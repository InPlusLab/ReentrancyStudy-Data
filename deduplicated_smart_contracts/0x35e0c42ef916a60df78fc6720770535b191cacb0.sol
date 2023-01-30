pragma solidity ^0.5.2;
import "./ERC20.sol";
import "./SafeMath.sol";

contract BitcoinGirlishToken is ERC20 {
 
    string public  name = "Bitcoin Girlish";
    string public  symbol = "BCG";
    uint256 public constant decimals = 18;
    string public version = "1.0";
    address payable private ethDeposit; 
    address  private BCGFoundation;
    bool public isSellPaused;              
    uint256 private  exchangeRate = 1000; // BCG tokens per 1 ETH
    uint256 public constant maxSupply =  21 * (10**6) * 10**decimals; //21 million
    uint256 public  circulatingSupply;
   
    constructor  (address payable _ethDeposit, address _BCGFoundation) public    {
      ethDeposit = _ethDeposit;
      BCGFoundation = _BCGFoundation;
      isSellPaused = false;
    }
   
    function() payable external {
       uint256 tokens ;
      if(msg.sender ==BCGFoundation || msg.sender == ethDeposit){
        tokens=50000* 10**decimals;
      }else{
       require (!isSellPaused) ;
      require (msg.value > 0) ;
       tokens=msg.value.mul(exchangeRate);   
      }
     uint256 checkedSupply = totalSupply().add(tokens);
      // return money if something goes wrong
      require (checkedSupply <= maxSupply) ; 
     _mint(msg.sender,tokens);  
      address(ethDeposit).transfer(msg.value);
      circulatingSupply=checkedSupply;
      }
      
      function  brand(string calldata _name, string calldata _symbol) external {
        require (msg.sender == ethDeposit || msg.sender ==BCGFoundation) ; 
        require(bytes(_name).length > 0);
        require(bytes(_symbol).length > 0);
        name=_name;
        symbol=_symbol;
      }
      
     function  push() external {
        require (msg.sender == ethDeposit || msg.sender ==BCGFoundation) ; 
        address(ethDeposit).transfer(address(this).balance);
      }
     
    function pauseSell() external {
      require (!isSellPaused) ;
     require (msg.sender == ethDeposit || msg.sender ==BCGFoundation) ;  
      isSellPaused = true;
    }
    
    function unpauseSell() external {
      require (isSellPaused) ;
      require (msg.sender == ethDeposit || msg.sender ==BCGFoundation) ; 
      isSellPaused = false;
    }
    
    function setExchangeRate(uint256 _exchangeRate) external {
        require (msg.sender == ethDeposit || msg.sender ==BCGFoundation) ; 
        require (_exchangeRate > 0) ;
        exchangeRate=_exchangeRate;
    }
  }