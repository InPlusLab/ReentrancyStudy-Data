/**

 *Submitted for verification at Etherscan.io on 2019-05-21

*/



pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

// File: contracts/ECDSA.sol



// pragma solidity >=0.4.21 <0.6.0;

pragma solidity ^0.5.0;



/**

 * @title Elliptic curve signature operations

 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d

 * TODO Remove this library once solidity supports passing a signature to ecrecover.

 * See https://github.com/ethereum/solidity/issues/864

 */



library ECDSA {



/**

  * @dev Recover signer address from a message by using their signature

  * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.

  * @param signature bytes signature, the signature is generated using web3.eth.sign()

  */

function recover(bytes32 hash, bytes memory signature)

    internal

    pure

    returns (address)

{

    bytes32 r;

    bytes32 s;

    uint8 v;



    // Check the signature length

    if (signature.length != 65) {

        return (address(0));

    }



    // Divide the signature in r, s and v variables

    // ecrecover takes the signature parameters, and the only way to get them

    // currently is to use assembly.

    // solium-disable-next-line security/no-inline-assembly

    assembly {

        r := mload(add(signature, 0x20))

        s := mload(add(signature, 0x40))

        v := byte(0, mload(add(signature, 0x60)))

    }



    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions

    if (v < 27) {

        v += 27;

    }



    // If the version is correct return the signer address

    if (v != 27 && v != 28) {

        return (address(0));

    } else {

        // solium-disable-next-line arg-overflow

        return ecrecover(hash, v, r, s);

    }

}



    /**

    * toEthSignedMessageHash

    * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"

    * and hash the result

    */

    function toEthSignedMessageHash(bytes32 hash)

      internal

      pure

      returns (bytes32)

    {

        // 32 is the length in bytes of hash,

        // enforced by the type signature above

        return keccak256(

            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)

        );

    }

}



// File: contracts/lib/RLPReader.sol



/*

* @author Hamdi Allam [email protected]

* Please reach out with any questions or concerns

*/

pragma solidity ^0.5.0;



library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;

    uint8 constant STRING_LONG_START  = 0xb8;

    uint8 constant LIST_SHORT_START   = 0xc0;

    uint8 constant LIST_LONG_START    = 0xf8;



    uint8 constant WORD_SIZE = 32;



    struct RLPItem {

        uint len;

        uint memPtr;

    }



    /*

    * @param item RLP encoded bytes

    */

    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {

        uint memPtr;

        assembly {

            memPtr := add(item, 0x20)

        }



        return RLPItem(item.length, memPtr);

    }



    /*

    * @param item RLP encoded bytes

    */

    function rlpLen(RLPItem memory item) internal pure returns (uint) {

        return item.len;

    }



    /*

    * @param item RLP encoded bytes

    */

    function payloadLen(RLPItem memory item) internal pure returns (uint) {

        return item.len - _payloadOffset(item.memPtr);

    }



    /*

    * @param item RLP encoded list in bytes

    */

    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory result) {

        require(isList(item));



        uint items = numItems(item);

        result = new RLPItem[](items);



        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);

        uint dataLen;

        for (uint i = 0; i < items; i++) {

            dataLen = _itemLength(memPtr);

            result[i] = RLPItem(dataLen, memPtr); 

            memPtr = memPtr + dataLen;

        }

    }



    // @return indicator whether encoded payload is a list. negate this function call for isData.

    function isList(RLPItem memory item) internal pure returns (bool) {

        if (item.len == 0) return false;



        uint8 byte0;

        uint memPtr = item.memPtr;

        assembly {

            byte0 := byte(0, mload(memPtr))

        }



        if (byte0 < LIST_SHORT_START)

            return false;

        return true;

    }



    /** RLPItem conversions into data types **/



    // @returns raw rlp encoding in bytes

    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {

        bytes memory result = new bytes(item.len);

        if (result.length == 0) return result;

        

        uint ptr;

        assembly {

            ptr := add(0x20, result)

        }



        copy(item.memPtr, ptr, item.len);

        return result;

    }



    // any non-zero byte is considered true

    function toBoolean(RLPItem memory item) internal pure returns (bool) {

        require(item.len == 1);

        uint result;

        uint memPtr = item.memPtr;

        assembly {

            result := byte(0, mload(memPtr))

        }



        return result == 0 ? false : true;

    }



    function toAddress(RLPItem memory item) internal pure returns (address) {

        // 1 byte for the length prefix

        require(item.len == 21);



        return address(toUint(item));

    }



    function toUint(RLPItem memory item) internal pure returns (uint) {

        require(item.len > 0 && item.len <= 33);



        uint offset = _payloadOffset(item.memPtr);

        uint len = item.len - offset;



        uint result;

        uint memPtr = item.memPtr + offset;

        assembly {

            result := mload(memPtr)



            // shfit to the correct location if neccesary

            if lt(len, 32) {

                result := div(result, exp(256, sub(32, len)))

            }

        }



        return result;

    }



    // enforces 32 byte length

    function toUintStrict(RLPItem memory item) internal pure returns (uint) {

        // one byte prefix

        require(item.len == 33);



        uint result;

        uint memPtr = item.memPtr + 1;

        assembly {

            result := mload(memPtr)

        }



        return result;

    }



    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        require(item.len > 0);



        uint offset = _payloadOffset(item.memPtr);

        uint len = item.len - offset; // data length

        bytes memory result = new bytes(len);



        uint destPtr;

        assembly {

            destPtr := add(0x20, result)

        }



        copy(item.memPtr + offset, destPtr, len);

        return result;

    }



    /*

    * Private Helpers

    */



    // @return number of payload items inside an encoded list.

    function numItems(RLPItem memory item) private pure returns (uint) {

        if (item.len == 0) return 0;



        uint count = 0;

        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);

        uint endPtr = item.memPtr + item.len;

        while (currPtr < endPtr) {

           currPtr = currPtr + _itemLength(currPtr); // skip over an item

           count++;

        }



        return count;

    }



    // @return entire rlp item byte length

    function _itemLength(uint memPtr) private pure returns (uint len) {

        uint byte0;

        assembly {

            byte0 := byte(0, mload(memPtr))

        }



        if (byte0 < STRING_SHORT_START)

            return 1;

        

        else if (byte0 < STRING_LONG_START)

            return byte0 - STRING_SHORT_START + 1;



        else if (byte0 < LIST_SHORT_START) {

            assembly {

                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is

                memPtr := add(memPtr, 1) // skip over the first byte

                

                /* 32 byte word size */

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len

                len := add(dataLen, add(byteLen, 1))

            }

        }



        else if (byte0 < LIST_LONG_START) {

            return byte0 - LIST_SHORT_START + 1;

        } 



        else {

            assembly {

                let byteLen := sub(byte0, 0xf7)

                memPtr := add(memPtr, 1)



                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length

                len := add(dataLen, add(byteLen, 1))

            }

        }

    }



    // @return number of bytes until the data

    function _payloadOffset(uint memPtr) private pure returns (uint) {

        uint byte0;

        assembly {

            byte0 := byte(0, mload(memPtr))

        }



        if (byte0 < STRING_SHORT_START) 

            return 0;

        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))

            return 1;

        else if (byte0 < LIST_SHORT_START)  // being explicit

            return byte0 - (STRING_LONG_START - 1) + 1;

        else

            return byte0 - (LIST_LONG_START - 1) + 1;

    }



    /*

    * @param src Pointer to source

    * @param dest Pointer to destination

    * @param len Amount of memory to copy from the source

    */

    function copy(uint src, uint dest, uint len) private pure {

        if (len == 0) return;



        // copy as many word sizes as possible

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {

            assembly {

                mstore(dest, mload(src))

            }



            src += WORD_SIZE;

            dest += WORD_SIZE;

        }



        // left over bytes. Mask is used to remove unwanted bytes from the word

        uint mask = 256 ** (WORD_SIZE - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask)) // zero out src

            let destpart := and(mload(dest), mask) // retrieve the bytes

            mstore(dest, or(destpart, srcpart))

        }

    }

}



// File: contracts/lib/MsDecoder.sol



// pragma experimental ABIEncoderV2;



/*

* Used to proxy function calls to the RLPReader for testing

*/





library MsDecoder {

    using RLPReader for bytes;

    using RLPReader for uint;

    using RLPReader for RLPReader.RLPItem;



    struct Message {

        address from;

        address to;

        bytes32 sessionID;

        uint mType;

        bytes content;

        bytes signature;

        // balance proof

        bytes32 channelID;

        uint256 balance;

        uint256 nonce;

        // hash of data related to transfer

        uint256 amount;

        bytes32 additionalHash;

        bytes paymentSignature;

    }



    function decode(bytes memory data) internal view returns (Message[] memory) {

        RLPReader.RLPItem[] memory messages = data.toRlpItem().toList();

        Message[] memory ms = new Message[](messages.length);

        RLPReader.RLPItem[] memory items;

        for(uint i=0; i<messages.length; i++) {

            items = messages[i].toList();

            ms[i] = Message(items[0].toAddress(), items[1].toAddress(), toBytes32(items[2].toBytes()), items[3].toUint(), items[4].toBytes(), items[5].toBytes(), toBytes32(items[6].toBytes()), items[7].toUint(), items[8].toUint(), items[9].toUint(), toBytes32(items[10].toBytes()), items[11].toBytes());

        }

        return ms;

    }



    function toBytes32(bytes memory source) internal pure returns (bytes32 result) {

        if (source.length == 0) {

            return 0x0;

        }

        assembly {

            result := mload(add(source, 32))

        }

    }

}



// File: contracts/PacketVerify.sol



// pragma experimental ABIEncoderV2;











contract PacketVerify {

    using RLPReader for bytes;

    using RLPReader for uint;

    using RLPReader for RLPReader.RLPItem;



    uint256 constant rate = 98;



    struct State {

        bytes32 prh;

        address token;

        uint256 amount;

        address provider;

        bytes32 pr;

        address loser;

    }

    struct URHash {

        bytes32 urh;

        address user;

        bytes32 urr;

        uint256 m;

    }

    struct PSettle{

        address user;

        uint amount;

    }



    function verify (

        bytes memory data

    )

        public

        view

        returns(string memory verifyResult, string memory gameInformation, address loser, address[5] memory users, bytes32[5] memory userSecretHashs, bytes32[5] memory userSecrets, uint[5] memory userModules, uint[5] memory userSettleAmounts) //0=success, 1xxx=invalid data, 2xxx=wrong result

    {

        MsDecoder.Message[] memory ms = MsDecoder.decode(data);

        State memory s;

        URHash[] memory urHash = new URHash[](5);

        PSettle[] memory pSettle = new PSettle[](5);

        uint idx = 0;

        // provider start game message

        if (ms[0].mType == 1) {

            RLPReader.RLPItem[] memory items = ms[0].content.toRlpItem().toList();

            s.prh = toBytes32(items[0].toBytes());

            s.token = items[1].toAddress();

            s.amount = items[2].toUint();

            s.provider = ms[0].from;

            gameInformation = string(abi.encodePacked("provider: ", addressToString(s.provider), ", token: ", addressToString(s.token), ", wager: ", uintToString(s.amount), ", provider secret hash: ", bytes32ToString(s.prh)));

            // token = s.token;

        } else {

            verifyResult = "error(-1001): provider should send game information message first\n";

            return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

        }

        // provider cancel game

        for(uint i=1; i<ms.length; i++){

            if(ms[i].mType == 6 && ms[i].from == s.provider){

                if(verifyCancel(s, ms, i)){

                    verifyResult = "game canceled, refund success\n";

                    return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

                } else {

                    verifyResult = "game canceled, refund failed\n";

                    return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);    

                }

            }

        }

        // provider send hash ready message

        for(uint i=1; i<ms.length; i++){ 

            if(ms[i].mType == 3 && ms[i].from == s.provider){

                RLPReader.RLPItem[] memory items = ms[i].content.toRlpItem().toList();

                for(uint k=0; k<5; k++) {

                    urHash[k].user = items[k].toAddress();

                    users[k] = items[k].toAddress();

                }

                idx = 0;

                for(uint j=1; j<i&&idx<5; j++){

                    if(ms[j].mType == 2 && ms[j].to == s.provider && ms[j].from == urHash[idx].user && ms[j].amount == s.amount){

                        urHash[idx].urh = toBytes32(ms[j].content.toRlpItem().toList()[0].toBytes());

                        userSecretHashs[idx] = urHash[idx].urh;

                        idx++;

                    }

                }

                if(idx < 5){

                    verifyResult = "error(-1002): users provider picked was wrong\n";

                    return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

                }

                break;

            }

        }

        if(urHash[0].user == address(0)) {

            verifyResult = "error(-1003): provider did not pick users\n";

            return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

        }

        // provider settle game

        idx = 0;

        for(uint i=1; i<ms.length&&idx<5; i++){

            if(ms[i].mType == 5 && ms[i].from == s.provider){

                if(idx == 0) {

                    s.pr = toBytes32(ms[i].content.toRlpItem().toList()[0].toBytes());

                    gameInformation = string(abi.encodePacked(gameInformation, ", provider secret: ", bytes32ToString(s.pr)));

                    if (keccak256(abi.encodePacked(s.pr)) != s.prh) {

                        verifyResult = "error(-1004): provider random was not matched with hash of random\n";

                        return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

                    }

                } else if(toBytes32(ms[i].content.toRlpItem().toList()[0].toBytes()) != s.pr) {

                    verifyResult = "error(-1004): provider random was not matched with hash of random\n";

                    return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

                }

                pSettle[idx].user = ms[i].to;

                pSettle[idx].amount = ms[i].amount;

                userSettleAmounts[idx] = ms[i].amount;

                idx++;

            }

        }

        if(!verifyProviderSettle(urHash, pSettle)) {

            verifyResult = "error(-1005): provider settle order was not matched with order of users\n";

            return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

        }

        // provider send random message

        for(uint i=1; i<ms.length; i++){

            if(ms[i].mType == 4 && ms[i].from == s.provider){

                RLPReader.RLPItem[] memory items = ms[i].content.toRlpItem().toList();

                for(uint j=0; j<5; j++){

                    if(keccak256(abi.encodePacked(toBytes32(items[j].toBytes()))) != urHash[j].urh) {

                        verifyResult = "error(-1006): user random was not matched with hash of random\n";

                        return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

                    }

                    urHash[j].urr = toBytes32(items[j].toBytes());

                    userSecrets[j] = urHash[j].urr;

                }

            }

        }

        uint256 m = uint256(urHash[0].urr^urHash[1].urr^urHash[2].urr^urHash[3].urr^urHash[4].urr^s.pr)%100 + 100;

        gameInformation = string(abi.encodePacked(gameInformation, ", module: ", uintToString(m)));

        uint256 minRand = 0;

        for (uint i=0; i<5; i++) {

            // uint i = 4 - j;

            // urHash[i].m = uint256(urHash[i].urr)%m;

            urHash[i].m = selectNumber(uint256(urHash[i].urr)%(m-i) + 1, userModules, m);

            userModules[i] = urHash[i].m;

            if(i == 0) {

                s.loser = urHash[i].user;

                minRand = urHash[i].m;

            } else if(urHash[i].m < minRand) {

                minRand = urHash[i].m;

                s.loser = urHash[i].user;

            }

        }

        loser = s.loser;

        // verify if settlement was correct

        for (uint i=0; i<5; i++) {

            if(pSettle[i].user == s.loser) {

                if(pSettle[i].amount != (s.amount*rate/100)*urHash[i].m/(urHash[0].m+urHash[1].m+urHash[2].m+urHash[3].m+urHash[4].m)) {

                    verifyResult = "error(-1007): wrong settle amount\n";

                    return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

                }

            } else {

                if(pSettle[i].amount != ((s.amount*rate/100)*urHash[i].m/(urHash[0].m+urHash[1].m+urHash[2].m+urHash[3].m+urHash[4].m)) + s.amount) {

                    verifyResult = "error(-1007): wrong settle amount\n";

                    return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

                }

            }

        }

        verifyResult = "Success!\n";

        return (verifyResult, gameInformation, loser, users, userSecretHashs, userSecrets, userModules, userSettleAmounts);

    }



    function selectNumber(

        uint rand,

        uint[5] memory userModules,

        uint module

    )

        internal

        view

        returns(uint)

    {

        uint temp = rand;

        for(uint i = 1; i < module + 1; i++){



            bool included = false;

            for(uint j = 0; j < 5; j ++){

                if(userModules[j] == i){

                    included = true;

                    break;

                }

            }

            if(!included) {

                temp --;

            }

            if(temp <= 0){

                return i;

            }

        }

        return module;

    }



    function verifyCancel (

        State memory s,

        MsDecoder.Message[] memory ms,

        uint cIdx

    )

        internal

        view

        returns(bool)

    {

        address[] memory users = new address[](cIdx);

        uint userLength = 0;

        for(uint i=0; i<cIdx; i++) {

            if(ms[i].mType == 2 && ms[i].to == s.provider  && ms[i].amount == s.amount){

                users[userLength] = ms[i].from;

                userLength++;

            }

        }

        uint idx = 0;

        for(uint j=cIdx; j<ms.length&&idx<userLength; j++) {

            if(ms[j].mType == 7 && ms[j].to == users[idx] && ms[j].amount == s.amount){

                idx++;

            }

        }

        if(idx < userLength) {

            return false;

        } else {

            return true;

        }

    }



    function verifyProviderSettle (

        URHash[] memory urHash,

        PSettle[] memory pSettle 

    )

        internal

        pure

        returns(bool)

    {

        for(uint i=0; i<5; i++) {

            uint j = 0;

            while(urHash[i].user != pSettle[j].user && j<5) j++;

            if(j==5) return false;

        }

        return true;

    }



    function toBytes32(

        bytes memory source

    ) 

        internal 

        pure 

        returns (bytes32 result) 

    {

        if (source.length == 0) {

            return 0x0;

        }

        assembly {

            result := mload(add(source, 32))

        }

    }





    function addressToString(address _addr) internal pure returns(string memory) {

        bytes32 value = bytes32(uint256(_addr));

        bytes memory alphabet = "0123456789abcdef";

    

        bytes memory str = new bytes(42);

        str[0] = '0';

        str[1] = 'x';

        for (uint i = 0; i < 20; i++) {

            str[2+i*2] = alphabet[uint(uint8(value[i + 12]) >> 4)];

            str[3+i*2] = alphabet[uint(uint8(value[i + 12]) & 0x0f)];

        }

        return string(str);

    }

    

    function bytes32ToString(bytes32 value) internal view returns (string memory) {

        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(66);

        str[0] = '0';

        str[1] = 'x';

        for (uint i = 0; i < 32; i++) {

            str[2+i*2] = alphabet[uint(uint8(value[i]) >> 4)];

            str[3+i*2] = alphabet[uint(uint8(value[i]) & 0x0f)];

        }

        return string(str);

    }

    

    function uintToString(uint _i) internal pure returns (string memory _uintAsString) {

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

}