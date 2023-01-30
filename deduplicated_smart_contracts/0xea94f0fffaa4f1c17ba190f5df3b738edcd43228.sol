pragma solidity ^0.4.23;

// File: contracts/interface/IArbitrage.sol

/*

  Copyright 2018 Contra Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.24;
 

interface IArbitrage {
    function executeArbitrage(
      address token,
      uint256 amount,
      address dest,
      bytes data
    )
      external
      returns (bool);
}

// File: contracts/interface/IBank.sol

/*

  Copyright 2018 Contra Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.24;


contract IBank {
    function totalSupplyOf(address token) public view returns (uint256 balance);
    function borrowFor(address token, address borrower, uint256 amount) public;
    function repay(address token, uint256 amount) external payable;
}

// File: openzeppelin-solidity/contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/FlashLender.sol

/*

  Copyright 2018 Contra Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.24;







// @title FlashLender: Borrow from the bank and enforce repayment by the end of transaction execution.
// @author Rich McAteer <[email protected]>, Max Wolff <[email protected]>
contract FlashLender is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    string public version = '0.1';
    address public bank;
    uint256 public fee;
    
    /**
    * @dev Verify that the borrowed tokens are returned to the bank plus a fee by the end of transaction execution.
    * @param token Address of the token to for arbitrage. 0x0 for Ether.
    * @param amount Amount borrowed.
    */
    modifier isArbitrage(address token, uint256 amount) {
        uint256 balance = IBank(bank).totalSupplyOf(token);
        uint256 feeAmount = amount.mul(fee).div(10 ** 18); 
        _;
        require(IBank(bank).totalSupplyOf(token) >= (balance.add(feeAmount)));
    }

    constructor(address _bank, uint256 _fee) public {
        bank = _bank;
        fee = _fee;
    }

    /**
    * @dev Borrow from the bank on behalf of an arbitrage contract and execute the arbitrage contract's callback function.
    * @param token Address of the token to borrow. 0x0 for Ether.
    * @param amount Amount to borrow.
    * @param dest Address of the account to receive arbitrage profits.
    * @param data The data to execute the arbitrage trade.
    */
    function borrow(
        address token,
        uint256 amount,
        address dest,
        bytes data
    )
        external
        nonReentrant
        isArbitrage(token, amount)
        returns (bool)
    {
        // Borrow from the bank and send to the arbitrageur.
        IBank(bank).borrowFor(token, msg.sender, amount);
        // Call the arbitrageur's execute arbitrage method.
        return IArbitrage(msg.sender).executeArbitrage(token, amount, dest, data);
    }

    /**
    * @dev Allow the owner to set the bank address.
    * @param _bank Address of the bank.
    */
    function setBank(address _bank) external onlyOwner {
        bank = _bank;
    }

    /**
    * @dev Allow the owner to set the fee.
    * @param _fee Fee to borrow, as a percentage of principal borrowed. 18 decimals of precision (e.g., 10^18 = 100% fee).
    */
    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

}

// File: contracts/example/ExternalCall.sol

/*

  Copyright 2018 Contra Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.24;

contract ExternalCall {
    // Source: https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function external_call(address destination, uint value, uint dataLength, bytes data) internal returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                d,
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }
}

// File: contracts/example/Arbitrage.sol

/*

  Copyright 2018 Contra Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.24;








// @title Arbitrage: Borrow Ether or ERC20 tokens to execute an arbitrage opportunity.
// @author Rich McAteer <[email protected]>, Max Wolff <[email protected]>
contract Arbitrage is IArbitrage, ExternalCall {
    using SafeMath for uint256;

    address public lender;
    address public tradeExecutor;
    address constant public ETH = 0x0;
    uint256 constant public MAX_UINT = 2 ** 256 - 1;

    modifier onlyLender() {
        require(msg.sender == lender);
        _;
    }

    constructor(address _lender, address _tradeExecutor) public {
        lender = _lender;
        tradeExecutor = _tradeExecutor; 
    }

    // Receive ETH from bank.
    function () payable public {}

    /**
    * @dev Borrow from flash lender to execute arbitrage trade. 
    * @param token Address of the token to borrow. 0x0 for Ether.
    * @param amount Amount to borrow.
    * @param dest Address of the account to receive arbitrage profits.
    * @param data The data to execute the arbitrage trade.
    */
    function submitTrade(address token, uint256 amount, address dest, bytes data) external {
        FlashLender(lender).borrow(token, amount, dest, data);
    }

    /**
    * @dev Callback from flash lender. Executes arbitrage trade.
    * @param token Address of the borrowed token. 0x0 for Ether.
    * @param amount Amount borrowed.
    * @param dest Address of the account to receive arbitrage profits.
    * @param data The data to execute the arbitrage trade.
    */
    function executeArbitrage(
        address token,
        uint256 amount,
        address dest,
        bytes data
    )
        external
        onlyLender 
        returns (bool)
    {
        uint256 value = 0;
        if (token == ETH) {
            value = amount;
        } else {
            // Send tokens to Trade Executor
            ERC20(token).transfer(tradeExecutor, amount);
        }

        // Execute the trades.
        external_call(tradeExecutor, value, data.length, data);

        // Determine the amount to repay.
        uint256 repayAmount = getRepayAmount(amount);

        address bank = FlashLender(lender).bank();

        // Repay the bank and collect remaining profits.
        if (token == ETH) {
            IBank(bank).repay.value(repayAmount)(token, repayAmount);
            dest.transfer(address(this).balance);
        } else {
            if (ERC20(token).allowance(this, bank) < repayAmount) {
                ERC20(token).approve(bank, MAX_UINT);
            }
            IBank(bank).repay(token, repayAmount);
            uint256 balance = ERC20(token).balanceOf(this);
            require(ERC20(token).transfer(dest, balance));
        }

        return true;
    }

    /** 
    * @dev Calculate the amount owed after borrowing.
    * @param amount Amount used to calculate repayment amount.
    */ 
    function getRepayAmount(uint256 amount) public view returns (uint256) {
        uint256 fee = FlashLender(lender).fee();
        uint256 feeAmount = amount.mul(fee).div(10 ** 18);
        return amount.add(feeAmount);
    }

}