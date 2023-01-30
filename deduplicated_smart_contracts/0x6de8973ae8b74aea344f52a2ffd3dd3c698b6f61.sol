/**
 *Submitted for verification at Etherscan.io on 2020-07-03
*/

// File: contracts/SalesManagement.sol

pragma solidity 0.6.4;

contract SalesManagement {

  address payable private adminAddress;
  uint64 minPrice;

  mapping(string => bool) contents;
  mapping(string => mapping (address => bool)) private buyers;
  mapping(string => address payable) private sellers;

  event BuyContents(string cid, uint64 price, address seller, address buyer);

  function initialize() public {
    adminAddress = 0x4aBF3F2730963Aa034E9A146D1018928E1bb6485;
    minPrice = 1;
  }

  function buyContents(
    bytes32 r,
    bytes32 s,
    uint8 v,
    bytes calldata metadata
  ) external payable {
    bytes32 metahash = keccak256(metadata);
    require(ecrecover(metahash, v, r, s) == adminAddress, 'Signer address is not admin address');

    bytes memory bytesPrice = bytes(metadata[78:]);
    uint64 price = abi.decode(bytesPrice, (uint64));
    require(price > minPrice);
    require(price >= msg.value, 'The payment amount is small');

    bytes memory bytesCid = bytes(metadata[:46]);
    string memory cid = string(bytesCid);

    bytes memory bytesSeller = bytes(metadata[46:78]);
    address payable seller = abi.decode(bytesSeller,(address));
    
    if(!contents[cid]) {
      setSeller(cid, seller);
      contents[cid] = true;
    }

    buyers[cid][msg.sender] = true;
    sellers[cid].transfer(msg.value);

    emit BuyContents(cid, price, seller, msg.sender);
  }

  function setSeller(string memory cid, address payable seller) private {
    sellers[cid] = seller;
  }

  function isBought(string memory cid, address buyer) public view returns (bool) {
    return buyers[cid][buyer];
  }

  function changeMinPrice(uint64 _minPrice) public {
    minPrice = _minPrice;
  }
}