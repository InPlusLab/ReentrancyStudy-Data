pragma solidity 0.5.17;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./MorpheusToken.sol";
import "./Rabbits.sol";
import "./randomOracle.sol";

// GameController Contract
// It is a ownable contract. It meens that some function can only be call by the owner/creator of contract
// Ownable will be transfer to a DAO after 3 months of production

contract MorpheusGameController is Ownable {
    using SafeMath for uint256;
    
    constructor(randomOracle _oracle, address _oracleAddress)
        public
    {
        // init first instance of game
        _lastRewardTime = now;
        beginningTime = now;
        
                //init oracle
        oracle = _oracle;
        oracleAddress = _oracleAddress;
    }

    // Tokens used in game
    MorpheusToken public morpheus;
    Rabbits public rabbits;
    randomOracle public oracle;
    
    // Oracle Address is an external smart contract providing a random result for the game.
    address public oracleAddress;
    
    // Beginning game time
    uint256 public beginningTime;

    // Rewards
    uint256 private _lastRewardTime;
    // Total quantity of tokens in the reward pool
    uint256 private _rewardPool;

    // number of period / claim
    uint256 private _numberOfPeriod = 1;

    // Total value played
    uint256 private _totalValuePlayed;
    // Total value burned
    uint256 private _totalValueBurned;
    
    // Total period value played
    uint256 private _totalValuePlayedOnPeriod;
    
    //Minimum balance you need to activate claim function
    uint256 public minimumBalanceForClaim = 10000*1E18;

    // All players from a period between 2 claims
    // Reload each time globalClaim is activated
    address[] public _playersFromPeriod;

    // Addresses of Zion stackers. 
    // Reload each time globalClaim is activated
    address[] private _zionStackers;

    // Reward part for each players, used for calculate proportion reward

    // Reward that player can claim
    mapping(address => uint256) private _myRewardTokens;

    // Values used for calculate who are Kings and proportionnal of the reward pool
    mapping(address => uint256) private _myPeriodLoss;
    mapping(address => uint256) private _myPeriodBets;

    // King ot the mountain is the player who have done the most bets value in a period
    // There is only one King of the mountain, if someone got the same bets value,
    // he can't dethrone the king, only a bigger bets value can dethrone the actual king
    address public kingOfTheMountain;

    // alert event needed for alert of any provableAPI problem
    event alertEvent(string alert);
    
    event rewardClaimed(address claimer,uint256 claimerGain,uint256 burntValue);
    event newKingOfTheMountain(address king);
    // need for result of playing instance 1 = win : 2 =Lost
    event gotAResult(address _player, uint8 _result);
    

    // =========================================================================================
    // Settings Functions  that only owner can call
    // =========================================================================================
    

    // Set the MorpheusToken address
    function setMorpheusToken(MorpheusToken _morpheusToken) public onlyOwner() {
        morpheus = _morpheusToken;
        emit alertEvent("Morpheus token has been set");
    }

    // Set the RabbitToken address
    function setRabbitsToken(Rabbits _rabbits) public onlyOwner() {
        rabbits = _rabbits;
        emit alertEvent("Rabbits token has been set");
    }
    
    // set minimum balance for claimerGain
    function setMinimumBalanceForClaim(uint256 _amount) public onlyOwner() {
        minimumBalanceForClaim = _amount.mul(1E18);
        emit alertEvent("Minimum balance for claim has been updated");
    }
    
    
    // =========================================================================================
    // Zion stackers
    // =========================================================================================
    
    uint256 _zionStackingValue = 50000;
    
    function setStackingValue(uint256 _amount) public onlyOwner(){
        _zionStackingValue = _amount;
    }
    
    function getZionStackersNumber() public view returns(uint256 _numberOfStackers){
        return(_zionStackers.length);
    }

    // add Zion stacker Addresse
    function becomeZionStacker() public {
        require(morpheus.balanceOf(msg.sender)>_zionStackingValue.mul(1E18),"Not enough balance");
        require(!isStacker(msg.sender),"Already a Zion stacker");
        require(_zionStackers.length<50, "There's no place place for you");
        morpheus.transferFrom(msg.sender, address(this), _zionStackingValue.mul(1E18));
        _zionStackers.push(msg.sender);
    }
    
    // reload Zion stackers
    function _eraseZionStackers() private {
        address[] memory _emptyArray;
        _zionStackers = _emptyArray;
    }
    
    // check if already stackers
    function isStacker(address _user) public view returns(bool){
        bool _isStacker = false;
        for(uint256 i = 0 ; i<_zionStackers.length ; i++){
            if(_zionStackers[i] == _user){
                _isStacker = true;
                break;
            }
        }
        return _isStacker;
    }


    // =========================================================================================
    // Get Functions
    // =========================================================================================

    // Get game infos
    function getGameData()
        public
        view
        returns (
            uint256 totalPeriod,
            uint256 totalValuePlayed,
            uint256 totalValuePlayedOnPeriod,
            uint256 totalValueBurned,
            uint256 lastRewardTime,
            uint256 actualPool,
            uint256 totalPlayersForThosePeriod
        )
    {
        return (
            _numberOfPeriod,
            _totalValuePlayed,
            _totalValuePlayedOnPeriod,
            _totalValueBurned,
            _lastRewardTime,
            _rewardPool,
            _playersFromPeriod.length
        );
    }

    // Get personnal game infos
    function getPersonnalData(address _user)
        public
        view
        returns (
            uint256 playerRewardTokens,
            uint256 playerPeriodLoss,
            uint256 playerPeriodBets
        )
    {
        return (
            _myRewardTokens[_user],
            _myPeriodLoss[_user],
            _myPeriodBets[_user]
        );
    }

    // =========================================================================================
    // Play Functions
    // =========================================================================================

    // Frontend will send the color choice of player. For code simplicity,
    // the color is hard coding by a number value
    // Blue is 0 and Red is 1

    struct gameInstance {
        address player;
        uint8 choice;
        uint256 amount;
    }
    
    // Variable used for prevent any claim before gameInstance isn't finished
    // meens the time before the choose pills action and the return of oracle random number
    uint256 public gameInstanceNumber = 0;

    mapping(bytes32 => gameInstance) gamesInstances;

    function choosePils(uint256 amount, uint8 _choice) public payable {
        require(amount > 0 && amount <= 250000,"Your bet must be between 0 to 250 000 MGT");
        uint256 _amount = amount.mul(1E18);
        // Need to have found amount
        require(morpheus.balanceOf(msg.sender) > _amount, "You don't have suffisant balance");
        // 0 = Blue or 1 = Red
        require(_choice == 0 || _choice == 1, "Choice must be 0 or 1" );

        // First transfer tokens played in the contract
        morpheus.transferFrom(msg.sender, address(this), _amount);
        
        // Add 1 to game instances number
        gameInstanceNumber = gameInstanceNumber.add(1);
         
        // Add player to list
        if(!_isPlayerInList(msg.sender)){
          _playersFromPeriod.push(msg.sender);
        }

        // Update total value played by all players
        _totalValuePlayed = _totalValuePlayed.add(_amount);
        
        _totalValuePlayedOnPeriod = _totalValuePlayedOnPeriod.add(_amount);

        // Update value of total played by the player
        _myPeriodBets[msg.sender] = _myPeriodBets[msg.sender].add(_amount);

         // Update king of the mountain if needed
        if (_myPeriodBets[msg.sender] > _myPeriodBets[kingOfTheMountain]) {
            kingOfTheMountain = msg.sender;
            emit newKingOfTheMountain(msg.sender);
        }

        // init an bytes32 id 
        bytes32 _id = keccak256(abi.encodePacked(
            _rewardPool.add(1),
            _totalValuePlayed,
            _lastRewardTime,
            _totalValueBurned.add(1)
            ));
            
        gamesInstances[_id] = gameInstance(msg.sender, _choice, _amount);
        oracle.getRandom(_id);
    }

    // Call back function used by proableAPI
    function callback(bytes32 _id,uint _result) external {
        // Only provable address can call this function
        require(msg.sender == oracleAddress, "Callback doesn't come from good Oracle");
        require(gamesInstances[_id].player != address(0x0), "Instance dosn't exist");

            // If color is the same played by player
            if (_result == gamesInstances[_id].choice) {
                //Mint token in contract 
                morpheus.mintTokensForWinner(gamesInstances[_id].amount);
                //Then send it to player
                morpheus.transfer(
                    gamesInstances[_id].player,
                    gamesInstances[_id].amount.mul(2)
                );
                emit gotAResult(gamesInstances[_id].player,1);
                    
            //If player loose
            } else {
                // Update loss of player
                _myPeriodLoss[gamesInstances[_id].player] = (_myPeriodLoss[gamesInstances[_id].player]).add(gamesInstances[_id].amount);
    
                // Update reward pool
                _rewardPool = _rewardPool.add(gamesInstances[_id].amount);
    
                emit gotAResult(gamesInstances[_id].player, 0);
                
            }

        delete gamesInstances[_id];
        gameInstanceNumber = gameInstanceNumber.sub(1);
    }
    
    // Checking if player is on the players list 
    function _isPlayerInList(address _player) internal view returns (bool) {
        bool exist = false;
        for (uint8 i = 0; i < _playersFromPeriod.length; i++) {
            if (_playersFromPeriod[i] == _player) {
                exist = true;
                break;
            }
        }
        return exist;
    }

    // Providing king of loosers address
    function _getKingOfLoosers() public view returns (address) {
        address _kingOfLoosers;
        uint256 _valueLost = 0;
        for (uint256 i = 0; i < _playersFromPeriod.length; i++) {
            // If player got loss
            if (
                _myPeriodBets[_playersFromPeriod[i]].div(2) <
                _myPeriodLoss[_playersFromPeriod[i]]
            ) {
                // Calculate total loss by player
                uint256 _lostByi = _myPeriodLoss[_playersFromPeriod[i]].sub(
                    _myPeriodBets[_playersFromPeriod[i]].div(2)
                );
                // There can be only one King of loosers
                // If draw, player whos has reached the first is the king
                if (_valueLost < _lostByi) {
                    _valueLost = _lostByi;
                    _kingOfLoosers = _playersFromPeriod[i];
                }
            }
        }
        return (_kingOfLoosers);
    }

    // =========================================================================================
    // Rewards Functions
    // =========================================================================================

    function claimRewards() public {
        require(gameInstanceNumber == 0, "There is a game instance pending please wait");
        require(_rewardPool > 0,"Reward pool is empty !!!");
        require(morpheus.balanceOf(msg.sender)>minimumBalanceForClaim,"You don't have enough MGT for call this function");

        // Security re entry
        uint256 _tempRewardPool = _rewardPool;
        uint256 _originalLostValue = _rewardPool;
        _rewardPool = 0;
        _totalValuePlayedOnPeriod = 0;
        _lastRewardTime = now;

        // update number of period 
        _numberOfPeriod = _numberOfPeriod.add(1);

        // First rewarding kings and claimer
        uint256 rewardForKings = (_tempRewardPool.mul(100)).div(10000);
        _transferToKingOfMountain(rewardForKings);
        
        // It is possible there is no king of loosers 
        if(_getKingOfLoosers() != address(0x0)){
            _transferToKingOfLoosers(rewardForKings);
        }

        
        // Because solidity don't know floating number, 0.5 % will be 50/10000
        uint256 _claimerPercentage = _getClaimerPercentage();
        uint256 rewardForClaimer = (_tempRewardPool.mul(_claimerPercentage)).div(10000);
        morpheus.transfer(msg.sender, rewardForClaimer);

        // then Burning
        uint256 burnPercentage = _getBurnPercentage();
        uint256 totalToBurn = (_tempRewardPool.mul(burnPercentage)).div(10000);
        morpheus.burnTokens(totalToBurn);
        _totalValueBurned = _totalValueBurned.add(totalToBurn);

        // Update temp reward pool
        // If there is there is king of loosers
        if(_getKingOfLoosers() != address(0x0)){
            _tempRewardPool = _tempRewardPool.sub(rewardForKings);
        }
        _tempRewardPool = _tempRewardPool.sub(rewardForKings);
        _tempRewardPool = _tempRewardPool.sub(rewardForClaimer);
        _tempRewardPool = _tempRewardPool.sub(totalToBurn);

        // Zion stackers rewards 10%
        if(_zionStackers.length>0){
            
            uint256 rewardForZionStackers = (_tempRewardPool.mul(1000)).div(10000);
            _transferToZionStackers(rewardForZionStackers);

            // update _rewardPool
            _tempRewardPool = _tempRewardPool.sub(rewardForZionStackers);
        }

        // Update rewards and refresh period .
        _setRewards(_tempRewardPool,_originalLostValue);

        emit rewardClaimed(msg.sender, rewardForClaimer, totalToBurn);
    }

    // After claimRewards, players can manualy claim them part of MGT
    function claimMyReward() public {
        require(_myRewardTokens[msg.sender] > 0, "You don't have any token to claim");
        // Re entry secure
        uint256 _myTempRewardTokens = _myRewardTokens[msg.sender];
        _myRewardTokens[msg.sender] = 0;
        morpheus.transfer(msg.sender, _myTempRewardTokens);
    }
    
    function _getClaimerPercentage() public view returns (uint256) {
        uint256 _timeSinceLastReward = now.sub(_lastRewardTime);
        // 50 meens 0.5% => it will be divid by 10000
        uint256 _claimPercentage = 50;

        if (_timeSinceLastReward > 1 days && _timeSinceLastReward < 2 days) {
            _claimPercentage = 100;
        }
        if (_timeSinceLastReward >= 2 days && _timeSinceLastReward < 3 days) {
            _claimPercentage = 150;
        }
        if (_timeSinceLastReward >= 3 days && _timeSinceLastReward < 4 days) {
            _claimPercentage = 200;
        }
        if (_timeSinceLastReward >= 4 days && _timeSinceLastReward < 5 days) {
            _claimPercentage = 250;
        }
        if (_timeSinceLastReward >= 5 days) {
            _claimPercentage = 300;
        }
        return _claimPercentage;
    }

    function _getBurnPercentage() public view returns (uint256) {
        uint256 _timeSinceLastReward = now.sub(_lastRewardTime);
        uint256 _burnPercentage = 8950;

        if (_timeSinceLastReward > 1 days && _timeSinceLastReward < 2 days) {
            _burnPercentage = 7900;
        }
        if (_timeSinceLastReward >= 2 days && _timeSinceLastReward < 3 days) {
            _burnPercentage = 6850;
        }
        if (_timeSinceLastReward >= 3 days && _timeSinceLastReward < 4 days) {
            _burnPercentage = 5800;
        }
        if (_timeSinceLastReward >= 4 days && _timeSinceLastReward < 5 days) {
            _burnPercentage = 4750;
        }
        if (_timeSinceLastReward >= 5 days ) {
            _burnPercentage = 3700;
        }
        return _burnPercentage;
    }

    function _setRewards(uint256 _rewardAmmount, uint256 _originalLostValue) private {
        require(_originalLostValue > 0 && _playersFromPeriod.length > 0);
        // Reentry secure
        uint256 _tempTotalRewardPart = _originalLostValue.mul(100);

        for (uint256 i = 0; i < _playersFromPeriod.length; i++) {
            // Check if player got reward part
            if (_myPeriodLoss[_playersFromPeriod[i]] > 0) {
                // Reentry secure
                uint256 _myTempRewardPart
                 = _myPeriodLoss[_playersFromPeriod[i]].mul(100);
                _myPeriodLoss[_playersFromPeriod[i]] = 0;

                uint256 _oldPersonnalReward
                 = _myRewardTokens[_playersFromPeriod[i]];
                _myRewardTokens[_playersFromPeriod[i]] = 0;

                // Calculate personnal reward to add
                uint256 personnalReward = (
                    _rewardAmmount.mul(_myTempRewardPart)
                )
                    .div(_tempTotalRewardPart);

                //  Add to old rewards
                _myRewardTokens[_playersFromPeriod[i]] = _oldPersonnalReward
                    .add(personnalReward);
            }
        }
        _deleteAllPlayersFromPeriod();
    }

    // update players of the period
    function _deleteAllPlayersFromPeriod() private {
        for (uint256 i = 0; i < _playersFromPeriod.length; i++) {
            _myPeriodLoss[_playersFromPeriod[i]] = 0;
            _myPeriodBets[_playersFromPeriod[i]] = 0;
        }
        address[] memory _newArray;
        _playersFromPeriod =_newArray;
    }

    function _transferToZionStackers(uint256 _amount) private {
        // To be sure to have a valid uint we substract modulo of matrixRunners number to amount
        uint256 amountModuloStackersNumber = _amount.sub(_amount % _zionStackers.length);
        // calculate value to transfer
        uint256 _toTransfer = amountModuloStackersNumber.div(_zionStackers.length);
        // + add stacking tokens
        _toTransfer = _toTransfer.add(_zionStackingValue.mul(1E18));
        for (uint256 i = 0; i < _zionStackers.length; i++) {
            morpheus.transfer(
                _zionStackers[i],
                _toTransfer
            );
        }
        _eraseZionStackers();
    }

    function _transferToKingOfMountain(uint256 _amount) private {
        require(kingOfTheMountain != address(0x0), "There is no king of the mountain ");
        // Re entry secure
        address _kingOfTheMountain = kingOfTheMountain;
        kingOfTheMountain = address(0x0);

        morpheus.transfer(_kingOfTheMountain, _amount);
    }

    function _transferToKingOfLoosers(uint256 _amount) private {
        if(_getKingOfLoosers() != address(0x0)){
            morpheus.transfer(_getKingOfLoosers(), _amount);           
        }
    }

    // =========================================================================================
    // Rabbits Functions
    // =========================================================================================
    

    // superclaim is the function who can only call the owner of 3 rabbits (3 different colors)
    // Those 3 rabbits will be burn and 50% of the reward pool wll be transfer to claimer
    // Rabbits must be approvedForAll by the owner for contract of gameAddress
    function superClaim(
        uint256 _id1,
        uint256 _id2,
        uint256 _id3
    ) public {
        require(gameInstanceNumber == 0, "There is a game instance pending please wait");
        require(_rewardPool > 0, "There is no reward on pool");
        // Can't be called before 30 days 
        require(now.sub(beginningTime) >= 40 days);
        require(
            (rabbits.ownerOf(_id1) == msg.sender &&
            rabbits.ownerOf(_id2) == msg.sender &&
            rabbits.ownerOf(_id3) == msg.sender),
            "You don't have the required Rabbits !!!"
        );
        // Re entry secure
        uint256 _tempRewardPool = _rewardPool;
        _rewardPool = 0;
        
        // Update number of periods of clock
        _numberOfPeriod = _numberOfPeriod.add(1);
        _lastRewardTime = now;
        
        // Reward kings
        uint256 rewardForKings = (_tempRewardPool.mul(1)).div(100);
        _transferToKingOfMountain(rewardForKings);
        _transferToKingOfLoosers(rewardForKings);
        
        // Reward superClaimer
        uint256 rewardForClaimer = _tempRewardPool.div(2);
        morpheus.transfer(msg.sender, rewardForClaimer);
        
        // update reward to burn
        _tempRewardPool = _tempRewardPool.sub(rewardForClaimer);
        _tempRewardPool = _tempRewardPool.sub(rewardForKings.mul(2));
        
        // Burn tokens
        morpheus.burnTokens(_tempRewardPool);
        _totalValueBurned = _totalValueBurned.add(_tempRewardPool);

        // Burn Rabbits
        rabbits.burnRabbitsTrilogy(msg.sender, _id1, _id2, _id3);
        // Update players for period.
        _deleteAllPlayersFromPeriod();

    }
    

}
