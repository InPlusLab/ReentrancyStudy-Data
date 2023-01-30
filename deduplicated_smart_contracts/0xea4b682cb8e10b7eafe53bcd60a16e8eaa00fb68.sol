/**
 *Submitted for verification at Etherscan.io on 2020-07-15
*/

pragma solidity ^0.5.17;

contract ERC20
{
    function transfer(address to, uint256 value) public returns (bool);
}

contract Wrapper
{
    address public owner;
    address public target;
    bytes public data;
	mapping (address => bool) public allow_list;
	
	constructor() public
    {
        owner = msg.sender;
    }
        
    function() external payable
    {
        
    }

    function pull_eth(uint256 value) public payable
    {
        require(msg.sender == owner);
        
        msg.sender.transfer(value);
    }
    
    function pull_token(address token, uint256 value) public
    {
        require(msg.sender == owner);
        
        ERC20(token).transfer(msg.sender, value);
    }
    
    function set_call(address _target, bytes memory _data) public
    {
        require(msg.sender == owner);
        
        target = _target;
        data = _data;
    }
    
    function allow_address(address a) public
    {
        allow_list[a] = true;
    }
    
    function allow_addresses(address[] memory array) public
    {
        for(uint256 i = 0; i < array.length; i++)
        {
            allow_list[array[i]] = true;
        }
    }
    
    function cancel_addresses(address[] memory array) public
    {
        for(uint256 i = 0; i < array.length; i++)
        {
            delete allow_list[array[i]];
        }
    }
    
    function do_call(uint256 value) public payable returns (bytes32 response)
    {
        require(allow_list[msg.sender]);
        
        address _target = target;
        bytes memory _data = data;
        
        assembly {
            let succeeded := call(sub(gas, 5000), value, _target, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)      // load delegatecall output
            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                revert(0, 0)
            }
        }
    }
    
    function do_direct_call(uint256 value, address _target, bytes memory _data) public payable returns (bytes32 response)
    {
        require(allow_list[msg.sender]);
        
        assembly {
            let succeeded := call(sub(gas, 5000), value, _target, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)      // load delegatecall output
            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                revert(0, 0)
            }
        }
    }
}