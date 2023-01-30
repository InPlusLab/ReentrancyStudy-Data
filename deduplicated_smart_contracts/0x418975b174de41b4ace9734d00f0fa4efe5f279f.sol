/**
 *Submitted for verification at Etherscan.io on 2020-02-24
*/

pragma solidity ^0.5.1;

contract Owned
{
    address payable internal _owner;

    constructor() public
    {
        _owner = msg.sender;
    }

    modifier onlyOwner 
    {
        require(msg.sender == _owner, "Only contract owner can do this.");
        _;
    }   

    function () external payable 
    {
        require(false, "eth transfer is disabled."); // throw
    }
}

contract Mortal is Owned {
    function die() public onlyOwner
    {
        selfdestruct(_owner);
    }
}

contract Erc20
{
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
}

contract Erc20TransferContract is Mortal
{
    address private _erc20;

    event Erc20Transfer(address indexed from, address to, uint256 value, string indexed ccid);

    constructor(address erc20) public
    {
        _erc20 = erc20;
    }
    
    function getErc20() public view returns (address erc20)
    {
        erc20 = _erc20;
    }

    function transfer(address to, uint256 value, string memory ccid) public returns (bool success)
    {
        require(bytes(ccid).length == 70, "Invalid creditcoin id length");
        Erc20 erc20 = Erc20(_erc20);
        success = erc20.transferFrom(msg.sender, to, value);
        emit Erc20Transfer(msg.sender, to, value, ccid);
    }
}