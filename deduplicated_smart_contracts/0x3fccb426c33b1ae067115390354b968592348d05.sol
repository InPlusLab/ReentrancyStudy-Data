// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize srl, Thomas Bertani



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
    function query(uint _timestamp, string _datasource, string _arg) returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
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
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;
    
    OraclizeI oraclize;
    modifier oraclizeAPI {
        address oraclizeAddr = OAR.getAddress();
        if (oraclizeAddr == 0){
            oraclize_setNetwork(networkID_auto);
            oraclizeAddr = OAR.getAddress();
        }
        oraclize = OraclizeI(oraclizeAddr);
        _
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        if (getCodeSize(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed)>0){
            OAR = OraclizeAddrResolverI(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed);
            return true;
        }
        if (getCodeSize(0x9efbea6358bed926b293d2ce63a730d6d98d43dd)>0){
            OAR = OraclizeAddrResolverI(0x9efbea6358bed926b293d2ce63a730d6d98d43dd);
            return true;
        }
        if (getCodeSize(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf)>0){
            OAR = OraclizeAddrResolverI(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf);
            return true;
        }
        return false;
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
    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
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
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
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

    function indexOf(string _haystack, string _needle) internal returns (int)
    {
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

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
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
    

}
// </ORACLIZE_API>

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

    /**
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

    /**
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

    /**
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

    /**
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice self) internal returns (slice) {
        return slice(self._len, self._ptr);
    }

    /**
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice&#39;s text.
     */
    function toString(slice self) internal returns (string) {
        var ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /**
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

    /**
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
    function empty(slice self) internal returns (bool) {
        return self._len == 0;
    }

    /**
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

    /**
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
    function equals(slice self, slice other) internal returns (bool) {
        return compare(self, other) == 0;
    }

    /**
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

    /**
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice self) internal returns (slice ret) {
        nextRune(self, ret);
    }

    /**
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

    /**
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
    function keccak(slice self) internal returns (bytes32 ret) {
        assembly {
            ret := sha3(mload(add(self, 32)), mload(self))
        }
    }

    /**
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

    /**
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

    /**
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

    /**
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

    /**
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

    /**
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

    /**
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

    /**
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

    /**
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

    /**
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

    /**
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

    /**
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
    function contains(slice self, slice needle) internal returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    /**
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

    /**
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


contract mortal {
    address owner;

    function mortal() {
        owner = msg.sender;
    }

    function kill() internal{
        suicide(owner);
    }
}

contract Pray4Prey is mortal, usingOraclize {
	using strings for *;
	
    /**the balances in wei being held by each player */
    mapping(address => uint128) winBalances;
    /**list of all players*/
    address[] public players;
    /** the number of players (may be != players.length, since players can leave the game)*/
    uint16 public numPlayers;
    
    /** animals[0] -> list of the owners of the animals of type 0, animals[1] animals type 1 etc (using a mapping instead of a multidimensional array for lower gas consumptions) */
    mapping(uint8 => address[]) animals;
    /** the cost of each animal type */
    uint128[] public costs;
    /** the value of each animal type (cost - fee), so it&#39;s not necessary to compute it each time*/
    uint128[] public values;
    /** internal  array of the probability factors, so it&#39;s not necessary to compute it each time*/
    uint8[] probabilityFactors;
    /** the fee to be paid each time an animal is bought in percent*/
    uint8[] public fees;

    /** the indices of the animals per type per player */
   // mapping(address => mapping(uint8 => uint16[])) animalIndices; 
  // mapping(address => mapping(uint8 => uint16)) numAnimalsXPlayerXType;
    
    /** total number of animals in the game 
    (!=sum of the lengths of the prey animals arrays, since those arrays contain holes) */
    uint16 public numAnimals;
    /** The maximum of animals allowed in the game */
    uint16 public maxAnimals;
    /** number of animals per player */
    mapping(address => uint8) numAnimalsXPlayer;
    /** number of animals per type */
    mapping(uint8 => uint16) numAnimalsXType;

    
    /** the query string getting the random numbers from oraclize**/
    string randomQuery;
    /** the timestamp of the next attack **/
    uint public nextAttackTimestamp;
    /** gas provided for oraclize callback (attack)**/
    uint32 public oraclizeGas;
    /** the id of the next oraclize callback*/
    bytes32 nextAttackId;
    
    
    /** is fired when new animals are purchased (who bought how many animals of which type?) */
    event newPurchase(address player, uint8 animalType, uint8 amount);
    /** is fired when a player leaves the game */
    event newExit(address player, uint256 totalBalance);
    /** is fired when an attack occures*/
    event newAttack();
    
    
    /** expected parameters: the costs per animal type and the game fee in percent 
    *   assumes that the cheapest animal is stored in [0]
    */
    function Pray4Prey(uint128[] animalCosts, uint8[] gameFees) {
        costs = animalCosts;
        fees = gameFees;
        for(uint8 i = 0; i< costs.length; i++){
            values.push(costs[i]-costs[i]/100*fees[i]);
            probabilityFactors.push(uint8(costs[costs.length-i-1]/costs[0]));
        }
        maxAnimals = 3000;
        randomQuery = "https://www.random.org/integers/?num=10&min=0&max=10000&col=1&base=10&format=plain&rnd=new";
        oraclizeGas=550000;
    }
    
     /** The fallback function runs whenever someone sends ether
        Depending of the value of the transaction the sender is either granted a prey or 
        the transaction is discarded and no ether accepted
        In the first case fees have to be paid*/
     function (){
         for(uint8 i = 0; i < costs.length; i++)
            if(msg.value==costs[i])
                addAnimals(i);
                
        if(msg.value==1000000000000000)
            exit();
        else
            throw;
            
     }
     
     /** buy animals of a given type 
     *  as many animals as possible are bought with msg.value, rest is added to the winBalance of the sender
     */
     function addAnimals(uint8 animalType){
        uint8 amount = uint8(msg.value/costs[animalType]);
        if(animalType >= costs.length || msg.value<costs[animalType] || numAnimalsXPlayer[msg.sender]+amount>50 || numAnimals+amount>=maxAnimals) throw;
        //if type exists, enough ether was transferred, the player doesn&#39;t posess to many animals already (else exit is too costly) and there are less than 10000 animals in the game
        if(numAnimalsXPlayer[msg.sender]==0)//new player
            addPlayer();
        for(uint8 j = 0; j<amount; j++){
            addAnimal(animalType);
        }
        numAnimals+=amount;
        numAnimalsXPlayer[msg.sender]+=amount;
        //numAnimalsXPlayerXType[msg.sender][animalType]+=amount;
        winBalances[msg.sender]+=uint128(msg.value*(100-fees[animalType])/100);
        newPurchase(msg.sender, animalType, j);
        
     }
     
     /**
     *  adds a single animal of the given type
     */
     function addAnimal(uint8 animalType) internal{
        if(numAnimalsXType[animalType]<animals[animalType].length)
            animals[animalType][numAnimalsXType[animalType]]=msg.sender;
        else
            animals[animalType].push(msg.sender);
        numAnimalsXType[animalType]++;
     }
     
  
     
     /**
      * adds an address to the list of players
      * before calling you need to check if the address is already in the game
      * */
     function addPlayer() internal{
        if(numPlayers<players.length)
            players[numPlayers]=msg.sender;
        else
            players.push(msg.sender);
        numPlayers++;
     }
     
     /**
      * removes a given address from the player array
      * */
     function deletePlayer(address playerAddress) internal{
         for(uint16 i  = 0; i < numPlayers; i++)
             if(players[i]==playerAddress){
                numPlayers--;
                players[i]=players[numPlayers];
                delete players[numPlayers];
                return;
             }
     }
     
     
     /** leave the game
      * pays out the sender&#39;s winBalance and removes him and his animals from the game
      * */
    function exit(){
    	cleanUp(msg.sender);//delete the animals
        newExit(msg.sender, winBalances[msg.sender]); //fire the event to notify the client
        if(!payout(msg.sender)) throw;
        delete winBalances[msg.sender];
        deletePlayer(msg.sender);
    }
    
    /**
     * Deletes the animals of a given player
     * */
    function cleanUp(address playerAddress) internal{
    	for(uint8 animalType = 0;  animalType< costs.length;  animalType++){//costs.length == num animal types
    	    if(numAnimalsXType[animalType]>0){
                for(uint16 i = 0; i < numAnimalsXType[animalType]; i++){
                    if(animals[animalType][i] == playerAddress){
                       replaceAnimal(animalType,i, true);
                    }
                }
    	    }
        }
        numAnimals-=numAnimalsXPlayer[playerAddress];
        delete numAnimalsXPlayer[playerAddress];
    }
    
    
    /**
     * Replaces the animal at the given index with the last animal in the array
     * */
    function replaceAnimal(uint8 animalType, uint16 index, bool exit) internal{
        if(exit){//delete all animals at the end of the array that belong to the same player
            while(animals[animalType][numAnimalsXType[animalType]-1]==animals[animalType][index]){
                numAnimalsXType[animalType]--;
                delete animals[animalType][numAnimalsXType[animalType]];
                if(numAnimalsXType[animalType]==index)
                    return;
            }
        }
        numAnimalsXType[animalType]--;
		animals[animalType][index]=animals[animalType][numAnimalsXType[animalType]];
		delete animals[animalType][numAnimalsXType[animalType]];//actually there&#39;s no need for the delete, since the index will not be accessed since it&#39;s higher than numAnimalsXType[animalType]
    }
    
    
    
    /**
     * pays out the given player and removes his fishes.
     * amount = winbalance + sum(fishvalues)
     * returns true if payout was successful
     * */
    function payout(address playerAddress) internal returns(bool){
        return playerAddress.send(winBalances[playerAddress]);
    }

    
    /**
     * manually triggers the attack. cannot be called afterwards, except
     * by the owner if and only if the attack wasn&#39;t launched as supposed, signifying
     * an error ocurred during the last invocation of oraclize, or there wasn&#39;t enough ether to pay the gas
     * */
    function triggerAttackManually(uint32 inseconds){
        if(!(msg.sender==owner && nextAttackTimestamp < now+300)) throw;
        triggerAttack(inseconds);
    }
    
    /**
     * sends a query to oraclize in order to get random numbers in &#39;inseconds&#39; seconds
     */
    function triggerAttack(uint32 inseconds) internal{
    	nextAttackTimestamp = now+inseconds;
    	nextAttackId = oraclize_query(nextAttackTimestamp, "URL", randomQuery, oraclizeGas+6000*numPlayers);
    }
    
    /**
     * The actual predator attack.
     * The predator kills up to 10 animals, but in case there are less than 100 animals in the game up to 10% get eaten.
     * */
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()||myid!=nextAttackId) throw; // just to be sure the calling address is the Oraclize authorized one and the callback is the expected one
        
        uint16[] memory ranges = new uint16[](costs.length+1);
        ranges[0] = 0;
        for(uint8 animalType = 0; animalType < costs.length; animalType ++){
            ranges[animalType+1] = ranges[animalType]+uint16(probabilityFactors[animalType]*numAnimalsXType[animalType]); 
        }     
        uint128 pot;
        uint16 random;        
        uint16 howmany = numAnimals<100?(numAnimals<10?1:numAnimals/10):10;//do not kill more than 10%, but at least one
        uint16[] memory randomNumbers = getNumbersFromString(result,"\n", howmany);
        for(uint8 i = 0; i < howmany; i++){
            random = mapToNewRange(randomNumbers[i], ranges[costs.length]);
            for(animalType = 0; animalType < costs.length; animalType ++)
                if (random < ranges[animalType+1]){
                    pot+= killAnimal(animalType, (random-ranges[animalType])/probabilityFactors[animalType]);
                    break;
                }
        }
        numAnimals-=howmany;
        newAttack();
        if(pot>uint128(oraclizeGas*tx.gasprice))
            distribute(uint128(pot-oraclizeGas*tx.gasprice));//distribute the pot minus the oraclize gas costs
        triggerAttack(timeTillNextAttack());
    }
    
    /**
     * the frequency of the shark attacks depends on the number of animals in the game. 
     * many animals -> many shark attacks
     * at least one attack in 24 hours
     * */
    function timeTillNextAttack() constant internal returns(uint32){
        return (86400/(1+numAnimals/100));
    }
    

    /**
     * kills the animal of the given type at the given index. 
     * */
    function killAnimal(uint8 animalType, uint16 index) internal returns(uint128){
        address preyOwner = animals[animalType][index];

        replaceAnimal(animalType,index,false);
        numAnimalsXPlayer[preyOwner]--;
        
        //numAnimalsXPlayerXType[preyOwner][animalType]--;
        //if the player still owns prey, the value of the animalType1 alone goes into the pot
        if(numAnimalsXPlayer[preyOwner]>0){
        	winBalances[preyOwner]-=values[animalType];
            return values[animalType];
        }
        //owner does not have anymore prey, his winBlanace goes into the pot
        else{
            uint128 bounty = winBalances[preyOwner];
            delete winBalances[preyOwner];
            deletePlayer(preyOwner);
            return bounty;
        }

    }
    
    
    /** distributes the given amount among the players depending on the number of fishes they possess*/
    function distribute(uint128 amount) internal{
        uint128 share = amount/numAnimals;
        for(uint16 i = 0; i < numPlayers; i++){
            winBalances[players[i]]+=share*numAnimalsXPlayer[players[i]];
        }
    }
    
    /**
     * allows the owner to collect the accumulated fees
     * sends the given amount to the owner&#39;s address if the amount does not exceed the
     * fees (cannot touch the players&#39; balances) minus 100 finney (ensure that oraclize fees can be paid)
     * */
    function collectFees(uint128 amount){
        if(!(msg.sender==owner)) throw;
        uint collectedFees = getFees();
        if(amount + 100 finney < collectedFees){
            if(!owner.send(amount)) throw;
        }
    }
    
    /**
     * pays out the players and kills the game.
     * */
    function stop(){
        if(!(msg.sender==owner)) throw;
        for(uint16 i = 0; i< numPlayers; i++){
            payout(players[i]);
        }
        kill();
    }
    
    /**
     * adds a new animal type to the game
     * max. number of animal types: 100
     * the cost may not be lower than costs[0]
     * */
    function addAnimalType(uint128 cost, uint8 fee){
        if(!(msg.sender==owner)||cost<costs[0]||costs.length>=100) throw;
        costs.push(cost);
        fees.push(fee);
        values.push(cost/100*fee);
        probabilityFactors.push(uint8(cost/costs[0]));
    }
    
 
   
   /****************** GETTERS *************************/
    
    
    function getWinBalancesOf(address playerAddress) constant returns(uint128){
        return winBalances[playerAddress];
    }
    
    function getAnimals(uint8 animalType) constant returns(address[]){
        return animals[animalType];
    }
    
    function getFees() constant returns(uint){
        uint reserved = 0;
        for(uint16 j = 0; j< numPlayers; j++)
            reserved+=winBalances[players[j]];
        return address(this).balance - reserved;
    }

    function getNumAnimalsXType(uint8 animalType) constant returns(uint16){
        return numAnimalsXType[animalType];
    }
    
    function getNumAnimalsXPlayer(address playerAddress) constant returns(uint16){
        return numAnimalsXPlayer[playerAddress];
    }
    
   /* function getNumAnimalsXPlayerXType(address playerAddress, uint8 animalType) constant returns(uint16){
        return numAnimalsXPlayerXType[playerAddress][animalType];
    }
    */
    /****************** SETTERS *************************/
    
    function setOraclizeGas(uint32 newGas){
        if(!(msg.sender==owner)) throw;
    	oraclizeGas = newGas;
    }
    
    function setMaxAnimals(uint16 number){
        if(!(msg.sender==owner)) throw;
    	maxAnimals = number;
    }
    
    /************* HELPERS ****************/

    /**
     * maps a given number to the new range (old range 10000)
     * */
    function mapToNewRange(uint number, uint range) constant internal returns (uint16 randomNumber) {
        return uint16(number*range / 10000);
    }
    
    /**
     * converts a string of numbers being separated by a given delimiter into an array of numbers (#howmany) 
     */
     function getNumbersFromString(string s, string delimiter, uint16 howmany) constant internal returns(uint16[] numbers){
         strings.slice memory myresult = s.toSlice();
         strings.slice memory delim = delimiter.toSlice();
         numbers = new uint16[](howmany);
         for(uint8 i = 0; i < howmany; i++){
             numbers[i]= uint16(parseInt(myresult.split(delim).toString())); 
         }
         return numbers;
     }
    
}