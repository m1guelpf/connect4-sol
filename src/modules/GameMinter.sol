// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "base64/base64.sol";
import "../ConnectFour.sol";
import "solmate/tokens/ERC721.sol";
import "StringUtils/StringUtils.sol";

contract GameMinter is ERC721("Connect 4", "CONN4"), StringUtils {
    error CannotMintGame();

    ConnectFour public immutable connect4;

    constructor(ConnectFour _connect4) {
        connect4 = _connect4;
    }

    function mint(uint256 gameId) public payable {
        (address player1, address player2, , bool finished) = connect4.getGame(
            gameId
        );
        bool didPlayer1Win = connect4.didPlayerWin(gameId, 0);
        if (!finished || msg.sender != (didPlayer1Win ? player1 : player2))
            revert CannotMintGame();

        _mint(msg.sender, gameId);
    }

    function drawBoard(uint256 id) internal view returns (string memory) {
        (uint64 player1Board, uint64 player2Board) = connect4.getBoards(id);

        string[] memory rows = new string[](7);
        for (uint256 rowNum = 0; rowNum < 7; rowNum++) {
            string[] memory columns = new string[](6);
            for (uint256 colNum = 0; colNum < 6; colNum++) {
                uint256 bbPos = 7 * rowNum + colNum;

                if (
                    (player1Board >> bbPos) % 2 == 0 &&
                    (player2Board >> bbPos) % 2 == 0
                ) continue;

                columns[colNum] = string(
                    abi.encodePacked(
                        '<circle cx="50" cy="',
                        toString((5 - colNum) * 100 + 50),
                        '" r="45" fill="',
                        (player1Board >> bbPos) % 2 == 0
                            ? "#22d3ee"
                            : "#f472b6",
                        '"></circle>'
                    )
                );
            }

            rows[rowNum] = string(
                abi.encodePacked(
                    '<svg x="',
                    toString(rowNum * 100),
                    '" y="0">',
                    columns[0],
                    columns[1],
                    columns[2],
                    columns[3],
                    columns[4],
                    columns[5],
                    '<rect width="100" height="600" fill="#7c3aed" mask="url(#cell-mask)"></rect></svg>'
                )
            );
        }

        string memory encoded = Base64.encode(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 600" stroke="none" width="350px"><defs>'
                '<pattern id="cell-pattern" patternUnits="userSpaceOnUse" width="100" height="100"><circle cx="50" cy="50" r="45" fill="black"></circle></pattern>',
                '<mask id="cell-mask"><rect width="100" height="600" fill="white"></rect><rect width="100" height="600" fill="url(#cell-pattern)"></rect></mask></defs>',
                rows[0],
                rows[1],
                rows[2],
                rows[3],
                rows[4],
                rows[5],
                rows[6],
                "</svg>"
            )
        );

        return string(abi.encodePacked("data:image/svg+xml;base64,", encoded));
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        (address player1, address player2, , ) = connect4.getGame(id);
        address winner = connect4.didPlayerWin(id, 0) ? player1 : player2;

        bytes memory json = abi.encodePacked(
            '{"name": "Connect Four #',
            toString(id),
            unicode'", "description": "This NFT represents a game of Connect4 played on the blockchain, and won by ',
            winner,
            '.", "image": "',
            drawBoard(id),
            '"}'
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(json)
                )
            );
    }
}
