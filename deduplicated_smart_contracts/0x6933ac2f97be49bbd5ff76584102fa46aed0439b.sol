/**
 *Submitted for verification at Etherscan.io on 2020-12-17
*/

pragma solidity ^0.4.24;


contract ERC20Token {

    function balanceOf(address _owner) constant public returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);
}


contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract BatchAirDrop is Ownable {

    event ApproveToken(address indexed owner, address indexed spender, uint256 value);

    constructor() public {}

    function() payable public {}


    /**
     * batch transfer for ERC20 token.(the same amount)
     *
     * @param _contractAddress ERC20 token address
     * @param _addresses array of address to sent
     * @param _value transfer amount
     */
    function batchTransferToken(address _contractAddress, address[] _addresses, uint _value) public onlyOwner {
        ERC20Token token = ERC20Token(_contractAddress);
        // transfer circularly
        for (uint i = 0; i < _addresses.length; i++) {
            token.transfer(_addresses[i], _value);
        }
    }

    /**
     * batch transfer for ERC20 token.
     *
     * @param _contractAddress ERC20 token address
     * @param _addresses array of address to sent
     * @param _values array of transfer amount
     */
    function batchTransferTokenS(address _contractAddress, address[] _addresses, uint[] _values) public onlyOwner {
        require(_addresses.length == _values.length);

        ERC20Token token = ERC20Token(_contractAddress);
        // transfer circularly
        for (uint i = 0; i < _addresses.length; i++) {
            token.transfer(_addresses[i], _values[i]);
        }
    }

    /**
     * batch transfer for ETH.(the same amount)
     *
     * @param _addresses array of address to sent
     */
    function batchTransferETH(address[] _addresses) payable public onlyOwner {
        // transfer circularly
        for (uint i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(msg.value / _addresses.length);
        }
    }

    /**
     * batch transfer for ETH.
     *
     * @param _addresses array of address to sent
     * @param _values array of transfer amount
     */
    function batchTransferETHS(address[] _addresses, uint[] _values) payable public onlyOwner {
        require(_addresses.length == _values.length);

        // transfer circularly
        for (uint i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(_values[i]);
        }
    }

    /**
     *  Recovery donated ether
     */
    function collectEtherBack(address collectorAddress) public onlyOwner {
        uint256 b = address(this).balance;
        require(b > 0);
        require(collectorAddress != 0x0);

        collectorAddress.transfer(b);
    }

    /**
    *  Recycle other ERC20 tokens
    */
    function collectOtherTokens(address tokenContract, address collectorAddress) onlyOwner public returns (bool) {
        ERC20Token t = ERC20Token(tokenContract);

        uint256 b = t.balanceOf(address(this));
        return t.transfer(collectorAddress, b);
    }

}