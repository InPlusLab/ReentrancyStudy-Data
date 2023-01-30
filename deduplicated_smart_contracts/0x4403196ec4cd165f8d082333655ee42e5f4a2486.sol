// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IERC1155.sol";
import "./IERC1155MetadataURI.sol";
import "./IERC1155Receiver.sol";
import "./Pausable.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./ERC165.sol";

contract ViVADOR is ERC165, IERC1155, ERC1155Metadata, Pausable {
    using SafeMath for uint256;
    using Address for address;

    // Mapping from token ID to account balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;
    
    // Mapping validators
    mapping (address => bool) private _validators;
    
    // Mapping original NFT minters
    mapping (uint256 => address payable) private _tokenMinters;
    
    // A nonce to ensure we have a unique id each time we mint.
    uint256 public nonce;
    
    // The fee for burning an asset
    // This fee goes to the asset minter
    uint256 private burnFee = 0 ether;

    /*
     *     bytes4(keccak256('balanceOf(address,uint256)')) == 0x00fdd58e
     *     bytes4(keccak256('balanceOfBatch(address[],uint256[])')) == 0x4e1273f4
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,uint256,bytes)')) == 0xf242432a
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6
     *
     *     => 0x00fdd58e ^ 0x4e1273f4 ^ 0xa22cb465 ^
     *        0xe985e9c5 ^ 0xf242432a ^ 0x2eb2c2d6 == 0xd9b67a26
     */
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    /*
     *     bytes4(keccak256('uri(uint256)')) == 0x0e89341c
     */
    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    /**
     * @dev See {_setBaseMetadataURI}.
     */
    constructor (string memory uri) public {
        _setBaseMetadataURI(uri);

        // register the supported interfaces to conform to ERC1155 via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155);

        // register the supported interfaces to conform to ERC1155MetadataURI via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    /*
    * Only allowed validators modifier
    */
    modifier onlyValidator() {
        require(_validators[msg.sender] == true, "Only validators are allowed");
        _;
    }
    
    event ValidatorSet(address validator, bool status);
    
    /*
    * change validator status
    */
    
    function setValidator(address validator, bool status) isOwner public {
        _validators[validator] = status;
        emit ValidatorSet(validator, status);
    }
    
    /*
    * Check if an address is a validator
    */
    function isValidator(address validator) public view returns (bool) {
        return _validators[validator]; 
    } 
    
    /**
    * Set a fee for burning an asset
    */
    function setBurnfee(uint256 fee) public isOwner {
        burnFee = fee;    
    }    
    
    /**
    * Get the current fee for burning an asset
    */
    function getBurnfee() public view returns (uint256) {
        return burnFee;
    }    
    

    /**
        @dev Get the specified address' balance for token with specified ID.

        Attempting to query the zero account for a balance will result in a revert.

        @param account The address of the token holder
        @param id ID of the token
        @return The account's balance of the token type requested
     */
    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
        @dev Get the balance of multiple account/token pairs.

        If any of the query accounts is the zero account, this query will revert.

        @param accounts The addresses of the token holders
        @param ids IDs of the tokens
        @return Balances for each account and token id pair
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and IDs must have same lengths");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: some address in batch balance query is zero");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    /**
     * @dev Sets or unsets the approval of a given operator.
     *
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     *
     * Because an account already has operator privileges for itself, this function will revert
     * if the account attempts to set the approval status for itself.
     *
     * @param operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address operator, bool approved) whenNotPaused public virtual override {
        require(msg.sender != operator, "ERC1155: cannot set approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
        @notice Queries the approval status of an operator for a given account.
        @param account   The account of the Tokens
        @param operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address account, address operator) public view override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
        @dev Transfers `value` amount of an `id` from the `from` address to the `to` address specified.
        Caller must be approved to manage the tokens being transferred out of the `from` account.
        If `to` is a smart contract, will call `onERC1155Received` on `to` and act appropriately.
        @param from Source address
        @param to Target address
        @param id ID of the token type
        @param value Transfer amount
        @param data Data forwarded to `onERC1155Received` if `to` is a contract receiver
    */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    )
        whenNotPaused
        public
        override
    {
        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender) == true,
            "ERC1155: need operator approval for 3rd party transfers"
        );

        _balances[id][from] = _balances[id][from].sub(value, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(value);

        emit TransferSingle(msg.sender, from, to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, value, data);
    }

    /**
        @dev Transfers `values` amount(s) of `ids` from the `from` address to the
        `to` address specified. Caller must be approved to manage the tokens being
        transferred out of the `from` account. If `to` is a smart contract, will
        call `onERC1155BatchReceived` on `to` and act appropriately.
        @param from Source address
        @param to Target address
        @param ids IDs of each token type
        @param values Transfer amounts per token type
        @param data Data forwarded to `onERC1155Received` if `to` is a contract receiver
    */
    
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    )
        whenNotPaused
        public
        virtual
        override
    {
        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");
        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender) == true,
            "ERC1155: need operator approval for 3rd party transfers"
        );

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            _balances[id][from] = _balances[id][from].sub(
                value,
                "ERC1155: insufficient balance of some token type for transfer"
            );
            _balances[id][to] = _balances[id][to].add(value);
        }

        emit TransferBatch(msg.sender, from, to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, values, data);
    }
    
    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substituion mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurence of the `{id}` substring in either the
     * URI or any of the values in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://adors.org/vault/{id}.json` URI would be
     * interpreted by clients as
     * `https://adors.org/vault/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    
    function setURI(string memory newuri) isOwner public {
        _setBaseMetadataURI(newuri);
    }
    
    /**
     * @dev Internal function to mint an amount of a token with the given ID
     * @param to The address that will own the minted token
     * @param id ID of the token to be minted
     * @param value Amount of the token to be minted
     * @param data Data forwarded to `onERC1155Received` if `to` is a contract receiver
     */
    function _mint(address to, uint256 id, uint256 value, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        _balances[id][to] = _balances[id][to].add(value);
        emit TransferSingle(msg.sender, address(0), to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, address(0), to, id, value, data);
    }

    
    function mint(address to, uint256 value, bytes memory data) whenNotPaused onlyValidator public {
        uint256 id = ++nonce;
        _tokenMinters[id] = msg.sender;
        _mint(to, id, value, data);
        emit URI(baseMetadataURI, id);
    }
    
    /**
     * @dev Internal function to batch mint amounts of tokens with the given IDs
     * @param to The address that will own the minted token
     * @param ids IDs of the tokens to be minted
     * @param values Amounts of the tokens to be minted
     * @param data Data forwarded to `onERC1155Received` if `to` is a contract receiver
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: batch mint to the zero address");
        require(ids.length == values.length, "ERC1155: minted IDs and values must have same lengths");

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = values[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(msg.sender, address(0), to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, address(0), to, ids, values, data);
    }
    
    function mintBatch(address to, uint256[] memory values, bytes memory data) whenNotPaused onlyValidator public {
        uint256[] memory ids = new uint256[](values.length);
        
        for (uint256 i = 0; i < values.length; i++) {
               ids[i] = ++nonce;
               _tokenMinters[ids[i]] = msg.sender;
        }
        _mintBatch(to, ids, values, data);
        _logURIs(ids);
    }
    
    /*
    * get the minter of a token
    */
    
    function minterOf(uint256 id) public view returns (address) {
        return _tokenMinters[id];
    }
    
    /**
     * @dev Internal function to burn an amount of a token with the given ID
     * @param account Account which owns the token to be burnt
     * @param id ID of the token to be burnt
     * @param value Amount of the token to be burnt
     */
    function _burn(address account, uint256 id, uint256 value) internal virtual {
        require(account != address(0), "ERC1155: attempting to burn tokens on zero account");

        _balances[id][account] = _balances[id][account].sub(
            value,
            "ERC1155: attempting to burn more than balance"
        );
        emit TransferSingle(msg.sender, account, address(0), id, value);
    }
    
    function burn(uint256 id, uint256 value) whenNotPaused payable public {
        address payable minter = _tokenMinters[id];
        
        if (minter != msg.sender) {
            // require burnFee if not the minter burning
            require(msg.value >= burnFee);
            minter.transfer(burnFee);
        } 
        _burn(msg.sender, id, value);   
    }

    /**
     * @dev Internal function to batch burn an amounts of tokens with the given IDs
     * @param account Account which owns the token to be burnt
     * @param ids IDs of the tokens to be burnt
     * @param values Amounts of the tokens to be burnt
     */
    function _burnBatch(address account, uint256[] memory ids, uint256[] memory values) internal virtual {
        require(account != address(0), "ERC1155: attempting to burn batch of tokens on zero account");
        require(ids.length == values.length, "ERC1155: burnt IDs and values must have same lengths");

        for(uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                values[i],
                "ERC1155: attempting to burn more than balance for some token"
            );
        }

        emit TransferBatch(msg.sender, account, address(0), ids, values);
    }
    
    function burnBatch(uint256[] memory ids, uint256[] memory values) whenNotPaused payable public {
        uint256 totalBurnFee = msg.value;
        
        for (uint256 i = 0; i < ids.length; i++) {
            address payable minter = _tokenMinters[ids[i]];
                        
            if (minter != msg.sender) {
                require(totalBurnFee >= burnFee, "Not enough fee to burn assets");
                minter.transfer(burnFee);
                totalBurnFee = totalBurnFee.sub(burnFee);
            }    
            
        }
        _burnBatch(msg.sender, ids, values);
    }
    
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    )
        private
    {
        if(to.isContract()) {
            require(
                IERC1155Receiver(to).onERC1155Received(operator, from, id, value, data) ==
                    IERC1155Receiver(to).onERC1155Received.selector,
                "ERC1155: got unknown value from onERC1155Received"
            );
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    )
        private
    {
        if(to.isContract()) {
            require(
                IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, values, data) ==
                    IERC1155Receiver(to).onERC1155BatchReceived.selector,
                "ERC1155: got unknown value from onERC1155BatchReceived"
            );
        }
    }
    
     function withdrawFund() isOwner public {
        uint256 balance = address(this).balance;
        owner.transfer(balance);
    }
}