/**

 *Submitted for verification at Etherscan.io on 2018-09-04

*/



//distribute tokens

pragma solidity ^0.4.24;



contract U42 {

	function transferFrom (address _from, address _to, uint256 _value ) public returns ( bool );

}



contract BatchDist1 {



	constructor() public {

		//nothing to do

	}



	function dist (address _tokenContractAddress) public returns (bool success) {

		U42 target = U42(_tokenContractAddress);



		//batch 1 -- 33 items

		target.transferFrom(msg.sender, 0x74fBaA54034e56c33696BD4620956DE244A64622, 1826301000000000000000000);

		target.transferFrom(msg.sender, 0xb5515d9EdC28D6D2d6Bee2879D0Dc4Bb12384a6a, 100000000000000000000000);

		target.transferFrom(msg.sender, 0xB6C7271bE1495b7904535e593fe0230DAee39c6E, 125000000000000000000000);

		target.transferFrom(msg.sender, 0x19B341bA9684479Ea4aAE77EF15B9854540Adc8e, 63750000000000000000000);

		target.transferFrom(msg.sender, 0xd1842e28342164b8613ceFA50F1e182b82C3304B, 187500000000000000000000);

		target.transferFrom(msg.sender, 0x1d1408eaB849FfF6DAC10E79FBB247555F84a604, 187500000000000000000000);

		target.transferFrom(msg.sender, 0x383E163cA4247633548973b4174c68a3BeD498A5, 2500000000000000000000);

		target.transferFrom(msg.sender, 0xcE820782D117e0B851CA5BeD64bD33975f59612c, 2556164383561640000000000);

		target.transferFrom(msg.sender, 0x2951f76ad5078aedb6CB5F61bf8203E8B3cf8c4E, 668578767123288000000000);

		target.transferFrom(msg.sender, 0x07E4286dcE50c0b1c26551cA0A250Dc0492204C4, 50000000000000000000000);

		target.transferFrom(msg.sender, 0x087aB63b03a9DB48dC8cE2380aA9327D0E7845b9, 25000000000000000000000);

		target.transferFrom(msg.sender, 0x2E5aD3Af0BFB366ffcECc22D6DB4025F3e85650B, 6250000000000000000000);

		target.transferFrom(msg.sender, 0xeEcEEE2C5D941e969fDd2C40E184af35F794bcc7, 64203767123287700000000);

		target.transferFrom(msg.sender, 0x2c26BfDD4442235A3Ee9E403f3d7F812E53470bB, 25000000000000000000000);

		target.transferFrom(msg.sender, 0xBaabf2E7791b3D93402aBd1faEEDF54f6b9c0342, 250000000000000000000000);

		target.transferFrom(msg.sender, 0xC84B023a1B922248328F4F9C61eA07Aff3085f4b, 10000000000000000000000);

		target.transferFrom(msg.sender, 0x0b30dE228D47393D190CAd5348D1D1d360D3fF2d, 64443493150684900000000);

		target.transferFrom(msg.sender, 0x6876585122CE7715945a5E1dc701E883CABE8c37, 12500000000000000000000);

		target.transferFrom(msg.sender, 0x7444FE4443df6Ff49a4b0BC6AD34E7cD5cae062a, 9589000000000000000000);

		target.transferFrom(msg.sender, 0x24dD6906449BB8c1b9A3BAA52D60F1816Ab4c981, 650000000000000000000000);

		target.transferFrom(msg.sender, 0x9eCA18Db1B457E1Fc2D8771009a31A214bF0000B, 856755000000000000000000);

		target.transferFrom(msg.sender, 0xA7e9c87B52b858e83440e8966dd4B688B1178538, 307000000000000000000000);

		target.transferFrom(msg.sender, 0xc6AFED34C7948E08005aB3ef481Fb615817c5Ef8, 25000000000000000000000);

		target.transferFrom(msg.sender, 0xF837E24817d5e127ab9fA3eb80FEA3eD4fCc0f98, 2500000000000000000000);

		target.transferFrom(msg.sender, 0x176BD475Fa233F88Ad9fDe2934c4D48F8c5D17A5, 127363000000000000000000);

		target.transferFrom(msg.sender, 0x1cF80Dd2d7b27F84fc5e19e0AA1f648A291055CF, 38388500000000000000000);

		target.transferFrom(msg.sender, 0x4a795BE81c53577dcA8F6F127C85C1C5b1bF2141, 38388500000000000000000);

		target.transferFrom(msg.sender, 0x65cBdB25882Dfd4Da55F9dBB8026243475651dCb, 2460882000000000000000000);

		target.transferFrom(msg.sender, 0x6C96A850b2b3CeE46b133aFa8FaeAd357884F5a2, 25000000000000000000000);

		target.transferFrom(msg.sender, 0x8F1b204bDe03630491e7E99660463Dd12005d0b2, 563681500000000000000000);

		target.transferFrom(msg.sender, 0xb06211921b4889ffCFfC82e700F43b1Ed15bF097, 13750000000000000000000);

		target.transferFrom(msg.sender, 0xf7dDf094F97262394663D96cDe4067d21261D9FE, 37500000000000000000000);

		target.transferFrom(msg.sender, 0x82B5e1bE5e082a72A48D5731FA536D16e58CDBBB, 12500000000000000000000);

		//end of batch 1 -- 33 items



		return true;

	}

}