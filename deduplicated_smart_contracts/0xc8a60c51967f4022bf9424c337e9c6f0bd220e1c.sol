/**

 *Submitted for verification at Etherscan.io on 2018-10-08

*/



/**

����ާާ� �ӧ�֧� �����֧ߧ��� = 2% ��ڧܧ�ڧ��ӧѧߧߧ�� + ���ڧߧѧާڧ�֧�ܧڧ� �����֧ߧ� ��� �ҧѧݧѧߧ�� �ܧ�ߧ��ѧܧ�� + ���ߧէڧӧڧէ�ѧݧ�ߧ�� �����֧ߧ� �� ���ާާ� �ӧܧݧѧէ�.

����ڧާ֧��:

����ݧ� �ӧ� �ӧߧ֧�ݧ� 1 ETH �� �ҧѧݧѧߧ� �ܧ�ߧ��ѧܧ�� 10 ETH, ��� ���ѧ� ���ާާѧ�ߧ�� �����֧ߧ� = 2.009166666 %

����ݧ� �ӧ� �ӧߧ֧�ݧ� 10 ETH �� �ҧѧݧѧߧ� �ܧ�ߧ��ѧܧ�� 250 ETH, ��� ���ѧ� ���ާާѧ�ߧ�� �����֧ߧ� = 2.19166666 %

����ݧ� �ӧ� �ӧߧ֧�ݧ� 15 ETH �� �ҧѧݧѧߧ� �ܧ�ߧ��ѧܧ�� 1200 ETH, ��� ���ѧ� ���ާާѧ�ߧ�� �����֧ߧ� = 2,83755 %

����ݧ� �ӧ� �ӧߧ֧�ݧ� 20 ETH �� �ҧѧݧѧߧ� �ܧ�ߧ��ѧܧ�� 3777 ETH, ��� ���ѧ� ���ާާѧ�ߧ�� �����֧ߧ� = 4.568 %



���֧� �ҧ�ݧ��� �ӧܧݧѧ� �� ���ҧ�ѧߧߧ�� �ڧߧӧ֧��ڧ�ڧ�, ��֧� �ҧ�ݧ��� ���ѧ� �����֧ߧ�.

 */

 

pragma solidity ^0.4.25;

contract NOTBAD_DynamicS {

    mapping (address => uint256) public invested;

    mapping (address => uint256) public atBlock;

    function () external payable

    {

        if (invested[msg.sender] != 0) {

            // �����ݧѧ�� = 2% ��ڧܧ�ڧ��ӧѧߧߧ�� + (�ҧѧݧѧߧ� �ܧ�ߧ��ѧܧ�� �� �ާ�ާ֧ߧ� �٧ѧ����� �ӧ��ݧѧ�� / 1500) + (���ާާ� �ڧߧӧ֧��ڧ�ڧ� / 400 ) / 100 * (�ߧ�ާ֧� �ҧݧ�ܧ� �ӧ����է� - �ߧ�ާ֧� �ҧݧ�ܧ� �ӧ称�է�) / ���֧էߧ�� ���ާާ� �ҧݧ�ܧ�� �� ����ܧ�. 

            uint256 amount = invested[msg.sender] * ( 2 + ((address(this).balance / 1500) + (invested[msg.sender] / 400))) / 100 * (block.number - atBlock[msg.sender]) / 6000;

            msg.sender.transfer(amount);

        }

        atBlock[msg.sender] = block.number;

        invested[msg.sender] += msg.value;

    }

}