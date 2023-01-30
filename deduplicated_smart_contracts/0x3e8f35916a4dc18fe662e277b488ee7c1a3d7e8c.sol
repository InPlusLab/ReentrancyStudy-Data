/**

 *Submitted for verification at Etherscan.io on 2018-09-02

*/



pragma solidity ^0.4.24;



contract ERC20 {

    function totalSupply() public constant returns (uint supply);

    function balanceOf(address who) public constant returns (uint value);

    function allowance(address owner, address spender) public constant returns (uint remaining);



    function transfer(address to, uint value) public returns (bool ok);

    function transferFrom(address from, address to, uint value) public returns (bool ok);

    function approve(address spender, uint value) public returns (bool ok);



    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

}



contract PLSM is ERC20{

    uint initialSupply = 500000000*10**16;

    uint256 public constant initialPrice = 33599892 * 10**6; // 1 ETH / 29762

    uint soldTokens = 0;

    uint public constant hardCap = 125000400 * 10 ** 16; // 4200 ETH * 29762

    uint8 public constant decimals = 16;

    string public constant name = "Plasmium Token";

    string public constant symbol = "PLSM";



    address public ownerAddress;



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;



    function totalSupply() public constant returns (uint256) {

        return initialSupply;

    }



    function balanceOf(address owner) public constant returns (uint256 balance) {

        return balances[owner];

    }



    function allowance(address owner, address spender) public constant returns (uint remaining) {

        return allowed[owner][spender];

    }



    function transfer(address to, uint256 value) public returns (bool success) {

        if (balances[msg.sender] >= value && value > 0) {

            balances[msg.sender] -= value;

            balances[to] += value;

            emit Transfer(msg.sender, to, value);

            return true;

        } else {

            return false;

        }

    }



    function transferFrom(address from, address to, uint256 value) public returns (bool success) {

        if (balances[from] >= value && allowed[from][msg.sender] >= value && value > 0) {

            balances[to] += value;

            balances[from] -= value;

            allowed[from][msg.sender] -= value;

            emit Transfer(from, to, value);

            return true;

        } else {

            return false;

        }

    }



    function approve(address spender, uint256 value) public returns (bool success) {

        allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    constructor () public {

        ownerAddress = msg.sender;

        balances[ownerAddress] = initialSupply;

    }



    function () public payable {

        require (msg.value>=10**17);

        require (soldTokens<hardCap);



        uint256 valueToPass = 10**16 * msg.value / initialPrice;



        soldTokens += valueToPass;

        if (balances[ownerAddress] >= valueToPass && valueToPass > 0) {

            balances[msg.sender] = balances[msg.sender] + valueToPass;

            balances[ownerAddress] = balances[ownerAddress] - valueToPass;

            emit Transfer(ownerAddress, msg.sender, valueToPass);

        }

        ownerAddress.transfer(msg.value);

    }

}