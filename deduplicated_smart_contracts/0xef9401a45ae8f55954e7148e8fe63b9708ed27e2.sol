/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

pragma solidity >=0.4.22 <0.7.0;

interface ISynthetix {
    function burnSynthsToTargetOnBehalf(address burnForAddress) external;
    function issueMaxSynthsOnBehalf(address issueForAddress) external;
    function remainingIssuableSynths(address issuer) external returns (uint256);
}

interface IFeePool {
    function claimOnBehalf(address claimingForAddress) external;
    function isFeesClaimable(address account) external returns (bool);
}

/**
 * @title Burn, Claim & Mint on behalf in 1 tx
 * 1. Delegate this contract address in mintr.synthetix.io 
 * 2. Call burnClaimMintSNX(your SNX account adddress)
 */
contract SNXClaimerZap {
    address synthetixProxy = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address feePoolProxy = 0xc43b833F93C3896472dED3EfF73311f571e38742;
    
    ISynthetix synthetix = ISynthetix(synthetixProxy);
    IFeePool feePool = IFeePool(feePoolProxy);

    function burnClaimMintSNX(address delegator) public returns (uint256) {
        
        if (!feePool.isFeesClaimable(delegator)) {
            synthetix.burnSynthsToTargetOnBehalf(delegator);
        }
        
        feePool.claimOnBehalf(delegator);
        
        if (synthetix.remainingIssuableSynths(delegator) > 0) {
            synthetix.issueMaxSynthsOnBehalf(delegator);
        }
        
        emit SNXClaimerZappedForAccount(delegator);
    }
    
    event SNXClaimerZappedForAccount(address delegator);
}