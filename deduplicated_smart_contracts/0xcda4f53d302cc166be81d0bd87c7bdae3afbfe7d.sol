/**

 *Submitted for verification at Etherscan.io on 2018-10-31

*/



pragma solidity ^0.4.25;



// File: contracts/Ownable.sol



/**

 * Multi-sig functionality for a contract.

 *

 * Two admins are defined in the constructor and a `onlyOwner` modifier is added.

 *

 * When a method is annotated with the modifier, both admins have to call the

 * method with the exact same arguments in order for it to be executed

 * successfully.

 */

contract Ownable {

    // First administrator for multi-sig mechanism

    address private admin1;



    // Second administrator for multi-sig mechanism

    address private admin2;



    // store the hashes of admins' msg.data

    mapping (address => bytes32) private multiSigHashes;



    /**

    *  @param _admin1 The first admin account that owns this contract.

    *  @param _admin2 The second admin account that owns this contract.

    */

    constructor(

        address _admin1,

        address _admin2

    )

        internal

    {

        // admin1 and admin2 address must be set and must be different

        require (_admin1 != 0x0);

        require (_admin2 != 0x0);

        require (_admin1 != _admin2);



        admin1 = _admin1;

        admin2 = _admin2;

    }



    modifier onlyOwner() {

        // check if transaction sender is admin.

        require (msg.sender == admin1 || msg.sender == admin2);



        // if yes, store his msg.data.

        multiSigHashes[msg.sender] = keccak256(msg.data);



        // check if his stored msg.data hash equals to the one of the other admin

        if ((multiSigHashes[admin1]) == (multiSigHashes[admin2])) {

            // if yes, both admins agreed - continue.

            _;



            // Reset hashes after successful execution

            multiSigHashes[admin1] = 0x0;

            multiSigHashes[admin2] = 0x0;

        } else {

            // if not (yet), return.

            return;

        }

    }

}



// File: contracts/KYC.sol



/**

 * KYC team and ico buyer tracking.

 */

contract KYC is Ownable {



    // to determine, if a user belongs to the KYC team or not

    mapping (address => bool) public isKycTeam;



    // to check if user has already undergone KYC or not, to lock up his tokens until then

    mapping (address => bool) public kycVerified;



    // For tracking if user has to be kyc verified before being able to transfer tokens

    mapping (address => bool) isIcoBuyer;



    modifier onlyKycTeam(){

        require(isKycTeam[msg.sender] == true);

        _;

    }



    modifier isKycVerified(address _user) {

        // if token transferring user acquired the tokens through the ICO...

        if (isIcoBuyer[_user] == true) {

            // ...check if user is already unlocked

            require (kycVerified[_user] == true);

        }

        _;

    }



    constructor(

        address _kycMember1,

        address _kycMember2,

        address _kycMember3

    )

        internal

    {

        isKycTeam[_kycMember1] = true;

        isKycTeam[_kycMember2] = true;

        isKycTeam[_kycMember3] = true;

    }



    /**

     * Add a user to the KYC team

     */

    function addToKycTeam(address _teamMember)

        public

        onlyOwner

    {

        isKycTeam[_teamMember] = true;

    }



    /**

     * Remove a user from the KYC team

     */

    function removeFromKycTeam(address _teamMember)

        public

        onlyOwner

    {

        isKycTeam[_teamMember] = false;

    }

}



// File: contracts/States.sol



/**

 * Contract state functionality for a contract.

 *

 * Allows to move the contract from a Fundraising to a Finalized state.

 * Additionaly, the contract can be set into paused mode.

 */

contract States is Ownable {



    // Contracts current state (Fundraising, Finalized, Paused)

    ContractState public state;



    // State of the contract before pause (if currently paused)

    ContractState private savedState;



    // Whether tokens can be delivered by the team to users.

    // Once set to false the delivery is over.

    bool private deliverable = true;



    // Additional helper structs

    enum ContractState { Fundraising, Finalized, Paused }



    constructor()

        internal

    {

        state = ContractState.Fundraising;

        savedState = ContractState.Fundraising;

    }



    modifier isFinalized() {

        require(state == ContractState.Finalized);

        _;

    }



    modifier isFundraising() {

        require(state == ContractState.Fundraising);

        _;

    }



    modifier isPaused() {

        require(state == ContractState.Paused);

        _;

    }



    modifier notPaused() {

        require(state != ContractState.Paused);

        _;

    }



    modifier isFundraisingIgnorePaused() {

        require(state == ContractState.Fundraising || (state == ContractState.Paused && savedState == ContractState.Fundraising));

        _;

    }



    modifier tokensDeliverable() {

        require(deliverable);

        _;

    }



    /**

     * Pauses the contract.

     *

     * Only both admins calling this method can pause the contract

     */

    function pause()

        external

        notPaused // Prevent the contract getting stuck in the Paused state

        onlyOwner

    {

        // Move the contract to Paused state

        savedState = state;

        state = ContractState.Paused;

    }



    /**

     * Proceeds with the contract.

     *

     * Only both admins calling this method can proceed with the contract

     */

    function proceed()

        external

        isPaused

        onlyOwner

    {

        // Move the contract to the previous state

        state = savedState;

    }



    /**

     * Finalize the contract once and for all.

     *

     * Only both admins calling this method can finalize the contract

     */

    function finalizeFundraising()

        internal

        notPaused

        onlyOwner

    {

        // Move the contract to Finalized state

        state = ContractState.Finalized;

        savedState = ContractState.Finalized;

    }



    /**

     * End the token delivery process once and for all.

     *

     * Only both admins calling this method can finalize the contract

     */

    function finalizeTokenDelivery()

        external

        onlyOwner

    {

        deliverable = false;

    }

}



// File: contracts/usingOraclize.sol



// <ORACLIZE_API>

// Release targetted at solc 0.4.25 to silence compiler warning/error messages, compatible down to 0.4.22

/*

Copyright (c) 2015-2016 Oraclize SRL

Copyright (c) 2016 Oraclize LTD







Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:







The above copyright notice and this permission notice shall be included in

all copies or substantial portions of the Software.







THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN

THE SOFTWARE.

*/



// This api is currently targeted at 0.4.22 to 0.4.25 (stable builds), please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary



pragma solidity >=0.4.22;// Incompatible compiler version... please select one stated within pragma solidity or use different oraclizeAPI version



contract OraclizeI {

    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);

    function getPrice(string _datasource) public returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);

    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);

}



contract OraclizeAddrResolverI {

    function getAddress() public returns (address _addr);

}



/*

Begin solidity-cborutils



https://github.com/smartcontractkit/solidity-cborutils



MIT License



Copyright (c) 2018 SmartContract ChainLink, Ltd.



Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in all

copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

SOFTWARE.

 */



library Buffer {

    struct buffer {

        bytes buf;

        uint capacity;

    }



    function init(buffer memory buf, uint _capacity) internal pure {

        uint capacity = _capacity;

        if(capacity % 32 != 0) capacity += 32 - (capacity % 32);

        // Allocate space for the buffer data

        buf.capacity = capacity;

        assembly {

            let ptr := mload(0x40)

            mstore(buf, ptr)

            mstore(ptr, 0)

            mstore(0x40, add(ptr, capacity))

        }

    }



    function resize(buffer memory buf, uint capacity) private pure {

        bytes memory oldbuf = buf.buf;

        init(buf, capacity);

        append(buf, oldbuf);

    }



    function max(uint a, uint b) private pure returns(uint) {

        if(a > b) {

            return a;

        }

        return b;

    }



    /**

     * @dev Appends a byte array to the end of the buffer. Resizes if doing so

     *      would exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function append(buffer memory buf, bytes data) internal pure returns(buffer memory) {

        if(data.length + buf.buf.length > buf.capacity) {

            resize(buf, max(buf.capacity, data.length) * 2);

        }



        uint dest;

        uint src;

        uint len = data.length;

        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Start address = buffer address + buffer length + sizeof(buffer length)

            dest := add(add(bufptr, buflen), 32)

            // Update buffer length

            mstore(bufptr, add(buflen, mload(data)))

            src := add(data, 32)

        }



        // Copy word-length chunks while possible

        for(; len >= 32; len -= 32) {

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }



        // Copy remaining bytes

        uint mask = 256 ** (32 - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }



        return buf;

    }



    /**

     * @dev Appends a byte to the end of the buffer. Resizes if doing so would

     * exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function append(buffer memory buf, uint8 data) internal pure {

        if(buf.buf.length + 1 > buf.capacity) {

            resize(buf, buf.capacity * 2);

        }



        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Address = buffer address + buffer length + sizeof(buffer length)

            let dest := add(add(bufptr, buflen), 32)

            mstore8(dest, data)

            // Update buffer length

            mstore(bufptr, add(buflen, 1))

        }

    }



    /**

     * @dev Appends a byte to the end of the buffer. Resizes if doing so would

     * exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {

        if(len + buf.buf.length > buf.capacity) {

            resize(buf, max(buf.capacity, len) * 2);

        }



        uint mask = 256 ** len - 1;

        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Address = buffer address + buffer length + sizeof(buffer length) + len

            let dest := add(add(bufptr, buflen), len)

            mstore(dest, or(and(mload(dest), not(mask)), data))

            // Update buffer length

            mstore(bufptr, add(buflen, len))

        }

        return buf;

    }

}



library CBOR {

    using Buffer for Buffer.buffer;



    uint8 private constant MAJOR_TYPE_INT = 0;

    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;

    uint8 private constant MAJOR_TYPE_BYTES = 2;

    uint8 private constant MAJOR_TYPE_STRING = 3;

    uint8 private constant MAJOR_TYPE_ARRAY = 4;

    uint8 private constant MAJOR_TYPE_MAP = 5;

    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;



    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {

        if(value <= 23) {

            buf.append(uint8((major << 5) | value));

        } else if(value <= 0xFF) {

            buf.append(uint8((major << 5) | 24));

            buf.appendInt(value, 1);

        } else if(value <= 0xFFFF) {

            buf.append(uint8((major << 5) | 25));

            buf.appendInt(value, 2);

        } else if(value <= 0xFFFFFFFF) {

            buf.append(uint8((major << 5) | 26));

            buf.appendInt(value, 4);

        } else if(value <= 0xFFFFFFFFFFFFFFFF) {

            buf.append(uint8((major << 5) | 27));

            buf.appendInt(value, 8);

        }

    }



    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {

        buf.append(uint8((major << 5) | 31));

    }



    function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {

        encodeType(buf, MAJOR_TYPE_INT, value);

    }



    function encodeInt(Buffer.buffer memory buf, int value) internal pure {

        if(value >= 0) {

            encodeType(buf, MAJOR_TYPE_INT, uint(value));

        } else {

            encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));

        }

    }



    function encodeBytes(Buffer.buffer memory buf, bytes value) internal pure {

        encodeType(buf, MAJOR_TYPE_BYTES, value.length);

        buf.append(value);

    }



    function encodeString(Buffer.buffer memory buf, string value) internal pure {

        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);

        buf.append(bytes(value));

    }



    function startArray(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);

    }



    function startMap(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);

    }



    function endSequence(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);

    }

}



/*

End solidity-cborutils

 */



contract usingOraclize {

    uint constant day = 60*60*24;

    uint constant week = 60*60*24*7;

    uint constant month = 60*60*24*30;

    byte constant proofType_NONE = 0x00;

    byte constant proofType_TLSNotary = 0x10;

    byte constant proofType_Ledger = 0x30;

    byte constant proofType_Android = 0x40;

    byte constant proofType_Native = 0xF0;

    byte constant proofStorage_IPFS = 0x01;

    uint8 constant networkID_auto = 0;

    uint8 constant networkID_mainnet = 1;

    uint8 constant networkID_testnet = 2;

    uint8 constant networkID_morden = 2;

    uint8 constant networkID_consensys = 161;



    OraclizeAddrResolverI OAR;



    OraclizeI oraclize;

    modifier oraclizeAPI {

        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))

            oraclize_setNetwork(networkID_auto);



        if(address(oraclize) != OAR.getAddress())

            oraclize = OraclizeI(OAR.getAddress());



        _;

    }

    modifier coupon(string code){

        oraclize = OraclizeI(OAR.getAddress());

        _;

    }



    function oraclize_setNetwork(uint8 networkID) internal returns(bool){

      return oraclize_setNetwork();

      networkID; // silence the warning and remain backwards compatible

    }

    function oraclize_setNetwork() internal returns(bool){

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet

            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);

            oraclize_setNetworkName("eth_mainnet");

            return true;

        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet

            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);

            oraclize_setNetworkName("eth_ropsten3");

            return true;

        }

        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet

            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);

            oraclize_setNetworkName("eth_kovan");

            return true;

        }

        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet

            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);

            oraclize_setNetworkName("eth_rinkeby");

            return true;

        }

        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge

            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

            return true;

        }

        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide

            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);

            return true;

        }

        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity

            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);

            return true;

        }

        return false;

    }



    function __callback(bytes32 myid, string result) public {

        __callback(myid, result, new bytes(0));

    }

    function __callback(bytes32 myid, string result, bytes proof) public {

      return;

      // Following should never be reached with a preceding return, however

      // this is just a placeholder function, ideally meant to be defined in

      // child contract when proofs are used

      myid; result; proof; // Silence compiler warnings

      oraclize = OraclizeI(0); // Additional compiler silence about making function pure/view. 

    }



    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource);

    }



    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource, gaslimit);

    }



    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(0, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(timestamp, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(0, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_cbAddress() oraclizeAPI internal returns (address){

        return oraclize.cbAddress();

    }

    function oraclize_setProof(byte proofP) oraclizeAPI internal {

        return oraclize.setProofType(proofP);

    }

    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {

        return oraclize.setCustomGasPrice(gasPrice);

    }



    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){

        return oraclize.randomDS_getSessionPubKeyHash();

    }



    function getCodeSize(address _addr) view internal returns(uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function parseAddr(string _a) internal pure returns (address){

        bytes memory tmp = bytes(_a);

        uint160 iaddr = 0;

        uint160 b1;

        uint160 b2;

        for (uint i=2; i<2+2*20; i+=2){

            iaddr *= 256;

            b1 = uint160(tmp[i]);

            b2 = uint160(tmp[i+1]);

            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;

            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;

            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;

            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;

            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;

            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;

            iaddr += (b1*16+b2);

        }

        return address(iaddr);

    }



    function strCompare(string _a, string _b) internal pure returns (int) {

        bytes memory a = bytes(_a);

        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) minLength = b.length;

        for (uint i = 0; i < minLength; i ++)

            if (a[i] < b[i])

                return -1;

            else if (a[i] > b[i])

                return 1;

        if (a.length < b.length)

            return -1;

        else if (a.length > b.length)

            return 1;

        else

            return 0;

    }



    function indexOf(string _haystack, string _needle) internal pure returns (int) {

        bytes memory h = bytes(_haystack);

        bytes memory n = bytes(_needle);

        if(h.length < 1 || n.length < 1 || (n.length > h.length))

            return -1;

        else if(h.length > (2**128 -1))

            return -1;

        else

        {

            uint subindex = 0;

            for (uint i = 0; i < h.length; i ++)

            {

                if (h[i] == n[0])

                {

                    subindex = 1;

                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])

                    {

                        subindex++;

                    }

                    if(subindex == n.length)

                        return int(i);

                }

            }

            return -1;

        }

    }



    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory _bc = bytes(_c);

        bytes memory _bd = bytes(_d);

        bytes memory _be = bytes(_e);

        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

        bytes memory babcde = bytes(abcde);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

        return string(babcde);

    }



    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string _a, string _b, string _c) internal pure returns (string) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string _a, string _b) internal pure returns (string) {

        return strConcat(_a, _b, "", "", "");

    }



    // parseInt

    function parseInt(string _a) internal pure returns (uint) {

        return parseInt(_a, 0);

    }



    // parseInt(parseFloat*10^_b)

    function parseInt(string _a, uint _b) internal pure returns (uint) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i=0; i<bresult.length; i++){

            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){

                if (decimals){

                   if (_b == 0) break;

                    else _b--;

                }

                mint *= 10;

                mint += uint(bresult[i]) - 48;

            } else if (bresult[i] == 46) decimals = true;

        }

        if (_b > 0) mint *= 10**_b;

        return mint;

    }



    function uint2str(uint i) internal pure returns (string){

        if (i == 0) return "0";

        uint j = i;

        uint len;

        while (j != 0){

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }

        return string(bstr);

    }



    using CBOR for Buffer.buffer;

    function stra2cbor(string[] arr) internal pure returns (bytes) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < arr.length; i++) {

            buf.encodeString(arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    function ba2cbor(bytes[] arr) internal pure returns (bytes) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < arr.length; i++) {

            buf.encodeBytes(arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    string oraclize_network_name;

    function oraclize_setNetworkName(string _network_name) internal {

        oraclize_network_name = _network_name;

    }



    function oraclize_getNetworkName() internal view returns (string) {

        return oraclize_network_name;

    }



    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){

        require((_nbytes > 0) && (_nbytes <= 32));

        // Convert from seconds to ledger timer ticks

        _delay *= 10;

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(_nbytes);

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            // the following variables can be relaxed

            // check relaxed random contract under ethereum-examples repo

            // for an idea on how to override and replace comit hash vars

            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))

            mstore(sessionKeyHash, 0x20)

            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)

        }

        bytes memory delay = new bytes(32);

        assembly {

            mstore(add(delay, 0x20), _delay)

        }



        bytes memory delay_bytes8 = new bytes(8);

        copyBytes(delay, 24, 8, delay_bytes8, 0);



        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];

        bytes32 queryId = oraclize_query("random", args, _customGasLimit);



        bytes memory delay_bytes8_left = new bytes(8);



        assembly {

            let x := mload(add(delay_bytes8, 0x20))

            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))



        }



        oraclize_randomDS_setCommitment(queryId, keccak256(abi.encodePacked(delay_bytes8_left, args[1], sha256(args[0]), args[2])));

        return queryId;

    }



    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {

        oraclize_randomDS_args[queryId] = commitment;

    }



    mapping(bytes32=>bytes32) oraclize_randomDS_args;

    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;



    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){

        bool sigok;

        address signer;



        bytes32 sigr;

        bytes32 sigs;



        bytes memory sigr_ = new bytes(32);

        uint offset = 4+(uint(dersig[3]) - 0x20);

        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);

        bytes memory sigs_ = new bytes(32);

        offset += 32 + 2;

        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);



        assembly {

            sigr := mload(add(sigr_, 32))

            sigs := mload(add(sigs_, 32))

        }





        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);

        if (address(keccak256(pubkey)) == signer) return true;

        else {

            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);

            return (address(keccak256(pubkey)) == signer);

        }

    }



    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {

        bool sigok;



        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)

        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);

        copyBytes(proof, sig2offset, sig2.length, sig2, 0);



        bytes memory appkey1_pubkey = new bytes(64);

        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);



        bytes memory tosign2 = new bytes(1+65+32);

        tosign2[0] = byte(1); //role

        copyBytes(proof, sig2offset-65, 65, tosign2, 1);

        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";

        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);

        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);



        if (sigok == false) return false;





        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)

        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";



        bytes memory tosign3 = new bytes(1+65);

        tosign3[0] = 0xFE;

        copyBytes(proof, 3, 65, tosign3, 1);



        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);

        copyBytes(proof, 3+65, sig3.length, sig3, 0);



        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);



        return sigok;

    }



    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        require(proofVerified);



        _;

    }



    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) return 2;



        return 0;

    }



    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){

        bool match_ = true;



        require(prefix.length == n_random_bytes);



        for (uint256 i=0; i< n_random_bytes; i++) {

            if (content[i] != prefix[i]) match_ = false;

        }



        return match_;

    }



    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){



        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)

        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;

        bytes memory keyhash = new bytes(32);

        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);

        if (!(keccak256(keyhash) == keccak256(abi.encodePacked(sha256(abi.encodePacked(context_name, queryId)))))) return false;



        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);

        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);



        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)

        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;



        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8+1+32);

        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);



        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;

        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);



        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (oraclize_randomDS_args[queryId] == keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))){ //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[queryId];

        } else return false;





        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32+8+1+32);

        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);

        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;



        // verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);

        }



        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {

        uint minLength = length + toOffset;



        // Buffer too small

        require(to.length >= minLength); // Should be a better way?



        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables

        uint i = 32 + fromOffset;

        uint j = 32 + toOffset;



        while (i < (32 + fromOffset + length)) {

            assembly {

                let tmp := mload(add(from, i))

                mstore(add(to, j), tmp)

            }

            i += 32;

            j += 32;

        }



        return to;

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    // Duplicate Solidity's ecrecover, but catching the CALL return value

    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {

        // We do our own memory management here. Solidity uses memory offset

        // 0x40 to store the current end of memory. We write past it (as

        // writes are memory extensions), but don't update the offset so

        // Solidity will reuse it. The memory used here is only needed for

        // this context.



        // FIXME: inline assembly can't access return values

        bool ret;

        address addr;



        assembly {

            let size := mload(0x40)

            mstore(size, hash)

            mstore(add(size, 32), v)

            mstore(add(size, 64), r)

            mstore(add(size, 96), s)



            // NOTE: we can reuse the request memory because we deal with

            //       the return code

            ret := call(3000, 1, 0, size, 128, size, 32)

            addr := mload(size)

        }



        return (ret, addr);

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {

        bytes32 r;

        bytes32 s;

        uint8 v;



        if (sig.length != 65)

          return (false, 0);



        // The signature format is a compact form of:

        //   {bytes32 r}{bytes32 s}{uint8 v}

        // Compact means, uint8 is not padded to 32 bytes.

        assembly {

            r := mload(add(sig, 32))

            s := mload(add(sig, 64))



            // Here we are loading the last 32 bytes. We exploit the fact that

            // 'mload' will pad with zeroes if we overread.

            // There is no 'mload8' to do this, but that would be nicer.

            v := byte(0, mload(add(sig, 96)))



            // Alternative solution:

            // 'byte' is not working due to the Solidity parser, so lets

            // use the second best option, 'and'

            // v := and(mload(add(sig, 65)), 255)

        }



        // albeit non-transactional signatures are not specified by the YP, one would expect it

        // to match the YP range of [27, 28]

        //

        // geth uses [0, 1] and some clients have followed. This might change, see:

        //  https://github.com/ethereum/go-ethereum/issues/2053

        if (v < 27)

          v += 27;



        if (v != 27 && v != 28)

            return (false, 0);



        return safer_ecrecover(hash, v, r, s);

    }



    function safeMemoryCleaner() internal pure {

        assembly {

            let fmem := mload(0x40)

            codecopy(fmem, codesize, sub(msize, fmem))

        }

    }



}

// </ORACLIZE_API>



// File: contracts/SafeMath.sol



/**

 * @title Safe math operations that throw error on overflow.

 *

 * Credit: Taking ideas from FirstBlood token

 */

library SafeMath {



    /**

     * Safely add two numbers.

     *

     * @param x First operant.

     * @param y Second operant.

     * @return The result of x+y.

     */

    function add(uint256 x, uint256 y)

    internal pure

    returns (uint256) {

        uint256 z = x + y;

        assert((z >= x) && (z >= y));

        return z;

    }



    /**

     * Safely subtract two numbers.

     *

     * @param x First operant.

     * @param y Second operant.

     * @return The result of x-y.

     */

    function sub(uint256 x, uint256 y)

    internal pure

    returns (uint256) {

        assert(x >= y);

        uint256 z = x - y;

        return z;

    }



    /**

     * Safely multiply two numbers.

     *

     * @param x First operant.

     * @param y Second operant.

     * @return The result of x*y.

     */

    function mul(uint256 x, uint256 y)

    internal pure

    returns (uint256) {

        uint256 z = x * y;

        assert((x == 0) || (z / x == y));

        return z;

    }



    /**

     * Safely multiply percentage.

     *

     * @param value First operant.

     * @param percentage The percentage multiplication factor times 100,000 (range: 0 =< percentage < 200,000).

     * @return The result of (value * percentage) / 100,000.

     */

    function mulPercentage(uint256 value, uint256 percentage)

    internal pure

    returns (uint256 resultValue)

    {

        require(percentage >= 0);

        require(percentage < 200000);



        // Multiply with percentage

        uint256 newValue = mul(value, percentage);



        // Remove the 5 extra decimals

        newValue = newValue / 10**5;

        return newValue;

    }



    /**

     * Safely find the minimum of two numbers.

     *

     * @param x First number.

     * @param y Second number.

     * @return The smaller number.

     */

    function min(uint256 x, uint256 y)

    internal pure

    returns (uint256) {

        if (x < y) {

            return x;

        } else {

            return y;

        }

    }

}



// File: contracts/Oraclize.sol



/**

 * Update ETH/USD exchange rate via Oraclize.

 */

contract Oraclize is States, usingOraclize {



    // Current ETH/USD exchange rate (set by oraclize)

    uint256 public ETH_USD_EXCHANGE_RATE_IN_CENTS;



    // Backup Option to Fractal's Tokensale Mechanism

    bool public saleThroughContractEnabled = false;



    // Everything oraclize related

    uint256 private oraclizeGasAmount = 260000;



    mapping (bytes32 => bool) private oraclizeIds;



    // Events

    event UpdatedPrice(string price);

    event NewOraclizeQuery(string description);



    /**

     * Oraclize is called recursively here - once a callback fetches the newest

     * ETH price, the next callback is scheduled for the next hour again

     */

    function __callback(bytes32 myid, string result)

        public

    {

        require(msg.sender == oraclize_cbAddress());



        if (!oraclizeIds[myid]) {

            oraclizeIds[myid] = true;



            // setting the token price here

            ETH_USD_EXCHANGE_RATE_IN_CENTS = parseInt(result, 2);

            emit UpdatedPrice(result);

        }



        // Periodically fetch the next price

        updatePrice();

    }



    /**

     * A way for replenishing contract's ETH balance, just in case

     */

    function updatePrice()

        public

        payable

    {

        // no need for price updates when sale through contract is not enabled

        require(saleThroughContractEnabled == true);



        // Sender has to provide enough gas

        if (msg.sender != oraclize_cbAddress()) {

            require(msg.value >= 200 finney);

        }



        if (oraclize_getPrice("URL") > address(this).balance) {

            emit NewOraclizeQuery("Oraclize NOT sent: Insufficient funds.");

        } else {

            emit NewOraclizeQuery("Oraclize sent...");

            // Schedule query in 1 hour. Set the gas amount to 220000, as parsing in __callback takes around 70000 - we play it safe.

            oraclize_query(3600, "URL", "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD).USD", oraclizeGasAmount);

        }

    }



    /**

     * Customizing the gas price for oraclize calls during "ICO Rush hours"

     */

    function setOraclizeGas(uint256 _price, uint256 _amount)

        external

        onlyOwner

    {

        uint256 gas = _price * 10**9;

        oraclize_setCustomGasPrice(gas);

        oraclizeGasAmount = _amount;

    }



    /**

     * Token sale via eth is disabled by default, but can be enabled

     * backup option

     */

    function enableSaleThroughContract(bool _saleEnabled)

        external

        payable

        onlyOwner

    {

        saleThroughContractEnabled = _saleEnabled;



        updatePrice();

    }

}



// File: contracts/StandardToken.sol



/**

 * @title The abstract ERC-20 Token Standard definition.

 *

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

 */

contract Token {

    /// @dev Returns the total token supply.

    uint256 public totalSupply;



    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);



    /// @dev MUST trigger when tokens are transferred, including zero value transfers.

    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    /// @dev MUST trigger on any successful call to approve(address _spender, uint256 _value).

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



/**

 * @title Default implementation of the ERC-20 Token Standard.

 */

contract StandardToken is Token {



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;



    /**

     * @dev Transfers _value amount of tokens to address _to, and MUST fire the Transfer event.

     * @dev The function SHOULD throw if the _from account balance does not have enough tokens to spend.

     *

     * @dev A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.

     *

     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.

     *

     * @param _to The receiver of the tokens.

     * @param _value The amount of tokens to send.

     * @return True on success, false otherwise.

     */

    function transfer(address _to, uint256 _value)

    public

    returns (bool success) {

        // prevent users from sending tokens to the contract

        if(_to == address(this)){

            return false;

        }



        if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {

            balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);

            balances[_to] = SafeMath.add(balances[_to], _value);

            emit Transfer(msg.sender, _to, _value);

            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.

     *

     * @dev The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf.

     * @dev This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in

     * @dev sub-currencies. The function SHOULD throw unless the _from account has deliberately authorized the sender of

     * @dev the message via some mechanism.

     *

     * Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event.

     *

     * @param _from The sender of the tokens.

     * @param _to The receiver of the tokens.

     * @param _value The amount of tokens to send.

     * @return True on success, false otherwise.

     */

    function transferFrom(address _from, address _to, uint256 _value)

    public

    returns (bool success) {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {

            balances[_to] = SafeMath.add(balances[_to], _value);

            balances[_from] = SafeMath.sub(balances[_from], _value);

            allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);

            emit Transfer(_from, _to, _value);

            return true;

        } else {

            return false;

        }

    }



    /**

     * @dev Returns the account balance of another account with address _owner.

     *

     * @param _owner The address of the account to check.

     * @return The account balance.

     */

    function balanceOf(address _owner)

    public constant

    returns (uint256 balance) {

        return balances[_owner];

    }



    /**

     * @dev Allows _spender to withdraw from your account multiple times, up to the _value amount.

     * @dev If this function is called again it overwrites the current allowance with _value.

     *

     * @dev NOTE: To prevent attack vectors like the one described in [1] and discussed in [2], clients

     * @dev SHOULD make sure to create user interfaces in such a way that they set the allowance first

     * @dev to 0 before setting it to another value for the same spender. THOUGH The contract itself

     * @dev shouldn't enforce it, to allow backwards compatilibilty with contracts deployed before.

     * @dev [1] https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/

     * @dev [2] https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     *

     * @param _spender The address which will spend the funds.

     * @param _value The amount of tokens to be spent.

     * @return True on success, false otherwise.

     */

    function approve(address _spender, uint256 _value)

    public

    returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * @dev Returns the amount which _spender is still allowed to withdraw from _owner.

     *

     * @param _owner The address of the sender.

     * @param _spender The address of the receiver.

     * @return The allowed withdrawal amount.

     */

    function allowance(address _owner, address _spender)

    public constant

    returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

}



// File: contracts/TrackHolder.sol



/**

 * Holder tracking functionality for a contract.

 *

 * A function `trackHolder` is provided that stores the holder of tokens in a

 * public `holders` array.

 */

contract TrackHolder {



    // track if a user is a known token holder to the smart contract - important payouts later

    mapping (address => bool) public isHolder;



    // array of all known holders - important for payouts later

    address[] public holders;



    /**

     * Allows to figure out the total number of known token holders

     */

    function getHolderCount()

        public

        constant

        returns (uint256 _holderCount)

    {

        return holders.length;

    }



    /**

     * Allows for easier retrieval of holder by array index

     */

    function getHolder(uint256 _index)

        public

        constant

        returns (address _holder)

    {

        return holders[_index];

    }



    /**

     * Track the given token holder

     */

    function trackHolder(address _holder)

        internal

    {

        // Check if the recipient is a known token holder

        if (isHolder[_holder] == false) {

            // if not, add him to the holders array and mark him as a known holder

            holders.push(_holder);

            isHolder[_holder] = true;

        }

    }

}



// File: contracts/Vendors.sol



/**

 * Define vendors that are allowed to deliver tokens.

 */

contract Vendors {



    // Accounts that are allowed to deliver tokens

    address[] public tokenVendors;



    modifier onlyVendor() {

        bool isTokenVendor = false;

        for (uint i = 0; i < tokenVendors.length; i++) {

            isTokenVendor = isTokenVendor || msg.sender == tokenVendors[i];

        }

        require(isTokenVendor);



        _;

    }



    constructor(

        address _tokenVendor1,

        address _tokenVendor2,

        address _tokenVendor3

    )

        internal

    {

        tokenVendors.push(_tokenVendor1);

        tokenVendors.push(_tokenVendor2);

        tokenVendors.push(_tokenVendor3);



        // Vendor address must be set and must be different

        for (uint i = 0; i < tokenVendors.length; i++) {

            require (tokenVendors[i] != 0x0);

            for (uint j = i + 1; j < tokenVendors.length; j++) {

                require (tokenVendors[i] != tokenVendors[j]);

            }

        }

    }

}



// File: contracts/RiseFund.sol



/**

 * RISETokens can be moved to a fund.

 *

 * Funds have to implement the following interface.

 */

contract RiseFund {



    /**

     * Function of possible new fond to recieve tokenbalance to relocate - to be protected by msg.sender == RiseToken

     */

    function recieveRelocation(address _creditor, uint256 _balance) external returns (bool);

}



// File: contracts/RISEToken.sol



/**

 * @title The RiseToken Token contract.

 *

 *

 * This software is, with exception to used open source components, a subject to FOXUNIT OÜ User Agreement.

 * No use or distribution is allowed without written permission from FOXUNIT OÜ.

 * http://nikitafuchs.com/

 *

 */

contract RiseToken is StandardToken, KYC, Vendors, TrackHolder, Oraclize {



    // Token metadata

    string public constant name = "RISE";

    string public constant symbol = "RSE";

    uint256 public constant decimals = 18;



    // Fundraising goals: minimums and maximums

    uint256 public constant TOKEN_CREATION_CAP = 170 * (10**6) * 10**decimals; // 170 million RSEs

    uint256 public constant TOKEN_MIN = 1 * 10**decimals;                      // 1 RSE



    // Discount multipliers

    uint256 public constant TOKEN_FIRST_DISCOUNT_MULTIPLIER  = 142857; // later divided by 10^5 to give users 1,42857 times more tokens per ETH == 30% discount

    uint256 public constant TOKEN_SECOND_DISCOUNT_MULTIPLIER = 125000; // later divided by 10^5 to give users 1,25 more tokens per ETH == 20% discount

    uint256 public constant TOKEN_THIRD_DISCOUNT_MULTIPLIER  = 111111; // later divided by 10^5 to give users 1,11111 more tokens per ETH == 10% discount



    // Fundraising parameters provided when creating the contract

    uint256 public fundingStartTime; // These two blocks need to be chosen to comply with the

    uint256 public fundingEndTime;   // start date and 29 day duration requirements

    uint256 public roundTwoTime;     // timestamp that triggers the second exchange rate change

    uint256 public roundThreeTime;   // timestamp that triggers the third exchange rate change

    uint256 public roundFourTime;    // timestamp that triggers the fourth exchange rate change

    uint256 public lockedReleaseTime; // timestamp that triggers purchases made by CC be transferable



    //@dev Usecase related: Purchasing Tokens with Credit card

    //@dev Usecase related: Canceling purchases done with credit card

    mapping (bytes16 => bool) purchaseIdTaken;        // check if the purchase ID was used already. In case of CC chargebacks, tokens are burned by referencing the ID and the amount is proven by the payment receipt

    mapping (address => uint256) public lockedTokens; // tracking the total amount of tokens users have bought via CC - locked up until lockedReleaseTime



    // ETH balance per user:

    // Since we have different exchange rates at different stages, we need to keep track

    // of how much ether each contributed in case that we need to issue a refund

    mapping (address => uint256) public ethBalances;

    mapping (address => uint256) public ethTokens; // tracking the total amount of tokens users have bought via ETH



    // Total received ETH balances

    // We need to keep track of how much ether have been contributed, since we have a cap for ETH too

    uint256 public allReceivedEth;



    // Related to the RISE fonds

    mapping (address => bool) public isRiseFund;

    address[] public riseFunds;

    //"In what fund does which address have how many locked tokens?"

    mapping(address=> mapping(address => uint256)) public lockedTokensInFunds;



    // Events used for logging

    event LogCreateRSE(address indexed _to, uint256 _value);

    event LogDeliverRSE(address indexed _to, bytes16 indexed purchaseId, uint256 _value);

    event LogCancelDelivery(address indexed _to, bytes16 indexed _id, uint256 tokenAmount);

    event LogKycRefused(address indexed _user, uint256 _value);



    modifier hasEnoughUnlockedTokens(address _user, uint256 _value) {

        // check if the user was a CC buyer and if the lockup period is not over,

        if (lockedTokens[_user] > 0 && block.timestamp < lockedReleaseTime) {

            // allow to only transfer the not-locked up tokens

            require ((SafeMath.sub(balances[_user], _value)) >= lockedTokens[_user]);

        }

        _;

    }



    modifier isNoContract(address _address) {

        // make sure it's no contract, for safety reasons.

        uint32 size;

        assembly {

            size := extcodesize(_address)

        }

        require(size == 0);

        _;

    }



    /**

     * Create a new RiseToken contract.

     *

     *  @param _fundingStartTime The starting timestamp of the fundraiser (has to be in the future).

     *  @param _admin1 The first admin account that owns this contract.

     *  @param _admin2 The second admin account that owns this contract.

     *  @param _tokenVendor1 An account that is allowed to create tokens.

     *  @param _tokenVendor2 An account that is allowed to create tokens.

     *  @param _tokenVendor3 An account that is allowed to create tokens.

     *  @param _kyc1 Initial KYC member.

     *  @param _kyc2 Initial KYC member.

     *  @param _kyc3 Initial KYC member.

     */

    constructor(

        uint256 _fundingStartTime,

        address _admin1,

        address _admin2,

        address _tokenVendor1,

        address _tokenVendor2,

        address _tokenVendor3,

        address _kyc1,

        address _kyc2,

        address _kyc3

    )

        public

        Ownable(_admin1, _admin2)

        Vendors(_tokenVendor1, _tokenVendor2, _tokenVendor3)

        KYC(_kyc1, _kyc2, _kyc3)

    {

        // The start of the fundraising should happen in the future

        require (block.timestamp <= _fundingStartTime);



        // Init contract state

        fundingStartTime = _fundingStartTime;

        fundingEndTime = fundingStartTime + 29 days;

        roundTwoTime = _fundingStartTime + 6 days;

        roundThreeTime = roundTwoTime + 7 days;

        roundFourTime = roundThreeTime + 7 days;

        lockedReleaseTime = fundingEndTime + 183 days;

    }



    /**

     * Override method to check if token transfer is allowed:

     * - Contract has to be finalized.

     * - Sender has to be KYC verified.

     * - Enough tokens have to be unlocked.

     */

    function transfer(address _to, uint256 _value)

        public

        isFinalized // Only allow token transfer after the fundraising has ended

        isKycVerified(msg.sender)

        hasEnoughUnlockedTokens(msg.sender, _value)

        returns (bool success)

    {

        bool result = super.transfer(_to, _value);

        if (result) {

            trackHolder(_to); // track the owner for later payouts

        }



        // Check if a fund is returning locked tokens and if we have to lock them again

        if (result && block.timestamp < lockedReleaseTime && isRiseFund[msg.sender]) {

            // Check if the recipient has ever transfered some locked tokens to that fund.

            uint256 lockedTokensInFund = lockedTokensInFunds[msg.sender][_to];

            if (lockedTokensInFund > 0) {

                // Calculate how many tokens in this transaction are locked tokens

                uint256 locked = SafeMath.min(lockedTokensInFund, _value);



                // Move locked tokens from fund back to account

                lockedTokens[_to] = SafeMath.add(lockedTokens[_to], locked);

                lockedTokensInFunds[msg.sender][_to] = SafeMath.sub(lockedTokensInFunds[msg.sender][_to], locked);

            }

        }

        return result;

    }



    /**

     * Override method to check if token transfer is allowed:

     * - Contract has to be finalized.

     * - Sender has to be KYC verified.

     * - Enough tokens have to be unlocked.

     */

    function transferFrom(address _from, address _to, uint256 _value)

        public

        isFinalized // Only allow token transfer after the fundraising has ended

        isKycVerified(_from)

        hasEnoughUnlockedTokens(_from, _value)

        returns (bool success)

    {

        bool result = super.transferFrom(_from, _to, _value);

        if (result) {

            trackHolder(_to); // track the owner for later payouts

        }

        return result;

    }



    /**

     * Deliver tokens that have been bought offline.

     *

     * Discount multipliers are applied off-contract in this case

     *

     * @param _to Recipient of the tokens.

     * @param _cents Tokens in Cents, e.g. 1 Token == 1$, passed as 100 cents.

     * @param _purchaseId A unique ID of the purchase from payment provider.

     * @param _unlocked Boolean to determine if the delivered tokens need to be locked (not the case for BTC buyers, their payment is final)

     */

    function deliverTokens(address _to, uint256 _cents, bytes16 _purchaseId, bool _unlocked)

        external

        isFundraising

        tokensDeliverable

        onlyVendor

    {

        require(block.timestamp >= fundingStartTime);

        require(_to != 0x0);

        require(_cents > 0);

        require(_purchaseId.length > 0);



        // Prevent from adding a delivery multiple times

        require(purchaseIdTaken[_purchaseId] == false);

        purchaseIdTaken[_purchaseId] = true;



        // Calculate the total amount of tokens and cut out the extra two decimal units,

        // because tokens was in cents.

        uint256 tokens = SafeMath.mul(_cents, (10**(decimals) / 10**2));



        // Check that the new total token amount would not exceed the token cap

        uint256 checkedSupply = SafeMath.add(totalSupply, tokens);

        require(checkedSupply <= TOKEN_CREATION_CAP);



        // Proceed only when all the checks above have passed



        // Update total token amount and token balance

        totalSupply = checkedSupply;

        balances[_to] = SafeMath.add(balances[_to], tokens);



        // If tokens were not paid with BTC (but credit card), they need to be locked up

        if (_unlocked == false) {

            lockedTokens[_to] = SafeMath.add(lockedTokens[_to], tokens);

        }



        // To force the check for KYC Status upon the user when he tries

        // transferring tokens and exclude every later token owner

        isIcoBuyer[_to] = true;



        // Log the creation of these tokens

        emit LogDeliverRSE(_to, _purchaseId, tokens);

        emit Transfer(address(0x0), _to, tokens);

        trackHolder(_to);

    }



    /**

     * Deliver tokens in batch.

     *

     * Same logic as deliverTokens.

     *

     * @param _to Recipient of the tokens.

     * @param _cents Tokens in Cents, e.g. 1 Token == 1$, passed as 100 cents.

     * @param _purchaseId A unique ID of the purchase from payment provider.

     * @param _unlocked Boolean to determine if the delivered tokens need to be locked (not the case for BTC buyers, their payment is final)

     */

    function deliverTokensBatch(address[] _to, uint256[] _cents, bytes16[] _purchaseId, bool[] _unlocked )

        external

        isFundraising

        tokensDeliverable

        onlyVendor

    {

        require(_to.length == _cents.length);

        require(_to.length == _purchaseId.length);

        require(_to.length == _unlocked.length);



        require(block.timestamp >= fundingStartTime);



        uint256 tokens;

        uint256 checkedSupply;



        for (uint8 i = 0 ; i < _to.length; i++) {

            require(_to[i] != 0x0);

            require(_cents[i] > 0);

            require(_purchaseId[i].length > 0);



            // Prevent from adding a delivery multiple times

            require(purchaseIdTaken[_purchaseId[i]] == false);

            purchaseIdTaken[_purchaseId[i]] = true;



            // Calculate the total amount of tokens and cut out the extra two decimal units,

            // because _tokens was in cents.

            tokens = SafeMath.mul(_cents[i], (10**(decimals) / 10**2));



            // Check that the new total token amount would not exceed the token cap

            checkedSupply = SafeMath.add(totalSupply, tokens);

            require(checkedSupply <= TOKEN_CREATION_CAP);



            // Proceed only when all the checks above have passed



            // Update total token amount and token balance

            totalSupply = checkedSupply;

            balances[_to[i]] = SafeMath.add(balances[_to[i]], tokens);



            // If tokens were not paid with BTC (but credit card), they need to be locked up

            if (_unlocked[i] == false) {

                lockedTokens[_to[i]] = SafeMath.add(lockedTokens[_to[i]], tokens);

            }



            // To force the check for KYC Status upon the user when he tries

            // transferring tokens and exclude every later token owner

            isIcoBuyer[_to[i]] = true;



            // Log the creation of these tokens

            emit LogDeliverRSE(_to[i], _purchaseId[i], tokens);

            emit Transfer(address(0x0), _to[i], tokens);

            trackHolder(_to[i]);

        }

    }



    /**

     * Called in case a buyer cancels his CC payment.

     *

     * Burns the tokens that have been delivered in deliverTokens/deliverTokensBatch.

     *

     * @param _purchaseId A unique ID of the purchase from payment provider.

     * @param _buyer Buyer of the tokens.

     * @param _cents Tokens in Cents, e.g. 1 Token == 1$, passed as 100 cents.

     */

    function cancelDelivery(bytes16 _purchaseId, uint _cents, address _buyer)

        external

        onlyKycTeam

    {

        // CC payments are only cancelable until lockedReleaseTime

        require (block.timestamp < lockedReleaseTime);



        // check if the purchase ID really exists to prove to auditors only actually canceled payments were made undone.

        require (purchaseIdTaken[_purchaseId] == true);

        purchaseIdTaken[_purchaseId] = false;



        // now withdraw the canceled purchase's token amount from the user's balance

        // calculate the total amount of tokens and cut out the extra two decimal units, because it's cents.

        uint256 tokens = SafeMath.mul(_cents, (10**(decimals) / 10**2));



        // Proceed only when all the checks above have passed



        // Update total token amount and token balance

        totalSupply = SafeMath.sub(totalSupply, tokens);

        balances[_buyer] = SafeMath.sub(balances[_buyer], tokens);



        // and withdraw the canceled purchase's token amount from the lockedUp token balance

        lockedTokens[_buyer] = SafeMath.sub(lockedTokens[_buyer], tokens);



        emit LogCancelDelivery(_buyer, _purchaseId, tokens);

        emit Transfer(_buyer, address(0x0), tokens);



        //@CC Binod at al.: This is not proof of god. It was neccessary to remove costly program logic. In case of a dispute,

        // people could refer to the purchaseID. Without a valid one there is no cancelation possible.

    }



    /**

     * Token buying via ETH (disabled by default).

     *

     * Make tokens buyable through fallback function.

     */

    function ()

        public

        payable

    {

        createTokens();

    }



    /**

     * Token buying via ETH (disabled by default).

     */

    function createTokens()

        payable

        public

        isFundraising

    {

        require(ETH_USD_EXCHANGE_RATE_IN_CENTS > 0);

        require(saleThroughContractEnabled == true);

        require(block.timestamp >= fundingStartTime);

        require(block.timestamp <= fundingEndTime);

        require(msg.value > 0);



        // Calculate the token amount:

        // - Divide by 100 to turn ETH_USD_EXCHANGE_RATE_IN_CENTS into full USD

        // - Apply discount multiplier

        uint256 tokens = SafeMath.mul(msg.value, ETH_USD_EXCHANGE_RATE_IN_CENTS);

        tokens = tokens / 100;

        tokens = SafeMath.mulPercentage(tokens, getCurrentDiscountRate());



        // Check that at least one token is created

        require(tokens >= TOKEN_MIN);



        // Check that the new total token amount would not exceed the token cap

        uint256 checkedSupply = SafeMath.add(totalSupply, tokens);

        require(checkedSupply <= TOKEN_CREATION_CAP);



        // Proceed only when all the checks above have passed



        // Update total token amount and token balance

        totalSupply = checkedSupply;

        balances[msg.sender] += tokens;  // safeAdd not needed; bad semantics to use here

        ethTokens[msg.sender] += tokens; // safeAdd not needed; bad semantics to use here



        // Update total eth amount and eth balance

        allReceivedEth = SafeMath.add(allReceivedEth, msg.value);

        ethBalances[msg.sender] = SafeMath.add(ethBalances[msg.sender], msg.value);



        // To force the check for KYC Status upon the user when he tries

        // transferring tokens and exclude every later token owner

        isIcoBuyer[msg.sender] = true;



        // Log the creation of these tokens

        emit LogCreateRSE(msg.sender, tokens);

        emit Transfer(address(0x0), msg.sender, tokens);

        trackHolder(msg.sender);

    }



    /**

     * Refuse KYC of a user that contributed in ETH.

     *

     * Burns the tokens that have been created via createTokens.

     */

    function refuseKyc(address _user)

        external

        onlyKycTeam

        payable

    {

        // Refusing KYC of a user, who only contributed in ETH.

        // We must pay close attention here for the case that a user contributes in ETH AND(!) CC !

        // in this case, he must only kill the tokens he received through ETH, the ones bought in fiat will be

        // killed by canceling his payments and subsequently calling cancelDelivery() with the according payment id.



        // Once a user is verified, you can't kick him out.

        require (kycVerified[_user] == false);



        // Imediately stop, if a user has none or only CC contributions.

        // we're managing kyc refusing of CC contributors off-chain

        require(ethBalances[_user] > 0);

        require(msg.value == ethBalances[_user]);



        // Ensure that token balance is not zero

        uint256 tokenBalance = balances[_user];

        require(tokenBalance > 0);



        // Proceed only when all the checks above have passed



        // Update total token amount and token balance

        uint256 tokens = ethTokens[_user];

        totalSupply = SafeMath.sub(totalSupply, tokens); // Extra safe

        balances[_user] = SafeMath.sub(balances[_user], tokens);

        ethTokens[_user] = 0;



        // Update total eth amount and eth balance

        allReceivedEth = SafeMath.sub(allReceivedEth, msg.value);

        ethBalances[_user] = 0;



        // Log this refund

        emit LogKycRefused(_user, msg.value);

        emit Transfer(_user, address(0x0), tokens);



        // Send the contributions only after we have updated all the balances

        // If you're using a contract, make sure it works with .transfer() gas limits

        _user.transfer(msg.value);

    }



    /**

     * Returns the current token price.

     */

    function getCurrentDiscountRate()

        private

        constant

        returns (uint256 currentDiscountRate)

    {

        // determine which discount to apply

        if (block.timestamp < roundTwoTime) {

            // first round

            return TOKEN_FIRST_DISCOUNT_MULTIPLIER;

        } else if (block.timestamp < roundThreeTime){

            // second round

            return TOKEN_SECOND_DISCOUNT_MULTIPLIER;

        } else if (block.timestamp < roundFourTime) {

            // third round

            return TOKEN_THIRD_DISCOUNT_MULTIPLIER;

        } else {

            // fourth round, no discount

            return 100000;

        }

    }



    /**

     * Approve KYC status of a user.

     *

     * Called by KYC team.

     */

    function unlockKyc(address _owner)

        external

        onlyKycTeam

    {

        require(kycVerified[_owner] == false);



        // Unlock the owner to allow transfer of tokens

        kycVerified[_owner] = true;



        // we leave the lockedTokens[_owner] as is, because also KYCed users could cancel their CC payments

    }



    /**

     * Revoke KYC status of a user.

     *

     * Called by KYC team.

     */

    function revokeKyc(address _owner)

        external

        onlyKycTeam

        isFundraisingIgnorePaused

    {

        require(kycVerified[_owner] == true);



        //revoke the KYC

        kycVerified[_owner] = false;



        // we leave the lockedTokens[_owner] as is, because also KYCed users could cancel their CC payments

    }



    /**

     * Allows admin to transfer ether from the contract.

     */

    function retrieveEth(address _recipient, uint256 _value)

        external

        onlyOwner

        isNoContract(_recipient)

    {

        // Make sure a recipient was defined !

        require(_recipient != 0x0);

        require(_value <= address(this).balance, "Withdraw amount exceeds contract balance");



        // Send the eth to where admins agree upon

        _recipient.transfer(_value);

    }



    /**

     * Ends the fundraising period once and for all.

     *

     * Afterwards token transfers via transfer/transferFrom are enabled.

     */

    function finalize()

        external

        isFundraising

        onlyOwner  // Only the admins calling this method exactly the same way can finalize the sale.

    {

        // Only allow to finalize the contract before the ending time if we already reached the cap

        require(block.timestamp > fundingEndTime || totalSupply >= TOKEN_CREATION_CAP);



        // Move the contract to Finalized state

        finalizeFundraising();

    }



    /**

     * Allow admins to add fonds

     */

    function addFond(address _fund)

        external

        onlyOwner

    {

        riseFunds.push(_fund);

        isRiseFund[_fund] = true;

    }



    /**

     * Allow token holder to move tokens into fund.

     */

    function moveTokensToFund(address _fund, uint256 _tokens)

        external

    {

        // make sure target is added as fund already

        require(isRiseFund[_fund] == true);



        // Define target contract

        RiseFund newFund = RiseFund(_fund);



        // perform the following only if CC lock up time is not passed

        // and the user has locked up tokens

        if (block.timestamp < lockedReleaseTime && lockedTokens[msg.sender] > 0) {

            // Calculate how many tokens in this transaction are locked tokens

            uint256 locked = SafeMath.min(lockedTokens[msg.sender], _tokens);



            // Move locked tokens from account to fund (will later be moved back in transfer() from fund to account)

            lockedTokens[msg.sender] = SafeMath.sub(lockedTokens[msg.sender], locked);

            lockedTokensInFunds[_fund][msg.sender] = SafeMath.add(lockedTokensInFunds[_fund][msg.sender], locked);

        }



        // Now that locked token tracking was taken care of, we can perform a

        // transfer to the fund (lockedTokens are already reduced, so transfer will succeed)

        require(transfer(_fund, _tokens));



        // Perform the relocation of balances to new contract

        require(newFund.recieveRelocation(msg.sender, _tokens));

    }

}