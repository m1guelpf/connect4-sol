// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import './Hevm.sol';
import '../ConnectFour.sol';

contract User {}

contract ConnectFourTest is DSTest {
	Hevm internal hevm;
	User internal user;
	ConnectFour internal game;

	event GameWon(address indexed winner, uint256 gameId);
	event MovePerformed(address indexed mover, uint256 gameId, uint8 row);
	event GameProposed(address indexed challenger, address indexed challenged);

	function setUp() public {
		user = new User();
		game = new ConnectFour();
		hevm = Hevm(HEVM_ADDRESS);
	}

	function testCanChallengePlayer() public {
		hevm.expectEmit(true, true, false, true);
		emit GameProposed(address(this), address(user));
		uint256 gameId = game.challenge(address(user));

		(address player1, address player2, uint8 moves, bool finished) = game.getGame(gameId);

		assertEq(player1, address(user));
		assertEq(player2, address(this));
		assertEq(moves, 0);
		assertTrue(!finished);
	}

	function testCanMakeMove() public {
		hevm.prank(address(user));
		uint256 gameId = game.challenge(address(this));

		hevm.expectEmit(true, false, false, true);
		emit MovePerformed(address(this), gameId, 4);
		game.makeMove(gameId, 4);

		(, , uint8 moves, bool finished) = game.getGame(gameId);

		assertEq(moves, 1);
		assertTrue(!finished);
	}

	function testPlayersMustTakeTurns() public {
		hevm.prank(address(user));
		uint256 gameId = game.challenge(address(this));

		game.makeMove(gameId, 4);

		hevm.expectRevert(ConnectFour.Unauthorized.selector);
		game.makeMove(gameId, 4);

		hevm.prank(address(user));
		game.makeMove(gameId, 4);

		hevm.prank(address(user));
		hevm.expectRevert(ConnectFour.Unauthorized.selector);
		game.makeMove(gameId, 4);

		(, , uint8 moves, ) = game.getGame(gameId);
		assertEq(moves, 2);
	}

	function testCannotMakeMoveOnInvalidRow() public {
		uint256 gameId = game.challenge(address(user));

		hevm.prank(address(user));
		hevm.expectRevert(stdError.indexOOBError);
		game.makeMove(gameId, 8);
	}

	function testCannotMakeMoveOnInvalidColumn() public {
		uint256 gameId = game.challenge(address(this));

		game.makeMove(gameId, 4);
		game.makeMove(gameId, 4);
		game.makeMove(gameId, 4);
		game.makeMove(gameId, 4);
		game.makeMove(gameId, 4);
		game.makeMove(gameId, 4);

		hevm.expectRevert(ConnectFour.InvalidMove.selector);
		game.makeMove(gameId, 4);
	}

	function testCanWinGame() public {
		uint256 gameId = game.challenge(address(user));

		hevm.prank(address(user));
		game.makeMove(gameId, 4);
		game.makeMove(gameId, 3);
		hevm.prank(address(user));
		game.makeMove(gameId, 4);
		game.makeMove(gameId, 3);
		hevm.prank(address(user));
		game.makeMove(gameId, 4);
		game.makeMove(gameId, 3);

		hevm.prank(address(user));
		hevm.expectEmit(true, false, false, true);
		emit GameWon(address(user), gameId);
		game.makeMove(gameId, 4);

		assertTrue(game.didPlayerWin(gameId, 0));
		assertTrue(!game.didPlayerWin(gameId, 1));

		(, , uint8 moves, bool finished) = game.getGame(gameId);

		assertEq(moves, 7);
		assertTrue(finished);

		hevm.expectRevert(ConnectFour.GameFinished.selector);
		game.makeMove(gameId, 3);
	}
}
