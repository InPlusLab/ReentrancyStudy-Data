// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

import "./Pausable.sol";
import "./IXToken.sol";
import "./IERC721.sol";
import "./ReentrancyGuard.sol";
import "./ERC721Holder.sol";
import "./IXStore.sol";
import "./Initializable.sol";
import "./SafeERC20.sol";

contract NFTX is Pausable, ReentrancyGuard, ERC721Holder {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event NewVault(uint256 indexed vaultId, address sender);
    event Mint(
        uint256 indexed vaultId,
        uint256[] nftIds,
        uint256 d2Amount,
        address sender
    );
    event Redeem(
        uint256 indexed vaultId,
        uint256[] nftIds,
        uint256 d2Amount,
        address sender
    );
    event MintRequested(
        uint256 indexed vaultId,
        uint256[] nftIds,
        address sender
    );

    IXStore public store;

    function initialize(address storeAddress) public initializer {
        initOwnable();
        initReentrancyGuard();
        store = IXStore(storeAddress);
    }

    /* function onlyManager(uint256 vaultId) internal view {
        
    } */

    function onlyPrivileged(uint256 vaultId) internal view {
        if (store.isFinalized(vaultId)) {
            require(msg.sender == owner(), "Not owner");
        } else {
            require(msg.sender == store.manager(vaultId), "Not manager");
        }
    }

    function isEligible(uint256 vaultId, uint256 nftId)
        public
        view
        virtual
        returns (bool)
    {
        return
            store.negateEligibility(vaultId)
                ? !store.isEligible(vaultId, nftId)
                : store.isEligible(vaultId, nftId);
    }

    function vaultSize(uint256 vaultId) public view virtual returns (uint256) {
        return
            store.isD2Vault(vaultId)
                ? store.d2Holdings(vaultId)
                : store.holdingsLength(vaultId).add(
                    store.reservesLength(vaultId)
                );
    }

    function _getPseudoRand(uint256 modulus)
        internal
        virtual
        returns (uint256)
    {
        store.setRandNonce(store.randNonce().add(1));
        return
            uint256(
                keccak256(abi.encodePacked(now, msg.sender, store.randNonce()))
            ) %
            modulus;
    }

    function _calcFee(
        uint256 amount,
        uint256 ethBase,
        uint256 ethStep,
        bool isD2
    ) internal pure virtual returns (uint256) {
        if (amount == 0) {
            return 0;
        } else if (isD2) {
            return ethBase.add(ethStep.mul(amount.sub(10**18)).div(10**18));
        } else {
            uint256 n = amount;
            uint256 nSub1 = amount >= 1 ? n.sub(1) : 0;
            return ethBase.add(ethStep.mul(nSub1));
        }
    }

    function _calcBounty(uint256 vaultId, uint256 numTokens, bool isBurn)
        public
        view
        virtual
        returns (uint256)
    {
        (, uint256 length) = store.supplierBounty(vaultId);
        if (length == 0) return 0;
        uint256 ethBounty = 0;
        for (uint256 i = 0; i < numTokens; i = i.add(1)) {
            uint256 _vaultSize = isBurn
                ? vaultSize(vaultId).sub(i.add(1))
                : vaultSize(vaultId).add(i);
            uint256 _ethBounty = _calcBountyHelper(vaultId, _vaultSize);
            ethBounty = ethBounty.add(_ethBounty);
        }
        return ethBounty;
    }

    function _calcBountyD2(uint256 vaultId, uint256 amount, bool isBurn)
        public
        view
        virtual
        returns (uint256)
    {
        (uint256 ethMax, uint256 length) = store.supplierBounty(vaultId);
        if (length == 0) return 0;
        uint256 prevSize = vaultSize(vaultId);
        uint256 prevDepth = prevSize > length ? 0 : length.sub(prevSize);
        uint256 prevReward = _calcBountyD2Helper(ethMax, length, prevSize);
        uint256 newSize = isBurn
            ? vaultSize(vaultId).sub(amount)
            : vaultSize(vaultId).add(amount);
        uint256 newDepth = newSize > length ? 0 : length.sub(newSize);
        uint256 newReward = _calcBountyD2Helper(ethMax, length, newSize);
        uint256 prevTriangle = prevDepth.mul(prevReward).div(2).div(10**18);
        uint256 newTriangle = newDepth.mul(newReward).div(2).div(10**18);
        return
            isBurn
                ? newTriangle.sub(prevTriangle)
                : prevTriangle.sub(newTriangle);
    }

    function _calcBountyD2Helper(uint256 ethMax, uint256 length, uint256 size)
        internal
        pure
        returns (uint256)
    {
        if (size >= length) return 0;
        return ethMax.sub(ethMax.mul(size).div(length));
    }

    function _calcBountyHelper(uint256 vaultId, uint256 _vaultSize)
        internal
        view
        virtual
        returns (uint256)
    {
        (uint256 ethMax, uint256 length) = store.supplierBounty(vaultId);
        if (_vaultSize >= length) return 0;
        uint256 depth = length.sub(_vaultSize);
        return ethMax.mul(depth).div(length);
    }

    function createVault(
        address _xTokenAddress,
        address _assetAddress,
        bool _isD2Vault
    ) public virtual nonReentrant returns (uint256) {
        onlyOwnerIfPaused(0);
        IXToken xToken = IXToken(_xTokenAddress);
        require(xToken.owner() == address(this), "Wrong owner");
        uint256 vaultId = store.addNewVault();
        store.setXTokenAddress(vaultId, _xTokenAddress);

        store.setXToken(vaultId);
        if (!_isD2Vault) {
            store.setNftAddress(vaultId, _assetAddress);
            store.setNft(vaultId);
            store.setNegateEligibility(vaultId, true);
        } else {
            store.setD2AssetAddress(vaultId, _assetAddress);
            store.setD2Asset(vaultId);
            store.setIsD2Vault(vaultId, true);
        }
        store.setManager(vaultId, msg.sender);
        emit NewVault(vaultId, msg.sender);
        return vaultId;
    }

    function depositETH(uint256 vaultId) public payable virtual {
        store.setEthBalance(vaultId, store.ethBalance(vaultId).add(msg.value));
    }

    function _payEthFromVault(
        uint256 vaultId,
        uint256 amount,
        address payable to
    ) internal virtual {
        uint256 ethBalance = store.ethBalance(vaultId);
        uint256 amountToSend = ethBalance < amount ? ethBalance : amount;
        if (amountToSend > 0) {
            store.setEthBalance(vaultId, ethBalance.sub(amountToSend));
            to.transfer(amountToSend);
        }
    }

    function _receiveEthToVault(
        uint256 vaultId,
        uint256 amountRequested,
        uint256 amountSent
    ) internal virtual {
        require(amountSent >= amountRequested, "Value too low");
        store.setEthBalance(
            vaultId,
            store.ethBalance(vaultId).add(amountRequested)
        );
        if (amountSent > amountRequested) {
            msg.sender.transfer(amountSent.sub(amountRequested));
        }
    }

    function requestMint(uint256 vaultId, uint256[] memory nftIds)
        public
        payable
        virtual
        nonReentrant
    {
        onlyOwnerIfPaused(1);
        require(store.allowMintRequests(vaultId), "Not allowed");
        // TODO: implement bounty + fees
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            require(
                store.nft(vaultId).ownerOf(nftIds[i]) != address(this),
                "Already owner"
            );
            store.nft(vaultId).safeTransferFrom(
                msg.sender,
                address(this),
                nftIds[i]
            );
            require(
                store.nft(vaultId).ownerOf(nftIds[i]) == address(this),
                "Not received"
            );
            store.setRequester(vaultId, nftIds[i], msg.sender);
        }
        emit MintRequested(vaultId, nftIds, msg.sender);
    }

    function revokeMintRequests(uint256 vaultId, uint256[] memory nftIds)
        public
        virtual
        nonReentrant
    {
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            require(
                store.requester(vaultId, nftIds[i]) == msg.sender,
                "Not requester"
            );
            store.setRequester(vaultId, nftIds[i], address(0));
            store.nft(vaultId).safeTransferFrom(
                address(this),
                msg.sender,
                nftIds[i]
            );
        }
    }

    function approveMintRequest(uint256 vaultId, uint256[] memory nftIds)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            address requester = store.requester(vaultId, nftIds[i]);
            require(requester != address(0), "No request");
            require(
                store.nft(vaultId).ownerOf(nftIds[i]) == address(this),
                "Not owner"
            );
            store.setRequester(vaultId, nftIds[i], address(0));
            store.setIsEligible(vaultId, nftIds[i], true);
            if (store.shouldReserve(vaultId, nftIds[i])) {
                store.reservesAdd(vaultId, nftIds[i]);
            } else {
                store.holdingsAdd(vaultId, nftIds[i]);
            }
            store.xToken(vaultId).mint(requester, 10**18);
        }
    }

    function _mint(uint256 vaultId, uint256[] memory nftIds, bool isDualOp)
        internal
        virtual
    {
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            uint256 nftId = nftIds[i];
            require(isEligible(vaultId, nftId), "Not eligible");
            require(
                store.nft(vaultId).ownerOf(nftId) != address(this),
                "Already owner"
            );
            store.nft(vaultId).safeTransferFrom(
                msg.sender,
                address(this),
                nftId
            );
            require(
                store.nft(vaultId).ownerOf(nftId) == address(this),
                "Not received"
            );
            if (store.shouldReserve(vaultId, nftId)) {
                store.reservesAdd(vaultId, nftId);
            } else {
                store.holdingsAdd(vaultId, nftId);
            }
        }
        if (!isDualOp) {
            uint256 amount = nftIds.length.mul(10**18);
            store.xToken(vaultId).mint(msg.sender, amount);
        }
    }

    function _mintD2(uint256 vaultId, uint256 amount) internal virtual {
        store.d2Asset(vaultId).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        store.xToken(vaultId).mint(msg.sender, amount);
        store.setD2Holdings(vaultId, store.d2Holdings(vaultId).add(amount));
    }

    function _redeem(uint256 vaultId, uint256 numNFTs, bool isDualOp)
        internal
        virtual
    {
        for (uint256 i = 0; i < numNFTs; i = i.add(1)) {
            uint256[] memory nftIds = new uint256[](1);
            if (store.holdingsLength(vaultId) > 0) {
                uint256 rand = _getPseudoRand(store.holdingsLength(vaultId));
                nftIds[0] = store.holdingsAt(vaultId, rand);
            } else {
                uint256 rand = _getPseudoRand(store.reservesLength(vaultId));
                nftIds[0] = store.reservesAt(vaultId, rand);
            }
            _redeemHelper(vaultId, nftIds, isDualOp);
            emit Redeem(vaultId, nftIds, 0, msg.sender);
        }
    }

    function _redeemD2(uint256 vaultId, uint256 amount) internal virtual {
        store.xToken(vaultId).burnFrom(msg.sender, amount);
        store.d2Asset(vaultId).safeTransfer(msg.sender, amount);
        store.setD2Holdings(vaultId, store.d2Holdings(vaultId).sub(amount));
        uint256[] memory nftIds = new uint256[](0);
        emit Redeem(vaultId, nftIds, amount, msg.sender);
    }

    function _redeemHelper(
        uint256 vaultId,
        uint256[] memory nftIds,
        bool isDualOp
    ) internal virtual {
        if (!isDualOp) {
            store.xToken(vaultId).burnFrom(
                msg.sender,
                nftIds.length.mul(10**18)
            );
        }
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            uint256 nftId = nftIds[i];
            require(
                store.holdingsContains(vaultId, nftId) ||
                    store.reservesContains(vaultId, nftId),
                "NFT not in vault"
            );
            if (store.holdingsContains(vaultId, nftId)) {
                store.holdingsRemove(vaultId, nftId);
            } else {
                store.reservesRemove(vaultId, nftId);
            }
            if (store.flipEligOnRedeem(vaultId)) {
                bool isElig = store.isEligible(vaultId, nftId);
                store.setIsEligible(vaultId, nftId, !isElig);
            }
            store.nft(vaultId).safeTransferFrom(
                address(this),
                msg.sender,
                nftId
            );
        }
    }

    function mint(uint256 vaultId, uint256[] memory nftIds, uint256 d2Amount)
        public
        payable
        virtual
        nonReentrant
    {
        onlyOwnerIfPaused(1);
        uint256 amount = store.isD2Vault(vaultId) ? d2Amount : nftIds.length;
        uint256 ethBounty = store.isD2Vault(vaultId)
            ? _calcBountyD2(vaultId, d2Amount, false)
            : _calcBounty(vaultId, amount, false);
        (uint256 ethBase, uint256 ethStep) = store.mintFees(vaultId);
        uint256 ethFee = _calcFee(
            amount,
            ethBase,
            ethStep,
            store.isD2Vault(vaultId)
        );
        if (ethFee > ethBounty) {
            _receiveEthToVault(vaultId, ethFee.sub(ethBounty), msg.value);
        }
        if (store.isD2Vault(vaultId)) {
            _mintD2(vaultId, d2Amount);
        } else {
            _mint(vaultId, nftIds, false);
        }
        if (ethBounty > ethFee) {
            _payEthFromVault(vaultId, ethBounty.sub(ethFee), msg.sender);
        }
        emit Mint(vaultId, nftIds, d2Amount, msg.sender);
    }

    function redeem(uint256 vaultId, uint256 amount)
        public
        payable
        virtual
        nonReentrant
    {
        onlyOwnerIfPaused(2);
        if (!store.isClosed(vaultId)) {
            uint256 ethBounty = store.isD2Vault(vaultId)
                ? _calcBountyD2(vaultId, amount, true)
                : _calcBounty(vaultId, amount, true);
            (uint256 ethBase, uint256 ethStep) = store.burnFees(vaultId);
            uint256 ethFee = _calcFee(
                amount,
                ethBase,
                ethStep,
                store.isD2Vault(vaultId)
            );
            if (ethBounty.add(ethFee) > 0) {
                _receiveEthToVault(vaultId, ethBounty.add(ethFee), msg.value);
            }
        }
        if (!store.isD2Vault(vaultId)) {
            _redeem(vaultId, amount, false);
        } else {
            _redeemD2(vaultId, amount);
        }

    }

    /* function mintAndRedeem(uint256 vaultId, uint256[] memory nftIds)
        public
        payable
        virtual
        nonReentrant
    {
        onlyOwnerIfPaused(3);
        require(!store.isD2Vault(vaultId), "Is D2 vault");
        require(!store.isClosed(vaultId), "Vault is closed");
        (uint256 ethBase, uint256 ethStep) = store.dualFees(vaultId);
        uint256 ethFee = _calcFee(
            nftIds.length,
            ethBase,
            ethStep,
            store.isD2Vault(vaultId)
        );
        if (ethFee > 0) {
            _receiveEthToVault(vaultId, ethFee, msg.value);
        }
        _mint(vaultId, nftIds, true);
        _redeem(vaultId, nftIds.length, true);
    } */

    function setIsEligible(
        uint256 vaultId,
        uint256[] memory nftIds,
        bool _boolean
    ) public virtual {
        onlyPrivileged(vaultId);
        for (uint256 i = 0; i < nftIds.length; i = i.add(1)) {
            store.setIsEligible(vaultId, nftIds[i], _boolean);
        }
    }

    function setAllowMintRequests(uint256 vaultId, bool isAllowed)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setAllowMintRequests(vaultId, isAllowed);
    }

    function setFlipEligOnRedeem(uint256 vaultId, bool flipElig)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setFlipEligOnRedeem(vaultId, flipElig);
    }

    function setNegateEligibility(uint256 vaultId, bool shouldNegate)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        require(
            store
                .holdingsLength(vaultId)
                .add(store.reservesLength(vaultId))
                .add(store.d2Holdings(vaultId)) ==
                0,
            "Vault not empty"
        );
        store.setNegateEligibility(vaultId, shouldNegate);
    }

    /* function setShouldReserve(
        uint256 vaultId,
        uint256[] memory nftIds,
        bool _boolean
    ) public virtual {
        onlyPrivileged(vaultId);
        for (uint256 i = 0; i < nftIds.length; i.add(1)) {
            store.setShouldReserve(vaultId, nftIds[i], _boolean);
        }
    } */

    /* function setIsReserved(
        uint256 vaultId,
        uint256[] memory nftIds,
        bool _boolean
    ) public virtual {
        onlyPrivileged(vaultId);
        for (uint256 i = 0; i < nftIds.length; i.add(1)) {
            uint256 nftId = nftIds[i];
            if (_boolean) {
                require(
                    store.holdingsContains(vaultId, nftId),
                    "Invalid nftId"
                );
                store.holdingsRemove(vaultId, nftId);
                store.reservesAdd(vaultId, nftId);
            } else {
                require(
                    store.reservesContains(vaultId, nftId),
                    "Invalid nftId"
                );
                store.reservesRemove(vaultId, nftId);
                store.holdingsAdd(vaultId, nftId);
            }
        }
    } */

    function changeTokenName(uint256 vaultId, string memory newName)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.xToken(vaultId).changeName(newName);
    }

    function changeTokenSymbol(uint256 vaultId, string memory newSymbol)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.xToken(vaultId).changeSymbol(newSymbol);
    }

    function setManager(uint256 vaultId, address newManager) public virtual {
        onlyPrivileged(vaultId);
        store.setManager(vaultId, newManager);
    }

    function finalizeVault(uint256 vaultId) public virtual {
        onlyPrivileged(vaultId);
        if (!store.isFinalized(vaultId)) {
            store.setIsFinalized(vaultId, true);
        }
    }

    function closeVault(uint256 vaultId) public virtual {
        onlyPrivileged(vaultId);
        if (!store.isFinalized(vaultId)) {
            store.setIsFinalized(vaultId, true);
        }
        store.setIsClosed(vaultId, true);
    }

    function setMintFees(uint256 vaultId, uint256 _ethBase, uint256 _ethStep)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setMintFees(vaultId, _ethBase, _ethStep);
    }

    function setBurnFees(uint256 vaultId, uint256 _ethBase, uint256 _ethStep)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setBurnFees(vaultId, _ethBase, _ethStep);
    }

    /* function setDualFees(uint256 vaultId, uint256 _ethBase, uint256 _ethStep)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setDualFees(vaultId, _ethBase, _ethStep);
    } */

    function setSupplierBounty(uint256 vaultId, uint256 ethMax, uint256 length)
        public
        virtual
    {
        onlyPrivileged(vaultId);
        store.setSupplierBounty(vaultId, ethMax, length);
    }

}
