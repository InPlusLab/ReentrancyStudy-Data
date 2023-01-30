/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.4.24;

// File: contracts/interfaces/EscrowReserveInterface.sol

interface EscrowReserveInterface {
  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);
  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool);
  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);
  function burnERC20(uint256 _amount, address _tokenAddress) external returns (bool);
}

// File: contracts/interfaces/BurnableERC20.sol

// @title An interface to interact with Burnable ERC20 tokens 
interface BurnableERC20 { 

  function allowance(address tokenOwner, address spender) external view returns (uint remaining);
  
  function burnFrom(address _tokenHolder, uint _amount) external returns (bool success); 

  function burn(uint _amount) external returns (bool success); 
  
  function totalSupply() external view returns (uint256);

  function balanceOf(address _who) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  event LogBurn(address indexed _spender, uint256 _value); 
}

// File: contracts/database/EscrowReserve.sol

interface Events {
  function transaction(string _message, address _from, address _to, uint _amount, address _token)  external;
}
interface DB {
  function addressStorage(bytes32 _key) external view returns (address);
  function uintStorage(bytes32 _key) external view returns (uint);
  function setUint(bytes32 _key, uint _value) external;
  function deleteUint(bytes32 _key) external;
  function setBool(bytes32 _key, bool _value) external;
  function boolStorage(bytes32 _key) external view returns (bool);
}

contract EscrowReserve is EscrowReserveInterface{
  DB private database;
  Events private events;

  constructor(address _database, address _events) public {
    database = DB(_database);
    events = Events(_events);
  }
  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "AssetManagerEscrow"))));
    BurnableERC20 erc20 = BurnableERC20(_tokenAddress);
    require(erc20.balanceOf(this) >= _amount);
    require(erc20.transfer(_receiver, _amount));
    events.transaction("ERC20 withdrawn from escrow reserve", address(this), _receiver, _amount, _tokenAddress);
    return true;
  }
  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "AssetManagerEscrow"))) ||
            msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleGeneratorETH"))) ||
            msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleGeneratorERC20"))));
    require(BurnableERC20(_tokenAddress).transferFrom(_payer, address(this), _amount));
    events.transaction("ERC20 received by escrow reserve", _payer, address(this), _amount, _tokenAddress);
  }
  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "AssetManagerEscrow"))));
    BurnableERC20(_tokenAddress).approve(_receiver, _amount); //always returns true
    events.transaction("ERC20 approval given by escrow reserve", address(this), _receiver, _amount, _tokenAddress);
    return true;
  }
  function burnERC20(uint256 _amount, address _tokenAddress) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "AssetManagerEscrow"))));
    require(BurnableERC20(_tokenAddress).burn(_amount));
    events.transaction("ERC20 burnt by escrow reserve", address(this), address(0), _amount, _tokenAddress);
    return true;
  }
}