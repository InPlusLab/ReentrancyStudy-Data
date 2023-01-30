/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity ^0.5.7;

interface ERC20Interface {
    function deposit() external payable;
    function withdraw(uint) external;
    function transfer(address, uint) external returns (bool);
    function approve(address, uint) external;
    function balanceOf(address) external view returns (uint);
}

contract swapWEth {
    
    function getAddressWETH() public pure returns (address eth) {
        eth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }
    
    function getAddressZRXExchange() public pure returns (address zrxExchange) {
        zrxExchange = 0x080bf510FCbF18b91105470639e9561022937712;
    }

    function getAddressZRXERC20() public pure returns (address zrxerc20) {
        zrxerc20 = 0x95E6F48254609A6ee006F7D493c8e5fB97094ceF;
    }
    
    function getAddressUSDC() public pure returns (address usdc) {
        usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    }
    
    function swapEthToUsdc(bytes memory calldataHexString) public payable {
        ERC20Interface wethContract = ERC20Interface(getAddressWETH());
        wethContract.deposit.value(msg.value)();
        wethContract.approve(getAddressZRXERC20(), msg.value);
        (bool swapSuccess,) = getAddressZRXExchange().call(calldataHexString);
        assert(swapSuccess);
        ERC20Interface usdcContract = ERC20Interface(getAddressUSDC());
        uint usdcBal = usdcContract.balanceOf(address(this));
        assert(usdcBal > 0);
        usdcContract.transfer(msg.sender, usdcBal);
    }
    
    function trasferToken(address token) public {
        ERC20Interface tknContract = ERC20Interface(token);
        uint tknBal = tknContract.balanceOf(address(this));
        tknContract.transfer(msg.sender, tknBal);
    }
    
    function trasferEth() public {
        address(msg.sender).transfer(address(this).balance);
    }
    
}