// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;




//== libs ==	
import "./safemath.sol";
import "./erc20.sol";
import "./lender.sol";
import "./ownable.sol";
import "./reentrancyguard.sol";


//== Contract ==
contract MDAI is ERC20,Lender,Ownable,ReentrancyGuard{
	using SafeMath for uint;
	address private multifinance;
	address private mfi;
	uint private _prv1 = 1;
	uint private _prv2 = 3;
	uint public minWd = 10*(10**decimals);
	uint public minDepo = 10*(10**decimals);
	uint public minWd2 = 20*(10**decimals);
	uint public startBlock; 
	mapping (address => uint) private _exp;
	mapping (address => uint) private _coll;
	
	event ReferralReward(address addr, uint amount);
	
	constructor () public ERC20("MDai Token", "MDAI", 18) {
		startBlock = block.number;
		
		btoken = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
		mfi = address(0x40098A16C4b9227B0cffe3eaA082b0baF1f02109);
		multifinance = address(0xcEa1c4d14044bf30DB8005534D071f0228C09102);
		
		setLender(address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643),2);
		approveToken(address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643));
		
		setLender(address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8),3);
		setLender(address(0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d),6);
		approveToken(address(0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3));
		
		approveToken(address(0x493C57C4763932315A328269E1ADaD09653B9081));
		
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
	
	function getLender(uint _num) external view returns(address){
		if (_num == 1) {
			return yfi;
		} else if (_num == 2) {
			return comp;
		} else if (_num == 3) {
			return aave;
		} else if (_num == 4) {
			return address(0);
		} else if (_num == 5) {
			return ful;
		}else if (_num == 6) {
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
		} else if (_num == 5) {
			ful = _token;
		} else if (_num == 6) {
			aaveToken = _token;
		}
	}
	function approveToken(address _token) public onlyManager{
		IERC20(btoken).approve(_token, type(uint).max);
	}
	function getPrice() external view returns (uint) {
		uint _pool = _calcPool();
		return _pool.mul(1e18).div(_sup);
	}
	function prov1() external view returns(uint){
		return _prv1;
	}
	function prov2() external view returns(uint){
		return _prv2;
	}
	
	function _btokenBal() private view returns (uint) {
		return IERC20(btoken).balanceOf(address(this));
	}
 	//== Pool == 	
	function _calcPool() internal view returns (uint) {
		return _proVal(_prv1).add(_proVal(_prv2)).add(_btokenBal());
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
		} else if (_prov == 5) {
			return _fulVal();
		}
	}
	function _setProVal(uint _prov) private{
		if (_prov == 1) {
			_yfiSup(_btokenBal());
		} else if (_prov == 2) {			
			_compSup(_btokenBal());
		} else if (_prov == 3) {
			_aavSup(_btokenBal());
		} else if (_prov == 5) {
			_fulSup(_btokenBal());
		}
	}
	function _wdProVal(uint _prov, uint _amt) internal{
		if (_prov == 1) {
			_yfiWithdraw(_amt);
		} else if (_prov == 2) {
			_compWithdraw(_amt);
		} else if (_prov == 3) {
			_aaveWd(_amt);
		} else if (_prov == 5) {
			_fulWithdraw(_amt);
		}
	}
	
	function wdProVal(uint _prov, uint _amt) external onlyManager{
		if (_prov == 1) {
			_yfiWithdraw(_amt);
		} else if (_prov == 2) {
			_compWithdraw(_amt);
		} else if (_prov == 3) {
			_aaveWd(_amt);
		} else if (_prov == 5) {
			_fulWithdraw(_amt);
		}
	}
	
	function setProv(uint _prov1, uint _prov2) external onlyManager{
		_prv1 = _prov1;
		_prv2 = _prov2;
	}
	function updateProv(uint _num, uint _new) external nonReentrant onlyManager{
		uint oldProv;
		if(_num == 1){
			oldProv = _prv1;
			_prv1 = _new;
		}else{
			oldProv = _prv2;
			_prv2 = _new;
		}
		uint _amt;
		if (oldProv == 1) {
			_amt = _yfiValue();
			_yfiWithdraw(_amt);
		} else if (oldProv == 2) {
			_amt = _compVal();
			_compWithdraw(_amt);
		} else if (oldProv == 3) {
			_amt = _aaveBalVal();
			_aaveWd(_amt);
		} else if (oldProv == 5) {
			_amt = _fulVal();
			_fulWithdraw(_amt);
		} 

		if (_new == 1) {
			_yfiSup(_amt);
		} else if (_new == 2) {
			_compSup(_amt);
		} else if (_new == 3) {
			_aavSup(_amt);
		}else if (_new == 5) {
			_fulSup(_amt);
		}
	}
	function _deposit() private {
		uint v1 = _proVal(_prv1);
		uint v2 = _proVal(_prv2);
		if(v1 <= v2){
			_setProVal(_prv1);
		}else{
			_setProVal(_prv2);
		}
	}
	function _withdraw(uint _amt) internal {
		if(_amt > _btokenBal()){
			uint v1 = _proVal(_prv1);
			uint v2 = _proVal(_prv2);
			require(v1 >= _amt || v2 >= _amt, "!insufficient fund");
			if(v1 >= v2){
				_wdProVal(_prv1,_amt);
			}else{
				_wdProVal(_prv2,_amt);
			}
		}
	}
	
	function _deposit(uint _amt) private nonReentrant
	{
		require(_amt >= minDepo, "!minimum deposit");
		uint pool = _calcPool();
		IERC20(btoken).transferFrom(_sender(), address(this), _amt);
		if(_amt >= minWd2*1e18)
			_deposit();
		uint amt = 0;
		if (pool == 0) {
			amt = _amt;
		} else {
			amt = (_amt.mul(_sup)).div(pool);
		}
		_mint(_sender(), amt);
		_coll[_sender()] = _coll[_sender()].add(_amt);
		if (_exp[_sender()] == 0){
			_setExp(_sender(),now + 30 days);
			
		}
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
		_sup = _sup.sub(_token);
		emit Transfer(_sender(), address(0), _token);
		_withdraw(_amt);
		IERC20(btoken).transfer(_sender(), _amt);
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
		_withdraw(_amt);
		uint  a1 = (_amt.mul(80)).div(100);
		uint  a2 = (_amt.mul(10)).div(100);
		IERC20(btoken).transfer(_sender(), a1);
		address referrer = Mfinance(multifinance).getReferral(_sender());
		IERC20(btoken).transfer(referrer, a2);
		emit ReferralReward(referrer, a2);
		IERC20(btoken).transfer(owner(), _amt.sub(a1).sub(a2));
		uint mfiprice = Mfinance(multifinance).getPrice();
		if(IERC20(mfi).totalSupply().add(_amt.mul(1e18).div(mfiprice)) <= Mfi(mfi).cap()){
			Mfi(mfi).mint(owner(), a2.mul(2).mul(1e18).div(mfiprice));
			Mfi(mfi).mint(_sender(), a1.mul(1e18).div(mfiprice));
		}
		_setExp(_sender(),now + 30 days);
	}
	receive() external payable {
    }
	
	function setExp(address _addr, uint _newExp) external onlyOwner{
		_setExp(_addr,_newExp);
	}

	function setMfi(address _addr) external onlyOwner{
		mfi = _addr;
	}
	function setMultifinance(address _addr) external onlyOwner{
		multifinance = _addr;
	}
	function getMultifinance() external view returns(address){
		return multifinance;
	}
	function getMfi() external view returns(address){
		return mfi;
	}
    
}