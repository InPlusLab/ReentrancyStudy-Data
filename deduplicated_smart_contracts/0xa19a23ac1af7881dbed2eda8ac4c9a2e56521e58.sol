/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

/**
 * Target smart contract.
 * For any suggestions please contact me at zhuangyuan20(at)outlook.com
 * This is a guess-number game. You can deposit some money and then start the game. When the game contract receive the money you send, the guess number function implemented in your contact will be trigged and returns a number afterwards. If your number equals to the gameSeed which is a random number within [1,1000], you will be rewarded with 10 times of your deposited amount.
* Fallback function() allows a player to start the game by sending Ether to this contract. Then it invokes the guess number function of the player¡¯s contract, and retrieves the result (i.e., guessNum). If the player¡¯s guessNum happens to equal the gameSeed, it will send a 10-time reward to the player.
 */
pragma solidity >=0.4.22 <0.6.0;
contract GuessNumberGame{
    address owner;
    uint256 guessNum;
    uint256 gameSeed;
    uint256 nonce;
     constructor () public {
        owner = msg.sender;
        nonce = 1000;
    }

    function() external payable{
        address add;
        add=msg.sender;
        uint gameSeed = uint(blockhash(block.number-1))%nonce + 1;
       (bool success, bytes memory result)=add.delegatecall(abi.encodeWithSignature("GuessNumberFunction()"));
         guessNum=abi.decode(result, (uint256));
        if(guessNum == gameSeed){
        add.call.value(10*(msg.value)).gas(2076400)("");
               }
    }
}