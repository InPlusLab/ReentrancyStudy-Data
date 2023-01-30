pragma solidity 0.4.24;


contract ExecutionTarget {
    uint256 public counter;

    function execute() public {
        counter += 1;
        emit Executed(counter);
    }

    function setCounter(uint256 x) public {
        counter = x;
    }

    event Executed(uint256 x);
}