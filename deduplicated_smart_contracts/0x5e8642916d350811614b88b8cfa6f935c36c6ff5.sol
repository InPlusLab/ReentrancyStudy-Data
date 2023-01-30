pragma solidity ^ 0.4.17;


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
    function Ownable() public { 
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
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


// Whitelist smart contract
// This smart contract keeps list of addresses to whitelist
contract WhiteList is Ownable {

    
    mapping(address => bool) public whiteList;
    mapping(address => address) public affiliates;
    uint public totalWhiteListed; //white listed users number

    event LogWhiteListed(address indexed user, address affiliate, uint whiteListedNum);
    event LogWhiteListedMultiple(uint whiteListedNum);
    event LogRemoveWhiteListed(address indexed user);

    // @notice it will return status of white listing
    // @return true if user is white listed and false if is not
    function isWhiteListedAndAffiliate(address _user) external view returns (bool, address) {
        return (whiteList[_user], affiliates[_user]); 
    }

    // @notice it will return refferal address 
    // @param _user {address} address of contributor
    function returnReferral(address _user) external view returns (address) {
        return  affiliates[_user];
    
    }

    // @notice it will remove whitelisted user
    // @param _contributor {address} of user to unwhitelist
    function removeFromWhiteList(address _user) external onlyOwner() returns (bool) {
       
        require(whiteList[_user] == true);
        whiteList[_user] = false;
        affiliates[_user] = address(0);
        totalWhiteListed--;
        LogRemoveWhiteListed(_user);
        return true;
    }

    // @notice it will white list one member
    // @param _user {address} of user to whitelist
    // @return true if successful
    function addToWhiteList(address _user, address _affiliate) external onlyOwner() returns (bool) {

        if (whiteList[_user] != true) {
            whiteList[_user] = true;
            affiliates[_user] = _affiliate;
            totalWhiteListed++;
            LogWhiteListed(_user, _affiliate, totalWhiteListed);            
        }
        return true;
    }

    // @notice it will white list multiple members
    // @param _user {address[]} of users to whitelist
    // @return true if successful
    function addToWhiteListMultiple(address[] _users, address[] _affiliate) external onlyOwner() returns (bool) {

        for (uint i = 0; i < _users.length; ++i) {

            if (whiteList[_users[i]] != true) {
                whiteList[_users[i]] = true;
                affiliates[_users[i]] = _affiliate[i];
                totalWhiteListed++;                          
            }           
        }
        LogWhiteListedMultiple(totalWhiteListed); 
        return true;
    }
}