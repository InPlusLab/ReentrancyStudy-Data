/**
 *Submitted for verification at Etherscan.io on 2019-11-04
*/

// File: contracts/lib/ERC20.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20
 * @dev A standard interface for tokens.
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20 {

    /// @dev Returns the total token supply
    function totalSupply() public view returns (uint256 supply);

    /// @dev Returns the account balance of the account with address _owner
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @dev Transfers _value number of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @dev Transfers _value number of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @dev Allows _spender to withdraw from the msg.sender's account up to the _value amount
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @dev Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

// File: contracts/FundsForwarder.sol


interface IGivethBridge {
    function donate(uint64 giverId, uint64 receiverId) external payable;
    function donate(uint64 giverId, uint64 receiverId, address token, uint _amount) external payable;
}

interface IFundsForwarderFactory {
    function bridge() external returns (address);
    function escapeHatchCaller() external returns (address);
    function escapeHatchDestination() external returns (address);
}

interface IMolochDao {
    function approvedToken() external returns (address);
    function members(address member) external returns (address, uint256, bool, uint256);
    function ragequit(uint sharesToBurn) external;
}

interface IWEth {
    function withdraw(uint wad) external;
    function balanceOf(address guy) external returns (uint);
}


contract FundsForwarder {
    uint64 public receiverId;
    uint64 public giverId;
    IFundsForwarderFactory public fundsForwarderFactory;

    string private constant ERROR_ERC20_APPROVE = "ERROR_ERC20_APPROVE";
    string private constant ERROR_BRIDGE_CALL = "ERROR_BRIDGE_CALL";
    string private constant ERROR_ZERO_BRIDGE = "ERROR_ZERO_BRIDGE";
    string private constant ERROR_DISALLOWED = "RECOVER_DISALLOWED";
    string private constant ERROR_TOKEN_TRANSFER = "RECOVER_TOKEN_TRANSFER";
    string private constant ERROR_ALREADY_INITIALIZED = "INIT_ALREADY_INITIALIZED";
    uint private constant MAX_UINT = uint(-1);

    event Forwarded(address to, address token, uint balance);
    event EscapeHatchCalled(address token, uint amount);

    constructor() public {
        /// @dev From AragonOS's Autopetrified contract
        // Immediately petrify base (non-proxy) instances of inherited contracts on deploy.
        // This renders them uninitializable (and unusable without a proxy).
        fundsForwarderFactory = IFundsForwarderFactory(address(-1));
    }

    /**
    * Fallback function to receive ETH donations
    */
    function() public payable {}

    /**
    * @dev Initialize can only be called once.
    * @notice msg.sender MUST be the _fundsForwarderFactory Contract
    *  Its address must be a contract with three public getters:
    *  - bridge(): Returns the bridge address
    *  - escapeHatchCaller(): Returns the escapeHatchCaller address
    *  - escapeHatchDestination(): Returns the escashouldpeHatchDestination address
    * @param _giverId The adminId of the liquidPledging pledge admin who is donating
    * @param _receiverId The adminId of the liquidPledging pledge admin receiving the donation
    */
    function initialize(uint64 _giverId, uint64 _receiverId) public {
        /// @dev onlyInit method from AragonOS's Initializable contract
        require(fundsForwarderFactory == address(0), ERROR_ALREADY_INITIALIZED);
        /// @dev Setting fundsForwarderFactory, serves as calling initialized()
        fundsForwarderFactory = IFundsForwarderFactory(msg.sender);
        /// @dev Make sure that the fundsForwarderFactory is a contract and has a bridge method
        require(fundsForwarderFactory.bridge() != address(0), ERROR_ZERO_BRIDGE);

        receiverId = _receiverId;
        giverId = _giverId;
    }

    /**
    * Transfer tokens/eth to the bridge. Transfer the entire balance of the contract
    * @param _token the token to transfer. 0x0 for ETH
    */
    function forward(address _token) public {
        IGivethBridge bridge = IGivethBridge(fundsForwarderFactory.bridge());
        require(bridge != address(0), ERROR_ZERO_BRIDGE);

        uint balance;
        bool result;
        /// @dev Logic for ether
        if (_token == address(0)) {
            balance = address(this).balance;
            /// @dev Call donate() with two arguments, for tokens
            /// Low level .call must be used due to function overloading
            /// keccak250("donate(uint64,uint64)") = bde60ac9
            /* solium-disable-next-line security/no-call-value */
            result = address(bridge).call.value(balance)(
                0xbde60ac9,
                giverId,
                receiverId
            );
        /// @dev Logic for tokens
        } else {
            ERC20 token = ERC20(_token);
            balance = token.balanceOf(this);
            /// @dev Since the bridge is a trusted contract, the max allowance
            ///  will be set on the first token transfer. Then it's skipped
            ///  Numbers for DAI        First tx | n+1 txs
            ///  approve(_, balance)      66356     51356
            ///  approve(_, MAX_UINT)     78596     39103
            ///                          +12240    -12253
            ///  Worth it if forward is called more than once for each token
            if (token.allowance(address(this), bridge) < balance) {
                require(token.approve(bridge, MAX_UINT), ERROR_ERC20_APPROVE);
            }

            /// @dev Call donate() with four arguments, for tokens
            /// Low level .call must be used due to function overloading
            /// keccak256("donate(uint64,uint64,address,uint256)") = 4c4316c7
            /* solium-disable-next-line security/no-low-level-calls */
            result = address(bridge).call(
                0x4c4316c7,
                giverId,
                receiverId,
                token,
                balance
            );
        }
        require(result, ERROR_BRIDGE_CALL);
        emit Forwarded(bridge, _token, balance);
    }

    /**
    * Transfer multiple tokens/eth to the bridge. Simplies UI interactions
    * @param _tokens the array of tokens to transfer. 0x0 for ETH
    */
    function forwardMultiple(address[] _tokens) public {
        uint tokensLength = _tokens.length;
        for (uint i = 0; i < tokensLength; i++) {
            forward(_tokens[i]);
        }
    }

    /**
    * Transfer tokens from a Moloch DAO by calling ragequit on all shares
    * @param _molochDao Address of a Moloch DAO
    * @param _convertWeth Flag to indicate that this DAO uses WETH
    */
    function forwardMoloch(address _molochDao, bool _convertWeth) public {
        IMolochDao molochDao = IMolochDao(_molochDao);
        (,uint shares,,) = molochDao.members(address(this));
        molochDao.ragequit(shares);
        address approvedToken = molochDao.approvedToken();
        if (_convertWeth) {
            IWEth weth = IWEth(approvedToken);
            weth.withdraw(weth.balanceOf(address(this)));
            forward(address(0));
        } else {
            forward(molochDao.approvedToken());
        }
    }

    /**
    * @notice Send funds to recovery address (escapeHatchDestination).
    * The `escapeHatch()` should only be called as a last resort if a
    * security issue is uncovered or something unexpected happened
    * @param _token Token balance to be sent to recovery vault.
    *
    * @dev Only the escapeHatchCaller can trigger this function
    * @dev The escapeHatchCaller address must not have control over escapeHatchDestination
    * @dev Function extracted from the Escapable contract (by Jordi Baylina and Adri¨¤ Massanet)
    * Instead of storing the caller, destination and owner addresses,
    * it fetches them from the parent contract.
    */
    function escapeHatch(address _token) public {
        /// @dev Serves as the original contract's onlyEscapeHatchCaller
        require(msg.sender == fundsForwarderFactory.escapeHatchCaller(), ERROR_DISALLOWED);

        address escapeHatchDestination = fundsForwarderFactory.escapeHatchDestination();

        uint256 balance;
        if (_token == 0x0) {
            balance = address(this).balance;
            escapeHatchDestination.transfer(balance);
        } else {
            ERC20 token = ERC20(_token);
            balance = token.balanceOf(this);
            require(token.transfer(escapeHatchDestination, balance), ERROR_TOKEN_TRANSFER);
        }

        emit EscapeHatchCalled(_token, balance);
    }
}

// File: contracts/lib/IsContract.sol

/*
 * SPDX-License-Identitifer:    MIT
 * Credit to @aragonOS
 */


contract IsContract {
    /*
    * NOTE: this should NEVER be used for authentication
    * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).
    *
    * This is only intended to be used as a sanity check that an address is actually a contract,
    * RATHER THAN an address not being a contract.
    */
    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) {
            return false;
        }

        uint256 size;
        assembly { size := extcodesize(_target) }
        return size > 0;
    }
}

// File: contracts/lib/Owned.sol


/// @title Owned
/// @author Adri¨¤ Massanet <adria@codecontext.io>
/// @notice The Owned contract has an owner address, and provides basic
///  authorization control functions, this simplifies & the implementation of
///  user permissions; this contract has three work flows for a change in
///  ownership, the first requires the new owner to validate that they have the
///  ability to accept ownership, the second allows the ownership to be
///  directly transfered without requiring acceptance, and the third allows for
///  the ownership to be removed to allow for decentralization
contract Owned {

    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event OwnershipRemoved();

    /// @dev The constructor sets the `msg.sender` as the`owner` of the contract
    constructor() public {
        owner = msg.sender;
    }

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require (msg.sender == owner,"err_ownedNotOwner");
        _;
    }

    /// @dev In this 1st option for ownership transfer `proposeOwnership()` must
    ///  be called first by the current `owner` then `acceptOwnership()` must be
    ///  called by the `newOwnerCandidate`
    /// @notice `onlyOwner` Proposes to transfer control of the contract to a
    ///  new owner
    /// @param _newOwnerCandidate The address being proposed as the new owner
    function proposeOwnership(address _newOwnerCandidate) public onlyOwner {
        newOwnerCandidate = _newOwnerCandidate;

        emit OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @notice Can only be called by the `newOwnerCandidate`, accepts the
    ///  transfer of ownership
    function acceptOwnership() public {
        require(msg.sender == newOwnerCandidate,"err_ownedNotCandidate");

        address oldOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = 0x0;

        emit OwnershipTransferred(oldOwner, owner);
    }

    /// @dev In this 2nd option for ownership transfer `changeOwnership()` can
    ///  be called and it will immediately assign ownership to the `newOwner`
    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    function changeOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != 0x0,"err_ownedInvalidAddress");

        address oldOwner = owner;
        owner = _newOwner;
        newOwnerCandidate = 0x0;

        emit OwnershipTransferred(oldOwner, owner);
    }

    /// @dev In this 3rd option for ownership transfer `removeOwnership()` can
    ///  be called and it will immediately assign ownership to the 0x0 address;
    ///  it requires a 0xdece be input as a parameter to prevent accidental use
    /// @notice Decentralizes the contract, this operation cannot be undone
    /// @param _dac `0xdac` has to be entered for this function to work
    function removeOwnership(address _dac) public onlyOwner {
        require(_dac == 0xdac,"err_ownedInvalidDac");

        owner = 0x0;
        newOwnerCandidate = 0x0;

        emit OwnershipRemoved();
    }
}

// File: contracts/lib/Escapable.sol


/*
    Copyright 2016, Jordi Baylina
    Contributor: Adri¨¤ Massanet <adria@codecontext.io>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/




/// @dev `Escapable` is a base level contract built off of the `Owned`
///  contract; it creates an escape hatch function that can be called in an
///  emergency that will allow designated addresses to send any ether or tokens
///  held in the contract to an `escapeHatchDestination` as long as they were
///  not blacklisted
contract Escapable is Owned {
    address public escapeHatchCaller;
    address public escapeHatchDestination;
    mapping (address=>bool) private escapeBlacklist; // Token contract addresses

    /// @notice The Constructor assigns the `escapeHatchDestination` and the
    ///  `escapeHatchCaller`
    /// @param _escapeHatchCaller The address of a trusted account or contract
    ///  to call `escapeHatch()` to send the ether in this contract to the
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller`
    ///  cannot move funds out of `escapeHatchDestination`
    /// @param _escapeHatchDestination The address of a safe location (usu a
    ///  Multisig) to send the ether held in this contract; if a neutral address
    ///  is required, the WHG Multisig is an option:
    ///  0x8Ff920020c8AD673661c8117f2855C384758C572
    constructor(address _escapeHatchCaller, address _escapeHatchDestination) public {
        escapeHatchCaller = _escapeHatchCaller;
        escapeHatchDestination = _escapeHatchDestination;
    }

    /// @dev The addresses preassigned as `escapeHatchCaller` or `owner`
    ///  are the only addresses that can call a function with this modifier
    modifier onlyEscapeHatchCallerOrOwner {
        require (
            (msg.sender == escapeHatchCaller)||(msg.sender == owner),
            "err_escapableInvalidCaller"
        );
        _;
    }

    /// @notice Creates the blacklist of tokens that are not able to be taken
    ///  out of the contract; can only be done at the deployment, and the logic
    ///  to add to the blacklist will be in the constructor of a child contract
    /// @param _token the token contract address that is to be blacklisted
    function blacklistEscapeToken(address _token) internal {
        escapeBlacklist[_token] = true;

        emit EscapeHatchBlackistedToken(_token);
    }

    /// @notice Checks to see if `_token` is in the blacklist of tokens
    /// @param _token the token address being queried
    /// @return False if `_token` is in the blacklist and can't be taken out of
    ///  the contract via the `escapeHatch()`
    function isTokenEscapable(address _token) public view returns (bool) {
        return !escapeBlacklist[_token];
    }

    /// @notice The `escapeHatch()` should only be called as a last resort if a
    /// security issue is uncovered or something unexpected happened
    /// @param _token to transfer, use 0x0 for ether
    function escapeHatch(address _token) public onlyEscapeHatchCallerOrOwner {
        require(escapeBlacklist[_token]==false,"err_escapableBlacklistedToken");

        uint256 balance;

        /// @dev Logic for ether
        if (_token == 0x0) {
            balance = address(this).balance;
            escapeHatchDestination.transfer(balance);
            emit EscapeHatchCalled(_token, balance);
            return;
        }
        /// @dev Logic for tokens
        ERC20 token = ERC20(_token);
        balance = token.balanceOf(this);
        require(token.transfer(escapeHatchDestination, balance),"err_escapableTransfer");
        emit EscapeHatchCalled(_token, balance);
    }

    /// @notice Changes the address assigned to call `escapeHatch()`
    /// @param _newEscapeHatchCaller The address of a trusted account or
    ///  contract to call `escapeHatch()` to send the value in this contract to
    ///  the `escapeHatchDestination`; it would be ideal that `escapeHatchCaller`
    ///  cannot move funds out of `escapeHatchDestination`
    function changeHatchEscapeCaller(address _newEscapeHatchCaller) public onlyEscapeHatchCallerOrOwner {
        escapeHatchCaller = _newEscapeHatchCaller;
    }

    event EscapeHatchBlackistedToken(address token);
    event EscapeHatchCalled(address token, uint amount);
}

// File: contracts/FundsForwarderFactory.sol




contract FundsForwarderFactory is Escapable, IsContract {
    address public bridge;
    address public childImplementation;

    string private constant ERROR_NOT_A_CONTRACT = "ERROR_NOT_A_CONTRACT";
    string private constant ERROR_HATCH_CALLER = "ERROR_HATCH_CALLER";
    string private constant ERROR_HATCH_DESTINATION = "ERROR_HATCH_DESTINATION";

    event NewFundForwarder(address indexed _giver, uint64 indexed _receiverId, address fundsForwarder);
    event BridgeChanged(address newBridge);
    event ChildImplementationChanged(address newChildImplementation);

    /**
    * @notice Create a new factory for deploying Giveth FundForwarders
    * @dev Requires a deployed bridge
    * @param _bridge Bridge address
    * @param _escapeHatchCaller The address of a trusted account or contract to
    *  call `escapeHatch()` to send the ether in this contract to the
    *  `escapeHatchDestination` it would be ideal if `escapeHatchCaller` cannot move
    *  funds out of `escapeHatchDestination`
    * @param _escapeHatchDestination The address of a safe location (usually a
    *  Multisig) to send the value held in this contract in an emergency
    */
    constructor(
        address _bridge,
        address _escapeHatchCaller,
        address _escapeHatchDestination,
        address _childImplementation
    ) Escapable(_escapeHatchCaller, _escapeHatchDestination) public {
        require(isContract(_bridge), ERROR_NOT_A_CONTRACT);
        bridge = _bridge;

        // Set the escapeHatch params to the same as in the bridge
        Escapable bridgeInstance = Escapable(_bridge);
        require(_escapeHatchCaller == bridgeInstance.escapeHatchCaller(), ERROR_HATCH_CALLER);
        require(_escapeHatchDestination == bridgeInstance.escapeHatchDestination(), ERROR_HATCH_DESTINATION);
        // Set the owner to the same as in the bridge
        changeOwnership(bridgeInstance.owner());

        // Deploy FundsForwarder
        if (_childImplementation == address(0)) {
            childImplementation = new FundsForwarder();
        } else {
            childImplementation = _childImplementation;
        }
    }

    /**
    * @notice Change the bridge address.
    * @param _bridge New bridge address
    */
    function changeBridge(address _bridge) external onlyEscapeHatchCallerOrOwner {
        bridge = _bridge;
        emit BridgeChanged(_bridge);
    }

    /**
    * @notice Change the childImplementation address.
    * @param _childImplementation New childImplementation address
    */
    function changeChildImplementation(address _childImplementation) external onlyEscapeHatchCallerOrOwner {
        childImplementation = _childImplementation;
        emit ChildImplementationChanged(_childImplementation);
    }

    /**
    * @param _giverId The adminId of the liquidPledging pledge admin who is donating
    * @param _receiverId The adminId of the liquidPledging pledge admin receiving the donation
    */
    function newFundsForwarder(uint64 _giverId, uint64 _receiverId) public {
        address fundsForwarder = _deployMinimal(childImplementation);
        FundsForwarder(fundsForwarder).initialize(_giverId, _receiverId);

        // Store a registry of fundForwarders as events
        emit NewFundForwarder(_giverId, _receiverId, fundsForwarder);
    }

    /**
     * @notice Deploys a minimal forwarding proxy that is not upgradable
     * From ZepelinOS https://github.com/zeppelinos/zos/blob/v2.4.0/packages/lib/contracts/upgradeability/ProxyFactory.sol
     */
    function _deployMinimal(address _logic) internal returns (address proxy) {
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(_logic);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
    }
}