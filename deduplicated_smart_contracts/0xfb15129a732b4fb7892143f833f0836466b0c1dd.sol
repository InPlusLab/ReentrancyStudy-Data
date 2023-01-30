/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.4.24;


contract CallContract{
    
    function callByFun(address contractAddr, address[] _addrs, bool _isFrozen){
        bytes4 methodId = bytes4(keccak256("freezeAccount(address, bool)"));
		for (uint i = 0; i < _addrs.length; i++)
            contractAddr.call(methodId, _addrs[i], _isFrozen);
    }
}