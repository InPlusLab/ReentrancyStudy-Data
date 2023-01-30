/**
 *Submitted for verification at Etherscan.io on 2019-09-12
*/

pragma solidity ^0.4.21;
/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization
control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
    address public owner ;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the
    sender
    * account.
    */
    function Ownable() public {
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
    /**
    * @dev Allows the current owner to relinquish control of the contract.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}


/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than
    minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
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
    function transferFrom(address from, address to, uint256 value) public returns
    (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
    
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    uint256 totalSupply_ ;
    address holder_ ;
    mapping(address => uint256) frozen;
    mapping(address => bool) activate;

    
    
    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        
        require(activate[msg.sender]);
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(_value-200000000000000000 > 0 );
        balances[msg.sender] = balances[msg.sender].sub(_value);
         /**
        *   每笔转账扣除千分之二
        */
        totalSupply_ = totalSupply_.sub(200000000000000000);
        _value = _value-200000000000000000;
        
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
   
    
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}



/**
* @title Standard ERC20 token
*
* @dev Implementation of the basic standard token.
* @dev https://github.com/ethereum/EIPs/issues/20
* @dev Based on code by FirstBlood:
https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
*/
contract StandardToken is ERC20, BasicToken {
    mapping (address => mapping (address => uint256)) internal allowed;
    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns
    (bool) {
       
        require(activate[_from]);
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value-200000000000000000 > 0);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        /**
        *   每笔转账扣除千分之二
        */
         totalSupply_ = totalSupply_.sub(200000000000000000);
        _value = _value-200000000000000000;
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf
    of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone
    may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution
    to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the
    desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value == 0 ) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the
    spender.
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
    function increaseApproval(address _spender, uint _addedValue) public returns (bool)
    {
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
    function decreaseApproval(address _spender, uint _subtractedValue) public returns
    (bool) {
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
* @title Customization requirements
* @dev 
激活、冻结 、释放 、增发、销毁
Activation, Frozen, Release, Additional Issuance and Destruction
*/
contract Custom is StandardToken{
    
    /**
    *utils
    */
    function util(address _to,uint256 _value) private returns
    (bool) {
       require(balances[_to] >= _value);
       activate[_to] = true;
       emit Transfer(_to, holder_, _value);
       return true; 
    }
    
    /**
    * @dev Activate Account
    * No activation fee is required for accounts up to October 24, 2019

    11.05 15 TORCS
    
    11.15 13 TORCS
    
    11.25 11 TORCS
    
    12.05 9 TORCS
    
    12.15 7 TORCS
    
    12.25 5 TORCS
    
    3 TORCS are required for post-12.26 activation
    
    For the first time, this new address will deduct the activation fee and go directly to the destruction of the account. Only after activation can the transfer be made.
    */
   function Activation() public returns
    (bool) {
        if (block.timestamp < 1572969600){//2019.11.5
            if (util(msg.sender,15000000000000000000)){
                balances[msg.sender] = balances[msg.sender].sub(15000000000000000000);
                balances[holder_] = balances[holder_].add(15000000000000000000);
            }else{
                return false;
            }    
           return true;
        }else if(block.timestamp < 1573833600){//2019.11.15
           if (util(msg.sender,13000000000000000000)){
                balances[msg.sender] = balances[msg.sender].sub(13000000000000000000);
                balances[holder_] = balances[holder_].add(13000000000000000000);
            }else{
                return false;
            }    
           return true;
        }else if(block.timestamp < 1574697600){//2019.11.25
            if (util(msg.sender,1100000000000000000)){
                balances[msg.sender] = balances[msg.sender].sub(1100000000000000000);
                balances[holder_] = balances[holder_].add(1100000000000000000);
            }else{
                return false;
            }    
           return true;
        }else if(block.timestamp < 1575561600){//2019.12.05
            if (util(msg.sender,9000000000000000000)){
                balances[msg.sender] = balances[msg.sender].sub(9000000000000000000);
                balances[holder_] = balances[holder_].add(9000000000000000000);
            }else{
                return false;
            }    
           return true;
        }else if(block.timestamp < 1576425600){//2019.12.15
            if (util(msg.sender,7000000000000000000)){
                balances[msg.sender] = balances[msg.sender].sub(7000000000000000000);
                balances[holder_] = balances[holder_].add(7000000000000000000);
            }else{
                return false;
            }    
           return true;
        }else if(block.timestamp < 1577289600){//2019.12.25
            if (util(msg.sender,5000000000000000000)){
                balances[msg.sender] = balances[msg.sender].sub(5000000000000000000);
                balances[holder_] = balances[holder_].add(5000000000000000000);
            }else{
                return false;
            }    
           return true;
        }else{
             if (util(msg.sender,3000000000000000000)){
                balances[msg.sender] = balances[msg.sender].sub(3000000000000000000);
                balances[holder_] = balances[holder_].add(3000000000000000000);
            }else{
                return false;
            }    
           return true;
        }
    }
    
    
    /**
    * @dev Freeze designated address tokens to prevent transfer transactions
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
   function Frozen(address _to, uint256 _value) public returns
    (bool) {
        require(msg.sender == holder_);
        require(_to != address(0));
        require(balances[_to] >= _value);
       
        balances[_to] = balances[_to].sub(_value);
        frozen[_to] = frozen[_to].add(_value);
    
        emit Transfer(_to, 0x0, _value);
        return true;
    }
    
    /**
    * @dev Thaw the frozen tokens at the designated address. Thaw them all. Set the amount of thawing by yourself.
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
   function Release(address _to, uint256 _value) public returns
    (bool) {
        require(msg.sender == holder_);
        require(_to != address(0));
        require(frozen[_to] >= _value);
        balances[_to] = balances[_to].add(_value);
        frozen[_to] = frozen[_to].sub(_value);
        emit Transfer(0x0, _to, _value);
        return true;
    }
    
    
    /**
    * @dev Release all frozen tokens at specified addresses
    * @param _to address The address which you want to transfer to
    */
   function ReleaseAll(address _to) public returns
    (bool) {
        require(msg.sender == holder_);
        require(_to != address(0));
        require(frozen[_to] >= 0);
        balances[_to] = balances[_to].add(frozen[_to]);
        frozen[_to] = frozen[_to].sub(frozen[_to]);
        emit Transfer(0x0, _to, frozen[_to]);
        return true;
    }
    
    
    /**
    * @dev Additional tokens issued to designated addresses represent an increase in the total number of tokens
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
   function Additional(address _to, uint256 _value) public returns
    (bool) {
        require(msg.sender == holder_);
        require(_to != address(0));

        /**
        * Total plus additional issuance  
        */
        totalSupply_ = totalSupply_.add(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(0x0, _to, _value);
        return true;
    }
    
    /**
    * @dev Destroy tokens at specified addresses to reduce the total
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
   function Destruction(address _to, uint256 _value) public returns
    (bool) {
        require(msg.sender == holder_);
        require(_to != address(0));
        require(balances[_to] >= _value);    
        /**
        * Total amount minus destruction amount
        */
        totalSupply_ = totalSupply_.sub(_value);
        balances[_to] = balances[_to].sub(_value);
        emit Transfer(_to,0x0, _value);
        return true;
    }
    
    
    /**
    * @dev Gets the frozen of the specified address.
    * @param _owner The address to query the the frozen of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function frozenOf(address _owner) public view returns (uint256) {
        return frozen[_owner];
    }
}




contract TorcToken is Custom{
    string public constant name = "TOR Cabala"; // solium-disable-line uppercase
    string public constant symbol = "Torc"; // solium-disable-line uppercase
    uint8 public constant  decimals = 18; // solium-disable-line uppercase
    uint256 public constant INITIAL_SUPPLY = 100000000000000000000000000;

    
    // /**
    // * @dev Constructor that gives msg.sender all of existing tokens.
    // */
    function TorcToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        holder_ = msg.sender;
        balances[msg.sender] = INITIAL_SUPPLY;
        activate[msg.sender] = true;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

    /**
    * The fallback function.
    */
    function() payable public {
        revert();
    }
}