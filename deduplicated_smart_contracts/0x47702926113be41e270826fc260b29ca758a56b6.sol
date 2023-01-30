/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity ^0.4.24;



/*

  ���֧ѧݧڧ٧ѧ�ڧ� ��ާѧ�� �ܧ�ߧ��ѧܧ�� ��� ��ڧ�� 6 �է��٧֧�

*/



contract SixFriends {



    using SafeMath for uint;



    address public ownerAddress; //���է�֧�� �ӧݧѧէ֧ݧ���

    uint private percentMarketing = 8; //������֧ߧ�� �ߧ� �ާѧ�ܧ֧�ڧߧ�

    uint private percentAdministrator = 2; //������֧ߧ�� �ѧէާڧߧڧ���ѧ�ڧ�



    uint public c_total_hexagons; //����ݧڧ�֧��ӧ� �ԧ֧ܧ�ѧԧ�ߧ�� �ӧ�֧ԧ�

    mapping(address =>  uint256) public Bills; //���ѧݧѧߧ� �էݧ� �ӧ�ӧ�է�



    uint256 public BillsTotal; //���ާާѧ�ߧѧ� ����ӧ֧է֧ߧߧѧ� ���ާާ�



    struct Node {

        uint256 usd;

        bool cfw;

        uint256 min; //�����ڧާ���� �ӧ��է�

        uint c_hexagons; //����ݧڧ�֧��ӧ� �ԧ֧ܧ�ѧԧ�ߧ��

        mapping(address => bytes32[]) Addresses; //���է�֧�� => ��ߧڧܧѧݧ�ߧ�� ����ݧܧ�

        mapping(address => uint256[6]) Statistics; //���է�֧�� => ���ѧ�ڧ��ڧܧ� ��� ��֧�֧�ѧݧѧ�

        mapping(bytes32 => address[6]) Hexagons; //���ߧڧܧѧݧ�ߧѧ� ����ݧܧ� (keccak256) => 6 �ܧ��֧ݧ�ܧ��

    }



    mapping (uint256 => Node) public Nodes; //�ӧ�� ��ڧ��



    //�����ӧ֧��֧� ���� ���ާާ� ��֧�֧ӧ�է� �է���ѧ���ߧ�

    modifier enoughMoney(uint256 tp) {

        require (msg.value >= Nodes[0].min, "Insufficient funds");

        _;

    }



    //�����ӧ֧��֧� ���� ���� �ܧ�� ��֧�֧ӧ֧� �ӧݧѧէ֧ݧ֧� �ܧ��֧ݧ�ܧ�

    modifier onlyOwner {

        require (msg.sender == ownerAddress, "Only owner");

        _;

    }



    //���ѧߧ֧� ���٧էѧ�

    modifier allReadyCreate(uint256 tp) {

        require (Nodes[tp].cfw == false);

        _;

    }



    //�����ӧ֧��� ���� ��֧ݧ�ӧ֧� �٧ѧ����ڧӧ�ڧ� ��ӧݧ�֧�� �ӧݧѧէ֧ݧ��֧� �ҧѧݧѧߧ��

    modifier recipientOwner(address recipient) {

        require (Bills[recipient] > 0);

        require (msg.sender == recipient);

        _;

    }



    //����ߧܧ�ڧ� �էݧ� ���ݧѧ��

    function pay(bytes32 ref, uint256 tp) public payable enoughMoney(tp) {



        if (Nodes[tp].Hexagons[ref][0] == 0) ref = Nodes[tp].Addresses[ownerAddress][0]; //����ݧ� ref �ߧ� �ߧѧۧէ֧ߧ� ��� �ҧ֧�֧��� ��֧�ӧ�� �٧ߧѧ�֧ߧڧ�



        createHexagons(ref, tp); //���֧�֧էѧ� ��֧ܧ���� ref, �է�ҧѧӧݧ�� �ߧ�ӧ�� 6 �է��٧֧�



        uint256 marketing_pay = ((msg.value / 100) * (percentMarketing + percentAdministrator));

        uint256 friend_pay = msg.value - marketing_pay;



        //���֧�֧ӧ�ا� �է֧ߧ�ԧ� �ߧ� ���֧�� �ܧݧڧ֧ߧ���

        for(uint256 i = 0; i < 6; i++)

            Bills[Nodes[tp].Hexagons[ref][i]] += friend_pay.div(6);



        //���֧�֧ӧ�ا� �ܧ�ާާڧ�ڧ� �ߧ� �ާѧ�ܧ֧�ڧߧ�

        Bills[ownerAddress] += marketing_pay;



        //����ާާڧ��� �ӧ�֧ԧ� �ӧ��ݧѧ�

        BillsTotal += msg.value;

    }



    function getHexagons(bytes32 ref, uint256 tp) public view returns (address, address, address, address, address, address)

    {

        return (Nodes[tp].Hexagons[ref][0], Nodes[tp].Hexagons[ref][1], Nodes[tp].Hexagons[ref][2], Nodes[tp].Hexagons[ref][3], Nodes[tp].Hexagons[ref][4], Nodes[tp].Hexagons[ref][0]);

    }



    //���ѧ����ڧ�� �է֧ߧ�ԧ� �� ��ҧߧ�ݧڧ�� ���֧�

    function getMoney(address recipient) public recipientOwner(recipient) {

        recipient.transfer(Bills[recipient]);

        Bills[recipient] = 0;

    }



    //���֧�֧էѧ� ��֧�֧էѧߧߧ�� ��֧�ܧ� �� �է�ҧѧӧݧ�� �ߧ�ӧ�� �ԧ֧ܧ�ѧԧ��

    function createHexagons(bytes32 ref, uint256 tp) internal {



        Nodes[tp].c_hexagons++; //���ӧ֧ݧڧ�ڧӧѧ� ���֧��ڧ� �ԧ֧ܧ�ѧԧ�ߧ�� �� ���ѧߧ٧ѧܧ�ڧ�

        c_total_hexagons++; //���ӧ֧ݧڧ�ڧӧѧ� ���֧��ڧ� �ԧ֧ܧ�ѧԧ�ߧ�� �� ���ѧߧ٧ѧܧ�ڧ�



        bytes32 new_ref = createRef(Nodes[tp].c_hexagons);



        //�������ا� ��� ��֧�֧էѧߧߧ�� ��֧�ܧ� �� ���٧էѧ� �ܧ��֧ݧ�ܧ�

        for(uint8 i = 0; i < 5; i++)

        {

            Nodes[tp].Hexagons[new_ref][i] = Nodes[tp].Hexagons[ref][i + 1]; //����ҧѧӧݧ�� �ߧ�ӧ�� �ԧ֧ܧ�ѧԧ��

            Nodes[tp].Statistics[Nodes[tp].Hexagons[ref][i]][5 - i]++; //����ҧѧӧݧ�� ���ѧ�ڧ��ܧ�

        }



        Nodes[tp].Statistics[Nodes[tp].Hexagons[ref][i]][0]++; //����ҧѧӧݧ�� ���ѧ�ڧ��ܧ�



        Nodes[tp].Hexagons[new_ref][5] = msg.sender;

        Nodes[tp].Addresses[msg.sender].push(new_ref); //����ҧѧӧݧ�� ��֧�ܧ�

    }



    //����٧էѧ� �ߧ�ӧ�� �ԧ֧ܧ�ѧԧ�� �� ��ܧѧ٧ѧߧڧ֧� �֧ԧ� ����ڧާ���� �� �����էܧ�ӧ�ԧ� �ߧ�ާ֧��

    function createFirstWallets(uint256 usd, uint256 tp) public onlyOwner allReadyCreate(tp) {



        bytes32 new_ref = createRef(1);



        Nodes[tp].Hexagons[new_ref] = [ownerAddress, ownerAddress, ownerAddress, ownerAddress, ownerAddress, ownerAddress];

        Nodes[tp].Addresses[ownerAddress].push(new_ref);



        Nodes[tp].c_hexagons = 1; //����ݧڧ�֧��ӧ� �ԧ֧ܧ�ѧԧ�ߧ��

        Nodes[tp].usd = usd; //���ܧ�ݧ�ܧ� ����ڧ� ��ݧ֧ߧ�ܧڧ� �ӧ٧ߧ�� �� ���� �ߧ�է� �� �է�ݧݧѧ�ѧ�

        Nodes[tp].cfw = true; //����է� ���ާ֧�ѧ֧��� �ܧѧ� ���٧էѧߧߧѧ�



        c_total_hexagons++;

    }



    //����٧էѧ� ��֧�֧�ѧݧ�ߧ�� ����ݧܧ� �ߧ� ���ߧ�ӧ� �ߧ�ާ֧�� �ҧݧ�ܧ� �� ��ڧ�� �ܧ�ߧ��ѧܧ��

    function createRef(uint hx) internal pure returns (bytes32) {

        uint256 _unixTimestamp;

        uint256 _timeExpired;

        return keccak256(abi.encodePacked(hx, _unixTimestamp, _timeExpired));

    }



    //����ݧ��ѧ� �ܧ�ݧڧ�֧��ӧ� ����ݧ�� �էݧ� �ѧէ�֧��

    function countAddressRef(address adr, uint256 tp) public view returns (uint count) {

        count = Nodes[tp].Addresses[adr].length;

    }



    //����ݧ��ѧ� ����ݧܧ�

    function getAddress(address adr, uint256 i, uint256 tp) public view returns(bytes32) {

        return Nodes[tp].Addresses[adr][i];

    }



    //����٧ӧ�ѧ�֧ߧڧ� ���ѧ�ڧ��ڧܧ�

    function getStatistics(address adr, uint256 tp) public view returns(uint256, uint256, uint256, uint256, uint256, uint256)

    {

        return (Nodes[tp].Statistics[adr][0], Nodes[tp].Statistics[adr][1], Nodes[tp].Statistics[adr][2], Nodes[tp].Statistics[adr][3], Nodes[tp].Statistics[adr][4], Nodes[tp].Statistics[adr][5]);

    }



    //�����ѧߧѧӧݧڧӧѧ� ����ڧާ���� �ӧ��է�

    function setMin(uint value, uint256 tp) public onlyOwner {

        Nodes[tp].min = value;

    }



    //����ݧ��֧ߧڧ� �ާڧߧڧާѧݧ�ߧ�� ����ڧާ����

    function getMin(uint256 tp) public view returns (uint256) {

        return Nodes[tp].min;

    }



    //����ݧ��ѧ� ����ѧ� �է֧ߧ֧�

    function getBillsTotal() public view returns (uint256) {

        return BillsTotal;

    }



    constructor() public {

        ownerAddress = msg.sender;

    }

}



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}