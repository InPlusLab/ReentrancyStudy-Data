/**

 *Submitted for verification at Etherscan.io on 2018-10-06

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

    using SafeMath for uint;

    string public symbol;

	string public name;

	uint8 public decimals;

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

    auctionlist[] public auctionlistts; //����Ͷ�� 

    mapping(address => uint[]) userlist;//�û����о��ĵĶ���

    mapping(address => uint[]) mypostauct;//���������з����Ķ���

    mapping(address => uint) balances;

    //����Ա�ʺ�

	mapping(address => bool) public admins;

	/* �����˻� */

	mapping(address => bool) public frozenAccount;

	bool public actived;

    //0x56F527C3F4a24bB2BeBA449FFd766331DA840FFA

    address btycaddress = 0x56F527C3F4a24bB2BeBA449FFd766331DA840FFA;

    btycInterface constant private btyc = btycInterface(0x56F527C3F4a24bB2BeBA449FFd766331DA840FFA);

    /* ֪ͨ */

	event auctconfim(address target, uint tokens);//���ĳɹ�֪ͨ

	event getmoneys(address target, uint tokens);//��ȡ����֪ͨ

	event Transfer(address indexed from, address indexed to, uint tokens);

	event FrozenFunds(address target, bool frozen);

	/* modifier���޸ı�־ */

    modifier onlyadmin {

        require(admins[msg.sender] == true);

        _;

    }

	constructor() public {

	    symbol = "BTYC";

		name = "BTYC Coin";

		decimals = 18;

	    systemprice = 20000 ether;

	    admins[owner] = true;

	    actived = true;

	}

	/*������� */

	function addauction(uint opentimes, uint endtimes, uint onceprices, uint openprices, uint endprices, string goodsnames, string goodspics) public returns(uint){

	    uint _now = now;

	    address addusers = msg.sender;

	    require(actived == true);

	    require(!frozenAccount[addusers]);

	    require(opentimes >= _now - 1 hours);

	    require(opentimes < _now + 2 days);

	    require(endtimes > opentimes);

	    //require(endtimes > _now + 2 days);

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

	/* ��ȡ�û���� */

	function balanceOf(address tokenOwner) public view returns(uint balance) {

		return balances[tokenOwner];

	}

	//btyc�û����

	function btycBalanceOf(address addr) public view returns(uint) {

	    return(btyc.balanceOf(addr));

	}

	/* ˽�еĽ��׺��� */

    function _transfer(address _from, address _to, uint _value) private {

        // ��ֹת�Ƶ�0x0

        require(_to != 0x0);

        require(actived == true);

        // ��ⷢ�����Ƿ����㹻���ʽ�

        require(balances[_from] >= _value);

        // ����Ƿ�������������͵������

        require(balances[_to] + _value > balances[_to]);

        // ���˱���Ϊ�����Ķ��ԣ� ����������һ������

        uint previousBalances = balances[_from] + balances[_to];

        // ���ٷ������ʲ�

        balances[_from] -= _value;

        // ���ӽ����ߵ��ʲ�

        balances[_to] += _value;

        emit Transfer(_from, _to, _value);

        // ���Լ�⣬ ��Ӧ��Ϊ��

        assert(balances[_from] + balances[_to] == previousBalances);

    }

    function transfer(address _to, uint256 _value) public returns(bool){

        _transfer(msg.sender, _to, _value);

    }

    function transferadmin(address _from, address _to, uint _value)  public onlyadmin{

        _transfer(_from, _to, _value);

    }

    function transferto(uint256 _value) public returns(bool){

        _transfer(msg.sender, this, _value);

    }

	function addusermoney(address addr, uint money) public onlyadmin{

	    balances[addr] = balances[addr].add(money);

		emit Transfer(this, addr, money);

	}

	//�û��������

	function canuse(address addr) public view returns(uint) {

	    return(btyc.getcanuse(addr));

	}

	//��Լ�������

	function btycownerof() public view returns(uint) {

	    return(btyc.balanceOf(this));

	}

	function ownerof() public view returns(uint) {

	    return(balances[this]);

	}

	//�Ѻ�Լ���ת��

	function sendleftmoney(address _to, uint _value) public onlyadmin{

	     _transfer(this, _to, _value);

	}

	/*�û�����*/

	function inputauction(uint auctids, uint addmoneys, string useraddrs) public payable{

	    uint _now = now;

	    address pusers = msg.sender;

	    require(!frozenAccount[pusers]);

	    require(actived == true);

	    auctionlist storage c = auctionlisting[auctids];

	    require(c.ifend == false);

	    require(c.ifsend == 0);

	    

	    uint userbalance = canuse(pusers);

	    require(addmoneys > c.currentprice);

	    require(addmoneys <= c.endprice);

	   // uint userhasmoney = c.ausers[pusers];

	   require(addmoneys > c.ausers[pusers]);

	    uint money = addmoneys - c.ausers[pusers];

	    

	    require(userbalance >= money);

	    if(c.endtime < _now) {

	        c.ifend = true;

	    }else{

	        if(addmoneys == c.endprice){

	            c.ifend = true;

	        }

	        btycsubmoney(pusers, money);

	        c.ausers[pusers] = addmoneys;

	        c.currentprice = addmoneys;

	        c.aucusers[c.lastid++] = putusers(pusers, _now, addmoneys,  useraddrs);

	    

	        userlist[pusers].push(auctids);

	        //emit auctconfim(pusers, money);

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

	     require(!frozenAccount[msg.sender]);

	     require(c.adduser == msg.sender);

	     require(c.endtime < _now);

	     require(c.ifsend == 0);

	     c.ifsend = 1;

	     c.ifend = true;

	}

	//�������յ��������

	function setgetgoods(uint auctids) public {

	    uint _now = now;

	    require(actived == true);

	    require(!frozenAccount[msg.sender]);

	    auctionlist storage c = auctionlisting[auctids];

	    require(c.endtime < _now);

	    require(c.ifend == true);

	    require(c.ifsend == 1);

	    putusers storage lasttuser = c.aucusers[c.lastid];

	    require(lasttuser.puser == msg.sender);

	    c.ifsend = 2;

	    uint getmoney = lasttuser.addmoney*70/100;

	    btycaddmoney(c.adduser, getmoney);

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

	    require(actived == true);

	    auctionlist storage c = auctionlisting[aid];

	    putusers storage data = c.aucusers[c.lastid];

	    require(data.puser == msg.sender);

	    require(!frozenAccount[msg.sender]);

	    data.useraddr = setaddr;

	    return(true);

	}

	/*�û���ȡ�������ͷ�����ֻ�ܷ���һ�� */

	function endauction(uint auctids) public {

	    //uint _now = now;

	    auctionlist storage c = auctionlisting[auctids];

	    require(actived == true);

	    require(c.ifsend == 2);

	    uint len = c.lastid;

	    putusers storage firstuser = c.aucusers[0];

        address suser = msg.sender;

	    require(!frozenAccount[suser]);

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

	    c.ausers[suser] = 0;

	    btycaddmoney(suser, sendmoney);

	    emit getmoneys(suser, sendmoney);

	    

	}

	//�趨������׼��

	function setsystemprice(uint price) public onlyadmin{

	    systemprice = price;

	}

	//����Ա���ᷢ���ߺ���Ʒ

	function setauctionother(uint auctids) public onlyadmin{

	    auctionlist storage c = auctionlisting[auctids];

	    btyc.freezeAccount(c.adduser, true);

	    c.ifend = true;

	    c.ifsend = 3;

	}

	//�趨��Ʒ״̬

	function setauctionsystem(uint auctids, uint setnum) public onlyadmin{

	    auctionlist storage c = auctionlisting[auctids]; 

	    c.ifend = true;

	    c.ifsend = setnum;

	}

	

	//�趨��Ʒ����

	function setauctionotherfree(uint auctids) public onlyadmin{

	    auctionlist storage c = auctionlisting[auctids];

	    btyc.freezeAccount(c.adduser, false);

	    c.ifsend = 2;

	}

	//Ͷ�߷�����δ��������ﲻ��

	function tsauction(uint auctids) public{

	    require(actived == true);

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

	    require(actived == true);

	    //uint _now = now;

	    auctionlist storage c = auctionlisting[auctids];

	    address suser = msg.sender;

	    require(c.ifsend == 3);

	    require(c.ausers[suser] > 0);

	    btycaddmoney(suser,c.ausers[suser]);

	    c.ausers[suser] = 0;

	    emit getmoneys(suser, c.ausers[suser]);

	}

	/*

	 * ���ù���Ա

	 * @param {Object} address

	 */

	function admAccount(address target, bool freeze) onlyOwner public {

		admins[target] = freeze;

	}

	function btycaddmoney(address addr, uint money) private{

	    address[] memory addrs =  new address[](1);

	    uint[] memory moneys =  new uint[](1);

	    addrs[0] = addr;

	    moneys[0] = money;

	    btyc.addBalances(addrs, moneys);

	    emit Transfer(this, addr, money);

	}

	function btycsubmoney(address addr, uint money) private{

	    address[] memory addrs =  new address[](1);

	    uint[] memory moneys =  new uint[](1);

	    addrs[0] = addr;

	    moneys[0] = money;

	    btyc.subBalances(addrs, moneys);

	    emit Transfer(addr, this, money);

	}

	/*

	 * �����Ƿ���

	 * @param {Object} bool

	 */

	function setactive(bool tags) public onlyOwner {

		actived = tags;

	}

	// ���� or �ⶳ�˻�

	function freezeAccount(address target, bool freeze) public {

		require(admins[msg.sender] == true);

		frozenAccount[target] = freeze;

		emit FrozenFunds(target, freeze);

	}

	

}

//btyc�ӿ���

interface btycInterface {

    function balanceOf(address _addr) external view returns (uint256);

    function mintToken(address target, uint256 mintedAmount) external returns (bool);

    //function transfer(address to, uint tokens) external returns (bool);

    function freezeAccount(address target, bool freeze) external returns (bool);

    function getcanuse(address tokenOwner) external view returns(uint);

    function addBalances(address[] recipients, uint256[] moenys) external returns(uint);

    function subBalances(address[] recipients, uint256[] moenys) external returns(uint);

}

library SafeMath {

	function add(uint a, uint b) internal pure returns(uint c) {

		c = a + b;

		require(c >= a);

	}



	function sub(uint a, uint b) internal pure returns(uint c) {

		require(b <= a);

		c = a - b;

	}



	function mul(uint a, uint b) internal pure returns(uint c) {

		c = a * b;

		require(a == 0 || c / a == b);

	}



	function div(uint a, uint b) internal pure returns(uint c) {

		require(b > 0);

		c = a / b;

	}

}