/**
 *Submitted for verification at Etherscan.io on 2019-09-02
*/

pragma solidity 0.5.10;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) internal {
        require(initialOwner != address(0));
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

/**
 * @dev Multisend contract.
 * @author www.grox.solutions
 */
contract EtherPayment is Ownable, ReentrancyGuard {

    uint8 private _recipientLimit = 7;

    address payable public wallet;

    /**
    *  Constructor
    *
    *  Initializes contract
    */
    constructor(address _owner, address payable _wallet) public Ownable(_owner) {
        changeWallet(_wallet);
    }

    /**
    *  Send ETH to each recipient
    *
    * @param _recipients - array of recipient addresses
    * @param _etherAmounts - array of amounts of ETH to send
    */
    function multiTransfer(address payable[] memory _recipients, uint256[] memory _etherAmounts) public payable nonReentrant {
        require(_recipients.length == _etherAmounts.length);
        require(_recipients.length <= _recipientLimit);

        // Seng ETH to recipients
        for (uint256 i = 0; i < _recipients.length; i++) {
            _recipients[i].send(_etherAmounts[i]);
        }

        if (address(this).balance > 0) {
            wallet.send(address(this).balance);
        }
    }

    /**
    *  Change Wallet to recieve remaining ETH
    *
    * @param _newWallet - new address
    */
    function changeWallet(address payable _newWallet) public onlyOwner {
        require(_newWallet != address(0));
        wallet = _newWallet;
    }

}