/**
 *Submitted for verification at Etherscan.io on 2019-09-10
*/

pragma solidity ^0.4.20;

contract Ownable {
    
    address public owner;
    
    event OwnershipTransferred(address indexed from, address indexed to);
    
    
    /**
     * Constructor assigns ownership to the address used to deploy the contract.
     * */
    function Ownable() public {
        owner = 0x202abc6cf98863ee0126c182ca325a33a867acba ;
    }


    /**
     * Any function with this modifier in its method signature can only be executed by
     * the owner of the contract. Any attempt made by any other account to invoke the 
     * functions with this modifier will result in a loss of gas and the contract's state
     * will remain untampered.
     * */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /**
     * Allows for the transfer of ownership to another address;
     * 
     * @param _newOwner The address to be assigned new ownership.
     * */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0)
            && _newOwner != owner 
        );
        OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();
    
    bool public paused = false;
    
    
    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    
    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }
    
    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }
    
    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}


contract TokenTransferInterface {
    function transfer(address _to, uint256 _value) public;
}


contract SelfDropCYFM is Pausable {
    
    mapping (address => bool) public addrHasClaimedTokens;
    
    TokenTransferInterface public constant token = TokenTransferInterface(0x32b87fb81674aa79214e51ae42d571136e29d385);
    
    uint256 public tokensToSend = 5000e18;
    
    
    function changeTokensToSend(uint256 _value) public onlyOwner {
        require(_value != tokensToSend);
        require(_value > 0);
        tokensToSend = (_value * (10 ** 18));
    }
    
    
    function() public payable whenNotPaused {
        require(!addrHasClaimedTokens[msg.sender]);
        require(msg.value == 0);
        addrHasClaimedTokens[msg.sender] = true;
        token.transfer(msg.sender, tokensToSend);
    }
}