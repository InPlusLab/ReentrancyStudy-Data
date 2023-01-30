/**
 *Submitted for verification at Etherscan.io on 2019-09-05
*/

pragma solidity ^0.4.17;
//Zep
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract KlownGasDrop {


//receivers
    mapping(address => bool) public receivers;
// token balances
    mapping ( address => uint256 ) public balances;
	//amount per receiver (with decimals)
	uint256 amountToClaim = 50000000;
	uint256 public totalSent = 0;
	
	address  _owner;
	address  whoSent;
	uint256 dappBalance;

//debugging breakpoints, quick and easy 
    uint public brpt = 0;
    uint public brpt1 = 0;

    IERC20 currentToken ;


//modifiers	
	modifier onlyOwner() {
      require(msg.sender == _owner);
      _;
  }
    /// Create new - constructor
     function  KlownGasDrop() public {
		_owner = msg.sender;
		dappBalance = 0;
    }

//address of token contract, not token sender!    
	address currentTokenAddress = 0x2462b6481af155709a3044ac1bde096d861a877b;


    //deposit
      function deposit(uint tokens) public onlyOwner {


    // add the deposited tokens into existing balance 
    balances[msg.sender]+= tokens;

    // transfer the tokens from the sender to this contract
    IERC20(currentTokenAddress).transferFrom(msg.sender, address(this), tokens);
    whoSent = msg.sender;
    
  }

function hasReceived(address received)  internal  view returns(bool)
{
    bool result = false;
    if(receivers[received] == true)
        result = true;
    
    return result;
}

uint256 temp = 0;
 /// claim gas drop amount (only once per address)
    function claimGasDrop() public returns(bool) {



		//have they already receivered?
        if(receivers[msg.sender] != true)
	    {

    	    //brpt = 1;
    		if(amountToClaim <= balances[whoSent])
    		{
    		    //brpt = 2; 
    		    balances[whoSent] -= amountToClaim;
    			//brpt = 3;
    			IERC20(currentTokenAddress).transfer(msg.sender, amountToClaim);
    			
    			receivers[msg.sender] = true;
    			totalSent += amountToClaim;
    			
    			//brpt = 4;
    			
    			
    		}

	    }
		

	   
    }


 //which currentToken is used here?
  function setCurrentToken(address currentTokenContract) external onlyOwner {
        currentTokenAddress = currentTokenContract;
        currentToken = IERC20(currentTokenContract);
        dappBalance = currentToken.balanceOf(address(this));
      
  }



 //set amount per gas claim (amount each address will receive)
  function setGasClaim(uint256 amount) external onlyOwner {
    
      amountToClaim = amount;
      
  }
//get amount per gas claim (amount each address will receive)
  function getGasClaimAmount()  public view returns (uint256)  {
    
      return amountToClaim;
      
  }
  
  


}