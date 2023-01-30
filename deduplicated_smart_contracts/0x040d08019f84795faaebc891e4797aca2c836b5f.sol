/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity ^0.4.24;



// File: contracts/CDComicsClueConverter.sol



contract ICDComicsClue {

    function clues(uint id) public view returns (uint, uint);

    function ownerOf(uint256 _tokenId) public view returns (address);

}



contract CDComicsClueConverter {

    address CDComicsClueAddress;



    constructor(address _CDComicsClueAddress) public {

        CDComicsClueAddress = _CDComicsClueAddress;

    }



    function artefacts(uint id) public view returns (uint, uint) {

        return ICDComicsClue(CDComicsClueAddress).clues(id);

    }



    function ownerOf(uint _tokenId) public view returns (address) {

        return ICDComicsClue(CDComicsClueAddress).ownerOf(_tokenId);

    }

}