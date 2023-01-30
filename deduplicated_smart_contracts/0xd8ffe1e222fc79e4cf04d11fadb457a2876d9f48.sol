/**
 *Submitted for verification at Etherscan.io on 2019-09-07
*/

pragma solidity >0.4.2;

// 'Salemcash' token contract
//
// Deployed to : 0xd9aF74B27919D8b96C2D0FA3e26B20463dbfa497
// Symbol      : SCS
// Name        : Salemcash Token
// Total supply: 20000000
// Decimals    : 18
//
// Welcome.
//
// (c) by Pastor Ombura / JSCI 2019. Copyright (c) 2011 The LevelDB Authors.
// ----------------------------------------------------------------------------

pragma solidity >0.4.2;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}



library ExtendedMath {


    //return the smaller of the two inputs (a or b)
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {

        if(a > b) return b;

        return a;

    }
}


pragma solidity >0.4.2;

contract Salemcash {

    mapping(address => uint) private _balances;

    constructor() public {
        _balances[msg.sender] = 20000000000000000000000000;
    }

    function getBalance(address account) public view returns (uint) {
        return _balances[account];
    }

    function transfer(address to, uint amount) public {
        require(_balances[msg.sender] >= amount);

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
    }
}

pragma solidity >0.4.2;

contract ERC20Interface {
    function totalSupply() public returns (uint);
    function balanceOf(address tokenOwner) public returns (uint balance);
    function allowance(address tokenOwner, address spender) public returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

pragma solidity >0.4.2;

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

pragma solidity >0.4.2;

/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract ERC20Pausable {
    function transfer(address to, uint256 value) public returns (bool) {
        return transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        return transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        return approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        return increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        return decreaseAllowance(spender, subtractedValue);
    }
}