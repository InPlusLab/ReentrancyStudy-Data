/**

 *Submitted for verification at Etherscan.io on 2018-12-30

*/



pragma solidity ^0.4.24;



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



// File: contracts/lib/lifecycle/Destructible.sol



contract Destructible is Ownable {

	function selfDestruct() public onlyOwner {

		selfdestruct(owner);

	}

}



// File: contracts/lib/ownership/ZapCoordinatorInterface.sol



contract ZapCoordinatorInterface is Ownable {

	function addImmutableContract(string contractName, address newAddress) external;

	function updateContract(string contractName, address newAddress) external;

	function getContractName(uint index) public view returns (string);

	function getContract(string contractName) public view returns (address);

	function updateAllDependencies() external;

}



// File: contracts/lib/ownership/Upgradable.sol



pragma solidity ^0.4.24;



contract Upgradable {



	address coordinatorAddr;

	ZapCoordinatorInterface coordinator;



	constructor(address c) public{

		coordinatorAddr = c;

		coordinator = ZapCoordinatorInterface(c);

	}



    function updateDependencies() external coordinatorOnly {

       _updateDependencies();

    }



    function _updateDependencies() internal;



    modifier coordinatorOnly() {

    	require(msg.sender == coordinatorAddr, "Error: Coordinator Only Function");

    	_;

    }

}



// File: contracts/lib/platform/PiecewiseLogic.sol



library PiecewiseLogic {

    function sumOfPowers(uint n, uint i) internal pure returns (uint) {

        require(i <= 6 && i >= 0, "Error: Invalid Piecewise Logic");



        if ( i == 0 ) return n;

        if ( i == 1 ) return (n * (n + 1)) / 2;

        if ( i == 2 ) return (n * (n + 1) * (2 * n + 1)) / 6;

        if ( i == 3 ) return ((n * (n + 1)) / 2) ** 2;

        if ( i == 4 ) return (n * (n + 1) * (2 * n + 1) * (3 * n * n + 3 * n - 1)) / 30;

        if ( i == 5 ) return (n * (n + 1)) ** 2 * (2 * n ** 2 + 2 * n - 1);

        if ( i == 6 ) return (n * (n + 1) * (2 * n + 1) * (3 * n ** 4 + 6 * n ** 3 - 3 * n + 1)) / 42;



        // impossible

        return 0;

    }



    function evaluateFunction(int[] curve, uint a, uint b) internal pure returns (int) {

        uint i = 0;

        int sum = 0;



        // Require to be within the dot limit

        require(a + b <= uint(curve[curve.length - 1]), "Error: Function not in dot limit");



        // Loop invariant: i should always point to the start of a piecewise piece (the length)

        while ( i < curve.length ) {

            uint l = uint(curve[i]);

            uint end = uint(curve[i + l + 1]);



            // Index of the next piece's end

            uint nextIndex = i + l + 2;



            if ( a > end ) { // move on to the next piece

                i = nextIndex;

                continue;

            }



            sum += evaluatePiece(curve, i, a, (a + b > end) ? end - a : b);



            if ( a + b <= end ) {

                // Entire calculation is within this piece

                return sum;

            }

            else {

                b -= end - a + 1; // Remove the dots we've already bound from b

                a = end;          // Move a up to the end

                i = nextIndex;    // Move index up

            }

        }

    }



    function evaluatePiece(int[] curve, uint index, uint a, uint b) internal pure returns (int){

        int sum = 0;

        uint len = uint(curve[index]);

        uint base = index + 1;

        uint end = base + len; // index of last term



        // iterate between index+1 and the end of this piece

        for ( uint i = base; i < end; i++ ) {

            sum += curve[i] * int(sumOfPowers(a + b, i - base) - sumOfPowers(a - 1, i - base));

        }



        require(sum >= 0, "Error: Cost must be greater than zero");

        return sum;

    }

}



// File: contracts/platform/registry/RegistryInterface.sol



// Technically an abstract contract, not interface (solidity compiler devs are working to fix this right now)



contract RegistryInterface {

    function initiateProvider(uint256, bytes32) public returns (bool);

    function initiateProviderCurve(bytes32, int256[], address) public returns (bool);

    function setEndpointParams(bytes32, bytes32[]) public;

    function getEndpointParams(address, bytes32) public view returns (bytes32[]);

    function getProviderPublicKey(address) public view returns (uint256);

    function getProviderTitle(address) public view returns (bytes32);

    function setProviderParameter(bytes32, bytes) public;

    function getProviderParameter(address, bytes32) public view returns (bytes);

    function getAllProviderParams(address) public view returns (bytes32[]);

    function getProviderCurveLength(address, bytes32) public view returns (uint256);

    function getProviderCurve(address, bytes32) public view returns (int[]);

    function isProviderInitiated(address) public view returns (bool);

    function getAllOracles() external view returns (address[]);

    function getProviderEndpoints(address) public view returns (bytes32[]);

    function getEndpointBroker(address, bytes32) public view returns (address);

}



// File: contracts/platform/bondage/currentCost/CurrentCostInterface.sol



contract CurrentCostInterface {    

    function _currentCostOfDot(address, bytes32, uint256) public view returns (uint256);

    function _dotLimit(address, bytes32) public view returns (uint256);

    function _costOfNDots(address, bytes32, uint256, uint256) public view returns (uint256);

}



// File: contracts/platform/bondage/currentCost/CurrentCost.sol



contract CurrentCost is Destructible, CurrentCostInterface, Upgradable {



    RegistryInterface registry;



    constructor(address c) Upgradable(c) public {

        _updateDependencies();

    }



    function _updateDependencies() internal {

        registry = RegistryInterface(coordinator.getContract("REGISTRY"));

    }



    /// @dev calculates current cost of dot

    /// @param oracleAddress oracle address

    /// @param endpoint oracle endpoint

    /// @param start nth dot to calculate price of

    /// @return cost of next dot

    function _currentCostOfDot(

        address oracleAddress,

        bytes32 endpoint,

        uint256 start

    )

        public

        view

        returns (uint256 cost)

    {

        return _costOfNDots(oracleAddress, endpoint, start, 0);

    }



    /// @dev calculates cost of n dots

    /// @param oracleAddress oracle address

    /// @param endpoint oracle endpoint

    /// @param start nth dot to start calculating price at

    /// @param nDots to bond

    /// @return cost of next dot

    function _costOfNDots(

        address oracleAddress,

        bytes32 endpoint,

        uint256 start,

        uint256 nDots

    )

        public

        view

        returns (uint256 cost)

    {





        uint256 length = registry.getProviderCurveLength(oracleAddress,endpoint);

        int[] memory curve = new int[](length);

        curve = registry.getProviderCurve(oracleAddress, endpoint);



        int res = PiecewiseLogic.evaluateFunction(curve, start, nDots);

        require(res >= 0, "Error: Cost of dots cannot be negative");

        return uint256(res);

    }



   function _dotLimit( 

        address oracleAddress,

        bytes32 endpoint

    )

        public

        view

        returns (uint256)

    {

        uint256 length = registry.getProviderCurveLength(oracleAddress,endpoint);

        int[] memory curve = new int[](length);

        curve = registry.getProviderCurve(oracleAddress, endpoint);



        return uint(curve[length-1]);

    }

}