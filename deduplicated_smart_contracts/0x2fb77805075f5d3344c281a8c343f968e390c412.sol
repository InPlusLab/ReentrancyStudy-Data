/**
 *Submitted for verification at Etherscan.io on 2019-09-08
*/

pragma solidity^0.5.11;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/*
  Lock and Hold is a contract for people with terrible self control.  
  
*/

contract LockAndHold {
    
    using SafeMath for uint256;
    
    address public initializer;
    
    /*
      All times are approximations since human time is a silly construct.
    */
    
    uint256 constant ONE_MONTH    = 2629746;
    uint256 constant THREE_MONTHS = 7889238;
    uint256 constant SIX_MONTHS   = 15778476;
    uint256 constant YEAR         = 31556952;
    
    string public padding = "0x0909090909";
    
    mapping (int256 => uint256) Times;
    
    struct Lock {
        bytes32 id;
        uint256 value;
        uint256 withdrawl_time;
    }
    
    mapping (address => Lock) locks;
    mapping (address => bool) lock_registry;
    //mapping (bytes32 => Lock) lookupLockByID;
    
    
    modifier requireNotAlreadyLocked(){
        require(!lock_registry[msg.sender], "Sending Address already has locked funds");
        _;
    }
    
    modifier requireIsAlreadyLocked(){
        require(lock_registry[msg.sender], "Sending Address has no locked funds");
        _;
    }
    
    
    constructor () public {
      initializer = msg.sender;
      
      // Setting at Construction
      Times[1] = THREE_MONTHS;
      Times[2] = SIX_MONTHS;
      Times[3] = YEAR;
    }
    
    /*
      View Functions
    */
    
    function isAddressLocking(address _address) public view returns (bool) {
        return lock_registry[_address];
    }
    
    function getLockReceiptBySender(address _address) public view returns (bytes memory) {
        Lock storage t = locks[_address];
        return abi.encode(t.id, padding, t.value, padding, t.withdrawl_time);
    }
    
    function getLockAmountBySender(address _address) public view returns (uint256) {
        return locks[_address].value;
    }
    
    function getLockupUntilTimeBySender(address _address) public view returns (uint256) {
        return locks[_address].withdrawl_time;
    }
    
    function getCurrentBlockTime() public view returns (uint256){
        return block.timestamp;
    }
    
    /*
      Internal Function that creates lock ID's for receipts
    */
    
    function __generateId(address _sender, uint256 _now, uint _salt) private pure returns (bytes32 id){
        return keccak256(abi.encode(_sender, _now, _salt));
    }
    
    /*
      Lock on Specific time outlined in Contract (Recommended way to use)
    */
    
    function lockOnTime(int8 _timeIDX) requireNotAlreadyLocked external payable {
        uint256 until = block.timestamp.add(Times[_timeIDX]);
        bytes32 id = __generateId(msg.sender, block.timestamp, block.number);
        
        locks[msg.sender] = Lock(id, msg.value, until);
        lock_registry[msg.sender] = true;
        
        emit Receipt(id, msg.value, block.timestamp, until);
    }
    
    /*
      Lock on a number of months.  Minimum is 1 month.  If you need to lock up for less than that
      ...what the fuck is wrong with you?
    */
    
    function customLockByMonth(uint256 _number_of_months) requireNotAlreadyLocked external payable {
        uint256 time_to_lock = _number_of_months.mul(ONE_MONTH);
        uint256 until = block.timestamp.add(time_to_lock);
        bytes32 id = __generateId(msg.sender, block.timestamp, block.number);
        
        locks[msg.sender] = Lock(id, msg.value, until);
        
        lock_registry[msg.sender] = true;
        
        emit Receipt(id, msg.value, block.timestamp, until);
    }
    
    /*
      Witthdrawl function for getting stuff out.
    */
    
    function withdrawl() requireIsAlreadyLocked external {
        require(locks[msg.sender].withdrawl_time <= block.timestamp, "Lockup period is still in effect");
        
        msg.sender.transfer(locks[msg.sender].value);
        locks[msg.sender].value = 0; // Just in case...
        lock_registry[msg.sender] = false;
        
        emit Withdrawl(msg.sender, block.timestamp);
    }

    /*
      If user sends funds directly without function will revert
    */
    
    function () external {
      revert();
    }
    
    event Receipt(bytes32 id, uint256 amount, uint256 locked_on, uint256 until);
    event Message(bytes16 status, bytes32 msg);
    event Withdrawl(address to, uint256 on);
}