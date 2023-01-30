/**
 *Submitted for verification at Etherscan.io on 2020-01-16
*/

pragma solidity 0.5.11;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Random is Owned {

    uint256 public winner;
    uint nonce = 0;
    event generatedRandomNumber(uint256 randomNumber);
    
    constructor(address _owner) public {
        owner = _owner;
    }
    
    function random(uint256 minimum, uint256 maximum) public onlyOwner returns (uint) {
       require(maximum > 0);
       nonce += 1;
       uint range = maximum - minimum;
       uint randomNumber = 1;
       if(maximum > 1)
            randomNumber = (uint(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1)))) % range);
       winner = randomNumber + minimum;
       emit generatedRandomNumber(winner);
       return winner;
    }
    
}