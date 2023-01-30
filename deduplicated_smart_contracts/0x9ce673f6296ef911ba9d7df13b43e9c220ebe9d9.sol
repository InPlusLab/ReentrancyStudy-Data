/**

 *Submitted for verification at Etherscan.io on 2018-11-15

*/



pragma solidity ^0.4.25;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) { 

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    require(c / a == b);

    return c;

  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); //Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    return c;

  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;

    return c;

  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);

    return c;

  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}

//interface

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

// contract

contract RicoDaily {

    using SafeMath for uint256;

    //Token credentials

    string public name = "Daley";

    string public symbol = "RECO";

    uint8 public decimals = 0; //This code assumes decimals is zero.  DO NOT CHANGE!

    uint256 public totalSupply = 200000000 * (uint256(10) ** decimals);

    uint256 ethDividendPerToken;

    uint256 public latestEthDividendPerToken = 0;

    uint256 public weiDistributed = 0;

    uint256 public remainder = 0;

    //Addresses

    address public beneficiary = 0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca;

    //Mapping

    mapping(address => uint256) public balanceOf;

    mapping(address => uint256) dividendBalanceOf;

    mapping(address => uint256) dividendCreditedTo;

    mapping(address => mapping (address => uint256)) public allowance;

    //Events

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() public {

        balanceOf[beneficiary] = totalSupply; //Initially assign all tokens to Reptar_IT.

        emit Transfer(address(0), msg.sender, totalSupply);

    }

    //Internal update, only can be called by this contract 

    function _revise(address account) internal {

        uint256 owed = ethDividendPerToken.sub(dividendCreditedTo[account]);

        dividendBalanceOf[account] = dividendBalanceOf[account].add(balanceOf[account].mul(owed));

        dividendCreditedTo[account] = ethDividendPerToken;

    }

    //Internal transfer, only can be called by this contract 

    function _transfer(address _from, address _to, uint256 _value) internal {

        require(_to != 0x0);

        require(_to != address(0));

        require(_value <= balanceOf[_from]);

        require(balanceOf[_to].add(_value) >= balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] = balanceOf[_from].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }

    //Transfer tokens

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(_value <= balanceOf[msg.sender]);

        _revise(msg.sender);  

        _revise(_to);

        _transfer(msg.sender, _to, _value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }

    //Transfer tokens from other address

    function transferFrom(address _from, address _to, uint256 _value) public payable returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);

        _revise(_from); 

        _revise(_to);

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        _transfer(_from, _to, _value);

        emit Transfer(_from, _to, _value);

        return true;

    }

    //token recieves ether coin

    function() public payable {

        uint256 recievedvalue = msg.value.add(remainder); //add previous remainder to incoming ether.

        ethDividendPerToken = ethDividendPerToken.add(recievedvalue.div(totalSupply));  // ignoring remainder

        remainder = recievedvalue.mod(totalSupply); // compute the new remainder

        weiDistributed = weiDistributed.add(recievedvalue); //tracks sum of ether distributed

        latestEthDividendPerToken = latestEthDividendPerToken.sub(latestEthDividendPerToken); // reset to zero

        latestEthDividendPerToken = ethDividendPerToken.add(recievedvalue.div(totalSupply));

    }

    //token holders can withdraw eth dividend if they have any

    function withdraw() public {

        _revise(msg.sender);

        uint256 amount = dividendBalanceOf[msg.sender];

        dividendBalanceOf[msg.sender] = 0;

        msg.sender.transfer(amount);

    }

    //Set allowance for other address & Allows `_spender` to spend no more than `_value` tokens on your behalf

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    //Set allowance for other address and notify

    //Allows `_spender` to spend no more than `_value` tokens on your behalf

    //Then ping the contract about it

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }

}