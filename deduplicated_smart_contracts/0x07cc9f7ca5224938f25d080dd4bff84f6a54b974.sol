/**
 *Submitted for verification at Etherscan.io on 2019-10-26
*/

pragma solidity ^0.4.25;
 

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}



contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function transfer(address to, uint value) public returns (bool);
  
  event Transfer(address indexed from, address indexed to, uint value);
  
  function allowance(address owner, address spender) public constant returns (uint);
  function transferFrom(address from, address to, uint value) public returns (bool);
  function approve(address spender, uint value) public returns (bool);
  
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint;
    
  address public owner;
  
  /// This is a switch to control the liquidity
  bool public transferable = true;
  
  mapping(address => uint) balances;

  //The frozen accounts 
  mapping (address => bool) public frozenAccount;

  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }
  
  modifier unFrozenAccount{
      require(!frozenAccount[msg.sender]);
      _;
  }
  
  modifier onlyOwner {
        require(msg.sender == owner);
        _;
  }
  
  modifier onlyTransferable {
      if (transferable) {
          _;
      } else {
          emit LiquidityAlarm("The liquidity is switched off");
          throw;
      }
  }
  
  /// Emitted when the target account is frozen
  event FrozenFunds(address _target, bool _frozen);
  
  /// Emitted when a function is invocated by unauthorized addresses.
  event InvalidCaller(address indexed _from);

  /// Emitted when some TOKEN are burn.
  event Burn(address indexed _from, uint256 value);
  
  /// Emitted when the ownership is transferred.
  event OwnershipTransferred(address indexed _from, address indexed to);
  
  /// Emitted if the account is invalid for transaction.
  event InvalidAccount(address indexed _from, bytes msg);
  
  /// Emitted when the liquity of TOKEN is switched off
  event LiquidityAlarm(bytes msg);
  
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) unFrozenAccount onlyTransferable public returns (bool){
    if (frozenAccount[_to]) {
        emit InvalidAccount(_to, "The receiver account is frozen");
		return false;
    } else {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
		return true;
    } 
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

  ///@notice `freeze? Prevent | Allow` `target` from sending & receiving TOKEN preconditions
  ///@param target Address to be frozen
  ///@param freeze To freeze the target account or not
  function freezeAccount(address target, bool freeze) onlyOwner public {
      frozenAccount[target]=freeze;
      emit FrozenFunds(target, freeze);
    }
  
  function accountFrozenStatus(address target) public view returns (bool frozen) {
      return frozenAccount[target];
  }
  
  function transferOwnership(address newOwner) onlyOwner public {
      if (newOwner != address(0)) {
          address oldOwner=owner;
          owner = newOwner;
          emit OwnershipTransferred(oldOwner, owner);
        }
  }
  
  function switchLiquidity (bool _transferable) onlyOwner public returns (bool success) {
      transferable=_transferable;
      return true;
  }
  
  function liquidityStatus () public view returns (bool _transferable) {
      return transferable;
  }
}


contract StandardToken is BasicToken {

  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) unFrozenAccount onlyTransferable public returns (bool){
    uint256 _allowance = allowed[_from][msg.sender];

    // Check account _from and _to is not frozen
    require(!frozenAccount[_from] && !frozenAccount[_to]);
    
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
	return true;
  }

  function approve(address _spender, uint _value) unFrozenAccount public returns (bool){
    require(_value > 0);

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
	return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }	
  
}


contract HuiTongVouchers is StandardToken {
    string public name = "HuiTongVouchers";
    string public symbol = "HTV";
    uint public decimals = 18;
 
    constructor() public {
        owner = msg.sender;
        totalSupply = 16 * 10 ** 26;
        balances[owner] = totalSupply;
    }
	
	
	function burn(uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value);  
		require(_value > 0); 
		
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
		emit Transfer(msg.sender, 0, _value);
		emit Burn(msg.sender, _value);

        return true;
    }


    function () public payable {
        revert();
    }
}