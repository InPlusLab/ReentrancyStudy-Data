/**

 *Submitted for verification at Etherscan.io on 2019-06-13

*/



/*

 * Price Adjustments for the last 100 NFTs in the Crypto stamp On-Chain Shop

 *

 * Developed by capacity.at

 * for post.at

 */





// File: node_modules\openzeppelin-solidity\contracts\introspection\IERC165.sol



pragma solidity ^0.5.0;



/**

 * @dev Interface of the ERC165 standard, as defined in the

 * [EIP](https://eips.ethereum.org/EIPS/eip-165).

 *

 * Implementers can declare support of contract interfaces, which can then be

 * queried by others (`ERC165Checker`).

 *

 * For an implementation, see `ERC165`.

 */

interface IERC165 {

    /**

     * @dev Returns true if this contract implements the interface defined by

     * `interfaceId`. See the corresponding

     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)

     * to learn more about how these ids are created.

     *

     * This function call must use less than 30 000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



// File: openzeppelin-solidity\contracts\token\ERC721\IERC721.sol



pragma solidity ^0.5.0;





/**

 * @dev Required interface of an ERC721 compliant contract.

 */

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



    /**

     * @dev Returns the number of NFTs in `owner`'s account.

     */

    function balanceOf(address owner) public view returns (uint256 balance);



    /**

     * @dev Returns the owner of the NFT specified by `tokenId`.

     */

    function ownerOf(uint256 tokenId) public view returns (address owner);



    /**

     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to

     * another (`to`).

     *

     * 

     *

     * Requirements:

     * - `from`, `to` cannot be zero.

     * - `tokenId` must be owned by `from`.

     * - If the caller is not `from`, it must be have been allowed to move this

     * NFT by either `approve` or `setApproveForAll`.

     */

    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    /**

     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to

     * another (`to`).

     *

     * Requirements:

     * - If the caller is not `from`, it must be approved to move this NFT by

     * either `approve` or `setApproveForAll`.

     */

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);



    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);





    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}



// File: contracts\PricingStrategy.sol



pragma solidity ^0.5.0;





contract PricingStrategy {



    function adjustPrice(uint256 oldprice, uint256 remainingPieces) public view returns (uint256); //returns the new price



}



// File: contracts\AdjustableLast100PricingStrategy.sol



/*



*/

pragma solidity ^0.5.0;









contract AdjustableLast100PricingStrategy is PricingStrategy {





    address public beneficiary;

    uint256 public factor;



    constructor (address _beneficiary) public {

        beneficiary = _beneficiary;

        factor = 108; // 8% increase

    }





    modifier onlyBeneficiary() {

        require(msg.sender == beneficiary, "Only the current benefinicary can call this function.");

        _;

    }



    function setFactor(uint256 _newFactor)

    public

    onlyBeneficiary

    {

        require(_newFactor > 0, "You need to provide a price modifier");

        factor = _newFactor;

    }





    /**

    calculates a new price based on the old price and other params referenced

    */

    function adjustPrice(uint256 _oldPrice, uint256 _remainingPieces) public view returns (uint256){

        if (_remainingPieces < 100) {

            return _oldPrice * factor / 100;

        } else {

            return _oldPrice;

        }

    }

}