pragma solidity ^0.4.24;

import "CurrencyOracle.sol";

contract SGDOracle is CurrencyOracle{

    constructor() payable public{
    	min_price = 140089000000000000 * 5;
        max_price = 140089000000000000 * 15;
        oracleURL = "BFjQg4RC+W/9hfxxYJ7nyyhM5oDrDTifxZwNV/E0UHs6LbxDviXY8w7jZ/KN3H5gh3Iqu0AknPD+qV2k1tRclKTz7vhpnsTDcz+SyUlkTRkbW+UL/hFWktFqsl9JWemmmGmXZ02LOIajjux+q0TRt3WxM27F+0yyYPPbdlq8Yt6d++91M4hbSEJjNrUSO8HKWpzoxc5SqHZZ0SM4UMhfHkDfUgp50mhNT81HJVBq/ENhIDhtriByIgV4/8otuDK+eyCWdL5mrg=="; 
    }

    function getCurrencySymbol() external view returns(bytes32 result) {
        return bytes32("SGD");
    }
}
