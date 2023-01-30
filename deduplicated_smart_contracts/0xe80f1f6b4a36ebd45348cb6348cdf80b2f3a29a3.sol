/**

 *Submitted for verification at Etherscan.io on 2019-05-23

*/



/*



ORACLIZE_API



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

//pragma solidity >= 0.5.0; // Incompatible compiler version - please select a compiler within the stated pragma range, or use a different version of the oraclizeAPI!



// Dummy contract only used to emit to end-user they are using wrong solc

contract solcChecker {

/* INCOMPATIBLE SOLC: import the following instead: "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.sol" */ function f(bytes calldata x) external;

}



contract OraclizeI {



    address public cbAddress;



    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function getPrice(string memory _datasource) public returns (uint _dsprice);

    function randomDS_getSessionPubKeyHash() external view returns (bytes32 _sessionKeyHash);

    function getPrice(string memory _datasource, uint _gasLimit) public returns (uint _dsprice);

    function queryN(uint _timestamp, string memory _datasource, bytes memory _argN) public payable returns (bytes32 _id);

    function query(uint _timestamp, string calldata _datasource, string calldata _arg) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2) public payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string calldata _datasource, string calldata _arg, uint _gasLimit) external payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string calldata _datasource, bytes calldata _argN, uint _gasLimit) external payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string calldata _datasource, string calldata _arg1, string calldata _arg2, uint _gasLimit) external payable returns (bytes32 _id);

}



contract OraclizeAddrResolverI {

    function getAddress() public returns (address _address);

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



    function init(buffer memory _buf, uint _capacity) internal pure {

        uint capacity = _capacity;

        if (capacity % 32 != 0) {

            capacity += 32 - (capacity % 32);

        }

        _buf.capacity = capacity; // Allocate space for the buffer data

        assembly {

            let ptr := mload(0x40)

            mstore(_buf, ptr)

            mstore(ptr, 0)

            mstore(0x40, add(ptr, capacity))

        }

    }



    function resize(buffer memory _buf, uint _capacity) private pure {

        bytes memory oldbuf = _buf.buf;

        init(_buf, _capacity);

        append(_buf, oldbuf);

    }



    function max(uint _a, uint _b) private pure returns (uint _max) {

        if (_a > _b) {

            return _a;

        }

        return _b;

    }

    /**

      * @dev Appends a byte array to the end of the buffer. Resizes if doing so

      *      would exceed the capacity of the buffer.

      * @param _buf The buffer to append to.

      * @param _data The data to append.

      * @return The original buffer.

      *

      */

    function append(buffer memory _buf, bytes memory _data) internal pure returns (buffer memory _buffer) {

        if (_data.length + _buf.buf.length > _buf.capacity) {

            resize(_buf, max(_buf.capacity, _data.length) * 2);

        }

        uint dest;

        uint src;

        uint len = _data.length;

        assembly {

            let bufptr := mload(_buf) // Memory address of the buffer data

            let buflen := mload(bufptr) // Length of existing buffer data

            dest := add(add(bufptr, buflen), 32) // Start address = buffer address + buffer length + sizeof(buffer length)

            mstore(bufptr, add(buflen, mload(_data))) // Update buffer length

            src := add(_data, 32)

        }

        for(; len >= 32; len -= 32) { // Copy word-length chunks while possible

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }

        uint mask = 256 ** (32 - len) - 1; // Copy remaining bytes

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }

        return _buf;

    }

    /**

      *

      * @dev Appends a byte to the end of the buffer. Resizes if doing so would

      * exceed the capacity of the buffer.

      * @param _buf The buffer to append to.

      * @param _data The data to append.

      * @return The original buffer.

      *

      */

    function append(buffer memory _buf, uint8 _data) internal pure {

        if (_buf.buf.length + 1 > _buf.capacity) {

            resize(_buf, _buf.capacity * 2);

        }

        assembly {

            let bufptr := mload(_buf) // Memory address of the buffer data

            let buflen := mload(bufptr) // Length of existing buffer data

            let dest := add(add(bufptr, buflen), 32) // Address = buffer address + buffer length + sizeof(buffer length)

            mstore8(dest, _data)

            mstore(bufptr, add(buflen, 1)) // Update buffer length

        }

    }

    /**

      *

      * @dev Appends a byte to the end of the buffer. Resizes if doing so would

      * exceed the capacity of the buffer.

      * @param _buf The buffer to append to.

      * @param _data The data to append.

      * @return The original buffer.

      *

      */

    function appendInt(buffer memory _buf, uint _data, uint _len) internal pure returns (buffer memory _buffer) {

        if (_len + _buf.buf.length > _buf.capacity) {

            resize(_buf, max(_buf.capacity, _len) * 2);

        }

        uint mask = 256 ** _len - 1;

        assembly {

            let bufptr := mload(_buf) // Memory address of the buffer data

            let buflen := mload(bufptr) // Length of existing buffer data

            let dest := add(add(bufptr, buflen), _len) // Address = buffer address + buffer length + sizeof(buffer length) + len

            mstore(dest, or(and(mload(dest), not(mask)), _data))

            mstore(bufptr, add(buflen, _len)) // Update buffer length

        }

        return _buf;

    }

}



library CBOR {



    using Buffer for Buffer.buffer;



    uint8 private constant MAJOR_TYPE_INT = 0;

    uint8 private constant MAJOR_TYPE_MAP = 5;

    uint8 private constant MAJOR_TYPE_BYTES = 2;

    uint8 private constant MAJOR_TYPE_ARRAY = 4;

    uint8 private constant MAJOR_TYPE_STRING = 3;

    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;

    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;



    function encodeType(Buffer.buffer memory _buf, uint8 _major, uint _value) private pure {

        if (_value <= 23) {

            _buf.append(uint8((_major << 5) | _value));

        } else if (_value <= 0xFF) {

            _buf.append(uint8((_major << 5) | 24));

            _buf.appendInt(_value, 1);

        } else if (_value <= 0xFFFF) {

            _buf.append(uint8((_major << 5) | 25));

            _buf.appendInt(_value, 2);

        } else if (_value <= 0xFFFFFFFF) {

            _buf.append(uint8((_major << 5) | 26));

            _buf.appendInt(_value, 4);

        } else if (_value <= 0xFFFFFFFFFFFFFFFF) {

            _buf.append(uint8((_major << 5) | 27));

            _buf.appendInt(_value, 8);

        }

    }



    function encodeIndefiniteLengthType(Buffer.buffer memory _buf, uint8 _major) private pure {

        _buf.append(uint8((_major << 5) | 31));

    }



    function encodeUInt(Buffer.buffer memory _buf, uint _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_INT, _value);

    }



    function encodeInt(Buffer.buffer memory _buf, int _value) internal pure {

        if (_value >= 0) {

            encodeType(_buf, MAJOR_TYPE_INT, uint(_value));

        } else {

            encodeType(_buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - _value));

        }

    }



    function encodeBytes(Buffer.buffer memory _buf, bytes memory _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_BYTES, _value.length);

        _buf.append(_value);

    }



    function encodeString(Buffer.buffer memory _buf, string memory _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_STRING, bytes(_value).length);

        _buf.append(bytes(_value));

    }



    function startArray(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_ARRAY);

    }



    function startMap(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_MAP);

    }



    function endSequence(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_CONTENT_FREE);

    }

}

/*



End solidity-cborutils



*/

contract usingOraclize {



    using CBOR for Buffer.buffer;



    OraclizeI oraclize;

    OraclizeAddrResolverI OAR;



    uint constant day = 60 * 60 * 24;

    uint constant week = 60 * 60 * 24 * 7;

    uint constant month = 60 * 60 * 24 * 30;



    byte constant proofType_NONE = 0x00;

    byte constant proofType_Ledger = 0x30;

    byte constant proofType_Native = 0xF0;

    byte constant proofStorage_IPFS = 0x01;

    byte constant proofType_Android = 0x40;

    byte constant proofType_TLSNotary = 0x10;



    string oraclize_network_name;

    uint8 constant networkID_auto = 0;

    uint8 constant networkID_morden = 2;

    uint8 constant networkID_mainnet = 1;

    uint8 constant networkID_testnet = 2;

    uint8 constant networkID_consensys = 161;



    mapping(bytes32 => bytes32) oraclize_randomDS_args;

    mapping(bytes32 => bool) oraclize_randomDS_sessionKeysHashVerified;



    modifier oraclizeAPI {

        if ((address(OAR) == address(0)) || (getCodeSize(address(OAR)) == 0)) {

            oraclize_setNetwork(networkID_auto);

        }

        if (address(oraclize) != OAR.getAddress()) {

            oraclize = OraclizeI(OAR.getAddress());

        }

        _;

    }



    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string memory _result, bytes memory _proof) {

        // RandomDS Proof Step 1: The prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (uint8(_proof[2]) == uint8(1)));

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        require(proofVerified);

        _;

    }



    function oraclize_setNetwork(uint8 _networkID) internal returns (bool _networkSet) {

      return oraclize_setNetwork();

      _networkID; // silence the warning and remain backwards compatible

    }



    function oraclize_setNetworkName(string memory _network_name) internal {

        oraclize_network_name = _network_name;

    }



    function oraclize_getNetworkName() internal view returns (string memory _networkName) {

        return oraclize_network_name;

    }



    function oraclize_setNetwork() internal returns (bool _networkSet) {

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed) > 0) { //mainnet

            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);

            oraclize_setNetworkName("eth_mainnet");

            return true;

        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1) > 0) { //ropsten testnet

            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);

            oraclize_setNetworkName("eth_ropsten3");

            return true;

        }

        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e) > 0) { //kovan testnet

            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);

            oraclize_setNetworkName("eth_kovan");

            return true;

        }

        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48) > 0) { //rinkeby testnet

            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);

            oraclize_setNetworkName("eth_rinkeby");

            return true;

        }

        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475) > 0) { //ethereum-bridge

            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

            return true;

        }

        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF) > 0) { //ether.camp ide

            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);

            return true;

        }

        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA) > 0) { //browser-solidity

            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);

            return true;

        }

        return false;

    }



    function __callback(bytes32 _myid, string memory _result) public {

        __callback(_myid, _result, new bytes(0));

    }



    function __callback(bytes32 _myid, string memory _result, bytes memory _proof) public {

      return;

      _myid; _result; _proof; // Silence compiler warnings

    }



    function oraclize_getPrice(string memory _datasource) oraclizeAPI internal returns (uint _queryPrice) {

        return oraclize.getPrice(_datasource);

    }



    function oraclize_getPrice(string memory _datasource, uint _gasLimit) oraclizeAPI internal returns (uint _queryPrice) {

        return oraclize.getPrice(_datasource, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string memory _arg) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query.value(price)(0, _datasource, _arg);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string memory _arg) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query.value(price)(_timestamp, _datasource, _arg);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string memory _arg, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource,_gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query_withGasLimit.value(price)(_timestamp, _datasource, _arg, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string memory _arg, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

           return 0; // Unexpectedly high price

        }

        return oraclize.query_withGasLimit.value(price)(0, _datasource, _arg, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string memory _arg1, string memory _arg2) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query2.value(price)(0, _datasource, _arg1, _arg2);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query2.value(price)(_timestamp, _datasource, _arg1, _arg2);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query2_withGasLimit.value(price)(_timestamp, _datasource, _arg1, _arg2, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string memory _arg1, string memory _arg2, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query2_withGasLimit.value(price)(0, _datasource, _arg1, _arg2, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[] memory _argN) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return oraclize.queryN.value(price)(0, _datasource, args);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[] memory _argN) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return oraclize.queryN.value(price)(_timestamp, _datasource, args);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[] memory _argN, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return oraclize.queryN_withGasLimit.value(price)(_timestamp, _datasource, args, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[] memory _argN, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return oraclize.queryN_withGasLimit.value(price)(0, _datasource, args, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[1] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[1] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[1] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[1] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[2] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[2] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[2] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[2] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[3] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[3] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[3] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[3] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[4] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[4] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[4] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[4] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[5] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[5] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[5] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[5] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[] memory _argN) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return oraclize.queryN.value(price)(0, _datasource, args);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[] memory _argN) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return oraclize.queryN.value(price)(_timestamp, _datasource, args);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[] memory _argN, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return oraclize.queryN_withGasLimit.value(price)(_timestamp, _datasource, args, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[] memory _argN, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return oraclize.queryN_withGasLimit.value(price)(0, _datasource, args, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[1] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[1] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[1] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[1] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[2] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[2] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[2] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[2] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[3] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[3] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[3] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[3] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[4] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[4] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[4] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[4] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[5] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[5] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[5] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[5] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_setProof(byte _proofP) oraclizeAPI internal {

        return oraclize.setProofType(_proofP);

    }





    function oraclize_cbAddress() oraclizeAPI internal returns (address _callbackAddress) {

        return oraclize.cbAddress();

    }



    function getCodeSize(address _addr) view internal returns (uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function oraclize_setCustomGasPrice(uint _gasPrice) oraclizeAPI internal {

        return oraclize.setCustomGasPrice(_gasPrice);

    }



    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32 _sessionKeyHash) {

        return oraclize.randomDS_getSessionPubKeyHash();

    }



    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {

        bytes memory tmp = bytes(_a);

        uint160 iaddr = 0;

        uint160 b1;

        uint160 b2;

        for (uint i = 2; i < 2 + 2 * 20; i += 2) {

            iaddr *= 256;

            b1 = uint160(uint8(tmp[i]));

            b2 = uint160(uint8(tmp[i + 1]));

            if ((b1 >= 97) && (b1 <= 102)) {

                b1 -= 87;

            } else if ((b1 >= 65) && (b1 <= 70)) {

                b1 -= 55;

            } else if ((b1 >= 48) && (b1 <= 57)) {

                b1 -= 48;

            }

            if ((b2 >= 97) && (b2 <= 102)) {

                b2 -= 87;

            } else if ((b2 >= 65) && (b2 <= 70)) {

                b2 -= 55;

            } else if ((b2 >= 48) && (b2 <= 57)) {

                b2 -= 48;

            }

            iaddr += (b1 * 16 + b2);

        }

        return address(iaddr);

    }



    function strCompare(string memory _a, string memory _b) internal pure returns (int _returnCode) {

        bytes memory a = bytes(_a);

        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) {

            minLength = b.length;

        }

        for (uint i = 0; i < minLength; i ++) {

            if (a[i] < b[i]) {

                return -1;

            } else if (a[i] > b[i]) {

                return 1;

            }

        }

        if (a.length < b.length) {

            return -1;

        } else if (a.length > b.length) {

            return 1;

        } else {

            return 0;

        }

    }



    function indexOf(string memory _haystack, string memory _needle) internal pure returns (int _returnCode) {

        bytes memory h = bytes(_haystack);

        bytes memory n = bytes(_needle);

        if (h.length < 1 || n.length < 1 || (n.length > h.length)) {

            return -1;

        } else if (h.length > (2 ** 128 - 1)) {

            return -1;

        } else {

            uint subindex = 0;

            for (uint i = 0; i < h.length; i++) {

                if (h[i] == n[0]) {

                    subindex = 1;

                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) {

                        subindex++;

                    }

                    if (subindex == n.length) {

                        return int(i);

                    }

                }

            }

            return -1;

        }

    }



    function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, "", "", "");

    }



    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory _bc = bytes(_c);

        bytes memory _bd = bytes(_d);

        bytes memory _be = bytes(_e);

        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

        bytes memory babcde = bytes(abcde);

        uint k = 0;

        uint i = 0;

        for (i = 0; i < _ba.length; i++) {

            babcde[k++] = _ba[i];

        }

        for (i = 0; i < _bb.length; i++) {

            babcde[k++] = _bb[i];

        }

        for (i = 0; i < _bc.length; i++) {

            babcde[k++] = _bc[i];

        }

        for (i = 0; i < _bd.length; i++) {

            babcde[k++] = _bd[i];

        }

        for (i = 0; i < _be.length; i++) {

            babcde[k++] = _be[i];

        }

        return string(babcde);

    }



    function safeParseInt(string memory _a) internal pure returns (uint _parsedInt) {

        return safeParseInt(_a, 0);

    }



    function safeParseInt(string memory _a, uint _b) internal pure returns (uint _parsedInt) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i = 0; i < bresult.length; i++) {

            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {

                if (decimals) {

                   if (_b == 0) break;

                    else _b--;

                }

                mint *= 10;

                mint += uint(uint8(bresult[i])) - 48;

            } else if (uint(uint8(bresult[i])) == 46) {

                require(!decimals, 'More than one decimal encountered in string!');

                decimals = true;

            } else {

                revert("Non-numeral character encountered in string!");

            }

        }

        if (_b > 0) {

            mint *= 10 ** _b;

        }

        return mint;

    }



    function parseInt(string memory _a) internal pure returns (uint _parsedInt) {

        return parseInt(_a, 0);

    }



    function parseInt(string memory _a, uint _b) internal pure returns (uint _parsedInt) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i = 0; i < bresult.length; i++) {

            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {

                if (decimals) {

                   if (_b == 0) {

                       break;

                   } else {

                       _b--;

                   }

                }

                mint *= 10;

                mint += uint(uint8(bresult[i])) - 48;

            } else if (uint(uint8(bresult[i])) == 46) {

                decimals = true;

            }

        }

        if (_b > 0) {

            mint *= 10 ** _b;

        }

        return mint;

    }



    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {

            return "0";

        }

        uint j = _i;

        uint len;

        while (j != 0) {

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (_i != 0) {

            bstr[k--] = byte(uint8(48 + _i % 10));

            _i /= 10;

        }

        return string(bstr);

    }



    function stra2cbor(string[] memory _arr) internal pure returns (bytes memory _cborEncoding) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < _arr.length; i++) {

            buf.encodeString(_arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    function ba2cbor(bytes[] memory _arr) internal pure returns (bytes memory _cborEncoding) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < _arr.length; i++) {

            buf.encodeBytes(_arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32 _queryId) {

        require((_nbytes > 0) && (_nbytes <= 32));

        _delay *= 10; // Convert from seconds to ledger timer ticks

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(uint8(_nbytes));

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            /*

             The following variables can be relaxed.

             Check the relaxed random contract at https://github.com/oraclize/ethereum-examples

             for an idea on how to override and replace commit hash variables.

            */

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



    function oraclize_randomDS_setCommitment(bytes32 _queryId, bytes32 _commitment) internal {

        oraclize_randomDS_args[_queryId] = _commitment;

    }



    function verifySig(bytes32 _tosignh, bytes memory _dersig, bytes memory _pubkey) internal returns (bool _sigVerified) {

        bool sigok;

        address signer;

        bytes32 sigr;

        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);

        uint offset = 4 + (uint(uint8(_dersig[3])) - 0x20);

        sigr_ = copyBytes(_dersig, offset, 32, sigr_, 0);

        bytes memory sigs_ = new bytes(32);

        offset += 32 + 2;

        sigs_ = copyBytes(_dersig, offset + (uint(uint8(_dersig[offset - 1])) - 0x20), 32, sigs_, 0);

        assembly {

            sigr := mload(add(sigr_, 32))

            sigs := mload(add(sigs_, 32))

        }

        (sigok, signer) = safer_ecrecover(_tosignh, 27, sigr, sigs);

        if (address(uint160(uint256(keccak256(_pubkey)))) == signer) {

            return true;

        } else {

            (sigok, signer) = safer_ecrecover(_tosignh, 28, sigr, sigs);

            return (address(uint160(uint256(keccak256(_pubkey)))) == signer);

        }

    }



    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes memory _proof, uint _sig2offset) internal returns (bool _proofVerified) {

        bool sigok;

        // Random DS Proof Step 6: Verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)

        bytes memory sig2 = new bytes(uint(uint8(_proof[_sig2offset + 1])) + 2);

        copyBytes(_proof, _sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);

        copyBytes(_proof, 3 + 1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1 + 65 + 32);

        tosign2[0] = byte(uint8(1)); //role

        copyBytes(_proof, _sig2offset - 65, 65, tosign2, 1);

        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";

        copyBytes(CODEHASH, 0, 32, tosign2, 1 + 65);

        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (!sigok) {

            return false;

        }

        // Random DS Proof Step 7: Verify the APPKEY1 provenance (must be signed by Ledger)

        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1 + 65);

        tosign3[0] = 0xFE;

        copyBytes(_proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(uint8(_proof[3 + 65 + 1])) + 2);

        copyBytes(_proof, 3 + 65, sig3.length, sig3, 0);

        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);

        return sigok;

    }



    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string memory _result, bytes memory _proof) internal returns (uint8 _returnCode) {

        // Random DS Proof Step 1: The prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L") || (_proof[1] != "P") || (uint8(_proof[2]) != uint8(1))) {

            return 1;

        }

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (!proofVerified) {

            return 2;

        }

        return 0;

    }



    function matchBytes32Prefix(bytes32 _content, bytes memory _prefix, uint _nRandomBytes) internal pure returns (bool _matchesPrefix) {

        bool match_ = true;

        require(_prefix.length == _nRandomBytes);

        for (uint256 i = 0; i< _nRandomBytes; i++) {

            if (_content[i] != _prefix[i]) {

                match_ = false;

            }

        }

        return match_;

    }



    function oraclize_randomDS_proofVerify__main(bytes memory _proof, bytes32 _queryId, bytes memory _result, string memory _contextName) internal returns (bool _proofVerified) {

        // Random DS Proof Step 2: The unique keyhash has to match with the sha256 of (context name + _queryId)

        uint ledgerProofLength = 3 + 65 + (uint(uint8(_proof[3 + 65 + 1])) + 2) + 32;

        bytes memory keyhash = new bytes(32);

        copyBytes(_proof, ledgerProofLength, 32, keyhash, 0);

        if (!(keccak256(keyhash) == keccak256(abi.encodePacked(sha256(abi.encodePacked(_contextName, _queryId)))))) {

            return false;

        }

        bytes memory sig1 = new bytes(uint(uint8(_proof[ledgerProofLength + (32 + 8 + 1 + 32) + 1])) + 2);

        copyBytes(_proof, ledgerProofLength + (32 + 8 + 1 + 32), sig1.length, sig1, 0);

        // Random DS Proof Step 3: We assume sig1 is valid (it will be verified during step 5) and we verify if '_result' is the _prefix of sha256(sig1)

        if (!matchBytes32Prefix(sha256(sig1), _result, uint(uint8(_proof[ledgerProofLength + 32 + 8])))) {

            return false;

        }

        // Random DS Proof Step 4: Commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8 + 1 + 32);

        copyBytes(_proof, ledgerProofLength + 32, 8 + 1 + 32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength + 32 + (8 + 1 + 32) + sig1.length + 65;

        copyBytes(_proof, sig2offset - 64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (oraclize_randomDS_args[_queryId] == keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))) { //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[_queryId];

        } else return false;

        // Random DS Proof Step 5: Validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32 + 8 + 1 + 32);

        copyBytes(_proof, ledgerProofLength, 32 + 8 + 1 + 32, tosign1, 0);

        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) {

            return false;

        }

        // Verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (!oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash]) {

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(_proof, sig2offset);

        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }

    /*

     The following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    */

    function copyBytes(bytes memory _from, uint _fromOffset, uint _length, bytes memory _to, uint _toOffset) internal pure returns (bytes memory _copiedBytes) {

        uint minLength = _length + _toOffset;

        require(_to.length >= minLength); // Buffer too small. Should be a better way?

        uint i = 32 + _fromOffset; // NOTE: the offset 32 is added to skip the `size` field of both bytes variables

        uint j = 32 + _toOffset;

        while (i < (32 + _fromOffset + _length)) {

            assembly {

                let tmp := mload(add(_from, i))

                mstore(add(_to, j), tmp)

            }

            i += 32;

            j += 32;

        }

        return _to;

    }

    /*

     The following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

     Duplicate Solidity's ecrecover, but catching the CALL return value

    */

    function safer_ecrecover(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) internal returns (bool _success, address _recoveredAddress) {

        /*

         We do our own memory management here. Solidity uses memory offset

         0x40 to store the current end of memory. We write past it (as

         writes are memory extensions), but don't update the offset so

         Solidity will reuse it. The memory used here is only needed for

         this context.

         FIXME: inline assembly can't access return values

        */

        bool ret;

        address addr;

        assembly {

            let size := mload(0x40)

            mstore(size, _hash)

            mstore(add(size, 32), _v)

            mstore(add(size, 64), _r)

            mstore(add(size, 96), _s)

            ret := call(3000, 1, 0, size, 128, size, 32) // NOTE: we can reuse the request memory because we deal with the return code.

            addr := mload(size)

        }

        return (ret, addr);

    }

    /*

     The following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    */

    function ecrecovery(bytes32 _hash, bytes memory _sig) internal returns (bool _success, address _recoveredAddress) {

        bytes32 r;

        bytes32 s;

        uint8 v;

        if (_sig.length != 65) {

            return (false, address(0));

        }

        /*

         The signature format is a compact form of:

           {bytes32 r}{bytes32 s}{uint8 v}

         Compact means, uint8 is not padded to 32 bytes.

        */

        assembly {

            r := mload(add(_sig, 32))

            s := mload(add(_sig, 64))

            /*

             Here we are loading the last 32 bytes. We exploit the fact that

             'mload' will pad with zeroes if we overread.

             There is no 'mload8' to do this, but that would be nicer.

            */

            v := byte(0, mload(add(_sig, 96)))

            /*

              Alternative solution:

              'byte' is not working due to the Solidity parser, so lets

              use the second best option, 'and'

              v := and(mload(add(_sig, 65)), 255)

            */

        }

        /*

         albeit non-transactional signatures are not specified by the YP, one would expect it

         to match the YP range of [27, 28]

         geth uses [0, 1] and some clients have followed. This might change, see:

         https://github.com/ethereum/go-ethereum/issues/2053

        */

        if (v < 27) {

            v += 27;

        }

        if (v != 27 && v != 28) {

            return (false, address(0));

        }

        return safer_ecrecover(_hash, v, r, s);

    }



    function safeMemoryCleaner() internal pure {

        assembly {

            let fmem := mload(0x40)

            codecopy(fmem, codesize, sub(msize, fmem))

        }

    }

}

/*



END ORACLIZE_API



*/



/*

 * Copyright 2019 Authpaper Team

 *

 * Licensed under the Apache License, Version 2.0 (the "License");

 * you may not use this file except in compliance with the License.

 * You may obtain a copy of the License at

 *

 *      http://www.apache.org/licenses/LICENSE-2.0

 *

 * Unless required by applicable law or agreed to in writing, software

 * distributed under the License is distributed on an "AS IS" BASIS,

 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

 * See the License for the specific language governing permissions and

 * limitations under the License.

 */

pragma solidity ^0.5.3;

//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";



contract Adminstrator {

  address public admin;

  address payable public owner;



  modifier onlyAdmin() { 

        require(msg.sender == admin || msg.sender == owner,"Not authorized"); 

        _;

  } 



  constructor() public {

    admin = msg.sender;

	owner = msg.sender;

  }



  function transferAdmin(address newAdmin) public onlyAdmin {

    admin = newAdmin; 

  }

}

contract FiftyContract is Adminstrator,usingOraclize {

    uint public mRate = 200 finney; //membership fee

	uint public membershiptime = 183 * 86400; //183 days, around 0.5 year

	uint public divideRadio = 485; //The divide ratio, each uplevel will get 0.485 by default

	uint public divideRadioBase = 1000;

	mapping (address => uint) public membership;

	mapping(address => mapping(uint => uint)) public memberOrders;

	event membershipExtended(address indexed _self, uint newexpiretime);

	

	string public website="http://portal.globalcfo.org/getOrderVer4.php?eth=";

	string[] public websiteString = ["http://portal.globalcfo.org/getOrderVer4.php?room=1&eth=",

	"http://portal.globalcfo.org/getOrderVer4.php?room=2&eth=",

	"http://portal.globalcfo.org/getOrderVer4.php?room=3&eth=",

	"http://portal.globalcfo.org/getOrderVer4.php?room=5&eth=",

	"http://portal.globalcfo.org/getOrderVer4.php?room=10&eth=",

	"http://portal.globalcfo.org/getOrderVer4.php?room=50&eth="

	];

	mapping (bytes32 => treeNode) public oraclizeCallbacks;

	

	//About the tree

	event completeTree(address indexed _self, uint indexed _nodeID, uint indexed _amount);

	event startTree(address indexed _self, uint indexed _nodeID, uint indexed _amount);	

	mapping (address => mapping (uint => uint)) public nodeIDIndex;	

	mapping (address => mapping (uint => bool)) public isReatingTree;

	mapping (address => mapping (uint => mapping (uint => mapping (uint => treeNode)))) public treeChildren;

	mapping (address => mapping (uint => mapping (uint => treeNode))) public treeParent;

	mapping (address => mapping (uint => mapping (uint => uint))) public treeCompleteTime;

	//Keep the current running nodes given an address

	mapping (address => mapping (uint => bool)) public currentNodes;

	//Temporary direct referral

	mapping (address => mapping (uint => mapping (uint => address))) public tempDirRefer;

	uint public spread=2;

	uint public minimumTreeNodeReferred=2;

	uint[] public possibleNodeType = [1,2,3,5,10,50];

	

	struct treeNode {

		 address payable ethAddress; 

		 uint nodeType; 

		 uint nodeID;

	}

	struct rewardDistribution {

		address payable first;

		address payable second;

	}

	

	//Statistic issue

	uint256 public ethIN=0;

	uint256 public ethOut=0;

	uint256 public receivedAmount=0;

	uint256 public sentAmount=0;

	bool public paused=false;

	mapping (address => uint) public nodeReceivedETH;

	event Paused(address account);

	event Unpaused(address account);

	event makeQuery(address indexed account, string msg);

	event refundEvent(address indexed _self, uint sentETH, uint requireETH, uint shopID, 

	address parent, address grandparent, bool isOpeningExistingRoom);

	

	//Setting the variables

	function setMembershipFee(uint rateFinney, uint memberDays) public onlyAdmin{

		require(rateFinney > 0, "new rate must be positive");

		require(memberDays > 0, "new membership time must be positive");

		mRate = rateFinney * 10 ** uint256(15); //In finney

		membershiptime = memberDays * 86400; //In days

		

	}

	function setTreeSpec(uint newSpread, uint newDivideRate, uint newDivideBase, 

	uint newTreeNodeReferred, uint[] memory newNodeType) public onlyAdmin{

		require(newSpread > 0, "new spread must > 0");

		require(newDivideRate > 0, "new divide level must > 0");

		require(newDivideBase > newDivideRate, "new divide level base must > ratio");

		require(newTreeNodeReferred >= 1, "new min tree nodes referred by root must > 1");

		require(newNodeType.length >= 1, "invalid possible node type");

		spread = newSpread;

		divideRadio = newDivideRate;

		divideRadioBase = newDivideBase;

		minimumTreeNodeReferred = newTreeNodeReferred;

		possibleNodeType=newNodeType;

	}

	function pause(bool isPause) public onlyAdmin{

		paused = isPause;

		if(isPause) emit Paused(msg.sender);

		else emit Unpaused(msg.sender);

	}

	function withdraw(uint amount) public onlyAdmin returns(bool) {

        require(amount < address(this).balance);

        owner.transfer(amount);

        return true;

    }

    function withdrawAll() public onlyAdmin returns(bool) {

        uint balanceOld = address(this).balance;

        owner.transfer(balanceOld);

        return true;

    }

	function _addMember(address _member) internal {

		require(_member != address(0));

		if(membership[_member] <= now) membership[_member] = now;

		membership[_member] += membershiptime;

		emit membershipExtended(_member,membership[_member]);

	}

	function addMember(address member) public onlyAdmin {

		_addMember(member);

	}

	function banMember(address member) public onlyAdmin {

		require(member != address(0));

		membership[member] = 0;

	}

		

	function() external payable { 

		require(!paused,"The contract is paused");

		require(address(this).balance + msg.value > address(this).balance);

		ethIN += msg.value;

		//Make web call to find the shopping order

		//Remember, each query burns 0.01 USD from the contract !!

		string memory queryStr = strConcating(website,addressToString(msg.sender));

		emit makeQuery(msg.sender,"Oraclize query sent");

		bytes32 queryId=oraclize_query("URL", queryStr, 800000);

		//emit makeQuery(msg.sender,queryStr);

		//bytes32 queryId=bytes32("AAA");

        oraclizeCallbacks[queryId] = treeNode(msg.sender,msg.value,0);

	}

		

	function __callback(bytes32 myid, string memory result) public {

        if (msg.sender != oraclize_cbAddress()) revert();

		bytes memory _baseBytes = bytes(result);

		//require(_baseBytes.length == 84 || _baseBytes.length == 105, "The return string is not valid");

		treeNode memory o = oraclizeCallbacks[myid];

		address payable treeRoot = o.ethAddress;

		uint totalETH = o.nodeType;

		require(treeRoot != address(0),"Invalid root address");

		require(totalETH >= 0, "No ETH send in");

		if(_baseBytes.length != 231 && _baseBytes.length != 211){

			//invalid response or opening existing room, refund

			distributeETH(treeRoot,treeRoot,treeRoot,totalETH,true);

			emit refundEvent(treeRoot,totalETH,_baseBytes.length,0,address(0),address(0),false);

			return;

		}

		if(_baseBytes.length == 211){

			uint isReatingRoom = extractUintFromByte(_baseBytes,0,1);

			address payable parentAddress = extractOneAddrFromByte(_baseBytes,1);

			address payable grandAddress = extractOneAddrFromByte(_baseBytes,43);

			address payable grandgrandAddress = extractOneAddrFromByte(_baseBytes,85);

			address payable ghostAddress1 = extractOneAddrFromByte(_baseBytes,127);

			address payable ghostAddress2 = extractOneAddrFromByte(_baseBytes,169);

			

			currentNodes[treeRoot][totalETH] = true;

			uint totalRequireETH = nodeIDIndex[treeRoot][totalETH];

			nodeIDIndex[treeRoot][totalETH] += 1;

			isReatingTree[treeRoot][totalETH] = (isReatingRoom==1)? true:false;

			emit startTree(treeRoot,totalRequireETH,totalETH);

			

			if(parentAddress != address(0))

				tempDirRefer[treeRoot][totalETH][totalRequireETH] = parentAddress;

			rewardDistribution memory rewardResult = 

				_placeChildTree(parentAddress,totalETH,treeRoot,totalRequireETH);

			if(rewardResult.first == address(0) && grandAddress != address(0)){

				//Try grandparent

				rewardResult = _placeChildTree(grandAddress,totalETH,treeRoot,totalRequireETH);

			}

			if(rewardResult.first == address(0) && grandgrandAddress != address(0)){

				//Try grandparent

				rewardResult = _placeChildTree(grandgrandAddress,totalETH,treeRoot,totalRequireETH);

			}

			if(rewardResult.first == address(0)){

				//Try grandparent

				rewardResult = rewardDistribution(ghostAddress1,ghostAddress2);

			}

			//if(rewardResult.first != address(0))

			distributeETH(treeRoot,rewardResult.first,rewardResult.second,totalETH,false);

			//else isOpeningExistingRoom=true;

			return;

		}

		if(_baseBytes.length == 231){

			//Getting the shop order from the website

			//The first 9 bytes return the purchase order, the second 12 bytes returns the order details

			//the following 42 bytes return the parent address, the following 42 bytes return the grandparent address

			uint shopOrderID = extractUintFromByte(_baseBytes,0,9);

			address payable parentAddress = extractOneAddrFromByte(_baseBytes,21);

			address payable grandAddress = extractOneAddrFromByte(_baseBytes,63);

			address payable grandgrandAddress = extractOneAddrFromByte(_baseBytes,105);

			address payable ghostAddress1 = extractOneAddrFromByte(_baseBytes,147);

			address payable ghostAddress2 = extractOneAddrFromByte(_baseBytes,189);

			bool[] memory isStartTreeHere = new bool[](2*possibleNodeType.length);

			bool isOpeningExistingRoom=false;

			uint totalRequireETH = 0;			

			for(uint i=0;i<possibleNodeType.length;i++){

				isStartTreeHere[i]

					= (getOneDigit(_baseBytes,(i+21)-possibleNodeType.length) ==1)? 

					true:false;

				isStartTreeHere[i+possibleNodeType.length]

					= (getOneDigit(_baseBytes,(i+21)-(2*possibleNodeType.length)) ==1)? 

					true:false;

				if(isStartTreeHere[i]){

					totalRequireETH += possibleNodeType[i] * 10 ** uint256(18);

					uint testTreeType = possibleNodeType[i] * 10 ** uint256(18);

					if(currentNodes[treeRoot][testTreeType] 

						|| nodeIDIndex[treeRoot][testTreeType] >= (2 ** 32) -1){

						isOpeningExistingRoom=true;

					}

				}

			}

			if(membership[treeRoot] <= now) totalRequireETH += mRate;

			if(totalRequireETH > totalETH || shopOrderID ==0 || isOpeningExistingRoom){

				//No enough ETH or invalid response or openning existing room, refund

				distributeETH(treeRoot,treeRoot,treeRoot,totalETH,true);

				memberOrders[treeRoot][shopOrderID]=3;//3 means refund

				emit refundEvent(treeRoot,totalETH,totalRequireETH,shopOrderID,

				    parentAddress,grandAddress,isOpeningExistingRoom);

				return;

			}else{

				//Has enough ETH, open the rooms and find a place from parent one by one

				//First, record the receive money and extend the membership

				receivedAmount += totalRequireETH;

				memberOrders[treeRoot][shopOrderID]=1;

				if(membership[treeRoot] <= now) _addMember(treeRoot);

				//First, send out the extra ETH

				totalRequireETH = totalETH - totalRequireETH;

				require(totalRequireETH < address(this).balance, "Too much remainder");

				//The remainder is enough for extend the membership

				if(( membership[treeRoot] <= now + (7*86400) ) && totalRequireETH >= mRate){

					//Auto extend membership

					_addMember(treeRoot);

					totalRequireETH -= mRate;

					receivedAmount += mRate;

				}

				if(totalRequireETH >0){

					totalETH = address(this).balance;

					treeRoot.transfer(totalRequireETH);

					ethOut += totalRequireETH;

					assert(address(this).balance + totalRequireETH >= totalETH);

				}

				for(uint i=0;i<possibleNodeType.length;i++){

					//For each type of tree, start a node and look for parent

					if(!isStartTreeHere[i]) continue;

					totalETH = possibleNodeType[i] * 10 ** uint256(18);

					currentNodes[treeRoot][totalETH] = true;

					totalRequireETH = nodeIDIndex[treeRoot][totalETH];

					nodeIDIndex[treeRoot][totalETH] += 1;

					isReatingTree[treeRoot][totalETH] = isStartTreeHere[i+possibleNodeType.length];

					emit startTree(treeRoot,totalRequireETH,totalETH);

					

					if(parentAddress != address(0))

						tempDirRefer[treeRoot][totalETH][totalRequireETH] = parentAddress;

					rewardDistribution memory rewardResult = 

						_placeChildTree(parentAddress,totalETH,treeRoot,totalRequireETH);

					if(rewardResult.first == address(0) && grandAddress != address(0)){

						//Try grandparent

						rewardResult = _placeChildTree(grandAddress,totalETH,treeRoot,totalRequireETH);

					}

					if(rewardResult.first == address(0) && grandgrandAddress != address(0)){

						//Try grandparent

						rewardResult = _placeChildTree(grandgrandAddress,totalETH,treeRoot,totalRequireETH);

					}

					if(rewardResult.first == address(0)){

						//Try grandparent

						rewardResult = rewardDistribution(ghostAddress1,ghostAddress2);

					}

					//if(rewardResult.first != address(0))

					distributeETH(treeRoot,rewardResult.first,rewardResult.second,totalETH,false);

					//else isOpeningExistingRoom=true;

				}

			}

			return;

		}



    }

	function _placeChildTree(address payable firstUpline, uint treeType, address payable treeRoot, uint treeNodeID) internal returns(rewardDistribution memory) {

		//We do BFS here, so need to search layer by layer

		if(firstUpline == address(0)) return rewardDistribution(address(0),address(0));

		address payable getETHOne = address(0); address payable getETHTwo = address(0);

		uint8 firstLevelSearch=_placeChild(firstUpline,treeType,treeRoot,treeNodeID); 

		if(firstLevelSearch == 1){

			getETHOne=firstUpline;

			uint cNodeID=nodeIDIndex[firstUpline][treeType] - 1;

			//So the firstUpline will get the money, as well as the parent of the firstUpline

			if(treeParent[firstUpline][treeType][cNodeID].nodeType != 0){

				getETHTwo = treeParent[firstUpline][treeType][cNodeID].ethAddress;

			}

		}

		//The same address has been here before

		if(firstLevelSearch == 2) return rewardDistribution(address(0),address(0));

		if(getETHOne == address(0)){

			//Now search the grandchildren of the firstUpline for a place

			if(currentNodes[firstUpline][treeType] && nodeIDIndex[firstUpline][treeType] <(2 ** 32) -1){

				uint cNodeID=nodeIDIndex[firstUpline][treeType] - 1;

				for (uint256 i=0; i < spread; i++) {

					if(treeChildren[firstUpline][treeType][cNodeID][i].nodeType != 0){

						treeNode memory kids = treeChildren[firstUpline][treeType][cNodeID][i];

						if(_placeChild(kids.ethAddress,treeType,treeRoot,treeNodeID) == 1){

							getETHOne=kids.ethAddress;

							//So the child of firstUpline will get the money, as well as the child

							getETHTwo = firstUpline;

							break;

						}

					}

				}

			}

		}

		return rewardDistribution(getETHOne,getETHTwo);

	}

	//Return 0, there is no place for the node, 1, there is a place and placed, 2, duplicate node is found

	function _placeChild(address payable firstUpline, uint treeType, address payable treeRoot, uint treeNodeID) 

		internal returns(uint8) {

		if(currentNodes[firstUpline][treeType] && nodeIDIndex[firstUpline][treeType] <(2 ** 32) -1){

			uint cNodeID=nodeIDIndex[firstUpline][treeType] - 1;

			for (uint256 i=0; i < spread; i++) {

				if(treeChildren[firstUpline][treeType][cNodeID][i].nodeType == 0){

					//firstUpline has a place

					treeChildren[firstUpline][treeType][cNodeID][i]

						= treeNode(treeRoot,treeType,treeNodeID);

					//Set parent

					treeParent[treeRoot][treeType][treeNodeID] 

						= treeNode(firstUpline,treeType,cNodeID);

					return 1;

				}else{

				    treeNode memory kids = treeChildren[firstUpline][treeType][cNodeID][i];

				    //The child has been here in previous project

				    if(kids.ethAddress == treeRoot) return 2;

				}

			}

		}

		return 0;

	}

	function _checkTreeComplete(address payable _root, uint _treeType, uint _nodeID) internal {

		require(_root != address(0), "Tree root to check completness is 0");

		bool _isCompleted = true;

		uint _isDirectRefCount = 0;

		for (uint256 i=0; i < spread; i++) {

			if(treeChildren[_root][_treeType][_nodeID][i].nodeType == 0){

				_isCompleted = false;

				break;

			}else{

				//Search the grandchildren

				treeNode memory _child = treeChildren[_root][_treeType][_nodeID][i];

				address referral = tempDirRefer[_child.ethAddress][_child.nodeType][_child.nodeID];

				if(referral == _root) _isDirectRefCount += 1;

				for (uint256 a=0; a < spread; a++) {

					if(treeChildren[_child.ethAddress][_treeType][_child.nodeID][a].nodeType == 0){

						_isCompleted = false;

						break;

					}else{

						treeNode memory _gChild=treeChildren[_child.ethAddress][_treeType][_child.nodeID][a];

						address referral2 = tempDirRefer[_gChild.ethAddress][_gChild.nodeType][_gChild.nodeID];

						if(referral2 == _root) _isDirectRefCount += 1;

					}

				}

				if(!_isCompleted) break;

			}

		}

		if(!_isCompleted) return;

		//The tree is completed, root can start over again

		currentNodes[_root][_treeType] = false;

		treeCompleteTime[_root][_treeType][nodeIDIndex[_root][_treeType]-1]=now;

		//Ban this user

		if(nodeIDIndex[_root][_treeType] == 1 && _isDirectRefCount < minimumTreeNodeReferred) 

			nodeIDIndex[_root][_treeType] = (2 ** 32) -1;

		emit completeTree(_root, nodeIDIndex[_root][_treeType], _treeType);

		

		if(isReatingTree[_root][_treeType]){

			string memory queryStr = addressToString(_root);

			for(uint i=0;i<possibleNodeType.length;i++){

				if(_treeType == possibleNodeType[i] * 10 ** uint256(18))

					queryStr = strConcating(websiteString[i],queryStr);

			}

			emit makeQuery(msg.sender,"Oraclize query sent");

			bytes32 queryId=oraclize_query("URL", queryStr, 800000);

			oraclizeCallbacks[queryId] = treeNode(_root,_treeType,0);

		}

	}

	function findChildFromTop(address searchTarget, address _root, uint _treeType, uint _nodeID) internal returns(uint8){

		require(_root != address(0), "Tree root to check completness is 0");

		for (uint8 i=0; i < spread; i++) {

			if(treeChildren[_root][_treeType][_nodeID][i].nodeType == 0){

				continue;

			}else{

				//Search the grandchildren

				treeNode memory _child = treeChildren[_root][_treeType][_nodeID][i];

				if(_child.ethAddress == searchTarget) return (i+1);

				for (uint8 a=0; a < spread; a++) {

					if(treeChildren[_child.ethAddress][_treeType][_child.nodeID][a].nodeType == 0){

						continue;

					}else{

						treeNode memory _gChild=treeChildren[_child.ethAddress][_treeType][_child.nodeID][a];

						if(_gChild.ethAddress == searchTarget) return ((i*2)+a+3);

					}

				}

			}

		}

		return 0;

	}

	function distributeETH(address treeRoot, address payable rewardFirst, address payable rewardSecond, uint totalETH, 

		bool isFund) internal{

		//Distribute the award

		uint moneyToDistribute = (totalETH * divideRadio) / divideRadioBase;

		uint sentETHThisTime = 0;

		require(totalETH > 2*moneyToDistribute, "Too much ether to send");

		require(address(this).balance > 2*moneyToDistribute, "Nothing to send");

		uint previousBalances = address(this).balance;

		if(rewardFirst != address(0)){

			rewardFirst.transfer(moneyToDistribute);

			sentETHThisTime += moneyToDistribute;

			ethOut += moneyToDistribute;

			if(!isFund){

				sentAmount += moneyToDistribute;

				nodeReceivedETH[rewardFirst] += moneyToDistribute;

			}

			//emit distributeETH(rewardResult.first, treeRoot, moneyToDistribute);

		} 

		if(rewardSecond != address(0)){

			//If it is repeating, the fourth children will send 0.03 less, or 30

			//The fifth and sixth children will not send out

			uint cNodeID=nodeIDIndex[rewardSecond][totalETH] - 1;

			uint8 childNum = findChildFromTop(treeRoot,rewardSecond,totalETH,cNodeID);

			if(childNum == 4){

				moneyToDistribute = (totalETH * (divideRadio-30)) / divideRadioBase;

				require(totalETH > 2*moneyToDistribute, "Too much ether to send");

				require(address(this).balance > moneyToDistribute, "Nothing to send");

			}

			if(childNum !=5 && childNum !=6){

				rewardSecond.transfer(moneyToDistribute);

				sentETHThisTime += moneyToDistribute;

				ethOut += moneyToDistribute;

			}

			if(!isFund){

				if(childNum !=5 && childNum !=6){

					sentAmount += moneyToDistribute;

					nodeReceivedETH[rewardSecond] += moneyToDistribute;

				}

				//emit distributeETH(rewardResult.second, treeRoot, moneyToDistribute);

				//Check if the node is now completed

				_checkTreeComplete(rewardSecond,totalETH,cNodeID);

			}

		}

		// Asserts are used to find bugs in your code. They should never fail

        assert(address(this).balance + sentETHThisTime >= previousBalances);

	}

    function strConcating(string memory _a, string memory _b) internal pure returns (string memory){

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        string memory ab = new string(_ba.length + _bb.length);

        bytes memory bab = bytes(ab);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];

        for (uint i = 0; i < _bb.length; i++) bab[k++] = _bb[i];

        return string(bab);

    }

    function addressToString(address _addr) public pure returns(string memory) {

        bytes32 value = bytes32(uint256(_addr));

        bytes memory alphabet = "0123456789abcdef";    

        bytes memory str = new bytes(42);

        str[0] = '0';

        str[1] = 'x';

        for (uint i = 0; i < 20; i++) {

            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];

            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];

        }

        return string(str);

    }



    function extractOneAddrFromByte(bytes memory tmp, uint start) internal pure returns (address payable){

		 if(tmp.length < start+42) return address(0); 

         uint160 iaddr = 0;

         uint160 b1;

         uint160 b2;

		 uint e=start+42;

         for (uint i=start+2; i<e; i+=2){

             iaddr *= 256;

             b1 = uint8(tmp[i]);

             b2 = uint8(tmp[i+1]);

             if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;

             else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;

             if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;

             else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;

             iaddr += (b1*16+b2);

         }

         return address(iaddr);

	}

	function getOneDigit(bytes memory b, uint start) internal pure returns (uint){

		if(b.length <= start) return 0;

		uint digit = uint8(b[start]);

		if(digit >=48 && digit<=57) return digit-48;

		return 0;

	}

	function extractUintFromByte(bytes memory b, uint start, uint length) internal pure returns (uint){

		if(b.length < start+length) return 0;

		uint result = 0;

		uint l=start+length;

		for(uint i=start;i < l; i++){

		    uint digit = uint8(b[i]);

			if(digit >=48 && digit<=57) result = (result * 10) + (digit - 48);

		}

		return result;

	}

}