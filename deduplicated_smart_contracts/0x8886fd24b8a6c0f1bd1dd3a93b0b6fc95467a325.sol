/**
 *Submitted for verification at Etherscan.io on 2019-09-11
*/

pragma solidity 0.5.11;

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

//////////////////
// Permissions
//                               Admin       User
// CRUD users                      x
// depositTokens                   x
// returnTokens                    x
// getTokensAvailableToMe                     x
// withdrawTokens                             x
////////

contract CraftrDropper is Ownable
{
    using SafeMath for uint256;
    
    Token CRAFTRToken;
    address contractAddress;

    struct TokenAirdrop 
    {
        address contractAddress;
        uint contractAddressID; // The id of the airdrop within a token address
        address tokenOwner;
        uint airdropDate;
        uint tokenBalance; // Current balance
        uint totalDropped; // Total to distribute
        uint usersAtDate; // How many users were signed at airdrop date
    }

    struct User 
    {
        address userAddress;
        uint signupDate;
        uint value;
        // User -> Airdrop id# -> balance
        mapping (address => mapping (uint => uint)) withdrawnBalances;
    }

    // Maps the tokens available in contract. Keyed by token address
    mapping (address => TokenAirdrop[]) public airdropSupply;

    // Users List
    mapping (address => User) public signups;
    uint public userSignupCount = 0;

    // Admins List
    mapping (address => bool) public admins;

    modifier onlyOwner 
    {
        assert(msg.sender == owner);
        _;
    }

    modifier onlyAdmin 
    {
        assert(msg.sender == owner || admins[msg.sender]);
        _;
    }

    event TokenDeposited(address _contractAddress, address _airdropper,uint _distributionSupply,uint creationDate);
    event UserAdded(address _userAddress, uint _value, uint _signupDate);
    event UsersAdded(address[] _userAddress, uint _value, uint _signupDate);
    event TokenWithdrawn(address _contractAddress, address _userAddress, uint _tokensWithdrawn, uint _withdrawalDate);

    constructor(address _tokenContract) public 
    {
        contractAddress = _tokenContract;
        CRAFTRToken = Token(_tokenContract);
    }

    /////////////////////
    // Owner / Admin functions
    /////////////////////

    /**
     * @dev allows owner to grant/revoke admin privileges to other accounts
     * @param _admin is the account to be granted/revoked admin privileges
     * @param isAdmin is whether or not to grant or revoke privileges.
     */
    function setAdmin(address _admin, bool isAdmin) public onlyOwner
    {
        admins[_admin] = isAdmin;
    }
    
    function insertUser(address _user, uint _value) public onlyAdmin 
    {
        require(signups[_user].userAddress == address(0));
        _value = _value.mul(10**18);
        signups[_user] = User(_user,now,_value);
        userSignupCount++;
        emit UserAdded(_user,_value,now);
    }

    function insertUsers(address[] memory _users, uint _value) public onlyOwner 
    {
        _value = _value.mul(10**18);
        for (uint i = 0; i < _users.length; i++)
        {
            require(signups[_users[i]].userAddress == address(0));
            signups[_users[i]] = User(_users[i],now,_value);
            userSignupCount++;
        }
        emit UsersAdded(_users,_value,now);
    }

    function deleteUser(address _user) public onlyAdmin
    {
        require(signups[_user].userAddress == _user);
        delete signups[_user];
        userSignupCount--;
    }

    function deleteUsers(address[] memory _users) public onlyOwner
    {
        for (uint i = 0; i < _users.length; i++)
        {
            require(signups[_users[i]].userAddress == _users[i]);
            delete signups[_users[i]];
            userSignupCount--;
        }
    }

     /**
     * @dev Transfers tokens to contract and sets the Token Airdrop
     * @notice Before calling this function, you must have given the Token Contract
     * an allowance of the tokens to distribute.
     * Call approve([this contract's address],_distributionSupply); on the ERC20 token cotnract first
     * @param _distributionSupply is the tokens that will be evenly distributed among all current users
     * Enter the number of tokens (the function multiplies by the token decimals)
     */
    function depositTokens(uint _distributionSupply) public onlyOwner
    {
        //Multiply number entered by token decimals.
        _distributionSupply = _distributionSupply.mul(10**18);

        TokenAirdrop memory ta = TokenAirdrop(contractAddress,airdropSupply[contractAddress].length,msg.sender,now,_distributionSupply,_distributionSupply,userSignupCount);
        airdropSupply[contractAddress].push(ta);

        // Transfer the tokens
        CRAFTRToken.transferFrom(msg.sender,address(this),_distributionSupply);

        emit TokenDeposited(contractAddress,ta.tokenOwner,ta.totalDropped,ta.airdropDate);
    }

    /**
     * @dev returns unclaimed tokens to the airdropper
     */
    function returnTokens() public onlyOwner
    {
        uint tokensToReturn = 0;

        for (uint i = 0; i < airdropSupply[contractAddress].length; i++)
        {
            TokenAirdrop storage ta = airdropSupply[contractAddress][i];
            if(msg.sender == ta.tokenOwner)
            {
                tokensToReturn = tokensToReturn.add(ta.tokenBalance);
                ta.tokenBalance = 0;
            }
        }
        CRAFTRToken.transfer(msg.sender,tokensToReturn);
        emit TokenWithdrawn(contractAddress,msg.sender,tokensToReturn,now);
    }

    /////////////////////
    // User functions
    /////////////////////

    /**
     * @dev calculates the amount of tokens the user will be able to withdraw
     * Given a token address, the function checks all airdrops with the same address
     * @return totalTokensAvailable is the tokens calculated
     */
    function getTokensAvailableToMe(address myAddress) view public returns (uint)
    {
        // Get User instance, given the sender account
        User storage user = signups[myAddress];
        require(user.userAddress != address(0));

        uint totalTokensAvailable = 0;
        for (uint i = 0; i < airdropSupply[contractAddress].length; i++)
        {
            uint _withdrawnBalance = user.withdrawnBalances[contractAddress][i];

            // if the user has not alreay withdrawn the tokens, count them
            if(_withdrawnBalance < user.value)
            {
                totalTokensAvailable = totalTokensAvailable.add(user.value);
            }
        }
        // Readable output
        totalTokensAvailable = totalTokensAvailable.div(10**18);
        return totalTokensAvailable;
    }

    /**
     * @dev calculates and withdraws the amount of tokens the user has been awarded by airdrops
     * Given a token address, the function checks all airdrops with the same
     * address and withdraws the corresponding tokens for the user.
     */
    function withdrawTokens() public 
    {
        // Get the instance of the current user
        User storage user = signups[msg.sender];
        // Check if user exists
        require(user.userAddress != address(0));

        uint totalTokensToTransfer = 0;

        // For each airdrop made for this token (token owner may have done several airdrops at any given point)
        for (uint i = 0; i < airdropSupply[contractAddress].length; i++)
        {
            TokenAirdrop storage ta = airdropSupply[contractAddress][i];

            uint _withdrawnBalance = user.withdrawnBalances[contractAddress][i];

            // if the user has not alreay withdrawn the tokens
            if(_withdrawnBalance < user.value)
            {
                // Register the tokens withdrawn by the user and total tokens withdrawn
                user.withdrawnBalances[contractAddress][i] = user.value;

                // substract tokens to be withdrawn from total amount reserved for airdrops
                ta.tokenBalance = ta.tokenBalance.sub(user.value);

                // instance the tokens to be paid
                totalTokensToTransfer = totalTokensToTransfer.add(user.value);
            }
        }

        // Transfer tokens from all airdrops that correspond to this user
        CRAFTRToken.transfer(msg.sender,totalTokensToTransfer);

        delete signups[msg.sender];
        userSignupCount--;

        emit TokenWithdrawn(contractAddress,msg.sender,totalTokensToTransfer,now);
    }
}