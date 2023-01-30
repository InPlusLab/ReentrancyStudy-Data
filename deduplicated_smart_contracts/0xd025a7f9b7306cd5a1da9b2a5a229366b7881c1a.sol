/**

 *Submitted for verification at Etherscan.io on 2019-02-01

*/



pragma solidity 0.4.25;



// §¬§à§ß§ã§ä§â§Ñ§Ü§ä.

contract MyMileage {



    // §£§Ý§Ñ§Õ§Ö§Ý§Ö§è §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ.

    address private owner;



    // §°§ä§à§Ò§â§Ñ§Ø§Ö§ß§Ú§Ö §ç§Ö§ê §ã§å§Þ§Þ §æ§Ñ§Û§Ý§à§Ó §Ó §Õ§Ñ§ä§å.

    mapping(bytes32 => uint) private map;



    // §®§à§Õ§Ú§æ§Ú§Ü§Ñ§ä§à§â §Õ§à§ã§ä§å§á§Ñ "§ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è".

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    // §¬§à§ß§ã§ä§â§å§Ü§ä§à§â.

    constructor() public {

        owner = msg.sender;

    }



    // §¥§à§Ò§Ñ§Ó§Ý§Ö§ß§Ú§Ö §Ù§Ñ§á§Ú§ã§Ú.

    function put(bytes32 fileHash) onlyOwner public {



        // §±§â§à§Ó§Ö§â§Ü§Ñ §á§å§ã§ä§à§Ô§à §Ù§ß§Ñ§é§Ö§ß§Ú§ñ §á§à §Ü§Ý§ð§é§å.

        require(free(fileHash));



        // §µ§ã§ä§Ñ§ß§à§Ó§Ü§Ñ §Ù§ß§Ñ§é§Ö§ß§Ú§ñ.

        map[fileHash] = now;

    }



    // §±§â§à§Ó§Ö§â§Ü§Ñ §ß§Ñ§Ý§Ú§é§Ú§ñ §Ù§ß§Ñ§é§Ö§ß§Ú§ñ.

    function free(bytes32 fileHash) view public returns (bool) {

        return map[fileHash] == 0;

    }



    // §±§à§Ý§å§é§Ö§ß§Ú§Ö §Ù§ß§Ñ§é§Ö§ß§Ú§ñ.

    function get(bytes32 fileHash) view public returns (uint) {

        return map[fileHash];

    }



    // §±§à§Ý§å§é§Ö§ß§Ú§Ö §Ü§à§Õ§Ñ §á§à§Õ§ä§Ó§Ö§â§Ø§Õ§Ö§ß§Ú§ñ

    // §Ó §Ó§Ú§Õ§Ö §ç§Ö§ê§Ñ §Ò§Ý§à§Ü§Ñ.

    function getConfirmationCode() view public returns (bytes32) {

        return blockhash(block.number - 6);

    }

}