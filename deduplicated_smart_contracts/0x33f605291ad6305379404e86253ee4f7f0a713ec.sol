/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.4.21;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public  returns (uint256);
    function transfer(address to, uint256 value) public  returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FBTT is ERC20 {

    using SafeMath for uint256;

    address public owner;

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    string public name = "Forex Business Transaction Token";
    string public constant symbol = "FBTT";
    uint public constant decimals = 18;

    //存储是否查看即空投过
    mapping(address => bool) touched;
    //查看即空投 100万
    uint currentBalanceAirTotalSupply = 1000000*(10**18); 
    uint currentBalanceAirSupply = 0;    // 已经查看即空投数量
    uint airdropNum = 100 ether;      //查看即空投 单个账户空投数量

    uint stopped;
    
    uint256 public total = 1000000000*(10**18)  ;//总量

    uint256 public totalSupply = total.mul(25).div(100);//总流通量  初始化 25% 营销渠道商务拓展 15%  10% 品牌合作、顾问服务


    //10% team锁仓总量
    uint256 public lockTeamTotal = total.div(10) ;
    //团队已解锁总量
    uint256 public unlockTeamTotal = 0;

    //45%  remain lock总量
    uint256 public  lockRemainTotal = total.mul(45).div(100)  ;
    //剩余    已解锁总量
    uint256 public  unlockRemainTotal = 0;


    //15%  Available +5% airDrop  前期总流通量 20%
    uint256 public availableTotal = total.mul(2).div(10) ;
    //准备空投数量
    uint256 public airdropTotal = total.div(20);
    //已空投数量
    uint256 public airdropedTotal = 0 ;

    uint256 public _startTime;

    modifier stoppable {
        assert(stopped == 0);
        _;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // 10% for ， 15%  for 
    function FBTT(address marketAddress,address brandAddress,address _owner) public {
        require(marketAddress != address(0));
        require(brandAddress != address(0));
        require(marketAddress != brandAddress);
        owner = _owner;

         _startTime = block.timestamp;
        
        balances[marketAddress] =  total.mul(15).div(100) ; // 15%
        balances[brandAddress] =  total.div(10) ; // 10%
        
    }

    function setStop(uint8 num) public onlyOwner  {
        stopped = num;
    }

    
    function transferOwnership(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }

    function balanceOf(address _owner)  public   returns (uint256) {
    // 添加这个方法，当余额为0的时候直接空投
    if (!touched[_owner] && currentBalanceAirSupply< currentBalanceAirTotalSupply &&  (totalSupply.add(airdropNum) <= total)) {
        touched[_owner] = true;
        currentBalanceAirSupply = currentBalanceAirSupply.add(airdropNum);
        totalSupply = totalSupply.add(airdropNum);
        balances[_owner] =  balances[_owner].add(airdropNum);
        airdropedTotal = airdropedTotal.add(airdropNum);
    }
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _amount) stoppable  public returns (bool success) {
        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    function transferFrom(address _from, uint256 _amount) stoppable public returns (bool success) {
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
        emit Transfer(_from, msg.sender, _amount);
        return true;
    }
    
    function approve(address _spender, uint256 _value) stoppable public returns (bool success) {
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //burn 
    function burn(address _from,uint256 _amount) public onlyOwner {
        require(_amount <= balances[_from]);
        balances[_from] = balances[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        total = total.sub(_amount);
        emit Transfer(_from, address(0), _amount);
    }

    //airdrop 
    function airdrop(address[] target, uint256 mintedAmount) public onlyOwner returns (bool)  {

        for(uint i=0;i<target.length;i++){
        require(airdropedTotal.add(mintedAmount)<= airdropTotal);
            mint(target[i],mintedAmount);
            airdropedTotal = airdropedTotal.add(mintedAmount);
        }

        return true;
    }
    
    //mint 
    function mint(address target, uint256 mintedAmount) public onlyOwner returns (bool)  {

            require(airdropedTotal.add(mintedAmount)<= availableTotal);

            balances[target] = balances[target].add(mintedAmount);
            totalSupply = totalSupply.add(mintedAmount);
            emit Transfer(0, target, mintedAmount);
            return true;
    }


    //release uint 1：team  2：剩余
    function release(uint accountType,address target,uint256 amount) public onlyOwner returns (bool)  {

            require((totalSupply.add(amount))<= total);

            if(accountType == 1){
                
                require((_startTime + 180 days) < block.timestamp);
                
                if((_startTime + 180 days) > block.timestamp){
                    require(unlockTeamTotal < (total.mul(1).div(100)));  
                } 

                if((_startTime + 210 days) > block.timestamp){
                   require(unlockTeamTotal < (total.mul(2).div(100)));
                } 

                if((_startTime + 240 days) > block.timestamp){
                  require(unlockTeamTotal < (total.mul(3).div(100)));

                } 

                if((_startTime + 270 days) > block.timestamp){
                  require(unlockTeamTotal < (total.mul(4).div(100)));
                }  

                if((_startTime + 300 days) > block.timestamp){
                  require(unlockTeamTotal < (total.mul(5).div(100)));

                }  

                if((_startTime + 330 days) > block.timestamp){
                 require(unlockTeamTotal < (total.mul(6).div(100)));
                }  

                if((_startTime + 360 days) > block.timestamp){
                 require(unlockTeamTotal < (total.mul(7).div(100)));

                }  

                if((_startTime + 390 days) > block.timestamp){
                 require(unlockTeamTotal < (total.mul(8).div(100)));

                }

                if((_startTime + 420 days) > block.timestamp){
                 require(unlockTeamTotal < (total.mul(9).div(100)));

                }

                if((_startTime + 450 days) > block.timestamp){
                 require(unlockTeamTotal < (total.mul(10).div(100)));

                }

                 unlockTeamTotal=unlockTeamTotal.add(amount);
            }else {
                
                    require((_startTime + 1 years) < block.timestamp);
                  
                   if((_startTime + 1 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(5).div(100)));
                   }
                   if((_startTime + 2 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(10).div(100)));
                   }
                   if((_startTime + 3 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(15).div(100)));
                   }
                   if((_startTime + 4 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(20).div(100)));
                   }
                   if((_startTime + 5 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(25).div(100)));
                   }
                   if((_startTime + 6 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(30).div(100)));
                   }
                   if((_startTime + 7 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(35).div(100)));
                   }
                   if((_startTime + 8 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(40).div(100)));
                   }
                   if((_startTime + 9 years) > block.timestamp){
                      require(unlockRemainTotal < (total.mul(45).div(100)));
                   }

                    unlockRemainTotal=unlockRemainTotal.add(amount);
                   
            }

            balances[target]=balances[target].add(amount);
            totalSupply=totalSupply.add(amount);
            emit Transfer(0, target, amount);
            return true;
    }


    function allowance(address _owner, address _spender)  constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
    
}