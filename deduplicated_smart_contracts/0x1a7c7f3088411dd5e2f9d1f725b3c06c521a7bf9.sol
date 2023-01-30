/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

pragma solidity ^0.5.0;


contract DSProxyInterface {
    function execute(bytes memory _code, bytes memory _data) public payable returns (address, bytes32);

    function execute(address _target, bytes memory _data) public payable returns (bytes32);

    function setCache(address _cacheAddr) public payable returns (bool);

    function owner() public returns (address);
}

contract MCDMonitorProxy {

    uint public CHANGE_PERIOD;
    address public monitor;
    address public owner;
    address public newMonitor;
    uint public changeRequestedTimestamp;

    mapping(address => bool) public allowed;

    
    modifier onlyAllowed() {
        require(allowed[msg.sender] || msg.sender == owner);
        _;
    }

    modifier onlyMonitor() {
        require (msg.sender == monitor);
        _;
    }

    constructor(uint _changePeriod) public {
        owner = msg.sender;
        CHANGE_PERIOD = _changePeriod * 1 days;
    }

    
    
    function setMonitor(address _monitor) public onlyAllowed {
        require(monitor == address(0));
        monitor = _monitor;
    }

    
    
    
    
    function callExecute(address _owner, address _saverProxy, bytes memory _data) public onlyMonitor {
        
        DSProxyInterface(_owner).execute(_saverProxy, _data);
    }

    
    
    
    function changeMonitor(address _newMonitor) public onlyAllowed {
        changeRequestedTimestamp = now;
        newMonitor = _newMonitor;
    }

    
    function cancelMonitorChange() public onlyAllowed {
        changeRequestedTimestamp = 0;
        newMonitor = address(0);
    }

    
    function confirmNewMonitor() public onlyAllowed {
        require((changeRequestedTimestamp + CHANGE_PERIOD) < now);
        require(changeRequestedTimestamp != 0);
        require(newMonitor != address(0));

        monitor = newMonitor;
        newMonitor = address(0);
        changeRequestedTimestamp = 0;
    }

    
    
    function addAllowed(address _user) public onlyAllowed {
        allowed[_user] = true;
    }

    
    
    
    function removeAllowed(address _user) public onlyAllowed {
        allowed[_user] = false;
    }
}