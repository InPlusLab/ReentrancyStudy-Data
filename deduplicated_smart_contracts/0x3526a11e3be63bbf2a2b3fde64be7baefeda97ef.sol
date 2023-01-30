/**

 *Submitted for verification at Etherscan.io on 2018-09-28

*/



//distribute tokens

pragma solidity ^0.4.24;



contract U42 {

	function transferFrom (address _from, address _to, uint256 _value ) public returns ( bool );

}



contract U42_Dist3 {



	constructor() public {

		//nothing to do

	}



	function dist (address _tokenContractAddress) public returns (bool success) {

		U42 target = U42(_tokenContractAddress);



		//batch 3 -- 30 items

		target.transferFrom(msg.sender, 0x6CE860449c423Eaa45e5E605E9630cE84C300B16, 37500000000000000000000);

		target.transferFrom(msg.sender, 0xE5249DeB2cbBf6110B53f4D2e224670b580dB02B, 63630000000000000000000);

		target.transferFrom(msg.sender, 0xb4b378E93007a36D42D12a1DD5f9EaD27aa43dca, 500935000000000000000000);

		target.transferFrom(msg.sender, 0x7354d078FA41aB31F6d01124F57fD0BF755f2c2F, 250000000000000000000000);

		target.transferFrom(msg.sender, 0x31156B3dFba60474Af2C7386e2F417301D3702D7, 10000000000000000000000);

		target.transferFrom(msg.sender, 0x9901D5eAC70A2d09f6b90a577DB7D02D5CdE9021, 32250000000000000000000);

		target.transferFrom(msg.sender, 0xc0A1004F4A0BdC06e503de028f81e5Ab0097e6A2, 230000000000000000000);

		target.transferFrom(msg.sender, 0xd4bf5E3f5ada0ACa8Ac19a17bF27b4AD2a39E2a4, 297850000000000000000);

		target.transferFrom(msg.sender, 0xA779081df0fe26A7D8B9662E17325Ea65Ad0A33A, 7500000000000000000000);

		target.transferFrom(msg.sender, 0xA060144B56588959B053985bac43Bd6b2AAdC2Cf, 156400000000000000000);

		target.transferFrom(msg.sender, 0x36DF0fDB4E10c679a737Ca5110961fa7bd9805Ca, 230000000000000000000);

		target.transferFrom(msg.sender, 0xF339c21fE359179Cf0f4a8AC2A8514B458b615B3, 1118034000000000000000000);

		target.transferFrom(msg.sender, 0x51FA675B49fC52b905b299D923CF2853120F1755, 306089000000000000000000);

		target.transferFrom(msg.sender, 0x8418549b5a053aC0851d14013ab39aC202b8a112, 532328000000000000000000);

		target.transferFrom(msg.sender, 0x68BFf8602ab7c2635bc3558F31Cf4c1f50DaEc46, 22500000000000000000000);

		target.transferFrom(msg.sender, 0x03fD3835a8Df5076FA61Ef70437E99B375f143c9, 1333219000000000000000000);

		target.transferFrom(msg.sender, 0x2D07A0f39071c910026e4271446995431c2Eee38, 648972000000000000000000);

		target.transferFrom(msg.sender, 0xB6C08B84DA23F2B986132B4b9D54fC02E1c1161E, 52500000000000000000000000);

		target.transferFrom(msg.sender, 0x1C39adBF54590dCC2623f0954027524Fd3d59C95, 50000000000000000000000);

		target.transferFrom(msg.sender, 0xbA6F38D19622fec21a0BD4f9a3cba313651c598c, 5405580000000000000000);

		target.transferFrom(msg.sender, 0x3A6068724f0Ae9fa21a5ce7C02Bc0c027Ef87aD8, 128801000000000000000000);

		target.transferFrom(msg.sender, 0x22B1bE2c2e67494De4d6FA7d20798712151FF124, 2169589000000000000000000);

		target.transferFrom(msg.sender, 0xA7A987F4a90EfF09812e9683Ced3d225A209699e, 125000000000000000000000);

		target.transferFrom(msg.sender, 0xeC4273FdfB6731b17b7e57789f1BEbE48902C27B, 20000000000000000000000);

		target.transferFrom(msg.sender, 0x447a60543AA9F78C206581E2023f088e98A672aF, 12500000000000000000000000);

		target.transferFrom(msg.sender, 0x1d4b4274BC4F6b399ABC77E9031eC1dE7952DF60, 37500000000000000000000);

		target.transferFrom(msg.sender, 0x20BB6a04cb8A7Dd9AE22eCe03eCE97B5F34fE8C9, 2500000000000000000000);

		target.transferFrom(msg.sender, 0x98CAB668Ef2f7314AF1519D1f1Ff0b02d5988dF7, 12553082000000000000000000);

		target.transferFrom(msg.sender, 0x8F1b204bDe03630491e7E99660463Dd12005d0b2, 62500000000000000000000);

		target.transferFrom(msg.sender, 0xe0738F9B8A750B670E113C0A3668240e884C49F9, 9250000000000000000000);

		//end of batch 3 -- 30 items



		return true;

	}

}