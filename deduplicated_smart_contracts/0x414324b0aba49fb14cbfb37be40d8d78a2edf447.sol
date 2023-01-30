/**
 *Submitted for verification at Etherscan.io on 2019-09-14
*/

// File: contracts/SafeMath.sol

/**
* MIT License
*
* Copyright (c) 2016-2019 zOS Global Limited
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: contracts/IERC20.sol

/**
* MIT License
*
* Copyright (c) 2016-2019 zOS Global Limited
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;

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

// File: contracts/ERC20.sol

/**
* MIT License
*
* Copyright (c) 2016-2019 zOS Global Limited
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;



/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

// File: contracts/ERC20Claimable.sol

/**
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2019 Equility AG (alethena.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;




/**
 * @title Claimable
 * In case of tokens that represent real-world assets such as shares of a company, one needs a way
 * to handle lost private keys. With physical certificates, courts can declare share certificates as
 * invalid so the company can issue replacements. Here, we want a solution that does not depend on
 * third parties to resolve such cases. Instead, when someone has lost a private key, he can use the
 * declareLost function to post a deposit and claim that the shares assigned to a specific address are
 * lost. To prevent front running, a commit reveal scheme is used. If he actually is the owner of the shares,
 * he needs to wait for a certain period and can then reclaim the lost shares as well as the deposit.
 * If he is an attacker trying to claim shares belonging to someone else, he risks losing the deposit
 * as it can be claimed at anytime by the rightful owner.
 * Furthermore, if "getClaimDeleter" is defined in the subclass, the returned address is allowed to
 * delete claims, returning the collateral. This can help to prevent obvious cases of abuse of the claim
 * function.
 */

contract ERC20Claimable is ERC20 {

    using SafeMath for uint256;
    using SafeMath for uint32;

    // A struct that represents a claim made
    struct Claim {
        address claimant; // the person who created the claim
        uint256 collateral; // the amount of collateral deposited
        uint32 timestamp;  // the timestamp of the block in which the claim was made
        address currencyUsed; // The currency (XCHF) can be updated, we record the currency used for every request
    }

    // Every claim must be preceded by an obscured preclaim in order to prevent front-running
    struct PreClaim {
        bytes32 msghash; // the hash of nonce + address to be claimed
        uint256 timestamp;  // the timestamp of the block in which the preclaim was made
    }

    uint256 public claimPeriod = 180 days; // Default of 180 days;
    uint256 public preClaimPeriod = 1 days; // One day. Minimum waiting period between preClaim and Claim;
    uint256 public preClaimPeriodEnd = 2 days; // Two days. Maximum waiting period between preClaim and Claim;

    mapping(address => Claim) public claims; // there can be at most one claim per address, here address is claimed address
    mapping(address => PreClaim) public preClaims; // there can be at most one preclaim per address, here address is claimer
    mapping(address => bool) public claimingDisabled; // disable claimability (e.g. for long term storage)

    // ERC-20 token that can be used as collateral or 0x0 if disabled
    address public customCollateralAddress;
    uint256 public customCollateralRate;

    /**
     * Returns the collateral rate for the given collateral type and 0 if that type
     * of collateral is not accepted. By default, only the token itself is accepted at
     * a rate of 1:1.
     *
     * Subclasses should override this method if they want to add additional types of
     * collateral.
     */
    function getCollateralRate(address collateralType) public view returns (uint256) {
        if (collateralType == address(this)) {
            return 1;
        } else if (collateralType == customCollateralAddress) {
            return customCollateralRate;
        } else {
            return 0;
        }
    }

    /**
     * Allows subclasses to set a custom collateral besides the token itself.
     * The collateral must be an ERC-20 token that returns true on successful transfers and
     * throws an exception or returns false on failure.
     * Also, do not forget to multiply the rate in accordance with the number of decimals of the collateral.
     * For example, rate should be 7*10**18 for 7 units of a collateral with 18 decimals.
     */
    function _setCustomClaimCollateral(address collateral, uint256 rate) internal {
        customCollateralAddress = collateral;
        if (customCollateralAddress == address(0)) {
            customCollateralRate = 0; // disabled
        } else {
            require(rate > 0, "Collateral rate can't be zero");
            customCollateralRate = rate;
        }
        emit CustomClaimCollateralChanged(collateral, rate);
    }

    function getClaimDeleter() public returns (address);

    /**
     * Allows subclasses to change the claim period, but not to fewer than 90 days.
     */
    function _setClaimPeriod(uint256 claimPeriodInDays) internal {
        require(claimPeriodInDays > 90, "Claim period must be at least 90 days"); // must be at least 90 days
        uint256 claimPeriodInSeconds = claimPeriodInDays.mul(1 days);
        claimPeriod = claimPeriodInSeconds;
        emit ClaimPeriodChanged(claimPeriod);
    }

    function setClaimable(bool enabled) public {
        claimingDisabled[msg.sender] = !enabled;
    }

    /**
     * Some users might want to disable claims for their address completely.
     * For example if they use a deep cold storage solution or paper wallet.
     */
    function isClaimsEnabled(address target) public view returns (bool) {
        return !claimingDisabled[target];
    }

    event ClaimMade(address indexed lostAddress, address indexed claimant, uint256 balance);
    event ClaimPrepared(address indexed claimer);
    event ClaimCleared(address indexed lostAddress, uint256 collateral);
    event ClaimDeleted(address indexed lostAddress, address indexed claimant, uint256 collateral);
    event ClaimResolved(address indexed lostAddress, address indexed claimant, uint256 collateral);
    event ClaimPeriodChanged(uint256 newClaimPeriodInDays);
    event CustomClaimCollateralChanged(address newCustomCollateralAddress, uint256 newCustomCollareralRate);

  /** Anyone can declare that the private key to a certain address was lost by calling declareLost
    * providing a deposit/collateral. There are three possibilities of what can happen with the claim:
    * 1) The claim period expires and the claimant can get the deposit and the shares back by calling resolveClaim
    * 2) The "lost" private key is used at any time to call clearClaim. In that case, the claim is deleted and
    *    the deposit sent to the shareholder (the owner of the private key). It is recommended to call resolveClaim
    *    whenever someone transfers funds to let claims be resolved automatically when the "lost" private key is
    *    used again.
    * 3) The owner deletes the claim and assigns the deposit to the claimant. This is intended to be used to resolve
    *    disputes. Generally, using this function implies that you have to trust the issuer of the tokens to handle
    *    the situation well. As a rule of thumb, the contract owner should assume the owner of the lost address to be the
    *    rightful owner of the deposit.
    * It is highly recommended that the owner observes the claims made and informs the owners of the claimed addresses
    * whenever a claim is made for their address (this of course is only possible if they are known to the owner, e.g.
    * through a shareholder register).
    * To prevent frontrunning attacks, a claim can only be made if the information revealed when calling "declareLost"
    * was previously commited using the "prepareClaim" function.
    */
    function prepareClaim(bytes32 hashedpackage) public {
        preClaims[msg.sender] = PreClaim({
            msghash: hashedpackage,
            timestamp: block.timestamp
        });
        emit ClaimPrepared(msg.sender);
    }

    function validateClaim(address lostAddress, bytes32 nonce) private view {
        PreClaim memory preClaim = preClaims[msg.sender];
        require(preClaim.msghash != 0, "Message hash can't be zero");
        require(preClaim.timestamp.add(preClaimPeriod) <= block.timestamp, "Preclaim period violated. Claimed too early");
        require(preClaim.timestamp.add(preClaimPeriodEnd) >= block.timestamp, "Preclaim period end. Claimed too late");
        require(preClaim.msghash == keccak256(abi.encodePacked(nonce, msg.sender, lostAddress)),"Package could not be validated");
    }

    function declareLost(address collateralType, address lostAddress, bytes32 nonce) public {
        require(lostAddress != address(0), "Can't claim zero address");
        require(isClaimsEnabled(lostAddress), "Claims disabled for this address");
        uint256 collateralRate = getCollateralRate(collateralType);
        require(collateralRate > 0, "Unsupported collateral type");
        address claimant = msg.sender;
        uint256 balance = balanceOf(lostAddress);
        uint256 collateral = balance.mul(collateralRate);
        IERC20 currency = IERC20(collateralType);
        require(balance > 0, "Claimed address holds no shares");
        require(currency.allowance(claimant, address(this)) >= collateral, "Currency allowance insufficient");
        require(currency.balanceOf(claimant) >= collateral, "Currency balance insufficient");
        require(claims[lostAddress].collateral == 0, "Address already claimed");
        validateClaim(lostAddress, nonce);
        require(currency.transferFrom(claimant, address(this), collateral), "Collateral transfer failed");

        claims[lostAddress] = Claim({
            claimant: claimant,
            collateral: collateral,
            timestamp: uint32(block.timestamp), // block timestamp is in seconds --> Should not overflow
            currencyUsed: collateralType
        });

        delete preClaims[claimant];
        emit ClaimMade(lostAddress, claimant, balance);
    }

    function getClaimant(address lostAddress) public view returns (address) {
        return claims[lostAddress].claimant;
    }

    function getCollateral(address lostAddress) public view returns (uint256) {
        return claims[lostAddress].collateral;
    }

    function getCollateralType(address lostAddress) public view returns (address) {
        return claims[lostAddress].currencyUsed;
    }

    function getTimeStamp(address lostAddress) public view returns (uint256) {
        return claims[lostAddress].timestamp;
    }

    function getPreClaimTimeStamp(address claimerAddress) public view returns (uint256) {
        return preClaims[claimerAddress].timestamp;
    }

    function getMsgHash(address claimerAddress) public view returns (bytes32) {
        return preClaims[claimerAddress].msghash;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(super.transfer(recipient, amount), "Transfer failed");
        clearClaim();
        return true;
    }

    /**
     * Clears a claim after the key has been found again and assigns the collateral to the "lost" address.
     * This is the price an adverse claimer pays for filing a false claim and makes it risky to do so.
     */
    function clearClaim() public {
        if (claims[msg.sender].collateral != 0) {
            uint256 collateral = claims[msg.sender].collateral;
            IERC20 currency = IERC20(claims[msg.sender].currencyUsed);
            delete claims[msg.sender];
            require(currency.transfer(msg.sender, collateral), "Collateral transfer failed");
            emit ClaimCleared(msg.sender, collateral);
        }
    }

   /**
    * After the claim period has passed, the claimant can call this function to send the
    * tokens on the lost address as well as the collateral to himself.
    */
    function resolveClaim(address lostAddress) public {
        Claim memory claim = claims[lostAddress];
        uint256 collateral = claim.collateral;
        IERC20 currency = IERC20(claim.currencyUsed);
        require(collateral != 0, "No claim found");
        require(claim.claimant == msg.sender, "Only claimant can resolve claim");
        require(claim.timestamp.add(uint32(claimPeriod)) <= block.timestamp, "Claim period not over yet");
        address claimant = claim.claimant;
        delete claims[lostAddress];
        require(currency.transfer(claimant, collateral), "Collateral transfer failed");
        _transfer(lostAddress, claimant, balanceOf(lostAddress));
        emit ClaimResolved(lostAddress, claimant, collateral);
    }

    /**
     * This function is to be executed by the owner only in case a dispute needs to be resolved manually.
     */
    function deleteClaim(address lostAddress) public {
        require(msg.sender == getClaimDeleter(), "You cannot delete claims");
        Claim memory claim = claims[lostAddress];
        IERC20 currency = IERC20(claim.currencyUsed);
        require(claim.collateral != 0, "No claim found");
        delete claims[lostAddress];
        require(currency.transfer(claim.claimant, claim.collateral), "Collateral transfer failed");
        emit ClaimDeleted(lostAddress, claim.claimant, claim.collateral);
    }

}

// File: contracts/Acquisition.sol

/**
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2019 Equility AG (alethena.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;



/**
 * @title Acquisition Attempt
 * @author Benjamin Rickenbacher, benjamin@alethena.com
 * @author Luzius Meisser, luzius@meissereconomics.com
 *
 */

contract Acquisition {

    using SafeMath for uint256;

    uint256 public constant VOTING_PERIOD = 60 days;    // 2months/60days
    uint256 public constant VALIDITY_PERIOD = 90 days;  // 3months/90days

    uint256 public quorum;                              // Percentage of votes needed to start drag-along process

    address private parent;                             // the parent contract
    address payable public buyer;                       // the person who made the offer
    uint256 public price;                               // the price offered per share (in XCHF base units, so 10**18 is 1 XCHF)
    uint256 public timestamp;                           // the timestamp of the block in which the acquisition was created

    uint256 public noVotes;                             // number of tokens voting for no
    uint256 public yesVotes;                            // number of tokens voting for yes

    enum Vote { NONE, YES, NO }                         // Used internally, represents not voted yet or yes/no vote.
    mapping (address => Vote) private votes;            // Who votes what

    event VotesChanged(uint256 newYesVotes, uint256 newNoVotes);

    constructor (address payable buyer_, uint256 price_, uint256 quorum_) public {
        require(price_ > 0, "Price cannot be zero");
        parent = msg.sender;
        buyer = buyer_;
        price = price_;
        quorum = quorum_;
        timestamp = block.timestamp;
    }

    function isWellFunded(address currency_, uint256 sharesToAcquire) public view returns (bool) {
        IERC20 currency = IERC20(currency_);
        uint256 buyerXCHFBalance = currency.balanceOf(buyer);
        uint256 buyerXCHFAllowance = currency.allowance(buyer, parent);
        uint256 xchfNeeded = sharesToAcquire.mul(price);
        return xchfNeeded <= buyerXCHFBalance && xchfNeeded <= buyerXCHFAllowance;
    }

    function isQuorumReached() public view returns (bool) {
        if (isVotingOpen()) {
            // is it already clear that 75% will vote yes even though the vote is not over yet?
            return yesVotes.mul(10000).div(IERC20(parent).totalSupply()) >= quorum;
        } else {
            // did 75% of all cast votes say 'yes'?
            return yesVotes.mul(10000).div(yesVotes.add(noVotes)) >= quorum;
        }
    }

    function quorumHasFailed() public view returns (bool) {
        if (isVotingOpen()) {
            // is it already clear that 25% will vote no even though the vote is not over yet?
            return (IERC20(parent).totalSupply().sub(noVotes)).mul(10000).div(IERC20(parent).totalSupply()) < quorum;
        } else {
            // did 25% of all cast votes say 'no'?
            return yesVotes.mul(10000).div(yesVotes.add(noVotes)) < quorum;
        }
    }

    function adjustVotes(address from, address to, uint256 value) public parentOnly() {
        if (isVotingOpen()) {
            Vote fromVoting = votes[from];
            Vote toVoting = votes[to];
            update(fromVoting, toVoting, value);
        }
    }

    function update(Vote previousVote, Vote newVote, uint256 votes_) internal {
        if (previousVote != newVote) {
            if (previousVote == Vote.NO) {
                noVotes = noVotes.sub(votes_);
            } else if (previousVote == Vote.YES) {
                yesVotes = yesVotes.sub(votes_);
            }
            if (newVote == Vote.NO) {
                noVotes = noVotes.add(votes_);
            } else if (newVote == Vote.YES) {
                yesVotes = yesVotes.add(votes_);
            }
            emit VotesChanged(yesVotes, noVotes);
        }
    }

    function isVotingOpen() public view returns (bool) {
        uint256 age = block.timestamp.sub(timestamp);
        return age <= VOTING_PERIOD;
    }

    function hasExpired() public view returns (bool) {
        uint256 age = block.timestamp.sub(timestamp);
        return age > VALIDITY_PERIOD;
    }

    modifier votingOpen() {
        require(isVotingOpen(), "The vote has ended.");
        _;
    }

    function voteYes(address sender, uint256 votes_) public parentOnly() votingOpen() {
        vote(Vote.YES, votes_, sender);
    }

    function voteNo(address sender, uint256 votes_) public parentOnly() votingOpen() {
        vote(Vote.NO, votes_, sender);
    }

    function vote(Vote yesOrNo, uint256 votes_, address voter) internal {
        Vote previousVote = votes[voter];
        Vote newVote = yesOrNo;
        votes[voter] = newVote;
        update(previousVote, newVote, votes_);
    }

    function hasVotedYes(address voter) public view returns (bool) {
        return votes[voter] == Vote.YES;
    }

    function hasVotedNo(address voter) public view returns (bool) {
        return votes[voter] == Vote.NO;
    }

    function kill() public parentOnly() {
        // destroy the contract and send leftovers to the buyer.
        selfdestruct(buyer);
    }

    modifier parentOnly () {
        require(msg.sender == parent, "Can only be called by parent contract");
        _;
    }
}

// File: contracts/IMigratable.sol

/**
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2019 Equility AG (alethena.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;

contract IMigratable {
    function migrationToContract() public returns (address);
}

// File: contracts/ERC20Draggable.sol

/**
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2019 Equility AG (alethena.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;






/**
 * @title Alethena SHA
 * @author Benjamin Rickenbacher, benjamin@alethena.com
 * @author Luzius Meisser, luzius@meissereconomics.com
 * @dev These tokens are based on the ERC20 standard and the open-zeppelin library.
 *
 * This is an ERC-20 token representing shares of ServiceHunter AG that are bound to
 * a shareholder agreement that can be found at the URL defined in the constant 'terms'
 * of the 'DraggableServiceHunterShares' contract. The agreement is partially enforced
 * through the Swiss legal system, and partially enforced through this smart contract.
 * In particular, this smart contract implements a drag-along clause which allows the
 * majority of token holders to force the minority sell their shares along with them in
 * case of an acquisition. That's why the tokens are called "Draggable ServiceHunter AG Shares."
 */

contract ERC20Draggable is ERC20 {

    using SafeMath for uint256;

    IERC20 private wrapped;                        // The wrapped contract

    // If the wrapped tokens got replaced in an acquisition, unwrapping might yield many currency tokens
    uint256 public unwrapConversionFactor = 1;

    // The current acquisition attempt, if any. See initiateAcquisition to see the requirements to make a public offer.
    Acquisition public offer;

    IERC20 private currency;

    address public offerFeeRecipient;              // Recipient of the fee. Fee makes sure the offer is serious.

    uint256 public offerFee;             // Fee of 5000 XCHF
    uint256 public migrationQuorum;      // Number of tokens that need to be migrated to complete migration
    uint256 public acquisitionQuorum;

    uint256 constant MIN_OFFER_INCREMENT = 10500;  // New offer must be at least 105% of old offer
    uint256 constant MIN_HOLDING = 500;            // Need at least 5% of all drag along tokens to make an offer
    uint256 constant MIN_DRAG_ALONG_QUOTA = 3000;  // 30% of the equity needs to be represented by drag along tokens for an offer to be made

    bool public active = true;                     // True as long as this contract is legally binding and the wrapped tokens are locked.

    event OfferCreated(address indexed buyer, uint256 pricePerShare);
    event OfferEnded(address indexed buyer, address sender, bool success, string message);
    event MigrationSucceeded(address newContractAddress);

    /**
     * CurrencyAddress specifies the currency used in acquisitions. The currency must be
     * an ERC-20 token that returns true on successful transfers and throws an exception or
     * returns false on failure. It can only be updated later if the currency supports the
     * IMigratable interface.
     */
    constructor(
        address wrappedToken,
        uint256 migrationQuorumInBIPS_,
        uint256 acquisitionQuorum_,
        address currencyAddress,
        address offerFeeRecipient_,
        uint offerFee_
    ) public {
        wrapped = IERC20(wrappedToken);
        offerFeeRecipient = offerFeeRecipient_;
        offerFee = offerFee_;
        migrationQuorum = migrationQuorumInBIPS_;
        acquisitionQuorum = acquisitionQuorum_;
        currency = IERC20(currencyAddress);
        IShares(wrappedToken).totalShares();
    }

    function getWrappedContract() public view returns (address) {
        return address(wrapped);
    }

    function getCurrencyContract() public view returns (address) {
        return address(currency);
    }

    function updateCurrency(address newCurrency) public noOfferPending () {
        require(active, "Contract is not active");
        require(IMigratable(getCurrencyContract()).migrationToContract() == newCurrency, "Invalid currency update");
        currency = IERC20(newCurrency);
    }

    /** Increases the number of drag-along tokens. Requires minter to deposit an equal amount of share tokens */
    function wrap(address shareholder, uint256 amount) public noOfferPending() {
        require(active, "Contract not active any more.");
        require(wrapped.balanceOf(msg.sender) >= amount, "Share balance not sufficient");
        require(wrapped.allowance(msg.sender, address(this)) >= amount, "Share allowance not sufficient");
        require(wrapped.transferFrom(msg.sender, address(this), amount), "Share transfer failed");
        _mint(shareholder, amount);
    }

    /** Decrease the number of drag-along tokens. The user gets back their shares in return */
    function unwrap(uint256 amount) public {
        require(!active, "As long as the contract is active, you are bound to it");
        _burn(msg.sender, amount);
        require(wrapped.transfer(msg.sender, amount.mul(unwrapConversionFactor)), "Share transfer failed");
    }

    /**
     * Burns both the token itself as well as the wrapped token!
     * If you want to get out of the shareholder agreement, use unwrap after it has been
     * deactivated by a majority vote or acquisition.
     *
     * Burning only works if wrapped token supports burning. Also, the exact meaning of this
     * operation might depend on the circumstances. Burning and reussing the wrapped token
     * does not free the sender from the legal obligations of the shareholder agreement.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        IBurnable(getWrappedContract()).burn(amount.mul(unwrapConversionFactor));
    }

  /** @dev Function to start drag-along procedure
   *  This can be called by anyone, but there is an upfront payment.
   */
    function initiateAcquisition(uint256 pricePerShare) public {
        require(active, "An accepted offer exists");
        uint256 totalEquity = IShares(getWrappedContract()).totalShares();
        address buyer = msg.sender;

        require(totalSupply() >= totalEquity.mul(MIN_DRAG_ALONG_QUOTA).div(10000), "This contract does not represent enough equity");
        require(balanceOf(buyer) >= totalEquity.mul(MIN_HOLDING).div(10000), "You need to hold at least 5% of the firm to make an offer");

        require(currency.transferFrom(buyer, offerFeeRecipient, offerFee), "Currency transfer failed");

        Acquisition newOffer = new Acquisition(msg.sender, pricePerShare, acquisitionQuorum);
        require(newOffer.isWellFunded(getCurrencyContract(), totalSupply() - balanceOf(buyer)), "Insufficient funding");
        if (offerExists()) {
            require(pricePerShare >= offer.price().mul(MIN_OFFER_INCREMENT).div(10000), "New offers must be at least 5% higher than the pending offer");
            killAcquisition("Offer was replaced by a higher bid");
        }
        offer = newOffer;

        emit OfferCreated(buyer, pricePerShare);
    }

    function voteYes() public offerPending() {
        address voter = msg.sender;
        offer.voteYes(voter, balanceOf(voter));
    }

    function voteNo() public offerPending() {
        address voter = msg.sender;
        offer.voteNo(voter, balanceOf(voter));
    }

    function cancelAcquisition() public offerPending() {
        require(msg.sender == offer.buyer(), "You are not authorized to cancel this acquisition offer");
        killAcquisition("Cancelled by buyer");
    }

    function contestAcquisition() public offerPending() {
        if (offer.hasExpired()) {
            killAcquisition("Offer expired");
        } else if (offer.quorumHasFailed()) {
            killAcquisition("Not enough support");
        } else if (
            !offer.isWellFunded(
                getCurrencyContract(),
                totalSupply().sub(balanceOf(offer.buyer()))
                )
            ) {
            killAcquisition("Offer was not sufficiently funded");
        } else {
            revert("Acquisition contest unsuccessful");
        }
    }

    function killAcquisition(string memory message) internal {
        address buyer = offer.buyer();
        offer.kill();
        offer = Acquisition(address(0));
        emit OfferEnded(
            buyer,
            msg.sender,
            false,
            message
        );
    }

    function completeAcquisition() public offerPending() {
        address buyer = offer.buyer();
        require(msg.sender == buyer, "You are not authorized to complete this acquisition offer");
        require(offer.isQuorumReached(), "Insufficient number of yes votes");
        require(
            offer.isWellFunded(
            getCurrencyContract(),
            totalSupply().sub(balanceOf(buyer))),
            "Offer insufficiently funded"
            );
        invertHoldings(buyer, currency, offer.price());
        emit OfferEnded(
            buyer,
            msg.sender,
            true,
            "Completed successfully"
        );
    }

    function wasAcquired() public view returns (bool) {
        return offerExists() ? !active : false;
    }

    function invertHoldings(address newOwner, IERC20 newBacking, uint256 conversionRate) internal {
        uint256 buyerBalance = balanceOf(newOwner);
        uint256 initialSupply = totalSupply();
        active = false;
        unwrap(buyerBalance);
        uint256 remaining = initialSupply.sub(buyerBalance);
        require(wrapped.transfer(newOwner, remaining), "Wrapped token transfer failed");
        require(newBacking.transferFrom(newOwner, address(this), conversionRate.mul(remaining)), "Backing transfer failed");

        wrapped = newBacking;
        unwrapConversionFactor = conversionRate;
    }

    function migrate() public {
        require(active, "Contract is not active");
        address successor = msg.sender;
        require(balanceOf(successor) >= totalSupply().mul(migrationQuorum).div(10000), "Quorum not reached");

        if (offerExists()) {
            if (!offer.quorumHasFailed()) {
                voteNo(); // should shut down the offer
                require(offer.quorumHasFailed(), "Quorum has not failed");
            }
            contestAcquisition();
            assert (!offerExists());
        }

        invertHoldings(successor, IERC20(successor), 1);
        emit MigrationSucceeded(successor);
    }

    function _mint(address account, uint256 amount) internal {
        super._mint(account, amount);
        if (offerExists() && active) {
            // never executed in the default implementation as wrap requires no offer
            offer.adjustVotes(address(0), account, amount);
        }
    }

    function _transfer(address from, address to, uint256 value) internal {
        super._transfer(from, to, value);
        if (offerExists() && active) {
            offer.adjustVotes(from, to, value);
        }
    }

    function _burn(address account, uint256 amount) internal {
        require(balanceOf(msg.sender) >= amount, "Balance insufficient");
        super._burn(account, amount);
        if (offerExists() && active) {
            offer.adjustVotes(account, address(0), amount);
        }
    }

    function getPendingOffer() public view returns (address) {
        return address(offer);
    }

    function offerExists() public view returns (bool) {
        return getPendingOffer() != address(0);
    }

    modifier offerPending() {
        require(offerExists() && active, "There is no pending offer");
        _;
    }

    modifier noOfferPending() {
        require(!offerExists(), "There is a pending offer");
        _;
    }

}

contract IShares {
    function totalShares() public returns (uint256);
}

contract IBurnable {
    function burn(uint256) public;
}

// File: contracts/DraggableServiceHunterShares.sol

/**
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2019 Equility AG (alethena.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
pragma solidity 0.5.10;



/**
 * @title Draggable ServiceHunter AG Shares
 * @author Benjamin Rickenbacher, benjamin@alethena.com
 * @author Luzius Meisser, luzius@meissereconomics.com
 *
 * This is an ERC-20 token representing shares of ServiceHunter AG that are bound to
 * a shareholder agreement that can be found at the URL defined in the constant 'terms'.
 * The shareholder agreement is partially enforced through this smart contract. The agreement
 * is designed to facilitate a complete acquisition of the firm even if a minority of shareholders
 * disagree with the acquisition, to protect the interest of the minority shareholders by requiring
 * the acquirer to offer the same conditions to everyone when acquiring the company, and to
 * facilitate an update of the shareholder agreement even if a minority of the shareholders that
 * are bound to this agreement disagree. The name "draggable" stems from the convention of calling
 * the right to drag a minority along with a sale of the company "drag-along" rights. The name is
 * chosen to ensure that token holders are aware that they are bound to such an agreement.
 *
 * The percentage of token holders that must agree with an update of the terms is defined by the
 * constant UPDATE_QUORUM. The precentage of yes-votes that is needed to successfully complete an
 * acquisition is defined in the constant ACQUISITION_QUORUM. Note that the update quorum is based
 * on the total number of tokens in circulation. In contrast, the acquisition quorum is based on the
 * number of votes cast during the voting period, not taking into account those who did not bother
 * to vote.
 */

contract DraggableServiceHunterShares is ERC20Claimable, ERC20Draggable {

    string public constant symbol = "DSHS";
    string public constant name = "Draggable ServiceHunter AG Shares";
    string public constant terms = "quitt.ch/investoren";

    uint8 public constant decimals = 0;                  // shares are not divisible

    uint256 public constant UPDATE_QUORUM = 7500;        // 7500 basis points = 75%
    uint256 public constant ACQUISITION_QUORUM = 7500;   // 7500 basis points = 75%
    uint256 public constant OFFER_FEE = 5000 * 10 ** 18; // 5000 XCHF

    /**
     * Designed to be used with the Crypto Franc as currency token. See also parent constructor.
     */
    constructor(address wrappedToken, address xchfAddress, address offerFeeRecipient)
        ERC20Draggable(wrappedToken, UPDATE_QUORUM, ACQUISITION_QUORUM, xchfAddress, offerFeeRecipient, OFFER_FEE) public {
        IClaimable(wrappedToken).setClaimable(false);
    }

    function getClaimDeleter() public returns (address) {
        return IClaimable(getWrappedContract()).getClaimDeleter();
    }

    function getCollateralRate(address collateralType) public view returns (uint256) {
        uint256 rate = super.getCollateralRate(collateralType);
        if (rate > 0) {
            return rate;
        } else if (collateralType == getWrappedContract()) {
            return unwrapConversionFactor;
        } else {
            // If the wrapped contract allows for a specific collateral, we should too.
            // If the wrapped contract is not IClaimable, we will fail here, but would fail anyway.
            return IClaimable(getWrappedContract()).getCollateralRate(collateralType).mul(unwrapConversionFactor);
        }
    }

}

contract IClaimable {
    function setClaimable(bool) public;
    function getCollateralRate(address) public view returns (uint256);
    function getClaimDeleter() public returns (address);
}