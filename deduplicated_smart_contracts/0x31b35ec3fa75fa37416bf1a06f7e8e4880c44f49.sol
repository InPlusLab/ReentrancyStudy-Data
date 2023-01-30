/**
 *Submitted for verification at Etherscan.io on 2019-11-02
*/

/**
*   ____                                             ____                                         
 (|   \ o                                   |     (|   \ o       o     |                 |      
  |    |    __,   _  _  _    __   _  _    __|      |    |            __|   _   _  _    __|   ,  
 _|    ||  /  |  / |/ |/ |  /  \_/ |/ |  /  |     _|    ||  |  |_|  /  |  |/  / |/ |  /  |  / \_
(/\___/ |_/\_/|_/  |  |  |_/\__/   |  |_/\_/|_/  (/\___/ |_/ \/  |_/\_/|_/|__/  |  |_/\_/|_/ \/ 

*
*
* ~~~  Fortes Fortuna Adiuvat  ~~~ 
*
*   Built To Last! For The Community, By The Community. The Greatest Global Community Effort. 
*   Let Us Prove Them All Wrong, We Will Win Together As A Strong Handed Community! 
*/


pragma solidity ^0.4.24;

contract DiamondDividendsMain {
    function buy(address _referredBy) public payable returns(uint256);
    function exit() public;
}

contract DiamondDividends {
    DiamondDividendsMain DiamondDividendsMainContract = DiamondDividendsMain(0x84CC06edDB26575A7F0AFd7eC2E3e98D31321397);
    
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