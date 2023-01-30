pragma solidity ^0.5.2;

import "./CereneumImplementation.sol";

/// @author AshKetchumNakamoto09
/// @title A Trustless Interest-bearing Cryptographic Certificate of Interest on Ethereum
contract Cereneum is CereneumImplementation
{
	using SafeMath for uint256;

	constructor(
			bytes32 a_hBTCMerkleTreeRoot,
			bytes32 a_hBCHMerkleTreeRoot,
			bytes32 a_hBSVMerkleTreeRoot,
			bytes32 a_hETHMerkleTreeRoot,
			bytes32 a_hLTCMerkleTreeRoot
  )
	public
	{
		//Store the launch time of the contract
    m_tContractLaunchTime = block.timestamp;
    m_hMerkleTreeRootsArray[0] = a_hBTCMerkleTreeRoot;
		m_hMerkleTreeRootsArray[1] = a_hBCHMerkleTreeRoot;
		m_hMerkleTreeRootsArray[2] = a_hBSVMerkleTreeRoot;
		m_hMerkleTreeRootsArray[3] = a_hETHMerkleTreeRoot;
		m_hMerkleTreeRootsArray[4] = a_hLTCMerkleTreeRoot;

		//These ratios will be updated on snapshot day
		//All ratios have an invisible 0.0 in front of them
		m_blockchainRatios[0] = 5128; //BCH
	  m_blockchainRatios[1] = 2263; //BSV
	  m_blockchainRatios[2] = 3106; //ETH
	  m_blockchainRatios[3] = 1311; //LTC

		//Binance 1
		m_exchangeAirdropAddresses[0] = 0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE;
		m_exchangeAirdropAmounts[0] = 17400347788910;

		//Binance 2
		m_exchangeAirdropAddresses[1] = 0xD551234Ae421e3BCBA99A0Da6d736074f22192FF;
		m_exchangeAirdropAmounts[1] = 6758097982665;

		//Binance 3
		m_exchangeAirdropAddresses[2] = 0x564286362092D8e7936f0549571a803B203aAceD;
		m_exchangeAirdropAmounts[2] = 5557947334680;

		//Binance 4
		m_exchangeAirdropAddresses[3] = 0x0681d8Db095565FE8A346fA0277bFfdE9C0eDBBF;
		m_exchangeAirdropAmounts[3] = 5953786344335;

		//Binance 5 has little ether in it

		//Binance 6
		m_exchangeAirdropAddresses[4] = 0x4E9ce36E442e55EcD9025B9a6E0D88485d628A67;
		m_exchangeAirdropAmounts[4] = 779918770916450;

		//Bittrex1
		m_exchangeAirdropAddresses[5] = 0xFBb1b73C4f0BDa4f67dcA266ce6Ef42f520fBB98;
		m_exchangeAirdropAmounts[5] = 84975797259280;

		//Bittrex3
		m_exchangeAirdropAddresses[6] = 0x66f820a414680B5bcda5eECA5dea238543F42054;
		m_exchangeAirdropAmounts[6] = 651875804471280;

		//KuCoin1
		m_exchangeAirdropAddresses[7] = 0x2B5634C42055806a59e9107ED44D43c426E58258;
		m_exchangeAirdropAmounts[7] = 6609673761160;

		//KuCoin2
		m_exchangeAirdropAddresses[8] = 0x689C56AEf474Df92D44A1B70850f808488F9769C;
		m_exchangeAirdropAmounts[8] = 4378334643430;

		//LAToken
		m_exchangeAirdropAddresses[9] = 0x7891b20C690605F4E370d6944C8A5DBfAc5a451c;
		m_exchangeAirdropAmounts[9] = 6754951284855;

		//Huobi Global
		m_exchangeAirdropAddresses[10] = 0xDc76CD25977E0a5Ae17155770273aD58648900D3;
		m_exchangeAirdropAmounts[10] = 427305320984440;

		//CoinBene
		m_exchangeAirdropAddresses[11] = 0x33683b94334eeBc9BD3EA85DDBDA4a86Fb461405;
		m_exchangeAirdropAmounts[11] = 2414794474090;

    //Mint all claimable coins to contract wallet
    _mint(address(this), m_nMaxRedeemable);
	}

	//ERC20 Constants
  string public constant name = "Cereneum";
  string public constant symbol = "CER";
  uint public constant decimals = 8;

	/// @dev A one time callable function to airdrop Ethereum chain CER tokens to some exchange wallets.
	/// The amounts granted had the standard whale penalties applied and were removed from the UTXO
	/// set before the Merkle Tree was built so they cannot be claimed a second time.
	function ExchangeEthereumAirdrops() external
	{
		UpdateDailyData();

		require(m_bHasAirdroppedExchanges == false);
		m_bHasAirdroppedExchanges = true;

		//The following Ethereum exchange addresses are removed from the claimable UTXO set and automatically airdropped
		//To encourage early exchange support.
		uint256 nGenesisBonuses = 0;
		uint256 nPublicReferralBonuses = 0;
		uint256 nTokensRedeemed = 0;
		uint256 nBonuses = 0;
		uint256 nPenalties = 0;

		for(uint256 i=0; i < 12; ++i)
		{
			(nTokensRedeemed, nBonuses, nPenalties) = GetRedeemAmount(m_exchangeAirdropAmounts[i], BlockchainType.Ethereum);

			//Transfer coins from contracts wallet to claim wallet
			_transfer(address(this), m_exchangeAirdropAddresses[i], nTokensRedeemed);

			//Mint speed bonus and 10% referral bonus to claiming address
			_mint(m_exchangeAirdropAddresses[i], nBonuses.add(nTokensRedeemed.div(10)));

			//Speed bonus and referral bonus matched for genesis address (20% for referral and 10% for claimer referral = 30%)
			nGenesisBonuses = nGenesisBonuses.add(nBonuses.add(nTokensRedeemed.mul(1000000000000).div(3333333333333)));

			//Grant 20% bonus of tokens to referrer
			nPublicReferralBonuses = nPublicReferralBonuses.add(nTokensRedeemed.div(5));

			m_nTotalRedeemed = m_nTotalRedeemed.add(GetRedeemRatio(m_exchangeAirdropAmounts[i], BlockchainType.Ethereum));
			m_nRedeemedCount = m_nRedeemedCount.add(1);
		}

		//Mint all of the referrer bonuses in a single call
		_mint(m_publicReferralAddress, nPublicReferralBonuses);

		//Mint all of the genesis bonuses in a single call
		_mint(m_genesis, nGenesisBonuses);
	}
}
