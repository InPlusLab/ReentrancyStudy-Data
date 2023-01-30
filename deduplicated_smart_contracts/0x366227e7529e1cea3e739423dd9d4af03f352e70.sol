/**
 *Submitted for verification at Etherscan.io on 2019-10-25
*/

pragma solidity ^0.5.11;

interface BCF {
	function totalEthereumBalance() external view returns (uint256);
	function totalSupply() external view returns (uint256);
	function buyPrice() external view returns (uint256);
	function sellPrice() external view returns (uint256);
	function calculateEthereumReceived(uint256 _tokensToSell) external view returns (uint256);
	function balanceOf(address _customer) external view returns (uint256);
	function dividendsOf(address _customer) external view returns (uint256);
}

contract QBCF {

	BCF private bcf;

	constructor(address _BCF_address) public {
		bcf = BCF(_BCF_address);
	}

	function allInfoFor(address _customer) public view returns (uint256 ethereumBalance, uint256 totalSupply, uint256 buyPrice, uint256 sellPrice, uint256 customerBalance, uint256 customerDividends) {
		return (bcf.totalEthereumBalance(), bcf.totalSupply(), bcf.buyPrice(), bcf.sellPrice(), bcf.balanceOf(_customer), bcf.dividendsOf(_customer));
	}
}