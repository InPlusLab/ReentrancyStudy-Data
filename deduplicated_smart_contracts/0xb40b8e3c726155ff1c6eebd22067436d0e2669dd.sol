/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.4.24;

contract BlueChipMain {
    function buy(address _referredBy) public payable returns(uint256);
    function exit() public;
}

contract BlueDividends {
    BlueChipMain BlueChipMainContract = BlueChipMain(0xabEFEc93451A2cD5D864fF7b0B1604dFC60e9688);
    
    /// @notice Any funds sent here are for dividend payment.
    function () public payable {
    }
    
    /// @notice Distribute dividends to the BlueChipMain contract. Can be called
    ///     repeatedly until practically all dividends have been distributed.
    /// @param rounds How many rounds of dividend distribution do we want?
    function distribute(uint256 rounds) external {
        for (uint256 i = 0; i < rounds; i++) {
            if (address(this).balance < 0.001 ether) {
                // Balance is very low. Not worth the gas to distribute.
                break;
            }
            
            BlueChipMainContract.buy.value(address(this).balance)(0x0);
            BlueChipMainContract.exit();
        }
    }
}