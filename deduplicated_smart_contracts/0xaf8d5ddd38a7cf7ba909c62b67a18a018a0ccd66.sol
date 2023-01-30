pragma solidity ^0.5.4;

import "./AuctionityStorage0.sol";
import "./AuctionityOwnable_V1.sol";
import "./AuctionityLibrary_V1.sol";

/**
 * @title ProxyUpdate
 */
contract AuctionityProxyUpdate_V1 is AuctionityLibrary_V1 {
    event LogSelectorAdded_V1(bytes4 selector, address delegate);
    event LogSelectorUpdated_V1(
        bytes4 selector,
        address delegate,
        address previousDelegate
    );
    event LogSelectorRemoved_V1(bytes4 selector, address delegate);
    event LogProxyFallbackContractUpdated_V1(address proxyFallbackContract);

    /// @notice Implement all selector for initial proxy update and ownable
    /// @dev this is call only by proxy contract
    /// @param _proxyUpdates address : contract proxyUpdate (this contract deployed)
    /// @param _ownable address : contract ownable
    function initProxyContract_V1(address _proxyUpdates, address _ownable)
        public
    {
        require(contractOwner == address(0), "Contract owner has been set.");
        contractOwner = msg.sender;

        _initProxyContract_V1(
            _proxyUpdates,
            bytes4(keccak256("addSelectors_V1(address,bytes4[])"))
        );
        _initProxyContract_V1(
            _proxyUpdates,
            bytes4(keccak256("updateSelectors_V1(address,bytes4[])"))
        );
        _initProxyContract_V1(
            _proxyUpdates,
            bytes4(keccak256("removeSelectors_V1(bytes4[])"))
        );
        _initProxyContract_V1(
            _proxyUpdates,
            bytes4(keccak256("updateProxyFallbackContract_V1(address)"))
        );
        _initProxyContract_V1(
            _ownable,
            bytes4(keccak256("getContractOwner_V1()"))
        );
        _initProxyContract_V1(
            _ownable,
            bytes4(keccak256("delegatedReceiveIsContractOwner_V1()"))
        );
        _initProxyContract_V1(
            _ownable,
            bytes4(keccak256("isContractOwner_V1()"))
        );
        _initProxyContract_V1(
            _ownable,
            bytes4(keccak256("renounceOwnership_V1()"))
        );
        _initProxyContract_V1(
            _ownable,
            bytes4(keccak256("transferOwnership_V1(address)"))
        );

    }

    /// @notice Add selector only in intitate contract
    /// @param _delegate address : contract delegated
    /// @param _selector bytes4 : selector implemented for delegated contract
    function _initProxyContract_V1(address _delegate, bytes4 _selector)
        internal
    {
        require(
            delegates[_selector] == address(0),
            "_initProxyContract_V1 FuncId clash"
        );
        delegates[_selector] = _delegate;
        emit LogSelectorAdded_V1(_selector, _delegate);
    }

    /// @notice Add selector from proxy
    /// @param _delegate address : contract delegated
    /// @param _selectors bytes4[] : list of selector implemented for delegated contract
    function addSelectors_V1(address _delegate, bytes4[] memory _selectors)
        public
    {
        require(
            delegatedSendIsContractOwner_V1(),
            "addSelectors_V1 Contract owner"
        );

        require(_delegate != address(0), "delegate can't be zero address.");

        for (uint selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
            require(
                delegates[_selectors[selectorIndex]] == address(0),
                "FuncId clash."
            );
            delegates[_selectors[selectorIndex]] = _delegate;
            emit LogSelectorAdded_V1(_selectors[selectorIndex], _delegate);
        }
    }

    /// @notice Update selector from proxy
    /// @param _delegate address : contract delegated
    /// @param _selectors bytes4[] : list of selector implemented for delegated contract
    function updateSelectors_V1(address _delegate, bytes4[] memory _selectors)
        public
    {
        require(
            delegatedSendIsContractOwner_V1(),
            "updateSelectors_V1 Contract owner"
        );

        require(_delegate != address(0), "delegate can't be zero address.");

        for (uint selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
            require(
                delegates[_selectors[selectorIndex]] != address(0),
                "Selector does not exist."
            );
            address previousDelegate = delegates[_selectors[selectorIndex]];
            delegates[_selectors[selectorIndex]] = _delegate;
            emit LogSelectorUpdated_V1(
                _selectors[selectorIndex],
                _delegate,
                previousDelegate
            );

        }
    }

    /// @notice remove selector from proxy
    /// @param _selectors bytes4[] : list of selector implemented for delegated contract
    function removeSelectors_V1(bytes4[] memory _selectors) public {
        require(
            delegatedSendIsContractOwner_V1(),
            "removeSelectors_V1 Contract owner"
        );

        for (uint selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
            require(
                delegates[_selectors[selectorIndex]] != address(0),
                "Selector does not exist."
            );
            address previousDelegate = delegates[_selectors[selectorIndex]];
            delete delegates[_selectors[selectorIndex]];
            emit LogSelectorRemoved_V1(
                _selectors[selectorIndex],
                previousDelegate
            );

        }
    }

    /// @notice add a fallback contract for another selector unimplemented
    /// @param _proxyFallbackContract address : contract fallback delegated
    function updateProxyFallbackContract_V1(address _proxyFallbackContract)
        public
    {
        require(
            delegatedSendIsContractOwner_V1(),
            "updateProxyFallbackContract_V1 Contract owner"
        );

        proxyFallbackContract = _proxyFallbackContract;

        emit LogProxyFallbackContractUpdated_V1(_proxyFallbackContract);

    }
}
