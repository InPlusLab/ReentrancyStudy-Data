/**
 *Submitted for verification at Etherscan.io on 2019-11-16
*/

pragma solidity ^0.5.12;

library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   
    constructor () internal {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function rescuebtcgwTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 __btcgw = IERC20(tokenAddr);
        require(receiver != address(0));
        uint256 __balance = __btcgw.balanceOf(address(this));
        
        require(__balance >= amount);
        assert(__btcgw.transfer(receiver, amount));
    }
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

 //--BTCGW BatchTransfer--Carstyle--
contract BatchTransfer is Ownable{
    using SafeMath for uint256;
    
    IERC20 BTCGW = IERC20(0x305F8157C1f841fBD378f636aBF390c5b4C0e330); //contract address of BTCGW

    
    function batchTransferBoth(address payable[] memory accounts, uint256 etherValue, uint256 btcgwValue) public payable {
        uint256 __etherBalance = address(this).balance;
        uint256 __btcgwAllowance = BTCGW.allowance(msg.sender, address(this));

        require(__etherBalance >= etherValue.mul(accounts.length));
        require(__btcgwAllowance >= btcgwValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i].transfer(etherValue);
            assert(BTCGW.transferFrom(msg.sender, accounts[i], btcgwValue));
        }
    }

    function batchTransferEther(address payable[] memory accounts, uint256 etherValue) public payable {
        uint256 __etherBalance = address(this).balance;

        require(__etherBalance >= etherValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i].transfer(etherValue);
        }
    }

   
    function batchTransferBTCGW(address[] memory accounts, uint256 btcgwValue) public {
        uint256 __btcgwAllowance = BTCGW.allowance(msg.sender, address(this));

        require(__btcgwAllowance >= btcgwValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            assert(BTCGW.transferFrom(msg.sender, accounts[i], btcgwValue));
        }
    }
}