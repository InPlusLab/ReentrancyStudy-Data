/**

 *Submitted for verification at Etherscan.io on 2019-06-10

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



  string private _name;

  string private _symbol;

  uint8 private _decimals;



  constructor(string memory name, string memory symbol, uint8 decimals) public {

    _name = name;

    _symbol = symbol;

    _decimals = decimals;

  }



  function name() public view returns(string memory) {

    return _name;

  }



  function symbol() public view returns(string memory) {

    return _symbol;

  }



  function decimals() public view returns(uint8) {

    return _decimals;

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



contract Bomb is ERC20Detailed {



  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;



  string constant tokenName = "BOMB";

  string constant tokenSymbol = "BOMB";

  uint8  constant tokenDecimals = 0;

  uint256 _totalSupply;

  uint256 public basePercent;



  function totalSupply() public view returns (uint256);



  function balanceOf(address owner) public view returns (uint256);

  

  function allowance(address owner, address spender) public view returns (uint256);



  function findOnePercent(uint256 value) public view returns (uint256);



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



contract WrappedBOMBv3 is ERC20Detailed, Owned {

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  

  Bomb BOMBcontract;

  string constant tokenName = "Wrapped-BOMB";

  string constant tokenSymbol = "W-BOMB";

  uint8  constant tokenDecimals = 18;

  uint256 _totalSupply;

  

  event  Deposit(address indexed dst, uint value);

  event  Withdrawal(address indexed src, uint value);

  

  // DO NOT SEND BOMBs DIRECTLY TO THIS CONTRACT. Only use the deposit(amount) function to deposit BOMBs.

  // You must give this contract an allowance from the original BOMB contract to be able to deposit BOMBs.

  function deposit(uint256 amount) public {

      require(amount > 0);

      uint supplyBeforeDeposit = BOMBcontract.balanceOf(address(this));

      require(BOMBcontract.transferFrom(msg.sender, address(this), amount));

      uint supplyAfterDeposit = BOMBcontract.balanceOf(address(this));

      assert(supplyAfterDeposit > supplyBeforeDeposit);

      uint depositAmount = supplyAfterDeposit - supplyBeforeDeposit;

      uint depositValue = depositAmount * (10**18);

      _balances[msg.sender] = _balances[msg.sender] + depositValue;

      _totalSupply = _totalSupply + depositValue;

      emit Deposit(msg.sender, amount);

  }

  

  // Use the withdraw(amount) function to withdraw BOMBS.

  // You can only withdraw whole bombs. No decimals.

  function withdraw(uint256 amount) public {

      require(amount > 0);

      require(amount < 10**6);

      uint withdrawValue = amount * (10**18);

      require(_balances[msg.sender] >= withdrawValue);

      _balances[msg.sender] = _balances[msg.sender] - withdrawValue;

      assert(BOMBcontract.transfer(msg.sender, amount));

      _totalSupply = _totalSupply - withdrawValue;

      emit Withdrawal(msg.sender, amount);

  }

  

  constructor() public payable ERC20Detailed("Wrapped-BOMB", "W-BOMB", 18) {

      _totalSupply = 0;

      BOMBcontract = Bomb(0x1C95b093d6C236d3EF7c796fE33f9CC6b8606714);

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

  

  // Use this to transfer your W-BOMBs.

  // You may transfer fractional W-BOMBs.

  // Fee is 0.1% of each transfer.

  function transfer(address to, uint256 value) public returns (bool) {

    require(value > 0);

    require(value <= _balances[msg.sender]);

    require(to != address(0));

    

    uint fee = value / 1000;

    

    _balances[msg.sender] = _balances[msg.sender] - value;

    _balances[to] = _balances[to] + value - fee;

    _balances[owner] = _balances[owner] + fee;



    emit Transfer(msg.sender, to, value - fee);

    emit Transfer(msg.sender, owner, fee);

    return true;

  }

  

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {

    for (uint256 i = 0; i < receivers.length; i++) {

      transfer(receivers[i], amounts[i]);

    }

  }

  

  function approve(address spender, uint256 value) public returns (bool) {

    require(value >= 0);

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

    

    uint fee = value / 1000;

    

    _balances[from] = _balances[from] - value;



    _balances[to] = _balances[to] + value - fee;

    _balances[owner] = _balances[owner] + fee;



    _allowed[from][msg.sender] = _allowed[from][msg.sender] - value;



    emit Transfer(from, to, value - fee);

    emit Transfer(from, owner, fee);

    return true;

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

  // DO NOT SEND TOKEN DIRECTLY TO THIS CONTRACT.

  // Use the deposit(amount) function to deposit BOMBs.

  function transferIERC20(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

      if (tokenAddress == address(0x1C95b093d6C236d3EF7c796fE33f9CC6b8606714)) {

          uint balanceOfContract = BOMBcontract.balanceOf(address(this)) * (10**18);

          assert(balanceOfContract >= _totalSupply);

          require(tokens <= balanceOfContract - _totalSupply);

          return BOMBcontract.transfer(owner, tokens);

      }

      IERC20 ierc20Contract = IERC20(tokenAddress);

      return ierc20Contract.transfer(owner, tokens);

  }

  

  function () payable external {

      revert();

  }

  

  // Owner may withdraw any ETH from this contract.

  function withdrawETH() public onlyOwner {

      owner.transfer(address(this).balance);

  }

}