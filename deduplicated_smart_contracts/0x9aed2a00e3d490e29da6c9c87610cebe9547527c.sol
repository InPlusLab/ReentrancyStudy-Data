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
        //call Token(address).approve(this, amount).
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
        //require(Erc20Token(_token).transfer(msg.sender, _amount));
        Erc20Token(_token).transfer(msg.sender, _amount);
        emit OnWithdraw(_token, msg.sender, _amount, tokenUserAmountOf[_token][msg.sender], getEventId());
    }
}

//质押贷款
contract Sigma is Base {    

    mapping (address => mapping (bytes32 => bool)) public orders;               //User=>Hash(OrderId)=>Bool
    mapping (address => mapping (bytes32 => uint)) public orderFills;           //User=>Hash(OrderId)=>Uint(_t1Amount2) ，记录卖出了多少，取消的时候是否质押物
    mapping (address => mapping (bytes32 => uint)) public claimsOf;             //User=>Hash(OrderId)=>Uint(_t1Amount2) ，债权列表，记录谁拥有多少；暂时不提供转让功能，毕竟都是短期投资
    mapping (address => mapping (bytes32 => uint)) public userOrderT2AmountOf;  //User=>Hash(OrderId)=>Uint(_t2Amount) ， 债权列表，记录谁拥有多少；暂时不提供转让功能，毕竟都是短期投资

    event OnBorrow    (address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string _clientNonce, address _borrower, uint64 _eventId);
    event OnBuyClaim  (uint _t1OkAmount1, uint _t1OkAmount2, uint _t2OkAmount, address _buyer, address _borrower, bytes32 _sellHash, string _clientNonce, uint64 _eventId);
    event OnCancel    (address _borrower, bytes32 _sellHash, string _clientNonce, uint64 _eventId);
    event OnGetPayment(uint _t1OkAmount2, uint _t2OkAmount, address _buyer, address _borrower, bytes32 _sellHash, string _clientNonce, uint64 _eventId);

    function balanceOf(address token, address user) view external returns (uint _result) {
        _result = tokenUserAmountOf[token][user];
    }
    
    function getSellHash(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string memory _clientNonce,
        address _borrower) public view returns (bytes32 _result)  
    {
        _result =  keccak256(this, _borrower, _t1, _t1Amount1, _t1Amount2, _t2, _t2Amount,  _loanMaxTime, _paymentTime, _clientNonce);
    }
   
    function borrow(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string   _clientNonce) 
        external 
    {
        require(_t1Amount1 > 0 && _t1Amount2 > 0 && _t2Amount > 0);
        require(_t1Amount1 < _t1Amount2);
        require(_t1 != _t2);
        require(bytes(_clientNonce).length <= 32);
        require(_loanMaxTime > now);
        require(_paymentTime > _loanMaxTime);
        bytes32 sellHash = getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,  _loanMaxTime,  _paymentTime,  _clientNonce, msg.sender);
        orders[msg.sender][sellHash] = true;
        emit OnBorrow (_t1,  _t1Amount1,  _t1Amount2,  _t2,  _t2Amount,  _loanMaxTime,  _paymentTime,  _clientNonce, msg.sender, getEventId());
    }

    function buyClaim1(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string   _clientNonce, 
        address _borrower, uint _buyerT1Amount1) external 
    {
        require(_loanMaxTime > now);
        bytes32 sellHash =  getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,  _loanMaxTime,  _paymentTime,  _clientNonce, _borrower);
        //uint buyerT1Amount2 = _buyerT1Amount1 + _buyerT1Amount1 * (_paymentTime - now) * (_t1Amount2 - _t1Amount1) / _t1Amount1 / (_paymentTime - _loanMaxTime);
        uint buyerT1Amount2 = getT1A2(_t1Amount1, _t1Amount2, _loanMaxTime, _paymentTime, _buyerT1Amount1);
        require(orders[_borrower][sellHash] && now <= _loanMaxTime && orderFills[_borrower][sellHash].add(buyerT1Amount2) <= _t1Amount2);
        
        uint _t2OkAmount = _t2Amount * buyerT1Amount2 / _t1Amount2;
        tradeBalance(sellHash, _t1, _buyerT1Amount1, buyerT1Amount2, _t2, _t2OkAmount,  _borrower);
        orderFills[_borrower][sellHash] = orderFills[_borrower][sellHash].add(buyerT1Amount2);
        emit OnBuyClaim (_buyerT1Amount1, buyerT1Amount2, _t2OkAmount, msg.sender, _borrower, sellHash, _clientNonce, getEventId());
    }

    function buyClaim2(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint[] memory _Time, string memory _clientNonce, 
        address _borrower, uint _buyerT1Amount1, uint8 v, bytes32[] memory rs) public 
    {
        require(_Time[0] > now);
        bytes32 sellHash =  getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,  _Time[0],  _Time[1],  _clientNonce, _borrower);
        require(ecrecover(sellHash,v,rs[0],rs[1]) == _borrower);
        uint buyerT1Amount2 = getT1A2(_t1Amount1, _t1Amount2, _Time[0], _Time[1], _buyerT1Amount1);
        require(orderFills[_borrower][sellHash].add(buyerT1Amount2) <= _t1Amount2);
        uint _t2OkAmount = _t2Amount * buyerT1Amount2 / _t1Amount2;
        tradeBalance(sellHash, _t1, _buyerT1Amount1, buyerT1Amount2, _t2, _t2OkAmount,  _borrower);
        orderFills[_borrower][sellHash] = orderFills[_borrower][sellHash].add(buyerT1Amount2);
        emit OnBuyClaim (_buyerT1Amount1, buyerT1Amount2, _t2OkAmount, msg.sender, _borrower, sellHash, _clientNonce, getEventId());
    }
    
    function buyClaim3(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string memory  _clientNonce, 
        address _borrower, uint _buyerT1Amount1, bytes memory _sig) public 
    {
        require(_loanMaxTime > now);
        bytes32 sellHash =  getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,  _loanMaxTime,  _paymentTime,  _clientNonce, _borrower);
        require(getAddress(sellHash, _sig) == _borrower);

        uint buyerT1Amount2 = getT1A2(_t1Amount1, _t1Amount2, _loanMaxTime, _paymentTime, _buyerT1Amount1);
        require(orderFills[_borrower][sellHash].add(buyerT1Amount2) <= _t1Amount2);
 
        uint _t2OkAmount = _t2Amount * buyerT1Amount2 / _t1Amount2;
        tradeBalance(sellHash, _t1, _buyerT1Amount1, buyerT1Amount2, _t2, _t2OkAmount,  _borrower);
        orderFills[_borrower][sellHash] = orderFills[_borrower][sellHash].add(buyerT1Amount2);
        emit OnBuyClaim (_buyerT1Amount1, buyerT1Amount2, _t2OkAmount, msg.sender, _borrower, sellHash, _clientNonce, getEventId());
    }


    function getT1A2(uint _t1Amount1, uint _t1Amount2, uint _loanMaxTime, uint _paymentTime, uint _buyerT1Amount1) 
        public view returns (uint _result)  
    {
        _result = _buyerT1Amount1 + _buyerT1Amount1 * (_paymentTime - now) * (_t1Amount2 - _t1Amount1) / _t1Amount1 / (_paymentTime - _loanMaxTime);
    }

    function getT1A(uint _t1Amount1, uint _t1Amount2, uint _loanMaxTime, uint _paymentTime, uint _buyerT1Amount2) 
        public view returns (uint _result)  
    {
        require(_paymentTime > now);
        uint bb = (_t1Amount2 - _t1Amount1) * _buyerT1Amount2 * (_paymentTime - now) / (_paymentTime - _loanMaxTime);
        require(_t1Amount2 * _buyerT1Amount2 > bb);
        _result = _t1Amount2 * _buyerT1Amount2 - bb;
        _result = _result  / _t1Amount2;
    }


    function testBuyClaim(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint loanMaxTime, uint _paymentTime, string   _clientNonce, 
        address _borrower)  external view returns(uint _buyerT1Amount1)  
    {
        bytes32 sellHash =  getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,  loanMaxTime,  _paymentTime,  _clientNonce, _borrower);
        uint buyerT1Amount2 = _t1Amount2 - orderFills[_borrower][sellHash];
        _buyerT1Amount1 = buyerT1Amount2  * (_t1Amount1 * (_paymentTime - loanMaxTime)) /( _t1Amount1 * (_paymentTime - loanMaxTime) + (_paymentTime - now) * (_t1Amount2 - _t1Amount1));
    }

    function availableToken1Amount11(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string memory  _clientNonce, 
        address _borrower) view public returns(uint _result)  
    {
        bytes32 sellHash =  getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,  _loanMaxTime,  _paymentTime,  _clientNonce, _borrower);
        if(orders[_borrower][sellHash] && now <= _loanMaxTime){
            uint a1 = tokenUserAmountOf[_t2][_borrower].mul(_t1Amount2).div(_t2Amount);
            uint a = _t1Amount2.sub(orderFills[_borrower][sellHash]);
            if (a > a1) { 
                a = a1;
            }
            _result = getT1A( _t1Amount1,  _t1Amount2,  _loanMaxTime,  _paymentTime, a) ;
        }
        else{
            _result = 0;
        }
    }

    function availableToken1Amount12(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint[] memory _Time, string memory _clientNonce, 
        address _borrower, uint8 v, bytes32[] memory rs) view public returns(uint _result)  
    {
        bytes32 sellHash =  getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,   _Time[0],   _Time[1],  _clientNonce, _borrower);
        if(ecrecover(sellHash,v,rs[0],rs[1]) == _borrower && now <= _Time[0]){
            uint a1 = tokenUserAmountOf[_t2][_borrower].mul(_t1Amount2);
            a1 = a1.div(_t2Amount);
            uint a = _t1Amount2.sub(orderFills[_borrower][sellHash]);
            if (a > a1) { 
                a = a1;
            }
            _result = getT1A( _t1Amount1,  _t1Amount2,   _Time[0],   _Time[1], a) ;
        }
        else{
            _result = 0;
        }
    }

    function availableToken1Amount13(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint[] memory _Time, string memory _clientNonce, 
        address _borrower, bytes memory _sig) view public returns(uint _result)  
    {
        bytes32 sellHash =  getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,   _Time[0],   _Time[1],  _clientNonce, _borrower);
        if(getAddress(sellHash, _sig) == _borrower && now <= _Time[0]){
            uint a1 = tokenUserAmountOf[_t2][_borrower].mul(_t1Amount2);
            a1 = a1.div(_t2Amount);
            uint a = _t1Amount2.sub(orderFills[_borrower][sellHash]);
            if (a > a1) { 
                a = a1;
            }
            _result = getT1A( _t1Amount1,  _t1Amount2,   _Time[0],   _Time[1], a) ;
        }
        else{
            _result = 0;
        }
    }

    function tradeBalance(bytes32 _sellHash, address _t1, uint _t1OkAmount1, uint _t1OkAmount2, address _t2, uint _t2OkAmount, address _borrower) private 
    {
        require(_t1OkAmount1 > 0 && _t1OkAmount2 > 0 && _t2OkAmount > 0);
        tokenUserAmountOf[_t2][_borrower] = tokenUserAmountOf[_t2][_borrower].sub(_t2OkAmount);     //质押。这个钱还在this上面，但没有记录到任何人账上了。

        tokenUserAmountOf[_t1][msg.sender] = tokenUserAmountOf[_t1][msg.sender].sub(_t1OkAmount1);  //贷款支付
        tokenUserAmountOf[_t1][_borrower]  = tokenUserAmountOf[_t1][_borrower].add(_t1OkAmount1);

        claimsOf[msg.sender][_sellHash] = claimsOf[msg.sender][_sellHash] + _t1OkAmount2;           //记账，债权和质押品数量
        userOrderT2AmountOf[msg.sender][_sellHash] =  userOrderT2AmountOf[msg.sender][_sellHash] + _t2OkAmount;
    }
   

    function cancel(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint loanMaxTime, uint _paymentTime, string    _clientNonce) external 
    {
        bytes32 sellHash = getSellHash( _t1,  _t1Amount1,  _t1Amount2, _t2,  _t2Amount,  loanMaxTime,  _paymentTime,  _clientNonce, msg.sender);
        require(orders[msg.sender][sellHash] && orderFills[msg.sender][sellHash] < _t1Amount2);
        orderFills[msg.sender][sellHash] = _t1Amount2;
        emit OnCancel(msg.sender, sellHash, _clientNonce, getEventId());
    }

    function getPaymentByBuyer(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string    _clientNonce,
        address _borrower) external 
    {
        require(_paymentTime <= now);       //只有到期才能还款

        address[] memory _buyers = new address[](1);
        _buyers[0] = address(msg.sender);

        address[] memory _t1t2 = new address[](2);
        _t1t2[0] = _t1;
        _t1t2[1] = _t2;
         
        uint[] memory _t1A1t1A2t2A = new uint[](3);
        _t1A1t1A2t2A[0] = _t1Amount1;
        _t1A1t1A2t2A[1] = _t1Amount2;
        _t1A1t1A2t2A[2] = _t2Amount;

        uint[] memory _lTpT = new uint[](2);
        _lTpT[0] = _loanMaxTime;
        _lTpT[1] = _paymentTime;

        require(_getPayment(_t1t2, _t1A1t1A2t2A, _lTpT, _clientNonce, _borrower, _buyers));
    }

      function getPaymentByBorrower(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string    _clientNonce,
        address[]  _buyers) external 
    {
        require(_loanMaxTime <= now);   //理论上任何时候都可以还款

        address[] memory _t1t2 = new address[](2);
        _t1t2[0] = _t1;
        _t1t2[1] = _t2;
         
        uint[] memory _t1A1t1A2t2A = new uint[](3);
        _t1A1t1A2t2A[0] = _t1Amount1;
        _t1A1t1A2t2A[1] = _t1Amount2;
        _t1A1t1A2t2A[2] = _t2Amount;

        uint[] memory _lTpT = new uint[](2);
        _lTpT[0] = _loanMaxTime;
        _lTpT[1] = _paymentTime;

        require(_getPayment(_t1t2, _t1A1t1A2t2A, _lTpT, _clientNonce, msg.sender, _buyers));
    }

    function getPayment(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string    _clientNonce,
        address _borrower, address[]  _buyers) external 
    {
        require(_paymentTime <= now);       //只有到期才能还款

        address[] memory _t1t2 = new address[](2);
        _t1t2[0] = _t1;
        _t1t2[1] = _t2;
         
        uint[] memory _t1A1t1A2t2A = new uint[](3);
        _t1A1t1A2t2A[0] = _t1Amount1;
        _t1A1t1A2t2A[1] = _t1Amount2;
        _t1A1t1A2t2A[2] = _t2Amount;

        uint[] memory _lTpT = new uint[](2);
        _lTpT[0] = _loanMaxTime;
        _lTpT[1] = _paymentTime;

        require(_getPayment(_t1t2, _t1A1t1A2t2A, _lTpT, _clientNonce, _borrower, _buyers));
    }


    function _getPayment(address[] memory _t1t2, uint[] memory _t1A1t1A2t2A, uint[] memory _lTpT, string  memory  _clientNonce,
        address _borrower, address[] memory _buyers) private returns (bool _result)
    // function _getPayment(address _t1, uint _t1Amount1, uint _t1Amount2, address _t2, uint _t2Amount, uint _loanMaxTime, uint _paymentTime, string  memory  _clientNonce,
    //     address _borrower, address[] memory _buyers) private returns (bool _result)
    {
        require(_buyers.length >= 1);
        bytes32 sellHash = getSellHash(_t1t2[0],  _t1A1t1A2t2A[0],  _t1A1t1A2t2A[1], _t1t2[1],  _t1A1t1A2t2A[2],  _lTpT[0],  _lTpT[1],     _clientNonce, _borrower);
                //function getSellHash( _t1,     _t1Amount1,       _t1Amount2,       _t2,      _t2Amount,       _loanMaxTime,_paymentTime, _clientNonce, _borrower)
                        // emit OnBorrow (_t1t2[0],  _t1A1t1A2t2A[0],  _t1A1t1A2t2A[1], _t1t2[1],  _t1A1t1A2t2A[2],  _lTpT[0],  _lTpT[1],     _clientNonce, _borrower, getEventId());

        for(uint i = 0; i < _buyers.length; i++){
            if (orders[_borrower][sellHash] &&  _lTpT[0] < now){
                uint T1A =   claimsOf[_buyers[i]][sellHash];
                uint T2A =   userOrderT2AmountOf[_buyers[i]][sellHash];
                require(T1A > 0 && T2A > 0);

                if (tokenUserAmountOf[_t1t2[0]][_borrower] >= T1A){
                    tokenUserAmountOf[_t1t2[0]][_borrower] = tokenUserAmountOf[_t1t2[0]][_borrower] - T1A;    //支付
                    tokenUserAmountOf[_t1t2[0]][_buyers[i]] = tokenUserAmountOf[_t1t2[0]][_buyers[i]] + T1A;
                    claimsOf[_buyers[i]][sellHash] = 0;
                    userOrderT2AmountOf[_buyers[i]][sellHash] = 0;
                    tokenUserAmountOf[_t1t2[1]][_borrower] = tokenUserAmountOf[_t1t2[1]][_borrower] + T2A;    //解除抵押
                    emit OnGetPayment(T1A, 0, _buyers[i], _borrower, sellHash, _clientNonce, getEventId());
                    _result = true;
                    continue;
                }
                else{
                    //tokenUserAmountOf[_t2][_borrower] = tokenUserAmountOf[_t2][_borrower] - T2A;
                    tokenUserAmountOf[_t1t2[1]][_buyers[i]] = tokenUserAmountOf[_t1t2[1]][_buyers[i]] + T2A;  //行使抵押权
                    claimsOf[_buyers[i]][sellHash] = 0;
                    userOrderT2AmountOf[_buyers[i]][sellHash] = 0;
                    emit OnGetPayment(0, T2A, _buyers[i], _borrower, sellHash, _clientNonce, getEventId());
                    _result = true;
                    continue;
                }
            }
        }

        if(!_result){
            emit OnGetPayment(0, 0, msg.sender, _borrower, sellHash, _clientNonce, getEventId());
        }
        _result = true;
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

}