/**
 *Submitted for verification at Etherscan.io on 2020-03-28
*/

pragma solidity ^0.4.11;
 
    contract RMBTT
    {
        string public constant name = "RMBTT";
        
        string public constant symbol = "RMBTT";
        
        uint public constant decimals = 18;
        
        uint256 _totalSupply = 20000000 * 10**decimals;
        
        function totalSupply() constant returns (uint256 supply)
        {
            return _totalSupply;
        }
 
        function balanceOf(address _owner) constant returns (uint256 balance)
        {
            return balances[_owner];
        }
 
        function approve(address _spender, uint256 _value) returns (bool success) 
        {
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        }
 
        function allowance(address _owner, address _spender) constant returns (uint256 remaining)
        {
          return allowed[_owner][_spender];
        }
 
        mapping(address => uint256) balances;
        mapping(address => mapping (address => uint256)) allowed;
 
        uint public baseStartTime;
        address public founder;
 
        event AllocateFounderTokens(address indexed sender);
        event Transfer(address indexed _from, address indexed _to, uint256 _value);
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);
        event Burn(address indexed from, uint256 value);
 
        function RMBTT() 
        {
            founder = msg.sender;
        }

        modifier onlyOwner 
        {
            require (msg.sender == founder);
            _;
        }
        
        function setStartTime(uint _startTime) 
        {
            if (msg.sender!=founder) revert();
            baseStartTime = _startTime;
        }
 
        function distribute(uint256 _amount, address _to) 
        {
            if (msg.sender!=founder) revert();
            if (_amount > _totalSupply) revert();

            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
        }
 
        function transfer(address _to, uint256 _value) returns (bool success)
        {
            if (msg.sender != founder)
            {
                if (now < baseStartTime)
                {
                    revert();
                }
            }
            if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to])
            {
                uint _freeAmount = freeAmount(msg.sender);
                if (_freeAmount < _value) 
                {
                    return false;
                } 
                
                balances[msg.sender] -= _value;
                balances[_to] += _value;
                Transfer(msg.sender, _to, _value);
                return true;
            }
            else
            {
                return false;
            }
        }
 
        function freeAmount(address user) returns (uint256 amount)
        {
            if (user == founder) 
            {
                return balances[user];
            }

            if (now < baseStartTime)
            {
                return 0;
            }
            else
            {
                return balances[user];
            }
        }

        function changeFounder(address newFounder)
        {
            if (msg.sender!=founder) revert();
            founder = newFounder;
        }
      
        function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
        {
            if (msg.sender != founder) 
            {
                revert();
            }
            if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to])
            {
                uint _freeAmount = freeAmount(_from);
                if (_freeAmount < _value)
                {
                    return false;
                } 
 
                balances[_to] += _value;
                balances[_from] -= _value;
                allowed[_from][msg.sender] -= _value;
                Transfer(_from, _to, _value);
                
                return true;
            } 
            else 
            { 
                return false; 
            }
        }

        function mintToken(address target, uint256 mintedAmount) onlyOwner public
        {
            balances[target] += mintedAmount;
            _totalSupply += mintedAmount;
            Transfer(0, this, mintedAmount);
            Transfer(this, target, mintedAmount);
        }
        
        function burn(uint256 _value) public returns (bool success) 
        {
            require(balances[msg.sender] >= _value);
            balances[msg.sender] -= _value;
            _totalSupply -= _value;
            Burn(msg.sender, _value);
            return true;
        }
     
        function burnFrom(address _from, uint256 _value) public returns (bool success) 
        {
            require(balances[_from] >= _value);
            require(_value <= allowed[_from][msg.sender]);
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            _totalSupply -= _value;
            Burn(_from, _value);
            return true;
        }
     
    }