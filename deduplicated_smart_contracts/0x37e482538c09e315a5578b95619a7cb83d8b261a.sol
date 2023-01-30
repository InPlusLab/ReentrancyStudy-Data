/**
 *Submitted for verification at Etherscan.io on 2019-07-14
*/

pragma solidity ^0.5.8;

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
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2¦Ð.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor() public {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
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

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract WCKAds is ReentrancyGuard, Ownable, Pausable {

    // OpenZeppelin's SafeMath library is used for all arithmetic operations to avoid overflows/underflows.
    using SafeMath for uint256;

    /* ********** */
    /* DATA TYPES */
    /* ********** */

    struct AdvertisingSlot {
        uint256 kittyIdBeingAdvertised;
        uint256 blockThatPriceWillResetAt;
        uint256 valuationPrice;
        address slotOwner;
    }

    /* ****** */
    /* EVENTS */
    /* ****** */

    event AdvertisingSlotRented(
        uint256 slotId,
        uint256 kittyIdBeingAdvertised,
        uint256 blockThatPriceWillResetAt,
        uint256 valuationPrice,
        address slotOwner
    );

    event AdvertisingSlotContentsChanged(
        uint256 slotId,
        uint256 newKittyIdBeingAdvertised
    );

    /* ******* */
    /* STORAGE */
    /* ******* */

    mapping (uint256 => AdvertisingSlot) public advertisingSlots;
    
    /* ********* */
    /* CONSTANTS */
    /* ********* */

    address public kittyCoreContractAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    address public kittySalesContractAddress = 0xb1690C08E213a35Ed9bAb7B318DE14420FB57d8C;
    address public kittySiresContractAddress = 0xC7af99Fe5513eB6710e6D5f44F9989dA40F27F26;    
    address public wckContractAddress = 0x09fE5f0236F0Ea5D930197DCE254d77B04128075;
    uint256 public minimumPriceIncrementInBasisPoints = 500;
    uint256 public maxRentalPeriodInBlocks = 604800;
    uint256 public minimumRentalPrice = (10**18);

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    function getCurrentPriceToRentAdvertisingSlot(uint256 _slotId) external view returns (uint256) {
        AdvertisingSlot memory currentSlot = advertisingSlots[_slotId];
        if(block.number < currentSlot.blockThatPriceWillResetAt){
            return _computeNextPrice(currentSlot.valuationPrice);
        } else {
            return minimumRentalPrice;
        }
    }

    function ownsKitty(address _address, uint256 _kittyId) view public returns (bool) {
        if(KittyCore(kittyCoreContractAddress).ownerOf(_kittyId) == _address){
            return true;
        } else {
            address salesSeller;
            (salesSeller, , , , ) = KittyAuction(kittySalesContractAddress).getAuction(_kittyId);
            address siresSeller;
            (siresSeller, , , , ) = KittyAuction(kittySiresContractAddress).getAuction(_kittyId);
            if(salesSeller == _address || siresSeller == _address){
                return true;
            } else {
                return false;
            }
        }
    }

    function rentAdvertisingSlot(uint256 _slotId, uint256 _newKittyIdToAdvertise, uint256 _newValuationPrice) external nonReentrant whenNotPaused {
        require(ownsKitty(msg.sender, _newKittyIdToAdvertise), 'the CryptoKitties Nifty License requires you to own any kitties whose image you want to use');
        AdvertisingSlot memory currentSlot = advertisingSlots[_slotId];
        if(block.number < currentSlot.blockThatPriceWillResetAt){
            require(_newValuationPrice >= _computeNextPrice(currentSlot.valuationPrice), 'you must submit a higher valuation price if the rental term has not elapsed');
            ERC20(wckContractAddress).transferFrom(msg.sender, address(this), _newValuationPrice);
        } else {
            ERC20(wckContractAddress).transferFrom(msg.sender, address(this), minimumRentalPrice);
        }
        uint256 newBlockThatPriceWillResetAt = (block.number).add(maxRentalPeriodInBlocks);
        AdvertisingSlot memory newAdvertisingSlot = AdvertisingSlot({
            kittyIdBeingAdvertised: _newKittyIdToAdvertise,
            blockThatPriceWillResetAt: newBlockThatPriceWillResetAt,
            valuationPrice: _newValuationPrice,
            slotOwner: msg.sender
        });
        advertisingSlots[_slotId] = newAdvertisingSlot;
        emit AdvertisingSlotRented(
            _slotId,
            _newKittyIdToAdvertise,
            newBlockThatPriceWillResetAt,
            _newValuationPrice,
            msg.sender
        );
    }

    function changeKittyIdBeingAdvertised(uint256 _slotId, uint256 _kittyId) external nonReentrant whenNotPaused {
        require(ownsKitty(msg.sender, _kittyId), 'the CryptoKitties Nifty License requires you to own any kitties whose image you want to use');
        AdvertisingSlot storage currentSlot = advertisingSlots[_slotId];
        require(msg.sender == currentSlot.slotOwner, 'only the current owner of this slot can change the advertisements subject matter');
        currentSlot.kittyIdBeingAdvertised = _kittyId;
        emit AdvertisingSlotContentsChanged(
            _slotId,
            _kittyId
        );
    }

    function ownerUpdateMinimumRentalPrice(uint256 _newMinimumRentalPrice) external onlyOwner {
        minimumRentalPrice = _newMinimumRentalPrice;
    }

    function ownerUpdateMinimumPriceIncrement(uint256 _newMinimumPriceIncrementInBasisPoints) external onlyOwner {
        minimumPriceIncrementInBasisPoints = _newMinimumPriceIncrementInBasisPoints;
    }

    function ownerUpdateMaxRentalPeriod(uint256 _newMaxRentalPeriodInBlocks) external onlyOwner {
        maxRentalPeriodInBlocks = _newMaxRentalPeriodInBlocks;
    }

    function ownerWithdrawERC20(address _erc20Address, uint256 _value) external onlyOwner {
        ERC20(_erc20Address).transfer(msg.sender, _value);
    }

    function ownerWithdrawEther() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    constructor() public {}

    function() external payable {}

    function _computeNextPrice(uint256 _currentPrice) view internal returns (uint256) {
        return _currentPrice.add((_currentPrice.mul(minimumPriceIncrementInBasisPoints)).div(uint256(10000)));
    }
}

/// @title Interface for interacting with the previous version of the WCK contract
contract ERC20 {
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

contract KittyCore {
    function ownerOf(uint256 _tokenId) external view returns (address owner);
}

contract KittyAuction {
    function getAuction(uint256 _tokenId) external view returns (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    );
}