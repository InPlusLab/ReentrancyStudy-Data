/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

pragma solidity ^0.6.0;

contract Reverter {
    address payable destination;
    constructor(address payable _destination) public {
        destination = _destination;
    }
    function transferAndRevert(uint256 _amount) public {
        require(address(this).balance >= _amount, "Insufficient Balance");
        destination.transfer(_amount);
        revert();
    }
}

contract Sender {
    event Transferred(address _address,uint256 _amount);
    constructor()public{}
    function safeSend(address payable _to) external payable {
        _safeTransfer(_to,address(this).balance, false);
    }
    function revertSend(address payable _to) external payable {
        _safeTransfer(_to,address(this).balance, true);
    }
    function _safeTransfer(address payable _to, uint256 _amount,bool _revert) internal {
        require(_to != address(0));
        emit Transferred(_to,_amount);
        if(_revert == true) {
            Reverter reverter = Reverter(_to);
            reverter.transferAndRevert(_amount);
        } else {
            _to.transfer(_amount);
        }
        
    }
}