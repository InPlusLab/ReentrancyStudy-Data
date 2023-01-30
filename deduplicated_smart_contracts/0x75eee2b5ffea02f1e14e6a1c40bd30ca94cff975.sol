/**

 *Submitted for verification at Etherscan.io on 2019-03-13

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {

    /**

    * @dev Multiplies two numbers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



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



pragma solidity >= 0.4.22 < 0.5;// Incompatible compiler version... please select one stated within pragma solidity or use different oraclizeAPI version



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



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * @notice Renouncing to ownership will leave the contract without an owner.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



pragma solidity ^0.4.24;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



pragma solidity ^0.4.24;



/**

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract ERC20Detailed is IERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string name, string symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns (string) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}



/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }

}



contract BonusToken is ERC20, ERC20Detailed, Ownable {



    address public gameAddress;

    address public investTokenAddress;

    uint public maxLotteryParticipants;



    mapping (address => uint256) public ethLotteryBalances;

    address[] public ethLotteryParticipants;

    uint256 public ethLotteryBank;

    bool public isEthLottery;



    mapping (address => uint256) public tokensLotteryBalances;

    address[] public tokensLotteryParticipants;

    uint256 public tokensLotteryBank;

    bool public isTokensLottery;



    modifier onlyGame() {

        require(msg.sender == gameAddress);

        _;

    }



    modifier tokenIsAvailable {

        require(investTokenAddress != address(0));

        _;

    }



    constructor (address startGameAddress) public ERC20Detailed("Bet Token", "BET", 18) {

        setGameAddress(startGameAddress);

    }



    function setGameAddress(address newGameAddress) public onlyOwner {

        require(newGameAddress != address(0));

        gameAddress = newGameAddress;

    }



    function buyTokens(address buyer, uint256 tokensAmount) public onlyGame {

        _mint(buyer, tokensAmount * 10**18);

    }



    function startEthLottery() public onlyGame {

        isEthLottery = true;

    }



    function startTokensLottery() public onlyGame tokenIsAvailable {

        isTokensLottery = true;

    }



    function restartEthLottery() public onlyGame {

        for (uint i = 0; i < ethLotteryParticipants.length; i++) {

            ethLotteryBalances[ethLotteryParticipants[i]] = 0;

        }

        ethLotteryParticipants = new address[](0);

        ethLotteryBank = 0;

        isEthLottery = false;

    }



    function restartTokensLottery() public onlyGame tokenIsAvailable {

        for (uint i = 0; i < tokensLotteryParticipants.length; i++) {

            tokensLotteryBalances[tokensLotteryParticipants[i]] = 0;

        }

        tokensLotteryParticipants = new address[](0);

        tokensLotteryBank = 0;

        isTokensLottery = false;

    }



    function updateEthLotteryBank(uint256 value) public onlyGame {

        ethLotteryBank = ethLotteryBank.sub(value);

    }



    function updateTokensLotteryBank(uint256 value) public onlyGame {

        tokensLotteryBank = tokensLotteryBank.sub(value);

    }



    function swapTokens(address account, uint256 tokensToBurnAmount) public {

        require(msg.sender == investTokenAddress);

        _burn(account, tokensToBurnAmount);

    }



    function sendToEthLottery(uint256 value) public {

        require(!isEthLottery);

        require(ethLotteryParticipants.length < maxLotteryParticipants);

        address account = msg.sender;

        _burn(account, value);

        if (ethLotteryBalances[account] == 0) {

            ethLotteryParticipants.push(account);

        }

        ethLotteryBalances[account] = ethLotteryBalances[account].add(value);

        ethLotteryBank = ethLotteryBank.add(value);

    }



    function sendToTokensLottery(uint256 value) public tokenIsAvailable {

        require(!isTokensLottery);

        require(tokensLotteryParticipants.length < maxLotteryParticipants);

        address account = msg.sender;

        _burn(account, value);

        if (tokensLotteryBalances[account] == 0) {

            tokensLotteryParticipants.push(account);

        }

        tokensLotteryBalances[account] = tokensLotteryBalances[account].add(value);

        tokensLotteryBank = tokensLotteryBank.add(value);

    }



    function ethLotteryParticipants() public view returns(address[]) {

        return ethLotteryParticipants;

    }



    function tokensLotteryParticipants() public view returns(address[]) {

        return tokensLotteryParticipants;

    }



    function setInvestTokenAddress(address newInvestTokenAddress) external onlyOwner {

        require(newInvestTokenAddress != address(0));

        investTokenAddress = newInvestTokenAddress;

    }



    function setMaxLotteryParticipants(uint256 participants) external onlyOwner {

        maxLotteryParticipants = participants;

    }

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface modIERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function transfer(address to, uint256 value, uint256 index) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20Detailed token

 * @dev The decimals are only for visualization purposes.

 * All the operations are done using the smallest and indivisible token unit,

 * just as on Ethereum all the operations are done in wei.

 */

contract modERC20Detailed is modIERC20 {

    string private _name;

    string private _symbol;

    uint8 private _decimals;



    constructor (string name, string symbol, uint8 decimals) public {

        _name = name;

        _symbol = symbol;

        _decimals = decimals;

    }



    /**

     * @return the name of the token.

     */

    function name() public view returns (string) {

        return _name;

    }



    /**

     * @return the symbol of the token.

     */

    function symbol() public view returns (string) {

        return _symbol;

    }



    /**

     * @return the number of decimals of the token.

     */

    function decimals() public view returns (uint8) {

        return _decimals;

    }

}



contract modERC20 is modIERC20 {

    using SafeMath for uint256;



    uint256 constant public MIN_HOLDERS_BALANCE = 20 ether;



    address public gameAddress;



    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;



    address[] internal holders;

    mapping(address => bool) internal isUser;



    function getHolders() public view returns (address[]) {

        return holders;

    }



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        if (to != gameAddress && from != gameAddress) {

            uint256 transferFee = value.div(100);

            _burn(from, transferFee);

            value = value.sub(transferFee);

        }

        _balances[from] = _balances[from].sub(value);

        if (to != gameAddress && _balances[to] < MIN_HOLDERS_BALANCE && _balances[to].add(value) >= MIN_HOLDERS_BALANCE) {

            holders.push(to);

        }

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }

}



contract InvestToken is modERC20, modERC20Detailed, Ownable {



    uint8 constant public REFERRER_PERCENT = 3;

    uint8 constant public CASHBACK_PERCENT = 2;

    uint8 constant public HOLDERS_BUY_PERCENT_WITH_REFERRER = 7;

    uint8 constant public HOLDERS_BUY_PERCENT_WITH_REFERRER_AND_CASHBACK = 5;

    uint8 constant public HOLDERS_BUY_PERCENT = 10;

    uint8 constant public HOLDERS_SELL_PERCENT = 5;

    uint8 constant public TOKENS_DIVIDER = 10;

    uint256 constant public PRICE_INTERVAL = 10000000000;



    uint256 public swapTokensLimit;

    uint256 public investDividends;

    uint256 public casinoDividends;

    mapping(address => uint256) public ethStorage;

    mapping(address => address) public referrers;

    mapping(address => uint256) public investSize24h;

    mapping(address => uint256) public lastInvestTime;

    BonusToken public bonusToken;



    uint256 private holdersIndex;

    uint256 private totalInvestDividends;

    uint256 private totalCasinoDividends;

    uint256 private priceCoeff = 105e9;

    uint256 private constant a = 5e9;



    event Buy(address indexed buyer, uint256 weiAmount, uint256 tokensAmount, uint256 timestamp);

    event Sell(address indexed seller, uint256 weiAmount, uint256 tokensAmount, uint256 timestamp);

    event Reinvest(address indexed investor, uint256 weiAmount, uint256 tokensAmount, uint256 timestamp);

    event Withdraw(address indexed investor, uint256 weiAmount, uint256 timestamp);

    event ReferalsIncome(address indexed recipient, uint256 amount, uint256 timestamp);

    event InvestIncome(address indexed recipient, uint256 amount, uint256 timestamp);

    event CasinoIncome(address indexed recipient, uint256 amount, uint256 timestamp);



    constructor (address _bonusToken) public modERC20Detailed("Get Token", "GET", 18) {

        require(_bonusToken != address (0));

        bonusToken = BonusToken(_bonusToken);

        swapTokensLimit = 10000;

        swapTokensLimit = swapTokensLimit.mul(10 ** uint256(decimals()));

    }



    modifier onlyGame() {

        require(msg.sender == gameAddress, 'The sender must be a game contract.');

        _;

    }



    function () public payable {

        if (msg.sender != gameAddress) {

            address referrer;

            if (msg.data.length == 20) {

                referrer = bytesToAddress(bytes(msg.data));

            }

            buyTokens(referrer);

        }

    }



    function buyTokens(address referrer) public payable {

        uint256 weiAmount = msg.value;

        address buyer = msg.sender;

        uint256 tokensAmount;

        (weiAmount, tokensAmount) = mint(buyer, weiAmount);

        uint256 correctWeiAmount = msg.value.sub(weiAmount);

        checkInvestTimeAndSize(buyer, correctWeiAmount);

        if (!isUser[buyer]) {

            if (referrer != address(0) && referrer != buyer) {

                referrers[buyer] = referrer;

            }

            buyFee(buyer, correctWeiAmount, true);

            isUser[buyer] = true;

        } else {

            buyFee(buyer, correctWeiAmount, false);

        }

        if (weiAmount > 0) {

            buyer.transfer(weiAmount);

        }

        emit Buy(buyer, correctWeiAmount, tokensAmount, now);

    }



    function sellTokens(uint256 tokensAmount, uint index) public {

        address seller = msg.sender;

        tokensAmount = tokensAmount.div(decimals()).mul(decimals());

        burn(seller, tokensAmount, index);

        uint256 weiAmount = tokensToEthereum(tokensAmount.div(uint256(10) ** decimals()));

        weiAmount = sellFee(weiAmount);

        seller.transfer(weiAmount);

        emit Sell(seller, weiAmount, tokensAmount, now);

    }



    function swapTokens(uint256 tokensAmountToBurn) public {

        uint256 tokensAmountToMint = tokensAmountToBurn.div(TOKENS_DIVIDER);

        require(tokensAmountToMint <= swapTokensLimit.sub(tokensAmountToMint));

        require(bonusToken.balanceOf(msg.sender) >= tokensAmountToBurn, 'Not enough bonus tokens.');

        bonusToken.swapTokens(msg.sender, tokensAmountToBurn);

        swapTokensLimit = swapTokensLimit.sub(tokensAmountToMint);

        priceCoeff = priceCoeff.add(tokensAmountToMint.mul(1e10));

        correctBalanceByMint(msg.sender, tokensAmountToMint);

        _mint(msg.sender, tokensAmountToMint);

    }



    function reinvest(uint256 weiAmount) public {

        ethStorage[msg.sender] = ethStorage[msg.sender].sub(weiAmount);

        uint256 tokensAmount;

        (weiAmount, tokensAmount) = mint(msg.sender, weiAmount);

        if (weiAmount > 0) {

            ethStorage[msg.sender] = ethStorage[msg.sender].add(weiAmount);

        }

        emit Reinvest(msg.sender, weiAmount, tokensAmount, now);

    }



    function withdraw(uint256 weiAmount) public {

        require(weiAmount > 0);

        ethStorage[msg.sender] = ethStorage[msg.sender].sub(weiAmount);

        msg.sender.transfer(weiAmount);

        emit Withdraw(msg.sender, weiAmount, now);

    }



    function transfer(address to, uint256 value, uint256 index) public returns (bool) {

        if (msg.sender != gameAddress) {

            correctBalanceByBurn(msg.sender, value, index);

        }

        _transfer(msg.sender, to, value);

        return true;

    }



    function sendDividendsToHolders(uint holdersIterations) public onlyOwner {

        if (holdersIndex == 0) {

            totalInvestDividends = investDividends;

            totalCasinoDividends = casinoDividends;

        }

        uint holdersIterationsNumber;

        if (holders.length.sub(holdersIndex) < holdersIterations) {

            holdersIterationsNumber = holders.length.sub(holdersIndex);

        } else {

            holdersIterationsNumber = holdersIterations;

        }

        uint256 holdersBalance = 0;

        uint256 weiAmount = 0;

        for (uint256 i = 0; i < holdersIterationsNumber; i++) {

            holdersBalance = balanceOf(holders[holdersIndex]);

            if (holdersBalance >= MIN_HOLDERS_BALANCE) {

                if (totalInvestDividends > 0) {

                    weiAmount = holdersBalance.mul(totalInvestDividends).div(totalSupply());

                    investDividends = investDividends.sub(weiAmount);

                    emit InvestIncome(holders[holdersIndex], weiAmount, now);

                    ethStorage[holders[holdersIndex]] = ethStorage[holders[holdersIndex]].add(weiAmount);

                }

                if (totalCasinoDividends > 0) {

                    weiAmount = holdersBalance.mul(totalCasinoDividends).div(totalSupply());

                    casinoDividends = casinoDividends.sub(weiAmount);

                    emit CasinoIncome(holders[holdersIndex], weiAmount, now);

                    ethStorage[holders[holdersIndex]] = ethStorage[holders[holdersIndex]].add(weiAmount);

                }

            }

            holdersIndex++;

        }

        if (holdersIndex == holders.length) {

            holdersIndex = 0;

        }

    }



    function setGameAddress(address newGameAddress) public onlyOwner {

        gameAddress = newGameAddress;

    }



    function sendToGame(address player, uint256 tokensAmount, uint256 index) public onlyGame returns(bool) {

        correctBalanceByBurn(player, tokensAmount, index);

        _transfer(player, gameAddress, tokensAmount);

        return true;

    }



    function gameDividends(uint256 weiAmount) public onlyGame {

        casinoDividends = casinoDividends.add(weiAmount);

    }



    function price() public view returns(uint256) {

        return priceCoeff.add(a);

    }



    function mint(address account, uint256 weiAmount) private returns(uint256, uint256) {

        (uint256 tokensToMint, uint256 backPayWeiAmount) = ethereumToTokens(weiAmount);

        correctBalanceByMint(account, tokensToMint);

        _mint(account, tokensToMint);

        return (backPayWeiAmount, tokensToMint);

    }



    function burn(address account, uint256 tokensAmount, uint256 index) private returns(uint256, uint256) {

        correctBalanceByBurn(account, tokensAmount, index);

        _burn(account, tokensAmount);

    }



    function checkInvestTimeAndSize(address account, uint256 weiAmount) private {

        if (now - lastInvestTime[account] > 24 hours) {

            investSize24h[account] = 0;

        }

        require(investSize24h[account].add(weiAmount) <= 5 ether, 'Investment limit exceeded for 24 hours.');

        investSize24h[account] = investSize24h[account].add(weiAmount);

        lastInvestTime[account] = now;

    }



    function buyFee(address sender, uint256 weiAmount, bool isFirstInvest) private {

        address referrer = referrers[sender];

        uint256 holdersWeiAmount;

        if (referrer != address(0)) {

            uint256 referrerWeiAmount = weiAmount.mul(REFERRER_PERCENT).div(100);

            emit ReferalsIncome(referrer, referrerWeiAmount, now);

            ethStorage[referrer] = ethStorage[referrer].add(referrerWeiAmount);

            if (isFirstInvest) {

                uint256 cashbackWeiAmount = weiAmount.mul(CASHBACK_PERCENT).div(100);

                emit ReferalsIncome(sender, cashbackWeiAmount, now);

                ethStorage[sender] = ethStorage[sender].add(cashbackWeiAmount);

                holdersWeiAmount = weiAmount.mul(HOLDERS_BUY_PERCENT_WITH_REFERRER_AND_CASHBACK).div(100);

            } else {

                holdersWeiAmount = weiAmount.mul(HOLDERS_BUY_PERCENT_WITH_REFERRER).div(100);

            }

        } else {

            holdersWeiAmount = weiAmount.mul(HOLDERS_BUY_PERCENT).div(100);

        }

        addDividends(holdersWeiAmount);

    }



    function sellFee(uint256 weiAmount) private returns(uint256) {

        uint256 holdersWeiAmount = weiAmount.mul(HOLDERS_SELL_PERCENT).div(100);

        addDividends(holdersWeiAmount);

        weiAmount = weiAmount.sub(holdersWeiAmount);

        return weiAmount;

    }



    function addDividends(uint256 weiAmount) private {

        investDividends = investDividends.add(weiAmount);

    }



    function correctBalanceByMint(address account, uint256 value) private {

        if (balanceOf(account) < MIN_HOLDERS_BALANCE && balanceOf(account).add(value) >= MIN_HOLDERS_BALANCE) {

            holders.push(msg.sender);

        }

    }



    function correctBalanceByBurn(address account, uint256 value, uint256 index) private {

        if (balanceOf(account) >= MIN_HOLDERS_BALANCE && balanceOf(account).sub(value) < MIN_HOLDERS_BALANCE) {

            require(holders[index] == account);

            deleteTokensHolder(index);

        }

    }



    function ethereumToTokens(uint256 weiAmount) private returns(uint256, uint256) {

        uint256 b = priceCoeff;

        uint256 c = weiAmount;

        uint256 D = (b ** 2).add(a.mul(4).mul(c));

        uint256 tokensAmount = (sqrt(D).sub(b)).div((a).mul(2));

        require(tokensAmount > 0);

        uint256 backPayWeiAmount = weiAmount.sub(a.mul(tokensAmount ** 2).add(priceCoeff.mul(tokensAmount)));

        priceCoeff = priceCoeff.add(tokensAmount.mul(1e10));

        tokensAmount = tokensAmount.mul(10 ** uint256(decimals()));

        return (tokensAmount, backPayWeiAmount);

    }



    function tokensToEthereum(uint256 tokensAmount) private returns(uint256) {

        require(tokensAmount > 0);

        uint256 weiAmount = priceCoeff.mul(tokensAmount).sub((tokensAmount ** 2).mul(5).mul(1e9));

        priceCoeff = priceCoeff.sub(tokensAmount.mul(1e10));

        return weiAmount;

    }



    function bytesToAddress(bytes source) private pure returns(address parsedAddress)

    {

        assembly {

            parsedAddress := mload(add(source,0x14))

        }

        return parsedAddress;

    }



    function sqrt(uint256 x) private pure returns (uint256 y) {

        uint256 z = (x + 1) / 2;

        y = x;

        while (z < y) {

            y = z;

            z = (x / z + z) / 2;

        }

    }



    function deleteTokensHolder(uint index) private {

        holders[index] = holders[holders.length - 1];

        delete holders[holders.length - 1];

        holders.length--;

    }

}





contract Game is usingOraclize, Ownable {

    using SafeMath for uint;



    uint private constant GAME_COIN_FlIP = 0;

    uint private constant GAME_DICE = 1;

    uint private constant GAME_TWO_DICE = 2;

    uint private constant GAME_ETHEROLL = 3;

    uint public constant LOTTERY_FEE = 0.002 ether;

    uint public constant BENEFICIAR_FEE_PERCENT = 5;

    uint public constant TOKEN_HOLDERS_FEE_PERCENT = 45;

    uint public constant MIN_ETH_BET = 0.01 ether;

    uint public constant MIN_TOKENS_BET = 0.05 ether;



    struct Query {

        uint amount;

        address gamer;

        uint[] values;

        uint prize;

        uint range;

        uint game;

        bool tokens;

        uint time;

        bool ended;

    }

    mapping(bytes32 => Query) public queries;

    mapping(address => uint) public waitingEthPrizes;

    mapping(address => uint) public waitingTokensPrizes;

    mapping(address => bool) public isBet;

    mapping(address => uint) public betsBalances;

    mapping(address => uint) private minEthRanges;

    mapping(address => uint) private maxEthRanges;

    mapping(address => uint) private minTokensRanges;

    mapping(address => uint) private maxTokensRanges;

    address[] public holdersInEthLottery;

    address[] public holdersInTokensLottery;

    address[] public players;

    bytes32 public ethLotteryQueryId;

    uint public ethLotterySize;

    uint public ethLotteryStage;

    uint public ethLotteryRound;

    uint public lastEthLotteryTime;

    bytes32 public tokensLotteryQueryId;

    uint public tokensLotterySize;

    uint public tokensLotteryStage;

    uint public tokensLotteryRound;

    uint public lastTokensLotteryTime;

    uint public lastSendBonusTokensTime;

    uint public callbackGas; // Gas for user __callback function by Oraclize

    uint public beneficiarFund;

    address public beneficiar;

    BonusToken public bonusToken;

    InvestToken public investToken;



    uint private playersIndex;



    event PlaceBet(address indexed gamer, bytes32 queryId, bool tokens);

    event Bet(address indexed gamer, uint indexed game, bool tokens, uint amount, uint result, uint[] winResult, uint prize, uint timestamp);

    event WinLottery(address indexed gamer, uint prize, uint ticketsAmount, uint indexed round, bool tokens);



    modifier valideAddress(address addr) {

        require(addr != address(0));

        _;

    }



    constructor(address startBeneficiarAddress) public valideAddress(startBeneficiarAddress) {

        oraclize_setProof(proofType_Ledger);

        oraclize_setCustomGasPrice(5000000000); // 5 gwei

        callbackGas = 300000;

        beneficiar = startBeneficiarAddress;

    }



    /*

    * @param game Game mode (0, 1, 2, 3), watch constants

    * @param values User selected numbers, length = 1 for coin flip game

    * @param referrer Referrer address (default is 0x0)

    *

    * NOTE: ALL USER NUMBERS START WITH 0

    * NOTE: ALL USER NUMBERS MUST GO ASCENDING

    *

    * call this function for place bet to coin flip game with number 0 (eagle)

    * placeBet(0, [0]);

    *

    * call this function for place bet to dice game with numbers 1, 2, 3, 4

    * placeBet(1, [0, 1, 2, 3]);

    *

    * call this function for place bet to two dice game with numbers 2, 3, 4, 7, 8, 11, 12

    * placeBet(2, [0, 1, 2, 5, 6, 9, 10]);

    *

    * call this function for place bet to etheroll game with numbers 1-38

    * placeBet(3, [37]);

    */

    function placeBet(uint game, uint[] values, uint tokensAmount, uint index) payable external {

        uint payAmount;

        if (tokensAmount == 0) {

            require(msg.value >= MIN_ETH_BET);

            payAmount = fee(msg.value, false);

        } else {

            require(tokensAmount >= MIN_TOKENS_BET);

            investToken.sendToGame(msg.sender, tokensAmount, index);

            payAmount = fee(tokensAmount, true);

        }

        require(game == GAME_COIN_FlIP || game == GAME_DICE || game == GAME_TWO_DICE || game == GAME_ETHEROLL);

        require(valideBet(game, values));

        uint range;

        uint winChance;

        if (game == GAME_COIN_FlIP) {

            require(values.length == 1);

            range = 2;

            winChance = 5000;

        } else if (game == GAME_DICE) {

            require(values.length <= 5);

            range = 6;

            winChance = 1667;

            winChance = winChance.mul(values.length);

        } else if (game == GAME_TWO_DICE) {

            require(values.length <= 10);

            range = 11;

            for (uint i = 0; i < values.length; i++) {

                if (values[i] == 0 || values[i] == 10) winChance = winChance.add(278);

                else if (values[i] == 1 || values[i] == 9) winChance = winChance.add(556);

                else if (values[i] == 2 || values[i] == 8) winChance = winChance.add(833);

                else if (values[i] == 3 || values[i] == 7) winChance = winChance.add(1111);

                else if (values[i] == 4 || values[i] == 6) winChance = winChance.add(1389);

                else if (values[i] == 5) winChance = winChance.add(1667);

            }

        } else if (game == GAME_ETHEROLL) {

            require(values.length <= 1);

            range = 100;

            winChance = uint(100).mul(values[0] + 1);

        }

        address sender = msg.sender;

        if (!isBet[sender]) {

            players.push(sender);

            isBet[sender] = true;

        }

        bytes32 queryId = random();

        uint prize = payAmount.mul(10000).div(winChance);

        if (tokensAmount == 0) {

            betsBalances[sender] = betsBalances[sender].add(payAmount);

            newQuery(queryId, msg.value, sender, values, prize, range);

            queries[queryId].tokens = false;

        } else {

            newQuery(queryId, tokensAmount, sender, values, prize, range);

            queries[queryId].tokens = true;

        }

        queries[queryId].game = game; // stack

        emit PlaceBet(sender, queryId, queries[queryId].tokens);

    }



    function ethLottery() external onlyOwner {

        require(now - lastEthLotteryTime >= 1 weeks);

        require(bonusToken.ethLotteryBank() > 0);

        require(ethLotterySize > 0);

        if (!bonusToken.isEthLottery()) {

            address[] memory lotteryParticipants = bonusToken.ethLotteryParticipants();

            for (uint i = 0; i < lotteryParticipants.length; i++) {

                address participant = lotteryParticipants[i];

                uint participantBalance = bonusToken.ethLotteryBalances(participant);

                if (participantBalance > 0) {

                    holdersInEthLottery.push(participant);

                }

            }

            updateEthLotteryRanges();

            ethLotteryRound++;

        }

        bonusToken.startEthLottery();

        ethLotteryQueryId = random();

    }



    function tokensLottery() external onlyOwner {

        require(now - lastTokensLotteryTime >= 1 weeks);

        require(bonusToken.tokensLotteryBank() > 0);

        require(tokensLotterySize > 0);

        if (!bonusToken.isEthLottery()) {

            address[] memory lotteryParticipants = bonusToken.tokensLotteryParticipants();

            for (uint i = 0; i < lotteryParticipants.length; i++) {

                address participant = lotteryParticipants[i];

                uint participantBalance = bonusToken.tokensLotteryBalances(participant);

                if (participantBalance > 0) {

                    holdersInTokensLottery.push(participant);

                }

            }

            updateTokensLotteryRanges();

            tokensLotteryRound++;

        }

        bonusToken.startTokensLottery();

        tokensLotteryQueryId = random();

    }



    function sendBonusTokens(uint playersIterations) external onlyOwner {

        require(now - lastSendBonusTokensTime >= 24 hours);

        uint playersIterationsNumber;

        if (players.length.sub(playersIndex) < playersIterations) {

            playersIterationsNumber = players.length.sub(playersIndex);

        } else {

            playersIterationsNumber = playersIterations;

        }

        uint tokensAmount;

        uint betsBalance;

        for (uint i; i < playersIterationsNumber; i++) {

            address player = players[playersIndex];

            tokensAmount = 0;

            betsBalance = betsBalances[player];

            if (betsBalance >= 1 ether) {

                tokensAmount = betsBalance.div(1 ether).mul(100);

                betsBalance = betsBalance.sub(betsBalance.div(1 ether).mul(1 ether));

                if (tokensAmount > 0) {

                    betsBalances[player] = betsBalance;

                    bonusToken.buyTokens(player, tokensAmount);

                }

            }

            playersIndex++;

        }

        if (playersIndex == players.length) {

            playersIndex = 0;

            lastSendBonusTokensTime = now;

        }

    }



    function refundEthPrize() external {

        require(waitingEthPrizes[msg.sender] > 0);

        require(address(this).balance >= waitingEthPrizes[msg.sender]);

        uint weiAmountToSend = waitingEthPrizes[msg.sender];

        waitingEthPrizes[msg.sender] = 0;

        msg.sender.transfer(weiAmountToSend);

    }



    function refundTokensPrize() external {

        require(waitingTokensPrizes[msg.sender] > 0);

        require(investToken.balanceOf(address(this)) >= waitingTokensPrizes[msg.sender]);

        uint tokensAmountToSend = waitingTokensPrizes[msg.sender];

        waitingTokensPrizes[msg.sender] = 0;

        investToken.transfer(msg.sender, tokensAmountToSend, 0);

    }



    function setOraclizeGasPrice(uint gasPrice) external onlyOwner {

        oraclize_setCustomGasPrice(gasPrice);

    }



    function setOraclizeGasLimit(uint gasLimit) external onlyOwner {

        callbackGas = gasLimit;

    }



    function setBeneficiar(address newBeneficiar) external onlyOwner valideAddress(newBeneficiar) {

        beneficiar = newBeneficiar;

    }



    function setInvestToken(address investTokenAddress) external onlyOwner valideAddress(investTokenAddress) {

        investToken = InvestToken(investTokenAddress);

    }



    function setBonusToken(address bonusTokenAddress) external onlyOwner valideAddress(bonusTokenAddress) {

        bonusToken = BonusToken(bonusTokenAddress);

    }



    function getFund(uint weiAmount) external onlyOwner {

        msg.sender.transfer(weiAmount);

    }



    function getBeneficiarFund() external {

        require(msg.sender == beneficiar);

        uint weiAmountToSend = beneficiarFund;

        beneficiarFund = 0;

        msg.sender.transfer(weiAmountToSend);

    }



    function __callback(bytes32 myId, string result, bytes proof) public {

        require((msg.sender == oraclize_cbAddress()));

        Query storage query = queries[myId];

        require(!query.ended);

        uint randomNumber;

        uint i;

        uint prize;

        address tokensHolder;

        if (query.gamer != address(0)) {

            if (oraclize_randomDS_proofVerify__returnCode(myId, result, proof) != 0) {

                if (!query.tokens) {

                    sendEthWin(query.gamer, query.amount);

                } else {

                    sendTokensWin(query.gamer, query.amount);

                }

            } else {

                randomNumber = uint(keccak256(result)) % query.range;

                bool isWin;

                if (query.game == GAME_ETHEROLL) {

                    if (randomNumber <= query.values[0]) {

                        if (query.tokens) {

                            sendTokensWin(query.gamer, query.prize);

                        } else {

                            sendEthWin(query.gamer, query.prize);

                        }

                        isWin = true;

                    }

                } else {

                    for (i = 0; i < query.values.length; i++) {

                        if (randomNumber == query.values[i]) {

                            if (query.tokens) {

                                sendTokensWin(query.gamer, query.prize);

                            } else {

                                sendEthWin(query.gamer, query.prize);

                            }

                            isWin = true;

                            break;

                        }

                    }

                }

                uint prizeAmount = 0;

                if (isWin) {

                    prizeAmount = query.prize;

                }

                emit Bet(query.gamer, query.game, query.tokens, query.amount, randomNumber, query.values, prizeAmount, now);

            }

            query.ended = true;

        } else if (myId == ethLotteryQueryId) {

            require(oraclize_randomDS_proofVerify__returnCode(myId, result, proof) == 0);

            randomNumber = uint(keccak256(result)) % bonusToken.ethLotteryBank();

            if (ethLotteryStage == 0) {

                prize = ethLotterySize.div(2);

            } else if (ethLotteryStage == 1) {

                prize = ethLotterySize.div(4);

            } else if (ethLotteryStage == 2) {

                prize = ethLotterySize.mul(12).div(100);

            } else if (ethLotteryStage == 3) {

                prize = ethLotterySize.mul(8).div(100);

            } else {

                prize = ethLotterySize.div(20);

            }

            for (i = 0; i < holdersInEthLottery.length; i++) {

                tokensHolder = holdersInEthLottery[i];

                if (randomNumber >= minEthRanges[tokensHolder] && randomNumber < maxEthRanges[tokensHolder]) {

                    deleteEthLotteryParticipant(i);

                    sendEthWin(tokensHolder, prize);

                    emit WinLottery(tokensHolder, prize, bonusToken.ethLotteryBalances(tokensHolder), ethLotteryRound, false);

                    ethLotteryStage++;

                    updateEthLotteryRanges();

                    bonusToken.updateEthLotteryBank(bonusToken.ethLotteryBalances(tokensHolder));

                    break;

                }

            }

            if (ethLotteryStage == 5 || holdersInEthLottery.length == 0) {

                holdersInEthLottery = new address[](0);

                ethLotterySize = 0;

                ethLotteryStage = 0;

                lastEthLotteryTime = now;

                bonusToken.restartEthLottery();

            } else {

                ethLotteryQueryId = random();

            }

        } else if (myId == tokensLotteryQueryId) {

            require(oraclize_randomDS_proofVerify__returnCode(myId, result, proof) == 0);

            randomNumber = uint(keccak256(result)) % bonusToken.tokensLotteryBank();

            if (tokensLotteryStage == 0) {

                prize = tokensLotterySize.div(2);

            } else if (tokensLotteryStage == 1) {

                prize = tokensLotterySize.div(4);

            } else if (tokensLotteryStage == 2) {

                prize = tokensLotterySize.mul(12).div(100);

            } else if (tokensLotteryStage == 3) {

                prize = tokensLotterySize.mul(8).div(100);

            } else {

                prize = tokensLotterySize.div(20);

            }

            for (i = 0; i < holdersInTokensLottery.length; i++) {

                tokensHolder = holdersInTokensLottery[i];

                if (randomNumber >= minTokensRanges[tokensHolder] && randomNumber < maxTokensRanges[tokensHolder]) {

                    deleteTokensLotteryParticipant(i);

                    sendTokensWin(tokensHolder, prize);

                    emit WinLottery(tokensHolder, prize, bonusToken.tokensLotteryBalances(tokensHolder), tokensLotteryRound, true);

                    tokensLotteryStage++;

                    updateTokensLotteryRanges();

                    bonusToken.updateTokensLotteryBank(bonusToken.tokensLotteryBalances(tokensHolder));

                    break;

                }

            }

            if (tokensLotteryStage == 5 || holdersInTokensLottery.length == 0) {

                holdersInTokensLottery = new address[](0);

                tokensLotterySize = 0;

                tokensLotteryStage = 0;

                lastTokensLotteryTime = now;

                bonusToken.restartTokensLottery();

            } else {

                tokensLotteryQueryId = random();

            }

        }

    }



    function updateEthLotteryRanges() private {

        uint range = 0;

        for (uint i = 0; i < holdersInEthLottery.length; i++) {

            address participant = holdersInEthLottery[i];

            uint participantBalance = bonusToken.ethLotteryBalances(participant);

            minEthRanges[participant] = range;

            range = range.add(participantBalance);

            maxEthRanges[participant] = range;

        }

    }



    function updateTokensLotteryRanges() private {

        uint range = 0;

        for (uint i = 0; i < holdersInTokensLottery.length; i++) {

            address participant = holdersInTokensLottery[i];

            uint participantBalance = bonusToken.tokensLotteryBalances(participant);

            minTokensRanges[participant] = range;

            range = range.add(participantBalance);

            maxTokensRanges[participant] = range;

        }

    }



    function valideBet(uint game, uint[] values) private pure returns(bool) {

        require(values.length > 0);

        for (uint i = 0; i < values.length; i++) {

            if (i == 0) {

                if (game == GAME_ETHEROLL && values[i] > 96) {

                    return false;

                }

            }

            if (i != values.length - 1) {

                if (values[i + 1] <= values[i]) {

                    return false;

                }

            }

        }

        return true;

    }



    function fee(uint amount, bool tokens) private returns(uint) {

        uint beneficiarFee = amount.mul(BENEFICIAR_FEE_PERCENT).div(1000);

        uint tokenHoldersFee = amount.mul(TOKEN_HOLDERS_FEE_PERCENT).div(1000);

        if (tokens) {

            tokensLotterySize = tokensLotterySize.add(LOTTERY_FEE);

            investToken.transfer(beneficiar, beneficiarFee, 0);

        } else {

            ethLotterySize = ethLotterySize.add(LOTTERY_FEE);

            beneficiarFund = beneficiarFund.add(beneficiarFee);

            address(investToken).transfer(tokenHoldersFee);

            investToken.gameDividends(tokenHoldersFee);

            amount = amount.sub(tokenHoldersFee);

        }

        amount = amount.sub(beneficiarFee).sub(LOTTERY_FEE);

        return amount;

    }



    function newQuery(bytes32 queryId, uint amount, address gamer, uint[] values, uint prize, uint range) private {

        queries[queryId].gamer = gamer;

        queries[queryId].amount = amount;

        queries[queryId].values = values;

        queries[queryId].prize = prize;

        queries[queryId].range = range;

        queries[queryId].time = now;

    }



    function random() private returns(bytes32 queryId) {

        require(address(this).balance >= oraclize_getPrice('random', callbackGas));

        queryId = oraclize_newRandomDSQuery(0, 4, callbackGas);

        require(queryId != 0, 'Oraclize error');

    }



    function sendEthWin(address winner, uint weiAmount) private {

        if (address(this).balance >= weiAmount) {

            winner.transfer(weiAmount);

        } else {

            waitingEthPrizes[winner] = waitingEthPrizes[winner].add(weiAmount);

        }

    }



    function sendTokensWin(address winner, uint tokensAmount) private {

        if (investToken.balanceOf(address(this)) >= tokensAmount) {

            investToken.transfer(winner, tokensAmount, 0);

        } else {

            waitingTokensPrizes[winner] = waitingTokensPrizes[winner].add(tokensAmount);

        }

    }



    function deleteEthLotteryParticipant(uint index) private {

        holdersInEthLottery[index] = holdersInEthLottery[holdersInEthLottery.length - 1];

        delete holdersInEthLottery[holdersInEthLottery.length - 1];

        holdersInEthLottery.length--;

    }



    function deleteTokensLotteryParticipant(uint index) private {

        holdersInTokensLottery[index] = holdersInTokensLottery[holdersInTokensLottery.length - 1];

        delete holdersInTokensLottery[holdersInTokensLottery.length - 1];

        holdersInTokensLottery.length--;

    }

}