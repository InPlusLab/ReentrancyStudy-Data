/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity 0.5.10;

contract KarlBenzContract {
    mapping (address => uint256) public balanceOf;

    string public name = "Karl Benz";
    string public symbol = "karl";
    uint8 public decimals = 18;
    address public genesisAddress = address(0x5b7d0dc6994211e4FF808fC873e7A4a8ED767aFF);
    uint256 public totalSupply = 63000000 * (uint256(10) ** decimals);

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