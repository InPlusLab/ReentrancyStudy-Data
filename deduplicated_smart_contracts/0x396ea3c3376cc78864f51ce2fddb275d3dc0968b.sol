/**
 *Submitted for verification at Etherscan.io on 2019-11-16
*/

pragma solidity 0.5.12;

pragma solidity 0.5.12;

contract GemLike {
    function allowance(address, address) public returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function balanceOf(address) public returns (uint);
    function deposit() public payable;
    function withdraw(uint) public;
}

contract SaiTubLike {
    function sai() public view returns (GemLike);
}

contract JoinLike {
    function dai() public view returns (GemLike);
}

contract OtcLike {
    function sellAllAmount(address, uint, address, uint) public returns (uint);
    function buyAllAmount(address, uint, address, uint) public returns (uint);
    function getPayAmount(address, address, uint) public returns (uint);
}

contract ScdMcdMigrationLike {
    function daiJoin() public view returns (JoinLike);
    function tub() public view returns (SaiTubLike);
    function swapSaiToDai(uint) public;
}


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

pragma solidity >0.4.13;

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


contract OasisDirectMigrateProxyActions is DSMath {
    function sellAllAmountAndMigrateSai(
        address otc,
        address daiToken,
        uint daiAmt,
        address buyToken,
        uint minBuyAmt,
        address scdMcdMigration
    ) public returns (uint buyAmt) {
        swapSaiToDai(scdMcdMigration, daiAmt);

        if (GemLike(daiToken).allowance(address(this), otc) < daiAmt) {
            GemLike(daiToken).approve(otc, uint(-1));
        }
        buyAmt = OtcLike(otc).sellAllAmount(daiToken, daiAmt, buyToken, minBuyAmt);
        require(GemLike(buyToken).transfer(msg.sender, buyAmt), "");
    }

    function sellAllAmountBuyEthAndMigrateSai(
        address otc,
        address daiToken,
        uint daiAmt,
        address wethToken,
        uint minBuyAmt,
        address scdMcdMigration
    ) public returns (uint wethAmt) {
        swapSaiToDai(scdMcdMigration, daiAmt);

        if (GemLike(daiToken).allowance(address(this), otc) < daiAmt) {
            GemLike(daiToken).approve(otc, uint(-1));
        }
        wethAmt = OtcLike(otc).sellAllAmount(daiToken, daiAmt, wethToken, minBuyAmt);
        withdrawAndSend(wethToken, wethAmt);
    }

    function buyAllAmountAndMigrateSai(
        address otc,
        address buyToken,
        uint buyAmt,
        address daiToken,
        uint maxDaiAmt,
        address scdMcdMigration
    ) public returns (uint payAmt) {
        uint daiAmtNow = OtcLike(otc).getPayAmount(daiToken, buyToken, buyAmt);
        require(daiAmtNow <= maxDaiAmt, "");

        swapSaiToDai(scdMcdMigration, daiAmtNow);

        if (GemLike(daiToken).allowance(address(this), otc) < daiAmtNow) {
            GemLike(daiToken).approve(otc, uint(-1));
        }
        payAmt = OtcLike(otc).buyAllAmount(address(buyToken), buyAmt, daiToken, daiAmtNow);
        require(
            GemLike(buyToken).transfer(msg.sender, min(buyAmt, GemLike(buyToken).balanceOf(address(this)))),
            ""
        ); // To avoid rounding issues we check the minimum value
    }

    function buyAllAmountBuyEthAndMigrateSai(
        address otc,
        address wethToken,
        uint wethAmt,
        address daiToken,
        uint maxDaiAmt,
        address scdMcdMigration
    ) public returns (uint payAmt) {
        uint daiAmtNow = OtcLike(otc).getPayAmount(daiToken, wethToken, wethAmt);
        require(daiAmtNow <= maxDaiAmt, "");

        swapSaiToDai(scdMcdMigration, daiAmtNow);

        if (GemLike(daiToken).allowance(address(this), otc) < daiAmtNow) {
            GemLike(daiToken).approve(otc, uint(-1));
        }
        payAmt = OtcLike(otc).buyAllAmount(wethToken, wethAmt, daiToken, daiAmtNow);
        withdrawAndSend(wethToken, wethAmt);
    }

    // private methods
    function swapSaiToDai(address scdMcdMigration, uint wad) private {
        GemLike sai = ScdMcdMigrationLike(scdMcdMigration).tub().sai();
        sai.transferFrom(msg.sender, address(this), wad);
        if (sai.allowance(address(this), scdMcdMigration) < wad) {
            sai.approve(scdMcdMigration, wad);
        }
        ScdMcdMigrationLike(scdMcdMigration).swapSaiToDai(wad);
    }

    function withdrawAndSend(address wethToken, uint wethAmt) private {
        GemLike(wethToken).withdraw(wethAmt);

        (bool success,) = msg.sender.call.value(wethAmt)("");
        require(success, "");
    }

    // required to be able to interact with ether
    function() external payable { }
}