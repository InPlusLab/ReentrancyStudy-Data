//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Water.sol";

contract Snowflake is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    mapping(uint256 => uint256) public mintTime;
    Water public meltWater;

    uint256 constant springStart = 1614556800;

    constructor() ERC721("Snowflake", "SFL") {
    }

    function setWater(address _address) public {
      require(meltWater == Water(0));
      meltWater = Water(_address);
    }

    function mint() public returns (uint256) {
      require(isWinter());
      
      _counter.increment();
      uint256 i = _counter.current();
      bytes32 idBytes = keccak256(abi.encode(blockhash(block.number - 1), i, address(this)));
      uint256 id = uint256(idBytes);
      _mint(msg.sender, id);

      mintTime[id] = block.timestamp;
      
      return id;
    }

    function burn(uint256 id) public {
      require(_exists(id));

      address tokenOwner = ownerOf(id);
      require(isMelted(id) || msg.sender == tokenOwner);

      _burn(id);
      meltWater.mint(tokenOwner, 100 ether);
    }

    function isMelted(uint256 id) public view returns (bool) {
      require(_exists(id));
      return block.timestamp >= getMeltTime(id) || !isWinter();
    }

    function isWinter() public view returns (bool) {
      return block.timestamp < springStart;
    }

    function exists(uint256 id) public view returns (bool) {
      return _exists(id);
    }

    function getLifeTime(uint256 id) public view returns (uint256) {
      require(_exists(id));
      bytes32 r = keccak256(abi.encode(id, 123));
      return (2 weeks) + (uint256(r) % (2 weeks));
    }

    function getMeltTime(uint256 id) public view returns (uint256) {
      require(_exists(id));
      uint256 intrinsicMeltTime = mintTime[id] + getLifeTime(id);
      if (intrinsicMeltTime < springStart) {
        return intrinsicMeltTime;
      } else {
        return springStart;
      }
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
      _setBaseURI(baseURI);
    }
}