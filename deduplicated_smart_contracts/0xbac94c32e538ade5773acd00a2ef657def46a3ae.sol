pragma solidity 0.5.8;

import "./ERC644Balances.sol";
import { ERC1820Client } from "./ERC1820Client.sol";


/**
 * @title ERC644 Database Contract
 * @author Panos
 */
contract CStore is ERC644Balances, ERC1820Client {

    address[] internal mDefaultOperators;
    mapping(address => bool) internal mIsDefaultOperator;
    mapping(address => mapping(address => bool)) internal mRevokedDefaultOperator;
    mapping(address => mapping(address => bool)) internal mAuthorizedOperators;

    /**
     * @notice Database construction
     * @param _totalSupply The total supply of the token
     */
    constructor(uint256 _totalSupply, address _initialOwner, address[] memory _defaultOperators) public
    {
        balances[_initialOwner] = _totalSupply;
        totalSupply = _totalSupply;
        mDefaultOperators = _defaultOperators;
        for (uint256 i = 0; i < mDefaultOperators.length; i++) { mIsDefaultOperator[mDefaultOperators[i]] = true; }

        setInterfaceImplementation("ERC644Balances", address(this));
    }

    /**
     * @notice Increase total supply by `_val`
     * @param _val Value to increase
     * @return Operation status
     */
    // solhint-disable-next-line no-unused-vars
    function incTotalSupply(uint _val) external onlyModule returns (bool) {
        return false;
    }

    /**
     * @notice Decrease total supply by `_val`
     * @param _val Value to decrease
     * @return Operation status
     */
     // solhint-disable-next-line no-unused-vars
     function decTotalSupply(uint _val) external onlyModule returns (bool) {
         return false;
     }

    /**
     * @notice moving `_amount` from `_from` to `_to`
     * @param _from The sender address
     * @param _to The receiving address
     * @param _amount The moving amount
     * @return bool The move result
     */
    function move(address _from, address _to, uint256 _amount) external
    onlyModule
    returns (bool) {
        balances[_from] = balances[_from].sub(_amount);
        emit BalanceAdj(msg.sender, _from, _amount, "-");
        balances[_to] = balances[_to].add(_amount);
        emit BalanceAdj(msg.sender, _to, _amount, "+");
        return true;
    }

    /**
     * @notice Setting operator `_operator` for `_tokenHolder`
     * @param _operator The operator to set status
     * @param _tokenHolder The token holder to set operator
     * @param _status The operator status
     * @return bool Status of operation
     */
    function setAuthorizedOperator(address _operator, address _tokenHolder, bool _status) external
    onlyModule
    returns (bool) {
        mAuthorizedOperators[_operator][_tokenHolder] = _status;
        return true;
    }

    /**
     * @notice Set revoke status for default operator `_operator` for `_tokenHolder`
     * @param _operator The default operator to set status
     * @param _tokenHolder The token holder to set operator
     * @param _status The operator status
     * @return bool Status of operation
     */
    function setRevokedDefaultOperator(address _operator, address _tokenHolder, bool _status) external
    onlyModule
    returns (bool) {
    mRevokedDefaultOperator[_operator][_tokenHolder] = _status;
        return true;
    }

    /**
     * @notice Getting operator `_operator` for `_tokenHolder`
     * @param _operator The operator address to get status
     * @param _tokenHolder The token holder address
     * @return bool Operator status
     */
    function getAuthorizedOperator(address _operator, address _tokenHolder) external
    view
    returns (bool) {
        return mAuthorizedOperators[_operator][_tokenHolder];
    }

    /**
     * @notice Getting default operator `_operator`
     * @param _operator The default operator address to get status
     * @return bool Default operator status
     */
    function getDefaultOperator(address _operator) external view returns (bool) {
        return mIsDefaultOperator[_operator];
    }

    /**
     * @notice Getting default operators
     * @return address[] Default operator addresses
     */
    function getDefaultOperators() external view returns (address[] memory) {
        return mDefaultOperators;
    }

    function getRevokedDefaultOperator(address _operator, address _tokenHolder) external view returns (bool) {
        return mRevokedDefaultOperator[_operator][_tokenHolder];
    }

    /**
     * @notice Increment `_acct` balance by `_val`
     * @param _acct Target account to increment balance.
     * @param _val Value to increment
     * @return Operation status
     */
    // solhint-disable-next-line no-unused-vars
    function incBalance(address _acct, uint _val) public onlyModule returns (bool) {
        return false;
    }

    /**
     * @notice Decrement `_acct` balance by `_val`
     * @param _acct Target account to decrement balance.
     * @param _val Value to decrement
     * @return Operation status
     */
     // solhint-disable-next-line no-unused-vars
     function decBalance(address _acct, uint _val) public onlyModule returns (bool) {
         return false;
     }
}

