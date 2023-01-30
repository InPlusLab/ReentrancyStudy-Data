/**
 *Submitted for verification at Etherscan.io on 2020-07-24
*/

pragma solidity >=0.4.22 <0.6.0;

contract OldContract
{
    function balanceOf(address addr) public view returns(uint256);
    function user_addr(uint32 index)public view returns(address);
}

contract AnowToken {
    string public name = 'Anow ';
    string public symbol = 'Anow';
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 private team_before_miner=3000000 ether;
    mapping (address => USERINFO) public user;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    address private admin;
    address private owner;
    uint8 private updata_old;
    struct USERINFO{
        uint256 anow;
        uint256 mine;
        uint256 time;
        uint8 is_hacker;
    }
    
    constructor () public {
        admin=msg.sender;
        owner=address(0x166451fFd5F53d2691e0734bEF2f3503747380B9);
    }
    
    function _transfer(address _from, address _to, uint _value) internal {

        require(_to !=address(0x0));
        require(user[_from].anow >= _value);
        require(user[_to].anow + _value > user[_to].anow);

        uint previousBalances = user[_from].anow + user[_to].anow; 
        user[_from].anow -= _value;
        user[_to].anow += _value;
        emit Transfer(_from, _to, _value); 
        assert(user[_from].anow + user[_to].anow == previousBalances);  
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
    
    function balanceOf(address addr)public view returns(uint256)
    {
        return user[addr].anow;
    }
    
    //ÍÚ¿ó
    function set_miner(uint256 anow)public
    {
        require(anow<=user[msg.sender].anow);
        user[msg.sender].anow -= anow;
        totalSupply -= anow;
        user[msg.sender].mine +=anow;
        user[msg.sender].time =now;
    }
    //È¡¿ó

    function get_miner(uint256 anow)public
    {
        require(user[msg.sender].is_hacker == 0);
        uint256 time=now;
        require(user[msg.sender].mine > 0);
        require(time > user[msg.sender].time + 432000);
        uint256 _anow=(user[msg.sender].mine)+user[msg.sender].mine/10;
        _anow=(_anow > anow?anow:_anow);
        totalSupply +=_anow;
        user[msg.sender].mine = 0;
        user[msg.sender].anow=user[msg.sender].anow+_anow;
    }
    function set_hacker(address addr,uint8 flags)public
    {
        require(msg.sender == admin || msg.sender == owner);
        user[addr].is_hacker = flags; 
    }
    //Ô¤ÍÚ
    function team_miner(uint256 anow)public
    {
        require(msg.sender == admin || msg.sender == owner);
        require(anow <= team_before_miner);
        team_before_miner -= anow;
        user[msg.sender].anow +=anow;
    }
    
    function destroy_anow(uint256 anow)public
    {
        require(msg.sender == admin || msg.sender == owner);
        require(anow <= user[owner].anow);
        require(anow <= totalSupply);
        totalSupply -=anow;
        user[msg.sender].anow -=anow;
    }
    function get_old_anow(address contr, uint32 first,uint32 last)public
    {
        require(updata_old == 0);
        address addr;
        uint256 total;
        uint256 a;
        OldContract old=OldContract(contr);
        for(uint32 i=first;i<=last;i++)
        {
            addr=old.user_addr(i);
            a=old.balanceOf(addr);
            user[addr].anow=a;
            total+=a;
        }
        if(first == 1)
            updata_old = 1;
            
        totalSupply += total;
    }
}