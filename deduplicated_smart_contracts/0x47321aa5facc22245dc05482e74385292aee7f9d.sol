/**
 *Submitted for verification at Etherscan.io on 2019-07-22
*/

pragma solidity >=0.4.25 <0.6.0;


contract TransferController {
    
    
    
    event CurrencyTransferred(address from, address to, uint256 value,
        address currencyCt, uint256 currencyId);

    
    
    
    function isFungible()
    public
    view
    returns (bool);

    function standard()
    public
    view
    returns (string memory);

    
    function receive(address from, address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    
    function approve(address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    
    function dispatch(address from, address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    

    function getReceiveSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("receive(address,address,uint256,address,uint256)"));
    }

    function getApproveSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("approve(address,uint256,address,uint256)"));
    }

    function getDispatchSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("dispatch(address,address,uint256,address,uint256)"));
    }
}

interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) public view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) public view returns (address owner);

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

contract ERC721TransferController is TransferController {
    
    
    
    string constant _standard = "ERC721";

    
    
    
    function isFungible()
    public
    view
    returns (bool)
    {
        return false;
    }

    function standard()
    public
    view
    returns (string memory)
    {
        return _standard;
    }

    function receive(address from, address to, uint256 id, address currencyCt, uint256 currencyId)
    public
    {
        require(currencyId == 0, "Currency ID is not 0 [ERC721TransferController.sol:46]");

        

        
        emit CurrencyTransferred(from, to, id, currencyCt, currencyId);
    }

    
    function approve(address , uint256 , address , uint256 currencyId)
    public
    {
        require(currencyId == 0, "Currency ID is not 0 [ERC721TransferController.sol:58]");

        
    }

    
    function dispatch(address from, address to, uint256 id, address currencyCt, uint256 currencyId)
    public
    {
        require(currencyId == 0, "Currency ID is not 0 [ERC721TransferController.sol:67]");

        
        

        
        emit CurrencyTransferred(from, to, id, currencyCt, currencyId);
    }
}