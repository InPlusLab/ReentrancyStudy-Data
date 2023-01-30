pragma solidity ^0.5.2;

import "./MiniMeTokenInterface.sol";
import "./ApproveAndCallFallBack.sol";
import "./SafeMath.sol";
import "./BancorFormula.sol";
import "./Controlled.sol";


contract Discover is Controlled, ApproveAndCallFallBack, BancorFormula {
    using SafeMath for uint;

    // Could be any MiniMe token
    MiniMeTokenInterface SNT;

    // Total SNT in circulation
    uint public total;

    // Parameter to calculate Max SNT any one DApp can stake
    uint public ceiling;

    // The max amount of tokens it is possible to stake, as a percentage of the total in circulation
    uint public max;

    // Decimal precision for this contract
    uint public decimals;

    // Prevents overflows in votesMinted
    uint public safeMax;

    // Whether we need more than an id param to identify arbitrary data must still be discussed.
    struct Data {
        address developer;
        bytes32 id;
        bytes32 metadata;
        uint balance;
        uint rate;
        uint available;
        uint votesMinted;
        uint votesCast;
        uint effectiveBalance;
    }

    Data[] public dapps;
    mapping(bytes32 => uint) public id2index;
    mapping(bytes32 => bool) public existingIDs;

    event DAppCreated(bytes32 indexed id, uint newEffectiveBalance);
    event Upvote(bytes32 indexed id, uint newEffectiveBalance);
    event Downvote(bytes32 indexed id, uint newEffectiveBalance);
    event Withdraw(bytes32 indexed id, uint newEffectiveBalance);
    event MetadataUpdated(bytes32 indexed id);
    event CeilingUpdated(uint oldCeiling, uint newCeiling);


    constructor(MiniMeTokenInterface _SNT) public {
        SNT = _SNT;

        total = 6804870174;

        ceiling = 292;   // See here for more: https://observablehq.com/@andytudhope/dapp-store-snt-curation-mechanism

        decimals = 1000000; // 4 decimal points for %, 2 because we only use 1/100th of total in circulation

        max = total.mul(ceiling).div(decimals);

        safeMax = uint(77).mul(max).div(100); // Limited by accuracy of BancorFormula
    }

    /**
     * @dev Update ceiling
     * @param _newCeiling New ceiling value
     */
    function setCeiling(uint _newCeiling) external onlyController {
        emit CeilingUpdated(ceiling, _newCeiling);

        ceiling = _newCeiling;
        max = total.mul(ceiling).div(decimals);
        safeMax = uint(77).mul(max).div(100);
    }

    /**
     * @dev Anyone can create a DApp (i.e an arb piece of data this contract happens to care about).
     * @param _id bytes32 unique identifier.
     * @param _amount of tokens to stake on initial ranking.
     * @param _metadata metadata hex string
     */
    function createDApp(bytes32 _id, uint _amount, bytes32 _metadata) external {
        _createDApp(
            msg.sender,
            _id,
            _amount,
            _metadata);
    }

    /**
     * @dev Sends SNT directly to the contract, not the developer. This gets added to the DApp's balance, no curve required.
     * @param _id bytes32 unique identifier.
     * @param _amount of tokens to stake on DApp's ranking. Used for upvoting + staking more.
     */
    function upvote(bytes32 _id, uint _amount) external {
        _upvote(msg.sender, _id, _amount);
    }

    /**
     * @dev Sends SNT to the developer and lowers the DApp's effective balance by 1%
     * @param _id bytes32 unique identifier.
     * @param _amount uint, included for approveAndCallFallBack
     */
    function downvote(bytes32 _id, uint _amount) external {
        _downvote(msg.sender, _id, _amount);
    }

    /**
     * @dev Developers can withdraw an amount not more than what was available of the
        SNT they originally staked minus what they have already received back in downvotes.
     * @param _id bytes32 unique identifier.
     * @return max SNT that can be withdrawn == available SNT for DApp.
     */
    function withdrawMax(bytes32 _id) external view returns(uint) {
        Data storage d = _getDAppById(_id);
        return d.available;
    }

    /**
     * @dev Developers can withdraw an amount not more than what was available of the
        SNT they originally staked minus what they have already received back in downvotes.
     * @param _id bytes32 unique identifier.
     * @param _amount of tokens to withdraw from DApp's overall balance.
     */
    function withdraw(bytes32 _id, uint _amount) external {

        Data storage d = _getDAppById(_id);

        uint256 tokensQuantity = _amount.div(1 ether);

        require(msg.sender == d.developer, "Only the developer can withdraw SNT staked on this data");
        require(tokensQuantity <= d.available, "You can only withdraw a percentage of the SNT staked, less what you have already received");

        uint precision;
        uint result;

        d.balance = d.balance.sub(tokensQuantity);
        d.rate = decimals.sub(d.balance.mul(decimals).div(max));
        d.available = d.balance.mul(d.rate);

        (result, precision) = BancorFormula.power(
            d.available,
            decimals,
            uint32(decimals),
            uint32(d.rate));

        d.votesMinted = result >> precision;
        if (d.votesCast > d.votesMinted) {
            d.votesCast = d.votesMinted;
        }

        uint temp1 = d.votesCast.mul(d.rate).mul(d.available);
        uint temp2 = d.votesMinted.mul(decimals).mul(decimals);
        uint effect = temp1.div(temp2);

        d.effectiveBalance = d.balance.sub(effect);

        require(SNT.transfer(d.developer, _amount), "Transfer failed");

        emit Withdraw(_id, d.effectiveBalance);
    }

    /**
     * dev Set the content for the dapp
     * @param _id bytes32 unique identifier.
     * @param _metadata metadata info
     */
    function setMetadata(bytes32 _id, bytes32 _metadata) external {
        uint dappIdx = id2index[_id];
        Data storage d = dapps[dappIdx];
        require(d.developer == msg.sender, "Only the developer can update the metadata");
        d.metadata = _metadata;
        emit MetadataUpdated(_id);
    }

    /**
     * @dev Used in UI in order to fetch all dapps
     * @return dapps count
     */
    function getDAppsCount() external view returns(uint) {
        return dapps.length;
    }

    /**
     * @notice Support for "approveAndCall".
     * @param _from Who approved.
     * @param _amount Amount being approved, needs to be equal `_amount` or `cost`.
     * @param _token Token being approved, needs to be `SNT`.
     * @param _data Abi encoded data with selector of `register(bytes32,address,bytes32,bytes32)`.
     */
    function receiveApproval(
        address _from,
        uint256 _amount,
        address _token,
        bytes calldata _data
    )
        external
    {
        require(_token == address(SNT), "Wrong token");
        require(_token == address(msg.sender), "Wrong account");
        require(_data.length <= 196, "Incorrect data");

        bytes4 sig;
        bytes32 id;
        uint256 amount;
        bytes32 metadata;

        (sig, id, amount, metadata) = abiDecodeRegister(_data);
        require(_amount == amount, "Wrong amount");

        if (sig == bytes4(0x7e38d973)) {
            _createDApp(
                _from,
                id,
                amount,
                metadata);
        } else if (sig == bytes4(0xac769090)) {
            _downvote(_from, id, amount);
        } else if (sig == bytes4(0x2b3df690)) {
            _upvote(_from, id, amount);
        } else {
            revert("Wrong method selector");
        }
    }

    /**
     * @dev Used in UI to display effect on ranking of user's donation
     * @param _id bytes32 unique identifier.
     * @param _amount of tokens to stake/"donate" to this DApp's ranking.
     * @return effect of donation on DApp's effectiveBalance
     */
    function upvoteEffect(bytes32 _id, uint _amount) external view returns(uint effect) {
        Data memory d = _getDAppById(_id);
        require(d.balance.add(_amount) <= safeMax, "You cannot upvote by this much, try with a lower amount");

        // Special case - no downvotes yet cast
        if (d.votesCast == 0) {
            return _amount;
        }

        uint precision;
        uint result;

        uint mBalance = d.balance.add(_amount);
        uint mRate = decimals.sub(mBalance.mul(decimals).div(max));
        uint mAvailable = mBalance.mul(mRate);

        (result, precision) = BancorFormula.power(
            mAvailable,
            decimals,
            uint32(decimals),
            uint32(mRate));

        uint mVMinted = result >> precision;

        uint temp1 = d.votesCast.mul(mRate).mul(mAvailable);
        uint temp2 = mVMinted.mul(decimals).mul(decimals);
        uint mEffect = temp1.div(temp2);

        uint mEBalance = mBalance.sub(mEffect);

        return (mEBalance.sub(d.effectiveBalance));
    }

     /**
     * @dev Downvotes always remove 1% of the current ranking.
     * @param _id bytes32 unique identifier.
     * @return balance_down_by, votes_required, cost
     */
    function downvoteCost(bytes32 _id) external view returns(uint b, uint vR, uint c) {
        Data memory d = _getDAppById(_id);
        return _downvoteCost(d);
    }

    function _createDApp(
        address _from,
        bytes32 _id,
        uint _amount,
        bytes32 _metadata
        )
      internal
      {
        require(!existingIDs[_id], "You must submit a unique ID");

        uint256 tokensQuantity = _amount.div(1 ether);

        require(tokensQuantity > 0, "You must spend some SNT to submit a ranking in order to avoid spam");
        require (tokensQuantity <= safeMax, "You cannot stake more SNT than the ceiling dictates");

        uint dappIdx = dapps.length;

        dapps.length++;

        Data storage d = dapps[dappIdx];
        d.developer = _from;
        d.id = _id;
        d.metadata = _metadata;

        uint precision;
        uint result;

        d.balance = tokensQuantity;
        d.rate = decimals.sub((d.balance).mul(decimals).div(max));
        d.available = d.balance.mul(d.rate);

        (result, precision) = BancorFormula.power(
            d.available,
            decimals,
            uint32(decimals),
            uint32(d.rate));

        d.votesMinted = result >> precision;
        d.votesCast = 0;
        d.effectiveBalance = tokensQuantity;

        id2index[_id] = dappIdx;
        existingIDs[_id] = true;

        require(SNT.transferFrom(_from, address(this), _amount), "Transfer failed");

        emit DAppCreated(_id, d.effectiveBalance);
    }

    function _upvote(address _from, bytes32 _id, uint _amount) internal {
        uint256 tokensQuantity = _amount.div(1 ether);
        require(tokensQuantity > 0, "You must send some SNT in order to upvote");

        Data storage d = _getDAppById(_id);

        require(d.balance.add(tokensQuantity) <= safeMax, "You cannot upvote by this much, try with a lower amount");

        uint precision;
        uint result;

        d.balance = d.balance.add(tokensQuantity);
        d.rate = decimals.sub((d.balance).mul(decimals).div(max));
        d.available = d.balance.mul(d.rate);

        (result, precision) = BancorFormula.power(
            d.available,
            decimals,
            uint32(decimals),
            uint32(d.rate));

        d.votesMinted = result >> precision;

        uint temp1 = d.votesCast.mul(d.rate).mul(d.available);
        uint temp2 = d.votesMinted.mul(decimals).mul(decimals);
        uint effect = temp1.div(temp2);

        d.effectiveBalance = d.balance.sub(effect);

        require(SNT.transferFrom(_from, address(this), _amount), "Transfer failed");

        emit Upvote(_id, d.effectiveBalance);
    }

    function _downvote(address _from, bytes32 _id, uint _amount) internal {
        uint256 tokensQuantity = _amount.div(1 ether);
        Data storage d = _getDAppById(_id);
        (uint b, uint vR, uint c) = _downvoteCost(d);

        require(tokensQuantity == c, "Incorrect amount: valid iff effect on ranking is 1%");

        d.available = d.available.sub(tokensQuantity);
        d.votesCast = d.votesCast.add(vR);
        d.effectiveBalance = d.effectiveBalance.sub(b);

        require(SNT.transferFrom(_from, d.developer, _amount), "Transfer failed");

        emit Downvote(_id, d.effectiveBalance);
    }

    function _downvoteCost(Data memory d) internal view returns(uint b, uint vR, uint c) {
        uint balanceDownBy = (d.effectiveBalance.div(100));
        uint votesRequired = (balanceDownBy.mul(d.votesMinted).mul(d.rate)).div(d.available);
        uint votesAvailable = d.votesMinted.sub(d.votesCast).sub(votesRequired);
        uint temp = (d.available.div(votesAvailable)).mul(votesRequired);
        uint cost = temp.div(decimals);
        return (balanceDownBy, votesRequired, cost);
    }

    /**
     * @dev Used internally in order to get a dapp while checking if it exists
     * @return existing dapp
     */
    function _getDAppById(bytes32 _id) internal view returns(Data storage d) {
        uint dappIdx = id2index[_id];
        d = dapps[dappIdx];
        require(d.id == _id, "Error fetching correct data");
    }

     /**
     * @dev Decodes abi encoded data with selector for "functionName(bytes32,uint256)".
     * @param _data Abi encoded data.
     * @return Decoded registry call.
     */
    function abiDecodeRegister(
        bytes memory _data
    )
        private
        pure
        returns(
            bytes4 sig,
            bytes32 id,
            uint256 amount,
            bytes32 metadata
        )
    {
        assembly {
            sig := mload(add(_data, add(0x20, 0)))
            id := mload(add(_data, 36))
            amount := mload(add(_data, 68))
            metadata := mload(add(_data, 100))
        }
    }
}
