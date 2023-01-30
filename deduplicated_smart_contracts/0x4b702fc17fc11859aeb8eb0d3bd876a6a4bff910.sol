/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity ^0.5.11;

contract IOwned {
	function owner() public pure returns (address) {}
}

contract IERC20Token {
	function decimals() public pure returns (uint8) {}
	function totalSupply() public pure returns (uint256) {}
}

contract ISmartToken is IOwned, IERC20Token {
}

contract IFormula {
	function calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public view returns (uint256);
	function calculateSaleReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _sellAmount) public view returns (uint256);
}

contract IConverter {
	function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256);
	function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
	function conversionFee() public pure returns (uint32) {}
	function connectors(address _address) public pure returns (uint256, uint32, bool, bool, bool) { _address; }
	function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);
	function claimTokens(address _from, uint256 _amount) public;
}

contract IContractRegistry {
	function getAddress(bytes32 _contractName) public view returns (address);
}

contract IGasPriceLimit {
	function gasPrice() public view returns (uint256);
}

library SafeMath {
	function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
		uint256 z = _x + _y;
		require(z >= _x);
		return z;
	}

	function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {
		require(_x >= _y);
		return _x - _y;
	}

	function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
		// gas optimization
		if (_x == 0)
			return 0;

		uint256 z = _x * _y;
		require(z / _x == _y);
		return z;
	}

	function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
		require(_y > 0);
		uint256 c = _x / _y;

		return c;
	}
}

contract BancorPrice {
	using SafeMath for uint256;

	IContractRegistry private registry = IContractRegistry(0xD1997064F0fEF8748C1de9B5ba53468C548738B3);

	bytes32 private constant BANCOR_FORMULA = "BancorFormula";
	bytes32 private constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";

	uint64 private constant MAX_CONVERSION_FEE = 1000000;

	// function getOutputAmountAndGas(IERC20Token[] calldata _path, uint256 _amount) internal view returns (uint256, uint256) {
	// 	uint256 amount = getOutputAmount(_path, _amount);
	// 	uint256 gasPrice = getGasPrice();
	// 	return (amount, gasPrice);
	// }

	// function getInputAmountAndGas(IERC20Token[] calldata _path, uint256 _amount) internal view returns (uint256, uint256) {
	// 	uint256 amount = getInputAmount(_path, _amount);
	// 	uint256 gasPrice = getGasPrice();
	// 	return (amount, gasPrice);
	// }

	function getOutputAmount(IERC20Token[] memory _path, uint256 _amount) internal view returns (uint256) {
		uint256 amount = _amount;
		uint256 supply;
		IERC20Token fromToken = _path[0];
		IFormula formula = IFormula(registry.getAddress(BANCOR_FORMULA));
		ISmartToken prevSmartToken;
		// iterate over the conversion path
		for (uint256 i = 1; i < _path.length; i += 2) {
			ISmartToken smartToken = ISmartToken(address(_path[i]));
			IERC20Token toToken = _path[i + 1];
			IConverter converter = IConverter(smartToken.owner());

			if (toToken == smartToken) { // buy the smart token
				// check if the current smart token supply was changed in the previous iteration
				supply = smartToken == prevSmartToken ? supply : smartToken.totalSupply();

				// validate input
				require(getConnectorSaleEnabled(converter, fromToken));

				// calculate the amount & the conversion fee
				uint256 balance = converter.getConnectorBalance(fromToken);
				uint32 weight = getConnectorWeight(converter, fromToken);
				amount = formula.calculatePurchaseReturn(supply, balance, weight, amount);
				uint256 fee = amount * converter.conversionFee() / MAX_CONVERSION_FEE;
				amount -= fee;

				// update the smart token supply for the next iteration
				supply = smartToken.totalSupply() + amount;
			}
			else if (fromToken == smartToken) { // sell the smart token
				// check if the current smart token supply was changed in the previous iteration
				supply = smartToken == prevSmartToken ? supply : smartToken.totalSupply();

				// calculate the amount & the conversion fee
				uint256 balance = converter.getConnectorBalance(toToken);
				uint32 weight = getConnectorWeight(converter, toToken);
				amount = formula.calculateSaleReturn(supply, balance, weight, amount);
				uint256 fee = amount * converter.conversionFee() / MAX_CONVERSION_FEE;
				amount -= fee;

				// update the smart token supply for the next iteration
				supply = smartToken.totalSupply() - amount;
			}
			else { // cross connector conversion
				amount = converter.getReturn(fromToken, toToken, amount);
			}

			prevSmartToken = smartToken;
			fromToken = toToken;
		}
		return amount;
	}

	function getInputAmount(IERC20Token[] memory _path, uint256 _amount) internal view returns (uint256) {
		IERC20Token fromToken = _path[0];
		uint256 initialAmount = getMultiplier(fromToken);
		uint256 initialReturn = getOutputAmount(_path, initialAmount);
		uint256 initialCost = _amount * initialAmount / initialReturn;
		uint256 finalReturn = getOutputAmount(_path, initialCost);
		return _amount * initialCost / finalReturn;
	}

	function getGasPrice() internal view returns (uint256) {
		IGasPriceLimit limit = IGasPriceLimit(registry.getAddress(BANCOR_GAS_PRICE_LIMIT));
		uint256 gasPrice = limit.gasPrice();
		return gasPrice;
	}

	function getConnectorSaleEnabled(IConverter _converter, IERC20Token _connector) private pure returns (bool) {
		uint256 virtualBalance;
		uint32 weight;
		bool isVirtualBalanceEnabled;
		bool isSaleEnabled;
		bool isSet;
		(virtualBalance, weight, isVirtualBalanceEnabled, isSaleEnabled, isSet) = _converter.connectors(address(_connector));
		return isSaleEnabled;
	}

	function getConnectorWeight(IConverter _converter, IERC20Token _connector) private pure returns (uint32) {
		uint256 virtualBalance;
		uint32 weight;
		bool isVirtualBalanceEnabled;
		bool isSaleEnabled;
		bool isSet;
		(virtualBalance, weight, isVirtualBalanceEnabled, isSaleEnabled, isSet) = _converter.connectors(address(_connector));
		return weight;
	}

	function getMultiplier(IERC20Token _token) private pure returns(uint256) {
		return 10 ** getDecimals(_token);
	}
	
	function getDecimals(IERC20Token _token) private pure returns(uint256) {
		if (address(_token) == 0xE0B7927c4aF23765Cb51314A0E0521A9645F0E2A) { // DGD
			return 9;
	    }
	    if (address(_token) == 0xbdEB4b83251Fb146687fa19D1C660F99411eefe3) { // SVD
	    	return 18;
	    }
	    return _token.decimals();
	}
}

contract BancorMultiPrice is BancorPrice {
	function getOutputAmountsAndGas(IERC20Token[] calldata _path, uint256 _amount) external view returns (uint256[100] memory _amounts, uint256 _gasPrice) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getOutputAmount(_path, (i + 1) * _amount / 100);
		}
		_gasPrice = getGasPrice();
	}

	function getInputAmountsAndGas(IERC20Token[] calldata _path, uint256 _amount) external view returns (uint256[100] memory _amounts, uint256 _gasPrice) {
		for (uint256 i = 0; i < 100; i++) {
			_amounts[i] = getInputAmount(_path, (i + 1) * _amount / 100);
		}
		_gasPrice = getGasPrice();
	}
}