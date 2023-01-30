/**

 *Submitted for verification at Etherscan.io on 2018-11-15

*/



pragma solidity >0.4.24 <0.5.0;





library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}



library Address {

  function isContract(address account) internal view returns (bool) {

    uint256 size;

    assembly { size := extcodesize(account) }

    return size > 0;

  }

}





contract IERC165{

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}



contract ERC165 is IERC165{

    mapping(bytes4 => bool) internal _supportedInterfaces;

    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

    constructor() public {

        _registerInterface(_InterfaceId_ERC165);

    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool){

        return _supportedInterfaces[interfaceID];

    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);

        _supportedInterfaces[interfaceId] = true;

    }

}



contract IERC721 {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256);

    function ownerOf(uint256 _tokenId) public view returns (address);

    function approve(address _approved, uint256 _tokenId) public payable;

    function getApproved(uint256 _tokenId) public view returns (address);

    function setApprovalForAll(address _operator, bool _approved) public;

    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable;    



}



contract IERC721Receiver {

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4);

}



contract ERC721Receiver is IERC721Receiver {

    function onERC721Received(address _operator, address _from,uint256 _tokenId, bytes _data) public returns(bytes4) {

        return ERC721_RECEIVED;

    }

}



contract ERC721 is IERC721,ERC165 {

    

    using SafeMath for uint256;

    using Address for address;

    

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner

    mapping (uint256 => address) public _tokenOwner;

    // Mapping from token ID to approved address

    mapping (uint256 => address) public _tokenApprovals;

    // Mapping from owner to number of owned token

    mapping (address => uint256) public _ownedTokensCount;

    // Mapping from owner to operator approvals

    mapping (address => mapping (address => bool)) public _operatorApprovals;

    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

    /*

     * 0x80ac58cd ===

     *   bytes4(keccak256('balanceOf(address)')) ^

     *   bytes4(keccak256('ownerOf(uint256)')) ^

     *   bytes4(keccak256('approve(address,uint256)')) ^

     *   bytes4(keccak256('getApproved(uint256)')) ^

     *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^

     *   bytes4(keccak256('isApprovedForAll(address,address)')) ^

     *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^

     *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^

     *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))

    */

    constructor() public {

        _registerInterface(_InterfaceId_ERC721);

    }

    function balanceOf(address _owner) public view returns (uint256){

        require(_owner != address(0));

        return _ownedTokensCount[_owner];

    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];

        require(owner != address(0));

        return owner;

    }

    function approve(address to, uint256 tokenId) public payable {

        address owner = ownerOf(tokenId);

        require(to != owner);

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



        _tokenApprovals[tokenId] = to;

        emit Approval(owner, to, tokenId);

    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId));

        return _tokenApprovals[tokenId];

    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);

        _operatorApprovals[msg.sender][to] = approved;

        emit ApprovalForAll(msg.sender, to, approved);

    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];

    }

    function transferFrom(address from, address to, uint256 tokenId) public payable {

        require(_isApprovedOrOwner(msg.sender, tokenId));

        require(to != address(0));



        _clearApproval(from, tokenId);

        _removeTokenFrom(from, tokenId);

        _addTokenTo(to, tokenId);



        emit Transfer(from, to, tokenId);

    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable {

        // solium-disable-next-line arg-overflow

        safeTransferFrom(from, to, tokenId, "");

    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) public payable {

        transferFrom(from, to, tokenId);

        // solium-disable-next-line arg-overflow

        require(_checkOnERC721Received(from, to, tokenId, _data));

    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];

        return owner != address(0);

    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);

        // Disable solium check because of

        // https://github.com/duaraghav8/Solium/issues/175

        // solium-disable-next-line operator-whitespace

        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));

    }

    function _addTokenTo(address to, uint256 tokenId) internal {

        require(_tokenOwner[tokenId] == address(0));

        _tokenOwner[tokenId] = to;

        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

    }

    function _removeTokenFrom(address from, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from);

        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);

        _tokenOwner[tokenId] = address(0);

    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes _data) internal returns (bool) {

        if (!to.isContract()) {

            return true;

        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);

        return (retval == _ERC721_RECEIVED);

    }

    function _clearApproval(address owner, uint256 tokenId) private {

        require(ownerOf(tokenId) == owner);

        if (_tokenApprovals[tokenId] != address(0)) {

            _tokenApprovals[tokenId] = address(0);

        }

    }

    

}



contract BTCCtoken is ERC721{

    

    

    // Set in case the core contract is broken and an upgrade is required

    address public ooo;

    address public newContractAddress;

    uint256 public totalSupply= 1000000000 ether;

    string public constant name = "btcc";

    string public constant symbol = "btcc";

    

    constructor() public{

        address _owner = msg.sender;

        _tokenOwner[1] = _owner;

        _ownedTokensCount[_owner] = _ownedTokensCount[_owner]+1;

    }

    

   

    

    

    

    }