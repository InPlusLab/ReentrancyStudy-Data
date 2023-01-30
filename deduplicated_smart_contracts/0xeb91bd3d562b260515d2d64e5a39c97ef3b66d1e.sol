/**
 *Submitted for verification at Etherscan.io on 2019-12-23
*/

pragma solidity ^0.4.24;

interface tokenRecipient { function receiveApproval (address _from, uint256 _value, address _token, bytes _extradata) external;}

contract owned {
    address private owner;
   
    constructor ()internal{
        owner = msg.sender;
    }
   
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
   
    function transferOwnership (address newOwner) onlyOwner private{
        owner = newOwner;
    }
}

contract LutraToken is owned {
   
    string public name = "Lutra Token";
    string public symbol = "LUT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
   
    mapping (address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public frozenAccount;
   
    event Transfer ( address indexed from, address indexed to, uint256 value );
    event Approval (address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);
    event FrozenFunds(address target, bool frozen);
   
    constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
        ) public{
            totalSupply = initialSupply*10**uint256(decimals);
            balanceOf[msg.sender] = totalSupply;
            name = tokenName;
            symbol = tokenSymbol;
        }
       
        ////////////////Transfer Function//////////////////////////////////
        function _transfer(address _from, address _to, uint _value) internal {
           
            require(_to != 0x0);
            require(balanceOf[_from] >=_value);
            require(balanceOf[_to] + _value >= balanceOf[_to]);
            require(!frozenAccount[msg.sender]);
             
            uint previousBalances = balanceOf[_from] + balanceOf[_to];
           
            balanceOf[_from] -=_value;
            balanceOf[_to] += _value;
           
            emit Transfer (_from, _to, _value);
           
            assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        }
       
        function transfer(address _to, uint256 _value) public returns (bool success){
           
            _transfer(msg.sender, _to, _value);
            return true;
        }
       
        ///////////////////Allowance Function///////////////////////////
        function transferFrom (address _from, address _to, uint256 _value) public returns (bool success){
            require(_value <=allowance[_from][msg.sender]);
            allowance[_from][msg.sender] -=_value;
            _transfer(_from,_to, _value);
            return true;
        }
       
        function approve (address _spender, uint256 _value) public
        returns (bool success){
            allowance[msg.sender][_spender] = _value;
            emit Approval(msg.sender, _spender, _value);
            return true;
        }
       
        function approveAndCall(address _spender, uint256 _value, bytes _extradata) public returns (bool success){
            tokenRecipient spender = tokenRecipient(_spender);
           
            if(approve(_spender,_value)){
                spender.receiveApproval(msg.sender, _value, this, _extradata);
                return true;
            }
        }
       
        ////////////////////Burn Function////////////////////////////////////////
       
        function burn (uint256 _value) onlyOwner public returns (bool success){
            require(balanceOf[msg.sender] >= _value);
           
            balanceOf[msg.sender] -= _value;
            totalSupply -= _value;
            emit Burn(msg.sender, _value);
            return true;
           
        }
       
        function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success){
            require(balanceOf[_from] >= _value);
            require(_value <= allowance [_from][msg.sender]);
           
            balanceOf[_from] -= _value;
            totalSupply -= _value;
            emit Burn(msg.sender, _value);
            return true;
        }
     
        ///////////////////Mint Function///////////////////////////////
       
        function mintToken (address target, uint256 mintedAmount) onlyOwner public {
            balanceOf[target] += mintedAmount;
            totalSupply += mintedAmount;
        }
        /////////////////Freeze Function/////////////////////////////
       
        function freezeAccount (address target, bool freeze) onlyOwner public{
            frozenAccount[target] = freeze;
            emit FrozenFunds (target, freeze);
        }
}