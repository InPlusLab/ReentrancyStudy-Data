/**
 *Submitted for verification at Etherscan.io on 2020-03-08
*/

// File: contracts/InternalModule.sol

pragma solidity >=0.5.0 <0.6.0;

contract InternalModule {

    address[] _authAddress;

    address payable[] public _contractOwners = [
        address(0x16F2F7eaC61e53271593C6F0BF301afb62837c9c),  // BBE
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

// File: contracts/LuckAssetsPoolB.sol

pragma solidity >=0.5.0 <0.6.0;




contract LuckAssetsPoolB is LuckAssetsPoolInterface, InternalModule {

    struct Invest {

        address who;

        uint256 when;

        uint256 amount;
    }

    uint256 public _nextWinningThePrizeTime;

    uint256 public _inPoolProp = 5;

    uint256 public _activityMinLimit = 30 ether;

    uint256 public _rewardsCount = 5;

    mapping(uint256 => Invest[]) public _rewardsAmountMapping;

    mapping(address => uint256) public _sumInAmountMapping;

    constructor() public {
        _nextWinningThePrizeTime = lib_math.CurrentDayzeroTime() + lib_math.OneDay();
    }

    function InPoolProp() external view returns (uint256) {
        return _inPoolProp;
    }

    function API_Clear( address owner ) external APIMethod {
        _sumInAmountMapping[owner] = 0;
    }

    function API_AddLatestAddress( address owner, uint256 amount ) external APIMethod returns (bool openable) {

        if ( now > _nextWinningThePrizeTime ) {
            WinningThePrize();
            openable = true;
        }

        _sumInAmountMapping[owner] += amount;

        if ( _sumInAmountMapping[owner] >= _activityMinLimit ) {

            _rewardsAmountMapping[_nextWinningThePrizeTime].push( Invest(owner, now, amount) );

            _sumInAmountMapping[owner] -= _activityMinLimit;
        }

        openable = false;
    }

    function WinningThePrize() internal {

        uint256 contractBalance = address(this).balance;

        Invest[] memory list = _rewardsAmountMapping[_nextWinningThePrizeTime];

        if ( list.length <= 0 ) {
            _nextWinningThePrizeTime = lib_math.CurrentDayzeroTime() + lib_math.OneDay();
            return;
        }

        uint256 everRed = contractBalance / _rewardsCount;
        if ( list.length > _rewardsCount ) {

            for (uint256 i = 0; i < _rewardsCount; i++) {
                address payable paddr = address( uint160( address(list[(now >> i) % list.length].who) ) );
                paddr.transfer(everRed);
                emit Log_Winner(paddr, now, everRed);
            }

        } else {

            everRed = contractBalance / list.length;
            for (uint256 i = 0; i < list.length; i++) {
                address payable paddr = address( uint160( address(list[i].who) ) );
                paddr.transfer(everRed);
                emit Log_Winner(paddr, now, everRed);
            }

        }

        _nextWinningThePrizeTime = lib_math.CurrentDayzeroTime() + lib_math.OneDay();
    }

    function API_GameOver() external APIMethod returns (bool) {
        _defaultReciver.transfer( address(this).balance );
    }

    function Owner_SetInPoolProp(uint256 p) external OwnerOnly {
        _inPoolProp = p;
    }

    function Owner_SetActivityMinLimit(uint256 p) external OwnerOnly {
        _activityMinLimit = p;
    }

    function () payable external {}

    function RewardsAmount() external view returns (uint256) {
        return 0;
    }
    function WithdrawRewards() external returns (uint256) {
        return 0;
    }
    function NeedPauseGame() external view returns (bool) {
        return false;
    }
    function API_Reboot() external returns (bool) {
        return false;
    }
}