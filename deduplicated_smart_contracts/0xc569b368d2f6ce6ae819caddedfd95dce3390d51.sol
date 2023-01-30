/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma solidity ^0.6.4;


/// @dev basic erc20 transfer
interface Token {
    function transfer(address _to, uint256 _value) external;
}


/// @dev prices in ft
interface FtInterface {
    function onMint(address _minter, uint256 _price) external returns (bool);

    function onBuy(
        address _seller,
        address _buyer,
        uint256 _previousPrice,
        uint256 _price
    ) external returns (bool);

    function onTransfer(address _from, address _to, uint256 _price) external returns (bool);
}


/// @dev erc1155
interface Receiver {
    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external returns(bytes4);

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns(bytes4);
}


library Math {
    /// @return uint256 = a + b
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /// @return uint256 = a - b
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}


contract Nft {
    using Math for uint256;

    uint256 public totalSupply;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256[]) private ownerToIds;
    mapping(uint256 => uint256) private idToIndex; // id = ownerToIds[owner][idToIndex[id]]
    mapping(address => mapping(address => bool)) private approval; // [owner][operator]
    mapping(uint256 => uint256) public priceOf; // ft, nextPrice >= prevPrice
    mapping(uint256 => uint256) public sellPriceOf; // ft, zero (not on sell) or >= priceOf
    mapping(uint256 => string) public nameOf;
    mapping(uint256 => string) public descriptionOf;
    mapping(uint256 => string) public imageOf;
    address public ft = address(0);

    /// @dev erc1155
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    /// @dev erc1155
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    /// @dev erc1155
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @dev erc1155
    event URI(string _value, uint256 indexed _id);

    event Price(uint256 indexed _id, uint256 _price);

    /// @notice keep clean from other tokens
    function clean(address _contract, uint256 _value) external {
        Token(_contract).transfer(msg.sender, _value);
    }

    function setFt(address _ft) external {
        require(ft == address(0), "already set");
        ft = _ft;
    }

    /// @notice creates nft using ft
    function mint(
        uint256 _price,
        uint256 _sellPrice,
        string calldata _name,
        string calldata _description,
        string calldata _image,
        bytes calldata _data
    ) external {
        require(_price > 1000000000, "small _price");
        require(_sellPrice == 0 || _sellPrice >= _price, "non-zero or small _sellPrice");
        require(bytes(_image).length > 0, "empty _image");

        require(FtInterface(ft).onMint(msg.sender, _price), "onMint");

        ownerOf[totalSupply] = msg.sender;
        idToIndex[totalSupply] = ownerToIds[msg.sender].length;
        ownerToIds[msg.sender].push(totalSupply);
        priceOf[totalSupply] = _price;
        sellPriceOf[totalSupply] = _sellPrice;
        nameOf[totalSupply] = _name;
        descriptionOf[totalSupply] = _description;
        imageOf[totalSupply] = _image;
        emit URI(uri(totalSupply), totalSupply);
        emit TransferSingle(msg.sender, address(0), msg.sender, totalSupply, 1);
        if (_sellPrice != 0) {
            emit Price(totalSupply, _sellPrice);
        }
        totalSupply = totalSupply.add(1);

        if (isContract(msg.sender)) {
            Receiver receiver = Receiver(msg.sender);
            bytes4 result = receiver.onERC1155Received(msg.sender, address(0), totalSupply.sub(1), 1, _data);
            require(result == 0xf23a6e61, "receiver");
        }
    }

    /// @param _sellPrice can be zero if not on sale, or not less then price
    function setPrice(uint256 _id, uint256 _sellPrice) external {
        require(ownerOf[_id] == msg.sender, "not an owner");
        require(_sellPrice == 0 || _sellPrice >= priceOf[_id], "non-zero or small _sellPrice");
        sellPriceOf[_id] = _sellPrice;
        emit Price(_id, _sellPrice);
    }

    function buy(uint256 _id, bytes calldata _data) external {
        address seller = ownerOf[_id];
        uint256 sellPrice = sellPriceOf[_id];
        require(sellPrice != 0, "not on sell");
        require(FtInterface(ft).onBuy(seller, msg.sender, priceOf[_id], sellPrice), "onBuy");
        transfer(seller, msg.sender, _id);
        priceOf[_id] = sellPrice;
        delete sellPriceOf[_id];
        emit TransferSingle(msg.sender, seller, msg.sender, _id, 1);
        emit Price(_id, 0);

        if (isContract(msg.sender)) {
            Receiver receiver = Receiver(msg.sender);
            bytes4 result = receiver.onERC1155Received(msg.sender, seller, _id, 1, _data);
            require(result == 0xf23a6e61, "receiver");
        }
    }

    /// @dev erc1155
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external {
        require(_to != address(0), "zero _to");
        require(_from == msg.sender || approval[_from][msg.sender], "not approved");
        require(_value == 0 || _value == 1, "big _value");
        if (_value == 1) {
            require(ownerOf[_id] == _from, "not an owner");
            transfer(_from, _to, _id);
            require(FtInterface(ft).onTransfer(_from, _to, priceOf[_id]), "onTransfer");
            if (sellPriceOf[_id] != 0) {
                delete sellPriceOf[_id];
                emit Price(_id, 0);
            }
        }
        emit TransferSingle(msg.sender, _from, _to, _id, _value);

        if (isContract(_to)) {
            Receiver receiver = Receiver(_to);
            bytes4 result = receiver.onERC1155Received(msg.sender, _from, _id, _value, _data);
            require(result == 0xf23a6e61, "receiver");
        }
    }

    /// @dev erc1155
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external {
        require(_to != address(0), "zero _to");
        require(_ids.length == _values.length, "different lengths of arrays");
        require(_from == msg.sender || approval[_from][msg.sender], "not approved");
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            uint256 value = _values[i];
            require(value == 0 || value == 1, "big value");
            if (value == 1) {
                require(ownerOf[id] == _from, "not an owner");
                transfer(_from, _to, id);
                totalPrice = totalPrice.add(priceOf[id]);
                if (sellPriceOf[id] != 0) {
                    delete sellPriceOf[id];
                    emit Price(id, 0);
                }
            }
        }
        if (totalPrice > 0) {
            require(FtInterface(ft).onTransfer(_from, _to, totalPrice), "onTransfer");
        }
        emit TransferBatch(msg.sender, _from, _to, _ids, _values);

        if (isContract(_to)) {
            Receiver receiver = Receiver(_to);
            bytes4 result = receiver.onERC1155BatchReceived(msg.sender, _from, _ids, _values, _data);
            require(result == 0xbc197c81, "receiver");
        }
    }

    /// @dev erc1155
    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0), "zero _operator");
        approval[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /// @dev erc1155
    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        return ownerOf[_id] == _owner ? 1 : 0;
    }

    /// @dev erc1155
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory) {
        require(_owners.length == _ids.length, "different lengths of arrays");
        uint256[] memory result = new uint256[](_owners.length);
        for (uint256 i = 0; i < _owners.length; i++) {
            result[i] = ownerOf[_ids[i]] == _owners[i] ? 1 : 0;
        }
        return result;
    }

    function tokensOf(address _owner) external view returns (uint256) {
        return ownerToIds[_owner].length;
    }

    function idOf(address _owner, uint256 _index) external view returns (uint256) {
        return ownerToIds[_owner][_index];
    }

    /// @dev erc1155
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return approval[_owner][_operator];
    }

    /// @dev erc165
    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        return _interfaceId == 0x01ffc9a7 // erc165
        || _interfaceId == 0xd9b67a26 // erc1155
        || _interfaceId == 0x0e89341c; // erc1155metadata
    }

    /// @dev erc1155metadata
    function uri(uint256 _id) public view returns (string memory) {
        bytes memory out = abi.encodePacked(
            "{ \"name\": \"",
            nameOf[_id],
            "\", \"description\": \"",
            descriptionOf[_id],
            "\", \"image\": \"",
            imageOf[_id],
            "\" }"
        );
        return string(out);
    }

    function transfer(address from, address to, uint256 id) private {
        ownerOf[id] = to;

        uint256 lastIndex = ownerToIds[from].length.sub(1);
        uint256 deletedIndex = idToIndex[id];
        if (lastIndex != deletedIndex) {
            uint256 lastId = ownerToIds[from][lastIndex];
            ownerToIds[from][deletedIndex] = lastId;
            idToIndex[lastId] = deletedIndex;
        }
        ownerToIds[from].pop();
        ownerToIds[to].push(id);
        idToIndex[id] = ownerToIds[to].length.sub(1);
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}