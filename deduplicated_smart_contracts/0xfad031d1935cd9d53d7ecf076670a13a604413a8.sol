/**

 *Submitted for verification at Etherscan.io on 2018-11-07

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity\contracts\access\Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */

library Roles {

  struct Role {

    mapping (address => bool) bearer;

  }



  /**

   * @dev give an account access to this role

   */

  function add(Role storage role, address account) internal {

    require(account != address(0));

    require(!has(role, account));



    role.bearer[account] = true;

  }



  /**

   * @dev remove an account's access to this role

   */

  function remove(Role storage role, address account) internal {

    require(account != address(0));

    require(has(role, account));



    role.bearer[account] = false;

  }



  /**

   * @dev check if an account has this role

   * @return bool

   */

  function has(Role storage role, address account)

    internal

    view

    returns (bool)

  {

    require(account != address(0));

    return role.bearer[account];

  }

}



// File: openzeppelin-solidity\contracts\access\roles\PauserRole.sol



contract PauserRole {

  using Roles for Roles.Role;



  event PauserAdded(address indexed account);

  event PauserRemoved(address indexed account);



  Roles.Role private pausers;



  constructor() internal {

    _addPauser(msg.sender);

  }



  modifier onlyPauser() {

    require(isPauser(msg.sender));

    _;

  }



  function isPauser(address account) public view returns (bool) {

    return pausers.has(account);

  }



  function addPauser(address account) public onlyPauser {

    _addPauser(account);

  }



  function renouncePauser() public {

    _removePauser(msg.sender);

  }



  function _addPauser(address account) internal {

    pausers.add(account);

    emit PauserAdded(account);

  }



  function _removePauser(address account) internal {

    pausers.remove(account);

    emit PauserRemoved(account);

  }

}



// File: openzeppelin-solidity\contracts\lifecycle\Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is PauserRole {

  event Paused(address account);

  event Unpaused(address account);



  bool private _paused;



  constructor() internal {

    _paused = false;

  }



  /**

   * @return true if the contract is paused, false otherwise.

   */

  function paused() public view returns(bool) {

    return _paused;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!_paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(_paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyPauser whenNotPaused {

    _paused = true;

    emit Paused(msg.sender);

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyPauser whenPaused {

    _paused = false;

    emit Unpaused(msg.sender);

  }

}



// File: openzeppelin-solidity\contracts\ownership\Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address private _owner;



  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() internal {

    _owner = msg.sender;

    emit OwnershipTransferred(address(0), _owner);

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns(address) {

    return _owner;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(isOwner());

    _;

  }



  /**

   * @return true if `msg.sender` is the owner of the contract.

   */

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));

    _owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;

  }

}



// File: openzeppelin-solidity\contracts\token\ERC20\IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

  function totalSupply() external view returns (uint256);



  function balanceOf(address who) external view returns (uint256);



  function allowance(address owner, address spender)

    external view returns (uint256);



  function transfer(address to, uint256 value) external returns (bool);



  function approve(address spender, uint256 value)

    external returns (bool);



  function transferFrom(address from, address to, uint256 value)

    external returns (bool);



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: contracts\HorseAuction.sol



/**

    @title An auction system to sell budnles of HORSE tokens

*/



contract HorseAuction is Ownable, Pausable {



    uint256 constant HORSE = 1 ether; //HORSE like ether has 18 decimal places

    uint256 constant MINIMAL_BUNDLE = 10000 * HORSE; //minimum HORSE in a bundle is 10000

    uint256 constant MINIMAL_DURATION = 5 minutes; //minimum auction duration is 5 minutes



    /**

        @dev Auction bundle containing HORSE

    */

    struct Bundle {

        uint256 amount;         //amount of HORSE in this bundle

        uint256 expires;        //date at which this bundle can no longer be bet on

        uint256 currentBid;     //current bid value

        address seller;         //address of the seller

        address highestBidder;  //address of the current highest bidder

    }



    /// @dev horse token access interface

    IERC20 public horseToken = IERC20(0x5B0751713b2527d7f002c0c4e2a37e1219610A6B);

    /// @dev matches a bundle id to the bundle

    mapping(bytes32 => Bundle) public bundles;

    /// @dev this is the devs equity expressed in /1000

    uint256 private _commission = 15;

    /// @dev total amount of fees this contract holds

    uint256 private _collected;



    event NewBundle(uint256 amount, uint256 duration, bytes32 id);

    event NewBid(bytes32 bundleId, uint256 currentValue);

    event AuctionEnded(bytes32 id);



    /**

        @dev Constructor

        Contract can be paused

    */

    constructor() public

    Ownable()

    Pausable() {

       

    }

    /**

        @dev contract owner can change fees

        Fees are expressed /1000

        @param newCommission the new fees in /1000

    */

    function changeCommission(uint256 newCommission) external 

    onlyOwner() {

        _commission = newCommission;

    }



    /**

        @dev creates a bundle of HORSE to put on auction for a certain duration

        @param amount The amount of HORSE to include in the bundle

        @param duration Duration of the auction in seconds

    */

    function sell(uint256 amount, uint256 duration) external {

        require(!paused(),"Contract is paused");



        //set minimal amount to avoid bundle spamming

        require(amount >= MINIMAL_BUNDLE, "Not enough HORSE in this bundle");

        require(duration > MINIMAL_DURATION, "Duration is too short");

        //bundle ID is the sha of amount + duration + seller address + current block timestamp

        bytes32 bundleId = keccak256(abi.encodePacked(amount, duration, msg.sender, block.timestamp));

        //make sure we wont destroy an existing bundle (if same amount, seller and duration and executed in the same block!)

        require(bundles[bundleId].seller == address(0),"You cant create twice the same bundle in a single block");



        Bundle storage newBundle = bundles[bundleId];

        newBundle.amount = amount;

        newBundle.expires = block.timestamp + duration;

        newBundle.seller = msg.sender;

        //transfer the required amount of HORSE from the seller to this contract

        //the seller must approve this transfer first of course!

        require(horseToken.transferFrom(msg.sender, address(this), amount),"Transfer failed, are we approved to transferFrom this amount?");



        emit NewBundle(amount, duration, bundleId);

    }



    /**

        @dev Add a new bid on a specific bundle

        @param bundleId ID of the bundle to bid on

        Bundle must exist and auction must not have expired

    */

    function bid(bytes32 bundleId) external payable 

    _exists(bundleId)

    _active(bundleId) {

        require(!paused(),"Contract is paused");



        Bundle storage bundle = bundles[bundleId];

        //Bidder must outbid the previous bidder

        require(bundle.currentBid < msg.value, "You must outbid the current value");



        //if not first bidder, send back the losers ETH!

        if(bundle.highestBidder != address(0)) {

            bundle.highestBidder.transfer(bundle.currentBid);

        }

        

        //replace the older highest bidder

        bundle.currentBid = msg.value;

        bundle.highestBidder = msg.sender;

        

        emit NewBid(bundleId, msg.value);

    }



    /**

        @dev Allows to withdraw a bundle from a completed auction

        Must exist and auction must have ended

        Can be called even while contract is paused

        @param bundleId ID of te bundle to withdraw

    */

    function withdrawBundle(bytes32 bundleId) external 

    _exists(bundleId)

    _expired(bundleId) {

        Bundle storage bundle = bundles[bundleId];

        //did we get any bids?

        if(bundle.currentBid > 0) {

            //compute the amount to keep

            uint256 commission = bundle.currentBid / 1000 * _commission;

            //give the seller his ETH

            bundle.seller.transfer(bundle.currentBid-commission);

            _collected = _collected + commission;

            //give the buyer his HORSE

            require(horseToken.transfer(bundle.highestBidder, bundle.amount),"Transfer failed");

        } else {

            //just give me back my horse

            require(horseToken.transfer(bundle.seller, bundle.amount),"Transfer failed");

        }

        

        delete(bundles[bundleId]);

        emit AuctionEnded(bundleId);

    }



    /**

        @dev Contract owner can withdraw collected auction fees

    */

    function withdraw() external

    onlyOwner() {

        msg.sender.transfer(_collected);

        _collected = 0;

    }



    modifier _exists(bytes32 bundleId) {

        require(bundles[bundleId].seller != address(0), "Bundle not found");

        _;

    }



    modifier _expired(bytes32 bundleId) {

        require(block.timestamp > bundles[bundleId].expires,"Auction is still active");

        _;

    }



    modifier _active(bytes32 bundleId) {

        require(block.timestamp <= bundles[bundleId].expires,"Auction expired");

        _;

    }



}