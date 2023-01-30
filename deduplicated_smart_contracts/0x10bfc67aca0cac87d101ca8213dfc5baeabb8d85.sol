/**
 *Submitted for verification at Etherscan.io on 2019-10-10
*/

pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function transferToVC(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval( address indexed owner, address indexed spender, uint256 value );
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;
  
  mapping(address => uint256) internal freezeBalances;
  
  mapping(address => uint256) internal transferTime;

  uint256 internal totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  
  modifier checkFreeze(address _from, uint256 _value) {
    uint256 span = now.sub(transferTime[_from]);                            //锁仓时长
    uint256 value2 = balances[_from].sub(_value);                           //转账后余额
    uint256 freeze = freezeBalances[_from];                                 //天使投资冻结金额
    require(
      freeze == 0 ||                                                        //非天使投资
      value2 >= freeze ||                                                   //锁仓6个月
      span > 180 days && value2 >= freeze.mul(0.7 ether).div(1 ether) ||    //第6个月底解锁40%
      span > 210 days && value2 >= freeze.mul(0.4 ether).div(1 ether) ||    //第7个月底解锁30%
      span > 240 days                                                       //第8个月底全部解锁
    );
    _;
  }
  
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public checkFreeze(msg.sender, _value) returns (bool) {
     require(_to != address(0));
     require(_value <= balances[msg.sender]);
     balances[msg.sender] = balances[msg.sender].sub(_value);
     balances[_to] = balances[_to].add(_value);
     emit Transfer(msg.sender, _to, _value);
     return true;
  }
  
  //转账给投资人时调这个函数转账
  function transferToVC(address _to, uint256 _value) public checkFreeze(msg.sender, _value) returns (bool) {
    transfer(_to, _value);
	freezeBalances[_to]=freezeBalances[_to].add(_value);    //保存投资人投资金额，计算冻结金额
	transferTime[_to] = now;    //保存当前转账时间
    return true;
  }


  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
  
  function timeOf(address _owner) public view returns (uint256) {
    return transferTime[_owner];
  }
  
  function freezeBalanceOf(address _owner) public view returns (uint256) {
    return freezeBalances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom( address _from, address _to, uint256 _value ) public checkFreeze(_from, _value) returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance( address _owner, address _spender ) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
}

contract ABTToken is StandardToken {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor() public {
    name = "ABTToken";
    symbol = "ABT";
    decimals = 8;
    totalSupply_ = 1000000000000000000;
    balances[0xB97f41cc340899DbA210BdCc86a912ef100eFE96] = totalSupply_;
    emit Transfer(address(0), 0xB97f41cc340899DbA210BdCc86a912ef100eFE96, totalSupply_);
  }
}