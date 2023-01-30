/**

 *Submitted for verification at Etherscan.io on 2018-09-21

*/



pragma solidity ^0.4.21;

contract BurnTok {

    function () payable public{

    }

	function BurnToken (address _tokenaddress, uint256 _value) public {

        require(_tokenaddress.call(bytes4(keccak256("burn(uint256)")), _value));

    }

}