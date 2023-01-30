/**
 *Submitted for verification at Etherscan.io on 2020-03-10
*/

pragma solidity ^0.5.11;


/// @title ERC-173 Contract Ownership Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-173.md
///  Note: the ERC-165 identifier for this interface is 0x7f5828d0
contract IERC173 {
    /// @dev This emits when ownership of a contract changes.
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    /// @notice Get the address of the owner
    /// @return The address of the owner.
    //// function owner() external view returns (address);

    /// @notice Set the address of the new owner of the contract
    /// @param _newOwner The address of the new owner of the contract
    function transferOwnership(address _newOwner) external;
}


contract Ownable is IERC173 {
    address internal _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, "The owner should be the sender");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0x0), msg.sender);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    /**
        @dev Transfers the ownership of the contract.

        @param _newOwner Address of the new owner
    */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "0x0 Is not a valid owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}


interface IERC20 {
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
}


/**
* @dev Library to perform safe calls to standard method for ERC20 tokens.
*
* Why Transfers: transfer methods could have a return value (bool), throw or revert for insufficient funds or
* unathorized value.
*
* Why Approve: approve method could has a return value (bool) or does not accept 0 as a valid value (BNB token).
* The common strategy used to clean approvals.
*
* We use the Solidity call instead of interface methods because in the case of transfer, it will fail
* for tokens with an implementation without returning a value.
* Since versions of Solidity 0.4.22 the EVM has a new opcode, called RETURNDATASIZE.
* This opcode stores the size of the returned data of an external call. The code checks the size of the return value
* after an external call and reverts the transaction in case the return data is shorter than expected
*/
library SafeERC20 {
    /**
    * @dev Transfer token for a specified address
    * @param _token erc20 The address of the ERC20 contract
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the _value of tokens to be transferred
    * @return bool whether the transfer was successful or not
    */
    function safeTransfer(IERC20 _token, address _to, uint256 _value) internal returns (bool) {
        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            // Insufficient funds
            return false;
        }

        address(_token).call(
           abi.encodeWithSignature("transfer(address,uint256)", _to, _value)
        );

        // Fail if the new balance its not equal than previous balance sub _value
        return prevBalance - _value == _token.balanceOf(address(this));
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _token erc20 The address of the ERC20 contract
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the _value of tokens to be transferred
    * @return bool whether the transfer was successful or not
    */
    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool)
    {
        uint256 prevBalance = _token.balanceOf(_from);

        if (
           prevBalance < _value || // Insufficient funds
            _token.allowance(_from, address(this)) < _value // Insufficient allowance
        ) {
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _value)
        );

        // Fail if the new balance its not equal than previous balance sub _value
        return prevBalance - _value == _token.balanceOf(_from);
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    *
    * @param _token erc20 The address of the ERC20 contract
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    * @return bool whether the approve was successful or not
    */
    function safeApprove(IERC20 _token, address _spender, uint256 _value) internal returns (bool) {
        address(_token).call(
           abi.encodeWithSignature("approve(address,uint256)",_spender, _value)
        );

        // Fail if the new allowance its not equal than _value
        return _token.allowance(address(this), _spender) == _value;
    }

    /**
    * @dev Clear approval
    * Note that if 0 is not a valid value it will be set to 1.
    * @param _token erc20 The address of the ERC20 contract
    * @param _spender The address which will spend the funds.
    */
    function clearApprove(IERC20 _token, address _spender) internal returns (bool) {
        bool success = safeApprove(_token, _spender, 0);

        if (!success) {
            success = safeApprove(_token, _spender, 1);
        }

        return success;
    }
}


library SafeMath {
    using SafeMath for uint256;

    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        require(z >= x, "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {
        require(x >= y, "Sub overflow");
        return x - y;
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }

        uint256 z = x * y;
        require(z/x == y, "Mul overflow");
        return z;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "Div by zero");
        return x / y;
    }

    function muldiv(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) {
        require(z != 0, "div by zero");
        return x.mul(y) / z;
    }
}


/**
    @title Emyto token escrow
    @author Victor Fage <victorfage@gmail.com>
*/
contract EmytoTokenEscrow is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Events

    event CreateEscrow(
        bytes32 _escrowId,
        address _agent,
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt
    );

    event SignedCreateEscrow(bytes32 _escrowId, bytes _agentSignature);

    event CancelSignature(bytes _agentSignature);

    event Deposit(
        bytes32 _escrowId,
        uint256 _toEscrow,
        uint256 _toEmyto
    );

    event Withdraw(
        bytes32 _escrowId,
        address _sender,
        address _to,
        uint256 _toAmount,
        uint256 _toAgent
    );

    event Cancel(bytes32 _escrowId, uint256 _amount);

    event SetEmytoFee(uint256 _fee);

    event EmytoWithdraw(IERC20 _token, address _to, uint256 _amount);

    struct Escrow {
        address agent;
        address depositant;
        address retreader;
        uint256 fee;
        IERC20 token;
        uint256 balance;
    }

    // 10000 ==  100%
    //   505 == 5.05%
    uint256 public BASE = 10000;
    uint256 private MAX_EMYTO_FEE = 50;
    uint256 private MAX_AGENT_FEE = 1000;
    uint256 public emytoFee;

    // Token to balance of emyto
    mapping(address => uint256) public emytoBalances;
    mapping(bytes32 => Escrow) public escrows;

    mapping (address => mapping (bytes => bool)) public canceledSignatures;

    // OnlyOwner functions

    /**
        @notice Set the emyto fee

        @dev Only the owner of the contract can send this transaction

        @param _fee The new emyto fee
    */
    function setEmytoFee(uint256 _fee) external onlyOwner {
        require(_fee <= MAX_EMYTO_FEE, "setEmytoFee: The emyto fee should be low or equal than the MAX_EMYTO_FEE");
        emytoFee = _fee;

        emit SetEmytoFee(_fee);
    }

    /**
        @notice Withdraw the accumulated amount of the fee

        @dev Only the owner of the contract can send this transaction

        @param _token The address of the token to withdraw
        @param _to The address destination of the tokens
        @param _amount The amount to withdraw
    */
    function emytoWithdraw(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(_to != address(0), "emytoWithdraw: The to address 0 its invalid");

        emytoBalances[address(_token)] = emytoBalances[address(_token)].sub(_amount);

        require(
            _token.safeTransfer(_to, _amount),
            "emytoWithdraw: Error transfer to emyto"
        );

        emit EmytoWithdraw(_token, _to, _amount);
    }

    // View functions

    /**
        @notice Calculate the escrow id

        @dev The id of the escrow its generate with keccak256 function using the parameters of the function

        @param _agent The agent address
        @param _depositant The depositant address
        @param _retreader The retreader address
        @param _fee The fee percentage(calculate in BASE), this fee will sent to the agent when the escrow is withdrawn
        @param _token The token address
        @param _salt An entropy value, used to generate the id

        @return The id of the escrow
    */
    function calculateId(
        address _agent,
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt
    ) public view returns(bytes32) {
        return keccak256(
            abi.encodePacked(
                address(this),
                _agent,
                _depositant,
                _retreader,
                _fee,
                _token,
                _salt
            )
        );
    }

    // External functions

    /**
        @notice Create an ERC20 escrow
            Fee: The ratio is expressed in order of BASE, for example
                1% is 100
                50.00% is 5000
                23.45% is 2345

        @dev The id of the escrow its generate with keccak256 function,
            using the address of this contract, the sender(agent), the _depositant,
            the _retreader, the _fee, the _token and the salt number

            The agent will be the sender of the transaction
            The _fee should be low or equal than 1000(10%)

        @param _depositant The depositant address
        @param _retreader The retrea    der address
        @param _fee The fee percentage(calculate in BASE), this fee will sent to the agent when the escrow is withdrawn
        @param _token The token address
        @param _salt An entropy value, used to generate the id

        @return The id of the escrow
    */
    function createEscrow(
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt
    ) external returns(bytes32 escrowId) {
        escrowId = _createEscrow(
            msg.sender,
            _depositant,
            _retreader,
            _fee,
            _token,
            _salt
        );
    }

    /**
        @notice Create an escrow, using the signature provided by the agent

        @dev The signature can will be cancel with cancelSignature function

        @param _agent The agent address
        @param _depositant The depositant address
        @param _retreader The retrea    der address
        @param _fee The fee percentage(calculate in BASE), this fee will sent to the agent when the escrow is withdrawn
        @param _token The token address
        @param _salt An entropy value, used to generate the id
        @param _agentSignature The signature provided by the agent

        @return The id of the escrow
    */
    function signedCreateEscrow(
        address _agent,
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt,
        bytes calldata _agentSignature
    ) external returns(bytes32 escrowId) {
        escrowId = _createEscrow(
            _agent,
            _depositant,
            _retreader,
            _fee,
            _token,
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
        @notice Deposit an amount valuate in escrow token to an escrow

        @dev The depositant of the escrow should be the sender, previous need the approve of the ERC20 tokens

        @param _escrowId The id of the escrow
        @param _amount The amount to deposit in an escrow, with emyto fee amount
    */
    function deposit(bytes32 _escrowId, uint256 _amount) external {
        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == escrow.depositant, "deposit: The sender should be the depositant");

        uint256 toEmyto = _feeAmount(_amount, emytoFee);

        // Transfer the tokens
        require(
            escrow.token.safeTransferFrom(msg.sender, address(this), _amount),
            "deposit: Error deposit tokens"
        );

        // Assign the fee amount to emyto
        emytoBalances[address(escrow.token)] += toEmyto;
        // Assign the deposit amount to the escrow, subtracting the fee emyto amount
        uint256 toEscrow = _amount.sub(toEmyto);
        escrow.balance += toEscrow;

        emit Deposit(_escrowId, toEscrow, toEmyto);
    }

    /**
        @notice Withdraw an amount from an escrow and send the tokens to the retreader address

        @dev The sender should be the depositant or the agent of the escrow

        @param _escrowId The id of the escrow
        @param _amount The base amount
    */
    function withdrawToRetreader(bytes32 _escrowId, uint256 _amount) external {
        Escrow storage escrow = escrows[_escrowId];
        _withdraw(_escrowId, escrow.depositant, escrow.retreader, _amount);
    }

    /**
        @notice Withdraw an amount from an escrow and the tokens  send to the depositant address

        @dev The sender should be the retreader or the agent of the escrow

        @param _escrowId The id of the escrow
        @param _amount The base amount
    */
    function withdrawToDepositant(bytes32 _escrowId, uint256 _amount) external {
        Escrow storage escrow = escrows[_escrowId];
        _withdraw(_escrowId, escrow.retreader, escrow.depositant, _amount);
    }

    /**
        @notice Cancel an escrow and send the balance of the escrow to the depositant address

        @dev The sender should be the agent of the escrow
            The escrow will deleted

        @param _escrowId The id of the escrow
    */
    function cancel(bytes32 _escrowId) external {
        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == escrow.agent, "cancel: The sender should be the agent");

        uint256 balance = escrow.balance;
        address depositant = escrow.depositant;
        IERC20 token = escrow.token;

        // Delete escrow
        delete escrows[_escrowId];

        // Send the tokens to the depositant if the escrow have balance
        if (balance != 0)
            require(
                token.safeTransfer(depositant, balance),
                "cancel: Error transfer to the depositant"
            );

        emit Cancel(_escrowId, balance);
    }

    // Internal functions

    function _createEscrow(
        address _agent,
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt
    ) internal returns(bytes32 escrowId) {
        require(_fee <= MAX_AGENT_FEE, "createEscrow: The agent fee should be low or equal than 1000");

        // Calculate the escrow id
        escrowId = calculateId(
            _agent,
            _depositant,
            _retreader,
            _fee,
            _token,
            _salt
        );

        // Check if the escrow was created
        require(escrows[escrowId].agent == address(0), "createEscrow: The escrow exists");

        // Add escrow to the escrows array
        escrows[escrowId] = Escrow({
            agent: _agent,
            depositant: _depositant,
            retreader: _retreader,
            fee: _fee,
            token: _token,
            balance: 0
        });

        emit CreateEscrow(escrowId, _agent, _depositant, _retreader, _fee, _token, _salt);
    }

    /**
        @notice Withdraw an amount from an escrow and send to _to address

        @dev The sender should be the _approved or the agent of the escrow

        @param _escrowId The id of the escrow
        @param _approved The address of approved
        @param _to The address of gone the tokens
        @param _amount The base amount
    */
    function _withdraw(
        bytes32 _escrowId,
        address _approved,
        address _to,
        uint256 _amount
    ) internal {
        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == _approved || msg.sender == escrow.agent, "_withdraw: The sender should be the _approved or the agent");

        // Calculate the fee
        uint256 toAgent = _feeAmount(_amount, escrow.fee);
        // Actualize escrow balance in storage
        escrow.balance = escrow.balance.sub(_amount);
        // Send fee to the agent
        require(
            escrow.token.safeTransfer(escrow.agent, toAgent),
            "_withdraw: Error transfer tokens to the agent"
        );
        // Substract the agent fee
        uint256 toAmount = _amount.sub(toAgent);
        // Send amount to the _to
        require(
            escrow.token.safeTransfer(_to, toAmount),
            "_withdraw: Error transfer to the _to"
        );

        emit Withdraw(_escrowId, msg.sender, _to, toAmount, toAgent);
    }

    /**
        @notice Calculate the fee amount

        @dev Formula: _amount * _fee / BASE

        @param _amount The base amount
        @param _fee The fee

        @return The calculate fee
    */
    function _feeAmount(
        uint256 _amount,
        uint256 _fee
    ) internal view returns(uint256) {
        return _amount.mul(_fee).div(BASE);
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