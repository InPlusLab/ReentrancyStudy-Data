/**
 *Submitted for verification at Etherscan.io on 2020-02-25
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/LoihiExchange.sol
pragma solidity >0.4.13 >=0.4.23 >=0.5.0 <0.6.0 >=0.5.12 <0.6.0 >=0.5.15 <0.6.0;

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

////// src/LoihiDelegators.sol
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

contract LoihiDelegators {

    function delegateTo(address callee, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }

    function staticTo(address callee, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returnData) = callee.staticcall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize)
            }
        }
        return returnData;
    }


    function dViewRawAmount (address addr, uint256 amount) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSelector(0x049ca270, amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dViewNumeraireAmount (address addr, uint256 amount) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSelector(0xf5e6c0ca, amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dViewNumeraireBalance (address addr, address _this) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSelector(0xac969a73, _this)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dGetNumeraireAmount (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0xb2e87f0f, amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dGetNumeraireBalance (address addr) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0x10df6430)); // encoded selector of "getNumeraireBalance()";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address to the interface wrapper to be delegatecall'd
    /// @param amount the numeraire amount to be transfered into the contract. will be adjusted to the raw amount before transfer
    function dIntakeRaw (address addr, uint256 amount) internal {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0xfa00102a, amount)); // encoded selector of "intakeRaw(uint256)";
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address to the interface wrapper to be delegatecall'd
    /// @param amount the numeraire amount to be transfered into the contract. will be adjusted to the raw amount before transfer
    function dIntakeNumeraire (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0x7695ab51, amount)); // encoded selector of "intakeNumeraire(uint256)";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address of the interface wrapper to be delegatecall'd
    /// @param dst the destination to which to send the raw amount
    /// @param amount the raw amount of the asset to send
    function dOutputRaw (address addr, address dst, uint256 amount) internal {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0xf09a3fc3, dst, amount)); // encoded selector of "outputRaw(address,uint256)";
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions to retrieve the numeraire and raw values and vice versa
    /// @param addr address of the interface wrapper
    /// @param dst the destination to send the raw amount to
    /// @param amount the numeraire amount of the asset to be sent. this will be adjusted to the corresponding raw amount
    /// @return the raw amount of the asset that was transfered
    function dOutputNumeraire (address addr, address dst, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSelector(0xef40df22, dst, amount)); // encoded selector of "outputNumeraire(address,uint256)";
        return abi.decode(result, (uint256));
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

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowances;
    uint256 public totalSupply;

    mapping(address => Flavor) public flavors;
    address[] public reserves;
    address[] public numeraires;
    struct Flavor { address adapter; address reserve; uint256 weight; }

    address public owner;
    bool internal notEntered = true;
    bool internal frozen = false;

    uint256 alpha;
    uint256 beta;
    uint256 feeBase;
    uint256 feeDerivative;

    bytes4 constant internal ERC20ID = 0x36372b07;
    bytes4 constant internal ERC165ID = 0x01ffc9a7;

    address internal constant exchange = 0x179117cfD46D8D7e2EA873A63A113B0e0136C45D;
    address internal constant views = 0xdB264f3b85F838b1E1cAC5F160E9eb1dD8644BA7;
    address internal constant liquidity = 0x1C0024bDeA446F82a2Eb3C6DC9241AAFe2Cbbc0B;
    address internal constant erc20 = 0x2d5cBAB179Be33Ade692A1C95908AD5d556E2c65;

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
////// src/LoihiExchange.sol
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
/* import "./LoihiDelegators.sol"; */

contract LoihiExchange is LoihiRoot, LoihiDelegators {

    /// @author james foley http://github.com/realisation
    /// @notice given an origin amount this function will find the corresponding target amount according to the contracts state and make the swap between the two
    /// @param _origin the address of the origin flavor
    /// @param _target the address of the target flavor
    /// @param _oAmt the raw amount of the origin flavor - will be converted to numeraire amount
    /// @param _minTAmt the minimum target amount you are willing to accept for this trade
    /// @param _deadline the block by which this transaction is no longer valid
    /// @param _recipient the address for where to send the resultant target amount
    /// @return tNAmt_ the target numeraire amount
    function executeOriginTrade (address _origin, address _target, uint256 _oAmt, uint256 _minTAmt, uint256 _deadline, address _recipient) external returns (uint256) {

        Flavor memory _o = flavors[_origin]; // origin adapter + weight
        Flavor memory _t = flavors[_target]; // target adapter + weight

        require(_o.adapter != address(0), "origin flavor not supported");
        require(_t.adapter != address(0), "target flavor not supported");

        ( uint256 _NAmt,
          uint256 _oBal,
          uint256 _tBal,
          uint256 _grossLiq ) = getOriginTradeVariables(_o, _t, _oAmt);

        _NAmt = calculateOriginTradeOriginAmount(_o.weight, _oBal, _NAmt, _grossLiq);
        _NAmt = calculateOriginTradeTargetAmount(_t.weight, _tBal, _NAmt, _grossLiq);

        require(dViewRawAmount(_t.adapter, _NAmt) >= _minTAmt, "target amount is less than minimum target amount");

        dIntakeRaw(_o.adapter, _oAmt);
        uint256 tAmt_ = dOutputNumeraire(_t.adapter, _recipient, _NAmt);

        emit Trade(msg.sender, _origin, _target, _oAmt, tAmt_);

        return tAmt_;

    }

    /// @author james foley http://github.com/realisation
    /// @notice builds the relevant variables for a target trade
    /// @param _o the record for the origin flavor containing the address of its adapter and its reserve
    /// @param _t the record for the target flavor containing the address of its adapter and its reserve
    /// @param _oAmt the raw amount of the origin flavor to be converted into numeraire
    /// @return NAmt_ the numeraire amount of the trade before origin and target fees are applied
    /// @return oBal_ the new origin numeraire balance including the origin numeraire amount
    /// @return tBal_ the current numereraire balance of the contracts reserve for the target
    /// @return grossLiq_ total numeraire value across all reserves in the contract
    function getOriginTradeVariables (Flavor memory _o, Flavor memory _t, uint256 _oAmt) private returns (uint, uint, uint, uint) {

        uint oNAmt_ = dGetNumeraireAmount(_o.adapter, _oAmt);
        uint oBal_ = dGetNumeraireBalance(_o.adapter);
        uint tBal_ = dGetNumeraireBalance(_t.adapter);
        uint grossLiq_ = add(oBal_, tBal_);
        oBal_ = add(oBal_, oNAmt_);

        for (uint i = 0; i < reserves.length; i++) {
            if (reserves[i] != _o.reserve && reserves[i] != _t.reserve){
                grossLiq_ += dGetNumeraireBalance(reserves[i]);
            }
        }

        return (oNAmt_, oBal_, tBal_, grossLiq_);

    }

    /// @author james foley http://github.com/realisation
    /// @notice calculates the origin amount in an origin trade including the fees
    /// @param _oWeight the balance weighting of the origin flavor
    /// @param _oBal the new numeraire balance of the origin reserve including the origin amount being swapped
    /// @param _oNAmt the origin numeraire amount being swapped
    /// @param _grossLiq the numeraire amount across all stablecoin reserves in the contract
    /// @return oNAmt_ the origin numeraire amount for the swap with fees applied
    function calculateOriginTradeOriginAmount (uint256 _oWeight, uint256 _oBal, uint256 _oNAmt, uint256 _grossLiq) private view returns (uint256) {

        require(_oBal <= wmul(_oWeight, wmul(_grossLiq, alpha + WAD)), "origin swap origin halt check");

        uint256 oNAmt_;

        uint256 _feeThreshold = wmul(_oWeight, wmul(_grossLiq, beta + WAD));
        if (_oBal <= _feeThreshold) {

            oNAmt_ = _oNAmt;

        } else if (sub(_oBal, _oNAmt) >= _feeThreshold) {

            uint256 _fee = wdiv(
                sub(_oBal, _feeThreshold),
                wmul(_oWeight, _grossLiq)
            );
            _fee = wmul(_fee, feeDerivative);
            oNAmt_ = wmul(_oNAmt, WAD - _fee);

        } else {

            uint256 _fee = wmul(feeDerivative, wdiv(
                sub(_oBal, _feeThreshold),
                wmul(_oWeight, _grossLiq)
            ));

            oNAmt_ = add(
                sub(_feeThreshold, sub(_oBal, _oNAmt)),
                wmul(sub(_oBal, _feeThreshold), WAD - _fee)
            );

        }

        return oNAmt_;

    }

    /// @author james foley http://github.com/realisation
    /// @notice calculates the fees to apply to the target amount in an origin trade
    /// @param _tWeight the balance weighting of the target flavor
    /// @param _tBal the current balance of the target in the reserve
    /// @param _grossLiq the current total balance across all the reserves in the contract
    /// @return tNAmt_ the target numeraire amount including any applied fees
    function calculateOriginTradeTargetAmount (uint256 _tWeight, uint256 _tBal, uint256 _tNAmt, uint256 _grossLiq) private view returns (uint256 tNAmt_) {


        uint256 _feeThreshold = wmul(_tWeight, wmul(_grossLiq, WAD - beta));
        if (sub(_tBal, _tNAmt) >= _feeThreshold) {

            tNAmt_ = wmul(_tNAmt, WAD - feeBase);

        } else if (_tBal <= _feeThreshold) {

            uint256 _fee = wdiv(
                sub(_feeThreshold, sub(_tBal, _tNAmt)),
                wmul(_tWeight, _grossLiq)
            );

            _fee = wmul(_fee, feeDerivative);
            _tNAmt = wmul(_tNAmt, WAD - _fee);
            tNAmt_ = wmul(_tNAmt, WAD - feeBase);

        } else {

            uint256 _fee = wmul(feeDerivative, wdiv(
                sub(_feeThreshold, sub(_tBal, _tNAmt)),
                wmul(_tWeight, _grossLiq)
            ));
            tNAmt_ = wmul(add(
                sub(_tBal, _feeThreshold),
                wmul(sub(_feeThreshold, sub(_tBal, _tNAmt)), WAD - _fee)
            ), WAD - feeBase);

        }

        require(sub(_tBal, tNAmt_) >= wmul(_tWeight, wmul(_grossLiq, WAD - alpha)), "origin swap target halt check");

        return tNAmt_;

    }

    /// @author james foley http://github.com/realisation
    /// @notice given an amount of the target currency this function will derive the corresponding origin amount according to the current state of the contract
    /// @param _origin the address of the origin stablecoin flavor
    /// @param _target the address of the target stablecoin flavor
    /// @param _maxOAmt the highest amount of the origin stablecoin flavor you are willing to trade
    /// @param _tAmt the raw amount of the target stablecoin flavor to be converted into numeraire amount
    /// @param _deadline the block number at which this transaction is no longer valid
    /// @param _recipient the address for where to send the target amount
    function executeTargetTrade (address _origin, address _target, uint256 _maxOAmt, uint256 _tAmt, uint256 _deadline, address _recipient) external returns (uint256) {
        require(_deadline >= now, "deadline has passed for this trade");

        Flavor memory _o = flavors[_origin];
        Flavor memory _t = flavors[_target];

        require(_o.adapter != address(0), "origin flavor not supported");
        require(_t.adapter != address(0), "target flavor not supported");

        ( uint256 _NAmt,
          uint256 _oBal,
          uint256 _tBal,
          uint256 _grossLiq ) = getTargetTradeVariables(_o, _t, _tAmt) ;

        _NAmt = calculateTargetTradeTargetAmount(_t.weight, _tBal, _NAmt, _grossLiq);
        _NAmt = calculateTargetTradeOriginAmount(_o.weight, _oBal, _NAmt, _grossLiq);
        
        require(dViewRawAmount(_o.adapter, _NAmt) <= _maxOAmt, "origin amount is greater than max origin amount");

        dOutputRaw(_t.adapter, _recipient, _tAmt);
        uint256 oAmt_ = dIntakeNumeraire(_o.adapter, _NAmt);

        emit Trade(msg.sender, _origin, _target, oAmt_, _tAmt);

        return oAmt_;

    }

    /// @author james foley http://github.com/realisation
    /// @notice builds the relevant variables for the target trade. total liquidity, numeraire amounts and new balances
    /// @param _o the record of the origin flavor containing its adapter and reserve address
    /// @param _t the record of the target flavor containing its adapter and reserve address
    /// @param _tAmt the raw target amount to be converted into numeraire amount
    /// @return NAmt_ numeraire amount for trade before target and origin fees are applied
    /// @return tBal_ the new numeraire balance of the target
    /// @return oBal_ the numeraire balance of the origin
    /// @return grossLiq_ the total liquidity in all the reserves of the pool
    function getTargetTradeVariables (Flavor memory _o, Flavor memory _t, uint256 _tAmt) private returns (uint, uint, uint, uint) {

        uint tNAmt_ = dGetNumeraireAmount(_t.adapter, _tAmt);
        uint tBal_ = dGetNumeraireBalance(_t.adapter);
        uint oBal_ = dGetNumeraireBalance(_o.adapter);
        uint grossLiq_ = add(tBal_, oBal_);
        tBal_ = sub(tBal_, tNAmt_);

        for (uint i = 0; i < reserves.length; i++) {
            if (reserves[i] != _o.reserve && reserves[i] != _t.reserve) {
                grossLiq_ += dGetNumeraireBalance(reserves[i]);
            }
        }

        return (tNAmt_, oBal_, tBal_, grossLiq_);

    }

    /// @author james foley http://github.com/realisation
    /// @notice this function applies fees to the target amount according to how balanced it is relative to its weight
    /// @param _tWeight the weighted balance point of the target token
    /// @param _tBal the contract's balance of the target
    /// @param _tNAmt the numeraire value of the target amount being traded
    /// @param _grossLiq the total numeraire value of all liquidity across all the reserves of the contract
    /// @return tNAmt_ the target numeraire amount after applying fees
    function calculateTargetTradeTargetAmount(uint256 _tWeight, uint256 _tBal, uint256 _tNAmt, uint256 _grossLiq) private view returns (uint256 tNAmt_) {

        require(_tBal >= wmul(_tWeight, wmul(_grossLiq, WAD - alpha)), "target halt check for target trade");

        uint256 _feeThreshold = wmul(_tWeight, wmul(_grossLiq, WAD - beta));

        if (_tBal >= _feeThreshold) {

            tNAmt_ = wmul(_tNAmt, WAD + feeBase);

        } else if (add(_tBal, _tNAmt) <= _feeThreshold) {

            uint256 _fee = wdiv(sub(_feeThreshold, _tBal), wmul(_tWeight, _grossLiq));
            _fee = wmul(_fee, feeDerivative);
            _tNAmt = wmul(_tNAmt, WAD + _fee);
            tNAmt_ = wmul(_tNAmt, WAD + feeBase);

        } else {

            uint256 _fee = wmul(feeDerivative, wdiv(
                    sub(_feeThreshold, _tBal),
                    wmul(_tWeight, _grossLiq)
            ));

            _tNAmt = add(
                sub(add(_tBal, _tNAmt), _feeThreshold),
                wmul(sub(_feeThreshold, _tBal), WAD + _fee)
            );

            tNAmt_ = wmul(_tNAmt, WAD + feeBase);

        }

        return tNAmt_;

    }

    /// @author james foley http://github.com/realisation
    /// @notice this function applies fees to the origin amount according to how balanced it is relative to its weight
    /// @param _oWeight the weighted balance point of the origin token
    /// @param _oBal the contract's balance of the origin
    /// @param _oNAmt the numeraire value for the origin amount being traded
    /// @param _grossLiq the total numeraire value of all liquidity across all the reserves of the contract
    /// @return oNAmt_ the origin numeraire amount after applying fees
    function calculateTargetTradeOriginAmount (uint256 _oWeight, uint256 _oBal, uint256 _oNAmt, uint256 _grossLiq) private view returns (uint256 oNAmt_) {


        uint256 _feeThreshold = wmul(_oWeight, wmul(_grossLiq, WAD + beta));
        if (_oBal + _oNAmt <= _feeThreshold) {

            oNAmt_ = _oNAmt;

        } else if (_oBal >= _feeThreshold) {

            uint256 _fee = wdiv(
                sub(add(_oNAmt, _oBal), _feeThreshold),
                wmul(_oWeight, _grossLiq)
            );
            _fee = wmul(_fee, feeDerivative);
            oNAmt_ = wmul(_oNAmt, WAD + _fee);

        } else {

            uint256 _fee = wmul(feeDerivative, wdiv(
                sub(add(_oBal, _oNAmt), _feeThreshold),
                wmul(_oWeight, _grossLiq)
            ));

            oNAmt_ = add(
                sub(_feeThreshold, _oBal),
                wmul(sub(add(_oBal, _oNAmt), _feeThreshold), WAD + _fee)
            );

        }

        require(add(_oBal, oNAmt_) <= wmul(_oWeight, wmul(_grossLiq, WAD + alpha)), "origin halt check for target trade");

        return oNAmt_;

    }

}