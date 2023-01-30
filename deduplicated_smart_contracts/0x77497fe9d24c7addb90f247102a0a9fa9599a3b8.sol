/**
 *Submitted for verification at Etherscan.io on 2020-07-22
*/

/**
* 
*   ¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨[¨€¨€¨€¨[   ¨€¨€¨[¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨[  ¨€¨€¨[¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨€¨€¨€¨€¨[ 
*  ¨€¨€¨€¨U¨€¨€¨X¨T¨T¨T¨T¨a¨€¨€¨X¨T¨T¨T¨€¨€¨[¨€¨€¨U¨€¨€¨€¨€¨[  ¨€¨€¨U¨€¨€¨X¨T¨T¨T¨T¨a¨^¨T¨T¨€¨€¨X¨T¨T¨a¨€¨€¨U  ¨€¨€¨U¨€¨€¨X¨T¨T¨T¨T¨a¨€¨€¨X¨T¨T¨€¨€¨[
*  ¨^¨€¨€¨U¨€¨€¨U     ¨€¨€¨U   ¨€¨€¨U¨€¨€¨U¨€¨€¨X¨€¨€¨[ ¨€¨€¨U¨€¨€¨€¨€¨€¨[     ¨€¨€¨U   ¨€¨€¨€¨€¨€¨€¨€¨U¨€¨€¨€¨€¨€¨[  ¨€¨€¨€¨€¨€¨€¨X¨a
*   ¨€¨€¨U¨€¨€¨U     ¨€¨€¨U   ¨€¨€¨U¨€¨€¨U¨€¨€¨U¨^¨€¨€¨[¨€¨€¨U¨€¨€¨X¨T¨T¨a     ¨€¨€¨U   ¨€¨€¨X¨T¨T¨€¨€¨U¨€¨€¨X¨T¨T¨a  ¨€¨€¨X¨T¨T¨€¨€¨[
*   ¨€¨€¨U¨^¨€¨€¨€¨€¨€¨€¨[¨^¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨U¨€¨€¨U ¨^¨€¨€¨€¨€¨U¨€¨€¨€¨€¨€¨€¨€¨[   ¨€¨€¨U   ¨€¨€¨U  ¨€¨€¨U¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨U  ¨€¨€¨U
*   ¨^¨T¨a ¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨a¨^¨T¨a  ¨^¨T¨T¨T¨a¨^¨T¨T¨T¨T¨T¨T¨a   ¨^¨T¨a   ¨^¨T¨a  ¨^¨T¨a¨^¨T¨T¨T¨T¨T¨T¨a¨^¨T¨a  ¨^¨T¨a
* 
* 1CoinEther
* https://1coinether.io
* 
* 
**/


pragma solidity >=0.4.23 <0.6.0;

contract OneCoinEther {
    
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        
        mapping(uint8 => bool) activeE3Levels;
        mapping(uint8 => bool) activeE6Levels;
        
        mapping(uint8 => E3) e3Matrix;
        mapping(uint8 => E6) e6Matrix;
    }
    
    struct E3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct E6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;

        address closedPart;
    }

    uint8 public constant LAST_LEVEL = 12;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId = 2;
    address public owner;
    
    mapping(uint8 => uint) public levelPrice;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
    
    
    constructor(address ownerAddress) public {
        levelPrice[1] = 0.025 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        
        owner = ownerAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeE3Levels[i] = true;
            users[ownerAddress].activeE6Levels[i] = true;
        }
        
        userIds[1] = ownerAddress;
    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }
    
    function buyNewLevel(uint8 matrix, uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(matrix == 1 || matrix == 2, "invalid matrix");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if (matrix == 1) {
            require(!users[msg.sender].activeE3Levels[level], "level already activated");

            if (users[msg.sender].e3Matrix[level-1].blocked) {
                users[msg.sender].e3Matrix[level-1].blocked = false;
            }
    
            address freeE3Referrer = findFreeE3Referrer(msg.sender, level);
            users[msg.sender].e3Matrix[level].currentReferrer = freeE3Referrer;
            users[msg.sender].activeE3Levels[level] = true;
            updateE3Referrer(msg.sender, freeE3Referrer, level);
            
            emit Upgrade(msg.sender, freeE3Referrer, 1, level);

        } else {
            require(!users[msg.sender].activeE6Levels[level], "level already activated"); 

            if (users[msg.sender].e6Matrix[level-1].blocked) {
                users[msg.sender].e6Matrix[level-1].blocked = false;
            }

            address freeE6Referrer = findFreeE6Referrer(msg.sender, level);
            
            users[msg.sender].activeE6Levels[level] = true;
            updateE6Referrer(msg.sender, freeE6Referrer, level);
            
            emit Upgrade(msg.sender, freeE6Referrer, 2, level);
        }
    }    
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 0.05 ether, "registration cost 0.05");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].activeE3Levels[1] = true; 
        users[userAddress].activeE6Levels[1] = true;
        
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;

        address freeE3Referrer = findFreeE3Referrer(userAddress, 1);
        users[userAddress].e3Matrix[1].currentReferrer = freeE3Referrer;
        updateE3Referrer(userAddress, freeE3Referrer, 1);

        updateE6Referrer(userAddress, findFreeE6Referrer(userAddress, 1), 1);
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function updateE3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].e3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].e3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].e3Matrix[level].referrals.length));
            return sendETHDividends(referrerAddress, userAddress, 1, level);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].e3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeE3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].e3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeE3Referrer(referrerAddress, level);
            if (users[referrerAddress].e3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].e3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].e3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateE3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendETHDividends(owner, userAddress, 1, level);
            users[owner].e3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }

    function updateE6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeE6Levels[level], "500. Referrer level is inactive");
        
        if (users[referrerAddress].e6Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].e6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].e6Matrix[level].firstLevelReferrals.length));
            
            //set current level
            users[userAddress].e6Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendETHDividends(referrerAddress, userAddress, 2, level);
            }
            
            address ref = users[referrerAddress].e6Matrix[level].currentReferrer;            
            users[ref].e6Matrix[level].secondLevelReferrals.push(userAddress); 
            
            uint len = users[ref].e6Matrix[level].firstLevelReferrals.length;
            
            if ((len == 2) && 
                (users[ref].e6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].e6Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].e6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].e6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].e6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (len == 2 && users[ref].e6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].e6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }

            return updateE6ReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].e6Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].e6Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].e6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].e6Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].e6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].e6Matrix[level].closedPart)) {

                updateE6(userAddress, referrerAddress, level, true);
                return updateE6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].e6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].e6Matrix[level].closedPart) {
                updateE6(userAddress, referrerAddress, level, true);
                return updateE6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateE6(userAddress, referrerAddress, level, false);
                return updateE6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].e6Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateE6(userAddress, referrerAddress, level, false);
            return updateE6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].e6Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateE6(userAddress, referrerAddress, level, true);
            return updateE6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (users[users[referrerAddress].e6Matrix[level].firstLevelReferrals[0]].e6Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].e6Matrix[level].firstLevelReferrals[1]].e6Matrix[level].firstLevelReferrals.length) {
            updateE6(userAddress, referrerAddress, level, false);
        } else {
            updateE6(userAddress, referrerAddress, level, true);
        }
        
        updateE6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateE6(address userAddress, address referrerAddress, uint8 level, bool e2) private {
        if (!e2) {
            users[users[referrerAddress].e6Matrix[level].firstLevelReferrals[0]].e6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].e6Matrix[level].firstLevelReferrals[0], 2, level, uint8(users[users[referrerAddress].e6Matrix[level].firstLevelReferrals[0]].e6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 2 + uint8(users[users[referrerAddress].e6Matrix[level].firstLevelReferrals[0]].e6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].e6Matrix[level].currentReferrer = users[referrerAddress].e6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].e6Matrix[level].firstLevelReferrals[1]].e6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].e6Matrix[level].firstLevelReferrals[1], 2, level, uint8(users[users[referrerAddress].e6Matrix[level].firstLevelReferrals[1]].e6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 4 + uint8(users[users[referrerAddress].e6Matrix[level].firstLevelReferrals[1]].e6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].e6Matrix[level].currentReferrer = users[referrerAddress].e6Matrix[level].firstLevelReferrals[1];
        }
    }
    
    function updateE6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].e6Matrix[level].secondLevelReferrals.length < 4) {
            return sendETHDividends(referrerAddress, userAddress, 2, level);
        }
        
        address[] memory e6 = users[users[referrerAddress].e6Matrix[level].currentReferrer].e6Matrix[level].firstLevelReferrals;
        
        if (e6.length == 2) {
            if (e6[0] == referrerAddress ||
                e6[1] == referrerAddress) {
                users[users[referrerAddress].e6Matrix[level].currentReferrer].e6Matrix[level].closedPart = referrerAddress;
            } else if (e6.length == 1) {
                if (e6[0] == referrerAddress) {
                    users[users[referrerAddress].e6Matrix[level].currentReferrer].e6Matrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].e6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].e6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].e6Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeE6Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].e6Matrix[level].blocked = true;
        }

        users[referrerAddress].e6Matrix[level].reinvestCount++;
        
        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeE6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            updateE6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 2, level);
            sendETHDividends(owner, userAddress, 2, level);
        }
    }
    
    function findFreeE3Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeE3Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    
    function findFreeE6Referrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeE6Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
        
    function usersActiveE3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeE3Levels[level];
    }

    function usersActiveE6Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeE6Levels[level];
    }

    function usersE3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool) {
        return (users[userAddress].e3Matrix[level].currentReferrer,
                users[userAddress].e3Matrix[level].referrals,
                users[userAddress].e3Matrix[level].blocked);
    }

    function usersE6Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, address) {
        return (users[userAddress].e6Matrix[level].currentReferrer,
                users[userAddress].e6Matrix[level].firstLevelReferrals,
                users[userAddress].e6Matrix[level].secondLevelReferrals,
                users[userAddress].e6Matrix[level].blocked,
                users[userAddress].e6Matrix[level].closedPart);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].e3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].e3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else {
            while (true) {
                if (users[receiver].e6Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].e6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, matrix, level);

        if (!address(uint160(receiver)).send(levelPrice[level])) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }
        
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}