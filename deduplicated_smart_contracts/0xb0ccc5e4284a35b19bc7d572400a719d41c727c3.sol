/**
 *Submitted for verification at Etherscan.io on 2020-04-02
*/

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

contract TrustListInterface{
  function is_trusted(address addr) public returns(bool);
}
contract TrustListTools{
  TrustListInterface public list;
  constructor(address _list) public {
    require(_list != address(0x0));
    list = TrustListInterface(_list);
  }

  modifier is_trusted(address addr){
    require(list.is_trusted(addr), "not a trusted issuer");
    _;
  }

}

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

library SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a, "add");
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a, "sub");
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "mul");
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0, "div");
        c = a / b;
    }
}
contract ERC20DepositPool is TrustListTools{
  using SafeMath for uint;

  address public erc20_token;
  mapping(address => uint) public all_deposits;
  mapping(address => uint) public locked_deposits;

  constructor(address _token, address _list) public TrustListTools(_list){
    erc20_token = _token;
  }

  event DepositPoolTransfer(address from, address to, uint amount);
  event OutsideTransfer(address from, address to, uint amount);
  event InternalTransfer(address from, address to, uint amount);
  event DepositERC20(address addr, uint amount);
  event WithdrawERC20(address addr, uint amount);

  event LockERC20(address from, address addr, uint amount);
  event UnlockERC20(address from, address addr, uint amount);

  function deposit(uint _amount) public returns (bool){
    TransferableToken token = TransferableToken(erc20_token);
    uint old_balance = token.balanceOf(address(this));
    (bool ret, ) = erc20_token.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), _amount));
    require(ret, "ERC20DepositPool, transferFrom return false");
    uint new_balance = token.balanceOf(address(this));
    require(new_balance == old_balance + _amount, "ERC20DepositPool:deposit, invalid deposit");

    all_deposits[msg.sender] = all_deposits[msg.sender].safeAdd(_amount);
    emit DepositERC20(msg.sender, _amount);
    return true;
  }

  function transfer(address _to, uint _amount) public returns (bool){
    require(_to != address(0x0), "invalid address");
    require (all_deposits[msg.sender] >= locked_deposits[msg.sender], "already locked too much");
    require (all_deposits[msg.sender].safeSub(locked_deposits[msg.sender]) >= _amount, "not enough deposit, maybe locked already");

    all_deposits[msg.sender] = all_deposits[msg.sender].safeSub(_amount);
    all_deposits[_to] = all_deposits[_to].safeAdd(_amount);

    emit DepositPoolTransfer(msg.sender, _to, _amount);
    return true;
  }

  function withdraw(uint _amount) public returns(bool){
    require (all_deposits[msg.sender] >= locked_deposits[msg.sender], "already locked too much");
    require (all_deposits[msg.sender].safeSub(locked_deposits[msg.sender]) >= _amount, "not enough deposit, maybe locked already");

    all_deposits[msg.sender] = all_deposits[msg.sender].safeSub(_amount);

    (bool ret, ) = erc20_token.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, _amount));
    require(ret, "ERC20DepositPool:withdraw, transfer return false");
    emit WithdrawERC20(msg.sender, _amount);
    return true;
  }

  function lock(address addr, uint amount) public is_trusted(msg.sender) returns (bool){
    require(addr != address(0x0), "invalid address");
    require(all_deposits[addr] >= amount, "not enough deposit");
    require(all_deposits[addr].safeSub(locked_deposits[addr]) >= amount, "not enough deposit because of already locked" );

    locked_deposits[addr] = locked_deposits[addr].safeAdd(amount);

    emit LockERC20(msg.sender, addr, amount);
    return true;
  }

  function unlock(address addr, uint amount) public is_trusted(msg.sender) returns(bool){
    require(locked_deposits[addr] >= amount, "unlock too much");
    locked_deposits[addr] = locked_deposits[addr].safeSub(amount);
    emit UnlockERC20(msg.sender, addr, amount);
    return true;
  }

  function outside_transfer(address from, address to, uint _amount) public is_trusted(msg.sender) returns(bool){
    require(to != address(0x0), "invalid address");
    require (all_deposits[from] >= locked_deposits[from], "already locked too much");
    require (all_deposits[from].safeSub(locked_deposits[from]) >= _amount, "not enough deposit, maybe locked already");

    all_deposits[from] = all_deposits[from].safeSub(_amount);

    (bool ret, ) = erc20_token.call(abi.encodeWithSignature("transfer(address,uint256)", to, _amount));
    require(ret, "ERC20DepositPool:outside_transfer, transfer return false");

    emit OutsideTransfer(from, to, _amount);
    return true;
  }

  function internal_transfer(address from, address to, uint _amount) public is_trusted(msg.sender) returns(bool){
    require(to != address(0x0), "invalid address");
    require (all_deposits[from] >= locked_deposits[from], "already locked too much");
    require (all_deposits[from].safeSub(locked_deposits[from]) >= _amount, "not enough deposit, maybe locked already");

    all_deposits[from] = all_deposits[from].safeSub(_amount);
    all_deposits[to] = all_deposits[to].safeAdd(_amount);

    emit InternalTransfer(from, to, _amount);
    return true;
  }

  function lockedOf(address addr) public view returns(uint){
    return locked_deposits[addr];
  }
  function balanceOf(address addr) public view returns (uint){
    return all_deposits[addr];
  }
}

contract ERC20DepositPoolFactory{
  event NewERC20DepositPool(address addr);

  function createERC20DepositPool(address token_addr, address _list) public returns(address){
    ERC20DepositPool dp = new ERC20DepositPool(token_addr, _list);
    emit NewERC20DepositPool(address (dp));
    return address(dp);
  }
}