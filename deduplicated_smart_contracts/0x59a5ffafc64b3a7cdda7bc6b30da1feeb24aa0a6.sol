/**

 *Submitted for verification at Etherscan.io on 2018-09-04

*/



//distribute tokens

pragma solidity ^0.4.24;



contract U42 {

	function transferFrom (address _from, address _to, uint256 _value ) public returns ( bool );

}



contract BatchDist2 {



	constructor() public {

		//nothing to do

	}



	function dist (address _tokenContractAddress) public returns (bool success) {

		U42 target = U42(_tokenContractAddress);



		//batch 2 -- 33 items

		target.transferFrom(msg.sender, 0xE2ab8901646e753fA4687bcB85BAc0Ed4eeD9feF, 262500000000000000000000);

		target.transferFrom(msg.sender, 0x8Ea23514E51f11F8B9334bdB3E0CdAB195B4e544, 25000000000000000000000);

		target.transferFrom(msg.sender, 0xC3df7C56E91A150119A3DA9F73f2b51f21502269, 25000000000000000000000);

		target.transferFrom(msg.sender, 0x5EC0adeeB1C98C157C7353e353e41De45E587efc, 250000000000000000000000);

		target.transferFrom(msg.sender, 0x70f71E34900449d810CA8d1eD47A72A936E02aAb, 27500000000000000000000);

		target.transferFrom(msg.sender, 0x1a49e86BafEd432B33302c9AEAe639Fa3548746A, 1333219000000000000000000);

		target.transferFrom(msg.sender, 0xB9Ecbbe78075476c6cF335c77bdCdAC433fDf726, 260787000000000000000000);

		target.transferFrom(msg.sender, 0x5B904e161Ac6d8C73a5D1607ae6458BDF3C9239E, 62500000000000000000000);

		target.transferFrom(msg.sender, 0x6CE860449c423Eaa45e5E605E9630cE84C300B16, 37500000000000000000000);

		target.transferFrom(msg.sender, 0x8e25E26036d3AD7Ffe7aeDF3b292574FDA1edda0, 63630000000000000000000);

		target.transferFrom(msg.sender, 0x7354d078FA41aB31F6d01124F57fD0BF755f2c2F, 250000000000000000000000);

		target.transferFrom(msg.sender, 0x31156B3dFba60474Af2C7386e2F417301D3702D7, 10000000000000000000000);

		target.transferFrom(msg.sender, 0x9901D5eAC70A2d09f6b90a577DB7D02D5CdE9021, 27300000000000000000000);

		target.transferFrom(msg.sender, 0xF339c21fE359179Cf0f4a8AC2A8514B458b615B3, 1118034000000000000000000);

		target.transferFrom(msg.sender, 0x51FA675B49fC52b905b299D923CF2853120F1755, 306089000000000000000000);

		target.transferFrom(msg.sender, 0x8418549b5a053aC0851d14013ab39aC202b8a112, 532328000000000000000000);

		target.transferFrom(msg.sender, 0x68BFf8602ab7c2635bc3558F31Cf4c1f50DaEc46, 22500000000000000000000);

		target.transferFrom(msg.sender, 0x03fD3835a8Df5076FA61Ef70437E99B375f143c9, 1333219000000000000000000);

		target.transferFrom(msg.sender, 0xb3d0C83C46a3c8C1B25cbFa4Ed0d32Df8dA86846, 648972000000000000000000);

		target.transferFrom(msg.sender, 0x1C39adBF54590dCC2623f0954027524Fd3d59C95, 50000000000000000000000);

		target.transferFrom(msg.sender, 0x22B1bE2c2e67494De4d6FA7d20798712151FF124, 2169589000000000000000000);

		target.transferFrom(msg.sender, 0xA7A987F4a90EfF09812e9683Ced3d225A209699e, 125000000000000000000000);

		target.transferFrom(msg.sender, 0xeC4273FdfB6731b17b7e57789f1BEbE48902C27B, 20000000000000000000000);

		target.transferFrom(msg.sender, 0x447a60543AA9F78C206581E2023f088e98A672aF, 12500000000000000000000000);

		target.transferFrom(msg.sender, 0x98CAB668Ef2f7314AF1519D1f1Ff0b02d5988dF7, 12553082000000000000000000);

		target.transferFrom(msg.sender, 0x20BB6a04cb8A7Dd9AE22eCe03eCE97B5F34fE8C9, 2500000000000000000000);

		target.transferFrom(msg.sender, 0x8F1b204bDe03630491e7E99660463Dd12005d0b2, 62500000000000000000000);

		target.transferFrom(msg.sender, 0x8F7fD445afa5203EfaF7033683BfbE198e6cFFa2, 125188000000000000000000);

		target.transferFrom(msg.sender, 0xD65D398f500C4ABc8313fF132814Ef173F57850E, 187500000000000000000000);

		target.transferFrom(msg.sender, 0xc9c7F168985EC5D534760DaC313458D982B41784, 448938000000000000000000);

		target.transferFrom(msg.sender, 0xE77Ce7Ac475ebBd4546594A7A2f164dB84Cb0dce, 82500000000000000000000);

		target.transferFrom(msg.sender, 0x1A35645dE121Aa895B46215739fEC495387D2E34, 2500000000000000000000);

		target.transferFrom(msg.sender, 0x9ebD57aca9209217E7103ce7d7c22d7e2cc1596E, 3750000000000000000000);

		//end of batch 2 -- 33 items



		return true;

	}

}