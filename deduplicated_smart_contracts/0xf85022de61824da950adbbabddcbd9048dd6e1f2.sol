/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/globalConstraints/GlobalConstraintInterface.sol

pragma solidity ^0.5.11;


contract GlobalConstraintInterface {

    enum CallPhase { Pre, Post, PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    /**
     * @dev when return if this globalConstraints is pre, post or both.
     * @return CallPhase enum indication  Pre, Post or PreAndPost.
     */
    function when() public returns(CallPhase);
}

// File: contracts/globalConstraints/TokenCapGC.sol

pragma solidity ^0.5.11;




/**
 * @title Token Cap Global Constraint
 * @dev A simple global constraint to cap the number of tokens.
 */

contract TokenCapGC {
    // A set of parameters, on which the cap will be checked:
    struct Parameters {
        IERC20 token;
        uint256 cap;
    }

    // Mapping from the hash of the parameters to the parameters themselves:
    mapping (bytes32=>Parameters) public parameters;

    /**
     * @dev adding a new set of parameters
     * @param  _token the token to add to the params.
     * @param _cap the cap to check the total supply against.
     * @return the calculated parameters hash
     */
    function setParameters(IERC20 _token, uint256 _cap) public returns(bytes32) {
        bytes32 paramsHash = getParametersHash(_token, _cap);
        parameters[paramsHash].token = _token;
        parameters[paramsHash].cap = _cap;
        return paramsHash;
    }

    /**
     * @dev calculate and returns the hash of the given parameters
     * @param  _token the token to add to the params.
     * @param _cap the cap to check the total supply against.
     * @return the calculated parameters hash
     */
    function getParametersHash(IERC20 _token, uint256 _cap) public pure returns(bytes32) {
        return (keccak256(abi.encodePacked(_token, _cap)));
    }

    /**
     * @dev check the constraint after the action.
     * This global constraint only checks the state after the action, so here we just return true:
     * @return true
     */
    function pre(address, bytes32, bytes32) public pure returns(bool) {
        return true;
    }

    /**
     * @dev check the total supply cap.
     * @param  _paramsHash the parameters hash to check the total supply cap against.
     * @return bool which represents a success
     */
    function post(address, bytes32 _paramsHash, bytes32) public view returns(bool) {
        if ((parameters[_paramsHash].token != IERC20(0)) &&
            (parameters[_paramsHash].token.totalSupply() > parameters[_paramsHash].cap)) {
            return false;
        }
        return true;
    }

    /**
     * @dev when return if this globalConstraints is pre, post or both.
     * @return CallPhase enum indication  Pre, Post or PreAndPost.
     */
    function when() public pure returns(GlobalConstraintInterface.CallPhase) {
        return GlobalConstraintInterface.CallPhase.Post;
    }
}