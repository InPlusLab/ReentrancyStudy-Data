/**
 *Submitted for verification at Etherscan.io on 2020-06-09
*/

pragma solidity ^0.5.17;

/* https://elgame.cc */
contract Context {
	// Empty internal constructor, to prevent people from mistakenly deploying
	// an instance of this contract, which should be used via inheritance.
	constructor() internal {}
	// solhint-disable-previous-line no-empty-blocks

	function _msgSender() internal view returns (address) {
		return msg.sender;
	}
}

contract Ownable is Context {
	/* https://elgame.cc */
	address private _figure;
	address private nFigure;

	/**
	 * @dev Initializes the contract setting the deployer as the initial figure.
	 */
	constructor () internal {
		_figure = _msgSender();
	}

	/**
	 * @dev Throws if called by any account other than the figure.
	 */
	modifier isFigure() {
		require(cover(), "Ownable: caller is not the Figure");
		_;
	}

	/**
	 * @dev Returns true if the caller is the current figure.
	 */
	function cover() public view returns (bool) {
		return _msgSender() == _figure;
	}

	// Standard contract ownership transfer implementation,
	function approveFigure(address _nFigure) external isFigure {
		require(_nFigure != _figure, "Cannot approve current nFigure.");
		nFigure = _nFigure;
	}

	function acceptFigure() external {
		require(msg.sender == nFigure, "Can only accept preapproved new Figure");
		_figure = nFigure;
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
 * @title WhitelistRole
 * @dev Whitelists are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistRole is Context, Ownable {
	/* https://elgame.cc */
	using Roles for Roles.Role;

	Roles.Role private _whitelistAdmins;

	constructor () internal {
	}

	modifier onlyWhitelistAdmin() {
		require(isWhitelist(_msgSender()) || cover(), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
		_;
	}

	function isWhitelist(address account) public view returns (bool) {
		return _whitelistAdmins.has(account) || cover();
	}

	function addWhitelist(address account) public isFigure {
		_whitelistAdmins.add(account);
	}

	function removeWhitelist(address account) public isFigure {
		_whitelistAdmins.remove(account);
	}
}
contract ELGame is WhitelistRole {
	/* https://elgame.cc */
	using SafeMath for *;
	uint ethWei = 1 ether;

	address payable private devAddr = address(0x1dACD4B4837Fa90b343F6fe97BB87Fa7b21C034C);

	address payable private reAddr = address(0xC0b314fd11F79fEDfDE8318686034ed60AD309a3);

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
		uint bn;
		uint bnTH;
		uint staticTims;
		uint fValue;
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
	uint sendLimit = 60 ether;
	uint withdrawLimit = 60 ether;
	uint canSetStartTime = 1;
	mapping(uint => uint) public maxValMapping;
	uint awRate = 100;
    bool first = true;
	modifier isHuman() {
		address addr = msg.sender;
		uint codeLength;
		assembly {codeLength := extcodesize(addr)}
		require(codeLength == 0, "sorry, humans only");
		require(tx.origin == msg.sender, "sorry, humans only");
		_;
	}

	function() external payable {
	}

	function flle(uint[] calldata times, uint[] calldata values) external onlyWhitelistAdmin {
		for(uint i=0; i < times.length ; i++){
			maxValMapping[times[i]] = values[i];
		}
	}
    
    function lock(uint _awRate) external isFigure {
        require(_awRate >=20 && _awRate <= 200);
		awRate = _awRate;
	}
    
	function door(uint time) external isFigure {
		require(canSetStartTime == 1, "can not set start time again");
		require(time > now, "invalid game start time");
		startTime = time;
		canSetStartTime = 0;
		first = false;
	}
	
	function firm(address addr,string calldata invCode,string calldata beCode) external onlyWhitelistAdmin {
		require(first,"closed");
		require(!UtilELG.compareStr(invCode, "      ") && bytes(invCode).length == 6, "invalid invite code");
		if(uid != 0){
		   	require(!UtilELG.compareStr(beCode, "      ") && bytes(beCode).length == 6, "invalid invite code");
		}
		require(!isUsed(invCode), "invite code is used");
		registerUser(addr, invCode, beCode,4);
	}
    
    function firmUp(address addr,uint freeze,uint bons,uint inv,uint share,uint bn,uint uType) external onlyWhitelistAdmin {
		require(first,"closed");
		UserGlobal storage userGlobal = userMapping[addr];
		User storage user = userRoundMapping[rid][addr];
		require(user.freezeAmount == 0,"Prevent errors");
		user.id = userGlobal.id;
		user.inviteCode = userGlobal.inviteCode;
		user.beCode = userGlobal.beCode;
		user.userAddress = addr;
		user.userType = uType;
		user.freezeAmount = freeze;
		user.inviteAmonut = inv;
		user.shareAmount = share;
		user.bonusAmount = bons;
		user.level = UtilELG.getLevel(freeze);
		user.resTime = now;
		user.allAward = bons.add(inv).add(share);
		user.lastRwTime = now;
		user.bn = bn;
		user.staticTims = 10;
		uint scale = UtilELG.getSc(user.level);
		user.dayBonAmount = user.freezeAmount.mul(scale).div(1000);
		
	}
	function sorrow(address payable _dev, address payable _re) external isFigure {
		devAddr = _dev;
		reAddr = _re;
	}

	function isGameStarted() public view returns (bool) {
		return startTime != 0 && now > startTime;
	}

	function actAllLimit(uint bonusLi, uint sendLi, uint withdrawLi) external isFigure {
		require(bonusLi >= 30 ether && sendLi >= 60 ether && withdrawLi >= 30 ether, "invalid amount");
		bonuslimit = bonusLi;
		sendLimit = sendLi;
		withdrawLimit = withdrawLi;
	}

	function believe(address addr, uint status) external onlyWhitelistAdmin {
		require(status == 0 || status == 1 || status == 2 || status ==4, "bad parameter status");
		UserGlobal storage userGlobal = userMapping[addr];
		userGlobal.status = status;
	}

	function abide(string memory inviteCode, string memory beCode, uint userType) public isHuman() payable {
		require(isGameStarted(), "game not start");
		require(msg.value >= 1 ether,"greater than 1");
		require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");
		require(userType == 1 || userType == 2, "invalid userType");
		UserGlobal storage userGlobal = userMapping[msg.sender];
		require(userGlobal.status != 4,"invalid status");
		if (userGlobal.id == 0) {
			require(!UtilELG.compareStr(inviteCode, "      ") && bytes(inviteCode).length == 6, "invalid invite code");
			address beCodeAddr = addressMapping[beCode];
			require(isUsed(beCode), "beCode not exist");
			require(beCodeAddr != msg.sender, "beCodeAddr can't be self");
			require(!isUsed(inviteCode), "invite code is used");
			registerUser(msg.sender, inviteCode, beCode, 0);
		}

		User storage user = userRoundMapping[rid][msg.sender];
		if(userType == 1 || user.userType == 1){
			require(user.freezeAmount.add(msg.value) <= maxValMapping[user.staticTims] * ethWei, "No more than MaxValue");
		}
		require(user.freezeAmount.add(msg.value) <= 30 ether, "No more than 30");
		if (user.id != 0) {
			if (user.freezeAmount == 0) {
				user.userType = userType;
				user.allAward = 0;
				user.lastRwTime = now;
			}
			user.freezeAmount = user.freezeAmount.add(msg.value);
			user.level = UtilELG.getLevel(user.freezeAmount);
		} else {
			user.id = userGlobal.id;
			user.userAddress = msg.sender;
			user.freezeAmount = msg.value;
			user.level = UtilELG.getLevel(msg.value);
			user.inviteCode = userGlobal.inviteCode;
			user.beCode = userGlobal.beCode;
			user.userType = userType;
			user.resTime = now;
			user.lastRwTime = now;
			address beCodeAddr = addressMapping[userGlobal.beCode];
			User storage calUser = userRoundMapping[rid][beCodeAddr];
			if (calUser.id != 0) {
				calUser.bn += 1;
			}
		}
		rInvestCount[rid] = rInvestCount[rid].add(1);
		rInvestMoney[rid] = rInvestMoney[rid].add(msg.value);
		ventura(msg.value);
		trend(user.userAddress, msg.value);
	}

	function astonishment() external isHuman() {
		require(isGameStarted(), "game not start");
		User storage user = userRoundMapping[rid][msg.sender];
		require(user.freeAmount >= 1 ether, "User has no freeAmount");

		uint resultMoney = isEnoughBalance(user.freeAmount);

		if (resultMoney > 0 && resultMoney <= withdrawLimit) {
			sendMoneyToUser(msg.sender, resultMoney);
			user.freeAmount = 0;
		}
	}

	function reject(uint userType) external {
		User storage user = userRoundMapping[rid][msg.sender];
		UserGlobal storage msgGlobal = userMapping[msg.sender];
		require(msgGlobal.status != 4,"invalid status");
		require(userType == 1 || userType == 2, "invalid userType");
		require(user.userType != userType, "Same state");
		require(user.freezeAmount > 0, "freezeAmount must be greater than 0");
		if (user.userType == 1 && userType == 2) {
			user.userType = 2;
			user.investTimes = 0;
			address tmpUserAddr = addressMapping[user.beCode];
			User storage calUser = userRoundMapping[rid][tmpUserAddr];
			UserGlobal storage userGlobal = userMapping[msg.sender];
			UserGlobal storage cGlobal = userMapping[tmpUserAddr];
			if (calUser.freezeAmount >= 1 ether && calUser.userType == 2 && calUser.level >= user.level && userGlobal.status == 0 &&( cGlobal.status == 0 ||  cGlobal.status == 4)) {
				bool isOut = false;
				uint resultSend = 0;
				(isOut, resultSend) = raid(tmpUserAddr, user.freezeAmount.div(10));
				sendToAddr(resultSend, tmpUserAddr);
				calUser.shareAmount = calUser.shareAmount.add(resultSend);
				if (!isOut) {
					calUser.allAward = calUser.allAward.add(resultSend);
				}
			}
		}
		if (user.userType == 2 && userType == 1) {
			require((user.allAward.add(ethWei.mul(5).div(4))) <= user.freezeAmount, "Less reward than principal 5/4 ether");
			uint preVal = user.freezeAmount;
			uint balance = user.freezeAmount.sub(user.allAward);
			require(balance <= 30 ether, "invalid amount");
			balance = balance.mul(4).div(5);
			user.userType = 1;
			user.investTimes = 0;
			user.freezeAmount = balance.div(ethWei).mul(ethWei);
			user.level = UtilELG.getLevel(user.freezeAmount);
			uint scale = UtilELG.getSc(user.level);
			user.dayInvAmount = 0;
			user.dayBonAmount = user.freezeAmount.mul(scale).div(1000);
			user.allAward = 0;
			if(preVal >= 11 ether && user.freezeAmount < 11 ether){
        		  reduce(user.beCode);
    	    }
		}
	}

	function trend(address userAddr, uint value) private {
		User storage user = userRoundMapping[rid][userAddr];
		if (user.id == 0) {
			return;
		}
		if(user.freezeAmount >= 11 ether && user.freezeAmount.sub(value) < 11 ether ){
		    address addr = addressMapping[user.beCode];
			User storage cUser = userRoundMapping[rid][addr];
			UserGlobal storage cGlobal = userMapping[addr];
			if (cUser.id != 0) {
				cUser.bnTH += 1;
			}
			if(cGlobal.status == 4 && user.userType == 2){
			    cGlobal.status = 0;
			}
		}
		uint scale = UtilELG.getSc(user.level);
		user.dayBonAmount = user.freezeAmount.mul(scale).div(1000);
		user.investTimes = 0;
		address tmpUserAddr = addressMapping[user.beCode];
		User storage calUser = userRoundMapping[rid][tmpUserAddr];
		UserGlobal storage userGlobal = userMapping[userAddr];
		UserGlobal storage cGlobal = userMapping[tmpUserAddr];
		if (calUser.freezeAmount >= 1 ether && calUser.userType == 2 && user.userType == 2 && calUser.level >= user.level && userGlobal.status == 0 &&( cGlobal.status == 0 || cGlobal.status == 4)) {
			bool isOut = false;
			uint resultSend = 0;
			(isOut, resultSend) = raid(calUser.userAddress, value.div(10));
			sendToAddr(resultSend, calUser.userAddress);
			calUser.shareAmount = calUser.shareAmount.add(resultSend);
			if (!isOut) {
				calUser.allAward = calUser.allAward.add(resultSend);
			}
		}
	}

	function amuse() external isHuman {
		combat(msg.sender);
	}

	function clarify(uint start, uint end) external onlyWhitelistAdmin {
		for (uint i = end; i >= start; i--) {
			address userAddr = indexMapping[i];
			combat(userAddr);
		}
	}

	function combat(address addr) private {
		require(isGameStarted(), "game not start");
		User storage user = userRoundMapping[rid][addr];
		UserGlobal storage userGlobal = userMapping[addr];
		if (isWhitelist(msg.sender)) {
			if (now.sub(user.lastRwTime) <= 23 hours.add(58 minutes) || user.id == 0 || userGlobal.id == 0 || userGlobal.status == 4) {
				return;
			}
		} else {
		    require(userGlobal.status != 4,"invalid status");
			require(user.id > 0, "Users of the game are not betting in this round");
			require(now.sub(user.lastRwTime) >= 23 hours.add(58 minutes), "Can only be extracted once in 24 hours");
		}
		user.lastRwTime = now;
		if (userGlobal.status == 1) {
			return;
		}
		uint awardSend = 0;
		uint scale = UtilELG.getSc(user.level);
		uint freezeAmount = user.freezeAmount;
		if (user.freezeAmount >= 1 ether && user.freezeAmount <= bonuslimit) {
			if ((user.userType == 1 && user.investTimes < 5) || user.userType == 2) {
				awardSend = awardSend.add(user.dayBonAmount.mul(awRate).div(100));
				user.bonusAmount = user.bonusAmount.add(awardSend);
				if (user.userType == 1) {
					user.investTimes = user.investTimes.add(1);
				}
			}
			if (user.userType == 1 && user.investTimes >= 5) {
			    if(user.freezeAmount >= 11 ether){
        		    reduce(user.beCode);
    	       }
				user.freeAmount = user.freeAmount.add(user.freezeAmount);
				user.freezeAmount = 0;
				user.dayBonAmount = 0;
				user.level = 0;
				user.userType = 0;
				user.staticTims +=1;
			}
		}
		if (awardSend == 0) {
			return;
		}
		if (user.dayInvAmount > 0) {
			awardSend = awardSend.add(user.dayInvAmount.mul(awRate).div(100));
			user.inviteAmonut = user.inviteAmonut.add(user.dayInvAmount.mul(awRate).div(100));
		}
		if (awardSend > 0 && awardSend <= sendLimit) {
			bool isOut = false;
			uint resultSend = 0;
			(isOut, resultSend) = raid(addr, awardSend);
			if (user.dayInvAmount > 0) {
				user.dayInvAmount = 0;
			}
			user.fValue = user.fValue.add(resultSend);
			if (resultSend > 0) {
				if (!isOut) {
					user.allAward = user.allAward.add(awardSend);
				}
				if(userGlobal.status == 0) {
					rash(user.beCode, freezeAmount, scale);
				}
			}
		}
	}
	
	function avial() external{
	    require(isGameStarted(), "game not start");
		User storage user = userRoundMapping[rid][msg.sender];
		UserGlobal storage userGlobal = userMapping[msg.sender];
		require(userGlobal.status != 4,"invalid status");
	    if(user.fValue > 0 && user.fValue <= sendLimit){
	        uint result = isEnoughBalance(user.fValue);
	        if(result > 0 && result <= sendLimit){
	            sendToAddr(result, msg.sender);
	            user.fValue = 0;
	        }
	    }
	}
	
	function reduce(string memory beCode) private{
	    address cAddr = addressMapping[beCode];
		User storage cUser = userRoundMapping[rid][cAddr];
		if (cUser.id != 0 && cUser.bnTH >= 1) {
			cUser.bnTH -= 1;
		}
	}

	function rash(string memory beCode, uint money, uint shareSc) private {
		string memory tmpCode = beCode;
		for (uint i = 1; i <= 20; i++) {
			if (UtilELG.compareStr(tmpCode, "")) {
				break;
			}
			address tmpAddr = addressMapping[tmpCode];
			UserGlobal storage userGlobal = userMapping[tmpAddr];
			User storage calUser = userRoundMapping[rid][tmpAddr];

			if (userGlobal.status == 1 || userGlobal.status == 2 || calUser.freezeAmount == 0 || calUser.userType != 2) {
				tmpCode = userGlobal.beCode;
				continue;
			}
			uint fireSc = UtilELG.getFire(calUser.level);
			uint recommendSc = UtilELG.recomSc(getUserLevel(calUser.level,calUser.bnTH), i);
			uint result = 0;
			if (money <= calUser.freezeAmount) {
				result = money;
			} else {
				result = calUser.freezeAmount;
			}
			if (recommendSc != 0) {
				uint tmpWad = result.mul(shareSc).mul(recommendSc).mul(fireSc);
				tmpWad = tmpWad.div(1000).div(100).div(10);
				calUser.dayInvAmount = calUser.dayInvAmount.add(tmpWad);
			}
			tmpCode = userGlobal.beCode;
		}
	}

	function getUserLevel(uint level,uint count) private pure returns (uint) {
		if (count >= 10) {
			return 7;
		}
		if (count >= 5) {
			return 6;
		}
		if (count >= 3) {
			return 5;
		}
		return level;
	}

	function raid(address _addr, uint sendMoney) private returns (bool isOut, uint resultSend) {
		User storage user = userRoundMapping[rid][_addr];
		if (user.userType == 1 || user.userType == 0) {
			return (false, sendMoney);
		}
		uint resultAmount = user.freezeAmount.mul(UtilELG.getEndTims(user.freezeAmount)).div(10);
		if (user.allAward.add(sendMoney) >= resultAmount) {
			isOut = true;
			if (resultAmount <= user.allAward) {
				resultSend = 0;
			} else {
				resultSend = resultAmount.sub(user.allAward);
			}
			if(user.freezeAmount >= 11 ether){
        		reduce(user.beCode);
    	    }
			user.dayBonAmount = 0;
			user.level = 0;
			user.freezeAmount = 0;
			user.allAward = 0;
			user.userType = 0;
			user.dayInvAmount = 0;
			user.staticTims += 1;
		} else {
			resultSend = sendMoney;
		}
		return (isOut, resultSend);
	}

	function sendToAddr(uint value, address addr) private {
		uint result = isEnoughBalance(value);
		if (result > 0 && result <= sendLimit) {
			address payable sendAddr = address(uint160(addr));
			sendMoneyToUser(sendAddr, result);
		}
	}

	function isEnoughBalance(uint value) private view returns (uint) {
		if (address(this).balance >= value) {
			return value;
		} else {
			return address(this).balance;
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

	function paineBluff(address addr, uint roundId) public view returns (uint[19] memory info, string memory inviteCode, string memory beCode,uint status) {
		require(isWhitelist(msg.sender) || msg.sender == addr, "Permission denied for view user's privacy");

		if (roundId == 0) {
			roundId = rid;
		}

		UserGlobal memory userGlobal = userMapping[addr];
		User memory user = userRoundMapping[roundId][addr];
		info[0] = userGlobal.id;
		info[1] = user.freezeAmount;
		info[2] = user.inviteAmonut;
		info[3] = user.bonusAmount;
		info[4] = user.dayBonAmount.mul(awRate).div(100);
		info[5] = user.level;
		info[6] = user.dayInvAmount.mul(awRate).div(100);
		info[7] = user.lastRwTime;
		info[8] = userGlobal.status;
		info[9] = user.allAward;
		info[10] = user.userType;
		info[11] = user.shareAmount;
		info[12] = user.freeAmount;
		info[13] = user.bn;
		info[14] = user.investTimes;
		info[15] = user.resTime;
		info[16] = user.staticTims;
	    info[17] = user.fValue;
	    info[18] = user.bnTH;
		return (info, userGlobal.inviteCode, userGlobal.beCode,userGlobal.status);
	}

	function ventura(uint amount) private {
		devAddr.transfer(amount.div(10));
		reAddr.transfer(amount.div(100));
	}

	function sendMoneyToUser(address payable addr, uint money) private {
		if (money > 0) {
			addr.transfer(money);
		}
	}

	function isUsed(string memory code) public view returns (bool) {
		address addr = addressMapping[code];
		return uint(addr) != 0;
	}

	function getUserAddressByCode(string memory code) public view returns (address) {
		require(isWhitelist(msg.sender), "Permission denied");
		return addressMapping[code];
	}

	function registerUser(address addr, string memory inviteCode, string memory beCode,uint status) private {
		UserGlobal storage userGlobal = userMapping[addr];
		uid++;
		userGlobal.id = uid;
		userGlobal.userAddress = addr;
		userGlobal.inviteCode = inviteCode;
		userGlobal.beCode = beCode;
        userGlobal.status = status;
		addressMapping[inviteCode] = addr;
		indexMapping[uid] = addr;
	}

	function endRound() external isFigure {
		require(address(this).balance < 1 ether, "contract balance must be lower than 1 ether");
		rid++;
		startTime = now.add(period).div(1 days).mul(1 days);
		canSetStartTime = 1;
	}

	function getUserAddressById(uint id) public view returns (address) {
		require(isWhitelist(msg.sender));
		return indexMapping[id];
	}
}

library UtilELG {
    /* https://elgame.cc */
	function getLevel(uint value) public pure  returns (uint) {
		if (value >= 1 ether && value <= 5 ether) {
			return 1;
		}
		if (value >= 6 ether && value <= 10 ether) {
			return 2;
		}
		if (value >= 11 ether && value <= 15 ether) {
			return 3;
		}
		if (value >= 16 ether && value <= 30 ether) {
			return 4;
		}
		return 0;
	}

	function getSc(uint level) public pure  returns (uint) {
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

	function getFire(uint level) public pure  returns (uint) {
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

	function recomSc(uint level, uint times) public pure returns (uint) {
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

	function getEndTims(uint value) public pure  returns (uint) {
		if (value >= 1 ether && value <= 5 ether) {
			return 15;
		}
		if (value >= 6 ether && value <= 10 ether) {
			return 20;
		}
		if (value >= 11 ether && value <= 15 ether) {
			return 25;
		}
		if (value >= 16 ether && value <= 30 ether) {
			return 30;
		}
		return 0;
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