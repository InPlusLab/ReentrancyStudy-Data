/**
 *Submitted for verification at Etherscan.io on 2019-07-02
*/

pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The constructor sets the original `owner` of the contract to the sender
   * account.
   */
    constructor() public
    {
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
  function transferOwnership(address newOwner) onlyOwner public {
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
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
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
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public
    returns (bool success) {
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
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
}

contract BaconCoin is BurnableToken, Ownable {

    string public constant name = "BaconCoin";
    string public constant symbol = "BAK";
    uint public constant decimals = 8;
    uint256 public constant initialSupply = 2200000000 * (10 ** uint256(decimals));

    // use Nonce for stop replay-attack
    struct Wallet {
        uint256 balance;
        uint256 tokenBalance;
        mapping(address => bool) authed;   
        uint64 seedNonce;
        uint64 withdrawNonce;
    }
    
    address[] public admins;

    mapping(bytes32 => Wallet) private wallets;
    mapping(address => bool) private isAdmin;

    uint256 private agentBalance;
    uint256 private agentTokenBalance;
    
    modifier onlyAdmin {
        require(isAdmin[msg.sender]);
        _;
    }

    modifier onlyRootAdmin {
        require(msg.sender == admins[0]);
        _;
    }

    event Auth(
        bytes32 indexed walletID,
        address indexed agent
    );

    event Withdraw(
        bytes32 indexed walletID,
        uint256 indexed nonce,
        uint256 indexed value,
        address recipient
    );
    
    event Deposit(
        bytes32 indexed walletID,
        address indexed sender,
        uint256 indexed value
    );

    event Seed(
        bytes32 indexed walletID,
        uint256 indexed nonce,
        uint256 indexed value
    );

    event Gain(
        bytes32 indexed walletID,
        uint256 indexed requestID,
        uint256 indexed value
    );

    event DepositToken(
        bytes32 indexed walletID,
        address indexed sender, 
        uint256 indexed amount
    );
    
    event WithdrawToken(
        bytes32 indexed walletID,
        uint256 indexed nonce,
        uint256 indexed amount,
        address recipient
    );
    
    event SeedToken(
        bytes32 indexed walletID,
        uint256 indexed nonce,
        uint256 indexed amount
    );

    event GainToken(
        bytes32 indexed walletID,
        uint256 indexed requestID,
        uint256 indexed amount
    );
    
    constructor() public
    {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; 

        admins.push(msg.sender);
        isAdmin[msg.sender] = true;
    }

    function auth(
        bytes32[] walletIDs,
        bytes32[] nameIDs,
        address[] agents,
        uint8[] v, bytes32[] r, bytes32[] s) onlyAdmin public
    {
        require(
            walletIDs.length == nameIDs.length &&
            walletIDs.length == agents.length &&
            walletIDs.length == v.length &&
            walletIDs.length == r.length &&
            walletIDs.length == s.length
        );

        for (uint i = 0; i < walletIDs.length; i++) {
            bytes32 walletID = walletIDs[i];
            address agent = agents[i];

            address signer = getMessageSigner(
                getAuthDigest(walletID, agent), v[i], r[i], s[i]
            );

            Wallet storage wallet = wallets[walletID];

            if (wallet.authed[signer] || walletID == getWalletDigest(nameIDs[i], signer)) {
                wallet.authed[agent] = true;

                emit Auth(walletID, agent);
            }
        }
    }

    function deposit( bytes32 walletID) payable public
    {
        wallets[walletID].balance += msg.value;

        emit Deposit(walletID, msg.sender, msg.value);
    }

    function withdraw(
        bytes32[] walletIDs,
        address[] receivers,
        uint256[] values,
        uint64[] nonces,
        uint8[] v, bytes32[] r, bytes32[] s) onlyAdmin public
    {
        require(
            walletIDs.length == receivers.length &&
            walletIDs.length == values.length &&
            walletIDs.length == nonces.length &&
            walletIDs.length == v.length &&
            walletIDs.length == r.length &&
            walletIDs.length == s.length
        );

        for (uint i = 0; i < walletIDs.length; i++) {
            bytes32 walletID = walletIDs[i];
            address receiver = receivers[i];
            uint256 value = values[i];
            uint64 nonce = nonces[i];

            address signer = getMessageSigner(
                getWithdrawDigest(walletID, receiver, value, nonce), v[i], r[i], s[i]
            );

            Wallet storage wallet = wallets[walletID];

            if (
                wallet.withdrawNonce < nonce &&
                wallet.balance >= value &&
                wallet.authed[signer] &&
                receiver.send(value)
            ) {
                wallet.withdrawNonce = nonce;
                wallet.balance -= value;

                emit Withdraw(walletID, nonce, value, receiver);
            }
        }
    }

    function seed(
        bytes32[] walletIDs,
        uint256[] values,
        uint64[] nonces,
        uint8[] v, bytes32[] r, bytes32[] s) onlyAdmin public
    {
        require(
            walletIDs.length == values.length &&
            walletIDs.length == nonces.length &&
            walletIDs.length == v.length &&
            walletIDs.length == r.length &&
            walletIDs.length == s.length
        );

        uint256 addition = 0;

        for (uint i = 0; i < walletIDs.length; i++) {
            bytes32 walletID = walletIDs[i];
            uint256 value = values[i];
            uint64 nonce = nonces[i];

            address signer = getMessageSigner(
                getSeedDigest(walletID, value, nonce), v[i], r[i], s[i]
            );

            Wallet storage wallet = wallets[walletID];

            if (
                wallet.seedNonce < nonce &&
                wallet.balance >= value &&
                wallet.authed[signer]
            ) {
                wallet.seedNonce = nonce;
                wallet.balance -= value;

                emit Seed(walletID, nonce, value);

                addition += value;
            }
        }

        agentBalance += addition;
    }


    function gain(
        bytes32[] walletIDs,
        uint256[] recordIDs,
        uint256[] values) onlyAdmin public
    {
        require(
            walletIDs.length == recordIDs.length &&
            walletIDs.length == values.length
        );

        uint256 remaining = agentBalance;

        for (uint i = 0; i < walletIDs.length; i++) {
            bytes32 walletID = walletIDs[i];
            uint256 value = values[i];

            require(value <= remaining);

            wallets[walletID].balance += value;
            remaining -= value;

            emit Gain(walletID, recordIDs[i], value);
        }

        agentBalance = remaining;
    }

    function getMessageSigner(
        bytes32 message,
        uint8 v, bytes32 r, bytes32 s) public pure returns(address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedMessage = keccak256(
            abi.encodePacked(prefix, message)
        );
        return ecrecover(prefixedMessage, v, r, s);
    }

    function getNameDigest(
        string myname) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(myname));
    }

    function getWalletDigest(
        bytes32 myname,
        address root) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(
            myname, root
        ));
    }

    function getAuthDigest(
        bytes32 walletID,
        address agent) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(
            walletID, agent
        ));
    }

    function getSeedDigest(
        bytes32 walletID,
        uint256 value,
        uint64 nonce) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(
            walletID, value, nonce
        ));
    }

    function getWithdrawDigest(
        bytes32 walletID,
        address receiver,
        uint256 value,
        uint64 nonce) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(
            walletID, receiver, value, nonce
        ));
    }

    function getSeedNonce(
        bytes32 walletID) public view returns (uint256)
    {
        return wallets[walletID].seedNonce + 1;
    }

    function getWithdrawNonce(
        bytes32 walletID) public view returns (uint256)
    {
        return wallets[walletID].withdrawNonce + 1;
    }

    function getAuthStatus(
        bytes32 walletID,
        address member) public view returns (bool)
    {
        return wallets[walletID].authed[member];
    }

    function getBalance(
        bytes32 walletID) public view returns (uint256)
    {
        return wallets[walletID].balance;
    }
    
    function gettokenBalance(
        bytes32 walletID) public view returns (uint256)
    {
        return wallets[walletID].tokenBalance;
    }

    function getagentBalance() public view returns (uint256)
    {
      return agentBalance;
    }

    function getagentTokenBalance() public view returns (uint256)
    {
      return agentTokenBalance;
    }
    
    function removeAdmin(
        address oldAdmin) onlyRootAdmin public
    {
        require(isAdmin[oldAdmin] && admins[0] != oldAdmin);

        bool found = false;
        for (uint i = 1; i < admins.length - 1; i++) {
            if (!found && admins[i] == oldAdmin) {
                found = true;
            }
            if (found) {
                admins[i] = admins[i + 1];
            }
        }

        admins.length--;
        isAdmin[oldAdmin] = false;
    }

    function changeRootAdmin(
        address newRootAdmin) onlyRootAdmin public
    {
        if (isAdmin[newRootAdmin] && admins[0] != newRootAdmin) {
            removeAdmin(newRootAdmin);
        }
        admins[0] = newRootAdmin;
        isAdmin[newRootAdmin] = true;
    }

    function addAdmin(
        address newAdmin) onlyRootAdmin public
    {
        require(!isAdmin[newAdmin]);

        isAdmin[newAdmin] = true;
        admins.push(newAdmin);
    }
    
    function depositToken(bytes32 walletID, uint256 amount) public returns (bool)
    {
        require(amount > 0);
        require(approve(msg.sender, amount+1));
   
        uint256 _allowance = allowed[msg.sender][msg.sender];
        balances[msg.sender] = balances[msg.sender].sub(amount);

        wallets[walletID].tokenBalance = wallets[walletID].tokenBalance.add(amount);
        allowed[msg.sender][msg.sender] = _allowance.sub(amount);

        emit DepositToken(walletID, msg.sender, amount);
        return true;
    }
  
    function withdrawToken(
        bytes32[] walletIDs,
        address[] receivers,
        uint256[] amounts,
        uint64[] nonces,
        uint8[] v, bytes32[] r, bytes32[] s) onlyAdmin public returns (bool)
    {
        require(
            walletIDs.length == receivers.length &&
            walletIDs.length == amounts.length &&
            walletIDs.length == nonces.length &&
            walletIDs.length == v.length &&
            walletIDs.length == r.length &&
            walletIDs.length == s.length
        );

        for (uint i = 0; i < walletIDs.length; i++) {
            bytes32 walletID = walletIDs[i];
            address receiver = receivers[i];
            uint256 amount = amounts[i];
            uint64 nonce = nonces[i];
            
            address signer = getMessageSigner(
                getWithdrawDigest(walletID, receiver, amount, nonce), v[i], r[i], s[i]
            );
            Wallet storage wallet = wallets[walletID];
            if (
                wallet.withdrawNonce < nonce &&
                wallet.tokenBalance >= amount &&
                wallet.authed[signer]
            ) 
            {
                wallet.withdrawNonce = nonce;
                wallet.tokenBalance = wallet.tokenBalance.sub(amount);
		        balances[receiver] = balances[receiver].add(amount);
		       
                emit WithdrawToken(walletID, nonce, amount, receiver);
                return true;
            }
        }
    }

    function seedToken(
        bytes32[] walletIDs,
        uint256[] amounts,
        uint64[] nonces,
        uint8[] v, bytes32[] r, bytes32[] s) onlyAdmin public
    {
        require(
            walletIDs.length == amounts.length &&
            walletIDs.length == nonces.length &&
            walletIDs.length == v.length &&
            walletIDs.length == r.length &&
            walletIDs.length == s.length
        );
        
        uint256 addition = 0;

        for (uint i = 0; i < walletIDs.length; i++) {
            bytes32 walletID = walletIDs[i];
            uint256 amount = amounts[i];
            uint64 nonce = nonces[i];

            address signer = getMessageSigner(
                getSeedDigest(walletID, amount, nonce), v[i], r[i], s[i]
            );

            Wallet storage wallet = wallets[walletID];
            if (
                wallet.seedNonce < nonce &&
                wallet.tokenBalance >= amount &&
                wallet.authed[signer]
            ) {
                wallet.seedNonce = nonce;
                wallet.tokenBalance = wallet.tokenBalance.sub(amount);
                emit SeedToken(walletID, nonce, amount);
                addition += amount;
            }
        }

        agentTokenBalance += addition;
    }


    function gainToken(
        bytes32[] walletIDs,
        uint256[] recordIDs,
        uint256[] amounts) onlyAdmin public
    {
        require(
            walletIDs.length == recordIDs.length &&
            walletIDs.length == amounts.length
        );

        uint256 remaining = agentTokenBalance;
        
        
        for (uint i = 0; i < walletIDs.length; i++) {
            bytes32 walletID = walletIDs[i];
            uint256 amount = amounts[i];
            
            Wallet storage wallet = wallets[walletID];
            require(amount <= remaining);

            wallet.tokenBalance = wallet.tokenBalance.add(amount);
            remaining = remaining.sub(amount);

            emit GainToken(walletID, recordIDs[i], amount);
        }

        agentTokenBalance = remaining;
    }

}