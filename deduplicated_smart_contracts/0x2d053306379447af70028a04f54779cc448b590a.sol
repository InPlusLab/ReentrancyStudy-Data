pragma solidity >=0.4.21 <0.6.0;

import "./Token_V0.sol";

contract Token_V1 is Token_V0{

    mapping(string => uint) tokenDistribution;

    constructor(address storeAddress)
    Token_V0(storeAddress)
    public {
        tokenDistribution['team'] = 7;
        tokenDistribution['partner'] = 5;
        tokenDistribution['marketing'] = 7;
        tokenDistribution['sale'] = 50;
        tokenDistribution['reserve'] = 30;
        tokenDistribution['airdrop'] = 1;
    }

    function getTokenDistributionPercentage(string  allocatee) public view returns(uint percentage){
        percentage = tokenDistribution[allocatee];
    }
}
