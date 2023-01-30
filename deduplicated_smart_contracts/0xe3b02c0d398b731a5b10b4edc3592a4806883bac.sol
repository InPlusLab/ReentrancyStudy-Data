pragma solidity ^0.4.24;

import "./CurrencyOracle.sol";

contract ILSOracle is CurrencyOracle{

    constructor() payable public{
    	min_price = 342537000000000000 * 5;
        max_price = 342537000000000000 * 15;
        oracleURL = "BAJtMgRLz+dmHykBBwMKEItgeOwSA3iTPzxI7cxkPIS2lkOTIo8/FuGhobTan8e+WWJtjMlCsWtjagAXVIzsBvanWBOEbAtoYasovsrxdqjeZogaVM163tfuM7zbbrMzeGUc56q1NtrMyB4YAtPwqmhwhKmPNNgqO2o5u9Lc5UYRuDXeiOx5O5Iuf4QnWWpn48XS4hqIm0aSujKjmJCE+Uk5LkJDEwP6MrRv7Ase+oosD3wMxVkFHDtxSqZayDU089tnv3BeNg==";
    }

    function getCurrencySymbol() external view returns(bytes32 result) {
        return bytes32("ILS");
    }
}
