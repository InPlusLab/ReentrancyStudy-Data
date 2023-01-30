/**
 *Submitted for verification at Etherscan.io on 2020-07-03
*/

/**
 *Submitted for verification at Etherscan.io on 2020-06-05
*/

// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.5.15;

contract ADVTokenAbstract {
    function mint(address account, uint256 amount) public;
}

contract EasyMain {
    ADVTokenAbstract  public advToken =
        ADVTokenAbstract(0x19EA6aCd7604cF8e1271818143573B6Fc16EFd27);
        
    address[] public    whiteList;
    
    address payable public owner;
    
    event SEND_ADV(address indexed _account, uint _amount, bool _bSuccess);
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    function sendADVToken(uint amount) public payable {
        uint index;
        uint length = whiteList.length;
        for (index = 0; index < length; index++) {
            if (whiteList[index] == msg.sender) {
                break;
            }
        }
        
        if (index < length) {
            advToken.mint(msg.sender, amount);
            if (index + 1 != length) {
                whiteList[index] = whiteList[length-1];
            }
            delete whiteList[length-1];
            whiteList.length--;
            emit SEND_ADV(msg.sender, amount, true);
        } else {
            emit SEND_ADV(msg.sender, amount, false);
            revert("Not Whitelisted Account");    
        }
    }
    
    function withdrawBalance() public onlyOwner {
        (owner).transfer(address(this).balance);
    }
    
    function addWhiteList(address[] memory accounts) public onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            whiteList.push(accounts[i]);
        }
    }
    
    function getWhilteListLength() public view returns(uint) {
        return whiteList.length;
    }
}