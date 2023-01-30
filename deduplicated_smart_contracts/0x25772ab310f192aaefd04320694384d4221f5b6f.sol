/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.5.6;

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

contract TokenBatch { 
    using   SafeMath for uint256;

    address public owner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner)  external  onlyOwner {
        require(_newOwner != address(0x0));
        owner = _newOwner;
    }

    constructor()  public {
        owner = msg.sender;
    }
  
    event OnTransfer(uint256 indexed _batchId, address indexed _to, bool indexed _done, uint256 _amount, address _sender);

    function batchTransfer1(address payable[] calldata _tos, uint256 _amount, uint256 _batchId, bool _isShowSuccess) external payable {
        require(_amount > 0);
        require(_tos.length > 0);
        uint RemAmount = msg.value.sub(_amount.mul(_tos.length));
        for(uint i = 0; i < _tos.length; i++){
            address payable to = _tos[i];
            if(to != address(0x0)){
                to.transfer(_amount);
                if (_isShowSuccess){
                    emit OnTransfer(_batchId, to, true, _amount, msg.sender);
                }
            }
            else
            {
                emit OnTransfer(_batchId, to, false, _amount, msg.sender);
            }     
        }
        if(RemAmount > 0)
        {
            msg.sender.transfer(RemAmount);  
        }
    }

    function batchTransfer2(address payable[] calldata _tos, uint256[] calldata _amounts, uint256 _batchId, bool _isShowSuccess) external payable {
        require(_amounts.length > 0);
        require(_tos.length > 0);
        require(_amounts.length == _tos.length );
        uint RemAmount = msg.value;
        for(uint i = 0; i < _tos.length; i++){
            address payable to = _tos[i];
            uint amount = _amounts[i];
            if(to != address(0x0) && amount > 0){
                RemAmount = RemAmount.sub(amount);
                to.transfer(amount);
                if (_isShowSuccess){
                    emit OnTransfer(_batchId, to, true, amount, msg.sender);
                }
            }
            else
            {
                emit OnTransfer(_batchId, to, false, amount, msg.sender);
            }     
        }
        if(RemAmount > 0)
        {
            msg.sender.transfer(RemAmount);  
        }
    }
    
    event OnTokenTransfer(uint256 indexed _batchId, address indexed _to, bool indexed _done, uint256 _amount, address _sender, address _erc20Token);
    
    function batchTokenTransfer1(address _erc20Token, address[] calldata _tos, uint256 _amount, uint256 _batchId, bool _isShowSuccess) external  {
        require(_amount > 0);
        require(_tos.length > 0);
        Erc20Token token = Erc20Token(_erc20Token);
        for(uint i = 0; i < _tos.length; i++){
            address to = _tos[i];
            if(to != address(0x0)){
                token.transferFrom(msg.sender, to, _amount);
                if (_isShowSuccess){
                    emit OnTokenTransfer(_batchId, to, true, _amount, msg.sender, _erc20Token);
                }
            }
            else
            {
                emit OnTokenTransfer(_batchId, to, false, _amount, msg.sender, _erc20Token);
            }     
        }
    }

    function batchTokenTransfer2(address _erc20Token, address [] calldata _tos, uint256[] calldata _amounts, uint256 _batchId, bool _isShowSuccess) external  {
        require(_amounts.length > 0);
        require(_tos.length > 0);
        require(_amounts.length == _tos.length );
        Erc20Token token = Erc20Token(_erc20Token);
        for(uint i = 0; i < _tos.length; i++){
            if(_tos[i] != address(0x0) && _amounts[i] > 0){
                token.transferFrom(msg.sender, _tos[i], _amounts[i]);
                if (_isShowSuccess){
                    emit OnTokenTransfer(_batchId, _tos[i], true, _amounts[i], msg.sender, _erc20Token);
                }
            }
            else
            {
                emit OnTokenTransfer(_batchId, _tos[i], false, _amounts[i], msg.sender, _erc20Token);
            }
        }
    }
    

    function () external payable {
        //selfdestruct(_to);
    }
    
    function disToken(address _token) external onlyOwner {
        if (_token != address(0x0)){
            Erc20Token token = Erc20Token(_token);
            uint amount = token.balanceOf(address(this));
            if (amount > 0) {
                token.transfer(msg.sender, amount);
            }
        }
        else{
            msg.sender.transfer(address(this).balance);
        }
    }

}