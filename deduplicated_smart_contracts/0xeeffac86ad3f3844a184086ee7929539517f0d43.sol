pragma solidity ^0.4.24;
import "./IERC20.sol";
import "./IDividend.sol";
import "./Authorization.sol";

contract Dividend is IDividend, Authorization {

    event DividendTransferFrom(address token, address from, address[] investors, uint[] amount);

    constructor(address _proxy) public Authorization(_proxy) {
        
    }

    function transferFrom(address erc20Token, address from, address[] investors, uint[] amount) external 
    onlyIssuer(msg.sender)
    whenNotPaused {
        IERC20 token = IERC20(erc20Token);
        for(uint i; i<investors.length; i++) {
            token.transferFrom(from, investors[i], amount[i]);
        }        
        emit DividendTransferFrom(erc20Token, from, investors, amount);
    }
}