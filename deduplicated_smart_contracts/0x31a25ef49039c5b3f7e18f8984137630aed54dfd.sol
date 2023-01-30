/**

 *Submitted for verification at Etherscan.io on 2019-06-12

*/



pragma solidity 0.5.7;



/**

 * @title Game

 * @dev A game of wits.

 */

contract Game {



    address public governance;



    constructor(address _governance) public payable {

        governance = _governance;

    }



    function claim(address payable who) public {

        require(msg.sender == governance, "Game::claim: The winner must be approved by governance");



        selfdestruct(who);

    }



}