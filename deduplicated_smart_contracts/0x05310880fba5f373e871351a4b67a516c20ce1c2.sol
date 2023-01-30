// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/SafeCast.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../JoysToken.sol";
import "../JoysNFT.sol";

import "./JoysLotteryMeta.sol";
import "./UniformRandomNumber.sol";

/// @title Joys lottery
/// @notice lottery joys hero and weapon with access control
contract JoysLottery is ReentrancyGuard, Pausable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using SafeMath for uint32;
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    // claim state 1normal 2claimed
    uint8 public constant CS_NORMAL = 1;
    uint8 public constant CS_CLAIMED = 2;

    uint16 public constant FREE_HERO_COUNT = 1999;
    uint16 public heroClaimed;

    // crowd sale hero and weapon level
    uint8 public constant CS_HERO_LEVEL = 3;
    uint8 public constant CS_WEAPON_LEVEL = 2;

    // high level hero and weapon amount
    uint8 public constant HL_HERO = 99;
    uint8 public constant HL_WEAPON = 99;
    uint8 public hlHero;
    uint8 public hlWeapon;

    // free claim rate hero and weapon
    mapping (address => uint8) public crowdSalesHero;
    mapping (address => uint8) public crowdSalesWeapon;

    // freeLotteryHero
    mapping (address => uint8) public freeClaimHero;

    // invite claim
    struct InviteClaimInfo {
        uint8 state;
        uint256 joys;
        address addr;
    }
    mapping (address => InviteClaimInfo[]) public inviteClaimHero;

    // claim hero and weapon fee
    uint256 public heroClaimFee = 50 * 1e18;
    uint256 public weaponClaimFee = 50 * 1e18;

    JoysToken public joys;                  // address of joys token contract
    JoysNFT public joysHero;                // address of joys hero contract
    JoysNFT public joysWeapon;              // address of joys weapon contract
    JoysLotteryMeta public heroMeta;        // address of joys hero meta contract
    JoysLotteryMeta public weaponMeta;      // address of joys weapon meta contract
    address public nftJackpot;              // jackpot from 50% of draw

    enum Operation {
        crowdSaleClaim,
        inviteClaim,
        freeClaim,
        notFreeDrawHero,
        notFreeDrawWeapon
    }
    enum BoxState {
        Init,
        CanOpen,
        Opened,
        Expired
    }
    struct RequestInfo {
        // The operation of request.
        // 0:crowd sale claim, 1:invite claim, 2:free claim,
        // 3:not free draw hero, 4:not free draw weapon
        Operation operation;

        // internal counter
        uint32 reqID;

        // Block number of request tx.
        uint40 blockNumber;

        uint32 a;
        uint32 b;
        uint256 c;

        uint timestamp;

        BoxState state;
    }
    // mapping user request
    mapping(address => RequestInfo[]) public reqBox;
    Counters.Counter public reqIdTracker;

    uint constant REQ_EXPIRATION_BLOCKS = 250;
    uint constant REQ_DELAY_BLOCKS = 3;

    /// @dev A list of random numbers from past requests mapped by address and request id
    mapping(uint256 => uint256) public randomNumbers;

    uint256 public lotteryFee = 0.03 * 1e18;
    address payable[] public lotteryRole;

    event ClaimRareHero(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility);
    event ClaimRareWeapon(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility);
    event ClaimHero(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility, uint256 joys);
    event DrawHero(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility);
    event DrawWeapon(address indexed to, uint32 level, uint32 strength, uint32 intelligence, uint32 agility);

    /*
    * @notice JoysLottery constructor pause lottery before add hero and weapon
    */
    constructor(address _joys,
        address _joysHero,
        address _joysWeapon,
        address _heroMeta,
        address _weaponMeta,
        address _jackpot
    ) public {
        joys = JoysToken(_joys);
        joysHero = JoysNFT(_joysHero);
        joysWeapon = JoysNFT(_joysWeapon);
        heroMeta = JoysLotteryMeta(_heroMeta);
        weaponMeta = JoysLotteryMeta(_weaponMeta);

        nftJackpot = _jackpot;
    }

    function lotteryMemberCount() public view returns (uint256) {
        return lotteryRole.length;
    }

    function getRoleMember(uint256 index) public view returns (address payable) {
        require(lotteryMemberCount() > index, "JoysLottery: lottery role index out of bounds");
        return lotteryRole[index];
    }

    function hasRole(address account) private view returns (bool) {
        for(uint256 i = 0; i < lotteryMemberCount(); ++i) {
            if (getRoleMember(i) == account) {
                return true;
            }
        }
        return false;
    }

    function grantLotteryRole(address payable[] memory _account) onlyOwner public {
        for(uint32 idx = 0; idx < _account.length; ++idx) {
            lotteryRole.push(_account[idx]);
        }
    }

    function revokeLotteryRole(address payable account) onlyOwner public {
        for(uint256 i = 0; i < lotteryMemberCount(); ++i) {
            if (getRoleMember(i) == account) {
                address payable last = getRoleMember(lotteryMemberCount() -1);
                lotteryRole[i] = last;
                lotteryRole.pop();
            }
        }
    }

    function setLotteryFee(uint256 _fee) onlyOwner public {
        require(lotteryFee != _fee, "JoysLottery:same fee.");
        lotteryFee = _fee;
    }

    /**
     * @dev addCrowdSaleAddress.
     *
     * Requirements: only owner.
     * @notice add address to crowd sales
     * @param _address The address to add
     * @param _claimWeapon The flag of whether claim weapon
     */
    function addCrowdSaleAddress(address[] memory _address, bool _claimWeapon) onlyOwner public{
        bool heroClaim = false;
        bool weaponClaim = false;
        for (uint32 idx = 0; idx < _address.length; ++idx) {
            if (crowdSalesHero[address(_address[idx])] >= CS_NORMAL) {
                continue;
            }
            crowdSalesHero[_address[idx]] = CS_NORMAL;
            heroClaim = true;
        }

        if (!_claimWeapon) {
            require(heroClaim, "JoysLottery: not changed.");
            return;
        }
        for (uint32 idx = 0; idx < _address.length; ++idx) {
            if (crowdSalesWeapon[address(_address[idx])] >= CS_NORMAL) {
                continue;
            }
            crowdSalesWeapon[address(_address[idx])] = CS_NORMAL;
            weaponClaim = true;
        }

        require(heroClaim || weaponClaim, "JoysLottery: not changed.");
    }

    function addInviteClaimAddress(address _inviter, address _user, uint256 _joys) onlyOwner public {
        for(uint32 i = 0; i < inviteClaimHero[_inviter].length; ++i) {
            require(inviteClaimHero[_inviter][i].addr != _user, "JoysLottery: Already add.");
        }

        inviteClaimHero[_inviter].push(InviteClaimInfo({
            state: CS_NORMAL,
            joys: _joys,
            addr: _user
            }));
    }

    function addFreeClaimAddress(address[] memory _address) onlyOwner public {
        for(uint32 i = 0; i < _address.length; ++i) {
            freeClaimHero[_address[i]] = CS_NORMAL;
        }
    }

    function _randN(uint256 _seed, uint256 _min, uint256 _max, uint256 _offset) internal pure returns (uint256) {
        require(_max > _min, "JoysLottery:randN condition");
        return UniformRandomNumber.uniform(_seed + _offset, (_max - _min).div(2)).add(_min);
    }

    function _randLevel(uint256 _seed, uint256 _max) internal pure returns (uint256) {
        return UniformRandomNumber.uniform(_seed, _max);
    }

    function _randRareNFTMeta(address _address, uint32 _requestId,
        uint32 _level, uint32 _sMin, uint32 _sMax, uint32 _iMin, uint32 _iMax, uint32 _aMin, uint32 _aMax)
    internal returns (uint32, uint32, uint32, uint32) {
        uint256 seed = randomNumber(_address, _requestId);
        uint32 strength = _randN(seed, uint256(_sMin), uint256(_sMax), block.timestamp).toUint32();
        uint32 intelligence = _randN(seed, uint256(_iMin), uint256(_iMax), block.gaslimit).toUint32();
        uint32 agility = _randN(seed, uint256(_aMin), uint256(_aMax), block.difficulty).toUint32();
        return (_level, strength, intelligence, agility);
    }

    /// @notice Gets the random number produced by the 3rd-party service
    /// @param _requestId The ID of the request used to get the results
    /// @return level, strength, intelligence, agility
    function _crowdSaleHero(address _address, uint32 _requestId) internal returns (uint32, uint32, uint32, uint32){
        for (uint256 idx = 0; idx < heroMeta.length(); ++idx) {
            uint32 level;
            uint32 sMin;
            uint32 sMax;
            uint32 iMin;
            uint32 iMax;
            uint32 aMin;
            uint32 aMax;
            uint256 weight;
            (level, sMin, sMax, iMin, iMax, aMin, aMax, weight) = heroMeta.meta(idx);
            if (level == CS_HERO_LEVEL) {
                return _randRareNFTMeta(_address, _requestId, level, sMin, sMax, iMin, iMax, aMin, aMax);
            }
        }
        return (0, 0, 0, 0);
    }

    function _crowdSaleWeapon(address _address, uint32 _requestId) internal returns (uint32 , uint32 , uint32 , uint32){
        for (uint256 idx = 0; idx < weaponMeta.length(); ++idx) {
            uint32 level;
            uint32 sMin;
            uint32 sMax;
            uint32 iMin;
            uint32 iMax;
            uint32 aMin;
            uint32 aMax;
            uint256 weight;
            (level, sMin, sMax, iMin, iMax, aMin, aMax, weight) = weaponMeta.meta(idx);
            if (level == CS_WEAPON_LEVEL) {
                return _randRareNFTMeta(_address, _requestId, level, sMin, sMax, iMin, iMax, aMin, aMax);
            }
        }
        return (0, 0, 0, 0);
    }

    /**
     * @dev crowdSaleClaim
     *
     * @notice crowd sale claim hero and weapon if have with Rare attribute
     */
    function crowdSaleClaim(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        // claim rare hero
        uint32 heroLevel;
        uint32 weaponLevel;
        if (crowdSalesHero[_address] == CS_NORMAL && heroClaimed < FREE_HERO_COUNT) {
            uint32 level;
            uint32 strength;
            uint32 intelligence;
            uint32 agility;
            (level, strength, intelligence, agility) = _crowdSaleHero(_address, _requestId);
            require(level > 0, "JoysLottery: claim hero with error level.");

            joysHero.mint(_address, level, strength, intelligence, agility);
            crowdSalesHero[_address] = CS_CLAIMED;
            heroClaimed++;

            heroLevel = level;
            emit ClaimRareHero(_address, level, strength, intelligence, agility);
        }

        // claim rare weapon
        if (crowdSalesWeapon[_address] == CS_NORMAL) {
            uint32 level;
            uint32 strength;
            uint32 intelligence;
            uint32 agility;
            (level, strength, intelligence, agility) = _crowdSaleWeapon(_address, _requestId);
            require(level > 0, "JoysLottery: claim weapon with error level.");

            joysWeapon.mint(_address, level, strength, intelligence, agility);
            crowdSalesWeapon[_address] = CS_CLAIMED;

            weaponLevel = level;
            emit ClaimRareWeapon(_address, level, strength, intelligence, agility);
        }
        return (heroLevel, weaponLevel, 0);
    }

    /**
     * @dev inviteClaim
     *
     * @notice with no joys token cost lottery hero and joys
     */
    function inviteClaim(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        require(heroClaimed < FREE_HERO_COUNT, "JoysLottery: No free hero to be claimed");

        bool flag = false;
        uint32 idx = 0;
        for (uint32 i = 0; i < inviteClaimHero[_address].length; ++i) {
            if (inviteClaimHero[_address][i].state == CS_NORMAL) {
                idx = i;
                flag = true;
                break;
            }
        }
        require(flag, "JoysLottery: all claimed");

        uint32 level;
        uint32 strength;
        uint32 intelligence;
        uint32 agility;
        (level, strength, intelligence, agility) = _draw(_address, _requestId, heroMeta);
        joysHero.mint(_address, level, strength, intelligence, agility);

        uint256 token = inviteClaimHero[_address][idx].joys;
        joys.transfer(_address, token);

        inviteClaimHero[_address][idx].state = CS_CLAIMED;
        heroClaimed++;

        emit ClaimHero(_address, level, strength, intelligence, agility, token);

        return (level, 0, token.div(1e18));
    }

    /**
     * @dev freeClaim
     *
     * @notice with no joys token cost lottery hero
     */
    function freeClaim(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        require(heroClaimed < FREE_HERO_COUNT, "JoysLottery: no free hero claimed");
        require(freeClaimHero[_address] == CS_NORMAL, "JoysLottery: have claimed");

        uint32 level;
        uint32 strength;
        uint32 intelligence;
        uint32 agility;
        (level, strength, intelligence, agility) = _draw(_address, _requestId, heroMeta);

        joysHero.mint(_address, level, strength, intelligence, agility);

        freeClaimHero[_address] = CS_CLAIMED;
        heroClaimed++;

        emit ClaimHero(_address, level, strength, intelligence, agility, 0);

        return (level, 0, 0);
    }

    function _weightSlice(JoysLotteryMeta _meta, uint32 _step) private view returns (uint256 _sum) {
        uint32 idx = 0;
        for (uint32 i = _meta.length(); i > 0; i--) {
            idx++;
            uint256 w;
            (, , , , , , , w) = _meta.meta(i-1);
            _sum += w;
            if (idx >= _step) {
                break;
            }
        }
        return _sum;
    }

    function _parseLevel(uint256 _weight, JoysLotteryMeta _meta) private view returns(uint32) {
        // cal weight
        uint256[] memory calWeight = new uint256[](_meta.length()+1);
        for(uint32 i = 0; i < _meta.length(); i++) {
            calWeight[i] = _weightSlice(_meta, _meta.length()-i);
        }

        uint32 level;
        for (uint32 i = 0; i < calWeight.length; ++i) {
            uint256 w = calWeight[i];
            level = i;
            if(_weight >= w) {
                if(i == 0) {
//                    level = i + 1;
                    return 1;
                }
                break;
            }
            if(_weight < w) {
                continue;
            }
        }
        return level;
    }

    function _draw(address _address, uint32 _requestId, JoysLotteryMeta _meta)
    private returns (uint32 level, uint32 strength, uint32 intelligence, uint32 agility) {
        uint256 weight;
        for (uint256 idx = 0; idx < _meta.length(); ++idx) {
            uint256 w;
            ( , , , , , , , w) = _meta.meta(idx);
            weight += w;
        }
        uint256 seed = randomNumber(_address, _requestId);
        // parse level
        level = _parseLevel(_randLevel(seed, weight), _meta);
        require(level > 0, "JoysLottery: with error level.");

        uint32 sMin;
        uint32 sMax;
        uint32 iMin;
        uint32 iMax;
        uint32 aMin;
        uint32 aMax;
        (, sMin, sMax, iMin, iMax, aMin, aMax, ) = _meta.meta(level-1);
        strength = _randN(seed, uint256(sMin), uint256(sMax), block.timestamp).toUint32();
        intelligence = _randN(seed, uint256(iMin), uint256(iMax), block.gaslimit).toUint32();
        agility = _randN(seed, uint256(aMin), uint256(aMax), block.difficulty).toUint32();
    }

    // lottery hero
    function drawHero(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        uint32 a;
        uint32 b;
        uint32 c;
        uint32 d;
        (a,b,c,d) = _draw(_address, _requestId, heroMeta);
        joysHero.mint(_address, a, b, c, d);

        return (a, 0, 0);
    }

    // lottery weapon
    function drawWeapon(address _address, uint32 _requestId) private returns (uint32, uint32, uint256) {
        uint32 a;
        uint32 b;
        uint32 c;
        uint32 d;
        (a,b,c,d) = _draw(_address, _requestId, weaponMeta);
        joysWeapon.mint(_address, a, b, c, d);

        return (0, b, 0);
    }

    function setFee(uint256 _hero, uint256 _weapon) public onlyOwner {
        require(heroClaimFee != _hero || weaponClaimFee != _weapon, "JoysLottery: no need");
        heroClaimFee = _hero;
        weaponClaimFee = _weapon;
    }

    function transferHeroOwnership(address _newHero) public onlyOwner {
        joysHero.transferOwnership(_newHero);
    }

    function transferWeaponOwnership(address _newWeapon) public onlyOwner {
        joysWeapon.transferOwnership(_newWeapon);
    }

    function mintHero(uint32 _level, uint32 _strength, uint32 _intelligence, uint32 _agility) public onlyOwner {
        require(hlHero < HL_HERO, "JoysLottery: max high level hero.");
        require(_level <= heroMeta.length(), "JoysLottery: wrong level.");
        joysHero.mint(_msgSender(), _level, _strength, _intelligence, _agility);
        hlHero++;
    }

    function mintWeapon(uint32 _level, uint32 _strength, uint32 _intelligence, uint32 _agility) public onlyOwner {
        require(hlWeapon < HL_HERO, "JoysLottery: max high level weapon.");
        require(_level <= weaponMeta.length(), "JoysLottery: wrong level.");
        joysWeapon.mint(_msgSender(), _level, _strength, _intelligence, _agility);
        hlWeapon++;
    }

    /// @dev Gets the next consecutive request ID to be used
    /// @return requestId The ID to be used for the next request
    function _getNextRequestId() internal view returns (uint32 requestId) {
        uint256 len = reqBox[_msgSender()].length;
        requestId = len <= 0 ? 1 : reqBox[_msgSender()][len - 1].reqID.add(1).toUint32();
    }

    /// @notice Checks if the request for randomness from the 3rd-party service has completed
    /// @dev For time-delayed requests, this function is used to check/confirm completion
    /// @param _requestId The ID of the request used to get the results of the RNG service
    /// @return state 0:not complete. 1:complete 2:expired
    function requestState(address _address, uint32 _requestId) public view returns (BoxState) {
        require(_address != address(0), "JoysLottery: invalid address.");
        require(_requestId > 0, "JoysLottery: zero request id.");

        uint256 len = requestCount(_address);
        require(len > 0, "JoysLottery: have no request.");
        require(_requestId <= len, "JoysLottery: invalid request id.");

        bool flag = false;
        uint256 idx = 0;
        for(uint256 i = len; i > 0; i--) {
            if (reqBox[_address][i-1].reqID == _requestId) {
                flag = true;
                idx = i-1;
                break;
            }
        }
        require(flag, "JoysLottery: don't have the special request id.");

        RequestInfo storage r = reqBox[_address][idx];
        uint40 blockNumber = r.blockNumber;
        if (r.state == BoxState.Init) {
            if(block.number > blockNumber + REQ_DELAY_BLOCKS &&
                block.number <= blockNumber + REQ_EXPIRATION_BLOCKS) {
                return BoxState.CanOpen;
            } else {
                return BoxState.Expired;
            }
        }

        return r.state;
    }

    /// @dev Gets a seed for a random number from the latest available blockhash
    /// @return seed The seed to be used for generating a random number
    function _getSeed(address _address, uint32 _requestId) internal virtual view returns (uint256 seed) {
        uint256 len = requestCount(_address);
        bool flag = false;
        uint256 idx = 0;
        for(uint256 i = len; i > 0; i--) {
            if (reqBox[_address][i-1].reqID == _requestId) {
                flag = true;
                idx = i-1;
                break;
            }
        }
        require(flag, "JoysLottery: gen seed error, no request id.");

        RequestInfo storage r = reqBox[_address][idx];
        seed = uint256(blockhash(r.blockNumber + REQ_DELAY_BLOCKS)) + uint256(_address)+ _requestId;
    }

    /// @dev Stores the latest random number by request ID and logs the event
    /// @param _requestId The key of the special address request to store the random number
    /// @param _result The random number for the special key
    function _storeResult(address _address, uint32 _requestId, uint256 _result) internal returns (uint256) {
        // Store random value
        uint256 key = (uint256(_address) + _requestId);
        if (randomNumbers[key] == 0) {
            randomNumbers[key] = _result;
        }

        return randomNumbers[key];
    }

    /// @notice Gets the random number produced by the 3rd-party service
    /// @param _requestId The ID of the request used to get the results of the RNG service
    /// @return randomNum The random number
    function randomNumber(address _address, uint32 _requestId) internal returns (uint256 randomNum) {
        return _storeResult(_address, _requestId, _getSeed(_address, _requestId));
    }

    /**
     * @dev getBox.
     *
     * @notice request a box according to '_op' operation
     * @param _op The operation.
     */
    function getBox(Operation _op) whenNotPaused nonReentrant public payable {
        require(msg.value >= lotteryFee, "JoysLottery: lottery fee limit.");
        require(lotteryMemberCount() > 0, "JoysLottery: no lottery role.");

        uint32 requestId = _getNextRequestId();
        uint40 lockBlock = uint40(block.number);

        if(requestId > 1) {
            uint32 lastRequest = requestId -1;
            BoxState state = requestState(_msgSender(), lastRequest);
            require(state == BoxState.Opened || state == BoxState.Expired, "JoysLottery: invalid request.");
            if(state == BoxState.Expired) {
                for(uint256 i = reqBox[_msgSender()].length; i > 0; i--) {
                    if(reqBox[_msgSender()][i-1].reqID == lastRequest) {
                        reqBox[_msgSender()][i-1].state = BoxState.Expired;
                        break;
                    }
                }
            }
        }

        if(_op == Operation.crowdSaleClaim) {
            require(
                crowdSalesHero[_msgSender()] == CS_NORMAL && heroClaimed < FREE_HERO_COUNT ||
                crowdSalesWeapon[_msgSender()] == CS_NORMAL,
                    "JoysLottery: Have no qualified.");

        } else if (_op == Operation.inviteClaim) {
            require(heroClaimed < FREE_HERO_COUNT, "JoysLottery: No free hero to be claimed");
            bool flag = false;
            uint256 len = inviteClaimHero[_msgSender()].length;
            require(len > 0, "JoysLottery: No invite qualified.");

            uint256 tokens;
            for (uint32 i = 0; i < len; ++i) {
                if (inviteClaimHero[_msgSender()][i].state == CS_NORMAL) {
                    flag = true;
                    tokens = inviteClaimHero[_msgSender()][i].joys;
                    break;
                }
            }
            require(flag, "JoysLottery: all claimed.");
            require(joys.balanceOf(address(this)) >= tokens, "JoysLottery:not enough JOYS to claim.");

        } else if (_op == Operation.freeClaim) {
            require(heroClaimed < FREE_HERO_COUNT, "JoysLottery: no free hero claimed");
            require(freeClaimHero[_msgSender()] == CS_NORMAL, "JoysLottery: have claimed");

        } else if (_op == Operation.notFreeDrawHero) {
            require(joys.balanceOf(_msgSender()) >= heroClaimFee, "JoysLottery: Insufficient joys token.");

            joys.transferFrom(_msgSender(), address(this), heroClaimFee);
            joys.burn(heroClaimFee.div(2));

            joys.transfer(nftJackpot, heroClaimFee.div(2));

        } else if (_op == Operation.notFreeDrawWeapon) {
            require(joys.balanceOf(_msgSender()) >= weaponClaimFee, "JoysLottery: Insufficient joys token.");

            joys.transferFrom(_msgSender(), address(this), weaponClaimFee);
            joys.burn(weaponClaimFee.div(2));

            joys.transfer(nftJackpot, weaponClaimFee.div(2));

        } else {
            require(false, "JoysLottery: invalid operation.");
        }

        // receive fee
        reqIdTracker.increment();
        uint256 idx = reqIdTracker.current().mod(lotteryMemberCount());
        _receive(getRoleMember(idx));

        reqBox[_msgSender()].push(RequestInfo({
            operation: _op,
            reqID: requestId,
            blockNumber: lockBlock,
            a:0,
            b:0,
            c:0,
            timestamp: 0,
            state: BoxState.Init
            }));
    }

    function _receive(address payable _address) private {
        _address.transfer(msg.value);
    }

    /**
     * @dev openBox.
     *
     * @notice request open box according to '_requestId', only lottery role.
     */
    function openBox(address _address) public {
        require(hasRole(_msgSender()), "JoysLottery: have no privilege.");

        uint256 len = requestCount(_address);
        require(len > 0, "JoysLottery: have no box.");

        uint256 idx = len - 1;
        RequestInfo storage req = reqBox[_address][idx];
        uint32 _requestId = req.reqID;
        require(requestState(_address, _requestId) == BoxState.CanOpen, "JoysLottery: invalid request state.");

        uint32 a;
        uint32 b;
        uint256 c;
        Operation _op = req.operation;
        if(_op == Operation.crowdSaleClaim) {
            (a, b, c) = crowdSaleClaim(_address, _requestId);

        } else if (_op == Operation.inviteClaim) {
            (a, b, c) = inviteClaim(_address, _requestId);

        } else if (_op == Operation.freeClaim) {
            (a, b, c) = freeClaim(_address, _requestId);

        } else if (_op == Operation.notFreeDrawHero) {
            (a, b, c) = drawHero(_address, _requestId);

        } else if (_op == Operation.notFreeDrawWeapon) {
            (a, b, c) = drawWeapon(_address, _requestId);

        } else {
            require(false, "JoysLottery: invalid operation.");

        }

        // update request box
        reqBox[_address][idx].a = a;
        reqBox[_address][idx].b = b;
        reqBox[_address][idx].c = c;
        reqBox[_address][idx].timestamp = block.timestamp;
        reqBox[_address][idx].state = BoxState.Opened;
    }

    function inviteCount(address _address) public view returns (uint256) {
        return inviteClaimHero[_address].length;
    }

    function requestCount(address _address) public view returns (uint256){
        return reqBox[_address].length;
    }

    function setAddress(address _joys,
        address _joysHero,
        address _joysWeapon,
        address _heroMeta,
        address _weaponMeta,
        address _jackpot
    ) public onlyOwner {
        joys = JoysToken(_joys);
        joysHero = JoysHero(_joysHero);
        joysWeapon = JoysWeapon(_joysWeapon);
        heroMeta = JoysLotteryMeta(_heroMeta);
        weaponMeta = JoysLotteryMeta(_weaponMeta);

        nftJackpot = _jackpot;
    }

    function recycleJoysToken(address _address) public onlyOwner {
        require(_address != address(0), "JoysLottery:Invalid address");
        require(joys.balanceOf(address(this)) > 0, "JoysLottery:no JOYS");
        joys.transfer(_address, joys.balanceOf(address(this)));
    }
}