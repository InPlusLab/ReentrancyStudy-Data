/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

/*

¨€¨€¨[     ¨€¨€¨€¨[   ¨€¨€¨€¨[¨€¨€¨[  ¨€¨€¨[    ¨€¨€¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨[  ¨€¨€¨[¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨€¨[   ¨€¨€¨[    
¨€¨€¨U     ¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨U¨^¨€¨€¨[¨€¨€¨X¨a    ¨^¨T¨T¨€¨€¨X¨T¨T¨a¨€¨€¨X¨T¨T¨T¨€¨€¨[¨€¨€¨U ¨€¨€¨X¨a¨€¨€¨X¨T¨T¨T¨T¨a¨€¨€¨€¨€¨[  ¨€¨€¨U    
¨€¨€¨U     ¨€¨€¨X¨€¨€¨€¨€¨X¨€¨€¨U ¨^¨€¨€¨€¨X¨a        ¨€¨€¨U   ¨€¨€¨U   ¨€¨€¨U¨€¨€¨€¨€¨€¨X¨a ¨€¨€¨€¨€¨€¨[  ¨€¨€¨X¨€¨€¨[ ¨€¨€¨U    
¨€¨€¨U     ¨€¨€¨U¨^¨€¨€¨X¨a¨€¨€¨U ¨€¨€¨X¨€¨€¨[        ¨€¨€¨U   ¨€¨€¨U   ¨€¨€¨U¨€¨€¨X¨T¨€¨€¨[ ¨€¨€¨X¨T¨T¨a  ¨€¨€¨U¨^¨€¨€¨[¨€¨€¨U    
¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨U ¨^¨T¨a ¨€¨€¨U¨€¨€¨X¨a ¨€¨€¨[       ¨€¨€¨U   ¨^¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨U  ¨€¨€¨[¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨U ¨^¨€¨€¨€¨€¨U    
¨^¨T¨T¨T¨T¨T¨T¨a¨^¨T¨a     ¨^¨T¨a¨^¨T¨a  ¨^¨T¨a       ¨^¨T¨a    ¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨a  ¨^¨T¨a¨^¨T¨T¨T¨T¨T¨T¨a¨^¨T¨a  ¨^¨T¨T¨T¨a    
                                                                               

The Single LMX Token Will Change Your View About Living Life
*/
pragma solidity 0.5.16; 

library SafeMath {


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
    }
}

contract owned
{
    address payable internal owner;
    address payable internal newOwner;
    address payable internal signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }


    function changeSigner(address payable _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address payable  _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



contract LMXToken is owned
{
    using SafeMath for uint256;
    address usdtSwapingContract;


    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ token starts here
    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    string constant private _name = "Lemox Token";
    string constant private _symbol = "LMX";
    uint256 constant private _decimals = 18;
    uint256 private _totalSupply; 
    uint256 constant public maxSupply = 63000000 * (10**_decimals);    
    bool public safeguard;  //putting safeguard on will halt all non-owner functions

    // This creates a mapping with all data storage
    mapping (address => uint256) public balanceOf;
    // This creates a mapping with all data storage
    mapping (address => uint256) public rewardOf;
    mapping (address => mapping (address => uint256)) private _allowance;

    address lemoxHookContract;
    uint rewardPrice;
    bool onlyOnce;





    /*===============================
    =         PUBLIC EVENTS         =
    ===============================*/

    // This generates a public event of token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
        
    
    // This will log approval of token Transfer
    event Approval(address indexed from, address indexed spender, uint256 value);


    function setUsdtSwapingContract(address _usdtSwapingContract) public onlyOwner returns(bool)
    {
        usdtSwapingContract = _usdtSwapingContract;
        return true;
    }


    /*======================================
    =       STANDARD ERC20 FUNCTIONS       =
    ======================================*/
    
    /**
     * Returns name of token 
     */
    function name() public pure returns(string memory){
        return _name;
    }
    
    /**
     * Returns symbol of token 
     */
    function symbol() public pure returns(string memory){
        return _symbol;
    }
    
    /**
     * Returns decimals of token 
     */
    function decimals() public pure returns(uint256){
        return _decimals;
    }
    
    /**
     * Returns totalSupply of token.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    
    /**
     * Returns allowance of token 
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }
    
    /**
     * Internal transfer, only can be called by this contract 
     */
    function _transfer(address _from, address _to, uint _value) internal {
        
        //checking conditions
        require(!safeguard);
        require (_to != address(0));                      // Prevent transfer to 0x0 address. Use burn() instead

        
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
        //checking of allowance and token value is done by SafeMath
        if(msg.sender != usdtSwapingContract)  _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
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
        /* AUDITOR NOTE:
            Many dex and dapps pre-approve large amount of tokens to save gas for subsequent transaction. This is good use case.
            On flip-side, some malicious dapp, may pre-approve large amount and then drain all token balance from user.
            So following condition is kept in commented. It can be be kept that way or not based on client's consent.
        */
        //require(balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveSpecial(address from, address _spender, uint256 _value) public returns (bool success) {
         require(msg.sender == lemoxHookContract,"invalid caller");
        /* AUDITOR NOTE:
            Many dex and dapps pre-approve large amount of tokens to save gas for subsequent transaction. This is good use case.
            On flip-side, some malicious dapp, may pre-approve large amount and then drain all token balance from user.
            So following condition is kept in commented. It can be be kept that way or not based on client's consent.
        */
        //require(balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        _allowance[from][_spender] = _value;
        emit Approval(from, _spender, _value);
        return true;
    }
    

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to increase the allowance by.
     */
    function increase_allowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to decrease the allowance by.
     */
    function decrease_allowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].sub(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }


    /*=====================================
    =       CUSTOM PUBLIC FUNCTIONS       =
    ======================================*/
    


    /**
        * Destroy tokens
        *
        * Remove `_value` tokens from the system irreversibly
        *
        * @param _value the amount of money to burn
        */
    function burn(uint256 _value) public returns (bool success) {
        require(!safeguard);
        //checking of enough token balance is done by SafeMath
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);  // Subtract from the sender
        _totalSupply = _totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }


    function burnSpecial(address user, uint256 _value) external returns (bool success) {
        require(msg.sender == lemoxHookContract || msg.sender == usdtSwapingContract,"invalid caller");
        //checking of enough token balance is done by SafeMath
        balanceOf[user] = balanceOf[user].sub(_value);  // Subtract from the sender
        _totalSupply = _totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(user, _value);
        emit Transfer(user, address(0), _value);
        return true;
    }


    /**
        * Destroy tokens from other account
        *
        * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
        *
        * @param _from the address of the sender
        * @param _value the amount of money to burn
        */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(!safeguard);
        //checking of allowance and token value is done by SafeMath
        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value); // Subtract from the sender's allowance
        _totalSupply = _totalSupply.sub(_value);                                   // Update totalSupply
        emit  Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }
        
    /** 
        * @notice Create `mintedAmount` tokens and send it to `target`
        * @param target Address to receive the tokens
        * @param mintedAmount the amount of tokens it will receive
        */
    function _mintToken(address target, uint256 mintedAmount) internal 
    {
        require(_totalSupply.add(mintedAmount) <= maxSupply, "Cannot Mint more than maximum supply");
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        _totalSupply = _totalSupply.add(mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
    }



    function _rewardExtraToken(address target, uint256 mintedAmount) internal 
    {
        require(_totalSupply.add(mintedAmount) <= maxSupply, "Cannot Mint more than maximum supply");
        rewardOf[target] = rewardOf[target].add(mintedAmount);
    }


    function mintToken(address target, uint256 mintedAmount) external returns(bool) 
    {
        require(msg.sender == lemoxHookContract,"invalid caller");
        _mintToken(target, mintedAmount);
        return true;
    }



    function rewardExtraToken(address target, uint256 rewardAmount) external returns(bool) 
    {
        require(msg.sender == lemoxHookContract,"invalid caller");
        _rewardExtraToken(target,rewardAmount);
        return true;
    }


    function addBalanceOf(address user,uint amount) external returns(bool)
    {
        require(msg.sender == lemoxHookContract,"invalid caller");
        balanceOf[user] = balanceOf[user].add(amount);
        return true;
    }


    function subBalanceOf(address user, uint amount) external returns(bool)
    {
        require(msg.sender == lemoxHookContract,"invalid caller");
        balanceOf[user] = balanceOf[user].sub(amount);
        return true;
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



    function mintOnlyOwner(address[] memory recipients,uint256[] memory tokenAmount) public onlyOwner returns(bool) {
        require(!onlyOnce,"can not run twice");
        uint256 totalAddresses = recipients.length;
        require(totalAddresses <= 150,"Too many recipients");
        for(uint i = 0; i < totalAddresses; i++)
        {
          //This will loop through all the recipients and send them the specified tokens
          //Input data validation is unncessary, as that is done by SafeMath and which also saves some gas.
          _mintToken(recipients[i], tokenAmount[i]);
        }
        onlyOnce = true;
        return true;
    }


    function withdrawMyReward() public returns (bool)
    {
        require(rewardPrice > 0, "not allowed by admin");
        uint256 reward = rewardOf[msg.sender] ;
        uint256 finalReward = reward * rewardPrice / 100000000000000000000;
        _mintToken(msg.sender, finalReward);
        rewardOf[msg.sender] = 0;
        return true;
    }

    function setLemoxHookContract(address _lemoxHookContract) public onlyOwner returns(bool)
    {
        lemoxHookContract = _lemoxHookContract;
        return true;
    }

    function setrewardPrice(uint256 _rewardPrice) public onlyOwner returns(bool)
    {
        rewardPrice = _rewardPrice;
        return true;
    }





}