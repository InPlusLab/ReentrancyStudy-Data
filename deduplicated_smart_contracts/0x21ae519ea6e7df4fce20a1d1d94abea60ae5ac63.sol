/**
 *Submitted for verification at Etherscan.io on 2019-12-21
*/

pragma solidity 0.5.11;

/**
 * @title Gods Unchained ERC-721 Token Raffle
 * @author Unchained Games
 */
contract RaffleMarket {
    // You can't win the raffle if you don't buy a ticket

    // ==== EVENTS ==== //

    /**
     * @dev OnBuyRaffleTickets emits an event when raffle tickets are purchased
     *
     * @param _raffleId - The raffle ID
     * @param _ticketHolder - Address buying raffle tickets
     * @param _tickets - Number of raffle tickets purchased
     */
    event OnBuyRaffleTickets(
        uint256 indexed _raffleId,
        address indexed _ticketHolder,
        uint256 _tickets
    );

    /**
     * @dev OnCancelRaffle emits an event when a host cancels a raffle
     *
     * @param _raffleId - The raffle ID
     * @param _host - The raffle Host
     */
    event OnCancelRaffle(
        uint256 indexed _raffleId,
        address indexed _host
    );

    /**
     * @dev OnCreateRaffle emits an event when a raffle is created
     *
     * @param _raffleId - The raffle ID
     * @param _tokenId - The token ID
     * @param _host - The host of the raffle
     * @param _costPerTicket - Cost in wei of a raffle ticket
     * @param _minimumTickets - Minimum number of tickets needed to select a raffle winner
     */
    event OnCreateRaffle(
        uint256 indexed _raffleId,
        uint256 indexed _tokenId,
        address indexed _host,
        uint256 _costPerTicket,
        uint256 _minimumTickets
    );

    /**
     * @dev OnDeleteTickets emits an event when raffle tickets are deleted
     *
     * @param _expiredRaffleId - An expired raffle ID
     * @param _tickets - Number of raffle tickets deleted
     */
    event OnDeleteTickets(
        uint256 indexed _expiredRaffleId,
        uint256 _tickets
    );

    /**
     * @dev OnRaffleWinner emits an event when a winning raffle ticket is selected
     *
     * @param _raffleId - The raffle ID
     * @param _winner - The raffle winner
     * @param _random - Randomly selected index
     * @param _payout - Amount of wei sent to the host
     * @param _contribution - Amount of wei sent to the treasury
     */
    event OnRaffleWinner(
        uint256 indexed _raffleId,
        address indexed _winner,
        uint256 _random,
        uint256 _payout,
        uint256 _contribution
    );

    /**
     * @dev OnRefundTickets emits an event when raffle tickets are refunded
     *
     * @param _raffleId - The ID of some raffle
     * @param _quantity - The number of tickets to refund
     */
    event OnRefundTickets(
        uint256 _raffleId,
        uint256 _quantity
    );

    /**
     * @dev OnRemoveAdmin emits an event when an admin is removed
     *
     * @param _admin - The removed admin
     */
    event OnRemoveAdmin(
        address _admin
    );

    /**
     * @dev OnSetAdmin emits an event when an admin address is set
     *
     * @param _admin - The new admin
     */
    event OnSetAdmin(
        address _admin
    );

    /**
     * @dev OnSetMinimumCostPerTicket emits an event when minimum cost per ticket is updated
     *
     * @param _minimumCostPerTicket - The minimum cost in wei for a raffle ticket
     */
    event OnSetMinimumCostPerTicket(
        uint256 _minimumCostPerTicket
    );

    /**
     * @dev OnSetTokenAddress emits an event when the token address is set in the constructor
     *
     * @param _tokenAddress - The ERC721 token address
     */
    event OnSetTokenAddress(
        address _tokenAddress
    );

    /**
     * @dev OnSetTreasury emits an event when the treasury is updated
     *
     * @param _treasury - The treasury address
     */
    event OnSetTreasury(
        address _treasury
    );

    /**
     * @dev OnSetContributionPercent emits an event when the contribution percent is updated
     * For example a contributionPercent of 25 is equal to 2.5%
     *
     * @param _contributionPercent - The contribution percent
     */
    event OnSetContributionPercent(
        uint256 _contributionPercent
    );

    /**
     * @dev OnWithdrawRaffleTickets emits an event when raffle tickets are withdrawn
     *
     * @param _raffleId - The raffle ID
     * @param _ticketHolder - The ticket holder that withdrew raffle tickets
     * @param _indexes - The indexes of withdrawn tickets
     */
    event OnWithdrawRaffleTickets(
        uint256 indexed _raffleId,
        address indexed _ticketHolder,
        uint256[] _indexes
    );

    /**
     * @dev Raffle is a struct containing information about a given raffle
     *
     * @param tokenId - An ERC721 token ID to be raffled
     * @param host - Address of the wallet hosting the raffle
     * @param costPerTicket - The cost of a ticket in wei
     * @param minimumTickets - The minimum number of tickets to activate a raffle
     * @param participants - An array of ticket holder addresses participating in the raffle
     */
    struct Raffle {
        uint256 tokenId;
        address host;
        uint256 costPerTicket;
        uint256 minimumTickets;
        address payable[] participants;
    }

    // ==== GLOBAL PUBLIC VARIABLES ==== //

    // Mapping raffle ID to Raffle
    mapping(uint256 => Raffle) public raffles;

    /**
     * @dev contributionPercent is the percent of a raffle contributed to the treasury
     */
    uint256 public contributionPercent;

    /**
     * @dev minRaffleTicketCost is the minimum amount of wei a raffle ticket can cost
     */
    uint256 public minRaffleTicketCost;

    /**
     * @dev tokenAddress is the ERC721 Token address eligible to raffle
     */
    address public tokenAddress;

    /**
     * @dev tokenInterface interfaces with the ERC721
     */
    interfaceERC721 public tokenInterface;

    /**
     * @dev totalRaffles is the total number of raffles that have been created
     */
    uint256 public totalRaffles;

    // ==== GLOBAL VARIABLES PRIVATE ==== //

    // Mapping admin address to boolean
    mapping(address => bool) private admin;

    /**
     * @dev treasury is the address where contributions are sent
     */
    address payable private treasury;

    // ==== CONSTRUCTOR ==== //

    /**
     * @dev constructor runs once during contract deployment
     *
     * @param _contributionPercent - Percent of a raffle contributed to the treasury
     * @param _minRaffleTicketCost - Minimum cost of a raffle ticket in wei
     * @param _tokenAddress - The token address eligible to Raffle
     * @param _treasury - Address where contributions are sent
     */
    constructor(uint256 _contributionPercent, uint256 _minRaffleTicketCost, address _tokenAddress, address payable _treasury)
        public
    {
        admin[msg.sender] = true;
        tokenInterface = interfaceERC721(_tokenAddress);
        setAdmin(msg.sender);
        setContributionPercent(_contributionPercent);
        setMinRaffleTicketCost(_minRaffleTicketCost);
        setTokenAddress(_tokenAddress);
        setTreasury(_treasury);
    }

    // ==== MODIFIERS ==== //

    /**
     * @dev onlyAdmin requires the msg.sender to be an admin
     */
    modifier onlyAdmin() {
        require(admin[msg.sender], "only admins");
        _;
    }

    /**
     * @dev onlyEOA requires msg.sender to be an externally owned account
     */
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "only externally owned accounts");
        _;
    }

    // ==== PUBLIC WRITE FUNCTIONS ==== //

    /**
     * @dev activateRaffle draws a winning raffle ticket
     *
     * @param raffleId - The Raffle ID
     */
    function activateRaffle(uint256 raffleId)
        public
        onlyEOA
    {
        // Reference the raffle
        Raffle storage raffle = raffles[raffleId];

        // Require minimum number of tickets before drawing a winning raffle ticket
        require(raffle.participants.length >= raffle.minimumTickets, "requires minimum number of tickets");

        selectWinningTicket(raffleId);
    }

    /**
     * @dev activateRaffleAsHost allows the host to activate a raffle at any time
     *
     * @param raffleId - The Raffle ID
     */
    function activateRaffleAsHost(uint256 raffleId)
        public
        onlyEOA
    {
        // Reference the raffle
        Raffle storage raffle = raffles[raffleId];

        // Require raffle host to be the msg.sender
        require(raffle.host == msg.sender, "only the raffle host can activate");

        // Raffle must have at least one ticket
        require(raffle.participants.length >= 1, "at least one participant needed to raffle");

        selectWinningTicket(raffleId);
    }

    /**
     * @dev buyRaffleTickets buys tickets for a given raffle
     *
     * @param raffleId - The Raffle ID
     */
    function buyRaffleTickets(uint256 raffleId)
        public
        payable
        onlyEOA
    {
        // Reference to the raffle
        Raffle storage raffle = raffles[raffleId];

        // Require a valid raffle
        require(raffle.host != address(0), "invalid raffle");

        // Confirm amount of ETH sent is enough for a ticket
        require(msg.value >= raffle.costPerTicket, "must send enough ETH for at least 1 ticket");

        // Calculate total tickets based on msg.value and ticket cost
        uint256 tickets = msg.value / raffle.costPerTicket;

        // Calculate any change
        uint256 remainder = msg.value % raffle.costPerTicket;

        // Add tickets to the raffle
        for (uint256 i = 0; i < tickets; i++) {
            raffle.participants.push(msg.sender);
        }

        // return change back to the address buying tickets
        if (remainder > 0) {
            msg.sender.transfer(remainder);
        }

        emit OnBuyRaffleTickets(raffleId, msg.sender, tickets);
    }

    /**
     * @dev cancelRaffle transfers the token back to the raffle host and deletes the raffle
     *
     * @param raffleId - The Raffle ID
     */
    function cancelRaffle(uint256 raffleId)
        public
    {
        // Reference the raffle
        Raffle storage raffle = raffles[raffleId];

        // Require the raffle host is the message sender
        require(raffle.host == msg.sender, "raffle host only");

        // Require no participants in the raffle
        require(raffle.participants.length == 0, "must be no participants in attendance");

        // Store token ID
        uint256 tokenId = raffle.tokenId;

        // Delete the raffle
        deleteRaffle(raffleId);

        // Transfer the token to the host
        tokenInterface.transferFrom(address(this), msg.sender, tokenId);

        emit OnCancelRaffle(raffleId, msg.sender);
    }

    /**
     * @dev deleteAndBuyRaffleTickets deletes old storage and buys tickets for a given raffle to save gas
     *
     * @param expiredRaffleId - Expired Raffle ID
     * @param tickets - Total number of expired raffle tickets to delete
     * @param raffleId - Raffle ID to buy tickets for
     */
    function deleteAndBuyRaffleTickets(uint256 expiredRaffleId, uint256 tickets, uint256 raffleId)
        public
        payable
    {
        // Reference the expired raffle
        Raffle storage raffle = raffles[expiredRaffleId];

        // Require the raffle has ended
        require(raffle.host == address(0), "raffle expired");

        // Handle deleting expired raffle tickets to free up storage
        if (raffle.participants.length > tickets) {
            do {
                raffle.participants.pop();
            }
            while (raffle.participants.length < raffle.participants.length - tickets);
            emit OnDeleteTickets(expiredRaffleId, tickets);
        } else if (raffle.participants.length > 0) {
            do {
                raffle.participants.pop();
            }
            while (raffle.participants.length > 0);
            emit OnDeleteTickets(expiredRaffleId, raffle.participants.length);
        }

        buyRaffleTickets(raffleId);
    }

    /**
     * @dev withdrawRaffleTickets allows a ticket holder to withdraw their tickets before a raffle is activated
     *
     * @param raffleId - The Raffle ID
     * @param indexes - Index of each ticket to withdraw
     */
    function withdrawRaffleTickets(uint256 raffleId, uint256[] memory indexes)
        public
    {
        // Reference the raffle
        Raffle storage raffle = raffles[raffleId];

        // Require a valid raffle
        require(raffle.host != address(0), "invalid raffle");

        // Require a least one ticket to withdraw
        require(indexes.length > 0, "must be greater than 0");

        // Loop through each ticket to withdraw
        for(uint256 i = 0; i < indexes.length; i++) {
            // Require sender to be the owner of the ticket
            require(raffle.participants[indexes[i]] == msg.sender, "must be ticket owner");

            // Require indexes are sorted from highest index to lowest index
            if (i > 0) {
                require(indexes[i] < indexes[i - 1], "must be sorted from highest index to lowest index");
            }

            // Set the ticket's index to equal the value of the last ticket
            raffle.participants[indexes[i]] = raffle.participants[raffle.participants.length - 1];

            // Delete the last index
            raffle.participants.pop();
        }

        emit OnWithdrawRaffleTickets(raffleId, msg.sender, indexes);

        // Send refund to the ticket holder
        msg.sender.transfer(indexes.length * raffle.costPerTicket);
    }

    /**
     * @dev refundRaffleTickets allows a raffle host to refund raffle tickets in order to cancel a raffle
     *
     * @param raffleId - The Raffle ID
     * @param quantity - Number of tickets to refund
     */
    function refundRaffleTickets(uint256 raffleId, uint256 quantity)
        public
    {
        // Reference the raffle
        Raffle storage raffle = raffles[raffleId];

        // Require raffle host to be the message sender
        require(raffle.host == msg.sender, "must be raffle host");

        // Require at least one ticket to refund
        require(quantity > 0, "must refund at least one ticket");

        // Require tickets in raffle to refund
        require(raffle.participants.length > 0, "must have participants to refund");

        // Number of tickets to refund
        uint256 numberOfTicketsToRefund = quantity;

        // Check quantity of raffle tickets
        if (quantity > raffle.participants.length) {
            numberOfTicketsToRefund = raffle.participants.length;
        }

        // Loop through each raffle ticket to refund
        for(uint256 i = 0; i < numberOfTicketsToRefund; i++) {
            // Store reference to the last participant
            address payable participant = raffle.participants[raffle.participants.length - 1];

            // Delete the last index
            raffle.participants.pop();

            // Transfer raffle cost to the participant
            participant.transfer(raffle.costPerTicket);
        }

        emit OnRefundTickets(raffleId, quantity);
    }

    // ==== PUBLIC READ FUNCTIONS ==== //

    /**
     * @dev getRaffle gets info from a given raffle
     *
     * @param raffleId - The Raffle ID
     *
     * @return _tokenId - ERC721 Token ID
     * @return _host - Address hosting the raffle
     * @return _costPerTicket - The cost in wei for a raffle ticket
     * @return _minimumTickets - The minimum number of tickets needed to activate a raffle
     * @return _participants - The current number of tickets in the raffle
     */
    function getRaffle(uint256 raffleId)
        public
        view
        returns(uint256 _tokenId, address _host, uint256 _costPerTicket, uint256 _minimumTickets, uint256 _participants)
    {
        Raffle storage raffle = raffles[raffleId];

        _tokenId = raffle.tokenId;
        _host = raffle.host;
        _costPerTicket = raffle.costPerTicket;
        _minimumTickets = raffle.minimumTickets;
        _participants = raffle.participants.length;
    }

    /**
     * @dev getRaffles gets info from a list of raffles
     *
     * @param raffleIds - List of Raffle IDs
     *
     * @return _tokenId - List of Token IDs
     * @return _host - List of addresses hosting the raffle
     * @return _costPerTicket - List of costs in wei for a raffle ticket
     * @return _minimumTickets - List of minimum number of tickets needed to activate a raffle
     * @return _participants - List of current number of tickets in the raffle
     */
    function getRaffles(uint256[] memory raffleIds)
        public
        view
        returns(uint256[] memory _tokenId, address[] memory _host, uint256[] memory _costPerTicket, uint256[] memory _minimumTickets, uint256[] memory _participants)
    {
        for(uint256 i = 0; i < raffleIds.length; i++) {
            Raffle storage raffle = raffles[raffleIds[i]];

            _tokenId[i] = raffle.tokenId;
            _host[i] = raffle.host;
            _costPerTicket[i] = raffle.costPerTicket;
            _minimumTickets[i] = raffle.minimumTickets;
            _participants[i] = raffle.participants.length;
        }
    }

    // ==== ADMIN FUNCTIONS ==== //

    /**
     * @dev setContributionPercent sets the percent of a raffle contributed to the treasury
     * Example: A contributionPercent of 25 is equal to 2.5%
     *
     * @param _contributionPercent - Percent of a raffle to contribute to the treasury
     */
    function setContributionPercent(uint256 _contributionPercent)
        public
        onlyAdmin
    {
        require(_contributionPercent < 500, "Can not exceed 50%");
        contributionPercent = _contributionPercent;

        emit OnSetContributionPercent(_contributionPercent);
    }

    /**
     * @dev setMinRaffleTicketCost sets the minimum cost of a raffle ticket in wei
     *
     * @param _minRaffleTicketCost - The minimum allowable cost of a raffle ticket
     */
    function setMinRaffleTicketCost(uint256 _minRaffleTicketCost)
        public
        onlyAdmin
    {
        minRaffleTicketCost = _minRaffleTicketCost;

        emit OnSetMinimumCostPerTicket(_minRaffleTicketCost);
    }

    /**
     * @dev setAdmin sets a new admin
     *
     * @param _admin - The new admin address
     */
    function setAdmin(address _admin)
        public
        onlyAdmin
    {
        admin[_admin] = true;

        emit OnSetAdmin(_admin);
    }

    /**
     * @dev removeAdmin removes an existing admin
     *
     * @param _admin - The admin address to remove
     */
    function removeAdmin(address _admin)
        public
        onlyAdmin
    {
        require(msg.sender != _admin, "self deletion not allowed");
        delete admin[_admin];

        emit OnRemoveAdmin(_admin);
    }

    /**
     * @dev setTreasury sets the treasury address
     *
     * @param _treasury - The treasury address
     */
    function setTreasury(address payable _treasury)
        public
        onlyAdmin
    {
        treasury = _treasury;

        emit OnSetTreasury(_treasury);
    }

    // ==== EXTERNAL FUNCTIONS ==== //

    /**
     * @dev onERC721Received handles receiving an ERC721 token
     *
     * _operator - The address which called `safeTransferFrom` function
     * @param _from - The address which previously owned the token
     * @param _tokenId - The NFT IDentifier which is being transferred
     * @param _data - Additional data with no specified format
     *
     * @return Receipt
     */
    function onERC721Received(address /*_operator*/, address _from, uint256 _tokenId, bytes calldata _data)
        external
        returns(bytes4)
    {
        // Require the token address is authorized
        require(msg.sender == tokenAddress, "must be the token address");

        // Require host is an externally owned account
        require(tx.origin == _from, "token owner must be an externally owned account");

        // Parse data payload
        (uint256 costPerTicket, uint256 minimumTickets) = abi.decode(_data, (uint256, uint256));

        // Create a raffle
        createRaffle(_tokenId, _from, costPerTicket, minimumTickets);

        // ERC721_RECEIVED Receipt (magic value)
        return 0x150b7a02;
    }

    // ==== PRIVATE FUNCTIONS ==== //

    /**
     * @dev createRaffle creates a new raffle
     *
     * @param tokenId - ERC721 Token ID
     * @param host - The host of the raffle
     * @param costPerTicket - The cost of one raffle ticket
     * @param minimumTickets - The minimum number of tickets needed for a raffle
     */
    function createRaffle(uint256 tokenId, address host, uint256 costPerTicket, uint256 minimumTickets)
        private
    {
        // Require the cost of a ticket to be greater than or equal to the minimum cost of a raffle ticket
        require(costPerTicket >= minRaffleTicketCost, "ticket price must meet the minimum");

        // Require at least one ticket to create a raffle
        require(minimumTickets > 0, "must set at least one raffle ticket");

        // Increment total raffles
        totalRaffles = totalRaffles + 1;
        uint256 raffleId = totalRaffles;

        // Creates a raffle
        raffles[raffleId] = Raffle({
            tokenId: tokenId,
            host: host,
            costPerTicket: costPerTicket,
            minimumTickets: minimumTickets,
            participants: new address payable[](0)
        });

        // Emit event when a raffle is created
        emit OnCreateRaffle(raffleId, tokenId, host, costPerTicket, minimumTickets);
    }

    /**
     * @dev deleteRaffle invalidates a given raffle
     *
     * @param raffleId - The Raffle ID
     */
    function deleteRaffle(uint256 raffleId)
        private
    {
        // Delete the raffle
        delete raffles[raffleId].tokenId;
        delete raffles[raffleId].host;
        delete raffles[raffleId].costPerTicket;
        delete raffles[raffleId].minimumTickets;
    }

    /**
     * @dev selectWinningTicket selects the winning ticket for a given raffle
     *
     * @param raffleId - The Raffle ID
     */
    function selectWinningTicket(uint256 raffleId)
        private
    {
        // Reference the raffle
        Raffle storage raffle = raffles[raffleId];

        // Get a random number based on total participants
        (uint256 random) = getRandom(raffle.participants.length);

        // Select a winner at random
        address winner = raffle.participants[random];

        // Confirm winner is a participant
        assert(winner != address(0));

        // The total amount of ETH allocated to the raffle
        uint256 pot = raffle.participants.length * raffle.costPerTicket;

        // Amount to contribute to the treasury
        uint256 contribution = (pot * contributionPercent) / 1000;

        // Amount to payout to the host
        uint256 payout = pot - contribution;

        // Cast host address as payable
        address payable host = address(uint160(raffle.host));

        // Store the token ID
        uint256 tokenId = raffle.tokenId;

        // Delete the raffle
        deleteRaffle(raffleId);

        // Transfer prize to the raffle winner
        interfaceERC721(tokenAddress).transferFrom(address(this), winner, tokenId);

        // Assert the winner is now the owner of the prize
        assert(tokenInterface.ownerOf(tokenId) == winner);

        // Transfer contribution to the treasury
        treasury.transfer(contribution);

        // Transfer pot to the raffle host
        host.transfer(payout);

        emit OnRaffleWinner(raffleId, winner, random, payout, contribution);
    }

    /**
     * @dev getRandom generates a random integer from 0 to (max - 1)
     *
     * @param max - Maximum number of integers to select from
     * @return random - The randomly selected integer
     */
    function getRandom(uint256 max)
        private
        view
        returns(uint256 random)
    {
        // Blockhash from last block
        uint256 blockhash_ = uint256(blockhash(block.number - 1));

        // Contract balance
        uint256 balance = address(this).balance;

        // Randomly generated integer
        random = uint256(keccak256(abi.encodePacked(
            // Unix timestamp in seconds
            block.timestamp,
            // Address of the block miner
            block.coinbase,
            // Difficulty of the block
            block.difficulty,
            // Blockhash from last block
            blockhash_,
            // Contract balance
            balance
        ))) % max;
    }

    /**
     * @dev setTokenAddress sets the ERC721 token address once from the constructor
     *
     * @param _tokenAddress - The ERC721 token address
     */
    function setTokenAddress(address _tokenAddress)
        private
    {
        tokenAddress = _tokenAddress;
        emit OnSetTokenAddress(_tokenAddress);
    }
}

// ==== INTERFACE ==== //
/**
 * @title Abstract Contract Interface
 */
contract interfaceERC721 {
    function transferFrom(address from, address to, uint256 tokenId) public;
    function ownerOf(uint256 tokenId) public view returns (address);
}