/**

 *Submitted for verification at Etherscan.io on 2019-02-14

*/



/*

Copyright 2019 Jochem Brouwer <[email protected]>



Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/



pragma solidity >0.5.0;



/*

    CREATE2SafeDeploy contract. This is basically a CREATE2 proxy contract which implements one extra guard for CREATE2: 

    If a contract has been deployed at an address in the past, the DeploySafe() transaction will throw 

    On top of this, the seed is hashed together with msg.sender (so seed is keccak256(msg.sender, seed)) to prevent users 

    deploying the same contract using an obvious seed (e.g. 0x0) run into a revert 

    DeploySafe only throws AFTER creation. This is to save some gas - if it tries to figure out if the target address is deployed 

    before it actually CREATE2's then it has to do an extra SHA3 on the init code. If you want to figure out if the contract is already deployed 

    you should 

*/





contract CREATE2SafeDeploy {

    

    // Read this mapping to see if a contract has been deployed (in the past (!!!)) at this address 

    // Hence extcodesize checks on the address will not work on in the future selfdestructed contracts.

    // This mapping records if a contract was ever (tried) to be deployed at this address 

    mapping (address => bool) public CREATE2DeployedAt;

    

    constructor() public {

        CREATE2DeployedAt[address(0x0)] = true; // in case of failed deployment we will let DeploySafe throw 

    }

    

    // DeploySafe which only checks if a contract has been deployed AFTER it is created 

    // Call this if you are sure that the the deploy address has not been used in the past 

    // If you are not sure, use DeploySafeWithPrecheck which checks if the contract has been deployed in the past 

    // before it starts to CREATE2 it - which saves gas in this case but will be slightly more expensive in case 

    // that the creation succeeds. 

    function DeploySafe(bytes calldata init_code, bytes32 seed) external payable returns (address) {

        // copy init_code to memory 

        bytes memory init_code_mem = init_code;

        bytes32 actualSeed = keccak256(abi.encodePacked(msg.sender, seed)); // prevent hash collissions 

        

        address deployedAt;

        

        assembly {

            deployedAt := create2(callvalue, add(init_code_mem, 0x20), mload(init_code_mem), actualSeed)

        }

        

        // If, for some reason, re-entrancy for CREATE is possible we guard against this here 

        // (actually since we hash msg.sender this seems impossible - but let's be safe)

        require(!CREATE2DeployedAt[deployedAt]);

        CREATE2DeployedAt[deployedAt] = true;

        

        return deployedAt;

    }

    

    // Call this contract to check if a contract is created at the target address before creating it. 

    // This saves gas in case there has been a contract at thte target in the past but costs slightly more gas if not.

    function DeploySafeWithPrecheck(bytes calldata init_code, bytes32 seed) external payable returns (address) {

        // copy init_code to memory 

        bytes memory init_code_mem = init_code;

        bytes32 actualSeed = keccak256(abi.encodePacked(msg.sender, seed));

        bytes32 init_code_keccak = keccak256(abi.encodePacked(init_code_mem));

        

        address target = _GetCREATE2ContractAddress(init_code_keccak, actualSeed);

        require(!CREATE2DeployedAt[target]);

        

        address deployedAt;

        

        assembly {

            deployedAt := create2(callvalue, add(init_code_mem, 0x20), mload(init_code_mem), actualSeed)

        }

        

        // If, for some reason, re-entrancy for CREATE is possible we guard against this here 

        require(!CREATE2DeployedAt[deployedAt]);

        CREATE2DeployedAt[deployedAt] = true;

        

        return deployedAt;

    }

    

    // returns the specific contract address which will be deployed here given keccak256(init_code) and seed as passed to DeploySafe 

    function GetCREATE2ContractAddress(bytes32 keccak256init_code, bytes32 seed) external view returns (address) {

        bytes32 result = keccak256(

            abi.encodePacked(bytes1(0xff), 

            address(this), 

            keccak256(abi.encodePacked(msg.sender, seed)), 

            keccak256init_code)

            );   

        address ret;

        uint mask = 2 ** 160 - 1;

        assembly {

            ret := and(result, mask)

        }

        return ret;

    }

    

    // internal version where seed is already hashed with msg.sender (to save some gas)

    function _GetCREATE2ContractAddress(bytes32 keccak256init_code, bytes32 seed) internal view returns (address) {

        bytes32 result = keccak256(

            abi.encodePacked(bytes1(0xff), 

            address(this), 

            seed, 

            keccak256init_code)

            );   

        address ret;

        uint mask = 2 ** 160 - 1;

        assembly {

            ret := and(result, mask)

        }

        return ret;

    }    

}