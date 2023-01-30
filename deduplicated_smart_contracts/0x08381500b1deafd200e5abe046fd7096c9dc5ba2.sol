pragma solidity >=0.5.3 < 0.6.0;



import { MembershipManagerV1 } from "./MembershipManagerV1.sol";

import { IMembershipManager } from "./IMembershipManager.sol";

import { BaseFactory } from "./BaseFactory.sol";

import { IMembershipFactory } from "./IMembershipFactory.sol";



contract MembershipManagerV1Factory is BaseFactory, IMembershipFactory {

    constructor(address _rootFactory) public BaseFactory(_rootFactory) {



    }

    function deployMembershipManager(address _communityManager) external onlyRootFactory() returns (address) {

        return address(new MembershipManagerV1(_communityManager));

    }



    function initialize(address _tokenManager, address _target) external onlyRootFactory(){

        IMembershipManager(_target).initialize(_tokenManager);

    }

}