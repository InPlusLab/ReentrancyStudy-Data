/**
 *Submitted for verification at Etherscan.io on 2021-04-23
*/

pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// @Name SafeMath
// @Desc Math operations with safety checks that throw on error
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
// ----------------------------------------------------------------------------
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
        return a / b;
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
// ----------------------------------------------------------------------------
// @title ERC20Basic
// @dev Simpler version of ERC20 interface
// See https://github.com/ethereum/EIPs/issues/179
// ----------------------------------------------------------------------------
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
// ----------------------------------------------------------------------------
// @title ERC20 interface
// @dev See https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// ----------------------------------------------------------------------------
// @title Basic token
// @dev Basic version of StandardToken, with no allowances.
// ----------------------------------------------------------------------------
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

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}
// ----------------------------------------------------------------------------
// @title Ownable
// ----------------------------------------------------------------------------
contract Ownable {

    address public owner;
    address public operator;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() public {
        owner    = msg.sender;
        operator = msg.sender;
    }

    modifier onlyOwner() { require(msg.sender == owner); _; }
    modifier onlyOwnerOrOperator() { require(msg.sender == owner || msg.sender == operator); _; }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function transferOperator(address _newOperator) external onlyOwner {
        require(_newOperator != address(0));
        emit OperatorTransferred(operator, _newOperator);
        operator = _newOperator;
    }
}
// ----------------------------------------------------------------------------
// @title BlackList
// @dev Base contract which allows children to implement an emergency stop mechanism.
// ----------------------------------------------------------------------------
contract BlackList is Ownable {

    event Lock(address indexed LockedAddress);
    event Unlock(address indexed UnLockedAddress);

    mapping( address => bool ) public blackList;

    modifier CheckBlackList { require(blackList[msg.sender] != true); _; }

    function SetLockAddress(address _lockAddress) external onlyOwnerOrOperator returns (bool) {
        require(_lockAddress != address(0));
        require(_lockAddress != owner);
        require(blackList[_lockAddress] != true);

        blackList[_lockAddress] = true;

        emit Lock(_lockAddress);

        return true;
    }

    function UnLockAddress(address _unlockAddress) external onlyOwner returns (bool) {
        require(blackList[_unlockAddress] != false);

        blackList[_unlockAddress] = false;

        emit Unlock(_unlockAddress);

        return true;
    }
}
// ----------------------------------------------------------------------------
// @title Pausable
// @dev Base contract which allows children to implement an emergency stop mechanism.
// ----------------------------------------------------------------------------
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() { require(!paused); _; }
    modifier whenPaused() { require(paused); _; }

    function pause() onlyOwnerOrOperator whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}
// ----------------------------------------------------------------------------
// @title Standard ERC20 token
// @dev Implementation of the basic standard token.
// https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
        } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}
// ----------------------------------------------------------------------------
// @title MultiTransfer Token
// @dev Only Admin
// ----------------------------------------------------------------------------
contract MultiTransferToken is StandardToken, Ownable {

    function MultiTransfer(address[] _to, uint256[] _amount) onlyOwner public returns (bool) {
        require(_to.length == _amount.length);

        uint256 ui;
        uint256 amountSum = 0;

        for (ui = 0; ui < _to.length; ui++) {
            require(_to[ui] != address(0));
            amountSum = amountSum.add(_amount[ui]);
        }

        require(amountSum <= balances[msg.sender]);

        for (ui = 0; ui < _to.length; ui++) {
            balances[msg.sender] = balances[msg.sender].sub(_amount[ui]);
            balances[_to[ui]] = balances[_to[ui]].add(_amount[ui]);

            emit Transfer(msg.sender, _to[ui], _amount[ui]);
        }

        return true;
    }
}
// ----------------------------------------------------------------------------
// @title Mintable token
// @dev Simple ERC20 Token example, with mintable token creation
// Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
// ----------------------------------------------------------------------------
contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() { require(!mintingFinished); _; }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }

    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}
// ----------------------------------------------------------------------------
// @title Pausable token
// @dev StandardToken modified with pausable transfers.
// ----------------------------------------------------------------------------

contract PausableToken is StandardToken, Pausable, BlackList {

    function transfer(address _to, uint256 _value) public whenNotPaused CheckBlackList returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused CheckBlackList returns (bool) {
        require(blackList[_from] != true);
        require(blackList[_to] != true);

        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused CheckBlackList returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused CheckBlackList returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused CheckBlackList returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}
// ----------------------------------------------------------------------------
// @Project EBANK (Everyone's Idea Bank)
// @ Contract : https://etherscan.io/address/0x3e6875dc24b75288508abb34ef7b2af8d6b48eaa
// @ Token TX : https://etherscan.io/tx/0xf90094db13818d0f31b74c8b9c891ee2f57c61859f4aca7326472e4d18e91d5a
// @ Minting TX : https://etherscan.io/tx/0x457f1d8ea75724590072e78e00503503b7c9eca2b90de495deeb64e620a530e0

// ----------------------------------------------------------------------------
contract EBank is PausableToken, MintableToken, MultiTransferToken {
    string public name = "EBank";
    string public symbol = "EBK";
    uint256 public decimals = 18;
}