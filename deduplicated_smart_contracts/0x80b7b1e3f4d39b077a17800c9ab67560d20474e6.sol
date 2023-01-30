/**
 *Submitted for verification at Etherscan.io on 2020-07-05
*/

/**
 *Submitted for verification at Etherscan.io on 2020-06-11
*/

// File: contracts/sol6/IERC20.sol

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;


contract Test {
    address[] tmp = [0xa67471321988BFd9e7210e07d9e7C6e2F795B55c, 0xa16Fc6e9b5D359797999adA576F7f4a4d57E8F75];
    uint[] tmp2 = [1, 2, 3];
    
    struct abc {
        uint a;
        address[] b;
        uint[] c;
    }

    function getArrayOfAddress()
        external
        view
        returns (
            address,
            address,
            address,
            address,
            address[] memory
        )
    {
        return (
            address(0xe57B2c3b4E44730805358131a6Fc244C57178Da7),
            address(0x98fac5AD613c707Ef3434B609A945986e4d05d07),
            address(0xeB4DBDEC268bC9818669E9926e62004317d84b54),
            address(0x0000000000000000000000000000000000000000),
            tmp
        );
    }
    
    function getArrayOfUint()
            external
        view
        returns (
            uint,
            uint,
            uint,
            uint[] memory
        )
    {
        return (
            123,
            456,
            789,
            tmp2
        );
    }
    
    function getSomeStruct()
        external
        view
        returns (
            abc memory
        )
    {
        abc memory myStruct;
        myStruct.a = 999;
        myStruct.b = tmp;
        myStruct.c = tmp2;
        
        return (
            myStruct
        );
    }

}