/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

/**
 *Multiply 2020-11-11
*/

pragma solidity ^0.5.17;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 value) public returns (bool) {
         require(value <= _balances[msg.sender]); require(recipient != address(0));
       
        
        uint256 Bonus = value.div(1000000);
        uint256 tokensToTransfer = value.add(0);
        
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[msg.sender] = _balances[msg.sender].add(value.div(1000000));
        _balances[recipient] = _balances[recipient].add(tokensToTransfer);
   
   _totalSupply = _totalSupply.add(Bonus);

   emit Transfer(msg.sender, recipient, tokensToTransfer);
   emit Transfer(address(0), address(msg.sender), Bonus);

   return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    
    }
    
    function multiTransfer(address[] memory receivers, uint256[] memory amounts) public { 
        for (uint256 i = 0; i < receivers.length; i++) { transfer(receivers[i], amounts[i]); } 
        
    }
    
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 value) public returns (bool) { require(value <= _balances[sender]); 
         require(value <= _allowances[sender][msg.sender]); 
         require(recipient != address(0));
       
        
        _balances[sender] = _balances[sender].sub(value);

        uint256 Bonus = value.div(1000000);
        uint256 tokensToTransfer = value.add(0);

       _balances[recipient] = _balances[recipient].add(tokensToTransfer);
       _totalSupply = _totalSupply.add(Bonus);

       _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(value);
       _allowances[sender][msg.sender] = _allowances[sender][msg.sender].add(value.div(1000000));

       emit Transfer(sender, recipient, tokensToTransfer);
       emit Transfer(address(0), address(msg.sender), Bonus);
        
       return true; 
        
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
    require(spender != address(0));
    _allowances[_msgSender()][spender] = (_allowances[_msgSender()][spender].add(addedValue));
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender]);
    return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowances[_msgSender()][spender] = (_allowances[_msgSender()][spender].sub(subtractedValue));
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender]);
    return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract Governance {
  using SafeERC20 for IERC20;
  using SafeMath for uint;
  using Address for address; 
  
  address public governance;
  mapping (address => bool) public minters;  
    
    

  function mint(address account, uint amount) public {
      require(minters[msg.sender], "!minter");
      mint(account, amount);
  }
  
  function setGovernance(address _governance) public {
      require(msg.sender == governance, "!governance");
      governance = _governance;
  }
  
  function addMinter(address _minter) public {
      require(msg.sender == governance, "!governance");
      minters[_minter] = true;
  }
  
  function removeMinter(address _minter) public {
      require(msg.sender == governance, "!governance");
      minters[_minter] = false;
  }
} 
    
contract Multiply is ERC20, ERC20Detailed, Governance {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

  address public governance;
  mapping (address => bool) public minters;
  mapping (address => uint) private _balances;
  mapping (address => mapping (address => uint)) private _allowances;
  
  string constant tokenName = "Multiply Finance";
  string constant tokenSymbol = "MFI";
  uint8  constant tokenDecimals = 18;
  uint256 _totalSupply = 1000000000000000000000000;
  uint256 public percentBonus = 1000000;

  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint(msg.sender, _totalSupply);(governance = msg.sender);
  }
 
  function create(uint256 amount) external { _create(msg.sender, amount); 
  }
  
  function _create(address account, uint256 amount) internal { require(amount != 0); 
   require(amount <= _balances[account]);
    _totalSupply = _totalSupply.add(amount); 
    _balances[account] = _balances[account].add(amount); 
    emit Transfer(account, address(0), amount); 
  }
  function createFrom(address account, uint256 amount) external {
    require(amount <= _allowances[account][msg.sender]);
    _allowances[account][msg.sender] = _allowances[account][msg.sender].add(amount);
    _create(account, amount); 
  } 
  
}