/**

 *Submitted for verification at Etherscan.io on 2018-08-28

*/



pragma solidity ^0.4.11;





interface CommonWallet {

    function receive() external payable;

}



library StringUtils {

    function concat(string _a, string _b)

        internal

        pure

        returns (string)

    {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);



        bytes memory bab = new bytes(_ba.length + _bb.length);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];

        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];

        return string(bab);

    }

}



library UintStringUtils {

    function toString(uint i)

        internal

        pure

        returns (string)

    {

        if (i == 0) return '0';

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

}



// @title AddressUtils

// @dev Utility library of inline functions on addresses

library AddressUtils {

    // Returns whether the target address is a contract

    // @dev This function will return false if invoked during the constructor of a contract,

    // as the code is not actually created until after the constructor finishes.

    // @param addr address to check

    // @return whether the target address is a contract

    function isContract(address addr)

        internal

        view

        returns(bool)

    {

        uint256 size;

        // XXX Currently there is no better way to check if there is a contract in an address

        // than to check the size of the code at that address.

        // See https://ethereum.stackexchange.com/a/14016/36603

        // for more details about how this works.

        // TODO Check this again before the Serenity release, because all addresses will be

        // contracts then.

        // solium-disable-next-line security/no-inline-assembly

        assembly { size := extcodesize(addr) }

        return size > 0;

    }

}



 // @title SafeMath256

 // @dev Math operations with safety checks that throw on error

library SafeMath256 {



  // @dev Multiplies two numbers, throws on overflow.

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }



  // @dev Integer division of two numbers, truncating the quotient.

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }





  // @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }





  // @dev Adds two numbers, throws on overflow.

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



library SafeMath32 {

  // @dev Multiplies two numbers, throws on overflow.

  function mul(uint32 a, uint32 b) internal pure returns (uint32 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }





  // @dev Integer division of two numbers, truncating the quotient.

  function div(uint32 a, uint32 b) internal pure returns (uint32) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint32 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }





  // @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  function sub(uint32 a, uint32 b) internal pure returns (uint32) {

    assert(b <= a);

    return a - b;

  }





  // @dev Adds two numbers, throws on overflow.

  function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



library SafeMath8 {

  // @dev Multiplies two numbers, throws on overflow.

  function mul(uint8 a, uint8 b) internal pure returns (uint8 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }





  // @dev Integer division of two numbers, truncating the quotient.

  function div(uint8 a, uint8 b) internal pure returns (uint8) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint8 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }





  // @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  function sub(uint8 a, uint8 b) internal pure returns (uint8) {

    assert(b <= a);

    return a - b;

  }





  // @dev Adds two numbers, throws on overflow.

  function add(uint8 a, uint8 b) internal pure returns (uint8 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



/// @title A facet of DragonCore that manages special access privileges.

contract DragonAccessControl 

{

    // @dev Non Assigned address.

    address constant NA = address(0);



    /// @dev Contract owner

    address internal controller_;



    /// @dev Contract modes

    enum Mode {TEST, PRESALE, OPERATE}



    /// @dev Contract state

    Mode internal mode_ = Mode.TEST;



    /// @dev OffChain Server accounts ('minions') addresses

    /// It's used for money withdrawal and export of tokens 

    mapping(address => bool) internal minions_;

    

    /// @dev Presale contract address. Can call `presale` method.

    address internal presale_;



    // Modifiers ---------------------------------------------------------------

    /// @dev Limit execution to controller account only.

    modifier controllerOnly() {

        require(controller_ == msg.sender, "controller_only");

        _;

    }



    /// @dev Limit execution to minion account only.

    modifier minionOnly() {

        require(minions_[msg.sender], "minion_only");

        _;

    }



    /// @dev Limit execution to test time only.

    modifier testModeOnly {

        require(mode_ == Mode.TEST, "test_mode_only");

        _;

    }



    /// @dev Limit execution to presale time only.

    modifier presaleModeOnly {

        require(mode_ == Mode.PRESALE, "presale_mode_only");

        _;

    }



    /// @dev Limit execution to operate time only.

    modifier operateModeOnly {

        require(mode_ == Mode.OPERATE, "operate_mode_only");

        _;

    }



     /// @dev Limit execution to presale account only.

    modifier presaleOnly() {

        require(msg.sender == presale_, "presale_only");

        _;

    }



    /// @dev set state to Mode.OPERATE.

    function setOperateMode()

        external 

        controllerOnly

        presaleModeOnly

    {

        mode_ = Mode.OPERATE;

    }



    /// @dev Set presale contract address. Becomes useless when presale is over.

    /// @param _presale Presale contract address.

    function setPresale(address _presale)

        external

        controllerOnly

    {

        presale_ = _presale;

    }



    /// @dev set state to Mode.PRESALE.

    function setPresaleMode()

        external

        controllerOnly

        testModeOnly

    {

        mode_ = Mode.PRESALE;

    }    



        /// @dev Get controller address.

    /// @return Address of contract's controller.

    function controller()

        external

        view

        returns(address)

    {

        return controller_;

    }



    /// @dev Transfer control to new address. Set controller an approvee for

    /// tokens that managed by contract itself. Remove previous controller value

    /// from contract's approvees.

    /// @param _to New controller address.

    function setController(address _to)

        external

        controllerOnly

    {

        require(_to != NA, "_to");

        require(controller_ != _to, "already_controller");



        controller_ = _to;

    }



    /// @dev Check if address is a minion.

    /// @param _addr Address to check.

    /// @return True if address is a minion.

    function isMinion(address _addr)

        public view returns(bool)

    {

        return minions_[_addr];

    }   



    function getCurrentMode() 

        public view returns (Mode) 

    {

        return mode_;

    }    

}



/// @dev token description, storage and transfer functions

contract DragonBase is DragonAccessControl

{

    using SafeMath8 for uint8;

    using SafeMath32 for uint32;

    using SafeMath256 for uint256;

    using StringUtils for string;

    using UintStringUtils for uint;    



    /// @dev The Birth event is fired whenever a new dragon comes into existence. 

    event Birth(address owner, uint256 petId, uint256 tokenId, uint256 parentA, uint256 parentB, string genes, string params);



    /// @dev Token name

    string internal name_;

    /// @dev Token symbol

    string internal symbol_;

    /// @dev Token resolving url

    string internal url_;



    struct DragonToken {

        // Constant Token params

        uint8   genNum;  // generation number. uses for dragon view

        string  genome;  // genome description

        uint256 petId;   // offchain dragon identifier



        // Parents

        uint256 parentA;

        uint256 parentB;



        // Game-depening Token params

        string  params;  // can change in export operation



        // State

        address owner; 

    }



    /// @dev Count of minted tokens

    uint256 internal mintCount_;

    /// @dev Maximum token supply

    uint256 internal maxSupply_;

     /// @dev Count of burn tokens

    uint256 internal burnCount_;



    // Tokens state

    /// @dev Token approvals values

    mapping(uint256 => address) internal approvals_;

    /// @dev Operator approvals

    mapping(address => mapping(address => bool)) internal operatorApprovals_;

    /// @dev Index of token in owner's token list

    mapping(uint256 => uint256) internal ownerIndex_;

    /// @dev Owner's tokens list

    mapping(address => uint256[]) internal ownTokens_;

    /// @dev Tokens

    mapping(uint256 => DragonToken) internal tokens_;



    // @dev Non Assigned address.

    address constant NA = address(0);



    /// @dev Add token to new owner. Increase owner's balance.

    /// @param _to Token receiver.

    /// @param _tokenId New token id.

    function _addTo(address _to, uint256 _tokenId)

        internal

    {

        DragonToken storage token = tokens_[_tokenId];

        require(token.owner == NA, "taken");



        uint256 lastIndex = ownTokens_[_to].length;

        ownTokens_[_to].push(_tokenId);

        ownerIndex_[_tokenId] = lastIndex;



        token.owner = _to;

    }



    /// @dev Create new token and increase mintCount.

    /// @param _genome New token's genome.

    /// @param _params Token params string. 

    /// @param _parentA Token A parent.

    /// @param _parentB Token B parent.

    /// @return New token id.

    function _createToken(

        address _to,

        

        // Constant Token params

        uint8   _genNum,

        string   _genome,

        uint256 _parentA,

        uint256 _parentB,

        

        // Game-depening Token params

        uint256 _petId,

        string   _params        

    )

        internal returns(uint256)

    {

        uint256 tokenId = mintCount_.add(1);

        mintCount_ = tokenId;



        DragonToken memory token = DragonToken(

            _genNum,

            _genome,

            _petId,



            _parentA,

            _parentB,



            _params,

            NA

        );

        

        tokens_[tokenId] = token;

        

        _addTo(_to, tokenId);

        

        emit Birth(_to, _petId, tokenId, _parentA, _parentB, _genome, _params);

        

        return tokenId;

    }    

 

    /// @dev Get token genome.

    /// @param _tokenId Token id.

    /// @return Token's genome.

    function getGenome(uint256 _tokenId)

        external view returns(string)

    {

        return tokens_[_tokenId].genome;

    }



    /// @dev Get token params.

    /// @param _tokenId Token id.

    /// @return Token's params.

    function getParams(uint256 _tokenId)

        external view returns(string)

    {

        return tokens_[_tokenId].params;

    }



    /// @dev Get token parentA.

    /// @param _tokenId Token id.

    /// @return Parent token id.

    function getParentA(uint256 _tokenId)

        external view returns(uint256)

    {

        return tokens_[_tokenId].parentA;

    }   



    /// @dev Get token parentB.

    /// @param _tokenId Token id.

    /// @return Parent token id.

    function getParentB(uint256 _tokenId)

        external view returns(uint256)

    {

        return tokens_[_tokenId].parentB;

    }



    /// @dev Check if `_tokenId` exists. Check if owner is not addres(0).

    /// @param _tokenId Token id

    /// @return Return true if token owner is real.

    function isExisting(uint256 _tokenId)

        public view returns(bool)

    {

        return tokens_[_tokenId].owner != NA;

    }    



    /// @dev Receive maxium token supply value.

    /// @return Contracts `maxSupply_` variable.

    function maxSupply()

        external view returns(uint256)

    {

        return maxSupply_;

    }



    /// @dev Set url prefix for tokenURI generation.

    /// @param _url Url prefix value.

    function setUrl(string _url)

        external controllerOnly

    {

        url_ = _url;

    }



    /// @dev Get token symbol.

    /// @return Token symbol name.

    function symbol()

        external view returns(string)

    {

        return symbol_;

    }



    /// @dev Get token URI to receive offchain information by it's id.

    /// @param _tokenId Token id.

    /// @return URL string. For example "http://erc721.tld/tokens/1".

    function tokenURI(uint256 _tokenId)

        external view returns(string)

    {

        return url_.concat(_tokenId.toString());

    }



     /// @dev Get token name.

    /// @return Token name string.

    function name()

        external view returns(string)

    {

        return name_;

    }



    /// @dev return information about _owner tokens

    function getTokens(address _owner)

        external view  returns (uint256[], uint256[], byte[]) 

    {

        uint256[] memory tokens = ownTokens_[_owner];

        uint256[] memory tokenIds = new uint256[](tokens.length);

        uint256[] memory petIds = new uint256[](tokens.length);



        byte[] memory genomes = new byte[](tokens.length * 77);

        uint index = 0;



        for(uint i = 0; i < tokens.length; i++) {

            uint256 tokenId = tokens[i];

            

            DragonToken storage token = tokens_[tokenId];



            tokenIds[i] = tokenId;

            petIds[i] = token.petId;

            

            bytes storage genome = bytes(token.genome);

            

            for(uint j = 0; j < genome.length; j++) {

                genomes[index++] = genome[j];

            }

        }

        return (tokenIds, petIds, genomes);

    }

    

}



/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens

/// @dev See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/ERC721.sol



contract ERC721Basic 

{

    /// @dev Emitted when token approvee is set

    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    /// @dev Emitted when owner approve all own tokens to operator.

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @dev Emitted when user deposit some funds.

    event Deposit(address indexed _sender, uint256 _value);

    /// @dev Emitted when user deposit some funds.

    event Withdraw(address indexed _sender, uint256 _value);

    /// @dev Emitted when token transferred to new owner

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);



    // Required methods

    function balanceOf(address _owner) external view returns (uint256 _balance);

    function ownerOf(uint256 _tokenId) public view returns (address _owner);

    function exists(uint256 _tokenId) public view returns (bool _exists);

    

    function approve(address _to, uint256 _tokenId) external;

    function getApproved(uint256 _tokenId) public view returns (address _to);



    //function transfer(address _to, uint256 _tokenId) public;

    function transferFrom(address _from, address _to, uint256 _tokenId) public;



    function totalSupply() public view returns (uint256 total);



    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)

    function supportsInterface(bytes4 _interfaceID) external view returns (bool);

}



/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Metadata is ERC721Basic 

{

    function name() external view returns (string _name);

    function symbol() external view returns (string _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string);

}





/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 *  from ERC721 asset contracts.

 */

contract ERC721Receiver 

{

  /**

   * @dev Magic value to be returned upon successful reception of an NFT

   *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,

   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`

   */

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;



  /**

   * @notice Handle the receipt of an NFT

   * @dev The ERC721 smart contract calls this function on the recipient

   *  after a `safetransfer`. This function MAY throw to revert and reject the

   *  transfer. This function MUST use 50,000 gas or less. Return of other

   *  than the magic value MUST result in the transaction being reverted.

   *  Note: the contract address is always the message sender.

   * @param _from The sending address

   * @param _tokenId The NFT identifier which is being transfered

   * @param _data Additional data with no specified format

   * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`

   */

    function onERC721Received(address _from, uint256 _tokenId, bytes _data )

        public returns(bytes4);

}



/**

 * @title ERC-721 Non-Fungible Token Standard, full implementation interface

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721 is ERC721Basic, ERC721Metadata, ERC721Receiver 

{

    /// @dev Interface signature 721 for interface detection.

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;



    bytes4 constant InterfaceSignature_ERC165 = 0x01ffc9a7;

    /*

    bytes4(keccak256('supportsInterface(bytes4)'));

    */



    bytes4 constant InterfaceSignature_ERC721Enumerable = 0x780e9d63;

    /*

    bytes4(keccak256('totalSupply()')) ^

    bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^

    bytes4(keccak256('tokenByIndex(uint256)'));

    */



    bytes4 constant InterfaceSignature_ERC721Metadata = 0x5b5e139f;

    /*

    bytes4(keccak256('name()')) ^

    bytes4(keccak256('symbol()')) ^

    bytes4(keccak256('tokenURI(uint256)'));

    */



    bytes4 constant InterfaceSignature_ERC721 = 0x80ac58cd;

    /*

    bytes4(keccak256('balanceOf(address)')) ^

    bytes4(keccak256('ownerOf(uint256)')) ^

    bytes4(keccak256('approve(address,uint256)')) ^

    bytes4(keccak256('getApproved(uint256)')) ^

    bytes4(keccak256('setApprovalForAll(address,bool)')) ^

    bytes4(keccak256('isApprovedForAll(address,address)')) ^

    bytes4(keccak256('transferFrom(address,address,uint256)')) ^

    bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^

    bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'));

    */



    function supportsInterface(bytes4 _interfaceID) external view returns (bool)

    {

        return ((_interfaceID == InterfaceSignature_ERC165)

            || (_interfaceID == InterfaceSignature_ERC721)

            || (_interfaceID == InterfaceSignature_ERC721Enumerable)

            || (_interfaceID == InterfaceSignature_ERC721Metadata));

    }    

}



/// @dev ERC721 methods

contract DragonOwnership is ERC721, DragonBase

{

    using StringUtils for string;

    using UintStringUtils for uint;    

    using AddressUtils for address;



    /// @dev Emitted when token transferred to new owner. Additional fields is petId, genes, params

    /// it uses for client-side indication

    event TransferInfo(address indexed _from, address indexed _to, uint256 _tokenId, uint256 petId, string genes, string params);



    /// @dev Specify if _addr is token owner or approvee. Also check if `_addr`

    /// is operator for token owner.

    /// @param _tokenId Token to check ownership of.

    /// @param _addr Address to check if it's an owner or an aprovee of `_tokenId`.

    /// @return True if token can be managed by provided `_addr`.

    function isOwnerOrApproved(uint256 _tokenId, address _addr)

        public view returns(bool)

    {

        DragonToken memory token = tokens_[_tokenId];



        if (token.owner == _addr) {

            return true;

        }

        else if (isApprovedFor(_tokenId, _addr)) {

            return true;

        }

        else if (isApprovedForAll(token.owner, _addr)) {

            return true;

        }



        return false;

    }



    /// @dev Limit execution to token owner or approvee only.

    /// @param _tokenId Token to check ownership of.

    modifier ownerOrApprovedOnly(uint256 _tokenId) {

        require(isOwnerOrApproved(_tokenId, msg.sender), "tokenOwnerOrApproved_only");

        _;

    }



    /// @dev Contract's own token only acceptable.

    /// @param _tokenId Contract's token id.

    modifier ownOnly(uint256 _tokenId) {

        require(tokens_[_tokenId].owner == address(this), "own_only");

        _;

    }



    /// @dev Determine if token is approved for specified approvee.

    /// @param _tokenId Target token id.

    /// @param _approvee Approvee address.

    /// @return True if so.

    function isApprovedFor(uint256 _tokenId, address _approvee)

        public view returns(bool)

    {

        return approvals_[_tokenId] == _approvee;

    }



    /// @dev Specify is given address set as operator with setApprovalForAll.

    /// @param _owner Token owner.

    /// @param _operator Address to check if it an operator.

    /// @return True if operator is set.

    function isApprovedForAll(address _owner, address _operator)

        public view returns(bool)

    {

        return operatorApprovals_[_owner][_operator];

    }



    /// @dev Check if `_tokenId` exists. Check if owner is not addres(0).

    /// @param _tokenId Token id

    /// @return Return true if token owner is real.

    function exists(uint256 _tokenId)

        public view returns(bool)

    {

        return tokens_[_tokenId].owner != NA;

    }



    /// @dev Get owner of a token.

    /// @param _tokenId Token owner id.

    /// @return Token owner address.

    function ownerOf(uint256 _tokenId)

        public view returns(address)

    {

        return tokens_[_tokenId].owner;

    }



    /// @dev Get approvee address. If there is not approvee returns 0x0.

    /// @param _tokenId Token id to get approvee of.

    /// @return Approvee address or 0x0.

    function getApproved(uint256 _tokenId)

        public view returns(address)

    {

        return approvals_[_tokenId];

    }



    /// @dev Grant owner alike controll permissions to third party.

    /// @param _to Permission receiver.

    /// @param _tokenId Granted token id.

    function approve(address _to, uint256 _tokenId)

        external ownerOrApprovedOnly(_tokenId)

    {

        address owner = ownerOf(_tokenId);

        require(_to != owner);



        if (getApproved(_tokenId) != NA || _to != NA) {

            approvals_[_tokenId] = _to;



            emit Approval(owner, _to, _tokenId);

        }

    }



    /// @dev Current total tokens supply. Always less then maxSupply.

    /// @return Difference between minted and burned tokens.

    function totalSupply()

        public view returns(uint256)

    {

        return mintCount_;

    }    



    /// @dev Get number of tokens which `_owner` owns.

    /// @param _owner Address to count own tokens.

    /// @return Count of owned tokens.

    function balanceOf(address _owner)

        external view returns(uint256)

    {

        return ownTokens_[_owner].length;

    }    



    /// @dev Internal set approval for all without _owner check.

    /// @param _owner Granting user.

    /// @param _to New account approvee.

    /// @param _approved Set new approvee status.

    function _setApprovalForAll(address _owner, address _to, bool _approved)

        internal

    {

        operatorApprovals_[_owner][_to] = _approved;



        emit ApprovalForAll(_owner, _to, _approved);

    }



    /// @dev Set approval for all account tokens.

    /// @param _to Approvee address.

    /// @param _approved Value true or false.

    function setApprovalForAll(address _to, bool _approved)

        external

    {

        require(_to != msg.sender);



        _setApprovalForAll(msg.sender, _to, _approved);

    }



    /// @dev Remove approval bindings for token. Do nothing if no approval

    /// exists.

    /// @param _from Address of token owner.

    /// @param _tokenId Target token id.

    function _clearApproval(address _from, uint256 _tokenId)

        internal

    {

        if (approvals_[_tokenId] == NA) {

            return;

        }



        approvals_[_tokenId] = NA;

        emit Approval(_from, NA, _tokenId);

    }



    /// @dev Check if contract was received by other side properly if receiver

    /// is a ctontract.

    /// @param _from Current token owner.

    /// @param _to New token owner.

    /// @param _tokenId token Id.

    /// @param _data Transaction data.

    /// @return True on success.

    function _checkAndCallSafeTransfer(

        address _from,

        address _to,

        uint256 _tokenId,

        bytes _data

    )

        internal returns(bool)

    {

        if (! _to.isContract()) {

            return true;

        }



        bytes4 retval = ERC721Receiver(_to).onERC721Received(

            _from, _tokenId, _data

        );



        return (retval == ERC721_RECEIVED);

    }



    /// @dev Remove token from owner. Unrecoverable.

    /// @param _tokenId Removing token id.

    function _remove(uint256 _tokenId)

        internal

    {

        address owner = tokens_[_tokenId].owner;

        _removeFrom(owner, _tokenId);

    }



    /// @dev Completely remove token from the contract. Unrecoverable.

    /// @param _owner Owner of removing token.

    /// @param _tokenId Removing token id.

    function _removeFrom(address _owner, uint256 _tokenId)

        internal

    {

        uint256 lastIndex = ownTokens_[_owner].length.sub(1);

        uint256 lastToken = ownTokens_[_owner][lastIndex];



        // Swap users token

        ownTokens_[_owner][ownerIndex_[_tokenId]] = lastToken;

        ownTokens_[_owner].length--;



        // Swap token indexes

        ownerIndex_[lastToken] = ownerIndex_[_tokenId];

        ownerIndex_[_tokenId] = 0;



        DragonToken storage token = tokens_[_tokenId];

        token.owner = NA;

    }



    /// @dev Transfer token from owner `_from` to another address or contract

    /// `_to` by it's `_tokenId`.

    /// @param _from Current token owner.

    /// @param _to New token owner.

    /// @param _tokenId token Id.

    function transferFrom( address _from, address _to, uint256 _tokenId )

        public ownerOrApprovedOnly(_tokenId)

    {

        require(_from != NA);

        require(_to != NA);



        _clearApproval(_from, _tokenId);

        _removeFrom(_from, _tokenId);

        _addTo(_to, _tokenId);



        emit Transfer(_from, _to, _tokenId);



        DragonToken storage token = tokens_[_tokenId];

        emit TransferInfo(_from, _to, _tokenId, token.petId, token.genome, token.params);

    }



    /// @dev Update token params and transfer to new owner. Only contract's own

    /// tokens could be updated. Also notifies receiver of the token.

    /// @param _to Address to transfer token to.

    /// @param _tokenId Id of token that should be transferred.

    /// @param _params New token params.

    function updateAndSafeTransferFrom(

        address _to,

        uint256 _tokenId,

        string _params

    )

        public

    {

        updateAndSafeTransferFrom(_to, _tokenId, _params, "");

    }



    /// @dev Update token params and transfer to new owner. Only contract's own

    /// tokens could be updated. Also notifies receiver of the token and send

    /// protion of _data to it.

    /// @param _to Address to transfer token to.

    /// @param _tokenId Id of token that should be transferred.

    /// @param _params New token params.

    /// @param _data Notification data.

    function updateAndSafeTransferFrom(

        address _to,

        uint256 _tokenId,

        string _params,

        bytes _data

    )

        public

    {

        // Safe transfer from

        updateAndTransferFrom(_to, _tokenId, _params, 0, 0);

        require(_checkAndCallSafeTransfer(address(this), _to, _tokenId, _data));

    }



    /// @dev Update token params and transfer to new owner. Only contract's own

    /// tokens could be updated.

    /// @param _to Address to transfer token to.

    /// @param _tokenId Id of token that should be transferred.

    /// @param _params New token params.

    function updateAndTransferFrom(

        address _to,

        uint256 _tokenId,

        string _params,

        uint256 _petId, 

        uint256 _transferCost

    )

        public

        ownOnly(_tokenId)

        minionOnly

    {

        require(bytes(_params).length > 0, "params_length");



        // Update

        tokens_[_tokenId].params = _params;

        if (tokens_[_tokenId].petId == 0 ) {

            tokens_[_tokenId].petId = _petId;

        }



        address from = tokens_[_tokenId].owner;



        // Transfer from

        transferFrom(from, _to, _tokenId);



        // send to the server's wallet the transaction cost

        // withdraw it from the balance of the contract. this amount must be withdrawn from the player

        // on the side of the game server        

        if (_transferCost > 0) {

            msg.sender.transfer(_transferCost);

        }

    }



    /// @dev Transfer token from one owner to new one and check if it was

    /// properly received if receiver is a contact.

    /// @param _from Current token owner.

    /// @param _to New token owner.

    /// @param _tokenId token Id.

    function safeTransferFrom(

        address _from,

        address _to,

        uint256 _tokenId

    )

        public

    {

        safeTransferFrom(_from, _to, _tokenId, "");

    }



    /// @dev Transfer token from one owner to new one and check if it was

    /// properly received if receiver is a contact.

    /// @param _from Current token owner.

    /// @param _to New token owner.

    /// @param _tokenId token Id.

    /// @param _data Transaction data.

    function safeTransferFrom(

        address _from,

        address _to,

        uint256 _tokenId,

        bytes _data

    )

        public

    {

        transferFrom(_from, _to, _tokenId);

        require(_checkAndCallSafeTransfer(_from, _to, _tokenId, _data));

    }



    /// @dev Burn owned token. Increases `burnCount_` and decrease `totalSupply`

    /// value.

    /// @param _tokenId Id of burning token.

    function burn(uint256 _tokenId)

        public

        ownerOrApprovedOnly(_tokenId)

    {

        address owner = tokens_[_tokenId].owner;

        _remove(_tokenId);



        burnCount_ += 1;



        emit Transfer(owner, NA, _tokenId);

    }



    /// @dev Receive count of burned tokens. Should be greater than `totalSupply`

    /// but less than `mintCount`.

    /// @return Number of burned tokens

    function burnCount()

        external

        view

        returns(uint256)

    {

        return burnCount_;

    }



    function onERC721Received(address, uint256, bytes)

        public returns(bytes4) 

    {

        return ERC721_RECEIVED;

    }

}







/// @title Managing contract. implements the logic of buying tokens, depositing / withdrawing funds 

/// to the project account and importing / exporting tokens

contract EtherDragonsCore is DragonOwnership 

{

    using SafeMath8 for uint8;

    using SafeMath32 for uint32;

    using SafeMath256 for uint256;

    using AddressUtils for address;

    using StringUtils for string;

    using UintStringUtils for uint;



    // @dev Non Assigned address.

    address constant NA = address(0);



    /// @dev Bounty tokens count limit

    uint256 public constant BOUNTY_LIMIT = 2500;

    /// @dev Presale tokens count limit

    uint256 public constant PRESALE_LIMIT = 7500;

    ///@dev Total gen0tokens generation limit

    uint256 public constant GEN0_CREATION_LIMIT = 90000;

    

    /// @dev Number of tokens minted in presale stage

    uint256 internal presaleCount_;  

    /// @dev Number of tokens minted for bounty campaign

    uint256 internal bountyCount_;

   

    ///@dev Company bank address

    address internal bank_;



    // Extension ---------------------------------------------------------------



    /// @dev Contract is not payable. To fullfil balance method `depositTo`

    /// should be used.

    function ()

        public payable

    {

        revert();

    }



    /// @dev amount on the account of the contract. This amount consists of deposits  from players and the system reserve for payment of transactions

    /// the player at any time to withdraw the amount corresponding to his account in the game, minus the cost of the transaction 

    function getBalance() 

        public view returns (uint256)

    {

        return address(this).balance;

    }    



    /// @dev at the moment of creation of the contract we transfer the address of the bank

    /// presell contract address set later

    constructor(

        address _bank

    )

        public

    {

        require(_bank != NA);

        

        controller_ = msg.sender;

        bank_ = _bank;

        

        // Meta

        name_ = "EtherDragons";

        symbol_ = "ED";

        url_ = "https://game.etherdragons.world/token/";



        // Token mint limit

        maxSupply_ = GEN0_CREATION_LIMIT + BOUNTY_LIMIT + PRESALE_LIMIT;

    }



    /// Number of tokens minted in presale stage

    function totalPresaleCount()

        public view returns(uint256)

    {

        return presaleCount_;

    }    



    /// @dev Number of tokens minted for bounty campaign

    function totalBountyCount()

        public view returns(uint256)

    {

        return bountyCount_;

    }    

    

    /// @dev Check if new token could be minted. Return true if count of minted

    /// tokens less than could be minted through contract deploy.

    /// Also, tokens can not be created more often than once in mintDelay_ minutes

    /// @return True if current count is less then maximum tokens available for now.

    function canMint()

        public view returns(bool)

    {

        return (mintCount_ + presaleCount_ + bountyCount_) < maxSupply_;

    }



    /// @dev Here we write the addresses of the wallets of the server from which it is accessed

    /// to contract methods.

    /// @param _to New minion address

    function minionAdd(address _to)

        external controllerOnly

    {

        require(minions_[_to] == false, "already_minion");

        

        // ��ѧ٧�֧�ѧ֧� ����ާ� �ѧէ�֧�� ���ݧ�٧�ӧѧ���� ���ܧ֧ߧѧާ� �ܧ�ߧ�ѧܧ��

        // allow the address to use contract tokens 

        _setApprovalForAll(address(this), _to, true);

        

        minions_[_to] = true;

    }



    /// @dev delete the address of the server wallet

    /// @param _to Minion address

    function minionRemove(address _to)

        external controllerOnly

    {

        require(minions_[_to], "not_a_minion");



        // and forbid this wallet to use tokens of the contract

        _setApprovalForAll(address(this), _to, false);

        minions_[_to] = false;

    }



    /// @dev Here the player can put funds to the account of the contract

    /// and get the same amount of in-game currency

    /// the game server understands who puts money at the wallet address

    function depositTo()

        public payable

    {

        emit Deposit(msg.sender, msg.value);

    }    

    

    /// @dev Transfer amount of Ethers to specified receiver. Only owner can

    // call this method.

    /// @param _to Transfer receiver.

    /// @param _amount Transfer value.

    /// @param _transferCost Transfer cost.

    function transferAmount(address _to, uint256 _amount, uint256 _transferCost)

        external minionOnly

    {

        require((_amount + _transferCost) <= address(this).balance, "not enough money!");

        _to.transfer(_amount);



        // send to the wallet of the server the transfer cost

        // withdraw  it from the balance of the contract. this amount must be withdrawn from the player

        // on the side of the game server

        if (_transferCost > 0) {

            msg.sender.transfer(_transferCost);

        }



        emit Withdraw(_to, _amount);

    }        



   /// @dev Mint new token with specified params. Transfer `_fee` to the

    /// `bank`. 

    /// @param _to New token owner.

    /// @param _fee Transaction fee.

    /// @param _genNum Generation number..

    /// @param _genome New genome unique value.

    /// @param _parentA Parent A.

    /// @param _parentB Parent B.

    /// @param _petId Pet identifier.

    /// @param _params List of parameters for pet.

    /// @param _transferCost Transfer cost.

    /// @return New token id.

    function mintRelease(

        address _to,

        uint256 _fee,

        

        // Constant Token params

        uint8   _genNum,

        string   _genome,

        uint256 _parentA,

        uint256 _parentB,

        

        // Game-depening Token params

        uint256 _petId,  //if petID = 0, then it was created outside of the server

        string   _params,

        uint256 _transferCost

    )

        external minionOnly operateModeOnly returns(uint256)

    {

        require(canMint(), "can_mint");

        require(_to != NA, "_to");

        require((_fee + _transferCost) <= address(this).balance, "_fee");

        require(bytes(_params).length != 0, "params_length");

        require(bytes(_genome).length == 77, "genome_length");

        

        // Parents should be both 0 or both not.

        if (_parentA != 0 && _parentB != 0) {

            require(_parentA != _parentB, "same_parent");

        }

        else if (_parentA == 0 && _parentB != 0) {

            revert("parentA_empty");

        }

        else if (_parentB == 0 && _parentA != 0) {

            revert("parentB_empty");

        }



        uint256 tokenId = _createToken(_to, _genNum, _genome, _parentA, _parentB, _petId, _params);



        require(_checkAndCallSafeTransfer(NA, _to, tokenId, ""), "safe_transfer");



        // Transfer mint fee to the fund

        CommonWallet(bank_).receive.value(_fee)();



        emit Transfer(NA, _to, tokenId);



        // send to the server wallet server the transfer cost,

        // withdraw it from the balance of the contract. this amount must be withdrawn from the player

        // on the side of the game server

        if (_transferCost > 0) {

            msg.sender.transfer(_transferCost);

        }



        return tokenId;

    }



    /// @dev Create new token via presale state

    /// @param _to New token owner.

    /// @param _genome New genome unique value.

    /// @return New token id.

    /// at the pre-sale stage we sell the zero-generation pets, which have only a genome.

    /// other attributes of such a token get when importing to the server

    function mintPresell(address _to, string _genome)

        external presaleOnly presaleModeOnly returns(uint256)

    {

        require(presaleCount_ < PRESALE_LIMIT, "presale_limit");



        // �� ���֧�֧ۧ� ��֧�� �ߧ֧� ��ѧ�ѧާ֧����. ���� ��� ���ݧ��ڧ� ����ݧ� �ӧӧ�է� �� �ڧԧ��.

        uint256 tokenId = _createToken(_to, 0, _genome, 0, 0, 0, "");

        presaleCount_ += 1;



        require(_checkAndCallSafeTransfer(NA, _to, tokenId, ""), "safe_transfer");



        emit Transfer(NA, _to, tokenId);

        

        return tokenId;

    }    

    

    /// @dev Create new token for bounty activity

    /// @param _to New token owner.

    /// @return New token id.

    function mintBounty(address _to, string _genome)

        external controllerOnly returns(uint256)

    {

        require(bountyCount_ < BOUNTY_LIMIT, "bounty_limit");



        // bounty pet has no parameters. They will receive them after importing to the game.

        uint256 tokenId = _createToken(_to, 0, _genome, 0, 0, 0, "");

    

        bountyCount_ += 1;

        require(_checkAndCallSafeTransfer(NA, _to, tokenId, ""), "safe_transfer");



        emit Transfer(NA, _to, tokenId);



        return tokenId;

    }        

}



contract Presale

{

    // Extension ---------------------------------------------------------------

    using AddressUtils for address;



    // Events ------------------------------------------------------------------

    ///the event is fired when starting a new wave presale stage

    event StageBegin(uint8 stage, uint256 timestamp);



    ///the event is fired when token sold

    event TokensBought(address buyerAddr, uint256[] tokenIds, bytes genomes);



    // Types -------------------------------------------------------------------

    struct Stage {

        // Predefined values

        uint256 price;      // token's price on the stage

        uint16 softcap;     // stage softCap

        uint16 hardcap;     // stage hardCap

        

        // Unknown values

        uint16 bought;      // sold on stage

        uint32 startDate;   // stage's beginDate

        uint32 endDate;     // stage's endDate

    }

    

    // Constants ---------------------------------------------------------------

    // 10 stages of 5 genocodes

    uint8 public constant STAGES = 10;

    uint8 internal constant TOKENS_PER_STAGE = 5;

    address constant NA = address(0);

    

    // State -------------------------------------------------------------------

    address internal CEOAddress;    // contract owner

    address internal bank_;         // profit wallet address (not a contract)

    address internal erc721_;       // main contract address

    

    /// @dev genomes for bounty stage

    string[TOKENS_PER_STAGE][STAGES] internal genomes_;



    /// stages data

    Stage[STAGES] internal stages_;

    

    // internal transaction counter, it uses for random generator

    uint32  internal counter_;

    

    /// stage is over

    bool    internal isOver_;



    /// stage number

    uint8   internal stageIndex_;



    ///  stage start Data

    uint32  internal stageStart_;



    // Lifetime ----------------------------------------------------------------

    constructor(

        address _bank,  

        address _erc721

    )

        public

    {

        require(_bank != NA, '_bank');

        require(_erc721.isContract(), '_erc721');



        CEOAddress = msg.sender;



        // Addresses should not be the same.

        require(_bank != CEOAddress, "bank = CEO");

        require(CEOAddress != _erc721, "CEO = erc721");

        require(_erc721 != _bank, "bank = erc721");



        // Update state

        bank_ = _bank;

        erc721_ = _erc721;

       

        // stages data 

        stages_[0].price = 10 finney;

        stages_[0].softcap = 100;

        stages_[0].hardcap = 300;

        

        stages_[1].price = 20 finney;

        stages_[1].softcap = 156;

        stages_[1].hardcap = 400;

    

        stages_[2].price = 32 finney;

        stages_[2].softcap = 212;

        stages_[2].hardcap = 500;

        

        stages_[3].price = 45 finney;

        stages_[3].softcap = 268;

        stages_[3].hardcap = 600;

        

        stages_[4].price = 58 finney;

        stages_[4].softcap = 324;

        stages_[4].hardcap = 700;

    

        stages_[5].price = 73 finney;

        stages_[5].softcap = 380;

        stages_[5].hardcap = 800;

    

        stages_[6].price = 87 finney;

        stages_[6].softcap = 436;

        stages_[6].hardcap = 900;

    

        stages_[7].price = 102 finney;

        stages_[7].softcap = 492;

        stages_[7].hardcap = 1000;

    

        stages_[8].price = 118 finney;

        stages_[8].softcap = 548;

        stages_[8].hardcap = 1100;

        

        stages_[9].price = 129 finney;

        stages_[9].softcap = 604;

        stages_[9].hardcap = 1200;

    }



    /// fill the genomes data

    function setStageGenomes(

        uint8 _stage,

        string _genome0, 

        string _genome1,

        string _genome2, 

        string _genome3, 

        string _genome4

    ) 

        external controllerOnly

    {

        genomes_[_stage][0] = _genome0;

        genomes_[_stage][1] = _genome1;

        genomes_[_stage][2] = _genome2;

        genomes_[_stage][3] = _genome3;

        genomes_[_stage][4] = _genome4;

    }



    /// @dev Contract itself is non payable

    function ()

        public payable

    {

        revert();

    }

    

    // Modifiers ---------------------------------------------------------------

    

    /// only from contract owner

    modifier controllerOnly() {

        require(msg.sender == CEOAddress, 'controller_only');

        _;

    }



    /// only for active stage

    modifier notOverOnly() {

        require(isOver_ == false, 'notOver_only');

        _;

    }



    // Getters -----------------------------------------------------------------

    /// owner address

    function getCEOAddress()

        public view returns(address)

    {

        return CEOAddress;

    }



    /// counter from random number generator

    function counter()

        internal view returns(uint32)

    {

        return counter_;

    }



    // tokens sold by stage ...

    function stageTokensBought(uint8 _stage)

        public view returns(uint16)

    {

        return stages_[_stage].bought;

    }



    // stage softcap

    function stageSoftcap(uint8 _stage)

        public view returns(uint16)

    {

        return stages_[_stage].softcap;

    }



    /// stage hardcap

    function stageHardcap(uint8 _stage)

        public view returns(uint16)

    {

        return stages_[_stage].hardcap;

    }



    /// stage Start Date    

    function stageStartDate(uint8 _stage)

        public view returns(uint)

    {

        return stages_[_stage].startDate;

    }

    

    /// stage Finish Date

    function stageEndDate(uint8 _stage)

        public view returns(uint)

    {

        return stages_[_stage].endDate;

    }



    /// stage token price

    function stagePrice(uint _stage)

        public view returns(uint)

    {

        return stages_[_stage].price;

    }

    

    // Genome Logic -----------------------------------------------------------------

    /// within the prelase , the dragons are generated, which are the ancestors of the destiny

    /// newborns have a high chance of mutation and are unlikely to be purebred

    /// the player will have to collect the breed, crossing a lot of pets

    /// In addition, you will need to pick up combat abilities

    /// these characteristics are assigned to the pet when the dragon is imported to the game server.    

    function nextGenome()

        internal returns(string)

    {

        uint8 n = getPseudoRandomNumber();



        counter_ += 1;

        

        return genomes_[stageIndex_][n];

    }



    function getPseudoRandomNumber()

        internal view returns(uint8 index)

    {

        uint8 n = uint8(

            keccak256(abi.encode(msg.sender, block.timestamp + counter_))

        );

        return n % TOKENS_PER_STAGE;

    }

    

    // PreSale Logic -----------------------------------------------------------------

    /// Presale stage0 begin date set

    /// presale start is possible only once    

    function setStartDate(uint32 _startDate)

        external controllerOnly

    {

        require(stages_[0].startDate == 0, 'already_set');

        

        stages_[0].startDate = _startDate;

        stageStart_ = _startDate;

        stageIndex_ = 0;

        

        emit StageBegin(stageIndex_, stageStart_); 

    }



    /// current stage number

    /// switches to the next stage if the time has come

    function stageIndex()

        external view returns(uint8)

    {

        Stage memory stage = stages_[stageIndex_];



        if (stage.endDate > 0 && stage.endDate <= now) {

            return stageIndex_ + 1;

        }

        else {

            return stageIndex_;

        }

    }

    

    /// check whether the phase started

    /// switch to the next stage, if necessary    

    function beforeBuy()

        internal

    {

        if (stageStart_ == 0) {

            revert('presale_not_started');

        }

        else if (stageStart_ > now) {

            revert('stage_not_started');

        }



        Stage memory stage = stages_[stageIndex_];

        if (stage.endDate > 0 && stage.endDate <= now) 

        {

            stageIndex_ += 1;

            stageStart_ = stages_[stageIndex_].startDate;



            if (stageStart_ > now) {

                revert('stage_not_started');

            }

        }

    }

    

    /// time to next midnight

    function midnight()

        public view returns(uint32)

    {

        uint32 tomorrow = uint32(now + 1 days);

        uint32 remain = uint32(tomorrow % 1 days);

        return tomorrow - remain;

    }

    

    /// buying a specified number of tokens

    function buyTokens(uint16 numToBuy)

        public payable notOverOnly returns(uint256[])

    {

        beforeBuy();

        

        require(numToBuy > 0 && numToBuy <= 10, "numToBuy error");



        Stage storage stage = stages_[stageIndex_];

        require((stage.price * numToBuy) <= msg.value, 'price');

        

        uint16 prevBought = stage.bought;

        require(prevBought + numToBuy <= stage.hardcap, "have required tokens");

        

        stage.bought += numToBuy;

        uint256[] memory tokenIds = new uint256[](numToBuy);

        

        bytes memory genomes = new bytes(numToBuy * 77);

        uint32 genomeByteIndex = 0;



        for(uint16 t = 0; t < numToBuy; t++) 

        {

            string memory genome = nextGenome();

            uint256 tokenId = EtherDragonsCore(erc721_).mintPresell(msg.sender, genome);



            bytes memory genomeBytes = bytes(genome);

            

            for(uint8 gi = 0; gi < genomeBytes.length; gi++) {

                genomes[genomeByteIndex++] = genomeBytes[gi];

            }



            tokenIds[t] = tokenId;

        }



        // Transfer mint fee to the fund

        bank_.transfer(address(this).balance);



        if (stage.bought == stage.hardcap) {

            stage.endDate = uint32(now);

            stageStart_ = midnight() + 1 days + 1 seconds;

            if (stageIndex_ < STAGES - 1) {

                stageIndex_ += 1;

            }

            else {

                isOver_ = true;

            }

        }

        else if (stage.bought >= stage.softcap && prevBought < stage.softcap) {

            stage.endDate = midnight() + 1 days;

            if (stageIndex_ < STAGES - 1) {

                stages_[stageIndex_ + 1].startDate = stage.endDate + 1 days;

            }

        }



        emit TokensBought(msg.sender, tokenIds, genomes);



        return tokenIds;

    }



    function currTime()

        public view returns(uint)

    {

        return now;

    }

    

    /// stages data

    function getStagesInfo() 

        public view returns (uint256[] prices, uint16[] softcaps, uint16[] hardcaps, uint16[] boughts) 

    {

            prices = new uint256[](STAGES);

            softcaps = new uint16[](STAGES);

            hardcaps = new uint16[](STAGES);

            boughts = new uint16[](STAGES);

            

            for(uint8 s = 0; s < STAGES; s++) {

                prices[s] = stages_[s].price;

                softcaps[s] = stages_[s].softcap;

                hardcaps[s] = stages_[s].hardcap;

                boughts[s] = stages_[s].bought;

            }

    }

    

    /// stages dates data

    function getStagesBeginEnd() 

        public view returns (uint32[] startDates, uint32[] endDates) 

    {

        startDates = new uint32[](STAGES);

        endDates = new uint32[](STAGES);

        

        for(uint8 s = 0; s < STAGES; s++) {

            startDates[s] = stages_[s].startDate;

            endDates[s] = stages_[s].endDate;

        }

    }



    /// returns data which genomes can be purchased at the stage

    function stageGenomes(uint8 _stage)

        public view returns(byte[])

    {

        byte[] memory genomes = new byte[](uint16(TOKENS_PER_STAGE) * 77);

        uint32 gbIndex = 0;



        for(uint8 tokenIndex = 0; tokenIndex < TOKENS_PER_STAGE; tokenIndex++) {

            

            bytes memory genomeBytes = bytes(genomes_[_stage][tokenIndex]);

            

            for(uint8 gi = 0; gi < genomeBytes.length; gi++) {

                genomes[gbIndex++] = genomeBytes[gi];

            }

        }



        return genomes;

    }

}