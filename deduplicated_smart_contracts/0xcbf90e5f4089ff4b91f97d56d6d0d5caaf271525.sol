// SPDX-License-Identifier: MIT

  /**
   * LYNC Network
   * https://lync.network
   *
   * Additional details for contract and wallet information:
   * https://lync.network/tracking/
   *
   * The cryptocurrency network designed for passive token rewards for its community.
   */

pragma solidity ^0.7.0;

import "./safemath.sol";

contract LYNCLottoETH {

    //Enable SafeMath
    using SafeMath for uint256;

    address payable public owner;
    address public contractAddress;
    address payable public holdingAddress;
    address public lastRoundWinner;
    uint256 public playersMax;
    uint256 public entryValue;
    uint256 public thisRoundPot;
    uint256 public winnerPercent;
    uint256 public winnerPot;
    uint256 public pumpPot;

    //Events
    event EnterConfirm(address _player, uint256 _entryFee);
    event WinnerPayment(address _winner, uint256 _winnerPayment);
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
    event OwnershipRenounced(address indexed _previousOwner, address indexed _newOwner);

	//User data
	struct Player {
		uint256 wins;
		uint256 plays;
	}

    //Mappings
    mapping(address => Player) players;

    //All players array
    address[] public allPlayers;

    //Players this round array
    address payable[] public playersThisRound;

    //On deployment
    constructor () {
        owner = msg.sender;
        contractAddress = address(this);
    }

    //MulDiv functions : source https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
    function mulDiv(uint x, uint y, uint z) public pure returns (uint) {
          (uint l, uint h) = fullMul (x, y);
          assert (h < z);
          uint mm = mulmod(x, y, z);
          if (mm > l) h -= 1;
          l -= mm;
          uint pow2 = z & -z;
          z /= pow2;
          l /= pow2;
          l += h * ((-pow2) / pow2 + 1);
          uint r = 1;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          return l * r;
    }

    //Required for MulDiv
    function fullMul(uint x, uint y) private pure returns (uint l, uint h) {
          uint mm = mulmod(x, y, uint (-1));
          l = x * y;
          h = mm - l;
          if (mm < l) h -= 1;
    }

    //Return total number of players this round
    function totalPlayersThisRound() public view returns(uint256) {
        return playersThisRound.length;
    }

    //Return all players
    function exportPlayerList() public view returns(address[] memory) {
        return allPlayers;
    }

    //Return player data
    function exportPlayerData(address _playersList) public view returns(uint256, uint256) {
        return(players[_playersList].wins, players[_playersList].plays);
    }

    //Enter the lotto
    function enterLotto() public payable {
        require(msg.value >= entryValue, "Minimum entry value was not met");

        if (playersThisRound.length < playersMax - 1) {

            //Check if this is a first play
            if (players[msg.sender].plays == 0) {
                allPlayers.push(msg.sender);
            }

            //Add player to the round
            playersThisRound.push(msg.sender);
            thisRoundPot = thisRoundPot.add(entryValue);
            players[msg.sender].plays++;

        } else {

            //Check if this is a first play
            if (players[msg.sender].plays == 0) {
                allPlayers.push(msg.sender);
            }

            //Add player to the round
            playersThisRound.push(msg.sender);
            thisRoundPot = thisRoundPot.add(entryValue);
            players[msg.sender].plays++;

            //Calculate pots and pick a winner
            uint256 _winnerPotShare = mulDiv(thisRoundPot, winnerPercent, 100);
            winnerPot = _winnerPotShare;
            thisRoundPot = thisRoundPot.sub(_winnerPotShare);
            pumpPot = pumpPot.add(thisRoundPot);
            pickWinner();
        }

        emit EnterConfirm(msg.sender, msg.value);
    }

    //Pick a winner and reset the round
    function pickWinner() internal {
        uint256 winner = random() % playersThisRound.length;
        address _winnerAddress = playersThisRound[winner];
        players[_winnerAddress].wins++;
        lastRoundWinner = _winnerAddress;
        playersThisRound[winner].transfer(winnerPot);
        playersThisRound = new address payable[](0);
        emit WinnerPayment(_winnerAddress, winnerPot);

        //Reset Pots
        winnerPot = 0;
        thisRoundPot = 0;
    }

    //Random generator
    function random() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    //Update minimum entry value (in wei)
    function minimumEntryUpdate(uint256 _entryValue) public onlyOwner {
        entryValue = _entryValue;
    }

    //Update number of players
    function playersMaxUpdate(uint256 _playersMax) public onlyOwner {
        playersMax = _playersMax;
    }

    //Update winner percentage
    function winnerPercenteUpdate(uint256 _winnerPercentage) public onlyOwner {
        winnerPercent = _winnerPercentage;
    }

    //Update the holding account address
    function holdingAddressUpdate(address payable _holdingAddress) public onlyOwner {
        holdingAddress = _holdingAddress;
    }

    //Transfer pump pot balance
    function transferPumpPotBalance() public onlyOwner {
        holdingAddress.transfer(pumpPot);
        pumpPot = 0;
    }

    //Transfer ownership to new owner
    function transferOwnership(address payable _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner cannot be a zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    //Remove owner from the contract
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner, address(0));
        owner = address(0);
    }

    //Close the contract and transfer any balances to the owner
    function closeContract() public onlyOwner {
        selfdestruct(owner);
    }

    //Modifiers
    modifier onlyOwner() {
        require(owner == msg.sender, "Only current owner can call this function");
        _;
    }
}
