pragma solidity ^0.4.26;

import "./Types.sol";

contract RoT is Destructable
{
	address public ESOPAddress;

	event LogESOPAndCompanySet(address ESOPAddress, address companyAddress);

	function setESOP(address ESOP, address company) public onlyOwner
	{
		ESOPAddress = ESOP;
		transferOwnership(company);
		emit LogESOPAndCompanySet(ESOP, company);
	}

	function killOnUnsupportedFork() public onlyOwner
	{
		delete ESOPAddress;
		selfdestroy();
	}
}

