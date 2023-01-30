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

contract IERC20Auction{
 function is_expired() public view returns(bool);

 function is_finished() public view returns(bool);

 function auction_expiration() public returns(bool);
}

contract IERC20AuctionFactory{

  function createERC20Auction(address _auction_proxy,
              uint _min_obj_amount,
              uint _min_bid_price,
              uint _obj_price_unit,
              uint _start_block,
              uint _end_block,
              address _creator,
              address _multisig
                             ) public returns(address);

}
contract IERC20DepositPool {
  event Transfer(address from, address to, uint amount);
  event OutsideTransfer(address from, address to, uint amount);
  event InternalTransfer(address from, address to, uint amount);
  event DepositERC20(address addr, uint amount);
  event WithdrawERC20(address addr, uint amount);

  event LockERC20(address from, address addr, uint amount);
  event UnlockERC20(address from, address addr, uint amount);

  function deposit(uint _amount) public returns (bool);

  function transfer(address _to, uint _amount) public returns (bool);

  function withdraw(uint _amount) public returns(bool);

  function lock(address addr, uint amount) public  returns (bool);

  function unlock(address addr, uint amount) public  returns(bool);

  function outside_transfer(address from, address to, uint _amount) public returns(bool);

  function internal_transfer(address from, address to, uint amount) public returns(bool);
}

contract IERC20AuctionOpProxy {
  function add_auction(address _auction) public;
  function apply_bid(address addr, uint amount, uint price, uint price_unit) public;
  function revoke_bid(address addr, uint amount, uint price, uint price_unit) public;
  function apply_auction(address addr, uint amount, uint price, uint price_unit) public;
  function object_token() public view returns(address, string memory);
  function object_total_amount() public view returns(uint);
}


contract ERC20TokenBankInterface{
  function balance() public view returns(uint);
  function token() public view returns(address, string memory);
  function issue(address _to, uint _amount) public returns (bool success);
}


contract ERC20Auction is IERC20Auction, MultiSigTools, TokenClaimer{

  IERC20AuctionOpProxy public auction_proxy;

  uint public minimum_object_amount;
  uint public minimum_bid_price;
  uint public obj_price_unit;

  uint public auction_start_block;
  uint public auction_end_block;


  address public current_buyer;
  uint public current_bid_price;
  uint public current_bid_amount;
  bool public is_auction_settled;
  address public auction_creator;

  constructor(address _auction_proxy,
              uint _min_obj_amount,
              uint _min_bid_price,
              uint _obj_price_unit,
              uint _start_block,
              uint _end_block,
              address _creator,
              address _multisig
) public MultiSigTools(_multisig){
    auction_proxy = IERC20AuctionOpProxy(_auction_proxy);
    minimum_object_amount = _min_obj_amount;
    minimum_bid_price = _min_bid_price;
    obj_price_unit = _obj_price_unit;
    auction_start_block = _start_block;
    auction_end_block = _end_block;
    auction_creator = _creator;
    current_buyer = address(0x0);
    current_bid_price = 0;
    current_bid_amount = 0;
    is_auction_settled = false;
  }

  function auction_info() public view returns (uint _min_obj_amount, uint _min_bid_price,
                                              uint _obj_price_unit, uint _start_block,
                                              uint _end_block){
    return (minimum_object_amount, minimum_bid_price, obj_price_unit, auction_start_block, auction_end_block);
  }

  function hammer_info() public view returns (address buyer, uint price, uint amount){
    require(is_auction_settled, "no hammer price until auction expired");
    buyer = current_buyer;
    price = current_bid_price;
    amount = current_bid_amount;
  }

  function object_token() public view returns(address, string memory){
    return auction_proxy.object_token();
  }
  function object_total_amount() public view returns(uint){
    return auction_proxy.object_total_amount();
  }

  event Bid(address addr, uint amount, uint price);

  function bid(uint amount, uint price) public returns (bool){
    require(block.number >= auction_start_block, "not start yet");
    require(block.number <= auction_end_block, "already expired");
    require(price >= current_bid_price, "should bid with higher price than current bid");
    require(price >= minimum_bid_price, "should be higher than the reserve price");
    require(amount >= minimum_object_amount, "should be more than minimum object amount");
    require(msg.sender != current_buyer, "you already got the bid");
    if(price == current_bid_price){
      require(amount > current_bid_amount, "same bid price should come with more amount");
    }

    require(amount <= object_total_amount(), "not enough object token for bid");

    auction_proxy.apply_bid(msg.sender, amount, price, obj_price_unit);

    if(current_buyer != address(0x0)){
      auction_proxy.revoke_bid(current_buyer, current_bid_amount, current_bid_price, obj_price_unit);
    }
    current_buyer = msg.sender;
    current_bid_price = price;
    current_bid_amount = amount;
    emit Bid(msg.sender, amount, price);
    return true;
  }

  function is_expired() public view returns(bool){
    return block.number > auction_end_block;
  }

  function is_finished() public view returns(bool){
    return is_auction_settled;
  }

  function auction_expiration() public returns (bool){
    require(block.number > auction_end_block, "not expired yet");
    require(!is_auction_settled, "auction settled already");
    if(current_buyer == address(0x0)){
      is_auction_settled = true;
      return true;
    }
    auction_proxy.apply_auction(current_buyer, current_bid_amount, current_bid_price, obj_price_unit);

    is_auction_settled = true;
    return true;
  }

  function claimStdTokens(uint64 id, address _token, address payable to) public only_signer is_majority_sig(id, "claimStdTokens"){
    _claimStdTokens(_token, to);
  }
}