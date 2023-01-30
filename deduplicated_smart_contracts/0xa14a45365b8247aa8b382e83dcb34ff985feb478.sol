/**

 *Submitted for verification at Etherscan.io on 2019-06-12

*/



pragma solidity ^0.5.0;



interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);



  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract ERC20Detailed is IERC20 {



  uint8 private _Tokendecimals;

  string private _Tokenname;

  string private _Tokensymbol;



  constructor(string memory name, string memory symbol, uint8 decimals) public {

   

   _Tokendecimals = decimals;

    _Tokenname = name;

    _Tokensymbol = symbol;

    

  }



  function name() public view returns(string memory) {

    return _Tokenname;

  }



  function symbol() public view returns(string memory) {

    return _Tokensymbol;

  }



  function decimals() public view returns(uint8) {

    return _Tokendecimals;

  }

}



contract Owned {

    address payable public owner;

    address payable public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address payable _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }

}



contract Nuke is ERC20Detailed {



  mapping (address => uint256) private _HalflifeTokenBalances;

  mapping (address => mapping (address => uint256)) private _allowed;

  string constant tokenName = "HalfLife";

  string constant tokenSymbol = "NUKE";

  uint8  constant tokenDecimals = 18;

  uint256 _totalSupply;

 

  function totalSupply() public view returns (uint256);



  function balanceOf(address owner) public view returns (uint256);



  function allowance(address owner, address spender) public view returns (uint256);



  function transfer(address to, uint256 value) public returns (bool);



  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public;



  function approve(address spender, uint256 value) public returns (bool);



  function transferFrom(address from, address to, uint256 value) public returns (bool);



  function increaseAllowance(address spender, uint256 addedValue) public returns (bool);



  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool);



  function _mint(address account, uint256 amount) internal;



  function burn(uint256 amount) external;



  function _burn(address account, uint256 amount) internal;



  function burnFrom(address account, uint256 amount) external;

}



contract WrappedNUKE is ERC20Detailed, Owned {

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  

  Nuke NUKEcontract;

  string constant tokenName = "Wrapped-HalfLife";

  string constant tokenSymbol = "W-NUKE";

  uint8  constant tokenDecimals = 18;

  uint256 _totalSupply;

  bool feeless;

  

  event  Deposit(address indexed dst, uint value);

  event  Withdrawal(address indexed src, uint value);

  

  //Use this to deposit a whole number of NUKEs

  function depositWholeNUKEs(uint256 amount) public {

      require(amount < 1000000);

      depositDecimalNUKEs(amount * (10**18));

  }

  

  //Use this to deposit fractional NUKEs where 1 "amount" is 1/10^18 NUKEs 

  function depositDecimalNUKEs(uint256 amount) public {

      require(amount > 0);

      require(amount < (10 ** 24));

      uint supplyBeforeDeposit = NUKEcontract.balanceOf(address(this));

      require(NUKEcontract.transferFrom(msg.sender, address(this), amount));

      uint supplyAfterDeposit = NUKEcontract.balanceOf(address(this));

      assert(supplyAfterDeposit > supplyBeforeDeposit);

      uint depositValue = supplyAfterDeposit - supplyBeforeDeposit;

      _balances[msg.sender] = _balances[msg.sender] + depositValue;

      _totalSupply = _totalSupply + depositValue;

      emit Deposit(msg.sender, amount);

  }

  

  //Use this to withdraw a whole number of NUKEs

  function withdrawWholeNUKEs(uint256 amount) public {

      require(amount < 1000000);

      withdrawDecimalNUKEs(amount * (10**18));

  }

  

  //Use this to withdraw fractional NUKEs where 1 "amount" is 1/10^18 NUKEs

  function withdrawDecimalNUKEs(uint256 amount) public {

      require(amount > 0);

      require(amount < (10**24));

      require(_balances[msg.sender] >= amount);

      _balances[msg.sender] = _balances[msg.sender] - amount;

      assert(NUKEcontract.transfer(msg.sender, amount));

      _totalSupply = _totalSupply - amount;

      emit Withdrawal(msg.sender, amount);

  }

  

  constructor() public payable ERC20Detailed("Wrapped-HalfLife", "W-NUKE", 18) {

      _totalSupply = 0;

      feeless = false;

      NUKEcontract = Nuke(0xc58c0Fca06908E66540102356f2E91edCaEB8D81);

  }

  

  function totalSupply() public view returns (uint256) {

    return _totalSupply;

  }



  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];

  }



  function allowance(address owner, address spender) public view returns (uint256) {

    return _allowed[owner][spender];

  }

  

  // Use this to transfer your W-NUKEs.

  function transfer(address to, uint256 value) public returns (bool) {

    require(value > 0);

    require(value <= _balances[msg.sender]);

    require(to != address(0));

    

    if (feeless) {

      _balances[msg.sender] = _balances[msg.sender] - value;

      _balances[to] = _balances[to] + value;

      emit Transfer(msg.sender, to, value);

      return true;

      

    } else {

      uint fee = value / 1000;

    

      _balances[msg.sender] = _balances[msg.sender] - value;

      _balances[to] = _balances[to] + value - fee;

      _balances[owner] = _balances[owner] + fee;



      emit Transfer(msg.sender, to, value - fee);

      emit Transfer(msg.sender, owner, fee);

      return true;

    }

  }

  

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {

    for (uint256 i = 0; i < receivers.length; i++) {

      transfer(receivers[i], amounts[i]);

    }

  }

  

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));

    _allowed[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);

    return true;

  }

  

  function transferFrom(address from, address to, uint256 value) public returns (bool) {

    require(value > 0);

    require(value <= _balances[from]);

    require(value <= _allowed[from][msg.sender]);

    require(to != address(0));

    

    

    if (feeless) {

        _balances[from] = _balances[from] - value;

        _balances[to] = _balances[to] + value;

        _allowed[from][msg.sender] = _allowed[from][msg.sender] - value;

        emit Transfer(from, to, value);

        return true;

        

    } else {

        uint fee = value / 1000;

    

        _balances[from] = _balances[from] - value;



        _balances[to] = _balances[to] + value - fee;

        _balances[owner] = _balances[owner] + fee;



        _allowed[from][msg.sender] = _allowed[from][msg.sender] - value;



        emit Transfer(from, to, value - fee);

        emit Transfer(from, owner, fee);

        return true;

    }

    

  }

  

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

    require(addedValue > 0);

    require(spender != address(0));

    uint allowedBefore = _allowed[msg.sender][spender];

    _allowed[msg.sender][spender] = _allowed[msg.sender][spender] + addedValue;

    uint allowedAfter = _allowed[msg.sender][spender];

    if (allowedAfter < allowedBefore) {

        _allowed[msg.sender][spender] = 10**77;

    }

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }

  

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

    require(subtractedValue > 0);

    require(spender != address(0));

    uint allowedBefore = _allowed[msg.sender][spender];

    _allowed[msg.sender][spender] = _allowed[msg.sender][spender] - subtractedValue;

    uint allowedAfter = _allowed[msg.sender][spender];

    if (allowedAfter > allowedBefore) {

        _allowed[msg.sender][spender] = 0;

    }

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }

  

  function burn(uint256 amount) external {

    _burn(msg.sender, amount);

  }



  function _burn(address account, uint256 amount) internal {

    require(amount != 0);

    require(amount <= _balances[account]);

    _totalSupply = _totalSupply - amount;

    _balances[account] = _balances[account] - amount;

    emit Transfer(account, address(0), amount);

  }



  function burnFrom(address account, uint256 amount) external {

    require(amount <= _allowed[account][msg.sender]);

    _allowed[account][msg.sender] = _allowed[account][msg.sender] - amount;

    _burn(account, amount);

  }

  

  // Owner may transfer out any accidentally sent tokens. 

  // DO NOT SEND TOKENS DIRECTLY TO THIS CONTRACT.

  // Use the deposit functions to deposit NUKEs.

  function transferIERC20(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

      if (tokenAddress == address(0xc58c0Fca06908E66540102356f2E91edCaEB8D81)) {

          uint balanceOfContract = NUKEcontract.balanceOf(address(this));

          assert(balanceOfContract >= _totalSupply);

          require(tokens <= balanceOfContract - _totalSupply);

          return NUKEcontract.transfer(owner, tokens);

      } else {

          IERC20 ierc20Contract = IERC20(tokenAddress);

          return ierc20Contract.transfer(owner, tokens);

      }

      

  }

  

  //This contract has a 0.1% fee for transfer of W-NUKEs

  //Send 0.01 ETH to this contract to permanently make this contract feeless for everyone

  function () payable external {

      if (feeless) return;

      if (msg.value >= 10000000000000000) {

          feeless = true;

      }

  }

  

  // Owner may withdraw any ETH from this contract.

  function withdrawETH() public onlyOwner {

      owner.transfer(address(this).balance);

  }

}