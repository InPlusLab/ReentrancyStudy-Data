/**
 *Submitted for verification at Etherscan.io on 2021-09-10
*/

// SPDX-License-Identifier: MIT

/**
    Built on (LOOT) - MIT license
    By [email protected]
*/

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
	// WARNING: Usage of transferFrom method is discouraged, use {safeTransferFrom} whenever possible.
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
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

abstract contract ReentrancyGuard {
	
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
	
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
	
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
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
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

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

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; 
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId;
        _allTokensIndex[lastTokenId] = tokenIndex;

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}


contract LootParty is ERC721Enumerable, ReentrancyGuard, Ownable {
	
	string[] private locationSettingPrefix = [
		"Ancient ", 
		"Boring ", 
		"Ominous ", 
		"Haunted ", 
		"Sacred ", 
		"Bleak ", 
		"Majestic ", 
		"Mystical "
	];

	string[] private locationSetting = [
		"Royal Castle ",
		"Peasant Farm ", 
		"Town Tavern ", 
		"Brothel House ", 
		"Feast of Fools ", 
		"Parish Church ", 
		"Royal Court ", 
		"Masquerade Ball ", 
		"Pirate&#39;s Cove ", 
		"Noble Banquet ", 
		"Black Death Music Party ", 
		"Prisoner&#39;s Base ",
		"Jousting Tournament ", 
		"Hilltop Church ", 
		"Traveller&#39;s Inn "
	];

	string[] private characterPrefix = [
		"Royal ", 
		"Holy ", 
		"Cursed ", 
		"Zealous ", 
		"Humble ", 
		"Modest ", 
		"Loyal ", 
		"Naughty "
	];

	string[] private character = [
		"King of Fools ", 
		"Boy Bishop ", 
		"Court Jester ", 
		"Crown Prince ", 
		"Noble Lady ", 
		"Gong Farmer ", 
		"High Church Priest ", 
		"Farm Goat ", 
		"Enlightened Monk ", 
		"Plague Doctor ", 
		"Statesman ", 
		"Noble Servant ", 
		"Noble Savage ", 
		"Armed Guard ", 
		"Charlatan ", 
		"Black Cat ", 
		"Virgin Prophet ", 
		"Mad King ",
		"Pope of Fools ",
		"King of the Feast "
	];

	string[] private costumePrefix = [
		"Velvet Red ", 
		"Royal Purple ", 
		"Murky Brown ", 
		"Deep Blue ", 
		"Midnight Black ", 
		"Off-White ", 
		"Neon Green ", 
		"Golden Yellow "
	];

	string[] private costume = [
		"Homespun Dress ",
		"Invisible Cloak ", 
		"Military Uniform ", 
		"Scholarly Robe ", 
		"Baggy Outfit ", 
		"Fitted Jacket ", 
		"Puffy Shorts ",
		"Clown Costume ",
		"Embroidered Mantle ",
		"Silk Veil "
	];

	string[] private foodPrefix = [
		"Roasted ", 
		"Stuffed ", 
		"Raw ", 
		"Marinated ", 
		"Baked ", 
		"Poached ", 
		"Deep Fried ", 
		"Boiled ", 
		"Glazed ", 
		"Smoked "
	];

	string[] private food = [
		"Turkey Leg ", 
		"Swan ", 
		"Peacock ", 
		"Salmon ", 
		"Boar's Sead ", 
		"Partridge ", 
		"Mallard ", 
		"Chicken " 
	];

	string[] private foodSuffix = [
		"Al Dente ", 
		"Au Fromage ", 
		"Deluxe ", 
		"A La King ", 
		"with Rice ", 
		"with Milk ", 
		"with Honey ", 
		"with Extra Guac "
	];

	string[] private drink = [
		"Sweet Wine ", 
		"Mulled Wine ", 
		"Ale ", 
		"Mead ", 
		"Beer ", 
		"Stale Ale ",
		"Aqua Vitae ", 
		"Eggnog ", 
		"Bride Ale ",
		"Mulberry Gin ", 
		"Blackberry Wine "
	];

	string[] private drinkPrefix = [
		"Cold ", 
		"Small ", 
		"Light ", 
		"Heavy ", 
		"Balanced ", 
		"Fruity ", 
		"Earthy ", 
		"Mineral "
	];

	string[] private music = [
		"Song of Spring ",
		"Ballata of Beauty ",
		"Gregorian Chant ",
		"Melodic Hymn ",
		"Royal Orchestra ",
		"Monk Choir ",
		"Taverwave Trap ",
		"Bardcore Rap "
	];

	string[] private entertainment = [
		"Acrobat Dancer ", 
		"Juggler ", 
		"Harper ", 
		"Bard ", 
		"Minstrel ",
		"Mummer ",
		"Jester ",
		"Puppet ", 
		"Troubadour ", 
		"Strolling Player ",
		"Clown "
	];

	string[] private entertainmentPrefix = [
		"Happy ", 
		"Sad ", 
		"Common ", 
		"Special ", 
		"Legendary "
	];

	string[] private club = [
		"The Liturgy of the Drunkards ", 
		"The Liturgy of the Gamblers ", 
		"The Will of the Ass ", 
		"The Path of the One ", 
		"Abbeys of the Fools ",  
		"Drunken Synod of Fools ", 
		"United Church of Wine ", 
		"Lady of Perpetual Exemption "
	];

	string[] private globalSuffix = [
	    "Belli ",
	    "Primigenia ",
	    "Redux ",
	    "Victrix ",
	    "Augusta ",
	    "Balnearis ",
	    "Huiusce Diei ",
	    "Obsequens ",
	    "Privata ",
	    "Publica ",
	    "Faitrix ",
	    "Virgo ",
	    "Annonaria ",
	    "Muliebris ",
	    "Equestris ",
	    "Barbata "
	];
	
	string[] private enchantment = [
	    "+1 "
	];
	
	
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
	
	function concatStrings(string memory stringOne, string memory stringTwo) internal pure returns (string memory) {
	    return string(abi.encodePacked(stringOne, stringTwo));
	} 
	
    function pluckTwo(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray, uint256 percentageChance) internal pure returns (string memory) {
        string memory output = "";
		uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));
		uint256 greatness = rand % 101; // inclusive between 1 to 100
		if(greatness <= percentageChance){
			output = sourceArray[rand % sourceArray.length];
		}
        return output;
    }
	
/**
	function getLocation(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
	    output = concatStrings(output, pluckTwo(tokenId, "LOCATIONPREFIX", locationSettingPrefix, 100));
	    output = concatStrings(output, pluckTwo(tokenId, "LOCATIONMAIN", locationSetting, 100));
	    output = concatStrings(output, pluckTwo(tokenId, "LOCATIONSUFFIX", globalSuffix, 100));
	    output = concatStrings(output, pluckTwo(tokenId, "LOCATIONGLOBALSUFFIX", globalSuffix, 100));
	    output = concatStrings(output, pluckTwo(tokenId, "LOCATIONENCHANTMENT", enchantment, 5));
		return output;
	}
*/
	
	// locationSettingPrefix, locationSetting

    function getLocation(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
        output = concatStrings(output, pluckTwo(tokenId, "LOCATIONPREFIX", locationSettingPrefix, 9));
        output = concatStrings(output, pluckTwo(tokenId, "LOCATIONMAIN", locationSetting, 100));
        output = concatStrings(output, pluckTwo(tokenId, "LOCATIONGLOBALSUFFIX", globalSuffix, 15));
		return output;
    }

	// characterPrefix, character
	
    function getCharacter(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
        output = concatStrings(output, pluckTwo(tokenId, "CHARACTERPREFIX", characterPrefix, 9));
        output = concatStrings(output, pluckTwo(tokenId, "CHARACTERMAIN", character, 100));
        output = concatStrings(output, pluckTwo(tokenId, "CHARACTERGLOBALSUFFIX", globalSuffix, 15));
		return output;
    }
	

	// costumePrefix, costume

    function getCostume(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
        output = concatStrings(output, pluckTwo(tokenId, "COSTUMEPREFIX", costumePrefix, 9));
        output = concatStrings(output, pluckTwo(tokenId, "COSTUMEMAIN", costume, 100));
        output = concatStrings(output, pluckTwo(tokenId, "COSTUMEGLOBALSUFFIX", globalSuffix, 15));
		output = concatStrings(output, pluckTwo(tokenId, "COSTUMENENCHANTMENT", enchantment, 5));
		return output;
    }

	// foodPrefix, food, foodSuffix
	
    function getFood(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
        output = concatStrings(output, pluckTwo(tokenId, "FOODPREFIX", foodPrefix, 9));
        output = concatStrings(output, pluckTwo(tokenId, "FOODMAIN", food, 100));
	    output = concatStrings(output, pluckTwo(tokenId, "FOODSUFFIX", foodSuffix, 42));
		 output = concatStrings(output, pluckTwo(tokenId, "FOODENCHANTMENT", enchantment, 5));
		return output;
    }

	// drink, drinkPrefix
	
    function getDrink(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
        output = concatStrings(output, pluckTwo(tokenId, "DRINKPREFIX", drinkPrefix, 9));
        output = concatStrings(output, pluckTwo(tokenId, "DRINKMAIN", drink, 100));
		 output = concatStrings(output, pluckTwo(tokenId, "DRINKENCHANTMENT", enchantment, 5));
		return output;
    }

	// music
	
    function getMusic(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
        output = concatStrings(output, pluckTwo(tokenId, "MUSICMAIN", music, 100));
		return output;
    }


	// entertainment, entertainmentPrefix
	
    function getEntertainment(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
        output = concatStrings(output, pluckTwo(tokenId, "ENTERTAINMENTPREFIX", entertainmentPrefix, 9));
        output = concatStrings(output, pluckTwo(tokenId, "ENTERTAINMENTMAIN", entertainment, 100));
        output = concatStrings(output, pluckTwo(tokenId, "ENTERTAINMENTGLOBALSUFFIX", globalSuffix, 15));
		return output;
    }

	// club

    function getClub(uint256 tokenId) public view returns (string memory) {
		string memory output = "";
        output = concatStrings(output, pluckTwo(tokenId, "CLUBMAIN", club, 100));
		return output;
    }
	
    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string[17] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = getLocation(tokenId);

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = getCharacter(tokenId);

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = getCostume(tokenId);

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = getFood(tokenId);

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = getDrink(tokenId);

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = getMusic(tokenId);

        parts[12] = '</text><text x="10" y="140" class="base">';

        parts[13] = getEntertainment(tokenId);

        parts[14] = '</text><text x="10" y="160" class="base">';

        parts[15] = getClub(tokenId);

        parts[16] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15], parts[16]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Party #', toString(tokenId), '", "description": "A randomized party generated and stored on chain. Stats, images, and other functionality are intentionally omitted for others to interpret. Feel free to use loot party in any way you want.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function claim(uint256 tokenId) public nonReentrant {
        require(tokenId > 0 && tokenId < 7778, "Token ID invalid");
        _safeMint(_msgSender(), tokenId);
    }
    
    function ownerClaim(uint256 tokenId) public nonReentrant onlyOwner {
        require(tokenId > 7777 && tokenId < 8001, "Token ID invalid");
        _safeMint(owner(), tokenId);
    }
    
    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
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
    
    constructor() ERC721("LootParty", "LOOTPARTY") Ownable() {}
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <[email protected]>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

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
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
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