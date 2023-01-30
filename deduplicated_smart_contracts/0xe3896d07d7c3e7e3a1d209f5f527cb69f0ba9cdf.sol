/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

library SafeMath {
    // *
    function mul(uint256 a,uint256 b) internal pure returns (uint256 c) {
        if(a == 0){
            return 0;
        }
        
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    // /
    function div(uint256 a, uint256 b) internal pure returns (uint256 c){
        assert(b > 0);
        c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
    
    // -
    function sub(uint256 a,uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    // +
    function add(uint256 a, uint256 b) internal pure returns (uint256 c){
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract CommonConstants {
    bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
}


// ERC-165 identifier interface is 0x4e2312e0
interface ERC1155TokenReceiver{
    function onERC1155Received(address _operator,address _from,uint256 _id,uint256 _value,bytes calldata _data) external returns(bytes4);
    function onERC1155BatchReceived(address _operator,address _from,uint256[] calldata _ids,uint256[] calldata _values,bytes calldata _data) external returns(bytes4);
}

interface IERC165 {
    //Returns true if this contract implements the interface define by 'interfaceId'
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

//ERC-1155 Multi Token Standard
contract IERC1155 is IERC165 {
    //Either 'TransferSingle' or 'TransferBatch' MUST emit when tokens are transferred,including zero value transfers as well as minting of buring
    event TransferSingle(address indexed _operator,address indexed _from,address indexed _to,uint256 _id,uint256 _value);
    
    event TransferBatch(address indexed _operator,address indexed _from,address indexed _to,uint256[] _ids, uint256[] _values);
    
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    
    // MUST emit when the URI is updated for a token ID
    // URIs are defined in RFC 3986
    // The URI MUST point a JSON file that conforms to the 'ERC-1155 Metadata URI JSON Schema'.
    event URI(string _value,uint256 indexed _id);
    
    // Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
    function safeTransferFrom(address _from,address _to,uint256 _id,uint256 _value,bytes calldata _data) external;
    
    // Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
    function safeBatchTransferFrom(address _from,address _to,uint256[] calldata _ids,uint256[] calldata _values,bytes calldata _data) external;
    
    // Get the balance of an account's Tokens
    function balanceOf(address _owner,uint256 _id) external view returns (uint256);
    
    // Get the balance of multiple account/token pairs
    function balanceOfBatch(address[] calldata _owner,uint256[] calldata _ids) external view returns (uint256[] memory);
    
    // Enable or disable approval for a third party ("operator") to manager all of the caller's tokens
    function setApprovalForAll(address _operator,bool _approved) external;
    
    //Queries the approval status of an operator for a given owner
    function isApprovedForAll(address _owner,address _operator) external view returns (bool);    
}

// Implementation of the {IERC165} interface
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
    mapping(bytes4=>bool) private _supportedInterfaces;
    
    constructor() internal {
        // Derived contract need only register support for their own interface
        _registerInterface(_INTERFACE_ID_ERC165);
    }
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }
    
    // Registers the contract as an implementer of the interface defined by 'interfaceId'
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff,"ERC165:invalid interface id");
        _supportedInterfaces[interfaceId] == true;
    }
}

// Collection of function related to the address type
library Address{
    // Returns true if 'account' is a contract
    function isContract(address account) internal view returns (bool) {
         // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    //Converts an 'address' info 'address payable'
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    
    //Replacement for Solidity's 'transfer':sends 'amount' wei to 'recipient',forwarding all available gas and reverting on erros;
    function sendValue(address payable recipient,uint256 amount) internal {
        require(address(this).balance >= amount,"Address: insufficient balance");
        
        (bool success,) = recipient.call.value(amount)("");
        require(success,"Address: unable to send value,recipient may have reverted");
    }
}

// A sample implementation of core ERC1155 function
contract ERC1155 is IERC1155,ERC165, CommonConstants{
    using SafeMath for uint256;
    using Address for address;
    
    // id=>(owner => balance)
    mapping(uint256 => mapping(address => uint256)) internal balances;
    
    // owner => (operator => approved)
    mapping (address => mapping(address => bool)) internal operatorApproval;
    
/////////////////////////////////////////// ERC165 //////////////////////////////////////////////
     /*
        bytes4(keccak256("safeTransferFrom(address,address,uint256,uint256,bytes)")) ^
        bytes4(keccak256("safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)")) ^
        bytes4(keccak256("balanceOf(address,uint256)")) ^
        bytes4(keccak256("balanceOfBatch(address[],uint256[])")) ^
        bytes4(keccak256("setApprovalForAll(address,bool)")) ^
        bytes4(keccak256("isApprovedForAll(address,address)"));
    */
    bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;
    
/////////////////////////////////////////// CONSTRUCTOR //////////////////////////////////////////
    constructor() public {
        _registerInterface(INTERFACE_SIGNATURE_ERC1155);
    }
    
/////////////////////////////////////////// ERC1155 //////////////////////////////////////////////

    // Transfers '_value' amount of an '_id' from the '_from' address to the '_to' address specified
    function safeTransferFrom(address _from, address _to,uint256 _id,uint256 _value,bytes calldata _data) external {
        require(_to != address(0x0),"Address: _to must be non-zero");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true,"Approval: need operator approval for 3rd party transfers");
        
        // SafeMath will throw with insuficient funds _from or if _id is not valid(balance will be zero)
        balances[_id][_from] = balances[_id][_from].sub(_value);
        balances[_id][_to] = _value.add(balances[_id][_to]);
        
        // MUST emit event
        emit TransferSingle(msg.sender,_from,_to,_id,_value);
        
        if(_to.isContract()){
            _doSafeTransferAcceptanceCheck(msg.sender, _from, _to, _id, _value, _data);
        }
    }
    
    // Transfers '_values' amount(s) of '_ids' from the '_from' address to the '_to' address specified
    function safeBatchTransferFrom(address _from,address _to,uint256[] calldata _ids,uint256[] calldata _values,bytes calldata _data) external {
        //MUST throw on error
        require(_to != address(0x0),"Address: _to must be non-zero");
        require(_ids.length == _values.length,"_ids and _values array length must match");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true,"Approval: need operator approval for 3rd party transfers");
        
        for (uint256 i = 0; i < _ids.length; ++ i){
            uint256 id = _ids[i];
            uint256 value = _values[i];
            
            //SafeMath will throw with insuficient funds _from or if _id is not valid(valance will be zero)
            balances[id][_from] = balances[id][_from].sub(value);
            balances[id][_to] = value.add(balances[id][_to]);
        }
        
        
        emit TransferBatch(msg.sender,_from,_to,_ids,_values);
        
        if(_to.isContract()){
            _doSafeBatchTransferAcceptanceCheck(msg.sender, _from, _to, _ids, _values, _data);
        }
    }
    
    // Get the balance of an account's tokens
    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        return balances[_id][_owner];
    }

    // Get the balance of multiple account/token pairs
    function balanceOfBatch(address[] calldata _owners,uint256[] calldata _ids) external view returns (uint256[] memory) {
        require(_owners.length == _ids.length,"_owners and _ids array length must match");
        
        uint256[] memory balances_ = new uint256[](_owners.length);
        
        for (uint256 i = 0; i < _owners.length; ++ i){
            balances_[i] = balances[_ids[i]][_owners[i]];
        }
        return balances_;
    }

    // Enable or disable approval for a third party("operator") to manage all of the caller's token
    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApproval[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender,_operator,_approved);
    }
    
    // Queries the approval status of an operator for a given owner
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorApproval[_owner][_operator];
    }
    
/////////////////////////////////////////// Internal //////////////////////////////////////////////
    function _doSafeTransferAcceptanceCheck(address _operator,address _from,address _to,uint256 _id,uint256 _value,bytes memory _data) internal {
        require(ERC1155TokenReceiver(_to).onERC1155Received(_operator,_from,_id,_value,_data) == ERC1155_ACCEPTED,"contract returned an unknown value from onERC1155Received");
    }
    
    function _doSafeBatchTransferAcceptanceCheck(address _operator,address _from,address _to, uint256[] memory _ids,uint256[] memory _values,bytes memory _data) internal {
        require(ERC1155TokenReceiver(_to).onERC1155BatchReceived(_operator,_from,_ids,_values,_data) == ERC1155_BATCH_ACCEPTED,"contract returned an unknown value from onERC1155BatchReceived");
    }
    
}


library UintLibrary {
    function toString(uint256 _i) internal pure returns (string memory) {
        if(_i == 0){
            return "0";
        }
        
        uint j = _i;
        uint len;
        while(j != 0) {
            len ++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len -1;
        
        while(_i != 0){
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        
        return string(bstr);
    }
}


library StringLibrary {
    using UintLibrary for uint256;
    
    function append(string memory _a,string memory _b) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory bab = new bytes(_ba.length + _bb.length);
        
        uint k = 0;
        for(uint i = 0;i < _ba.length; i ++)bab[k++] = _ba[i];
        for(uint i = 0;i < _bb.length; i ++)bab[k++] = _bb[i];
        return string(bab);
    }
    
    function append(string memory _a,string memory _b,string memory _c) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory babc = new bytes(_ba.length + _bb.length + _bc.length);
        
        uint k = 0;
        for(uint i = 0; i < _ba.length; i ++) babc[k ++] = _ba[i];
        for(uint i = 0; i < _bb.length; i ++) babc[k ++] = _bb[i];
        for(uint i = 0; i < _bc.length; i ++) babc[k ++] = _bc[i];
        
        return string(babc);
    }
    
    function recover(string memory message, uint8 v, bytes32 r,bytes32 s) internal pure returns (address) {
        bytes memory msgBytes = bytes(message);
        bytes memory fullMessage = concat(
            bytes("\x19Ethereum Signed Message:\n"),
            bytes(msgBytes.length.toString()),
            msgBytes,
            new bytes(0), new bytes(0), new bytes(0),new bytes(0)
        );
        
        return ecrecover(keccak256(fullMessage),v,r,s);
    }
    
    // Merging multiple strings
    function concat(bytes memory _ba,bytes memory _bb,bytes memory _bc,bytes memory _bd,bytes memory _be, bytes memory _bf,bytes memory _bg) internal pure returns(bytes memory) {
        bytes memory resultBytes = new bytes(_ba.length + _bb.length + _bc.length + _bd.length + _be.length + _bf.length + _bg.length);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i ++) resultBytes[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i ++) resultBytes[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i ++) resultBytes[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i ++) resultBytes[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i ++) resultBytes[k++] = _be[i];
        for (uint i = 0; i < _bf.length; i ++) resultBytes[k++] = _bf[i];
        for (uint i = 0; i < _bg.length; i ++) resultBytes[k++] = _bg[i];

        return resultBytes;   
    }
}

contract HasContractURI is ERC165 {
    string public contractURI;
    
     /*
     * bytes4(keccak256('contractURI()')) == 0xe8a3d485
     */
    bytes4 private constant _INTERFACT_ID_CONTRACT_URI = 0xe8a3d485;
    
    constructor(string memory _contractURI) public {
        contractURI = _contractURI;
        _registerInterface(_INTERFACT_ID_CONTRACT_URI);
    }
    
    // Internal function to set the contract URI
    function _setContractURI(string memory _contractURI) internal {
        contractURI = _contractURI;
    }
}

contract HasTokenURI {
    using StringLibrary for string;
    
    // Token URI prefix 
    string public tokenURIPrefix;
    
    // Optional mapping for token URIs;
    mapping(uint256 => string) private _tokenURIs;
    
    constructor(string memory _tokenURIPrefix) public {
        tokenURIPrefix = _tokenURIPrefix;
    }
    
    // Returns an URI for a given token ID
    function _tokenURI(uint256 tokenId) internal view returns (string memory) {
        return tokenURIPrefix.append(_tokenURIs[tokenId]);
    }
    
    // Internal function to set the token URI for a given token.Reverts if the token ID does not exist.
    function _setTokenURI(uint256 tokenId,string memory uri) internal {
        _tokenURIs[tokenId] = uri;
    }
    
    // Internal function to set the token URI prefix
    function _setTokenURIPrefix(string memory _tokenURIPrefix) internal {
        tokenURIPrefix = _tokenURIPrefix;
    }
    
    function _clearTokenURI(uint256 tokenId) internal {
        if(bytes(_tokenURIs[tokenId]).length != 0){
            delete _tokenURIs[tokenId];
        }
    }
}

// Provider information about the current execution context, including the sender of the transaction and its data.
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying an instance of this contract,which 
    // should be used via inheritance.
    constructor() internal {}
    
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

// Contract module which providers a basic access control mechanism, where there is an account (an owner) that
// can be granted exclusive access to specific functions.
contract Ownable is Context {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Initializes the contract setting the deployer as the initial owner;
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    // Returns the address of the current owner
    function owner() public view returns (address) {
        return _owner;
    }
    
    // Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(isOwner(),"Ownable: caller is not the owner");
        _;
    }
    
    // Returns true is the caller is the current owner.
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    
    // Leaves the contract without owner.
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner,address(0));
        _owner = address(0);
    }
    
    // Transfers ownership of the contract to a new account
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0x0),"Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner,newOwner);
        _owner = newOwner;
    }
}

// The ERC-165 identifier for this interface is 0x0e89341c
interface IERC1155Metadata_URI {
    // a distinct uniform resource identifier (URI) for a given token.
    // the URI may point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
    function uri(uint256 _id) external view returns (string memory);
}

// The ERC-165 identifier for this interface is 0x0e89341c.
contract ERC1155Metadata_URI is IERC1155Metadata_URI, HasTokenURI {
    constructor(string memory _tokenURIPrefix) HasTokenURI(_tokenURIPrefix) public { }
    
    function uri(uint256 _id) external view returns (string memory) {
        return _tokenURI(_id);
    }
}

contract HasSecondarySaleFees is ERC165 {
    event SecondarySaleFees(uint256 tokenId,address[] recipient,uint[] bps);
    
    /*
     * bytes4(keccak256('getFeeBps(uint256)')) == 0x0ebd4c7f
     * bytes4(keccak256('getFeeRecipients(uint256)')) == 0xb9c4d9fb
     *
     * => 0x0ebd4c7f ^ 0xb9c4d9fb == 0xb7799584
     */
    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;
    
    constructor() public {
        _registerInterface(_INTERFACE_ID_FEES);
    }
    
    function getFeeRecipients(uint256 id) public view returns (address payable[] memory);
    function getFeeBps(uint256 id) public view returns (uint[] memory);
}

contract ERC1155Base is HasSecondarySaleFees,Ownable,ERC1155Metadata_URI,HasContractURI,ERC1155{
    struct Fee {
        address payable recipient;
        uint256 value;
    }
    
    // id => creator
    mapping(uint256 => address) public creators;
    // id => fees
    mapping(uint256 => Fee[]) public fees;
    
    constructor(string memory contractURI, string memory tokenURIPrefix) HasContractURI(contractURI) ERC1155Metadata_URI(tokenURIPrefix) public {
        
    }
    
    function getFeeRecipients(uint256 id) public view returns (address payable[] memory) {
        Fee[] memory _fees = fees[id];
        address payable[] memory result = new address payable[](_fees.length);
        for(uint i = 0; i < _fees.length; i ++){
            result[i] = _fees[i].recipient;
        }
        return result;
    }
    
    function getFeeBps(uint256 id) public view returns (uint[] memory) {
        Fee[] memory _fees = fees[id];
        uint[] memory result = new uint[](_fees.length);
        for(uint i = 0;i < _fees.length; i ++){
            result[i] = _fees[i].value;
        }
        
        return result;
    }
    
    function _mint(uint256 _id,Fee[] memory _fees,uint256 _supply,string memory _uri) internal {
        require(creators[_id] == address(0x0),"Token is already minted");
        require(_supply != 0,"Supply should be positive");
        require(bytes(_uri).length > 0,"uri should be set");
        
        creators[_id] = msg.sender;
        address[] memory recipients = new address[](_fees.length);
        uint[] memory bps = new uint[](_fees.length);
        for (uint i = 0;i < _fees.length; i ++){
            require(_fees[i].recipient != address(0x0),"Recipient should be present");
            require(_fees[i].value != 0,"Fee value should be positive");
            fees[_id].push(_fees[i]);
            recipients[i] = _fees[i].recipient;
            bps[i] = _fees[i].value;
        }
        
        if (_fees.length > 0){
            emit SecondarySaleFees(_id,recipients,bps);
        }
        
        balances[_id][msg.sender] = _supply;
        _setTokenURI(_id,_uri);
        
        emit TransferSingle(msg.sender,address(0x0),msg.sender,_id,_supply);
        emit URI(_uri,_id);
    }
    
    function burn(address _owner, uint256 _id,uint256 _value) external {
        require(_owner == msg.sender || operatorApproval[_owner][msg.sender] == true,"Need operator approva for 3rd party burns");
        
        balances[_id][_owner] = balances[_id][_owner].sub(_value);
        
        emit TransferSingle(msg.sender,_owner,address(0x0),_id,_value);
    }
    
    // Internal function to set the token URI for a given token 
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(creators[tokenId] != address(0x0),"setTokenURI:Token should exist");
        super._setTokenURI(tokenId,uri);
    }
    
    function setTokenURIPrefix(string memory tokenURIPrefix) public onlyOwner {
        super._setTokenURIPrefix(tokenURIPrefix);
    }
    
    function setContractURI(string memory contractURI) public onlyOwner {
        super._setContractURI(contractURI);
    }
}


// library for managing addresses assigned to a Role
library Roles {
    struct Role {
        mapping (address=>bool) bearer;
    }
    
    // Give an account access to this Role
    function add(Role storage role,address account) internal {
        require(!has(role,account),"Roles: account already has role");
        role.bearer[account] = true;
    }
    
    // Remove an account's access to this role
    function remove(Role storage role,address account) internal {
        require(has(role,account),"Roles: account does not have role");
        role.bearer[account] = false;
    }
    
    
    // Check if an account has this role
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0x0),"Roles: account is the zero address");
        return role.bearer[account];
    }
}


contract SignerRole is Context {
    using Roles for Roles.Role;
    
    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);
    
    Roles.Role private _signers;
    
    constructor() internal {
        _addSigner(_msgSender());
    }
    
    modifier onlySigner(){
        require(isSigner(_msgSender()),"SignerRole: caller does not have the Signer role");
        _;
    }
    
    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }
    
    function addSigner(address account) public onlySigner {
        _addSigner(account);
    }
    
    function renounceSigner() public {
        _removeSigner(_msgSender());
    }
    
    function _addSigner(address account) internal {
        _signers.add(account);
    }
    
    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}

contract AntasyToken is Ownable,SignerRole, ERC1155Base {
    string public name;
    string public symbol;
    
    constructor(string memory _name,string memory _symbol,address signer, string memory contractURI,string memory tokenURIPrefix) ERC1155Base(contractURI,tokenURIPrefix) public {
        name = _name;
        symbol = _symbol;
        
        _addSigner(signer);
        _registerInterface(bytes4(keccak256('MINT_WITH_ADDRESS')));
    }
    
    function addSigner(address account) public onlyOwner {
        _addSigner(account);
    }
    
    function removeSigner(address account) public onlyOwner{
        _removeSigner(account);
    }
    
    function mint(uint256 id, Fee[] memory fee,uint256 supply,string memory uri) public {
    //require(isSigner(ecrecover(keccak256(abi.encode(this,id)),v,r,s)),"signer should sign tokenId");
        _mint(id,fee,supply,uri);
    }
}