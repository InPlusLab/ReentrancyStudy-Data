pragma solidity ^0.4.24;
import "./SafeMath.sol";

contract ERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract ERC721  {
    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


contract Moldex721New {
    using SafeMath for uint256;

    //¥³¥ó¥È¥é¥¯¥Èowner
    address public owner;
    // fee¤òÊÜ¤±È¡¤ëaccount
    address public feeAccount;
    // contract admins
    mapping (address => bool) admins;
    // tradeœg¤ß¤Îorder¤òÓ›åh
    mapping (bytes32 => bool) public traded;
    // is initialize proxy
    bool internal _initialized;
    // Events
		event Trade(address indexed ownerAddress, address indexed receiverAddress, address indexed sellTokenAddress, uint256 tokenId, uint256 amount, uint256 fee, uint256 _now);
    // onlyOwner modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _; 
    }

    // Admin Validation msg.sender should be owner or admin
    modifier onlyAdmin {
        if(msg.sender != owner && !admins[msg.sender]) revert();
        _;
    }

    constructor
    (
        address _feeAccount
    ) 
    public
    {
        owner = msg.sender;
        admins[msg.sender] = true;
        feeAccount = _feeAccount;
    }

    function initialize(address _owner, address _feeAccount) public {
        require(!_initialized);
        owner = _owner;
        admins[_owner] = true;
        feeAccount = _feeAccount;
        _initialized = true;
   }


    function setOwner
    (
        address _owner
    )
    external onlyOwner
    {
        owner = _owner;
    }

    function setAdmin
    (
        address admin,
        bool isAdmin
    )
    external onlyOwner
    {
        admins[admin] = isAdmin;
    }

    function trade
    (
        uint256[2] tradeValues,
        address[4] tradeAddresses,
        uint8[2] v,
        bytes32[4] rs
    )
    external onlyAdmin
    returns (bool)
    {
        /* 
        params
            tradeValues[0] erc721 token id
            tradeValues[1] mold amount
        */
        /* 
            tradeAddresses[0] erc721 token address
            tradeAddresses[1] mold token address
            tradeAddresses[2] erc721 token owner address
            tradeAddresses[3] erc721 receiver address / mold token owner
        */
        /*
            rs[0] erc721 token owner recovery r
            rs[1] erc721 token owner recovery s
            rs[2] dex admin recovery r
            rs[3] dex admin recovery s
        */
        /*
            v[0] erc721 token owner recovery v
            v[1] dex admin recovery v
         */
         bytes32 orderHash = keccak256(abi.encodePacked(
             address(this), // dex address
             tradeAddresses[0], // 721 token address
             tradeAddresses[2], // 721 token owner address
             tradeValues[0], // token Id
             tradeAddresses[1], //  moldToken Address
             tradeValues[1] // mold amount
         ));

        bytes32 tradeHash = keccak256(abi.encodePacked(
            orderHash,
            tradeAddresses[3] // 721 token receiver address
        ));
         // check maker signature is valid
        require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v[0], rs[0], rs[1]) == tradeAddresses[2]);
        require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", tradeHash)), v[1], rs[2], rs[3]) == tradeAddresses[3]);
        // transfer mold
        uint256 tradeAmount = tradeValues[1] * 95 / 100;
        uint256 feeAmount = tradeValues[1] * 5 / 100;
        if (!ERC20(tradeAddresses[1]).transferFrom(tradeAddresses[3], tradeAddresses[2], tradeAmount)) revert();
        if (!ERC20(tradeAddresses[1]).transferFrom(tradeAddresses[3], feeAccount,feeAmount)) revert();
        // transfer 721 token
        ERC721(tradeAddresses[0]).transferFrom(tradeAddresses[2], tradeAddresses[3], tradeValues[0]);
        emit Trade(tradeAddresses[2], tradeAddresses[3] , tradeAddresses[0], tradeValues[0], tradeAmount, feeAmount, now);
    }
}
