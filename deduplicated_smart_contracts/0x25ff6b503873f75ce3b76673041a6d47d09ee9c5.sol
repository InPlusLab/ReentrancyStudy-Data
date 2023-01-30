/**
   _____       _     _ _       _____      _
  |  __ \     | |   (_) |     / ____|    | |
  | |__) |   _| |__  _| | __ | |    _   _| |__   ___
  |  _  / | | | '_ \| | |/ / | |   | | | | '_ \ / _ \
  | | \ \ |_| | |_) | |   <  | |___| |_| | |_) |  __/
  |_|  \_\__,_|_.__/|_|_|\_\  \_____\__,_|_.__/ \___|

*/

// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC721Enumerable.sol";

contract RubikCube is Ownable, ERC721Enumerable {
  using Strings for uint256;

  uint256 public constant mintPrice = 0.03 ether;
  uint256 public constant supplyLimit = 1000;
  uint256 public saleStartTime = 1631034420;
  string public baseURI;
  uint256 private _reserved = 40; // for marketing
  address private creatorAddress = 0x1aFB99F41c4ebEA2279ACE75875737fa067759AE;

  constructor(
    string memory inputBaseUri
  ) ERC721("Rubiks Cube", "RKCUBE") {
    baseURI = inputBaseUri;
    _safeMint( creatorAddress, 0); // The team gets the first cube
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  function setBaseURI(string calldata newBaseUri) external onlyOwner {
    baseURI = newBaseUri;
  }

  function setStart(uint256 datetime) external onlyOwner {
    saleStartTime = datetime;
  }

  function mintActive() public view returns(bool) {
    return block.timestamp > saleStartTime && saleStartTime > 0;
  }


  function mint(uint256 num) external payable {
    uint256 supply = totalSupply();
    require(mintActive(), "Sale is not active");
    require( num < 21, "Too many tokens for one transaction" );
    require( supply + num < supplyLimit - _reserved, "Not enough tokens left" );
    require( msg.value >= mintPrice * num, "Insufficient payment" );

    for(uint256 i; i < num; i++){
      _safeMint( msg.sender, supply + i );
    }
  }

  function giveaway(address _to, uint256 _amount) external onlyOwner() {
    require( _amount <= _reserved, "Exceeds reserved token supply" );

    uint256 supply = totalSupply();
    for(uint256 i; i < _amount; i++){
      _safeMint( _to, supply + i );
    }

    _reserved -= _amount;
  }


  function withdraw() external onlyOwner {
    require(address(this).balance > 0, "No balance to withdraw");
    (bool success, ) = creatorAddress.call{value: address(this).balance}("");
    require(success, "Withdrawal failed");
  }

  function tokensOwnedBy(address wallet) external view returns(uint256[] memory) {
    uint tokenCount = balanceOf(wallet);

    uint256[] memory ownedTokenIds = new uint256[](tokenCount);
    for(uint i = 0; i < tokenCount; i++){
      ownedTokenIds[i] = tokenOfOwnerByIndex(wallet, i);
    }

    return ownedTokenIds;
  }
}