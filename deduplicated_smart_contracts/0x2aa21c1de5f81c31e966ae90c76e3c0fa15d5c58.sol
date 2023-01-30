/**
 *Submitted for verification at Etherscan.io on 2020-04-24
*/

pragma solidity ^0.5.13;

contract EXCH {
    function appreciateTokenPrice(uint256 _amount) public;
}

contract TOKEN {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Hex2_Distribution {
    event onDistribute(
        address indexed customerAddress,
        uint256 price
    );

    TOKEN erc20;
    EXCH hexmax;

    constructor() public {
        hexmax = EXCH(address(0xd52dca990CFC3760e0Cb0A60D96BE0da43fEbf19));
        erc20 = TOKEN(address(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39));
    }

    function() payable external {
        revert();
    }

    function feedHexMax() public {
      uint256 _balance = erc20.balanceOf(address(this));

      if (_balance > 1000e8) {
        erc20.approve(address(0xd52dca990CFC3760e0Cb0A60D96BE0da43fEbf19), _balance);
        hexmax.appreciateTokenPrice(_balance);

        emit onDistribute(msg.sender, _balance);
      }
    }
}