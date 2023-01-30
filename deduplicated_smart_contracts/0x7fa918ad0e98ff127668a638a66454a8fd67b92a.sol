/**
 *Submitted for verification at Etherscan.io on 2020-06-27
*/

/**
*
*                                                                                                
* 88888888888           88                                                88                        
* 88             ,d     88                                                ""    ,d                  
* 88             88     88                                                      88                  
* 88aaaaa      MM88MMM  88,dPPYba,    ,adPPYba,  8b,dPPYba,  8b,dPPYba,   88  MM88MMM  8b       d8  
* 88"""""        88     88P'    "8a  a8P_____88  88P'   "Y8  88P'   `"8a  88    88     `8b     d8'  
* 88             88     88       88  8PP"""""""  88          88       88  88    88      `8b   d8'   
* 88             88,    88       88  "8b,   ,aa  88          88       88  88    88,      `8b,d8'    
* 88888888888    "Y888  88       88   `"Ybbd8"'  88          88       88  88    "Y888      Y88'     
*                                                                                          d8'      
*                                                                                         d8'        
* 
* Ethernity
* https://ethernitiy.digital
* 
**/


pragma solidity >=0.4.23 <0.6.0;

contract Ethernity {
    
    struct User {
        uint id;
        uint partnersCount;
        
        address referrer;
        address globalReferrer;
        
        mapping(uint8 => bool) activeX3Levels;
        mapping(uint8 => bool) activeX6Levels;
        mapping(uint8 => bool) activeGlobalX3Levels;
        mapping(uint8 => bool) activeGlobalX6Levels;
        
        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X6) x6Matrix;
        mapping(uint8 => X3) globalX3Matrix;
        mapping(uint8 => X6) globalX6Matrix;
    }
    
    struct X3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct X6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;

        address closedPart;
    }
    
    address private owner;

    uint8 private constant LAST_LEVEL = 12;
    uint8 private globalCurrentX3SponsorPartners = 0;
    uint8 private globalCurrentX6SponsorPartners = 0;
    uint private globalCurrentX3SponsorId = 1;
    uint private globalCurrentX6SponsorId = 1;
    uint private lastUserId = 2;
   
    mapping(uint8 => uint) private levelPrice;
    mapping(uint => address) private idToAddress;
    mapping(address => User) private users;
    
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgraded(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);
    
    
    constructor(address ownerAddress) public {
        levelPrice[1] = 0.01 ether;
        for (uint8 i = 2; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i-1] * 2;
        }
        
        owner = ownerAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            globalReferrer: address(0),
            partnersCount: uint(0)
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeX3Levels[i] = true;
            users[ownerAddress].activeX6Levels[i] = true;
            users[ownerAddress].activeGlobalX3Levels[i] = true;
            users[ownerAddress].activeGlobalX6Levels[i] = true;
        }
    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function join(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }
    
    function upgrade(uint8 matrix, uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(matrix == 1 || matrix == 2 || matrix == 3 || matrix == 4, "invalid matrix");
        require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");

        if (matrix == 1) {
            require(!users[msg.sender].activeX3Levels[level], "level already activated");

            if (users[msg.sender].x3Matrix[level-1].blocked) {
                users[msg.sender].x3Matrix[level-1].blocked = false;
            }
    
            address freeX3Referrer = findFreeX3Referrer(msg.sender, level);
            users[msg.sender].x3Matrix[level].currentReferrer = freeX3Referrer;
            users[msg.sender].activeX3Levels[level] = true;
            updateX3Referrer(msg.sender, freeX3Referrer, level);
            
            emit Upgraded(msg.sender, freeX3Referrer, 1, level);

        } else if (matrix == 2) {
            require(!users[msg.sender].activeX6Levels[level], "level already activated"); 

            if (users[msg.sender].x6Matrix[level-1].blocked) {
                users[msg.sender].x6Matrix[level-1].blocked = false;
            }

            address freeX6Referrer = findFreeX6Referrer(msg.sender, level);

            users[msg.sender].activeX6Levels[level] = true;
            updateX6Referrer(msg.sender, freeX6Referrer, level);
            
            emit Upgraded(msg.sender, freeX6Referrer, 2, level);
        } else if (matrix == 3) {
            require(!users[msg.sender].activeGlobalX3Levels[level], "level already activated");

            if (users[msg.sender].globalX3Matrix[level-1].blocked) {
                users[msg.sender].globalX3Matrix[level-1].blocked = false;
            }
    
            address freeX3Referrer = findFreeGlobalX3Referrer(msg.sender, level);
            
            users[msg.sender].globalX3Matrix[level].currentReferrer = freeX3Referrer;
            users[msg.sender].activeGlobalX3Levels[level] = true;
            updateGlobalX3Referrer(msg.sender, freeX3Referrer, level);
            
            emit Upgraded(msg.sender, freeX3Referrer, 3, level);

        } else if (matrix == 4) {
            require(!users[msg.sender].activeGlobalX6Levels[level], "level already activated"); 

            if (users[msg.sender].globalX6Matrix[level-1].blocked) {
                users[msg.sender].globalX6Matrix[level-1].blocked = false;
            }

            address freeX6Referrer = findFreeGlobalX6Referrer(msg.sender, level);
            
            users[msg.sender].activeGlobalX6Levels[level] = true;
            updateGlobalX6Referrer(msg.sender, freeX6Referrer, level);
            
            emit Upgraded(msg.sender, freeX6Referrer, 4, level);

        }
    }    
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == 0.04 ether, "registration cost 0.04");
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
            globalReferrer: idToAddress[globalCurrentX3SponsorId],
            partnersCount: uint(0)
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].activeX3Levels[1] = true; 
        users[userAddress].activeX6Levels[1] = true;
        users[userAddress].activeGlobalX3Levels[1] = true; 
        users[userAddress].activeGlobalX6Levels[1] = true;
        
        lastUserId++;
        users[referrerAddress].partnersCount++;

        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);
        address freeX6Referrer = findFreeX6Referrer(userAddress, 1);
        address globalX3ReferrerAddress = idToAddress[globalCurrentX3SponsorId];
        address globalX6ReferrerAddress = idToAddress[globalCurrentX6SponsorId];
        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;
        users[userAddress].globalX3Matrix[1].currentReferrer = globalX3ReferrerAddress;
        
        updateX3Referrer(userAddress, freeX3Referrer, 1);
        updateGlobalX3Referrer(userAddress, globalX3ReferrerAddress, 1);
        updateX6Referrer(userAddress, freeX6Referrer, 1);
        updateGlobalX6Referrer(userAddress, globalX6ReferrerAddress, 1);
        
        globalCurrentX3SponsorPartners++;
        globalCurrentX6SponsorPartners++;
        
        if (globalCurrentX3SponsorPartners == 3) {
            globalCurrentX3SponsorPartners = 0;
            globalCurrentX3SponsorId++;
        }
        
        if (globalCurrentX6SponsorPartners == 2) {
            globalCurrentX6SponsorPartners = 0;
            globalCurrentX6SponsorId++;
        }
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function getAddressById(uint userId) external view returns(address) {
        return idToAddress[userId];
    }
    
    function getLastUserId() external view returns(uint) {
        return lastUserId;
    }
    
    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));
            return sendETHDividends(referrerAddress, userAddress, 1, level);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeX3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress, level);
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendETHDividends(owner, userAddress, 1, level);
            users[owner].x3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }
    
    function updateGlobalX3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        users[referrerAddress].globalX3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].globalX3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 3, level, uint8(users[referrerAddress].globalX3Matrix[level].referrals.length));
            return sendETHDividends(referrerAddress, userAddress, 3, level);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 3, level, 3);
        //close matrix
        users[referrerAddress].globalX3Matrix[level].referrals = new address[](0);
        if (!users[referrerAddress].activeGlobalX3Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].globalX3Matrix[level].blocked = true;
        }

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeGlobalX3Referrer(referrerAddress, level);
            if (users[referrerAddress].globalX3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].globalX3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].globalX3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 3, level);
            updateGlobalX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            sendETHDividends(owner, userAddress, 3, level);
            users[owner].globalX3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 3, level);
        }
    }

    function updateX6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeX6Levels[level], "500. Referrer level is inactive");
        
        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].x6Matrix[level].firstLevelReferrals.length));
            
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendETHDividends(referrerAddress, userAddress, 2, level);
            }
            
            address ref = users[referrerAddress].x6Matrix[level].currentReferrer;            
            users[ref].x6Matrix[level].secondLevelReferrals.push(userAddress); 
            
            uint len = users[ref].x6Matrix[level].firstLevelReferrals.length;
            
            if ((len == 2) && 
                (users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (len == 2 && users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }

            return updateX6ReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].x6Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].x6Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x6Matrix[level].closedPart)) {

                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].x6Matrix[level].closedPart) {
                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateX6(userAddress, referrerAddress, level, false);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateX6(userAddress, referrerAddress, level, false);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateX6(userAddress, referrerAddress, level, true);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length) {
            updateX6(userAddress, referrerAddress, level, false);
        } else {
            updateX6(userAddress, referrerAddress, level, true);
        }
        
        updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x6Matrix[level].firstLevelReferrals[0], 2, level, uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 2 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x6Matrix[level].firstLevelReferrals[1], 2, level, uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 4 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[1];
        }
    }
    
    function updateX6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x6Matrix[level].secondLevelReferrals.length < 4) {
            return sendETHDividends(referrerAddress, userAddress, 2, level);
        }
        
        address[] memory x6 = users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].firstLevelReferrals;
        
        if (x6.length == 2) {
            if (x6[0] == referrerAddress ||
                x6[1] == referrerAddress) {
                users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
            } else if (x6.length == 1) {
                if (x6[0] == referrerAddress) {
                    users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].x6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeX6Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x6Matrix[level].blocked = true;
        }

        users[referrerAddress].x6Matrix[level].reinvestCount++;
        
        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeX6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            updateX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 2, level);
            sendETHDividends(owner, userAddress, 2, level);
        }
    }
    
    function updateGlobalX6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeGlobalX6Levels[level], "500. Referrer level is inactive");
        
        if (users[referrerAddress].globalX6Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].globalX6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 4, level, uint8(users[referrerAddress].globalX6Matrix[level].firstLevelReferrals.length));
            
            //set current level
            users[userAddress].globalX6Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendETHDividends(referrerAddress, userAddress, 4, level);
            }
            
            address ref = users[referrerAddress].globalX6Matrix[level].currentReferrer;            
            users[ref].globalX6Matrix[level].secondLevelReferrals.push(userAddress); 
            
            uint len = users[ref].globalX6Matrix[level].firstLevelReferrals.length;
            
            if ((len == 2) && 
                (users[ref].globalX6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].globalX6Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].globalX6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 4, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 4, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].globalX6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].globalX6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 4, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 4, level, 4);
                }
            } else if (len == 2 && users[ref].globalX6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].globalX6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 4, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 4, level, 6);
                }
            }

            return updateGlobalX6ReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].globalX6Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].globalX6Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].globalX6Matrix[level].closedPart)) {

                updateGlobalX6(userAddress, referrerAddress, level, true);
                return updateGlobalX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].globalX6Matrix[level].closedPart) {
                updateGlobalX6(userAddress, referrerAddress, level, true);
                return updateGlobalX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateGlobalX6(userAddress, referrerAddress, level, false);
                return updateGlobalX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateGlobalX6(userAddress, referrerAddress, level, false);
            return updateGlobalX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateGlobalX6(userAddress, referrerAddress, level, true);
            return updateGlobalX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (users[users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0]].globalX6Matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[1]].globalX6Matrix[level].firstLevelReferrals.length) {
            updateGlobalX6(userAddress, referrerAddress, level, false);
        } else {
            updateGlobalX6(userAddress, referrerAddress, level, true);
        }
        
        updateGlobalX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateGlobalX6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0]].globalX6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0], 4, level, uint8(users[users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0]].globalX6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 4, level, 2 + uint8(users[users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0]].globalX6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].globalX6Matrix[level].currentReferrer = users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[1]].globalX6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[1], 4, level, uint8(users[users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[1]].globalX6Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 4, level, 4 + uint8(users[users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[1]].globalX6Matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].globalX6Matrix[level].currentReferrer = users[referrerAddress].globalX6Matrix[level].firstLevelReferrals[1];
        }
    }
    
    function updateGlobalX6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].globalX6Matrix[level].secondLevelReferrals.length < 4) {
            return sendETHDividends(referrerAddress, userAddress, 4, level);
        }
        
        address[] memory x6 = users[users[referrerAddress].globalX6Matrix[level].currentReferrer].globalX6Matrix[level].firstLevelReferrals;
        
        if (x6.length == 2) {
            if (x6[0] == referrerAddress ||
                x6[1] == referrerAddress) {
                users[users[referrerAddress].globalX6Matrix[level].currentReferrer].globalX6Matrix[level].closedPart = referrerAddress;
            } else if (x6.length == 1) {
                if (x6[0] == referrerAddress) {
                    users[users[referrerAddress].globalX6Matrix[level].currentReferrer].globalX6Matrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].globalX6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].globalX6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].globalX6Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeGlobalX6Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].globalX6Matrix[level].blocked = true;
        }

        users[referrerAddress].globalX6Matrix[level].reinvestCount++;
        
        if (referrerAddress != owner) {
            address freeReferrerAddress = findFreeGlobalX6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 4, level);
            updateGlobalX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 4, level);
            sendETHDividends(owner, userAddress, 4, level);
        }
    }
    
    function findFreeX3Referrer(address userAddress, uint8 level) private view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    
    function findFreeGlobalX3Referrer(address userAddress, uint8 level) private view returns(address) {
        while (true) {
            if (users[users[userAddress].globalReferrer].activeGlobalX3Levels[level]) {
                return users[userAddress].globalReferrer;
            }
            
            userAddress = users[userAddress].globalReferrer;
        }
    }
    
    function findFreeX6Referrer(address userAddress, uint8 level) private view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX6Levels[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    
    function findFreeGlobalX6Referrer(address userAddress, uint8 level) private view returns(address) {
        while (true) {
            if (users[users[userAddress].globalReferrer].activeGlobalX6Levels[level]) {
                return users[userAddress].globalReferrer;
            }
            
            userAddress = users[userAddress].globalReferrer;
        }
    }
        
    function usersActiveX3Levels(address userAddress, uint8 level) external view returns(bool) {
        return users[userAddress].activeX3Levels[level];
    }
    
    function usersGlobalActiveX3Levels(address userAddress, uint8 level) external view returns(bool) {
        return users[userAddress].activeGlobalX3Levels[level];
    }

    function usersActiveX6Levels(address userAddress, uint8 level) external view returns(bool) {
        return users[userAddress].activeX6Levels[level];
    }
    
     function usersGlobalActiveX6Levels(address userAddress, uint8 level) external view returns(bool) {
        return users[userAddress].activeGlobalX6Levels[level];
    }

    function usersX3Matrix(address userAddress, uint8 level) external view returns(address, address[] memory, bool, uint) {
        return (users[userAddress].x3Matrix[level].currentReferrer,
                users[userAddress].x3Matrix[level].referrals,
                users[userAddress].x3Matrix[level].blocked,
                users[userAddress].x3Matrix[level].reinvestCount);
    }
    
    function usersGlobalX3Matrix(address userAddress, uint8 level) external view returns(address, address[] memory, bool, uint) {
        return (users[userAddress].globalX3Matrix[level].currentReferrer,
                users[userAddress].globalX3Matrix[level].referrals,
                users[userAddress].globalX3Matrix[level].blocked,
                users[userAddress].globalX3Matrix[level].reinvestCount);
    }

    function usersX6Matrix(address userAddress, uint8 level) external view returns(address, address[] memory, address[] memory, bool, uint, address) {
        return (users[userAddress].x6Matrix[level].currentReferrer,
                users[userAddress].x6Matrix[level].firstLevelReferrals,
                users[userAddress].x6Matrix[level].secondLevelReferrals,
                users[userAddress].x6Matrix[level].blocked,
                users[userAddress].x6Matrix[level].reinvestCount,
                users[userAddress].x6Matrix[level].closedPart);
    }
    
    function usersGlobalX6Matrix(address userAddress, uint8 level) external view returns(address, address[] memory, address[] memory, bool, uint, address) {
        return (users[userAddress].globalX6Matrix[level].currentReferrer,
                users[userAddress].globalX6Matrix[level].firstLevelReferrals,
                users[userAddress].globalX6Matrix[level].secondLevelReferrals,
                users[userAddress].globalX6Matrix[level].blocked,
                users[userAddress].globalX6Matrix[level].reinvestCount,
                users[userAddress].globalX6Matrix[level].closedPart);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    function userInfo(address userAddress) external view returns(uint, uint, address, address) {
        return (users[userAddress].id,
            users[userAddress].partnersCount,
            users[userAddress].referrer,
            users[userAddress].globalReferrer);
    }

    function findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
        address receiver = userAddress;
        bool isExtraDividends;
        if (matrix == 1) {
            while (true) {
                if (users[receiver].x3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 1, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else if (matrix == 2) {
            while (true) {
                if (users[receiver].x6Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x6Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else if (matrix == 3) {
            while (true) {
                if (users[receiver].globalX3Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 3, level);
                    isExtraDividends = true;
                    receiver = users[receiver].globalX3Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        } else if (matrix == 4) {
            while (true) {
                if (users[receiver].globalX6Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 4, level);
                    isExtraDividends = true;
                    receiver = users[receiver].globalX6Matrix[level].currentReferrer;
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