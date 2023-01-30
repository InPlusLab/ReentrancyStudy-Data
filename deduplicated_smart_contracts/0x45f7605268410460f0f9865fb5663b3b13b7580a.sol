/*

    Gold Reserve Token

    

    xgr_token.sol

    3.0.0

    

    Fusion Solutions KFT <[email protected]>

    

    Written by Andor Rajci, November 2018

*/

pragma solidity 0.4.18;



import "./xgr_token_db.sol";

import "./xgr_token_lib.sol";

import "./xgr_deposits.sol";

import "./xgr_fork.sol";

import "./xgr_safeMath.sol";

import "./xgr_owned.sol";

import "./xgr_sample.sol";



contract Token is SafeMath, Owned {

    /**

    * @title Gold Reserve [XGR] token

    */

    /* Variables */

    string  public name = "GoldReserve";

    string  public symbol = "XGR";

    uint8   public decimals = 8;

    uint256 public transactionFeeRate   = 20; // 0.02 %

    uint256 public transactionFeeRateM  = 1e3; // 1000

    uint256 public transactionFeeMin    =   2000000; // 0.2 XGR

    uint256 public transactionFeeMax    = 200000000; // 2.0 XGR

    address public databaseAddress;

    address public depositsAddress;

    address public forkAddress;

    address public libAddress;

    /* Constructor */

    function Token(address newDatabaseAddress, address newDepositAddress, address newFrokAddress, address newLibAddress) public {

        databaseAddress = newDatabaseAddress;

        depositsAddress = newDepositAddress;

        forkAddress = newFrokAddress;

        libAddress = newLibAddress;

    }

    /* Fallback */

    function () {

        revert();

    }

    /* Externals */

    function changeDataBaseAddress(address newDatabaseAddress) external onlyForOwner {

        databaseAddress = newDatabaseAddress;

    }

    function changeDepositsAddress(address newDepositsAddress) external onlyForOwner {

        depositsAddress = newDepositsAddress;

    }

    function changeForkAddress(address newForkAddress) external onlyForOwner {

        forkAddress = newForkAddress;

    }

    function changeLibAddress(address newLibAddress) external onlyForOwner {

        libAddress = newLibAddress;

    }

    function changeFees(uint256 rate, uint256 rateMultiplier, uint256 min, uint256 max) external onlyForOwner {

        transactionFeeRate = rate;

        transactionFeeRateM = rateMultiplier;

        transactionFeeMin = min;

        transactionFeeMax = max;

    }

    /**

     * @notice `msg.sender` approves `spender` to spend `amount` tokens on its behalf.

     * @param spender The address of the account able to transfer the tokens

     * @param amount The amount of tokens to be approved for transfer

     * @return True if the approval was successful

     */

    function approve(address spender, uint256 amount) external returns (bool _success) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x20)

            }

        }

    }

    /**

     * @notice Send `amount` tokens to `to` from `msg.sender`

     * @param to The address of the recipient

     * @param amount The amount of tokens to be transferred

     * @return Whether the transfer was successful or not

     */

    function transfer(address to, uint256 amount) external returns (bool success) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x20)

            }

        }

    }

    /**

     * @notice Send `amount` tokens to `to` from `from` on the condition it is approved by `from`

     * @param from The address holding the tokens being transferred

     * @param to The address of the recipient

     * @param amount The amount of tokens to be transferred

     * @return True if the transfer was successful

     */

    function transferFrom(address from, address to, uint256 amount) external returns (bool success) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x20)

            }

        }

    }

    /**

     * @notice Send `amount` tokens to `to` from `msg.sender` and notify the receiver from your transaction with your `extraData` data

     * @param to The contract address of the recipient

     * @param amount The amount of tokens to be transferred

     * @param extraData Data to give forward to the receiver

     * @return Whether the transfer was successful or not

     */

    function transfer(address to, uint256 amount, bytes extraData) external returns (bool success) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x20)

            }

        }

    }

    function mint(address owner, uint256 value) external returns (bool success) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x20)

            }

        }

    }

    /* Internals */

    /* Constants */

    function allowance(address owner, address spender) public constant returns (uint256 remaining, uint256 nonce) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x40)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x40)

            }

        }

    }

    function getTransactionFee(uint256 value) public constant returns (bool success, uint256 fee) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x40)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x40)

            }

        }

    }

    function balanceOf(address owner) public constant returns (uint256 value) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x20)

            }

        }

    }

    function balancesOf(address owner) public constant returns (uint256 balance, uint256 lockedAmount) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x40)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x40)

            }

        }

    }

    function totalSupply() public constant returns (uint256 value) {

        address _trg = libAddress;

        assembly {

            let m := mload(0x40)

            calldatacopy(m, 0, calldatasize)

            let success := delegatecall(gas, _trg, m, calldatasize, m, 0x20)

            switch success case 0 {

                revert(0, 0)

            } default {

                return(m, 0x20)

            }

        }

    }

    /* Events */

    event AllowanceUsed(address indexed spender, address indexed owner, uint256 indexed value);

    event Mint(address indexed addr, uint256 indexed value);

    event Burn(address indexed addr, uint256 indexed value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Transfer2(address indexed from, address indexed to, uint256 indexed value, bytes data);

}

