/**
 *Submitted for verification at Etherscan.io on 2019-10-27
*/

// GoToken is an open community aims to explore a decentralized collaboration network incentived and well-governed through blockchain. Learn more about gotoken @ forum.gotoken.io


pragma solidity >=0.4.21 <0.6.0;

contract TransferableToken{
    function balanceOf(address _owner) public returns (uint256 balance) ;
    function transfer(address _to, uint256 _amount) public returns (bool success) ;
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) ;
}


contract TokenClaimer{

    event ClaimedTokens(address indexed _token, address indexed _to, uint _amount);
    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
  function _claimStdTokens(address _token, address payable to) internal {
        if (_token == address(0x0)) {
            to.transfer(address(this).balance);
            return;
        }
        TransferableToken token = TransferableToken(_token);
        uint balance = token.balanceOf(address(this));

        (bool status,) = _token.call(abi.encodeWithSignature("transfer(address,uint256)", to, balance));
        require(status, "call failed");
        emit ClaimedTokens(_token, to, balance);
  }
}


pragma solidity >=0.4.21 <0.6.0;

contract MultiSigInterface{
  function update_and_check_reach_majority(uint64 id, string memory name, bytes32 hash, address sender) public returns (bool);
  function is_signer(address addr) public view returns(bool);
}

contract MultiSigTools{
  MultiSigInterface public multisig_contract;
  constructor(address _contract) public{
    require(_contract!= address(0x0));
    multisig_contract = MultiSigInterface(_contract);
  }

  modifier only_signer{
    require(multisig_contract.is_signer(msg.sender), "only a signer can call in MultiSigTools");
    _;
  }

  modifier is_majority_sig(uint64 id, string memory name) {
    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
    if(multisig_contract.update_and_check_reach_majority(id, name, hash, msg.sender)){
      _;
    }
  }

  event TransferMultiSig(address _old, address _new);

  function transfer_multisig(uint64 id, address _contract) public only_signer
  is_majority_sig(id, "transfer_multisig"){
    require(_contract != address(0x0));
    address old = address(multisig_contract);
    multisig_contract = MultiSigInterface(_contract);
    emit TransferMultiSig(old, _contract);
  }
}


pragma solidity >=0.4.21 <0.6.0;

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


pragma solidity >=0.4.21 <0.6.0;




contract GTTokenInterface is TransferableToken{
    function destroyTokens(address _owner, uint _amount) public returns (bool);
    function generateTokens(address _owner, uint _amount) public returns (bool);
}

contract InitIssueAndLock is MultiSigTools{
  using AddressArray for address[];

  uint public unlock_block_number;
  uint[] public amounts;
  address[] public addrs;
  bool public issued;
  address public gt_contract;

  event Issue(uint total, address[] addrs, uint[] amounts);

  constructor(address _gt_contract, uint _unlock_block_number, address[] memory _addrs, uint[] memory _amounts, address _multisig) MultiSigTools(_multisig) public {
    require(_amounts.length == _addrs.length);
    require(_unlock_block_number > block.number);
    for(uint i = 0; i < _addrs.length; i++){
      addrs.push(_addrs[i]);
      amounts.push(_amounts[i]);
    }
    issued = false;
    unlock_block_number = _unlock_block_number;
    gt_contract = _gt_contract;
  }

  function issue() public{
    require(issued == false, "issued already");
    require(unlock_block_number <= block.number, "not ready to unlock");

    GTTokenInterface token = GTTokenInterface(gt_contract);

    uint total = 0;
    for(uint i = 0; i < addrs.length; i++){
      token.generateTokens(addrs[i], amounts[i]);
      total = total + amounts[i];
    }
    issued = true;
    emit Issue(total, addrs, amounts);
  }

  function replace(uint64 id, address old_addr, address new_addr) public only_signer is_majority_sig(id, "replace"){
    require(issued == false, "issued already");
    addrs.replace(old_addr, new_addr);
  }

  function get_number_of_addrs() public view returns(uint){
    return addrs.length;
  }

  function get_addr_amount(uint i) public view returns(address addr, uint amount){
    addr = addrs[i];
    amount = amounts[i];
  }

  function get_init_and_lock_status() public view returns(address[] memory , uint[] memory ){
    return (addrs, amounts);
  }
}