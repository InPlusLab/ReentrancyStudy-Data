/**

 *Submitted for verification at Etherscan.io on 2018-12-17

*/



library SafeMath8 {



    function mul(uint8 a, uint8 b) internal pure returns (uint8) {

        if (a == 0) {

            return 0;

        }

        uint8 c = a * b;

        assert(c / a == b);

        return c;

    }



    function div(uint8 a, uint8 b) internal pure returns (uint8) {

        return a / b;

    }



    function sub(uint8 a, uint8 b) internal pure returns (uint8) {

        assert(b <= a);

        return a - b;

    }



    function add(uint8 a, uint8 b) internal pure returns (uint8) {

        uint8 c = a + b;

        assert(c >= a);

        return c;

    }



    function pow(uint8 a, uint8 b) internal pure returns (uint8) {

        if (a == 0) return 0;

        if (b == 0) return 1;



        uint8 c = a ** b;

        assert(c / (a ** (b - 1)) == a);

        return c;

    }

}



library SafeMath16 {



    function mul(uint16 a, uint16 b) internal pure returns (uint16) {

        if (a == 0) {

            return 0;

        }

        uint16 c = a * b;

        assert(c / a == b);

        return c;

    }



    function div(uint16 a, uint16 b) internal pure returns (uint16) {

        return a / b;

    }



    function sub(uint16 a, uint16 b) internal pure returns (uint16) {

        assert(b <= a);

        return a - b;

    }



    function add(uint16 a, uint16 b) internal pure returns (uint16) {

        uint16 c = a + b;

        assert(c >= a);

        return c;

    }



    function pow(uint16 a, uint16 b) internal pure returns (uint16) {

        if (a == 0) return 0;

        if (b == 0) return 1;



        uint16 c = a ** b;

        assert(c / (a ** (b - 1)) == a);

        return c;

    }

}



library SafeMath256 {



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



    function pow(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;

        if (b == 0) return 1;



        uint256 c = a ** b;

        assert(c / (a ** (b - 1)) == a);

        return c;

    }

}



library SafeConvert {



    function toUint8(uint256 _value) internal pure returns (uint8) {

        assert(_value <= 255);

        return uint8(_value);

    }



    function toUint16(uint256 _value) internal pure returns (uint16) {

        assert(_value <= 2**16 - 1);

        return uint16(_value);

    }



    function toUint32(uint256 _value) internal pure returns (uint32) {

        assert(_value <= 2**32 - 1);

        return uint32(_value);

    }

}



contract DragonStorage {

    function getGenome(uint256) external view returns (uint256[4]);

}



contract Parser {

    using SafeMath8 for uint8;

    using SafeMath256 for uint256;



    using SafeConvert for uint256;

    

    DragonStorage _storage_ = DragonStorage(0x960f401AED58668ef476eF02B2A2D43B83C261D8);



    function _getIndexAndFactor(uint8 _counter) internal pure returns (uint8 index, uint8 factor) {

        if (_counter < 44) index = 0;

        else if (_counter < 88) index = 1;

        else if (_counter < 132) index = 2;

        else index = 3;

        factor = _counter.add(1) % 4 == 0 ? 10 : 100;

    }



    function getParsedGenome(uint256 _id) external view returns (uint8[16][10] parsed) {

        uint256[4] memory _composed = _storage_.getGenome(_id);

        uint8 counter = 160; // 40 genes with 4 values in each one

        uint8 _factor;

        uint8 _index;



        for (uint8 i = 0; i < 10; i++) {

            for (uint8 j = 0; j < 16; j++) {

                counter = counter.sub(1);

                // _index - index of value in genome array where current gene is stored

                // _factor - denominator that determines the number of digits

                (_index, _factor) = _getIndexAndFactor(counter);

                parsed[9 - i][15 - j] = (_composed[_index] % _factor).toUint8();

                _composed[_index] /= _factor;

            }

        }

    }

}