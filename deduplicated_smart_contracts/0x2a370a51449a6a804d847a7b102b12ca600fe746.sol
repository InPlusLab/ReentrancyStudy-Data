/**
 *Submitted for verification at Etherscan.io on 2019-07-23
*/

pragma solidity 0.5.10;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath 
{
  function mul(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    if (a == 0) 
    {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable 
{
    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public
    {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() 
    {
        assert(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public
    {
        assert(newOwner != address(0));
        owner = newOwner;
    }
}

contract Token
{
   mapping(address => mapping (address => uint256)) allowed;
   function transfer(address to, uint256 value) public returns (bool);
   function transferFrom(address from, address to, uint256 value) public returns (bool);
}

contract CraftrEscrow is Ownable
{
    using SafeMath for uint256;
    
    Token CRAFTRToken;

    mapping (uint256 => Escrow) inEscrow;
    mapping (address => bool) public admins;

    uint256 round_interval = 12 hours;

    struct Escrow
    {
        address _from;
        address _to;
        uint256 _amount;
        uint256 _expiryTime;
        bool _accepted;
        bool _released;
        bool _denied;
    }

    modifier onlyVendor(address vendor, uint256 depositID)
    {
        assert(inEscrow[depositID]._to == vendor);
        _;
    }
    
    modifier onlyBuyer(address buyer, uint256 depositID)
    {
        assert(inEscrow[depositID]._from == buyer);
        _;
    }

    modifier onlyAdmin()
    {
        assert(msg.sender == owner || admins[msg.sender]);
        _;
    }
    
    event Deposit(address buyer, uint256 amount, uint256 depositID);
    event Accepted(address vendor, uint256 depositID);
    event Declined(address vendor, uint256 depositID);
    event Released(address buyer, address vendor, uint256 amount, uint256 depositID);
    event DepositReverted(address buyer, uint256 amount, uint256 depositID, address reverter);
    event DepositRevertedByOwner();
    event TokensReleasedByOwner(address vendor, uint256 amount, uint256 depositID);
    event AdminAdded(address admin);
    event AdminRemoved(address admin);
    
    constructor(address _tokenContract) public
    {
        CRAFTRToken = Token(_tokenContract);
    }
    
    /**
     * @dev Allows a BUYER to deposit tokens into the contract. Useful information are mapped and 
     * the countdown for the VENDOR is initialized. 
     * @param amount The amount of tokens to deposit
     * @param to The VENDOR address
     * @return The deposit ID
     */
    function deposit(uint256 amount, address to) public returns(uint256)
    {
        uint256 depositID = amount.add(now);
        inEscrow[depositID]._from = msg.sender;
        inEscrow[depositID]._to = to;
        inEscrow[depositID]._amount = amount;
        inEscrow[depositID]._expiryTime = now.add(round_interval);
        inEscrow[depositID]._accepted = false;
        inEscrow[depositID]._denied = false;
        inEscrow[depositID]._released = false;
        CRAFTRToken.transferFrom(msg.sender,address(this),amount);
        emit Deposit(msg.sender, amount, depositID);
        
        return depositID;
    }
    
    /**
     * @dev VENDOR accepts the deposit before the expiration
     * @param depositID The deposit ID
     */
    function acceptDeposit(uint256 depositID) public onlyVendor(msg.sender, depositID)
    {
        require(
            now <= inEscrow[depositID]._expiryTime 
            && !inEscrow[depositID]._denied 
            && !inEscrow[depositID]._accepted
        );
        inEscrow[depositID]._accepted = true;
        emit Accepted(msg.sender, depositID);
    }

    /**
     * @dev VENDOR cancels the deposit before the expiration
     * @param depositID The deposit ID
     */
    function declineDeposit(uint256 depositID) public onlyVendor(msg.sender, depositID)
    {
        require(
            now <= inEscrow[depositID]._expiryTime 
            && !inEscrow[depositID]._denied 
            && !inEscrow[depositID]._accepted
        );
        inEscrow[depositID]._denied = true;
        emit Declined(msg.sender, depositID);
    }
    
    /**
     * @dev BUYER releases the deposit to the VENDOR
     * @param depositID The deposit ID
     */
    function releaseTokens(uint256 depositID) public onlyBuyer(msg.sender, depositID) 
    {
        require(
            inEscrow[depositID]._accepted 
            && !inEscrow[depositID]._denied 
            && !inEscrow[depositID]._released
        );
        CRAFTRToken.transfer(inEscrow[depositID]._to, inEscrow[depositID]._amount);
        inEscrow[depositID]._released = true;
        emit Released(msg.sender, inEscrow[depositID]._to, inEscrow[depositID]._amount, depositID);
    }
    
    /**
     * @dev BUYER reverts the deposit to itself
     * @param depositID The deposit ID
     */
    function revertDeposit(uint256 depositID) public onlyBuyer(msg.sender, depositID)
    {
        require(
            (
                now > inEscrow[depositID]._expiryTime 
                && !inEscrow[depositID]._accepted 
                && !inEscrow[depositID]._released 
                && !inEscrow[depositID]._denied
            ) || (
                inEscrow[depositID]._denied
            )
        );

        CRAFTRToken.transfer(msg.sender,inEscrow[depositID]._amount);
        emit DepositReverted(msg.sender, inEscrow[depositID]._amount, depositID, msg.sender);
        inEscrow[depositID]._released = true;
    }
    
    /**
     * @dev ADMIN reverts tokens to BUYER after a dispute resolution
     * @param depositID The deposit ID
     */
    function adminRevertDeposit(uint256 depositID) public onlyAdmin
    {
        require(
            inEscrow[depositID]._accepted 
            && !inEscrow[depositID]._released 
            && !inEscrow[depositID]._denied
        );
        CRAFTRToken.transfer(inEscrow[depositID]._from,inEscrow[depositID]._amount);
        emit DepositReverted(inEscrow[depositID]._from, inEscrow[depositID]._amount, depositID, msg.sender);
        inEscrow[depositID]._released = true;
        emit DepositRevertedByOwner();
    }
    
    /**
     * @dev ADMIN releases tokens to VENDOR after a dispute resolution
     * @param depositID The deposit ID
     */
    function adminReleaseTokens(uint256 depositID) public onlyAdmin
    {
        require(
            inEscrow[depositID]._accepted 
            && !inEscrow[depositID]._released 
            && !inEscrow[depositID]._denied
        );
        CRAFTRToken.transfer(inEscrow[depositID]._to, inEscrow[depositID]._amount);
        inEscrow[depositID]._released = true;
        emit TokensReleasedByOwner(inEscrow[depositID]._to, inEscrow[depositID]._amount, depositID);
    }

    /**
     * @dev OWNER sets a new ADMIN
     * @param admin The address of the ADMIN
     */
    function setAdmin(address admin) public onlyOwner 
    {
        admins[admin] = true;
        emit AdminAdded(admin);
    }

    /**
     * @dev OWNER removes an ADMIN
     * @param admin The address of the ADMIN
     */
    function unsetAdmin(address admin) public onlyOwner 
    {
        admins[admin] = false;
        emit AdminRemoved(admin);
    }
    
}