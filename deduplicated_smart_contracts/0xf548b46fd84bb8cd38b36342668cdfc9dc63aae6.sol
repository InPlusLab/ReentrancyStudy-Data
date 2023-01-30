/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

pragma solidity 0.5.12;

library SafeMath {
    
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    
}

contract FaucetPay {
    
    using SafeMath for uint;
    
    event Deposit(address _from, uint256 _amount);
    event Withdrawal(address _to, uint256 _amount);
    
    address payable private adminAddress;
     
    constructor() public { 
        adminAddress = msg.sender;
    }
    
    modifier _onlyOwner(){
        require(msg.sender == adminAddress);
          _;
    }

    function changeAdminAddress(address payable _newAddress) _onlyOwner public {
        adminAddress = _newAddress;
    }   

    function deposit() public payable returns(bool) {
        
        require(msg.value > 0);
        emit Deposit(msg.sender, msg.value);
        
        return true;
        
    }

    function withdraw(address payable _address, uint256 _amount) _onlyOwner public returns(bool) {
    
        _address.transfer(_amount);
        emit Withdrawal(msg.sender, _amount);
        
        return true;
        
    }
    
}