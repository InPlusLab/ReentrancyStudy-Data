/**

 *Submitted for verification at Etherscan.io on 2019-02-21

*/



pragma solidity 0.4.18;



contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    function Ownable() public {

        owner = msg.sender;

    }



    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0));

        OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }

}



contract ERC20Interface {

    // Send _value amount of tokens to address _to

    function transfer(address _to, uint256 _value) returns (bool success);

    // Get the account balance of another account with address _owner

    function balanceOf(address _owner) constant returns (uint256 balance);

}



contract Distributor is Ownable {

    ERC20Interface token;



    address public constant tokenAddress = 0x67bc56cAad630DC1719B14A540Adc8e9968325C3;

    uint256 public constant amount = 100e18;

    address[] public arr = [

        0x98752cb375997293d84d82306ca07a549ccbc82f,

        0x854674cd485483889b15bf38182e905874d9ce00,

        0x1d73d5bee9b66f327fef3116f8aada575ebcd471,

        0x525b904a65305bc543f8442d3fdfb1666874a212,

        0x676b24bec734b77594bfe87388a0ac97b001040c,

        0xf4693941bdfe1ff553ff6310ddb68f3ad99628b3,

        0x523dea329c45eeeb885edebe89bc922ff84a1402,

        0x1f5e4d28e44b2c93865ebda1c26acb6e963a23ba,

        0x9d416a2aed9e1fb60b2c0d37c66320bc5e0a3d88,

        0xe63e4aaaa476269d012093012e4347176036bbfe,

        0x2429873e55a9c38884e7490d341ee3e07846db82,

        0x1ac6f654f7c2b5571d7416d7eea1c6389636409e,

        0xaf2458a6604c490676eaa1c2436226df1e575fc6,

        0x0b4609318a960a52b6cde1e7b5e2bf8ebd7e5775,

        0x7fa616a97bc378cec0b0a9c5f116a20eea5256b2,

        0x7304f10047ac45464ee4a4ed9cc3cff4b8fc9f32,

        0x9e7c15c7e24eb066d74392b702b7b6b68e954cad,

        0x2a6e2c853d5b0b051221bc3f609b7f4a57c9a3da,

        0xa6493a8fb60beb6b2edc9fc8eea842af11da22fc,

        0x036ee2efd3e1f3673ab9cc8da1dab1f96611ff54,

        0xee7eb825e14946461916f11e2c09d1fdf7b04bb4,

        0xcd90648b08d70d2a0d57731ed79b779953f2bf22,

        0xff757b9ddaa451cd6b2c3095908bab1ee9d9f48e,

        0x40f24df773d42c1d4f52e2a0a2e65c8b38cde8f5,

        0x8d97885c76cb9f6a0baf35544737800c87bb335a,

        0x2642e61683da3e3c9e668d3db8bb3ddec42f170c,

        0xcec94127e0fde533b49b441c170e3744a7be31f8,

        0xe389ca25a76145adc601eae0d891b35c4c5c4944,

        0x4ca089cf26af9546b0b82567a7e53099abdbee29,

        0x4b3c06b67f22d4e92883b04e5dd73cd84711f9a2,

        0x09B7B0160DaAac135fa37b4B3f0F270aBd50255b,

        0x363b2ada391edfb83f3efa6a08d65e264ba92b59,

        0xdc1f300fea680fda56b4a5d9c9e77cda1e15ce26,

        0xa8bbd30d0ef1a0eef20b329276ce0a4383762019,

        0x1c86883d3c396b464dc8c4fccda15e633edcda88,

        0x41aba30e0aacac1ab7bae932bb9aa0e40d8c8a5c,

        0xe8be42526145cd5e94c17951ada23980651430cd,

        0x5242b54ff227480734816b32ef70538386d07de7,

        0xacb31061e919c6c29a4fd54fc2b537e576f4c5b3,

        0x64b610141279363906b96d69d2d17bf89296f86a,

        0x3d8aa707c692b81c011d45aed8be6153f6f35327,

        0x4786d725c2091b5f4557a6857ffaec3b96ccce3b,

        0x69b98110d5a3205a0813adbb280af83db54eb3cf,

        0x7e37a2ea026a4d8803830100a35556821aaeb2fa,

        0x87e166306d5f55678d37853cddf109ab902ba798,

        0x95d121d1f8ffad4a804782a6a9d68b488b7e468d,

        0xe18c74828a09d71776247f8337357b5fa76ba7ab,

        0xa96e7974a8943c6c8736aca8c8e1ff6c1c657ef9,

        0x7141f037a6faa3d27d699d1a0afea19656c94bd2,

        0x89bb211edbe7a994356c759300568ce630314415,

        0x1aeff90f0082e674ea89b4a38bab0422a87d7461,

        0x4118c27f0531d96800fa5418b5b714300976137f,

        0x93b665d4c723dbbd1ba2d899283773ca1c26dcd8,

        0x0298eea87b1d003bdaa63b88090461af5350eb87,

        0x557a06fe167ff5432618e1bed6b2787a4718b20a,

        0xbec0d2984aeb29cb6466096832d7b14c0650f74c,

        0xd347f8e395f9175b605bdbe8e736c8921ee4170f,

        0x9a3b6676d43eba8715502e270793a1e5ebf2beca,

        0xed3f9e1433c6e5a198e9ea49f7b384f884031b9b,

        0x0ee6f3744b81d3e44adbda44ebaa86c59ee45ba8,

        0xd62ec4785d215fa038806d47d4fea55793a12e44,

        0x171f388d8b0b0b8dc0f9559392dba8276ea4a0b4,

        0xc7a7abc49b17afa0f336e797e936f28daf88ebe9,

        0x328E65fe6044c62abc618d95cBc1C4202A615127,

        0xda4775803adf167cf6217c11bf3abda609fe1aff,

        0x63f04a47186e6f21bea8a5e314bec9309f8c562f,

        0x566e2afcc5dd7149cd673fb129eda6a172a5ccbd,

        0x32529fcccf79757a5e9e36196deae7948fb8a865,

        0x159a47477f5e45f7019fd1b4d8af6e4e28a300c1,

        0x5b3c0a217c406e8d07e00fe261f5ba2689e3ee09,

        0xa15831ecff347fdb36f9954805473af9fde8224b,

        0x764edf5b393c11d213283df58ca00ef5d5ab2696,

        0x0e76cd00a9d2b02defad37e870b694e265d1ce67,

        0x22754795084cd334fa70686e78587b3e09532de8,

        0xfa002f9e92447811949f0d4e445414d90545fd1c,

        0xd7349c9f9fc44f5aec596cc050ef37c9284bb17a,

        0x4facf1678fdcd7bd4d84ced4fdbfb706f3908f14,

        0x661bcf2805f42faf3519ebc0c7be277e28652419,

        0x5144cfd0c1dd023fed98aa3d8d99e8961fdb3266,

        0xaa7bd1c11dd623b5de2f3825a2ffcafbcb912c88,

        0x5da430e5d8ae9e3bee803e1d883ca96b068b3c2d,

        0xc331f93b4899b39cd4be76df5c29933a34f47546,

        0x7d3dd457b5495c316776dcbdb623e86809b287f6,

        0xe837aabb4673d41409d24eb9d8aabc87fdf7b492,

        0x92129f23579d11bf1e0b56a2afd27b335253029b,

        0x2af6901eacebc4f3d1dcb0b85de9ba4e296ce29e,

        0xc990be8b6c265792c85a1edef88fe0865a43db65,

        0x566c1388c62ca2501e626e4915b4db2f44484b3c,

        0xefc54b58b3fdf7bd7554b6ac3cfb9f026d6ecd59,

        0x3E7F93ef5BEa25278fbe5c00d99550CC1d56Db5E,

        0x10b8bc869684cc400a3606a86f32d62cb7a7ca7a,

        0xc38ce60c2452b621e317e9cf7398c79b8320223d,

        0xC48f869247aD3abA7647042C246141624240Ff2C,

        0x3e5c04c7d850f3ada7bcffdfbf96d005560db441,

        0xda75a69c2a6c70c294e3eb08d469f92b6a830b10,

        0x465826faf4f93736737318596cfb84509f49c79e,

        0x181f3825e3e51b50a8be8f0aa6c06bbead89ce22,

        0xca4ea426c373c28868ed969bfa510ba0b28e6d53,

        0xa3df872b4da427acca09cd1978b29a51eb147a42,

        0x1239d5bddbabf1b6e75fa84dc674f4033ce05243,

        0xeb855692aca4a78b52c9654a16817742d9bfd954,

        0xdffbeed1cfb32473a3ba2d668d54f76457967ff2,

        0x12c014607fc2d3e3b326c6c85f300ff556ec5072,

        0x0611f410cd6c881f7b5827ab997197a0a40b69b7,

        0x8ff83dbb9b9867f297c110a09005bf2d334e82f5,

        0xdd641ce48b65c551d4ffff6a6e5e0fc86772a356,

        0xa1b69fd49877045d49670a772c2b64d1c6c48f91,

        0x2b88e6beb210ebd0201d7cbebd85e39e4660e794,

        0x2e64c5cbcce2ade4389fd0fd90b612f1c0be3202,

        0x9a40df7b9d75cab81d438fcb7001d66f47d637ce,

        0xe76184092ea7660882f867cdd4dbd76337e47071,

        0xeb4a321d678b9643e4bfd294a3d2a1ca3aff41c0,

        0x152d92b9613e676d060bad091e4736d01ae789c0,

        0x649ab390e3de3c30917a710688ddadb3069c1c9c,

        0x4e225fcab68ad608529a777fc979d378df6d785c,

        0x9cb12fdaddbf502c8350a549ed7a415f89484515,

        0xcb88c7e2502b7596e6e88dfef32bbb649d718caf,

        0xde3d6061202e03e2eE2E684316E2d7Ab36E59454,

        0xA7300f6ABf11Ff569234866BF734DE7c3EEB8308,

        0x456ff1b58606a429a303490410bf25854d528392,

        0x9b9b8a4cd73530acea8c4ef3d328648732adc123,

        0x15233af663cd72f20ce2922deaf7a904bcb32493,

        0x2d1380ff9e422a27e173abacae077b3ffc326125,

        0x4f9a18130bf721b73c114396395c00c0d06bf53e,

        0x11cc7b1edc9190f461b6da47ea21b48975594e6b,

        0x76e26dd4ec2b3d992216f4af5dfccc08fae80c22,

        0xfefcb494c553e87af14933a1c0cd1af4e1bff477,

        0x374a22d3a1d4b71e3fbb30d77cd8110de7d7c237,

        0x5b7da44a5665b9f25b44ef956e422e9e6bfeb435,

        0xa6b6bc476470e2607746fdbe8d530a0437b213e6,

        0x0ac62606742022189777867f5a937dbf900c57ce,

        0x3c9572fa74b0e67db04c413f79f24aa017d7d88d,

        0xab78152fc2d6bc56e7b2c7e57c698db7948c1061,

        0xdf70d65622a58bae119f48260ead035ad92274a3,

        0x8cfec33e801fe592e27315dd9aab7c8e3f5464d4,

        0x45fB837e28A67Efb711Bd8d195B8A5BBf32529d5,

        0xaec7068970e795bf5dd0e58162ceb2bfaad08fd0,

        0xa032576281515159cc09ef3b3a0bfd514349fba2,

        0x9c2563fdde8021bd8107f5a65165eb925691703b,

        0x054adad4ff7d303f831de65c77b83b24bc7c6318,

        0xb0ca014721fc9156ce1fb41459bdf33f4623b107,

        0xd41cd26e44bfba5f60424e051d8396f6c679485d,

        0xe1072c272d16700f676aa8238fe8e00014bc4dac,

        0x14d4d0e898691f3f6808e3b0594dfec1a9c93b97,

        0xf8d8d0634cf8c1c7cd664914ef5f7bc9fd3de317,

        0x351412d9e8a97524ff6b5bf357ebff7ec32d8c76,

        0xf47f5bc81e363f898c799f8c84a195e9b98959e7,

        0x679acf9556b74c8b50f64357e37224b382daa7b3,

        0x1fce07fdc88e4a5108ca609a2821e446c37ca1f9,

        0x6ea478013455900dcfceebc35e3ece6017afd3aa,

        0xaeb09e57b66c1b35d06f34e679b468e738105c51,

        0xd325faea1baea28542ca84cdc062f2a6f9be369e,

        0x90292b8074642146e22c0369993b3f2d75dfd2af,

        0x9d552c6af170eee8dcbfcbba7e5bef71384d7816,

        0x8E607Ca41096021C2da81Cdf85f3b4Aa3cBb3827,

        0xa3174cb05f8522b6ff5345434687df67feacc7e6,

        0x6bab3996a80a0ed3890138868fb14efad5a2014e,

        0xef5a775e51b3ff4c793b2c3d69ebff72780d5ab9,

        0xbf4615a1eb6e73f70b4f77cdfa3ff15ef196f0ea,

        0x3de49d994b098108565b2297139266d7d003e8fe,

        0xC2b96B0e1A38673a1a888bA5D674D888eb23fAC7,

        0xb434df7f8efd66ac63b656e9c0c7f63621838d03,

        0x559be9592abaddd80749ccc4de6a9bf5b8bf43ee,

        0xd65f5964b963c7d1f041657b29e4d0922c26f633,

        0x5e5162c3ef7300f089df819355cb58d20210a3b7,

        0x12725edbfee5c60fe06b1bac3fe1fcd6ce0ad483,

        0xb07686d90167b33cc1dadc270b9c68e6fbf4b827,

        0x120a98ec0f0a868559d901a04b2ddc6429f74a70,

        0x291b9554364050451593380f3b1440fdaacab2b2,

        0x59045b5216571c613ee9a89b304810d3fdae8638,

        0x6ffbcb395a6ecd6fea931243c2fc0b01d40b69df,

        0xE5ACf0aEca89a2Dc03eBA7a11d2d5f4a26A6D255,

        0x0f32efa03216a3f12403c49630a33f6d49233de1,

        0x9cef816dfc15a3ac800190b4efa0e4b1ed601c13,

        0x9a055412267ed7e6a6b584a3e8478ee6d8e719cd,

        0x981fad94ae2d9ee4efbbcd619984c7a3bd8bd402,

        0xf6ad605ded548a1f9a6d1ae1efe9a45be58b24ca,

        0xf5685e1649ac728b5ee054580a907c948aca5886,

        0x9dd18fc6be91a1e32db6cfef96d078920f3553ae,

        0xc7aa495f30ac9a5b9852c08b35beafe8508c6494,

        0xe82d4E48f06BE0EE726E646E1eCAFE5a6388a267,

        0xc11bd6cbe74350c0877403323e8e927a98b365d3,

        0xcdcf4c61796ec7476bcf3852aa7413abc52ac858,

        0x4C40E6182751Bf4636Fe106BB98Bf0D75d8cFD2d,

        0x76dc5bac81aaf8f13fbb9242a62f780d6711a72f,

        0xa8c95A177091864BfAE674ffaE17C66C5d83d06e,

        0x3a6f47322F2b32C3836652De6F259FdA1170C930,

        0x4647c5b897752e77598f2c6b2535df5da2973240,

        0x1bf2772672111c29c70870f0eb183b575efba7b2,

        0x699553bd5905bd1f337787dea9a4a1c6f71ec91a,

        0xaced6d288cf9073a9f0e3da9d40e7ec031dd553f,

        0x909eced1d60637a9f2ab0f015c7a0c51bea61904,

        0x1b927fdf788a155dc19e44e0b9532d36219c3b91,

        0xa7832e116056207c6b5edd2dbe0461282253307b,

        0xf894e1fede773471f9430209f81d266f1ab84a37,

        0x05ebbe952c623c77a82458504ec9487e57786962,

        0x4274224f4c130ceaa2d07bd7fe16fe50ca90f58a,

        0x73bcb0761cdb492910ffa1ae2d63bc28fb22411d,

        0x69500f01f62b4016294289c38569c0349cea9b8f,

        0x79ad10fd0653979fd6495b734b531754fd4e7554,

        0xeeff6762fc33d3d109421d6dc57da16f2895ef69,

        0x20d8245fc45c7066fcebd895b2802d502546627a,

        0xeecff0d0c8e9535239955a3fe4f715fa8a9bf00a,

        0x63aece0d41c939603d9f82d2ef4837295e5a03fd,

        0x28210d16c044ab77cfdacea6d701e9c823029327,

        0xf5eb0ff8e087a3ee6f9577392a4324afde337b7e,

        0x8a19d167978ad089543637e938c90ba064bc2692,

        0xf9ab6e9e7d46174c959b12e309c1cfb81f509bad,

        0x2c6b24643e50349371535e33b3646b87c2de1b67,

        0x42db7a960e189d9ddcace91909ada5960925e391,

        0xa1fcfa3b6614090c924ed45cbd31f0cff0306f3b,

        0xdd3466815e34336ba2035f89e3528eafcbe482b5,

        0x85bb56be712adeaef83db23e21b875f037b2288b,

        0x097b43ea82a85ad51e8af88e81049975709ee6e6,

        0x9501bd987c8e68f525ea8d6889296c27a9198033,

        0xc914aff51dc7509f8f635db05a91e96bccca414b,

        0xfe8598f7d6e98d8611f8fd637563d74d69c0cd05,

        0x2e47cb9cf71ea65280a4d3b21ceaca47cf529789,

        0x122efa357e962dcd0f5658fd3f6845376a8dbb66,

        0x45df5a073385a202caef81f3634f4ddc7c4e7d0f,

        0x81873f65dba71cb7fa3829664df33f97ecdbe26c,

        0x4a73ed6323e4d25a96571021b9c00d8221543733,

        0x809454247f019ec403554dbac62994f89c30a5cc,

        0xc95e4d3a7e9671908a676a1cdfae5e211ceca8a0,

        0xa60577509e85d7861c38e4995e8446a44361c341,

        0xcbe3e2dbdee319436e75d25015501b69b84d0091,

        0x4200610b4882a4695c2fce87a743739dd074c1f6,

        0x7504c207d2db6d3622c670c3fa08e6b20ddfa8da,

        0xeb4da312fb8b971708563106f9cebbf0c60af78b,

        0xd7863d5953416ec03552bd5ace8f5a2c017da3a4,

        0x5e9337f3a2564b52c80938b180e713f0568e0598,

        0xcc22ab08d428acc476535c408541c9672c85c07d,

        0xd4f3b72bb00e7e6c93ffae90bac8bc2933963005,

        0x209bfe701a95f6e4b2addbe15481806661299c95,

        0xe0163f2ff7281a425a55fdddff583ab6d9c2b81e,

        0x854c9c325523c8cf51968dfd8703f1a961680d49,

        0xfb492e747113330af2a9cfa080c776e69a1100e5,

        0xb492b94ee395e660777f1e02efa09106fc63f480,

        0x86fbe09a392f8f0ee2beb28c76eef52f914a2b53,

        0x94fa1e396bef442e0ec15186cc7721f2b495b361,

        0xc55f86b70b92d2b1ff98fecfd41e05ac7d5c11b2,

        0x37587013586c5cde6a3bce49e7158d2b50cb64e8,

        0x0b92907853cb71951fc56e8f23d26b7c6ce63496,

        0xb14076f236b2015d212b979e95e65c317414575e,

        0x6d80606d6bb418514266bee24926550ca7968a5b,

        0x7e3d75fdef6bdc3557d47969cb4176c67d0d8528,

        0x84194bb3def01c6da4b2f597f826db885125b70c,

        0xc41e59f659218af0fe32e7a4dfad89f89e7e27db,

        0xd22174fc01bc0cf8fb336ac545d345b768ca9174,

        0xf323ccc676b28985ba3194e2e91a80680e23392b,

        0x5c18ec452e7fe3649489d550bd8d396579937770,

        0xdce8766223a1830db75975c7c83d611cbfca6cdd,

        0x2825f3f31c37dd77bb7cc10185716b352cc9ffcb,

        0xcdd8a57be8805c00efb9e6a457cc45e1d00ece0c,

        0xfa2ca3bf38a244f223d6d0d4fd68be99c03ad904,

        0x2677f931edd79282abfdc57a1779bb19ffe2db1c,

        0x4ef20b3b2e587d7900e3a27a23f67d0d29e997be,

        0x77e1de76205c9464edd9dfd23d42914380ff0151,

        0x11da1e34cbb6c516f86f1ee1017efba126f4413b,

        0x6c5a7c25cfd59861c6d82d38c632a3263fa4ef30,

        0x0270b488c88878ffd5f55af26d680195de816951,

        0x56dd905c3628d98c39bc3cc024e0cc359cfd30ec,

        0x4ca628af59164b871f967c0b5399aff45ccafcf4,

        0xdcf025fbb7abd462b66101ce5c25c83f63cdc19b

    ];



    function Distributor () public {

        token = ERC20Interface(tokenAddress);

    }



    function batchTransfer () public onlyOwner {

        for (uint i = 0; i < arr.length; i++) {

            token.transfer(arr[i], amount);

        }

    }



}