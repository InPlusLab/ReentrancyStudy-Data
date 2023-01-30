pragma solidity ^0.5.4;

import "./AuctionityLibrary_V1.sol";

/// @title AuctionityOracable_V1
contract AuctionityOracable_V1 is AuctionityLibrary_V1 {
    /// @notice event LogOracleTransfered_V1
    event LogOracleTransfered_V1(
        address indexed previousOracle,
        address indexed newOracle
    );

    /// @notice delegate receive of getOracle
    /// @return  _oracle address
    function delegatedReceiveGetOracle_V1()
        public
        payable
        returns (address _oracle)
    {
        return getOracle_V1();
    }

    /// @notice getter oracle address
    /// @return  _oracle address
    function getOracle_V1() public view returns (address _oracle) {
        return oracle;
    }

    /// @notice verify if msg.sender is oracle
    /// @return _isOracle bool
    function isOracle_V1() public view returns (bool _isOracle) {
        return msg.sender == oracle;
    }

    /**
     * @return true if `_oracle` is the oracle of the contract.
     */

    /// @notice verify oracle address
    /// @param _oracle address : address to compare
    /// @return _isOracle bool
    function verifyOracle_V1(address _oracle)
        public
        view
        returns (bool _isOracle)
    {
        return _oracle == oracle;
    }

    /// @notice Allows the current oracle or owner to set a new oracle.
    /// @param _newOracle The address to transfer oracleship to.
    function transferOracle_V1(address _newOracle) public {
        require(
            isOracle_V1() || delegatedSendIsContractOwner_V1(),
            "Is not Oracle or Owner"
        );
        _transferOracle_V1(_newOracle);
    }

    /// @notice Transfers control of the contract to a newOracle.
    /// @param _newOracle The address to transfer oracleship to.
    function _transferOracle_V1(address _newOracle) internal {
        require(_newOracle != address(0), "Oracle can't be 0x0");
        emit LogOracleTransfered_V1(oracle, _newOracle);
        oracle = _newOracle;
    }
}
