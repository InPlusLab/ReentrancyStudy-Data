/**
 *  MultiSig.sol v1.1.0
 * 
 *  Bilal Arif - https://twitter.com/furusiyya_
 *  Draglet GbmH
 */

pragma solidity 0.4.19;


library SafeMath {
  function mul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) pure internal returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) pure internal returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) pure internal returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) pure internal returns (uint256) {
    return a < b ? a : b;
  }

}

contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private rentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }

}

/**
 * MultiSig is designed to hold funds of the ico. Account is controlled by four administratos. To trigger a payout
 * three out of four administrators will must agree on same amount of ethers to be transferred. During the signing
 * process if one administrator sends different targetted address or amount of ethers, process will abort and they
 * need to start again.
 * Administrator can be replaced but three out of four must agree upon replacement of fourth administrator. Three
 * admins will send address of fourth administrator along with address of new one administrator. If a single one
 * sends different address the updating process will abort and they need to start again. 
 */

contract MultiSig is ReentrancyGuard{
  
  using SafeMath for uint256;
  
  // Maintain state funds transfer signing process
  struct Transaction{
    address[3] signer;
    uint confirmations;
    uint256 eth;
  }
  
  // count and record signers with ethers they agree to transfer
  Transaction private  pending;
    
  // the number of administrator that must confirm the same operation before it is run.
  uint256 constant public required = 3;

  mapping(address => bool) private administrators;
 
  // Funds has arrived into the contract (record how much).
  event Deposit(address _from, uint256 value);
  
  // Funds transfer to other contract
  event Transfer(address indexed fristSigner, address indexed secondSigner, address indexed thirdSigner, address to,uint256 eth,bool success);
  
  // Administrator successfully signs a fund transfer
  event TransferConfirmed(address signer,uint256 amount,uint256 remainingConfirmations);
  
  // Administrator successfully signs a key update transaction
  event UpdateConfirmed(address indexed signer,address indexed newAddress,uint256 remainingConfirmations);
  
  
  // Administrator violated consensus
  event Violated(string action, address sender); 
  
  // Administrator key updated (administrator replaced)
  event KeyReplaced(address oldKey,address newKey);

  event EventTransferWasReset();
  event EventUpdateWasReset();
  
  
  function MultiSig() public {

    administrators[0x8E0c5A1b55d4E71B7891010EF504b11f19F4c466] = true;
    administrators[0x5e77156CD35574A1dAC125992B73b3C5a973a4eb] = true;
    administrators[0x604EdF8FE01db0AdafED4701F5De42b15067d23c] = true;
    administrators[0xed4C73Ad76D90715d648797Acd29A8529ED511A0] = true;

  }
  
  /**
   * @dev  To trigger payout three out of four administrators call this
   * function, funds will be transferred right after verification of
   * third signer call.
   * @param recipient The address of recipient
   * @param amount Amount of wei to be transferred
   */
  function transfer(address recipient, uint256 amount) external onlyAdmin nonReentrant {
    
    // input validations
    require( recipient != 0x00 );
    require( amount > 0 );
    require( this.balance >= amount);

    uint remaining;
    
    // Start of signing process, first signer will finalize inputs for remaining two
    if(pending.confirmations == 0){
        
        pending.signer[pending.confirmations] = msg.sender;
        pending.eth = amount;
        pending.confirmations = pending.confirmations.add(1);
        remaining = required.sub(pending.confirmations);
        TransferConfirmed(msg.sender,amount,remaining);
        return;
    
    }
    
    // Compare amount of wei with previous confirmtaion
    if(pending.eth != amount){
        transferViolated("Incorrect amount of wei passed");
        return;
    }
    
    // make sure signer is not trying to spam
    if(msg.sender == pending.signer[0]){
        transferViolated("Signer is spamming");
        return;
    }
    
    pending.signer[pending.confirmations] = msg.sender;
    pending.confirmations = pending.confirmations.add(1);
    remaining = required.sub(pending.confirmations);
    
    // make sure signer is not trying to spam
    if( remaining == 0){
        if(msg.sender == pending.signer[1]){
            transferViolated("One of signers is spamming");
            return;
        }
    }
    
    TransferConfirmed(msg.sender,amount,remaining);
    
    // If three confirmation are done, trigger payout
    if (pending.confirmations == 3){
        if(recipient.send(amount)){
            Transfer(pending.signer[0],pending.signer[1], pending.signer[2], recipient,amount,true);
        }else{
            Transfer(pending.signer[0],pending.signer[1], pending.signer[2], recipient,amount,false);
        }
        ResetTransferState();
    } 
  }
  
  function transferViolated(string error) private {
    Violated(error, msg.sender);
    ResetTransferState();
  }
  
  function ResetTransferState() internal
  {
      delete pending;
      EventTransferWasReset();
  }


  /**
   * @dev Reset values of pending (Transaction object)
   */
  function abortTransaction() external onlyAdmin{
       ResetTransferState();
  }
  
  /** 
   * @dev Fallback function, receives value and emits a deposit event. 
   */
  function() payable public {
    // just being sent some cash?
    if (msg.value > 0)
      Deposit(msg.sender, msg.value);
  }

  /**
   * @dev Checks if given address is an administrator.
   * @param _addr address The address which you want to check.
   * @return True if the address is an administrator and fase otherwise.
   */
  function isAdministrator(address _addr) public constant returns (bool) {
    return administrators[_addr];
  }
  
  // Maintian state of administrator key update process
  struct KeyUpdate{
    address[3] signer;
    uint confirmations;
    address oldAddress;
    address newAddress;
  }
  
  KeyUpdate private updating;
  
  /**
   * @dev Three admnistrator can replace key of fourth administrator. 
   * @param _oldAddress Address of adminisrator needs to be replaced
   * @param _newAddress Address of new administrator
   */
  function updateAdministratorKey(address _oldAddress, address _newAddress) external onlyAdmin {
    
    // input verifications
    require(isAdministrator(_oldAddress));
    require( _newAddress != 0x00 );
    require(!isAdministrator(_newAddress));
    require( msg.sender != _oldAddress );
    
    // count confirmation 
    uint256 remaining;
    
    // start of updating process, first signer will finalize address to be replaced
    // and new address to be registered, remaining two must confirm
    if( updating.confirmations == 0){
        
        updating.signer[updating.confirmations] = msg.sender;
        updating.oldAddress = _oldAddress;
        updating.newAddress = _newAddress;
        updating.confirmations = updating.confirmations.add(1);
        remaining = required.sub(updating.confirmations);
        UpdateConfirmed(msg.sender,_newAddress,remaining);
        return;
        
    }
    
    // violated consensus
    if(updating.oldAddress != _oldAddress){
        Violated("Old addresses do not match",msg.sender);
        ResetUpdateState();
        return;
    }
    
    if(updating.newAddress != _newAddress){
        Violated("New addresses do not match",msg.sender);
        ResetUpdateState();
        return; 
    }
    
    // make sure admin is not trying to spam
    if(msg.sender == updating.signer[0]){
        Violated("Signer is spamming",msg.sender);
        ResetUpdateState();
        return;
    }
        
    updating.signer[updating.confirmations] = msg.sender;
    updating.confirmations = updating.confirmations.add(1);
    remaining = required.sub(updating.confirmations);

    if( remaining == 0){
        if(msg.sender == updating.signer[1]){
            Violated("One of signers is spamming",msg.sender);
            ResetUpdateState();
            return;
        }
    }

    UpdateConfirmed(msg.sender,_newAddress,remaining);
    
    // if three confirmation are done, register new admin and remove old one
    if( updating.confirmations == 3 ){
        KeyReplaced(_oldAddress, _newAddress);
        ResetUpdateState();
        delete administrators[_oldAddress];
        administrators[_newAddress] = true;
        return;
    }
  }
  
  function ResetUpdateState() internal
  {
      delete updating;
      EventUpdateWasReset();
  }

  /**
   * @dev Reset values of updating (KeyUpdate object)
   */
  function abortUpdate() external onlyAdmin{
      ResetUpdateState();
  }
  
  /**
   * @dev modifier allow only if function is called by administrator
   */
  modifier onlyAdmin(){
      if( !administrators[msg.sender] ){
          revert();
      }
      _;
  }
}