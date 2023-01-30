pragma solidity ^0.5.0;

import "./Robe.sol";
import "./IRobeSyntaxChecker.sol";

/**
  * @title A simple HTML syntax checker
  * @author Marco Vasapollo <ceo@metaring.com>
  * @author Alessandro Mario Lagana Toschi <alet@risepic.com>
*/
contract RobeHTMLSyntaxChecker is IRobeSyntaxChecker {

    function check(uint256 rootTokenId, uint256 newTokenId, address owner, bytes memory payload, address robeAddress) public view returns(bool) {
       //Extremely trivial and simplistic control coded in less than 30 seconds. We will make a more accurate one later
        require(payload[0] == "<");
        require(payload[1] == "h");
        require(payload[2] == "t");
        require(payload[3] == "m");
        require(payload[4] == "l");
        require(payload[5] == ">");
        return true;
    }
}

/**
  * @title A simple HTML-based Robe NFT
  * 
  * @author Marco Vasapollo <ceo@metaring.com>
  * @author Alessandro Mario Lagana Toschi <alet@risepic.com>
*/
contract RobeHTMLWrapper is Robe {

    constructor() Robe(address(new RobeHTMLSyntaxChecker())) public {
    }

    function mint(string memory html) public returns(uint256) {
        return super.mint(bytes(html));
    }

    function mint(uint256 tokenId, string memory html) public returns(uint256) {
        return super.mint(tokenId, bytes(html));
    }

    function getHTML(uint256 tokenId) public view returns(string memory) {
        return string(super.getContent(tokenId));
    }

    function getCompleteInfoInHTML(uint256 tokenId) public view returns(uint256, address, string memory) {
        (uint256 position, address owner, bytes memory payload) = super.getCompleteInfo(tokenId);
        return (position, owner, string(payload));
    }
}