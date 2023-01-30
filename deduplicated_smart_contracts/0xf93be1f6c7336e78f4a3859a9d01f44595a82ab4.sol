/**

 *Submitted for verification at Etherscan.io on 2019-07-12

*/



pragma solidity ^0.4.23;



pragma solidity ^0.4.23;



pragma solidity ^0.4.23;



// ----------------------------------------------------------------------------

contract ERC20 {



    // ERC Token Standard #223 Interface

    // https://github.com/ethereum/EIPs/issues/223



    string public symbol;

    string public  name;

    uint8 public decimals;



    function transfer(address _to, uint _value, bytes _data) external returns (bool success);



    // approveAndCall

    function approveAndCall(address spender, uint tokens, bytes data) external returns (bool success);



    // ERC Token Standard #20 Interface

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md





    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);



    // bulk operations

    function transferBulk(address[] to, uint[] tokens) public;

    function approveBulk(address[] spender, uint[] tokens) public;

}



pragma solidity ^0.4.23;



/// @title ERC-721 Non-Fungible Token Standard

/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

///  Note: the ERC-165 identifier for this interface is 0x6466353c

interface ERC721 /*is ERC165*/ {



    /// @notice Query if a contract implements an interface

    /// @param interfaceID The interface identifier, as specified in ERC-165

    /// @dev Interface identification is specified in ERC-165. This function

    ///  uses less than 30,000 gas.

    /// @return `true` if the contract implements `interfaceID` and

    ///  `interfaceID` is not 0xffffffff, `false` otherwise

    function supportsInterface(bytes4 interfaceID) external view returns (bool);



    /// @dev This emits when ownership of any NFT changes by any mechanism.

    ///  This event emits when NFTs are created (`from` == 0) and destroyed

    ///  (`to` == 0). Exception: during contract creation, any number of NFTs

    ///  may be created and assigned without emitting Transfer. At the time of

    ///  any transfer, the approved address for that NFT (if any) is reset to none.

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);



    /// @dev This emits when the approved address for an NFT is changed or

    ///  reaffirmed. The zero address indicates there is no approved address.

    ///  When a Transfer event emits, this also indicates that the approved

    ///  address for that NFT (if any) is reset to none.

    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);



    /// @dev This emits when an operator is enabled or disabled for an owner.

    ///  The operator can manage all NFTs of the owner.

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



    /// @notice Count all NFTs assigned to an owner

    /// @dev NFTs assigned to the zero address are considered invalid, and this

    ///  function throws for queries about the zero address.

    /// @param _owner An address for whom to query the balance

    /// @return The number of NFTs owned by `_owner`, possibly zero

    function balanceOf(address _owner) external view returns (uint256);



    /// @notice Find the owner of an NFT

    /// @param _tokenId The identifier for an NFT

    /// @dev NFTs assigned to zero address are considered invalid, and queries

    ///  about them do throw.

    /// @return The address of the owner of the NFT

    function ownerOf(uint256 _tokenId) external view returns (address);



    /// @notice Transfers the ownership of an NFT from one address to another address

    /// @dev Throws unless `msg.sender` is the current owner, an authorized

    ///  operator, or the approved address for this NFT. Throws if `_from` is

    ///  not the current owner. Throws if `_to` is the zero address. Throws if

    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function

    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls

    ///  `onERC721Received` on `_to` and throws if the return value is not

    ///  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.

    /// @param _from The current owner of the NFT

    /// @param _to The new owner

    /// @param _tokenId The NFT to transfer

    /// @param data Additional data with no specified format, sent in call to `_to`

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external;

    

    /// @notice Transfers the ownership of an NFT from one address to another address

    /// @dev This works identically to the other function with an extra data parameter,

    ///  except this function just sets data to ""

    /// @param _from The current owner of the NFT

    /// @param _to The new owner

    /// @param _tokenId The NFT to transfer

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;



    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE

    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE

    ///  THEY MAY BE PERMANENTLY LOST

    /// @dev Throws unless `msg.sender` is the current owner, an authorized

    ///  operator, or the approved address for this NFT. Throws if `_from` is

    ///  not the current owner. Throws if `_to` is the zero address. Throws if

    ///  `_tokenId` is not a valid NFT.

    /// @param _from The current owner of the NFT

    /// @param _to The new owner

    /// @param _tokenId The NFT to transfer

    function transferFrom(address _from, address _to, uint256 _tokenId) external;



    /// @notice Set or reaffirm the approved address for an NFT

    /// @dev The zero address indicates there is no approved address.

    /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized

    ///  operator of the current owner.

    /// @param _approved The new approved NFT controller

    /// @param _tokenId The NFT to approve

    function approve(address _approved, uint256 _tokenId) external;



    /// @notice Enable or disable approval for a third party ("operator") to manage

    ///  all your asset.

    /// @dev Emits the ApprovalForAll event

    /// @param _operator Address to add to the set of authorized operators.

    /// @param _approved True if the operators is approved, false to revoke approval

    function setApprovalForAll(address _operator, bool _approved) external;



    /// @notice Get the approved address for a single NFT

    /// @dev Throws if `_tokenId` is not a valid NFT

    /// @param _tokenId The NFT to find the approved address for

    /// @return The approved address for this NFT, or the zero address if there is none

    function getApproved(uint256 _tokenId) external view returns (address);



    /// @notice Query if an address is an authorized operator for another address

    /// @param _owner The address that owns the NFTs

    /// @param _operator The address that acts on behalf of the owner

    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);





   /// @notice A descriptive name for a collection of NFTs in this contract

    function name() external pure returns (string _name);



    /// @notice An abbreviated name for NFTs in this contract

    function symbol() external pure returns (string _symbol);



    

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.

    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC

    ///  3986. The URI may point to a JSON file that conforms to the "ERC721

    ///  Metadata JSON Schema".

    function tokenURI(uint256 _tokenId) external view returns (string);



     /// @notice Count NFTs tracked by this contract

    /// @return A count of valid NFTs tracked by this contract, where each one of

    ///  them has an assigned and queryable owner not equal to the zero address

    function totalSupply() external view returns (uint256);



    /// @notice Enumerate valid NFTs

    /// @dev Throws if `_index` >= `totalSupply()`.

    /// @param _index A counter less than `totalSupply()`

    /// @return The token identifier for the `_index`th NFT,

    ///  (sort order not specified)

    function tokenByIndex(uint256 _index) external view returns (uint256);



    /// @notice Enumerate NFTs assigned to an owner

    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if

    ///  `_owner` is the zero address, representing invalid NFTs.

    /// @param _owner An address where we are interested in NFTs owned by them

    /// @param _index A counter less than `balanceOf(_owner)`

    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,

    ///   (sort order not specified)

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);



    /// @notice Transfers a Cutie to another address. When transferring to a smart

    ///  contract, ensure that it is aware of ERC-721 (or

    ///  BlockchainCuties specifically), otherwise the Cutie may be lost forever.

    /// @param _to The address of the recipient, can be a user or contract.

    /// @param _cutieId The ID of the Cutie to transfer.

    function transfer(address _to, uint256 _cutieId) external;

}



pragma solidity ^0.4.23;



pragma solidity ^0.4.23;





/**

 * @title ERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */

interface ERC165 {



    /**

     * @notice Query if a contract implements an interface

     * @param _interfaceId The interface identifier, as specified in ERC-165

     * @dev Interface identification is specified in ERC-165. This function

     * uses less than 30,000 gas.

     */

    function supportsInterface(bytes4 _interfaceId)

    external

    view

    returns (bool);

}





/**

    @title ERC-1155 Multi Token Standard

    @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1155.md

    Note: The ERC-165 identifier for this interface is 0xd9b67a26.

 */

interface IERC1155 /* is ERC165 */ {

    /**

        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).

        The `_operator` argument MUST be msg.sender.

        The `_from` argument MUST be the address of the holder whose balance is decreased.

        The `_to` argument MUST be the address of the recipient whose balance is increased.

        The `_id` argument MUST be the token type being transferred.

        The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.

        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).

        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).

    */

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);



    /**

        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).

        The `_operator` argument MUST be msg.sender.

        The `_from` argument MUST be the address of the holder whose balance is decreased.

        The `_to` argument MUST be the address of the recipient whose balance is increased.

        The `_ids` argument MUST be the list of tokens being transferred.

        The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.

        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).

        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).

    */

    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);



    /**

        @dev MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absense of an event assumes disabled).

    */

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



    /**

        @dev MUST emit when the URI is updated for a token ID.

        URIs are defined in RFC 3986.

        The URI MUST point a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".



        The URI value allows for ID substitution by clients. If the string {id} exists in any URI,

        clients MUST replace this with the actual token ID in hexadecimal form.

    */

    event URI(string _value, uint256 indexed _id);



    /**

        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).

        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).

        MUST revert if `_to` is the zero address.

        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.

        MUST revert on any other error.

        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).

        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).

        @param _from    Source address

        @param _to      Target address

        @param _id      ID of the token type

        @param _value   Transfer amount

        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`

    */

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes _data) external;



    /**

        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).

        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).

        MUST revert if `_to` is the zero address.

        MUST revert if length of `_ids` is not the same as length of `_values`.

        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.

        MUST revert on any other error.

        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).

        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).

        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).

        @param _from    Source address

        @param _to      Target address

        @param _ids     IDs of each token type (order and length must match _values array)

        @param _values  Transfer amounts per token type (order and length must match _ids array)

        @param _data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`

    */

    function safeBatchTransferFrom(address _from, address _to, uint256[] _ids, uint256[] _values, bytes _data) external;



    /**

        @notice Get the balance of an account's Tokens.

        @param _owner  The address of the token holder

        @param _id     ID of the Token

        @return        The _owner's balance of the Token type requested

     */

    function balanceOf(address _owner, uint256 _id) external view returns (uint256);



    /**

        @notice Get the balance of multiple account/token pairs

        @param _owners The addresses of the token holders

        @param _ids    ID of the Tokens

        @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)

     */

    function balanceOfBatch(address[] _owners, uint256[] _ids) external view returns (uint256[] memory);



    /**

        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.

        @dev MUST emit the ApprovalForAll event on success.

        @param _operator  Address to add to the set of authorized operators

        @param _approved  True if the operator is approved, false to revoke approval

    */

    function setApprovalForAll(address _operator, bool _approved) external;



    /**

        @notice Queries the approval status of an operator for a given owner.

        @param _owner     The owner of the Tokens

        @param _operator  Address of authorized operator

        @return           True if the operator is approved, false if not

    */

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}





contract Operators

{

    mapping (address=>bool) ownerAddress;

    mapping (address=>bool) operatorAddress;



    constructor() public

    {

        ownerAddress[msg.sender] = true;

    }



    modifier onlyOwner()

    {

        require(ownerAddress[msg.sender]);

        _;

    }



    function isOwner(address _addr) public view returns (bool) {

        return ownerAddress[_addr];

    }



    function addOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0));



        ownerAddress[_newOwner] = true;

    }



    function removeOwner(address _oldOwner) external onlyOwner {

        delete(ownerAddress[_oldOwner]);

    }



    modifier onlyOperator() {

        require(isOperator(msg.sender));

        _;

    }



    function isOperator(address _addr) public view returns (bool) {

        return operatorAddress[_addr] || ownerAddress[_addr];

    }



    function addOperator(address _newOperator) external onlyOwner {

        require(_newOperator != address(0));



        operatorAddress[_newOperator] = true;

    }



    function removeOperator(address _oldOperator) external onlyOwner {

        delete(operatorAddress[_oldOperator]);

    }



    function withdrawERC20(ERC20 _tokenContract) external onlyOwner

    {

        uint256 balance = _tokenContract.balanceOf(address(this));

        _tokenContract.transfer(msg.sender, balance);

    }



    function approveERC721(ERC721 _tokenContract) external onlyOwner

    {

        _tokenContract.setApprovalForAll(msg.sender, true);

    }



    function approveERC1155(IERC1155 _tokenContract) external onlyOwner

    {

        _tokenContract.setApprovalForAll(msg.sender, true);

    }



    function withdrawEth() external onlyOwner

    {

        if (address(this).balance > 0)

        {

            msg.sender.transfer(address(this).balance);

        }

    }

}



pragma solidity ^0.4.23;



/// @author https://BlockChainArchitect.iocontract Bank is CutiePluginBase

contract PluginInterface

{

    /// @dev simply a boolean to indicate this is the contract we expect to be

    function isPluginInterface() public pure returns (bool);



    function onRemove() public;



    /// @dev Begins new feature.

    /// @param _cutieId - ID of token to auction, sender must be owner.

    /// @param _parameter - arbitrary parameter

    /// @param _seller - Old owner, if not the message sender

    function run(

        uint40 _cutieId,

        uint256 _parameter,

        address _seller

    )

    public

    payable;



    /// @dev Begins new feature, approved and signed by COO.

    /// @param _cutieId - ID of token to auction, sender must be owner.

    /// @param _parameter - arbitrary parameter

    function runSigned(

        uint40 _cutieId,

        uint256 _parameter,

        address _owner

    ) external payable;



    function withdraw() external;

}



pragma solidity ^0.4.23;



interface PluginsInterface

{

    function isPlugin(address contractAddress) external view returns(bool);

    function withdraw() external;

    function setMinSign(uint40 _newMinSignId) external;



    function runPluginOperator(

        address _pluginAddress,

        uint40 _signId,

        uint40 _cutieId,

        uint128 _value,

        uint256 _parameter,

        address _sender) external payable;

}



pragma solidity ^0.4.23;



pragma solidity ^0.4.23;



/// @title BlockchainCuties: Collectible and breedable cuties on the Ethereum blockchain.

/// @author https://BlockChainArchitect.io

/// @dev This is the BlockchainCuties configuration. It can be changed redeploying another version.

interface ConfigInterface

{

    function isConfig() external pure returns (bool);



    function getCooldownIndexFromGeneration(uint16 _generation, uint40 _cutieId) external view returns (uint16);

    function getCooldownEndTimeFromIndex(uint16 _cooldownIndex, uint40 _cutieId) external view returns (uint40);

    function getCooldownIndexFromGeneration(uint16 _generation) external view returns (uint16);

    function getCooldownEndTimeFromIndex(uint16 _cooldownIndex) external view returns (uint40);



    function getCooldownIndexCount() external view returns (uint256);



    function getBabyGenFromId(uint40 _momId, uint40 _dadId) external view returns (uint16);

    function getBabyGen(uint16 _momGen, uint16 _dadGen) external pure returns (uint16);



    function getTutorialBabyGen(uint16 _dadGen) external pure returns (uint16);



    function getBreedingFee(uint40 _momId, uint40 _dadId) external view returns (uint256);

}





contract CutieCoreInterface

{

    function isCutieCore() pure public returns (bool);



    ConfigInterface public config;



    function transferFrom(address _from, address _to, uint256 _cutieId) external;

    function transfer(address _to, uint256 _cutieId) external;



    function ownerOf(uint256 _cutieId)

        external

        view

        returns (address owner);



    function getCutie(uint40 _id)

        external

        view

        returns (

        uint256 genes,

        uint40 birthTime,

        uint40 cooldownEndTime,

        uint40 momId,

        uint40 dadId,

        uint16 cooldownIndex,

        uint16 generation

    );



    function getGenes(uint40 _id)

        public

        view

        returns (

        uint256 genes

    );





    function getCooldownEndTime(uint40 _id)

        public

        view

        returns (

        uint40 cooldownEndTime

    );



    function getCooldownIndex(uint40 _id)

        public

        view

        returns (

        uint16 cooldownIndex

    );





    function getGeneration(uint40 _id)

        public

        view

        returns (

        uint16 generation

    );



    function getOptional(uint40 _id)

        public

        view

        returns (

        uint64 optional

    );





    function changeGenes(

        uint40 _cutieId,

        uint256 _genes)

        public;



    function changeCooldownEndTime(

        uint40 _cutieId,

        uint40 _cooldownEndTime)

        public;



    function changeCooldownIndex(

        uint40 _cutieId,

        uint16 _cooldownIndex)

        public;



    function changeOptional(

        uint40 _cutieId,

        uint64 _optional)

        public;



    function changeGeneration(

        uint40 _cutieId,

        uint16 _generation)

        public;



    function createSaleAuction(

        uint40 _cutieId,

        uint128 _startPrice,

        uint128 _endPrice,

        uint40 _duration

    )

    public;



    function getApproved(uint256 _tokenId) external returns (address);

    function totalSupply() view external returns (uint256);

    function createPromoCutie(uint256 _genes, address _owner) external;

    function checkOwnerAndApprove(address _claimant, uint40 _cutieId, address _pluginsContract) external view;

    function breedWith(uint40 _momId, uint40 _dadId) public payable returns (uint40);

    function getBreedingFee(uint40 _momId, uint40 _dadId) public view returns (uint256);

    function restoreCutieToAddress(uint40 _cutieId, address _recipient) external;

    function createGen0Auction(uint256 _genes, uint128 startPrice, uint128 endPrice, uint40 duration) external;

    function createGen0AuctionWithTokens(uint256 _genes, uint128 startPrice, uint128 endPrice, uint40 duration, address[] allowedTokens) external;

    function createPromoCutieWithGeneration(uint256 _genes, address _owner, uint16 _generation) external;

    function createPromoCutieBulk(uint256[] _genes, address _owner, uint16 _generation) external;

}





contract Plugins is Operators, PluginsInterface

{

    event SignUsed(uint40 signId, address sender);

    event MinSignSet(uint40 signId);



    uint40 public minSignId;

    mapping(uint40 => address) public usedSignes;

    address public signerAddress;



    mapping(address => PluginInterface) public plugins;

    PluginInterface[] public pluginsArray;

    CutieCoreInterface public coreContract;



    function setSigner(address _newSigner) external onlyOwner {

        signerAddress = _newSigner;

    }



    /// @dev Sets the reference to the plugin contract.

    /// @param _address - Address of plugin contract.

    function addPlugin(address _address) external onlyOwner

    {

        PluginInterface candidateContract = PluginInterface(_address);



        // verify that a contract is what we expect

        require(candidateContract.isPluginInterface());



        // Set the new contract address

        plugins[_address] = candidateContract;

        pluginsArray.push(candidateContract);

    }



    /// @dev Remove plugin and calls onRemove to cleanup

    function removePlugin(address _address) external onlyOwner

    {

        plugins[_address].onRemove();

        delete plugins[_address];



        uint256 kindex = 0;

        while (kindex < pluginsArray.length)

        {

            if (address(pluginsArray[kindex]) == _address)

            {

                pluginsArray[kindex] = pluginsArray[pluginsArray.length-1];

                pluginsArray.length--;

            }

            else

            {

                kindex++;

            }

        }

    }



    /// @dev Common function to be used also in backend

    function hashArguments(

        address _pluginAddress,

        uint40 _signId,

        uint40 _cutieId,

        uint128 _value,

        uint256 _parameter)

    public pure returns (bytes32 msgHash)

    {

        msgHash = keccak256(abi.encode(_pluginAddress, _signId, _cutieId, _value, _parameter));

    }



    /// @dev Common function to be used also in backend

    function getSigner(

        address _pluginAddress,

        uint40 _signId,

        uint40 _cutieId,

        uint128 _value,

        uint256 _parameter,

        uint8 _v,

        bytes32 _r,

        bytes32 _s

    )

    public pure returns (address)

    {

        bytes32 msgHash = hashArguments(_pluginAddress, _signId, _cutieId, _value, _parameter);

        return ecrecover(msgHash, _v, _r, _s);

    }



    /// @dev Common function to be used also in backend

    function isValidSignature(

        address _pluginAddress,

        uint40 _signId,

        uint40 _cutieId,

        uint128 _value,

        uint256 _parameter,

        uint8 _v,

        bytes32 _r,

        bytes32 _s

    )

    public

    view

    returns (bool)

    {

        return getSigner(_pluginAddress, _signId, _cutieId, _value, _parameter, _v, _r, _s) == signerAddress;

    }



    /// @dev Put a cutie up for plugin feature with signature.

    ///  Can be used for items equip, item sales and other features.

    ///  Signatures are generated by Operator role.

    function runPluginSigned(

        address _pluginAddress,

        uint40 _signId,

        uint40 _cutieId,

        uint128 _value,

        uint256 _parameter,

        uint8 _v,

        bytes32 _r,

        bytes32 _s

    )

        external

//        whenNotPaused

        payable

    {

        require (isValidSignature(_pluginAddress, _signId, _cutieId, _value, _parameter, _v, _r, _s));



        require(address(plugins[_pluginAddress]) != address(0));



        require (usedSignes[_signId] == address(0));



        require (_signId >= minSignId);

        // value can also be zero for free calls



        require (_value <= msg.value);



        usedSignes[_signId] = msg.sender;



        if (_cutieId > 0)

        {

            // If cutie is already on any auction or in adventure, this will throw

            // as it will be owned by the other contract.

            // If _cutieId is 0, then cutie is not used on this plugin.



            require(coreContract.ownerOf(_cutieId) == msg.sender);

        }



        emit SignUsed(_signId, msg.sender);



        // Plugin contract throws if inputs are invalid and clears

        // transfer after escrowing the cutie.

        plugins[_pluginAddress].runSigned.value(_value)(

            _cutieId,

            _parameter,

            msg.sender

        );

    }



    /// @dev Put a cutie up for plugin feature as Operator.

    ///  Can be used for items equip, item sales and other features.

    ///  Signatures are generated by Operator role.

    function runPluginOperator(

        address _pluginAddress,

        uint40 _signId,

        uint40 _cutieId,

        uint128 _value,

        uint256 _parameter,

        address _sender)

        external payable onlyOperator

    {

        require(address(plugins[_pluginAddress]) != address(0));



        require (usedSignes[_signId] == address(0));



        require (_signId >= minSignId);

        // value can also be zero for free calls





        require (_value <= msg.value);



        usedSignes[_signId] = _sender;



        emit SignUsed(_signId, _sender);





        // Plugin contract throws if inputs are invalid and clears

        // transfer after escrowing the cutie.

        plugins[_pluginAddress].runSigned.value(_value)(

            _cutieId,

            _parameter,

            _sender

        );

    }



    function setSignAsUsed(uint40 _signId, address _sender) external onlyOperator

    {

        usedSignes[_signId] = _sender;

        emit SignUsed(_signId, _sender);

    }



    /// @dev Sets minimal signId, than can be used.

    ///       All unused signatures less than signId will be cancelled on off-chain server

    ///       and unused items will be transfered back to owner.

    function setMinSign(uint40 _newMinSignId) external onlyOperator

    {

        require (_newMinSignId > minSignId);

        minSignId = _newMinSignId;

        emit MinSignSet(minSignId);

    }



    /// @dev Put a cutie up for plugin feature.

    function runPlugin(

        address _pluginAddress,

        uint40 _cutieId,

        uint256 _parameter

    ) external payable

    {

        // If cutie is already on any auction or in adventure, this will throw

        // because it will be owned by the other contract.

        // If _cutieId is 0, then cutie is not used on this feature.

        require(address(plugins[_pluginAddress]) != address(0));

        if (_cutieId > 0)

        {

            coreContract.checkOwnerAndApprove(msg.sender, _cutieId, _pluginAddress);

        }



        // Plugin contract throws if inputs are invalid and clears

        // transfer after escrowing the cutie.

        plugins[_pluginAddress].run.value(msg.value)(

            _cutieId,

            _parameter,

            msg.sender

        );

    }



    function isPlugin(address contractAddress) external view returns(bool)

    {

        return address(plugins[contractAddress]) != address(0);

    }



    function setup(address _address) external onlyOwner

    {

        coreContract = CutieCoreInterface(_address);

    }



    function withdraw() external

    {

        require(

            msg.sender == address(coreContract) ||

            isOwner(msg.sender)

        );

        for (uint32 i = 0; i < pluginsArray.length; ++i)

        {

            pluginsArray[i].withdraw();

        }

    }

}