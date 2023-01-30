/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.25;

/**

 * @title Happy Melody Token

 * @dev Happy Melody Token Smart Contract

 */

// Public Sale: 10 November      Public Sale Ends: 30 November

// Min. Purchase: 0.01 ETH

// Initial Value: 1HMT = 0.00000005

// Number of tokens for sale: 9.000.000.000 HMT (60%)

// Fouder + CEO  10%

// Team 3%

// DEV 2%

// Marketting + Partnerships 15%

// Telegram : https://t.me/HappyMelodyToken_HMT

// Fabook : https://www.facebook.com/HappyMelodyToken/

library SafeMath {



    

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {

            return 0;

        }

        c = a * b;

        assert(c / a == b);

        return c;

    }



   

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

      

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



contract AltcoinToken {

    function balanceOf(address _owner) constant public returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

}



contract ERC20Basic {

    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract HappyMelodyToken is ERC20 {

// HappyMelodyToken

// Token name: Happy Melody Token

// Symbol: HMT

// Decimals: 18

// This creates an array with all balances 

    using SafeMath for uint256;

    address owner = msg.sender;



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;    



    string public constant name = "Happy Melody Token";                      // Set the name for dis

    string public constant symbol = "HMT";                                   // Set the symbol for display purposes

    uint public constant decimals = 8;                                      // Amount of decimals for display purposes

    

    uint256 public totalSupply = 15000000000e8;                             // Update total supply

    uint256 public totalDistributed = 0;        

    uint256 public tokensPerEth = 15000000e8;

    uint256 public constant minContribution = 1 ether / 100; // 0.01 Ether

//Soft Cap 150ETH

//Hard Cap 600ETH

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    

    event Distr(address indexed to, uint256 amount);

    event DistrFinished();

//Enough Hard Cap to stop ico

    event Airdrop(address indexed _owner, uint _amount, uint _balance);



    event TokensPerEthUpdated(uint _tokensPerEth);

    

    event Burn(address indexed burner, uint256 value);

//All unsold tokens will be burn

    bool public distributionFinished = false;

    

    modifier canDistr() {

        require(!distributionFinished);

        _;

    }

    

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    

    function HappyMelodyToken () public {

        owner = msg.sender;

        uint256 devTokens = 1500000000e8;

        distr(owner, devTokens);

//Founder wallet is locked in 6 Months ( 0x06D49C0BbE8BBA7B42ab19E344242B3D057F53e3 )

//Team wallet is locked in 3 Months

//Advisor Wallet lock for 2 months

    }

    

    function transferOwnership(address newOwner) onlyOwner public {

        if (newOwner != address(0)) {

            owner = newOwner;

        }

    }

    



    function finishDistribution() onlyOwner canDistr public returns (bool) {

        distributionFinished = true;

        emit DistrFinished();

        return true;

    }

    

    function distr(address _to, uint256 _amount) canDistr private returns (bool) {

        totalDistributed = totalDistributed.add(_amount);        

        balances[_to] = balances[_to].add(_amount);

        emit Distr(_to, _amount);

        emit Transfer(address(0), _to, _amount);



        return true;

    }



    function doAirdrop(address _participant, uint _amount) internal {



        require( _amount > 0 );      



        require( totalDistributed < totalSupply );

        

        balances[_participant] = balances[_participant].add(_amount);

        totalDistributed = totalDistributed.add(_amount);



        if (totalDistributed >= totalSupply) {

            distributionFinished = true;

        }



      

        emit Airdrop(_participant, _amount, balances[_participant]);

        emit Transfer(address(0), _participant, _amount);

    }



    function adminClaimAirdrop(address _participant, uint _amount) public onlyOwner {        

        doAirdrop(_participant, _amount);

    }



    function adminClaimAirdropMultiple(address[] _addresses, uint _amount) public onlyOwner {        

        for (uint i = 0; i < _addresses.length; i++) doAirdrop(_addresses[i], _amount);

    }



    function updateTokensPerEth(uint _tokensPerEth) public onlyOwner {        

        tokensPerEth = _tokensPerEth;

        emit TokensPerEthUpdated(_tokensPerEth);

    }

           

    function () external payable {

        getTokens();

     }

    

    function getTokens() payable canDistr  public {

        uint256 tokens = 0;



        require( msg.value >= minContribution );



        require( msg.value > 0 );

        

        tokens = tokensPerEth.mul(msg.value) / 1 ether;        

        address investor = msg.sender;

        

        if (tokens > 0) {

            distr(investor, tokens);

        }



        if (totalDistributed >= totalSupply) {

            distributionFinished = true;

        }

    }



    function balanceOf(address _owner) constant public returns (uint256) {

        return balances[_owner];

    }



    

    modifier onlyPayloadSize(uint size) {

        assert(msg.data.length >= size + 4);

        _;

    }

/* Send coins */

    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

// Add and subtract new balances 

        require(_to != address(0));

        require(_amount <= balances[msg.sender]);

// Add and subtract new balances 

        balances[msg.sender] = balances[msg.sender].sub(_amount);

        balances[_to] = balances[_to].add(_amount);

        emit Transfer(msg.sender, _to, _amount);

        return true;

    }

/* transferFrom */

    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {



        require(_to != address(0));

        require(_amount <= balances[_from]);

        require(_amount <= allowed[_from][msg.sender]);

        

        balances[_from] = balances[_from].sub(_amount);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);

        balances[_to] = balances[_to].add(_amount);

        emit Transfer(_from, _to, _amount);

        return true;

    }

    

    function approve(address _spender, uint256 _value) public returns (bool success) {

// mitigates the ERC20 spend/approval race condition

        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

/* Withdraw */

    function withdraw() onlyOwner public {

        address myAddress = this;

        uint256 etherBalance = myAddress.balance;

        owner.transfer(etherBalance);

    }

/* allowance */

    function allowance(address _owner, address _spender) constant public returns (uint256) {

        return allowed[_owner][_spender];

    }

/* getTokens */

    function getTokenBalance(address tokenAddress, address who) constant public returns (uint){

        AltcoinToken t = AltcoinToken(tokenAddress);

        uint bal = t.balanceOf(who);

        return bal;

    }

/* Burn */

    function burn(uint256 _value) onlyOwner public {

        require(_value <= balances[msg.sender]);

        //All unsold tokens will be burn

        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);

        totalSupply = totalSupply.sub(_value);

        totalDistributed = totalDistributed.sub(_value);

        emit Burn(burner, _value);

    }

/* withdrawAltcoinTokens */

    function withdrawAltcoinTokens(address _tokenContract) onlyOwner public returns (bool) {

        AltcoinToken token = AltcoinToken(_tokenContract);

        uint256 amount = token.balanceOf(address(this));

        return token.transfer(owner, amount);

    }

}