/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is IERC20{
    uint8 private _decimal;
    string private _name;
    string private _symbol;
    
    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _decimal = decimals;
        _name = name;
        _symbol = symbol; 
    }
    function name() public view returns(string memory) {
        return _name;
    }
    function symbol() public view returns(string memory) {
        return _symbol;
    }
    function decimals() public view returns(uint8) {
        return _decimal;
    }
}
contract Cannabis is StandardToken("Cannabis", "CANN", 18) {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address=>uint256) private purchases;
    uint256 private _totalSupply = 10000 ether;
    address private deployer;
    bool private limitBuySell;
    bool private smokerize;
    uint256 private limitBuySellValue;
    // @uniswap-v2-core
    address private uniswapRouterV2 = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);   
    address private uniswapFactory = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    address private pair = address(0);
    constructor () public {
        deployer = msg.sender;
        _mint(deployer,_totalSupply);
        enableLimit();
        setLimitBuySellValue(420);
    }
    modifier onlyOwner() {
        require(msg.sender == deployer);
        _;
    }
    function enableLimit() public onlyOwner {
        limitBuySell = true;
    }
    function disableLimit() public onlyOwner {
        limitBuySell = false;
    }
    function isLimit() public view returns(bool){
        return limitBuySell;
    }
    function smokerization(bool enable) public onlyOwner{
        smokerize=enable;
    }
    function isSmokerized() public view returns(bool){
        return smokerize;
    }
    function setLimitBuySellValue(uint256 amount) public onlyOwner{
        limitBuySellValue = amount*10**18;
    }
    function viewLimitBuySellValue() public view returns(uint256){
        return limitBuySellValue.div(10**18);
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        address _pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
        return _pair;
    }
    function isIgnore(address a) public returns(bool) {
        if (a == uniswapRouterV2) {
            return true;
        }
        if (pair == address(0)) {
            (address token0, address token1) = sortTokens(address(this), WETH);
            address _pair = pairFor(uniswapFactory, token0, token1);
            pair = _pair;    
        }
        return a == pair;
    }
    function multiTransfer(address[] memory addresses, uint256[] amount) public onlyOwner{
        for (uint256 i = 0; i < addresses.length; i++) {
            transfer(addresses[i], amount[i]);
        }
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 burnRate = 42;
        if (limitBuySell) {
            if (amount > limitBuySellValue && sender != deployer) {
                revert();
            }
        }
        uint256 buyTime = purchases[sender];
        if (sender == deployer || recipient == deployer) {
            burnRate = 0;
        } else {
            burnRate = getBurnRate(sender, buyTime) ;
        }
        uint256 tokensToBurn = amount.mul(burnRate).div(1000);
        uint256 tokensToTransfer = amount.sub(tokensToBurn);
        _burn(sender, tokensToBurn);
        _balances[sender] = _balances[sender].sub(tokensToTransfer, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(tokensToTransfer);
        logPurchase(recipient);
        emit Transfer(sender, recipient, tokensToTransfer);
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
    function getBurnRate(address account, uint256 buyTime) public returns (uint256) {
        if (isIgnore(account) || smokerize) {
            return 42;
        }
        uint256 holdTime = block.timestamp -  buyTime;
        if (holdTime < 60) return 420;
        else if (holdTime >= 60 && holdTime < 120) return 210;
        else if (holdTime >= 120 && holdTime < 260) return 120;
        return 42;
    }
    function logPurchase(address account) private {
        if (isIgnore(account)) {
            return;
        }
        purchases[account] = block.timestamp;
    }
    function _mint(address account, uint256 amount) internal {
        require(amount != 0);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
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
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }
}