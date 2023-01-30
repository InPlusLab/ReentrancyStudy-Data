/**
 *Submitted for verification at Etherscan.io on 2019-09-04
*/

pragma solidity ^0.5.11;

// Voken panel
//
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   support@vision.network
//   support@voken.io


/**
 * @dev Uint256 wrappers over Solidity's arithmetic operations with added overflow checks.
 */
library SafeMath256 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


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
 * @dev Interface of Voken2.0
 */
interface IVoken2 {
    function totalSupply() external view returns (uint256);
    function whitelistingMode() external view returns (bool);
    function safeMode() external view returns (bool);
    function burningMode() external view returns (bool, uint16);
    function balanceOf(address account) external view returns (uint256);
    function reservedOf(address account) external view returns (uint256);
    function whitelisted(address account) external view returns (bool);
    function whitelistCounter() external view returns (uint256);
    function whitelistReferralsCount(address account) external view returns (uint256);
}


/**
 * @dev Interface of Voken shareholders
 */
interface VokenShareholders {
    function page() external view returns (uint256);
    function weis() external view returns (uint256);
    function vokens() external view returns (uint256);
    function shareholdersCounter(uint256 pageNumber) external view returns (uint256);
    function pageEther(uint256 pageNumber) external view returns (uint256);
    function pageEtherSum(uint256 pageNumber) external view returns (uint256);
    function pageVoken(uint256 pageNumber) external view returns (uint256);
    function pageVokenSum(uint256 pageNumber) external view returns (uint256);
    function pageEndingBlock(uint256 pageNumber) external view returns (uint256);
    function vokenHolding(address account, uint256 pageNumber) external view returns (uint256);
    function etherDividend(address account, uint256 pageNumber) external view returns (uint256 amount,
                                                                                       uint256 dividend,
                                                                                       uint256 remain);
    function reservedOf(address account) external view returns (uint256 reserved);
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
 * @title Voken Panel
 */
contract VokenPanel is Ownable {
    using SafeMath256 for uint256;

    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);
    VokenShareholders private _SHAREHOLDERS = VokenShareholders(0x7712F76D2A52141D44461CDbC8b660506DCAB752);
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

    function voken2() public view returns (uint256 totalSupply,
                                           uint256 whitelistCounter,
                                           bool whitelistingMode,
                                           bool safeMode,
                                           bool burningMode) {
        totalSupply = _VOKEN.totalSupply();

        whitelistCounter = _VOKEN.whitelistCounter();
        whitelistingMode = _VOKEN.whitelistingMode();
        safeMode = _VOKEN.safeMode();
        (burningMode,) = _VOKEN.burningMode();
    }


    function shareholders() public view returns (uint256 page,
                                                 uint256 weis,
                                                 uint256 vokens) {
        page = _SHAREHOLDERS.page();
        weis = _SHAREHOLDERS.weis();
        vokens = _SHAREHOLDERS.vokens();
    }

    function publicSaleStatus() public view returns (uint16 stage,
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

    function accountVoken2(address account) public view returns (bool whitelisted,
                                                                 uint256 whitelistReferralsCount,
                                                                 uint256 balance,
                                                                 uint256 reserved) {
        whitelisted = _VOKEN.whitelisted(account);
        whitelistReferralsCount = _VOKEN.whitelistReferralsCount(account);
        balance = _VOKEN.balanceOf(account);
        reserved = _VOKEN.reservedOf(account);
    }

    function pageShareholders(uint256 pageNumber) public view returns (uint256 weis,
                                                                       uint256 vokens,
                                                                       uint256 sumWeis,
                                                                       uint256 sumVokens,
                                                                       uint256 endingBlock) {
        if (pageNumber > 0) {
            weis = _SHAREHOLDERS.pageEther(pageNumber);
            vokens = _SHAREHOLDERS.pageVoken(pageNumber);
            sumWeis = _SHAREHOLDERS.pageEtherSum(pageNumber);
            sumVokens = _SHAREHOLDERS.pageVokenSum(pageNumber);
            endingBlock = _SHAREHOLDERS.pageEndingBlock(pageNumber);
        }
    }

    function accountShareholders(address account, uint256 pageNumber) public view returns (bool isShareholder,
                                                                                           uint256 proportion,
                                                                                           uint256 devidendWeis,
                                                                                           uint256 dividendWithdrawed,
                                                                                           uint256 dividendRemain) {
        uint256 __vokenHolding = _SHAREHOLDERS.vokenHolding(account, pageNumber);
        isShareholder = __vokenHolding > 0;

        uint256 __page = _SHAREHOLDERS.page();

        if (pageNumber > 0 && pageNumber < __page) {
            proportion = __vokenHolding.mul(100000000).div(_SHAREHOLDERS.pageVokenSum(pageNumber));

            (uint256 __devidendEthers, uint256 __dividendWithdrawed, uint256 __dividendRemain) = _SHAREHOLDERS.etherDividend(account, pageNumber);
            devidendWeis = devidendWeis.add(__devidendEthers);
            dividendWithdrawed = dividendWithdrawed.add(__dividendWithdrawed);
            dividendRemain = dividendRemain.add(__dividendRemain);
        }
    }

    function accountPublicSale(address account) public view returns (uint256 vokenIssued,
                                                                     uint256 vokenBonus,
                                                                     uint256 vokenReferral,
                                                                     uint256 vokenReferrals,
                                                                     uint256 weiRewarded,
                                                                     uint256 usdRewarded,
                                                                     uint256 reserved) {
        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , weiRewarded, , usdRewarded) = _PUBLIC_SALE.queryAccount(account);
        reserved = _PUBLIC_SALE.reservedOf(account);
    }

    function accountPublicSaleSeason(address account, uint16 seasonNumber) public view returns (uint256 vokenIssued,
                                                                                                uint256 vokenBonus,
                                                                                                uint256 vokenReferral,
                                                                                                uint256 vokenReferrals,
                                                                                                uint256 weiRewarded,
                                                                                                uint256 usdRewarded) {
        (vokenIssued, vokenBonus, vokenReferral, vokenReferrals, , , weiRewarded, , , usdRewarded) = _PUBLIC_SALE.accountInSeason(account, seasonNumber);
    }
}