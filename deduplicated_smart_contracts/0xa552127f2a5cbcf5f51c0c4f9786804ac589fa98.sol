/**

 *Submitted for verification at Etherscan.io on 2018-11-07

*/



pragma solidity ^0.4.24;



contract Time {

  using DateTime for uint;



  function getDate(uint time) public view returns(string) {

    uint year = time.getYear();

    uint month = time.getMonth();

    uint day = time.getDay();



    if(month < 10) {

      string memory _month = Utils.strConcat(Utils.uint2str(0), Utils.uint2str(month));

    } else {

      _month = Utils.uint2str(month);

    }



    if(day < 10) {

      string memory _day = Utils.strConcat("0", Utils.uint2str(day));

    }else{

      _day = Utils.uint2str(day);

    }



    return Utils.strConcat(Utils.uint2str(year), _month, _day);

  }



  function getTime(uint time) public view returns(string) {

    uint hour = time.parseTimestamp().hour;

    uint minute = time.parseTimestamp().minute;

    uint second = time.parseTimestamp().second;



    if(hour < 10) {

      string memory _hour = Utils.strConcat(Utils.uint2str(0), Utils.uint2str(hour));

    } else {

      _hour = Utils.uint2str(hour);

    }



    if(minute < 10) {

      string memory _minute = Utils.strConcat("0", Utils.uint2str(minute));

    }else{

      _minute = Utils.uint2str(minute);

    }



    if(second < 10) {

      string memory _second = Utils.strConcat("0", Utils.uint2str(second));

    }else{

      _second = Utils.uint2str(second);

    }



    return Utils.strConcat(_hour, _minute,_second);

  }



}



//////////////////////////////////////////////////

library Utils {

  // https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol#L886



  function uint2str(uint i) internal pure returns (string) {

    if (i == 0) return "0";

    uint j = i;

    uint len;

    while (j != 0){

      len++;

      j /= 10;

    }



    bytes memory bstr = new bytes(len);

    uint k = len - 1;

    while (i != 0){

      bstr[k--] = byte(48 + i % 10);

      i /= 10;

    }



    return string(bstr);

  }



  // https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol#L833



  function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){

    bytes memory _ba = bytes(_a);

    bytes memory _bb = bytes(_b);

    bytes memory _bc = bytes(_c);

    bytes memory _bd = bytes(_d);

    bytes memory _be = bytes(_e);

    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

    bytes memory babcde = bytes(abcde);

    uint k = 0;

    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

    for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

    for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

    for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

    for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

    return string(babcde);

  }



  function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {

    return strConcat(_a, _b, _c, _d, "");

  }



  function strConcat(string _a, string _b, string _c) internal pure returns (string) {

    return strConcat(_a, _b, _c, "", "");

  }



  function strConcat(string _a, string _b) internal pure returns (string) {

    return strConcat(_a, _b, "", "", "");

  }

}





//////////////////////////////////////////////////





library DateTime {

        /*

         *  Date and Time utilities for ethereum contracts

         *

         */

        struct _DateTime {

                uint16 year;

                uint8 month;

                uint8 day;

                uint8 hour;

                uint8 minute;

                uint8 second;

                uint8 weekday;

        }



        uint constant DAY_IN_SECONDS = 86400;

        uint constant YEAR_IN_SECONDS = 31536000;

        uint constant LEAP_YEAR_IN_SECONDS = 31622400;



        uint constant HOUR_IN_SECONDS = 3600;

        uint constant MINUTE_IN_SECONDS = 60;



        uint16 constant ORIGIN_YEAR = 1970;



        function isLeapYear(uint16 year) internal pure returns (bool) {

                if (year % 4 != 0) {

                        return false;

                }

                if (year % 100 != 0) {

                        return true;

                }

                if (year % 400 != 0) {

                        return false;

                }

                return true;

        }



        function leapYearsBefore(uint year) internal pure returns (uint) {

                year -= 1;

                return year / 4 - year / 100 + year / 400;

        }



        function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {

                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {

                        return 31;

                }

                else if (month == 4 || month == 6 || month == 9 || month == 11) {

                        return 30;

                }

                else if (isLeapYear(year)) {

                        return 29;

                }

                else {

                        return 28;

                }

        }



        function parseTimestamp(uint timestamp) internal pure returns (_DateTime dt) {

                uint secondsAccountedFor = 0;

                uint buf;

                uint8 i;



                // Year

                dt.year = getYear(timestamp);

                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);



                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;

                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);



                // Month

                uint secondsInMonth;

                for (i = 1; i <= 12; i++) {

                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);

                        if (secondsInMonth + secondsAccountedFor > timestamp) {

                                dt.month = i;

                                break;

                        }

                        secondsAccountedFor += secondsInMonth;

                }



                // Day

                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {

                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {

                                dt.day = i;

                                break;

                        }

                        secondsAccountedFor += DAY_IN_SECONDS;

                }



                // Hour

                dt.hour = getHour(timestamp);



                // Minute

                dt.minute = getMinute(timestamp);



                // Second

                dt.second = getSecond(timestamp);



                // Day of week.

                dt.weekday = getWeekday(timestamp);

        }



        function getYear(uint timestamp) internal pure returns (uint16) {

                uint secondsAccountedFor = 0;

                uint16 year;

                uint numLeapYears;



                // Year

                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);

                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);



                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;

                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);



                while (secondsAccountedFor > timestamp) {

                        if (isLeapYear(uint16(year - 1))) {

                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;

                        }

                        else {

                                secondsAccountedFor -= YEAR_IN_SECONDS;

                        }

                        year -= 1;

                }

                return year;

        }



        function getMonth(uint timestamp) internal pure returns (uint8) {

                return parseTimestamp(timestamp).month;

        }



        function getDay(uint timestamp) internal pure returns (uint8) {

                return parseTimestamp(timestamp).day;

        }



        function getHour(uint timestamp) internal pure returns (uint8) {

                return uint8((timestamp / 60 / 60) % 24);

        }



        function getMinute(uint timestamp) internal pure returns (uint8) {

                return uint8((timestamp / 60) % 60);

        }



        function getSecond(uint timestamp) internal pure returns (uint8) {

                return uint8(timestamp % 60);

        }



        function getWeekday(uint timestamp) internal pure returns (uint8) {

                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);

        }



        function toTimestamp(uint16 year, uint8 month, uint8 day) internal pure returns (uint timestamp) {

                return toTimestamp(year, month, day, 0, 0, 0);

        }



        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) internal pure returns (uint timestamp) {

                return toTimestamp(year, month, day, hour, 0, 0);

        }



        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) internal pure returns (uint timestamp) {

                return toTimestamp(year, month, day, hour, minute, 0);

        }



        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) internal pure returns (uint timestamp) {

                uint16 i;



                // Year

                for (i = ORIGIN_YEAR; i < year; i++) {

                        if (isLeapYear(i)) {

                                timestamp += LEAP_YEAR_IN_SECONDS;

                        }

                        else {

                                timestamp += YEAR_IN_SECONDS;

                        }

                }



                // Month

                uint8[12] memory monthDayCounts;

                monthDayCounts[0] = 31;

                if (isLeapYear(year)) {

                        monthDayCounts[1] = 29;

                }

                else {

                        monthDayCounts[1] = 28;

                }

                monthDayCounts[2] = 31;

                monthDayCounts[3] = 30;

                monthDayCounts[4] = 31;

                monthDayCounts[5] = 30;

                monthDayCounts[6] = 31;

                monthDayCounts[7] = 31;

                monthDayCounts[8] = 30;

                monthDayCounts[9] = 31;

                monthDayCounts[10] = 30;

                monthDayCounts[11] = 31;



                for (i = 1; i < month; i++) {

                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];

                }



                // Day

                timestamp += DAY_IN_SECONDS * (day - 1);



                // Hour

                timestamp += HOUR_IN_SECONDS * (hour);



                // Minute

                timestamp += MINUTE_IN_SECONDS * (minute);



                // Second

                timestamp += second;



                return timestamp;

        }

}





//////////////////////////////////////////////////