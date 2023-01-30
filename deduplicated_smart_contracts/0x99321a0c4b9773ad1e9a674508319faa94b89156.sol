/**

 *Submitted for verification at Etherscan.io on 2019-02-10

*/



pragma solidity >=0.4.0 <0.6.0;



contract HireGoListings {



    struct HireGoListing {

        address user;

        address appOwner;

    }



    mapping(bytes32 => HireGoListing) public listings;



    uint public numberOfListings = 0;



    function addListing(address _thirdPartyOwner, bytes32 _ipfs) public {

        HireGoListing memory listing = HireGoListing({user:msg.sender, appOwner:_thirdPartyOwner});

        listings[_ipfs] = listing;

        numberOfListings++;

    }



    function adminDelete(bytes32 _ipfs) public {

        require(listings[_ipfs].user == msg.sender);

        delete listings[_ipfs];

        numberOfListings--;

    }



    function deleteListing(bytes32 _ipfs) public {

        require(listings[_ipfs].appOwner == msg.sender);

        delete listings[_ipfs];

        numberOfListings--;

    }

}