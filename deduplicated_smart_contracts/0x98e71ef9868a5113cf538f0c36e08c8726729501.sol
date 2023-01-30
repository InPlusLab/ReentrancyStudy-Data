/**

 *Submitted for verification at Etherscan.io on 2019-04-11

*/



pragma solidity ^0.5.2;



/**

 * @title Anchoring system

 * @author Blockchain Partner

 * @author https://blockchainpartner.fr

 */

contract AnchoringSystem {



    /// @dev Event emitted when saving a new anchor

    event NewAnchor(address anchorer, bytes32 digest);



    /// @dev Event emitted when revoking an anchor

    event NewRevokation(address revoker, bytes32 digest);



    /// @dev `anchors[anchorer][digest]` is true if `digest` has been anchored by `anchorer`

    mapping(bytes32 => mapping(address => bool)) public anchors;



    /// @dev Save a new anchor

    /// @param _digest bytes32 hash to anchor

    function saveNewAnchor(bytes32 _digest) public {

        require(!anchors[_digest][msg.sender]);

        emit NewAnchor(msg.sender, _digest);

        anchors[_digest][msg.sender] = true;

    }



    /// @dev Revoke an anchor

    /// @param _digest bytes32 hash to revoke

    function revoke(bytes32 _digest) public {

        require(anchors[_digest][msg.sender]);

        emit NewRevokation(msg.sender, _digest);

        anchors[_digest][msg.sender] = false;

    }

}