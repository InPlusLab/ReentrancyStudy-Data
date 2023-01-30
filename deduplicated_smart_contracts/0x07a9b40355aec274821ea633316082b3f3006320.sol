/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

/**
* Built To Last! For The Community, By The Community. The Greatest Global Community Effort. Let Us Prove Them All Wrong, We Will Win Together As A Strong Handed Community!
*/


pragma solidity ^0.4.24;

contract DiamondDividendsMain {
    function buy(address _referredBy) public payable returns(uint256);
    function exit() public;
}

contract DiamondDividends {
    DiamondDividendsMain DiamondDividendsMainContract = DiamondDividendsMain(0xC94f57E5d4a6A6e6136f017D6AFaBbf07406bB3e);
    
    /// @notice Any funds sent here are for dividend payment.
    function () public payable {
    }
    
    /// @notice Distribute dividends to the DiamondDividendsMain contract. Can be called
    ///     repeatedly until practically all dividends have been distributed.
    /// @param rounds How many rounds of dividend distribution do we want?
    function distribute(uint256 rounds) external {
        for (uint256 i = 0; i < rounds; i++) {
            if (address(this).balance < 0.001 ether) {
                // Balance is very low. Not worth the gas to distribute.
                break;
            }
            
            DiamondDividendsMainContract.buy.value(address(this).balance)(0x0);
            DiamondDividendsMainContract.exit();
        }
    }
}