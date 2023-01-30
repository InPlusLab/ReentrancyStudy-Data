/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity ^0.5.11;

interface IERC20Token {
	function decimals() external pure returns (uint8);
}

interface KyberProxy {
	function getExpectedRate(IERC20Token _from, IERC20Token _to, uint256 _amount) external view returns(uint256, uint256);
}

contract KyberPrice {
	KyberProxy private proxy = KyberProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
	IERC20Token private etherToken = IERC20Token(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

	function getOutputAmount(IERC20Token _from, IERC20Token _to, uint256 _amount) internal view returns (uint256) {
		(uint256 expectedRate, ) = proxy.getExpectedRate(_from, _to, _amount);
		uint256 defaultMultiplier = getMultiplier(etherToken);
		uint256 fromMultiplier = getMultiplier(_from);
		uint256 toMultiplier = getMultiplier(_to);
		uint256 amount = (expectedRate * toMultiplier * _amount) / (defaultMultiplier * fromMultiplier);
		return amount;
	}

	function getInputAmount(IERC20Token _from, IERC20Token _to, uint256 _amount) internal view returns (uint256) {
		uint256 initialAmount = getMultiplier(_from);
		uint256 initialReturn = getOutputAmount(_from, _to, initialAmount);
		if (initialReturn == 0) {
			return 0;
		}
		uint256 initialCost = _amount * initialAmount / initialReturn;
		uint256 finalReturn = getOutputAmount(_from, _to, initialCost);
		if (finalReturn == 0) {
			return 0;
		}
		return _amount * initialCost / finalReturn;
	}
	
	function getMultiplier(IERC20Token _token) private view returns(uint256) {
		return 10 ** getDecimals(_token);
	}
	
	function getDecimals(IERC20Token _token) private view returns(uint256) {
		if (_token == etherToken) {
			return 18;
		}
		return _token.decimals();
	}
}

contract KyberMultiPrice is KyberPrice {
	function getOutputAmounts(IERC20Token _from, IERC20Token _to, uint256 _amount) external view returns (uint256[100] memory _amounts) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getOutputAmount(_from, _to, (i + 1) * _amount / 100);
		}
	}

	function getInputAmounts(IERC20Token _from, IERC20Token _to, uint256 _amount) external view returns (uint256[100] memory _amounts) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getInputAmount(_from, _to, (i + 1) * _amount / 100);
		}
	}
}