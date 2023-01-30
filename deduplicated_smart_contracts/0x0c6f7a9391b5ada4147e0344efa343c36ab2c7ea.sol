// SPDX-License-Identifier: MIT
// @author 0xski.eth

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./Base64.sol";

// Interface to the original Loot Contract.
interface LootInterface {
    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    function getWeapon(uint256 tokenId) external view returns (string memory);

    function getChest(uint256 tokenId) external view returns (string memory);

    function getHead(uint256 tokenId) external view returns (string memory);

    function getWaist(uint256 tokenId) external view returns (string memory);

    function getFoot(uint256 tokenId) external view returns (string memory);

    function getHand(uint256 tokenId) external view returns (string memory);

    function getNeck(uint256 tokenId) external view returns (string memory);

    function getRing(uint256 tokenId) external view returns (string memory);
}

interface SytheticLootInterface {
    function getWeapon(address walletAddress)
        external
        view
        returns (string memory);

    function getChest(address walletAddress)
        external
        view
        returns (string memory);

    function getHead(address walletAddress)
        external
        view
        returns (string memory);

    function getWaist(address walletAddress)
        external
        view
        returns (string memory);

    function getFoot(address walletAddress)
        external
        view
        returns (string memory);

    function getHand(address walletAddress)
        external
        view
        returns (string memory);

    function getNeck(address walletAddress)
        external
        view
        returns (string memory);

    function getRing(address walletAddress)
        external
        view
        returns (string memory);
}

library Svg {
    /**
     * @dev Returns a <line> element giving a straight line between
     the two points specified by (`x1`,`y1`), (`x2`, `y2`). Color can be
     specified with `color` string and `roundLine` is a boolean flag to 
     make the corners of the line rounded.
     */
    function getLine(
        uint256 x1,
        uint256 x2,
        uint256 y1,
        uint256 y2,
        string memory color,
        bool roundLine
    ) public pure returns (string memory) {
        string[11] memory parts;

        parts[0] = '<line x1="';
        parts[1] = Strings.toString(x1);
        parts[2] = '" x2="';
        parts[3] = Strings.toString(x2);
        parts[4] = '" y1="';
        parts[5] = Strings.toString(y1);
        parts[6] = '" y2="';
        parts[7] = Strings.toString(y2);
        parts[8] = '" stroke="';
        parts[9] = color;
        if (roundLine) {
            parts[10] = '" stroke-width="2" stroke-linecap="round"/>';
        } else {
            parts[10] = '" stroke-width="2" stroke-linecap="square"/>';
        }

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(abi.encodePacked(output, parts[9], parts[10]));
        return output;
    }

    /**
     * @dev Returns a <path> element giving a filled curve. The curve is
     specified by start x,y coordinates, end x,y coordinates and a control
     point that controls the curve.
     */
    function getFilledCurve(
        uint256 startX,
        uint256 startY,
        uint256 controlX,
        uint256 controlY,
        uint256 endX,
        uint256 endY
    ) public pure returns (string memory) {
        string[17] memory parts;
        string memory fillColor = "white";

        parts[0] = '<path d="M ';
        parts[1] = Strings.toString(startX);
        parts[2] = " ";
        parts[3] = Strings.toString(startY);
        parts[4] = " Q ";
        parts[5] = Strings.toString(controlX);
        parts[6] = " ";
        parts[7] = Strings.toString(controlY);
        parts[8] = " ";
        parts[9] = Strings.toString(endX);
        parts[10] = " ";
        parts[11] = Strings.toString(endY);
        parts[12] = '" stroke="';
        parts[13] = fillColor;
        parts[14] = '" fill="';
        parts[15] = fillColor;
        parts[16] = '" stroke-linecap="round"/>';

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[9],
                parts[10],
                parts[11],
                parts[12],
                parts[13],
                parts[14],
                parts[15],
                parts[16]
            )
        );
        return output;
    }

    /**
     * @dev Returns a <text> element opening position at `atX` and `atY`
     coordinates with CSS class name specified by `className`.
     */
    function getText(
        uint256 atX,
        uint256 atY,
        string memory className
    ) public pure returns (string memory) {
        string[7] memory parts;
        parts[0] = '<text x="';
        parts[1] = Strings.toString(atX);
        parts[2] = '" y="';
        parts[3] = Strings.toString(atY);
        parts[4] = '" class="';
        parts[5] = className;
        parts[6] = '">';

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6]
            )
        );
        return output;
    }

    /**
     * @dev Adds the chest to the SVG. Based on whether the treasure
     has been opened, this will be an opened or closed treasure
     chest rendering.
     */
    function __svgAddTreasureChest(bool isOpened)
        public
        pure
        returns (string memory)
    {
        string[30] memory parts;
        string memory chestColor = "white";

        parts[0] = getLine(125, 225, 250, 250, chestColor, true);
        parts[1] = getLine(125, 225, 300, 300, chestColor, true);
        parts[2] = getLine(125, 125, 250, 300, chestColor, true);
        parts[3] = getLine(225, 225, 250, 300, chestColor, true);

        // Corners of chest.
        parts[4] = getLine(125, 135, 290, 300, chestColor, true);
        parts[5] = getLine(225, 215, 290, 300, chestColor, true);

        // Top of chest.
        uint256 chestTopY;
        if (isOpened) {
            chestTopY = 225;
        } else {
            chestTopY = 250;
        }

        parts[6] = getLine(125, 225, chestTopY, chestTopY, chestColor, true);
        parts[7] = getLine(
            125,
            125,
            chestTopY,
            chestTopY - 15,
            chestColor,
            true
        );
        parts[8] = getLine(
            225,
            225,
            chestTopY,
            chestTopY - 15,
            chestColor,
            true
        );
        parts[9] = getLine(
            125,
            225,
            chestTopY - 15,
            chestTopY - 15,
            chestColor,
            true
        );

        if (isOpened) {
            // Connectors from top to bottom.
            parts[10] = getLine(125, 130, 225, 250, chestColor, true);
            parts[11] = getLine(225, 220, 225, 250, chestColor, true);
        }

        // Bottom notch.
        parts[12] = getLine(170, 170, 250, 265, chestColor, true);
        parts[13] = getLine(180, 180, 250, 265, chestColor, true);
        parts[14] = getLine(170, 180, 265, 265, chestColor, true);

        // Top notch.
        parts[15] = getLine(
            170,
            170,
            chestTopY,
            chestTopY - 5,
            chestColor,
            true
        );
        parts[16] = getLine(
            180,
            180,
            chestTopY,
            chestTopY - 5,
            chestColor,
            true
        );
        parts[17] = getLine(
            170,
            180,
            chestTopY - 5,
            chestTopY - 5,
            chestColor,
            true
        );

        if (isOpened) {
            // Top lock.
            parts[18] = getLine(172, 172, 225, 230, chestColor, true);
            parts[19] = getLine(178, 178, 225, 230, chestColor, true);
            parts[20] = getLine(172, 178, 230, 230, chestColor, true);
        }

        // Bottom lock
        parts[21] = getLine(175, 175, 256, 258, chestColor, true);

        // Top corners.
        parts[22] = getLine(
            135,
            125,
            chestTopY - 15,
            chestTopY - 5,
            chestColor,
            true
        );
        parts[23] = getLine(
            215,
            225,
            chestTopY - 15,
            chestTopY - 5,
            chestColor,
            true
        );

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[9],
                parts[10],
                parts[11],
                parts[12],
                parts[13],
                parts[14],
                parts[15],
                parts[16]
            )
        );
        output = string(
            abi.encodePacked(
                output,
                parts[17],
                parts[18],
                parts[19],
                parts[20],
                parts[21],
                parts[22],
                parts[23],
                parts[24]
            )
        );
        output = string(abi.encodePacked(output, parts[25], parts[26]));
        return output;
    }

    /**
     * @dev Adds a plaque to the SVG for treasures claimed using a Loot bag.
     */
    function __svgAddTreasureChestPlaque() public pure returns (string memory) {
        string[10] memory parts;
        parts[
            0
        ] = '<rect x="165" y="278" width="20" height="10" stroke="white" stroke-width="1" fill="none" />';
        parts[
            1
        ] = '<circle cx="167" cy="280" r="0.5" stroke="white" fill="white" stroke-width="0.25" />';
        parts[
            2
        ] = '<circle cx="167" cy="286" r="0.5" stroke="white" fill="white" stroke-width="0.25" />';
        parts[
            3
        ] = '<circle cx="183" cy="280" r="0.5" stroke="white" fill="white" stroke-width="0.25" />';
        parts[
            4
        ] = '<circle cx="183" cy="286" r="0.5" stroke="white" fill="white" stroke-width="0.25" />';
        parts[5] = getText(171, 284, "small");
        parts[6] = "Loot";
        parts[7] = "</text>";

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7]
            )
        );
        return output;
    }

    /**
     * @dev Adds the treasure contents to the SVG based on a randomly picked
     composition (either 1, 2x, or 3x). Probabilities are 50% for 1x, 30% for
     2x and 20% for 3x.
     */
    function __svgAddTreasureContents(uint256 randComposition)
        public
        pure
        returns (string memory)
    {
        string[3] memory parts;

        if (randComposition >= 50) {
            parts[0] = getFilledCurve(130, 249, 175, 240, 220, 249);
        } else if (randComposition >= 20) {
            parts[0] = getFilledCurve(130, 249, 152, 240, 175, 249);
            parts[1] = getFilledCurve(175, 249, 197, 240, 220, 249);
        } else {
            parts[0] = getFilledCurve(130, 249, 145, 240, 160, 249);
            parts[1] = getFilledCurve(160, 249, 175, 240, 190, 249);
            parts[2] = getFilledCurve(190, 249, 205, 240, 220, 249);
        }

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2])
        );
        return output;
    }

    /**
     * @dev Adds the text for the treasure contents description.
     */
    function __svgAddTreasureContentsDescription(
        uint256 textX,
        uint256 textY,
        string memory description
    ) public pure returns (string memory) {
        string[3] memory parts;
        parts[0] = getText(textX, textY, "base");
        parts[1] = description;
        parts[2] = "</text>";

        return string(abi.encodePacked(parts[0], parts[1], parts[2]));
    }

    /**
     * @dev Adds the text for the treasure location.
     */
    function __svgAddLocation(
        uint256 textX,
        uint256 textY,
        uint256 treasureX,
        uint256 treasureY
    ) public pure returns (string memory) {
        string[7] memory parts;
        parts[0] = getText(textX, textY, "base");
        parts[1] = "Found at: (";
        parts[2] = Strings.toString(treasureX);
        parts[3] = ", ";
        parts[4] = Strings.toString(treasureY);
        parts[5] = ")";
        parts[6] = "</text>";

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6]
            )
        );
        return output;
    }

    /**
     * @dev Adds the text for the random item of Loot or
     Synthetic loot that is recorded when the treasure is minted.
     */
    function __svgAddWearingItem(
        uint256 textX,
        uint256 textY,
        string memory whileWearing
    ) public pure returns (string memory) {
        string[4] memory parts;
        parts[0] = getText(textX, textY, "base");
        parts[1] = "Wearing: ";
        parts[2] = whileWearing;
        parts[3] = "</text>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2], parts[3])
        );
        return output;
    }

    /**
     * @dev Adds the text for the Loot bag that was used to claim
     the treasure (if any). This is only the case when the treasure
     is claimed with 'mintWithLoot'.
     */
    function __svgAddLootBagRecord(
        uint256 textX,
        uint256 textY,
        uint256 lootBagId
    ) public pure returns (string memory) {
        string[4] memory parts;
        parts[0] = getText(textX, textY, "base");
        parts[1] = "Carrying Loot: Bag #";
        parts[2] = Strings.toString(lootBagId);
        parts[3] = "</text>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2], parts[3])
        );
        return output;
    }

    /**
     * @dev Adds the text for the weight of the treasure.
     */
    function __svgAddTreasureWeight(
        uint256 textX,
        uint256 textY,
        uint256 weight
    ) public pure returns (string memory) {
        string[5] memory parts;

        parts[0] = getText(textX, textY, "base");
        parts[1] = "Weight: ";
        parts[2] = Strings.toString(weight);
        parts[3] = " kg";
        parts[4] = "</text>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4])
        );
        return output;
    }

    /**
     * @dev Returns the opening tag of an SVG with some high level properties
     specified.
     */
    function __svgAddBegin() public pure returns (string memory) {
        return
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; } .small {fill: white; font-size: 4px;}</style><rect width="100%" height="100%" fill="black" />';
    }
}

contract TreasureChests is ERC721Enumerable, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIds;

    // Reference to the 'Loot' contract.
    address private lootAddress = 0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7;
    LootInterface private lootContract = LootInterface(lootAddress);

    // Reference to the 'Synthetic Loot' contract.
    address private syntheticLootAddress =
        0x869Ad3Dfb0F9ACB9094BA85228008981BE6DBddE;
    SytheticLootInterface private syntheticLootContract =
        SytheticLootInterface(syntheticLootAddress);

    // Keeping track of which addresses claimed the Treasure (either with
    // 'regular' mint or with Loot).
    mapping(address => bool) private claimedAddresses;

    // Keeping track which treasure locations have been discovered. We hash
    // the (x, y) coordinates and store here.
    mapping(bytes32 => bool) private hasLocationBeenDiscovered;

    // State to keep track of Treasure properties.
    // 1. Whether the treasure has been opened.
    // 2. Where the treasure is located (depends on address minting).
    // 3. Random Synthetic Loot or Loot item recorded when minting
    // 4. Record of which Loot was used to claim treasure if minting
    //    with Loot.
    mapping(uint256 => bool) private isTreasureOpened;
    mapping(uint256 => uint256) private discoveredWithLoot;
    mapping(uint256 => string) private whileWearing;
    mapping(uint256 => bytes) private coordinates;

    // Amount of Ether an account has to send to open the treasure.
    uint256 public constant openTreasurePrice = 20000000000000000; // 0.02 ETH
    uint256 public constant treasureMapSize = 1024;

    constructor() ERC721("Treasure Chests", "CHESTS") {}

    function totalSupply() public view override returns (uint256) {
        return _tokenIds.current();
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    /**
     * @dev Function to get a random uint from `input` akin to one in
     dhof's Loot contract.
     */
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    modifier oncePerAddress() {
        // This address has already been used to claim a treasure.
        require(
            !claimedAddresses[msg.sender],
            "This address has already been used to claim a treasure"
        );
        _;
    }

    modifier canOpenAtMint() {
        // Send only 0 ETH to mint treasure closed or 0.02 ETH to open the treasure.
        require(
            msg.value == 0 || msg.value == openTreasurePrice,
            "Send only 0 ETH to mint treasure closed or 0.02 ETH to open the treasure"
        );
        _;
    }

    /**
     * @dev 'with Loot' way to claim a treasure that requires the adventurer
     to have a Loot bag that they can specify as the one to use when claiming
     the treasure.
     */
    function mintWithLoot(
        uint256 lootBagId,
        uint256 treasureX,
        uint256 treasureY
    ) public payable oncePerAddress canOpenAtMint {
        require(
            lootContract.ownerOf(lootBagId) == msg.sender,
            "Sender not owner of provided Loot"
        );

        // First verify that a treasure has not yet been discovered at
        // these coordinates and also that the coordinates that the
        // sender is trying to discover the treasure at are correctly
        // derived from the sender's address.
        bytes32 coordHash = keccak256(
            abi.encodePacked(treasureX, ",", treasureY)
        );
        __verifyTreasureCoordinates(treasureX, treasureY, coordHash);

        // Update the state by
        // 1. Marking the (x, y) location as discovered.
        // 2. Marking the address as having claimed a treasure.
        hasLocationBeenDiscovered[coordHash] = true;
        claimedAddresses[msg.sender] = true;

        // Get whatever the next token ID is.
        _tokenIds.increment();
        uint256 newTreasureId = _tokenIds.current();

        // Update metadata for this token at mint:
        // 1. Since this is a 'withLoot' mint, pick a random Loot
        //    item that the adventurer uses to claim the treasure and store
        //    it in the state.
        // 2. Record which Loot bag was used to claim this treasure.
        // 3. Store the coordinates of this treasure.
        // 4. If the adventurer has chosen to open treasure,
        //    record that in the state.

        // Uses the actual Loot bag to pick a random item.
        whileWearing[newTreasureId] = getRandomLootItem(msg.sender, lootBagId);
        discoveredWithLoot[newTreasureId] = lootBagId;
        coordinates[newTreasureId] = abi.encode(treasureX, ",", treasureY);
        if (msg.value == openTreasurePrice) {
            isTreasureOpened[newTreasureId] = true;
        }

        _mint(msg.sender, newTreasureId);
    }

    /**
     * @dev 'Regular' way to claim a treasure that any adventurer with
     an ethereum address can use.
     */
    function mint(uint256 treasureX, uint256 treasureY)
        public
        payable
        oncePerAddress
        canOpenAtMint
        nonReentrant
    {
        // First verify that a treasure has not yet been discovered at
        // these coordinates and also that the coordinates that the
        // sender is trying to discover the treasure at are correctly
        // derived from the sender's address.
        bytes32 coordHash = keccak256(
            abi.encodePacked(treasureX, ",", treasureY)
        );
        __verifyTreasureCoordinates(treasureX, treasureY, coordHash);

        // Update the state by
        // 1. Marking the (x, y) location as discovered.
        // 2. Marking the address as having claimed a treasure.
        hasLocationBeenDiscovered[coordHash] = true;
        claimedAddresses[msg.sender] = true;

        // Get whatever the next token ID is.
        _tokenIds.increment();
        uint256 newTreasureId = _tokenIds.current();

        // Update metadata for this token at mint:
        // 1. Since this is a 'regular' mint, pick a random Synthetic Loot
        //    item that the adventurer uses to claim the treasure and store
        //    it in the state.
        // 2. Store the coordinates of this treasure.
        // 3. If the adventurer has chosen to open treasure,
        //    record that in the state.

        whileWearing[newTreasureId] = getRandomSyntheticLootItem(msg.sender);
        coordinates[newTreasureId] = abi.encode(treasureX, ",", treasureY);
        if (msg.value == openTreasurePrice) {
            isTreasureOpened[newTreasureId] = true;
        }

        _mint(msg.sender, newTreasureId);
    }

    /**
     * @dev If the treasure was not opened at mint, can open it by calling
     this function and sending the same small fee.
     */
    function openTreasure(uint256 tokenId) public payable nonReentrant {
        require(
            msg.value == openTreasurePrice,
            "Fee to the goldsmith to open a treasure is 0.02 ETH"
        );
        require(
            tokenId > 0 && tokenId <= _tokenIds.current(),
            "Token ID invalid"
        );
        require(ownerOf(tokenId) == msg.sender, "Not owner of treasure");
        require(!isTreasureOpened[tokenId], "Treasure already opened");

        isTreasureOpened[tokenId] = true;
    }

    /**
     * @dev Verifies the coordinates of the treasure which are coming as function
     call arguments. Checks that the coordinates are correctly derived from the 
     sender's address and checks to make sure that the treasure at the given
     coordinates has not yet been discovered.
     */
    function __verifyTreasureCoordinates(
        uint256 treasureX,
        uint256 treasureY,
        bytes32 coordHash
    ) private view {
        uint256 computedTreasureX = random(
            string(abi.encodePacked(msg.sender, "x"))
        ) % treasureMapSize;
        uint256 computedTreasureY = random(
            string(abi.encodePacked(msg.sender, "y"))
        ) % treasureMapSize;

        // Treasure x coordinate does not match
        require(
            computedTreasureX == treasureX,
            "Treasure x coordinate does not match"
        );
        // Treasure y coordinate does not match
        require(
            computedTreasureY == treasureY,
            "Treasure y coordinate does not match"
        );
        // Treasure at the provided x, y coordinates has already been discovered
        require(!hasLocationBeenDiscovered[coordHash]);
    }

    /**
     * @dev Returns the weight of a treasure.
     */
    function getTreasureWeight(uint256 tokenId) private pure returns (uint256) {
        return
            random(
                string(abi.encodePacked("WEIGHT", Strings.toString(tokenId)))
            ).mod(100).add(1);
    }

    /**
     * @dev Returns the metal of a given treasure along with a multiplier (if any) based on
     the random composition (2x or 3x). Only called if the treasure is opened.
     */
    function getTreasureMetal(
        uint256 tokenId,
        uint256 treasureX,
        uint256 treasureY
    ) private pure returns (string memory) {
        uint256 randMetal = random(
            string(
                abi.encodePacked(
                    "METAL",
                    treasureX,
                    treasureY,
                    Strings.toString(tokenId)
                )
            )
        ).mod(101);

        // Distribution over 0 - 100.
        string memory metal;
        if (randMetal == 100) {
            metal = "Rhodium";
        } else if (randMetal >= 95) {
            metal = "Platinum";
        } else if (randMetal >= 80) {
            metal = "Gold";
        } else if (randMetal >= 50) {
            metal = "Silver";
        } else {
            metal = "Bronze";
        }

        // Get the composition for the treasure here in order to
        // display it correctly with the metal.
        uint256 randComposition = __getRandomTreasureComposition(
            tokenId,
            treasureX,
            treasureY
        );
        if (randComposition >= 50) {
            return metal;
        } else if (randComposition >= 20) {
            return string(abi.encodePacked("2x", " ", metal));
        } else {
            return string(abi.encodePacked("3x", " ", metal));
        }
    }

    /**
     * @dev Returns a string for the special item contained in the
     treasure. If none, returns empty string.
     */
    function getTreasureSpecialItem(
        uint256 tokenId,
        uint256 treasureX,
        uint256 treasureY
    ) private pure returns (string memory) {
        uint256 special = random(
            string(
                abi.encodePacked(
                    "SPECIAL",
                    treasureX,
                    treasureY,
                    Strings.toString(tokenId)
                )
            )
        ).mod(250);

        // Some rare treasures.
        if (special == 66) {
            return "Sacred Texts";
        }
        if (special == 0) {
            return "Map to Blackbeard's Treasure";
        }
        if (special == 1) {
            return "Ancient Coin";
        }
        if (special == 7) {
            return "Note to a Byzantine General";
        }
        return "";
    }

    /**
     * @dev Returns a random number for a given treasure which is used to
     determine the 'composition' of the treasure. Only called if the treasure
     is opened.
     */
    function __getRandomTreasureComposition(
        uint256 tokenId,
        uint256 treasureX,
        uint256 treasureY
    ) private pure returns (uint256) {
        return
            random(
                string(
                    abi.encodePacked(
                        "COMPOSITION",
                        treasureX,
                        treasureY,
                        Strings.toString(tokenId)
                    )
                )
            ).mod(100);
    }

    /**
     * @dev Returns a composed description of a given treasure. Only called if 
     the treasure is opened.
     */
    function getTreasureContentsDescription(
        uint256 tokenId,
        uint256 treasureX,
        uint256 treasureY
    ) private pure returns (string memory) {
        string[2] memory parts;

        // Either 'Bronze', 'Silver', 'Gold', etc. along with optional
        // multiplier.
        parts[0] = getTreasureMetal(tokenId, treasureX, treasureY);

        // Get a special item (if any).
        string memory specialItem = getTreasureSpecialItem(
            tokenId,
            treasureX,
            treasureY
        );
        if (
            keccak256(abi.encodePacked(specialItem)) !=
            keccak256(abi.encodePacked(""))
        ) {
            parts[1] = string(abi.encodePacked(" + ", specialItem));
        }

        string memory description = string(
            abi.encodePacked(parts[0], parts[1])
        );
        return description;
    }

    /**
     * @dev Returns a string in JSON format for the attributes of the given
     treasure.
     */
    function buildAttributesJSON(
        uint256 tokenId,
        uint256 treasureX,
        uint256 treasureY
    ) private view returns (string memory) {
        string[15] memory parts;
        parts[0] = '[{"trait_type": "Opened", "value": "';
        parts[1] = isTreasureOpened[tokenId] ? "Yes" : "No";
        parts[2] = '"}, {"trait_type": "Weight", "value": "';
        parts[3] = Strings.toString(getTreasureWeight(tokenId));
        parts[4] = '"}, ';
        // These should only be added if the treasure is opened.
        if (isTreasureOpened[tokenId]) {
            parts[5] = '{"trait_type": "Metal", "value": "';
            parts[6] = getTreasureMetal(tokenId, treasureX, treasureY);
            parts[7] = '"}, {"trait_type": "Special Item", "value": "';
            string memory specialItem = getTreasureSpecialItem(
                tokenId,
                treasureX,
                treasureY
            );
            if (
                keccak256(abi.encodePacked(specialItem)) ==
                keccak256(abi.encodePacked(""))
            ) {
                parts[8] = "None";
            } else {
                parts[8] = specialItem;
            }
            parts[9] = '"}, ';
        }
        parts[10] = '{"trait_type": "Claimed with Loot", "value": "';
        parts[11] = discoveredWithLoot[tokenId] == 0
            ? "None"
            : string(
                abi.encodePacked(
                    "Bag #",
                    Strings.toString(discoveredWithLoot[tokenId])
                )
            );
        parts[12] = '"}, {"trait_type": "Wearing", "value": "';
        parts[13] = whileWearing[tokenId];
        parts[14] = '"}]';

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        return
            string(
                abi.encodePacked(
                    output,
                    parts[9],
                    parts[10],
                    parts[11],
                    parts[12],
                    parts[13],
                    parts[14]
                )
            );
    }

    /**
     * @dev Override of tokenURI. Generated fully on-chain dynamically
     building an SVG based on state recorded at token mint and randomness
     based on the token ID and treasure location (tied to token ID).
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(tokenId > 0 && tokenId <= _tokenIds.current());

        string[10] memory parts;
        parts[0] = Svg.__svgAddBegin();

        uint256 textY = 20;

        // Every treasure has a location.
        uint256 treasureX;
        uint256 treasureY;

        (treasureX, , treasureY) = abi.decode(
            coordinates[tokenId],
            (uint256, string, uint256)
        );
        parts[1] = Svg.__svgAddLocation(10, textY, treasureX, treasureY);

        // Every treasure has a random item that the adventurer was wearing
        // when claiming.
        textY += 20;
        parts[2] = Svg.__svgAddWearingItem(10, textY, whileWearing[tokenId]);

        // Add a record of the loot bag if was claimed with Loot.
        if (discoveredWithLoot[tokenId] != 0) {
            textY += 20;
            parts[8] = Svg.__svgAddLootBagRecord(
                10,
                textY,
                discoveredWithLoot[tokenId]
            );
        }

        // Every treasure has a weight.
        textY += 20;
        parts[3] = Svg.__svgAddTreasureWeight(
            10,
            textY,
            getTreasureWeight(tokenId)
        );

        // If the treasure has been opened, then we add the treasure contents and
        // add the description of the contents.
        if (isTreasureOpened[tokenId]) {
            uint256 randComposition = __getRandomTreasureComposition(
                tokenId,
                treasureX,
                treasureY
            );
            parts[4] = Svg.__svgAddTreasureContents(randComposition);
            textY += 20;
            parts[5] = Svg.__svgAddTreasureContentsDescription(
                10,
                textY,
                getTreasureContentsDescription(tokenId, treasureX, treasureY)
            );
        }

        // Every treasure is a chest, though the function will take care of
        // rendering either an opened or closed chest.
        parts[6] = Svg.__svgAddTreasureChest(isTreasureOpened[tokenId]);

        // If a treasure was claimed with an OG 'Loot' bag, add a plaque to
        // the treasure chest.
        if (discoveredWithLoot[tokenId] != 0) {
            parts[7] = Svg.__svgAddTreasureChestPlaque();
        }

        parts[9] = "</svg>";

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8]
            )
        );
        output = string(abi.encodePacked(output, parts[9]));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Treasure Chest #',
                        Strings.toString(tokenId),
                        '", "description": "Treasure Chests are randomly generated treasures scattered and hidden across an island, claimable by any Adventurer.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '", "attributes": ',
                        buildAttributesJSON(tokenId, treasureX, treasureY),
                        "}"
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    /**
     * @dev Returns a random **Synthetic Loot** item for a treasure. This is originally
     computed at mint based on the creator address.
     */
    function getRandomSyntheticLootItem(address creator)
        private
        view
        returns (string memory)
    {
        uint256 rand = random(string(abi.encodePacked(creator))) % 8;
        if (rand == 0) {
            return syntheticLootContract.getChest(creator);
        } else if (rand == 1) {
            return syntheticLootContract.getFoot(creator);
        } else if (rand == 2) {
            return syntheticLootContract.getHand(creator);
        } else if (rand == 3) {
            return syntheticLootContract.getHead(creator);
        } else if (rand == 4) {
            return syntheticLootContract.getNeck(creator);
        } else if (rand == 5) {
            return syntheticLootContract.getRing(creator);
        } else if (rand == 6) {
            return syntheticLootContract.getWaist(creator);
        } else {
            return syntheticLootContract.getWeapon(creator);
        }
    }

    /**
     * @dev Returns a random **Loot** item for a treasure. This is originally
     computed at mint based on the creator address and uses the loot bag
     ID that the creator chose to use to claim the treasure.
     */
    function getRandomLootItem(address creator, uint256 lootBagId)
        private
        view
        returns (string memory)
    {
        // Pick a random number to pick which Loot component to pick.
        // There are a total of 8.
        uint256 rand = random(string(abi.encodePacked(creator))) % 8;

        if (rand == 0) {
            return lootContract.getChest(lootBagId);
        } else if (rand == 1) {
            return lootContract.getFoot(lootBagId);
        } else if (rand == 2) {
            return lootContract.getHand(lootBagId);
        } else if (rand == 3) {
            return lootContract.getHead(lootBagId);
        } else if (rand == 4) {
            return lootContract.getNeck(lootBagId);
        } else if (rand == 5) {
            return lootContract.getRing(lootBagId);
        } else if (rand == 6) {
            return lootContract.getWaist(lootBagId);
        } else {
            return lootContract.getWeapon(lootBagId);
        }
    }

    /**
     * @dev Returns description of the treasure if it was opened,
     otherwise empty string. Wrapper for `getTreasureInfo()`
     */
    function getTreasureDescription(
        uint256 tokenId,
        uint256 treasureX,
        uint256 treasureY
    ) private view returns (string memory) {
        return
            isTreasureOpened[tokenId]
                ? getTreasureContentsDescription(tokenId, treasureX, treasureY)
                : "";
    }

    /**
     * @dev Returns data about a given treasure give the treasure's `itemId`.
            Things that are returned define a treasure:
            -- (x, y) coordinates of treasure
            -- Random Loot item recorded when claiming the treasure
            -- Loot Bag that was used to claim treasure (if any)
            -- Weight of treasure
            -- Description of treasure (if opened, otherwise empty string)
     */
    function getTreasureInfo(uint256 tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            string memory,
            uint256,
            uint256,
            string memory
        )
    {
        require(tokenId > 0 && tokenId <= _tokenIds.current());

        uint256 treasureX;
        uint256 treasureY;

        (treasureX, , treasureY) = abi.decode(
            coordinates[tokenId],
            (uint256, string, uint256)
        );

        return (
            treasureX,
            treasureY,
            whileWearing[tokenId],
            discoveredWithLoot[tokenId],
            getTreasureWeight(tokenId),
            getTreasureDescription(tokenId, treasureX, treasureY)
        );
    }

    /**
     * @dev Utility function. Returns whether or not a given address owns a given Loot 
     bag (specified by `lootBagId`).
     */
    function isOwnerOfLoot(uint256 lootBagId, address account)
        public
        view
        returns (bool)
    {
        return lootContract.ownerOf(lootBagId) == account;
    }

    /**
     * @dev Utility function. Returns how many Loot tokens a given address owns.
     */
    function countLootOwned(address account) public view returns (uint256) {
        return lootContract.balanceOf(account);
    }

    /**
     * @dev Utility function. Returns whether or not a given address has claimed a
     treasure.
     */
    function didClaimTreasure(address account) public view returns (bool) {
        return claimedAddresses[account];
    }

    /**
     * @dev Utility function. Returns whether or not one can still claim a 
     treasure at the given x, y coordinates.
     */
    function isTreasureAvailableToClaim(uint256 treasureX, uint256 treasureY)
        public
        view
        returns (bool)
    {
        // Compute the hash of how we store coordinates in the state.
        bytes32 coordHash = keccak256(
            abi.encodePacked(treasureX, ",", treasureY)
        );
        return !hasLocationBeenDiscovered[coordHash];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <[email protected]>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

{
  "optimizer": {
    "enabled": true,
    "runs": 100
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {
    "contracts/TreasureChests.sol": {
      "Svg": "0x77b919201b8e4eade32a2c23998c401f4437bc89"
    }
  }
}