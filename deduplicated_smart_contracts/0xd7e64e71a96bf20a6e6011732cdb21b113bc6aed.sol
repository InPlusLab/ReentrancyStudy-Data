pragma solidity ^0.4.25;

import "./HuptexStandard.sol";

contract HuptexProtocol is StandardToken, BurnableToken, Ownable {
    // Constants
    string  public constant name = "Huptex";
    string  public constant symbol = "HTX";
    uint8   public constant decimals = 2;
    uint256 public constant INITIAL_SUPPLY      = 5000000 * (10 ** uint256(decimals));

    mapping(address => bool) public balanceLocked;   
    
    
    uint public amountRaised;
    uint256 public buyPrice = 100;
    bool public crowdsaleClosed = true;
    bool public transferEnabled = true;


    constructor() public {
      totalSupply_ = INITIAL_SUPPLY;
      balances[msg.sender] = INITIAL_SUPPLY;
      emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
 

    function _transfer(address _from, address _to, uint _value) internal {     
        require (balances[_from] >= _value);               // Check if the sender has enough
        require (balances[_to] + _value > balances[_to]); // Check for overflows
   
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the sender
        balances[_to] = balances[_to].add(_value);                            // Add the same to the recipient
 
        emit Transfer(_from, _to, _value);
    }

    function setPrice( uint256 newBuyPrice) onlyOwner public {
        buyPrice = newBuyPrice;
    }

    function closeBuy(bool closebuy) onlyOwner public {
        crowdsaleClosed = closebuy;
    }

    function () external payable {
        require(!crowdsaleClosed);
        uint amount = msg.value ;               // calculates the amount
        amountRaised = amountRaised.add(amount);
        _transfer(owner, msg.sender, amount.mul(buyPrice)); 
        owner.transfer(amount);
    }
 
    function enableTransfer(bool _enable) onlyOwner external {
        transferEnabled = _enable;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(transferEnabled);
        require(!balanceLocked[_from] );

        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(transferEnabled);
        require(!balanceLocked[msg.sender] );
        
        return super.transfer(_to, _value);
    }    
  
    function lock ( address[] _addr ) onlyOwner external  {
        for (uint i = 0; i < _addr.length; i++) {
          balanceLocked[_addr[i]] =  true;  
        }
    }
    
   
    function unlock ( address[] _addr ) onlyOwner external  {
        for (uint i = 0; i < _addr.length; i++) {
          balanceLocked[_addr[i]] =  false;  
        }
    }
 
        
}