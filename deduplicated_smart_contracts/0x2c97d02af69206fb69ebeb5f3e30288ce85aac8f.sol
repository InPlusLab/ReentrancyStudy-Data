/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title ERC1155 interface
 * @dev see https://github.com/ethereum/EIPs/issues/1155
 */

interface IERC1155 /* is ERC165 */ {
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;

    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}

contract CommonConstants {
    bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; 
    bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; 
    bytes4 constant internal FAILURE = 0x00000000; 
}

contract ElevateSwap is ERC1155TokenReceiver, CommonConstants {
  enum PaymentState {
    Uninitialized,
    PaymentSent,
    ReceivedSpent,
    SenderRefunded
  }

  struct Payment {
    bytes20 paymentHash;
    uint64 lockTime;
    PaymentState state;
  }

  mapping (bytes32 => Payment) public payments;
 
  event PaymentSent(bytes32 id);
  event ReceiverSpent(bytes32 id, bytes32 secret);
  event SenderRefunded(bytes32 id);

  constructor() public { }

  function ethPayment(
    bytes32 _id,
    address _receiver,
    bytes20 _secretHash,
    uint64 _lockTime
  ) external payable {
    require(_receiver != address(0) && msg.value > 0 && payments[_id].state == PaymentState.Uninitialized);

    bytes20 paymentHash = ripemd160(abi.encodePacked(
      _receiver,
      msg.sender,
      _secretHash,
      address(0),
      msg.value,
      uint256(0)
    ));

    payments[_id] = Payment(
      paymentHash,
      _lockTime,
      PaymentState.PaymentSent
    );

    emit PaymentSent(_id);
  }

  function erc20Payment(
    bytes32 _id,
    uint256 _amount,
    address _tokenAddress,
    address _receiver,
    bytes20 _secretHash,
    uint64 _lockTime
  ) external payable {
    require(_receiver != address(0) && _amount > 0 && payments[_id].state == PaymentState.Uninitialized);

    bytes20 paymentHash = ripemd160(abi.encodePacked(
      _receiver,
      msg.sender,
      _secretHash,
      _tokenAddress,
      _amount,
      uint256(0)
    ));

    payments[_id] = Payment(
      paymentHash,
      _lockTime,
      PaymentState.PaymentSent
    );

    IERC20 token = IERC20(_tokenAddress);
    require(token.transferFrom(msg.sender, address(this), _amount));
    emit PaymentSent(_id);
  }

  function erc1155Payment(
    bytes32 _id,
    uint256 _tokenId,
    uint256 _amount,
    address _tokenAddress,
    address _receiver,
    bytes20 _secretHash,
    uint64 _lockTime
  ) external payable {
    require(_receiver != address(0) && _amount > 0 && _tokenId > 0 && payments[_id].state == PaymentState.Uninitialized);

    bytes20 paymentHash = ripemd160(abi.encodePacked(
      _receiver,
      msg.sender,
      _secretHash,
      _tokenAddress,
      _amount,
      _tokenId
    ));

    payments[_id] = Payment(
      paymentHash,
      _lockTime,
      PaymentState.PaymentSent
    );

    IERC1155 token = IERC1155(_tokenAddress);
    token.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, bytes(msg.data));
    emit PaymentSent(_id);
  }

  function receiverSpend(
    bytes32 _id,
    uint256 _amount,
    bytes32 _secret,
    address _tokenAddress,
    address _sender,
    uint256 _tokenId
  ) external {
    require(payments[_id].state == PaymentState.PaymentSent);

    bytes20 paymentHash = ripemd160(abi.encodePacked(
      msg.sender,
      _sender,
      ripemd160(abi.encodePacked(sha256(abi.encodePacked(_secret)))),
      _tokenAddress,
      _amount,
      _tokenId
    ));

    require(paymentHash == payments[_id].paymentHash && now < payments[_id].lockTime);
    payments[_id].state = PaymentState.ReceivedSpent;
    if (_tokenAddress == address(0)) {
      msg.sender.transfer(_amount);
    } else if(_tokenId > uint256(0)) {
      IERC1155 token = IERC1155(_tokenAddress);
      token.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, bytes(msg.data));
    } else {
      IERC20 token = IERC20(_tokenAddress);
      require(token.transfer(msg.sender, _amount));
    }

    emit ReceiverSpent(_id, _secret);
  }

  function senderRefund(
      bytes32 _id,
      uint256 _amount,
      bytes20 _paymentHash,
      address _tokenAddress,
      address _receiver,
      uint256 _tokenId
  ) external {
    require(payments[_id].state == PaymentState.PaymentSent);

    bytes20 paymentHash = ripemd160(abi.encodePacked(
      _receiver,
      msg.sender,
      _paymentHash,
      _tokenAddress,
      _amount,
      _tokenId
    ));

    require(paymentHash == payments[_id].paymentHash && now >= payments[_id].lockTime);

    payments[_id].state = PaymentState.SenderRefunded;

    if (_tokenAddress == address(0)) {
      msg.sender.transfer(_amount);
    } else if(_tokenId > uint256(0)) {
      IERC1155 token = IERC1155(_tokenAddress);
      token.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, bytes(msg.data));
    } else {
      IERC20 token = IERC20(_tokenAddress);
      require(token.transfer(msg.sender, _amount));
    }

    emit SenderRefunded(_id);
  }

  function onERC1155Received(
     address _operator, 
     address _from, 
     uint256 _id, 
     uint256 _value, 
     bytes calldata _data
  ) external returns(bytes4){
    if(_operator == msg.sender && _value > 0){
        return 0xf23a6e61;
      //return ERC1155_ACCEPTED;
      
    }
    return 0xf23a6e61;
    //return FAILURE;
    //return ERC1155_ACCEPTED;
  }

  function onERC1155BatchReceived(
    address _operator, 
    address _from, 
    uint256[] calldata _ids, 
    uint256[] calldata _values, 
    bytes calldata _data
  ) external returns(bytes4) {
    if(_operator == msg.sender ){
      return ERC1155_BATCH_ACCEPTED;
    }
    //return FAILURE;
    return ERC1155_BATCH_ACCEPTED;
  }
}