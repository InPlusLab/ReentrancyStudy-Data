/**
 *Submitted for verification at Etherscan.io on 2019-07-02
*/

pragma solidity >=0.5.0;

contract PollingEvents {
    event PollCreated(
        address indexed creator,
        uint256 blockCreated,
        uint256 pollId,
        uint256 startDate,
        uint256 endDate,
        string multiHash
    );

    event PollWithdrawn(
        address indexed creator,
        uint256 blockWithdrawn,
        uint256 pollId
    );

    event Voted(
        address indexed voter,
        uint256 indexed pollId,
        uint256 indexed optionId
    );
}

contract PollingEmitter is PollingEvents {
    uint256 public npoll;

    function createPoll(uint256 startDate, uint256 endDate, string calldata multiHash)
        external
    {
        require(endDate > startDate, "polling-invalid-poll-window");
        emit PollCreated(
            msg.sender,
            block.number,
            npoll,
            startDate,
            endDate,
            multiHash
        );
        require(npoll < uint(-1), "polling-too-many-polls");
        npoll++;
    }

    function withdrawPoll(uint256 pollId)
        external
    {
        emit PollWithdrawn(msg.sender, block.number, pollId);
    }

    function vote(uint256 pollId, uint256 optionId)
        external
    {
        emit Voted(msg.sender, pollId, optionId);
    }
}