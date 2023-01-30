pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   */
  function Ownable() public {
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
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   */
  function transferOwnership(address newOwner) public onlyOwner{
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

contract ComissionList is Claimable {
  using SafeMath for uint256;

  struct Transfer {
    uint256 stat;
    uint256 perc;
  }

  mapping (string => Transfer) refillPaySystemInfo;
  mapping (string => Transfer) widthrawPaySystemInfo;

  Transfer transferInfo;

  event RefillCommisionIsChanged(string _paySystem, uint256 stat, uint256 perc);
  event WidthrawCommisionIsChanged(string _paySystem, uint256 stat, uint256 perc);
  event TransferCommisionIsChanged(uint256 stat, uint256 perc);

  // ����ѧߧ�ӧڧ�� �ڧߧ���ާѧ�ڧ� ��� �ܧ�ާڧ��ڧ� �էݧ� �����ݧߧ�֧ާ�� ��ݧѧ�קاߧ�� ��ڧ��֧ާ�
  function setRefillFor(string _paySystem, uint256 _stat, uint256 _perc) public onlyOwner returns (uint256) {
    refillPaySystemInfo[_paySystem].stat = _stat;
    refillPaySystemInfo[_paySystem].perc = _perc;

    RefillCommisionIsChanged(_paySystem, _stat, _perc);
  }

  // ����ѧߧ�ӧڧ�� �ڧߧ���ާѧ�ڧ� ��� �ܧ�ާڧ��ڧ� �էݧ� ��ߧڧާѧ֧�ާ� ��ݧѧ�קاߧ�� ��ڧ��֧ާ�
  function setWidthrawFor(string _paySystem,uint256 _stat, uint256 _perc) public onlyOwner returns (uint256) {
    widthrawPaySystemInfo[_paySystem].stat = _stat;
    widthrawPaySystemInfo[_paySystem].perc = _perc;

    WidthrawCommisionIsChanged(_paySystem, _stat, _perc);
  }

  // ����ѧߧ�ӧڧ�� �ڧߧ���ާѧ�ڧ� ��� �ܧ�ާڧ��ڧ� �էݧ� ��֧�֧ӧ�է�
  function setTransfer(uint256 _stat, uint256 _perc) public onlyOwner returns (uint256) {
    transferInfo.stat = _stat;
    transferInfo.perc = _perc;

    TransferCommisionIsChanged(_stat, _perc);
  }

  // �ӧ٧��� �����֧ߧ� ��� �ܧ�ާڧ��ڧ� �էݧ� �����ݧߧ�֧ާ�� ��ݧѧ�קاߧ�� ��ڧ��֧ާ�
  function getRefillStatFor(string _paySystem) public view returns (uint256) {
    return refillPaySystemInfo[_paySystem].perc;
  }

  // �ӧ٧��� ��ڧܧ� ��� �ܧ�ާڧ��ڧ� �էݧ� �����ݧߧ�֧ާ�� ��ݧѧ�קاߧ�� ��ڧ��֧ާ�
  function getRefillPercFor(string _paySystem) public view returns (uint256) {
    return refillPaySystemInfo[_paySystem].stat;
  }

  // �ӧ٧��� �����֧ߧ� ��� �ܧ�ާڧ��ڧ� �էݧ� ��ߧڧާѧ֧ާ�� ��ݧѧ�קاߧ�� ��ڧ��֧ާ�
  function getWidthrawStatFor(string _paySystem) public view returns (uint256) {
    return widthrawPaySystemInfo[_paySystem].perc;
  }

  // �ӧ٧��� ��ڧܧ� ��� �ܧ�ާڧ��ڧ� �էݧ� ��ߧڧާѧ֧ާ�� ��ݧѧ�קاߧ�� ��ڧ��֧ާ�
  function getWidthrawPercFor(string _paySystem) public view returns (uint256) {
    return widthrawPaySystemInfo[_paySystem].stat;
  }

  // �ӧ٧��� �����֧ߧ� ��� �ܧ�ާڧ��ڧ� �էݧ� ��֧�֧ӧ�է�
  function getTransferPerc() public view returns (uint256) {
    return transferInfo.perc;
  }
  
  // �ӧ٧��� ��ڧܧ� ��� �ܧ�ާڧ��ڧ� �էݧ� ��֧�֧ӧ�է�
  function getTransferStat() public view returns (uint256) {
    return transferInfo.stat;
  }

  // ��ѧ���ڧ�ѧ�� �ܧ�ާڧ��ڧ� ��� ��ߧ��ڧ� �էݧ� ��ݧѧ�קاߧ�� ��ڧ��֧ާ� �� ���ާާ�
  function calcWidthraw(string _paySystem, uint256 _value) public view returns(uint256) {
    uint256 _totalComission;
    _totalComission = widthrawPaySystemInfo[_paySystem].stat + (_value / 100 ) * widthrawPaySystemInfo[_paySystem].perc;

    return _totalComission;
  }

  // ��ѧ���ڧ�ѧ�� �ܧ�ާڧ��ڧ� �� �����ݧߧ֧ߧڧ� �էݧ� ��ݧѧ�קاߧ�� ��ڧ��֧ާ� �� ���ާާ�
  function calcRefill(string _paySystem, uint256 _value) public view returns(uint256) {
    uint256 _totalComission;
    _totalComission = refillPaySystemInfo[_paySystem].stat + (_value / 100 ) * refillPaySystemInfo[_paySystem].perc;

    return _totalComission;
  }

  // ��ѧ���ڧ�ѧ�� �ܧ�ާڧ��ڧ� �� ��֧�֧ӧ�է� �էݧ� ��ݧѧ�קاߧ�� ��ڧ��֧ާ� �� ���ާާ�
  function calcTransfer(uint256 _value) public view returns(uint256) {
    uint256 _totalComission;
    _totalComission = transferInfo.stat + (_value / 100 ) * transferInfo.perc;

    return _totalComission;
  }
}