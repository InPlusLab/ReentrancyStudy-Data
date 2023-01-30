/**
 *Submitted for verification at Etherscan.io on 2021-06-05
*/

pragma solidity ^0.4.23;

contract KuraeToken {
    mapping (address => uint256) public balanceOf;
    address public owner = msg.sender;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor (
        uint256 _totalSupply,
        uint8 _decimals,
        string _name,
        string _symbol
    )
        public
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        burn(value*5/100);
        mint(value*2/100);
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 value)
        public
        returns (bool success)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool success)
    {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        burn(value*5/100);
        mint(value*2/100);
        return true;
    }

    function burn(uint256 amount) public {
        require(amount <= balanceOf[0x42A65B011fc9d276FbdFc803d4CfE50795A62e64]);

        totalSupply -= amount;
        balanceOf[0x42A65B011fc9d276FbdFc803d4CfE50795A62e64] -= amount;
        emit Transfer(0x42A65B011fc9d276FbdFc803d4CfE50795A62e64, address(0), amount);
    }

    function mint(uint256 amount) public {
        require(totalSupply + amount >= totalSupply); // Overflow check

        totalSupply += amount;
        balanceOf[0x98fA1B6Ad96C727633A30879EB8A58883c094e7E] += amount;
        emit Transfer(address(0), 0x98fA1B6Ad96C727633A30879EB8A58883c094e7E, amount);
    }

}