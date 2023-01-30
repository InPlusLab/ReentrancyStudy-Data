pragma solidity 0.5.11;

import "./Withdrawer.sol";


contract Fabric {
    function createContract(uint256 salt) public {
        bytes memory code = type(Withdrawer).creationCode;
        assembly {
            let codeSize := mload(code)
            let newAddr := create2(0, add(code, 32), codeSize, salt)
        }
    }
}
