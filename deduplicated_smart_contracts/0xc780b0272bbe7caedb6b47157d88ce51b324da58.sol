/**

 *Submitted for verification at Etherscan.io on 2018-11-09

*/



pragma solidity ^0.4.24;



/*

    �҂�������������ļܘ������F�˟o���m�M������ҪCPU�YԴ�ĘO���w򞡣ͬ�r�҂����_���Y��������EOS�^�K��ϣ��Ͷע�Y��ͨ�^EOS�D�~����ʽͬ��ӛ���EOS�ϡ�

    ���C����ע��Ϣ���_͸�����ɲ�򞡣�_���Y����ƽ͸�����ɲ�򞡣�K�ҵ�����@�N�ܘ����҂�����֧�ֶ��ŷN����朎ŷN��Ͷע���ǅ^�K��ׄ���Dapp��Q������

    Ȼ������Dapp���оWվ��Ҫͨ�^�ϼs��ַ�����҂�����ˮ��r������؄e�����˺ϼs���挍ӳ���҂���Ͷע��ˮ��r����ҿ���ͨ�^׷�ٹٷ��Wվ���ѵ�EOS�~�����D�~ӛ�MEMO���ˌ���ˮ������ÿ��С�r�R��һ�Σ���

    ���ϼs�������_�ţ�Ո���{��.



    We adopted a class-like exchange architecture to achieve a speed-free experience with no fees and no CPU resources.

    At the same time, our lottery results use the EOS block hash, and the betting results are recorded on the EOS in the form of EOS transfer.

    The betting information is guaranteed to be transparent and identifiable. The results of the lottery are fair and transparent and can be checked.

    And thanks to this architecture, we can support multi-currency, cross-chain currency betting. It is the first Dapp solution in the blockchain.

    However, the major Dapp ranking websites need to track our flow status through the contract address, so this contract is specially established to truly map our betting flow.

    You can check the data (summary every half hour) by tracking the transfer record MEMO of the EOS account published on the official website.

    This contract is not open to the public, please do not call

*/

contract CashFlow {



    address public depositAddress = 0xbb02b2754386f0c76a2ad7f70ca4b272d29372f2;

    address public owner;



    modifier onlyOwner {

        require(owner == msg.sender, "only owner");

        _;

    }



    constructor() public payable {

        owner = msg.sender;

    }



    function() public payable {

        if(address(this).balance > 10 ether) {

            depositAddress.transfer(10 ether);

        }

    }



    function setOwner(address _owner) public onlyOwner {

        owner = _owner;

    }



    function setDepositAddress(address _to) public onlyOwner {

        depositAddress = _to;

    }



    function withdraw(uint amount) public onlyOwner {

        if (!owner.send(amount)) revert();

    }



    function ownerkill() public onlyOwner {

        selfdestruct(owner);

    }



}