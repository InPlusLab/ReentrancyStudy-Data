/**
 *Submitted for verification at Etherscan.io on 2019-08-01
*/

pragma solidity ^0.4.0;

contract XPeerChain{
    //代币简介：Blockchain operating system that connects the world’s networks and facilitates the development of cross-chain applications.
    //官方网址：http://xpeer.org
    //开源社区：https://github.com/xpeerchain
    
    /* Public variables of the token */
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    bool public isStop;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 _supply, string _name, string _symbol, uint8 _decimals) public {
        /* if supply not given then generate 1 million of the smallest unit of the token */
        if (_supply == 0) _supply = 1000000;
	    totalSupply = _supply;
        /* Unless you add other functions these variables will never change */
        balanceOf[msg.sender] = _supply;
        name = _name;
        symbol = _symbol;
        /* If you want a divisible token then add the amount of decimals the base unit has  */
        decimals = _decimals;
        owner = msg.sender;
        isStop = false;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        /* if the sender doenst have enough balance then stop */
        require (balanceOf[msg.sender] > _value);
        require (balanceOf[_to] + _value > balanceOf[_to]);
        require (!isStop);

        /* Add and subtract new balances */
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        /* Notifiy anyone listening that this transfer took place */
        emit Transfer(msg.sender, _to, _value);
    }

    function stopContract(bool stop) public {
        require (msg.sender == owner);
        isStop = stop;
    }
}