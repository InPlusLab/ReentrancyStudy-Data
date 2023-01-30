/**

 *Submitted for verification at Etherscan.io on 2019-04-30

*/



pragma solidity 0.5.7;

//import "https://raw.githubusercontent.com/KevK0/solidity-type-casting/master/contracts/stringCasting.sol";

//import "https://raw.githubusercontent.com/Arachnid/solidity-stringutils/master/src/strings.sol";



library SafeMath {

    /**

    * @dev Multiplies two numbers, reverts on overflow.

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

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



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



contract Ownable {

  address public owner;



  event transferOwner(address indexed existingOwner, address indexed newOwner);



  constructor() public {

    owner = msg.sender;

  }



  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  function transferOwnership(address newOwner) onlyOwner public {

    if (newOwner != address(0)) {

      owner = newOwner;

      emit transferOwner(msg.sender, owner);

    }

  }

}



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



}



contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   *

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



contract ERC865 {



    function transferPreSigned(

        bytes memory _signature,

        address _to,

        uint256 _value,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool);



    function approvePreSigned(

        bytes memory _signature,

        address _spender,

        uint256 _value,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool);



    function increaseApprovalPreSigned(

        bytes memory _signature,

        address _spender,

        uint256 _addedValue,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool);



    function decreaseApprovalPreSigned(

        bytes memory _signature,

        address _spender,

        uint256 _subtractedValue,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool);

}



contract ERC865Token is ERC865, StandardToken, Ownable {



    /* Nonces of transfers performed */

    mapping(bytes => bool) signatures;

    /* mapping of nonces of each user */

    mapping (address => uint256) nonces;



    event TransferPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);

    event ApprovalPreSigned(address indexed from, address indexed to, address indexed delegate, uint256 amount, uint256 fee);



    bytes4 internal constant transferSig = 0x48664c16;

    bytes4 internal constant approvalSig = 0xf7ac9c2e;

    bytes4 internal constant increaseApprovalSig = 0xa45f71ff;

    bytes4 internal constant decreaseApprovalSig = 0x59388d78;

    //bytes memory vvv=0x1d915567e2b192cd7a09915020b24a7980e1705003e97b8774af4aa53d9886176fe4e09916f4d865cfbec913a36030534d9e04c9b0293346743bdcdc0020408f1b;



    //return nonce using function

    function getNonce(address _owner) public view returns (uint256 nonce){

      return nonces[_owner];

    }





    /**

     * @notice Submit a presigned transfer

     * @param _signature bytes The signature, issued by the owner.

     * @param _to address The address which you want to transfer to.

     * @param _value uint256 The amount of tokens to be transferred.

     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.

     * @param _nonce uint256 Presigned transaction number.

     */

    function transferPreSigned(

        bytes memory _signature,

        address _to,

        uint256 _value,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool)

    {

        require(_to != address(0));

        require(signatures[_signature] == false);



        bytes32 hashedTx = recoverPreSignedHash(address(this), transferSig, _to, _value, _fee, _nonce);

        address from = recover(hashedTx, _signature);

        require(from != address(0));

        require(_nonce == nonces[from].add(1));

        require(_value.add(_fee) <= balances[from]);



        nonces[from] = _nonce;

        signatures[_signature] = true;

        balances[from] = balances[from].sub(_value).sub(_fee);

        balances[_to] = balances[_to].add(_value);

        balances[msg.sender] = balances[msg.sender].add(_fee);



        emit Transfer(from, _to, _value);

        emit Transfer(from, msg.sender, _fee);

        emit TransferPreSigned(from, _to, msg.sender, _value, _fee);

        return true;

    }



    /**

     * @notice Submit a presigned approval

     * @param _signature bytes The signature, issued by the owner.

     * @param _spender address The address which will spend the funds.

     * @param _value uint256 The amount of tokens to allow.

     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.

     * @param _nonce uint256 Presigned transaction number.

     */

    function approvePreSigned(

        bytes memory _signature,

        address _spender,

        uint256 _value,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool)

    {

        require(_spender != address(0));

        require(signatures[_signature] == false);



        bytes32 hashedTx = recoverPreSignedHash(address(this), approvalSig, _spender, _value, _fee, _nonce);

        address from = recover(hashedTx, _signature);

        require(from != address(0));

        require(_nonce == nonces[from].add(1));

        require(_value.add(_fee) <= balances[from]);



        nonces[from] = _nonce;

        signatures[_signature] = true;

        allowed[from][_spender] =_value;

        balances[from] = balances[from].sub(_fee);

        balances[msg.sender] = balances[msg.sender].add(_fee);



        emit Approval(from, _spender, _value);

        emit Transfer(from, msg.sender, _fee);

        emit ApprovalPreSigned(from, _spender, msg.sender, _value, _fee);

        return true;

    }



    /**

     * @notice Increase the amount of tokens that an owner allowed to a spender.

     * @param _signature bytes The signature, issued by the owner.

     * @param _spender address The address which will spend the funds.

     * @param _addedValue uint256 The amount of tokens to increase the allowance by.

     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.

     * @param _nonce uint256 Presigned transaction number.

     */

    function increaseApprovalPreSigned(

        bytes memory _signature,

        address _spender,

        uint256 _addedValue,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool)

    {

        require(_spender != address(0));

        require(signatures[_signature] == false);



//bytes32 bb=0x59e737eebff4522155b125a11dbd8d225c1a7f047ce93747b103b197e116c224;

//bytes storage nbh=0x7e4362ae61ed93458b1921df843e72570c7f1e11713e6883c0b93ce95e40a1f939daf972b192cff66721f62382c3e3ad423c5d312c2c5c5ac6d00a6d187729861b;

        bytes32 hashedTx = recoverPreSignedHash(address(this), increaseApprovalSig, _spender, _addedValue, _fee, _nonce);

        address from = recover(hashedTx, _signature);

        require(from != address(0));

        require(_nonce == nonces[from].add(1));

        require(allowed[from][_spender].add(_addedValue).add(_fee) <= balances[from]);

        //require(_addedValue <= allowed[from][_spender]);



        nonces[from] = _nonce;

        signatures[_signature] = true;

        allowed[from][_spender] = allowed[from][_spender].add(_addedValue);

        balances[from] = balances[from].sub(_fee);

        balances[msg.sender] = balances[msg.sender].add(_fee);



        emit Approval(from, _spender, allowed[from][_spender]);

        emit Transfer(from, msg.sender, _fee);

        emit ApprovalPreSigned(from, _spender, msg.sender, allowed[from][_spender], _fee);

        return true;

    }



    /**

     * @notice Decrease the amount of tokens that an owner allowed to a spender.

     * @param _signature bytes The signature, issued by the owner

     * @param _spender address The address which will spend the funds.

     * @param _subtractedValue uint256 The amount of tokens to decrease the allowance by.

     * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.

     * @param _nonce uint256 Presigned transaction number.

     */

    function decreaseApprovalPreSigned(

        bytes memory _signature,

        address _spender,

        uint256 _subtractedValue,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool)

    {

        require(_spender != address(0));

        require(signatures[_signature] == false);



        bytes32 hashedTx = recoverPreSignedHash(address(this), decreaseApprovalSig, _spender, _subtractedValue, _fee, _nonce);

        address from = recover(hashedTx, _signature);

        require(from != address(0));

        require(_nonce == nonces[from].add(1));

        //require(_subtractedValue <= balances[from]);

        //require(_subtractedValue <= allowed[from][_spender]);

        //require(_subtractedValue <= allowed[from][_spender]);

        require(_fee <= balances[from]);



        nonces[from] = _nonce;

        signatures[_signature] = true;

        uint oldValue = allowed[from][_spender];

        if (_subtractedValue > oldValue) {

            allowed[from][_spender] = 0;

        } else {

            allowed[from][_spender] = oldValue.sub(_subtractedValue);

        }

        balances[from] = balances[from].sub(_fee);

        balances[msg.sender] = balances[msg.sender].add(_fee);



        emit Approval(from, _spender, _subtractedValue);

        emit Transfer(from, msg.sender, _fee);

        emit ApprovalPreSigned(from, _spender, msg.sender, allowed[from][_spender], _fee);

        return true;

    }



    /**

     * @notice Transfer tokens from one address to another

     * @param _signature bytes The signature, issued by the spender.

     * @param _from address The address which you want to send tokens from.

     * @param _to address The address which you want to transfer to.

     * @param _value uint256 The amount of tokens to be transferred.

     * @param _fee uint256 The amount of tokens paid to msg.sender, by the spender.

     * @param _nonce uint256 Presigned transaction number.

     */

    /*function transferFromPreSigned(

        bytes _signature,

        address _from,

        address _to,

        uint256 _value,

        uint256 _fee,

        uint256 _nonce

    )

        public

        returns (bool)

    {

        require(_to != address(0));

        require(signatures[_signature] == false);

        signatures[_signature] = true;



        bytes32 hashedTx = transferFromPreSignedHashing(address(this), _from, _to, _value, _fee, _nonce);



        address spender = recover(hashedTx, _signature);

        require(spender != address(0));

        require(_value.add(_fee) <= balances[_from])?;



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][spender] = allowed[_from][spender].sub(_value);



        balances[spender] = balances[spender].sub(_fee);

        balances[msg.sender] = balances[msg.sender].add(_fee);



        emit Transfer(_from, _to, _value);

        emit Transfer(spender, msg.sender, _fee);

        return true;

    }*/



     /**

      * @notice Hash (keccak256) of the payload used by recoverPreSignedHash

      * @param _token address The address of the token

      * @param _spender address The address which will spend the funds.

      * @param _value uint256 The amount of tokens.

      * @param _fee uint256 The amount of tokens paid to msg.sender, by the owner.

      * @param _nonce uint256 Presigned transaction number.

      */    

    function recoverPreSignedHash(

        address _token,

        bytes4 _functionSig,

        address _spender,

        uint256 _value,

        uint256 _fee,

        uint256 _nonce

        )

      public pure returns (bytes32)

      {

        //return keccak256(_token, _functionSig, _spender, _value, _fee, _nonce);

        return keccak256(abi.encodePacked(_token, _functionSig, _spender, _value, _fee,_nonce));

    }



    /**

     * @notice Recover signer address from a message by using his signature

     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.

     * @param sig bytes signature, the signature is generated using web3.eth.sign()

     */

    function recover(bytes32 hash, bytes memory sig) public pure returns (address) {

      bytes32 r;

      bytes32 s;

      uint8 v;



      //Check the signature length

      if (sig.length != 65) {

        return (address(0));

      }



      // Divide the signature in r, s and v variables

      assembly {

        r := mload(add(sig, 32))

        s := mload(add(sig, 64))

        v := byte(0, mload(add(sig, 96)))

      }



      // Version of signature should be 27 or 28, but 0 and 1 are also possible versions

      if (v < 27) {

        v += 27;

      }



      // If the version is correct return the signer address

      if (v != 27 && v != 28) {

        return (address(0));

      } else {

        return ecrecover(hash, v, r, s);

      }

    }



}





contract SampleERC865Token is ERC865Token {

  //using strings for *;

  using SafeMath for uint256;



  uint256 public constant _tokenSupply = 42000000;

  string public constant name = "GCH Token";

  string public constant symbol = "GCH";

  uint8 public constant decimals = 18;

  uint256 public constant decimalValue = 10 ** uint256(decimals);

 

  

  bytes32 internal constant digest = 0x618e860eefb172f655b56aad9bdc5685c037efba70b9c34a8e303b19778efd2c;//=""

  

  uint256 public sellPrice;

  uint256 public buyPrice;

    

  

  constructor() public {

    //require(_tokenSupply > 0);

    totalSupply_ = _tokenSupply.mul(decimalValue);

    balances[msg.sender] = totalSupply_;

    owner = msg.sender;

    emit Transfer(address(this), msg.sender, totalSupply_);

  }

  /*

  function transferMul(address[] froms,

    address[] _toes,

    uint256[] _values,

    uint256[] _fees) public returns (bool[]) {

        require(msg.sender == owner);

        

        bool[] storage isSuccess;

        //uint256 fee=0;

            

        for (uint i=0; i < _toes.length; i++) {

        

            if(_values[i].add(_fees[i]) <= balances[froms[i]]){

                balances[froms[i]] = balances[froms[i]].sub(_values[i]).sub(_fees[i]);

                balances[_toes[i]] = balances[_toes[i]].add(_values[i]);

                

                balances[msg.sender] = balances[msg.sender].add(_fees[i]);

                

                emit Transfer(froms[i], _toes[i], _values[i]);

                if(froms[i] != msg.sender){

                emit Transfer(froms[i], msg.sender, _fees[i]);

                    

                }

                isSuccess.push(true);

            }else{

                isSuccess.push(false);}

        

    }

    //emit Transfer(msg.sender, _to, _value);

    

    return isSuccess;

  }

  */

  /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth

    /// @param newSellPrice Price the users can sell to the contract

    /// @param newBuyPrice Price users can buy from the contract

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {

        sellPrice = newSellPrice;

        buyPrice = newBuyPrice;

    }



    /// @notice Buy tokens from contract by sending ether

    function buy() payable public {

        uint amount = msg.value / buyPrice;                 // calculates the amount

        emit Transfer(address(this), msg.sender, amount);       // makes the transfers

    }



    /// @notice Sell `amount` tokens to contract

    /// @param amount amount of tokens to be sold

    function sell(uint256 amount) public {

        address myAddress = address(this);

        require(myAddress.balance >= amount * sellPrice);   // checks if the contract has enough ether to buy

        emit Transfer(msg.sender, address(this), amount);       // makes the transfers

        msg.sender.transfer(amount * sellPrice);            // sends ether to the seller. It's important to do this last to avoid recursion attacks

    }

/*

  using stringcast for string;

  function transferArray(string signs,address[] _toes,

        uint256[] _values,

        uint256[] _fees,

        uint256[] _nonces) public returns (bool) {

            require(msg.sender == owner);

         

            var s = signs.toSlice();

            var delim = ".".toSlice();

            var parts = new string[](s.count(delim) + 1);

            for(uint i = 0; i < parts.length; i++) {

                parts[i] = s.split(delim).toString();

                

                bytes32 hashedTx = recoverPreSignedHash(address(this), transferSig, _toes[i], _values[i], _fees[i], _nonces[i]);

                address from = recover(hashedTx,parts[i].toBytes());

                

                if(_values[i].add(_fees[i]) <= balances[from]){

                balances[from] = balances[from].sub(_values[i]).sub(_fees[i]);

                balances[_toes[i]] = balances[_toes[i]].add(_values[i]);

                

                balances[msg.sender] = balances[msg.sender].add(_fees[i]);

                

                emit Transfer(from, _toes[i], _values[i]);

                if(_fees[i] != 0){

                    emit Transfer(from, msg.sender, _fees[i]);

                    

                }

            }

        }

    return true;

  }

  */

  

    

  function transferArray(uint8[] memory v,bytes32[] memory r,bytes32[] memory s,address[] memory _toes,

        uint256[] memory _values,

        uint256[] memory _fees) public returns (bool) {

            require(msg.sender == owner);

            uint totalFee = 0;

         

            for(uint i = 0; i < _toes.length; i++) {

                //bytes32 messageDigest = keccak256(hashes[i]);

                address from = ecrecover(digest, v[i], r[i], s[i]);

                

                uint256 value=_values[i];

                uint256 fee=_fees[i];

                

                uint fromBalance = balances[from];

                

                

                if(value.add(fee) <= fromBalance){

                    address to = _toes[i];

                    uint toBalance = balances[to];

                    

                    balances[from] = fromBalance.sub(value).sub(fee);

                    balances[to] = toBalance.add(value);

                    

                    //balances[msg.sender] = balances[msg.sender].add(_fees[i]);

                    

                    emit Transfer(from, to, value);

                   

                    totalFee=totalFee.add(fee);

                    

                    if(fee != 0){

                        

                    emit Transfer(from, msg.sender, fee);

                    

                    }

                    

                    

                

                }

            

            }

            balances[msg.sender] = balances[msg.sender].add(totalFee);

            

        return true;

  }

  

  

  

  

    function sendBatchCS(address[] calldata _recipients, uint[] calldata _values) external returns (bool) {

            require(_recipients.length == _values.length);

    

            uint senderBalance = balances[msg.sender];

            for (uint i = 0; i < _values.length; i++) {

                uint value = _values[i];

                address to = _recipients[i];

                require(senderBalance >= value);

                if(msg.sender != to){

                    senderBalance = senderBalance - value;

                    balances[to] += value;

                }

    			emit Transfer(msg.sender, to, value);

            }

            balances[msg.sender] = senderBalance;

            return true;

    }

  

}