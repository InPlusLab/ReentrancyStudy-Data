/**
 *Submitted for verification at Etherscan.io on 2021-06-13
*/

//Shiba Milkshake ($SHISHAKE)

//Telegram: https://t.me/ShibaMilkshake

/*
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
[email protected]::[email protected]
oooooooooooooooO8:::::[email protected]@8:[email protected]
[email protected]:[email protected]@8O::::::::::[email protected]@O:oooOOOoo:@oooooooooooooooooooo
[email protected]@o::oooooooooooooooooooOOOOOoo:8oooooooooooooooooooo
[email protected]@O::oooooooooooooooooooooooooOOoo:@oooooooooooooooooooo
[email protected]:[email protected]
[email protected]:oooooooooooooooooooooooooooooooooo88oooooooooooooooooooo
[email protected]:...:ooooooooooo:@ooooooooooooooooooooo
[email protected]:ooooooooooo:...:[email protected]
[email protected]::[email protected]
ooooooooooooooo88:[email protected]@[email protected]@oooooooooooooO8oooooooooooooooooo
ooooooooooooooO8:ooooo:oo::Ooooooooooooooooo:oooooooooooooo8Oooooooooooooooooo
oooooooooooooo8Oooooooooooo:............:o:oooooooooooo:::::@ooooooooooooooooo
[email protected]:oooooo:o:....:@8:[email protected]:oooooo:........:8Ooooooooooooooooo
[email protected]:..:ooo:........:[email protected]::@ooooooooooooooooo
[email protected]:[email protected]:[email protected]@[email protected]:8Oooooooooooooooooo
[email protected]:[email protected]:oo:8Ooooooooooooooooooo
[email protected]::[email protected]@[email protected]@@8................:::::[email protected]
[email protected]@O:ooooo8:[email protected]@:......::ooo:o:[email protected]
[email protected]:ooooooo8:[email protected]:::o:::oo:[email protected]@o88oooooooooooooooooooooo
[email protected]:ooooooo8:[email protected]@..:[email protected]@@8oOooo:[email protected]
[email protected]@@@@@@@@@@@@@@@@@@@@@@@oooOOooooooo:o::@@@O:.:[email protected]
ooooooooooooooooO8ooooooooo8:[email protected]:oooooooooooooo::@::::....:@Ooooooooo
[email protected]@@@@@@@@@@@@@@@@@:....ooooooooooooooo:[email protected]:[email protected]
oooooooooooooooo8:...:8::o8:o8:::@O........ooooooooooooooo:88oooooo:..:@oooooo
oooooooooooooooo8o...:@:o:8:@::::@8o........oooooooooo:oooo:@o:Ooooo:..O8ooooo
ooooooooooooooooo8O::@8::8:[email protected]@88:......oo::[email protected]::O88Oooooo..:@ooooo
[email protected]@O8oooO8:@[email protected]@@@[email protected]@@Ooo:oooooooo:::[email protected]:@ooooo
oooooooooooooo8O:.:88::o88o8oo8O8:[email protected]@O::::oooooooooo:::@oooooo...8Oooooo
oooooooooooooo8Oo.:88::OOO8:[email protected]::......o8oooooooooooooooo:[email protected]:...8Ooooooo
[email protected]::[email protected]@Oo:......oOooooooooooooooo:8Ooo:.::88oooooooo
[email protected]@[email protected]::....:o8ooooooooooooooo88:oo:[email protected]
ooooooooooooooooO8:[email protected]@O:o:.:[email protected]@@8Oooooooooooooo
[email protected]@:[email protected]
[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8888888OOooooooooooo
ooooOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/
//Twitter: https://twitter.com/ShibaMilkshake
//Website: https://shibamilkshake.finance (online before launch)
//📃 Verified Contract Before Launch📃
//🌝 5% Rewards 🌝
//🤖 Antibot Contract 🤖
//🕓 Cooldown & Initial Limit-Buy 🕓
//🔰 Ownership Renounced 🔰
//🔏 Unicrypt Locked at Launch 🔏
//🗳 Fair Launch (No Shaky Presale) & Community Driven
//CG, CMC listing: Submission after launch
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract ShibaMilkshake is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = "Shiba Milkshake";
    string private constant _symbol = "SHISHAKE\xF0\x9F\x8D\xA8";
    uint8 private constant _decimals = 8;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 3000000000000000 * 10**8;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private _taxFee = 5;
    uint256 private _teamFee = 10;

    mapping(address => bool) private bots;
    mapping(address => uint256) private cooldown;
    address payable private _shakerAddress;
    address payable private _shishakeMarketing;
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private cooldownEnabled = false;
    uint256 private _maxTxAmount = _tTotal;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address payable shakerAddress, address payable shishakeMarketing) {
        _shakerAddress = shakerAddress;
        _shishakeMarketing = shishakeMarketing;
        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_shakerAddress] = true;
        _isExcludedFromFee[_shishakeMarketing] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
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

    function setCooldownEnabled(bool onoff) external onlyOwner() {
        cooldownEnabled = onoff;
    }

    function tokenFromReflection(uint256 rAmount)
        private
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _teamFee == 0) return;
        _taxFee = 0;
        _teamFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = 5;
        _teamFee = 12;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            if (cooldownEnabled) {
                if (
                    from != address(this) &&
                    to != address(this) &&
                    from != address(uniswapV2Router) &&
                    to != address(uniswapV2Router)
                ) {
                    require(
                        _msgSender() == address(uniswapV2Router) ||
                            _msgSender() == uniswapV2Pair,
                        "ERR: Uniswap only"
                    );
                }
            }
            require(amount <= _maxTxAmount);
            require(!bots[from] && !bots[to]);
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to] &&
                cooldownEnabled
            ) {
                require(cooldown[to] < block.timestamp);
                cooldown[to] = block.timestamp + (17 seconds);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != uniswapV2Pair && swapEnabled) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _shakerAddress.transfer(amount.div(2));
        _shishakeMarketing.transfer(amount.div(2));
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen, "trading is already open");
        IUniswapV2Router02 _uniswapV2Router =
            IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapEnabled = true;
        cooldownEnabled = true;
        _maxTxAmount = 7500000000000 * 10**8;
        tradingOpen = true;
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    function manualswap() external {
        require(_msgSender() == _shakerAddress);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualsend() external {
        require(_msgSender() == _shakerAddress);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function setBots(address[] memory bots_) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBot(address notbot) public onlyOwner {
        bots[notbot] = false;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    receive() external payable {}

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
            _getTValues(tAmount, _taxFee, _teamFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function _getTValues(
        uint256 tAmount,
        uint256 taxFee,
        uint256 TeamFee
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tTeam = tAmount.mul(TeamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        require(maxTxPercent > 0, "Amount must be greater than 0");
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
        emit MaxTxAmountUpdated(_maxTxAmount);
    }
}