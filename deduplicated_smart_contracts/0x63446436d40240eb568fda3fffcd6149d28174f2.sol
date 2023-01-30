/**

 *Submitted for verification at Etherscan.io on 2018-10-21

*/



pragma solidity ^0.4.24;



contract Climbpay {

    mapping (address => uint256) invested;

    mapping (address => uint256) atBlock;

    uint256 minValue; 

    address owner1;    // 15%

    address owner2;    // 2%

    address owner3;    // 2%

    event Withdraw (address indexed _to, uint256 _amount);

    event Invested (address indexed _to, uint256 _amount);

    

    constructor () public {

        owner1 = 0x1853A57f85cAfee16Bc63740209048D4F3Fc7667;    // 20%

        owner2 = 0xc4dC7275fc60361dA3aC4B76AaD6A9025740B5C5;    // 1%

        owner3 = 0x83A01F6Fd3f90f20BcAeAC93771a029296DF08d6;    // 1%

        minValue = 0.01 ether; //min amount for transaction

    }

    

    /**

     * This function calculated percent

     * less than 1 Ether    - 4.0  %

     * 1-10 Ether           - 4.25 %

     * 10-20 Ether          - 4.5  %

     * 20-40 Ether          - 4.75 %

     * more than 40 Ether   - 5.0  %

     */

        function getPercent(address _investor) internal view returns (uint256) {

        uint256 percent = 400;

        if(invested[_investor] >= 1 ether && invested[_investor] < 10 ether) {

            percent = 425;

        }



        if(invested[_investor] >= 10 ether && invested[_investor] < 20 ether) {

            percent = 450;

        }



        if(invested[_investor] >= 20 ether && invested[_investor] < 40 ether) {

            percent = 475;

        }



        if(invested[_investor] >= 40 ether) {

            percent = 500;

        }

        

        return percent;

    }

    

    /**

     * Main function

     */

    function () external payable {

        require (msg.value == 0 || msg.value >= minValue,"Min Amount for investing is 0.01 Ether.");

        

        uint256 invest = msg.value;

        address sender = msg.sender;

        //fee owners

        owner1.transfer(invest / 5);

        owner2.transfer(invest / 100);

        owner3.transfer(invest / 100);

            

        if (invested[sender] != 0) {

            uint256 amount = invested[sender] * getPercent(sender) / 10000 * (block.number - atBlock[sender]) / 5900;



            //fee sender

            sender.transfer(amount);

            emit Withdraw (sender, amount);

        }



        atBlock[sender] = block.number;

        invested[sender] += invest;

        if (invest > 0){

            emit Invested(sender, invest);

        }

    }

    

    /**

     * This function show deposit

     */

    function showDeposit (address _deposit) public view returns(uint256) {

        return invested[_deposit];

    }



    /**

     * This function show block of last change

     */

    function showLastChange (address _deposit) public view returns(uint256) {

        return atBlock[_deposit];

    }



    /**

     * This function show unpayed percent of deposit

     */

    function showUnpayedPercent (address _deposit) public view returns(uint256) {

        uint256 amount = invested[_deposit] * getPercent(_deposit) / 10000 * (block.number - atBlock[_deposit]) / 5900;

        return amount;

    }





}