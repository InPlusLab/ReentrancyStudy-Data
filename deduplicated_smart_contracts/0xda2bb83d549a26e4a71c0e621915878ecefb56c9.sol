pragma solidity 0.5.9;

contract AverageBlockTime {
    struct Snapshot {
        uint128 timestamp;
        uint128 blockNumber;
    }
    Snapshot snapshot0;
    Snapshot snapshot1;
    uint256 minUpdateDelay;

    constructor(uint256 _minUpdateDelay, uint128 _snapshotTimestamp, uint128 _snapshotBlockNumber) public {
        require(block.timestamp - _snapshotTimestamp >= _minUpdateDelay, "require an older snapshot");
        require(_snapshotBlockNumber < block.number, "can't use a future snapshot");
        minUpdateDelay = _minUpdateDelay;
        snapshot0.timestamp = _snapshotTimestamp;
        snapshot0.blockNumber = _snapshotBlockNumber;
    }

    function update() external {
        Snapshot memory _snapshot0 = snapshot0;
        Snapshot memory _snapshot1 = snapshot1;
        if(_snapshot0.timestamp > _snapshot1.timestamp) {
            if(block.timestamp - _snapshot1.timestamp >= minUpdateDelay) {
                snapshot1.timestamp = uint128(block.timestamp);
                snapshot1.blockNumber = uint128(block.number);
            }
        } else {
            if(block.timestamp - _snapshot0.timestamp >= minUpdateDelay) {
                snapshot0.timestamp = uint128(block.timestamp);
                snapshot0.blockNumber = uint128(block.number);
            }
        }
    }

    function getAverageBlockTimeInMicroSeconds() external view returns (uint256) {
        Snapshot storage snapshot = snapshot0;
        if(snapshot.timestamp > snapshot1.timestamp) {
            if(block.timestamp - snapshot.timestamp < minUpdateDelay) {
                snapshot = snapshot1;
            }
        } else {
            if(block.timestamp - snapshot1.timestamp >= minUpdateDelay) {
                snapshot = snapshot1;
            }
        }
        return ((block.timestamp - snapshot.timestamp) * 1000) / (block.number - snapshot.blockNumber);
    }
}