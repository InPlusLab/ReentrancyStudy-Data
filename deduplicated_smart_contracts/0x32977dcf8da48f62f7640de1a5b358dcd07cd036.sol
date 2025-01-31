/**
 *Submitted for verification at Etherscan.io on 2019-12-05
*/

pragma solidity 0.5.13;

contract StandardContract {
    mapping (address => uint256) public balanceOf;

    string public name = "Cloud Intelligence ������";
    string public symbol = "CNG";
    uint8 public decimals = 18;
    address public genesisAddress = address(0xaC08A8eF16D1C875f2A829368A0FdEBc4e9fA7Ef);
    uint256 public totalSupply = 100000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        balanceOf[genesisAddress] = totalSupply;
        emit Transfer(address(0), genesisAddress, totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
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
        return true;
    }
}