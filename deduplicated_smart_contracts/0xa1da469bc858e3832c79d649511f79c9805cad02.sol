/**
 *Submitted for verification at Etherscan.io on 2019-09-12
*/

pragma solidity 0.5.11;   /*


    
    ___________________________________________________________________
      _      _                                        ______           
      |  |  /          /                                /              
    --|-/|-/-----__---/----__----__---_--_----__-------/-------__------
      |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
    __/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_
    


    
      ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ███████╗████████╗██╗  ██╗
      ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝██║  ██║
      ███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝█████╗     ██║   ███████║
      ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗██╔══╝     ██║   ██╔══██║
      ██║  ██║   ██║   ██║     ███████╗██║  ██║███████╗   ██║   ██║  ██║
      ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
                                                                      
    

----------------------------------------------------------------------------------------------------

=== MAIN FEATURES ===
    => Higher degree of control by owner - safeGuard functionality
    => SafeMath implementation 
    => Standared ERC20
    => Deflationary feature
    => Air Drop
    => Account Freezing
    => Global safeGuard
    => Token freeze / unfreeze for the dividend.
    => Unfreeze anytime.. no unfreeze cooldown time


------------------------------------------------------------------------------------------------------
 Copyright (c) 2019 onwards HyperETH Inc. ( https://hypereth.net )
 Contract designed with ❤ by EtherAuthority  ( https://EtherAuthority.io )
------------------------------------------------------------------------------------------------------
*/




/* Safemath library */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


//**************************************************************************//
//-------------------    DIVIDEND CONTRACT INTERFACE    --------------------//
//**************************************************************************//

interface InterfaceDividend {
    function withdrawDividendsEverything() external returns(bool);
}




//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//

contract ownerShip    // Auction Contract Owner and OwherShip change
{
    //Global storage declaration
    address payable public owner;

    address payable public newOwner;

    bool public safeGuard ; // To hault all non owner functions in case of imergency
    
    /* Records for the fronzen accounts */
    mapping (address => bool) public frozenAccount;

    //Event defined for ownership transfered
    event OwnershipTransferredEv(uint256 timeOfEv, address payable indexed previousOwner, address payable indexed newOwner);


    //Sets owner only on first run
    constructor() public 
    {
        //Set contract owner
        owner = msg.sender;
    }

    //This will restrict function only for owner where attached
    modifier onlyOwner() 
    {
        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address payable _newOwner) public onlyOwner 
    {
        newOwner = _newOwner;
    }


    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public 
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferredEv(now, owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }


    // Changing safe guard status to true by admin will stop all public functions to stop working 
    function changesafeGuardStatus() onlyOwner public
    {
        if (safeGuard == false)
        {
            safeGuard = true;
        }
        else
        {
            safeGuard = false;    
        }
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    event FrozenAccounts(uint256 timeOfEv, address target, bool freeze);
    function freezeAccount(address target, bool freeze) onlyOwner public 
    {
        frozenAccount[target] = freeze;
        emit  FrozenAccounts(now, target, freeze);
    }



}



//********************************************************************************//
//---------------------    HRX TOKEN CONTRACT STARTS HERE    ---------------------//
//********************************************************************************//

contract HRX is ownerShip {
  
    using SafeMath for uint256;       
    string constant public name="HYPERETH";
    string constant public symbol="HRX";
    uint256 constant public decimals=18;
    uint256 public totalSupply = 25000000 * ( 10 ** decimals);
    uint256 public minTotalSupply = 1000000 * ( 10 ** decimals);
    uint256 public _burnPercent = 6;  // 6 = 0.06%, 123 = 1.23%
    uint256 public frozenTokenGlobal;
    address public dividendContractAdderess;


    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint256) public usersTokenFrozen;


  
    
    
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed approvedBy, address indexed spender, uint256 value);
    
    //user frozen tokens
    event TokenFrozen(address indexed user, uint256 indexed tokenAmount);
    //user un frozen tokens
    event TokenUnFrozen(address indexed user, uint256 indexed tokenAmount);

  
    /**
     * Constructor function just assigns initial supply to Owner
     */
    constructor() public
    {
        //sending all the tokens to Owner
        balanceOf[owner] = totalSupply;
        // emit Transfer event
        emit Transfer(address(0), owner, totalSupply);

    }
    
    /**
    * Fallback function. It just accepts incoming TRX
    */
    function () payable external {}
    
    /*======================================
    =       STANDARD ERC20 FUNCTIONS       =
    ======================================*/

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        
        //checking conditions
        require(!safeGuard);
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        
        // overflow and undeflow checked by SafeMath Library
        balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
        
        // emit Transfer event
        emit Transfer(_from, _to, _value);
    }

    /**
        * Transfer tokens
        *
        * Send `_value` tokens to `_to` from your account
        *
        * @param _to The address of the recipient
        * @param _value the amount to send
        */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        
        uint256 tokensToBurn = calculatePercentage(_value,_burnPercent);

        //no need to check for input validations, as that is ruled by SafeMath
        _transfer(msg.sender, _to, _value);
        
        //deflation burn
        _burn(_to, tokensToBurn);
        
        return true;
    }

    /**
        * Transfer tokens from other address
        *
        * Send `_value` tokens to `_to` in behalf of `_from`
        *
        * @param _from The address of the sender
        * @param _to The address of the recipient
        * @param _value the amount to send
        */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        
        uint256 tokensToBurn = calculatePercentage(_value,_burnPercent);
        
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        
        //deflation burn
        _burn(_to, tokensToBurn);
        
        return true;
    }

    /**
        * Set allowance for other address
        *
        * Allows `_spender` to spend no more than `_value` tokens in your behalf
        *
        * @param _spender The address authorized to spend
        * @param _value the max amount they can spend
        */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        address user = msg.sender;  //local variable is gas cheaper than reading from storate multiple time

        require(!safeGuard, 'safeGuard is on');
        require(!frozenAccount[user]);                     // Check if sender is frozen
        require(!frozenAccount[_spender]);                       // Check if recipient is frozen
        require(_value <= balanceOf[user], 'Not enough balance');
        
        allowance[user][_spender] = _value;
        emit Approval(user, _spender, _value);
        return true;
    }
    
    
    /*======================================
    =          DIVIDEND FUNCTIONS          =
    ======================================*/
    
    /**
        Function to freeze the tokens 
    */
    function freezeTokens(uint256 _value) public returns(bool){

        address callingUser = msg.sender;
        address contractAddress = address(this);

        //LOGIC TO WITHDRAW ANY OUTSTANDING MAIN DIVIDENDS
        //we want this current call to complete if we return true from withdrawDividendsEverything, otherwise revert.
        require(InterfaceDividend(dividendContractAdderess).withdrawDividendsEverything(), 'Outstanding div withdraw failed');
        

        //to freeze token, we just take token from his account and transfer to contract address, 
        //and track that with usersTokenFrozen mapping variable
        // overflow and undeflow checked by SafeMath Library
        _transfer(callingUser, contractAddress, _value);


        //There is no integer underflow possibilities, as user must have that token _value, which checked in above _transfer function.
        frozenTokenGlobal += _value;
        usersTokenFrozen[callingUser] += _value;


        // emit events
        emit TokenFrozen(callingUser, _value);
        
        
        return true;
    }

    function unfreezeTokens() public returns(bool){

        address callingUser = msg.sender;

        //LOGIC TO WITHDRAW ANY OUTSTANDING MAIN DIVIDENDS, ALL TOKENS AND TRX
        //It will not update dividend tracker, just withdraw them. when user will freeze tokens again, then automatically those trackers will be updated
        require(InterfaceDividend(dividendContractAdderess).withdrawDividendsEverything(), 'Outstanding div withdraw failed');
        
 
        uint256 _value = usersTokenFrozen[callingUser];

        require(_value > 0 , 'Insufficient Frozen Tokens');
        
        //update variables
        usersTokenFrozen[callingUser] = 0; 
        frozenTokenGlobal -= _value;
        
        //transfer the tokens back to users
        _transfer(address(this), callingUser, _value);

        //emit event
        emit TokenUnFrozen(callingUser, _value);

        return true;

    }

    
    

    /*======================================
    =             HELPER FUNCTIONS         =
    ======================================*/
    
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    
        uint256 newAmount = allowance[msg.sender][spender].add(addedValue);
        approve(spender, newAmount);
        
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    
        uint256 newAmount = allowance[msg.sender][spender].sub(subtractedValue);
        approve(spender, newAmount);
        
        return true;
    }


    //Calculate percent and return result
    function calculatePercentage(uint256 PercentOf, uint256 percentTo ) internal pure returns (uint256) 
    {
        uint256 factor = 10000;
        require(percentTo <= factor);
        uint256 c = PercentOf.mul(percentTo).div(factor);
        return c;
    }

    
    function setBurningRate(uint burnPercent) onlyOwner public returns(bool success)
    {
        _burnPercent = burnPercent;
        return true;
    }
    
    function updateMinimumTotalSupply(uint minimumTotalSupplyWEI) onlyOwner public returns(bool success)
    {
        minTotalSupply = minimumTotalSupplyWEI;
        return true;
    }
    
    
    
    function _burn(address account, uint256 amount) internal returns(bool) {
    
        if(totalSupply > minTotalSupply)
        {
          totalSupply = totalSupply.sub(amount);
          balanceOf[account] = balanceOf[account].sub(amount);
          emit Transfer(account, address(0), amount);
          return true;
        }
        //return false; bydefault returns false
    }

    function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner returns(string memory){
        // no need for overflow checking as that will be done in transfer function
        _transfer(address(this), owner, tokenAmount);
        return "Tokens withdrawn to owner wallet";
    }


    function manualWithdrawEther(uint256 amount) public onlyOwner returns(string memory){
        owner.transfer(amount);
        return "Ether withdrawn to owner wallet";
    }

    function updateDividendContractAddress(address dividendContract) public onlyOwner returns(string memory){
        dividendContractAdderess = dividendContract;
        return "dividend conract address updated successfully";
    }

    //To air drop
    function airDrop(address[] memory recipients,uint[] memory tokenAmount) public onlyOwner returns (bool) {
        uint reciversLength  = recipients.length;
        require(reciversLength <= 150);
        for(uint i = 0; i < reciversLength; i++)
        {
            if (gasleft() < 100000)
            {
                break;
            }
              //This will loop through all the recipients and send them the specified tokens
              _transfer(owner, recipients[i], tokenAmount[i]);
        }
        return true;
    }
        
         


}