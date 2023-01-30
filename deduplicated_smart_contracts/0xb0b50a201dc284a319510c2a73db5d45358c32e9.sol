/**

 *Submitted for verification at Etherscan.io on 2019-06-13

*/



pragma solidity ^0.5.0;



contract freedomStatement {

    

    string public statement = "https://ipfs.globalupload.io/QmfEnSNTHTe9ut6frhNsY16rXhiTjoGWtXozrA66y56Pbn";

    mapping (address => bool) internal consent;

    event wearehere(string statement);

    

    constructor () public {

        emit wearehere(statement);

    }

        

    function isHuman(address addr) internal view returns (bool) {

        uint size;

        assembly { size := extcodesize(addr) }

        return size == 0;

    }



    function () external {

        require(isHuman(msg.sender),"no robot");//Don't want to use tx.origin because that will cause an interoperability problem

        consent[msg.sender] = true;

    }

    

    function check(address addr) public view returns (bool){

        return(consent[addr]);

    }

}