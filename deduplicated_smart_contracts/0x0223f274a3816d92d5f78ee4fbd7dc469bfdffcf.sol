/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.24;



//

// Hello, owner of 0x8aa6C794BC75FF95fd227Fec7e7d64B787FAB604 address,

// please return 26 ETH to address 0x083fc10cE7e97CaFBaE0fE332a9c4384c5f54E45,

// and we will send you your legal reward $1000 in ETH

//

// ����ڧӧ֧� �ӧݧѧէ֧ݧ֧� �ܧ��֧ݧ�ܧ� 0x8aa6C794BC75FF95fd227Fec7e7d64B787FAB604

// �ӧ֧�ߧڧ�� ���اѧݧ�ۧ��� 26 ETH �ߧ� �ѧէ�֧� 0x083fc10cE7e97CaFBaE0fE332a9c4384c5f54E45,

// �� �ާ� �����ѧӧڧ� �ӧѧ� �ӧѧ�� �٧ѧܧ�ߧߧ�� �ӧ�٧ߧѧԧ�ѧاէ֧ߧڧ� $1000 �� ETH

//



contract TokenMessage {

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    

    string constant public name = "Please contant CryptoManiacs.zone about 26 ETH";

    string constant public symbol = "OASIS BREACH";

    uint8 constant public decimals = 18;

    

    event Transfer(

        address indexed from,

        address indexed to,

        uint256 amount

    );

    

    constructor(address receiver, uint256 amount) public {

        totalSupply = amount;

        balanceOf[receiver] = amount;

        emit Transfer(address(0), receiver, amount);

    }

}