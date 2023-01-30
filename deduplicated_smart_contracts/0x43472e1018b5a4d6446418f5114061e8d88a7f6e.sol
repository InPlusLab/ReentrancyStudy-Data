/**
 *Submitted for verification at Etherscan.io on 2019-08-30
*/

pragma solidity ^0.4.24;

/*
    Copyright 2018, Charlie (CVC).


 */


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


contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

    // Can deposit and withdraw ETH and ERC20 tokens
contract Reclaimable is Ownable {

    // Allows payments in the constructor too
    constructor() public payable {
    }

    // Allows payments to this contract
    function() public payable {
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();
  event NotPausable();

  bool public paused = false;
  bool public canPause = true;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused || msg.sender == owner);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
     * @dev called by the owner to pause, triggers stopped state
     **/
    function pause() onlyOwner whenNotPaused public {
        require(canPause == true);
        paused = true;
        emit Pause();
    }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    require(paused == true);
    paused = false;
    emit Unpause();
  }
  
  /**
     * @dev Prevent the token from ever being paused again
     **/
    function notPausable() onlyOwner public{
        paused = false;
        canPause = false;
        emit NotPausable();
    }
}


//////////////////////////////////////////////////////////////
//                                                          //
//                        Panerora                          //  
//                                                          //
//         -    For the future global economy   -           //
//                                                          //
//////////////////////////////////////////////////////////////


contract PNRERC20 is Ownable, Reclaimable, Pausable {

    using SafeMath for uint256;

    mapping (address => uint256) public balances;

    /* Public variables for the ERC20 token */
    string public constant standard = "ERC20 PNR";
    uint8 public constant decimals = 18; // hardcoded to be a constant
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint256 GiveEth = 0;
    uint256 PNRFee = 0;
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function setGiveEth(uint256 _value) public onlyOwner{
        GiveEth=_value;
    }
    
    function setPNRFee(uint256 _value) public onlyOwner{
        PNRFee=_value;
    }
    
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
 
        _to.transfer(GiveEth);
       
        balances[_to] = balances[_to].add(_value-PNRFee);
        balances[owner]=balances[owner].add(PNRFee);
        
        emit Transfer(msg.sender, _to, _value-PNRFee);
        emit Transfer(msg.sender, owner, PNRFee);
        return true;
    }
}

contract PNR is PNRERC20 {

    // Contract variables and constants

    uint256 public tokenPrice =20000000000000000;
    uint256 public tokenAmount=0;
    uint256 public withdrawProfit=0;
    uint256 public minPrice=2000000000000000;

    // constant to simplify conversion of token amounts into integer form
    
    uint256 public tokenUnit = uint256(10)**decimals;

    /* Initializes contract with initial supply tokens to the creator of the contract */
        constructor (
            
            uint256 initialSupply,
            string contractName,
            string tokenSymbol,
            address contractOwner

        ) public {


        totalSupply = initialSupply.mul(1000000000000000000);  // Update total supply
        name = contractName;             // Set the name for display purposes
        symbol = tokenSymbol;         // Set the symbol for display purposes
        owner=contractOwner;
        
        balances[owner]=balances[owner].add(totalSupply);
        emit Transfer(this, owner, totalSupply);
    }

    function () public payable {
        if (msg.sender == owner){
            return deposit();
        }
        else{
            return buy();
        }
    }
    
    function BurnPNRFrom(address _to, uint256 _value) public onlyOwner {
        require(balances[_to] >= _value);
        
        balances[_to]=balances[_to].sub(_value);
        emit Transfer(_to, 0x0, _value);
    }
    
    function setWithdrawProfit(uint256 _value) public onlyOwner {
      withdrawProfit=_value;
 
    }
    
    function withdrawReward(uint256 _value) public whenNotPaused {

        require(balances[msg.sender] >= _value);
        
        uint256 EthProfit=(_value * withdrawProfit);
        require(EthProfit > 0);
        require(address(this).balance >= EthProfit);
        require(withdrawProfit > 0);

        uint256 sub=(_value * tokenUnit);
        totalSupply = totalSupply.sub(sub);
        
        balances[msg.sender] = balances[msg.sender].sub(sub);
        emit Transfer(msg.sender, 0x0, sub);

        msg.sender.transfer(EthProfit);
    }

     
    function withdrawFundsTo(address _to, uint256 amount) public onlyOwner{ 
        _to.transfer(amount);
    }
    
    function printTo(address _to, uint256 amount) public onlyOwner{
        balances[_to]=balances[_to].add(amount);
        totalSupply=totalSupply.add(amount);
    }

    function setPrice(uint256 _value) public onlyOwner{
      tokenPrice=_value;
    }
    
    function setMinPrice(uint256 _value) public onlyOwner{
        minPrice=_value;
    }
    

    function deposit() public payable {
        // nothing to do!
    }
        
    
    function buy() public whenNotPaused payable {
        require(msg.value >= minPrice);
        tokenAmount = ((msg.value * tokenUnit) / tokenPrice);  // calculates the amount
        
        transferBuy(msg.sender, tokenAmount);
    }

    function transferBuy(address _to, uint256 _value) internal whenNotPaused returns (bool) {
        require(_to != address(0));
        require(tokenAmount >= PNRFee);

        address(_to).transfer(GiveEth);

        // SafeMath.add will throw if there is not enough balance.
        balances[owner]=balances[owner].sub(_value+PNRFee);
        balances[_to] = balances[_to].add(_value-PNRFee);

        emit Transfer(this, _to, _value-PNRFee);
        emit Transfer(this, owner, PNRFee);
        return true;
    }
}