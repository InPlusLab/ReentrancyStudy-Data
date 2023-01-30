pragma solidity ^0.5.11;

import "./Container.sol";

contract HBTCStorage is Container{

    string public constant name = "HBTCStorage";

    address private caller;

    constructor(address aCaller) public{
        totalSupply = 0;
        caller = aCaller;
    }
    uint256 public totalSupply;

    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowed;

    function supporterExists(bytes32 taskHash, address user) public view returns(bool){
        return itemAddressExists(taskHash, user);
    }

    function setTaskInfo(bytes32 taskHash, uint256 taskType, uint256 status) external onlyCaller{
        setItemInfo(taskHash, taskType, status);
    }

    function getTaskInfo(bytes32 taskHash) public view returns(uint256, uint256, uint256){
        return getItemInfo(taskHash);
    }

    function addSupporter(bytes32 taskHash, address oneAddress) external onlyCaller{
        addItemAddress(taskHash, oneAddress);
    }

    function removeAllSupporter(bytes32 taskHash) external onlyCaller{
        removeItemAddresses(taskHash);
    }

    modifier onlyCaller() {
        require(msg.sender == caller, "only use main main contract to call");
        _;
    }

    function getTotalSupply() external view returns(uint256) {
        return totalSupply;
    }

    function setTotalSupply(uint256 amount) external onlyCaller {
        totalSupply = amount;
    }

    function balanceOf(address account) external view returns(uint256) {
        return balances[account];
    }

    function setBalance(address account,uint256 amount) external onlyCaller {
        require(account != address(0),"account address error");
        balances[account] = amount;
    }

    function getAllowed(address owner,address spender) external view returns(uint256) {
        return allowed[owner][spender];
    }

    function setAllowed(address owner,address spender,uint256 amount) external onlyCaller {
        require(owner != address(0),"owner address error");
        require(spender != address(0),"spender address error");
        allowed[owner][spender] = amount;
    }
}