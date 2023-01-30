/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity 0.5.11;

contract INEC {
    function balanceOfAt(address _owner, uint _blockNumber) external view returns (uint);
}

contract NectarReader {
    
    INEC nectar;
    
    constructor (address _nectarAddress) public {
        nectar = INEC(_nectarAddress);
    }
    
    function effectiveNectarBalance(address _owner, uint32[] memory _blockNumbers) public view returns (uint256 effectiveBalance){
        for (uint32 i = 0; i < _blockNumbers.length; i++) {
            effectiveBalance += nectar.balanceOfAt(_owner, _blockNumbers[i])/_blockNumbers.length;
        }
    }
    
}