pragma solidity >=0.5.3 < 0.6.0;



import { ITokenManagerFactory } from "./ITokenManagerFactory.sol";

import { IMembershipFactory } from "./IMembershipFactory.sol";

import { IMembershipManager } from "./IMembershipManager.sol";

import { IEventManagerFactory } from "./IEventManagerFactory.sol";

import { BaseCommunityFactory } from "./BaseCommunityFactory.sol";



/// @author Ryan @ Protea 

/// @title V1 Community ecosystem factory

contract CommunityFactoryV1 is BaseCommunityFactory{

    address internal eventManagerFactory_;



    /// Constructor of V1 factory

    /// @param _daiTokenAddress         Address of the DAI token account

    /// @param _proteaAccount           Address of the Protea DAI account

    /// @notice                         Also sets a super admin for changing factories at a later stage, unused at present

    /// @author Ryan                

    constructor (address _daiTokenAddress, address _proteaAccount) public BaseCommunityFactory(_daiTokenAddress, _proteaAccount) {

    }



    /// @dev                            By passing through a list, this allows greater flexibility of the interface for different factories

    /// @param _factories               :address[]  List of factories

    /// @notice                         Introspection or interface confirmation should be used at later stages

    function initialize(address[] calldata _factories) external onlyAdmin(){

        require(tokenManagerFactory_ == address(0), "Already initialised");

        tokenManagerFactory_ = _factories[0];

        membershipManagerFactory_ = _factories[1];

        eventManagerFactory_ = _factories[2];



        emit FactoryRegistered(address(0), tokenManagerFactory_);

        emit FactoryRegistered(address(0), membershipManagerFactory_);

        emit FactoryRegistered(address(0), eventManagerFactory_);

    }



    function setTokenManagerFactory(address _newFactory) external onlyAdmin() {

        address oldFactory = tokenManagerFactory_;

        tokenManagerFactory_ = _newFactory;

        emit FactoryRegistered(oldFactory, tokenManagerFactory_);

    }



    function setMembershipManagerFactory(address _newFactory) external onlyAdmin() {

        address oldFactory = membershipManagerFactory_;

        membershipManagerFactory_ = _newFactory;

        emit FactoryRegistered(oldFactory, membershipManagerFactory_);

    }



    function setEventManagerFactory(address _newFactory) external onlyAdmin() {

        address oldFactory = eventManagerFactory_;

        eventManagerFactory_ = _newFactory;

        emit FactoryRegistered(oldFactory, eventManagerFactory_);

    }



    /// Allows the creation of a community

    /// @param _communityName           :string Name of the community

    /// @param _communitySymbol         :string Symbol of the community token

    /// @param _communityManager        :address The address of the super admin

    /// @param _gradientDemoninator     :uint256 The gradient modifier in the curve, not required in V1

    /// @param _contributionRate        :uint256 Percentage of incoming DAI to be diverted to the community account, from 0 to 100

    /// @return uint256                 Index of the deployed ecosystem

    /// @dev                            Also sets a super admin for changing factories at a later stage, unused at present

    // Rough gas usage 5,169,665 

    /// @author Ryan

    function createCommunity(

        string calldata _communityName,

        string calldata _communitySymbol,

        address _communityManager,

        uint256 _gradientDemoninator,

        uint256 _contributionRate

    )

        external

        returns(uint256)

    {

        address membershipManagerAddress = IMembershipFactory(membershipManagerFactory_).deployMembershipManager(_communityManager);



        address tokenManagerAddress = ITokenManagerFactory(tokenManagerFactory_).deployMarket(

            _communityName,

            _communitySymbol,

            daiAddress_,

            proteaAccount_,

            _communityManager,

            _contributionRate,

            membershipManagerAddress

        );



        IMembershipFactory(membershipManagerFactory_).initialize(tokenManagerAddress, membershipManagerAddress);



        address eventManagerAddress = IEventManagerFactory(eventManagerFactory_).deployEventManager(

            tokenManagerAddress,

            membershipManagerAddress,

            _communityManager

        );



        uint256 index = numberOfCommunities_;

        numberOfCommunities_ = numberOfCommunities_ + 1;

        

        communities_[index].name = _communityName;

        communities_[index].creator = msg.sender;

        communities_[index].tokenManagerAddress = tokenManagerAddress;

        communities_[index].membershipManagerAddress = membershipManagerAddress;

        communities_[index].utilities.push(eventManagerAddress);



        emit CommunityCreated(

            msg.sender,

            index, 

            tokenManagerAddress, 

            membershipManagerAddress, 

            communities_[index].utilities

        );



        return index;

    }



    /// Fetching community data

    /// @param _index                   :uint256 Index of the community

    /// @dev                            Fetches all data and contract addresses of deployed communities by index

    /// @return Community               Returns a Community struct matching the provided index

    /// @author Ryan

    function getCommunity(uint256 _index)

        external

        view

        returns(

            string memory,

            address,

            address,

            address,

            address[] memory

        )

    {

        return (

            communities_[_index].name,

            communities_[_index].creator,

            communities_[_index].membershipManagerAddress,

            communities_[_index].tokenManagerAddress,

            communities_[_index].utilities

        );

    }



    function getFactories() external view returns (address[] memory) {

        address[] memory factories = new address[](3);

        factories[0] = tokenManagerFactory_;

        factories[1] = membershipManagerFactory_;

        factories[2] = eventManagerFactory_;



        return factories;

    }

}