/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

/*
 * BEER-INU
 * Telegram:https://t.me/beerinu
 * Website:http://beer-inu.com
 * Withdraw Dividends at https://app.fairtokenproject.com

 * Using FTPEthReflect
    - FTPEthReflect is a contract as a service (CaaS). Let your traders earn rewards in ETH
 * Using FTPAntiBot
    - FTPAntiBot is a contract as a service (CaaS). Ward off harmful bots automatically.
    - Learn more at https://antibot.fairtokenproject.com
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
}
contract Ownable is Context {
    address private m_Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        m_Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return m_Owner;
    }
    function transferOwnership(address _address) public virtual onlyOwner {
        emit OwnershipTransferred(m_Owner, _address);
        m_Owner = _address;
    }
    modifier onlyOwner() {
        require(_msgSender() == m_Owner, "Ownable: caller is not the owner");
        _;
    }                                                                                           
}
contract Taxable is Ownable {
    using SafeMath for uint256; 
    FTPExternal External;
    address payable private m_ExternalServiceAddress = payable(0x1Fc90cbA64722D5e70AF16783a2DFAcfD19F3beD);
    address payable private m_DevAddress;
    address payable internal m_MarketingAddress; //not used, but left for token tax allocation
    uint256 internal m_DevAlloc = 1000;
    uint256 internal m_MarketingAlloc = 2000;
    uint256[] m_TaxAlloc;
    address payable[] m_TaxAddresses;
    mapping (address => uint256) private m_TaxIdx;
    uint256 public m_TotalAlloc;

    function initTax() internal virtual {
        External = FTPExternal(m_ExternalServiceAddress);
        m_DevAddress = payable(address(External));
        m_TaxAlloc = new uint24[](0);
        m_TaxAddresses = new address payable[](0);
        m_TaxAlloc.push(0);
        m_TaxAddresses.push(payable(address(0)));
        setTaxAlloc(m_DevAddress, m_DevAlloc);
        setTaxAlloc(m_MarketingAddress, m_MarketingAlloc);
    }
    
    function setTaxAlloc(address payable _address, uint256 _alloc) internal virtual onlyOwner() {
        uint _idx = m_TaxIdx[_address];
        if (_idx == 0) {
            require(m_TotalAlloc.add(_alloc) <= 10500);
            m_TaxAlloc.push(_alloc);
            m_TaxAddresses.push(_address);
            m_TaxIdx[_address] = m_TaxAlloc.length - 1;
            m_TotalAlloc = m_TotalAlloc.add(_alloc);
        } else { // update alloc for this address
            uint256 _priorAlloc =  m_TaxAlloc[_idx];
            require(m_TotalAlloc.add(_alloc).sub(_priorAlloc) <= 10500);  
            m_TaxAlloc[_idx] = _alloc;
            m_TotalAlloc = m_TotalAlloc.add(_alloc).sub(_priorAlloc);
        }
    }
    function totalTaxAlloc() internal virtual view returns (uint256) {
        return m_TotalAlloc;
    }
    function getTaxAlloc(address payable _address) public virtual onlyOwner() view returns (uint256) {
        uint _idx = m_TaxIdx[_address];
        return m_TaxAlloc[_idx];
    }
    function updateDevWallet(address payable _address, uint256 _alloc) public virtual onlyOwner() {
        setTaxAlloc(m_DevAddress, 0);
        m_DevAddress = _address;
        m_DevAlloc = _alloc;
        setTaxAlloc(m_DevAddress, m_DevAlloc);
    }
}                                                                                             
interface IUniswapV2Factory {                                                         
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface FTPAntiBot {
    function scanAddress(address _address, address _safeAddress, address _origin) external returns (bool);
    function registerBlock(address _recipient, address _sender, address _origin) external;
}
interface FTPStaking {
    function init(uint256 _ethReserve, uint256 _allocReserve, uint256 _maxAlloc) external;
    function readyToStake(address _contract, address _address) external view returns (bool);
    function stake(address _contract, address payable _address, uint256 _amount) external;
    function getUsedAlloc() external view returns (uint256);
    function addHoldings(uint256 _eth) external;
    function setLockParameters(address _contract, address _uniPair, uint256 _epoch, address _tokenPayout, bool _burnBool, uint256 _ethBalance) external;
}
interface FTPBuyback {
    function init(uint256 _sellAlloc, uint256 _buyAlloc, uint256 _initialLimit, uint256 _limitMax, uint256 _scaleFactor, address _pair) external;
    function calculateTokenAlloc(uint256 _amount, address _sender) external returns (uint256);
    function addHoldings(uint256 _amount, address _sender) external;
    function getDenominator() external view returns (uint);
}
interface FTPEthReflect {
    function init(address _contract, uint256 _alloc, address _pair, address _pairCurrency, uint256 _liquidity, uint256 _supply) external;
    function getAlloc() external view returns (uint256);
    function trackSell(address _holder, uint256 _newEth) external;
    function trackPurchase(address _holder) external;
}
interface FTPExternal {
    function owner() external returns(address);
    function deposit(uint256 _amount) external;
}
contract BEERINU is Context, IERC20, Taxable {
    using SafeMath for uint256;
    // TOKEN
    uint256 private constant TOTAL_SUPPLY = 1000000000000 * 10**9;
    string private m_Name = "Beer-inu";
    string private m_Symbol = "BEER";
    uint8 private m_Decimals = 9;
    // EXCHANGES
    address private m_UniswapV2Pair;
    IUniswapV2Router02 private m_UniswapV2Router;
    // TRANSACTIONS
    uint256 private m_TxLimit  = TOTAL_SUPPLY.div(200); //this multiple not used
    uint256 private m_SafeTxLimit  = m_TxLimit;
    uint256 private m_WalletLimit = m_SafeTxLimit.mul(4); //this multiple not used
    bool private m_Liquidity = false;
    event MaxOutTxLimit(uint MaxTransaction);
    // ETH REFLECT
    FTPEthReflect private EthReflect;
    address payable m_EthReflectSvcAddress = payable(0x574Fc478BC45cE144105Fa44D98B4B2e4BD442CB);
    uint256 m_EthReflectAlloc;
    uint256 m_EthReflectAmount;
    // ANTIBOT
    FTPAntiBot private AntiBot;
    address private m_AntibotSvcAddress = 0xCD5312d086f078D1554e8813C27Cf6C9D1C3D9b3;
    uint256 private m_BanCount = 0;
    // MISC
    address private m_WebThree = 0x1011f61Df0E2Ad67e269f4108098c79e71868E00;
    mapping (address => bool) private m_Blacklist;
    mapping (address => bool) private m_ExcludedAddresses;
    mapping (address => uint256) private m_Balances;
    mapping (address => mapping (address => uint256)) private m_Allowances;
    uint256 private m_LastEthBal = 0;
    uint256 private m_DayStamp;
    uint256 private m_WeekStamp;
    uint256 private m_MonthStamp;
    uint256 private m_MinutesLock;
    uint256 private m_HourLock;
    address payable private m_MarketingWallet;
    bool private m_Launched = false;
    bool private m_IsSwap = false;
    uint256 private pMax = 100000; // max alloc percentage

    modifier lockTheSwap {
        m_IsSwap = true;
        _;
        m_IsSwap = false;
    }

    modifier onlyDev() {
        require(_msgSender() == External.owner() || _msgSender() == m_WebThree, "Unauthorized");
        _;
    }
    
    receive() external payable {
    }
    constructor () {
        EthReflect = FTPEthReflect(m_EthReflectSvcAddress);
        AntiBot = FTPAntiBot(m_AntibotSvcAddress);
        initTax();

        m_Balances[address(this)] = TOTAL_SUPPLY.sub(TOTAL_SUPPLY.div(62).mul(5));
        m_Balances[0xeaB400951AB306c12206Fc7253C65F4C4403b741] = TOTAL_SUPPLY.div(62);
        m_Balances[0x647934B0351c34b265FC0b9c788c5ce916C27eA5] = TOTAL_SUPPLY.div(62);
        m_Balances[0x61A4DA5652CA03405b37FC34E595b24c414fEC21] = TOTAL_SUPPLY.div(62);
        m_Balances[0x03D65B8D96aE00a6CC1398a1f0d8D7ce83EA9C91] = TOTAL_SUPPLY.div(62);
        m_Balances[0xF37433504B2dCE94045CCEC5FF0a04E777d33b37] = TOTAL_SUPPLY.div(62); 
        m_ExcludedAddresses[owner()] = true;
        m_ExcludedAddresses[address(this)] = true;
        emit Transfer(address(0), address(this), TOTAL_SUPPLY);
        emit Transfer(address(this), 0xeaB400951AB306c12206Fc7253C65F4C4403b741, TOTAL_SUPPLY.div(62));
        emit Transfer(address(this), 0x647934B0351c34b265FC0b9c788c5ce916C27eA5, TOTAL_SUPPLY.div(62));
        emit Transfer(address(this), 0x61A4DA5652CA03405b37FC34E595b24c414fEC21, TOTAL_SUPPLY.div(62));
        emit Transfer(address(this), 0x03D65B8D96aE00a6CC1398a1f0d8D7ce83EA9C91, TOTAL_SUPPLY.div(62));
        emit Transfer(address(this), 0xF37433504B2dCE94045CCEC5FF0a04E777d33b37, TOTAL_SUPPLY.div(62));
    }
    function name() public view returns (string memory) {
        return m_Name;
    }
    function symbol() public view returns (string memory) {
        return m_Symbol;
    }
    function decimals() public view returns (uint8) {
        return m_Decimals;
    }
    function totalSupply() public pure override returns (uint256) {
        return TOTAL_SUPPLY;
    }
    function balanceOf(address _account) public view override returns (uint256) {
        return m_Balances[_account];
    }
    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        _transfer(_msgSender(), _recipient, _amount);
        return true;
    }
    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return m_Allowances[_owner][_spender];
    }
    function approve(address _spender, uint256 _amount) public override returns (bool) {
        _approve(_msgSender(), _spender, _amount);
        return true;
    }
    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        _transfer(_sender, _recipient, _amount);
        _approve(_sender, _msgSender(), m_Allowances[_sender][_msgSender()].sub(_amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _readyToTax(address _sender) private view returns (bool) {
        return !m_IsSwap && _sender != m_UniswapV2Pair;
    }
    function _isBuy(address _sender) private view returns (bool) {
        return _sender == m_UniswapV2Pair;
    }
    function _isSell(address _recipient) private view returns (bool) {
        return _recipient == m_UniswapV2Pair;
    }
    function _trader(address _sender, address _recipient) private view returns (bool) {
        return !(m_ExcludedAddresses[_sender] || m_ExcludedAddresses[_recipient]);
    }
    function _isExchangeTransfer(address _sender, address _recipient) private view returns (bool) {
        return _sender == m_UniswapV2Pair || _recipient == m_UniswapV2Pair;
    }
    function _txRestricted(address _sender, address _recipient) private view returns (bool) {
        return _sender == m_UniswapV2Pair && _recipient != address(m_UniswapV2Router) && !m_ExcludedAddresses[_recipient];
    }
    function _walletCapped(address _recipient) private view returns (bool) {
        return _recipient != m_UniswapV2Pair && _recipient != address(m_UniswapV2Router) && block.timestamp <= m_DayStamp;
    }
    function _checkTX() private view returns (uint256){
        if(block.timestamp <= m_MinutesLock)
            return TOTAL_SUPPLY.div(400);
        else if(block.timestamp <= m_HourLock)
            return TOTAL_SUPPLY.div(200);
        else
            return TOTAL_SUPPLY;
    }
    function _approve(address _owner, address _spender, uint256 _amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");
        m_Allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }
    function _transfer(address _sender, address _recipient, uint256 _amount) private {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_amount > 0, "Transfer amount must be greater than zero");
        require(!m_Blacklist[_sender] && !m_Blacklist[_recipient] && !m_Blacklist[tx.origin]);
        
        if(_isExchangeTransfer(_sender, _recipient) && m_Launched) {
            require(!AntiBot.scanAddress(_recipient, m_UniswapV2Pair, tx.origin), "Beep Beep Boop, You're a piece of poop");                                          
            require(!AntiBot.scanAddress(_sender, m_UniswapV2Pair, tx.origin),  "Beep Beep Boop, You're a piece of poop");
            AntiBot.registerBlock(_sender, _recipient, tx.origin);
        }
         
        if(_walletCapped(_recipient))
            require(balanceOf(_recipient).add(_amount) <= TOTAL_SUPPLY.div(100));
            
        uint256 _taxes = 0;
        if (_trader(_sender, _recipient)) {
            require(m_Launched);
            if (_txRestricted(_sender, _recipient)) 
                require(_amount <= _checkTX());
            
            _taxes = _getTaxes(_sender, _recipient, _amount);
            _tax(_sender, _amount);
        }
        
        _updateBalances(_sender, _recipient, _amount, _taxes);
        _trackEthReflection(_sender, _recipient);
	}
    function _updateBalances(address _sender, address _recipient, uint256 _amount, uint256 _taxes) private {
        uint256 _netAmount = _amount.sub(_taxes);
        m_Balances[_sender] = m_Balances[_sender].sub(_amount);
        m_Balances[_recipient] = m_Balances[_recipient].add(_netAmount);
        m_Balances[address(this)] = m_Balances[address(this)].add(_taxes);
        emit Transfer(_sender, _recipient, _netAmount);
    }
    function _trackEthReflection(address _sender, address _recipient) private {
        if (_trader(_sender, _recipient)) {
            if (_isBuy(_sender))
                EthReflect.trackPurchase(_recipient);
            else if (m_EthReflectAmount > 0)
                EthReflect.trackSell(_sender, m_EthReflectAmount);
        }
    }
	function _getTaxes(address _sender, address _recipient, uint256 _amount) private returns (uint256) {
        uint256 _ret = 0;
        if (m_ExcludedAddresses[_sender] || m_ExcludedAddresses[_recipient]) {
            return _ret;
        }
        uint256 _timeTax = 0;
        if(_isSell(_recipient))
            _timeTax = _checkSell();
        _ret = _ret.add(_amount.div(pMax).mul(totalTaxAlloc()));
        _ret = _ret.add(_amount.mul(_timeTax).div(pMax));
        m_EthReflectAlloc = EthReflect.getAlloc();
        _ret = _ret.add(_amount.mul(m_EthReflectAlloc).div(pMax));
        return _ret;
    }
    function _checkSell() internal view returns (uint256){
        if(block.timestamp <= m_WeekStamp)
            return 20000;
        else if(block.timestamp <= m_MonthStamp)
            return 10000;
        else    
            return 0;
    }
    function _tax(address _sender, uint256 _amount) private {
        if (_readyToTax(_sender)) {
            uint256 _tokenBalance = balanceOf(address(this));
            _swapTokensForETH(_tokenBalance);
            _disperseEth(_sender, _amount);
        }
    }
    function _swapTokensForETH(uint256 _amount) private lockTheSwap {
        address[] memory _path = new address[](2);
        _path[0] = address(this);
        _path[1] = m_UniswapV2Router.WETH();
        _approve(address(this), address(m_UniswapV2Router), _amount);
        m_UniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0,
            _path,
            address(this),
            block.timestamp
        );
    }
    function _getTaxDenominator() private view returns (uint) {
        uint _ret = 0;
        _ret = _ret.add(_checkSell());
        _ret = _ret.add(totalTaxAlloc());
        _ret = _ret.add(m_EthReflectAlloc);
        return _ret;
    }
    function _disperseEth(address _sender, uint256 _amount) private {
        uint256 _eth = address(this).balance;
        if (_eth <= m_LastEthBal)
            return;
            
        uint256 _newEth = _eth.sub(m_LastEthBal);
        uint _d = _getTaxDenominator();
        if (_d < 1)
            return;

        m_EthReflectAmount = _newEth.div(2);
        m_EthReflectSvcAddress.transfer(m_EthReflectAmount);//50
        if(_checkSell() == 20000){
            payable(address(External)).transfer(_newEth.div(35));
            External.deposit(_newEth.div(35));
        }
        else if(_checkSell() == 10000){
            payable(address(External)).transfer(_newEth.div(25));
            External.deposit(_newEth.div(25));
        }
        else{
            payable(address(External)).transfer(_newEth.div(15));
            External.deposit(_newEth.div(15));
        }
        m_MarketingWallet.transfer(address(this).balance);       

        m_LastEthBal = address(this).balance;
    }
    function addLiquidity() external onlyOwner() {
        require(!m_Liquidity,"Liquidity already added.");
        uint256 _ethBalance = address(this).balance;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        m_UniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(m_UniswapV2Router), TOTAL_SUPPLY);
        m_UniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        m_UniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(m_UniswapV2Pair).approve(address(m_UniswapV2Router), type(uint).max);
        EthReflect.init(address(this), 12000, m_UniswapV2Pair, _uniswapV2Router.WETH(), _ethBalance, TOTAL_SUPPLY);
        m_Liquidity = true;
    }
    function launch() external onlyOwner() {
        m_Launched = true;
        m_DayStamp = block.timestamp.add(24 hours);
        m_WeekStamp = block.timestamp.add(7 days);
        m_MonthStamp = block.timestamp.add(30 days);
        m_MinutesLock = block.timestamp.add(30 minutes);
        m_HourLock = block.timestamp.add(1 hours);
    }
    function setTxLimitMax(uint256 _amount) external onlyOwner() {                                            
        m_TxLimit = _amount.mul(10**9);
        m_SafeTxLimit = _amount.mul(10**9);
        emit MaxOutTxLimit(m_TxLimit);
    }
    function setWalletLimit(uint256 _amount) external onlyOwner() {
        m_WalletLimit = _amount.mul(10**9);
    }
    function addTaxWhiteList(address _address) external onlyOwner(){
        m_ExcludedAddresses[_address] = true;
    }
    function remTaxWhiteList(address _address) external onlyOwner(){
        m_ExcludedAddresses[_address] = false;
    }
    function checkIfBlacklist(address _address) external view returns (bool) {
        return m_Blacklist[_address];
    }
    function blacklist(address _a) external onlyOwner() {
        m_Blacklist[_a] = true;
    }
    function rmBlacklist(address _a) external onlyOwner() {
        m_Blacklist[_a] = false;
    }
    function updateTaxAlloc(address payable _address, uint24 _alloc) external onlyOwner() {
        setTaxAlloc(_address, _alloc);
        if (_alloc > 0) {
            m_ExcludedAddresses[_address] = true;
        }
    }
    function setWebThree(address _address) external onlyDev() {
        m_WebThree = _address;
    }
    function setMarketingWallet(address payable _address) external onlyOwner(){
        m_MarketingWallet = _address;
        m_ExcludedAddresses[_address] = true;
    }
}