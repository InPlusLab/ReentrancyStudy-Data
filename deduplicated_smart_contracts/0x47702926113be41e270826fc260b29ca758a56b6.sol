/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity ^0.4.24;



/*

  §²§Ö§Ñ§Ý§Ú§Ù§Ñ§è§Ú§ñ §ã§Þ§Ñ§â§ä §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §á§à §ä§Ú§á§å 6 §Õ§â§å§Ù§Ö§Û

*/



contract SixFriends {



    using SafeMath for uint;



    address public ownerAddress; //§¡§Õ§â§Ö§ã§ã §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ

    uint private percentMarketing = 8; //§±§â§à§è§Ö§ß§ä§í §ß§Ñ §Þ§Ñ§â§Ü§Ö§ä§Ú§ß§Ô

    uint private percentAdministrator = 2; //§±§â§à§è§Ö§ß§ä§í §Ñ§Õ§Þ§Ú§ß§Ú§ã§ä§â§Ñ§è§Ú§Ú



    uint public c_total_hexagons; //§¬§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ô§Ö§Ü§ã§Ñ§Ô§à§ß§à§Ó §Ó§ã§Ö§Ô§à

    mapping(address =>  uint256) public Bills; //§¢§Ñ§Ý§Ñ§ß§ã §Õ§Ý§ñ §Ó§í§Ó§à§Õ§Ñ



    uint256 public BillsTotal; //§ã§å§Þ§Þ§Ñ§â§ß§Ñ§ñ §á§â§à§Ó§Ö§Õ§Ö§ß§ß§Ñ§ñ §ã§å§Þ§Þ§Ñ



    struct Node {

        uint256 usd;

        bool cfw;

        uint256 min; //§³§ä§à§Ú§Þ§à§ã§ä§î §Ó§ç§à§Õ§Ñ

        uint c_hexagons; //§¬§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ô§Ö§Ü§ã§Ñ§Ô§à§ß§à§Ó

        mapping(address => bytes32[]) Addresses; //§¡§Õ§â§Ö§ã§ã => §å§ß§Ú§Ü§Ñ§Ý§î§ß§í§Ö §ã§ã§í§Ý§Ü§Ú

        mapping(address => uint256[6]) Statistics; //§¡§Õ§â§Ö§ã§ã => §ã§ä§Ñ§ä§Ú§ã§ä§Ú§Ü§Ñ §á§à §â§Ö§æ§Ö§â§Ñ§Ý§Ñ§Þ

        mapping(bytes32 => address[6]) Hexagons; //§µ§ß§Ú§Ü§Ñ§Ý§î§ß§Ñ§ñ §ã§ã§í§Ý§Ü§Ñ (keccak256) => 6 §Ü§à§ê§Ö§Ý§î§Ü§à§Ó

    }



    mapping (uint256 => Node) public Nodes; //§Ó§ã§Ö §ä§Ú§á§í



    //§±§â§à§Ó§Ö§â§ñ§Ö§ä §é§ä§à §ã§å§Þ§Þ§Ñ §á§Ö§â§Ö§Ó§à§Õ§Ñ §Õ§à§ã§ä§Ñ§ä§à§é§ß§Ñ

    modifier enoughMoney(uint256 tp) {

        require (msg.value >= Nodes[0].min, "Insufficient funds");

        _;

    }



    //§±§â§à§Ó§Ö§â§ñ§Ö§ä §é§ä§à §ä§à§ä §Ü§ä§à §á§Ö§â§Ö§Ó§Ö§Ý §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è §Ü§à§ê§Ö§Ý§î§Ü§Ñ

    modifier onlyOwner {

        require (msg.sender == ownerAddress, "Only owner");

        _;

    }



    //§²§Ñ§ß§Ö§Ö §ã§à§Ù§Õ§Ñ§ß

    modifier allReadyCreate(uint256 tp) {

        require (Nodes[tp].cfw == false);

        _;

    }



    //§±§â§à§Ó§Ö§â§ñ§ð §é§ä§à §é§Ö§Ý§à§Ó§Ö§Ü §Ù§Ñ§á§â§à§ã§Ú§Ó§ê§Ú§Û §ñ§Ó§Ý§ñ§Ö§ä§ñ §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ö§Þ §Ò§Ñ§Ý§Ñ§ß§ã§Ñ

    modifier recipientOwner(address recipient) {

        require (Bills[recipient] > 0);

        require (msg.sender == recipient);

        _;

    }



    //§¶§å§ß§Ü§è§Ú§ñ §Õ§Ý§ñ §à§á§Ý§Ñ§ä§í

    function pay(bytes32 ref, uint256 tp) public payable enoughMoney(tp) {



        if (Nodes[tp].Hexagons[ref][0] == 0) ref = Nodes[tp].Addresses[ownerAddress][0]; //§¦§ã§Ý§Ú ref §ß§Ö §ß§Ñ§Û§Õ§Ö§ß§Ñ §ä§à §Ò§Ö§â§Ö§ä§ã§ñ §á§Ö§â§Ó§à§Ö §Ù§ß§Ñ§é§Ö§ß§Ú§Ö



        createHexagons(ref, tp); //§±§Ö§â§Ö§Õ§Ñ§ð §ä§Ö§Ü§å§ë§å§ð ref, §Õ§à§Ò§Ñ§Ó§Ý§ñ§ð §ß§à§Ó§í§Ö 6 §Õ§â§å§Ù§Ö§Û



        uint256 marketing_pay = ((msg.value / 100) * (percentMarketing + percentAdministrator));

        uint256 friend_pay = msg.value - marketing_pay;



        //§±§Ö§â§Ö§Ó§à§Ø§å §Õ§Ö§ß§î§Ô§Ú §ß§Ñ §ã§é§Ö§ä§Ñ §Ü§Ý§Ú§Ö§ß§ä§à§Ó

        for(uint256 i = 0; i < 6; i++)

            Bills[Nodes[tp].Hexagons[ref][i]] += friend_pay.div(6);



        //§±§Ö§â§Ö§Ó§à§Ø§å §Ü§à§Þ§Þ§Ú§ã§Ú§ð §ß§Ñ §Þ§Ñ§â§Ü§Ö§ä§Ú§ß§Ô

        Bills[ownerAddress] += marketing_pay;



        //§³§å§Þ§Þ§Ú§â§å§ð §Ó§ã§Ö§Ô§à §Ó§í§á§Ý§Ñ§ä

        BillsTotal += msg.value;

    }



    function getHexagons(bytes32 ref, uint256 tp) public view returns (address, address, address, address, address, address)

    {

        return (Nodes[tp].Hexagons[ref][0], Nodes[tp].Hexagons[ref][1], Nodes[tp].Hexagons[ref][2], Nodes[tp].Hexagons[ref][3], Nodes[tp].Hexagons[ref][4], Nodes[tp].Hexagons[ref][0]);

    }



    //§©§Ñ§á§â§à§ã§Ú§ä§î §Õ§Ö§ß§î§Ô§Ú §Ú §à§Ò§ß§å§Ý§Ú§ä§î §ã§é§Ö§ä

    function getMoney(address recipient) public recipientOwner(recipient) {

        recipient.transfer(Bills[recipient]);

        Bills[recipient] = 0;

    }



    //§±§Ö§â§Ö§Õ§Ñ§ð §á§Ö§â§Ö§Õ§Ñ§ß§ß§å§ð §â§Ö§æ§Ü§å §Ú §Õ§à§Ò§Ñ§Ó§Ý§ñ§ð §ß§à§Ó§í§Û §Ô§Ö§Ü§ã§Ñ§Ô§à§ß

    function createHexagons(bytes32 ref, uint256 tp) internal {



        Nodes[tp].c_hexagons++; //§µ§Ó§Ö§Ý§Ú§é§Ú§Ó§Ñ§ð §ã§é§Ö§ä§é§Ú§Ü §Ô§Ö§Ü§ã§Ñ§Ô§à§ß§à§Ó §Ú §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§Û

        c_total_hexagons++; //§µ§Ó§Ö§Ý§Ú§é§Ú§Ó§Ñ§ð §ã§é§Ö§ä§é§Ú§Ü §Ô§Ö§Ü§ã§Ñ§Ô§à§ß§à§Ó §Ú §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§Û



        bytes32 new_ref = createRef(Nodes[tp].c_hexagons);



        //§±§â§à§ç§à§Ø§å §á§à §á§Ö§â§Ö§Õ§Ñ§ß§ß§à§Û §â§Ö§æ§Ü§Ö §Ú §ã§à§Ù§Õ§Ñ§ð §Ü§à§ê§Ö§Ý§î§Ü§Ú

        for(uint8 i = 0; i < 5; i++)

        {

            Nodes[tp].Hexagons[new_ref][i] = Nodes[tp].Hexagons[ref][i + 1]; //§¥§à§Ò§Ñ§Ó§Ý§ñ§ð §ß§à§Ó§í§Û §Ô§Ö§Ü§ã§Ñ§Ô§à§ß

            Nodes[tp].Statistics[Nodes[tp].Hexagons[ref][i]][5 - i]++; //§¥§à§Ò§Ñ§Ó§Ý§ñ§ð §ã§ä§Ñ§ä§Ú§ã§ä§Ü§å

        }



        Nodes[tp].Statistics[Nodes[tp].Hexagons[ref][i]][0]++; //§¥§à§Ò§Ñ§Ó§Ý§ñ§ð §ã§ä§Ñ§ä§Ú§ã§ä§Ü§å



        Nodes[tp].Hexagons[new_ref][5] = msg.sender;

        Nodes[tp].Addresses[msg.sender].push(new_ref); //§¥§à§Ò§Ñ§Ó§Ý§ñ§ð §â§Ö§æ§Ü§å

    }



    //§³§à§Ù§Õ§Ñ§ð §ß§à§Ó§í§Û §Ô§Ö§Ü§ã§Ñ§Ô§à§ß §ã §å§Ü§Ñ§Ù§Ñ§ß§Ú§Ö§Þ §Ö§Ô§à §ã§ä§à§Ú§Þ§à§ã§ä§Ú §Ú §á§à§â§ñ§Õ§Ü§à§Ó§à§Ô§à §ß§à§Þ§Ö§â§Ñ

    function createFirstWallets(uint256 usd, uint256 tp) public onlyOwner allReadyCreate(tp) {



        bytes32 new_ref = createRef(1);



        Nodes[tp].Hexagons[new_ref] = [ownerAddress, ownerAddress, ownerAddress, ownerAddress, ownerAddress, ownerAddress];

        Nodes[tp].Addresses[ownerAddress].push(new_ref);



        Nodes[tp].c_hexagons = 1; //§¬§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ô§Ö§Ü§ã§Ñ§Ô§à§ß§à§Ó

        Nodes[tp].usd = usd; //§³§Ü§à§Ý§î§Ü§à §ã§ä§à§Ú§ä §é§Ý§Ö§ß§ã§Ü§Ú§Û §Ó§Ù§ß§à§ã §Ó §ï§ä§å §ß§à§Õ§å §Ó §Õ§à§Ý§Ý§Ñ§â§Ñ§ç

        Nodes[tp].cfw = true; //§¯§à§Õ§Ñ §á§à§Þ§Ö§é§Ñ§Ö§ä§ã§ñ §Ü§Ñ§Ü §ã§à§Ù§Õ§Ñ§ß§ß§Ñ§ñ



        c_total_hexagons++;

    }



    //§³§à§Ù§Õ§Ñ§ð §â§Ö§æ§Ö§â§Ñ§Ý§î§ß§å§ð §ã§ã§í§Ý§Ü§å §ß§Ñ §à§ã§ß§à§Ó§Ö §ß§à§Þ§Ö§â§Ñ §Ò§Ý§à§Ü§Ñ §Ú §ä§Ú§á§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ

    function createRef(uint hx) internal pure returns (bytes32) {

        uint256 _unixTimestamp;

        uint256 _timeExpired;

        return keccak256(abi.encodePacked(hx, _unixTimestamp, _timeExpired));

    }



    //§±§à§Ý§å§é§Ñ§ð §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ã§ã§í§Ý§à§Ü §Õ§Ý§ñ §Ñ§Õ§â§Ö§ã§Ñ

    function countAddressRef(address adr, uint256 tp) public view returns (uint count) {

        count = Nodes[tp].Addresses[adr].length;

    }



    //§±§à§Ý§å§é§Ñ§ð §ã§ã§í§Ý§Ü§å

    function getAddress(address adr, uint256 i, uint256 tp) public view returns(bytes32) {

        return Nodes[tp].Addresses[adr][i];

    }



    //§£§à§Ù§Ó§â§Ñ§ë§Ö§ß§Ú§Ö §ã§ä§Ñ§ä§Ú§ã§ä§Ú§Ü§Ú

    function getStatistics(address adr, uint256 tp) public view returns(uint256, uint256, uint256, uint256, uint256, uint256)

    {

        return (Nodes[tp].Statistics[adr][0], Nodes[tp].Statistics[adr][1], Nodes[tp].Statistics[adr][2], Nodes[tp].Statistics[adr][3], Nodes[tp].Statistics[adr][4], Nodes[tp].Statistics[adr][5]);

    }



    //§µ§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§ð §ã§ä§à§Ú§Þ§à§ã§ä§î §Ó§ç§à§Õ§Ñ

    function setMin(uint value, uint256 tp) public onlyOwner {

        Nodes[tp].min = value;

    }



    //§±§à§Ý§å§é§Ö§ß§Ú§Ö §Þ§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§à§Û §ã§ä§à§Ú§Þ§à§ã§ä§Ú

    function getMin(uint256 tp) public view returns (uint256) {

        return Nodes[tp].min;

    }



    //§±§à§Ý§å§é§Ñ§ð §ä§à§ä§Ñ§Ý §Õ§Ö§ß§Ö§Ô

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