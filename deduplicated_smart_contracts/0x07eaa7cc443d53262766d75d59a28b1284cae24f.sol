/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

pragma solidity ^0.4.25;

// File: contracts/lib/ownership/Ownable.sol

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    constructor() public { owner = msg.sender; }

    /// @dev Throws if called by any contract other than latest designated caller
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// File: contracts/lib/token/FactoryTokenInterface.sol

contract FactoryTokenInterface is Ownable {
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function mint(address _to, uint256 _amount) public returns (bool);
    function burnFrom(address _from, uint256 _value) public;
}

// File: contracts/lib/token/TokenFactoryInterface.sol

contract TokenFactoryInterface {
    function create(string _name, string _symbol) public returns (FactoryTokenInterface);
}

// File: contracts/lib/ownership/ZapCoordinatorInterface.sol

contract ZapCoordinatorInterface is Ownable {
    function addImmutableContract(string contractName, address newAddress) external;
    function updateContract(string contractName, address newAddress) external;
    function getContractName(uint index) public view returns (string);
    function getContract(string contractName) public view returns (address);
    function updateAllDependencies() external;
}

// File: contracts/platform/bondage/BondageInterface.sol

contract BondageInterface {
    function bond(address, bytes32, uint256) external returns(uint256);
    function unbond(address, bytes32, uint256) external returns (uint256);
    function delegateBond(address, address, bytes32, uint256) external returns(uint256);
    function escrowDots(address, address, bytes32, uint256) external returns (bool);
    function releaseDots(address, address, bytes32, uint256) external returns (bool);
    function returnDots(address, address, bytes32, uint256) external returns (bool success);
    function calcZapForDots(address, bytes32, uint256) external view returns (uint256);
    function currentCostOfDot(address, bytes32, uint256) public view returns (uint256);
    function getDotsIssued(address, bytes32) public view returns (uint256);
    function getBoundDots(address, address, bytes32) public view returns (uint256);
    function getZapBound(address, bytes32) public view returns (uint256);
    function dotLimit( address, bytes32) public view returns (uint256);
}

// File: contracts/platform/bondage/currentCost/CurrentCostInterface.sol

contract CurrentCostInterface {
    function _currentCostOfDot(address, bytes32, uint256) public view returns (uint256);
    function _dotLimit(address, bytes32) public view returns (uint256);
    function _costOfNDots(address, bytes32, uint256, uint256) public view returns (uint256);
}

// File: contracts/platform/registry/RegistryInterface.sol

contract RegistryInterface {
    function initiateProvider(uint256, bytes32) public returns (bool);
    function initiateProviderCurve(bytes32, int256[], address) public returns (bool);
    function setEndpointParams(bytes32, bytes32[]) public;
    function getEndpointParams(address, bytes32) public view returns (bytes32[]);
    function getProviderPublicKey(address) public view returns (uint256);
    function getProviderTitle(address) public view returns (bytes32);
    function setProviderParameter(bytes32, bytes) public;
    function setProviderTitle(bytes32) public;
    function clearEndpoint(bytes32) public;
    function getProviderParameter(address, bytes32) public view returns (bytes);
    function getAllProviderParams(address) public view returns (bytes32[]);
    function getProviderCurveLength(address, bytes32) public view returns (uint256);
    function getProviderCurve(address, bytes32) public view returns (int[]);
    function isProviderInitiated(address) public view returns (bool);
    function getAllOracles() external view returns (address[]);
    function getProviderEndpoints(address) public view returns (bytes32[]);
    function getEndpointBroker(address, bytes32) public view returns (address);
}

// File: contracts/lib/platform/FundingContest.sol

/*
Fundsaising where users can bond to contestant curves which mint tokens( unbondabe*),
winner decided by oracle
contract unbonds from loser curves
winner takes all of fund

Starting Fundsaising Contest:

    deploys with contest uninitialized: status = Uninitialized

    anyone can initialize new token:backed curve

    owner initializes contest with oracle: status = Initialized

Expired :
    When Oracle fails to respond in time
    contract will unbond from all Endpoints
    All users will be able to unbond to receive what they have paid

Resolve Funding Contest:

    owner calls query to data provider oracle.

    Data provider oracle respond with data, trigger judge function to set winning curve

    anyone calls settle, contest unbonds from all curves, winner endpoint owner receive all funds

    *holders of winning token can optionally unbond
*/

contract FundingContest is Ownable {

    CurrentCostInterface currentCost;
    FactoryTokenInterface public reserveToken;
    ZapCoordinatorInterface public coord;
    TokenFactoryInterface public tokenFactory;
    BondageInterface bondage;

    enum ContestStatus {
        Uninitialized,      //
        Initialized,       // ready for buys
        Expired,          // Oracle did not respond in time -> ready to refund
        Judged,          // winner determined
        Settled         // value of winning tokens determined
    }

    address public oracle;    // address of oracle who will choose the winner
    uint256 public ttl;    // time allowed before, close and judge. if time expired, allow unbond from all curves
    bytes32 public winner;    // curve identifier of the winner
    uint256 public winValue;  // final value of the winning token
    ContestStatus public status; //state of contest

    mapping(bytes32 => address) public curves; // map of endpoint specifier to token-backed dotaddress
    bytes32[] public curves_list; // array of endpoint specifiers
    mapping(bytes32 => address) public beneficiaries; // beneficiaries of endpoint that participate in funding contest
    mapping(bytes32 => address) public curve_creators; 

    mapping(address => uint256) public redeemed; // map of address redemption amount in case of expired
    address[] public redeemed_list;

    event DotTokenCreated(address tokenAddress);
    event Bonded(bytes32 indexed endpoint, uint256 indexed numDots, address indexed sender);
    event Unbonded(bytes32 indexed endpoint,uint256 indexed amount, address indexed sender);

    event Initialized(address indexed oracle);
    event Closed();
    event Judged(bytes32 winner);
    event Settled(address indexed winnerAddress, bytes32 indexed winnerEndpoint);
    event Expired(bytes32 indexed endpoint, uint256 indexed totalDots);
    event Reset();

    constructor(
        address coordinator,
        address factory,
        uint256 providerPubKey,
        bytes32 providerTitle
    ){
        coord = ZapCoordinatorInterface(coordinator);
        reserveToken = FactoryTokenInterface(coord.getContract("ZAP_TOKEN"));
        bondage = BondageInterface(coord.getContract("BONDAGE"));
        currentCost = CurrentCostInterface(coord.getContract("CURRENT_COST")); //always allow bondage to transfer from wallet
        reserveToken.approve(bondage, ~uint256(0));
        tokenFactory = TokenFactoryInterface(factory);

        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY"));
        registry.initiateProvider(providerPubKey, providerTitle);
        status = ContestStatus.Uninitialized;
    }

// contest lifecycle

    function initializeContest(
        address oracleAddress,
        uint256 _ttl
    ) onlyOwner public {
        require( status == ContestStatus.Uninitialized, "Contest already initialized");
        oracle = oracleAddress;
        ttl = _ttl + block.number;
        status = ContestStatus.Initialized;
        emit Initialized(oracle);
    }

  /// TokenDotFactory methods

    function initializeCurve(
        bytes32 endpoint,
        bytes32 symbol,
        int256[] curve
    ) public returns(address) {
        // require(status==ContestStatus.Initialized,"Contest is not initalized")
        require(curves[endpoint] == 0, "Curve endpoint already exists or used in the past. Please choose a new endpoint");

        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY"));
        registry.initiateProviderCurve(endpoint, curve, address(this));

        curves[endpoint] = newToken(bytes32ToString(endpoint), bytes32ToString(symbol));
        curves_list.push(endpoint);
        registry.setProviderParameter(endpoint, toBytes(curves[endpoint]));
        emit DotTokenCreated(curves[endpoint]);
				curve_creators[endpoint] = msg.sender;
				return curves[endpoint];
    }

    //whether this contract holds tokens or coming from msg.sender,etc
    function bond(bytes32 endpoint, uint numDots) public  {
        require( status == ContestStatus.Initialized, " contest is not initiated");

        uint256 issued = bondage.getDotsIssued(address(this), endpoint);
        uint256 numReserve = currentCost._costOfNDots(address(this), endpoint, issued + 1, numDots - 1);

        require(
            reserveToken.transferFrom(msg.sender, address(this), numReserve),
            "insufficient accepted token numDots approved for transfer"
        );
        redeemed[msg.sender]=numReserve;

        reserveToken.approve(address(bondage), numReserve);
        bondage.bond(address(this), endpoint, numDots);
        FactoryTokenInterface(curves[endpoint]).mint(msg.sender, numDots);
        emit Bonded(endpoint, numDots, msg.sender);
    }

    function judge(bytes32 endpoint) external {

        require(status!=ContestStatus.Expired, "Contest is already in Expired state, ready to unbond");

        if(block.number > ttl ){ //expired
          status=ContestStatus.Expired;
        }
        else{
          require( status == ContestStatus.Initialized, "Contest not initialized" );
          require( msg.sender == oracle, "Only designated Oracle can judge");
          require(beneficiaries[endpoint]!=0,"Endpoint invalid");
          winner = endpoint;
          status = ContestStatus.Judged;
          emit Judged(winner);
        }
    }

    /**
    If expired -> allow unbond for all
    Else -> allow unbond for winner
    */
    function settle() public {
        if(status == ContestStatus.Expired || block.number > ttl){//expired
          emit Expired(winner,1);
          for(uint256 i = 0; i<curves_list.length; i++){
            uint256 numDots = bondage.getDotsIssued(address(this), curves_list[i]);
            if(numDots>0){ //unbond from this address for all
              bondage.unbond(address(this), curves_list[i], numDots);
            }
            emit Expired(curves_list[i],numDots);
          }
          status=ContestStatus.Expired;
        }
        else{
          require( status == ContestStatus.Judged, "winner not determined");
          uint256 dots;
          uint256 tokenDotBalance;

          uint256 numWin = bondage.getDotsIssued(address(this), winner);
          require(numWin>0,"No dots to settle");

          for( uint256 j = 0; j < curves_list.length; j++) {
            if(curves_list[j]!=winner){

              dots =  bondage.getDotsIssued(address(this), curves_list[j]);
              if( dots > 0) {
                  bondage.unbond(address(this), curves_list[j], dots);
              }
            }
          }
          winValue = reserveToken.balanceOf(address(this))/ numWin;

          status = ContestStatus.Settled;
          emit Settled(beneficiaries[winner], winner);

        }
    }

    //TODO ensure all has been redeemed or enough time has elasped
    function reset() public {
        require(msg.sender == oracle);
        //todo balance is 0
        require(status == ContestStatus.Settled || status == ContestStatus.Expired, "contest not settled");
        if( status == ContestStatus.Expired ) {
            require(reserveToken.balanceOf(address(this)) == 0, "funds remain");
        }

        delete redeemed_list;
        delete curves_list;
        status = ContestStatus.Initialized;
        emit Reset();
    }

    // If the contract is expired, users can call unbond to get refund back
    function unbond(bytes32 endpoint) public returns(uint256) {

        uint256 issued = bondage.getDotsIssued(address(this), endpoint);
        uint256 reserveCost;
        uint256 tokensBalance;
        FactoryTokenInterface curveToken = FactoryTokenInterface(getTokenAddress(endpoint));

        if( status == ContestStatus.Initialized || status == ContestStatus.Expired) {
            //oracle has taken too long to judge winner so unbonds will be allowed for all
            require(block.number > ttl, "oracle query not expired.");
            // require(status == ContestStatus.Settled, "contest not settled");
            status = ContestStatus.Expired;

            //burn dot backed token
            tokensBalance = curveToken.balanceOf(msg.sender);
            require(tokensBalance>0, "Unsufficient balance to redeem");
            // transfer back to user what they paid
            reserveCost = redeemed[msg.sender];
            require(reserveCost>0,"No funding found");

            curveToken.burnFrom(msg.sender, tokensBalance);
            require(reserveToken.transfer(msg.sender, reserveCost), "transfer failed");

            emit Unbonded(endpoint, reserveCost, msg.sender);
            return reserveCost;
        }
        else {
            require( status == ContestStatus.Settled, " contest not settled");
            require(winner==endpoint, "only winners can unbond for rewards");

            tokensBalance = curveToken.balanceOf(msg.sender);
            require(tokensBalance>0, "Unsufficient balance to redeem");
            //get reserve value to send
            reserveCost = currentCost._costOfNDots(address(this), winner, issued + 1 - tokensBalance, tokensBalance - 1);

            //reward user's winning tokens unbond value + share of losing curves reserve token proportional to winning token holdings

            uint256 reward = ( winValue * tokensBalance )/2; //50% of winning goes to winner beneficiary
            uint256 funderReward = reward + reserveCost;

            //burn user's unbonded tokens
            bondage.unbond(address(this), winner,tokensBalance);
            // curveToken.approve(address(this),tokensBalance);
            curveToken.burnFrom(msg.sender, tokensBalance);
            //
            require(reserveToken.transfer(msg.sender, funderReward),"Failed to send to funder");
            require(reserveToken.transfer(beneficiaries[winner],reward),"Failed to send to beneficiary");
            return reward;
        }
    }

    function newToken(
        string name,
        string symbol
    )
        internal
        returns (address tokenAddress)
    {
        FactoryTokenInterface token = tokenFactory.create(name, symbol);
        tokenAddress = address(token);
        return tokenAddress;
    }

    function getTokenAddress(bytes32 endpoint) public view returns(address) {
        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY"));
        return bytesToAddr(registry.getProviderParameter(address(this), endpoint));
    }

    function getEndpoints() public view returns(bytes32[]){
      return curves_list;
    }

    function getStatus() public view returns(uint256){
      return uint(status);
    }

    function isEndpointValid(bytes32 _endpoint) public view returns(bool){
      for(uint256 i=0; i<curves_list.length;i++){
        if(_endpoint == curves_list[i]){
          return true;
        }
      }
      return false;
    }

    function setBeneficiary(bytes32 endpoint, address b) { 
       require(beneficiaries[endpoint] == 0, "Beneficiary already set for this curve");
       require(curve_creators[endpoint] == msg.sender, "Only curve creator can set beneficiary address");
       beneficiaries[endpoint] = b;
    }


    // https://ethereum.stackexchange.com/questions/884/how-to-convert-an-address-to-bytes-in-solidity
    function toBytes(address x) public pure returns (bytes b) {
        b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
    }

    //https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string
    function bytes32ToString(bytes32 x) public pure returns (string) {
        bytes memory bytesString = new bytes(32);
        bytesString = abi.encodePacked(x);
        return string(bytesString);
    }

    //https://ethereum.stackexchange.com/questions/15350/how-to-convert-an-bytes-to-address-in-solidity
    function bytesToAddr (bytes b) public pure returns (address) {
        uint result = 0;
        for (uint i = b.length-1; i+1 > 0; i--) {
            uint c = uint(b[i]);
            uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));
            result += to_inc;
        }
        return address(result);
    }
}

// File: contracts/platform/dispatch/DispatchInterface.sol

interface DispatchInterface {
    function query(address, string, bytes32, bytes32[]) external returns (uint256);
    function respond1(uint256, string) external returns (bool);
    function respond2(uint256, string, string) external returns (bool);
    function respond3(uint256, string, string, string) external returns (bool);
    function respond4(uint256, string, string, string, string) external returns (bool);
    function respondBytes32Array(uint256, bytes32[]) external returns (bool);
    function respondIntArray(uint256,int[] ) external returns (bool);
    function cancelQuery(uint256) external;
    function getProvider(uint256 id) public view returns (address);
    function getSubscriber(uint256 id) public view returns (address);
    function getEndpoint(uint256 id) public view returns (bytes32);
    function getStatus(uint256 id) public view returns (uint256);
    function getCancel(uint256 id) public view returns (uint256);
    function getUserQuery(uint256 id) public view returns (string);
    function getSubscriberOnchain(uint256 id) public view returns (bool);
}

// File: contracts/lib/platform/Client.sol

contract Client1 {
    /// @dev callback that provider will call after Dispatch.query() call
    /// @param id request id
    /// @param response1 first provider-specified param
    function callback(uint256 id, string response1) external;
}
contract Client2 {
    /// @dev callback that provider will call after Dispatch.query() call
    /// @param id request id
    /// @param response1 first provider-specified param
    /// @param response2 second provider-specified param
    function callback(uint256 id, string response1, string response2) external;
}
contract Client3 {
    /// @dev callback that provider will call after Dispatch.query() call
    /// @param id request id
    /// @param response1 first provider-specified param
    /// @param response2 second provider-specified param
    /// @param response3 third provider-specified param
    function callback(uint256 id, string response1, string response2, string response3) external;
}
contract Client4 {
    /// @dev callback that provider will call after Dispatch.query() call
    /// @param id request id
    /// @param response1 first provider-specified param
    /// @param response2 second provider-specified param
    /// @param response3 third provider-specified param
    /// @param response4 fourth provider-specified param
    function callback(uint256 id, string response1, string response2, string response3, string response4) external;
}

contract ClientBytes32Array {
    /// @dev callback that provider will call after Dispatch.query() call
    /// @param id request id
    /// @param response bytes32 array
    function callback(uint256 id, bytes32[] response) external;
}

contract ClientIntArray{
    /// @dev callback that provider will call after Dispatch.query() call
    /// @param id request id
    /// @param response int array
    function callback(uint256 id, int[] response) external;
}

// File: contracts/lib/platform/GitFundContest.sol

contract GitFundContest is Ownable, ClientBytes32Array {
  FundingContest public contest;
  ZapCoordinatorInterface public coordinator;
  BondageInterface bondage;
  DispatchInterface dispatch;
  address public owner;
  uint256 public query_id;
  uint256 public startPrice;
  bytes32[] public endpoints;
  uint256 queryId;
	uint256 start_time;

  constructor(
    address _cord,
    address _contest
  ){
    owner = msg.sender;
    contest = FundingContest(_contest);
    coordinator = ZapCoordinatorInterface(_cord);
    address bondageAddress = coordinator.getContract("BONDAGE");
    bondage = BondageInterface(bondageAddress);
    address dispatchAddress = coordinator.getContract("DISPATCH");
    dispatch = DispatchInterface(dispatchAddress);
    FactoryTokenInterface reserveToken = FactoryTokenInterface(coordinator.getContract("ZAP_TOKEN"));
    reserveToken.approve(address(bondageAddress),~uint256(0));
		start_time = now;
  }

  function bondToGitOracle(address _gitOracle,bytes32 _endpoint,uint256 _numDots)public returns (bool){
    bondage.bond(_gitOracle,_endpoint,_numDots);
    return true;

  }
  function queryToSettle(address _gitOracle,bytes32 _endpoint) public returns(uint256){
    require(msg.sender == owner, "Only owner can call query to settle");
		bytes32[] memory params = new bytes32[]( contest.getEndpoints().length + 1);
		params[0] = bytes32(now); // for the timestamp
		bytes32[] memory tmp_params = contest.getEndpoints();
		for ( uint i = 1; i < tmp_params.length; i++) {
				params[i] = tmp_params[i-1];
		}

		queryId = dispatch.query(_gitOracle,"GitCommits",_endpoint,params);
    return queryId;
  }

  function callback(uint256 _id, bytes32[] _endpoints) external {
    address dispatchAddress = coordinator.getContract("DISPATCH");
    require(address(msg.sender)==address(dispatchAddress),"Only accept response from dispatch");
    require(_id == queryId, "wrong query ID");
    require(contest.getStatus()==1,"Contest is not in initialized state"); //2 is the ReadyToSettle enum value
    return contest.judge(_endpoints[0]);

  }


}