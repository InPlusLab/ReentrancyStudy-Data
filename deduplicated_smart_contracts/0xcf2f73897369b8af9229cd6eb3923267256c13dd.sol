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

         

         createTokens(5 * (10**25)); // ���٧էѧߧڧ� 50 �ާݧ� ���ܧ֧ߧ��

         

         partner_reserve = 5 * (10**24); // ��֧٧֧�ӧѧ�ڧ� 5 �ާݧ� ���ܧ֧ߧ�� �էݧ� 10% �էݧ� �ڧߧӧ֧������

         bounce_reserve = 1 * (10**24); // ��֧٧֧�ӧѧ�ڧ� 1 �ާݧ� ���ܧ֧ߧ�� �էݧ� �ҧ�ߧ��ߧ�� ����ԧ�ѧާާ�

         

         // �ӧ��ڧ�ݧ֧ߧڧ� ��ҧ�֧ԧ� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ�� �էݧ� ����էѧا� (44 �ާݧ�)

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





 // �����ѧߧ�ӧܧ� �ߧ�ӧ�ԧ� �ӧݧѧէ֧ݧ��� �ܧ�ߧ��ѧܧ�� 

 // �ӧ��էߧ�� ��ѧ�ѧާ֧�� �ѧէ�֧� ETH �ܧ��֧ݧ�ܧ� 



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



	

	// ����ѧߧ�ӧܧ� ��֧ܧ��֧ԧ� �ҧ�ߧ��� �٧� ���ܧ��ܧ�

	

	function setBouncePercent(uint _percent) public onlyOwner {

	    current_percent = _percent;

	}

	

	function setDiscountPercent(uint _discount) public onlyOwner {

	    current_discount = _discount;

	}

	

	

	// ����ѧߧ�ӧܧ� ��֧ܧ��֧� ��ѧ٧� ����էѧ� (pre-ico = 0, ico = 1, stopped = 3)

	

	function setState(State _newState) public onlyOwner {

	    currentState = _newState;

	}

	

	// ����ѧߧ�ӧܧ� �ާڧߧڧާѧݧ�ߧ�� ���ާާ� ��ݧѧ�֧ا� �� ���ڧ�ѧ�

	

	function setMinAmount(uint _new) public onlyOwner {

	    _minAmount = _new;

	}

	

	// �ӧ�٧�ҧߧ�ӧݧ֧ߧڧ� ��֧�֧ӧ�է��

	

	function allowTransfers() public onlyOwner {

		_allowedTransfers = true;		

	}

	

	// �٧ѧާ���٧ܧ� �ӧ�֧� ��֧�֧ӧ�է��

	

	function stopTransfers() public onlyOwner {

		_allowedTransfers = false;

	}

	

	// ���ߧܧ�ڧ� ��ާ֧ߧ� �ѧէ�֧�� ETH �ܧ�է� �ҧ�է�� �������ѧ�� �����ѧӧݧ֧ߧߧ�� ���ڧ��

	

    function setBeneficiaryAddress(address _new) public onlyOwner {

        beneficiary = _new;

    }

    

    // ���ߧܧ�ڧ� ����ѧߧ�ӧܧ� ����ڧާ���� ��էߧ�ԧ� ���ܧ֧ߧ� �� wei 

    

    function setTokenPrice(uint _price) public onlyOwner {

        tokenPrice = _price;

    }

    

    // ���ܧߧ�ڧ� ���ڧ�ѧߧڧ� ���ܧ֧ߧ�� �� ��ҧ�֧ԧ� �ҧѧݧѧߧ�� �ߧ� �ҧѧݧѧߧ� �����ѧӧڧ�֧ݧ�

    

	function transferPayable(address _address, uint _amount) private returns (bool) {

	    accounts[_address] = safeAdd(accounts[_address], _amount);

	    accounts[owner] = safeSub(accounts[owner], _amount);

	    totalSold = safeAdd(totalSold, _amount);

	    return true;

	}

	

	// �ӧ��ڧ�ݧ֧ߧڧ� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ��, ��ѧӧߧ�� �ܧ�ݧڧ�֧��ӧ� �����ѧӧݧ֧ߧߧ�� ���ڧ���

	// �ڧ���է� �ڧ� ����ڧާ���� ���ܧ֧ߧ�, �ҧ�ߧ��� �� ��ܧڧէܧ�

	

	function get_tokens_count(uint _amount) private returns (uint) {

	    

	     uint currentPrice = tokenPrice;

	     uint tokens = safeDiv( safeMul(_amount, _decimals), currentPrice ) ;

	     totalSold = safeAdd(totalSold, tokens);

	     

	     if(currentState == State.PRE_ICO) {

	         tokens = safeAdd(tokens, get_bounce_tokens(tokens)); // �ӧ�٧�ӧѧ֧��� ���� PRE-ICO

	     } else if(currentState == State.ICO) {

	         tokens = safeAdd(tokens, get_discount_tokens(tokens)); // �ӧ�٧�ӧѧ֧��� ���� ICO

	     }

	     

	     return tokens;

	}

	

	// �ӧ��ڧ�ݧ֧ߧڧ� ��֧ܧ��֧� ��ܧڧէܧ�

	

	function get_discount_tokens(uint _tokens) isAllowedBounce private returns (uint) {

	    

	    uint tokens = 0;

	    uint _current_percent = safeMul(current_discount, 100);

	    tokens = _tokens * _current_percent / 10000;

	    totalBounces = safeAdd(totalBounces, tokens);

	    return tokens;

	    

	}

	

	// �ӧ��ڧ�ݧ֧ߧڧ� �ҧ�ߧ��ߧ�� ���ܧ֧ߧ��

	

	function get_bounce_tokens(uint _tokens) isAllowedBounce() private returns (uint) {

	    uint tokens = 0;

	    uint _current_percent = safeMul(current_percent, 100);

	    tokens = _tokens * _current_percent / 10000;

	    totalBounces = safeAdd(totalBounces, tokens);

	    return tokens;

	}

	

	// ���ߧܧ�ڧ�, �ܧ����ѧ� �ӧ�٧�ӧѧ֧��� ���� �����ѧӧܧ� ���ڧ�� �ߧ� �ܧ�ߧ��ѧܧ�

	

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

	

	// �ӧ�٧ӧ�ѧ� ���֧է���, �ӧ�٧�ӧѧ֧��� �ӧݧѧէ֧ݧ��֧� �ܧ�ߧ��ѧܧ��,

	// �էݧ� �ӧ�٧ӧ�ѧ�� �ߧ� �ܧ�ߧ��ѧܧ�� �է�ݧاߧ� ���ڧ�����ӧ�ӧѧ�� ���ڧ��

	

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