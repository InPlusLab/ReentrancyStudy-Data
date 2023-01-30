/**

 *Submitted for verification at Etherscan.io on 2019-06-14

*/



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



pragma solidity ^0.5.0;



/**

 * @dev Contract module which provides a basic access control mechanism, where

 * there is an account (an owner) that can be granted exclusive access to

 * specific functions.

 *

 * This module is used through inheritance. It will make available the modifier

 * `onlyOwner`, which can be aplied to your functions to restrict their use to

 * the owner.

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");

        _;

    }



    /**

     * @dev Returns true if the caller is the current owner.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Leaves the contract without owner. It will not be possible to call

     * `onlyOwner` functions anymore. Can only be called by the current owner.

     *

     * > Note: Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



// File: contracts/Strings.sol



pragma solidity ^0.5.2;



library Strings {

  // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol

  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {

    bytes memory _ba = bytes(_a);

    bytes memory _bb = bytes(_b);

    bytes memory _bc = bytes(_c);

    bytes memory _bd = bytes(_d);

    bytes memory _be = bytes(_e);

    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

    bytes memory babcde = bytes(abcde);

    uint k = 0;

    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

    for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

    for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

    for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

    for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];

    return string(babcde);

  }



  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {

    return strConcat(_a, _b, _c, _d, "");

  }



  function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {

    return strConcat(_a, _b, _c, "", "");

  }



  function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {

    return strConcat(_a, _b, "", "", "");

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



  function fromAddress(address addr) internal pure returns(string memory) {

    bytes20 addrBytes = bytes20(addr);

    bytes16 hexAlphabet = "0123456789abcdef";

    bytes memory result = new bytes(42);

    result[0] = '0';

    result[1] = 'x';

    for (uint i = 0; i < 20; i++) {

      result[i * 2 + 2] = hexAlphabet[uint8(addrBytes[i] >> 4)];

      result[i * 2 + 3] = hexAlphabet[uint8(addrBytes[i] & 0x0f)];

    }

    return string(result);

  }

}



// File: contracts/OpenSeaENSResolver.sol



pragma solidity ^0.5.2;







/**

 * @title OpenSea ENS Resolver

 * OpenSea ENS Resolver - A resolver for linking ENS domains to OpenSea listings.

 */

contract OpenSeaENSResolver is Ownable {

  string private _baseURI = "https://opensea.io/assets/0xfac7bea255a6990f749363002136af6556b31e04/";



  function baseURI() public view returns (string memory) {

    return _baseURI;

  }



  function setBaseURI(string memory uri) public onlyOwner {

    _baseURI = uri;

  }



  function openSeaVersion() public pure returns (string memory) {

    return "1.0.0";

  }



  function text(bytes32 node, string memory key) public view returns (string memory) {

    if (keccak256(bytes(key)) == keccak256(bytes("url"))) {

      return Strings.strConcat(_baseURI, Strings.uint2str(uint256(node)));

    }

    return "";

  }

}