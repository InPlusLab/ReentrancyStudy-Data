pragma solidity ^0.5.0;

import "./ERC20Interface.sol";
import "./OwnerHelper.sol";
import "./SafeMath.sol";

contract VALLIXToken is ERC20Interface, OwnerHelper
{
    using SafeMath for uint;
    
    string public name;
    uint public decimals;
    string public symbol;
    
    uint constant private E18 = 1000000000000000000;
    uint constant private month = 2592000;
    
    uint constant public maxTotalSupply     = 10000000000 * E18;
    
    uint constant public maxSaleSupply      =  2000000000 * E18;
    uint constant public maxCrowdSupply     =  1600000000 * E18;
    uint constant public maxMktSupply       =  2800000000 * E18;
    uint constant public maxTeamSupply      =  1600000000 * E18;
    uint constant public maxReserveSupply   =  1600000000 * E18;
    uint constant public maxAdvisorSupply   =   400000000 * E18;
    
    uint constant public teamVestingSupplyPerTime       = 100000000 * E18;
    uint constant public teamVestingDate                = 2 * month;
    uint constant public teamVestingTime                = 16;
    
    uint public totalTokenSupply;
    
    uint public tokenIssuedSale;
    uint public privateIssuedSale;
    uint public publicIssuedSale;
    uint public tokenIssuedCrowd;
    uint public tokenIssuedMkt;
    uint public tokenIssuedTeam;
    uint public tokenIssuedReserve;
    uint public tokenIssuedAdvisor;
    
    uint public burnTokenSupply;
    
    mapping (address => uint) public balances;
    mapping (address => mapping ( address => uint )) public approvals;
    
    mapping (address => uint) public privateFirstWallet;
    mapping (address => uint) public privateSecondWallet;
    mapping (address => uint) public privateThirdWallet;
    mapping (address => uint) public privateFourthWallet;
    mapping (address => uint) public privateFifthWallet;
    
    mapping (uint => uint) public teamVestingTimeAtSupply;
    
    bool public tokenLock = true;
    bool public saleTime = true;
    uint public endSaleTime = 0;

    event Burn(address indexed _from, uint _value);
    
    event SaleIssue(address indexed _to, uint _tokens);
    event CrowdIssue(address indexed _to, uint _tokens);
    event MktIssue(address indexed _to, uint _tokens);
    event TeamIssue(address indexed _to, uint _tokens);
    event ReserveIssue(address indexed _to, uint _tokens);
    event AdvisorIssue(address indexed _to, uint _tokens);
    
    event TokenUnLock(address indexed _to, uint _tokens);
    
    constructor() public
    {
        name        = "VALLIX Token";
        decimals    = 18;
        symbol      = "VLX";
        
        totalTokenSupply = 0;
        
        tokenIssuedSale     = 0;
        tokenIssuedCrowd    = 0;
        tokenIssuedMkt      = 0;
        tokenIssuedTeam     = 0;
        tokenIssuedReserve  = 0;
        tokenIssuedAdvisor  = 0;
        
        require(maxTotalSupply == maxSaleSupply + maxCrowdSupply + maxMktSupply + maxTeamSupply + maxReserveSupply + maxAdvisorSupply);
        
        require(maxTeamSupply == teamVestingSupplyPerTime * teamVestingTime);
        
    }
    
    function totalSupply() view public returns (uint) 
    {
        return totalTokenSupply;
    }
    
    function balanceOf(address _who) view public returns (uint) 
    {
        uint balance = balances[_who];
        balance = balance.add(privateFirstWallet[_who] + privateSecondWallet[_who] + privateThirdWallet[_who] + privateFourthWallet[_who] + privateFifthWallet[_who]);
        
        return balance;
    }
    
    function transfer(address _to, uint _value) public returns (bool) 
    {
        require(isTransferable() == true);
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool)
    {
        require(isTransferable() == true);
        require(balances[msg.sender] >= _value);
        
        approvals[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true; 
    }
    
    function allowance(address _owner, address _spender) view public returns (uint) 
    {
        return approvals[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) 
    {
        require(isTransferable() == true);
        require(balances[_from] >= _value);
        require(approvals[_from][msg.sender] >= _value);
        
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }
    
    function privateIssue(address _to, uint _value) onlyIssuer public
    {
        uint tokens = _value * E18;
        require(maxSaleSupply >= tokenIssuedSale.add(tokens));
        
        balances[_to]                   = balances[_to].add( tokens.mul(10)/100 );
        privateFirstWallet[_to]         = privateFirstWallet[_to].add( tokens.mul(10)/100 );
        privateSecondWallet[_to]        = privateSecondWallet[_to].add( tokens.mul(10)/100 );
        privateThirdWallet[_to]         = privateThirdWallet[_to].add( tokens.mul(20)/100 );
        privateFourthWallet[_to]        = privateFourthWallet[_to].add( tokens.mul(20)/100 );
        privateFifthWallet[_to]         = privateFifthWallet[_to].add( tokens.mul(30)/100 );
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedSale = tokenIssuedSale.add(tokens);
        privateIssuedSale = privateIssuedSale.add(tokens);
        
        emit SaleIssue(_to, tokens);
    }

    function publicIssue(address _to, uint _value) onlyIssuer public
    {
        uint tokens = _value * E18;
        require(maxSaleSupply >= tokenIssuedSale.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedSale = tokenIssuedSale.add(tokens);
        publicIssuedSale = publicIssuedSale.add(tokens);
        
        emit SaleIssue(_to, tokens);
    }

    function crowdIssue(address _to, uint _value) onlyIssuer public
    {
        uint tokens = _value * E18;
        require(maxCrowdSupply >= tokenIssuedCrowd.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedCrowd = tokenIssuedCrowd.add(tokens);
        
        emit CrowdIssue(_to, tokens);
    }
    
    function mktIssue(address _to, uint _value) onlyIssuer public
    {
        uint tokens = _value * E18;
        require(maxMktSupply >= tokenIssuedMkt.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedMkt = tokenIssuedMkt.add(tokens);
        
        emit MktIssue(_to, tokens);
    }
    
    function reserveIssue(address _to, uint _value) onlyIssuer public
    {
        uint tokens = _value * E18;
        require(maxReserveSupply >= tokenIssuedReserve.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedReserve = tokenIssuedReserve.add(tokens);
        
        emit ReserveIssue(_to, tokens);
    }

    function teamIssueVesting(address _to, uint _time) onlyIssuer public
    {
        require(saleTime == false);
        require(teamVestingTime >= _time);
        
        uint time = now;
        require( ( ( endSaleTime + (_time * teamVestingDate) ) < time ) && ( teamVestingTimeAtSupply[_time] > 0 ));
        
        uint tokens = teamVestingTimeAtSupply[_time];

        require(maxTeamSupply >= tokenIssuedTeam.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        teamVestingTimeAtSupply[_time] = 0;
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedTeam = tokenIssuedTeam.add(tokens);
        
        emit TeamIssue(_to, tokens);
    }
    
    function advisorIssue(address _to, uint _value) onlyIssuer public
    {
        uint tokens = _value * E18;
        
        require(maxAdvisorSupply >= tokenIssuedAdvisor.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedAdvisor = tokenIssuedAdvisor.add(tokens);
        
        emit AdvisorIssue(_to, tokens);
    }

    function isTransferable() private view returns (bool)
    {
        if(tokenLock == false)
        {
            return true;
        }
        else if(msg.sender == manager)
        {
            return true;
        }
        
        return false;
    }
    
    function setTokenUnlock() onlyManager public
    {
        require(tokenLock == true);
        require(saleTime == false);
        
        tokenLock = false;
    }
    
    function setTokenLock() onlyManager public
    {
        require(tokenLock == false);
        
        tokenLock = true;
    }
    
    function privateUnlock(address _to) onlyManager public
    {
        require(tokenLock == false);
        require(saleTime == false);
        
        uint time = now;
        uint unlockTokens = 0;

        if( (time >= endSaleTime.add(month)) && (privateFirstWallet[_to] > 0) )
        {
            balances[_to] = balances[_to].add(privateFirstWallet[_to]);
            unlockTokens = unlockTokens.add(privateFirstWallet[_to]);
            privateFirstWallet[_to] = 0;
        }
        
        if( (time >= endSaleTime.add(month * 2)) && (privateSecondWallet[_to] > 0) )
        {
            balances[_to] = balances[_to].add(privateSecondWallet[_to]);
            unlockTokens = unlockTokens.add(privateSecondWallet[_to]);
            privateSecondWallet[_to] = 0;
        }

        if( (time >= endSaleTime.add(month * 3)) && (privateThirdWallet[_to] > 0) )
        {
            balances[_to] = balances[_to].add(privateThirdWallet[_to]);
            unlockTokens = unlockTokens.add(privateThirdWallet[_to]);
            privateThirdWallet[_to] = 0;
        }

        if( (time >= endSaleTime.add(month * 4)) && (privateFourthWallet[_to] > 0) )
        {
            balances[_to] = balances[_to].add(privateFourthWallet[_to]);
            unlockTokens = unlockTokens.add(privateFourthWallet[_to]);
            privateFourthWallet[_to] = 0;
        }

        if( (time >= endSaleTime.add(month * 5)) && (privateFifthWallet[_to] > 0) )
        {
            balances[_to] = balances[_to].add(privateFifthWallet[_to]);
            unlockTokens = unlockTokens.add(privateFifthWallet[_to]);
            privateFifthWallet[_to] = 0;
        }
        
        emit TokenUnLock(_to, unlockTokens);
    }
    
    function () payable external
    {
        revert();
    }
    
    function endSale() onlyManager public
    {
        require(saleTime == true);
        
        saleTime = false;
        
        uint time = now;
        
        endSaleTime = time;
        
        for(uint i = 1; i <= teamVestingTime; i++)
        {
            teamVestingTimeAtSupply[i] = teamVestingTimeAtSupply[i].add(teamVestingSupplyPerTime);
        }
       
    }    
   
    function transferAnyERC20Token(address tokenAddress, uint tokens) onlyManager public returns (bool success)
    {
        return ERC20Interface(tokenAddress).transfer(manager, tokens);
    }
    
    function burnToken(uint _value) onlyManager public
    {
        uint tokens = _value * E18;
        
        require(balances[msg.sender] >= tokens);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        burnTokenSupply = burnTokenSupply.add(tokens);
        totalTokenSupply = totalTokenSupply.sub(tokens);
        
        emit Burn(msg.sender, tokens);
    }
    
    function close() onlyMaster public
    {
        selfdestruct(msg.sender);
    }
}