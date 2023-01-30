/**
 *Submitted for verification at Etherscan.io on 2020-07-07
*/

pragma solidity >=0.4.22 <0.6.0;
contract Anow_TokenERC20 {
    string public name = 'Anow';
    string public symbol = 'Anow';
    uint8 public decimals = 18;
    uint256 public totalSupply=3000000 ether;
    mapping (address => uint256) public balanceOf; 
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    function _transfer(address _from, address _to, uint _value) internal {
        require(sys_info.start_time > 0);
        require(_to !=address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to]; 
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value); 
        require(balanceOf[_from] + balanceOf[_to] == previousBalances);  
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value); 
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]); 
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value; 
        return true;
    }
    function safe_add(uint256 a,uint256 b)private pure returns(uint256)
    {
        uint256 c = a + b;
        require(c >= a && c >= b);
        return c;
        
    }
    function safe_sub(uint256 a,uint256 b)private pure returns(uint256)
    {
        require(b <= a);
        return a - b;
        
    }
    function safe_mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function safe_div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b; 
        require(a == b * c + a % b);
        return c;
    }
    struct SYSTEM_INFO{
        uint32 start_time;
        uint32 count;
        uint256 total_power;
        uint256 total_lock;
        mapping(uint32 =>uint256) day_power;
    }
    struct USER_INFO{
        uint32 index;
        uint32 flags;
        uint32 father_index;
        uint256 lock_Anow;
        uint32 lock_time;
        uint256 power;
        uint256 fa_power;
        uint256 last_Income;
        uint256 total_Income;
        uint32 team_pople;
        uint32 lower_level_pople;
        uint256 team_mining;
        uint256 lower_level_mining;
    }
    SYSTEM_INFO public sys_info;
    address admin;
    address owner1;
    address owner2;
    address owner3;
    uint32 private team_time;
    uint256 private team_number=3000000 ether;
    mapping(address =>bool) public votes;
    mapping(address => USER_INFO) public user_info;
    mapping(uint32 => address) public user_addr;    
    constructor () public {
        admin == msg.sender;
        owner1=address(0x166451fFd5F53d2691e0734bEF2f3503747380B9);
        owner2=address(0xBfd86108B9ee107912BDa9689D15A39A8b6F0E0b);
        owner3=address(0x45104F63D25198358E2c0efbAE57a96E2A44771F);
        balanceOf[msg.sender]=10000 ether;
        balanceOf[owner1] = 10000 ether;
        balanceOf[owner2]=2970000 ether;
        balanceOf[owner3]=10000 ether;
        sys_info.count=1;
        user_info[msg.sender].index = sys_info.count;
        uint32 n=uint32(msg.sender);
        uint32 n1=n % 26+65;
        uint32 n2=(n>>10) %26+65;
        uint32 n3 =(n >> 20) % 26 +65;
        user_info[msg.sender].flags =(n1<<16) +(n2<<8) +n3;
        user_info[msg.sender].lock_time=uint32(now/86400);
        user_addr[sys_info.count]=msg.sender; 
        create_user(owner1,1,user_info[msg.sender].flags);
        create_user(owner2,1,user_info[msg.sender].flags);
        create_user(owner3,1,user_info[msg.sender].flags);
    }

    function get_father_flags(address ad)public view returns(uint32 father_flags)
    {
        USER_INFO storage fa_u=user_info[user_addr[user_info[ad].father_index]];
        return fa_u.flags;
    }
    function get_5day_power(uint32 first_day)public view returns(
        uint256 power1,uint256 power2,uint256 power3,uint256 power4,uint256 power5)
    {
        return(sys_info.day_power[first_day],
               sys_info.day_power[first_day+1],
               sys_info.day_power[first_day+2],
               sys_info.day_power[first_day+3],
               sys_info.day_power[first_day+4]
            );
    }
    //记录当天算力
    function set_power()public
    {
        uint32 cur_day=uint32(now/86400);
        sys_info.day_power[cur_day]=sys_info.total_power;
    }
    
    //------------------------------------------------------------------
    function create_user(address my_ad,uint32 fa_index,uint32 fa_flags)internal returns(uint32 index,uint32 father)
    {
        if(user_info[my_ad].index>0){
            return(user_info[my_ad].index,user_info[my_ad].father_index);
        }
        require(fa_index !=0 && fa_flags !=0);
        address ad=user_addr[fa_index];
        require(ad!=address(0x0));
        require(user_info[ad].flags == fa_flags);
        sys_info.count++;
        user_info[my_ad].index = sys_info.count;
        uint32 n=uint32(my_ad);
        uint32 n1=n % 26+65;
        uint32 n2=(n>>10) %26+65;
        uint32 n3 =(n >> 20) % 26 +65;
        user_info[my_ad].flags =(n1<<16) +(n2<<8) +n3;
        user_info[my_ad].father_index = fa_index;
        user_addr[sys_info.count]=my_ad;
        USER_INFO storage fu=user_info[user_addr[fa_index]];
        fu.lower_level_pople+=1;
        for(uint32 i=0;i<4;i++)
        {
            if(fu.father_index == 0)break;
            fu=user_info[user_addr[fu.father_index]];
            fu.team_pople+=1;
        }
        return(user_info[my_ad].index,user_info[my_ad].father_index);
    }
    function deposits(uint32 father_index,uint32 father_flags, uint256 balance)public
    {
        require(balance <= balanceOf[msg.sender]);
        USER_INFO storage user=user_info[msg.sender];
        require(user.lock_Anow == 0);
        require(balance >100);
        uint32 my_index;
        uint32 fa_index;
        (my_index,fa_index)=create_user(msg.sender,father_index,father_flags);
        require(my_index > 0 && (fa_index >0 || my_index ==1));
        balanceOf[msg.sender]-=balance;
        totalSupply=safe_sub(totalSupply,balance);
        user.lock_Anow=balance;
        user.power=safe_add(user.power,balance);
        sys_info.total_lock=safe_add(sys_info.total_lock,balance);
        uint256 total_power=balance;
        user.lock_time=uint32(now/86400);
        uint256 pow;
        USER_INFO storage fu=user;
        for(uint32 i=0;i<5;i++)
        {
            if(fu.father_index==0)break;
            fu=user_info[user_addr[fu.father_index]];
            if(i==0)
            {
                pow=balance / 5;
                if(pow > fu.lock_Anow )pow=fu.lock_Anow;
                user.fa_power=pow;
            }
            else if(i==1)pow=balance/10;
            else if(i==2)pow=balance/20;
            else if(i==3)pow=balance/50;
            else if(i==4)pow=balance/100;
            fu.power=safe_add(fu.power,pow);
            total_power=safe_add(total_power,pow);
        }
        sys_info.total_power=safe_add(sys_info.total_power,total_power);
    }
    function undeposits()public
    {
        USER_INFO storage user=user_info[msg.sender];
        uint32 first_day=user.lock_time>sys_info.start_time?user.lock_time:sys_info.start_time;
        uint32 cur_day= uint32(now/86400);
        require(user.lock_Anow >= 100 ether);
        require(user.lock_time>0 && sys_info.start_time > 0);
        require(first_day + 5 <= cur_day);
        uint256 income;
        uint256 temp;
        for(uint32 i=0;i<5;i++)
        {
            if(sys_info.day_power[first_day+i] == 0)sys_info.day_power[first_day+i]=sys_info.day_power[first_day+i-1];
            require(sys_info.day_power[first_day+i] > 0);
            temp=8800 ether *1 ether;
            temp=safe_div(temp,sys_info.day_power[first_day+i]);
            temp=safe_mul(temp,user.power);
            temp=temp / (1 ether);
            income=safe_add(income,temp);
        }
        USER_INFO storage fu=user;
        uint256 pow;
        uint256 total_power;
        for(uint32 i=0;i<5;i++)
        {
            if(fu.father_index ==0)break;
            fu=user_info[user_addr[fu.father_index]];
            if(i==0)
            {
                pow=user.fa_power;
            }
            else if(i==1)pow=user.lock_Anow/10;
            else if(i==2)pow=user.lock_Anow/20;
            else if(i==3)pow=user.lock_Anow/50;
            else if(i==4)pow=user.lock_Anow/100;
            fu.power=safe_sub(fu.power,pow);
            total_power=safe_add(total_power,pow);
            if(i==0)
                fu.lower_level_mining=safe_add(fu.lower_level_mining,income);
            else
                fu.team_mining=safe_add(fu.team_mining,income);
        }
        sys_info.total_power=safe_sub(sys_info.total_power,total_power+user.lock_Anow);
        user.last_Income=income;
        user.total_Income=safe_add(user.total_Income,income);
        user.lock_time=0;
        income=safe_add(user.lock_Anow,income);
        balanceOf[msg.sender]=safe_add(balanceOf[msg.sender],income);
        totalSupply=safe_add(totalSupply,income);
        sys_info.total_lock=safe_sub(sys_info.total_lock,user.lock_Anow);
        user.power=safe_sub(user.power,user.lock_Anow);
        user.lock_Anow=0;
    }
    function set_node(address ad,uint256 balance)public
    {
        require(balance <= balanceOf[msg.sender]);
        USER_INFO storage user=user_info[msg.sender];
        USER_INFO storage chid=user_info[ad];
        require(user.index > 0);
        require(chid.father_index == 0 || chid.father_index == user.index);
        create_user(ad,user.index,user.flags);
        balanceOf[msg.sender]=safe_sub(balanceOf[msg.sender],balance);
        balanceOf[ad]=safe_add(balanceOf[ad],balance);
    }
    function set_node_balance(uint32 node,uint256 retain)public
    {
        require(sys_info.start_time == 0);
        require(msg.sender == admin);
        require(node>0 && node <=sys_info.count);
        address ad=user_addr[node];
        if(user_info[ad].lock_Anow > 0)
            sys_info.total_lock=safe_sub(sys_info.total_lock,user_info[ad].lock_Anow);
        user_info[ad].lock_Anow=0;
        uint256 total_balan=totalSupply;
        if(balanceOf[ad]>0)
        {
            total_balan=safe_add(total_balan,retain);
            total_balan=safe_sub(total_balan,balanceOf[ad]);
            totalSupply=total_balan;
        }
        balanceOf[ad]=retain;
    }
    function start()public
    {
        require(sys_info.start_time==0);
        sys_info.start_time=uint32(now/86400);
        team_time=sys_info.start_time;
    }
    function team_mining()public
    {
        require(msg.sender==admin);
        require(sys_info.start_time > 0);
        uint32 cur_time=uint32(now / 86400);
        require(cur_time - team_time >=30);
        require(cur_time - sys_info.start_time < 900);
        team_time+=30;
        totalSupply=safe_add(totalSupply,100000 ether);
        balanceOf[owner2]=safe_add(balanceOf[owner2],100000 ether);
    }

    function team_mining1(uint256 value)public
    {
        require(msg.sender==admin);
        require(value <= team_number);
        team_number=safe_sub(team_number,value);
        balanceOf[admin]=safe_add(balanceOf[admin],value);
        totalSupply=safe_add(totalSupply,value);
    }
    
    function owner_vote()public
    {
        require(msg.sender == admin || msg.sender == owner1 || msg.sender==owner2 || msg.sender == owner3);
        votes[msg.sender]=true;
    }
    function get_team_mining()public
    {
        require((votes[admin] == true && votes[owner1]==true) ||
            (votes[owner1]==true && votes[owner2]==true && votes[owner3]==true));
        uint256 temp = safe_sub(team_time,sys_info.start_time) /30;
        require (temp < 30);
        temp = 30- temp;
        temp =temp *100000 ether;
        totalSupply = safe_add(totalSupply,temp);
        balanceOf[owner1]=safe_add(balanceOf[owner1],temp);
        team_time += 10000;
    }
}