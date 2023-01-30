pragma solidity ^0.5.7;

import "./IERC20.sol";
import "./Managed.sol";
import "./AllowanceChecker.sol";
import "./IERC20Mintable.sol";
import "./IOriginate.sol";

/*solium-disable-next-line*/
contract Originate is Managed, IOriginate, AllowanceChecker {

    struct Request {
        address requesterAddress;
        mapping(address => uint256[2]) stableCoinAddressToAmount;
        address[] stableCoins;
        RequestState originateRequestState;
    }

    Request[] public allOriginatesRequests;

    event OriginateRequestCreated(
        uint256 _originateId,
        address requesterAddress,
        address[] stableCoins,
        uint256[] coinsAmount
    );

    event CoinsOriginated(
        uint256 _originateId,
        address[] stableCoins,
        uint256[] exchangedCoinsAmount
    );

    event OriginateRequestCanceled(
        uint256 _originateId,
        address requesterAddress
    );

    modifier requireOriginateIdExisting(uint256 _originateId) {
        require(
            _originateId < allOriginatesRequests.length,
            ERROR_ACCESS_DENIED
        );
        _;
    }

    modifier onlyPermittedCoin(address _stableCoinAddress) {
        require(
            true == hasPermission(
            _stableCoinAddress,
            PERMITTED_COINS
        ),
            ERROR_NOT_PERMITTED_COIN
        );
        _;
    }

    constructor(address _managementAddress)
    public
    Managed(_managementAddress)
    {}

    function externalOriginate(
        uint256 _originateId,
        address[] calldata _stableCoinAddresses,
        uint256[] calldata _maxCoinsAmount
    )
    external
    requirePermission(CAN_EXCHANGE_COINS)
    returns (bool)
    {
        internalOriginate(
            _originateId,
            _stableCoinAddresses,
            _maxCoinsAmount
        );
        return true;
    }

    function externalMultiOriginate(
        uint256[] calldata _originateIds,
        address[] calldata _stableCoinAddresses,
        uint256[] calldata _maxCoinsAmount
    )
    external
    requirePermission(CAN_EXCHANGE_COINS)
    {
        for (uint256 i = 0; i < _originateIds.length; i++) {
            if (
                allOriginatesRequests[_originateIds[i]].originateRequestState != RequestState.PaidPartially &&
                allOriginatesRequests[_originateIds[i]].originateRequestState != RequestState.Pending
            ) {
                continue;
            }
            internalOriginate(
                _originateIds[i],
                _stableCoinAddresses,
                _maxCoinsAmount
            );
        }
    }

    function createOriginateRequest(
        address[] memory _stableCoinAddresses,
        uint256[] memory _values
    )
    public
    requireContractExistsInRegistry(CONTRACT_TOKEN)
    returns (bool)
    {
        require(
            _stableCoinAddresses.length == _values.length,
            ERROR_WRONG_AMOUNT
        );
        allOriginatesRequests.push(
            Request(
                {
                requesterAddress : msg.sender,
                originateRequestState : RequestState.Pending,
                stableCoins : _stableCoinAddresses
                }
            )
        );
        Request storage request = allOriginatesRequests[
        allOriginatesRequests.length.sub(1)
        ];
        for (uint256 i = 0; i < _stableCoinAddresses.length; i++) {
            internalValidateCoin(_stableCoinAddresses[i], _values[i]);
            request.stableCoinAddressToAmount[
            _stableCoinAddresses[i]
            ] = [
            _values[i],
            0
            ];
        }
        emit OriginateRequestCreated(
            allOriginatesRequests.length.sub(1),
            msg.sender,
            _stableCoinAddresses,
            _values
        );
        for (uint256 i = 0; i < _stableCoinAddresses.length; i++) {
            IERC20(_stableCoinAddresses[i]).transferFrom(
                msg.sender,
                address(this),
                _values[i]
            );
        }
        return true;
    }

    function cancelOriginateRequest(
        uint256 _originateRequestId
    )
    public
    requireOriginateIdExisting(_originateRequestId)
    returns (bool)
    {
        Request storage request = allOriginatesRequests[_originateRequestId];
        require(request.requesterAddress == msg.sender, ERROR_ACCESS_DENIED);
        require(
            request.originateRequestState == RequestState.Pending,
            ERROR_ACCESS_DENIED
        );
        request.originateRequestState = RequestState.Canceled;

        emit OriginateRequestCanceled(
            _originateRequestId,
            msg.sender
        );
        for (uint256 i = 0; i < request.stableCoins.length; i++) {
            IERC20(request.stableCoins[i]).transfer(
                msg.sender,
                request.stableCoinAddressToAmount[request.stableCoins[i]][0]
            );
        }
        return true;
    }

    function getStableCoinAmountsByRequestId(
        uint256 _originateId,
        address _stableCoin
    )
    public
    view
    returns (uint256[2] memory)
    {
        Request storage request = allOriginatesRequests[_originateId];
        return request.stableCoinAddressToAmount[_stableCoin];
    }

    function getStableCoinsAddressesByRequestId(
        uint256 _originateId
    )
    public
    view
    returns (address[] memory)
    {
        Request storage request = allOriginatesRequests[_originateId];
        return request.stableCoins;
    }

    function internalOriginate(
        uint256 _originateId,
        address[] memory _stableCoinAddresses,
        uint256[] memory _maxCoinsAmount
    )
    internal
    requireOriginateIdExisting(_originateId)
    {
        require(
            _maxCoinsAmount.length == _stableCoinAddresses.length,
            ERROR_WRONG_AMOUNT
        );
        Request storage request = allOriginatesRequests[_originateId];
        bool originated;
        uint256 usdAmount;

        for (uint256 i = 0; i < _stableCoinAddresses.length; i++) {
            requirePermittedCoin(_stableCoinAddresses[i]);

            uint256[2] memory coinAmounts = request.stableCoinAddressToAmount[
            _stableCoinAddresses[i]
            ];
            uint256 amountToExchange = coinAmounts[0].sub(coinAmounts[1]);
            if (_maxCoinsAmount[i] < amountToExchange) {
                amountToExchange = _maxCoinsAmount[i];
            }
            coinAmounts[1] = coinAmounts[1].add(amountToExchange);
            if (
                coinAmounts[0] > coinAmounts[1] ||
                (i > 0 && false == originated)
            ) {
                originated = false;
            } else {
                originated = true;
            }

            usdAmount = usdAmount.add(
                management.calculateUsdByCoin(
                    _stableCoinAddresses[i],
                    amountToExchange
                )
            );
            IERC20(_stableCoinAddresses[i]).transfer(
                management.coinsHolder(),
                amountToExchange
            );
        }
        internalMintBlobsByUSD(
            request.requesterAddress,
            usdAmount
        );
        if (false == originated) {
            request.originateRequestState = RequestState.PaidPartially;
        } else {
            request.originateRequestState = RequestState.FullyPaid;
        }

        emit CoinsOriginated(
            _originateId,
            _stableCoinAddresses,
            _maxCoinsAmount
        );
    }

    function internalMintBlobsByUSD(
        address _holderAddress,
        uint256 _usdAmount
    )
    internal
    {
        IERC20Mintable(
            management.contractRegistry(CONTRACT_TOKEN)
        ).mint(
            _holderAddress,
            (_usdAmount).div(management.blobCoinPrice())
        );
    }

    function requirePermittedCoin(address _stableCoinAddress)
    internal
    onlyPermittedCoin(_stableCoinAddress)
    {

    }

    function internalValidateCoin(address _stableCoinAddress, uint256 _value)
    internal
    requireAllowance(
        _stableCoinAddress,
        msg.sender,
        _value
    )
    onlyPermittedCoin(_stableCoinAddress)
    {}
}
