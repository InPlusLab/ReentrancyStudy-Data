/*Contract For Transmission (TMN) [tmission.io] and OnPlace Inc. (OPL) [onplace.io] Members Compensation*/

pragma solidity 0.4.21;

import "./List.sol";


contract Compensation {
    address public admin1;
    address public admin2;
    uint256 public unlockerBlockNumber;
    string public message;
    bool public admin1IsLive;

    List public listContract;

    mapping(address => bool) public compensationCompleteOf;

    modifier onlyAdmin1 {
        require(msg.sender == admin1);
        _;
    }

    modifier onlyAdmin2 {
        require(msg.sender == admin2);
        _;
    }

    modifier afterDeadline {
        require(block.number >= unlockerBlockNumber);
        _;
    }

    function Compensation(
    address admin1Address,
    address admin2Address,
    uint256 blockNumber
    ) public {
        admin1 = admin1Address;
        admin2 = admin2Address;
        unlockerBlockNumber = blockNumber;
        admin1IsLive = false;
    }

    function () public payable {}

    function getCompensation()
    public {
        address recipient = msg.sender;
        require(!compensationCompleteOf[recipient]);
        uint256 compensationAmount = listContract.balanceOf(recipient);
        compensationCompleteOf[recipient] = true;
        recipient.transfer(compensationAmount);
    }

    function transferOwnershipOfAdmin1(address newAdmin)
    public onlyAdmin1 {
        admin1 = newAdmin;
    }

    function checkAdmin1()
    public onlyAdmin1 {
        admin1IsLive = true;
    }

    function withdrawCompensationFunds(uint256 amount)
    public onlyAdmin1 afterDeadline {
        admin1.transfer(amount);
    }

    function transferOwnershipOfAdmin2(address newAdmin)
    public onlyAdmin2 {
        admin2 = newAdmin;
    }

    function changeList(address newListAddress)
    public onlyAdmin2 {
        listContract = List(newListAddress);
    }

    function changeMessage(string newMessage)
    public onlyAdmin2 {
        message = newMessage;
    }
}
