/**

 *Submitted for verification at Etherscan.io on 2019-03-21

*/



pragma solidity ^0.4.24;



/*

*   gibmireinbier - Full Stack Blockchain Developer

*   0xA4a799086aE18D7db6C4b57f496B081b44888888

*   [email protected]

*/



interface F2mInterface {

    function getTotalDividendsByAddress(address _invester) public view returns(uint256);

}



contract Whitelist {

    // total dividends in ver. 1 ~ 446 ether

    uint256 constant public TOTAL_DIVIDENDS = 446879946341425765598;

    uint256 constant public PREMINT_TOKENS = 500000*(10**10);

    // MAX 180 000 tokens for an address

    uint256 constant public LIMIT = 180000*(10**10);



    F2mInterface public f2mV1;

    address public devTeam;

    address constant public oldDevTeam = 0x96504e1f83e380984B1d4ECCC0E8B9f0559b2Ad2;

    

    constructor(address _devTeam) public {

        devTeam = _devTeam;

        DevTeamInterface(_devTeam).setWhitelistAddress(address(this));



        // f2mV1 = F2mInterface(0x8888887c5eDE327aFbeb15019598aAa3b4FaE759);

        f2mV1 = F2mInterface(0xc9B0D6Fc77DD2b39F2a6d4e18Ae0e0996e95a640);

    }



    // REMOVED by Seizo

    // function getPremintAmount(address _address) 

    //     public

    //     view

    //     returns(uint256)

    // {

    //     address _mask = _address == devTeam ? oldDevTeam : _address;

    //     //uint256 _v1_dividends = f2mV1.getTotalDividendsByAddress(_mask);

    //     uint256 _v1_dividends = TOTAL_DIVIDENDS;

    //     // secure if, smt gone wrong

    //     if (_v1_dividends > TOTAL_DIVIDENDS) return 0;

    //     uint256 _amount = PREMINT_TOKENS * _v1_dividends / TOTAL_DIVIDENDS;

    //     if (_amount > LIMIT) return LIMIT;

    //     return _amount;

    // }

}



interface DevTeamInterface {

    function setF2mAddress(address _address) public;

    function setLotteryAddress(address _address) public;

    function setCitizenAddress(address _address) public;

    function setBankAddress(address _address) public;

    function setRewardAddress(address _address) public;

    function setWhitelistAddress(address _address) public;



    function setupNetwork() public;

}