/**
 *Submitted for verification at Etherscan.io on 2020-03-09
*/

pragma solidity 0.4.15;

contract ERC20Interface {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approved(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

contract UBTFreeze {
    address constant public RECEIVER = 0x3c100e43cc0715B659d5e7F8C67a9aac7dD170C0;
    uint constant public DEADLINE = 1609509600; // Jan, 1st 2021, 2pm CET
    ERC20Interface constant UBT = ERC20Interface(0x8400D94A5cb0fa0D041a3788e395285d61c9ee5e);

    function transferAfterDeadline() returns(bool) {
        require(now > DEADLINE);
        require(UBT.transfer(RECEIVER, UBT.balanceOf(this)));
        return true;
    }
}