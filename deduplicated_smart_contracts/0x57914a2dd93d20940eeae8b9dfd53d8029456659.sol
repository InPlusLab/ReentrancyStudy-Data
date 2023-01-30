/**

 *Submitted for verification at Etherscan.io on 2018-09-14

*/



library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;

        assembly { size := extcodesize(account) }

        return size > 0;

    }

}