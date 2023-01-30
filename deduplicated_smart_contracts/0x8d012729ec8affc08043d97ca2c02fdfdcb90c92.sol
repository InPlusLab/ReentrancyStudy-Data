/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface ITokenInterface {
    /** ERC20 **/
    function totalSupply() external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);

    /** VALUE, YFV, vUSD, vETH has minters **/
    function minters(address account) external view returns (bool);
    function mint(address _to, uint _amount) external;

    /** VALUE **/
    function cap() external returns (uint);
    function yfvLockedBalance() external returns (uint);
}

interface IFreeFromUpTo {
    function freeFromUpTo(address from, uint valueToken) external returns (uint freed);
}

contract GovVaultRewardAutoCompound {
    using SafeMath for uint;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI(uint8 _flag) {
        if ((_flag & 0x1) == 0) {
            _;
        } else {
            uint gasStart = gasleft();
            _;
            uint gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }

    ITokenInterface public valueToken = ITokenInterface(0x49E833337ECe7aFE375e44F4E3e8481029218E5c);

    address public govVault = address(0xceC03a960Ea678A2B6EA350fe0DbD1807B22D875);
    address public insuranceFund = address(0xb7b2Ea8A1198368f950834875047aA7294A2bDAa); // set to Governance Multisig at start
    address public exploitCompensationFund = address(0x0000000000000000000000000000000000000000); // to compensate who lost during the exploit on Nov 14 2020
    address public otherReserve = address(0x0000000000000000000000000000000000000000); // to reserve for future use

    uint public govVaultValuePerBlock = 0.2 ether;         // VALUE/block
    uint public insuranceFundValuePerBlock = 0;            // VALUE/block
    uint public exploitCompensationFundValuePerBlock = 0;  // VALUE/block
    uint public otherReserveValuePerBlock = 0;             // VALUE/block

    uint public lastRewardBlock;    // Last block number that reward distribution occurs.
    bool public minterPaused;       // if the minter is paused

    address public governance;

    event TransferToFund(address indexed fund, uint amount);

    constructor (ITokenInterface _valueToken, uint _govVaultValuePerBlock, uint _startBlock) public {
        if (address(_valueToken) != address(0)) valueToken = _valueToken;
        govVaultValuePerBlock = _govVaultValuePerBlock;
        lastRewardBlock = (block.number > _startBlock) ? block.number : _startBlock;
        governance = msg.sender;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "!governance");
        _;
    }

    function setGovernance(address _governance) external onlyGovernance {
        governance = _governance;
    }

    function setMinterPaused(bool _minterPaused) external onlyGovernance {
        minterPaused = _minterPaused;
    }

    function setGovVault(address _govVault) external onlyGovernance {
        govVault = _govVault;
    }

    function setInsuranceFund(address _insuranceFund) external onlyGovernance {
        insuranceFund = _insuranceFund;
    }

    function setExploitCompensationFund(address _exploitCompensationFund) external onlyGovernance {
        exploitCompensationFund = _exploitCompensationFund;
    }

    function setOtherReserve(address _otherReserve) external onlyGovernance {
        otherReserve = _otherReserve;
    }

    function setGovVaultValuePerBlock(uint _govVaultValuePerBlock) external onlyGovernance {
        require(_govVaultValuePerBlock <= 10 ether, "_govVaultValuePerBlock is insanely high");
        mintAndSendFund(uint8(0));
        govVaultValuePerBlock = _govVaultValuePerBlock;
    }

    function setInsuranceFundValuePerBlock(uint _insuranceFundValuePerBlock) external onlyGovernance {
        require(_insuranceFundValuePerBlock <= 1 ether, "_insuranceFundValuePerBlock is insanely high");
        mintAndSendFund(uint8(0));
        insuranceFundValuePerBlock = _insuranceFundValuePerBlock;
    }

    function setExploitCompensationFundValuePerBlock(uint _exploitCompensationFundValuePerBlock) external onlyGovernance {
        require(_exploitCompensationFundValuePerBlock <= 1 ether, "_exploitCompensationFundValuePerBlock is insanely high");
        mintAndSendFund(uint8(0));
        exploitCompensationFundValuePerBlock = _exploitCompensationFundValuePerBlock;
    }

    function setOtherReserveValuePerBlock(uint _otherReserveValuePerBlock) external onlyGovernance {
        require(_otherReserveValuePerBlock <= 1 ether, "_otherReserveValuePerBlock is insanely high");
        mintAndSendFund(uint8(0));
        otherReserveValuePerBlock = _otherReserveValuePerBlock;
    }

    function mintAndSendFund(uint8 _flag) public discountCHI(_flag) {
        if (minterPaused || lastRewardBlock >= block.number) {
            return;
        }
        uint numBlks = block.number.sub(lastRewardBlock);
        lastRewardBlock = block.number;
        if (govVaultValuePerBlock > 0) _safeValueMint(govVault, govVaultValuePerBlock.mul(numBlks));
        if (insuranceFundValuePerBlock > 0) _safeValueMint(insuranceFund, insuranceFundValuePerBlock.mul(numBlks));
        if (exploitCompensationFundValuePerBlock > 0) _safeValueMint(exploitCompensationFund, exploitCompensationFundValuePerBlock.mul(numBlks));
        if (otherReserveValuePerBlock > 0) _safeValueMint(otherReserve, otherReserveValuePerBlock.mul(numBlks));
    }

    // Safe valueToken mint, ensure it is never over cap and we are the current owner.
    function _safeValueMint(address _to, uint _amount) internal {
        if (valueToken.minters(address(this)) && _to != address(0)) {
            uint totalSupply = valueToken.totalSupply();
            uint realCap = valueToken.cap().add(valueToken.yfvLockedBalance());
            if (totalSupply.add(_amount) > realCap) {
                _amount = realCap.sub(totalSupply);
            }
            valueToken.mint(_to, _amount);
            emit TransferToFund(_to, _amount);
        }
    }

    /**
     * This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
     * There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
     */
    function governanceRecoverUnsupported(ITokenInterface _token, uint _amount, address _to) external onlyGovernance {
        _token.transfer(_to, _amount);
    }
}