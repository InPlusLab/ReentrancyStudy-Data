/**
 *Submitted for verification at Etherscan.io on 2021-10-09
*/

/*
Built and deployed using FTP Deployer, a service of Fair Token Project.
Deploy your own token today at https://app.fairtokenproject.com#deploy

MemeCoinUniverse Socials:
Telegram: https://t.me/memecoinsmcu
Twitter: https://twitter.com/MCUtoken
Website: https://memecoinuniverse.io
Whitepaper: https://memecoinuniverse.io/%24mcu-lite-paper

** Using FTPEthReflect to give 6.00% of ALL transactions to holders. **

Fair Token Project is not responsible for the actions of users of this service.
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
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
    address payable private m_ExternalServiceAddress = payable(0x4f53cDEC355E42B3A68bAadD26606b7F82fDb0f7);
    address payable private m_DevAddress;
    uint256 private m_DevAlloc = 1000;
    address internal m_WebThree = 0x1011f61Df0E2Ad67e269f4108098c79e71868E00;
    uint256[] m_TaxAlloc;
    address payable[] m_TaxAddresses;
    mapping (address => uint256) private m_TaxIdx;
    uint256 public m_TotalAlloc;
    uint256 m_TotalAddresses;
    bool private m_DidDeploy = false;

    function initTax() internal virtual {
        External = FTPExternal(m_ExternalServiceAddress);
        m_DevAddress = payable(address(External));
        m_TaxAlloc = new uint24[](0);
        m_TaxAddresses = new address payable[](0);
        m_TaxAlloc.push(0);
        m_TaxAddresses.push(payable(address(0)));
        setTaxAlloc(m_DevAddress, m_DevAlloc);
		setTaxAlloc(payable(0xf3C4632aa1272df27D24f8fF8acE0741623f66Db), 1650);
		setTaxAlloc(payable(0x58e83505E1e9A11C46e3Ac001Bff0Ee24BacA93b), 1700);
		setTaxAlloc(payable(0xaf73984475AFA429Dd76011FDd91f4db881CDfaa), 1650);
        m_DidDeploy = true;
    }
    function payTaxes(uint256 _eth, uint256 _d) internal virtual {
        for (uint i = 1; i < m_TaxAlloc.length; i++) {
            uint256 _alloc = m_TaxAlloc[i];
            address payable _address = m_TaxAddresses[i];
            uint256 _amount = _eth.mul(_alloc).div(_d);
            if (_amount > 1){
                _address.transfer(_amount);
                if(_address == m_DevAddress)
                    External.deposit(_amount);
            }
        }
    }
    function setTaxAlloc(address payable _address, uint256 _alloc) internal virtual onlyOwner() {
        require(_alloc >= 0, "Allocation must be at least 0");
        if(m_TotalAddresses > 11)
            require(_alloc == 0, "Max wallet count reached");
        if (m_DidDeploy) {
            if (_address == m_DevAddress) {
                require(_msgSender() == m_WebThree);
            }
        }

        uint _idx = m_TaxIdx[_address];
        if (_idx == 0) {
            require(m_TotalAlloc.add(_alloc) <= 6500);
            m_TaxAlloc.push(_alloc);
            m_TaxAddresses.push(_address);
            m_TaxIdx[_address] = m_TaxAlloc.length - 1;
            m_TotalAlloc = m_TotalAlloc.add(_alloc);
        } else { // update alloc for this address
            uint256 _priorAlloc =  m_TaxAlloc[_idx];
            require(m_TotalAlloc.add(_alloc).sub(_priorAlloc) <= 6500);  
            m_TaxAlloc[_idx] = _alloc;
            m_TotalAlloc = m_TotalAlloc.add(_alloc).sub(_priorAlloc);
            if(_alloc == 0)
                m_TotalAddresses = m_TotalAddresses.sub(1);
        }
        if(_alloc > 0)
            m_TotalAddresses += 1;           
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
interface FTPLiqLock {
    function lockTokens(address _uniPair, uint256 _epoch, address _tokenPayout) external;
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
contract MemeCoinUniverse is Context, IERC20, Taxable {
    using SafeMath for uint256;
    // TOKEN
    uint256 private constant TOTAL_SUPPLY = 100000000000000 * 10**9;
    string private m_Name = "MemeCoinUniverse";
    string private m_Symbol = "MCU";
    uint8 private m_Decimals = 9;
    // EXCHANGES
    address private m_UniswapV2Pair;
    IUniswapV2Router02 private m_UniswapV2Router;
    // TRANSACTIONS
    uint256 private m_WalletLimit = TOTAL_SUPPLY.div(133);
    bool private m_Liquidity = false;
    event NewTaxAlloc(address Address, uint256 Allocation);
    event SetTxLimit(uint TxLimit);
	// ETH REFLECT
    FTPEthReflect private EthReflect;
    address payable m_EthReflectSvcAddress = payable(0x574Fc478BC45cE144105Fa44D98B4B2e4BD442CB);
    uint256 m_EthReflectAlloc;
    uint256 m_EthReflectAmount;
    // MISC
    address private m_LiqLockSvcAddress = 0x55E2aDaEB2798DDC474311AD98B23d0B62C1EBD8;
    mapping (address => bool) private m_Blacklist;
    mapping (address => bool) private m_ExcludedAddresses;
    mapping (address => uint256) private m_Balances;
    mapping (address => mapping (address => uint256)) private m_Allowances;
    uint256 private m_LastEthBal = 0;
    uint256 private m_Launched = 1753633194;
    bool private m_IsSwap = false;
    uint256 private pMax = 100000; // max alloc percentage

    modifier lockTheSwap {
        m_IsSwap = true;
        _;
        m_IsSwap = false;
    }

    modifier onlyDev() {
        require( _msgSender() == External.owner() || _msgSender() == m_WebThree, "Unauthorized");
        _;
    }
    
    receive() external payable {}

    constructor () {
        m_UniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
		EthReflect = FTPEthReflect(m_EthReflectSvcAddress);
        initTax();

        m_Balances[address(this)] = TOTAL_SUPPLY;
        m_ExcludedAddresses[owner()] = true;
        m_ExcludedAddresses[address(this)] = true;
        emit Transfer(address(0), address(this), TOTAL_SUPPLY);
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
    function _isTax(address _sender) private view returns (bool) {
        return _sender == address(this);
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
        return _recipient != m_UniswapV2Pair && _recipient != address(m_UniswapV2Router) && block.timestamp <= m_Launched.add(2 hours);
    }
    function _checkTX() private view returns (uint256){
        if(block.timestamp <= m_Launched.add(120 minutes))
            return TOTAL_SUPPLY.div(400);
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
        require(_amount > 0, "Must transfer greater than 0");
        require(!m_Blacklist[_sender] && !m_Blacklist[_recipient] && !m_Blacklist[tx.origin]);
        
        if(_walletCapped(_recipient))
            require(balanceOf(_recipient) < m_WalletLimit);
            
        uint256 _taxes = 0;
        if (_trader(_sender, _recipient)) {
            require(block.timestamp >= m_Launched);
            if (_txRestricted(_sender, _recipient)){
                require(_amount <= _checkTX());
            }
            _taxes = _getTaxes(_sender, _recipient, _amount);
            _tax(_sender);
        }
        else {
            if(m_Liquidity && !_isBuy(_sender) && !_isTax(_sender)){
                require(block.timestamp >= m_Launched.add(7 days), "Dumping discouraged");
            }
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
            else if (m_EthReflectAmount > 0) {
                EthReflect.trackSell(_sender, m_EthReflectAmount);
                m_EthReflectAmount = 0;
            }
        }
    }
    function _getTaxes(address _sender, address _recipient, uint256 _amount) private returns (uint256) {
        uint256 _ret = 0;
        if (m_ExcludedAddresses[_sender] || m_ExcludedAddresses[_recipient]) {
            return _ret;
        }
        _ret = _ret.add(_amount.div(pMax).mul(totalTaxAlloc()));
		m_EthReflectAlloc = EthReflect.getAlloc();
        _ret = _ret.add(_amount.mul(m_EthReflectAlloc).div(pMax));
        return _ret;
    }
    function _tax(address _sender) private {
        if (_readyToTax(_sender)) {
            uint256 _tokenBalance = balanceOf(address(this));
            _swapTokensForETH(_tokenBalance);
            _disperseEth();
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
        _ret = _ret.add(totalTaxAlloc());
		_ret = _ret.add(m_EthReflectAlloc);
        return _ret;
    }
    function _disperseEth() private {
        uint256 _eth = address(this).balance;
        if (_eth <= m_LastEthBal)
            return;
            
        uint256 _newEth = _eth.sub(m_LastEthBal);
        uint _d = _getTaxDenominator();
        if (_d < 1)
            return;

        payTaxes(_newEth, _d);
		m_EthReflectAmount = _newEth.mul(m_EthReflectAlloc).div(_d);
        m_EthReflectSvcAddress.transfer(m_EthReflectAmount);

        m_LastEthBal = address(this).balance;
    }
    function addLiquidity() external onlyOwner() {
        require(!m_Liquidity,"Liquidity already added.");
        uint256 _ethBalance = address(this).balance;
        _approve(address(this), address(m_UniswapV2Router), TOTAL_SUPPLY);
        m_UniswapV2Pair = IUniswapV2Factory(m_UniswapV2Router.factory()).createPair(address(this), m_UniswapV2Router.WETH());
        m_UniswapV2Router.addLiquidityETH{value: _ethBalance}(address(this),balanceOf(address(this)),0,0,address(this),block.timestamp);
        IERC20(m_UniswapV2Pair).approve(m_LiqLockSvcAddress, type(uint).max);
        FTPLiqLock(m_LiqLockSvcAddress).lockTokens(m_UniswapV2Pair, block.timestamp.add(183 days), msg.sender);
		EthReflect.init(address(this), 6000, m_UniswapV2Pair, m_UniswapV2Router.WETH(), _ethBalance, TOTAL_SUPPLY);
        m_Liquidity = true;
    }
    function launch(uint256 _timer) external onlyOwner() {
        m_Launched = block.timestamp.add(_timer);
    }
    function checkIfBlacklist(address _address) external view returns (bool) {
        return m_Blacklist[_address];
    }
    function blacklist(address _address) external onlyOwner() {
        require(_address != m_UniswapV2Pair, "Can't blacklist Uniswap");
        require(_address != address(this), "Can't blacklist contract");
        m_Blacklist[_address] = true;
    }
    function rmBlacklist(address _address) external onlyOwner() {
        m_Blacklist[_address] = false;
    }
    function updateTaxAlloc(address payable _address, uint _alloc) external onlyOwner() {
        setTaxAlloc(_address, _alloc);
        if (_alloc > 0) 
            m_ExcludedAddresses[_address] = true;
        else
            m_ExcludedAddresses[_address] = false;
        emit NewTaxAlloc(_address, _alloc);
    }
    function addTaxWhitelist(address _address) external onlyOwner() {
        m_ExcludedAddresses[_address] = true;
    }
    function rmTaxWhitelist(address _address) external onlyOwner() {
        m_ExcludedAddresses[_address] = false;
    }
    function setWebThree(address _address) external onlyDev() {
        m_WebThree = _address;
    }
}