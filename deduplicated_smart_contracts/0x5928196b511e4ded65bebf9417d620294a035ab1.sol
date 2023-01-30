pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./SmartInvoice.sol";
import "./SmartInvoiceToken.sol";

contract SmartInvoiceWallet {
  using SafeMath for uint256;

  address public owner;
  IERC20 public assetToken;

  //internal book keeping. Needed so that we only pay invoices we know we explicitly committed to pay
  mapping(address => SmartInvoice.Status) private _smartInvoiceStatus;

  modifier isOwner() {
    require(msg.sender == owner, "not owner");
    _;
  }

  constructor(address _owner, IERC20 _assetToken) public {
    require(_owner != address(0), "owner can not be 0x0");
    require(address(_assetToken) != address(0), "asset token can not be 0x0");
    owner = _owner;
    assetToken = _assetToken;
  }

  function () external payable {
    require(false, "Eth transfers not allowed");
  }

  function balance() public view returns (uint256) {
    return this.assetToken().balanceOf(address(this));
  }

  function transfer(address to, uint256 value) external isOwner returns (bool) {
    return this.assetToken().transfer(to, value);
  }

  function invoiceTokenTransfer(SmartInvoiceToken smartInvoiceToken, address to, uint256 value) external isOwner  returns (bool) {
    return smartInvoiceToken.transfer(to, value);
  }

  function invoiceTokenBalance(SmartInvoiceToken smartInvoiceToken) public view returns (uint256) {
    require(smartInvoiceToken.smartInvoice().assetToken() == this.assetToken(), "smartInvoice uses different asset token");

    return smartInvoiceToken.balanceOf(address(this));
  }

  function invoiceTokenBalanceSum(SmartInvoiceToken[] memory smartInvoiceTokens) public view returns (uint256) {
    uint256 total = 0;
    for (uint32 index = 0; index < smartInvoiceTokens.length; index++) {
      require(smartInvoiceTokens[index].smartInvoice().assetToken() == this.assetToken(), "smartInvoice uses different asset token");
      total = total.add(smartInvoiceTokens[index].balanceOf(address(this)));
    }
    return total;
  }

  //Note: owner (or their advocate) is expected to have audited what they commit to,
  // including confidence that the terms are guaranteed not to change. i.e. the smartInvoice is trusted
  function commit(SmartInvoice smartInvoice) external isOwner  returns (bool) {
    require(smartInvoice.payer() == address(this), "not smart invoice payer");
    require(smartInvoice.status() == SmartInvoice.Status.UNCOMMITTED, "smart invoice already committed");
    require(smartInvoice.assetToken() == this.assetToken(), "smartInvoice uses different asset token");
    require(smartInvoice.commit(), "could not commit");
    require(smartInvoice.status() == SmartInvoice.Status.COMMITTED, "commit did not update status");
    _smartInvoiceStatus[address(smartInvoice)] = SmartInvoice.Status.COMMITTED;
    return true;
  }

  function hasValidCommit(SmartInvoice smartInvoice) public view returns (bool) {
    return smartInvoice.payer() == address(this)
        && smartInvoice.status() == SmartInvoice.Status.COMMITTED
        && _smartInvoiceStatus[address(smartInvoice)] == SmartInvoice.Status.COMMITTED;
  }

  function canSettleSmartInvoice(SmartInvoice smartInvoice) public view returns (bool) {
    return hasValidCommit(smartInvoice)
        && now >= smartInvoice.dueDate();
  }

  function settle(SmartInvoice smartInvoice) external returns (bool) {
    require(canSettleSmartInvoice(smartInvoice), "settle not valid");
    require(assetToken.approve(address(smartInvoice), smartInvoice.amount()), "approve failed");
    require(smartInvoice.settle(), "settle smart invoice failed");
    require(smartInvoice.status() == SmartInvoice.Status.SETTLED, "settle did not update status");
    _smartInvoiceStatus[address(smartInvoice)] = SmartInvoice.Status.SETTLED;
    return true;
  }

  function redeem(SmartInvoiceToken smartInvoiceToken) external isOwner returns (bool) {
    require(smartInvoiceToken.canRedeem(), "redeem not valid");
    require(smartInvoiceToken.smartInvoice().assetToken() == this.assetToken(), "smartInvoice uses different asset token");
    uint256 amount = this.invoiceTokenBalance(smartInvoiceToken);
    require(smartInvoiceToken.redeem(amount), "redeem smart invoice failed");
    return true;
  }
}

