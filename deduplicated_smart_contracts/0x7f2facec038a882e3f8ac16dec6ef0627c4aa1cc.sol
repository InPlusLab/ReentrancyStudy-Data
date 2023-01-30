pragma solidity ^0.5.17;

import './Ownable.sol';
import './ERC20Detailed.sol';

contract RealEstate is Ownable, ERC20Detailed {

    using SafeMath for uint256;
    using SafeMathInt for int256;
	using UInt256Lib for uint256;

	struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }


    event TransactionFailed(address indexed destination, uint index, bytes data);

	// Stable ordering is not guaranteed.

    Transaction[] public transactions;


    modifier validRecipient(address to) {
        require(to != address(this));
        _;
    }

    uint256 public constant DECIMALS = 10;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint256 public constant INITIAL_SUPPLY = 20 * 10**4 * 10**DECIMALS;
    address public Distributor;
    mapping (address => bool) public govs;

    uint256 public _totalSupply;
    uint256 public _currentPrice;
    uint256 public _targetPrice;
    uint256 public _userLength;
    uint public _commission;

    mapping(address => uint256) public _updatedBalance;
	mapping(address => bool) userStatus;
	mapping(uint => address) public idByAddress;

    mapping (address => mapping (address => uint256)) public _allowance;
    event AddGovEmp(address account);
    event RemoveGovEmp(address account);
    
	constructor() public {

		Ownable.initialize(msg.sender);
		ERC20Detailed.initialize("Real Estate Host", "REH", uint8(DECIMALS));

        _totalSupply = INITIAL_SUPPLY;
        _updatedBalance[msg.sender] = _totalSupply;

        _userLength++;
        idByAddress[_userLength] = msg.sender;
        _commission = 8; // initial at 8% fee
        addGovEmp(msg.sender);
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    
    modifier onlyDistributor() {
        require(msg.sender == Distributor, "Only Distributor");
        _;
    }

	/**
     * @return The total number of fragments.
     */

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }
    
	/**
     * @param who The address to query.
     * @return The balance of the specified address.
     */

    function balanceOf(address who)
        public
        view
        returns (uint256)
    {
        return _updatedBalance[who];
    }
    
    /**
     * @param amount The amount to be transferred.
     * @return commission base (Government wont apply)
     */
    function commissionCalculate(uint256 amount) internal view returns(uint256){
        if (govs[msg.sender] == true) return 0;
        uint256 fee = amount.mul(_commission).div(100);
        return fee;
    }
    /**
     * Add and remove a Gov employee
     */ 
    function addGovEmp(address account) public onlyOwner {
        govs[account] = true;
        emit AddGovEmp(account);
    }

    function removeGovEmp(address account) public onlyOwner {
        govs[account] = false;
        emit RemoveGovEmp(account);
    }
    
	/**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return True on success, false otherwise.
     */

    function transfer(address to, uint256 value)
        public
        validRecipient(to)
        returns (bool)
    {
        if(!userStatus[to]){
            userStatus[to] = true;
            _userLength++;
            idByAddress[_userLength] = to;
        }
        uint256 fee = commissionCalculate(value);
        uint256 receive = value - fee;
        _updatedBalance[msg.sender] = _updatedBalance[msg.sender].sub(value);
        _updatedBalance[to] = _updatedBalance[to].add(receive);
        updateSupplyDecreaseBy(fee);

        emit Transfer(msg.sender, to, receive);
        emit Transfer(msg.sender, address(0x0), fee);
        return true;
    }
    
    function updateSupplyDecreaseBy(uint256 value) private{
        _totalSupply = _totalSupply - value;
    }
	/**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return The number of tokens still available for the spender.
     */

    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowance[owner_][spender];
    }

	/**
     * @dev Transfer tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */

    function transferFrom(address from, address to, uint256 value)
        public
        validRecipient(to)
        returns (bool)
    {
        _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);

        if(!userStatus[to]){
            userStatus[to] = true;
            _userLength++;
             idByAddress[_userLength] = to;
        }
        uint256 fee = commissionCalculate(value);
        uint256 receive = value - fee;
        
        _updatedBalance[from] = _updatedBalance[from].sub(value);
        _updatedBalance[to] = _updatedBalance[to].add(receive);
        updateSupplyDecreaseBy(fee);

        emit Transfer(from, to, value);
        emit Transfer(from, address(0x0), fee);

        return true;
    }


	/**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * increaseAllowance and decreaseAllowance should be used instead.
     * Changing an allowance with this method brings the risk that someone may transfer both
     * the old and the new allowance - if they are both greater than zero - if a transfer
     * transaction is mined before the later approve() call is mined.
     *
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */

    function approve(address spender, uint256 value)
        public
        returns (bool)
    {
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

	/**
     * @dev Increase the amount of tokens that an owner has allowed to a spender.
     * This method should be used instead of approve() to avoid the double approval vulnerability
     * described above.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

	/**
     * @dev Decrease the amount of tokens that an owner has allowed to a spender.
     *
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 oldValue = _allowance[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowance[msg.sender][spender] = 0;
        } else {
            _allowance[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    function setTotalSupply(uint256 _supply) private onlyDistributor {
        _totalSupply = _supply;
    }

    function setCommission(uint commission) public onlyDistributor{
        require(commission <= 8, "commission cant exceed 8 percent.");
        _commission = commission;
    }
    function setDistributor(address _Distributor) public onlyOwner {
        Distributor = _Distributor;
    }

    function getUserLength() public view returns(uint256) {
        return _userLength;
    }

    function getUserAddress(uint256 id) public view returns(address) {
        return idByAddress[id];
    }

}

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
        require(b > 0, errorMessage);
        uint256 c = a / b;

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

library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a)
        internal
        pure
        returns (int256)
    {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

library UInt256Lib {

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    /**
     * @dev Safely converts a uint256 to an int256.
     */
    function toInt256Safe(uint256 a)
        internal
        pure
        returns (int256)
    {
        require(a <= MAX_INT256);
        return int256(a);
    }
}