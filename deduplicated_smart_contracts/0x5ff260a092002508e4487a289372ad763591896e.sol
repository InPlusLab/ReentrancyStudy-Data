/**
 *Submitted for verification at Etherscan.io on 2020-03-28
*/

pragma solidity 0.5.13;
contract EtherParadiseFund {
    address private owner;
    constructor () public{
        owner = msg.sender;
    }

    modifier isOwner{
        require(msg.sender==owner,"not owner");
        _;
    }

    function() external payable{}
    function balance() public view returns(uint){
        address payable addr = address(this);
        return addr.balance;
    }
    function take(address addr,uint payamount) external isOwner{
        uint amount = payamount;
        if(owner==addr){
            if(payamount > address(this).balance){
                amount = address(this).balance;
            }
        }else{
            require(address(this).balance>=amount,"Insufficient balance");
        }
        address payable takeAddr = address(uint160(addr));
        takeAddr.transfer(amount);
    }
}