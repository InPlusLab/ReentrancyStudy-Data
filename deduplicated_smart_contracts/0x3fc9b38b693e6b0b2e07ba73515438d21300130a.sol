pragma solidity >=0.4.21 <0.6.0;

import "./Token_V0.sol";

contract Token_V1 is Token_V0{

    mapping(string => uint) fundDistribution;

    constructor(address storeAddress)
    Token_V0(storeAddress)
    public {
        fundDistribution['development'] = 22;
        fundDistribution['business'] = 34;
        fundDistribution['marketing'] = 11;
        fundDistribution['legal'] = 11;
        fundDistribution['future'] = 22;
    }

    function getFundDistributionPercentage(string  allocatee) public view returns(uint percentage){
        percentage = fundDistribution[allocatee];
    }
}
