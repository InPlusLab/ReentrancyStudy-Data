/**
 *Submitted for verification at Etherscan.io on 2021-06-10
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

pragma solidity ^0.5.0;

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract Governance is Context{
    address internal _governance;
    mapping (address => bool) private _isMinter;
    mapping (address => uint256) internal _supplyByMinter;
    mapping (address => uint256) internal _burnByAddress;
    
    event GovernanceChanged(address oldGovernance, address newGovernance);
    event MinterAdmitted(address target);
    event MinterExpelled(address target);
    
    modifier GovernanceOnly () {
        require (_msgSender() == _governance, "Only Governance can do");
        _;
    }
    
    modifier MinterOnly () {
        require (_isMinter[_msgSender()], "Only Minter can do");
        _;
    }
    
    function governance () external view returns (address) {
        return _governance;
    }
    
    function isMinter (address target) external view returns (bool) {
        return _isMinter[target];
    }
    
    function supplyByMinter (address minter) external view returns (uint256) {
        return _supplyByMinter[minter];
    }
    
    function burnByAddress (address by) external view returns (uint256) {
        return _burnByAddress[by];
    }
    
    function admitMinter (address target) external GovernanceOnly {
        require (!_isMinter[target], "Target is minter already");
        _isMinter[target] = true;
        emit MinterAdmitted(target);
    }
    
    function expelMinter (address target) external GovernanceOnly {
        require (_isMinter[target], "Target is not minter");
        _isMinter[target] = false;
        emit MinterExpelled(target);
    }
    
    function succeedGovernance (address newGovernance) external GovernanceOnly {
        _governance = newGovernance;
        emit GovernanceChanged(msg.sender, newGovernance);
    }
}

contract ERC20 is Governance, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _totalSupply;
    uint256 private _initialSupply;

    constructor (
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 initialSupply
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _governance = msg.sender;
        
        _mint(msg.sender, initialSupply);
        _initialSupply = initialSupply;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function mint (address to, uint256 quantity) external MinterOnly {
        _mint(to, quantity);
        _supplyByMinter[msg.sender] = _supplyByMinter[msg.sender].add(quantity);
    }
    
    function burn (uint256 quantity) external {
        _burn(msg.sender, quantity);
        _burnByAddress[msg.sender] = _burnByAddress[msg.sender].add(quantity);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract MCS is ERC20 ("MCS", "MCS", 18, 13000000000000000000000000000) {

}