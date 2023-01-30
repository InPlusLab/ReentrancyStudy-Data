/**
 *Submitted for verification at Etherscan.io on 2020-04-24
*/

// File: contracts/lib/Context.sol

// From package @openzeppelin/contracts@2.4.0
pragma solidity 0.5.8;

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
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/lib/Ownable.sol

// From package @openzeppelin/contracts@2.4.0
pragma solidity 0.5.8;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Registry.sol

pragma solidity 0.5.8;


contract Registry is Ownable {
    // ------
    // STATE
    // ------

    struct Member {
        uint256 challengeID;
        uint256 memberStartTime; // Used for voting: voteWeight = sqrt(now - memberStartTime)
    }

    // Note, this address is used to map to the owner and delegates in the ERC-1056 registry
    mapping(address => Member) public members;

    // -----------------
    // GETTER FUNCTIONS
    // -----------------

    /**
    @dev                Get the challenge ID of a Member. If no challenge exists it returns 0
    @param _member      The member being checked
    @return             The challengeID
    */
    function getChallengeID(address _member) external view returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = members[_member];
        return member.challengeID;
    }

    /**
    @dev                Get the start time of a Member. If no time exists it returns 0
    @param _member      The member being checked
    @return             The start time
    */
    function getMemberStartTime(address _member) external view returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = members[_member];
        return member.memberStartTime;
    }

    // -----------------
    // SETTER FUNCTIONS
    // -----------------

    /**
    @dev                Set a member in the Registry. Only Everest can call this function.
    @param _member      The member being added
    @return             The start time of the member
    */
    function setMember(address _member) external onlyOwner returns (uint256) {
        require(_member != address(0), "Can't check 0 address");
        Member memory member = Member({
            challengeID: 0,
            /* solium-disable-next-line security/no-block-members*/
            memberStartTime: now
        });
        members[_member] = member;

        /* solium-disable-next-line security/no-block-members*/
        return now;
    }

    /**
    @dev                        Edit the challengeID. Can be used to set a challenge or remove a
                                challenge for a member. Only Everest can call.
    @param _member              The member being checked
    @param _newChallengeID      The new challenge ID. Pass in 0 to remove a challenge.
    */
    function editChallengeID(address _member, uint256 _newChallengeID) external onlyOwner {
        require(_member != address(0), "Can't check 0 address");
        Member storage member = members[_member];
        member.challengeID = _newChallengeID;
    }

    /**
    @dev                Remove a member. Only Everest can call
    @param _member      The member being removed
    */
    function deleteMember(address _member) external onlyOwner {
        require(_member != address(0), "Can't check 0 address");
        delete members[_member];
    }
}