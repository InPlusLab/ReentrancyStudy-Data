/**

 *Submitted for verification at Etherscan.io on 2018-10-23

*/



pragma solidity ^0.4.10;





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





/*  ERC 20 token */

contract StandardToken is Token {



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











contract KOISafe {

  mapping (address => uint256) allocations;

  uint256 public unlockDate;

  address public KOI;

  uint256 public constant exponent = 10**18;



  function KOISafe(address _KOI) {

    KOI = _KOI;

    unlockDate = now + 0 days;

        allocations[0x0aa8AFdc36571f9a37F3b9FEf0dfcACA66eA86D6] = 88888888888;

  }



  function unlock() external {

    if(now < unlockDate) throw;

    uint256 entitled = allocations[msg.sender];

    allocations[msg.sender] = 0;

    if(!StandardToken(KOI).transfer(msg.sender, entitled * exponent)) throw;

  }



}





contract SafeMath {



    /* function assert(bool assertion) internal { */

    /*   if (!assertion) { */

    /*     throw; */

    /*   } */

    /* }      // assert no longer needed once solidity is on 0.4.10 */



    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {

      uint256 z = x + y;

      assert((z >= x) && (z >= y));

      return z;

    }



    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {

      assert(x >= y);

      uint256 z = x - y;

      return z;

    }



    function safeMult(uint256 x, uint256 y) internal returns(uint256) {

      uint256 z = x * y;

      assert((x == 0)||(z/x == y));

      return z;

    }



}













contract KOIToken is StandardToken, SafeMath {



    // metadata

    string public constant name = "KOI TOKEN";

    string public constant symbol = "KOI";

    uint256 public constant decimals = 18;

    string public version = "1.0";



    // contracts

    address public ethFundDeposit = 0x0aa8AFdc36571f9a37F3b9FEf0dfcACA66eA86D6;      // deposit address for ETH for koi International

    address public koiFundDeposit = 0x0aa8AFdc36571f9a37F3b9FEf0dfcACA66eA86D6;      // deposit address for koi International use and KOI User Fund



    // crowdsale parameters

    bool public isFinalized;              // switched to true in operational state

    uint256 public fundingStartBlock;

    uint256 public fundingEndBlock;

    uint256 public constant koiFund = 500 * (10**6) * 10**decimals;   // 500m koi reserved for koi Intl use

    uint256 public constant tokenExchangeRate = 888888; // 888888 KOI tokens per 1 ETH

    uint256 public constant tokenCreationCap =  100000 * (10**6) * 10**decimals;

    uint256 public constant tokenCreationMin =  675 * (10**6) * 10**decimals;





    // events

    event LogRefund(address indexed _to, uint256 _value);

    event CreateKOI(address indexed _to, uint256 _value);



    // constructor

    function KOIToken(

        address _ethFundDeposit,

        address _koiFundDeposit,

        uint256 _fundingStartBlock,

        uint256 _fundingEndBlock)

    {

      isFinalized = false;                   //controls pre through crowdsale state

      ethFundDeposit = _ethFundDeposit;

      koiFundDeposit = _koiFundDeposit;

      fundingStartBlock = _fundingStartBlock;

      fundingEndBlock = _fundingEndBlock;

      totalSupply = tokenCreationCap;

      balances[koiFundDeposit] = koiFund;    // 

      CreateKOI(koiFundDeposit, koiFund);  // 

    }



    /// @dev Accepts ether and creates new KOI tokens.

    function createTokens() payable external {

      if (isFinalized) throw;

      if (block.number < fundingStartBlock) throw;

      if (block.number > fundingEndBlock) throw;

      if (msg.value == 0) throw;



      uint256 tokens = safeMult(msg.value, tokenExchangeRate); // check that we're not over totals

      uint256 checkedSupply = safeAdd(totalSupply, tokens);



      // return money if something goes wrong

      if (tokenCreationCap < checkedSupply) throw;  // odd fractions won't be found



      totalSupply = checkedSupply;

      balances[msg.sender] += tokens;  // safeAdd not needed; bad semantics to use here

      CreateKOI(msg.sender, tokens);  // logs token creation

    }



    /// @dev Ends the funding period and sends the ETH home

    function finalize() external {

      if (isFinalized) throw;

      if (msg.sender != ethFundDeposit) throw; // locks finalize to the ultimate ETH owner

      if(totalSupply < tokenCreationMin) throw;      // have to sell minimum to move to operational

      if(block.number <= fundingEndBlock && totalSupply != tokenCreationCap) throw;

      // move to operational

      isFinalized = true;

      if(!ethFundDeposit.send(this.balance)) throw;  // 

    }



    /// @dev Allows contributors to recover their ether in the case of a failed funding campaign.

    function refund() external {

      if(isFinalized) throw;                       // prevents refund if operational

      if (block.number <= fundingEndBlock) throw; // prevents refund until sale period is over

      if(totalSupply >= tokenCreationMin) throw;  // no refunds if we sold enough

      if(msg.sender == koiFundDeposit) throw;    // 

      uint256 koiVal = balances[msg.sender];

      if (koiVal == 0) throw;

      balances[msg.sender] = 0;

      totalSupply = safeSubtract(totalSupply, koiVal); // extra safe

      uint256 ethVal = koiVal / tokenExchangeRate;     // should be safe; previous throws covers edges

      LogRefund(msg.sender, ethVal);               // log it 

      if (!msg.sender.send(ethVal)) throw;       // if you're using a contract; make sure it works with .send gas limits

    }



}