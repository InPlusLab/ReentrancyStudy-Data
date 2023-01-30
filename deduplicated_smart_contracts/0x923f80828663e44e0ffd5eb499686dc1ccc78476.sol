/**
 *Submitted for verification at Etherscan.io on 2019-09-19
*/

pragma solidity ^0.5.8;

contract NEST_MiningSave {
    
    IBMapping mappingContract;                      
    ERC20 nestContract;                             
    
    constructor (address map) public {
        mappingContract = IBMapping(address(map));              
        nestContract = ERC20(address(mappingContract.checkAddress("nest")));            
    }
    
    function changeMapping(address map) public onlyOwner {
        mappingContract = IBMapping(address(map));              
        nestContract = ERC20(address(mappingContract.checkAddress("nest")));            
    }
    
    function turnOut(uint256 amount, address to) public onlyMiningCalculation returns(uint256) {
        uint256 leftNum = nestContract.balanceOf(address(this));
        if (leftNum >= amount) {
            nestContract.transfer(to, amount);
            return amount;
        } else {
            return 0;
        }
    }
    
    modifier onlyOwner(){
        require(mappingContract.checkOwners(msg.sender) == true);
        _;
    }

    modifier onlyMiningCalculation(){
        require(address(mappingContract.checkAddress("miningCalculation")) == msg.sender);
        _;
    }
    
}


contract ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);

    function transfer( address to, uint256 value) external;
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}


contract IBMapping {
	function checkAddress(string memory name) public view returns (address contractAddress);
	function checkOwners(address man) public view returns (bool);
}