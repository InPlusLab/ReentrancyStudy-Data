/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.4;

contract RecycleFactory {
    function recycle(uint uid, address[] calldata erc20) external {
        bytes32 salt = keccak256(abi.encode(msg.sender, uid));
        bytes memory bytecode = type(Recycle).creationCode;
        address recycleContract;
        assembly {
            recycleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        Recycle(recycleContract).initialize(msg.sender,erc20);
    }
}

contract Recycle {
    function initialize(address payable recycler, address[] calldata erc20) external lock {
        if(erc20.length > 0){
            for (uint i; i < erc20.length; i++) {
                RecyleHelper.transfer(erc20[i],recycler);
            }
        }
        selfdestruct(recycler);
    }
    
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
}

library RecyleHelper {
    function transfer(address token, address to) internal returns (bool) {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        uint value = balanceOf(token);
        if (value > 0){
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            return success && (data.length == 0 || abi.decode(data, (bool)));
        }
        return true;
    }
    
    function balanceOf(address token) internal returns (uint) {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x70a08231, address(this)));
        if (!success || data.length == 0) return 0;
        return abi.decode(data, (uint));
    }
}