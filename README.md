# Connect Four on the Blockchain

> An optimised Connect4 game implementation on Solidity

The [ConnectFour.sol](./src/ConnectFour.sol) contract has been deployed on mainnet at address [0x7CD285b59f38afd61b2Ab0505b5F9c318158ea42](https://etherscan.io/address/0x7cd285b59f38afd61b2ab0505b5f9c318158ea42). [GameMinter.sol](./src/modules/GameMinter.sol) will be deployed soon, along with a frontend for a better experience.

Still to do:

- [ ] Review & deploy [GameMinter.sol](./src/modules/GameMinter.sol) (do I need to make it `Ownable` for OpenSea details access?).
- [ ] Set up a subgraph for easier frontend data access.
- [ ] Build a simple frontend that lists current games, and shows the board.

## Design

The [ConnectFour.sol](./src/ConnectFour.sol) uses two [bitboards](https://en.wikipedia.org/wiki/Bitboard) (one for each player) to store the board state (`uint64[2] Game.board`). It also stores the height of each row (the position of the last empty block per row) for easier computation (`uint64[7] Game.height`). When making a move, we shift a single byte to the position stored in height for that row, and use the XOR operator to store it into our bitboard.

## Modules

### Game Minter

This module allows you to mint any games you have won as ERC-721 tokens. The metadata for these tokens is completely on-chain down to the image, which is a vector image generated by the contract and displaying the Connect4 board.

## Acknowledgements

The design of this contract is inspired from [Fhourstones](https://github.com/qu1j0t3/fhourstones), a program written by [John Tromp](http://tromp.github.io) in 1996 to calculate the best moves in the game of Connect4.
