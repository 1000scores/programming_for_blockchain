// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.5;


contract RockPaperScissors {
	
	address public owner = msg.sender;

	uint256 public lastParticipantBlock = 0;

	address payable player1 = payable(address(0));
	address payable player2 = payable(address(0));

	bytes32 player1_choice_hash;
	bytes32 player2_choice_hash;

	bool player1_submitted_hash = false;
	bool player2_submitted_hash = false;

	uint256 gamePrice = 0;
	uint256 contractsMoneyFromFees = 0;

	uint256 fee = 0;

	enum State {
		Rock,
		Paper,
		Scissors
	}

	State player1_revealed_choice;
	State player2_revealed_choice;

	bool player1_revealed = false;
	bool player2_revealed = false;

	modifier OnlyOwner {
		require(msg.sender == owner);
		_;
	}
	// Not supported, because I still don't know how to use doubles in solidity
	function setFee(uint256 _fee) public OnlyOwner {
		fee = _fee / 100.0;
	}

	function getFees(address payable _to) public OnlyOwner {
		_to.transfer(contractsMoneyFromFees);
	}
	
	modifier CanAddParticipant {
		require(msg.sender != player1 && msg.sender != player2, "You can't participate for two players!");
		if (lastParticipantBlock != 0 && lastParticipantBlock + 200 < block.number) {
			endGame();
		}
		require(
			player1_choice_hash == 0 || player2_choice_hash == 0,
			"There are two players participating in smart contract already. Try later."
		);
		_;
	}

	event ParticipantAdded(address participant);

	function participate(bytes32 choice_hash) public payable CanAddParticipant {
		if (player1_choice_hash == 0) {
			player1_choice_hash = choice_hash;
			player1_submitted_hash = true;
			player1 = payable(msg.sender);
			gamePrice = msg.value;
		} else {
			player2_choice_hash = choice_hash;
			player2 = payable(msg.sender);
			if (msg.value < gamePrice) {
				bool status = player1.send(gamePrice - msg.value);
				require(status, "Error in refund to player1");
				gamePrice = msg.value;
			} else if(msg.value > gamePrice) {
				bool status = payable(msg.sender).send(msg.value - gamePrice);
				require(status, "Error in refund to player2");
			}
			lastParticipantBlock = block.number;
			player2_submitted_hash = true;
		}

		emit ParticipantAdded(msg.sender);
	}

	/*
	For debug
	function getAbiEncode(State choice, uint256 nonce) public pure returns (bytes memory) {
		return abi.encode(choice, nonce);
	}
	function getSha256(bytes memory abiEncoded) public pure returns (bytes32) {
		return sha256(abiEncoded);
	}
	function allTogether(State choice, uint256 nonce) public pure returns (bytes32) {
		return sha256(abi.encode(choice, nonce));
	}
	*/

	modifier ValidChoiceReveal(State choice, uint256 nonce) {
		require(player1_choice_hash != 0 && player2_choice_hash != 0, "Need two players in game to reveal choice");
		require(msg.sender == player1 || msg.sender == player2, "You don't participate in current game");
		bytes32 current_hash = sha256(abi.encode(choice, nonce));
		if (msg.sender == player1) {
			require(!player1_revealed, "You've already revealed your choice.");
			require(player1_choice_hash == current_hash, string.concat("Hashes is not equal. Your choice hasn't been revealed. current_hash = ", string(abi.encode(current_hash)), "player1_choice_hash", string(abi.encode(player1_choice_hash))));
			player1_revealed_choice = choice;
			player1_revealed = true;
		} else {
			require(!player2_revealed, "You've already revealed your choice.");
			require(player2_choice_hash == current_hash, string.concat("Hashes is not equal. Your choice hasn't been revealed. current_hash = ", string(abi.encode(current_hash)), "player2_choice_hash", string(abi.encode(player2_choice_hash))));
			player2_revealed_choice = choice;
			player2_revealed = true;
		}
		_;
	}

	event PlayerRevealedChoice(address player);

	function revealChoice(State choice, uint256 nonce) public ValidChoiceReveal(choice, nonce) {
		emit PlayerRevealedChoice(msg.sender);
		if (player1_revealed && player2_revealed) {
			getWinner();
		}
	}

	event Draw(address player1, address player2);

	function drawFunc() private {
		player1.transfer(gamePrice);
		player2.transfer(gamePrice);
		gamePrice = 0;
		emit Draw(player1, player2);
		makeFieldsEmpty();
	}

	event Player1Wins(address player1, address player2);

	function player1WinsFunc() private {
		uint256 feeForSmartContract = 2 * gamePrice * fee;
		player1.transfer(2 * gamePrice - feeForSmartContract);
		contractsMoneyFromFees += feeForSmartContract;
		gamePrice = 0;
		emit Player1Wins(player1, player2);
		makeFieldsEmpty();
	}

	event Player2Wins(address player1, address player2);

	function player2WinsFunc() private {
		uint256 feeForSmartContract = 2 * gamePrice * fee;
		player2.transfer(2 * gamePrice - feeForSmartContract);
		contractsMoneyFromFees += feeForSmartContract;
		gamePrice = 0;
		emit Player2Wins(player1, player2);
		makeFieldsEmpty();
	}

	function getWinner() private {
		if (player1_revealed_choice == State.Rock) {
			if (player2_revealed_choice == State.Rock) {
				drawFunc();
			} else if (player2_revealed_choice == State.Paper) {
				player2WinsFunc();
			} else {
				player1WinsFunc();
			}
		} else if (player1_revealed_choice == State.Paper) {
			if (player2_revealed_choice == State.Paper) {
				drawFunc();
			} else if (player2_revealed_choice == State.Rock) {
				player1WinsFunc();
			} else {
				player2WinsFunc();
			}
		} else {
			if (player2_revealed_choice == State.Scissors) {
				drawFunc();
			} else if (player2_revealed_choice == State.Paper) {
				player1WinsFunc();
			} else {
				player2WinsFunc();
			}
		}
	}

	event GotRefund(address player);

	function makeRefund(address accountForRefund) private {
		payable(accountForRefund).transfer(gamePrice);
		makeFieldsEmpty();
		emit GotRefund(msg.sender);
	}

	modifier CanGetRefund {
		require(player1 == msg.sender || player2 == msg.sender, "You don't participate in this game.");
		require(player1_submitted_hash, "Game hasn't started");
		_;
	}

    function getRefund() public CanGetRefund{
		if (!player2_submitted_hash) {
			require(msg.sender == player1, "Only participant can get refund");
			makeRefund(msg.sender);
			makeFieldsEmpty();
		} else if (lastParticipantBlock != 0 && lastParticipantBlock + 200 < block.number) {
			if (!player1_revealed && !player2_revealed) {
				drawFunc();
			} else if (!player1_revealed) {
				require(msg.sender == player1, "Only participant can get winners money");
				player2WinsFunc();
			} else {
				require(msg.sender == player1, "Only participant can get winners money");
				player1WinsFunc();
			}
		}
	}

	event RefundBothPlayers(address player1, address player2, uint256 sumOfRefund);

	function makeFieldsEmpty() private {
		lastParticipantBlock = 0;
		player1_choice_hash = 0;
		player2_choice_hash = 0;
		player1_revealed = false;
		player2_revealed = false;
		gamePrice = 0;
		player1_submitted_hash = false;
		player2_submitted_hash = false;
		player1 = payable(address(0));
		player2 = payable(address(0));
	}

	function endGame() private {
		if (gamePrice != 0) {
			if (!player1_revealed && !player2_revealed) {
				player1.transfer(gamePrice);
				player2.transfer(gamePrice);
				emit RefundBothPlayers(player1, player2, gamePrice);
			} else if(player1_revealed) {
				player1WinsFunc();
			} else {
				player2WinsFunc();
			}
		}

		makeFieldsEmpty();
	}
}
