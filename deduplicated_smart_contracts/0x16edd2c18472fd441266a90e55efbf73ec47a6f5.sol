/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.4.21;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
        return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Erc20Token {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 }

contract Base  {
    using SafeMath for uint;
    uint64 public currentEventId = 1;                            
    function getEventId() internal returns(uint64 _result) {      
        _result = currentEventId;
        currentEventId ++;
    }

    mapping (address => mapping (address => uint)) public tokenUserAmountOf;      //mapping of token addresses to mapping of account balances (token=0 means Ether)
    event OnDeposit(address indexed _token, address indexed _user, uint _amount, uint _balance, uint64 _eventId);
    event OnWithdraw(address indexed _token, address indexed _user, uint _amount, uint _balance, uint64 _eventId);

    function deposit() payable external {
        _deposit();
    }

    function _deposit() internal {
        tokenUserAmountOf[address(0x0)][msg.sender] = tokenUserAmountOf[address(0x0)][msg.sender].add(msg.value);
        emit OnDeposit(address(0x0), msg.sender, msg.value, tokenUserAmountOf[address(0x0)][msg.sender], getEventId());
    }

    function withdraw(uint _amount) external {
        require(tokenUserAmountOf[address(0x0)][msg.sender] >= _amount);
        tokenUserAmountOf[address(0x0)][msg.sender] = tokenUserAmountOf[address(0x0)][msg.sender].sub(_amount);
        msg.sender.transfer(_amount);
        emit OnWithdraw(address(0x0), msg.sender, _amount, tokenUserAmountOf[address(0x0)][msg.sender], getEventId());
    }

    function depositToken(address _token, uint _amount) external {
        //remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.
        require(_token != address(0x0));
        // require(Erc20Token(_token).transferFrom(msg.sender, address(this), _amount));
        Erc20Token(_token).transferFrom(msg.sender, address(this), _amount);
        tokenUserAmountOf[_token][msg.sender] = tokenUserAmountOf[_token][msg.sender].add(_amount);
        emit OnDeposit(_token, msg.sender, _amount, tokenUserAmountOf[_token][msg.sender], getEventId());
    }
       
    function testDepositToken(address _token, address _user, uint _amount) external view returns (bool _result) {
        require(_token != address(0x0));
        require(_user != address(0x0));
        require(_amount > 0);
        _result = Erc20Token(_token).allowance(_user, address(this)) >= _amount;
    }

    function testAllowance(address _token, address _user) external view returns (uint _result) {
        _result = Erc20Token(_token).allowance(_user, address(this));
    }
    
    function withdrawToken(address _token, uint _amount) external {
        require(_token != address(0x0));
        require (tokenUserAmountOf[_token][msg.sender] >= _amount);
        tokenUserAmountOf[_token][msg.sender] = tokenUserAmountOf[_token][msg.sender].sub(_amount);
        // require(Erc20Token(_token).transfer(msg.sender, _amount));
        Erc20Token(_token).transfer(msg.sender, _amount);
        emit OnWithdraw(_token, msg.sender, _amount, tokenUserAmountOf[_token][msg.sender], getEventId());
    }
}

contract Gamma is Base {    

    mapping (address => mapping (bytes32 => bool)) public orders;         //User=>Hash(OrderId)=>Bool
    mapping (address => mapping (bytes32 => uint)) public orderFills;     //User=>Hash(OrderId)=>Uint

    event OnSell  (address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string _clientNonce, address _seller, uint64 _eventId);
    event OnBuy   (address _tokenGet, uint _okAmountGet, address _tokenGive, uint _okAmountGive, address _seller, address _buyer, bytes32 _sellHash, uint64 _eventId);
    event OnCancel(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string _clientNonce, address _seller, uint64 _eventId);

    function balanceOf(address token, address user) view external returns (uint _result) {
        _result = tokenUserAmountOf[token][user];
    }
    
    function getSellHash(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce) 
        public view returns (bytes32 _result)  
    {
        _result =  keccak256(this, _tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
    }
   
    function sell(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string  _clientNonce) external {
        require(_amountGet > 0 && _amountGive > 0);
        require(_tokenGet != _tokenGive);
        require(bytes(_clientNonce).length <= 32);
        require(_expires > block.number);

        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        orders[msg.sender][sellHash] = true;
        emit OnSell(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, msg.sender, getEventId());
    }

    function buy1(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string  _clientNonce, address _seller, uint _amount)
        external 
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if (orders[_seller][sellHash] && block.number <= _expires && orderFills[_seller][sellHash].add(_amount) <= _amountGet)
        {
            tradeBalance(_tokenGet, _amountGet, _tokenGive, _amountGive, _seller, _amount);
            orderFills[_seller][sellHash] = orderFills[_seller][sellHash].add(_amount);
            emit OnBuy(_tokenGet, _amount, _tokenGive, _amountGive.mul(_amount).div(_amountGet), _seller, msg.sender, sellHash, getEventId());
            return;
        }
        emit OnBuy(_tokenGet, 0, _tokenGive, 0, _seller, msg.sender, 0x0, getEventId());     //delete
        return;
    }
  
    function buy2(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce, address _seller, uint _amount, 
        uint8 v, bytes32 r, bytes32 s) public
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if (block.number <= _expires && orderFills[_seller][sellHash].add(_amount) <= _amountGet)        
        {
            if (orders[_seller][sellHash]) 
            {
                tradeBalance(_tokenGet, _amountGet, _tokenGive, _amountGive, _seller, _amount);
                orderFills[_seller][sellHash] = orderFills[_seller][sellHash].add(_amount);
                emit OnBuy(_tokenGet, _amount, _tokenGive, _amountGive.mul(_amount) / _amountGet, _seller, msg.sender, sellHash, getEventId());
                return;
            }
            else 
            if (ecrecover(sellHash,v,r,s) == _seller) 
            {
                tradeBalance(_tokenGet, _amountGet, _tokenGive, _amountGive, _seller, _amount);
                orderFills[_seller][sellHash] = orderFills[_seller][sellHash].add(_amount);
                emit OnBuy(_tokenGet, _amount, _tokenGive, _amountGive.mul(_amount) / _amountGet, _seller, msg.sender, sellHash, getEventId());
                return;
            }
            else
            {
                emit OnBuy(_tokenGet, 0, _tokenGive, 0, _seller, msg.sender, sellHash, getEventId());     //delete
                return;
            }
        }
        emit OnBuy(_tokenGet, 0, _tokenGive, 0, _seller, msg.sender, 0x0, getEventId());     //delete
        return;
    }

    function buy3(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce, address _seller, uint _amount, 
        bytes memory _sig) public
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if (block.number <= _expires && orderFills[_seller][sellHash].add(_amount) <= _amountGet)        
        {
            if (orders[_seller][sellHash]) 
            {
                tradeBalance(_tokenGet, _amountGet, _tokenGive, _amountGive, _seller, _amount);
                orderFills[_seller][sellHash] = orderFills[_seller][sellHash].add(_amount);
                emit OnBuy(_tokenGet, _amount, _tokenGive, _amountGive.mul(_amount) / _amountGet, _seller, msg.sender, sellHash, getEventId());
                return;
            }
            else if (getAddress(sellHash, _sig) == _seller) 
            {
                tradeBalance(_tokenGet, _amountGet, _tokenGive, _amountGive, _seller, _amount);
                orderFills[_seller][sellHash] = orderFills[_seller][sellHash].add(_amount);
                emit OnBuy(_tokenGet, _amount, _tokenGive, _amountGive.mul(_amount) / _amountGet, _seller, msg.sender, sellHash, getEventId());
                return;
            }
            else
            {
                emit OnBuy(_tokenGet, 0, _tokenGive, 0, _seller, msg.sender, sellHash, getEventId());     //delete
                return;
            }
        }
        emit OnBuy(_tokenGet, 0, _tokenGive, 0, _seller, msg.sender, 0x0, getEventId());     //delete
        return;
    }

    function tradeBalance(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, address _seller, uint _amount) private {
        // require(_seller != msg.sender);
        // return(_amount > 0);
        tokenUserAmountOf[_tokenGet][msg.sender]  = tokenUserAmountOf[_tokenGet][msg.sender].sub(_amount);
        tokenUserAmountOf[_tokenGet][_seller]     = tokenUserAmountOf[_tokenGet][_seller].add(_amount);
        uint t1Amount = _amountGive.mul(_amount).div(_amountGet);
        // return(t1Amount > 0);
        tokenUserAmountOf[_tokenGive][msg.sender] = tokenUserAmountOf[_tokenGive][msg.sender].add(t1Amount);
        tokenUserAmountOf[_tokenGive][_seller]    = tokenUserAmountOf[_tokenGive][_seller].sub(t1Amount);
    }

    function testBuy1(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce, address _seller, 
        uint _amount, address _buyer) view public returns(bool _result) 
    {
        _result = tokenUserAmountOf[_tokenGet][_buyer] >= _amount && availableVolume1(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, _seller) >= _amount;   
    }

    function testBuy2(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce, address _seller, 
        uint _amount, address _buyer, uint8 v, bytes32 r, bytes32 s) view public returns(bool _result) 
    {
        _result = tokenUserAmountOf[_tokenGet][_buyer] >= _amount && availableVolume2(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, _seller,  v,  r,  s) >= _amount;   
    }

    function testBuy3(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce, address _seller, 
        uint _amount, address _buyer, bytes memory _sig) view public returns(bool _result) 
    {
        _result = tokenUserAmountOf[_tokenGet][_buyer] >= _amount && availableVolume3(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, _seller,  _sig) >= _amount;   
    }

    function availableVolume1(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce, address _seller) 
        view public returns(uint _result) 
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if (orders[_seller][sellHash] && block.number <= _expires){
            uint a2 = tokenUserAmountOf[_tokenGive][_seller].mul(_amountGet).div(_amountGive);
            uint a1 = _amountGet.sub(orderFills[_seller][sellHash]);
            if (a1 < a2) return a1;
            return a2;
        }
        return 0;
    }
      
    function availableVolume2(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce, address _seller, 
        uint8 v, bytes32 r, bytes32 s)  public view returns(uint _result) 
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if ((orders[_seller][sellHash] || ecrecover(sellHash, v, r, s) == _seller) 
            && block.number <= _expires)
        {
            // uint a2 = tokenUserAmountOf[_tokenGive][_seller].mul( _amountGet) / _amountGive;
            // uint a1 = _amountGet.sub(orderFills[_seller][sellHash]);
            uint a2 = tokenUserAmountOf[_tokenGive][_seller].mul( _amountGet);
            a2 = a2 / _amountGive;
            uint a1 = _amountGet.sub(orderFills[_seller][sellHash]);
            if (a1 < a2) return a1;
            return a2;
        }
        return 0;
    }

    function availableVolume3(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string memory _clientNonce, address _seller, 
        bytes memory _sig)  public view returns(uint _result) 
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if ((orders[_seller][sellHash] || getAddress(sellHash, _sig) == _seller) 
            && block.number <= _expires)
        {
            // uint a2 = tokenUserAmountOf[_tokenGive][_seller].mul( _amountGet) / _amountGive;
            // uint a1 = _amountGet.sub(orderFills[_seller][sellHash]);
            uint a2 = tokenUserAmountOf[_tokenGive][_seller].mul( _amountGet);
            a2 = a2 / _amountGive;
            uint a1 = _amountGet.sub(orderFills[_seller][sellHash]);
            if (a1 < a2) return a1;
            return a2;
        }
        return 0;
    }

    function amountFilled(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string  _clientNonce, address _seller) 
        view external returns(uint) 
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        return orderFills[_seller][sellHash];
    }

    function cancelOrder1(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string  _clientNonce) external 
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if (orders[msg.sender][sellHash]){
            orderFills[msg.sender][sellHash] = _amountGet;
            emit OnCancel(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, msg.sender, getEventId());
        }
        emit OnCancel(_tokenGet, 0, _tokenGive, 0, _expires, _clientNonce, msg.sender, getEventId());
        return;
    }

    function cancelOrder2(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string  _clientNonce,
        uint8 v, bytes32 r, bytes32 s) external 
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if (orders[msg.sender][sellHash]){
            orderFills[msg.sender][sellHash] = _amountGet;
            emit OnCancel(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, msg.sender, getEventId());
            return;
        }
        else if (ecrecover(sellHash, v, r, s) ==  msg.sender){
            orderFills[msg.sender][sellHash] = _amountGet;
            emit OnCancel(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, msg.sender, getEventId());
            return;
        }
        emit OnCancel(_tokenGet, 0, _tokenGive, 0, _expires, _clientNonce, msg.sender, getEventId());
        return;
    }

    function cancelOrder3(address _tokenGet, uint _amountGet, address _tokenGive, uint _amountGive, uint _expires, string  _clientNonce,
        bytes  _sig) external 
    {
        bytes32 sellHash = getSellHash(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce);
        if (orders[msg.sender][sellHash]){
            orderFills[msg.sender][sellHash] = _amountGet;
            emit OnCancel(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, msg.sender, getEventId());
            return;
        }
        else if (getAddress(sellHash, _sig) ==  msg.sender){
            orderFills[msg.sender][sellHash] = _amountGet;
            emit OnCancel(_tokenGet, _amountGet, _tokenGive, _amountGive, _expires, _clientNonce, msg.sender, getEventId());
            return;
        }
        emit OnCancel(_tokenGet, 0, _tokenGive, 0, _expires, _clientNonce, msg.sender, getEventId());
        return;
    }

    function getAddress(bytes32 h, bytes memory sig) public pure returns (address _address) 
    {
        bytes32 _r;
        bytes32 _s;
        uint8 _v;
        if (sig.length == 65) {
            assembly {
                _r := mload(add(sig, 32))
                _s := mload(add(sig, 64))
                _v := and(mload(add(sig, 65)), 255)
            }
            if (_v < 27) {
                _v += 27;
            }
            if (_v == 27 || _v == 28) {
                _address = ecrecover(h, _v, _r, _s);
            }
        }
    }

    function() payable external {
        // require(1 == 2); //selfdestruct(_to);
        if(msg.value > 0){
            _deposit();
        }
    }

    
    function testGetRSV(bytes32 h, bytes memory sig) public pure returns (address _address,  bytes32 _r, bytes32 _s, uint8 _v) 
    {
        if (sig.length == 65) {
            assembly {
                _r := mload(add(sig, 32))
                _s := mload(add(sig, 64))
                _v := and(mload(add(sig, 65)), 255)
            }
            if (_v < 27) {
                _v += 27;
            }
            if (_v == 27 || _v == 28) {
                _address = ecrecover(h, _v, _r, _s);
            }
        }
    }


}