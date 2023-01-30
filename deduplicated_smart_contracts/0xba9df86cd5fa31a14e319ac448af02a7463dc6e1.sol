/**
 *Submitted for verification at Etherscan.io on 2020-06-28
*/

pragma solidity >=0.4.23 <0.6.0;

contract Million {
    struct User {
        uint key;
        address referrer;
        bool[] levelActived;
        address[] levelReferrer;
        address[][] levelReferrals;
        address[][5][] levelMatrix;
    }
    mapping(address => User) public users;
    address[] public addresses;
    uint[4] public levelFee = [0.05 ether, 0.5 ether, 5 ether, 50 ether];
  
    constructor() public {
        addresses.push(msg.sender);
        User memory user = User({
            key: addresses.length,
            referrer: address(0),
            levelActived: new bool[](0),
            levelReferrer: new address[](0),
            levelReferrals: new address[][](0),
            levelMatrix: new address[][5][](0)
        });
        users[msg.sender] = user;
        for (uint i = 1; i <= 4; i++) {
            users[msg.sender].levelActived.push(true);
            users[msg.sender].levelReferrer.push(address(0));
            users[msg.sender].levelReferrals.push(new address[](0));
            users[msg.sender].levelMatrix.push([new address[](0), new address[](0), new address[](0), new address[](0), new address[](0)]);
        }
    }

    function() external payable {
        uint level;
        if (msg.value == levelFee[0]) level = 1;
        else if (msg.value == levelFee[1]) level = 2;
        else if (msg.value == levelFee[2]) level = 3;
        else if (msg.value == levelFee[3]) level = 4;
        else revert("incorrect value");

        if (level == 1) {
            if (userExist(msg.sender)) revert("already registered");
            address referrer = bytesToAddress(msg.data);
            registerUser(referrer);
        } else {
            if (!userExist(msg.sender)) revert("user not exist");
            if (users[msg.sender].levelActived[level-1]) revert("level already actived");
            buyLevel(level);
        }
    }

    function registerUser(address referrer) public payable {
        require(msg.value == levelFee[0], "incorrect value");
        require(!userExist(msg.sender), "user exist");
        if (referrer == address(0) || !userExist(referrer)) referrer = addresses[0];
       
        referrer = findFreeUpline(referrer, 1);
        addresses.push(msg.sender);
        User memory user = User({
            key: addresses.length,
            referrer: referrer,
            levelActived: new bool[](0),
            levelReferrer: new address[](0),
            levelReferrals: new address[][](0),
            levelMatrix: new address[][5][](0)
        });
        users[msg.sender] = user;
        for (uint i = 1; i <= 4; i++) {
            users[msg.sender].levelActived.push(false);
            users[msg.sender].levelReferrer.push(address(0));
            users[msg.sender].levelReferrals.push(new address[](0));
            users[msg.sender].levelMatrix.push([new address[](0), new address[](0), new address[](0), new address[](0), new address[](0)]);
        }
        users[msg.sender].levelActived[0] = true;
        users[msg.sender].levelReferrer[0] = referrer;
        
        updateUplineMatrix(msg.sender, 1);
        sendCoinToReferrer(msg.sender, 1);
    }

    function findFreeUpline(address referrer, uint level) public view returns(address) {
        while(!users[referrer].levelActived[level-1]) {
            referrer = users[referrer].referrer;
        }
        if (users[referrer].levelReferrals[level-1].length < 5) {
            return referrer;
        }

        bool found = false;
        address[] memory referrals = new address[](155);
        for (uint i = 0; i < 5; i++) {
            referrals[i] = users[referrer].levelReferrals[level-1][i];
        }
        for (uint i = 0; i < 155; i++) {
            if (users[referrals[i]].levelReferrals[level-1].length == 5) {
                if (i < 30) {
                    for (uint k = 0; k < 5; k++) {
                        referrals[(i+1)*5+k] = users[referrals[i]].levelReferrals[level-1][k];
                    }
                }
            } else {
                referrer = referrals[i];
                found = true;
                break;
            } 
        }
        require(found, "cannot find upline");
        return referrer;
    }

    function buyLevel(uint level) public payable {
        require(level >= 1 && level <= 4, "invalid level");
        require(msg.value == levelFee[level-1], "incorrect value");
        require(userExist(msg.sender), "user not exist");
        require(!users[msg.sender].levelActived[level-1], "level already actived");

        address referrer = findFreeUpline(users[msg.sender].referrer, level);
        users[msg.sender].levelActived[level-1] = true;
        users[msg.sender].levelReferrer[level-1] = referrer;
        
        updateUplineMatrix(msg.sender, level);
        sendCoinToReferrer(msg.sender, level);
    }

    function updateUplineMatrix(address user, uint level) internal {
        address referrer = users[user].levelReferrer[level-1];
        users[referrer].levelReferrals[level-1].push(user);
        address receiver = users[referrer].levelReferrer[level-1];
        if (receiver == address(0)) return;
        for (uint i = 0; i < users[receiver].levelReferrals[level-1].length; i++) {
            if (users[receiver].levelReferrals[level-1][i] == referrer) {
                users[receiver].levelMatrix[level-1][i].push(user);
                break;
            }    
        }
    }

    function sendCoinToReferrer(address user, uint level) internal {
        address referrer = users[user].levelReferrer[level-1];
        address receiver = users[referrer].levelReferrer[level-1];
        if (receiver == address(0)) receiver = addresses[0];
        address(uint160(receiver)).transfer(levelFee[level-1]);
    }
     
    function userExist(address user) public view returns(bool) {
        return users[user].key > 0;
    }

    function viewUserExistAndLevelActived(address user) public view returns(bool, bool[] memory) {
        if (users[user].key > 0) {
            return (true, users[user].levelActived);
        } else {
            return (false, new bool[](0));
        }
    }

    function viewUserLevelMatrix(address user, uint level) public view returns(address, address[] memory, address[] memory) {
        address[] memory matrix = new address[](25);
        for (uint i = 0; i < 5; i++) {
            for (uint k = 0; k < users[user].levelMatrix[level-1][i].length; k++) {
                matrix[i*5+k] = users[user].levelMatrix[level-1][i][k];
            }
        }
        return (users[user].levelReferrer[level-1], users[user].levelReferrals[level-1], matrix);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}