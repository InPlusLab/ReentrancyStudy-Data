pragma solidity ^0.5.0;

import "./RHC.sol";

contract Crowdsale {

  /// @dev represents a round of token sale
  struct Round {
    /// @dev price per token for every token
    uint tokenPrice;
    /// @dev total number of tokens available in the round
    uint capacityLeft;
  }

  /// @notice event is raised when a token sale occurs
  /// @param amountSent amount of money sent by the purchaser
  /// @param amountReturned amount of money returned to the purchaser in case amount sent was not exact
  /// @param buyer the address which purchased the tokens
  event Sale(uint amountSent, uint amountReturned, uint tokensSold, address buyer);

  /// @notice raised when all tokens are sold out
  event SaleCompleted();

  /// @notice raised when a round completes and the next round starts
  /// @param oldTokenPrice previous price per token
  /// @param newTokenPrice new price per token
  event RoundChanged(uint oldTokenPrice, uint newTokenPrice);

  /// @dev information about rounds of fundraising in the crowdsale
  Round[] private _rounds;
  uint8 private _currentRound;

  /// @notice where the contract wires funds in exchange for tokens
  address payable private wallet;

  /// @notice a refenence to the RHC token being sold
  RHC public token;

  /// @notice reports whether the sale is still open
  bool public isSaleOpen;

  /// @dev how much wei has been raised so far
  uint public weiRaised;

  /// @dev how many tokens have been sold so far
  uint public tokensSold;

  /// @notice creates the crowdsale. Only intended to be used by Robinhood team.
  constructor(address payable targetWallet, uint[] memory roundPrices, uint[] memory roundCapacities) public {
    require(roundPrices.length == roundCapacities.length, "Equal number of round parameters must be specified");
    require(roundPrices.length >= 1, "Crowdsale must have at least one round");
    require(roundPrices.length < 10, "Rounds are limited to 10 at most");

    // store rounds
    _currentRound = 0;
    for (uint i = 0; i < roundPrices.length; i++) {
      _rounds.push(Round(roundPrices[i], roundCapacities[i]));
    }

    wallet = targetWallet;
    isSaleOpen = true;
    weiRaised = 0;
    tokensSold = 0;

    // Create token with this contract as the owner
    token = new RHC(address(this));

    // add target wallet as an additional owner
    token.addAdmin(wallet);
  }

  function() external payable {
    uint amount = msg.value;
    address payable buyer = msg.sender;
    require(amount > 0, "must send money to get tokens");
    require(buyer != address(0), "can't send from address 0");
    require(isSaleOpen, "sale must be open in order to purchase tokens");

    (uint tokenCount, uint change) = calculateTokenCount(amount);

    // if insufficient money is sent, return the buyer's mone
    if (tokenCount == 0) {
      buyer.transfer(change);
      return;
    }

    // this is how much of the money will be consumed by this token purchase
    uint acceptedFunds = amount - change;

    // forward funds to owner
    wallet.transfer(acceptedFunds);

    // return left over (unused) funds back to the sender
    buyer.transfer(change);

    // assign tokens to whoever is purchasing
    token.issue(buyer, tokenCount);

    // update state tracking how much wei has been raised so far
    weiRaised += acceptedFunds;
    tokensSold += tokenCount;

    updateRounds(tokenCount);

    emit Sale(amount, change, tokenCount, buyer);
  }

  /// @notice given an amount of money returns how many tokens the money will result in with the
  /// current round's pricing
  function calculateTokenCount(uint money) public view returns (uint count, uint change) {
    require(isSaleOpen, "sale is no longer open and tokens can't be purchased");

    // get current token price
    uint price = _rounds[_currentRound].tokenPrice;
    uint capacityLeft = _rounds[_currentRound].capacityLeft;

    // money sent must be bigger than or equal the price, otherwise, no purchase is necessary
    if (money < price) {
      // return all the money
      return (0, money);
    }

    count = money / price;
    change = money % price;

    // Ensure there's sufficient capacity in the current round. If the user wishes to
    // purchase more, they can send money again to purchase tokens at the next round
    if (count > capacityLeft) {
      change += price * (count - capacityLeft);
      count = capacityLeft;
    }

    return (count, change);
  }

  /// increases the round or closes the sale if tokens are sold out
  function updateRounds(uint tokens) private {
    Round storage currentRound = _rounds[_currentRound];
    currentRound.capacityLeft -= tokens;

    if (currentRound.capacityLeft <= 0) {
      if (_currentRound == _rounds.length - 1) {
        isSaleOpen = false;
        emit SaleCompleted();
      } else {
        _currentRound++;
        emit RoundChanged(currentRound.tokenPrice, _rounds[_currentRound].tokenPrice);
      }
    }
  }
}