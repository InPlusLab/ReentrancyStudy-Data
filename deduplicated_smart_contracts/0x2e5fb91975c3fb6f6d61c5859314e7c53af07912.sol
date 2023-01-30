pragma solidity 0.4.21;

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

contract ERC820Registry {
    function getManager(address addr) public view returns(address);
    function setManager(address addr, address newManager) public;
    function getInterfaceImplementer(address addr, bytes32 iHash) public constant returns (address);
    function setInterfaceImplementer(address addr, bytes32 iHash, address implementer) public;
}

contract ERC820Implementer {
    ERC820Registry erc820Registry = ERC820Registry(0x991a1bcb077599290d7305493c9A630c20f8b798);

    function setInterfaceImplementation(string ifaceLabel, address impl) internal {
        bytes32 ifaceHash = keccak256(ifaceLabel);
        erc820Registry.setInterfaceImplementer(this, ifaceHash, impl);
    }

    function interfaceAddr(address addr, string ifaceLabel) internal constant returns(address) {
        bytes32 ifaceHash = keccak256(ifaceLabel);
        return erc820Registry.getInterfaceImplementer(addr, ifaceHash);
    }

    function delegateManagement(address newManager) internal {
        erc820Registry.setManager(this, newManager);
    }
}
interface ERC777TokensSender {
    function tokensToSend(address operator, address from, address to, uint amount, bytes userData,bytes operatorData) external;
}


interface ERC777TokensRecipient {
    function tokensReceived(address operator, address from, address to, uint amount, bytes userData, bytes operatorData) external;
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev The constructor sets the original owner of the contract to the sender account.
   */
  function Ownable() public {
    setOwner(msg.sender);
  }

  /**
   * @dev Sets a new owner address
   */
  function setOwner(address newOwner) internal {
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    setOwner(newOwner);
  }
}

contract JaroCoinToken is Ownable, ERC820Implementer {
    using SafeMath for uint256;

    string public constant name = "JaroCoin";
    string public constant symbol = "JARO";
    uint8 public constant decimals = 18;
    uint256 public constant granularity = 1e10;   // Token has 8 digits after comma

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => bool)) public isOperatorFor;
    mapping (address => mapping (uint256 => bool)) private usedNonces;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Sent(address indexed operator, address indexed from, address indexed to, uint256 amount, bytes userData, bytes operatorData);
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes userData, bytes operatorData);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply = 0;
    uint256 public constant maxSupply = 21000000e18;


    // ------- ERC777/ERC965 Implementation ----------

    /**
    * @notice Send `_amount` of tokens to address `_to` passing `_userData` to the recipient
    * @param _to The address of the recipient
    * @param _amount The number of tokens to be sent
    * @param _userData Data generated by the user to be sent to the recipient
    */
    function send(address _to, uint256 _amount, bytes _userData) public {
        doSend(msg.sender, _to, _amount, _userData, msg.sender, "", true);
    }

    /**
    * @dev transfer token for a specified address via cheque
    * @param _to The address to transfer to
    * @param _amount The amount to be transferred
    * @param _userData The data to be executed
    * @param _nonce Unique nonce to avoid double spendings
    */
    function sendByCheque(address _to, uint256 _amount, bytes _userData, uint256 _nonce, uint8 v, bytes32 r, bytes32 s) public {
        require(_to != address(this));

        // Check if signature is valid, get signer's address and mark this cheque as used.
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(prefix, keccak256(_to, _amount, _userData, _nonce));
        // bytes32 hash = keccak256(_to, _amount, _userData, _nonce);

        address signer = ecrecover(hash, v, r, s);
        require (signer != 0);
        require (!usedNonces[signer][_nonce]);
        usedNonces[signer][_nonce] = true;

        // Transfer tokens
        doSend(signer, _to, _amount, _userData, signer, "", true);
    }

    /**
    * @notice Authorize a third party `_operator` to manage (send) `msg.sender`'s tokens.
    * @param _operator The operator that wants to be Authorized
    */
    function authorizeOperator(address _operator) public {
        require(_operator != msg.sender);
        isOperatorFor[_operator][msg.sender] = true;
        emit AuthorizedOperator(_operator, msg.sender);
    }

    /**
    * @notice Revoke a third party `_operator`'s rights to manage (send) `msg.sender`'s tokens.
    * @param _operator The operator that wants to be Revoked
    */
    function revokeOperator(address _operator) public {
        require(_operator != msg.sender);
        isOperatorFor[_operator][msg.sender] = false;
        emit RevokedOperator(_operator, msg.sender);
    }

    /**
    * @notice Send `_amount` of tokens on behalf of the address `from` to the address `to`.
    * @param _from The address holding the tokens being sent
    * @param _to The address of the recipient
    * @param _amount The number of tokens to be sent
    * @param _userData Data generated by the user to be sent to the recipient
    * @param _operatorData Data generated by the operator to be sent to the recipient
    */
    function operatorSend(address _from, address _to, uint256 _amount, bytes _userData, bytes _operatorData) public {
        require(isOperatorFor[msg.sender][_from]);
        doSend(_from, _to, _amount, _userData, msg.sender, _operatorData, true);
    }

    /* -- Helper Functions -- */
    /**
    * @notice Internal function that ensures `_amount` is multiple of the granularity
    * @param _amount The quantity that want's to be checked
    */
    function requireMultiple(uint256 _amount) internal pure {
        require(_amount.div(granularity).mul(granularity) == _amount);
    }

    /**
    * @notice Check whether an address is a regular address or not.
    * @param _addr Address of the contract that has to be checked
    * @return `true` if `_addr` is a regular address (not a contract)
    */
    function isRegularAddress(address _addr) internal constant returns(bool) {
        if (_addr == 0) { return false; }
        uint size;
        assembly { size := extcodesize(_addr) } // solhint-disable-line no-inline-assembly
        return size == 0;
    }

    /**
    * @notice Helper function that checks for ERC777TokensSender on the sender and calls it.
    *  May throw according to `_preventLocking`
    * @param _from The address holding the tokens being sent
    * @param _to The address of the recipient
    * @param _amount The amount of tokens to be sent
    * @param _userData Data generated by the user to be passed to the recipient
    * @param _operatorData Data generated by the operator to be passed to the recipient
    *  implementing `ERC777TokensSender`.
    *  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer
    *  functions SHOULD set this parameter to `false`.
    */
    function callSender(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData
    ) private {
        address senderImplementation = interfaceAddr(_from, "ERC777TokensSender");
        if (senderImplementation != 0) {
            ERC777TokensSender(senderImplementation).tokensToSend(
                _operator, _from, _to, _amount, _userData, _operatorData);
        }
    }

    /**
    * @notice Helper function that checks for ERC777TokensRecipient on the recipient and calls it.
    *  May throw according to `_preventLocking`
    * @param _from The address holding the tokens being sent
    * @param _to The address of the recipient
    * @param _amount The number of tokens to be sent
    * @param _userData Data generated by the user to be passed to the recipient
    * @param _operatorData Data generated by the operator to be passed to the recipient
    * @param _preventLocking `true` if you want this function to throw when tokens are sent to a contract not
    *  implementing `ERC777TokensRecipient`.
    *  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer
    *  functions SHOULD set this parameter to `false`.
    */
    function callRecipient(
        address _operator,
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        bytes _operatorData,
        bool _preventLocking
    ) private {
        address recipientImplementation = interfaceAddr(_to, "ERC777TokensRecipient");
        if (recipientImplementation != 0) {
            ERC777TokensRecipient(recipientImplementation).tokensReceived(
                _operator, _from, _to, _amount, _userData, _operatorData);
        } else if (_preventLocking) {
            require(isRegularAddress(_to));
        }
    }

    /**
    * @notice Helper function actually performing the sending of tokens.
    * @param _from The address holding the tokens being sent
    * @param _to The address of the recipient
    * @param _amount The number of tokens to be sent
    * @param _userData Data generated by the user to be passed to the recipient
    * @param _operatorData Data generated by the operator to be passed to the recipient
    * @param _preventLocking `true` if you want this function to throw when tokens are sent to a contract not
    *  implementing `erc777_tokenHolder`.
    *  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer
    *  functions SHOULD set this parameter to `false`.
    */
    function doSend(
        address _from,
        address _to,
        uint256 _amount,
        bytes _userData,
        address _operator,
        bytes _operatorData,
        bool _preventLocking
    )
        private
    {
        requireMultiple(_amount);

        callSender(_operator, _from, _to, _amount, _userData, _operatorData);

        require(_to != 0x0);                  // forbid sending to 0x0 (=burning)
        require(balanceOf[_from] >= _amount); // ensure enough funds

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        callRecipient(_operator, _from, _to, _amount, _userData, _operatorData, _preventLocking);

        emit Sent(_operator, _from, _to, _amount, _userData, _operatorData);
        emit Transfer(_from, _to, _amount);
    }

    // ------- ERC20 Implementation ----------

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        doSend(msg.sender, _to, _value, "", msg.sender, "", false);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another. Technically this is not ERC20 transferFrom but more ERC777 operatorSend.
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(isOperatorFor[msg.sender][_from]);
        doSend(_from, _to, _value, "", msg.sender, "", true);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**

     * @dev Originally in ERC20 this function to check the amount of tokens that an owner allowed to a spender.
     *
     * Function was added purly for backward compatibility with ERC20. Use operator logic from ERC777 instead.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A returning uint256 balanceOf _spender if it's active operator and 0 if not.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 _amount) {
        if (isOperatorFor[_spender][_owner]) {
            _amount = balanceOf[_owner];
        } else {
            _amount = 0;
        }
    }

    /**
     * @dev Approve the passed address to spend tokens on behalf of msg.sender.
     *
     * This function is more authorizeOperator and revokeOperator from ERC777 that Approve from ERC20.
     * Approve concept has several issues (e.g. https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729),
     * so I prefer to use operator concept. If you want to revoke approval, just put 0 into _value.
     * @param _spender The address which will spend the funds.
     * @param _value Fake value to be compatible with ERC20 requirements.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != msg.sender);

        if (_value > 0) {
            // Authorizing operator
            isOperatorFor[_spender][msg.sender] = true;
            emit AuthorizedOperator(_spender, msg.sender);
        } else {
            // Revoking operator
            isOperatorFor[_spender][msg.sender] = false;
            emit RevokedOperator(_spender, msg.sender);
        }

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // ------- Minting and burning ----------

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @param _operatorData Data that will be passed to the recipient as a first transfer.
    */
    function mint(address _to, uint256 _amount, bytes _operatorData) public onlyOwner {
        require (totalSupply.add(_amount) <= maxSupply);
        requireMultiple(_amount);

        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        callRecipient(msg.sender, 0x0, _to, _amount, "", _operatorData, true);

        emit Minted(msg.sender, _to, _amount, _operatorData);
        emit Transfer(0x0, _to, _amount);
    }

    /**
    * @dev Function to burn sender's tokens
    * @param _amount The amount of tokens to burn.
    * @return A boolean that indicates if the operation was successful.
    */
    function burn(uint256 _amount, bytes _userData) public {
        require (_amount > 0);
        require (balanceOf[msg.sender] >= _amount);
        requireMultiple(_amount);

        callSender(msg.sender, msg.sender, 0x0, _amount, _userData, "");

        totalSupply = totalSupply.sub(_amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);

        emit Burned(msg.sender, msg.sender, _amount, _userData, "");
        emit Transfer(msg.sender, 0x0, _amount);
    }

}