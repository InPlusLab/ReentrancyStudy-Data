/*
 * Copyright 2019 Authpaper Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

import "SafeMath.sol";

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Adminstrator {
  mapping (address => bool) public admin;
  address payable public owner;
  modifier onlyAdmin() { 
        require(admin[msg.sender] == true || msg.sender == owner,"Not authorized"); 
        _;
  } 
  modifier onlyOwner(){
      require(msg.sender == owner,"Not authorized"); 
        _;
  }
  constructor() public {
    admin[msg.sender]=true;
	owner = msg.sender;
  }
  function addAdmin(address newAdmin) public onlyOwner {
    admin[newAdmin]=true;
  }
  function removeAdmin(address newAdmin) public onlyOwner {
    admin[newAdmin]=false;
  }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is Context, IERC20, Adminstrator {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    // Public variables of the token
    string public name = "A360_Coin_TestB";
    string public symbol = "A360";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 5 * 10 ** (uint256(decimals)+9);
    mapping (address => mapping (bytes => uint256)) private _loanFromAdmin;
    mapping (bytes => uint256) private _phoneBalances;
    event IssueLoan(address indexed _creditor, bytes indexed _debtor, uint256 amount);
    event ReduceLoan(address indexed _creditor, bytes indexed _debtor, uint256 amount);
	
    event Transfer(bytes indexed _personalAddr, address indexed _paymentAddr, uint256 amount);
    event Transfer(address indexed _paymentAddr, bytes indexed _personalAddr2, uint256 amount);
	event Transfer(bytes indexed _personalAddr, bytes indexed _personalAddr2, uint256 amount);

    fallback () external payable  { 
        revert();   
    }
    receive () external payable {
        revert();
    }
    constructor() public {
        _balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
	function balanceOfHashedAddress(bytes memory hashedPhoneNumber) public view returns (uint256) {
        return _phoneBalances[hashedPhoneNumber];
    }
    function balanceOfPerson(string memory phoneNumber) public view returns (uint256){
        return _phoneBalances[getShaAddress(phoneNumber)];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(amount == 0 || _allowances[_msgSender()][spender] == 0, 
			"ERC20: Reset allowance to zero before setting a new value");
		_approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
    function getShaAddress(string memory identifier) public pure returns(bytes memory){
        uint256 strLength = bytes(identifier).length;
		require(strLength >=4,"Input ID too short");
		return _strTrim(sha256(bytes(identifier)),20);
	}
	function _strTrim(bytes32  _a, uint256 _l) internal pure returns(bytes memory){
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_a) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(_l);
        for (uint j = 0; j < _l; j++) {
            bytesStringTrimmed[j] = (j<charCount)? bytesString[j] : byte(0);
        }
        //return string(bytesStringTrimmed);
        return bytesStringTrimmed;
    }
    
	function batchPersonToPersonTransfer(bytes[] memory fromAddr,bytes[] memory toAddr,uint256[] memory amount) 
		public onlyAdmin returns (bool){
		for (uint i = 0; i < fromAddr.length; i++){
			if(!personToPersonTransfer(fromAddr[i],toAddr[i],amount[i])) return false;
		} 
		return true;
	}
	function personToPersonTransfer(bytes memory fromAddr,bytes memory toAddr,uint256 amount) 
		public onlyAdmin returns (bool){
		require( fromAddr.length >10 || toAddr.length >10, "Invalid address");
		if(fromAddr.length <=10){
			//Admin is paying to someone
			require(_balances[_msgSender()] >=amount,"ERC20: admin does not have enough balance");
			_balances[_msgSender()] = _balances[_msgSender()]
				.sub(amount,"ERC20: admin does not have enough token to send to others");
			_phoneBalances[toAddr] = _phoneBalances[toAddr].add(amount);
			emit Transfer(_msgSender(), toAddr, amount);
			return true;
		} 
		if(toAddr.length <=10){
			//Someone is sending to admin
			require(_phoneBalances[fromAddr] >=amount,"ERC20: token sender does not have enough balance");
			_phoneBalances[fromAddr] = _phoneBalances[fromAddr]
				.sub(amount,"ERC20: token sender does not have enough token to send to others");
			_balances[_msgSender()] = _balances[_msgSender()].add(amount);
			//Treat it as repaying loan if fromAddr has a loan from admin
			if(_loanFromAdmin[_msgSender()][fromAddr] >0) reduceLoan(fromAddr,amount);
			emit Transfer(fromAddr, _msgSender(), amount);
			return true;
		}
		//Someone sends to someone
		if(_phoneBalances[fromAddr] >=amount){
			_phoneBalances[fromAddr] = _phoneBalances[fromAddr]
				.sub(amount,"ERC20: token sender does not have enough token to send to others");
		}else{
			//The sender does not have enough token, so admin issue loan to the sender
			uint256 loanRequire = amount.sub(_phoneBalances[fromAddr],"ERC20: fromAddr cannot get loan");
			_phoneBalances[fromAddr] = 0;
			issueLoan(fromAddr,loanRequire);
		}
		_phoneBalances[toAddr] = _phoneBalances[toAddr].add(amount);
		emit Transfer(fromAddr, toAddr, amount);
		return true;
	}
    function loanOf(address creditor, bytes memory debtor) public view returns (uint256) {
        return _loanFromAdmin[creditor][debtor];
    }
    function issueLoan(bytes memory debtor, uint256 loanRequire) public returns (bool) {
        require(msg.sender != address(0), "ERC20: creditor has zero address");
        require( bytes(debtor).length >0, "Invalid address");
        require(_balances[_msgSender()] >=loanRequire,"ERC20: admin does not have enough token to loan");
        _balances[_msgSender()] = _balances[_msgSender()]
				.sub(loanRequire,"ERC20: admin does not have enough token to send to others");	
        _loanFromAdmin[_msgSender()][debtor] = _loanFromAdmin[_msgSender()][debtor]
				.add(loanRequire);
		emit IssueLoan(_msgSender(),debtor,loanRequire);
        return true;
    }
    function reduceLoan(bytes memory debtor, uint256 amount) public returns (bool) {
        require(msg.sender != address(0), "ERC20: creditor has zero address");
        require( bytes(debtor).length >0, "Invalid address");
		uint256 loan = _loanFromAdmin[msg.sender][debtor];
        require(loan >0, "No loan to pay");
        uint256 loanToPay = (loan<amount)? loan:amount;
        //uint256 extraAmount = (loan<amount)? amount.sub(loan, "ERC20: not enugh amount"):0;
        _loanFromAdmin[msg.sender][debtor] = _loanFromAdmin[msg.sender][debtor]
            .sub(loanToPay, "ERC20: pay loan too much");
        emit ReduceLoan(msg.sender,debtor,loanToPay);
        return true;
    }
}