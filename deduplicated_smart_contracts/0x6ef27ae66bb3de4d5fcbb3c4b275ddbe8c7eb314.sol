/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

pragma solidity >=0.5.0 <0.6.0;


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath#mul: OVERFLOW");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath#sub: UNDERFLOW");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath#add: OVERFLOW");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
        return a % b;
    }

}

//import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract GemstoneMine is Ownable {
    using SafeMath for uint256;
    
    address public gemAddress;
    address public gemLPAddress;
    address public secondTokenAddress; // A new token will be announced.
    address public secondTokenLPAddress;
    
    uint256 public totalAmountGemLPStaked;
    uint256 public totalAmountSecondaryLPStaked;

    event staked(address _guy, uint256 _amount, address _coin);
    event unstaked(address _guy, uint256 _amount, address _coin);
  
    struct stakeTracker {
        uint256 lastBlockChecked;
        uint256 points;
        uint256 personalGemLPStakedTokens;
        uint256 personalSecondaryLPStakedTokens;
    }

    mapping(address => stakeTracker) private _stakedTokens;
    
    
    modifier updateStakingPoints(address account) {
        if (block.number > _stakedTokens[account].lastBlockChecked) {
            uint256 rewardBlocks = block.number.sub(_stakedTokens[account].lastBlockChecked);
            if (_stakedTokens[account].personalGemLPStakedTokens > 0) {//gemLP
                _stakedTokens[account].points = _stakedTokens[account].points.add(_stakedTokens[account].personalGemLPStakedTokens.mul(rewardBlocks)/_getGemLPDifficulty());
            }
            if (_stakedTokens[account].personalSecondaryLPStakedTokens > 0) {//secondTokenLP
                _stakedTokens[account].points = _stakedTokens[account].points.add(_stakedTokens[account].personalSecondaryLPStakedTokens.mul(rewardBlocks)/_getSecondTokenLPDifficulty());
            } 
            _stakedTokens[account].lastBlockChecked = block.number;   
        }
        _;
    }

    function getStakedGemLPBalanceFrom(address _address) view public returns(uint256){
        return _stakedTokens[_address].personalGemLPStakedTokens;
    }
    
    function getStakedSecondaryLPBalanceFrom(address _address) view public returns(uint256){
        return _stakedTokens[_address].personalSecondaryLPStakedTokens;
    }
    
    function getLastBlockFrom(address _address) view public returns(uint256){
        return _stakedTokens[_address].lastBlockChecked;
    }
    
    function getLastPoints(address _address) view public returns(uint256){
        return _stakedTokens[_address].points;
    }
    
    
    
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant uniswapV2Factory = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    // address public lpAddress; calculate using library
    function _getLPAddress(address token0, address token1) internal pure returns (address){
        return UniswapV2Library.pairFor(uniswapV2Factory, token0, token1);
    }
    
    //function will be called after user claims (ownership will be transfered)
    function _resetPoints(address _address) external onlyOwner{
        _stakedTokens[_address].points = 0;
    }
    
    //calculate points before claiming
    function _updatePoints(address _address) external updateStakingPoints(_address) onlyOwner{
    }
    
    uint256 public gemDifficulty; // Base difficulty
    uint256 public gemScale;
    uint256 public secondTokenDifficulty;// Secondary token will be announced
    uint256 public secondTokenScale;

    IERC20 private gemToken;
    IERC20 private gemTokenLP;
    IERC20 private secondToken;
    IERC20 private secondTokenLP;
    
    function _getGemLPDifficulty() public view returns (uint256){
        return gemDifficulty.mul((totalAmountGemLPStaked+gemScale)/gemScale);
    }
    
    function _getSecondTokenLPDifficulty() public view returns (uint256){
        return secondTokenDifficulty.mul((totalAmountSecondaryLPStaked+secondTokenScale)/secondTokenScale);
    }
    
    function setGemAddress(address _address) public onlyOwner {
        gemAddress = _address;
        gemLPAddress = _getLPAddress(gemAddress, WETH);
        gemToken = IERC20(gemAddress);
        gemTokenLP = IERC20(gemLPAddress);
    }
    
    function setSecondTokenAddress(address _address) public onlyOwner{
        secondTokenAddress = _address;
        secondTokenLPAddress = _getLPAddress(secondTokenAddress, WETH);
        secondToken = IERC20(secondTokenAddress);
        secondTokenLP = IERC20(secondTokenLPAddress);
    }
    
    
    function setGemDifficulty(uint256 _difficulty, uint256 _scale) public onlyOwner{
        gemDifficulty = _difficulty;
        gemScale = _scale;
    }

    
    function setSecondTokenDifficulty(uint256 _difficulty, uint256 _scale) public onlyOwner{
        secondTokenDifficulty = _difficulty;
        secondTokenScale = _scale;
    }
    
    constructor() public {
        setGemDifficulty(4, 10**18);
        setGemAddress(0x8Df3872D7071076012173c2442272dbA7f9acB23);
    }

    function stakeGemLP(uint256 amount) external updateStakingPoints(msg.sender) {
        require(gemTokenLP.transferFrom(msg.sender, address(this), amount), "can't stake");
        totalAmountGemLPStaked = totalAmountGemLPStaked.add(amount);
        _stakedTokens[msg.sender].personalGemLPStakedTokens = _stakedTokens[msg.sender].personalGemLPStakedTokens.add(amount);
        emit staked(msg.sender, amount, gemLPAddress);
    }
    
    function stakeSecondTokenLP(uint256 amount) external updateStakingPoints(msg.sender) {
        require(secondTokenLP.transferFrom(msg.sender, address(this), amount), "can't stake");
        totalAmountSecondaryLPStaked = totalAmountSecondaryLPStaked.add(amount);
        _stakedTokens[msg.sender].personalSecondaryLPStakedTokens = _stakedTokens[msg.sender].personalSecondaryLPStakedTokens.add(amount);
        emit staked(msg.sender, amount, secondTokenLPAddress);
    }
    
    function unStakeGemLP(uint256 amount) external updateStakingPoints(msg.sender) {
        require(_stakedTokens[msg.sender].personalGemLPStakedTokens >= amount, "cant unstake");
        totalAmountGemLPStaked = totalAmountGemLPStaked.sub(amount);
        _stakedTokens[msg.sender].personalGemLPStakedTokens = _stakedTokens[msg.sender].personalGemLPStakedTokens.sub(amount);
        gemTokenLP.transfer(msg.sender, amount);
        emit unstaked(msg.sender, amount, gemLPAddress);
    }
    
    function unStakeSecondTokenLP(uint256 amount) external updateStakingPoints(msg.sender) {
        require(_stakedTokens[msg.sender].personalSecondaryLPStakedTokens >= amount, "cant unstake");
        totalAmountSecondaryLPStaked = totalAmountSecondaryLPStaked.sub(amount);
        _stakedTokens[msg.sender].personalSecondaryLPStakedTokens = _stakedTokens[msg.sender].personalSecondaryLPStakedTokens.sub(amount);
        secondTokenLP.transfer(msg.sender, amount);
        emit unstaked(msg.sender, amount, secondTokenLPAddress);
    }
}