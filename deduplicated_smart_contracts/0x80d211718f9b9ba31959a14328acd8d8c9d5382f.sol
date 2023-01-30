pragma solidity ^0.5.1;

//Palmes token

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Owned.sol";
import "./ERC20Detailed.sol";

contract Palmes is ERC20Detailed { 
    
    using SafeMath for uint256; 
    string constant tokenName = "Palmes"; 
    string constant tokenSymbol = "PLM"; 
    uint8 constant tokenDecimals = 6; 
    uint256 _totalSuplly= _initialSupply;
    uint256 _initialSupply = 100000000000;
    
    
     mapping (address => uint256) private _PalmesTokenBalances; 
     mapping (address => mapping (address => uint256)) private _allowed;
//
  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) { _mint(msg.sender, _initialSupply); }
           
            function totalSupply() public view returns (uint256) { return _initialSupply; }

            function balanceOf(address owner) public view returns (uint256) { return _PalmesTokenBalances[owner]; }

            function allowance(address owner, address spender) public view returns (uint256) { return _allowed[owner][spender]; }

            function transfer(address to, uint256 value) public returns (bool) { require(value <= _PalmesTokenBalances[msg.sender]); require(to != address(0));
  

   uint256 PalmesIncrease = value.div(1000000);
   uint256 tokensToTransfer = value.add(0);
   
   
   _PalmesTokenBalances[msg.sender] = _PalmesTokenBalances[msg.sender].sub(value);
   _PalmesTokenBalances[msg.sender] = _PalmesTokenBalances[msg.sender].add(value.div(1000000));
   _PalmesTokenBalances[to] = _PalmesTokenBalances[to].add(tokensToTransfer);
  
   _totalSuplly = _initialSupply.add(PalmesIncrease);

   emit Transfer(msg.sender, to, tokensToTransfer);
   emit Transfer(address(0), address(msg.sender), PalmesIncrease);

   return true;
   }

   function multiTransfer(address[] memory receivers, uint256[] memory amounts) public { for (uint256 i = 0; i < receivers.length; i++) { transfer(receivers[i], amounts[i]); } }

   function approve(address spender, uint256 value) public returns (bool) { require(spender != address(0)); 
   _allowed[msg.sender][spender] = value; 
   emit Approval(msg.sender, spender, value); 
   return true; }

   function transferFrom(address from, address to, uint256 value) public returns (bool) { require(value <= _PalmesTokenBalances[from]); 
   require(value <= _allowed[from][msg.sender]); 
   require(to != address(0));

_PalmesTokenBalances[from] = _PalmesTokenBalances[from].sub(value);

   uint256 PalmesIncrease = value.div(1000000);
   uint256 tokensToTransfer = value.add(0);

_PalmesTokenBalances[to] = _PalmesTokenBalances[to].add(tokensToTransfer);
_initialSupply = _initialSupply.add(PalmesIncrease);

_allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
_allowed[from][msg.sender] = _allowed[from][msg.sender].add(value.div(1000000));

emit Transfer(from, to, tokensToTransfer);
emit Transfer(address(0), address(msg.sender), PalmesIncrease);

return true;
}

function increaseAllowance(address spender, uint256 addedValue) public returns (bool) { require(spender != address(0)); 
_allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue)); 
emit Approval(msg.sender, spender, _allowed[msg.sender][spender]); return true; }

function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) { require(spender != address(0)); 
_allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue)); 
emit Approval(msg.sender, spender, _allowed[msg.sender][spender]); return true; }

function _mint(address account, uint256 amount) internal { require(amount != 0); 
_PalmesTokenBalances[account] = _PalmesTokenBalances[account].add(amount); emit Transfer(address(0), account, amount); }

function create(uint256 amount) external { _create(msg.sender, amount); }

function _create(address account, uint256 amount) internal { require(amount != 0); 
require(amount <= _PalmesTokenBalances[account]);
_totalSuplly = _initialSupply.add(amount); 
_PalmesTokenBalances[account] = _PalmesTokenBalances[account].add(amount); 
emit Transfer(account, address(0), amount); }

function createFrom(address account, uint256 amount) external { require(amount <= _allowed[account][msg.sender]); 
_allowed[account][msg.sender] = _allowed[account][msg.sender].add(amount); 
_create(account, amount); } }