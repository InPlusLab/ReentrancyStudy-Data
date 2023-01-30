/**

 *Submitted for verification at Etherscan.io on 2019-05-20

*/



pragma solidity ^0.4.13;



library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



contract EthicHubBase {



    uint8 public version;



    EthicHubStorageInterface public ethicHubStorage = EthicHubStorageInterface(0);



    constructor(address _storageAddress) public {

        require(_storageAddress != address(0));

        ethicHubStorage = EthicHubStorageInterface(_storageAddress);

    }



}



contract EthicHubStorageInterface {



    //modifier for access in sets and deletes

    modifier onlyEthicHubContracts() {_;}



    // Setters

    function setAddress(bytes32 _key, address _value) external;

    function setUint(bytes32 _key, uint _value) external;

    function setString(bytes32 _key, string _value) external;

    function setBytes(bytes32 _key, bytes _value) external;

    function setBool(bytes32 _key, bool _value) external;

    function setInt(bytes32 _key, int _value) external;

    // Deleters

    function deleteAddress(bytes32 _key) external;

    function deleteUint(bytes32 _key) external;

    function deleteString(bytes32 _key) external;

    function deleteBytes(bytes32 _key) external;

    function deleteBool(bytes32 _key) external;

    function deleteInt(bytes32 _key) external;



    // Getters

    function getAddress(bytes32 _key) external view returns (address);

    function getUint(bytes32 _key) external view returns (uint);

    function getString(bytes32 _key) external view returns (string);

    function getBytes(bytes32 _key) external view returns (bytes);

    function getBool(bytes32 _key) external view returns (bool);

    function getInt(bytes32 _key) external view returns (int);

}



contract EthicHubReputationInterface {

    modifier onlyUsersContract(){_;}

    modifier onlyLendingContract(){_;}

    function burnReputation(uint delayDays)  external;

    function incrementReputation(uint completedProjectsByTier)  external;

    function initLocalNodeReputation(address localNode)  external;

    function initCommunityReputation(address community)  external;

    function getCommunityReputation(address target) public view returns(uint256);

    function getLocalNodeReputation(address target) public view returns(uint256);

}



contract EthicHubReputation is EthicHubBase, EthicHubReputationInterface {



    //10 with 2 decilmals

    uint constant maxReputation = 1000;

    uint constant reputationStep = 100;

    //Tier 1 x 20 people

    uint constant minProyect = 20;

    uint constant public initReputation = 500;



    //0.05

    uint constant incrLocalNodeMultiplier = 5;



    using SafeMath for uint;



    event ReputationUpdated(address indexed affected, uint newValue);



    /*** Modifiers ************/



    /// @dev Only allow access from the latest version of a contract in the Rocket Pool network after deployment

    modifier onlyUsersContract() {

        require(ethicHubStorage.getAddress(keccak256(abi.encodePacked("contract.name", "users"))) == msg.sender);

        _;

    }



    modifier onlyLendingContract() {

        require(ethicHubStorage.getAddress(keccak256(abi.encodePacked("contract.address", msg.sender))) == msg.sender);

        _;

    }



    /// @dev constructor

    constructor(address _storageAddress) EthicHubBase(_storageAddress) public {

      // Version

      version = 2;

    }



    function burnReputation(uint delayDays) external onlyLendingContract {

        address lendingContract = msg.sender;

        //Get temporal parameters

        uint maxDelayDays = ethicHubStorage.getUint(keccak256(abi.encodePacked("lending.maxDelayDays", lendingContract)));

        require(maxDelayDays != 0);

        require(delayDays != 0);



        //Affected players

        address community = ethicHubStorage.getAddress(keccak256(abi.encodePacked("lending.community", lendingContract)));

        require(community != address(0));

        //Affected local node

        address localNode = ethicHubStorage.getAddress(keccak256(abi.encodePacked("lending.localNode", lendingContract)));

        require(localNode != address(0));



        //***** Community

        uint previousCommunityReputation = ethicHubStorage.getUint(keccak256(abi.encodePacked("community.reputation", community)));

        //Calculation and update

        uint newCommunityReputation = burnCommunityReputation(delayDays, maxDelayDays, previousCommunityReputation);

        ethicHubStorage.setUint(keccak256(abi.encodePacked("community.reputation", community)), newCommunityReputation);

        emit ReputationUpdated(community, newCommunityReputation);



        //***** Local node

        uint previousLocalNodeReputation = ethicHubStorage.getUint(keccak256(abi.encodePacked("localNode.reputation", localNode)));

        uint newLocalNodeReputation = burnLocalNodeReputation(delayDays, maxDelayDays, previousLocalNodeReputation);

        ethicHubStorage.setUint(keccak256(abi.encodePacked("localNode.reputation", localNode)), newLocalNodeReputation);

        emit ReputationUpdated(localNode, newLocalNodeReputation);



    }



    function incrementReputation(uint completedProjectsByTier) external onlyLendingContract {

        address lendingContract = msg.sender;

        //Affected players

        address community = ethicHubStorage.getAddress(keccak256(abi.encodePacked("lending.community", lendingContract)));

        require(community != address(0));

        //Affected local node

        address localNode = ethicHubStorage.getAddress(keccak256(abi.encodePacked("lending.localNode", lendingContract)));

        require(localNode != address(0));



        //Tier

        uint projectTier = ethicHubStorage.getUint(keccak256(abi.encodePacked("lending.tier", lendingContract)));

        require(projectTier > 0);

        require(completedProjectsByTier > 0);



        //***** Community

        uint previousCommunityReputation = ethicHubStorage.getUint(keccak256(abi.encodePacked("community.reputation", community)));

        //Calculation and update

        uint newCommunityReputation = incrementCommunityReputation(previousCommunityReputation, completedProjectsByTier);

        ethicHubStorage.setUint(keccak256(abi.encodePacked("community.reputation", community)), newCommunityReputation);

        emit ReputationUpdated(community, newCommunityReputation);



        //***** Local node

        uint borrowers = ethicHubStorage.getUint(keccak256(abi.encodePacked("lending.communityMembers", lendingContract)));

        uint previousLocalNodeReputation = ethicHubStorage.getUint(keccak256(abi.encodePacked("localNode.reputation", localNode)));

        uint newLocalNodeReputation = incrementLocalNodeReputation(previousLocalNodeReputation, projectTier, borrowers);

        ethicHubStorage.setUint(keccak256(abi.encodePacked("localNode.reputation", localNode)), newLocalNodeReputation);

        emit ReputationUpdated(localNode, newLocalNodeReputation);

    }



    function incrementCommunityReputation(uint previousReputation, uint completedProjectsByTier) public pure returns(uint) {

        require(completedProjectsByTier > 0);

        uint nextRep = previousReputation.add(reputationStep.div(completedProjectsByTier));

        if (nextRep >= maxReputation) {

            return maxReputation;

        } else {

            return nextRep;

        }

    }



    function incrementLocalNodeReputation(uint previousReputation, uint tier, uint borrowers) public pure returns(uint) {

        require(tier >= 1);

        //this should 20 but since it's hardcoded in EthicHubLending, let's be safe.

        //TODO store min borrowers in EthicHubStorage

        require(borrowers > 0); 

        uint increment = (tier.mul(borrowers).div(minProyect)).mul(incrLocalNodeMultiplier);

        uint nextRep = previousReputation.add(increment);

        if (nextRep >= maxReputation) {

            return maxReputation;

        } else {

            return nextRep;

        }

    }



    function burnLocalNodeReputation(uint delayDays, uint maxDelayDays, uint prevReputation) public pure returns(uint) {

        if (delayDays >= maxDelayDays){

            return 0;

        }

        uint decrement = prevReputation.mul(delayDays).div(maxDelayDays);

        if (delayDays < maxDelayDays && decrement < reputationStep) {

            return prevReputation.sub(decrement);

        } else {

            return prevReputation.sub(reputationStep);

        }

    }



    function burnCommunityReputation(uint delayDays, uint maxDelayDays, uint prevReputation) public pure returns(uint) {

        if (delayDays < maxDelayDays) {

            return prevReputation.sub(prevReputation.mul(delayDays).div(maxDelayDays));

        } else {

            return 0;

        }

    }



    function initLocalNodeReputation(address localNode) onlyUsersContract external {

        require(ethicHubStorage.getUint(keccak256(abi.encodePacked("localNode.reputation", localNode))) == 0);

        ethicHubStorage.setUint(keccak256(abi.encodePacked("localNode.reputation", localNode)), initReputation);

    }



    function initCommunityReputation(address community) onlyUsersContract external {

        require(ethicHubStorage.getUint(keccak256(abi.encodePacked("comunity.reputation", community))) == 0);

        ethicHubStorage.setUint(keccak256(abi.encodePacked("community.reputation", community)), initReputation);

    }



    function getCommunityReputation(address target) public view returns(uint256) {

        return ethicHubStorage.getUint(keccak256(abi.encodePacked("community.reputation", target)));

    }



    function getLocalNodeReputation(address target) public view returns(uint256) {

        return ethicHubStorage.getUint(keccak256(abi.encodePacked("localNode.reputation", target)));

    }



}