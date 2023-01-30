/**

 *Submitted for verification at Etherscan.io on 2019-02-02

*/



pragma solidity ^0.4.24;



/**

 * Implementation of the xorshift128+ PRNG

 */

library PRNG {



    struct Data {

        uint64 s0;

        uint64 s1;

    }



    function next(Data storage self) external returns (uint64) {

        uint64 x = self.s0;

        uint64 y = self.s1;



        self.s0 = y;

        x ^= x << 23; // a

        self.s1 = x ^ y ^ (x >> 17) ^ (y >> 26); // b, c

        return self.s1 + y;

    }

}