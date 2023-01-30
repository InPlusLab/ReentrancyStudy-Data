pragma solidity ^0.5.0;

import "ERC20Mintable.sol";
import "Ownable.sol";

library Strings {

    function concat(string memory _base, string memory _value) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

}

contract HSEToken is ERC20Mintable, Ownable {    
    using Strings for string;
    string public name = "HuShow Ecology Token";
    string public symbol = "HST";
    uint256 public decimals = 18;    
    uint256 private msgCount;
    uint256 private msgMintCount;
    address constant ETHER = address(0);

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // Model a Message
    struct _Message {
        uint256 timestamp;   // Message timestamp
        string nodeName;     // Node name
        string productName;  // Product name
        string productSale;  // Product sale
        string percent;      // Percent
        uint256 mintAmount;  // Mint amount
        string tokenPrice;   // Token price
    }

    mapping(uint256 => _Message) public mintMessage;
    mapping(uint256 => string) private message;
    
    constructor() public {}

    function doMint(uint256 _mintAmount, address _beneficiary, string memory _nodeName, string memory _productName, string memory _productSale, string memory _percent, string memory _tokenPrice) public onlyOwner {
        require (_mintAmount >= 0);
        require(_beneficiary != ETHER);
        require(mint(_beneficiary, _mintAmount), "Mint tokens to beneficiary");
        // Create new mint message
        _setMessageMint(_nodeName, _productName, _productSale, _percent, _mintAmount, _tokenPrice);
    }
    
    function _setMessageMint(string memory _nodeName, string memory _productName, string memory _productSale, string memory _percent, uint256 _mintAmount, string memory _tokenPrice) internal {
        msgMintCount = msgMintCount.add(1);
        mintMessage[msgMintCount] = _Message(now, _nodeName, _productName, _productSale, _percent, _mintAmount, _tokenPrice);
    }

    function readMessageMint(uint256 _msgId) public view returns(string memory) {
        _Message storage m = mintMessage[_msgId];
        uint256 mintedAmount = m.mintAmount / ( 10 ** decimals);
        string memory tmpOne = uint2str(m.timestamp).concat(" ").concat(m.nodeName).concat("节点以");
        string memory tmpTwo = tmpOne.concat(m.productName);
        string memory tmpThree = tmpTwo.concat(m.productSale).concat("销售额申请");
        string memory tmpFour = tmpThree.concat(m.percent).concat("铸币");
        string memory tmpFive = tmpFour.concat(uint2str(mintedAmount)).concat("个HST (").concat(m.tokenPrice).concat(") ").concat(",分配规则参考公示内容。");
        return tmpFive;
    }

    function setMessage(string memory _message) public onlyOwner {
        msgCount = msgCount.add(1);
        message[msgCount] = _message;        
    }

    function readMessage(uint256 _msgId) public view returns(string memory) {
        return message[_msgId];
    }
    
    function transferRights(address _newOwner) public onlyOwner {
        addMinter(_newOwner);
        renounceMinter();
        transferOwnership(_newOwner);
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
}