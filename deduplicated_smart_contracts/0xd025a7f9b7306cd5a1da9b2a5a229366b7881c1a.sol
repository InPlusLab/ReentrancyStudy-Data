/**

 *Submitted for verification at Etherscan.io on 2019-02-01

*/



pragma solidity 0.4.25;



// ����ߧ���ѧܧ�.

contract MyMileage {



    // ���ݧѧէ֧ݧ֧� �ܧ�ߧ��ѧܧ��.

    address private owner;



    // �����ҧ�ѧا֧ߧڧ� ��֧� ���ާ� ��ѧۧݧ�� �� �էѧ��.

    mapping(bytes32 => uint) private map;



    // ����էڧ�ڧܧѧ��� �է������ "���ݧ�ܧ� �ӧݧѧէ֧ݧ֧�".

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    // ����ߧ����ܧ���.

    constructor() public {

        owner = msg.sender;

    }



    // ����ҧѧӧݧ֧ߧڧ� �٧ѧ�ڧ��.

    function put(bytes32 fileHash) onlyOwner public {



        // �����ӧ֧�ܧ� ������ԧ� �٧ߧѧ�֧ߧڧ� ��� �ܧݧ���.

        require(free(fileHash));



        // �����ѧߧ�ӧܧ� �٧ߧѧ�֧ߧڧ�.

        map[fileHash] = now;

    }



    // �����ӧ֧�ܧ� �ߧѧݧڧ�ڧ� �٧ߧѧ�֧ߧڧ�.

    function free(bytes32 fileHash) view public returns (bool) {

        return map[fileHash] == 0;

    }



    // ����ݧ��֧ߧڧ� �٧ߧѧ�֧ߧڧ�.

    function get(bytes32 fileHash) view public returns (uint) {

        return map[fileHash];

    }



    // ����ݧ��֧ߧڧ� �ܧ�է� ���է�ӧ֧�اէ֧ߧڧ�

    // �� �ӧڧէ� ��֧�� �ҧݧ�ܧ�.

    function getConfirmationCode() view public returns (bytes32) {

        return blockhash(block.number - 6);

    }

}