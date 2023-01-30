pragma solidity ^0.4.24;

import "CurrencyOracle.sol";

contract HKDOracle is CurrencyOracle{

    constructor() payable public{
        min_price = 778575000000000000 * 5;  //price (10**18) * 0.5
        max_price = 778575000000000000 * 15; //price (10**18) * 1.5
        oracleURL = "BBSuv2bd17wI0kW0ZDSgIBZStR1StjdXPQogR39DuBGWLmnlZz4mb5rEC7wbV+2p9EXRZegOPmOQLjGAPIk4oJ3b3bgBZVJuTJIlkCFYOZvd4DV1n+PIZjdqjUr7Tr7l4iWW1YJmmkPRFnn2Y+hgl4BfGXV3Imj9oloGm9u8Taf2mgCRaYgwePk7MyRs2qHMPgOnX0vSLhTSnFY4X9hu6lWMdQq27OjdshpBPaxjmT/oDw1pwczfsfGCowkRdJ7e+A6p0MoPiw==";
    }

    function getCurrencySymbol() external view returns(bytes32 result) {
        return bytes32("HKD");
    }
}
