pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./SmartInvoice.sol";

/**
 * @title SmartInvoiceToken
 */
contract SmartInvoiceToken is ERC20 {

    SmartInvoice public smartInvoice;

    constructor(uint256 _amount,
                uint256 _dueDate,
                IERC20 _assetToken,
                address _beneficiary,
                address _payer,
                string memory _referenceHash) public {
        smartInvoice = new SmartInvoice(_amount, _dueDate, _assetToken, address(this), _payer, _referenceHash);
        _mint(_beneficiary, smartInvoice.amount());
    }

    function canRedeem() public view returns (bool) {
        return smartInvoice.status() == SmartInvoice.Status.SETTLED;
    }

    function redeem(uint256 amount) public returns (bool) {
        require(canRedeem(), "Can only redeem after settlement");
        require(smartInvoice.assetToken().transfer(msg.sender, amount), "smartInvoice uses different asset token");
        //note the internal _burn function will fail if not enough tokens to burn
        _burn(msg.sender, amount);
        return true;
    }

}
