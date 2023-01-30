pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/common/SafeERC20.sol";
import "@aragon/os/contracts/lib/token/ERC20.sol";
import "@aragon/apps-token-manager/contracts/TokenManager.sol";
import "@aragon/apps-vault/contracts/Vault.sol";
import "@aragon/os/contracts/lib/math/SafeMath.sol";
import "@aragon/os/contracts/lib/math/SafeMath64.sol";


contract StakingManager is AragonApp {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;
    using SafeMath64 for uint64;

    // prettier-ignore
    bytes32 public constant CHANGE_LOCK_TIME_ROLE = keccak256("CHANGE_LOCK_TIME_ROLE");
    // prettier-ignore
    bytes32 public constant CHANGE_MAX_LOCKS_ROLE = keccak256("CHANGE_MAX_LOCKS_ROLE");
    // prettier-ignore
    bytes32 public constant CHANGE_VAULT_ROLE = keccak256("CHANGE_VAULT_ROLE");

    uint64 public constant MAX_LOCKS_LIMIT = 20;

    // prettier-ignore
    string private constant ERROR_ADDRESS_NOT_CONTRACT = "STAKING_MANAGER_ADDRESS_NOT_CONTRACT";
    // prettier-ignore
    string private constant ERROR_STAKE_REVERTED = "STAKING_MANAGER_STAKE_REVERTED";
    // prettier-ignore
    string private constant ERROR_INSUFFICENT_TOKENS = "STAKING_MANAGER_INSUFFICENT_TOKENS";
    // prettier-ignore
    string private constant ERROR_TOKENS_NOT_APPROVED = "STAKING_MANAGER_TOKENS_NOT_APPROVED";
    // prettier-ignore
    string private constant ERROR_NOT_ENOUGH_UNWRAPPABLE_TOKENS = "STAKING_MANAGER_NOT_ENOUGH_UNWRAPPABLE_TOKENS";
    // prettier-ignore
    string private constant ERROR_LOCK_TIME_TOO_LOW = "STAKING_MANAGER_LOCK_TIME_TOO_LOW";
    // prettier-ignore
    string private constant ERROR_IMPOSSIBLE_TO_INSERT = "STAKING_MANAGER_IMPOSSIBLE_TO_INSERT";
    // prettier-ignore
    string private constant ERROR_MAX_LOCKS_TOO_HIGH = "STAKING_MANAGER_MAX_LOCKS_TOO_HIGH";
    // prettier-ignore
    string private constant ERROR_AMOUNT_TOO_LOW = "STAKING_MANAGER_AMOUNT_TOO_LOW";

    struct Lock {
        uint64 lockDate;
        uint64 duration;
        uint256 amount;
    }

    TokenManager public wrappedTokenManager;
    Vault public vault;

    address public depositToken;
    uint64 public minLockTime;
    uint64 public maxLocks;

    mapping(address => Lock[]) public addressStakeLocks;

    event Staked(
        address sender,
        address receiver,
        uint256 amount,
        uint64 duration,
        uint64 lockDate
    );
    event Unstaked(address receiver, uint256 amount);
    event LockTimeChanged(uint256 duration);
    event MaxLocksChanged(uint64 maxLocks);
    event VaultChanged(address vault);

    /**
     * @notice Initialize StakingManager app contract
     * @param _tokenManager TokenManager address
     * @param _vault Vault address
     * @param _depositToken Accepted token address
     * @param _minLockTime number of seconds after which it's possible to unwrap tokens related to a wrap
     * @param _maxLocks number of possible stakedLocks for a given address before doing an unwrap
     */
    function initialize(
        address _tokenManager,
        address _vault,
        address _depositToken,
        uint64 _minLockTime,
        uint64 _maxLocks
    ) external onlyInit {
        require(isContract(_tokenManager), ERROR_ADDRESS_NOT_CONTRACT);
        require(isContract(_depositToken), ERROR_ADDRESS_NOT_CONTRACT);
        require(isContract(_vault), ERROR_ADDRESS_NOT_CONTRACT);
        require(_maxLocks <= MAX_LOCKS_LIMIT, ERROR_MAX_LOCKS_TOO_HIGH);

        wrappedTokenManager = TokenManager(_tokenManager);
        vault = Vault(_vault);
        depositToken = _depositToken;
        minLockTime = _minLockTime;
        maxLocks = _maxLocks;

        initialized();
    }

    /**
     * @notice Stake a given amount of `depositToken` into wrappedTokenManager's token
     * @dev This function requires the MINT_ROLE permission on the TokenManager specified
     * @param _amount Wrapped amount
     * @param _duration lock time for this wrapping
     * @param _receiver address who will receive back once unwrapped
     */
    function stake(
        uint256 _amount,
        uint64 _duration,
        address _receiver
    ) external returns (bool) {
        require(_duration >= minLockTime, ERROR_LOCK_TIME_TOO_LOW);
        require(_amount > 0, ERROR_AMOUNT_TOO_LOW);
        require(
            ERC20(depositToken).balanceOf(msg.sender) >= _amount,
            ERROR_INSUFFICENT_TOKENS
        );
        require(
            ERC20(depositToken).allowance(msg.sender, this) >= _amount,
            ERROR_TOKENS_NOT_APPROVED
        );
        require(
            ERC20(depositToken).safeTransferFrom(
                msg.sender,
                address(vault),
                _amount
            ),
            ERROR_STAKE_REVERTED
        );

        wrappedTokenManager.mint(_receiver, _amount);

        (
            uint256 emptyIndex,
            uint256 totalNumberOfStakedLocks
        ) = _getEmptyLockIndexForAddress(_receiver);
        uint64 lockDate = getTimestamp64();

        if (emptyIndex < totalNumberOfStakedLocks) {
            addressStakeLocks[_receiver][emptyIndex] = Lock(
                lockDate,
                _duration,
                _amount
            );
        } else {
            addressStakeLocks[_receiver].push(
                Lock(lockDate, _duration, _amount)
            );
        }

        emit Staked(msg.sender, _receiver, _amount, _duration, lockDate);
        return true;
    }

    /**
     * @notice Unstake a given amount of wrappedTokenManager's token
     * @dev This function requires the BURN_ROLE permissions on the TokenManager and TRANSFER_ROLE on the Vault specified
     * @param _amount Wrapped amount
     */
    function unstake(uint256 _amount) external returns (uint256) {
        require(
            _updateStakedTokenLocks(msg.sender, _amount),
            ERROR_NOT_ENOUGH_UNWRAPPABLE_TOKENS
        );

        wrappedTokenManager.burn(msg.sender, _amount);
        vault.transfer(depositToken, msg.sender, _amount);

        emit Unstaked(msg.sender, _amount);
        return _amount;
    }

    /**
     * @notice Change lock time
     * @param _minLockTime Lock time
     */
    function changeMinLockTime(uint64 _minLockTime)
        external
        auth(CHANGE_LOCK_TIME_ROLE)
    {
        minLockTime = _minLockTime;
        emit LockTimeChanged(minLockTime);
    }

    /**
     * @notice Change max stakedLocks
     * @param _maxLocks Maximun number of stakedLocks allowed for an address
     */
    function changeMaxAllowedStakeLocks(uint64 _maxLocks)
        external
        auth(CHANGE_MAX_LOCKS_ROLE)
    {
        require(_maxLocks <= MAX_LOCKS_LIMIT, ERROR_MAX_LOCKS_TOO_HIGH);
        maxLocks = _maxLocks;
        emit MaxLocksChanged(maxLocks);
    }

    /**
     * @notice Change vault
     * @param _vault new Vault address
     */
    function changeVaultContractAddress(address _vault)
        external
        auth(CHANGE_VAULT_ROLE)
    {
        require(isContract(_vault), ERROR_ADDRESS_NOT_CONTRACT);

        vault = Vault(_vault);
        emit VaultChanged(_vault);
    }

    /**
     * @notice Return all Locks for a given _address
     * @param _address address
     */
    function getStakedLocks(address _address) external view returns (Lock[]) {
        return addressStakeLocks[_address];
    }

    /**
     * @notice Check if it's possible to unwrap the specified _amountToUnstake of token and updates (or deletes) related stakedLocks
     * @param _unwrapper address who want to unwrap
     * @param _amountToUnstake amount
     */
    function _updateStakedTokenLocks(
        address _unwrapper,
        uint256 _amountToUnstake
    ) internal returns (bool) {
        Lock[] storage stakedLocks = addressStakeLocks[_unwrapper];

        uint256 totalAmountUnstakedSoFar = 0;
        uint256 stakedLocksLength = stakedLocks.length;
        uint64[] memory locksToRemove = new uint64[](stakedLocksLength);
        uint64 currentIndexOfLocksToBeRemoved = 0;

        bool result = false;
        uint64 timestamp = getTimestamp64();
        uint64 i = 0;
        for (; i < stakedLocksLength; i++) {
            if (
                timestamp >=
                stakedLocks[i].lockDate.add(stakedLocks[i].duration) &&
                !_isWrapLockEmpty(stakedLocks[i])
            ) {
                totalAmountUnstakedSoFar = totalAmountUnstakedSoFar.add(
                    stakedLocks[i].amount
                );

                if (_amountToUnstake == totalAmountUnstakedSoFar) {
                    locksToRemove[currentIndexOfLocksToBeRemoved] = i;
                    currentIndexOfLocksToBeRemoved = currentIndexOfLocksToBeRemoved
                        .add(1);
                    result = true;
                    break;
                } else if (_amountToUnstake < totalAmountUnstakedSoFar) {
                    stakedLocks[i].amount = totalAmountUnstakedSoFar.sub(
                        _amountToUnstake
                    );
                    result = true;
                    break;
                } else {
                    locksToRemove[currentIndexOfLocksToBeRemoved] = i;
                    currentIndexOfLocksToBeRemoved = currentIndexOfLocksToBeRemoved
                        .add(1);
                }
            }
        }

        for (i = 0; i < currentIndexOfLocksToBeRemoved; i++) {
            delete stakedLocks[locksToRemove[i]];
        }

        return result;
    }

    /**
     * @notice Returns the position in which it's possible to insert a new Lock within addressStakeLocks
     * @param _address address
     */
    function _getEmptyLockIndexForAddress(address _address)
        internal
        view
        returns (uint256, uint256)
    {
        Lock[] storage stakedLocks = addressStakeLocks[_address];
        uint256 numberOfStakeLocks = stakedLocks.length;

        if (numberOfStakeLocks < maxLocks) {
            return (maxLocks.add(1), numberOfStakeLocks);
        } else {
            for (uint256 i = 0; i < numberOfStakeLocks; i++) {
                if (_isWrapLockEmpty(stakedLocks[i])) {
                    return (i, numberOfStakeLocks);
                }
            }

            revert(ERROR_IMPOSSIBLE_TO_INSERT);
        }
    }

    /**
     * @notice Check if a Lock is empty
     * @param _lock lock
     */
    function _isWrapLockEmpty(Lock memory _lock) internal pure returns (bool) {
        return _lock.duration == 0 && _lock.lockDate == 0 && _lock.amount == 0;
    }
}