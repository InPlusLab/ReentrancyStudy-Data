// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

import "./EnumerableSet.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IXToken.sol";
import "./IERC721.sol";
import "./SafeERC20.sol";

contract XStore is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    struct FeeParams {
        uint256 ethBase;
        uint256 ethStep;
    }

    struct BountyParams {
        uint256 ethMax;
        uint256 length;
    }

    struct Vault {
        address xTokenAddress;
        address nftAddress;
        address manager;
        IXToken xToken;
        IERC721 nft;
        EnumerableSet.UintSet holdings;
        EnumerableSet.UintSet reserves;
        mapping(uint256 => address) requester;
        mapping(uint256 => bool) isEligible;
        mapping(uint256 => bool) shouldReserve;
        bool allowMintRequests;
        bool flipEligOnRedeem;
        bool negateEligibility;
        bool isFinalized;
        bool isClosed;
        FeeParams mintFees;
        FeeParams burnFees;
        FeeParams dualFees;
        BountyParams supplierBounty;
        uint256 ethBalance;
        uint256 tokenBalance;
        bool isD2Vault;
        address d2AssetAddress;
        IERC20 d2Asset;
        uint256 d2Holdings;
    }

    event XTokenAddressSet(uint256 indexed vaultId, address token);
    event NftAddressSet(uint256 indexed vaultId, address asset);
    event ManagerSet(uint256 indexed vaultId, address manager);
    event XTokenSet(uint256 indexed vaultId);
    event NftSet(uint256 indexed vaultId);
    event HoldingsAdded(uint256 indexed vaultId, uint256 id);
    event HoldingsRemoved(uint256 indexed vaultId, uint256 id);
    event ReservesAdded(uint256 indexed vaultId, uint256 id);
    event ReservesRemoved(uint256 indexed vaultId, uint256 id);
    event RequesterSet(uint256 indexed vaultId, uint256 id, address requester);
    event IsEligibleSet(uint256 indexed vaultId, uint256 id, bool _bool);
    event ShouldReserveSet(uint256 indexed vaultId, uint256 id, bool _bool);
    event AllowMintRequestsSet(uint256 indexed vaultId, bool isAllowed);
    event FlipEligOnRedeemSet(uint256 indexed vaultId, bool _bool);
    event NegateEligibilitySet(uint256 indexed vaultId, bool _bool);
    event IsFinalizedSet(uint256 indexed vaultId, bool _isFinalized);
    event IsClosedSet(uint256 indexed vaultId, bool _isClosed);
    event MintFeesSet(
        uint256 indexed vaultId,
        uint256 ethBase,
        uint256 ethStep
    );
    event BurnFeesSet(
        uint256 indexed vaultId,
        uint256 ethBase,
        uint256 ethStep
    );
    event DualFeesSet(
        uint256 indexed vaultId,
        uint256 ethBase,
        uint256 ethStep
    );
    event SupplierBountySet(
        uint256 indexed vaultId,
        uint256 ethMax,
        uint256 length
    );
    event EthBalanceSet(uint256 indexed vaultId, uint256 _ethBalance);
    event TokenBalanceSet(uint256 indexed vaultId, uint256 _tokenBalance);
    event IsD2VaultSet(uint256 indexed vaultId, bool _isD2Vault);
    event D2AssetAddressSet(uint256 indexed vaultId, address _d2Asset);
    event D2AssetSet(uint256 indexed vaultId);
    event D2HoldingsSet(uint256 indexed vaultId, uint256 _d2Holdings);
    event NewVaultAdded(uint256 indexed vaultId);
    event IsExtensionSet(address addr, bool _isExtension);
    event RandNonceSet(uint256 _randNonce);

    Vault[] internal vaults;

    mapping(address => bool) public isExtension;
    uint256 public randNonce;

    constructor() public {
        initOwnable();
    }

    function _getVault(uint256 vaultId) internal view returns (Vault storage) {
        require(vaultId < vaults.length, "Invalid vaultId");
        return vaults[vaultId];
    }

    function vaultsLength() public view returns (uint256) {
        return vaults.length;
    }

    function xTokenAddress(uint256 vaultId) public view returns (address) {
        Vault storage vault = _getVault(vaultId);
        return vault.xTokenAddress;
    }

    function nftAddress(uint256 vaultId) public view returns (address) {
        Vault storage vault = _getVault(vaultId);
        return vault.nftAddress;
    }

    function manager(uint256 vaultId) public view returns (address) {
        Vault storage vault = _getVault(vaultId);
        return vault.manager;
    }

    function xToken(uint256 vaultId) public view returns (IXToken) {
        Vault storage vault = _getVault(vaultId);
        return vault.xToken;
    }

    function nft(uint256 vaultId) public view returns (IERC721) {
        Vault storage vault = _getVault(vaultId);
        return vault.nft;
    }

    function holdingsLength(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.length();
    }

    function holdingsContains(uint256 vaultId, uint256 elem)
        public
        view
        returns (bool)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.contains(elem);
    }

    function holdingsAt(uint256 vaultId, uint256 index)
        public
        view
        returns (uint256)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.at(index);
    }

    function reservesLength(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.length();
    }

    function reservesContains(uint256 vaultId, uint256 elem)
        public
        view
        returns (bool)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.contains(elem);
    }

    function reservesAt(uint256 vaultId, uint256 index)
        public
        view
        returns (uint256)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.holdings.at(index);
    }

    function requester(uint256 vaultId, uint256 id)
        public
        view
        returns (address)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.requester[id];
    }

    function isEligible(uint256 vaultId, uint256 id)
        public
        view
        returns (bool)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.isEligible[id];
    }

    function shouldReserve(uint256 vaultId, uint256 id)
        public
        view
        returns (bool)
    {
        Vault storage vault = _getVault(vaultId);
        return vault.shouldReserve[id];
    }

    function allowMintRequests(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.allowMintRequests;
    }

    function flipEligOnRedeem(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.flipEligOnRedeem;
    }

    function negateEligibility(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.negateEligibility;
    }

    function isFinalized(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.isFinalized;
    }

    function isClosed(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.isClosed;
    }

    function mintFees(uint256 vaultId) public view returns (uint256, uint256) {
        Vault storage vault = _getVault(vaultId);
        return (vault.mintFees.ethBase, vault.mintFees.ethStep);
    }

    function burnFees(uint256 vaultId) public view returns (uint256, uint256) {
        Vault storage vault = _getVault(vaultId);
        return (vault.burnFees.ethBase, vault.burnFees.ethStep);
    }

    function dualFees(uint256 vaultId) public view returns (uint256, uint256) {
        Vault storage vault = _getVault(vaultId);
        return (vault.dualFees.ethBase, vault.dualFees.ethStep);
    }

    function supplierBounty(uint256 vaultId)
        public
        view
        returns (uint256, uint256)
    {
        Vault storage vault = _getVault(vaultId);
        return (vault.supplierBounty.ethMax, vault.supplierBounty.length);
    }

    function ethBalance(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.ethBalance;
    }

    function tokenBalance(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.tokenBalance;
    }

    function isD2Vault(uint256 vaultId) public view returns (bool) {
        Vault storage vault = _getVault(vaultId);
        return vault.isD2Vault;
    }

    function d2AssetAddress(uint256 vaultId) public view returns (address) {
        Vault storage vault = _getVault(vaultId);
        return vault.d2AssetAddress;
    }

    function d2Asset(uint256 vaultId) public view returns (IERC20) {
        Vault storage vault = _getVault(vaultId);
        return vault.d2Asset;
    }

    function d2Holdings(uint256 vaultId) public view returns (uint256) {
        Vault storage vault = _getVault(vaultId);
        return vault.d2Holdings;
    }

    function setXTokenAddress(uint256 vaultId, address _xTokenAddress)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.xTokenAddress = _xTokenAddress;
        emit XTokenAddressSet(vaultId, _xTokenAddress);
    }

    function setNftAddress(uint256 vaultId, address _nft) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.nftAddress = _nft;
        emit NftAddressSet(vaultId, _nft);
    }

    function setManager(uint256 vaultId, address _manager) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.manager = _manager;
        emit ManagerSet(vaultId, _manager);
    }

    function setXToken(uint256 vaultId) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.xToken = IXToken(vault.xTokenAddress);
        emit XTokenSet(vaultId);
    }

    function setNft(uint256 vaultId) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.nft = IERC721(vault.nftAddress);
        emit NftSet(vaultId);
    }

    function holdingsAdd(uint256 vaultId, uint256 elem) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.holdings.add(elem);
        emit HoldingsAdded(vaultId, elem);
    }

    function holdingsRemove(uint256 vaultId, uint256 elem) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.holdings.remove(elem);
        emit HoldingsRemoved(vaultId, elem);
    }

    function reservesAdd(uint256 vaultId, uint256 elem) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.reserves.add(elem);
        emit ReservesAdded(vaultId, elem);
    }

    function reservesRemove(uint256 vaultId, uint256 elem) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.reserves.remove(elem);
        emit ReservesRemoved(vaultId, elem);
    }

    function setRequester(uint256 vaultId, uint256 id, address _requester)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.requester[id] = _requester;
        emit RequesterSet(vaultId, id, _requester);
    }

    function setIsEligible(uint256 vaultId, uint256 id, bool _bool)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.isEligible[id] = _bool;
        emit IsEligibleSet(vaultId, id, _bool);
    }

    function setShouldReserve(uint256 vaultId, uint256 id, bool _shouldReserve)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.shouldReserve[id] = _shouldReserve;
        emit ShouldReserveSet(vaultId, id, _shouldReserve);
    }

    function setAllowMintRequests(uint256 vaultId, bool isAllowed)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.allowMintRequests = isAllowed;
        emit AllowMintRequestsSet(vaultId, isAllowed);
    }

    function setFlipEligOnRedeem(uint256 vaultId, bool flipElig)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.flipEligOnRedeem = flipElig;
        emit FlipEligOnRedeemSet(vaultId, flipElig);
    }

    function setNegateEligibility(uint256 vaultId, bool negateElig)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.negateEligibility = negateElig;
        emit NegateEligibilitySet(vaultId, negateElig);
    }

    function setIsFinalized(uint256 vaultId, bool _isFinalized)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.isFinalized = _isFinalized;
        emit IsFinalizedSet(vaultId, _isFinalized);
    }

    function setIsClosed(uint256 vaultId, bool _isClosed) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.isClosed = _isClosed;
        emit IsClosedSet(vaultId, _isClosed);
    }

    function setMintFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.mintFees = FeeParams(ethBase, ethStep);
        emit MintFeesSet(vaultId, ethBase, ethStep);
    }

    function setBurnFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.burnFees = FeeParams(ethBase, ethStep);
        emit BurnFeesSet(vaultId, ethBase, ethStep);
    }

    function setDualFees(uint256 vaultId, uint256 ethBase, uint256 ethStep)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.dualFees = FeeParams(ethBase, ethStep);
        emit DualFeesSet(vaultId, ethBase, ethStep);
    }

    function setSupplierBounty(uint256 vaultId, uint256 ethMax, uint256 length)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.supplierBounty = BountyParams(ethMax, length);
        emit SupplierBountySet(vaultId, ethMax, length);
    }

    function setEthBalance(uint256 vaultId, uint256 _ethBalance)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.ethBalance = _ethBalance;
        emit EthBalanceSet(vaultId, _ethBalance);
    }

    function setTokenBalance(uint256 vaultId, uint256 _tokenBalance)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.tokenBalance = _tokenBalance;
        emit TokenBalanceSet(vaultId, _tokenBalance);
    }

    function setIsD2Vault(uint256 vaultId, bool _isD2Vault) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.isD2Vault = _isD2Vault;
        emit IsD2VaultSet(vaultId, _isD2Vault);
    }

    function setD2AssetAddress(uint256 vaultId, address _d2Asset)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.d2AssetAddress = _d2Asset;
        emit D2AssetAddressSet(vaultId, _d2Asset);
    }

    function setD2Asset(uint256 vaultId) public onlyOwner {
        Vault storage vault = _getVault(vaultId);
        vault.d2Asset = IERC20(vault.d2AssetAddress);
        emit D2AssetSet(vaultId);
    }

    function setD2Holdings(uint256 vaultId, uint256 _d2Holdings)
        public
        onlyOwner
    {
        Vault storage vault = _getVault(vaultId);
        vault.d2Holdings = _d2Holdings;
        emit D2HoldingsSet(vaultId, _d2Holdings);
    }

    ////////////////////////////////////////////////////////////

    function addNewVault() public onlyOwner returns (uint256) {
        Vault memory newVault;
        vaults.push(newVault);
        uint256 vaultId = vaults.length.sub(1);
        emit NewVaultAdded(vaultId);
        return vaultId;
    }

    function setIsExtension(address addr, bool _isExtension) public onlyOwner {
        isExtension[addr] = _isExtension;
        emit IsExtensionSet(addr, _isExtension);
    }

    function setRandNonce(uint256 _randNonce) public onlyOwner {
        randNonce = _randNonce;
        emit RandNonceSet(_randNonce);
    }
}
