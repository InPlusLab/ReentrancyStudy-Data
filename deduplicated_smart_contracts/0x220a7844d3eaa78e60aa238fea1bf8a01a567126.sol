/**
 *Submitted for verification at Etherscan.io on 2019-10-25
*/

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.2;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/SignerRole.sol

pragma solidity ^0.5.2;


contract SignerRole {
    using Roles for Roles.Role;

    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);

    Roles.Role private _signers;

    constructor () internal {
        _addSigner(msg.sender);
    }

    modifier onlySigner() {
        require(isSigner(msg.sender));
        _;
    }

    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }

    function addSigner(address account) public onlySigner {
        _addSigner(account);
    }

    function renounceSigner() public {
        _removeSigner(msg.sender);
    }

    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }

    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}

// File: contracts/RegistryInterface.sol

pragma solidity ^0.5.2;

interface RegistryInterface {

    function getCurrencyConverter() external view returns (address);

}

// File: contracts/EthKidsRegistry.sol

pragma solidity ^0.5.2;



/**
 * @title EthKidsRegistry
 * @dev Holds the list of the communities' addresses
 */
contract EthKidsRegistry is RegistryInterface, SignerRole {

    uint256 public communityIndex = 0;
    mapping(uint256 => address) public communities;
    address public currencyConverter;

    event CommunityRegistered(address communityAddress, uint256 index);

    function registerCommunity(address _communityAddress) onlySigner public {
        registerCommunityAt(_communityAddress, communityIndex);
        communityIndex++;
    }

    /**
    * @dev Make sure the community has address(this) as one of _signers in order to set registry instance
    **/
    function registerCommunityAt(address _communityAddress, uint256 index) onlySigner public {
        communities[index] = _communityAddress;
        ((RegistryAware)(_communityAddress)).setRegistry(address(this));
        emit CommunityRegistered(_communityAddress, index);
    }

    function registerCurrencyConverter(address _currencyConverter) onlySigner public {
        currencyConverter = _currencyConverter;
    }

    function removeCommunity(uint256 _index) onlySigner public {
        communities[_index] = address(0);
    }

    function getCommunityAt(uint256 _index) public view returns (address community) {
        require(communities[_index] != address(0), "No such community exists");
        return communities[_index];
    }

    function getCurrencyConverter() public view returns (address) {
        return currencyConverter;
    }

}

interface RegistryAware {

    function setRegistry(address _registry) external;

}