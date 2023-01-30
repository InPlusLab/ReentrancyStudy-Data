/**
 *Submitted for verification at Etherscan.io on 2020-02-25
*/

pragma solidity ^0.4.17;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}




/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  //lock the amount of the specified address.
  mapping(address => uint256) public lockValues;
  //Foundation wallet address
  address public fundWallet=0x861c70B7E2122209D26FecF3Ed25b2C1758Cd869;
  //private Crowd
  address public privateWallet=0xBd0bd747181e77EE2683Fc525908F2d52b300217;
  // eth to FTC rate   uint256 public constant DAGTEXCHANGE
  uint256 public  ethExchangeFtcRate=2000;

  address public mintMaster;

  //1000000000*10**18 total ,150000000
  uint256 totalSupply_=1000000000*10**18;

  uint256 mintNums_;



  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function totalMintNums() public view returns (uint256) {
        return mintNums_;
   }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    address addr = msg.sender;
    require(addr!= address(0));
    require(_value <= balances[addr]);
    uint256 transBlalance = balances[addr].sub(lockValues[addr]);
    require(_value <= transBlalance);
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;

  }


  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    ///
    uint256 transBlalance = balances[_from].sub(lockValues[_from]);
    require(_value <= transBlalance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);
    return true;

  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   * 0x8d2f55E47274348A6E29CA240DD084463b7B9A0d,
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    uint256 transBlalance = balances[msg.sender].sub(lockValues[msg.sender]);
    require(_value <= transBlalance);

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}




/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
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
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}



/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}



/**
 * @dev FTC token ERC20 contract
 */
contract EtherFreeToken is MintableToken, PausableToken {
    string public constant version = "1.0";
    string public  name = "EtherFree";
    string public  symbol = "ETF";
    uint8 public constant decimals = 18;

    event MintMasterTransferred(address indexed previousMaster, address indexed newMaster);
     event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value);

    modifier onlyMintMasterOrOwner() {
        require(msg.sender == mintMaster || msg.sender == owner);
        _;
    }

    /**
     * init Genesis block
    *
    */
    constructor() public {
        mintMaster = msg.sender;
        //End initial foundation data

    }


    function transferMintMaster(address newMaster) onlyOwner public {
        require(newMaster != address(0));
        emit MintMasterTransferred(mintMaster, newMaster);
        mintMaster = newMaster;
    }

    function mintToAddresses(address[] addresses, uint256 amount) public onlyMintMasterOrOwner canMint {
        for (uint i = 0; i < addresses.length; i++) {
            require(mint(addresses[i], amount));
        }
    }

    function mintToAddressesAndAmounts(address[] addresses, uint256[] amounts) public onlyMintMasterOrOwner canMint {
        require(addresses.length == amounts.length);
        for (uint i = 0; i < addresses.length; i++) {
            require(mint(addresses[i], amounts[i]));
        }
    }
    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyMintMasterOrOwner canMint public returns (bool) {

        mintNums_ = mintNums_.add(_amount);
        require(mintNums_<=totalSupply_);
        owner = msg.sender;
        bool result = super.mint(_to, _amount);
        return result;
    }



    function () payable public  {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary)  payable public returns (bool){
       require(beneficiary != 0x0,"ERC20: transfer from the zero address");

       uint256 weiAmount = msg.value;
       uint256 ftcTokens = weiAmount.mul(ethExchangeFtcRate);
       uint256 balnaceofpri = balances[privateWallet];
       require(balnaceofpri >= ftcTokens, "ERC20: transfer from the balnaceofpri Amount false");

       balances[beneficiary]=balances[beneficiary].add(ftcTokens);
       balances[privateWallet]=balances[privateWallet].sub(ftcTokens);
        emit Transfer(privateWallet, beneficiary, ftcTokens);

       privateWallet.transfer(msg.value);


       emit TokenPurchase(privateWallet, beneficiary, msg.value);

       return true;




    }

   // reset name and symbol
    function setNameSymbol(string newName, string newSymbol) public onlyMintMasterOrOwner {
        name=newName;
        symbol=newSymbol;
  }


   function addLockValues(address _to, uint256 _amount) public onlyMintMasterOrOwner{
       require(_to != address(0));
       require(_amount >=0);
       lockValues[_to]=lockValues[_to].add(_amount);
   }

   function releaseLockValues(address _to, uint256 _amount) public onlyMintMasterOrOwner returns (bool){
        bool ret =false;
       require(_to != address(0));
       require(_amount >=0);
       uint256 lockAmount = lockValues[_to];
       require(lockAmount>=_amount);
       lockValues[_to]=lockValues[_to].sub(_amount);
       ret=true;
       return ret;

   }
   /**
    *
    *  udpate  FTC's Rate of exchange for eth
    */
   function changeEthRoFtcRate(uint256 _amount) public onlyMintMasterOrOwner returns (bool) {
         bool ret =false;
         require(_amount >=0);
         ethExchangeFtcRate = _amount;
         ret=true;
         return ret;
   }

    /**
    *  0x3b17ac05fb5384ff145cc44542e4200df734dd3773182ca429e71879dbe1ea0d
    *  udpate  crowd£¨Private placement£© address
    */
   function changePrivateWallet(address _newAddress) public onlyMintMasterOrOwner returns (bool) {
         bool ret =false;
         require(_newAddress != address(0));
         privateWallet = _newAddress;
         ret=true;
         return ret;
   }







}