/**
 *Submitted for verification at Etherscan.io on 2021-08-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}



pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}


pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}



pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}



pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



pragma solidity ^0.8.0;

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping (uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping (address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
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

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
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

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
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

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}


pragma solidity ^0.8.0;

abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    mapping (uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}



// File @openzeppelin/contracts/utils/[email protected]

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
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
}


// File contracts/Musto.sol

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.8.0;


contract TheUnstableHorsesYard is ERC721URIStorage {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // horse own; 
    address public owner;
    uint public total_No_Tokens = 1000;
    uint public total_No_TokensRemaining = total_No_Tokens;
    uint public total_No_Horses = 999;
    uint public total_No_HorsesRemaining = total_No_Horses;
    uint public owner_Horses = 1;
    uint public owner_HorsesRemaining = owner_Horses;
    uint public nextTokenId = 1;
    uint public maxHorsesMintInOnce = 3;
    uint public price = 30000000000000000;  // 0.03 ETH
    bool public sale  =  true;  // false
    uint256 public startingIpfsId = 0;
    uint256 private _lastIpfsId = 0;
    uint256 public start = 1;
    

    mapping(uint => bool) public exist;


    // farm juice own;
    mapping(address => uint) public farmJuices_Owner;
    mapping(address => bool) public farmJuices_Own;
    uint private FarmJuice_newTokenId = 1000001;
    uint public farmJuices = 1000;
    uint public farmJuicesRemaining = farmJuices;
    uint public farmJuicesTransfered = 0;



    // Breed section;
    uint public total_No_HorsesBreed = 0;
    uint public StartIndex_HorsesBreed = 100000000001;
    uint public NextIndex_HorsesBreed  = StartIndex_HorsesBreed;

    event Minted(address to, uint id, string uri);
    event PriceUpdated(uint newPrice);
    event OwnerUpdated(address newOwner);

    address payable fundWallet;
    string public baseUri ;
    string public FarmJuice_baseUri ;
    string public breed_baseUri ;


 
    constructor(address _fundWallet, string memory _baseUri, string memory _FarmJuice_baseUri, string memory _breed_baseUri) ERC721("The Unstable Horses Yard", "TUHY") {
        owner = msg.sender;
        fundWallet = payable(_fundWallet); 
        baseUri = _baseUri; 
        FarmJuice_baseUri = _FarmJuice_baseUri; 
        breed_baseUri = _breed_baseUri; 
    }

    function fundWalletView() public view returns(address){
        require(msg.sender == owner || msg.sender == fundWallet, "Only owner");
        return fundWallet;
    }  

    function fundWalletUpdate(address _fundWallet) public  returns(address){
        require(msg.sender == owner || msg.sender == fundWallet, "Only owner");
        fundWallet = payable(_fundWallet); 
    }  

    /* Mint Horses only OWNER */
    function mint_owner(address to) public {
        require(msg.sender == owner || msg.sender == fundWallet, "Only owner can transfer");
        require(owner_HorsesRemaining >= 0, "mint token limit exceeds");
        
        if(total_No_Tokens == total_No_TokensRemaining) {
            _lastIpfsId = random(1, total_No_Tokens, uint256(uint160(address(_msgSender()))) + 1);
            startingIpfsId = _lastIpfsId;
        } else {
            _lastIpfsId = getIpfsIdToMint();
        }
        total_No_TokensRemaining--;
        owner_HorsesRemaining--;
        
        require(exist[nextTokenId] == false, "Mint: Token already exist.");
        string memory tokenURI = string(abi.encodePacked(baseUri, uint2str(_lastIpfsId)));
        _mint(to, nextTokenId);
        _setTokenURI(nextTokenId, (tokenURI));
        
        exist[nextTokenId] = true;
        nextTokenId++;
        
    }
    
    /* Mint Horses */
    function mint(uint numberOfMints) public payable {
        require(sale == true, "sale is off");
        require(numberOfMints > 0, "minimum 1 token need to be minted");
        require(numberOfMints <= maxHorsesMintInOnce, "max horses mint limit exceeds");
        require(total_No_HorsesRemaining - numberOfMints >= 0, "mint token limit exceeds, check how many remaining to mint."); //10000 item cap (9900 public + 100 team mints)
        require(msg.value >= price * numberOfMints, "price is not correct.");  //User must pay set price.`
        
		for (uint256 i = 0; i < numberOfMints; i++) {
            if(total_No_Tokens == total_No_TokensRemaining) {
                _lastIpfsId = random(1, total_No_Tokens, uint256(uint160(address(_msgSender()))) + 1);
                startingIpfsId = _lastIpfsId;
            } else {
                _lastIpfsId = getIpfsIdToMint();
            }
            total_No_TokensRemaining--;
            total_No_HorsesRemaining--;
            
            require(exist[nextTokenId] == false, "Mint: Token already exist.");
            string memory tokenURI = string(abi.encodePacked(baseUri, uint2str(_lastIpfsId)));
            _mint(msg.sender, nextTokenId);
            _setTokenURI(nextTokenId, (tokenURI));
            
            exist[nextTokenId] = true;
            nextTokenId++;
        }
        // this(address).transfer(msg.value);
    }


    
    /* Farm Juice */
    function farmJuice_Mint(address player) public {  // there is no fund transfer because only  owner can mint FARM Juices. 
        require(msg.sender == owner || msg.sender == fundWallet, "Only owner can mint");
        require(farmJuicesRemaining > 0, "All farm juices  transfered."); 
        require(farmJuices_Own[player] == false, "User already own farmJuice"); 
        
        farmJuicesRemaining--;
        farmJuicesTransfered++;
        farmJuices_Owner[player] = FarmJuice_newTokenId;
        farmJuices_Own[player] = true;
        
        string memory FarmJuice_URI = string(abi.encodePacked(FarmJuice_baseUri));
            
        _mint(player, FarmJuice_newTokenId);
        _setTokenURI(FarmJuice_newTokenId, FarmJuice_URI);
        
        FarmJuice_newTokenId++;
    }

    /* Breed Horse */
    function Breed(address player, uint token1_ID, uint token2_ID) public {
        require(farmJuices_Own[msg.sender] == true, "User should own farm Juice for Breeding"); 
        require(ownerOf(token1_ID) == msg.sender, "User should own Token 1"); 
        require(ownerOf(token2_ID) == msg.sender, "User should own Token 2"); 
        
         string memory tokenURI = string(abi.encodePacked(breed_baseUri, uint2str(NextIndex_HorsesBreed)));
        _mint(player, NextIndex_HorsesBreed);
        _setTokenURI(NextIndex_HorsesBreed, tokenURI);
        
        NextIndex_HorsesBreed += 1;
        total_No_HorsesBreed +=  1;

        burn(token1_ID);
        burn(token2_ID);
    }
    
    

    //random number
	function random( uint256 from, uint256 to, uint256 salty ) private view returns (uint256) {
		uint256 seed =
			uint256(
				keccak256(
					abi.encodePacked(
						block.timestamp +
							block.difficulty +
							((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
							block.gaslimit +
							((uint256(keccak256(abi.encodePacked(_msgSender())))) / (block.timestamp)) +
							block.number +
							salty
					)
				)
			);
		
		uint randomData = 0;
		if( (seed.mod(to - from) + from) <= total_No_Horses ){
		    randomData = seed.mod(to - from) + from;
		} else {
		    randomData = total_No_Horses / 2;
		}
		return randomData;
	}
	
    function getIpfsIdToMint() public view returns(uint256 _nextIpfsId) {
        require(total_No_TokensRemaining > 0, "All tokens have been minted");
        
        if(_lastIpfsId == total_No_Tokens && nextTokenId < total_No_Tokens) {
            _nextIpfsId = start;   // 2
        } else if(nextTokenId <= total_No_Tokens) {
            _nextIpfsId = _lastIpfsId + 1;
        }
    }
	
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
		if (_i == 0) {
			return "0";
		}
		uint256 j = _i;
		uint256 len;
		while (j != 0) {
			len++;
			j /= 10;
		}
		bytes memory bstr = new bytes(len);
		uint256 k = len;
		while (_i != 0) {
			k = k - 1;
			uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
			bytes1 b1 = bytes1(temp);
			bstr[k] = b1;
			_i /= 10;
		}
		return string(bstr);
	}	
    
    function update_FarmJuice_URI(string memory newFarmJuice_URI) public{
      require(msg.sender == owner || msg.sender == fundWallet, "only owner");
      FarmJuice_baseUri = newFarmJuice_URI;
    }
    
    function update_FarmJuice_limit(uint  add_newTokens) public{
        require(msg.sender == owner || msg.sender == fundWallet, "Only owner");
        farmJuices += add_newTokens; 
        farmJuicesRemaining += add_newTokens;
    }
    
    function burn(uint256 _tokenId) public {
        require(_exists(_tokenId), "Burn: token does not exist.");
        require(ownerOf(_tokenId) == _msgSender(), "Burn: caller is not token owner.");
        _burn(_tokenId);
    }
        
    function balancer() public view returns (uint256){
        return address(this).balance;
    }
    
    function update_Tokens_Limit(uint add_newTokens) public{
      require(msg.sender == owner || msg.sender == fundWallet, "Only owner");
      
      start = total_No_Tokens + 1;
      _lastIpfsId = total_No_Tokens;
      total_No_Tokens += add_newTokens ;
      total_No_Horses += (add_newTokens - 99) ;
      total_No_TokensRemaining += add_newTokens;
      total_No_HorsesRemaining = (add_newTokens - 99);
      price = 40000000000000000;  // 0.04 ETH
      maxHorsesMintInOnce = 15;
      
      owner_Horses += 99;
      owner_HorsesRemaining += 99;
    }

    function update_Mint_per_Tx(uint _num) public{
      require(msg.sender == owner || msg.sender == fundWallet, "Only owner");
      maxHorsesMintInOnce = _num;
    }

    function update_Owner(address newOwner) public{
      require(msg.sender == owner || msg.sender == fundWallet);
      owner = newOwner;
      emit OwnerUpdated(newOwner);
    }

    function update_price(uint newprice) public{
      require(msg.sender == owner || msg.sender == fundWallet);
      price = newprice;
      emit PriceUpdated(newprice);
    }

    function changeSale() public{
      require(msg.sender == owner || msg.sender == fundWallet);
      sale = !sale;
    }

    function withdraw() public{
        require(msg.sender == owner || msg.sender == fundWallet, "Only owner");
        payable(fundWallet).transfer(address(this).balance);
    }
    function update_URI(string memory new_URI) public{ 
      require(msg.sender == owner || msg.sender == fundWallet, "only owner"); 
       baseUri = new_URI; 
    }
}