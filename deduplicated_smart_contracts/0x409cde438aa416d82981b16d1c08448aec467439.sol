pragma solidity ^0.5.5;

import "./ERC721.sol";
import "./Ownable.sol";

contract TokenWarranty is ERC721, Ownable {

    address private minter;
    address private holder;
    address private pooler;
    
    /*** EVENTS ***/
    event NewMaterial(
        uint256 indexed _tokenId,
        address indexed _owner
    );
    
    /*** DATA TYPES ***/
    struct Material {
        string creator;
        string fileName;
        string material_code;
        uint256 createTime;
    }
    
    Material[] public materials;
    
    mapping (uint256 => string) public certhash;
    mapping (uint256 => string) public trimhash;
    mapping (uint256 => string) public tokenURI;
    mapping (uint256 => string) public ownerContact;
    mapping (uint256 => bool) public isSell;
    
    constructor() public ERC721("TokenWarranty", "TWT") {}
    
    modifier onlyHolder() {
        require(msg.sender == holder);
        _;
    }

    modifier onlyMinter() {
        require(msg.sender == minter);
        _;
    }    
    
    /*** FUNCTIONS ***/
    function setHolder(address _requestor) public {
        if(holder==address(0)){
            require(msg.sender == _owner);
            holder = _requestor;
        } else {
            require(msg.sender == holder);
            holder = _requestor;
        }
    }    

    function setMinter(address _requestor) public {
        if(minter==address(0)){
            require(msg.sender == _owner);
            minter = _requestor;
        } else {
            require(msg.sender == minter);
            minter = _requestor;
        }
    }
    
    function setPooler(address _requestor) public {
        if(pooler==address(0)){
            require(msg.sender == _owner);
            pooler = _requestor;
        } else {
            require(msg.sender == holder);
            pooler = _requestor;
        }
    }

    function setHash(uint256 tokenId, string memory hash) public {
        require(msg.sender == _tokenOwner[tokenId] || msg.sender == holder);
        certhash[tokenId] = hash;
    }
    
    function setSold(uint256 tokenId) public onlyHolder {
        require(isSell[tokenId] == true);
        isSell[tokenId] = false;
    }
    
    function setTrim(uint256 tokenId, string memory hash) public {
        require(msg.sender == _tokenOwner[tokenId] || msg.sender == holder);
        trimhash[tokenId] = hash;
    }  
    
    function setURI(uint256 tokenId, string memory hash) public {
        require(msg.sender == _tokenOwner[tokenId] || msg.sender == holder);
        tokenURI[tokenId] = hash;
    }
    
    function resetSell(uint256 tokenId) onlyHolder public {
        isSell[tokenId] = false;
    }
    
    function setContact(uint256 tokenId, string memory mails) public onlyHolder {
        require(isSell[tokenId] == false);
        ownerContact[tokenId] = mails;
        isSell[tokenId] = true;
    }
    
    function getHolder() onlyOwner external view returns (address) {
        return holder;
    }    
    
    function getMinter() onlyOwner external view returns (address) {
        return minter;
    }     
    
    /// create token functions ///
    function create(string memory _name, string memory _file, string memory _matID) public onlyMinter {
        uint256 id = materials.push(Material(_name, _file, _matID, now)) - 1;
        _tokenOwner[id] = pooler;
        isSell[id] = false;
        _ownedTokensCount[pooler].increment();
        emit NewMaterial(id, pooler);
    }    

}


