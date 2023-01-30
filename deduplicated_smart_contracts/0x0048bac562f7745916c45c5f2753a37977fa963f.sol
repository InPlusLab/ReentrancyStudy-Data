/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

pragma solidity ^0.5.17;

contract Context
{
    constructor() internal {}

    function _msgSender() internal view returns (address payable)
	{
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory)
	{
        this;
        return msg.data;
    }
}

contract Ownable is Context
{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal
	{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address)
	{
        return _owner;
    }

    modifier onlyOwner()
	{
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool)
	{
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner
	{
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner
	{
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal
	{
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// --------------------------------
// Safe Math Library
// Added ceiling function
// --------------------------------
library SafeMath
{
    function add(uint256 a, uint256 b) internal pure returns (uint256)
	{
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
	{
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
	{
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

	// Gas Optimization
    function mul(uint256 a, uint256 b) internal pure returns (uint256)
	{
        if (a == 0)
		{
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
	{
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
	{
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256)
	{
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
	{
        require(b != 0, errorMessage);
        return a % b;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256)
	{
		uint256 c = add(a,m);
		uint256 d = sub(c,1);
		return mul(div(d,m),m);
	}
}

interface IERC20
{
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Detailed is IERC20
{
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals) public
	{
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory)
	{
        return _name;
    }

    function symbol() public view returns (string memory)
	{
        return _symbol;
    }

    function decimals() public view returns (uint8)
	{
        return _decimals;
    }
}

// --------------------------------
// Ensure enough gas
// --------------------------------
contract GasPump
{
    bytes32 private stub;
    uint256 private constant target = 10000;

    modifier requestGas()
	{
        if (tx.gasprice == 0 || gasleft() > block.gaslimit)
		{
            _;
            uint256 startgas = gasleft();
            while (startgas - gasleft() < target)
			{
                // Burn gas
                stub = keccak256(abi.encodePacked(stub));
            }
        }

		else
		{
            _;
        }
    }
}

contract AntiBaseProtocol is Context, Ownable, ERC20Detailed, GasPump
{
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public whitelistFrom;
    mapping(address => bool) public whitelistTo;

    // Reward Wallet
	address rewardFeeWallet = 0x75340900942a7309934B7182b6c6643E954d890a;
	// Deployer Wallet
	address deployerWallet = 0x737d33D9FE00576b6b9609a2D5Ee81bA55aa766E;

	// Token Details
	string constant tokenName = "https://t.me/antibaseprotocol";
	string constant tokenSymbol = "ABASE";
	uint8  constant tokenDecimals = 18;
    uint256 private _totalSupply = 31.25 * (10 ** 18);
	uint256 public basePercent = 100;

    bytes32 private lastHash;

	constructor() public ERC20Detailed(tokenName, tokenSymbol, tokenDecimals)
	{
		_mint(msg.sender, _totalSupply);
	}

    function totalSupply() public view returns (uint256)
	{
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256)
	{
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool)
	{
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool)
	{
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient,uint256 amount) public returns (bool)
    {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(_msgSender(), spender,
		_allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function burn(uint256 amount) public
	{
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public
	{
        _burnFrom(account, amount);
    }

	// --------------------------------
	// 15% Burn Fee
	// --------------------------------
	function findBurnFee(uint256 value) public view returns (uint256)
	{
		uint256 roundValue = value.ceil(basePercent);
		uint256 onePercent = roundValue.mul(basePercent).div(666);
		return onePercent;
	}

	// --------------------------------
	// 5% Community Rewards Fee
	// --------------------------------
    function findRewardFee(uint256 value) public view returns (uint256)
    {
        uint256 roundValue = value.ceil(basePercent);
        uint256 onePercent = roundValue.mul(basePercent).div(2000);
        return onePercent;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal requestGas
	{
        require(amount <= _balances[sender]);
        require(recipient != address(0), "ERC20: transfer to the zero address");

		// Deployer Transaction (So that transactions made my deployer don't get affected
		// Reward Wallet Transaction (So that transactions made by reward wallet when distributing rewards dont get affected)
		if (msg.sender == deployerWallet || msg.sender == rewardFeeWallet)
        {
            // Subtract from sender balance
            _balances[sender] = _balances[sender].sub(amount);

            // Add to recipient balance
			_balances[recipient] = _balances[recipient].add(amount);

            emit Transfer(sender, recipient, amount);
        }

		else
	    {
		    // Subtract from sender balance
			_balances[sender] = _balances[sender].sub(amount);

			// Get 15% of transacted tokens
			uint256 tokensToBurn = findBurnFee(amount);

			// Get 5% of transacted tokens
			uint256 tokensToReward = findRewardFee(amount);

			// Transfer amount - (burn tokens) - (reward tokens)
			uint256 tokensToTransfer = amount.sub(tokensToBurn).sub(tokensToReward);

			// Add to reward fee wallet
			_balances[rewardFeeWallet] = _balances[rewardFeeWallet].add(tokensToReward);

			// Add to recipient balance
			_balances[recipient] = _balances[recipient].add(tokensToTransfer);

            // Subtract burned amount from supply
			_totalSupply = _totalSupply.sub(tokensToBurn);

			// Transaction Documentation Log
            emit Transfer(sender, recipient, tokensToTransfer);
			emit Transfer(sender, rewardFeeWallet, tokensToReward);
			emit Transfer(sender, address(0), tokensToBurn); 
	    }
    }
	
    function _mint(address account, uint256 amount) internal
	{
		require(amount != 0);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal
	{
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal
    {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal
	{
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}