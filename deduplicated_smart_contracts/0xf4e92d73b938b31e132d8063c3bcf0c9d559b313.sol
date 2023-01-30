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




contract LiquidDelegateFactoryInterface{
  function createLiquidDemocracy() public returns(address);
}

contract VoteFactoryInterface{
  function createLiquidVote(address delegation)  public returns(address);
}

contract VoteInterface{
  function addChoice(bytes32 hash) public;
  function getChoiceVoteNumber(bytes32 hash) public returns(uint);
  function isChoiceExist(bytes32 hash) public view returns(bool);
  function recordVoteChoice(bytes32 option, address voter) public;
  function voteChoice(bytes32 option) public;
}

contract LiquidMultiSig{
  using AddressArray for address[];

  struct invoke_status{
    uint propose_height;
    string func_name;
    uint64 invoke_id;
    bool called;
    bool processing;
    VoteInterface vote_contract;
    bool exists;
  }

  uint public signer_number;
  address[] public signers;
  address public owner;
  mapping (bytes32 => invoke_status) public invokes;
  mapping (bytes32 => uint64) public used_invoke_ids;
  mapping(address => uint) public signer_join_height;
  bool public force_no_majority;

  LiquidDelegateFactoryInterface public liquid_delegate_factory;
  LiquidDemocracyInterface public liquid_delegate;
  VoteFactoryInterface public vote_factory;

  event signers_reformed(address[] old_signers, address[] new_signers);
  event valid_function_sign(string name, uint64 id, uint64 current_signed_number, uint propose_height);
  event function_called(string name, uint64 id, uint propose_height);

  modifier enough_signers(address[] memory s){
    require(s.length >=3, "the number of signers must be >=3");
    _;
  }

  constructor(address[] memory s, address _delegate_factory, address _vote_factory) public enough_signers(s){
    signer_number = s.length;
    owner = msg.sender;
    for(uint i = 0; i < s.length; i++){
      signers.push(s[i]);
      signer_join_height[s[i]] = block.number;
    }
    liquid_delegate_factory = LiquidDelegateFactoryInterface(_delegate_factory);
    vote_factory = VoteFactoryInterface(_vote_factory);
    liquid_delegate = LiquidDemocracyInterface(address(0x0));
  }

  event init_done(address democracy_addr);
  function do_initialization() public{
    require(liquid_delegate == LiquidDemocracyInterface(address(0x0)), "already initialized");
    liquid_delegate = LiquidDemocracyInterface(liquid_delegate_factory.createLiquidDemocracy());
    for(uint i = 0; i < signers.length; i++){
      liquid_delegate.setWeight(signers[i], 1);
    }
    emit init_done(address(liquid_delegate));
  }

  modifier only_signer{
    require(signers.exists(msg.sender), "only a signer can call this");
    _;
  }

  function is_signer(address _addr) public view returns(bool){
    return signers.exists(_addr);
  }

  function get_democracy() public view returns(address){
    return address(liquid_delegate);
  }
  function is_all_minus_sig(uint number, uint64 id, string memory name, bytes32 hash, address sender) internal returns (bool){
    bytes32 b = keccak256(abi.encodePacked(name, signers));
    require(id <= used_invoke_ids[b] + 1, "you're using a too big id.");

    if(id > used_invoke_ids[b]){
      used_invoke_ids[b] = id;
    }

    bytes32 invokeHash = keccak256(abi.encodePacked(id, name, signers));
    bytes32 choiceHash = hash;
    if(!invokes[invokeHash].exists){
      invokes[invokeHash].propose_height = block.number;
      invokes[invokeHash].func_name = name;
      invokes[invokeHash].invoke_id = id;
      invokes[invokeHash].called = false;
      invokes[invokeHash].processing = false;
      invokes[invokeHash].vote_contract = VoteInterface(vote_factory.createLiquidVote(address(liquid_delegate)));
      invokes[invokeHash].exists = true;
      invokes[invokeHash].vote_contract.addChoice(choiceHash);

      invokes[invokeHash].vote_contract.recordVoteChoice(choiceHash, sender);
      emit valid_function_sign(name, id, 1, block.number);
      return false;
    }
    invoke_status storage invoke = invokes[invokeHash];
    if(!invoke.vote_contract.isChoiceExist(choiceHash)){
      invoke.vote_contract.addChoice(choiceHash);
    }

    uint valid_invoke_num = 0;
    uint join_height = signer_join_height[sender];
    require(join_height < invoke.propose_height, "this proposal is already exist before you become a signer");
    invoke.vote_contract.recordVoteChoice(choiceHash, sender);
    valid_invoke_num = invoke.vote_contract.getChoiceVoteNumber(choiceHash);

    emit valid_function_sign(name, id, uint64(valid_invoke_num), invoke.propose_height);
    if(invoke.called) return false;
    if(valid_invoke_num < signer_number-number) return false;
    invoke.processing = true;
    return true;

  }

  function get_majority_number() private view returns(uint){
    return signer_number/2 + 1;
  }
  function update_and_check_reach_majority(uint64 id, string memory name, bytes32 hash, address sender) public returns (bool){
    //bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
    uint minority = signer_number - get_majority_number();
    if(!is_all_minus_sig(minority, id, name, hash, sender))
      return false;
    bytes32 invokeHash = keccak256(abi.encodePacked(id, name, signers));
    set_called(invokeHash);
    return true;
  }

  modifier is_majority_sig(uint64 id, string memory name) {
    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
    uint minority = signer_number - get_majority_number();
    if(!is_all_minus_sig(minority, id, name, hash, msg.sender))
      return ;
    bytes32 invokeHash = keccak256(abi.encodePacked(id, name, signers));
    set_called(invokeHash);
    _;
  }

  modifier is_all_sig(uint64 id, string memory name) {
    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
    if(!is_all_minus_sig(0, id, name, hash, msg.sender)) return ;
    bytes32 invokeHash = keccak256(abi.encodePacked(id, name, signers));
    set_called(invokeHash);
    _;
  }

  function set_called(bytes32 hash) internal {
    invoke_status storage invoke = invokes[hash];
    require(invoke.exists, "no such function");
    require(!invoke.called, "already called");
    require(invoke.processing, "cannot call this separately");
    invoke.called = true;
    invoke.processing = false;
    emit function_called(invoke.func_name, invoke.invoke_id, invoke.propose_height);
  }

  function get_sig_status(uint64 id, string memory name) public view returns(uint propose_height, address vote_contract, bool called){
    bytes32 invokeHash = keccak256(abi.encodePacked(id, name, signers));
    invoke_status storage invoke = invokes[invokeHash];
    require(invoke.exists, "no such sig");
    propose_height = invoke.propose_height;
    vote_contract = address(invoke.vote_contract);
    called = invoke.called;
  }

  function array_exist (address[] memory accounts, address p) private pure returns (bool){
    for (uint i = 0; i< accounts.length;i++){
      if (accounts[i]==p){
        return true;
      }
    }
    return false;
  }

  function reform_signers(uint64 id, address[] memory s)
    public
    only_signer
    enough_signers(s)
    is_majority_sig(id, "reform_signers"){
    address[] memory old_signers = signers;
    for(uint i = 0; i < s.length; i++){
      if(array_exist(old_signers, s[i])){
      }else{
        signer_join_height[s[i]] = block.number;
        liquid_delegate.setWeight(s[i], 1);
      }
    }
    for(uint i = 0; i < old_signers.length; i++){
      if(array_exist(s,old_signers[i])){
      }else{
        signer_join_height[old_signers[i]] = 0;
        liquid_delegate.removeVoter(old_signers[i]);
      }
    }
    signer_number = s.length;
    signers = s;
    emit signers_reformed(old_signers, signers);
  }

  function get_unused_invoke_id(string memory name) public view returns(uint64){
    return used_invoke_ids[keccak256(abi.encodePacked(name, signers))] + 1;
  }
  function get_signers() public view returns(address[] memory){
    return signers;
  }

  function set_democracy_no_majority(uint64 id, bool t) public only_signer
    is_majority_sig(id, "set_democracy_no_majority"){
      liquid_delegate.setNoMajority(t);
  }


}

contract LiquidMultiSigFactory{
  event NewMultiSig(address addr, address[] signers);

  function createMultiSig(address[] memory _signers, address _delegate_factory, address _vote_factory) public returns(address){
    LiquidMultiSig ms = new LiquidMultiSig(_signers, _delegate_factory, _vote_factory);
    ms.do_initialization();
    emit NewMultiSig(address(ms), _signers);
    return address(ms);
  }
}