/**
 *Submitted for verification at Etherscan.io on 2019-09-04
*/

pragma solidity ^0.5.11;

// Voken Public-Sale Panel
//
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   support@vision.network
//   support@voken.io


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
contract Ownable {
    address internal _owner;
    address internal _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * IMPORTANT: Need to run {acceptOwnership} by the new owner.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);
        _newOwner = newOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Accept ownership of the contract.
     *
     * Can only be called by the new owner.
     */
    function acceptOwnership() public {
        require(msg.sender == _newOwner, "Ownable: caller is not the new owner address");
        require(msg.sender != address(0), "Ownable: caller is the zero address");

        emit OwnershipAccepted(_owner, msg.sender);
        _owner = msg.sender;
        _newOwner = address(0);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * Can only be called by the current owner.
     */
    function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(recipient != address(0), "Rescue: recipient is the zero address");
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount, "Rescue: amount exceeds balance");
        _token.transfer(recipient, amount);
    }

    /**
     * @dev Withdraw Ether
     *
     * Can only be called by the current owner.
     */
    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Withdraw: recipient is the zero address");

        uint256 balance = address(this).balance;

        require(balance >= amount, "Withdraw: amount exceeds balance");
        recipient.transfer(amount);
    }
}


/**
 * @dev Interface of the ERC20 standard
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}


/**
 * @dev Interface of Voken public-sale
 */
interface VokenPublicSale {
    function status() external view returns (uint16 stage,
                                             uint16 season,
                                             uint256 etherUsdPrice,
                                             uint256 vokenUsdPrice,
                                             uint256 shareholdersRatio);
    function sum() external view returns(uint256 vokenIssued,
                                         uint256 vokenBonus,
                                         uint256 weiSold,
                                         uint256 weiRewarded,
                                         uint256 weiShareholders,
                                         uint256 weiTeam,
                                         uint256 weiPended,
                                         uint256 usdSold,
                                         uint256 usdRewarded);
    function transactions() external view returns(uint256 txs,
                                                  uint256 vokenIssuedTxs,
                                                  uint256 vokenBonusTxs);
    function queryAccount(address account) external view returns (uint256 vokenIssued,
                                                                  uint256 vokenBonus,
                                                                  uint256 vokenReferral,
                                                                  uint256 vokenReferrals,
                                                                  uint256 weiPurchased,
                                                                  uint256 weiRewarded,
                                                                  uint256 usdPurchased,
                                                                  uint256 usdRewarded);
    function accountInSeason(address account, uint16 seasonNumber) external view returns (uint256 vokenIssued,
                                                                                          uint256 vokenBonus,
                                                                                          uint256 vokenReferral,
                                                                                          uint256 vokenReferrals,
                                                                                          uint256 weiPurchased,
                                                                                          uint256 weiReferrals,
                                                                                          uint256 weiRewarded,
                                                                                          uint256 usdPurchased,
                                                                                          uint256 usdReferrals,
                                                                                          uint256 usdRewarded);
    function seasonReferrals(uint16 seasonNumber) external view returns (address[] memory);
    function seasonAccountReferrals(uint16 seasonNumber, address account) external view returns (address[] memory);
    function reservedOf(address account) external view returns (uint256);
}


/**
 * @title Voken Public-Sale Panel
 */
contract VokenPublicSalePanel is Ownable {
    VokenPublicSale private _PUBLIC_SALE = VokenPublicSale(0xfEb75b3cC7281B18f2d475A04F1fFAAA3C9a6E36);

    event Donate(address indexed account, uint256 amount);


    /**
     * @dev Donate
     */
    function () external payable {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    function status() public view returns (uint16 stage,
                                           uint16 season,
                                           uint256 etherUsdPrice,
                                           uint256 vokenUsdPrice,
                                           uint256 shareholdersRatio,
                                           uint256 txs,
                                           uint256 vokenIssued,
                                           uint256 vokenBonus,
                                           uint256 weiRewarded,
                                           uint256 usdRewarded) {
        (stage, season, etherUsdPrice, vokenUsdPrice, shareholdersRatio) = _PUBLIC_SALE.status();
        (vokenIssued, vokenBonus, , weiRewarded, , , , usdRewarded, ) = _PUBLIC_SALE.sum();
        (txs, ,) = _PUBLIC_SALE.transactions();
    }

    function queryAccount(address account) public view returns (uint256 vokenIssued,
                                                                uint256 vokenBonus,
                                                                uint256 vokenReferral,
                                                                uint256 vokenReferrals,
                                                                uint256 weiRewarded,
                                                                uint256 usdRewarded,
                                                                uint256 reserved) {
        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , weiRewarded, , usdRewarded) = _PUBLIC_SALE.queryAccount(account);
        reserved = _PUBLIC_SALE.reservedOf(account);
    }

    function queryAccountInSeason(address account, uint16 seasonNumber) public view returns (uint256 vokenIssued,
                                                                                             uint256 vokenBonus,
                                                                                             uint256 vokenReferral,
                                                                                             uint256 vokenReferrals,
                                                                                             uint256 weiRewarded,
                                                                                             uint256 usdRewarded) {
        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , , weiRewarded, , , usdRewarded) = _PUBLIC_SALE.accountInSeason(account, seasonNumber);
    }
}