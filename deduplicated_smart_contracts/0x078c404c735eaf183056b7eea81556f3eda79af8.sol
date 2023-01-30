/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-09
 * BEB dapp for www.betbeb.com www.bitbeb.com
*/
pragma solidity^0.4.20;  
//ʵ��������
interface tokenTransfer {
    function transfer(address receiver, uint amount);
    function transferFrom(address _from, address _to, uint256 _value);
    function balanceOf(address receiver) returns(uint256);
}

contract Ownable {
  address public owner;
  bool lock = false;
 
 
    /**
     * ��̨�����캯��
     */
    function Ownable () public {
        owner = msg.sender;
    }
 
    /**
     * �жϵ�ǰ��Լ�������Ƿ��Ǻ�Լ��������
     */
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
 
    /**
     * ��Լ��������ָ��һ���µĹ���Ա
     * @param  newOwner address �µĹ���Ա�ʻ���ַ
     */
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}

contract BebPos is Ownable{

    //��Ա���ݽṹ
   struct BebUser {
        address customerAddr;//��Աaddress
        uint256 amount; //����� 
        uint256 bebtime;//���ʱ��
        //uint256 interest;//��Ϣ
    }
    uint256 Bebamount;//BEBδ��������
    uint256 bebTotalAmount;//BEB����
    uint256 sumAmount = 0;//��Ա������ 
    uint256 OneMinuteBEB;//��ʼ��1���Ӳ���BEB����
    tokenTransfer public bebTokenTransfer; //���� 
    uint8 decimals = 18;
    uint256 OneMinute=1 minutes; //1����
    //��Ա �ṹ 
    mapping(address=>BebUser)public BebUsers;
    address[] BebUserArray;//���ĵ�ַ����
    //�¼�
    event messageBetsGame(address sender,bool isScuccess,string message);
    //BEB�ĺ�Լ��ַ 
    function BebPos(address _tokenAddress,uint256 _Bebamount,uint256 _bebTotalAmount,uint256 _OneMinuteBEB){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
         Bebamount=_Bebamount*10**18;//��ʼ�趨Ϊ��������
         bebTotalAmount=_bebTotalAmount*10**18;//��ʼ�趨BEB����
         OneMinuteBEB=_OneMinuteBEB*10**18;//��ʼ��1���Ӳ���BEB���� 
         BebUserArray.push(_tokenAddress);
     }
         //���� BEB
    function BebDeposit(address _addr,uint256 _value) public{
        //�жϻ�Ա������Ƿ����0
       if(BebUsers[msg.sender].amount == 0){
           //�ж�δ���������Ƿ����20��BEB
           if(Bebamount > OneMinuteBEB){
           bebTokenTransfer.transferFrom(_addr,address(address(this)),_value);//����BEB
           BebUsers[_addr].customerAddr=_addr;
           BebUsers[_addr].amount=_value;
           BebUsers[_addr].bebtime=now;
           sumAmount+=_value;//�ܴ������
           //�����������ַ
           //addToAddress(msg.sender);//�����������ַ
           messageBetsGame(msg.sender, true,"ת��ɹ�");
            return;   
           }
           else{
            messageBetsGame(msg.sender, true,"ת��ʧ��,BEB�����Ѿ�ȫ���������");
            return;   
           }
       }else{
            messageBetsGame(msg.sender, true,"ת��ʧ��,����ȡ����Լ�е����");
            return;
       }
    }

    //ȡ��
    function redemption() public {
        address _address = msg.sender;
        BebUser storage user = BebUsers[_address];
        require(user.amount > 0);
        //
        uint256 _time=user.bebtime;//���ʱ��
        uint256 _amuont=user.amount;//���˴����
           uint256 AA=(now-_time)/OneMinute*OneMinuteBEB;//����ʱ��-���ʱ��/60��*ÿ��������20BEB
           uint256 BB=bebTotalAmount-Bebamount;//���������ͨ����
           uint256 CC=_amuont*AA/BB;//���*AA/����ͨ����
           //�ж�δ���������Ƿ����20BEB
           if(Bebamount > OneMinuteBEB){
              Bebamount-=CC; 
             //user.interest+=CC;//���˻�������Ϣ
             user.bebtime=now;//���ô��ʱ��Ϊ����
           }
        //�ж�δ���������Ƿ����20��BEB
        if(Bebamount > OneMinuteBEB){
            Bebamount-=CC;//�ӷ����������м���
            sumAmount-=_amuont;
            bebTokenTransfer.transfer(msg.sender,CC+user.amount);//ת�˸���Ա + ��Ա����+��ǰ��Ϣ 
           //�������� 
            BebUsers[_address].amount=0;//��Ա���0
            BebUsers[_address].bebtime=0;//��Ա���ʱ��0
            //BebUsers[_address].interest=0;//��Ϣ��0
            messageBetsGame(_address, true,"�������Ϣ�ɹ�ȡ��");
            return;
        }
        else{
            Bebamount-=CC;//�ӷ����������м���
            sumAmount-=_amuont;
            bebTokenTransfer.transfer(msg.sender,_amuont);//ת�˸���Ա + ��Ա���� 
           //�������� 
            BebUsers[_address].amount=0;//��Ա���0
            BebUsers[_address].bebtime=0;//��Ա���ʱ��0
            //BebUsers[_address].interest=0;//��Ϣ��0
            messageBetsGame(_address, true,"BEB�����Ѿ�������ϣ�ȡ�ر���");
            return;  
        }
    }
    function getTokenBalance() public view returns(uint256){
         return bebTokenTransfer.balanceOf(address(this));
    }
    function getSumAmount() public view returns(uint256){
        return sumAmount;
    }
    function getBebAmount() public view returns(uint256){
        return Bebamount;
    }
    function getBebAmountzl() public view returns(uint256){
        uint256 _sumAmount=bebTotalAmount-Bebamount;
        return _sumAmount;
    }

    function getLength() public view returns(uint256){
        return (BebUserArray.length);
    }
     function getUserProfit(address _form) public view returns(address,uint256,uint256,uint256){
       address _address = _form;
       BebUser storage user = BebUsers[_address];
       assert(user.amount > 0);
       uint256 A=(now-user.bebtime)/OneMinute*OneMinuteBEB;
       uint256 B=bebTotalAmount-Bebamount;
       uint256 C=user.amount*A/B;
        return (_address,user.bebtime,user.amount,C);
    }
    function()payable{
        
    }
}