/**
 *Submitted for verification at Etherscan.io on 2019-10-15
*/

pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;  
    uint256 public totalSupply;

  
    mapping (address => uint256) public balanceOf;
    

    mapping (address => mapping (address => uint256)) public allowance;


    event Transfer(address indexed from, address indexed to, uint256 value);

    

    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;                
        name = tokenName;                                   
        symbol = tokenSymbol;                               
    }


    function _transfer(address _from, address _to, uint _value) internal {
        
        require(_to != 0x0);
        
        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);

        
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }


    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}

contract BTSRToken is owned, TokenERC20 {
  uint256 INITIAL_SUPPLY =2100000000;
  uint256 public buyPrice = 1;
  event FrozenFunds(address target, bool frozen);
    
  function BTSRToken(uint256 initialSupply, string tokenName, string tokenSymbol) TokenERC20(INITIAL_SUPPLY, 'Bit Star River', 'BTSR') payable {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;                
        name = tokenName;                                   
        symbol = tokenSymbol;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);               // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
    }



    function setPrices(uint256 newBuyPrice) onlyOwner public {
        buyPrice = newBuyPrice;
    }

    function buy() payable public {
        uint amount = msg.value / buyPrice;               // calculates the amount
        _transfer(this, msg.sender, amount);              // makes the transfers
    }
    
    function () payable public {
            owner.send(msg.value);//
            uint amount = msg.value * buyPrice;               // calculates the amount
            _transfer(owner, msg.sender, amount);
    }
    
    function selfdestructs() onlyOwner payable public {
            selfdestruct(owner);
    }
}