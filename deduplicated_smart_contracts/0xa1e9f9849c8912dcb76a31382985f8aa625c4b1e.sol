/**

 *Submitted for verification at Etherscan.io on 2018-11-25

*/



pragma solidity 0.4.25;



contract PackInterface {

    

    function purchaseFor(address user, uint16 packCount, address referrer)  public payable;

}



contract MultiPurchaser {

    

    function purchaseFor(address pack, address[] memory users, uint16 packCount, address referrer) public payable {

        for (uint i = 0; i < users.length; i++) {

            PackInterface(pack).purchaseFor(users[i], packCount, referrer);

        }

    }

    

}