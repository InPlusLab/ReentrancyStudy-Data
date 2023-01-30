/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

pragma solidity ^0.5.11;


contract IERC721 {
    // ERC20 compatible functions
    function name() public view returns (string memory _name);
    function symbol() public view returns (string memory _symbol);

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);
    function getApproved(uint256 tokenId) public view returns (address operator);
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function approve(address to, uint256 tokenId) public;
    function setApprovalForAll(address operator, bool _approved) public;

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


/**
    @title Emyto ERC721 token escrow
    @author Victor Fage <victorfage@gmail.com>
*/
contract EmytoERC721Escrow {

    // Events

    event CreateEscrow(
        bytes32 _escrowId,
        address _agent,
        address _depositant,
        address _retreader,
        IERC721 _token,
        uint256 _tokenId,
        uint256 _salt
    );

    event SignedCreateEscrow(bytes32 _escrowId, bytes _agentSignature);

    event CancelSignature(bytes _agentSignature);

    event Deposit(bytes32 _escrowId);

    event Withdraw(
        bytes32 _escrowId,
        address _sender,
        address _to
    );

    event Cancel(bytes32 _escrowId);

    struct Escrow {
        address agent;
        address depositant;
        address retreader;
        IERC721 token;
        uint256 tokenId;
    }

    mapping (bytes32 => Escrow) public escrows;
    mapping (address => mapping (bytes => bool)) public canceledSignatures;

    // View functions

    /**
        @notice Calculate the escrow id

        @dev The id of the escrow its generate with keccak256 function using the parameters of the function

        @param _agent The agent address
        @param _depositant The depositant address
        @param _retreader The retreader address
        @param _token The ERC721 token address
        @param _tokenId The ERC721 token id
        @param _salt An entropy value, used to generate the id

        @return The id of the escrow
    */
    function calculateId(
        address _agent,
        address _depositant,
        address _retreader,
        IERC721 _token,
        uint256 _tokenId,
        uint256 _salt
    ) public view returns(bytes32) {
        return keccak256(
            abi.encodePacked(
                address(this),
                _agent,
                _depositant,
                _retreader,
                _token,
                _tokenId,
                _salt
            )
        );
    }

    // External functions

    /**
        @notice Create an ERC721 escrow

        @dev The id of the escrow its generate with keccak256 function,
            using the address of this contract, the sender(agent), the _depositant,
            the _retreader, the _token, the _tokenId and the salt number

            The agent will be the sender of the transaction

        @param _depositant The depositant address
        @param _retreader The retreader address
        @param _token The ERC721 token address
        @param _tokenId The ERC721 token id
        @param _salt An entropy value, used to generate the id

        @return The id of the escrow
    */
    function createEscrow(
        address _depositant,
        address _retreader,
        IERC721 _token,
        uint256 _tokenId,
        uint256 _salt
    ) external returns(bytes32 escrowId) {
        escrowId = _createEscrow(
            msg.sender,
            _depositant,
            _retreader,
            _token,
            _tokenId,
            _salt
        );
    }

    /**
        @notice Create an escrow, using the signature provided by the agent

        @dev The signature can will be cancel with cancelSignature function

        @param _agent The agent address
        @param _depositant The depositant address
        @param _retreader The retrea    der address
        @param _token The ERC721 token address
        @param _tokenId The ERC721 token id
        @param _salt An entropy value, used to generate the id
        @param _agentSignature The signature provided by the agent

        @return The id of the escrow
    */
    function signedCreateEscrow(
        address _agent,
        address _depositant,
        address _retreader,
        IERC721 _token,
        uint256 _tokenId,
        uint256 _salt,
        bytes calldata _agentSignature
    ) external returns(bytes32 escrowId) {
        escrowId = _createEscrow(
            _agent,
            _depositant,
            _retreader,
            _token,
            _tokenId,
            _salt
        );

        require(!canceledSignatures[_agent][_agentSignature], "signedCreateEscrow: The signature was canceled");

        require(
            _agent == _ecrecovery(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", escrowId)), _agentSignature),
            "signedCreateEscrow: Invalid agent signature"
        );

        emit SignedCreateEscrow(escrowId, _agentSignature);
    }

    /**
        @notice Cancel a create escrow signature

        @param _agentSignature The signature provided by the agent
    */
    function cancelSignature(bytes calldata _agentSignature) external {
        canceledSignatures[msg.sender][_agentSignature] = true;

        emit CancelSignature(_agentSignature);
    }

    /**
        @notice Deposit an erc721 token in escrow

        @dev The depositant of the escrow should be the sender, previous need the approve of the ERC721 token

        @param _escrowId The id of the escrow
    */
    function deposit(bytes32 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == escrow.depositant, "deposit: The sender should be the depositant");

        // Transfer the erc721 token
        escrow.token.transferFrom(msg.sender, address(this), escrow.tokenId);

        emit Deposit(_escrowId);
    }

    /**
        @notice Withdraw an erc721 token from an escrow and send it to the retreader address

        @dev The sender should be the depositant or the agent of the escrow

        @param _escrowId The id of the escrow
    */
    function withdrawToRetreader(bytes32 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        _withdraw(_escrowId, escrow.depositant, escrow.retreader);
    }

    /**
        @notice Withdraw an erc721 token from an escrow and send it to the depositant address

        @dev The sender should be the retreader or the agent of the escrow

        @param _escrowId The id of the escrow
    */
    function withdrawToDepositant(bytes32 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        _withdraw(_escrowId, escrow.retreader, escrow.depositant);
    }

    /**
        @notice Cancel an escrow and send the erc721 token to the depositant address

        @dev The sender should be the agent of the escrow
            The escrow will deleted

        @param _escrowId The id of the escrow
    */
    function cancel(bytes32 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == escrow.agent, "cancel: The sender should be the agent");

        address depositant = escrow.depositant;
        IERC721 token = escrow.token;
        uint256 tokenId = escrow.tokenId;

        // Delete escrow
        delete escrows[_escrowId];

        // Send the ERC721 token to the depositant
        token.safeTransferFrom(address(this), depositant, tokenId);

        emit Cancel(_escrowId);
    }

    // Internal functions

    function _createEscrow(
        address _agent,
        address _depositant,
        address _retreader,
        IERC721 _token,
        uint256 _tokenId,
        uint256 _salt
    ) internal returns(bytes32 escrowId) {
        // Calculate the escrow id
        escrowId = calculateId(
            _agent,
            _depositant,
            _retreader,
            _token,
            _tokenId,
            _salt
        );

        // Check if the escrow was created
        require(escrows[escrowId].agent == address(0), "createEscrow: The escrow exists");

        // Add escrow to the escrows array
        escrows[escrowId] = Escrow({
            agent: _agent,
            depositant: _depositant,
            retreader: _retreader,
            token: _token,
            tokenId: _tokenId
        });

        emit CreateEscrow(escrowId, _agent, _depositant, _retreader, _token, _tokenId, _salt);
    }

    /**
        @notice Withdraw an erc721 token from an escrow and send it to _to address

        @dev The sender should be the _approved or the agent of the escrow

        @param _escrowId The id of the escrow
        @param _approved The address of approved
        @param _to The address of gone the tokens
    */
    function _withdraw(
        bytes32 _escrowId,
        address _approved,
        address _to
    ) internal {
        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == _approved || msg.sender == escrow.agent, "_withdraw: The sender should be the _approved or the agent");

        escrow.token.safeTransferFrom(address(this), _to, escrow.tokenId);

        emit Withdraw(_escrowId, msg.sender, _to);
    }

    function _ecrecovery(bytes32 _hash, bytes memory _sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := and(mload(add(_sig, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(_hash, v, r, s);
    }
}