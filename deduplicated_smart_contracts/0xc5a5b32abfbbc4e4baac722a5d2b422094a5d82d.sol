/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address public owner;





    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );





    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor() public {

        owner = msg.sender;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * @notice Renouncing to ownership will leave the contract without an owner.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);

        owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param _newOwner The address to transfer ownership to.

     */

    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param _newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0));

        emit OwnershipTransferred(owner, _newOwner);

        owner = _newOwner;

    }

}



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

    event Pause();

    event Unpause();



    bool public paused = false;





    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!paused);

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(paused);

        _;

    }



    /**

     * @dev called by the owner to pause, triggers stopped state

     */

    function pause() public onlyOwner whenNotPaused {

        paused = true;

        emit Pause();

    }



    /**

     * @dev called by the owner to unpause, returns to normal state

     */

    function unpause() public onlyOwner whenPaused {

        paused = false;

        emit Unpause();

    }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (_a == 0) {

            return 0;

        }



        c = _a * _b;

        assert(c / _a == _b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        // assert(_b > 0); // Solidity automatically throws when dividing by 0

        // uint256 c = _a / _b;

        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return _a / _b;

    }



    /**

    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        assert(_b <= _a);

        return _a - _b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        c = _a + _b;

        assert(c >= _a);

        return c;

    }

}





interface BBTxInterface {

    function snapshot() external returns(uint256);

    function circulationAt(uint256 _snapshotId) external view returns(uint256);

    function balanceOfAt(address _account, uint256 _snapshotId) external view returns (uint256);

}



contract Dividend is Pausable {

    using SafeMath for *;



    struct RoundInfo {

        uint256 bbtSnapshotId;

        uint256 dividend;

    }



    struct CurrentRoundInfo {

        uint256 roundId;

        uint256 dividend;

        bool isEnded;   // default is false

    }



    BBTxInterface private BBT;   // BBT contract

    mapping (uint256 => CurrentRoundInfo) public currentRound_;  // (gameId => current round information)

    mapping (uint256 => mapping(address => uint256)) public playersWithdrew_;    // (gameId => plyAddr => withdrewEth)

    mapping (uint256 => mapping(uint256 => RoundInfo)) public roundsInfo_;  // gameId => roundId => RoundInfo

    mapping (uint256 => uint256[]) public roundIds_;    //gameId => roundIds

    mapping (uint256 => uint256) public cumulativeDividend;  // gameId => cumulative total dividend;

    address[] public games;    //registered games (gameID => gameContractAddress)

    mapping (address => uint256) public gameIdxAddress;  //address => gameId



    event Deposited(uint256 indexed _gameId, address indexed _from, uint256 indexed _round, uint256 _value);

    event Distributed(uint256 indexed _gameId, uint256 indexed _roundId, uint256 bbtSnapshotId, uint256 dividend);

    event Withdrew(uint256 indexed _gameId, address indexed _from, uint256 _value);



    modifier isHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;



        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }



    modifier onlyRegistered(address _gameAddress) {

        bool ifRegistered = hasRegistered(_gameAddress);

        require(ifRegistered == true, 'not registered.');

        _;

    }



    modifier validGameId(uint256 _gameId) {

        require(_gameId <= getGameCount(), 'invalid gameId.');

        _;

    }



    constructor(address _bbtAddress) public {

        BBT = BBTxInterface(_bbtAddress);

        games.push(address(0)); //map gameId 0 to address 0x0

    }



    /**

    * @dev fetch gameId by gameAddress.

    * @param _gameAddress game contract address.

    * @return return registered game id, or 0 if not registered.

    */

    function getGameId(address _gameAddress) public view returns(uint256) {

        return gameIdxAddress[_gameAddress];

    }



    /**

    * @dev get total registered game count.

    */

    function getGameCount() public view returns(uint256) {

        return games.length - 1;    //exclude gameId 0

    }



    /**

    * @dev register game.

    * @param _gameAddress game contract address.

    * @return return registered game id.

    */

    function register(address _gameAddress)

        onlyOwner

        whenNotPaused

        public

        returns(uint256)

    {

        bool ifRegistered = hasRegistered(_gameAddress);

        require(ifRegistered == false, 'already registered.');

        uint256 gameId = (games.push(_gameAddress)).sub(1);

        gameIdxAddress[_gameAddress] = gameId;

        return gameId;

    }



    /**

    * @dev unregister game.

    * @param _gameAddress game contract address.

    * @return return bool.

    */

    function unRegister(address _gameAddress)

        onlyOwner

        whenNotPaused

        onlyRegistered(_gameAddress)

        public

        returns(bool)

    {

        uint256 gameId = getGameId(_gameAddress);

        games[gameId] = address(0);

        gameIdxAddress[_gameAddress] = 0;

        return true;

    }



    /**

    * @dev check if the given address already register.

    * @return return true if registered.

    */

    function hasRegistered(address _gameAddress) public view returns(bool) {

        uint256 gameId = getGameId(_gameAddress);

        if (gameId == 0)

            return false;

        return true;

    }



    /**

     * @dev get count of game rounds

     */

    function getRoundsCount(uint256 _gameId)

        validGameId(_gameId)

        public

        view

        returns(uint256)

    {

        return roundIds_[_gameId].length;

    }



    /**

     * @dev deposit dividend eth in.

     * @param _round which round the dividend for.

     * @return deposit success.

     */

    function deposit(uint256 _round)

        onlyRegistered(msg.sender)

        whenNotPaused

        public

        payable

        returns(bool)

    {

        uint256 gameId = getGameId(msg.sender);

        require(msg.value > 0, "deposit amount should not be empty.");

        require(_round > 0 && _round >= currentRound_[gameId].roundId, "can not deposit dividend for past round.");



        if (_round == currentRound_[gameId].roundId) {

            require(currentRound_[gameId].isEnded == false, "this round has ended. can not deposit.");

            currentRound_[gameId].dividend = (currentRound_[gameId].dividend).add(msg.value);

        } else {    // new round

            if (currentRound_[gameId].roundId > 0)  //when first deposit come in, don't check isEnded.

                require(currentRound_[gameId].isEnded == true, "last round not end. can not deposit new round.");

            currentRound_[gameId].roundId = _round;

            currentRound_[gameId].isEnded = false;

            currentRound_[gameId].dividend = msg.value;

        }



        cumulativeDividend[gameId] = cumulativeDividend[gameId].add(msg.value);



        emit Deposited(gameId, msg.sender, _round, msg.value);

        return true;

    }



    /**

     * @dev distribute dividend to BBT holder.

     * @param _round which round the distribution for.

     * @return distributed success.

     */

    function distribute(uint256 _round)

        onlyRegistered(msg.sender)

        whenNotPaused

        public

        returns(bool)

    {

        uint256 gameId = getGameId(msg.sender);

        require(_round > 0 && _round >= currentRound_[gameId].roundId, "can not distribute dividend for past round.");



        if (_round == currentRound_[gameId].roundId) {

            require(currentRound_[gameId].isEnded == false, "this round has ended. can not distribute again.");

        } else {    //when this round has no deposit

            require(currentRound_[gameId].isEnded == true, "last round not end. can not distribute new round.");

            currentRound_[gameId].roundId = _round;

            currentRound_[gameId].dividend = 0;

        }



        RoundInfo memory roundInfo;

        roundInfo.bbtSnapshotId = BBT.snapshot();

        roundInfo.dividend = currentRound_[gameId].dividend;

        roundsInfo_[gameId][currentRound_[gameId].roundId] = roundInfo;

        roundIds_[gameId].push(currentRound_[gameId].roundId);



        currentRound_[gameId].isEnded = true;   //mark this round is ended



        emit Distributed(gameId, currentRound_[gameId].roundId, roundInfo.bbtSnapshotId, roundInfo.dividend);

        return true;

    }



    /**

     * @dev player withdraw dividend out.

     */

    function withdraw(uint256 _gameId)

        validGameId(_gameId)

        whenNotPaused

        isHuman

        public

    {

        uint256 plyLeftDividend = getPlayerLeftDividend(_gameId, msg.sender);

        if (plyLeftDividend > 0) {

            (msg.sender).transfer(plyLeftDividend);

            playersWithdrew_[_gameId][msg.sender] = (playersWithdrew_[_gameId][msg.sender]).add(plyLeftDividend);

        }

        emit Withdrew(_gameId, msg.sender, plyLeftDividend);

    }



    /**

     * @dev player withdraw dividend out.

     */

    function withdrawAll()

        whenNotPaused

        isHuman

        public

    {

        uint256 gameCount_ = getGameCount();

        for (uint256 i = 1; i <= gameCount_; i++) {

            withdraw(i);

        }

    }



    /**

     * @dev get player dividend by round id and game id.

     */

    function getPlayerRoundDividend(uint256 _gameId, address _plyAddr, uint256 _roundId)

        validGameId(_gameId)

        public

        view

        returns(uint256)

    {

        RoundInfo storage roundInfo = roundsInfo_[_gameId][_roundId];

        // cause circulation divided by token decimal, so the balance should divide by it too.

        uint256 plyRoundBBT = (BBT.balanceOfAt(_plyAddr, roundInfo.bbtSnapshotId)).div(1e18);

        return plyRoundBBT.mul(getRoundDividendPerBBTHelper(_gameId, _roundId));

    }



    /**

     * @dev get player dividend by round id and game address.

     */

    function getPlayerRoundDividendByAddr(address _gameAddr, address _plyAddr, uint256 _roundId)

        public

        view

        returns(uint256)

    {

        uint256 gameId = getGameId(_gameAddr);

        return getPlayerRoundDividend(gameId, _plyAddr, _roundId);

    }



    /**

     * @dev get player total dividend by game id.

     */

    function getPlayerTotalDividend(uint256 _gameId, address _plyAddr)

        validGameId(_gameId)

        public

        view

        returns(uint256)

    {

        uint256 plyTotalDividend;

        for (uint256 i = 0; i < roundIds_[_gameId].length; i++) {

            uint256 roundId = roundIds_[_gameId][i];

            plyTotalDividend = plyTotalDividend.add(getPlayerRoundDividend(_gameId, _plyAddr, roundId));

        }

        return plyTotalDividend;

    }



    /**

     * @dev get player total dividend by game addr.

     */

    function getPlayerTotalDividendByAddr(address _gameAddr, address _plyAddr)

        public

        view

        returns(uint256)

    {

        uint256 gameId = getGameId(_gameAddr);

        return getPlayerTotalDividend(gameId, _plyAddr);

    }



    /**

     * @dev get player left dividend(total - withdrew) by game id

     */

    function getPlayerLeftDividend(uint256 _gameId, address _plyAddr)

        validGameId(_gameId)

        public

        view

        returns(uint256)

    {

        return (getPlayerTotalDividend(_gameId, _plyAddr)).sub(playersWithdrew_[_gameId][_plyAddr]);

    }



    /**

     * @dev get player left dividend(total - withdrew) by game address

     */

    function getPlayerLeftDividendByAddr(address _gameAddr, address _plyAddr)

        public

        view

        returns(uint256)

    {

        uint256 gameId = getGameId(_gameAddr);

        return getPlayerLeftDividend(gameId, _plyAddr);

    }



    /**

     * @dev calculate dividend per BBT by round id.

     */

    function getRoundDividendPerBBTHelper(uint256 _gameId, uint256 _roundId)

        internal

        view

        returns(uint256)

    {

        RoundInfo storage roundInfo = roundsInfo_[_gameId][_roundId];



        if (roundInfo.dividend == 0)

            return 0;



        // must divide by token decimal, or circulation is greater than dividend,

        // the result will be 0, not 0.xxx(cause solidity not support float.)

        // and the func which rely on this helper will get the result 0 too.

        uint256 circulationAtSnapshot = (BBT.circulationAt(roundInfo.bbtSnapshotId)).div(1e18);

        if (circulationAtSnapshot == 0)

            return 0;

        return (roundInfo.dividend).div(circulationAtSnapshot);

    }

}