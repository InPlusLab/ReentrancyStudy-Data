/**
 *Submitted for verification at Etherscan.io on 2019-11-17
*/

pragma solidity >=0.4.21 <0.6.0;

contract WeightMultiSig{

  struct invoke_status{
    uint propose_height;
    bytes32 invoke_hash;
    string func_name;
    uint64 invoke_id;
    bool called;
    address[] invoke_signers;
    bool processing;
    bool exists;
  }

  uint public signer_number;
  address[] public signers;
  mapping (address => uint) public weights;
  uint public total_weight;
  address public owner;
  mapping (bytes32 => invoke_status) public invokes;
  mapping (bytes32 => uint64) public used_invoke_ids;
  mapping(address => uint) public signer_join_height;

  event signers_reformed(address[] old_signers, address[] new_signers, uint[] new_weights);
  event valid_function_sign(string name, uint64 id, uint64 current_signed_number, uint propose_height);
  event function_called(string name, uint64 id, uint propose_height);

  modifier enough_signers(address[] memory s){
    require(s.length >=3, "the number of signers must be >=3");
    _;
  }
  constructor(address[] memory s, uint[] memory w) public enough_signers(s){
    require(s.length == w.length, "signers and weights are not with the same length");
    signer_number = s.length;
    owner = msg.sender;
    total_weight = 0;
    for(uint i = 0; i < s.length; i++){
      signers.push(s[i]);
      weights[s[i]] = w[i];
      signer_join_height[s[i]] = block.number;
      total_weight += w[i];
    }
  }

  modifier only_signer{
    require(array_exist(signers, msg.sender), "only a signer can call this");
    _;
  }

  function is_signer(address _addr) public view returns(bool){
    return array_exist(signers, _addr);
  }

  function get_total_weight() internal view returns (uint){
    return total_weight;
  }

  function get_majority_weight() private view returns(uint){
    return get_total_weight()/2 + 1;
  }

  function array_exist (address[] memory accounts, address p) private pure returns (bool){
    for (uint i = 0; i< accounts.length;i++){
      if (accounts[i]==p){
        return true;
      }
    }
    return false;
  }

  function is_all_minus_sig(uint number, uint64 id, string memory name, bytes32 hash, address sender) internal returns (bool){
    bytes32 b = keccak256(abi.encodePacked(name));
    require(id <= used_invoke_ids[b] + 1, "you're using a too big id.");

    if(id > used_invoke_ids[b]){
      used_invoke_ids[b] = id;
    }

    if(!invokes[hash].exists){
      invokes[hash].propose_height = block.number;
      invokes[hash].invoke_hash = hash;
      invokes[hash].func_name= name;
      invokes[hash].invoke_id= id;
      invokes[hash].called= false;
      invokes[hash].invoke_signers.push(sender);
      invokes[hash].processing= false;
      invokes[hash].exists= true;
      emit valid_function_sign(name, id, uint64(weights[sender]), block.number);
      if(weights[sender] >= get_total_weight() - number){
        invokes[hash].processing = true;
        return true;
      }else{
        return false;
      }
    }


    invoke_status storage invoke = invokes[hash];
    require(!array_exist(invoke.invoke_signers, sender), "you already called this method");

    //uint[] memory t;
    //emit signers_reformed(signers, [sender], t);
    uint valid_invoke_weight = 0;
    uint join_height = signer_join_height[sender];
    for(uint i = 0; i < invoke.invoke_signers.length; i++){
      require(join_height < invoke.propose_height, "this proposal is already exist before you become a signer");
      if(array_exist(signers, invoke.invoke_signers[i])){
        valid_invoke_weight += weights[invoke.invoke_signers[i]];
      }
    }
    invoke.invoke_signers.push(sender);
    valid_invoke_weight += weights[sender];
    emit valid_function_sign(name, id, uint64(valid_invoke_weight), invoke.propose_height);
    if(invoke.called) return false;
    if(valid_invoke_weight < get_total_weight() -number) return false;
    invoke.processing = true;
    return true;
  }

  function update_and_check_reach_majority(uint64 id, string memory name, bytes32 hash, address sender) public returns (bool){
    //bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
    if(!is_all_minus_sig(get_majority_weight()-1, id, name, hash, sender))
      return false;
    set_called(hash);
    return true;
  }

  modifier is_majority_sig(uint64 id, string memory name) {
    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
    if(!is_all_minus_sig(get_majority_weight()-1, id, name, hash, msg.sender))
      return ;
    set_called(hash);
    _;
  }

  modifier is_all_sig(uint64 id, string memory name) {
    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
    if(!is_all_minus_sig(0, id, name, hash, msg.sender)) return ;
    set_called(hash);
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

  function reform_signers(uint64 id, address[] calldata s, uint[] calldata w)
    external
    only_signer
    enough_signers(s)
    is_majority_sig(id, "reform_signers"){
    address[] memory old_signers = signers;
    for(uint i = 0; i < s.length; i++){
      if(array_exist(old_signers, s[i])){
      }else{
        signer_join_height[s[i]] = block.number;
        weights[s[i]] = w[i];
      }
    }
    for(uint i = 0; i < old_signers.length; i++){
      if(array_exist(s, old_signers[i])){
      }else{
        signer_join_height[old_signers[i]] = 0;
        weights[s[i]] = 0;
      }
    }
    signer_number = s.length;
    signers = s;
    emit signers_reformed(old_signers, signers, w);
    total_weight = 0; //enforce update.
    for(uint i = 0; i < signers.length; i++){
      weights[signers[i]] = w[i];
      total_weight += weights[signers[i]];
    }
  }

  function get_unused_invoke_id(string memory name) public view returns(uint64){
    return used_invoke_ids[keccak256(abi.encodePacked(name))] + 1;
  }
  function get_signers() public view returns(address[] memory){
    return signers;
  }
  function get_signer_weight(address addr) public view returns(uint){
    return weights[addr];
  }
}

contract WeightMultiSigFactory{
  event NewWeightMultiSig(address addr, address[] signers, uint[] weights);

  function createWeightMultiSig(address[] memory _signers, uint[] memory _weights) public returns(address){
    WeightMultiSig ms = new WeightMultiSig(_signers, _weights);
    emit NewWeightMultiSig(address(ms), _signers, _weights);
    return address(ms);
  }
}