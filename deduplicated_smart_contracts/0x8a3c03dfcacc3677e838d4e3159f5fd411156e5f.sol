/**
 *Submitted for verification at Etherscan.io on 2020-04-28
*/

pragma solidity ^0.4.24;

interface IERC20Mintable {
    function mint(address[] _receiver, uint256[] _value, uint256[] _timestamp) external;
}
interface IERC20ImplUpgradeable {
    function getImplAddress() view external returns(address);
    function getMintBurnAddress() view external returns(address);
    function isImplAddress(address) view external returns(bool);
}
interface IERC20Burnable {
    function burn(address[] _receiver, uint256[] _value, uint256[] _timestamp) external;
    function burnAll(address[] _receiver) external;
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
    );

    event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
    );
}

contract ContractBase {
    
    Proxy proxy;

    constructor(address _proxy) public {
        proxy = Proxy(_proxy);
    }
    
}

library Address {
 
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

}

contract AuthModule {

    address primaryAdmin;
    address primaryIssuer;
    address primaryExchange;

    event JobshipTransferred(
        string  strType,
        address indexed previousOwner,
        address indexed newOwner,
        address indexed caller
      );

    constructor(
        address _admin, 
        address _issuer, 
        address _exchange
    ) 
        public 
    {
        primaryAdmin = _admin;
        primaryIssuer = _issuer;
        primaryExchange = _exchange;
    }

    function isAdmin(address _admin) public view returns (bool) {
        return primaryAdmin == _admin;
    }

    function isIssuer(address _issuer) public view returns (bool) {
        return primaryIssuer == _issuer;
    }

    function isExchange(address _exchange) public view returns (bool) {
        return primaryExchange == _exchange;
    }

    function transferIssuer(address _addr) public returns (bool) {
        require (_addr != address(0) && _addr != primaryIssuer, "_addr invalid");
        require (isIssuer(msg.sender) || isAdmin(msg.sender), "only issuer or admin");

        emit JobshipTransferred("issuer", primaryIssuer, _addr, msg.sender);
        primaryIssuer = _addr;
        return true;
    }

    function transferExchange(address _addr) public returns(bool) {
        require (_addr != address(0) && _addr != primaryExchange, "_addr invalid");
        require (isExchange(msg.sender) || isAdmin(msg.sender), "only exchange or admin");

        emit JobshipTransferred("exchange", primaryExchange, _addr, msg.sender);
        primaryExchange = _addr;
        return true;
    }
}
contract Pausable {

    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    function _pause() internal whenNotPaused {
        paused = true;
        emit Pause();
    }

    function _unpause() internal whenPaused {
        paused = false;
        emit Unpause();
    }

}


contract Authorization is ContractBase, Pausable{
    
    constructor(address _proxy) public ContractBase(_proxy) {

    }

    modifier onlyInside(address _sender) {
        require(proxy.isInsideContract(_sender), "Can only be called inside");
        _;
    }

    modifier onlyIssuer(address _sender) {
        AuthModule auth = AuthModule(proxy.getModule("AuthModule"));
        require(auth.isIssuer(_sender), "Need to be issuer");
        _;
    }

    modifier onlyAdmin(address _sender) {
        AuthModule auth = AuthModule(proxy.getModule("AuthModule"));
        require(auth.isAdmin(_sender), "Need to be admin");
        _;
    }

    modifier onlyExchange(address _sender) {
        AuthModule auth = AuthModule(proxy.getModule("AuthModule"));
        require(auth.isExchange(_sender), "Need to be exchange");
        _;
    }

    modifier onlyIssuerOrExchange(address _sender) {
        AuthModule auth = AuthModule(proxy.getModule("AuthModule"));
        require(auth.isIssuer(_sender) || auth.isExchange(_sender), "Need to be issuer or exchange");
        _;
    }

    modifier onlyTokenModule(address _sender) {
        require(_sender == proxy.getModule("TokenModule"), "Need to be tokenModule");
        _;
    }

    function unpause() public onlyAdmin(msg.sender)  {
        _unpause();
    }

    function pause() public onlyAdmin(msg.sender) {
        _pause();
    }

}

library LibMapAddressBool {

    struct MapAddressBool {
        mapping(address => MapValue) data;  // do not modify this variable outside
        uint256 length;
    }

    struct MapValue {
        bool value;
        bool inited;
    }

    function add(MapAddressBool storage self, address _key, bool _val) public returns (bool newAdded) {
        if(!self.data[_key].inited) {
            self.data[_key].inited = true;
            self.length++;
            newAdded = true;
        }
        self.data[_key].value = _val;
    }

    function remove(MapAddressBool storage self, address _key) public returns (bool removed) {
        if(self.data[_key].inited) {
            self.data[_key].inited = false;
            // self.data[_key].value = false;  // no need to reset value here
            self.length--;
            removed = true;
        }
    }

    function contain(MapAddressBool storage self, address _key) public view returns (bool) {
        return self.data[_key].inited;
    }

    function get(MapAddressBool storage self, address _key) public view returns (bool) {
        if(!self.data[_key].inited)
            return false;
        return self.data[_key].value; 
    }

    // function getLength(AddressBool storage self) public view returns (uint) {
    //     return self.length;
    // }
}




library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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


library StringUtils {
    /// @dev Does a byte-by-byte lexicographical comparison of two strings.
    /// @return a negative number if `_a` is smaller, zero if they are equal
    /// and a positive numbe if `_b` is smaller.
    function compare(string _a, string _b) returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }
    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string _a, string _b) returns (bool) {
        return compare(_a, _b) == 0;
    }
    /// @dev Finds the index of the first occurrence of _needle in _haystack
    function indexOf(string _haystack, string _needle) returns (int)
    {
    	bytes memory h = bytes(_haystack);
    	bytes memory n = bytes(_needle);
    	if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
    		return -1;
    	else if(h.length > (2**128 -1)) // since we have to be able to return -1 (if the char isn't found or input error), this function must return an "int" type with a max length of (2^128 - 1)
    		return -1;									
    	else
    	{
    		uint subindex = 0;
    		for (uint i = 0; i < h.length; i ++)
    		{
    			if (h[i] == n[0]) // found the first char of b
    			{
    				subindex = 1;
    				while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) // search until the chars don't match or until we reach the end of a or b
    				{
    					subindex++;
    				}	
    				if(subindex == n.length)
    					return int(i);
    			}
    		}
    		return -1;
    	}	
    }
}

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


contract Proxy {
    using Address for address;

    mapping(string => address) moduleMap;
    mapping(address => bool) insideContracts;   // all internal contract address, used to make sure only called from inside

    event AddInsideContract(address _contract);
    event AddInsideContracts(address[] _contracts);
    event RemoveInsideContract(address _contract);
    event UpdateModule(string _moduleName, address _preModule, address _newModule);

    modifier onlyAdmin() {
        AuthModule auth = AuthModule(getModule("AuthModule"));
        require(auth.isAdmin(msg.sender), "Need be admin");
        _;
    }
    
    constructor(address authModule) public {
        _updateModule("AuthModule", authModule, true);
    }

    function addInsideContract(address _contract) public onlyAdmin {
        _addInsideContract(_contract);
    }

    function _addInsideContract(address _contract) private {
        // require(insideContracts[_contract] == false, "Inside contract already exists");
        insideContracts[_contract] = true;
        emit AddInsideContract(_contract);
    }
    
    function addInsideContracts(address[] _contracts) public onlyAdmin {
        for(uint i = 0; i < _contracts.length; i++) {
            // require(insideContracts[_contracts[i]] == false, "Inside contract already exists");
            insideContracts[_contracts[i]] = true;
        }
        emit AddInsideContracts(_contracts);
    }

    function removeInsideContract(address _contract) public onlyAdmin {
        _removeInsideContract(_contract);
    }

    function _removeInsideContract(address _contract) private {
        delete insideContracts[_contract];
        emit RemoveInsideContract(_contract);
    }

    // TODO: need to check if the address is a contract
    function isInsideContract(address _contract) public view returns (bool) {
        return _contract.isContract() && insideContracts[_contract] == true;
    }

    function updateModule(string _moduleName, address _module, bool _insideContract) public onlyAdmin {
        _updateModule(_moduleName, _module, _insideContract);
    }

    function _updateModule(string _moduleName, address _module, bool _insideContract) private {
        address preModule = moduleMap[_moduleName];
        if(preModule != address(0))
            _removeInsideContract(preModule);
        moduleMap[_moduleName] = _module;
        if(_insideContract && _module != address(0))
            _addInsideContract(_module);
        emit UpdateModule(_moduleName, preModule, _module);
    }

    function getModule(string _moduleName) public view returns (address) {
        return moduleMap[_moduleName];
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


contract StorageModule is Authorization {

    using SafeMath for uint256;
    using LibMapAddressBool for LibMapAddressBool.MapAddressBool;
    using StringUtils for string;

    LibMapAddressBool.MapAddressBool shareholders;
    mapping(address => bool) investorWhitelist;
    mapping(address => bool) investorBlacklist;
    mapping(address => InvestorInfo) investorInfo;
    mapping(address => InvestorDocument) investorDocuments;
    mapping(uint => address) usedHashid;

    mapping(bytes32 => uint256) retailInvestorCounts;
    mapping(bytes32 => mapping(address => uint256)) retailInvestors;
    
    bool public isTXFrozen;
    uint256 public shareholderMaxAmount;
    string[] public allowCountrys;

    event AddInvestorToWhitelist(address _investor);
    event AddInvestorsToWhitelist(address[] _investors);
    event RemoveInvestorFromWhitelist(address _investor);
    event UpdateBlacklist(address[] _investors, bool _black);
    event SetShareholderMaxAmount(uint _oldValue, uint _newValue);
    event InitShareholders(address[] _shareholders, bool _original);
    event AddShareholder(address _shareholder, uint _balance);
    event RemoveShareholder(address _shareholder, uint _balance);
    // event AddInvestorInfo(address _investor, uint hashid, string _country, bool _kyc, uint _validDate);
    event UpdateInvestorInfo(address _investor, uint hashid, string _country, bool _kyc, uint _validDate, bool _pi);
    // event AddDocument(address _investor, string _url, uint _hash);
    event UpdateDocument(address _investor, string _url, uint _hash);

    struct Shareholder {
        bool inited;
        bool original;
    }

    //专业投资者 Pi,合规投资者,前x名合规投资者
    struct InvestorInfo {
        bool inited;
        uint hashid; //是投资者所有资料串在一起的hash值
        string country;//地区
        bool kyc;// 合规投资者认证
        uint validDate;
        bool pi; //is professional, pi和kyc必须要有一个是true
    }

    struct InvestorDocument {
        string url;
        uint hash;
    }

    constructor(address _proxy) public Authorization(_proxy) {
        
    }

    function freezeTX(bool _freeze) public onlyAdmin(msg.sender) whenNotPaused {
        isTXFrozen = _freeze;
    }

    function addInvestorToWhitelist(address _investor) external onlyIssuerOrExchange(msg.sender) whenNotPaused {
        investorWhitelist[_investor] = true;
        emit AddInvestorToWhitelist(_investor);
    }

    function addInvestorsToWhitelist(address[] _investors) external onlyIssuerOrExchange(msg.sender) whenNotPaused {
        for(uint i = 0; i < _investors.length; i++) {
            investorWhitelist[_investors[i]] = true;
        }
        emit AddInvestorsToWhitelist(_investors);
    }

    function updateBlacklist(address[] _investors, bool _black) external onlyIssuerOrExchange(msg.sender) whenNotPaused {
        for(uint i = 0; i < _investors.length; i++) {
            investorBlacklist[_investors[i]] = _black;
        }
        emit UpdateBlacklist(_investors, _black);
    }

    function removeInvestorFromWhitelist(address _investor) external onlyIssuerOrExchange(msg.sender) whenNotPaused {
        delete investorWhitelist[_investor];
        emit RemoveInvestorFromWhitelist(_investor);
    }

    function addRetailInvestor(address _investor) external onlyIssuerOrExchange(msg.sender) whenNotPaused {
        bytes32 _country= getInvestorCountry(_investor);
        if(retailInvestors[_country][_investor] != 0)
            return;
        retailInvestors[_country][_investor] = ++retailInvestorCounts[_country];
    }

    function getRetailInvestorCount(bytes32 _country) external view returns (uint256) {
        return retailInvestorCounts[_country];
    }

    function getRetailInvestor(address _investor) external view returns (uint256) {
        bytes32 _country= getInvestorCountry(_investor);
        return retailInvestors[_country][_investor];
    }

    function isInvestorInWhitelist(address _investor) external view returns (bool) {
        return investorWhitelist[_investor];
    }

    function isInBlacklist(address _investor) external view returns (bool) {
        return investorBlacklist[_investor];
    }

    function isProfessionalInvestor(address _investor) external view returns (bool) {
        return investorInfo[_investor].pi;
    }

    function setShareholderMaxAmount(uint256 _shareholderMaxAmount) public onlyIssuer(msg.sender) whenNotPaused {
        uint256 preValue = shareholderMaxAmount;
        shareholderMaxAmount = _shareholderMaxAmount;
        emit SetShareholderMaxAmount(preValue, shareholderMaxAmount);
    }

    // called after mint
    function initShareholders(address[] _shareholders, bool _original) public onlyInside(msg.sender) whenNotPaused {
        for(uint i = 0; i < _shareholders.length; i++) {
            shareholders.add(_shareholders[i], _original);
        }
        emit InitShareholders(_shareholders, _original);
    }

    // called after transaction or burn
    function updateShareholders(address _from, address _to) public onlyInside(msg.sender) whenNotPaused {
        TokenModule token = TokenModule(proxy.getModule("TokenModule"));
        uint balanceFrom = token.balanceOf(_from);
        uint balanceTo = token.balanceOf(_to);
        if(balanceFrom == 0)
            removeShareholder(_from, 0);
        // no need to check investors amount here, cause ComplicanceModule will do the job.
        // _to will be 0 while burn
        if(_to != address(0))
            addShareholder(_to, balanceTo); 
    }  

    function addShareholder(address _shareholder, uint _balance) private {
        bool newAdded = shareholders.add(_shareholder, false);
        if(newAdded)
            emit AddShareholder(_shareholder, _balance);
    }

    function removeShareholder(address _shareholder, uint _balance) private {
        bool removed = shareholders.remove(_shareholder);
        if(removed)
            emit RemoveShareholder(_shareholder, _balance);
    }

    function shareholderAmount() public view returns (uint256) {
        return shareholders.length;
    }

    function isShareholder(address _address) public view returns (bool) {
        return shareholders.contain(_address);
    }
    
    function shareholderExceeded(uint amount) public view returns (bool) {
        return shareholders.length + amount > shareholderMaxAmount;
    }

    function getInvestorCountry(address _address) public view returns (bytes32 result) {
        string memory country = investorInfo[_address].country;
        assembly {
            result := mload(add(country, 32))
        }
    }

    // function addInvestorInfo(
    //     address _investor, 
    //     uint _investorHash,
    //     string _country, 
    //     bool _kyc, 
    //     uint _validDate
    // ) 
    //     external 
    //     onlyIssuerOrExchange(msg.sender) 
    // {
    //     require(investorInfo[_investor].inited == false, "Investor already exists");
    //     investorInfo[_investor] = InvestorInfo(true, _investorHash, _country, _kyc, _validDate);
    //     emit AddInvestorInfo(_investor, _investorHash, _country, _kyc, _validDate);
    // }

    function updateInvestorInfo(
        address _investor, 
        uint _hashid,
        string _country, 
        bool _kyc, 
        uint _validDate ,
        bool _pi
    ) 
        external 
        onlyIssuerOrExchange(msg.sender) 
        whenNotPaused
        returns(bool)
    {
        // require(investorInfo[_investor].inited == true, "Investor do not exist");
        bool temp_pi = true; //temp_pi = _pi; // force set all guys is professional.
        require (_kyc || temp_pi, "require _kyc or _pi at less one be true");
        require (isAllowCountry(_country), "country not allow");
        require (_hashid != 0);
        require (usedHashid[_hashid] == address(0) || usedHashid[_hashid] == _investor);
        
        //uint oldhashid = investorInfo[_investor].hashid;
        investorInfo[_investor] = InvestorInfo(true, _hashid, _country, _kyc, _validDate, temp_pi);
        usedHashid[_hashid] = _investor;
        //if (oldhashid != _hashid) //
        //    delete usedHashid[oldhashid];
        emit UpdateInvestorInfo(_investor, _hashid, _country, _kyc, _validDate, temp_pi);
        return true;
    }

    function getInvestorInfo(address _investor) public view returns (uint, string, bool, uint, bool) {
        InvestorInfo storage info = investorInfo[_investor];
        return (info.hashid, info.country, info.kyc, info.validDate, info.pi);
    }

    // function addDocument(
    //     address _investor, 
    //     string _url, 
    //     uint _hash
    // ) 
    //     external 
    //     onlyIssuerOrExchange(msg.sender) 
    // {
    //     InvestorDocument storage doc = investorDocuments[_investor];
    //     require(doc.hash == 0, "Investor document already exists");
    //     investorDocuments[_investor] = InvestorDocument(_url, _hash);
    //     emit AddDocument(_investor, _url, _hash);
    // }

    function updateDocument(
        address _investor, 
        string _url, 
        uint _hash
    ) 
        external 
        onlyIssuerOrExchange(msg.sender) 
        whenNotPaused
    {
        // InvestorDocument storage doc = investorDocuments[_investor];
        // require(doc.hash != 0, "Investor document do not exists");
        investorDocuments[_investor] = InvestorDocument(_url, _hash);
        emit UpdateDocument(_investor, _url, _hash);
    }

    function getDocument(address _investor) external view returns (string, uint) {
        InvestorDocument storage doc = investorDocuments[_investor];
        return (doc.url, doc.hash);
    }

    function addAllowCountrys(string _country)
        external 
        onlyIssuerOrExchange(msg.sender)
        returns (bool)
    {
        bytes memory strmemct = bytes(_country);
        require (strmemct.length > 0, "country can not empty");

        uint aclen = allowCountrys.length;
        uint firstEmptyPlace = aclen;
        for (uint i=0; i < aclen; i++)
        {
            if (allowCountrys[i].equal(_country))
                return false;
            bytes memory strmem = bytes(allowCountrys[i]);
            if (strmem.length == 0 && firstEmptyPlace == aclen)
                firstEmptyPlace = i;
        }
        if (firstEmptyPlace != aclen)
            allowCountrys[firstEmptyPlace] = _country;
        else
            allowCountrys.push(_country);
        return true;
    }

    function removeAllowCountrys(string _country) 
        external
        onlyIssuerOrExchange(msg.sender)
        returns (bool) 
    {
        uint aclen = allowCountrys.length;
        for (uint i=0; i < aclen; i++)
        {
            if (allowCountrys[i].equal(_country))
            {
                delete allowCountrys[i];
                return true;
            }
        }
        return false;
    }

    function isAllowCountry(string _country)
        public
        returns(bool)
    {
        uint aclen = allowCountrys.length;
        for (uint i=0; i < aclen; i++)
        {
            if (allowCountrys[i].equal(_country)) {
                return true;
            }
        }
        return false;
    }
}