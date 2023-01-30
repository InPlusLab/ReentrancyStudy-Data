/**
 *Submitted for verification at Etherscan.io on 2019-12-23
*/

pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

interface CTokenInterface {
    function underlying() external view returns (address);
}


contract Helpers {
    address payable public controllerOne = 0x0f0EBD0d7672362D11e0b6d219abA30b0588954E;
    address payable public controllerTwo = 0xd8db02A498E9AFbf4A32BC006DC1940495b4e592;
    address payable public controllerThree = 0xe866ecE4bbD0Ac75577225Ee2C464ef16DC8b1F3;
    mapping (address => address) public ctokenAddrs;

    modifier isController {
        require(msg.sender == controllerOne || msg.sender == controllerTwo || msg.sender == controllerThree, "not-controller");
        _;
    }

    function addCtknMapping(address[] memory cTkn) public isController {
        for (uint i = 0; i < cTkn.length; i++) {
            address cErc20 = cTkn[i];
            address erc20 = CTokenInterface(cErc20).underlying();
            ctokenAddrs[erc20] = cErc20;
        }
    }
}


contract InstaCompoundMapping is Helpers {
    constructor() public {
        address ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
        address cEth = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
        address cSai = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;
        address cDai = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
        address cUsdc = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
        address[] memory cAddresses = new address[](3);
        cAddresses[0] = cSai;
        cAddresses[1] = cDai;
        cAddresses[2] = cUsdc;
        ctokenAddrs[ethAddress] = cEth;
        addCtknMapping(cAddresses);
    }
}