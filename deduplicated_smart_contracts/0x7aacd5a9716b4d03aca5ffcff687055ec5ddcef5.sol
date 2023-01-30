/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/Loihi.sol
pragma solidity >0.4.13 >=0.4.23 >=0.5.0 <0.6.0 >=0.5.6 <0.6.0 >=0.5.12 <0.6.0 >=0.5.15 <0.6.0;

////// lib/ds-math/src/math.sol
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity >0.4.13; */

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

////// src/LoihiRoot.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.5.15; */

/* import "ds-math/math.sol"; */

contract LoihiRoot is DSMath {

    string  public constant name = "Shells";
    string  public constant symbol = "SHL";
    uint8   public constant decimals = 18;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowances;
    uint256 public totalSupply;

    struct Flavor { address adapter; address reserve; }
    mapping(address => Flavor) public flavors;

    address[] public reserves;
    address[] public numeraires;
    uint256[] public weights;

    address public owner;
    bool internal notEntered = true;
    bool public frozen = false;

    uint256 public alpha;
    uint256 public beta;
    uint256 public delta;
    uint256 public epsilon;
    uint256 public lambda;
    uint256 internal omega;

    bytes4 constant internal ERC20ID = 0x36372b07;
    bytes4 constant internal ERC165ID = 0x01ffc9a7;

    address constant exchange = 0x9FD98Fcd4A9B10297237c735a9cb9B2a64266AE6;
    address constant liquidity = 0xA3f4A860eFa4a60279E6E50f2169FDD080aAb655;
    address constant views = 0x5202b8156F3E0C2C3696514a5532667f2C2fe49D;
    address constant erc20 = 0x7422916F26BdFCC037Fe47CeDFf27Ddb7a8aa7cd;

    event ShellsMinted(address indexed minter, uint256 amount, address[] indexed coins, uint256[] amounts);
    event ShellsBurned(address indexed burner, uint256 amount, address[] indexed coins, uint256[] amounts);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Trade(address indexed trader, address indexed origin, address indexed target, uint256 originAmount, uint256 targetAmount);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier nonReentrant() {
        require(notEntered, "re-entered");
        notEntered = false;
        _;
        notEntered = true;
    }

    modifier notFrozen () {
        require(!frozen, "swaps, selective deposits and selective withdraws have been frozen.");
        _;
    }

}
////// src/Loihi.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.5.15; */

/* import "./LoihiRoot.sol"; */

contract ERC20Approve {
    function approve (address spender, uint256 amount) public returns (bool);
}

contract Loihi is LoihiRoot {

    address constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant cdai = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address constant chai = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;

    address constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant cusdc = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

    address constant usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant ausdt = 0x71fc860F7D3A592A4a98740e39dB31d25db65ae8;

    address constant susd = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address constant asusd = 0x625aE63000f46200499120B906716420bd059240;

    address constant daiAdapter = 0xaC3DcacaF33626963468c58001414aDf1a4CCF86;
    address constant cdaiAdapter = 0xA5F095e778B30DcE3AD25D5A545e3e9d6092f1Af;
    address constant chaiAdapter = 0x251D87F3d6581ae430a8Df18C2474DA07C569615;

    address constant usdcAdapter = 0x98dD552EaEc607f9804fbd9758Df9C30Ada60B7B;
    address constant cusdcAdapter = 0xA189607D20afFA0b1a578f9D14040822D507978F;

    address constant usdtAdapter = 0xCd0dA368E6e32912DD6633767850751969346d15;
    address constant ausdtAdapter = 0xA4906F20a7806ca28626d3D607F9a594f1B9ed3B;

    address constant susdAdapter = 0x4CB5174C962a40177876799836f353e8E9c4eF75;
    address constant asusdAdapter = 0x68747564d7B4e7b654BE26D09f60f7756Cf54BF8;

    address constant aaveLpCore = 0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3;

    constructor () public {

        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

        numeraires = [ dai, usdc, usdt, susd ];
        reserves = [ cdaiAdapter, cusdcAdapter, ausdtAdapter, asusdAdapter ];
        weights = [ 300000000000000000, 300000000000000000, 300000000000000000, 100000000000000000 ];
        
        flavors[dai] = Flavor(daiAdapter, cdaiAdapter);
        flavors[chai] = Flavor(chaiAdapter, cdaiAdapter);
        flavors[cdai] = Flavor(cdaiAdapter, cdaiAdapter);
        flavors[usdc] = Flavor(usdcAdapter, cusdcAdapter);
        flavors[cusdc] = Flavor(cusdcAdapter, cusdcAdapter);
        flavors[usdt] = Flavor(usdtAdapter, ausdtAdapter);
        flavors[ausdt] = Flavor(ausdtAdapter, ausdtAdapter);
        flavors[susd] = Flavor(susdAdapter, asusdAdapter);
        flavors[asusd] = Flavor(asusdAdapter, asusdAdapter);

        address[] memory targets = new address[](5);
        address[] memory spenders = new address[](5);
        targets[0] = dai; spenders[0] = chai;
        targets[1] = dai; spenders[1] = cdai;
        targets[2] = susd; spenders[2] = aaveLpCore;
        targets[3] = usdc; spenders[3] = cusdc;
        targets[4] = usdt; spenders[4] = aaveLpCore;

        for (uint i = 0; i < targets.length; i++) {
            (bool success, bytes memory returndata) = targets[i].call(abi.encodeWithSignature("approve(address,uint256)", spenders[i], uint256(0)));
            require(success, "SafeERC20: low-level call failed");
            (success, returndata) = targets[i].call(abi.encodeWithSignature("approve(address,uint256)", spenders[i], uint256(-1)));
            require(success, "SafeERC20: low-level call failed");
        }
        
        alpha = 900000000000000000; // .9
        beta = 400000000000000000; // .4
        delta = 150000000000000000; // .15
        epsilon = 175000000000000; // 1.75 bps * 2 = 3.5 bps
        lambda = 500000000000000000; // .5 

    }

    function supportsInterface (bytes4 interfaceID) external returns (bool) {
        return interfaceID == ERC20ID || interfaceID == ERC165ID;
    }

    function freeze (bool freeze) external onlyOwner {
        frozen = freeze;
    }

    function transferOwnership (address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function setParams (uint256 _alpha, uint256 _beta, uint256 _delta, uint256 _epsilon, uint256 _lambda, uint256 _omega) public onlyOwner {
        require(_alpha < WAD && _alpha > 0, "invalid-alpha");
        require(_beta < _alpha && _beta > 0, "invalid-beta");
        alpha = _alpha;
        beta = _beta;
        delta = _delta;
        epsilon = _epsilon;
        lambda = _lambda;
        omega = _omega;
    }

    function includeNumeraireReserveAndWeight (address numeraire, address reserve, uint256 weight) public onlyOwner {
        numeraires.push(numeraire);
        reserves.push(reserve);
        weights.push(weight);
    }

    function includeAdapter (address flavor, address adapter, address reserve) public onlyOwner {
        flavors[flavor] = Flavor(adapter, reserve);
    }

    function excludeAdapter (address flavor) public onlyOwner {
        delete flavors[flavor];
    }

    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) { revert(add(returnData, 0x20), returndatasize) }
        }
        return returnData;
    }

    function staticTo(address callee, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.staticcall(data);
        assembly {
            if eq(success, 0) { revert(add(returnData, 0x20), returndatasize) }
        }
        return returnData;
    }

    /// @author james foley http://github.com/realisation
    /// @notice swap a given origin amount for a bounded minimum of the target
    /// @param _o the address of the origin
    /// @param _t the address of the target
    /// @param _oAmt the origin amount
    /// @param _mTAmt the minimum target amount 
    /// @param _dline deadline in block number after which the trade will not execute
    /// @return tAmt_ the amount of target that has been swapped for the origin
    function swapByOrigin (address _o, address _t, uint256 _oAmt, uint256 _mTAmt, uint256 _dline) external notFrozen nonReentrant returns (uint256 tAmt_) {
        bytes memory result = delegateTo(exchange, abi.encodeWithSignature("executeOriginTrade(uint256,uint256,address,address,address,uint256)", _dline, _mTAmt, msg.sender, _o, _t, _oAmt));
        return abi.decode(result, (uint256));
    }


    /// @author james foley http://github.com/realisation
    /// @notice transfer a fixed origin amount into a dynamic target amount at the recipients address 
    /// @param _o the address of the origin
    /// @param _t the address of the target
    /// @param _oAmt the origin amount
    /// @param _mTAmt the minimum target amount 
    /// @param _dline deadline in block number after which the trade will not execute
    /// @param _rcpnt the address of the recipient of the target
    /// @return tAmt_ the amount of target that has been swapped for the origin
    function transferByOrigin (address _o, address _t, uint256 _oAmt, uint256 _mTAmt, uint256 _dline, address _rcpnt) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(exchange, abi.encodeWithSignature("executeOriginTrade(uint256,uint256,address,address,address,uint256)", _dline, _mTAmt, _rcpnt, _o, _t, _oAmt));
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @notice view how much of the target currency the origin currency will provide
    /// @param _o the address of the origin
    /// @param _t the address of the target
    /// @param _oAmt the origin amount
    /// @return tAmt_ the amount of target that has been swapped for the origin
    function viewOriginTrade (address _o, address _t, uint256 _oAmt) external view notFrozen returns (uint256) {

        Flavor memory _oF = flavors[_o];
        Flavor memory _tF = flavors[_t];

        uint256[] memory _globals = new uint256[](6);
        _globals[0] = alpha; _globals[1] = beta; _globals[2] = delta; _globals[3] = epsilon; _globals[4] = lambda; _globals[5] = omega;

        bytes memory result = staticTo(views, abi.encodeWithSignature("viewTargetAmount(uint256,address,address,address,address[],address,address,uint256[],uint256[])", 
            _oAmt, _oF.adapter, _tF.adapter, address(this), reserves, _oF.reserve, _tF.reserve, weights, _globals)); 

        return abi.decode(result, (uint256));

    }

    /// @author james foley http://github.com/realisation
    /// @notice swap a dynamic origin amount for a fixed target amount
    /// @param _o the address of the origin
    /// @param _t the address of the target
    /// @param _mOAmt the maximum origin amount
    /// @param _tAmt the target amount 
    /// @param _dline deadline in block number after which the trade will not execute
    /// @return oAmt_ the amount of origin that has been swapped for the target
    function swapByTarget (address _o, address _t, uint256 _mOAmt, uint256 _tAmt, uint256 _dline) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(exchange, abi.encodeWithSignature("executeTargetTrade(uint256,address,address,uint256,uint256,address)", _dline, _o, _t, _mOAmt, _tAmt, msg.sender));
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @notice transfer a dynamic origin amount into a fixed target amount at the recipients address
    /// @param _o the address of the origin
    /// @param _t the address of the target
    /// @param _mOAmt the maximum origin amount
    /// @param _tAmt the target amount 
    /// @param _dline deadline in block number after which the trade will not execute
    /// @param _rcpnt the address of the recipient of the target
    /// @return oAmt_ the amount of origin that has been swapped for the target
    function transferByTarget (address _o, address _t, uint256 _mOAmt, uint256 _tAmt, uint256 _dline, address _rcpnt) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(exchange, abi.encodeWithSignature("executeTargetTrade(uint256,address,address,uint256,uint256,address)", _dline, _o, _t, _mOAmt, _tAmt, _rcpnt));
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @notice view how much of the origin currency the target currency will take
    /// @param _o the address of the origin
    /// @param _t the address of the target
    /// @param _tAmt the target amount
    /// @return oAmt_ the amount of target that has been swapped for the origin
    function viewTargetTrade (address _o, address _t, uint256 _tAmt) external view notFrozen returns (uint256) {

        Flavor memory _oF = flavors[_o];
        Flavor memory _tF = flavors[_t];

        uint256[] memory _globals = new uint256[](6);
        _globals[0] = alpha; _globals[1] = beta; _globals[2] = delta; _globals[3] = epsilon; _globals[4] = lambda; _globals[5] = omega;

        bytes memory result = staticTo(views, abi.encodeWithSignature("viewOriginAmount(uint256,address,address,address,address[],address,address,uint256[],uint256[])", 
            _tAmt, _tF.adapter, _oF.adapter, address(this), reserves, _tF.reserve, _oF.reserve, weights, _globals));

        return abi.decode(result, (uint256));

    }

    /// @author james foley http://github.com/realisation
    /// @notice selectively deposit any supported stablecoin flavor into the contract in return for corresponding amount of shell tokens
    /// @param _flvrs an array containing the addresses of the flavors being deposited into
    /// @param _amts an array containing the values of the flavors you wish to deposit into the contract. each amount should have the same index as the flavor it is meant to deposit
    /// @param _minShells minimum acceptable amount of shells 
    /// @param _dline deadline for tx
    /// @return shellsToMint_ the amount of shells to mint for the deposited stablecoin flavors
    function selectiveDeposit (address[] calldata _flvrs, uint256[] calldata _amts, uint256 _minShells, uint256 _dline) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(liquidity, abi.encodeWithSignature("selectiveDeposit(address[],uint256[],uint256,uint256)", _flvrs, _amts, _minShells, _dline));
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @notice view how many shell tokens a deposit will mint
    /// @param _flvrs an array containing the addresses of the flavors being deposited into
    /// @param _amts an array containing the values of the flavors you wish to deposit into the contract. each amount should have the same index as the flavor it is meant to deposit
    /// @return shellsToMint_ the amount of shells to mint for the deposited stablecoin flavors
    function viewSelectiveDeposit (address[] calldata _flvrs, uint256[] calldata _amts) external view notFrozen returns (uint256) {
        uint256[] memory _globals = new uint256[](7);
        _globals[0] = alpha; _globals[1] = beta; _globals[2] = delta; _globals[3] = epsilon; _globals[4] = lambda; _globals[5] = omega; _globals[6] = totalSupply;
        address[] memory _flavors = new address[](_flvrs.length*2);
        for (uint256 i = 0; i < _flvrs.length; i++){
            Flavor memory _f = flavors[_flvrs[i]];
            _flavors[i*2] = _f.adapter;
            _flavors[i*2+1] = _f.reserve;
        }
        bytes memory result = staticTo(views, abi.encodeWithSignature("viewSelectiveDeposit(address[],address[],uint256[],address,uint256[],uint256[])", reserves, _flavors, _amts, address(this), weights, _globals));
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @notice deposit into the pool with no slippage from the numeraire assets the pool supports
    /// @param _deposit the full amount you want to deposit into the pool which will be divided up evenly amongst the numeraire assets of the pool
    /// @return shellsToMint_ the amount of shells you receive in return for your deposit
    function proportionalDeposit (uint256 _deposit) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(liquidity, abi.encodeWithSignature("proportionalDeposit(uint256)", _deposit));
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @notice selectively withdrawal any supported stablecoin flavor from the contract by burning a corresponding amount of shell tokens
    /// @param _flvrs an array of flavors to withdraw from the reserves
    /// @param _amts an array of amounts to withdraw that maps to _flavors
    /// @return shellsBurned_ the corresponding amount of shell tokens to withdraw the specified amount of specified flavors
    function selectiveWithdraw (address[] calldata _flvrs, uint256[] calldata _amts, uint256 _maxShells, uint256 _dline) external notFrozen nonReentrant returns (uint256) {
        bytes memory result = delegateTo(liquidity, abi.encodeWithSignature("selectiveWithdraw(address[],uint256[],uint256,uint256)", _flvrs, _amts, _maxShells, _dline));
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @notice view how many shell tokens a withdraw will consume
    /// @param _flvrs an array of flavors to withdraw from the reserves
    /// @param _amts an array of amounts to withdraw that maps to _flavors
    /// @return shellsBurned_ the corresponding amount of shell tokens to withdraw the specified amount of specified flavors
    function viewSelectiveWithdraw (address[] calldata _flvrs, uint256[] calldata _amts) external view notFrozen returns (uint256) {
        uint256[] memory _globals = new uint256[](7);
        _globals[0] = alpha; _globals[1] = beta; _globals[2] = delta; _globals[3] = epsilon; _globals[4] = lambda; _globals[5] = omega; _globals[6] = totalSupply;
        address[] memory _flavors = new address[](_flvrs.length*2);
        for (uint256 i = 0; i < _flvrs.length; i++){
            Flavor memory _f = flavors[_flvrs[i]];
            _flavors[i*2] = _f.adapter;
            _flavors[i*2+1] = _f.reserve;
        }
        bytes memory result = staticTo(views, abi.encodeWithSignature("viewSelectiveWithdraw(address[],address[],uint256[],address,uint256[],uint256[])", reserves, _flavors, _amts, address(this), weights, _globals));
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @notice withdrawas amount of shell tokens from the the pool equally from the numeraire assets of the pool with no slippage
    /// @param _totalShells the full amount you want to withdraw from the pool which will be withdrawn from evenly amongst the numeraire assets of the pool
    /// @return withdrawnAmts_ the amount withdrawn from each of the numeraire assets
    function proportionalWithdraw (uint256 _totalShells) external nonReentrant returns (uint256[] memory) {
        bytes memory result = delegateTo(liquidity, abi.encodeWithSignature("proportionalWithdraw(uint256)", _totalShells));
        return abi.decode(result, (uint256[]));
    }

    function transfer (address recipient, uint256 amount) public nonReentrant returns (bool) {
        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("transfer(address,uint256)", recipient, amount));
        return abi.decode(result, (bool));
    }

    function transferFrom (address sender, address recipient, uint256 amount) public nonReentrant returns (bool) {
        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("transferFrom(address,address,uint256)", sender, recipient, amount));
        return abi.decode(result, (bool));
    }

    function approve (address spender, uint256 amount) public nonReentrant returns (bool) {
        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("approve(address,uint256)", spender, amount));
        return abi.decode(result, (bool));
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("increaseAllowance(address,uint256)", spender, addedValue));
        return abi.decode(result, (bool));
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        bytes memory result = delegateTo(erc20, abi.encodeWithSignature("decreaseAllowance(address,uint256)", spender, subtractedValue));
        return abi.decode(result, (bool));
    }

    function balanceOf (address account) public view returns (uint256) {
        return balances[account];
    }

    function allowance (address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    function totalReserves () external returns (uint256, uint256[] memory) {
        bytes memory result = staticTo(views, abi.encodeWithSignature("totalReserves(address[],address)", reserves, address(this)));
        return abi.decode(result, (uint256, uint256[]));
    }

    function safeApprove(address _token, address _spender, uint256 _value) public onlyOwner {
        (bool success, bytes memory returndata) = _token.call(abi.encodeWithSignature("approve(address,uint256)", _spender, _value));
        require(success, "SafeERC20: low-level call failed");
    }

}