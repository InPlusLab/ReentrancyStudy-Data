pragma solidity 0.5.8;

import "./ERC777ERC20Compat.sol";
import "./SafeGuard.sol";
import { CStore } from "./CStore.sol"; //TODO: Convert all imports like this

contract CALL is ERC777ERC20Compat, SafeGuard {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _granularity,
        uint256 _totalSupply,
        address _initialOwner,
        address[] memory _defaultOperators
    )
    public ERC777ERC20Compat(_name, _symbol, _granularity, _totalSupply, _initialOwner, _defaultOperators)
    {
        requireMultiple(_totalSupply);
        require(balancesDB.setModule(address(this), true), "Cannot enable access to the database.");
        balancesDB.transferOwnership(_initialOwner);

        callRecipient(msg.sender, address(0), _initialOwner, _totalSupply, "", "", true);

        emit Minted(msg.sender, _initialOwner, _totalSupply, "", "");
        if (mErc20compatible) { emit Transfer(address(0), _initialOwner, _totalSupply); }
    }

    /**
     * @notice change the balances database to `_newDB`
     * @param _newDB The new balances database address
     */
    function changeBalancesDB(address _newDB) public onlyOwner {
        balancesDB = CStore(_newDB);
    }

    /**
     * @notice Disables the ERC20 interface. This function can only be called
     * by the owner.
     */
    function disableERC20() public onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("ERC20Token", address(0));
    }

    /**
     * @notice Re enables the ERC20 interface. This function can only be called
     *  by the owner.
     */
    function enableERC20() public onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", address(this));
    }

    /**
     * @dev Transfer the specified amounts of tokens to the specified addresses.
     * @dev Be aware that there is no check for duplicate recipients.
     * @param _toAddresses Receiver addresses.
     * @param _amounts Amounts of tokens that will be transferred.
     */
    function multiPartyTransfer(address[] calldata _toAddresses, uint256[] calldata _amounts) external erc20 {
        /* Ensures _toAddresses array is less than or equal to 255 */
        require(_toAddresses.length <= 255, "Unsupported number of addresses.");
        /* Ensures _toAddress and _amounts have the same number of entries. */
        require(_toAddresses.length == _amounts.length, "Provided addresses does not equal to provided sums.");

        for (uint8 i = 0; i < _toAddresses.length; i++) {
            transfer(_toAddresses[i], _amounts[i]);
        }
    }

    /**
    * @dev Transfer the specified amounts of tokens to the specified addresses from authorized balance of sender.
    * @dev Be aware that there is no check for duplicate recipients.
    * @param _from The address of the sender
    * @param _toAddresses The addresses of the recipients (MAX 255)
    * @param _amounts The amounts of tokens to be transferred
    */
    function multiPartyTransferFrom(address _from, address[] calldata _toAddresses, uint256[] calldata _amounts) external erc20 {
        /* Ensures _toAddresses array is less than or equal to 255 */
        require(_toAddresses.length <= 255, "Unsupported number of addresses.");
        /* Ensures _toAddress and _amounts have the same number of entries. */
        require(_toAddresses.length == _amounts.length, "Provided addresses does not equal to provided sums.");

        for (uint8 i = 0; i < _toAddresses.length; i++) {
            transferFrom(_from, _toAddresses[i], _amounts[i]);
        }
    }

    /**
     * @dev Transfer the specified amounts of tokens to the specified addresses.
     * @dev Be aware that there is no check for duplicate recipients.
     * @param _toAddresses Receiver addresses.
     * @param _amounts Amounts of tokens that will be transferred.
     * @param _userData User supplied data
     */
    function multiPartySend(address[] memory _toAddresses, uint256[] memory _amounts, bytes memory _userData) public {
        /* Ensures _toAddresses array is less than or equal to 255 */
        require(_toAddresses.length <= 255, "Unsupported number of addresses.");
        /* Ensures _toAddress and _amounts have the same number of entries. */
        require(_toAddresses.length == _amounts.length, "Provided addresses does not equal to provided sums.");

        for (uint8 i = 0; i < _toAddresses.length; i++) {
            doSend(msg.sender,  msg.sender, _toAddresses[i], _amounts[i], _userData, "", true);
        }
    }

    /**
    * @dev Transfer the specified amounts of tokens to the specified addresses as `_from`.
    * @dev Be aware that there is no check for duplicate recipients.
    * @param _from Address to use as sender
    * @param _to Receiver addresses.
    * @param _amounts Amounts of tokens that will be transferred.
    * @param _userData User supplied data
    * @param _operatorData Operator supplied data
    */
    function multiOperatorSend(address _from, address[] calldata _to, uint256[] calldata _amounts, bytes calldata _userData, bytes calldata _operatorData)
    external {
        /* Ensures _toAddresses array is less than or equal to 255 */
        require(_to.length <= 255, "Unsupported number of addresses.");
        /* Ensures _toAddress and _amounts have the same number of entries. */
        require(_to.length == _amounts.length, "Provided addresses does not equal to provided sums.");

        for (uint8 i = 0; i < _to.length; i++) {
            require(isOperatorFor(msg.sender, _from), "Not an operator"); //TODO check for denial of service
            doSend(msg.sender, _from, _to[i], _amounts[i], _userData, _operatorData, true);
        }
    }
}

