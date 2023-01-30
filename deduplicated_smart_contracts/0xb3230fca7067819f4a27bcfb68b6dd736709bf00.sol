pragma solidity ^0.4.19;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    string public constant name = "Token Name";
    string public constant symbol = "SYM";
    uint8 public constant decimals = 18;  // 18 is the most common number of decimal places

}

/**
 *
 *	# Marketboard Listing
 *
 *	This contract represents an item listed on the marketboard at marketboard.io
 *
 *  Steps for listing:
 *  - Server creates a bunch of these contracts in &#39;idle&#39; state (async, in cron job, &#39;creating&#39; state until mined)
 *  - When a user starts a transaction, server returns an &#39;idle&#39; state one and marks it as &#39;pending:tokens&#39; state
 *  - User sets their price per token, this is saved on the servers.
 *  - User gets the contract address, and sends some tokens to the contract.
 *  - While webapp is open, constantly query for incoming tokens to this contract
 *  - If no query for 24 hours, put contract back to &#39;idle&#39; state. Do a token query just in case maybe?
 *  - Once tokens received, send a `finalize(tokenContractAddr, senderAddr, tokenPrice)` transaction to the contract from the server, mark as &#39;pending:finalize&#39;
 *  - Show success to user, item is now listed but with finalizing logo
 *  - Server contantly queries all &#39;pending:finalize&#39; contracts until they&#39;ve been mined
 *  - Once mined (ie calling `isReady()` returns true) state change to &#39;ready&#39;
 *
 *  Steps for buyback:
 *  - REQUIRES &#39;ready&#39; state
 *  - User sends a call to the contract&#39;s `buyback()` function
 *
 *  Steps for purchase:
 *  - REQUIRES &#39;ready&#39; state
 *  - User calls `purchase(recipientAddr)` and sends required money to the contract
 *  - Server constantly monitors &#39;ready&#39; contracts (maybe only when a user views it?)
 *  - Once contract has been reset, mark contract as &#39;idle&#39; state
 *
 *  Type IDs:
 *  - 0x01  :   ERC20 listing
 */

/// Represents a listing on the ProWallet Marketboard
contract MarketboardERC20Listing {

    /// Contract version
    function _version() pure public returns(uint32) {
        return 1;
    }

    /// Notifies when the listing has been completed
    event MarketboardListingComplete(address indexed tokenContract, uint256 numTokensSold, uint256 totalEtherPrice, uint256 fee);

    /// Notifies when the listing was cancelled by the seller
    event MarketboardListingBuyback(address indexed tokenContract, uint256 numTokens);

	/// Notifies when the listing has been destroyed
	event MarketboardListingDestroyed();

    /// Notifies that the seller has changed the price on this listing
    event MarketboardListingPriceChanged(uint256 oldPricePerToken, uint256 newPricePerToken);


    /// This function modifier fails if the caller is not the contract creator.
    modifier moderatorOnly {
        require(msg.sender == moderator);
        _;
    }

    /// This function modifier fails if the caller is not the contract creator or token seller.
    modifier moderatorOrSellerOnly {
        require(moderator == msg.sender || seller == msg.sender);
        _;
    }

    /// The Ethereum price per token
	uint256 public tokenPrice = 0;

    /// The ERC20 token contract address that we are selling
    address public tokenContract;

    /// The account which is moderating this transaction. This is also the account which receives the fee profits.
    address moderator;

    /// The account which will receive the money if someone buys this listing. This is the account which created the listing.
    address seller;

    /// This is a fixed Ethereum fee added to the transaction. The fee is
    /// sent back to the contract creator after successful purchase.
    uint256 public feeFixed;

    /// This fee is a percentage of the total price with a base of 100,000, ie. 1,000 is 1%. The fee is
    /// sent back to the contract creator after successful purchase.
    uint32 public feePercentage;
	uint32 constant public feePercentageMax = 100000;

    /// Constructor
    function MarketboardERC20Listing(address _moderator, uint256 _feeFixed, uint32 _feePercentage, address _erc20Token, uint256 _tokenPrice) public {

        // Store the contract creator (the automated server account)
        seller = msg.sender;
        moderator = _moderator;
        feeFixed = _feeFixed;
        feePercentage = _feePercentage;
        tokenContract = _erc20Token;
        tokenPrice = _tokenPrice;

    }

    /// Get the total amount of ERC20 tokens we are sending
    function tokenCount() public view returns(uint256) {

        // Fetch token balance
        ERC20 erc = ERC20(tokenContract);
        return erc.balanceOf(this);

    }

    /// Get the total amount of Ether needed to successfully purchase this item.
    function totalPrice() public view returns(uint256) {

        // Return price required
        return tokenPrice * tokenCount() + fee();

    }

    /// Get the fee this transaction will cost.
    function fee() public view returns(uint256) {

        // Get total raw price, item cost * item count
        uint256 price = tokenPrice * tokenCount();

        // Calculate fee
        return price * feePercentage / feePercentageMax + feeFixed;

    }

    /// Allows the seller to change the price of this listing
    function setPrice(uint256 newTokenPrice) moderatorOrSellerOnly public {

        // Store old price
        uint256 oldPrice = tokenPrice;

        // Set new price
        tokenPrice = newTokenPrice;

        // Notify
        MarketboardListingPriceChanged(oldPrice, newTokenPrice);

    }

    /// Perform a buyback, ie. retrieve the item for free. Only the creator or the seller can do this.
    function buyback(address recipient) moderatorOrSellerOnly public {

        // Send tokens to the recipient
        ERC20 erc = ERC20(tokenContract);
		uint256 balance = erc.balanceOf(this);
        erc.transfer(recipient, balance);

        // Send event
        MarketboardListingBuyback(tokenContract, balance);

        // We are done, reset and send remaining Ether (if any) back to the moderator
        reset();

    }

	/// Purchase the item(s) represented by this listing, and send the tokens to
    /// another address instead of the sender.
    function purchase(address recipient) public payable {

        // Check if the right amount of Ether was sent
        require(msg.value >= totalPrice());

        // Send tokens to the recipient
        ERC20 erc = ERC20(tokenContract);
		uint256 balance = erc.balanceOf(this);
        erc.transfer(recipient, balance);

		// Get the amount of Ether to send to the seller
		uint256 basePrice = tokenPrice * balance;
		require(basePrice > 0);
		require(basePrice < this.balance);

		// Send Ether to the seller
		seller.transfer(basePrice);

        // Send event
        MarketboardListingComplete(tokenContract, balance, 0, 0);

        // We are done, reset and send remaining Ether back to the moderator as fee
        reset();

    }

    /// If somehow another unrelated type of token was sent to this contract, this can be used to claim those tokens back.
    function claimUnrelatedTokens(address unrelatedTokenContract, address recipient) moderatorOrSellerOnly public {

        // Make sure we&#39;re not dealing with the known token
        require(tokenContract != unrelatedTokenContract);

        // Send tokens to the recipient
        ERC20 erc = ERC20(unrelatedTokenContract);
        uint256 balance = erc.balanceOf(this);
        erc.transfer(recipient, balance);

    }

	/// Destroys the listing. Also transfers profits to the moderator.
	function reset() internal {

        // Notify
        MarketboardListingDestroyed();

		// Send remaining Ether (the fee from the last transaction) to the creator as profits
		selfdestruct(moderator);

	}

}