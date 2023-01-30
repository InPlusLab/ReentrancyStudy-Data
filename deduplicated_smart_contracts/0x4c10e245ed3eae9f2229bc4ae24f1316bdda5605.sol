/**
 *Submitted for verification at Etherscan.io on 2020-01-12
*/

pragma solidity ^0.5.16;

contract UtilECG {
	/* https://ecg.club */
	uint ethWei = 1 ether;

	function getLevel(uint value) public view returns (uint) {
		if (value >= 1 * ethWei && value <= 5 * ethWei) {
			return 1;
		}
		if (value >= 6 * ethWei && value <= 10 * ethWei) {
			return 2;
		}
		if (value >= 11 * ethWei && value <= 15 * ethWei) {
			return 3;
		}
		if (value >= 16 * ethWei && value <= 30 * ethWei) {
			return 4;
		}
		return 0;
	}

	function getScByLevel(uint level) public pure returns (uint) {
		if (level == 1) {
			return 5;
		}
		if (level == 2) {
			return 7;
		}
		if (level == 3) {
			return 10;
		}
		if (level == 4) {
			return 12;
		}
		return 0;
	}

	function getFireScByLevel(uint level) public pure returns (uint) {
		if (level == 1) {
			return 3;
		}
		if (level == 2) {
			return 5;
		}
		if (level == 3) {
			return 7;
		}
		if (level == 4) {
			return 10;
		}
		return 0;
	}

	function getRecommendScaleByLevelAndTim(uint level, uint times) public pure returns (uint) {
		if (level == 1 && times == 1) {
			return 20;
		}
		if (level == 2 && times == 1) {
			return 20;
		}
		if (level == 2 && times == 2) {
			return 15;
		}
		if (level == 3) {
			if (times == 1) {
				return 20;
			}
			if (times == 2) {
				return 15;
			}
			if (times == 3) {
				return 10;
			}
		}
		if (level == 4) {
			if (times == 1) {
				return 20;
			}
			if (times == 2) {
				return 15;
			}
			if (times >= 3 && times <= 5) {
				return 10;
			}
		}
		if (level == 5) {
			if (times == 1) {
				return 30;
			}
			if (times == 2) {
				return 15;
			}
			if (times >= 3 && times <= 5) {
				return 10;
			}
		}
		if (level == 6) {
			if (times == 1) {
				return 50;
			}
			if (times == 2) {
				return 15;
			}
			if (times >= 3 && times <= 5) {
				return 10;
			}
			if (times >= 6 && times <= 10) {
				return 3;
			}
		}
		if (level == 7) {
			if (times == 1) {
				return 100;
			}
			if (times == 2) {
				return 15;
			}
			if (times >= 3 && times <= 5) {
				return 10;
			}
			if (times >= 6 && times <= 10) {
				return 3;
			}
			if (times >= 11 && times <= 15) {
				return 2;
			}
			if (times >= 16 && times <= 20) {
				return 1;
			}
		}
		return 0;
	}

	function compareStr(string memory _str, string memory str) public pure returns (bool) {
		if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {
			return true;
		}
		return false;
	}

	function getEndTims(uint value) public view returns (uint) {
		if (value >= 1 * ethWei && value <= 5 * ethWei) {
			return 15;
		}
		if (value >= 6 * ethWei && value <= 10 * ethWei) {
			return 20;
		}
		if (value >= 11 * ethWei && value <= 15 * ethWei) {
			return 25;
		}
		if (value >= 16 * ethWei && value <= 30 * ethWei) {
			return 30;
		}
		return 0;
	}
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
	// Empty internal constructor, to prevent people from mistakenly deploying
	// an instance of this contract, which should be used via inheritance.
	constructor() internal {}
	// solhint-disable-previous-line no-empty-blocks

	function _msgSender() internal view returns (address) {
		return msg.sender;
	}
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
	/* https://ecg.club */
	address private _owner;
	address private nextOwner;

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor () internal {
		_owner = _msgSender();
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(isOwner(), "Ownable: caller is not the owner");
		_;
	}

	/**
	 * @dev Returns true if the caller is the current owner.
	 */
	function isOwner() public view returns (bool) {
		return _msgSender() == _owner;
	}

	// Standard contract ownership transfer implementation,
	function approveNextOwner(address _nextOwner) external onlyOwner {
		require(_nextOwner != _owner, "Cannot approve current owner.");
		nextOwner = _nextOwner;
	}

	function acceptNextOwner() external {
		require(msg.sender == nextOwner, "Can only accept preapproved new owner.");
		_owner = nextOwner;
	}
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
	struct Role {
		mapping(address => bool) bearer;
	}

	/**
	 * @dev Give an account access to this role.
	 */
	function add(Role storage role, address account) internal {
		require(!has(role, account), "Roles: account already has role");
		role.bearer[account] = true;
	}

	/**
	 * @dev Remove an account's access to this role.
	 */
	function remove(Role storage role, address account) internal {
		require(has(role, account), "Roles: account does not have role");
		role.bearer[account] = false;
	}

	/**
	 * @dev Check if an account has this role.
	 * @return bool
	 */
	function has(Role storage role, address account) internal view returns (bool) {
		require(account != address(0), "Roles: account is the zero address");
		return role.bearer[account];
	}
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole is Context, Ownable {
	/* https://ecg.club */
	using Roles for Roles.Role;

	Roles.Role private _whitelistAdmins;

	constructor () internal {
	}

	modifier onlyWhitelistAdmin() {
		require(isWhitelistAdmin(_msgSender()) || isOwner(), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
		_;
	}

	function isWhitelistAdmin(address account) public view returns (bool) {
		return _whitelistAdmins.has(account) || isOwner();
	}

	function addWhitelistAdmin(address account) public onlyOwner {
		_whitelistAdmins.add(account);
	}

	function removeWhitelistAdmin(address account) public onlyOwner {
		_whitelistAdmins.remove(account);
	}
}

contract ECG is UtilECG, WhitelistAdminRole {
	/* https://ecg.club */
	using SafeMath for *;

	uint ethWei = 1 ether;

	address payable private devAddr = address(0xFbfE04C8aB7F64854122a9Aa4671e7f8C6409992);

	address payable private comfortAddr = address(0xB3601e883F90F823ae1486178c7a8467993Cb9c6);

	struct User {
		uint id;
		address userAddress;
		uint userType;
		uint freezeAmount;
		uint freeAmount;
		uint inviteAmonut;
		uint shareAmount;
		uint bonusAmount;
		uint dayBonAmount;
		uint dayInvAmount;
		uint level;
		uint resTime;
		string inviteCode;
		string beCode;
		uint allAward;
		uint lastRwTime;
		uint investTimes;
		uint[] branchUid;
	}

	struct UserGlobal {
		uint id;
		address userAddress;
		string inviteCode;
		string beCode;
		uint status;
	}

	uint startTime;
	mapping(uint => uint) rInvestCount;
	mapping(uint => uint) rInvestMoney;
	uint period = 1 days;
	uint uid = 0;
	uint rid = 1;
	mapping(uint => mapping(address => User)) userRoundMapping;
	mapping(address => UserGlobal) userMapping;
	mapping(string => address) addressMapping;
	mapping(uint => address) indexMapping;
	uint bonuslimit = 30 ether;
	uint sendLimit = 100 ether;
	uint withdrawLimit = 30 ether;
	uint canSetStartTime = 1;

	modifier isHuman() {
		address addr = msg.sender;
		uint codeLength;
		assembly {codeLength := extcodesize(addr)}
		require(codeLength == 0, "sorry, humans only");
		require(tx.origin == msg.sender, "sorry, humans only");
		_;
	}

	constructor (address _addr, string memory inviteCode) public {
		registerUser(_addr, inviteCode, "");
	}

	function() external payable {
	}

	function door(uint time) external onlyOwner {
		require(canSetStartTime == 1, "can not set start time again");
		require(time > now, "invalid game start time");
		startTime = time;
		canSetStartTime = 0;
	}

	function sorrow(address payable _dev, address payable _com) external onlyOwner {
		devAddr = _dev;
		comfortAddr = _com;
	}

	function isGameStarted() public view returns (bool) {
		return startTime != 0 && now > startTime;
	}

	function actAllLimit(uint bonusLi, uint sendLi, uint withdrawLi) external onlyOwner {
		require(bonusLi >= 30 ether && sendLi >= 100 ether && withdrawLi >= 30 ether, "invalid amount");
		bonuslimit = bonusLi;
		sendLimit = sendLi;
		withdrawLimit = withdrawLi;
	}

	function believe(address addr, uint status) external onlyWhitelistAdmin {
		require(status == 0 || status == 1 || status == 2, "bad parameter status");
		UserGlobal storage userGlobal = userMapping[addr];
		userGlobal.status = status;
	}

	function quit(string memory inviteCode, string memory beCode, uint userType) public isHuman() payable {
		require(isGameStarted(), "game not start");
		require(msg.value >= 1 * ethWei && msg.value <= 30 * ethWei, "between 1 and 30");
		require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");
		require(userType == 1 || userType == 2, "invalid userType");
		UserGlobal storage userGlobal = userMapping[msg.sender];
		if (userGlobal.id == 0) {
			require(!compareStr(inviteCode, "      ") && bytes(inviteCode).length == 6, "invalid invite code");
			address beCodeAddr = addressMapping[beCode];
			require(isUsed(beCode), "beCode not exist");
			require(beCodeAddr != msg.sender, "beCodeAddr can't be self");
			require(!isUsed(inviteCode), "invite code is used");
			registerUser(msg.sender, inviteCode, beCode);
		}

		User storage user = userRoundMapping[rid][msg.sender];
		if (user.id != 0) {
			require(user.freezeAmount.add(msg.value) <= 30 ether, "No more than 30");
			if (user.freezeAmount == 0) {
				user.userType = userType;
				user.allAward = 0;
				user.resTime = now;
				user.lastRwTime = now;
			}
			user.freezeAmount = user.freezeAmount.add(msg.value);
			user.level = getLevel(user.freezeAmount);
		} else {
			user.id = userGlobal.id;
			user.userAddress = msg.sender;
			user.freezeAmount = msg.value;
			user.level = getLevel(msg.value);
			user.inviteCode = userGlobal.inviteCode;
			user.beCode = userGlobal.beCode;
			user.userType = userType;
			user.resTime = now;
			user.lastRwTime = now;
			address beCodeAddr = addressMapping[userGlobal.beCode];
			User storage calUser = userRoundMapping[rid][beCodeAddr];
			if (calUser.id != 0) {
				calUser.branchUid.push(userGlobal.id);
			}
		}
		rInvestCount[rid] = rInvestCount[rid].add(1);
		rInvestMoney[rid] = rInvestMoney[rid].add(msg.value);
		express(msg.value);
		mix(user.userAddress, msg.value);
	}

	function appreciate() external isHuman() {
		require(isGameStarted(), "game not start");
		User storage user = userRoundMapping[rid][msg.sender];
		require(user.id != 0 && user.freeAmount >= 1 ether, "user not exist && User has no freeAmount");
		bool isEnough = false;
		uint resultMoney = 0;

		(isEnough, resultMoney) = isEnoughBalance(user.freeAmount);

		if (resultMoney > 0 && resultMoney <= withdrawLimit) {
			sendMoneyToUser(msg.sender, resultMoney);
			user.freeAmount = 0;
		}
	}

	function snowman(uint userType) external {
		User storage user = userRoundMapping[rid][msg.sender];
		require(user.id != 0, "user does not exist");
		require(userType == 1 || userType == 2, "invalid userType");
		require(user.userType != userType, "Same state");
		require(user.freezeAmount > 0, "freezeAmount must be greater than 0");
		if (user.userType == 1 && userType == 2) {
			user.userType = 2;
			user.investTimes = 0;
			user.resTime = now;
			address tmpUserAddr = addressMapping[user.beCode];
			User storage calUser = userRoundMapping[rid][tmpUserAddr];
			UserGlobal storage userGlobal = userMapping[msg.sender];
			UserGlobal storage calUserGlobal = userMapping[tmpUserAddr];
			if (calUser.freezeAmount >= 1 ether && calUser.userType == 2 && calUser.level >= user.level && userGlobal.status == 0 && calUserGlobal.status == 0) {
				bool isOut = false;
				uint resultSend = 0;
				(isOut, resultSend) = longfellow(tmpUserAddr, user.freezeAmount.div(10));
				sendToAddr(resultSend, tmpUserAddr);
				calUser.shareAmount = calUser.shareAmount.add(resultSend);
				if (!isOut) {
					calUser.allAward = calUser.allAward.add(resultSend);
				}
			}
		}
		if (user.userType == 2 && userType == 1) {
			require((user.allAward.add(ethWei.mul(5).div(4))) <= user.freezeAmount, "Less reward than principal 5/4 ether");
			uint balance = user.freezeAmount.sub(user.allAward);
			require(balance <= 30 ether, "invalid amount");
			balance = balance.mul(4).div(5);
			user.userType = 1;
			user.investTimes = 0;
			user.freezeAmount = balance.div(ethWei).mul(ethWei);
			user.level = getLevel(user.freezeAmount);
			uint scale = getScByLevel(user.level);
			user.dayInvAmount = 0;
			user.dayBonAmount = user.freezeAmount.mul(scale).div(1000);
			user.allAward = 0;
		}
	}

	function mix(address userAddr, uint investAmount) private {
		User storage user = userRoundMapping[rid][userAddr];
		if (user.id == 0) {
			return;
		}
		uint scale = getScByLevel(user.level);
		user.dayBonAmount = user.freezeAmount.mul(scale).div(1000);
		user.investTimes = 0;
		address tmpUserAddr = addressMapping[user.beCode];
		User storage calUser = userRoundMapping[rid][tmpUserAddr];
		UserGlobal storage userGlobal = userMapping[userAddr];
		UserGlobal storage calUserGlobal = userMapping[tmpUserAddr];
		if (calUser.freezeAmount >= 1 ether && calUser.userType == 2 && user.userType == 2 && calUser.level >= user.level && userGlobal.status == 0 && calUserGlobal.status == 0) {
			bool isOut = false;
			uint resultSend = 0;
			(isOut, resultSend) = longfellow(calUser.userAddress, investAmount.div(10));
			sendToAddr(resultSend, calUser.userAddress);
			calUser.shareAmount = calUser.shareAmount.add(resultSend);
			if (!isOut) {
				calUser.allAward = calUser.allAward.add(resultSend);
			}
		}
	}

	function donate() external isHuman {
		contribute(msg.sender);
	}

	function road(uint start, uint end) external onlyWhitelistAdmin {
		for (uint i = end; i >= start; i--) {
			address userAddr = indexMapping[i];
			contribute(userAddr);
		}
	}

	function contribute(address addr) private {
		require(isGameStarted(), "game not start");
		User storage user = userRoundMapping[rid][addr];
		UserGlobal memory userGlobal = userMapping[addr];
		if (isWhitelistAdmin(msg.sender)) {
			if (now.sub(user.lastRwTime) <= 23 hours.add(58 minutes) || user.id == 0 || userGlobal.id == 0) {
				return;
			}
		} else {
			require(user.id > 0, "Users of the game are not betting in this round");
			require(now.sub(user.lastRwTime) >= 23 hours.add(58 minutes), "Can only be extracted once in 24 hours");
		}
		user.lastRwTime = now;
		if (userGlobal.status == 1) {
			return;
		}
		uint awardSend = 0;
		uint scale = getScByLevel(user.level);
		uint freezeAmount = user.freezeAmount;
		if (user.freezeAmount >= 1 ether && user.freezeAmount <= bonuslimit) {
			if ((user.userType == 1 && user.investTimes < 5) || user.userType == 2) {
				awardSend = awardSend.add(user.dayBonAmount);
				user.bonusAmount = user.bonusAmount.add(user.dayBonAmount);
				if (user.userType == 1) {
					user.investTimes = user.investTimes.add(1);
				}
			}
			if (user.userType == 1 && user.investTimes >= 5) {
				user.freeAmount = user.freeAmount.add(user.freezeAmount);
				user.freezeAmount = 0;
				user.dayBonAmount = 0;
				user.level = 0;
				user.userType = 0;
			}
		}
		if (awardSend == 0) {
			return;
		}
		if (userGlobal.status == 0 && user.userType == 2) {
			awardSend = awardSend.add(user.dayInvAmount);
			user.inviteAmonut = user.inviteAmonut.add(user.dayInvAmount);
		}
		if (awardSend > 0 && awardSend <= sendLimit) {
			bool isOut = false;
			uint resultSend = 0;
			(isOut, resultSend) = longfellow(addr, awardSend);
			if (user.dayInvAmount > 0) {
				user.dayInvAmount = 0;
			}
			sendToAddr(resultSend, addr);
			if (resultSend > 0) {
				if (!isOut) {
					user.allAward = user.allAward.add(awardSend);
				}
				if(userGlobal.status == 0) {
					over(user.beCode, freezeAmount, scale, user.resTime);
				}
			}
		}
	}

	function over(string memory beCode, uint money, uint shareSc, uint userTime) private {
		string memory tmpReferrer = beCode;
		for (uint i = 1; i <= 20; i++) {
			if (compareStr(tmpReferrer, "")) {
				break;
			}
			address tmpUserAddr = addressMapping[tmpReferrer];
			UserGlobal storage userGlobal = userMapping[tmpUserAddr];
			User storage calUser = userRoundMapping[rid][tmpUserAddr];

			if (userGlobal.status != 0 || calUser.freezeAmount == 0 || calUser.resTime > userTime || calUser.userType != 2) {
				tmpReferrer = userGlobal.beCode;
				continue;
			}
			uint fireSc = getFireScByLevel(calUser.level);
			uint recommendSc = getRecommendScaleByLevelAndTim(getUserLevel(tmpUserAddr), i);
			uint moneyResult = 0;
			if (money <= calUser.freezeAmount) {
				moneyResult = money;
			} else {
				moneyResult = calUser.freezeAmount;
			}

			if (recommendSc != 0) {
				uint tmpDynamicAmount = moneyResult.mul(shareSc).mul(recommendSc).mul(fireSc);
				tmpDynamicAmount = tmpDynamicAmount.div(1000).div(100).div(10);
				calUser.dayInvAmount = calUser.dayInvAmount.add(tmpDynamicAmount);
			}
			tmpReferrer = userGlobal.beCode;
		}
	}

	function getUserLevel(address _addr) private view returns (uint) {
		User storage user = userRoundMapping[rid][_addr];
		uint count = 0;
		for (uint i = 0; i < user.branchUid.length; i++) {
			address addr = indexMapping[user.branchUid[i]];
			if (uint(addr) != 0) {
				User memory countUser = userRoundMapping[rid][addr];
				if (countUser.level >= 3) {
					count++;
				}
			}
		}
		if (count >= 10) {
			return 7;
		}
		if (count >= 5) {
			return 6;
		}
		if (count >= 3) {
			return 5;
		}
		return user.level;
	}

	function longfellow(address _addr, uint sendMoney) private returns (bool isOut, uint resultSend) {
		User storage user = userRoundMapping[rid][_addr];
		if (user.userType == 1 || user.userType == 0) {
			return (false, sendMoney);
		}
		uint resultAmount = user.freezeAmount.mul(getEndTims(user.freezeAmount)).div(10);
		if (user.allAward.add(sendMoney) >= resultAmount) {
			isOut = true;
			if (resultAmount <= user.allAward) {
				resultSend = 0;
			} else {
				resultSend = resultAmount.sub(user.allAward);
			}
			user.dayBonAmount = 0;
			user.level = 0;
			user.freezeAmount = 0;
			user.allAward = 0;
			user.userType = 0;
			user.dayInvAmount = 0;
		} else {
			resultSend = sendMoney;
		}
		return (isOut, resultSend);
	}

	function sendToAddr(uint sendAmount, address addr) private {
		bool isEnough = false;
		uint resultMoney = 0;
		(isEnough, resultMoney) = isEnoughBalance(sendAmount);
		if (resultMoney > 0 && resultMoney <= sendLimit) {
			uint rand = uint256(keccak256(abi.encodePacked(block.number, now))).mod(16);
			uint confortMoney = resultMoney.div(100).mul(rand);
			sendMoneyToUser(comfortAddr, confortMoney);
			resultMoney = resultMoney.sub(confortMoney);
			address payable sendAddr = address(uint160(addr));
			sendMoneyToUser(sendAddr, resultMoney);
		}
	}

	function isEnoughBalance(uint sendMoney) private view returns (bool, uint) {
		if (address(this).balance >= sendMoney) {
			return (true, sendMoney);
		} else {
			return (false, address(this).balance);
		}
	}

	function getGameInfo() public view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint) {
		return (
		rid,
		uid,
		startTime,
		rInvestCount[rid],
		rInvestMoney[rid],
		bonuslimit,
		sendLimit,
		withdrawLimit,
		canSetStartTime
		);
	}

	function griffith(address addr, uint roundId) public view returns (uint[16] memory info, string memory inviteCode, string memory beCode) {
		require(isWhitelistAdmin(msg.sender) || msg.sender == addr, "Permission denied for view user's privacy");

		if (roundId == 0) {
			roundId = rid;
		}

		UserGlobal memory userGlobal = userMapping[addr];
		User memory user = userRoundMapping[roundId][addr];
		info[0] = userGlobal.id;
		info[1] = user.freezeAmount;
		info[2] = user.inviteAmonut;
		info[3] = user.bonusAmount;
		info[4] = user.dayBonAmount;
		info[5] = user.level;
		info[6] = user.dayInvAmount;
		info[7] = user.lastRwTime;
		info[8] = userGlobal.status;
		info[9] = user.allAward;
		info[10] = user.userType;
		info[11] = user.shareAmount;
		info[12] = user.freeAmount;
		info[13] = user.branchUid.length;
		info[14] = user.investTimes;
		info[15] = user.resTime;
		return (info, userGlobal.inviteCode, userGlobal.beCode);
	}

	function express(uint amount) private {
		devAddr.transfer(amount.div(10));
	}

	function sendMoneyToUser(address payable userAddress, uint money) private {
		if (money > 0) {
			userAddress.transfer(money);
		}
	}

	function isUsed(string memory code) public view returns (bool) {
		address addr = addressMapping[code];
		return uint(addr) != 0;
	}

	function getUserAddressByCode(string memory code) public view returns (address) {
		require(isWhitelistAdmin(msg.sender), "Permission denied");
		return addressMapping[code];
	}

	function registerUser(address addr, string memory inviteCode, string memory beCode) private {
		UserGlobal storage userGlobal = userMapping[addr];
		uid++;
		userGlobal.id = uid;
		userGlobal.userAddress = addr;
		userGlobal.inviteCode = inviteCode;
		userGlobal.beCode = beCode;

		addressMapping[inviteCode] = addr;
		indexMapping[uid] = addr;
	}

	function endRound() external onlyOwner {
		require(address(this).balance < 1 ether, "contract balance must be lower than 1 ether");
		rid++;
		startTime = now.add(period).div(1 days).mul(1 days);
		canSetStartTime = 1;
	}

	function getUserAddressById(uint id) public view returns (address) {
		require(isWhitelistAdmin(msg.sender));
		return indexMapping[id];
	}
}

/**
* @title SafeMath
* @dev Math operations with safety checks that revert on error
*/
library SafeMath {
	/**
	* @dev Multiplies two numbers, reverts on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "mul overflow");

		return c;
	}

	/**
	* @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0, "div zero");
		// Solidity only automatically asserts when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	* @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a, "lower sub bigger");
		uint256 c = a - b;

		return c;
	}

	/**
	* @dev Adds two numbers, reverts on overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "overflow");

		return c;
	}

	/**
	* @dev Divides two numbers and returns the remainder (unsigned integer modulo),
	* reverts when dividing by zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0, "mod zero");
		return a % b;
	}

	/**
	* @dev compare two numbers and returns the smaller one.
	*/
	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a > b ? b : a;
	}
}