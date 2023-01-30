/**

 *Submitted for verification at Etherscan.io on 2018-11-16

*/



// solhint-disable max-line-length

// @title A contract to blacklist addresses



/* Deployment:

Owner: 0x33a7ae7536d39032e16b0475aef6692a09727fe2

Owner Ropsten testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29

Owner private testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29

Address: 0xbb6b72c396b5a690a84b5f3fd0ec7ed28985ab17

Address Ropsten testnet: 0x6cd4a37da53f9a868c7447b00aa6652e1b07182b

Address private testnet: 0x40ac673e2b2683ff6371880477eeab71fc6ed428

ABI: [{"constant":false,"inputs":[{"name":"_dataInfo","type":"string"},{"name":"_version","type":"uint256"},{"name":"_who","type":"address"}],"name":"add","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"moderator","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_moderator","type":"address"}],"name":"setModerator","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"contentCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"blacklisted","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_dataInfo","type":"string"},{"name":"_version","type":"uint256"},{"name":"_who","type":"address"}],"name":"remove","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":false,"stateMutability":"nonpayable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"dataInfo","type":"string"},{"indexed":true,"name":"version","type":"uint256"},{"indexed":true,"name":"who","type":"address"},{"indexed":false,"name":"eventType","type":"uint16"}],"name":"LogEvent","type":"event"}]

Optimized: yes

Solidity version: v0.4.24

*/



// solhint-enable max-line-length



pragma solidity 0.4.24;





contract Blacklist {



    //enum EventTypes

    uint16 constant internal NONE = 0;

    uint16 constant internal ADD = 1;

    uint16 constant internal REMOVE = 2;



    address public owner;

    address public moderator;

    mapping (address => bool) public blacklisted;

    uint public contentCount = 0;

    

    event LogEvent(string dataInfo, uint indexed version, address indexed who, uint16 eventType);



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    modifier onlyModeratorOrOwner {

        require((msg.sender == owner) || (msg.sender == moderator));

        _;

    }



    constructor() public {

        owner = msg.sender;

        moderator = owner;

    }



    // @notice fallback function, don't allow call to it

    function () public {

        revert();

    }

    

    function kill() public onlyOwner {

        selfdestruct(owner);

    }



    function setModerator(address _moderator) public onlyOwner {

        moderator = _moderator;

    }



    function add(string _dataInfo, uint _version, address _who) public onlyModeratorOrOwner {

        blacklisted[_who] = true;

        contentCount++;

        emit LogEvent(_dataInfo, _version, _who, ADD);

    }



    function remove(string _dataInfo, uint _version, address _who) public onlyModeratorOrOwner {

        blacklisted[_who] = false;

        contentCount++;

        emit LogEvent(_dataInfo, _version, _who, REMOVE);

    }

}