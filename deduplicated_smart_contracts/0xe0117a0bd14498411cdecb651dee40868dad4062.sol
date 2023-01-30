/**

 *Submitted for verification at Etherscan.io on 2018-08-18

*/



pragma solidity ^0.4.19;



contract ERC20 {



    /// @return total amount of tokens

    function totalSupply() public constant returns (uint supply);



    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) public constant returns (uint balance);



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint _value) public returns (bool success);



    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);



    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of wei to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint _value) public returns (bool success);



    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) public constant returns (uint remaining);



    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

}



contract ODCToken is ERC20 {



    uint public _totalSupply = 100*10**26;

    uint8 constant public decimals = 18;

    string constant public name = "OdcToken";

    string constant public symbol = "ODC";



    mapping (address => uint) balances;

    mapping (address => mapping (address => uint)) allowed;



    function ODCToken() public {

        balances[msg.sender] = _totalSupply;

        Transfer(address(0), msg.sender, _totalSupply);

    }



    function totalSupply() public constant returns (uint supply) {

        return _totalSupply;

    }



    function balanceOf(address _owner) public constant returns (uint) {

        return balances[_owner];

    }



    function transfer(address _to, uint _value) public returns (bool) {

        //Default assumes totalSupply can't be over max (2^256 - 1).

        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } else { return false; }

    }







    uint constant MAX_UINT = 2**256 - 1;

    

    /// @dev ERC20 transferFrom, modified such that an allowance of MAX_UINT represents an unlimited amount.

    /// @param _from Address to transfer from.

    /// @param _to Address to transfer to.

    /// @param _value Amount to transfer.

    /// @return Success of transfer.

    function transferFrom(address _from, address _to, uint _value)

        public

        returns (bool)

    {

        uint allowance = allowed[_from][msg.sender];

        if (balances[_from] >= _value

            && allowance >= _value

            && balances[_to] + _value >= balances[_to]

        ) {

            balances[_to] += _value;

            balances[_from] -= _value;

            if (allowance < MAX_UINT) {

                allowed[_from][msg.sender] -= _value;

            }

            Transfer(_from, _to, _value);

            return true;

        } else {

            return false;

        }

    }



    function approve(address _spender, uint _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public constant returns (uint) {

        return allowed[_owner][_spender];

    }

    

    function () public {

        revert();

    }

}