pragma solidity ^0.4.24;



import "./LTRFactory.sol";



contract LTRConceptArtLoop {

    

	struct LTRGiftAddress	{

        address _address;

		uint _assetGiven; 

			// 1: Should give Y01

			// 2: Should give Y02

			// 3: Should give Y03

			// 4: Already gave Y01

			// 5: Already gave Y02

			// 6: Already gave Y03

    }

	

    LTRGiftAddress[] public _LTRGiftCampaign;

	

	mapping (address => uint) public _arrayIdsPlusOne;

	

	address public _owner;

	ItemFactory _factoryContract;

	modifier onlyOwner() {

		require(msg.sender == _owner);

		_;

	}

	

	constructor (address _factoryContractAddress) public {

        _owner = msg.sender;

		_factoryContract = ItemFactory(_factoryContractAddress);

    }

	

	function changeOwner(address _newOwner) public onlyOwner returns (bool) {

		_owner = _newOwner;

		

		return true;

	}

	

	function transferOwnershipOfFactory(address _newOwner) public onlyOwner returns (bool) {

		_factoryContract.transferOwnership(_newOwner);

		return true;

	}

	

	

	function addNewAddress(address _newAddress, uint _assetIDtoGive) public onlyOwner returns (uint) {

		require(_arrayIdsPlusOne[_newAddress] == 0);

		

		LTRGiftAddress memory _newLTRGiftAddress = LTRGiftAddress(_newAddress, _assetIDtoGive);

		uint id = (_LTRGiftCampaign.push(_newLTRGiftAddress) - 1);

		_arrayIdsPlusOne[_newAddress] = id+1;

		return id;

	}

	

	function sendToAddress(address _address) public onlyOwner returns (bool) {

		require(_arrayIdsPlusOne[_address] != 0);

		require(_LTRGiftCampaign[_arrayIdsPlusOne[_address]-1]._assetGiven < 4);

		

		// HERE, call the factory contract

		

        _factoryContract.mint(_LTRGiftCampaign[_arrayIdsPlusOne[_address]-1]._assetGiven - 1, _address);

		

		_LTRGiftCampaign[_arrayIdsPlusOne[_address]-1]._assetGiven += 3;

		

		return true;

    }

    

    function addAddressAndSend(address _newAddress, uint _assetIDtoGive) public onlyOwner returns (bool) {

        

        require(_arrayIdsPlusOne[_newAddress] == 0);

		

		LTRGiftAddress memory _newLTRGiftAddress = LTRGiftAddress(_newAddress, _assetIDtoGive);

		uint id = (_LTRGiftCampaign.push(_newLTRGiftAddress) - 1);

		_arrayIdsPlusOne[_newAddress] = id+1;

        

		require(_LTRGiftCampaign[_arrayIdsPlusOne[_newAddress]-1]._assetGiven < 4);

		

		// HERE, call the factory contract

		

        _factoryContract.mint(_LTRGiftCampaign[_arrayIdsPlusOne[_newAddress]-1]._assetGiven - 1, _newAddress);

		

		_LTRGiftCampaign[_arrayIdsPlusOne[_newAddress]-1]._assetGiven += 3;

		

		return true;

    }

}