/**
 *Submitted for verification at Etherscan.io on 2020-03-06
*/

pragma solidity ^0.4.24;

library SafeMath {

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// https://github.com/ethereum/EIPs/issues/20
interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
/**
 * Author : Hamza Yasin
 * Linkedin: linkedin.com/in/hamzayasin
 * Github: HamzaYasin1
 */

contract BernCommunitySales is Ownable {
    
    using SafeMath for uint256;

    // The token being sold
    ERC20 private _token;
    
    // Address where funds are collected
    address private _wallet;
    
    uint256 private _rate = 2; // 1 token = 0.005 eth ~ 1 ether = 200 tokens
    
    // Amount of wei raised
    uint256 private _weiRaised;
    
    uint256 public _tierOneBonus;
    
    uint256 public _tierTwoBonus;
    
    uint256 public _tierThreeBonus;
    
    uint256 public _tierFourBonus;
    
    uint256 public _weekOne;
        
    uint256 public _weekTwo;
    
    uint256 public _weekThree;
        
    uint256 public _weekFour;
    
    uint256 private _tokensSold;
    
    uint256 public _startTime =  1590969600; // 06/01/2020 @ 12:00am (UTC)
    
    uint256 public _endTime = 1654041600; // 06/01/2022 @ 12:00am (UTC)
    
    // 50 % of totalSupply will be in the sales contract

    uint256 public _saleSupply = SafeMath.mul(200000000,  10 ** uint256(16)); // 200 million or 40 %
    uint256 public teamSupply = SafeMath.mul(25000000, 10 ** uint256(16)); // 25 million or 5%
    uint256 public developmentSupply = SafeMath.mul(25000000, 10 ** uint256(16)); // 25 million or 5 %
    

    // timelocks
    uint256 internal developmentTimeLock;
    uint256 internal teamTimeLock;

    // count the number of function calls
    uint internal teamCounter = 0;
    uint internal developmentCounter = 0;
    
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    
    constructor (address  wallet, ERC20 token) public {
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _wallet = wallet;
        _token = token;
        _tokensSold = 0;
        
        _weekOne = SafeMath.add(_startTime, 16 weeks);
        _weekTwo = SafeMath.add(_weekOne, 16 weeks);
        _weekThree = SafeMath.add(_weekOne, 16 weeks);
        _weekFour = SafeMath.add(_weekOne, 16 weeks);
       
       _tierOneBonus =  SafeMath.div(SafeMath.mul(_rate,200),100);
       _tierTwoBonus =  SafeMath.div(SafeMath.mul(_rate,100),100);
       _tierThreeBonus =  SafeMath.div(SafeMath.mul(_rate,50),100);
       _tierFourBonus =  SafeMath.div(SafeMath.mul(_rate,25),100);
       
        /** Vested Period calculations for team and advisors*/
        developmentTimeLock = SafeMath.add(_endTime, 16 weeks);
        teamTimeLock = SafeMath.add(_endTime, 16 weeks);
       
    }

    function () external payable {
        buyTokens(msg.sender);
    }


    function token() public view returns (ERC20) {
        return _token;
    }

    function wallet() public view returns (address ) {
        return _wallet;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function buyTokens(address beneficiary) public  payable {
        require(validPurchase());

        uint256 weiAmount = msg.value;
        uint256 accessTime = now;
        
        require(weiAmount >= 10000000000000000, "Wei amount should be greater than 0.01 ETH");
        _preValidatePurchase(beneficiary, weiAmount);
        
        uint256 tokens = 0;
        
        tokens = _processPurchase(accessTime,weiAmount, tokens);
      
        _weiRaised = _weiRaised.add(weiAmount);
        
        _deliverTokens(beneficiary, tokens);  
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);
        
        _tokensSold = _tokensSold.add(tokens);
        
        _forwardFunds();
     
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal pure {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.transfer(beneficiary, tokenAmount);
    }

    function _processPurchase(uint256 accessTime, uint256 weiAmount, uint256 tokenAmount)  internal returns (uint256) {
       
       if ( accessTime <= _weekOne ) { 
        tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierOneBonus));
      } else if (( accessTime <= _weekTwo ) && (accessTime > _weekOne)) { 
        tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierTwoBonus));
      } else if (( accessTime <= _weekThree ) && (accessTime > _weekFour)) { 
        tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierThreeBonus));
      } else if (( accessTime <= _weekFour ) && (accessTime > _weekThree)) { 
        tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierFourBonus));
      } 
        tokenAmount = tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_rate));
        
        require(_saleSupply >= tokenAmount, "sale supply should be greater or equals to tokenAmount");
        
        _saleSupply = _saleSupply.sub(tokenAmount);        

        return tokenAmount;
        
    }
    
      // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= _startTime && now <= _endTime;
        bool nonZeroPurchase = msg.value != 0;
        bool weiRaisedOk = _weiRaised <= (20000 * 1 ether);
        return withinPeriod && nonZeroPurchase && weiRaisedOk;
  }

  // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
      return now > _endTime;
    }

    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
    function withdrawTokens(uint _amount) external onlyOwner {
       _token.transfer(_wallet, _amount);
   }
     
    function grantTeamToken(address teamAddress) external onlyOwner {
        require((teamCounter < 4) && (teamTimeLock < now));
       
        teamTimeLock = SafeMath.add(teamTimeLock, 16 weeks);
        _token.transfer(teamAddress,SafeMath.div(teamSupply, 4));
        teamCounter = SafeMath.add(teamCounter, 1);        
    }

    function grantDevelopmentToken(address developmentAddress) external onlyOwner {
        require((developmentCounter < 4) && (developmentTimeLock < now));
       
        developmentTimeLock = SafeMath.add(developmentTimeLock, 16 weeks);
        _token.transfer(developmentAddress,SafeMath.div(developmentSupply, 4));
        developmentCounter = SafeMath.add(developmentCounter, 1);        
    }
    
    function transferFunds(address[] recipients, uint256[] values) external onlyOwner {

        for (uint i = 0; i < recipients.length; i++) {
            uint x = values[i].mul(10000000000000000);
            require(_saleSupply >= values[i]);
            _saleSupply = SafeMath.sub(_saleSupply,values[i]);
            _token.transfer(recipients[i], x); 
        }
    } 


}