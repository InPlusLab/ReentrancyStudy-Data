/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

pragma solidity 0.5.4;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
contract IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor () public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Contract for CertificateBase
 * Copyright 2019, Hiway Blockchain Systems (Hiway.com)
 */
contract CertificateBase {
    
    // Address used by off-chain controller service to sign certificate
    mapping(address => bool) internal _certificateSigners;
    mapping(address => uint256) internal _checkCount;
    
    event Checked(address sender);
    
    /**
    * @dev Set signer authorization for operator.
    * @param operator Address to add/remove as a certificate signer.
    * @param authorized 'true' if operator shall be accepted as certificate signer, 'false' if not.
    */
    function _setCertificateSigner(address operator, bool authorized) internal {
      require(operator != address(0), "Action Blocked - Not a valid address");
      _certificateSigners[operator] = authorized;
    }
    
    function _checkCertificate(bytes memory _data, bytes4 _function) internal view returns(bool) {
        bytes memory sig = _extractBytes(_data, 0, 65);    // signature generated on offchain
        bytes memory expHex = _extractBytes(_data, 65, 4); // expiration timestamp in Hex;
        uint expUnix = _bytesToUint(expHex);               // expiration timestamp in Unix;

        require(expUnix > now, 'Certificate Expired');
       
        bytes32 txHash = _getSignHash(_getPreSignedHash(_function, address(this), expUnix, _checkCount[msg.sender]));
       
        address recovered = _ecrecoverFromSig(txHash, sig);
          
        return _certificateSigners[recovered];
    }
    
    function _ecrecoverFromSig(bytes32 hash, bytes memory sig) internal pure returns (address recoveredAddress) 
    {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (sig.length != 65) return address(0);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return ecrecover(hash, v, r, s);
    }
    
    function _getPreSignedHash(bytes4 _function, address _address, uint _expiration, uint _nonce) internal pure returns(bytes32) {
         return keccak256(abi.encodePacked(_function, _address, _expiration, _nonce));
    }
    
    function _getSignHash(bytes32 _hash) internal pure returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }
    
    function _getRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(hash, v, r, s);
    }
    
    function getFunctionId(string calldata _function) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_function));
    }
    
    function _getStringHash(string memory _str) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_str));
    }
    
    function _extractBytes(bytes memory _data, uint _pos, uint _length) internal pure returns(bytes memory) {
        bytes memory result = new bytes(_length);
        for(uint i = 0;i< _length; i++) {
           result[i] = _data[_pos + i];
        }
        return result;
    }
    
    function _bytesToUint(bytes memory _data) internal pure returns(uint256){
        uint256 number;
        for(uint i=0;i<_data.length;i++){
            number = number + uint8(_data[i])*(2**(8*(_data.length-(i+1))));
        }
        return number;
    }
}


/**
 * @title Contract for CertificateController
 * Copyright 2019, Hiway Blockchain Systems (Hiway.com)
 */
contract CertificateController is Ownable, CertificateBase {
    
    /**
     * @dev Modifier to protect methods with certificate control
     */
    modifier isValidCertificate(bytes memory data, bytes4 _function) {
        require(_certificateSigners[msg.sender] || _checkCertificate(data, _function), "Transfer Blocked - Sender lockup period not ended");

        _checkCount[msg.sender] += 1; // Increment sender check count

        emit Checked(msg.sender);
        _;
    }
    
    /**
     * @dev Set signer authorization for operator.
     * @param operator Address to add/remove as a certificate signer.
     * @param authorized 'true' if operator shall be accepted as certificate signer, 'false' if not.
     */
    function setCertificateSigner(address operator, bool authorized) external onlyOwner {
        require(operator != address(0), "Address should not be zero");
        _setCertificateSigner(operator, authorized);
    }
    

   /**
    * @dev Get number of transations already sent to this contract by the sender
    * @param sender Address whom to check the counter of.
    * @return uint256 Number of transaction already sent to this contract.
    */
   function checkCount(address sender) external view returns (uint256) {
     return _checkCount[sender];
   }

   /**
    * @dev Get certificate signer authorization for an operator.
    * @param operator Address whom to check the certificate signer authorization for.
    * @return bool 'true' if operator is authorized as certificate signer, 'false' if not.
    */
   function certificateSigners(address operator) external view returns (bool) {
     return _certificateSigners[operator];
   }
   
   /**
    * @dev Get Blockchain timestamp 
    */
   function getBlockTime() external view returns (uint) {
        return now;
   }
}


/**
 * @title Contract for HiwayController
 * Copyright 2019, Hiway Blockchain Systems (Hiway.com)
 */
contract HiwayController is Ownable {
  
  // Array of controllers.
  address[] internal _controllers;

  // Mapping of controller status.
  mapping(address => bool) internal _isController;
  
  modifier onlyController() {
        require(_isController[msg.sender] , "Only Controller can execute");
        _;
  }
    
  /**
   * @dev Get the list of controllers.
   * @return List of addresses of all the controllers.
   */
  function controllers() external view returns (address[] memory) {
    return _controllers;
  }
  
  /**
   *
   * @dev Set list of token controllers.
   * @param operators Controller addresses.
   */
  function setControllers(address[] calldata operators) external onlyOwner {
    _setControllers(operators);
  }
  
  /**
   * @dev Set list of token controllers.
   * @param operators Controller addresses.
   */
  function _setControllers(address[] memory operators) internal {
    for (uint i = 0; i<_controllers.length; i++){
      _isController[_controllers[i]] = false;
    }
    for (uint j = 0; j<operators.length; j++){
      _isController[operators[j]] = true;
    }
    _controllers = operators;
  }
}

/**
 * @title Contract for HiwayTokenManagement
 * Copyright 2019, Hiway Blockchain Systems (Hiway.com)
 */
contract HiwayTokenManagement is Ownable {

  // Array of tokens.  
  address[] internal _tokens;

  // Mappfing of token instance
  mapping(address => IERC20) internal _tokenInstances;
  // Mapping of token status.
  mapping(address => bool) internal _isToken;
    
  /**
  * @dev Get the list of tokens.
  * @return List of addresses of all the tokens.
  */
  function tokens() external view returns (address[] memory) {
    return _tokens;
  }
  
  /**
   *
   * @dev Set list of operators.
   * @param operators Controller addresses.
   */
  function setTokens(address[] calldata operators) external onlyOwner {
    _setTokens(operators);
  }
  
  /**
  * @dev Set list of operators.
  * @param operators addresses.
  */
  function _setTokens(address[] memory operators) internal {
    for (uint i = 0; i<_tokens.length; i++){
      _isToken[operators[i]] = false;
    }
    for (uint j = 0; j<operators.length; j++){
      _isToken[operators[j]] = true;
      _tokenInstances[operators[j]] = IERC20(operators[j]);
    }
    _tokens = operators;
  }
}

/**
 * @title Contract for HiwayEscrowBase
 * Copyright 2019, Hiway Blockchain Systems (Hiway.com)
 */
contract HiwayEscrowBase is HiwayController, HiwayTokenManagement, CertificateController {
    using SafeMath for uint;

    address public feeAccount;
    
    uint8 public feeMul = 3; // escrow percent fee, default 3%
    uint public jobId;       // increase job id

    struct Job {
        string name;
        address token;
        address client;
        address worker;
        uint amount;

        uint releasedAmount;
        uint refundedAmount;

        uint createdTime;
        uint estimatedTime;
        uint finishedTime;

        uint8 status;       // 0: created, 1: accepted, 2: declined,  3: closed, 4: completed
        bool refundable;
    }

    mapping (uint => Job) public jobs;
    mapping (address => uint[]) public clientJobIds;
    mapping (address => uint[]) public workerJobIds;
    

    modifier onlyClient(uint _id) {
        require(msg.sender == jobs[_id].client , "Only Client can execute");
        _;
    }

    modifier onlyWorker(uint _id) {
        require(msg.sender == jobs[_id].worker , "Only Worker can execute");
        _;
    }

    event CreateJob(address indexed _client, uint _id);
    event AcceptJob(address indexed _worker, uint _id);
    event DeclineJob(address indexed _worker, uint _id);
    event CloseJob(address indexed _address, uint _id);
    event CompleteJob(address indexed _client, uint _id);
    event DepositJob(address indexed _client, uint _id);
    event RefundJob(address indexed _address, uint _id);
    event ReleaseJob(address indexed _client, uint _id);
    event ClaimJob(address indexed _worker, uint _id);
    event WithdrawHoldAmount(address indexed _to, uint _amount);
    event SetRefundable(address indexed _address, uint _id);
    
    /**
    * @dev The HiwayEscrowBase constructor.
    */
    constructor(address _feeAccount, uint8 _fee) public {
        feeAccount = _feeAccount;
        feeMul = _fee;
    }

    /**
    * @dev Return Job Info
    * @param _id uint The Job Id which will get Job Info
    * @return job that represents current info;
    */
    function returnJobInfo(uint _id)
    external view returns (
        string memory, 
        address, 
        address, 
        uint, 
        uint, 
        uint, 
        uint, 
        uint, 
        uint, 
        uint,
        address, 
        bool
    ) {
        require(_id >= 0, "Job ID should not be greather than zero");
        Job storage job = jobs[_id];

        return (
            job.name, 
            job.client, 
            job.worker, 
            job.amount, 
            job.releasedAmount, 
            job.refundedAmount, 
            job.createdTime, 
            job.estimatedTime, 
            job.finishedTime, 
            job.status,
            job.token, 
            job.refundable
        );
    }

    /**
    * @dev Return Job Ids that client created
    * @param _client address The Address which will get JobIds
    * @return uint[] that represents created job Ids;
    */
    function returnClientJobIds(address _client) external view returns (uint[] memory) {
        return clientJobIds[_client];
    }

    /**
    * @dev Return Job Ids that awarded to worker
    * @param _worker address The Address which will get JobIds
    * @return uint[] that represents created job Ids;
    */
    function returnWorkerJobIds(address _worker) external view returns (uint[] memory) {
        return workerJobIds[_worker];
    }

    /********************** HiwayEscrowBase INTERNAL FUNCTIONS **************************/
    
    /**
    * [INTERNAL]
    * @dev Function to create a job.
    * @param _name string The name which will present job's name.
    * @param _tokenAddress address that represents Token
    * @param _client address The address which will present client.
    * @param _worker address The address which will present worker.
    * @param _amount uint initial depositAmount
    * @param _estimatedTime uint The estimatedTime which will present as epochtime.
    * @return jobId if the operation was successful.
    */
    function _create(
        string memory _name, 
        address _tokenAddress, 
        address _client, 
        address _worker,
        uint _amount,
        uint _estimatedTime
        ) internal returns (uint) {
        jobId ++;

        jobs[jobId] = Job({
            token: _tokenAddress,
            name : _name,
            client : _client,
            worker : _worker,
            amount : 0,
            releasedAmount : 0,
            refundedAmount : 0,
            createdTime: now,
            estimatedTime : _estimatedTime,
            finishedTime : 0,
            status: 0,
            refundable: true
            });

        clientJobIds[_client].push(jobId);
        workerJobIds[_worker].push(jobId);

        emit CreateJob(_client, jobId);
        
        if(_amount > 0) {
            _deposit(jobs[jobId], jobId, _amount);
        }
        return jobId;
    }
    
    /**
    * [INTERNAL]
    * @dev Function to accept job.
    * @param _job Job.
    * @param _id uint The Job Id which will accept.
    */
    function _accept(Job storage _job, uint _id) internal {
        _job.status = 1;
        _job.refundable = false;
        
        emit AcceptJob(_job.worker, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to claim job.
    * @param _job Job
    * @param _id uint The Job Id which will claim.
    * @param _amount uint
    */
    function _claim(Job storage _job, uint _id, uint _amount) internal{
        IERC20  token = _tokenInstances[_job.token];
        
        require(_job.amount.sub(_job.releasedAmount) >= _amount, "Insufficient blance");

        _job.releasedAmount = _job.releasedAmount.add(_amount);

        token.transfer(_job.worker, _amount);

        emit ClaimJob(_job.worker, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to release job.
    * @param _job Job
    * @param _id uint The Job Id which will release.
    * @param _amount uint
    */
    function _release(Job storage _job, uint _id, uint _amount) internal {
        IERC20  token = _tokenInstances[_job.token];
        
        require(_job.amount.sub(_job.releasedAmount) >= _amount, "Insufficient blance");

        _job.releasedAmount = _job.releasedAmount.add(_amount);

        token.transfer(_job.worker, _amount);
        
        emit ReleaseJob(_job.client, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to deposit job.
    * @param _job Job
    * @param _id uint The Job Id which will deposit.
    * @param _amount uint
    */
    function _deposit(Job storage _job, uint _id, uint _amount) internal {
        IERC20  token = _tokenInstances[_job.token];
        
        uint fee = (_amount * feeMul) / 100;
        require(token.balanceOf(_job.client) >= (_amount + fee), "Insufficient balance");

        _job.amount = _job.amount.add(_amount);

        token.transferFrom(_job.client, address(this), _amount);
        token.transferFrom(_job.client, feeAccount, fee);

        emit DepositJob(_job.client, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to refund job.
    * @param _job Job
    * @param _id uint The Job Id which will refund.
    * @param _refundAmount uint
    * @param _address address
    */
    function _refund(Job storage _job, uint _id, uint _refundAmount, address _address) internal {
        IERC20  token = _tokenInstances[_job.token];
        require(_job.amount.sub(_job.releasedAmount) >= _refundAmount, "Insufficient blance");

        _job.amount = _job.amount.sub(_refundAmount);
        _job.refundedAmount = _job.refundedAmount.add(_refundAmount);
        _job.refundable = false;
        
        token.transfer(_job.client, _refundAmount);
            
        emit RefundJob(_address, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to decline job.
    * @param _job Job
    * @param _id uint The Job Id which will decline.
    */
    function _decline (Job storage _job, uint _id) internal {
        _job.status = 2; // declined
        _job.finishedTime = now;
        
        emit DeclineJob(_job.worker, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to close job.
    * @param _job Job
    * @param _id uint The Job Id which will close.
    */
    function _close (Job storage _job, uint _id, address _address) internal {
        _job.status = 3; // closed
        _job.finishedTime = now;
        
        emit CloseJob(_address, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to complete job.
    * @param _job Job
    * @param _id uint The Job Id which will close.
    */
    function _complete (Job storage _job, uint _id) internal {
        _job.status = 4; // complete
        _job.finishedTime = now;
        
        emit CompleteJob(_job.client, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to set Refundable to a job.
    * @param _job Job
    * @param _id uint The Job Id which will set Refundable.
    * @param _controller address
    */
    function _setRefundable(Job storage _job, uint _id, address _controller) internal {
        _job.refundable = true;
         
        emit SetRefundable(_controller, _id);
    }
    
    /**
    * [INTERNAL]
    * @dev Function to set an address to send fees.
    * @param _feeAccount address The address which will set.
    */
    function _setFeeAccount(address _feeAccount) internal {
        feeAccount = _feeAccount;
    }

    /**
    * [INTERNAL]
    * @dev Function to set fee percent.
    * @param _fee uint8 This fee which will set.
    */
    function _setFee (uint8 _fee) internal {
        feeMul = _fee;
    }
}


/**
 * @title Contract for HiwayEscrow
 * Copyright 2019, Hiway Blockchain Systems (Hiway.com)
 */
contract HiwayEscrow is Ownable, HiwayEscrowBase
{
    using SafeMath for uint;

    /**
    * @dev The HiwayEscrow constructor.
    */
    constructor(address _feeAccount, uint8 _fee) public 
    HiwayEscrowBase(_feeAccount, _fee) {
        require(_feeAccount != address(0), "Address should not be zero");
        require(_fee >= 0 && _fee < 100, "Fee percent should be less than 100");
    }

    /**
    * @dev Function to create a job.
    * @param _name string The name which will present job's name.
    * @param _tokenAddress address that represents Token
    * @param _worker address The address which will present worker.
    * @param _estimatedTime uint The estimatedTime which will present as epochtime.
    * @param _data bytes memory
    * @return jobId if the operation was successful.
    */
    function create(
        string memory _name, 
        address _tokenAddress, 
        address _worker, 
        uint _amount,
        uint _estimatedTime, 
        bytes memory _data ) public 
        isValidCertificate(_data, 0x8803719f) returns (uint) {
        address client = msg.sender;
        
        require(_tokenAddress != address(0), "Address should not be zero");
        require(_isToken[_tokenAddress], "Token should be registered");
        require(_worker != address(0), "Address should not be zero");
        require(client != address(0), "Address should not be zero");
        require(_amount >= 0, "Amount should be greater than zero");
        require(_estimatedTime >=0, "EstimatedTime should be equals greater than zero");
        
        return _create(_name, _tokenAddress, client, _worker, _amount, _estimatedTime);
    }
    
    /**
    * @dev Function to accept job.
    * @param _id uint The Job Id which will accept.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function accept(uint _id, bytes memory _data) public onlyWorker(_id) 
    isValidCertificate(_data, 0xc931b330) returns (bool) {
        Job storage job = jobs[_id];
        
        require(job.status == 0, "Only available during employer does not accept job");

        _accept(job, _id);
        
        return true;
    }
    
    /**
    * @dev Function to decline job.
    * @param _id uint The Job Id which will close.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function decline(uint _id, bytes memory _data) public onlyWorker(_id) 
    isValidCertificate(_data, 0x9385e3ac) returns (bool) {
        address worker = msg.sender;
        require(worker != address(0), "Address should not be zero");
        Job storage job = jobs[_id];
        
        require(job.status == 1, "Only available during employer did accept job");

        _decline(job, _id);
        _refund(job, _id, job.amount, worker);
        
        return true;
    }

    /**
    * @dev Function to close job.
    * @param _id uint The Job Id which will close.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function close(uint _id, bytes memory _data) public onlyClient(_id) 
    isValidCertificate(_data, 0x0d7dad84) returns (bool) {
        address client = msg.sender;
        require(client != address(0), "Address should not be zero");
        Job storage job = jobs[_id];

        require(job.status == 0, "Only available during woker does not accept job");

        _close(job, _id, client);
        _refund(job, _id, job.amount, client);

        return true;
    }

    /**
    * @dev Function to complete job.
    * @param _id uint The Job Id which will complete.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function complete(uint _id, bytes memory _data) public onlyClient(_id) 
    isValidCertificate(_data, 0x7da64a23) returns (bool) {
        address client = msg.sender;
        require(client != address(0), "Address should not be zero");
        Job storage job = jobs[_id];
        
        require(job.status != 3 || job.status != 4, "Available once unclosed or uncompleted");

        _complete(job, _id);
        
        return true;
    }

    /**
    * @dev Function to deposit amount of tokens.
    * @param _id uint The Job Id which will deposit to.
    * @param _amount uint The Amount which will deposit.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function deposit(uint _id, uint _amount, bytes memory _data) public onlyClient(_id) 
    isValidCertificate(_data, 0x48c73f68) returns (bool) {
        address client = msg.sender;
        require(client != address(0), "Address should not be zero");
        require(_amount > 0, "Amount should be greater than zero");
        require(feeAccount != address(0), "Address should not be zero");
        
        Job storage job = jobs[_id];
        
        _deposit(job, _id, _amount);
        
        return true;
    }

    /**
    * @dev Function to refund amount of tokens.
    * @param _id uint The Job Id which will refund from.
    * @param _amount uint The Amount which will refund.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function refund(uint _id, uint _amount, bytes memory _data) public onlyClient(_id) 
    isValidCertificate(_data, 0x4fd96796) returns (bool) {
        address client = msg.sender;
        require(client != address(0), "Address should not be zero");
        require(_amount > 0, "Amount should be greater than zero");

        Job storage job = jobs[_id];

        require(job.status != 3 || job.status != 4, "Available once unclosed or uncompleted");
        require(job.refundable == true);
        
        _refund(job, _id, _amount, client);
         
        return true;
    }
    
    /**
    * @dev Function to refund job by worker.
    * @param _id uint The Job Id which will close.
    * @param _amount uint The Amount which will refund.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function refundByWorker(uint _id, uint _amount, bytes memory _data) public onlyWorker(_id) 
    isValidCertificate(_data, 0xf862ee7d) returns (bool) {
        address worker = msg.sender;
        require(worker != address(0), "Address should not be zero");
        Job storage job = jobs[_id];
 
        require(job.status == 1, "Only available during woker accept job");

        _refund(job, _id, _amount, worker);
       
        return true;
    }

    /**
    * @dev Function to release amount of tokens.
    * @param _id uint The Job Id which will release from.
    * @param _amount uint The Amount which will release.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function release(uint _id, uint _amount, bytes memory _data) public onlyClient(_id) 
    isValidCertificate(_data, 0x585a6dc6) returns (bool) {
        address client = msg.sender;
        require(client != address(0), "Address should not be zero");
        require(_amount > 0, "Amount should be greater than zero");

        Job storage job = jobs[_id];
        
        require(job.status != 3 || job.status != 4, "Available once unclosed or uncompleted");
        
        _release(job, _id, _amount);
        
        return true;
    }

    /**
    * @dev Function to claim amount of tokens.
    * @param _id uint The Job Id which will claim from.
    * @param _amount uint The Amount which will claim.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function claim(uint _id, uint _amount, bytes memory _data) public onlyWorker(_id) 
    isValidCertificate(_data, 0xb8b75836) returns (bool) {
        address worker = msg.sender;
        require(worker != address(0), "Address should not be zero");
        require(_amount > 0, "Amount should be greater than zero");

        Job storage job = jobs[_id];
        
        require(job.status == 4, "Available once completed");
        
        _claim(job, _id, _amount);
        
        return true;
    }
    
    /**
    * @dev Function to set Refundable to a job.
    * @param _id uint The Job Id which will set Refundable.
    * @param _data bytes memory
    * @return True if the operation was successful.
    */
    function setRefundable(uint _id, bytes memory _data) public onlyController 
    isValidCertificate(_data, 0x7d0613f0) returns (bool) {
        address contoller = msg.sender;
        require(contoller != address(0), "Address should not be zero");

        Job storage job = jobs[_id];

        require(job.refundable == false);
        
        _setRefundable(job, _id, contoller);
        
        return true;
    }

    /**
    * @dev Function to set an address to send fees.
    * @param _feeAccount address The address which will set.
    * @return True if the operation was successful.
    */
    function setFeeAccount(address _feeAccount) public onlyOwner  returns (bool) {
        require(_feeAccount != address(0), "Address should not be zero");
        
        _setFeeAccount(_feeAccount);

        return true;
    }

    /**
    * @dev Function to set fee percent.
    * @param _fee uint8 This fee which will set.
    * @return True if the operation was successful.
    */
    function setFee (uint8 _fee) public onlyOwner returns (bool) {
        require(_fee >= 0 && _fee < 100, "Fee percent should be less than 100");
        
        _setFee(_fee);
        
        return true;
    }
}