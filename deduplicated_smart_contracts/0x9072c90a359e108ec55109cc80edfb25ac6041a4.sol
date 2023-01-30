/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity ^0.5.1;



/**

 * Followine - Wine. More info www.followine.io

**/



contract WineInformation {



	struct wineInfo {

		string manifacturer;

		uint256 wineYear;

		string origin;

		uint256 activation;

		string name;

		uint256 coil;

	}

	mapping (uint256 => wineInfo) wines;

	address owner;



	constructor() public {

        owner = msg.sender;

    }



	modifier onlyOwner() {

		require(msg.sender == owner);

		_;

	}



	function changeOwner(address _newOwner) public onlyOwner {

        owner = _newOwner;

    }



	function addWine(uint256 _id, string memory _manifacturer, uint256 _wineYear, string memory _origin, uint256 _activation, string memory _name, uint256 _coil) public onlyOwner {

		wines[_id].manifacturer = _manifacturer;

		wines[_id].wineYear = _wineYear;

		wines[_id].origin = _origin;

		wines[_id].activation = _activation;

		wines[_id].name = _name;

		wines[_id].coil = _coil;

	}



	function getWine(uint256 _id) public view returns(string memory manifacturer, uint256 wineYear, string memory origin, uint256 activation, string memory name, uint256 coil){

		return (wines[_id].manifacturer,wines[_id].wineYear,wines[_id].origin,wines[_id].activation,wines[_id].name,wines[_id].coil);

	}



}