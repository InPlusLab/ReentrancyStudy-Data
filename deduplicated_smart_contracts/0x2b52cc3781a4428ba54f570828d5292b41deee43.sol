/**
 *Submitted for verification at Etherscan.io on 2019-09-10
*/

// File: @gnosis.pm/util-contracts/contracts/Token.sol

/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
pragma solidity ^0.5.2;

/// @title Abstract token contract - Functions to be implemented by token contracts
contract Token {
    /*
     *  Events
     */
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    /*
     *  Public functions
     */
    function transfer(address to, uint value) public returns (bool);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function approve(address spender, uint value) public returns (bool);
    function balanceOf(address owner) public view returns (uint);
    function allowance(address owner, address spender) public view returns (uint);
    function totalSupply() public view returns (uint);
}

// File: contracts/Disbursement.sol

pragma solidity ^0.5.8;



/// @title Disbursement contract - allows to distribute tokens over time
/// @author Stefan George - <stefan@gnosis.pm>
contract Disbursement {

    /*
     *  Storage
     */
    address public owner;
    address public receiver;
    address public wallet;
    uint public disbursementPeriod;
    uint public startDate;
    uint public withdrawnTokens;
    Token public token;

    /*
     *  Modifiers
     */
    modifier isOwner() {
        if (msg.sender != owner)
            revert("Only owner is allowed to proceed");
        _;
    }

    modifier isReceiver() {
        if (msg.sender != receiver)
            revert("Only receiver is allowed to proceed");
        _;
    }

    modifier isWallet() {
        if (msg.sender != wallet)
            revert("Only wallet is allowed to proceed");
        _;
    }

    modifier isSetUp() {
        if (address(token) == address(0))
            revert("Contract is not set up");
        _;
    }

    /*
     *  Public functions
     */
    /// @dev Constructor function sets contract owner and wallet address, which is allowed to withdraw all tokens anytime
    /// @param _receiver Receiver of vested tokens
    /// @param _wallet Gnosis multisig wallet address
    /// @param _disbursementPeriod Vesting period in seconds
    /// @param _startDate Start date of disbursement period (cliff)
    constructor(address _receiver, address _wallet, uint _disbursementPeriod, uint _startDate)
        public
    {
        if (_receiver == address(0) || _wallet == address(0) || _disbursementPeriod == 0)
            revert("Arguments are null");
        owner = msg.sender;
        receiver = _receiver;
        wallet = _wallet;
        disbursementPeriod = _disbursementPeriod;
        startDate = _startDate;
        if (startDate == 0){
          startDate = now;
        }
    }

    /// @dev Setup function sets external contracts' addresses
    /// @param _token Token address
    function setup(Token _token)
        public
        isOwner
    {
        if (address(token) != address(0) || address(_token) == address(0))
            revert("Setup was executed already or address is null");
        token = _token;
    }

    /// @dev Transfers tokens to a given address
    /// @param _to Address of token receiver
    /// @param _value Number of tokens to transfer
    function withdraw(address _to, uint256 _value)
        public
        isReceiver
        isSetUp
    {
        uint maxTokens = calcMaxWithdraw();
        if (_value > maxTokens){
          revert("Withdraw amount exceeds allowed tokens");
        }
        withdrawnTokens += _value;
        token.transfer(_to, _value);
    }

    /// @dev Transfers all tokens to multisig wallet
    function walletWithdraw()
        public
        isWallet
        isSetUp
    {
        uint balance = token.balanceOf(address(this));
        withdrawnTokens += balance;
        token.transfer(wallet, balance);
    }

    /// @dev Calculates the maximum amount of vested tokens
    /// @return Number of vested tokens to withdraw
    function calcMaxWithdraw()
        public
        view
        returns (uint)
    {
        uint maxTokens = (token.balanceOf(address(this)) + withdrawnTokens) * (now - startDate) / disbursementPeriod;
        if (withdrawnTokens >= maxTokens || startDate > now){
          return 0;
        }
        return maxTokens - withdrawnTokens;
    }
}