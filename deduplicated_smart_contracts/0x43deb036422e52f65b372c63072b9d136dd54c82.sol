/**
 *Submitted for verification at Etherscan.io on 2020-04-02
*/

pragma solidity ^0.5.0;
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

}


pragma solidity ^0.5.0;

contract CommonConstants {
    bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; 
    bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; 
}

pragma solidity ^0.5.0;

interface ERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);
}

pragma solidity ^0.5.0;

interface ERC165 {

  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}

pragma solidity ^0.5.0;

interface IERC1155 /* is ERC165 */ {

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;

    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}


pragma solidity ^0.5.0;

contract ERC1155Base is IERC1155, ERC165, CommonConstants
{
    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) internal balances; // id => (owner => balance)
    mapping (address => mapping(address => bool)) internal operatorApproval; // owner => (operator => approved)

/////////////////////////////////////////// ERC165 //////////////////////////////////////////////

    bytes4 constant private INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

    function supportsInterface(bytes4 _interfaceId)
    public
    view
    returns (bool) {
         if (_interfaceId == INTERFACE_SIGNATURE_ERC165 ||
             _interfaceId == INTERFACE_SIGNATURE_ERC1155) {
            return true;
         }

         return false;
    }

/////////////////////////////////////////// ERC1155 //////////////////////////////////////////////



    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {

        require(_to != address(0x0), "_to must be non-zero.");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");
        balances[_id][_from] = balances[_id][_from].sub(_value);
        balances[_id][_to]   = _value.add(balances[_id][_to]);

        emit TransferSingle(msg.sender, _from, _to, _id, _value);

        if (_to.isContract()) {
            _doSafeTransferAcceptanceCheck(msg.sender, _from, _to, _id, _value, _data);
        }
    }


    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external {
        require(_to != address(0x0), "destination address must be non-zero.");
        require(_ids.length == _values.length, "_ids and _values array length must match.");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");

        for (uint256 i = 0; i < _ids.length; ++i) {
            uint256 id = _ids[i];
            uint256 value = _values[i];
            balances[id][_from] = balances[id][_from].sub(value);
            balances[id][_to]   = value.add(balances[id][_to]);
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _values);

        if (_to.isContract()) {
            _doSafeBatchTransferAcceptanceCheck(msg.sender, _from, _to, _ids, _values, _data);
        }
    }

    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        return balances[_id][_owner];
    }


    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory) {
        require(_owners.length == _ids.length);
        uint256[] memory balances_ = new uint256[](_owners.length);
        for (uint256 i = 0; i < _owners.length; ++i) {
            balances_[i] = balances[_ids[i]][_owners[i]];
        }
        return balances_;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApproval[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorApproval[_owner][_operator];
    }

/////////////////////////////////////////// Internal //////////////////////////////////////////////

    function _doSafeTransferAcceptanceCheck(address _operator, address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) internal {
        require(ERC1155TokenReceiver(_to).onERC1155Received(_operator, _from, _id, _value, _data) == ERC1155_ACCEPTED, "contract returned an unknown value from onERC1155Received");
    }

    function _doSafeBatchTransferAcceptanceCheck(address _operator, address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) internal {
        require(ERC1155TokenReceiver(_to).onERC1155BatchReceived(_operator, _from, _ids, _values, _data) == ERC1155_BATCH_ACCEPTED, "contract returned an unknown value from onERC1155BatchReceived");
    }
}

pragma solidity ^0.5.0;

contract ERC1155MixedFungible is ERC1155Base {

    uint256 constant TYPE_MASK = uint256(uint128(~0)) << 128;
    uint256 constant NF_INDEX_MASK = uint128(~0);
    uint256 constant TYPE_NF_BIT = 1 << 255;
    mapping (uint256 => address) nfOwners;

    function isNonFungible(uint256 _id) public pure returns(bool) {
        return _id & TYPE_NF_BIT == TYPE_NF_BIT;
    }
    function isFungible(uint256 _id) public pure returns(bool) {
        return _id & TYPE_NF_BIT == 0;
    }
    function getNonFungibleIndex(uint256 _id) public pure returns(uint256) {
        return _id & NF_INDEX_MASK;
    }
    function getNonFungibleBaseType(uint256 _id) public pure returns(uint256) {
        return _id & TYPE_MASK;
    }
    function isNonFungibleBaseType(uint256 _id) public pure returns(bool) {
        // A base type has the NF bit but does not have an index.
        return (_id & TYPE_NF_BIT == TYPE_NF_BIT) && (_id & NF_INDEX_MASK == 0);
    }
    function isNonFungibleItem(uint256 _id) public pure returns(bool) {
        // A base type has the NF bit but does has an index.
        return (_id & TYPE_NF_BIT == TYPE_NF_BIT) && (_id & NF_INDEX_MASK != 0);
    }
    function ownerOf(uint256 _id) public view returns (address) {
        return nfOwners[_id];
    }

    // override
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external {

        require(_to != address(0x0), "cannot send to zero address");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");

        if (isNonFungible(_id)) {
            require(nfOwners[_id] == _from);
            nfOwners[_id] = _to;
            // You could keep balance of NF type in base type id like so:
            uint256 baseType = getNonFungibleBaseType(_id);
            balances[baseType][_from] = balances[baseType][_from].sub(_value);
            balances[baseType][_to]   = balances[baseType][_to].add(_value);
        } else {
            balances[_id][_from] = balances[_id][_from].sub(_value);
            balances[_id][_to]   = balances[_id][_to].add(_value);
        }

        emit TransferSingle(msg.sender, _from, _to, _id, _value);

        if (_to.isContract()) {
            _doSafeTransferAcceptanceCheck(msg.sender, _from, _to, _id, _value, _data);
        }
    }

    function safeBatchTransferFrom(
      address _from, 
      address _to, 
      uint256[] calldata _ids, 
      uint256[] calldata _values, 
      bytes calldata _data
    ) external {
        require(_to != address(0x0), "cannot send to zero address");
        require(_ids.length == _values.length, "Array length must match");
        require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party transfers.");

        for (uint256 i = 0; i < _ids.length; ++i) {
            uint256 id = _ids[i];
            uint256 value = _values[i];
            if (isNonFungible(id)) {
                require(nfOwners[id] == _from);
                nfOwners[id] = _to;
                balances[getNonFungibleBaseType(id)][_from] = balances[getNonFungibleBaseType(id)][_from].sub(value);
                balances[getNonFungibleBaseType(id)][_to]   = balances[getNonFungibleBaseType(id)][_to].add(value);
            } else {
                balances[id][_from] = balances[id][_from].sub(value);
                balances[id][_to]   = value.add(balances[id][_to]);
            }
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _values);

        if (_to.isContract()) {
            _doSafeBatchTransferAcceptanceCheck(msg.sender, _from, _to, _ids, _values, _data);
        }
    }

    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        if (isNonFungibleItem(_id))
            return nfOwners[_id] == _owner ? 1 : 0;
        return balances[_id][_owner];
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory) {
        require(_owners.length == _ids.length);
        uint256[] memory balances_ = new uint256[](_owners.length);
        for (uint256 i = 0; i < _owners.length; ++i) {
            uint256 id = _ids[i];
            if (isNonFungibleItem(id)) {
                balances_[i] = nfOwners[id] == _owners[i] ? 1 : 0;
            } else {
            	balances_[i] = balances[id][_owners[i]];
            }
        }

        return balances_;
    }
}

pragma solidity ^0.5.0;

contract Elevate is ERC1155MixedFungible {

    address public owner;
    uint256 nonce;
    mapping (uint256 => uint256) public maxIndex;
    mapping (address => bool) public creators;
    mapping(address => mapping(address => mapping(uint256 => uint256))) allowances;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => uint256) public tokenSupplyLimit;


    modifier creatorOnly() {
        require(creators[msg.sender]);
        _;
    }

    constructor() public {
      owner = msg.sender;
      creators[msg.sender] = true;
    }

    event Approval(address indexed _owner, address indexed _spender, uint256 indexed _id, uint256 _oldValue, uint256 _value);
    event SupplyLimit(uint256 indexed _id, uint256 _supplyLimit);

    function create(
        string calldata _uri,
        bool   _isNF
    ) external creatorOnly returns(uint256 _type) {
        _type = (++nonce << 128);

        if (_isNF)
          _type = _type | TYPE_NF_BIT;


        emit TransferSingle(msg.sender, address(0x0), address(0x0), _type, 0);

        if (bytes(_uri).length > 0)
            emit URI(_uri, _type);
        return _type;
    }

    function setSupplyLimit(uint256 _typeOrId, uint256 _supplyLimit) external creatorOnly {
      require(_supplyLimit > 0);
      if(isNonFungibleItem(_typeOrId)) {
        uint256 typeId = getNonFungibleBaseType(_typeOrId);
        tokenSupplyLimit[typeId] = _supplyLimit;
        emit SupplyLimit(typeId, _supplyLimit);
      } else {
        tokenSupplyLimit[_typeOrId] = _supplyLimit;
        emit SupplyLimit(_typeOrId, _supplyLimit);
      }
    }

    function mintNonFungible(uint256 _type, address[] calldata _to) external creatorOnly {
        require(isNonFungible(_type));
        uint256 index = maxIndex[_type] + 1;
        maxIndex[_type] = _to.length.add(maxIndex[_type]);
        for (uint256 i = 0; i < _to.length; ++i) {
            address distributeTo = _to[i];
            uint256 id  = _type | index + i;
            require(tokenSupplyLimit[_type] == 0 || tokenSupply[_type].add(1) <= tokenSupplyLimit[_type], "Token supply limit exceeded");
            nfOwners[id] = distributeTo;
            tokenSupply[_type] = tokenSupply[_type].add(1);
            balances[_type][distributeTo] = balances[_type][distributeTo].add(1);

            emit TransferSingle(msg.sender, address(0x0), distributeTo, id, 1);

            if (distributeTo.isContract()) {
                _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, distributeTo, id, 1, '');
            }
        }
    }

    function mintFungible(uint256 _id, address[] calldata _to, uint256[] calldata _quantities) external creatorOnly {
        require(isFungible(_id));
        for (uint256 i = 0; i < _to.length; ++i) {
            address to = _to[i];
            uint256 quantity = _quantities[i];
            require(tokenSupplyLimit[_id] == 0 || tokenSupply[_id].add(quantity) <= tokenSupplyLimit[_id], "Token supply limit exceeded");
            balances[_id][to] = quantity.add(balances[_id][to]);
            tokenSupply[_id] = tokenSupply[_id].add(quantity);

            emit TransferSingle(msg.sender, address(0x0), to, _id, quantity);

            if (to.isContract()) {
                _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, to, _id, quantity, '');
            }
        }
    }

    function atomicSwap(
      address _addressPartyA, 
      address _addressPartyB, 
      uint256[] calldata _idsPartyA, 
      uint256[] calldata _idsPartyB,
      uint256[] calldata _valuesPartyA,
      uint256[] calldata _valuesPartyB
    ) external {
      require(_addressPartyA != address(0x0), "cannot send to zero address");
      require(_addressPartyB != address(0x0), "cannot send to zero address");
      require(_idsPartyA.length == _valuesPartyA.length, "Array length must match");
      require(_idsPartyB.length == _valuesPartyB.length, "Array length must match");

      // Transfer party A tokens to party B
      for (uint256 i = 0; i < _idsPartyA.length; ++i) {
        require(allowances[_addressPartyA][msg.sender][_idsPartyA[i]] == _valuesPartyA[i]);
        if(isFungible(_idsPartyA[i])) {
          uint256 id = _idsPartyA[i];
          balances[id][_addressPartyB] = balances[id][_addressPartyB].add(_valuesPartyA[i]);
          balances[id][_addressPartyA] = balances[id][_addressPartyA].sub(_valuesPartyA[i]);
        } else {
          uint256 baseType = getNonFungibleBaseType(_idsPartyA[i]);
          nfOwners[_idsPartyA[i]] = _addressPartyB;
          balances[baseType][_addressPartyB] = balances[baseType][_addressPartyB].add(_valuesPartyA[i]);
          balances[baseType][_addressPartyA] = balances[baseType][_addressPartyA].sub(_valuesPartyA[i]);
        }
        allowances[_addressPartyA][msg.sender][_idsPartyA[i]] = allowances[_addressPartyA][msg.sender][_idsPartyA[i]].sub(_valuesPartyA[i]);
        if (_addressPartyA.isContract()) {
            _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, _addressPartyA, _idsPartyA[i], _valuesPartyA[i], '');
        }
      }

      // Transfer party B tokens to party A
      for (uint256 i = 0; i < _idsPartyB.length; ++i) {
        require(allowances[_addressPartyB][msg.sender][_idsPartyB[i]] == _valuesPartyB[i]);
        if(isFungible(_idsPartyB[i])) {
          uint256 id = _idsPartyB[i];
          balances[id][_addressPartyA] = balances[id][_addressPartyA].add(_valuesPartyB[i]);
          balances[id][_addressPartyB] = balances[id][_addressPartyB].sub(_valuesPartyB[i]);
        } else {
          uint256 baseType = getNonFungibleBaseType(_idsPartyB[i]);
          nfOwners[_idsPartyB[i]] = _addressPartyA;
          balances[baseType][_addressPartyA] = balances[baseType][_addressPartyA].add(_valuesPartyB[i]);
          balances[baseType][_addressPartyB] = balances[baseType][_addressPartyB].sub(_valuesPartyB[i]);
        }
        allowances[_addressPartyB][msg.sender][_idsPartyB[i]] = allowances[_addressPartyB][msg.sender][_idsPartyB[i]].sub(_valuesPartyB[i]);
        if (_addressPartyB.isContract()) {
            _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, _addressPartyB, _idsPartyB[i], _valuesPartyB[i], '');
        }
      }

        emit TransferBatch(msg.sender, _addressPartyA, _addressPartyB, _idsPartyA, _valuesPartyA);
        emit TransferBatch(msg.sender, _addressPartyB, _addressPartyA, _idsPartyB, _valuesPartyB);
      
    }

    function approveBatch(
      address _spender, 
      uint256[] calldata _ids, 
      uint256[] calldata _currentValues, 
      uint256[] calldata _values
    ) external {
      require(_ids.length == _currentValues.length, "Arrays must be same length");
      require(_currentValues.length == _values.length, "Arrays must be same length");
      for(uint256 i = 0; i < _values.length; i++) {
        uint256 id = _ids[i];
        uint256 currentValue = _currentValues[i];
        uint256 value = _values[i];
        require(allowances[msg.sender][_spender][id] == currentValue);
        allowances[msg.sender][_spender][id] = value;
        emit Approval(msg.sender, _spender, id, currentValue, value);
      }
    }
    
    function batchAuthorizeCreators(address[] calldata _addresses) external {
      require(msg.sender == owner);
      for (uint256 i = 0; i < _addresses.length; ++i) {
        creators[_addresses[i]] = true;
      }
    }

    function allowance(address _owner, address _spender, uint256 _id) external view returns (uint256){
        return allowances[_owner][_spender][_id];
    }

    function burn(address _from, uint256[] calldata _ids, uint256[] calldata _values
    ) external {
      require(_from == msg.sender || operatorApproval[_from][msg.sender] == true, "Need operator approval for 3rd party burn.");
      require(_ids.length > 0 && _ids.length == _values.length);
      for(uint256 i = 0; i < _ids.length; i++) {
        if(isFungible(_ids[i])) {
          require(balances[_ids[i]][_from] >= _values[i]);
          balances[_ids[i]][_from] = balances[_ids[i]][_from].sub(_values[i]);
        } else {
          require(isNonFungible(_ids[i]));
          require(_values[i] == 1);
          uint256 baseType = getNonFungibleBaseType(_ids[i]);
          // --totalSupply? 
          balances[baseType][_from] = balances[baseType][_from].sub(1);
          delete nfOwners[_ids[i]];
        }
        emit TransferSingle(msg.sender, _from, address(0x0), _ids[i], _values[i]);
      }
 
    }
}