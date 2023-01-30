/**
 *Submitted for verification at Etherscan.io on 2020-12-01
*/

pragma solidity >=0.4.21 <0.6.0;

contract SafeMath {

    function safeMul(uint a, uint b) internal pure returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns(uint) {
        uint c = a + b;
        assert(c >=a && c >= b);
        return c;
    }
}

contract DatrixoEquityToken is SafeMath {

    string constant public standard = "ERC20";
    string constant public name = "DatrixoEquityToken";
    string constant public symbol = "DRX";
    uint8 constant public decimals = 5;
    uint public totalSupply = 800000000;
    address public owner;
    uint public startTime;
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public firstPurchaseTime;
    address[] public shareholders;

    event Transfer(address indexed from, address indexed to, uint value);
    event ShareholderRemoved(address indexed addr, uint value);

    constructor(address _ownerAddr, uint _startTime) public {
        owner = _ownerAddr;
        startTime = _startTime;
        balanceOf[owner] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not contract owner.");
        _;
    }

    modifier afterStartTime() {
        require(now > startTime, "STO is not started.");
        _;
    }

    function transfer(address _to, uint _value) public onlyOwner afterStartTime returns(bool success){
        require(msg.sender != _to, "Target address can't be equal source.");
        require(_to != address(0), "Target address is 0x0");
        require(balanceOf[_to] == 0, "Target balance not equal 0");
        if (!checkShareholderExist(_to)) {
            shareholders.push(_to);
        }
        return _firstTransfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public onlyOwner afterStartTime returns(bool success){
        return _secondTransfer(_from, _to, _value);
    }

    function removeShareholder(address _addr) public onlyOwner returns(bool success) {
        require(_addr != address(0), "Target address is 0x0");
        require(checkShareholderExist(_addr), "Shareholder is not exist.");
        for (uint i = 0; i < shareholders.length; i++) {
            if (shareholders[i] == _addr) {
                delete shareholders[i];
            }
        }
        if (firstPurchaseTime[_addr] > 0) {
            delete firstPurchaseTime[_addr];
        }
        bool result = true;
        uint value = 0;
        if (balanceOf[_addr] > 0) {
            value = balanceOf[_addr];
            result = _transferFrom(_addr, owner, value);
        }
        require(result);
        emit ShareholderRemoved(_addr, value);
        return result;
    }

    function _firstTransfer(address _to, uint _value) internal onlyOwner afterStartTime returns(bool success) {
        require(_to != address(0), "Target address is 0x0");
        require(balanceOf[_to] == 0, "Target balance not equal 0");
        require(safeSub(balanceOf[msg.sender], _value) >= 0, "Value more then available amount");
        if (!checkShareholderExist(_to)) {
            shareholders.push(_to);
        }
        firstPurchaseTime[_to] = now;
        return _transfer(_to, _value);
    }

    function _secondTransfer(address _from, address _to, uint _value) onlyOwner afterStartTime internal returns(bool success){
        require(safeSub(balanceOf[_from], _value) >= 0, "Value more then balance amount");
        if (_to != address(0)) {
            require(firstPurchaseTime[_to] == 0, "Target balance has first transfer amount.");
        }
        if (firstPurchaseTime[_from] > 0) {
            delete firstPurchaseTime[_from];
        }
        if (!checkShareholderExist(_to)) {
            shareholders.push(_to);
        }
        firstPurchaseTime[_to] = now;
        return _transferFrom(_from, _to, _value);
    }

    function checkShareholderExist(address _addr) internal view returns(bool) {
        for (uint i = 0; i < shareholders.length; i++) {
            if (shareholders[i] == _addr) return true;
        }
        return false;
    }

    function _transfer(address _to, uint _value) internal returns(bool success){
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function _transferFrom(address _from, address _to, uint _value) internal returns(bool success){
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function getShareholdersArray() public view returns(address[] memory) {
        return shareholders;
    }

    function setStart(uint _newStart) public onlyOwner {
        require(_newStart < startTime, "New start time must be earlier current start time.");
        startTime = _newStart;
    }
}