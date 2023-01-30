/**
 *Submitted for verification at Etherscan.io on 2020-07-21
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

// -- https://incomestaking.net
// -- https://github.com/BasicIncomeStaking
// -- Discord: https://discord.gg/KYndmrf

// -- BIS Smart Contract
// -- 1)Each transaction may trigger 1 of 3 possible functions of the contract.
// -- 	1-a) Transactions have a 40% chance of burning 5%. Burned tokens are deducted from the total supply.
// -- 	1-b) Transactions have a 20% chance of minting 2.5%. Minted tokens are added to the total supply.	
// -- 	1-c) Transactions have a 40% chance of not being affected by the contract. 

// -- 2) BIS token can be staked. Stakers have 2 options to generate earnings through our staking platfrom.
// --   2-a) 10% of the total unstaked amount is distributed among the remaining stakers.
// --   2-b) 0.5% of every transaction is cut as the means of staker pay-out. Each collected cut is shared
// --   among all the stakers proportionally.

// -- 3) BIS' premise is to provide minimum basic income for its stakers no matter what. For the purpose, we
// -- 	 employ a Safe Staking Wallet as a reserve for stakers. In case where the network isn't able to generate 
// -- 	 promised minimum income for the stakers, Safe Staking Wallet is used to pay the remaining stake rewards.

// -- i) There is a minimum 1000 BIS staking threshold. 
// -- ii) Daily minimum staking reward threshold is 0.1% of the total amount of user's staked BIS Tokens. If collected BIS tokens 
// -- aren't able to provide enough BIS stake reward for the stakers, Safe Staking Wallet will be used to ensure that each 
// -- stakers recieves at least 0.1% of their total staked BIS Tokens.

pragma solidity ^0.5.17;

contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}

contract GasPump {
    bytes32 private stub;
    uint256 private constant target = 10000;

    modifier requestGas() {
        if (tx.gasprice == 0 || gasleft() > block.gaslimit) {
            _;
            uint256 startgas = gasleft();
            while (startgas - gasleft() < target) {
                // Burn gas
                stub = keccak256(abi.encodePacked(stub));
            }
        } else {
            _;
        }
    }
}

contract BISToken is Context, Ownable, ERC20Detailed, GasPump {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public whitelistFrom;
    mapping(address => bool) public whitelistTo;

    uint256 private _totalSupply;
    bytes32 private lastHash;
    uint256 constant private Scalar = 2**64;
    uint256 constant private Tx_cut = 1; // Corresponds to 0.5% transaction cut for stakers
    uint256 constant private Min_Allowed_Stake = 1e21; // Min 1000 BIS Token is needed for staking
    
	struct User {
		uint256 staked;
		int256 scaledPayout;
	}

	struct Info {
		uint256 totalStaked;
		uint256 scaledPayoutPerToken;
	}
	Info private info;
    
    event WhitelistFrom(address _addr, bool _whitelisted);
    event WhitelistTo(address _addr, bool _whitelisted);
    event Shot(
        address indexed sender,
        address indexed recipient,
        uint256 value
    );
    event Survived(
        address indexed sender,
        address indexed recipient,
        uint256 value
    );

    constructor() public ERC20Detailed("Basic Income Staking", "BIS", 18) {
        _mint(_msgSender(), 15000000 * 10**18);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
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

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }

    function setWhitelistedTo(address _addr, bool _whitelisted)
        external
        onlyOwner
    {
        emit WhitelistTo(_addr, _whitelisted);
        whitelistTo[_addr] = _whitelisted;
    }

    function setWhitelistedFrom(address _addr, bool _whitelisted)
        external
        onlyOwner
    {
        emit WhitelistFrom(_addr, _whitelisted);
        whitelistFrom[_addr] = _whitelisted;
    }

    function _isWhitelisted(address _from, address _to)
        internal
        view
        returns (bool)
    {
        return whitelistFrom[_from] || whitelistTo[_to];
    }
    
    function _dice_burn() internal returns (uint256) {
        bytes32 result = keccak256(
            abi.encodePacked(block.number, lastHash, gasleft())
        );
        lastHash = result;
        return uint256(result) % 2 == 1 ? 1 : 0;
    }
    
    function _dice_mint() internal returns (uint256) {
        bytes32 result1 = keccak256(
            abi.encodePacked(block.number, lastHash, gasleft())
        );
        lastHash = result1;
        return uint256(result1) % 4 == 2 ? 1 : 0;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal requestGas {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (!_isWhitelisted(sender, recipient) && _dice_burn() == 1) {
            //Burn 5% of the transaction amount and supply
            _totalSupply = _totalSupply.sub((amount)/20);
            emit Shot(sender, recipient, (amount)/20);
            emit Transfer(sender, address(0), (amount)/20);
            //Reduce the burned amount from recipient
            _balances[recipient] = _balances[recipient].add(amount - (amount)/20);
            emit Survived(sender, recipient, (amount - (amount/20)));
            emit Transfer(sender, recipient, (amount - (amount/20)));
            
        } else if (!_isWhitelisted(sender, recipient) && _dice_mint() == 1 && _dice_burn() == 0) {
            //Mint 2.5% of the transaction amount and add to the supply
            _totalSupply = _totalSupply.add(5*(amount/200));
            //Add the minted amount to recipient
            _balances[recipient] = _balances[recipient].add(amount + (5*(amount/200)));
            emit Survived(sender, recipient, (amount + 5*(amount/200)));
            emit Transfer(sender, recipient, (amount + 5*(amount/200)));
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
            emit Survived(sender, recipient, amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "ERC20: burn amount exceeds allowance"
            )
        );
    }
}