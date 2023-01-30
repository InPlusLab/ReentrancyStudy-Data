/**
 *Submitted for verification at Etherscan.io on 2020-04-04
*/

pragma solidity ^0.5.10;

contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  //transfer owner to another address
  function transferOwnership(address _newOwner) public onlyOwner {
    if (_newOwner != address(0)) {
      owner = _newOwner;
    }
  }
}

contract Tombstone{
    string public name;
    string public born_on;
    string public died_on;
    string public epitaph;
    string public place;
    
    event Mourn(address indexed who);
    
    bool built = false;
    
    function build(
        string memory _name, 
        string memory _born_on, 
        string memory _died_on, 
        string memory _epitaph, 
        string memory _place
    ) public {
        require(!built);
        name = _name;
        born_on = _born_on;
        died_on = _died_on;
        epitaph = _epitaph;
        place = _place;
        built = true;
    }
    
    
    function info() public view 
        returns(
            string memory, 
            string memory, 
            string memory, 
            string memory,
            string memory
        )
    {
        return (name, born_on, died_on, epitaph, place);
    }
    
    function mourn() public {
        emit Mourn(msg.sender);
    }
}

// Mourn victims of coronavirus pandemic.
// R.I.P
// https://restinpeace.world/

contract RestInPeace is Ownable {
    address public templateAddress;
    
    event Created(address indexed sender, address tombstone);
    
    constructor(address _template) public {
        templateAddress = _template;
    }
    
    function updateTemplate(address _template) public onlyOwner {
        templateAddress = _template;
    }
    
    /// @dev create tombstone
    /// @param name name of deceased
    /// @param born_on (yyyymmdd) birth date of deceased
    /// @param died_on (yyyymmdd) death date of deceased
    /// @param epitaph epitaph to deceased
    /// @param place place of birth
    /// @return tombstone Tombstone
    function createTombstone(
        string memory name, 
        string memory born_on, 
        string memory died_on, 
        string memory epitaph, 
        string memory place
    ) public returns (Tombstone tombstone) {
        
        require(bytes(name).length <= 150, "Too long name");
        require(bytes(born_on).length == 8, "Invalid date format");
        require(bytes(died_on).length == 8, "Invalid date format");
        require(bytes(epitaph).length <= 300, "Too long inputs");
        require(bytes(place).length <= 150, "Too long inputs");
        
        tombstone = Tombstone(createFromTemplate(templateAddress));
        tombstone.build(name, born_on, died_on, epitaph, place);
        emit Created(msg.sender, address(tombstone));
    }
    
    function createFromTemplate(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
          let clone := mload(0x40)
          mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
          mstore(add(clone, 0x14), targetBytes)
          mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
          result := create(0, clone, 0x37)
        }
   }
}