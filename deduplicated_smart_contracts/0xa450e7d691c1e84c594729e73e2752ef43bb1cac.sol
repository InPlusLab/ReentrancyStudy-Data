/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
   
    function getMonth(uint timestamp) internal pure returns (uint month) {
        uint year;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        uint year;
        uint month;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
   
    function getYear(uint timestamp) internal pure returns (uint year) {
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
   
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }
        function add(Role storage role, address account) internal {
            require(!has(role, account), "Roles: account already has role");
            role.bearer[account] = true;
        }
        function remove(Role storage role, address account) internal {
            require(has(role, account), "Roles: account does not have role");
            role.bearer[account] = false;
        }
        function has(Role storage role, address account) internal view returns (bool) {
            require(account != address(0), "Roles: account is the zero address");
            return role.bearer[account];
        }
    }
   
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}  

interface IERC721{
   
    function ownerOf(uint256 _tokenId) external view returns (address _owner); // from ERC721
    function setUpdateOperator(uint256 assetId,address operator) external;
    function exists(uint256 assetId) external view returns (bool);
    function isAuthorized(address operator, uint256 assetId) external view returns (bool);
    function updateOperator(uint256 assetId) external view returns (bool);
    function balanceOf(address _owner) external view returns (uint256 _balance);
    function tokenOfOwnerByIndex(address,uint256) external view returns (uint256 _etateTokenId);
    function isApprovedForAll(address, address) external view returns (bool auth);
}

struct Lease{
    address lessor;
    address lessee;
    uint256 assetId;
    string nftType;
   
}

struct LeaseDetail{
    uint256 rentAmount;
    uint256 deposit;
    uint monthsPaid;
    uint gracePeriod;
    uint leaseLength;
    uint dateSigned;
    string rentToken;
    bool isOpen;
    bool isLeased;
    bool autoPay;
    bool autoRegenerate;
}
   
struct Acceptedtoken{
    string tokenSymbol;
    address tokenAddress;
    bool added;
}

contract DCLRentStorage{
   
    using Roles for Roles.Role;
    using BokkyPooBahsDateTimeLibrary for uint;
    Roles.Role _platformAdmins;
   
    address[] _platformAdminsArr;
    address dclLandProxy;
    address dclEstateProxy;
    address _owner;
   
    uint _adminCount = 0;
    uint public leaseCount = 0;
    uint256 platformFee = 5;
    uint256 public minERCRent = 100000000000000000000;
    uint256 public minETHRent = 20000000000000000;
    uint256 public maliciousLimit = 2;
   
    mapping(string => mapping(uint256 => Lease)) public leaseByNftTypeAssetId;
    mapping(string => mapping(uint256 => LeaseDetail)) public leaseDetailByNftTypeAssetId;
    mapping(string => mapping(uint256 => uint256)) public leaseIndexByNftByAssetId;
    mapping(string => Acceptedtoken) public acceptedTokensBySymbol;
    mapping(string => uint256) public depositsByTokenSymbol;
    mapping(string => address) public nftRegistryByType;
    mapping(address => uint256) public landlordMaliciousCount;

    Lease[] public allLeases;
    bytes32[] public acceptedTokenSymbols;
   
    Lease stubLease = Lease(address(0), address(0), 0, "");
    LeaseDetail stubLeaseDetail = LeaseDetail(0,0,0,0,0,0,"",false, false, false, false);
   
    event RentPaid(string nftType, uint256 assetId, address lessee, address lessor, uint256 amount, string rentToken);
    event LeaseCreated(string nftType, uint256 assetId, address lessor, uint256 rentAmount, uint leaseLength, uint gracePeriod, string rentToken);
    event LeaseUpdated(string nftType, uint256 assetId, address lessor, uint256 rentAmount, uint leaseLength, uint gracePeriod, string rentToken);
    event LeaseCanceled(string nftType, uint256 assetId, address lessor, address depositTo);
    event LeaseRemoved(string nftType, uint256 assetId);
    event LeaseAccepted(string nftType, uint256 assetId, address lessee);
    event LeaseCompleted(string nftType, uint256 assetId);
    event LeaseTerminated(string nftType, uint256 assetId, address lessor);
}

contract DCLRent is DCLRentStorage {
   
    constructor() public{
        _owner = msg.sender;
        allLeases.push(stubLease);
        leaseCount++;
    }
   
    function addAdmin(address newAdmin) public{
        require(_owner == msg.sender || _platformAdmins.has(msg.sender));
        _platformAdminsArr.push(newAdmin);
        _platformAdmins.add(newAdmin);
        _adminCount++;
    }
   
    function addNFTType(string memory nftType, address nftRegistry) public{
        require(_platformAdmins.has(msg.sender));
        nftRegistryByType[nftType] = nftRegistry;
    }
   
    function getAcceptedTokenSymbols()public view returns(bytes32[] memory tokenSymbols){
        return acceptedTokenSymbols;
    }
   
    function updatePlatformFee(uint256 newFee) public{
        require(_platformAdmins.has(msg.sender));
        platformFee = newFee;
    }
   
    function addSupportedToken(string memory symbol, address token) public{
        require(_platformAdmins.has(msg.sender));
        if(!acceptedTokensBySymbol[symbol].added){
            acceptedTokensBySymbol[symbol] = Acceptedtoken(symbol, token, true);
            acceptedTokenSymbols.push(stringToBytes32(symbol));
        }
    }
   
    function changeMaliciousLimit(uint256 newLimit) public{
        require(_platformAdmins.has(msg.sender));
        maliciousLimit = newLimit;
    }
   
    function changeMalLandlordCount(address landlord, uint8 count) public{
        require(_platformAdmins.has(msg.sender));
        landlordMaliciousCount[landlord] = count;
    }
   
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        if (bytes(source).length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
   
    function isLeasedByAssetId(string memory _nftType, uint256 _assetId) public view returns(bool isLeased){
        return leaseDetailByNftTypeAssetId[_nftType][_assetId].isLeased;
    }
   
    function acceptLease(string memory _nftType, uint256 _assetId, bool _autoPay) public payable{
        require(!isLeasedByAssetId(_nftType, _assetId));
        require(leaseDetailByNftTypeAssetId[_nftType][_assetId].isOpen);
        require(IERC721(nftRegistryByType[leaseByNftTypeAssetId[_nftType][_assetId].nftType]).ownerOf(_assetId) != msg.sender);
       
        uint256 balance;
        if(keccak256(abi.encodePacked(leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken)) == (keccak256(abi.encodePacked("ETH")))){
            balance = msg.sender.balance;
            require(msg.value >= leaseDetailByNftTypeAssetId[_nftType][_assetId].rentAmount + leaseDetailByNftTypeAssetId[_nftType][_assetId].deposit);
        }
        else{
            balance = IERC20(acceptedTokensBySymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken].tokenAddress).balanceOf(msg.sender);
        }
        require(balance >= (leaseDetailByNftTypeAssetId[_nftType][_assetId].rentAmount + leaseDetailByNftTypeAssetId[_nftType][_assetId].deposit));
        leaseByNftTypeAssetId[_nftType][_assetId].lessee = msg.sender;
        leaseDetailByNftTypeAssetId[_nftType][_assetId].isOpen = false;
        leaseDetailByNftTypeAssetId[_nftType][_assetId].isLeased = true;
        leaseDetailByNftTypeAssetId[_nftType][_assetId].isLeased = true;
        leaseDetailByNftTypeAssetId[_nftType][_assetId].autoPay = _autoPay;
        leaseDetailByNftTypeAssetId[_nftType][_assetId].dateSigned = now;
        IERC721(nftRegistryByType[leaseByNftTypeAssetId[_nftType][_assetId].nftType]).setUpdateOperator(_assetId, msg.sender);
        allLeases[leaseIndexByNftByAssetId[_nftType][_assetId]] = leaseByNftTypeAssetId[_nftType][_assetId];
        require(_tenantMakeDeposit(_nftType, _assetId));
        require(_payRent(_nftType, _assetId));
        emit LeaseAccepted(_nftType, _assetId, msg.sender);
    }
   
    function createLease(Lease memory newLease, LeaseDetail memory newLeaseDetail, bool isUpdate) public{
        require(acceptedTokensBySymbol[newLeaseDetail.rentToken].added || (keccak256(abi.encodePacked(newLeaseDetail.rentToken)) == (keccak256(abi.encodePacked("ETH")))));
        require(!isLeasedByAssetId(newLease.nftType, newLease.assetId));
        if(isUpdate){
        require(!leaseDetailByNftTypeAssetId[newLease.nftType][newLease.assetId].isOpen);
        }
        require(IERC721(nftRegistryByType[newLease.nftType]).exists(newLease.assetId));
        require(IERC721(nftRegistryByType[newLease.nftType]).ownerOf(newLease.assetId) == msg.sender || _platformAdmins.has(msg.sender));
        require(IERC721(nftRegistryByType[newLease.nftType]).isApprovedForAll(msg.sender, address(this)));
        require(landlordMaliciousCount[msg.sender] <= maliciousLimit);
        require(_createLease(newLease, newLeaseDetail));
        if(isUpdate){
            emit LeaseUpdated(newLease.nftType, newLease.assetId, msg.sender, newLeaseDetail.rentAmount, newLeaseDetail.leaseLength, newLeaseDetail.gracePeriod, newLeaseDetail.rentToken);
        }
        else{
            emit LeaseCreated(newLease.nftType, newLease.assetId, msg.sender, newLeaseDetail.rentAmount, newLeaseDetail.leaseLength, newLeaseDetail.gracePeriod, newLeaseDetail.rentToken);
        }
    }
   
    function _createLease(Lease memory newLease, LeaseDetail memory newLeaseDetail) internal returns(bool){
        if((keccak256(abi.encodePacked(newLeaseDetail.rentToken)) != (keccak256(abi.encodePacked("ETH"))))){
            if(newLeaseDetail.rentAmount < minERCRent){
                return false;
            }
        }
        else{
            if(newLeaseDetail.rentAmount < minETHRent){
                return false;
            }
        }
 
        leaseDetailByNftTypeAssetId[newLease.nftType][newLease.assetId] = newLeaseDetail;
        leaseByNftTypeAssetId[newLease.nftType][newLease.assetId] = newLease;
       
        if(leaseIndexByNftByAssetId[newLease.nftType][newLease.assetId] == 0){
            allLeases.push(newLease);
            leaseIndexByNftByAssetId[newLease.nftType][newLease.assetId] = leaseCount;
            leaseCount++;
        }
        else{
            allLeases[leaseIndexByNftByAssetId[newLease.nftType][newLease.assetId]] = newLease;
        }
        return true;
    }
   
    function _eraseLease(string memory _nftType, uint256 _assetId, bool checkRegen, bool malicious) internal returns(bool){
        //rentHeldByNftTypeAssetId[_nftType][_assetId] = 0;
        address landlord = leaseByNftTypeAssetId[_nftType][_assetId].lessor;
        if(checkRegen){
            if(leaseDetailByNftTypeAssetId[_nftType][_assetId].autoRegenerate){
                leaseByNftTypeAssetId[_nftType][_assetId].lessee = address(0);
                leaseDetailByNftTypeAssetId[_nftType][_assetId].dateSigned = 0;
                leaseDetailByNftTypeAssetId[_nftType][_assetId].isOpen = true;
                leaseDetailByNftTypeAssetId[_nftType][_assetId].isLeased = false;
                leaseDetailByNftTypeAssetId[_nftType][_assetId].monthsPaid = 0;
            }
            else{
                leaseDetailByNftTypeAssetId[_nftType][_assetId] = stubLeaseDetail;        
                leaseByNftTypeAssetId[_nftType][_assetId] = stubLease;  
            }
        }
        else{
                leaseDetailByNftTypeAssetId[_nftType][_assetId] = stubLeaseDetail;        
                leaseByNftTypeAssetId[_nftType][_assetId] = stubLease;            
        }
        if(malicious){
            if(isPlatformAuthorized(_nftType)){
                IERC721(nftRegistryByType[_nftType]).setUpdateOperator(_assetId, address(this));
            }
            landlordMaliciousCount[landlord] = landlordMaliciousCount[landlord] + 1;
        }
        allLeases[leaseIndexByNftByAssetId[_nftType][_assetId]] = leaseByNftTypeAssetId[_nftType][_assetId];
        return true;
    }
   
    function _checkLease(string memory _nftType, uint256 _assetId)internal view returns(bool){
        if(isLeasedByAssetId(_nftType, _assetId) &&
        !leaseDetailByNftTypeAssetId[_nftType][_assetId].isOpen && isLeasedByAssetId(_nftType, _assetId)){
            return true;
        }
        else{
            return false;
        }
    }
   
    function isRentDue(string memory _nftType, uint256 _assetId) public view returns (bool rentDue){
        uint today = now;
        if(_checkLease(_nftType,_assetId))
        {
            if(isRentOverDue(_nftType, _assetId)){
                return true;
            }
            else{
                if(today >
                BokkyPooBahsDateTimeLibrary.addMonths(leaseDetailByNftTypeAssetId[_nftType][_assetId].dateSigned,
                leaseDetailByNftTypeAssetId[_nftType][_assetId].monthsPaid)){
                    return true;
                }
                else{
                    return false;
                }
            }
        }
        else{
            return false;
        }
    }
   
    function isRentOverDue(string memory _nftType, uint256 _assetId) public view returns (bool){
        uint today = now;
        if(_checkLease(_nftType, _assetId))
        {
            if(leaseDetailByNftTypeAssetId[_nftType][_assetId].monthsPaid >= leaseDetailByNftTypeAssetId[_nftType][_assetId].leaseLength){
                return false;
            }
            else{
                if(today > BokkyPooBahsDateTimeLibrary.addDays(
                BokkyPooBahsDateTimeLibrary.addMonths(leaseDetailByNftTypeAssetId[_nftType][_assetId].dateSigned, leaseDetailByNftTypeAssetId[_nftType][_assetId].monthsPaid),
                leaseDetailByNftTypeAssetId[_nftType][_assetId].gracePeriod)){
                    return true;
                }
                else{
                    return false;
                }
            }
        }
        else{
            return false;
        }
    }
   
    function landlordCancelLease(string memory _nftType, uint256 _assetId) public{
        require(isLeasedByAssetId(_nftType, _assetId));
        require(!leaseDetailByNftTypeAssetId[_nftType][_assetId].isOpen);
        require(IERC721(nftRegistryByType[leaseByNftTypeAssetId[_nftType][_assetId].nftType]).exists(_assetId));
        require(IERC721(nftRegistryByType[leaseByNftTypeAssetId[_nftType][_assetId].nftType]).ownerOf(_assetId) == msg.sender);
        require( _transferTenantDeposit(_nftType, _assetId, leaseByNftTypeAssetId[_nftType][_assetId].lessee));
        require(_eraseLease(_nftType, _assetId, false, true));
        emit LeaseCanceled(leaseByNftTypeAssetId[_nftType][_assetId].nftType, leaseByNftTypeAssetId[_nftType][_assetId].assetId, leaseByNftTypeAssetId[_nftType][_assetId].lessor, leaseByNftTypeAssetId[_nftType][_assetId].lessee);
    }
   
    function landlordRemoveLease(string memory _nftType, uint256 _assetId) public{
        require(!isLeasedByAssetId(_nftType, _assetId));
        require(!isLeaseCompleted(_nftType, _assetId));
        require(leaseDetailByNftTypeAssetId[_nftType][_assetId].isOpen);
        require(IERC721(nftRegistryByType[leaseByNftTypeAssetId[_nftType][_assetId].nftType]).exists(_assetId));
        require(IERC721(nftRegistryByType[leaseByNftTypeAssetId[_nftType][_assetId].nftType]).ownerOf(_assetId) == msg.sender);
        require(_eraseLease(_nftType,_assetId, false, false));
        emit LeaseRemoved(_nftType, _assetId);
    }
   
    function landlordTerminateLease(string memory _nftType, uint256 _assetId) public{
        require(isLeasedByAssetId(_nftType, _assetId));
        require(isRentOverDue(_nftType, _assetId));
        require(!isLeaseCompleted(_nftType, _assetId));
        require(IERC721(nftRegistryByType[leaseByNftTypeAssetId[_nftType][_assetId].nftType]).ownerOf(_assetId) == msg.sender);
        require(_transferTenantDeposit(_nftType, _assetId, leaseByNftTypeAssetId[_nftType][_assetId].lessor));
        address lessor =leaseByNftTypeAssetId[_nftType][_assetId].lessor;
        require(_eraseLease(_nftType, _assetId, true, false));
        emit LeaseTerminated(_nftType, _assetId, lessor);
    }
   
    function tenantCancelLease(string memory _nftType, uint256 _assetId) public{
        require(isLeasedByAssetId(_nftType, _assetId));
        require(!isLeaseCompleted(_nftType, _assetId));
        require(leaseByNftTypeAssetId[_nftType][_assetId].lessee == msg.sender);
        require(_transferTenantDeposit(_nftType, _assetId, leaseByNftTypeAssetId[_nftType][_assetId].lessor));
        require(_eraseLease(_nftType, _assetId, true, false));
        emit LeaseCanceled(_nftType, _assetId, leaseByNftTypeAssetId[_nftType][_assetId].lessor, leaseByNftTypeAssetId[_nftType][_assetId].lessor);
    }
   
    function _tenantMakeDeposit(string memory _nftType, uint256 _assetId) internal returns (bool){
        uint256 deposit = leaseDetailByNftTypeAssetId[_nftType][_assetId].deposit;
        if(deposit > 0){
            if((keccak256(abi.encodePacked(leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken)) != (keccak256(abi.encodePacked("ETH"))))){
            uint256 lesseeBalance = IERC20(acceptedTokensBySymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken].tokenAddress).balanceOf(msg.sender);
            require(lesseeBalance >= deposit);
            IERC20(acceptedTokensBySymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken].tokenAddress).transferFrom(leaseByNftTypeAssetId[_nftType][_assetId].lessee, address(this), deposit);
            }
            depositsByTokenSymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken] += deposit;
        }
        return true;
    }
   
    function _transferTenantDeposit(string memory _nftType, uint256 _assetId, address _sendDepositTo) internal returns (bool){
        require(leaseByNftTypeAssetId[_nftType][_assetId].lessor == IERC721(nftRegistryByType[_nftType]).ownerOf(_assetId));
       
        if(leaseDetailByNftTypeAssetId[_nftType][_assetId].deposit > 0){    
            if((keccak256(abi.encodePacked(leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken)) == (keccak256(abi.encodePacked("ETH"))))){
                address payable depositReceiver = payable(_sendDepositTo);
                depositReceiver.transfer(leaseDetailByNftTypeAssetId[_nftType][_assetId].deposit);
            }
            else{
                IERC20(acceptedTokensBySymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken].tokenAddress).transfer(_sendDepositTo, leaseDetailByNftTypeAssetId[_nftType][_assetId].deposit);
            }
            depositsByTokenSymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken] -= leaseDetailByNftTypeAssetId[_nftType][_assetId].deposit;
        }
        return true;
    }
   
    function adminTerminateLease(string memory _nftType, uint256 _assetId, address _sendDepositTo, bool malicious) public {
        require(isLeasedByAssetId(_nftType, _assetId));
        require(_platformAdmins.has(msg.sender));
        require(_transferTenantDeposit(_nftType, _assetId, _sendDepositTo));
        address lessor = leaseByNftTypeAssetId[_nftType][_assetId].lessor;
        if(malicious){
            require(_eraseLease(_nftType, _assetId, false, true));
        }
        else{
            require(_eraseLease(_nftType, _assetId, true, false));
        }
        emit LeaseTerminated(_nftType, _assetId, lessor);
    }
   
    function adminRemoveLease(string memory _nftType, uint256 _assetId) public {
        require(!isLeasedByAssetId(_nftType, _assetId));
        require(leaseDetailByNftTypeAssetId[_nftType][_assetId].isOpen);
        require(_platformAdmins.has(msg.sender));
        require(_eraseLease(_nftType, _assetId, false, false));
        emit LeaseRemoved(_nftType, _assetId);
    }
   
    function adminWithdraw(string memory token)public{
        require(_platformAdmins.has(msg.sender));
        require(acceptedTokensBySymbol[token].added);
        if((keccak256(abi.encodePacked(token)) == (keccak256(abi.encodePacked("ETH"))))){
            uint256 platformBalance = address(this).balance;
            platformBalance -= depositsByTokenSymbol[token];
            uint256 platformAdminSplit = platformBalance / _adminCount;
            for(uint256 i = 0; i < _adminCount; i++){
                address payable admin = payable(_platformAdminsArr[i]);
                admin.transfer(platformAdminSplit);
            }  
        }
        else{
            require(IERC20(acceptedTokensBySymbol[token].tokenAddress).balanceOf(address(this)) > 1000000000000000000);
            uint256 platformBalance = IERC20(acceptedTokensBySymbol[token].tokenAddress).balanceOf(address(this));
            platformBalance -= depositsByTokenSymbol[token];
            uint256 platformAdminSplit = platformBalance / _adminCount;
            for(uint256 i = 0; i < _adminCount; i++){
                IERC20(acceptedTokensBySymbol[token].tokenAddress).transfer(_platformAdminsArr[i], platformAdminSplit);
            }  
        }
    }
   
    function isLeaseCompleted(string memory _nftType, uint256 _assetId) public view returns(bool){
        if(isLeasedByAssetId(_nftType, _assetId)){
        if(leaseDetailByNftTypeAssetId[_nftType][_assetId].monthsPaid >= leaseDetailByNftTypeAssetId[_nftType][_assetId].leaseLength){
            if(now > BokkyPooBahsDateTimeLibrary.addMonths(leaseDetailByNftTypeAssetId[_nftType][_assetId].dateSigned, leaseDetailByNftTypeAssetId[_nftType][_assetId].leaseLength)){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
        }
        else{
            return false;
        }
    }
   
    function _payRent(string memory _nftType, uint256 _assetId) internal returns(bool){
        uint256 platformCut =  leaseDetailByNftTypeAssetId[_nftType][_assetId].rentAmount * platformFee / 100;
        uint256 monthlyRent = leaseDetailByNftTypeAssetId[_nftType][_assetId].rentAmount - platformCut;// - rentHeld;
        uint256 lesseeBalance;
       
        if((keccak256(abi.encodePacked(leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken)) == (keccak256(abi.encodePacked("ETH"))))){
            lesseeBalance = leaseByNftTypeAssetId[_nftType][_assetId].lessee.balance;
            require(lesseeBalance >= leaseDetailByNftTypeAssetId[_nftType][_assetId].rentAmount);
            require(msg.value >= leaseDetailByNftTypeAssetId[_nftType][_assetId].rentAmount);
            address payable landlord = payable(leaseByNftTypeAssetId[_nftType][_assetId].lessor);
            uint256 rentPaid = msg.value;
            require(rentPaid >= monthlyRent);
            landlord.transfer(monthlyRent);
        }
        else{
            lesseeBalance = IERC20(acceptedTokensBySymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken].tokenAddress).balanceOf(leaseByNftTypeAssetId[_nftType][_assetId].lessee);
            require(lesseeBalance >= leaseDetailByNftTypeAssetId[_nftType][_assetId].rentAmount);
            IERC20(acceptedTokensBySymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken].tokenAddress).transferFrom(leaseByNftTypeAssetId[_nftType][_assetId].lessee, leaseByNftTypeAssetId[_nftType][_assetId].lessor, monthlyRent);
            IERC20(acceptedTokensBySymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken].tokenAddress).transferFrom(leaseByNftTypeAssetId[_nftType][_assetId].lessee, address(this), platformCut);

        }
        leaseDetailByNftTypeAssetId[_nftType][_assetId].monthsPaid += 1;
        allLeases[leaseIndexByNftByAssetId[_nftType][_assetId]] = leaseByNftTypeAssetId[_nftType][_assetId];
        emit RentPaid(_nftType, _assetId, leaseByNftTypeAssetId[_nftType][_assetId].lessee, leaseByNftTypeAssetId[_nftType][_assetId].lessor, leaseDetailByNftTypeAssetId[_nftType][_assetId].rentAmount, leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken);
        return true;
    }
   
    function payRent(string memory _nftType, uint256 _assetId) public payable{
        require(acceptedTokensBySymbol[leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken].added || (keccak256(abi.encodePacked(leaseDetailByNftTypeAssetId[_nftType][_assetId].rentToken))) == (keccak256(abi.encodePacked("ETH"))), "Token not supported");
        require(isLeasedByAssetId(_nftType, _assetId));
        require(!leaseDetailByNftTypeAssetId[_nftType][_assetId].isOpen);
        require(msg.sender == leaseByNftTypeAssetId[_nftType][_assetId].lessee || _platformAdmins.has(msg.sender));
        require(IERC721(nftRegistryByType[_nftType]).exists(_assetId));
        require(leaseDetailByNftTypeAssetId[_nftType][_assetId].monthsPaid < leaseDetailByNftTypeAssetId[_nftType][_assetId].leaseLength);
        require(leaseByNftTypeAssetId[_nftType][_assetId].lessor == IERC721(nftRegistryByType[_nftType]).ownerOf(_assetId));
        require(isRentDue(_nftType, _assetId));
        require(_payRent(_nftType, _assetId));
    }
   
    function isAdmin(address adminAddress) public view returns(bool){
        return _platformAdmins.has(adminAddress);
    }

    function isPlatformAuthorized(string memory _nftType) public view returns (bool){
        return IERC721(nftRegistryByType[_nftType]).isApprovedForAll(msg.sender, address(this));
    }
}