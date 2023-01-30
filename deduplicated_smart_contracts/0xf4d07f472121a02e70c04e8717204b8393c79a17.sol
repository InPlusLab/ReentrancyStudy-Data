/**
 *Submitted for verification at Etherscan.io on 2020-03-08
*/

pragma solidity ^0.5.16;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AutoRedDotDistrict is Ownable {

    using SafeMath for uint256;

    /* ********** */
    /* DATA TYPES */
    /* ********** */

    /* ****** */
    /* EVENTS */
    /* ****** */

    /* ******* */
    /* STORAGE */
    /* ******* */

    // Anyone can call the createAuction function to receive a small reward when
    // any of the whitelisted kitties are available to sire.
    uint256 public auctionCreationReward = 10000000000000000; // 0.01 ETH

    // Users can only call createAuction for kitties that are whitelisted by
    // the owner.
    mapping (uint256 => bool) public kittyIsWhitelisted;
    uint256 public numberOfWhitelistedKitties;

    // The owner can set startingPrice, endingPrice, and auctionDuration for
    // siring auctions.
    mapping (uint256 => uint256) public startingSiringPriceForKitty;
    uint256 public globalEndingSiringPrice = 0;
    uint256 public globalAuctionDuration = 1296000; // 15 Days (in seconds)

    /* ********* */
    /* MODIFIERS */
    /* ********* */

    /* ********* */
    /* CONSTANTS */
    /* ********* */

    address public kittyCoreAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    address public kittySiresAddress = 0xC7af99Fe5513eB6710e6D5f44F9989dA40F27F26;

    /* ********* */
    /* FUNCTIONS */
    /* ********* */

    // Anyone can call this function to claim the auctionCreationReward when
    // any of the red dot district kitties are rested and ready to sire.
    // The auctionCreationReward funds come from the previous successful sire
    // auctions, so the owner does not have to keep refilling this contract.
    // This function is still callable even if the contract does not have enough
    // for the auctionCreationReward, the caller will simply not be rewarded.
    function createAuction(uint256 _kittyId) external {
        require(kittyIsWhitelisted[_kittyId] == true, 'kitty is not whitelisted');

        KittyCore(kittyCoreAddress).createSiringAuction(
            _kittyId,
            startingSiringPriceForKitty[_kittyId],
            globalEndingSiringPrice,
            globalAuctionDuration
        );

        uint256 contractBalance = address(this).balance;
        if(contractBalance >= auctionCreationReward){
            msg.sender.transfer(auctionCreationReward);
        }
    }

    function ownerChangeStartingSiringPrice(uint256 _kittyId, uint256 _newStartingSiringPrice) external onlyOwner {
        startingSiringPriceForKitty[_kittyId] = _newStartingSiringPrice;
    }

    function ownerChangeGlobalEndingSiringPrice(uint256 _newGlobalEndingSiringPrice) external onlyOwner {
        globalEndingSiringPrice = _newGlobalEndingSiringPrice;
    }

    function ownerChangeGlobalAuctionDuration(uint256 _newGlobalAuctionDuration) external onlyOwner {
        globalAuctionDuration = _newGlobalAuctionDuration;
    }

    function ownerChangeAuctionCreationReward(uint256 _newAuctionCreationReward) external onlyOwner {
        auctionCreationReward = _newAuctionCreationReward;
    }

    function ownerCancelSiringAuction(uint256 _kittyId) external onlyOwner {
        KittySires(kittySiresAddress).cancelAuction(_kittyId);
    }

    function ownerWithdrawKitty(address _destination, uint256 _kittyId) external onlyOwner {
        KittyCore(kittyCoreAddress).transfer(_destination, _kittyId);
    }

    function ownerWhitelistKitty(uint256 _kittyId, bool _whitelist) external onlyOwner {
        require(kittyIsWhitelisted[_kittyId] != _whitelist, 'kitty already had that value for its whitelist status');

        kittyIsWhitelisted[_kittyId] = _whitelist;
        if(_whitelist){
            numberOfWhitelistedKitties = numberOfWhitelistedKitties.add(1);
        } else {
            numberOfWhitelistedKitties = numberOfWhitelistedKitties.sub(1);
        }
    }

    // This is the main withdrawal function that the owner can call to claim
    // earnings. It leaves numberOfWhitelistedKitties * auctionCreationReward
    // in the contract to incentivize future callers of the createAuction
    // function.
    function ownerWithdrawAllEarnings() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        uint256 fundsToLeaveToIncentivizeFutureCallers = auctionCreationReward.mul(numberOfWhitelistedKitties);
        if(contractBalance > fundsToLeaveToIncentivizeFutureCallers){
            uint256 earnings = contractBalance.sub(fundsToLeaveToIncentivizeFutureCallers);
            msg.sender.transfer(earnings);
        }
    }

    // This is an emergency function that the owner can call to retrieve all
    // ether, including the ether that would normally be left in the contract to
    // incentivize future callers of the createAuction function.
    function emergencyWithdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    constructor() public {
        // Initialize starting prices for the six EN04 generation 0 kitties
        startingSiringPriceForKitty[848437] = 200000000000000000; // 0.2 ETH
        startingSiringPriceForKitty[848439] = 200000000000000000; // 0.2 ETH
        startingSiringPriceForKitty[848440] = 200000000000000000; // 0.2 ETH
        startingSiringPriceForKitty[848441] = 200000000000000000; // 0.2 ETH
        startingSiringPriceForKitty[848442] = 200000000000000000; // 0.2 ETH
        startingSiringPriceForKitty[848582] = 200000000000000000; // 0.2 ETH

        // Whitelist the six EN04 generation 0 kitties
        kittyIsWhitelisted[848437] = true;
        kittyIsWhitelisted[848439] = true;
        kittyIsWhitelisted[848440] = true;
        kittyIsWhitelisted[848441] = true;
        kittyIsWhitelisted[848442] = true;
        kittyIsWhitelisted[848582] = true;
        numberOfWhitelistedKitties = 6;

        // Transfer ownership to Dapper Labs original Red Dot District EOA
        // account on mainnet, they can change ownership to whatever address
        // they wish after that.
        transferOwnership(0xBb1e390b77Ff99f2765e78EF1A7d069c29406bee);
    }

    function() external payable {}
}

contract KittyCore {
    function transfer(address _to, uint256 _tokenId) external;
    function createSiringAuction(uint256 _kittyId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration) external;
}

contract KittySires {
    function cancelAuction(uint256 _tokenId) external;
}