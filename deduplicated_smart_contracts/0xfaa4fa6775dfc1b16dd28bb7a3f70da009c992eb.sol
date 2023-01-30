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
    
    //§µ§ß§Ú§Ü§Ñ§Ý§î§ß§í§Û §Ü§à§Õ §Ü§à§â§à§Ó§í
    uint cow_code;
    
    struct cows {
        uint cow;
        bool place;
        uint date_buy;
        bool cow_live;
        uint milk;
        uint date_milk;
    } 
    
    //§®§Ñ§á§á§Ú§ß§Ô §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ü§à§â§à§Ó §å §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§ñ
    mapping (address => uint) users_cows;
    //§®§Ñ§á§á§Ú§ß§Ô §Ü§à§â§à§Ó§í §å §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§ñ
    mapping (bytes32 => cows) user;
    //§®§Ñ§á§á§Ú§ß§Ô §ä§Ö§Ý§Ö§Ô§Ú
    mapping (address => bool) telega;
    //§¡§Õ§â§Ö§ã §Ü§à§ê§Ö§Ý§î§Ü§Ñ §Õ§Ó§Ú§Ø§Ü§Ñ
    address multisig;
    //§¡§Õ§â§Ö§ã §Ü§à§ê§Ö§Ý§î§Ü§Ñ rico
    address rico;
    
    
    //§ã§Ü§à§Ý§î§Ü§à §Ü§à§â§à§Ó§Ñ §Õ§Ñ§Ö§ä §Þ§à§Ý§à§Ü§Ñ §Ù§Ñ §à§Õ§ß§å §Õ§à§Û§Ü§å
    uint volume_milk;
    //§ã§Ü§à§Ý§î§Ü§à §ß§å§Ø§ß§à §Ó§â§Ö§Þ§Ö§ß§Ú §Þ§Ö§Ø§Õ§å §Õ§à§Ö§ß§Ú§ñ§Þ§Ú
    uint time_to_milk;
    //§Ó§â§Ö§Þ§Þ§ñ §Ø§Ú§Ù§ß§Ú §Ü§à§â§à§Ó§í
    uint time_to_live;   
        
    //§ã§Ü§à§Ý§î§Ü§à §ã§ä§à§Ú§ä §Þ§à§Ý§à§Ü§à §Ó §Ó§Ö§ñ§ç §Ó §â§à§Ù§ß§Ú§è§å
    uint milkcost;
    

    //§Ú§ß§Ú§è§Ú§Ú§â§å§Ö§Þ §á§Ö§â§Ö§Þ§Ö§ß§ß§í§Ö §Õ§Ó§Ú§Ø§Ü§Ñ
    function Game() public {
        
        //§å§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§Þ §Ü§à§ê§Ö§Ý§Ö§Ü §Õ§Ó§Ú§Ø§Ü§Ñ §Õ§Ý§ñ §å§á§â§Ñ§Ó§Ý§Ö§ß§Ú§ñ
    	multisig = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        //§å§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§Þ §Ü§à§ê§Ö§Ý§Ö§Ü §Õ§Ó§Ú§Ø§Ü§Ñ §Õ§Ý§ñ §å§á§â§Ñ§Ó§Ý§Ö§ß§Ú§ñ
    	rico = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    	
    	//§µ§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§Þ §ã§é§Ö§ä§é§Ú§Ü §Ü§à§â§à§Ó
    	cow_code = 0;
    	
        //§ã§Ü§à§Ý§î§Ü§à §Ý§Ú§ä§â§à§Ó §Õ§Ñ§Ö§ä §Ü§à§â§à§Ó§Ñ §ß§Ñ 5 §Þ§Ú§ß§å§ä
        volume_milk = 20;
        //§é§Ö§â§Ö§Ù §ã§Ü§à§Ý§î§Ü§à §ã§Ö§Ü§å§ß§Õ §Þ§à§Ø§ß§à §Õ§à§Ú§ä§î §Ü§à§â§à§Ó§å
        time_to_milk = 60;
        //§ã§Ü§à§Ý§î§Ü§à §ã§Ö§Ü§å§ß§Õ §Ø§Ú§Ó§Ö§ä §Ü§à§â§à§Ó§Ñ - 30 §Þ§Ú§ß
        time_to_live = 1800;  
        
        //§³§Ü§à§Ý§î§Ü§à §ã§ä§à§Ú§ä §á§â§à§Õ§Ñ§ä§î §Þ§à§Ý§à§Ü§à §Ó §â§à§Ù§ß§Ú§è§å
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
    
    //§á§à§Ü§å§á§Ñ§Ö§Þ §Ü§à§â§à§Ó §ä§à§Ý§î§Ü§à §à§ä §Õ§Ó§Ú§Ø§Ü§Ñ
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
    
    //§á§à§Ü§å§á§Ñ§Ö§Þ §á§à§Ý§Ö
    function payPlace(uint cor) private {

        uint index = msg.value/0.01 ether;
        user[keccak256(msg.sender) & keccak256(cor)].place=true;
        rico.transfer(msg.value);
    }        
    
    
    
    //§Õ§à§Ú§Þ §Ü§à§â§à§Ó§å
    function MilkCow(address gamer) private {
       
        uint time= now;
        uint time_milk;
        
        //§á§à§Ý§å§é§Ö§Ö§Þ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ü§à§â§à§Ó §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§ñ
        uint cows_count = users_cows[gamer];
        
        for (uint i=1; i<=cows_count; i++) {
            
            //§á§à§Ý§å§é§Ö§Ö§Þ §Ñ§ß§Ü§Ö§ä§å §Ü§à§â§à§Ó§í
            cows tmp = user[keccak256(gamer) & keccak256(i)];
            
            //§Ö§ã§Ý§Ú §Ü§à§â§à§Ó§Ñ §á§à§Ü§Ñ §Ø§Ú§Ó§Ñ §ä§à§Ô§Õ§Ñ §Õ§à§Ú§Þ
            if (tmp.cow_live==true && tmp.place) {
                
                //§á§à§Ý§å§é§Ñ§Ö§Þ §Ó§â§Ö§Þ§ñ §ã§Þ§Ö§â§ä§Ú §Ü§à§â§à§Ó§í
                uint datedeadcow=tmp.date_buy+time_to_live;
               
                //§Ö§ã§Ý§Ú §Ó§â§Ö§Þ§ñ §ã§Þ§Ö§â§ä§Ú §Ü§à§â§à§Ó§í §å§Ø§Ö §ß§Ñ§ã§ä§å§á§Ú§Ý§à
                if (time>=datedeadcow) {
                    
                    //§á§à§Ý§å§é§Ñ§Ö§Þ §ã§Ü§à§Ý§î§Ü§à §Õ§à§Ö§Ü §Þ§í §á§â§à§á§å§ã§ä§Ú§Ý§Ú
                    time_milk=(time-tmp.date_milk)/time_to_milk;
                    
                    if (time_milk>=1) {
                        //§Ü§Ú§Õ§Ñ§Ö§Þ §ß§Ñ §ã§Ü§Ý§Ñ§Õ §Þ§à§Ý§à§Ü§à §Ü§à§ä§à§â§à§Ö §Þ§í §ß§Ñ§Õ§à§Ú§Ý§Ú §Ù§Ñ §á§â§à§á§å§ë§Ö§ß§ß§í§Ö §Õ§à§Û§Ü§Ú
                        tmp.milk+=(volume_milk*time_milk);
                        //§å§Ò§Ú§Ó§Ñ§Ö§Þ §Ü§à§â§à§Ó§å
                        tmp.cow_live=false;
                        //§å§ã§ä§Ñ§ß§Ñ§Ó§Ý§Ú§Ó§Ñ§Ö§Þ §á§à§ã§Ý§Ö§Õ§ß§Ö§Ö §Ó§â§Ö§Þ§ñ §Õ§à§Ö§ß§Ú§ñ
                        tmp.date_milk+=time_milk*time_to_milk;
                    }
                    
                } else {
                    
                    time_milk=(time-tmp.date_milk)/time_to_milk;
                    
                    if (time_milk>=1) {
                        tmp.milk+=volume_milk*time_milk;
                        tmp.date_milk+=time_milk*time_to_milk;
                    }
                }
           
                //§à§Ò§ß§à§Ó§Ý§ñ§Ö§Þ §Ñ§ß§Ü§Ö§ä§å §Ü§à§â§à§Ó§í
                user[keccak256(gamer) & keccak256(i)] = tmp;
            }
        }
    }    
  
    //§á§â§à§Õ§Ñ§Ö§Þ §Þ§à§Ý§à§Ü§à, §Ö§ã§Ý§Ú §å§Ü§Ñ§Ù§Ñ§ß§à 0 §ä§à§Ô§Õ§Ñ §Ó§ã§Ö §Þ§à§Ý§à§Ü§à, §Ú§ß§Ñ§é§Ö §ã§Ü§à§Ý§î§Ü§à §ã§Ü§à§Ý§î§Ü§à §å§Ü§Ñ§Ù§Ñ§ß§à
    function saleMilk(uint vol, uint num_cow) public {
        
        //§ã§Ü§à§Ý§î§Ü§à §Ò§å§Õ§Ö§Þ §á§â§à§Õ§à§Ó§Ñ§ä§î §Þ§à§Ý§à§Ü§Ñ
        uint milk_to_sale;
        
        //§à§ä§Ô§â§å§Ù§Ü§Ñ §Þ§à§Ý§à§Ü§Ñ §Ó§à§Ù§Þ§à§Ø§ß§à §ä§à§Ý§î§Ü§à §á§â§Ú §ß§Ñ§Ý§Ú§é§Ú§Ú §ä§Ö§Ý§Ö§Ô§Ú §å §æ§Ö§â§Þ§Ö§â§Ñ
        if (telega[msg.sender]==true) {
            
            MilkCow(msg.sender);
            
            //§±§à§Ý§å§é§Ñ§Ö§Þ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ü§à§â§à§Ó §å §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§ñ
            uint cows_count = users_cows[msg.sender];            
        
            //§à§Ò§ß§å§Ý§ñ§Ö§Þ §Ó§ã§Ö §Þ§à§Ý§à§Ü§à §ß§Ñ §á§â§à§Õ§Ñ§Ø§å
            milk_to_sale=0;
            
            //§Ö§ã§Ý§Ú §Þ§í §á§â§à§Õ§Ñ§Ö§Þ §Þ§à§Ý§à§Ü§à §Ó§ã§Ö§ç §Ü§à§â§à§Ó
            if (num_cow==0) {
                
                for (uint i=1; i<=cows_count; i++) {
                    
                    if (user[keccak256(msg.sender) & keccak256(i)].place) {
                        
                        milk_to_sale += user[keccak256(msg.sender) & keccak256(i)].milk;
                        //§å§Õ§Ñ§Ý§ñ§Ö§Þ §Ú§Ù §Ñ§ß§Ü§Ö§ä§í §Ó§ã§Ö §Þ§à§Ý§à§Ü§à
                        user[keccak256(msg.sender) & keccak256(i)].milk = 0;
                    }
                }
            }
            //§Ö§ã§Ý§Ú §å§Ü§Ñ§Ù§Ñ§ß§Ñ §Ü§à§â§à§Ó§Ñ §Ü§à§ä§à§â§å§ð §Þ§í §Õ§à§Ý§Ø§ß§í §á§à§Õ§à§Ú§ä§î
            else {
                
                //§á§à§Ý§å§é§Ö§Ö§Þ §Ñ§ß§Ü§Ö§ä§å §Ü§à§â§à§Ó§í
                cows tmp = user[keccak256(msg.sender) & keccak256(num_cow)];
                            
                //§Ö§ã§Ý§Ú §Ò§å§Õ§Ö§Þ §á§â§à§Õ§à§Ó§Ñ§ä§î §Ó§ã§Ö §Þ§à§Ý§à§Ü§à
                if (vol==0) {
                
                    //§Ù§Ñ§á§à§Þ§Ú§ß§Ñ§Ö§Þ §ã§Ü§à§Ý§î§Ü§à §Þ§à§Ý§à§Ü§Ñ §á§â§à§Õ§Ñ§Ó§Ñ§ä§î
                    milk_to_sale = tmp.milk;
                    //§å§Õ§Ñ§Ý§ñ§Ö§Þ §Ú§Ù §Ñ§ß§Ü§Ö§ä§í §Ó§ã§Ö §Þ§à§Ý§à§Ü§à
                    tmp.milk = 0;    
                } 
                //§Ö§ã§Ý§Ú §Ò§å§Õ§Ö§Þ §á§â§à§Õ§à§Ó§Ñ§ä§î §é§Ñ§ã§ä§î §Þ§à§Ý§à§Ü§Ñ
                else {
                        
                    //§Ö§ã§Ý§Ú §Þ§à§Ý§à§Ü§Ñ §Ü§à§ä§à§â§à§Ô§à §ç§à§é§Ö§ä §á§â§à§Õ§Ñ§ä§î §æ§Ö§â§Þ§Ö§â §Þ§Ö§ß§î§ê§Ö §é§Ö§Þ §Ö§ã§ä§î
                    if (tmp.milk>vol) {
                    
                        milk_to_sale = vol;
                        tmp.milk -= milk_to_sale;
                    } 
                    
                    //§Ö§ã§Ý§Ú §Þ§à§Ý§à§Ü§Ñ §Ü§à§ä§à§â§í§Û §ç§à§é§Ö§ä §á§â§à§Õ§Ñ§ä§î §æ§Ö§â§Þ§Ö§â §ß§Ö§Õ§à§ã§ä§Ñ§ä§à§é§ß§à, §ä§à §á§â§à§Õ§Ñ§Ö§Þ §ä§à§Ý§î§Ü§à §ä§à §é§ä§à §Ö§ã§ä§î
                    else {
                        
                        milk_to_sale = tmp.milk;
                        tmp.milk = 0;
                    }                        
                } 
                
                user[keccak256(msg.sender) & keccak256(num_cow)] = tmp;
            }
            
            //§à§ä§ã§í§Ý§Ñ§Ö§Þ §ï§æ§Ú§â §Ù§Ñ §Ü§å§á§Ý§Ö§ß§ß§à§Ö §Þ§à§Ý§à§Ü§à
            msg.sender.transfer(milkcost*milk_to_sale);
        }            
    }
            
    //§á§â§à§Õ§Ñ§Ö§Þ §Ü§à§â§à§Ó§å §à§ä §æ§Ö§â§Þ§Ö§â§Ñ §æ§Ö§â§Þ§Ö§â§å, §Ú§ã§ä§à§â§Ú§ð §á§Ö§â§Ö§Õ§Ñ§é§Ú §Ó§ã§Ö§Ô§Õ§Ñ §Þ§à§Ø§ß§à §å§Ù§ß§Ñ§ä§î §Ú§Ù §é§ä§Ö§ß§Ú§ñ §Ò§Õ
    function TransferCow(address gamer, uint num_cow) public {
       
        //§á§à§Ý§å§é§Ö§Ö§Þ §Ñ§ß§Ü§Ö§ä§å §Ü§à§â§à§Ó§í
        cows cow= user[keccak256(msg.sender) & keccak256(num_cow)];
        
        //§á§â§à§Õ§Ñ§Ó§Ñ§ä§î §â§Ñ§Ù§â§Ö§ê§Ñ§Ö§ä§ã§ñ §ä§à§Ý§î§Ü§à §Ø§Ú§Ó§å§ð §Ü§à§â§à§Ó§å
        if (cow.cow_live == true && cow.place==true) {
            
            //§á§à§Ý§å§é§Ñ§Ö§Þ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ü§à§â§à§Ó §å §á§à§Ü§å§á§Ñ§ä§Ö§Ý§ñ
            uint cows_count = users_cows[gamer];
            
            //§å§Ó§Ö§Ý§Ú§é§Ú§Ó§Ñ§Ö§Þ §ã§é§Ö§ä§é§Ú§Ü §Ü§à§â§à§Ó §á§à§Ü§å§á§Ñ§ä§Ö§Ý§ñ
            cows_count++;
            
            //§ã§à§Ù§Õ§Ñ§Ö§Þ §Ú §Ù§Ñ§á§à§Ý§ß§ñ§Ö§Þ §Ñ§ß§Ü§Ö§ä§å §Ü§à§â§à§Ó§í §Õ§Ý§ñ §ß§à§Ó§à§Ô§à §æ§Ö§â§Þ§Ö§â§Ñ, §á§â§Ú §ï§ä§à§Þ §Þ§à§Ý§à§Ü§à §ß§Ö §á§Ö§â§Ö§Õ§Ñ§Ö§ä§ã§ñ
            user[keccak256(gamer) & keccak256(cows_count)]=cows(cow.cow,true,cow.date_buy,cow.cow_live,0,now);
            
            //§å§Ò§Ú§Ó§Ñ§Ö§Þ §Ü§à§â§à§Ó§å §Ú §á§â§à§ê§Ý§à§Ô§à §æ§Ö§â§Þ§Ö§â§Ñ
            cow.cow_live= false;
            //§à§Ò§ß§à§Ó§Ý§ñ§Ö§Þ §Ñ§ß§Ü§Ö§ä§å §Ü§à§â§à§Ó§í §á§â§Ö§Õ§í§Õ§å§ë§Ö§Ô§à §æ§Ö§â§Þ§Ö§â§Ñ
            user[keccak256(msg.sender) & keccak256(num_cow)] = cow;
            
            users_cows[gamer] = cows_count;
        }
    }
    
    //§å§Ò§Ú§Ó§Ñ§Ö§Þ §Ü§à§â§à§Ó§å §á§â§Ú§ß§å§Õ§Ú§ä§Ö§Ý§î§ß§à §Ú§Ù §Õ§Ó§Ú§Ø§Ü§Ñ
    function DeadCow(address gamer, uint num_cow) public onlyOwner {
       
        //§à§Ò§ß§à§Ó§Ý§ñ§Ö§Þ §Ñ§ß§Ü§Ö§ä§å §Ü§à§â§à§Ó§í
        user[keccak256(gamer) & keccak256(num_cow)].cow_live = false;
    }  
    
    //§±§à§ã§Ý§Ñ§ä§î §ä§Ö§Ý§Ö§Ô§å §æ§Ö§â§Þ§Ö§â§å
    function TelegaSend(address gamer) public onlyOwner {
       
        //§±§à§ã§Ý§Ñ§ä§î §ä§Ö§Ý§Ö§Ô§å
        telega[gamer] = true;
       
    }  
    
    //§£§Ö§â§ß§å§ä§î §Õ§Ö§ß§î§Ô§Ú
    function SendOwner() public onlyOwner {
        msg.sender.transfer(this.balance);
    }      
    
    //§±§à§ã§Ý§Ñ§ä§î §ä§Ö§Ý§Ö§Ô§å §æ§Ö§â§Þ§Ö§â§å
    function TelegaOut(address gamer) public onlyOwner {
       
        //§±§à§ã§Ý§Ñ§ä§î §ä§Ö§Ý§Ö§Ô§å
        telega[gamer] = false;
       
    }  
    
    //§£§í§Ó§Ö§ã§ä§Ú §ã§Ü§à§Ý§î§Ü§à §Ü§à§â§à§Ó §å §æ§Ö§â§Þ§Ö§â§Ñ
    function CountCow(address gamer) public view returns (uint) {
        return users_cows[gamer];   
    }

    //§£§í§Ó§Ö§ã§ä§Ú §ã§Ü§à§Ý§î§Ü§à §Ü§à§â§à§Ó §å §æ§Ö§â§Þ§Ö§â§Ñ
    function StatusCow(address gamer, uint num_cow) public view returns (uint,bool,uint,bool,uint,uint) {
        return (user[keccak256(gamer) & keccak256(num_cow)].cow,
        user[keccak256(gamer) & keccak256(num_cow)].place,
        user[keccak256(gamer) & keccak256(num_cow)].date_buy,
        user[keccak256(gamer) & keccak256(num_cow)].cow_live,
        user[keccak256(gamer) & keccak256(num_cow)].milk,
        user[keccak256(gamer) & keccak256(num_cow)].date_milk);   
    }
    
    //§£§í§Ó§Ö§ã§ä§Ú §ß§Ñ§Ý§Ú§é§Ú§Ö §ä§Ö§Ý§Ö§Ô§Ú §å §æ§Ö§â§Þ§Ö§â§Ñ
    function Statustelega(address gamer) public view returns (bool) {
        return telega[gamer];   
    }    
    
}