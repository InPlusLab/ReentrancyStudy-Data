/**

 *Submitted for verification at Etherscan.io on 2018-10-30

*/



pragma solidity ^0.4.24;







/**

 * @title String

 * @dev ConcatenationString, uintToString, stringsEqual, stringToBytes32, bytes32ToString

 */

contract String {



  function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string memory) {

    bytes memory _ba = bytes(_a);

    bytes memory _bb = bytes(_b);

    bytes memory _bc = bytes(_c);

    bytes memory _bd = bytes(_d);

    bytes memory _be = bytes(_e);

    bytes memory abcde = bytes(new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length));

    uint k = 0;

    uint i;

    for (i = 0; i < _ba.length; i++) {

      abcde[k++] = _ba[i];

    }

    for (i = 0; i < _bb.length; i++) {

      abcde[k++] = _bb[i];

    }

    for (i = 0; i < _bc.length; i++) {

      abcde[k++] = _bc[i];

    }

    for (i = 0; i < _bd.length; i++) {

      abcde[k++] = _bd[i];

    }

    for (i = 0; i < _be.length; i++) {

      abcde[k++] = _be[i];

    }

    return string(abcde);

  }



  function strConcat(string _a, string _b, string _c, string _d) internal pure returns(string) {

    return strConcat(_a, _b, _c, _d, "");

  }



  function strConcat(string _a, string _b, string _c) internal pure returns(string) {

    return strConcat(_a, _b, _c, "", "");

  }



  function strConcat(string _a, string _b) internal pure returns(string) {

    return strConcat(_a, _b, "", "", "");

  }



  function uint2str(uint i) internal pure returns(string) {

    if (i == 0) {

      return "0";

    }

    uint j = i;

    uint length;

    while (j != 0) {

      length++;

      j /= 10;

    }

    bytes memory bstr = new bytes(length);

    uint k = length - 1;

    while (i != 0) {

      bstr[k--] = byte(uint8(48 + i % 10));

      i /= 10;

    }

    return string(bstr);

  }



  function stringsEqual(string memory _a, string memory _b) internal pure returns(bool) {

    bytes memory a = bytes(_a);

    bytes memory b = bytes(_b);



    if (a.length != b.length)

      return false;



    for (uint i = 0; i < a.length; i++) {

      if (a[i] != b[i]) {

        return false;

      }

    }



    return true;

  }



  function stringToBytes32(string memory source) internal pure returns(bytes32 result) {

    bytes memory _tmp = bytes(source);

    if (_tmp.length == 0) {

      return 0x0;

    }

    assembly {

      result := mload(add(source, 32))

    }

  }



  function bytes32ToString(bytes32 x) internal pure returns (string) {

    bytes memory bytesString = new bytes(32);

    uint charCount = 0;

    uint j;

    for (j = 0; j < 32; j++) {

      byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));

      if (char != 0) {

        bytesString[charCount] = char;

        charCount++;

      }

    }

    bytes memory bytesStringTrimmed = new bytes(charCount);

    for (j = 0; j < charCount; j++) {

      bytesStringTrimmed[j] = bytesString[j];

    }

    return string(bytesStringTrimmed);

  }



  function inArray(string[] _array, string _value) internal pure returns(bool result) {

    if (_array.length == 0 || bytes(_value).length == 0) {

      return false;

    }

    result = false;

    for (uint i = 0; i < _array.length; i++) {

      if (stringsEqual(_array[i],_value)) {

        result = true;

        return true;

      }

    }

  }

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor () public {

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



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }

}



/**

 * @title MultiOwnable

 * @dev The MultiOwnable contract has an owner address[], and provides basic authorization control

 */

contract MultiOwnable is Ownable {



  struct Types {

    mapping (address => bool) access;

  }

  mapping (uint => Types) private multiOwnersTypes;



  event AddOwner(uint _type, address addr);

  event AddOwner(uint[] types, address addr);

  event RemoveOwner(uint _type, address addr);



  modifier onlyMultiOwnersType(uint _type) {

    require(multiOwnersTypes[_type].access[msg.sender] || msg.sender == owner, "403");

    _;

  }



  function onlyMultiOwnerType(uint _type, address _sender) public view returns(bool) {

    if (multiOwnersTypes[_type].access[_sender] || _sender == owner) {

      return true;

    }

    return false;

  }



  function addMultiOwnerType(uint _type, address _owner) public onlyOwner returns(bool) {

    require(_owner != address(0));

    multiOwnersTypes[_type].access[_owner] = true;

    emit AddOwner(_type, _owner);

    return true;

  }

  

  function addMultiOwnerTypes(uint[] types, address _owner) public onlyOwner returns(bool) {

    require(_owner != address(0));

    require(types.length > 0);

    for (uint i = 0; i < types.length; i++) {

      multiOwnersTypes[types[i]].access[_owner] = true;

    }

    emit AddOwner(types, _owner);

    return true;

  }



  function removeMultiOwnerType(uint types, address _owner) public onlyOwner returns(bool) {

    require(_owner != address(0));

    multiOwnersTypes[types].access[_owner] = false;

    emit RemoveOwner(types, _owner);

    return true;

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

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

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



contract IBonus {

  function getCurrentDayBonus(uint startSaleDate, bool saleState) public view returns(uint);

  function _currentDay(uint startSaleDate, bool saleState) public view returns(uint);

  function getBonusData() public view returns(string);

  function getPreSaleBonusPercent() public view returns(uint);

  function getMinReachUsdPayInCents() public view returns(uint);

}



contract ShipCoinBonusSystem is IBonus, MultiOwnable, String {

  using SafeMath for uint256;



  struct Bonus {

    uint startDay;

    uint endDay;

    uint percent;

  }



  Bonus[] public bonus;



  uint256 private constant ONE_DAY = 86400;



  uint private preSaleBonusPercent = 40;

  uint private minReachUsdPayInCents = 1000000;



  event AddBonus(uint startDay, uint endDay, uint percent);

  event ChangeBonus(uint startDay, uint endDay, uint percentOld, uint percentNew);

  event DeleteBonus(uint startDay, uint endDay, uint percent);



  /**

   * @dev constructor

   */

  constructor() public {

    bonus.push(Bonus(0, 2, 20)); // 20% for the first 48 hours | 0 - 2 days

    bonus.push(Bonus(3, 14, 15)); // 15% for weeks 1-2 starting from day 3 | 3 - 14 days

    bonus.push(Bonus(15, 28, 10)); // 10% for weeks 3-4 | 15 - 28 days

    bonus.push(Bonus(29, 42, 5));// 5% for weeks 5-6 | 29 - 42 days

  }



  /**

   * @dev Add or change bonus data

   * @param _startDay timestamp

   * @param _endDay timestamp

   * @param _percent uint

   */

  function addChangeBonus(uint _startDay, uint _endDay, uint _percent) public onlyMultiOwnersType(1) returns(bool) {

    for (uint i = 0; i < bonus.length; i++) {

      if (bonus[i].startDay == _startDay && bonus[i].endDay == _endDay) {

        uint oldPercent = bonus[i].percent;

        if (bonus[i].percent != _percent) {

          bonus[i].percent = _percent;

          emit ChangeBonus(_startDay, _endDay, oldPercent, _percent);

        }

        return true;

      }

    }

    bonus.push(Bonus(_startDay, _endDay, _percent));

    emit AddBonus(_startDay, _endDay, _percent);

    return true;

  }



  /**

   * @dev Delete bonus data

   * @param _startDay timestamp

   * @param _endDay timestamp

   * @param _percent uint

   */

  function delBonus(uint _startDay, uint _endDay, uint _percent) public onlyMultiOwnersType(2) returns(bool) {

    for (uint i = 0; i < bonus.length; i++) {

      if (bonus[i].startDay == _startDay && bonus[i].endDay == _endDay && bonus[i].percent == _percent) {

        delete bonus[i];

        emit DeleteBonus(_startDay, _endDay, _percent);

        return true;

      }

    }

    return false;

  }



  /**

   * @dev Get current day bonus percent.

   * @param startSaleDate timestamp

   * @param saleState bool

   */

  function getCurrentDayBonus(uint startSaleDate, bool saleState) public view returns(uint) {

    if (saleState) {

      for (uint i = 0; i < bonus.length; i++) {

        if ((startSaleDate > 0 && block.timestamp >= startSaleDate) && (_currentDay(startSaleDate, saleState) >= bonus[i].startDay) && (_currentDay(startSaleDate, saleState) <= bonus[i].endDay)) {

          if (bonus[i].percent > 0) {

            return bonus[i].percent;

          }

        }

      }

    }

    return 0;

  }



  /**

   * @dev Change preSale bonus percent

   * @param _bonus uint

   */

  function changePreSaleBonus(uint _bonus) public onlyOwner returns(bool) {

    require(_bonus > 20);

    preSaleBonusPercent = _bonus;

  }



  /**

   * @dev Change the minimum required amount to participate in the PreSale.

   * @param _minUsdInCents minReachUsdPayInCents

   */

  function changePreSaleMinUsd(uint _minUsdInCents) public onlyOwner returns(bool) {

    require(_minUsdInCents > 100000);

    minReachUsdPayInCents = _minUsdInCents;

  }



  /**

   * @dev §³urrent day from the moment of start sale

   * @param startSaleDate timestamp

   * @param saleState bool

   */

  function _currentDay(uint startSaleDate, bool saleState) public view returns(uint) {

    if (!saleState || startSaleDate == 0 || startSaleDate > block.timestamp) {

      return 0;

    }

    return block.timestamp.sub(startSaleDate).div(ONE_DAY);

  }



  /**

   * @dev get all bonus data in json format

   */

  function getBonusData() public view returns(string) {

    string memory _array = "[";

    for (uint i = 0; i < bonus.length; i++) {

      _array = strConcat(

          _array,

          strConcat("{\"startDay\":", uint2str(bonus[i].startDay), ",\"endDay\":", uint2str(bonus[i].endDay), ",\"percent\":"),

          uint2str(bonus[i].percent),

          (i+1 == bonus.length) ? "}]" : "},"

        );

    }

    return _array;

  }



  /**

   * @dev get preSale bonus prcent

   */

  function getPreSaleBonusPercent() public view returns(uint) {

    return preSaleBonusPercent;

  }



  /**

   * @dev get minimum required amount to participate in the PreSale

   */

  function getMinReachUsdPayInCents() public view returns(uint) {

    return minReachUsdPayInCents;

  }



}