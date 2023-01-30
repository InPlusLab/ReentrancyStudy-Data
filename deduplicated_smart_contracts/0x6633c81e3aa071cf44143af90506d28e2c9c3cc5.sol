/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

pragma solidity 0.5.17;


contract ReentrancyGuard
{
  bool private _notEntered;


  constructor () internal
  {
    _notEntered = true;
  }

  modifier nonReentrant()
  {
    // _notEntered true on first call
    require(_notEntered, "reent");

    // Any calls to nonReentrant after this point will fail
    _notEntered = false;
    _;
    _notEntered = true;
  }
}


pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.5.17;


contract IYLD is IERC20
{
  function mint(address _account, uint _amount) public returns (bool);
}

// File: contracts\ClaimDropper.sol

pragma solidity 0.5.17;


contract ClaimDropper is ReentrancyGuard
{
  IYLD internal constant YLDToken = IYLD(0xDcB01cc464238396E213a6fDd933E36796eAfF9f);
  mapping(address => uint) internal beneficiaries;


  constructor () public
  {
    beneficiaries[0x12C3Fd99ab45Bd806128E96062dc5A6C273d8AF6] = 200;
    beneficiaries[0xF22b63516903f78ad5e0F7FD1A8092Ae9834EFe8] = 1000;
    beneficiaries[0xe6309a762D72E66d16e6f1CfaEEe9F5Cab6F9C52] = 300;
    beneficiaries[0xC0768B3f5830d46577bcD6415e28244Db333d986] = 300;
    beneficiaries[0x2082273e1B5308Ac9F1bDdA8F5cc1Bb43C43ca26] = 1250;
    beneficiaries[0x3e513fF22f7637f96d056741Ed7C3F01cde63Ff2] = 300;
    beneficiaries[0xbe611bC1AD2e40412D83E346ae69aE2C0054bb96] = 750;
    beneficiaries[0x22c13EA0441860e00785f481C466469a2275c211] = 750;
    beneficiaries[0x9ff9B4508E30a5b7De41f021fC9634dF1f7D5c87] = 750;
    beneficiaries[0x2e4acCEd34DF045B43358E6De8B89Fd070349f15] = 750;
    beneficiaries[0x58413117f1bd86D5224d0Dd1dFec7d2fA7611136] = 750;
    beneficiaries[0x80353Ba6223A4920296E9Eb7155aC60802477E16] = 750;
    beneficiaries[0x60aD781161Ee9fB192A6C75cB81E3Be0D2Fe28c2] = 750;
    beneficiaries[0xE44C62dbFE8C170c91CB08291BEECe67777bAA0E] = 1250;
    beneficiaries[0x7D601144Ba14182C9D062099eaeA2ea5CDE7e6A9] = 1000;
    beneficiaries[0xB908E71bD23C25A8921955e714385E8E8cCb5960] = 1250;
    beneficiaries[0x458195409522C9FcE3d71d8D4190369AF4F38613] = 1250;
    beneficiaries[0x964D22D80FDA5CeeAEFf106211fB4843feE9b4A6] = 300;
    beneficiaries[0xd3Fa9F6a8818D7De2054794A42cba2F2667F670D] = 300;
    beneficiaries[0x0884E58DEfE5178c286Bc2cbF7349B1079e6DFc7] = 300;
    beneficiaries[0x8C8E99160e4E2f354b1747Af9f40Af1a342e8888] = 200;
    beneficiaries[0x69f36A5e83f9E5BF31fAAc61A7E5144810D9BE83] = 200;
    beneficiaries[0x2D8bDF0cae37A102Dc6b1c9dc828B396972A1f46] = 1000;
    beneficiaries[0x058ac714e41ce538744F7bd9205304a19776A711] = 200;
    beneficiaries[0x911aF297Fd9D464Fb0dC5ffdBA14eDb1de07dDA2] = 1000;
    beneficiaries[0x85FC884fd2858BB3Da9550DEFdBd2Bb4c0ee7157] = 300;
    beneficiaries[0x22bbFe1994B410738E1c7D823E602EF697a7a198] = 750;
    beneficiaries[0x1715292de4595Cd3903984880C0D2C9FF4AC9999] = 200;
    beneficiaries[0x087069CBC6BAABe5611F03967B2498166c0E1DCb] = 1000;
    beneficiaries[0xc11B831c79906dE20ECf2621e0Dce218E23EC60b] = 300;
    beneficiaries[0xEde78D65Cfb2307E007B1ff6412cfFE19b9eC74F] = 300;
    beneficiaries[0x2Ea260a5C4d3d44cf2BA604004b088Dc1013DE20] = 750;
    beneficiaries[0xf91ECE17a4ea360AcBE444B63dAe3abD8B893D0d] = 200;
    beneficiaries[0x2A060e5a5Cd1ba946b93284cC6307F5356ba9A51] = 200;
    beneficiaries[0xE5e7711ccd8D6D770cdBF754D8f783e6bc5FAa31] = 300;
    beneficiaries[0xF3f67A3FdC7d66B4357C6686938C3726C46503CC] = 200;
    beneficiaries[0x9CB6247bF9e22da514b1b32aCAE28C560C73d848] = 1000;
    beneficiaries[0x83AB4941E341ECfeF825e38Bc4b6Fb3f15cF95a4] = 750;
    beneficiaries[0xEcA88938aBfF4F6329fE99Cf67709B392DD0F7cb] = 200;
    beneficiaries[0xF6bA9A42e348A6770e749e8d713B33a59431d557] = 1000;
    beneficiaries[0x33142B70d290cAe2fE4d0Bbc1B116F5032F80fA5] = 200;
    beneficiaries[0xD02D098370b18FA0FfdEF3a83D1CE44b97194B04] = 200;
    beneficiaries[0x1100629e5C803E5b232c94c658DeC27d13a79c1A] = 1000;
    beneficiaries[0x61574aD3fefD2fDA1882E35B7FdE2Eb7558f8F46] = 200;
    beneficiaries[0x2070C50ACE4DE768BC063B5e090C64ff6307E806] = 750;
    beneficiaries[0x3B7373c6BfC90BF8fF2E44C7F8897697Ccc29062] = 300;
    beneficiaries[0x753083390ba2C56aE152dB078D2aE90Eb21023cD] = 200;
    beneficiaries[0xBCF5Ec0c8520A72c3E8C5aF775F0662eB472Fc1d] = 200;
    beneficiaries[0x8D12B8c3bEf358d1901d891a74FA801aBa2b79B0] = 200;
    beneficiaries[0x028f964F0Eb7F1E97F6Bec047A8844E11843ae2b] = 200;
    beneficiaries[0xE5F6fA060D54BCD7FA43C35d9CD2CB9b1B98Fbc0] = 200;
    beneficiaries[0x880772af311d7F3Bb2cf10A789Fa1264815f14e8] = 200;
    beneficiaries[0x4E7738dE4172F4ce899B9248565C336BB02efB38] = 200;
    beneficiaries[0x9f2cFB19A3d5495B0fC9E2834F52d2B4146A68a0] = 200;
    beneficiaries[0xfe2321D7DFA492dFC39330e8b85E7c49161e7F98] = 1000;
    beneficiaries[0x4408A119FfC739866521DB85Dc7cEF2F72c8168e] = 200;
    beneficiaries[0x09a9A5de88f68aeE50A62ef4Ea15BD0C552fB572] = 750;
    beneficiaries[0xD7b86667B2A91A91A5415c24188E83F19aaE9686] = 200;
    beneficiaries[0x207a9244e950AEB8C0041766927fd94841033590] = 200;
    beneficiaries[0x11ba7a053ec69206ccEB7f81950F86b079469f50] = 200;
    beneficiaries[0x81Bd8b80cdd71C11Fb4BF685c729E7B6689fC698] = 200;
    beneficiaries[0x7406047D76c57e5B6E67D2fa54f264AF46EC354c] = 200;
    beneficiaries[0x00bbdfca8f11E44A4b0d1196D6c40dEA54924D91] = 200;
    beneficiaries[0x0D2C626E4A23D6754b6a7e0e27f4F97124abF47c] = 750;
    beneficiaries[0xE950C23891E41E5bb3fe4a45DdE62752a4BBf9Fb] = 750;
    beneficiaries[0x6EB3095c9190D5831ff03a1aCF4c5f523c74DF3d] = 750;
    beneficiaries[0x3caDc49c14b384192345F1c7e1eD0f19855F2b19] = 300;
    beneficiaries[0x055ade7a19307eDc837572906fD3f444A631a983] = 200;
    beneficiaries[0x75a9D8A7382725252FB2939EDDA70Ef9fD6EAa95] = 750;
    beneficiaries[0xB21A951c7E4B467fA344e6bc08F0ba72116F4E91] = 200;
    beneficiaries[0x6e577B01BB9784C9eF4a062171c36d643d99d209] = 300;
    beneficiaries[0x59273d0f04cf13d8b456577c6F8356da6ABA7c5E] = 300;
    beneficiaries[0x54b321b2be9162cf1995Ee9daaF393Ae876e510D] = 300;
    beneficiaries[0x80fdaF4A47864CFC5F6d132101F6eE26BC167D33] = 200;
    beneficiaries[0xD69e9dcb720eE58eeCBDe5109B849f28c27294c8] = 1000;
    beneficiaries[0x43a0913556221d9Ae386B2D7422c71a791a3Bd04] = 1000;
    beneficiaries[0x2FE7d879e342FEe5f1d04BfEdAf35Bb9D4fA5b89] = 200;
    beneficiaries[0x2bA8de1cB230DA4F9C314F43224ce1253E58bAca] = 200;
    beneficiaries[0x628f792899B3b43BFfe357b54727c8F6A3F84495] = 200;
    beneficiaries[0x3CC14Bb5c1715F36486f0d8c195647C2E91159A0] = 200;
    beneficiaries[0x638a0117F398aEF681c98E7Be67B25BF96c35aC9] = 300;
    beneficiaries[0x1aEf9E889b8D48CF38290D0C1103A8ece0df1D61] = 200;
    beneficiaries[0x3F2e8eAE82A771AB28c168b9E0f4eB9b508b605B] = 300;
    beneficiaries[0xa4AB2F6cd715f3B915Ab94dB255b1587a06DC0c9] = 200;
    beneficiaries[0x58024B6C1005dE40eAC2D4c06bC947ebf2a302Af] = 300;
    beneficiaries[0xd859CbAD6f4fbEac118c5f4CBf47ED21215f0C9F] = 200;
    beneficiaries[0xef398a72Ca7E9c352D14aA297c5c59F604C43BDC] = 200;
    beneficiaries[0xBa89dfBbcbFee144343c59CC001Ef4Ff88bd30c4] = 1000;
    beneficiaries[0x9d837534941BE1f9422A2E1F230D34685CEFdD8f] = 300;
    beneficiaries[0xD51622E64Ad14dcad142C2c54e6F6b2fab3b570e] = 300;
    beneficiaries[0xadAc2a2c88aA5306E355234eC46dDFc2FaEF8cD1] = 200;
    beneficiaries[0xDBb586b238Ab1F7F5aC4Dec616b59e7C7478D010] = 200;
    beneficiaries[0x9F9692FfF5Ce2C81737f62bccA101a7a7bC31c46] = 200;
    beneficiaries[0x87BA6ef5fAB4A3F54440D2f2a7606024f6971280] = 200;
    beneficiaries[0xc6bb76D4Db067495f8b9b545E6e1CC9e550F3ff3] = 200;
    beneficiaries[0x32f28d947d83eAf48c82A6E7057F62560B74Cc43] = 750;
    beneficiaries[0x1B2e7D29D411B4b4e48F3335E523d8dcA382DfD6] = 1000;
    beneficiaries[0x309fC3FD88280BAD00DA6E2E6DFdc2F7fe005b13] = 200;
    beneficiaries[0x37Afb5B8Aa15D7bbbb95924Ac26Bba01727e03A6] = 1000;
    beneficiaries[0x5e630b5b001Ff5E7f3cEc1C50E915395F49a6f0c] = 1000;
    beneficiaries[0xC0CF30Ca34C392fE00dc583d99dD39E541Ed3Ca6] = 200;
    beneficiaries[0x40649C2F378550F0130644652fEF3922188DFD68] = 1000;
    beneficiaries[0xeD85c910EE10e88f3c2De3668a2683A428E20603] = 200;
    beneficiaries[0x4F3D348a6D09837Ae7961B1E0cEe2cc118cec777] = 300;
    beneficiaries[0x541959881e4766125980F24F8b2F89405b249Df9] = 200;
    beneficiaries[0x88c4bc658c9a8f91acc879be97B8E12ccE43c4A0] = 200;
    beneficiaries[0x3508f12c16D194E845F9DeD067BcD17A06Db1A1D] = 200;
    beneficiaries[0x587fD17DA29627507f5D8ba952C4c5cd23D5C339] = 200;
    beneficiaries[0xa69F71F6B5895A30a86c4560A5116E2b5f5e4cec] = 200;
    beneficiaries[0xCC4d59249fA39bb1eE7CCd05b4eE179080Af5b08] = 750;
    beneficiaries[0x9Dbe9a73e59DCAE7dF3D33728697cD7a89147E63] = 300;
    beneficiaries[0x513555a1D2aA6D56Af8ffa64Fd06DB7df1499F51] = 200;
    beneficiaries[0x1b7f00Ca9d8fEA5a9853F18aD247f806a8Dce57a] = 200;
    beneficiaries[0xB9393836755De736EcB99E503448BD6f2474330c] = 300;
    beneficiaries[0x167f9aD72E83B484c5649E54d54086EC6D9D174F] = 200;
    beneficiaries[0x62957Fdac6bD021D75b959851Cb0D83d4c465C6D] = 200;
    beneficiaries[0xf63e0F0F564bAB0dE5564409664e6Cb6cB2A94DC] = 200;
    beneficiaries[0x6965E4c3A375E7b067bA0d06D9fBcde03e596b3F] = 200;
    beneficiaries[0xa7395Ba41a8071Dd9A982Ab57D4e9b3a87732E84] = 300;
    beneficiaries[0xC2baBaDA4bff38D3569D1044CF3005C21AAA650f] = 300;
    beneficiaries[0xd158675E9dE7f78980029146Ad61Cd9d13b7a030] = 200;
    beneficiaries[0xa7dE072cd500CBbBdcd769B6299178fF5d1cc73D] = 200;
    beneficiaries[0xd4Cf8f8b980e1288c9E9bb27DA4825f8f11AA49b] = 200;
    beneficiaries[0xF72EC7BfB2AA9170859d5E759943a96d30fcE15E] = 750;
    beneficiaries[0x6A5ac7a5990eE13BcF71a5Be81F1A4822c3A3601] = 300;
    beneficiaries[0x3A87AF6346a092082648933948ad8cbFc1DE699C] = 200;
    beneficiaries[0x96dFDBA8c32BFA38B059110A823376B33548509d] = 200;
    beneficiaries[0x47db432055b6afc68cdC87DACd2B52cfb56acb05] = 200;
    beneficiaries[0x198723f678a146f133dAEBfBd7120A6Dda1ed9fE] = 200;
    beneficiaries[0x9AE07F7977F4371f0EA47dd4DB69d1991fA14116] = 200;
    beneficiaries[0xD0FAfC4d7267C59E4784026aF0C57bCBca85aD84] = 200;
    beneficiaries[0x91fC93b4006C1a794Aa636f62A15e34eb381D1D2] = 200;
    beneficiaries[0xDFD2144eb8CC1212551d50b00b18a2fEfcf6762b] = 300;
    beneficiaries[0x4F965481E7E969390EfA57E72F277Ba2aA4d7Cc6] = 200;
    beneficiaries[0xff4F08EFB00a1f4D9Ac93aDb472FE8F3C5BEa016] = 200;
    beneficiaries[0xA21392dD4b12CB543Fb6d1e4e8759B3AC6e55169] = 200;
    beneficiaries[0x23C0954C4b997c58A1544717dE90C8E174eA194c] = 200;
    beneficiaries[0x7233Ca5e3042b62cB281A189C01F2083F29AF9F6] = 200;
    beneficiaries[0x2f2431618099A670931e0b478B02481141c4E2D3] = 200;
    beneficiaries[0xBC1a997243787f6A905e74508258eb55E5d593D7] = 200;
    beneficiaries[0xA37172d3803cd1366608dFeA5EfeEC767A880A8b] = 200;
    beneficiaries[0x0d4f0f044Dc5E2B059F11c6A5024D97e05E8F85E] = 200;
    beneficiaries[0x1df46555484302C19eC69377ab684576e5288560] = 200;
    beneficiaries[0x37Ddef38fd342775de976B02E366dfD244C40765] = 200;
    beneficiaries[0x9bA30966C0920B287a78BfD325f9fA61aA93e44c] = 750;
    beneficiaries[0x30B3C3451a09018a1C8CCBFe90d67801D9B36690] = 200;
    beneficiaries[0x86FEDe75c6660a8e1635a86360c9eE9d28899bA3] = 200;
    beneficiaries[0xC742A301A8b7FFc23ac35805Ba5FA98a4Ad2993b] = 200;
    beneficiaries[0x3783119553a0461A2ecCF6097da901E064baB2b8] = 200;
    beneficiaries[0xCa214150c6DF8848b2488F33f2c35f2417265798] = 200;
    beneficiaries[0xaDE00BeD371F52469077198a162a7Af17835C843] = 750;
    beneficiaries[0x23DDAfBE006eeB03FD273c422b256b6773EccE1f] = 200;
    beneficiaries[0x8B1EA47e37A70E7FeEFc6A6945a4A7272a7934db] = 200;
    beneficiaries[0xE2E895E6df7Ae8Caf5379CD7b53346bE8dB0b38c] = 200;
    beneficiaries[0x5Da487Ea7278E25288fd4f0f9243e3Fa61bc7443] = 200;
    beneficiaries[0xA593A4D8474D117CE126635dcE163Fe1fffF8701] = 200;
    beneficiaries[0xb8a4dCfa4045e32541C31C005A59A54f66B04fd6] = 200;
    beneficiaries[0xDE44aEA008e9C285fe4CbE0470A96425e80F8D62] = 200;
    beneficiaries[0x70225f33B587C52eCFc60e96037061E97DbDb926] = 200;
    beneficiaries[0xbC25D10fA5eBd8fEE24f265F586cBBE43aFf5F99] = 200;
    beneficiaries[0x86557BE46ce751a041cD59888df62Fd527c89658] = 200;
    beneficiaries[0xcbBC5D06BE48B9B1D90A8E787B4d42bc4A3B74a8] = 200;
    beneficiaries[0x6F40712E3b8D094E8fF4914A803985d8cfBA202D] = 200;
    beneficiaries[0xf4FCa18Db3398289d114d1F4F5A8273C3153e96a] = 200;
    beneficiaries[0xA4D8230DA1B4645384bB6669212f6CbfCBaDebd7] = 1000;
    beneficiaries[0xEcE71f288be2920e87B7e39CAfede463CE35884E] = 200;
    beneficiaries[0x512c7EE11BeDaCbA6A1d62c7B1E63027845db054] = 200;
    beneficiaries[0x49318b3970C8a82275B440900bE45f27bf682108] = 200;
    beneficiaries[0x90831a589dFFd0E54e5D444cb9Ea2C64FE2ced40] = 200;
    beneficiaries[0xD96641EB8bAC886D6dfD700aFDF4d1dfe2Fe75aa] = 200;
    beneficiaries[0x80Ad7547D879AB0481Eda439BF0514e02B0Cc2b9] = 200;
    beneficiaries[0xEeAB357B6583FF64d12045164177546f5c155B45] = 200;
    beneficiaries[0xe48f10c76Dc5d130a9A712841Fc950D395C8a97d] = 200;
    beneficiaries[0xa652F1e216E881b3A679D91958a5E93C71828CA6] = 200;
    beneficiaries[0x00456EbCA41FF7506fbb979E0a696ba2924d2B51] = 200;
    beneficiaries[0x6866524640106A83Bd8b7245856430672F452745] = 200;
    beneficiaries[0x71E9af759874AFa5B127AfE98437778e81Be0bfc] = 200;
    beneficiaries[0x7444b9cA731C287750348c6010CC04bA8C90112d] = 200;
    beneficiaries[0x69fAa59e22242667bdfa03c6AABEe7cB6a57666c] = 200;
    beneficiaries[0xeE3bFFC6D83d8a547DF4F6eDb93079d486AE6C20] = 200;
    beneficiaries[0xAE1A1CDB13Ec86506831531D9e52456b2c0eb625] = 200;
    beneficiaries[0x9C19C33b69B078f2B0EaF8b9d57ca8EC81E6b54B] = 200;
    beneficiaries[0x0Fe02564587A0C78Da87b1dc2eA74622F4006a7a] = 200;
    beneficiaries[0x557364BA5DF09db866cB81578D14a91698296f7C] = 200;
    beneficiaries[0xeb5F30A15f8B24021450b8DB1a62dBb4676113F5] = 200;
    beneficiaries[0xD56FA51A148f53322537FdF16e4C3DB53E73ebdd] = 200;
    beneficiaries[0x8d25F564B59EB49173f5574c5AD54856f5A31E7a] = 200;
    beneficiaries[0x89d394418eE349D26AEf5D0a3B9e3378f0CCa16d] = 200;
    beneficiaries[0xcC4fB675c46F3715c52307c4d2f8640c4EF7bb31] = 200;
    beneficiaries[0x3aAcAcD72E7d381cF9855328B3e5b78012d9A681] = 200;
    beneficiaries[0x412C8dc906e72736a015bd49b4e86971422E6C2C] = 200;
    beneficiaries[0xddfF444D8946b6d621d97beF7e59155eA3aA719D] = 200;
    beneficiaries[0x65E27aD821D14E3567E97eb600728d2AAc7e1be4] = 200;
    beneficiaries[0x8a3cf089782FEFceD39159DE9C9427f2C04Fa206] = 200;
    beneficiaries[0xc8896a13DBD775Ef7dAD93c84eA6AF8E5eBBBfAD] = 200;
    beneficiaries[0x9649C6205FE1c20AE8b4B5b4110f0f331226c638] = 200;
    beneficiaries[0x2C015E92d4A616f389fe31BC564833fd306dD85F] = 200;
    beneficiaries[0xbd071de4D984F91330d4fAb66c323DC94D38C220] = 200;
    beneficiaries[0x78F128BD6aab01f3BA5164C46Daf6Dc5B4CeE506] = 200;
    beneficiaries[0xd05D24EfE9B9bA97a2b03A017D2c034eB6f63d62] = 200;
    beneficiaries[0x3b2534b8EA1f9a8BF9D9915B91bae673d161F2A5] = 200;
    beneficiaries[0x14a1Da87Db814D34f14f1604dD5B160175F2Cd13] = 200;
    beneficiaries[0x44C51816D2B75CbD5cf63B2c8107E6f8D9a39529] = 200;
    beneficiaries[0x43d50C5C59E18D91dE7979A789D676aa2678c5f4] = 200;
    beneficiaries[0x44534Ac8935Fb535015c28f29c8e7514C2DB90E1] = 200;
    beneficiaries[0x2C1Ce551eC6e217BCBe673F16F3833a5CcdAdE91] = 200;
    beneficiaries[0xdAFEaBcdF356d0379496d06bc20061474aa38BB0] = 200;
    beneficiaries[0x97a148De591419234F9e6E85aAaC9f1848df8e83] = 200;
    beneficiaries[0xeae26500a557e9318E9c84DeEe51F939F6C3633f] = 200;
    beneficiaries[0x26F9d36D03F0F7EFcDD734566D5247f71935be4a] = 200;
    beneficiaries[0xA86D9D90963728a79B5dbc0b344fe6EAC64f6D60] = 200;
    beneficiaries[0x68F49Bbeb0c838F44C5ae837755726Bc24200AB8] = 200;
    beneficiaries[0xDE45420A0ef778a0C9Df285a58518bEA95f9F060] = 200;
    beneficiaries[0x83349FcB60eB8ef21EE5a19f389f74b5e32f25B0] = 200;
    beneficiaries[0xd59B39Bbe9Ab0616C6678BC7E44bbe9B614B6684] = 200;
    beneficiaries[0x1C6c4B0Bb7778024587F664469Ec1B8aDb34f835] = 200;
    beneficiaries[0xbe2D6DbA42d8ecA78a192C31928ACCA148ef20F3] = 200;
    beneficiaries[0xebf19189049345ab39Ca3735176d81F82a0eF4F2] = 200;
    beneficiaries[0xF1b68B434b73e1C60C281ed3e94747a3619726F5] = 200;
    beneficiaries[0xa1eA4878E72bEA0FCD0017F2A8F1a37443235397] = 200;
    beneficiaries[0x073bbe2ff5D5026D0EB9bE2b7400df8065a3Eafa] = 200;
    beneficiaries[0x36db2Ab3A2E42BE16cD298F2F830A33d4C02754C] = 200;
    beneficiaries[0x43DA7e1c1d2bc565D2ecFc052Fab0E7fb61289AD] = 200;
    beneficiaries[0x49EFd7B6727494293BC778D4785c0A8cdaC909c2] = 200;
    beneficiaries[0x4708348B44A39B26f5C50e6fe6587F415f0D266b] = 200;
    beneficiaries[0x7DB4364291d5A46f510d0e770Aa995E5e8B720Be] = 200;
    beneficiaries[0xf6C1aDD2d4665f63907E3c4359edeCE40E6be9ae] = 200;
    beneficiaries[0x36C9b4ef975fC652485DCfc70a6E7eb4AB71AA77] = 300;
    beneficiaries[0x93f263bDa652E5061386284A7d3b6Ea0cDD27852] = 750;
    beneficiaries[0x27Fc7Af5f9B8deC2D54583baa92E68f4972b897c] = 200;
    beneficiaries[0xa01dd79c6A09CD5d51278dba059114Bc2Cb5eBCe] = 200;
    beneficiaries[0x4B0C7009D8A79B32DF8EA0458C320c3CcdB2D4f4] = 200;
    beneficiaries[0xbF429E966C8c64BB1d2E39b3093267C76bD1df7f] = 200;
    beneficiaries[0xEB09921C7ecfd51Cbf0A8C0806Dd2E549f6Dc244] = 750;
    beneficiaries[0xbFDA1E8806E41AFA4cb04ed659C430f0D49915bd] = 200;
    beneficiaries[0xC4Cf5940A3CdAAb6de8193b2b1Cb63819E1d3FD5] = 200;
    beneficiaries[0x3D89d56ee3329F4D3eD7E06E2C6DF1fC12D29702] = 200;
    beneficiaries[0x41557da6b1d7FE8f7065f15FC1f3bBaBE3fBd199] = 750;
    beneficiaries[0x906C0CCf85318915A46E0Ce0a23c7043301B1856] = 200;
    beneficiaries[0x26BA13D38DD4A58249d6E0b70B218ebF58589f4D] = 200;
    beneficiaries[0x3a277C69C5d41828EfEb4A13Cd8394854595Bbf2] = 200;
    beneficiaries[0xD103Df6eC77e12f005aA5139c3b08A60B01036d6] = 200;
    beneficiaries[0x23B8733E1D487e46C235783722e748cb3044E9e7] = 200;
    beneficiaries[0x3E7Cf6bc65831c6326B623F3B8E91ADF5a2662eA] = 300;
    beneficiaries[0xFeBaA323e6e56ca00Fb2F4C250c8B07463997D62] = 200;
    beneficiaries[0x8EAb3F4c0C5dAa4B297919c424bed43590670b0f] = 200;
    beneficiaries[0x374Ab0e4acA169707744F67C82d4e65e644a88c3] = 200;
    beneficiaries[0x658F00B0b6a1516b896202D1C86b883C467F6D59] = 200;
    beneficiaries[0xC9DCc8fa9ff0FaE9e85d7279Ba04B16f654C0c70] = 200;
    beneficiaries[0xf56036f6a5D9b9991c209DcbC9C40b2C1cD46540] = 200;
    beneficiaries[0xa88bD8f41C6257dFBEebD1596bb9aC28fFb8E34F] = 200;
    beneficiaries[0x192fEc3528F5e81f798F65D2e0bCF7694C322Ab6] = 200;
    beneficiaries[0xb87cadd528eA72d7Ca52c2FE23618d74C5fDE764] = 200;
    beneficiaries[0x7cE1B74fBCfE8454cFB79Fa0c00BAD3D29455d98] = 200;
    beneficiaries[0x0CAbC2e952700Ba7a128d331c7c3a3BcC1eDE238] = 200;
    beneficiaries[0xa845b9C214B4e43EB1F436Be937D4cFf69B05837] = 200;
    beneficiaries[0x9FEBdB70d953275A80231294A0e9f488AcF043eB] = 200;
    beneficiaries[0x81D8c125AE5189c279AD7118fe965f964e815631] = 200;
    beneficiaries[0xe879DE0212972dC34cf32923c44CDaBb8d76d8FE] = 200;
    beneficiaries[0x8c6dF2fD469F88bC5c214e37bd2F23851f96809e] = 200;
    beneficiaries[0x57EDad71fe71FAbFB7F3E7890d6C8068848ccD84] = 200;
    beneficiaries[0xF06f0B09f7B21b1ac0B6e6726f649Bd1fC227E0f] = 200;
    beneficiaries[0x914e5Ba5cD3039A658ca0b2bb047b8244e50F595] = 200;
    beneficiaries[0x4C6c7c98C51541f51dEAB94bf775961E3d50cA3C] = 200;
    beneficiaries[0xCd4A95Ef8E9DAdDFdfa71623Ae2b47C013268F13] = 200;
    beneficiaries[0x74F3E94c530691392F17c830f118A02ff20b83cb] = 200;
    beneficiaries[0xF5E72000fbD407CB7c91b87b76FDf1dcE8396B17] = 200;
    beneficiaries[0x17508f54576C821175fc5113855698B3C6a7690F] = 200;
    beneficiaries[0x1024C1D406d2833369C089FB7ED5146A7338D788] = 200;
    beneficiaries[0xe222e11129A5FEfDEBcc0572a10A6dEAcc35E6C0] = 200;
    beneficiaries[0xf27B173b8B24561f040e5Efd37b4ba28Fd465040] = 200;
    beneficiaries[0x9611925D2f413B19A9a1e710e3A1A5828a20cfCf] = 200;
    beneficiaries[0x492484fB65d41B49696Ec1cBDe26cE496E9bc3c7] = 200;
    beneficiaries[0xD578b651F7e088861229CC7E7178E57a5F674d3e] = 200;
    beneficiaries[0x60718c1430f8c770182cF79F5adBBeE8D4d96dce] = 200;
    beneficiaries[0x0bF98720Eb6Ef66968b1Db120c31335f13DF94F8] = 200;
    beneficiaries[0x902D55aAac9383144E691c0365fBb932C5b21e21] = 200;
    beneficiaries[0x25bA6BAE41925a71209C2fCc20f0aE73de980C12] = 200;
    beneficiaries[0x346e8013652f09e351619Adefa9b73338501a113] = 200;
    beneficiaries[0x1e7c4a7Ec5eE819c6d1DB0C10015b73832752A41] = 200;
    beneficiaries[0x9DC6A59a9Eee821cE178f0aaBE1880874d48eca1] = 200;
    beneficiaries[0x28e672a29A5a059f5e7b84Ef3C11E4D1019AC540] = 200;
    beneficiaries[0x1D0676ab90E684E9c70c96a8691c2c993eEc2dA8] = 200;
    beneficiaries[0xcc01F6b833977DeECA15B1D2EbE294499890634b] = 200;
    beneficiaries[0x08bb7B7F7CbE2b06A0251e5954af2204862A02aE] = 200;
    beneficiaries[0x3B1aaD97c533380ACa455Bd00365E73Ce44Ec833] = 200;
    beneficiaries[0x7996151C69f93CB2895d6e75C827a8C9116db636] = 200;
    beneficiaries[0x64aaaBE41689B60ed969386b2D154e3887f628F6] = 200;
    beneficiaries[0x0b540972DA3097C9f7FDBE62c45e4D1900719E04] = 200;
    beneficiaries[0x8468c6Efa8ca7ffccB2C31D112e5e9331A469867] = 200;
    beneficiaries[0xBe38B0357bd98a7007A18207c31409380a73e411] = 200;
    beneficiaries[0xCc91ae31e938459212E14Fcc3A6189272fC79636] = 200;
    beneficiaries[0x3A712cd5783D553858377442175674eD788f7f1A] = 200;
    beneficiaries[0x23bf8e7eFee938A95dd67950cC5DAcc3d3b62e9A] = 200;
    beneficiaries[0xeD90796a4331b82df318D7996E1603ddaaFE33F0] = 200;
    beneficiaries[0x09A98b8b15c9FADFF8524503768479B26eDE3ec7] = 200;
    beneficiaries[0xd91A5d90f0846eE3017d0D2B19C81F6c5A7ADd02] = 200;
    beneficiaries[0x61283db5f61915eFB4fE2D0aD776520517cE13b3] = 200;
    beneficiaries[0xB018AC68Ae2979650F8482D1F92B12D4Ad268948] = 200;
    beneficiaries[0xCAb5068F0Cc1278D29233D2175682082c3559f4e] = 200;
    beneficiaries[0x2DC8aD93a8fa55F410D4cB59be7187565f25DA6b] = 200;
    beneficiaries[0x0b18D03bC9bC53115cd5BC042ADef176CBec9B43] = 200;
    beneficiaries[0xb7912896a6bc5d94997A8F429Cf474Dc19C8E113] = 200;
    beneficiaries[0x3357C8Bd2EDEb20D2781125De2cC68E5232B376c] = 200;
    beneficiaries[0xE53ddF0EE1Ce5Cc21ea14dC4445DF9E26326d6a7] = 200;
    beneficiaries[0xf1eF5E5d48641Ca6fA9bfEdB008624747826b210] = 200;
    beneficiaries[0xF44217A8b6b3f258BFFEaD635c226528aa516aea] = 200;
    beneficiaries[0xea9C9647399901F5482D8d0C87Ae9D1A7A165745] = 200;
    beneficiaries[0x5712Ec69B1dEDf934303cE530aE2b4f1D3ca4c61] = 200;
    beneficiaries[0x1deAe228C77A25148D4f5b6033e53b6d941207Dd] = 200;
    beneficiaries[0x75f58030c190bb4288f56100F0Ee49B6EEb4A134] = 200;
    beneficiaries[0xa87dBb982008E26f3Ec39258dbB69344631274C5] = 200;
    beneficiaries[0xFcFA6885830f508f6eFb78bDfAd1e299CB56D022] = 200;
    beneficiaries[0x68499F41c6b020EF1F33da86E5D7819d8ABC8928] = 200;
    beneficiaries[0xB032ec905759B464A75EBbD41703CCcebAE77934] = 200;
    beneficiaries[0xA3aa6e119a42b5f608775360984D3721F12E3f2C] = 200;
    beneficiaries[0x11B1785D9Ac81480c03210e89F1508c8c115888E] = 200;
    beneficiaries[0x0B8Fa0e33997038a05d78CCE8E1bdFe8cfCEcdef] = 200;
    beneficiaries[0xf0a8CEA0DE817eec61b4d27456CFB003167E8024] = 200;
    beneficiaries[0x335147a6afcFE1136d9341c9a264F4A69616AD7a] = 200;
    beneficiaries[0x0f5FDA152d1980b868506797bE399eF39015D544] = 200;
    beneficiaries[0x8ebcDeb6A47f65dEA41A3853B822BE0e4b52b78a] = 200;
    beneficiaries[0xD7E17834f4aEf24F732DBb6f0D364ad5FDE9d516] = 200;
    beneficiaries[0xF77a5526691B92078FE9bc01616C5FF900AA0516] = 200;
    beneficiaries[0x453F36DD4Cfcead6b7627472239440984D553d73] = 200;
    beneficiaries[0x62c9D5fB01Fb969A49f0fE590363ad16A5645C62] = 200;
    beneficiaries[0x726a723c9809A3Ca9e4AA536057293585e03A299] = 200;
    beneficiaries[0x809A2595FEd9d8f6D1Df68006A684bAFC8621857] = 200;
    beneficiaries[0x48a6d8A3D6EE913B2942fF28918482733a17bAEB] = 200;
    beneficiaries[0x04858A3a53190D1e1020B349e674Aab5f107BEc2] = 200;
    beneficiaries[0x4918bc5204930b6620728cbc1F7577c54155c976] = 200;
    beneficiaries[0xc04B02A344a20C8689dcb3a30448b9Dbf9197319] = 200;
    beneficiaries[0x8f98Ac169d5f3F9E32b94dB4a7E8F0A23DB54f8D] = 200;
    beneficiaries[0xE45B05F9950D99e4f41c68d3FE445fBF09CE5F44] = 200;
    beneficiaries[0x59B94039429754530807772D2995b6a6c1aB685f] = 200;
    beneficiaries[0x8454E1EE9a5324a291516B95364a929d723B2308] = 200;
    beneficiaries[0xB7C1Ad49AFb0ff0f50E8C57abc605cCE3bf2cFed] = 200;
    beneficiaries[0x8eeFAe59353a1787a62e8db7C9679D974eBDDF14] = 200;
    beneficiaries[0xB235769014bd63de9Ef56995B291C26BA13Bf561] = 200;
    beneficiaries[0x88327A05A2eaa77213EC7Ca0d5B84776b584Ae78] = 200;
    beneficiaries[0x6d89FE3B635049A4846D8Af0c16b80bCDbcC553b] = 200;
    beneficiaries[0xb81ab8a53E09e9c430c736d53D455A99C4F8e9Da] = 200;
    beneficiaries[0x90CA05C876f48a9cA51fE0E81e3181C91a3ae260] = 200;
    beneficiaries[0x8878d2A969CD617cEe9e0549D7EBaf5288464546] = 200;
    beneficiaries[0xD26631C76cfBe45E9822220dd99EF5B4DCc3a5Ef] = 200;
    beneficiaries[0x51c65d26FAaea0BD17C7A40c5F85971871519CE9] = 200;
    beneficiaries[0x755CE5F31617deD6e41D15Cc51D8FF642CE10e9d] = 300;
    beneficiaries[0x8c96C4ba3C4A72D9F0E1603c718f293Ff2C4B87f] = 200;
    beneficiaries[0xb53341aDFc12ad21187157f1eD3EEfc9855e8434] = 200;
    beneficiaries[0x86C0684b6EC2a9bf8E57F102c08c33299C08B13c] = 200;
    beneficiaries[0x8F5d11ABE6cb2bACC743dc3dFF57faDB7e4F38e4] = 300;
    beneficiaries[0x8f49a1E1c14Bd7C7A91C9cBF352574Df08e6bb38] = 200;
    beneficiaries[0x23aE96E06d86b12d8fE786473905a55C332b893F] = 300;
    beneficiaries[0x5e76154A7326fEE1a4C63F821f13e217E271a1bF] = 200;
    beneficiaries[0xa9A3b8807E8490665D5dB3f8c47969c614D9aFf8] = 200;
    beneficiaries[0xCF9a87f76435859Cd3E0029038DB0133C5b61AeC] = 300;
    beneficiaries[0x3010b8ebdFfCC76831574d923A1d80d1A203f11C] = 200;
    beneficiaries[0xaE2Fed09dDF0c088B3db1A840117305AB63C28E3] = 200;
    beneficiaries[0x1808674817f55D6fb5163EBBd068D315B2905053] = 200;
    beneficiaries[0x1151D9EDA4d6415b57851F39894c0bC69134e86C] = 200;
    beneficiaries[0xDc242304bF67909138568378dCdcb2fC4CD1D012] = 200;
    beneficiaries[0xFF051e0561Ad2AeF1fD8a07cF525bA4Ca465D404] = 200;
    beneficiaries[0xb7735A4875C9824e1043Fb80d644e5a5930c6065] = 200;
    beneficiaries[0x5919F1028dB96A108eD4CE18b7EcE118646E92eA] = 1000;
    beneficiaries[0x1151D9EDA4d6415b57851F39894c0bC69134e86C] = 200;
    beneficiaries[0xce485E854eF129D13dc1E25D103412Bd25e97904] = 200;
    beneficiaries[0x06A846E8Aeee62FF64A9cAa2d8daa79Ce95D2c68] = 200;
    beneficiaries[0xDee78ed15436387A45FCE325898f7c58449FBfC2] = 200;
    beneficiaries[0xb12302C971398B5a292D216c308db50F32EE769b] = 200;
    beneficiaries[0x30f93cd7ee2A2C13dBC5FDe3d1ed06D4bE0f12B8] = 200;
    beneficiaries[0x5Cbc816bB51d8B46e9DefAeB4bEbe70F3899af59] = 1000;
    beneficiaries[0x795fE6F884eB7599abfa814aea3Cb8d0B3CC47c2] = 200;
    beneficiaries[0xA9405926aA26D16E5Bfe3B24Ca905D8B4d0A6Cd4] = 200;
    beneficiaries[0x2492A8400813764952c89a88232F1221858D9C10] = 200;
    beneficiaries[0x655F8D053AA2770Fe86a1b839fDFa40B9e8d5aC4] = 200;
    beneficiaries[0x58A3505ee61F90BD5fBCf2abd889Afad46B69d3a] = 200;
    beneficiaries[0x99998044C990dAe1c8218c78F3470E14D5D491A2] = 300;
    beneficiaries[0x4143F535c06d72A1B73a6AFF971D4f21Af435444] = 200;
    beneficiaries[0x9E2Bea982FC97c67bf376C70011E37Db6CE64EB5] = 200;
    beneficiaries[0x852eE519D3cD3a55bf16b9B500F04DEA598a1772] = 200;
    beneficiaries[0x7E43CE9899999A97bce6F6b1e689a66111069D3B] = 200;
    beneficiaries[0x6FCfB789a593762557177Fe9548E44d166F91eD4] = 200;
    beneficiaries[0xc1FD551F72220E89deF36DE9d59D32E766E609d8] = 200;
    beneficiaries[0x5EAfd2E4160C8d8B06cD220DDab2163369884583] = 200;
    beneficiaries[0xA34c8558B22bcEd464a4c0cf222457bDC632D1d8] = 200;
    beneficiaries[0xBA6feD04195b466ac0921927E1c899AC134a06b3] = 200;
    beneficiaries[0x184cC5908E1a3D29B4D31df67d99622C4Baa7b71] = 200;
    beneficiaries[0x0087a081a9B430fd8f688c6ac5dD24421BfB060D] = 200;
    beneficiaries[0x92156573daC216BE021A1A4F467121be92991D73] = 200;
    beneficiaries[0xFd443CFD21172cd5bDA7B754C2fB64819EFA74F6] = 200;
    beneficiaries[0xd03A083589edC2aCcf09593951dCf000475cc9f2] = 200;
    beneficiaries[0x326A0Ad4Ee7A996Ba15BC42932aEdAB8AB9907ba] = 200;
    beneficiaries[0xAa52C4d4A54118BcDe22a4d64aaa95Bd92E86B54] = 200;
    beneficiaries[0x8017Ff21bc4972d84a4dfFf2141517dAeFD0c256] = 200;
    beneficiaries[0x945D0f44ADd439645323Ee6dAc2b64ae1c0C30F4] = 200;
    beneficiaries[0x2eBDA071d7927EA702811E20d88f3364e1e21AF5] = 200;
    beneficiaries[0x07726d7e4ed80c8C64a8dd27e64F876Bd4225744] = 200;
    beneficiaries[0x11b6b351535e7b846d8300A7E0bF2e9cBEb47DC3] = 200;
    beneficiaries[0x897853510D7fb160045122934110a3197E0DF2DF] = 200;
    beneficiaries[0x6eBe0A783cF353d0233d1C48f126B42f14fFB51C] = 200;
    beneficiaries[0x8AAc7249D573a12664A4d6667D8869756B9eE75e] = 200;
    beneficiaries[0x1a0A1b98884491d3f977d0328Ee93fA2739b6747] = 1250;
  }

  function isBeneficiary(address _account) public view returns (bool)
  {
    return beneficiaries[_account] >= 200;
  }

  function claim() public nonReentrant
  {
    require(isBeneficiary(msg.sender), "404");
    require(YLDToken.mint(msg.sender, beneficiaries[msg.sender] * 1e18));

    beneficiaries[msg.sender] = 0;
  }
}