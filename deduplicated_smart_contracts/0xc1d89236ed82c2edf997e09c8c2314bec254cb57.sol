/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity ^0.5.11;

interface ERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

interface Factory {
	function getExchange(ERC20 _token) external view returns (Exchange);
}

interface Exchange {
	function getEthToTokenInputPrice(uint256 _amount) external view returns (uint256);
	function getEthToTokenOutputPrice(uint256 _amount) external view returns (uint256);
	function getTokenToEthInputPrice(uint256 _amount) external view returns (uint256);
	function getTokenToEthOutputPrice(uint256 _amount) external view returns (uint256);
}

contract UniswapPrice {
	Factory private factory = Factory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);

	function getEthToTokenInputAmount(ERC20 _token, uint256 _amount) internal view returns (uint256) {
		Exchange exchange = factory.getExchange(_token);
		uint256 amount = exchange.getEthToTokenInputPrice(_amount);
		return amount;
	}

	function getEthToTokenOutputAmount(ERC20 _token, uint256 _amount) internal view returns (uint256) {
		Exchange exchange = factory.getExchange(_token);
		if (_token.balanceOf(address(exchange)) < _amount) {
			return 0;
		}
		uint256 amount = exchange.getEthToTokenOutputPrice(_amount);
		return amount;
	}

	function getTokenToEthInputAmount(ERC20 _token, uint256 _amount) internal view returns (uint256) {
		Exchange exchange = factory.getExchange(_token);
		uint256 amount = exchange.getTokenToEthInputPrice(_amount);
		return amount;
	}

	function getTokenToEthOutputAmount(ERC20 _token, uint256 _amount) internal view returns (uint256) {
		Exchange exchange = factory.getExchange(_token);
		if (address(exchange).balance < _amount) {
			return 0;
		}
		uint256 amount = exchange.getTokenToEthOutputPrice(_amount);
		return amount;
	}

	function getTokenToTokenInputAmount(ERC20 _from, ERC20 _to, uint256 _amount) internal view returns (uint256) {
		Exchange fromExchange = factory.getExchange(_from);
		Exchange toExchange = factory.getExchange(_to);
		uint256 ethAmount = fromExchange.getTokenToEthInputPrice(_amount);
		uint256 amount = toExchange.getEthToTokenInputPrice(ethAmount);
		return amount;
	}

	function getTokenToTokenOutputAmount(ERC20 _from, ERC20 _to, uint256 _amount) internal view returns (uint256) {
		Exchange fromExchange = factory.getExchange(_from);
		Exchange toExchange = factory.getExchange(_to);
		if (_to.balanceOf(address(toExchange)) < _amount) {
			return 0;
		}
		uint256 ethAmount = toExchange.getEthToTokenOutputPrice(_amount);
		if (address(fromExchange).balance < ethAmount) {
			return 0;
		}
		uint256 amount = fromExchange.getTokenToEthOutputPrice(ethAmount);
		return amount;
	}
}

contract UniswapMultiPrice is UniswapPrice {
	function getEthToTokenInputAmounts(ERC20 _token, uint256 _amount) external view returns (uint256[100] memory _amounts) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getEthToTokenInputAmount(_token, (i + 1) * _amount / 100);
		}
	}

	function getEthToTokenOutputAmounts(ERC20 _token, uint256 _amount) external view returns (uint256[100] memory _amounts) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getEthToTokenOutputAmount(_token, (i + 1) * _amount / 100);
		}
	}

	function getTokenToEthInputAmounts(ERC20 _token, uint256 _amount) external view returns (uint256[100] memory _amounts) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getTokenToEthInputAmount(_token, (i + 1) * _amount / 100);
		}
	}

	function getTokenToEthOutputAmounts(ERC20 _token, uint256 _amount) external view returns (uint256[100] memory _amounts) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getTokenToEthOutputAmount(_token, (i + 1) * _amount / 100);
		}
	}

	function getTokenToTokenInputAmounts(ERC20 _from, ERC20 _to, uint256 _amount) external view returns (uint256[100] memory _amounts) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getTokenToTokenInputAmount(_from, _to, (i + 1) * _amount / 100);
		}
	}

	function getTokenToTokenOutputAmounts(ERC20 _from, ERC20 _to, uint256 _amount) external view returns (uint256[100] memory _amounts) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getTokenToTokenOutputAmount(_from, _to, (i + 1) * _amount / 100);
		}
	}
}