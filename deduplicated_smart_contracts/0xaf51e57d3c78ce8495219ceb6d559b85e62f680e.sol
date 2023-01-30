/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;


interface ERC20 {
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
}


interface Adapter {

    /**
     * @dev MUST return name of the protocol.
     */
    function getProtocolName() external pure returns (string memory);

    /**
     * @dev MUST return amount of the given asset locked on the protocol by the given user.
     */
    function getAssetAmount(address asset, address user) external view returns (int128);

    /**
     * @dev MUST return struct with underlying assets rates for the given asset.
     */
    function getUnderlyingRates(address asset) external view returns (Component[] memory);
}


struct ProtocolDetail {
    string name;
    AssetBalance[] balances;
    AssetRate[] rates;
}


struct ProtocolBalance {
    string name;
    AssetBalance[] balances;
}


struct ProtocolRate {
    string name;
    AssetRate[] rates;
}


struct AssetBalance {
    address asset;
    int256 amount;
    uint8 decimals;
}


struct AssetRate {
    address asset;
    Component[] components;
}


struct Component {
    address underlying;
    uint256 rate;
}


contract Ownable {

    modifier onlyOwner {
        require(msg.sender == owner, "O: onlyOwner function!");
        _;
    }

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @notice Initializes owner variable with msg.sender address.
     */
    constructor() internal {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @notice Transfers ownership to the desired address.
     * The function is callable only by the owner.
     */
    function transferOwnership(address _owner) external onlyOwner {
        require(_owner != address(0), "O: new owner is the zero address!");
        emit OwnershipTransferred(owner, _owner);
        owner = _owner;
    }
}


/**
 * @title Base contract for AdapterRegistry.
 */
contract AdapterAssetsManager is Ownable {

    address internal constant INITIAL_ADAPTER = address(1);

    mapping(address => address) internal adapters;

    mapping(address => address[]) internal assets;

    /**
     * @notice Initializes contract storage.
     * @param _adapters Array with adapters.
     * @param _assets Nested array of supported assets for each adapter.
     */
    constructor(
        address[] memory _adapters,
        address[][] memory _assets
    )
        internal
    {
        require(_adapters.length == _assets.length, "AAM: wrong constructor parameters!");

        adapters[INITIAL_ADAPTER] = INITIAL_ADAPTER;

        for (uint256 i = 0; i < _adapters.length; i++) {
            addAdapter(_adapters[i], _assets[i]);
        }
    }

    /**
     * @notice Adds new adapter to adapters list.
     * The function is callable only by the owner.
     * @param newAdapter Address of new adapter.
     * @param _assets Addresses of adapter's assets.
     */
    function addAdapter(
        address newAdapter,
        address[] memory _assets
    )
        public
        onlyOwner
    {
        require(newAdapter != address(0), "AAM: zero adapter!");
        require(newAdapter != INITIAL_ADAPTER, "AAM: initial adapter!");
        require(adapters[newAdapter] == address(0), "AAM: adapter exists!");

        adapters[newAdapter] = adapters[INITIAL_ADAPTER];
        adapters[INITIAL_ADAPTER] = newAdapter;

        assets[newAdapter] = _assets;
    }

    /**
     * @notice Removes one of adapters from adapters list.
     * The function is callable only by the owner.
     * @param adapter Address of adapter to be removed.
     */
    function removeAdapter(
        address adapter
    )
        public
        onlyOwner
    {
        require(isValidAdapter(adapter), "AAM: invalid adapter!");

        address prevAdapter;
        address currentAdapter = adapters[adapter];
        while (currentAdapter != adapter) {
            prevAdapter = currentAdapter;
            currentAdapter = adapters[currentAdapter];
        }

        delete assets[adapter];

        adapters[prevAdapter] = adapters[adapter];
        adapters[adapter] = address(0);
    }

    /**
     * @notice Adds new asset to adapter.
     * The function is callable only by the owner.
     * @param adapter Address of adapter.
     * @param asset Address of new adapter's asset.
     */
    function addAdapterAsset(
        address adapter,
        address asset
    )
        public
        onlyOwner
    {
        require(isValidAdapter(adapter), "AAM: adapter is not valid!");
        assets[adapter].push(asset);
    }

    /**
     * @notice Removes one of adapter's assets by its index.
     * The function is callable only by the owner.
     * @param adapter Address of adapter.
     * @param assetIndex Index of adapter's asset to be removed.
     */
    function removeAdapterAsset(
        address adapter,
        uint256 assetIndex
    )
        public
        onlyOwner
    {
        require(isValidAdapter(adapter), "AAM: adapter is not valid!");

        address[] storage adapterAssets = assets[adapter];
        uint256 length = adapterAssets.length;
        require(assetIndex < length, "AAM: asset index is too large!");

        if (assetIndex != length - 1) {
            adapterAssets[assetIndex] = adapterAssets[length - 1];
        }

        adapterAssets.pop();
    }

    /**
     * @param adapter Address of adapter.
     * @return Array of adapter's assets.
     */
    function getAdapterAssets(
        address adapter
    )
        public
        view
        returns (address[] memory)
    {
        return assets[adapter];
    }

    /**
     * @return Array of adapters.
     */
    function getAdapters()
        public
        view
        returns (address[] memory)
    {
        uint256 counter = 0;
        address currentAdapter = adapters[INITIAL_ADAPTER];

        while (currentAdapter != INITIAL_ADAPTER) {
            currentAdapter = adapters[currentAdapter];
            counter++;
        }

        address[] memory adaptersList = new address[](counter);
        counter = 0;
        currentAdapter = adapters[INITIAL_ADAPTER];

        while (currentAdapter != INITIAL_ADAPTER) {
            adaptersList[counter] = currentAdapter;
            currentAdapter = adapters[currentAdapter];
            counter++;
        }

        return adaptersList;
    }

    /**
     * @param adapter Address of adapter.
     * @return Whether adapter is valid.
     */
    function isValidAdapter(
        address adapter
    )
        public
        view
        returns (bool)
    {
        return adapters[adapter] != address(0) && adapter != INITIAL_ADAPTER;
    }
}


/**
* @title Registry for protocol adapters.
* @notice getBalances() and getRates() functions
* with different arguments implement the main functionality.
*/
contract AdapterRegistry is AdapterAssetsManager {

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(
        address[] memory _adapters,
        address[][] memory _assets
    )
        public
        AdapterAssetsManager(_adapters, _assets)
    {}

    /**
     * @return All the amounts and rates of supported assets
     * via supported adapters by the given user.
     */
    function getBalancesAndRates(
        address user
    )
        external
        view
        returns(ProtocolDetail[] memory)
    {
        address[] memory adapters = getAdapters();
        ProtocolDetail[] memory protocolDetails = new ProtocolDetail[](adapters.length);

        for (uint256 i = 0; i < adapters.length; i++) {
            protocolDetails[i] = ProtocolDetail({
                name: Adapter(adapters[i]).getProtocolName(),
                balances: getBalances(user, adapters[i]),
                rates: getRates(adapters[i])
            });
        }

        return protocolDetails;
    }

    /**
     * @return All the amounts of supported assets
     * via supported adapters by the given user.
     */
    function getBalances(
        address user
    )
        external
        view
        returns(ProtocolBalance[] memory)
    {
        address[] memory adapters = getAdapters();
        ProtocolBalance[] memory protocolBalances = new ProtocolBalance[](adapters.length);

        for (uint256 i = 0; i < adapters.length; i++) {
            protocolBalances[i] = ProtocolBalance({
                name: Adapter(adapters[i]).getProtocolName(),
                balances: getBalances(user, adapters[i])
            });
        }

        return protocolBalances;
    }

    /**
     * @return All the exchange rates for supported assets
     * via the supported adapters.
     */
    function getRates()
        external
        view
        returns (ProtocolRate[] memory)
    {
        address[] memory adapters = getAdapters();
        ProtocolRate[] memory protocolRates = new ProtocolRate[](adapters.length);

        for (uint256 i = 0; i < adapters.length; i++) {
            protocolRates[i] = ProtocolRate({
                name: Adapter(adapters[i]).getProtocolName(),
                rates: getRates(adapters[i])
            });
        }

        return protocolRates;
    }

    /**
     * @return All the amounts of supported assets
     * via the given adapter by the given user.
     */
    function getBalances(
        address user,
        address adapter
    )
        public
        view
        returns (AssetBalance[] memory)
    {
        address[] memory adapterAssets = getAdapterAssets(adapter);

        return getBalances(user, adapter, adapterAssets);
    }

    /**
     * @return All the amounts of the given assets
     * via the given adapter by the given user.
     */
    function getBalances(
        address user,
        address adapter,
        address[] memory assets
    )
        public
        view
        returns (AssetBalance[] memory)
    {
        uint256 length = assets.length;
        AssetBalance[] memory assetBalances = new AssetBalance[](length);

        for (uint256 i = 0; i < length; i++) {
            address asset = assets[i];
            assetBalances[i] = AssetBalance({
                asset: asset,
                amount: Adapter(adapter).getAssetAmount(asset, user),
                decimals: getAssetDecimals(asset)
            });
        }

        return assetBalances;
    }

    /**
     * @return All the exchange rates for supported assets
     * via the given adapter.
     */
    function getRates(
        address adapter
    )
        public
        view
        returns (AssetRate[] memory)
    {
        address[] memory adapterAssets = assets[adapter];

        return getRates(adapter, adapterAssets);
    }

    /**
     * @return All the exchange rates for the given assets
     * via the given adapter.
     */
    function getRates(
        address adapter,
        address[] memory assets
    )
        public
        view
        returns (AssetRate[] memory)
    {
        uint256 length = assets.length;
        AssetRate[] memory rates = new AssetRate[](length);

        for (uint256 i = 0; i < length; i++) {
            address asset = assets[i];
            rates[i] = AssetRate({
                asset: asset,
                components: Adapter(adapter).getUnderlyingRates(asset)
            });
        }

        return rates;
    }

    function getAssetDecimals(
        address asset
    )
        internal
        view
        returns (uint8)
    {
        return asset == ETH ? uint8(18) : ERC20(asset).decimals();
    }

}