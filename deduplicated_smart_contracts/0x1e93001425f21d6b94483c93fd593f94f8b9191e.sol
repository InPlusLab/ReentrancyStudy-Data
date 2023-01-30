/**
 *Submitted for verification at Etherscan.io on 2019-10-16
*/

pragma solidity ^0.5.0;

contract IChest {
        function purchaseFor(address user, uint count, address referrer) public payable;

}


contract Purchase {
    
    function purchaseFor(IChest chest, uint price, address[] memory users, uint count) public payable {
        require(users.length > 0, "");
        for (uint i = 0; i < users.length; i++) {
            chest.purchaseFor.value(price)(users[i], count, address(0));
        }
    }
    
}