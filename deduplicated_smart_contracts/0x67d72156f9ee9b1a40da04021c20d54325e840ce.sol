/**
 *Submitted for verification at Etherscan.io on 2020-11-29
*/

/*

AXXA.AI

*/
pragma solidity 0.4.20;

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

contract UnknownToken {
    function balanceOf(address _owner) constant public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

interface Token { 
    function release(address _to, uint256 _value) external returns (bool);
    function totalSupply() constant external returns (uint256 supply);
    function balanceOf(address _owner) constant external returns (uint256 balance);
}

contract AXXA is ERC20 {
    
    using SafeMath for uint256;
    address owner = msg.sender;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string public constant name = "AXXA.AI";
    string public constant symbol = "AXXA";
    uint public constant decimals = 18;
    
    uint256 public totalSupply = 1000000000e18;
    uint256 public circulatingSupply = 0;
    uint256 public unreleasedTokens = totalSupply.sub(circulatingSupply);
    uint256 value;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    event Release(address indexed to, uint256 amount);
    event ReleaseComplete();
    
    event Burn(address indexed burner, uint256 value);

    bool public tokenReleaseComplete = false;
    
    modifier canRelease() {
        require(!tokenReleaseComplete);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
   
    
    function AXXA () public {
        owner = msg.sender;
        release(owner, circulatingSupply);
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
	
    function finishTokenRelease() onlyOwner canRelease public returns (bool) {
        tokenReleaseComplete = true;
        ReleaseComplete();
        return true;
    }
    
    function release(address _to, uint256 _amount) canRelease private returns (bool) {
        circulatingSupply = circulatingSupply.add(_amount);
        unreleasedTokens = unreleasedTokens.sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Release(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
        
        if (circulatingSupply >= totalSupply) {
            tokenReleaseComplete = true;
        }
    }
    
   
    function distributeAmounts(address[] addresses, uint256[] amounts) onlyOwner canRelease public {
        
        require(addresses.length <= 255);
        require(addresses.length == amounts.length);
        
        for (uint8 i = 0; i < addresses.length; i++) {
            amounts[i]=amounts[i].mul(1e18); // no need of decimals
            require(amounts[i] <= unreleasedTokens);

            release(addresses[i], amounts[i]);
            
            if (circulatingSupply >= totalSupply) {
                tokenReleaseComplete = true;
            }
        }
    }
    
    function () external payable {
		
           owner.transfer(msg.value);
     }
    

    function balanceOf(address _owner) constant public returns (uint256) {
	    return balances[_owner];
    }
	

    // mitigates the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
 
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
      
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    function burn(uint256 _value) onlyOwner public {
        
        _value=_value.mul(1e18); // no need of decimals
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which should be an assertion failure
        
        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        circulatingSupply = circulatingSupply.sub(_value);
        Burn(burner, _value);
		Transfer(burner, address(0), _value);
    }
    
    function recoverUnknownTokens(address _tokenContract) onlyOwner public returns (bool) {
        UnknownToken token = UnknownToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }


}