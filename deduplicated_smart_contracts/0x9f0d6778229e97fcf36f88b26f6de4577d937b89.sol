pragma solidity ^0.5.0;

import "./IERC20.sol";

contract SmartInvoice {
    enum Status { UNCOMMITTED, COMMITTED, SETTLED }
    function getStatusString(Status status)
    public
    pure
    returns (string memory)
    {
        if (Status.UNCOMMITTED == status) {
            return "UNCOMMITTED";
        }
        if (Status.COMMITTED == status) {
            return "COMMITTED";
        }
        if (Status.SETTLED == status) {
            return "SETTLED";
        }
        return "ERROR";
    }

    uint256 public amount;
    uint256 public dueDate;
    IERC20 public assetToken;
    address public beneficiary;
    address public payer;
    string public referenceHash;

    Status  public status;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(uint256 _amount,
                uint256 _dueDate,
                IERC20 _assetToken,
                address _beneficiary,
                address _payer,
                string memory _referenceHash) public {
        require(_beneficiary != address(0), "beneficiary cannot be 0x0");
        require(_payer != address(0), "payer cannot be 0x0");
        amount = _amount;
        dueDate = _dueDate;
        assetToken = _assetToken;
        beneficiary = _beneficiary;
        payer = _payer;
        referenceHash = _referenceHash;

        status = Status.UNCOMMITTED;
    }

    function changeBeneficiary(address _newBeneficiary) public returns (bool) {
        require(msg.sender == beneficiary, "caller not current beneficiary");
        require(_newBeneficiary != address(0), "new beneficiary cannot be 0x0");
        require(status != Status.SETTLED, "can not change beneficiary after settlement");
        beneficiary = _newBeneficiary;
        return true;
    }

    function commit() public returns (bool) {
        require(msg.sender == payer, "only payer can commit to settle");
        require(status == Status.UNCOMMITTED, "can only commit while status in UNCOMMITTED");
        status = Status.COMMITTED;
        return true;
    }

    function settle() public returns (bool) {
        require(msg.sender == payer, "only payer can settle");
        require(status != Status.SETTLED, "already settled");
        require(now >= dueDate, "can only settle after due date");
        require(assetToken.transferFrom(payer, beneficiary, amount), "could not complete transfer");
        status = Status.SETTLED;
        return true;
    }

}

