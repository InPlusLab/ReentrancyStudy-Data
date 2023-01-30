/**

 *Submitted for verification at Etherscan.io on 2019-06-07

*/



pragma solidity >=0.4.22 <0.6.0;

// ----------------------------------------------------------------------------

// VeChain Fungible Token Standard Interface

// https://github.com/vechain/VIPs/blob/master/vips/VIP-180.md

// ----------------------------------------------------------------------------

interface VIP180 {

    function decimals() external view returns(uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _tokenOwner) external view returns (uint256);

    function transfer(address _to, uint _tokens) external returns (bool);

    function transferFrom(address _from, address _to, uint _tokens) external returns (bool);

    function approve(address _spender, uint _tokens) external returns (bool);

    function allowance(address _tokenOwner, address _spender) external view returns (uint256);



    event Transfer(address indexed _from, address indexed _to, uint _tokens);

    event Approval(address indexed _tokenOwner, address indexed _spender, uint _tokens);

}



//-----------------------------------------------------------------------------

/// @title Locked Token contract

/// @notice defines token locking and unlocking functionality.

//-----------------------------------------------------------------------------

contract LockedTokenManager {

    //-------------------------------------------------------------------------

    /// @dev Emits when VIP-180 tokens become locked for any number of months by

    ///  any mechanism.

    //-------------------------------------------------------------------------

    event Lock (address indexed _tokenOwner, address indexed _tokenAddress, uint _tokens);



    //-------------------------------------------------------------------------

    /// @dev Emits when VIP-180 tokens become unlocked by any mechanism.

    //-------------------------------------------------------------------------

    event Unlock (address indexed _tokenOwner, address indexed _tokenAddress, uint _tokens);



    // Unix Timestamp for 4-1-2019 at 00:00:00.

    //  Used to calculate months since release.

    uint constant FIRST_MONTH_TIMESTAMP = 1554076800;

    // Maximum number of months into the future locked tokens can be recovered.

    uint constant MAXIMUM_LOCK_MONTHS = 240;

    // Tracks months since release. Starts at 0 and increments every 30.4375 days.

    uint public currentMonth;

    // Locked token balances by unlock month

    mapping (address => mapping(address => mapping(uint => uint))) tokensLockedUntilMonth;

    

    //-------------------------------------------------------------------------

    /// @dev Throws if parameter is zero

    //-------------------------------------------------------------------------

    modifier notZero(uint _param) {

        require (_param != 0, "Parameter cannot be zero");

        _;

    }



    //-------------------------------------------------------------------------

    /// @notice Lock `_tokens` tokens for `_numberOfMonths` months.

    /// @dev Throws if amount to lock is zero. Throws if numberOfMonths is zero

    ///  or greater than maximum months. Throws if sender has insufficient 

    ///  balance to lock. Throws if token address does not allow transfer.

    /// @param _tokenAddress Address of the token contract to lock from.

    /// @param _numberOfMonths The number of months the tokens will be locked.

    /// @param _tokens The number of tokens to lock.

    //-------------------------------------------------------------------------

    function lock(address _tokenAddress, uint _tokens, uint _numberOfMonths) 

        public 

        notZero(_tokens)

        returns(bool)

    {

        // number of months must be a valid amount.

        require (

            _numberOfMonths > 0 && _numberOfMonths <= MAXIMUM_LOCK_MONTHS,

            "Invalid number of months"

        );



        // transfer amount from sender

        VIP180 tokenContract = VIP180(_tokenAddress);

        tokenContract.transferFrom(msg.sender, address(this), _tokens);

        

        // add amount to sender's locked token balance

        tokensLockedUntilMonth[msg.sender][_tokenAddress][currentMonth + _numberOfMonths] += _tokens;

        // emit lock event

        emit Lock(msg.sender, _tokenAddress, _tokens);



        return true;

    }

    

    //-------------------------------------------------------------------------

    /// @notice LockFrom `_tokens` tokens for `_numberOfMonths` months.

    /// @dev Throws if amount to lock is zero. Throws if numberOfMonths is zero

    ///  or greater than maximum months. Throws if token holder has insufficient 

    ///  balance to lock. Throws if transferFrom fails.

    /// @param _tokenHolder Address of token holder whose tokens will be locked.

    /// @param _tokenAddress Address of the token contract to lock from.

    /// @param _numberOfMonths The number of months the tokens will be locked.

    /// @param _tokens The number of tokens to lock.

    //-------------------------------------------------------------------------

    function lockFrom(

        address _tokenHolder, 

        address _tokenAddress, 

        uint _tokens, 

        uint _numberOfMonths

    ) public notZero(_tokens) returns(bool) {

        // number of months must be a valid amount.

        require (

            _numberOfMonths > 0 && _numberOfMonths <= MAXIMUM_LOCK_MONTHS,

            "Invalid number of months"

        );



        // transfer amount from sender

        VIP180 tokenContract = VIP180(_tokenAddress);

        tokenContract.transferFrom(_tokenHolder, address(this), _tokens);

        

        // add amount to sender's locked token balance

        tokensLockedUntilMonth[_tokenHolder][_tokenAddress][currentMonth + _numberOfMonths] += _tokens;

        // emit lock event

        emit Lock(_tokenHolder, _tokenAddress, _tokens);



        return true;

    }



    //-------------------------------------------------------------------------

    /// @notice Send `_tokens` tokens to `_to`, then lock for `_numberOfMonths`

    ///  months.

    /// @dev Throws if amount to send is zero. Throws if `msg.sender` has

    ///  insufficient balance for transfer. Throws if _to is the zero address.

    ///  Throws if numberOfMonths is zero or greater than maximum months.

    ///  Emits transfer and lock events.

    /// @param _to The address to where tokens are being sent and locked.

    /// @param _tokenAddress Address of the contract to transfer and lock from.

    /// @param _numberOfMonths The number of months the tokens will be locked.

    /// @param _tokens The number of tokens to send and lock.

    //-------------------------------------------------------------------------

    function transferAndLock(

        address _to,

        address _tokenAddress,

        uint _tokens,

        uint _numberOfMonths

    ) external returns (bool) {

        // number of months must be a valid amount.

        require (

            _numberOfMonths > 0 && _numberOfMonths <= MAXIMUM_LOCK_MONTHS,

            "Invalid number of months"

        );



        // transfer amount from sender

        VIP180 tokenContract = VIP180(_tokenAddress);

        tokenContract.transferFrom(msg.sender, address(this), _tokens);

        

        // add amount to sender's locked token balance

        tokensLockedUntilMonth[_to][_tokenAddress][currentMonth + _numberOfMonths] += _tokens;

        // emit lock event

        emit Lock(_to, _tokenAddress, _tokens);



        return true;

    }

    

    //-------------------------------------------------------------------------

    /// @notice Send `_tokens` tokens to `_to`, then lock for `_numberOfMonths`

    ///  months.

    /// @dev Throws if amount to send is zero. Throws if `msg.sender` has

    ///  insufficient balance for transfer. Throws if _to is the zero address.

    ///  Throws if numberOfMonths is zero or greater than maximum months.

    ///  Throws if transferFrom fails. Emits transfer and lock events.

    /// @param _from The address from where tokens are being sent.

    /// @param _to The address to where tokens are being sent and locked.

    /// @param _tokenAddress Address of the contract to transfer and lock from.

    /// @param _numberOfMonths The number of months the tokens will be locked.

    /// @param _tokens The number of tokens to send and lock.

    //-------------------------------------------------------------------------

    function transferFromAndLock(

        address _from,

        address _to,

        address _tokenAddress,

        uint _tokens,

        uint _numberOfMonths

    ) external returns (bool) {

        // number of months must be a valid amount.

        require (

            _numberOfMonths > 0 && _numberOfMonths <= MAXIMUM_LOCK_MONTHS,

            "Invalid number of months"

        );



        // transfer amount from sender

        VIP180 tokenContract = VIP180(_tokenAddress);

        tokenContract.transferFrom(_from, address(this), _tokens);

        

        // add amount to sender's locked token balance

        tokensLockedUntilMonth[_to][_tokenAddress][currentMonth + _numberOfMonths] += _tokens;

        // emit lock event

        emit Lock(_to, _tokenAddress, _tokens);



        return true;

    }



    //-------------------------------------------------------------------------

    /// @notice Unlock all qualifying tokens for `_tokenOwner`. Sender must 

    ///  either be tokenOwner or an approved address.

    /// @dev If tokenOwner is empty, tokenOwner is set to msg.sender. Throws

    ///  if sender is not tokenOwner or an approved spender (allowance > 0).

    /// @param _tokenOwner The token owner whose tokens will unlock.

    /// @param _tokenAddress The token contract address.

    //-------------------------------------------------------------------------

    function unlockAll(address _tokenOwner, address _tokenAddress) external {

        // create local variable for token owner

        address addressToUnlock = _tokenOwner;

        // if tokenOwner parameter is empty, set tokenOwner to sender

        if (addressToUnlock == address(0)) {

            addressToUnlock = msg.sender;

        }

        VIP180 tokenContract = VIP180(_tokenAddress);

        // sender must either be tokenOwner or an approved address

        if (msg.sender != addressToUnlock) {

            require (

                tokenContract.allowance(addressToUnlock, msg.sender) > 0,

                "Not authorized to unlock for this address"

            );

        }



        // create local variable for unlock total

        uint tokensToUnlock;

        // check each month starting from 1 month after release

        for (uint i = 1; i <= currentMonth; ++i) {

            // add qualifying tokens to tokens to unlock variable

            tokensToUnlock += tokensLockedUntilMonth[addressToUnlock][_tokenAddress][i];

            // set locked token balance of month i to 0 

            tokensLockedUntilMonth[addressToUnlock][_tokenAddress][i] = 0;

        }

        // add qualifying tokens back to token owner's account balance

        tokenContract.transfer(addressToUnlock, tokensToUnlock);

        // emit unlock event

        emit Unlock (addressToUnlock, _tokenAddress, tokensToUnlock);

    }



    //-------------------------------------------------------------------------

    /// @notice Unlock all tokens locked until `month` months since April 2019 

    ///  for `tokenOwner`. Sender must be tokenOwner or an approved address.

    /// @dev If tokenOwner is empty, tokenOwner is set to msg.sender. Throws

    ///  if sender is not tokenOwner or an approved spender (allowance > 0).

    /// @param _tokenOwner The token owner whose tokens will unlock.

    /// @param _tokenAddress The token contract address.

    /// @param _month Number of months since April 2019.

    //-------------------------------------------------------------------------

    function unlockByMonth(

        address _tokenOwner, 

        address _tokenAddress, 

        uint _month

    ) external {

        // create local variable for token owner

        address addressToUnlock = _tokenOwner;

        // if tokenOwner parameter is empty, set tokenOwner to sender

        if (addressToUnlock == address(0)) {

            addressToUnlock = msg.sender;

        }

        VIP180 tokenContract = VIP180(_tokenAddress);

        // sender must either be tokenOwner or an approved address

        if (msg.sender != addressToUnlock) {

            require (

                tokenContract.allowance(addressToUnlock, msg.sender) > 0,

                "Not authorized to unlock for this address"

            );

        }

        // month of locked tokens must be less than or equal to current month

        require (

            currentMonth >= _month,

            "Tokens from this month cannot be unlocked yet"

        );

        // create local variable for unlock amount

        uint tokensToUnlock = tokensLockedUntilMonth[addressToUnlock][_tokenAddress][_month];

        // set locked token balance of month to 0

        tokensLockedUntilMonth[addressToUnlock][_tokenAddress][_month] = 0;

        // add qualifying tokens back to token owner's account balance

        tokenContract.transfer(addressToUnlock, tokensToUnlock);

        // emit unlock event

        emit Unlock(addressToUnlock, _tokenAddress, tokensToUnlock);

    }



    //-------------------------------------------------------------------------

    /// @notice Update the current month.

    /// @dev Throws if less than 30.4375 days has passed since currentMonth.

    //-------------------------------------------------------------------------

    function updateMonthsSinceRelease() external {

        // check if months since first month is greater than the currentMonth

        uint secondsSinceRelease = block.timestamp - FIRST_MONTH_TIMESTAMP;

        require (

            currentMonth < secondsSinceRelease / (30 * 1 days + 10 * 1 hours + 30 * 1 minutes),

            "Cannot update month yet"

        );

        // increment months since release

        ++currentMonth;

    }



    //-------------------------------------------------------------------------

    /// @notice View the total locked token holdings of `tokenOwner`. Only

    ///  displays tokens from _tokenAddress.

    /// @param _tokenOwner The locked token owner.

    /// @param _tokenAddress The token contract address.

    /// @return Total locked token holdings of a token owner.

    //-------------------------------------------------------------------------

    function viewTotalLockedTokens(

        address _tokenOwner,

        address _tokenAddress

    ) public view returns (uint lockedTokens) {

        for (uint i = 1; i < currentMonth + MAXIMUM_LOCK_MONTHS; ++i) {

            lockedTokens += tokensLockedUntilMonth[_tokenOwner][_tokenAddress][i];

        }

    }



    //-------------------------------------------------------------------------

    /// @notice View the locked token holdings of `tokenOwner` unlockable in

    ///  `_month` months since April 2019.

    /// @param _tokenOwner The locked token owner.

    /// @param _tokenAddress The token contract's address.

    /// @param _month Months since April 2019 the tokens are locked until.

    /// @return Locked token holdings by month.

    //-------------------------------------------------------------------------

    function viewLockedTokensByMonth(

        address _tokenOwner,

        address _tokenAddress,

        uint _month

    ) external view returns (uint) {

        return tokensLockedUntilMonth[_tokenOwner][_tokenAddress][_month];

    }

}