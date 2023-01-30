/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.4.24;

// File: contracts/interfaces/CrowdsaleReserveInterface.sol

interface CrowdsaleReserveInterface {
  function issueETH(address _receiver, uint256 _amount) external returns (bool);
  function receiveETH(address _payer) external payable returns (bool);
  function refundETHAsset(address _asset, uint256 _amount) external returns (bool);
  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);
  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool);
  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);
  function refundERC20Asset(address _asset, uint256 _amount, address _tokenAddress) external returns (bool);
}

// File: contracts/interfaces/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface ERC20 {
  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address _who) external view returns (uint256);

  function allowance(address _owner, address _spender) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/interfaces/DividendInterface.sol

interface DividendInterface{
  function issueDividends(uint _amount) external payable returns (bool);

  // @dev Total number of tokens in existence
  function totalSupply() external view returns (uint256);

  function getERC20() external view returns (address);
}

// File: contracts/database/CrowdsaleReserve.sol

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

contract CrowdsaleReserve is CrowdsaleReserveInterface{
  DB private database;
  Events private events;

  constructor(address _database, address _events) public {
    database = DB(_database);
    events = Events(_events);
  }
  function issueETH(address _receiver, uint256 _amount) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleETH"))), 'Contract not authorized');
    require(address(this).balance >= _amount, 'Not enough funds');
    _receiver.transfer(_amount);
    events.transaction("Ether withdrawn from crowdsale reserve", address(this), _receiver, _amount, address(0));
    return true;
  }
  function receiveETH(address _payer) external payable returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleETH"))), 'Contract not authorized');
    events.transaction("Ether received by crowdsale reserve", address(this), _payer, msg.value, address(0));
    return true;
  }
  function refundETHAsset(address _asset, uint256 _amount) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleETH"))), 'Contract not authorized');
    require(DividendInterface(_asset).issueDividends.value(_amount)(_amount), 'Dividend issuance failed');
    events.transaction("Asset issued refund by crowdsale reserve", _asset, address(this), _amount, address(0));
    return true;
  }
  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleERC20"))), 'Contract not authorized');
    ERC20 erc20 = ERC20(_tokenAddress);
    require(erc20.balanceOf(this) >= _amount, 'Not enough funds');
    require(erc20.transfer(_receiver, _amount), 'Transfer failed');
    events.transaction("ERC20 withdrawn from crowdsale reserve", address(this), _receiver, _amount, _tokenAddress);
    return true;
  }
  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleERC20"))), 'Contract not authorized');
    require(ERC20(_tokenAddress).transferFrom(_payer, address(this), _amount), 'Transfer failed');
    events.transaction("ERC20 received by crowdsale reserve", _payer, address(this), _amount, _tokenAddress);
  }
  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) public returns (bool){
    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked("contract", "CrowdsaleERC20"))), 'Contract not authorized');
    ERC20(_tokenAddress).approve(_receiver, _amount); //always returns true
    events.transaction("ERC20 approval given by crowdsale reserve", address(this), _receiver, _amount, _tokenAddress);
    return true;
  }
  function refundERC20Asset(address _asset, uint256 _amount, address _tokenAddress) external returns (bool){
    approveERC20(_asset, _amount, _tokenAddress);
    require(DividendInterface(_asset).issueDividends(_amount), 'Dividend issuance failed');
    events.transaction("Asset issued refund by crowdsale reserve", _asset, address(this), _amount, _tokenAddress);
    return true;
  }
}