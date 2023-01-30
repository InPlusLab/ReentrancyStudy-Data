/**

 *Submitted for verification at Etherscan.io on 2019-06-07

*/



pragma solidity >=0.4.22 <0.6.0;



//-----------------------------------------------------------------------------

/// @title Eight Hour Token contract

/// @notice defines standard ERC-20 functionality.

//-----------------------------------------------------------------------------

contract EightHoursToken {

    //-------------------------------------------------------------------------

    /// @dev Emits when ownership of EHrT changes by any mechanism. Also emits

    ///  when tokens are destroyed ('to' == 0).

    //-------------------------------------------------------------------------

    event Transfer (address indexed _from, address indexed _to, uint _tokens);



    //-------------------------------------------------------------------------

    /// @dev Emits when an approved spender is changed or reaffirmed, or if

    ///  the allowance amount changes. The zero address indicates there is no

    ///  approved address.

    //-------------------------------------------------------------------------

    event Approval (

        address indexed _tokenOwner, 

        address indexed _spender, 

        uint _tokens

    );

    

    // total number of tokens in circulation.

    //  Burning tokens reduces this amount

    uint totalEHrT = (10 ** 10) * (10**18);    // ten billion

    // the token balances of all token holders

    mapping (address => uint) ehrtBalances;

    // approved spenders and allowances of all token holders

    mapping (address => mapping (address => uint)) allowances;



    constructor() public {

        ehrtBalances[msg.sender] = totalEHrT;

    }

    

    //-------------------------------------------------------------------------

    /// @dev Throws if tokenOwner has insufficient EHrT balance

    //-------------------------------------------------------------------------

    modifier sufficientFunds(address tokenOwner, uint tokens) {

        require (ehrtBalances[tokenOwner] >= tokens, "Insufficient balance");

        _;

    }



    //-------------------------------------------------------------------------

    /// @notice Send `(tokens/1000000000000000000).fixed(0,18)` EHrT to `to`.

    /// @dev Throws if `msg.sender` has insufficient balance for transfer.

    /// @param _to The address to where EHrT is being sent.

    /// @param _tokens The number of tokens to send.

    /// @return True upon successful transfer. Will throw if unsuccessful.

    //-------------------------------------------------------------------------

    function transfer(address _to, uint _tokens) 

        public

        sufficientFunds(msg.sender, _tokens)

        returns(bool) 

    {

        // subtract amount from sender

        ehrtBalances[msg.sender] -= _tokens;



        if (_to != address(0)) {

            // add amount to token receiver

            ehrtBalances[_to] += _tokens;

        }

        else {

            // burn amount

            totalEHrT -= _tokens;

        }



        // emit transfer event

        emit Transfer(msg.sender, _to, _tokens);

        

        return true;

    }



    //-------------------------------------------------------------------------

    /// @notice Send `(tokens/1000000000000000000).fixed(0,18)` EHrT from

    ///  `from` to `to`.

    /// @dev Throws if `msg.sender` has insufficient allowance for transfer.

    ///  Throws if `from` has insufficient balance for transfer.

    /// @param _from The address from where EHrT is being sent. Sender must be

    ///  an approved spender.

    /// @param _to The token owner whose EHrT is being sent.

    /// @param _tokens The number of tokens to send.

    /// @return True upon successful transfer. Will throw if unsuccessful.

    //-------------------------------------------------------------------------

    function transferFrom(address _from, address _to, uint _tokens) 

        public

        sufficientFunds(_from, _tokens)

        returns(bool) 

    {

        require (

            allowances[_from][msg.sender] >= _tokens, 

            "Insufficient allowance"

        );

        // subtract amount from sender's allowance

        allowances[_from][msg.sender] -= _tokens;

        // subtract amount from token owner

        ehrtBalances[_from] -= _tokens;



        if (_to != address(0)) {

            // add amount to token receiver

            ehrtBalances[_to] += _tokens;

        }

        else {

            // burn amount

            totalEHrT -= _tokens;

        }

        // emit transfer event

        emit Transfer(_from, _to, _tokens);



        return true;

    }



    //-------------------------------------------------------------------------

    /// @notice Allow `_spender` to withdraw from your account, multiple times,

    ///  up to `(tokens/1000000000000000000).fixed(0,18)` EHrT. Calling this

    ///  function overwrites the previous allowance of spender.

    /// @dev Emits approval event

    /// @param _spender The address to authorize as a spender

    /// @param _tokens The new token allowance of spender (in pWei).

    //-------------------------------------------------------------------------

    function approve(address _spender, uint _tokens) external returns(bool) {

        // set the spender's allowance to token amount

        allowances[msg.sender][_spender] = _tokens;

        // emit approval event

        emit Approval(msg.sender, _spender, _tokens);



        return true;

    }



    //-------------------------------------------------------------------------

    /// @notice Get the total number of tokens in circulation.

    /// @return Total tokens tracked by this contract.

    //-------------------------------------------------------------------------

    function totalSupply() external view returns (uint) { return totalEHrT; }



    //-------------------------------------------------------------------------

    /// @notice Get the number of EHrT tokens owned by `_tokenOwner`.

    /// @param _tokenOwner The EHrT token owner.

    /// @return The number of EHrT tokens owned by `tokenOwner` (in pWei).

    //-------------------------------------------------------------------------

    function balanceOf(address _tokenOwner) public view returns(uint) {

        return ehrtBalances[_tokenOwner];

    }



    //-------------------------------------------------------------------------

    /// @notice Get the remaining allowance of spender for token owner.

    /// @param _tokenOwner The EHrT token owner.

    /// @param _spender The approved spender address.

    /// @return The remaining allowance of spender for tokenOwner.

    //-------------------------------------------------------------------------

    function allowance(

        address _tokenOwner, 

        address _spender

    ) public view returns (uint) {

        return allowances[_tokenOwner][_spender];

    }



    //-------------------------------------------------------------------------

    /// @notice Get the token's name.

    /// @return The token's name as a string

    //-------------------------------------------------------------------------

    function name() external pure returns (string memory) { 

        return "Eight Hours Token"; 

    }



    //-------------------------------------------------------------------------

    /// @notice Get the token's ticker symbol.

    /// @return The token's ticker symbol as a string

    //-------------------------------------------------------------------------

    function symbol() external pure returns (string memory) { return "EHrT"; }



    //-------------------------------------------------------------------------

    /// @notice Get the number of allowed decimal places for the token.

    /// @return The number of allowed decimal places for the token.

    //-------------------------------------------------------------------------

    function decimals() external pure returns (uint8) { return 18; }

}