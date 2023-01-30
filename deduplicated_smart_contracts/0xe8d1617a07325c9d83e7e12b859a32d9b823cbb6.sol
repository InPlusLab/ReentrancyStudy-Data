pragma solidity 0.4.24;

import "ClarityToken.sol";

contract UserPaymentAccount {

    ClarityToken clarityToken;
    address controller;
    address paymentTarget;
    bool isLockedTransactions;
    bool isLockedReplenish;

    mapping(string => uint256) balances;
    mapping(address => bool) public isOwner;
    mapping(address => bool) public isOperator;

    constructor(address _controller, address _clarityToken, address _paymentTarget, address _owner) public {
        clarityToken = ClarityToken(_clarityToken);
        controller = _controller;
        isOwner[_owner] = true;
        paymentTarget = _paymentTarget;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }

    function balanceOf(string _userId) public view returns (uint256 _balance) {
        _balance = balances[_userId];
    }

    function replenish(string _toUserId, uint256 _amount) public returns (bool) {
        require(!isLockedReplenish);
        require(clarityToken.transferFrom(msg.sender, address(this), _amount));
        balances[_toUserId] += _amount;
        return true;
    }

    function move(string _fromUserId, string _toUserId, uint256 _amount) public returns (bool) {
        require((msg.sender == controller && !isLockedTransactions) || isOwner[msg.sender]);
        return _move(_fromUserId, _toUserId, _amount);
    }

    function _move(string _fromUserId, string _toUserId, uint256 _amount) internal returns (bool) {
        require(balances[_fromUserId] >= _amount);
        balances[_fromUserId] -= _amount;
        balances[_toUserId] += _amount;
        return true;
    }

    function pay(string _fromUserId, uint256 _amount) public returns (bool) {
        require((msg.sender == controller && !isLockedTransactions) || isOwner[msg.sender]);
        require(balances[_fromUserId] >= _amount);
        require(clarityToken.transfer(paymentTarget, _amount));
        balances[_fromUserId] -= _amount;
        return true;
    }

    function takeAllTokens() public returns (bool) {
        require(isOwner[msg.sender]);
        require(clarityToken.transfer(paymentTarget, clarityToken.balanceOf(address(this))));
        isLockedReplenish = true;
        isLockedTransactions = true;
        return true;
    }

    function addOwner(address _owner) public notNull(_owner) returns (bool) {
        require(isOwner[msg.sender]);
        isOwner[_owner] = true;
        return true;
    }

    function removeOwner(address _owner) public notNull(_owner) returns (bool) {
        require(msg.sender != _owner && isOwner[msg.sender]);
        isOwner[_owner] = false;
        return true;
    }

    function lockTransactions() public returns (bool) {
        require(isOwner[msg.sender] || isOperator[msg.sender]);
        isLockedTransactions = true;
        return true;
    }

    function unlockTransactions() public returns (bool) {
        require(isOwner[msg.sender] || isOperator[msg.sender]);
        isLockedTransactions = false;
        return true;
    }

    function lockReplenish() public returns (bool) {
        require(isOwner[msg.sender]);
        isLockedReplenish = true;
        return true;
    }

    function unlockReplenish() public returns (bool) {
        require(isOwner[msg.sender]);
        isLockedReplenish = false;
        return true;
    }

    function addOperator(address _operator) public notNull(_operator) returns (bool) {
        require(isOwner[msg.sender]);
        isOperator[_operator] = true;
        return true;
    }

    function removeOperator(address _operator) public notNull(_operator) returns (bool) {
        require(isOwner[msg.sender]);
        isOperator[_operator] = false;
        return true;
    }

    function setController(address _controller) public notNull(_controller) returns (bool) {
        require(isOwner[msg.sender]);
        controller = _controller;
        return true;
    }

    function setPaymentTarget(address _paymentTarget) public notNull(_paymentTarget) returns (bool) {
        require(isOwner[msg.sender]);
        paymentTarget = _paymentTarget;
        return true;
    }

}
