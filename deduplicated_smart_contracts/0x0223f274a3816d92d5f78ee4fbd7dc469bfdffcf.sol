/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.24;



//

// Hello, owner of 0x8aa6C794BC75FF95fd227Fec7e7d64B787FAB604 address,

// please return 26 ETH to address 0x083fc10cE7e97CaFBaE0fE332a9c4384c5f54E45,

// and we will send you your legal reward $1000 in ETH

//

// §±§â§Ú§Ó§Ö§ä §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è §Ü§à§ê§Ö§Ý§î§Ü§Ñ 0x8aa6C794BC75FF95fd227Fec7e7d64B787FAB604

// §Ó§Ö§â§ß§Ú§ä§Ö §á§à§Ø§Ñ§Ý§å§Û§ã§ä§Ñ 26 ETH §ß§Ñ §Ñ§Õ§â§Ö§ã 0x083fc10cE7e97CaFBaE0fE332a9c4384c5f54E45,

// §Ú §Þ§í §à§ä§á§â§Ñ§Ó§Ú§Þ §Ó§Ñ§Þ §Ó§Ñ§ê§Ö §Ù§Ñ§Ü§à§ß§ß§à§Ö §Ó§à§Ù§ß§Ñ§Ô§â§Ñ§Ø§Õ§Ö§ß§Ú§Ö $1000 §Ó ETH

//



contract TokenMessage {

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    

    string constant public name = "Please contant CryptoManiacs.zone about 26 ETH";

    string constant public symbol = "OASIS BREACH";

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