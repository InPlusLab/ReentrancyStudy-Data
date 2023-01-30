/**
 *Submitted for verification at Etherscan.io on 2020-02-21
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/McdSfChangeSpell.sol
pragma solidity >0.4.13 >=0.5.12 <0.6.0;

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

////// src/McdSfChangeSpell.sol
// Copyright (C) 2019 Maker Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.5.12; */

/* import "ds-math/math.sol"; */

contract PauseLike {
	function delay() public view returns (uint256);
	function plot(address, bytes32, bytes memory, uint256) public;
	function exec(address, bytes32, bytes memory, uint256) public;
}

/**
 * @title MCD Stability Fee Change Spell
 */
contract McdSfChangeSpell is DSMath {
	PauseLike public pause = PauseLike(0xbE286431454714F511008713973d3B053A2d38f3);
	address public plan = 0x4F5f0933158569c026d617337614d00Ee6589B6E;
	address public jug = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;

	// bytes32 what, the `what`
	bytes32 public what = "base";
	// uint256 data, the new Stability Fee
	uint256 public data = mul(1337, RAY);

	bytes32 public tag;
	uint256 public eta;

	bytes public sig;
	bool public done;

	/**
	 * @dev constructor function to set function sig, plan, and tag
	 */
	constructor() public {
		// `MCD_GOV_ACTIONS` connector contract used here
		sig = abi.encodeWithSignature(
			"dripAndFile(address,bytes32,uint256)",
			jug,
			what,
			data
		);
		address _plan = plan;
		bytes32 _tag;
		assembly { _tag := extcodehash(_plan) }
		tag = _tag;
	}

	/**
	 * @dev schedule function to set `eta` and call `pause.plot`
	 */
	function schedule() public {
		require(eta == 0, "spell-already-scheduled");
		eta = add(now, PauseLike(pause).delay());
		pause.plot(plan, tag, sig, eta);
	}

	/**
	 * @dev cast function to execute a plotted plan
	 */
	function cast() public {
		require(!done, "spell-already-cast");
		done = true;
		pause.exec(plan, tag, sig, eta);
	}
}