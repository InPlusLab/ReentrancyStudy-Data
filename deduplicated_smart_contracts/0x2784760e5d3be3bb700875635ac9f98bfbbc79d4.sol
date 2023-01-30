/**
 * Note for the truffle testversion:
 * DragonKingTest inherits from DragonKing and adds one more function for testing the volcano from truffle.
 * For deployment on ropsten or mainnet, just deploy the DragonKing contract and remove this comment before verifying on
 * etherscan.
 * */

 /**
  * Dragonking is a blockchain game in which players may purchase dragons and knights of different levels and values.
  * Once every period of time the volcano erupts and wipes a few of them from the board. The value of the killed characters
  * gets distributed amongst all of the survivors. The dragon king receive a bigger share than the others.
  * In contrast to dragons, knights need to be teleported to the battlefield first with the use of teleport tokens.
  * Additionally, they may attack a dragon once per period.
  * Both character types can be protected from death up to three times.
  * Take a look at dragonking.io for more detailed information.
  * @author: Julia Altenried, Yuriy Kashnikov
  * */

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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract mortal is Ownable{

	function mortal() public {
	}

	function kill() internal {
		selfdestruct(owner);
	}
}


contract Token {
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
}

contract DragonKing is mortal {

	struct Character {
		uint8 characterType;
		uint128 value;
		address owner;
	}

	/** array holding ids of the curret characters*/
	uint32[] public ids;
	/** the id to be given to the next character **/
	uint32 public nextId;
	/** the id of the oldest character */
	uint32 public oldest;
	/** the character belonging to a given id */
	mapping(uint32 => Character) characters;
	/** teleported knights **/
	mapping(uint32 => bool) teleported;
	/** the cost of each character type */
	uint128[] public costs;
	/** the value of each character type (cost - fee), so it's not necessary to compute it each time*/
	uint128[] public values;
	/** the fee to be paid each time an character is bought in percent*/
	uint8 fee;
	/** the number of dragon types **/
	uint8 constant public numDragonTypes = 6;


	/** total number of characters in the game  */
	uint16 public numCharacters;
	/** The maximum of characters allowed in the game */
	uint16 public maxCharacters;
	/** number of characters per type */
	mapping(uint8 => uint16) public numCharactersXType;


	/** the amount of time that should pass since last eruption **/
	uint8 public eruptionThreshold;
	/** timestampt of the last eruption event **/
	uint256 public lastEruptionTimestamp;
	/** how many characters to kill in %, e.g. 20 will stand for 20%, should be < 100 **/
	uint8 public percentageToKill;

	/** knight cooldown. contains the timestamp of the earliest possible moment to start a fight */
	mapping(uint32 => uint) public cooldown;
	uint256 public constant CooldownThreshold = 1 days;

	/** the teleport token contract used to send knights to the game scene */
	Token teleportToken;
	/** the price for teleportation*/
	uint public teleportPrice;
	/** the neverdue token contract used to purchase protection from eruptions and fights */
	Token neverdieToken;
	/** the price for protection */
	uint public protectionPrice;
	/** tells the number of times a character is protected */
	mapping(uint32 => uint8) public protection;

	// MODIFIER

	/** is fired when new characters are purchased (who bought how many characters of which type?) */
	event NewPurchase(address player, uint8 characterType, uint8 amount, uint32 startId);
	/** is fired when a player leaves the game */
	event NewExit(address player, uint256 totalBalance, uint32[] removedCharacters);
	/** is fired when an eruption occurs */
	event NewEruption(uint32[] hitCharacters, uint128 value, uint128 gasCost);
	/** is fired when a single character is sold **/
	event NewSell(uint32 characterId, address player, uint256 value);
	/** is fired when a knight fights a dragon **/
	event NewFight(uint32 winnerID, uint32 loserID, uint256 value);
	/** is fired when a knight is teleported to the field **/
	event NewTeleport(uint32 characterId);
	/** is fired when a protection is purchased **/
	event NewProtection(uint32 characterId, uint8 lifes);

	/** initializes the contract parameters	 */
	function DragonKing(address teleportTokenAddress, address neverdieTokenAddress, uint8 eruptionThresholdInHours, uint8 percentageOfCharactersToKill, uint8 characterFee, uint16[] charactersCosts) public onlyOwner {
		fee = characterFee;
		for (uint8 i = 0; i < charactersCosts.length * 2; i++) {
			costs.push(uint128(charactersCosts[i % numDragonTypes]) * 1 finney);
			values.push(costs[i] - costs[i] / 100 * fee);
		}
		eruptionThreshold = eruptionThresholdInHours * 60 * 60; // convert to seconds
		percentageToKill = percentageOfCharactersToKill;
		maxCharacters = 600;
		nextId = 1;
		teleportToken = Token(teleportTokenAddress);
		teleportPrice = 1;
		neverdieToken = Token(neverdieTokenAddress);
		protectionPrice = 1;
	}

	/**
	 * buys as many characters as possible with the transfered value of the given type
	 * @param characterType the type of the character
	 */
	function addCharacters(uint8 characterType) payable public {
		uint8 amount = uint8(msg.value / costs[characterType]);
		uint16 nchars = numCharacters;
		if (characterType >= costs.length || msg.value < costs[characterType] || nchars + amount > maxCharacters) revert();
		//if type exists, enough ether was transferred and there are less than maxCharacters characters in the game
		bool isDragon = characterType < numDragonTypes;
		uint32 nid = nextId;
		if (isDragon) {
			//dragons enter the game directly
			for (uint8 i = 0; i < amount; i++) {
				addCharacter(nid + i, nchars + i);
				characters[nid + i] = Character(characterType, values[characterType], msg.sender);
			}
			numCharactersXType[characterType] += amount;
			numCharacters += amount;
		}
		else {
			for (uint8 j = 0; j < amount; j++) {
				characters[nid + j] = Character(characterType, values[characterType], msg.sender);
			}
		}
		nextId = nid + amount;
		NewPurchase(msg.sender, characterType, amount, nid);
	}



	/**
	 * adds a single dragon of the given type to the ids array, which is used to iterate over all characters
	 * @param nId the id the character is about to receive
	 * @param nchars the number of characters currently in the game
	 */
	function addCharacter(uint32 nId, uint16 nchars) internal {
		if (nchars < ids.length)
			ids[nchars] = nId;
		else
			ids.push(nId);
	}

	/**
	 * leave the game.
	 * pays out the sender's balance and removes him and his characters from the game
	 * */
	function exit() public {
		uint32[] memory removed = new uint32[](50);
		uint8 count;
		uint32 lastId;
		uint playerBalance;
		uint16 nchars = numCharacters;
		for (uint16 i = 0; i < nchars; i++) {
			if (characters[ids[i]].owner == msg.sender) {
				//first delete all characters at the end of the array
				while (nchars > 0 && characters[ids[nchars - 1]].owner == msg.sender) {
					nchars--;
					lastId = ids[nchars];
					numCharactersXType[characters[lastId].characterType]--;
					playerBalance += characters[lastId].value;
					removed[count] = lastId;
					count++;
					if (lastId == oldest) oldest = 0;
					delete characters[lastId];
				}
				//if the last character does not belong to the player, replace the players character by this last one
				if (nchars > i + 1) {
					playerBalance += characters[ids[i]].value;
					removed[count] = ids[i];
					count++;
					nchars--;
					replaceCharacter(i, nchars);
				}
			}
		}
		numCharacters = nchars;
		NewExit(msg.sender, playerBalance, removed); //fire the event to notify the client
		msg.sender.transfer(playerBalance);
	}

	/**
	 * Replaces the character with the given id with the last character in the array
	 * @param index the index of the character in the id array
	 * @param nchars the number of characters
	 * */
	function replaceCharacter(uint16 index, uint16 nchars) internal {
		uint32 characterId = ids[index];
		numCharactersXType[characters[characterId].characterType]--;
		if (characterId == oldest) oldest = 0;
		delete characters[characterId];
		ids[index] = ids[nchars];
		delete ids[nchars];
	}

	/**
	 * The volcano eruption can be triggered by anybody but only if enough time has passed since the last eription.
	 * The volcano hits up to a certain percentage of characters, but at least one.
	 * The percantage is specified in 'percentageToKill'
	 * */

	function triggerVolcanoEruption() public {
		require(now >= lastEruptionTimestamp + eruptionThreshold);
		require(numCharacters>0);
		lastEruptionTimestamp = now;
		uint128 pot;
		uint128 value;
		uint16 random;
		uint32 nextHitId;
		uint16 nchars = numCharacters;
		uint32 howmany = nchars * percentageToKill / 100;
		uint128 neededGas = 80000 + 10000 * uint32(nchars);
		if(howmany == 0) howmany = 1;//hit at least 1
		uint32[] memory hitCharacters = new uint32[](howmany);
		for (uint8 i = 0; i < howmany; i++) {
			random = uint16(generateRandomNumber(lastEruptionTimestamp + i) % nchars);
			nextHitId = ids[random];
			hitCharacters[i] = nextHitId;
			value = hitCharacter(random, nchars);
			if (value > 0) {
				nchars--;
			}
			pot += value;
		}
		uint128 gasCost = uint128(neededGas * tx.gasprice);
		numCharacters = nchars;
		if (pot > gasCost){
			distribute(pot - gasCost); //distribute the pot minus the oraclize gas costs
			NewEruption(hitCharacters, pot - gasCost, gasCost);
		}
		else
			NewEruption(hitCharacters, 0, gasCost);
	}


	/**
	 * A knight may attack a dragon, but not choose which one.
	 * The creature with the higher level wins. The level is determined by characterType % numDragonTypes.
	 * The value of the loser is transfered to the winner. In case of a the same level, the winner is chosen randomly.
	 * @param knightID the ID of the knight to perfrom the attack
	 * @param knightIndex the index of the knight in the ids-array. Just needed to save gas costs.
	 *					  In case it's unknown or incorrect, the index is looked up in the array.
	 * */
	function fight(uint32 knightID, uint16 knightIndex) public {
		if (knightID != ids[knightIndex])
			knightID = getCharacterIndex(knightID);
		Character storage knight = characters[knightID];
		require(cooldown[knightID] + CooldownThreshold <= now);
		require(knight.owner == msg.sender);
		require(knight.characterType >= numDragonTypes);
		uint16 dragonIndex = getRandomDragon(knightID);
		assert(dragonIndex < maxCharacters);
		uint32 dragonID = ids[dragonIndex];
		Character storage dragon = characters[dragonID];
		uint16 tieBreaker = uint16(now % 2);
		uint128 value;
		if (knight.characterType - numDragonTypes > dragon.characterType || (knight.characterType - numDragonTypes == dragon.characterType && tieBreaker == 0)) {
			value = hitCharacter(dragonIndex, numCharacters);
			if (value > 0) {
				numCharacters--;
			}
			knight.value += value;
			cooldown[knightID] = now;
			if (oldest == 0) findOldest();
			NewFight(knightID, dragonID, value);
		}
		else {
			value = hitCharacter(knightIndex, numCharacters);
			if (value > 0) {
				numCharacters--;
			}
			dragon.value += value;
			NewFight(dragonID, knightID, value);
		}
	}

	/**
	 * pick a random dragon.
	 * @param nonce a nonce to make sure there's not always the same dragon chosen in a single block.
	 * @return the index of a random dragon
	 * */
	function getRandomDragon(uint256 nonce) internal view returns(uint16) {
		uint16 randomIndex = uint16(generateRandomNumber(nonce) % numCharacters);
		//use 7, 11 or 13 as step size. scales for up to 1000 characters
		uint16 stepSize = numCharacters % 7 == 0 ? (numCharacters % 11 == 0 ? 13 : 11) : 7;
		uint16 i = randomIndex;
		//if the picked character is a knight or belongs to the sender, look at the character + stepSizes ahead in the array (modulo the total number)
		//will at some point return to the startingPoint if no character is suited
		do {
			if (characters[ids[i]].characterType < numDragonTypes && characters[ids[i]].owner != msg.sender) return i;
			i = (i + stepSize) % numCharacters;
		} while (i != randomIndex);
		return maxCharacters + 1; //there is none
	}

	/**
	 * generate a random number.
	 * @param nonce a nonce to make sure there's not always the same number returned in a single block.
	 * @return the random number
	 * */
	function generateRandomNumber(uint256 nonce) internal view returns(uint) {
		return uint(keccak256(block.blockhash(block.number - 1), now, numCharacters, nonce));
	}

	/**
	 * Hits the character of the given type at the given index.
	 * @param index the index of the character
	 * @param nchars the number of characters
	 * @return the value gained from hitting the characters (zero is the character was protected)
	 * */
	function hitCharacter(uint16 index, uint16 nchars) internal returns(uint128 characterValue) {
		uint32 id = ids[index];
		if (protection[id] > 0) {
			protection[id]--;
			return 0;
		}
		characterValue = characters[ids[index]].value;
		nchars--;
		replaceCharacter(index, nchars);
	}

	/**
	 * finds the oldest character
	 * */
	function findOldest() public {
		oldest = ids[0];
		for (uint16 i = 1; i < numCharacters; i++) {
			if (ids[i] < oldest && characters[ids[i]].characterType < numDragonTypes) //the oldest character has the lowest id -todo
				oldest = ids[i];
		}
	}

	/**
	* distributes the given amount among the surviving characters
	* @param totalAmount nthe amount to distribute
	*/
	function distribute(uint128 totalAmount) internal {
		//pay 10% to the oldest dragon
		if (oldest == 0)
			findOldest();
		characters[oldest].value += totalAmount / 10;
		uint128 amount = totalAmount / 10 * 9;
		//distribute the rest according to their type
		uint128 valueSum;
		uint128[] memory shares = new uint128[](values.length);
		for (uint8 v = 0; v < values.length; v++) {
			if (numCharactersXType[v] > 0) valueSum += values[v];
		}
		for (uint8 m = 0; m < values.length; m++) {
			if (numCharactersXType[m] > 0)
				shares[m] = amount * values[m] / valueSum / numCharactersXType[m];
		}
		for (uint16 i = 0; i < numCharacters; i++) {
			characters[ids[i]].value += shares[characters[ids[i]].characterType];
		}
	}

	/**
	 * allows the owner to collect the accumulated fees
	 * sends the given amount to the owner's address if the amount does not exceed the
	 * fees (cannot touch the players' balances) minus 100 finney (ensure that oraclize fees can be paid)
	 * @param amount the amount to be collected
	 * */
	function collectFees(uint128 amount) public onlyOwner {
		uint collectedFees = getFees();
		if (amount + 100 finney < collectedFees) {
			owner.transfer(amount);
		}
	}

	/**
	 * pays out the players and kills the game.
	 * */
	function stop() public onlyOwner {
		for (uint16 i = 0; i < numCharacters; i++) {
			if (!characters[ids[i]].owner.send(characters[ids[i]].value)) revert();
		}
		kill();
	}

	/**
	 * sell the character of the given id
	 * throws an exception in case of a knight not yet teleported to the game
	 * @param characterId the id of the character
	 * */
	function sellCharacter(uint32 characterId) public {
		require(msg.sender == characters[characterId].owner);
		uint128 val = characters[characterId].value;
		numCharacters--;
		replaceCharacter(getCharacterIndex(characterId), numCharacters);
		msg.sender.transfer(val);
		NewSell(characterId, msg.sender, val);
	}

	/**
	 * receive approval to spend some tokens.
	 * used for teleport and protection.
	 * @param sender the sender address
	 * @param value the transferred value
	 * @param tokenContract the address of the token contract
	 * @param callData the data passed by the token contract
	 * */
	function receiveApproval(address sender, uint256 value, address tokenContract, bytes callData) public {
		if (msg.sender == address(teleportToken)) {
			require(value >= teleportPrice);
			assert(teleportToken.transferFrom(sender, this, teleportPrice));
			teleportKnight(toUint32(callData));
		}
		else if (msg.sender == address(neverdieToken)) {
			uint32 id = toUint32(callData);
			// user can purchase extra lifes only right after character purchaes
			// in other words, user value should be equal the initial value
			require(characters[id].value == values[characters[id].characterType]);

			// calc how many lifes user can actually buy
			// the formula is the following:
			uint256 lifePrice = ((characters[id].characterType % numDragonTypes) + 1) * protectionPrice;
			uint256 price = 0;
			uint8 i = protection[id];
			require(i <= 3);
			for (i; i < 3 && value >= price + lifePrice * (i + 1); i++) {
				price += lifePrice * (i + 1);
			}
			assert(neverdieToken.transferFrom(sender, this, price));
			protectCharacter(id, i);
		}
		else
			revert();
	}

	/**
	 * knights are only entering the game completely, when they are teleported to the scene
	 * @param id the character id
	 * */
	function teleportKnight(uint32 id) internal {
		// ensure we do not teleport twice
		require(teleported[id] == false);
		teleported[id] = true;
		Character storage knight = characters[id];
		assert(knight.characterType >= numDragonTypes); //this also makes calls with non-existent ids fail
		addCharacter(id, numCharacters);
		numCharacters++;
		numCharactersXType[knight.characterType]++;
		NewTeleport(id);
	}

	/**
	 * adds protection to a character
	 * @param id the character id
	 * @param lifes the number of protections
	 * */
	function protectCharacter(uint32 id, uint8 lifes) internal {
		protection[id] = lifes;
		NewProtection(id, lifes);
	}


	/****************** GETTERS *************************/

	/**
	 * returns the character of the given id
	 * @param characterId the character id
	 * @return the type, value and owner of the character
	 * */
	function getCharacter(uint32 characterId) constant public returns(uint8, uint128, address) {
		return (characters[characterId].characterType, characters[characterId].value, characters[characterId].owner);
	}

	/**
	 * returns the index of a character of the given id
	 * @param characterId the character id
	 * @return the character id
	 * */
	function getCharacterIndex(uint32 characterId) constant public returns(uint16) {
		for (uint16 i = 0; i < ids.length; i++) {
			if (ids[i] == characterId) {
				return i;
			}
		}
		revert();
	}

	/**
	 * returns 10 characters starting from a certain indey
	 * @param startIndex the index to start from
	 * @return 4 arrays containing the ids, types, values and owners of the characters
	 * */
	function get10Characters(uint16 startIndex) constant public returns(uint32[10] characterIds, uint8[10] types, uint128[10] values, address[10] owners) {
		uint32 endIndex = startIndex + 10 > numCharacters ? numCharacters : startIndex + 10;
		uint8 j = 0;
		uint32 id;
		for (uint16 i = startIndex; i < endIndex; i++) {
			id = ids[i];
			characterIds[j] = id;
			types[j] = characters[id].characterType;
			values[j] = characters[id].value;
			owners[j] = characters[id].owner;
			j++;
		}

	}

	/**
	 * returns the number of dragons in the game
	 * @return the number of dragons
	 * */
	function getNumDragons() constant public returns(uint16 numDragons) {
		for (uint8 i = 0; i < numDragonTypes; i++)
			numDragons += numCharactersXType[i];
	}

	/**
	 * returns the number of knights in the game
	 * @return the number of knights
	 * */
	function getNumKnights() constant public returns(uint16 numKnights) {
		for (uint8 i = numDragonTypes; i < costs.length; i++)
			numKnights += numCharactersXType[i];
	}

	/**
	 * @return the accumulated fees
	 * */
	function getFees() constant public returns(uint) {
		uint reserved = 0;
		for (uint16 j = 0; j < numCharacters; j++)
			reserved += characters[ids[j]].value;
		return address(this).balance - reserved;
	}


	/****************** SETTERS *************************/

	/**
	 * sets the prices of the character types
	 * @param prices the prices in finney
	 * */
	function setPrices(uint16[] prices) public onlyOwner {
		for (uint8 i = 0; i < prices.length * 2; i++) {
			costs[i] = uint128(prices[i % numDragonTypes]) * 1 finney;
			values[i] = costs[i] - costs[i] / 100 * fee;
		}
	}

	/**
	 * sets the fee to charge on each purchase
	 * @param _fee the new fee
	 * */
	function setFee(uint8 _fee) public onlyOwner {
		fee = _fee;
	}

	/**
	 * sets the maximum number of characters allowed in the game
	 * @param number the new maximum
	 * */
	function setMaxCharacters(uint16 number) public onlyOwner {
		maxCharacters = number;
	}

	/**
	 * sets the teleport price
	 * @param price the price in tokens
	 * */
	function setTeleportPrice(uint price) public onlyOwner {
		teleportPrice = price;
	}

	/**
	 * sets the protection price
	 * @param price the price in tokens
	 * */
	function setProtectionPrice(uint price) public onlyOwner {
		protectionPrice = price;
	}


	/************* HELPERS ****************/

	/**
	 * only works for bytes of length < 32
	 * @param b the byte input
	 * @return the uint
	 * */
	function toUint32(bytes b) internal pure returns(uint32) {
		bytes32 newB;
		assembly {
			newB: = mload(0x80)
		}
		return uint32(newB);
	}

}