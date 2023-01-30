/**

 *Submitted for verification at Etherscan.io on 2019-01-13

*/



contract PostboyRejectSetting {

   

    address public adminAddress;



    uint256 public minTimeForReject;

    bool public isRejectEnabled;



    modifier isAdmin() {

        require(msg.sender == adminAddress);

        _;

    }



    constructor() public {

        adminAddress = msg.sender;

        minTimeForReject = 0;

        isRejectEnabled = false;

    }



    function changeRejectSetting(uint256 rejectTime, bool isEnabled) isAdmin public {

        minTimeForReject = rejectTime;

        isRejectEnabled = isEnabled;

    }

}