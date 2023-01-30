pragma solidity 0.5.17;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        if(a % b != 0)
            c = c + 1;
        return c;
    }
}

pragma solidity 0.5.17;

import './safeMath.sol';

interface Curve {
    function get_virtual_price() external view returns (uint);
}

interface Yearn {
    function getPricePerFullShare() external view returns (uint);
}

interface UnderlyingToken {
    function decimals() external view returns (uint8);
}

interface Compound {
    function exchangeRateStored() external view returns (uint);
    function underlying() external view returns (address);
}

interface Cream {
    function exchangeRateStored() external view returns (uint);
    function underlying() external view returns (address);
}

contract Normalizer {
    using SafeMath for uint;

    address public governance;
    address public creamY;
    mapping(address => bool) public native;
    mapping(address => bool) public yearn;
    mapping(address => bool) public curve;
    mapping(address => address) public curveSwap;
    mapping(address => bool) public vaults;
    mapping(address => bool) public compound;
    mapping(address => bool) public cream;
    mapping(address => uint) public underlyingDecimals;

    constructor() public {
        governance = msg.sender;

        native[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; // USDT
        native[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; // USDC
        native[0x4Fabb145d64652a948d72533023f6E7A623C7C53] = true; // BUSD
        native[0x0000000000085d4780B73119b644AE5ecd22b376] = true; // TUSD

        yearn[0xACd43E627e64355f1861cEC6d3a6688B31a6F952] = true; // vault yDAI
        yearn[0x37d19d1c4E1fa9DC47bD1eA12f742a0887eDa74a] = true; // vault yTUSD
        yearn[0x597aD1e0c13Bfe8025993D9e79C69E1c0233522e] = true; // vault yUSDC
        yearn[0x2f08119C6f07c006695E079AAFc638b8789FAf18] = true; // vault yUSDT

        yearn[0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01] = true; // yDAI
        yearn[0xd6aD7a6750A7593E092a9B218d66C0A814a3436e] = true; // yUSDC
        yearn[0x83f798e925BcD4017Eb265844FDDAbb448f1707D] = true; // yUSDT
        yearn[0x73a052500105205d34Daf004eAb301916DA8190f] = true; // yTUSD
        yearn[0xF61718057901F84C4eEC4339EF8f0D86D2B45600] = true; // ySUSD

        yearn[0xC2cB1040220768554cf699b0d863A3cd4324ce32] = true; // bDAI
        yearn[0x26EA744E5B887E5205727f55dFBE8685e3b21951] = true; // bUSDC
        yearn[0xE6354ed5bC4b393a5Aad09f21c46E101e692d447] = true; // bUSDT
        yearn[0x04bC0Ab673d88aE9dbC9DA2380cB6B79C4BCa9aE] = true; // bBUSD

        curve[0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2] = true; // cCompound
        curveSwap[0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2] = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56;
        curve[0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8] = true; // cYearn
        curveSwap[0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8] = 0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51;
        curve[0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B] = true; // cBUSD
        curveSwap[0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B] = 0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27;
        curve[0xC25a3A3b969415c80451098fa907EC722572917F] = true; // cSUSD
        curveSwap[0xC25a3A3b969415c80451098fa907EC722572917F] = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;
        curve[0xD905e2eaeBe188fc92179b6350807D8bd91Db0D8] = true; // cPAX
        curveSwap[0xD905e2eaeBe188fc92179b6350807D8bd91Db0D8] = 0x06364f10B501e868329afBc005b3492902d6C763;

        compound[0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643] = true; // cDAI
        underlyingDecimals[0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643] = 1e18;
        compound[0x39AA39c021dfbaE8faC545936693aC917d5E7563] = true; // cUSDC
        underlyingDecimals[0x39AA39c021dfbaE8faC545936693aC917d5E7563] = 1e6;
        compound[0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9] = true; // cUSDT
        underlyingDecimals[0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9] = 1e6;

        cream[0x44fbeBd2F576670a6C33f6Fc0B00aA8c5753b322] = true; // crUSDC
        underlyingDecimals[0x44fbeBd2F576670a6C33f6Fc0B00aA8c5753b322] = 1e6;
        cream[0x797AAB1ce7c01eB727ab980762bA88e7133d2157] = true; // crUSDT
        underlyingDecimals[0x797AAB1ce7c01eB727ab980762bA88e7133d2157] = 1e6;
        cream[0x1FF8CDB51219a8838b52E9cAc09b71e591BC998e] = true; // crBUSD
        underlyingDecimals[0x1FF8CDB51219a8838b52E9cAc09b71e591BC998e] = 1e18;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setCreamY(address _creamY) external {
        require(msg.sender == governance, "!governance");
        creamY = _creamY;
    }

    function getPrice(address token) external view returns (uint) {
        if (native[token] || token == creamY) {
            return 1e18;
        } else if (yearn[token]) {
            return Yearn(token).getPricePerFullShare();
        } else if (curve[token]) {
            return Curve(curveSwap[token]).get_virtual_price();
        } else if (compound[token]) {
            return getCompoundPrice(token);
        } else if (cream[token]) {
            return getCreamPrice(token);
        } else {
            return uint(0);
        }
    }

    function getCompoundPrice(address token) public view returns (uint) {
        address underlying = Compound(token).underlying();
        uint8 decimals = UnderlyingToken(underlying).decimals();
        return Compound(token).exchangeRateStored().mul(1e8).div(uint(10) ** decimals);
    }

    function getCreamPrice(address token) public view returns (uint) {
        address underlying = Cream(token).underlying();
        uint8 decimals = UnderlyingToken(underlying).decimals();
        return Cream(token).exchangeRateStored().mul(1e8).div(uint(10) ** decimals);
    }
}

pragma solidity 0.5.17;

import './safeMath.sol';
import './normalizer.sol';

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
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

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;
    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
    function sqrt(int256 x) internal pure returns (int256) {
        int256 z = add(x / 2, 1);
        int256 y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z), z)) / 2);
        }
        return y;
    }
}

contract CreamY is ERC20, ERC20Detailed {

    event LOG_SWAP(
        address indexed caller,
        address indexed tokenIn,
        address indexed tokenOut,
        uint            tokenAmountIn,
        uint            tokenAmountOut
    );

    event LOG_JOIN(
        address indexed caller,
        address indexed tokenIn,
        uint            tokenAmountIn
    );

    event LOG_EXIT(
        address indexed caller,
        address indexed tokenOut,
        uint            tokenAmountOut
    );

    using SafeMath for uint;
    using SignedSafeMath for int256;
    using SafeERC20 for IERC20;

    mapping(address => bool) public coins;
    mapping(address => bool) public pause;
    IERC20[] public allCoins;
    Normalizer public normalizer;
    address public governance;
    address public reservePool;

    constructor(address _normalizer, address _reservePool) public ERC20Detailed("CreamY USD", "cyUSD", 18) {
        governance = msg.sender;
        normalizer = Normalizer(_normalizer);
        reservePool = _reservePool;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setNormalizer(address _normalizer) external {
        require(msg.sender == governance, "!governance");
        normalizer = Normalizer(_normalizer);
    }

    function setReservePool(address _reservePool) external {
        require(msg.sender == governance, "!governance");
        require(_reservePool != address(0), "invalid reserve pool");
        reservePool = _reservePool;
    }

    function setFees(uint _fee, uint _reserveRatio) external {
        require(msg.sender == governance, '!governance');
        require(_fee < 1e18 && _fee >= 0.99e18, 'Invalid fee'); // 0 < fee <= 1%
        if (_reserveRatio > 0) {
            require(_reserveRatio <= 1e18, 'Invalid reserve ratio'); // reserve ratio <= 100% fee
        }
        fee = _fee;
        reserveRatio = _reserveRatio;
    }

    function approveCoins(address _coin) external {
        require(msg.sender == governance, "!governance");
        require(coins[_coin] == false, "Already approved");
        coins[_coin] = true;
        allCoins.push(IERC20(_coin));
    }

    function setPause(address _coin, bool _pause) external {
        require(msg.sender == governance, "!governance");
        pause[_coin] = _pause;
    }

    function setA(uint _A) external {
        require(msg.sender == governance, "!governance");
        require(_A > 0 && _A <= 1e18, "Invalid A");
        // When A is close to 1, it becomes the fixed price model (x + y = k).
        // When A is close to 0, it degenerates to Uniswap (x * y = k).
        // However, A couldn't be exactly 0 since it will break the f function.
        A = _A;
    }

    function seize(IERC20 token, uint amount) external {
        require(msg.sender == governance, "!governance");
        require(!tokens[address(token)], "can't seize liquidity");

        uint bal = token.balanceOf(address(this));
        require(amount <= bal);

        token.safeTransfer(reservePool, amount);
    }

    uint public fee = 0.99965e18;
    uint public reserveRatio = 1e18;
    uint public constant BASE = 1e18;

    uint public A = 0.7e18;
    uint public count = 0;
    mapping(address => bool) tokens;

    function f(int256 _x, int256 x, int256 y) internal view returns (int256 _y) {
        int256 k;
        int256 c;
        {
            int256 u = x.add(y.mul(int256(A)).div(1e18));
            int256 v = y.add(x.mul(int256(A)).div(1e18));
            k = u.mul(v);
            c = _x.mul(_x).sub(k.mul(1e18).div(int256(A)));
        }

        int256 cst = int256(A).add(int256(1e36).div(int256(A)));
        int256 _b = _x.mul(cst).div(1e18);

        int256 D = _b.mul(_b).sub(c.mul(4));

        require(D >= 0, "!root");

        _y = (-_b).add(D.sqrt()).div(2);
    }

    function collectReserve(IERC20 from, uint input) internal {
        if (reserveRatio > 0) {
            uint _fee = input.mul(BASE.sub(fee)).div(BASE);
            uint _reserve = _fee.mul(reserveRatio).div(BASE);
            from.safeTransfer(reservePool, _reserve);
        }
    }

    // Get all support coins
    function getAllCoins() public view returns (IERC20[] memory) {
        return allCoins;
    }

    // Calculate total pool value in USD
    function calcTotalValue() public view returns (uint value) {
        uint totalValue = uint(0);
        for (uint i = 0; i < allCoins.length; i++) {
            totalValue = totalValue.add(balance(allCoins[i]));
        }
        return totalValue;
    }

    // Calculate _x given x, y, _y
    function getX(int256 output, int256 x, int256 y) internal view returns (int256 input) {
        int256 _y = y.sub(output);
        int256 _x = f(_y, y, x);
        input = _x.sub(x);
    }

    // Calculate _y given x, y, _x
    function getY(int256 input, int256 x, int256 y) internal view returns (int256 output) {
        int256 _x = x.add(input);
        int256 _y = f(_x, x, y);
        output = y.sub(_y);
    }

    // Calculate output given exact input
    function getOutExactIn(IERC20 from, IERC20 to, uint input, int256 x, int256 y) public view returns (uint output) {
        uint inputInUsd = normalize1e18(from, input).mul(normalizer.getPrice(address(from))).div(1e18);
        uint inputAfterFeeInUsd = inputInUsd.mul(fee).div(BASE);

        uint outputInUsd = uint(getY(i(inputAfterFeeInUsd), x, y));

        output = normalize(to, outputInUsd.mul(1e18).div(normalizer.getPrice(address(to))));
    }

    // Calculate input given exact output
    function getInExactOut(IERC20 from, IERC20 to, uint output, int256 x, int256 y) public view returns (uint input) {
        uint outputInUsd = normalize1e18(to, output).mul(normalizer.getPrice(address(to))).div(1e18);

        uint inputBeforeFeeInUsd = uint(getX(i(outputInUsd), x, y));
        uint inputInUsd = inputBeforeFeeInUsd.mul(BASE).div(fee);

        input = normalize(from, inputInUsd.mul(1e18).div(normalizer.getPrice(address(from))));
    }

    // Normalize coin to 1e18
    function normalize1e18(IERC20 token, uint _amount) internal view returns (uint) {
        uint _decimals = ERC20Detailed(address(token)).decimals();
        if (_decimals == uint(18)) {
            return _amount;
        } else {
            return _amount.mul(1e18).div(uint(10)**_decimals);
        }
    }

    // Normalize coin to original decimals
    function normalize(IERC20 token, uint _amount) internal view returns (uint) {
        uint _decimals = ERC20Detailed(address(token)).decimals();
        if (_decimals == uint(18)) {
            return _amount;
        } else {
            return _amount.mul(uint(10)**_decimals).div(1e18);
        }
    }

    // Contract balance of coin normalized to 1e18
    function balance(IERC20 token) public view returns (uint) {
        address _token = address(token);
        uint _balance = IERC20(_token).balanceOf(address(this));
        uint _balanceInUsd = _balance.mul(normalizer.getPrice(_token)).div(1e18);
        return normalize1e18(token, _balanceInUsd);
    }

    // Converter helper to int256
    function i(uint x) public pure returns (int256) {
        int256 value = int256(x);
        require(value >= 0, 'overflow');
        return value;
    }

    function swapExactAmountIn(IERC20 from, IERC20 to, uint input, uint minOutput, uint deadline) external returns (uint output) {
        require(coins[address(from)] == true, "!coin");
        require(pause[address(from)] == false, "pause");
        require(coins[address(to)] == true, "!coin");
        require(pause[address(to)] == false, "pause");
        require(normalizer.getPrice(address(from)) > 0, "zero price");
        require(normalizer.getPrice(address(to)) > 0, "zero price");

        require(block.timestamp <= deadline, "expired");

        output = getOutExactIn(from, to, input, i(balance(from)), i(balance(to)));

        require(balance(to) >= output, "insufficient output liquidity");
        require(output >= minOutput, "slippage");

        emit LOG_SWAP(msg.sender, address(from), address(to), input, output);

        from.safeTransferFrom(msg.sender, address(this), input);
        to.safeTransfer(msg.sender, output);
        collectReserve(from, input);
        return output;
    }

    function swapExactAmountOut(IERC20 from, IERC20 to, uint maxInput, uint output, uint deadline) external returns (uint input) {
        require(coins[address(from)] == true, "!coin");
        require(pause[address(from)] == false, "pause");
        require(coins[address(to)] == true, "!coin");
        require(pause[address(to)] == false, "pause");
        require(normalizer.getPrice(address(from)) > 0, "zero price");
        require(normalizer.getPrice(address(to)) > 0, "zero price");

        require(block.timestamp <= deadline, "expired");
        require(balance(to) >= output, "insufficient output liquidity");

        input = getInExactOut(from, to, output, i(balance(from)), i(balance(to)));

        require(input <= maxInput, "slippage");

        emit LOG_SWAP(msg.sender, address(from), address(to), input, output);

        from.safeTransferFrom(msg.sender, address(this), input);
        to.safeTransfer(msg.sender, output);
        collectReserve(from, input);
        return input;
    }

    function addLiquidityExactIn(IERC20 from, uint input, uint minOutput, uint deadline) external returns (uint output) {
        require(coins[address(from)] == true, "!coin");
        require(pause[address(from)] == false, "pause");
        require(block.timestamp <= deadline, "expired");
        require(input > 0, "zero input");
        require(normalizer.getPrice(address(from)) > 0, "zero price");
        require(normalizer.getPrice(address(this)) > 0, "zero price");

        if (totalSupply() == 0) {
            uint inputAfterFee = input.mul(fee).div(BASE);
            output = normalize1e18(from, inputAfterFee.mul(normalizer.getPrice(address(from))).div(1e18));
        } else {
            output = getOutExactIn(from, this, input, i(balance(from)), i(totalSupply().div(count)));
        }

        require(output >= minOutput, "slippage");

        emit LOG_JOIN(msg.sender, address(from), output);

        from.safeTransferFrom(msg.sender, address(this), input);
        _mint(msg.sender, output);

        if (!tokens[address(from)] && balance(from) > 0) {
            tokens[address(from)] = true;
            count = count.add(1);
        }
    }

    function addLiquidityExactOut(IERC20 from, uint maxInput, uint output, uint deadline) external returns (uint input) {
        require(coins[address(from)] == true, "!coin");
        require(pause[address(from)] == false, "pause");
        require(block.timestamp <= deadline, "expired");
        require(output > 0, "zero output");
        require(normalizer.getPrice(address(from)) > 0, "zero price");
        require(normalizer.getPrice(address(this)) > 0, "zero price");

        if (totalSupply() == 0) {
            uint inputAfterFee = normalize(from, output.mul(1e18).div(normalizer.getPrice(address(from))));
            input = inputAfterFee.mul(BASE).divCeil(fee);
        } else {
            input = getInExactOut(from, this, output, i(balance(from)), i(totalSupply().div(count)));
        }

        require(input <= maxInput, "slippage");

        emit LOG_JOIN(msg.sender, address(from), output);

        from.safeTransferFrom(msg.sender, address(this), input);
        _mint(msg.sender, output);

        if (!tokens[address(from)] && balance(from) > 0) {
            tokens[address(from)] = true;
            count = count.add(1);
        }
    }

    function removeLiquidityExactIn(IERC20 to, uint input, uint minOutput, uint deadline) external returns (uint output) {
        require(block.timestamp <= deadline, "expired");
        require(coins[address(to)] == true, "!coin");
        require(input > 0, "zero input");
        require(normalizer.getPrice(address(this)) > 0, "zero price");
        require(normalizer.getPrice(address(to)) > 0, "zero price");

        output = getOutExactIn(this, to, input, i(totalSupply().div(count)), i(balance(to)));

        require(output >= minOutput, "slippage");

        emit LOG_EXIT(msg.sender, address(to), output);

        _burn(msg.sender, input);
        to.safeTransfer(msg.sender, output);

        if (balance(to) == 0) {
            tokens[address(to)] = false;
            count = count.sub(1);
        }
    }

    function removeLiquidityExactOut(IERC20 to, uint maxInput, uint output, uint deadline) external returns (uint input) {
        require(block.timestamp <= deadline, "expired");
        require(coins[address(to)] == true, "!coin");
        require(output > 0, "zero output");
        require(normalizer.getPrice(address(this)) > 0, "zero price");
        require(normalizer.getPrice(address(to)) > 0, "zero price");

        input = getInExactOut(this, to, output, i(totalSupply().div(count)), i(balance(to)));

        require(input <= maxInput, "slippage");

        emit LOG_EXIT(msg.sender, address(to), output);

        _burn(msg.sender, input);
        to.safeTransfer(msg.sender, output);

        if (balance(to) == 0) {
            tokens[address(to)] = false;
            count = count.sub(1);
        }
    }
}

