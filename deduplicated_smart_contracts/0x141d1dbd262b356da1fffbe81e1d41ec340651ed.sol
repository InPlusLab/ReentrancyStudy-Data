/**

 *Submitted for verification at Etherscan.io on 2019-01-29

*/



pragma solidity ^0.4.25;



//-------------------------------------------------------------------------------------------------------

//  ERC20 Contract :  Cryptocurrency VIZCOIN Blockchain Technology,-

//--------------------------------------------------------------------------------------------------------



library SafeMath {

    function Mul(uint256 a, uint256 b) internal constant returns (uint256) {

        uint256 c = a * b;

        assert(a == 0 ||c / a == b);

        return c;

    }

    

    function Div(uint256 a, uint256 b) internal constant returns (uint256) {

        assert(b > 0);

        uint256 c = a / b;

        assert(a == b * c + a % b);

        return c;

    }

    

    function Sub(uint256 a, uint256 b) internal constant returns (uint256) {

        assert(b <= a);

        return a - b;

    }

    

    function add(uint256 a, uint256 b) internal constant returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



contract VIZCOIN {

    string public constant name = "VIZCOIN";

    string public constant symbol = "VIZ";

    uint8 public constant decimals = 18;

    uint public _totalSupply = 990000000;

    uint256 public RATE = 1;

    bool public isminting = false;

    

    using SafeMath for uint256;

    address public owner;



    modifier onlyOwner() {

        if (msg.sender != owner){

            throw;

        }

         _;

    }    



    mapping(address => uint256) balances;

    mapping(address => mapping(address=>uint256)) allowed;

    

    function () payable{

        createTokens();

    }   

        

    constructor() public {

        owner = 0x56aac1C9aB4D1C77f8046576D35c7D6Ee2561ADA;

        balances[(owner)] = _totalSupply;

    }    

        

    function burnToken(uint256 _value) onlyOwner {

        require(balances[msg.sender] >= _value && _value > 0 );

        _totalSupply = _totalSupply.Sub(_value);

    }   

    

    function createTokens() payable {

        if(isminting == true){

            require(msg.value > 0);

            uint256 tokens = msg.value.Div(990000000000000).Mul(RATE);

            balances[msg.sender] = balances[msg.sender].add(tokens);

            _totalSupply = _totalSupply.add(tokens);

            owner.transfer(msg.value);

        }

        else{

            throw;

        }

    }

    

    function endCrowdsale() onlyOwner {

        isminting = false;

    }

    

    function changeCrowdsaleRate(uint256 _value) onlyOwner {

        RATE = _value;

    }

    

    function totalSupply() constant returns(uint256){

        return _totalSupply;

    }

    

    function balanceof(address _owner) constant returns(uint256){

        return balances[_owner];

    }

    

    function transfer(address _to, uint256 _value)returns(bool) {

        require(balances[msg.sender] >= _value && _value > 0 );

        balances[msg.sender] = balances[msg.sender].Sub(_value);

        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;

    }

    

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        require(allowed[_from][msg.sender] >= _value && balances[_from] >= _value && _value > 0);

        balances[_from] = balances[_from].Sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].Sub(_value);

        Transfer(_from, _to, _value);

        return true;

    }

    

    function approve(address _spender, uint256 _value) returns(bool success){

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }

    

     function allowance(address _owner, address _spender) constant returns (uint256){

         return allowed[_owner][_spender];

    }

    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _Owner, address indexed _spender, uint256 _value);

}