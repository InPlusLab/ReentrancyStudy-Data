/**
 *Submitted for verification at Etherscan.io on 2020-11-26
*/

// File: contracts/zeppelin/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/interfaces/HydroInterface.sol

pragma solidity ^0.5.0;

interface HydroInterface {
    function balances(address) external view returns (uint);
    function allowed(address, address) external view returns (uint);
    function transfer(address _to, uint256 _amount) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _amount) external returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData)
        external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function totalSupply() external view returns (uint);

    function authenticate(uint _value, uint _challenge, uint _partnerId) external;
}

// File: contracts/interfaces/SnowflakeInterface.sol

pragma solidity ^0.5.0;

interface SnowflakeInterface {
    function deposits(uint) external view returns (uint);
    function resolverAllowances(uint, address) external view returns (uint);

    function identityRegistryAddress() external returns (address);
    function hydroTokenAddress() external returns (address);
    function clientRaindropAddress() external returns (address);

    function setAddresses(address _identityRegistryAddress, address _hydroTokenAddress) external;
    function setClientRaindropAddress(address _clientRaindropAddress) external;

    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, string calldata casedHydroId,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addProvidersFor(
        address approvingAddress, address[] calldata providers, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function removeProvidersFor(
        address approvingAddress, address[] calldata providers, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function upgradeProvidersFor(
        address approvingAddress, address[] calldata newProviders, address[] calldata oldProviders,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function addResolver(address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData) external;
    function addResolverAsProvider(
        uint ein, address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData
    ) external;
    function addResolverFor(
        address approvingAddress, address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function changeResolverAllowances(address[] calldata resolvers, uint[] calldata withdrawAllowances) external;
    function changeResolverAllowancesDelegated(
        address approvingAddress, address[] calldata resolvers, uint[] calldata withdrawAllowances,
        uint8 v, bytes32 r, bytes32 s
    ) external;
    function removeResolver(address resolver, bool isSnowflake, bytes calldata extraData) external;
    function removeResolverFor(
        address approvingAddress, address resolver, bool isSnowflake, bytes calldata extraData,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;

    function triggerRecoveryAddressChangeFor(
        address approvingAddress, address newRecoveryAddress, uint8 v, bytes32 r, bytes32 s
    ) external;

    function transferSnowflakeBalance(uint einTo, uint amount) external;
    function withdrawSnowflakeBalance(address to, uint amount) external;
    function transferSnowflakeBalanceFrom(uint einFrom, uint einTo, uint amount) external;
    function withdrawSnowflakeBalanceFrom(uint einFrom, address to, uint amount) external;
    function transferSnowflakeBalanceFromVia(uint einFrom, address via, uint einTo, uint amount, bytes calldata _bytes)
        external;
    function withdrawSnowflakeBalanceFromVia(uint einFrom, address via, address to, uint amount, bytes calldata _bytes)
        external;
}

// File: contracts/interfaces/SnowflakeResolverInterface.sol

pragma solidity ^0.5.0;

interface SnowflakeResolverInterface {
    function callOnAddition() external view returns (bool);
    function callOnRemoval() external view returns (bool);
    function onAddition(uint ein, uint allowance, bytes calldata extraData) external returns (bool);
    function onRemoval(uint ein, bytes calldata extraData) external returns (bool);
}

// File: contracts/SnowflakeResolver.sol

pragma solidity ^0.5.0;





contract SnowflakeResolver is Ownable {
    string public snowflakeName;
    string public snowflakeDescription;

    address public snowflakeAddress;

    bool public callOnAddition;
    bool public callOnRemoval;

    constructor(
        string memory _snowflakeName, string memory _snowflakeDescription,
        address _snowflakeAddress,
        bool _callOnAddition, bool _callOnRemoval
    )
        public
    {
        snowflakeName = _snowflakeName;
        snowflakeDescription = _snowflakeDescription;

        setSnowflakeAddress(_snowflakeAddress);

        callOnAddition = _callOnAddition;
        callOnRemoval = _callOnRemoval;
    }

    modifier senderIsSnowflake() {
        require(msg.sender == snowflakeAddress, "Did not originate from Snowflake.");
        _;
    }

    // this can be overriden to initialize other variables, such as e.g. an ERC20 object to wrap the HYDRO token
    function setSnowflakeAddress(address _snowflakeAddress) public onlyOwner {
        snowflakeAddress = _snowflakeAddress;
    }

    // if callOnAddition is true, onAddition is called every time a user adds the contract as a resolver
    // this implementation **must** use the senderIsSnowflake modifier
    // returning false will disallow users from adding the contract as a resolver
    function onAddition(uint ein, uint allowance, bytes memory extraData) public returns (bool);

    // if callOnRemoval is true, onRemoval is called every time a user removes the contract as a resolver
    // this function **must** use the senderIsSnowflake modifier
    // returning false soft prevents users from removing the contract as a resolver
    // however, note that they can force remove the resolver, bypassing onRemoval
    function onRemoval(uint ein, bytes memory extraData) public returns (bool);

    function transferHydroBalanceTo(uint einTo, uint amount) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(hydro.approveAndCall(snowflakeAddress, amount, abi.encode(einTo)), "Unsuccessful approveAndCall.");
    }

    function withdrawHydroBalanceTo(address to, uint amount) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(hydro.transfer(to, amount), "Unsuccessful transfer.");
    }

    function transferHydroBalanceToVia(address via, uint einTo, uint amount, bytes memory snowflakeCallBytes) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(
            hydro.approveAndCall(
                snowflakeAddress, amount, abi.encode(true, address(this), via, einTo, snowflakeCallBytes)
            ),
            "Unsuccessful approveAndCall."
        );
    }

    function withdrawHydroBalanceToVia(address via, address to, uint amount, bytes memory snowflakeCallBytes) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(
            hydro.approveAndCall(
                snowflakeAddress, amount, abi.encode(false, address(this), via, to, snowflakeCallBytes)
            ),
            "Unsuccessful approveAndCall."
        );
    }
}

// File: contracts/interfaces/IdentityRegistryInterface.sol

pragma solidity ^0.5.0;

interface IdentityRegistryInterface {
    function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        external pure returns (bool);

    // Identity View Functions /////////////////////////////////////////////////////////////////////////////////////////
    function identityExists(uint ein) external view returns (bool);
    function hasIdentity(address _address) external view returns (bool);
    function getEIN(address _address) external view returns (uint ein);
    function isAssociatedAddressFor(uint ein, address _address) external view returns (bool);
    function isProviderFor(uint ein, address provider) external view returns (bool);
    function isResolverFor(uint ein, address resolver) external view returns (bool);
    function getIdentity(uint ein) external view returns (
        address recoveryAddress,
        address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
    );

    // Identity Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function createIdentity(address recoveryAddress, address[] calldata providers, address[] calldata resolvers)
        external returns (uint ein);
    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, address[] calldata resolvers,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addAssociatedAddress(
        address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function addAssociatedAddressDelegated(
        address approvingAddress, address addressToAdd,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function removeAssociatedAddress() external;
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function addProviders(address[] calldata providers) external;
    function addProvidersFor(uint ein, address[] calldata providers) external;
    function removeProviders(address[] calldata providers) external;
    function removeProvidersFor(uint ein, address[] calldata providers) external;
    function addResolvers(address[] calldata resolvers) external;
    function addResolversFor(uint ein, address[] calldata resolvers) external;
    function removeResolvers(address[] calldata resolvers) external;
    function removeResolversFor(uint ein, address[] calldata resolvers) external;

    // Recovery Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function triggerRecoveryAddressChange(address newRecoveryAddress) external;
    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) external;
    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function triggerDestruction(
        uint ein, address[] calldata firstChunk, address[] calldata lastChunk, bool resetResolvers
    ) external;
}

// File: contracts/zeppelin/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
* @title SafeMath
* @dev Math operations with safety checks that revert on error
*/
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/resolvers/Charity.sol

pragma solidity ^0.5.0;








 contract Charity is SnowflakeResolver{
     using SafeMath for uint256;
     
     //states for project phases
     
     enum State{
         Approved,
         Awaiting,
         Disabled
     }
     
     //State variables
     
     
     //max amount to be raised,refunds excess back to donators
     uint256 public charityGoal;
     
     
     //The current donations for the Charity
    uint256 public currentBalance;
    
    //deadline set for the Charity
    uint public raiseBy;
    
    //title for the Charity
    string public title;
    
    //description for the Charity
    string public description;
    
    //snowflake address
    address _snowflakeAddress;
    
    //overlord address
    address public overlord;
    
    //the only address that can withdraw the funds...should be set by the charity owner
    address public charityOwnerAddress;
    
    
    
    address _creatorAddress;
     
     // initialize on create
     State public state = State.Awaiting;
     
     //keeps track of all contributions by address
     mapping(uint => uint ) public contributions;
     
     //keeps track of all registered participants
     mapping(uint=>bool) public aParticipant;
     
     //emitted when funding is received
     event fundingReceived(address contributor,uint amount,uint currentTotal);
     
     //emitted when donations are paid out to the creator
     event creatorPaid(address recipient);
     
     //emitted when the charity is approved
     event charityApproved(uint timeApproved);
     
     //emitted when the charity is disabled
     event charityDisabled(uint timeDisabled); 
     
     
     
     
     //confirm current State
     
     modifier inState(State _state){
         require(state==_state,"this project has not been approved or has been disabled");
         _;
     }
     

     
     //checks if the ein has this contract as a resolver
     modifier isParticipant(address _target){
         uint _ein=checkEIN(_target);
    require(aParticipant[_ein]==true, 'this EIN has not registered as a participant');
    _;
}

     //checks if target has an ein
     modifier HasEIN(address target){
    require(checkforReg(target)==true);
    _;
}


//double check that this project has not expired
modifier notExpired{
    require(checkIfCharityExpired()==false,"Project has expired");
    _;
}

modifier GoalNotReached{
    require (checkIfFundingComplete()==false,"Goal has been reached");
    _;
}

modifier onlyOverlord{
    require (msg.sender==overlord,"You are not the charity overlord");
    _;
}

modifier onlyCharityOwner{
    require (msg.sender==charityOwnerAddress,"You are not the charity owner");
    _;
}
    constructor (
         address snowflakeAddress,
         string memory projectTitle,
         string memory projectDesc,
         uint charityEnd,
         uint goalAmount,
         address _owner,
         address _overlord) SnowflakeResolver(projectTitle, projectDesc, snowflakeAddress, true, false) public {
             snowflakeAddress=_snowflakeAddress;
             charityOwnerAddress=_owner;
             title= projectTitle;
             description= projectDesc;
             charityGoal = convertToRealAmount(goalAmount);
            raiseBy= now+(charityEnd)*(1 days);
             currentBalance = 0;
             overlord=_overlord;
         }
         
         function checkEIN(address _address) internal HasEIN(_address) returns(uint){
        SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
    IdentityRegistryInterface idRegistry= IdentityRegistryInterface(snowfl.identityRegistryAddress());
       uint Ein=idRegistry.getEIN(_address);
       return Ein;
   }
       function convertToRealAmount(uint256 firstAmount) internal pure returns(uint){
          uint256 finalAmount= firstAmount.mul(1000000000000000000);
          return finalAmount;
       }
       
       //approve a charity so it can start receiving donations
       function approveCharity() public onlyOverlord {
           state=State.Approved;
           emit charityApproved(now);
       }

        //disable this charity so it can stop receive funding
       function disableCharity() public onlyOverlord {
           state=State.Disabled;
           emit charityDisabled(now);
           
       }
       
         function checkforReg(address _target) public  returns(bool){
    SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
    IdentityRegistryInterface idRegistry= IdentityRegistryInterface(snowfl.identityRegistryAddress());
    _target=msg.sender;
    bool hasId=idRegistry.hasIdentity(msg.sender);
    return hasId;
}

 //called to register any new actor in the system
//makes the ein to be a participant in the system
function onAddition(uint ein,uint /**allocation**/,bytes memory) public senderIsSnowflake() returns (bool){
     aParticipant[ein]=true;
    return true;
   
}
function onRemoval(uint, bytes memory) public senderIsSnowflake() returns (bool) {}
 
         //main withdraw function that can be called anytime will send all funds from the contract
     function withdrawContributions(address to) public onlyCharityOwner {
        SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
        HydroInterface hydro = HydroInterface(snowfl.hydroTokenAddress());
        withdrawHydroBalanceTo(to, hydro.balanceOf(address(this)));
        currentBalance=currentBalance.sub(hydro.balanceOf(address(this)));
        emit creatorPaid(to);
    }
     
     //function to allow registered participants contribute to a charity
      function contribute(uint _amount) public inState(State.Approved) notExpired() isParticipant(msg.sender) {
          require(checkEIN(msg.sender) !=checkEIN(charityOwnerAddress),"you cannot donate to your own Charity");
          uint _realAmount= convertToRealAmount(_amount);
            SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
            uint ein=checkEIN(msg.sender);
             snowfl.withdrawSnowflakeBalanceFrom(ein, address(this), _realAmount);
           contributions[ein]=contributions[ein].add(convertToRealAmount(_amount));
           currentBalance=currentBalance.add(convertToRealAmount(_amount));
           
           emit fundingReceived(msg.sender,_amount,currentBalance);
          
           }   
           
    
   // check if the the charity has reached its goal    
     function checkIfFundingComplete() public view returns(bool){
         if (currentBalance>=charityGoal){
            return (true);
         }
         else{
 return false;
     }
     }
     
    
     
     //checks if the charity has expired
     function checkIfCharityExpired() public view returns(bool){
         if(now>=raiseBy){
             return(true);

         }
     }
         
         //check the remaining amount before project reaches its goal
         //should be run when the project has not reached its goal
         function checkRemainingAmount() public view notExpired() returns(uint)  {
             uint _Amount= charityGoal.sub(currentBalance);
            
             return(_Amount);
         }
         
         //check remaining time before project expiration
         //should be called when the project has not expired
             function checkRemainingTime() public view  returns(uint)  {
                 if(now>=raiseBy){
             return 0;
                 }
                 else{
                     return raiseBy;
         }}
         
         function checkState() public view returns(State){
             return state;
         }
       
       
 }

// File: contracts/resolvers/CharityFactory.sol

pragma solidity ^0.5.0;


contract charityFactory {
address snowflake;
address public globalOverlord;

Charity[] public charities;

event newCharityCreated(
    address indexed _deployedAddress
);

modifier onlyOverlord{
    require (msg.sender==globalOverlord,"You are not the OVERLORD");
    _;
}

constructor(address _snowflake) public{
    snowflake=_snowflake;
    
    //sets the deployer of the factory contract as the overlord
    globalOverlord=msg.sender;
}

//creates a new charity instance
function createNewCharity(string memory _name,string memory _description,uint _days,uint _maxAmount,address _ownerAddress) public returns(address newContract){
       Charity c = new Charity(snowflake,_name,_description,_days,_maxAmount,_ownerAddress,globalOverlord);
       charities.push(c);
       emit newCharityCreated(address(c));
        return address(c);
    //returns the new election contract address

}

 //function to transfer the overlord position to another address
 //can only be called by the existing overlord
     function transferOverlordAuthority(address _newOverlord) public onlyOverlord {
        globalOverlord=_newOverlord;
     }
     
     //returns the addresses of all charities that have all been deployed
 function returnAllCharities() external view returns(Charity[] memory){
        return charities;
    }

}