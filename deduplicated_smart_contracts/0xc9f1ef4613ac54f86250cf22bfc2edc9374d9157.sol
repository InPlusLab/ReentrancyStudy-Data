/**

 *Submitted for verification at Etherscan.io on 2018-12-25

*/



pragma solidity ^0.4.8;



/*

AvatarNetwork Copyright



https://avatarnetwork.io

*/



contract Owned {



    address owner;



    function Owned() {

        owner = msg.sender;

    }



    function changeOwner(address newOwner) onlyOwner {

        owner = newOwner;

    }



    modifier onlyOwner() {

        if (msg.sender==owner) _;

    }

}



contract Token is Owned {

    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract ERC20Token is Token {



    function transfer(address _to, uint256 _value) returns (bool success) {



        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } else { return false; }

    }



    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {



        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            Transfer(_from, _to, _value);

            return true;

        } else { return false; }

    }



    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);



        return true;

    }



    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract Victory is ERC20Token {



    bool public isTokenSale = false;

    uint256 public price;

    uint256 public limit;



    address walletOut = 0x520c05695c55B6619AeCF8eF8b7Be6c8B7d7686e;



    function getWalletOut() constant returns (address _to) {

        return walletOut;

    }



    function () external payable  {

        if (isTokenSale == false) {

            throw;

        }



        uint256 tokenAmount = (msg.value  * 1000000000000000000) / price;



        if (balances[owner] >= tokenAmount && balances[msg.sender] + tokenAmount > balances[msg.sender]) {

            if (balances[owner] - tokenAmount < limit) {

                throw;

            }

            balances[owner] -= tokenAmount;

            balances[msg.sender] += tokenAmount;

            Transfer(owner, msg.sender, tokenAmount);

        } else {

            throw;

        }

    }



    function stopSale() onlyOwner {

        isTokenSale = false;

    }



    function startSale() onlyOwner {

        isTokenSale = true;

    }



    function setPrice(uint256 newPrice) onlyOwner {

        price = newPrice;

    }



    function setLimit(uint256 newLimit) onlyOwner {

        limit = newLimit;

    }



    function setWallet(address _to) onlyOwner {

        walletOut = _to;

    }



    function sendFund() onlyOwner {

        walletOut.send(this.balance);

    }



    string public name;

    uint8 public decimals;

    string public symbol;

    string public version = '1.0';



    function Victory() {

        totalSupply = 1000000000 * 1000000000000000000;

        balances[msg.sender] = totalSupply;

        name = 'Victory';

        decimals = 18;

        symbol = 'VIC';

        price = 714285714285714;

        limit = 0;

    }





    /* ����ҧѧӧݧ�֧� �ߧ� ���֧� ���ܧ֧ߧ�� */

    function add(uint256 _value) onlyOwner returns (bool success)

    {

        if (balances[msg.sender] + _value <= balances[msg.sender]) {

            return false;

        }

        totalSupply += _value;

        balances[msg.sender] += _value;



        return true;

    }



}