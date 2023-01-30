/**
 *Submitted for verification at Etherscan.io on 2020-11-22
*/

pragma solidity ^0.5.16;

// this contract serves as feeToSetter, allowing owner to manage fees in the context of a specific feeTo implementation
contract EliteFeeToSetter {
    // immutables
    address public factory;
    uint public vestingEnd;
    address public feeTo;

    address public owner;

    constructor(address factory_, uint vestingEnd_, address owner_, address feeTo_) public {
        require(vestingEnd_ > block.timestamp, 'EliteFeeToSetter::constructor: vesting must end after deployment');
        factory = factory_;
        vestingEnd = vestingEnd_;
        owner = owner_;
        feeTo = feeTo_;
    }

    // allows owner to change itself at any time
    function setOwner(address owner_) public {
        require(msg.sender == owner, 'EliteFeeToSetter::setOwner: not allowed');
        owner = owner_;
    }

    // allows owner to change feeToSetter after vesting
    function setFeeToSetter(address feeToSetter_) public {
        require(block.timestamp >= vestingEnd, 'EliteFeeToSetter::setFeeToSetter: not time yet');
        require(msg.sender == owner, 'EliteFeeToSetter::setFeeToSetter: not allowed');
        IEliteswapV2Factory(factory).setFeeToSetter(feeToSetter_);
    }

    // allows owner to turn fees on/off after vesting
    function toggleFees(bool on) public {
        require(block.timestamp >= vestingEnd, 'EliteFeeToSetter::toggleFees: not time yet');
        require(msg.sender == owner, 'EliteFeeToSetter::toggleFees: not allowed');
        IEliteswapV2Factory(factory).setFeeTo(on ? feeTo : address(0));
    }
}

interface IEliteswapV2Factory {
    function setFeeToSetter(address) external;
    function setFeeTo(address) external;
}