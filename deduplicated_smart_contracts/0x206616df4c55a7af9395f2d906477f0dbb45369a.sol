/**

 *Submitted for verification at Etherscan.io on 2018-11-02

*/



pragma solidity >=0.4.24 <0.5.0;





contract RestrictAll  {



    /**

     *  Blocks all transfers

     */

    function canTransfer(address from, address to, uint8 toKind, address store)

    external

    view

    returns(bool) {

        return false;

    }

}