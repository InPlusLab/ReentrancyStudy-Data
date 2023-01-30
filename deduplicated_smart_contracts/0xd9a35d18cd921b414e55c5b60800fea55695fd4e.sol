pragma solidity ^0.5.7;

import "./IERC20.sol";
import "./Ownable.sol";
import "./Managed.sol";
import "./BlobCoin.sol";
import "./AllowanceChecker.sol";
import "./ERC20Burnable.sol";
import "./IDissolve.sol";

contract Dissolve is IDissolve, Managed, AllowanceChecker {

    struct Request {
        uint256 totalAmount; //100 blobs
        uint256 dissolvedAmount; //10 blobs
        address requesterAddress;
        RequestState dissolveRequestState;
    }

    Request[] public allDissolvesRequests;

    mapping(address => uint256[]) public holderToDissolveRequestId;
    mapping(uint256  => address) public dissolveRequestIdToHolder;

    event DissolveRequestCreated(
        uint256 _dissolveId,
        uint256 coinsAmount,
        address requesterAddress
    );

    event DissolveRequestRemoved(
        uint256 _dissolveId,
        uint256 coinsAmountUnlocked,
        address requesterAddress
    );

    event CoinsDissolve(
        uint256 _dissolveId,
        uint256 requestedAmount,
        uint256 dissolvedAmount
    );

    modifier requireDissolveIdExisting(uint256 _dissolveId) {
        require(
            _dissolveId < allDissolvesRequests.length,
            ERROR_ACCESS_DENIED
        );
        _;
    }

    modifier requireHasEnoughBlobs(uint256 _amount) {
        BlobCoin blobCoin = BlobCoin(
            management.contractRegistry(CONTRACT_TOKEN)
        );
        uint256 requesterBalance = blobCoin.balanceOf(msg.sender);
        require(
            requesterBalance >= _amount &&
            blobCoin.allowedBalance(msg.sender, requesterBalance) >= _amount,
            ERROR_ACCESS_DENIED
        );
        _;
    }

    constructor(address _managementAddress)
    public
    Managed(_managementAddress)
    {}

    function externalDissolve(
        uint256 _dissolveId,
        uint256 _maxAmount
    )
    external
    requirePermission(CAN_EXCHANGE_COINS)
    returns (bool)
    {
        internalDissolve(
            _dissolveId,
            _maxAmount
        );
        return true;
    }

    function externalMultiDissolve(
        uint256[] calldata _dissolveIds,
        uint256 _maxAmount
    )
    external
    requirePermission(CAN_EXCHANGE_COINS)
    {
        for (uint256 i = 0; i < _dissolveIds.length; i++) {
            if (
                allDissolvesRequests[_dissolveIds[i]].dissolveRequestState != RequestState.PaidPartially &&
                allDissolvesRequests[_dissolveIds[i]].dissolveRequestState != RequestState.Pending
            ) {
                continue;
            }
            internalDissolve(
                _dissolveIds[i],
                _maxAmount
            );
        }

    }

    function removeDissolveRequest(
        uint256 _dissolveId
    )
    public
    requireContractExistsInRegistry(CONTRACT_TOKEN)
    returns (bool)
    {
        Request storage request = allDissolvesRequests[
        _dissolveId
        ];
        require(
            msg.sender == request.requesterAddress,
            ERROR_ACCESS_DENIED
        );
        require(
            request.dissolveRequestState == RequestState.PaidPartially ||
            request.dissolveRequestState == RequestState.Pending,
            ERROR_NOT_AVAILABLE
        );
        request.dissolveRequestState = RequestState.Refunded;
        uint256 amountToUnlock = request.totalAmount
        .sub(request.dissolvedAmount);
        request.totalAmount = request.dissolvedAmount;
        BlobCoin(management.contractRegistry(CONTRACT_TOKEN)).unlock(
            msg.sender,
            amountToUnlock
        );
        emit DissolveRequestRemoved(
            _dissolveId,
            amountToUnlock,
            msg.sender
        );
        return true;
    }

    function createDissolveRequest(uint256 _value)
    public
    requireContractExistsInRegistry(CONTRACT_TOKEN)
    requireHasEnoughBlobs(_value)
    returns (bool)
    {
        holderToDissolveRequestId[msg.sender].push(
            allDissolvesRequests.length
        );
        dissolveRequestIdToHolder[
        allDissolvesRequests.length
        ] = msg.sender;
        emit DissolveRequestCreated(
            allDissolvesRequests.length,
            _value,
            msg.sender
        );
        allDissolvesRequests.push(
            Request(
                _value,
                0,
                msg.sender,
                RequestState.Pending
            )
        );

        BlobCoin(management.contractRegistry(CONTRACT_TOKEN)).lock(
            msg.sender,
            _value
        );
        return true;
    }

    function internalDissolve(
        uint256 _dissolveId,
        uint256 _maxAmount
    )
    internal
    requireDissolveIdExisting(_dissolveId)
    {
        Request storage request = allDissolvesRequests[
        _dissolveId
        ];
        require(
            request.dissolveRequestState == RequestState.PaidPartially ||
            request.dissolveRequestState == RequestState.Pending,
            ERROR_NOT_AVAILABLE
        );
        uint256 amountToWithdraw = request.totalAmount
        .sub(request.dissolvedAmount);
        if (_maxAmount < amountToWithdraw) {
            amountToWithdraw = _maxAmount;
        }

        request.dissolvedAmount = request.dissolvedAmount
        .add(amountToWithdraw);

        if (request.totalAmount > request.dissolvedAmount) {
            request.dissolveRequestState = RequestState.PaidPartially;
        } else {
            request.dissolveRequestState = RequestState.FullyPaid;
        }
        internalBurnCoins(
            request.requesterAddress,
            amountToWithdraw
        );

        internalTransferCoinsBack(
            amountToWithdraw,
            request.requesterAddress
        );

        emit CoinsDissolve(
            _dissolveId,
            request.totalAmount,
            amountToWithdraw
        );
    }

    function internalBurnCoins(address _address, uint256 _amount) internal {
        ERC20Burnable(
            management.contractRegistry(CONTRACT_TOKEN)
        ).burnFrom(_address, _amount);
    }

    function internalTransferCoinsBack(
        uint256 _blobsAmountToWithdraw,
        address _coinsReceiver
    )
    internal
    {
        BlobCoin blobCoin = BlobCoin(
            management.contractRegistry(CONTRACT_TOKEN)
        );
        address[] memory permittedCoinsAddresses;
        uint256[] memory coinsAmount;
        (
        permittedCoinsAddresses,
        coinsAmount
        ) = management.calculateCoinsAmountByUSD(
            management.calculateUSDByBlobs(_blobsAmountToWithdraw).div(10**uint256(blobCoin.decimals()))
        );
        for (uint256 i = 1; i < permittedCoinsAddresses.length; i++) {
            if (
                coinsAmount[i] == 0 ||
                permittedCoinsAddresses[i] == address(0)
            ) {
                continue;
            }
            require(
                getCoinAllowance(
                    permittedCoinsAddresses[i],
                    management.coinsHolder()
                ) >= coinsAmount[i],
                ERROR_BALANCE_IS_NOT_ALLOWED
            );
            IERC20(permittedCoinsAddresses[i]).transferFrom(
                management.coinsHolder(),
                _coinsReceiver,
                coinsAmount[i]
            );
        }
    }
}
