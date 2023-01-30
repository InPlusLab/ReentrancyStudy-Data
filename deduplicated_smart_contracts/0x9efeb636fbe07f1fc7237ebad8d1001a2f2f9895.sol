/**
 *Submitted for verification at Etherscan.io on 2019-12-05
*/

pragma solidity >=0.4.21 <0.6.0;

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

contract TokenInterface is TransferableToken{
    function destroyTokens(address _owner, uint _amount) public returns (bool);
    function generateTokens(address _owner, uint _amount) public returns (bool);
}

contract DoubleCurveFund is TokenClaimer, MultiSigTools{
  using SafeMath for uint;

  string public desc;
  address public native_token;
  address public exchange_token;

  uint public t; // y param
  uint public s; // x param
  uint public l; // ratio

  uint internal x; // remain token in current section
  uint internal m; // section no. from 0
  uint internal rest;
  uint internal exp;

  bool public paused;

  uint public withdraw;
  uint public profit;
  uint public total_exchange_token;

  event Fund(address addr, uint amount, uint remain, uint got_amount);
  event Exchange(address addr, uint amount, uint remain, uint got_amount);

  constructor(address _native_token,
              address _exchange_token,
              uint _t,
              uint _s,
              uint _l,
              address _multisig
             ) public MultiSigTools(_multisig){
               t = _t;
               s = _s;
               l = _l;
               native_token = _native_token;
               exchange_token = _exchange_token;

               x = 1;
               m = 0;
               rest = SafeMath.safeSub(s.safeMul(t.safeDiv(2)), t.safeDiv(2));
               exp = 1;

               withdraw = 0;
               profit = 0;
               total_exchange_token = 0;
               paused = false;
             }

  function balance() public returns(uint){
    TransferableToken token = TransferableToken(address(exchange_token));
    return token.balanceOf(address(this));
  }


  function claimStdTokens(uint64 id, address _token, address payable to) public only_signer is_majority_sig(id, "claimStdTokens"){
    require(_token != exchange_token);
    _claimStdTokens(_token, to);
  }
  modifier when_paused(){
    require(paused == true, "require paused");
    _;
  }
  modifier when_not_paused(){
    require(paused == false, "require not paused");
    _;
  }

  function pause(uint64 id) public only_signer is_majority_sig(id, "pause"){
    paused = true;
  }
  function unpause(uint64 id) public only_signer is_majority_sig(id, "unpause"){
    paused = false;
  }

  function current_exchange_price() public view returns(uint) {
    uint t1 = m.safeMul(t);
    uint t2 = x.safeSub((exp - 1).safeMul(s)) * t;
    uint t3 = exp * s;

    return t1 + t2.safeDiv(t3);
  }

  function set_desc(uint64 id, string memory _desc) public only_signer is_majority_sig(id, "set_desc"){
    desc = _desc;
  }

  function withdraw_profit(uint64 id, address _addr, uint amount)
    public
    only_signer
    is_majority_sig(id, "withdraw_profit")
    returns(bool){
    require(amount > 0, "withdraw_profit, amount should be > 0");
    require(amount + withdraw <= profit, "claim too much!");

    TransferableToken token = TransferableToken(exchange_token);
    uint old_balance = token.balanceOf(address(this));
    (bool ret, ) = exchange_token.call(abi.encodeWithSignature("transfer(address,uint256)", _addr, amount));
    require(ret, "DoubleCurveFund:withdraw_profit, transfer return false");
    uint new_balance = token.balanceOf(address(this));
    require(new_balance == old_balance + amount, "DoubleCurveFund:withdraw_profit, invalid transfer");
    withdraw += amount;
    return true;
  }

  function fund(uint amount) public when_not_paused returns(bool){
    require(amount > 0, "fund, amount should be > 0");
    (uint remain, uint native_amount) = _fund(amount);
    require(native_amount != 0, "amount too small");

    amount = amount - remain;

    TransferableToken token = TransferableToken(exchange_token);
    uint old_balance = token.balanceOf(address(this));
    (bool ret, ) = exchange_token.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), amount));
    require(ret, "DoubleCurveFund:fund, transferFrom return false");
    uint new_balance = token.balanceOf(address(this));
    require(new_balance == old_balance + amount, "DoubleCurveFund:fund, invalid transfer");
    if(native_amount > 0){
      TokenInterface ti = TokenInterface(native_token);
      ti.generateTokens(msg.sender, native_amount);
    }
    emit Fund(msg.sender, amount, remain, native_amount);
    return true;
  }


  function _fund(uint _amount) internal returns(uint exchange_amount, uint native_amount){
    uint api = 0;
    uint amount = _amount;

    while(amount >= rest){
      amount = amount.safeSub(rest);
      exp = exp.safeMul(2);
      m += 1;
      uint tmp = (exp - 1).safeMul(s);
      api += tmp.safeSub(x);
      rest = (exp.safeMul(m) + exp.safeDiv(2)).safeMul(s).safeMul(t).safeSub(t.safeDiv(2));
      x = tmp;
    }
    uint a = x.safeSub((exp-1).safeMul(s));
    (uint b, bool status) = binary(a, amount);
    if(!status){
      uint t1 = m.safeMul(t).safeMul(b + 1 - a);
      uint t2 = t.safeMul(b + 1 - a).safeMul(b + a);
      uint t3 = s.safeMul(exp).safeMul(2);
      uint c = t1.safeAdd(t2.safeDiv(t3));

      rest = rest.safeSub(c);
      x = x.safeAdd(b-a + 1);
      api = api.safeAdd(b-a+1);
      amount = amount.safeSub(c);
    }
    uint tmp = _amount.safeSub(amount);
    uint c = tmp.safeMul(l).safeDiv(10000);

    profit = profit.safeAdd(tmp.safeSub(c));
    total_exchange_token = total_exchange_token.safeAdd(tmp);

    return (amount, api);
  }

  function binary(uint _x, uint _amount) internal view returns(uint, bool){
    uint min = x;
    uint max = exp.safeMul(s);
    uint y = max;

    uint v = m.safeMul(t).safeAdd(min.safeMul(t).safeDiv(t));
    if(_amount < v){
      return (0, true);
    }

    while(min < max){
      uint b = min.safeAdd(max).safeDiv(2);
      uint t1 = m.safeMul(t).safeMul(b+1 - _x);
      uint t2 = t.safeMul(b+1 - _x).safeMul(b + _x).safeDiv(y.safeMul(2));
      uint c = t1.safeAdd(t2);
      if(_amount < c){
        max = b.safeSub(1);
      }
      if(_amount >= c){
        min = b.safeAdd(1);
      }
    }
    uint t1 = m.safeMul(t).safeMul(max + 1 - _x) ;
    uint t2 = t.safeMul(_x + max).safeMul(max + 1 - _x).safeDiv(y.safeMul(2));
    uint c = t1.safeAdd(t2);
    if(c > _amount){
      max = max - 1;
    }
    return (max, false);
  }

  function exchange(uint amount) public when_not_paused returns(bool){
    require(amount > 0, "exchange, amount should be > 0");
    TransferableToken token = TransferableToken(native_token);
    uint b = token.balanceOf(msg.sender);
    require(b >= amount, "not enough amount");

    uint exchange_amount = _exchange(amount);
    require(exchange_amount != 0, "no exchanges");

    (bool ret, ) = exchange_token.call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, exchange_amount));
    require(ret, "DoubleCurveFund:exchange 1, transfer return false");
    TokenInterface ti = TokenInterface(native_token);
    ti.destroyTokens(msg.sender, amount);

    emit Exchange(msg.sender, amount, 0, exchange_amount);
    return true;
  }
  function _exchange(uint _api) internal returns(uint exchange_token_amount){
    uint amount = 0;
    uint api = _api;
    if(api == 0){return 0;}

    uint restsell = rest.safeMul(l).safeDiv(10000);
    uint tt = t.safeMul(l).safeDiv(10000);
    while (api > 0 && api > x.safeSub((exp - 1).safeMul(s))){
      api = api.safeSub(x.safeSub((exp - 1).safeMul(s)));
      uint k = (exp.safeMul(m).safeAdd(exp.safeDiv(2))).safeMul(s).safeMul(tt);
      amount = amount.safeAdd(k.safeSub(tt.safeDiv(2)).safeSub(restsell));
      x = (exp - 1).safeMul(s);
      m = m.safeSub(1);
      exp = exp.safeDiv(2);
      restsell = 0;
    }
    uint kx = x.safeSub((exp - 1).safeMul(s));
    uint t1 = m.safeMul(tt).safeMul(api);
    uint t2 = (kx.safeMul(2).safeSub(api).safeSub(1)).safeMul(api).safeMul(tt);
    uint t3 = s.safeMul(exp).safeMul(2);
    amount = amount.safeAdd(t1.safeAdd(t2.safeDiv(t3)));

    x = x.safeSub(api);
    restsell = restsell.safeAdd(amount);
    rest = restsell.safeMul(10000).safeDiv(l);
    total_exchange_token = total_exchange_token.safeSub(amount.safeSub(1));
    return amount.safeSub(1);
  }
}

contract DoubleCurveFundFactory{
  event NewDoubleCurveFund(address addr);
  function createDoubleCurveFund(address _native_token,
                                 address _exchange_token,
                                 address _multisig,
                                 uint _t, //y param
                                 uint _s, //x param
                                 uint _l  //profit ratio * 10000
                                ) public returns(address){
    DoubleCurveFund c = new DoubleCurveFund(_native_token, _exchange_token, _t, _s, _l, _multisig);
    emit NewDoubleCurveFund(address(c));
    return address(c);
  }
}