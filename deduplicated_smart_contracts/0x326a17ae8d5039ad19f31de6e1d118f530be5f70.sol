pragma solidity 0.5.17;

// Crowdsale Contract

import "./Crowdsale.sol";
import "./CappedCrowdsale.sol";
import "./TimedCrowdsale.sol";
import "./MorpheusToken.sol";
import "./MintedCrowdsale.sol";

contract MGTCrowdsale is
    Crowdsale,
    TimedCrowdsale,
    CappedCrowdsale,
    MintedCrowdsale
{
    constructor(address payable _deployer, address _gameAddress)
        public
        Crowdsale(50000, _deployer, new MorpheusToken(_deployer, _gameAddress))
        TimedCrowdsale(1607180400, 1607785200) // time began is 1607180400
        CappedCrowdsale(600 * 1E18)
    {
        //mint tokens for Marketing (3M) and Liquidity Pool (9 022 556)
        _deliverTokens(_deployer, 12022556 * 1E18);
    }
}
