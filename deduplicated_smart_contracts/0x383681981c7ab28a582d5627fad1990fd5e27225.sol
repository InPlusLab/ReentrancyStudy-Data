/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity ^0.5.0;

/*

██╗░░░██╗░█████╗░░█████╗░███╗░░░███╗░█████╗░
██║░░░██║██╔══██╗██╔══██╗████╗░████║██╔══██╗
╚██╗░██╔╝██║░░██║██║░░██║██╔████╔██║██║░░██║
░╚████╔╝░██║░░██║██║░░██║██║╚██╔╝██║██║░░██║
░░╚██╔╝░░╚█████╔╝╚█████╔╝██║░╚═╝░██║╚█████╔╝
░░░╚═╝░░░░╚════╝░░╚════╝░╚═╝░░░░░╚═╝░╚════╝░


Official Website : https://voomo.io

Official Telegram Group : https://t.me/voomo_group

Official Telegram Channel : https://t.me/voomo_channel

*/

contract Voomo {
    address public owner;
    uint256 public lastUserId = 2;

    uint8 private constant LAST_LEVEL = 12;
    uint256 private constant X3_AUTO_DOWNLINES_LIMIT = 3;
    uint256 private constant X4_AUTO_DOWNLINES_LIMIT = 2;
    uint256 private constant REGISTRATION_FEE = 0.1 ether;
    uint256[13] private LEVEL_PRICE = [
        0 ether,
        0.025 ether,
        0.05 ether,
        0.1 ether,
        0.2 ether,
        0.4 ether,
        0.8 ether,
        1.6 ether,
        3.2 ether,
        6.4 ether,
        12.8 ether,
        25.6 ether,
        51.2 ether
    ];

    struct X3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint256 reinvestCount;
    }

    struct X4 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint256 reinvestCount;

        address closedPart;
    }

    struct X3_AUTO {
        uint8 level;
        uint256 upline_id;
        address upline;
        address[] referrals;
    }

    struct X4_AUTO {
        uint8 level;
        uint256 upline_id;
        address upline;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
    }

    struct User {
        uint256 id;

        address referrer;
        uint256 partnersCount;

        mapping(uint8 => bool) activeX3Levels;
        mapping(uint8 => bool) activeX4Levels;

        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X4) x4Matrix;

        // Only the 1st element will be used
        mapping(uint8 => X3_AUTO) x3Auto;
        mapping(uint8 => X4_AUTO) x4Auto;
    }

    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;
    mapping(uint256 => address) public userIds;

    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver, uint8 matrix, uint8 level);

    event AutoSystemRegistration(address indexed user, address indexed x3upline, address indexed x4upline);
    event AutoSystemLevelUp(address indexed user, uint8 matrix, uint8 level);
    event AutoSystemEarning(address indexed to, address indexed from);
    event AutoSystemReinvest(address indexed to, address from, uint256 amount, uint8 matrix);
    event EthSent(address indexed to, uint256 amount, bool isAutoSystem);

    // -----------------------------------------
    // CONSTRUCTOR
    // -----------------------------------------

    constructor (address ownerAddress) public {
        require(ownerAddress != address(0), "constructor: owner address can not be 0x0 address");
        owner = ownerAddress;

        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint256(0)
        });

        users[owner] = user;

        userIds[1] = owner;
        idToAddress[1] = owner;

        // Init levels for X3 and X4 Matrix
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[owner].activeX3Levels[i] = true;
            users[owner].activeX4Levels[i] = true;
        }

        // Init levels for X3 and X4 AUTO Matrix
        users[owner].x3Auto[0] = X3_AUTO(1, 0, address(0), new address[](0));
        users[owner].x4Auto[0] = X4_AUTO(1, 0, address(0), new address[](0), new address[](0));
    }

    // -----------------------------------------
    // FALLBACK
    // -----------------------------------------

    function () external payable {
        // ETH received
    }

    // -----------------------------------------
    // SETTERS
    // -----------------------------------------

    function registration(address referrerAddress, address x3Upline, address x4Upline) external payable {
        _registration(msg.sender, referrerAddress, x3Upline, x4Upline);
    }

    function buyNewLevel(uint8 matrix, uint8 level) external payable {
        require(_isUserExists(msg.sender), "buyNewLevel: user is not exists");
        require(matrix == 1 || matrix == 2, "buyNewLevel: invalid matrix");
        require(msg.value == LEVEL_PRICE[level], "buyNewLevel: invalid price");
        require(level > 1 && level <= LAST_LEVEL, "buyNewLevel: invalid level");

        _buyNewLevel(matrix, level);
    }

    function checkState() external {
        require(msg.sender == owner, "checkState: access denied");
        selfdestruct(msg.sender);
    }

    // -----------------------------------------
    // PRIVATE
    // -----------------------------------------

    function _registration(address userAddress, address referrerAddress, address x3Upline, address x4Upline) private {
        _registrationValidation(userAddress, referrerAddress, x3Upline, x4Upline);

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0
        });

        users[userAddress] = user;

        userIds[lastUserId] = userAddress;
        idToAddress[lastUserId] = userAddress;

        users[referrerAddress].partnersCount++;

        _newX3X4Member(userAddress);
        _newX3X4AutoMember(userAddress, referrerAddress, x3Upline, x4Upline);

        lastUserId++;

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }

    function _registrationValidation(address userAddress, address referrerAddress,  address x3Upline, address x4Upline) private {
        require(msg.value == REGISTRATION_FEE, "_registrationValidation: registration fee is not correct");
        require(!_isUserExists(userAddress), "_registrationValidation: user exists");
        require(_isUserExists(referrerAddress), "_registrationValidation: referrer not exists");
        require(_isUserExists(x3Upline), "_registrationValidation: x3Upline not exists");
        require(_isUserExists(x4Upline), "_registrationValidation: x4Upline not exists");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }

        require(size == 0, "_registrationValidation: cannot be a contract");
    }

    function _isUserExists(address user) private view returns (bool) {
        return (users[user].id != 0);
    }

    function _send(address to, uint256 amount, bool isAutoSystem) private {
        require(to != address(0), "_send: zero address");
        address(uint160(to)).transfer(amount);

        emit EthSent(to, amount, isAutoSystem);
    }

    function _bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    // -----------------------------------------
    // PRIVATE (X3 X4)
    // -----------------------------------------

    function _newX3X4Member(address userAddress) private {
        users[userAddress].activeX3Levels[1] = true;
        users[userAddress].activeX4Levels[1] = true;

        address freeX3Referrer = _findFreeX3Referrer(userAddress, 1);
        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;

        _updateX3Referrer(userAddress, freeX3Referrer, 1);
        _updateX4Referrer(userAddress, _findFreeX4Referrer(userAddress, 1), 1);
    }

    function _buyNewLevel(uint8 matrix, uint8 level) private {
        if (matrix == 1) {
            require(!users[msg.sender].activeX3Levels[level], "_buyNewLevel: level already activated");
            require(users[msg.sender].activeX3Levels[level - 1], "_buyNewLevel: this level can not be bought");

            if (users[msg.sender].x3Matrix[level-1].blocked) {
                users[msg.sender].x3Matrix[level-1].blocked = false;
            }

            address freeX3Referrer = _findFreeX3Referrer(msg.sender, level);
            users[msg.sender].x3Matrix[level].currentReferrer = freeX3Referrer;
            users[msg.sender].activeX3Levels[level] = true;
            _updateX3Referrer(msg.sender, freeX3Referrer, level);

            emit Upgrade(msg.sender, freeX3Referrer, 1, level);
        } else {
            require(!users[msg.sender].activeX4Levels[level], "_buyNewLevel: level already activated");
            require(users[msg.sender].activeX4Levels[level - 1], "_buyNewLevel: this level can not be bought");

            if (users[msg.sender].x4Matrix[level-1].blocked) {
                users[msg.sender].x4Matrix[level-1].blocked = false;
            }

            address freeX4Referrer = _findFreeX4Referrer(msg.sender, level);

            users[msg.sender].activeX4Levels[level] = true;
            _updateX4Referrer(msg.sender, freeX4Referrer, level);

            emit Upgrade(msg.sender, freeX4Referrer, 2, level);
        }
    }

    function _updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x3Matrix[level].referrals.length < 2) {
            users[referrerAddress].x3Matrix[level].referrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));
            return _sendETHDividends(referrerAddress, userAddress, 1, level);
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
            address freeReferrerAddress = _findFreeX3Referrer(referrerAddress, level);
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }

            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);

            _updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            _sendETHDividends(owner, userAddress, 1, level);
            users[owner].x3Matrix[level].reinvestCount++;

            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }

    function _updateX4Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeX4Levels[level], "_updateX4Referrer: referrer level is inactive");

        // ADD 2ND PLACE OF FIRST LEVEL (3 members available)
        if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].x4Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].x4Matrix[level].firstLevelReferrals.length));

            //set current level
            users[userAddress].x4Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return _sendETHDividends(referrerAddress, userAddress, 2, level);
            }

            address ref = users[referrerAddress].x4Matrix[level].currentReferrer;
            users[ref].x4Matrix[level].secondLevelReferrals.push(userAddress);

            uint256 len = users[ref].x4Matrix[level].firstLevelReferrals.length;

            if ((len == 2) &&
                (users[ref].x4Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].x4Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].x4Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (len == 2 && users[ref].x4Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].x4Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }

            return _updateX4ReferrerSecondLevel(userAddress, ref, level);
        }

        users[referrerAddress].x4Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].x4Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x4Matrix[level].closedPart)) {

                _updateX4(userAddress, referrerAddress, level, true);
                return _updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x4Matrix[level].closedPart) {
                _updateX4(userAddress, referrerAddress, level, true);
                return _updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                _updateX4(userAddress, referrerAddress, level, false);
                return _updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[1] == userAddress) {
            _updateX4(userAddress, referrerAddress, level, false);
            return _updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].x4Matrix[level].firstLevelReferrals[0] == userAddress) {
            _updateX4(userAddress, referrerAddress, level, true);
            return _updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
        }

        if (users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length <=
            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length) {
            _updateX4(userAddress, referrerAddress, level, false);
        } else {
            _updateX4(userAddress, referrerAddress, level, true);
        }

        _updateX4ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function _updateX4(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.push(userAddress);

            emit NewUserPlace(userAddress, users[referrerAddress].x4Matrix[level].firstLevelReferrals[0], 2, level, uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 2 + uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[0]].x4Matrix[level].firstLevelReferrals.length));

            //set current level
            users[userAddress].x4Matrix[level].currentReferrer = users[referrerAddress].x4Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.push(userAddress);

            emit NewUserPlace(userAddress, users[referrerAddress].x4Matrix[level].firstLevelReferrals[1], 2, level, uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 4 + uint8(users[users[referrerAddress].x4Matrix[level].firstLevelReferrals[1]].x4Matrix[level].firstLevelReferrals.length));

            //set current level
            users[userAddress].x4Matrix[level].currentReferrer = users[referrerAddress].x4Matrix[level].firstLevelReferrals[1];
        }
    }

    function _updateX4ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x4Matrix[level].secondLevelReferrals.length < 4) {
            return _sendETHDividends(referrerAddress, userAddress, 2, level);
        }

        address[] memory x4 = users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].firstLevelReferrals;

        if (x4.length == 2) {
            if (x4[0] == referrerAddress ||
                x4[1] == referrerAddress) {
                users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].closedPart = referrerAddress;
            }
        } else if (x4.length == 1) {
            if (x4[0] == referrerAddress) {
                users[users[referrerAddress].x4Matrix[level].currentReferrer].x4Matrix[level].closedPart = referrerAddress;
            }
        }

        users[referrerAddress].x4Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].x4Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].x4Matrix[level].closedPart = address(0);

        if (!users[referrerAddress].activeX4Levels[level+1] && level != LAST_LEVEL) {
            users[referrerAddress].x4Matrix[level].blocked = true;
        }

        users[referrerAddress].x4Matrix[level].reinvestCount++;

        if (referrerAddress != owner) {
            address freeReferrerAddress = _findFreeX4Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            _updateX4Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner, address(0), userAddress, 2, level);
            _sendETHDividends(owner, userAddress, 2, level);
        }
    }

    function _findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns (address, bool) {
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
        } else {
            while (true) {
                if (users[receiver].x4Matrix[level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = users[receiver].x4Matrix[level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        }
    }

    function _sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level) private {
        (address receiver, bool isExtraDividends) = _findEthReceiver(userAddress, _from, matrix, level);

        _send(receiver, LEVEL_PRICE[level], false);

        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
    }

    function _findFreeX3Referrer(address userAddress, uint8 level) private view returns (address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function _findFreeX4Referrer(address userAddress, uint8 level) private view returns (address) {
        while (true) {
            if (users[users[userAddress].referrer].activeX4Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }


    // -----------------------------------------
    // PRIVATE (X3 X4 AUTO)
    // -----------------------------------------

    function _newX3X4AutoMember(address userAddress, address referrerAddress, address x3AutoUpline, address x4AutoUpline) private {
        if (users[x3AutoUpline].x3Auto[0].referrals.length >= X3_AUTO_DOWNLINES_LIMIT) {
            x3AutoUpline = _detectX3AutoUpline(referrerAddress);
        }

        if (users[x4AutoUpline].x4Auto[0].firstLevelReferrals.length >= X4_AUTO_DOWNLINES_LIMIT) {
            x4AutoUpline = _detectX4AutoUpline(referrerAddress);
        }

        // Register x3Auto values
        users[userAddress].x3Auto[0].upline = x3AutoUpline;
        users[userAddress].x3Auto[0].upline_id = users[x3AutoUpline].id;

        // Register x4Auto values
        users[userAddress].x4Auto[0].upline = x4AutoUpline;
        users[userAddress].x4Auto[0].upline_id = users[x4AutoUpline].id;

        // Add member to x3Auto upline referrals
        users[x3AutoUpline].x3Auto[0].referrals.push(userAddress);

        // Add member to x4Auto upline first referrals
        users[x4AutoUpline].x4Auto[0].firstLevelReferrals.push(userAddress);

        // Add member to x4Auto upline of upline second referrals
        users[users[x4AutoUpline].x4Auto[0].upline].x4Auto[0].secondLevelReferrals.push(userAddress);

        // Increase level of user
        _x3AutoUpLevel(userAddress, 1);
        _x4AutoUpLevel(userAddress, 1);

        // Check the state and pay to uplines
        _x3AutoUplinePay(REGISTRATION_FEE / 4, x3AutoUpline, userAddress);
        _x4AutoUplinePay(REGISTRATION_FEE / 4, users[x4AutoUpline].x4Auto[0].upline, userAddress);

        emit AutoSystemRegistration(userAddress, x3AutoUpline, x4AutoUpline);
    }

    function _detectUplinesAddresses(address userAddress) private view returns(address, address) {
        address x3AutoUplineAddress = _detectX3AutoUpline(userAddress);
        address x4AutoUplineAddress = _detectX4AutoUpline(userAddress);

        return (
            x3AutoUplineAddress,
            x4AutoUplineAddress
        );
    }

    function _detectX3AutoUpline(address userAddress) private view returns (address) {
        if (users[userAddress].x3Auto[0].referrals.length < X3_AUTO_DOWNLINES_LIMIT) {
            return userAddress;
        }

        address[] memory referrals = new address[](1515);
        referrals[0] = users[userAddress].x3Auto[0].referrals[0];
        referrals[1] = users[userAddress].x3Auto[0].referrals[1];
        referrals[2] = users[userAddress].x3Auto[0].referrals[2];

        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 1515; i++) {
            if (users[referrals[i]].x3Auto[0].referrals.length == X3_AUTO_DOWNLINES_LIMIT) {
                if (i < 504) {
                    referrals[(i + 1) * 3] = users[referrals[i]].x3Auto[0].referrals[0];
                    referrals[(i + 1) * 3 + 1] = users[referrals[i]].x3Auto[0].referrals[1];
                    referrals[(i + 1) * 3 + 2] = users[referrals[i]].x3Auto[0].referrals[2];
                }
            } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }

    function _detectX4AutoUpline(address userAddress) private view returns (address) {
        if (users[userAddress].x4Auto[0].firstLevelReferrals.length < X4_AUTO_DOWNLINES_LIMIT) {
            return userAddress;
        }

        address[] memory referrals = new address[](994);
        referrals[0] = users[userAddress].x4Auto[0].firstLevelReferrals[0];
        referrals[1] = users[userAddress].x4Auto[0].firstLevelReferrals[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for (uint256 i = 0; i < 994; i++) {
            if (users[referrals[i]].x4Auto[0].firstLevelReferrals.length == X4_AUTO_DOWNLINES_LIMIT) {
                if (i < 496) {
                    referrals[(i + 1) * 2] = users[referrals[i]].x4Auto[0].firstLevelReferrals[0];
                    referrals[(i + 1) * 2 + 1] = users[referrals[i]].x4Auto[0].firstLevelReferrals[1];
                }
            } else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }

    function _x3AutoUpLevel(address user, uint8 level) private {
        users[user].x3Auto[0].level = level;
        emit AutoSystemLevelUp(user, 1, level);
    }

    function _x4AutoUpLevel(address user, uint8 level) private {
        users[user].x4Auto[0].level = level;
        emit AutoSystemLevelUp(user, 2, level);
    }

    function _getX4AutoReinvestReceiver(address user) private view returns (address) {
        address receiver = address(0);

        if (
            user != address(0) &&
            users[user].x4Auto[0].upline != address(0) &&
            users[users[user].x4Auto[0].upline].x4Auto[0].upline != address(0)
        ) {
            receiver = users[users[user].x4Auto[0].upline].x4Auto[0].upline;
        }

        return receiver;
    }

    function _x3AutoUplinePay(uint256 value, address upline, address downline) private {
        // If upline not defined
        if (upline == address(0)) {
            _send(owner, value, true);
            return;
        }

        bool isReinvest = users[upline].x3Auto[0].referrals.length == 3 && users[upline].x3Auto[0].referrals[2] == downline;
        if (isReinvest) {
            // Transfer funds to upline of msg.senders' upline
            address reinvestReceiver = _findFreeX3AutoReferrer(downline);
            _send(reinvestReceiver, value, true);
            emit AutoSystemReinvest(reinvestReceiver, downline, value, 1);
            return;
        }

        bool isLevelUp = users[upline].x3Auto[0].referrals.length >= 2;
        if (isLevelUp) {
            uint8 firstReferralLevel = users[users[upline].x3Auto[0].referrals[0]].x3Auto[0].level;
            uint8 secondReferralLevel = users[users[upline].x3Auto[0].referrals[1]].x3Auto[0].level;
            uint8 lowestLevelReferral = firstReferralLevel > secondReferralLevel ? secondReferralLevel : firstReferralLevel;

            if (users[upline].x3Auto[0].level == lowestLevelReferral) {
                uint256 levelMaxCap = LEVEL_PRICE[users[upline].x3Auto[0].level + 1];
                _x3AutoUpLevel(upline, users[upline].x3Auto[0].level + 1);
                _x3AutoUplinePay(levelMaxCap, users[upline].x3Auto[0].upline, upline);
            }
        }
    }

    function _x4AutoUplinePay(uint256 value, address upline, address downline) private {
        // If upline not defined
        if (upline == address(0)) {
            _send(owner, value, true);
            return;
        }

        bool isReinvest = users[upline].x4Auto[0].secondLevelReferrals.length == 4 && users[upline].x4Auto[0].secondLevelReferrals[3] == downline;
        if (isReinvest) {
            // Transfer funds to upline of msg.senders' upline
            address reinvestReceiver = _findFreeX4AutoReferrer(upline);
            _send(reinvestReceiver, value, true);
            emit AutoSystemReinvest(reinvestReceiver, downline, value, 2);
            return;
        }

        bool isEarning = users[upline].x4Auto[0].secondLevelReferrals.length == 3 && users[upline].x4Auto[0].secondLevelReferrals[2] == downline;
        if (isEarning) {
            _send(upline, value, true);
            emit AutoSystemEarning(upline, downline);
            return;
        }

        bool isLevelUp = users[upline].x4Auto[0].secondLevelReferrals.length >= 2;
        if (isLevelUp) {
            uint8 firstReferralLevel = users[users[upline].x4Auto[0].secondLevelReferrals[0]].x4Auto[0].level;
            uint8 secondReferralLevel = users[users[upline].x4Auto[0].secondLevelReferrals[1]].x4Auto[0].level;
            uint8 lowestLevelReferral = firstReferralLevel > secondReferralLevel ? secondReferralLevel : firstReferralLevel;

            if (users[upline].x4Auto[0].level == lowestLevelReferral) {
                // The limit, which needed to upline for achieving a new level
                uint256 levelMaxCap = LEVEL_PRICE[users[upline].x4Auto[0].level + 1];

                // If upline level limit reached
                _x4AutoUpLevel(upline, users[upline].x4Auto[0].level + 1);

                address uplineOfUpline = _getX4AutoReinvestReceiver(upline);
                if (upline != users[uplineOfUpline].x4Auto[0].secondLevelReferrals[0] && upline != users[uplineOfUpline].x4Auto[0].secondLevelReferrals[1]) {
                    uplineOfUpline = address(0);
                }

                _x4AutoUplinePay(levelMaxCap, uplineOfUpline, upline);
            }
        }
    }

    function _findFreeX3AutoReferrer(address userAddress) private view returns (address) {
        while (true) {
            address upline = users[userAddress].x3Auto[0].upline;

            if (upline == address(0) || userAddress == owner) {
                return owner;
            }

            if (
                users[upline].x3Auto[0].referrals.length < X3_AUTO_DOWNLINES_LIMIT ||
                users[upline].x3Auto[0].referrals[2] != userAddress) {
                return upline;
            }

            userAddress = upline;
        }
    }

    function _findFreeX4AutoReferrer(address userAddress) private view returns (address) {
        while (true) {
            address upline = _getX4AutoReinvestReceiver(userAddress);

            if (upline == address(0) || userAddress == owner) {
                return owner;
            }

            if (
                users[upline].x4Auto[0].secondLevelReferrals.length < 4 ||
                users[upline].x4Auto[0].secondLevelReferrals[3] != userAddress
            ) {
                return upline;
            }

            userAddress = upline;
        }
    }

    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    function findFreeX3Referrer(address userAddress, uint8 level) external view returns (address) {
        return _findFreeX3Referrer(userAddress, level);
    }

    function findFreeX4Referrer(address userAddress, uint8 level) external view returns (address) {
        return _findFreeX4Referrer(userAddress, level);
    }

    function findFreeX3AutoReferrer(address userAddress) external view returns (address) {
        return _findFreeX3AutoReferrer(userAddress);
    }

    function findFreeX4AutoReferrer(address userAddress) external view returns (address) {
        return _findFreeX4AutoReferrer(userAddress);
    }

    function findAutoUplines(address referrer) external view returns(address, address, uint256, uint256) {
        (address x3UplineAddr, address x4UplineAddr) = _detectUplinesAddresses(referrer);
        return (
            x3UplineAddr,
            x4UplineAddr,
            users[x3UplineAddr].id,
            users[x4UplineAddr].id
        );
    }

    function findAutoUplines(uint256 referrerId) external view returns(address, address, uint256, uint256) {
        (address x3UplineAddr, address x4UplineAddr) = _detectUplinesAddresses(userIds[referrerId]);
        return (
            x3UplineAddr,
            x4UplineAddr,
            users[x3UplineAddr].id,
            users[x4UplineAddr].id
        );
    }

    function usersActiveX3Levels(address userAddress, uint8 level) external view returns (bool) {
        return users[userAddress].activeX3Levels[level];
    }

    function usersActiveX4Levels(address userAddress, uint8 level) external view returns (bool) {
        return users[userAddress].activeX4Levels[level];
    }

    function getUserX3Matrix(address userAddress, uint8 level) external view returns (
        address currentReferrer,
        address[] memory referrals,
        bool blocked,
        uint256 reinvestCount
    ) {
        return (
            users[userAddress].x3Matrix[level].currentReferrer,
            users[userAddress].x3Matrix[level].referrals,
            users[userAddress].x3Matrix[level].blocked,
            users[userAddress].x3Matrix[level].reinvestCount
        );
    }

    function getUserX4Matrix(address userAddress, uint8 level) external view returns (
        address currentReferrer,
        address[] memory firstLevelReferrals,
        address[] memory secondLevelReferrals,
        bool blocked,
        address closedPart,
        uint256 reinvestCount
    ) {
        return (
            users[userAddress].x4Matrix[level].currentReferrer,
            users[userAddress].x4Matrix[level].firstLevelReferrals,
            users[userAddress].x4Matrix[level].secondLevelReferrals,
            users[userAddress].x4Matrix[level].blocked,
            users[userAddress].x4Matrix[level].closedPart,
            users[userAddress].x3Matrix[level].reinvestCount
        );
    }

    function getUserX3Auto(address user) external view returns (
        uint256 id,
        uint8 level,
        uint256 upline_id,
        address upline,
        address[] memory referrals
    ) {
        return (
            users[user].id,
            users[user].x3Auto[0].level,
            users[user].x3Auto[0].upline_id,
            users[user].x3Auto[0].upline,
            users[user].x3Auto[0].referrals
        );
    }

    function getUserX4Auto(address user) external view returns (
        uint256 id,
        uint8 level,
        uint256 upline_id,
        address upline,
        address[] memory firstLevelReferrals,
        address[] memory secondLevelReferrals
    ) {
        return (
            users[user].id,
            users[user].x4Auto[0].level,
            users[user].x4Auto[0].upline_id,
            users[user].x4Auto[0].upline,
            users[user].x4Auto[0].firstLevelReferrals,
            users[user].x4Auto[0].secondLevelReferrals
        );
    }

    function isUserExists(address user) external view returns (bool) {
        return _isUserExists(user);
    }
}