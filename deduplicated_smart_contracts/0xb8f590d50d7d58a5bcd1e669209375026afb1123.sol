/**
 *Submitted for verification at Etherscan.io on 2019-06-29
*/

pragma solidity ^0.5.10;

/*
* @Author Flash
* Source at https://github.com/Flash-Git/Arca/tree/master/contracts
*/

/*
* @Author Flash
* @title Arca
*
* @dev Allows for the simultaneous trade of multiple asset types
* Handles escrowless ERC20 and ERC721 transfers
*/

interface Erc20 {
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface Erc721 {
  function ownerOf(uint256 tokenId) external view returns (address owner);
  function isApprovedForAll(address owner, address operator) external view returns (bool);
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract Arca {
  event TradeAccepted(address indexed sender, address indexed partner, uint256 indexed boxNum, uint256 partnerNonce);
  event TradeUnaccepted(address indexed sender, address indexed partner, uint256 indexed boxNum);
  event TradeExecuted(address indexed sender, address indexed partner, uint256 indexed boxNum);
  event OfferModifiedERC20(address indexed sender, address indexed partner, uint256 indexed boxNum,
    address contractAdd, uint256 amount, uint8 index, uint256 nonce);
  event OfferModifiedERC721(address indexed sender, address indexed partner, uint256 indexed boxNum,
    address contractAdd, uint256 id, uint8 index, uint256 nonce);
  event OfferRemovedERC20(address indexed sender, address indexed partner, uint256 indexed boxNum, uint8 index, uint256 nonce);
  event OfferRemovedERC721(address indexed sender, address indexed partner, uint256 indexed boxNum, uint8 index, uint256 nonce);
  event BoxCountModifiedERC20(address indexed sender, address indexed partner, uint256 indexed boxNum, uint8 count, uint256 nonce);
  event BoxCountModifiedERC721(address indexed sender, address indexed partner, uint256 indexed boxNum, uint8 count, uint256 nonce);
  event OwnerUpdated(address indexed oldOwner, address indexed newOwner);
  event KilledContract(address indexed owner, address indexed newContract);

  address payable public owner;
  mapping(address => mapping(address => mapping(uint256 => Box))) private boxes;

  struct OfferErc20 {
    address add;
    uint256 amount;
  }

  struct OfferErc721 {
    address add;
    uint256 id;
  }

  struct Box {
    OfferErc20[] offersErc20;
    OfferErc721[] offersErc721;
    uint8 countErc20;
    uint8 countErc721;
    uint256 nonce;
    uint256 partnerNonce;
  }


  constructor() public {
    owner = msg.sender;
  }

  modifier isOwner() {
    require(msg.sender == owner, "Sender isn't the contract's owner");

    _;//Continue to run
  }


  /*
  * GETTERS
  */

  function getOfferErc20(address _add1, address _add2, uint256 _boxNum, uint8 _index) external view returns(address, uint256) {
    return (boxes[_add1][_add2][_boxNum].offersErc20[_index].add, boxes[_add1][_add2][_boxNum].offersErc20[_index].amount);
  }
  
  function getOfferErc721(address _add1, address _add2, uint256 _boxNum, uint8 _index) external view returns(address, uint256) {
    return (boxes[_add1][_add2][_boxNum].offersErc721[_index].add, boxes[_add1][_add2][_boxNum].offersErc721[_index].id);
  }

  function getErc20Count(address _add1, address _add2, uint256 _boxNum) external view returns(uint8) {
    return boxes[_add1][_add2][_boxNum].countErc20;
  }

  function getErc721Count(address _add1, address _add2, uint256 _boxNum) external view returns(uint8) {
    return boxes[_add1][_add2][_boxNum].countErc721;
  }

  function getNonce(address _add1, address _add2, uint256 _boxNum) external view returns(uint256) {
    return boxes[_add1][_add2][_boxNum].nonce;
  }

  function getPartnerNonce(address _add1, address _add2, uint256 _boxNum) external view returns(uint256) {
    return boxes[_add1][_add2][_boxNum].partnerNonce;
  }


  /*
  * TRADE ACTIONS
  */

  function acceptTrade(address _tradePartner, uint256 _boxNum, uint256 _partnerNonce) external {
    boxes[msg.sender][_tradePartner][_boxNum].partnerNonce = _partnerNonce+1; //Offset serves to avoid explicit "satisfied" variable
    emit TradeAccepted(msg.sender, _tradePartner, _boxNum, _partnerNonce+1);

    if(boxes[_tradePartner][msg.sender][_boxNum].partnerNonce == boxes[msg.sender][_tradePartner][_boxNum].nonce+1){
      executeTrade(_tradePartner, _boxNum);
    }
  }

  function unacceptTrade(address _tradePartner, uint256 _boxNum) external {
    boxes[msg.sender][_tradePartner][_boxNum].partnerNonce = 0;
    emit TradeUnaccepted(msg.sender, _tradePartner, _boxNum);
  }

  function executeTrade(address _tradePartner, uint256 _boxNum) private {
    Box storage senderBox = boxes[msg.sender][_tradePartner][_boxNum];
    Box storage prtnerBox = boxes[_tradePartner][msg.sender][_boxNum];

    //Check Satisfaction
    require(senderBox.nonce+1 == prtnerBox.partnerNonce, "Sender not satisfied");
    require(prtnerBox.nonce+1 == senderBox.partnerNonce, "Trade partner not satisfied");

    //Drop Satisfaction
    senderBox.partnerNonce = 0;
    prtnerBox.partnerNonce = 0;

    //Execute Erc20 Transfers
    executeTransfersErc20(msg.sender, _tradePartner, _boxNum);
    executeTransfersErc20(_tradePartner, msg.sender, _boxNum);

    //Execute Erc721 Transfers
    executeTransfersErc721(msg.sender, _tradePartner, _boxNum);
    executeTransfersErc721(_tradePartner, msg.sender, _boxNum);

    //Wipe (Not Necessary)
    senderBox.countErc20 = 0;
    prtnerBox.countErc20 = 0;
    senderBox.countErc721 = 0;
    prtnerBox.countErc721 = 0;
    
    emit BoxCountModifiedERC20(msg.sender, _tradePartner, _boxNum, 0, senderBox.nonce);
    emit BoxCountModifiedERC20(_tradePartner, msg.sender, _boxNum, 0, prtnerBox.nonce);

    emit BoxCountModifiedERC721(msg.sender, _tradePartner, _boxNum, 0, senderBox.nonce);
    emit BoxCountModifiedERC721(_tradePartner, msg.sender, _boxNum, 0, prtnerBox.nonce);

    emit TradeExecuted(msg.sender, _tradePartner, _boxNum);
  }


  /*
  * BOX FUNCTIONS
  */

  function pushOfferErc20(address _tradePartner, uint256 _boxNum, address _erc20Address, uint256 _amount) external {
    addOfferErc20(_tradePartner, _boxNum, _erc20Address, _amount, boxes[msg.sender][_tradePartner][_boxNum].countErc20);
  }

  function addOfferErc20(address _tradePartner, uint256 _boxNum, address _erc20Address, uint256 _amount, uint8 _index) public {
    require(Erc20(_erc20Address).allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");
    
    OfferErc20 memory offer = OfferErc20({add: _erc20Address, amount:_amount});
    Box storage box = boxes[msg.sender][_tradePartner][_boxNum];
    
    if(box.offersErc20.length > _index){
      box.offersErc20[_index] = offer;
    }else{
      box.offersErc20.push(offer);
    }

    if(box.countErc20 <= _index){
      box.countErc20++;
    }

    emit OfferModifiedERC20(msg.sender, _tradePartner, _boxNum, _erc20Address, _amount, _index, box.nonce++);
  }
  
  function pushOfferErc721(address _tradePartner, uint256 _boxNum, address _erc721Address, uint256 _id) external {
    addOfferErc721(_tradePartner, _boxNum, _erc721Address, _id, boxes[msg.sender][_tradePartner][_boxNum].countErc721);
  }
  
  function addOfferErc721(address _tradePartner, uint256 _boxNum, address _erc721Address, uint256 _id, uint8 _index) public {
    require(Erc721(_erc721Address).ownerOf(_id) == msg.sender, "Sender isn't owner of this erc721 token");
    require(Erc721(_erc721Address).isApprovedForAll(msg.sender, address(this)) == true, "Contract not approved for erc721 token transfers");

    OfferErc721 memory offer = OfferErc721({add: _erc721Address, id:_id});
    Box storage box = boxes[msg.sender][_tradePartner][_boxNum];

    if(box.offersErc721.length > _index){
      box.offersErc721[_index] = offer;
    }else{
      box.offersErc721.push(offer);
    }

    if(box.countErc721 <= _index){
      box.countErc721++;
    }

    emit OfferModifiedERC721(msg.sender, _tradePartner, _boxNum, _erc721Address, _id, _index, box.nonce++);
  }

  function removeOfferErc20(address _tradePartner, uint256 _boxNum, uint8 _index) external {
    Box storage box = boxes[msg.sender][_tradePartner][_boxNum];
    box.offersErc20[_index].add = address(0);

    emit OfferRemovedERC20(msg.sender, _tradePartner, _boxNum, _index, box.nonce++);
  }

  function removeOfferErc721(address _tradePartner, uint256 _boxNum, uint8 _index) external {
    Box storage box = boxes[msg.sender][_tradePartner][_boxNum];
    box.offersErc721[_index].add = address(0);

    emit OfferRemovedERC721(msg.sender, _tradePartner, _boxNum, _index, box.nonce++);
  }

  //Set to 0 to clear
  function setCountErc20(address _tradePartner, uint256 _boxNum, uint8 _count) external {
    Box storage box = boxes[msg.sender][_tradePartner][_boxNum];
    box.countErc20 = _count;

    emit BoxCountModifiedERC20(msg.sender, _tradePartner, _boxNum, _count, box.nonce++);
  }

  //Set to 0 to clear
  function setCountErc721(address _tradePartner, uint256 _boxNum, uint8 _count) external {
    Box storage box = boxes[msg.sender][_tradePartner][_boxNum];
    box.countErc721 = _count;

    emit BoxCountModifiedERC721(msg.sender, _tradePartner, _boxNum, _count, box.nonce++);
  }


  /*
  * EXECUTION
  */

  function executeTransfersErc20(address _add1, address _add2, uint256 _boxNum) private {
    Box memory box = boxes[_add1][_add2][_boxNum];

    OfferErc20[] memory offers = box.offersErc20;
    for(uint8 i = 0; i < box.countErc20; i++){
      if(box.offersErc20[i].add != address(0)){
        directErc20Transfer(_add1, _add2, offers[i].add, offers[i].amount);
      }
    }
  }
  
  function executeTransfersErc721(address _add1, address _add2, uint256 _boxNum) private {
    Box memory box = boxes[_add1][_add2][_boxNum];

    OfferErc721[] memory offers = box.offersErc721;
    for(uint8 i = 0; i < box.countErc721; i++){
      if(box.offersErc721[i].add != address(0)){
        directErc721Transfer(_add1, _add2, offers[i].add, offers[i].id);
      }
    }
  }

  function directErc20Transfer(address _add1, address _add2, address _erc20Address, uint256 _amount) private {
    uint startBalance = Erc20(_erc20Address).balanceOf(_add2);
    Erc20(_erc20Address).transferFrom(_add1, _add2, _amount);
    require(startBalance + _amount == Erc20(_erc20Address).balanceOf(_add2), "Balance of ERC20 failed to update");
  }

  function directErc721Transfer(address _add1, address _add2, address _erc721Address, uint256 _id) private {
    Erc721(_erc721Address).safeTransferFrom(_add1, _add2, _id);
    require(Erc721(_erc721Address).ownerOf(_id) == _add2, "Owner of ERC721 failed to update");
  }


  /*
  * OWNER
  */

  function updateOwner(address payable _newOwner) external isOwner() {
    owner = _newOwner;
    emit OwnerUpdated(msg.sender, owner);
  }

  function killContract(address _newContract) external isOwner() {
    emit KilledContract(msg.sender, _newContract);
    selfdestruct(owner);
  }
}