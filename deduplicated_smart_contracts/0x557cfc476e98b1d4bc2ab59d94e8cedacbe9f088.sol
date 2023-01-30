/**
 *Submitted for verification at Etherscan.io on 2019-10-15
*/

pragma solidity ^0.5.12;

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

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

contract minterests is Ownable, ReentrancyGuard {

  using SafeMath for uint256;

  /**
    * @dev Represents the balance of a given user. The 'previous' field is used to store the
    *      balance of the previous month in order to ponderate the bond's held time when updating
    *      interests.
    */
  struct Balance {
    // Total number of tokens held last month.
    uint256 previousBalance;
    // Total number of tokens held atm.
    uint256 currentBalance;
    // Total number of months these tokens have been held as of last month.
    uint256 previousHolding;
    // Total number of months these tokens have been held atm.
    uint256 currentHolding;
    // How much tokens has been bought through referral.
    uint256 refereeBalance;
  }

  /**
    * @dev Represents the claiming informations of an investor :
    *      Whether he is claiming and in which currency he whishes to get paid.
    */
  struct Claiming {
    // Tells wether investor is claiming its interests or not.
    bool claiming;
    // The currency type to be delivered, Euro or Ether.
    bytes32 currency;
    // The name of the bond partition to be redeemed.
    bytes32 partitionNameInHex;
  }

  /**
    * @dev Represents all about an investor.
    */
  struct Info {
    // Calculated according to the balance, the held time, and the token type.
    // It needs to be multiplied by 10 to get the € value.
    uint256 balanceInterests;
    // User status about his willing to claim its interests.
    Claiming claimingInterests;
    // User status about his willing to redeem its midterm or longterm bonds.
    Claiming claimingBonds;
    // Total of midterm bond tokens.
    Balance mid;
    // Total of longterm bond tokens.
    Balance lng;
    // Total of perpetual bond tokens.
    Balance per;
  }
  // The state of each investor.
  mapping (address => Info) investors;

  // A list of "superuser" that have control over a few methods of this contract,
  // not a controller as in ERC1400. Used to allow third-parties to update an investor's
  // infos.
  mapping (address => bool) _isInterestsController;

  // To what extent an interest unit can be divided (10^18).
  uint256 DECIMALS = 1000000000000000000;


  /**************************** MWT_interests events ********************************/

  // Emitted when an investor invested through a referal link.
  event Refered (
    address indexed referer,
    address indexed referee,
    uint256 midAmount,
    uint256 lngAmount,
    uint256 perAmount
  );

  // Emitted when the balance of an investor which invested through
  // a referal link is updated.
  event ModifiedReferee (
    address indexed investor,
    uint256 midAmount,
    uint256 lngAmount,
    uint256 perAmount
  );

  // Emitted when an investor's interests balance is modified.
  event UpdatedInterests (
    address indexed investor,
    uint256 interests
  );

  // Special case when a controller directly modified an investor's
  // interests balance.
  event ModifiedInterests (
    address indexed investor,
    uint256 value
  );

  // Emitted when an "interest controller" is addded or removed.
  event ModifiedInterestsController (
    address indexed controller,
    bool value
  );

  // Emitted when the claiming state of the investor is modified.
  event ModifiedClaimingInterests (
    address indexed investor,
    bool claiming,
    bytes32 currency
  );

  // Emitted when an user's interests are to be paid in euros by
  // the third party.
  event WillBePaidInterests (
    address indexed investor,
    uint256 balanceInterests
  );

  // Emitted when the bonds claiming status of an investor changed.
  event ModifiedClaimingBonds (
    address indexed investor,
    bool claiming,
    bytes32 currency,
    bytes32 partitionNameInHex
  );

  // Emitted when an user's bonds are to be paid in euros by
  // the third party.
  event WillBePaidBonds (
    address indexed investor,
    bytes32 partitionNameInHex,
    uint256 claimedAmount
  );

  // Emitted when the number of months an investor has been holding
  // each bond is modified. It's modified when a month has passed,
  // when the bonds are redeemed, or when set ad hoc by the contract
  // owner.
  event ModifiedHoldings (
    address indexed investor,
    uint256 midHolding,
    uint256 lngHolding,
    uint256 perHolding
  );

  // Emitted when an user redeems more bonds that we know he got. This
  // seems sneaky, and actually it is : the bonds balance is on another
  // contract (ERC1400) and we know about the actual balance of the
  // investor when we call `updateInterests`, once each month...
  event ModifiedHoldingsAndBalanceError (
    address indexed investor,
    bytes32 partitionNameInHex,
    uint256 holding,
    uint256 balance
  );

  // Emitted when an investor's interests balance is modified. It's
  // modified when one month has passed, when bonds are redeemed, or
  // when the balance is set ad hoc by the contract owner.
  event ModifiedBalances (
    address indexed investor,
    uint256 midBalance,
    uint256 lngBalance,
    uint256 perBalance
  );


  /**************************** MWT_interests getters ********************************/

  /**
    * @dev Get the interests balance of an investor.
    */
  function interestsOf (address investor) external view returns (uint256) {
    return (investors[investor].balanceInterests);
  }

  /**
    * @dev Check whether an address is an "interest controller" (a third-party superuser).
    */
  function isInterestsController (address _address) external view returns (bool) {
    return (_isInterestsController[_address]);
  }

  /**
    * @dev Check whether an investor is currently claiming its interests, and in which currency.
    */
  function isClaimingInterests (address investor) external view returns (bool, bytes32) {
    return (investors[investor].claimingInterests.claiming, investors[investor].claimingInterests.currency);
  }

  /**
    * @dev Check whether an investor is currently claiming its bonds, which one(s), and in which currency.
    */
  function isClaimingBonds (address investor) external view returns (bool, bytes32, bytes32) {
    return (
      investors[investor].claimingBonds.claiming,
      investors[investor].claimingBonds.currency,
      investors[investor].claimingBonds.partitionNameInHex
    );
  }

  /**
    * @dev Get the midterm bond infos of an investor.
    */
  function midtermBondInfosOf (address investor) external view returns (
    uint256,
    uint256,
    uint256
  ) {
    return (
      investors[investor].mid.currentBalance,
      investors[investor].mid.currentHolding,
      investors[investor].mid.refereeBalance
    );
  }

  /**
    * @dev Get the longterm bond infos of an investor.
    */
  function longtermBondInfosOf (address investor) external view returns (
    uint256,
    uint256,
    uint256
  ) {
    return (
      investors[investor].lng.currentBalance,
      investors[investor].lng.currentHolding,
      investors[investor].lng.refereeBalance
    );
  }

  /**
    * @dev Get the perpetual bond infos of an investor.
    */
  function perpetualBondInfosOf (address investor) external view returns (
    uint256,
    uint256,
    uint256
  ) {
    return (
      investors[investor].per.currentBalance,
      investors[investor].per.currentHolding,
      investors[investor].per.refereeBalance
    );
  }



  /**************************** MWT_interests external functions ********************************/

  /**
    * @dev Allows an investor to express his desire to redeem his interests.
    */
  function claimInterests (bool claiming, bytes32 _currency) external {
    bytes32 currency = _currency;
    require (currency == "eur" || currency == "eth", "A8"); // Transfer Blocked - Token restriction
    uint256 minimum = currency == "eth" ? 10 : 100; // ie: 100 euros

    require (investors[msg.sender].balanceInterests >= minimum.mul(DECIMALS), "A6"); // Transfer Blocked - Receiver not eligible
    if (!claiming) {
      currency = "";
    }

    investors[msg.sender].claimingInterests.claiming = claiming;
    investors[msg.sender].claimingInterests.currency = currency;

    emit ModifiedClaimingInterests (msg.sender, claiming, currency);
  }

  /**
    * @dev This function updates interests balance for several investors, so that they can be paid by the third party.
    */
  function payInterests (address[] calldata investorsAddresses) external nonReentrant {
    require (_isInterestsController[msg.sender], "A5"); // Your are not allowed to perform this action

    for (uint i = 0; i < investorsAddresses.length; i++) {
      require (investors[investorsAddresses[i]].claimingInterests.claiming, "A6"); // This investor is not currently claiming

      investors[investorsAddresses[i]].claimingInterests.claiming = false;
      investors[investorsAddresses[i]].claimingInterests.currency = "";

      emit ModifiedClaimingInterests(investorsAddresses[i], false, "");
      emit WillBePaidInterests(investorsAddresses[i], investors[investorsAddresses[i]].balanceInterests);
      investors[investorsAddresses[i]].balanceInterests = 0;
      emit UpdatedInterests(investorsAddresses[i], investors[investorsAddresses[i]].balanceInterests);
    }
  }

  /**
    * @dev Allows an investor to claim one of its bonds.
    */
  function claimBond (bool claiming, bytes32 _currency, bytes32 partition) external {
    uint256 bondYear = 0;
    uint256 bondMonth = 0;
    bytes32 currency = _currency;

    require (currency == "eur" || currency == "eth", "A8"); // Transfer Blocked - Token restriction
    // This function is only for midterm and longterm bonds, which have a restricted period
    // before they can be withdrawn.
    // We use 3 utf8 characters in each partition to identify it ("mid" for the midterm ones and "lng" for the longterm
    // ones).
    require ((partition[0] == "m" && partition[1] == "i" && partition[2] == "d")
              || (partition[0] == "l" && partition[1] == "n" && partition[2] == "g"), "A6");

    // Retrieving the bond issuance date (YYYYMM) from an UTF8 encoded string.
    for (uint i = 4; i < 10; i++) {
      // Is it a valid UTF8 digit ? https://www.utf8-chartable.de/unicode-utf8-table.pl
      require ((uint8(partition[i]) >= 48) && (uint8(partition[i]) <= 57), "A6"); // Transfer Blocked - Receiver not eligible
    }

    // The first digit is the millenium.
    bondYear = bondYear.add(uint256(uint8(partition[4])).sub(48).mul(1000));
    // The second one is the century.
    bondYear = bondYear.add(uint256(uint8(partition[5])).sub(48).mul(100));
    // The third one is the <is there a name for a ten year period ?>.
    bondYear = bondYear.add(uint256(uint8(partition[6])).sub(48).mul(10));
    // The fourth one is the year unit.
    bondYear = bondYear.add(uint256(uint8(partition[7])).sub(48));
    // Same for month, but it has only two digits.
    bondMonth = bondMonth.add(uint256(uint8(partition[8])).sub(48).mul(10));
    bondMonth = bondMonth.add(uint256(uint8(partition[9])).sub(48));

    // Did the boutique decoding fucked up ? :-)
    require (bondYear >= 2000);
    require (bondMonth >= 0 && bondMonth <= 12);

    // Calculating the elapsed time since bond issuance
    uint256 elapsedMonths = (bondYear * 12 + bondMonth) - 23640;
    uint256 currentTime;
    assembly {
      currentTime := timestamp()
    }

    // conversion of the current time (in sec) since epoch to months
    uint256 currentMonth = currentTime / 2630016;
    uint256 deltaMonths = currentMonth - elapsedMonths;

    if (partition[0] == "m" && partition[1] == "i" && partition[2] == "d") {
      // This is a midterm bond, 5 years (60 months) should have passed.
      require (deltaMonths >= 60, "A6"); // Transfer Blocked - Receiver not eligible
    } else if (partition[0] == "l" && partition[1] == "n" && partition[2] == "g") {
      // This is a longterm bond, 10 years (120 months) should have passed.
      require (deltaMonths >= 120, "A6"); // Transfer Blocked - Receiver not eligible
    } else {
      // This is __not__ possible !
      assert (false);
    }

    investors[msg.sender].claimingBonds.claiming = claiming;
    investors[msg.sender].claimingBonds.currency = claiming ? currency : bytes32("");
    investors[msg.sender].claimingBonds.partitionNameInHex = claiming ? partition : bytes32("");

    emit ModifiedClaimingBonds(
      msg.sender,
      claiming,
      investors[msg.sender].claimingBonds.currency,
      investors[msg.sender].claimingBonds.partitionNameInHex
    );
  }

  /**
    * @dev This functions is called after the investor expressed its desire to redeem its bonds using the above
    *      function (claimBonds). It needs to be called __before__ the third party pays the investor its bonds
    *      in fiat.
    *
    * @param claimedAmount The balance of the investor on the redeemed partition.
    */
  function payBonds (address investor, uint256 claimedAmount) external nonReentrant {
    require (_isInterestsController[msg.sender], "A5"); // You are not allowed to perform this action
    require (investors[investor].claimingBonds.claiming, "A6"); // This investor is not currently claiming
    investors[investor].claimingBonds.claiming = false;

    // This function is only for midterm and longterm bonds, which have a restricted period
    // before they can be withdrawn.
    // We use 3 utf8 characters in each partition to identify it ("mid" for the midterm ones and "lng" for the longterm
    // ones).
    bytes32 partition = investors[investor].claimingBonds.partitionNameInHex;
    require ((partition[0] == "m" && partition[1] == "i" && partition[2] == "d")
              || (partition[0] == "l" && partition[1] == "n" && partition[2] == "g"), "A6");

    // If all balances of a partition type are empty, we need to reset the "holding" variable.
    uint256 midLeft = 0;
    uint256 lngLeft = 0;
    bool emitHoldingEvent = false;
    if (partition[0] == "m" && partition[1] == "i" && partition[2] == "d") {
      // For the midterm bonds.
      if (claimedAmount < investors[investor].mid.currentBalance) {
        // All partitions of this type are not empty, no need to update holding.
        midLeft = investors[investor].mid.currentBalance.sub(claimedAmount);
      } else if (claimedAmount == investors[investor].mid.currentBalance) {
        // The investor just withdrew all bonds from all partitions of this type.
        // There is a possibility that an investor could refill the __exact same__ amount of the
        // __same partition type__ before we update the interests, i.e. before the end of the month.
        // Example: let's be an investor with the foolowing balances.
        // mid_201001 = 200, mid_201801 = 200, currentBalance = mid_201001 + mid_201801 = 400
        // If this investor refills mid_201801 with 200, then mid_201801 = 400 = currentBalance.
        // In that case, holding would be reseted whereas the investor still has 200 mid_201001
        // Since this case should be extremly rare, we do not emit an error event.
        investors[investor].mid.previousHolding = 0;
        investors[investor].mid.currentHolding = 0;
        emitHoldingEvent = true;
      } else {
        // This case should normally not occur.
        // If the current holding is not up to date regarding token balances, it means that the
        // investor refilled its balance after claiming bonds but before we update the interests.
        // This period lasts at most one month.
        // We reset holding and balance too (which could mess up adjustmentRate), but we emit an event.
        emit ModifiedHoldingsAndBalanceError(
          investor,
          investors[investor].claimingBonds.partitionNameInHex,
          investors[investor].mid.currentHolding,
          investors[investor].mid.currentBalance
        );
        investors[investor].mid.previousHolding = 0;
        investors[investor].mid.currentHolding = 0;
        emitHoldingEvent = true;
      }
      // There are some units left only if the investor had other partitions of the same type.
      investors[investor].mid.previousBalance = midLeft;
      investors[investor].mid.currentBalance = midLeft;
    } else if (partition[0] == "l" && partition[1] == "n" && partition[2] == "g") {
      if (claimedAmount < investors[investor].lng.currentBalance) {
        // All partitions of this type are not empty, no need to update holding.
        lngLeft = investors[investor].lng.currentBalance.sub(claimedAmount);
      } else if (claimedAmount == investors[investor].lng.currentBalance) {
        // Same as in the precedent branch, but with longterm bonds.
        investors[investor].lng.previousHolding = 0;
        investors[investor].lng.currentHolding = 0;
        emitHoldingEvent = true;
      } else {
        // See above for the details of this sneaky case..
        emit ModifiedHoldingsAndBalanceError(
          investor,
          investors[investor].claimingBonds.partitionNameInHex,
          investors[investor].lng.currentHolding,
          investors[investor].lng.currentBalance
        );
        investors[investor].lng.previousHolding = 0;
        investors[investor].lng.currentHolding = 0;
        emitHoldingEvent = true;
      }
      // There are some units left only if the investor had other partitions of the same type.
      investors[investor].lng.previousBalance = lngLeft;
      investors[investor].lng.currentBalance = lngLeft;
    } else {
      // We should __not__ get here !
      assert (false);
    }

    emit WillBePaidBonds(
      investor,
      partition,
      claimedAmount
    );

    investors[investor].claimingBonds.currency = "";
    investors[investor].claimingBonds.partitionNameInHex = "";
    emit ModifiedClaimingBonds(
      investor,
      false,
      investors[investor].claimingBonds.currency,
      investors[investor].claimingBonds.partitionNameInHex
    );

    if (emitHoldingEvent) {
      emit ModifiedHoldings(
        investor,
        investors[investor].mid.currentHolding,
        investors[investor].lng.currentHolding,
        investors[investor].per.currentHolding
      );
    }

    emit ModifiedBalances(
      investor,
      investors[investor].mid.currentBalance,
      investors[investor].lng.currentBalance,
      investors[investor].per.currentBalance
    );

  }

  /**
    * @dev Set how much time an investor has been holding each bond.
    */
  function setHoldings (address investor, uint256 midHolding, uint256 lngHolding, uint256 perHolding) external onlyOwner {
    investors[investor].mid.previousHolding = midHolding;
    investors[investor].mid.currentHolding = midHolding;
    investors[investor].lng.previousHolding = lngHolding;
    investors[investor].lng.currentHolding = lngHolding;
    investors[investor].per.previousHolding = perHolding;
    investors[investor].per.currentHolding = perHolding;

    emit ModifiedHoldings(investor, midHolding, lngHolding, perHolding);
  }

  /**
    * @dev Set custom balances for an investor.
    */
  function setBalances (address investor, uint256 midBalance, uint256 lngBalance, uint256 perBalance) external onlyOwner {
    investors[investor].mid.previousBalance = midBalance;
    investors[investor].mid.currentBalance = midBalance;
    investors[investor].lng.previousBalance = lngBalance;
    investors[investor].lng.currentBalance = lngBalance;
    investors[investor].per.previousBalance = perBalance;
    investors[investor].per.currentBalance = perBalance;

    emit ModifiedBalances(investor, midBalance, lngBalance, perBalance);
  }

  /**
    * @dev Set the interests balance of an investor.
    */
  function setInterests (address investor, uint256 value) external onlyOwner {
    investors[investor].balanceInterests = value;

    emit ModifiedInterests(investor, value);
    emit UpdatedInterests(investor, investors[investor].balanceInterests);
  }

  /**
    * @dev Add or remove an address from the InterestsController mapping.
    */
  function setInterestsController (address controller, bool value) external onlyOwner {
    _isInterestsController[controller] = value;

    emit ModifiedInterestsController(controller, value);
  }

  /**
    * @dev Increases the referer interests balance of a given amount.
    *
    * @param referer The address of the referal initiator
    * @param referee The address of the referal consumer
    * @param percent The percentage of interests earned by the referer
    * @param midAmount How many mid term bonds the referee bought through this referal
    * @param lngAmount How many long term bonds the referee bought through this referal
    * @param perAmount How many perpetual tokens the referee bought through this referal
    */
  function updateReferralInfos (
    address referer,
    address referee,
    uint256 percent,
    uint256 midAmount,
    uint256 lngAmount,
    uint256 perAmount
  ) external onlyOwner {
    // Referee and/or referer address(es) is(/are) not valid.
    require (referer != referee && referer != address(0) && referee != address(0), "A7");
    // The given percent parameter is not a valid percentage.
    require (percent >= 1 && percent <= 100, "A8");

    // Updates referer interests balance accounting for the referee investment
    investors[referer].balanceInterests = investors[referer].balanceInterests.add(midAmount.mul(percent).div(100));
    investors[referer].balanceInterests = investors[referer].balanceInterests.add(lngAmount.mul(percent).div(100));
    investors[referer].balanceInterests = investors[referer].balanceInterests.add(perAmount.mul(percent).div(100));
    emit UpdatedInterests(referer, investors[referer].balanceInterests);

    investors[referee].mid.refereeBalance = investors[referee].mid.refereeBalance.add(midAmount);
    investors[referee].lng.refereeBalance = investors[referee].lng.refereeBalance.add(lngAmount);
    investors[referee].per.refereeBalance = investors[referee].per.refereeBalance.add(perAmount);
    emit ModifiedReferee(
      referee,
      investors[referee].mid.refereeBalance,
      investors[referee].lng.refereeBalance,
      investors[referee].per.refereeBalance
    );
    emit Refered(referer, referee, midAmount, lngAmount, perAmount);
  }

  /**
    * @dev Set the referee balance of an investor.
    *
    * @param investor The address of the investor whose balance has to be modified
    * @param midAmount How many mid term bonds the referee bought through referal
    * @param lngAmount How many long term bonds the referee bought through referal
    * @param perAmount How many perpetual tokens the referee bought through referal
    */
  function setRefereeAmount (
    address investor,
    uint256 midAmount,
    uint256 lngAmount,
    uint256 perAmount
  ) external onlyOwner {
    investors[investor].mid.refereeBalance = midAmount;
    investors[investor].lng.refereeBalance = lngAmount;
    investors[investor].per.refereeBalance = perAmount;
    emit ModifiedReferee(investor, midAmount, lngAmount, perAmount);
  }

  /**
    * @dev Updates an investor's investment state. Will be called each month.
    *
    * @param investor The address of the investor for which to update interests
    * @param midBalance Balance of mid term bond
    * @param lngBalance Balance of long term bond
    * @param perBalance Balance of perpetual token
    */
  function updateInterests (address investor, uint256 midBalance, uint256 lngBalance, uint256 perBalance) external onlyOwner {
    // Investor's balance in each bond may have changed since last month
    investors[investor].mid.currentBalance = midBalance;
    investors[investor].lng.currentBalance = lngBalance;
    investors[investor].per.currentBalance = perBalance;

    // Adjusts investor's referee balance
    bool adjustedReferee = false;
    if (investors[investor].mid.refereeBalance > investors[investor].mid.currentBalance) {
      investors[investor].mid.refereeBalance = investors[investor].mid.currentBalance;
      adjustedReferee = true;
    }
    if (investors[investor].lng.refereeBalance > investors[investor].lng.currentBalance) {
      investors[investor].lng.refereeBalance = investors[investor].lng.currentBalance;
      adjustedReferee = true;
    }
    if (investors[investor].per.refereeBalance > investors[investor].per.currentBalance) {
      investors[investor].per.refereeBalance = investors[investor].per.currentBalance;
      adjustedReferee = true;
    }
    if (adjustedReferee) {
      emit ModifiedReferee(
        investor,
        investors[investor].mid.refereeBalance,
        investors[investor].lng.refereeBalance,
        investors[investor].per.refereeBalance
      );
    }

    // Increment the hodling counter : we pass to the next month. The hodling (in months) has to be adjusted
    // if the longterm or perpetual bonds balance has increased, for the midterm the interests are fixed so we
    // can, for one, keep it simple :-).
    if (investors[investor].mid.currentBalance > 0) {
        investors[investor].mid.currentHolding = investors[investor].mid.currentHolding.add(DECIMALS);
    }
    if (investors[investor].lng.currentBalance > 0) {
        if (investors[investor].lng.currentBalance > investors[investor].lng.previousBalance
            && investors[investor].lng.previousBalance > 0) {
            uint256 adjustmentRate = (((investors[investor].lng.currentBalance
                                        .sub(investors[investor].lng.previousBalance))
                                        .mul(DECIMALS))
                                        .div(investors[investor].lng.currentBalance));
            investors[investor].lng.currentHolding = (((DECIMALS
                                                        .sub(adjustmentRate))
                                                        .mul(investors[investor].lng.previousHolding
                                                             .add(DECIMALS)))
                                                        .div(DECIMALS));
        }
        else {
            investors[investor].lng.currentHolding = investors[investor].lng.currentHolding.add(DECIMALS);
        }
    }
    if (investors[investor].per.currentBalance > 0) {
        if (investors[investor].per.currentBalance > investors[investor].per.previousBalance
            && investors[investor].per.previousBalance > 0) {
            uint256 adjustmentRate = (((investors[investor].per.currentBalance
                                        .sub(investors[investor].per.previousBalance))
                                        .mul(DECIMALS))
                                        .div(investors[investor].per.currentBalance));
            investors[investor].per.currentHolding = (((DECIMALS.sub(adjustmentRate))
                                                        .mul(investors[investor].per.previousHolding
                                                             .add(DECIMALS)))
                                                        .div(DECIMALS));
        }
        else {
            investors[investor].per.currentHolding = investors[investor].per.currentHolding.add(DECIMALS);
        }
    }

    // We emit ModifiedHoldings later

    _minterest(investor);

    // We pass to the next month, hence the previous month is now the current one :D
    investors[investor].mid.previousHolding = investors[investor].mid.currentHolding;
    investors[investor].lng.previousHolding = investors[investor].lng.currentHolding;
    investors[investor].per.previousHolding = investors[investor].per.currentHolding;

    // Same thing for balances
    investors[investor].mid.previousBalance = investors[investor].mid.currentBalance;
    investors[investor].lng.previousBalance = investors[investor].lng.currentBalance;
    investors[investor].per.previousBalance = investors[investor].per.currentBalance;

    emit ModifiedBalances(
      investor,
      investors[investor].mid.currentBalance,
      investors[investor].lng.currentBalance,
      investors[investor].per.currentBalance
    );

    // If the balance of a partition is empty, we need to reset the corresponding "holding" variable
    if (investors[investor].per.currentBalance == 0) {
      investors[investor].per.previousHolding = 0;
      investors[investor].per.currentHolding = 0;
    }
    if (investors[investor].mid.currentBalance == 0) {
      investors[investor].mid.previousHolding = 0;
      investors[investor].mid.currentHolding = 0;
    }
    if (investors[investor].lng.currentBalance == 0) {
      investors[investor].lng.previousHolding = 0;
      investors[investor].lng.currentHolding = 0;
    }

    emit ModifiedHoldings(
      investor,
      investors[investor].mid.currentHolding,
      investors[investor].lng.currentHolding,
      investors[investor].per.currentHolding
    );

    emit UpdatedInterests(investor, investors[investor].balanceInterests);
  }



  /******************** MWT_interests internal functions ************************/

  /**
    *  @dev Calculates the investor's total interests given how many tokens he holds, their type, and
    *       for how long he's been holding them.
    *       For midterm bonds tokens, the interest rate is constant. For longterm and perpetual bonds tokens
    *       rates are given by a table designed by the token issuer (Montessori Worldwide) which is
    *       translated in Solidity as a set of conditions.
    */
  function _minterest (address investor) internal {
    // The interests rates are multiplied by 10^4 to both use integers and have a 10^-4 percent precision
    uint256 rateFactor = 10000; // 10^4

    // Bonus to referee interest rates are multiplied by 100 to keep 10^-2 precision
    uint256 bonusFactor = 100;

    // midRate represents the interest rate of the user's midterm bonds
    uint256 midRate = 575;

    // lngRate represents the interest rate of the user's midterm bonds
    uint256 lngRate = 0;
    if (investors[investor].lng.currentBalance > 0) {
      if (investors[investor].lng.currentHolding < DECIMALS.mul(12)) {
        if (investors[investor].lng.currentBalance < DECIMALS.mul(800)) {
          lngRate = 700;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(2400)) {
          lngRate = 730;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(7200)) {
          lngRate = 749;
        }
        else {
          lngRate = 760;
        }
      }
      else if (investors[investor].lng.currentHolding < DECIMALS.mul(36)) {
        if (investors[investor].lng.currentBalance < DECIMALS.mul(800)) {
          lngRate = 730;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(2400)) {
          lngRate = 745;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(7200)) {
          lngRate = 756;
        }
        else {
          lngRate = 764;
        }
      }
      else if (investors[investor].lng.currentHolding < DECIMALS.mul(72)) {
        if (investors[investor].lng.currentBalance < DECIMALS.mul(800)) {
          lngRate = 749;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(2400)) {
          lngRate = 757;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(7200)) {
          lngRate = 763;
        }
        else {
          lngRate = 767;
        }
      }
      else if (investors[investor].lng.currentHolding >= DECIMALS.mul(72)) {
        if (investors[investor].lng.currentBalance < DECIMALS.mul(800)) {
          lngRate = 760;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(2400)) {
          lngRate = 764;
        }
        else if (investors[investor].lng.currentBalance < DECIMALS.mul(7200)) {
          lngRate = 767;
        }
        else if (investors[investor].lng.currentBalance >= DECIMALS.mul(7200)) {
          lngRate = 770;
        }
      }
      assert (lngRate != 0);
    }

    // perRate represents the interest rate of the user's midterm bonds
    uint256 perRate = 0;
    if (investors[investor].per.currentBalance > 0) {
      if (investors[investor].per.currentHolding < DECIMALS.mul(12)) {
        if (investors[investor].per.currentBalance < DECIMALS.mul(800)) {
          perRate = 850;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(2400)) {
          perRate = 888;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(7200)) {
          perRate = 911;
        }
        else if (investors[investor].per.currentBalance >= DECIMALS.mul(7200)) {
          perRate = 925;
        }
      }
      else if (investors[investor].per.currentHolding < DECIMALS.mul(36)) {
        if (investors[investor].per.currentBalance < DECIMALS.mul(800)) {
          perRate = 888;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(2400)) {
          perRate = 906;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(7200)) {
          perRate = 919;
        }
        else if (investors[investor].per.currentBalance >= DECIMALS.mul(7200)) {
          perRate = 930;
        }
      }
      else if (investors[investor].per.currentHolding < DECIMALS.mul(72)) {
        if (investors[investor].per.currentBalance < DECIMALS.mul(800)) {
          perRate = 911;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(2400)) {
          perRate = 919;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(7200)) {
          perRate = 927;
        }
        else if (investors[investor].per.currentBalance >= DECIMALS.mul(7200)) {
          perRate = 934;
        }
      }
      else if (investors[investor].per.currentHolding >= DECIMALS.mul(72)) {
        if (investors[investor].per.currentBalance < DECIMALS.mul(800)) {
          perRate = 925;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(2400)) {
          perRate = 930;
        }
        else if (investors[investor].per.currentBalance < DECIMALS.mul(7200)) {
          perRate = 934;
        }
        else if (investors[investor].per.currentBalance >= DECIMALS.mul(7200)) {
          perRate = 937;
        }
      }
      assert (perRate != 0);
    }

    // The total user interests are incremented by this month's interests in each bond.
    // We divide by 12 because the interest rate is calculated on a yearly basis.
    // If an investor has a "referee balance" we need to apply a 5% bonus to its interests rate. In this case,
    // we multiply the interests rate by 105 then divide it by 100 so it is increased by 5% without precision loss.
    // In any case, we add the rate of each bond (time the investor's balance in this bond) on the interests balance.

    //  Midterm bond interests
    if (investors[investor].mid.refereeBalance > 0) {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((midRate.mul(105) // Rate with 5% bonus
        .mul(investors[investor].mid.refereeBalance))
        .div(12))
        .div(rateFactor)
        .div(bonusFactor)
      );
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((midRate
        .mul(investors[investor].mid.currentBalance.sub(investors[investor].mid.refereeBalance)))
        .div(12))
        .div(rateFactor)
      );
    } else {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((midRate
        .mul(investors[investor].mid.currentBalance))
        .div(12))
        .div(rateFactor)
      );
    }
    //  Longterm bond interests
    if (investors[investor].lng.refereeBalance > 0) {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((lngRate.mul(105) // Rate with 5% bonus
        .mul(investors[investor].lng.refereeBalance))
        .div(12))
        .div(rateFactor)
        .div(bonusFactor)
      );
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((lngRate.mul(investors[investor].lng.currentBalance.sub(investors[investor].lng.refereeBalance)))
        .div(12))
        .div(rateFactor)
      );
    } else {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((lngRate.mul(investors[investor].lng.currentBalance))
        .div(12))
        .div(rateFactor)
      );
    }
    //  Perpetual bond interests
    if (investors[investor].per.refereeBalance > 0) {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((perRate.mul(105) // Rate with 5% bonus
        .mul(investors[investor].per.refereeBalance))
        .div(12))
        .div(rateFactor)
        .div(bonusFactor)
      );
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((perRate.mul(investors[investor].per.currentBalance.sub(investors[investor].per.refereeBalance)))
        .div(12))
        .div(rateFactor)
      );
    } else {
      investors[investor].balanceInterests = investors[investor].balanceInterests.add(
        ((perRate.mul(investors[investor].per.currentBalance))
        .div(12))
        .div(rateFactor)
      );
    }
  }
}