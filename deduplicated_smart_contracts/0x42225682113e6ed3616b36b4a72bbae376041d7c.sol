pragma solidity ^0.5.10;

import './ESContract.sol'; /// @dev also contains safeMath

/// @title BetDeEx Smart Contract - The Decentralized Prediction Platform of Era Swap Ecosystem
/// @author The EraSwap Team
/// @notice This contract is used by manager to deploy new Bet contracts
/// @dev This contract also acts as treasurer
contract BetDeEx {
    using SafeMath for uint256;

    address[] public bets; /// @dev Stores addresses of bets
    address public superManager; /// @dev Required to be public because ES needs to be sent transaparently.

    EraswapToken esTokenContract;

    mapping(address => uint256) public betBalanceInExaEs; /// @dev All ES tokens are transfered to main BetDeEx address for common allowance in ERC20 so this mapping stores total ES tokens betted in each bet.
    mapping(address => bool) public isBetValid; /// @dev Stores authentic bet contracts (only deployed through this contract)
    mapping(address => bool) public isManager; /// @dev Stores addresses who are given manager privileges by superManager

    event NewBetContract (
        address indexed _deployer,
        address _contractAddress,
        uint8 indexed _category,
        uint8 indexed _subCategory,
        string _description
    );

    event NewBetting (
        address indexed _betAddress,
        address indexed _bettorAddress,
        uint8 indexed _choice,
        uint256 _betTokensInExaEs
    );

    event EndBetContract (
        address indexed _ender,
        address indexed _contractAddress,
        uint8 _result,
        uint256 _prizePool,
        uint256 _platformFee
    );

    /// @dev This event is for indexing ES withdrawl transactions to winner bettors from this contract
    event TransferES (
        address indexed _betContract,
        address indexed _to,
        uint256 _tokensInExaEs
    );

    modifier onlySuperManager() {
        require(msg.sender == superManager, "only superManager can call");
        _;
    }

    modifier onlyManager() {
        require(isManager[msg.sender], "only manager can call");
        _;
    }

    modifier onlyBetContract() {
        require(isBetValid[msg.sender], "only bet contract can call");
        _;
    }

    /// @notice Sets up BetDeEx smart contract when deployed
    /// @param _esTokenContractAddress is EraSwap contract address
    constructor(address _esTokenContractAddress) public {
        superManager = msg.sender;
        isManager[msg.sender] = true;
        esTokenContract = EraswapToken(_esTokenContractAddress);
    }

    /// @notice This function is used to deploy a new bet
    /// @param _description is the question of Bet in plain English, bettors have to understand the bet description and later choose to bet on yes no or draw according to their preference
    /// @param _category is the broad category for example Sports. Purpose of this is only to filter bets and show in UI, hence the name of the category is not stored in smart contract and category is repressented by a number (0, 1, 2, 3...)
    /// @param _subCategory is a specific category for example Football. Each category will have sub categories represented by a number (0, 1, 2, 3...)
    /// @param _minimumBetInExaEs is the least amount of ExaES that can be betted, any bet participant (bettor) will have to bet this amount or higher. Betting higher amount gives more share of winning amount
    /// @param _prizePercentPerThousand is a form of representation of platform fee. It is a number less than or equal to 1000. For eg 2% is to be collected as platform fee then this value would be 980. If 0.2% then 998.
    /// @param _isDrawPossible is functionality for allowing a draw option
    /// @param _pauseTimestamp Bet will be open for betting until this timestamp, after this timestamp, any user will not be able to place bet. and manager can only end bet after this time
    /// @return address of newly deployed bet contract. This is for UI of Admin panel.
    function createBet(
        string memory _description,
        uint8 _category,
        uint8 _subCategory,
        uint256 _minimumBetInExaEs,
        uint256 _prizePercentPerThousand,
        bool _isDrawPossible,
        uint256 _pauseTimestamp
    ) public onlyManager returns (address) {
        Bet _newBet = new Bet(
          _description,
          _category,
          _subCategory,
          _minimumBetInExaEs,
          _prizePercentPerThousand,
          _isDrawPossible,
          _pauseTimestamp
        );
        bets.push(address(_newBet));
        isBetValid[address(_newBet)] = true;

        emit NewBetContract(
          msg.sender,
          address(_newBet),
          _category,
          _subCategory,
          _description
        );

        return address(_newBet);
    }

    /// @notice this function is used for getting total number of bets
    /// @return number of Bet contracts deployed by BetDeEx
    function getNumberOfBets() public view returns (uint256) {
        return bets.length;
    }







    /// @notice this is for giving access to multiple accounts to manage BetDeEx
    /// @param _manager is address of new manager
    function addManager(address _manager) public onlySuperManager {
        isManager[_manager] = true;
    }

    /// @notice this is for revoking access of a manager to manage BetDeEx
    /// @param _manager is address of manager who is to be converted into a former manager
    function removeManager(address _manager) public onlySuperManager {
        isManager[_manager] = false;
    }

    /// @notice this is an internal functionality that is only for bet contracts to emit a event when a new bet is placed so that front end can get the information by subscribing to  contract
    function emitNewBettingEvent(address _bettorAddress, uint8 _choice, uint256 _betTokensInExaEs) public onlyBetContract {
        emit NewBetting(msg.sender, _bettorAddress, _choice, _betTokensInExaEs);
    }

    /// @notice this is an internal functionality that is only for bet contracts to emit event when a bet is ended so that front end can get the information by subscribing to  contract
    function emitEndEvent(address _ender, uint8 _result, uint256 _gasFee) public onlyBetContract {
        emit EndBetContract(_ender, msg.sender, _result, betBalanceInExaEs[msg.sender], _gasFee);
    }

    /// @notice this is an internal functionality that is used to transfer tokens from bettor wallet to BetDeEx contract
    function collectBettorTokens(address _from, uint256 _betTokensInExaEs) public onlyBetContract returns (bool) {
        require(esTokenContract.transferFrom(_from, address(this), _betTokensInExaEs), "tokens should be collected from user");
        betBalanceInExaEs[msg.sender] = betBalanceInExaEs[msg.sender].add(_betTokensInExaEs);
        return true;
    }

    /// @notice this is an internal functionality that is used to transfer prizes to winners
    function sendTokensToAddress(address _to, uint256 _tokensInExaEs) public onlyBetContract returns (bool) {
        betBalanceInExaEs[msg.sender] = betBalanceInExaEs[msg.sender].sub(_tokensInExaEs);
        require(esTokenContract.transfer(_to, _tokensInExaEs), "tokens should be sent");

        emit TransferES(msg.sender, _to, _tokensInExaEs);
        return true;
    }

    /// @notice this is an internal functionality that is used to collect platform fee
    function collectPlatformFee(uint256 _platformFee) public onlyBetContract returns (bool) {
        require(esTokenContract.transfer(superManager, _platformFee), "platform fee should be collected");
        return true;
    }

}

/// @title Bet Smart Contract
/// @author The EraSwap Team
/// @notice This contract is governs bettors and is deployed by BetDeEx Smart Contract
contract Bet {
    using SafeMath for uint256;

    BetDeEx betDeEx;

    string public description; /// @dev question text of the bet
    bool public isDrawPossible; /// @dev if false then user cannot bet on draw choice
    uint8 public category; /// @dev sports, movies
    uint8 public subCategory; /// @dev cricket, football

    uint8 public finalResult; /// @dev given a value when manager ends bet
    address public endedBy; /// @dev address of manager who enters the correct choice while ending the bet

    uint256 public creationTimestamp; /// @dev set during bet creation
    uint256 public pauseTimestamp; /// @dev set as an argument by deployer
    uint256 public endTimestamp; /// @dev set when a manager ends bet and prizes are distributed

    uint256 public minimumBetInExaEs; /// @dev minimum amount required to enter bet
    uint256 public prizePercentPerThousand; /// @dev percentage of bet balance which will be dristributed to winners and rest is platform fee
    uint256[3] public totalBetTokensInExaEsByChoice = [0, 0, 0]; /// @dev array of total bet value of no, yes, draw voters
    uint256[3] public getNumberOfChoiceBettors = [0, 0, 0]; /// @dev stores number of bettors in a choice

    uint256 public totalPrize; /// @dev this is the prize (platform fee is already excluded)

    mapping(address => uint256[3]) public bettorBetAmountInExaEsByChoice; /// @dev mapps addresses to array of betAmount by choice
    mapping(address => bool) public bettorHasClaimed; /// @dev set to true when bettor claims the prize

    modifier onlyManager() {
        require(betDeEx.isManager(msg.sender), "only manager can call");
        _;
    }

    /// @notice this sets up Bet contract
    /// @param _description is the question of Bet in plain English, bettors have to understand the bet description and later choose to bet on yes no or draw according to their preference
    /// @param _category is the broad category for example Sports. Purpose of this is only to filter bets and show in UI, hence the name of the category is not stored in smart contract and category is repressented by a number (0, 1, 2, 3...)
    /// @param _subCategory is a specific category for example Football. Each category will have sub categories represented by a number (0, 1, 2, 3...)
    /// @param _minimumBetInExaEs is the least amount of ExaES that can be betted, any bet participant (bettor) will have to bet this amount or higher. Betting higher amount gives more share of winning amount
    /// @param _prizePercentPerThousand is a form of representation of platform fee. It is a number less than or equal to 1000. For eg 2% is to be collected as platform fee then this value would be 980. If 0.2% then 998.
    /// @param _isDrawPossible is functionality for allowing a draw option
    /// @param _pauseTimestamp Bet will be open for betting until this timestamp, after this timestamp, any user will not be able to place bet. and manager can only end bet after this time
    constructor(string memory _description, uint8 _category, uint8 _subCategory, uint256 _minimumBetInExaEs, uint256 _prizePercentPerThousand, bool _isDrawPossible, uint256 _pauseTimestamp) public {
        description = _description;
        isDrawPossible = _isDrawPossible;
        category = _category;
        subCategory = _subCategory;
        minimumBetInExaEs = _minimumBetInExaEs;
        prizePercentPerThousand = _prizePercentPerThousand;
        betDeEx = BetDeEx(msg.sender);
        creationTimestamp = now;
        pauseTimestamp = _pauseTimestamp;
    }

    /// @notice this function gives amount of ExaEs that is total betted on this bet
    function betBalanceInExaEs() public view returns (uint256) {
        return betDeEx.betBalanceInExaEs(address(this));
    }

    /// @notice this function is used to place a bet on available choice
    /// @param _choice should be 0, 1, 2; no => 0, yes => 1, draw => 2
    /// @param _betTokensInExaEs is amount of bet
    function enterBet(uint8 _choice, uint256 _betTokensInExaEs) public {
        require(now < pauseTimestamp, "cannot enter after pause time");
        require(_betTokensInExaEs >= minimumBetInExaEs, "betting tokens should be more than minimum");

        /// @dev betDeEx contract transfers the tokens to it self
        require(betDeEx.collectBettorTokens(msg.sender, _betTokensInExaEs), "betting tokens should be collected");

        // @dev _choice can be 0 or 1 and it can be 2 only if isDrawPossible is true
        if (_choice > 2 || (_choice == 2 && !isDrawPossible) ) {
            require(false, "this choice is not available");
        }

        getNumberOfChoiceBettors[_choice] = getNumberOfChoiceBettors[_choice].add(1);
        totalBetTokensInExaEsByChoice[_choice] = totalBetTokensInExaEsByChoice[_choice].add(_betTokensInExaEs);

        bettorBetAmountInExaEsByChoice[msg.sender][_choice] = bettorBetAmountInExaEsByChoice[msg.sender][_choice].add(_betTokensInExaEs);

        betDeEx.emitNewBettingEvent(msg.sender, _choice, _betTokensInExaEs);
    }

    /// @notice this function is used by manager to load correct answer
    /// @param _choice is the correct choice
    function endBet(uint8 _choice) public onlyManager {
        require(now >= pauseTimestamp, "cannot end bet before pause time");
        require(endedBy == address(0), "Bet Already Ended");

        // @dev _choice can be 0 or 1 and it can be 2 only if isDrawPossible is true
        if(_choice < 2  || (_choice == 2 && isDrawPossible)) {
            finalResult = _choice;
        } else {
            require(false, "this choice is not available");
        }

        endedBy = msg.sender;
        endTimestamp = now;

        /// @dev the platform fee is excluded from entire bet balance and this is the amount to be distributed
        totalPrize = betBalanceInExaEs().mul(prizePercentPerThousand).div(1000);

        /// @dev this is the left platform fee according to the totalPrize variable above
        uint256 _platformFee = betBalanceInExaEs().sub(totalPrize);

        /// @dev sending plaftrom fee to the super manager
        require(betDeEx.collectPlatformFee(_platformFee), "platform fee should be collected");

        betDeEx.emitEndEvent(endedBy, _choice, _platformFee);
    }

    /// @notice this function can be called by anyone to see how much winners are getting
    /// @param _bettorAddress is address whose prize we want to see
    /// @return winner prize of input address
    function seeWinnerPrize(address _bettorAddress) public view returns (uint256) {
        require(endTimestamp > 0, "cannot see prize before bet ends");

        return bettorBetAmountInExaEsByChoice[_bettorAddress][finalResult].mul(totalPrize).div(totalBetTokensInExaEsByChoice[finalResult]);
    }

    /// @notice this function will be called after bet ends and winner bettors can withdraw their prize share
    function withdrawPrize() public {
        require(endTimestamp > 0, "cannot withdraw before end time");
        require(!bettorHasClaimed[msg.sender], "cannot claim again");
        require(bettorBetAmountInExaEsByChoice[msg.sender][finalResult] > minimumBetInExaEs, "caller should have a betting"); /// @dev to keep out option 0
        uint256 _winningAmount = bettorBetAmountInExaEsByChoice[msg.sender][finalResult].mul(totalPrize).div(totalBetTokensInExaEsByChoice[finalResult]);
        bettorHasClaimed[msg.sender] = true;
        betDeEx.sendTokensToAddress(
            msg.sender,
            _winningAmount
        );
    }
}
