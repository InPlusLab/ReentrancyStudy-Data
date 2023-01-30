/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity =0.5.10;

// * Gods Unchained Raffle Token Exchange
//
// * Version 1.0
//
// * A dedicated contract for listing (selling) and buying raffle tokens.
//
// * https://gu.cards

contract ERC20Interface {
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

contract IERC20Interface {
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract RaffleToken is ERC20Interface, IERC20Interface {}

contract RaffleTokenExchange {

    //////// V A R I A B L E S
    //
    // The raffle token contract
    //
    RaffleToken constant public raffleContract = RaffleToken(0x41B00464EB3427F5B05f42Df31e49e083A73bD0f);
    //
    // In case the exchange is paused.
    //
    bool public paused;
    //
    // Standard contract ownership.
    //
    address payable public owner;
    //
    // Next id for the next listing
    //
    uint public nextListingId;
    //
    // All raffle token listings mapped by id
    //
    mapping (uint => Listing) public listingsById;
    //
    // All purchases
    //
    mapping (uint => Purchase) public purchasesById;
    //
    // Next id for the next purche
    //
    uint public nextPurchaseId;

    //////// S T R U C T S
    //
    //  A listing of raffle tokens
    //
    struct Listing {
        //
        // price per token (in wei).
        //
        uint pricePerToken;
        //
        //
        // How many tokens? (Original Amount)
        //
        uint initialAmount;
        //
        // How many tokens left? (Maybe altered due to partial sales)
        //
        uint amountLeft;
        //
        // Listed by whom?
        //
        address payable seller;
        //
        // Active/Inactive listing?
        //
        bool active;
    }
    //
    //  A purchase of raffle tokens
    //
    struct Purchase {
        //
        // How many tokens?
        //
        uint totalAmount;
        //
        // total price payed
        //
        uint totalAmountPayed;
        //
        // When did the purchase happen?
        //
        uint timestamp;
    }

    //////// EVENTS
    //
    //
    //
    event Listed(uint id, uint pricePerToken, uint initialAmount, address seller);
    event Canceled(uint id);
    event Purchased(uint id, uint totalAmount, uint totalAmountPayed, uint timestamp);

    //////// M O D I F I E R S
    //
    // Invokable only by contract owner.
    //
    modifier onlyContractOwner {
        require(msg.sender == owner, "Function called by non-owner.");
        _;
    }
    //
    // Invokable only if exchange is not paused.
    //
    modifier onlyUnpaused {
        require(paused == false, "Exchange is paused.");
        _;
    }

    //////// C O N S T R U C T O R
    //
    constructor() public {
        owner = msg.sender;
        nextListingId = 1;
        nextPurchaseId = 1;
    }

    //////// F U N C T I O N S
    //
    // buyRaffle
    //
    function buyRaffle(uint[] calldata amounts, uint[] calldata listingIds) payable external onlyUnpaused {
        require(amounts.length == listingIds.length, "You have to provide amounts for every single listing!");
        uint totalAmount;
        uint totalAmountPayed;
        for (uint i = 0; i < listingIds.length; i++) {
            uint id = listingIds[i];
            uint amount = amounts[i];
            Listing storage listing = listingsById[id];
            require(listing.active, "Listing is not active anymore!");
            listing.amountLeft -= amount;
            require(listing.amountLeft >= 0, "Amount left needs to be higher than 0.");
            if(listing.amountLeft == 0) { listing.active = false; }
            uint amountToPay = listing.pricePerToken * amount;
            listing.seller.transfer(amountToPay);
            totalAmountPayed += amountToPay;
            totalAmount += amount;
            require(raffleContract.transferFrom(listing.seller, msg.sender, amount), 'Token transfer failed!');
        }
        require(totalAmountPayed <= msg.value, 'Overpayed!');
        uint id = nextPurchaseId++;
        Purchase storage purchase = purchasesById[id];
        purchase.totalAmount = totalAmount;
        purchase.totalAmountPayed = totalAmountPayed;
        purchase.timestamp = now;
        emit Purchased(id, totalAmount, totalAmountPayed, now);
    }
    //
    // Add listing
    //
    function addListing(uint initialAmount, uint pricePerToken) external onlyUnpaused {
        require(raffleContract.balanceOf(msg.sender) >= initialAmount, "Amount to sell is higher than balance!");
        require(raffleContract.allowance(msg.sender, address(this)) >= initialAmount, "Allowance is to small (increase allowance)!");
        uint id = nextListingId++;
        Listing storage listing = listingsById[id];
        listing.initialAmount = initialAmount;
        listing.amountLeft = initialAmount;
        listing.pricePerToken = pricePerToken;
        listing.seller = msg.sender;
        listing.active = true;
        emit Listed(id, listing.pricePerToken, listing.initialAmount, listing.seller);
    }
    //
    // Cancel listing
    //
    function cancelListing(uint id) external {
        Listing storage listing = listingsById[id];
        require(listing.active, "This listing was turned inactive already!");
        require(listing.seller == msg.sender || owner == msg.sender, "Only the listing owner or the contract owner can cancel the listing!");
        listing.active = false;
        emit Canceled(id);
    }
    //
    // Set paused
    //
    function setPaused(bool value) external onlyContractOwner {
        paused = value;
    }
    //
    // Funds withdrawal to cover operational costs
    //
    function withdrawFunds(uint withdrawAmount) external onlyContractOwner {
        owner.transfer(withdrawAmount);
    }
    //
    // Contract may be destroyed only when there is nothing else going on. 
    // All funds are transferred to contract owner.
    //
    function kill() external onlyContractOwner {
        selfdestruct(owner);
    }
}