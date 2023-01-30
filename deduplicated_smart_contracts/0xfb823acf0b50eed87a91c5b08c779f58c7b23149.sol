/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

// File: contracts/SafeMath.sol

pragma solidity ^0.5.0;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/Ownable.sol

pragma solidity ^0.5.0;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   */
  constructor () public {
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
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

// File: contracts/Pausable.sol

pragma solidity ^0.5.0;



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  constructor() public {}

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

// File: contracts/Controllable.sol

pragma solidity ^0.5.0;


/**
 * @title Controllable
 * @dev The Controllable contract has an controller address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Controllable {
  address public controller;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   */
  constructor() public {
    controller = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyController() {
    require(msg.sender == controller);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newController The address to transfer ownership to.
   */
  function transferControl(address newController) public onlyController {
    if (newController != address(0)) {
      controller = newController;
    }
  }

}

// File: contracts/TokenInterface.sol

pragma solidity ^0.5.0;


/**
 * @title Token (WIRA)
 * Standard Mintable ERC20 Token
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract TokenInterface is Controllable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);
  event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
  event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function totalSupply() public view returns (uint);
  function totalSupplyAt(uint _blockNumber) public view returns(uint);
  function balanceOf(address _owner) public view returns (uint256 balance);
  function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint);
  function transfer(address _to, uint256 _amount) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
  function approve(address _spender, uint256 _amount) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);
  function mint(address _owner, uint _amount) public returns (bool);
  function enableTransfers() public returns (bool);
  function finishMinting() public returns (bool);
}

// File: contracts/NewWiraTokenSale.sol

pragma solidity ^0.5.0;



/**
 * @title NewWiraTokenSale
 * Tokensale allows investors to make token purchases and assigns them tokens based

 * on a token per ETH rate. Funds collected are forwarded to a wallet as they arrive.
 */
 contract NewWiraTokenSale is Pausable {
   using SafeMath for uint256;

   TokenInterface public token;
   uint256 public totalWeiRaised;
   uint256 public tokensMinted;
   uint256 public contributors;

   bool public finalized = false;

   address public tokenWalletAddress;
   address payable tokenSaleWalletAddress;
   uint256 public constant TOKENSALE_CAP = 122500000 * 10 ** 18;
   uint256 public constant TOTAL_CAP = 408333334 * 10 ** 18;
   uint256 public constant TEAM_TOKENS = 285833334 * 10 ** 18; //TOTAL_CAP - TOKENSALE_CAP

   uint256 public conversionRateInCents = 15000; // 1ETH = 15000 cents by default - can be updated
   event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
   event Finalized();

   constructor(
     address _tokenAddress,
     address _tokenSaleWalletAddress,
     address _tokenWalletAddress
   ) public {
      require(_tokenAddress != address(0));
      token = TokenInterface(_tokenAddress);
      tokensMinted = 26983068991913242797089;
      totalWeiRaised = 17172834754735456896;
      contributors = 20;

      tokenWalletAddress = _tokenWalletAddress;
      tokenSaleWalletAddress = address(uint160(_tokenSaleWalletAddress));
   }

   /**
    * High level token purchase function
    */
   function() external payable {
     buyTokens(msg.sender);
   }

   /**
    * Low level token purchase function
    * @param _beneficiary will receive the tokens.
    */
   function buyTokens(address _beneficiary) public payable whenNotPaused whenNotFinalized {
    require(_beneficiary != address(0));
    validatePurchase();

    uint256 current = now;
    uint256 tokens;

    totalWeiRaised = totalWeiRaised.add(msg.value);
    tokens = (msg.value * conversionRateInCents) / 20;
    contributors = contributors.add(1);
    tokensMinted = tokensMinted.add(tokens);

    /*
    *@info: msg.value can stay in Wei as long as decimals for the tokens are the same as Ethereum (18 decimals)
    */
    require(tokensMinted < TOKENSALE_CAP);

    token.mint(_beneficiary, tokens);
    emit TokenPurchase(msg.sender, _beneficiary, msg.value, tokens);
    forwardFunds();
   }

   function updateConversionRate(uint256 _conversionRateInCents) onlyOwner public {
       conversionRateInCents = _conversionRateInCents;
   }

   /**
   * Forwards funds to the tokensale wallet
   */
   function forwardFunds() internal {
       address(tokenSaleWalletAddress).transfer(msg.value);
   }

   function currentDate() public view returns (uint256) {
       return now;
   }

   /**
   * Validates the purchase (period, minimum amount, within cap)
   * @return {bool} valid
   */
   function validatePurchase() internal returns (bool) {
      bool nonZeroPurchase = msg.value != 0;
      require(nonZeroPurchase);
   }

   /**
   * Returns the total WIRA token supply
   * @return totalSupply {uint256} WIRA Token Total Supply
   */
   function totalSupply() public view returns (uint256) {
       return token.totalSupply();
   }

   /**
   * Returns token holder WIRA Token balance
   * @param _owner {address} Token holder address
   * @return balance {uint256} Corresponding token holder balance
   */
   function balanceOf(address _owner) public view returns (uint256) {
      return token.balanceOf(_owner);
   }

   /**
   * Change the WIRA Token controller
   * @param _newController {address} New WIRA Token controller
   */
   function changeController(address _newController) public onlyOwner {
      require(isContract(_newController));
      token.transferControl(_newController);
   }

   function finalize() public onlyOwner {
      require(paused);
      emit Finalized();

      uint256 remainingTokens = TOKENSALE_CAP - tokensMinted;
      token.mint(tokenWalletAddress, remainingTokens);
      finalized = true;
   }

   function enableTransfers() public onlyOwner {
     token.enableTransfers();
   }


   function isContract(address _addr) view internal returns(bool) {
     uint size;
     if (_addr == address(0))
       return false;
     assembly {
         size := extcodesize(_addr)
     }
     return size>0;
   }

   modifier whenNotFinalized() {
     require(!finalized);
     _;
   }

 }