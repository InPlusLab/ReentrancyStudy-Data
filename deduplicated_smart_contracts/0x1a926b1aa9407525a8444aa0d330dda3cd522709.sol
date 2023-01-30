/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity >=0.4.22 <0.6.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract NSTTeamLock{
    address public owner;
    modifier onlyOwner() {
      require(msg.sender == owner);
     _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        if (newOwner != address(0)) {
         owner = newOwner;
        }
    }
    using SafeMath for uint256;
    IERC20 token ;
    uint256 public TeamLockTime = 365 days;
    uint256 public TotalLock;
    uint256 private mouth = 30 days;
    address public TeamOwner;
    
    
    struct lockBody{
        uint8 lockType;
        uint256 unlockTime;
        uint256 value;
        uint256 getValue;
        uint256 getTime;
        uint256 firstRelease;
        uint256 release;
        bool isFirst;
        address tokenAddr;
    }

    mapping (address => lockBody) public addressOf;
    mapping (address => uint256) public totalLockOf;
    
    constructor(address _token,address _TeamOwner) public {
        token = IERC20(_token);
        owner = msg.sender;
        TeamOwner = _TeamOwner;
    }
    
    function allotTeamToken() public onlyOwner {
        uint256 _value = 400000000*10**18;
        uint256 _eyValue = 40000000*10**18;
        uint256 balanceOfthis = token.balanceOf(address(this));
        require(balanceOfthis.sub(TotalLock)>=_value,"代币余额不足");
        require(TeamOwner!=address(0),"权限地址不够");
        uint256 nowLockTime = uint256(now).add(TeamLockTime);
        addressOf[TeamOwner] = lockBody(1,nowLockTime,_value,0,nowLockTime,_eyValue,_eyValue,true,address(token));
        TotalLock = TotalLock.add(_value);
        totalLockOf[TeamOwner] = totalLockOf[TeamOwner].add(_value);
    }
    
    function setToken(address _token) public onlyOwner {
        token = IERC20(_token);
    }
    
    function changeOwner(address _addr) public onlyOwner {
            TeamOwner = _addr;
    }
    
    function releaseToken() public onlyOwner returns(bool success){
        require(TeamOwner!=address(0));
        lockBody memory _body = addressOf[TeamOwner];
        require(now>=_body.unlockTime);
        require(_body.value>0);
        require(_body.value>_body.getValue);
        uint256 _reValue = _body.value.sub(_body.getValue) ;
        uint256 _day = (now.sub(_body.getTime)).div(mouth);
        uint256 _value;
        if(_body.isFirst){
            _value = _value.add(_body.firstRelease) ;
            addressOf[TeamOwner].isFirst=false;
            _value = _value.add(_body.release.mul(_day));
        }else{
            _value = _value.add(_body.release.mul(_day));
        }
        if(_reValue<=_value){
            _value=_reValue;
        }
        addressOf[TeamOwner].getTime = addressOf[TeamOwner].getTime.add(_day.mul(mouth)) ;
        addressOf[TeamOwner].getValue = addressOf[TeamOwner].getValue.add(_value);
        TotalLock = TotalLock.sub(_value);
        totalLockOf[TeamOwner] = totalLockOf[TeamOwner].sub(_value);
        IERC20 _token = IERC20(_body.tokenAddr);
        _token.transfer(TeamOwner,_value);
        return true;
    }
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}