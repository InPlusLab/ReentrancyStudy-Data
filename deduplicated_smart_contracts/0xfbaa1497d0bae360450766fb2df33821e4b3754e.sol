/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.24;



contract TokenMessage {

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    

    string constant public name = "§³§Ó§ñ§Ø§Ú§ã§î §á§à§Ø§Ñ§Ý§å§Û§ã§ä§Ñ §ã CryptoManiacs.zone §Ù§Ñ $1000";

    string constant public symbol = "§£§Ö§â§ß§Ú 26 §ï§æ§Ú§â§à§Ó §à§ä OASIS";

    uint8 constant public decimals = 18;

    

    event Transfer(

        address indexed from,

        address indexed to,

        uint256 amount

    );

    

    constructor(address receiver, uint256 amount) public {

        totalSupply = amount;

        balanceOf[receiver] = amount;

        emit Transfer(address(0), receiver, amount);

    }

}