pragma solidity 0.4.23;


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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    /// Total amount of tokens
    uint256 public totalSupply;
  
    function balanceOf(address _owner) public view returns (uint256);
  
    function transfer(address _to, uint256 _amount) public returns (bool);
  
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender) public view returns (uint256);
  
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool);
  
    function approve(address _spender, uint256 _amount) public returns (bool);
  
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

  //balance in each address account
    mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _amount The amount to be transferred.
  */
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0));
        require(balances[msg.sender] >= _amount && _amount > 0 && balances[_to].add(_amount) > balances[_to]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
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
 */
contract StandardToken is ERC20, BasicToken {
  
  
    mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _amount uint256 the amount of tokens to be transferred
   */
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0));
        require(balances[_from] >= _amount);
        require(allowed[_from][msg.sender] >= _amount);
        require(_amount > 0 && balances[_to].add(_amount) > balances[_to]);

        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        emit Transfer(_from, _to, _amount);
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
   * @param _amount The amount of tokens to be spent.
   */
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
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

}
/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    constructor()public {
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
    function transferOwnership(address newOwner)public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

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
        totalSupply = totalSupply.add(_amount);
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
 * @title VCT Token
 * @dev Token representing VCT.
 */
contract VCTToken is BurnableToken,Ownable,MintableToken {
    string public name ;
    string public symbol ;
    uint8 public decimals = 18 ;
     
     /**
     *@dev users sending ether to this contract will be reverted. Any ether sent to the contract will be sent back to the caller
     */
    function ()public payable {
        revert("Sending ether to the contract is not allowed");
    }
     
     /**
     * @dev Constructor function to initialize the initial supply of token to the creator of the contract
     * @param initialSupply The initial supply of tokens which will be fixed through out
     * @param tokenName The name of the token
     * @param tokenSymbol The symbol of the token
     */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
        ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals); //Update total supply with the decimal amount
        name = tokenName;
        symbol = tokenSymbol;
        balances[msg.sender] = totalSupply;
         
        //Emitting transfer event since assigning all tokens to the creator also corresponds to the transfer of tokens to the creator
        emit Transfer(address(0), msg.sender, totalSupply);
    }
     
     /**
     * @dev allows token holders to send tokens to multiple addresses from one single transaction
     * Beware that sending tokens to large number of addresses in one transaction might exceed gas limit of the 
     * transaction or even for the entire block. Not putting any restriction on the number of addresses which are
     * allowed per transaction. But it should be taken into account while creating dapps.
     * @param dests The addresses to whom user wants to send tokens
     * @param values The number of tokens to be sent to each address
     */
    function multiSend(address[]dests, uint[]values)public{
        require(dests.length==values.length, "Number of addresses and values should be same");
        uint256 i = 0;
        while (i < dests.length) {
            transfer(dests[i], values[i]);
            i += 1;
        }
    }
     
     /**
     *@dev helper method to get token details, name, symbol and totalSupply in one go
     */
    function getTokenDetail() public view returns (string, string, uint256) {
        return (name, symbol, totalSupply);
    }
}