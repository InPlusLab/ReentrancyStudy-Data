/**

 *Submitted for verification at Etherscan.io on 2019-04-11

*/



pragma solidity >=0.4.21 <0.6.0;



//ERC780 implementaion

contract EthereumClaimsRegistry {



    mapping(address => mapping(address => mapping(bytes32 => bytes32))) public registry;



    event ClaimSet(

        address indexed issuer,

        address indexed subject,

        bytes32 indexed key,

        bytes32 value,

        uint updatedAt);



    event ClaimRemoved(

        address indexed issuer,

        address indexed subject,

        bytes32 indexed key,

        uint removedAt);



    // create or update clams

    function setClaim(address subject, bytes32 key, bytes32 value) public {

        registry[msg.sender][subject][key] = value;

        emit ClaimSet(msg.sender, subject, key, value, now);

    }



    function setSelfClaim(bytes32 key, bytes32 value) public {

        setClaim(msg.sender, key, value);

    }



    function getClaim(address issuer, address subject, bytes32 key) public view returns(bytes32) {

        return registry[issuer][subject][key];

    }



    function removeClaim(address issuer, address subject, bytes32 key) public {

        require(msg.sender == issuer);

        delete registry[issuer][subject][key];

        emit ClaimRemoved(msg.sender, subject, key, now);

    }

}