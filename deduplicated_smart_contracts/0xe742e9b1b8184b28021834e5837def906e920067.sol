/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

pragma solidity >=0.4.21 <0.6.0;
contract LiquidDemocracyInterface{
  function setNoMajority(bool t) public ;
  function getVoterCount() public view returns(uint);
  function getWeight(address addr) public view returns(uint) ;
  function getDelegatee(address addr) public view returns (address [] memory);
  function getDelegator(address addr) public view returns(address);
  function delegate(address _to) public returns(bool);
  function undelegate() public returns(bool);
  function setWeight(address addr, uint weight) public returns(bool);
  function removeVoter(address addr) public returns(bool);
  function lastUpdateHeight() public view returns(uint);
}


library AddressArray{
  function exists(address[] storage self, address addr) public view returns(bool){
    for (uint i = 0; i< self.length;i++){
      if (self[i]==addr){
        return true;
      }
    }
    return false;
  }

  function index_of(address[] storage self, address addr) public view returns(uint){
    for (uint i = 0; i< self.length;i++){
      if (self[i]==addr){
        return i;
      }
    }
    require(false, "AddressArray:index_of, not exist");
  }

  function remove(address[] storage self, address addr) public returns(bool){
    uint index = index_of(self, addr);
    self[index] = self[self.length - 1];

    delete self[self.length-1];
    self.length--;
  }

  function replace(address[] storage self, address old_addr, address new_addr) public returns(bool){
    uint index = index_of(self, old_addr);
    self[index] = new_addr;
  }
}



contract LiquidDemocracy is LiquidDemocracyInterface{
  using AddressArray for address[];

  address public owner;

  mapping (address => uint) public vote_weight;
  mapping (address => address) public v_to_parent;
  mapping (address => address[]) public v_to_children;
  uint public voter_count;
  uint public total_power;

  bool public force_no_majority;
  uint public last_update_height;


  event LiquidDelegate(address from, address to);
  event LiquidUndelegate(address from, address to);
  event LiquidSetWeight(address addr, uint weight);
  event LiquidRemoveVoter(address addr);

  constructor() public{
    owner = msg.sender;
    voter_count = 0;
    force_no_majority = true;
    last_update_height = block.number;
  }

  modifier isOwner{
    require(msg.sender == owner, "only owner can call this");
    _;
  }

  function setNoMajority(bool t) public isOwner{
    force_no_majority = t;
  }

  function transferOwner(address new_owner) public isOwner{
    require(new_owner != address(0x0), "transferOwner: invalid address");
    owner = new_owner;
  }


  function setWeight(address addr, uint weight) public isOwner returns(bool){
    require(weight > 0, "invalid weight");
    require(addr != address(0x0), "setWeight: invalid address");
    vote_weight[addr] = weight;
    voter_count ++;
    total_power += weight;
    last_update_height = block.number;
    emit LiquidSetWeight(addr, weight);
    return true;
  }
  function removeVoter(address addr) public isOwner returns(bool){
    require(addr != address(0x0), "removeVoter: invalid address");
    total_power -= vote_weight[addr];
    vote_weight[addr] = 0;
    _undelegate(addr);
    address[] storage children = v_to_children[addr];
    for(uint i = 0; i < children.length; i++){
      delete v_to_parent[children[i]];
    }
    delete v_to_children[addr];

    voter_count --;
    last_update_height = block.number;
    emit LiquidRemoveVoter(addr);
    return true;
  }

  function check_circle(address _from, address _to) internal view returns(bool){
    address parent = _to;
    while(parent != address(0x0)){
      parent = v_to_parent[parent];
      if(parent == _from){
        return true;
      }
    }
    return false;
  }

  function delegate(address _to) public  returns(bool){
    require(_to != msg.sender, "cannot be self");
    require(vote_weight[msg.sender] != 0, "no sender");
    require(vote_weight[_to] != 0, "no _to");
    bool has_circle = check_circle(msg.sender, _to);
    require(!has_circle, "cannot have delegate circle");

    address old = v_to_parent[msg.sender];
    if(old != address(0x0)){
      address[] storage children = v_to_children[old];
      children.remove(msg.sender);
    }
    v_to_parent[msg.sender] = _to;
    v_to_children[_to].push(msg.sender);

    if(force_no_majority){
      address fp = getFinalDelegator(msg.sender);
      uint p = getVoterTotalPower(fp);
      require(p <= getTotalPower()/2, "this delegate causes a majority, call getFinalDelegator(...) to know the potential majority");
    }

    last_update_height = block.number;
    emit LiquidDelegate(msg.sender, _to);
    return true;
  }

  function _undelegate(address from) internal {
    address old = v_to_parent[from];
    if(old == address(0x0)) {
      return;
    }
    address[] storage children = v_to_children[old];
    children.remove(from);
    v_to_parent[from] = address(0x0);
    last_update_height = block.number;
    emit LiquidUndelegate(from, old);

  }
  function undelegate() public returns(bool){
    _undelegate(msg.sender);
    return true;
  }

  function getDelegator(address addr) public view returns(address ){
    return v_to_parent[addr];
  }

  function getDelegatee(address addr) public view returns (address [] memory){
    return v_to_children[addr];
  }

  function getWeight(address addr) public view returns(uint) {
    return vote_weight[addr];
  }
  function getVoterCount() public view returns(uint){
    return voter_count;
  }

  function getTotalPower() public view returns(uint){
    return total_power;
  }

  function getVoterTotalPower(address addr) public view returns(uint){
    address[] memory to_visit = new address[](getVoterCount());
    uint power = 0;
    uint index = 0;
    to_visit[index] = addr;
    index ++;
    while(index != 0){
      index --;
      address last = to_visit[index];
      power += getWeight(last);
      address[] memory children = getDelegatee(last);
      for(uint i = 0; i < children.length; i++){
          to_visit[index] = children[i];
          index ++;
      }
    }
    return power;
  }

  function getFinalDelegator(address addr) public view returns(address){
    require(addr != address(0x0), "get_voted_parent: invalid address");
    address next = getDelegator(addr);
    while(next != address(0x0)){
      if(getDelegator(next) == address(0x0)){
        return next;
      }
      next = getDelegator(next);
    }
    return address(0x0);
  }

  function lastUpdateHeight() public view returns(uint){
    return last_update_height;
  }
}

contract LiquidDemocracyFactory{
  event NewLiquidDemocracy(address addr);
  function createLiquidDemocracy() public returns(address){
    LiquidDemocracy ld = new LiquidDemocracy();
    ld.transferOwner(msg.sender);
    emit NewLiquidDemocracy(address(ld));
    return address(ld);
  }
}