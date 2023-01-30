/**

 *Submitted for verification at Etherscan.io on 2019-03-17

*/



pragma solidity 0.5.6; /*



___________________________________________________________________

  _      _                                        ______           

  |  |  /          /                                /              

--|-/|-/-----__---/----__----__---_--_----__-------/-------__------

  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     

__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_





�������������[ �����[     �����[�����[  �����[���������������[    �����������������[ �������������[ �����[  �����[���������������[�������[   �����[

�����X�T�T�����[�����U     �����U�����U �����X�a�����X�T�T�T�T�a    �^�T�T�����X�T�T�a�����X�T�T�T�����[�����U �����X�a�����X�T�T�T�T�a���������[  �����U

�����U  �����U�����U     �����U�����������X�a �����������[         �����U   �����U   �����U�����������X�a �����������[  �����X�����[ �����U

�����U  �����U�����U     �����U�����X�T�����[ �����X�T�T�a         �����U   �����U   �����U�����X�T�����[ �����X�T�T�a  �����U�^�����[�����U

�������������X�a���������������[�����U�����U  �����[���������������[       �����U   �^�������������X�a�����U  �����[���������������[�����U �^���������U

�^�T�T�T�T�T�a �^�T�T�T�T�T�T�a�^�T�a�^�T�a  �^�T�a�^�T�T�T�T�T�T�a       �^�T�a    �^�T�T�T�T�T�a �^�T�a  �^�T�a�^�T�T�T�T�T�T�a�^�T�a  �^�T�T�T�a

                                                                                   

                                                                                   

// ----------------------------------------------------------------------------

// 'DlikeToken' contract with following features

//      => ERC20 Compliance

//      => Higher degree of control by owner - safeguard functionality

//      => SafeMath implementation 

//      => Burnable and minting 

//      => in-built buy/sell functions (owner can control buying/selling process)

//

// Name        : DlikeToken

// Symbol      : DLIKE

// Total supply: 800,000,000 (800 Million)

// Decimals    : 18

//

// Copyright 2019 onwards - Dlike ( https://dlike.io )

// Contract designed and audited by EtherAuthority ( https://EtherAuthority.io )

// Special thanks to openzeppelin for inspiration:  ( https://github.com/OpenZeppelin )

// ----------------------------------------------------------------------------

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





//*******************************************************************//

//------------------ Contract to Manage Ownership -------------------//

//*******************************************************************//

    

contract owned {

    address payable internal owner;

    

     constructor () public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address payable newOwner) onlyOwner public {

        owner = newOwner;

    }

}

    



    

//****************************************************************************//

//---------------------        MAIN CODE STARTS HERE     ---------------------//

//****************************************************************************//

    

contract DlikeToken is owned {

    



    /*===============================

    =         DATA STORAGE          =

    ===============================*/



    // Public variables of the token

    using SafeMath for uint256;

    string constant public name = "DlikeToken";

    string constant public symbol = "DLIKE";

    uint256 constant public decimals = 18;

    uint256 public totalSupply = 800000000 * (10**decimals);   //800 million tokens

    uint256 public maximumMinting;

    bool public safeguard = false;  //putting safeguard on will halt all non-owner functions

    

    // This creates a mapping with all data storage

    mapping (address => uint256) internal _balanceOf;

    mapping (address => mapping (address => uint256)) internal _allowance;

    mapping (address => bool) internal _frozenAccount;





    /*===============================

    =         PUBLIC EVENTS         =

    ===============================*/



    // This generates a public event of token transfer

    event Transfer(address indexed from, address indexed to, uint256 value);

    

    // This will log approval of token Transfer

    event Approval(address indexed from, address indexed spender, uint256 value);



    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);

        

    // This generates a public event for frozen (blacklisting) accounts

    event FrozenFunds(address indexed target, bool indexed frozen);







    /*======================================

    =       STANDARD ERC20 FUNCTIONS       =

    ======================================*/

    

    /**

     * Check token balance of any user

     */

    function balanceOf(address owner) public view returns (uint256) {

        return _balanceOf[owner];

    }

    

    /**

     * Check allowance of any spender versus owner

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowance[owner][spender];

    }

    

    /**

     * Check if particular user address is frozen or not

     */

    function frozenAccount(address owner) public view returns (bool) {

        return _frozenAccount[owner];

    }



    /**

     * Internal transfer, only can be called by this contract

     */

    function _transfer(address _from, address _to, uint _value) internal {

        

        //checking conditions

        require(!safeguard);

        require (_to != address(0));                         // Prevent transfer to 0x0 address. Use burn() instead

        require(!_frozenAccount[_from]);                     // Check if sender is frozen

        require(!_frozenAccount[_to]);                       // Check if recipient is frozen

        

        // overflow and undeflow checked by SafeMath Library

        _balanceOf[_from] = _balanceOf[_from].sub(_value);   // Subtract from the sender

        _balanceOf[_to] = _balanceOf[_to].add(_value);       // Add the same to the recipient

        

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

        require(_value <= _allowance[_from][msg.sender]);     // Check _allowance

        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);

        _transfer(_from, _to, _value);

        return true;

    }



    /**

        * Set _allowance for other address

        *

        * Allows `_spender` to spend no more than `_value` tokens in your behalf

        *

        * @param _spender The address authorized to spend

        * @param _value the max amount they can spend

        */

    function approve(address _spender, uint256 _value) public returns (bool success) {

        require(!safeguard);

        _allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    

    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to increase the _allowance by.

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

     * @param value The amount of tokens to decrease the _allowance by.

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

    

    constructor() public{

        //sending all the tokens to Owner

        _balanceOf[owner] = totalSupply;

        

        //maximum minting set to totalSupply

        maximumMinting = totalSupply;

        

        //firing event which logs this transaction

        emit Transfer(address(0), owner, totalSupply);

    }

    

    /* No need for empty fallback function as contract without it will automatically rejects incoming ether */

    //function () external payable { revert; }



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

        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);  // Subtract from the sender

        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply

        emit Burn(msg.sender, _value);

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

        //checking of _allowance and token value is done by SafeMath

        _balanceOf[_from] = _balanceOf[_from].sub(_value);                         // Subtract from the targeted balance

        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value); // Subtract from the sender's _allowance

        totalSupply = totalSupply.sub(_value);                                   // Update totalSupply

        emit  Burn(_from, _value);

        return true;

    }

        

    

    /** 

        * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens

        * @param target Address to be frozen

        * @param freeze either to freeze it or not

        */

    function freezeAccount(address target, bool freeze) onlyOwner public {

            _frozenAccount[target] = freeze;

        emit  FrozenFunds(target, freeze);

    }

    

    /** 

        * @notice Create `mintedAmount` tokens and send it to `target`

        * @param target Address to receive the tokens

        * @param mintedAmount the amount of tokens it will receive

        */

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        totalSupply = totalSupply.add(mintedAmount);

        //owner can not mint more than max supply of tokens, to prevent 'Evil Mint' issue!!

        require(totalSupply <= maximumMinting, 'Minting reached its maximum minting limit' );

        _balanceOf[target] = _balanceOf[target].add(mintedAmount);

        

        emit Transfer(address(0), target, mintedAmount);

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



}