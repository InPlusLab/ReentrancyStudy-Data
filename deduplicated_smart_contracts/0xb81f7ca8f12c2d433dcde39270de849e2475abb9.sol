/**
 *Submitted for verification at Etherscan.io on 2020-03-09
*/

pragma solidity >= 0.5.12;

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

contract TokenLike {
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
}

contract VatLike {
    function gem(bytes32 ilk, address owner) public view returns (uint gem_);
    function dai(address owner) public view returns (uint dai_);
    function urns(bytes32 ilk, address owner) public view returns (uint ink, uint art);
    function ilks(bytes32 ilk) public view returns (uint Art, uint rate, uint spot, uint line, uint dust);
    function hope(address usr) public;
    function frob(bytes32 i, address u, address v, address w, int dink, int dart) public;
    function live() public view returns (uint live_);
}

contract GemJoinLike {
    function join(address urn, uint wad) public;
    function exit(address guy, uint wad) public;
}

contract SpotLike {
    function ilks(bytes32 ilk) public view returns (address pip, uint mat);
}

contract JugLike {
    function ilks(bytes32 ilk) public view returns (uint duty, uint rho);
    function base() public view returns (uint base_);
}

contract EndLike {
    function free(bytes32 ilk) public;
}

contract CatLike {
    function ilks(bytes32 ilk) public view returns (address flip, uint chop, uint lump);
}

contract OtcLike {
    function buyAllAmount(address buyGem, uint buyAmt, address sellGem, uint maxFillAmt) public returns (uint fillAmt);
    function sellAllAmount(address sellGem, uint sellAmt, address buyGem, uint minFillAmount) public returns (uint fillAmt);
    function getPayAmount(address pay_gem, address buy_gem, uint buy_amt) public view returns (uint fill_amt);
}

// OCM := OasisCdpManager
contract OCMLike {
    function urns(address usr, bytes32 ilk) public view returns (address urn);
    function open(bytes32 ilk) public returns (address urn);
    function frob(bytes32 ilk, int dink, int dart) public;
    function flux(bytes32 ilk, address dst, uint wad) public;
    function move(bytes32 ilk, address dst, uint rad) public;
    function quit(bytes32 ilk) public;
}

// DCM := DssCdpManager
contract DCMLike {
    function open(bytes32 ilk, address usr) public returns (uint);
    function enter(address src, uint cdp) public;
}

contract OLPAEvents {
    event FundGem(bytes32 indexed ilk, uint amount);
    event FundDai(bytes32 indexed ilk, uint amount);
    event DrawGem(bytes32 indexed ilk, uint amount);
    event DrawDai(bytes32 indexed ilk, uint amount);
    event BuyLev(bytes32 indexed ilk, uint amount, uint maxPayAmount, uint payAmount);
    event SellLev(bytes32 indexed ilk, uint amount, uint minPayAmount, uint payAmount);
    event Redeem(bytes32 indexed ilk, uint amount);
    event Free(bytes32 indexed ilk, uint amount, uint daiAmount);
    event Export(bytes32 indexed ilk, uint amount, uint daiAmount);
}

contract OasisLeverageProxyActions is DSMath, OLPAEvents {
    uint constant UV_INK   = 0;
    uint constant UV_TAB   = 1;
    uint constant UV_SPOT  = 2;
    uint constant UV_RATE  = 3;
    uint constant UV_DUST  = 4;
    uint constant UV_COUNT = 5;

    // This function returns an urn's ink, tab (:= art*rate), spot, and rate as a memory array.
    function urnValues(
        bytes32 ilk,
        address owner,
        address vat
    ) internal view returns (uint[UV_COUNT] memory values) {
        (, uint rate, uint spot, , uint dust) = VatLike(vat).ilks(ilk);
        (uint ink, uint art) = VatLike(vat).urns(ilk, owner);
        values[UV_INK]  = ink;
        values[UV_TAB]  = mul(art, rate);
        values[UV_SPOT] = spot;
        values[UV_RATE] = rate;
        values[UV_DUST] = dust;
    }

    // conversion factor; RAY / ROW = WAD
    // actual value: 10 ** 9
    uint constant ROW = RAY / WAD;

    uint constant BO_WALLET_BALANCE = 0;
    uint constant BO_MARGIN_BALANCE = 1;
    uint constant BO_URN_BALANCE = 2;
    uint constant BO_DEBT = 3;
    uint constant BO_DAI_BALANCE = 4;
    uint constant BO_PRICE = 5;
    uint constant BO_MIN_COLL_RATIO = 6;
    uint constant BO_ALLOWANCE = 7;
    uint constant BO_STABILITY_FEE = 8;
    uint constant BO_LIQUIDATION_PENALTY = 9;
    uint constant BO_DUST = 10;
    uint constant BO_COUNT = 11;

    function balance(
        address margin,
        bytes32[] memory ilks,
        address[] memory tokens,
        address vat,
        address spotter,
        address jug,
        address cat,
        address ocm
    ) public view returns (uint[] memory data, uint live) {
        data = new uint[](BO_COUNT * ilks.length);
        live = VatLike(vat).live();
        for (uint i = 0; i < ilks.length; i++) {
            if (uint(ilks[i]) == 0) break;
            uint row = BO_COUNT * i;
            data[row+BO_WALLET_BALANCE] = TokenLike(tokens[i]).balanceOf(msg.sender);
            data[row+BO_ALLOWANCE] = TokenLike(tokens[i]).allowance(msg.sender, margin);
            address urn = OCMLike(ocm).urns(margin, ilks[i]);
            uint spot;
            uint dust_mat_duty;
            if (urn != address(0)) {
                data[row+BO_MARGIN_BALANCE] = VatLike(vat).gem(ilks[i], urn);
                uint[UV_COUNT] memory urnVals = urnValues(ilks[i], urn, vat);
                data[row+BO_URN_BALANCE] = urnVals[UV_INK];
                data[row+BO_DEBT] = urnVals[UV_TAB] / RAY;
                spot = urnVals[UV_SPOT];
                dust_mat_duty  = urnVals[UV_DUST];
                data[row+BO_DAI_BALANCE] = VatLike(vat).dai(urn) / RAY;
            } else {
                (, , spot, , dust_mat_duty) = VatLike(vat).ilks(ilks[i]);
            }
            data[row+BO_DUST] = dust_mat_duty / RAY;
            (, dust_mat_duty) = SpotLike(spotter).ilks(ilks[i]);
            data[row+BO_PRICE] = mul(spot, dust_mat_duty) / (RAY * ROW);
            data[row+BO_MIN_COLL_RATIO] = dust_mat_duty / ROW;
            (dust_mat_duty, ) = JugLike(jug).ilks(ilks[i]);
            data[row+BO_STABILITY_FEE] = dust_mat_duty + JugLike(jug).base();
            (, data[row+BO_LIQUIDATION_PENALTY], ) = CatLike(cat).ilks(ilks[i]);
        }
    }

    function init(
        address ocm,
        bytes32 ilk
    ) internal returns (address urn) {
        urn = OCMLike(ocm).urns(address(this), ilk);
        if (urn == address(0)) urn = OCMLike(ocm).open(ilk);
    }

    function approve(
        address token,
        address usr
    ) internal {
        if (TokenLike(token).allowance(address(this), usr) != uint(-1)) {
            require(
                TokenLike(token).approve(usr, uint(-1)),
                "olpa/cannot-approve"
            );
        }
    }

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // WARNING:                                                              //
    //   These functions are meant to be used as a library for a DSProxy.    //
    //   Some are unsafe if called directly.                                 //
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    function fundGem(
        address ocm,
        bytes32 ilk,
        uint amount,
        address token,
        address adapter
    ) public {
        require(
            TokenLike(token).transferFrom(msg.sender, address(this), amount),
            "olpa/fund-cannot-transfer"
        );
        address urn = init(ocm, ilk);
        approve(token, adapter);
        GemJoinLike(adapter).join(urn, amount);
        require(amount < 2**255, "olpa/fundGem-overflow");
        OCMLike(ocm).frob(ilk, int(amount), 0);
        emit FundGem(ilk, amount);
    }

    function fundDai(
        address ocm,
        bytes32 ilk,
        uint amount,
        address token,
        address adapter,
        address vat
    ) public {
        require(
            TokenLike(token).transferFrom(msg.sender, address(this), amount),
            "olpa/fund-cannot-transfer"
        );
        emit FundDai(ilk, amount);
        address urn = init(ocm, ilk);
        approve(token, adapter);
        GemJoinLike(adapter).join(urn, amount);
        // join will have created the OCM urn if it did not already exist
        (, uint art) = VatLike(vat).urns(ilk, urn);
        if (art == 0) return;
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        uint tab = mul(art, rate);
        uint dai = mul(amount, RAY);
        uint dart;
        if (dai >= tab) {
          // wipe all debt
          dart = art;
        } else {
          // use (approximately) all free dai to wipe debt
          // if this makes the urn dusty, the tx will revert--UI must handle this
          dart = dai / rate;
          require(dart <= 2**255, "olpa/fundDai-overflow");
        }
        OCMLike(ocm).frob(ilk, 0, -int(dart));

    }

    function drawGem(
        address ocm,
        bytes32 ilk,
        uint amount,
        address adapter
    ) public {
        emit DrawGem(ilk, amount);
        require(amount <= 2**255, "olpa/fundGem-overflow");
        OCMLike(ocm).frob(ilk, -int(amount), 0);
        OCMLike(ocm).flux(ilk, address(this), amount);
        GemJoinLike(adapter).exit(msg.sender, amount);
    }

    function drawDai(
        address ocm,
        bytes32 ilk,
        uint amount,
        address adapter,
        address vat
    ) public {
        emit DrawDai(ilk, amount);
        address urn = init(ocm, ilk);
        uint dai = VatLike(vat).dai(urn) / RAY;
        if (amount > dai) {
            (, uint rate,,,) = VatLike(vat).ilks(ilk);
            // add 1 to ensure we generate at least (amount - dai) new debt
            uint dart = add(1, mul(amount - dai, RAY) / rate);
            require(dart < 2**255, "olpa/drawDai-overflow");
            OCMLike(ocm).frob(ilk, 0, int(dart));
        }
        OCMLike(ocm).move(ilk, address(this), amount * RAY);
        VatLike(vat).hope(adapter);
        GemJoinLike(adapter).exit(msg.sender, amount);
    }

    uint constant ADDR_TOKEN = 0;
    uint constant ADDR_ADAPTER = 1;
    uint constant ADDR_PAY_TOKEN = 2;
    uint constant ADDR_PAY_ADAPTER = 3;
    uint constant ADDR_OCM = 4;
    uint constant ADDR_OTC = 5;
    uint constant ADDR_VAT = 6;
    uint constant ADDR_COUNT = 7;

    function buyLev(
        address[ADDR_COUNT] memory contracts,
        bytes32 ilk,
        uint amount,
        uint maxPayAmount
    ) public {
        uint payAmount = OtcLike(contracts[ADDR_OTC]).getPayAmount(
            contracts[ADDR_PAY_TOKEN],
            contracts[ADDR_TOKEN],
            amount
        );
        require(payAmount <= maxPayAmount, "olpa/buyLev-excessive-total-amount");

        approve(contracts[ADDR_PAY_TOKEN], contracts[ADDR_OTC]);
        approve(contracts[ADDR_TOKEN], contracts[ADDR_ADAPTER]);

        VatLike(contracts[ADDR_VAT]).hope(contracts[ADDR_PAY_ADAPTER]);

        address urn = OCMLike(contracts[ADDR_OCM]).urns(address(this), ilk);
        uint daiBalance = VatLike(contracts[ADDR_VAT]).dai(urn) / RAY;

        if (payAmount <= daiBalance) {
            OCMLike(contracts[ADDR_OCM]).move(ilk, address(this), payAmount * RAY);
            GemJoinLike(contracts[ADDR_PAY_ADAPTER]).exit(address(this), payAmount);

            payAmount = OtcLike(contracts[ADDR_OTC]).buyAllAmount(
                contracts[ADDR_TOKEN],
                amount,
                contracts[ADDR_PAY_TOKEN],
                payAmount
            );

            GemJoinLike(contracts[ADDR_ADAPTER]).join(urn, amount);
            OCMLike(contracts[ADDR_OCM]).frob(ilk, int(amount), 0);
        } else {
            uint daiLeft = payAmount;
            payAmount = add(payAmount, TokenLike(contracts[ADDR_PAY_TOKEN]).balanceOf(address(this)));
            amount = 0;
            uint[UV_COUNT] memory urnVals = urnValues(ilk, urn, contracts[ADDR_VAT]);
            while (daiLeft > 0) {
                uint drawableDai = mul(urnVals[UV_INK], urnVals[UV_SPOT]);
                drawableDai = drawableDai > urnVals[UV_TAB] ? drawableDai - urnVals[UV_TAB] : 0;

                // daiLeft > daiBalance, so subtraction can be unchecked
                uint dart = min(mul(daiLeft - daiBalance, RAY), drawableDai) / urnVals[UV_RATE];

                // dart should be non-zero and the resulting position should be non-dusty
                // math is guaranteed to be safe by prior logic; cache new tab in drawableDai variable
                if (dart > 0 && (drawableDai = dart * urnVals[UV_RATE] + urnVals[UV_TAB]) >= urnVals[UV_DUST]) {
                    require(dart < 2**255, "olpa/buyLev-overflow");
                    OCMLike(contracts[ADDR_OCM]).frob(ilk, 0, int(dart));
                    urnVals[UV_TAB] = drawableDai;
                } else if (daiBalance == 0) {
                    // two cases:
                    //   1) need to draw a dusty amount
                    //   2) need to draw less than minimum possible amount of dai (dart == 0)

                    // Case (1) -- must revert
                    if (dart > 0) revert("olpa/buyLev-unfillable-dusty");

                    // Case (2) -- try to fill order
                    // This may revert due to being unsafe; if this happens, it is the correct behavior.
                    // If successful, we may buy slightly more than <amount> of <ilk>.
                    OCMLike(contracts[ADDR_OCM]).frob(ilk, 0, 1);
                    urnVals[UV_TAB] += urnVals[UV_RATE];
                }

                daiBalance = VatLike(contracts[ADDR_VAT]).dai(urn) / RAY;

                OCMLike(contracts[ADDR_OCM]).move(ilk, address(this), daiBalance * RAY);
                GemJoinLike(contracts[ADDR_PAY_ADAPTER]).exit(address(this), daiBalance);

                uint buyAmount = OtcLike(contracts[ADDR_OTC]).sellAllAmount(
                    contracts[ADDR_PAY_TOKEN],
                    daiBalance,
                    contracts[ADDR_TOKEN],
                    0
                );
                amount = add(amount, buyAmount);
                daiLeft = daiLeft <= daiBalance ? 0 : daiLeft - daiBalance;
                daiBalance = 0;

                GemJoinLike(contracts[ADDR_ADAPTER]).join(urn, buyAmount);

                require(buyAmount < 2**255, "olpa/buyLev-overflow");
                OCMLike(contracts[ADDR_OCM]).frob(ilk, int(buyAmount), 0);
                urnVals[UV_INK] = add(urnVals[UV_INK], buyAmount);
            }
            payAmount = sub(payAmount, TokenLike(contracts[ADDR_PAY_TOKEN]).balanceOf(address(this)));
        }
        emit BuyLev(ilk, amount, maxPayAmount, payAmount);
    }

    function sellLev(
        address[ADDR_COUNT] memory contracts,
        bytes32 ilk,
        uint origSellAmount,
        uint minDaiAmount
    ) public {
        approve(contracts[ADDR_TOKEN], contracts[ADDR_OTC]);
        approve(contracts[ADDR_PAY_TOKEN], contracts[ADDR_PAY_ADAPTER]);

        uint totalDaiAmount = 0;

        address urn = OCMLike(contracts[ADDR_OCM]).urns(address(this), ilk);
        uint[UV_COUNT] memory urnVals = urnValues(ilk, urn, contracts[ADDR_VAT]);

        uint amount = origSellAmount;

        while (amount > 0) {
            // truncating division ensures that sellAmount will not be too large
            uint sellAmount = sub(mul(urnVals[UV_INK], urnVals[UV_SPOT]), urnVals[UV_TAB]) / urnVals[UV_SPOT];
            require(sellAmount > 0, "olpa/sellLev-cannot-sell");
            if (sellAmount > amount) {
                sellAmount = amount;
                amount = 0;
            } else {
                amount = sub(amount, sellAmount);
            }
            require(sellAmount <= 2**255, "olpa/sellLev-overflow");
            OCMLike(contracts[ADDR_OCM]).frob(ilk, -int(sellAmount), 0);

            OCMLike(contracts[ADDR_OCM]).flux(ilk, address(this), sellAmount);
            GemJoinLike(contracts[ADDR_ADAPTER]).exit(address(this), sellAmount);

            urnVals[UV_INK] = sub(urnVals[UV_INK], sellAmount);
            uint daiAmount = OtcLike(contracts[ADDR_OTC]).sellAllAmount(
                contracts[ADDR_TOKEN],
                sellAmount,
                contracts[ADDR_PAY_TOKEN],
                0
            );

            totalDaiAmount = add(totalDaiAmount, daiAmount);

            GemJoinLike(contracts[ADDR_PAY_ADAPTER]).join(urn, daiAmount);

            daiAmount = mul(daiAmount, RAY);
            uint dart = daiAmount >= urnVals[UV_TAB]
                            ? urnVals[UV_TAB]
                            : min(daiAmount, urnVals[UV_TAB] - urnVals[UV_DUST]);
            dart = dart / urnVals[UV_RATE];
            require(dart <= 2**255, "olpa/sellLev-overflow");
            OCMLike(contracts[ADDR_OCM]).frob(ilk, 0, -int(dart));

            // frob succeeded, so this math must be safe
            urnVals[UV_TAB] = urnVals[UV_TAB] - dart * urnVals[UV_RATE];
        }
        require(
            totalDaiAmount >= minDaiAmount, "olpa/sellLev-insufficient-total-amount"
        );
        emit SellLev(ilk, origSellAmount, minDaiAmount, totalDaiAmount);
    }

    function redeem(
        address ocm,
        bytes32 ilk,
        uint amount,
        address adapter
    ) public {
        emit Redeem(ilk, amount);
        require(amount < 2**255, "olpa/redeem-overflow");
        OCMLike(ocm).frob(ilk, int(amount), 0);
    }

    function free(
        address ocm,
        bytes32 ilk,
        address vat,
        address end,
        address adapter,
        address daiAdapter
    ) public {
        VatLike(vat).hope(address(ocm));
        OCMLike(ocm).quit(ilk);
        EndLike(end).free(ilk);
        uint gem = VatLike(vat).gem(ilk, OCMLike(ocm).urns(address(this), ilk));
        OCMLike(ocm).flux(ilk, address(this), gem);
        uint amount = VatLike(vat).gem(ilk, address(this));
        GemJoinLike(adapter).exit(msg.sender, amount);
        uint dai = VatLike(vat).dai(OCMLike(ocm).urns(address(this), ilk)) / RAY;

        OCMLike(ocm).move(ilk, address(this), dai * RAY);
        VatLike(vat).hope(daiAdapter);
        GemJoinLike(daiAdapter).exit(msg.sender, dai);

        emit Free(ilk, amount, dai);
    }

    function export(
        address ocm,
        bytes32 ilk,
        address vat,
        address dcm
    ) public returns (uint cdpId) {
        uint[UV_COUNT] memory urnVals = urnValues(ilk, OCMLike(ocm).urns(address(this), ilk), vat);
        emit Export(ilk, urnVals[UV_INK], urnVals[UV_TAB] / RAY);

        VatLike(vat).hope(ocm);
        OCMLike(ocm).quit(ilk);

        cdpId = DCMLike(dcm).open(ilk, address(this));
        VatLike(vat).hope(address(dcm));
        DCMLike(dcm).enter(address(this), cdpId);
    }
}