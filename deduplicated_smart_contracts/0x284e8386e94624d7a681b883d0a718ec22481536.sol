/**
 *Submitted for verification at Etherscan.io on 2020-07-03
*/

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
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

// Util functions imported in OnChainSDK for caller to use.
library utils {
    uint constant UINT256MAX = ~uint(0);

    // A decimal byte to uint. Return value of 10 indicating invalid input.
    function byte2Uint(byte b) internal pure returns(uint8) {
        if (b >= '0' && b <= '9') {
            return uint8(b) - 48;  // '0'
        }
        // Indicating invalid input.
        return 10;
    }
    // Return value of 16 indicating invalid input.
    function hexByte2Uint(byte b) internal pure returns(uint8) {
        if (b >= '0' && b <= '9') {
            return uint8(b) - 48;  // '0'
        } else if (b >= 'A' && b <= 'F') {
            return uint8(b) - 55;
        } else if (b >= 'a' && b <= 'f') {
            return uint8(b) - 87;
        }
        // Indicating invalid input.
        return 16;
    }

    /// StringToXXX helpers.

    // A decimal string (charset c in [0-9]) to uint. Like atoi(),
    // 1. processing stops once encountering character not in charset c.
    // 2. returns UINT256MAX when overflow.
    function str2Uint(string memory a) internal pure returns(uint) {
        bytes memory b = bytes(a);
        uint res = 0;
        for (uint i = 0; i < b.length; i++) {
            uint8 tmp = byte2Uint(b[i]);
            if (tmp >= 10) {
                return res;
            } else {
                // Overflow.
                if (res >= UINT256MAX / 10) {
                    return UINT256MAX;
                }
                res = res * 10 + tmp;
            }
        }
        return res;
    }

    // Hex string (charset c in [0-9A-Za-z]) to uint. Like atoi(),
    // 1. processing stops once encountering character not in charset c.
    // 2. returns UINT256MAX when overflow.
    function hexStr2Uint(string memory a) internal pure returns(uint) {
        bytes memory b = bytes(a);
        uint res = 0;
        uint i = 0;
        if (b.length >= 2 && b[0] == '0' && (b[1] == 'x' || b[1] == 'X')) {
            i += 2;
        }
        for (; i < b.length; i++) {
            uint tmp = hexByte2Uint(b[i]);
            if (tmp >= 16) {
                return res;
            } else {
                // Overflow.
                if (res >= UINT256MAX / 16) {
                    return UINT256MAX;
                }
                res = res * 16 + tmp;
            }
        }
        return res;
    }

    // Input: 20-byte hex string without or with 0x/0X prefix (40 characters or 42 characters)
    // Example: '0x0e7ad63d2a305a7b9f46541c386aafbd2af6b263' => address(0x0e7ad63d2a305a7b9f46541c386aafbd2af6b263)
    // address is of uint160.
    function str2Addr(string memory a) internal pure returns(address) {
        bytes memory b = bytes(a);
        require(b.length == 40 || b.length == 42, "Invalid input, should be 20-byte hex string");
        uint i = 0;
        if (b.length == 42) {
            i += 2;
        }

        uint160 res = 0;
        for (; i < b.length; i += 2) {
            res *= 256;

            uint160 b1 = uint160(hexByte2Uint(b[i]));
            uint160 b2 = uint160(hexByte2Uint(b[i+1]));
            require(b1 < 16 && b2 < 16, "address string with invalid character");

            res += b1 * 16 + b2;
        }
        return address(res);
    }

    /// XXXToString() helpers.

    // Example: 12 -> 'c' (without 0x/0X prefix).
    function uint2HexStr(uint x) internal pure returns(string memory) {
        if (x == 0) return '0';

        uint j = x;
        uint len;
        while (j != 0) {
            len++;
            j /= 16;
        }

        bytes memory b = new bytes(len);
        uint k = len - 1;
        while (x != 0) {
            uint8 curr = uint8(x & 0xf);
            b[k--] = curr > 9 ? byte(55 + curr) : byte(48 + curr);
            x /= 16;
        }
        return string(b);
    }

    // Example: 12 -> "12"
    function uint2Str(uint x) internal pure returns(string memory) {
        if (x == 0) return '0';

        uint j = x;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory b = new bytes(len);
        uint k = len - 1;
        while (x != 0) {
            b[k--] = byte(uint8(48 + x % 10));
            x /= 10;
        }
        return string(b);
    }

    // Example: address(0x0e7ad63d2a305a7b9f46541c386aafbd2af6b263) => '0x0e7ad63d2a305a7b9f46541c386aafbd2af6b263'
    function addr2Str(address _addr) internal pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory charset = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = charset[uint8(value[i + 12] >> 4)];
            str[3+i*2] = charset[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    /// bytes/string helpers.

    function bytesConcat(bytes memory a, bytes memory b) internal pure returns(bytes memory) {
        bytes memory concated = new bytes(a.length + b.length);
        uint i = 0;
        uint k = 0;
        while (i < a.length) { concated[k++] = a[i++]; }
        i = 0;
        while(i < b.length) { concated[k++] = b[i++]; }
        return concated;
    }

    function strConcat(string memory a, string memory b) internal pure returns(string memory) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        return string(bytesConcat(aa, bb));
    }

    function bytesCompare(bytes memory a, bytes memory b) internal pure returns(int) {
        uint len = a.length < b.length ? a.length : b.length;
        for (uint i = 0; i < len; i++) {
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

    // "abd" > "abcde"
    function strCompare(string memory a, string memory b) internal pure returns(int) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        return bytesCompare(aa, bb);
    }

    function bytesEqual(bytes memory a, bytes memory b) internal pure returns(bool) {
        return (a.length == b.length) && (bytesCompare(a, b) == 0);
    }

    function strEqual(string memory a, string memory b) internal pure returns(bool) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        return bytesEqual(aa, bb);
    }

    // Return the index of needle's first occurrance in haystack. Return value
    // of -1 indicating no occurrance.
    // Useful in case of parsing float string "123.45".
    // Example:
    //   indexOf('123', '') => 0
    //   indexOf('', '45') => -1
    //   indexOf('123', '1234') => -1
    //   indexOf('123.45', '.') => 3
    function indexOf(string memory haystack, string memory needle) internal pure returns(int) {
        bytes memory b_haystack = bytes(haystack);
        bytes memory b_needle = bytes(needle);
        return indexOf(b_haystack, b_needle);
    }

    function indexOf(bytes memory haystack, bytes memory needle) internal pure returns(int) {
        if (needle.length == 0) {
            return 0;
        } else if (haystack.length < needle.length) {
            return -1;
        }
        // Instead of O(haystack.length x needle.length), saving gas using KMP:
        // O(haystack.length + needle.length)
        uint[] memory pi = new uint[](needle.length + 1);
        pi[1] = 0;
        uint k = 0;
        uint q = 0;
        // KMP pre-processing
        for(q = 2; q <= needle.length; q++) {
            while(k > 0 && needle[k] != needle[q-1]) {
                k = pi[k];
            }
            if(needle[k] == needle[q-1]) {
                k++;
            }
            pi[q] = k;
        }
        // KMP matching
        q = 0;
        for(uint i = 0; i < haystack.length; i++) {
            while(q > 0 && needle[q] != haystack[i]) {
                q = pi[q];
            }
            if(needle[q] == haystack[i]) {
                q++;
            }
            // Match
            if(q == needle.length) {
                return int(i - q + 1);
            }
        }
        // No match
        return -1;
    }

    // subStr("1234567890", 2, 5) => "34567"
    // [start, start + len), index starting from 0.
    function subStr(bytes memory a, uint start, uint len) internal pure returns(bytes memory) {
        require(start < a.length && start + len > start && start + len <= a.length,
                "Invalid start index or length out of range");
        bytes memory res = new bytes(len);
        for (uint i = 0; i < len; i++) {
            res[i] = a[start + i];
        }
        return res;
    }

    // string num = "123.4567";
    // subStr(num, indexOf(num, '.') + 1) => "4567"
    function subStr(bytes memory a, uint start) internal pure returns(bytes memory) {
        require(start < a.length, "Invalid start index out of range");
        return subStr(a, start, a.length - start);
    }

    function subStr(string memory a, uint start, uint len) internal pure returns(string memory) {
        bytes memory aa = bytes(a);
        return string(subStr(aa, start, len));
    }

    function subStr(string memory a, uint start) internal pure returns(string memory) {
        bytes memory aa = bytes(a);
        return string(subStr(aa, start));
    }
}

contract DOSProxyInterface {
    function query(address, uint, string memory, string memory) public returns (uint);
    function requestRandom(address, uint) public returns (uint);
}

contract DOSPaymentInterface {
    function setPaymentMethod(address payer, address tokenAddr) public;
    function defaultTokenAddr() public returns(address);
}

contract DOSAddressBridgeInterface {
    function getProxyAddress() public view returns (address);
    function getPaymentAddress() public view returns (address);
}

contract ERC20I {
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
}

contract DOSOnChainSDK is Ownable {
    // Comment out utils library if you don't need it to save gas. (L4 and L30)
    // using utils for *;

    DOSProxyInterface dosProxy;
    DOSAddressBridgeInterface dosAddrBridge =
        DOSAddressBridgeInterface(0x98A0E7026778840Aacd28B9c03137D32e06F5ff1);

    modifier resolveAddress {
        dosProxy = DOSProxyInterface(dosAddrBridge.getProxyAddress());
        _;
    }

    modifier auth {
        // Filter out malicious __callback__ caller.
        require(msg.sender == dosAddrBridge.getProxyAddress(), "Unauthenticated response");
        _;
    }

    // @dev: call setup function first and transfer DOS tokens into deployed contract as oracle fees.
    function DOSSetup() public onlyOwner {
        address paymentAddr = dosAddrBridge.getPaymentAddress();
        address defaultToken = DOSPaymentInterface(dosAddrBridge.getPaymentAddress()).defaultTokenAddr();
        ERC20I(defaultToken).approve(paymentAddr, uint(-1));
        DOSPaymentInterface(dosAddrBridge.getPaymentAddress()).setPaymentMethod(address(this), defaultToken);
    }

    // @dev: refund all unused fees to caller.
    function DOSRefund() public onlyOwner {
        address token = DOSPaymentInterface(dosAddrBridge.getPaymentAddress()).defaultTokenAddr();
        uint amount = ERC20I(token).balanceOf(address(this));
        ERC20I(token).transfer(msg.sender, amount);
    }

    // @dev: Call this function to get a unique queryId to differentiate
    //       parallel requests. A return value of 0x0 stands for error and a
    //       related event would be emitted.
    // @timeout: Estimated timeout in seconds specified by caller; e.g. 15.
    //           Response is not guaranteed if processing time exceeds this.
    // @dataSource: Data source destination specified by caller.
    //              E.g.: 'https://api.coinbase.com/v2/prices/ETH-USD/spot'
    // @selector: A selector expression provided by caller to filter out
    //            specific data fields out of the raw response. The response
    //            data format (json, xml/html, and more) is identified from
    //            the selector expression.
    //            E.g. Use "$.data.amount" to extract "194.22" out.
    //             {
    //                  "data":{
    //                          "base":"ETH",
    //                          "currency":"USD",
    //                          "amount":"194.22"
    //                  }
    //             }
    //            Check below documentation for details.
    //            (https://dosnetwork.github.io/docs/#/contents/blockchains/ethereum?id=selector).
    function DOSQuery(uint timeout, string memory dataSource, string memory selector)
        internal
        resolveAddress
        returns (uint)
    {
        return dosProxy.query(address(this), timeout, dataSource, selector);
    }

    // @dev: Must override __callback__ to process a corresponding response. A
    //       user-defined event could be added to notify the Dapp frontend that
    //       the response is ready.
    // @queryId: A unique queryId returned by DOSQuery() for callers to
    //           differentiate parallel responses.
    // @result: Response for the specified queryId.
    function __callback__(uint queryId, bytes calldata result) external {
        // To be overridden in the caller contract.
    }

    // @dev: Call this function to request either a fast but insecure random
    //       number or a safe and secure random number delivered back
    //       asynchronously through the __callback__ function.
    //       Depending on the mode, the return value would be a random number
    //       (for fast mode) or a requestId (for safe mode).
    // @seed: Optional random seed provided by caller.
    function DOSRandom(uint seed)
        internal
        resolveAddress
        returns (uint)
    {
        return dosProxy.requestRandom(address(this), seed);
    }

    // @dev: Must override __callback__ to process a corresponding random
    //       number. A user-defined event could be added to notify the Dapp
    //       frontend that a new secure random number is generated.
    // @requestId: A unique requestId returned by DOSRandom() for requester to
    //             differentiate random numbers generated concurrently.
    // @generatedRandom: Generated secure random number for the specific
    //                   requestId.
    function __callback__(uint requestId, uint generatedRandom) external auth {
        // To be overridden in the caller contract.
    }
}


// An example get latest ETH-USD price from Coinbase
contract CoinbaseEthPriceFeed is DOSOnChainSDK {
    using utils for *;

    // Struct to hold parsed floating string "123.45"
    struct ethusd {
        uint integral;
        uint fractional;
    }
    uint queryId;
    string public price_str;
    ethusd public price;

    event GetPrice(uint integral, uint fractional);

    constructor() public {
        // @dev: setup and then transfer DOS tokens into deployed contract
        // as oracle fees.
        // Unused fees can be reclaimed by calling DOSRefund() in the SDK.
        super.DOSSetup();
    }

    function getEthUsdPrice() public {
        queryId = DOSQuery(30, "https://api.coinbase.com/v2/prices/ETH-USD/spot", "$.data.amount");
    }

    function __callback__(uint id, bytes calldata result) external auth {
        require(queryId == id, "Unmatched response");

        price_str = string(result);
        price.integral = price_str.subStr(1).str2Uint();
        int delimit_idx = price_str.indexOf('.');
        if (delimit_idx != -1) {
            price.fractional = price_str.subStr(uint(delimit_idx + 1)).str2Uint();
        }
        emit GetPrice(price.integral, price.fractional);
    }
}