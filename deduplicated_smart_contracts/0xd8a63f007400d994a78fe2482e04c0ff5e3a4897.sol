/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

/**
¡°Commons Clause¡± License Condition v1.0

The Software is provided to you by the Licensor under the License, as defined below, subject to the following condition.

Without limiting other conditions in the License, the grant of rights under the License will not include, and the License does not grant to you, the right to Sell the Software.

For purposes of the foregoing, ¡°Sell¡± means practicing any or all of the rights granted to you under the License to provide to third parties, for a fee or other consideration (including without limitation fees for hosting or consulting/ support services related to the Software), a product or service whose value derives, entirely or substantially, from the functionality of the Software. Any license notice or attribution required by the License must also include this Commons Clause License Condition notice.

Software: Mopayd

License: Apache 2.0 with Common Clause

Licensor: Mopayd LLC


 *Authored by Alex George
*/

pragma solidity ^0.4.23;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
    require(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  /**
  * @dev a to power of b, throws on overflow.
  */
  function pow(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a ** b;
    require(c >= a);
    return c;
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
// Mopayd app
// Authored by Alex George
// https://github.com/bitbleach

contract Mopayd is Ownable {
  using SafeMath for uint256;

  address public feeAccount;
  uint256 public inactivityReleasePeriod;
  mapping (address => mapping (address => uint256)) public tokens;
  mapping (address => mapping (address => bool)) public delegation;
  mapping (address => uint256) public lastActiveTransaction;
  mapping (address => bool) public hardWithdrawRequested;
  mapping (address => bool) public superAdmins;
  mapping (address => bool) public admins;
  mapping (bytes32 => bool) public withdrawn;
  mapping (bytes32 => bool) public paymentDelegation;
  mapping (bytes32 => uint256) public orderFills;
  mapping (bytes32 => uint256) public feeFills;

  event Deposit(address token, address user, address to, uint256 amount, uint256 balance);
  event Payment(uint256 amountTotal, uint256 paymentNonce, uint256 orderExpires, uint256 maxTotalFee, uint256 amountToPay, uint256 txFee, address paymentToken, address merchant, address customer);
  event Withdraw(address token, address user, address to, uint256 amount);
  event RequestHardWithdraw(address user, bool request);
  event Delegation(address user, address to, bool request);

  modifier onlyAdmin {
    require(msg.sender == owner || admins[msg.sender] || superAdmins[msg.sender]);
    _;
  }

  modifier onlySuperAdmin {
    require(msg.sender == owner || superAdmins[msg.sender]);
    _;
  }

  constructor(address _feeAccount, uint256 _inactivityReleasePeriod) public {
    owner = msg.sender;
    feeAccount = _feeAccount;
    inactivityReleasePeriod = _inactivityReleasePeriod;
  }

  function requestHardWithdraw(bool request) public {
    require(block.number.sub(lastActiveTransaction[msg.sender]) >= inactivityReleasePeriod);
    hardWithdrawRequested[msg.sender] = request;
    lastActiveTransaction[msg.sender] = block.number;
    emit RequestHardWithdraw(msg.sender, request);
  }

  function withdraw(address token, uint256 amount) public returns (bool) {
    require(block.number.sub(lastActiveTransaction[msg.sender]) >= inactivityReleasePeriod);
    require(tokens[token][msg.sender] >= amount);
    require(hardWithdrawRequested[msg.sender] == true);

    tokens[token][msg.sender] = tokens[token][msg.sender].sub(amount);
    if (token == address(0)) {
      msg.sender.transfer(amount);
    } else {
      require(ERC20(token).transfer(msg.sender, amount));
    }
    emit Withdraw(token, msg.sender, msg.sender, amount);
    return true;
  }

  function setInactivityReleasePeriod(uint256 expire) onlyAdmin public returns (bool) {
    require(expire <= 2000000);
    require(expire >= 6000);
    inactivityReleasePeriod = expire;
    return true;
  }

  function setSuperAdmin(address superAdmin, bool isAdmin) onlyOwner public {
    superAdmins[superAdmin] = isAdmin;
  }

  function setAdmin(address admin, bool isAdmin) onlySuperAdmin public {
    admins[admin] = isAdmin;
  }

  function setFeeAccount(address newFeeAccount) onlySuperAdmin public {
    feeAccount = newFeeAccount;
  }

  function depositToken(address token, address to, uint256 amount) public {
    receiveTokenDeposit(token, msg.sender, to, amount);
  }

  function receiveTokenDeposit(address token, address from, address to, uint256 amount) public {
    tokens[token][to] = tokens[token][to].add(amount);
    lastActiveTransaction[from] = block.number;
    require(ERC20(token).transferFrom(from, address(this), amount));
    emit Deposit(token, from, to, amount, tokens[token][from]);
  }

  function deposit(address to) payable public {
    tokens[address(0)][to] = tokens[address(0)][to].add(msg.value);
    lastActiveTransaction[msg.sender] = block.number;
    emit Deposit(address(0), msg.sender, to, msg.value, tokens[address(0)][msg.sender]);
  }

  function adminWithdraw(address token, uint256 amount, address user, address to, uint256 nonce, uint8 v, bytes32 r, bytes32 s, uint256 gasCost) onlyAdmin public returns (bool) {
    // user must be able to pay for gas cost
    if(token == address(0)){
      require(tokens[address(0)][user] >= gasCost.add(amount));
    } else {
      require(tokens[token][user] >= gasCost.add(amount));
    }

    bytes32 hash = keccak256(address(this), token, amount, user, to, nonce, gasCost);
    require(!withdrawn[hash]);
    withdrawn[hash] = true;
    require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user);

    if(token == address(0)){
      tokens[address(0)][user] = tokens[address(0)][user].sub(gasCost.add(amount));
      tokens[address(0)][feeAccount] = tokens[address(0)][feeAccount].add(gasCost);
      to.transfer(amount);
    } else {
      tokens[token][user] = tokens[token][user].sub(gasCost.add(amount));
      tokens[token][feeAccount] = tokens[token][feeAccount].add(gasCost);
      require(ERC20(token).transfer(to, amount));
    }
    lastActiveTransaction[user] = block.number;
    emit Withdraw(token, user, to, amount);
    return true;
  }

  function balanceOf(address token, address user) view public returns (uint256) {
    return tokens[token][user];
  }

  function disableDelegatePaymentControl(address user, address to) onlyAdmin public returns (bool) {
    delegation[user][to] = false;
    emit Delegation(owner, to, false);
    return false;
  }

  function delegatePaymentControl(address user, address to, uint256 nonce, uint8 v, bytes32 r, bytes32 s, bool delegate) onlyAdmin public returns (bool) {
    bytes32 hash = keccak256(address(this), user, to, nonce);
    require(!paymentDelegation[hash]);
    paymentDelegation[hash] = true;
    
    require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user);

    delegation[user][to] = delegate;
    emit Delegation(user, to, delegate);
    return delegate;
  }

  /* paymentValues
     [0] amountTotal
     [1] paymentNonce
     [2] orderExpires
     [3] maxTotalFee
     [4] amountToPay
     [5] txFee
   paymentAddresses
     [0] paymentToken
     [1] merchant
     [2] customer
   */

  function sendPayment(uint256[6] paymentValues, address[3] paymentAddresses, uint8 v, bytes32[2] rs) onlyAdmin public returns (bool) {
    // prevents execution of stale orders
    require(block.number < paymentValues[2]);

    // authenticates encrypted request
    bytes32 paymentHash = keccak256(address(this), paymentValues[0], paymentValues[1], paymentValues[2], paymentValues[3], paymentAddresses[0], paymentAddresses[1]);

    address customer = ecrecover(keccak256("\x19Ethereum Signed Message:\n32", paymentHash), v, rs[0], rs[1]);

    require(customer == paymentAddresses[2] || delegation[paymentAddresses[2]][customer]);

    // require customer balance to be greater than transcation balance, amount to pay + fee
    require(tokens[paymentAddresses[0]][paymentAddresses[2]] >= paymentValues[4].add(paymentValues[5]));

    // require cumulative amount sent to be less than specified maximum
    require(orderFills[paymentHash].add(paymentValues[4]) <= paymentValues[0]);
    // require cumulative fee total to never exceed total max fee value
    require(feeFills[paymentHash].add(paymentValues[5]) <= paymentValues[3]);
    
    // subtract payment tokens from customer balance
    tokens[paymentAddresses[0]][paymentAddresses[2]] = tokens[paymentAddresses[0]][paymentAddresses[2]].sub(paymentValues[4]);
    // add payment tokens to merchant balance
    tokens[paymentAddresses[0]][paymentAddresses[1]] = tokens[paymentAddresses[0]][paymentAddresses[1]].add(paymentValues[4]);

    // from customer take processing fee
    tokens[paymentAddresses[0]][paymentAddresses[2]] = tokens[paymentAddresses[0]][paymentAddresses[2]].sub(paymentValues[5]);
    tokens[paymentAddresses[0]][feeAccount] = tokens[paymentAddresses[0]][feeAccount].add(paymentValues[5]);

    orderFills[paymentHash] = orderFills[paymentHash].add(paymentValues[4]);
    feeFills[paymentHash] = feeFills[paymentHash].add(paymentValues[5]);

    emit Payment(paymentValues[0], paymentValues[1], paymentValues[2], paymentValues[3], paymentValues[4], paymentValues[5], paymentAddresses[0], paymentAddresses[1], paymentAddresses[2]);

    lastActiveTransaction[paymentAddresses[1]] = block.number;
    lastActiveTransaction[paymentAddresses[2]] = block.number;

    return true;
  }

}