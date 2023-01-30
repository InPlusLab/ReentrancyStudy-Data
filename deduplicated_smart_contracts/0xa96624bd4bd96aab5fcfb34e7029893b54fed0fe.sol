/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity ^0.5.8;


/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title interface for unsafe ERC20
 * @dev Unsafe ERC20 does not return when transfer, approve, transferFrom
 */
interface IUnsafeERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external;

  function approve(address spender, uint256 value) external;

  function transferFrom(address from, address to, uint256 value) external;
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}

/**
 * @title TokenSale
 */
contract TokenSale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // token for sale
    IERC20 public saleToken;

    // address where funds are collected
    address public fundCollector;

    // address where has tokens to sell
    address public tokenWallet;

    // use whitelist[user] to get whether the user was allowed to buy
    mapping(address => bool) public whitelist;

    // exchangeable token
    struct ExToken {
        bool safe;
        bool accepted;
        uint256 rate;
    }

    // exchangeable tokens
    mapping(address => ExToken) private _exTokens;

    // bonus threshold
    uint256 public bonusThreshold;

    // tier-1 bonus
    uint256 public tierOneBonusTime;
    uint256 public tierOneBonusRate;

    // tier-2 bonus
    uint256 public tierTwoBonusTime;
    uint256 public tierTwoBonusRate;

    /**
     * @param _setter who set USDT
     * @param _usdt address of USDT
     */
    event USDTSet(
        address indexed _setter,
        address indexed _usdt
    );

    /**
     * @param _setter who set fund collector
     * @param _fundCollector address of fund collector
     */
    event FundCollectorSet(
        address indexed _setter,
        address indexed _fundCollector
    );

    /**
     * @param _setter who set sale token
     * @param _saleToken address of sale token
     */
    event SaleTokenSet(
        address indexed _setter,
        address indexed _saleToken
    );

    /**
     * @param _setter who set token wallet
     * @param _tokenWallet address of token wallet
     */
    event TokenWalletSet(
        address indexed _setter,
        address indexed _tokenWallet
    );

    /**
     * @param _setter who set bonus threshold
     * @param _bonusThreshold exceed the threshold will get bonus
     * @param _tierOneBonusTime tier one bonus timestamp
     * @param _tierOneBonusRate tier one bonus rate
     * @param _tierTwoBonusTime tier two bonus timestamp
     * @param _tierTwoBonusRate tier two bonus rate
     */
    event BonusConditionsSet(
        address indexed _setter,
        uint256 _bonusThreshold,
        uint256 _tierOneBonusTime,
        uint256 _tierOneBonusRate,
        uint256 _tierTwoBonusTime,
        uint256 _tierTwoBonusRate
    );

    /**
     * @param _setter who set the whitelist
     * @param _user address of the user
     * @param _allowed whether the user allowed to buy
     */
    event WhitelistSet(
        address indexed _setter,
        address indexed _user,
        bool _allowed
    );

    /**
     * event for logging exchangeable token updates
     * @param _setter who set the exchangeable token
     * @param _exToken the exchangeable token
     * @param _safe whether the exchangeable token is a safe ERC20
     * @param _accepted whether the exchangeable token was accepted
     * @param _rate exchange rate of the exchangeable token
     */
    event ExTokenSet(
        address indexed _setter,
        address indexed _exToken,
        bool _safe,
        bool _accepted,
        uint256 _rate
    );

    /**
     * event for token purchase logging
     * @param _buyer address of token buyer
     * @param _exToken address of the exchangeable token
     * @param _exTokenAmount amount of the exchangeable tokens
     * @param _amount amount of tokens purchased
     */
    event TokensPurchased(
        address indexed _buyer,
        address indexed _exToken,
        uint256 _exTokenAmount,
        uint256 _amount
    );

    constructor (
        address _fundCollector,
        address _saleToken,
        address _tokenWallet,
        uint256 _bonusThreshold,
        uint256 _tierOneBonusTime,
        uint256 _tierOneBonusRate,
        uint256 _tierTwoBonusTime,
        uint256 _tierTwoBonusRate
    )
        public
    {
        _setFundCollector(_fundCollector);
        _setSaleToken(_saleToken);
        _setTokenWallet(_tokenWallet);
        _setBonusConditions(
            _bonusThreshold,
            _tierOneBonusTime,
            _tierOneBonusRate,
            _tierTwoBonusTime,
            _tierTwoBonusRate
        );

    }

    /**
     * @param _fundCollector address of the fund collector
     */
    function setFundCollector(address _fundCollector) external onlyOwner {
        _setFundCollector(_fundCollector);
    }

    /**
     * @param _fundCollector address of the fund collector
     */
    function _setFundCollector(address _fundCollector) private {
        require(_fundCollector != address(0), "fund collector cannot be 0x0");
        fundCollector = _fundCollector;
        emit FundCollectorSet(msg.sender, _fundCollector);
    }

    /**
     * @param _saleToken address of the sale token
     */
    function setSaleToken(address _saleToken) external onlyOwner {
        _setSaleToken(_saleToken);
    }

    /**
     * @param _saleToken address of the sale token
     */
    function _setSaleToken(address _saleToken) private {
        require(_saleToken != address(0), "sale token cannot be 0x0");
        saleToken = IERC20(_saleToken);
        emit SaleTokenSet(msg.sender, _saleToken);
    }

    /**
     * @param _tokenWallet address of the token wallet
     */
    function setTokenWallet(address _tokenWallet) external onlyOwner {
        _setTokenWallet(_tokenWallet);
    }

    /**
     * @param _tokenWallet address of the token wallet
     */
    function _setTokenWallet(address _tokenWallet) private {
        require(_tokenWallet != address(0), "token wallet cannot be 0x0");
        tokenWallet = _tokenWallet;
        emit TokenWalletSet(msg.sender, _tokenWallet);
    }

    /**
     * @param _bonusThreshold exceed the threshold will get bonus
     * @param _tierOneBonusTime before t1 bonus timestamp will use t1 bonus rate
     * @param _tierOneBonusRate tier-1 bonus rate
     * @param _tierTwoBonusTime before t2 bonus timestamp will use t2 bonus rate
     * @param _tierTwoBonusRate tier-2 bonus rate
     */
    function setBonusConditions(
        uint256 _bonusThreshold,
        uint256 _tierOneBonusTime,
        uint256 _tierOneBonusRate,
        uint256 _tierTwoBonusTime,
        uint256 _tierTwoBonusRate
    )
        external
        onlyOwner
    {
        _setBonusConditions(
            _bonusThreshold,
            _tierOneBonusTime,
            _tierOneBonusRate,
            _tierTwoBonusTime,
            _tierTwoBonusRate
        );
    }

    function _setBonusConditions(
        uint256 _bonusThreshold,
        uint256 _tierOneBonusTime,
        uint256 _tierOneBonusRate,
        uint256 _tierTwoBonusTime,
        uint256 _tierTwoBonusRate
    )
        private
        onlyOwner
    {
        require(_bonusThreshold > 0," threshold cannot be zero.");
        require(_tierOneBonusTime < _tierTwoBonusTime, "invalid bonus time");
        require(_tierOneBonusRate >= _tierTwoBonusRate, "invalid bonus rate");

        bonusThreshold = _bonusThreshold;
        tierOneBonusTime = _tierOneBonusTime;
        tierOneBonusRate = _tierOneBonusRate;
        tierTwoBonusTime = _tierTwoBonusTime;
        tierTwoBonusRate = _tierTwoBonusRate;

        emit BonusConditionsSet(
            msg.sender,
            _bonusThreshold,
            _tierOneBonusTime,
            _tierOneBonusRate,
            _tierTwoBonusTime,
            _tierTwoBonusRate
        );
    }

    /**
     * @notice set allowed to ture to add the user into the whitelist
     * @notice set allowed to false to remove the user from the whitelist
     * @param _user address of user
     * @param _allowed whether allow the user to deposit/withdraw or not
     */
    function setWhitelist(address _user, bool _allowed) external onlyOwner {
        whitelist[_user] = _allowed;
        emit WhitelistSet(msg.sender, _user, _allowed);
    }

    /**
     * @dev checks the amount of tokens left in the allowance.
     * @return amount of tokens left in the allowance
     */
    function remainingTokens() external view returns (uint256) {
        return Math.min(
            saleToken.balanceOf(tokenWallet),
            saleToken.allowance(tokenWallet, address(this))
        );
    }

    /**
     * @param _exToken address of the exchangeable token
     * @param _safe whether it is a safe ERC20
     * @param _accepted true: accepted; false: rejected
     * @param _rate exchange rate
     */
    function setExToken(
        address _exToken,
        bool _safe,
        bool _accepted,
        uint256 _rate
    )
        external
        onlyOwner
    {
        _exTokens[_exToken].safe = _safe;
        _exTokens[_exToken].accepted = _accepted;
        _exTokens[_exToken].rate = _rate;
        emit ExTokenSet(msg.sender, _exToken, _safe, _accepted, _rate);
    }

    /**
     * @param _exToken address of the exchangeable token
     * @return whether the exchangeable token is a safe ERC20
     */
    function safe(address _exToken) public view returns (bool) {
        return _exTokens[_exToken].safe;
    }

    /**
     * @param _exToken address of the exchangeable token
     * @return whether the exchangeable token is accepted or not
     */
    function accepted(address _exToken) public view returns (bool) {
        return _exTokens[_exToken].accepted;
    }

    /**
     * @param _exToken address of the exchangeale token
     * @return amount of sale token a buyer gets per exchangeable token
     */
    function rate(address _exToken) external view returns (uint256) {
        return _exTokens[_exToken].rate;
    }

    /**
     * @dev get exchangeable sale token amount
     * @param _exToken address of the exchangeable token
     * @param _amount amount of the exchangeable token (how much to pay)
     * @return purchased sale token amount
     */
    function exchangeableAmounts(
        address _exToken,
        uint256 _amount
    )
        external
        view
        returns (uint256)
    {
        return _getTokenAmount(_exToken, _amount);
    }

    /**
     * @dev buy tokens
     * @dev buyer must be in whitelist
     * @param _exToken address of the exchangeable token
     * @param _amount amount of the exchangeable token
     */
    function buyTokens(
        address _exToken,
        uint256 _amount
    )
        external
    {
        require(_exTokens[_exToken].accepted, "token was not accepted");
        require(_amount != 0, "amount cannot 0");
        require(whitelist[msg.sender], "buyer must be in whitelist");
        // calculate token amount to sell
        uint256 _tokens = _getTokenAmount(_exToken, _amount);
        require(_tokens >= 10**18, "at least buy 1 tokens per purchase");
        _forwardFunds(_exToken, _amount);
        _processPurchase(msg.sender, _tokens);
        emit TokensPurchased(msg.sender, _exToken, _amount, _tokens);
    }

    /**
     * @dev buyer transfers amount of the exchangeable token to fund collector
     * @param _exToken address of the exchangeable token
     * @param _amount amount of the exchangeable token will send to fund collector
     */
    function _forwardFunds(address _exToken, uint256 _amount) private {
        if (_exTokens[_exToken].safe) {
            IERC20(_exToken).safeTransferFrom(msg.sender, fundCollector, _amount);
        } else {
            IUnsafeERC20(_exToken).transferFrom(msg.sender, fundCollector, _amount);
        }
    }

    /**
     * @dev calculated purchased sale token amount
     * @param _exToken address of the exchangeable token
     * @param _amount amount of the exchangeable token (how much to pay)
     * @return amount of purchased sale token
     */
    function _getTokenAmount(
        address _exToken,
        uint256 _amount
    )
        private
        view
        returns (uint256)
    {
        // round down value (v) by multiple (m) = (v / m) * m
        uint256 _value = _amount
            .mul(_exTokens[_exToken].rate)
            .div(1000000000000000000)
            .mul(1000000000000000000);
        return _applyBonus(_value);
    }

    function _applyBonus(
        uint256 _amount
    )
        private
        view
        returns (uint256)
    {
        if (_amount < bonusThreshold) {
            return _amount;
        }

        if (block.timestamp <= tierOneBonusTime) {
            return _amount.mul(tierOneBonusRate).div(100);
        } else if (block.timestamp <= tierTwoBonusTime) {
            return _amount.mul(tierTwoBonusRate).div(100);
        } else {
            return _amount;
        }
    }

    /**
     * @dev transfer sale token amounts from token wallet to beneficiary
     * @param _beneficiary purchased tokens will transfer to this address
     * @param _tokenAmount purchased token amount
     */
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    )
        private
    {
        saleToken.safeTransferFrom(tokenWallet, _beneficiary, _tokenAmount);
    }
}