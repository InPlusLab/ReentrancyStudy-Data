/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

pragma solidity 0.5.16;


/// @title Version
contract Version {
    string public semanticVersion;

    /// @notice Constructor saves a public version of the deployed Contract.
    /// @param _version Semantic version of the contract.
    constructor(string memory _version) internal {
        semanticVersion = _version;
    }
}


/// @title Factory
contract Factory is Version {
    event FactoryAddedContract(address indexed _contract);

    modifier contractHasntDeployed(address _contract) {
        require(contracts[_contract] == false);
        _;
    }

    mapping(address => bool) public contracts;

    constructor(string memory _version) internal Version(_version) {}

    function hasBeenDeployed(address _contract) public view returns (bool) {
        return contracts[_contract];
    }

    function addContract(address _contract)
        internal
        contractHasntDeployed(_contract)
        returns (bool)
    {
        contracts[_contract] = true;
        emit FactoryAddedContract(_contract);
        return true;
    }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value)
        external
        returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract PaymentAddress is Ownable {
    address public collector;

    event PaymentMade(
        address indexed _payer,
        address indexed _collector,
        uint256 _value
    );
    event ClaimedTokens(
        address indexed _token,
        address indexed _collector,
        uint256 _amount
    );

    constructor(address _collector, address _owner) public {
        collector = _collector;
        _transferOwnership(_owner);
    }

    function() external payable {
        emit PaymentMade(msg.sender, collector, msg.value);
        // https://diligence.consensys.net/blog/2019/09/stop-using-soliditys-transfer-now/
        (bool success, ) = collector.call.value(msg.value)("");
        require(success, "Eth forward failed.");
    }

    /// @notice This method can be used by the controller to extract tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    function claimTokens(address _token) public onlyOwner {
        ERC20 erc20token = ERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));

        require(
            erc20token.transfer(collector, balance),
            "Token transfer could not be executed."
        );

        emit ClaimedTokens(_token, collector, balance);
    }
}


contract PaymentAddressFactory is Factory {
    // index of created contracts
    mapping(address => address[]) public paymentAddresses;

    constructor() public Factory("1.1.0") {}

    // deploy a new contract
    function newPaymentAddress(address _collector, address _owner)
        public
        returns (address newContract)
    {
        address paymentAddress = address(
            new PaymentAddress(_collector, _owner)
        );
        paymentAddresses[_collector].push(paymentAddress);
        addContract(paymentAddress);
        return paymentAddress;
    }
}