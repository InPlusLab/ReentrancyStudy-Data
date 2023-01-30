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

contract ERC20PeriodAuction is MultiSigTools{
  IERC20AuctionOpProxy public auction_proxy;

  uint public minimum_object_amount;
  uint public minimum_bid_price;
  uint public obj_price_unit;

  uint public auction_period;
  bool public auction_paused;

  IERC20AuctionFactory public auction_factory;

  IERC20Auction public current_auction;

  mapping (address => bool) private trusted_auctions;

  constructor(uint _min_obj_amount,
              uint _min_bid_price,
              uint _obj_price_unit,
              uint _auction_period,
              address _auction_factory,
             address _multisig) public MultiSigTools(_multisig){
    minimum_object_amount = _min_obj_amount;
    minimum_bid_price = _min_bid_price;
    obj_price_unit = _obj_price_unit;

    auction_period = _auction_period;
    auction_factory = IERC20AuctionFactory(_auction_factory);
    auction_paused = false;
  }

  function unpause_auction(uint64 id) public only_signer is_majority_sig(id, "unpause_auction"){
    require(auction_paused, "already unpaused");
    auction_paused = false;
  }
  function pause_auction(uint64 id) public only_signer is_majority_sig(id, "pause_auction"){
    require(!auction_paused, "already paused");
    auction_paused = true;
  }

  event ChangeAuctionProxy(address old_addr, address new_addr);
  function change_auction_proxy(uint64 id, address new_proxy) public only_signer is_majority_sig(id, "change_auction_proxy"){
    require(new_proxy != address(0x0), "invalid address");
    if(address(current_auction) != address(0x0)){
      require(current_auction.is_finished(), "current auction is not finished");
    }
    address old = address(auction_proxy);
    auction_proxy = IERC20AuctionOpProxy(new_proxy);
    emit ChangeAuctionProxy(old, new_proxy);
  }

  event ChangeMinObjAmount(uint old_amount, uint new_amount);
  function change_minimum_object_amount(uint64 id, uint new_amount) public only_signer is_majority_sig(id, "change_minimum_object_amount"){
    require(new_amount != 0, "invalid amount");
    if(address(current_auction) != address(0x0)){
      require(current_auction.is_finished(), "current auction is not finished");
    }
    uint old = minimum_object_amount;
    minimum_object_amount = new_amount;
    emit ChangeMinObjAmount(old, new_amount);
  }

  event ChangeMinBidPrice(uint old_price, uint new_price);
  function change_min_bid_price(uint64 id, uint new_price) public only_signer is_majority_sig(id, "change_min_bid_price"){
    require(new_price != 0, "invalid price");
    if(address(current_auction) != address(0x0)){
      require(current_auction.is_finished(), "current auction is not finished");
    }
    uint old = minimum_bid_price;
    minimum_bid_price = new_price;
    emit ChangeMinBidPrice(old, new_price);
  }

  event ChangeAuctionObjPriceUnit(uint old_unit, uint new_unit);
  function change_auction_obj_price_unit(uint64 id, uint new_unit) public only_signer is_majority_sig(id, "change_auction_obj_price_unit"){
    require(new_unit >=1, "invalid unit");
    if(address(current_auction) != address(0x0)){
      require(current_auction.is_finished(), "current auction is not finished");
    }
    uint old = obj_price_unit;
    obj_price_unit = new_unit;
    emit ChangeAuctionObjPriceUnit(old, new_unit);
  }

  event ChangeAuctionPeriod(uint old_period, uint new_period);
  function change_auction_period(uint64 id, uint new_period) public only_signer is_majority_sig(id, "change_auction_period"){
    require(new_period > 1, "invalid period");
    if(address(current_auction) != address(0x0)){
      require(current_auction.is_finished(), "current auction is not finished");
    }
    uint old = auction_period;
    auction_period = new_period;
    emit ChangeAuctionPeriod(old, auction_period);
  }

  event ChangeAuctionFactory(address old_factory, address new_factory);
  function change_auction_factory(uint64 id, address new_factory) public only_signer is_majority_sig(id, "change_auction_factory"){
    require(new_factory != address(0x0), "invalid address");
    if(address(current_auction) != address(0x0)){
      require(current_auction.is_finished(), "current auction is not finished");
    }
    address old = address(auction_factory);
    auction_factory = IERC20AuctionFactory(new_factory);
    emit ChangeAuctionFactory(old, new_factory);
  }

  event ChangeCurrentAuction(address old_auction, address new_auction);
  function change_current_auction(uint64 id, address new_auction) public only_signer is_majority_sig(id, "change_current_auction"){
    require(new_auction != address(0x0), "invalid address");
    if(address(current_auction) != address(0x0)){
      require(current_auction.is_finished(), "current auction is not finished");
    }
    address old = address(current_auction);
    current_auction = IERC20Auction(new_auction);
    trusted_auctions[new_auction] = true;
    emit ChangeCurrentAuction(old, new_auction);
    auction_proxy.add_auction(address(current_auction));
  }

  event NewAuction(address new_auction);
  function new_auction() public returns (address auction_address){
    require(!auction_paused, "auction already paused");
    require(address(auction_proxy) != address(0x0), "not ready for create auction");

    if(address(current_auction) != address(0x0)){
      require(current_auction.is_expired(), "current auction is not expired");
      if(!current_auction.is_finished()){
        current_auction.auction_expiration();
      }
      require(current_auction.is_finished(), "current auction cannot be finished");
    }


    address _current_auction = auction_factory.createERC20Auction(address(auction_proxy),
                                                        minimum_object_amount,
                                                        minimum_bid_price,
                                                        obj_price_unit,
                                                        block.number,
                                                        block.number + auction_period,
                                                        msg.sender,
                                                        address(multisig_contract)
                                                        );

    trusted_auctions[address(_current_auction)] = true;
    current_auction = IERC20Auction(_current_auction);
    auction_proxy.add_auction(address(current_auction));

    emit NewAuction(address(current_auction));
    return address(current_auction);
  }
}

contract ERC20PeriodAuctionFactory{
  event NewERC20PeriodAuction(address addr);
  function createERC20PeriodAuction(uint _min_obj_amount,
              uint _min_bid_price,
              uint _obj_price_unit,
              uint _auction_period,
              address _auction_factory,
             address _multisig) public returns(address){

               ERC20PeriodAuction auction = new ERC20PeriodAuction(
                 _min_obj_amount,
                 _min_bid_price,
                 _obj_price_unit,
                 _auction_period,
                 _auction_factory,
                 _multisig
               );

               emit NewERC20PeriodAuction(address(auction));

               return address(auction);
          }
}