/**

 *Submitted for verification at Etherscan.io on 2019-06-12

*/



pragma solidity ^0.4.13;



contract ERC20 {

  function balanceOf(address who) constant returns (uint);

  function allowance(address owner, address spender) constant returns (uint);



  function transfer(address to, uint value) returns (bool ok);

  function transferFrom(address from, address to, uint value) returns (bool ok);

  function approve(address spender, uint value) returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);

  event Approval(address indexed owner, address indexed spender, uint value);

}



//Safe math

contract SafeMath {

  function safeMul(uint a, uint b) internal returns (uint) {

    uint c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function safeDiv(uint a, uint b) internal returns (uint) {

    assert(b > 0);

    uint c = a / b;

    assert(a == b * c + a % b);

    return c;

  }



  function safeSub(uint a, uint b) internal returns (uint) {

    assert(b <= a);

    return a - b;

  }



  function safeAdd(uint a, uint b) internal returns (uint) {

    uint c = a + b;

    assert(c>=a && c>=b);

    return c;

  }



  function max64(uint64 a, uint64 b) internal constant returns (uint64) {

    return a >= b ? a : b;

  }



  function min64(uint64 a, uint64 b) internal constant returns (uint64) {

    return a < b ? a : b;

  }



  function max256(uint a, uint b) internal constant returns (uint) {

    return a >= b ? a : b;

  }



  function min256(uint a, uint b) internal constant returns (uint) {

    return a < b ? a : b;

  }



}



contract StandardToken is ERC20, SafeMath {



  /* Actual balances of token holders */

  mapping(address => uint) balances;



  /* approve() allowances */

  mapping (address => mapping (address => uint)) allowed;



  function transfer(address _to, uint _value) returns (bool success) {

    balances[msg.sender] = safeSub(balances[msg.sender], _value);

    balances[_to] = safeAdd(balances[_to], _value);

    Transfer(msg.sender, _to, _value);

    return true;

  }



  function transferFrom(address _from, address _to, uint _value) returns (bool success) {

    uint _allowance = allowed[_from][msg.sender];



    balances[_to] = safeAdd(balances[_to], _value);

    balances[_from] = safeSub(balances[_from], _value);

    allowed[_from][msg.sender] = safeSub(_allowance, _value);

    Transfer(_from, _to, _value);

    return true;

  }



  function balanceOf(address _address) constant returns (uint balance) {

    return balances[_address];

  }



  function approve(address _spender, uint _value) returns (bool success) {



    // To change the approve amount you first have to reduce the addresses`

    //  allowance to zero by calling `approve(_spender, 0)` if it is not

    //  already 0 to mitigate the race condition described here:

    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));



    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

    return true;

  }



  function allowance(address _owner, address _spender) constant returns (uint remaining) {

    return allowed[_owner][_spender];

  }



}



contract SOTOToken is StandardToken {



    string public name = "SOTO Token";

    string public symbol = "SOTO";

    uint8 public decimals = 18;

    uint public totalSupply = 1000000000 * (10 ** uint(decimals));//Total supply 1000,000,000

    uint public poolPreICO = 100000000 * (10 ** uint(decimals));

    uint public poolICO = 400000000 * (10 ** uint(decimals));

    uint public poolEcosystem = 380000000 * (10 ** uint(decimals));

    uint public poolManagement = 120000000 * (10 ** uint(decimals));

    

    /*

    Staking



    Month	% Dividend

    First	1%

    Second	3%

    Third	6%

    Forth	10%

    Fifth	15%

    Sixth	21%

    Seventh	28%

    Eigth	36%

    Ninth	45%

    Tenth	55%

    Eleventh 66%

    Twelvth	78%

    */

    uint staking_1 = 1;

    uint staking_2 = 3;

    uint staking_3 = 6;

    uint staking_4 = 10;

    uint staking_5 = 15;

    uint staking_6 = 21;

    uint staking_7 = 28;

    uint staking_8 = 36;

    uint staking_9 = 45;

    uint staking_10 = 55;

    uint staking_11 = 66;

    uint staking_12 = 78;

    

    //Staking data

    mapping (address => uint) public Staking;

    

	//Technical variables to store states

    bool public TransferAllowed = true;

    bool public StakingActivated = true;



    //Event logs

    event Burn(address indexed from, uint tokens);// This notifies clients about the amount burnt

    

    address public owner = 0x0;//Admin actions

 

function SOTOToken(address _owner) {

    

      owner = _owner;

      balances[owner] = 0;

    

      //Add total supply to the owner address

      balances[owner] = safeAdd(balances[owner], totalSupply);

      Transfer(0, this, totalSupply);

      Transfer(this, owner, totalSupply);

    }

    

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    // Decrease user balance

    function decreaseTokens(address _target, uint _amount) external returns (bool) {

        require(msg.sender == owner);

        require(_target != owner);

        require(_amount > 0);//Number of tokens must be greater than 0

        uint amount=_amount * (10 ** uint(decimals));

        balances[_target] = safeSub(balances[_target], amount);

        Transfer(_target, 0, amount);

        Burn(_target, amount);

        return true;

    }

    

    // Stake tokens

    function stake() external returns(bool) {

        require(StakingActivated);

        require(msg.sender != owner);

        require(balances[msg.sender] > 0);

        require(Staking[msg.sender] == 0);



        Staking[msg.sender]=now;

        return true;

    }



    // Unstake tokens

    function unstake() external returns(bool) {

        require(msg.sender != owner);

        require(balances[msg.sender] > 0);

        require(Staking[msg.sender] > 0);



        uint timePassed = now - Staking[msg.sender];

        uint monthsPassed = safeDiv(timePassed,2592000);//30 days in month * 86400 seconds in day



        if(monthsPassed > 0){

            

        uint stakingPercent = staking_1;



        if(monthsPassed==1){stakingPercent = staking_1;}

        if(monthsPassed==2){stakingPercent = staking_2;}

        if(monthsPassed==3){stakingPercent = staking_3;}

        if(monthsPassed==4){stakingPercent = staking_4;}

        if(monthsPassed==5){stakingPercent = staking_5;}

        if(monthsPassed==6){stakingPercent = staking_6;}

        if(monthsPassed==7){stakingPercent = staking_7;}

        if(monthsPassed==8){stakingPercent = staking_8;}

        if(monthsPassed==9){stakingPercent = staking_9;}

        if(monthsPassed==10){stakingPercent = staking_10;}

        if(monthsPassed==11){stakingPercent = staking_11;}

        if(monthsPassed>=12){stakingPercent = staking_12;}



        uint stakingMul = safeMul(balances[msg.sender], stakingPercent);

        uint stakingTotal = safeDiv(stakingMul, 100);



        uint tokensToAdd=stakingTotal * (10 ** uint(decimals));



        balances[msg.sender]=safeAdd(balances[msg.sender], tokensToAdd);

        Transfer(0, this, tokensToAdd);

        Transfer(this, msg.sender, tokensToAdd);

        }



        Staking[msg.sender]=0;

        return true;

    }

    

    function transfer(address _to, uint _value) returns (bool success) {



        require(Staking[msg.sender]==0);

        

        //Forbid token transfers

        if(!TransferAllowed){

            return false;

        }

        

    return super.transfer(_to, _value);

    }



    function transferFrom(address _from, address _to, uint _value) returns (bool success) {



        require(Staking[msg.sender]==0);

        

        //Forbid token transfers

        if(!TransferAllowed){

            return false;

        }

        

        return super.transferFrom(_from, _to, _value);

    }



    //Change owner

    function changeOwner(address _to) external onlyOwner() {

        balances[_to] = balances[owner];

        balances[owner] = 0;

        owner = _to;

    }

     

    //Allow or prohibit token transfers

    function setTransfer(bool _TransferAllowed) external onlyOwner {

        TransferAllowed = _TransferAllowed;

    }



    function setStaking(bool _StakingActivated) external onlyOwner {

        StakingActivated = _StakingActivated;

    }



    function setStakingPercent(uint _staking_1, uint _staking_2, uint _staking_3, uint _staking_4, uint _staking_5, uint _staking_6, uint _staking_7, uint _staking_8, uint _staking_9, uint _staking_10, uint _staking_11, uint _staking_12) external onlyOwner {

        staking_1 = _staking_1;

        staking_2 = _staking_2;

        staking_3 = _staking_3;

        staking_4 = _staking_4;

        staking_5 = _staking_5;

        staking_6 = _staking_6;

        staking_7 = _staking_7;

        staking_8 = _staking_8;

        staking_9 = _staking_9;

        staking_10 = _staking_10;

        staking_11 = _staking_11;

        staking_12 = _staking_12;

    }

    

}