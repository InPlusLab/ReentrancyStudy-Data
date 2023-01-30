// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.3;

import 'Ownable.sol';
import 'SafeMath.sol';
import 'Address.sol';
import 'IERC20.sol';

contract Kindly is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => uint256) public totalTokensTransferred;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    struct ValuesResult {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tCharity;
        uint256 tMaintenance;
        uint256 tLiquidityWallet;
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 rLiquidity;
        uint256 rCharity;
        uint256 rMaintenance;
        uint256 rLiquidityWallet;
    }

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 108 * 10**6 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "Kindly Coin";
    string private constant _symbol = "KIND";
    uint8 private constant _decimals = 18;
    
    // fees
    uint256 public _taxFee = 30;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _charityFee = 250;
    uint256 private _previousCharityFee = _charityFee;

    uint256 public _maintenanceFee = 90;
    uint256 private _previousMaintenanceFee = _maintenanceFee;

    uint256 public _liquidityWalletFee = 30;
    uint256 private _previousliquidityWalletFee = _liquidityWalletFee;

    uint256 public _maxTxAmount = 540 * 10**3 * 10**18; // 0.005
    uint256 private constant _TIMELOCK = 0; //31556926 1 year

    event TaxFeePercentChanged(uint256 oldValue, uint256 newValue);
    event CharityFeePercentChanged(uint256 oldValue, uint256 newValue);
    event MaintenanceFeePercentChanged(uint256 oldValue, uint256 newValue);
    event LiquidityWalletFeePercentChanged(uint256 oldValue, uint256 newValue);
    event MaxTxPermillChanged(uint256 oldValue, uint256 newValue);


    constructor (address payable charityAddress, address payable maintenanceAddress, address payable liquidityWalletAddress) {
        _rOwned[owner()] = _rTotal;

        // exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        setCharityAddress(charityAddress);
        setMaintenanceAddress(maintenanceAddress);
        setLiquidityWalletAddress(liquidityWalletAddress);

        increaseTimeLockBy(_TIMELOCK);
        
        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function totalRSupply() external view onlyOwner() returns (uint256) {
        return _rTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function balanceOfT(address account) external view onlyOwner() returns (uint256) {
        return _tOwned[account];
    }

    function balanceOfR(address account) external view onlyOwner() returns (uint256) {
        return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner() onlyUnlocked() {
        emit OwnershipTransferred(owner(), newOwner);
        _transfer(owner(), newOwner, balanceOf(owner()));
        updateOwner(newOwner);
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public override onlyOwner() onlyUnlocked(){
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function excludeFromFee(address account) public override onlyOwner onlyUnlocked(){
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner() onlyUnlocked(){
        require(taxFee <= 30, "Cannot set percentage over 0.3%");
        emit TaxFeePercentChanged(_taxFee, taxFee);
        _taxFee = taxFee;
    }

    function setCharityFeePercent(uint256 charityFee) external onlyOwner() onlyUnlocked(){
        require(charityFee <= 250, "Cannot set percentage over 2.50%");
        emit CharityFeePercentChanged(_charityFee, charityFee);
        _charityFee = charityFee;
    }

    function setMaintenanceFeePercent(uint256 maintenanceFee) external onlyOwner() onlyUnlocked(){
        require(maintenanceFee <= 90, "Cannot set percentage over 0.90%");
        emit MaintenanceFeePercentChanged(_maintenanceFee, maintenanceFee);
        _maintenanceFee = maintenanceFee;
    }
    
    function setLiquidityWalletFeePercent(uint256 liquidityWalletFee) external onlyOwner() onlyUnlocked(){
        require(liquidityWalletFee <= 30, "Cannot set percentage over 0.3%");
        emit LiquidityWalletFeePercentChanged(_liquidityWalletFee, liquidityWalletFee);
        _liquidityWalletFee = liquidityWalletFee;
    }
   
    function setMaxTxPermill(uint256 maxTxPermill) external onlyOwner() onlyUnlocked(){
        emit LiquidityWalletFeePercentChanged(_maxTxAmount, _tTotal.mul(maxTxPermill).div(10**3));
        _maxTxAmount = _tTotal.mul(maxTxPermill).div(
            10**3
        );
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        ValuesResult memory valuesResult = ValuesResult(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

        _getTValues(tAmount, valuesResult);
        _getRValues(tAmount, valuesResult, _getRate());

        return (valuesResult.rAmount, valuesResult.rTransferAmount, valuesResult.rFee, valuesResult.tTransferAmount, valuesResult.tFee, valuesResult.tLiquidity, valuesResult.tCharity, valuesResult.tMaintenance, valuesResult.tLiquidityWallet);
    }

    function _getTValues(uint256 tAmount, ValuesResult memory valuesResult) private view returns (ValuesResult memory) {
        {
            uint256 tFee = calculateTaxFee(tAmount);
            valuesResult.tFee = tFee;
        }
        {
            uint256 tCharity = calculateCharityFee(tAmount);
            valuesResult.tCharity = tCharity;
        }
        {
            uint256 tMaintenance = calculateMaintenanceFee(tAmount);
            valuesResult.tMaintenance = tMaintenance;
        }
        {
            uint256 tLiquidityWallet = calculateLiquidityWalletFee(tAmount);
            valuesResult.tLiquidityWallet = tLiquidityWallet;
        }

        valuesResult.tTransferAmount = tAmount.sub(valuesResult.tFee).sub(valuesResult.tCharity).sub(valuesResult.tMaintenance).sub(valuesResult.tLiquidityWallet);
        return valuesResult;
    }

    function _getRValues(uint256 tAmount, ValuesResult memory valuesResult, uint256 currentRate) private pure returns (ValuesResult memory) {
        {
            uint256 rAmount = tAmount.mul(currentRate);
            valuesResult.rAmount = rAmount;
        }
        {
            uint256 rFee = valuesResult.tFee.mul(currentRate);
            valuesResult.rFee = rFee;
        }
        {
            uint256 rCharity = valuesResult.tCharity.mul(currentRate);
            valuesResult.rCharity = rCharity;
        }
        {
            uint256 rMaintenance = valuesResult.tMaintenance.mul(currentRate);
            valuesResult.rMaintenance = rMaintenance;
        }
        {
            uint256 rLiquidityWallet = valuesResult.tLiquidityWallet.mul(currentRate);
            valuesResult.rLiquidityWallet = rLiquidityWallet;
        }

        valuesResult.rTransferAmount = valuesResult.rAmount.sub(valuesResult.rFee).sub(valuesResult.rCharity).sub(valuesResult.rMaintenance).sub(valuesResult.rLiquidityWallet);
        return (valuesResult);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function _takeCharity(uint256 tCharity) private {
        uint256 currentRate =  _getRate();
        uint256 rCharity = tCharity.mul(currentRate);
        _rOwned[charity()] = _rOwned[charity()].add(rCharity);
        if(_isExcluded[charity()])
            _tOwned[charity()] = _tOwned[charity()].add(tCharity);
    }

    function _takeMaintenance(uint256 tMaintenance) private {
        uint256 currentRate =  _getRate();
        uint256 rMaintenance = tMaintenance.mul(currentRate);
        _rOwned[maintenance()] = _rOwned[maintenance()].add(rMaintenance);
        if(_isExcluded[maintenance()])
            _tOwned[maintenance()] = _tOwned[maintenance()].add(tMaintenance);
    }
    
    function _takeLiquidityWallet(uint256 tLiquidityWallet) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidityWallet = tLiquidityWallet.mul(currentRate);
        _rOwned[liquidityWallet()] = _rOwned[liquidityWallet()].add(rLiquidityWallet);
        if(_isExcluded[liquidityWallet()])
            _tOwned[liquidityWallet()] = _tOwned[liquidityWallet()].add(tLiquidityWallet);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**4
        );
    }

    function calculateCharityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_charityFee).div(
            10**4
        );
    }

    function calculateMaintenanceFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_maintenanceFee).div(
            10**4
        );
    }

    function calculateLiquidityWalletFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityWalletFee).div(
            10**4
        );
    }
    
    function removeAllFee() private {
        if(_taxFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousCharityFee = _charityFee;
        _previousMaintenanceFee = _maintenanceFee;
        _previousliquidityWalletFee = _liquidityWalletFee;
        
        _taxFee = 0;
        _charityFee = 0;
        _maintenanceFee = 0;
        _liquidityWalletFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _charityFee = _previousCharityFee;
        _maintenanceFee = _previousMaintenanceFee;
        _liquidityWalletFee = _previousliquidityWalletFee;
    }
    
    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addTokensTransferred(address wallet, uint256 amount) private {
        uint256 rate = _taxFee.add(_charityFee).add(_maintenanceFee).add(_liquidityWalletFee);
        totalTokensTransferred[wallet] = totalTokensTransferred[wallet].add(amount.mul(rate).div(10**4));
    }

    function getTotalTokensTransferredHistory(address wallet) external view returns(uint256 amount){
        amount = totalTokensTransferred[wallet];
        return amount;
    }

    /**
    * TRANSFER
    */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        // if fees are calculated, then these amounts will be tracked in totalTokensTransferred[sender]
        if(takeFee){
            addTokensTransferred(from, amount);
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity, uint256 tMaintenance, uint256 tLiquidityWallet) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeMaintenance(tMaintenance);
        _takeLiquidityWallet(tLiquidityWallet);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity, uint256 tMaintenance, uint256 tLiquidityWallet) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeMaintenance(tMaintenance);
        _takeLiquidityWallet(tLiquidityWallet);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity, uint256 tMaintenance, uint256 tLiquidityWallet) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeMaintenance(tMaintenance);
        _takeLiquidityWallet(tLiquidityWallet);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity, uint256 tMaintenance, uint256 tLiquidityWallet) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeMaintenance(tMaintenance);
        _takeLiquidityWallet(tLiquidityWallet);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    /**
    * TRANSFER (END)
    */
}