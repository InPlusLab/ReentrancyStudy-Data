// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

import "./TokenAppController.sol";
import "./IERC20.sol";
import "./IERC721.sol";
import "./IXStore.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";

contract XBounties is TokenAppController, ReentrancyGuard {
    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    uint256 public constant BASE = 10**18;
    uint256 public interval = 15 * 60; // 15 minutes
    uint256 public start = 1608667200; // Tue Dec 22 2020, 12pm PST
    uint64 public vestedUntil = 1609876800; // Tue, Jan 5 2021, 12pm PST

    IERC20 public nftxToken;
    address payable public daoMultiSig;

    struct Bounty {
        address tokenContract;
        uint256 nftxPrice;
        uint256 paidOut;
        uint256 payoutCap;
    }

    event NewBountyAdded(uint256 bountyId);
    event BountyFilled(
        uint256 bountyId,
        uint256 nftxAmount,
        uint256 assetAmount,
        address sender,
        uint64 start,
        uint64 cliff,
        uint64 vested
    );
    event NftxPriceSet(uint256 bountyId, uint256 newNftxPrice);
    event PayoutCapSet(uint256 bountyId, uint256 newCap);
    event BountyClosed(uint256 bountyId);
    event EthWithdrawn(uint256 amount);
    event Erc20Withdrawn(address tokenContract, uint256 amount);
    event Erc721Withdrawn(address nftContract, uint256 tokenId);

    Bounty[] internal bounties;

    constructor(
        address _tokenManager,
        address payable _daoMultiSig,
        address _nftxToken,
        address _xStore
    ) public {
        initTAC();
        setTokenManager(_tokenManager);
        daoMultiSig = _daoMultiSig;
        nftxToken = IERC20(_nftxToken);

        IXStore xStore = IXStore(_xStore);

        createEthBounty(130 * BASE, 65000 * BASE);
        createEthBounty(65 * BASE, 65000 * BASE);
        createEthBounty(BASE.mul(130).div(3), 65000 * BASE);
        createBounty(
            xStore.xTokenAddress(0), // PUNK-BASIC
            390 * BASE,
            31200 * BASE
        );
        createBounty(
            xStore.xTokenAddress(15), // PUNK-FEMALE
            520 * BASE,
            15600 * BASE
        );
        createBounty(
            xStore.xTokenAddress(1), // PUNK-ATTR-4
            585 * BASE,
            14625 * BASE
        );
        createBounty(
            xStore.xTokenAddress(2), // PUNK-ATTR-5
            1950 * BASE,
            15600 * BASE
        );
        createBounty(
            xStore.xTokenAddress(3), // PUNK-ZOMBIE
            8450 * BASE,
            16900 * BASE
        );
        createBounty(
            xStore.xTokenAddress(4), // AXIE-ORIGIN
            130 * BASE,
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(5), // AXIE-MYSTIC-1
            780 * BASE,
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(6), // AXIE-MYSTIC-2
            3900 * BASE,
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(7), // KITTY-GEN-0
            325 * BASE.div(10),
            6760 * BASE
        );
        createBounty(
            xStore.xTokenAddress(8), // KITTY-GEN-0-F
            39 * BASE,
            6240 * BASE
        );
        createBounty(
            xStore.xTokenAddress(9), // KITTY-FOUNDER
            6175 * BASE,
            6175 * BASE
        );
        createBounty(
            xStore.xTokenAddress(10), // AVASTR-BASIC
            195 * BASE.div(10),
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(11), // AVASTR-RANK-30
            26 * BASE,
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(12), // AVASTR-RANK-60
            195 * BASE,
            7800 * BASE
        );
        createBounty(
            xStore.xTokenAddress(13), // GLYPH
            1300 * BASE,
            23400 * BASE
        );
        createBounty(
            xStore.xTokenAddress(14), // JOY
            650 * BASE,
            11700 * BASE
        );
    }

    function setStart(uint256 newStart) public onlyOwner {
        start = newStart;
    }

    function setInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }

    function setVestedUntil(uint64 newTime) public onlyOwner {
        vestedUntil = newTime;
    }

    function getBountyInfo(uint256 bountyId)
        public
        view
        returns (address, uint256, uint256, uint256)
    {
        require(bountyId < bounties.length, "Invalid bountyId");
        return (
            bounties[bountyId].tokenContract,
            bounties[bountyId].nftxPrice,
            bounties[bountyId].paidOut,
            bounties[bountyId].payoutCap
        );
    }

    function getMaxPayout() public view returns (uint256) {
        uint256 tMinus4 = start.sub(interval.mul(4));
        uint256 tMinus3 = start.sub(interval.mul(3));
        uint256 tMinus2 = start.sub(interval.mul(2));
        uint256 tMinus1 = start.sub(interval.mul(1));
        uint256 tm4Max = 0;
        uint256 tm3Max = 50 * BASE;
        uint256 tm2Max = 500 * BASE;
        uint256 tm1Max = 5000 * BASE;
        uint256 tm0Max = 50000 * BASE;
        if (now < tMinus4) {
            return 0;
        } else if (now < tMinus3) {
            uint256 progressBigNum = now.sub(tMinus4).mul(BASE).div(interval);
            uint256 addedPayout = tm3Max.sub(tm4Max).mul(progressBigNum).div(
                BASE
            );
            return tm4Max.add(addedPayout);
        } else if (now < tMinus2) {
            uint256 progressBigNum = now.sub(tMinus3).mul(BASE).div(interval);
            uint256 addedPayout = tm2Max.sub(tm3Max).mul(progressBigNum).div(
                BASE
            );
            return tm3Max.add(addedPayout);
        } else if (now < tMinus1) {
            uint256 progressBigNum = now.sub(tMinus2).mul(BASE).div(interval);
            uint256 addedPayout = tm1Max.sub(tm2Max).mul(progressBigNum).div(
                BASE
            );
            return tm2Max.add(addedPayout);
        } else if (now < start) {
            uint256 progressBigNum = now.sub(tMinus1).mul(BASE).div(interval);
            uint256 addedPayout = tm0Max.sub(tm1Max).mul(progressBigNum).div(
                BASE
            );
            return tm1Max.add(addedPayout);
        } else {
            return tm0Max;
        }
    }

    function getBountiesLength() public view returns (uint256) {
        return bounties.length;
    }

    function getIsEth(uint256 bountyId) public view returns (bool) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].tokenContract == address(0);
    }

    function getTokenContract(uint256 bountyId) public view returns (address) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].tokenContract;
    }

    function getNftxPrice(uint256 bountyId) public view returns (uint256) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].nftxPrice;
    }

    function getPayoutCap(uint256 bountyId) public view returns (uint256) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].payoutCap;
    }

    function getPaidOut(uint256 bountyId) public view returns (uint256) {
        require(bountyId < bounties.length, "Invalid bountyId");
        return bounties[bountyId].paidOut;
    }

    function setNftxPrice(uint256 bountyId, uint256 newPrice) public onlyOwner {
        require(bountyId < bounties.length, "Invalid bountyId");
        bounties[bountyId].nftxPrice = newPrice;
        emit NftxPriceSet(bountyId, newPrice);
    }

    function setPayoutCap(uint256 bountyId, uint256 newCap) public onlyOwner {
        require(bountyId < bounties.length, "Invalid bountyId");
        bounties[bountyId].payoutCap = newCap;
        emit PayoutCapSet(bountyId, newCap);
    }

    function createEthBounty(uint256 nftxPricePerEth, uint256 amountOfEth)
        public
        onlyOwner
    {
        createBounty(address(0), nftxPricePerEth, amountOfEth);
    }

    function createBounty(address token, uint256 nftxPrice, uint256 payoutCap)
        public
        onlyOwner
    {
        Bounty memory newBounty;
        newBounty.tokenContract = token;
        newBounty.nftxPrice = nftxPrice;
        newBounty.payoutCap = payoutCap;
        bounties.push(newBounty);
        uint256 bountyId = bounties.length.sub(1);
        emit NewBountyAdded(bountyId);
    }

    function closeBounty(uint256 bountyId) public onlyOwner {
        require(bountyId < bounties.length, "Invalid bountyId");
        bounties[bountyId].payoutCap = bounties[bountyId].paidOut;
        emit BountyClosed(bountyId);
    }

    function fillBounty(uint256 bountyId, uint256 amountBeingSent)
        public
        payable
        nonReentrant
    {
        _fillBountyCustom(
            bountyId,
            amountBeingSent,
            vestedUntil - 2,
            vestedUntil - 1,
            vestedUntil
        );
    }

    /* function fillBountyCustom(
        uint256 bountyId,
        uint256 donationSize,
        uint64 _start,
        uint64 cliff,
        uint64 vested
    ) public payable nonReentrant {
        _fillBountyCustom(bountyId, donationSize, _start, cliff, vested);
    } */

    function _fillBountyCustom(
        uint256 bountyId,
        uint256 donationSize,
        uint64 _start,
        uint64 cliff,
        uint64 vested
    ) internal {
        require(cliff >= vestedUntil - 1 && vested >= vestedUntil, "Not valid");
        require(bountyId < bounties.length, "Invalid bountyId");
        Bounty storage bounty = bounties[bountyId];
        uint256 rewardCap = getMaxPayout();
        require(rewardCap > 0, "Must wait for cap to be lifted");
        uint256 remainingNftx = bounty.payoutCap.sub(bounty.paidOut);
        require(remainingNftx > 0, "Bounty is already finished");
        uint256 requestedNftx = donationSize.mul(bounty.nftxPrice).div(BASE);
        uint256 willGive = remainingNftx < requestedNftx
            ? remainingNftx
            : rewardCap < requestedNftx
            ? rewardCap
            : requestedNftx;
        uint256 willTake = donationSize.mul(willGive).div(requestedNftx);
        if (getIsEth(bountyId)) {
            require(msg.value >= willTake, "Value sent is insufficient");
            if (msg.value > willTake) {
                address payable _sender = msg.sender;
                _sender.transfer(msg.value.sub(willTake));
            }
            daoMultiSig.transfer(willTake);
        } else {
            IERC20 fundToken = IERC20(bounty.tokenContract);
            fundToken.safeTransferFrom(msg.sender, daoMultiSig, willTake);
        }
        if (now > vested) {
            nftxToken.safeTransfer(msg.sender, willGive);
        } else {
            nftxToken.safeTransfer(tokenManagerAddr, willGive);
            callAssignVested(
                msg.sender,
                willGive,
                _start,
                cliff,
                vested,
                false
            );
        }
        bounty.paidOut = bounty.paidOut.add(willGive);
        emit BountyFilled(
            bountyId,
            willGive,
            willTake,
            msg.sender,
            _start,
            cliff,
            vested
        );
    }

    function withdrawEth(uint256 amount) public onlyOwner {
        address payable sender = msg.sender;
        sender.transfer(amount);
        emit EthWithdrawn(amount);
    }

    function withdrawErc20(address tokenContract, uint256 amount)
        public
        onlyOwner
    {
        IERC20 token = IERC20(tokenContract);
        token.safeTransfer(msg.sender, amount);
        emit Erc20Withdrawn(tokenContract, amount);
    }

    function withdrawErc721(address nftContract, uint256 tokenId)
        public
        onlyOwner
    {
        IERC721 nft = IERC721(nftContract);
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        emit Erc721Withdrawn(nftContract, tokenId);
    }
}
