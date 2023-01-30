pragma solidity ^0.4.4;

/**
 * @title Contract for object that have an owner
 */
contract Owned {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * @dev Delegate contract to another person
     * @param _owner New owner address 
     */
    function setOwner(address _owner) onlyOwner
    { owner = _owner; }

    /**
     * @dev Owner check modifier
     */
    modifier onlyOwner { if (msg.sender != owner) throw; _; }
}

/**
 * @title Common pattern for destroyable contracts 
 */
contract Destroyable {
    address public hammer;

    /**
     * @dev Hammer setter
     * @param _hammer New hammer address
     */
    function setHammer(address _hammer) onlyHammer
    { hammer = _hammer; }

    /**
     * @dev Destroy contract and scrub a data
     * @notice Only hammer can call it 
     */
    function destroy() onlyHammer
    { suicide(msg.sender); }

    /**
     * @dev Hammer check modifier
     */
    modifier onlyHammer { if (msg.sender != hammer) throw; _; }
}

/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned, Destroyable {
    function Object() {
        owner  = msg.sender;
        hammer = msg.sender;
    }
}

// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
contract ERC20 
{
// Functions:
    /// @return total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256);

// Events:
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Presale is Object {
    ERC20   public token;
    uint256 public bounty;
    uint256 public donation;

    /**
     * @dev Presale contract constructor
     * @param _token Bounty token address
     * @param _bounty Bount value by donation
     * @param _donation Donation value
     */
    function Presale(address _token, uint256 _bounty, uint256 _donation) {
        token    = ERC20(_token);
        bounty   = _bounty;
        donation = _donation;
    }

    /**
     * @dev Cancel presale contract by owner, bounty refunded to owner
     */
    function cancel() onlyOwner {
        if (!token.transfer(owner, bounty)) throw;
    }

    /**
    * @dev Accept presale contract,
    *      bounty transfered to sender - donation to owner
    */
    function () payable {
        if (msg.value != donation) throw;
        if (!token.transfer(msg.sender, bounty)) throw;
        if (!owner.send(msg.value)) throw;
    }
}

library CreatorPresale {
    function create(address _token, uint256 _bounty, uint256 _donation) returns (Presale)
    { return new Presale(_token, _bounty, _donation); }

    function version() constant returns (string)
    { return "v0.6.3"; }

    function abi() constant returns (string)
    { return &#39;[{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"hammer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"destroy","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"donation","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"bounty","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_hammer","type":"address"}],"name":"setHammer","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"cancel","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"_token","type":"address"},{"name":"_bounty","type":"uint256"},{"name":"_donation","type":"uint256"}],"payable":false,"type":"constructor"},{"payable":true,"type":"fallback"}]&#39;; }
}

/**
 * @title Builder based contract
 */
contract Builder is Object {
    /**
     * @dev this event emitted for every builded contract
     */
    event Builded(address indexed client, address indexed instance);
 
    /* Addresses builded contracts at sender */
    mapping(address => address[]) public getContractsOf;
 
    /**
     * @dev Get last address
     * @return last address contract
     */
    function getLastContract() constant returns (address) {
        var sender_contracts = getContractsOf[msg.sender];
        return sender_contracts[sender_contracts.length - 1];
    }

    /* Building beneficiary */
    address public beneficiary;

    /**
     * @dev Set beneficiary
     * @param _beneficiary is address of beneficiary
     */
    function setBeneficiary(address _beneficiary) onlyOwner
    { beneficiary = _beneficiary; }

    /* Building cost  */
    uint public buildingCostWei;

    /**
     * @dev Set building cost
     * @param _buildingCostWei is cost
     */
    function setCost(uint _buildingCostWei) onlyOwner
    { buildingCostWei = _buildingCostWei; }

    /* Security check report */
    string public securityCheckURI;

    /**
     * @dev Set security check report URI
     * @param _uri is an URI to report
     */
    function setSecurityCheck(string _uri) onlyOwner
    { securityCheckURI = _uri; }
}
//
// AIRA Builder for Congress contract
//
contract BuilderPresale is Builder {
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create(address _token,
                    uint256 _bounty,
                    uint256 _donation,
                    address _client) payable returns (address) {
        if (buildingCostWei > 0 && beneficiary != 0) {
            // Too low value
            if (msg.value < buildingCostWei) throw;
            // Beneficiary send
            if (!beneficiary.send(buildingCostWei)) throw;
            // Refund
            if (msg.value > buildingCostWei) {
                if (!msg.sender.send(msg.value - buildingCostWei)) throw;
            }
        } else {
            // Refund all
            if (msg.value > 0) {
                if (!msg.sender.send(msg.value)) throw;
            }
        }

        if (_client == 0)
            _client = msg.sender;
 
        var inst = CreatorPresale.create(_token, _bounty, _donation);
        inst.setOwner(_client);
        inst.setHammer(_client);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        return inst;
    }
}