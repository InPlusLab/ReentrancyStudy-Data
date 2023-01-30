/**

 *Submitted for verification at Etherscan.io on 2018-11-01

*/



pragma solidity ^0.4.21;



contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}



library SafeERC20 {

    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

        assert(token.transfer(to, value));

    }

}



contract TokenTimelock {

    using SafeERC20 for ERC20Basic;



    string public constant name = "BIXITeamLock";



    // ERC20 basic token contract being held

    ERC20Basic public token = ERC20Basic(0x10289bDa0eC95c612276417C4Cb01123A047855a);



    // beneficiary of tokens after they are released

    address public beneficiary = 0x4E35FB8178A1DA49DE7EA19d8F60F55111d85315;



    // timestamp when token release is enabled

    uint256 public releaseTime = 1604160000;



    function TokenTimelock() public {}



    function release() public {

        require(block.timestamp >= releaseTime);



        uint256 amount = token.balanceOf(this);

        require(amount > 0);



        token.safeTransfer(beneficiary, amount);

    }

}