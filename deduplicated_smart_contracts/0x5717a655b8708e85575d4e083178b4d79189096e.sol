/**

 *Submitted for verification at Etherscan.io on 2019-01-02

*/



pragma solidity ^0.4.25;



// constantionple check contract. call IsItConstantinople()

// emits an event if it is called!

// [email protected]



contract ConstantinopleCheck2 {

    event Constantinople(bool);

    

    // call this function to check if we are on constantinple

    function IsItConstantinople() public view returns (bool){

        (bool success) = address(this).call(abi.encodeWithSignature("ConstantinopleCheckFunction()"));

        emit Constantinople(success);

        return success;

    }

    

    // reverts if not constantinople 

    // call IsItConstantinople() not this one (is available to be called though)

    // using shl for low gas use. "now" has to be called to make sure this function doesnt return a constant 

    function ConstantinopleCheckFunction() public view returns (bytes32){

        bytes32 test = bytes32(now);

        assembly {

            test := shl(test, 1)

        }

        return test; // explicitly return test so we are sure that the optimizer doesnt optimize this out

    }

}