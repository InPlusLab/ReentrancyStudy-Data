/**
 *Submitted for verification at Etherscan.io on 2019-11-13
*/

pragma solidity ^0.5.10;

// Helps manage OpenSea trading
contract OwnableDelegateProxy { }
contract ProxyRegistry { mapping(address => OwnableDelegateProxy) public proxies;}

// Helps interact with the Nexium contract without including it in this file.
interface NxcInterface { function transfer(address _to, uint256 _value) external returns(bool);
	function transferFrom(address _from, address _to, uint256 _value) external returns(bool);
	function totalSupply() external view returns(uint256);}
 
// Checks overflow and more 
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * [EIP](https://eips.ethereum.org/EIPS/eip-165).
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others (`ERC165Checker`).
 *
 * For an implementation, see `ERC165`.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract tokenSpender { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public;
    }

/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

/**
 * @dev Implementation of the `IERC165` interface.
 *
 * Contracts may inherit from this and call `_registerInterface` to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See `IERC165.supportsInterface`.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See `IERC165.supportsInterface`.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

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

    function uint2str(uint i) internal pure returns (string memory) {
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
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }
}

contract IProxyContractForMetaTxs {
// Interface taken from the implementation by Austin Griffith
// https://github.com/austintgriffith/bouncer-proxy/blob/master/BouncerProxy/BouncerProxy.sol

  function updateWhitelist(address _account, bool _value) public returns(bool);
  
  event UpdateWhitelist(address _account, bool _value);
  // copied from https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
  
  function () external payable;
  
  event Received (address indexed sender, uint value);

  function getHash(address signer, address destination, uint value, bytes memory data, address rewardToken, uint rewardAmount) public view returns(bytes32);
  
  // original forward function copied from https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
  function forward(bytes memory sig, address signer, address destination, uint value, bytes memory data, address rewardToken, uint rewardAmount) public;
  
  // when some frontends see that a tx is made from a bouncerproxy, they may want to parse through these events to find out who the signer was etc
  event Forwarded (bytes sig, address signer, address destination, uint value, bytes data,address rewardToken, uint rewardAmount,bytes32 _hash);

  // copied from https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
  // which was copied from GnosisSafe
  // https://github.com/gnosis/gnosis-safe-contracts/blob/master/contracts/GnosisSafe.sol
  function executeCall(address to, uint256 value, bytes memory data) internal returns (bool success);

  //borrowed from OpenZeppelin's ESDA stuff:
  //https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/cryptography/ECDSA.sol
  function signerIsWhitelisted(bytes32 _hash, bytes memory _signature) internal view returns (bool);
}

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

/**
 * This is a generic factory contract that can be used to mint tokens. The configuration
 * for minting is specified by an _optionId, which can be used to delineate various 
 * ways of minting.
 */
interface Factory {
  /**
   * Returns the name of this factory.
   */
  function name() external view returns (string memory);

  /**
   * Returns the symbol for this factory.
   */
  function symbol() external view returns (string memory);

  /**
   * Number of options the factory supports.
   */
  function numOptions() external view returns (uint256);

  /**
   * @dev Returns whether the option ID can be minted. Can return false if the developer wishes to
   * restrict a total supply per option ID (or overall).
   */
  function canMint(uint256 _optionId) external view returns (bool);

  /**
   * @dev Returns a URL specifying some metadata about the option. This metadata can be of the
   * same structure as the ERC721 metadata.
   */
  function tokenURI(uint256 _optionId) external view returns (string memory);

  /**
   * Indicates that this is a factory contract. Ideally would use EIP 165 supportsInterface()
   */
  function supportsFactoryInterface() external view returns (bool);

  /**
    * @dev Mints asset(s) in accordance to a specific address with a particular "option". This should be 
    * callable only by the contract owner or the owner's Wyvern Proxy (later universal login will solve this).
    * Options should also be delineated 0 - (numOptions() - 1) for convenient indexing.
    * @param _optionId the option id
    * @param _toAddress address of the future owner of the asset(s)
    */
  function mint(uint256 _optionId, address _toAddress) external;
}

contract IProxyContractForBurn {
    function setnxcAddress(address new_address) public;
    function burnNxCtoMintAssets(uint256 nbOfAsset, string[] memory keys, string[] memory values) public view returns (uint256);
}

library Helpers {
  function parseBytesToStringArr(bytes memory b, uint256 globalOffset) internal pure returns (string[] memory)
  {
	uint256 nbOfStrings = sliceUint(b, globalOffset);
	string[] memory stringArr = new string[](nbOfStrings);
	
	uint256[] memory offsetArr = new uint256[](nbOfStrings);
	uint256[] memory stringLengths = new uint256[](nbOfStrings);
	
	for (uint256 i = 0; i < nbOfStrings; i++)
	{
		offsetArr[i] = sliceUint(b, globalOffset + 32 + 32 * i);
	}
	
	for (uint256 i = 0; i < nbOfStrings; i++)
	{
		stringLengths[i] = sliceUint(b, globalOffset + 32 + offsetArr[i]);
		require(stringLengths[i] <= 32); // No string more than a bytes32

		stringArr[i] = bytes32ToString(bytesToBytes32(b, globalOffset + 64 + offsetArr[i]),stringLengths[i]);
	}
	
	return stringArr;
  }  
  
	function bytesToBytes32(bytes memory b, uint offset) internal pure returns (bytes32) {
	  bytes32 out;

	  for (uint i = 0; i < 32; i++) {
		out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
	  }
	  return out;
	}
	
    function uintToBytes32(uint v) internal pure returns (bytes32 ret) {
    if (v == 0) {
        ret = '0';
    }
    else {
        while (v > 0) {
            ret = bytes32(uint(ret) / (2 ** 8));
            ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
            v /= 10;
        }
    }
    return ret;
    }
    
    function bytes32ToString(bytes32 data) internal pure returns (string memory) {
		bytes memory bytesString = new bytes(32);
		for (uint j=0; j<32; j++) {
			byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
			if (char != 0) {
				bytesString[j] = char;
			}
		}
		return string(bytesString);
	}
	
    function bytes32ToString(bytes32 data, uint _length) internal pure returns (string memory) {
		bytes memory bytesString = new bytes(_length);
		for (uint j=0; j<_length; j++) {
			byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
			if (char != 0) {
				bytesString[j] = char;
			}
		}
		return string(bytesString);
	}
	
	function bytesToUint(bytes memory b)  internal pure returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint256(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }
        return number;
    }

    function sliceUint(bytes memory bs, uint start) internal pure returns (uint) {
    require(bs.length >= start + 32, "slicing out of range");
    uint x;
    assembly {
        x := mload(add(bs, add(0x20, start)))
    }
    return x;
	}
    
    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    string memory ab = new string(_ba.length + _bb.length);
    bytes memory babc = bytes(ab);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babc[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) babc[k++] = _bb[i];
    return string(babc); }
	
	function uint256ArrayConcat(uint256[] memory _a, uint256[] memory _b) internal pure returns (uint256[] memory)
	{
		uint256[] memory _c = new uint256[](_a.length + _b.length);
		
		for (uint256 i=0; i < _a.length; i++) {
            _c[i] = _a[i];
        }
		for (uint256 i=0; i < _b.length; i++) {
            _c[_a.length+i] = _b[i];
        }
		
		return _c;
	}
}

/* Contract used for alloing shared ownership of a contract
* Can be configured to have 1 or many approvals needed for a tx to execute.
* (i.e. works like any multisig wallet)
*/
contract MultiSigOwnable {

    uint256 private nbApprovalsNeeded;
    address[] private ownerList;
    
    bytes4[] private functionSignatureHashList;
    bytes32 private Current_functionCallHash;
    bytes private Current_functionCall;
    bytes4 private Current_functionSig;
    
    address[] private Current_Approvals;

    event MultiSigOwnerTransactionCleared(bytes4 FuncSelector);
    
    modifier onlyMultiSigOwners() {
      require(msg.sender == address(this));
    
      bytes4 funcSelector;
      bytes memory msg_data = msg.data;
      assembly {
              funcSelector := mload(add(msg_data, 32))
          }
          
      if(!isRegistered(funcSelector))
      {
        registerMultiOwnableFunction(funcSelector);
      }
      
      _;
    }
    
    constructor (uint256 _nbApprovalsNeeded, address[] memory _ownerList) internal {
      require(_ownerList.length >= 1);
      require(_nbApprovalsNeeded >=1);
      
      for (uint256 i = 0; i < _ownerList.length; i++)
      {
          if(!isInOwnerList(_ownerList[i]))
          {
              ownerList.push(_ownerList[i]);
          }
      }
      
      nbApprovalsNeeded = _nbApprovalsNeeded;
      }
    
    function isInOwnerList(address _sender) view public returns (bool)	{
      
      for (uint256 i = 0; i < ownerList.length; i++)
      {
        if (_sender == ownerList[i])
          return true;
      }
      return false;	
    }
    
    function addOwnerToList(address _addOwner) public onlyMultiSigOwners() {
      ownerList.push(_addOwner);
    }
    
    function updateApprovalsNeeded(uint256 _nbApprovalsNeeded) public onlyMultiSigOwners() {
      nbApprovalsNeeded = _nbApprovalsNeeded;
    }
    
    function isInApprovalList(address _sender) view internal returns (bool) {
      
      for (uint256 i = 0; i < Current_Approvals.length; i++)
      {
        if (_sender == Current_Approvals[i])
          return true;
      }
      return false;	
    }
    
    function registerMultiOwnableFunction(bytes4 _functionSignatureHash) public
    {
      functionSignatureHashList.push(_functionSignatureHash);
    }
    
    function removeOwner(address _ownerToRemove) public onlyMultiSigOwners() {
        require(isInOwnerList(_ownerToRemove), "Remove owner - Not in owner list");
      
        bool _ownerToRemoveFound = false;
      
        for (uint256 i = 0; i < ownerList.length - 1; i++)
      {
        if (ownerList[i] == _ownerToRemove)
        {
          _ownerToRemoveFound = true;
        }
        if (_ownerToRemoveFound)
        {
          ownerList[i] = ownerList[i+1];
        }
      }
      ownerList.length--;
    }
    
    function initialCall(bytes memory functionCall) public returns (bytes32) {
      require(isInOwnerList(msg.sender), "Initial call - Not in owner list");
      
      Current_functionCallHash = keccak256(functionCall);
      Current_functionCall = functionCall;
      
      delete Current_Approvals;

      Current_Approvals.push(msg.sender);
      
      bytes4 funcSelector;

      assembly {
        funcSelector := mload(add(functionCall, 32))
      }
          
      Current_functionSig = funcSelector;
        
      
      if(nbApprovalsNeeded == 1)
      {
        address(this).call(functionCall);
        
        if (!isRegistered(funcSelector))
        {
          revert("initialCall - Called a function without the onlyMultiSigOwners modifier");
        }
        
        emit MultiSigOwnerTransactionCleared(funcSelector);
      }
      
      return Current_functionCallHash;
    }
    
    function isRegistered(bytes4 _functionSignatureHash) public view returns (bool) {

      for (uint256 i = 0; i < functionSignatureHashList.length; i++)
      {
        if (functionSignatureHashList[i] == _functionSignatureHash)
        {
          return true;
        }
      }
      return false;
    }
    
    function approve_tx(bytes32 _callDataHash) public {
      require(isInOwnerList(msg.sender), "Approve - Not in owner list");
        require(!isInApprovalList(msg.sender));
    
      if (_callDataHash == Current_functionCallHash)
      {
        Current_Approvals.push(msg.sender);
      }
      
      if (Current_Approvals.length >= nbApprovalsNeeded)
      {
        address(this).call(Current_functionCall);
        
        if (!isRegistered(Current_functionSig))
        {
          revert("approve - Called a function without the onlyMultiSigOwners modifier");
        }
        
        emit MultiSigOwnerTransactionCleared(Current_functionSig);
      }
    }
}

interface IProxyForKYCWhitelist {
	function isWhitelisted(address _addr) external view returns (bool);
}

contract ProxyForKYCWhitelistEveryoneIsWhitelisted is IProxyForKYCWhitelist {
	
	// By default, allow everyone to buy LTR assets
	function isWhitelisted(address _addr) public view returns (bool)
	{
		return true;
	}
}

contract ProxyForKYCWhitelistOnlySpecifiedPeopleAreWhitelisted is IProxyForKYCWhitelist, MultiSigOwnable {
  mapping(address => bool) whitelisted;

  constructor (uint256 nbApprovalsNeeded, address[] memory _ownerList) MultiSigOwnable(nbApprovalsNeeded, _ownerList) public
  {
    for (uint256 i = 0; i < _ownerList.length; i++)
    {
      whitelisted[_ownerList[i]] = true;
    }
  }

	function setWhitelistedStatus(address _addr, bool whitelisted_status) public onlyMultiSigOwners() {
    whitelisted[_addr] = whitelisted_status;
  }
  
	function setNWhitelistedStatus(address[] memory _addresses, bool whitelisted_status) public onlyMultiSigOwners() {
    for (uint256 i = 0; i < _addresses.length; i++)
    {
      whitelisted[_addresses[i]] = whitelisted_status;
    }
  }

	function isWhitelisted(address _addr) public view returns (bool)
	{
		return whitelisted[_addr];
	}
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * 
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either `approve` or `setApproveForAll`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either `approve` or `setApproveForAll`.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * This function is deprecated.
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

contract NFT_Factory is Factory, Ownable, MultiSigOwnable {
  using Strings for string;

  address payable nftAddress;
  address public listingAddress;
  
  address public proxyRegistryAddress;
  address public proxyContractForBurnAddress;
  address public proxyContractForMetatxsAddress;
  mapping(uint256 => uint256) public nbAssetMaxPerOptionID;
  mapping(uint256 => uint256) public nbAssetPerOptionID;
  mapping(uint256 => address) public minterForOptionID;
  mapping(uint256 => address) public addressForUGCForOptionID;
  mapping(uint256 => uint256) public tokenIDsToNonUniqueTokenID;

  address public nexiumAddress;
  string public baseURI;
  uint256 NUM_OPTIONS;
  
  struct KeyValue {
	uint256 _index;
	string _key;
	string _value;}
  
  mapping (uint256 => KeyValue[]) public KeyValueArrayOptionID;
  mapping (uint256 => mapping(string => KeyValue)) public KeyValueMappingOptionID;
  mapping (uint256 => KeyValue[]) public KeyValueArrayOptionIDOnCreation;
  mapping (uint256 => mapping(string => KeyValue)) public KeyValueMappingOptionIDOnCreation;
  mapping (uint256 => KeyValue[]) public KeyValueArrayTokenID;
  mapping (uint256 => mapping(string => KeyValue)) public KeyValueMappingTokenID;
  
  mapping(uint256 => address) whitelistContractAddresses;
  address public defaultWhitelistContractAddresses;
  mapping(uint256 => uint256[]) public bundlesDefinition;
  mapping(uint256 => bool) public isBundle;
	
  event NewAssetCreated(address minter, uint256 optionID, uint256 nbAssetMintedMax);
  event NewAssetMinted(address minter, address _to, uint256 optionID, uint256 tokenID);
  
  constructor(address _proxyRegistryAddress, address payable _nftAddress, address _listingAddress, string memory _baseURI, address _proxyContractForBurnAddress, address _proxyContractForMetatxsAddress, address _nexiumAddress, address _defaultWhitelistContractAddresses, uint256 _nbApprovalNeeded, address[] memory _ownerList) 
	Ownable() MultiSigOwnable(_nbApprovalNeeded, _ownerList) public {
	proxyContractForBurnAddress =  _proxyContractForBurnAddress;
    proxyContractForMetatxsAddress = _proxyContractForMetatxsAddress;
	proxyRegistryAddress = _proxyRegistryAddress;
    nftAddress = _nftAddress;
	baseURI = _baseURI;    
	listingAddress = _listingAddress;
	nexiumAddress = _nexiumAddress;
	NUM_OPTIONS = 0;
	defaultWhitelistContractAddresses = _defaultWhitelistContractAddresses;
  }
  
  function setProxyContractForBurnAddress (address _new_address) public onlyMultiSigOwners() {
      proxyContractForBurnAddress = _new_address;
  }
  
  function setdefaultWhitelistContractAddresses (address _new_address) public onlyMultiSigOwners() {
      defaultWhitelistContractAddresses = _new_address;
  }
  
  function setProxyContractForMetatxsAddress (address _new_address) public onlyMultiSigOwners() {
      proxyContractForMetatxsAddress = _new_address;
  }
  
  function setnftAddress (address payable _new_address) public onlyMultiSigOwners() {
      nftAddress = _new_address;
  }
  
   function setnxcAddress(address _new_address) public onlyMultiSigOwners() {
		nexiumAddress = _new_address;
  }
	
  function setlistingAddress (address _new_address) public onlyMultiSigOwners() {
      listingAddress = _new_address;
  }
    
  function setbaseURI (string memory _new_baseURI) public onlyMultiSigOwners() {
      baseURI = _new_baseURI;
  }
 
  function name() external view returns (string memory) {
    return "B2E NFT Sale";
  }

  function symbol() external view returns (string memory) {
    return "B2ENFTS";
  }

  function supportsFactoryInterface() public view returns (bool) {
    return true;
  }

  function numOptions() public view returns (uint256) {
    return NUM_OPTIONS;
  }

  function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public  {
	   require(_token == nexiumAddress);
	   require(_extraData.length >= 4); // We need at least the functionSelector;
	   
	    bytes4 funcSelector = 0x0;
	    
        if (_extraData.length == 0) {
            funcSelector = 0x0;
        }

        assembly {
            funcSelector := mload(add(_extraData, 32))
        }
        
        if (funcSelector == bytes4(keccak256("createNewOptionID(uint256,address)")))
        {
			revert("Please put empty keys and values args");
			/*uint256 nbOfAsset = Helpers.sliceUint(_extraData, 4);
			address _minter = address(Helpers.sliceUint(_extraData, 36));

			createNewOptionID(nbOfAsset, _minter);
			
			NxcInterface nexiumContract = NxcInterface(address(nexiumAddress));

			require(_value >= CallProxyForNxCBurn(nbOfAsset), "Not enough NXC!");*/
        }
		else if (funcSelector == bytes4(keccak256("createNewOptionID(uint256,address,string[],string[])")))
		{

			// Check extraData length
			
			uint256 nbOfAsset = Helpers.sliceUint(_extraData, 4);
			address _minter = address(Helpers.sliceUint(_extraData, 36));
			
			uint256 keysOffset = Helpers.sliceUint(_extraData, 68) + 4; // we have to account for the bytes4 selector
			uint256 valuesOffset = Helpers.sliceUint(_extraData, 100) + 4;
			
			uint256 nbOfKeys = Helpers.sliceUint(_extraData, keysOffset);
			uint256 nbOfValues = Helpers.sliceUint(_extraData, valuesOffset);
			
			require(nbOfValues == nbOfKeys);
			
			string[] memory keys = Helpers.parseBytesToStringArr(_extraData, keysOffset);
			string[] memory values = Helpers.parseBytesToStringArr(_extraData, valuesOffset);
			
			createNewOptionID(nbOfAsset, _minter, keys, values);
			
			require(_value >= CallProxyForNxCBurn(nbOfAsset, keys, values), "Not enough NXC!");
        }
        else
        {
            revert("Unknown function called through receiveApproval");
        }
		
		NxcInterface nexiumContract = NxcInterface(address(nexiumAddress));
		if(!nexiumContract.transferFrom(_from, address(this), _value))
		{
			revert("notEnoughNxCSent");
		}
			
	    return;
  }

  // Retrieves the formula for the number of NxC to burn to create a new asset type:

    function CallProxyForNxCBurn(uint256 nbOfAsset, string[] memory keys, string[] memory values) public view returns (uint256) {
		
      ProxyContractForBurn _proxyContractForBurn = ProxyContractForBurn(proxyContractForBurnAddress);
      
      uint256 nbNxCToBurn = _proxyContractForBurn.burnNxCtoMintAssets(nbOfAsset, keys, values);
	    
      return nbNxCToBurn;
  }
 

    // As we need to burn NxC, you can't call this function directly
  function createNewOptionID(uint256 nbAssetMaxToMint, address _minter, string[] memory keys, string[] memory values) internal {
  
      uint256 _optionID = NUM_OPTIONS;
      require(nbAssetMaxPerOptionID[_optionID] == 0);
      
	  nbAssetPerOptionID[_optionID] = 0;
      nbAssetMaxPerOptionID[_optionID] = nbAssetMaxToMint;
	  minterForOptionID[_optionID] = _minter;

		require(keys.length == values.length);
		
		for (uint256 i = 0; i < keys.length; i++)
		{
			string memory _key = keys[i];
			string memory _value = values[i];
		
		
		    KeyValue memory keyValueForThisKey = KeyValueMappingOptionIDOnCreation[_optionID][_key];

			uint256 index;
			KeyValue memory newKeyValue;
			
			// Check if the key already set or not
			if (bytes(keyValueForThisKey._key).length == 0)
			{
			  index = KeyValueArrayOptionIDOnCreation[_optionID].length;
			  newKeyValue = KeyValue(index, _key, _value);
			  KeyValueArrayOptionIDOnCreation[_optionID].push(newKeyValue);
			}	
			else
			{
			  index = keyValueForThisKey._index;
			  newKeyValue = KeyValue(index, _key, _value);
			  KeyValueArrayOptionIDOnCreation[_optionID][index] = newKeyValue;
			}
			
			KeyValueMappingOptionIDOnCreation[_optionID][_key] = newKeyValue;
		}
    
      
	  emit NewAssetCreated(_minter, _optionID, nbAssetMaxToMint);
	  
	  whitelistContractAddresses[_optionID] = defaultWhitelistContractAddresses;
	  
      NUM_OPTIONS = NUM_OPTIONS + 1;
  }
  
  function setWhitelistContractAddressForOptionID(uint256 _optionID, address _new_address) public {
	require(msg.sender == minterForOptionID[_optionID]);
	
	whitelistContractAddresses[_optionID] = _new_address;
  }
  
  
   function transferMintership(uint256 _optionID, address _new_minter) public {
	require(msg.sender == minterForOptionID[_optionID]);
	minterForOptionID[_optionID] = _new_minter;
  }
  
   function ownerOf(uint256 _optionID) public view returns (address) {
	return minterForOptionID[_optionID];
	//return owner();
  }
  
  function mintWithTokenURI(uint256 _optionId, address _toAddress, uint256 _category, string calldata _tokenURI) external returns (uint256)
  {
	uint256 tokenID = this.mintCat(_optionId, _toAddress, _category);
	
    NFT_Token itemContract = NFT_Token(nftAddress);

	itemContract.setTokenURI(tokenID, _tokenURI);
  }
  
	// Lets the asset creator to store onchain some properties for the asset
  function setOptionIdPropriety(uint256 _optionID, string memory _key, string memory _value) public
  {
    require(msg.sender == minterForOptionID[_optionID]);
    require(bytes(_key).length > 0);
    
    KeyValue memory keyValueForThisKey = KeyValueMappingOptionID[_optionID][_key];

    uint256 index;
    KeyValue memory newKeyValue;
    
    // Check if the key already set or not
    if (bytes(keyValueForThisKey._key).length == 0)
    {
      index = KeyValueArrayOptionID[_optionID].length;
      newKeyValue = KeyValue(index, _key, _value);
      KeyValueArrayOptionID[_optionID].push(newKeyValue);
    }	
    else
    {
      index = keyValueForThisKey._index;
      newKeyValue = KeyValue(index, _key, _value);
      KeyValueArrayOptionID[_optionID][index] = newKeyValue;
    }
    
    KeyValueMappingOptionID[_optionID][_key] = newKeyValue;
  }

  function deleteOptionIdPropriety(uint256 _optionID, string memory _key) public
  {
    require(msg.sender == minterForOptionID[_optionID]);

    KeyValue memory keyValueForThisKey = KeyValueMappingOptionID[_optionID][_key];

    uint256 index = keyValueForThisKey._index;
    uint256 length = KeyValueArrayOptionID[_optionID].length;
    
    KeyValueArrayOptionID[_optionID][index] = KeyValueArrayOptionID[_optionID][length-1];
    delete KeyValueArrayOptionID[_optionID][length-1];
    delete KeyValueMappingOptionID[_optionID][_key];
  }

  function setTokenIdPropriety(uint256 _TokenID, string memory _key, string memory _value) public
  {	
    NFT_Token itemContract = NFT_Token(nftAddress);
    
    uint256 _optionId = itemContract.itemTypes(_TokenID);
    require(msg.sender == minterForOptionID[_optionId]);
    
    require(bytes(_key).length > 0);
      
    KeyValue memory keyValueForThisKey = KeyValueMappingTokenID[_TokenID][_key];

    uint256 index;
    KeyValue memory newKeyValue;
    
    // Check if the key already set or not
    
    if (bytes(keyValueForThisKey._key).length == 0)
    {
      index = KeyValueArrayTokenID[_TokenID].length;
      newKeyValue = KeyValue(index, _key, _value);
      KeyValueArrayTokenID[_TokenID].push(newKeyValue);
    }	
    else
    {
      index = keyValueForThisKey._index;
      newKeyValue = KeyValue(index, _key, _value);
      KeyValueArrayTokenID[_TokenID][index] = newKeyValue;
    }
    
    KeyValueMappingTokenID[_TokenID][_key] = newKeyValue;
  }

  function deleteTokenIdPropriety(uint256 _TokenID, string memory _key) public
  {
    NFT_Token itemContract = NFT_Token(nftAddress);
    
    uint256 _optionId = itemContract.itemTypes(_TokenID);
    require(msg.sender == minterForOptionID[_optionId]);

    KeyValue memory keyValueForThisKey = KeyValueMappingTokenID[_TokenID][_key];

    uint256 index = keyValueForThisKey._index;
    uint256 length = KeyValueArrayTokenID[_TokenID].length;
    
    KeyValueArrayTokenID[_TokenID][index] = KeyValueArrayTokenID[_TokenID][length-1];
    delete KeyValueArrayTokenID[_TokenID][length-1];
    delete KeyValueMappingTokenID[_TokenID][_key];
  }

  function setTokenURI(uint256 tokenID, string memory _tokenURI) public
    {
      NFT_Token itemContract = NFT_Token(nftAddress);
      
      uint256 optionID = itemContract.itemTypes(tokenID);
      
    require(msg.sender == minterForOptionID[optionID]);
    
    itemContract.setTokenURI(tokenID, _tokenURI);
    }

    function setUGCAddress(uint256 _optionId, address _new_address) public {
      require(msg.sender == minterForOptionID[_optionId]);
      
      addressForUGCForOptionID[_optionId] = _new_address;
    }
 
  function tokenURI(uint256 _optionId) external view returns (string memory) {
      return Helpers.strConcat(
                              baseURI,
                              Helpers.strConcat(Helpers.bytes32ToString(Helpers.uintToBytes32(_optionId)), "/")
              );
    }
  /**
   * Hack to get things to work automatically on OpenSea.
   * Use transferFrom so the frontend doesn't have to worry about different method names.
   */
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    mint(_tokenId, _to);
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    if (owner() == _owner && _owner == _operator) {
      return true;
    }

    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (owner() == _owner && address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return false;
  }
  
    function mint(uint256 _optionId, address _toAddress) public {
		  
		ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
		require(address(proxyRegistry.proxies(minterForOptionID[_optionId])) == msg.sender || minterForOptionID[_optionId] == msg.sender);
		  
		this.mintCat(_optionId, _toAddress, 0);
    }
    
    function MintN(uint256 _optionId, uint256 N, address _to, uint256 _cat) external returns (uint256[] memory) {
      require(msg.sender == minterForOptionID[_optionId], "msg.sender isn't minter for the asset");
      
      uint256[] memory currentTokenIds = new uint256[](N);
      for (uint256 i = 0; i < N; i++)
      {
        uint256 new_tokenID = this.mintCat(_optionId, _to, _cat);
        currentTokenIds[i] = new_tokenID;
      }
      return currentTokenIds;
    }
	
	
	function DefineBundle(uint256 optionID, uint256[] memory optionIDList) public 
	{
		require(minterForOptionID[optionID] == msg.sender);
		for (uint256 i = 0; i < optionIDList.length; i++)
		{
			require(minterForOptionID[optionIDList[i]] == msg.sender);
		}
		bundlesDefinition[optionID] = optionIDList;
		isBundle[optionID] = true;
	}
	
    function mintCat(uint256 _optionId, address _toAddress, uint256 _category) external returns (uint256) {
		require(this.canMint(_optionId), "Not available for minting");
		require(msg.sender == minterForOptionID[_optionId] || msg.sender == address(this), "msg.sender isn't minter for the asset (mint(3)");

		// Check if whitelisted
		IProxyForKYCWhitelist _ProxyForKYCWhitelistContract = IProxyForKYCWhitelist(whitelistContractAddresses[_optionId]);
		require(_ProxyForKYCWhitelistContract.isWhitelisted(_toAddress));

		nbAssetPerOptionID[_optionId] = nbAssetPerOptionID[_optionId] + 1;
		uint256 _tokenID = 0;
		
		/*if (_optionId >= 51 && _optionId <= 56) // Bundles
		{
			if (_optionId == 51) // Urumi bundle
			{
				uint256[] memory UrumiOptionIds = new uint256[](13);
				UrumiOptionIds[0] = 1;
				UrumiOptionIds[1] = 3;
				UrumiOptionIds[2] = 7;
				UrumiOptionIds[3] = 11;
				UrumiOptionIds[4] = 15;
				UrumiOptionIds[5] = 19;
				UrumiOptionIds[6] = 23;
				UrumiOptionIds[7] = 27;
				UrumiOptionIds[8] = 31;
				UrumiOptionIds[9] = 35;
				UrumiOptionIds[10] = 39;
				UrumiOptionIds[11] = 43;
				UrumiOptionIds[12] = 47;
				
				for (uint256 i = 0; i < UrumiOptionIds.length; i++)
				{
					this.mintCat(UrumiOptionIds[i], _toAddress,0);
				}
				
			}
			else if (_optionId == 52) // Merlin bundle
			{
				uint256[] memory MerlinOptionIds = new uint256[](13);
				MerlinOptionIds[0] = 1;
				MerlinOptionIds[2] = 4;
				MerlinOptionIds[3] = 8;
				MerlinOptionIds[4] = 12;
				MerlinOptionIds[5] = 16;
				MerlinOptionIds[6] = 20;
				MerlinOptionIds[7] = 24;
				MerlinOptionIds[8] = 28;
				MerlinOptionIds[9] = 32;
				MerlinOptionIds[10] = 36;
				MerlinOptionIds[11] = 40;
				MerlinOptionIds[12] = 44;
				MerlinOptionIds[12] = 48;
				
				for (uint256 i = 0; i < MerlinOptionIds.length; i++)
				{
					this.mintCat(MerlinOptionIds[i], _toAddress,0);
				}
			}
			else if (_optionId == 53) // Goliath bundle
			{
				uint256[] memory GoliathOptionIds = new uint256[](13);
				GoliathOptionIds[0] = 1;
				GoliathOptionIds[1] = 5;
				GoliathOptionIds[2] = 9;
				GoliathOptionIds[3] = 13;
				GoliathOptionIds[4] = 17;
				GoliathOptionIds[5] = 21;
				GoliathOptionIds[6] = 25;
				GoliathOptionIds[7] = 29;
				GoliathOptionIds[8] = 33;
				GoliathOptionIds[9] = 37;
				GoliathOptionIds[10] = 41;
				GoliathOptionIds[11] = 45;
				GoliathOptionIds[12] = 49;
				
				for (uint256 i = 0; i < GoliathOptionIds.length; i++)
				{
					this.mintCat(GoliathOptionIds[i], _toAddress,0);
				}
			}
			else if (_optionId == 54) // Firebird bundle
			{
				uint256[] memory FirebirdOptionIds = new uint256[](13);
				FirebirdOptionIds[0] = 1;
				FirebirdOptionIds[1] = 6;
				FirebirdOptionIds[2] = 10;
				FirebirdOptionIds[3] = 14;
				FirebirdOptionIds[4] = 18;
				FirebirdOptionIds[5] = 22;
				FirebirdOptionIds[6] = 26;
				FirebirdOptionIds[7] = 30;
				FirebirdOptionIds[8] = 34;
				FirebirdOptionIds[9] = 38;
				FirebirdOptionIds[10] = 42;
				FirebirdOptionIds[11] = 46;
				FirebirdOptionIds[12] = 50;
				
				for (uint256 i = 0; i < FirebirdOptionIds.length; i++)
				{
					this.mintCat(FirebirdOptionIds[i], _toAddress,0);
				}
			}
			else if (_optionId == 55) // All skins bundle
			{
				this.mintCat(1, _toAddress,0);
				for (uint256 i = 3; i < 51; i++)
				{
					this.mintCat(i, _toAddress,0);
				}
			}
		}*/
		if(isBundle[_optionId])
		{
			for (uint i = 0; i < bundlesDefinition[_optionId].length; i++)
			{
				this.mintCat(bundlesDefinition[_optionId][i], _toAddress,0);
			}
		}
		else	// Regular mint
		{
			NFT_Token itemContract = NFT_Token(nftAddress);
			bytes4 _functionSignatureHash = bytes4(keccak256("mintTo(address,uint256,uint256)"));
			bytes memory _extraData = abi.encodeWithSelector(_functionSignatureHash,_toAddress, _optionId, _category);
			/*bytes32 CallDataHash = */itemContract.initialCall(_extraData);
			_tokenID = itemContract.totalSupply();
			tokenIDsToNonUniqueTokenID[_tokenID] = nbAssetPerOptionID[_optionId];
			
			emit NewAssetMinted(msg.sender, _toAddress, _optionId, _tokenID);		
		}
		
		return _tokenID;
    }

    function canMint(uint256 _optionId) external view returns (bool) {
        
      bool isOptionAvailable = (_optionId <= NUM_OPTIONS);
      bool enoughNxCBurned = (nbAssetMaxPerOptionID[_optionId] > nbAssetPerOptionID[_optionId]);

      return (isOptionAvailable && enoughNxCBurned);
    }
}

contract ProxyContractForMetaTxs is IProxyContractForMetaTxs {}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safetransfer`. This function MAY throw to revert and reject the
   * transfer. Return of other than the magic value MUST result in the
   * transaction being reverted.
   * Note: the contract address is always the message sender.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _tokenId The NFT identifier which is being transferred
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes memory _data
  )
    public
    returns(bytes4);
}

contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /*
     *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
     *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
     *
     *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
     */
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    /**
     * @dev Constructor function.
     */
    constructor () public {
        // register the supported interface to conform to ERC721Enumerable via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner.
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract.
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens.
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to address the beneficiary that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner.
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }
	
	function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].length--;

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}

contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }
}

/**
 * @title TradeableERC721Token
 * TradeableERC721Token - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract TradeableERC721Token is ERC721Full, Ownable, MultiSigOwnable {
  using Strings for string;

  // Mapping from token ID to item type.
  mapping (uint256 => uint256) public itemTypes;
  mapping (uint256 => uint256) public itemCategory;

	address proxyRegistryAddress;
  
  constructor(string memory _name, string memory _symbol, address _proxyRegistryAddress) ERC721Full(_name, _symbol) public 
  { 
	proxyRegistryAddress = _proxyRegistryAddress;  
  }

  /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
  */
	
  function mintTo(address _to, uint256 _itemType, uint256 _itemCategory) onlyMultiSigOwners() public {
  
    uint256 newTokenId = _getNextTokenId();
    _mint(_to, newTokenId);
    itemTypes[newTokenId] = _itemType;
    
    itemCategory[newTokenId] = _itemCategory;
    
  }

  /**
    * @dev calculates the next token ID based on totalSupply
    * @return uint256 for the next token ID
    */
  function _getNextTokenId() private view returns (uint256) {
    return totalSupply().add(1);
  }

  function baseTokenURI() public pure returns (string memory) {
    return "";
  }

  function tokenURI(uint256 _tokenId) public view returns (string memory) {
    return Strings.strConcat(
        baseTokenURI(),
        Strings.uint2str(itemTypes[_tokenId]),
        "/",
        Strings.uint2str(_tokenId)
    );
  }
  
  /**
   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
   */
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
    // Whitelist OpenSea proxy contract for easy trading.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(owner)) == operator) {
        return true;
    }

    return super.isApprovedForAll(owner, operator);
  }
}

/* Should be Ownable for OpenSea StoreFront customizations*/
contract NFT_Token is TradeableERC721Token/*, Ownable *//*, NexiumReceiver*/ {

	event Grouping(address groupOwner, uint256 tokenID);
	event Ungrouping(address groupOwner, uint256 tokenID);

  // BEGIN ATTRIBUTE

  address private NexiumAddress;
  address private FactoryAddress;

	mapping(address => uint256) groupOwners;
	mapping(uint256 => uint256) public NexiumPerTokenId;
	mapping(uint256 => uint256) public EtherPerTokenId;

    string private _name;
    string private _symbol;
    uint256 private _total_supply;
    string private _uri_prefix;
    string private _route;

    // The last asset id
    uint256 private _last_id;
	
	mapping(uint256 => string) tokenURIs;

    // Locked status
    mapping(uint256 => bool) private _locked;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    /**
     * @dev Constructor function
     */
    constructor (address _proxyRegistryAddress, string memory name, string memory symbol, string memory uri_prefix, address _NexiumAddress, address _FactoryAddress, uint256 _nbApprovalNeeded, address[] memory _ownerList) 
    TradeableERC721Token("LTR Item", "LTRI", _proxyRegistryAddress)
    Ownable() MultiSigOwnable(_nbApprovalNeeded, _ownerList) public {
        NexiumAddress = _NexiumAddress;
        FactoryAddress = _FactoryAddress;
        _name = name;
        _symbol = symbol;
        _uri_prefix = uri_prefix;
		_route = "";
        _total_supply = 0;
        _last_id = 0;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

  // END ATTRIBUTE

  function setnexiumAddress (address _new_address) public onlyMultiSigOwners() {
      NexiumAddress = _new_address;
  }
  
  function setfactoryAddress (address _new_address) public onlyMultiSigOwners() {
      FactoryAddress = _new_address;
  }

  // BEGIN RECEIVE ETH AND NXC

	function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public {

	    require(_token == NexiumAddress);
	    require(_extraData.length == 32);

	    uint256 tokenId = Helpers.bytesToUint(_extraData);

	    NxcInterface nexiumContract = NxcInterface(NexiumAddress);

	    if(nexiumContract.transferFrom(_from, address(this), _value) == false)
	    {
	        revert();
	    }
	    
	    NexiumPerTokenId[tokenId] = NexiumPerTokenId[tokenId].add(_value);

	    return;
	}

	function recoverNexium(uint256 _valueToRecover, uint256 tokenId) public {

		require(msg.sender == ownerOf(tokenId), "You need to own the asset");
		require(NexiumPerTokenId[tokenId] >= _valueToRecover);

	    NxcInterface nexiumContract = NxcInterface(NexiumAddress);

	    NexiumPerTokenId[tokenId] = NexiumPerTokenId[tokenId].sub(_valueToRecover);
	    
	    if(nexiumContract.transfer(msg.sender, _valueToRecover) == false)
	    {
	        revert();
	    }
	}

	function receiveETH (uint256 tokenId) public payable returns (bool) {
	    EtherPerTokenId[tokenId] = EtherPerTokenId[tokenId].add(msg.value);

	    return true;
	}

	function recoverETH(uint256 tokenId, uint256 _valueToRecover) public returns (bool) {

		require(msg.sender == ownerOf(tokenId), "You need to own the asset");
		require(EtherPerTokenId[tokenId] >= _valueToRecover);

	    EtherPerTokenId[tokenId] = EtherPerTokenId[tokenId].sub(_valueToRecover);
	    if(msg.sender.send(_valueToRecover) == true)
	    {
	        return true;
	    }
	    else
	    {
	        revert();
	    }
	}

  // END RECEIVE ETH AND NXC

  // BEGIN GROUP HANDLING
	mapping(uint256 => uint256[]) groupMapping;

	function groupAssets(uint256[] memory tokenIds) public returns (uint256) {

	    uint256 tokenId = totalSupply().add(1);
        _mint(msg.sender, tokenId);

	    for (uint256 i = 0; i < tokenIds.length; i++) {
	          transferFrom(msg.sender, address(this), tokenIds[i]);
	    }

	    groupMapping[tokenId] = tokenIds;

		emit Grouping(msg.sender, tokenId);

	    return tokenId;
	}

	function ungroupAssets(uint256 tokenId) public returns (uint256[] memory) {
        
        require(ownerOf(tokenId) == msg.sender);
        require(groupMapping[tokenId].length > 0);
        
        uint256[] memory retValue = new uint256[](groupMapping[tokenId].length);
        
        for (uint256 i = 0; i < groupMapping[tokenId].length; i++) {
	          this.transferFrom(address(this), msg.sender, groupMapping[tokenId][i]);
	          retValue[i] = groupMapping[tokenId][i];
	    } 
	    
	    groupMapping[tokenId].length = 0;
        
        //burn the group
        _burn(msg.sender, tokenId);

		emit Ungrouping(msg.sender, tokenId);
	
        return retValue;
	}

	function getGroupContent(uint256 tokenId) public view returns (uint256[] memory)
	{
		uint256[] memory currentArray;
			
		if (!isGroup(tokenId))
		{
			currentArray = new uint256[](1);
			currentArray[0] = tokenId;
		}
		else
		{

			for (uint256 i = 0; i < groupMapping[tokenId].length; i++)
			{
				currentArray = Helpers.uint256ArrayConcat(currentArray, getGroupContent(groupMapping[tokenId][i]));
			}
		}
		return currentArray;
	}
	
	function getGroupContentFirstLevel(uint256 tokenId) public view returns (uint256[] memory)
	{
		uint256[] memory currentArray;
			
		if (!isGroup(tokenId))
		{
			currentArray = new uint256[](1);
			currentArray[0] = tokenId;
		}
		else
		{
			currentArray = groupMapping[tokenId];
			
		}
		return currentArray;
	}
	
	function isGroup(uint256 tokenId) internal view returns (bool) {
	    return (groupMapping[tokenId].length == 0);
	}

  // END GROUP HANDLING

  // BEGIN BASIC ERC721 HANDLING

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

  // END BASIC ERC721 HANDLING

  // BEGIN COMPLEX ERC721 HANDLING

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));
		
		bytes memory TokenURIAsBytes = bytes(tokenURIs[tokenId]); 
 
		if (TokenURIAsBytes.length == 0)
		{
		    return 	Helpers.strConcat(
						Helpers.strConcat(
                            Helpers.strConcat(
								_uri_prefix, 
								_route),
                            Helpers.strConcat(
								Helpers.bytes32ToString(Helpers.uintToBytes32(itemTypes[tokenId])), 
								"/")),
						Helpers.strConcat(
							Helpers.bytes32ToString(Helpers.uintToBytes32(tokenId)), 
							"/"));
		}
		else
		{
			return tokenURIs[tokenId];
		}
    }
	
    function setURI_Prefix(string memory _new_uri_prefix) public onlyMultiSigOwners() returns (bool) {
        _uri_prefix = _new_uri_prefix;
        return true;
    }
	
    function setRoute(string memory _new_route) public onlyMultiSigOwners() returns (bool) {
        _route = _new_route;
        return true;
    }
	
	// Used to provide a specific URI for one tokenID
	function setTokenURI(uint256 tokenID, string memory _tokenURI) public returns (bool) {
		require(msg.sender == FactoryAddress);
		
		tokenURIs[tokenID] = _tokenURI;
		return true;
	}

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);
    }

  // END COMPLEX ERC721 HANDLING


  // BEGIN META_TXS PROXY HANDLING
  
	// Pass through the proxy implementation:
	
    address payable ProxyContractForMetaTxsAddress;

    function setProxyContractForMetaTxsAddress(address payable _newAddress) public onlyMultiSigOwners() returns (bool) {
        ProxyContractForMetaTxsAddress = _newAddress;
    }

	  function updateWhitelist(address _account, bool _value) public returns(bool)
	  {
		ProxyContractForMetaTxs _proxy_contract_MetaTx = ProxyContractForMetaTxs(ProxyContractForMetaTxsAddress);
		return _proxy_contract_MetaTx.updateWhitelist(_account, _value);
	  }
	  
	  event UpdateWhitelist(address _account, bool _value);
	  	  
	  function () external payable
	  {
		ProxyContractForMetaTxsAddress.call.value(msg.value)("");
	  }
	  
	  event Received (address indexed sender, uint value);

	  function getHash(address signer, address destination, uint value, bytes memory data, address rewardToken, uint rewardAmount) public view returns(bytes32)
	  {
	  	ProxyContractForMetaTxs _proxy_contract_MetaTx = ProxyContractForMetaTxs(ProxyContractForMetaTxsAddress);
		return _proxy_contract_MetaTx.getHash(signer, destination, value, data, rewardToken, rewardAmount);
	  }
	  
	  // original forward function copied from https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
	  function forward(bytes memory sig, address signer, address destination, uint value, bytes memory data, address rewardToken, uint rewardAmount) public
	  {
	  	ProxyContractForMetaTxs _proxy_contract_MetaTx = ProxyContractForMetaTxs(ProxyContractForMetaTxsAddress);
		return _proxy_contract_MetaTx.forward(sig, signer, destination, value, data, rewardToken, rewardAmount);
	  }
	  
	  // when some frontends see that a tx is made from a bouncerproxy, they may want to parse through these events to find out who the signer was etc
	  event Forwarded (bytes sig, address signer, address destination, uint value, bytes data,address rewardToken, uint rewardAmount,bytes32 _hash);
	
  // END META_TXS PROXY HANDLING
}

pragma experimental ABIEncoderV2;
contract NFT_B2E_Listing is MultiSigOwnable {
    
	event RegisterNewAsset(uint256 optionID, string name);
	event RegisterNewBBA(bytes32 hash, uint256 optionID);
	    
	event UpdateAsset(uint256 optionID, string name);
	event UpdateBBA(bytes32 prevhash, bytes32 newhash, uint256 optionID);
	
    address public NFTFactoryAddress;
    address payable NFTTokenAddress;

    struct TokenType {
        uint256 optionID;
        string name;
		    address minter;
    }
	
   struct BBA_Registry_entry {
       uint256 optionID;
       uint256 version;
       address creator;
       bytes32 hash;
    }
   
    mapping(bytes32 => uint256) hashToOptionId;
    mapping(uint256 => TokenType) _tokenTypes;
    mapping(uint256 => BBA_Registry_entry) BBA_Registry;
   
   constructor(address _factory, address payable _nft, uint256 _nbApprovalNeeded, address[] memory _ownerList) MultiSigOwnable(_nbApprovalNeeded, _ownerList) public {
		NFTFactoryAddress = _factory;
		NFTTokenAddress = _nft;
   }

   function setNFTFactoryAddress(address _new_address) public onlyMultiSigOwners() {
		NFTFactoryAddress = _new_address;
   }
   
   function setNFTTokenAddress(address payable _new_address) public onlyMultiSigOwners() {
		NFTTokenAddress = _new_address;
    }
    
   function newAsset(uint256 optionID, string memory name, address minter) public {
		_tokenTypes[optionID] = TokenType(optionID, name, minter);
		emit RegisterNewAsset(optionID, name);
    }
   
   function replaceAsset(uint256 optionID, string memory name, address minter) public {
		delete _tokenTypes[optionID];
		_tokenTypes[optionID] = TokenType(optionID, name, minter);
		emit UpdateAsset(optionID, name);
    }

   function query(bytes32 hash) public view returns (uint256) {
		return hashToOptionId[hash];
    }
   
    function queryBBA(uint256 optionID) public view returns (BBA_Registry_entry memory) {
		  return BBA_Registry[optionID];
    }
   
   function registerBBA(bytes32 hash, uint256 optionID) public onlyMultiSigOwners() returns (bool) {
		emit RegisterNewBBA(hash, optionID);
		
		require(hashToOptionId[hash] == 0, "BBA Already exists");
		hashToOptionId[hash] = optionID;
		
		return true;
    }
   
   function updateBBA(bytes32 prevhash, bytes32 newhash, uint256 optionID, address creator, uint256 version) public onlyMultiSigOwners() returns (bool) {
	   require(optionID == hashToOptionId[prevhash]);
	   require(creator == BBA_Registry[optionID].creator);
	   require(version == BBA_Registry[optionID].version + 1);
	   
       BBA_Registry_entry memory _bba = BBA_Registry_entry(optionID, version, creator, newhash);
       BBA_Registry[optionID] = _bba;
	   
       emit UpdateBBA(prevhash, newhash, optionID);
	   return true;
    }
   
   	function getAllTokenIds(address addr) public view returns (uint256[] memory)
	{
		NFT_Token ItemContract = NFT_Token(NFTTokenAddress);
		return ItemContract.tokensOfOwner(addr);
	}
	
	function getAllOptionIds(address addr) public view returns (uint256[] memory)
	{
		NFT_Token ItemContract = NFT_Token(NFTTokenAddress);
		
		uint256[] memory tokenIDs = ItemContract.tokensOfOwner(addr);
		
		for (uint256 i = 0; i < tokenIDs.length; i++)
		{
			uint256 currentOptionID = ItemContract.itemTypes(tokenIDs[i]);
			tokenIDs[i] = currentOptionID;
		}
		return tokenIDs;
	}
}

contract ProxyContractForBurn is IProxyContractForBurn {
	 using SafeMath for uint256;
	 
	address public nxcAddress;
			
	uint256 minimum = 100;
	uint256 divisor = 4;
	
	constructor(address _nxcAddress) public {
		nxcAddress = _nxcAddress;
	}
	
	function setnxcAddress(address new_address) public
	{
		nxcAddress = new_address;
	}
	
	function burnNxCtoMintAssets(uint256 nbOfAsset, string[] memory keys, string[] memory values) public view returns (uint256)
	{
		require (keys.length == values.length);
		
		NxcInterface nxcContract = NxcInterface(nxcAddress);
		
		uint256 nxcTotalSupply = nxcContract.totalSupply();
		
		// N = (100+NOMBRE_ASSET) * TOTAL_SUPPLY / 1 000 000 / 4
	    uint256 ret = ((nbOfAsset.add(minimum)).mul((nxcTotalSupply).div(1000))).div(divisor.mul(1000000)).mul(1000);
	    
		return ret;
	}
}