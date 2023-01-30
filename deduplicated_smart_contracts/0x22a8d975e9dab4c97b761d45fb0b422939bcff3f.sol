/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-20
*/

pragma solidity ^0.5.7;

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// File: node_modules/openzeppelin-solidity/contracts/access/Roles.sol

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

// File: node_modules/openzeppelin-solidity/contracts/access/roles/PauserRole.sol

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

// File: contracts/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {

    uint256 public selfDestructAt;
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
    function pause(uint256 selfDestructPeriod) public onlyPauser whenNotPaused {
        _paused = true;
        selfDestructAt = now + selfDestructPeriod;
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

// File: contracts/PausableDestroyable.sol

contract PausableDestroyable is Pausable {

    function destroy() public whenPaused {
        require(selfDestructAt <= now);
        // send remaining funds to address 0, to prevent the owner from taking the funds himself (and steal the funds from the vault)
        selfdestruct(address(0));
    }
}

// File: contracts/ubivault.sol

///@title UBIVault, version 0.2
///@author AXVECO B.V., commisioned by THINSIA
/**
 * The UBIVault smart contract allows parties to fund the fault with money (Ether) and citizens to register and claim an UBI.
 * The vault makes a payout maximally once per weeks when AE/AC >= AB, where
 *  AE is 95% of the total deposited money (5% is for the maintenancePool)
 *  AC is the amountOfCitizens
 *  AB is Amount of AmountOfBasicIncome
*/
contract UBIVault is Ownable, PausableDestroyable {

    using SafeMath for uint256;

    mapping(address => uint256) public rightFromPaymentCycle;
    mapping(bytes32 => bool) public useablePasswordHashes;
    mapping(bytes32 => bool) public usedPasswordHashes;
    uint8 public amountOfBasicIncomeCanBeIncreased;
    uint256 public amountOfBasicIncome;
    uint256 public amountOfCitizens;
    uint256 public euroCentInWei;
    uint256 public availableEther;
    address payable public maintenancePool;
    uint256 public minimumPeriod;
    uint256 public promisedEther;
    uint256 lastPayout;
    uint256[] public paymentsCycle;

    event LogUseablePasswordCreated(bytes32 passwordHash);
    event LogUBICreated(uint256 adjustedEuroCentInWei, uint256 totalamountOfBasicIncomeInWei, uint256 amountOfCitizens, uint8 amountOfBasicIncomeCanBeIncreased, uint256 paymentsCycle);
    event LogCitizenRegistered(address newCitizen);
    event LogPasswordUsed(bytes32 password, bytes32 passwordHash);
    event LogVaultSponsored(address payee, bytes32 message, uint256 amount);
    event LogUBIClaimed(address indexed caller, uint256 income, address indexed citizen);

    ///@dev we set the first value in the paymentsCycle array, because 0 is the default value for the rightFromPaymentCycle for all addresses.
    constructor(
        uint256 initialAB,
        uint256 initialMinimumPeriod,
        uint256 initialEuroCentInWei,
        address payable _maintenancePool
    ) public {
        minimumPeriod = initialMinimumPeriod;
        euroCentInWei = initialEuroCentInWei;
        amountOfBasicIncome = initialAB;
        maintenancePool = _maintenancePool;
        paymentsCycle.push(0);
    }

    function claimUBIOwner(address payable[] memory citizens, bool onlyOne) public onlyOwner returns(bool) {
        bool allRequestedCitizensGotPayout = true;
        for(uint256 i = 0; i < citizens.length; i++) {
            if(!claimUBI(citizens[i], onlyOne)) {
              allRequestedCitizensGotPayout = false;
            }
        }
        return allRequestedCitizensGotPayout;
    }

    function claimUBIPublic(bool onlyOne) public {
        require(claimUBI(msg.sender, onlyOne), "There is no claimable UBI available for your account");
    }

    function createUseablePasswords(bytes32[] memory _useablePasswordHashes) public onlyOwner {
        for(uint256 i = 0; i < _useablePasswordHashes.length; i++) {
            bytes32 usablePasswordHash = _useablePasswordHashes[i];
            require(!useablePasswordHashes[usablePasswordHash], "One of your useablePasswords was already registered");
            useablePasswordHashes[usablePasswordHash] = true;
            emit LogUseablePasswordCreated(usablePasswordHash);
        }
    }

    /**
     * Allows anybody to request making an UBI available for the citizens when the lastPayout is more than one week ago and
     * AE / AC >= AB
    */
    /**
     * decreases the variable availableEther (which is increased in the function sponsorVault)
     * increases the variable promisedEther (which is decreased in the function claimUBI)
     * increases the lastPayout variable to the current time
     * sets the ether promised during this cycle as a new value in the paymentsCycle array (which is also set in the constructor)
    */
    function createUBI(uint256 adjustedEuroCentInWei) public onlyOwner {
//        uint256 adjustedDollarInWei = adjustedEuroCentInWei.mul(100);
        uint256 totalamountOfBasicIncomeInWei = adjustedEuroCentInWei.mul(amountOfBasicIncome).mul(amountOfCitizens);
        // We only allow a fluctuation of 5% per UBI creation
//        require(adjustedDollarInWei >= euroCentInWei.mul(95) && adjustedDollarInWei <= euroCentInWei.mul(105), "The exchange rate can only fluctuate +- 5% per createUBI call");
        require(lastPayout <= now - minimumPeriod, "You should wait the required time in between createUBI calls");
        require(availableEther.div(adjustedEuroCentInWei).div(amountOfCitizens) >= amountOfBasicIncome, "There are not enough funds in the UBI contract to sustain another UBI");
        euroCentInWei = adjustedEuroCentInWei;
        availableEther = availableEther.sub(totalamountOfBasicIncomeInWei);
        promisedEther = promisedEther.add(totalamountOfBasicIncomeInWei);

        paymentsCycle.push(adjustedEuroCentInWei.mul(amountOfBasicIncome));
        lastPayout = now;

        // if there is enough income available (7$)
        if(availableEther >= adjustedEuroCentInWei.mul(700).mul(amountOfCitizens)) {
            // and we increased it twice before,
            if(amountOfBasicIncomeCanBeIncreased == 2) {
                amountOfBasicIncomeCanBeIncreased = 0;
                amountOfBasicIncome = amountOfBasicIncome.add(700);
            // and we did not increase it twice before
            } else {
                amountOfBasicIncomeCanBeIncreased++;
            }
        // if there is not enough income available and we increased the counter prior to this function call
        } else if(amountOfBasicIncomeCanBeIncreased != 0) {
            amountOfBasicIncomeCanBeIncreased == 0;
        }
        emit LogUBICreated(adjustedEuroCentInWei, totalamountOfBasicIncomeInWei, amountOfCitizens, amountOfBasicIncomeCanBeIncreased, paymentsCycle.length - 1);
    }

    function registerCitizenOwner(address newCitizen) public onlyOwner {
        require(newCitizen != address(0) , "NewCitizen cannot be the 0 address");
        registerCitizen(newCitizen);
    }

    function registerCitizenPublic(bytes32 password) public {
        bytes32 passwordHash = keccak256(abi.encodePacked(password));
        require(useablePasswordHashes[passwordHash] && !usedPasswordHashes[passwordHash], "Password is not known or already used");
        usedPasswordHashes[passwordHash] = true;
        registerCitizen(msg.sender);
        emit LogPasswordUsed(password, passwordHash);
    }

    /**
     * Increases the availableEther with 95% of the transfered value, the remainder is available for maintenancePool.
     * AE becomes available for the citizens in the next paymentsCycle
    */
    ///@dev availableEther is truncated (rounded down), the remainder becomes available for maintenancePool
    function sponsorVault(bytes32 message) public payable whenNotPaused {
        moneyReceived(message);
    }

    // Allows citizens to claim their UBI which was made available since the last time they claimed it (or have registered, whichever is bigger)
    /**
     * 
     * increases the rightFromPaymentCycle for the caller (also increased in the function registerCitizen)
     * decreases the promisedEther (which is increased in the function createUBI)
    */
    function claimUBI(address payable citizen, bool onlyOne) internal returns(bool) {
        require(rightFromPaymentCycle[citizen] != 0, "Citizen not registered");
        uint256 incomeClaims = paymentsCycle.length - rightFromPaymentCycle[citizen];
        uint256 income;
        uint256 paymentsCycleLength = paymentsCycle.length;
        if(onlyOne && incomeClaims > 0) {
          income = paymentsCycle[paymentsCycleLength - incomeClaims];
        } else if(incomeClaims == 1) {
            income = paymentsCycle[paymentsCycleLength - 1];
        } else if(incomeClaims > 1) {
            for(uint256 index; index < incomeClaims; index++) {
                income = income.add(paymentsCycle[paymentsCycleLength - incomeClaims + index]);
            }
        } else {
            return false;
        }
        rightFromPaymentCycle[citizen] = paymentsCycleLength;
        promisedEther = promisedEther.sub(income);
        citizen.transfer(income);
        emit LogUBIClaimed(msg.sender, income, citizen);
        return true;

    }

    function moneyReceived(bytes32 message) internal {
      uint256 increaseInAvailableEther = msg.value.mul(95) / 100;
      availableEther = availableEther.add(increaseInAvailableEther);
      maintenancePool.transfer(msg.value - increaseInAvailableEther);
      emit LogVaultSponsored(msg.sender, message, msg.value);
    }

     /**
     * Allows a person to register as a citizen in the UBIVault.
     * The citizen will have a claim on the AE from the next paymentsCycle onwards.
    */
    //Increases the variable rightFromPaymentCycle for a citizen (also increased in the function claimUBI)
    function registerCitizen(address newCitizen) internal {
        require(rightFromPaymentCycle[newCitizen] == 0, "Citizen already registered");
        rightFromPaymentCycle[newCitizen] = paymentsCycle.length;
        amountOfCitizens++;
        emit LogCitizenRegistered(newCitizen);
    }

    function () external payable whenNotPaused {
        moneyReceived(bytes32(0));
    }
}