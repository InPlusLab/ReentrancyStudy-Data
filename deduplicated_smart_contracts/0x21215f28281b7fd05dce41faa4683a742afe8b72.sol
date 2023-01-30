/**
 *Submitted for verification at Etherscan.io on 2020-04-02
*/

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



contract AddressList{
  using AddressArray for address[];
  mapping(address => bool) private address_status;
  address[] public addresses;

  constructor() public{}

  function get_all_addresses() public view returns(address[] memory){
    return addresses;
  }

  function get_address(uint i) public view returns(address){
    require(i < addresses.length, "AddressList:get_address, out of range");
    return addresses[i];
  }

  function get_address_num() public view returns(uint){
    return addresses.length;
  }

  function is_address_exist(address addr) public view returns(bool){
    return address_status[addr];
  }

  function _add_address(address addr) internal{
    if(address_status[addr]) return;
    address_status[addr] = true;
    addresses.push(addr);
  }

  function _remove_address(address addr) internal{
    if(!address_status[addr]) return;
    address_status[addr] = false;
    addresses.remove(addr);
  }

  function _reset() internal{
    for(uint i = 0; i < addresses.length; i++){
      address_status[addresses[i]] = false;
    }
    delete addresses;
  }
}

contract TrustList is AddressList, MultiSigTools{

  event AddTrust(address addr);
  event RemoveTrust(address addr);

  constructor(address[] memory _list, address _multisig) public MultiSigTools(_multisig){
    for(uint i = 0; i < _list.length; i++){
      _add_address(_list[i]);
    }
  }

  function is_trusted(address addr) public view returns(bool){
    return is_address_exist(addr);
  }

  function get_trusted(uint i) public view returns(address){
    return get_address(i);
  }

  function get_trusted_num() public view returns(uint){
    return get_address_num();
  }

  function add_trusted(uint64 id, address addr) public
    only_signer is_majority_sig(id, "add_trusted"){
    _add_address(addr);
    emit AddTrust(addr);
  }
  function add_multi_trusted(uint64 id, address[] memory _list) public
    only_signer is_majority_sig(id, "add_multi_trusted"){
    for(uint i = 0; i < _list.length; i++){
      _add_address(_list[i]);
      emit AddTrust(_list[i]);
    }
  }

  function remove_trusted(uint64 id, address addr) public
    only_signer is_majority_sig(id, "remove_trusted"){
    _remove_address(addr);
    emit RemoveTrust(addr);
  }

  function remove_multi_trusted(uint64 id, address[] memory _list) public
  only_signer is_majority_sig(id, "remove_multi_trusted"){
    for(uint i = 0; i < _list.length; i++){
      _remove_address(_list[i]);
      emit RemoveTrust(_list[i]);
    }
  }
}

contract TrustListFactory{
  event NewTrustList(address addr, address[] list, address multisig);

  function createTrustList(address[] memory _list, address _multisig) public returns(address){
    TrustList tl = new TrustList(_list, _multisig);
    emit NewTrustList(address(tl), _list, _multisig);
    return address(tl);
  }
}

contract IERC20AuctionOpProxy {
  function add_auction(address _auction) public;
  function apply_bid(address addr, uint amount, uint price, uint price_unit) public;
  function revoke_bid(address addr, uint amount, uint price, uint price_unit) public;
  function apply_auction(address addr, uint amount, uint price, uint price_unit) public;
  function object_token() public view returns(address, string memory);
  function object_total_amount() public view returns(uint);
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
contract ERC20TokenBankInterface{
  function balance() public view returns(uint);
  function token() public view returns(address, string memory);
  function issue(address _to, uint _amount) public returns (bool success);
}

contract ERC20AuctionOpProxy is AddressList, IERC20AuctionOpProxy, MultiSigTools{
  using SafeMath for uint;

  ERC20TokenBankInterface public object_erc20_pool;
  address public exchange_erc20_token;
  address public benifit_pool;

  address public auction_mgr_contract;

  constructor(address _object_erc20_pool,
              address _exchange_erc20_token,
              address _benifit_pool,
             address _auction_mgr,
             address _multisig) public AddressList()
             MultiSigTools(_multisig){

    object_erc20_pool = ERC20TokenBankInterface(_object_erc20_pool);
    exchange_erc20_token = _exchange_erc20_token;
    benifit_pool = _benifit_pool;
    auction_mgr_contract = _auction_mgr;
  }


  function add_auction(address _auction) public{
    require (msg.sender == auction_mgr_contract, "only auction mgr can op this");
    _add_address(_auction);
  }

  function apply_bid(address addr, uint amount, uint price, uint price_unit) public{
    require(is_address_exist(msg.sender), "only trusted auction contract can op this");

    uint total = amount.safeMul(price).safeDiv(price_unit);
    //exchange_deposit_pool.lock(addr, total);
    TransferableToken token = TransferableToken(exchange_erc20_token);
    uint old_balance = token.balanceOf(address(this));
    (bool ret, ) = exchange_erc20_token.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", addr, address(this), total));
    require(ret, "ERC20AuctionOpProxy, transferFrom return false. Please make sure you have enough token and approved them for auction.");
    uint new_balance = token.balanceOf(address(this));
    require(new_balance == old_balance + total, "ERC20TokenAuctionOpProxy, apply_bid, invalid bid");
  }

  function revoke_bid(address addr, uint amount, uint price, uint price_unit) public{
    require(is_address_exist(msg.sender), "only trusted auction contract can op this");
    uint old_total = amount.safeMul(price).safeDiv(price_unit);

    (bool ret, ) = exchange_erc20_token.call(abi.encodeWithSignature("transfer(address,uint256)", addr, old_total));
    require(ret, "ERC20AuctionOpProxy, revoke_bid, transfer return false");
    //exchange_deposit_pool.unlock(addr, old_total);
  }

  function apply_auction(address addr, uint amount, uint price, uint price_unit) public{
    require(is_address_exist(msg.sender), "only trusted auction contract can op this");
    uint total = amount.safeMul(price).safeDiv(price_unit);

    TransferableToken token = TransferableToken(exchange_erc20_token);
    uint old_balance = token.balanceOf(benifit_pool);
    (bool ret, ) = exchange_erc20_token.call(abi.encodeWithSignature("transfer(address,uint256)", benifit_pool, total));
    require(ret, "ERC20AuctionOpProxy, apply_auction, transfer return false");
    uint new_balance = token.balanceOf(benifit_pool);
    require(new_balance == old_balance + total, "ERC20AuctionOpProxy, apply_auction, invalid transfer");

    //exchange_deposit_pool.outside_transfer(addr, benifit_pool, total);
    //exchange_deposit_pool.unlock(addr, total);
    object_erc20_pool.issue(addr, amount);
  }

  function object_token() public view returns(address, string memory){
    return object_erc20_pool.token();
  }
  function object_total_amount() public view returns(uint){
    return object_erc20_pool.balance();
  }

  event ChangeObjectERC20Pool(address old_addr, address new_addr);
  function change_object_erc20_pool(uint64 id, address new_pool) public only_signer is_majority_sig(id, "change_object_erc20_pool"){
    require(new_pool != address(0x0), "invalid address");
    address old_addr = address(object_erc20_pool);
    object_erc20_pool = ERC20TokenBankInterface(new_pool);

    emit ChangeObjectERC20Pool(old_addr, new_pool);
  }

  event ChangeBenifitPool(address old_addr, address new_addr);
  function change_benifit_pool(uint64 id, address new_pool) public only_signer is_majority_sig(id, "change_benifit_pool"){
    require(new_pool != address(0x0), "invalid address");
    address old = benifit_pool;
    benifit_pool = new_pool;
    emit ChangeBenifitPool(old, benifit_pool);
  }
}

contract ERC20AuctionOpProxyFactory{
  event NewERC20AuctionOpProxy(address addr);
  function createERC20AuctionOpProxy(address _object_erc20_pool,
              address _exchange_erc20_token,
              address _benifit_pool, address _auction_mgr, address _multisig) public returns(address){
                ERC20AuctionOpProxy proxy = new ERC20AuctionOpProxy(_object_erc20_pool,
                                                                   _exchange_erc20_token, _benifit_pool, _auction_mgr, _multisig);

                emit NewERC20AuctionOpProxy(address(proxy));
                return address(proxy);
  }
}