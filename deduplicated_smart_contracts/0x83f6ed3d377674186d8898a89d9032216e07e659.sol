/**

 *Submitted for verification at Etherscan.io on 2019-01-16

*/



// SaiValuesAggregator.sol -- Sai values aggregator



// Copyright (C) 2018-2019 Michael Elliot <[email protected]>

// Copyright (C) 2018-2019 Gonzalo Balabasquer <[email protected]>

//

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



pragma solidity ^0.4.24;



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



pragma solidity ^0.4.13;



contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);

    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);

    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);

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



contract TopInterface {

    function tub() public view returns (address);

    function tap() public view returns (address);

}



contract TubInterface {

    function vox() public view returns (address);

    function pit() public view returns (address);

    function pip() public view returns (address);

    function pep() public view returns (address);

    function mat() public view returns (uint);

    function chi() public view returns (uint);

    function per() public view returns (uint);

    function tag() public view returns (uint);

    function axe() public view returns (uint);

    function cap() public view returns (uint);

    function fit() public view returns (uint);

    function tax() public view returns (uint);

    function fee() public view returns (uint);

    function gap() public view returns (uint);

    function rho() public view returns (uint);

    function rhi() public view returns (uint);

    function off() public view returns (bool);

    function out() public view returns (bool);

    function gem() public view returns (address);

    function gov() public view returns (address);

    function skr() public view returns (address);

    function sai() public view returns (address);

    function sin() public view returns (address);

    function cups(bytes32) public view returns (address, uint, uint, uint);

    function tab(bytes32) public view returns (uint);

    function safe(bytes32) public view returns (bool);

}



contract TapInterface {

    function fix() public view returns (uint);

    function gap() public view returns (uint);

}



contract VoxInterface {

    function par() public view returns (uint);

    function way() public view returns (uint);

    function era() public view returns (uint);

}



contract PipInterface {

    function peek() public view returns (bytes32, bool);

}



contract TokInterface {

    function totalSupply() public view returns (uint);

    function balanceOf(address) public view returns (uint);

    function allowance(address, address) public view returns (uint);

}



contract ProxyInterface {

    function owner() public view returns (address);

}



contract ProxyRegInterface {

    function proxies(address) public view returns (address);

}



contract SaiValuesAggregator is DSMath {

    address public top;



    constructor(address _top) public {

        top = _top;

    }



    function tub() public view returns (address) {

        return TopInterface(top).tub();

    }



    function tap() public view returns (address) {

        return TopInterface(top).tap();

    }



    function vox() public view returns (address) {

        return TubInterface(tub()).vox();

    }



    function pit() public view returns (address) {

        return TubInterface(tub()).pit();

    }



    function pip() public view returns (address) {

        return TubInterface(tub()).pip();

    }



    function pep() public view returns (address) {

        return TubInterface(tub()).pep();

    }



    function gem() public view returns (address) {

        return TubInterface(tub()).gem();

    }



    function gov() public view returns (address) {

        return TubInterface(tub()).gov();

    }



    function skr() public view returns (address) {

        return TubInterface(tub()).skr();

    }



    function sai() public view returns (address) {

        return TubInterface(tub()).sai();

    }



    function sin() public view returns (address) {

        return TubInterface(tub()).sin();

    }



    function getContractsAddrs(address proxyRegistry, address addr) public view returns (

                                                                                uint blockNumber,

                                                                                address[] saiContracts,

                                                                                address proxy

                                                                            ) {

        blockNumber = block.number;

        saiContracts = new address[](12);

        saiContracts[0] = top;

        saiContracts[1] = tub();

        saiContracts[2] = tap();

        saiContracts[3] = vox();

        saiContracts[4] = pit();

        saiContracts[5] = pip();

        saiContracts[6] = pep();

        saiContracts[7] = gem();

        saiContracts[8] = gov();

        saiContracts[9] = skr();

        saiContracts[10] = sai();

        saiContracts[11] = sin();

        proxy = ProxyRegInterface(proxyRegistry).proxies(addr);

        proxy = proxy != address(0) && ProxyInterface(proxy).owner() == addr ? proxy : address(0);

    }



    // Return the aggregated values from tub, vox and tap

    function aggregateValues(address addr, address proxy) public view returns (

                                                        uint blockNumber,

                                                        bytes32 pipVal,

                                                        bool pipSet,

                                                        bytes32 pepVal,

                                                        bool pepSet,

                                                        bool[] sStatus, // System status

                                                        uint[] sValues, // System Values

                                                        uint[] tValues // Token Values

                                                    ) {

        blockNumber = block.number;



        (pipVal, pipSet) = PipInterface(pip()).peek(); // Price feed value for gem

        (pepVal, pepSet) = PipInterface(pep()).peek(); // Price feed value for gov



        sStatus = new bool[](4);

        sStatus[0] = TubInterface(tub()).off(); // off: Cage flag

        sStatus[1] = TubInterface(tub()).out(); // out: Post cage exit

        uint pro = rmul(TokInterface(skr()).balanceOf(tub()), TubInterface(tub()).tag());

        sStatus[2] = pro < TokInterface(sin()).totalSupply(); // eek: deficit

        sStatus[3] = pro >= rmul(TokInterface(sin()).totalSupply(), TubInterface(tub()).mat()); // safe



        sValues = new uint[](19);

        // Tub

        sValues[0] = TubInterface(tub()).axe(); // Liquidation penalty

        sValues[1] = TubInterface(tub()).mat(); // Liquidation ratio

        sValues[2] = TubInterface(tub()).cap(); // Debt ceiling

        sValues[3] = TubInterface(tub()).fit(); // REF per SKR (just before settlement)

        sValues[4] = TubInterface(tub()).tax(); // Stability fee

        sValues[5] = TubInterface(tub()).fee(); // Governance fee

        sValues[6] = TubInterface(tub()).chi(); // Accumulated Tax Rates

        sValues[7] = TubInterface(tub()).rhi(); // Accumulated Tax + Fee Rates

        sValues[8] = TubInterface(tub()).rho(); // Time of last drip

        sValues[9] = TubInterface(tub()).gap(); // Join-Exit Spread

        sValues[10] = TubInterface(tub()).tag(); // Abstracted collateral price (ref per skr)

        sValues[11] = TubInterface(tub()).per(); // Wrapper ratio (gem per skr)

        // Vox

        sValues[12] = VoxInterface(vox()).par(); // Dai Target Price (ref per dai)

        sValues[13] = VoxInterface(vox()).way(); // The holder fee (interest rate)

        sValues[14] = VoxInterface(vox()).era();

        // Tap

        sValues[15] = TapInterface(tap()).fix(); // Cage price

        sValues[16] = TapInterface(tap()).gap(); // Boom-Bust Spread



        tValues = new uint[](20);

        tValues[0] = addr.balance;

        tValues[1] = TokInterface(gem()).totalSupply();

        tValues[2] = TokInterface(gem()).balanceOf(addr);

        tValues[3] = TokInterface(gem()).balanceOf(tub());

        tValues[4] = TokInterface(gem()).balanceOf(tap());



        tValues[5] = TokInterface(gov()).totalSupply();

        tValues[6] = TokInterface(gov()).balanceOf(addr);

        tValues[7] = TokInterface(gov()).balanceOf(pit());

        tValues[8] = TokInterface(gov()).allowance(addr, proxy);



        tValues[9] = TokInterface(skr()).totalSupply();

        tValues[10] = TokInterface(skr()).balanceOf(addr);

        tValues[11] = TokInterface(skr()).balanceOf(tub());

        tValues[12] = TokInterface(skr()).balanceOf(tap());



        tValues[13] = TokInterface(sai()).totalSupply();

        tValues[14] = TokInterface(sai()).balanceOf(addr);

        tValues[15] = TokInterface(sai()).balanceOf(tap());

        tValues[16] = TokInterface(sai()).allowance(addr, proxy);



        tValues[17] = TokInterface(sin()).totalSupply();

        tValues[18] = TokInterface(sin()).balanceOf(tub());

        tValues[19] = TokInterface(sin()).balanceOf(tap());

    }



    function aggregateCDPValues(bytes32 cup) public view returns (

                                                                    uint blockNumber,

                                                                    address lad,

                                                                    bool safe,

                                                                    uint[] r

                                                                ) {

        blockNumber = block.number;



        r = new uint[](8);



        // r[0]: ink

        // r[1]: art

        // r[2]: ire

        (lad, r[0], r[1], r[2]) = TubInterface(tub()).cups(cup);

        if (lad != address(0)) {

            safe = TubInterface(tub()).safe(cup);



            uint pro = rmul(TubInterface(tub()).tag(), r[0]);

            // r[3]: ratio

            r[3] = VoxInterface(vox()).par() > 0 && TubInterface(tub()).tab(cup) > 0 ? wdiv(pro, rmul(VoxInterface(vox()).par(), TubInterface(tub()).tab(cup))) : 0;



            // r[4]: availDAI

            r[4] = safe && TubInterface(tub()).mat() > 0 && VoxInterface(vox()).par() > 0

            ?

                sub(rdiv(pro, rmul(TubInterface(tub()).mat(), VoxInterface(vox()).par())), TubInterface(tub()).tab(cup))

            :

                0; // If not safe DAI can not be drawn



            uint minSKRNeeded = TubInterface(tub()).tag() > 0

            ?

                rdiv(rmul(rmul(TubInterface(tub()).tab(cup), TubInterface(tub()).mat()), VoxInterface(vox()).par()), TubInterface(tub()).tag())

            :

                0; // If there is not feed price, minSKR can not be calculated



            // r[5]: availSKR

            r[5] = safe

            ?

                r[1] > 0

                ?

                    minSKRNeeded > 0

                    ?

                        sub(r[0], minSKRNeeded > 0.005 ether ? minSKRNeeded : 0.005 ether)

                    :

                        0 // If minSKR can not be calculated, availSKR either

                :

                    r[0] // If no debt the available SKR is all the amount locked

            :

                0; // If not safe, there is not SKR to free



            // r[6]: availETH

            r[6] = rmul(r[5], TubInterface(tub()).per());



            // r[7]: liqPrice

            r[7] = r[0] > 0 && TubInterface(tub()).tab(cup) > 0

            ?

                wdiv(rdiv(rmul(TubInterface(tub()).tab(cup), TubInterface(tub()).mat()), TubInterface(tub()).per()), r[0])

            :

                0; // If there is not SKR locked or debt, liqPrice can not be calculated

        }

    }

}