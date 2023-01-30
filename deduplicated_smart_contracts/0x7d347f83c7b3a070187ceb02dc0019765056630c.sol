pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Pow.sol";
import "./Ownable.sol";

/**
* @dev EBitcoin Token (EBT)
*/
contract EBitcoin is IERC20, ERC20, ERC20Detailed, ERC20Pow, Ownable {

    using SafeMath for uint256;

    struct BankAccount {
        uint256 balance;
        uint256 interestSettled;
        uint256 lastBlockNumber;
    }

    mapping (address => BankAccount) private _bankAccounts;

    //Suppose one block in 10 minutes, one day is 144
    uint256 private _interestInterval = 144;

    /**
    * @dev Init
    */
    constructor ()
        ERC20Detailed("EBitcoin Token", "EBT", 8)
        ERC20Pow(2**16, 2**232, 210000, 5000000000, 504, 60, 144)
    public {}

    /**
    * @dev Returns the amount of bank balance owned by `account`
    */
    function bankBalanceOf(address account) public view returns (uint256) {
        return _bankAccounts[account].balance;
    }

    /**
    * @dev Returns the amount of bank interes owned by `account`
    */
    function bankInterestOf(address account) public view returns (uint256) {

        // No interest without deposit
        BankAccount storage item = _bankAccounts[account];
        if(0 == item.balance)  return 0;

        // balance * day / 365 * 0.01
        uint256 blockNumber = getBlockCount();
        uint256 intervalCount = blockNumber.sub(item.lastBlockNumber).div(_interestInterval);
        uint256 interest = item.balance.mul(intervalCount).div(365).div(100);
        return interest.add(item.interestSettled);
    }

    /**
    * @dev Deposit `amount` tokens in the bank
    *
    * Returns a boolean value indicating whether the operation succeeded
    *
    * Emits a {Transfer} event.
    */
    function bankDeposit(uint256 amount) public returns (bool) {

        // Deducting balance
        uint256 balance = _getBalance(msg.sender);
        _setBalance(msg.sender, balance.sub(amount, "Token: bank deposit amount exceeds balance"));

        // If have a bank balance, need to calculate interest first
        BankAccount storage item = _bankAccounts[msg.sender];
        if (0 != item.balance) {

            // balance * day / 365 * 0.01
            uint256 blockNumber = getBlockCount();
            uint256 intervalCount = blockNumber.sub(item.lastBlockNumber).div(_interestInterval);
            uint256 interest = item.balance.mul(intervalCount).div(365).div(100);

            // Append
            item.balance = item.balance.add(amount);
            item.interestSettled = item.interestSettled.add(interest);
            item.lastBlockNumber = blockNumber;
        }
        else {

            // Init
            item.balance = amount;
            item.interestSettled = 0;
            item.lastBlockNumber = getBlockCount();
        }

        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    /**
    * @dev Withdrawal `amount` tokens in the bank
    *
    * Returns a boolean value indicating whether the operation succeeded
    *
    * Emits a {Transfer} event.
    */
    function bankWithdrawal(uint256 amount) public returns (bool) {

        // Bank balance greater than or equal amount
        BankAccount storage item = _bankAccounts[msg.sender];
        require(0 == amount || 0 != item.balance, "Token: withdrawal amount exceeds bank balance");

        // balance * day / 365 * 0.01
        uint256 blockNumber = getBlockCount();
        uint256 intervalCount = blockNumber.sub(item.lastBlockNumber).div(_interestInterval);
        uint256 interest = item.balance.mul(intervalCount).div(365).div(100);
        interest = interest.add(item.interestSettled);

        // Interest is enough to pay
        if (interest >= amount) {

            // Deducting interest
            item.lastBlockNumber = blockNumber;
            item.interestSettled = interest.sub(amount);

            // Transfer balance and increase total supply
            _setBalance(msg.sender, _getBalance(msg.sender).add(amount));
            _setTotalSupply(_getTotalSupply().add(amount));
        }
        else {

            // Deducting interest and bank balance
            uint256 remainAmount = amount.sub(interest);
            item.balance = item.balance.sub(remainAmount, "Token: withdrawal amount exceeds bank balance");
            item.lastBlockNumber = blockNumber;
            item.interestSettled = 0;

            // Transfer balance and increase total supply
            _setBalance(msg.sender, _getBalance(msg.sender).add(amount));
            _setTotalSupply(_getTotalSupply().add(interest));
        }

        emit Transfer(address(0), msg.sender, amount);
        return true;
    }

    /**
    * @dev Owner can transfer out any accidentally sent ERC20 tokens
    */
    function transferAnyERC20Token(address tokenAddress, uint256 amount) public onlyOwner returns (bool) {
        return IERC20(tokenAddress).transfer(getOwner(), amount);
    }
}