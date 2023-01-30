/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity 0.5.10;
pragma experimental ABIEncoderV2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
contract GachaDrop is Ownable {
    struct Drop {
        string name;
        uint periodToPlay;
        mapping(address => uint) timeTrackUser;
    }
    // uint public periodToPlay = 1; // 86400; // seconds
    mapping(string => Drop) public Drops;
    string[] public DropNames;
    event _random(address _from, uint _ticket, string _drop);
    event _changePeriodToPlay(string _drop, uint _period);
    constructor() public {
        Drops['GodsUnchained'].name = 'GodsUnchained';
        Drops['GodsUnchained'].periodToPlay = 1;
        DropNames.push('GodsUnchained');
    }
    function getDropNames() public view returns(string[] memory) {
        return DropNames;
    }
    function getAward(string memory _drop) public {
        require(isValidToPlay(_drop));
        Drops[_drop].timeTrackUser[msg.sender] = block.timestamp;
        emit _random(msg.sender, block.timestamp, Drops[_drop].name);
    }

    function isValidToPlay(string memory _drop) public view returns (bool){
        return Drops[_drop].periodToPlay <= now - Drops[_drop].timeTrackUser[msg.sender];
    }
    function changePeriodToPlay(string memory _drop, uint _period) onlyOwner public{
        if(Drops[_drop].periodToPlay == 0) {
            DropNames.push(_drop);
            Drops[_drop].name = _drop;
        }
        
        Drops[_drop].periodToPlay = _period;
        emit _changePeriodToPlay(_drop, _period);
    }

}