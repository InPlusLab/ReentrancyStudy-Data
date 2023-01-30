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