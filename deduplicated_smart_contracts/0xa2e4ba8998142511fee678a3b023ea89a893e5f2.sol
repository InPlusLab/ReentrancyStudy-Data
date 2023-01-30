/**
 *Submitted for verification at Etherscan.io on 2020-03-08
*/

// File: contracts/InternalModule.sol

pragma solidity >=0.5.0 <0.6.0;

contract InternalModule {

    address[] _authAddress;

    address payable[] public _contractOwners = [
        address(0x16F2F7eaC61e53271593C6F0BF301afb62837c9c),
        address(0xB3707f6130DBe9a0EceB1278172Dce9B0c9a2EFB)
    ];

    address payable public _defaultReciver = address(0xf2B64c2fFBD458cCC667c66c0C4B278A88450a63);

    constructor() public {

        require(_contractOwners.length > 0);

        _defaultReciver = _contractOwners[0];
    }

    modifier OwnerOnly() {

        bool exist = false;
        for ( uint i = 0; i < _contractOwners.length; i++ ) {
            if ( _contractOwners[i] == msg.sender ) {
                exist = true;
                break;
            }
        }

        require(exist); _;
    }

    modifier DAODefense() {
        uint256 size;
        address payable safeAddr = msg.sender;
        assembly {size := extcodesize(safeAddr)}
        require( size == 0, "DAO_Warning" );
        _;
    }

    modifier APIMethod() {

        bool exist = false;

        for (uint i = 0; i < _authAddress.length; i++) {
            if ( _authAddress[i] == msg.sender ) {
                exist = true;
                break;
            }
        }

        require(exist); _;
    }

    function AuthAddresses() external view returns (address[] memory authAddr) {
        return _authAddress;
    }

    function AddAuthAddress(address _addr) external OwnerOnly {
        _authAddress.push(_addr);
    }

    function DelAuthAddress(address _addr) external OwnerOnly {

        for (uint i = 0; i < _authAddress.length; i++) {
            if (_authAddress[i] == _addr) {
                for (uint j = 0; j < _authAddress.length - 1; j++) {
                    _authAddress[j] = _authAddress[j+1];
                }
                delete _authAddress[_authAddress.length - 1];
                _authAddress.length--;
                return ;
            }
        }

    }

}

// File: contracts/interface/recommend/RecommendInterface.sol

///////////////////////////////////////////////////////////////////////////////////
////                         Referral record contract                           ///
///////////////////////////////////////////////////////////////////////////////////
///                                                                             ///
/// Record the referral relationship between accounts, including short version  ///
/// referral code application, query, relationship binding, relationship query, ///
/// quantity query and so on.                                                   ///
///                                                                             ///
///////////////////////////////////////////////////////////////////////////////////
///                                                          Mr.K by 2019/08/01 ///
///////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.5.0 <0.6.0;

interface RecommendInterface {

    // v2.0 unsupported this method.
    // Bind Referral
    // function Bind( address _recommer ) external returns (bool);

    // Get all recommended addresses list at the level
    function RecommendList( address _owner, uint256 depth ) external view returns (address[] memory list);

    // Get my referral
    function GetIntroducer( address _owner ) external view returns (address);

    // v2.0 unsupported this method.
    // Register a 6-digit referral with uppercase letters and numbers
    // function RegisterShortCode( bytes6 shortCode ) external returns (bool);

    // Get the corresponding wallet address binding with the short version referral code
    function ShortCodeToAddress( bytes6 shortCode ) external view returns (address);

    // Check whether the address corresponds to the short version referral code
    function AddressToShortCode( address _addr ) external view returns (bytes6);

    // Get the total team members of the corresponding address
    function TeamMemberTotal( address _addr ) external view returns (uint256);

    // Get the number of valid users of a team
    function ValidMembersCountOf( address _addr ) external view returns (uint256);

    // Get the total number of ETH one address invests
    function InvestTotalEtherOf( address _addr ) external view returns (uint256);

    // Get the number of valid users one address directly invites
    function DirectValidMembersCount( address _addr ) external view returns (uint256);

    // Determine if it is a valid user
    function IsValidMember( address _addr ) external view returns (bool);

    // Mark one as a valid user and write to the level contract, and record the total number of ETH this user invests
    function API_MarkValid( address _addr, uint256 _evalue ) external;

    // Bind recommer and register short recommecode
    function API_BindEx( address _owner, address _recommer, bytes6 shortCode ) external;

}

// File: contracts/interface/turing/TuringInterface.sol

pragma solidity >=0.5.0 <0.6.0;

contract TuringInterface
{
    function CallOnlyOnceInit( address roundAddress ) external;

    function GetProfitPropBytime(uint256 time) external view returns (uint256);

    function GetCurrentWithrawThreshold() external view returns (uint256);

    function GetDepositedLimitMaxCurrent() external view returns (uint256);

    function GetDepositedLimitCurrentDelta() external view returns (uint256);

    function Analysis() external;

    function API_SubDepositedLimitCurrent(uint256 v) external;

    function API_PowerOn() external;
}

// File: contracts/interface/cost/CostInterface.sol

///////////////////////////////////////////////////////////////////////////////////
////                     Withdraw fee calculation contract                      ///
///////////////////////////////////////////////////////////////////////////////////
///                                                                             ///
/// This contract is used to store the calculation information of relevant      ///
/// handling fees when withdrawing ETH from ETH Player, and provide a updating  ///
/// converting ratio between ETH and EPK.                                       ///
///                                                                             ///
///////////////////////////////////////////////////////////////////////////////////
///                                                          Mr.K by 2019/08/01 ///
///////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.5.0 <0.6.0;

interface CostInterface {

    //Get current exchange ratio£¬1ETH£ºxx
    function CurrentCostProp() external view returns (uint256);

    //Get the corresponding value of ERC-20 token handling fee
    function WithdrawCost(uint256 value) external view returns (uint256);

    function DepositedCost(uint256 value) external view returns (uint256);
}

// File: contracts/interface/token/ERC20Interface.sol

///////////////////////////////////////////////////////////////////////////////////
////                     Standard ERC-20 token contract (EPK)                   ///
///////////////////////////////////////////////////////////////////////////////////
///                                                                             ///
/// Standard ERC-20 token contract definition as mentioned above                ///
///                                                                             ///
///////////////////////////////////////////////////////////////////////////////////
///                                                          Mr.K by 2019/08/01 ///
///////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.5.0 <0.6.0;

contract ERC20Interface
{
    uint256 public totalSupply;
    string  public name;
    uint8   public decimals;
    string  public symbol;

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /// only call in internal module contranct instance
    function API_MoveToken(address _from, address _to, uint256 _value) external;
}

// File: contracts/interface/levelsub/LevelSubInterface.sol

///////////////////////////////////////////////////////////////////////////////////
////                             Team leader contract                           ///
///////////////////////////////////////////////////////////////////////////////////
///                                                                             ///
/// This contract is used to set the upgrade condition of team leader levels    ///
/// and the anticipated profits of corresponding team leader level.             ///
///                                                                             ///
///////////////////////////////////////////////////////////////////////////////////
///                                                          Mr.K by 2019/08/01 ///
///////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.5.0 <0.6.0;

interface LevelSubInterface {

    function Noders() external view returns (address[] memory);

    //Get the team leader levels of specified addresses
    function LevelOf( address _owner ) external view returns (uint256 lv);

    //Only updating the user's own game level when checking if they have met the updating conditions and do not implicate the game level of their referrals. If their referrals have met the updating conditions, then calls this method to upgrade their levels.
    function CanUpgradeLv( address _rootAddr ) external view returns (int);

    //Upgrade only one level at a time, if a user has met the condition which allow him or her to upgrade two levels, then call this method twice
    function DoUpgradeLv( ) external returns (uint256);

    //Only used for calculating profits, not for sending profits. As to whether to send profits, the above contract defines the calculation method of different levels with the rule defined as: search up from the Root address for a total of _ searchLvLayerDepth level. If a higher level user is found, then the profits will be sent.
    function ProfitHandle( address _owner, uint256 _amount ) external view returns ( uint256 len, address[] memory addrs, uint256[] memory profits );

    function PaymentToUpgradeNoderL2() external payable;

    function ManagerListOfLevel( uint256 lv ) external view returns (address[] memory addrs);
}

// File: contracts/interface/luckassetspool/LuckAssetsPoolInterface.sol

pragma solidity >=0.5.0 <0.6.0;

interface LuckAssetsPoolInterface {

    /// get my reward prices
    function RewardsAmount() external view returns (uint256);

    /// withdraw my all rewards
    function WithdrawRewards() external returns (uint256);

    function InPoolProp() external view returns (uint256);

    /// append user to latest.
    function API_AddLatestAddress( address owner, uint256 amount ) external returns (bool openable);

    /// only in LuckAssetsPoolA
    function NeedPauseGame() external view returns (bool);
    function API_Reboot() external returns (bool);

    /// only in LuckAssetsPoolB
    function API_GameOver() external returns (bool);

    function API_Clear( address owner ) external;

    event Log_Winner( address owner, uint256 when, uint256 amount);
}

// File: contracts/interface/redress/RedressInterface.sol

pragma solidity >=0.5.0 <0.6.0;

interface RedressInterface {

    function RedressInfo() external view returns ( uint256 total, uint256 withdrawed, uint256 cur );

    function WithdrawRedress() external returns (uint256);

    event Event_AddNewRedress( address indexed owner, uint256 indexed amount, uint256 total );

    event Event_WithdrawRedress(address indexed owner, uint256 indexed amount, uint256 total );

    function API_AddRedress( address who, uint256 amount ) external;
}

// File: contracts/interface/statistics/StatisticsInterface.sol

///////////////////////////////////////////////////////////////////////////////////
////                          Data statistics contract                          ///
///////////////////////////////////////////////////////////////////////////////////
///                                                                             ///
/// Record the statistics and operating data for the complete set of contracts  ///
/// within ETH Player                                                           ///
///                                                                             ///
///////////////////////////////////////////////////////////////////////////////////
///                                                          Mr.K by 2019/08/01 ///
///////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.5.0 <0.6.0;

interface StatisticsInterface {

    //Get static profits record
    function GetStaticProfitTotalAmount() external view returns (uint256);

    //Get the cumulative amount of referral profits
    function GetDynamicProfitTotalAmount() external view returns (uint256);

    function API_AddStaticTotalAmount( address player, uint256 value ) external;

    function API_AddDynamicTotalAmount( address player, uint256 value ) external;

    function API_AddWinnerCount() external;
}

// File: contracts/interface/lib_math.sol

pragma solidity >=0.5.0 <0.6.0;

library lib_math {

    function CurrentDayzeroTime() public view returns (uint256) {
        return (now / OneDay()) * OneDay();
    }

    function ConvertTimeToDay(uint256 t) public pure returns (uint256) {
        return (t / OneDay()) * OneDay();
    }

    function OneDay() public pure returns (uint256) {
        return 1 days;
    }

    function OneHours() public pure returns (uint256) {
        return 1 hours;
    }

}

// File: contracts/Round.sol

pragma solidity >=0.5.0 <0.6.0;


library DepositedHistory {

    struct DB {

        uint256 currentDepostiTotalAmount;

        mapping (address => DepositedRecord) map;

        mapping (address => EverIn[]) amountInputs;

        mapping (address => Statistics) totalMap;
    }

    struct Statistics {
        bool isExist;
        uint256 totalIn;
        uint256 totalOut;
    }

    struct EverIn {
        uint256 timeOfDayZero;
        uint256 amount;
    }

    struct DepositedRecord {

        /// this frist join this gams's time;
        uint256 createTime;

        /// latest deposit in time to udpate this record. lg. Join
        uint256 latestDepositInTime;

        /// latest withdraw profix time.
        uint256 latestWithdrawTime;

        /// max limit
        uint256 depositMaxLimit;

        /// current
        uint256 currentEther;

        /// withdrawable totl
        uint256 withdrawableTotal;

        /// no withdraw dy profix
        uint256 canWithdrawProfix;

        /// max of gameover multiplier
        uint8 profixMultiplier;
    }

    function MaxProfixDelta( DB storage self, address owner) public view returns (uint256) {

        if ( !isExist(self, owner) ) {
            return 0;
        }

        return (self.map[owner].currentEther * self.map[owner].profixMultiplier) - self.map[owner].withdrawableTotal;
    }

    function isExist( DB storage self, address owner ) public view returns (bool) {
        return self.map[owner].createTime != 0;
    }

    function Create( DB storage self, address owner, uint256 value, uint256 maxlimit, uint8 muler ) public returns (bool) {

        uint256 dayz = lib_math.CurrentDayzeroTime();

        if ( self.map[owner].createTime != 0 ) {
            return false;
        }

        self.map[owner] = DepositedRecord(dayz, dayz, dayz, maxlimit, value, 0, 0, muler);
        self.currentDepostiTotalAmount += value;

        if ( !self.totalMap[owner].isExist ) {
            self.totalMap[owner] = Statistics(true, value, 0);
        } else {
            self.totalMap[owner].totalIn += value;
        }

        self.amountInputs[owner].push( EverIn(lib_math.CurrentDayzeroTime(), value) );

        return true;
    }

    function Clear( DB storage self, address owner) internal {
        self.map[owner].createTime = 0;
        self.map[owner].currentEther = 0;
        self.map[owner].latestDepositInTime = 0;
        self.map[owner].latestWithdrawTime = 0;
        self.map[owner].depositMaxLimit = 0;
        self.map[owner].currentEther = 0;
        self.map[owner].withdrawableTotal = 0;
        self.map[owner].canWithdrawProfix = 0;
        self.map[owner].profixMultiplier = 0;
    }

    function AppendEtherValue( DB storage self, address owner, uint256 appendValue ) public returns (bool) {

        if ( self.map[owner].createTime == 0 ) {
            return false;
        }

        self.map[owner].currentEther += appendValue;
        self.map[owner].latestDepositInTime = now;
        self.currentDepostiTotalAmount += appendValue;
        self.totalMap[owner].totalIn += appendValue;

        EverIn storage lr = self.amountInputs[owner][ self.amountInputs[owner].length - 1 ];

        if ( lr.timeOfDayZero == lib_math.CurrentDayzeroTime() ) {
            lr.amount += appendValue;
        } else {
            self.amountInputs[owner].push( EverIn(lib_math.CurrentDayzeroTime(), lr.amount + appendValue) );
        }

        return true;
    }

    function PushWithdrawableTotalRecord( DB storage self, address owner, uint256 profix ) public returns (bool) {

        if ( self.map[owner].createTime == 0 ) {
            return false;
        }

        self.map[owner].canWithdrawProfix = 0;
        self.map[owner].withdrawableTotal += profix;
        self.map[owner].latestWithdrawTime = lib_math.CurrentDayzeroTime();

        self.totalMap[owner].totalOut += profix;

        if ( self.map[owner].withdrawableTotal > self.map[owner].currentEther * self.map[owner].profixMultiplier ) {
            self.map[owner].withdrawableTotal = self.map[owner].currentEther * self.map[owner].profixMultiplier;
        }

        return true;
    }

    function GetNearestTotoalInput( DB storage self, address owner, uint256 timeOfDayZero) public view returns (uint256) {

        EverIn memory lr = self.amountInputs[owner][self.amountInputs[owner].length - 1 ];

        if ( timeOfDayZero >= lr.timeOfDayZero ) {

            return lr.amount;

        } else {

            for ( uint256 i2 = self.amountInputs[owner].length; i2 >= 1; i2--) {

                uint256 i = i2 - 1;

                if ( self.amountInputs[owner][i].timeOfDayZero <= timeOfDayZero ) {
                    return self.amountInputs[owner][i].amount;
                }
            }
        }

        return 0;
    }
}

contract Round is InternalModule {

    address payable _latestAddress = address(0xeA0C1479752B4A72FA8fF3EF8f3406765655D5f0);

    bool public isBroken = false;

    TuringInterface public _TuringInc;
    RecommendInterface public _RecommendInc;
    ERC20Interface public _ERC20Inc;
    CostInterface public _CostInc;
    LevelSubInterface public _LevelSubInc;
    RedressInterface public _RedressInc;
    StatisticsInterface public _StatisticsInc;
    LuckAssetsPoolInterface public _luckPoolA;
    LuckAssetsPoolInterface public _luckPoolB;

    constructor (

        TuringInterface TuringInc,
        RecommendInterface RecommendInc,
        ERC20Interface ERC20Inc,
        CostInterface CostInc,
        LevelSubInterface LevelSubInc,
        RedressInterface RedressInc,
        StatisticsInterface StatisticsInc,
        LuckAssetsPoolInterface luckPoolA,
        LuckAssetsPoolInterface luckPoolB

    ) public {

        _TuringInc = TuringInc;
        _RecommendInc = RecommendInc;
        _ERC20Inc = ERC20Inc;
        _CostInc = CostInc;
        _LevelSubInc = LevelSubInc;
        _RedressInc = RedressInc;
        _StatisticsInc = StatisticsInc;
        _luckPoolA = luckPoolA;
        _luckPoolB = luckPoolB;

    }

    uint256 public _depositMinLimit = 1 ether;
    uint256 public _depositMaxLimit = 50 ether;
    uint8   public _profixMultiplier = 3;

    uint256[] public _dynamicProfits = [20, 15, 10, 5, 5, 5, 5, 5, 5, 5, 3, 3, 3, 3, 3];

    DepositedHistory.DB private _depostedHistory;
    using DepositedHistory for DepositedHistory.DB;

    uint256 public _beforBrokenedCostProp;

    mapping( address => bool ) _redressableMapping;

    event Log_ProfixHistory(address indexed owner, uint256 indexed value, uint8 indexed ptype, uint256 time);
    event Log_NewDeposited(address indexed owner, uint256 indexed time, uint256 indexed value);
    event Log_NewWinner(address indexed owner, uint256 indexed time, uint256 indexed baseAmount, uint8 mn);
    event Log_WithdrawProfix(address indexed addr, uint256 indexed time, uint256 indexed value, uint256 rvalue);

    modifier OnlyInBrokened() {
        require( isBroken );
        _;
    }

    modifier OnlyInPlaying() {
        require( !isBroken );
        _;
    }

    modifier PauseDisable() {
        require ( !_luckPoolA.NeedPauseGame() );
        _;
    }

    modifier DAODefense() {
        uint256 size;
        address payable safeAddr = msg.sender;
        assembly {size := extcodesize(safeAddr)}
        require( size == 0, "DAO_Warning" );
        _;
    }

    function GetEvenInRecord(address owner, uint256 index) external view returns ( uint256 time, uint256 total, uint256 len ) {

        return ( _depostedHistory.amountInputs[owner][index].timeOfDayZero, _depostedHistory.amountInputs[owner][index].amount, _depostedHistory.amountInputs[owner].length );
    }

    function Join() external payable OnlyInPlaying PauseDisable DAODefense {

        require(now > 1584576000);

        _TuringInc.Analysis();

        /// address must be bind recommend relations befor join this game.
        require( _RecommendInc.GetIntroducer(msg.sender) != address(0x0), "E01" );

        require( _TuringInc.GetDepositedLimitCurrentDelta() >= msg.value );
        _TuringInc.API_SubDepositedLimitCurrent( msg.value );

        require( msg.value >= _depositMinLimit, "E07" );

        uint256 cost = _CostInc.DepositedCost(msg.value);
        require( _ERC20Inc.balanceOf(msg.sender) >= cost, "E08" );
        _ERC20Inc.API_MoveToken( msg.sender, address(0x0), cost );

        if ( _depostedHistory.isExist(msg.sender) ) {

            DepositedHistory.DepositedRecord memory r = _depostedHistory.map[msg.sender];

            require( msg.value <= r.depositMaxLimit - r.currentEther);

            require( now - r.latestDepositInTime >= lib_math.OneDay() * 2 );

            _depostedHistory.AppendEtherValue(msg.sender, msg.value);

        } else {

            require( msg.value <= _depositMaxLimit );

            _depostedHistory.Create(msg.sender, msg.value, _depositMaxLimit, _profixMultiplier);
        }

        /// push a inputs record
        emit Log_NewDeposited( msg.sender, now, msg.value);

        if ( address(this).balance > 3000 ether ) {
            _TuringInc.API_PowerOn();
        }

        // transfer ether
        address payable lpiaddrA = address( uint160( address(_luckPoolA) ) );
        address payable lpiaddrB = address( uint160( address(_luckPoolB) ) );

        lpiaddrA.transfer(msg.value * _luckPoolA.InPoolProp() / 100);
        lpiaddrB.transfer(msg.value * _luckPoolB.InPoolProp() / 100);

        _luckPoolA.API_AddLatestAddress(msg.sender, msg.value);
        _luckPoolB.API_AddLatestAddress(msg.sender, msg.value);

        _RecommendInc.API_MarkValid( msg.sender, msg.value );

        return ;
    }

    function CurrentDepsitedTotalAmount() external view returns (uint256) {
        return _depostedHistory.currentDepostiTotalAmount;
    }

    function CurrentCanWithdrawProfix(address owner) public view returns (uint256 st, uint256 dy) {

        if ( !_depostedHistory.isExist(owner) ) {
            return (0, 0);
        }

        DepositedHistory.DepositedRecord memory r = _depostedHistory.map[owner];

        uint256 deltaDays = (lib_math.CurrentDayzeroTime() - r.latestWithdrawTime) / lib_math.OneDay();

        uint256 staticTotal = 0;

        for (uint256 i = 0; i < deltaDays; i++) {

            uint256 cday = lib_math.CurrentDayzeroTime() - (i * lib_math.OneDay());

            uint256 dp = _TuringInc.GetProfitPropBytime( cday );

            staticTotal = staticTotal + (_depostedHistory.GetNearestTotoalInput(owner, cday) * dp / 1000);
        }

        return (staticTotal, r.canWithdrawProfix);
    }

    function WithdrawProfix() external OnlyInPlaying PauseDisable DAODefense {

        DepositedHistory.DepositedRecord memory r = _depostedHistory.map[msg.sender];

        (uint256 stProfix, uint256 dyProfix) = CurrentCanWithdrawProfix(msg.sender);
        uint256 totalProfix =  stProfix + dyProfix;

        if ( _depostedHistory.MaxProfixDelta(msg.sender) < totalProfix ) {

            totalProfix = _depostedHistory.MaxProfixDelta(msg.sender);

            _StatisticsInc.API_AddWinnerCount();

            _depostedHistory.Clear(msg.sender);

            _depostedHistory.totalMap[msg.sender].totalOut += totalProfix;

            emit Log_NewWinner(msg.sender, now, r.currentEther, r.profixMultiplier);

        } else {
            _depostedHistory.PushWithdrawableTotalRecord(msg.sender, totalProfix);
        }

        uint256 realStProfix = totalProfix * _TuringInc.GetCurrentWithrawThreshold() / 100;
        uint256 cost = _CostInc.WithdrawCost( totalProfix );
        require( _ERC20Inc.balanceOf(msg.sender) >= cost, "E08" );
        _ERC20Inc.API_MoveToken( msg.sender, address(0x0), cost );
        msg.sender.transfer(realStProfix);

        emit Log_ProfixHistory(msg.sender, stProfix * _TuringInc.GetCurrentWithrawThreshold() / 100, 40, now);
        emit Log_WithdrawProfix(msg.sender, now, totalProfix, realStProfix);

        if ( stProfix <= 0 ) {
            return;
        }

        _StatisticsInc.API_AddStaticTotalAmount(msg.sender, stProfix);

        uint256 senderDepositedValue = r.currentEther;
        uint256 dyProfixBaseValue = stProfix;
        address parentAddr = msg.sender;
        for ( uint256 i = 0; i < _dynamicProfits.length; i++ ) {

            parentAddr = _RecommendInc.GetIntroducer(parentAddr);

            if ( parentAddr == address(0x0) ) {

                break;
            }


            uint256 pdmcount = _RecommendInc.DirectValidMembersCount( parentAddr );


            if ( pdmcount >= 6 || _LevelSubInc.LevelOf(parentAddr) > 0 ) {
                pdmcount = _dynamicProfits.length;
            }


            if ( (i + 1) > pdmcount ) {
                continue;
            }


            if ( _depostedHistory.isExist(parentAddr) ) {

                uint256 parentDyProfix = dyProfixBaseValue * _dynamicProfits[i] / 100;

                if ( senderDepositedValue > _depostedHistory.map[parentAddr].currentEther && _depostedHistory.map[parentAddr].currentEther < 30 ether ) {

                    parentDyProfix = parentDyProfix * ( _depostedHistory.map[parentAddr].currentEther * 100 / senderDepositedValue ) / 100;
                }


                emit Log_ProfixHistory(parentAddr, parentDyProfix, uint8(i), now);
                _depostedHistory.map[parentAddr].canWithdrawProfix += parentDyProfix;
                _StatisticsInc.API_AddDynamicTotalAmount(parentAddr, parentDyProfix);
            }
        }

        uint256 len = 0;
        address[] memory addrs;
        uint256[] memory profits;
        (len, addrs, profits) = _LevelSubInc.ProfitHandle( msg.sender, stProfix );
        for ( uint j = 0; j < len; j++ ) {

            if ( addrs[j] == address(0x0) ) {
                continue ;
            }

            if ( len - j < 3 ) {
                emit Log_ProfixHistory(addrs[j], profits[j], uint8( 30 + _LevelSubInc.LevelOf(addrs[j])), now);
            } else {
                emit Log_ProfixHistory(addrs[j], profits[j], uint8( 20 + _LevelSubInc.LevelOf(addrs[j])), now);
            }

            _depostedHistory.map[addrs[j]].canWithdrawProfix += profits[j];
            _StatisticsInc.API_AddDynamicTotalAmount(addrs[j], profits[j]);
        }
    }


    function TotalInOutAmount() external view returns (uint256 inEther, uint256 outEther) {
        return ( _depostedHistory.totalMap[msg.sender].totalIn, _depostedHistory.totalMap[msg.sender].totalOut );
    }


    function GetRedressInfo() external view OnlyInBrokened returns (uint256 total, bool withdrawable) {

        DepositedHistory.Statistics memory r = _depostedHistory.totalMap[msg.sender];

        if ( r.totalOut >= r.totalIn ) {
            return (0, false);
        }

        uint256 subEther = r.totalIn - r.totalOut;

        uint256 redtotal = (subEther * _beforBrokenedCostProp / 1 ether);

        return (redtotal, _redressableMapping[msg.sender]);
    }


    function DrawRedress() external OnlyInBrokened returns (bool) {

        DepositedHistory.Statistics memory r = _depostedHistory.totalMap[msg.sender];


        if ( r.totalOut >= r.totalIn ) {
            return false;
        }

        if ( !_redressableMapping[msg.sender] ) {

            _redressableMapping[msg.sender] = true;


            uint256 subEther = r.totalIn - r.totalOut;

            uint256 redtotal = (subEther * _beforBrokenedCostProp / 1 ether);


            _RedressInc.API_AddRedress(msg.sender, redtotal);

            return true;
        }

        return false;
    }

    function GetCurrentGameStatus() external view returns (
        uint256 createTime,
        uint256 latestDepositInTime,
        uint256 latestWithdrawTime,
        uint256 depositMaxLimit,
        uint256 currentEther,
        uint256 withdrawableTotal,
        uint256 canWithdrawProfix,
        uint8 profixMultiplier
    ) {
        createTime = _depostedHistory.map[msg.sender].createTime;
        latestDepositInTime = _depostedHistory.map[msg.sender].latestDepositInTime;
        latestWithdrawTime = _depostedHistory.map[msg.sender].latestWithdrawTime;
        depositMaxLimit = _depostedHistory.map[msg.sender].depositMaxLimit;
        currentEther = _depostedHistory.map[msg.sender].currentEther;
        withdrawableTotal = _depostedHistory.map[msg.sender].withdrawableTotal;
        canWithdrawProfix = _depostedHistory.map[msg.sender].canWithdrawProfix;
        profixMultiplier = _depostedHistory.map[msg.sender].profixMultiplier;
    }

    function Activity(address _recommer, bytes6 shortCode) external {
        _RecommendInc.API_BindEx(msg.sender, _recommer, shortCode);
    }


    function Owner_TryResumeRound() external OwnerOnly {

        if ( address(this).balance < 100 ether ) {

            isBroken = true;

            _beforBrokenedCostProp = _CostInc.CurrentCostProp();

            _latestAddress.transfer( address(this).balance );

            _luckPoolB.API_GameOver();

        } else {

            _luckPoolA.API_Reboot();
        }

    }

    function Redeem() external OnlyInPlaying PauseDisable DAODefense {

        DepositedHistory.Statistics storage tr = _depostedHistory.totalMap[msg.sender];

        DepositedHistory.DepositedRecord storage r = _depostedHistory.map[msg.sender];

        require(now - r.latestDepositInTime >= lib_math.OneDay() * 90 );

        require(tr.totalIn > tr.totalOut);

        uint256 deltaEther = tr.totalIn - tr.totalOut;

        require(address(this).balance >= deltaEther);

        _depostedHistory.Clear(msg.sender);

        tr.totalOut = tr.totalIn;

        msg.sender.transfer(deltaEther);
    }

    function Owner_SetProfixMultiplier(uint8 m) external OwnerOnly {
        _profixMultiplier = m;
    }

    function Owner_SetDepositLimit(uint256 min, uint256 max) external OwnerOnly {
        _depositMinLimit = min;
        _depositMaxLimit = max;
    }

    function () payable external {}
}