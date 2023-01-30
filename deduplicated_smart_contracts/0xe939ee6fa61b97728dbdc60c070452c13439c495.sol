/**

 *Submitted for verification at Etherscan.io on 2019-08-21

*/



pragma solidity ^0.4.12;



contract Token {

    /* This is a slight change to the ERC20 base standard.

    function totalSupply() constant returns (uint256 supply);

    is replaced with:

    uint256 public totalSupply;

    This automatically creates a getter function for the totalSupply.

    This is moved to the base contract since public getter functions are not

    currently recognised as an implementation of the matching abstract

    function by the compiler.

    */

    /// total amount of tokens

    uint256 public totalSupply;



    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) constant returns (uint256 balance);



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) returns (bool success);



    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);



    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of tokens to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) returns (bool success);



    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}





/* Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20 */



contract ERC20 is Token {



    function transfer(address _to, uint256 _value) returns (bool success) {

        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        balances[msg.sender] -= _value;

        balances[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        balances[_to] += _value;

        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);

        return true;

    }



    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



    mapping (address => uint256) public balances; // *added public

    mapping (address => mapping (address => uint256)) public allowed; // *added public

}



contract EmpowBonus {

    

    event Bonus(address indexed _address, uint32 indexed dapp_id, uint256 _time, uint256 _bonus_amount, uint256 _pay_amount);

    

    struct BonusHistory {

        address user;

        uint32 dapp_id;

        uint256 time;

        uint32 pay_type;

        uint256 bonus_amount;

        uint256 pay_amount;

    }

    

    mapping (address => uint256) public countBonus;

    mapping (address => mapping (uint256 => BonusHistory)) public bonusHistories;

    

    address public owner;

    address public USDTAddress;

    

    modifier onlyOwner () {

        require(msg.sender == owner);

        _;

    }

    

    function EmpowBonus ()

        public

    {

        owner = msg.sender;

    }

    

    function bonus (uint32 _dapp_id, uint256 _bonus_amount)

        public

        payable

        returns(bool)

    {

        require(msg.value > 0);

        

        countBonus[msg.sender]++;

        

        uint256 currentTime = block.timestamp;

        

        Bonus(msg.sender, _dapp_id, 0, _bonus_amount, msg.value);

        saveHistory(msg.sender, _dapp_id, currentTime, 0, _bonus_amount, msg.value); // pay_type (0 = ETH, 1 = USDT)

        

        return true;

    }

    

    function bonusWithUsdt (uint32 _dapp_id, uint256 _bonus_amount, uint256 _amount_usdt)

        public

        returns(bool)

    {

        require(_amount_usdt > 0);

        // transfer USDT

        require(ERC20(USDTAddress).transferFrom(msg.sender, owner, _amount_usdt));

        

        countBonus[msg.sender]++;

        

        uint256 currentTime = block.timestamp;

        

        Bonus(msg.sender, _dapp_id, 1, _bonus_amount, _amount_usdt);

        saveHistory(msg.sender, _dapp_id, currentTime, 1, _bonus_amount, _amount_usdt); // pay_type (0 = ETH, 1 = USDT)

    }

    

    function saveHistory (address _address, uint32 _dapp_id, uint256 _time, uint32 _pay_type, uint256 _bonus_amount, uint256 _pay_amount)

        private

        returns(bool)

    {

        bonusHistories[msg.sender][countBonus[_address]].user = _address;

        bonusHistories[msg.sender][countBonus[_address]].dapp_id = _dapp_id;

        bonusHistories[msg.sender][countBonus[_address]].time = _time;

        bonusHistories[msg.sender][countBonus[_address]].pay_type = _pay_type;

        bonusHistories[msg.sender][countBonus[_address]].bonus_amount = _bonus_amount;

        bonusHistories[msg.sender][countBonus[_address]].pay_amount = _pay_amount;

        return true;

    }

    

    // OWNER functions

    function updateUSDTAddress (address _address)

        public

        onlyOwner

        returns (bool)

    {

        USDTAddress = _address;

        return true;

    }

    

    function withdraw (uint256 _amount) 

        public

        onlyOwner

        returns (bool)

    {

        owner.transfer(_amount);

        return true;

    }

}