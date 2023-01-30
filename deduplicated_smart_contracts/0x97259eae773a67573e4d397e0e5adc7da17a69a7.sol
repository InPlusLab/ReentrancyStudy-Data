/**
uCAD is a Canadian Dollar Fiat Token developed and released by uFiats,
a UCASH Network initiative.  uCAD and other uFiats are used as
tokenized gift certificate currency units which are purchasable
and sellable through a global converter network.

UCASH Network partners, smart-contract Dapps, services,
initiatives and other 3rd parties can use uFiats to provide
a range of digital financial services.
*/

pragma solidity ^0.5.1;

import './IERC20.sol';
import './SafeMath.sol';
import './Ownable.sol';
import './Blacklistable.sol';
import './Pausable.sol';
import './ECDSA.sol';

/**
 * @title uCAD Fiat Token
 * @dev ERC20 Token backed by fiat reserves
 */


contract uCAD is IERC20, Ownable, Pausable, Blacklistable {
    using SafeMath for uint256;

    string public name = "uCAD Fiat Token";
    string public symbol = "uCAD";
    uint8 public decimals = 18;
    string public currency = "CAD";
    address public masterCreator;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;
    uint256 public totalSupply = 0;

    mapping(address => bool) internal creators;
    mapping(address => uint256) internal creatorAllowed;

    mapping(address=> uint256) internal metaNonces;

    event Create(address indexed creator, address indexed to, uint256 amount);
    event Destroy(address indexed destroyer, uint256 amount);
    event CreatorConfigured(address indexed creator, uint256 creatorAllowedAmount);
    event CreatorRemoved(address indexed oldCreator);
    event MasterCreatorChanged(address indexed newMasterCreator);

    constructor() public {
        masterCreator = msg.sender;
        pauser = msg.sender;
        blacklister = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than a creator
    */
    modifier onlyCreators() {
        require(creators[msg.sender] == true);
        _;
    }

    /**
     * @dev Function to create tokens
     * @param _to The address that will receive the createed tokens.
     * @param _amount The amount of tokens to create. Must be less than or equal to the creatorAllowance of the caller.
     * @return A boolean that indicates if the operation was successful.
    */
    function create(address _to, uint256 _amount) whenNotPaused onlyCreators notBlacklisted(msg.sender) notBlacklisted(_to) public returns (bool) {
        require(_to != address(0));
        require(_amount > 0);

        uint256 creatingAllowedAmount = creatorAllowed[msg.sender];
        require(_amount <= creatingAllowedAmount);

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        creatorAllowed[msg.sender] = creatingAllowedAmount.sub(_amount);
        emit Create(msg.sender, _to, _amount);
        emit Transfer(address(0x0), _to, _amount);
        return true;
    }

    /**
     * @dev Throws if called by any account other than the masterCreator
    */
    modifier onlyMasterCreator() {
        require(msg.sender == masterCreator);
        _;
    }

    /**
     * @dev Get creator allowance for an account
     * @param creator The address of the creator
    */
    function creatorAllowance(address creator) public view returns (uint256) {
        return creatorAllowed[creator];
    }

    /**
     * @dev Checks if account is a creator
     * @param account The address to check
    */
    function isCreator(address account) public view returns (bool) {
        return creators[account];
    }

    /**
     * @dev Function to add/update a new creator
     * @param creator The address of the creator
     * @param creatorAllowedAmount The reatingc amount allowed for the creator
     * @return True if the operation was successful.
    */
    function configureCreator(address creator, uint256 creatorAllowedAmount) whenNotPaused onlyMasterCreator public returns (bool) {
        creators[creator] = true;
        creatorAllowed[creator] = creatorAllowedAmount;
        emit CreatorConfigured(creator, creatorAllowedAmount);
        return true;
    }

    /**
     * @dev Function to remove a creator
     * @param creator The address of the creator to remove
     * @return True if the operation was successful.
    */
    function removeCreator(address creator) onlyMasterCreator public returns (bool) {
        creators[creator] = false;
        creatorAllowed[creator] = 0;
        emit CreatorRemoved(creator);
        return true;
    }

    /**
     * @dev allows a creator to destroy some of its own tokens
     * Validates that caller is a creator and that sender is not blacklisted
     * amount is less than or equal to the creator's account balance
     * @param _amount uint256 the amount of tokens to be destroyed
    */
    function destroy(uint256 _amount) whenNotPaused onlyCreators notBlacklisted(msg.sender) public {
        uint256 balance = balances[msg.sender];
        require(_amount > 0);
        require(balance >= _amount);

        totalSupply = totalSupply.sub(_amount);
        balances[msg.sender] = balance.sub(_amount);
        emit Destroy(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }

  /**
     * @dev allows masterCreator to allocate role to another address
     * Validates that caller is the current masterCreator
     * @param _newMasterCreator address the address to allocate role to
   */

    function updateMasterCreator(address _newMasterCreator) onlyOwner public {
        require(_newMasterCreator != address(0));
        masterCreator = _newMasterCreator;
        emit MasterCreatorChanged(masterCreator);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    /**
     * @dev Transfer token to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, allowed[from][msg.sender].sub(value));
        return true;
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev gets the payload to sign when a user wants to do a metaTransfer
     * @param _from uint256 address of the transferer
     * @param _to uint256 address of the recipient
     * @param value uint256 the amount of tokens to be transferred
     * @param fee uint256 the fee paid to the relayer in uCAD
     * @param nonce uint256 the metaNonce of the usere's metatransaction
    */
  function getTransferPayload(
        address _from,
        address _to,
        uint256 value,
        uint256 fee,
        uint256 nonce
    ) public
    view
    returns (bytes32 payload)
  {
    return ECDSA.toEthSignedMessageHash(
      keccak256(abi.encodePacked(
        "transfer",     // function specfic text
        _from,          // transferer.
        _to,            // recipient
        address(this),  // Token address (replay protection).
        value,          // Number of tokens.
        fee,            // fee paid to metaTransfer relayer, in uCAD
        nonce           // Local sender specific nonce (replay protection).
      ))
    );
  }


/**
     * @dev gets the payload to sign when a user wants to do a metaApprove
     * @param _from uint256 address of the approver
     * @param _to uint256 address of the approvee
     * @param value uint256 the amount of tokens to be approved
     * @param fee uint256 the fee paid to the relayer in uCAD
     * @param metaNonce uint256 the metaNonce of the usere's metatransaction
    */
    function getApprovePayload(
        address _from,
        address _to,
        uint256 value,
        uint256 fee,
        uint256 metaNonce
    ) public
    view
    returns (bytes32 payload)
  {
    return ECDSA.toEthSignedMessageHash(
      keccak256(abi.encodePacked(
        "approve",      // function specfic text
        _from,          // Approver.
        _to,            // Approvee
        address(this),  // Token address (replay protection).
        value,          // Number of tokens.
        fee,            // Local sender specific nonce (replay protection).
        metaNonce       // fee paid to metaApprove relayer, in uCAD
      ))
    );
  }


/**
     * @dev gets the payload to sign when a user wants to do a metaTransferFrom
     * @param _from uint256 the from address of the approver
     * @param _to uint256 address of the recipient
     * @param _by uint256 by address of the approvee
     * @param value uint256 the amount of tokens to be transferred
     * @param fee uint256 the fee paid to the relayer in uCAD
     * @param metaNonce uint256 the metaNonce of the usere's metatransaction
    */
    function getTransferFromPayload(
        address _from,
        address _to,
        address _by,
        uint256 value,
        uint256 fee,
        uint256 metaNonce
    ) public
    view
    returns (bytes32 payload)
  {
    return ECDSA.toEthSignedMessageHash(
      keccak256(abi.encodePacked(
        "transferFrom",     // function specfic text
        _from,              // Approver
        _to,                // Recipient
        _by,                // Approvee
        address(this),      // Token address (replay protection).
        value,              // Number of tokens.
        fee,                // fee paid to metaApprove relayer, in uCAD
        metaNonce           // Local sender specific nonce (replay protection).
      ))
    );
  }

  /**
     * @dev gets the current metaNonce of an address
     * @param sender address of the metaTransaction sender
 **/
  function getMetaNonce(address sender) public view returns (uint256) {
    return metaNonces[sender];
  }

   /**
     * @dev extra getter function to potentially satisfy ERC1776
     * @param _from address of the metaTransaction sender
 **/

  function meta_nonce(address _from) external view returns (uint256 nonce) {
        return metaNonces[_from];
    }


  /**
     * @dev function to validate a signiture with a given address and payload that has been signed
 **/
  function isValidSignature(
    address _signer,
    bytes32 payload,
    bytes memory signature
  )
    public
    pure
    returns (bool)
  {
    return (_signer == ECDSA.recover(
      ECDSA.toEthSignedMessageHash(payload),
      signature
    ));
  }
 /**
     * @dev Emitted when metaTransfer is successfully executed
     */
      event MetaTransfer(address indexed relayer, address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when metaApprove is successfully executed
     */
    event MetaApproval(address indexed relayer, address indexed owner, address indexed spender, uint256 value);


    /**
     * @dev metaTransfer function called by relayer which executes a token transfer
     * on behalf of the original sender who provided a vaild signature.
     * @param _from address of the original sender
     * @param _to address of the  recipient
     * @param value uint256 amount of uCAD being sent
     * @param fee uint256 uCAD fee rewarded to the relayer
     * @param metaNonce uint256 metaNonce of the original sender
     * @param signature bytes signature provided by original sender
     */
  function metaTransfer(
        address _from,
        address _to,
        uint256 value,
        uint256 fee,
        uint256 metaNonce,
        bytes memory signature
  ) public returns (bool success) {


    // Verify and increment nonce.
    require(getMetaNonce(_from) == metaNonce);
    metaNonces[_from] = metaNonces[_from].add(1);
    // Verify signature.
    bytes32 payload = getTransferPayload(_from,_to, value, fee, metaNonce);
    require(isValidSignature(_from,payload,signature));

    require(_from != address(0));

    //_transfer(sender,receiver,value);
    _transfer(_from,_to,value);
    //send Fee to metaTx miner
    _transfer(_from,msg.sender,fee);

    emit MetaTransfer(msg.sender, _from,_to,value);
    return true;
  }

/**
     * @dev metaApprove function called by relayer which executes a token approval
     * on behalf of the original sender who provided a vaild signature.
     * @param _from address of the original approver
     * @param _to address of the  recipient
     * @param value uint256 amount of uCAD being sent
     * @param fee uint256 uCAD fee rewarded to the relayer
     * @param metaNonce uint256 metaNonce of the original approver
     * @param signature bytes signature provided by original approver
     */
    function metaApprove(
        address _from,
        address _to,
        uint256 value,
        uint256 fee,
        uint256 metaNonce,
        bytes memory signature
    ) public returns (bool success) {
    // Verify and increment nonce.
    require(getMetaNonce(_from) == metaNonce);
    metaNonces[_from] = metaNonces[_from].add(1);

    // Verify signature.
    bytes32 payload = getApprovePayload(_from,_to, value, fee,metaNonce);
    require(isValidSignature(_from, payload, signature));

    require(_from != address(0));

    //_approve(sender,receiver,value);
    _approve(_from,_to,value);

    //send Fee to metaTx miner
    _transfer(_from,msg.sender,fee);

    emit MetaApproval(msg.sender,_from,_to,value);
    return true;
    }


/**
     * @dev metaTransferFrom function called by relayer which executes a token transferFrom
     * on behalf of the original sender who provided a vaild signature.
     * @param _from address of the original sender
     * @param _to address of the  recipient
     * @param value uint256 amount of uCAD being sent
     * @param fee uint256 uCAD fee rewarded to the relayer
     * @param metaNonce uint256 metaNonce of the original sender
     * @param signature bytes signature provided by original sender
     */
    function metaTransferFrom(
        address _from,
        address _to,
        address _by,
        uint256 value,
        uint256 fee,
        uint256 metaNonce,
        bytes memory signature
        ) public returns(bool){
    // Verify and increment nonce.
    require(getMetaNonce(_by) == metaNonce);
    metaNonces[_by] = metaNonces[_by].add(1);

    // Verify signature.
    bytes32 payload = getTransferFromPayload(_from,_to,_by, value,fee, metaNonce);
    require(isValidSignature(_by, payload, signature));

    require(_by != address(0));

    //_transfer(sender,receiver,value);
    _transfer(_from,_to,value);

      //send Fee to metaTx miner
    _transfer(_by,msg.sender,fee);

    //subtract approved amount by value+fee
    _approve(_from, _by, allowed[_from][_by].sub(value));

    emit MetaTransfer(msg.sender, _from,_to,value);

    return true;
    }

       /**
     * @dev Transfer token for a specified addresses.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
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

        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}
