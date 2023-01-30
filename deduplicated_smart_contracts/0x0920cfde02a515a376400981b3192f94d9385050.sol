/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

/*
 * Copyright ©️ 2018-2020 Galt•Project Society Construction and Terraforming Company
 * (Founded by [Nikolai Popeka](https://github.com/npopeka)
 *
 * Copyright ©️ 2018-2020 Galt•Core Blockchain Company
 * (Founded by [Nikolai Popeka](https://github.com/npopeka) by
 * [Basic Agreement](ipfs/QmaCiXUmSrP16Gz8Jdzq6AJESY1EAANmmwha15uR3c1bsS)).
 * 
 * 🌎 Galt Project is an international decentralized land and real estate property registry
 * governed by DAO (Decentralized autonomous organization) and self-governance platform for communities
 * of homeowners on Ethereum.
 * 
 * 🏡 https://galtproject.io
 */

pragma solidity ^0.5.13;

contract IPPDepositHolder {
  event Deposit(address indexed tokenContract, uint256 indexed tokenId, uint256 amount);
  event Withdrawal(address indexed tokenContract, uint256 indexed tokenId, uint256 total);
  event Payout(address indexed tokenContract, uint256 indexed tokenId, uint256 amount, address to);

  function deposit(address _tokenContract, uint256 _tokenId, uint256 _amount) external;
  function withdraw(address _tokenContract, uint256 _tokenId) external;
  function payout(address _tokenContract, uint256 _tokenId, address _to) external;
  function balanceOf(address _tokenContract, uint256 _tokenId) external view returns (uint256);
  function isInsufficient(address _tokenContract, uint256 _tokenId, uint256 _minimalDeposit)
    external
    view
    returns (bool);
}

library MathUtils {
  int256 constant public longer_fixed_log_e_1_5 = 405465108108164381978013115464349137;
  int256 constant public longer_fixed_1 = 1000000000000000000000000000000000000;
  int256 constant public longer_fixed_log_e_10 = 2302585092994045684017991454684364208;

  int256 constant fixed_1 = 1000000000000000000;
  int256 constant fixed_e = 2718281828459045400;

  int256 constant ln_2 = 693147180559945300;
  int256 constant ln_10 = 2302585092994046000;

  uint256 constant e = 2718281828459045000;

  function INT256_MIN() internal pure returns (int256) {
    return int256((uint256(1) << 255));
  }

  function INT256_MAX() internal pure returns (int256) {
    return int256(~((uint256(1) << 255)));
  }

  function UINT256_MIN() internal pure returns (uint256) {
    return 0;
  }

  function UINT256_MAX() internal pure returns (uint256) {
    return ~uint256(0);
  }

  function EPS() internal pure returns (int256) {
    return 1000000000;
  }

  function abs(int number) internal pure returns (int) {
    return number > 0 ? number : number * (- 1);
  }

  function between(int a, int b, int c) internal pure returns (bool) {
    return (a - EPS() <= b) && (b <= c + EPS());
  }

  function minInt(int a, int b) internal pure returns (int) {
    return a < b ? a : b;
  }

  function maxInt(int a, int b) internal pure returns (int) {
    return a > b ? a : b;
  }

  /**
  * Limitations:
  * - positive values
  **/
  function sqrt(int x) internal pure returns (int y) {
    int z = (x + 1) / 2;
    y = x;
    while (abs(z) < abs(y)) {
      y = z;
      z = (x / z + z) / 2;
    }
    y *= 10 ** 9;
  }

  function floorInt(int x) internal pure returns (int) {
    return (x / 1 ether) * 1 ether;
  }

  function toFixedInt(int x, int precision) internal pure returns (int) {
    if (precision == 18) {
      return x;
    }
    return (x / int(10 ** uint(18 - precision))) * int(10 ** uint(18 - precision));
  }

  /**
  * Limitations:
  * - positive values
  **/
  function logE(int256 x) internal pure returns (int256) {
    if (x > 1.999 ether) {
      int256 newX = x;
      int256 power = 0;
      while (newX > 1.999 ether) {
        newX /= 10;
        power += 1;
      }
      return logOfAroundOne(newX) + power * ln_10;
    } else {
      return logOfAroundOne(x);
    }
  }

  /**
  * Limitations:
  * - positive values
  * - no more than 1.999(9) ether
  **/
  function logOfAroundOne(int256 x) internal pure returns (int256) {
    int256 r = 0;
    int256 v = x;
    while (v <= fixed_1 / 10) {
      v = v * 10;
      r -= longer_fixed_log_e_10;
    }
    while (v >= 10 * fixed_1) {
      v = v / 10;
      r += longer_fixed_log_e_10;
    }
    while (v < fixed_1) {
      v = v * fixed_e;
      r -= longer_fixed_1;
    }
    while (v > fixed_e) {
      v = v / fixed_e;
      r += longer_fixed_1;
    }
    if (v == fixed_1) {
      return round_off(r) / fixed_1;
    }
    if (v == fixed_e) {
      return fixed_1 + round_off(r) / fixed_1;
    }
    v *= fixed_1;
    v = v - 3 * longer_fixed_1 / 2;
    r = r + longer_fixed_log_e_1_5;
    int256 m = longer_fixed_1 * v / (v + 3 * longer_fixed_1);
    r = r + 2 * m;
    int256 m_2 = m * m / longer_fixed_1;
    int256 i = 3;
    while (true) {
      m = m * m_2 / longer_fixed_1;
      r = r + 2 * m / i;
      i += 2;
      if (i >= 3 + 2 * 18)
        break;
    }
    return round_off(r) / fixed_1;
  }

  function logAny(int256 v, int256 base) internal pure returns (int256) {
    return (logE(v) * 1 ether) / logE(base);
  }

  // https://solidity.readthedocs.io/en/v0.5.3/assembly.html
  /**
  * Limitations:
  * - positive values
  **/
  function log2(int256 v) internal pure returns (int256) {
    return (logE(v) * 1 ether) / ln_2;
  }

  /**
  * Limitations:
  * - positive values
  **/
  function log10(int256 v) internal pure returns (int256) {
    return (logE(v) * 1 ether) / ln_10;
  }

  function round_off(int256 x) public pure returns (int256) {
    int8 sign = 1;
    int v = x;
    if (v < 0) {
      sign = - 1;
      v = - v;
    }
    if (v % fixed_1 >= fixed_1 / 2)
      v = v + fixed_1 - v % fixed_1;
    return v * sign;
  }

  /**
  * Limitations: positive values
  **/
  function exp(int x) internal pure returns (int) {
    int sum = 1 ether;
    sum = 1 ether + x * sum / 14 ether;
    sum = 1 ether + x * sum / 13 ether;
    sum = 1 ether + x * sum / 12 ether;
    sum = 1 ether + x * sum / 11 ether;
    sum = 1 ether + x * sum / 10 ether;
    sum = 1 ether + x * sum / 9 ether;
    sum = 1 ether + x * sum / 8 ether;
    sum = 1 ether + x * sum / 7 ether;
    sum = 1 ether + x * sum / 6 ether;
    sum = 1 ether + x * sum / 5 ether;
    sum = 1 ether + x * sum / 4 ether;
    sum = 1 ether + x * sum / 3 ether;
    sum = 1 ether + x * sum / 2 ether;
    sum = 1 ether + x * sum / 1 ether;

    return sum;
  }
}

library PointUtils {

  int256 internal constant EPS = 1000000000;

  function comparePoints(int[2] memory a, int[2] memory b) internal pure returns (int8) {
    if (a[0] - b[0] > EPS || (MathUtils.abs(a[0] - b[0]) < EPS && a[1] - b[1] > EPS)) {
      return 1;
    } else if (b[0] - a[0] > EPS || (MathUtils.abs(a[0] - b[0]) < EPS && b[1] - a[1] > EPS)) {
      return - 1;
    } else if (MathUtils.abs(a[0] - b[0]) < EPS && MathUtils.abs(a[1] - b[1]) < EPS) {
      return 0;
    }
  }

  function isEqual(int[2] memory a, int[2] memory b) internal pure returns (bool) {
    return a[0] == b[0] && a[1] == b[1];
  }

  function isEqualEPS(int[2] memory a, int[2] memory b) internal pure returns (bool) {
    return MathUtils.abs(a[0] - b[0]) < EPS && MathUtils.abs(a[1] - b[1]) < EPS;
  }
}

library VectorUtils {
  function onSegment(int[2] memory a, int[2] memory b, int[2] memory c) internal pure returns (bool) {
    /* solium-disable-next-line */
    return (MathUtils.minInt(a[0], b[0]) <= c[0]) && (c[0] <= MathUtils.maxInt(a[0], b[0])) &&
    /* solium-disable-next-line */
    (MathUtils.minInt(a[1], b[1]) <= c[1]) && (c[1] <= MathUtils.maxInt(a[1], b[1]));
  }

  function direction(int[2] memory a, int[2] memory b, int[2] memory c) internal pure returns (int256) {
    return (c[0] - a[0]) * (b[1] - a[1]) - (b[0] - a[0]) * (c[1] - a[1]);
  }
}

library SegmentUtils {

  int256 internal constant EPS = 1000000000;
  int256 internal constant POS_EPS = 10000000000000000000000;

  enum Position {
    BEFORE,
    AFTER
  }

  struct Sweepline {
    int256 x;
    Position position;
  }

  function segmentsIntersect(int[2][2] memory a, int[2][2] memory b) internal pure returns (bool) {
    int256 d1 = VectorUtils.direction(b[0], b[1], a[0]);
    int256 d2 = VectorUtils.direction(b[0], b[1], a[1]);
    int256 d3 = VectorUtils.direction(a[0], a[1], b[0]);
    int256 d4 = VectorUtils.direction(a[0], a[1], b[1]);

    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
      return true;
    } else if (d1 == 0 && VectorUtils.onSegment(b[0], b[1], a[0])) {
      return true;
    } else if (d2 == 0 && VectorUtils.onSegment(b[0], b[1], a[1])) {
      return true;
    } else if (d3 == 0 && VectorUtils.onSegment(a[0], a[1], b[0])) {
      return true;
    } else if (d4 == 0 && VectorUtils.onSegment(a[0], a[1], b[1])) {
      return true;
    }
    return false;
  }

  function findSegmentsIntersection(int[2][2] memory a, int[2][2] memory b) internal pure returns (int256[2] memory) {
    int xDivide = ((a[0][0] - a[1][0]) * (b[0][1] - b[1][1]) - (a[0][1] - a[1][1]) * (b[0][0] - b[1][0]));
    if (xDivide == 0) {
      return int256[2]([int256(0), 0]);
    }

    int x = ((a[0][0] * a[1][1] - a[0][1] * a[1][0]) * (b[0][0] - b[1][0]) - (a[0][0] - a[1][0]) * (b[0][0] * b[1][1] - b[0][1] * b[1][0])) /
    xDivide;

    int yDivide = ((a[0][0] - a[1][0]) * (b[0][1] - b[1][1]) - (a[0][1] - a[1][1]) * (b[0][0] - b[1][0]));
    if (yDivide == 0) {
      return int256[2]([int256(0), 0]);
    }

    int y = ((a[0][0] * a[1][1] - a[0][1] * a[1][0]) * (b[0][1] - b[1][1]) - (a[0][1] - a[1][1]) * (b[0][0] * b[1][1] - b[0][1] * b[1][0])) /
    yDivide;

    if (a[0][0] >= a[1][0]) {
      if (!MathUtils.between(a[1][0], x, a[0][0])) {return int256[2]([int256(0), 0]);}
    } else {
      if (!MathUtils.between(a[0][0], x, a[1][0])) {return int256[2]([int256(0), 0]);}
    }
    if (a[0][1] >= a[1][1]) {
      if (!MathUtils.between(a[1][1], y, a[0][1])) {return int256[2]([int256(0), 0]);}
    } else {
      if (!MathUtils.between(a[0][1], y, a[1][1])) {return int256[2]([int256(0), 0]);}
    }
    if (b[0][0] >= b[1][0]) {
      if (!MathUtils.between(b[1][0], x, b[0][0])) {return int256[2]([int256(0), 0]);}
    } else {
      if (!MathUtils.between(b[0][0], x, b[1][0])) {return int256[2]([int256(0), 0]);}
    }
    if (b[0][1] >= b[1][1]) {
      if (!MathUtils.between(b[1][1], y, b[0][1])) {return int256[2]([int256(0), 0]);}
    } else {
      if (!MathUtils.between(b[0][1], y, b[1][1])) {return int256[2]([int256(0), 0]);}
    }
    return [x, y];
  }

  function isEqual(int[2][2] memory a, int[2][2] memory b) internal pure returns (bool) {
    return b[0][0] == a[0][0] && b[0][1] != a[0][1] && b[1][0] == a[1][0] && b[1][1] != a[1][1];
  }

  function compareSegments(Sweepline storage sweepline, int[2][2] memory a, int[2][2] memory b) internal view returns (int8) {
    if (isEqual(a, b)) {
      return int8(0);
    }

    int deltaY = getY(a, sweepline.x) - getY(b, sweepline.x);

    if (MathUtils.abs(deltaY) > EPS) {
      return deltaY < 0 ? int8(- 1) : int8(1);
    } else {
      int aSlope = getSlope(a);
      int bSlope = getSlope(b);

      if (aSlope != bSlope) {
        if (sweepline.position == Position.BEFORE) {
          return aSlope > bSlope ? int8(- 1) : int8(1);
        } else {
          return aSlope > bSlope ? int8(1) : int8(- 1);
        }
      }
    }

    if (a[0][0] - b[0][0] != 0) {
      return a[0][0] - b[0][0] < 0 ? int8(- 1) : int8(1);
    }

    if (a[1][0] - b[1][0] != 0) {
      return a[1][0] - b[1][0] < 0 ? int8(- 1) : int8(1);
    }

    return int8(0);
  }

  function getSlope(int[2][2] memory segment) internal pure returns (int) {
    if (segment[0][0] == segment[1][0]) {
      return (segment[0][1] < segment[1][1]) ? MathUtils.INT256_MAX() : MathUtils.INT256_MIN();
    } else {
      return (segment[1][1] - segment[0][1]) / (segment[1][0] - segment[0][0]);
    }
  }

  function getY(int[2][2] memory segment, int x) internal pure returns (int) {
    if (x <= segment[0][0]) {
      return segment[0][1];
    } else if (x >= segment[1][0]) {
      return segment[1][1];
    }

    if ((x - segment[0][0]) > (segment[1][0] - x)) {
      int ifac = 1 ether * (x - segment[0][0]) / (segment[1][0] - segment[0][0]);
      return ((segment[0][1] * (1 ether - ifac)) / 1 ether) + ((segment[1][1] * ifac) / 1 ether);
    } else {
      int fac = 1 ether * (segment[1][0] - x) / (segment[1][0] - segment[0][0]);
      return ((segment[0][1] * fac) / 1 ether) + ((segment[1][1] * (1 ether - fac)) / 1 ether);
    }
  }

  function cmp(int x, int y) internal pure returns (int) {
    if (x == y) {
      return 0;
    }
    if (x < y) {
      return - 1;
    } else {
      return 1;
    }
  }

  function pointOnSegment(int[2] memory point, int[2] memory sp1, int[2] memory sp2) internal pure returns (bool) {
    // compare versus epsilon for floating point values, or != 0 if using integers
    if (MathUtils.abs((point[1] - sp1[1]) * (sp2[0] - sp1[0]) - (point[0] - sp1[0]) * (sp2[1] - sp1[1])) > POS_EPS) {
      return false;
    }

    int dotproduct = (point[0] - sp1[0]) * (sp2[0] - sp1[0]) + (point[1] - sp1[1]) * (sp2[1] - sp1[1]);
    if (dotproduct < 0) {
      return false;
    }

    int squaredlengthba = (sp2[0] - sp1[0]) * (sp2[0] - sp1[0]) + (sp2[1] - sp1[1]) * (sp2[1] - sp1[1]);
    if (dotproduct > squaredlengthba) {
      return false;
    }

    return true;
  }
}

library GeohashUtils {
  uint256 constant C1_GEOHASH = 31;
  uint256 constant C2_GEOHASH = 1023;
  uint256 constant C3_GEOHASH = 32767;
  uint256 constant C4_GEOHASH = 1048575;
  uint256 constant C5_GEOHASH = 33554431;
  uint256 constant C6_GEOHASH = 1073741823;
  uint256 constant C7_GEOHASH = 34359738367;
  uint256 constant C8_GEOHASH = 1099511627775;
  uint256 constant C9_GEOHASH = 35184372088831;
  uint256 constant C10_GEOHASH = 1125899906842623;
  uint256 constant C11_GEOHASH = 36028797018963967;
  uint256 constant C12_GEOHASH = 1152921504606846975;

  // bytes32("0123456789bcdefghjkmnpqrstuvwxyz")
  bytes32 constant GEOHASH5_MASK = 0x30313233343536373839626364656667686a6b6d6e707172737475767778797a;

  uint256 constant Z_RESERVED_MASK = uint256(0x0000000000000000000000000000000ffffffffffffffffffffffffffffffff);
  uint256 constant Z_HEIGHT_MASK =   uint256(0x0000000000000000000000000000000ffffffff000000000000000000000000);
  uint256 constant Z_INT32_MASK =    uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000);
  uint256 constant Z_GEOHASH5_MASK = uint256(0x000000000000000000000000000000000000000ffffffffffffffffffffffff);

  // -2_147_483_648
  int256 constant Z_MIN = int256(-2147483648);
  // 2_147_483_647
  int256 constant Z_MAX = int256(2147483647);

  function geohash5Precision(uint256 _geohash5) internal pure returns (uint8) {
    if (_geohash5 == 0) {
      return 0;
    } else if (_geohash5 <= C1_GEOHASH) {
      return 1;
    } else if (_geohash5 <= C2_GEOHASH) {
      return 2;
    } else if (_geohash5 <= C3_GEOHASH) {
      return 3;
    } else if (_geohash5 <= C4_GEOHASH) {
      return 4;
    } else if (_geohash5 <= C5_GEOHASH) {
      return 5;
    } else if (_geohash5 <= C6_GEOHASH) {
      return 6;
    } else if (_geohash5 <= C7_GEOHASH) {
      return 7;
    } else if (_geohash5 <= C8_GEOHASH) {
      return 8;
    } else if (_geohash5 <= C9_GEOHASH) {
      return 9;
    } else if (_geohash5 <= C10_GEOHASH) {
      return 10;
    } else if (_geohash5 <= C11_GEOHASH) {
      return 11;
    } else if (_geohash5 <= C12_GEOHASH) {
      return 12;
    } else {
      revert("Invalid geohash5");
    }
  }

  function geohash5ToGeohashString(uint256 _input) pure internal returns (bytes32) {
    if (_input > C12_GEOHASH) {
      revert("Number exceeds the limit");
    }

    uint256 num = _input;
    bytes32 output;
    bytes32 fiveOn = bytes32(uint256(31));
    uint8 counter = 0;

    while (num != 0) {
      output = output >> 8;
      uint256 d = uint256(bytes32(num) & fiveOn);
      output = output ^ (bytes1(GEOHASH5_MASK[d]));
      num = num >> 5;
      counter++;
    }

    return output;
  }

  function geohash5ToGeohash5z(int256 _height, uint256 _geohash5) pure internal returns (uint256) {
    requireHeightValid(_height);
    uint256 shiftedHeight = uint256(_height) << 96;

    return (_geohash5 | shiftedHeight) & Z_RESERVED_MASK;
  }

  function geohash5ToGeohash5zBytes32(int256 _height, uint256 _geohash5) pure internal returns (bytes32) {
    return bytes32(geohash5ToGeohash5z(_height, _geohash5));
  }

  function geohash5zToHeightAndGeohash5(uint256 _geohash5z) pure internal returns (int256 height, uint256 geohash5) {
    height = int32((_geohash5z & Z_HEIGHT_MASK) >> 96);
    geohash5 = _geohash5z & Z_GEOHASH5_MASK;
  }

  function geohash5zToGeohash5(uint256 _geohash5z) pure internal returns (uint256) {
    return _geohash5z & Z_GEOHASH5_MASK;
  }

  function geohash5zToHeight(uint256 _geohash5z) pure internal returns (int256) {
    return int32((_geohash5z & Z_HEIGHT_MASK) >> 96);
  }

  function geohash5zToHeightAndGeohash5Bytes32(
    uint256 _geohash5z
  )
    pure
    internal
    returns (bytes32 height, bytes32 geohash5)
  {
    (int256 x, uint256 y) = geohash5zToHeightAndGeohash5(_geohash5z);
    return (bytes32(x), bytes32(y));
  }

  function requireHeightValid(int256 _height) pure internal {
    require(Z_MIN <= _height && _height <= Z_MAX, "GeohashUtils: height overflow");
  }

  function isHeightValid(int256 _height) pure internal returns (bool) {
    return (Z_MIN <= _height && _height <= Z_MAX);
  }

  function maxGeohashNumber() internal pure returns (uint256) {
    return C12_GEOHASH;
  }
}

library TrigonometryUtils {
  int constant PI = 3141592653589793300;
  int constant ONEQTR_PI = 785398163397448300;
  int constant THRQTR_PI = 2356194490192345000;

  function getSinOfRad(int256 x) internal pure returns (int256) {
    int q;
    int s = 0;
    int N = 100;
    int n;
    q = x;
    for (n = 1; n <= N; n++) {
      s += q;

      q *= ((- 1) * x * x) / ((2 * n) * (2 * n + 1) * 1 ether);
      q /= 1 ether;
      if (q == 0) {
        return s;
      }
    }
    return s;
  }

  function getSinOfDegree(int256 degree) internal pure returns (int256) {
    int q;
    int s = 0;
    int N = 100;
    int n;

    int x = degree * (PI / 180) / 1 ether;
    q = x;

    for (n = 1; n <= N; n++) {
      s += q;

      q *= ((- 1) * x * x) / ((2 * n) * (2 * n + 1) * 1 ether);
      q /= 1 ether;
      if (q == 0) {
        return s;
      }
    }
    return s;
  }

  function sin(int256 radians) internal pure returns (int256) {
    return getSinOfRad(radians);
  }

  function cos(int256 radians) internal pure returns (int256) {
    return getSinOfRad(radians + (PI / 2));
  }

  function tan(int256 radians) internal pure returns (int256) {
    return (sin(radians) * 1 ether) / cos(radians);
  }

  function atan(int256 input) internal pure returns (int256) {
    int sign = 1 ether;
    int y = 0;
    int x = input;
    if (x == 0) {
      return 0;
    }
    if (x > 0) {
      x = div((x - 1 ether), (x + 1 ether));
      y = mul(x, x);
      x = mul((mul((mul((mul((mul((mul((mul((mul((mul(2866225700000000, y) - 16165736699999998), y) + 42909613800000000), y) - 75289640000000000), y) + 106562639300000000), y) - 142088994400000000), y) + 199935508500000000), y) - 333331452800000000), y) + 1 ether), x);
      x = 785398163397000000 + mul(sign, x);
    } else {
      int a = 0;
      // 1st term
      int sum = 0;
      int n = 50;

      // special cases
      if (x == 1)
        return PI / 4;
      if (x == - 1)
        return - PI / 4;

      if (n > 0) {
        if ((x < - 1 ether) || (x > 1 ether)) {
          // constant term
          if (x > 1)
            sum = PI / 2;
          else
            sum = - PI / 2;
          // initial value of a
          a = - (1 ether ** 2) / x;
          for (int i = 1; i <= n; i++) {
            sum += a;
            a *= - 1 * ((2 * i - 1) * 1 ether ** 2) / ((2 * i + 1) * ((x * x) / 1 ether));
            a /= 1 ether;
            if (a == 0) {
              break;
            }
            // next term from last
          }
        } else {// -1 < x < 1
          // constant term
          sum = 0;
          // initial value of a
          a = x;
          for (int j = 1; j <= n; j++) {
            sum += a;
            a *= - 1 * (2 * j - 1) * ((x * x) / 1 ether) / (2 * j + 1);
            a /= 1 ether;
            if (a == 0) {
              break;
            }
            // next term from last
          }
        }
      }
      return sum;
    }

    return x;
  }

  function mul(int a, int b) internal pure returns(int) {
    return (a * b) / 1 ether;
  }

  function div(int a, int b) internal pure returns(int) {
    return (a * 1 ether) / b;
  }

  function atan2(int256 y, int256 x) internal pure returns (int256) {
    int u = atan((y * 1 ether) / x);
    if (x < 0) {// 2nd, 3rd quadrant
      if (u > 0) // will go to 3rd quadrant
        u -= PI;
      else
        u += PI;
    }
    return u;
  }

  /**
  * Limitations:
  * - no more than 0.999(9) eth
  **/
  function atanh(int256 x) internal pure returns (int256) {
    return MathUtils.logE(((1 ether + x) * 1 ether) / (1 ether - x)) / 2;
  }

  function cosh(int256 radians) internal pure returns (int256) {
    int256 y = MathUtils.exp(radians);
    return (y + (1 ether * 1 ether) / y) / 2;
  }

  function sinh(int256 radians) internal pure returns (int256) {
    int256 y = MathUtils.exp(radians);
    return (y - (1 ether * 1 ether) / y) / 2;
  }

  function asinh(int256 x) internal pure returns (int256) {
    return MathUtils.logE(x + MathUtils.sqrt((x * x) / 1 ether + 1 ether));
  }

  function degreeToRad(int256 degree) internal pure returns (int256) {
    return degree * (PI / 180) / 1 ether;
  }

  function radToDegree(int256 radians) internal pure returns (int256) {
    return radians * (180 / PI) * 1 ether;
  }
}

library LandUtils {

  struct LatLonData {
    mapping(uint256 => int256[2]) latLonByGeohash;
    mapping(bytes32 => mapping(uint8 => uint256)) geohashByLatLonHash;

    mapping(uint256 => int256[3]) utmByGeohash;
    mapping(bytes32 => int256[3]) utmByLatLonHash;
  }

  function latLonIntervalToLatLon(
    int256[2] memory latInterval,
    int256[2] memory lonInterval
  )
    public
    pure
    returns (int256 lat, int256 lon)
  {
    lat = (latInterval[0] + latInterval[1]) / 2;
    lon = (lonInterval[0] + lonInterval[1]) / 2;
  }

  function geohash5ToLatLonArr(uint256 _geohash5) public pure returns (int256[2] memory) {
    (int256 lat, int256 lon) = geohash5ToLatLon(_geohash5);
    return [lat, lon];
  }

  /**
    Decode the geohash to its exact values, including the error
    margins of the result.  Returns four float values: latitude,
    longitude, the plus/minus error for latitude (as a positive
    number) and the plus/minus error for longitude (as a positive
    number).
  **/
  function geohash5ToLatLon(uint256 _geohash5) public pure returns (int256 lat, int256 lon) {
    if (_geohash5 > GeohashUtils.maxGeohashNumber()) {
      revert("Number exceeds the limit");
    }

    int256[2] memory lat_interval = [int256(- 90 ether), int256(90 ether)];
    int256[2] memory lon_interval = [int256(- 180 ether), int256(180 ether)];

    uint8[5] memory mask_arr = [16, 8, 4, 2, 1];

    bool is_even = true;

    uint256 capacity = GeohashUtils.geohash5Precision(_geohash5);
    uint256 num;
    uint256 cd;
    uint8 mask;

    while (capacity > 0) {
      capacity--;

      num = _geohash5 >> 5 * capacity;
      cd = uint256(bytes32(uint256(num)) & bytes32(uint256(31)));

      for (uint8 i = 0; i < mask_arr.length; i++) {
        mask = mask_arr[i];

        if (is_even) {
          // adds longitude info
          if (cd & mask != 0) {
            lon_interval[0] = (lon_interval[0] + lon_interval[1]) / 2;
          } else {
            lon_interval[1] = (lon_interval[0] + lon_interval[1]) / 2;
          }
        } else {
          // adds latitude info
          if (cd & mask != 0) {
            lat_interval[0] = (lat_interval[0] + lat_interval[1]) / 2;
          } else {
            lat_interval[1] = (lat_interval[0] + lat_interval[1]) / 2;
          }
        }

        is_even = !is_even;
      }
    }

    return latLonIntervalToLatLon(lat_interval, lon_interval);
  }

  function latLonToGeohash5(int256 _lat, int256 _lon, uint8 _precision) public pure returns (uint256) {
    int256[2] memory lat_interval = [int256(- 90 ether), int256(90 ether)];
    int256[2] memory lon_interval = [int256(- 180 ether), int256(180 ether)];

    uint8[5] memory bits = [16, 8, 4, 2, 1];

    uint8 bit = 0;
    uint8 ch = 0;

    int256 mid;
    bool even = true;

    uint256 geohash;
    uint8 precision = _precision;
    while (precision > 0) {
      if (even) {
        mid = (lon_interval[0] + lon_interval[1]) / 2;
        if (_lon > mid) {
          ch |= bits[bit];
          lon_interval[0] = mid;
        } else {
          lon_interval[1] = mid;
        }
      } else {
        mid = (lat_interval[0] + lat_interval[1]) / 2;
        if (_lat > mid) {
          ch |= bits[bit];
          lat_interval[0] = mid;
        } else {
          lat_interval[1] = mid;
        }
      }

      even = !even;

      if (bit < 4) {
        bit += 1;
      } else {
        precision -= 1;
        geohash += uint256(bytes32(uint256(ch)) & bytes32(uint256(31))) << 5 * precision;
        bit = 0;
        ch = 0;
      }
    }
    return geohash;
  }

  function UtmUncompress(int[3] memory compressedUtm) internal pure returns (int x, int y, int scale, int latBand, int zone, int isNorth) {
    x = compressedUtm[0];
    y = compressedUtm[1];

    latBand = compressedUtm[2] / (1 ether * 10 ** 9);
    isNorth = compressedUtm[2] / (1 ether * 10 ** 6) - latBand * 10 ** 3;
    zone = compressedUtm[2] / (1 ether * 10 ** 3) - isNorth * 10 ** 3 - latBand * 10 ** 6;
    scale = compressedUtm[2] - (zone * 1 ether * 10 ** 3) - (isNorth * 1 ether * 10 ** 6) - (latBand * 1 ether * 10 ** 9);
  }

  function latLonToUtmCompressed(int _lat, int _lon) public pure returns (int[3] memory) {
    (int x, int y, int scale, int latBand, int zone, bool isNorth) = latLonToUtm(_lat, _lon);

    return [x, y, scale + (zone * 1 ether * 10 ** 3) + (int(isNorth ? 1 : 0) * 1 ether * 10 ** 6) + (latBand * 1 ether * 10 ** 9)];
  }

  // WGS 84: a = 6378137, b = 6356752.314245, f = 1/298.257223563;
  int constant ellipsoidalA = 6378137000000000000000000;
  int constant ellipsoidalB = 6356752314245000000000000;
  int constant ellipsoidalF = 3352810664747481;

  int constant falseEasting = 500000 ether;
  int constant falseNorthing = 10000000 ether;
  int constant k0 = 999600000000000000;

  // 2πA is the circumference of a meridian
  int constant A = 6367449145823415000000000;
  int constant AmulK0 = 6364902166165086000000000;
  // eccentricity
  int constant eccentricity = 81819190842621490;

  // UTM scale on the central meridian
  // latitude ± from equator
  // longitude ± from central meridian
  function latLonToUtm(int256 _lat, int256 _lon)
    public
    pure
    returns
    (
      int x,
      int y,
      int scale,
      int latBand,
      int zone,
      bool isNorth
    )
  {
    require(- 80 ether <= _lat && _lat <= 84 ether, "Outside UTM limits");

    int L0;
    (zone, L0, latBand) = getUTM_L0_zone(_lat, _lon);

    // note a is one-based array (6th order Krüger expressions)
    int[7] memory a = [int(0), 837731820624470, 760852777357, 1197645503, 2429171, 5712, 15];
    int[39] memory variables;

    //  variables[0] - F
    //  variables[1] - t
    //  variables[2] - o
    //  variables[3] - ti
    variables[0] = TrigonometryUtils.degreeToRad(_lat);
    variables[1] = TrigonometryUtils.tan(variables[0]);
    // t ≡ tanF, ti ≡ tanFʹ; prime (ʹ) indicates angles on the conformal sphere
    variables[14] = MathUtils.sqrt(1 ether + (variables[1] * variables[1]) / 1 ether);
    variables[2] = TrigonometryUtils.sinh((eccentricity * TrigonometryUtils.atanh((eccentricity * variables[1]) / variables[14])) / 1 ether);
    variables[3] = (variables[1] * MathUtils.sqrt(1 ether + (variables[2] * variables[2]) / 1 ether)) / 1 ether - (variables[2] * variables[14]) / 1 ether;

    //  variables[4] - tanL
    //  variables[5] - MathUtils.sqrt(((ti * ti) / 1 ether) + ((cosL * cosL) / 1 ether))
    //  variables[6] - Ei
    //  variables[7] - ni
    (variables[4], variables[6], variables[7], variables[5]) = getUTM_tanL_Ei_ni(_lon, L0, variables[3]);

    variables[15] = TrigonometryUtils.sin(2 * 1 * variables[6]);
    variables[16] = TrigonometryUtils.sin(2 * 2 * variables[6]);
    variables[17] = TrigonometryUtils.sin(2 * 3 * variables[6]);
    variables[18] = TrigonometryUtils.sin(2 * 4 * variables[6]);
    variables[19] = TrigonometryUtils.sin(2 * 5 * variables[6]);
    variables[20] = TrigonometryUtils.sin(2 * 6 * variables[6]);

    variables[21] = TrigonometryUtils.cosh(2 * 1 * variables[7]);
    variables[22] = TrigonometryUtils.cosh(2 * 2 * variables[7]);
    variables[23] = TrigonometryUtils.cosh(2 * 3 * variables[7]);
    variables[24] = TrigonometryUtils.cosh(2 * 4 * variables[7]);
    variables[25] = TrigonometryUtils.cosh(2 * 5 * variables[7]);
    variables[26] = TrigonometryUtils.cosh(2 * 6 * variables[7]);

    variables[27] = TrigonometryUtils.cos(2 * 1 * variables[6]);
    variables[28] = TrigonometryUtils.cos(2 * 2 * variables[6]);
    variables[29] = TrigonometryUtils.cos(2 * 3 * variables[6]);
    variables[30] = TrigonometryUtils.cos(2 * 4 * variables[6]);
    variables[31] = TrigonometryUtils.cos(2 * 5 * variables[6]);
    variables[32] = TrigonometryUtils.cos(2 * 6 * variables[6]);

    variables[33] = TrigonometryUtils.sinh(2 * 1 * variables[7]);
    variables[34] = TrigonometryUtils.sinh(2 * 2 * variables[7]);
    variables[35] = TrigonometryUtils.sinh(2 * 3 * variables[7]);
    variables[36] = TrigonometryUtils.sinh(2 * 4 * variables[7]);
    variables[37] = TrigonometryUtils.sinh(2 * 5 * variables[7]);
    variables[38] = TrigonometryUtils.sinh(2 * 6 * variables[7]);

    //  variables[8] - E
    /* solium-disable-next-line */
    variables[8] = variables[6]
    + (a[1] * (variables[15] * variables[21]) / 1 ether) / 1 ether
    + (a[2] * (variables[16] * variables[22]) / 1 ether) / 1 ether
    + (a[3] * (variables[17] * variables[23]) / 1 ether) / 1 ether
    + (a[4] * (variables[18] * variables[24]) / 1 ether) / 1 ether
    + (a[5] * (variables[19] * variables[25]) / 1 ether) / 1 ether
    /* solium-disable-next-line */
    + (a[6] * (variables[20] * variables[26]) / 1 ether) / 1 ether;

    //  variables[9] - n
    /* solium-disable-next-line */
    variables[9] = variables[7]
    + (a[1] * ((variables[27] * variables[33]) / 1 ether)) / 1 ether
    + (a[2] * ((variables[28] * variables[34]) / 1 ether)) / 1 ether
    + (a[3] * ((variables[29] * variables[35]) / 1 ether)) / 1 ether
    + (a[4] * ((variables[30] * variables[36]) / 1 ether)) / 1 ether
    + (a[5] * ((variables[31] * variables[37]) / 1 ether)) / 1 ether
    /* solium-disable-next-line */
    + (a[6] * ((variables[32] * variables[38]) / 1 ether)) / 1 ether;


    x = (AmulK0 * variables[9]) / 1 ether;
    y = (AmulK0 * variables[8]) / 1 ether;
    // ------------

    // shift x/y to false origins
    x = x + falseEasting;
    // make x relative to false easting
    if (y < 0) {
      y = y + falseNorthing;
      // make y in southern hemisphere relative to false northing
    }

    // round to reasonable precision
    x = MathUtils.toFixedInt(x, 6);
    // nm precision
    y = MathUtils.toFixedInt(y, 6);

    // ---- convergence: Karney 2011 Eq 23, 24

    //  variables[10] - pi
    //  variables[11] - qi
    //  variables[12] - V
    /* solium-disable-next-line */
    variables[10] = 1 ether
    + 2 * 1 * ((a[1] * (variables[27] * variables[21]) / 1 ether) / 1 ether)
    + 2 * 2 * ((a[2] * (variables[28] * variables[22]) / 1 ether) / 1 ether)
    + 2 * 3 * ((a[3] * (variables[29] * variables[23]) / 1 ether) / 1 ether)
    + 2 * 4 * ((a[4] * (variables[30] * variables[24]) / 1 ether) / 1 ether)
    + 2 * 5 * ((a[5] * (variables[31] * variables[25]) / 1 ether) / 1 ether)
    /* solium-disable-next-line */
    + 2 * 6 * ((a[6] * (variables[32] * variables[26]) / 1 ether) / 1 ether);

    /* solium-disable-next-line */
    variables[11] = 2 * 1 * ((a[1] * ((variables[15] * variables[33]) / 1 ether)) / 1 ether)
    + 2 * 2 * ((a[2] * ((variables[16] * variables[34]) / 1 ether)) / 1 ether)
    + 2 * 3 * ((a[3] * ((variables[17] * variables[35]) / 1 ether)) / 1 ether)
    + 2 * 4 * ((a[4] * ((variables[18] * variables[36]) / 1 ether)) / 1 ether)
    + 2 * 5 * ((a[5] * ((variables[19] * variables[37]) / 1 ether)) / 1 ether)
    /* solium-disable-next-line */
    + 2 * 6 * ((a[6] * ((variables[20] * variables[38]) / 1 ether)) / 1 ether);

    variables[12] = getUTM_V(variables[3], variables[4], variables[11], variables[10]);

    // ---- scale: Karney 2011 Eq 25

    //  variables[13] - k
    variables[13] = getUTM_k(variables[0], variables[14], variables[11], variables[10], variables[5]);

    //    convergence = MathUtils.toFixedInt(TrigonometryUtils.radToDegree(variables[12]), 9);
    scale = MathUtils.toFixedInt(variables[13], 12);

    isNorth = _lat >= 0;
    // hemisphere
  }

  // TrigonometryUtils.degreeToRad(6 ether)
  int constant sixDegreeRad = 104719755119659776;

  // TrigonometryUtils.degreeToRad(((zone - 1) * 6 ether) - 180 ether + 3 ether)
  function L0byZone() public pure returns (int[61] memory) {
    return [int(- 3193952531149623000), - 3089232776029963300, - 2984513020910303000, - 2879793265790643700, - 2775073510670984000, - 2670353755551324000, - 2565634000431664600, - 2460914245312004000, - 2356194490192345000, - 2251474735072684800, - 2146754979953025500, - 2042035224833365500, - 1937315469713705700, - 1832595714594046200, - 1727875959474386400, - 1623156204354726400, - 1518436449235066600, - 1413716694115406800, - 1308996938995747300, - 1204277183876087300, - 1099557428756427600, - 994837673636767700, - 890117918517108000, - 785398163397448300, - 680678408277788400, - 575958653158128800, - 471238898038469000, - 366519142918809200, - 261799387799149400, - 157079632679489660, - 52359877559829880, 52359877559829880, 157079632679489660, 261799387799149400, 366519142918809200, 471238898038469000, 575958653158128800, 680678408277788400, 785398163397448300, 890117918517108000, 994837673636767700, 1099557428756427600, 1204277183876087300, 1308996938995747300, 1413716694115406800, 1518436449235066600, 1623156204354726400, 1727875959474386400, 1832595714594046200, 1937315469713705700, 2042035224833365500, 2146754979953025500, 2251474735072684800, 2356194490192345000, 2460914245312004000, 2565634000431664600, 2670353755551324000, 2775073510670984000, 2879793265790643700, 2984513020910303000, 3089232776029963300];
  }

  function getUTM_L0_zone(int _lat, int _lon) public pure returns (int zone, int L0, int latBand) {
    zone = ((_lon + 180 ether) / 6 ether) + 1;
    // longitudinal zone
    L0 = TrigonometryUtils.degreeToRad(((zone - 1) * 6 ether) - 180 ether + 3 ether);
    // longitude of central meridian

    // ---- handle Norway/Svalbard exceptions
    // grid zones are 8° tall; 0°N is offset 10 into latitude bands array
    latBand = _lat / 8 ether + 10;

    // adjust zone & central meridian for Norway
    if (zone == 31 && latBand == 17 && _lon >= 3) {
      zone++;
      L0 += sixDegreeRad;
    }
    // adjust zone & central meridian for Svalbard
    if (zone == 32 && (latBand == 19 || latBand == 20) && _lon < 9 ether) {
      zone--;
      L0 -= sixDegreeRad;
    }
    if (zone == 32 && (latBand == 19 || latBand == 20) && _lon >= 9 ether) {
      zone++;
      L0 += sixDegreeRad;
    }
    if (zone == 34 && (latBand == 19 || latBand == 20) && _lon < 21 ether) {
      zone--;
      L0 -= sixDegreeRad;
    }
    if (zone == 34 && (latBand == 19 || latBand == 20) && _lon >= 21 ether) {
      zone++;
      L0 += sixDegreeRad;
    }
    if (zone == 36 && (latBand == 19 || latBand == 20) && _lon < 33 ether) {
      zone--;
      L0 -= sixDegreeRad;
    }
    if (zone == 36 && (latBand == 19 || latBand == 20) && _lon >= 33 ether) {
      zone++;
      L0 += sixDegreeRad;
    }
  }

  function getUTM_tanL_Ei_ni(int _lon, int L0, int ti) public pure returns (int tanL, int Ei, int ni, int si) {
    int L = TrigonometryUtils.degreeToRad(_lon) - L0;
    int cosL = TrigonometryUtils.cos(L);
    tanL = TrigonometryUtils.tan(L);

    Ei = TrigonometryUtils.atan2(ti, cosL);
    si = MathUtils.sqrt(((ti * ti) / 1 ether) + ((cosL * cosL) / 1 ether));
    ni = TrigonometryUtils.asinh((TrigonometryUtils.sin(L) * 1 ether) / si);
  }

  function getUTM_V(int ti, int tanL, int qi, int pi) public pure returns (int) {
    return TrigonometryUtils.atan((((ti * 1 ether) / MathUtils.sqrt(1 ether + (ti * ti) / 1 ether)) * tanL) / 1 ether) + TrigonometryUtils.atan2(qi, pi);
  }

  function getUTM_k(int F, int st, int pi, int qi, int si) public pure returns (int) {
    int sinF = TrigonometryUtils.sin(F);
    return (k0 * (
    /* solium-disable-next-line */
    (((((MathUtils.sqrt(1 ether - (((eccentricity * eccentricity) / 1 ether) * ((sinF * sinF) / 1 ether)) / 1 ether) * st) / si) * A) / ellipsoidalA)
    * MathUtils.sqrt((pi * pi) / 1 ether + (qi * qi) / 1 ether)) / 1 ether
    )) / 1 ether;
  }
}

library PolygonUtils {

  int256 public constant RADIUS = 6378137;
  int256 public constant PI = 3141592653589793300;

  struct LatLonData {
    mapping(uint => int256[2]) latLonByGeohash;
  }

  struct CoorsPolygon {
    int256[2][] points;
  }

  struct UtmPolygon {
    int256[3][] points;
  }

  function geohash5ToLatLonArr(LatLonData storage self, uint256 _geohash5) internal returns (int256[2] memory) {
    (int256 lat, int256 lon) = geohash5ToLatLon(self, _geohash5);
    return [lat, lon];
  }

  function geohash5ToLatLon(LatLonData storage self, uint256 _geohash5) internal returns (int256 lat, int256 lon) {
    if (self.latLonByGeohash[_geohash5][0] == 0) {
      self.latLonByGeohash[_geohash5] = LandUtils.geohash5ToLatLonArr(_geohash5);
    }

    return (self.latLonByGeohash[_geohash5][0], self.latLonByGeohash[_geohash5][1]);
  }

  function isInside(LatLonData storage self, uint _geohash5, uint256[] memory _polygon) public returns (bool) {
    (int256 x, int256 y) = geohash5ToLatLon(self, _geohash5);

    bool inside = false;
    uint256 j = _polygon.length - 1;

    for (uint256 i = 0; i < _polygon.length; i++) {
      (int256 xi, int256 yi) = geohash5ToLatLon(self, _polygon[i]);
      (int256 xj, int256 yj) = geohash5ToLatLon(self, _polygon[j]);

      bool intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  function isInsideWithoutCache(
    uint256 _geohash5,
    uint256[] memory _polygon
  )
    public
    pure
    returns (bool)
  {
    (int256 x, int256 y) = LandUtils.geohash5ToLatLon(_geohash5);

    bool inside = false;
    uint256 j = _polygon.length - 1;

    for (uint256 i = 0; i < _polygon.length; i++) {
      (int256 xi, int256 yi) = LandUtils.geohash5ToLatLon(_polygon[i]);
      (int256 xj, int256 yj) = LandUtils.geohash5ToLatLon(_polygon[j]);

      bool intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  function isInsideCoors(int256[2] memory _point, CoorsPolygon storage _polygon) internal view returns (bool) {
    bool inside = false;
    uint256 j = _polygon.points.length - 1;

    for (uint256 i = 0; i < _polygon.points.length; i++) {
      bool intersect = ((_polygon.points[i][1] > _point[1]) != (_polygon.points[j][1] > _point[1])) && (_point[0] < (_polygon.points[j][0] - _polygon.points[i][0]) * (_point[1] - _polygon.points[i][1]) / (_polygon.points[j][1] - _polygon.points[i][1]) + _polygon.points[i][0]);
      if (intersect) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  function isClockwise(int[2] memory firstPoint, int[2] memory secondPoint, int[2] memory thirdPoint) internal pure returns (bool) {
    return (((secondPoint[0] - firstPoint[0]) * (secondPoint[1] + firstPoint[1])) +
    ((thirdPoint[0] - secondPoint[0]) * (thirdPoint[1] + secondPoint[1]))) > 0;
  }

  function getUtmArea(UtmPolygon memory _polygon) internal pure returns (uint result) {
    int area = 0;
    // Accumulates area in the loop
    uint j = _polygon.points.length - 1;
    // The last vertex is the 'previous' one to the first

    int scaleSum = 0;
    int firstScale;
    bool differentScales = false;
    int firstPointZone;
    for (uint i = 0; i < _polygon.points.length; i++) {
      area += ((_polygon.points[j][0] + _polygon.points[i][0]) * (_polygon.points[j][1] - _polygon.points[i][1])) / 1 ether;

      (,, int scale,, int zone,) = LandUtils.UtmUncompress(_polygon.points[i]);

      if (i == 0) {
        firstPointZone = zone;
        firstScale = (scale / int(10 ** 13)) * int(10 ** 13);
      } else {
        if (!differentScales) {
          differentScales = firstScale != (scale / int(10 ** 13)) * int(10 ** 13);
        }
      }

      require(zone == firstPointZone, "All points should belongs to same zone");

      scaleSum += scale;
      j = i;
      //j is previous vertex to i
    }
    if (area < 0) {
      area *= - 1;
    }

    if (differentScales) {
      // if scale is different with 0.00001 accuracy - apply scale
      result = (uint(area * 1 ether) / (uint(scaleSum / int(_polygon.points.length)) ** uint(2)) / 1 ether) / 2;
    } else {
      // else if scale the same - don't apply scale
      result = uint(area / 2);
    }
  }

  function rad(int angle) internal pure returns (int) {
    return angle * PI / 180 / 1 ether;
  }

  function isSelfIntersected(CoorsPolygon storage _polygon) public view returns (bool) {
    for (uint256 i = 0; i < _polygon.points.length; i++) {
      int256[2] storage iaPoint = _polygon.points[i];
      uint256 ibIndex = i == _polygon.points.length - 1 ? 0 : i + 1;
      int256[2] storage ibPoint = _polygon.points[ibIndex];

      for (uint256 k = 0; k < _polygon.points.length; k++) {
        int256[2] storage kaPoint = _polygon.points[k];
        uint256 kbIndex = k == _polygon.points.length - 1 ? 0 : k + 1;
        int256[2] storage kbPoint = _polygon.points[kbIndex];

        int256[2] memory intersectionPoint = SegmentUtils.findSegmentsIntersection([iaPoint, ibPoint], [kaPoint, kbPoint]);
        if (intersectionPoint[0] == 0 && intersectionPoint[1] == 0) {
          continue;
        }
        /* solium-disable-next-line */
        if (PointUtils.isEqual(intersectionPoint, iaPoint) || PointUtils.isEqual(intersectionPoint, ibPoint)
        || PointUtils.isEqual(intersectionPoint, kaPoint) || PointUtils.isEqual(intersectionPoint, kbPoint)) {
          continue;
        }
        return true;
      }
    }
    return false;
  }
}

interface IACL {
  function setRole(bytes32 _role, address _candidate, bool _allow) external;
  function hasRole(address _candidate, bytes32 _role) external view returns (bool);
}

interface IPPGlobalRegistry {
  function setContract(bytes32 _key, address _value) external;

  // GETTERS
  function getContract(bytes32 _key) external view returns (address);
  function getACL() external view returns (IACL);
  function getGaltTokenAddress() external view returns (address);
  function getPPTokenRegistryAddress() external view returns (address);
  function getPPLockerRegistryAddress() external view returns (address);
  function getPPMarketAddress() external view returns (address);
}

interface IPPTokenController {
  event Mint(address indexed to, uint256 indexed tokenId);
  event SetGeoDataManager(address indexed geoDataManager);
  event SetContourVerificationManager(address indexed contourVerificationManager);
  event SetFeeManager(address indexed feeManager);
  event SetFeeCollector(address indexed feeCollector);
  event ReportCVMisbehaviour(uint256 tokenId);
  event NewProposal(
    uint256 indexed proposalId,
    uint256 indexed tokenId,
    address indexed creator
  );
  event ProposalExecuted(uint256 indexed proposalId);
  event ProposalExecutionFailed(uint256 indexed proposalId);
  event ProposalApproval(
    uint256 indexed proposalId,
    uint256 indexed tokenId
  );
  event ProposalRejection(
    uint256 indexed proposalId,
    uint256 indexed tokenId
  );
  event ProposalCancellation(
    uint256 indexed proposalId,
    uint256 indexed tokenId
  );
  event SetMinter(address indexed minter);
  event SetBurner(address indexed burner);
  event SetBurnTimeout(uint256 indexed tokenId, uint256 timeout);
  event InitiateTokenBurn(uint256 indexed tokenId, uint256 timeoutAt);
  event BurnTokenByTimeout(uint256 indexed tokenId);
  event CancelTokenBurn(uint256 indexed tokenId);
  event SetFee(bytes32 indexed key, uint256 value);
  event WithdrawEth(address indexed to, uint256 amount);
  event WithdrawErc20(address indexed to, address indexed tokenAddress, uint256 amount);
  event UpdateContourUpdatedAt(uint256 indexed tokenId, uint256 timestamp);
  event UpdateDetailsUpdatedAt(uint256 indexed tokenId, uint256 timestamp);

  enum PropertyInitialSetupStage {
    PENDING,
    DETAILS,
    DONE
  }

  function contourVerificationManager() external view returns (address);
  function fees(bytes32) external view returns (uint256);
  function setBurner(address _burner) external;
  function setGeoDataManager(address _geoDataManager) external;
  function setFeeManager(address _feeManager) external;
  function setFeeCollector(address _feeCollector) external;
  function setBurnTimeoutDuration(uint256 _tokenId, uint256 _duration) external;
  function setFee(bytes32 _key, uint256 _value) external;
  function withdrawErc20(address _tokenAddress, address _to) external;
  function withdrawEth(address payable _to) external;
  function initiateTokenBurn(uint256 _tokenId) external;
  function cancelTokenBurn(uint256 _tokenId) external;
  function burnTokenByTimeout(uint256 _tokenId) external;
  function reportCVMisbehaviour(uint256 _tokenId) external;
  function propose(bytes calldata _data, string calldata _dataLink) external payable;
  function approve(uint256 _proposalId) external;
  function execute(uint256 _proposalId) external;
  function fetchTokenId(bytes calldata _data) external pure returns (uint256 tokenId);
  function() external payable;
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

interface IPPToken {
  event SetBaseURI(string baseURI);
  event SetContractDataLink(string indexed dataLink);
  event SetLegalAgreementIpfsHash(bytes32 legalAgreementIpfsHash);
  event SetController(address indexed controller);
  event SetDetails(
    address indexed geoDataManager,
    uint256 indexed privatePropertyId
  );
  event SetContour(
    address indexed geoDataManager,
    uint256 indexed privatePropertyId
  );
  event SetHumanAddress(uint256 indexed tokenId, string humanAddress);
  event SetDataLink(uint256 indexed tokenId, string dataLink);
  event SetLedgerIdentifier(uint256 indexed tokenId, bytes32 ledgerIdentifier);
  event SetVertexRootHash(uint256 indexed tokenId, bytes32 ledgerIdentifier);
  event SetVertexStorageLink(uint256 indexed tokenId, string vertexStorageLink);
  event SetArea(uint256 indexed tokenId, uint256 area, AreaSource areaSource);
  event SetExtraData(bytes32 indexed key, bytes32 value);
  event SetPropertyExtraData(uint256 indexed propertyId, bytes32 indexed key, bytes32 value);
  event Mint(address indexed to, uint256 indexed privatePropertyId);
  event Burn(address indexed from, uint256 indexed privatePropertyId);

  enum AreaSource {
    USER_INPUT,
    CONTRACT
  }

  enum TokenType {
    NULL,
    LAND_PLOT,
    BUILDING,
    ROOM,
    PACKAGE
  }

  struct Property {
    uint256 setupStage;

    // (LAND_PLOT,BUILDING,ROOM) Type cannot be changed after token creation
    TokenType tokenType;
    // Geohash5z (x,y,z)
    uint256[] contour;
    // Meters above the sea
    int256 highestPoint;

    // USER_INPUT or CONTRACT
    AreaSource areaSource;
    // Calculated either by contract (for land plots and buildings) or by manual input
    // in sq. meters (1 sq. meter == 1 eth)
    uint256 area;

    bytes32 ledgerIdentifier;
    string humanAddress;
    string dataLink;

    // Reserved for future use
    bytes32 vertexRootHash;
    string vertexStorageLink;
  }

  // PERMISSIONED METHODS

  function setContractDataLink(string calldata _dataLink) external;
  function setLegalAgreementIpfsHash(bytes32 _legalAgreementIpfsHash) external;
  function setController(address payable _controller) external;
  function setDetails(
    uint256 _tokenId,
    TokenType _tokenType,
    AreaSource _areaSource,
    uint256 _area,
    bytes32 _ledgerIdentifier,
    string calldata _humanAddress,
    string calldata _dataLink
  )
    external;

  function setContour(
    uint256 _tokenId,
    uint256[] calldata _contour,
    int256 _highestPoint
  )
    external;

  function setArea(uint256 _tokenId, uint256 _area, AreaSource _areaSource) external;
  function setLedgerIdentifier(uint256 _tokenId, bytes32 _ledgerIdentifier) external;
  function setDataLink(uint256 _tokenId, string calldata _dataLink) external;
  function setVertexRootHash(uint256 _tokenId, bytes32 _vertexRootHash) external;
  function setVertexStorageLink(uint256 _tokenId, string calldata _vertexStorageLink) external;
  function setExtraData(bytes32 _key, bytes32 _value) external;
  function setPropertyExtraData(uint256 _tokenId, bytes32 _key, bytes32 _value) external;

  function incrementSetupStage(uint256 _tokenId) external;

  function mint(address _to) external returns (uint256);
  function burn(uint256 _tokenId) external;
  function transferFrom(address from, address to, uint256 tokenId) external;

  // GETTERS
  function controller() external view returns (address payable);
  function extraData(bytes32 _key) external view returns (bytes32);
  function propertyExtraData(uint256 _tokenId, bytes32 _key) external view returns (bytes32);
  function propertyCreatedAt(uint256 _tokenId) external view returns (uint256);
  function tokensOfOwner(address _owner) external view returns (uint256[] memory);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function exists(uint256 _tokenId) external view returns (bool);
  function getType(uint256 _tokenId) external view returns (TokenType);
  function getContour(uint256 _tokenId) external view returns (uint256[] memory);
  function getContourLength(uint256 _tokenId) external view returns (uint256);
  function getHighestPoint(uint256 _tokenId) external view returns (int256);
  function getHumanAddress(uint256 _tokenId) external view returns (string memory);
  function getArea(uint256 _tokenId) external view returns (uint256);
  function getAreaSource(uint256 _tokenId) external view returns (AreaSource);
  function getLedgerIdentifier(uint256 _tokenId) external view returns (bytes32);
  function getDataLink(uint256 _tokenId) external view returns (string memory);
  function getVertexRootHash(uint256 _tokenId) external view returns (bytes32);
  function getVertexStorageLink(uint256 _tokenId) external view returns (string memory);
  function getSetupStage(uint256 _tokenId) external view returns (uint256);
  function getDetails(uint256 _tokenId)
    external
    view
    returns (
      TokenType tokenType,
      uint256[] memory contour,
      int256 highestPoint,
      AreaSource areaSource,
      uint256 area,
      bytes32 ledgerIdentifier,
      string memory humanAddress,
      string memory dataLink,
      uint256 setupStage,
      bytes32 vertexRootHash,
      string memory vertexStorageLink
    );
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract PPTokenController is IPPTokenController, Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 public constant VERSION = 3;

  bytes32 public constant PROPOSAL_GALT_FEE_KEY = bytes32("CONTROLLER_PROPOSAL_GALT");
  bytes32 public constant PROPOSAL_ETH_FEE_KEY = bytes32("CONTROLLER_PROPOSAL_ETH");
  bytes32 public constant DETAILS_UPDATED_EXTRA_KEY = bytes32("DETAILS_UPDATED_AT");
  bytes32 public constant CONTOUR_UPDATED_EXTRA_KEY = bytes32("CONTOUR_UPDATED_AT");
  bytes32 public constant CLAIM_UNIQUENESS_KEY = bytes32("CLAIM_UNIQUENESS");

  // setDetails(uint256,uint8,uint8,uint256,bytes32,string,string)
  bytes32 internal constant TOKEN_SET_DETAILS_SIGNATURE = 0x18212fc600000000000000000000000000000000000000000000000000000000;
  // setContour(uint256,uint256[],int256)
  bytes32 internal constant TOKEN_SET_CONTOUR_SIGNATURE = 0x89e8915f00000000000000000000000000000000000000000000000000000000;

  enum ProposalStatus {
    NULL,
    PENDING,
    APPROVED,
    EXECUTED,
    REJECTED,
    CANCELLED
  }

  struct Proposal {
    address creator;
    ProposalStatus status;
    bool tokenOwnerApproved;
    bool geoDataManagerApproved;
    bytes data;
    string dataLink;
  }

  IPPGlobalRegistry public globalRegistry;
  IPPToken public tokenContract;
  address public contourVerificationManager;
  address public geoDataManager;
  address public feeManager;
  address public feeCollector;
  address public minter;
  address public burner;
  uint256 public defaultBurnTimeoutDuration;
  uint256 internal idCounter;

  mapping(uint256 => Proposal) public proposals;
  // tokenId => timeoutDuration (in seconds)
  mapping(uint256 => uint256) public burnTimeoutDuration;
  // tokenId => burnTimeoutAt
  mapping(uint256 => uint256) public burnTimeoutAt;
  // key => fee
  mapping(bytes32 => uint256) public fees;

  modifier onlyMinter() {
    require(msg.sender == minter, "Only minter allowed");

    _;
  }

  modifier onlyContourVerifier() {
    require(msg.sender == contourVerificationManager, "Only contourVerifier allowed");

    _;
  }

  constructor(IPPGlobalRegistry _globalRegistry, IPPToken _tokenContract, uint256 _defaultBurnTimeoutDuration) public {
    require(_defaultBurnTimeoutDuration > 0, "Invalid burn timeout duration");

    defaultBurnTimeoutDuration = _defaultBurnTimeoutDuration;
    tokenContract = _tokenContract;
    globalRegistry = _globalRegistry;
  }

  function() external payable {
  }

  // CONTRACT OWNER INTERFACE

  function setContourVerificationManager(address _contourVerificationManager) external onlyOwner {
    contourVerificationManager = _contourVerificationManager;

    emit SetContourVerificationManager(_contourVerificationManager);
  }

  function setGeoDataManager(address _geoDataManager) external onlyOwner {
    geoDataManager = _geoDataManager;

    emit SetGeoDataManager(_geoDataManager);
  }

  function setFeeManager(address _feeManager) external onlyOwner {
    feeManager = _feeManager;

    emit SetFeeManager(_feeManager);
  }

  function setFeeCollector(address _feeCollector) external onlyOwner {
    feeCollector = _feeCollector;

    emit SetFeeCollector(_feeCollector);
  }

  function setMinter(address _minter) external onlyOwner {
    minter = _minter;

    emit SetMinter(_minter);
  }

  function setBurner(address _burner) external onlyOwner {
    burner = _burner;

    emit SetBurner(_burner);
  }

  function withdrawErc20(address _tokenAddress, address _to) external {
    require(msg.sender == feeCollector, "Missing permissions");

    uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));

    IERC20(_tokenAddress).transfer(_to, balance);

    emit WithdrawErc20(_to, _tokenAddress, balance);
  }

  function withdrawEth(address payable _to) external {
    require(msg.sender == feeCollector, "Missing permissions");

    uint256 balance = address(this).balance;

    _to.transfer(balance);

    emit WithdrawEth(_to, balance);
  }

  function setFee(bytes32 _key, uint256 _value) external {
    require(msg.sender == feeManager, "Missing permissions");

    fees[_key] = _value;
    emit SetFee(_key, _value);
  }

  // BURNER INTERFACE

  function initiateTokenBurn(uint256 _tokenId) external {
    require(msg.sender == burner, "Only burner allowed");
    require(burnTimeoutAt[_tokenId] == 0, "Burn already initiated");
    require(tokenContract.ownerOf(_tokenId) != address(0), "Token doesn't exists");

    uint256 duration = burnTimeoutDuration[_tokenId];
    if (duration == 0) {
      duration = defaultBurnTimeoutDuration;
    }

    uint256 timeoutAt = block.timestamp.add(duration);
    burnTimeoutAt[_tokenId] = timeoutAt;

    emit InitiateTokenBurn(_tokenId, timeoutAt);
  }

  // MINTER INTERFACE
  function mint(address _to) external onlyMinter {
    uint256 _tokenId = tokenContract.mint(_to);

    emit Mint(_to, _tokenId);
  }

  // CONTOUR VERIFICATION INTERFACE

  function reportCVMisbehaviour(uint256 _tokenId) external onlyContourVerifier {
    tokenContract.burn(_tokenId);

    emit ReportCVMisbehaviour(_tokenId);
  }

  // CONTROLLER INTERFACE

  function setInitialDetails(
    uint256 _privatePropertyId,
    IPPToken.TokenType _tokenType,
    IPPToken.AreaSource _areaSource,
    uint256 _area,
    bytes32 _ledgerIdentifier,
    string calldata _humanAddress,
    string calldata _dataLink,
    bool _claimUniqueness
  )
    external
    onlyMinter
  {
    // Will REVERT if there is no owner assigned to the token
    tokenContract.ownerOf(_privatePropertyId);

    uint256 setupStage = tokenContract.getSetupStage(_privatePropertyId);
    require(setupStage == uint256(PropertyInitialSetupStage.PENDING), "Requires PENDING setup stage");

    tokenContract.setDetails(_privatePropertyId, _tokenType, _areaSource, _area, _ledgerIdentifier, _humanAddress, _dataLink);

    tokenContract.incrementSetupStage(_privatePropertyId);

    _updateDetailsUpdatedAt(_privatePropertyId);

    tokenContract.setPropertyExtraData(_privatePropertyId, CLAIM_UNIQUENESS_KEY, bytes32(uint256(_claimUniqueness ? 1 : 0)));
  }

  function setInitialContour(
    uint256 _privatePropertyId,
    uint256[] calldata _contour,
    int256 _highestPoint
  )
    external
    onlyMinter
  {
    uint256 setupStage = tokenContract.getSetupStage(_privatePropertyId);

    require(setupStage == uint256(PropertyInitialSetupStage.DETAILS), "Requires DETAILS setup stage");

    tokenContract.setContour(_privatePropertyId, _contour, _highestPoint);

    tokenContract.incrementSetupStage(_privatePropertyId);

    _updateContourUpdatedAt(_privatePropertyId);
  }

  // TOKEN OWNER INTERFACE

  function setBurnTimeoutDuration(uint256 _tokenId, uint256 _duration) external {
    require(tokenContract.ownerOf(_tokenId) == msg.sender, "Only token owner allowed");
    require(_duration > 0, "Invalid timeout duration");

    burnTimeoutDuration[_tokenId] = _duration;

    emit SetBurnTimeout(_tokenId, _duration);
  }

  function cancelTokenBurn(uint256 _tokenId) external {
    require(burnTimeoutAt[_tokenId] != 0, "Burn not initiated");
    require(tokenContract.ownerOf(_tokenId) == msg.sender, "Only token owner allowed");

    burnTimeoutAt[_tokenId] = 0;

    emit CancelTokenBurn(_tokenId);
  }

  // COMMON INTERFACE

  function propose(
    bytes calldata _data,
    string calldata _dataLink
  )
    external
    payable
  {
    address msgSender = msg.sender;
    uint256 tokenId = fetchTokenId(_data);
    uint256 proposalId = _nextId();

    Proposal storage p = proposals[proposalId];

    if (msgSender == geoDataManager) {
      p.geoDataManagerApproved = true;
    } else if (msgSender == tokenContract.ownerOf(tokenId)) {
      _acceptProposalFee();
      p.tokenOwnerApproved = true;
    } else {
      revert("Missing permissions");
    }

    p.creator = msgSender;
    p.data = _data;
    p.dataLink = _dataLink;
    p.status = ProposalStatus.PENDING;

    emit NewProposal(proposalId, tokenId, msg.sender);
  }

  function approve(uint256 _proposalId) external {
    Proposal storage p = proposals[_proposalId];
    uint256 tokenId = fetchTokenId(p.data);

    require(p.status == ProposalStatus.PENDING, "Expect PENDING status");

    if (p.geoDataManagerApproved == true) {
      require(msg.sender == tokenContract.ownerOf(tokenId), "Missing permissions");
      p.tokenOwnerApproved = true;
    } else if (p.tokenOwnerApproved == true) {
      require(msg.sender == geoDataManager, "Missing permissions");
      p.geoDataManagerApproved = true;
    } else {
      revert("Missing permissions");
    }

    emit ProposalApproval(_proposalId, tokenId);

    p.status = ProposalStatus.APPROVED;

    execute(_proposalId);
  }

  function reject(uint256 _proposalId) external {
    Proposal storage p = proposals[_proposalId];
    uint256 tokenId = fetchTokenId(p.data);

    require(p.status == ProposalStatus.PENDING, "Expect PENDING status");

    if (p.geoDataManagerApproved == true) {
      require(msg.sender == tokenContract.ownerOf(tokenId), "Missing permissions");
    } else if (p.tokenOwnerApproved == true) {
      require(msg.sender == geoDataManager, "Missing permissions");
    } else {
      revert("Missing permissions");
    }

    p.status = ProposalStatus.REJECTED;

    emit ProposalRejection(_proposalId, tokenId);
  }

  function cancel(uint256 _proposalId) external {
    Proposal storage p = proposals[_proposalId];
    uint256 tokenId = fetchTokenId(p.data);

    require(p.status == ProposalStatus.PENDING, "Expect PENDING status");

    if (msg.sender == geoDataManager) {
      require(p.geoDataManagerApproved == true, "Only own proposals can be cancelled");
    } else if (msg.sender == tokenContract.ownerOf(tokenId)) {
      require(p.tokenOwnerApproved == true, "Only own proposals can be cancelled");
    } else {
      revert("Missing permissions");
    }

    p.status = ProposalStatus.CANCELLED;

    emit ProposalCancellation(_proposalId, tokenId);
  }

  // PERMISSIONLESS INTERFACE

  function execute(uint256 _proposalId) public {
    Proposal storage p = proposals[_proposalId];

    require(p.tokenOwnerApproved == true, "Token owner approval required");
    require(p.geoDataManagerApproved == true, "GeoDataManager approval required");
    require(p.status == ProposalStatus.APPROVED, "Expect APPROVED status");

    _preExecuteHook(p.data);

    p.status = ProposalStatus.EXECUTED;

    (bool ok,) = address(tokenContract)
      .call
      .gas(gasleft().sub(50000))(p.data);

    if (ok == false) {
      emit ProposalExecutionFailed(_proposalId);
      p.status = ProposalStatus.APPROVED;
    } else {
      emit ProposalExecuted(_proposalId);
    }
  }

  function _preExecuteHook(bytes memory data) internal {
    bytes32 signature = fetchSignature(data);
    uint256 tokenId = fetchTokenId(data);

    if (signature == TOKEN_SET_DETAILS_SIGNATURE) {
      _updateDetailsUpdatedAt(tokenId);
    } else if (signature == TOKEN_SET_CONTOUR_SIGNATURE) {
      _updateContourUpdatedAt(tokenId);
    }
  }

  function burnTokenByTimeout(uint256 _tokenId) external {
    require(burnTimeoutAt[_tokenId] != 0, "Timeout not set");
    require(block.timestamp > burnTimeoutAt[_tokenId], "Timeout has not passed yet");
    require(tokenContract.ownerOf(_tokenId) != address(0), "Token already burned");

    tokenContract.burn(_tokenId);

    emit BurnTokenByTimeout(_tokenId);
  }

  // @dev Assuming that a tokenId is always the first argument in a method
  function fetchTokenId(bytes memory _data) public pure returns (uint256 tokenId) {
    assembly {
      tokenId := mload(add(_data, 0x24))
    }

    require(tokenId > 0, "Failed fetching tokenId from encoded data");
  }

  function fetchSignature(bytes memory _data) public pure returns (bytes32 signature) {
    assembly {
      signature := and(mload(add(_data, 0x20)), 0xffffffff00000000000000000000000000000000000000000000000000000000)
    }
  }

  // INTERNAL

  function _nextId() internal returns (uint256) {
    idCounter += 1;
    return idCounter;
  }

  function _galtToken() internal view returns (IERC20) {
    return IERC20(globalRegistry.getGaltTokenAddress());
  }

  function _acceptProposalFee() internal {
    if (msg.value == 0) {
      _galtToken().transferFrom(msg.sender, address(this), fees[PROPOSAL_GALT_FEE_KEY]);
    } else {
      require(msg.value == fees[PROPOSAL_ETH_FEE_KEY], "Invalid fee");
    }
  }

  function _updateDetailsUpdatedAt(uint256 _tokenId) internal {
    bytes32 value = bytes32(now);

    tokenContract.setPropertyExtraData(_tokenId, DETAILS_UPDATED_EXTRA_KEY, value);

    emit UpdateDetailsUpdatedAt(_tokenId, now);
  }

  function _updateContourUpdatedAt(uint256 _tokenId) internal {
    bytes32 value = bytes32(now);

    tokenContract.setPropertyExtraData(_tokenId, CONTOUR_UPDATED_EXTRA_KEY, value);

    emit UpdateDetailsUpdatedAt(_tokenId, now);
  }

  // GETTERS

  function getDetailsUpdatedAt(uint256 _tokenId) public view returns (uint256) {
    return uint256(tokenContract.propertyExtraData(_tokenId, DETAILS_UPDATED_EXTRA_KEY));
  }

  function getContourUpdatedAt(uint256 _tokenId) public view returns (uint256) {
    return uint256(tokenContract.propertyExtraData(_tokenId, CONTOUR_UPDATED_EXTRA_KEY));
  }

  function getClaimUniquenessFlag(uint256 _tokenId) public view returns (bool) {
    return tokenContract.propertyExtraData(_tokenId, CLAIM_UNIQUENESS_KEY) != 0x0;
  }
}

library CPointUtils {

  uint256 public constant XYZ_MASK =    uint256(0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff);
  uint256 public constant XY_MASK =     uint256(0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff);
  uint256 public constant HEIGHT_MASK = uint256(0x000000000000000000000000ffffffff00000000000000000000000000000000);
  uint256 public constant LAT_MASK =    uint256(0x00000000000000000000000000000000ffffffffffffffff0000000000000000);
  uint256 public constant LON_MASK =    uint256(0x000000000000000000000000000000000000000000000000ffffffffffffffff);
  uint256 public constant INT64_MASK =  uint256(0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000);
  uint256 public constant INT32_MASK =  uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000);

  // -2_147_483_648
  int256 constant Z_MIN = int256(-2147483648);
  // 2_147_483_647
  int256 constant Z_MAX = int256(2147483647);

  int256 constant DECIMALS = 10 ** 8;

  // LAT/LON/HEIGHT

  function cPointToLat(uint256 _cPoint) internal pure returns (int256) {
    return int256(int64(((_cPoint & LAT_MASK) >> 64) ^ INT64_MASK)) * DECIMALS;
  }

  function cPointToLon(uint256 _cPoint) internal pure returns (int256) {
    return int256(int64((_cPoint & LON_MASK) ^ INT64_MASK)) * DECIMALS;
  }

  function cPointToHeight(uint256 _cPoint) internal pure returns (int256) {
    return int32(((_cPoint & HEIGHT_MASK) >> 128) ^ INT32_MASK);
  }

  // COMBINATIONS

  function cPointToLatLonHeight(uint256 _cPoint) internal pure returns (int256 lat, int256 lon, int256 height) {
    lat = cPointToLat(_cPoint);
    lon = cPointToLon(_cPoint);
    height = cPointToHeight(_cPoint);
  }

  function cPointToLatLonArr(uint256 _cPoint) internal pure returns (int256[2] memory) {
    return [
      cPointToLat(_cPoint),
      cPointToLon(_cPoint)
    ];
  }

  function cPointToLatLon(uint256 _cPoint) internal pure returns (int256 lat, int256 lon) {
    lat = cPointToLat(_cPoint);
    lon = cPointToLon(_cPoint);
  }

  function latLonHeightToCPoint(int256 _lat, int256 _lon, int256 _height) internal pure returns (uint256 cPoint) {
    requireHeightValid(_height);

    int256 lat = (_lat / DECIMALS) << 64;
    int256 height = _height << 128;

    return uint256(((((bytes32(_lon / DECIMALS) & bytes32(LON_MASK)) ^ bytes32(lat)) & bytes32(XY_MASK)) ^ bytes32(height)) & bytes32(XYZ_MASK));
  }

  function requireHeightValid(int256 _height) pure internal {
    require(Z_MIN <= _height && _height <= Z_MAX, "CPointUtils: height overflow");
  }

  function isHeightValid(int256 _height) pure internal returns (bool) {
    return (Z_MIN <= _height && _height <= Z_MAX);
  }
}

library PPContourVerificationLib {
  enum InclusionType {
    A_POINT_INSIDE_B,
    B_POINT_INSIDE_A
  }

  /**
   * @dev Checks if two given contour segment intersect each other
   * @param _excludeCollinear will return false if two segments are collinear
   */
  function contourSegmentsIntersects(
    uint256[] memory _contourA,
    uint256[] memory _contourB,
    uint256 _aSegmentFirstPointIndex,
    uint256 _bSegmentFirstPointIndex,
    bool _excludeCollinear
  )
    internal
    view
    returns (bool)
  {
    uint contourAlen = _contourA.length;
    uint contourBlen = _contourB.length;

    uint256 _aSegmentFirstPoint = _contourA[_aSegmentFirstPointIndex];
    uint256 _aSegmentSecondPoint = _aSegmentFirstPointIndex + 1 == contourAlen ? _contourA[0] : _contourA[_aSegmentFirstPointIndex + 1];

    uint256 _bSegmentFirstPoint = _contourB[_bSegmentFirstPointIndex];
    uint256 _bSegmentSecondPoint = _bSegmentFirstPointIndex + 1 == contourBlen ? _contourB[0] : _contourB[_bSegmentFirstPointIndex + 1];

    bool isCollinear = segmentsAreCollinear(
      _aSegmentFirstPoint,
      _aSegmentSecondPoint,
      _bSegmentSecondPoint,
      _bSegmentFirstPoint
    );

    if (_excludeCollinear && isCollinear) {
      return false;
    }

    return SegmentUtils.segmentsIntersect(
      getLatLonSegment(
        _aSegmentFirstPoint,
        _aSegmentSecondPoint
      ),
      getLatLonSegment(
        _bSegmentFirstPoint,
        _bSegmentSecondPoint
      )
    );
  }

  function pointInsideContour(
    uint256[] memory _contourA,
    uint256[] memory _contourB,
    uint256 _includingPoint
  )
    internal
    view
    returns (bool)
  {
    return isInsideWithoutCache(_includingPoint, _contourA, true) && isInsideWithoutCache(_includingPoint, _contourB, true);
  }

  function isInsideWithoutCache(
    uint256 _cPoint,
    uint256[] memory _polygon,
    bool _excludeCollinear
  )
    internal
    pure
    returns (bool)
  {
    (int256 x, int256 y) = CPointUtils.cPointToLatLon(_cPoint);

    bool inside = false;
    uint256 j = _polygon.length - 1;

    for (uint256 i = 0; i < _polygon.length; i++) {
      (int256 xi, int256 yi) = CPointUtils.cPointToLatLon(_polygon[i]);
      (int256 xj, int256 yj) = CPointUtils.cPointToLatLon(_polygon[j]);

      bool intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (_excludeCollinear) {
        if (SegmentUtils.pointOnSegment([x, y], [xi, yi], [xj, yj])) {
          return false;
        }
      }
      if (intersect) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  function segmentsAreCollinear(
    uint256 _a1,
    uint256 _b1,
    uint256 _a2,
    uint256 _b2
  )
    internal
    pure
    returns (bool)
  {
    int256[2] memory a1 = toLatLonPoint(_a1);
    int256[2] memory b1 = toLatLonPoint(_b1);
    int256[2] memory a2 = toLatLonPoint(_a2);
    int256[2] memory b2 = toLatLonPoint(_b2);

    return SegmentUtils.pointOnSegment(a2, a1, b1) ||
    SegmentUtils.pointOnSegment(b2, a1, b1) ||
    SegmentUtils.pointOnSegment(a1, b1, b2) ||
    SegmentUtils.pointOnSegment(a2, b1, b2) ||
    SegmentUtils.pointOnSegment(b1, a1, a2) ||
    SegmentUtils.pointOnSegment(b2, a1, a2);
  }

  function getLatLonSegment(
    uint256 _aPoint,
    uint256 _bPoint
  )
    internal
    pure
    returns (int256[2][2] memory)
  {
    return int256[2][2]([
      toLatLonPoint(_aPoint),
      toLatLonPoint(_bPoint)
    ]);
  }

  function toLatLonPoint(
    uint256 _cPoint
  )
    internal
    pure
    returns (int256[2] memory)
  {
    return CPointUtils.cPointToLatLonArr(_cPoint);
  }

  function checkForRoomVerticalIntersection(
    uint256[] memory _validContour,
    uint256[] memory _invalidContour,
    int256 _vHP,
    int256 _iHP
  )
    internal
    view
    returns (bool)
  {
    int256 vLP = getLowestElevation(_validContour);
    int256 iLP = getLowestElevation(_invalidContour);

    return checkVerticalIntersection(_vHP, vLP, _iHP, iLP);
  }

  function getLowestElevation(
    uint256[] memory _contour
  )
    internal
    pure
    returns (int256)
  {
    uint256 len = _contour.length;
    require(len > 2, "Empty contour passed in");

    int256 theLowest = CPointUtils.cPointToHeight(_contour[0]);

    for (uint256 i = 1; i < len; i++) {
      int256 elevation = CPointUtils.cPointToHeight(_contour[i]);
      if (elevation < theLowest) {
        theLowest = elevation;
      }
    }

    return theLowest;
  }

  function checkVerticalIntersection(int256 _aHP, int256 _aLP, int256 _bHP, int256 _bLP) internal pure returns (bool) {
    if (_aHP == _bHP && _aLP == _bLP) {
      return true;
    }

    if (_aHP < _bHP && _aHP > _bLP) {
      return true;
    }

    if (_bHP < _aHP && _bHP > _aLP) {
      return true;
    }

    if (_aLP < _bHP && _aLP > _bLP) {
      return true;
    }

    if (_bLP < _aHP && _bLP > _aLP) {
      return true;
    }

    return false;
  }
}
contract PPContourVerificationPublicLib {
  function contourSegmentsIntersects(
    uint256[] memory _contourA,
    uint256[] memory _contourB,
    uint256 _aSegmentFirstPointIndex,
    uint256 _bSegmentFirstPointIndex,
    bool _excludeCollinear
  )
    public
    view
    returns (bool)
  {
    return PPContourVerificationLib.contourSegmentsIntersects(
      _contourA,
      _contourB,
      _aSegmentFirstPointIndex,
      _bSegmentFirstPointIndex,
      _excludeCollinear
    );
  }

  function checkForRoomVerticalIntersection(
    uint256[] memory _validContour,
    uint256[] memory _invalidContour,
    int256 _vHP,
    int256 _iHP
  )
    public
    view
    returns (bool)
  {
    return PPContourVerificationLib.checkForRoomVerticalIntersection(
      _validContour,
      _invalidContour,
      _vHP,
      _iHP
    );
  }

  function pointInsideContour(
    uint256[] memory _contourA,
    uint256[] memory _contourB,
    uint256 _includingPoint
  )
    public
    view
    returns (bool)
  {
    return PPContourVerificationLib.pointInsideContour(_contourA, _contourB, _includingPoint);
  }

  function segmentsAreCollinear(
    uint256 _a1g,
    uint256 _b1g,
    uint256 _a2g,
    uint256 _b2g
  )
    public
    view
    returns(bool)
  {
    return PPContourVerificationLib.segmentsAreCollinear(
      _a1g,
      _b1g,
      _a2g,
      _b2g
    );
  }

  function getLowestElevation(uint256[] memory _contour) public pure returns (int256) {
    return PPContourVerificationLib.getLowestElevation(_contour);
  }

  function checkVerticalIntersection(int256 _aHP, int256 _aLP, int256 _bHP, int256 _bLP) public pure returns (bool) {
    return PPContourVerificationLib.checkVerticalIntersection(_aHP, _aLP, _bHP, _bLP);
  }
}
contract PPContourVerification is Ownable {
  event EnableVerification(uint256 minimalDeposit, uint256 activeFrom);
  event DisableVerification();
  event ReportNoDeposit(address indexed reporter, uint256 token);
  event ReportIntersection(address indexed reporter, uint256 indexed validTokenId, uint256 indexed invalidTokenId);
  event ReportInclusion(address indexed reporter, uint256 indexed validTokenId, uint256 indexed invalidTokenId);

  bytes32 public constant PPGR_DEPOSIT_HOLDER_KEY = bytes32("deposit_holder");

  PPContourVerificationPublicLib public lib;
  PPTokenController public controller;
  // 0 if disabled
  uint256 public activeFrom;
  // 0 if disabled, in GALT
  uint256 public minimalDeposit;
  uint256 public minimalTimeout;
  uint256 public newTokenTimeout;

  modifier onlyActiveVerification() {
    require(activeFrom != 0 && now >= activeFrom, "Verification is disabled");

    _;
  }

  constructor(
    PPTokenController _controller,
    PPContourVerificationPublicLib _lib,
    uint256 _minimalTimeout,
    uint256 _newTokenTimeout
  )
    public
  {
    controller = _controller;
    lib = _lib;
    minimalTimeout = _minimalTimeout;
    newTokenTimeout = _newTokenTimeout;
  }

  // OWNER INTERFACE

  function enableVerification(uint256 _minimalDeposit, uint256 _timeout) external onlyOwner {
    require(activeFrom == 0, "Verification is already enabled");
    require(_timeout >= minimalTimeout, "Timeout is not big enough");

    uint256 _activeFrom = now + _timeout;

    minimalDeposit = _minimalDeposit;
    activeFrom = _activeFrom;

    emit EnableVerification(_minimalDeposit, _activeFrom);
  }

  function disableVerification() external onlyOwner {
    require(minimalDeposit != 0 && activeFrom != 0, "Verification is already disabled");

    minimalDeposit = 0;
    activeFrom = 0;

    emit DisableVerification();
  }

  // PUBLIC INTERFACE

  function reportNoDeposit(uint256 _tokenId) external onlyActiveVerification {

    uint256 propertyCreatedAt = _tokenContract().propertyCreatedAt(_tokenId);
    require(now >= propertyCreatedAt + newTokenTimeout, "newTokenTimeout not passed yet");

    require(_tokenContract().exists(_tokenId), "Token doesn't exist");

    address tokenContractAddress = address(_tokenContract());
    IPPDepositHolder depositHolder = _depositHolder();
    bool isSufficient = depositHolder.isInsufficient(tokenContractAddress, _tokenId, minimalDeposit);

    require(isSufficient == false, "The deposit is sufficient");

    if (depositHolder.balanceOf(tokenContractAddress, _tokenId) > 0) {
      depositHolder.payout(tokenContractAddress, _tokenId, msg.sender);
    }
    controller.reportCVMisbehaviour(_tokenId);

    emit ReportNoDeposit(msg.sender, _tokenId);
  }

  function reportInclusion(
    uint256 _validTokenId,
    uint256 _invalidTokenId,
    uint256 _includingPoint
  )
    external
    onlyActiveVerification
  {
    _ensureInvalidity(_validTokenId, _invalidTokenId);

    IPPToken tokenContract = _tokenContract();

    uint256[] memory validContour = tokenContract.getContour(_validTokenId);
    uint256[] memory invalidContour = tokenContract.getContour(_invalidTokenId);

    bool isInside = lib.pointInsideContour(validContour, invalidContour, _includingPoint);

    if (isInside == true) {
      if (tokenContract.getType(_validTokenId) == IPPToken.TokenType.ROOM) {
        bool uniquenessValidToken = controller.getClaimUniquenessFlag(_validTokenId);
        bool uniquenessInvalidToken = controller.getClaimUniquenessFlag(_invalidTokenId);
        if (!uniquenessValidToken || !uniquenessInvalidToken) {
          _requireVerticalIntersection(_validTokenId, _invalidTokenId, validContour, invalidContour);
        }
      }
    } else {
      revert("Inclusion not found");
    }

    _depositHolder().payout(address(tokenContract), _invalidTokenId, msg.sender);
    controller.reportCVMisbehaviour(_invalidTokenId);

    emit ReportInclusion(msg.sender, _validTokenId, _invalidTokenId);
  }

  // INTERNAL

  function _tokenContract() internal returns (IPPToken) {
    return controller.tokenContract();
  }

  function _depositHolder() internal view returns(IPPDepositHolder) {
    return IPPDepositHolder(controller.globalRegistry().getContract(PPGR_DEPOSIT_HOLDER_KEY));
  }

  function _requireVerticalIntersection(
    uint256 _validTokenId,
    uint256 _invalidTokenId,
    uint256[] memory _validContour,
    uint256[] memory _invalidContour
  )
    internal
  {
    IPPToken tokenContract = controller.tokenContract();

    require(
      lib.checkForRoomVerticalIntersection(
        _validContour,
        _invalidContour,
        tokenContract.getHighestPoint(_validTokenId),
        tokenContract.getHighestPoint(_invalidTokenId)
      ) == true,
      "Contour intersects, but not the heights"
    );
  }

  function _ensureInvalidity(uint256 _validToken, uint256 _invalidToken) internal {
    IPPToken tokenContract = controller.tokenContract();

    require(tokenContract.exists(_validToken) == true, "Valid token doesn't exist");
    require(tokenContract.exists(_invalidToken) == true, "Invalid token doesn't exist");

    IPPToken.TokenType validTokenType = tokenContract.getType(_validToken);
    require(
      validTokenType == tokenContract.getType(_invalidToken),
      "Tokens type mismatch"
    );

    bool uniquenessValidToken = controller.getClaimUniquenessFlag(_validToken);
    bool uniquenessInvalidToken = controller.getClaimUniquenessFlag(_invalidToken);

    if (uniquenessValidToken && uniquenessInvalidToken && validTokenType == IPPToken.TokenType.ROOM) {
      bytes32 validHumanAddressHash = keccak256(abi.encodePacked(tokenContract.getHumanAddress(_validToken)));
      bytes32 invalidHumanAddressHash = keccak256(abi.encodePacked(tokenContract.getHumanAddress(_invalidToken)));
      require(validHumanAddressHash == invalidHumanAddressHash, "Both tokens have uniqueness flag and different human addresses");
    }

    uint256 validLatestTimestamp = controller.getContourUpdatedAt(_validToken);
    if (validLatestTimestamp == 0) {
      validLatestTimestamp = tokenContract.propertyCreatedAt(_validToken);
    }
    assert(validLatestTimestamp > 0);

    uint256 invalidLatestTimestamp = controller.getContourUpdatedAt(_invalidToken);
    if (invalidLatestTimestamp == 0) {
      invalidLatestTimestamp = tokenContract.propertyCreatedAt(_invalidToken);
    }
    assert(invalidLatestTimestamp > 0);

    // Matching timestamps
    require(
      invalidLatestTimestamp >= validLatestTimestamp,
      // solium-disable-next-line error-reason
      "Expression 'invalidTimestamp >= validTimestamp' doesn't satisfied"
    );
  }
}

contract PPContourVerificationFactory {
  event NewPPContourVerification(address contourVerificationContract);

  PPContourVerificationPublicLib public lib;

  constructor(PPContourVerificationPublicLib _lib) public {
    lib = _lib;
  }

  function build(
    PPTokenController _controller,
    uint256 _minimalTimeout,
    uint256 _newTokenTimeout
  )
    external
    returns (PPContourVerification)
  {
    PPContourVerification cv = new PPContourVerification(_controller, lib, _minimalTimeout, _newTokenTimeout);

    emit NewPPContourVerification(address(cv));

    cv.transferOwnership(msg.sender);

    return cv;
  }
}