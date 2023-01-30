pragma solidity ^0.4.24;
import { Proxy } from "Proxy.sol";
import { StorageModule } from "./StorageModule.sol";
import { AuthModule } from "./AuthModule.sol";
import "./IERC20.sol";
import "./IERC20Mintable.sol";
import "./IERC20Burnable.sol";
import "./IERC20ImplUpgradeable.sol";
import "./Authorization.sol";

library ItMapUintAddress
{
    struct MapUintAddress
    {
        mapping(uint => MapValue) data;
        KeyFlag[] keys;
        uint size;
    }

    struct MapValue { uint keyIndex; address value; }

    struct KeyFlag { uint key; bool deleted; }

    function add(MapUintAddress storage self, uint key, address value) public returns (bool replaced)
    {
        uint keyIndex = self.data[key].keyIndex;
        self.data[key].value = value;
        if (keyIndex > 0)
            return true;
        else
        {
            self.keys.push(KeyFlag(key, false));
            self.data[key].keyIndex = self.keys.length;
            self.size++;
            return false;
        }
    }

    function remove(MapUintAddress storage self, uint key) public returns (bool success)
    {
        uint keyIndex = self.data[key].keyIndex;
        if (keyIndex == 0)
            return false;
        delete self.data[key];
        self.keys[keyIndex - 1].deleted = true;
        self.size --;
    }

    function contain(MapUintAddress storage self, uint key) public view returns (bool)
    {
        return self.data[key].keyIndex > 0;
    }

    function startIndex(MapUintAddress storage self) public view returns (uint keyIndex)
    {
        return nextIndex(self, uint(-1));
    }

    function validIndex(MapUintAddress storage self, uint keyIndex) public view returns (bool)
    {
        return keyIndex < self.keys.length;
    }

    function nextIndex(MapUintAddress storage self, uint _keyIndex) public view returns (uint)
    {
        uint keyIndex = _keyIndex;
        keyIndex++;
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
            keyIndex++;
        return keyIndex;
    }

    function getByIndex(MapUintAddress storage self, uint keyIndex) public view returns (address value)
    {
        uint key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }

    function getByKey(MapUintAddress storage self, uint key) public view returns (address value) {
        return self.data[key].value;
    }
}

contract TokenModule is Authorization {
    
    using ItMapUintAddress for ItMapUintAddress.MapUintAddress;

    ItMapUintAddress.MapUintAddress tokenMap;

    event UpdateToken(uint _tag, address _old, address _new);

    constructor(address _proxy) public Authorization(_proxy) {
       
    }

    function addToken(uint _tag, address _token) external whenNotPaused onlyAdmin(msg.sender) {
        require(tokenMap.data[_tag].value == address(0), "Token already exists");
        tokenMap.add(_tag, _token);
        emit UpdateToken(_tag, address(0), _token);
    }

    function updateToken(uint _tag, address _token) external whenNotPaused onlyAdmin(msg.sender) {
        require(tokenMap.data[_tag].value != address(0), "Token not exists");
        address _old = tokenMap.data[_tag].value;
        tokenMap.add(_tag, _token);
        emit UpdateToken(_tag, _old, _token);
    }

    function getToken(uint _tag) external view returns (address) {
        return tokenMap.getByKey(_tag);
    }

    function balanceOf(address _from) external view returns (uint256 sum) {
        for(uint i = tokenMap.startIndex(); tokenMap.validIndex(i); i = tokenMap.nextIndex(i)) {
            IERC20 _token = IERC20(tokenMap.getByIndex(i));
            if(_token != address(0))
                sum += _token.balanceOf(_from);
        }
    }

    function mint(uint _tokenTag, address[] _investors, uint[] _balances, uint[] _timestamps, bool _originals) external whenNotPaused onlyIssuer(msg.sender) {
        IERC20ImplUpgradeable token = IERC20ImplUpgradeable(tokenMap.getByKey(_tokenTag));
        IERC20Mintable impl = IERC20Mintable(token.getMintBurnAddress());
        require(impl != address(0), "mint impl require not 0");

        impl.mint(_investors, _balances, _timestamps);

        StorageModule sm = StorageModule(proxy.getModule("StorageModule"));
        sm.initShareholders(_investors, _originals);
    }

    function burn(uint _tokenTag, address[] _investors, uint256[] _values, uint256[] _timestamps) external whenNotPaused onlyIssuer(msg.sender) {
        IERC20ImplUpgradeable token = IERC20ImplUpgradeable(tokenMap.getByKey(_tokenTag));
        IERC20Burnable impl = IERC20Burnable(token.getMintBurnAddress());
        require(impl != address(0), "burn impl require not 0");
        impl.burn(_investors, _values, _timestamps);
    }

    function burnAll(uint _tokenTag, address[] _investors) external whenNotPaused onlyIssuer(msg.sender) {
        IERC20ImplUpgradeable token = IERC20ImplUpgradeable(tokenMap.getByKey(_tokenTag));
        IERC20Burnable impl = IERC20Burnable(token.getMintBurnAddress());
        require(impl != address(0), "burn impl require not 0");
        impl.burnAll(_investors);
    }

    function getTokenTags() external view returns(uint[] tags){
        tags = new uint[](tokenMap.size);
        uint j = 0;
        for(uint i = tokenMap.startIndex(); tokenMap.validIndex(i); i = tokenMap.nextIndex(i)) {
            tags[j] = tokenMap.keys[i].key;
            ++j;
        }
    }
}
