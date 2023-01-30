/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

// File: contracts/components/Owned.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.24;

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    constructor() public {
        owner = msg.sender;
    }

    address public newOwner;

    function transferOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }
}

// File: contracts/components/Halt.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.24;


contract Halt is Owned {

    bool public halted = false;

    modifier notHalted() {
        require(!halted, "Smart contract is halted");
        _;
    }

    modifier isHalted() {
        require(halted, "Smart contract is not halted");
        _;
    }

    /// @notice function Emergency situation that requires
    /// @notice contribution period to stop or not.
    function setHalt(bool halt)
        public
        onlyOwner
    {
        halted = halt;
    }
}

// File: contracts/components/ReentrancyGuard.sol

pragma solidity 0.4.26;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

// File: contracts/lib/BasicStorageLib.sol

pragma solidity ^0.4.24;

library BasicStorageLib {

    struct UintData {
        mapping(bytes => mapping(bytes => uint))           _storage;
    }

    struct BoolData {
        mapping(bytes => mapping(bytes => bool))           _storage;
    }

    struct AddressData {
        mapping(bytes => mapping(bytes => address))        _storage;
    }

    struct BytesData {
        mapping(bytes => mapping(bytes => bytes))          _storage;
    }

    struct StringData {
        mapping(bytes => mapping(bytes => string))         _storage;
    }

    /* uintStorage */

    function setStorage(UintData storage self, bytes memory key, bytes memory innerKey, uint value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(UintData storage self, bytes memory key, bytes memory innerKey) internal view returns (uint) {
        return self._storage[key][innerKey];
    }

    function delStorage(UintData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

    /* boolStorage */

    function setStorage(BoolData storage self, bytes memory key, bytes memory innerKey, bool value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(BoolData storage self, bytes memory key, bytes memory innerKey) internal view returns (bool) {
        return self._storage[key][innerKey];
    }

    function delStorage(BoolData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

    /* addressStorage */

    function setStorage(AddressData storage self, bytes memory key, bytes memory innerKey, address value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(AddressData storage self, bytes memory key, bytes memory innerKey) internal view returns (address) {
        return self._storage[key][innerKey];
    }

    function delStorage(AddressData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

    /* bytesStorage */

    function setStorage(BytesData storage self, bytes memory key, bytes memory innerKey, bytes memory value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(BytesData storage self, bytes memory key, bytes memory innerKey) internal view returns (bytes memory) {
        return self._storage[key][innerKey];
    }

    function delStorage(BytesData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

    /* stringStorage */

    function setStorage(StringData storage self, bytes memory key, bytes memory innerKey, string memory value) internal {
        self._storage[key][innerKey] = value;
    }

    function getStorage(StringData storage self, bytes memory key, bytes memory innerKey) internal view returns (string memory) {
        return self._storage[key][innerKey];
    }

    function delStorage(StringData storage self, bytes memory key, bytes memory innerKey) internal {
        delete self._storage[key][innerKey];
    }

}

// File: contracts/components/BasicStorage.sol

pragma solidity ^0.4.24;


contract BasicStorage {
    /************************************************************
     **
     ** VARIABLES
     **
     ************************************************************/

    //// basic variables
    using BasicStorageLib for BasicStorageLib.UintData;
    using BasicStorageLib for BasicStorageLib.BoolData;
    using BasicStorageLib for BasicStorageLib.AddressData;
    using BasicStorageLib for BasicStorageLib.BytesData;
    using BasicStorageLib for BasicStorageLib.StringData;

    BasicStorageLib.UintData    internal uintData;
    BasicStorageLib.BoolData    internal boolData;
    BasicStorageLib.AddressData internal addressData;
    BasicStorageLib.BytesData   internal bytesData;
    BasicStorageLib.StringData  internal stringData;
}

// File: contracts/interfaces/IRC20Protocol.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;

interface IRC20Protocol {
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function balanceOf(address _owner) external view returns (uint);
}

// File: contracts/interfaces/IQuota.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity 0.4.26;

interface IQuota {
  function userMintLock(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function userMintRevoke(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function userMintRedeem(uint tokenId, bytes32 storemanGroupId, uint value) external;

  function smgMintLock(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function smgMintRevoke(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function smgMintRedeem(uint tokenId, bytes32 storemanGroupId, uint value) external;

  function userBurnLock(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function userBurnRevoke(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function userBurnRedeem(uint tokenId, bytes32 storemanGroupId, uint value) external;

  function smgBurnLock(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function smgBurnRevoke(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function smgBurnRedeem(uint tokenId, bytes32 storemanGroupId, uint value) external;

  function userFastMint(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function userFastBurn(uint tokenId, bytes32 storemanGroupId, uint value) external;

  function smgFastMint(uint tokenId, bytes32 storemanGroupId, uint value) external;
  function smgFastBurn(uint tokenId, bytes32 storemanGroupId, uint value) external;

  function assetLock(bytes32 srcStoremanGroupId, bytes32 dstStoremanGroupId) external;
  function assetRedeem(bytes32 srcStoremanGroupId, bytes32 dstStoremanGroupId) external;
  function assetRevoke(bytes32 srcStoremanGroupId, bytes32 dstStoremanGroupId) external;

  function debtLock(bytes32 srcStoremanGroupId, bytes32 dstStoremanGroupId) external;
  function debtRedeem(bytes32 srcStoremanGroupId, bytes32 dstStoremanGroupId) external;
  function debtRevoke(bytes32 srcStoremanGroupId, bytes32 dstStoremanGroupId) external;

  function getUserMintQuota(uint tokenId, bytes32 storemanGroupId) external view returns (uint);
  function getSmgMintQuota(uint tokenId, bytes32 storemanGroupId) external view returns (uint);

  function getUserBurnQuota(uint tokenId, bytes32 storemanGroupId) external view returns (uint);
  function getSmgBurnQuota(uint tokenId, bytes32 storemanGroupId) external view returns (uint);

  function getAsset(uint tokenId, bytes32 storemanGroupId) external view returns (uint asset, uint asset_receivable, uint asset_payable);
  function getDebt(uint tokenId, bytes32 storemanGroupId) external view returns (uint debt, uint debt_receivable, uint debt_payable);

  function isDebtClean(bytes32 storemanGroupId) external view returns (bool);
}

// File: contracts/interfaces/IStoremanGroup.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.24;

interface IStoremanGroup {
    function getSelectedSmNumber(bytes32 groupId) external view returns(uint number);
    function getStoremanGroupConfig(bytes32 id) external view returns(bytes32 groupId, uint8 status, uint deposit, uint chain1, uint chain2, uint curve1, uint curve2,  bytes gpk1, bytes gpk2, uint startTime, uint endTime);
    function getDeposit(bytes32 id) external view returns(uint);
    function getStoremanGroupStatus(bytes32 id) external view returns(uint8 status, uint startTime, uint endTime);
    function setGpk(bytes32 groupId, bytes gpk1, bytes gpk2) external;
    function setInvalidSm(bytes32 groupId, uint[] indexs, uint8[] slashTypes) external returns(bool isContinue);
    function getThresholdByGrpId(bytes32 groupId) external view returns (uint);
    function getSelectedSmInfo(bytes32 groupId, uint index) external view returns(address wkAddr, bytes PK, bytes enodeId);
    function recordSmSlash(address wk) public;
}

// File: contracts/interfaces/ITokenManager.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity 0.4.26;

interface ITokenManager {
    function getTokenPairInfo(uint id) external view
      returns (uint origChainID, bytes tokenOrigAccount, uint shadowChainID, bytes tokenShadowAccount);

    function getTokenPairInfoSlim(uint id) external view 
      returns (uint origChainID, bytes tokenOrigAccount, uint shadowChainID);

    function mintToken(uint id, address to,uint value) external;

    function burnToken(uint id, uint value) external;
}

// File: contracts/interfaces/ISignatureVerifier.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity 0.4.26;

interface ISignatureVerifier {
  function verify(
        uint curveId,
        bytes32 signature,
        bytes32 groupKeyX,
        bytes32 groupKeyY,
        bytes32 randomPointX,
        bytes32 randomPointY,
        bytes32 message
    ) external returns (bool);
}

// File: contracts/lib/SafeMath.sol

pragma solidity ^0.4.24;

/**
 * Math operations with safety checks
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath mul overflow");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath div 0"); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath sub b > a");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath add overflow");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath mod 0");
        return a % b;
    }
}

// File: contracts/crossApproach/lib/HTLCTxLib.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;
pragma experimental ABIEncoderV2;


library HTLCTxLib {
    using SafeMath for uint;

    /**
     *
     * ENUMS
     *
     */

    /// @notice tx info status
    /// @notice uninitialized,locked,redeemed,revoked
    enum TxStatus {None, Locked, Redeemed, Revoked, AssetLocked, DebtLocked}

    /**
     *
     * STRUCTURES
     *
     */

    /// @notice struct of HTLC user mint lock parameters
    struct HTLCUserParams {
        bytes32 xHash;                  /// hash of HTLC random number
        bytes32 smgID;                  /// ID of storeman group which user has selected
        uint tokenPairID;               /// token pair id on cross chain
        uint value;                     /// exchange token value
        uint lockFee;                   /// exchange token value
        uint lockedTime;                /// HTLC lock time
    }

    /// @notice HTLC(Hashed TimeLock Contract) tx info
    struct BaseTx {
        bytes32 smgID;                  /// HTLC transaction storeman ID
        uint lockedTime;                /// HTLC transaction locked time
        uint beginLockedTime;           /// HTLC transaction begin locked time
        TxStatus status;                /// HTLC transaction status
    }

    /// @notice user  tx info
    struct UserTx {
        BaseTx baseTx;
        uint tokenPairID;
        uint value;
        uint fee;
        address userAccount;            /// HTLC transaction sender address for the security check while user's revoke
    }
    /// @notice storeman  tx info
    struct SmgTx {
        BaseTx baseTx;
        uint tokenPairID;
        uint value;
        address  userAccount;          /// HTLC transaction user address for the security check while user's redeem
    }
    /// @notice storeman  debt tx info
    struct DebtTx {
        BaseTx baseTx;
        bytes32 srcSmgID;              /// HTLC transaction sender(source storeman) ID
    }

    struct Data {
        /// @notice mapping of hash(x) to UserTx -- xHash->htlcUserTxData
        mapping(bytes32 => UserTx) mapHashXUserTxs;

        /// @notice mapping of hash(x) to SmgTx -- xHash->htlcSmgTxData
        mapping(bytes32 => SmgTx) mapHashXSmgTxs;

        /// @notice mapping of hash(x) to DebtTx -- xHash->htlcDebtTxData
        mapping(bytes32 => DebtTx) mapHashXDebtTxs;

    }

    /**
     *
     * MANIPULATIONS
     *
     */

    /// @notice                     add user transaction info
    /// @param params               parameters for user tx
    function addUserTx(Data storage self, HTLCUserParams memory params)
        public
    {
        UserTx memory userTx = self.mapHashXUserTxs[params.xHash];
        // UserTx storage userTx = self.mapHashXUserTxs[params.xHash];
        // require(params.value != 0, "Value is invalid");
        require(userTx.baseTx.status == TxStatus.None, "User tx exists");

        userTx.baseTx.smgID = params.smgID;
        userTx.baseTx.lockedTime = params.lockedTime;
        userTx.baseTx.beginLockedTime = now;
        userTx.baseTx.status = TxStatus.Locked;
        userTx.tokenPairID = params.tokenPairID;
        userTx.value = params.value;
        userTx.fee = params.lockFee;
        userTx.userAccount = msg.sender;

        self.mapHashXUserTxs[params.xHash] = userTx;
    }

    /// @notice                     refund coins from HTLC transaction, which is used for storeman redeem(outbound)
    /// @param x                    HTLC random number
    function redeemUserTx(Data storage self, bytes32 x)
        external
        returns(bytes32 xHash)
    {
        xHash = sha256(abi.encodePacked(x));

        UserTx storage userTx = self.mapHashXUserTxs[xHash];
        require(userTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(now < userTx.baseTx.beginLockedTime.add(userTx.baseTx.lockedTime), "Redeem timeout");

        userTx.baseTx.status = TxStatus.Redeemed;

        return xHash;
    }

    /// @notice                     revoke user transaction
    /// @param  xHash               hash of HTLC random number
    function revokeUserTx(Data storage self, bytes32 xHash)
        external
    {
        UserTx storage userTx = self.mapHashXUserTxs[xHash];
        require(userTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(now >= userTx.baseTx.beginLockedTime.add(userTx.baseTx.lockedTime), "Revoke is not permitted");

        userTx.baseTx.status = TxStatus.Revoked;
    }

    /// @notice                    function for get user info
    /// @param xHash               hash of HTLC random number
    /// @return smgID              ID of storeman which user has selected
    /// @return tokenPairID        token pair ID of cross chain
    /// @return value              exchange value
    /// @return fee                exchange fee
    /// @return userAccount        HTLC transaction sender address for the security check while user's revoke
    function getUserTx(Data storage self, bytes32 xHash)
        external
        view
        returns (bytes32, uint, uint, uint, address)
    {
        UserTx storage userTx = self.mapHashXUserTxs[xHash];
        return (userTx.baseTx.smgID, userTx.tokenPairID, userTx.value, userTx.fee, userTx.userAccount);
    }

    /// @notice                     add storeman transaction info
    /// @param  xHash               hash of HTLC random number
    /// @param  smgID               ID of the storeman which user has selected
    /// @param  tokenPairID         token pair ID of cross chain
    /// @param  value               HTLC transfer value of token
    /// @param  userAccount            user account address on the destination chain, which is used to redeem token
    function addSmgTx(Data storage self, bytes32 xHash, bytes32 smgID, uint tokenPairID, uint value, address userAccount, uint lockedTime)
        external
    {
        SmgTx memory smgTx = self.mapHashXSmgTxs[xHash];
        // SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        require(value != 0, "Value is invalid");
        require(smgTx.baseTx.status == TxStatus.None, "Smg tx exists");

        smgTx.baseTx.smgID = smgID;
        smgTx.baseTx.status = TxStatus.Locked;
        smgTx.baseTx.lockedTime = lockedTime;
        smgTx.baseTx.beginLockedTime = now;
        smgTx.tokenPairID = tokenPairID;
        smgTx.value = value;
        smgTx.userAccount = userAccount;

        self.mapHashXSmgTxs[xHash] = smgTx;
    }

    /// @notice                     refund coins from HTLC transaction, which is used for users redeem(inbound)
    /// @param x                    HTLC random number
    function redeemSmgTx(Data storage self, bytes32 x)
        external
        returns(bytes32 xHash)
    {
        xHash = sha256(abi.encodePacked(x));

        SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        require(smgTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(now < smgTx.baseTx.beginLockedTime.add(smgTx.baseTx.lockedTime), "Redeem timeout");

        smgTx.baseTx.status = TxStatus.Redeemed;

        return xHash;
    }

    /// @notice                     revoke storeman transaction
    /// @param  xHash               hash of HTLC random number
    function revokeSmgTx(Data storage self, bytes32 xHash)
        external
    {
        SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        require(smgTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(now >= smgTx.baseTx.beginLockedTime.add(smgTx.baseTx.lockedTime), "Revoke is not permitted");

        smgTx.baseTx.status = TxStatus.Revoked;
    }

    /// @notice                     function for get smg info
    /// @param xHash                hash of HTLC random number
    /// @return smgID               ID of storeman which user has selected
    /// @return tokenPairID         token pair ID of cross chain
    /// @return value               exchange value
    /// @return userAccount            user account address for redeem
    function getSmgTx(Data storage self, bytes32 xHash)
        external
        view
        returns (bytes32, uint, uint, address)
    {
        SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        return (smgTx.baseTx.smgID, smgTx.tokenPairID, smgTx.value, smgTx.userAccount);
    }

    /// @notice                     add storeman transaction info
    /// @param  xHash               hash of HTLC random number
    /// @param  srcSmgID            ID of source storeman group
    /// @param  destSmgID           ID of the storeman which will take over of the debt of source storeman group
    /// @param  lockedTime          HTLC lock time
    /// @param  status              Status, should be 'Locked' for asset or 'DebtLocked' for debt
    function addDebtTx(Data storage self, bytes32 xHash, bytes32 srcSmgID, bytes32 destSmgID, uint lockedTime, TxStatus status)
        external
    {
        DebtTx memory debtTx = self.mapHashXDebtTxs[xHash];
        // DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        require(debtTx.baseTx.status == TxStatus.None, "Debt tx exists");

        debtTx.baseTx.smgID = destSmgID;
        debtTx.baseTx.status = status;//TxStatus.Locked;
        debtTx.baseTx.lockedTime = lockedTime;
        debtTx.baseTx.beginLockedTime = now;
        debtTx.srcSmgID = srcSmgID;

        self.mapHashXDebtTxs[xHash] = debtTx;
    }

    /// @notice                     refund coins from HTLC transaction
    /// @param x                    HTLC random number
    /// @param status               Status, should be 'Locked' for asset or 'DebtLocked' for debt
    function redeemDebtTx(Data storage self, bytes32 x, TxStatus status)
        external
        returns(bytes32 xHash)
    {
        xHash = sha256(abi.encodePacked(x));

        DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        // require(debtTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(debtTx.baseTx.status == status, "Status is not locked");
        require(now < debtTx.baseTx.beginLockedTime.add(debtTx.baseTx.lockedTime), "Redeem timeout");

        debtTx.baseTx.status = TxStatus.Redeemed;

        return xHash;
    }

    /// @notice                     revoke debt transaction, which is used for source storeman group
    /// @param  xHash               hash of HTLC random number
    /// @param  status              Status, should be 'Locked' for asset or 'DebtLocked' for debt
    function revokeDebtTx(Data storage self, bytes32 xHash, TxStatus status)
        external
    {
        DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        // require(debtTx.baseTx.status == TxStatus.Locked, "Status is not locked");
        require(debtTx.baseTx.status == status, "Status is not locked");
        require(now >= debtTx.baseTx.beginLockedTime.add(debtTx.baseTx.lockedTime), "Revoke is not permitted");

        debtTx.baseTx.status = TxStatus.Revoked;
    }

    /// @notice                     function for get debt info
    /// @param xHash                hash of HTLC random number
    /// @return srcSmgID            ID of source storeman
    /// @return destSmgID           ID of destination storeman
    function getDebtTx(Data storage self, bytes32 xHash)
        external
        view
        returns (bytes32, bytes32)
    {
        DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        return (debtTx.srcSmgID, debtTx.baseTx.smgID);
    }

    function getLeftTime(uint endTime) private view returns (uint) {
        if (now < endTime) {
            return endTime.sub(now);
        }
        return 0;
    }

    /// @notice                     function for get debt info
    /// @param xHash                hash of HTLC random number
    /// @return leftTime            the left lock time
    function getLeftLockedTime(Data storage self, bytes32 xHash)
        external
        view
        returns (uint)
    {
        UserTx storage userTx = self.mapHashXUserTxs[xHash];
        if (userTx.baseTx.status != TxStatus.None) {
            return getLeftTime(userTx.baseTx.beginLockedTime.add(userTx.baseTx.lockedTime));
        }
        SmgTx storage smgTx = self.mapHashXSmgTxs[xHash];
        if (smgTx.baseTx.status != TxStatus.None) {
            return getLeftTime(smgTx.baseTx.beginLockedTime.add(smgTx.baseTx.lockedTime));
        }
        DebtTx storage debtTx = self.mapHashXDebtTxs[xHash];
        if (debtTx.baseTx.status != TxStatus.None) {
            return getLeftTime(debtTx.baseTx.beginLockedTime.add(debtTx.baseTx.lockedTime));
        }
        require(false, 'invalid xHash');
    }
}

// File: contracts/crossApproach/lib/RapidityTxLib.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;

library RapidityTxLib {

    /**
     *
     * ENUMS
     *
     */

    /// @notice tx info status
    /// @notice uninitialized,Redeemed
    enum TxStatus {None, Redeemed}

    /**
     *
     * STRUCTURES
     *
     */
    struct Data {
        /// @notice mapping of uniqueID to TxStatus -- uniqueID->TxStatus
        mapping(bytes32 => TxStatus) mapTxStatus;

    }

    /**
     *
     * MANIPULATIONS
     *
     */

    /// @notice                     add user transaction info
    /// @param  uniqueID            Rapidity random number
    function addRapidityTx(Data storage self, bytes32 uniqueID)
        internal
    {
        TxStatus status = self.mapTxStatus[uniqueID];
        require(status == TxStatus.None, "Rapidity tx exists");
        self.mapTxStatus[uniqueID] = TxStatus.Redeemed;
    }
}

// File: contracts/crossApproach/lib/CrossTypes.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;








library CrossTypes {
    using SafeMath for uint;

    /**
     *
     * STRUCTURES
     *
     */

    struct Data {

        /// map of the htlc transaction info
        HTLCTxLib.Data htlcTxData;

        /// map of the rapidity transaction info
        RapidityTxLib.Data rapidityTxData;

        /// quota data of storeman group
        IQuota quota;

        /// token manager instance interface
        ITokenManager tokenManager;

        /// storemanGroup admin instance interface
        IStoremanGroup smgAdminProxy;

        /// storemanGroup fee admin instance address
        address smgFeeProxy;

        ISignatureVerifier sigVerifier;

        /// @notice transaction fee, smgID => fee
        mapping(bytes32 => uint) mapStoremanFee;

        /// @notice transaction fee, origChainID => shadowChainID => fee
        mapping(uint => mapping(uint =>uint)) mapLockFee;

        /// @notice transaction fee, origChainID => shadowChainID => fee
        mapping(uint => mapping(uint =>uint)) mapRevokeFee;

    }

    /**
     *
     * MANIPULATIONS
     *
     */

    // /// @notice       convert bytes32 to address
    // /// @param b      bytes32
    // function bytes32ToAddress(bytes32 b) internal pure returns (address) {
    //     return address(uint160(bytes20(b))); // high
    //     // return address(uint160(uint256(b))); // low
    // }

    /// @notice       convert bytes to address
    /// @param b      bytes
    function bytesToAddress(bytes b) internal pure returns (address addr) {
        assembly {
            addr := mload(add(b,20))
        }
    }

    function transfer(address tokenScAddr, address to, uint value)
        internal
        returns(bool)
    {
        uint beforeBalance;
        uint afterBalance;
        beforeBalance = IRC20Protocol(tokenScAddr).balanceOf(to);
        // IRC20Protocol(tokenScAddr).transfer(to, value);
        tokenScAddr.call(bytes4(keccak256("transfer(address,uint256)")), to, value);
        afterBalance = IRC20Protocol(tokenScAddr).balanceOf(to);
        return afterBalance == beforeBalance.add(value);
    }

    function transferFrom(address tokenScAddr, address from, address to, uint value)
        internal
        returns(bool)
    {
        uint beforeBalance;
        uint afterBalance;
        beforeBalance = IRC20Protocol(tokenScAddr).balanceOf(to);
        // IRC20Protocol(tokenScAddr).transferFrom(from, to, value);
        tokenScAddr.call(bytes4(keccak256("transferFrom(address,address,uint256)")), from, to, value);
        afterBalance = IRC20Protocol(tokenScAddr).balanceOf(to);
        return afterBalance == beforeBalance.add(value);
    }
}

// File: contracts/crossApproach/CrossStorage.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;





contract CrossStorage is BasicStorage {
    using HTLCTxLib for HTLCTxLib.Data;
    using RapidityTxLib for RapidityTxLib.Data;

    /************************************************************
     **
     ** VARIABLES
     **
     ************************************************************/

    CrossTypes.Data internal storageData;

    /// @notice locked time(in seconds)
    uint public lockedTime = uint(3600*36);

    /// @notice Since storeman group admin receiver address may be changed, system should make sure the new address
    /// @notice can be used, and the old address can not be used. The solution is add timestamp.
    /// @notice unit: second
    uint public smgFeeReceiverTimeout = uint(10*60);

    enum GroupStatus { none, initial, curveSeted, failed, selected, ready, unregistered, dismissed }

}

// File: contracts/crossApproach/lib/HTLCDebtLib.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;



library HTLCDebtLib {
    using SafeMath for uint;
    using HTLCTxLib for HTLCTxLib.Data;

    /**
     *
     * STRUCTURES
     *
     */
    /// @notice struct of HTLC debt lock parameters
    struct HTLCDebtLockParams {
        bytes32 xHash;                  /// hash of HTLC random number
        bytes32 srcSmgID;               /// ID of source storeman group
        bytes32 destSmgID;              /// ID of destination storeman group
        uint lockedTime;                /// HTLC lock time
    }

    /**
     *
     * EVENTS
     *
     **/

    /// @notice                     event of storeman debt lock
    /// @param xHash                hash of HTLC random number
    /// @param srcSmgID             ID of source storeman group
    /// @param destSmgID            ID of destination storeman group
    event SrcDebtLockLogger(bytes32 indexed xHash, bytes32 indexed srcSmgID, bytes32 indexed destSmgID);

    /// @notice                     event of redeem storeman debt
    /// @param xHash                hash of HTLC random number
    /// @param srcSmgID             ID of source storeman group
    /// @param destSmgID            ID of destination storeman group
    /// @param x                    HTLC random number
    event DestDebtRedeemLogger(bytes32 indexed xHash, bytes32 indexed srcSmgID, bytes32 indexed destSmgID, bytes32 x);

    /// @notice                     event of revoke storeman debt
    /// @param xHash                hash of HTLC random number
    /// @param srcSmgID             ID of source storeman group
    /// @param destSmgID            ID of destination storeman group
    event SrcDebtRevokeLogger(bytes32 indexed xHash, bytes32 indexed srcSmgID, bytes32 indexed destSmgID);

    /// @notice                     event of storeman debt lock
    /// @param xHash                hash of HTLC random number
    /// @param srcSmgID             ID of source storeman group
    /// @param destSmgID            ID of destination storeman group
    event DestDebtLockLogger(bytes32 indexed xHash, bytes32 indexed srcSmgID, bytes32 indexed destSmgID);

    /// @notice                     event of redeem storeman debt
    /// @param xHash                hash of HTLC random number
    /// @param srcSmgID             ID of source storeman group
    /// @param destSmgID            ID of destination storeman group
    /// @param x                    HTLC random number
    event SrcDebtRedeemLogger(bytes32 indexed xHash, bytes32 indexed srcSmgID, bytes32 indexed destSmgID, bytes32 x);

    /// @notice                     event of revoke storeman debt
    /// @param xHash                hash of HTLC random number
    /// @param srcSmgID             ID of source storeman group
    /// @param destSmgID            ID of destination storeman group
    event DestDebtRevokeLogger(bytes32 indexed xHash, bytes32 indexed srcSmgID, bytes32 indexed destSmgID);

    /**
     *
     * MANIPULATIONS
     *
     */

    /// @notice                     lock storeman debt
    /// @param  storageData         Cross storage data
    /// @param  params              parameters of storeman debt lock
    function srcDebtLock(CrossTypes.Data storage storageData, HTLCDebtLockParams memory params)
        public
    {
        storageData.htlcTxData.addDebtTx(params.xHash, params.srcSmgID, params.destSmgID, params.lockedTime, HTLCTxLib.TxStatus.AssetLocked);

        storageData.quota.assetLock(params.srcSmgID, params.destSmgID);

        emit SrcDebtLockLogger(params.xHash, params.srcSmgID, params.destSmgID);
    }

    /// @notice                     lock storeman debt
    /// @param  storageData         Cross storage data
    /// @param  params              parameters of storeman debt lock
    function destDebtLock(CrossTypes.Data storage storageData, HTLCDebtLockParams memory params)
        public
    {
        storageData.htlcTxData.addDebtTx(params.xHash, params.srcSmgID, params.destSmgID, params.lockedTime, HTLCTxLib.TxStatus.DebtLocked);

        storageData.quota.debtLock(params.srcSmgID, params.destSmgID);

        emit DestDebtLockLogger(params.xHash, params.srcSmgID, params.destSmgID);
    }

    /// @notice                     redeem storeman debt
    /// @param  storageData         Cross storage data
    /// @param  x                   HTLC random number
    function srcDebtRedeem(CrossTypes.Data storage storageData, bytes32 x)
        external
    {
        bytes32 xHash = storageData.htlcTxData.redeemDebtTx(x, HTLCTxLib.TxStatus.DebtLocked);

        bytes32 srcSmgID;
        bytes32 destSmgID;
        (srcSmgID, destSmgID) = storageData.htlcTxData.getDebtTx(xHash);

        storageData.quota.debtRedeem(srcSmgID, destSmgID);

        emit SrcDebtRedeemLogger(xHash, srcSmgID, destSmgID, x);
    }

    /// @notice                     redeem storeman debt
    /// @param  storageData         Cross storage data
    /// @param  x                   HTLC random number
    function destDebtRedeem(CrossTypes.Data storage storageData, bytes32 x)
        external
    {
        bytes32 xHash = storageData.htlcTxData.redeemDebtTx(x, HTLCTxLib.TxStatus.AssetLocked);

        bytes32 srcSmgID;
        bytes32 destSmgID;
        (srcSmgID, destSmgID) = storageData.htlcTxData.getDebtTx(xHash);

        storageData.quota.assetRedeem(srcSmgID, destSmgID);

        emit DestDebtRedeemLogger(xHash, srcSmgID, destSmgID, x);
    }

    /// @notice                     revoke storeman debt
    /// @param  storageData         Cross storage data
    /// @param  xHash               hash of HTLC random number
    function destDebtRevoke(CrossTypes.Data storage storageData, bytes32 xHash)
        external
    {
        storageData.htlcTxData.revokeDebtTx(xHash, HTLCTxLib.TxStatus.DebtLocked);

        bytes32 srcSmgID;
        bytes32 destSmgID;
        (srcSmgID, destSmgID) = storageData.htlcTxData.getDebtTx(xHash);

        storageData.quota.debtRevoke(srcSmgID, destSmgID);

        emit DestDebtRevokeLogger(xHash, srcSmgID, destSmgID);
    }

    /// @notice                     revoke storeman debt
    /// @param  storageData         Cross storage data
    /// @param  xHash               hash of HTLC random number
    function srcDebtRevoke(CrossTypes.Data storage storageData, bytes32 xHash)
        external
    {
        storageData.htlcTxData.revokeDebtTx(xHash, HTLCTxLib.TxStatus.AssetLocked);

        bytes32 srcSmgID;
        bytes32 destSmgID;
        (srcSmgID, destSmgID) = storageData.htlcTxData.getDebtTx(xHash);

        storageData.quota.assetRevoke(srcSmgID, destSmgID);

        emit SrcDebtRevokeLogger(xHash, srcSmgID, destSmgID);
    }

}

// File: contracts/interfaces/ISmgFeeProxy.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity 0.4.26;

interface ISmgFeeProxy {
  function smgTransfer(bytes32 smgID) external payable;
}

// File: contracts/crossApproach/lib/RapidityLib.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;



// import "../../interfaces/IRC20Protocol.sol";


library RapidityLib {
    using SafeMath for uint;
    using RapidityTxLib for RapidityTxLib.Data;

    /**
    *
    * STRUCTURES
    *
    */

    /// @notice struct of Rapidity storeman mint lock parameters
    struct RapidityUserMintParams {
        bytes32 smgID;                      /// ID of storeman group which user has selected
        uint tokenPairID;                   /// token pair id on cross chain
        uint value;                         /// exchange token value
        bytes userShadowAccount;            /// account of shadow chain, used to receive token
    }

    /// @notice struct of Rapidity storeman mint lock parameters
    struct RapiditySmgMintParams {
        bytes32 uniqueID;                   /// Rapidity random number
        bytes32 smgID;                      /// ID of storeman group which user has selected
        uint tokenPairID;                   /// token pair id on cross chain
        uint value;                         /// exchange token value
        address userShadowAccount;          /// account of shadow chain, used to receive token
    }

    /// @notice struct of Rapidity user burn lock parameters
    struct RapidityUserBurnParams {
        bytes32 smgID;                  /// ID of storeman group which user has selected
        uint tokenPairID;               /// token pair id on cross chain
        uint value;                     /// exchange token value
        bytes userOrigAccount;          /// account of token original chain, used to receive token
    }

    /// @notice struct of Rapidity user burn lock parameters
    struct RapiditySmgBurnParams {
        bytes32 uniqueID;               /// Rapidity random number
        bytes32 smgID;                  /// ID of storeman group which user has selected
        uint tokenPairID;               /// token pair id on cross chain
        uint value;                     /// exchange token value
        address userOrigAccount;          /// account of token original chain, used to receive token
    }

    /**
     *
     * EVENTS
     *
     **/


    /// @notice                         event of exchange WRC-20 token with original chain token request
    /// @notice                         event invoked by storeman group
    /// @param smgID                    ID of storemanGroup
    /// @param tokenPairID              token pair ID of cross chain token
    /// @param value                    Rapidity value
    /// @param userAccount              account of shadow chain, used to receive token
    event UserFastMintLogger(bytes32 indexed smgID, uint indexed tokenPairID, uint value, uint fee, bytes userAccount);

    /// @notice                         event of exchange WRC-20 token with original chain token request
    /// @notice                         event invoked by storeman group
    /// @param uniqueID                 unique random number
    /// @param smgID                    ID of storemanGroup
    /// @param tokenPairID              token pair ID of cross chain token
    /// @param value                    Rapidity value
    /// @param userAccount              account of original chain, used to receive token
    event SmgFastMintLogger(bytes32 indexed uniqueID, bytes32 indexed smgID, uint indexed tokenPairID, uint value, address userAccount);

    /// @notice                         event of exchange WRC-20 token with original chain token request
    /// @notice                         event invoked by storeman group
    /// @param smgID                    ID of storemanGroup
    /// @param tokenPairID              token pair ID of cross chain token
    /// @param value                    Rapidity value
    /// @param userAccount              account of shadow chain, used to receive token
    event UserFastBurnLogger(bytes32 indexed smgID, uint indexed tokenPairID, uint value, uint fee, bytes userAccount);

    /// @notice                         event of exchange WRC-20 token with original chain token request
    /// @notice                         event invoked by storeman group
    /// @param uniqueID                 unique random number
    /// @param smgID                    ID of storemanGroup
    /// @param tokenPairID              token pair ID of cross chain token
    /// @param value                    Rapidity value
    /// @param userAccount              account of original chain, used to receive token
    event SmgFastBurnLogger(bytes32 indexed uniqueID, bytes32 indexed smgID, uint indexed tokenPairID, uint value, address userAccount);

    /**
    *
    * MANIPULATIONS
    *
    */

    /// @notice                         mintBridge, user lock token on token original chain
    /// @notice                         event invoked by user mint lock
    /// @param storageData              Cross storage data
    /// @param params                   parameters for user mint lock token on token original chain
    function userFastMint(CrossTypes.Data storage storageData, RapidityUserMintParams memory params)
        public
    {
        uint origChainID;
        uint shadowChainID;
        bytes memory tokenOrigAccount;
        (origChainID,tokenOrigAccount,shadowChainID) = storageData.tokenManager.getTokenPairInfoSlim(params.tokenPairID);
        require(origChainID != 0, "Token does not exist");

        uint lockFee = storageData.mapLockFee[origChainID][shadowChainID];

        storageData.quota.userFastMint(params.tokenPairID, params.smgID, params.value);

        if (lockFee > 0) {
            if (storageData.smgFeeProxy == address(0)) {
                storageData.mapStoremanFee[params.smgID] = storageData.mapStoremanFee[params.smgID].add(lockFee);
            } else {
                ISmgFeeProxy(storageData.smgFeeProxy).smgTransfer.value(lockFee)(params.smgID);
            }
        }

        address tokenScAddr = CrossTypes.bytesToAddress(tokenOrigAccount);

        uint left;
        if (tokenScAddr == address(0)) {
            left = (msg.value).sub(params.value).sub(lockFee);
        } else {
            left = (msg.value).sub(lockFee);

            // require(IRC20Protocol(tokenScAddr).transferFrom(msg.sender, this, params.value), "Lock token failed");
            require(CrossTypes.transferFrom(tokenScAddr, msg.sender, this, params.value), "Lock token failed");
        }
        if (left != 0) {
            (msg.sender).transfer(left);
        }
        emit UserFastMintLogger(params.smgID, params.tokenPairID, params.value, lockFee, params.userShadowAccount);
    }

    /// @notice                         mintBridge, storeman mint lock token on token shadow chain
    /// @notice                         event invoked by user mint lock
    /// @param storageData              Cross storage data
    /// @param params                   parameters for storeman mint lock token on token shadow chain
    function smgFastMint(CrossTypes.Data storage storageData, RapiditySmgMintParams memory params)
        public
    {
        storageData.rapidityTxData.addRapidityTx(params.uniqueID);

        storageData.quota.smgFastMint(params.tokenPairID, params.smgID, params.value);

        storageData.tokenManager.mintToken(params.tokenPairID, params.userShadowAccount, params.value);

        emit SmgFastMintLogger(params.uniqueID, params.smgID, params.tokenPairID, params.value, params.userShadowAccount);
    }

    /// @notice                         burnBridge, user lock token on token original chain
    /// @notice                         event invoked by user burn lock
    /// @param storageData              Cross storage data
    /// @param params                   parameters for user burn lock token on token original chain
    function userFastBurn(CrossTypes.Data storage storageData, RapidityUserBurnParams memory params)
        public
    {
        uint origChainID;
        uint shadowChainID;
        bytes memory tokenShadowAccount;
        (origChainID,,shadowChainID,tokenShadowAccount) = storageData.tokenManager.getTokenPairInfo(params.tokenPairID);
        require(origChainID != 0, "Token does not exist");

        uint lockFee = storageData.mapLockFee[origChainID][shadowChainID];

        storageData.quota.userFastBurn(params.tokenPairID, params.smgID, params.value);

        address tokenScAddr = CrossTypes.bytesToAddress(tokenShadowAccount);
        // require(IRC20Protocol(tokenScAddr).transferFrom(msg.sender, this, params.value), "Lock token failed");
        require(CrossTypes.transferFrom(tokenScAddr, msg.sender, this, params.value), "Lock token failed");

        storageData.tokenManager.burnToken(params.tokenPairID, params.value);

        if (lockFee > 0) {
            if (storageData.smgFeeProxy == address(0)) {
                storageData.mapStoremanFee[params.smgID] = storageData.mapStoremanFee[params.smgID].add(lockFee);
            } else {
                ISmgFeeProxy(storageData.smgFeeProxy).smgTransfer.value(lockFee)(params.smgID);
            }
        }

        uint left = (msg.value).sub(lockFee);
        if (left != 0) {
            (msg.sender).transfer(left);
        }

        emit UserFastBurnLogger(params.smgID, params.tokenPairID, params.value, lockFee, params.userOrigAccount);
    }

    /// @notice                         burnBridge, storeman burn lock token on token shadow chain
    /// @notice                         event invoked by user burn lock
    /// @param storageData              Cross storage data
    /// @param params                   parameters for storeman burn lock token on token shadow chain
    function smgFastBurn(CrossTypes.Data storage storageData, RapiditySmgBurnParams memory params)
        public
    {
        uint origChainID;
        bytes memory tokenOrigAccount;
        (origChainID,tokenOrigAccount,) = storageData.tokenManager.getTokenPairInfoSlim(params.tokenPairID);
        require(origChainID != 0, "Token does not exist");

        storageData.rapidityTxData.addRapidityTx(params.uniqueID);

        storageData.quota.smgFastBurn(params.tokenPairID, params.smgID, params.value);

        address tokenScAddr = CrossTypes.bytesToAddress(tokenOrigAccount);

        if (tokenScAddr == address(0)) {
            (params.userOrigAccount).transfer(params.value);
        } else {
            // require(IRC20Protocol(tokenScAddr).transfer(params.userOrigAccount, params.value), "Transfer token failed");
            require(CrossTypes.transfer(tokenScAddr, params.userOrigAccount, params.value), "Transfer token failed");
        }

        emit SmgFastBurnLogger(params.uniqueID, params.smgID, params.tokenPairID, params.value, params.userOrigAccount);
    }

}

// File: contracts/crossApproach/CrossDelegate.sol

/*

  Copyright 2019 Wanchain Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//

pragma solidity ^0.4.26;



// import "./lib/HTLCMintLib.sol";
// import "./lib/HTLCBurnLib.sol";



contract CrossDelegate is CrossStorage, ReentrancyGuard, Halt {
    using SafeMath for uint;

    /**
     *
     * EVENTS
     *
     **/

    /// @notice                         event of storeman group ID withdraw the original coin to receiver
    /// @param smgID                    ID of storemanGroup
    /// @param timeStamp                timestamp of the withdraw
    /// @param receiver                 receiver address
    /// @param fee                      shadow coin of the fee which the storeman group pk got it
    event SmgWithdrawFeeLogger(bytes32 indexed smgID, uint timeStamp, address indexed receiver, uint fee);

    /**
     *
     * MODIFIERS
     *
     */
    /// @dev Check valid value
    modifier onlyMeaningfulValue(uint value) {
        require(value != 0, "Value is null");
        _;
    }

    /// @notice                                 check the storeman group is ready
    /// @param smgID                            ID of storeman group
    modifier onlyReadySmg(bytes32 smgID) {
        uint8 status;
        uint startTime;
        uint endTime;
        (status,startTime,endTime) = storageData.smgAdminProxy.getStoremanGroupStatus(smgID);

        require(status == uint8(GroupStatus.ready) && now >= startTime && now <= endTime, "PK is not ready");
        _;
    }


    // function _checkValue(uint value) private view {
    //     require(value != 0, "Value is null");
    // }

    // function _checkReadySmg(bytes32 smgID) private view {
    //     uint8 status;
    //     uint startTime;
    //     uint endTime;
    //     (,status,,,,,,,,startTime,endTime) = storageData.smgAdminProxy.getStoremanGroupConfig(smgID);

    //     require(status == uint8(GroupStatus.ready) && now >= startTime && now <= endTime, "PK is not ready");
    // }

    // function _checkUnregisteredSmg(bytes32 smgID) private view {
    //     uint8 status;
    //     (,status,,,,,,,,,) = storageData.smgAdminProxy.getStoremanGroupConfig(smgID);

    //     require(status == uint8(GroupStatus.unregistered), "PK is not unregistered");
    // }

    /**
     *
     * MANIPULATIONS
     *
     */

    // /// @notice                                 get the exist storeman group info
    // /// @param smgID                            ID of storeman group
    // /// @return curveID                         ID of elliptic curve
    // /// @return PK                              PK of storeman group
    // function acquireExistSmgInfo(bytes32 smgID)
    //     private
    //     view
    //     returns (uint curveID, bytes memory PK)
    // {
    //     uint origChainID;
    //     (,,,origChainID,,curveID,,PK,,,) = storageData.smgAdminProxy.getStoremanGroupConfig(smgID);
    //     require(origChainID != 0, "PK does not exist");

    //     return (curveID, PK);
    // }

    /// @notice                                 check the storeman group is ready or not
    /// @param smgID                            ID of storeman group
    /// @return curveID                         ID of elliptic curve
    /// @return PK                              PK of storeman group
    function acquireReadySmgInfo(bytes32 smgID)
        private
        view
        returns (uint curveID, bytes memory PK)
    {
        uint8 status;
        uint startTime;
        uint endTime;
        (,status,,,,curveID,,PK,,startTime,endTime) = storageData.smgAdminProxy.getStoremanGroupConfig(smgID);

        require(status == uint8(GroupStatus.ready) && now >= startTime && now <= endTime, "PK is not ready");

        return (curveID, PK);
    }

    /// @notice                                 get the unregistered storeman group info
    /// @param smgID                            ID of storeman group
    /// @return curveID                         ID of elliptic curve
    /// @return PK                              PK of storeman group
    function acquireUnregisteredSmgInfo(bytes32 smgID)
        private
        view
        returns (uint curveID, bytes memory PK)
    {
        uint8 status;
        (,status,,,,curveID,,PK,,,) = storageData.smgAdminProxy.getStoremanGroupConfig(smgID);

        require(status == uint8(GroupStatus.unregistered), "PK is not unregistered");
    }
    /*
    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  xHash                           hash of HTLC random number
    /// @param  smgID                           ID of storeman
    /// @param  tokenPairID                     token pair ID of cross chain token
    /// @param  value                           exchange value
    /// @param  userAccount                     account of user, used to receive WRC20 token
    function userMintLock(bytes32 xHash, bytes32 smgID, uint tokenPairID, uint value, bytes userAccount)
        external
        payable
        notHalted
        nonReentrant
        onlyReadySmg(smgID)
        onlyMeaningfulValue(value)
    {
        HTLCMintLib.HTLCUserMintLockParams memory params = HTLCMintLib.HTLCUserMintLockParams({
            xHash: xHash,
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            lockedTime: lockedTime.mul(2),
            userShadowAccount: userAccount
        });

        HTLCMintLib.userMintLock(storageData, params);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  xHash                           hash of HTLC random number
    /// @param  smgID                           ID of storeman
    /// @param  tokenPairID                     token pair ID of cross chain token
    /// @param  value                           exchange value
    /// @param  userAccount                     address of user, used to receive WRC20 token
    /// @param  r                               signature
    /// @param  s                               signature
    function smgMintLock(bytes32 xHash, bytes32 smgID, uint tokenPairID, uint value, address userAccount, bytes r, bytes32 s)
        external
        notHalted
        nonReentrant
    {
        uint curveID;
        bytes memory PK;
        (curveID, PK) = acquireReadySmgInfo(smgID);

        bytes32 mHash = sha256(abi.encode(xHash, tokenPairID, value, userAccount));
        verifySignature(curveID, mHash, PK, r, s);

        HTLCMintLib.HTLCSmgMintLockParams memory params = HTLCMintLib.HTLCSmgMintLockParams({
            xHash: xHash,
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            lockedTime: lockedTime,
            userShadowAccount: userAccount
        });
        HTLCMintLib.smgMintLock(storageData, params);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  x                               HTLC random number
    function userMintRedeem(bytes32 x)
        external
        notHalted
        nonReentrant
    {
        HTLCMintLib.userMintRedeem(storageData, x);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  x                               HTLC random number
    function smgMintRedeem(bytes32 x)
        external
        notHalted
        nonReentrant
    {
        HTLCMintLib.smgMintRedeem(storageData, x);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  xHash                           hash of HTLC random number
    function smgMintRevoke(bytes32 xHash)
        external
        notHalted
        nonReentrant
    {
        HTLCMintLib.smgMintRevoke(storageData, xHash);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  xHash                           hash of HTLC random number
    function userMintRevoke(bytes32 xHash)
        external
        payable
        notHalted
        nonReentrant
    {
        HTLCMintLib.userMintRevoke(storageData, xHash);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  xHash                           hash of HTLC random number
    /// @param  smgID                           ID of storeman
    /// @param  tokenPairID                     token pair ID of cross chain token
    /// @param  value                           exchange value
    /// @param  userAccount                     account of user, used to receive original chain token
    function userBurnLock(bytes32 xHash, bytes32 smgID, uint tokenPairID, uint value, bytes userAccount)
        external
        payable
        notHalted
        nonReentrant
        onlyReadySmg(smgID)
        onlyMeaningfulValue(value)
    {
        HTLCBurnLib.HTLCUserBurnLockParams memory params = HTLCBurnLib.HTLCUserBurnLockParams({
            xHash: xHash,
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            lockedTime: lockedTime.mul(2),
            userOrigAccount: userAccount
        });
        HTLCBurnLib.userBurnLock(storageData, params);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  xHash                           hash of HTLC random number
    /// @param  smgID                           ID of storeman
    /// @param  tokenPairID                     token pair ID of cross chain token
    /// @param  value                           exchange value
    /// @param  userAccount                     address of user, used to receive WRC20 token
    /// @param  r                               signature
    /// @param  s                               signature
    function smgBurnLock(bytes32 xHash, bytes32 smgID, uint tokenPairID, uint value, address userAccount, bytes r, bytes32 s)
        external
        notHalted
        nonReentrant
    {
        uint curveID;
        bytes memory PK;
        (curveID, PK) = acquireReadySmgInfo(smgID);

        bytes32 mHash = sha256(abi.encode(xHash, tokenPairID, value, userAccount));
        verifySignature(curveID, mHash, PK, r, s);

        HTLCBurnLib.HTLCSmgBurnLockParams memory params = HTLCBurnLib.HTLCSmgBurnLockParams({
            xHash: xHash,
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            lockedTime: lockedTime,
            userOrigAccount: userAccount
        });
        HTLCBurnLib.smgBurnLock(storageData, params);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  x                               HTLC random number
    function userBurnRedeem(bytes32 x)
        external
        notHalted
        nonReentrant
    {
        HTLCBurnLib.userBurnRedeem(storageData, x);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  x                               HTLC random number
    function smgBurnRedeem(bytes32 x)
        external
        notHalted
        nonReentrant
    {
        HTLCBurnLib.smgBurnRedeem(storageData, x);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  xHash                           hash of HTLC random number
    function smgBurnRevoke(bytes32 xHash)
        external
        notHalted
        nonReentrant
    {
        HTLCBurnLib.smgBurnRevoke(storageData, xHash);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  xHash                           hash of HTLC random number
    function userBurnRevoke(bytes32 xHash)
        external
        payable
        notHalted
        nonReentrant
    {
        HTLCBurnLib.userBurnRevoke(storageData, xHash);
    }
*/
    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  smgID                           ID of storeman
    /// @param  tokenPairID                     token pair ID of cross chain token
    /// @param  value                           exchange value
    /// @param  userAccount                     account of user, used to receive shadow chain token
    function userFastMint(bytes32 smgID, uint tokenPairID, uint value, bytes userAccount)
        external
        payable
        notHalted
        // nonReentrant
        onlyReadySmg(smgID)
        onlyMeaningfulValue(value)
    {
        RapidityLib.RapidityUserMintParams memory params = RapidityLib.RapidityUserMintParams({
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            userShadowAccount: userAccount
        });
        RapidityLib.userFastMint(storageData, params);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  uniqueID                        fast cross chain random number
    /// @param  smgID                           ID of storeman
    /// @param  tokenPairID                     token pair ID of cross chain token
    /// @param  value                           exchange value
    /// @param  userAccount                     address of user, used to receive WRC20 token
    /// @param  r                               signature
    /// @param  s                               signature
    function smgFastMint(bytes32 uniqueID, bytes32 smgID, uint tokenPairID, uint value, address userAccount, bytes r, bytes32 s)
        external
        notHalted
        nonReentrant
    {
        uint curveID;
        bytes memory PK;
        // (curveID, PK) = acquireExistSmgInfo(smgID);
        (curveID, PK) = acquireReadySmgInfo(smgID);

        bytes32 mHash = sha256(abi.encode(uniqueID, tokenPairID, value, userAccount));
        verifySignature(curveID, mHash, PK, r, s);

        RapidityLib.RapiditySmgMintParams memory params = RapidityLib.RapiditySmgMintParams({
            uniqueID: uniqueID,
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            userShadowAccount: userAccount
        });
        RapidityLib.smgFastMint(storageData, params);
    }


    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  smgID                           ID of storeman
    /// @param  tokenPairID                     token pair ID of cross chain token
    /// @param  value                           exchange value
    /// @param  userAccount                     account of user, used to receive original chain token
    function userFastBurn(bytes32 smgID, uint tokenPairID, uint value, bytes userAccount)
        external
        payable
        notHalted
        nonReentrant
        onlyReadySmg(smgID)
        onlyMeaningfulValue(value)
    {
        RapidityLib.RapidityUserBurnParams memory params = RapidityLib.RapidityUserBurnParams({
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            userOrigAccount: userAccount
        });
        RapidityLib.userFastBurn(storageData, params);
    }

    /// @notice                                 request exchange RC20 token with WRC20 on wanchain
    /// @param  uniqueID                        fast cross chain random number
    /// @param  smgID                           ID of storeman
    /// @param  tokenPairID                     token pair ID of cross chain token
    /// @param  value                           exchange value
    /// @param  userAccount                     address of user, used to receive original token/coin
    /// @param  r                               signature
    /// @param  s                               signature
    function smgFastBurn(bytes32 uniqueID, bytes32 smgID, uint tokenPairID, uint value, address userAccount, bytes r, bytes32 s)
        external
        notHalted
        nonReentrant
    {
        uint curveID;
        bytes memory PK;
        // (curveID, PK) = acquireExistSmgInfo(smgID);
        (curveID, PK) = acquireReadySmgInfo(smgID);

        bytes32 mHash = sha256(abi.encode(uniqueID, tokenPairID, value, userAccount));
        verifySignature(curveID, mHash, PK, r, s);

        RapidityLib.RapiditySmgBurnParams memory params = RapidityLib.RapiditySmgBurnParams({
            uniqueID: uniqueID,
            smgID: smgID,
            tokenPairID: tokenPairID,
            value: value,
            userOrigAccount: userAccount
        });
        RapidityLib.smgFastBurn(storageData, params);
    }

    /// @notice                                 lock storeman debt
    /// @param  xHash                           hash of HTLC random number
    /// @param  srcSmgID                        ID of src storeman
    /// @param  destSmgID                       ID of dst storeman
    /// @param  r                               signature
    /// @param  s                               signature
    function srcDebtLock(bytes32 xHash, bytes32 srcSmgID, bytes32 destSmgID, bytes r, bytes32 s)
        external
        notHalted
        onlyReadySmg(destSmgID)
    {
        uint curveID;
        bytes memory PK;
        (curveID, PK) = acquireUnregisteredSmgInfo(srcSmgID);

        bytes32 mHash = sha256(abi.encode(xHash, destSmgID));
        verifySignature(curveID, mHash, PK, r, s);

        HTLCDebtLib.HTLCDebtLockParams memory params = HTLCDebtLib.HTLCDebtLockParams({
            xHash: xHash,
            srcSmgID: srcSmgID,
            destSmgID: destSmgID,
            lockedTime: lockedTime.mul(2)
        });
        HTLCDebtLib.srcDebtLock(storageData, params);
    }

    /// @notice                                 lock storeman debt
    /// @param  xHash                           hash of HTLC random number
    /// @param  srcSmgID                        ID of src storeman
    /// @param  destSmgID                       ID of dst storeman
    /// @param  r                               signature
    /// @param  s                               signature
    function destDebtLock(bytes32 xHash, bytes32 srcSmgID, bytes32 destSmgID, bytes r, bytes32 s)
        external
        notHalted
    {
        uint curveID;
        bytes memory PK;
        (curveID, PK) = acquireReadySmgInfo(destSmgID);

        bytes32 mHash = sha256(abi.encode(xHash, srcSmgID));
        verifySignature(curveID, mHash, PK, r, s);

        HTLCDebtLib.HTLCDebtLockParams memory params = HTLCDebtLib.HTLCDebtLockParams({
            xHash: xHash,
            srcSmgID: srcSmgID,
            destSmgID: destSmgID,
            lockedTime: lockedTime
        });
        HTLCDebtLib.destDebtLock(storageData, params);
    }

    /// @notice                                 redeem debt, destination storeman group takes over the debt of source storeman group
    /// @param  x                               HTLC random number
    function srcDebtRedeem(bytes32 x)
        external
        notHalted
    {
        HTLCDebtLib.srcDebtRedeem(storageData, x);
    }

    /// @notice                                 redeem debt, destination storeman group takes over the debt of source storeman group
    /// @param  x                               HTLC random number
    function destDebtRedeem(bytes32 x)
        external
        notHalted
    {
        HTLCDebtLib.destDebtRedeem(storageData, x);
    }

    /// @notice                                 source storeman group revoke the debt on debt chain
    /// @param  xHash                           hash of HTLC random number
    function destDebtRevoke(bytes32 xHash)
        external
        notHalted
    {
        HTLCDebtLib.destDebtRevoke(storageData, xHash);
    }

    /// @notice                                 source storeman group revoke the debt on asset chain
    /// @param  xHash                           hash of HTLC random number
    function srcDebtRevoke(bytes32 xHash)
        external
        notHalted
    {
        HTLCDebtLib.srcDebtRevoke(storageData, xHash);
    }

    /// @notice                             get the fee of the storeman group should get
    /// @param smgID                        ID of storemanGroup
    /// @return fee                         original coin the storeman group should get
    function getStoremanFee(bytes32 smgID)
        external
        view
        returns(uint fee)
    {
        fee = storageData.mapStoremanFee[smgID];
    }

    /// @notice                             get the fee of the storeman group should get
    /// @param origChainID                  ID of token original chain
    /// @param shadowChainID                ID of token shadow chain
    /// @param lockFee                      Coin the storeman group should get while storeman redeem user lock
    /// @param revokeFee                    Coin the storeman group should get while user revoke its lock
    function setFees(uint origChainID, uint shadowChainID, uint lockFee, uint revokeFee)
        external
        onlyOwner
    {
        storageData.mapLockFee[origChainID][shadowChainID] = lockFee;
        storageData.mapRevokeFee[origChainID][shadowChainID] = revokeFee;
    }

    /// @notice                             get the fee of the storeman group should get
    /// @param origChainID                  Original chain ID
    /// @param shadowChainID                Shadow Chain ID
    /// @return lockFee                     Coin the storeman group should get while storeman redeem user lock
    /// @return revokeFee                   Coin the storeman group should get while user revoke its lock
    function getFees(uint origChainID, uint shadowChainID)
        external
        view
        returns(uint lockFee, uint revokeFee)
    {
        lockFee = storageData.mapLockFee[origChainID][shadowChainID];
        revokeFee = storageData.mapRevokeFee[origChainID][shadowChainID];
    }

    /// @notice                             get the fee of the storeman group should get
    /// @param time                         Coin the storeman group should get while storeman redeem user lock
    function setLockedTime(uint time)
        external
        onlyOwner
    {
        lockedTime = time;
    }

    /// @notice                             get the fee of the storeman group should get
    /// @param  xHash                       hash of HTLC random number
    /// @return leftLockTime                left time of locked transaction
    function getLeftLockedTime(bytes32 xHash) external view returns (uint leftLockedTime) {
        leftLockedTime = storageData.htlcTxData.getLeftLockedTime(xHash);
    }

    /// @notice                             update the initialized state value of this contract
    /// @param tokenManager                 address of the token manager
    /// @param smgAdminProxy                address of the storeman group admin
    /// @param smgFeeProxy                  address of the proxy to store fee for storeman group
    /// @param quota                        address of the quota
    /// @param sigVerifier                  address of the signature verifier
    function setPartners(address tokenManager, address smgAdminProxy, address smgFeeProxy, address quota, address sigVerifier)
        external
        onlyOwner
    {
        require(tokenManager != address(0) && smgAdminProxy != address(0) && quota != address(0) && sigVerifier != address(0),
            "Parameter is invalid");

        storageData.smgAdminProxy = IStoremanGroup(smgAdminProxy);
        storageData.tokenManager = ITokenManager(tokenManager);
        storageData.quota = IQuota(quota);
        storageData.smgFeeProxy = smgFeeProxy;
        storageData.sigVerifier = ISignatureVerifier(sigVerifier);
    }

    /// @notice                             get the initialized state value of this contract
    /// @return tokenManager                address of the token manager
    /// @return smgAdminProxy               address of the storeman group admin
    /// @return smgFeeProxy                 address of the proxy to store fee for storeman group
    /// @return quota                       address of the quota
    /// @return sigVerifier                 address of the signature verifier
    function getPartners()
        external
        view
        returns(address tokenManager, address smgAdminProxy, address smgFeeProxy, address quota, address sigVerifier)
    {
        tokenManager = address(storageData.tokenManager);
        smgAdminProxy = address(storageData.smgAdminProxy);
        smgFeeProxy = storageData.smgFeeProxy;
        quota = address(storageData.quota);
        sigVerifier = address(storageData.sigVerifier);
    }

    /// @notice                             get the fee of the storeman group should get
    /// @param timeout                      Timeout for storeman group receiver withdraw fee, uint second
    function setWithdrawFeeTimeout(uint timeout)
        external
        onlyOwner
    {
        smgFeeReceiverTimeout = timeout;
    }

    /// @notice                             storeman group withdraw the fee to receiver account
    /// @param smgID                        ID of the storeman group
    /// @param receiver                     account of the receiver
    /// @param r                            signature
    /// @param s                            signature
    function smgWithdrawFee(bytes32 smgID, uint timeStamp, address receiver, bytes r, bytes32 s)
        external
        nonReentrant
    {

        require(now < timeStamp.add(smgFeeReceiverTimeout), "The receiver address expired");

        uint curveID;
        bytes memory PK;
        (,,,,,curveID,,PK,,,) = storageData.smgAdminProxy.getStoremanGroupConfig(smgID);
        verifySignature(curveID, sha256(abi.encode(timeStamp, receiver)), PK, r, s);

        uint fee = storageData.mapStoremanFee[smgID];

        require(fee > 0, "Fee is null");

        delete storageData.mapStoremanFee[smgID];
        receiver.transfer(fee);

        emit SmgWithdrawFeeLogger(smgID, now, receiver, fee);
    }

    /// @notice       convert bytes to bytes32
    /// @param b      bytes array
    /// @param offset offset of array to begin convert
    // function bytesToBytes32(bytes b, uint offset) private pure returns (bytes32) {
    //     bytes32 out;

    //     for (uint i = 0; i < 32; i++) {
    //       out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
    //     }
    //     return out;
    // }
    function bytesToBytes32(bytes memory b, uint offset) private pure returns (bytes32 result) {
        assembly {
            result := mload(add(add(b, offset), 32))
        }
    }

    /// @notice             verify signature
    /// @param  curveID     ID of elliptic curve
    /// @param  message     message to be verified
    /// @param  r           Signature info r
    /// @param  s           Signature info s
    function verifySignature(uint curveID, bytes32 message, bytes PK, bytes r, bytes32 s)
        private
        // view
    {
        bytes32 PKx = bytesToBytes32(PK, 0);
        bytes32 PKy = bytesToBytes32(PK, 32);

        bytes32 Rx = bytesToBytes32(r, 0);
        bytes32 Ry = bytesToBytes32(r, 32);

        require(storageData.sigVerifier.verify(curveID, s, PKx, PKy, Rx, Ry, message), "Signature verification failed");
    }

    // /// @notice                              get the detailed quota info. of this storeman group
    // /// @param smgID                         ID of storemanGroup
    // /// @param tokenPairID                   token pair ID of cross chain token
    // /// @return _quota                       storemanGroup's total quota
    // /// @return mintBridgeQuota              inbound, the amount which storeman group can handle
    // /// @return BurnBridgeQuota              outbound, the amount which storeman group can handle
    // /// @return _receivable                  amount of original token to be received, equals to amount of WAN token to be minted
    // /// @return _payable                     amount of WAN token to be burnt
    // /// @return _debt                        amount of original token has been exchanged to the wanchain
    // function queryStoremanGroupQuota(bytes32 smgID, uint tokenPairID)
    //     external
    //     view
    //     returns(uint, uint, uint, uint, uint, uint)
    // {
    //     return storageData.quotaData.queryQuotaInfo(smgID, tokenPairID);
    // }
}