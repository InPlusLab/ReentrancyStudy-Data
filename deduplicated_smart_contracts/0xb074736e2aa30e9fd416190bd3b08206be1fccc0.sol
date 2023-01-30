pragma solidity ^0.4.21;

/// RK35Z token ERC20 with Extensions ERC223
contract RK40Z {
    uint256 constant public MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    bool public SC_locked = true;
    bool public tokenCreated = false;
	uint public DateCreateToken;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => bool) public frozenAccount;
	mapping(address => bool) public SmartContract_Allowed;

	// ERC20 Event 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event FrozenFunds(address target, bool frozen);
	event Burn(address indexed from, uint256 value);
    
    // Initialize
    // Constructor is called only once and can not be called again (Ethereum Solidity specification)
    function RK40Z() public {
        // Security check in case EVM has future flaw or exploit to call constructor multiple times
        require(tokenCreated == false);

        owner = msg.sender;
        
		name = "RK40Z";
        symbol = "RK40Z";
        decimals = 5;
        totalSupply = 500000000 * 10 ** uint256(decimals);
        balances[owner] = totalSupply;
        emit Transfer(owner, owner, totalSupply);
		
        tokenCreated = true;

        // Final sanity check to ensure owner balance is greater than zero
        require(balances[owner] > 0);

		// Date Deploy Contract
		DateCreateToken = now;
    }
	
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

	// Function to create date token.
    function DateCreateToken() public view returns (uint256 _DateCreateToken) {
		return DateCreateToken;
	}
   	
    // Function to access name of token .
    function name() view public returns (string _name) {
		return name;
	}
	
    // Function to access symbol of token .
    function symbol() public view returns (string _symbol) {
		return symbol;
    }

    // Function to access decimals of token .
    function decimals() public view returns (uint8 _decimals) {	
		return decimals;
    }

    // Function to access total supply of tokens .
    function totalSupply() public view returns (uint256 _totalSupply) {
		return totalSupply;
	}
	
	// Get balance of the address provided
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

	// Get Smart Contract of the address approved
    function SmartContract_Allowed(address _target) constant public returns (bool _sc_address_allowed) {
        return SmartContract_Allowed[_target];
    }

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) revert();
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x < y) revert();
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
    }

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint256 _value, bytes _data) public  returns (bool success) {
        // Only allow transfer once Locked
        // Once it is Locked, it is Locked forever and no one can lock again
		require(!SC_locked);
		require(!frozenAccount[msg.sender]);
		require(!frozenAccount[_to]);
		
        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } 
        else {
            return transferToAddress(_to, _value, _data);
        }
    }

    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // Only allow transfer once Locked
        require(!SC_locked);
		require(!frozenAccount[msg.sender]);
		require(!frozenAccount[_to]);

        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } 
        else {
            return transferToAddress(_to, _value, empty);
        }
    }

	// assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    // function that is called when transaction target is an address
    function transferToAddress(address _to, uint256 _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    // function that is called when transaction target is a contract
    function transferToContract(address _to, uint256 _value, bytes _data) private returns (bool success) {
        require(SmartContract_Allowed[_to]);
		
		if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

   
    // Allow transfers if the owner provided an allowance
    // Use SafeMath for the main logic
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // Only allow transfer once Locked
        // Once it is Locked, it is Locked forever and no one can lock again
        require(!SC_locked);
		require(!frozenAccount[_from]);
		require(!frozenAccount[_to]);
		
        // Protect against wrapping uints.
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][owner];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        balances[_from] = safeSub(balanceOf(_from), _value);
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // Only allow transfer once unLocked
        require(!SC_locked);
		require(!frozenAccount[msg.sender]);
		require(!frozenAccount[_spender]);
		
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
		return allowed[_owner][_spender];
    }
	
    /// Set allowance for other address and notify
    function approveAndCall(address _spender, uint256 _value) public returns (bool success) {
        require(!SC_locked);
		require(!frozenAccount[msg.sender]);
		require(!frozenAccount[_spender]);
		
        if (approve(_spender, _value)) {
            return true;
        }
    }
	
	/// Function to activate Ether reception in the smart Contract address only by the Owner
    function () public payable { 
		if(msg.sender != owner) { revert(); }
    }

	// Creator/Owner can Locked/Unlock smart contract
    function OWN_ChangeState_locked(bool _locked) onlyOwner public {
        SC_locked = _locked;
    }
	
	 /// Destroy tokens amount (Caution!!! the operation is destructive and you can not go back)
    function OWN_burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    /// Destroy tokens amount from another account (Caution!!! the operation is destructive and you can not go back)
    function OWN_burnAddress(address _from, uint256 _value)  onlyOwner public returns (bool success) {
        require(balances[_from] >= _value);
        require(_value <= allowed[_from][owner]);
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;             
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
	
	///Generate other tokens after starting the program
    function OWN_mintToken(uint256 mintedAmount) onlyOwner public {
        //aggiungo i decimali al valore che imposto
        balances[owner] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, owner, mintedAmount);
    }
	
	/// Block / Unlock address handling tokens
    function OWN_freezeAddress(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
		
	/// Function to destroy the smart contract
    function OWN_kill() onlyOwner public { 
		selfdestruct(owner); 
    }
	
	/// Function Change Owner
	function OWN_transferOwnership(address newOwner) onlyOwner public {
        // function allowed only if the address is not smart contract
        if (!isContract(newOwner)) {	
			owner = newOwner;
		}
    }
	
	/// Smart Contract approved
    function OWN_SmartContract_Allowed(address target, bool _allowed) onlyOwner public {
		// function allowed only for smart contract
        if (isContract(target)) {
			SmartContract_Allowed[target] = _allowed;
		}
    }
	
	/// Distribution Token from Admin
	function OWN_DistributeTokenAdmin_Multi(address[] addresses, uint256 _value, bool freeze) onlyOwner public{
		for (uint i = 0; i < addresses.length; i++) {
			//Block / Unlock address handling tokens
			frozenAccount[addresses[i]] = freeze;
			emit FrozenFunds(addresses[i], freeze);
			
			bytes memory empty;
			if (isContract(addresses[i])) {
				transferToContract(addresses[i], _value, empty);
			} 
			else {
				transferToAddress(addresses[i], _value, empty);
			}
		}
	}
}