/**

 *Submitted for verification at Etherscan.io on 2018-04-26

*/



pragma solidity ^0.4.18;



// <ORACLIZE_API>

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



contract OraclizeI {

    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);

    function getPrice(string _datasource) returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);

    function useCoupon(string _coupon);

    function setProofType(byte _proofType);

    function setConfig(bytes32 _config);

    function setCustomGasPrice(uint _gasPrice);

    function randomDS_getSessionPubKeyHash() returns(bytes32);

}

contract OraclizeAddrResolverI {

    function getAddress() returns (address _addr);

}

contract usingOraclize {

    uint constant day = 60*60*24;

    uint constant week = 60*60*24*7;

    uint constant month = 60*60*24*30;

    byte constant proofType_NONE = 0x00;

    byte constant proofType_TLSNotary = 0x10;

    byte constant proofType_Android = 0x20;

    byte constant proofType_Ledger = 0x30;

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

        oraclize.useCoupon(code);

        _;

    }



    function oraclize_setNetwork(uint8 networkID) internal returns(bool){

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



    function __callback(bytes32 myid, string result) {

        __callback(myid, result, new bytes(0));

    }

    function __callback(bytes32 myid, string result, bytes proof) {

    }

    

    function oraclize_useCoupon(string code) oraclizeAPI internal {

        oraclize.useCoupon(code);

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

    function oraclize_setConfig(bytes32 config) oraclizeAPI internal {

        return oraclize.setConfig(config);

    }

    

    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){

        return oraclize.randomDS_getSessionPubKeyHash();

    }



    function getCodeSize(address _addr) constant internal returns(uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function parseAddr(string _a) internal returns (address){

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



    function strCompare(string _a, string _b) internal returns (int) {

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



    function indexOf(string _haystack, string _needle) internal returns (int) {

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



    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string) {

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



    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string _a, string _b, string _c) internal returns (string) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string _a, string _b) internal returns (string) {

        return strConcat(_a, _b, "", "", "");

    }



    // parseInt

    function parseInt(string _a) internal returns (uint) {

        return parseInt(_a, 0);

    }



    // parseInt(parseFloat*10^_b)

    function parseInt(string _a, uint _b) internal returns (uint) {

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



    function uint2str(uint i) internal returns (string){

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

    

    function stra2cbor(string[] arr) internal returns (bytes) {

            uint arrlen = arr.length;



            // get correct cbor output length

            uint outputlen = 0;

            bytes[] memory elemArray = new bytes[](arrlen);

            for (uint i = 0; i < arrlen; i++) {

                elemArray[i] = (bytes(arr[i]));

                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types

            }

            uint ctr = 0;

            uint cborlen = arrlen + 0x80;

            outputlen += byte(cborlen).length;

            bytes memory res = new bytes(outputlen);



            while (byte(cborlen).length > ctr) {

                res[ctr] = byte(cborlen)[ctr];

                ctr++;

            }

            for (i = 0; i < arrlen; i++) {

                res[ctr] = 0x5F;

                ctr++;

                for (uint x = 0; x < elemArray[i].length; x++) {

                    // if there's a bug with larger strings, this may be the culprit

                    if (x % 23 == 0) {

                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;

                        elemcborlen += 0x40;

                        uint lctr = ctr;

                        while (byte(elemcborlen).length > ctr - lctr) {

                            res[ctr] = byte(elemcborlen)[ctr - lctr];

                            ctr++;

                        }

                    }

                    res[ctr] = elemArray[i][x];

                    ctr++;

                }

                res[ctr] = 0xFF;

                ctr++;

            }

            return res;

        }



    function ba2cbor(bytes[] arr) internal returns (bytes) {

            uint arrlen = arr.length;



            // get correct cbor output length

            uint outputlen = 0;

            bytes[] memory elemArray = new bytes[](arrlen);

            for (uint i = 0; i < arrlen; i++) {

                elemArray[i] = (bytes(arr[i]));

                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types

            }

            uint ctr = 0;

            uint cborlen = arrlen + 0x80;

            outputlen += byte(cborlen).length;

            bytes memory res = new bytes(outputlen);



            while (byte(cborlen).length > ctr) {

                res[ctr] = byte(cborlen)[ctr];

                ctr++;

            }

            for (i = 0; i < arrlen; i++) {

                res[ctr] = 0x5F;

                ctr++;

                for (uint x = 0; x < elemArray[i].length; x++) {

                    // if there's a bug with larger strings, this may be the culprit

                    if (x % 23 == 0) {

                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;

                        elemcborlen += 0x40;

                        uint lctr = ctr;

                        while (byte(elemcborlen).length > ctr - lctr) {

                            res[ctr] = byte(elemcborlen)[ctr - lctr];

                            ctr++;

                        }

                    }

                    res[ctr] = elemArray[i][x];

                    ctr++;

                }

                res[ctr] = 0xFF;

                ctr++;

            }

            return res;

        }

        

        

    string oraclize_network_name;

    function oraclize_setNetworkName(string _network_name) internal {

        oraclize_network_name = _network_name;

    }

    

    function oraclize_getNetworkName() internal returns (string) {

        return oraclize_network_name;

    }

    

    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){

        if ((_nbytes == 0)||(_nbytes > 32)) throw;

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(_nbytes);

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))

            mstore(sessionKeyHash, 0x20)

            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)

        }

        bytes[3] memory args = [unonce, nbytes, sessionKeyHash]; 

        bytes32 queryId = oraclize_query(_delay, "random", args, _customGasLimit);

        oraclize_randomDS_setCommitment(queryId, sha3(bytes8(_delay), args[1], sha256(args[0]), args[2]));

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

        if (address(sha3(pubkey)) == signer) return true;

        else {

            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);

            return (address(sha3(pubkey)) == signer);

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

        tosign2[0] = 1; //role

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

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) throw;

        

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) throw;

        

        _;

    }

    

    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;

        

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) return 2;

        

        return 0;

    }

    

    function matchBytes32Prefix(bytes32 content, bytes prefix) internal returns (bool){

        bool match_ = true;

        

        for (var i=0; i<prefix.length; i++){

            if (content[i] != prefix[i]) match_ = false;

        }

        

        return match_;

    }



    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){

        bool checkok;

        

        

        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)

        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;

        bytes memory keyhash = new bytes(32);

        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);

        checkok = (sha3(keyhash) == sha3(sha256(context_name, queryId)));

        if (checkok == false) return false;

        

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);

        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);

        

        

        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)

        checkok = matchBytes32Prefix(sha256(sig1), result);

        if (checkok == false) return false;

        

        

        // Step 4: commitment match verification, sha3(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8+1+32);

        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);

        

        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;

        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);

        

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (oraclize_randomDS_args[queryId] == sha3(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[queryId];

        } else return false;

        

        

        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32+8+1+32);

        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);

        checkok = verifySig(sha256(tosign1), sig1, sessionPubkey);

        if (checkok == false) return false;

        

        // verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);

        }

        

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }



    

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal returns (bytes) {

        uint minLength = length + toOffset;



        if (to.length < minLength) {

            // Buffer too small

            throw; // Should be a better way?

        }



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

        

}

// </ORACLIZE_API>



/*

 * @title String & slice utility library for Solidity contracts.

 * @author Nick Johnson <[email protected]>

 *

 * @dev Functionality in this library is largely implemented using an

 *      abstraction called a 'slice'. A slice represents a part of a string -

 *      anything from the entire string to a single character, or even no

 *      characters at all (a 0-length slice). Since a slice only has to specify

 *      an offset and a length, copying and manipulating slices is a lot less

 *      expensive than copying and manipulating the strings they reference.

 *

 *      To further reduce gas costs, most functions on slice that need to return

 *      a slice modify the original one instead of allocating a new one; for

 *      instance, `s.split(".")` will return the text up to the first '.',

 *      modifying s to only contain the remainder of the string after the '.'.

 *      In situations where you do not want to modify the original slice, you

 *      can make a copy first with `.copy()`, for example:

 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since

 *      Solidity has no memory management, it will result in allocating many

 *      short-lived slices that are later discarded.

 *

 *      Functions that return two slices come in two versions: a non-allocating

 *      version that takes the second slice as an argument, modifying it in

 *      place, and an allocating version that allocates and returns the second

 *      slice; see `nextRune` for example.

 *

 *      Functions that have to copy string data will return strings rather than

 *      slices; these can be cast back to slices for further processing if

 *      required.

 *

 *      For convenience, some functions are provided with non-modifying

 *      variants that create a new slice and return both; for instance,

 *      `s.splitNew('.')` leaves s unmodified, and returns two values

 *      corresponding to the left and right parts of the string.

 */

library strings {

    struct slice {

        uint _len;

        uint _ptr;

    }



    function memcpy(uint dest, uint src, uint len) private {

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

    }



    /*

     * @dev Returns a slice containing the entire string.

     * @param self The string to make a slice from.

     * @return A newly allocated slice containing the entire string.

     */

    function toSlice(string self) internal returns (slice) {

        uint ptr;

        assembly {

            ptr := add(self, 0x20)

        }

        return slice(bytes(self).length, ptr);

    }



    /*

     * @dev Returns the length of a null-terminated bytes32 string.

     * @param self The value to find the length of.

     * @return The length of the string, from 0 to 32.

     */

    function len(bytes32 self) internal returns (uint) {

        uint ret;

        if (self == 0)

            return 0;

        if (self & 0xffffffffffffffffffffffffffffffff == 0) {

            ret += 16;

            self = bytes32(uint(self) / 0x100000000000000000000000000000000);

        }

        if (self & 0xffffffffffffffff == 0) {

            ret += 8;

            self = bytes32(uint(self) / 0x10000000000000000);

        }

        if (self & 0xffffffff == 0) {

            ret += 4;

            self = bytes32(uint(self) / 0x100000000);

        }

        if (self & 0xffff == 0) {

            ret += 2;

            self = bytes32(uint(self) / 0x10000);

        }

        if (self & 0xff == 0) {

            ret += 1;

        }

        return 32 - ret;

    }



    /*

     * @dev Returns a slice containing the entire bytes32, interpreted as a

     *      null-termintaed utf-8 string.

     * @param self The bytes32 value to convert to a slice.

     * @return A new slice containing the value of the input argument up to the

     *         first null.

     */

    function toSliceB32(bytes32 self) internal returns (slice ret) {

        // Allocate space for `self` in memory, copy it there, and point ret at it

        assembly {

            let ptr := mload(0x40)

            mstore(0x40, add(ptr, 0x20))

            mstore(ptr, self)

            mstore(add(ret, 0x20), ptr)

        }

        ret._len = len(self);

    }



    /*

     * @dev Returns a new slice containing the same data as the current slice.

     * @param self The slice to copy.

     * @return A new slice containing the same data as `self`.

     */

    function copy(slice self) internal returns (slice) {

        return slice(self._len, self._ptr);

    }



    /*

     * @dev Copies a slice to a new string.

     * @param self The slice to copy.

     * @return A newly allocated string containing the slice's text.

     */

    function toString(slice self) internal returns (string) {

        var ret = new string(self._len);

        uint retptr;

        assembly { retptr := add(ret, 32) }



        memcpy(retptr, self._ptr, self._len);

        return ret;

    }



    /*

     * @dev Returns the length in runes of the slice. Note that this operation

     *      takes time proportional to the length of the slice; avoid using it

     *      in loops, and call `slice.empty()` if you only need to know whether

     *      the slice is empty or not.

     * @param self The slice to operate on.

     * @return The length of the slice in runes.

     */

    function len(slice self) internal returns (uint) {

        // Starting at ptr-31 means the LSB will be the byte we care about

        var ptr = self._ptr - 31;

        var end = ptr + self._len;

        for (uint len = 0; ptr < end; len++) {

            uint8 b;

            assembly { b := and(mload(ptr), 0xFF) }

            if (b < 0x80) {

                ptr += 1;

            } else if(b < 0xE0) {

                ptr += 2;

            } else if(b < 0xF0) {

                ptr += 3;

            } else if(b < 0xF8) {

                ptr += 4;

            } else if(b < 0xFC) {

                ptr += 5;

            } else {

                ptr += 6;

            }

        }

        return len;

    }



    /*

     * @dev Returns true if the slice is empty (has a length of 0).

     * @param self The slice to operate on.

     * @return True if the slice is empty, False otherwise.

     */

    function empty(slice self) internal returns (bool) {

        return self._len == 0;

    }



    /*

     * @dev Returns a positive number if `other` comes lexicographically after

     *      `self`, a negative number if it comes before, or zero if the

     *      contents of the two slices are equal. Comparison is done per-rune,

     *      on unicode codepoints.

     * @param self The first slice to compare.

     * @param other The second slice to compare.

     * @return The result of the comparison.

     */

    function compare(slice self, slice other) internal returns (int) {

        uint shortest = self._len;

        if (other._len < self._len)

            shortest = other._len;



        var selfptr = self._ptr;

        var otherptr = other._ptr;

        for (uint idx = 0; idx < shortest; idx += 32) {

            uint a;

            uint b;

            assembly {

                a := mload(selfptr)

                b := mload(otherptr)

            }

            if (a != b) {

                // Mask out irrelevant bytes and check again

                uint mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);

                var diff = (a & mask) - (b & mask);

                if (diff != 0)

                    return int(diff);

            }

            selfptr += 32;

            otherptr += 32;

        }

        return int(self._len) - int(other._len);

    }



    /*

     * @dev Returns true if the two slices contain the same text.

     * @param self The first slice to compare.

     * @param self The second slice to compare.

     * @return True if the slices are equal, false otherwise.

     */

    function equals(slice self, slice other) internal returns (bool) {

        return compare(self, other) == 0;

    }



    /*

     * @dev Extracts the first rune in the slice into `rune`, advancing the

     *      slice to point to the next rune and returning `self`.

     * @param self The slice to operate on.

     * @param rune The slice that will contain the first rune.

     * @return `rune`.

     */

    function nextRune(slice self, slice rune) internal returns (slice) {

        rune._ptr = self._ptr;



        if (self._len == 0) {

            rune._len = 0;

            return rune;

        }



        uint len;

        uint b;

        // Load the first byte of the rune into the LSBs of b

        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }

        if (b < 0x80) {

            len = 1;

        } else if(b < 0xE0) {

            len = 2;

        } else if(b < 0xF0) {

            len = 3;

        } else {

            len = 4;

        }



        // Check for truncated codepoints

        if (len > self._len) {

            rune._len = self._len;

            self._ptr += self._len;

            self._len = 0;

            return rune;

        }



        self._ptr += len;

        self._len -= len;

        rune._len = len;

        return rune;

    }



    /*

     * @dev Returns the first rune in the slice, advancing the slice to point

     *      to the next rune.

     * @param self The slice to operate on.

     * @return A slice containing only the first rune from `self`.

     */

    function nextRune(slice self) internal returns (slice ret) {

        nextRune(self, ret);

    }



    /*

     * @dev Returns the number of the first codepoint in the slice.

     * @param self The slice to operate on.

     * @return The number of the first codepoint in the slice.

     */

    function ord(slice self) internal returns (uint ret) {

        if (self._len == 0) {

            return 0;

        }



        uint word;

        uint len;

        uint div = 2 ** 248;



        // Load the rune into the MSBs of b

        assembly { word:= mload(mload(add(self, 32))) }

        var b = word / div;

        if (b < 0x80) {

            ret = b;

            len = 1;

        } else if(b < 0xE0) {

            ret = b & 0x1F;

            len = 2;

        } else if(b < 0xF0) {

            ret = b & 0x0F;

            len = 3;

        } else {

            ret = b & 0x07;

            len = 4;

        }



        // Check for truncated codepoints

        if (len > self._len) {

            return 0;

        }



        for (uint i = 1; i < len; i++) {

            div = div / 256;

            b = (word / div) & 0xFF;

            if (b & 0xC0 != 0x80) {

                // Invalid UTF-8 sequence

                return 0;

            }

            ret = (ret * 64) | (b & 0x3F);

        }



        return ret;

    }



    /*

     * @dev Returns the keccak-256 hash of the slice.

     * @param self The slice to hash.

     * @return The hash of the slice.

     */

    function keccak(slice self) internal returns (bytes32 ret) {

        assembly {

            ret := sha3(mload(add(self, 32)), mload(self))

        }

    }



    /*

     * @dev Returns true if `self` starts with `needle`.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return True if the slice starts with the provided text, false otherwise.

     */

    function startsWith(slice self, slice needle) internal returns (bool) {

        if (self._len < needle._len) {

            return false;

        }



        if (self._ptr == needle._ptr) {

            return true;

        }



        bool equal;

        assembly {

            let len := mload(needle)

            let selfptr := mload(add(self, 0x20))

            let needleptr := mload(add(needle, 0x20))

            equal := eq(sha3(selfptr, len), sha3(needleptr, len))

        }

        return equal;

    }



    /*

     * @dev If `self` starts with `needle`, `needle` is removed from the

     *      beginning of `self`. Otherwise, `self` is unmodified.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return `self`

     */

    function beyond(slice self, slice needle) internal returns (slice) {

        if (self._len < needle._len) {

            return self;

        }



        bool equal = true;

        if (self._ptr != needle._ptr) {

            assembly {

                let len := mload(needle)

                let selfptr := mload(add(self, 0x20))

                let needleptr := mload(add(needle, 0x20))

                equal := eq(sha3(selfptr, len), sha3(needleptr, len))

            }

        }



        if (equal) {

            self._len -= needle._len;

            self._ptr += needle._len;

        }



        return self;

    }



    /*

     * @dev Returns true if the slice ends with `needle`.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return True if the slice starts with the provided text, false otherwise.

     */

    function endsWith(slice self, slice needle) internal returns (bool) {

        if (self._len < needle._len) {

            return false;

        }



        var selfptr = self._ptr + self._len - needle._len;



        if (selfptr == needle._ptr) {

            return true;

        }



        bool equal;

        assembly {

            let len := mload(needle)

            let needleptr := mload(add(needle, 0x20))

            equal := eq(sha3(selfptr, len), sha3(needleptr, len))

        }



        return equal;

    }



    /*

     * @dev If `self` ends with `needle`, `needle` is removed from the

     *      end of `self`. Otherwise, `self` is unmodified.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return `self`

     */

    function until(slice self, slice needle) internal returns (slice) {

        if (self._len < needle._len) {

            return self;

        }



        var selfptr = self._ptr + self._len - needle._len;

        bool equal = true;

        if (selfptr != needle._ptr) {

            assembly {

                let len := mload(needle)

                let needleptr := mload(add(needle, 0x20))

                equal := eq(sha3(selfptr, len), sha3(needleptr, len))

            }

        }



        if (equal) {

            self._len -= needle._len;

        }



        return self;

    }



    // Returns the memory address of the first byte of the first occurrence of

    // `needle` in `self`, or the first byte after `self` if not found.

    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {

        uint ptr;

        uint idx;



        if (needlelen <= selflen) {

            if (needlelen <= 32) {

                // Optimized assembly for 68 gas per byte on short strings

                assembly {

                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))

                    let needledata := and(mload(needleptr), mask)

                    let end := add(selfptr, sub(selflen, needlelen))

                    ptr := selfptr

                    loop:

                    jumpi(exit, eq(and(mload(ptr), mask), needledata))

                    ptr := add(ptr, 1)

                    jumpi(loop, lt(sub(ptr, 1), end))

                    ptr := add(selfptr, selflen)

                    exit:

                }

                return ptr;

            } else {

                // For long needles, use hashing

                bytes32 hash;

                assembly { hash := sha3(needleptr, needlelen) }

                ptr = selfptr;

                for (idx = 0; idx <= selflen - needlelen; idx++) {

                    bytes32 testHash;

                    assembly { testHash := sha3(ptr, needlelen) }

                    if (hash == testHash)

                        return ptr;

                    ptr += 1;

                }

            }

        }

        return selfptr + selflen;

    }



    // Returns the memory address of the first byte after the last occurrence of

    // `needle` in `self`, or the address of `self` if not found.

    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {

        uint ptr;



        if (needlelen <= selflen) {

            if (needlelen <= 32) {

                // Optimized assembly for 69 gas per byte on short strings

                assembly {

                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))

                    let needledata := and(mload(needleptr), mask)

                    ptr := add(selfptr, sub(selflen, needlelen))

                    loop:

                    jumpi(ret, eq(and(mload(ptr), mask), needledata))

                    ptr := sub(ptr, 1)

                    jumpi(loop, gt(add(ptr, 1), selfptr))

                    ptr := selfptr

                    jump(exit)

                    ret:

                    ptr := add(ptr, needlelen)

                    exit:

                }

                return ptr;

            } else {

                // For long needles, use hashing

                bytes32 hash;

                assembly { hash := sha3(needleptr, needlelen) }

                ptr = selfptr + (selflen - needlelen);

                while (ptr >= selfptr) {

                    bytes32 testHash;

                    assembly { testHash := sha3(ptr, needlelen) }

                    if (hash == testHash)

                        return ptr + needlelen;

                    ptr -= 1;

                }

            }

        }

        return selfptr;

    }



    /*

     * @dev Modifies `self` to contain everything from the first occurrence of

     *      `needle` to the end of the slice. `self` is set to the empty slice

     *      if `needle` is not found.

     * @param self The slice to search and modify.

     * @param needle The text to search for.

     * @return `self`.

     */

    function find(slice self, slice needle) internal returns (slice) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);

        self._len -= ptr - self._ptr;

        self._ptr = ptr;

        return self;

    }



    /*

     * @dev Modifies `self` to contain the part of the string from the start of

     *      `self` to the end of the first occurrence of `needle`. If `needle`

     *      is not found, `self` is set to the empty slice.

     * @param self The slice to search and modify.

     * @param needle The text to search for.

     * @return `self`.

     */

    function rfind(slice self, slice needle) internal returns (slice) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);

        self._len = ptr - self._ptr;

        return self;

    }



    /*

     * @dev Splits the slice, setting `self` to everything after the first

     *      occurrence of `needle`, and `token` to everything before it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and `token` is set to the entirety of `self`.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @param token An output parameter to which the first token is written.

     * @return `token`.

     */

    function split(slice self, slice needle, slice token) internal returns (slice) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);

        token._ptr = self._ptr;

        token._len = ptr - self._ptr;

        if (ptr == self._ptr + self._len) {

            // Not found

            self._len = 0;

        } else {

            self._len -= token._len + needle._len;

            self._ptr = ptr + needle._len;

        }

        return token;

    }



    /*

     * @dev Splits the slice, setting `self` to everything after the first

     *      occurrence of `needle`, and returning everything before it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and the entirety of `self` is returned.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @return The part of `self` up to the first occurrence of `delim`.

     */

    function split(slice self, slice needle) internal returns (slice token) {

        split(self, needle, token);

    }



    /*

     * @dev Splits the slice, setting `self` to everything before the last

     *      occurrence of `needle`, and `token` to everything after it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and `token` is set to the entirety of `self`.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @param token An output parameter to which the first token is written.

     * @return `token`.

     */

    function rsplit(slice self, slice needle, slice token) internal returns (slice) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);

        token._ptr = ptr;

        token._len = self._len - (ptr - self._ptr);

        if (ptr == self._ptr) {

            // Not found

            self._len = 0;

        } else {

            self._len -= token._len + needle._len;

        }

        return token;

    }



    /*

     * @dev Splits the slice, setting `self` to everything before the last

     *      occurrence of `needle`, and returning everything after it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and the entirety of `self` is returned.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @return The part of `self` after the last occurrence of `delim`.

     */

    function rsplit(slice self, slice needle) internal returns (slice token) {

        rsplit(self, needle, token);

    }



    /*

     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.

     * @param self The slice to search.

     * @param needle The text to search for in `self`.

     * @return The number of occurrences of `needle` found in `self`.

     */

    function count(slice self, slice needle) internal returns (uint count) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;

        while (ptr <= self._ptr + self._len) {

            count++;

            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;

        }

    }



    /*

     * @dev Returns True if `self` contains `needle`.

     * @param self The slice to search.

     * @param needle The text to search for in `self`.

     * @return True if `needle` is found in `self`, false otherwise.

     */

    function contains(slice self, slice needle) internal returns (bool) {

        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;

    }



    /*

     * @dev Returns a newly allocated string containing the concatenation of

     *      `self` and `other`.

     * @param self The first slice to concatenate.

     * @param other The second slice to concatenate.

     * @return The concatenation of the two strings.

     */

    function concat(slice self, slice other) internal returns (string) {

        var ret = new string(self._len + other._len);

        uint retptr;

        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);

        memcpy(retptr + self._len, other._ptr, other._len);

        return ret;

    }



    /*

     * @dev Joins an array of slices, using `self` as a delimiter, returning a

     *      newly allocated string.

     * @param self The delimiter to use.

     * @param parts A list of slices to join.

     * @return A newly allocated string containing all the slices in `parts`,

     *         joined with `self`.

     */

    function join(slice self, slice[] parts) internal returns (string) {

        if (parts.length == 0)

            return "";



        uint len = self._len * (parts.length - 1);

        for(uint i = 0; i < parts.length; i++)

            len += parts[i]._len;



        var ret = new string(len);

        uint retptr;

        assembly { retptr := add(ret, 32) }



        for(i = 0; i < parts.length; i++) {

            memcpy(retptr, parts[i]._ptr, parts[i]._len);

            retptr += parts[i]._len;

            if (i < parts.length - 1) {

                memcpy(retptr, self._ptr, self._len);

                retptr += self._len;

            }

        }



        return ret;

    }

}





contract SafeMath {

    function safeToAdd(uint a, uint b) pure internal returns (bool) {

        return (a + b >= a);

    }

    function safeAdd(uint a, uint b) pure internal returns (uint) {

        require(safeToAdd(a, b));

        return (a + b);

    }



    function safeToSubtract(uint a, uint b) pure internal returns (bool) {

        return (b <= a);

    }



    function safeSub(uint a, uint b) pure internal returns (uint) {

        require(safeToSubtract(a, b));

        return (a - b);

    }

}







/**

 * @title Etherwow

 * @dev user choose a num in [2,99] system generate a num in [1,100], if num user choosed  > num system generated, user win, otherwise user lose

 */

contract Etherwow is usingOraclize, SafeMath {

    

     using strings for *;



    /*

     * checks user profit, bet size and user number is within range

    */

    modifier betIsValid(uint _betSize, uint _userNumber) {

        require(((((_betSize * (100-(safeSub(_userNumber,1)))) / (safeSub(_userNumber,1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize <= maxProfit && _betSize >= minBet && _userNumber >= minNumber && _userNumber <= maxNumber); 

        _;

    }



    /*

     * checks game is currently active

    */

    modifier gameIsActive {

        require(gamePaused == false);

        _;

    }     



    /*

     * checks only Oraclize address is calling

    */

    modifier onlyOraclize {

        require(msg.sender == oraclize_cbAddress());

        _;

    }



    /*

     * checks only owner address is calling

    */

    modifier onlyOwner {

         require(msg.sender == owner);

         _;

    }



    /*

     * checks only owner address is calling

    */

    modifier onlyOwnerOrOperator {

         require((msg.sender == owner || msg.sender == operator.addr) && msg.sender != 0x0);

         _;

    }



    /*

     * game vars

    */ 

    uint constant public maxProfitDivisor = 1000000;

    uint constant public houseEdgeDivisor = 1000;    

    uint constant public maxNumber = 99; 

    uint constant public minNumber = 2;

    

    bool public gamePaused;

    uint32 public gasForOraclize;

    address public owner;

    uint public contractBalance;

    uint public houseEdge;     

    uint public maxProfit;   

    uint public maxProfitAsPercentOfHouse;                    

    uint public minBet; 

    uint public maxPendingPayouts;

    uint public randomQueryID;

    uint public randomGenerateMethod;

    string private randomApiKey;

    

    /* init discontinued contract data */     

    uint public totalBets = 0;

    uint public totalWeiWon = 0;

    uint public totalWeiWagered = 0; 



    /* access control */

    Operator public operator;



    struct Operator{

        address addr;

        bool refundPermission;  /* true - have permission, false - don't have permission */

        uint refundAmtApprove;  /* when refundAmtApprove not enough, use ownerModOperator() to set again */

    }



 



    /*

     * user vars

    */

    mapping (bytes32 => address) public userAddress;

    mapping (bytes32 => address) public userTempAddress;

    mapping (bytes32 => bytes32) public userBetId;

    mapping (bytes32 => uint) public  userBetValue;

    mapping (bytes32 => uint) public  userTempBetValue;               

    mapping (bytes32 => uint) public  userDieResult;

    mapping (bytes32 => uint) public  userNumber;

    mapping (address => uint) public  userPendingWithdrawals;      

    mapping (bytes32 => uint) public  userProfit;

    mapping (bytes32 => uint) public  userTempReward;           

    /* Status: 0=lose, 1=win, 2=win + failed send, 3=refund, 4=refund + failed send, 5=pending, 6=manual refund */

    mapping (bytes32 => uint8) public  betStatus;           



    /*

     * events

    */

    /* log bets + output to web3 for precise 'payout on win' field in UI */

    event LogBet(bytes32 indexed BetID, address indexed UserAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint UserNumber, uint RandomQueryID);      

    /* output to web3 UI on bet result*/

    event LogResult(bytes32 indexed BetID, address indexed UserAddress, uint UserNumber, uint DiceResult, uint Value, uint8 Status, uint RandomGenerateMethod, bytes Proof, uint indexed SerialNumberOfResult);   

    /* log manual refunds */

    event LogRefund(bytes32 indexed BetID, address indexed UserAddress, uint indexed RefundValue);

    /* log owner transfers */

    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);





    /*

     * init

    */

    function Etherwow() {



        owner = msg.sender;

        oraclize_setNetwork(networkID_auto);        

        /* init 990 = 99% (1% houseEdge)*/

        ownerSetHouseEdge(990);

        /* init 10,000 = 1%  */

        ownerSetMaxProfitAsPercentOfHouse(10000);

        /* init min bet (0.1 ether) */

        ownerSetMinBet(100000000000000000);        

        /* init gas for oraclize */        

        gasForOraclize = 250000;  

        /* init gas price for callback (default 20 gwei)*/

        oraclize_setCustomGasPrice(20000000000 wei);

        /* defult random num generation method 0-random.org */

        randomGenerateMethod = 0; 



    }



    /*

     * @dev generate a true random num, two methods are provide, to avoid single point failure

     *      randomGenerateMethod = 0 - random num generate from random.org

     *      randomGenerateMethod = 1 - random num generate from oraclize service

     * @return oraclize queryId

     */

    function generateRandomNum() internal returns(bytes32){

        /* random num solution from random.org */

        if (randomGenerateMethod == 0){

                randomQueryID += 1;

                string memory queryString1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":";

                string memory queryString1_1 = ",\"n\":1,\"min\":1,\"max\":100,\"replacement\":true,\"base\":10${[identity] \"}\"},\"id\":";

                queryString1 = queryString1.toSlice().concat(randomApiKey.toSlice());

                queryString1 = queryString1.toSlice().concat(queryString1_1.toSlice());



                string memory queryString2 = uint2str(randomQueryID);

                string memory queryString3 = "${[identity] \"}\"}']";



                string memory queryString1_2 = queryString1.toSlice().concat(queryString2.toSlice());



                string memory queryString1_2_3 = queryString1_2.toSlice().concat(queryString3.toSlice()); 



                oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);

                return oraclize_query("nested", queryString1_2_3, gasForOraclize);               

        }



        /* random num solution from oraclize(by default), prove fair paper: http://www.oraclize.it/papers/random_datasource-rev1.pdf */

        if (randomGenerateMethod == 1){

                randomQueryID += 1;

                uint N = 8; /* number of random bytes we want the datasource to return */

                uint delay = 0; /* number of seconds to wait before the execution takes place */

                oraclize_setProof(proofType_Ledger);

                return oraclize_newRandomDSQuery(delay, N, gasForOraclize); /* this function internally generates the correct oraclize_query and returns its queryId */

                

        }

        



    }



    /*

     * @dev validate roll dice request, and log the bet info

     * @param number player choosen, from [2,99]

     */

    function userRollDice(uint rollUnder) public 

        payable

        gameIsActive

        betIsValid(msg.value, rollUnder)

    {       



        bytes32 rngId = generateRandomNum(); 

       

        /* map bet id to this oraclize query */

        userBetId[rngId] = rngId;

        /* map user lucky number to this oraclize query */

        userNumber[rngId] = rollUnder;

        /* map value of wager to this oraclize query */

        userBetValue[rngId] = msg.value;

        /* map user address to this oraclize query */

        userAddress[rngId] = msg.sender;

        /* safely map user profit to this oraclize query */                     

        userProfit[rngId] = ((((msg.value * (100-(safeSub(rollUnder,1)))) / (safeSub(rollUnder,1))+msg.value))*houseEdge/houseEdgeDivisor)-msg.value;        

        /* safely increase maxPendingPayouts liability - calc all pending payouts under assumption they win */

        maxPendingPayouts = safeAdd(maxPendingPayouts, userProfit[rngId]);

        /* check contract can payout on win */

        require(maxPendingPayouts < contractBalance);

        /* bet status = 5-pending */

        betStatus[rngId] = 5;

        /* provides accurate numbers for web3 and allows for manual refunds in case of no oraclize __callback */

        emit LogBet(userBetId[rngId], userAddress[rngId], safeAdd(userBetValue[rngId], userProfit[rngId]), userProfit[rngId], userBetValue[rngId], userNumber[rngId], randomQueryID);          



    }   

             



    /*

     * @dev oraclize callback, only oraclize can call, payout should in active status

     * @param queryId

     * @param query result

     * @param query proof

     */

    function __callback(bytes32 myid, string result, bytes proof) public   

        onlyOraclize

    {  

        /* user address mapped to query id does not exist */

        require(userAddress[myid]!=0x0);



        /* random num solution from random.org(by default) */

        if (randomGenerateMethod == 0){

                /* keep oraclize honest by retrieving the serialNumber from random.org result */

                var sl_result = result.toSlice();

                sl_result.beyond("[".toSlice()).until("]".toSlice());

                uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());          



                /* map random result to user */

                userDieResult[myid] = parseInt(sl_result.beyond("[".toSlice()).until("]".toSlice()).toString());                 

        } 



        /* random num solution from oraclize */        

        if (randomGenerateMethod == 1){

                uint maxRange = 100; /* this is the highest uint we want to get. It should never be greater than 2^(8*N), where N is the number of random bytes we had asked the datasource to return */

                userDieResult[myid] = uint(sha3(result)) % maxRange + 1; /* this is an efficient way to get the uint out in the [0, maxRange] range */

        }

      

        /* get the userAddress for this query id */

        userTempAddress[myid] = userAddress[myid];

        /* delete userAddress for this query id */

        delete userAddress[myid];



        /* map the userProfit for this query id */

        userTempReward[myid] = userProfit[myid];

        /* set  userProfit for this query id to 0 */

        userProfit[myid] = 0; 



        /* safely reduce maxPendingPayouts liability */

        maxPendingPayouts = safeSub(maxPendingPayouts, userTempReward[myid]);         



        /* map the userBetValue for this query id */

        userTempBetValue[myid] = userBetValue[myid];

        /* set  userBetValue for this query id to 0 */

        userBetValue[myid] = 0; 



        /* total number of bets */

        totalBets += 1;



        /* total wagered */

        totalWeiWagered += userTempBetValue[myid];                                                           



        /*

        * refund

        * if result is 0 result is empty or no proof refund original bet value

        * if refund fails save refund value to userPendingWithdrawals

        */

        if(userDieResult[myid] == 0 || bytes(result).length == 0 || bytes(proof).length == 0){                                                     

             /* Status: 0=lose, 1=win, 2=win + failed send, 3=refund, 4=refund + failed send*/ 

             /* 3 = refund */

             betStatus[myid] = 3;

            /*

            * send refund - external call to an untrusted contract

            * if send fails map refund value to userPendingWithdrawals[address]

            * for withdrawal later via userWithdrawPendingTransactions

            */

            if(!userTempAddress[myid].send(userTempBetValue[myid])){

                /* 4 = refund + failed send */

                betStatus[myid] = 4;              

                /* if send failed let user withdraw via userWithdrawPendingTransactions */

                userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], userTempBetValue[myid]);                        

            }

            emit LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], betStatus[myid], randomGenerateMethod, proof, serialNumberOfResult);

            return;

        }



        /*

        * pay winner

        * update contract balance to calculate new max bet

        * send reward

        * if send of reward fails save value to userPendingWithdrawals        

        */

        if(userDieResult[myid] < userNumber[myid]){ 



            /* safely reduce contract balance by user profit */

            contractBalance = safeSub(contractBalance, userTempReward[myid]); 



            /* update total wei won */

            totalWeiWon = safeAdd(totalWeiWon, userTempReward[myid]);              



            /* safely calculate payout via profit plus original wager */

            userTempReward[myid] = safeAdd(userTempReward[myid], userTempBetValue[myid]); 



            /* 1 = win */

            betStatus[myid] = 1;                           



            /* update maximum profit */

            setMaxProfit();

            

            /*

            * send win - external call to an untrusted contract

            * if send fails map reward value to userPendingWithdrawals[address]

            * for withdrawal later via userWithdrawPendingTransactions

            */

            if(!userTempAddress[myid].send(userTempReward[myid])){

                /* 2 = win + failed send */

                betStatus[myid] = 2;                   

                /* if send failed let user withdraw via userWithdrawPendingTransactions */

                userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], userTempReward[myid]);                               

            }

            

            emit LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], betStatus[myid], randomGenerateMethod, proof, serialNumberOfResult);

            return;



        }



        /*

        * no win

        * send 1 wei to a losing bet

        * update contract balance to calculate new max bet

        */

        if(userDieResult[myid] >= userNumber[myid]){



            /* 0 = lose */

            betStatus[myid] = 0;

            emit LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], betStatus[myid], randomGenerateMethod, proof, serialNumberOfResult);                                



            /*  

            *  safe adjust contractBalance

            *  setMaxProfit

            *  send 1 wei to losing bet

            */

            contractBalance = safeAdd(contractBalance, (userTempBetValue[myid]-1));                                                                         



            /* update maximum profit */

            setMaxProfit(); 



            /*

            * send 1 wei - external call to an untrusted contract                  

            */

            if(!userTempAddress[myid].send(1)){

                /* if send failed let user withdraw via userWithdrawPendingTransactions */                

               userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], 1);                                

            }                                   



            return;



        }



    }

    

    /*

     * @dev in case of a failed refund or win send, user can withdraw later

     * @return true - withdraw success, false - withdraw failed

     */

    function userWithdrawPendingTransactions() public 

        gameIsActive

        returns (bool)

     {

        uint withdrawAmount = userPendingWithdrawals[msg.sender];

        userPendingWithdrawals[msg.sender] = 0;

        /* external call to untrusted contract */

        if (msg.sender.call.value(withdrawAmount)()) {

            return true;

        } else {

            /* if send failed revert userPendingWithdrawals[msg.sender] = 0; */

            /* user can try to withdraw again later */

            userPendingWithdrawals[msg.sender] = withdrawAmount;

            return false;

        }

    }



    /*

     * @dev in case of a failed refund or win send, user can check pending withdraw

     * @param address to check

     * @return pending withdraw amount

     */

    function userGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {

        return userPendingWithdrawals[addressToCheck];

    }



    /*

     * @dev sets max profit

     */

    function setMaxProfit() internal {

        maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;  

    }      



    /*

     * @dev fallback method

     */

    function ()

        payable

        onlyOwnerOrOperator

    {

        /* safely update contract balance */

        contractBalance = safeAdd(contractBalance, msg.value);        

        /* update the maximum profit */

        setMaxProfit();

    } 

     

     /*

     * @dev owner can set operator & permission

     * if want to revoke a permission, just set address to "0x0"

     * @param operator address

     * @param operator transfer permission

     * @param operator transfer approve amt

     * @param operator refund permission

     * @param operator refund approve amt

     */  

    function ownerModOperator(address newAddress, bool newRefundPermission, uint newRefundAmtApprove) public 

        onlyOwner

    {

        operator.addr = newAddress;

        operator.refundPermission = newRefundPermission;

        operator.refundAmtApprove = newRefundAmtApprove;            

    }



    /*

     * @dev onlyOwnerOrOperator set gas price for oraclize callback

     */

    function ownerSetCallbackGasPrice(uint newCallbackGasPrice) public 

        onlyOwnerOrOperator

    {

        oraclize_setCustomGasPrice(newCallbackGasPrice);

    }     



    /*

     * @dev onlyOwnerOrOperator set gas limit for oraclize query

     */

    function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public 

        onlyOwnerOrOperator

    {

        gasForOraclize = newSafeGasToOraclize;

    }



    /*

     * @dev onlyOwnerOrOperator adjust contract balance variable (only used for max profit calc)

     */

    function ownerUpdateContractBalance(uint newContractBalanceInWei) public 

        onlyOwnerOrOperator

    {        

       contractBalance = newContractBalanceInWei;

    }    



    /*

     * @dev owner set houseEdge

     */    

    function ownerSetHouseEdge(uint newHouseEdge) public 

        onlyOwnerOrOperator

    {

        if(msg.sender == operator.addr && newHouseEdge > 990) throw;

        houseEdge = newHouseEdge;

    }



    /*

     * @dev onlyOwnerOrOperator set maxProfitAsPercentOfHouse

     */    

    function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public 

        onlyOwnerOrOperator

    {

        /* restrict each bet to a maximum profit of 5% contractBalance */

        require(newMaxProfitAsPercent <= 50000);



        maxProfitAsPercentOfHouse = newMaxProfitAsPercent;

        setMaxProfit();

    }



    /*

     * @dev onlyOwnerOrOperator set minBet

     */        

    function ownerSetMinBet(uint newMinimumBet) public 

        onlyOwnerOrOperator

    {

        minBet = newMinimumBet;

    }       



    /*

     * @dev owner transfer ether

     */  

    function ownerTransferEther(address sendTo, uint amount) public 

        onlyOwner

    {        

        /* safely update contract balance when sending out funds*/

        contractBalance = safeSub(contractBalance, amount);     

        /* update max profit */

        setMaxProfit();

        sendTo.transfer(amount);

        emit LogOwnerTransfer(sendTo, amount); 

    }



    /*

     * @dev manual refund

     * only onlyOwnerOrOperator address can do manual refund

     * used only if bet placed but not execute payout method after stock market close

     * filter LogBet by address and/or userBetId, do manual refund only when meet below conditions:

     * 1. record should in logBet;

     * 2. record should not in logResult;

     * 3. record should not in logRefund;

     * if LogResult exists user should use the withdraw pattern userWithdrawPendingTransactions

     * if LogRefund exists means manual refund has been done before!

     * @param betId

     * @param address sendTo

     * @param original user profit

     * @param original bet value

    */

    function ownerRefundUser(bytes32 originalUserBetId, address sendTo, uint originalUserProfit, uint originalUserBetValue) public 

        onlyOwnerOrOperator

    {        

        require(msg.sender == owner || (msg.sender == operator.addr && operator.refundPermission == true && safeToSubtract(operator.refundAmtApprove, originalUserBetValue)));

        /* safely reduce pendingPayouts by userProfit[rngId] */

        maxPendingPayouts = safeSub(maxPendingPayouts, originalUserProfit);

        /* send refund */

        sendTo.transfer(originalUserBetValue);

        /* decrease approve amt if it's triggered by operator(no need to use safesub here, since passed above require() statement) */

        if(msg.sender == operator.addr){

            operator.refundAmtApprove = operator.refundAmtApprove -  originalUserBetValue;

        }

        /* update betStatus = 6-manual refund */

        betStatus[originalUserBetId] = 6;

        /* log refunds */

        emit LogRefund(originalUserBetId, sendTo, originalUserBetValue);        

    }    



    /*

     * @dev onlyOwnerOrOperator set system emergency pause

     * @param true: pause, false: not pause

     */ 

    function ownerPauseGame(bool newStatus) public 

        onlyOwnerOrOperator

    {

        gamePaused = newStatus;

    }





    /*

     * @dev owner set new owner

     * @param new owner address

     */ 

    function ownerChangeOwner(address newOwner) public 

        onlyOwner

    {

        owner = newOwner;

    }



    /*

     * @dev onlyOwnerOrOperator set random.org api key

     * @param new api key

     */ 

    function ownerSetRandomApiKey(string newApiKey) public 

        onlyOwnerOrOperator

    {

        randomApiKey = newApiKey;

    } 



    /*

     * @dev onlyOwnerOrOperator can set randomGenerateMethod

     * @param 0-random num solution from random.org, 1-random num solution from oraclize

     */  

    function ownerSetRandomGenerateMethod(uint newRandomGenerateMethod) public 

        onlyOwnerOrOperator

    {

        randomGenerateMethod = newRandomGenerateMethod;

    } 

    

    /*

     * @dev owner selfdestruct contract ***BE CAREFUL! EMERGENCY ONLY / CONTRACT UPGRADE***

     */ 

    function ownerkill() public 

        onlyOwner

    {

        selfdestruct(owner);

    }    





}