/**
 *Submitted for verification at Etherscan.io on 2020-12-15
*/

pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC1820Registry {
    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;
    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address);
    function setManager(address _addr, address _newManager) external;
    function getManager(address _addr) public view returns (address);
}


/// Base client to interact with the registry.
contract ERC1820Client {
    ERC1820Registry constant ERC1820REGISTRY = ERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    function setInterfaceImplementation(string memory _interfaceLabel, address _implementation) internal {
        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        ERC1820REGISTRY.setInterfaceImplementer(address(this), interfaceHash, _implementation);
    }

    function interfaceAddr(address addr, string memory _interfaceLabel) internal view returns(address) {
        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        return ERC1820REGISTRY.getInterfaceImplementer(addr, interfaceHash);
    }

    function delegateManagement(address _newManager) internal {
        ERC1820REGISTRY.setManager(address(this), _newManager);
    }
}

/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */



contract ERC1820Implementer {
  bytes32 constant ERC1820_ACCEPT_MAGIC = keccak256(abi.encodePacked("ERC1820_ACCEPT_MAGIC"));

  mapping(bytes32 => bool) internal _interfaceHashes;

  function canImplementInterfaceForAddress(bytes32 interfaceHash, address /*addr*/) // Comments to avoid compilation warnings for unused variables.
    external
    view
    returns(bytes32)
  {
    if(_interfaceHashes[interfaceHash]) {
      return ERC1820_ACCEPT_MAGIC;
    } else {
      return "";
    }
  }

  function _setInterface(string memory interfaceLabel) internal {
    _interfaceHashes[keccak256(abi.encodePacked(interfaceLabel))] = true;
  }

}

/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */


/**
 * @title IERC1400 security token standard
 * @dev See https://github.com/SecurityTokenStandard/EIP-Spec/blob/master/eip/eip-1400.md
 */
interface IERC1400 /*is IERC20*/ { // Interfaces can currently not inherit interfaces, but IERC1400 shall include IERC20

  // ****************** Document Management *******************
  function getDocument(bytes32 name) external view returns (string memory, bytes32);
  function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external;

  // ******************* Token Information ********************
  function balanceOfByPartition(bytes32 partition, address tokenHolder) external view returns (uint256);
  function partitionsOf(address tokenHolder) external view returns (bytes32[] memory);

  // *********************** Transfers ************************
  function transferWithData(address to, uint256 value, bytes calldata data) external;
  function transferFromWithData(address from, address to, uint256 value, bytes calldata data) external;

  // *************** Partition Token Transfers ****************
  function transferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data) external returns (bytes32);
  function operatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData) external returns (bytes32);

  // ****************** Controller Operation ******************
  function isControllable() external view returns (bool);
  // function controllerTransfer(address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData) external; // removed because same action can be achieved with "operatorTransferByPartition"
  // function controllerRedeem(address tokenHolder, uint256 value, bytes calldata data, bytes calldata operatorData) external; // removed because same action can be achieved with "operatorRedeemByPartition"

  // ****************** Operator Management *******************
  function authorizeOperator(address operator) external;
  function revokeOperator(address operator) external;
  function authorizeOperatorByPartition(bytes32 partition, address operator) external;
  function revokeOperatorByPartition(bytes32 partition, address operator) external;

  // ****************** Operator Information ******************
  function isOperator(address operator, address tokenHolder) external view returns (bool);
  function isOperatorForPartition(bytes32 partition, address operator, address tokenHolder) external view returns (bool);

  // ********************* Token Issuance *********************
  function isIssuable() external view returns (bool);
  function issue(address tokenHolder, uint256 value, bytes calldata data) external;
  function issueByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data) external;

  // ******************** Token Redemption ********************
  function redeem(uint256 value, bytes calldata data) external;
  function redeemFrom(address tokenHolder, uint256 value, bytes calldata data) external;
  function redeemByPartition(bytes32 partition, uint256 value, bytes calldata data) external;
  function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata operatorData) external;

  // ******************* Transfer Validity ********************
  // We use different transfer validity functions because those described in the interface don't allow to verify the certificate's validity.
  // Indeed, verifying the ecrtificate's validity requires to keeps the function's arguments in the exact same order as the transfer function.
  //
  // function canTransfer(address to, uint256 value, bytes calldata data) external view returns (byte, bytes32);
  // function canTransferFrom(address from, address to, uint256 value, bytes calldata data) external view returns (byte, bytes32);
  // function canTransferByPartition(address from, address to, bytes32 partition, uint256 value, bytes calldata data) external view returns (byte, bytes32, bytes32);    

  // ******************* Controller Events ********************
  // We don't use this event as we don't use "controllerTransfer"
  //   event ControllerTransfer(
  //       address controller,
  //       address indexed from,
  //       address indexed to,
  //       uint256 value,
  //       bytes data,
  //       bytes operatorData
  //   );
  //
  // We don't use this event as we don't use "controllerRedeem"
  //   event ControllerRedemption(
  //       address controller,
  //       address indexed tokenHolder,
  //       uint256 value,
  //       bytes data,
  //       bytes operatorData
  //   );

  // ******************** Document Events *********************
  event Document(bytes32 indexed name, string uri, bytes32 documentHash);

  // ******************** Transfer Events *********************
  event TransferByPartition(
      bytes32 indexed fromPartition,
      address operator,
      address indexed from,
      address indexed to,
      uint256 value,
      bytes data,
      bytes operatorData
  );

  event ChangedPartition(
      bytes32 indexed fromPartition,
      bytes32 indexed toPartition,
      uint256 value
  );

  // ******************** Operator Events *********************
  event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
  event RevokedOperator(address indexed operator, address indexed tokenHolder);
  event AuthorizedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);
  event RevokedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);

  // ************** Issuance / Redemption Events **************
  event Issued(address indexed operator, address indexed to, uint256 value, bytes data);
  event Redeemed(address indexed operator, address indexed from, uint256 value, bytes data);
  event IssuedByPartition(bytes32 indexed partition, address indexed operator, address indexed to, uint256 value, bytes data, bytes operatorData);
  event RedeemedByPartition(bytes32 indexed partition, address indexed operator, address indexed from, uint256 value, bytes operatorData);

}

/**
 * Reason codes - ERC-1066
 *
 * To improve the token holder experience, canTransfer MUST return a reason byte code
 * on success or failure based on the ERC-1066 application-specific status codes specified below.
 * An implementation can also return arbitrary data as a bytes32 to provide additional
 * information not captured by the reason code.
 * 
 * Code	Reason
 * 0x50	transfer failure
 * 0x51	transfer success
 * 0x52	insufficient balance
 * 0x53	insufficient allowance
 * 0x54	transfers halted (contract paused)
 * 0x55	funds locked (lockup period)
 * 0x56	invalid sender
 * 0x57	invalid receiver
 * 0x58	invalid operator (transfer agent)
 * 0x59	
 * 0x5a	
 * 0x5b	
 * 0x5a	
 * 0x5b	
 * 0x5c	
 * 0x5d	
 * 0x5e	
 * 0x5f	token meta or info
 *
 * These codes are being discussed at: https://ethereum-magicians.org/t/erc-1066-ethereum-status-codes-esc/283/24
 */

/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */












/**
 * @notice Interface to the extension types
 */
interface IExtensionTypes {
  enum CertificateValidation {
    None,
    NonceBased,
    SaltBased
  }
}

interface IERC1400Extended {
    // Not a real interface but added here for functions which don't belong to IERC1400

    function owner() external view returns (address);

    function controllers() external view returns (address[] memory);

    function totalPartitions() external view returns (bytes32[] memory);

    function getDefaultPartitions() external view returns (bytes32[] memory);

    function totalSupplyByPartition(bytes32 partition) external view returns (uint256);
}

contract IERC1400TokensValidatorExtended is IExtensionTypes {
    // Not a real interface but added here for functions which don't belong to IERC1400TokensValidator

    function retrieveTokenSetup(address token) external view returns (CertificateValidation, bool, bool, bool, bool, address[] memory);

    function spendableBalanceOfByPartition(address token, bytes32 partition, address account) external view returns (uint256);

    function isAllowlisted(address token, address account) public view returns (bool);

    function isBlocklisted(address token, address account) public view returns (bool);
}

/**
 * @title BatchReader
 * @dev Proxy contract to read multiple information from the smart contract in a single contract call.
 */
contract BatchReader is IExtensionTypes, ERC1820Client, ERC1820Implementer {
    using SafeMath for uint256;

    string internal constant BALANCE_READER = "BatchReader";

    string constant internal ERC1400_TOKENS_VALIDATOR = "ERC1400TokensValidator";

    // Mapping from token to token extension address
    mapping(address => address) internal _extension;

    constructor() public {
        ERC1820Implementer._setInterface(BALANCE_READER);
    }

    /**
     * @dev Get batch of token supplies.
     * @return Batch of token supplies.
     */
    function batchTokenSuppliesInfos(address[] calldata tokens) external view returns (uint256[] memory, uint256[] memory, bytes32[] memory, uint256[] memory, uint256[] memory, bytes32[] memory) {
        uint256[] memory batchTotalSupplies = new uint256[](tokens.length);
        for (uint256 j = 0; j < tokens.length; j++) {
            batchTotalSupplies[j] = IERC20(tokens[j]).totalSupply();
        }

        (uint256[] memory totalPartitionsLengths, bytes32[] memory batchTotalPartitions, uint256[] memory batchPartitionSupplies) = batchTotalPartitions(tokens);

        (uint256[] memory defaultPartitionsLengths, bytes32[] memory batchDefaultPartitions) = batchDefaultPartitions(tokens);

        return (batchTotalSupplies, totalPartitionsLengths, batchTotalPartitions, batchPartitionSupplies, defaultPartitionsLengths, batchDefaultPartitions);
    }

    /**
     * @dev Get batch of token roles.
     * @return Batch of token roles.
     */
    function batchTokenRolesInfos(address[] calldata tokens) external view returns (address[] memory, uint256[] memory, address[] memory, uint256[] memory, address[] memory) {
        (uint256[] memory batchExtensionControllersLength, address[] memory batchExtensionControllers) = batchExtensionControllers(tokens);

        (uint256[] memory batchControllersLength, address[] memory batchControllers) = batchControllers(tokens);

        address[] memory batchOwners = new address[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            batchOwners[i] = IERC1400Extended(tokens[i]).owner();
        }
        return (batchOwners, batchControllersLength, batchControllers, batchExtensionControllersLength, batchExtensionControllers);
    }

    /**
     * @dev Get batch of token controllers.
     * @return Batch of token controllers.
     */
    function batchControllers(address[] memory tokens) public view returns (uint256[] memory, address[] memory) {
        uint256[] memory batchControllersLength = new uint256[](tokens.length);
        uint256 controllersLength=0;

        for (uint256 i = 0; i < tokens.length; i++) {
            address[] memory controllers = IERC1400Extended(tokens[i]).controllers();
            batchControllersLength[i] = controllers.length;
            controllersLength = controllersLength.add(controllers.length);
        }

        address[] memory batchControllersResponse = new address[](controllersLength);

        uint256 counter = 0;
        for (uint256 j = 0; j < tokens.length; j++) {
            address[] memory controllers = IERC1400Extended(tokens[j]).controllers();

            for (uint256 k = 0; k < controllers.length; k++) {
                batchControllersResponse[counter] = controllers[k];
                counter++;
            }
        }

        return (batchControllersLength, batchControllersResponse);
    }

    /**
     * @dev Get batch of token extension controllers.
     * @return Batch of token extension controllers.
     */
    function batchExtensionControllers(address[] memory tokens) public view returns (uint256[] memory, address[] memory) {
        address[] memory batchTokenExtension = new address[](tokens.length);

        uint256[] memory batchExtensionControllersLength = new uint256[](tokens.length);
        uint256 extensionControllersLength=0;

        for (uint256 i = 0; i < tokens.length; i++) {
            batchTokenExtension[i] = interfaceAddr(tokens[i], ERC1400_TOKENS_VALIDATOR);

            if (batchTokenExtension[i] != address(0)) {
                (,,,,,address[] memory extensionControllers) = IERC1400TokensValidatorExtended(batchTokenExtension[i]).retrieveTokenSetup(tokens[i]);
                batchExtensionControllersLength[i] = extensionControllers.length;
                extensionControllersLength = extensionControllersLength.add(extensionControllers.length);
            } else {
                batchExtensionControllersLength[i] = 0;
            }
        }

        address[] memory batchExtensionControllersResponse = new address[](extensionControllersLength);

        uint256 counter = 0;
        for (uint256 j = 0; j < tokens.length; j++) {
            if (batchTokenExtension[j] != address(0)) {
                (,,,,,address[] memory extensionControllers) = IERC1400TokensValidatorExtended(batchTokenExtension[j]).retrieveTokenSetup(tokens[j]);

                for (uint256 k = 0; k < extensionControllers.length; k++) {
                    batchExtensionControllersResponse[counter] = extensionControllers[k];
                    counter++;
                }
            }
        }

        return (batchExtensionControllersLength, batchExtensionControllersResponse);
    }

    /**
     * @dev Get batch of token extension setup.
     * @return Batch of token extension setup.
     */
    function batchTokenExtensionSetup(address[] calldata tokens) external view returns (address[] memory, CertificateValidation[] memory, bool[] memory, bool[] memory, bool[] memory, bool[] memory) {
        (address[] memory batchTokenExtension, CertificateValidation[] memory batchCertificateActivated, bool[] memory batchAllowlistActivated, bool[] memory batchBlocklistActivated) = batchTokenExtensionSetup1(tokens);

        (bool[] memory batchGranularityByPartitionActivated, bool[] memory batchHoldsActivated) = batchTokenExtensionSetup2(tokens);
        return (batchTokenExtension, batchCertificateActivated, batchAllowlistActivated, batchBlocklistActivated, batchGranularityByPartitionActivated, batchHoldsActivated);
    }

    /**
     * @dev Get batch of token extension setup (part 1).
     * @return Batch of token extension setup (part 1).
     */
    function batchTokenExtensionSetup1(address[] memory tokens) public view returns (address[] memory, CertificateValidation[] memory, bool[] memory, bool[] memory) {
        address[] memory batchTokenExtension = new address[](tokens.length);
        CertificateValidation[] memory batchCertificateActivated = new CertificateValidation[](tokens.length);
        bool[] memory batchAllowlistActivated = new bool[](tokens.length);
        bool[] memory batchBlocklistActivated = new bool[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            batchTokenExtension[i] = interfaceAddr(tokens[i], ERC1400_TOKENS_VALIDATOR);

            if (batchTokenExtension[i] != address(0)) {
                (CertificateValidation certificateActivated, bool allowlistActivated, bool blocklistActivated,,,) = IERC1400TokensValidatorExtended(batchTokenExtension[i]).retrieveTokenSetup(tokens[i]);
                batchCertificateActivated[i] = certificateActivated;
                batchAllowlistActivated[i] = allowlistActivated;
                batchBlocklistActivated[i] = blocklistActivated;
            } else {
                batchCertificateActivated[i] = CertificateValidation.None;
                batchAllowlistActivated[i] = false;
                batchBlocklistActivated[i] = false;
            }
        }

        return (batchTokenExtension, batchCertificateActivated, batchAllowlistActivated, batchBlocklistActivated);
    }

    /**
     * @dev Get batch of token extension setup (part 2).
     * @return Batch of token extension setup (part 2).
     */
    function batchTokenExtensionSetup2(address[] memory tokens) public view returns (bool[] memory, bool[] memory) {
        address[] memory batchTokenExtension = new address[](tokens.length);
        bool[] memory batchGranularityByPartitionActivated = new bool[](tokens.length);
        bool[] memory batchHoldsActivated = new bool[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            batchTokenExtension[i] = interfaceAddr(tokens[i], ERC1400_TOKENS_VALIDATOR);

            if (batchTokenExtension[i] != address(0)) {
                (,,, bool granularityByPartitionActivated, bool holdsActivated,) = IERC1400TokensValidatorExtended(batchTokenExtension[i]).retrieveTokenSetup(tokens[i]);
                batchGranularityByPartitionActivated[i] = granularityByPartitionActivated;
                batchHoldsActivated[i] = holdsActivated;
            } else {
                batchGranularityByPartitionActivated[i] = false;
                batchHoldsActivated[i] = false;
            }
        }

        return (batchGranularityByPartitionActivated, batchHoldsActivated);
    }

    /**
     * @dev Get batch of ERC1400 balances.
     * @return Batch of ERC1400 balances.
     */
    function batchERC1400Balances(address[] calldata tokens, address[] calldata tokenHolders) external view returns (uint256[] memory, uint256[] memory, uint256[] memory, bytes32[] memory, uint256[] memory, uint256[] memory) {
        (,, uint256[] memory batchSpendableBalancesOfByPartition) = batchSpendableBalanceOfByPartition(tokens, tokenHolders);

        (uint256[] memory totalPartitionsLengths, bytes32[] memory batchTotalPartitions, uint256[] memory batchBalancesOfByPartition) = batchBalanceOfByPartition(tokens, tokenHolders);

        uint256[] memory batchBalancesOf = batchBalanceOf(tokens, tokenHolders);

        uint256[] memory batchEthBalances = batchEthBalance(tokenHolders);

        return (batchEthBalances, batchBalancesOf, totalPartitionsLengths, batchTotalPartitions, batchBalancesOfByPartition, batchSpendableBalancesOfByPartition);
    }

    /**
     * @dev Get batch of ERC20 balances.
     * @return Batch of ERC20 balances.
     */
    function batchERC20Balances(address[] calldata tokens, address[] calldata tokenHolders) external view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory batchBalancesOf = batchBalanceOf(tokens, tokenHolders);

        uint256[] memory batchEthBalances = batchEthBalance(tokenHolders);

        return (batchEthBalances, batchBalancesOf);
    }

    /**
     * @dev Get batch of ETH balances.
     * @return Batch of token ETH balances.
     */
    function batchEthBalance(address[] memory tokenHolders) public view returns (uint256[] memory) {
        uint256[] memory batchEthBalanceResponse = new uint256[](tokenHolders.length);

        for (uint256 i = 0; i < tokenHolders.length; i++) {
            batchEthBalanceResponse[i] = tokenHolders[i].balance;
        }

        return batchEthBalanceResponse;
    }

    /**
     * @dev Get batch of token balances.
     * @return Batch of token balances.
     */
    function batchBalanceOf(address[] memory tokens, address[] memory tokenHolders) public view returns (uint256[] memory) {
        uint256[] memory batchBalanceOfResponse = new uint256[](tokenHolders.length * tokens.length);

        for (uint256 i = 0; i < tokenHolders.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                batchBalanceOfResponse[i*tokens.length + j] = IERC20(tokens[j]).balanceOf(tokenHolders[i]);
            }
        }

        return batchBalanceOfResponse;
    }

    /**
     * @dev Get batch of partition balances.
     * @return Batch of token partition balances.
     */
    function batchBalanceOfByPartition(address[] memory tokens, address[] memory tokenHolders) public view returns (uint256[] memory, bytes32[] memory, uint256[] memory) {
        (uint256[] memory totalPartitionsLengths, bytes32[] memory batchTotalPartitions,) = batchTotalPartitions(tokens);
        
        uint256[] memory batchBalanceOfByPartitionResponse = new uint256[](tokenHolders.length * batchTotalPartitions.length);

        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint256 counter = 0;
            for (uint256 j = 0; j < tokens.length; j++) {
                for (uint256 k = 0; k < totalPartitionsLengths[j]; k++) {
                    batchBalanceOfByPartitionResponse[i*batchTotalPartitions.length + counter] = IERC1400(tokens[j]).balanceOfByPartition(batchTotalPartitions[counter], tokenHolders[i]);
                    counter++;
                }
            }
        }

        return (totalPartitionsLengths, batchTotalPartitions, batchBalanceOfByPartitionResponse);
    }

    /**
     * @dev Get batch of spendable partition balances.
     * @return Batch of token spendable partition balances.
     */
    function batchSpendableBalanceOfByPartition(address[] memory tokens, address[] memory tokenHolders) public view returns (uint256[] memory, bytes32[] memory, uint256[] memory) {
        (uint256[] memory totalPartitionsLengths, bytes32[] memory batchTotalPartitions,) = batchTotalPartitions(tokens);
        
        uint256[] memory batchSpendableBalanceOfByPartitionResponse = new uint256[](tokenHolders.length * batchTotalPartitions.length);

        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint256 counter = 0;
            for (uint256 j = 0; j < tokens.length; j++) {
                address tokenExtension = interfaceAddr(tokens[j], ERC1400_TOKENS_VALIDATOR);

                for (uint256 k = 0; k < totalPartitionsLengths[j]; k++) {
                    if (tokenExtension != address(0)) {
                        batchSpendableBalanceOfByPartitionResponse[i*batchTotalPartitions.length + counter] = IERC1400TokensValidatorExtended(tokenExtension).spendableBalanceOfByPartition(tokens[j], batchTotalPartitions[counter], tokenHolders[i]);
                    } else {
                        batchSpendableBalanceOfByPartitionResponse[i*batchTotalPartitions.length + counter] = IERC1400(tokens[j]).balanceOfByPartition(batchTotalPartitions[counter], tokenHolders[i]);
                    }
                    counter++;
                }
            }
        }

        return (totalPartitionsLengths, batchTotalPartitions, batchSpendableBalanceOfByPartitionResponse);
    }

    /**
     * @dev Get batch of token partitions.
     * @return Batch of token partitions.
     */
    function batchTotalPartitions(address[] memory tokens) public view returns (uint256[] memory, bytes32[] memory, uint256[] memory) {
        uint256[] memory batchTotalPartitionsLength = new uint256[](tokens.length);
        uint256 totalPartitionsLength=0;

        for (uint256 i = 0; i < tokens.length; i++) {
            bytes32[] memory totalPartitions = IERC1400Extended(tokens[i]).totalPartitions();
            batchTotalPartitionsLength[i] = totalPartitions.length;
            totalPartitionsLength = totalPartitionsLength.add(totalPartitions.length);
        }

        bytes32[] memory batchTotalPartitionsResponse = new bytes32[](totalPartitionsLength);
        uint256[] memory batchPartitionSupplies = new uint256[](totalPartitionsLength);

        uint256 counter = 0;
        for (uint256 j = 0; j < tokens.length; j++) {
            bytes32[] memory totalPartitions = IERC1400Extended(tokens[j]).totalPartitions();

            for (uint256 k = 0; k < totalPartitions.length; k++) {
                batchTotalPartitionsResponse[counter] = totalPartitions[k];
                batchPartitionSupplies[counter] = IERC1400Extended(tokens[j]).totalSupplyByPartition(totalPartitions[k]);
                counter++;
            }
        }

        return (batchTotalPartitionsLength, batchTotalPartitionsResponse, batchPartitionSupplies);
    }

    /**
     * @dev Get batch of token default partitions.
     * @return Batch of token default partitions.
     */
    function batchDefaultPartitions(address[] memory tokens) public view returns (uint256[] memory, bytes32[] memory) {
        uint256[] memory batchDefaultPartitionsLength = new uint256[](tokens.length);
        uint256 defaultPartitionsLength=0;

        for (uint256 i = 0; i < tokens.length; i++) {
            bytes32[] memory defaultPartitions = IERC1400Extended(tokens[i]).getDefaultPartitions();
            batchDefaultPartitionsLength[i] = defaultPartitions.length;
            defaultPartitionsLength = defaultPartitionsLength.add(defaultPartitions.length);
        }

        bytes32[] memory batchDefaultPartitionsResponse = new bytes32[](defaultPartitionsLength);

        uint256 counter = 0;
        for (uint256 j = 0; j < tokens.length; j++) {
            bytes32[] memory defaultPartitions = IERC1400Extended(tokens[j]).getDefaultPartitions();

            for (uint256 k = 0; k < defaultPartitions.length; k++) {
                batchDefaultPartitionsResponse[counter] = defaultPartitions[k];
                counter++;
            }
        }

        return (batchDefaultPartitionsLength, batchDefaultPartitionsResponse);
    }

    /**
     * @dev Get batch of validation status.
     * @return Batch of validation status.
     */
    function batchValidations(address[] memory tokens, address[] memory tokenHolders) public view returns (bool[] memory, bool[] memory) {
        bool[] memory batchAllowlisted = batchAllowlisted(tokens, tokenHolders);
        bool[] memory batchBlocklisted = batchBlocklisted(tokens, tokenHolders);

        return (batchAllowlisted, batchBlocklisted);
    }

    /**
     * @dev Get batch of allowlisted status.
     * @return Batch of allowlisted status.
     */
    function batchAllowlisted(address[] memory tokens, address[] memory tokenHolders) public view returns (bool[] memory) {
        bool[] memory batchAllowlistedResponse = new bool[](tokenHolders.length * tokens.length);

        for (uint256 i = 0; i < tokenHolders.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                address tokenExtension = interfaceAddr(tokens[j], ERC1400_TOKENS_VALIDATOR);
                if (tokenExtension != address(0)) {
                    batchAllowlistedResponse[i*tokens.length + j] = IERC1400TokensValidatorExtended(tokenExtension).isAllowlisted(tokens[j], tokenHolders[i]);
                } else {
                    batchAllowlistedResponse[i*tokens.length + j] = false;
                }
            }
        }
        return batchAllowlistedResponse;
    }

    /**
     * @dev Get batch of blocklisted status.
     * @return Batch of blocklisted status.
     */
    function batchBlocklisted(address[] memory tokens, address[] memory tokenHolders) public view returns (bool[] memory) {
        bool[] memory batchBlocklistedResponse = new bool[](tokenHolders.length * tokens.length);

        for (uint256 i = 0; i < tokenHolders.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                address tokenExtension = interfaceAddr(tokens[j], ERC1400_TOKENS_VALIDATOR);
                if (tokenExtension != address(0)) {
                    batchBlocklistedResponse[i*tokens.length + j] = IERC1400TokensValidatorExtended(tokenExtension).isBlocklisted(tokens[j], tokenHolders[i]);
                } else {
                    batchBlocklistedResponse[i*tokens.length + j] = false;
                }
            }
        }
        return batchBlocklistedResponse;
    }

}