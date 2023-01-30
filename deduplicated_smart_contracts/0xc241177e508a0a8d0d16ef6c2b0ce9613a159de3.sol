/**

 *Submitted for verification at Etherscan.io on 2018-12-30

*/



pragma solidity 0.4.24;



contract PostboyDonate {



    struct TransferRequest {

        address approve_1;

        address targetAddress;

        uint256 amount;

        bool isActive;

    }

   

    address public adminAddress_1;

    address public adminAddress_2;

    address public adminAddress_3;



    TransferRequest public transferRequest;



    modifier isAdmin() {

        require(msg.sender == adminAddress_1 || msg.sender == adminAddress_2 || msg.sender == adminAddress_3);

        _;

    }



    constructor(address admin_1, address admin_2, address admin_3) public {

        adminAddress_1 = admin_1;

        adminAddress_2 = admin_2;

        adminAddress_3 = admin_3;

        transferRequest.isActive = false;

    }



    function changeAdmin(address newAdminAddress) isAdmin public {

        require(transferRequest.isActive == false);



        if (msg.sender == adminAddress_1) {

            adminAddress_1 = newAdminAddress;

            return;

        }

        if (msg.sender == adminAddress_2) {

            adminAddress_2 = newAdminAddress;

            return;

        }

        if (msg.sender == adminAddress_3) {

            adminAddress_3 = newAdminAddress;

            return;

        }

    }



    function createTransferRequest(uint256 amount, address targetAddress) isAdmin public {

        require(amount <= address(this).balance);

        require(transferRequest.isActive == false);



        transferRequest.approve_1 = msg.sender;

        transferRequest.targetAddress = targetAddress;

        transferRequest.amount = amount;

        transferRequest.isActive = true;

    }



    function approveAndTransfer(uint256 amount, address targetAddress) isAdmin public {

        require(amount <= address(this).balance);

        require(transferRequest.isActive == true);



        require(transferRequest.amount == amount);

        require(transferRequest.targetAddress == targetAddress);

        require(transferRequest.approve_1 != msg.sender);



        transferRequest.approve_1 = address(0);

        transferRequest.targetAddress = address(0);

        transferRequest.amount = 0;

        transferRequest.isActive = false;



        targetAddress.transfer(amount);

    }



    function removeTransferRequest() isAdmin public {

        transferRequest.approve_1 = address(0);

        transferRequest.targetAddress = address(0);

        transferRequest.amount = 0;

        transferRequest.isActive = false;

    }



    function () external payable {

    }

}