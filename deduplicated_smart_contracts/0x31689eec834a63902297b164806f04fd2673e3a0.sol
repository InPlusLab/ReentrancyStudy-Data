/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

abstract contract Context {
    function _sender() public view virtual returns (address payable) {
        return msg.sender;
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

}


interface IERC20 {
	function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
interface OLDIERC20 {
	function transfer(address recipient, uint amount) external;
    function approve(address spender, uint amount) external;
    function transferFrom(address sender, address recipient, uint amount) external;
	event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


abstract contract ERC20 is Context, IERC20 {
    using SafeMath for uint;
    mapping (address => uint) internal _bal;
    mapping (address => mapping (address => uint)) private _alwnc;
    uint internal _sup;
    string public name;
    string public symbol;
    uint public decimals;
    constructor (string memory _name, string memory _symbol, uint _decimal) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimal;
    }
    function totalSupply() public view override returns (uint) {
        return _sup;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _bal[account];
    }
    function transfer(address recipient, uint amount) public  override returns (bool) {
        _transfer(_sender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view  override returns (uint) {
        return _alwnc[owner][spender];
    }
    function approve(address spender, uint amount) public  override returns (bool) {
        _approve(_sender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public  override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _sender(), _alwnc[sender][_sender()].sub(amount, "ERC20: amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public  returns (bool) {
        _approve(_sender(), spender, _alwnc[_sender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public  returns (bool) {
        _approve(_sender(), spender, _alwnc[_sender()][spender].sub(subtractedValue, "ERC20: decreased allowance < zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) private  {
        require(sender != address(0), "ERC20: !from address");
        require(recipient != address(0), "ERC20: !to address");
        _bal[sender] = _bal[sender].sub(amount, "ERC20: !balance");
        _bal[recipient] = _bal[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint amount) internal  {
        require(account != address(0), "ERC20: 0 address");
        _sup = _sup.add(amount);
        _bal[account] = _bal[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _approve(address owner, address spender, uint amount) private  {
        require(owner != address(0), "ERC20: !from address");
        require(spender != address(0), "ERC20: !to address");
        _alwnc[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

interface Comp {
    function mint ( uint mintAmount ) external returns ( uint );
    function redeem(uint redeemTokens) external returns (uint);
    function exchangeRateStored() external view returns (uint);
}

interface Yfi {
	function deposit(uint _amount) external;
	function withdraw(uint _token) external;
	function getPricePerFullShare() external view returns (uint);
}
interface Aave {
    function deposit(address _reserve, uint _amount, uint16 _referralCode) external;
}
interface AToken {
    function redeem(uint amount) external;
}
interface LendingGateway {
    function getLendingPool() external view returns (address);
}
interface Mfinance {
    function getReferral(address _addr) external view returns(address);
    function setReferral(address _addr,address _referral) external returns(bool);
	function setExp(address _addr, uint _newExp) external;
	function referralOf(address _addr) external view returns(address);
	function getRefPool() external view returns(address);
	function getPrice() external view returns(uint);
}

interface Mfi {
   function cap() external view returns (uint);
   function mint(address account, uint amount) external;
}

abstract contract Lender{
	using SafeMath for uint;
	address internal btoken;
	address internal yfi;
	address internal comp;
	address internal aave;
	address internal aaveToken;
	constructor () public {
	}
	function _yfiBal() internal view returns (uint) {
		return IERC20(yfi).balanceOf(address(this));
	}
	function _yfiValue() internal view returns (uint) {
		uint b = _yfiBal();
		if (b > 0) {
		  b = b.mul(Yfi(yfi).getPricePerFullShare()).div(1e18);
		}
		return b;
	}


	function _yfiWithdraw(uint _amt) internal {
		uint b = _yfiBal();
		uint bT = _yfiValue();
		require(bT >= _amt, "insufficient funds");
		uint amt = (b.mul(_amt)).div(bT).add(1);
		Yfi(yfi).withdraw(amt);
	}
	function _compBalance() internal view returns (uint) {
	  return IERC20(comp).balanceOf(address(this));
	}
	function _compVal() internal view returns (uint) {
		uint b = _compBalance();
		if (b > 0) {
			b = b.mul(Comp(comp).exchangeRateStored()).div(1e18);
		}
		return b;
	}

	function _compWithdraw(uint _amt) internal {
		uint b = _compBalance();
		uint bT = _compVal();
		require(bT >= _amt, "insufficient funds");
		uint amt = (b.mul(_amt)).div(bT).add(1);
		require(Comp(comp).redeem(amt) == 0, "Comp: wd failed");
	}
	function getAave() internal view returns (address) {
		return LendingGateway(aave).getLendingPool();
	}
	function _aaveBalVal() internal view returns (uint) {
		return IERC20(aaveToken).balanceOf(address(this));
	}

}

abstract contract Ownable is Context {
    address payable private _owner;
    constructor () public {
        _owner = _sender();
    }
    function owner() public view returns (address payable) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _sender(), "Ownable: !owner");
        _;
    }

	function inCaseWrongTokenTransfer(address _tokenAddr,uint _type) onlyOwner external {
		require(_tokenAddr != address(this), "Ownable: !address");
        uint qty = IERC20(_tokenAddr).balanceOf(address(this));
		if(_type == 1)
			IERC20(_tokenAddr).transfer(_sender(), qty);
		else
			OLDIERC20(_tokenAddr).transfer(_sender(), qty);
    }
	
    function inCaseWrongEthTransfer() onlyOwner external{
        (bool result, ) = _sender().call{value:address(this).balance}("");
        require(result, "ETH Transfer Failed");
    }
}

abstract contract ReentrancyGuard {
	uint private constant _NOT_ENTERED = 1;
	uint private constant _ENTERED = 2;
	uint private _status;
	constructor () public {
		_status = _NOT_ENTERED;
	}
	modifier nonReentrant() {
		require(_status != _ENTERED, "reentrant call");
		_status = _ENTERED;
		_;
		_status = _NOT_ENTERED;
	}
}


//== Contract ==
contract MUSDC is ERC20,Lender,Ownable,ReentrancyGuard{
	using SafeMath for uint;
	address private multifinance;
	address private mfi;
	uint private _prv1 = 2;
	uint private _prv2 = 3;
	uint public minWd = 100*(10**decimals);
	uint public minDepo = 100*(10**decimals);
	uint public minWd2 = 1000*(10**decimals);
	uint public collTotal; 
	uint private _adminFee; 
	uint public startBlock; 
	mapping (address => uint) private _exp;
	mapping (address => uint) private _coll;
	event ReferralReward(address addr, uint amount);
	
	constructor (address _btoken,address _mfi,address _multifinance) public ERC20("MUsdc Token", "MUSDC", 6) {
		startBlock = block.number;
		btoken = _btoken;
		mfi = _mfi;
		multifinance = _multifinance;
	}
	
	function setMin(uint _min1,uint _min2, uint _min3) external onlyOwner{
		minWd = _min1;
		minDepo = _min2;
		minWd2 = _min3;
	}
	
	function collateralOf(address _addr) external view returns(uint){
		return _coll[_addr];
	}
	function _setExp(address _addr, uint _newExp) internal{
		_exp[_addr] = _newExp;
		Mfinance(multifinance).setExp(_addr,_newExp);
	}
	
	function getExp(address _addr) external view returns(uint){
		return _exp[_addr];
	}
	function getAdminFee() external view onlyOwner returns(uint) {
		return _adminFee;
	}
	
	function getLender(uint _num) external view returns(address){
		if (_num == 1) {
			return yfi;
		} else if (_num == 2) {
			return comp;
		} else if (_num == 3) {
			return aave;
		} else if (_num == 4) {
			return aaveToken;
		}
	}
	function setLender(address _token, uint _num) public onlyOwner{
		if (_num == 1) {
			yfi = _token;
		} else if (_num == 2) {
			comp = _token;
		} else if (_num == 3) {
			aave = _token;
		} else if (_num == 4) {
			aaveToken = _token;
		}
	}
	function approveToken(address _token) public onlyOwner{
		IERC20(btoken).approve(_token, type(uint).max);
	}
	function getPrice() external view returns (uint) {
		uint _pool = _calcPool();
		return _pool.mul(1e18).div(_sup);
	}
	function getProv() external view returns(uint,uint){
		return (_prv1,_prv2);
	}
	
	function _btokenBal() private view returns (uint) {
		return IERC20(btoken).balanceOf(address(this));
	}
 	//== Pool == 	
	function _calcPool() internal view returns (uint) {
		return _proVal(_prv1).add(_proVal(_prv2)).add(_btokenBal()).sub(_adminFee);
	}
	function calcPoolValue() external view returns (uint) {
		return _calcPool();
	}
	function _proVal(uint _prov) private view returns (uint){
		if (_prov == 1) {
			return _yfiValue();
		} else if (_prov == 2) {
			return _compVal();
		} else if (_prov == 3) {
			return _aaveBalVal();
		}
	}
	function _setProVal(uint _prov, uint _amt) private{
		if (_prov == 1) {
			Yfi(yfi).deposit(_amt);
		} else if (_prov == 2) {			
			require(Comp(comp).mint(_amt) == 0, "Comp: supply failed");
		} else if (_prov == 3) {
			Aave(getAave()).deposit(btoken, _amt, 0);
		}
	}
	function _wdProVal(uint _prov, uint _amt) internal{
		if (_prov == 1) {
			_yfiWithdraw(_amt);
		} else if (_prov == 2) {
			_compWithdraw(_amt);
		} else if (_prov == 3) {
			AToken(aaveToken).redeem(_amt);
		}
	}
	
	function wdProVal(uint _prov, uint _amt) external onlyOwner{
		if (_prov == 1) {
			_yfiWithdraw(_amt);
		} else if (_prov == 2) {
			_compWithdraw(_amt);
		} else if (_prov == 3) {
			AToken(aaveToken).redeem(_amt);
		}
	}
	
	function setProv(uint prov1, uint prov2) external onlyOwner{
		_prv1 = prov1;
		_prv2 = prov2;
	}
	
	function _depositPush(uint _amt) private {
		uint v1 = _proVal(_prv1);
		uint v2 = _proVal(_prv2);
		if(v1 <= v2){
			_setProVal(_prv1,_amt);
		}else{
			_setProVal(_prv2,_amt);
		}
	}
	
	function _withdraw(uint _amt) internal {
		uint v1 = _proVal(_prv1);
		uint v2 = _proVal(_prv2);
		require(v1 >= _amt || v2 >= _amt, "!insufficient fund");
		if(v1 >= v2){
			_wdProVal(_prv1,_amt);
		}else{
			_wdProVal(_prv2,_amt);
		}
	}
	
	function _deposit(uint _amt) private nonReentrant
	{
		require(_amt >= minDepo, "!minimum deposit");
		uint pool = _calcPool();
		uint bal = _btokenBal().sub(_adminFee);
		IERC20(btoken).transferFrom(_sender(), address(this), _amt);
		if(_amt >= minWd2*1e6){
			uint amtPush = _amt;
			uint earn = 0;
			if(pool >= collTotal)
				earn = pool - collTotal;
			uint minBal = 0;
			uint addBal = 0;
			if(bal < earn){
				minBal = earn - bal;
			}else{
				addBal = bal - earn;
			}
			
			if(amtPush > minBal){
				amtPush = amtPush - minBal;
			}else {
				amtPush = 0;
			}
			
			amtPush =  amtPush + addBal;
			if(amtPush > 0)
				_depositPush(amtPush);
		}
		_coll[_sender()] = _coll[_sender()].add(_amt);
		collTotal = collTotal.add(_amt);
		uint amt = 0;
		if (pool == 0) {
			amt = _amt;
		} else {
			amt = (_amt.mul(_sup)).div(pool);
		}
		_mint(_sender(), amt);
		if (_exp[_sender()] == 0){
			_setExp(_sender(),now + 30 days);
		}
	}
	
	function depositAll() external  onlyOwner nonReentrant
	{
		uint bal = _btokenBal().sub(_adminFee);
		uint pool = _calcPool();
		uint earn = 0;
		if(pool >= collTotal)
			earn = pool - collTotal;	
		require(bal > earn, "!min WD");
		_depositPush(bal - earn);
	}
	
	
	function depositReg(uint _amt, address _ref) public 
	{
		if(Mfinance(multifinance).setReferral(_sender(),_ref)){
			_deposit(_amt);
		}
	}
	
	function deposit(uint _amt) external 
	{
		address ref = Mfinance(multifinance).referralOf(_sender());
		if(ref == address(0)){
			depositReg(_amt,Mfinance(multifinance).getRefPool());
		}else{
			_deposit(_amt);
		}
	}
	
	function wdC(uint _amt) external nonReentrant
	{
		require(_amt >= minWd, "!min WD");
		uint pool = _calcPool();
		uint _token = (_amt.mul(_sup)).div(pool);
		require(_amt <= _coll[_sender()], "!collateral");
		require(_token <= balanceOf(_sender()), "!balance");
		_bal[_sender()] = _bal[_sender()].sub(_token, "!balance");
		_coll[_sender()] = _coll[_sender()].sub(_amt);
		collTotal = collTotal.sub(_amt);
		_sup = _sup.sub(_token);
		emit Transfer(_sender(), address(0), _token);
		_withdraw(_amt);
		IERC20(btoken).transfer(_sender(), _amt);
	}
	
	function getEarned(address _addr) public view returns(uint){
		uint bal = (balanceOf(_addr).mul(_calcPool())).div(_sup);
		if( bal >= _coll[_addr])
			return bal.sub(_coll[_addr]);
		else
			return 0;
	}
	
	function wdR() external nonReentrant
	{
		require(now >= _exp[_sender()], "!eligible");
		uint pool = _calcPool();
		uint _amt = ((balanceOf(_sender()).mul(pool)).div(_sup)).sub(_coll[_sender()]);
		require(_amt > 0, "zero amount");
		uint _token = (_amt.mul(_sup)).div(pool);
		require(_token <= balanceOf(_sender()), "!balance");
		_bal[_sender()] = _bal[_sender()].sub(_token, "!balance");
		_sup = _sup.sub(_token);
		emit Transfer(_sender(), address(0), _token);
		if(_amt > _btokenBal()){
			_withdraw(_amt);
		}
		uint  a1 = (_amt.mul(80)).div(100);
		uint  a2 = (_amt.mul(10)).div(100);
		IERC20(btoken).transfer(_sender(), a1);
		address referrer = Mfinance(multifinance).getReferral(_sender());
		IERC20(btoken).transfer(referrer, a2);
		emit ReferralReward(referrer, a2);
		_adminFee = _adminFee.add( _amt.sub(a1).sub(a2));
		uint mfiprice = Mfinance(multifinance).getPrice();
		uint mfisup = IERC20(mfi).totalSupply();
		uint cap = uint(30000).mul(1e18);
		if(mfisup < cap){
			uint avail = cap.sub(mfisup);
			uint reqmint = a1.mul(1e12).mul(1e18).div(mfiprice);
			if(reqmint >= avail)
				reqmint = avail;
			Mfi(mfi).mint(_sender(), reqmint);
		}
		_setExp(_sender(),now + 30 days);
	}
	
	function wdAdm() external onlyOwner{
		require(_adminFee > 0, "!insufficient balance");
		IERC20(btoken).transfer(_sender(),_adminFee);
		_adminFee = 0;
	}
	
	receive() external payable {
    }
	
	function setExp(address _addr, uint _newExp) external onlyOwner{
		_setExp(_addr,_newExp);
	}
}