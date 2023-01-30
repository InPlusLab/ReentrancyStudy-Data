pragma solidity ^0.4.2;

import "./Lockable.sol";

contract IaToken is Lockable{

    mapping(string => uint) tokenDistribution;

    constructor(string _name, string _symbol, uint8 _decimals)
    DetailedERC20(_name, _symbol, _decimals)
    public{
        totalSupply_ = 5000000000 * 10 ** 18;
        balances[msg.sender] = totalSupply_;
        tokenDistribution['sale'] = 40;
        tokenDistribution['reserved'] = 40;
        tokenDistribution['marketing'] = 12;
        tokenDistribution['team'] = 8;
    }

    function getTokenDistributionPercentage(string  allocatee) public view returns(uint percentage){
        percentage = tokenDistribution[allocatee];
    }
}
