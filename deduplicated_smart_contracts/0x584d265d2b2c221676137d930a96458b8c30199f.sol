/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity 0.5.16;


contract AddressRegistry {
    // Aave
    address public AaveLendingPoolAddressProviderAddress = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;
    address public AaveEthAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Uniswap
    address public UniswapFactoryAddress = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;

    // Compound
    address public CompoundPriceOracleAddress = 0x1D8aEdc9E924730DD3f9641CDb4D1B92B848b4bd;
    address public CompoundComptrollerAddress = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    address public CEtherAddress = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    address public CUSDCAddress = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    address public CDaiAddress = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address public CSaiAddress = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;

    // Token(s)
    address public DaiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public BatAddress = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
    address public UsdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // MakerDAO
    // https://changelog.makerdao.com/
    // https://changelog.makerdao.com/releases/mainnet/1.0.4/contracts.json
    address public EthJoinAddress = 0x2F0b23f53734252Bda2277357e97e1517d6B042A;
    address public UsdcJoinAddress = 0xA191e578a6736167326d05c119CE0c90849E84B7;
    address public BatJoinAddress = 0x3D0B1912B66114d4096F48A8CEe3A56C231772cA;
    address public DaiJoinAddress = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address public JugAddress = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address public DssProxyActionsAddress = 0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038;
    address public DssCdpManagerAddress = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
}