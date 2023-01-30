/**

 *Submitted for verification at Etherscan.io on 2019-05-31

*/



pragma solidity ^ 0.5.8;

 

 /**

 *  ¨X¨T¨[¨X¨T¨[¨X¨T¨T¨T¨[¨X¨T¨T¨[©¤¨X¨T¨T¨T¨[¨X¨T¨T¨T¨T¨[     ©¤©¤©¤©¤©¤©¤¨X¨T¨T¨[¨X¨T¨[©¤¨X¨[

 *  ¨^¨[¨^¨a¨X¨a¨U¨X¨T¨[¨U¨U¨X¨[¨U©¤¨U¨X¨T¨T¨a¨U¨X¨[¨X¨[¨U     ©¤©¤©¤©¤©¤©¤¨^¨g©¤¨a¨U¨U¨^¨[¨U¨U

 *  ©¤¨^¨[¨X¨a©¤¨^¨a¨X¨a¨U¨U¨^¨a¨^¨[¨U¨^¨T¨T¨[¨^¨a¨U¨U¨^¨a     ¨X¨[¨X¨[¨X¨[©¤¨U¨U©¤¨U¨X¨[¨^¨a¨U

 *  ©¤¨X¨a¨^¨[©¤¨X¨T¨a¨X¨a¨U¨X¨T¨[¨U¨U¨X¨T¨T¨a©¤©¤¨U¨U©¤©¤     ¨U¨^¨a¨^¨a¨U©¤¨U¨U©¤¨U¨U¨^¨[¨U¨U

 *  ¨X¨a¨X¨[¨^¨[¨U¨U¨^¨T¨[¨U¨^¨T¨a¨U¨U¨^¨T¨T¨[©¤©¤¨U¨U©¤©¤     ¨^¨[¨X¨[¨X¨a¨X¨g©¤¨[¨U¨U©¤¨U¨U¨U

 *  ¨^¨T¨a¨^¨T¨a¨^¨T¨T¨T¨a¨^¨T¨T¨T¨a¨^¨T¨T¨T¨a©¤©¤¨^¨a©¤©¤     ©¤¨^¨a¨^¨a©¤¨^¨T¨T¨a¨^¨a©¤¨^¨T¨a

 *

 * 

 * The contract of acceptance and withdrawal of funds in the first, fair and open gaming platform https://x2bet.win

 * Buying coins x2bet you agree that you have turned 18 years old and you realize the risk associated with gambling and slot machines

 * For the withdrawal of winnings from the system, a commission of 3% is charged.

 * The creator of the project is not responsible for the player¡¯s financial losses when playing fair slot machines, all actions you do at your own risk.

 * The project team has the right to suspend withdrawal of funds, in case of detection of suspicious actions, until clarification of circumstances.

 */



contract X2Bet_win {

    

    using SafeMath

    for uint;

    

    address public owner;

    mapping(address => uint) public deposit;

    mapping(address => uint) public withdrawal;

    bool public status = true;

    uint public min_payment = 0.05 ether;

    uint public systemPercent = 0;

    

    constructor()public {

        owner = msg.sender;

    }

    

    event ByCoin(

        address indexed from,

        uint indexed block,

        uint value,

        uint user_id,

        uint time

    );

    

    event ReturnRoyalty(

        address indexed from,

        uint indexed block,

        uint value, 

        uint withdrawal_id,

        uint time

    );

    

    modifier isNotContract(){

        uint size;

        address addr = msg.sender;

        assembly { size := extcodesize(addr) }

        require(size == 0 && tx.origin == msg.sender);

        _;

    }

    

    modifier contractIsOn(){

        require(status);

        _;

    }

    

    modifier minPayment(){

        require(msg.value >= min_payment);

        _;

    }

    

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    //Coin purchase method x2Bet.win

    function byCoin(uint _user_id)contractIsOn isNotContract minPayment public payable{

        deposit[msg.sender]+= msg.value;

        emit ByCoin(msg.sender, block.number, msg.value, _user_id, now);

        

    }

    

    //Automatic withdrawal of winnings x2Bet.win

    function pay_royaltie(address payable[] memory dests, uint256[] memory values, uint256[] memory ident) onlyOwner contractIsOn public returns(uint){

        uint256 i = 0;

        while (i < dests.length) {

            uint transfer_value = values[i].sub(values[i].mul(3).div(100));

            dests[i].transfer(transfer_value);

            withdrawal[dests[i]]+=values[i];

            emit ReturnRoyalty(dests[i], block.number, values[i], ident[i], now);

            systemPercent += values[i].mul(3).div(100);

            i += 1;

        }

        

        return(i);

    }

    

    function startProphylaxy()onlyOwner public {

        status = false;

    }

    

    function stopProphylaxy()onlyOwner public {

        status = true;

    }

    

    function() external payable {

        

    }

    

}



library SafeMath {



    /**

     * @dev Multiplies two numbers, reverts on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        require(c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns(uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0

        uint256 c = a / b;

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns(uint256) {

        require(b <= a);

        uint256 c = a - b;

        return c;

    }



    function add(uint256 a, uint256 b) internal pure returns(uint256) {

        uint256 c = a + b;

        require(c >= a);

        return c;

    }

}