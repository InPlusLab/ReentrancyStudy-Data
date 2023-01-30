/**
 *Submitted for verification at Etherscan.io on 2019-10-12
*/

pragma solidity 0.5.11;

contract Token {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
}

contract LockTokenContract {
    // kankan
    address public Address = address(0x5b7F0342fC6Ee4036145dabf7c72b484B13E0785);
    address public HubTokenAddress  = address(0x6E3fd7E78aC97A2692fA87Ad28E2365e505b675e);
    uint256 public releaseTime = 1602432000; // 2020-10-12 00:00:00

    constructor() public {
    }

    function () payable external {
        require(msg.sender == Address);
        require(msg.value == 0);
        require(now > releaseTime);

        Token token = Token(HubTokenAddress);
        uint256 balance = token.balanceOf(address(this));

        require(token.transfer(msg.sender, balance));
    }
}