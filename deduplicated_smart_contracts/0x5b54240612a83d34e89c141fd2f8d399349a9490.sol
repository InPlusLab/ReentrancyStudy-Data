/**

 *Submitted for verification at Etherscan.io on 2019-04-11

*/



pragma solidity ^0.4.24; 



contract ERC223 {

  uint public totalSupply;

  function balanceOf(address who) constant returns (uint);



  function name() constant returns (string _name);

  function symbol() constant returns (string _symbol);

  function decimals() constant returns (uint8 _decimals);

  function totalSupply() constant returns (uint256 _supply);



  function transfer(address to, uint value) returns (bool ok);

  function transfer(address to, uint value, bytes data) returns (bool ok);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);

}



contract ContractReceiver {

  function tokenFallback(address _from, uint _value, bytes _data);

}



contract ERC223Token is ERC223 {

  using SafeMath for uint;



  mapping(address => uint) balances;



  string public name;

  string public symbol;

  uint8 public decimals;

  uint256 public totalSupply;





  // Function to access name of token .

  function name() constant returns (string _name) {

      return name;

  }

  // Function to access symbol of token .

  function symbol() constant returns (string _symbol) {

      return symbol;

  }

  // Function to access decimals of token .

  function decimals() constant returns (uint8 _decimals) {

      return decimals;

  }

  // Function to access total supply of tokens .

  function totalSupply() constant returns (uint256 _totalSupply) {

      return totalSupply;

  }



  // Function that is called when a user or another contract wants to transfer funds .

  function transfer(address _to, uint _value, bytes _data) returns (bool success) {

    if(isContract(_to)) {

        return transferToContract(_to, _value, _data);

    }

    else {

        return transferToAddress(_to, _value, _data);

    }

}



  // Standard function transfer similar to ERC20 transfer with no _data .

  // Added due to backwards compatibility reasons .

  function transfer(address _to, uint _value) returns (bool success) {



    //standard function transfer similar to ERC20 transfer with no _data

    //added due to backwards compatibility reasons

    bytes memory empty;

    if(isContract(_to)) {

        return transferToContract(_to, _value, empty);

    }

    else {

        return transferToAddress(_to, _value, empty);

    }

}



//assemble the given address bytecode. If bytecode exists then the _addr is a contract.

  function isContract(address _addr) private returns (bool is_contract) {

      uint length;

      assembly {

            //retrieve the size of the code on target address, this needs assembly

            length := extcodesize(_addr)

        }

        if(length>0) {

            return true;

        }

        else {

            return false;

        }

    }



  //function that is called when transaction target is an address

  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {

    if (balanceOf(msg.sender) < _value) revert();

    balances[msg.sender] = balanceOf(msg.sender).sub(_value);

    balances[_to] = balanceOf(_to).add(_value);

    Transfer(msg.sender, _to, _value);

    ERC223Transfer(msg.sender, _to, _value, _data);

    return true;

  }



  //function that is called when transaction target is a contract

  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {

    if (balanceOf(msg.sender) < _value) revert();

    balances[msg.sender] = balanceOf(msg.sender).sub(_value);

    balances[_to] = balanceOf(_to).add(_value);

    ContractReceiver reciever = ContractReceiver(_to);

    reciever.tokenFallback(msg.sender, _value, _data);

    Transfer(msg.sender, _to, _value);

    ERC223Transfer(msg.sender, _to, _value, _data);

    return true;

  }





  function balanceOf(address _owner) constant returns (uint balance) {

    return balances[_owner];

  }

}







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}









  



// change contract name to your contract's name

// i.e. "contract Bitcoin is ERC223Token"

contract BitUnits is ERC223Token {

  using SafeMath for uint256;



  // for example, "Bitcoin"

  string public name = "BitUnits";

  // for example, "BTC"

  string public symbol = "UNITX";

  // set token's precision

  // pick any number from 0 to 18

  // for example, 4 decimal points means that

  // smallest token using will be 0.0001 TKN

  uint public decimals = 8;

  // total supply of the token

  // for example, for Bitcoin it would be 21000000

  uint public totalSupply = 10000000 * (10**decimals);



  // Treasure is where ICO funds (ETH/ETC) will be forwarded

  // replace this address with your wallet address!

  // it is recommended that you create a paper wallet for this purpose

  address private treasury = 0xeb3C95a5CEB6Ae90f47380694F1922dFA1aed3C4;

  

  // ICO price. You will need to do a little bit of math to figure it out

  // given 4 decimals, this setting means "1 ETC = 50,000 TKN"

  uint256 private priceDiv = 2000000000;

  

  event Purchase(address indexed purchaser, uint256 amount);



  constructor() public {

    // This is how many tokens you want to allocate to yourself

    balances[msg.sender] = 10000000 * (10**decimals);

    // This is how many tokens you want to allocate for ICO

    balances[0x0] = 0 * (10**decimals);

  }



  function () public payable {

    bytes memory empty;

    if (msg.value == 0) { revert(); }

    uint256 purchasedAmount = msg.value.div(priceDiv);

    if (purchasedAmount == 0) { revert(); } // not enough ETC sent

    if (purchasedAmount > balances[0x0]) { revert(); } // too much ETC sent



    treasury.transfer(msg.value);

    balances[0x0] = balances[0x0].sub(purchasedAmount);

    balances[msg.sender] = balances[msg.sender].add(purchasedAmount);



    emit Transfer(0x0, msg.sender, purchasedAmount);

    emit ERC223Transfer(0x0, msg.sender, purchasedAmount, empty);

    emit Purchase(msg.sender, purchasedAmount);

  }

}