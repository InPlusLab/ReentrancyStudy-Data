/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// import "./IERC20.sol";
/////////////////////////////////////////////////////////////////////////////////

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// import "../Roles.sol";
/////////////////////////////////////////////////////////////////////////////////
pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// 
/////////////////////////////////////////////////////////////////////////////////


contract TrustedRole {
    using Roles for Roles.Role;

    event TrustedAdded(address indexed account);
    event TrustedRemoved(address indexed account);

    Roles.Role private _trusted;

    constructor () internal {
        _addTrusted(msg.sender);
    }

    modifier onlyTrusted() {
        require(isTrusted(msg.sender), "TrusRole: caller does not have the Minter role");
        _;
    }

    function isTrusted(address account) public view returns (bool) {
        return _trusted.has(account);
    }

    function addTrusted(address account) public onlyTrusted {
        _addTrusted(account);
    }

    function renounceMinter() public {
        _removeTrusted(msg.sender);
    }

    function _addTrusted(address account) internal {
        _trusted.add(account);
        emit TrustedAdded(account);
    }

    function _removeTrusted(address account) internal {
        _trusted.remove(account);
        emit TrustedRemoved(account);
    }
}

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// PiramidTemplate Interface
/////////////////////////////////////////////////////////////////////////////////
interface IPiramid{
    //using SafeMath for uint;
    
    function addTrustedByOwner(address account) external;
    
    function addTrusted(address account) external;
     
    function setOwner(address account) external payable ;
        
    function transferAnyERC20Token(IERC20 tokenAddress, address toaddr, uint tokens) external returns (bool success) ;
    
    function setTrustDoInit(address account) external payable ;
    
    function initValue(string calldata _namepiramid, int _levels, int _countatlevel, address _feeaddr, address _feeaddr2, address _firstaddr) external ;
    
    function setSumLevel(int _level, uint sum) external ;
    
    function setFeeAddr(address _addr) external payable ;
    
    function setFeeAddr2(address _addr) external payable ;
    
    function setFeeFirstPercent(uint _perc) external payable ;
    
    function getFeeSums() external view returns(uint _Payments1, uint _Payments2) ;
    
    function setBlockPayment(address _addr) external payable ;
    
    function unsetBlockPayment(address _addr) external payable ;
    
    function getBlockPayment(address _addr) external view returns(bool _Result) ;
    
    function getName() external view returns(string memory) ;
    
    function getLevels() external view returns(int) ;
    
    function getSlotsOnLevel() external view returns(int _SlotsOnLevel) ;
    
    function getSumOneLevel(int _level) external view returns(uint) ;
    
    function getInfoByAddr(address _addr) external view returns(address _parentaddr, address _realpositionaddr, address _thisaddr, int _countchildren, uint _countallref) ;
    
    function getInfoByAddrAnLevel(address _addr, int _level) external view returns(address _thisaddr, uint _allslots, uint _freeslots, uint _paidslots, uint _paidamount) ;
    
    function getPaymentInfoByLevel(int _level, address _parentaddr) external view returns(int _retLevel, uint _retSum, address _retAddress, uint _retAllSlots, uint _retFreeSlots) ;
    
    function addPartner(address _addrPartner, uint _percentPartner) external payable returns(int _idPartner) ;
    
    function getPartner(int _idPartner) external view returns(address _addrPartner, uint _percentPartner, int _idPartnerRet, uint _Paid) ;
    
    function changePartnerInfo(int _idPartner, address _addrPartner, uint _Percent) external payable ;
    
    function getNeadPaymentCount(address _addr) external view returns (int _countNead) ;
    
    function getNeadPaymentAddr(address _addr, int _pos) external view returns (address _NeadAddr) ;
    
    function getNeadPaymentSum(address _addr, int _pos) external view returns (uint _NeadAddr) ;
    
    function destroyNeadPayment(address _addr) external ;
    
    function setComlitePay(address _addr) external ;
    
    function addPayment(address _addrParent, address _addrPayer, int _idPartner) external payable returns(address _realposition) ;
    
    function getDownAddrWithFreeSlots(address _addrParrent) external view returns(address _freeAddr) ;
    
    function checkPresentAddr(address _addr) external view returns(bool _retPresent) ;
    
    function checkComplitePay(address _addr) external view returns(bool _retPresent) ;
    
    function checkCompliteGenerateTable(address _addr) external view returns(bool _retPresent) ;
    
    function getFullSumPay() external view returns(uint retSum) ;
}



//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// PiramidTemplate
/////////////////////////////////////////////////////////////////////////////////
contract PiramidV1Manadge is TrustedRole{
    
    event SetNewOwner(address Who, address What);
    
    address private _owner;
    mapping (string=>IPiramid) Piramids;
    bool private initComplite = false;
    
    constructor() public payable{
        _owner = msg.sender;
    }
    
    function () external payable {
        
        if(msg.value>0){
            address payable owner = address(uint160(_owner));
            owner.transfer(address(this).balance);
            //address(uint160(owner)).transfer(address(this).balance);
        }
    }
    
    modifier onlyOwner() {
        require(_owner!=msg.sender, "Piramid: caller not owner");
        _;
    }
    
    function addTrustedByOwner(address account) public onlyTrusted {
        _addTrusted(account);
    }
     
    function setOwner(address account) public onlyTrusted payable {
        emit SetNewOwner(msg.sender, account);
        _owner = address(account);
    }
    
    
    function initAll(address _pir1, address _pir2, address _pir3) public onlyTrusted payable{
        require(!initComplite, 'Already initialization!');
        
        string memory NamePir = 'beginner';
        Piramids[NamePir] = IPiramid(_pir1);
        pirSetTrustDoInit(NamePir, address(this));
        pirInitValue(NamePir, NamePir, 6, 5, _owner, _owner, _owner);
        pirSetSumLevel(NamePir, 0, uint(500000000000000));
        pirSetSumLevel(NamePir, 1, uint(750000000000000));
        pirSetSumLevel(NamePir, 2, uint(350000000000000));
        pirSetSumLevel(NamePir, 3, uint(500000000000000));
        pirSetSumLevel(NamePir, 4, uint(750000000000000));
        pirSetSumLevel(NamePir, 5, uint(900000000000000));
        pirSetSumLevel(NamePir, 6, uint(1250000000000000));
        
        NamePir = 'middle';
        Piramids[NamePir] = IPiramid(_pir2);
        pirSetTrustDoInit(NamePir, address(this));
        pirInitValue(NamePir, NamePir, 8, 4, _owner, _owner, _owner);
        pirSetSumLevel(NamePir, 0, uint(2000000000000000));
        pirSetSumLevel(NamePir, 1, uint(3500000000000000));
        pirSetSumLevel(NamePir, 2, uint(1250000000000000));
        pirSetSumLevel(NamePir, 3, uint(1750000000000000));
        pirSetSumLevel(NamePir, 4, uint(2000000000000000));
        pirSetSumLevel(NamePir, 5, uint(2750000000000000));
        pirSetSumLevel(NamePir, 6, uint(3250000000000000));
        pirSetSumLevel(NamePir, 7, uint(3500000000000000));
        pirSetSumLevel(NamePir, 8, uint(5000000000000000));
        
        NamePir = 'big';
        Piramids[NamePir] = IPiramid(_pir3);
        pirSetTrustDoInit(NamePir, address(this));
        pirInitValue(NamePir, NamePir, 7, 7, _owner, _owner, _owner);
        pirSetSumLevel(NamePir, 0, uint(40000000000000000));
        pirSetSumLevel(NamePir, 1, uint(60000000000000000));
        pirSetSumLevel(NamePir, 2, uint(25000000000000000));
        pirSetSumLevel(NamePir, 3, uint(35000000000000000));
        pirSetSumLevel(NamePir, 4, uint(45000000000000000));
        pirSetSumLevel(NamePir, 5, uint(65000000000000000));
        pirSetSumLevel(NamePir, 6, uint(90000000000000000));
        pirSetSumLevel(NamePir, 7, uint(140000000000000000));
        initComplite = true;
    }
        
    
    function initAllSmall(address _pir1, address _pir2, address _pir3) public onlyTrusted payable{
        require(!initComplite, 'Already initialization!');
        
        string memory NamePir = 'beginner';
        Piramids[NamePir] = IPiramid(_pir1);
        
        NamePir = 'middle';
        Piramids[NamePir] = IPiramid(_pir2);
        
        NamePir = 'big';
        Piramids[NamePir] = IPiramid(_pir3);
        
        initComplite = true;
    }
    
    function GameOver() public onlyOwner payable {
        selfdestruct(address(uint160(_owner)));
    }
    
    function transferAnyERC20Token(IERC20 tokenAddress, address toaddr, uint tokens) public onlyTrusted returns (bool success) {
        return IERC20(tokenAddress).transfer(toaddr, tokens);
    }
    
    function setNewAddressPir(string memory _namepirm, address _account) public onlyTrusted {
        
        Piramids[_namepirm] = IPiramid(_account);
    }
    
    function getAddreesPir(string memory _namepir) public view returns (address AddressPiramid){
        
        return address(Piramids[_namepir]);
    }
    
    
    function addTrustedToAll(address account) public onlyTrusted{
        
        pirAddTrusted('beginner', account);
        
        pirAddTrusted('middle', account);
        
        pirAddTrusted('big', account);
    }
    
    function pirSetTrustDoInit(string memory _namepir, address account) public onlyTrusted {
        
        require(!initComplite, 'Already complite');
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].setTrustDoInit.selector, account);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.setTrustDoInit: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            //////
        }
    }
    
    
    function pirAddTrusted(string memory _namepir, address account) public onlyTrusted returns (bool result){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].addTrusted.selector, account);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.addTrusted: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (bool));
        }
    }
    
    function pirInitValue(string memory _namepir, string memory _namepiramid, int _levels, int _countatlevel, address _feeaddr, address _feeaddr2, address _firstaddr) internal {
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].initValue.selector, _namepiramid, _levels, _countatlevel, _feeaddr, _feeaddr2, _firstaddr);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.initValue: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            /////
        }
    }
    
    function pirSetSumLevel(string memory _namepir, int _level, uint sum) internal {
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].setSumLevel.selector, _level, sum);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.setSumLevel: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            //////
        }
        
    }
    
    function pirGetFullSumPay(string memory _namepir) public returns(uint retSum){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getFullSumPay.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getFullSumPay: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (uint));
        }
    }
    
    
    function pirCheckPresentAddr(string memory _namepir, address account) public returns (bool result){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].checkPresentAddr.selector, account);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.checkPresentAddr: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (bool));
        }
    }
    
    function pirGetName(string memory _namepir) public returns (string memory name){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getName.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getName: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (string));
        }
    }
    
    
    function pirGetLevels(string memory _namepir) public returns (int _Levels){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getLevels.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getLevels: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (int));
        }
    }
    
    
    function pirGetSlotsOnLevel(string memory _namepir) public returns(int _SlotsOnLevel){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getSlotsOnLevel.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getSlotsOnLevel: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (int));
        }
    }
    
    
    function pirGetSumOneLevel(string memory _namepir, int _level) public returns(uint _SlotsOnLevel){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getSumOneLevel.selector, _level);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getSumOneLevel: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (uint));
        }
    }
    
    
    function pirGetInfoByAddr(string memory _namepir, address _addr) public returns(address _parentaddr, address _realpositionaddr, address _thisaddr, int _countchildren, uint _countallref){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getInfoByAddr.selector, _addr);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getInfoByAddr: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (address, address, address, int, uint));
        }
    }
    
    
    
    function pirGetInfoByAddrAnLevel(string memory _namepir, address _addr, int _level) public returns(address _thisaddr, uint _allslots, uint _freeslots, uint _paidslots, uint _paidamount){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getInfoByAddrAnLevel.selector, _addr, _level);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getInfoByAddrAnLevel: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (address, uint, uint, uint, uint));
        }
    }

    
    function pirGetPartner(string memory _namepir, int _idPartner) public returns(address _addrPartner, uint _percentPartner, int _idPartnerRet, uint _Paid){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getPartner.selector, _idPartner);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getPartner: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (address, uint, int, uint));
        }
    }
    
    function pirGetFeeSums(string memory _namepir) public returns(uint _Payments1, uint _Payments2){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getFeeSums.selector);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getFeeSums: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (uint, uint));
        }
    }
    
    
    function pirGetBlockPayment(string memory _namepir, address _addr) public returns(bool _Result){
        
        bytes memory data = abi.encodeWithSelector(Piramids[_namepir].getBlockPayment.selector, _addr);
        (bool success, bytes memory returndata) = address(Piramids[_namepir]).call(data);
        require(success, "PiramidV3.getBlockPayment: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            return abi.decode(returndata, (bool));
        }
    }
}