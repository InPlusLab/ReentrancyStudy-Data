/**

 *Submitted for verification at Etherscan.io on 2019-04-27

*/



pragma solidity ^0.4.25;

contract TestMultiSig {

    event set1(uint256 num,address addr);

    event set2(uint256 num,address addr,bool boolean);

    uint256 a;

    address addr;

    bool b;

    

    function foo1(uint256 _a, address _addr) {

        a=_a;

        addr=_addr;

        emit set1(_a,_addr);

    }   

    

    function foo2(uint256 _a, address _addr, bool _b) {

        a=_a;

        addr=_addr;

        b=_b;

        emit set2(_a,_addr,_b);

    }   

}