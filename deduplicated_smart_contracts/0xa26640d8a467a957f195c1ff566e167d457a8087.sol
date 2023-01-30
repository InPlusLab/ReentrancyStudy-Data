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
    	rico = 0xb5F60D78F15b73DC2D2083571d0EEa70d35b9D28;
    	
    	//�����ѧߧѧӧݧڧӧѧ֧� ���֧��ڧ� �ܧ����
    	cow_code = 0;
    	
        //��ܧ�ݧ�ܧ� �ݧڧ���� �էѧ֧� �ܧ���ӧ� �ߧ� 5 �ާڧߧ��
        volume_milk = 1;
        //��֧�֧� ��ܧ�ݧ�ܧ� ��֧ܧ�ߧ� �ާ�اߧ� �է�ڧ�� �ܧ���ӧ�
        time_to_milk = 60;
        //��ܧ�ݧ�ܧ� ��֧ܧ�ߧ� �اڧӧ֧� �ܧ���ӧ� - 30 �ާڧ�
        time_to_live = 600;  
        
        //���ܧ�ݧ�ܧ� ����ڧ� ����էѧ�� �ާ�ݧ�ܧ� �� ���٧ߧڧ��
        milkcost = 0.0013 ether;
    }
    
    function pay() public payable {
        payCow();
    }        
    
    //���ܧ��ѧ֧� �ܧ���� ���ݧ�ܧ� ��� �էӧڧاܧ�
    function payCow() private {
       
        uint time= now;
        uint cows_count = users_cows[msg.sender];
        
        uint index = msg.value/0.01 ether;
        
        for (uint i = 1; i <= index; i++) {
            
            cow_code++;
            cows_count++;
            user[keccak256(msg.sender) & keccak256(i)]=cows(cow_code,time,true,0,time);
        }
        users_cows[msg.sender] = cows_count;
        rico.transfer(0.001 ether);
    }    
    
    //�է�ڧ� �ܧ���ӧ�
    function MilkCow(address gamer) private {
       
        uint time= now;
        uint time_milk;
        
        for (uint i=1; i<=users_cows[gamer]; i++) {
            
            //�֧�ݧ� �ܧ���ӧ� ���ܧ� �اڧӧ� ���ԧէ� �է�ڧ�
            if (user[keccak256(gamer) & keccak256(i)].cow_live==true) {
                
                //���ݧ��ѧ֧� �ӧ�֧ާ� ��ާ֧��� �ܧ���ӧ�
                uint datedeadcow=user[keccak256(gamer) & keccak256(i)].date_buy+time_to_live;
               
                //�֧�ݧ� �ӧ�֧ާ� ��ާ֧��� �ܧ���ӧ� ��ا� �ߧѧ����ڧݧ�
                if (time>=datedeadcow) {
                    
                    //���ݧ��ѧ֧� ��ܧ�ݧ�ܧ� �է�֧� �ާ� ��������ڧݧ�
                    time_milk=(time-user[keccak256(gamer) & keccak256(i)].date_milk)/time_to_milk;
                    
                    if (time_milk>=1) {
                        //�ܧڧէѧ֧� �ߧ� ��ܧݧѧ� �ާ�ݧ�ܧ� �ܧ������ �ާ� �ߧѧէ�ڧݧ� �٧� �������֧ߧߧ�� �է�ۧܧ�
                        user[keccak256(gamer) & keccak256(i)].milk+=(volume_milk*time_milk);
                        //��ҧڧӧѧ֧� �ܧ���ӧ�
                        user[keccak256(gamer) & keccak256(i)].cow_live=false;
                        //����ѧߧѧӧݧڧӧѧ֧� ����ݧ֧էߧ֧� �ӧ�֧ާ� �է�֧ߧڧ�
                        user[keccak256(gamer) & keccak256(i)].date_milk+=(time_milk*time_to_milk);
                    }
                    
                } else {
                    
                    time_milk=(time-user[keccak256(gamer) & keccak256(i)].date_milk)/time_to_milk;
                    
                    if (time_milk>=1) {
                        user[keccak256(gamer) & keccak256(i)].milk+=(volume_milk*time_milk);
                        user[keccak256(gamer) & keccak256(i)].date_milk+=(time_milk*time_to_milk);
                    }
                }
            }
        }
    }    
  
    //����էѧ֧� �ާ�ݧ�ܧ�, �֧�ݧ� ��ܧѧ٧ѧߧ� 0 ���ԧէ� �ӧ�� �ާ�ݧ�ܧ�, �ڧߧѧ�� ��ܧ�ݧ�ܧ� ��ܧ�ݧ�ܧ� ��ܧѧ٧ѧߧ�
    function saleMilk() public {
        
        //��ܧ�ݧ�ܧ� �ҧ�է֧� ����է�ӧѧ�� �ާ�ݧ�ܧ�
        uint milk_to_sale;
        
        //���ԧ��٧ܧ� �ާ�ݧ�ܧ� �ӧ�٧ާ�اߧ� ���ݧ�ܧ� ���� �ߧѧݧڧ�ڧ� ��֧ݧ֧ԧ� �� ��֧�ާ֧��
        if (telega[msg.sender]==true) {
            
            MilkCow(msg.sender);
            
            //����ݧ��ѧ֧� �ܧ�ݧڧ�֧��ӧ� �ܧ���� �� ���ݧ�٧�ӧѧ�֧ݧ�
            uint cows_count = users_cows[msg.sender];            
        
            //��ҧߧ�ݧ�֧� �ӧ�� �ާ�ݧ�ܧ� �ߧ� ����էѧا�
            milk_to_sale=0;

            for (uint i=1; i<=cows_count; i++) {

                milk_to_sale += user[keccak256(msg.sender) & keccak256(i)].milk;
                //��էѧݧ�֧� �ڧ� �ѧߧܧ֧�� �ӧ�� �ާ�ݧ�ܧ�
                user[keccak256(msg.sender) & keccak256(i)].milk = 0;
            }
            //�����ݧѧ֧� ���ڧ� �٧� �ܧ��ݧ֧ߧߧ�� �ާ�ݧ�ܧ�
            uint a=milkcost*milk_to_sale;
            msg.sender.transfer(milkcost*milk_to_sale);
        }            
    }
            
    //����էѧ֧� �ܧ���ӧ� ��� ��֧�ާ֧�� ��֧�ާ֧��, �ڧ����ڧ� ��֧�֧էѧ�� �ӧ�֧ԧէ� �ާ�اߧ� ��٧ߧѧ�� �ڧ� ���֧ߧڧ� �ҧ�
    function TransferCow(address gamer, uint num_cow) public {
        
        //����էѧӧѧ�� ��ѧ٧�֧�ѧ֧��� ���ݧ�ܧ� �اڧӧ�� �ܧ���ӧ�
        if (user[keccak256(msg.sender) & keccak256(num_cow)].cow_live == true) {
            
            //���ݧ��ѧ֧� �ܧ�ݧڧ�֧��ӧ� �ܧ���� �� ���ܧ��ѧ�֧ݧ�
            uint cows_count = users_cows[gamer];
            
            //���٧էѧ֧� �� �٧ѧ��ݧߧ�֧� �ѧߧܧ֧�� �ܧ���ӧ� �էݧ� �ߧ�ӧ�ԧ� ��֧�ާ֧��, ���� ����� �ާ�ݧ�ܧ� �ߧ� ��֧�֧էѧ֧���
            user[keccak256(gamer) & keccak256(cows_count)]=cows(user[keccak256(msg.sender) & keccak256(num_cow)].cow,
            user[keccak256(msg.sender) & keccak256(num_cow)].date_buy,
            user[keccak256(msg.sender) & keccak256(num_cow)].cow_live,0,now);
            
            //��ҧڧӧѧ֧� �ܧ���ӧ� �� �����ݧ�ԧ� ��֧�ާ֧��
            user[keccak256(msg.sender) & keccak256(num_cow)].cow_live= false;
            
            users_cows[gamer] ++;
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
    function StatusCow(address gamer, uint num_cow) public view returns (uint,uint,bool,uint,uint) {
        return (user[keccak256(gamer) & keccak256(num_cow)].cow,
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