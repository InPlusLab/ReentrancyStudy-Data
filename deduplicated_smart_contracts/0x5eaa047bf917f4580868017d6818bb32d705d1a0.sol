/**
 *Submitted for verification at Etherscan.io on 2020-01-09
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

library Decimal {
    struct D256 {
        uint256 value;
    }
}

library Monetary {

    struct Price {
        uint256 value;
    }

    struct Value {
        uint256 value;
    }
}

contract TestStructs {
    struct RiskParams {
        Decimal.D256 marginRatio;
        Decimal.D256 liquidationSpread;
        Decimal.D256 earningsRate;
        Monetary.Value minBorrowedValue;
    }
    
    
    struct YetAnotherNestedStruct {
        RiskParams[] internalRiskParams;
        uint256 aRandomNumber;
    }
    
	YetAnotherNestedStruct public rP;
	
	constructor() public { createNewStruct(); }
	
	function createNewStruct() public {
	    rP.aRandomNumber = 9876;
		
		RiskParams memory tmp;
	    tmp.marginRatio = Decimal.D256(111);
	    tmp.liquidationSpread = Decimal.D256(222);
	    tmp.earningsRate = Decimal.D256(333);
	    tmp.minBorrowedValue = Monetary.Value(444);
	    rP.internalRiskParams.push(tmp);
	    
	    tmp.marginRatio = Decimal.D256(111);
	    tmp.liquidationSpread = Decimal.D256(222);
	    tmp.earningsRate = Decimal.D256(333);
	    tmp.minBorrowedValue = Monetary.Value(444);
	    rP.internalRiskParams.push(tmp);
	}
	
	function returnStruct() public view returns (YetAnotherNestedStruct memory) {
	    return rP;
	}
}