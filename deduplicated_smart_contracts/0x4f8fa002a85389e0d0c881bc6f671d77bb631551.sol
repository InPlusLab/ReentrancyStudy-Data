/**
 *Submitted for verification at Etherscan.io on 2020-02-24
*/

pragma solidity ^0.4.23;

contract DHC {
    mapping(address => uint256) private balances;

    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public totalSupply;
    address public owner;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        address _owner
    ) public {
        balances[_owner] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
        owner = _owner;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        if (_to != address(0)) {
            require(balances[msg.sender] >= _value);
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
    }

    /*With permission, destory token from an address and minus total amount.*/
    function burnFrom(address _who, uint256 _value) public returns (bool) {
        require(msg.sender == owner);
        assert(balances[_who] >= _value);
        totalSupply -= _value;
        balances[_who] -= _value;
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