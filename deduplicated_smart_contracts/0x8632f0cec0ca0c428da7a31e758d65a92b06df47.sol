/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity 0.5.11; /*


___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_


██████╗  █████╗ ███╗   ██╗██╗  ██╗     ██████╗ ██████╗ ██╗███╗   ██╗
██╔══██╗██╔══██╗████╗  ██║╚██╗██╔╝    ██╔════╝██╔═══██╗██║████╗  ██║
██████╔╝███████║██╔██╗ ██║ ╚███╔╝     ██║     ██║   ██║██║██╔██╗ ██║
██╔══██╗██╔══██║██║╚██╗██║ ██╔██╗     ██║     ██║   ██║██║██║╚██╗██║
██████╔╝██║  ██║██║ ╚████║██╔╝ ██╗    ╚██████╗╚██████╔╝██║██║ ╚████║
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
                                                                                                                                                  
                                                                              

=== 'BanxCoin' Token contract with following features ===
    => ERC20 Compliance
    => Higher degree of control by owner - safeguard functionality
    => SafeMath implementation 
    => Burnable and minting 


======================= Quick Stats ===================
    => Name             : Banx coin
    => Symbol           : BXN
    => Initial Supply   : 500000000 tokens - vested
    => Total supply     : (Minting on demand)
    => Decimals         : 18
    

====================== Vesting Logic ===================
    => 500 million tokens will be vested, means will be kept aside for owner to withdraw in defined intervals
    => Owner can withdraw 1% of it after 60 days after contract deployment


============= Independant Audit of the code ============
    => Multiple Freelancers Auditors



-------------------------------------------------------------------
 Copyright (c) 2019 onwards Banx Coin Inc. ( http://banxcoin.org )
 Contract designed with ❤ by EtherAuthority ( https://EtherAuthority.io )
-------------------------------------------------------------------
*/ 




//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//
/**
    * @title SafeMath
    * @dev Math operations with safety checks that throw on error
    */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address payable public owner;
    address payable internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
 

    
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
    
contract Banxcoin is owned {
    

    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;
    string constant public name = "Banx coin";
    string constant public symbol = "BXN";
    uint256 constant public decimals = 18;
    uint256 public totalSupply;
    
    address public burnAddress;     //This variable will hold the address of the contract or any address where the tokens will be sent to be burned
    bool public safeguard;      //putting safeguard on will halt all non-owner functions

    // Vesting related variables
    uint256 public totalVestedTokens = 500000000 * (10**decimals);      // 500 million tokens vested
    uint256 public monthlyVestingRelease = totalVestedTokens / 100;     // 1% of totalVestedTokens
    uint256 public vestedTokensWithdrawn;                               // how many vested tokens withdrawn by owner
    uint256 public deploymentTimestamp;
    
    
    
    // This creates a mapping with all data storage
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;
    mapping (address => bool) public transferAccounts;
    mapping (address => bool) public burnAccounts;
    mapping (address => bool) public minterAccounts;
    mapping (address => bool) public creatorAccounts;



    /*===============================
    =       OPERATOR MODIFIERS      =
    ===============================*/

    //This allows only authorized transfer operators to transfer tokens
    modifier onlyTransferOperator {
        require(transferAccounts[msg.sender]);
        _;
    }

    //This allows only authorized burn operators to burn tokens
    modifier onlyBurnOperator {
        require(burnAccounts[msg.sender]);
        _;
    }

    //This allows only authorized minters to mint new tokens
    modifier onlyMintOperator {
        require(minterAccounts[msg.sender]);
        _;
    }

    //This allows only owners and authorized operator creators to create new operators
    modifier onlyOwnerOrCreator {
        require(creatorAccounts[msg.sender] || msg.sender == owner);
        _;
    }


    /*===============================
    =         PUBLIC EVENTS         =
    ===============================*/

    // This generates a public event of token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, address indexed to, uint256 value);
        
    // This notifies clients about the amount minted
    event Mint(address indexed to, uint256 value);
        
    // This generates a public event for frozen (blacklisting) accounts
    event FrozenAccounts(address target, bool frozen);
    
    // This will log approval of token Transfer
    event Approval(address indexed from, address indexed spender, uint256 value);

    //This will log the addition of operators
    event AddOperator(address indexed operator, string  role);
    
    //This will log the removal of operators
    event RemoveOperator(address indexed operator, string  role);
    
    //This will log any changes in the burn address
    event UpdateBurnAddress(address indexed oldAddress, address indexed newAddress, uint256  timestamp);
    
    //This will log the vesting EVENTS
    event WithdrawVestedTokens(address userAddress, uint256 numberOfTokens);

    /*======================================
    =       STANDARD ERC20 FUNCTIONS       =
    ======================================*/

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        
        //checking conditions
        require(!safeguard);
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        
		if(_to == burnAddress)
		{
			burn(_from, _value);
		}
		else
		{
            // overflow and undeflow checked by SafeMath Library
            balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
            balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
            
            // emit Transfer event
            emit Transfer(_from, _to, _value);
		}
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
        
        //no need to check for input validations, as that is ruled by SafeMath
        _transfer(msg.sender, _to, _value);
        
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
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
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
        require(!safeguard);
        require(balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    /*=====================================
    =       CUSTOM PUBLIC FUNCTIONS       =
    ======================================*/
    
    constructor() public{
        
        //Setting deployment timestamp;
        deploymentTimestamp = now;
        
        burnAddress = address(this);

    }
    
    //just accept incoming ether
    function () external payable {}

    /**
        * Destroy tokens
        *
        * Remove `_value` tokens from the system irreversibly
        *
        * @param _value the amount of money to burn
        */
    function burn(address _from, uint256 _value) internal returns (bool success) {

        //checking of enough token balance is done by SafeMath
        balanceOf[_from] = balanceOf[_from].sub(_value);            // Subtract from the targeted balance
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(_from, burnAddress, _value);
        emit Transfer(_from, burnAddress, _value);
        return true;
    }


    /**
        * Destroy tokens from user account by Burn Operator only
        *
        * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
        *
        * @param _from the address of the sender
        * @param _value the amount of money to burn
        */
    function burnFrom(address _from, uint256 _value) onlyBurnOperator public returns (bool success) {
        
        require(!safeguard);
        
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value); // Subtract from the sender's allowance
        
        burn(_from, _value);
        
        return true;
    }


    /** 
        * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
        * @param target Address to be frozen
        * @param freeze either to freeze it or not
        */
    function freezeAccount(address target, bool freeze) onlyOwner public {
            frozenAccount[target] = freeze;
        emit  FrozenAccounts(target, freeze);
    }
    
    /** 
        * @notice Create `mintedAmount` tokens and send it to `target`
        * @param target Address to receive the tokens
        * @param mintedAmount the amount of tokens it will receive
        */
    function _mintToken(address target, uint256 mintedAmount) internal {
        
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Mint(target, mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
    }
    
    function mintToken(address target, uint256 mintedAmount) onlyMintOperator public {
        _mintToken(target, mintedAmount);
    }



    /**
        * Owner can transfer tokens from contract to owner address
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    
    function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner{
        // no need for overflow checking as that will be done in transfer function
        _transfer(address(this), owner, tokenAmount);
    }
    
    //Just in rare case, owner wants to transfer Ether from contract to owner address
    function manualWithdrawEther()onlyOwner public{
        address(owner).transfer(address(this).balance);
    }
    
    /**
        * Change safeguard status on or off
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    function changeSafeguardStatus() onlyOwner public{
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;    
        }
    }

    //Owner can change the address which is used to send the tokens to burn.
    function updateBurnAddress(address _burnAddress) onlyOwner public {
        address oldAddress = burnAddress;
        burnAddress = _burnAddress;
        emit UpdateBurnAddress(oldAddress, _burnAddress, now);
    }
    

    
    
    /*============================================
    =   OPERATOR CREATION & DELETION FUNCTIONS   =
    ============================================*/
    

    function addBurnAccount(address operator) onlyOwnerOrCreator public returns(bool) {
        burnAccounts[operator] = true;
        emit  AddOperator(operator, 'Burn');
        return true;
    }
    
    function removeBurnAccount(address operator) onlyOwnerOrCreator public returns(bool) {
        burnAccounts[operator] = false;
        emit  RemoveOperator(operator, 'Burn');
        return true;
    }

    function addMinterAccount(address operator) onlyOwnerOrCreator public returns(bool) {
        minterAccounts[operator] = true;
        emit  AddOperator(operator, 'Minter');
        return true;
    }
    
    function removeMinterAccount(address operator) onlyOwnerOrCreator public returns(bool) {
        minterAccounts[operator] = false;
        emit  RemoveOperator(operator, 'Minter');
        return true;
    }
    
    function addCreatorAccount(address operator) onlyOwnerOrCreator public returns(bool) {
        creatorAccounts[operator] = true;
        emit  AddOperator(operator, 'Creator');
        return true;
    }
    
    function removeCreatorAccount(address operator) onlyOwnerOrCreator public returns(bool) {
        creatorAccounts[operator] = false;
        emit  RemoveOperator(operator, 'Creator');
        return true;
    }
    
    
    /*============================================
    =             VESTING FUNCTIONS              =
    ============================================*/

    // Function to view available vested tokens
    function availableTokensFromVesting() public view returns(uint256) {
        
        uint256 currentTimeStamp = now;
        uint256 vestingStartTimestamp = deploymentTimestamp + 5184000;  //deploy time plus 60*60*24*60 = 60 days after contract deployment
        
        if(currentTimeStamp < vestingStartTimestamp || vestedTokensWithdrawn >= totalVestedTokens)
        {
            return 0;
        }
        else
        {
            
            uint256 timestampDiff = currentTimeStamp - vestingStartTimestamp;
            uint256 numMonths = 1 + (timestampDiff / 2592000);        //finding months after vesting release time
            uint256 tokensAllTime = monthlyVestingRelease * numMonths;
            
            return tokensAllTime - vestedTokensWithdrawn;
            
        }

   }
   
   //function to withdraw desired number of tokens from the available tokens.
   function withdrawVestingTokens() onlyOwner public returns (bool) {
       
       uint256 tokensToWithdraw = availableTokensFromVesting();
       
       if(tokensToWithdraw > 0){
           
           _mintToken(msg.sender, tokensToWithdraw);
           vestedTokensWithdrawn += tokensToWithdraw;

           emit WithdrawVestedTokens(msg.sender, tokensToWithdraw);
           return true;
       }
   }
   
   

}