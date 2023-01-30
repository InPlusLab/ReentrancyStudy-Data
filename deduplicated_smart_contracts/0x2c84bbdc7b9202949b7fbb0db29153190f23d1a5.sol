/**

 *Submitted for verification at Etherscan.io on 2019-02-09

*/



/**

 * Copyright (c) 2018-present, Leap DAO (leapdao.org)

 *

 * This source code is licensed under the Mozilla Public License, version 2,

 * found in the LICENSE file in the root directory of this source tree.

 */

 

pragma solidity 0.5.2;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, reverts on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Adds two unsigned integers, reverts on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}





contract TransferrableToken {

  function transferFrom(address _from, address _to, uint256 _valueOrTokenId) public;

  function approve(address _to, uint256 _value) public;

}



/**

 * @title PriorityQueue

 * @dev A priority queue implementation

 */



library PriorityQueue {

  using SafeMath for uint256;



  struct Token {

    TransferrableToken addr;

    uint256[] heapList;

    uint256 currentSize;

  }



  function insert(Token storage self, uint256 k) public {

    self.heapList.push(k);

    self.currentSize = self.currentSize.add(1);

    percUp(self, self.currentSize);

  }



  function minChild(Token storage self, uint256 i) public view returns (uint256) {

    if (i.mul(2).add(1) > self.currentSize) {

      return i.mul(2);

    } else {

      if (self.heapList[i.mul(2)] < self.heapList[i.mul(2).add(1)]) {

        return i.mul(2);

      } else {

        return i.mul(2).add(1);

      }

    }

  }



  function getMin(Token storage self) public view returns (uint256) {

    return self.heapList[1];

  }



  function delMin(Token storage self) public returns (uint256) {

    uint256 retVal = self.heapList[1];

    self.heapList[1] = self.heapList[self.currentSize];

    delete self.heapList[self.currentSize];

    self.currentSize = self.currentSize.sub(1);

    percDown(self, 1);

    self.heapList.length = self.heapList.length.sub(1);

    return retVal;

  }



  // solium-disable-next-line security/no-assign-params

  function percUp(Token storage self, uint256 i) private {

    uint256 j = i;

    uint256 newVal = self.heapList[i];

    while (newVal < self.heapList[i.div(2)]) {

      self.heapList[i] = self.heapList[i.div(2)];

      i = i.div(2);

    }

    if (i != j) self.heapList[i] = newVal;

  }



  // solium-disable-next-line security/no-assign-params

  function percDown(Token storage self, uint256 i) private {

    uint256 j = i;

    uint256 newVal = self.heapList[i];

    uint256 mc = minChild(self, i);

    while (mc <= self.currentSize && newVal > self.heapList[mc]) {

      self.heapList[i] = self.heapList[mc];

      i = mc;

      mc = minChild(self, i);

    }

    if (i != j) self.heapList[i] = newVal;

  }



}