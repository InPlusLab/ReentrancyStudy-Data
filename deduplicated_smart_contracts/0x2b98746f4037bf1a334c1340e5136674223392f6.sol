/**
 *Submitted for verification at Etherscan.io on 2020-02-22
*/

pragma solidity 0.5.11;

/**
 * @title Gods Unchained - The Chosen One
 * @author Mythic Titan
 */
contract TheChosenOne {
    // 5 Gods Unchained Cards enter the arena
    // The Chosen One is selected at random to keep all of the cards

    // ==== EVENTS ==== //

    /**
     * @dev OnPlayerEnter emits an event when a player enters an arena
     *
     * @param _player - The player's address
     * @param _quality - Gods Unchained card quality
     * @param _proto - Gods Unchained proto id
     */
    event OnPlayerEnter(
        address _player,
        uint8 indexed _quality,
        uint16 indexed _proto
    );

    /**
     * @dev OnPlayerExit emits an event when a player leaves an arena
     *
     * @param _player - The player's address
     * @param _quality - Gods Unchained card quality
     * @param _proto - Gods Unchained proto id
     */
    event OnPlayerExit(
        address _player,
        uint8 indexed _quality,
        uint16 indexed _proto
    );

    /**
     * @dev OnChosenOneSelected emits an event when The Chosen One is selected
     *
     * @param _chosenOne - The Chosen One's address
     * @param _quality - Gods Unchained card quality
     * @param _proto - Gods Unchained proto id
     */
    event OnChosenOneSelected(
        address indexed _chosenOne,
        uint8 indexed _quality,
        uint16 indexed _proto
    );

    // ==== STRUCT ==== //
    struct Player {
        uint256 tokenId;
        address owner;
    }

    // ==== PUBLIC VARIABLES ==== //

    // Mapping proto to quality to players
    mapping(uint16 => mapping(uint8 => Player[])) public arenas;

    /**
     * @dev quorum is how many players must be in an arena to select The Chosen One
     */
    uint256 public quorum = 5;

    /**
     * @dev tokenAddress is the ERC721 Token address
     */
    address public tokenAddress;

    /**
     * @dev tokenInterface interfaces with the ERC721
     */
    interfaceERC721 public tokenInterface;

    // ==== CONSTRUCTOR ==== //

    /**
     * @dev constructor runs once during contract deployment
     *
     * @param _tokenAddress - The Gods Unchained contract address
     */
    constructor(address _tokenAddress)
        public
    {
        tokenInterface = interfaceERC721(_tokenAddress);
    }

    // ==== MODIFIERS ==== //

    /**
     * @dev onlyEOA requires msg.sender to be an externally owned account
     */
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "only externally owned accounts");
        _;
    }

    // ==== PUBLIC WRITE FUNCTIONS ==== //

    /**
     * @dev activateArena selects The Chosen One
     *
     * @param proto - Gods Unchained Proto ID
     * @param quality - Gods Unchained Quality
     */
    function activateArena(uint16 proto, uint8 quality)
        public
        onlyEOA
    {
        // Reference the players
        Player[] storage players = arenas[proto][quality];

        // Require minimum number of players before selecting The Chosen One
        require(players.length == quorum, "requires minimum number of players");

        // Select The Chosen One at random
        uint256 random = getRandom(quorum, proto, quality);

        // The Chosen One
        address theChosenOne = players[random].owner;

        // Transfer winning cards to The Chosen One and Reset the players
        for(uint256 i = players.length - 1; i >= 0; i--) {
            tokenInterface.transferFrom(address(this), theChosenOne, players[i].tokenId);
            players.pop();
        }

        // Emit an event log when The Chosen One is selected
        emit OnChosenOneSelected(theChosenOne, quality, proto);
    }

    /**
     * @dev exitArena removes a player from an Arena
     *
     * @param proto - Gods Unchained proto
     * @param quality - Gods Unchained quality
     * @param index - Index of the player to remove
     */
    function exitArena(uint16 proto, uint8 quality, uint256 index)
        private
    {
        // Reference the players
        Player[] storage arena = arenas[proto][quality];

        // Require the msg.sender is the player
        require(arena[index].owner == msg.sender, "Must be the player");

        // Store the token id
        uint256 tokenId = arena[index].tokenId;

        // Set the last index equal to the removed player
        arena[index] = arena[arena.length - 1];

        // Remove last element in the list of players
        arena.pop();

        // Transfer the token back to the owner
        tokenInterface.transferFrom(address(this), msg.sender, tokenId);

        // Emit an event when a player leaves an arena
        emit OnPlayerExit(msg.sender, quality, proto);
    }

    // ==== EXTERNAL FUNCTIONS ==== //

    /**
     * @dev onERC721Received handles receiving an ERC721 token
     *
     * _operator - The address which called `safeTransferFrom` function
     * @param _from - The address which previously owned the token
     * @param _tokenId - The NFT IDentifier which is being transferred
     * _data - Additional data with no specified format
     *
     * @return Receipt
     */
    function onERC721Received(address /*_operator*/, address _from, uint256 _tokenId, bytes calldata /*_data*/)
        external
        returns(bytes4)
    {
        // Require token address is authorized
        require(msg.sender == tokenAddress, "must be the token address");

        // Require token holder is an externally owned account
        require(tx.origin == _from, "token owner must be an externally owned account");

        // Get the Gods Unchained Proto and Quality from Token ID
        (uint16 proto, uint8 quality) = tokenInterface.getDetails(_tokenId);

        // Check if there is space for a player in the arena
        require(arenas[proto][quality].length < quorum, "Max Players Reached");

        // Add player to an arena
        arenas[proto][quality].push(Player({
            tokenId: _tokenId,
            owner: _from
        }));

        // Emit event when a new player enters the arena
        emit OnPlayerEnter(_from, quality, proto);

        // ERC721_RECEIVED Receipt (magic value)
        return 0x150b7a02;
    }

    // ==== PRIVATE FUNCTIONS ==== //

    /**
     * @dev getRandom generates a random integer from 0 to (max - 1)
     *
     * @param max - Maximum number of integers to select from
     * @param proto - Gods Unchained Proto
     * @param quality - Gods Unchained Quality
     * @return random - The randomly selected integer
     */
    function getRandom(uint256 max, uint16 proto, uint8 quality)
        private
        view
        returns(uint256 random)
    {
        // Blockhash from last block
        uint256 blockhash_ = uint256(blockhash(block.number - 1));

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
            // Proto
            proto,
            // Quality
            quality
        ))) % max;
    }
}

// ==== INTERFACE ==== //
/**
 * @title Abstract Contract Interface
 */
contract interfaceERC721 {
    function getDetails(uint256 _tokenId) public view returns (uint16, uint8);
    function transferFrom(address from, address to, uint256 tokenId) public;
}