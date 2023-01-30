pragma solidity ^0.4.24;
/* import "./oraclizeAPI_0.5.sol"; */
import "./Owned.sol";
import "./BurnableToken.sol";
import "./KYCVerification.sol";

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract UTRAToken is Owned, BurnableToken {

    string public name = "SurePAY Utility, Transaction, Reward and Access Token.";
    string public symbol = "UTRA";
    uint8 public decimals = 5;
    
    uint256 public initialSupply = 8100000000 * (10 ** uint256(decimals));
    uint256 public totalSupply = 8100000000 * (10 ** uint256(decimals));
    uint256 public externalAuthorizePurchase = 0;
    
    
    mapping (address => bool) public frozenAccount;
    mapping(address => uint8) authorizedCaller;
    mapping (address => bool) public lockingEnabled;
    
    bool public kycEnabled = true;

    KYCVerification public kycVerification;

    event KYCMandateUpdate(bool _kycEnabled);
    event KYCContractAddressUpdate(KYCVerification _kycAddress);
    event LockFunds(address _buyer,bool _status);


    modifier onlyAuthCaller(){
        require(authorizedCaller[msg.sender] == 1 || msg.sender == owner);
        _;
    }
    
    /*
        check locking status of user address.
    */
    modifier lockingVerified(address _guy) {
        if(lockingEnabled[_guy] == true){
            revert("Account is locked");
        }
        _;
    }
    
    modifier kycVerified(address _guy) {
      if(kycEnabled == true){
          if(kycVerification.isVerified(_guy) == false)
          {
              revert("KYC Not Verified");
          }
      }
      _;
    }
    
     modifier frozenVerified(address _guy) {
        if(frozenAccount[_guy] == true)
        {
            revert("Account is freeze");
        }
        _;
    }

    function updateKycContractAddress(KYCVerification _kycAddress) public onlyOwner returns(bool)
    {
      kycVerification = _kycAddress;

      emit KYCContractAddressUpdate(_kycAddress);

      return true;
    }

    function updateKycMandate(bool _kycEnabled) public onlyAuthCaller returns(bool)
    {
        kycEnabled = _kycEnabled;
        emit KYCMandateUpdate(_kycEnabled);
        return true;
    }
    
    function forceUpdateLockStatus(address _holder,bool _lock) public onlyAuthCaller returns(bool)
    {
        lockingEnabled[_holder] = _lock;
        emit LockFunds(_holder, _lock);
        return true;
    }

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);
    
    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor() public {
        owner = msg.sender;
        balances[0x49156f159aAf87207fD54401eB1F73974968768C] = totalSupply;
        
        /* unlock totalSupply holder account */
        
        lockingEnabled[0x49156f159aAf87207fD54401eB1F73974968768C] = false;
        
        emit Transfer(address(0x0), address(this), totalSupply);
        emit Transfer(address(this), address(0x49156f159aAf87207fD54401eB1F73974968768C), totalSupply);
            
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }
    
    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }
    
    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    
    function () payable public {
        revert();
    }
    

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balances[_from] > _value);                // Check if the sender has enough
        require (balances[_to].add(_value) > balances[_to]); // Check for overflow
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the sender
        balances[_to] = balances[_to].add(_value);                           // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] = balances[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }


    function purchaseToken(address _receiver, uint _tokens) onlyAuthCaller public {
        require(_tokens > 0);
        require(initialSupply > _tokens);
        
        lockingEnabled[_receiver] = true;
        emit LockFunds(_receiver, true);
        
        initialSupply = initialSupply.sub(_tokens);
        _transfer(owner, _receiver, _tokens);              // makes the transfers
        externalAuthorizePurchase = externalAuthorizePurchase.add(_tokens);
    }

    /**
      * @dev transfer token for a specified address
      * @param _to The address to transfer to.
      * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public kycVerified(msg.sender) frozenVerified(msg.sender) lockingVerified(msg.sender)  returns (bool) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    /*
        Please make sure before calling this function from UI, Sender has sufficient balance for 
        All transfers 
    */
    function multiTransfer(address[] _to,uint[] _value) public kycVerified(msg.sender) frozenVerified(msg.sender) lockingVerified(msg.sender) returns (bool) {
        require(_to.length == _value.length, "Length of Destination should be equal to value");
        for(uint _interator = 0;_interator < _to.length; _interator++ )
        {
            _transfer(msg.sender,_to[_interator],_value[_interator]);
        }
        return true;    
    }
    
    /*
        Lock user address
    */
    function lockUserAddress() public returns(bool){
        lockingEnabled[msg.sender] = true;
        emit LockFunds(msg.sender, true);
    }
    
    /*
        Unlock User Address
    */
    function unlockUserAddress() public returns(bool){
        lockingEnabled[msg.sender] = false;
        emit LockFunds(msg.sender, false);
    }
}
