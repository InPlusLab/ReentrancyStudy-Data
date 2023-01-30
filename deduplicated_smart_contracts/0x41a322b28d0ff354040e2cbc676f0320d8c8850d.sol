/**

 *Submitted for verification at Etherscan.io on 2019-05-13

*/



pragma solidity ^0.4.18;







/**

 * @title ERC721 interface

 * @dev see https://github.com/ethereum/eips/issues/721

 */

contract ERC721 {

  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);



  function balanceOf(address _owner) public view returns (uint256 _balance);

  function ownerOf(uint256 _tokenId) public view returns (address _owner);

  function transfer(address _to, uint256 _tokenId) public;

  function approve(address _to, uint256 _tokenId) public;

  function takeOwnership(uint256 _tokenId) public;

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  /**

  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}





/**

 * @title ERC721Token

 * Generic implementation for the required functionality of the ERC721 standard

 */

contract ERC721Token is ERC721 {

  using SafeMath for uint256;



  // Total amount of tokens

  uint256 private totalTokens;



  // Mapping from token ID to owner

  mapping (uint256 => address) private tokenOwner;



  // Mapping from token ID to approved address

  mapping (uint256 => address) private tokenApprovals;



  // Mapping from owner to list of owned token IDs

  mapping (address => uint256[]) private ownedTokens;



  // Mapping from token ID to index of the owner tokens list

  mapping(uint256 => uint256) private ownedTokensIndex;



  /**

  * @dev Guarantees msg.sender is owner of the given token

  * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender

  */

  modifier onlyOwnerOf(uint256 _tokenId) {

    require(ownerOf(_tokenId) == msg.sender);

    _;

  }



  /**

  * @dev Gets the total amount of tokens stored by the contract

  * @return uint256 representing the total amount of tokens

  */

  function totalSupply() public view returns (uint256) {

    return totalTokens;

  }



  /**

  * @dev Gets the balance of the specified address

  * @param _owner address to query the balance of

  * @return uint256 representing the amount owned by the passed address

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return ownedTokens[_owner].length;

  }



  /**

  * @dev Gets the list of tokens owned by a given address

  * @param _owner address to query the tokens of

  * @return uint256[] representing the list of tokens owned by the passed address

  */

  function tokensOf(address _owner) public view returns (uint256[]) {

    return ownedTokens[_owner];

  }



  /**

  * @dev Gets the owner of the specified token ID

  * @param _tokenId uint256 ID of the token to query the owner of

  * @return owner address currently marked as the owner of the given token ID

  */

  function ownerOf(uint256 _tokenId) public view returns (address) {

    address owner = tokenOwner[_tokenId];

    require(owner != address(0));

    return owner;

  }



  /**

   * @dev Gets the approved address to take ownership of a given token ID

   * @param _tokenId uint256 ID of the token to query the approval of

   * @return address currently approved to take ownership of the given token ID

   */

  function approvedFor(uint256 _tokenId) public view returns (address) {

    return tokenApprovals[_tokenId];

  }



  /**

  * @dev Transfers the ownership of a given token ID to another address

  * @param _to address to receive the ownership of the given token ID

  * @param _tokenId uint256 ID of the token to be transferred

  */

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {

    clearApprovalAndTransfer(msg.sender, _to, _tokenId);

  }



  /**

  * @dev Approves another address to claim for the ownership of the given token ID

  * @param _to address to be approved for the given token ID

  * @param _tokenId uint256 ID of the token to be approved

  */

  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {

    address owner = ownerOf(_tokenId);

    require(_to != owner);

    if (approvedFor(_tokenId) != 0 || _to != 0) {

      tokenApprovals[_tokenId] = _to;

      Approval(owner, _to, _tokenId);

    }

  }



  /**

  * @dev Claims the ownership of a given token ID

  * @param _tokenId uint256 ID of the token being claimed by the msg.sender

  */

  function takeOwnership(uint256 _tokenId) public {

    require(isApprovedFor(msg.sender, _tokenId));

    clearApprovalAndTransfer(ownerOf(_tokenId), msg.sender, _tokenId);

  }



  /**

  * @dev Mint token function

  * @param _to The address that will own the minted token

  * @param _tokenId uint256 ID of the token to be minted by the msg.sender

  */

  function _mint(address _to, uint256 _tokenId) internal {

    require(_to != address(0));

    addToken(_to, _tokenId);

    Transfer(0x0, _to, _tokenId);

  }



  /**

  * @dev Burns a specific token

  * @param _tokenId uint256 ID of the token being burned by the msg.sender

  */

  function _burn(uint256 _tokenId) onlyOwnerOf(_tokenId) internal {

    if (approvedFor(_tokenId) != 0) {

      clearApproval(msg.sender, _tokenId);

    }

    removeToken(msg.sender, _tokenId);

    Transfer(msg.sender, 0x0, _tokenId);

  }



  /**

   * @dev Tells whether the msg.sender is approved for the given token ID or not

   * This function is not private so it can be extended in further implementations like the operatable ERC721

   * @param _owner address of the owner to query the approval of

   * @param _tokenId uint256 ID of the token to query the approval of

   * @return bool whether the msg.sender is approved for the given token ID or not

   */

  function isApprovedFor(address _owner, uint256 _tokenId) internal view returns (bool) {

    return approvedFor(_tokenId) == _owner;

  }



  /**

  * @dev Internal function to clear current approval and transfer the ownership of a given token ID

  * @param _from address which you want to send tokens from

  * @param _to address which you want to transfer the token to

  * @param _tokenId uint256 ID of the token to be transferred

  */

  function clearApprovalAndTransfer(address _from, address _to, uint256 _tokenId) internal {

    require(_to != address(0));

    require(_to != ownerOf(_tokenId));

    require(ownerOf(_tokenId) == _from);



    clearApproval(_from, _tokenId);

    removeToken(_from, _tokenId);

    addToken(_to, _tokenId);

    Transfer(_from, _to, _tokenId);

  }



  /**

  * @dev Internal function to clear current approval of a given token ID

  * @param _tokenId uint256 ID of the token to be transferred

  */

  function clearApproval(address _owner, uint256 _tokenId) private {

    require(ownerOf(_tokenId) == _owner);

    tokenApprovals[_tokenId] = 0;

    Approval(_owner, 0, _tokenId);

  }



  /**

  * @dev Internal function to add a token ID to the list of a given address

  * @param _to address representing the new owner of the given token ID

  * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address

  */

  function addToken(address _to, uint256 _tokenId) private {

    require(tokenOwner[_tokenId] == address(0));

    tokenOwner[_tokenId] = _to;

    uint256 length = balanceOf(_to);

    ownedTokens[_to].push(_tokenId);

    ownedTokensIndex[_tokenId] = length;

    totalTokens = totalTokens.add(1);

  }



  /**

  * @dev Internal function to remove a token ID from the list of a given address

  * @param _from address representing the previous owner of the given token ID

  * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address

  */

  function removeToken(address _from, uint256 _tokenId) private {

    require(ownerOf(_tokenId) == _from);



    uint256 tokenIndex = ownedTokensIndex[_tokenId];

    uint256 lastTokenIndex = balanceOf(_from).sub(1);

    uint256 lastToken = ownedTokens[_from][lastTokenIndex];



    tokenOwner[_tokenId] = 0;

    ownedTokens[_from][tokenIndex] = lastToken;

    ownedTokens[_from][lastTokenIndex] = 0;

    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to

    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping

    // the lastToken to the first position, and then dropping the element placed in the last position of the list



    ownedTokens[_from].length--;

    ownedTokensIndex[_tokenId] = 0;

    ownedTokensIndex[lastToken] = tokenIndex;

    totalTokens = totalTokens.sub(1);

  }

}







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() public {

    owner = msg.sender;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));

    OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension

/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

///  Note: the ERC-165 identifier for this interface is 0x5b5e139f

interface ERC721Metadata /* is ERC721 */ {

  /// @notice A descriptive name for a collection of NFTs in this contract

  function name() external pure returns (string _name);



  /// @notice An abbreviated name for NFTs in this contract

  function symbol() external pure returns (string _symbol);



  /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.

  /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC

  ///  3986. The URI may point to a JSON file that conforms to the "ERC721

  ///  Metadata JSON Schema".

  function tokenURI(uint256 _tokenId) external view returns (string);

}





contract SupeRare is ERC721Token, Ownable, ERC721Metadata {

    using SafeMath for uint256;

    

    // Percentage to owner of SupeRare. (* 10) to allow for < 1% 

    uint256 public maintainerPercentage = 30; 

    

    // Percentage to creator of artwork. (* 10) to allow for tens decimal. 

    uint256 public creatorPercentage = 100; 

    

    // Mapping from token ID to the address bidding

    mapping(uint256 => address) private tokenBidder;



    // Mapping from token ID to the current bid amount

    mapping(uint256 => uint256) private tokenCurrentBid;

    

    // Mapping from token ID to the owner sale price

    mapping(uint256 => uint256) private tokenSalePrice;



    // Mapping from token ID to the creator's address

    mapping(uint256 => address) private tokenCreator;

  

    // Mapping from token ID to the metadata uri

    mapping(uint256 => string) private tokenToURI;

    

    // Mapping from metadata uri to the token ID

    mapping(string => uint256) private uriOriginalToken;

    

    // Mapping from token ID to whether the token has been sold before.

    mapping(uint256 => bool) private tokenSold;



    // Mapping of address to boolean indicating whether the add

    mapping(address => bool) private creatorWhitelist;





    event WhitelistCreator(address indexed _creator);

    event Bid(address indexed _bidder, uint256 indexed _amount, uint256 indexed _tokenId);

    event AcceptBid(address indexed _bidder, address indexed _seller, uint256 _amount, uint256 indexed _tokenId);

    event CancelBid(address indexed _bidder, uint256 indexed _amount, uint256 indexed _tokenId);

    event Sold(address indexed _buyer, address indexed _seller, uint256 _amount, uint256 indexed _tokenId);

    event SalePriceSet(uint256 indexed _tokenId, uint256 indexed _price);



    /**

     * @dev Guarantees _uri has not been used with a token already

     * @param _uri string of the metadata uri associated with the token

     */

    modifier uniqueURI(string _uri) {

        require(uriOriginalToken[_uri] == 0);

        _;

    }



    /**

     * @dev Guarantees msg.sender is not the owner of the given token

     * @param _tokenId uint256 ID of the token to validate its ownership does not belongs to msg.sender

     */

    modifier notOwnerOf(uint256 _tokenId) {

        require(ownerOf(_tokenId) != msg.sender);

        _;

    }



    /**

     * @dev Guarantees msg.sender is a whitelisted creator of SupeRare

     */

    modifier onlyCreator() {

        require(creatorWhitelist[msg.sender] == true);

        _;

    }



    /**

     * @dev Transfers the ownership of a given token ID to another address.

     * Sets the token to be on its second sale.

     * @param _to address to receive the ownership of the given token ID

     * @param _tokenId uint256 ID of the token to be transferred

     */

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {

        tokenSold[_tokenId] = true;

        tokenSalePrice[_tokenId] = 0;

        clearApprovalAndTransfer(msg.sender, _to, _tokenId);

    }



    /**

     * @dev Adds a new unique token to the supply

     * @param _uri string metadata uri associated with the token

     */

    function addNewToken(string _uri) public uniqueURI(_uri) onlyCreator {

        uint256 newId = createToken(_uri, msg.sender);

        uriOriginalToken[_uri] = newId;

    }



    /**

     * @dev Adds a new unique token to the supply with N editions. The sale price is set for all editions

     * @param _uri string metadata uri associated with the token.

     * @param _editions uint256 number of editions to create.

     * @param _salePrice uint256 wei price of editions.

     */

    function addNewTokenWithEditions(string _uri, uint256 _editions, uint256 _salePrice) public uniqueURI(_uri) onlyCreator {

      uint256 originalId = createToken(_uri, msg.sender);

      uriOriginalToken[_uri] = originalId;



      for (uint256 i=0; i<_editions; i++){

        uint256 newId = createToken(_uri, msg.sender);

        tokenSalePrice[newId] = _salePrice;

        SalePriceSet(newId, _salePrice);

      }

    }



    /**

    * @dev Bids on the token, replacing the bid if the bid is higher than the current bid. You cannot bid on a token you already own.

    * @param _tokenId uint256 ID of the token to bid on

    */

    function bid(uint256 _tokenId) public payable notOwnerOf(_tokenId) {

        require(isGreaterBid(_tokenId));

        returnCurrentBid(_tokenId);

        tokenBidder[_tokenId] = msg.sender;

        tokenCurrentBid[_tokenId] = msg.value;

        Bid(msg.sender, msg.value, _tokenId);

    }



    /**

     * @dev Accept the bid on the token, transferring ownership to the current bidder and paying out the owner.

     * @param _tokenId uint256 ID of the token with the standing bid

     */

    function acceptBid(uint256 _tokenId) public onlyOwnerOf(_tokenId) {

        uint256 currentBid = tokenCurrentBid[_tokenId];

        address currentBidder = tokenBidder[_tokenId];

        address tokenOwner = ownerOf(_tokenId);

        address creator = tokenCreator[_tokenId];

        clearApprovalAndTransfer(msg.sender, currentBidder, _tokenId);

        payout(currentBid, owner, creator, tokenOwner, _tokenId);

        clearBid(_tokenId);

        AcceptBid(currentBidder, tokenOwner, currentBid, _tokenId);

        tokenSalePrice[_tokenId] = 0;

    }

    

    /**

     * @dev Cancels the bid on the token, returning the bid amount to the bidder.

     * @param _tokenId uint256 ID of the token with a bid

     */

    function cancelBid(uint256 _tokenId) public {

        address bidder = tokenBidder[_tokenId];

        require(msg.sender == bidder);

        uint256 bidAmount = tokenCurrentBid[_tokenId];

        msg.sender.transfer(bidAmount);

        clearBid(_tokenId);

        CancelBid(bidder, bidAmount, _tokenId);

    }

    

    /**

     * @dev Purchase the token if there is a sale price; transfers ownership to buyer and pays out owner.

     * @param _tokenId uint256 ID of the token to be purchased

     */

    function buy(uint256 _tokenId) public payable notOwnerOf(_tokenId) {

        uint256 salePrice = tokenSalePrice[_tokenId];

        uint256 sentPrice = msg.value;

        address buyer = msg.sender;

        address tokenOwner = ownerOf(_tokenId);

        address creator = tokenCreator[_tokenId];

        require(salePrice > 0);

        require(sentPrice >= salePrice);

        returnCurrentBid(_tokenId);

        clearBid(_tokenId);

        clearApprovalAndTransfer(tokenOwner, buyer, _tokenId);

        payout(sentPrice, owner, creator, tokenOwner, _tokenId);

        tokenSalePrice[_tokenId] = 0;

        Sold(buyer, tokenOwner, sentPrice, _tokenId);

    }



    /**

     * @dev Set the sale price of the token

     * @param _tokenId uint256 ID of the token with the standing bid

     */

    function setSalePrice(uint256 _tokenId, uint256 _salePrice) public onlyOwnerOf(_tokenId) {

        uint256 currentBid = tokenCurrentBid[_tokenId];

        require(_salePrice > currentBid);

        tokenSalePrice[_tokenId] = _salePrice;

        SalePriceSet(_tokenId, _salePrice);

    }



    /**

     * @dev Adds the provided address to the whitelist of creators

     * @param _creator address to be added to the whitelist

     */

    function whitelistCreator(address _creator) public onlyOwner {

      creatorWhitelist[_creator] = true;

      WhitelistCreator(_creator);

    }

    

    /**

     * @dev Set the maintainer Percentage. Needs to be 10 * target percentage

     * @param _percentage uint256 percentage * 10.

     */

    function setMaintainerPercentage(uint256 _percentage) public onlyOwner() {

       maintainerPercentage = _percentage;

    }

    

    /**

     * @dev Set the creator Percentage. Needs to be 10 * target percentage

     * @param _percentage uint256 percentage * 10.

     */

    function setCreatorPercentage(uint256 _percentage) public onlyOwner() {

       creatorPercentage = _percentage;

    }

    

    /**

     * @notice A descriptive name for a collection of NFTs in this contract

     */

    function name() external pure returns (string _name) {

        return 'SupeRare';

    }



    /**

     * @notice An abbreviated name for NFTs in this contract

     */

    function symbol() external pure returns (string _symbol) {

        return 'SUPR';

    }



    /**

     * @notice approve is not a supported function for this contract

     */

    function approve(address _to, uint256 _tokenId) public {

        revert();

    }



    /** 

     * @dev Returns whether the creator is whitelisted

     * @param _creator address to check

     * @return bool 

     */

    function isWhitelisted(address _creator) external view returns (bool) {

      return creatorWhitelist[_creator];

    }



    /** 

     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.

     * @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC

     * 3986. The URI may point to a JSON file that conforms to the "ERC721

     * Metadata JSON Schema".

     */

    function tokenURI(uint256 _tokenId) external view returns (string) {

        ownerOf(_tokenId);

        return tokenToURI[_tokenId];

    }



    /**

    * @dev Gets the specified token ID of the uri. It only

    * returns ids of originals.

    * Throw if not connected to a token ID.

    * @param _uri string uri of metadata

    * @return uint256 token ID

    */

    function originalTokenOfUri(string _uri) public view returns (uint256) {

        uint256 tokenId = uriOriginalToken[_uri];

        ownerOf(tokenId);

        return tokenId;

    }



    /**

    * @dev Gets the current bid and bidder of the token

    * @param _tokenId uint256 ID of the token to get bid details

    * @return bid amount and bidder address of token

    */

    function currentBidDetailsOfToken(uint256 _tokenId) public view returns (uint256, address) {

        return (tokenCurrentBid[_tokenId], tokenBidder[_tokenId]);

    }



    /**

    * @dev Gets the creator of the token

    * @param _tokenId uint256 ID of the token

    * @return address of the creator

    */

    function creatorOfToken(uint256 _tokenId) public view returns (address) {

        return tokenCreator[_tokenId];

    }

    

    /**

    * @dev Gets the sale price of the token

    * @param _tokenId uint256 ID of the token

    * @return sale price of the token

    */

    function salePriceOfToken(uint256 _tokenId) public view returns (uint256) {

        return tokenSalePrice[_tokenId];

    }

    

    /**

    * @dev Internal function to return funds to current bidder.

    * @param _tokenId uint256 ID of the token with the standing bid

    */

    function returnCurrentBid(uint256 _tokenId) private {

        uint256 currentBid = tokenCurrentBid[_tokenId];

        address currentBidder = tokenBidder[_tokenId];

        if(currentBidder != address(0)) {

            currentBidder.transfer(currentBid);

        }

    }

    

    /**

    * @dev Internal function to check that the bid is larger than current bid

    * @param _tokenId uint256 ID of the token with the standing bid

    */

    function isGreaterBid(uint256 _tokenId) private view returns (bool) {

        return msg.value > tokenCurrentBid[_tokenId];

    }

    

    /**

    * @dev Internal function to clear bid

    * @param _tokenId uint256 ID of the token with the standing bid

    */

    function clearBid(uint256 _tokenId) private {

        tokenBidder[_tokenId] = address(0);

        tokenCurrentBid[_tokenId] = 0;

    }

    

    /**

    * @dev Internal function to pay the bidder, creator, and maintainer

    * @param _val uint256 value to be split

    * @param _maintainer address of account maintaining SupeRare

    * @param _creator address of the creator of token

    * @param _maintainer address of the owner of token

    */

    function payout(uint256 _val, address _maintainer, address _creator, address _tokenOwner, uint256 _tokenId) private {

        uint256 maintainerPayment;

        uint256 creatorPayment;

        uint256 ownerPayment;

        if (tokenSold[_tokenId]) {

            maintainerPayment = _val.mul(maintainerPercentage).div(1000);

            creatorPayment = _val.mul(creatorPercentage).div(1000);

            ownerPayment = _val.sub(creatorPayment).sub(maintainerPayment); 

        } else {

            maintainerPayment = 0;

            creatorPayment = _val;

            ownerPayment = 0;

            tokenSold[_tokenId] = true;

        }

        _maintainer.transfer(maintainerPayment);

        _creator.transfer(creatorPayment);

        _tokenOwner.transfer(ownerPayment);

      

    }



    /**

     * @dev Internal function creating a new token.

     * @param _uri string metadata uri associated with the token

     */

    function createToken(string _uri, address _creator) private  returns (uint256){

      uint256 newId = totalSupply() + 1;

      _mint(_creator, newId);

      tokenCreator[newId] = _creator;

      tokenToURI[newId] = _uri;

      return newId;

    }



}