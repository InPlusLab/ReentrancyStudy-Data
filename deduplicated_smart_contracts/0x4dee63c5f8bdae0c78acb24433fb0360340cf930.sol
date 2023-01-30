/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

pragma solidity 0.6.2;



/**
 * @dev The contract has an owner address, and provides basic authorization control whitch
 * simplifies the implementation of user permissions. This contract is based on the source code at:
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable
{

  /**
   * @dev Error constants.
   */
  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

  /**
   * @dev Current owner address.
   */
  address public owner;

  /**
   * @dev An event which is triggered when the owner is changed.
   * @param previousOwner The address of the previous owner.
   * @param newOwner The address of the new owner.
   */
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The constructor sets the original `owner` of the contract to the sender account.
   */
  constructor()
    public
  {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner()
  {
    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {
    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}



/**
 * @dev Math operations with safety checks that throw on error. This contract is based on the
 * source code at:
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol.
 */
library SafeMath
{
  /**
   * List of revert message codes. Implementing dApp should handle showing the correct message.
   * Based on 0xcert framework error codes.
   */
  string constant OVERFLOW = "008001";
  string constant SUBTRAHEND_GREATER_THEN_MINUEND = "008002";
  string constant DIVISION_BY_ZERO = "008003";

  /**
   * @dev Multiplies two numbers, reverts on overflow.
   * @param _factor1 Factor number.
   * @param _factor2 Factor number.
   * @return product The product of the two factors.
   */
  function mul(
    uint256 _factor1,
    uint256 _factor2
  )
    internal
    pure
    returns (uint256 product)
  {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_factor1 == 0)
    {
      return 0;
    }

    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2, OVERFLOW);
  }

  /**
   * @dev Integer division of two numbers, truncating the quotient, reverts on division by zero.
   * @param _dividend Dividend number.
   * @param _divisor Divisor number.
   * @return quotient The quotient.
   */
  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {
    // Solidity automatically asserts when dividing by 0, using all gas.
    require(_divisor > 0, DIVISION_BY_ZERO);
    quotient = _dividend / _divisor;
    // assert(_dividend == _divisor * quotient + _dividend % _divisor); // There is no case in which this doesn't hold.
  }

  /**
   * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
   * @param _minuend Minuend number.
   * @param _subtrahend Subtrahend number.
   * @return difference Difference.
   */
  function sub(
    uint256 _minuend,
    uint256 _subtrahend
  )
    internal
    pure
    returns (uint256 difference)
  {
    require(_subtrahend <= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);
    difference = _minuend - _subtrahend;
  }

  /**
   * @dev Adds two numbers, reverts on overflow.
   * @param _addend1 Number.
   * @param _addend2 Number.
   * @return sum Sum.
   */
  function add(
    uint256 _addend1,
    uint256 _addend2
  )
    internal
    pure
    returns (uint256 sum)
  {
    sum = _addend1 + _addend2;
    require(sum >= _addend1, OVERFLOW);
  }

  /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo), reverts when
    * dividing by zero.
    * @param _dividend Number.
    * @param _divisor Number.
    * @return remainder Remainder.
    */
  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder)
  {
    require(_divisor != 0, DIVISION_BY_ZERO);
    remainder = _dividend % _divisor;
  }

}


/**
 * @dev signature of external (deployed) contract (ERC20 token)
 * only methods we will use, needed for us to communicate with CYTR token (which is ERC20)
 */
contract ERC20Token {
 
    function totalSupply() external view returns (uint256){}
    function balanceOf(address account) external view returns (uint256){}
    function allowance(address owner, address spender) external view returns (uint256){}
    function transfer(address recipient, uint256 amount) external returns (bool){}
    function approve(address spender, uint256 amount) external returns (bool){}
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){}
    function decimals()  external view returns (uint8){}
  
}



/**
 * @dev signature of external (deployed) contract for NFT publishing (ERC721)
 * only methods we will use, needed for us to communicate with Cyclops token (which is ERC721)
 */
contract CyclopsTokens {
    
 
 
 function mint(address _to, uint256 _tokenId, string calldata _uri) external {}
 
 function ownerOf(uint256 _tokenId) external view returns (address) {}
 function burn(uint256 _tokenId) external {}
 
 function tokenURI(uint256 _tokenId) external  view returns(string memory) {}
    
}

contract NFTMarketplace is
  Ownable
{
    using SafeMath for uint256;    
    
     modifier onlyPriceManager() {
      require(
          msg.sender == price_manager,
          "only price manager can call this function"
          );
          _;
    }
    
    modifier onlyOwnerOrPriceManager() {
      require(
          msg.sender == price_manager || msg.sender == owner,
          "only price manager or owner can call this function"
          );
          _;
    }
 
    /**
    * @dev not bullet-proof check, but additional measure, actually we require specific (contract) address,
    * which is key (see onlyBankContract)
    */
    function isContract(address _addr) internal view returns (bool){
      uint32 size;
      assembly {
          size := extcodesize(_addr)
      }
    
      return (size > 0);
    }

    modifier notContract(){
      require(
          (!isContract(msg.sender)),
          "external contracts are not allowed"
          );
          _;
    }

 
    
  //external NFT publishing contract
  CyclopsTokens nftContract;
  ERC20Token token; //CYTR
  
  //hard code address of external contract (NFT), as it can't be redeployed in production
  //what could be redeployed - NFTBank contract -  and we can link new NFT bank 
  //with special method in CyclopsTokens
  address nftContractAddress = 0xd6d778d86Ddf225e3c02C45D6C6e8Eb3497B452A; //NFT contract (Cyclops)
  address paymentTokenAddress = 0xBD05CeE8741100010D8E93048a80Ed77645ac7bf; //payment token (ERC20, CYTR)
  
  address price_manager = 0x0000000000000000000000000000000000000000;
  
  bool internal_prices = true;
  uint256 price_curve = 5; //5%
  
  uint32 constant BAD_NFT_PROFILE_ID = 9999999;
  uint256 constant BAD_PRICE = 0;
  string constant BAD_URL = '';
  uint32 constant UNLIMITED = 9999999;
  
  /**
   * @dev 'database' to store profiles of NFTs
   */
  struct NFTProfile{
      uint32 id;
      uint256 price; //in CYTR, i.e. 1,678 CYTR last 18 digits are decimals
      uint256 sell_price; //in CYTR i.e. 1,678 CYTR last 18 digits are decimals
      string url;
      uint32 limit;
  }
  
  NFTProfile[] public nftProfiles;
  
  uint256 next_token_id = 10;

   /**
   * @dev Events
   */
    //buy from us
    event Minted(uint32 profileID, uint256 tokenId, address wallet, uint256 cytrAmount, uint256 priceAtMoment);
    
    //intermediate event for support of broken buy (CYTR transferred but NFT was not minted) 
    // - for manual resolution from admin panel
    event GotCYTRForNFT(uint32 profileID, address wallet, uint256 cytrAmount, uint256 priceAtMoment);
    
    //intermediate event for support of broken sell (CYTR transferred back NFT was not burned) 
    // - for manual resolution from admin panel
    event SendCYTRForNFT(uint32 profileID, address wallet, uint256 cytrAmount, uint256 buybackPriceAtMoment);
    
    //buy back from user
    event Burned(uint32 profileID, uint256 tokenId, address wallet, uint256 cytrAmount, uint256 buybackPriceAtMoment);
    
    //admin events - CYTR tokens/ether deposit/withdrawal
    event TokensDeposited(uint256 amount, address wallet);
    event FinneyDeposited(uint256 amount, address wallet);
    event Withdrawn(uint256 amount, address wallet);
    event TokensWithdrawn(uint256 amount, address wallet);
    event AdminMinted(uint32 profileID, uint256 tokenId, address wallet, uint256 curPrice); 
    event AdminBurned(uint256 _tokenId,uint32 tokenProfileId, uint256 curSellPrice); 

  /**
   * @dev Contract constructor.
   */
  constructor()
    public
  {
     price_manager = owner;
     nftContract = CyclopsTokens(nftContractAddress);   //NFT minting interface
     token = ERC20Token(paymentTokenAddress);           //CYTR interface
  }
    
    function setPriceManagerRight(address newPriceManager) external onlyOwner{
          price_manager = newPriceManager;
    }
      
    
    function getPriceManager() public view returns(address){
        return price_manager;
    }

    function setInternalPriceCurve() external onlyOwnerOrPriceManager{
          internal_prices = true;
    }
    
    function setExternalPriceCurve() external onlyOwnerOrPriceManager{
          internal_prices = false;
    }
      
    function isPriceCurveInternal() public view returns(bool){
        return internal_prices;
    }
      
    function setPriceCurve(uint256 new_curve) external onlyOwnerOrPriceManager{
          price_curve = new_curve;
    }
      
    
    function getPriceCurve() public view returns(uint256){
        return price_curve;
    }
    
    
    /**
    * @dev setter/getter for ERC20 linked to exchange (current) smartcontract
    */
    function setPaymentToken(address newERC20Contract) external onlyOwner returns(bool){
    
        paymentTokenAddress = newERC20Contract;
        token = ERC20Token(paymentTokenAddress);
    }
    
    
    function getPaymentToken() external view returns(address){
        return paymentTokenAddress;
    }
    
    
    
    /**
    * @dev setter/getter for NFT publisher linked to 'marketplace' smartcontract
    */
    function setNFTContract(address newNFTContract) external onlyOwner returns(bool){
    
        nftContractAddress = newNFTContract;
        nftContract = CyclopsTokens(nftContractAddress);
    }
    
    
    function getNFTContract() external view returns(address){
        return nftContractAddress;
    }



  /**
   * @dev getter for next_token_id
   */
  function getNextTokenId() external  view returns (uint256){
      return next_token_id;
  }
  
   /**
   * @dev setter for next_token_id
   */
  function setNextTokenId(uint32 setId) external onlyOwnerOrPriceManager (){
      next_token_id = setId;
  }
  
  /**
   * @dev adds 'record' to 'database'
   * @param id, unique id of profiles
   * @param price, price of NFT assets which will be generated based on profile
   * @param sell_price, when we will buy out from owner (burn)
   * @param url, url of NFT assets which will be generated based on profile
   */
  function addNFTProfile(uint32 id, uint256 price, uint256 sell_price, string calldata url, uint32 limit) external onlyOwnerOrPriceManager {
      NFTProfile memory temp = NFTProfile(id,price,sell_price,url, limit);
      nftProfiles.push(temp);
  }
  
  
  
  /**
   * @dev removes 'record' to 'database'
   * @param id (profile id)
   *
   */
  function removeNFTProfileAtId(uint32 id) external onlyOwnerOrPriceManager {
     for (uint32 i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              removeNFTProfileAtIndex(i);      
              return;
          }
     }
  }
  
  
  
  /**
   * @dev removes 'record' to 'database'
   * @param index, record number (from 0)
   *
   */
  function removeNFTProfileAtIndex(uint32 index) internal {
     if (index >= nftProfiles.length) return;
     if (index == nftProfiles.length -1){
         nftProfiles.pop();
     } else {
         for (uint i = index; i < nftProfiles.length-1; i++){
             nftProfiles[i] = nftProfiles[i+1];
         }
         nftProfiles.pop();
     }
  }
  
  
  
  /**
   * @dev replaces 'record' in the 'database'
   * @param id, unique id of profile
   * @param price, price of NFT assets which will be generated based on profile
   * @param sell_price, sell price (back to owner) of NFT assets when owner sell to us (and we burn)
   * @param url, url of NFT assets which will be generated based on profile
   */
  function replaceNFTProfileAtId(uint32 id, uint256 price, uint256 sell_price, string calldata url, uint32 limit) external onlyOwnerOrPriceManager {
     for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              nftProfiles[i].price = price;
              nftProfiles[i].sell_price = sell_price;
              nftProfiles[i].url = url;
              nftProfiles[i].limit = limit;
              return;
          }
     }
  }
  
  
  /**
   * @dev replaces 'record' in the 'database'
   * @param atIndex, at which row of array to make replacement
   * @param id, unique id of profiles
   * @param price, price of NFT assets which will be generated based on profile
   * @param sell_price, sell price (back to owner) of NFT assets when owner sell to us (and we burn)
   * @param url, url of NFT assets which will be generated based on profile
   */
  function replaceNFTProfileAtIndex(uint32 atIndex, uint32 id, uint256 price, uint256 sell_price, string calldata url, uint32 limit) external onlyOwnerOrPriceManager  {
     nftProfiles[atIndex].id = id;
     nftProfiles[atIndex].price = price;
     nftProfiles[atIndex].sell_price = sell_price;
     nftProfiles[atIndex].url = url;
     nftProfiles[atIndex].limit = limit;
  }
  
    /**
   * @dev return array of strings is not supported by solidity, we return ids & prices
   */
  function viewNFTProfilesPrices() external view returns( uint32[] memory, uint256[] memory, uint256[] memory){
      uint32[] memory ids = new uint32[](nftProfiles.length);
      uint256[] memory prices = new uint256[](nftProfiles.length);
      uint256[] memory sell_prices = new uint256[](nftProfiles.length);
      for (uint i = 0; i < nftProfiles.length; i++){
          ids[i] = nftProfiles[i].id;
          prices[i] = nftProfiles[i].price;
          sell_prices[i] = nftProfiles[i].sell_price;
      }
      return (ids, prices, sell_prices);
  }
  
  
   /**
   * @dev return price, sell_price & url for profile by id
   */
  function viewNFTProfileDetails(uint32 id) external view returns(uint256, uint256, string memory, uint32){
     for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              return (nftProfiles[i].price, nftProfiles[i].sell_price, nftProfiles[i].url, nftProfiles[i].limit);     
          }
     }
     return (BAD_PRICE, BAD_PRICE, BAD_URL, UNLIMITED);
  }
  
  /**
   * @dev get price by id from 'database'
   * @param id, unique id of profiles
   */
  function getPriceById(uint32 id) public  view returns (uint256){
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              return nftProfiles[i].price;
          }
      }
      return BAD_PRICE;
  }
  
  
 
  
  /**
   * @dev get sell price by id from 'database'
   * @param id, unique id of profiles
   */
  function getSellPriceById(uint32 id) public  view returns (uint256){
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              return nftProfiles[i].sell_price;
          }
      }
      return BAD_PRICE;
  }
  
   /**
   * @dev set new price for asset (profile of NFT), price for which customer can buy
   * @param id, unique id of profiles
   */
  function setPriceById(uint32 id, uint256 new_price) external onlyOwnerOrPriceManager{
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              nftProfiles[i].price = new_price;
              return;
          }
      }
  }
  
   /**
   * @dev set new sell (buy back) price for asset (profile of NFT), 
   * price for which customer can sell to us
   * @param id, unique id of profiles
   */
  function setSellPriceById(uint32 id, uint256 new_price) external onlyOwnerOrPriceManager{
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              nftProfiles[i].sell_price = new_price;
              return;
          }
      }
  }
  
  // for optimization, funciton to update both prices
  function updatePricesById(uint32 id, uint256 new_price, uint256 new_sell_price) external onlyOwnerOrPriceManager{
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              nftProfiles[i].price = new_price;
              nftProfiles[i].sell_price = new_sell_price;
              return;
          }
      }
  }
  
 
  
  /**
   * @dev get url by id from 'database'
   * @param id, unique id of profiles
   */ 
  function  getUrlById(uint32 id) public view returns (string memory){
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
              return nftProfiles[i].url;
          }
      }
      return BAD_URL;
  }
  
  function  getLimitById(uint32 id) public view returns (uint32){
      for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == id){
             return nftProfiles[i].limit;
          }
      }
      return UNLIMITED;
  }
  
   
  /**
   * @dev accepts payment only in CYTR(!) for mint NFT & calls external contract
   * it is public function, i.e called by buyer via dApp
   * buyer selects profile (profileID), provides own wallet address (_to)
   * and dApp provides available _tokenId (for flexibility its calculation is not automatic on 
   * smart contract level, but it is possible to implement) - > nftContract.totalSupply()+1
   * why not recommended: outsite of smart contract with multiple simultaneous customers we can 
   * instanteneusly on level of backend determinte next free id.
   * on CyclopsTokens smartcontract level it can be only calculated correctly after mint transaction is confirmed
   * here utility function is implemented which is used by backend ,getNextTokenId()
   * it is also possible to use setNextTokenId function (by owner) to reset token id if needed
   * normal use is dApp requests next token id (tid = getNextTokenId()) and after that
   * calls publicMint(profile, to, tid)
   * it allows different dApps use different token ids areas
   * like   dapp1: tid = getNextTokenId() + 10000
   *        dapp2: tid = getNextTokenId() + 20000
   */
  function buyNFT(          //'buy' == mint NFT token function, provides NFT token in exchange of CYTR    
    uint32 profileID,       //id of NFT profile
    uint256 cytrAmount,     //amount of CYTR we check it is equal to price, amount in real form i.e. 18 decimals
    address _to,            //where to deliver 
    uint256 _tokenId        //with which id NFT will be generated
  ) 
    external 
    notContract 
    returns (uint256)
  {
    require (getLimitById(profileID) > 0,"limit is over");
    
    uint256 curPrice = getPriceById(profileID);
    require(curPrice != BAD_PRICE, "price for NFT profile not found");
    require(cytrAmount > 0, "You need to provide some CYTR"); //it is already in 'real' form, i.e. with decimals
    
    require(cytrAmount == curPrice); //correct work (i.e. dApp calculated price correctly)
    
    uint256 token_bal = token.balanceOf(msg.sender); //how much CYTR buyer has
    
    require(token_bal >= cytrAmount, "Check the CYTR balance on your wallet"); //is it enough
    
    uint256 allowance = token.allowance(msg.sender, address(this));
    
    require(allowance >= cytrAmount, "Check the CYTR allowance"); //is allowance provided
    
    require(isFreeTokenId(_tokenId), "token id is is occupied"); //adjust on calling party

    //ensure we revert in case of failure
    try token.transferFrom(msg.sender, address(this), cytrAmount) { // get CYTR from buyer
        emit GotCYTRForNFT(profileID, msg.sender, cytrAmount, curPrice);
    } catch {
        require(false,"CYTR transfer failed");
        return 0; 
    }
  
   
    //external contract mint
    try nftContract.mint(_to,_tokenId, getUrlById(profileID)){
        next_token_id++;
        //we should have event pairs GotCYTRForNFT - Minted if all good
        emit Minted(profileID, _tokenId, msg.sender, cytrAmount, curPrice); 
    } catch {
        //return payment by using require..it should revert transaction 
        require(false,"mint failed");
    }
    
    for (uint i = 0; i < nftProfiles.length; i++){
      if (nftProfiles[i].id == profileID){
          if (nftProfiles[i].limit != UNLIMITED) nftProfiles[i].limit--;
      }
    }
    
    if (internal_prices){ //if we manage price curve internally
        for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == profileID){
              uint256 change = nftProfiles[i].price.div(100).mul(price_curve);
              nftProfiles[i].price = nftProfiles[i].price.add(change);
              change = nftProfiles[i].sell_price.div(100).mul(price_curve);
              nftProfiles[i].sell_price = nftProfiles[i].sell_price.add(change);
          }
      }
    }
 
    //return _tokenId; //success, return generated tokenId, works only if called by contract, i.e. not our case
  }

 /**
   * @dev method allows collectible owner to sell it back for sell price
   * collectible is burned, amount of sell price returned to owner of collectible
   * tokenId -> tokenProfileId -> sell price
   */
  function sellNFTBack(uint256 _tokenId) external notContract returns(uint256){ //'sell' == burn, burns and returns CYTR to user
        require(nftContract.ownerOf(_tokenId) == msg.sender, "it is not your NFT");
        uint32 tokenProfileId = getProfileIdByTokenId(_tokenId);
        require(tokenProfileId != BAD_NFT_PROFILE_ID, "NFT profile ID not found");
        uint256 sellPrice = getSellPriceById(tokenProfileId); 
        require(sellPrice != BAD_PRICE, "NFT price not found");
        
        require(token.balanceOf(msg.sender) > sellPrice, "unsufficient CYTR on contract");
        
        try nftContract.burn(_tokenId) {
            emit Burned(tokenProfileId, _tokenId, msg.sender, sellPrice, sellPrice); 
        } catch {
        //ensure error will be send (false, i.e. require is never fulfilled, error send)
            require (false, "NFT burn failed");
        }
      
        //ensure we revert in case of failure
        try token.transfer(msg.sender,  sellPrice) { // send CYTR to seller
            //just continue if all good..
            emit SendCYTRForNFT(tokenProfileId, msg.sender, sellPrice, sellPrice);
        } catch {
            require(false,"CYTR transfer failed");
            return 0; 
        }
        
        for (uint i = 0; i < nftProfiles.length; i++){
          if (nftProfiles[i].id == tokenProfileId){
              if (nftProfiles[i].limit != UNLIMITED) nftProfiles[i].limit++;
          }
        }
       
        if (internal_prices){ //if we manage price curve internally
            for (uint i = 0; i < nftProfiles.length; i++){
              if (nftProfiles[i].id == tokenProfileId){
                  uint256 change = nftProfiles[i].price.div(100).mul(price_curve);
                  nftProfiles[i].price = nftProfiles[i].price.sub(change);
                  change = nftProfiles[i].sell_price.div(100).mul(price_curve);
                  nftProfiles[i].sell_price = nftProfiles[i].sell_price.sub(change);
              }
            }
        }
  }
  
  
  function adminMint(       //mint for free as admin
    uint32 profileID,       //id of NFT profile
    address _to,            //where to deliver 
    uint256 _tokenId        //with which id NFT will be generated
  ) 
    external 
    onlyOwnerOrPriceManager
    returns (uint256)
  {
    uint256 curPrice = getPriceById(profileID);
    require(curPrice != BAD_PRICE, "price for NFT profile not found");
    require(isFreeTokenId(_tokenId), "token id is is occupied");
  

    
    //external contract mint
    try nftContract.mint(_to,_tokenId, getUrlById(profileID)){
        next_token_id++;
        //we should have event pairs GotCYTRForNFT - Minted if all good
        emit AdminMinted(profileID, _tokenId, _to, curPrice); 
    } catch {
        //return payment by using require..it should revert transaction 
        require(false,"mint failed");
    }
    
    return _tokenId; //success, return generated tokenId (works if called by another contract)
  }

  
  
  function adminBurn(uint256 _tokenId) external  onlyOwnerOrPriceManager returns(uint256){  //burn as admin, without CYTR move

        uint32 tokenProfileId = getProfileIdByTokenId(_tokenId);
        //require(tokenProfileId != BAD_NFT_PROFILE_ID, "NFT profile ID not found");
        //in admin mode we do not require it
        uint256 sellPrice = getSellPriceById(tokenProfileId); 
        //require(sellPrice != BAD_PRICE, "NFT price not found");
        //in admin mode we do not require it
        
        try nftContract.burn(_tokenId) {
            emit AdminBurned(_tokenId, tokenProfileId, sellPrice); 
        } catch {
        //ensure error will be send (false, i.e. require is never fulfilled, error send)
            require (false, "NFT burn failed");
        }
      
  }
  
  
  function getProfileIdByTokenId(uint256 tokenId) public view returns(uint32){
      string memory url = BAD_URL;
      try nftContract.tokenURI(tokenId) {
        url = nftContract.tokenURI(tokenId);
        return getProfileIdbyUrl(url);
      } catch {
        return BAD_NFT_PROFILE_ID;
      }
     
  }
  
  function getProfileIdbyUrl(string memory url) public  view returns (uint32){
      for (uint i = 0; i < nftProfiles.length; i++){
          if (keccak256(bytes(nftProfiles[i].url)) == keccak256(bytes(url))){
              return nftProfiles[i].id;
          }
      }
      return BAD_NFT_PROFILE_ID;
  }
  
 
  
  function isFreeTokenId(uint256 tokenId) public view returns (bool){
      try nftContract.tokenURI(tokenId) { 
          //if we can run this successfully it means token id is not free -> false
          return false;
      } catch {
          return true; //if we errored getting url by tokenId, it is free -> true
      }
  }
  
  
  function getTokenPriceByTokenId(uint256 tokenId) public view returns(uint256){
      string memory url = BAD_URL;
      try nftContract.tokenURI(tokenId) {
        url = nftContract.tokenURI(tokenId);
        uint32 profileId = getProfileIdbyUrl(url);
        if (profileId == BAD_NFT_PROFILE_ID){
            return BAD_NFT_PROFILE_ID;
        } else {
            return getSellPriceById(profileId);
        }
      } catch {
        return BAD_NFT_PROFILE_ID;
      }
     
  }
  
  
    /**
    * @dev - six functions below are for owner to check balance and
    * deposit/withdraw eth/tokens to exchange contract
    */
    /**
    * @dev returns contract balance, in wei
    */
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
    * @dev returns contract tokens balance
    */
    function getContractTokensBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    
    function withdraw(address payable sendTo, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "unsufficient funds");
        bool success = false;
        // ** sendTo.transfer(amount);**
        (success, ) = sendTo.call.value(amount)("");
        require(success, "Transfer failed.");
        // ** end **
        emit Withdrawn(amount, sendTo); //in wei
    }
    
    
    //deposit ether (amount in finney for control is provided as input paramenter)
    function deposit(uint256 amount) payable external onlyOwner { 
        require(amount*(1 finney) == msg.value,"please provide value in finney");
        emit FinneyDeposited(amount, owner); //in finney
    }
    
    
    // tokens with decimals, already converted on frontend
    function depositTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "You need to deposit at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
    
        emit TokensDeposited(amount, owner);
    }
    
    
    // tokens with decimals, already converted on frontend
    function withdrawTokens(address to_wallet, uint256 realAmountTokens) external onlyOwner {
            
        require(realAmountTokens > 0, "You need to withdraw at least some tokens");
      
        uint256 contractTokenBalance = token.balanceOf(address(this));
    
        require(contractTokenBalance > realAmountTokens, "unsufficient funds");
    
         //ensure we revert in case of failure
        try token.transfer(to_wallet, realAmountTokens) {
            emit TokensWithdrawn(realAmountTokens, to_wallet); //in real representation
        } catch {
            require(false,"tokens transfer failed");
    
        }
    
    }
        
    
    
}