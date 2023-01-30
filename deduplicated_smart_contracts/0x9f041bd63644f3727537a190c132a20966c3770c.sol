pragma solidity ^0.4.17;

/**
 * Allows one to send EIP-20 tokens to multiple addresses cheaply.
 * Copyright &#169; 2017 by ABDK Consulting https://abdk.consulting/
 * Author: Mikhail Vladimirov <mikhail.vladimirov[at]gmail.com>
 */
contract BatchTokenSender {
    /**
     * If you like this contract, you may send some ether to this address and
     * it will be used to develop more useful contracts available to everyone.
     */
    address public donationAddress;

    /**
     * Create new Batch Token Sender with given donation address.
     *
     * @param _donationAddress donation address
     */
    function BatchTokenSender (address _donationAddress) public {
        donationAddress = _donationAddress;
    }

    /**
     * Encode transfer amount and recepient address as a single uin256 value.
     *
     * @param _lotsNumber transfer amount as number of lots
     * @param _to transfer recipient address
     * @return encoded transfer
     */
    function encodeTransfer (uint96 _lotsNumber, address _to)
    public pure returns (uint256 _encodedTransfer) {
        return (_lotsNumber << 160) | uint160 (_to);
    }

    /**
     * Perform multiple token transfers from message sender&#39;s address.
     *
     * @param _token EIP-20 token smart contract that manages tokens to be sent
     * @param _lotSize number of tokens in lot
     * @param _transfers an array or encoded transfers to perform
     */
    function batchSend (
        Token _token, uint160 _lotSize, uint256 [] _transfers) public {
        uint256 count = _transfers.length;
        for (uint256 i = 0; i < count; i++) {
            uint256 transfer = _transfers [i];
            uint256 value = (transfer >> 160) * _lotSize;
            address to = address (
                transfer & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            if (!_token.transferFrom (msg.sender, to, value)) revert ();
        }
    }
}

/**
 * EIP-20 standard token interface, as defined
 * <a href="https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md">here</a>.
 */
contract Token {
    /**
     * Get total number of tokens in circulation.
     *
     * @return total number of tokens in circulation
     */
    function totalSupply ()
    public constant returns (uint256 supply);

    /**
     * Get number of tokens currently belonging to given owner.
     *
     * @param _owner address to get number of tokens currently belonging to the
     *        owner of
     * @return number of tokens currently belonging to the owner of given
     *         address
     */
    function balanceOf (address _owner)
    public constant returns (uint256 balance);

    /**
     * Transfer given number of tokens from message sender to given recipient.
     *
     * @param _to address to transfer tokens to the owner of
     * @param _value number of tokens to transfer to the owner of given address
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transfer (address _to, uint256 _value)
    public returns (bool success);

    /**
     * Transfer given number of tokens from given owner to given recipient.
     *
     * @param _from address to transfer tokens from the owner of
     * @param _to address to transfer tokens to the owner of
     * @param _value number of tokens to transfer from given owner to given
     *        recipient
     * @return true if tokens were transferred successfully, false otherwise
     */
    function transferFrom (address _from, address _to, uint256 _value)
    public returns (bool success);

    /**
     * Allow given spender to transfer given number of tokens from message
     * sender.
     *
     * @param _spender address to allow the owner of to transfer tokens from
     *        message sender
     * @param _value number of tokens to allow to transfer
     * @return true if token transfer was successfully approved, false otherwise
     */
    function approve (address _spender, uint256 _value)
    public returns (bool success);

    /**
     * Tell how many tokens given spender is currently allowed to transfer from
     * given owner.
     *
     * @param _owner address to get number of tokens allowed to be transferred
     *        from the owner of
     * @param _spender address to get number of tokens allowed to be transferred
     *        by the owner of
     * @return number of tokens given spender is currently allowed to transfer
     *         from given owner
     */
    function allowance (address _owner, address _spender)
    public constant returns (uint256 remaining);

    /**
     * Logged when tokens were transferred from one owner to another.
     *
     * @param _from address of the owner, tokens were transferred from
     * @param _to address of the owner, tokens were transferred to
     * @param _value number of tokens transferred
     */
    event Transfer (address indexed _from, address indexed _to, uint256 _value);

    /**
     * Logged when owner approved his tokens to be transferred by some spender.
     * @param _owner owner who approved his tokens to be transferred
     * @param _spender spender who were allowed to transfer the tokens belonging
     *        to the owner
     * @param _value number of tokens belonging to the owner, approved to be
     *        transferred by the spender
     */
    event Approval (
        address indexed _owner, address indexed _spender, uint256 _value);
}