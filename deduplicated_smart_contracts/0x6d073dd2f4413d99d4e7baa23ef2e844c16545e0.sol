/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

// File: openzeppelin\contracts\GSN\Context.sol

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: openzeppelin\contracts\access\Ownable.sol

pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\generics\Configurable.sol

pragma solidity ^0.6.0;


/**
* Allows a contract to have admin rights on changing some config values
*/
abstract contract Configurable is Ownable {

    event ConfigChanged(bytes32 name, uint256 new_value);
    // config
	mapping(bytes32 => uint256) public config;

    constructor() public
    Ownable() {
    }

    /**
        @dev Sets a config value
		@param name Name of the value
        @param new_value The value to write in the config
    */
    function setConfigValue(bytes32 name, uint256 new_value) public virtual
    onlyOwner() {
        config[name] = new_value;
        emit ConfigChanged(name, new_value);
    }
}

// File: contracts\CreatorRoulette.sol

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


enum State {READY, WAITING_QUERY1, WAITING_QUERY2, DONE, REFUND}

struct RaceConfig {
    // provable query ids
    bytes32 query_price_start;
    bytes32 query_price_end;

    bytes32[] coins;
    uint256[] coin_pool;
    uint256 total_pool;

    uint256 race_duration;
    uint256 min_bet;
    uint256 start_time;
    uint256 betting_duration;
    uint256 bet_matching_pool;
    uint256 paid; //amount paid to claimers

    address creator;

    State state;
}

abstract contract IChallenge {
    //function races(uint256 raceid) external view returns (RaceConfig memory);
    mapping(uint256 => RaceConfig) public races;
    function getRaceCoinPrices(uint256 race_id, bytes32 coin) virtual external view returns (uint256 start, uint256 end);
    function getRaceCoins(uint256 race_id) virtual external view returns(uint256 length, bytes32[10] memory array, uint256[10] memory pools);
}

contract CreatorRoulette is Configurable {
    event RewardClaimed(uint256 raceid);

    mapping(uint256 => bool) rewarded;

    constructor() public
    Configurable() {
        config["REWARD"] = 1 ether;
        config["MIN_POOL"] = 0.3 ether;
        config["ODDS"] = 64;
        config["CHALLENGE_ADDR"] = uint256(0x2FC5Ef1BA3D72595Db6fd52478813DE85872D751);
    }

    function checkWin(uint256 raceid) public view returns (bool) {
        address addr = address(config["CHALLENGE_ADDR"]);
        ( , ,uint256 pool, , , , , , , ,State state) = IChallenge(addr).races(raceid);
        if(state != State.DONE) {
            return false;
        }
        if(pool < config["MIN_POOL"]) {
            return false;
        }
        ( , bytes32[10] memory coinArray, ) = IChallenge(addr).getRaceCoins(raceid);
        (uint256 start, uint256 end) = IChallenge(addr).getRaceCoinPrices(raceid, coinArray[0]);
        
        uint256 val = uint256(keccak256(abi.encodePacked(start, end, raceid)));
        return val % config["ODDS"] == 0;
    }

    receive() external payable {
        
    }

    function ownerKill() external onlyOwner {
        selfdestruct(payable(owner()));
    }

    function claim(uint256 raceid) public {
        require(!rewarded[raceid], "already rewarded");
        require(checkWin(raceid), "not a winner");
        rewarded[raceid] = true;
        address addr = address(config["CHALLENGE_ADDR"]);
        ( , , , , , , , , ,address creator , ) = IChallenge(addr).races(raceid);
        payable(creator).transfer(config["REWARD"]);
        emit RewardClaimed(raceid);
    }
}