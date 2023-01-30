
pragma solidity ^0.6.0;
import "./Context.sol";
import "./SafeMath.sol";
contract ERC20 is Context {
    using SafeMath for uint256;

    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;
    //need to go public
    uint256 public _totalSupply;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);



    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) virtual internal  {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
} //_mint passed as virtual bc overriden in ERC20Capped.
//======================================================================================================

//SPDX-Licence-Identifier: 2guys

pragma solidity ^0.6.0;

import "./ERC20.sol";

contract Steam is ERC20 {

    using SafeMath for uint256;

    modifier onlyUPS() {
        require(_UPS == _msgSender(), "onlyUPS: Only the UPStkn contract may call this function");
        _;
    }

    string private _name;
    address public _UPS;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _maxSupply;
    uint256 private _steamMinted = 0;

    event SteamGenerated(address account, uint amount);

    constructor(uint256 STEAM_maxTokens) public {
        _name = "STEAM";
        _symbol = "STMtkn";
        _decimals = 18;
        _maxSupply = STEAM_maxTokens.mul(1e18);
        ERC20._mint(_msgSender(), 1e18);
        _UPS =  _msgSender();
    }
    
    function generateSteam(address account, uint256 amount) external onlyUPS {
        require((_totalSupply + amount) < _maxSupply, "STEAM token: cannot generate more steam than the max supply");
        ERC20._mint(account, amount);
        _steamMinted = _steamMinted.add(amount);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return ERC20._totalSupply;
    }
    
    function mySteam(address _address) public view returns(uint256){
        return balanceOf(_address);
    }
    
    function getSteamTotalSupply() public view returns(uint256){
        return _totalSupply;
    }
    
    function getSteamMaxSupply() public view returns(uint256){
        return _maxSupply;
    }
    
    function getSteamMinted() public view returns(uint256){
        return _steamMinted;
    }

}

pragma solidity ^0.6.0;
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
} // File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.0;
library SafeMath{
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

        /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
} // File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
} // File: @openzeppelin/contracts/token/ERC20/IERC20.sol
//SPDX-Licence-Identifier: 2guys

//======================================================================================================


pragma solidity ^0.6.0;

import "./Steam.sol";
import "./ERC20.sol";

interface IUNIv2 {
    function sync() external;
}

contract UpSwing is ERC20 {

    using SafeMath for uint256;

    address private UNIv2;
    address private Treasury;
    
    mapping(address => bool) public allowed;
    mapping(address => bool) public pauser;
    modifier onlyAllowed() {
        require(allowed[_msgSender()], "onlyAllowed");
        _;
    }


    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _initialSupply;
    uint256 private _UPSBurned = 0;
    
    uint8 public leverage;
    bool public paused = true;
    mapping(address => uint256) sellPressure;
    mapping(address => uint256) steamToGenerate;
    mapping(address => uint256) txCount;
    
    address _STEAM;

    event BurnedFromLiquidityPool(address burnerAddress, uint amount);
    event SteamGenerated(address steamRecipientddress, uint amount);

    constructor(uint256 UPS_totalSupply) public {
        _name = "UpSwing"; 
        _symbol = "UPStkn";
        _decimals = 18;
        _initialSupply = UPS_totalSupply.mul(1e18);
        ERC20._mint(_msgSender(), UPS_totalSupply.mul(1e18)); //uses "normal" numbers

        leverage = 90;
        Treasury = msg.sender;
        
        _STEAM = address(new Steam(UPS_totalSupply)); //creates steam token
        allowed[_msgSender()] = true;
        pauser[_msgSender()] = true;
    }
    
    modifier onlyPauser() {
        require(pauser[_msgSender()], "onlyPauser");
        _;
    }

    
    function setPauser(address _address, bool _bool) public onlyAllowed {
        pauser[_address] = _bool;
    }
    
    function togglePause(bool _bool) public onlyPauser {
        paused = _bool;
    }
    
    
    modifier canSteam(address _address){
        require(steamToGenerate[_address] > 0, "no Steam to generate");
        _;
    }
    
    /*  //STEAM function called below:
    
        function generateSteam(address account, uint256 amount) external onlyAllowed {
        require((_totalSupply + amount) < _maxSupply, "STEAM token: cannot generate more steam than the max supply");
        ERC20._mint(account, amount);
        _steamMinted = _steamMinted.add(amount);
    }
    */
    
    function _generateSteamFromUPSBurn(address _address) internal canSteam(_address){
        uint256 _steam = steamToGenerate[_address];
        steamToGenerate[_address] = 0;
        Steam(_STEAM).generateSteam(_address, _steam);
    }   
    
    function addToSteam(address _address, uint256 _amount) internal {
        steamToGenerate[_address] = steamToGenerate[_address].add(_amount);
    }  
    
    function amountPressure(uint256 amount) internal view returns(uint256){ 
        uint256 UNI_SupplyRatio = (getUNIV2Liq().mul(1e18)).div(totalSupply());
        UNI_SupplyRatio = UNI_SupplyRatio.mul(leverage).div(100);

        return amount.mul(UNI_SupplyRatio).div(1e18);
    }
    
    function setAllowed(address _address, bool _bool) public onlyAllowed {
        allowed[_address] = _bool;
    }

    function setUNIv2(address _address) public onlyAllowed {
        UNIv2 = _address;
    }
    
    function setTreasury(address _address) public onlyAllowed {
        Treasury = _address;
    }

    function setLeverage(uint8 _leverage) public onlyAllowed {
        require(_leverage <= 100 && _leverage >= 0);
        leverage = _leverage;
    }

    function myPressure(address _address) public view returns(uint256){
        return amountPressure(sellPressure[_address]);
    }
    
    function releasePressure(address _address) internal {
        uint256 amount = myPressure(_address);
        
        if(amount < balanceOf(UNIv2)) {
            require(_totalSupply.sub(amount) >= _initialSupply.div(1000), "There is less than 0.1% of the Maximum Supply remaining, unfortunately, kabooming is over");
            
            sellPressure[_address] = 0;
            addToSteam(_address, amount);
            
            ERC20._burn(UNIv2, amount);

            _UPSBurned = _UPSBurned.add(amount);
            emit BurnedFromLiquidityPool(_address, amount);
            
            _generateSteamFromUPSBurn(_address);
            emit SteamGenerated(_address, amount);
            
            txCount[_address] = 0;
        } else if (amount > 0) {
            sellPressure[_address] = sellPressure[_address].div(2);
        }
        
        
       IUNIv2(UNIv2).sync();
    }
    
    function UPSMath(uint256 n) internal pure returns(uint256){
        uint _t = n*n + 1;
        _t =  1e10/(_t);
        return (92*_t)/100;
        
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal override{
        require(!paused || pauser[sender], "UPStkn: You must wait until UniSwap listing to transfer");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
    
        ERC20._balances[sender] = ERC20._balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        ERC20._balances[recipient] = ERC20._balances[recipient].add(amount);
    
            if(recipient == UNIv2){ 
                txCount[sender] = txCount[sender]+1;
                amount = amount.mul(UPSMath(txCount[sender])).div(1e10);
                sellPressure[sender] = sellPressure[sender].add(amount);
            }
    
            if(sender == recipient && amount == 0){releasePressure(sender);}
    
        emit Transfer(sender, recipient, amount);
    }
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }
    
    function mySteam(address _address) public view returns(uint256){
        return steamToGenerate[_address];
    }
    
    function getUNIV2Address() public view returns (address) {
        return UNIv2;
    }
    
    function getUNIV2Liq() public view returns (uint256) {
        return balanceOf(UNIv2);
    }
    
    function getUPSTotalSupply() public view returns(uint256){
        return _totalSupply;
    }
    
    function getUPSBurned() public view returns(uint256){
        return _UPSBurned;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return ERC20._totalSupply;
    }

}
