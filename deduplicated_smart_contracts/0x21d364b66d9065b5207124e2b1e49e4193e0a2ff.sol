/**

 *Submitted for verification at Etherscan.io on 2018-11-05

*/



pragma solidity ^0.4.24;



contract BasicAccessControl {

    address public owner;

    address[] public moderators;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner,"Must be owner!");

        _;

    }



    modifier onlyModerators() {

        if (msg.sender != owner) {

            bool found = false;

            for (uint index = 0; index < moderators.length; index++) {

                if (moderators[index] == msg.sender) {

                    found = true;

                    break;

                }

            }

            require(found,"Must be moderator!");

        }

        _;

    }



    function ChangeOwner(address _newOwner) public onlyOwner {

        if (_newOwner != address(0)) {

            owner = _newOwner;

        }

    }



    function AddModerator(address _newModerator) public onlyOwner {

        if (_newModerator != address(0)) {

            for (uint index = 0; index < moderators.length; index++) {

                if (moderators[index] == _newModerator) {

                    return;

                }

            }

            moderators.push(_newModerator);

        }

    }

    

    function RemoveModerator(address _oldModerator) public onlyOwner {

        uint foundIndex = 0;

        for (; foundIndex < moderators.length; foundIndex++) {

            if (moderators[foundIndex] == _oldModerator) {

                break;

            }

        }

        if (foundIndex < moderators.length) {

            moderators[foundIndex] = moderators[moderators.length-1];

            delete moderators[moderators.length-1];

            moderators.length--;

        }

    }

}



contract DataEdit is BasicAccessControl {

    //var

    struct UserData {

        mapping (string => address) ref;

    }

    mapping (address => UserData) userData;

    mapping (address => mapping(string=>uint)) promotion;



    //modifier

    modifier onlyNew(string _gameName){

        require(userData[msg.sender].ref[_gameName] == 0x0,"Can't change reference address");

        _;

    }



    //set

    function setUserRef(address _address, address _refAddress, string _gameName) public;

    function changeAmountPromotion(string _gameName, address _address, uint _amount, bool isPlus) public;

    //get

    function getUserRef(address _address, string _gameName) public view returns(address);

    function getAmountPromotionByAddress(string _gameName, address _address) public view returns (uint);

}



contract UserData_BrickGame is DataEdit {

    function() public payable {

        revert("Transactions is not allow!");

    }



    function setUserRef(address _address, address _refAddress, string _gameName) public onlyNew(_gameName) onlyModerators {

        userData[_address].ref[_gameName] = _refAddress;

    }



    function getUserRef(address _address, string _gameName) public view returns(address){

        return userData[_address].ref[_gameName];

    }

    function changeAmountPromotion(string _gameName, address _address, uint _amount, bool isPlus) public onlyModerators {

        if(isPlus) {

            promotion[_address][_gameName] = promotion[_address][_gameName] + _amount;

        } else {

            require(promotion[_address][_gameName] >= _amount);

            promotion[_address][_gameName] = promotion[_address][_gameName] - _amount;

        }

    }



    function getAmountPromotionByAddress(string _gameName, address _address) public view returns (uint){

        return promotion[_address][_gameName];

    }

}