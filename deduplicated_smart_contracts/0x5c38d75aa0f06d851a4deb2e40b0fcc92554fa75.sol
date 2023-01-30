// SPDX-License-Identifier: AGPL-3.0-only

/*
    IMintableToken.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

interface IMintableToken {
    function mint(
        address account,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    )
        external
        returns (bool);
}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    Schains.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./Permissions.sol";
import "./SchainsInternal.sol";
import "./ConstantsHolder.sol";
import "./KeyStorage.sol";
import "./SkaleVerifier.sol";
import "./FieldOperations.sol";
import "./NodeRotation.sol";
import "./ISkaleDKG.sol";


/**
 * @title Schains - contract contains all functionality logic to manage Schains
 */
contract Schains is Permissions {
    using StringUtils for string;
    using StringUtils for uint;

    struct SchainParameters {
        uint lifetime;
        uint8 typeOfSchain;
        uint16 nonce;
        string name;
    }

    // informs that Schain is created
    event SchainCreated(
        string name,
        address owner,
        uint partOfNode,
        uint lifetime,
        uint numberOfNodes,
        uint deposit,
        uint16 nonce,
        bytes32 schainId,
        uint time,
        uint gasSpend
    );

    event SchainDeleted(
        address owner,
        string name,
        bytes32 indexed schainId
    );

    event NodeRotated(
        bytes32 schainId,
        uint oldNode,
        uint newNode
    );

    event NodeAdded(
        bytes32 schainId,
        uint newNode
    );

    // informs that Schain based on some Nodes
    event SchainNodes(
        string name,
        bytes32 schainId,
        uint[] nodesInGroup,
        uint time,
        uint gasSpend
    );

    bytes32 public constant SCHAIN_CREATOR_ROLE = keccak256("SCHAIN_CREATOR_ROLE");

    /**
     * @dev addSchain - create Schain in the system
     * function could be run only by executor
     * @param from - owner of Schain
     * @param deposit - received amoung of SKL
     * @param data - Schain's data
     */
    function addSchain(address from, uint deposit, bytes calldata data) external allow("SkaleManager") {
        SchainParameters memory schainParameters = _fallbackSchainParametersDataConverter(data);
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        uint schainCreationTimeStamp = constantsHolder.schainCreationTimeStamp();
        uint minSchainLifetime = constantsHolder.minimalSchainLifetime();
        require(now >= schainCreationTimeStamp, "It is not a time for creating Schain");
        require(
            schainParameters.lifetime >= minSchainLifetime,
            "Minimal schain lifetime should be satisfied"
        );
        require(
            getSchainPrice(schainParameters.typeOfSchain, schainParameters.lifetime) <= deposit,
            "Not enough money to create Schain");

        _addSchain(from, deposit, schainParameters);
    }

    function addSchainByFoundation(
        uint lifetime,
        uint8 typeOfSchain,
        uint16 nonce,
        string calldata name
    )
        external
    {
        require(hasRole(SCHAIN_CREATOR_ROLE, msg.sender), "Sender is not authorized to create schian");

        SchainParameters memory schainParameters = SchainParameters({
            lifetime: lifetime,
            typeOfSchain: typeOfSchain,
            nonce: nonce,
            name: name
        });

        _addSchain(msg.sender, 0, schainParameters);
    }

    /**
     * @dev deleteSchain - removes Schain from the system
     * function could be run only by executor
     * @param from - owner of Schain
     * @param name - Schain name
     */
    function deleteSchain(address from, string calldata name) external allow("SkaleManager") {
        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        bytes32 schainId = keccak256(abi.encodePacked(name));
        require(
            schainsInternal.isOwnerAddress(from, schainId),
            "Message sender is not an owner of Schain"
        );
        address nodesAddress = contractManager.getContract("Nodes");

        // removes Schain from Nodes
        uint[] memory nodesInGroup = schainsInternal.getNodesInGroup(schainId);
        uint8 partOfNode = schainsInternal.getSchainsPartOfNode(schainId);
        for (uint i = 0; i < nodesInGroup.length; i++) {
            uint schainIndex = schainsInternal.findSchainAtSchainsForNode(
                nodesInGroup[i],
                schainId
            );
            if (schainsInternal.checkHoleForSchain(schainId, i)) {
                continue;
            }
            require(
                schainIndex < schainsInternal.getLengthOfSchainsForNode(nodesInGroup[i]),
                "Some Node does not contain given Schain");
            schainsInternal.removeNodeFromSchain(nodesInGroup[i], schainId);
            schainsInternal.removeNodeFromExceptions(schainId, nodesInGroup[i]);
            if (!Nodes(nodesAddress).isNodeLeft(nodesInGroup[i])) {
                this.addSpace(nodesInGroup[i], partOfNode);
            }
        }
        schainsInternal.deleteGroup(schainId);
        schainsInternal.removeSchain(schainId, from);
        schainsInternal.removeHolesForSchain(schainId);
        nodeRotation.removeRotation(schainId);
        emit SchainDeleted(from, name, schainId);
    }

    function deleteSchainByRoot(string calldata name) external allow("SkaleManager") {
        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        bytes32 schainId = keccak256(abi.encodePacked(name));
        SchainsInternal schainsInternal = SchainsInternal(
            contractManager.getContract("SchainsInternal"));
        require(schainsInternal.isSchainExist(schainId), "Schain does not exist");

        // removes Schain from Nodes
        uint[] memory nodesInGroup = schainsInternal.getNodesInGroup(schainId);
        uint8 partOfNode = schainsInternal.getSchainsPartOfNode(schainId);
        for (uint i = 0; i < nodesInGroup.length; i++) {
            uint schainIndex = schainsInternal.findSchainAtSchainsForNode(
                nodesInGroup[i],
                schainId
            );
            if (schainsInternal.checkHoleForSchain(schainId, i)) {
                continue;
            }
            require(
                schainIndex < schainsInternal.getLengthOfSchainsForNode(nodesInGroup[i]),
                "Some Node does not contain given Schain");
            schainsInternal.removeNodeFromSchain(nodesInGroup[i], schainId);
            schainsInternal.removeNodeFromExceptions(schainId, nodesInGroup[i]);
            this.addSpace(nodesInGroup[i], partOfNode);
        }
        schainsInternal.deleteGroup(schainId);
        address from = schainsInternal.getSchainOwner(schainId);
        schainsInternal.removeSchain(schainId, from);
        schainsInternal.removeHolesForSchain(schainId);
        nodeRotation.removeRotation(schainId);
        emit SchainDeleted(from, name, schainId);
    }

    function restartSchainCreation(string calldata name) external allow("SkaleManager") {
        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        bytes32 schainId = keccak256(abi.encodePacked(name));
        ISkaleDKG skaleDKG = ISkaleDKG(contractManager.getContract("SkaleDKG"));
        require(!skaleDKG.isLastDKGSuccesful(schainId), "DKG success");
        SchainsInternal schainsInternal = SchainsInternal(
            contractManager.getContract("SchainsInternal"));
        require(schainsInternal.isAnyFreeNode(schainId), "No any free Nodes for rotation");
        uint newNodeIndex = nodeRotation.selectNodeToGroup(schainId);
        skaleDKG.openChannel(schainId);
        emit NodeAdded(schainId, newNodeIndex);
    }

    /**
     * @dev addSpace - return occupied space to Node
     * @param nodeIndex - index of Node at common array of Nodes
     * @param partOfNode - divisor of given type of Schain
     */
    function addSpace(uint nodeIndex, uint8 partOfNode) external allowTwo("Schains", "NodeRotation") {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        nodes.addSpaceToNode(nodeIndex, partOfNode);
    }

    /**
     * @dev verifySignature - verify signature which create Group by Groups BLS master public key     
     * @param signatureA - first part of BLS signature
     * @param signatureB - second part of BLS signature
     * @param hash - hashed message
     * @param counter - smallest sub from square
     * @param hashA - first part of hashed message
     * @param hashB - second part of hashed message
     * @param schainName - name of the Schain
     * @return true - if correct, false - if not
     */
    function verifySchainSignature(
        uint signatureA,
        uint signatureB,
        bytes32 hash,
        uint counter,
        uint hashA,
        uint hashB,
        string calldata schainName
    )
        external
        view
        returns (bool)
    {
        SkaleVerifier skaleVerifier = SkaleVerifier(contractManager.getContract("SkaleVerifier"));

        G2Operations.G2Point memory publicKey = KeyStorage(
            contractManager.getContract("KeyStorage")
        ).getCommonPublicKey(
            keccak256(abi.encodePacked(schainName))
        );
        return skaleVerifier.verify(
            Fp2Operations.Fp2Point({
                a: signatureA,
                b: signatureB
            }),
            hash, counter,
            hashA, hashB,
            publicKey
        );
    }

    function initialize(address newContractsAddress) public override initializer {
        Permissions.initialize(newContractsAddress);
    }

    /**
     * @dev getSchainPrice - returns current price for given Schain
     * @param typeOfSchain - type of Schain
     * @param lifetime - lifetime of Schain
     * @return current price for given Schain
     */
    function getSchainPrice(uint typeOfSchain, uint lifetime) public view returns (uint) {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        uint nodeDeposit = constantsHolder.NODE_DEPOSIT();
        uint numberOfNodes;
        uint8 divisor;
        (numberOfNodes, divisor) = getNodesDataFromTypeOfSchain(typeOfSchain);
        if (divisor == 0) {
            return 1e18;
        } else {
            uint up = nodeDeposit.mul(numberOfNodes.mul(lifetime.mul(2)));
            uint down = uint(
                uint(constantsHolder.SMALL_DIVISOR())
                    .mul(uint(constantsHolder.SECONDS_TO_YEAR()))
                    .div(divisor)
            );
            return up.div(down);
        }
    }

    /**
     * @dev getNodesDataFromTypeOfSchain - returns number if Nodes
     * and part of Node which needed to this Schain
     * @param typeOfSchain - type of Schain
     * @return numberOfNodes - number of Nodes needed to this Schain
     * @return partOfNode - divisor of given type of Schain
     */
    function getNodesDataFromTypeOfSchain(uint typeOfSchain)
        public
        view
        returns (uint numberOfNodes, uint8 partOfNode)
    {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        numberOfNodes = constantsHolder.NUMBER_OF_NODES_FOR_SCHAIN();
        if (typeOfSchain == 1) {
            partOfNode = constantsHolder.SMALL_DIVISOR() / constantsHolder.SMALL_DIVISOR();
        } else if (typeOfSchain == 2) {
            partOfNode = constantsHolder.SMALL_DIVISOR() / constantsHolder.MEDIUM_DIVISOR();
        } else if (typeOfSchain == 3) {
            partOfNode = constantsHolder.SMALL_DIVISOR() / constantsHolder.LARGE_DIVISOR();
        } else if (typeOfSchain == 4) {
            partOfNode = 0;
            numberOfNodes = constantsHolder.NUMBER_OF_NODES_FOR_TEST_SCHAIN();
        } else if (typeOfSchain == 5) {
            partOfNode = constantsHolder.SMALL_DIVISOR() / constantsHolder.MEDIUM_TEST_DIVISOR();
            numberOfNodes = constantsHolder.NUMBER_OF_NODES_FOR_MEDIUM_TEST_SCHAIN();
        } else {
            revert("Bad schain type");
        }
    }

    function _initializeSchainInSchainsInternal(
        string memory name,
        address from,
        uint deposit,
        uint lifetime) private
    {
        address dataAddress = contractManager.getContract("SchainsInternal");
        require(SchainsInternal(dataAddress).isSchainNameAvailable(name), "Schain name is not available");

        // initialize Schain
        SchainsInternal(dataAddress).initializeSchain(
            name,
            from,
            lifetime,
            deposit);
        SchainsInternal(dataAddress).setSchainIndex(keccak256(abi.encodePacked(name)), from);
    }

    /**
     * @dev fallbackSchainParameterDataConverter - converts data from bytes to normal parameters
     * @param data - concatenated parameters
     * @return schainParameters Parsed lifetime, typeOfSchain, nonce and name
     */
    function _fallbackSchainParametersDataConverter(bytes memory data)
        private
        pure
        returns (SchainParameters memory schainParameters)
    {
        (schainParameters.lifetime,
        schainParameters.typeOfSchain,
        schainParameters.nonce,
        schainParameters.name) = abi.decode(data, (uint, uint8, uint16, string));
    }

    /**
     * @dev _createGroupForSchain - creates Group for Schain
     * @param schainName - name of Schain
     * @param schainId - hash by name of Schain
     * @param numberOfNodes - number of Nodes needed for this Schain
     * @param partOfNode - divisor of given type of Schain
     */
    function _createGroupForSchain(
        string memory schainName,
        bytes32 schainId,
        uint numberOfNodes,
        uint8 partOfNode
    )
        private
    {
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        uint[] memory nodesInGroup = schainsInternal.createGroupForSchain(schainId, numberOfNodes, partOfNode);
        ISkaleDKG(contractManager.getContract("SkaleDKG")).openChannel(schainId);

        emit SchainNodes(
            schainName,
            schainId,
            nodesInGroup,
            block.timestamp,
            gasleft());
    }

    /**
     * @dev _addSchain - create Schain in the system
     * function could be run only by executor
     * @param from - owner of Schain
     * @param deposit - received amoung of SKL
     * @param schainParameters - Schain's data
     */
    function _addSchain(address from, uint deposit, SchainParameters memory schainParameters) private {
        uint numberOfNodes;
        uint8 partOfNode;

        require(schainParameters.typeOfSchain <= 5, "Invalid type of Schain");

        //initialize Schain
        _initializeSchainInSchainsInternal(
            schainParameters.name,
            from,
            deposit,
            schainParameters.lifetime);

        // create a group for Schain
        (numberOfNodes, partOfNode) = getNodesDataFromTypeOfSchain(schainParameters.typeOfSchain);

        _createGroupForSchain(
            schainParameters.name,
            keccak256(abi.encodePacked(schainParameters.name)),
            numberOfNodes,
            partOfNode
        );

        emit SchainCreated(
            schainParameters.name,
            from,
            partOfNode,
            schainParameters.lifetime,
            numberOfNodes,
            deposit,
            schainParameters.nonce,
            keccak256(abi.encodePacked(schainParameters.name)),
            block.timestamp,
            gasleft());
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    StringUtils.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;


library MathUtils {
    event UnderflowError(
        uint a,
        uint b
    );

    uint constant private _EPS = 1e6;

    function boundedSub(uint256 a, uint256 b) internal returns (uint256) {
        if (a >= b) {
            return a - b;
        } else {
            emit UnderflowError(a, b);
            return 0;
        }
    }

    function boundedSubWithoutEvent(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a >= b) {
            return a - b;
        } else {
            return 0;
        }
    }

    function muchGreater(uint256 a, uint256 b) internal pure returns (bool) {
        assert(uint(-1) - _EPS > b);
        return a > b + _EPS;
    }

    function approximatelyEqual(uint256 a, uint256 b) internal pure returns (bool) {
        if (a > b) {
            return a - b < _EPS;
        } else {
            return b - a < _EPS;
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    Precompiled.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;


library Precompiled {

    function bigModExp(uint base, uint power, uint modulus) internal view returns (uint) {
        uint[6] memory inputToBigModExp;
        inputToBigModExp[0] = 32;
        inputToBigModExp[1] = 32;
        inputToBigModExp[2] = 32;
        inputToBigModExp[3] = base;
        inputToBigModExp[4] = power;
        inputToBigModExp[5] = modulus;
        uint[1] memory out;
        bool success;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            success := staticcall(not(0), 5, inputToBigModExp, mul(6, 0x20), out, 0x20)
        }
        require(success, "BigModExp failed");
        return out[0];
    }

    function bn256ScalarMul(uint x, uint y, uint k) internal view returns (uint , uint ) {
        uint[3] memory inputToMul;
        uint[2] memory output;
        inputToMul[0] = x;
        inputToMul[1] = y;
        inputToMul[2] = k;
        bool success;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            success := staticcall(not(0), 7, inputToMul, 0x60, output, 0x40)
        }
        require(success, "Multiplication failed");
        return (output[0], output[1]);
    }

    function bn256Pairing(
        uint x1,
        uint y1,
        uint a1,
        uint b1,
        uint c1,
        uint d1,
        uint x2,
        uint y2,
        uint a2,
        uint b2,
        uint c2,
        uint d2)
        internal view returns (bool)
    {
        bool success;
        uint[12] memory inputToPairing;
        inputToPairing[0] = x1;
        inputToPairing[1] = y1;
        inputToPairing[2] = a1;
        inputToPairing[3] = b1;
        inputToPairing[4] = c1;
        inputToPairing[5] = d1;
        inputToPairing[6] = x2;
        inputToPairing[7] = y2;
        inputToPairing[8] = a2;
        inputToPairing[9] = b2;
        inputToPairing[10] = c2;
        inputToPairing[11] = d2;
        uint[1] memory out;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            success := staticcall(not(0), 8, inputToPairing, mul(12, 0x20), out, 0x20)
        }
        require(success, "Pairing check failed");
        return out[0] != 0;
    }
}
pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    Decryption.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;


contract Decryption {

    function encrypt(uint256 secretNumber, bytes32 key) external pure returns (bytes32 ciphertext) {
        return bytes32(secretNumber) ^ key;
    }

    function decrypt(bytes32 ciphertext, bytes32 key) external pure returns (uint256 secretNumber) {
        return uint256(ciphertext ^ key);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    Bounty.sol - SKALE Manager
    Copyright (C) 2020-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./ConstantsHolder.sol";
import "./Nodes.sol";
import "./Permissions.sol";


contract Bounty is Permissions {

    uint public constant STAGE_LENGTH = 31558150; // 1 year
    uint public constant YEAR1_BOUNTY = 3850e5 * 1e18;
    uint public constant YEAR2_BOUNTY = 3465e5 * 1e18;
    uint public constant YEAR3_BOUNTY = 3080e5 * 1e18;
    uint public constant YEAR4_BOUNTY = 2695e5 * 1e18;
    uint public constant YEAR5_BOUNTY = 2310e5 * 1e18;
    uint public constant YEAR6_BOUNTY = 1925e5 * 1e18;
    uint public constant BOUNTY = 96250000 * 1e18;

    uint private _nextStage;
    uint private _stagePool;
    bool public bountyReduction;

    uint private _nodesPerRewardPeriod;
    uint private _nodesRemainingPerRewardPeriod;
    uint private _rewardPeriodFinished;

    function getBounty(
        uint nodeIndex,
        uint downtime,
        uint latency
    )
        external
        allow("SkaleManager")
        returns (uint)
    {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));

        _refillStagePool(constantsHolder);

        if (_rewardPeriodFinished <= now) {
            _updateNodesPerRewardPeriod(constantsHolder, nodes);
        }

        uint bounty = _calculateMaximumBountyAmount(_stagePool, _nextStage, nodeIndex, constantsHolder, nodes);

        bounty = _reduceBounty(
            bounty,
            nodeIndex,
            downtime,
            latency,
            nodes,
            constantsHolder
        );

        _stagePool = _stagePool.sub(bounty);
        _nodesRemainingPerRewardPeriod = _nodesRemainingPerRewardPeriod.sub(1);

        return bounty;
    }

    function enableBountyReduction() external onlyOwner {
        bountyReduction = true;
    }

    function disableBountyReduction() external onlyOwner {
        bountyReduction = false;
    }

    function calculateNormalBounty(uint nodeIndex) external view returns (uint) {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));

        uint stagePoolSize;
        uint nextStage;
        (stagePoolSize, nextStage) = _getStagePoolSize(constantsHolder);

        return _calculateMaximumBountyAmount(
            stagePoolSize,
            nextStage,
            nodeIndex,
            constantsHolder,
            nodes
        );
    }

    function initialize(address contractManagerAddress) public override initializer {
        Permissions.initialize(contractManagerAddress);
        _nextStage = 0;
        _stagePool = 0;
        _rewardPeriodFinished = 0;
        bountyReduction = false;
    }

    // private

    function _calculateMaximumBountyAmount(
        uint stagePoolSize,
        uint nextStage,
        uint nodeIndex,
        ConstantsHolder constantsHolder,
        Nodes nodes
    )
        private
        view
        returns (uint)
    {
        if (nodes.isNodeLeft(nodeIndex)) {
            return 0;
        }

        if (now < constantsHolder.launchTimestamp()) {
            // network is not launched
            // bounty is turned off
            return 0;
        }

        uint numberOfRewards = _getStageBeginningTimestamp(nextStage, constantsHolder)
            .sub(now)
            .div(constantsHolder.rewardPeriod());

        uint numberOfRewardsPerAllNodes = numberOfRewards.mul(_nodesPerRewardPeriod);

        return stagePoolSize.div(
            numberOfRewardsPerAllNodes.add(_nodesRemainingPerRewardPeriod)
        );
    }

    function _getStageBeginningTimestamp(uint stage, ConstantsHolder constantsHolder) private view returns (uint) {
        return constantsHolder.launchTimestamp().add(stage.mul(STAGE_LENGTH));
    }

    function _getStagePoolSize(ConstantsHolder constantsHolder) private view returns (uint stagePool, uint nextStage) {
        stagePool = _stagePool;
        for (nextStage = _nextStage; now >= _getStageBeginningTimestamp(nextStage, constantsHolder); ++nextStage) {
            stagePool += _getStageReward(_nextStage);
        }
    }

    function _refillStagePool(ConstantsHolder constantsHolder) private {
        (_stagePool, _nextStage) = _getStagePoolSize(constantsHolder);
    }

    function _updateNodesPerRewardPeriod(ConstantsHolder constantsHolder, Nodes nodes) private {
        _nodesPerRewardPeriod = nodes.getNumberOnlineNodes();
        _nodesRemainingPerRewardPeriod = _nodesPerRewardPeriod;
        _rewardPeriodFinished = now.add(uint(constantsHolder.rewardPeriod()));
    }

    function _getStageReward(uint stage) private pure returns (uint) {
        if (stage >= 6) {
            return BOUNTY.div(2 ** stage.sub(6).div(3));
        } else {
            if (stage == 0) {
                return YEAR1_BOUNTY;
            } else if (stage == 1) {
                return YEAR2_BOUNTY;
            } else if (stage == 2) {
                return YEAR3_BOUNTY;
            } else if (stage == 3) {
                return YEAR4_BOUNTY;
            } else if (stage == 4) {
                return YEAR5_BOUNTY;
            } else {
                return YEAR6_BOUNTY;
            }
        }
    }

    function _reduceBounty(
        uint bounty,
        uint nodeIndex,
        uint downtime,
        uint latency,
        Nodes nodes,
        ConstantsHolder constants
    )
        private
        returns (uint reducedBounty)
    {
        if (!bountyReduction) {
            return bounty;
        }

        reducedBounty = _reduceBountyByDowntime(bounty, nodeIndex, downtime, nodes, constants);

        if (latency > constants.allowableLatency()) {
            // reduce bounty because latency is too big
            reducedBounty = reducedBounty.mul(constants.allowableLatency()).div(latency);
        }

        if (!nodes.checkPossibilityToMaintainNode(nodes.getValidatorId(nodeIndex), nodeIndex)) {
            reducedBounty = reducedBounty.div(constants.MSR_REDUCING_COEFFICIENT());
        }
    }

    function _reduceBountyByDowntime(
        uint bounty,
        uint nodeIndex,
        uint downtime,
        Nodes nodes,
        ConstantsHolder constants
    )
        private
        view
        returns (uint reducedBounty)
    {
        reducedBounty = bounty;
        uint getBountyDeadline = uint(nodes.getNodeLastRewardDate(nodeIndex))
            .add(constants.rewardPeriod())
            .add(constants.deltaPeriod());
        uint numberOfExpiredIntervals;
        if (now > getBountyDeadline) {
            numberOfExpiredIntervals = now.sub(getBountyDeadline).div(constants.checkTime());
        } else {
            numberOfExpiredIntervals = 0;
        }
        uint normalDowntime = uint(constants.rewardPeriod())
            .sub(constants.deltaPeriod())
            .div(constants.checkTime())
            .div(constants.DOWNTIME_THRESHOLD_PART());
        uint totalDowntime = downtime.add(numberOfExpiredIntervals);
        if (totalDowntime > normalDowntime) {
            // reduce bounty because downtime is too big
            uint penalty = bounty
                .mul(totalDowntime)
                .div(
                    uint(constants.rewardPeriod()).sub(constants.deltaPeriod())
                        .div(constants.checkTime())
                );
            if (bounty > penalty) {
                reducedBounty = bounty.sub(penalty);
            } else {
                reducedBounty = 0;
            }
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    Nodes.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./SafeCast.sol";

import "./Permissions.sol";
import "./ConstantsHolder.sol";
import "./ValidatorService.sol";
import "./DelegationController.sol";


/**
 * @title Nodes - contract contains all functionality logic to manage Nodes
 */
contract Nodes is Permissions {
    
    using SafeCast for uint;

    // All Nodes states
    enum NodeStatus {Active, Leaving, Left, In_Maintenance}

    struct Node {
        string name;
        bytes4 ip;
        bytes4 publicIP;
        uint16 port;
        bytes32[2] publicKey;
        uint startBlock;
        uint lastRewardDate;
        uint finishTime;
        NodeStatus status;
        uint validatorId;
    }

    // struct to note which Nodes and which number of Nodes owned by user
    struct CreatedNodes {
        mapping (uint => bool) isNodeExist;
        uint numberOfNodes;
    }

    struct SpaceManaging {
        uint8 freeSpace;
        uint indexInSpaceMap;
    }

    // TODO: move outside the contract
    struct NodeCreationParams {
        string name;
        bytes4 ip;
        bytes4 publicIp;
        uint16 port;
        bytes32[2] publicKey;
        uint16 nonce;
    }

    // array which contain all Nodes
    Node[] public nodes;

    SpaceManaging[] public spaceOfNodes;

    // mapping for checking which Nodes and which number of Nodes owned by user
    mapping (address => CreatedNodes) public nodeIndexes;
    // mapping for checking is IP address busy
    mapping (bytes4 => bool) public nodesIPCheck;
    // mapping for checking is Name busy
    mapping (bytes32 => bool) public nodesNameCheck;
    // mapping for indication from Name to Index
    mapping (bytes32 => uint) public nodesNameToIndex;
    // mapping for indication from space to Nodes
    mapping (uint8 => uint[]) public spaceToNodes;

    mapping (uint => uint[]) public validatorToNodeIndexes;

    uint public numberOfActiveNodes;
    uint public numberOfLeavingNodes;
    uint public numberOfLeftNodes;

    // informs that Node is created
    event NodeCreated(
        uint nodeIndex,
        address owner,
        string name,
        bytes4 ip,
        bytes4 publicIP,
        uint16 port,
        uint16 nonce,
        uint time,
        uint gasSpend
    );

    // informs that node is fully finished quitting from the system
    event ExitCompleted(
        uint nodeIndex,
        uint time,
        uint gasSpend
    );

    // informs that owner starts the procedure of quitting the Node from the system
    event ExitInited(
        uint nodeIndex,
        uint startLeavingPeriod,
        uint time,
        uint gasSpend
    );

    modifier checkNodeExists(uint nodeIndex) {
        require(nodeIndex < nodes.length, "Node with such index does not exist");
        _;
    }

    /**
     * @dev removeSpaceFromFractionalNode - occupies space from Fractional Node
     * function could be run only by Schains
     * @param nodeIndex - index of Node at array of Fractional Nodes
     * @param space - space which should be occupied
     */
    function removeSpaceFromNode(uint nodeIndex, uint8 space)
        external
        checkNodeExists(nodeIndex)
        allowTwo("NodeRotation", "SchainsInternal")
        returns (bool)
    {
        if (spaceOfNodes[nodeIndex].freeSpace < space) {
            return false;
        }
        if (space > 0) {
            _moveNodeToNewSpaceMap(
                nodeIndex,
                uint(spaceOfNodes[nodeIndex].freeSpace).sub(space).toUint8()
            );
        }
        return true;
    }

    /**
     * @dev adSpaceToFractionalNode - returns space to Fractional Node
     * function could be run only be Schains
     * @param nodeIndex - index of Node at array of Fractional Nodes
     * @param space - space which should be returned
     */
    function addSpaceToNode(uint nodeIndex, uint8 space)
        external
        checkNodeExists(nodeIndex)
        allow("Schains")
    {
        if (space > 0) {
            _moveNodeToNewSpaceMap(
                nodeIndex,
                uint(spaceOfNodes[nodeIndex].freeSpace).add(space).toUint8()
            );
        }
    }

    /**
     * @dev changeNodeLastRewardDate - changes Node's last reward date
     * function could be run only by SkaleManager
     * @param nodeIndex - index of Node
     */
    function changeNodeLastRewardDate(uint nodeIndex)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
    {
        nodes[nodeIndex].lastRewardDate = block.timestamp;
    }

    function changeNodeFinishTime(uint nodeIndex, uint time)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
    {
        nodes[nodeIndex].finishTime = time;
    }

    /**
     * @dev createNode - creates new Node and add it to the Nodes contract
     * function could be only run by SkaleManager
     * @param from - owner of Node
     */
    //  * @return nodeIndex - index of Node
    function createNode(address from, NodeCreationParams calldata params)
        external
        allow("SkaleManager")
        // returns (uint nodeIndex)
    {
        // checks that Node has correct data
        require(params.ip != 0x0 && !nodesIPCheck[params.ip], "IP address is zero or is not available");
        require(!nodesNameCheck[keccak256(abi.encodePacked(params.name))], "Name has already registered");
        require(params.port > 0, "Port is zero");

        uint validatorId = ValidatorService(
            contractManager.getContract("ValidatorService")).getValidatorIdByNodeAddress(from);

        // adds Node to Nodes contract
        uint nodeIndex = _addNode(
            from,
            params.name,
            params.ip,
            params.publicIp,
            params.port,
            params.publicKey,
            validatorId);

        emit NodeCreated(
            nodeIndex,
            from,
            params.name,
            params.ip,
            params.publicIp,
            params.port,
            params.nonce,
            block.timestamp,
            gasleft());
    }

    /**
     * @dev initExit - initiate a procedure of quitting the system
     * function could be only run by SkaleManager
     * @param nodeIndex - index of Node
     * @return true - if everything OK
     */
    function initExit(uint nodeIndex)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
        returns (bool)
    {
        _setNodeLeaving(nodeIndex);

        emit ExitInited(
            nodeIndex,
            block.timestamp,
            block.timestamp,
            gasleft());
        return true;
    }

    /**
     * @dev completeExit - finish a procedure of quitting the system
     * function could be run only by SkaleManager
     * @param nodeIndex - index of Node
     * @return amount of SKL which be returned
     */
    function completeExit(uint nodeIndex)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
        returns (bool)
    {
        require(isNodeLeaving(nodeIndex), "Node is not Leaving");

        _setNodeLeft(nodeIndex);
        _deleteNode(nodeIndex);

        emit ExitCompleted(
            nodeIndex,
            block.timestamp,
            gasleft());
        return true;
    }

    function deleteNodeForValidator(uint validatorId, uint nodeIndex)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
    {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(validatorService.validatorExists(validatorId), "Validator with such ID does not exist");
        uint[] memory validatorNodes = validatorToNodeIndexes[validatorId];
        uint position = _findNode(validatorNodes, nodeIndex);
        if (position < validatorNodes.length) {
            validatorToNodeIndexes[validatorId][position] =
                validatorToNodeIndexes[validatorId][validatorNodes.length.sub(1)];
        }
        validatorToNodeIndexes[validatorId].pop();
    }

    function checkPossibilityCreatingNode(address nodeAddress) external allow("SkaleManager") {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController")
        );
        uint validatorId = validatorService.getValidatorIdByNodeAddress(nodeAddress);
        require(validatorService.isAuthorizedValidator(validatorId), "Validator is not authorized to create a node");
        uint[] memory validatorNodes = validatorToNodeIndexes[validatorId];
        uint delegationsTotal = delegationController.getAndUpdateDelegatedToValidatorNow(validatorId);
        uint msr = ConstantsHolder(contractManager.getContract("ConstantsHolder")).msr();
        require(
            validatorNodes.length.add(1).mul(msr) <= delegationsTotal,
            "Validator must meet the Minimum Staking Requirement");
    }

    function checkPossibilityToMaintainNode(
        uint validatorId,
        uint nodeIndex
    )
        external
        checkNodeExists(nodeIndex)
        allow("Bounty")
        returns (bool)
    {
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController")
        );
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(validatorService.validatorExists(validatorId), "Validator with such ID does not exist");
        uint[] memory validatorNodes = validatorToNodeIndexes[validatorId];
        uint position = _findNode(validatorNodes, nodeIndex);
        require(position < validatorNodes.length, "Node does not exist for this Validator");
        uint delegationsTotal = delegationController.getAndUpdateDelegatedToValidatorNow(validatorId);
        uint msr = ConstantsHolder(contractManager.getContract("ConstantsHolder")).msr();
        return position.add(1).mul(msr) <= delegationsTotal;
    }

    function setNodeInMaintenance(uint nodeIndex) external {
        require(nodes[nodeIndex].status == NodeStatus.Active, "Node is not Active");
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        uint validatorId = getValidatorId(nodeIndex);
        bool permitted = (_isOwner() || isNodeExist(msg.sender, nodeIndex));
        if (!permitted) {
            permitted = validatorService.getValidatorId(msg.sender) == validatorId;
        }
        require(permitted, "Sender is not permitted to call this function");
        nodes[nodeIndex].status = NodeStatus.In_Maintenance;
    }

    function removeNodeFromInMaintenance(uint nodeIndex) external {
        require(nodes[nodeIndex].status == NodeStatus.In_Maintenance, "Node is not In Maintence");
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        uint validatorId = getValidatorId(nodeIndex);
        bool permitted = (_isOwner() || isNodeExist(msg.sender, nodeIndex));
        if (!permitted) {
            permitted = validatorService.getValidatorId(msg.sender) == validatorId;
        }
        require(permitted, "Sender is not permitted to call this function");
        nodes[nodeIndex].status = NodeStatus.Active;
    }

    function getNodesWithFreeSpace(uint8 freeSpace) external view returns (uint[] memory) {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        uint[] memory nodesWithFreeSpace = new uint[](countNodesWithFreeSpace(freeSpace));
        uint cursor = 0;
        uint totalSpace = constantsHolder.TOTAL_SPACE_ON_NODE();
        for (uint8 i = freeSpace; i <= totalSpace; ++i) {
            for (uint j = 0; j < spaceToNodes[i].length; j++) {
                nodesWithFreeSpace[cursor] = spaceToNodes[i][j];
                ++cursor;
            }
        }
        return nodesWithFreeSpace;
    }

    /**
     * @dev isTimeForReward - checks if time for reward has come
     * @param nodeIndex - index of Node
     * @return if time for reward has come - true, else - false
     */
    function isTimeForReward(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        return uint(nodes[nodeIndex].lastRewardDate).add(constantsHolder.rewardPeriod()) <= block.timestamp;
    }

    /**
     * @dev getNodeIP - get ip address of Node
     * @param nodeIndex - index of Node
     * @return ip address
     */
    function getNodeIP(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bytes4)
    {
        require(nodeIndex < nodes.length, "Node does not exist");
        return nodes[nodeIndex].ip;
    }

    /**
     * @dev getNodePort - get Node's port
     * @param nodeIndex - index of Node
     * @return port
     */
    function getNodePort(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (uint16)
    {
        return nodes[nodeIndex].port;
    }

    function getNodePublicKey(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bytes32[2] memory)
    {
        return nodes[nodeIndex].publicKey;
    }

    function getNodeFinishTime(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (uint)
    {
        return nodes[nodeIndex].finishTime;
    }

    /**
     * @dev isNodeLeft - checks if Node status Left
     * @param nodeIndex - index of Node
     * @return if Node status Left - true, else - false
     */
    function isNodeLeft(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {
        return nodes[nodeIndex].status == NodeStatus.Left;
    }

    function isNodeInMaintenance(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {
        return nodes[nodeIndex].status == NodeStatus.In_Maintenance;
    }

    /**
     * @dev getNodeLastRewardDate - get Node last reward date
     * @param nodeIndex - index of Node
     * @return Node last reward date
     */
    function getNodeLastRewardDate(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (uint)
    {
        return nodes[nodeIndex].lastRewardDate;
    }

    /**
     * @dev getNodeNextRewardDate - get Node next reward date
     * @param nodeIndex - index of Node
     * @return Node next reward date
     */
    function getNodeNextRewardDate(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (uint)
    {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        return nodes[nodeIndex].lastRewardDate.add(constantsHolder.rewardPeriod());
    }

    /**
     * @dev getNumberOfNodes - get number of Nodes
     * @return number of Nodes
     */
    function getNumberOfNodes() external view returns (uint) {
        return nodes.length;
    }

    /**
     * @dev getNumberOfFullNodes - get number Online Nodes
     * @return number of active nodes plus number of leaving nodes
     */
    function getNumberOnlineNodes() external view returns (uint) {
        return numberOfActiveNodes.add(numberOfLeavingNodes);
    }

    /**
     * @dev getActiveNodeIPs - get array of ips of Active Nodes
     * @return activeNodeIPs - array of ips of Active Nodes
     */
    function getActiveNodeIPs() external view returns (bytes4[] memory activeNodeIPs) {
        activeNodeIPs = new bytes4[](numberOfActiveNodes);
        uint indexOfActiveNodeIPs = 0;
        for (uint indexOfNodes = 0; indexOfNodes < nodes.length; indexOfNodes++) {
            if (isNodeActive(indexOfNodes)) {
                activeNodeIPs[indexOfActiveNodeIPs] = nodes[indexOfNodes].ip;
                indexOfActiveNodeIPs++;
            }
        }
    }

    /**
     * @dev getActiveNodesByAddress - get array of indexes of Active Nodes, which were
     * created by msg.sender
     * @return activeNodesByAddress Array of indexes of Active Nodes, which were created by msg.sender
     */
    function getActiveNodesByAddress() external view returns (uint[] memory activeNodesByAddress) {
        activeNodesByAddress = new uint[](nodeIndexes[msg.sender].numberOfNodes);
        uint indexOfActiveNodesByAddress = 0;
        for (uint indexOfNodes = 0; indexOfNodes < nodes.length; indexOfNodes++) {
            if (nodeIndexes[msg.sender].isNodeExist[indexOfNodes] && isNodeActive(indexOfNodes)) {
                activeNodesByAddress[indexOfActiveNodesByAddress] = indexOfNodes;
                indexOfActiveNodesByAddress++;
            }
        }
    }

    /**
     * @dev getActiveNodeIds - get array of indexes of Active Nodes
     * @return activeNodeIds - array of indexes of Active Nodes
     */
    function getActiveNodeIds() external view returns (uint[] memory activeNodeIds) {
        activeNodeIds = new uint[](numberOfActiveNodes);
        uint indexOfActiveNodeIds = 0;
        for (uint indexOfNodes = 0; indexOfNodes < nodes.length; indexOfNodes++) {
            if (isNodeActive(indexOfNodes)) {
                activeNodeIds[indexOfActiveNodeIds] = indexOfNodes;
                indexOfActiveNodeIds++;
            }
        }
    }

    function getNodeStatus(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (NodeStatus)
    {
        return nodes[nodeIndex].status;
    }

    function getValidatorNodeIndexes(uint validatorId) external view returns (uint[] memory) {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(validatorService.validatorExists(validatorId), "Validator with such ID does not exist");
        return validatorToNodeIndexes[validatorId];
    }

    /**
     * @dev constructor in Permissions approach
     * @param contractsAddress needed in Permissions constructor
    */
    function initialize(address contractsAddress) public override initializer {
        Permissions.initialize(contractsAddress);

        numberOfActiveNodes = 0;
        numberOfLeavingNodes = 0;
        numberOfLeftNodes = 0;
    }

    function getValidatorId(uint nodeIndex)
        public
        view
        checkNodeExists(nodeIndex)
        returns (uint)
    {
        return nodes[nodeIndex].validatorId;
    }

    /**
     * @dev isNodeExist - checks existence of Node at this address
     * @param from - account address
     * @param nodeIndex - index of Node
     * @return if exist - true, else - false
     */
    function isNodeExist(address from, uint nodeIndex)
        public
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {
        return nodeIndexes[from].isNodeExist[nodeIndex];
    }

    /**
     * @dev isNodeActive - checks if Node status Active
     * @param nodeIndex - index of Node
     * @return if Node status Active - true, else - false
     */
    function isNodeActive(uint nodeIndex)
        public
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {
        return nodes[nodeIndex].status == NodeStatus.Active;
    }

    /**
     * @dev isNodeLeaving - checks if Node status Leaving
     * @param nodeIndex - index of Node
     * @return if Node status Leaving - true, else - false
     */
    function isNodeLeaving(uint nodeIndex)
        public
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {
        return nodes[nodeIndex].status == NodeStatus.Leaving;
    }

    function countNodesWithFreeSpace(uint8 freeSpace) public view returns (uint count) {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        count = 0;
        uint totalSpace = constantsHolder.TOTAL_SPACE_ON_NODE();
        for (uint8 i = freeSpace; i <= totalSpace; ++i) {
            count = count.add(spaceToNodes[i].length);
        }
    }

    function _findNode(uint[] memory validatorNodeIndexes, uint nodeIndex) private pure returns (uint) {
        uint i;
        for (i = 0; i < validatorNodeIndexes.length; i++) {
            if (validatorNodeIndexes[i] == nodeIndex) {
                return i;
            }
        }
        return validatorNodeIndexes.length;
    }

    function _moveNodeToNewSpaceMap(uint nodeIndex, uint8 newSpace) private {
        uint8 previousSpace = spaceOfNodes[nodeIndex].freeSpace;
        uint indexInArray = spaceOfNodes[nodeIndex].indexInSpaceMap;
        if (indexInArray < spaceToNodes[previousSpace].length.sub(1)) {
            uint shiftedIndex = spaceToNodes[previousSpace][spaceToNodes[previousSpace].length.sub(1)];
            spaceToNodes[previousSpace][indexInArray] = shiftedIndex;
            spaceOfNodes[shiftedIndex].indexInSpaceMap = indexInArray;
            spaceToNodes[previousSpace].pop();
        } else {
            spaceToNodes[previousSpace].pop();
        }
        spaceToNodes[newSpace].push(nodeIndex);
        spaceOfNodes[nodeIndex].freeSpace = newSpace;
        spaceOfNodes[nodeIndex].indexInSpaceMap = spaceToNodes[newSpace].length.sub(1);
    }

    /**
     * @dev _setNodeLeft - set Node Left
     * function could be run only by Nodes
     * @param nodeIndex - index of Node
     */
    function _setNodeLeft(uint nodeIndex) private {
        nodesIPCheck[nodes[nodeIndex].ip] = false;
        nodesNameCheck[keccak256(abi.encodePacked(nodes[nodeIndex].name))] = false;
        delete nodesNameToIndex[keccak256(abi.encodePacked(nodes[nodeIndex].name))];
        if (nodes[nodeIndex].status == NodeStatus.Active) {
            numberOfActiveNodes--;
        } else {
            numberOfLeavingNodes--;
        }
        nodes[nodeIndex].status = NodeStatus.Left;
        numberOfLeftNodes++;
    }

    /**
     * @dev _setNodeLeaving - set Node Leaving
     * function could be run only by Nodes
     * @param nodeIndex - index of Node
     */
    function _setNodeLeaving(uint nodeIndex) private {
        nodes[nodeIndex].status = NodeStatus.Leaving;
        numberOfActiveNodes--;
        numberOfLeavingNodes++;
    }

    /**
     * @dev _addNode - adds Node to array
     * function could be run only by executor
     * @param from - owner of Node
     * @param name - Node name
     * @param ip - Node ip
     * @param publicIP - Node public ip
     * @param port - Node public port
     * @param publicKey - Ethereum public key
     * @return nodeIndex Index of Node
     */
    function _addNode(
        address from,
        string memory name,
        bytes4 ip,
        bytes4 publicIP,
        uint16 port,
        bytes32[2] memory publicKey,
        uint validatorId
    )
        private
        returns (uint nodeIndex)
    {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        nodes.push(Node({
            name: name,
            ip: ip,
            publicIP: publicIP,
            port: port,
            //owner: from,
            publicKey: publicKey,
            startBlock: block.number,
            lastRewardDate: block.timestamp,
            finishTime: 0,
            status: NodeStatus.Active,
            validatorId: validatorId
        }));
        nodeIndex = nodes.length.sub(1);
        validatorToNodeIndexes[validatorId].push(nodeIndex);
        bytes32 nodeId = keccak256(abi.encodePacked(name));
        nodesIPCheck[ip] = true;
        nodesNameCheck[nodeId] = true;
        nodesNameToIndex[nodeId] = nodeIndex;
        nodeIndexes[from].isNodeExist[nodeIndex] = true;
        nodeIndexes[from].numberOfNodes++;
        spaceOfNodes.push(SpaceManaging({
            freeSpace: constantsHolder.TOTAL_SPACE_ON_NODE(),
            indexInSpaceMap: spaceToNodes[constantsHolder.TOTAL_SPACE_ON_NODE()].length
        }));
        spaceToNodes[constantsHolder.TOTAL_SPACE_ON_NODE()].push(nodeIndex);
        numberOfActiveNodes++;
    }

    function _deleteNode(uint nodeIndex) private {
        uint8 space = spaceOfNodes[nodeIndex].freeSpace;
        uint indexInArray = spaceOfNodes[nodeIndex].indexInSpaceMap;
        if (indexInArray < spaceToNodes[space].length.sub(1)) {
            uint shiftedIndex = spaceToNodes[space][spaceToNodes[space].length.sub(1)];
            spaceToNodes[space][indexInArray] = shiftedIndex;
            spaceOfNodes[shiftedIndex].indexInSpaceMap = indexInArray;
            spaceToNodes[space].pop();
        } else {
            spaceToNodes[space].pop();
        }
        delete spaceOfNodes[nodeIndex].freeSpace;
        delete spaceOfNodes[nodeIndex].indexInSpaceMap;
    }

}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    Distributor.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./IERC1820Registry.sol";
import "./IERC777Recipient.sol";
import "./IERC20.sol";

import "./Permissions.sol";
import "./ConstantsHolder.sol";
import "./MathUtils.sol";

import "./ValidatorService.sol";
import "./DelegationController.sol";
import "./DelegationPeriodManager.sol";
import "./TimeHelpers.sol";


contract Distributor is Permissions, IERC777Recipient {
    using MathUtils for uint;

    /**
     * @dev Emitted when a bounty is withdrawn by the token holder.
     */
    event WithdrawBounty(
        address holder,
        uint validatorId,
        address destination,
        uint amount
    );

    /**
     * @dev Emitted when a validator fee is withdrawn by the validator.
     */
    event WithdrawFee(
        uint validatorId,
        address destination,
        uint amount
    );

    /**
     * @dev Emitted when a bounty is distributed.
     */
    event BountyWasPaid(
        uint validatorId,
        uint amount
    );

    IERC1820Registry private _erc1820;

    // validatorId =>        month => token
    mapping (uint => mapping (uint => uint)) private _bountyPaid;
    // validatorId =>        month => token
    mapping (uint => mapping (uint => uint)) private _feePaid;
    //        holder =>   validatorId => month
    mapping (address => mapping (uint => uint)) private _firstUnwithdrawnMonth;
    // validatorId => month
    mapping (uint => uint) private _firstUnwithdrawnMonthForValidator;

    function getAndUpdateEarnedBountyAmount(uint validatorId) external returns (uint earned, uint endMonth) {
        return getAndUpdateEarnedBountyAmountOf(msg.sender, validatorId);
    }

    function withdrawBounty(uint validatorId, address to) external {
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        require(now >= timeHelpers.addMonths(
                constantsHolder.launchTimestamp(),
                constantsHolder.BOUNTY_LOCKUP_MONTHS()
            ), "Bounty is locked");

        uint bounty;
        uint endMonth;
        (bounty, endMonth) = getAndUpdateEarnedBountyAmountOf(msg.sender, validatorId);

        _firstUnwithdrawnMonth[msg.sender][validatorId] = endMonth;

        IERC20 skaleToken = IERC20(contractManager.getContract("SkaleToken"));
        require(skaleToken.transfer(to, bounty), "Failed to transfer tokens");

        emit WithdrawBounty(
            msg.sender,
            validatorId,
            to,
            bounty
        );
    }

    function withdrawFee(address to) external {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        IERC20 skaleToken = IERC20(contractManager.getContract("SkaleToken"));
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        require(now >= timeHelpers.addMonths(
                constantsHolder.launchTimestamp(),
                constantsHolder.BOUNTY_LOCKUP_MONTHS()
            ), "Bounty is locked");
        // check Validator Exist inside getValidatorId
        uint validatorId = validatorService.getValidatorId(msg.sender);

        uint fee;
        uint endMonth;
        (fee, endMonth) = getEarnedFeeAmountOf(validatorId);

        _firstUnwithdrawnMonthForValidator[validatorId] = endMonth;

        require(skaleToken.transfer(to, fee), "Failed to transfer tokens");

        emit WithdrawFee(
            validatorId,
            to,
            fee
        );
    }

    function tokensReceived(
        address,
        address,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata
    )
        external override
        allow("SkaleToken")
    {
        require(to == address(this), "Receiver is incorrect");
        require(userData.length == 32, "Data length is incorrect");
        uint validatorId = abi.decode(userData, (uint));
        _distributeBounty(amount, validatorId);
    }

    function getEarnedFeeAmount() external view returns (uint earned, uint endMonth) {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        return getEarnedFeeAmountOf(validatorService.getValidatorId(msg.sender));
    }

    function initialize(address contractsAddress) public override initializer {
        Permissions.initialize(contractsAddress);
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function getAndUpdateEarnedBountyAmountOf(address wallet, uint validatorId)
        public returns (uint earned, uint endMonth)
    {
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController"));
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));

        uint currentMonth = timeHelpers.getCurrentMonth();

        uint startMonth = _firstUnwithdrawnMonth[wallet][validatorId];
        if (startMonth == 0) {
            startMonth = delegationController.getFirstDelegationMonth(wallet, validatorId);
            if (startMonth == 0) {
                return (0, 0);
            }
        }

        earned = 0;
        endMonth = currentMonth;
        if (endMonth > startMonth.add(12)) {
            endMonth = startMonth.add(12);
        }
        for (uint i = startMonth; i < endMonth; ++i) {
            uint effectiveDelegatedToValidator =
                delegationController.getAndUpdateEffectiveDelegatedToValidator(validatorId, i);
            if (effectiveDelegatedToValidator.muchGreater(0)) {
                earned = earned.add(
                    _bountyPaid[validatorId][i].mul(
                        delegationController.getAndUpdateEffectiveDelegatedByHolderToValidator(wallet, validatorId, i))
                            .div(effectiveDelegatedToValidator)
                    );
            }
        }
    }

    function getEarnedFeeAmountOf(uint validatorId) public view returns (uint earned, uint endMonth) {
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));

        uint currentMonth = timeHelpers.getCurrentMonth();

        uint startMonth = _firstUnwithdrawnMonthForValidator[validatorId];
        if (startMonth == 0) {
            return (0, 0);
        }

        earned = 0;
        endMonth = currentMonth;
        if (endMonth > startMonth.add(12)) {
            endMonth = startMonth.add(12);
        }
        for (uint i = startMonth; i < endMonth; ++i) {
            earned = earned.add(_feePaid[validatorId][i]);
        }
    }

    // private

    function _distributeBounty(uint amount, uint validatorId) private {
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));

        uint currentMonth = timeHelpers.getCurrentMonth();
        uint feeRate = validatorService.getValidator(validatorId).feeRate;

        uint fee = amount.mul(feeRate).div(1000);
        uint bounty = amount.sub(fee);
        _bountyPaid[validatorId][currentMonth] = _bountyPaid[validatorId][currentMonth].add(bounty);
        _feePaid[validatorId][currentMonth] = _feePaid[validatorId][currentMonth].add(fee);

        if (_firstUnwithdrawnMonthForValidator[validatorId] == 0) {
            _firstUnwithdrawnMonthForValidator[validatorId] = currentMonth;
        }

        emit BountyWasPaid(validatorId, amount);
    }
}

pragma solidity ^0.6.0;


/**
 * @dev Wrappers over Solidity's uintXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and then downcasting.
 */
library SafeCast {

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    StringUtils.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Vadim Yavorsky

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./SafeMath.sol";


library StringUtils {
    using SafeMath for uint;

    function strConcat(string memory a, string memory b) internal pure returns (string memory) {
        bytes memory _ba = bytes(a);
        bytes memory _bb = bytes(b);

        string memory ab = new string(_ba.length.add(_bb.length));
        bytes memory strBytes = bytes(ab);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            strBytes[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            strBytes[k++] = _bb[i];
        }
        return string(strBytes);
    }

    function uint2str(uint i) internal pure returns (string memory) {
        if (i == 0) {
            return "0";
        }
        uint j = i;
        uint _i = i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len.sub(1);
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    TimeHelpers.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./SafeMath.sol";

import "./BokkyPooBahsDateTimeLibrary.sol";

/**
 * @title TimeHelpers
 * @dev The contract performs time operations.
 *
 * These functions are used to calculate monthly and Proof of Use epochs.
 */
contract TimeHelpers {
    using SafeMath for uint;

    uint constant private _ZERO_YEAR = 2020;

    function calculateProofOfUseLockEndTime(uint month, uint lockUpPeriodDays) external view returns (uint timestamp) {
        timestamp = BokkyPooBahsDateTimeLibrary.addDays(monthToTimestamp(month), lockUpPeriodDays);
    }

    function addDays(uint fromTimestamp, uint n) external pure returns (uint) {
        return BokkyPooBahsDateTimeLibrary.addDays(fromTimestamp, n);
    }

    function addMonths(uint fromTimestamp, uint n) external pure returns (uint) {
        return BokkyPooBahsDateTimeLibrary.addMonths(fromTimestamp, n);
    }

    function addYears(uint fromTimestamp, uint n) external pure returns (uint) {
        return BokkyPooBahsDateTimeLibrary.addYears(fromTimestamp, n);
    }

    function getCurrentMonth() external view virtual returns (uint) {
        return timestampToMonth(now);
    }

    function timestampToDay(uint timestamp) external view returns (uint) {
        uint wholeDays = timestamp / BokkyPooBahsDateTimeLibrary.SECONDS_PER_DAY;
        uint zeroDay = BokkyPooBahsDateTimeLibrary.timestampFromDate(_ZERO_YEAR, 1, 1) /
            BokkyPooBahsDateTimeLibrary.SECONDS_PER_DAY;
        require(wholeDays >= zeroDay, "Timestamp is too far in the past");
        return wholeDays - zeroDay;
    }

    function timestampToYear(uint timestamp) external view virtual returns (uint) {
        uint year;
        (year, , ) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        require(year >= _ZERO_YEAR, "Timestamp is too far in the past");
        return year - _ZERO_YEAR;
    }

    function timestampToMonth(uint timestamp) public view virtual returns (uint) {
        uint year;
        uint month;
        (year, month, ) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        require(year >= _ZERO_YEAR, "Timestamp is too far in the past");
        month = month.sub(1).add(year.sub(_ZERO_YEAR).mul(12));
        require(month > 0, "Timestamp is too far in the past");
        return month;
    }

    function monthToTimestamp(uint month) public view virtual returns (uint timestamp) {
        uint year = _ZERO_YEAR;
        uint _month = month;
        year = year.add(_month.div(12));
        _month = _month.mod(12);
        _month = _month.add(1);
        return BokkyPooBahsDateTimeLibrary.timestampFromDate(year, _month, 1);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    SchainsInternal.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./ConstantsHolder.sol";
import "./Nodes.sol";
import "./ISkaleDKG.sol";

/**
 * @title SchainsInternal - contract contains all functionality logic to manage Schains
 */
contract SchainsInternal is Permissions {

    struct Schain {
        string name;
        address owner;
        uint indexInOwnerList;
        uint8 partOfNode;
        uint lifetime;
        uint startDate;
        uint startBlock;
        uint deposit;
        uint64 index;
    }


    // mapping which contain all schains
    mapping (bytes32 => Schain) public schains;

    mapping (bytes32 => bool) public isSchainActive;

    mapping (bytes32 => uint[]) public schainsGroups;

    mapping (bytes32 => mapping (uint => bool)) private _exceptionsForGroups;
    // mapping shows schains by owner's address
    mapping (address => bytes32[]) public schainIndexes;
    // mapping shows schains which Node composed in
    mapping (uint => bytes32[]) public schainsForNodes;

    mapping (uint => uint[]) public holesForNodes;

    mapping (bytes32 => uint[]) public holesForSchains;


    // array which contain all schains
    bytes32[] public schainsAtSystem;

    uint64 public numberOfSchains;
    // total resources that schains occupied
    uint public sumOfSchainsResources;

    mapping (bytes32 => bool) public usedSchainNames;

    /**
     * @dev initializeSchain - initializes Schain
     * function could be run only by executor
     * @param name - SChain name
     * @param from - Schain owner
     * @param lifetime - initial lifetime of Schain
     * @param deposit - given amount of SKL
     */
    function initializeSchain(
        string calldata name,
        address from,
        uint lifetime,
        uint deposit) external allow("Schains")
    {
        bytes32 schainId = keccak256(abi.encodePacked(name));
        schains[schainId].name = name;
        schains[schainId].owner = from;
        schains[schainId].startDate = block.timestamp;
        schains[schainId].startBlock = block.number;
        schains[schainId].lifetime = lifetime;
        schains[schainId].deposit = deposit;
        schains[schainId].index = numberOfSchains;
        isSchainActive[schainId] = true;
        numberOfSchains++;
        schainsAtSystem.push(schainId);
        usedSchainNames[schainId] = true;
    }

    function createGroupForSchain(
        bytes32 schainId,
        uint numberOfNodes,
        uint8 partOfNode
    )
        external
        allow("Schains")
        returns (uint[] memory)
    {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        schains[schainId].partOfNode = partOfNode;
        if (partOfNode > 0) {
            sumOfSchainsResources = sumOfSchainsResources.add(
                numberOfNodes.mul(constantsHolder.TOTAL_SPACE_ON_NODE()).div(partOfNode)
            );
        }
        return _generateGroup(schainId, numberOfNodes);
    }

    /**
     * @dev setSchainIndex - adds Schain's hash to owner
     * function could be run only by executor
     * @param schainId - hash by Schain name
     * @param from - Schain owner
     */
    function setSchainIndex(bytes32 schainId, address from) external allow("Schains") {
        schains[schainId].indexInOwnerList = schainIndexes[from].length;
        schainIndexes[from].push(schainId);
    }

    /**
     * @dev changeLifetime - changes Lifetime for Schain
     * function could be run only by executor
     * @param schainId - hash by Schain name
     * @param lifetime - time which would be added to lifetime of Schain
     * @param deposit - amount of SKL which payed for this time
     */
    function changeLifetime(bytes32 schainId, uint lifetime, uint deposit) external allow("Schains") {
        schains[schainId].deposit = schains[schainId].deposit.add(deposit);
        schains[schainId].lifetime = schains[schainId].lifetime.add(lifetime);
    }

    /**
     * @dev removeSchain - removes Schain from the system
     * function could be run only by executor
     * @param schainId - hash by Schain name
     * @param from - owner of Schain
     */
    function removeSchain(bytes32 schainId, address from) external allow("Schains") {
        isSchainActive[schainId] = false;
        uint length = schainIndexes[from].length;
        uint index = schains[schainId].indexInOwnerList;
        if (index != length.sub(1)) {
            bytes32 lastSchainId = schainIndexes[from][length.sub(1)];
            schains[lastSchainId].indexInOwnerList = index;
            schainIndexes[from][index] = lastSchainId;
        }
        schainIndexes[from].pop();

        // TODO:
        // optimize
        for (uint i = 0; i + 1 < schainsAtSystem.length; i++) {
            if (schainsAtSystem[i] == schainId) {
                schainsAtSystem[i] = schainsAtSystem[schainsAtSystem.length.sub(1)];
                break;
            }
        }
        schainsAtSystem.pop();

        delete schains[schainId];
        numberOfSchains--;
    }

    function removeNodeFromSchain(
        uint nodeIndex,
        bytes32 schainHash
    )
        external
        allowThree("NodeRotation", "SkaleDKG", "Schains")
    {
        uint indexOfNode = _findNode(schainHash, nodeIndex);
        uint indexOfLastNode = schainsGroups[schainHash].length.sub(1);

        if (indexOfNode == indexOfLastNode) {
            schainsGroups[schainHash].pop();
        } else {
            delete schainsGroups[schainHash][indexOfNode];
            if (holesForSchains[schainHash].length > 0 && holesForSchains[schainHash][0] > indexOfNode) {
                uint hole = holesForSchains[schainHash][0];
                holesForSchains[schainHash][0] = indexOfNode;
                holesForSchains[schainHash].push(hole);
            } else {
                holesForSchains[schainHash].push(indexOfNode);
            }
        }

        uint schainId = findSchainAtSchainsForNode(nodeIndex, schainHash);
        removeSchainForNode(nodeIndex, schainId);
    }

    function removeNodeFromExceptions(bytes32 schainHash, uint nodeIndex) external allow("Schains") {
        _exceptionsForGroups[schainHash][nodeIndex] = false;
    }

    /**
     * @dev deleteGroup - delete Group from Data contract
     * function could be run only by executor
     * @param schainId - Groups identifier
     */
    function deleteGroup(bytes32 schainId) external allow("Schains") {
        // delete channel
        ISkaleDKG skaleDKG = ISkaleDKG(contractManager.getContract("SkaleDKG"));

        delete schainsGroups[schainId];
        if (skaleDKG.isChannelOpened(schainId)) {
            skaleDKG.deleteChannel(schainId);
        }
    }

    /**
     * @dev setException - sets a Node like exception
     * function could be run only by executor
     * @param schainId - Groups identifier
     * @param nodeIndex - index of Node which would be notes like exception
     */
    function setException(bytes32 schainId, uint nodeIndex) external allowTwo("Schains", "NodeRotation") {
        _exceptionsForGroups[schainId][nodeIndex] = true;
    }

    /**
     * @dev setNodeInGroup - adds Node to Group
     * function could be run only by executor
     * @param schainId - Groups
     * @param nodeIndex - index of Node which would be added to the Group
     */
    function setNodeInGroup(bytes32 schainId, uint nodeIndex) external allowTwo("Schains", "NodeRotation") {
        if (holesForSchains[schainId].length == 0) {
            schainsGroups[schainId].push(nodeIndex);
        } else {
            schainsGroups[schainId][holesForSchains[schainId][0]] = nodeIndex;
            uint min = uint(-1);
            uint index = 0;
            for (uint i = 1; i < holesForSchains[schainId].length; i++) {
                if (min > holesForSchains[schainId][i]) {
                    min = holesForSchains[schainId][i];
                    index = i;
                }
            }
            if (min == uint(-1)) {
                delete holesForSchains[schainId];
            } else {
                holesForSchains[schainId][0] = min;
                holesForSchains[schainId][index] =
                    holesForSchains[schainId][holesForSchains[schainId].length - 1];
                holesForSchains[schainId].pop();
            }
        }
    }

    function removeHolesForSchain(bytes32 schainHash) external allow("Schains") {
        delete holesForSchains[schainHash];
    }

    /**
     * @dev getSchains - gets all Schains at the system
     * @return array of hashes by Schain names
     */
    function getSchains() external view returns (bytes32[] memory) {
        return schainsAtSystem;
    }

    /**
     * @dev getSchainsPartOfNode - gets occupied space for given Schain
     * @param schainId - hash by Schain name
     * @return occupied space
     */
    function getSchainsPartOfNode(bytes32 schainId) external view returns (uint8) {
        return schains[schainId].partOfNode;
    }

    /**
     * @dev getSchainListSize - gets number of created Schains at the system by owner
     * @param from - owner of Schain
     * return number of Schains
     */
    function getSchainListSize(address from) external view returns (uint) {
        return schainIndexes[from].length;
    }

    /**
     * @dev getSchainIdsByAddress - gets array of hashes by Schain names which owned by `from`
     * @param from - owner of some Schains
     * @return array of hashes by Schain names
     */
    function getSchainIdsByAddress(address from) external view returns (bytes32[] memory) {
        return schainIndexes[from];
    }

    /**
     * @dev getSchainIdsForNode - returns array of hashes by Schain names,
     * which given Node composed
     * @param nodeIndex - index of Node
     * @return array of hashes by Schain names
     */
    function getSchainIdsForNode(uint nodeIndex) external view returns (bytes32[] memory) {
        return schainsForNodes[nodeIndex];
    }

    function getSchainOwner(bytes32 schainId) external view returns (address) {
        return schains[schainId].owner;
    }

    /**
     * @dev isSchainNameAvailable - checks is given name available
     * Need to delete - copy of web3.utils.soliditySha3
     * @param name - possible new name of Schain
     * @return if available - true, else - false
     */
    function isSchainNameAvailable(string calldata name) external view returns (bool) {
        bytes32 schainId = keccak256(abi.encodePacked(name));
        return schains[schainId].owner == address(0) && !usedSchainNames[schainId];
    }

    /**
     * @dev isTimeExpired - checks is Schain lifetime expired
     * @param schainId - hash by Schain name
     * @return if expired - true, else - false
     */
    function isTimeExpired(bytes32 schainId) external view returns (bool) {
        return uint(schains[schainId].startDate).add(schains[schainId].lifetime) < block.timestamp;
    }

    /**
     * @dev isOwnerAddress - checks is `from` - owner of `schainId` Schain
     * @param from - owner of Schain
     * @param schainId - hash by Schain name
     * @return if owner - true, else - false
     */
    function isOwnerAddress(address from, bytes32 schainId) external view returns (bool) {
        return schains[schainId].owner == from;
    }

    function isSchainExist(bytes32 schainId) external view returns (bool) {
        return keccak256(abi.encodePacked(schains[schainId].name)) != keccak256(abi.encodePacked(""));
    }

    function getSchainName(bytes32 schainId) external view returns (string memory) {
        return schains[schainId].name;
    }

    function getActiveSchain(uint nodeIndex) external view returns (bytes32) {
        for (uint i = schainsForNodes[nodeIndex].length; i > 0; i--) {
            if (schainsForNodes[nodeIndex][i - 1] != bytes32(0)) {
                return schainsForNodes[nodeIndex][i - 1];
            }
        }
        return bytes32(0);
    }

    function getActiveSchains(uint nodeIndex) external view returns (bytes32[] memory activeSchains) {
        uint activeAmount = 0;
        for (uint i = 0; i < schainsForNodes[nodeIndex].length; i++) {
            if (schainsForNodes[nodeIndex][i] != bytes32(0)) {
                activeAmount++;
            }
        }

        uint cursor = 0;
        activeSchains = new bytes32[](activeAmount);
        for (uint i = schainsForNodes[nodeIndex].length; i > 0; i--) {
            if (schainsForNodes[nodeIndex][i - 1] != bytes32(0)) {
                activeSchains[cursor++] = schainsForNodes[nodeIndex][i - 1];
            }
        }
    }

    /**
     * @dev getNumberOfNodesInGroup - shows number of Nodes in Group
     * @param schainId - Groups identifier
     * @return number of Nodes in Group
     */
    function getNumberOfNodesInGroup(bytes32 schainId) external view returns (uint) {
        return schainsGroups[schainId].length;
    }

    /**
     * @dev getNodesInGroup - shows Nodes in Group
     * @param schainId - Groups identifier
     * @return array of indexes of Nodes in Group
     */
    function getNodesInGroup(bytes32 schainId) external view returns (uint[] memory) {
        return schainsGroups[schainId];
    }

    /**
     * @dev getNodeIndexInGroup - looks for Node in Group
     * @param schainId - Groups identifier
     * @param nodeId - Nodes identifier
     * @return index of Node in Group
     */
    function getNodeIndexInGroup(bytes32 schainId, uint nodeId) external view returns (uint) {
        for (uint index = 0; index < schainsGroups[schainId].length; index++) {
            if (schainsGroups[schainId][index] == nodeId) {
                return index;
            }
        }
        return schainsGroups[schainId].length;
    }

    function isAnyFreeNode(bytes32 schainId) external view returns (bool) {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint8 space = schains[schainId].partOfNode;
        uint[] memory nodesWithFreeSpace = nodes.getNodesWithFreeSpace(space);
        for (uint i = 0; i < nodesWithFreeSpace.length; i++) {
            if (_isCorrespond(schainId, nodesWithFreeSpace[i])) {
                return true;
            }
        }
        return false;
    }

    function checkException(bytes32 schainId, uint nodeIndex) external view returns (bool) {
        return _exceptionsForGroups[schainId][nodeIndex];
    }

    function checkHoleForSchain(bytes32 schainHash, uint indexOfNode) external view returns (bool) {
        for (uint i = 0; i < holesForSchains[schainHash].length; i++) {
            if (holesForSchains[schainHash][i] == indexOfNode) {
                return true;
            }
        }
        return false;
    }

    function initialize(address newContractsAddress) public override initializer {
        Permissions.initialize(newContractsAddress);

        numberOfSchains = 0;
        sumOfSchainsResources = 0;
    }

    /**
     * @dev addSchainForNode - adds Schain hash to Node
     * function could be run only by executor
     * @param nodeIndex - index of Node
     * @param schainId - hash by Schain name
     */
    function addSchainForNode(uint nodeIndex, bytes32 schainId) public allowTwo("Schains", "NodeRotation") {
        if (holesForNodes[nodeIndex].length == 0) {
            schainsForNodes[nodeIndex].push(schainId);
        } else {
            schainsForNodes[nodeIndex][holesForNodes[nodeIndex][0]] = schainId;
            uint min = uint(-1);
            uint index = 0;
            for (uint i = 1; i < holesForNodes[nodeIndex].length; i++) {
                if (min > holesForNodes[nodeIndex][i]) {
                    min = holesForNodes[nodeIndex][i];
                    index = i;
                }
            }
            if (min == uint(-1)) {
                delete holesForNodes[nodeIndex];
            } else {
                holesForNodes[nodeIndex][0] = min;
                holesForNodes[nodeIndex][index] = holesForNodes[nodeIndex][holesForNodes[nodeIndex].length - 1];
                holesForNodes[nodeIndex].pop();
            }
        }
    }

    /**
     * @dev removesSchainForNode - clean given Node of Schain
     * function could be run only by executor
     * @param nodeIndex - index of Node
     * @param schainIndex - index of Schain in schainsForNodes array by this Node
     */
    function removeSchainForNode(uint nodeIndex, uint schainIndex)
        public
        allowThree("NodeRotation", "SkaleDKG", "Schains")
    {
        uint length = schainsForNodes[nodeIndex].length;
        if (schainIndex == length.sub(1)) {
            schainsForNodes[nodeIndex].pop();
        } else {
            schainsForNodes[nodeIndex][schainIndex] = bytes32(0);
            if (holesForNodes[nodeIndex].length > 0 && holesForNodes[nodeIndex][0] > schainIndex) {
                uint hole = holesForNodes[nodeIndex][0];
                holesForNodes[nodeIndex][0] = schainIndex;
                holesForNodes[nodeIndex].push(hole);
            } else {
                holesForNodes[nodeIndex].push(schainIndex);
            }
        }
    }

    /**
     * @dev getLengthOfSchainsForNode - returns number of Schains which contain given Node
     * @param nodeIndex - index of Node
     * @return number of Schains
     */
    function getLengthOfSchainsForNode(uint nodeIndex) public view returns (uint) {
        return schainsForNodes[nodeIndex].length;
    }

    /**
     * @dev findSchainAtSchainsForNode - finds index of Schain at schainsForNode array
     * @param nodeIndex - index of Node at common array of Nodes
     * @param schainId - hash of name of Schain
     * @return index of Schain at schainsForNode array
     */
    function findSchainAtSchainsForNode(uint nodeIndex, bytes32 schainId) public view returns (uint) {
        uint length = getLengthOfSchainsForNode(nodeIndex);
        for (uint i = 0; i < length; i++) {
            if (schainsForNodes[nodeIndex][i] == schainId) {
                return i;
            }
        }
        return length;
    }

    function isEnoughNodes(bytes32 schainId) public view returns (uint[] memory result) {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint8 space = schains[schainId].partOfNode;
        uint[] memory nodesWithFreeSpace = nodes.getNodesWithFreeSpace(space);
        uint counter = 0;
        for (uint i = 0; i < nodesWithFreeSpace.length; i++) {
            if (!_isCorrespond(schainId, nodesWithFreeSpace[i])) {
                counter++;
            }
        }
        if (counter < nodesWithFreeSpace.length) {
            result = new uint[](nodesWithFreeSpace.length.sub(counter));
            counter = 0;
            for (uint i = 0; i < nodesWithFreeSpace.length; i++) {
                if (_isCorrespond(schainId, nodesWithFreeSpace[i])) {
                    result[counter] = nodesWithFreeSpace[i];
                    counter++;
                }
            }
        }
    }

    /**
     * @dev _generateGroup - generates Group for Schain
     * @param schainId - index of Group
     */
    function _generateGroup(bytes32 schainId, uint numberOfNodes) private returns (uint[] memory nodesInGroup) {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint8 space = schains[schainId].partOfNode;
        nodesInGroup = new uint[](numberOfNodes);

        uint[] memory possibleNodes = isEnoughNodes(schainId);
        require(possibleNodes.length >= nodesInGroup.length, "Not enough nodes to create Schain");
        uint ignoringTail = 0;
        uint random = uint(keccak256(abi.encodePacked(uint(blockhash(block.number.sub(1))), schainId)));
        for (uint i = 0; i < nodesInGroup.length; ++i) {
            uint index = random % (possibleNodes.length.sub(ignoringTail));
            uint node = possibleNodes[index];
            nodesInGroup[i] = node;
            _swap(possibleNodes, index, possibleNodes.length.sub(ignoringTail).sub(1));
            ++ignoringTail;

            _exceptionsForGroups[schainId][node] = true;
            addSchainForNode(node, schainId);
            require(nodes.removeSpaceFromNode(node, space), "Could not remove space from Node");
        }

        // set generated group
        schainsGroups[schainId] = nodesInGroup;
    }

    function _isCorrespond(bytes32 schainId, uint nodeIndex) private view returns (bool) {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        return !_exceptionsForGroups[schainId][nodeIndex] && nodes.isNodeActive(nodeIndex);
    }

    function _swap(uint[] memory array, uint index1, uint index2) private pure {
        uint buffer = array[index1];
        array[index1] = array[index2];
        array[index2] = buffer;
    }

    /**
     * @dev findNode - find local index of Node in Schain
     * @param schainId - Groups identifier
     * @param nodeIndex - global index of Node
     * @return local index of Node in Schain
     */
    function _findNode(bytes32 schainId, uint nodeIndex) private view returns (uint) {
        uint[] memory nodesInGroup = schainsGroups[schainId];
        uint index;
        for (index = 0; index < nodesInGroup.length; index++) {
            if (nodesInGroup[index] == nodeIndex) {
                return index;
            }
        }
        return index;
    }

}

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.6.0;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        uint year;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        uint year;
        uint month;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function send(address recipient, uint256 amount, bytes calldata data) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See {operatorSend} and {operatorBurn}.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See {isOperatorFor}.
     *
     * Emits an {AuthorizedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Revoke an account's operator status for the caller.
     *
     * See {isOperatorFor} and {defaultOperators}.
     *
     * Emits a {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if {authorizeOperator} was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * {revokeOperator}, in which case {isOperatorFor} will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    FieldOperations.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs

    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./SafeMath.sol";

import "./Precompiled.sol";


library Fp2Operations {
    using SafeMath for uint;

    struct Fp2Point {
        uint a;
        uint b;
    }

    uint constant public P = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    function addFp2(Fp2Point memory value1, Fp2Point memory value2) internal pure returns (Fp2Point memory) {
        return Fp2Point({ a: addmod(value1.a, value2.a, P), b: addmod(value1.b, value2.b, P) });
    }

    function scalarMulFp2(Fp2Point memory value, uint scalar) internal pure returns (Fp2Point memory) {
        return Fp2Point({ a: mulmod(scalar, value.a, P), b: mulmod(scalar, value.b, P) });
    }

    function minusFp2(Fp2Point memory diminished, Fp2Point memory subtracted) internal pure
        returns (Fp2Point memory difference)
    {
        uint p = P;
        if (diminished.a >= subtracted.a) {
            difference.a = addmod(diminished.a, p - (subtracted.a), p);
        } else {
            difference.a = p - (addmod(subtracted.a, p - (diminished.a), p));
        }
        if (diminished.b >= subtracted.b) {
            difference.b = addmod(diminished.b, p - (subtracted.b), p);
        } else {
            difference.b = p - (addmod(subtracted.b, p - (diminished.b), p));
        }
    }

    function mulFp2(
        Fp2Point memory value1,
        Fp2Point memory value2
    )
        internal
        pure
        returns (Fp2Point memory result)
    {
        uint p = P;
        Fp2Point memory point = Fp2Point({
            a: mulmod(value1.a, value2.a, p),
            b: mulmod(value1.b, value2.b, p)});
        result.a = addmod(
            point.a,
            mulmod(p - 1, point.b, p),
            p);
        result.b = addmod(
            mulmod(
                addmod(value1.a, value1.b, p),
                addmod(value2.a, value2.b, p),
                p),
            p - addmod(point.a, point.b, p),
            p);
    }

    function squaredFp2(Fp2Point memory value) internal pure returns (Fp2Point memory) {
        uint p = P;
        uint ab = mulmod(value.a, value.b, p);
        uint mult = mulmod(addmod(value.a, value.b, p), addmod(value.a, mulmod(p - 1, value.b, p), p), p);
        return Fp2Point({ a: mult, b: addmod(ab, ab, p) });
    }

    function inverseFp2(Fp2Point memory value) internal view returns (Fp2Point memory result) {
        uint p = P;
        uint t0 = mulmod(value.a, value.a, p);
        uint t1 = mulmod(value.b, value.b, p);
        uint t2 = mulmod(p - 1, t1, p);
        if (t0 >= t2) {
            t2 = addmod(t0, p - t2, p);
        } else {
            t2 = p - addmod(t2, p - t0, p);
        }
        uint t3 = Precompiled.bigModExp(t2, p - 2, p);
        result.a = mulmod(value.a, t3, p);
        result.b = p - mulmod(value.b, t3, p);
    }

    function isEqual(
        Fp2Point memory value1,
        Fp2Point memory value2
    )
        internal
        pure
        returns (bool)
    {
        return value1.a == value2.a && value1.b == value2.b;
    }
}


library G2Operations {
    using SafeMath for uint;
    using Fp2Operations for Fp2Operations.Fp2Point;

    struct G2Point {
        Fp2Operations.Fp2Point x;
        Fp2Operations.Fp2Point y;
    }

    function getTWISTB() internal pure returns (Fp2Operations.Fp2Point memory) {
        // Current solidity version does not support Constants of non-value type
        // so we implemented this function
        return Fp2Operations.Fp2Point({
            a: 19485874751759354771024239261021720505790618469301721065564631296452457478373,
            b: 266929791119991161246907387137283842545076965332900288569378510910307636690
        });
    }

    function getG2() internal pure returns (G2Point memory) {
        // Current solidity version does not support Constants of non-value type
        // so we implemented this function
        return G2Point({
            x: Fp2Operations.Fp2Point({
                a: 10857046999023057135944570762232829481370756359578518086990519993285655852781,
                b: 11559732032986387107991004021392285783925812861821192530917403151452391805634
            }),
            y: Fp2Operations.Fp2Point({
                a: 8495653923123431417604973247489272438418190587263600148770280649306958101930,
                b: 4082367875863433681332203403145435568316851327593401208105741076214120093531
            })
        });
    }

    function getG1() internal pure returns (Fp2Operations.Fp2Point memory) {
        // Current solidity version does not support Constants of non-value type
        // so we implemented this function
        return Fp2Operations.Fp2Point({
            a: 1,
            b: 2
        });
    }

    function getG2Zero() internal pure returns (G2Point memory) {
        // Current solidity version does not support Constants of non-value type
        // so we implemented this function
        return G2Point({
            x: Fp2Operations.Fp2Point({
                a: 0,
                b: 0
            }),
            y: Fp2Operations.Fp2Point({
                a: 1,
                b: 0
            })
        });
    }

    function isG1Point(uint x, uint y) internal pure returns (bool) {
        uint p = Fp2Operations.P;
        return mulmod(y, y, p) == 
            addmod(mulmod(mulmod(x, x, p), x, p), 3, p);
    }
    function isG1(Fp2Operations.Fp2Point memory point) internal pure returns (bool) {
        return isG1Point(point.a, point.b);
    }

    function isG2Point(Fp2Operations.Fp2Point memory x, Fp2Operations.Fp2Point memory y) internal pure returns (bool) {
        if (isG2ZeroPoint(x, y)) {
            return true;
        }
        Fp2Operations.Fp2Point memory squaredY = y.squaredFp2();
        Fp2Operations.Fp2Point memory res = squaredY.minusFp2(
                x.squaredFp2().mulFp2(x)
            ).minusFp2(getTWISTB());
        return res.a == 0 && res.b == 0;
    }

    function isG2(G2Point memory value) internal pure returns (bool) {
        return isG2Point(value.x, value.y);
    }

    function isG2ZeroPoint(
        Fp2Operations.Fp2Point memory x,
        Fp2Operations.Fp2Point memory y
    )
        internal
        pure
        returns (bool)
    {
        return x.a == 0 && x.b == 0 && y.a == 1 && y.b == 0;
    }

    function isG2Zero(G2Point memory value) internal pure returns (bool) {
        return value.x.a == 0 && value.x.b == 0 && value.y.a == 1 && value.y.b == 0;
        // return isG2ZeroPoint(value.x, value.y);
    }

    function addG2(
        G2Point memory value1,
        G2Point memory value2
    )
        internal
        view
        returns (G2Point memory sum)
    {
        if (isG2Zero(value1)) {
            return value2;
        }
        if (isG2Zero(value2)) {
            return value1;
        }
        if (isEqual(value1, value2)) {
            return doubleG2(value1);
        }

        Fp2Operations.Fp2Point memory s = value2.y.minusFp2(value1.y).mulFp2(value2.x.minusFp2(value1.x).inverseFp2());
        sum.x = s.squaredFp2().minusFp2(value1.x.addFp2(value2.x));
        sum.y = value1.y.addFp2(s.mulFp2(sum.x.minusFp2(value1.x)));
        uint p = Fp2Operations.P;
        sum.y.a = p - sum.y.a;
        sum.y.b = p - sum.y.b;
    }

    function toUS(G2Point memory value) internal pure returns (G2Point memory) {
        return G2Point({
            x: value.x.mulFp2(Fp2Operations.Fp2Point({ a: 1, b: 0 }).squaredFp2()),
            y: value.y.mulFp2(
                Fp2Operations.Fp2Point({ a: 1, b: 0 }).mulFp2(Fp2Operations.Fp2Point({ a: 1, b: 0 }).squaredFp2())
            )
        });
    }

    function isEqual(
        G2Point memory value1,
        G2Point memory value2
    )
        internal
        pure
        returns (bool)
    {
        return value1.x.isEqual(value2.x) && value1.y.isEqual(value2.y);
    }

    function doubleG2(G2Point memory value)
        internal
        view
        returns (G2Point memory result)
    {
        if (isG2Zero(value)) {
            return value;
        } else {
            Fp2Operations.Fp2Point memory s =
                value.x.squaredFp2().scalarMulFp2(3).mulFp2(value.y.scalarMulFp2(2).inverseFp2());
            result.x = s.squaredFp2().minusFp2(value.x.addFp2(value.x));
            result.y = value.y.addFp2(s.mulFp2(result.x.minusFp2(value.x)));
            uint p = Fp2Operations.P;
            result.y.a = p - result.y.a;
            result.y.b = p - result.y.b;
        }
    }

    function mulG2(
        G2Point memory value,
        uint scalar
    )
        internal
        view
        returns (G2Point memory result)
    {
        uint step = scalar;
        result = G2Point({
            x: Fp2Operations.Fp2Point({
                a: 0,
                b: 0
            }),
            y: Fp2Operations.Fp2Point({
                a: 1,
                b: 0
            })
        });
        G2Point memory tmp = value;
        uint gs = gasleft();
        while (step > 0) {
            if (step % 2 == 1) {
                result = addG2(result, tmp);
            }
            gs = gasleft();
            tmp = doubleG2(tmp);
            step >>= 1;
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    TokenLaunchLocker.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./Permissions.sol";
import "./ILocker.sol";
import "./ConstantsHolder.sol";
import "./MathUtils.sol";

import "./DelegationController.sol";
import "./TimeHelpers.sol";
import "./PartialDifferences.sol";


contract TokenLaunchLocker is Permissions, ILocker {
    using MathUtils for uint;
    using PartialDifferences for PartialDifferences.Value;

    /**
     * @dev Emitted when an `amount` is unlocked.
     */
    event Unlocked(
        address holder,
        uint amount
    );

    /**
     * @dev Emitted when an `amount` is locked.
     */
    event Locked(
        address holder,
        uint amount
    );

    struct DelegatedAmountAndMonth {
        uint delegated;
        uint month;
    }

    //        holder => tokens
    mapping (address => uint) private _locked;

    //        holder => tokens
    mapping (address => PartialDifferences.Value) private _delegatedAmount;

    mapping (address => DelegatedAmountAndMonth) private _totalDelegatedAmount;

    // delegationId => tokens
    mapping (uint => uint) private _delegationAmount;

    function lock(address holder, uint amount) external allow("TokenLaunchManager") {
        _locked[holder] = _locked[holder].add(amount);

        emit Locked(holder, amount);
    }

    function handleDelegationAdd(
        address holder, uint delegationId, uint amount, uint month)
        external allow("DelegationController")
    {
        if (_locked[holder] > 0) {
            TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));

            uint currentMonth = timeHelpers.getCurrentMonth();
            uint fromLocked = amount;
            uint locked = _locked[holder].boundedSub(_getAndUpdateDelegatedAmount(holder, currentMonth));
            if (fromLocked > locked) {
                fromLocked = locked;
            }
            if (fromLocked > 0) {
                require(_delegationAmount[delegationId] == 0, "Delegation was already added");
                _addToDelegatedAmount(holder, fromLocked, month);
                _addToTotalDelegatedAmount(holder, fromLocked, month);
                _delegationAmount[delegationId] = fromLocked;
            }
        }
    }

    function handleDelegationRemoving(
        address holder,
        uint delegationId,
        uint month)
        external allow("DelegationController")
    {
        if (_delegationAmount[delegationId] > 0) {
            if (_locked[holder] > 0) {
                _removeFromDelegatedAmount(holder, _delegationAmount[delegationId], month);
            }
            delete _delegationAmount[delegationId];
        }
    }

    function getAndUpdateLockedAmount(address wallet) external override returns (uint) {
        if (_locked[wallet] > 0) {
            DelegationController delegationController = DelegationController(
                contractManager.getContract("DelegationController"));
            TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
            ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

            uint currentMonth = timeHelpers.getCurrentMonth();
            if (_totalDelegatedSatisfiesProofOfUserCondition(wallet) &&
                timeHelpers.calculateProofOfUseLockEndTime(
                    _totalDelegatedAmount[wallet].month,
                    constantsHolder.proofOfUseLockUpPeriodDays()
                ) <= now) {
                _unlock(wallet);
                return 0;
            } else {
                uint lockedByDelegationController = _getAndUpdateDelegatedAmount(wallet, currentMonth)
                    .add(delegationController.getLockedInPendingDelegations(wallet));
                if (_locked[wallet] > lockedByDelegationController) {
                    return _locked[wallet].boundedSub(lockedByDelegationController);
                } else {
                    return 0;
                }
            }
        } else {
            return 0;
        }
    }

    function getAndUpdateForbiddenForDelegationAmount(address) external override returns (uint) {
        return 0;
    }

    function initialize(address contractManagerAddress) public override initializer {
        Permissions.initialize(contractManagerAddress);
    }

    // private

    function _getAndUpdateDelegatedAmount(address holder, uint currentMonth) private returns (uint) {
        return _delegatedAmount[holder].getAndUpdateValue(currentMonth);
    }

    function _addToDelegatedAmount(address holder, uint amount, uint month) private {
        _delegatedAmount[holder].addToValue(amount, month);
    }

    function _removeFromDelegatedAmount(address holder, uint amount, uint month) private {
        _delegatedAmount[holder].subtractFromValue(amount, month);
    }

    function _addToTotalDelegatedAmount(address holder, uint amount, uint month) private {
        require(
            _totalDelegatedAmount[holder].month == 0 || _totalDelegatedAmount[holder].month <= month,
            "Can't add to total delegated in the past");

        // do not update counter if it is big enough
        // because it will override month value
        if (!_totalDelegatedSatisfiesProofOfUserCondition(holder)) {
            _totalDelegatedAmount[holder].delegated = _totalDelegatedAmount[holder].delegated.add(amount);
            _totalDelegatedAmount[holder].month = month;
        }
    }

    function _unlock(address holder) private {
        emit Unlocked(holder, _locked[holder]);
        delete _locked[holder];
        _deleteDelegatedAmount(holder);
        _deleteTotalDelegatedAmount(holder);
    }

    function _deleteDelegatedAmount(address holder) private {
        _delegatedAmount[holder].clear();
    }

    function _deleteTotalDelegatedAmount(address holder) private {
        delete _totalDelegatedAmount[holder].delegated;
        delete _totalDelegatedAmount[holder].month;
    }

    function _totalDelegatedSatisfiesProofOfUserCondition(address holder) private view returns (bool) {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        return _totalDelegatedAmount[holder].delegated.mul(100) >=
            _locked[holder].mul(constantsHolder.proofOfUseDelegationPercentage());
    }
}
pragma solidity ^0.6.0;
import "./Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    DelegationController.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Dmytro Stebaiev
    @author Vadim Yavorsky

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./IERC777.sol";

import "./Permissions.sol";
import "./Nodes.sol";
import "./MathUtils.sol";
import "./FractionUtils.sol";

import "./DelegationPeriodManager.sol";
import "./Punisher.sol";
import "./TokenLaunchLocker.sol";
import "./TokenState.sol";
import "./ValidatorService.sol";
import "./PartialDifferences.sol";

/**
 * @title Delegation Controller
 * @dev This contract performs all delegation functions including delegation
 * requests, undelegation, slashing, etc.
 *
 * Delegators and validators may both perform delegations. Validators who perform
 * delegations to themselves are effectively self-delegating or self-bonding.
 *
 * Delegated tokens may be in one of several states:
 *
 * - PROPOSED: token holder proposes tokens to delegate to a validator
 * - ACCEPTED: token delegations are accepted by a validator and are locked-by-delegation
 * - CANCELED: token holder cancels delegation proposal. Only allowed before the proposal is accepted by the validator
 * - REJECTED: token proposal expires at the UTC start of the next month
 * - DELEGATED: accepted delegations are delegated at the UTC start of the month
 * - UNDELEGATION_REQUESTED: token holder requests delegations to undelegate from the validator
 * - COMPLETED: undelegation request is completed at the end of the delegation period
 */
contract DelegationController is Permissions, ILocker {
    using MathUtils for uint;
    using PartialDifferences for PartialDifferences.Sequence;
    using PartialDifferences for PartialDifferences.Value;
    using FractionUtils for FractionUtils.Fraction;

    enum State {
        PROPOSED,
        ACCEPTED,
        CANCELED,
        REJECTED,
        DELEGATED,
        UNDELEGATION_REQUESTED,
        COMPLETED
    }

    struct Delegation {
        address holder; // address of token owner
        uint validatorId;
        uint amount;
        uint delegationPeriod;
        uint created; // time of delegation creation
        uint started; // month when a delegation becomes active
        uint finished; // first month after a delegation ends
        string info;
    }

    struct SlashingLogEvent {
        FractionUtils.Fraction reducingCoefficient;
        uint nextMonth;
    }

    struct SlashingLog {
        //      month => slashing event
        mapping (uint => SlashingLogEvent) slashes;
        uint firstMonth;
        uint lastMonth;
    }

    struct DelegationExtras {
        uint lastSlashingMonthBeforeDelegation;
    }

    struct SlashingEvent {
        FractionUtils.Fraction reducingCoefficient;
        uint validatorId;
        uint month;
    }

    struct SlashingSignal {
        address holder;
        uint penalty;
    }

    struct LockedInPending {
        uint amount;
        uint month;
    }

    struct FirstDelegationMonth {
        // month
        uint value;
        //validatorId => month
        mapping (uint => uint) byValidator;
    }

    struct ValidatorsStatistics {
        // number of validators
        uint number;
        //validatorId => bool - is Delegated or not
        mapping (uint => uint) delegated;
    }

    /**
     * @dev Emitted when a delegation is proposed to a validator.
     */
    event DelegationProposed(
        uint delegationId
    );

    /**
     * @dev Emitted when a delegation is accepted by a validator.
     */
    event DelegationAccepted(
        uint delegationId
    );

    /**
     * @dev Emitted when a delegation is cancelled by the delegator.
     */
    event DelegationRequestCanceledByUser(
        uint delegationId
    );

    /**
     * @dev Emitted when a delegation is requested to undelegate.
     */
    event UndelegationRequested(
        uint delegationId
    );

    /// @dev delegations will never be deleted to index in this array may be used like delegation id
    Delegation[] public delegations;

    // validatorId => delegationId[]
    mapping (uint => uint[]) public delegationsByValidator;

    //        holder => delegationId[]
    mapping (address => uint[]) public delegationsByHolder;

    // delegationId => extras
    mapping(uint => DelegationExtras) private _delegationExtras;

    // validatorId => sequence
    mapping (uint => PartialDifferences.Value) private _delegatedToValidator;
    // validatorId => sequence
    mapping (uint => PartialDifferences.Sequence) private _effectiveDelegatedToValidator;

    // validatorId => slashing log
    mapping (uint => SlashingLog) private _slashesOfValidator;

    //        holder => sequence
    mapping (address => PartialDifferences.Value) private _delegatedByHolder;
    //        holder =>   validatorId => sequence
    mapping (address => mapping (uint => PartialDifferences.Value)) private _delegatedByHolderToValidator;
    //        holder =>   validatorId => sequence
    mapping (address => mapping (uint => PartialDifferences.Sequence)) private _effectiveDelegatedByHolderToValidator;

    SlashingEvent[] private _slashes;
    //        holder => index in _slashes;
    mapping (address => uint) private _firstUnprocessedSlashByHolder;

    //        holder =>   validatorId => month
    mapping (address => FirstDelegationMonth) private _firstDelegationMonth;

    //        holder => locked in pending
    mapping (address => LockedInPending) private _lockedInPendingDelegations;

    mapping (address => ValidatorsStatistics) private _numberOfValidatorsPerDelegator;

    /**
     * @dev Modifier to make a function callable only if delegation exists.
     */
    modifier checkDelegationExists(uint delegationId) {
        require(delegationId < delegations.length, "Delegation does not exist");
        _;
    }

    function getAndUpdateDelegatedToValidatorNow(uint validatorId) external returns (uint) {
        return getAndUpdateDelegatedToValidator(validatorId, _getCurrentMonth());
    }

    function getAndUpdateDelegatedAmount(address holder) external returns (uint) {
        return _getAndUpdateDelegatedByHolder(holder);
    }

    function getAndUpdateEffectiveDelegatedByHolderToValidator(address holder, uint validatorId, uint month) external
        allow("Distributor") returns (uint effectiveDelegated)
    {
        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(holder);
        effectiveDelegated = _effectiveDelegatedByHolderToValidator[holder][validatorId]
            .getAndUpdateValueInSequence(month);
        _sendSlashingSignals(slashingSignals);
    }

    /**
     * @dev Allows a token holder to create a delegation proposal of an `amount`
     * and `delegationPeriod` to a `validatorId`. Delegation must be accepted
     * by the validator before the UTC start of the month, otherwise the
     * delegation will be rejected.
     *
     * The token holder may add additional information in each proposal.
     *
     * @param validatorId uint ID of validator to receive delegation proposal
     * @param amount uint amount of proposed delegation
     * @param delegationPeriod uint period of proposed delegation
     * @param info string extra information provided by the token holder (if any)
     */
    function delegate(
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string calldata info
    )
        external
    {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        DelegationPeriodManager delegationPeriodManager = DelegationPeriodManager(
            contractManager.getContract("DelegationPeriodManager"));
        IERC777 skaleToken = IERC777(contractManager.getContract("SkaleToken"));
        TokenState tokenState = TokenState(contractManager.getContract("TokenState"));

        require(
            validatorService.checkMinimumDelegation(validatorId, amount),
            "Amount does not meet the validator's minimum delegation amount");
        require(
            validatorService.isAuthorizedValidator(validatorId),
            "Validator is not authorized to accept delegation request");
        require(
            delegationPeriodManager.isDelegationPeriodAllowed(delegationPeriod),
            "This delegation period is not allowed");
        require(
            validatorService.isAcceptingNewRequests(validatorId),
            "The validator is not currently accepting new requests");
        _checkIfDelegationIsAllowed(msg.sender, validatorId);

        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(msg.sender);

        uint delegationId = _addDelegation(
            msg.sender,
            validatorId,
            amount,
            delegationPeriod,
            info);

        // check that there is enough money
        uint holderBalance = skaleToken.balanceOf(msg.sender);
        uint forbiddenForDelegation = tokenState.getAndUpdateForbiddenForDelegationAmount(msg.sender);
        require(holderBalance >= forbiddenForDelegation, "Token holder does not have enough tokens to delegate");

        emit DelegationProposed(delegationId);

        _sendSlashingSignals(slashingSignals);
    }

    /**
     * @dev See ILocker.
     */
    function getAndUpdateLockedAmount(address wallet) external override returns (uint) {
        return _getAndUpdateLockedAmount(wallet);
    }

    /**
     * @dev See ILocker.
     */
    function getAndUpdateForbiddenForDelegationAmount(address wallet) external override returns (uint) {
        return _getAndUpdateLockedAmount(wallet);
    }

    /**
     * @dev Allows a token holder to cancel a delegation proposal.
     *
     * Requirements:
     *
     * - the sender must be the token holder of the delegation proposal.
     * - the delegation must still be in a PROPOSED state.
     *
     * Emits a DelegationRequestCanceledByUser event.
     *
     * @param delegationId uint ID of delegation proposal
     */
    function cancelPendingDelegation(uint delegationId) external checkDelegationExists(delegationId) {
        require(msg.sender == delegations[delegationId].holder, "Only token holders can cancel delegation request");
        require(getState(delegationId) == State.PROPOSED, "Token holders are only able to cancel PROPOSED delegations");

        delegations[delegationId].finished = _getCurrentMonth();
        _subtractFromLockedInPendingDelegations(delegations[delegationId].holder, delegations[delegationId].amount);

        emit DelegationRequestCanceledByUser(delegationId);
    }

    /**
     * @dev Allows a validator to accept a proposed delegation.
     * Successful acceptance of delegations transition the tokens from a
     * PROPOSED state to ACCEPTED, and tokens are locked for the remainder of the
     * delegation period.
     *
     * Emits a DelegationAccepted event.
     *
     * @param delegationId uint ID of delegation proposal
     */
    function acceptPendingDelegation(uint delegationId) external checkDelegationExists(delegationId) {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(
            validatorService.checkValidatorAddressToId(msg.sender, delegations[delegationId].validatorId),
            "No permissions to accept request");
        _checkIfDelegationIsAllowed(delegations[delegationId].holder, delegations[delegationId].validatorId);
        
        State currentState = getState(delegationId);
        if (currentState != State.PROPOSED) {
            if (currentState == State.ACCEPTED ||
                currentState == State.DELEGATED ||
                currentState == State.UNDELEGATION_REQUESTED ||
                currentState == State.COMPLETED)
            {
                revert("The delegation has been already accepted");
            } else if (currentState == State.CANCELED) {
                revert("The delegation has been cancelled by token holder");
            } else if (currentState == State.REJECTED) {
                revert("The delegation request is outdated");
            }
        }
        require(currentState == State.PROPOSED, "Cannot set delegation state to accepted");
        
        TokenLaunchLocker tokenLaunchLocker = TokenLaunchLocker(contractManager.getContract("TokenLaunchLocker"));

        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(delegations[delegationId].holder);

        _addToAllStatistics(delegationId);

        tokenLaunchLocker.handleDelegationAdd(
            delegations[delegationId].holder,
            delegationId,
            delegations[delegationId].amount,
            delegations[delegationId].started);

        _sendSlashingSignals(slashingSignals);

        emit DelegationAccepted(delegationId);
    }

    /**
     * @dev Allows a delegator to undelegate a specific delegation.
     *
     * Requirements:
     *
     * - the sender must be the delegator.
     * - the delegation must be in DELEGATED state.
     *
     * Emits an UndelegationRequested event.
     *
     * @param delegationId uint ID of delegation to undelegate
     */
    function requestUndelegation(uint delegationId) external checkDelegationExists(delegationId) {
        require(getState(delegationId) == State.DELEGATED, "Cannot request undelegation");
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(
            delegations[delegationId].holder == msg.sender ||
            (validatorService.validatorAddressExists(msg.sender) &&
            delegations[delegationId].validatorId == validatorService.getValidatorId(msg.sender)),
            "Permission denied to request undelegation");
        TokenLaunchLocker tokenLaunchLocker = TokenLaunchLocker(contractManager.getContract("TokenLaunchLocker"));
        DelegationPeriodManager delegationPeriodManager = DelegationPeriodManager(
            contractManager.getContract("DelegationPeriodManager"));
        _removeValidatorFromValidatorsPerDelegators(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId
        );
        processAllSlashes(msg.sender);
        delegations[delegationId].finished = _calculateDelegationEndMonth(delegationId);
        uint amountAfterSlashing = _calculateDelegationAmountAfterSlashing(delegationId);
        _removeFromDelegatedToValidator(
            delegations[delegationId].validatorId,
            amountAfterSlashing,
            delegations[delegationId].finished);
        _removeFromDelegatedByHolder(
            delegations[delegationId].holder,
            amountAfterSlashing,
            delegations[delegationId].finished);
        _removeFromDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            amountAfterSlashing,
            delegations[delegationId].finished);
        uint effectiveAmount = amountAfterSlashing.mul(delegationPeriodManager.stakeMultipliers(
            delegations[delegationId].delegationPeriod));
        _removeFromEffectiveDelegatedToValidator(
            delegations[delegationId].validatorId,
            effectiveAmount,
            delegations[delegationId].finished);
        _removeFromEffectiveDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            effectiveAmount,
            delegations[delegationId].finished);
        tokenLaunchLocker.handleDelegationRemoving(
            delegations[delegationId].holder,
            delegationId,
            delegations[delegationId].finished);
        emit UndelegationRequested(delegationId);
    }

    /**
     * @dev Allows the Punisher to confiscate an `amount` of stake from
     * `validatorId` by slashing. This slashes all delegations of the validator,
     * which reduces the amount that the validator has staked. This consequence
     * may force the SKALE Manger to reduce the number of nodes a validator is
     * operating so the validator can meet the Minimum Staking Requirement.
     *
     * See Punisher.
     *
     * Emits a SlashingEvent.
     *
     * @param validatorId uint validator to slash
     * @param amount uint amount to slash
     *
     */
    function confiscate(uint validatorId, uint amount) external allow("Punisher") {
        uint currentMonth = _getCurrentMonth();
        FractionUtils.Fraction memory coefficient =
            _delegatedToValidator[validatorId].reduceValue(amount, currentMonth);
        _effectiveDelegatedToValidator[validatorId].reduceSequence(coefficient, currentMonth);
        _putToSlashingLog(_slashesOfValidator[validatorId], coefficient, currentMonth);
        _slashes.push(SlashingEvent({reducingCoefficient: coefficient, validatorId: validatorId, month: currentMonth}));
    }

    function getAndUpdateEffectiveDelegatedToValidator(uint validatorId, uint month)
        external allow("Distributor") returns (uint)
    {
        return _effectiveDelegatedToValidator[validatorId].getAndUpdateValueInSequence(month);
    }

    function getAndUpdateDelegatedByHolderToValidatorNow(address holder, uint validatorId) external returns (uint) {
        return _getAndUpdateDelegatedByHolderToValidator(holder, validatorId, _getCurrentMonth());
    }

    function getDelegation(uint delegationId)
        external view checkDelegationExists(delegationId) returns (Delegation memory)
    {
        return delegations[delegationId];
    }

    function getFirstDelegationMonth(address holder, uint validatorId) external view returns(uint) {
        return _firstDelegationMonth[holder].byValidator[validatorId];
    }

    function getDelegationsByValidatorLength(uint validatorId) external view returns (uint) {
        return delegationsByValidator[validatorId].length;
    }

    function getDelegationsByHolderLength(address holder) external view returns (uint) {
        return delegationsByHolder[holder].length;
    }

    function initialize(address contractsAddress) public override initializer {
        Permissions.initialize(contractsAddress);
    }

    function getAndUpdateDelegatedToValidator(uint validatorId, uint month)
        public allow("Nodes") returns (uint)
    {
        return _delegatedToValidator[validatorId].getAndUpdateValue(month);
    }

    function processSlashes(address holder, uint limit) public {
        _sendSlashingSignals(_processSlashesWithoutSignals(holder, limit));
    }

    function processAllSlashes(address holder) public {
        processSlashes(holder, 0);
    }

    /**
     * @dev Returns the token state of a given delegation.
     *
     * @param delegationId uint ID of the delegation
     */
    function getState(uint delegationId) public view checkDelegationExists(delegationId) returns (State state) {
        if (delegations[delegationId].started == 0) {
            if (delegations[delegationId].finished == 0) {
                TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
                if (_getCurrentMonth() == timeHelpers.timestampToMonth(delegations[delegationId].created)) {
                    return State.PROPOSED;
                } else {
                    return State.REJECTED;
                }
            } else {
                return State.CANCELED;
            }
        } else {
            if (_getCurrentMonth() < delegations[delegationId].started) {
                return State.ACCEPTED;
            } else {
                if (delegations[delegationId].finished == 0) {
                    return State.DELEGATED;
                } else {
                    if (_getCurrentMonth() < delegations[delegationId].finished) {
                        return State.UNDELEGATION_REQUESTED;
                    } else {
                        return State.COMPLETED;
                    }
                }
            }
        }
    }

    function getLockedInPendingDelegations(address holder) public view returns (uint) {
        uint currentMonth = _getCurrentMonth();
        if (_lockedInPendingDelegations[holder].month < currentMonth) {
            return 0;
        } else {
            return _lockedInPendingDelegations[holder].amount;
        }
    }

    function hasUnprocessedSlashes(address holder) public view returns (bool) {
        return _everDelegated(holder) && _firstUnprocessedSlashByHolder[holder] < _slashes.length;
    }    

    // private

    function _addDelegation(
        address holder,
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string memory info
    )
        private
        returns (uint delegationId)
    {
        delegationId = delegations.length;
        delegations.push(Delegation(
            holder,
            validatorId,
            amount,
            delegationPeriod,
            now,
            0,
            0,
            info
        ));
        delegationsByValidator[validatorId].push(delegationId);
        delegationsByHolder[holder].push(delegationId);
        _addToLockedInPendingDelegations(delegations[delegationId].holder, delegations[delegationId].amount);
    }

    function _calculateDelegationEndMonth(uint delegationId) private view returns (uint) {
        uint currentMonth = _getCurrentMonth();
        uint started = delegations[delegationId].started;

        if (currentMonth < started) {
            return started.add(delegations[delegationId].delegationPeriod);
        } else {
            uint completedPeriods = currentMonth.sub(started).div(delegations[delegationId].delegationPeriod);
            return started.add(completedPeriods.add(1).mul(delegations[delegationId].delegationPeriod));
        }
    }

    function _addToDelegatedToValidator(uint validatorId, uint amount, uint month) private {
        _delegatedToValidator[validatorId].addToValue(amount, month);
    }

    function _addToEffectiveDelegatedToValidator(uint validatorId, uint effectiveAmount, uint month) private {
        _effectiveDelegatedToValidator[validatorId].addToSequence(effectiveAmount, month);
    }

    function _addToDelegatedByHolder(address holder, uint amount, uint month) private {
        _delegatedByHolder[holder].addToValue(amount, month);
    }

    function _addToDelegatedByHolderToValidator(
        address holder, uint validatorId, uint amount, uint month) private
    {
        _delegatedByHolderToValidator[holder][validatorId].addToValue(amount, month);
    }

    function _addValidatorToValidatorsPerDelegators(address holder, uint validatorId) private {
        if (_numberOfValidatorsPerDelegator[holder].delegated[validatorId] == 0) {
            _numberOfValidatorsPerDelegator[holder].number = _numberOfValidatorsPerDelegator[holder].number.add(1);
        }
        _numberOfValidatorsPerDelegator[holder].
            delegated[validatorId] = _numberOfValidatorsPerDelegator[holder].delegated[validatorId].add(1);
    }

    function _removeFromDelegatedByHolder(address holder, uint amount, uint month) private {
        _delegatedByHolder[holder].subtractFromValue(amount, month);
    }

    function _removeFromDelegatedByHolderToValidator(
        address holder, uint validatorId, uint amount, uint month) private
    {
        _delegatedByHolderToValidator[holder][validatorId].subtractFromValue(amount, month);
    }

    function _removeValidatorFromValidatorsPerDelegators(address holder, uint validatorId) private {
        if (_numberOfValidatorsPerDelegator[holder].delegated[validatorId] == 1) {
            _numberOfValidatorsPerDelegator[holder].number = _numberOfValidatorsPerDelegator[holder].number.sub(1);
        }
        _numberOfValidatorsPerDelegator[holder].
            delegated[validatorId] = _numberOfValidatorsPerDelegator[holder].delegated[validatorId].sub(1);
    }

    function _addToEffectiveDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint effectiveAmount,
        uint month)
        private
    {
        _effectiveDelegatedByHolderToValidator[holder][validatorId].addToSequence(effectiveAmount, month);
    }

    function _removeFromEffectiveDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint effectiveAmount,
        uint month)
        private
    {
        _effectiveDelegatedByHolderToValidator[holder][validatorId].subtractFromSequence(effectiveAmount, month);
    }

    function _getAndUpdateDelegatedByHolder(address holder) private returns (uint) {
        uint currentMonth = _getCurrentMonth();
        processAllSlashes(holder);
        return _delegatedByHolder[holder].getAndUpdateValue(currentMonth);
    }

    function _getAndUpdateDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint month)
        private returns (uint)
    {
        return _delegatedByHolderToValidator[holder][validatorId].getAndUpdateValue(month);
    }

    function _addToLockedInPendingDelegations(address holder, uint amount) private returns (uint) {
        uint currentMonth = _getCurrentMonth();
        if (_lockedInPendingDelegations[holder].month < currentMonth) {
            _lockedInPendingDelegations[holder].amount = amount;
            _lockedInPendingDelegations[holder].month = currentMonth;
        } else {
            assert(_lockedInPendingDelegations[holder].month == currentMonth);
            _lockedInPendingDelegations[holder].amount = _lockedInPendingDelegations[holder].amount.add(amount);
        }
    }

    function _subtractFromLockedInPendingDelegations(address holder, uint amount) private returns (uint) {
        uint currentMonth = _getCurrentMonth();
        require(
            _lockedInPendingDelegations[holder].month == currentMonth,
            "There are no delegation requests this month");
        require(_lockedInPendingDelegations[holder].amount >= amount, "Unlocking amount is too big");
        _lockedInPendingDelegations[holder].amount = _lockedInPendingDelegations[holder].amount.sub(amount);
    }

    function _getCurrentMonth() private view returns (uint) {
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        return timeHelpers.getCurrentMonth();
    }

    function _getAndUpdateLockedAmount(address wallet) private returns (uint) {
        return _getAndUpdateDelegatedByHolder(wallet).add(getLockedInPendingDelegations(wallet));
    }

    function _updateFirstDelegationMonth(address holder, uint validatorId, uint month) private {
        if (_firstDelegationMonth[holder].value == 0) {
            _firstDelegationMonth[holder].value = month;
            _firstUnprocessedSlashByHolder[holder] = _slashes.length;
        }
        if (_firstDelegationMonth[holder].byValidator[validatorId] == 0) {
            _firstDelegationMonth[holder].byValidator[validatorId] = month;
        }
    }

    function _everDelegated(address holder) private view returns (bool) {
        return _firstDelegationMonth[holder].value > 0;
    }

    function _removeFromDelegatedToValidator(uint validatorId, uint amount, uint month) private {
        _delegatedToValidator[validatorId].subtractFromValue(amount, month);
    }

    function _removeFromEffectiveDelegatedToValidator(uint validatorId, uint effectiveAmount, uint month) private {
        _effectiveDelegatedToValidator[validatorId].subtractFromSequence(effectiveAmount, month);
    }

    function _calculateDelegationAmountAfterSlashing(uint delegationId) private view returns (uint) {
        uint startMonth = _delegationExtras[delegationId].lastSlashingMonthBeforeDelegation;
        uint validatorId = delegations[delegationId].validatorId;
        uint amount = delegations[delegationId].amount;
        if (startMonth == 0) {
            startMonth = _slashesOfValidator[validatorId].firstMonth;
            if (startMonth == 0) {
                return amount;
            }
        }
        for (uint i = startMonth;
            i > 0 && i < delegations[delegationId].finished;
            i = _slashesOfValidator[validatorId].slashes[i].nextMonth) {
            if (i >= delegations[delegationId].started) {
                amount = amount
                    .mul(_slashesOfValidator[validatorId].slashes[i].reducingCoefficient.numerator)
                    .div(_slashesOfValidator[validatorId].slashes[i].reducingCoefficient.denominator);
            }
        }
        return amount;
    }

    function _putToSlashingLog(
        SlashingLog storage log,
        FractionUtils.Fraction memory coefficient,
        uint month)
        private
    {
        if (log.firstMonth == 0) {
            log.firstMonth = month;
            log.lastMonth = month;
            log.slashes[month].reducingCoefficient = coefficient;
            log.slashes[month].nextMonth = 0;
        } else {
            require(log.lastMonth <= month, "Cannot put slashing event in the past");
            if (log.lastMonth == month) {
                log.slashes[month].reducingCoefficient =
                    log.slashes[month].reducingCoefficient.multiplyFraction(coefficient);
            } else {
                log.slashes[month].reducingCoefficient = coefficient;
                log.slashes[month].nextMonth = 0;
                log.slashes[log.lastMonth].nextMonth = month;
                log.lastMonth = month;
            }
        }
    }

    function _processSlashesWithoutSignals(address holder, uint limit)
        private returns (SlashingSignal[] memory slashingSignals)
    {
        if (hasUnprocessedSlashes(holder)) {
            uint index = _firstUnprocessedSlashByHolder[holder];
            uint end = _slashes.length;
            if (limit > 0 && index.add(limit) < end) {
                end = index.add(limit);
            }
            slashingSignals = new SlashingSignal[](end.sub(index));
            uint begin = index;
            for (; index < end; ++index) {
                uint validatorId = _slashes[index].validatorId;
                uint month = _slashes[index].month;
                uint oldValue = _getAndUpdateDelegatedByHolderToValidator(holder, validatorId, month);
                if (oldValue.muchGreater(0)) {
                    _delegatedByHolderToValidator[holder][validatorId].reduceValueByCoefficientAndUpdateSum(
                        _delegatedByHolder[holder],
                        _slashes[index].reducingCoefficient,
                        month);
                    _effectiveDelegatedByHolderToValidator[holder][validatorId].reduceSequence(
                        _slashes[index].reducingCoefficient,
                        month);
                    slashingSignals[index.sub(begin)].holder = holder;
                    slashingSignals[index.sub(begin)].penalty
                        = oldValue.boundedSub(_getAndUpdateDelegatedByHolderToValidator(holder, validatorId, month));
                }
            }
            _firstUnprocessedSlashByHolder[holder] = end;
        }
    }

    function _processAllSlashesWithoutSignals(address holder)
        private returns (SlashingSignal[] memory slashingSignals)
    {
        return _processSlashesWithoutSignals(holder, 0);
    }

    function _sendSlashingSignals(SlashingSignal[] memory slashingSignals) private {
        Punisher punisher = Punisher(contractManager.getContract("Punisher"));
        address previousHolder = address(0);
        uint accumulatedPenalty = 0;
        for (uint i = 0; i < slashingSignals.length; ++i) {
            if (slashingSignals[i].holder != previousHolder) {
                if (accumulatedPenalty > 0) {
                    punisher.handleSlash(previousHolder, accumulatedPenalty);
                }
                previousHolder = slashingSignals[i].holder;
                accumulatedPenalty = slashingSignals[i].penalty;
            } else {
                accumulatedPenalty = accumulatedPenalty.add(slashingSignals[i].penalty);
            }
        }
        if (accumulatedPenalty > 0) {
            punisher.handleSlash(previousHolder, accumulatedPenalty);
        }
    }

    function _addToAllStatistics(uint delegationId) private {
        DelegationPeriodManager delegationPeriodManager = DelegationPeriodManager(
            contractManager.getContract("DelegationPeriodManager"));

        uint currentMonth = _getCurrentMonth();
        delegations[delegationId].started = currentMonth.add(1);
        if (_slashesOfValidator[delegations[delegationId].validatorId].lastMonth > 0) {
            _delegationExtras[delegationId].lastSlashingMonthBeforeDelegation =
                _slashesOfValidator[delegations[delegationId].validatorId].lastMonth;
        }

        _addToDelegatedToValidator(
            delegations[delegationId].validatorId,
            delegations[delegationId].amount,
            currentMonth.add(1));
        _addToDelegatedByHolder(
            delegations[delegationId].holder,
            delegations[delegationId].amount,
            currentMonth.add(1));
        _addToDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            delegations[delegationId].amount,
            currentMonth.add(1));
        _updateFirstDelegationMonth(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            currentMonth.add(1));
        uint effectiveAmount = delegations[delegationId].amount.mul(delegationPeriodManager.stakeMultipliers(
            delegations[delegationId].delegationPeriod));
        _addToEffectiveDelegatedToValidator(
            delegations[delegationId].validatorId,
            effectiveAmount,
            currentMonth.add(1));
        _addToEffectiveDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            effectiveAmount,
            currentMonth.add(1));
        _addValidatorToValidatorsPerDelegators(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId
        );
    }

    function _checkIfDelegationIsAllowed(address holder, uint validatorId) private view returns (bool) {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        require(
            _numberOfValidatorsPerDelegator[holder].delegated[validatorId] > 0 ||
                (
                    _numberOfValidatorsPerDelegator[holder].delegated[validatorId] == 0 &&
                    _numberOfValidatorsPerDelegator[holder].number < constantsHolder.limitValidatorsPerDelegator()
                ),
            "Limit of validators is reached"
        );
    }
}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    ValidatorService.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev
    @author Artem Payvin
    @author Vadim Yavorsky

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./ECDSA.sol";

import "./Permissions.sol";
import "./ConstantsHolder.sol";

import "./DelegationController.sol";

/**
 * @title ValidatorService
 * @dev This contract handles all validator operations including registration,
 * node management, validator-specific delegation parameters, and more.
 *
 * Validators register an address, and use this address to accept delegations and
 * register nodes.
 *
 */
contract ValidatorService is Permissions {

    using ECDSA for bytes32;

    struct Validator {
        string name;
        address validatorAddress;
        address requestedAddress;
        string description;
        uint feeRate;
        uint registrationTime;
        uint minimumDelegationAmount;
        bool acceptNewRequests;
    }

    /**
     * @dev Emitted when a validator registers.
     */
    event ValidatorRegistered(
        uint validatorId
    );

    /**
     * @dev Emitted when a validator address changes.
     */
    event ValidatorAddressChanged(
        uint validatorId,
        address newAddress
    );

    event ValidatorWasEnabled(
        uint validatorId
    );

    event ValidatorWasDisabled(
        uint validatorId
    );

    /**
     * @dev Emitted when a node address is linked to a validator.
     */
    event NodeAddressWasAdded(
        uint validatorId,
        address nodeAddress
    );

    /**
     * @dev Emitted when a node address is unlinked from a validator.
     */
    event NodeAddressWasRemoved(
        uint validatorId,
        address nodeAddress
    );

    mapping (uint => Validator) public validators;
    mapping (uint => bool) private _trustedValidators;
    uint[] public trustedValidatorsList;
    //       address => validatorId
    mapping (address => uint) private _validatorAddressToId;
    //       address => validatorId
    mapping (address => uint) private _nodeAddressToValidatorId;
    // validatorId => nodeAddress[]
    mapping (uint => address[]) private _nodeAddresses;
    uint public numberOfValidators;
    bool public useWhitelist;

    modifier checkValidatorExists(uint validatorId) {
        require(validatorExists(validatorId), "Validator with such ID does not exist");
        _;
    }

    /**
     * @dev Creates a new validator Id.
     *
     * Requirements:
     *
     * - sender must not already have registered a validator Id.
     * - fee rate must be between 0 - 1000‰. Note: per mille!
     *
     * Emits ValidatorRegistered event.
     *
     * @param name string
     * @param description string
     * @param feeRate uint Fee charged on delegations by the validator per mille
     * @param minimumDelegationAmount uint Minimum delegation amount accepted by the validator
     */
    function registerValidator(
        string calldata name,
        string calldata description,
        uint feeRate,
        uint minimumDelegationAmount
    )
        external
        returns (uint validatorId)
    {
        require(!validatorAddressExists(msg.sender), "Validator with such address already exists");
        require(feeRate < 1000, "Fee rate of validator should be lower than 100%");
        validatorId = ++numberOfValidators;
        validators[validatorId] = Validator(
            name,
            msg.sender,
            address(0),
            description,
            feeRate,
            now,
            minimumDelegationAmount,
            true
        );
        _setValidatorAddress(validatorId, msg.sender);

        emit ValidatorRegistered(validatorId);
    }

    function enableValidator(uint validatorId) external checkValidatorExists(validatorId) onlyAdmin {
        require(!_trustedValidators[validatorId], "Validator is already enabled");
        _trustedValidators[validatorId] = true;
        trustedValidatorsList.push(validatorId);
        emit ValidatorWasEnabled(validatorId);
    }

    function disableValidator(uint validatorId) external checkValidatorExists(validatorId) onlyAdmin {
        require(_trustedValidators[validatorId], "Validator is already disabled");
        _trustedValidators[validatorId] = false;
        uint position = _find(trustedValidatorsList, validatorId);
        if (position < trustedValidatorsList.length) {
            trustedValidatorsList[position] =
                trustedValidatorsList[trustedValidatorsList.length.sub(1)];
        }
        trustedValidatorsList.pop();
        emit ValidatorWasDisabled(validatorId);
    }

    /**
     * @dev Owner can disable the validator whitelist. Once turned off the
     * whitelist cannot be re-enabled.
     */
    function disableWhitelist() external onlyOwner {
        useWhitelist = false;
    }

    /**
     * @dev Allows a validator to request a new address.
     *
     * Requirements:
     *
     * - new address must not be null
     * - new address must not be already registered as a validator
     *
     * @param newValidatorAddress address
     */
    function requestForNewAddress(address newValidatorAddress) external {
        require(newValidatorAddress != address(0), "New address cannot be null");
        require(_validatorAddressToId[newValidatorAddress] == 0, "Address already registered");
        // check Validator Exist inside getValidatorId
        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].requestedAddress = newValidatorAddress;
    }

    function confirmNewAddress(uint validatorId)
        external
        checkValidatorExists(validatorId)
    {
        require(
            getValidator(validatorId).requestedAddress == msg.sender,
            "The validator address cannot be changed because it is not the actual owner"
        );
        delete validators[validatorId].requestedAddress;
        _setValidatorAddress(validatorId, msg.sender);

        emit ValidatorAddressChanged(validatorId, validators[validatorId].validatorAddress);
    }

    /**
     * @dev Links a given node address.
     *
     * Requirements:
     *
     * - the given signature must be valid.
     * - the address must not be assigned to a validator.
     *
     * Emits NodeAddressWasAdded event.
     *
     * @param nodeAddress address
     * @param sig bytes signature of validator Id by node operator.
     */
    function linkNodeAddress(address nodeAddress, bytes calldata sig) external {
        // check Validator Exist inside getValidatorId
        uint validatorId = getValidatorId(msg.sender);
        require(
            keccak256(abi.encodePacked(validatorId)).toEthSignedMessageHash().recover(sig) == nodeAddress,
            "Signature is not pass"
        );
        require(_validatorAddressToId[nodeAddress] == 0, "Node address is a validator");

        _addNodeAddress(validatorId, nodeAddress);
        emit NodeAddressWasAdded(validatorId, nodeAddress);
    }

    /**
     * @dev Unlinks a given node address from a validator.
     *
     * Emits NodeAddressWasRemoved event.
     *
     * @param nodeAddress address
     */
    function unlinkNodeAddress(address nodeAddress) external {
        // check Validator Exist inside getValidatorId
        uint validatorId = getValidatorId(msg.sender);

        _removeNodeAddress(validatorId, nodeAddress);
        emit NodeAddressWasRemoved(validatorId, nodeAddress);
    }

    function setValidatorMDA(uint minimumDelegationAmount) external {
        // check Validator Exist inside getValidatorId
        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].minimumDelegationAmount = minimumDelegationAmount;
    }

    /**
     * @dev Allows a validator to set a new validator name.
     *
     * @param newName string
     */
    function setValidatorName(string calldata newName) external {
        // check Validator Exist inside getValidatorId
        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].name = newName;
    }

    /**
     * @dev Allows a validator to set a new validator description.
     *
     * @param newDescription string
     */
    function setValidatorDescription(string calldata newDescription) external {
        // check Validator Exist inside getValidatorId
        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].description = newDescription;
    }

    /**
     * @dev Allows a validator to start accepting new delegation requests.
     *
     * Requirements:
     *
     * - validator must not have already enabled accepting new requests
     */
    function startAcceptingNewRequests() external {
        // check Validator Exist inside getValidatorId
        uint validatorId = getValidatorId(msg.sender);
        require(!isAcceptingNewRequests(validatorId), "Accepting request is already enabled");

        validators[validatorId].acceptNewRequests = true;
    }

    /**
     * @dev Allows a validator to stop accepting new delegation requests.
     *
     * Requirements:
     *
     * - validator must not have already stopped accepting new requests
     */
    function stopAcceptingNewRequests() external {
        // check Validator Exist inside getValidatorId
        uint validatorId = getValidatorId(msg.sender);
        require(isAcceptingNewRequests(validatorId), "Accepting request is already disabled");

        validators[validatorId].acceptNewRequests = false;
    }

    /**
     * @dev Returns the amount of validator bond.
     *
     * @param validatorId uint ID of validator to return the amount of locked funds
     * @return bondAmount uint the amount of self-delegated funds by the validator
    */
    function getAndUpdateBondAmount(uint validatorId)
        external
        returns (uint)
    {
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController")
        );
        return delegationController.getAndUpdateDelegatedByHolderToValidatorNow(
            getValidator(validatorId).validatorAddress,
            validatorId
        );
    }

    function getMyNodesAddresses() external view returns (address[] memory) {
        return getNodeAddresses(getValidatorId(msg.sender));
    }

    /**
     * @dev Returns a list of trusted validators.
     *
     * @return uint[] trusted validators
     */
    function getTrustedValidators() external view returns (uint[] memory) {
        return trustedValidatorsList;
    }

    function checkMinimumDelegation(uint validatorId, uint amount)
        external
        view
        checkValidatorExists(validatorId)
        allow("DelegationController")
        returns (bool)
    {
        return validators[validatorId].minimumDelegationAmount <= amount ? true : false;
    }

    function checkValidatorAddressToId(address validatorAddress, uint validatorId)
        external
        view
        returns (bool)
    {
        return getValidatorId(validatorAddress) == validatorId ? true : false;
    }

    function getValidatorIdByNodeAddress(address nodeAddress) external view returns (uint validatorId) {
        validatorId = _nodeAddressToValidatorId[nodeAddress];
        require(validatorId != 0, "Node address is not assigned to a validator");
    }


    function isAuthorizedValidator(uint validatorId) external view checkValidatorExists(validatorId) returns (bool) {
        return _trustedValidators[validatorId] || !useWhitelist;
    }

    function initialize(address contractManagerAddress) public override initializer {
        Permissions.initialize(contractManagerAddress);
        useWhitelist = true;
    }

    function getNodeAddresses(uint validatorId) public view returns (address[] memory) {
        return _nodeAddresses[validatorId];
    }

    function validatorExists(uint validatorId) public view returns (bool) {
        return validatorId <= numberOfValidators && validatorId != 0;
    }

    function validatorAddressExists(address validatorAddress) public view returns (bool) {
        return _validatorAddressToId[validatorAddress] != 0;
    }

    function checkIfValidatorAddressExists(address validatorAddress) public view {
        require(validatorAddressExists(validatorAddress), "Validator with given address does not exist");
    }

    function getValidator(uint validatorId) public view checkValidatorExists(validatorId) returns (Validator memory) {
        return validators[validatorId];
    }

    function getValidatorId(address validatorAddress) public view returns (uint) {
        checkIfValidatorAddressExists(validatorAddress);
        return _validatorAddressToId[validatorAddress];
    }

    function isAcceptingNewRequests(uint validatorId) public view checkValidatorExists(validatorId) returns (bool) {
        return validators[validatorId].acceptNewRequests;
    }

    // private
    function _setValidatorAddress(uint validatorId, address validatorAddress) private {
        if (_validatorAddressToId[validatorAddress] == validatorId) {
            return;
        }
        require(_validatorAddressToId[validatorAddress] == 0, "Address is in use by another validator");
        address oldAddress = validators[validatorId].validatorAddress;
        delete _validatorAddressToId[oldAddress];
        _nodeAddressToValidatorId[validatorAddress] = validatorId;
        validators[validatorId].validatorAddress = validatorAddress;
        _validatorAddressToId[validatorAddress] = validatorId;
    }

    function _addNodeAddress(uint validatorId, address nodeAddress) private {
        if (_nodeAddressToValidatorId[nodeAddress] == validatorId) {
            return;
        }
        require(_nodeAddressToValidatorId[nodeAddress] == 0, "Validator cannot override node address");
        _nodeAddressToValidatorId[nodeAddress] = validatorId;
        _nodeAddresses[validatorId].push(nodeAddress);
    }

    function _removeNodeAddress(uint validatorId, address nodeAddress) private {
        require(_nodeAddressToValidatorId[nodeAddress] == validatorId,
            "Validator does not have permissions to unlink node");
        delete _nodeAddressToValidatorId[nodeAddress];
        for (uint i = 0; i < _nodeAddresses[validatorId].length; ++i) {
            if (_nodeAddresses[validatorId][i] == nodeAddress) {
                if (i + 1 < _nodeAddresses[validatorId].length) {
                    _nodeAddresses[validatorId][i] =
                        _nodeAddresses[validatorId][_nodeAddresses[validatorId].length.sub(1)];
                }
                delete _nodeAddresses[validatorId][_nodeAddresses[validatorId].length.sub(1)];
                _nodeAddresses[validatorId].pop();
                break;
            }
        }
    }

    function _find(uint[] memory array, uint index) private pure returns (uint) {
        uint i;
        for (i = 0; i < array.length; i++) {
            if (array[i] == index) {
                return i;
            }
        }
        return array.length;
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    ContractManager.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./Ownable.sol";
import "./Address.sol";

import "./StringUtils.sol";


/**
 * @title Main contract in upgradeable approach. This contract contains the actual
 * current mapping from contract IDs (in the form of human-readable strings) to addresses.
 * @author Artem Payvin
 */
contract ContractManager is OwnableUpgradeSafe {
    using StringUtils for string;
    using Address for address;

    // mapping of actual smart contracts addresses
    mapping (bytes32 => address) public contracts;

    event ContractUpgraded(string contractsName, address contractsAddress);

    function initialize() external initializer {
        OwnableUpgradeSafe.__Ownable_init();
    }

    /**
     * Adds actual contract to mapping of actual contract addresses
     * @param contractsName - contracts name in skale manager system
     * @param newContractsAddress - contracts address in skale manager system
     */
    function setContractsAddress(string calldata contractsName, address newContractsAddress) external onlyOwner {
        // check newContractsAddress is not equal to zero
        require(newContractsAddress != address(0), "New address is equal zero");
        // create hash of contractsName
        bytes32 contractId = keccak256(abi.encodePacked(contractsName));
        // check newContractsAddress is not equal the previous contract's address
        require(contracts[contractId] != newContractsAddress, "Contract is already added");
        require(newContractsAddress.isContract(), "Given contracts address does not contain code");
        // add newContractsAddress to mapping of actual contract addresses
        contracts[contractId] = newContractsAddress;
        emit ContractUpgraded(contractsName, newContractsAddress);
    }

    function getContract(string calldata name) external view returns (address contractAddress) {
        contractAddress = contracts[keccak256(abi.encodePacked(name))];
        require(contractAddress != address(0), name.strConcat(" contract has not been found"));
    }
}

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777Recipient {
    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    ConstantsHolder.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./Permissions.sol";


/**
 * @title Contains constants and common variables for Skale Manager system
 * @author Artem Payvin
 */
contract ConstantsHolder is Permissions {

    // initial price for creating Node (100 SKL)
    uint public constant NODE_DEPOSIT = 100 * 1e18;

    uint8 public constant TOTAL_SPACE_ON_NODE = 128;

    // part of Node for Small Skale-chain (1/128 of Node)
    uint8 public constant SMALL_DIVISOR = 128;

    // part of Node for Medium Skale-chain (1/8 of Node)
    uint8 public constant MEDIUM_DIVISOR = 8;

    // part of Node for Large Skale-chain (full Node)
    uint8 public constant LARGE_DIVISOR = 1;

    // part of Node for Medium Test Skale-chain (1/4 of Node)
    uint8 public constant MEDIUM_TEST_DIVISOR = 4;

    // typically number of Nodes for Skale-chain (16 Nodes)
    uint public constant NUMBER_OF_NODES_FOR_SCHAIN = 16;

    // number of Nodes for Test Skale-chain (2 Nodes)
    uint public constant NUMBER_OF_NODES_FOR_TEST_SCHAIN = 2;

    // number of Nodes for Test Skale-chain (4 Nodes)
    uint public constant NUMBER_OF_NODES_FOR_MEDIUM_TEST_SCHAIN = 4;    

    // number of seconds in one year
    uint32 public constant SECONDS_TO_YEAR = 31622400;

    // initial number of monitors
    uint public constant NUMBER_OF_MONITORS = 24;

    uint public constant OPTIMAL_LOAD_PERCENTAGE = 80;

    uint public constant ADJUSTMENT_SPEED = 1000;

    uint public constant COOLDOWN_TIME = 60;

    uint public constant MIN_PRICE = 10**6;

    uint public constant MSR_REDUCING_COEFFICIENT = 2;

    uint public constant DOWNTIME_THRESHOLD_PART = 30;

    uint public constant BOUNTY_LOCKUP_MONTHS = 2;

    // MSR - Minimum staking requirement
    uint public msr;

    // Reward period - 30 days (each 30 days Node would be granted for bounty)
    uint32 public rewardPeriod;

    // Allowable latency - 150000 ms by default
    uint32 public allowableLatency;

    /**
     * Delta period - 1 hour (1 hour before Reward period became Monitors need
     * to send Verdicts and 1 hour after Reward period became Node need to come
     * and get Bounty)
     */
    uint32 public deltaPeriod;

    /**
     * Check time - 2 minutes (every 2 minutes monitors should check metrics
     * from checked nodes)
     */
    uint public checkTime;

    //Need to add minimal allowed parameters for verdicts

    uint public launchTimestamp;

    uint public rotationDelay;

    uint public proofOfUseLockUpPeriodDays;

    uint public proofOfUseDelegationPercentage;

    uint public limitValidatorsPerDelegator;

    uint256 public firstDelegationsMonth; // deprecated

    // date when schains will be allowed for creation
    uint public schainCreationTimeStamp;

    uint public minimalSchainLifetime;

    /**
     * Set reward and delta periods to new one, run only by owner. This function
     * only for tests.
     * @param newRewardPeriod - new Reward period
     * @param newDeltaPeriod - new Delta period
     */
    function setPeriods(uint32 newRewardPeriod, uint32 newDeltaPeriod) external onlyOwner {
        require(
            newRewardPeriod >= newDeltaPeriod && newRewardPeriod - newDeltaPeriod >= checkTime,
            "Incorrect Periods"
        );
        rewardPeriod = newRewardPeriod;
        deltaPeriod = newDeltaPeriod;
    }

    /**
     * Set new check time. This function only for tests.
     * @param newCheckTime - new check time
     */
    function setCheckTime(uint newCheckTime) external onlyOwner {
        require(rewardPeriod - deltaPeriod >= checkTime, "Incorrect check time");
        checkTime = newCheckTime;
    }    

    /**
     * Set latency new one in ms, run only by owner. This function
     * only for tests.
     * @param newAllowableLatency - new Allowable Latency
     */
    function setLatency(uint32 newAllowableLatency) external onlyOwner {
        allowableLatency = newAllowableLatency;
    }

    function setMSR(uint newMSR) external onlyOwner {
        msr = newMSR;
    }

    function setLaunchTimestamp(uint timestamp) external onlyOwner {
        require(now < launchTimestamp, "Can't set network launch timestamp because network is already launched");
        launchTimestamp = timestamp;
    }

    function setRotationDelay(uint newDelay) external onlyOwner {
        rotationDelay = newDelay;
    }

    function setProofOfUseLockUpPeriod(uint periodDays) external onlyOwner {
        proofOfUseLockUpPeriodDays = periodDays;
    }

    function setProofOfUseDelegationPercentage(uint percentage) external onlyOwner {
        require(percentage <= 100, "Percentage value is incorrect");
        proofOfUseDelegationPercentage = percentage;
    }

    function setLimitValidatorsPerDelegator(uint newLimit) external onlyOwner {
        limitValidatorsPerDelegator = newLimit;
    }

    function setSchainCreationTimeStamp(uint timestamp) external onlyOwner {
        schainCreationTimeStamp = timestamp;
    }

    function setMinimalSchainLifetime(uint lifetime) external onlyOwner {
        minimalSchainLifetime = lifetime;
    }

    /**
     * @dev constructor in Permissions approach
     * @param contractsAddress needed in Permissions constructor
     */
    function initialize(address contractsAddress) public override initializer {
        Permissions.initialize(contractsAddress);

        msr = 0;
        rewardPeriod = 2592000;
        allowableLatency = 150000;
        deltaPeriod = 3600;
        checkTime = 300;
        launchTimestamp = uint(-1);
        rotationDelay = 12 hours;
        proofOfUseLockUpPeriodDays = 90;
        proofOfUseDelegationPercentage = 50;
        limitValidatorsPerDelegator = 20;
        firstDelegationsMonth = 0;
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    TokenState.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./Permissions.sol";
import "./DelegationController.sol";
import "./TimeHelpers.sol";
import "./ILocker.sol";


/**
 * @title Token State
 * @dev This contract manages lockers to control token transferability.
 *
 * See ILocker.
 */
contract TokenState is Permissions, ILocker {

    /**
     * @dev Emitted when a contract is added to the locker.
     */
    event LockerWasAdded(
        string locker
    );

    /**
     * @dev Emitted when a contract is removed from the locker.
     */
    event LockerWasRemoved(
        string locker
    );

    string[] private _lockers;

    /**
     *  @dev Return and update the total locked amount of a given `holder`.
     *
     *  @param holder address of the token holder
     *  @return total locked amount
    */
    function getAndUpdateLockedAmount(address holder) external override returns (uint) {
        uint locked = 0;
        for (uint i = 0; i < _lockers.length; ++i) {
            ILocker locker = ILocker(contractManager.getContract(_lockers[i]));
            locked = locked.add(locker.getAndUpdateLockedAmount(holder));
        }
        return locked;
    }

    /**
     * @dev Return and update the total locked and un-delegatable amount of a given `holder`.
     *
     * @param holder address of the token holder
     * @return amount total slashed amount (non-transferable and non-delegatable)
    */
    function getAndUpdateForbiddenForDelegationAmount(address holder) external override returns (uint amount) {
        uint forbidden = 0;
        for (uint i = 0; i < _lockers.length; ++i) {
            ILocker locker = ILocker(contractManager.getContract(_lockers[i]));
            forbidden = forbidden.add(locker.getAndUpdateForbiddenForDelegationAmount(holder));
        }
        return forbidden;
    }

    /**
     * @dev Allows the Owner to remove a contract from the locker.
     *
     * Emits a LockerWasRemoved event.
     *
     * @param locker string name of contract to remove from locker
     */
    function removeLocker(string calldata locker) external onlyOwner {
        uint index;
        bytes32 hash = keccak256(abi.encodePacked(locker));
        for (index = 0; index < _lockers.length; ++index) {
            if (keccak256(abi.encodePacked(_lockers[index])) == hash) {
                break;
            }
        }
        if (index < _lockers.length) {
            if (index < _lockers.length.sub(1)) {
                _lockers[index] = _lockers[_lockers.length.sub(1)];
            }
            delete _lockers[_lockers.length.sub(1)];
            _lockers.pop();
            emit LockerWasRemoved(locker);
        }
    }

    function initialize(address contractManagerAddress) public override initializer {
        Permissions.initialize(contractManagerAddress);
        addLocker("DelegationController");
        addLocker("Punisher");
        addLocker("TokenLaunchLocker");
    }

    /**
     * @dev Allows the Owner to add a contract to the Locker.
     *
     * Emits a LockerWasAdded event.
     *
     * @param locker string name of contract to add to locker
     */
    function addLocker(string memory locker) public onlyOwner {
        _lockers.push(locker);
        emit LockerWasAdded(locker);
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    PartialDifferences.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./MathUtils.sol";
import "./FractionUtils.sol";

/**
 * @title Partial Differences Library
 * @dev This library contains functions to manage Partial Differences data
 * structure. Partial Differences is an array of value differences over time.
 *
 * For example: assuming an array [3, 6, 3, 1, 2], partial differences can
 * represent this array as [_, 3, -3, -2, 1].
 *
 * This data structure allows adding values on an open interval with O(1)
 * complexity.
 *
 * For example: add +5 to [3, 6, 3, 1, 2] starting from the second element (3),
 * instead of performing [3, 6, 3+5, 1+5, 2+5] partial differences allows
 * performing [_, 3, -3+5, -2, 1]. The original array can be restored by
 * adding values from partial differences.
 */
library PartialDifferences {
    using SafeMath for uint;
    using MathUtils for uint;

    struct Sequence {
             // month => diff
        mapping (uint => uint) addDiff;
             // month => diff
        mapping (uint => uint) subtractDiff;
             // month => value
        mapping (uint => uint) value;

        uint firstUnprocessedMonth;
        uint lastChangedMonth;
    }

    struct Value {
             // month => diff
        mapping (uint => uint) addDiff;
             // month => diff
        mapping (uint => uint) subtractDiff;

        uint value;
        uint firstUnprocessedMonth;
        uint lastChangedMonth;
    }

    // functions for sequence

    function addToSequence(Sequence storage sequence, uint diff, uint month) internal {
        require(sequence.firstUnprocessedMonth <= month, "Cannot add to the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
        }
        sequence.addDiff[month] = sequence.addDiff[month].add(diff);
        if (sequence.lastChangedMonth != month) {
            sequence.lastChangedMonth = month;
        }
    }

    function subtractFromSequence(Sequence storage sequence, uint diff, uint month) internal {
        require(sequence.firstUnprocessedMonth <= month, "Cannot subtract from the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
        }
        sequence.subtractDiff[month] = sequence.subtractDiff[month].add(diff);
        if (sequence.lastChangedMonth != month) {
            sequence.lastChangedMonth = month;
        }
    }

    function getAndUpdateValueInSequence(Sequence storage sequence, uint month) internal returns (uint) {
        if (sequence.firstUnprocessedMonth == 0) {
            return 0;
        }

        if (sequence.firstUnprocessedMonth <= month) {
            for (uint i = sequence.firstUnprocessedMonth; i <= month; ++i) {
                uint nextValue = sequence.value[i.sub(1)].add(sequence.addDiff[i]).boundedSub(sequence.subtractDiff[i]);
                if (sequence.value[i] != nextValue) {
                    sequence.value[i] = nextValue;
                }
                if (sequence.addDiff[i] > 0) {
                    delete sequence.addDiff[i];
                }
                if (sequence.subtractDiff[i] > 0) {
                    delete sequence.subtractDiff[i];
                }
            }
            sequence.firstUnprocessedMonth = month.add(1);
        }

        return sequence.value[month];
    }

    function reduceSequence(
        Sequence storage sequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month) internal
    {
        require(month.add(1) >= sequence.firstUnprocessedMonth, "Can't reduce value in the past");
        require(
            reducingCoefficient.numerator <= reducingCoefficient.denominator,
            "Increasing of values is not implemented");
        if (sequence.firstUnprocessedMonth == 0) {
            return;
        }
        uint value = getAndUpdateValueInSequence(sequence, month);
        if (value.approximatelyEqual(0)) {
            return;
        }

        sequence.value[month] = sequence.value[month]
            .mul(reducingCoefficient.numerator)
            .div(reducingCoefficient.denominator);

        for (uint i = month.add(1); i <= sequence.lastChangedMonth; ++i) {
            sequence.subtractDiff[i] = sequence.subtractDiff[i]
                .mul(reducingCoefficient.numerator)
                .div(reducingCoefficient.denominator);
        }
    }

    // functions for value

    function addToValue(Value storage sequence, uint diff, uint month) internal {
        require(sequence.firstUnprocessedMonth <= month, "Cannot add to the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
            sequence.lastChangedMonth = month;
        }
        if (month > sequence.lastChangedMonth) {
            sequence.lastChangedMonth = month;
        }

        if (month >= sequence.firstUnprocessedMonth) {
            sequence.addDiff[month] = sequence.addDiff[month].add(diff);
        } else {
            sequence.value = sequence.value.add(diff);
        }
    }

    function subtractFromValue(Value storage sequence, uint diff, uint month) internal {
        require(sequence.firstUnprocessedMonth <= month.add(1), "Cannot subtract from the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
            sequence.lastChangedMonth = month;
        }
        if (month > sequence.lastChangedMonth) {
            sequence.lastChangedMonth = month;
        }

        if (month >= sequence.firstUnprocessedMonth) {
            sequence.subtractDiff[month] = sequence.subtractDiff[month].add(diff);
        } else {
            sequence.value = sequence.value.boundedSub(diff);
        }
    }

    function getAndUpdateValue(Value storage sequence, uint month) internal returns (uint) {
        require(
            month.add(1) >= sequence.firstUnprocessedMonth,
            "Cannot calculate value in the past");
        if (sequence.firstUnprocessedMonth == 0) {
            return 0;
        }

        if (sequence.firstUnprocessedMonth <= month) {
            for (uint i = sequence.firstUnprocessedMonth; i <= month; ++i) {
                uint newValue = sequence.value.add(sequence.addDiff[i]).boundedSub(sequence.subtractDiff[i]);
                if (sequence.value != newValue) {
                    sequence.value = newValue;
                }
                if (sequence.addDiff[i] > 0) {
                    delete sequence.addDiff[i];
                }
                if (sequence.subtractDiff[i] > 0) {
                    delete sequence.subtractDiff[i];
                }
            }
            sequence.firstUnprocessedMonth = month.add(1);
        }

        return sequence.value;
    }

    function reduceValue(
        Value storage sequence,
        uint amount,
        uint month)
        internal returns (FractionUtils.Fraction memory)
    {
        require(month.add(1) >= sequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        if (sequence.firstUnprocessedMonth == 0) {
            return FractionUtils.createFraction(0);
        }
        uint value = getAndUpdateValue(sequence, month);
        if (value.approximatelyEqual(0)) {
            return FractionUtils.createFraction(0);
        }

        uint _amount = amount;
        if (value < amount) {
            _amount = value;
        }

        FractionUtils.Fraction memory reducingCoefficient =
            FractionUtils.createFraction(value.boundedSub(_amount), value);
        reduceValueByCoefficient(sequence, reducingCoefficient, month);
        return reducingCoefficient;
    }

    function reduceValueByCoefficient(
        Value storage sequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month)
        internal
    {
        reduceValueByCoefficientAndUpdateSumIfNeeded(
            sequence,
            sequence,
            reducingCoefficient,
            month,
            false);
    }

    function reduceValueByCoefficientAndUpdateSum(
        Value storage sequence,
        Value storage sumSequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month) internal
    {
        reduceValueByCoefficientAndUpdateSumIfNeeded(
            sequence,
            sumSequence,
            reducingCoefficient,
            month,
            true);
    }

    function reduceValueByCoefficientAndUpdateSumIfNeeded(
        Value storage sequence,
        Value storage sumSequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month,
        bool hasSumSequence) internal
    {
        require(month.add(1) >= sequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        if (hasSumSequence) {
            require(month.add(1) >= sumSequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        }
        require(
            reducingCoefficient.numerator <= reducingCoefficient.denominator,
            "Increasing of values is not implemented");
        if (sequence.firstUnprocessedMonth == 0) {
            return;
        }
        uint value = getAndUpdateValue(sequence, month);
        if (value.approximatelyEqual(0)) {
            return;
        }

        uint newValue = sequence.value.mul(reducingCoefficient.numerator).div(reducingCoefficient.denominator);
        if (hasSumSequence) {
            subtractFromValue(sumSequence, sequence.value.boundedSub(newValue), month);
        }
        sequence.value = newValue;

        for (uint i = month.add(1); i <= sequence.lastChangedMonth; ++i) {
            uint newDiff = sequence.subtractDiff[i]
                .mul(reducingCoefficient.numerator)
                .div(reducingCoefficient.denominator);
            if (hasSumSequence) {
                sumSequence.subtractDiff[i] = sumSequence.subtractDiff[i]
                    .boundedSub(sequence.subtractDiff[i].boundedSub(newDiff));
            }
            sequence.subtractDiff[i] = newDiff;
        }
    }

    function clear(Value storage sequence) internal {
        for (uint i = sequence.firstUnprocessedMonth; i <= sequence.lastChangedMonth; ++i) {
            if (sequence.addDiff[i] > 0) {
                delete sequence.addDiff[i];
            }
            if (sequence.subtractDiff[i] > 0) {
                delete sequence.subtractDiff[i];
            }
        }
        if (sequence.value > 0) {
            delete sequence.value;
        }
        if (sequence.firstUnprocessedMonth > 0) {
            delete sequence.firstUnprocessedMonth;
        }
        if (sequence.lastChangedMonth > 0) {
            delete sequence.lastChangedMonth;
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    DelegationPeriodManager.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Dmytro Stebaiev
    @author Vadim Yavorsky

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./Permissions.sol";

/**
 * @title Delegation Period Manager
 * @dev This contract handles all delegation offerings. Delegations are held for
 * a specified period (months), and different durations can have different
 * returns or `stakeMultiplier`. Currently, only delegation periods can be added.
 */
contract DelegationPeriodManager is Permissions {

    /**
     * @dev Emitted when a new delegation period is specified.
     */
    event DelegationPeriodWasSet(
        uint length,
        uint stakeMultiplier
    );

    mapping (uint => uint) public stakeMultipliers;

    /**
     * @dev Creates a new available delegation period and return in the network.
     * Only the owner may set new delegation period and returns in the network.
     *
     * Emits a DelegationPeriodWasSet event.
     *
     * @param monthsCount uint delegation duration in months
     * @param stakeMultiplier uint return for delegation
     */
    function setDelegationPeriod(uint monthsCount, uint stakeMultiplier) external onlyOwner {
        stakeMultipliers[monthsCount] = stakeMultiplier;

        emit DelegationPeriodWasSet(monthsCount, stakeMultiplier);
    }

    /**
     * @dev Checks whether given delegation period is allowed.
     *
     * @param monthsCount uint delegation duration in months
     * @return bool True if delegation period is allowed
     */
    function isDelegationPeriodAllowed(uint monthsCount) external view returns (bool) {
        return stakeMultipliers[monthsCount] != 0 ? true : false;
    }

    /**
     * @dev Initial delegation period and multiplier settings.
     */
    function initialize(address contractsAddress) public override initializer {
        Permissions.initialize(contractsAddress);
        stakeMultipliers[3] = 100;  // 3 months at 100
        // stakeMultipliers[6] = 150;  // 6 months at 150
        // stakeMultipliers[12] = 200; // 12 months at 200
    }
}
pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    Monitors.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./SafeCast.sol";

import "./ConstantsHolder.sol";
import "./Nodes.sol";

contract Monitors is Permissions {

    using StringUtils for string;
    using SafeCast for uint;

    struct Verdict {
        uint toNodeIndex;
        uint32 downtime;
        uint32 latency;
    }

    struct CheckedNode {
        uint nodeIndex;
        uint time;
    }

    struct CheckedNodeWithIp {
        uint nodeIndex;
        uint time;
        bytes4 ip;
    }

    mapping (bytes32 => CheckedNode[]) public checkedNodes;
    mapping (bytes32 => uint[][]) public verdicts;

    mapping (bytes32 => uint[]) public groupsForMonitors;

    mapping (bytes32 => uint) public lastVerdictBlocks;
    mapping (bytes32 => uint) public lastBountyBlocks;


    event MonitorCreated(
        uint nodeIndex,
        bytes32 monitorIndex,
        uint numberOfMonitors,
        uint[] nodesInGroup,
        uint time,
        uint gasSpend
    );

    event VerdictWasSent(
        uint indexed fromMonitorIndex,
        uint indexed toNodeIndex,
        uint32 downtime,
        uint32 latency,
        bool status,
        uint previousBlockEvent,
        uint time,
        uint gasSpend
    );

    event MetricsWereCalculated(
        uint forNodeIndex,
        uint32 averageDowntime,
        uint32 averageLatency,
        uint time,
        uint gasSpend
    );

    event PeriodsWereSet(
        uint rewardPeriod,
        uint deltaPeriod,
        uint time,
        uint gasSpend
    );


    event MonitorRotated(
        bytes32 monitorIndex,
        uint newNode
    );

    /**
     * addMonitor - setup monitors of node
     */
    function addMonitor(uint nodeIndex) external allow("SkaleManager") {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        bytes32 monitorIndex = keccak256(abi.encodePacked(nodeIndex));
        _generateGroup(monitorIndex, nodeIndex, constantsHolder.NUMBER_OF_MONITORS());
        CheckedNode memory checkedNode = _getCheckedNodeData(nodeIndex);
        for (uint i = 0; i < groupsForMonitors[monitorIndex].length; i++) {
            bytes32 index = keccak256(abi.encodePacked(groupsForMonitors[monitorIndex][i]));
            addCheckedNode(index, checkedNode);
        }

        emit MonitorCreated(
            nodeIndex,
            monitorIndex,
            groupsForMonitors[monitorIndex].length,
            groupsForMonitors[monitorIndex],
            block.timestamp,
            gasleft()
        );
    }

    function deleteMonitor(uint nodeIndex) external allow("SkaleManager") {
        bytes32 monitorIndex = keccak256(abi.encodePacked(nodeIndex));
        while (verdicts[keccak256(abi.encodePacked(nodeIndex))].length > 0) {
            verdicts[keccak256(abi.encodePacked(nodeIndex))].pop();
        }
        uint[] memory nodesInGroup = groupsForMonitors[monitorIndex];
        uint index;
        bytes32 monitoringIndex;
        for (uint i = 0; i < nodesInGroup.length; i++) {
            monitoringIndex = keccak256(abi.encodePacked(nodesInGroup[i]));
            (index, ) = _find(monitoringIndex, nodeIndex);
            if (index < checkedNodes[monitoringIndex].length) {
                if (index != checkedNodes[monitoringIndex].length.sub(1)) {
                    checkedNodes[monitoringIndex][index] =
                        checkedNodes[monitoringIndex][checkedNodes[monitoringIndex].length.sub(1)];
                }
                checkedNodes[monitoringIndex].pop();
            }
        }
        delete groupsForMonitors[monitorIndex];
    }

    function removeCheckedNodes(uint nodeIndex) external allow("SkaleManager") {
        bytes32 monitorIndex = keccak256(abi.encodePacked(nodeIndex));
        delete checkedNodes[monitorIndex];
    }

    function sendVerdict(uint fromMonitorIndex, Verdict calldata verdict) external allow("SkaleManager") {
        uint index;
        uint time;
        bytes32 monitorIndex = keccak256(abi.encodePacked(fromMonitorIndex));
        (index, time) = _find(monitorIndex, verdict.toNodeIndex);
        require(time > 0, "Checked Node does not exist in MonitorsArray");
        if (time <= block.timestamp) {
            if (index != checkedNodes[monitorIndex].length.sub(1)) {
                checkedNodes[monitorIndex][index] = 
                    checkedNodes[monitorIndex][checkedNodes[monitorIndex].length.sub(1)];
            }
            delete checkedNodes[monitorIndex][checkedNodes[monitorIndex].length.sub(1)];
            checkedNodes[monitorIndex].pop();
            ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
            bool receiveVerdict = time.add(constantsHolder.deltaPeriod()) > block.timestamp;
            if (receiveVerdict) {
                verdicts[keccak256(abi.encodePacked(verdict.toNodeIndex))].push(
                    [uint(verdict.downtime), uint(verdict.latency)]
                );
            }
            _emitVerdictsEvent(fromMonitorIndex, verdict, receiveVerdict);
        }
    }

    function calculateMetrics(uint nodeIndex)
        external
        allow("SkaleManager")
        returns (uint averageDowntime, uint averageLatency)
    {
        bytes32 monitorIndex = keccak256(abi.encodePacked(nodeIndex));
        uint lengthOfArray = getLengthOfMetrics(monitorIndex);
        uint[] memory downtimeArray = new uint[](lengthOfArray);
        uint[] memory latencyArray = new uint[](lengthOfArray);
        for (uint i = 0; i < lengthOfArray; i++) {
            downtimeArray[i] = verdicts[monitorIndex][i][0];
            latencyArray[i] = verdicts[monitorIndex][i][1];
        }
        if (lengthOfArray > 0) {
            averageDowntime = _median(downtimeArray);
            averageLatency = _median(latencyArray);
        }
        delete verdicts[monitorIndex];
    }

    function setLastBountyBlock(uint nodeIndex) external allow("SkaleManager") {
        lastBountyBlocks[keccak256(abi.encodePacked(nodeIndex))] = block.number;
    }

    function getCheckedArray(bytes32 monitorIndex)
        external
        view
        returns (CheckedNodeWithIp[] memory checkedNodesWithIp)
    {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        checkedNodesWithIp = new CheckedNodeWithIp[](checkedNodes[monitorIndex].length);
        for (uint i = 0; i < checkedNodes[monitorIndex].length; ++i) {
            checkedNodesWithIp[i].nodeIndex = checkedNodes[monitorIndex][i].nodeIndex;
            checkedNodesWithIp[i].time = checkedNodes[monitorIndex][i].time;
            checkedNodesWithIp[i].ip = nodes.getNodeIP(checkedNodes[monitorIndex][i].nodeIndex);
        }
    }

    function getLastBountyBlock(uint nodeIndex) external view returns (uint) {
        return lastBountyBlocks[keccak256(abi.encodePacked(nodeIndex))];
    }

    function getNodesInGroup(bytes32 monitorIndex) external view returns (uint[] memory) {
        return groupsForMonitors[monitorIndex];
    }

    function getNumberOfNodesInGroup(bytes32 monitorIndex) external view returns (uint) {
        return groupsForMonitors[monitorIndex].length;
    }

    function initialize(address newContractsAddress) public override initializer {
        Permissions.initialize(newContractsAddress);
    }

    /**
     *  Add checked node or update existing one if it is already exits
     */
    function addCheckedNode(bytes32 monitorIndex, CheckedNode memory checkedNode) public allow("SkaleManager") {
        for (uint i = 0; i < checkedNodes[monitorIndex].length; ++i) {
            if (checkedNodes[monitorIndex][i].nodeIndex == checkedNode.nodeIndex) {
                checkedNodes[monitorIndex][i] = checkedNode;
                return;
            }
        }
        checkedNodes[monitorIndex].push(checkedNode);
    }

    function getLastReceivedVerdictBlock(uint nodeIndex) public view returns (uint) {
        return lastVerdictBlocks[keccak256(abi.encodePacked(nodeIndex))];
    }

    function getLengthOfMetrics(bytes32 monitorIndex) public view returns (uint) {
        return verdicts[monitorIndex].length;
    }

    function _generateGroup(bytes32 monitorIndex, uint nodeIndex, uint numberOfNodes)
        private
    {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint[] memory activeNodes = nodes.getActiveNodeIds();
        uint numberOfNodesInGroup;
        uint availableAmount = activeNodes.length.sub((nodes.isNodeActive(nodeIndex)) ? 1 : 0);
        if (numberOfNodes > availableAmount) {
            numberOfNodesInGroup = availableAmount;
        } else {
            numberOfNodesInGroup = numberOfNodes;
        }
        uint ignoringTail = 0;
        uint random = uint(keccak256(abi.encodePacked(uint(blockhash(block.number.sub(1))), monitorIndex)));
        for (uint i = 0; i < numberOfNodesInGroup; ++i) {
            uint index = random % (activeNodes.length.sub(ignoringTail));
            if (activeNodes[index] == nodeIndex) {
                _swap(activeNodes, index, activeNodes.length.sub(ignoringTail).sub(1));
                ++ignoringTail;
                index = random % (activeNodes.length.sub(ignoringTail));
            }
            groupsForMonitors[monitorIndex].push(activeNodes[index]);
            _swap(activeNodes, index, activeNodes.length.sub(ignoringTail).sub(1));
            ++ignoringTail;
        }
    }

    function _median(uint[] memory values) private pure returns (uint) {
        if (values.length < 1) {
            revert("Can't calculate _median of empty array");
        }
        _quickSort(values, 0, values.length.sub(1));
        return values[values.length.div(2)];
    }

    function _swap(uint[] memory array, uint index1, uint index2) private pure {
        uint buffer = array[index1];
        array[index1] = array[index2];
        array[index2] = buffer;
    }

    function _find(bytes32 monitorIndex, uint nodeIndex) private view returns (uint index, uint time) {
        index = checkedNodes[monitorIndex].length;
        time = 0;
        for (uint i = 0; i < checkedNodes[monitorIndex].length; i++) {
            uint checkedNodeNodeIndex;
            uint checkedNodeTime;
            checkedNodeNodeIndex = checkedNodes[monitorIndex][i].nodeIndex;
            checkedNodeTime = checkedNodes[monitorIndex][i].time;
            if (checkedNodeNodeIndex == nodeIndex && (time == 0 || checkedNodeTime < time))
            {
                index = i;
                time = checkedNodeTime;
            }
        }
    }

    function _quickSort(uint[] memory array, uint left, uint right) private pure {
        uint leftIndex = left;
        uint rightIndex = right;
        uint middle = array[right.add(left).div(2)];
        while (leftIndex <= rightIndex) {
            while (array[leftIndex] < middle) {
                leftIndex++;
                }
            while (middle < array[rightIndex]) {
                rightIndex--;
                }
            if (leftIndex <= rightIndex) {
                (array[leftIndex], array[rightIndex]) = (array[rightIndex], array[leftIndex]);
                leftIndex++;
                rightIndex = (rightIndex > 0 ? rightIndex.sub(1) : 0);
            }
        }
        if (left < rightIndex)
            _quickSort(array, left, rightIndex);
        if (leftIndex < right)
            _quickSort(array, leftIndex, right);
    }

    function _getCheckedNodeData(uint nodeIndex) private view returns (CheckedNode memory checkedNode) {
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));

        checkedNode.nodeIndex = nodeIndex;
        checkedNode.time = nodes.getNodeNextRewardDate(nodeIndex).sub(constantsHolder.deltaPeriod());
    }

    function _emitVerdictsEvent(
        uint fromMonitorIndex,
        Verdict memory verdict,
        bool receiveVerdict
    )
        private
    {
        uint previousBlockEvent = getLastReceivedVerdictBlock(verdict.toNodeIndex);
        lastVerdictBlocks[keccak256(abi.encodePacked(verdict.toNodeIndex))] = block.number;

        emit VerdictWasSent(
                fromMonitorIndex,
                verdict.toNodeIndex,
                verdict.downtime,
                verdict.latency,
                receiveVerdict,
                previousBlockEvent,
                block.timestamp,
                gasleft()
            );
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    ECDH.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR _A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
import "./SafeMath.sol";


contract ECDH {
    using SafeMath for uint256;

    uint256 constant private _GX = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint256 constant private _GY = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    uint256 constant private _N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    uint256 constant private _A = 0;

    function publicKey(uint256 privKey) external pure returns (uint256 qx, uint256 qy) {
        uint256 x;
        uint256 y;
        uint256 z;
        (x, y, z) = ecMul(
            privKey,
            _GX,
            _GY,
            1
        );
        z = inverse(z);
        qx = mulmod(x, z, _N);
        qy = mulmod(y, z, _N);
    }

    function deriveKey(
        uint256 privKey,
        uint256 pubX,
        uint256 pubY
    )
        external
        pure
        returns (uint256 qx, uint256 qy)
    {
        uint256 x;
        uint256 y;
        uint256 z;
        (x, y, z) = ecMul(
            privKey,
            pubX,
            pubY,
            1
        );
        z = inverse(z);
        qx = mulmod(x, z, _N);
        qy = mulmod(y, z, _N);
    }

    function jAdd(
        uint256 x1,
        uint256 z1,
        uint256 x2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 z3)
    {
        (x3, z3) = (addmod(mulmod(z2, x1, _N), mulmod(x2, z1, _N), _N), mulmod(z1, z2, _N));
    }

    function jSub(
        uint256 x1,
        uint256 z1,
        uint256 x2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 z3)
    {
        (x3, z3) = (addmod(mulmod(z2, x1, _N), mulmod(_N.sub(x2), z1, _N), _N), mulmod(z1, z2, _N));
    }

    function jMul(
        uint256 x1,
        uint256 z1,
        uint256 x2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 z3)
    {
        (x3, z3) = (mulmod(x1, x2, _N), mulmod(z1, z2, _N));
    }

    function jDiv(
        uint256 x1,
        uint256 z1,
        uint256 x2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 z3)
    {
        (x3, z3) = (mulmod(x1, z2, _N), mulmod(z1, x2, _N));
    }

    function inverse(uint256 a) public pure returns (uint256 invA) {
        uint256 t = 0;
        uint256 newT = 1;
        uint256 r = _N;
        uint256 newR = a;
        uint256 q;
        while (newR != 0) {
            q = r.div(newR);
            (t, newT) = (newT, addmod(t, (_N.sub(mulmod(q, newT, _N))), _N));
            (r, newR) = (newR, r % newR);
        }
        return t;
    }

    function ecAdd(
        uint256 x1,
        uint256 y1,
        uint256 z1,
        uint256 x2,
        uint256 y2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 y3, uint256 z3)
    {
        uint256 ln;
        uint256 lz;
        uint256 da;
        uint256 db;

        if ((x1 == 0) && (y1 == 0)) {
            return (x2, y2, z2);
        }

        if ((x2 == 0) && (y2 == 0)) {
            return (x1, y1, z1);
        }

        if ((x1 == x2) && (y1 == y2)) {
            (ln, lz) = jMul(x1, z1, x1, z1);
            (ln, lz) = jMul(ln,lz,3,1);
            (ln, lz) = jAdd(ln,lz,_A,1);
            (da, db) = jMul(y1,z1,2,1);
        } else {
            (ln, lz) = jSub(y2,z2,y1,z1);
            (da, db) = jSub(x2,z2,x1,z1);
        }
        (ln, lz) = jDiv(ln,lz,da,db);

        (x3, da) = jMul(ln,lz,ln,lz);
        (x3, da) = jSub(x3,da,x1,z1);
        (x3, da) = jSub(x3,da,x2,z2);

        (y3, db) = jSub(x1,z1,x3,da);
        (y3, db) = jMul(y3,db,ln,lz);
        (y3, db) = jSub(y3,db,y1,z1);

        if (da != db) {
            x3 = mulmod(x3, db, _N);
            y3 = mulmod(y3, da, _N);
            z3 = mulmod(da, db, _N);
        } else {
            z3 = da;
        }
    }

    function ecDouble(
        uint256 x1,
        uint256 y1,
        uint256 z1
    )
        public
        pure
        returns (uint256 x3, uint256 y3, uint256 z3)
    {
        (x3, y3, z3) = ecAdd(
            x1,
            y1,
            z1,
            x1,
            y1,
            z1
        );
    }

    function ecMul(
        uint256 d,
        uint256 x1,
        uint256 y1,
        uint256 z1
    )
        public
        pure
        returns (uint256 x3, uint256 y3, uint256 z3)
    {
        uint256 remaining = d;
        uint256 px = x1;
        uint256 py = y1;
        uint256 pz = z1;
        uint256 acx = 0;
        uint256 acy = 0;
        uint256 acz = 1;

        if (d == 0) {
            return (0, 0, 1);
        }

        while (remaining != 0) {
            if ((remaining & 1) != 0) {
                (acx, acy, acz) = ecAdd(
                    acx,
                    acy,
                    acz,
                    px,
                    py,
                    pz
                );
            }
            remaining = remaining.div(2);
            (px, py, pz) = ecDouble(px, py, pz);
        }

        (x3, y3, z3) = (acx, acy, acz);
    }
}

pragma solidity ^0.6.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

pragma solidity ^0.6.0;

import "./Context.sol";
import "./Initializable.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    Permissions.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./SafeMath.sol";
import "./AccessControl.sol";

import "./ContractManager.sol";


/**
 * @title Permissions - connected module for Upgradeable approach, knows ContractManager
 * @author Artem Payvin
 */
contract Permissions is AccessControlUpgradeSafe {
    using SafeMath for uint;
    using Address for address;
    
    ContractManager public contractManager;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_isOwner(), "Caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(_isAdmin(msg.sender), "Caller is not an admin");
        _;
    }

    /**
     * @dev allow - throws if called by any account and contract other than the owner
     * or `contractName` contract
     * @param contractName - human readable name of contract
     */
    modifier allow(string memory contractName) {
        require(
            contractManager.contracts(keccak256(abi.encodePacked(contractName))) == msg.sender || _isOwner(),
            "Message sender is invalid");
        _;
    }

    modifier allowTwo(string memory contractName1, string memory contractName2) {
        require(
            contractManager.contracts(keccak256(abi.encodePacked(contractName1))) == msg.sender ||
            contractManager.contracts(keccak256(abi.encodePacked(contractName2))) == msg.sender ||
            _isOwner(),
            "Message sender is invalid");
        _;
    }

    modifier allowThree(string memory contractName1, string memory contractName2, string memory contractName3) {
        require(
            contractManager.contracts(keccak256(abi.encodePacked(contractName1))) == msg.sender ||
            contractManager.contracts(keccak256(abi.encodePacked(contractName2))) == msg.sender ||
            contractManager.contracts(keccak256(abi.encodePacked(contractName3))) == msg.sender ||
            _isOwner(),
            "Message sender is invalid");
        _;
    }

    function initialize(address contractManagerAddress) public virtual initializer {
        AccessControlUpgradeSafe.__AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setContractManager(contractManagerAddress);
    }

    function _isOwner() internal view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _isAdmin(address account) internal view returns (bool) {
        address skaleManagerAddress = contractManager.contracts(keccak256(abi.encodePacked("SkaleManager")));
        if (skaleManagerAddress != address(0)) {
            AccessControlUpgradeSafe skaleManager = AccessControlUpgradeSafe(skaleManagerAddress);
            return skaleManager.hasRole(keccak256("ADMIN_ROLE"), account) || _isOwner();
        } else {
            return _isOwner();
        }
    }

    function _setContractManager(address contractManagerAddress) private {
        require(contractManagerAddress != address(0), "ContractManager address is not set");
        require(contractManagerAddress.isContract(), "Address is not contract");
        contractManager = ContractManager(contractManagerAddress);
    }
}

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    ILocker.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

/**
 * @dev Interface of Locker functions of the {TokenState} contract.
 *
 * The SKALE Network has three types of locked tokens:
 *
 * - Tokens that are transferrable but are currently locked into delegation with
 * a validator. See {DelegationController};
 *
 * - Tokens that are not transferable from one address to another, but may be
 * delegated to a validator {getAndUpdateLockedAmount}. This lock enforces
 * Proof-of-Use requirements. See {TokenLaunchLocker}; and,
 *
 * - Tokens that are neither transferable nor delegatable
 * {getAndUpdateForbiddenForDelegationAmount}. This lock enforces slashing.
 * See {Punisher}.
 */
interface ILocker {
    /**
     * @dev Returns the locked amount of untransferable tokens of a given `wallet`
     */
    function getAndUpdateLockedAmount(address wallet) external returns (uint);

    /**
     * @dev Returns the locked amount of untransferable and un-delegatable tokens of a given `wallet`.
     */
    function getAndUpdateForbiddenForDelegationAmount(address wallet) external returns (uint);
}

pragma solidity ^0.6.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    ISkaleDKG.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

interface ISkaleDKG {
    function openChannel(bytes32 schainId) external;
    function deleteChannel(bytes32 schainId) external;
    function isLastDKGSuccesful(bytes32 groupIndex) external view returns (bool);
    function isChannelOpened(bytes32 schainId) external view returns (bool);
}
pragma solidity ^0.6.0;

import "./EnumerableSet.sol";
import "./Address.sol";
import "./Context.sol";
import "./Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, _msgSender()));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 */
abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    NodeRotation.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Vadim Yavorsky

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./Permissions.sol";
import "./ConstantsHolder.sol";
import "./SchainsInternal.sol";
import "./Schains.sol";
import "./Nodes.sol";
import "./ISkaleDKG.sol";


contract NodeRotation is Permissions {
    using StringUtils for string;
    using StringUtils for uint;

    /**
     * nodeIndex - index of Node which is in process of rotation(left from schain)
     * newNodeIndex - index of Node which is rotated(added to schain)
     * freezeUntil - time till which Node should be turned on
     * rotationCounter - how many rotations were on this schain
     */
    struct Rotation {
        uint nodeIndex;
        uint newNodeIndex;
        uint freezeUntil;
        uint rotationCounter;
    }

    struct LeavingHistory {
        bytes32 schainIndex;
        uint finishedRotation;
    }

    mapping (bytes32 => Rotation) public rotations;

    mapping (uint => LeavingHistory[]) public leavingHistory;

    mapping (bytes32 => bool) public waitForNewNode;


    function exitFromSchain(uint nodeIndex) external allow("SkaleManager") returns (bool) {
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        bytes32 schainId = schainsInternal.getActiveSchain(nodeIndex);
        require(_checkRotation(schainId), "No any free Nodes for rotating");
        rotateNode(nodeIndex, schainId, true);
        return schainsInternal.getActiveSchain(nodeIndex) == bytes32(0) ? true : false;
    }

    function freezeSchains(uint nodeIndex) external allow("SkaleManager") {
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        bytes32[] memory schains = schainsInternal.getActiveSchains(nodeIndex);
        for (uint i = 0; i < schains.length; i++) {
            Rotation memory rotation = rotations[schains[i]];
            if (rotation.nodeIndex == nodeIndex && now < rotation.freezeUntil) {
                continue;
            }
            string memory schainName = schainsInternal.getSchainName(schains[i]);
            string memory revertMessage = "Node cannot rotate on Schain ";
            revertMessage = revertMessage.strConcat(schainName);
            revertMessage = revertMessage.strConcat(", occupied by Node ");
            revertMessage = revertMessage.strConcat(rotation.nodeIndex.uint2str());
            string memory dkgRevert = "DKG proccess did not finish on schain ";
            ISkaleDKG skaleDKG = ISkaleDKG(contractManager.getContract("SkaleDKG"));
            require(
                skaleDKG.isLastDKGSuccesful(keccak256(abi.encodePacked(schainName))),
                dkgRevert.strConcat(schainName));
            require(rotation.freezeUntil < now, revertMessage);
            _startRotation(schains[i], nodeIndex);
        }
    }


    function removeRotation(bytes32 schainIndex) external allow("Schains") {
        delete rotations[schainIndex];
    }

    function skipRotationDelay(bytes32 schainIndex) external onlyOwner {
        rotations[schainIndex].freezeUntil = now;
    }

    function getRotation(bytes32 schainIndex) external view returns (Rotation memory) {
        return rotations[schainIndex];
    }

    function getLeavingHistory(uint nodeIndex) external view returns (LeavingHistory[] memory) {
        return leavingHistory[nodeIndex];
    }

    function isRotationInProgress(bytes32 schainIndex) external view returns (bool) {
        return rotations[schainIndex].freezeUntil >= now && !waitForNewNode[schainIndex];
    }

    function initialize(address newContractsAddress) public override initializer {
        Permissions.initialize(newContractsAddress);
    }

    function rotateNode(
        uint nodeIndex,
        bytes32 schainId,
        bool shouldDelay
    )
        public
        allowTwo("SkaleDKG", "SkaleManager")
        returns (uint newNode)
    {
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        Schains schains = Schains(contractManager.getContract("Schains"));
        schainsInternal.removeNodeFromSchain(nodeIndex, schainId);
        newNode = selectNodeToGroup(schainId);
        uint8 space = schainsInternal.getSchainsPartOfNode(schainId);
        schains.addSpace(nodeIndex, space);
        _finishRotation(schainId, nodeIndex, newNode, shouldDelay);
    }

    /**
     * @dev selectNodeToGroup - pseudo-randomly select new Node for Schain
     * @param schainId - hash of name of Schain
     * @return nodeIndex - global index of Node
     */
    function selectNodeToGroup(bytes32 schainId)
        public
        allowThree("SkaleManager", "Schains", "SkaleDKG")
        returns (uint)
    {
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        require(schainsInternal.isSchainActive(schainId), "Group is not active");
        uint8 space = schainsInternal.getSchainsPartOfNode(schainId);
        uint[] memory possibleNodes = schainsInternal.isEnoughNodes(schainId);
        require(possibleNodes.length > 0, "No any free Nodes for rotation");
        uint nodeIndex;
        uint random = uint(keccak256(abi.encodePacked(uint(blockhash(block.number - 1)), schainId)));
        do {
            uint index = random % possibleNodes.length;
            nodeIndex = possibleNodes[index];
            random = uint(keccak256(abi.encodePacked(random, nodeIndex)));
        } while (schainsInternal.checkException(schainId, nodeIndex));
        require(nodes.removeSpaceFromNode(nodeIndex, space), "Could not remove space from nodeIndex");
        schainsInternal.addSchainForNode(nodeIndex, schainId);
        schainsInternal.setException(schainId, nodeIndex);
        schainsInternal.setNodeInGroup(schainId, nodeIndex);
        return nodeIndex;
    }


    function _startRotation(bytes32 schainIndex, uint nodeIndex) private {
        ConstantsHolder constants = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        rotations[schainIndex].nodeIndex = nodeIndex;
        rotations[schainIndex].newNodeIndex = nodeIndex;
        rotations[schainIndex].freezeUntil = now.add(constants.rotationDelay());
        waitForNewNode[schainIndex] = true;
    }

    function _finishRotation(
        bytes32 schainIndex,
        uint nodeIndex,
        uint newNodeIndex,
        bool shouldDelay)
        private
    {
        ConstantsHolder constants = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        leavingHistory[nodeIndex].push(
            LeavingHistory(schainIndex, shouldDelay ? now.add(constants.rotationDelay()) : now)
        );
        rotations[schainIndex].newNodeIndex = newNodeIndex;
        rotations[schainIndex].rotationCounter++;
        delete waitForNewNode[schainIndex];
        ISkaleDKG(contractManager.getContract("SkaleDKG")).openChannel(schainIndex);
    }

    function _checkRotation(bytes32 schainId ) private view returns (bool) {
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        require(schainsInternal.isSchainExist(schainId), "Schain does not exist for rotation");
        return schainsInternal.isAnyFreeNode(schainId);
    }


}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    SkaleVerifier.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./Permissions.sol";
import "./SchainsInternal.sol";
import "./Precompiled.sol";
import "./FieldOperations.sol";


contract SkaleVerifier is Permissions {  
    using Fp2Operations for Fp2Operations.Fp2Point;

    function verify(
        Fp2Operations.Fp2Point calldata signature,
        bytes32 hash,
        uint counter,
        uint hashA,
        uint hashB,
        G2Operations.G2Point calldata publicKey
    )
        external
        view
        returns (bool)
    {
        if (!_checkHashToGroupWithHelper(
            hash,
            counter,
            hashA,
            hashB
            )
        )
        {
            return false;
        }

        uint newSignB;
        if (!(signature.a == 0 && signature.b == 0)) {
            newSignB = Fp2Operations.P.sub((signature.b % Fp2Operations.P));
        } else {
            newSignB = signature.b;
        }

        require(G2Operations.isG1Point(signature.a, newSignB), "Sign not in G1");
        require(G2Operations.isG1Point(hashA, hashB), "Hash not in G1");

        G2Operations.G2Point memory g2 = G2Operations.getG2();
        require(
            G2Operations.isG2(publicKey),
            "Public Key not in G2"
        );

        return Precompiled.bn256Pairing(
            signature.a, newSignB,
            g2.x.b, g2.x.a, g2.y.b, g2.y.a,
            hashA, hashB,
            publicKey.x.b, publicKey.x.a, publicKey.y.b, publicKey.y.a
        );
    }

    function initialize(address newContractsAddress) public override initializer {
        Permissions.initialize(newContractsAddress);
    }

    function _checkHashToGroupWithHelper(
        bytes32 hash,
        uint counter,
        uint hashA,
        uint hashB
    )
        private
        pure
        returns (bool)
    {
        uint xCoord = uint(hash) % Fp2Operations.P;
        xCoord = (xCoord.add(counter)) % Fp2Operations.P;

        uint ySquared = addmod(
            mulmod(mulmod(xCoord, xCoord, Fp2Operations.P), xCoord, Fp2Operations.P),
            3,
            Fp2Operations.P
        );
        if (hashB < Fp2Operations.P.div(2) || mulmod(hashB, hashB, Fp2Operations.P) != ySquared || xCoord != hashA) {
            return false;
        }

        return true;
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    KeyStorage.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;
import "./Decryption.sol";
import "./Permissions.sol";
import "./SchainsInternal.sol";
import "./ECDH.sol";
import "./Precompiled.sol";
import "./FieldOperations.sol";

contract KeyStorage is Permissions {
    using Fp2Operations for Fp2Operations.Fp2Point;
    using G2Operations for G2Operations.G2Point;

    struct BroadcastedData {
        KeyShare[] secretKeyContribution;
        G2Operations.G2Point[] verificationVector;
    }

    struct KeyShare {
        bytes32[2] publicKey;
        bytes32 share;
    }

    // Unused variable!!
    mapping(bytes32 => mapping(uint => BroadcastedData)) private _data;
    // 
    
    mapping(bytes32 => G2Operations.G2Point) private _publicKeysInProgress;
    mapping(bytes32 => G2Operations.G2Point) private _schainsPublicKeys;

    // Unused variable
    mapping(bytes32 => G2Operations.G2Point[]) private _schainsNodesPublicKeys;
    //

    mapping(bytes32 => G2Operations.G2Point[]) private _previousSchainsPublicKeys;

    function deleteKey(bytes32 groupIndex) external allow("SkaleDKG") {
        _previousSchainsPublicKeys[groupIndex].push(_schainsPublicKeys[groupIndex]);
        delete _schainsPublicKeys[groupIndex];
    }

    function initPublicKeyInProgress(bytes32 groupIndex) external allow("SkaleDKG") {
        _publicKeysInProgress[groupIndex] = G2Operations.getG2Zero();
    }

    function adding(bytes32 groupIndex, G2Operations.G2Point memory value) external allow("SkaleDKG") {
        require(value.isG2(), "Incorrect g2 point");
        _publicKeysInProgress[groupIndex] = value.addG2(_publicKeysInProgress[groupIndex]);
    }

    function finalizePublicKey(bytes32 groupIndex) external allow("SkaleDKG") {
        if (!_isSchainsPublicKeyZero(groupIndex)) {
            _previousSchainsPublicKeys[groupIndex].push(_schainsPublicKeys[groupIndex]);
        }
        _schainsPublicKeys[groupIndex] = _publicKeysInProgress[groupIndex];
        delete _publicKeysInProgress[groupIndex];
    }

    function getCommonPublicKey(bytes32 groupIndex) external view returns (G2Operations.G2Point memory) {
        return _schainsPublicKeys[groupIndex];
    }

    function getPreviousPublicKey(bytes32 groupIndex) external view returns (G2Operations.G2Point memory) {
        uint length = _previousSchainsPublicKeys[groupIndex].length;
        if (length == 0) {
            return G2Operations.getG2Zero();
        }
        return _previousSchainsPublicKeys[groupIndex][length - 1];
    }

    function getAllPreviousPublicKeys(bytes32 groupIndex) external view returns (G2Operations.G2Point[] memory) {
        return _previousSchainsPublicKeys[groupIndex];
    }

    function initialize(address contractsAddress) public override initializer {
        Permissions.initialize(contractsAddress);
    }

    function _isSchainsPublicKeyZero(bytes32 schainId) private view returns (bool) {
        return _schainsPublicKeys[schainId].x.a == 0 &&
            _schainsPublicKeys[schainId].x.b == 0 &&
            _schainsPublicKeys[schainId].y.a == 0 &&
            _schainsPublicKeys[schainId].y.b == 0;
    }

    function _getData() private view returns (BroadcastedData memory) {
        return _data[keccak256(abi.encodePacked("UnusedFunction"))][0];
    }

    function _getNodesPublicKey() private view returns (G2Operations.G2Point memory) {
        return _schainsNodesPublicKeys[keccak256(abi.encodePacked("UnusedFunction"))][0];
    }
}
pragma solidity ^0.6.0;

/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */
interface IERC1820Registry {
    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a {ManagerChanged} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See {setManager}.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as ``account``'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See {interfaceHash} to learn how these are created.
     *
     * Emits an {InterfaceImplementerSet} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an {IERC165} interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement {IERC1820Implementer} and return true when
     * queried for support, unless `implementer` is the caller. See
     * {IERC1820Implementer-canImplementInterfaceForAddress}.
     */
    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an {IERC165} interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * https://eips.ethereum.org/EIPS/eip-1820#interface-name[section of the EIP].
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     *  @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     *  @param account Address of the contract for which to update the cache.
     *  @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     *  @notice Checks whether a contract implements an ERC165 interface or not.
     *  If the result is not cached a direct lookup on the contract address is performed.
     *  If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     *  {updateERC165Cache} with the contract address.
     *  @param account Address of the contract to check.
     *  @param interfaceId ERC165 interface to check.
     *  @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     *  @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     *  @param account Address of the contract to check.
     *  @param interfaceId ERC165 interface to check.
     *  @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    FractionUtils.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./SafeMath.sol";


library FractionUtils {
    using SafeMath for uint;

    struct Fraction {
        uint numerator;
        uint denominator;
    }

    function createFraction(uint numerator, uint denominator) internal pure returns (Fraction memory) {
        require(denominator > 0, "Division by zero");
        Fraction memory fraction = Fraction({numerator: numerator, denominator: denominator});
        reduceFraction(fraction);
        return fraction;
    }

    function createFraction(uint value) internal pure returns (Fraction memory) {
        return createFraction(value, 1);
    }

    function reduceFraction(Fraction memory fraction) internal pure {
        uint _gcd = gcd(fraction.numerator, fraction.denominator);
        fraction.numerator = fraction.numerator.div(_gcd);
        fraction.denominator = fraction.denominator.div(_gcd);
    }

    function multiplyFraction(Fraction memory a, Fraction memory b) internal pure returns (Fraction memory) {
        return createFraction(a.numerator.mul(b.numerator), a.denominator.mul(b.denominator));
    }

    function gcd(uint a, uint b) internal pure returns (uint) {
        uint _a = a;
        uint _b = b;
        if (_b > _a) {
            (_a, _b) = swap(_a, _b);
        }
        while (_b > 0) {
            _a = _a.mod(_b);
            (_a, _b) = swap (_a, _b);
        }
        return _a;
    }

    function swap(uint a, uint b) internal pure returns (uint, uint) {
        return (b, a);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only

/*
    SkaleManager.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./IERC1820Registry.sol";
import "./IERC777.sol";
import "./IERC777Recipient.sol";

import "./Distributor.sol";
import "./ValidatorService.sol";
import "./IMintableToken.sol";
import "./Bounty.sol";
import "./ConstantsHolder.sol";
import "./Monitors.sol";
import "./NodeRotation.sol";
import "./Permissions.sol";
import "./Schains.sol";


contract SkaleManager is IERC777Recipient, Permissions {
    IERC1820Registry private _erc1820;

    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    bytes32 constant public ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event BountyGot(
        uint indexed nodeIndex,
        address owner,
        uint averageDowntime,
        uint averageLatency,
        uint bounty,
        uint previousBlockEvent,
        uint time,
        uint gasSpend
    );

    function tokensReceived(
        address, // operator
        address from,
        address to,
        uint256 value,
        bytes calldata userData,
        bytes calldata // operator data
    )
        external override
        allow("SkaleToken")
    {
        require(to == address(this), "Receiver is incorrect");
        if (userData.length > 0) {
            Schains schains = Schains(
                contractManager.getContract("Schains"));
            schains.addSchain(from, value, userData);
        }
    }

    function createNode(
        uint16 port,
        uint16 nonce,
        bytes4 ip,
        bytes4 publicIp,
        bytes32[2] calldata publicKey,
        string calldata name)
        external
    {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        // validators checks inside checkPossibilityCreatingNode
        nodes.checkPossibilityCreatingNode(msg.sender);

        Nodes.NodeCreationParams memory params = Nodes.NodeCreationParams({
            name: name,
            ip: ip,
            publicIp: publicIp,
            port: port,
            publicKey: publicKey,
            nonce: nonce});
        nodes.createNode(msg.sender, params);
        // uint nodeIndex = nodes.createNode(msg.sender, params);
        // Monitors monitors = Monitors(contractManager.getContract("Monitors"));
        // monitors.addMonitor(nodeIndex);
    }

    function nodeExit(uint nodeIndex) external {
        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint validatorId = nodes.getValidatorId(nodeIndex);
        bool permitted = (_isOwner() || nodes.isNodeExist(msg.sender, nodeIndex));
        if (!permitted) {
            permitted = validatorService.getValidatorId(msg.sender) == validatorId;
        }
        require(permitted, "Sender is not permitted to call this function");
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        ConstantsHolder constants = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        nodeRotation.freezeSchains(nodeIndex);
        if (nodes.isNodeActive(nodeIndex)) {
            require(nodes.initExit(nodeIndex), "Initialization of node exit is failed");
        }
        bool completed;
        bool isSchains = false;
        if (schainsInternal.getActiveSchain(nodeIndex) != bytes32(0)) {
            completed = nodeRotation.exitFromSchain(nodeIndex);
            isSchains = true;
        } else {
            completed = true;
        }
        if (completed) {
            require(nodes.completeExit(nodeIndex), "Finishing of node exit is failed");
            nodes.changeNodeFinishTime(nodeIndex, now.add(isSchains ? constants.rotationDelay() : 0));
            // Monitors monitors = Monitors(contractManager.getContract("Monitors"));
            // monitors.removeCheckedNodes(nodeIndex);
            // monitors.deleteMonitor(nodeIndex);
            nodes.deleteNodeForValidator(validatorId, nodeIndex);
        }
    }

    function deleteSchain(string calldata name) external {
        Schains schains = Schains(contractManager.getContract("Schains"));
        // schain owner checks inside deleteSchain
        schains.deleteSchain(msg.sender, name);
    }

    function deleteSchainByRoot(string calldata name) external onlyAdmin {
        Schains schains = Schains(contractManager.getContract("Schains"));
        schains.deleteSchainByRoot(name);
    }

    // function sendVerdict(uint fromMonitorIndex, Monitors.Verdict calldata verdict) external {
    //     Nodes nodes = Nodes(contractManager.getContract("Nodes"));
    //     require(nodes.isNodeExist(msg.sender, fromMonitorIndex), "Node does not exist for Message sender");

    //     Monitors monitors = Monitors(contractManager.getContract("Monitors"));
    //     // additional checks for monitoring inside sendVerdict
    //     monitors.sendVerdict(fromMonitorIndex, verdict);
    // }

    // function sendVerdicts(uint fromMonitorIndex, Monitors.Verdict[] calldata verdicts) external {
    //     Nodes nodes = Nodes(contractManager.getContract("Nodes"));
    //     require(nodes.isNodeExist(msg.sender, fromMonitorIndex), "Node does not exist for Message sender");

    //     Monitors monitors = Monitors(contractManager.getContract("Monitors"));
    //     for (uint i = 0; i < verdicts.length; i++) {
    //         // additional checks for monitoring inside sendVerdict
    //         monitors.sendVerdict(fromMonitorIndex, verdicts[i]);
    //     }
    // }

    function getBounty(uint nodeIndex) external {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        require(nodes.isNodeExist(msg.sender, nodeIndex), "Node does not exist for Message sender");
        require(nodes.isTimeForReward(nodeIndex), "Not time for bounty");
        require(
            nodes.isNodeActive(nodeIndex) || nodes.isNodeLeaving(nodeIndex), "Node is not Active and is not Leaving"
        );
        Bounty bountyContract = Bounty(contractManager.getContract("Bounty"));
        uint averageDowntime;
        uint averageLatency;
        Monitors monitors = Monitors(contractManager.getContract("Monitors"));
        (averageDowntime, averageLatency) = monitors.calculateMetrics(nodeIndex);

        uint bounty = bountyContract.getBounty(
            nodeIndex,
            averageDowntime,
            averageLatency);

        nodes.changeNodeLastRewardDate(nodeIndex);
        // monitors.deleteMonitor(nodeIndex);
        // monitors.addMonitor(nodeIndex);

        if (bounty > 0) {
            _payBounty(bounty, nodes.getValidatorId(nodeIndex));
        }

        _emitBountyEvent(nodeIndex, msg.sender, averageDowntime, averageLatency, bounty);
    }

    function initialize(address newContractsAddress) public override initializer {
        Permissions.initialize(newContractsAddress);
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

    function _payBounty(uint bounty, uint validatorId) private returns (bool) {        
        IERC777 skaleToken = IERC777(contractManager.getContract("SkaleToken"));
        Distributor distributor = Distributor(contractManager.getContract("Distributor"));
        
        require(
            IMintableToken(address(skaleToken)).mint(address(distributor), bounty, abi.encode(validatorId), ""),
            "Token was not minted"
        );
    }

    function _emitBountyEvent(
        uint nodeIndex,
        address from,
        uint averageDowntime,
        uint averageLatency,
        uint bounty
    )
        private
    {
        Monitors monitors = Monitors(contractManager.getContract("Monitors"));
        uint previousBlockEvent = monitors.getLastBountyBlock(nodeIndex);
        monitors.setLastBountyBlock(nodeIndex);

        emit BountyGot(
            nodeIndex,
            from,
            averageDowntime,
            averageLatency,
            bounty,
            previousBlockEvent,
            block.timestamp,
            gasleft());
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

/*
    Punisher.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity 0.6.10;

import "./Permissions.sol";
import "./ILocker.sol";

import "./ValidatorService.sol";
import "./DelegationController.sol";

/**
 * @title Punisher
 * @dev This contract handles all slashing and forgiving operations.
 */
contract Punisher is Permissions, ILocker {

    /**
     * @dev Emitted when a slashing condition occurs.
     */
    event Slash(
        uint validatorId,
        uint amount
    );

    /**
     * @dev Emitted when a forgive condition occurs.
     */
    event Forgive(
        address wallet,
        uint amount
    );

    //        holder => tokens
    mapping (address => uint) private _locked;

    /**
     * @dev Executes slashing on a validator and its delegations by an `amount`
     * of tokens. Currently, SkaleDKG is the only service allowed to execute
     * slashing.
     *
     * Emits a Slash event.
     *
     * @param validatorId uint validator to be slashed
     * @param amount uint slashed amount
    */
    function slash(uint validatorId, uint amount) external allow("SkaleDKG") {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController"));

        require(validatorService.validatorExists(validatorId), "Validator does not exist");

        delegationController.confiscate(validatorId, amount);

        emit Slash(validatorId, amount);
    }

    /**
     * @dev Allows the Owner to forgive a slashing condition.
     *
     * Emits a Forgive event.
     *
     * @param holder address of the slashed
     * @param amount uint amount to be forgiven
     */
    function forgive(address holder, uint amount) external onlyAdmin {
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController"));

        require(!delegationController.hasUnprocessedSlashes(holder), "Not all slashes were calculated");

        if (amount > _locked[holder]) {
            delete _locked[holder];
        } else {
            _locked[holder] = _locked[holder].sub(amount);
        }

        emit Forgive(holder, amount);
    }

    /**
     * @dev See ILocker-getAndUpdateLockedAmount
     */
    function getAndUpdateLockedAmount(address wallet) external override returns (uint) {
        return _getAndUpdateLockedAmount(wallet);
    }

    /**
     * @dev See ILocker-getAndUpdateForbiddenForDelegationAmount
     */
    function getAndUpdateForbiddenForDelegationAmount(address wallet) external override returns (uint) {
        return _getAndUpdateLockedAmount(wallet);
    }

    function handleSlash(address holder, uint amount) external allow("DelegationController") {
        _locked[holder] = _locked[holder].add(amount);
    }

    function initialize(address contractManagerAddress) public override initializer {
        Permissions.initialize(contractManagerAddress);
    }

    // private

    function _getAndUpdateLockedAmount(address wallet) private returns (uint) {
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController"));

        delegationController.processAllSlashes(wallet);
        return _locked[wallet];
    }

}
