/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity 0.4.25;



library SafeMath 

{



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */



  function mul(uint256 a, uint256 b) internal pure returns(uint256 c) 

  {

     if (a == 0) 

     {

     	return 0;

     }

     c = a * b;

     assert(c / a == b);

     return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */



  function div(uint256 a, uint256 b) internal pure returns(uint256) 

  {

     return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */



  function sub(uint256 a, uint256 b) internal pure returns(uint256) 

  {

     assert(b <= a);

     return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */



  function add(uint256 a, uint256 b) internal pure returns(uint256 c) 

  {

     c = a + b;

     assert(c >= a);

     return c;

  }

}



contract ERC20Interface

{

    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);



    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

}



contract NTCT is ERC20Interface

{

    using SafeMath for uint256;

   

    uint256 constant public TOKEN_DECIMALS = 10 ** 18;

    string public constant name            = "Nortonchain Token";

    string public constant symbol          = "NTCT";

    uint256 public totalTokenSupply        = 1000000000 * TOKEN_DECIMALS;



    uint8 public constant decimals         = 18;

    address public owner;

    uint256 public totalBurned;

    bool stopped = false;



    event Burn(address indexed _burner, uint256 _value);

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);



    struct ClaimLimit 

    {

       uint256 time_limit_epoch;

       bool    limitSet;

    }

    /** mappings **/ 

    mapping(address => ClaimLimit) claimLimits;

    mapping(address => uint256) public  balances;

    mapping(address => mapping(address => uint256)) internal  allowed;

 

    /**

     * @dev Throws if called by any account other than the owner.

     */



    modifier onlyOwner() 

    {

       require(msg.sender == owner);

       _;

    }

    

    /** constructor **/



    constructor() public

    {

       owner = msg.sender;

       balances[address(this)] = totalTokenSupply;



       emit Transfer(address(0x0), address(this), balances[address(this)]);

    }



    /**

     * @dev To pause CrowdSale

     */



    function pauseCrowdSale() external onlyOwner

    {

        stopped = false;

    }



    /**

     * @dev To resume CrowdSale

     */



    function resumeCrowdSale() external onlyOwner

    {

        stopped = true;

    }



    /**

     * @dev Burn specified number of NTCT tokens

     * @param _value The amount of tokens to be burned

     */



     function burn(uint256 _value) onlyOwner public returns (bool) 

     {

        require(!stopped);

        require(_value <= balances[msg.sender]);



        address burner = msg.sender;



        balances[burner] = balances[burner].sub(_value);

        totalTokenSupply = totalTokenSupply.sub(_value);

        totalBurned      = totalBurned.add(_value);



        emit Burn(burner, _value);

        emit Transfer(burner, address(0x0), _value);

        return true;

     }     



     /**

      * @dev total number of tokens in existence

      * @return An uint256 representing the total number of tokens in existence

      */



     function totalSupply() public view returns(uint256 _totalSupply) 

     {

        _totalSupply = totalTokenSupply;

        return _totalSupply;

     }



    /**

     * @dev Gets the balance of the specified address

     * @param _owner The address to query the the balance of

     * @return An uint256 representing the amount owned by the passed address

     */



    function balanceOf(address _owner) public view returns (uint256) 

    {

       return balances[_owner];

    }



    /**

     * @dev Transfer tokens from one address to another

     * @param _from address The address which you want to send tokens from

     * @param _to address The address which you want to transfer to

     * @param _value uint256 the amout of tokens to be transfered

     */



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)     

    {

       require(!stopped);



       if (_value == 0) 

       {

           emit Transfer(_from, _to, _value);  // Follow the spec to launch the event when value is equal to 0

           return true;

       }



       require(!claimLimits[msg.sender].limitSet, "Limit is set and use claim");

       require(_to != address(0x0));

       require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value >= 0);



       balances[_from] = balances[_from].sub(_value);

       allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

       balances[_to] = balances[_to].add(_value);



       emit Transfer(_from, _to, _value);

       return true;

    }



    /**

     * @dev transfer tokens from smart contract to another account, only by owner

     * @param _address The address to transfer to

     * @param _tokens The amount to be transferred

     */



    function transferTo(address _address, uint256 _tokens) external onlyOwner returns(bool) 

    {

       require( _address != address(0x0)); 

       require( balances[address(this)] >= _tokens.mul(TOKEN_DECIMALS) && _tokens.mul(TOKEN_DECIMALS) > 0);



       balances[address(this)] = ( balances[address(this)]).sub(_tokens.mul(TOKEN_DECIMALS));

       balances[_address] = (balances[_address]).add(_tokens.mul(TOKEN_DECIMALS));



       emit Transfer(address(this), _address, _tokens.mul(TOKEN_DECIMALS));

       return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender

     *

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param _spender The address which will spend the funds

     * @param _tokens The amount of tokens to be spent

     */



    function approve(address _spender, uint256 _tokens) public returns(bool)

    {

       require(!stopped);

       require(_spender != address(0x0));



       allowed[msg.sender][_spender] = _tokens;



       emit Approval(msg.sender, _spender, _tokens);

       return true;

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender

     * @param _owner address The address which owns the funds

     * @param _spender address The address which will spend the funds

     * @return A uint256 specifing the amount of tokens still avaible for the spender

     */



    function allowance(address _owner, address _spender) public view returns(uint256)

    {

       require(!stopped);

       require(_owner != address(0x0) && _spender != address(0x0));



       return allowed[_owner][_spender];

    }



    /**

     * @dev transfer token for a specified address

     * @param _address The address to transfer to

     * @param _tokens The amount to be transferred

     */



    function transfer(address _address, uint256 _tokens) public returns(bool)

    {

       require(!stopped);



       if (_tokens == 0) 

       {

           emit Transfer(msg.sender, _address, _tokens);  // Follow the spec to launch the event when tokens are equal to 0

           return true;

       }



       require(!claimLimits[msg.sender].limitSet, "Limit is set and use claim");

       require(_address != address(0x0));

       require(balances[msg.sender] >= _tokens);



       balances[msg.sender] = (balances[msg.sender]).sub(_tokens);

       balances[_address] = (balances[_address]).add(_tokens);



       emit Transfer(msg.sender, _address, _tokens);

       return true;

    }



    /**

     * @dev transfer ownership of this contract, only by owner

     * @param _newOwner The address of the new owner to transfer ownership

     */



    function transferOwnership(address _newOwner)public onlyOwner

    {

       require(!stopped);

       require( _newOwner != address(0x0));



       balances[_newOwner] = (balances[_newOwner]).add(balances[owner]);

       balances[owner] = 0;

       owner = _newOwner;



       emit Transfer(msg.sender, _newOwner, balances[_newOwner]);

   }



   /**

    * @dev Increase the amount of tokens that an owner allowed to a spender

    * approve should be called when allowed[_spender] == 0. To increment

    * allowed value is better to use this function to avoid 2 calls (and wait until

    * the first transaction is mined)

    * From MonolithDAO Token.sol

    * @param _spender The address which will spend the funds

    * @param _addedValue The amount of tokens to increase the allowance by

    */



   function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) 

   {

      require(!stopped);



      allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);



      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

      return true;

   }



   /**

    * @dev Decrease the amount of tokens that an owner allowed to a spender

    * approve should be called when allowed[_spender] == 0. To decrement

    * allowed value is better to use this function to avoid 2 calls (and wait until

    * the first transaction is mined)

    * From MonolithDAO Token.sol

    * @param _spender The address which will spend the funds

    * @param _subtractedValue The amount of tokens to decrease the allowance by

    */



   function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) 

   {

      uint256 oldValue = allowed[msg.sender][_spender];



      require(!stopped);



      if (_subtractedValue > oldValue) 

      {

         allowed[msg.sender][_spender] = 0;

      }

      else 

      {

         allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

      }



      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

      return true;

   }



   /**

    * @dev Transfer tokens to another account, time limit apply

    */



   function claim(address _recipient) public

   {

      require(_recipient != address(0x0), "Invalid recipient");

      require(msg.sender != _recipient, "Self transfer");

      require(claimLimits[msg.sender].limitSet, "Limit not set");



      require (now > claimLimits[msg.sender].time_limit_epoch, "Time limit");

       

      uint256 tokens = balances[msg.sender];

       

      balances[msg.sender] = (balances[msg.sender]).sub(tokens);

      balances[_recipient] = (balances[_recipient]).add(tokens);

       

      emit Transfer(msg.sender, _recipient, tokens);

   }

 

   /**

    * @dev Set limit on a claim per address

    */



   function setClaimLimit(address _address, uint256 _days) public onlyOwner

   {

      require(balances[_address] > 0, "No tokens");



      claimLimits[_address].time_limit_epoch = (now + ((_days).mul(1 days)));

   		

      claimLimits[_address].limitSet = true;

   }



}