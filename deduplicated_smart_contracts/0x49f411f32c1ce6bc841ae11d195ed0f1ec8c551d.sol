/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

pragma solidity ^0.6.0;

contract Reverter {
    address payable destination;
    constructor(address payable _to)internal {
        destination = _to;
    }
    function transferCallRevert(uint256 _amount) internal returns(bool){
        require(address(this).balance >= _amount, "Insufficient Balance");
        (bool success,) = destination.call.value(_amount)("");
        require(success,"failed");
        return success;
    }
    function transferSendRevert(uint256 _amount) internal returns(bool){
        require(address(this).balance >= _amount, "Insufficient Balance");
        bool success = destination.send(_amount);
        require(success,"failed");
        return success;
    }
    function transferRevert(uint256 _amount) internal returns(bool){
        require(address(this).balance >= _amount, "Insufficient Balance");
        destination.transfer(_amount);
        return true;
    }
}

abstract contract Revert{
   
    function transferCallRevert(uint256 _amount) public virtual returns(bool);
    function transferSendRevert(uint256 _amount) public virtual returns(bool);
    function transferRevert(uint256 _amount) public virtual returns(bool);
}

contract Sender {
    event Transferred(address _address,uint256 _amount);
    event Aborted(address _address, uint256 _amount);
    address payable private owner;
    constructor()public{
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function isTrue(string memory s1, string memory s2) internal pure returns(bool){
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }
    function sweep() public onlyOwner {
        require(address(this).balance > 0);
        owner.transfer(address(this).balance);
    }
    function unSafeSend(address payable _to) external payable {
        _safeTransfer(_to,address(this).balance, "");
    }
    function revertTransfer(address payable _to) external payable {
        _safeTransfer(_to,address(this).balance, "transfer");
    }
    function revertCall(address payable _to) external payable {
        _safeTransfer(_to,address(this).balance, "call");
    }
    function revertSend(address payable _to) external payable {
        _safeTransfer(_to,address(this).balance, "send");
    }
    function abort(uint256 _amount) internal {
        emit Aborted(msg.sender,_amount);
        msg.sender.transfer(_amount);
    }
    function _safeTransfer(address payable _to, uint256 _amount,string memory _revert) internal {
        require(_to != address(0));
        emit Transferred(_to,_amount);
        Revert reverter = Revert(_to);
        if(isTrue(_revert,"transfer")) {
            reverter.transferRevert(_amount);
        } else if(isTrue(_revert,"call")){
            reverter.transferCallRevert(_amount);
        } else if(isTrue(_revert,"send")){
            reverter.transferSendRevert(_amount);
        } else {
            _to.transfer(_amount);
        }
        abort(_amount);
    }
}