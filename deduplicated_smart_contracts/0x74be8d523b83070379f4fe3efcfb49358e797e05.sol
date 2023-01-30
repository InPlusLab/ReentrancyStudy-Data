/**

 *Submitted for verification at Etherscan.io on 2018-10-30

*/



pragma solidity ^0.4.25;



library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}





library BytesLib {

  function toAddress(bytes _bytes, uint _start) internal pure returns (address) {

    require(_bytes.length >= (_start + 20));

    address tempAddress;



    assembly {

      tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)

    }



    return tempAddress;

  }



  function toUint(bytes _bytes, uint _start) internal pure returns (uint256) {

    require(_bytes.length >= (_start + 32));

    uint256 tempUint;



    assembly {

      tempUint := mload(add(add(_bytes, 0x20), _start))

    }



    return tempUint;

  }



  function slice(bytes _bytes, uint _start, uint _length) internal  pure returns (bytes) {

    require(_bytes.length >= (_start + _length));

    bytes memory tempBytes;



    assembly {

      switch iszero(_length)

        case 0 {

          // Get a location of some free memory and store it in tempBytes as

          // Solidity does for memory variables.

          tempBytes := mload(0x40)



          // The first word of the slice result is potentially a partial

          // word read from the original array. To read it, we calculate

          // the length of that partial word and start copying that many

          // bytes into the array. The first word we copy will start with

          // data we don't care about, but the last `lengthmod` bytes will

          // land at the beginning of the contents of the new array. When

          // we're done copying, we overwrite the full first word with

          // the actual length of the slice.

          let lengthmod := and(_length, 31)



          // The multiplication in the next line is necessary

          // because when slicing multiples of 32 bytes (lengthmod == 0)

          // the following copy loop was copying the origin's length

          // and then ending prematurely not copying everything it should.

          let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))

          let end := add(mc, _length)



          for {

            // The multiplication in the next line has the same exact purpose

            // as the one above.

            let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)

          } lt(mc, end) {

            mc := add(mc, 0x20)

            cc := add(cc, 0x20)

          } {

            mstore(mc, mload(cc))

          }



          mstore(tempBytes, _length)



          //update free-memory pointer

          //allocating the array padded to 32 bytes like the compiler does now

          mstore(0x40, and(add(mc, 31), not(31)))

        }

        //if we want a zero-length slice let's just return a zero-length array

        default {

          tempBytes := mload(0x40)

          mstore(0x40, add(tempBytes, 0x20))

        }

    }

    return tempBytes;

  }



}



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



contract ERC20 {

  function totalSupply() public view returns (uint256);



  function balanceOf(address _who) public view returns (uint256);



  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transfer(address _to, uint256 _value) public returns (bool);



  function approve(address _spender, uint256 _value)

    public returns (bool);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



contract TokenAirdrop is ContractReceiver {

  using SafeMath for uint256;

  using BytesLib for bytes;



  // let users withdraw their tokens

  // person => token => balance

  mapping(address => mapping(address => uint256)) private balances;

  address private etherAddress = 0x0;



  event Airdrop(

    address from,

    address to,

    bytes message,

    address token,

    uint amount,

    uint time

  );

  event Claim(

    address claimer,

    address token,

    uint amount,

    uint time

  );





  // handle incoming ERC223 tokens

  function tokenFallback(address from, uint value, bytes data) public {

    // payload structure

    // [address 20 bytes][utf-8 encoded message]

    require(data.length > 20);

    address beneficiary = data.toAddress(0);

    bytes memory message = data.slice(20, data.length - 20);

    balances[beneficiary][msg.sender] = balances[beneficiary][msg.sender].add(value);

    emit Airdrop(from, beneficiary, message, msg.sender, value, now);

  }



  // handle ether

  function giftEther(address to, bytes message) public payable {

    require(msg.value > 0);

    balances[to][etherAddress] = balances[to][etherAddress].add(msg.value);

    emit Airdrop(msg.sender, to, message, etherAddress, msg.value, now);

  }



  // handle ERC20

  function giftERC20(address to, uint amount, address token, bytes message) public {

    ERC20(token).transferFrom(msg.sender, address(this), amount);

    balances[to][token] = balances[to][token].add(amount);

    emit Airdrop(msg.sender, to, message, token, amount, now);

  }



  function claim(address token) public {

    uint amount = balanceOf(msg.sender, token);

    require(amount > 0);

    balances[msg.sender][token] = 0;

    require(sendTokensTo(msg.sender, amount, token));

    emit Claim(msg.sender, token, amount, now);

  }



  function balanceOf(address person, address token) public view returns(uint) {

    return balances[person][token];

  }



  function sendTokensTo(address destination, uint256 amount, address tkn) private returns(bool) {

    if (tkn == etherAddress) {

      destination.transfer(amount);

    } else {

      require(ERC20(tkn).transfer(destination, amount));

    }

    return true;

  }

}