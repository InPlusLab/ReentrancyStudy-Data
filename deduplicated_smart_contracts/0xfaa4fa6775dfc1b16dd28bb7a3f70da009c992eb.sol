pragma solidity ^0.4.18;

contract ownerOnly {
    
    function ownerOnly() public { owner = msg.sender; }
    address owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


contract Game is ownerOnly {
    
    //���ߧڧܧѧݧ�ߧ�� �ܧ�� �ܧ���ӧ�
    uint cow_code;
    
    struct cows {
        uint cow;
        bool place;
        uint date_buy;
        bool cow_live;
        uint milk;
        uint date_milk;
    } 
    
    //���ѧ��ڧߧ� �ܧ�ݧڧ�֧��ӧ� �ܧ���� �� ���ݧ�٧�ӧѧ�֧ݧ�
    mapping (address => uint) users_cows;
    //���ѧ��ڧߧ� �ܧ���ӧ� �� ���ݧ�٧�ӧѧ�֧ݧ�
    mapping (bytes32 => cows) user;
    //���ѧ��ڧߧ� ��֧ݧ֧ԧ�
    mapping (address => bool) telega;
    //���է�֧� �ܧ��֧ݧ�ܧ� �էӧڧاܧ�
    address multisig;
    //���է�֧� �ܧ��֧ݧ�ܧ� rico
    address rico;
    
    
    //��ܧ�ݧ�ܧ� �ܧ���ӧ� �էѧ֧� �ާ�ݧ�ܧ� �٧� ��էߧ� �է�ۧܧ�
    uint volume_milk;
    //��ܧ�ݧ�ܧ� �ߧ�اߧ� �ӧ�֧ާ֧ߧ� �ާ֧اէ� �է�֧ߧڧ�ާ�
    uint time_to_milk;
    //�ӧ�֧ާާ� �اڧ٧ߧ� �ܧ���ӧ�
    uint time_to_live;   
        
    //��ܧ�ݧ�ܧ� ����ڧ� �ާ�ݧ�ܧ� �� �ӧ֧�� �� ���٧ߧڧ��
    uint milkcost;
    

    //�ڧߧڧ�ڧڧ��֧� ��֧�֧ާ֧ߧߧ�� �էӧڧاܧ�
    function Game() public {
        
        //����ѧߧѧӧݧڧӧѧ֧� �ܧ��֧ݧ֧� �էӧڧاܧ� �էݧ� ����ѧӧݧ֧ߧڧ�
    	multisig = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        //����ѧߧѧӧݧڧӧѧ֧� �ܧ��֧ݧ֧� �էӧڧاܧ� �էݧ� ����ѧӧݧ֧ߧڧ�
    	rico = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    	
    	//�����ѧߧѧӧݧڧӧѧ֧� ���֧��ڧ� �ܧ����
    	cow_code = 0;
    	
        //��ܧ�ݧ�ܧ� �ݧڧ���� �էѧ֧� �ܧ���ӧ� �ߧ� 5 �ާڧߧ��
        volume_milk = 20;
        //��֧�֧� ��ܧ�ݧ�ܧ� ��֧ܧ�ߧ� �ާ�اߧ� �է�ڧ�� �ܧ���ӧ�
        time_to_milk = 60;
        //��ܧ�ݧ�ܧ� ��֧ܧ�ߧ� �اڧӧ֧� �ܧ���ӧ� - 30 �ާڧ�
        time_to_live = 1800;  
        
        //���ܧ�ݧ�ܧ� ����ڧ� ����էѧ�� �ާ�ݧ�ܧ� �� ���٧ߧڧ��
        milkcost = 0.001083333333333 ether;
    }
    
    function pay(uint cor) public payable {
       
        if (cor==0) {
            payCow();    
        }
        else {
            payPlace(cor);
        }
    }        
    
    //���ܧ��ѧ֧� �ܧ���� ���ݧ�ܧ� ��� �էӧڧاܧ�
    function payCow() private {
       
        uint time= now;
        uint cows_count = users_cows[msg.sender];
        
        uint index = msg.value/0.09 ether;
        
        for (uint i = 1; i <= index; i++) {
            
            cow_code++;
            cows_count++;
            user[keccak256(msg.sender) & keccak256(i)]=cows(cow_code,false,time,true,0,time);
        }
        users_cows[msg.sender] = cows_count;
    }    
    
    //���ܧ��ѧ֧� ���ݧ�
    function payPlace(uint cor) private {

        uint index = msg.value/0.01 ether;
        user[keccak256(msg.sender) & keccak256(cor)].place=true;
        rico.transfer(msg.value);
    }        
    
    
    
    //�է�ڧ� �ܧ���ӧ�
    function MilkCow(address gamer) private {
       
        uint time= now;
        uint time_milk;
        
        //���ݧ��֧֧� �ܧ�ݧڧ�֧��ӧ� �ܧ���� ���ݧ�٧�ӧѧ�֧ݧ�
        uint cows_count = users_cows[gamer];
        
        for (uint i=1; i<=cows_count; i++) {
            
            //���ݧ��֧֧� �ѧߧܧ֧�� �ܧ���ӧ�
            cows tmp = user[keccak256(gamer) & keccak256(i)];
            
            //�֧�ݧ� �ܧ���ӧ� ���ܧ� �اڧӧ� ���ԧէ� �է�ڧ�
            if (tmp.cow_live==true && tmp.place) {
                
                //���ݧ��ѧ֧� �ӧ�֧ާ� ��ާ֧��� �ܧ���ӧ�
                uint datedeadcow=tmp.date_buy+time_to_live;
               
                //�֧�ݧ� �ӧ�֧ާ� ��ާ֧��� �ܧ���ӧ� ��ا� �ߧѧ����ڧݧ�
                if (time>=datedeadcow) {
                    
                    //���ݧ��ѧ֧� ��ܧ�ݧ�ܧ� �է�֧� �ާ� ��������ڧݧ�
                    time_milk=(time-tmp.date_milk)/time_to_milk;
                    
                    if (time_milk>=1) {
                        //�ܧڧէѧ֧� �ߧ� ��ܧݧѧ� �ާ�ݧ�ܧ� �ܧ������ �ާ� �ߧѧէ�ڧݧ� �٧� �������֧ߧߧ�� �է�ۧܧ�
                        tmp.milk+=(volume_milk*time_milk);
                        //��ҧڧӧѧ֧� �ܧ���ӧ�
                        tmp.cow_live=false;
                        //����ѧߧѧӧݧڧӧѧ֧� ����ݧ֧էߧ֧� �ӧ�֧ާ� �է�֧ߧڧ�
                        tmp.date_milk+=time_milk*time_to_milk;
                    }
                    
                } else {
                    
                    time_milk=(time-tmp.date_milk)/time_to_milk;
                    
                    if (time_milk>=1) {
                        tmp.milk+=volume_milk*time_milk;
                        tmp.date_milk+=time_milk*time_to_milk;
                    }
                }
           
                //��ҧߧ�ӧݧ�֧� �ѧߧܧ֧�� �ܧ���ӧ�
                user[keccak256(gamer) & keccak256(i)] = tmp;
            }
        }
    }    
  
    //����էѧ֧� �ާ�ݧ�ܧ�, �֧�ݧ� ��ܧѧ٧ѧߧ� 0 ���ԧէ� �ӧ�� �ާ�ݧ�ܧ�, �ڧߧѧ�� ��ܧ�ݧ�ܧ� ��ܧ�ݧ�ܧ� ��ܧѧ٧ѧߧ�
    function saleMilk(uint vol, uint num_cow) public {
        
        //��ܧ�ݧ�ܧ� �ҧ�է֧� ����է�ӧѧ�� �ާ�ݧ�ܧ�
        uint milk_to_sale;
        
        //���ԧ��٧ܧ� �ާ�ݧ�ܧ� �ӧ�٧ާ�اߧ� ���ݧ�ܧ� ���� �ߧѧݧڧ�ڧ� ��֧ݧ֧ԧ� �� ��֧�ާ֧��
        if (telega[msg.sender]==true) {
            
            MilkCow(msg.sender);
            
            //����ݧ��ѧ֧� �ܧ�ݧڧ�֧��ӧ� �ܧ���� �� ���ݧ�٧�ӧѧ�֧ݧ�
            uint cows_count = users_cows[msg.sender];            
        
            //��ҧߧ�ݧ�֧� �ӧ�� �ާ�ݧ�ܧ� �ߧ� ����էѧا�
            milk_to_sale=0;
            
            //�֧�ݧ� �ާ� ����էѧ֧� �ާ�ݧ�ܧ� �ӧ�֧� �ܧ����
            if (num_cow==0) {
                
                for (uint i=1; i<=cows_count; i++) {
                    
                    if (user[keccak256(msg.sender) & keccak256(i)].place) {
                        
                        milk_to_sale += user[keccak256(msg.sender) & keccak256(i)].milk;
                        //��էѧݧ�֧� �ڧ� �ѧߧܧ֧�� �ӧ�� �ާ�ݧ�ܧ�
                        user[keccak256(msg.sender) & keccak256(i)].milk = 0;
                    }
                }
            }
            //�֧�ݧ� ��ܧѧ٧ѧߧ� �ܧ���ӧ� �ܧ������ �ާ� �է�ݧاߧ� ���է�ڧ��
            else {
                
                //���ݧ��֧֧� �ѧߧܧ֧�� �ܧ���ӧ�
                cows tmp = user[keccak256(msg.sender) & keccak256(num_cow)];
                            
                //�֧�ݧ� �ҧ�է֧� ����է�ӧѧ�� �ӧ�� �ާ�ݧ�ܧ�
                if (vol==0) {
                
                    //�٧ѧ��ާڧߧѧ֧� ��ܧ�ݧ�ܧ� �ާ�ݧ�ܧ� ����էѧӧѧ��
                    milk_to_sale = tmp.milk;
                    //��էѧݧ�֧� �ڧ� �ѧߧܧ֧�� �ӧ�� �ާ�ݧ�ܧ�
                    tmp.milk = 0;    
                } 
                //�֧�ݧ� �ҧ�է֧� ����է�ӧѧ�� ��ѧ��� �ާ�ݧ�ܧ�
                else {
                        
                    //�֧�ݧ� �ާ�ݧ�ܧ� �ܧ�����ԧ� ����֧� ����էѧ�� ��֧�ާ֧� �ާ֧ߧ��� ��֧� �֧���
                    if (tmp.milk>vol) {
                    
                        milk_to_sale = vol;
                        tmp.milk -= milk_to_sale;
                    } 
                    
                    //�֧�ݧ� �ާ�ݧ�ܧ� �ܧ������ ����֧� ����էѧ�� ��֧�ާ֧� �ߧ֧է���ѧ���ߧ�, ��� ����էѧ֧� ���ݧ�ܧ� ��� ���� �֧���
                    else {
                        
                        milk_to_sale = tmp.milk;
                        tmp.milk = 0;
                    }                        
                } 
                
                user[keccak256(msg.sender) & keccak256(num_cow)] = tmp;
            }
            
            //�����ݧѧ֧� ���ڧ� �٧� �ܧ��ݧ֧ߧߧ�� �ާ�ݧ�ܧ�
            msg.sender.transfer(milkcost*milk_to_sale);
        }            
    }
            
    //����էѧ֧� �ܧ���ӧ� ��� ��֧�ާ֧�� ��֧�ާ֧��, �ڧ����ڧ� ��֧�֧էѧ�� �ӧ�֧ԧէ� �ާ�اߧ� ��٧ߧѧ�� �ڧ� ���֧ߧڧ� �ҧ�
    function TransferCow(address gamer, uint num_cow) public {
       
        //���ݧ��֧֧� �ѧߧܧ֧�� �ܧ���ӧ�
        cows cow= user[keccak256(msg.sender) & keccak256(num_cow)];
        
        //����էѧӧѧ�� ��ѧ٧�֧�ѧ֧��� ���ݧ�ܧ� �اڧӧ�� �ܧ���ӧ�
        if (cow.cow_live == true && cow.place==true) {
            
            //���ݧ��ѧ֧� �ܧ�ݧڧ�֧��ӧ� �ܧ���� �� ���ܧ��ѧ�֧ݧ�
            uint cows_count = users_cows[gamer];
            
            //��ӧ֧ݧڧ�ڧӧѧ֧� ���֧��ڧ� �ܧ���� ���ܧ��ѧ�֧ݧ�
            cows_count++;
            
            //���٧էѧ֧� �� �٧ѧ��ݧߧ�֧� �ѧߧܧ֧�� �ܧ���ӧ� �էݧ� �ߧ�ӧ�ԧ� ��֧�ާ֧��, ���� ����� �ާ�ݧ�ܧ� �ߧ� ��֧�֧էѧ֧���
            user[keccak256(gamer) & keccak256(cows_count)]=cows(cow.cow,true,cow.date_buy,cow.cow_live,0,now);
            
            //��ҧڧӧѧ֧� �ܧ���ӧ� �� �����ݧ�ԧ� ��֧�ާ֧��
            cow.cow_live= false;
            //��ҧߧ�ӧݧ�֧� �ѧߧܧ֧�� �ܧ���ӧ� ���֧է�է��֧ԧ� ��֧�ާ֧��
            user[keccak256(msg.sender) & keccak256(num_cow)] = cow;
            
            users_cows[gamer] = cows_count;
        }
    }
    
    //��ҧڧӧѧ֧� �ܧ���ӧ� ���ڧߧ�էڧ�֧ݧ�ߧ� �ڧ� �էӧڧاܧ�
    function DeadCow(address gamer, uint num_cow) public onlyOwner {
       
        //��ҧߧ�ӧݧ�֧� �ѧߧܧ֧�� �ܧ���ӧ�
        user[keccak256(gamer) & keccak256(num_cow)].cow_live = false;
    }  
    
    //�����ݧѧ�� ��֧ݧ֧ԧ� ��֧�ާ֧��
    function TelegaSend(address gamer) public onlyOwner {
       
        //�����ݧѧ�� ��֧ݧ֧ԧ�
        telega[gamer] = true;
       
    }  
    
    //���֧�ߧ��� �է֧ߧ�ԧ�
    function SendOwner() public onlyOwner {
        msg.sender.transfer(this.balance);
    }      
    
    //�����ݧѧ�� ��֧ݧ֧ԧ� ��֧�ާ֧��
    function TelegaOut(address gamer) public onlyOwner {
       
        //�����ݧѧ�� ��֧ݧ֧ԧ�
        telega[gamer] = false;
       
    }  
    
    //����ӧ֧��� ��ܧ�ݧ�ܧ� �ܧ���� �� ��֧�ާ֧��
    function CountCow(address gamer) public view returns (uint) {
        return users_cows[gamer];   
    }

    //����ӧ֧��� ��ܧ�ݧ�ܧ� �ܧ���� �� ��֧�ާ֧��
    function StatusCow(address gamer, uint num_cow) public view returns (uint,bool,uint,bool,uint,uint) {
        return (user[keccak256(gamer) & keccak256(num_cow)].cow,
        user[keccak256(gamer) & keccak256(num_cow)].place,
        user[keccak256(gamer) & keccak256(num_cow)].date_buy,
        user[keccak256(gamer) & keccak256(num_cow)].cow_live,
        user[keccak256(gamer) & keccak256(num_cow)].milk,
        user[keccak256(gamer) & keccak256(num_cow)].date_milk);   
    }
    
    //����ӧ֧��� �ߧѧݧڧ�ڧ� ��֧ݧ֧ԧ� �� ��֧�ާ֧��
    function Statustelega(address gamer) public view returns (bool) {
        return telega[gamer];   
    }    
    
}