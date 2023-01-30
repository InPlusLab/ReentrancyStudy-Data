/**
 *Submitted for verification at Etherscan.io on 2020-02-22
*/

pragma solidity ^0.5.16;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}

/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * @dev Supports unlimited numbers of roles and addresses.
 * @dev See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 *  for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 *  to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  /**
   * @dev reverts if addr does not have role
   * @param addr address
   * @param roleName the name of the role
   * // reverts
   */
  function checkRole(address addr, string memory roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  /**
   * @dev determine if addr has role
   * @param addr address
   * @param roleName the name of the role
   * @return bool
   */
  function hasRole(address addr, string memory roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function addRole(address addr, string memory roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function removeRole(address addr, string memory roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param roleName the name of the role
   * // reverts
   */
  modifier onlyRole(string memory roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

}

/**
 * @title RBACWithAdmin
 * @author Matt Condon (@Shrugs)
 * @dev It's recommended that you define constants in the contract,
 * @dev like ROLE_ADMIN below, to avoid typos.
 */
contract RBACWithAdmin is RBAC { // , DESTROYER {
  /**
   * A constant role name for indicating admins.
   */
  string public constant ROLE_ADMIN = "admin";
  string public constant ROLE_PAUSE_ADMIN = "pauseAdmin";

  /**
   * @dev modifier to scope access to admins
   * // reverts
   */
  modifier onlyAdmin()
  {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }
  modifier onlyPauseAdmin()
  {
    checkRole(msg.sender, ROLE_PAUSE_ADMIN);
    _;
  }
  /**
   * @dev constructor. Sets msg.sender as admin by default
   */
  constructor()
    public
  {
    addRole(msg.sender, ROLE_ADMIN);
    addRole(msg.sender, ROLE_PAUSE_ADMIN);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminAddRole(address addr, string memory roleName)
    onlyAdmin
    public
  {
    addRole(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminRemoveRole(address addr, string memory roleName)
    onlyAdmin
    public
  {
    removeRole(addr, roleName);
  }
}

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <remco@2¦Ð.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is RBACWithAdmin {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyPauseAdmin whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyPauseAdmin whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract DragonsETH {
    struct Dragon {
        uint256 gen1;
        uint8 stage; // 0 - Dead, 1 - Egg, 2 - Young Dragon 
        uint8 currentAction; // 0 - free, 1 - fight place, 0xFF - Necropolis,  2 - random fight,
                             // 3 - breed market, 4 - breed auction, 5 - random breed, 6 - market place ...
        uint240 gen2;
        uint256 nextBlock2Action;
    }

    Dragon[] public dragons;
    
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function setCurrentAction(uint256 _dragonID, uint8 _currentAction) external;
}

contract FixMarketPlace is Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    DragonsETH public mainContract;
    address payable wallet;
    uint256 public ownersPercent = 50; // eq 5%
    mapping(uint256 => address payable) public dragonsOwner;
    mapping(uint256 => uint256) public dragonPrices;
    mapping(uint256 => uint256) public dragonsListIndex;
    mapping(address => uint256) public ownerDragonsCount;
    mapping(uint256 => uint256) public dragonsLikes;
    uint256[] public dragonsList;
    
    event SoldOut(address indexed _from, address indexed _to, uint256 _tokenId, uint256 _price);
    event ForSale(address indexed _from, uint256 _tokenId, uint256 _price);
    event SaleCancel(address indexed _from, uint256 _tokenId, uint256 _price);
    
    constructor(address payable _wallet, address _mainContract) public {
        wallet = _wallet;
        mainContract = DragonsETH(_mainContract);
    }
    function add2MarketPlace(address payable _dragonOwner, uint256 _dragonID, uint256 _dragonPrice, uint256 /*_endBlockNumber*/) 
        external
        whenNotPaused
        returns (bool) 
    {
        require(msg.sender == address(mainContract), "Only the main contract can add dragons!");
        dragonsOwner[_dragonID] = _dragonOwner;
        ownerDragonsCount[_dragonOwner]++;
        dragonPrices[_dragonID] = _dragonPrice;
        dragonsListIndex[_dragonID] = dragonsList.length;
        dragonsList.push(_dragonID);
        mainContract.setCurrentAction(_dragonID, 6);
        emit ForSale(_dragonOwner, _dragonID, _dragonPrice);
        return true;
    }
    
    function delFromFixMarketPlace(uint256 _dragonID) external {
        require(msg.sender == dragonsOwner[_dragonID], "Only owners can do it!");
        mainContract.transferFrom(address(this), dragonsOwner[_dragonID], _dragonID);
        emit SaleCancel(dragonsOwner[_dragonID], _dragonID, dragonPrices[_dragonID]);
        _delItem(_dragonID);
    }
    function buyDragon(uint256 _dragonID) external payable nonReentrant whenNotPaused {
        uint256 _dragonCommisions = dragonPrices[_dragonID].mul(ownersPercent).div(1000);
        require(msg.value >= dragonPrices[_dragonID].add(_dragonCommisions), "Not enough Ether!");
        uint256 valueToReturn = msg.value.sub(dragonPrices[_dragonID]).sub(_dragonCommisions);
        if (valueToReturn != 0) {
            msg.sender.transfer(valueToReturn);
        }
    
        mainContract.safeTransferFrom(address(this), msg.sender, _dragonID);
        wallet.transfer(_dragonCommisions);
        dragonsOwner[_dragonID].transfer(msg.value - valueToReturn - _dragonCommisions);
        emit SoldOut(dragonsOwner[_dragonID], msg.sender, _dragonID, msg.value - valueToReturn - _dragonCommisions);
        _delItem(_dragonID);
    }
    function likeDragon(uint256 _dragonID) external whenNotPaused {
        dragonsLikes[_dragonID]++;
    }
    function totalDragonsToSale() external view returns(uint256) {
        return dragonsList.length;
    }
    function getAllDragonsSale() external view returns(uint256[] memory) {
        return dragonsList;
    }
    function getSlicedDragonsSale(uint256 _firstIndex, uint256 _aboveLastIndex) external view returns(uint256[] memory) {
        require(_firstIndex < dragonsList.length, "The first index greater than totalDragonsToSale!");
        uint256 lastIndex = _aboveLastIndex;
        if (_aboveLastIndex > dragonsList.length) lastIndex = dragonsList.length;
        require(_firstIndex <= lastIndex, "The first index greater than last!");
        uint256 resultCount = lastIndex - _firstIndex;
        if (resultCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](resultCount);
            uint256 _dragonIndex;
            uint256 _resultIndex = 0;

            for (_dragonIndex = _firstIndex; _dragonIndex < lastIndex; _dragonIndex++) {
                result[_resultIndex] = dragonsList[_dragonIndex];
                _resultIndex++;
            }

            return result;
        }
    }
    function getOwnedDragonToSale(address _owner) external view returns(uint256[] memory) {
        uint256 countResaultDragons = ownerDragonsCount[_owner];
        if (countResaultDragons == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](countResaultDragons);
            uint256 _dragonIndex;
            uint256 _resultIndex = 0;

            for (_dragonIndex = 0; _dragonIndex < dragonsList.length; _dragonIndex++) {
                uint256 _dragonID = dragonsList[_dragonIndex];
                if (dragonsOwner[_dragonID] == _owner) {
                    result[_resultIndex] = _dragonID;
                    _resultIndex++;
                    if (_resultIndex == countResaultDragons) break;
                }
            }

            return result;
        }
    }
    function getFewDragons(uint256[] calldata _dragonIDs) external view returns(uint256[] memory) {
        uint256 dragonCount = _dragonIDs.length;
        if (dragonCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](dragonCount * 4);
            uint256 resultIndex = 0;

            for (uint256 dragonIndex = 0; dragonIndex < dragonCount; dragonIndex++) {
                uint256 dragonID = _dragonIDs[dragonIndex];
                result[resultIndex++] = dragonID;
                uint8 tmp;
                (,tmp,,,) = mainContract.dragons(dragonID);
                result[resultIndex++] = uint256(tmp);
                result[resultIndex++] = uint256(dragonsOwner[dragonID]);
                result[resultIndex++] = dragonPrices[dragonID];
                
            }

            return result; 
        }
    }
     function _delItem(uint256 _dragonID) private {
        require(dragonsOwner[_dragonID] != address(0), "An attempt to remove an unregistered dragon!");
        mainContract.setCurrentAction(_dragonID, 0);
        ownerDragonsCount[dragonsOwner[_dragonID]]--;
        delete(dragonsOwner[_dragonID]);
        delete(dragonPrices[_dragonID]);
        delete(dragonsLikes[_dragonID]);
        if (dragonsList.length - 1 != dragonsListIndex[_dragonID]) {
            dragonsList[dragonsListIndex[_dragonID]] = dragonsList[dragonsList.length - 1];
            dragonsListIndex[dragonsList[dragonsList.length - 1]] = dragonsListIndex[_dragonID];
        }
        dragonsList.length--;
        delete(dragonsListIndex[_dragonID]);
    }
    function clearMarket(uint256[] calldata _dragonIDs) external onlyAdmin whenPaused {
        uint256 dragonCount = _dragonIDs.length;
        if (dragonCount > 0) {
            for (uint256 dragonIndex = 0; dragonIndex < dragonCount; dragonIndex++) {
                uint256 dragonID = _dragonIDs[dragonIndex];
                mainContract.transferFrom(address(this), dragonsOwner[dragonID], dragonID);
                _delItem(dragonID);
            }
        }
    }
    function changeWallet(address payable _wallet) external onlyAdmin {
        wallet = _wallet;
    }
    function changeOwnersPercent(uint256 _ownersPercent) external onlyAdmin {
        ownersPercent = _ownersPercent;
    }
    function withdrawAllEther() external onlyAdmin {
        require(wallet != address(0), "Withdraw address can't be zero!");
        wallet.transfer(address(this).balance);
    }
}