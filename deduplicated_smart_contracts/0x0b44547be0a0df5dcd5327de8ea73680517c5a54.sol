/**

 *Submitted for verification at Etherscan.io on 2019-04-24

*/



pragma solidity 0.5.7;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */

library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, reverts on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Adds two unsigned integers, reverts on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



contract ERC1820Registry {

    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;

    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address);

    function setManager(address _addr, address _newManager) external;

    function getManager(address _addr) public view returns (address);

}





/// Base client to interact with the registry.

contract ERC1820Client {

    ERC1820Registry constant ERC1820REGISTRY = ERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);



    function setInterfaceImplementation(string memory _interfaceLabel, address _implementation) internal {

        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));

        ERC1820REGISTRY.setInterfaceImplementer(address(this), interfaceHash, _implementation);

    }



    function interfaceAddr(address addr, string memory _interfaceLabel) internal view returns(address) {

        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));

        return ERC1820REGISTRY.getInterfaceImplementer(addr, interfaceHash);

    }



    function delegateManagement(address _newManager) internal {

        ERC1820REGISTRY.setManager(address(this), _newManager);

    }

}



interface ERC20Token {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);



    // solhint-disable-next-line no-simple-event-func-name

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

}



interface ERC777Token {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function granularity() external view returns (uint256);



    function defaultOperators() external view returns (address[] memory);

    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    function authorizeOperator(address operator) external;

    function revokeOperator(address operator) external;



    function send(address to, uint256 amount, bytes calldata data) external;

    function operatorSend(

        address from,

        address to,

        uint256 amount,

        bytes calldata data,

        bytes calldata operatorData

    ) external;



    function burn(uint256 amount, bytes calldata data) external;

    function operatorBurn(address from, uint256 amount, bytes calldata data, bytes calldata operatorData) external;



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



interface ERC777TokensSender {

    function tokensToSend(

        address operator,

        address from,

        address to,

        uint amount,

        bytes calldata data,

        bytes calldata operatorData

    ) external;

}



interface ERC777TokensRecipient {

    function tokensReceived(

        address operator,

        address from,

        address to,

        uint256 amount,

        bytes calldata data,

        bytes calldata operatorData

    ) external;

}



contract ERC777BaseToken is ERC777Token, ERC1820Client {

    using SafeMath for uint256;



    string internal mName;

    string internal mSymbol;

    uint256 internal mGranularity;

    uint256 internal mTotalSupply;





    mapping(address => uint) internal mBalances;



    address[] internal mDefaultOperators;

    mapping(address => bool) internal mIsDefaultOperator;

    mapping(address => mapping(address => bool)) internal mRevokedDefaultOperator;

    mapping(address => mapping(address => bool)) internal mAuthorizedOperators;



    /* -- Constructor -- */

    //

    /// @notice Constructor to create a ReferenceToken

    /// @param _name Name of the new token

    /// @param _symbol Symbol of the new token.

    /// @param _granularity Minimum transferable chunk.

    constructor(

        string memory _name,

        string memory _symbol,

        uint256 _granularity,

        address[] memory _defaultOperators

    ) internal {

        mName = _name;

        mSymbol = _symbol;

        mTotalSupply = 0;

        require(_granularity >= 1, "Granularity must be > 1");

        mGranularity = _granularity;



        mDefaultOperators = _defaultOperators;

        for (uint256 i = 0; i < mDefaultOperators.length; i++) { mIsDefaultOperator[mDefaultOperators[i]] = true; }



        setInterfaceImplementation("ERC777Token", address(this));

    }



    /* -- ERC777 Interface Implementation -- */

    //

    /// @return the name of the token

    function name() public view returns (string memory) { return mName; }



    /// @return the symbol of the token

    function symbol() public view returns (string memory) { return mSymbol; }



    /// @return the granularity of the token

    function granularity() public view returns (uint256) { return mGranularity; }



    /// @return the total supply of the token

    function totalSupply() public view returns (uint256) { return mTotalSupply; }



    /// @notice Return the account balance of some account

    /// @param _tokenHolder Address for which the balance is returned

    /// @return the balance of `_tokenAddress`.

    function balanceOf(address _tokenHolder) public view returns (uint256) { return mBalances[_tokenHolder]; }



    /// @notice Return the list of default operators

    /// @return the list of all the default operators

    function defaultOperators() public view returns (address[] memory) { return mDefaultOperators; }



    /// @notice Send `_amount` of tokens to address `_to` passing `_data` to the recipient

    /// @param _to The address of the recipient

    /// @param _amount The number of tokens to be sent

    function send(address _to, uint256 _amount, bytes calldata _data) external {

        doSend(msg.sender, msg.sender, _to, _amount, _data, "", true);

    }



    /// @notice Authorize a third party `_operator` to manage (send) `msg.sender`'s tokens.

    /// @param _operator The operator that wants to be Authorized

    function authorizeOperator(address _operator) external {

        require(_operator != msg.sender, "Cannot authorize yourself as an operator");

        if (mIsDefaultOperator[_operator]) {

            mRevokedDefaultOperator[_operator][msg.sender] = false;

        } else {

            mAuthorizedOperators[_operator][msg.sender] = true;

        }

        emit AuthorizedOperator(_operator, msg.sender);

    }



    /// @notice Revoke a third party `_operator`'s rights to manage (send) `msg.sender`'s tokens.

    /// @param _operator The operator that wants to be Revoked

    function revokeOperator(address _operator) external {

        require(_operator != msg.sender, "Cannot revoke yourself as an operator");

        if (mIsDefaultOperator[_operator]) {

            mRevokedDefaultOperator[_operator][msg.sender] = true;

        } else {

            mAuthorizedOperators[_operator][msg.sender] = false;

        }

        emit RevokedOperator(_operator, msg.sender);

    }



    /// @notice Check whether the `_operator` address is allowed to manage the tokens held by `_tokenHolder` address.

    /// @param _operator address to check if it has the right to manage the tokens

    /// @param _tokenHolder address which holds the tokens to be managed

    /// @return `true` if `_operator` is authorized for `_tokenHolder`

    function isOperatorFor(address _operator, address _tokenHolder) public view returns (bool) {

        return (_operator == _tokenHolder // solium-disable-line operator-whitespace

            || mAuthorizedOperators[_operator][_tokenHolder]

            || (mIsDefaultOperator[_operator] && !mRevokedDefaultOperator[_operator][_tokenHolder]));

    }



    /// @notice Send `_amount` of tokens on behalf of the address `from` to the address `to`.

    /// @param _from The address holding the tokens being sent

    /// @param _to The address of the recipient

    /// @param _amount The number of tokens to be sent

    /// @param _data Data generated by the user to be sent to the recipient

    /// @param _operatorData Data generated by the operator to be sent to the recipient

    function operatorSend(

        address _from,

        address _to,

        uint256 _amount,

        bytes calldata _data,

        bytes calldata _operatorData

    )

        external

    {

        require(isOperatorFor(msg.sender, _from), "Not an operator");

        doSend(msg.sender, _from, _to, _amount, _data, _operatorData, true);

    }



    function burn(uint256 _amount, bytes calldata _data) external {

        doBurn(msg.sender, msg.sender, _amount, _data, "");

    }



    function operatorBurn(

        address _tokenHolder,

        uint256 _amount,

        bytes calldata _data,

        bytes calldata _operatorData

    )

        external

    {

        require(isOperatorFor(msg.sender, _tokenHolder), "Not an operator");

        doBurn(msg.sender, _tokenHolder, _amount, _data, _operatorData);

    }



    /* -- Helper Functions -- */

    //

    /// @notice Internal function that ensures `_amount` is multiple of the granularity

    /// @param _amount The quantity that want's to be checked

    function requireMultiple(uint256 _amount) internal view {

        require(_amount % mGranularity == 0, "Amount is not a multiple of granualrity");

    }



    /// @notice Check whether an address is a regular address or not.

    /// @param _addr Address of the contract that has to be checked

    /// @return `true` if `_addr` is a regular address (not a contract)

    function isRegularAddress(address _addr) internal view returns(bool) {

        if (_addr == address(0)) { return false; }

        uint size;

        assembly { size := extcodesize(_addr) } // solium-disable-line security/no-inline-assembly

        return size == 0;

    }



    /// @notice Helper function actually performing the sending of tokens.

    /// @param _operator The address performing the send

    /// @param _from The address holding the tokens being sent

    /// @param _to The address of the recipient

    /// @param _amount The number of tokens to be sent

    /// @param _data Data generated by the user to be passed to the recipient

    /// @param _operatorData Data generated by the operator to be passed to the recipient

    /// @param _preventLocking `true` if you want this function to throw when tokens are sent to a contract not

    ///  implementing `ERC777tokensRecipient`.

    ///  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer

    ///  functions SHOULD set this parameter to `false`.

    function doSend(

        address _operator,

        address _from,

        address _to,

        uint256 _amount,

        bytes memory _data,

        bytes memory _operatorData,

        bool _preventLocking

    )

        internal

    {

        requireMultiple(_amount);



        callSender(_operator, _from, _to, _amount, _data, _operatorData);



        require(_to != address(0), "Cannot send to 0x0");

        require(mBalances[_from] >= _amount, "Not enough funds");



        mBalances[_from] = mBalances[_from].sub(_amount);

        mBalances[_to] = mBalances[_to].add(_amount);



        callRecipient(_operator, _from, _to, _amount, _data, _operatorData, _preventLocking);



        emit Sent(_operator, _from, _to, _amount, _data, _operatorData);

    }



    /// @notice Helper function actually performing the burning of tokens.

    /// @param _operator The address performing the burn

    /// @param _tokenHolder The address holding the tokens being burn

    /// @param _amount The number of tokens to be burnt

    /// @param _data Data generated by the token holder

    /// @param _operatorData Data generated by the operator

    function doBurn(

        address _operator,

        address _tokenHolder,

        uint256 _amount,

        bytes memory _data,

        bytes memory _operatorData

    )

        internal

    {

        callSender(_operator, _tokenHolder, address(0), _amount, _data, _operatorData);



        requireMultiple(_amount);

        require(balanceOf(_tokenHolder) >= _amount, "Not enough funds");



        mBalances[_tokenHolder] = mBalances[_tokenHolder].sub(_amount);

        mTotalSupply = mTotalSupply.sub(_amount);



        emit Burned(_operator, _tokenHolder, _amount, _data, _operatorData);

    }



    /// @notice Helper function that checks for ERC777TokensRecipient on the recipient and calls it.

    ///  May throw according to `_preventLocking`

    /// @param _operator The address performing the send or mint

    /// @param _from The address holding the tokens being sent

    /// @param _to The address of the recipient

    /// @param _amount The number of tokens to be sent

    /// @param _data Data generated by the user to be passed to the recipient

    /// @param _operatorData Data generated by the operator to be passed to the recipient

    /// @param _preventLocking `true` if you want this function to throw when tokens are sent to a contract not

    ///  implementing `ERC777TokensRecipient`.

    ///  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer

    ///  functions SHOULD set this parameter to `false`.

    function callRecipient(

        address _operator,

        address _from,

        address _to,

        uint256 _amount,

        bytes memory _data,

        bytes memory _operatorData,

        bool _preventLocking

    )

        internal

    {

        address recipientImplementation = interfaceAddr(_to, "ERC777TokensRecipient");

        if (recipientImplementation != address(0)) {

            ERC777TokensRecipient(recipientImplementation).tokensReceived(

                _operator, _from, _to, _amount, _data, _operatorData);

        } else if (_preventLocking) {

            require(isRegularAddress(_to), "Cannot send to contract without ERC777TokensRecipient");

        }

    }



    /// @notice Helper function that checks for ERC777TokensSender on the sender and calls it.

    ///  May throw according to `_preventLocking`

    /// @param _from The address holding the tokens being sent

    /// @param _to The address of the recipient

    /// @param _amount The amount of tokens to be sent

    /// @param _data Data generated by the user to be passed to the recipient

    /// @param _operatorData Data generated by the operator to be passed to the recipient

    ///  implementing `ERC777TokensSender`.

    ///  ERC777 native Send functions MUST set this parameter to `true`, and backwards compatible ERC20 transfer

    ///  functions SHOULD set this parameter to `false`.

    function callSender(

        address _operator,

        address _from,

        address _to,

        uint256 _amount,

        bytes memory _data,

        bytes memory _operatorData

    )

        internal

    {

        address senderImplementation = interfaceAddr(_from, "ERC777TokensSender");

        if (senderImplementation == address(0)) { return; }

        ERC777TokensSender(senderImplementation).tokensToSend(

            _operator, _from, _to, _amount, _data, _operatorData);

    }

}



contract ERC777ERC20BaseToken is ERC20Token, ERC777BaseToken {

    bool internal mErc20compatible;



    mapping(address => mapping(address => uint256)) internal mAllowed;



    constructor(

        string memory _name,

        string memory _symbol,

        uint256 _granularity,

        address[] memory _defaultOperators

    )

        internal ERC777BaseToken(_name, _symbol, _granularity, _defaultOperators)

    {

        mErc20compatible = true;

        setInterfaceImplementation("ERC20Token", address(this));

    }



    /// @notice This modifier is applied to erc20 obsolete methods that are

    ///  implemented only to maintain backwards compatibility. When the erc20

    ///  compatibility is disabled, this methods will fail.

    modifier erc20 () {

        require(mErc20compatible, "ERC20 is disabled");

        _;

    }



    /// @notice For Backwards compatibility

    /// @return The decimals of the token. Forced to 18 in ERC777.

    function decimals() public erc20 view returns (uint8) { return uint8(18); }



    /// @notice ERC20 backwards compatible transfer.

    /// @param _to The address of the recipient

    /// @param _amount The number of tokens to be transferred

    /// @return `true`, if the transfer can't be done, it should fail.

    function transfer(address _to, uint256 _amount) public erc20 returns (bool success) {

        doSend(msg.sender, msg.sender, _to, _amount, "", "", false);

        return true;

    }



    /// @notice ERC20 backwards compatible transferFrom.

    /// @param _from The address holding the tokens being transferred

    /// @param _to The address of the recipient

    /// @param _amount The number of tokens to be transferred

    /// @return `true`, if the transfer can't be done, it should fail.

    function transferFrom(address _from, address _to, uint256 _amount) public erc20 returns (bool success) {

        require(_amount <= mAllowed[_from][msg.sender], "Not enough funds allowed");



        // Cannot be after doSend because of tokensReceived re-entry

        mAllowed[_from][msg.sender] = mAllowed[_from][msg.sender].sub(_amount);

        doSend(msg.sender, _from, _to, _amount, "", "", false);

        return true;

    }



    /// @notice ERC20 backwards compatible approve.

    ///  `msg.sender` approves `_spender` to spend `_amount` tokens on its behalf.

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _amount The number of tokens to be approved for transfer

    /// @return `true`, if the approve can't be done, it should fail.

    function approve(address _spender, uint256 _amount) public erc20 returns (bool success) {

        _approve(msg.sender, _spender, _amount);

        return true;

    }



    /**

     * @dev Approve an address to spend another addresses' tokens.

     * @param owner The address that owns the tokens.

     * @param spender The address that will spend the tokens.

     * @param value The number of tokens that can be spent.

     */

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));

        require(owner != address(0));



        mAllowed[owner][spender] = value;

        emit Approval(owner, spender, value);

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when _allowed[msg.sender][spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public erc20 returns (bool) {

        _approve(msg.sender, spender, mAllowed[msg.sender][spender].add(addedValue));

        return true;

    }



    



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public erc20 returns (bool) {

        _approve(msg.sender, spender, mAllowed[msg.sender][spender].sub(subtractedValue));

        return true;

    }



    /// @notice ERC20 backwards compatible allowance.

    ///  This function makes it easy to read the `allowed[]` map

    /// @param _owner The address of the account that owns the token

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens of _owner that _spender is allowed

    ///  to spend

    function allowance(address _owner, address _spender) public erc20 view returns (uint256 remaining) {

        return mAllowed[_owner][_spender];

    }



    function doSend(

        address _operator,

        address _from,

        address _to,

        uint256 _amount,

        bytes memory _data,

        bytes memory _operatorData,

        bool _preventLocking

    )

        internal

    {

        super.doSend(_operator, _from, _to, _amount, _data, _operatorData, _preventLocking);

        if (mErc20compatible) { emit Transfer(_from, _to, _amount); }

    }



    function doBurn(

        address _operator,

        address _tokenHolder,

        uint256 _amount,

        bytes memory _data,

        bytes memory _operatorData

    )

        internal

    {

        super.doBurn(_operator, _tokenHolder, _amount, _data, _operatorData);

        if (mErc20compatible) { emit Transfer(_tokenHolder, address(0), _amount); }

    }

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     * @notice Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}





contract DATACHAIN is ERC777ERC20BaseToken, Ownable {

    string internal dName = "DATACHAIN";

    string internal dSymbol = "DC";

    uint256 internal dGranularity = 1;

    uint256 internal dTotalSupply = 1000000000 * (10**18);



    function dDefaultOperators() internal pure returns (address[] memory) {

        address[] memory defaultOps = new address[](1);

        

        defaultOps[0] = 0xa6903375509A5F4f740aEC4Aa677b8C18D41027b;

        

        return defaultOps;

    }



    constructor() public 

        ERC777ERC20BaseToken(

            dName, 

            dSymbol, 

            dGranularity, 

            dDefaultOperators()) 

    {

        _mint(msg.sender, dTotalSupply);

    }



    function _mint(address to, uint256 value) internal returns (bool) {



        require(to != address(0));



        requireMultiple(value);



        mTotalSupply = mTotalSupply.add(value);

        mBalances[to] = mBalances[to].add(value);



        callRecipient(msg.sender, address(0), to, value, "", "", true);





        emit Minted(msg.sender, to, value, "", "");



        emit Transfer(address(0), to, value);



        return true;

    }



    function mint(address to, uint256 value) public onlyOwner returns (bool) {

        _mint(to, value);

        return true;

    }

}