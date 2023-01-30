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

// File: contracts/resolvers/Voting.sol

pragma solidity ^0.5.0;






contract Voting is SnowflakeResolver {
mapping(uint=>Candidate) public candidates;
mapping(uint=>bool) public aParticipant;
mapping(uint=>bool) public aCandidate;
mapping(uint=>bool) private hasVoted;

struct Candidate{
    uint voteCount;
}


//uint256 candidateFee= 20000000000000000000;//200tokens
uint256 regFee= 100000000000000000000;//100tokens

//this is the routed address where all fees will go to be later burned
address public FEEWALLET;


uint256 burnAmount=1000000000000000000000;//1000tokens
uint maxNoOfCandidates=2;
address _snowflakeAddress;
uint deadlineInDays;

uint[] candidateEINs;
uint[] voterEINs;

//requires that the ein is a registered candidate
modifier isCandidate(uint ein){
    require(aCandidate[ein]==true,'This EIN has not registered as a candidate');
    _;
}

//requires that the ein has set this contract a resolver
modifier isParticipant(uint _ein){
    require(aParticipant[_ein]==true, 'this EIN has not registered as a participant');
    _;
}

//requires that the entered ein is not a candidate yet
modifier isNotCandidate(uint _ein){
    require(aParticipant[_ein]==true && aCandidate[_ein]==false,"you are a candidate");
    _;
}

//requires that the target does not have a hydroId yet
modifier noIdYet(address target){
    require(checkforReg(target)==false);
    _;
}

modifier HasEIN(address target){
    require(checkforReg(target)==true);
    _;
}

//requires that the deadline hasn't passed
modifier voteStillValid(){
    require (now<=deadlineInDays,"this election has expired");
    _;
}


event voted(uint _candidate);
event becameCandidate(uint _candidateEIN);
event registeredAsVoter(uint voterEin);
event newDeadlineSet(uint _newDeadline);

 constructor (address snowflakeAddress,string memory _name,string memory _description,uint _days,address feeOwner)
        SnowflakeResolver(_name, _description, snowflakeAddress, true, false) public
    {
        snowflakeAddress=_snowflakeAddress;
        deadlineInDays=now+_days*1 days;
        FEEWALLET=feeOwner;
        
    }
//sets the maximum no of candidates for this resolver
//can only be set by contract owner
function setMaxCandidacy(uint _max) public  voteStillValid() onlyOwner(){
    maxNoOfCandidates=_max;
}
//check if address interacting with contract already has an ein
function checkforReg(address _target) public  returns(bool){
    SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
    IdentityRegistryInterface idRegistry= IdentityRegistryInterface(snowfl.identityRegistryAddress());
    _target=msg.sender;
    bool hasId=idRegistry.hasIdentity(msg.sender);
    return hasId;
}

//basic check to return ein of the specific address
   function checkEIN(address _address) public returns(uint){
        SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
    IdentityRegistryInterface idRegistry= IdentityRegistryInterface(snowfl.identityRegistryAddress());
       uint Ein=idRegistry.getEIN(_address);
       return Ein;
   }
        
 /**   

//implement create Identity function
//might not be needed for now
function createId(address recoveryAddress) public returns(uint ein){
    SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
    IdentityRegistryInterface idRegistry= IdentityRegistryInterface(snowfl.identityRegistryAddress());
    address[] memory _providers = new address [](2);
    address[] memory _resolvers= new address [](1);
    _providers[0]= address(this);
    _providers[1]= _snowflakeAddress;
    _resolvers[0]= address(this);
    
    return idRegistry.createIdentity(recoveryAddress,_providers,_resolvers);
    
    
} 

**/
//called to register any new actor in the system
//makes the ein to be a participant in the system
//a fee of 100 tokens is required
function onAddition(uint ein,uint /**allocation**/,bytes memory) public senderIsSnowflake() returns (bool){
    SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
    snowfl.withdrawSnowflakeBalanceFrom(ein, FEEWALLET, regFee );
    aParticipant[ein]=true;
     emit registeredAsVoter(ein);
    return true;
   
}

 function onRemoval(uint, bytes memory) public senderIsSnowflake() returns (bool) {}
 
 //anyone who wants to become a candidate
 //1000 hydro tokens are deducted from the ein of msg.sender and sent to FEEWALLET
 function becomeCandidate(uint ein) public isParticipant(ein)  voteStillValid() isNotCandidate(ein){
     SnowflakeInterface snowfl=SnowflakeInterface(snowflakeAddress);
   uint candidateCount= candidateEINs.length;
    require(candidateCount<=maxNoOfCandidates,"candidate limit reached!");
    snowfl.withdrawSnowflakeBalanceFrom(ein,FEEWALLET, burnAmount);
    aCandidate[ein]=true;
    candidateEINs.push(ein);
    emit becameCandidate(ein);
 }
 
 //main vote function
function vote(uint _ein) public  HasEIN(msg.sender) isCandidate(_ein)  voteStillValid() returns(bool){
 SnowflakeInterface snowfl=SnowflakeInterface(snowflakeAddress);
 IdentityRegistryInterface idRegistry= IdentityRegistryInterface(snowfl.identityRegistryAddress());
 uint ein=checkEIN(msg.sender);
 
 require(aParticipant[ein]==true,'you are not a voter,register first');
 require (aCandidate[ein]==false,"you are a candidate");
 require(idRegistry.isResolverFor(ein,address(this)),"This EIN has not set this resolver.");
 require (hasVoted[ein]==false,"you have already voted");
 
 candidates[_ein].voteCount++;
 hasVoted[ein]=true;
  emit voted(_ein);
 return (true);


}
//return the current max number of candidates
function getMaxCandidates() public view returns(uint[] memory,uint){
    return(candidateEINs,maxNoOfCandidates);
}



    function withdrawFees(address to) public onlyOwner {
        SnowflakeInterface snowfl = SnowflakeInterface(snowflakeAddress);
        HydroInterface hydro = HydroInterface(snowfl.hydroTokenAddress());
        withdrawHydroBalanceTo(to, hydro.balanceOf(address(this)));
    }
    
    function setNewDeadline(uint _newDays) public onlyOwner voteStillValid returns(uint){
        deadlineInDays=now+_newDays*1 days;
        emit newDeadlineSet(deadlineInDays);
        return deadlineInDays;
    }
    
    function getDeadline() public view returns(uint){
        return deadlineInDays;
    }

}

// File: contracts/resolvers/electionFactory.sol

pragma solidity ^0.5.0;


contract electionFactory {
address snowflake;
address feeOwner;
mapping(uint256 => bool) public electionIds;

event newElectionCreated(
    address indexed _deployedAddress,uint _id
);
constructor(address _snowflake) public{
    snowflake=_snowflake;
    feeOwner=msg.sender;
}


function createNewElection(uint256 _electionID,string memory _name,string memory _description,uint _days) public returns(address newContract){
        require(electionIds[_electionID]==false,"election id already exists");
       Voting v = new Voting(snowflake,_name,_description,_days,feeOwner);
       emit newElectionCreated(address(v),_electionID);
       electionIds[_electionID]=true;
        return address(v);
    //returns the new election contract address

}

}