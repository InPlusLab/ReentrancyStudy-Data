/**

 *Submitted for verification at Etherscan.io on 2019-05-15

*/



pragma solidity ^0.4.26;



contract SafeMath {

    // Overflow protected math functions



    /**

        @dev returns the sum of _x and _y, asserts if the calculation overflows



        @param _x   value 1

        @param _y   value 2



        @return sum

    */

    function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x + _y;

        require(z >= _x);        //assert(z >= _x);

        return z;

    }



    /**

        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number



        @param _x   minuend

        @param _y   subtrahend



        @return difference

    */

    function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_x >= _y);        //assert(_x >= _y);

        return _x - _y;

    }



    /**

        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows



        @param _x   factor 1

        @param _y   factor 2



        @return product

    */

    function safeMul(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x * _y;

        require(_x == 0 || z / _x == _y);        //assert(_x == 0 || z / _x == _y);

        return z;

    }

	

	function safeDiv(uint256 _x, uint256 _y)internal pure returns (uint256){

	    // assert(b > 0); // Solidity automatically throws when dividing by 0

        // uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return _x / _y;

	}

	

	function ceilDiv(uint256 _x, uint256 _y)internal pure returns (uint256){

		return (_x + _y - 1) / _y;

	}

}





contract Sqrt {

	function sqrt(uint x)public pure returns(uint y) {

        uint z = (x + 1) / 2;

        y = x;

        while (z < y) {

            y = z;

            z = (x / z + z) / 2;

        }

    }

}



contract ERC20Token {

	mapping (address => uint256) balances;

	address public owner;

    string public name;

    string public symbol;

    uint8 public decimals = 18;

	// total amount of tokens

    uint256 public totalSupply;

	// `allowed` tracks any extra transfer rights as in all ERC20 tokens

    mapping (address => mapping (address => uint256)) allowed;



    constructor() public {

        uint256 initialSupply = 10000000000;

        totalSupply = initialSupply * 10 ** uint256(decimals);

        balances[msg.sender] = totalSupply;

        name = "Game Chain";

        symbol = "GMI";

    }

	

    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) public constant returns (uint256 balance) {

		 return balances[_owner];

	}



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) public returns (bool success) {

	    require(_value > 0 );                                      // Check send token value > 0;

		require(balances[msg.sender] >= _value);                   // Check if the sender has enough

        require(balances[_to] + _value > balances[_to]);           // Check for overflows											

		balances[msg.sender] -= _value;                            // Subtract from the sender

		balances[_to] += _value;                                   // Add the same to the recipient                       

		 

		emit Transfer(msg.sender, _to, _value); 			       // Notify anyone listening that this transfer took place

		return true;      

	}



    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

	  

	    require(balances[_from] >= _value);                 // Check if the sender has enough

        require(balances[_to] + _value >= balances[_to]);   // Check for overflows

        require(_value <= allowed[_from][msg.sender]);      // Check allowance

        balances[_from] -= _value;                         // Subtract from the sender

        balances[_to] += _value;                           // Add the same to the recipient

        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;

	}



    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of tokens to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) public returns (bool success) {

		require(balances[msg.sender] >= _value);

		allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

		return true;

	

	}

	

    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];

	}

	

	/* This unnamed function is called whenever someone tries to send ether to it */

    function () private {

        revert();     // Prevents accidental sending of ether

    }



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract UnlockGmi is SafeMath{

    

//    using SafeMath for *;

	

	//list user

	mapping (address => uint256) private lockList;                         

    bool            private             activated_;                                             // mark contract is activated;

    uint256         private             activatedTime;

	

	ERC20Token      private             gmiToken;

    

	mapping (address => uint256)  private takenTime;

	mapping (address => uint256)  private takenAmount;

	

	uint64          private             timeInterval;

	uint64          private             unLockedAmount;

	address         public              owner_;

	



//==============================================================================

//     _ _  _  __|_ _    __|_ _  _  .

//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)

//==============================================================================

    // constructor(address gmiTokeAddress) public {

    //     gmiToken = ERC20Token(gmiTokeAddress);

    //     timeInterval = 60 * 60 * 24;

    //     unLockedAmount = 200;

    //     initialize();

    //     owner_ = msg.sender;

    // }

    constructor() public {

        gmiToken = ERC20Token(0x03B267325193FD0c15cA0D2A693e54213C2AfCB6);

        timeInterval = 60 * 60 * 24;

        unLockedAmount = 200;

        initialize();

        owner_ = msg.sender;

    }

	

	function initialize() private {

		lockList[0x2fED4396Ee204a448201fAB980f1C90018e22801] = 302122  * 10 ** 18; 

        lockList[0x3cC8291F32a07aC9D0D9887eEc7331bD273c613B] = 1142882 * 10 ** 18;

        lockList[0xef6607FafE4406dD1698865aC89BcBc22323e853] = 139708  * 10 ** 18;

        lockList[0x1b15FD6FeaecC11B44D689b7B1C2471207a26a23] = 116678  * 10 ** 18;

        lockList[0xe813fe32aBd2f47c5010426d259e2372e526021C] = 103784  * 10 ** 18;

        lockList[0x253f9FAb9dCB4a64ceF5b3320eB9F28163924DF9] = 71770   * 10 ** 18;

        lockList[0x3aa9230bF5deD1c72aa4083B6137ADC7955B5a1a] = 114020  * 10 ** 18;

        lockList[0xe37079253aDa30eeF49f65EFd48608A4C15F614D] = 503303  * 10 ** 18;

        lockList[0x89Ad15DfCDe37dCF1C7C8582d8ff7F195796EB7B] = 164803  * 10 ** 18;

        lockList[0xD063C6f99F221Df40D1F15A1d5D6a477573f8092] = 31460   * 10 ** 18;

        lockList[0x8Ef20D2388606Fd4E6ef0f0f070a63c5c655626c] = 681715  * 10 ** 18;

        lockList[0x632A8a687C5c99556117650641B3ACB299ba070f] = 458888  * 10 ** 18;

        lockList[0x8901A17d3964214D501F9C8B015854d037d90fEf] = 831815  * 10 ** 18;

        lockList[0xDF5662248182270da3b7582d303CFb2d5E62ec23] = 603573  * 10 ** 18;

        lockList[0x1f5a6da1dfd6645eb4f3afc0d4e457aac95c8776] = 1014032 * 10 ** 18;

        lockList[0xb1FA3A4c4CEEc881Ec3B4f50afa4d40a20353385] = 339020  * 10 ** 18;

        lockList[0x7F3D90153259c49887d55E906af3336c38F814A9] = 421571  * 10 ** 18;

        lockList[0x9c6fc8Eb31B67Cc9452c96B77DdCb5EF504CDa81] = 119204  * 10 ** 18;

        lockList[0xD9c1F9347785dc2E79477E20E7d5e5b7866deF35] = 178954  * 10 ** 18;

        lockList[0xa4FEf4Cc6f63E5Ea0A2F3044EA84b9a1EACeAE5e] = 139148  * 10 ** 18;

        lockList[0x3Ae9e2E7fEA9031eE85facbBc26794b079b3dCd9] = 1940127 * 10 ** 18;

        lockList[0x901AD29A0e95647525137E2af782C517375D37C4] = 4750115 * 10 ** 18;

        lockList[0xbff165E4549bfcea5F150FC5ee04cC8dA4dCAe5d] = 59902   * 10 ** 18;

        lockList[0x09c09b03563B6Be9104Da38890468C0D9A98C691] = 2729048 * 10 ** 18;

        lockList[0x400D5Fd9A30C3f524931F82C687cacB6C4054F41] = 610952  * 10 ** 18;

        lockList[0x054C0a11804Ad1116290CF14EE23Ad59F3d0925e] = 376660  * 10 ** 18;

        lockList[0xB80ab7AAb74731243fE13d5c6Eb87223CfaDA59b] = 73479   * 10 ** 18;

        lockList[0xb1DbcBd1705938546e1eBa520332B4c164878965] = 68520   * 10 ** 18;

        lockList[0x4e961A68d3dafff6D4d863d21fba6Fff82b25d5c] = 10000   * 10 ** 18;

        lockList[0x097515d2570baBbDa32e5caF23a765e574cDc6B1] = 50683   * 10 ** 18;

        lockList[0xb2aCA30Ae71d146aad0422a141e3eF0B9313A4bc] = 25158   * 10 ** 18;

        lockList[0x8Ab96a4778BB5b7E6839059D2988e846A749E9ED] = 67043   * 10 ** 18;

        lockList[0x7e5177Bd22D9e64AfEBD4F06DdD4C6F6bFccc548] = 113495  * 10 ** 18;

        lockList[0xd3A8bBBc7eeAF8422C791A3d046Fa773E972bAe2] = 184614  * 10 ** 18;

        lockList[0x66F9A4b3C09dA25cF14a063647882c31880bcd17] = 37509   * 10 ** 18;

        lockList[0x3409780afa44ede06111b927e25c1fa7ef72cda5] = 185956  * 10 ** 18;

        lockList[0x1F105e0A5126a1282929ff5E4FB1819F2D48a785] = 221487  * 10 ** 18;

        lockList[0x5F86Ff75c7745d40d81F155c9B2D49794F8Dd85E] = 476976  * 10 ** 18;

        lockList[0xDF5662248182270da3b7582d303CFb2d5E62ec23] = 654221  * 10 ** 18;

        lockList[0xAB107D9932f4338538c72fEc7fEd65a7F87Ed24C] = 1863872 * 10 ** 18;

        lockList[0xB3D3403BB64258CFA18C49D28c0E9719eF0A0004] = 192751  * 10 ** 18;

        lockList[0xb1da36EfcBf2ee81178A113c631932AEc9c9ADE9] = 34386   * 10 ** 18;

        lockList[0x8894EdE64044F73d293bD43eaeBf1D6Dbc55B361] = 2368356 * 10 ** 18;

        lockList[0xF7F62c2B263E6C7319322f2A4a76d989404835d6] = 100515  * 10 ** 18;

        lockList[0x5814639DA554762e40745b9F0e2C5d0Ba593E532] = 413704  * 10 ** 18;

        lockList[0xc02918Eb9563dBa6322673C2f18096Dceb5BE71d] = 101500  * 10 ** 18;

        lockList[0x61dBB6fA0d7A85a73Fb3AA4896079eE4011229e5] = 164921  * 10 ** 18;

        lockList[0x30E442ADD9826B52F344D7FAfB8960Df9dbb8f30] = 280178  * 10 ** 18;

        lockList[0xE8B0A0BEc7b2B772858414527C022bfb259FAC71] = 1559993 * 10 ** 18;

        lockList[0x9f8B4fd6B3BbACCa93b79C37Ce1F330a5A81cbB7] = 766709  * 10 ** 18;

        lockList[0x5a98B695Fe35F628DFaEBbBB5493Dc8488FA3275] = 283605  * 10 ** 18;

        lockList[0x23b6E3369bD27C3C4Be5d925c6fa1FCea52283e2] = 143304  * 10 ** 18;

        lockList[0xE8c215194222708C831362D5e181b2Af99c6c384] = 144635  * 10 ** 18;

        lockList[0xfC0aE173522D24326CFfA9D0D0C058565Fd39d2B] = 84228   * 10 ** 18;

        lockList[0x5e08EA6DDD4BF0969B33CAD27D89Fb586F0fC2f1] = 34749   * 10 ** 18;

        lockList[0xE7De0652d437b627AcC466002d1bC8D44bdb156E] = 17809   * 10 ** 18;

        lockList[0xEa4CedE1d23c616404Ac2dcDB3A3C5EaA24Ce38d] = 13263   * 10 ** 18;

        lockList[0x7d97568b1329013A026ED561A0FA542030f7b44B] = 107752  * 10 ** 18;

        lockList[0x0c52d845AB2cB7e4bec52DF6F521603683FA8780] = 36368   * 10 ** 18;

        lockList[0x58d66AC8820fa6f7c18594766519c490d33C6E96] = 292311  * 10 ** 18;

        lockList[0x1554972baa4b0f26bafbfac8872fc461683a64aa] = 74097   * 10 ** 18;

        lockList[0xcCD4513E24C87439173f747625FDBF906AE5428A] = 33718   * 10 ** 18;

        lockList[0xB81f587dEB7Dc1eb1e7372B1BD0E75DeE5804313] = 34711   * 10 ** 18;

        lockList[0xad4e8ae487bf8b6005aa7cb8f3f573752db1ced0] = 62781   * 10 ** 18;

        lockList[0x9e25ade8a3a4f2f1a9e902a3eaa62baee0000c16] = 43912   * 10 ** 18;

        lockList[0xeb019f923bb1Dab5Fd309E342b52950E6A3a5bb5] = 210671  * 10 ** 18;

        lockList[0xf145c1E0dEcE26b8DD0eDbd0D7A1f4a16dBFE238] = 414327  * 10 ** 18;

        lockList[0xf1cfa922da06079ce6ed6c5b6922df0d4b82c76f] = 135962  * 10 ** 18;

        lockList[0x0Fc746A1800BDb4F6308B544e07B46eF4615776E] = 12948   * 10 ** 18;

        lockList[0x448bc2419Fef08eF72a49B125EA8f2312a0Db64C] = 11331   * 10 ** 18;

        lockList[0x6766B4BebcEfa05db1041b80f9C67a00aAe60d2a] = 44260   * 10 ** 18;

        lockList[0xfd1b9d97772661f56cb630262311f345e24078ee] = 116657  * 10 ** 18;

        lockList[0x5149F1A30Bab45e436550De2Aed5C63101CC3c61] = 161098  * 10 ** 18;

        lockList[0xAeA06A4bFc2c60b2CEb3457c56eEb602C72B6C74] = 13499   * 10 ** 18;

        lockList[0xB24969E6CEAE48EfccAb7dB5E56169574A3a13A8] = 62028   * 10 ** 18;

        lockList[0x6FaE413d14cD734d6816d4407b1e4aB931D3F918] = 100378  * 10 ** 18;

        lockList[0xb6224a0f0ab25312d100a1a8c498f7fb4c86da17] = 484510  * 10 ** 18;

        lockList[0xE3C398F56733eF23a06D96f37EaE555eE6596A85] = 381015  * 10 ** 18;

        lockList[0x3eB5594E1CE158799849cfC7A7861164107F2006] = 445141  * 10 ** 18;

        lockList[0x15ac93dE94657882c8EB6204213D9B521dEBaBfB] = 213617  * 10 ** 18;

        lockList[0x1988267Ce9B413EE6706A21417481Ed11a3Ca152] = 595134  * 10 ** 18;

        lockList[0x50e10b4444F2eC1a14Deea02138A338896c2325E] = 321502  * 10 ** 18;

        lockList[0x5934028055dd8bff18e75283af5a8800469c7eda] = 788752  * 10 ** 18;

        lockList[0xff54d0987cba3c07dc2e65f8ba62a963439e257f] = 239170  * 10 ** 18;

        lockList[0x71396C01ba9AA053a51cfadC7d0D09d97aF96189] = 2250076 * 10 ** 18;

        lockList[0x795129211Eb76D8440E01Ed2374417f054dB65f2] = 2355693 * 10 ** 18;

        lockList[0xac0c89c654d837100db2c3dc5923e308c745ac0e] = 34000   * 10 ** 18;

        lockList[0x9e25ade8a3a4f2f1a9e902a3eaa62baee0000c16] = 998700  * 10 ** 18;

        lockList[0x941D03Ae7242cF1929888FdE6160771ff27f3D8c] = 1308777 * 10 ** 18;

        lockList[0xd9A2649ea71A38065B2DB6e670272Bed0bb68fB7] = 1570922 * 10 ** 18;

        lockList[0x7303bDf8d7c7642F5297A0a97320ee440E55D028] = 1846600 * 10 ** 18;

        lockList[0x333a0401Aa60D81Ba38e9E9Bd43FD0f8253A83eB] = 1503988 * 10 ** 18;

        lockList[0x5AC44139a4E395b8d1461b251597F86F997A407B] = 1467330 * 10 ** 18;

        lockList[0xbB07b26d8c7d9894FAF45139B3286784780EC94F] = 1650000 * 10 ** 18;

        lockList[0xc4Ad40d8FCCDcd555B7026CAc1CC6513993a2A03] = 845391  * 10 ** 18;

        lockList[0x92Dab5d9af2fC53863affd8b9212Fae404A8B625] = 48000   * 10 ** 18;

   	}

//==============================================================================

//     _ _  _  _|. |`. _  _ _  .

//    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)

//==============================================================================

    /**

     * @dev used to make sure no one can interact with contract until it has

     * been activated.

     */

    modifier isActivated() {

        require(activated_ == true, "it's not ready yet");

        _;

    }

	

	/**

	 * @dev  Whether or not owner

	 */

	modifier isOwer() {

	    require(msg.sender == owner_, "you need owner auth");

        _;

	}

	

	/**

	  *@dev  active unlock contract

	  *

	  */

	function activeUnLockGMI(uint64 timeStamp) isOwer() {

		activatedTime = timeStamp;

		activated_ = true;

	}

	

	/**

	 **@dev shutDown unlock flag

	 */

	function shutDownUnlocked() isOwer() {

	    activated_ = false;

	}

	

	/**

	 *@dev Take the remaining GMI to prevent accidents.

	 * 

	 */

	function getRemainingGMI(address userAddr) isOwer() {

	    require(activated_ == false, "you need shut down unlocked contract first");

	    uint256 remainGMI = gmiToken.balanceOf(address(this));

	    gmiToken.transfer(userAddr, remainGMI);

	}

	

	modifier isExhausted() {

		require(takenAmount[msg.sender] < lockList[msg.sender], "Locked GMI is isExhausted");

		_;

	}

	

	/*

     * @dev Get GMI to user

     */

    function getUnLockedGMI() public 

	isActivated() 

	isExhausted()

		payable {



 		uint256 currentTakeGMI = 0;

 		uint256 unlockedCount = 0;

		uint256 unlockedGMI = 0;

		uint256 userLockedGMI = 0;

		uint256 userTakeTime = 0;

        (currentTakeGMI, unlockedCount, unlockedGMI, userLockedGMI, userTakeTime) = calculateUnLockerGMI(msg.sender);

		takenAmount[msg.sender] = safeAdd(takenAmount[msg.sender], currentTakeGMI);

		takenTime[msg.sender] = now;

		gmiToken.transfer(msg.sender, currentTakeGMI);

    }

    

    

	/*

     * @dev  calculate user unlocked GMI amount

     */

    function calculateUnLockerGMI(address userAddr) private isActivated() 

    view returns(uint256, uint256, uint256, uint256, uint256)  {

        uint256 unlockedCount = 0;

		uint256 currentTakeGMI = 0;

		uint256 userTakenTime = takenTime[userAddr];

		uint256 userLockedGMI = lockList[userAddr];



	    unlockedCount = safeDiv(safeSub(now, activatedTime), timeInterval);

		

		if(unlockedCount == 0) {

		    return (0, unlockedCount, unlockedGMI, userLockedGMI, userTakenTime);

		}

		

		if(unlockedCount > unLockedAmount) {

		    unlockedCount = unLockedAmount;

		}



		uint256 unlockedGMI =  safeDiv(safeMul(userLockedGMI, unlockedCount), unLockedAmount);

		currentTakeGMI = safeSub(unlockedGMI, takenAmount[userAddr]);

		if(unlockedCount == unLockedAmount) {

		   currentTakeGMI = safeSub(userLockedGMI, takenAmount[userAddr]);

		}

	    return (currentTakeGMI, unlockedCount, unlockedGMI, userLockedGMI, userTakenTime);

    }



	function balancesOfUnLockedGMI(address userAddr) public 

	isActivated() view returns(uint256, uint256, uint256, uint256, uint256)

    {

	

		uint256 currentTakeGMI = 0;

		uint256 unlockedCount = 0;

		uint256 unlockedGMI = 0;

		uint256 userLockedGMI = 0;

		uint256 userTakeTime = 0;



		(currentTakeGMI, unlockedCount, unlockedGMI, userLockedGMI, userTakeTime) = calculateUnLockerGMI(userAddr);

		    

		return (currentTakeGMI, unlockedCount, unlockedGMI, userLockedGMI, userTakeTime);

	}

}