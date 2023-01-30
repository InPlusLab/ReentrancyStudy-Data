/**

 *Submitted for verification at Etherscan.io on 2019-03-13

*/



pragma solidity 0.4.24;



contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



}



contract RegularToken is Token {



    function transfer(address _to, uint _value) returns (bool) {

        //Default assumes totalSupply can't be over max (2^256 - 1).

        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } else { return false; }

    }



    function transferFrom(address _from, address _to, uint _value) returns (bool) {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {

            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            Transfer(_from, _to, _value);

            return true;

        } else { return false; }

    }



    function balanceOf(address _owner) constant returns (uint) {

        return balances[_owner];

    }



    function approve(address _spender, uint _value) returns (bool) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) constant returns (uint) {

        return allowed[_owner][_spender];

    }



    mapping (address => uint) balances;

    mapping (address => mapping (address => uint)) allowed;

    uint public totalSupply;

}



contract UnboundedRegularToken is RegularToken {

        

     function transfer(address _to, uint256 _value) returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } else {

            return false;

        }

    }

 

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {

            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            Transfer(_from, _to, _value);

            return true;

        } else {

            return false;

        }

    }

 

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }

 

   

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    

}



contract ACCTToken is UnboundedRegularToken {

    

    // Asset Circulation Cash  Token

    

      // contracts

    address public ethFundDeposit;  



    uint public totalSupply = 5*10**26;

    uint8 constant public decimals = 18;

    string constant public name = "ACCTToken";

    string constant public symbol = "ACCT";

      uint256 public currentSupply; 

 

        // constructor

    function ACCTToken(

        address _ethFundDeposit,

        uint256 _currentSupply)

    {

        ethFundDeposit = _ethFundDeposit;

        

        currentSupply = formatDecimals(_currentSupply);

        totalSupply = formatDecimals(10000000000);

        balances[msg.sender] = totalSupply;

        if(currentSupply > totalSupply) throw;

      

    }

    

      function formatDecimals(uint256 _value) internal returns (uint256 ) {

        return _value * 10 ** decimals;

    }

 

    

}