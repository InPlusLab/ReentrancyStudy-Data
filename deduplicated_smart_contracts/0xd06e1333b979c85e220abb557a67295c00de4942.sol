pragma solidity ^0.4.18;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity ^0.4.18;

import "./ERC20Basic.sol";
import "./SafeMath.sol";

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}
pragma solidity ^0.4.18;

import "./ERC20Basic.sol";

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.4.18;

import "./StandardToken.sol";
import "./Pausable.sol";

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
  }
pragma solidity ^0.4.18;

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  }

pragma solidity ^0.4.18;

import "./Ownable.sol";
import "./ERC20Basic.sol";
import "./SafeERC20.sol";

contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }
  }
pragma solidity ^0.4.18;

import "./StandardToken.sol";
import "./PausableToken.sol";
import "./MintableToken.sol";
import "./CanReclaimToken.sol";


contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

contract MOOVEToken is StandardToken, PausableToken, MintableToken {

  string public constant name = "MOOVE CURRENCY"; 
  string public constant symbol = "MOOVE"; 
  uint8 public constant decimals = 18; 

  uint256 public constant INITIAL_SUPPLY = 0 * (10 ** uint256(decimals));

  function MOOVEToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    maxSupply = 400000000 * (10 ** uint256(decimals));

    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

  function approveAndCall(address spender, uint _value, bytes data) public returns (bool success) {
    approve(spender, _value);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, _value, address(this), data);
    return true;
  }
}
pragma solidity ^0.4.18;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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
  }
pragma solidity ^0.4.18;

import "./ERC20Basic.sol";
import "./ERC20.sol";

library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
  }
pragma solidity ^0.4.18;

import "./StandardToken.sol";
import "./Ownable.sol";
import "./Claimable.sol";

contract MintableToken is StandardToken, Ownable, Claimable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  uint public maxSupply = 400000000 * (10 ** 18);


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    if (maxSupply < totalSupply_.add(_amount) ) {
        revert();
    }

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  }
pragma solidity ^0.4.18;

import "./Ownable.sol";

contract Claimable is Ownable {
  address public pendingOwner;

  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
  }
pragma solidity ^0.4.18;

import "./BasicToken.sol";
import "./ERC20.sol";

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  }
pragma solidity ^0.4.18;

import "./Ownable.sol";

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
  }
pragma solidity ^0.4.18;

import "./Ownable.sol";

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract TestTokenFallback is Ownable {
    bool public requireFlag = true;
    bool public successFlag = true;

    event LogTokenFallback(address indexed msgSender, address indexed from, uint256 amount, bytes data);
    event LogReceiveApproval(address indexed msgSender, uint256 amount, address indexed token, bytes data);

    function setRequireFlag(bool _requireFlag) public onlyOwner {
        requireFlag = _requireFlag;
    }

    function setSuccessFlag(bool _successFlag) public onlyOwner {
        successFlag = _successFlag;
    }

    function tokenFallback(address from, uint256 amount, bytes data) public returns (bool success) {
        // ERC20Interface(token).transferFrom(from, address(this), tokens);
        require(requireFlag);
        LogTokenFallback(msg.sender, from, amount, data);
        return successFlag;
    }

    function receiveApproval(address from, uint256 amount, address token, bytes data) public {
        require(requireFlag);
        ERC20Interface(token).transferFrom(from, address(this), amount);
        LogReceiveApproval(msg.sender, amount, token, data);
    }
}
