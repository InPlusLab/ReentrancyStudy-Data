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

import "./lynctoken.sol";

contract LYNCLottoLYNC {

    //Enable SafeMath
    using SafeMath for uint256;

    address payable public owner;
    address public contractAddress;
    address public holdingAddress;
    address public lastRoundWinner;
    uint256 public playersMax;
    uint256 public entryValue;
    uint256 public thisRoundPot;
    uint256 public winnerPercent;
    uint256 public winnerPot;
    uint256 public tokenPot;

    LYNCToken public tokenContract;

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
    address[] public playersThisRound;

    //On deployment
    constructor(LYNCToken _tokenContract) {
        owner = msg.sender;
        tokenContract = _tokenContract;
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
    function enterLotto(uint256 _entryTokens) external returns (bool) {
        uint256 _entryValueFee = mulDiv(entryValue, tokenContract.feePercent(), 100);
        uint256 _entryValueMinusFee = entryValue.sub(_entryValueFee);
        require(_entryTokens > _entryValueMinusFee, "Minimum entry value was not met");
        require(tokenContract.transferFrom(msg.sender, address(this), _entryTokens));

        if (playersThisRound.length < playersMax - 1) {

            //Check if this is a first play
            if (players[msg.sender].plays == 0) {
                allPlayers.push(msg.sender);
            }

            //Add player to the round
            playersThisRound.push(msg.sender);
            thisRoundPot = thisRoundPot.add(_entryValueMinusFee);
            players[msg.sender].plays++;

        } else {

            //Check if this is a first play
            if (players[msg.sender].plays == 0) {
                allPlayers.push(msg.sender);
            }

            //Add player to the round
            playersThisRound.push(msg.sender);
            thisRoundPot = thisRoundPot.add(_entryValueMinusFee);
            players[msg.sender].plays++;

            //Calculate pots and pick a winner
            winnerPot = mulDiv(thisRoundPot, winnerPercent, 100);
            uint256 _thisRoundTokenPot = thisRoundPot.sub(winnerPot);
            tokenPot = tokenPot.add(_thisRoundTokenPot);
            pickWinner();
        }

        emit EnterConfirm(msg.sender, _entryTokens);
        return true;
    }

    //Pick a winner and reset the round
    function pickWinner() internal {
        uint256 winner = random() % playersThisRound.length;
        address _winnerAddress = playersThisRound[winner];
        players[_winnerAddress].wins++;
        lastRoundWinner = _winnerAddress;
        require(tokenContract.transfer(playersThisRound[winner], winnerPot));
        playersThisRound = new address[](0);
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
    function holdingAddressUpdate(address _holdingAddress) public onlyOwner {
        holdingAddress = _holdingAddress;
    }

    //Transfer token pot balance
    function transferTokenPotBalance() public onlyOwner {
        require(tokenContract.transfer(holdingAddress, tokenPot));
        tokenPot = 0;
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
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        selfdestruct(owner);
    }

    //Modifiers
    modifier onlyOwner() {
        require(owner == msg.sender, "Only current owner can call this function");
        _;
    }
}
