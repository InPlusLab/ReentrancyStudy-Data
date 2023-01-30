pragma solidity ^0.4.25;

import "./Contracts.sol";
import "./SafeMath.sol";
import "./Croupier.sol";
import "./Ownalbe.sol";


contract Wallet is Ownable, Croupier, Contracts {
    using SafeMath for *;

    uint64 private _depositId = 0;
    uint64 private _withdrawId = 0;

    //log
    event DepositPlaced(uint64 id, address player, uint256 amount, string memo);
    event WithdrawPlaced(uint64 id, address player, uint256 amount, string memo);

    function deposit(string memo) external payable {
        require(tx.origin == msg.sender, "No contract bet accepted");
        require(msg.value > 0, "Invalid amount");

        emit DepositPlaced(_depositId, msg.sender, msg.value, memo);
        _depositId++;
    }

    function withdraw(address player, uint256 amount, string memo) external onlyCroupier {
        player.transfer(amount);
        emit WithdrawPlaced(_withdrawId, player, amount, memo);
        _withdrawId++;
    }
}

