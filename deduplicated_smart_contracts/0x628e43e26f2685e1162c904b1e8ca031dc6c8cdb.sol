/**

 *Submitted for verification at Etherscan.io on 2018-10-05

*/



pragma solidity ^ 0.4.25;

/* ����һ�����࣬ �˻�����Ա */

contract owned {



    address public owner;



    constructor() public {

    owner = msg.sender;

    }

    /* modifier���޸ı�־ */

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    /* �޸Ĺ���Ա�˻��� onlyOwner����ֻ�����û�����Ա���޸� */

    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner;

    }   

}

contract lepaitoken is owned{

    uint public systemprice;

    struct putusers{

	    	address puser;//������

	    	uint addtime;//����ʱ��

	    	uint addmoney; //���ļ۸�

	    	string useraddr; //�����˵�ַ 

    }

    struct auctionlist{

        address adduser;//�����0

        uint opentime;//��ʼʱ��1

        uint endtime;//����ʱ��2

        uint openprice;//���ļ۸�3

        uint endprice;//��߼۸�4

        uint onceprice;//ÿ�μӼ�5

        uint currentprice;//��ǰ�۸�6

        string goodsname; //��Ʒ����7

        string goodspic; //��ƷͼƬ8 

        bool ifend;//�Ƿ����9

        uint ifsend;//�Ƿ񷢻�10

        uint lastid;//������11

        mapping(uint => putusers) aucusers;//�����˵�������

        mapping(address => uint) ausers;//�����˵ľ��ļ۸�

    }

    auctionlist[] public auctionlisting; //�����е�

    auctionlist[] public auctionlistend; //���Ľ�����

    auctionlist[] public auctionlistts; //���Ľ�����

    mapping(address => uint[]) userlist;//�û����о��ĵĶ���

    mapping(address => uint[]) mypostauct;//���������з����Ķ���

    //0x56F527C3F4a24bB2BeBA449FFd766331DA840FFA

    btycInterface constant private btyc = btycInterface(0x56F527C3F4a24bB2BeBA449FFd766331DA840FFA);

    /* ֪ͨ */

	event auctconfim(address target, uint tokens);//���ĳɹ�֪ͨ

	event getmoneys(address target, uint tokens);//��ȡ����֪ͨ

	constructor() public {

	    systemprice = 20000 ether;

	}

	/*������� */

	function addauction(address addusers,uint opentimes, uint endtimes, uint onceprices, uint openprices, uint endprices, string goodsnames, string goodspics) public returns(uint){

	    uint _now = now;

	    require(opentimes < _now + 2 days);

	    require(endtimes > opentimes);

	    require(endtimes > _now + 2 days);

	    require(endtimes < opentimes + 2 days);

	    require(btyc.balanceOf(addusers) >= systemprice);

	    auctionlisting.push(auctionlist(addusers, opentimes, endtimes, openprices, endprices, onceprices, openprices, goodsnames, goodspics, false, 0, 0));

	    uint lastid = auctionlisting.length;

	    mypostauct[addusers].push(lastid);

	    return(lastid);

	}

	//�����߷���������

	function getmypostlastid() public view returns(uint){

	    return(mypostauct[msg.sender].length);

	}

	//�����߷����Ķ���id

	function getmypost(uint ids) public view returns(uint){

	    return(mypostauct[msg.sender][ids]);

	}

	//�û����

	function balanceOf(address addr) public view returns(uint) {

	    return(btyc.balanceOf(addr));

	}

	//�û��������

	function canuse(address addr) public view returns(uint) {

	    return(btyc.getcanuse(addr));

	}

	//��Լ�������

	function ownerof() public view returns(uint) {

	    return(btyc.balanceOf(this));

	}

	//�Ѻ�Լ���ת��

	function sendleftmoney(uint money, address toaddr) public onlyOwner{

	    btyc.transfer(toaddr, money);

	}

	/*�û�����*/

	function inputauction(uint auctids, address pusers, uint addmoneys,string useraddrs) public {

	    uint _now = now;

	    auctionlist storage c = auctionlisting[auctids];

	    require(c.ifend == false);

	    require(c.ifsend == 0);

	    

	    uint userbalance = canuse(pusers);

	    require(addmoneys > c.currentprice);

	    require(addmoneys <= c.endprice);

	    uint userhasmoney = c.ausers[pusers];

	    uint money = addmoneys;

	    if(userhasmoney > 0) {

	        require(addmoneys > userhasmoney);

	        money = addmoneys - userhasmoney;

	    }

	    

	    require(userbalance >= money);

	    if(c.endtime < _now) {

	        c.ifend = true;

	    }else{

	        if(addmoneys == c.endprice){

	            c.ifend = true;

	        }

	        btyc.transfer(this, money);

	        c.ausers[pusers] = addmoneys;

	        c.currentprice = addmoneys;

	        c.aucusers[c.lastid++] = putusers(pusers, _now, addmoneys,  useraddrs);

	    

	        userlist[pusers].push(auctids);

	        emit auctconfim(pusers, money);

	    }

	    

	    

	    //}

	    

	}

	//��ȡ�û��Լ����ĵ�����

	function getuserlistlength(address uaddr) public view returns(uint len) {

	    len = userlist[uaddr].length;

	}

	//�鿴��������

	function viewauction(uint aid) public view returns(address addusers,uint opentimes, uint endtimes, uint onceprices, uint openprices, uint endprices, uint currentprices, string goodsnames, string goodspics, bool ifends, uint ifsends, uint anum){

		auctionlist storage c = auctionlisting[aid];

		addusers = c.adduser;//0

		opentimes = c.opentime;//1

		endtimes = c.endtime;//2

		onceprices = c.onceprice;//3

		openprices = c.openprice;//4

		endprices = c.endprice;//5

		currentprices = c.currentprice;//6

		goodspics = c.goodspic;//7

		goodsnames = c.goodsname;//8

		ifends = c.ifend;//9

		ifsends = c.ifsend;//10

		anum = c.lastid;//11

		

	}

	//��ȡ���������ľ���������

	function viewauctionlist(uint aid, uint uid) public view returns(address pusers,uint addtimes,uint addmoneys){

	    auctionlist storage c = auctionlisting[aid];

	    putusers storage u = c.aucusers[uid];

	    pusers = u.puser;//0

	    addtimes = u.addtime;//1

	    addmoneys = u.addmoney;//2

	}

	//��ȡ���о�����Ʒ������

	function getactlen() public view returns(uint) {

	    return(auctionlisting.length);

	}

	//��ȡͶ�߶���������

	function getacttslen() public view returns(uint) {

	    return(auctionlistts.length);

	}

	//��ȡ������������

	function getactendlen() public view returns(uint) {

	    return(auctionlistend.length);

	}

	//�������趨����

	function setsendgoods(uint auctids) public {

	    uint _now = now;

	     auctionlist storage c = auctionlisting[auctids];

	     require(c.adduser == msg.sender);

	     require(c.endtime < _now);

	     require(c.ifsend == 0);

	     c.ifsend = 1;

	     c.ifend = true;

	}

	//�������յ��������

	function setgetgoods(uint auctids) public {

	    uint _now = now;

	    auctionlist storage c = auctionlisting[auctids];

	    require(c.endtime < _now);

	    require(c.ifend == true);

	    require(c.ifsend == 1);

	    putusers storage lasttuser = c.aucusers[c.lastid];

	    require(lasttuser.puser == msg.sender);

	    c.ifsend = 2;

	    uint getmoney = lasttuser.addmoney*70/100;

	    btyc.mintToken(c.adduser, getmoney);

	    auctionlistend.push(c);

	}

	//��ȡ�û��ķ�����ַ�������ߣ�

	function getuseraddress(uint auctids) public view returns(string){

	    auctionlist storage c = auctionlisting[auctids];

	    require(c.adduser == msg.sender);

	    //putusers memory mdata = c.aucusers[c.lastid];

	    return(c.aucusers[c.lastid].useraddr);

	}

	function editusetaddress(uint aid, string setaddr) public returns(bool){

	    auctionlist storage c = auctionlisting[aid];

	    putusers storage data = c.aucusers[c.lastid];

	    require(data.puser == msg.sender);

	    data.useraddr = setaddr;

	    return(true);

	}

	/*�û���ȡ�������ͷ�����ֻ�ܷ���һ�� */

	function endauction(uint auctids) public {

	    //uint _now = now;

	    auctionlist storage c = auctionlisting[auctids];

	    require(c.ifsend == 2);

	    uint len = c.lastid;

	    putusers storage firstuser = c.aucusers[0];

        address suser = msg.sender;

	    

	    require(c.ifend == true);

	    require(len > 1);

	    require(c.ausers[suser] > 0);

	    uint sendmoney = 0;

	    if(len == 2) {

	        require(firstuser.puser == suser);

	        sendmoney = c.currentprice*3/10 + c.ausers[suser];

	    }else{

	        if(firstuser.puser == suser) {

	            sendmoney = c.currentprice*1/10 + c.ausers[suser];

	        }else{

	            uint onemoney = (c.currentprice*2/10)/(len-2);

	            sendmoney = onemoney + c.ausers[suser];

	        }

	    }

	    require(sendmoney > 0);

	    btyc.mintToken(suser, sendmoney);

	    c.ausers[suser] = 0;

	    emit getmoneys(suser, sendmoney);

	    

	}

	//�趨������׼��

	function setsystemprice(uint price) public onlyOwner{

	    systemprice = price;

	}

	//����Ա���ᷢ���ߺ���Ʒ

	function setauctionother(uint auctids) public onlyOwner{

	    auctionlist storage c = auctionlisting[auctids];

	    btyc.freezeAccount(c.adduser, true);

	    c.ifend = true;

	    c.ifsend = 3;

	}

	//�趨��Ʒ״̬

	function setauctionsystem(uint auctids, uint setnum) public onlyOwner{

	    auctionlist storage c = auctionlisting[auctids]; 

	    c.ifend = true;

	    c.ifsend = setnum;

	}

	//�趨��Ʒ����

	function setauctionotherfree(uint auctids) public onlyOwner{

	    auctionlist storage c = auctionlisting[auctids];

	    btyc.freezeAccount(c.adduser, false);

	    c.ifsend = 2;

	}

	//Ͷ�߷�����δ��������ﲻ��

	function tsauction(uint auctids) public{

	   auctionlist storage c = auctionlisting[auctids];

	   uint _now = now;

	   require(c.endtime > _now);

	   require(c.endtime + 2 days < _now);

	   require(c.aucusers[c.lastid].puser == msg.sender);

	   if(c.endtime + 2 days < _now && c.ifsend == 0) {

	       c.ifsend = 5;

	       c.ifend = true;

	       auctionlistts.push(c);

	   }

	   if(c.endtime + 9 days < _now && c.ifsend == 1) {

	       c.ifsend = 5;

	       c.ifend = true;

	       auctionlistts.push(c);

	   }

	}

	//����Ա�趨Υ�澺�ķ���������

	function endauctionother(uint auctids) public {

	    //uint _now = now;

	    auctionlist storage c = auctionlisting[auctids];

	    address suser = msg.sender;

	    require(c.ifsend == 3);

	    require(c.ausers[suser] > 0);

	    btyc.mintToken(suser,c.ausers[suser]);

	    c.ausers[suser] = 0;

	    emit getmoneys(suser, c.ausers[suser]);

	}

	

}

//btyc�ӿ���

interface btycInterface {

    //mapping(address => uint) balances;

    function balanceOf(address _addr) external view returns (uint256);

    function mintToken(address target, uint256 mintedAmount) external returns (bool);

    function transfer(address to, uint tokens) external returns (bool);

    function freezeAccount(address target, bool freeze) external returns (bool);

    function getcanuse(address tokenOwner) external view returns(uint);

}