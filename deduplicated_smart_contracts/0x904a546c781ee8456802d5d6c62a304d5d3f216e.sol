/**
 *Submitted for verification at Etherscan.io on 2019-12-25
*/

pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
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

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
contract IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transfer(address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ereum/EIPs/issues/179
 */
contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    uint8 public decimals;
}

contract DepositBlockchainCard is Ownable {
    using SafeMath for uint256;
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    address payable public SYS_ADDRESS = address(0xbE064F371A0e1e0EF7f4DA08578210002219722B);
    address payable public PARTNER_ADDRESS = address(0x1e56CAB5Dc4503caf9CcB469Ae7b0b22354C678c);
    uint public sysfee = 100000000000000;// 1 finney;
    uint public partnerfee = 70000000000000; // 1 finney;

    struct item {
        address iOwner;
        string key;
        uint item;
        address game;
        bool available;
        ERC20 bonusToken;
        uint bonusTokenAmount;
        address payable creator;
        address buyer;
        bytes32 pass;
        uint sysfee;
        uint partnerfee;
    }
    struct itemsByCreator {
        uint[] code;
        uint[] iId;
    }
    struct game2code {
        mapping(uint => uint[]) codes;
    }
    mapping(uint => item) public items;
    mapping(address => game2code) private codes;
    mapping(address => itemsByCreator) private itemsByCreators;
    event _deposit(address creator, uint _code);
    event _withdraw(uint _code);
    constructor() public {}

    function setParners(address payable _partner, uint _fee) public onlyOwner (){
        PARTNER_ADDRESS = _partner;
        partnerfee = _fee;
    }
    function setSys(address payable _sys, uint _fee) public onlyOwner (){
        SYS_ADDRESS = _sys;
        sysfee = _fee;
    }
    function getItem(uint _code) public view returns (address iOwner, string memory _key,
        uint _item,
        address game,
        bool available) {
        return (items[_code].iOwner, items[_code].key, items[_code].item, items[_code].game, items[_code].available);
    }
    function getItemByOwner(uint _code) public returns (address iOwner, string memory _key,
        uint _item,
        address game,
        bool available,
        bytes32 pass,
        address _creator,
        address _buyer) {
        require(msg.sender == items[_code].buyer || msg.sender == items[_code].creator);
        uint code = _code;
        return (items[code].iOwner, items[_code].key, items[_code].item, items[_code].game, items[_code].available,
        items[code].pass, items[code].creator, items[code].buyer);
    }
    function getItemsByCreator() public returns (uint[] memory _code, uint[] memory _iId) {
        return (itemsByCreators[msg.sender].code, itemsByCreators[msg.sender].iId);
    }
    function getItemsByTokenOwner(address _game, uint _iId) public returns (uint[] memory _codes) {
        IERC721 erc721 = IERC721(_game);
        require(erc721.ownerOf(_iId) == msg.sender);
        return codes[_game].codes[_iId];
    }
    function changePass(uint _code, bytes32 _pass) public {
        require(msg.sender == items[_code].creator);
        items[_code].pass = _pass;
    }
    function checkPass(uint _code, bytes32 _pass) public view returns(bool){
        return items[_code].pass == _pass;
    }
    function deposit(uint256 _code, address payable _iOwner, string memory _key, uint256 _feeAmount,
        address _game, uint256 _iId, ERC20 _bonusToken, uint256 _bonusTokenAmount, bytes32 _pass, address _buyer) public payable{
        require(items[_code].available == false);
        if(_bonusToken != ETH_TOKEN_ADDRESS) {
            require(msg.value == _feeAmount.add(sysfee).add(partnerfee));
            if(_bonusToken != ERC20(address(0)) && _bonusTokenAmount > 0) {

                ERC20 erc20 = ERC20(_bonusToken);
                erc20.transferFrom(msg.sender, address(this), _bonusTokenAmount);
            }
        } else {
            require(msg.value == _bonusTokenAmount.add(_feeAmount).add(sysfee).add(partnerfee));
        }
        _iOwner.transfer(_feeAmount);
        IERC721 erc721 = IERC721(_game);
        erc721.transferFrom(msg.sender, address(this), _iId);
        items[_code] = item(_iOwner, _key, _iId, _game, true, _bonusToken, _bonusTokenAmount, msg.sender, _buyer, _pass, sysfee, partnerfee);
        items[_code].available = true;
        addCode(_game, _iId, _code);
        itemsByCreators[msg.sender].code.push(_code);
        itemsByCreators[msg.sender].iId.push(_iId);
        emit _deposit(msg.sender, _code);
    }
    function addCode(address _game, uint256 _iId, uint256 _code) internal {
        bool existed;
        for(uint8 i=0; i < codes[_game].codes[_iId].length; i++) {
            if(codes[_game].codes[_iId][i] == _code) existed = true;
        }
        if(!existed) codes[_game].codes[_iId].push(_code);
    }
    function cancel(uint256 _code, bytes32 _pass) public {
        require(items[_code].available == true && msg.sender == address(items[_code].creator) && _pass == items[_code].pass);
        if(items[_code].bonusToken != ETH_TOKEN_ADDRESS) {
            if(items[_code].bonusToken != ERC20(address(0)) && items[_code].bonusTokenAmount > 0) {

                ERC20 erc20 = ERC20(items[_code].bonusToken);
                erc20.transfer(items[_code].creator, items[_code].bonusTokenAmount);
            }
        } else {
            items[_code].creator.transfer(items[_code].bonusTokenAmount);
        }
        IERC721 erc721 = IERC721(items[_code].game);
        erc721.transferFrom(address(this), items[_code].creator, items[_code].item);
        items[_code].available = false;
        items[_code].creator.transfer(items[_code].sysfee.add(items[_code].partnerfee));
        emit _withdraw(_code);
    }
    function withdraw(uint256 _code, address payable _to, bytes32 _pass) public {
        require(items[_code].available == true && msg.sender == address(items[_code].iOwner) && _pass == items[_code].pass);
        if(items[_code].bonusToken != ETH_TOKEN_ADDRESS) {
            if(items[_code].bonusToken != ERC20(address(0)) && items[_code].bonusTokenAmount > 0) {

                ERC20 erc20 = ERC20(items[_code].bonusToken);
                erc20.transfer(_to, items[_code].bonusTokenAmount);
            }
        } else {
            _to.transfer(items[_code].bonusTokenAmount);
        }
        IERC721 erc721 = IERC721(items[_code].game);
        erc721.transferFrom(address(this), _to, items[_code].item);
        items[_code].available = false;
        SYS_ADDRESS.transfer(items[_code].sysfee);
        PARTNER_ADDRESS.transfer(items[_code].partnerfee);
        emit _withdraw(_code);
    }

}