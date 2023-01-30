/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

interface IERC165 {
    // This function call must use less than 30 000 gas
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// Multi Token Standard
contract IERC1155 is IERC165 {
    event TransferSingle(address indexed _operator,address indexed _from,address indexed _to,uint256 _id,uint256 _value);
    
    event TransferBatch(address indexed _operator,address indexed _from,address indexed _to,uint256[] _ids,uint256[] _values);
    
    // Must emot when approval for a second party/operator address to manager all tokens for an owner address is enabled or disabled
    event ApprovalForAll(address indexed _owner,address indexed _operator,bool _approved);
    
    function safeTransferFrom(address _from,address _to,uint256 _id,uint256 _value,bytes calldata _data) external;
    
    function safeBatchTransferFrom(address _from,address _to,uint256[] calldata _ids,uint256[] calldata _values,bytes calldata _data) external;
    
    // Get the balance of an account's Tokens
    function balanceOf(address _owner,uint256 _id) external view returns (uint256);
    
    function balanceOfBatch(address[] calldata _owners,uint256[] calldata _ids) external view returns (uint256[] memory);

    // Enable or disable approval for a third party to manage all of the caller's tokens.
    function setApprovalForAll(address _operator,bool _approved) external;
    
    // Queries the approval status of an operator for a given owner.
    function isApprovedForAll(address _owner,address _operator) external view returns (bool);
}


library UintLibrary {
    function toString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        
        uint256 j = _i;
        uint256 len;
        
        while(j != 0) {
            len ++;
            j /= 10;
        }
        
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while(_i != 0){
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
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
        
        uint256 k = 0;
        
        for (uint256 i = 0;i < _ba.length; i ++) bab[k ++] = _ba[i];
        for (uint256 i = 0;i < _bb.length; i ++) bab[k ++] = _bb[i];
        
        return string(bab);
    }
    
    function append(string memory _a,string memory _b,string memory _c) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory babc = new bytes(_ba.length + _bb.length + _bc.length);
        
        uint256 k = 0;
        for (uint256 i = 0;i < _ba.length; i ++) babc[k ++] = _ba[i];
        for (uint256 i = 0;i < _bb.length; i ++) babc[k ++] = _bb[i];
        for (uint256 i = 0;i < _bc.length; i ++) babc[k ++] = _bc[i];

        return string(babc);
    }
    
    function recover(string memory message, uint8 v, bytes32 r,bytes32 s) internal pure returns (address) {
        bytes memory msgBytes = bytes(message);
        bytes memory fullMessage = concat(bytes("\x19Ethereum Signed Message:\n"),bytes(msgBytes.length.toString()),msgBytes,new bytes(0),new bytes(0),new bytes(0), new bytes(0));
        return ecrecover(keccak256(fullMessage),v,r,s);
    }
    
    function concat(bytes memory _ba,bytes memory _bb,bytes memory _bc,bytes memory _bd,bytes memory _be,bytes memory _bf,bytes memory _bg) internal pure returns (bytes memory){
        bytes memory resultBytes = new bytes(_ba.length + _bb.length + _bc.length + _bd.length + _be.length + _bf.length + _bg.length);
        
        uint256 k = 0;
        
        for (uint256 i = 0; i < _ba.length; i ++) resultBytes[k ++] = _ba[i];
        for (uint256 i = 0; i < _bb.length; i ++) resultBytes[k ++] = _bb[i];
        for (uint256 i = 0; i < _bc.length; i ++) resultBytes[k ++] = _bc[i];
        for (uint256 i = 0; i < _bd.length; i ++) resultBytes[k ++] = _bd[i];
        for (uint256 i = 0; i < _be.length; i ++) resultBytes[k ++] = _be[i];
        for (uint256 i = 0; i < _bf.length; i ++) resultBytes[k ++] = _bf[i];
        for (uint256 i = 0; i < _bg.length; i ++) resultBytes[k ++] = _bg[i];

        return resultBytes;
    }
}

library AddressLibrary {
    function toString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(_addr));
        
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        
        for (uint256 i = 0; i < 20; i ++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}

contract Context {
    constructor() internal {}
    
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    
    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
    
    // Initialized the contract setting the deployer as the initial owner
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0),msgSender);
    }
    
    // Returns the address of the current owner.
    function owner() public view returns (address) {
        return _owner;
    }
    
    modifier onlyOwner(){
        require(isOwner(),"Ownable: caller is not the owner");
        _;
    }
    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    
    // Leaves the contract without owner.It will not be possible to call "onlyOwner" function anymore.
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner,address(0));
        _owner = address(0);
    }
    
    // Transfers ownership of the contract to a new account
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),"Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner,newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"SafeMath: addition overflow");
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a,b,"SafeMath: subtraction overflow");
    }
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a,errorMessage);
        uint256 c = a - b;
        return c;
    }
    
    function mul(uint256 a,uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        
        uint256 c = a * b;
        require(c / a == b,"SafeMath: multiplication overflow");
        
        return c;
    }
    
    function div(uint256 a,uint256 b) internal pure returns (uint256) {
        return div(a,b,"SafeMath: division by zero");
    }
    
    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b > 0,errorMessage);
        uint256 c = a / b;
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a,b,"SafeMath: modulo by zero");
    }
    
    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b != 0,errorMessage);
        return a % b;
    }
}

// Implementation of the IERC165 interface
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
    mapping(bytes4 => bool) private _supportedInterfaces;
    
    constructor() internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }
    
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff,"ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract HasSecondarySaleFees is ERC165 {
    event SecondarySaleFees(uint256 tokenId,address[] recipients,uint256[] bps);
    
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
    
    function getFeeBps(uint256 id) public view returns (uint256[] memory);
}

contract AbstractSale is Ownable{
    using UintLibrary for uint256;
    using AddressLibrary for address;
    using StringLibrary for string;
    using SafeMath for uint256;
    
    // HasSecondarySaleFees's interfaceId = 0xb7799584;
    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;
    
    uint256 public buyerFee = 0;
    address payable public beneficiary;
    
    // An ECDSA signature
    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    
    constructor(address payable _beneficiary) public {
        beneficiary = _beneficiary;
    }
    
    function setBuyerFee(uint256 _buyerFee) public onlyOwner {
        buyerFee = _buyerFee;
    }
    
    function setBeneficiary(address payable _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }
    
    function prepareMessage(address token,uint256 tokenId,uint256 price,uint256 fee,uint256 nonce) internal pure returns (string memory){
        string memory result = string(
            strConcat(bytes(token.toString()),bytes(". tokenId: "),bytes(tokenId.toString()),bytes(". price: "),bytes(price.toString()),bytes(". nonce: "),bytes(nonce.toString()))    
        );
        
        if (fee != 0){
            return result.append(". fee: ",fee.toString());
        } else {
            return result;
        }
    }
    
    function prepareBidMessage(
        address token,  //代币合约的地址
        uint256 tokenId,
        uint256 fee,
        uint256 nonce
    ) internal pure returns (string memory) {
        string memory result = string(
            strBidConcat(
                bytes(token.toString()),
                bytes(". tokenId: "),
                bytes(tokenId.toString()),
                bytes(". nonce: "),
                bytes(nonce.toString())
            )
        );
        if (fee != 0) {
            return result.append(". fee: ", fee.toString());
        } else {
            return result;
        }
    }
    
    function strConcat(bytes memory _ba,bytes memory _bb,bytes memory _bc,bytes memory _bd,bytes memory _be,bytes memory _bf,bytes memory _bg) internal pure returns (bytes memory){
        bytes memory resultBytes = new bytes(_ba.length + _bb.length + _bc.length + _bd.length + _be.length + _bf.length + _bg.length);
        
        uint256 k = 0;
        for (uint256 i = 0; i < _ba.length; i ++) resultBytes[k ++] = _ba[i];
        for (uint256 i = 0; i < _bb.length; i ++) resultBytes[k ++] = _bb[i];
        for (uint256 i = 0; i < _bc.length; i ++) resultBytes[k ++] = _bc[i];
        for (uint256 i = 0; i < _bd.length; i ++) resultBytes[k ++] = _bd[i];
        for (uint256 i = 0; i < _be.length; i ++) resultBytes[k ++] = _be[i];
        for (uint256 i = 0; i < _bf.length; i ++) resultBytes[k ++] = _bf[i];
        for (uint256 i = 0; i < _bg.length; i ++) resultBytes[k ++] = _bg[i];
        
        return resultBytes;
    }
    
    function strBidConcat(bytes memory _ba,bytes memory _bb,bytes memory _bc,bytes memory _bd,bytes memory _be) internal pure returns (bytes memory){
        bytes memory resultBytes = new bytes(_ba.length + _bb.length + _bc.length + _bd.length + _be.length );
        
        uint256 k = 0;
        for (uint256 i = 0; i < _ba.length; i ++) resultBytes[k ++] = _ba[i];
        for (uint256 i = 0; i < _bb.length; i ++) resultBytes[k ++] = _bb[i];
        for (uint256 i = 0; i < _bc.length; i ++) resultBytes[k ++] = _bc[i];
        for (uint256 i = 0; i < _bd.length; i ++) resultBytes[k ++] = _bd[i];
        for (uint256 i = 0; i < _be.length; i ++) resultBytes[k ++] = _be[i];
       
        
        return resultBytes;
    }
    
    function transferEther(IERC165 token,uint256 tokenId,address payable owner,uint256 total,uint256 sellerFee) internal {
        // The remaining amount after deducting the handling fee
        uint256 value = transferFeeToBeneficiary(total,sellerFee);
        
        // if nft contaact support HasSecondarySaleFees
        
        if (token.supportsInterface(_INTERFACE_ID_FEES)){
            HasSecondarySaleFees withFees = HasSecondarySaleFees(address(token));
            address payable[] memory recipients = withFees.getFeeRecipients(tokenId);
            uint256[] memory fees = withFees.getFeeBps(tokenId);
            require(fees.length == recipients.length);
            for(uint256 i = 0; i < fees.length; i ++) {
                (uint256 newValue,uint256 current) = subFee(value,total.mul(fees[i]).div(10000));
                value = newValue;
                recipients[i].transfer(current);
            }
        }
        owner.transfer(value);
        
    }
 
    function transferFeeToBeneficiary(uint256 total, uint256 sellerFee) internal returns (uint256) {
        (uint256 value,uint256 sellerFeeValue) = subFee(total,total.mul(sellerFee).div(10000));
        
        uint256 buyerFeeValue = total.mul(buyerFee).div(10000);
        uint256 beneficiaryFee = buyerFeeValue.add(sellerFeeValue);
        if (beneficiaryFee > 0) {
            beneficiary.transfer(beneficiaryFee);
        }
        return value;
    }
    
    function subFee(uint256 value,uint256 fee) internal pure returns (uint256 newValue,uint256 realFee) {
        if (value > fee) {
            newValue = value - fee;
            realFee = fee;
        } else {
            newValue = 0;
            realFee = value;
        }
    }
}

contract IERC721 is IERC165 {
    event Transfer(address indexed from,address indexed to,uint256 indexed tokenId);
    event Approval(address indexed owner,address indexed approved,uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);
    
    function balanceOf(address owner) public view returns (uint256 balance);
    
    function ownerOf(uint256 tokenId) public view returns (address owner);
    
    function safeTransferFrom(address from,address to,uint256 tokenId) public;
    
    function transferFrom(address from,address to,uint256 tokenId) public;
    
    function approve(address to,uint256 tokenId) public;
    
    function getApproved(uint256 tokenId) public view returns (address operator);
    
    function setApprovalForAll(address operator,bool _approved) public;
    
    function isApprovedForAll(address owner,address operator) public view returns (bool);
    
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory data) public;
}


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }
    
    function add(Role storage role,address account) internal {
        require(!has(role,account),"Roles:account already has role");
        role.bearer[account] = true;
    }
    
    function remove(Role storage role,address account) internal {
        require(has(role,account), "Roles: account does not have role");
        role.bearer[account] = false;
    }
    
    function has(Role storage role,address account) internal view returns (bool){
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract OperatorRole is Context {
    using Roles for Roles.Role;
    
    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);
    
    Roles.Role private _operators;
    
    constructor() internal {}
    
    modifier onlyOperator(){
        require(isOperator(_msgSender()),"OperatorRole: caller does not have the operator role");
        _;
    }
    
    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }
    
    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }
    
    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }
    
}

contract OwnableOperatorRole is Ownable,OperatorRole {
    function addOperator(address account) public onlyOwner {
        _addOperator(account);
    }
    
    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }
}


contract TransferProxy is OwnableOperatorRole {
    function erc721safeTransferFrom(IERC721 token,address from,address to,uint256 tokenId) external onlyOperator {
        token.safeTransferFrom(from,to,tokenId);
    }
    
    function erc1155safeTransferFrom(IERC1155 _token,address _from,address _to,uint256 _id,uint256 _value,bytes calldata _data) external onlyOperator {
        _token.safeTransferFrom(_from,_to,_id,_value,_data);
    }
}

contract ERC1155SaleNonceHolder is OwnableOperatorRole {
    // keccak256(token, owner, tokenId) => nonce
    mapping(bytes32 => uint256) public nonces;
    
    // keccak256(token, owner, tokenId, nonce) => completed amount
    mapping(bytes32 => uint256) public completed;
    
    function getNonce(address token,uint256 tokenId,address owner) public view returns (uint256) {
        return nonces[getNonceKey(token,tokenId,owner)];
    }
    
    function setNonce(address token,uint256 tokenId,address owner,uint256 nonce) public onlyOperator {
        nonces[getNonceKey(token,tokenId,owner)] = nonce;
    }
    
    function getNonceKey(address token,uint256 tokenId,address owner) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(token,tokenId,owner));
    }
    
    function getCompleted(address token,uint256 tokenId,address owner,uint256 nonce) public view returns (uint256) {
        return completed[getCompletedKey(token,tokenId,owner,nonce)];
    }
    
    function setCompleted(address token,uint256 tokenId,address owner,uint256 nonce,uint256 _completed) public onlyOperator {
        completed[getCompletedKey(token,tokenId,owner,nonce)] = _completed;
    }
    
    
    function getCompletedKey(address token,uint256 tokenId,address owner,uint256 nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(token,tokenId,owner,nonce));
    }
}


contract ERC1155Sale is Ownable, AbstractSale {
    using StringLibrary for string;

     event Bid(
        address indexed token,	//藏品合约地址
        uint256 indexed tokenId,//藏品ID
        address owner,	//藏品拥有者
        uint256 bidPrice,	//竞价价格
        address bidder,   //竞价者地址,
        uint256 refundPrice,//退回的金额
        address preBidder   //退往的地址
    );

    event CancelBidRefund(
        address indexed token,//藏品合约地址
        uint256 indexed tokenId,//藏品ID
        address owner,//藏品拥有者
        uint256 refundPrice,//退回的金额
        address preBidder   //退往的地址
    );


    event Buy(
        address indexed token,
        uint256 indexed tokenId,
        address owner,
        uint256 price,
        address buyer,
        uint256 value
    );
    
    event BuyFormBid(
        address indexed token,
        uint256 indexed tokenId,
        address owner,
        uint256 price,
        address buyer,
        uint256 value
        
    );

   event CloseOrder(
        address indexed token,//藏品合约地址
        uint256 indexed tokenId,//藏品id
        address owner,//藏品拥有者
        uint256 nonce, //当前nonce(已经+1)
        uint256 refundPrice,//退回的金额
        address preBidder   //退往的地址
    );
    
    event CancelOrder(
        address indexed token,//藏品合约地址
        uint256 indexed tokenId,//藏品id
        address owner,//藏品拥有者
        uint256 nonce ,//当前nonce(已经+1)
        uint256 refundPrice,//退回的金额
        address preBidder   //退往的地址
    );
    
    
    event CancelBid(
        address indexed token,
        uint256 indexed tokenId,
        address owner,
        uint256 refundPrice,
        address preBidder
    );

    bytes constant EMPTY = "";

    TransferProxy public transferProxy;
    ERC1155SaleNonceHolder public nonceHolder;

    
    // tokenId => (ownerAddress => bidAddress)
    mapping(uint256 => mapping(address =>address payable)) private auctionBidders;
    // tokenId => (ownerAddress => bidPrice)
    mapping(uint256=>mapping(address => uint256)) private auctionBidPrices;

    constructor(
        TransferProxy _transferProxy,
        ERC1155SaleNonceHolder _nonceHolder,
        address payable beneficiary
    ) public AbstractSale(beneficiary) {
        transferProxy = _transferProxy;
        nonceHolder = _nonceHolder;
    }

    function hasBidder(uint256 tokenId,address owner) public view returns (bool) {
        return auctionBidPrices[tokenId][owner] != 0;
    }

    function bidderPrice(uint256 tokenId,address owner) public view returns (uint256) {
        return auctionBidPrices[tokenId][owner];
    }

    function bid(IERC1155 token,uint256 tokenId,address payable owner,uint256 selling,uint256 price,uint256 sellerFee,Sig memory signature) public payable {
        require(msg.value > 0,"Bid: payamount cannot be zero");

        uint256 nonce = verifySignature(
            address(token),
            tokenId,
            owner,
            selling,
            price,
            sellerFee,
            signature
        );
        
        
        address payable preBidder = address(0);
        uint256  preBidderPrice = 0;
        if(hasBidder(tokenId,owner)){
            preBidder = auctionBidders[tokenId][owner];
            preBidderPrice = auctionBidPrices[tokenId][owner];

            require(msg.value > preBidderPrice,"Bid: new price must be higher");
            //将资产原路返回
            preBidder.transfer(preBidderPrice);
       }

        auctionBidders[tokenId][owner] = msg.sender;
        auctionBidPrices[tokenId][owner] = msg.value;

        emit Bid(address(token),tokenId,owner,msg.value,msg.sender,preBidderPrice,preBidder);
    }

    function buy(
        IERC1155 token,
        uint256 tokenId,
        address payable owner,
        uint256 selling,// 出售的总数量
        uint256 buying, // 购买的数量
        uint256 price,
        uint256 sellerFee,
        Sig memory signature //在交易创建时就已经签名成功,由服务器保存
    ) public payable {
        // 验证签名并且取回nonce,签名时传入owner,即
        uint256 nonce = verifySignature(
            address(token),
            tokenId,
            owner,
            selling,
            price,
            sellerFee,
            signature
        );
        uint256 total = price.mul(buying);
        uint256 buyerFeeValue = total.mul(buyerFee).div(10000);
        require(total + buyerFeeValue == msg.value, "msg.value is incorrect");

        bool closed = verifyOpenAndModifyState(
            address(token),
            tokenId,
            owner,
            nonce,
            selling,
            buying
        );

        transferProxy.erc1155safeTransferFrom(
            token,
            owner,
            msg.sender,
            tokenId,
            buying,
            EMPTY
        );

        transferEther(token, tokenId, owner, total, sellerFee);
        emit Buy(address(token), tokenId, owner, price, msg.sender,buying);
        if (closed) {
            address payable preBidder = address(0);
            uint256 preBidderPrice = 0;
            
            if(hasBidder(tokenId,owner)){
                preBidder = auctionBidders[tokenId][owner];
                preBidderPrice = auctionBidPrices[tokenId][owner];
    
                //将资产原路返回
                auctionBidPrices[tokenId][owner] = 0;
                auctionBidders[tokenId][owner] = address(0);
                preBidder.transfer(preBidderPrice);
            }
            
            nonceHolder.setNonce(address(token), tokenId, owner, nonce + 1);
            emit CloseOrder(address(token), tokenId, owner, nonce + 1,preBidderPrice,preBidder);

        }
    }
    
    function cancelBid(IERC1155 token,uint256 tokenId,address owner) public{
        address payable preBidder = auctionBidders[tokenId][owner];
        require(msg.sender == preBidder,"msg.sender is not bidder");
        
        uint256  preBidderPrice = auctionBidPrices[tokenId][owner];
        auctionBidPrices[tokenId][owner] = 0;
        auctionBidders[tokenId][owner] = address(0);
        preBidder.transfer(preBidderPrice);
            
        
        emit CancelBid(address(token),tokenId,owner,preBidderPrice,preBidder);
    }

    
    function acceptanceOfOffer( IERC1155 token,
        uint256 tokenId,
        address payable owner,
        uint256 selling,// 出售的总数量
        uint256 price,
        uint256 bidPrice,
        uint256 sellerFee,
        Sig memory signature //在交易创建时就已经签名成功,由服务器保存
        ) public {
            //must have bid.
            require(hasBidder(tokenId,owner),"Recieve: Token has not bidder");
            require(msg.sender == owner,"msg.sender is not owner");
            
            
            uint256 nonce = verifySignature(
                address(token),
                tokenId,
                owner,
                selling,
                price,
                sellerFee,
                signature
            );
            
            address  bidder = auctionBidders[tokenId][owner];
            uint256  bidrPrice_ = auctionBidPrices[tokenId][owner];
            
            require(bidrPrice_ == bidPrice,"bidPrice is wrong");
            
            bool closed = verifyOpenAndModifyState(
                address(token),
                tokenId,
                owner,
                nonce,
                selling,
                1
            );
            
            
            transferProxy.erc1155safeTransferFrom(
                token,
                owner,
                bidder,
                tokenId,
                1,
                EMPTY
            );
            
            auctionBidPrices[tokenId][owner] = 0;
            auctionBidders[tokenId][owner] = address(0);
            transferEther(token, tokenId, owner, bidrPrice_, sellerFee);
            
           
            
            emit BuyFormBid(address(token), tokenId, owner, bidrPrice_, bidder, 1);
            if (closed) {
                nonceHolder.setNonce(address(token), tokenId, owner, nonce + 1);
                emit CloseOrder(address(token), tokenId, owner, nonce + 1,0,address(0));
            }

        }

    

    function cancel(address token, uint256 tokenId) public payable {
        uint256 nonce = nonceHolder.getNonce(token, tokenId, msg.sender);
        nonceHolder.setNonce(token, tokenId, msg.sender, nonce + 1);

        address payable preBidder = address(0);
        uint256  preBidderPrice = 0;
        if(hasBidder(tokenId,msg.sender)){
            preBidder = auctionBidders[tokenId][msg.sender];
            preBidderPrice = auctionBidPrices[tokenId][msg.sender];
    
            //将资产原路返回
            auctionBidPrices[tokenId][msg.sender] = 0;
            auctionBidders[tokenId][msg.sender] = address(0);
            preBidder.transfer(preBidderPrice);
        }

        emit CancelOrder(token, tokenId, msg.sender, nonce + 1,preBidderPrice,preBidder);
    }

    function verifySignature(
        address token,
        uint256 tokenId,
        address payable owner,
        uint256 selling,
        uint256 price,
        uint256 sellerFee,
        Sig memory signature
    ) internal view returns (uint256 nonce) {
        nonce = nonceHolder.getNonce(token, tokenId, owner);
        require(
            prepareMessage(token, tokenId, price, selling, sellerFee, nonce)
                .recover(signature.v, signature.r, signature.s) == owner,
            "incorrect signature"
        );
    }



    function verifyOpenAndModifyState(
        address token,
        uint256 tokenId,
        address payable owner,
        uint256 nonce,
        uint256 selling,
        uint256 buying
    ) internal returns (bool) {
        uint256 comp = nonceHolder
            .getCompleted(token, tokenId, owner, nonce)
            .add(buying);
        require(comp <= selling,"buying amount greater than selling");
        nonceHolder.setCompleted(token, tokenId, owner, nonce, comp);

        if (comp == selling) {
            nonceHolder.setNonce(token, tokenId, owner, nonce + 1);
            return true;
        }
        return false;
    }

    function prepareMessage(
        address token,
        uint256 tokenId,
        uint256 price,
        uint256 value,
        uint256 fee,
        uint256 nonce
    ) internal pure returns (string memory) {
        return
            prepareMessage(token, tokenId, price, fee, nonce).append(
                ". value: ",
                value.toString()
            );
    }
    
}