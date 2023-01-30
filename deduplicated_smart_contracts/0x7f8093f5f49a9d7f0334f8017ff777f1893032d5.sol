/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

pragma solidity 0.5.17;

contract ThankYouToken {
    string public name     = "Thank You Token";
    string public symbol   = "TYT";
    uint8  public decimals = 18;
    uint public totalSupply;

    address public constant vault = address(0x83D0D842e6DB3B020f384a2af11bD14787BEC8E7);

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Donate(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() external payable {
        donate();
    }

    function donate() public payable {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        (bool success,) = vault.call.value(msg.value)("");
        require(success);
        emit Donate(msg.sender, msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}