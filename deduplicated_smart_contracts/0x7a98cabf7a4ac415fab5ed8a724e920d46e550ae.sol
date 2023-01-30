/**
 *Submitted for verification at Etherscan.io on 2020-03-31
*/

pragma solidity 0.4.26;

contract owned {
    
    address public owner;
    
    function owned() payable{
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(owner == msg.sender);
        _;
    }
    
    function changeOwner(address _newOwner) onlyOwner public{
        owner = _newOwner;
    }
    
    
}

contract ProofOfExistence is owned {
    
    mapping (string => uint256) private hashOf;
    uint256 price;
    string public name = 'Proof of Existence';
    bool pause;
    
    
    modifier isNotPaused{
        require(!pause);
        _;
    }
    
    modifier isNotExist(string _hash){
        require(hashOf[_hash] == 0);
        _;
    }
    
    modifier Payed{

        require(msg.value >= 1 ether / price);
        _;
    }
    
    
    function ProofOfExistence(uint256 _price) owned() payable{
        hashOf['Created'] = block.timestamp;
        price = _price;
        pause = false;
    }
    
    
    
    function getCurrentPrice() public view returns (uint256){
        return 1 ether / price;
    }
    
    function createProof(string _hash) isNotExist(_hash) isNotPaused Payed public payable{
        
            hashOf[_hash] = block.timestamp;
        
    }
    
    function checkProof(string _hash) public view returns (uint256){
    
           return hashOf[_hash];
           
    }
    
    function changePrice(uint256 _price) onlyOwner public{
        price = _price;
    }
    
    function withdraw() isNotPaused onlyOwner public{
        owner.transfer(this.balance);
    }
    
    
    // function killThis() onlyOwner public{
    //     selfdestruct(owner);
    // }
    
    function setPause(bool _pause) onlyOwner public{
        pause = _pause;
    }
    
}