/**

 *Submitted for verification at Etherscan.io on 2018-11-02

*/



pragma solidity ^0.4.24;



// File: zeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}



// File: zeppelin-solidity/contracts/ownership/Ownable.sol



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

  function Ownable() {

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

  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));

    OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol



/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    Unpause();

  }

}



// File: zeppelin-solidity/contracts/lifecycle/Destructible.sol



/**

 * @title Destructible

 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.

 */

contract Destructible is Ownable {



  function Destructible() payable { }



  /**

   * @dev Transfers the current balance to the owner and terminates the contract.

   */

  function destroy() onlyOwner public {

    selfdestruct(owner);

  }



  function destroyAndSend(address _recipient) onlyOwner public {

    selfdestruct(_recipient);

  }

}



// File: zeppelin-solidity/contracts/ownership/Contactable.sol



/**

 * @title Contactable token

 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their

 * contact information.

 */

contract Contactable is Ownable{



    string public contactInformation;



    /**

     * @dev Allows the owner to set a string with their contact information.

     * @param info The contact information to attach to the contract.

     */

    function setContactInformation(string info) onlyOwner public {

         contactInformation = info;

     }

}



// File: contracts/Restricted.sol



/** @title Restricted

 *  Exposes onlyMonetha modifier

 */

contract Restricted is Ownable {



    //MonethaAddress set event

    event MonethaAddressSet(

        address _address,

        bool _isMonethaAddress

    );



    mapping (address => bool) public isMonethaAddress;



    /**

     *  Restrict methods in such way, that they can be invoked only by monethaAddress account.

     */

    modifier onlyMonetha() {

        require(isMonethaAddress[msg.sender]);

        _;

    }



    /**

     *  Allows owner to set new monetha address

     */

    function setMonethaAddress(address _address, bool _isMonethaAddress) onlyOwner public {

        isMonethaAddress[_address] = _isMonethaAddress;



        MonethaAddressSet(_address, _isMonethaAddress);

    }

}



// File: contracts/ERC20.sol



/**

* @title ERC20 interface

*/

contract ERC20 {

    function totalSupply() public view returns (uint256);



    function decimals() public view returns(uint256);



    function balanceOf(address _who) public view returns (uint256);



    function allowance(address _owner, address _spender)

        public view returns (uint256);



    function transfer(address _to, uint256 _value) public returns (bool);



    function approve(address _spender, uint256 _value)

        public returns (bool);



    function transferFrom(address _from, address _to, uint256 _value)

        public returns (bool);



    event Transfer(

        address indexed from,

        address indexed to,

        uint256 value

    );



    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

}



// File: contracts/MonethaGateway.sol



/**

 *  @title MonethaGateway

 *

 *  MonethaGateway forward funds from order payment to merchant's wallet and collects Monetha fee.

 */

contract MonethaGateway is Pausable, Contactable, Destructible, Restricted {



    using SafeMath for uint256;

    

    string constant VERSION = "0.5";



    /**

     *  Fee permille of Monetha fee.

     *  1 permille (��) = 0.1 percent (%)

     *  15�� = 1.5%

     */

    uint public constant FEE_PERMILLE = 15;

    

    /**

     *  Address of Monetha Vault for fee collection

     */

    address public monethaVault;



    /**

     *  Account for permissions managing

     */

    address public admin;



    event PaymentProcessedEther(address merchantWallet, uint merchantIncome, uint monethaIncome);

    event PaymentProcessedToken(address tokenAddress, address merchantWallet, uint merchantIncome, uint monethaIncome);



    /**

     *  @param _monethaVault Address of Monetha Vault

     */

    constructor(address _monethaVault, address _admin) public {

        require(_monethaVault != 0x0);

        monethaVault = _monethaVault;

        

        setAdmin(_admin);

    }

    

    /**

     *  acceptPayment accept payment from PaymentAcceptor, forwards it to merchant's wallet

     *      and collects Monetha fee.

     *  @param _merchantWallet address of merchant's wallet for fund transfer

     *  @param _monethaFee is a fee collected by Monetha

     */

    function acceptPayment(address _merchantWallet, uint _monethaFee) external payable onlyMonetha whenNotPaused {

        require(_merchantWallet != 0x0);

        require(_monethaFee >= 0 && _monethaFee <= FEE_PERMILLE.mul(msg.value).div(1000)); // Monetha fee cannot be greater than 1.5% of payment

        

        uint merchantIncome = msg.value.sub(_monethaFee);



        _merchantWallet.transfer(merchantIncome);

        monethaVault.transfer(_monethaFee);



        emit PaymentProcessedEther(_merchantWallet, merchantIncome, _monethaFee);

    }



    /**

     *  acceptTokenPayment accept token payment from PaymentAcceptor, forwards it to merchant's wallet

     *      and collects Monetha fee.

     *  @param _merchantWallet address of merchant's wallet for fund transfer

     *  @param _monethaFee is a fee collected by Monetha

     *  @param _tokenAddress is the token address

     *  @param _value is the order value

     */

    function acceptTokenPayment(

        address _merchantWallet,

        uint _monethaFee,

        address _tokenAddress,

        uint _value

    )

        external onlyMonetha whenNotPaused

    {

        require(_merchantWallet != 0x0);



        // Monetha fee cannot be greater than 1.5% of payment

        require(_monethaFee >= 0 && _monethaFee <= FEE_PERMILLE.mul(_value).div(1000));



        uint merchantIncome = _value.sub(_monethaFee);

        

        ERC20(_tokenAddress).transfer(_merchantWallet, merchantIncome);

        ERC20(_tokenAddress).transfer(monethaVault, _monethaFee);

        

        emit PaymentProcessedToken(_tokenAddress, _merchantWallet, merchantIncome, _monethaFee);

    }



    /**

     *  changeMonethaVault allows owner to change address of Monetha Vault.

     *  @param newVault New address of Monetha Vault

     */

    function changeMonethaVault(address newVault) external onlyOwner whenNotPaused {

        monethaVault = newVault;

    }



    /**

     *  Allows other monetha account or contract to set new monetha address

     */

    function setMonethaAddress(address _address, bool _isMonethaAddress) public {

        require(msg.sender == admin || msg.sender == owner);



        isMonethaAddress[_address] = _isMonethaAddress;



        emit MonethaAddressSet(_address, _isMonethaAddress);

    }



    /**

     *  setAdmin allows owner to change address of admin.

     *  @param _admin New address of admin

     */

    function setAdmin(address _admin) public onlyOwner {

        require(_admin != 0x0);

        admin = _admin;

    }

}



// File: contracts/SafeDestructible.sol



/**

 * @title SafeDestructible

 * Base contract that can be destroyed by owner.

 * Can be destructed if there are no funds on contract balance.

 */

contract SafeDestructible is Ownable {

    function destroy() onlyOwner public {

        require(this.balance == 0);

        selfdestruct(owner);

    }

}



// File: contracts/MerchantWallet.sol



/**

 *  @title MerchantWallet

 *  Serves as a public Merchant profile with merchant profile info,

 *      payment settings and latest reputation value.

 *  Also MerchantWallet accepts payments for orders.

 */



contract MerchantWallet is Pausable, SafeDestructible, Contactable, Restricted {



    string constant VERSION = "0.5";



    /// Address of merchant's account, that can withdraw from wallet

    address public merchantAccount;



    /// Address of merchant's fund address.

    address public merchantFundAddress;



    /// Unique Merchant identifier hash

    bytes32 public merchantIdHash;



    /// profileMap stores general information about the merchant

    mapping (string=>string) profileMap;



    /// paymentSettingsMap stores payment and order settings for the merchant

    mapping (string=>string) paymentSettingsMap;



    /// compositeReputationMap stores composite reputation, that compraises from several metrics

    mapping (string=>uint32) compositeReputationMap;



    /// number of last digits in compositeReputation for fractional part

    uint8 public constant REPUTATION_DECIMALS = 4;



    /**

     *  Restrict methods in such way, that they can be invoked only by merchant account.

     */

    modifier onlyMerchant() {

        require(msg.sender == merchantAccount);

        _;

    }



    /**

     *  Fund Address should always be Externally Owned Account and not a contract.

     */

    modifier isEOA(address _fundAddress) {

        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_fundAddress)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }



    /**

     *  Restrict methods in such way, that they can be invoked only by merchant account or by monethaAddress account.

     */

    modifier onlyMerchantOrMonetha() {

        require(msg.sender == merchantAccount || isMonethaAddress[msg.sender]);

        _;

    }



    /**

     *  @param _merchantAccount Address of merchant's account, that can withdraw from wallet

     *  @param _merchantId Merchant identifier

     *  @param _fundAddress Merchant's fund address, where amount will be transferred.

     */

    constructor(address _merchantAccount, string _merchantId, address _fundAddress) public isEOA(_fundAddress) {

        require(_merchantAccount != 0x0);

        require(bytes(_merchantId).length > 0);



        merchantAccount = _merchantAccount;

        merchantIdHash = keccak256(_merchantId);



        merchantFundAddress = _fundAddress;

    }



    /**

     *  Accept payment from MonethaGateway

     */

    function () external payable {

    }



    /**

     *  @return profile info by string key

     */

    function profile(string key) external constant returns (string) {

        return profileMap[key];

    }



    /**

     *  @return payment setting by string key

     */

    function paymentSettings(string key) external constant returns (string) {

        return paymentSettingsMap[key];

    }



    /**

     *  @return composite reputation value by string key

     */

    function compositeReputation(string key) external constant returns (uint32) {

        return compositeReputationMap[key];

    }



    /**

     *  Set profile info by string key

     */

    function setProfile(

        string profileKey,

        string profileValue,

        string repKey,

        uint32 repValue

    )

        external onlyOwner

    {

        profileMap[profileKey] = profileValue;



        if (bytes(repKey).length != 0) {

            compositeReputationMap[repKey] = repValue;

        }

    }



    /**

     *  Set payment setting by string key

     */

    function setPaymentSettings(string key, string value) external onlyOwner {

        paymentSettingsMap[key] = value;

    }



    /**

     *  Set composite reputation value by string key

     */

    function setCompositeReputation(string key, uint32 value) external onlyMonetha {

        compositeReputationMap[key] = value;

    }



    /**

     *  Allows withdrawal of funds to beneficiary address

     */

    function doWithdrawal(address beneficiary, uint amount) private {

        require(beneficiary != 0x0);

        beneficiary.transfer(amount);

    }



    /**

     *  Allows merchant to withdraw funds to beneficiary address

     */

    function withdrawTo(address beneficiary, uint amount) public onlyMerchant whenNotPaused {

        doWithdrawal(beneficiary, amount);

    }



    /**

     *  Allows merchant to withdraw funds to it's own account

     */

    function withdraw(uint amount) external onlyMerchant {

        withdrawTo(msg.sender, amount);

    }



    /**

     *  Allows merchant or Monetha to initiate exchange of funds by withdrawing funds to deposit address of the exchange

     */

    function withdrawToExchange(address depositAccount, uint amount) external onlyMerchantOrMonetha whenNotPaused {

        doWithdrawal(depositAccount, amount);

    }



    /**

     *  Allows merchant or Monetha to initiate exchange of funds by withdrawing all funds to deposit address of the exchange

     */

    function withdrawAllToExchange(address depositAccount, uint min_amount) external onlyMerchantOrMonetha whenNotPaused {

        require (address(this).balance >= min_amount);

        doWithdrawal(depositAccount, address(this).balance);

    }



    /**

     *  Allows merchant to change it's account address

     */

    function changeMerchantAccount(address newAccount) external onlyMerchant whenNotPaused {

        merchantAccount = newAccount;

    }



    /**

     *  Allows merchant to change it's fund address.

     */

    function changeFundAddress(address newFundAddress) external onlyMerchant isEOA(newFundAddress) {

        merchantFundAddress = newFundAddress;

    }

}



// File: contracts/PrivatePaymentProcessor.sol



contract PrivatePaymentProcessor is Pausable, Destructible, Contactable, Restricted {



    using SafeMath for uint256;



    string constant VERSION = "0.5";



    // Order paid event

    event OrderPaidInEther(

        uint indexed _orderId,

        address indexed _originAddress,

        uint _price,

        uint _monethaFee

    );



    event OrderPaidInToken(

        uint indexed _orderId,

        address indexed _originAddress,

        address indexed _tokenAddress,

        uint _price,

        uint _monethaFee

    );



    // Payments have been processed event

    event PaymentsProcessed(

        address indexed _merchantAddress,

        uint _amount,

        uint _fee

    );



    // PaymentRefunding is an event when refunding initialized

    event PaymentRefunding(

        uint indexed _orderId,

        address indexed _clientAddress,

        uint _amount,

        string _refundReason

    );



    // PaymentWithdrawn event is fired when payment is withdrawn

    event PaymentWithdrawn(

        uint indexed _orderId,

        address indexed _clientAddress,

        uint amount

    );



    /// MonethaGateway contract for payment processing

    MonethaGateway public monethaGateway;



    /// Address of MerchantWallet, where merchant reputation and funds are stored

    MerchantWallet public merchantWallet;



    /// Merchant identifier hash, that associates with the acceptor

    bytes32 public merchantIdHash;



    enum WithdrawState {Null, Pending, Withdrawn}



    struct Withdraw {

        WithdrawState state;

        uint amount;

        address clientAddress;

    }



    mapping (uint=>Withdraw) public withdrawals;



    /**

     *  Private Payment Processor sets Monetha Gateway and Merchant Wallet.

     *  @param _merchantId Merchant of the acceptor

     *  @param _monethaGateway Address of MonethaGateway contract for payment processing

     *  @param _merchantWallet Address of MerchantWallet, where merchant reputation and funds are stored

     */

    constructor(

        string _merchantId,

        MonethaGateway _monethaGateway,

        MerchantWallet _merchantWallet

    )

        public

    {

        require(bytes(_merchantId).length > 0);



        merchantIdHash = keccak256(_merchantId);



        setMonethaGateway(_monethaGateway);

        setMerchantWallet(_merchantWallet);

    }



    /**

     *  payForOrder is used by order wallet/client to pay for the order

     *  @param _orderId Identifier of the order

     *  @param _originAddress buyer address

     *  @param _monethaFee is fee collected by Monetha

     */

    function payForOrder(

        uint _orderId,

        address _originAddress,

        uint _monethaFee

    )

        external payable whenNotPaused

    {

        require(_orderId > 0);

        require(_originAddress != 0x0);

        require(msg.value > 0);



        address fundAddress;

        fundAddress = merchantWallet.merchantFundAddress();



        if (fundAddress != address(0)) {

            monethaGateway.acceptPayment.value(msg.value)(fundAddress, _monethaFee);

        } else {

            monethaGateway.acceptPayment.value(msg.value)(merchantWallet, _monethaFee);

        }



        // log payment event

        emit OrderPaidInEther(_orderId, _originAddress, msg.value, _monethaFee);

    }



    /**

     *  payForOrderInTokens is used by order wallet/client to pay for the order

     *  This call requires that token's approve method has been called prior to this.

     *  @param _orderId Identifier of the order

     *  @param _originAddress buyer address

     *  @param _monethaFee is fee collected by Monetha

     *  @param _tokenAddress is tokens address

     *  @param _orderValue is order amount

     */

    function payForOrderInTokens(

        uint _orderId,

        address _originAddress,

        uint _monethaFee,

        address _tokenAddress,

        uint _orderValue

    )

        external whenNotPaused

    {

        require(_orderId > 0);

        require(_originAddress != 0x0);

        require(_orderValue > 0);

        require(_tokenAddress != address(0));



        address fundAddress;

        fundAddress = merchantWallet.merchantFundAddress();



        ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _orderValue);

        

        ERC20(_tokenAddress).transfer(address(monethaGateway), _orderValue);



        if (fundAddress != address(0)) {

            monethaGateway.acceptTokenPayment(fundAddress, _monethaFee, _tokenAddress, _orderValue);

        } else {

            monethaGateway.acceptTokenPayment(merchantWallet, _monethaFee, _tokenAddress, _orderValue);

        }

        

        // log payment event

        emit OrderPaidInToken(_orderId, _originAddress, _tokenAddress, _orderValue, _monethaFee);

    }



    /**

     *  refundPayment used in case order cannot be processed and funds need to be returned

     *  This function initiate process of funds refunding to the client.

     *  @param _orderId Identifier of the order

     *  @param _clientAddress is an address of client

     *  @param _refundReason Order refund reason

     */

    function refundPayment(

        uint _orderId,

        address _clientAddress,

        string _refundReason

    )

        external payable onlyMonetha whenNotPaused

    {

        require(_orderId > 0);

        require(_clientAddress != 0x0);

        require(msg.value > 0);

        require(WithdrawState.Null == withdrawals[_orderId].state);



        // create withdraw

        withdrawals[_orderId] = Withdraw({

            state: WithdrawState.Pending,

            amount: msg.value,

            clientAddress: _clientAddress

            });



        // log refunding

        emit PaymentRefunding(_orderId, _clientAddress, msg.value, _refundReason);

    }



    /**

     *  refundTokenPayment used in case order cannot be processed and tokens need to be returned

     *  This call requires that token's approve method has been called prior to this.

     *  This function initiate process of refunding tokens to the client.

     *  @param _orderId Identifier of the order

     *  @param _clientAddress is an address of client

     *  @param _refundReason Order refund reason

     *  @param _tokenAddress is tokens address

     *  @param _orderValue is order amount

     */

    function refundTokenPayment(

        uint _orderId,

        address _clientAddress,

        string _refundReason,

        uint _orderValue,

        address _tokenAddress

    )

        external onlyMonetha whenNotPaused

    {

        require(_orderId > 0);

        require(_clientAddress != 0x0);

        require(_orderValue > 0);

        require(_tokenAddress != address(0));

        require(WithdrawState.Null == withdrawals[_orderId].state);



        ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _orderValue);

        

        // create withdraw

        withdrawals[_orderId] = Withdraw({

            state: WithdrawState.Pending,

            amount: _orderValue,

            clientAddress: _clientAddress

            });



        // log refunding

        emit PaymentRefunding(_orderId, _clientAddress, _orderValue, _refundReason);

    }



    /**

     *  withdrawRefund performs fund transfer to the client's account.

     *  @param _orderId Identifier of the order

     */

    function withdrawRefund(uint _orderId)

        external whenNotPaused

    {

        Withdraw storage withdraw = withdrawals[_orderId];

        require(WithdrawState.Pending == withdraw.state);



        address clientAddress = withdraw.clientAddress;

        uint amount = withdraw.amount;



        // changing withdraw state before transfer

        withdraw.state = WithdrawState.Withdrawn;



        // transfer fund to clients account

        clientAddress.transfer(amount);



        // log withdrawn

        emit PaymentWithdrawn(_orderId, clientAddress, amount);

    }



    /**

     *  withdrawTokenRefund performs token transfer to the client's account.

     *  @param _orderId Identifier of the order

     *  @param _tokenAddress token address

     */

    function withdrawTokenRefund(uint _orderId, address _tokenAddress)

        external whenNotPaused

    {

        require(_tokenAddress != address(0));



        Withdraw storage withdraw = withdrawals[_orderId];

        require(WithdrawState.Pending == withdraw.state);



        address clientAddress = withdraw.clientAddress;

        uint amount = withdraw.amount;



        // changing withdraw state before transfer

        withdraw.state = WithdrawState.Withdrawn;



        // transfer fund to clients account

        ERC20(_tokenAddress).transfer(clientAddress, amount);



        // log withdrawn

        emit PaymentWithdrawn(_orderId, clientAddress, amount);

    }



    /**

     *  setMonethaGateway allows owner to change address of MonethaGateway.

     *  @param _newGateway Address of new MonethaGateway contract

     */

    function setMonethaGateway(MonethaGateway _newGateway) public onlyOwner {

        require(address(_newGateway) != 0x0);



        monethaGateway = _newGateway;

    }



    /**

     *  setMerchantWallet allows owner to change address of MerchantWallet.

     *  @param _newWallet Address of new MerchantWallet contract

     */

    function setMerchantWallet(MerchantWallet _newWallet) public onlyOwner {

        require(address(_newWallet) != 0x0);

        require(_newWallet.merchantIdHash() == merchantIdHash);



        merchantWallet = _newWallet;

    }

}