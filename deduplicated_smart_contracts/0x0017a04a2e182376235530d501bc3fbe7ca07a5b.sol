/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

pragma solidity ^0.4.23;
/*
 *          
 *              KOL Community Foundation
 *             Dev:Jack Koe
 *             Special for: KOL
 *   
 *             20200406
 *  
 */




 library SafeMath {
   function mul(uint a, uint b) internal pure  returns (uint) {
     uint c = a * b;
     require(a == 0 || c / a == b);
     return c;
   }
   function div(uint a, uint b) internal pure returns (uint) {
     require(b > 0);
     uint c = a / b;
     require(a == b * c + a % b);
     return c;
   }
   function sub(uint a, uint b) internal pure returns (uint) {
     require(b <= a);
     return a - b;
   }
   function add(uint a, uint b) internal pure returns (uint) {
     uint c = a + b;
     require(c >= a);
     return c;
   }
   function max64(uint64 a, uint64 b) internal  pure returns (uint64) {
     return a >= b ? a : b;
   }
   function min64(uint64 a, uint64 b) internal  pure returns (uint64) {
     return a < b ? a : b;
   }
   function max256(uint256 a, uint256 b) internal  pure returns (uint256) {
     return a >= b ? a : b;
   }
   function min256(uint256 a, uint256 b) internal  pure returns (uint256) {
     return a < b ? a : b;
   }
 }

 /**
  * @title KOL Node Lock & Release Contract
  * @dev visit: https://github.com/jackoelv/KOL/
 */

 contract ERC20Basic {
   uint public totalSupply;
   function balanceOf(address who) public constant returns (uint);
   function transfer(address to, uint value) public;
   event Transfer(address indexed from, address indexed to, uint value);
 }

 contract ERC20 is ERC20Basic {
   function allowance(address owner, address spender) public constant returns (uint);
   function transferFrom(address from, address to, uint value) public;
   function approve(address spender, uint value) public;
   event Approval(address indexed owner, address indexed spender, uint value);
 }

 /**
  * @title KOL Node Lock & Release Contract
  * @dev visit: https://github.com/jackoelv/KOL/
 */

 contract BasicToken is ERC20Basic {

   using SafeMath for uint;

   mapping(address => uint) balances;

   function transfer(address _to, uint _value) public{
     balances[msg.sender] = balances[msg.sender].sub(_value);
     balances[_to] = balances[_to].add(_value);
     emit Transfer(msg.sender, _to, _value);
   }

   function balanceOf(address _owner) public constant returns (uint balance) {
     return balances[_owner];
   }
 }

 /**
  * @title KOL Node Lock & Release Contract
  * @dev visit: https://github.com/jackoelv/KOL/
 */

 contract StandardToken is BasicToken, ERC20 {
   mapping (address => mapping (address => uint)) allowed;
   uint256 public userSupplyed;

   function transferFrom(address _from, address _to, uint _value) public {
     balances[_to] = balances[_to].add(_value);
     balances[_from] = balances[_from].sub(_value);
     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
     emit Transfer(_from, _to, _value);
   }

   function approve(address _spender, uint _value) public{
     require((_value == 0) || (allowed[msg.sender][_spender] == 0)) ;
     allowed[msg.sender][_spender] = _value;
     emit Approval(msg.sender, _spender, _value);
   }

   function allowance(address _owner, address _spender) public constant returns (uint remaining) {
     return allowed[_owner][_spender];
   }
 }
 contract KOL is StandardToken {
   function queryNode(address _addr) public view returns(bool);
   function querySuperNode(address _addr) public view returns(bool);
 }

 /**
  * @title KOL Node Lock & Release Contract
  * @dev visit: https://github.com/jackoelv/KOL/
 */

 contract Ownable {
     address public owner;

     constructor() public{
         owner = msg.sender;
     }

     modifier onlyOwner {
         require(msg.sender == owner);
         _;
     }
     function transferOwnership(address newOwner) onlyOwner public{
         if (newOwner != address(0)) {
             owner = newOwner;
         }
     }
 }
 /**
  * @title KOL Node Lock & Release Contract
  * @dev visit: https://github.com/jackoelv/KOL/
 */
contract KOLLockNode is Ownable{
  using SafeMath for uint256;
  string public name = "KOL Node Lock";
  KOL public token;

  uint256 public dealTime =  3 days;
  uint256 public missionId = 0;
  uint256 public nodeRate = 0;
  uint256 public releasedAll = 0;
  uint256 public balanceAll = 0;
  /* 正式环境 */

  uint16 public constant totalSuperNodes = 21;
  uint16 public constant totalNodes = 500;
  uint16 public constant halfSuperNodes = 11;
  uint16 public constant mostNodes = 335;
  uint16 public constant halfNodes = 251;
  uint16 public constant minSuperNodes = 15;
  uint16 public constant minNodes = 101;


  uint16 public constant most = 67;
  uint16 public constant half = 51;
  uint16 public constant less = 33;

  mapping(address => mapping(uint256 => bool)) private Voter;

  constructor(address _tokenAddress) public {
    token = KOL(_tokenAddress);
  }

  event MissionPassed(uint256 _missionId,bytes32 _name);
  event OfferingFinished(uint256 _missionId,uint256 _totalAmount,uint256 _length);
  event MissionLaunched(bytes32 _name,uint256 _missionId,address _whoLaunch);
  event AllTokenBack(address _fund,uint256 _amount);
  event Recycled(address _node,uint256 _amount);
  event RateChanged(uint256 _rate);


  modifier onlySuperNode() {
    require(token.querySuperNode(msg.sender));
      _;
  }
  modifier onlyNode() {
      require(token.queryNode(msg.sender));
      _;
  }
  modifier onlyNodes() {
      require(token.querySuperNode(msg.sender)||token.queryNode(msg.sender));
      _;
  }

  struct KolMission{
    uint256 startTime;
    uint256 endTime;
    uint256 totalAmount;
    uint256 offeringAmount;
    uint256 rate;
    bytes32 name;
    address recycleNodeAddr;
    uint16 agreeNodes;
    uint16 refuseNodes;
    uint16 agreeSuperNodes;
    uint16 refuseSuperNodes;
    bool superPassed;
    bool nodePassed;
    bool done;
  }
  mapping (uint256 => KolMission) private missionList;

  struct KolOffering{
    address target;
    uint256 targetAmount;
  }

  mapping (address => uint256) private nodeBalance;
  mapping (address => uint256) private nodeReleasedBalance;

  KolOffering[] private kolOfferings;
  mapping(uint256 => KolOffering[]) private offeringList;

  function missionPassed(uint256 _missionId) private {
    emit MissionPassed(_missionId,missionList[_missionId].name);
  }
  function createKolMission(bytes32 _name,uint256 _totalAmount,address _recycleNodeAddr,uint256 _rate) onlyNodes public {
      bytes32 iName = _name;
      uint256 balance = token.balanceOf(this);
      uint256 allLeftBalance = balanceAll.sub(releasedAll);
      require(balance >= allLeftBalance.add(_totalAmount));
      missionList[missionId] = KolMission(uint256(now),
                                          uint256(now + dealTime),
                                          _totalAmount,
                                          0,
                                          _rate,
                                          iName,
                                          _recycleNodeAddr,
                                          0,
                                          0,
                                          0,
                                          0,
                                          false,
                                          false,
                                          false);

      missionId++;
      emit MissionLaunched(iName,missionId-1,msg.sender);
  }
  function voteMission(uint16 _type,uint256 _missionId,bool _agree) onlyNodes public{
    require(!Voter[msg.sender][_missionId]);
    require(!missionList[_missionId].done);
    uint16 minNodesNum = minNodes;
    uint16 minSuperNodesNum = minSuperNodes;
    uint16 passNodes = halfNodes;
    uint16 passSuperNodes = halfSuperNodes;
    uint16 rate = half;

    if (_type == 1){
      require(token.querySuperNode(msg.sender));
    }else if (_type ==2){
      require(token.queryNode(msg.sender));
    }

    if(now > missionList[_missionId].endTime){
      if ( _type == 1 ){
        if (
          (missionList[_missionId].agreeSuperNodes + missionList[_missionId].refuseSuperNodes)>=minSuperNodesNum
          &&
          missionList[_missionId].agreeSuperNodes >= (missionList[_missionId].agreeSuperNodes + missionList[_missionId].refuseSuperNodes) * rate/100
          ){
            missionList[_missionId].superPassed = true;
            missionPassed(_missionId);
        }
      }else if (_type ==2 ){
        //节点投票
        if (
          (missionList[_missionId].agreeNodes + missionList[_missionId].refuseNodes)>=minNodesNum
          &&
          missionList[_missionId].agreeNodes >= (missionList[_missionId].refuseNodes + missionList[_missionId].refuseNodes) * rate/100
          ){
            missionList[_missionId].nodePassed = true;
        }
      }
    }else{
      if(_agree == true){
        if (_type == 1){
          missionList[_missionId].agreeSuperNodes++;
        }else if(_type == 2){
          missionList[_missionId].agreeNodes++;
        }
      }
      else{
        if (_type == 1){
          missionList[_missionId].refuseSuperNodes++;
        }else if(_type == 2){
          missionList[_missionId].refuseNodes++;
        }
      }
      if (_type == 1){
        if (missionList[_missionId].agreeSuperNodes >= passSuperNodes) {
            missionList[_missionId].superPassed = true;
            missionPassed(_missionId);
        }else if (missionList[_missionId].refuseSuperNodes >= passSuperNodes) {
            missionList[_missionId].done = true;
        }
      }else if (_type ==2){
        if (missionList[_missionId].agreeNodes >= passNodes) {
            missionList[_missionId].nodePassed = true;
        }else if (missionList[_missionId].refuseNodes >= passNodes) {
            missionList[_missionId].done = true;
        }
      }
    }
    Voter[msg.sender][_missionId] = true;
  }

  function excuteVote(uint256 _missionId) onlyOwner public {
    require(!missionList[_missionId].done);
    require(uint256(now) < (missionList[_missionId].endTime + uint256(dealTime)));
    require(missionList[_missionId].superPassed);
    require(missionList[_missionId].nodePassed);
    if (missionList[_missionId].name == "TRANSFER ALL KOL TO FUND"){
      transferAllKolToFund();
      missionList[_missionId].done = true;
    }else if (missionList[_missionId].name == "RECYCLE KOL FROM OLDNODE"){
      recycleKOL(missionList[_missionId].recycleNodeAddr);
      missionList[_missionId].done = true;
    }else if(missionList[_missionId].name == "CHANGE RELEASE RATE"){
      nodeRate = missionList[_missionId].rate;
      missionList[_missionId].done = true;
      emit RateChanged(nodeRate);
    }else{
      require(token.balanceOf(this).add(releasedAll) >= balanceAll.add(missionList[_missionId].totalAmount));
      require(missionList[_missionId].totalAmount == missionList[_missionId].offeringAmount);
      for (uint m = 0; m < offeringList[_missionId].length; m++){
        //这里要做一个记账。
        /* token.transfer(offeringList[_missionId][m].target, offeringList[_missionId][m].targetAmount); */
        nodeBalance[offeringList[_missionId][m].target] = nodeBalance[offeringList[_missionId][m].target].add(offeringList[_missionId][m].targetAmount);
      }
      balanceAll = balanceAll.add(missionList[_missionId].offeringAmount);
      nodeRate = missionList[_missionId].rate;
      missionList[_missionId].done = true;
      emit RateChanged(nodeRate);
      emit OfferingFinished(_missionId,missionList[_missionId].offeringAmount,offeringList[_missionId].length);
    }

  }
  function getMission1(uint256 _missionId) public view returns(uint256,
                                                            uint256,
                                                            uint256,
                                                            uint256,
                                                            uint256,
                                                            bytes32,
                                                            address){
    return(missionList[_missionId].startTime,
            missionList[_missionId].endTime,
            missionList[_missionId].totalAmount,
            missionList[_missionId].offeringAmount,
            missionList[_missionId].rate,
            missionList[_missionId].name,
            missionList[_missionId].recycleNodeAddr);
  }
  function getMission2(uint256 _missionId) public view returns(uint16,
                                                              uint16,
                                                              uint16,
                                                              uint16,
                                                              bool,
                                                              bool,
                                                              bool){
    return(
          missionList[_missionId].agreeNodes,
          missionList[_missionId].refuseNodes,
          missionList[_missionId].agreeSuperNodes,
          missionList[_missionId].refuseSuperNodes,
          missionList[_missionId].superPassed,
          missionList[_missionId].nodePassed,
          missionList[_missionId].done);
  }
  function getOfferings(uint256 _missionId,uint256 _id) public view returns(address,uint256,uint256){
    return(offeringList[_missionId][_id].target,offeringList[_missionId][_id].targetAmount,offeringList[_missionId].length);
  }

  function addKolOffering(uint256 _missionId,address[] _target ,uint256[] _targetAmount) onlyNodes public{
    require(missionList[_missionId].superPassed);
    require(!missionList[_missionId].done);
    require(_target.length == _targetAmount.length);
    bool isNode = false;
    for (uint j = 0; j< _targetAmount.length; j++){

      isNode = token.queryNode(_target[j])||token.querySuperNode(_target[j]);
      require(isNode);
      missionList[_missionId].offeringAmount = missionList[_missionId].offeringAmount.add(_targetAmount[j]);
      offeringList[_missionId].push(KolOffering(_target[j],_targetAmount[j]));

    }
    require(missionList[_missionId].totalAmount >= missionList[_missionId].offeringAmount);

  }
  function voted(address _node,uint256 _missionId) public view returns(bool){
    return Voter[_node][_missionId];
  }
  function getKOL() onlyNodes public {

    require(nodeBalance[msg.sender] > 0);
    uint256 amount = nodeBalance[msg.sender].mul(nodeRate).div(100);
    uint256 releaseKol = amount.sub(nodeReleasedBalance[msg.sender]);
    require(releaseKol > 0);
    require(nodeReleasedBalance[msg.sender].add(releaseKol)<=nodeBalance[msg.sender]);
    require(token.balanceOf(this) >= releaseKol);

    token.transfer(msg.sender, releaseKol);
    nodeReleasedBalance[msg.sender] = nodeReleasedBalance[msg.sender].add(releaseKol);
    releasedAll = releasedAll.add(releaseKol);
  }
  function queryBalance(address _node) onlyNodes public view returns(uint256,uint256){
    return(nodeBalance[_node],nodeReleasedBalance[_node]);
  }
  function transferAllKolToFund() private {
    address fund = 0x27750e6D41Aef99501eBC256538c6A13a254Ea15;
    uint256 balance = token.balanceOf(this);
    token.transfer(fund, balance);
    emit AllTokenBack(fund,balance);
  }
  function recycleKOL(address _node) private {
    require((!token.queryNode(_node)) && (!token.querySuperNode(msg.sender)));
    require(nodeBalance[_node] > 0);
    uint256 recycles = nodeBalance[_node].sub(nodeReleasedBalance[_node]);
    balanceAll = balanceAll.sub(recycles);
    nodeBalance[_node] = nodeReleasedBalance[_node];
    emit Recycled(_node,recycles);
  }
  function leftKOL() public view returns(uint256,bool) {
    uint256 balance = token.balanceOf(this);
    uint256 allLeftBalance = balanceAll.sub(releasedAll);
    if (balance >= allLeftBalance)
      return(balance.sub(allLeftBalance),true);
    else
      return(allLeftBalance.sub(balance),false);
  }

}