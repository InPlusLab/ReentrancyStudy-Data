library WalletMainLib {
  using Array256Lib for uint256[];
  using BasicMathLib for uint256;

  struct WalletData {
    uint256 maxOwners; //Maximum wallet owners, should be 50
    address[] owners; //Array of all owners
    uint256 requiredAdmin; //Number of sigs required for administrative changes
    uint256 requiredMajor; //Number of sigs required for major transactions
    uint256 requiredMinor; //Number of sigs required for minor transactions

    // The amount of a token spent per day, ether is at address mapping 0,
    // all other tokens defined by address. uint256[0] corresponds to the current
    // day,  uint256[1] is the spend amount
    mapping (address => uint256[2]) currentSpend;
    //The day spend threshold for transactions to be major, ether at 0, all others by address
    mapping (address => uint256) majorThreshold;
    //Array of transactions per day, uint256 is the day timestamp, bytes32 is the transaction id
    mapping (uint256 => bytes32[]) transactions;
    //Tracks the index of each owner in the owners Array
    mapping (address => uint256) ownerIndex;
    //Array of Transaction&#39;s by id, new tx&#39;s with exact inputs as previous tx will add to array
    mapping (bytes32 => Transaction[]) transactionInfo;

  }

  struct Transaction {
    uint256 day; //Timestamp of the day initialized
    uint256 value; //Amount of ether being sent
    address tokenAdress; //Address of token transferred
    uint256 amount; //Amount of tokens transferred
    bytes data; //Temp location for pending transactions, erased after final confirmation
    uint256[] confirmedOwners; //Array of owners confirming transaction
    uint256 confirmCount; //Tracks the number of confirms
    uint256 confirmRequired; //Number of sigs required for this transaction
    bool success; //True after final confirmation
  }

  /*Events*/
  event LogRevokeNotice(bytes32 txid, address sender, uint256 confirmsNeeded);
  event LogTransactionFailed(bytes32 txid, address sender);
  event LogTransactionConfirmed(bytes32 txid, address sender, uint256 confirmsNeeded);
  event LogTransactionComplete(bytes32 txid, address target, uint256 value, bytes data);
  event LogContractCreated(address newContract, uint256 value);
  event LogErrorMsg(uint256 amount, string msg);

  /// @dev Constructor
  /// @param self The wallet in contract storage
  /// @param _owners Array of initial owners
  /// @param _requiredAdmin Set number of sigs for administrative tasks
  /// @param _requiredMajor Set number of sigs for major tx
  /// @param _requiredMinor Set number of sigs for minor tx
  /// @param _majorThreshold Set major tx threshold amount for ether
  /// @return Will return true when complete
  function init(WalletData storage self,
                address[] _owners,
                uint256 _requiredAdmin,
                uint256 _requiredMajor,
                uint256 _requiredMinor,
                uint256 _majorThreshold) public returns (bool)
  {
    require(self.owners.length == 0);
    require(_owners.length >= _requiredAdmin && _requiredAdmin > 0);
    require(_owners.length >= _requiredMajor && _requiredMajor > 0);
    require(_owners.length >= _requiredMinor && _requiredMinor > 0);
    self.owners.push(0); //Leave index-0 empty for easier owner checks

    for (uint256 i=0; i<_owners.length; i++) {
      require(_owners[i] != 0);
      self.owners.push(_owners[i]);
      self.ownerIndex[_owners[i]] = i+1;
    }
    self.requiredAdmin = _requiredAdmin;
    self.requiredMajor = _requiredMajor;
    self.requiredMinor = _requiredMinor;
    self.maxOwners = 50; //Limits to 50 owners, should create wallet pools for more owners
    self.majorThreshold[0] = _majorThreshold; //Sets ether threshold at address 0

    return true;
  }

  /*Checks*/

  /// @dev Verifies a confirming owner has not confirmed already
  /// @param self Contract wallet in storage
  /// @param _id ID of the tx being checked
  /// @param _txIndex Index number of this tx
  /// @return Returns true if check passes, false otherwise
  function checkNotConfirmed(WalletData storage self, bytes32 _id, uint256 _txIndex)
           public returns (bool)
  {
    require(self.ownerIndex[msg.sender] > 0);
    uint256 _txLen = self.transactionInfo[_id].length;

    if(_txLen == 0 || _txIndex >= _txLen){
      LogErrorMsg(_txLen, "Tx not initiated");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    if(self.transactionInfo[_id][_txIndex].success){
      LogErrorMsg(_txIndex, "Transaction already complete");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    //Function from Modular.io array utility library
    bool found;
    uint256 index;
    (found, index) = self.transactionInfo[_id][_txIndex].confirmedOwners.indexOf(uint256(msg.sender), false);
    if(found){
      LogErrorMsg(index, "Owner already confirmed");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    return true;
  }

  /*Utility Functions*/

  /// @dev Used later to calculate the number of confirmations needed for tx
  /// @param _required Number of sigs required
  /// @param _count Current number of sigs
  function calcConfirmsNeeded(uint256 _required, uint256 _count) public pure returns (uint256){
    return _required - _count;
  }

  /// @dev Used to check if tx is moving tokens and parses amount
  /// @param _txData Data for proposed tx
  /// @return bool True if transaction is moving tokens
  /// @return uint256 Amount of tokens involved, 0 if not spending tx
  function getAmount(bytes _txData) public pure returns (bool,uint256) {
    bytes32 getSig;
    bytes4 sig;
    bytes4 tSig = 0xa9059cbb; //transfer func signature
    bytes4 aSig = 0x095ea7b3; //approve func signature
    bytes4 tfSig = 0x23b872dd; //transferFrom func signature
    bool transfer;
    bytes32 _amountData;
    uint256 _amount;

    assembly { getSig := mload(add(_txData,0x20)) }
    sig = bytes4(getSig);
    if(sig ==  tSig || sig == aSig){
      transfer = true;
      assembly { _amountData := mload(add(_txData,0x44)) }
      _amount = uint256(_amountData);
    } else if(sig == tfSig){
      transfer = true;
      assembly { _amountData := mload(add(_txData,0x64)) }
      _amount = uint256(_amountData);
    }
    return (transfer,_amount);
  }

  /// @dev Retrieves sig requirement for spending tx
  /// @param self Contract wallet in storage
  /// @param _to Target address of transaction
  /// @param _value Amount of ether spend
  /// @param _isTransfer True if transferring other tokens, false otherwise
  /// @param _amount Amount of tokens being transferred, 0 if not a transfer tx
  /// @return uint256 The required sigs for tx
  function getRequired(WalletData storage self,
                       address _to,
                       uint256 _value,
                       bool _isTransfer,
                       uint256 _amount)
                       public returns (uint256)
  {
    bool err;
    uint256 res;
    bool major = true;
    //Reset spend if this is first check of the day
    if((now / 1 days) > self.currentSpend[0][0]){
      self.currentSpend[0][0] = now / 1 days;
      self.currentSpend[0][1] = 0;
    }

    (err, res) = self.currentSpend[0][1].plus(_value);
    require(!err);

    if(res < self.majorThreshold[0])
      major = false;

    if(_to != 0 && _isTransfer){
      if((now / 1 days) > self.currentSpend[_to][0]){
        self.currentSpend[_to][0] = now / 1 days;
        self.currentSpend[_to][1] = 0;
      }

      (err, res) = self.currentSpend[_to][1].plus(_amount);
      require(!err);

      if(res >= self.majorThreshold[_to])
        major = true;
    }

    return major ? self.requiredMajor : self.requiredMinor;
  }

  /// @dev Function to create new contract
  /// @param _txData Transaction data
  /// @param _value Amount of eth sending to new contract
  function createContract(bytes _txData, uint256 _value) public {
    address _newContract;
    bool allGood;

    assembly {
      _newContract := create(_value, add(_txData, 0x20), mload(_txData))
      allGood := gt(extcodesize(_newContract),0)
    }
    require(allGood);
    LogContractCreated(_newContract, _value);
  }

  /*Primary Function*/

  /// @dev Create and execute transaction from wallet
  /// @param self Wallet in contract storage
  /// @param _to Address of target
  /// @param _value Amount of ether sending
  /// @param _txData Data for executing transaction
  /// @param _confirm True if confirming, false if revoking confirmation
  /// @param _data Message data passed from wallet contract
  /// @return bool Returns true if successful, false otherwise
  /// @return bytes32 Returns the tx ID, can be used for confirm/revoke functions
  function serveTx(WalletData storage self,
                   address _to,
                   uint256 _value,
                   bytes _txData,
                   bool _confirm,
                   bytes _data)
                   public returns (bool,bytes32)
  {
    bytes32 _id = keccak256("serveTx",_to,_value,_txData);
    uint256 _txIndex = self.transactionInfo[_id].length;
    uint256 _required = self.requiredMajor;

    //Run checks if not called from generic confirm/revoke function
    if(msg.sender != address(this)){
      bool allGood;
      uint256 _amount;
      // if the owner is revoking his/her confirmation but doesn&#39;t know the
      // specific transaction id hash
      if(!_confirm) {
        allGood = revokeConfirm(self, _id);
        return (allGood,_id);
      } else { // else confirming the transaction
        //Reuse allGood due to stack limit
        if(_to != 0)
          (allGood,_amount) = getAmount(_txData);

        //if this is a new transaction id or if a previous identical transaction had already succeeded
        if(_txIndex == 0 || self.transactionInfo[_id][_txIndex - 1].success){
          require(self.ownerIndex[msg.sender] > 0);

          _required = getRequired(self, _to, _value, allGood,_amount);

          // add this transaction to the wallets record and initialize the settings
          self.transactionInfo[_id].length++;
          self.transactionInfo[_id][_txIndex].confirmRequired = _required;
          self.transactionInfo[_id][_txIndex].day = now / 1 days;
          self.transactions[now / 1 days].push(_id);
        } else { // else the transaction is already pending
          _txIndex--; // set the index to the index of the existing transaction
          //make sure the sender isn&#39;t already confirmed
          allGood = checkNotConfirmed(self, _id, _txIndex);
          if(!allGood)
            return (false,_id);
        }
      }

      // add the senders confirmation to the transaction
      self.transactionInfo[_id][_txIndex].confirmedOwners.push(uint256(msg.sender));
      self.transactionInfo[_id][_txIndex].confirmCount++;
    } else {
      // else were calling from generic confirm/revoke function, set the
      // _txIndex index to the index of the existing transaction
      _txIndex--;
    }

    // if there are enough confirmations
    if(self.transactionInfo[_id][_txIndex].confirmCount ==
       self.transactionInfo[_id][_txIndex].confirmRequired)
    {
      // execute the transaction
      self.currentSpend[0][1] += _value;
      self.currentSpend[_to][1] += _amount;
      self.transactionInfo[_id][_txIndex].success = true;

      if(_to == 0){
        //Failure is self contained in method
        createContract(_txData, _value);
      } else {
        require(_to.call.value(_value)(_txData));
      }
      delete self.transactionInfo[_id][_txIndex].data;
      LogTransactionComplete(_id, _to, _value, _data);
    } else {
      if(self.transactionInfo[_id][_txIndex].data.length == 0)
        self.transactionInfo[_id][_txIndex].data = _data;

      uint256 confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_txIndex].confirmRequired,
                                               self.transactionInfo[_id][_txIndex].confirmCount);
      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
    }

    return (true,_id);
  }

  /* Confirm/Revoke functions using tx ID */

  /// @dev Confirms a current pending tx, will execute if final confirmation
  /// @param self Wallet in contract storage
  /// @param _id ID of the transaction
  /// @return Returns true if successful, false otherwise
  function confirmTx(WalletData storage self, bytes32 _id)
                     public returns (bool) {
    require(self.ownerIndex[msg.sender] > 0);
    uint256 _txIndex = self.transactionInfo[_id].length;
    bool ret;

    if(_txIndex == 0){
      LogErrorMsg(_txIndex, "Tx not initiated");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    _txIndex--;
    bool allGood = checkNotConfirmed(self, _id, _txIndex);
    if(!allGood)
      return false;

    self.transactionInfo[_id][_txIndex].confirmedOwners.push(uint256(msg.sender));
    self.transactionInfo[_id][_txIndex].confirmCount++;

    if(self.transactionInfo[_id][_txIndex].confirmCount ==
       self.transactionInfo[_id][_txIndex].confirmRequired)
    {
      address a = address(this);
      require(a.call(self.transactionInfo[_id][_txIndex].data));
    } else {
      uint256 confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_txIndex].confirmRequired,
                                               self.transactionInfo[_id][_txIndex].confirmCount);

      LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
      ret = true;
    }

    return ret;
  }

  /// @dev Revokes a prior confirmation from sender, call with tx ID
  /// @param self Wallet in contract storage
  /// @param _id ID of the transaction
  /// @return Returns true if successful, false otherwise
  function revokeConfirm(WalletData storage self, bytes32 _id)
           public
           returns (bool)
  {
    require(self.ownerIndex[msg.sender] > 0);
    uint256 _txIndex = self.transactionInfo[_id].length;

    if(_txIndex == 0){
      LogErrorMsg(_txIndex, "Tx not initiated");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    _txIndex--;
    if(self.transactionInfo[_id][_txIndex].success){
      LogErrorMsg(_txIndex, "Transaction already complete");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }

    //Function from Modular.io array utility library
    bool found;
    uint256 index;
    (found, index) = self.transactionInfo[_id][_txIndex].confirmedOwners.indexOf(uint256(msg.sender), false);
    if(!found){
      LogErrorMsg(index, "Owner has not confirmed tx");
      LogTransactionFailed(_id, msg.sender);
      return false;
    }
    self.transactionInfo[_id][_txIndex].confirmedOwners[index] = 0;
    self.transactionInfo[_id][_txIndex].confirmCount--;

    uint256 confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_txIndex].confirmRequired,
                                             self.transactionInfo[_id][_txIndex].confirmCount);
    //Transaction removed if all sigs revoked but id remains in wallet transaction list
    if(self.transactionInfo[_id][_txIndex].confirmCount == 0)
      self.transactionInfo[_id].length--;

    LogRevokeNotice(_id, msg.sender, confirmsNeeded);
    return true;
  }
}

library Array256Lib {

  /// @dev Sum vector
  /// @param self Storage array containing uint256 type variables
  /// @return sum The sum of all elements, does not check for overflow
  function sumElements(uint256[] storage self) public view returns(uint256 sum) {
    assembly {
      mstore(0x60,self_slot)

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        sum := add(sload(add(sha3(0x60,0x20),i)),sum)
      }
    }
  }

  /// @dev Returns the max value in an array.
  /// @param self Storage array containing uint256 type variables
  /// @return maxValue The highest value in the array
  function getMax(uint256[] storage self) public view returns(uint256 maxValue) {
    assembly {
      mstore(0x60,self_slot)
      maxValue := sload(sha3(0x60,0x20))

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        switch gt(sload(add(sha3(0x60,0x20),i)), maxValue)
        case 1 {
          maxValue := sload(add(sha3(0x60,0x20),i))
        }
      }
    }
  }

  /// @dev Returns the minimum value in an array.
  /// @param self Storage array containing uint256 type variables
  /// @return minValue The highest value in the array
  function getMin(uint256[] storage self) public view returns(uint256 minValue) {
    assembly {
      mstore(0x60,self_slot)
      minValue := sload(sha3(0x60,0x20))

      for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
        switch gt(sload(add(sha3(0x60,0x20),i)), minValue)
        case 0 {
          minValue := sload(add(sha3(0x60,0x20),i))
        }
      }
    }
  }

  /// @dev Finds the index of a given value in an array
  /// @param self Storage array containing uint256 type variables
  /// @param value The value to search for
  /// @param isSorted True if the array is sorted, false otherwise
  /// @return found True if the value was found, false otherwise
  /// @return index The index of the given value, returns 0 if found is false
  function indexOf(uint256[] storage self, uint256 value, bool isSorted)
           public
           view
           returns(bool found, uint256 index) {
    assembly{
      mstore(0x60,self_slot)
      switch isSorted
      case 1 {
        let high := sub(sload(self_slot),1)
        let mid := 0
        let low := 0
        for { } iszero(gt(low, high)) { } {
          mid := div(add(low,high),2)

          switch lt(sload(add(sha3(0x60,0x20),mid)),value)
          case 1 {
             low := add(mid,1)
          }
          case 0 {
            switch gt(sload(add(sha3(0x60,0x20),mid)),value)
            case 1 {
              high := sub(mid,1)
            }
            case 0 {
              found := 1
              index := mid
              low := add(high,1)
            }
          }
        }
      }
      case 0 {
        for { let low := 0 } lt(low, sload(self_slot)) { low := add(low, 1) } {
          switch eq(sload(add(sha3(0x60,0x20),low)), value)
          case 1 {
            found := 1
            index := low
            low := sload(self_slot)
          }
        }
      }
    }
  }

  /// @dev Utility function for heapSort
  /// @param index The index of child node
  /// @return pI The parent node index
  function getParentI(uint256 index) private pure returns (uint256 pI) {
    uint256 i = index - 1;
    pI = i/2;
  }

  /// @dev Utility function for heapSort
  /// @param index The index of parent node
  /// @return lcI The index of left child
  function getLeftChildI(uint256 index) private pure returns (uint256 lcI) {
    uint256 i = index * 2;
    lcI = i + 1;
  }

  /// @dev Sorts given array in place
  /// @param self Storage array containing uint256 type variables
  function heapSort(uint256[] storage self) public {
    uint256 end = self.length - 1;
    uint256 start = getParentI(end);
    uint256 root = start;
    uint256 lChild;
    uint256 rChild;
    uint256 swap;
    uint256 temp;
    while(start >= 0){
      root = start;
      lChild = getLeftChildI(start);
      while(lChild <= end){
        rChild = lChild + 1;
        swap = root;
        if(self[swap] < self[lChild])
          swap = lChild;
        if((rChild <= end) && (self[swap]<self[rChild]))
          swap = rChild;
        if(swap == root)
          lChild = end+1;
        else {
          temp = self[swap];
          self[swap] = self[root];
          self[root] = temp;
          root = swap;
          lChild = getLeftChildI(root);
        }
      }
      if(start == 0)
        break;
      else
        start = start - 1;
    }
    while(end > 0){
      temp = self[end];
      self[end] = self[0];
      self[0] = temp;
      end = end - 1;
      root = 0;
      lChild = getLeftChildI(0);
      while(lChild <= end){
        rChild = lChild + 1;
        swap = root;
        if(self[swap] < self[lChild])
          swap = lChild;
        if((rChild <= end) && (self[swap]<self[rChild]))
          swap = rChild;
        if(swap == root)
          lChild = end + 1;
        else {
          temp = self[swap];
          self[swap] = self[root];
          self[root] = temp;
          root = swap;
          lChild = getLeftChildI(root);
        }
      }
    }
  }

  /// @dev Removes duplicates from a given array.
  /// @param self Storage array containing uint256 type variables
  function uniq(uint256[] storage self) public returns (uint256 length) {
    bool contains;
    uint256 index;

    for (uint256 i = 0; i < self.length; i++) {
      (contains, index) = indexOf(self, self[i], false);

      if (i > index) {
        for (uint256 j = i; j < self.length - 1; j++){
          self[j] = self[j + 1];
        }

        delete self[self.length - 1];
        self.length--;
        i--;
      }
    }

    length = self.length;
  }
}

library BasicMathLib {
  /// @dev Multiplies two numbers and checks for overflow before returning.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is overflow
  /// @return res The product of a and b, or 0 if there is overflow
  function times(uint256 a, uint256 b) public view returns (bool err,uint256 res) {
    assembly{
      res := mul(a,b)
      switch or(iszero(b), eq(div(res,b), a))
      case 0 {
        err := 1
        res := 0
      }
    }
  }

  /// @dev Divides two numbers but checks for 0 in the divisor first.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if `b` is 0
  /// @return res The quotient of a and b, or 0 if `b` is 0
  function dividedBy(uint256 a, uint256 b) public view returns (bool err,uint256 i) {
    uint256 res;
    assembly{
      switch iszero(b)
      case 0 {
        res := div(a,b)
        let loc := mload(0x40)
        mstore(add(loc,0x20),res)
        i := mload(add(loc,0x20))
      }
      default {
        err := 1
        i := 0
      }
    }
  }

  /// @dev Adds two numbers and checks for overflow before returning.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is overflow
  /// @return res The sum of a and b, or 0 if there is overflow
  function plus(uint256 a, uint256 b) public view returns (bool err, uint256 res) {
    assembly{
      res := add(a,b)
      switch and(eq(sub(res,b), a), or(gt(res,b),eq(res,b)))
      case 0 {
        err := 1
        res := 0
      }
    }
  }

  /// @dev Subtracts two numbers and checks for underflow before returning.
  /// Does not throw but rather logs an Err event if there is underflow.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is underflow
  /// @return res The difference between a and b, or 0 if there is underflow
  function minus(uint256 a, uint256 b) public view returns (bool err,uint256 res) {
    assembly{
      res := sub(a,b)
      switch eq(and(eq(add(res,b), a), or(lt(res,a), eq(res,a))), 1)
      case 0 {
        err := 1
        res := 0
      }
    }
  }
}