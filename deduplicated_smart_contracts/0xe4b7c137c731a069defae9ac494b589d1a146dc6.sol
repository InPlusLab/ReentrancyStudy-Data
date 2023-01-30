/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity ^0.5.1;



/**

 * Followine - Coil. More info www.followine.io

**/



contract CoilChecker {



	mapping (string => bool) coils;

	address owner;



	constructor() public {

        owner = msg.sender;

    }



	modifier onlyOwner() {

		require(msg.sender == owner);

		_;

	}



    function addCoil(string memory _id) public onlyOwner {

        coils[_id] = true;

    }



	function changeOwner(address _newOwner) public onlyOwner {

        owner = _newOwner;

    }



	function removeCoil(string memory _id) public onlyOwner {

        coils[_id] = false;

    }



	function getCoil(string memory _id) public view returns (bool coilStatus) {

        return coils[_id];

    }



}