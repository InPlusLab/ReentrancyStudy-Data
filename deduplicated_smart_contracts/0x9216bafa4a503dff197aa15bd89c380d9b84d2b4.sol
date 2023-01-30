/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

// File: contracts\lib\ERC20Plus.sol

pragma solidity 0.5.9;

/**
 * @title ERC20 interface with additional functions
 * @dev it has added functions that deals to minting, pausing token and token information
 */
contract ERC20Plus {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    // additonal functions
    function mint(address _to, uint256 _amount) public returns (bool);
    function owner() public view returns (address);
    function transferOwnership(address newOwner) public;
    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function decimals() public view returns (uint8);
    function paused() public view returns (bool);
}

// File: contracts\lib\SafeMath.sol

pragma solidity ^0.5.9;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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
        require(c / a == b, 'SafeMul overflow!');

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, 'SafeDiv cannot divide by 0!');
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'SafeSub underflow!');
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeAdd overflow!');

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'SafeMod cannot compute modulo of 0!');
        return a % b;
    }
}

// File: contracts\lib\Ownable.sol

pragma solidity 0.5.9;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public _owner;

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
        require(isOwner(), "Only owner is able call this function!");
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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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

// File: contracts\lib\Crowdsale.sol

pragma solidity 0.5.9;

/**
 * @title Crowdsale - modified from zeppelin-solidity library
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // how many token units a buyer gets per wei

    // Note: using custom rate in Tokensale
    // uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;


    // event for token purchase logging
    // purchaser who paid for the tokens
    // beneficiary who got the tokens
    // value weis paid for purchase
    // amount amount of tokens purchased
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function initCrowdsale(uint256 _startTime, uint256 _endTime) public {
        require(
            startTime == 0 && endTime == 0,
            "Global variables must be empty when initializing crowdsale!"
        );
        require(_startTime >= now, "_startTime must be more than current time!");
        require(_endTime >= _startTime, "_endTime must be more than _startTime!");

        startTime = _startTime;
        endTime = _endTime;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        return now > endTime;
    }
}

// File: contracts\lib\FinalizableCrowdsale.sol

pragma solidity 0.5.9;





/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}

// File: contracts\lib\Pausable.sol

pragma solidity 0.5.9;



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "must not be paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "must be paused");
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        _paused = false;
        emit Unpause();
    }
}

// File: contracts\FundsSplitterInterface.sol

pragma solidity 0.5.9;

contract FundsSplitterInterface {
    function splitFunds() public payable;
    function splitStarFunds() public;
    function() external payable;
}

// File: contracts\StarEthRateInterface.sol

pragma solidity 0.5.9;

interface StarEthRateInterface {
    function decimalCorrectionFactor() external returns (uint256);
    function starEthRate() external returns (uint256);
}

// File: contracts\TokenSaleInterface.sol

pragma solidity 0.5.9;

/**
 * @title TokenSale contract interface
 */
interface TokenSaleInterface {
    function init
    (
        uint256 _startTime,
        uint256 _endTime,
        address[6] calldata _externalAddresses,
        uint256 _softCap,
        uint256 _crowdsaleCap,
        bool    _isWeiAccepted,
        bool    _isMinting,
        uint256[] calldata _targetRates,
        uint256[] calldata _targetRatesTimestamps
    )
    external;
}

// File: contracts\Whitelist.sol

pragma solidity 0.5.9;



/**
 * @title Whitelist - crowdsale whitelist contract
 * @author Gustavo Guimaraes - <gustavo@starbase.co>
 */
contract Whitelist is Ownable {
    mapping(address => bool) public allowedAddresses;

    event WhitelistUpdated(uint256 timestamp, string operation, address indexed member);

    /**
    * @dev Adds single address to whitelist.
    * @param _address Address to be added to the whitelist
    */
    function addToWhitelist(address _address) external onlyOwner {
        allowedAddresses[_address] = true;
        emit WhitelistUpdated(now, "Added", _address);
    }

    /**
     * @dev add various whitelist addresses
     * @param _addresses Array of ethereum addresses
     */
    function addManyToWhitelist(address[] calldata _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            allowedAddresses[_addresses[i]] = true;
            emit WhitelistUpdated(now, "Added", _addresses[i]);
        }
    }

    /**
     * @dev remove whitelist addresses
     * @param _addresses Array of ethereum addresses
     */
    function removeManyFromWhitelist(address[] memory _addresses) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            allowedAddresses[_addresses[i]] = false;
            emit WhitelistUpdated(now, "Removed", _addresses[i]);
        }
    }
}

// File: contracts\TokenSale.sol

pragma solidity 0.5.9;








/**
 * @title Token Sale contract - crowdsale of company tokens.
 * @author Gustavo Guimaraes - <gustavo@starbase.co>
 * @author Markus Waas - <markus@starbase.co>
 */
contract TokenSale is FinalizableCrowdsale, Pausable {
    uint256 public softCap;
    uint256 public crowdsaleCap;
    uint256 public tokensSold;

    // rate definitions
    uint256 public currentTargetRateIndex;
    uint256[] public targetRates;
    uint256[] public targetRatesTimestamps;

    // amount of raised money in STAR
    uint256 public starRaised;
    address public tokenOwnerAfterSale;
    bool public isWeiAccepted;
    bool public isMinting;
    bool private isInitialized;

    // external contracts
    Whitelist public whitelist;
    ERC20Plus public starToken;
    FundsSplitterInterface public wallet;
    StarEthRateInterface public starEthRateInterface;

    // The token being sold
    ERC20Plus public tokenOnSale;

    // Keep track of user investments
    mapping (address => uint256) public ethInvestments;
    mapping (address => uint256) public starInvestments;

    event TokenRateChanged(uint256 previousRate, uint256 newRate);
    event TokenStarRateChanged(uint256 previousStarRate, uint256 newStarRate);
    event TokenPurchaseWithStar(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
     * @dev initialization function
     * @param _startTime The timestamp of the beginning of the crowdsale
     * @param _endTime Timestamp when the crowdsale will finish
     * @param _externalAddresses Containing all external addresses, see below
     * #param _whitelist contract containing the whitelisted addresses
     * #param _starToken STAR token contract address
     * #param _companyToken ERC20 contract address that has minting capabilities
     * #param _tokenOwnerAfterSale Address that this TokenSale will pass the token ownership to after it's finished. Only works when TokenSale mints tokens, otherwise must be `0x0`.
     * #param _starEthRateInterface The StarEthRate contract address .
     * #param _wallet FundsSplitter wallet that redirects funds to client and Starbase.
     * @param _softCap Soft cap of the token sale
     * @param _crowdsaleCap Cap for the token sale
     * @param _isWeiAccepted Bool for acceptance of ether in token sale
     * @param _isMinting Bool that indicates whether token sale mints ERC20 tokens on sale or simply transfers them
     * @param _targetRates Array of target rates.
     * @param _targetRatesTimestamps Array of target rates timestamps.
     */
    function init(
        uint256 _startTime,
        uint256 _endTime,
        address[6] calldata _externalAddresses, // array avoids stack too deep error
        uint256 _softCap,
        uint256 _crowdsaleCap,
        bool    _isWeiAccepted,
        bool    _isMinting,
        uint256[] calldata _targetRates,
        uint256[] calldata _targetRatesTimestamps
    )
        external
    {
        require(!isInitialized, "Contract instance was initialized already!");
        isInitialized = true;

        require(
            _externalAddresses[0] != address(0) &&
            _externalAddresses[1] != address(0) &&
            _externalAddresses[2] != address(0) &&
            _externalAddresses[4] != address(0) &&
            _externalAddresses[5] != address(0) &&
            _crowdsaleCap != 0,
            "Parameter variables cannot be empty!"
        );

        require(
            _softCap < _crowdsaleCap,
            "SoftCap should be smaller than crowdsaleCap!"
        );

        currentTargetRateIndex = 0;
        initCrowdsale(_startTime, _endTime);
        tokenOnSale = ERC20Plus(_externalAddresses[2]);
        whitelist = Whitelist(_externalAddresses[0]);
        starToken = ERC20Plus(_externalAddresses[1]);
        wallet = FundsSplitterInterface(uint160(_externalAddresses[5]));
        tokenOwnerAfterSale = _externalAddresses[3];
        starEthRateInterface = StarEthRateInterface(_externalAddresses[4]);
        isWeiAccepted = _isWeiAccepted;
        isMinting = _isMinting;
        _owner = tx.origin;

        uint8 decimals = tokenOnSale.decimals();
        softCap = _softCap.mul(10 ** uint256(decimals));
        crowdsaleCap = _crowdsaleCap.mul(10 ** uint256(decimals));

        targetRates = _targetRates;
        targetRatesTimestamps = _targetRatesTimestamps;

        if (isMinting) {
            require(tokenOwnerAfterSale != address(0), "tokenOwnerAfterSale cannot be empty when minting tokens!");
            require(tokenOnSale.paused(), "Company token must be paused upon initialization!");
        } else {
            require(tokenOwnerAfterSale == address(0), "tokenOwnerAfterSale must be empty when minting tokens!");
        }

        verifyTargetRates();
    }

    modifier isWhitelisted(address beneficiary) {
        require(
            whitelist.allowedAddresses(beneficiary),
            "Beneficiary not whitelisted!"
        );

        _;
    }

    /**
     * @dev override fallback function. cannot use it
     */
    function () external payable {
        revert("No fallback function defined!");
    }

    /**
     * @dev function that allows token purchases with STAR or ETH
     * @param beneficiary Address of the purchaser
     */
    function buyTokens(address beneficiary)
        public
        payable
        whenNotPaused
        isWhitelisted(beneficiary)
    {
        require(beneficiary != address(0), "Purchaser address cant be zero!");
        require(validPurchase(), "TokenSale over or not yet started!");
        require(tokensSold < crowdsaleCap, "All tokens sold!");
        if (isMinting) {
            require(tokenOnSale.owner() == address(this), "The token owner must be contract address!");
        }

        checkForNewRateAndUpdate();

        if (!isWeiAccepted) {
            require(msg.value == 0, "Only purchases with STAR are allowed!");
        } else if (msg.value > 0) {
            buyTokensWithWei(beneficiary);
        }

        // beneficiary must allow TokenSale address to transfer star tokens on its behalf
        uint256 starAllocationToTokenSale
            = starToken.allowance(msg.sender, address(this));

        if (starAllocationToTokenSale > 0) {
            uint256 decimalCorrectionFactor =
                starEthRateInterface.decimalCorrectionFactor();
            uint256 starEthRate = starEthRateInterface.starEthRate();
            uint256 ethRate = targetRates[currentTargetRateIndex];

            // calculate token amount to be created
            uint256 decimals = uint256(tokenOnSale.decimals());
            uint256 tokens = (starAllocationToTokenSale
                .mul(ethRate)
                .mul(starEthRate))
                .mul(10 ** decimals) // token decimals count
                .div(decimalCorrectionFactor)
                .div(1e18); // STAR decimals count

            // remainder logic
            if (tokensSold.add(tokens) > crowdsaleCap) {
                tokens = crowdsaleCap.sub(tokensSold);

                starAllocationToTokenSale = tokens
                    .mul(1e18)
                    .mul(decimalCorrectionFactor)
                    .div(ethRate)
                    .div(starEthRate)
                    .div(10 ** decimals);
            }

            // update state
            starRaised = starRaised.add(starAllocationToTokenSale);
            starInvestments[beneficiary] = starInvestments[beneficiary].add(starAllocationToTokenSale);

            tokensSold = tokensSold.add(tokens);
            sendPurchasedTokens(beneficiary, tokens);
            emit TokenPurchaseWithStar(msg.sender, beneficiary, starAllocationToTokenSale, tokens);

            forwardsStarFunds(starAllocationToTokenSale);
        }
    }

    /**
     * @dev function that allows token purchases with Wei
     * @param beneficiary Address of the purchaser
     */
    function buyTokensWithWei(address beneficiary)
        internal
    {
        uint256 weiAmount = msg.value;
        uint256 weiRefund;

        uint256 ethRate = targetRates[currentTargetRateIndex];

        // calculate token amount to be created
        uint256 decimals = uint256(tokenOnSale.decimals());
        uint256 tokens = weiAmount
            .mul(ethRate)
            .mul(10 ** decimals) // token decimals count
            .div(1e18);  // ETH decimals count

        // remainder logic
        if (tokensSold.add(tokens) > crowdsaleCap) {
            tokens = crowdsaleCap.sub(tokensSold);
            weiAmount = tokens.mul(1e18).div(ethRate).div(10 ** decimals);

            weiRefund = msg.value.sub(weiAmount);
        }

        // update state
        weiRaised = weiRaised.add(weiAmount);
        ethInvestments[beneficiary]
            = ethInvestments[beneficiary].add(weiAmount);

        tokensSold = tokensSold.add(tokens);
        sendPurchasedTokens(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardsWeiFunds(weiRefund);
    }

    // isMinting checker -- it either mints ERC20 token or transfers them
    function sendPurchasedTokens(
        address _beneficiary,
        uint256 _tokens
    ) internal {
        if (isMinting) {
            tokenOnSale.mint(_beneficiary, _tokens);
        } else {
            tokenOnSale.transfer(_beneficiary, _tokens);
        }
    }

    // check for softCap achievement
    // @return true when softCap is reached
    function hasReachedSoftCap() public view returns (bool) {
        if (tokensSold >= softCap) return true;

        return false;
    }

    // override Crowdsale#hasEnded to add cap logic
    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        if (tokensSold >= crowdsaleCap) return true;

        return super.hasEnded();
    }

    /**
     * @dev override Crowdsale#validPurchase
     * @return true if the transaction can buy tokens
     */
    function validPurchase() internal view returns (bool) {
        return now >= startTime && now <= endTime;
    }

    /**
     * @dev forward wei funds
     */
    function forwardsWeiFunds(uint256 _weiRefund) internal {
        if (softCap == 0 || hasReachedSoftCap()) {
            if (_weiRefund > 0) msg.sender.transfer(_weiRefund);

            _forwardAnyFunds();
        }
    }

    /**
     * @dev forward star funds
     */
    function forwardsStarFunds(uint256 _value) internal {
        if (softCap > 0 && !hasReachedSoftCap()) {
            starToken.transferFrom(msg.sender, address(this), _value);
        } else {
            starToken.transferFrom(msg.sender, address(wallet), _value);

            _forwardAnyFunds();
        }
    }

    /**
     * @dev withdraw funds for failed sales
     */
    function withdrawUserFunds() public {
        require(hasEnded(), "Can only withdraw funds for ended sales!");
        require(
            !hasReachedSoftCap(),
            "Can only withdraw funds for sales that didn't reach soft cap!"
        );

        uint256 investedEthRefund = ethInvestments[msg.sender];
        uint256 investedStarRefund = starInvestments[msg.sender];

        require(
            investedEthRefund > 0 || investedStarRefund > 0,
            "You don't have any funds in the contract!"
        );

        // prevent reentrancy attack
        ethInvestments[msg.sender] = 0;
        starInvestments[msg.sender] = 0;

        if (investedEthRefund > 0) {
            msg.sender.transfer(investedEthRefund);
        }
        if (investedStarRefund > 0) {
            starToken.transfer(msg.sender, investedStarRefund);
        }
    }

    function verifyTargetRates() internal view {
        require(
            targetRates.length == targetRatesTimestamps.length,
            'Target rates and target rates timestamps lengths should match!'
        );

        require(targetRates.length > 0, 'Target rates cannot be empty!');
        require(
            targetRatesTimestamps[0] == startTime,
            'First target rate timestamp should match startTime!'
        );

        for (uint256 i = 0; i < targetRates.length; i++) {
            if (i > 0) {
                require(
                    targetRatesTimestamps[i-1] < targetRatesTimestamps[i],
                    'Target rates timestamps should be sorted from low to high!'
                );
            }

            if (i == targetRates.length - 1) {
               require(
                    targetRatesTimestamps[i] < endTime,
                    'All target rate timestamps should be before endTime!'
                );
            }

            require(targetRates[i] > 0, 'All target rates must be above 0!');
        }
    }

    /**
     * @dev Returns current rate and index for rate in targetRates array.
     * Does not update target rate index, use checkForNewRateAndUpdate() to
     * update,
     */
    function getCurrentRate() public view returns (uint256, uint256) {
        for (
            uint256 i = currentTargetRateIndex + 1;
            i < targetRatesTimestamps.length;
            i++
        ) {
            if (now < targetRatesTimestamps[i]) {
                return (targetRates[i - 1], i - 1);
            }
        }

        return (
            targetRates[targetRatesTimestamps.length - 1],
            targetRatesTimestamps.length - 1
        );
    }

    /**
     * @dev Check for new valid rate and update. Automatically called when
     * purchasing tokens.
     */
    function checkForNewRateAndUpdate() public {
        (, uint256 targetRateIndex) = getCurrentRate(); // ignore first value

        if (targetRateIndex > currentTargetRateIndex) {
            currentTargetRateIndex = targetRateIndex;
        }
    }

    /**
     * @dev finalizes crowdsale
     */
    function finalization() internal {
        uint256 remainingTokens = isMinting
            ? crowdsaleCap.sub(tokensSold)
            : tokenOnSale.balanceOf(address(this));

        if (remainingTokens > 0) {
            sendPurchasedTokens(address(wallet), remainingTokens);
        }
        if (isMinting) {
            tokenOnSale.transferOwnership(tokenOwnerAfterSale);
        }

        super.finalization();
    }

    /**
     * @dev Get whitelist address.
     * @return The whitelist address.
     */
    function getWhitelistAddress() external view returns (address) {
        return address(whitelist);
    }

    /**
     * @dev Get starToken address.
     * @return The starToken address.
     */
    function getStarTokenAddress() external view returns (address) {
        return address(starToken);
    }

    /**
     * @dev Get wallet address.
     * @return The wallet address.
     */
    function getWalletAddress() external view returns (address) {
        return address(wallet);
    }

    /**
     * @dev Get starEthRateInterface address.
     * @return The starEthRateInterface address.
     */
    function getStarEthRateInterfaceAddress() external view returns (address) {
        return address(starEthRateInterface);
    }

    /**
     * @dev Get tokenOnSale address.
     * @return The tokenOnSale address.
     */
    function getTokenOnSaleAddress() external view returns (address) {
        return address(tokenOnSale);
    }

    function _forwardAnyFunds() private {
        // when there is still balance left send to wallet contract
        uint256 ethBalance = address(this).balance;
        uint256 starBalance = starToken.balanceOf(address(this));

        if (ethBalance > 0) {
            address(wallet).transfer(ethBalance);
        }

        if (starBalance > 0) {
            starToken.transfer(address(wallet), starBalance);
        }

        uint256 ethBalanceWallet = address(wallet).balance;
        uint256 starBalanceWallet = starToken.balanceOf(address(wallet));

        if (ethBalanceWallet > 0) {
            wallet.splitFunds();
        }

        if (starBalanceWallet > 0) {
            wallet.splitStarFunds();
        }
    }
}