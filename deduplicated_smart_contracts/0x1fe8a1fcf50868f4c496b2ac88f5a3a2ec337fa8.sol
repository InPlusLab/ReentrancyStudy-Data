/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

pragma solidity >=0.4.21 <0.7.0;

contract AddValues {
    address payable owner;
    event EventSeeAmount(uint256 amount);
    
    constructor () public{
        owner=msg.sender;
    }
    
    modifier onlyOwner{
        require (msg.sender == owner);
        _;
    }

    function () external payable{
        uint256 total;
        uint256 x = 3;
        uint256 y = 30;
        
        total = x + y;
        emit EventSeeAmount(total);
    }
    
    function destroy () public onlyOwner{
        selfdestruct(owner);
    }
    
}