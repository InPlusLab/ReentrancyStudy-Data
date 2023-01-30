/**

 *Submitted for verification at Etherscan.io on 2019-05-02

*/



pragma solidity >=0.4.18;



contract ERC20Token {



  function totalSupply () constant returns (uint256 _totalSupply);



  function balanceOf (address _owner) constant returns (uint256 balance);



  function transfer (address _to, uint256 _value) returns (bool success);



  function transferFrom (address _from, address _to, uint256 _value) returns (bool success);



  function approve (address _spender, uint256 _value) returns (bool success);



  function allowance (address _owner, address _spender) constant returns (uint256 remaining);



  event Transfer (address indexed _from, address indexed _to, uint256 _value);



  event Approval (address indexed _owner, address indexed _spender, uint256 _value);

}



contract SafeMath {

  uint256 constant private MAX_UINT256 =

  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;



  function safeAdd (uint256 x, uint256 y) constant internal returns (uint256 z) {

    assert (x <= MAX_UINT256 - y);

    return x + y;

  }



  function safeSub (uint256 x, uint256 y) constant internal returns (uint256 z) {

    assert (x >= y);

    return x - y;

  }



  function safeMul (uint256 x, uint256 y)  constant internal  returns (uint256 z) {

    if (y == 0) return 0; // Prevent division by zero at the next line

    assert (x <= MAX_UINT256 / y);

    return x * y;

  }

  

  

   function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;

    return c;

  }

  

}





contract Token is ERC20Token, SafeMath {



  function Token () {

    // Do nothing

  }

 

  function balanceOf (address _owner) constant returns (uint256 balance) {

    return accounts [_owner];

  }



  function transfer (address _to, uint256 _value) returns (bool success) {

    if (accounts [msg.sender] < _value) return false;

    if (_value > 0 && msg.sender != _to) {

      accounts [msg.sender] = safeSub (accounts [msg.sender], _value);

      accounts [_to] = safeAdd (accounts [_to], _value);

    }

    Transfer (msg.sender, _to, _value); 

    return true;

  }



  function transferFrom (address _from, address _to, uint256 _value)  returns (bool success) {

    if (allowances [_from][msg.sender] < _value) return false;

    if (accounts [_from] < _value) return false;



    allowances [_from][msg.sender] =

      safeSub (allowances [_from][msg.sender], _value);



    if (_value > 0 && _from != _to) {

      accounts [_from] = safeSub (accounts [_from], _value);

      accounts [_to] = safeAdd (accounts [_to], _value);

    }

    Transfer (_from, _to, _value);

    return true;

  }



 

  function approve (address _spender, uint256 _value) returns (bool success) {

    allowances [msg.sender][_spender] = _value;

    Approval (msg.sender, _spender, _value);

    return true;

  }



  

  function allowance (address _owner, address _spender) constant

  returns (uint256 remaining) {

    return allowances [_owner][_spender];

  }



  /**

   * Mapping from addresses of token holders to the numbers of tokens belonging

   * to these token holders.

   */

  mapping (address => uint256) accounts;



  /**

   * Mapping from addresses of token holders to the mapping of addresses of

   * spenders to the allowances set by these token holders to these spenders.

   */

  mapping (address => mapping (address => uint256)) private allowances;

}





contract MSRiseToken is Token {

    

    address public owner;

    

     

    uint256 tokenCount = 0;

    

    uint256 public bounce_reserve = 0;

    uint256 public partner_reserve = 0;

    uint256 public sale_reserve = 0;

     

    bool frozen = false;

     

    uint256 constant MAX_TOKEN_COUNT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

     

	uint public constant _decimals = (10**18);

	

     

    modifier onlyOwner() {

	    require(owner == msg.sender);

	    _;

	}

     

     function MSRiseToken() {

         owner = msg.sender;

         

         createTokens(5 * (10**25)); // §ã§à§Ù§Õ§Ñ§ß§Ú§Ö 50 §Þ§Ý§ß §ä§à§Ü§Ö§ß§à§Ó

         

         partner_reserve = 5 * (10**24); // §â§Ö§Ù§Ö§â§Ó§Ñ§è§Ú§ñ 5 §Þ§Ý§ß §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ 10% §Õ§Ý§ñ §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó

         bounce_reserve = 1 * (10**24); // §â§Ö§Ù§Ö§â§Ó§Ñ§è§Ú§ñ 1 §Þ§Ý§ß §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §Ò§à§ß§å§ã§ß§à§Û §á§â§à§Ô§â§Ñ§Þ§Þ§í

         

         // §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§ñ §à§Ò§ë§Ö§Ô§à §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§Ñ §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §á§â§à§Õ§Ñ§Ø§Ú (44 §Þ§Ý§ß)

         sale_reserve = safeSub(tokenCount, safeAdd(partner_reserve, bounce_reserve));  

         

         

     }

     

    function totalSupply () constant returns (uint256 _totalSupply) {

        return tokenCount;

    }

     

    function name () constant returns (string result) {

		return "MSRiseToken";

	}

	

	function symbol () constant returns (string result) {

		return "MSRT";

	}

	

	function decimals () constant returns (uint result) {

        return 18;

    }

    

    function transfer (address _to, uint256 _value) returns (bool success) {

        if (frozen) return false;

        else return Token.transfer (_to, _value);

    }



  

  function transferFrom (address _from, address _to, uint256 _value)

    returns (bool success) {

    if (frozen) return false;

    else return Token.transferFrom (_from, _to, _value);

  }



  

  function approve (address _spender, uint256 _currentValue, uint256 _newValue)

    returns (bool success) {

    if (allowance (msg.sender, _spender) == _currentValue)

      return approve (_spender, _newValue);

    else return false;

  }



  function burnTokens (uint256 _value) returns (bool success) {

    if (_value > accounts [msg.sender]) return false;

    else if (_value > 0) {

      accounts [msg.sender] = safeSub (accounts [msg.sender], _value);

      tokenCount = safeSub (tokenCount, _value);

      return true;

    } else return true;

  }





  function createTokens (uint256 _value) returns (bool success) {

    require (msg.sender == owner);



    if (_value > 0) {

      if (_value > safeSub (MAX_TOKEN_COUNT, tokenCount)) return false;

      accounts [msg.sender] = safeAdd (accounts [msg.sender], _value);

      tokenCount = safeAdd (tokenCount, _value);

    }



    return true;

  }





 // §µ§ã§ä§Ñ§ß§à§Ó§Ü§Ñ §ß§à§Ó§à§Ô§à §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ 

 // §Ó§ç§à§Õ§ß§à§Û §á§Ñ§â§Ñ§Þ§Ö§ä§â §Ñ§Õ§â§Ö§ã ETH §Ü§à§ê§Ö§Ý§î§Ü§Ñ 



  function setOwner (address _newOwner) {

    require (msg.sender == owner);



    owner = _newOwner;

  }



  function freezeTransfers () {

    require (msg.sender == owner);



    if (!frozen) {

      frozen = true;

      Freeze ();

    }

  }





  function unfreezeTransfers () {

    require (msg.sender == owner);



    if (frozen) {

      frozen = false;

      Unfreeze ();

    }

  }



  event Freeze ();



  event Unfreeze ();



}





contract MSRiseTokenSale is MSRiseToken  {

 

    address[] balancesKeys;

    mapping (address => uint256) balances;

 

    enum State { PRE_ICO, ICO, STOPPED }

    

    

    // 0 , 1 , 2

    

    State public currentState = State.STOPPED;



    uint public tokenPrice = 50000000000000000;

    uint public _minAmount = 0.05 ether;

	

	mapping (address => uint256) wallets;



    address public beneficiary;



	uint256 public totalSold = 0;

	uint256 public totalBounces = 0;

	

	uint public current_percent = 15;

	uint public current_discount = 0;



	bool private _allowedTransfers = true;

	

	modifier minAmount() {

        require(msg.value >= _minAmount);

        _;

    }

    

    modifier saleIsOn() {

        require(currentState != State.STOPPED && totalSold < sale_reserve);

        _;

    }

    

    modifier isAllowedBounce() {

        require(totalBounces < bounce_reserve);

        _;

    }

    

	function TokenSale() {

	    owner = msg.sender;

	    beneficiary = msg.sender;

	}



	

	// §å§ã§ä§Ñ§ß§à§Ó§Ü§Ñ §ä§Ö§Ü§å§ë§Ö§Ô§à §Ò§à§ß§å§ã§Ñ §Ù§Ñ §á§à§Ü§å§á§Ü§å

	

	function setBouncePercent(uint _percent) public onlyOwner {

	    current_percent = _percent;

	}

	

	function setDiscountPercent(uint _discount) public onlyOwner {

	    current_discount = _discount;

	}

	

	

	// §å§ã§ä§Ñ§ß§à§Ó§Ü§Ñ §ä§Ö§Ü§å§ë§Ö§Û §æ§Ñ§Ù§í §á§â§à§Õ§Ñ§Ø (pre-ico = 0, ico = 1, stopped = 3)

	

	function setState(State _newState) public onlyOwner {

	    currentState = _newState;

	}

	

	// §å§ã§ä§Ñ§ß§à§Ó§Ü§Ñ §Þ§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§à§Û §ã§å§Þ§Þ§í §á§Ý§Ñ§ä§Ö§Ø§Ñ §Ó §ï§æ§Ú§â§Ñ§ç

	

	function setMinAmount(uint _new) public onlyOwner {

	    _minAmount = _new;

	}

	

	// §Ó§à§Ù§à§Ò§ß§à§Ó§Ý§Ö§ß§Ú§Ö §á§Ö§â§Ö§Ó§à§Õ§à§Ó

	

	function allowTransfers() public onlyOwner {

		_allowedTransfers = true;		

	}

	

	// §Ù§Ñ§Þ§à§â§à§Ù§Ü§Ñ §Ó§ã§Ö§ç §á§Ö§â§Ö§Ó§à§Õ§à§Ó

	

	function stopTransfers() public onlyOwner {

		_allowedTransfers = false;

	}

	

	// §æ§å§ß§Ü§è§Ú§ñ §ã§Þ§Ö§ß§í §Ñ§Õ§â§Ö§ã§Ñ ETH §Ü§å§Õ§Ñ §Ò§å§Õ§å§ä §á§à§ã§ä§å§á§Ñ§ä§î §à§ä§á§â§Ñ§Ó§Ý§Ö§ß§ß§í§Ö §ï§æ§Ú§â§í

	

    function setBeneficiaryAddress(address _new) public onlyOwner {

        beneficiary = _new;

    }

    

    // §æ§å§ß§Ü§è§Ú§ñ §å§ã§ä§Ñ§ß§à§Ó§Ü§Ú §ã§ä§à§Ú§Þ§à§ã§ä§Ú §à§Õ§ß§à§Ô§à §ä§à§Ü§Ö§ß§Ñ §Ó wei 

    

    function setTokenPrice(uint _price) public onlyOwner {

        tokenPrice = _price;

    }

    

    // §æ§å§Ü§ß§è§Ú§ñ §ã§á§Ú§ã§Ñ§ß§Ú§ñ §ä§à§Ü§Ö§ß§à§Ó §ã §à§Ò§ë§Ö§Ô§à §Ò§Ñ§Ý§Ñ§ß§ã§Ñ §ß§Ñ §Ò§Ñ§Ý§Ñ§ß§ã §à§ä§á§â§Ñ§Ó§Ú§ä§Ö§Ý§ñ

    

	function transferPayable(address _address, uint _amount) private returns (bool) {

	    accounts[_address] = safeAdd(accounts[_address], _amount);

	    accounts[owner] = safeSub(accounts[owner], _amount);

	    totalSold = safeAdd(totalSold, _amount);

	    return true;

	}

	

	// §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§ñ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ä§à§Ü§Ö§ß§à§Ó, §â§Ñ§Ó§ß§à§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §à§ä§á§â§Ñ§Ó§Ý§Ö§ß§ß§í§ç §ï§æ§Ú§â§à§Ó

	// §Ú§ã§ç§à§Õ§ñ §Ú§Ù §ã§ä§à§Ú§Þ§à§ã§ä§Ú §ä§à§Ü§Ö§ß§Ñ, §Ò§à§ß§å§ã§Ñ §Ú §ã§Ü§Ú§Õ§Ü§Ú

	

	function get_tokens_count(uint _amount) private returns (uint) {

	    

	     uint currentPrice = tokenPrice;

	     uint tokens = safeDiv( safeMul(_amount, _decimals), currentPrice ) ;

	     totalSold = safeAdd(totalSold, tokens);

	     

	     if(currentState == State.PRE_ICO) {

	         tokens = safeAdd(tokens, get_bounce_tokens(tokens)); // §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §á§â§Ú PRE-ICO

	     } else if(currentState == State.ICO) {

	         tokens = safeAdd(tokens, get_discount_tokens(tokens)); // §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §á§â§Ú ICO

	     }

	     

	     return tokens;

	}

	

	// §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§Ö §ä§Ö§Ü§å§ë§Ö§Û §ã§Ü§Ú§Õ§Ü§Ú

	

	function get_discount_tokens(uint _tokens) isAllowedBounce private returns (uint) {

	    

	    uint tokens = 0;

	    uint _current_percent = safeMul(current_discount, 100);

	    tokens = _tokens * _current_percent / 10000;

	    totalBounces = safeAdd(totalBounces, tokens);

	    return tokens;

	    

	}

	

	// §Ó§í§é§Ú§ã§Ý§Ö§ß§Ú§Ö §Ò§à§ß§å§ã§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó

	

	function get_bounce_tokens(uint _tokens) isAllowedBounce() private returns (uint) {

	    uint tokens = 0;

	    uint _current_percent = safeMul(current_percent, 100);

	    tokens = _tokens * _current_percent / 10000;

	    totalBounces = safeAdd(totalBounces, tokens);

	    return tokens;

	}

	

	// §æ§å§ß§Ü§è§Ú§ñ, §Ü§à§ä§à§â§Ñ§ñ §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §á§â§Ú §à§ä§á§â§Ñ§Ó§Ü§Ö §ï§æ§Ú§â§Ñ §ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä

	

	function buy() public saleIsOn() minAmount() payable {

	    uint tokens;

	    tokens = get_tokens_count(msg.value);

		require(transferPayable(msg.sender , tokens));

		if(_allowedTransfers) {

			beneficiary.transfer(msg.value);

			balances[msg.sender] = safeAdd(balances[msg.sender], msg.value);

			balancesKeys.push(msg.sender);

	    }

	}

	

	// §Ó§à§Ù§Ó§â§Ñ§ä §ã§â§Ö§Õ§ã§ä§Ó, §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ö§Þ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ,

	// §Õ§Ý§ñ §Ó§à§Ù§Ó§â§Ñ§ä§Ñ §ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ö §Õ§à§Ý§Ø§ß§í §á§â§Ú§ã§å§ä§ã§ä§Ó§à§Ó§Ñ§ä§î §ï§æ§Ú§â§í

	

	function refund() onlyOwner {

      for(uint i = 0 ; i < balancesKeys.length ; i++) {

          address addr = balancesKeys[i]; 

          uint value = balances[addr];

          balances[addr] = 0; 

          accounts[addr] = 0;

          addr.transfer(value); 

      }

    }

	

	

	function() external payable {

      buy();

    }

	

    

}