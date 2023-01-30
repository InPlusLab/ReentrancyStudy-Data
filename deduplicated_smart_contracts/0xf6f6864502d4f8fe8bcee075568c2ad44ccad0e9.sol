/**
 *Submitted for verification at Etherscan.io on 2020-02-22
*/

pragma solidity >= 0.5.0 < 0.7.0;

contract Counter {
  int private count = 0;

  event Count(
    int count
  );

  function incrementCount() public {
    count += 1;
    emit Count(count);
  }

  function decrementCount() public {
    count -= 1;
    emit Count(count);
  }

  function resetCount() public {
    count = 0;
    emit Count(count);
  }

  function getCount() public view returns (int) {
    return count;
  }
}