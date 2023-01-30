/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity ^0.6.0;

abstract contract IBadgerHunt {
    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) public virtual ;
}

abstract contract IERC20 {
    function transfer(address,uint) public virtual returns (bool);
}

contract BadgerCatcher {
    IBadgerHunt public constant badgerHunt = IBadgerHunt(0xC5C8933073B1c682aE07b4bc22d2249c220884bE);
    
    address public constant badgerTokenAddr = 0x3472A5A71965499acd81997a54BBA8D852C6E53d;
    
    function claimWithProxy(uint _index, uint _amount, bytes32[] memory _proof) public {
        badgerHunt.claim(_index, address(this), _amount, _proof);
        
        IERC20(badgerTokenAddr).transfer(msg.sender, _amount);
    }
    
    function getCallData(uint _index, uint _amount, bytes32[] memory _proof) public view returns (bytes memory) {
        return abi.encodeWithSignature(
            "claimWithProxy(uint256,uint256,bytes32[])",
            _index,
            _amount,
            _proof
        );
    }
 }