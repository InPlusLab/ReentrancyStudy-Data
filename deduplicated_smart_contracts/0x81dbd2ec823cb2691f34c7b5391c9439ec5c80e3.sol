/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/LoihiViews.sol
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
        bytes memory result = staticTo(addr, abi.encodeWithSignature("viewRawAmount(uint256)", amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dViewNumeraireAmount (address addr, uint256 amount) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSignature("viewNumeraireAmount(uint256)", amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dViewNumeraireBalance (address addr, address _this) internal view returns (uint256) {
        bytes memory result = staticTo(addr, abi.encodeWithSignature("viewNumeraireBalance(address)", _this)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dGetNumeraireAmount (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("getNumeraireAmount(uint256)", amount)); // encoded selector of "getNumeraireAmount(uint256");
        return abi.decode(result, (uint256));
    }

    function dGetNumeraireBalance (address addr) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("getNumeraireBalance()")); // encoded selector of "getNumeraireBalance()";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address to the interface wrapper to be delegatecall'd
    /// @param amount the numeraire amount to be transfered into the contract. will be adjusted to the raw amount before transfer
    function dIntakeRaw (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("intakeRaw(uint256)", amount)); // encoded selector of "intakeRaw(uint256)";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address to the interface wrapper to be delegatecall'd
    /// @param amount the numeraire amount to be transfered into the contract. will be adjusted to the raw amount before transfer
    function dIntakeNumeraire (address addr, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("intakeNumeraire(uint256)", amount)); // encoded selector of "intakeNumeraire(uint256)";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions for retrieving and transfering numeraire and raw values and vice versa
    /// @param addr the address of the interface wrapper to be delegatecall'd
    /// @param dst the destination to which to send the raw amount
    /// @param amount the raw amount of the asset to send
    function dOutputRaw (address addr, address dst, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("outputRaw(address,uint256)", dst, amount)); // encoded selector of "outputRaw(address,uint256)";
        return abi.decode(result, (uint256));
    }

    /// @author james foley http://github.com/realisation
    /// @dev this function delegate calls addr, which is an interface to the required functions to retrieve the numeraire and raw values and vice versa
    /// @param addr address of the interface wrapper
    /// @param dst the destination to send the raw amount to
    /// @param amount the numeraire amount of the asset to be sent. this will be adjusted to the corresponding raw amount
    /// @return the raw amount of the asset that was transfered
    function dOutputNumeraire (address addr, address dst, uint256 amount) internal returns (uint256) {
        bytes memory result = delegateTo(addr, abi.encodeWithSignature("outputNumeraire(address,uint256)", dst, amount)); // encoded selector of "outputNumeraire(address,uint256)";
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

    // address constant exchange = 0x9FD98Fcd4A9B10297237c735a9cb9B2a64266AE6;
    // address constant liquidity = 0xA3f4A860eFa4a60279E6E50f2169FDD080aAb655;
    // address constant views = 0x5202b8156F3E0C2C3696514a5532667f2C2fe49D;
    // address constant erc20 = 0x7422916F26BdFCC037Fe47CeDFf27Ddb7a8aa7cd;
    address exchange;
    address liquidity;
    address views;
    address erc20;

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
////// src/LoihiViews.sol
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

contract LoihiViews is LoihiRoot, LoihiDelegators {

    function viewTargetAmount (uint256 _oAmt, address _oAdptr, address _tAdptr, address _this, address[] memory _rsrvs, address _oRsrv, address _tRsrv, uint256[] memory _weights, uint256[] memory _globals) public view returns (uint256 tNAmt_) {

        require(_oAdptr != address(0), "origin flavor not supported");
        require(_tAdptr != address(0), "target flavor not supported");

        if (_oRsrv == _tRsrv) {
            uint256 _oNAmt = dViewNumeraireAmount(_oAdptr, _oAmt);
            return dViewRawAmount(_tAdptr, _oNAmt);
        }

        uint256 _oNAmt = dViewNumeraireAmount(_oAdptr, _oAmt);

        uint256 _grossLiq;
        uint256[] memory _balances = new uint256[](_rsrvs.length);
        for (uint i = 0; i < _rsrvs.length; i++) {
            _balances[i] = dViewNumeraireBalance(_rsrvs[i], _this);
            _grossLiq += _balances[i];
        }

        tNAmt_ = wmul(_oNAmt, WAD-_globals[3]);
        uint256 _oNFAmt = tNAmt_;
        uint256 _psi;
        uint256 _nGLiq;
        for (uint j = 0; j < 10; j++) {
            _psi = 0;
            _nGLiq = _grossLiq + _oNAmt - tNAmt_;
            for (uint i = 0; i < _balances.length; i++) {
                if (_rsrvs[i] == _oRsrv) _psi += makeFee(add(_balances[i], _oNAmt), wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
                else if (_rsrvs[i] == _tRsrv) _psi += makeFee(sub(_balances[i], tNAmt_), wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
                else _psi += makeFee(_balances[i], wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
            }

            if (_globals[5] < _psi) {
                if ((tNAmt_ = _oNFAmt + _globals[5] - _psi) / 10000000000 == tNAmt_ / 10000000000) break;
            } else {
                if ((tNAmt_ = _oNFAmt + wmul(_globals[4], _globals[5] - _psi)) / 10000000000 == tNAmt_ / 10000000000) break;
            }

        }

        for (uint i = 0; i < _balances.length; i++) {
            uint256 _ideal = wmul(_nGLiq, _weights[i]);
            if (_rsrvs[i] == _oRsrv) require(_balances[i] + _oNAmt < wmul(_ideal, WAD + _globals[0]), "origin halt check");
            if (_rsrvs[i] == _tRsrv) require(_balances[i] - tNAmt_ > wmul(_ideal, WAD - _globals[0]), "target halt check");
        }

        tNAmt_ = wmul(tNAmt_, WAD-_globals[3]);

        return dViewRawAmount(_tAdptr, tNAmt_);

    }

    function viewOriginAmount (uint256 _tAmt, address _tAdptr, address _oAdptr, address _this, address[] memory _rsrvs, address _tRsrv, address _oRsrv, uint256[] memory _weights, uint256[] memory _globals) public view returns (uint256 oNAmt_) {


        require(_oAdptr != address(0), "origin flavor not supported");
        require(_tAdptr != address(0), "target flavor not supported");

        if (_oRsrv == _tRsrv) {
            uint256 _tNAmt = dViewNumeraireAmount(_tAdptr, _tAmt);
            return dViewRawAmount(_oAdptr, _tNAmt);
        }

        uint256 _tNAmt = dViewNumeraireAmount(_tAdptr, _tAmt);

        uint256 _grossLiq;
        uint256[] memory _balances = new uint256[](_rsrvs.length);
        for (uint i = 0; i < _rsrvs.length; i++) {
            _balances[i] = dViewNumeraireBalance(_rsrvs[i], _this);
            _grossLiq += _balances[i];
        }

        oNAmt_ = wmul(_tNAmt, WAD+_globals[3]);
        uint256 _tNFAmt = oNAmt_;
        uint256 _psi;
        uint256 _nGLiq;
        for (uint j = 0; j < 10; j++) {
            _psi = 0;
            _nGLiq = _grossLiq + oNAmt_ - _tNAmt;
            for (uint i = 0; i < _rsrvs.length; i++) {
                if (_rsrvs[i] == _oRsrv) _psi += makeFee(add(_balances[i], oNAmt_), wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
                else if (_rsrvs[i] == _tRsrv) _psi += makeFee(sub(_balances[i], _tNAmt), wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
                else _psi += makeFee(_balances[i], wmul(_nGLiq, _weights[i]), _globals[1], _globals[2]);
            }

            if (_globals[5] < _psi) {
                if ((oNAmt_ = _tNFAmt + _psi - _globals[5]) / 10000000000 == oNAmt_ / 10000000000) break;
            } else {
                if ((oNAmt_ = _tNFAmt - wmul(_globals[4], _globals[5] - _psi)) / 10000000000 == oNAmt_ / 10000000000) break;
            }

        }

        for (uint i = 0; i < _balances.length; i++) {
            uint256 _ideal = wmul(_nGLiq, _weights[i]);
            if (_rsrvs[i] == _oRsrv) require(_balances[i] + oNAmt_ < wmul(_ideal, WAD + _globals[0]), "origin halt check");
            if (_rsrvs[i] == _tRsrv) require(_balances[i] - _tNAmt > wmul(_ideal, WAD - _globals[0]), "target halt check");
        }

        oNAmt_ = wmul(oNAmt_, WAD+_globals[3]);

        return dViewRawAmount(_oAdptr, oNAmt_);

    }

    function makeFee (uint256 _bal, uint256 _ideal, uint256 _beta, uint256 _delta) internal view returns (uint256 _fee) {

        uint256 threshold;
        if (_bal < (threshold = wmul(_ideal, WAD-_beta))) {
            _fee = wdiv(_delta, _ideal);
            _fee = wmul(_fee, (threshold = sub(threshold, _bal)));
            _fee = wmul(_fee, threshold);
        } else if (_bal > (threshold = wmul(_ideal, WAD+_beta))) {
            _fee = wdiv(_delta, _ideal);
            _fee = wmul(_fee, (threshold = sub(_bal, threshold)));
            _fee = wmul(_fee, threshold);
        } else _fee = 0;

    }

    function viewSelectiveWithdraw (address[] calldata _rsrvs, address[] calldata _flvrs, uint256[] calldata _amts, address _this, uint256[] calldata _weights, uint256[] calldata _globals) external view returns (uint256) {

        (uint256[] memory _balances, uint256[] memory _withdrawals) = viewBalancesAndAmounts(_rsrvs, _flvrs, _amts, _this);

        uint256 shellsBurned_;

        uint256 _nSum; uint256 _oSum;
        for (uint i = 0; i < _balances.length; i++) {
            _nSum = add(_nSum, sub(_balances[i], _withdrawals[i]));
            _oSum = add(_oSum, _balances[i]);
        }

        uint256 _psi = viewBurnFees(_balances, _withdrawals, _globals, _weights, _nSum, _oSum);

        if (_globals[5] < _psi) {
            uint256 _oUtil = sub(_oSum, _globals[5]);
            uint256 _nUtil = sub(_nSum, _psi);
            if (_oUtil == 0) return wmul(_nUtil, WAD+_globals[3]);
            shellsBurned_ = wdiv(wmul(sub(_oUtil, _nUtil), _globals[6]), _oUtil);
        } else {
            uint256 _oUtil = sub(_oSum, _globals[5]);
            uint256 _nUtil = sub(_nSum, wmul(_psi, _globals[4]));
            if (_oUtil == 0) return wmul(_nUtil, WAD+_globals[3]);
            uint256 _oUtilPrime = wmul(_globals[5], _globals[4]);
            _oUtilPrime = sub(_oSum, _oUtilPrime);
            shellsBurned_ = wdiv(wmul(sub(_oUtilPrime, _nUtil), _globals[6]), _oUtil);
        }

        return wmul(shellsBurned_, WAD+_globals[3]);

    }

    function viewSelectiveDeposit (address[] calldata _rsrvs, address[] calldata _flvrs, uint256[] calldata _amts, address _this, uint256[] calldata _weights, uint256[] calldata _globals) external view returns (uint256) {

        (uint256[] memory _balances, uint256[] memory _deposits) = viewBalancesAndAmounts(_rsrvs, _flvrs, _amts, _this);

        uint256 shellsMinted_;

        uint256 _nSum; uint256 _oSum;
        for (uint i = 0; i < _balances.length; i++) {
            _nSum = add(_nSum, add(_balances[i], _deposits[i]));
            _oSum = add(_oSum, _balances[i]);
        }

        require(_oSum < _nSum, "insufficient-deposit");

        uint256 _psi = viewMintFees(_balances, _deposits, _globals, _weights, _nSum, _oSum);

        if (_globals[5] < _psi) {
            uint256 _oUtil = sub(_oSum, _globals[5]);
            uint256 _nUtil = sub(_nSum, _psi);
            if (_oUtil == 0 || _globals[6] == 0) return wmul(_nUtil, WAD-_globals[3]);
            shellsMinted_ = wdiv(wmul(sub(_nUtil, _oUtil), _globals[6]), _oUtil);
        } else {
            uint256 _oUtil = sub(_oSum, _globals[5]);
            uint256 _nUtil = sub(_nSum, wmul(_psi, _globals[4]));
            if (_oUtil == 0 || _globals[6] == 0) return wmul(_nUtil, WAD-_globals[3]);
            uint256 _oUtilPrime = wmul(_globals[5], _globals[4]);
            _oUtilPrime = sub(_oSum, _oUtilPrime);
            shellsMinted_ = wdiv(wmul(sub(_nUtil, _oUtilPrime), _globals[6]), _oUtil);
        }

        return wmul(shellsMinted_, WAD-_globals[3]);
    }

    function viewMintFees (uint256[] memory _balances, uint256[] memory _deposits, uint256[] memory _globals, uint256[] memory _weights, uint256 _nSum, uint256 _oSum) public view returns (uint256 psi_) {

        for (uint i = 0; i < _balances.length; i++) {
            uint256 _nBal = add(_balances[i], _deposits[i]);
            uint256 _nIdeal = wmul(_nSum, _weights[i]);
            require(_nBal <= wmul(_nIdeal, WAD + _globals[0]), "deposit upper halt check");
            require(_nBal >= wmul(_nIdeal, WAD - _globals[0]), "deposit lower halt check");
            psi_ += makeFee(_nBal, _nIdeal, _globals[1], _globals[2]);
        }

    }

    function viewBurnFees (uint256[] memory _balances, uint256[] memory _withdrawals, uint256[] memory _globals, uint256[] memory _weights, uint256 _nSum, uint256 _oSum) public view returns (uint256 psi_) {

        for (uint i = 0; i < _balances.length; i++) {
            uint256 _nBal = sub(_balances[i], _withdrawals[i]);
            uint256 _nIdeal = wmul(_nSum, _weights[i]);
            require(_nBal <= wmul(_nIdeal, WAD + _globals[0]), "withdraw upper halt check");
            require(_nBal >= wmul(_nIdeal, WAD - _globals[0]), "withdraw lower halt check");
            psi_ += makeFee(_nBal, _nIdeal, _globals[1], _globals[2]);
        }

    }


    function viewBalancesAndAmounts (address[] memory _rsrvs, address[] memory _flvrs, uint256[] memory _amts, address _this) private view returns (uint256[] memory, uint256[] memory) {

        uint256[] memory balances_ = new uint256[](_rsrvs.length);
        uint256[] memory amounts_ = new uint256[](_rsrvs.length);

        for (uint i = 0; i < _flvrs.length/2; i++) {
            require(_flvrs[i*2] != address(0), "flavor not supported");
            for (uint j = 0; j < _rsrvs.length; j++) {
                if (balances_[j] == 0) balances_[j] = dViewNumeraireBalance(_rsrvs[j], _this);
                if (_rsrvs[j] == _flvrs[i*2+1] && _amts[i] > 0) amounts_[j] += dViewNumeraireAmount(_flvrs[i*2], _amts[i]);
            }
        }

        return (balances_, amounts_);

    }

    function totalReserves (address[] calldata _reserves, address _addr) external view returns (uint256, uint256[] memory) {
        uint256 totalBalance_;
        uint256[] memory balances_ = new uint256[](_reserves.length);
        for (uint i = 0; i < _reserves.length; i++) {
            balances_[i] = dViewNumeraireBalance(_reserves[i], _addr);
            totalBalance_ += balances_[i];
        }
        return (totalBalance_, balances_);
    }

}