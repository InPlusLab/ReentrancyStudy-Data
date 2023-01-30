/**
 *Submitted for verification at Etherscan.io on 2021-09-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/** 
 * XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 * XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  .***   XXXXXXXXXXXXXXXXXX
 * XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  ,*********  XXXXXXXXXXXXXXXX
 * XXXXXXXXXXXXXXXXXXXXXXXXXXXX  ***************  XXXXXXXXXXXXX
 * XXXXXXXXXXXXXXXXXXXXXXXXX  .*******************  XXXXXXXXXXX
 * XXXXXXXXXXXXXXXXXXXXXXX  ***********    **********  XXXXXXXX
 * XXXXXXXXXXXXXXXXXXXX   ***********       ***********  XXXXXX
 * XXXXXXXXXXXXXXXXXX  ***********         ***************  XXX
 * XXXXXXXXXXXXXXXX  ***********           ****    ********* XX
 * XXXXXXXXXXXXXXXX *********      ***    ***      *********  X
 * XXXXXXXXXXXXXXXX  **********  *****          *********** XXX
 * XXXXXXXXXXXX   /////.*************         ***********  XXXX
 * XXXXXXXXX  /////////...***********      ************  XXXXXX
 * XXXXXXX/ ///////////..... /////////   ///////////   XXXXXXXX
 * XXXXXX  /    //////.........///////////////////   XXXXXXXXXX
 * XXXXXXXXXX .///////...........//////////////   XXXXXXXXXXXXX
 * XXXXXXXXX .///////.....//..////  /////////  XXXXXXXXXXXXXXXX
 * XXXXXXX# /////////////////////  XXXXXXXXXXXXXXXXXXXXXXXXXXXX
 * XXXXX   ////////////////////   XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 * XX   ////////////// //////   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 * XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 */
interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface IERC1155 {
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
}

interface INiftyRegistry {
   function isValidNiftySender(address sending_key) external view returns (bool);
}

contract OmnibusProxy {

	address public _omnibus;

	constructor() {
        _omnibus = 0xE052113bd7D7700d623414a0a4585BCaE754E9d5;
	}

    modifier onlyValidSender() {
        address registry = 0x6e53130dDfF21E3BC963Ee902005223b9A202106;
        require(INiftyRegistry(registry).isValidNiftySender(msg.sender), "OmnibusProxy: Invalid msg.sender");
        _;
    }

	function safeTransferFrom721(address smartcontract, address reciever, uint tokenId) public onlyValidSender {
    	IERC721(smartcontract).safeTransferFrom(_omnibus, reciever, tokenId);
	}

	function safeTransferFrom1155(address smartcontract, address reciever, uint _id, uint256 _value, bytes calldata _data) public onlyValidSender {
    	IERC1155(smartcontract).safeTransferFrom(_omnibus, reciever, _id, _value, _data);
	}

	function safeBatchTransferFrom1155(address smartcontract, address reciever, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) public onlyValidSender {
    	IERC1155(smartcontract).safeBatchTransferFrom(_omnibus, reciever, _ids, _values, _data);
	}
	
}