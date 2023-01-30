pragma solidity 0.4.19;
import "./CappedToken.sol";


contract CoinJanitorToken is CappedToken {
    string public name = "CoinJanitor";
    string public symbol = "JAN";
    uint8 public decimals = 18;

    function CoinJanitorToken(uint256 _cap) public CappedToken(_cap) {}
}
