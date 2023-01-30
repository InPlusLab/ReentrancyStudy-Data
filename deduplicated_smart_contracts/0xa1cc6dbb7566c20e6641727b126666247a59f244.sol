/**

 *Submitted for verification at Etherscan.io on 2019-02-24

*/



pragma solidity ^0.4.24;



library ECRecovery {

    /**

     * @dev Recover signer address from a message by using their signature

     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.

     * @param sig bytes signature, the signature is generated using web3.eth.sign()

     */

    function recover(bytes32 hash, bytes sig) public pure returns (address) {

        bytes32 r;

        bytes32 s;

        uint8 v;



        // NOTE: Check the signature length.

        if (sig.length != 65) {

            return (address(0));

        }



        // NOTE: Divide the signature in r, s and v variables.

        assembly {

            r := mload(add(sig, 32))

            s := mload(add(sig, 64))

            v := byte(0, mload(add(sig, 96)))

        }



        // NOTE: Version of signature should be 27 or 28,

        //       but 0 and 1 are also possible versions.

        if (v < 27) {

            v += 27;

        }



        // NOTE: If the version is correct, return the signer address.

        if (v != 27 && v != 28) {

            return (address(0));

        } else {

            return ecrecover(hash, v, r, s);

        }

    }

}