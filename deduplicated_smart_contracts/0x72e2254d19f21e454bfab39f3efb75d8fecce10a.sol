/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity ^0.4.24;



// File: contracts/CDClueConverter.sol



contract ICDClue {

    function clues(uint id) public view returns (uint, uint);

    function ownerOf(uint256 _tokenId) public view returns (address);

}



contract CDClueConverter {

    address CDClueAddress;



    constructor(address _CDClueAddress) public {

        CDClueAddress = _CDClueAddress;

    }



    function artefacts(uint id) public view returns (uint, uint) {

        return ICDClue(CDClueAddress).clues(id);

    }



    function ownerOf(uint _tokenId) public view returns (address) {

        return ICDClue(CDClueAddress).ownerOf(_tokenId);

    }

}