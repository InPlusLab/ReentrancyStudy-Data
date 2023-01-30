/**

 *Submitted for verification at Etherscan.io on 2018-12-08

*/



pragma solidity ^0.4.16;



contract ERC20Interface {

    function totalSupply() 

        public 

        constant 

        returns (uint256);



    function balanceOf(

        address _address) 

        public 

        constant 

        returns (uint256 balance);



    function allowance(

        address _address, 

        address _to)

        public 

        constant 

        returns (uint256 remaining);



    function transfer(

        address _to, 

        uint256 _value) 

        public 

        returns (bool success);



    function approve(

        address _to, 

        uint256 _value) 

        public 

        returns (bool success);



    function transferFrom(

        address _from, 

        address _to, 

        uint256 _value) 

        public 

        returns (bool success);



    event Transfer(

        address indexed _from, 

        address indexed _to, 

        uint256 _value

    );



    event Approval(

        address indexed _from, 

        address indexed _to, 

        uint256 _value

    );

}



contract Owned {

    address owner;

    address newOwner;

    uint32 transferCount;    



    event TransferOwnership(

        address indexed _from, 

        address indexed _to

    );



    constructor() public {

        owner = msg.sender;

        transferCount = 0;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(

        address _newOwner) 

        public 

        onlyOwner 

    {

        newOwner = _newOwner;

    }



    function viewOwner()

        public

        view

        returns (address)

    {

        return owner;

    }



    function viewTransferCount()

        public

        view

        onlyOwner

        returns (uint32)

    {

        return transferCount;

    }



    function isTransferPending() 

        public

        view

        returns (bool) {

        require(

            msg.sender == owner || 

            msg.sender == newOwner);

        return newOwner != address(0);

    }



    function acceptOwnership()

         public 

    {

        require(msg.sender == newOwner);



        owner = newOwner;

        newOwner = address(0);

        transferCount++;



        emit TransferOwnership(

            owner, 

            newOwner

        );

    }

}







library SafeMath {

    function add(

        uint256 a, 

        uint256 b)

        internal 

        pure 

        returns(uint256 c) 

    {

        c = a + b;

        require(c >= a);

    }



    function sub(

        uint256 a, 

        uint256 b)

        internal 

        pure 

        returns(uint256 c) 

    {

        require(b <= a);

        c = a - b;

    }



    function mul(

        uint256 a, 

        uint256 b) 

        internal 

        pure 

        returns(uint256 c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }



    function div(

        uint256 a, 

        uint256 b) 

        internal 

        pure 

        returns(uint256 c) {

        require(b > 0);

        c = a / b;

    }

}







contract ApproveAndCallFallBack {

    function receiveApproval(

        address _from, 

        uint256 _value, 

        address token, 

        bytes data) 

        public;

}



contract Token is ERC20Interface, Owned {

    using SafeMath for uint256;



    string public symbol;

    string public name;

    uint8 public decimals;

    uint256 public totalSupply;



    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    mapping(address => uint256) incomes;

    mapping(address => uint256) expenses; 

    mapping(address => bool) frozenAccount;



    event FreezeAccount(

        address _address, 

        bool frozen

    );

    

    event Burn(

        address _address,

        uint256 _value

    );

    

    event MintToken(

        uint256 _value

    );



    constructor(

        uint256 _totalSupply,

        string _name,

        string _symbol,

        uint8 _decimals) 

        public 

    {

        symbol = _symbol;

        name = _name;

        decimals = _decimals;

        totalSupply = _totalSupply * 10**uint256(_decimals);

        balances[owner] = totalSupply;



        emit Transfer(address(0), owner, totalSupply);

    }



    function totalSupply()

        public

        constant

        returns (uint256)

    {

        return totalSupply;

    }



    function _transfer(

        address _from, 

        address _to, 

        uint256 _value) 

        internal 

        returns (bool success)

    {

        require (_to != 0x0);

        require (balances[_from] >= _value);

        require(!frozenAccount[_from]);

        require(!frozenAccount[_to]);



        balances[_from] = balances[_from].sub(_value);  

        balances[_to] = balances[_to].add(_value);   



        incomes[_to] = incomes[_to].add(_value);

        expenses[_from] = expenses[_from].add(_value);



        emit Transfer(_from, _to, _value);



        return true;

    }



    function transfer(

        address _to, 

        uint256 _value) 

        public 

        returns (bool success) 

    {

        return _transfer(msg.sender, _to, _value);

    }



    function approve(

        address _to, 

        uint256 _value) 

        public 

        returns (bool success) 

    {

        require (_to != 0x0);

        require(!frozenAccount[_to]);



        allowed[msg.sender][_to] = _value;



        emit Approval(msg.sender, _to, _value);



        return true;

    }



/*

    function batchTransfer(

        address[] _tos,

        uint256 _value)

        public

        returns (bool success)

    {



    }



*/



    function transferFrom(

        address _from, 

        address _to, 

        uint256 _value) 

        public 

        returns (bool success) 

    {

        require(allowed[_from][_to] >= _value);

        

        allowed[_from][_to] = allowed[_from][_to].sub(_value);

        return _transfer(_from, _to, _value);

    }



    function balanceOf(

        address _address) 

        public 

        constant 

        returns (uint256 remaining) 

    {

        require(_address != 0x0);

//        require(_address == msg.sender);



        return balances[_address];

    }



    function incomeOf(

        address _address) 

        public 

        constant 

        returns (uint256 income) 

    {

        require(_address != 0x0);



        return incomes[_address];

    }



    function expenseOf(

        address _address) 

        public 

        constant 

        returns (uint256 expense) 

    {

        require(_address != 0x0);



        return expenses[_address];

    }



    function allowance(

        address _from, 

        address _to) 

        public 

        constant 

        returns (uint256 remaining) 

    {

        require(_from != 0x0);

        require(_to != 0x0);

        require(_from == msg.sender || _to == msg.sender);



        return allowed[_from][_to];

    }





    function approveAndCall(

        address _to, 

        uint256 _value, 

        bytes _data) 

        public 

        returns (bool success) 

    {

        if (approve(_to, _value)) {

            ApproveAndCallFallBack(_to).receiveApproval(msg.sender, _value, this, _data);

            return true;

        }

        return false;

    }



    function () public payable {

        revert();

    }



    function transferBackToken(

        address _from, 

        uint256 _value) 

        public 

        onlyOwner 

        returns (bool success) 

    {

        return _transfer(_from, owner, _value);

    }



    function freezeAccount(

        address _address, 

        bool freeze) 

        public 

        onlyOwner 

        returns (bool success)

    {

        frozenAccount[_address] = freeze;



        emit FreezeAccount(_address, freeze);



        return true;

    }



    function isFrozenAccount(

        address _address) 

        public 

        onlyOwner

        constant 

        returns (bool frozen) 

    {

        require(_address != 0x0);



        return frozenAccount[_address];

    }



    function burn(

        uint256 _value)

        public

        returns (bool success)

    {

        require(balances[msg.sender] >= _value);



        balances[msg.sender] = balances[msg.sender].sub(_value);   

        totalSupply = totalSupply.sub(_value);



        emit Burn(msg.sender, _value);



        return true;  

    }



    function mintToken(

        uint256 _value)

        public

        onlyOwner

        returns (bool success)

    {

        balances[owner] = balances[owner].add(_value);

        totalSupply = totalSupply.add(_value);



        emit MintToken(_value);



        return true;        

    }

}