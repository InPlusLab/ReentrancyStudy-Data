/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

// File: contracts/interfaces/IAaveOracle.sol

pragma solidity ^0.5.0;

interface IAaveOracle {
    // TODO rename back to getOracleProphecy
    function getAssetPrice(address _asset) external view returns (uint256);
    function prophecies(address _asset) external view returns (uint64, uint96, uint96);
    function submitProphecy(address _asset, uint96 _sybilProphecy, uint96 _oracleProphecy) external;
    function isSybilWhitelisted(address _sybil) external view returns (bool);
}

// File: contracts/AaveOracle.sol

pragma solidity ^0.5.0;


contract AaveOracle is IAaveOracle {
    struct TimestampedProphecy {
        uint64 timestamp;
        uint96 sybilProphecy;
        uint96 oracleProphecy;
    }

    event ProphecySubmitted(
        address indexed _sybil,
        address indexed _asset,
        uint96 _sybilProphecy,
        uint96 _oracleProphecy
    );

    event SybilWhitelisted(address sybil);

    // Asset => price prophecy
    mapping(address => TimestampedProphecy) public prophecies;

    // Whitelisted sybils allowed to submit prices
    mapping(address => bool) private sybils;

    modifier onlySybil {
        require(isSybilWhitelisted(msg.sender), "INVALID_SYBIL");
        _;
    }

    constructor(address[] memory _sybils) public {
        internalWhitelistSybils(_sybils);
    }

    /// @notice Internal function to whitelist a list of sybils
    /// @param _sybils The addresses of the sybils
    function internalWhitelistSybils(address[] memory _sybils) internal {
        for (uint256 i = 0; i < _sybils.length; i++) {
            sybils[_sybils[i]] = true;
            emit SybilWhitelisted(_sybils[i]);
        }
    }

    /// @notice Submits a new prophecy for an asset
    /// - Only callable by whitelisted sybils
    /// @param _asset The asset address
    /// @param _sybilProphecy The new individual prophecy of the sybil
    /// @param _oracleProphecy The offchain calculated prophecy from all the currently valid ones
    function submitProphecy(address _asset, uint96 _sybilProphecy, uint96 _oracleProphecy) external onlySybil {
        prophecies[_asset] = TimestampedProphecy(uint64(block.timestamp), _sybilProphecy, _oracleProphecy);
        emit ProphecySubmitted(msg.sender, _asset, _sybilProphecy, _oracleProphecy);
    }

    /// @notice Gets the current prophecy for an asset
    /// @param _asset The asset address
    function getAssetPrice(address _asset) external view returns (uint256) {
        return uint256(prophecies[_asset].oracleProphecy);
    }

    /// @notice Gets the data of the current prophecy for an asset
    /// @param _asset The asset address
    function getProphecy(address _asset) external view returns (uint64, uint96, uint96) {
        TimestampedProphecy memory _prophecy = prophecies[_asset];
        return (_prophecy.timestamp, _prophecy.sybilProphecy, _prophecy.oracleProphecy);
    }

    /// @notice Return a bool with the whitelisting state of a sybil
    /// @param _sybil The address of the sybil
    function isSybilWhitelisted(address _sybil) public view returns (bool) {
        return sybils[_sybil];
    }

}