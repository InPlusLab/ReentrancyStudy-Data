pragma solidity ^0.4.11;

contract SafeMath {

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256 ) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256 ) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256 ) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256 ) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20 {

    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is ERC20, SafeMath {

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Transfers sender&#39;s tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) public returns (bool) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = safeSub(balances[msg.sender], _value);
            balances[_to] = safeAdd(balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else return false;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] = safeAdd(balances[_to], _value);
            balances[_from] = safeSub(balances[_from], _value);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        } else return false;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract Ownable {

    address public owner;
    address public pendingOwner;

    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Safe transfer of ownership in 2 steps. Once called, a newOwner needs to call claimOwnership() to prove ownership.
    function transferOwnership(address newOwner) onlyOwner {
        pendingOwner = newOwner;
    }

    function claimOwnership() {
        if (msg.sender == pendingOwner) {
            owner = pendingOwner;
            pendingOwner = 0;
        }
    }
}

contract MultiOwnable {

    mapping (address => bool) ownerMap;
    address[] public owners;

    event OwnerAdded(address indexed _newOwner);
    event OwnerRemoved(address indexed _oldOwner);

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function MultiOwnable() {
        // Add default owner
        address owner = msg.sender;
        ownerMap[owner] = true;
        owners.push(owner);
    }

    function ownerCount() public constant returns (uint256) {
        return owners.length;
    }

    function isOwner(address owner) public constant returns (bool) {
        return ownerMap[owner];
    }

    function addOwner(address owner) onlyOwner public returns (bool) {
        if (!isOwner(owner) && owner != 0) {
            ownerMap[owner] = true;
            owners.push(owner);

            OwnerAdded(owner);
            return true;
        } else return false;
    }

    function removeOwner(address owner) onlyOwner public returns (bool) {
        if (isOwner(owner)) {
            ownerMap[owner] = false;
            for (uint i = 0; i < owners.length - 1; i++) {
                if (owners[i] == owner) {
                    owners[i] = owners[owners.length - 1];
                    break;
                }
            }
            owners.length -= 1;

            OwnerRemoved(owner);
            return true;
        } else return false;
    }
}

contract Pausable is Ownable {

    bool public paused;

    modifier ifNotPaused {
        require(!paused);
        _;
    }

    modifier ifPaused {
        require(paused);
        _;
    }

    // Called by the owner on emergency, triggers paused state
    function pause() external onlyOwner {
        paused = true;
    }

    // Called by the owner on end of emergency, returns to normal state
    function resume() external onlyOwner ifPaused {
        paused = false;
    }
}

contract CommonBsToken is StandardToken, MultiOwnable {

    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals = 18;
    string public version = &#39;v0.1&#39;;

    address public creator;
    address public seller;     // The main account that holds all tokens at the beginning.

    uint256 public saleLimit;  // (e18) How many tokens can be sold in total through all tiers or tokensales.
    uint256 public tokensSold; // (e18) Number of tokens sold through all tiers or tokensales.
    uint256 public totalSales; // Total number of sale (including external sales) made through all tiers or tokensales.

    bool public locked;

    event Sell(address indexed _seller, address indexed _buyer, uint256 _value);
    event SellerChanged(address indexed _oldSeller, address indexed _newSeller);

    event Lock();
    event Unlock();

    event Burn(address indexed _burner, uint256 _value);

    modifier onlyUnlocked() {
        if (!isOwner(msg.sender) && locked) throw;
        _;
    }

    function CommonBsToken(
        address _seller,
        string _name,
        string _symbol,
        uint256 _totalSupplyNoDecimals,
        uint256 _saleLimitNoDecimals
    ) MultiOwnable() {

        // Lock the transfer function during the presale/crowdsale to prevent speculations.
        locked = true;

        creator = msg.sender;
        seller = _seller;

        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupplyNoDecimals * 1e18;
        saleLimit = _saleLimitNoDecimals * 1e18;

        balances[seller] = totalSupply;
        Transfer(0x0, seller, totalSupply);
    }

    function changeSeller(address newSeller) onlyOwner public returns (bool) {
        require(newSeller != 0x0 && seller != newSeller);

        address oldSeller = seller;
        uint256 unsoldTokens = balances[oldSeller];
        balances[oldSeller] = 0;
        balances[newSeller] = safeAdd(balances[newSeller], unsoldTokens);
        Transfer(oldSeller, newSeller, unsoldTokens);

        seller = newSeller;
        SellerChanged(oldSeller, newSeller);
        return true;
    }

    function sellNoDecimals(address _to, uint256 _value) public returns (bool) {
        return sell(_to, _value * 1e18);
    }

    function sell(address _to, uint256 _value) onlyOwner public returns (bool) {

        // Check that we are not out of limit and still can sell tokens:
        if (saleLimit > 0) require(safeSub(saleLimit, safeAdd(tokensSold, _value)) >= 0);

        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[seller]);

        balances[seller] = safeSub(balances[seller], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(seller, _to, _value);

        tokensSold = safeAdd(tokensSold, _value);
        totalSales = safeAdd(totalSales, 1);
        Sell(seller, _to, _value);

        return true;
    }

    function transfer(address _to, uint256 _value) onlyUnlocked public returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyUnlocked public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function lock() onlyOwner public {
        locked = true;
        Lock();
    }

    function unlock() onlyOwner public {
        locked = false;
        Unlock();
    }

    function burn(uint256 _value) public returns (bool) {
        require(_value > 0);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = safeSub(balances[msg.sender], _value) ;
        totalSupply = safeSub(totalSupply, _value);
        Transfer(msg.sender, 0x0, _value);
        Burn(msg.sender, _value);

        return true;
    }
}

contract CommonBsPresale is SafeMath, Ownable, Pausable {

    enum Currency { BTC, LTC, ZEC, DASH, WAVES, USD, EUR }

    // TODO rename to Buyer?

    struct Backer {
        uint256 weiReceived; // Amount of wei given by backer
        uint256 tokensSent;  // Amount of tokens received in return to the given amount of ETH.
    }

    // TODO rename to buyers?

    // (buyer_eth_address -> struct)
    mapping(address => Backer) public backers;

    // currency_code => (tx_hash => tokens)
    mapping(uint8 => mapping(bytes32 => uint256)) public externalTxs;

    CommonBsToken public token; // Token contract reference.
    address public beneficiary; // Address that will receive ETH raised during this crowdsale.
    address public notifier;    // Address that can this crowdsale about changed external conditions.

    // TODO implement
    uint256 public minWeiToAccept = 0.0001 ether;

    uint256 public maxCapWei = 0.01 ether;
    uint public tokensPerWei = 400 * 1.25; // Ordinary price: 1 ETH = 400 tokens. Plus 25% bonus during presale.

    uint public startTime; // Will be setup once in a constructor from now().
    uint public endTime = 1520600400; // 2018-03-09T13:00:00Z

    // Stats for current crowdsale

    uint256 public totalInWei         = 0; // Grand total in wei
    uint256 public totalTokensSold    = 0; // Total amount of tokens sold during this crowdsale.
    uint256 public totalEthSales      = 0; // Total amount of ETH contributions during this crowdsale.
    uint256 public totalExternalSales = 0; // Total amount of external contributions (BTC, LTC, USD, etc.) during this crowdsale.
    uint256 public weiReceived        = 0; // Total amount of wei received during this crowdsale smart contract.

    uint public finalizedTime = 0; // Unix timestamp when finalize() was called.

    bool public saleEnabled = true;   // if false, then contract will not sell tokens on payment received

    event BeneficiaryChanged(address indexed _oldAddress, address indexed _newAddress);
    event NotifierChanged(address indexed _oldAddress, address indexed _newAddress);

    event EthReceived(address indexed _buyer, uint256 _amountWei);
    event ExternalSale(Currency _currency, bytes32 _txIdSha3, address indexed _buyer, uint256 _amountWei, uint256 _tokensE18);

    modifier respectTimeFrame() {
        require(isSaleOn());
        _;
    }

    modifier canNotify() {
        require(msg.sender == owner || msg.sender == notifier);
        _;
    }

    function CommonBsPresale(address _owner, address _token, address _beneficiary) {
        token = CommonBsToken(_token);
        owner = _owner;
        notifier = owner;
        beneficiary = _beneficiary;
        startTime = now;
    }

    // Override this method to mock current time.
    function getNow() public constant returns (uint) {
        return now;
    }

    function setSaleEnabled(bool _enabled) public onlyOwner {
        saleEnabled = _enabled;
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        BeneficiaryChanged(beneficiary, _beneficiary);
        beneficiary = _beneficiary;
    }

    function setNotifier(address _notifier) public onlyOwner {
        NotifierChanged(notifier, _notifier);
        notifier = _notifier;
    }

    /*
     * The fallback function corresponds to a donation in ETH
     */
    function() public payable {
        if (saleEnabled) sellTokensForEth(msg.sender, msg.value);
    }

    function sellTokensForEth(address _buyer, uint256 _amountWei) internal ifNotPaused respectTimeFrame {

        require(_amountWei >= minWeiToAccept);

        totalInWei = safeAdd(totalInWei, _amountWei);
        weiReceived = safeAdd(weiReceived, _amountWei);
        require(totalInWei <= maxCapWei); // If max cap reached.

        uint256 tokensE18 = weiToTokens(_amountWei);
        require(token.sell(_buyer, tokensE18)); // Transfer tokens to buyer.
        totalTokensSold = safeAdd(totalTokensSold, tokensE18);
        totalEthSales++;

        Backer backer = backers[_buyer];
        backer.tokensSent = safeAdd(backer.tokensSent, tokensE18);
        backer.weiReceived = safeAdd(backer.weiReceived, _amountWei);  // Update the total wei collected during the crowdfunding for this backer

        EthReceived(_buyer, _amountWei);
    }

    // Calc how much tokens you can buy at current time.
    function weiToTokens(uint256 _amountWei) public constant returns (uint256) {
        return safeMul(_amountWei, tokensPerWei);
    }

    //----------------------------------------------------------------------
    // Begin of external sales.

    function externalSales(
        uint8[] _currencies,
        bytes32[] _txIdSha3,
        address[] _buyers,
        uint256[] _amountsWei,
        uint256[] _tokensE18
    ) public ifNotPaused canNotify {

        require(_currencies.length > 0);
        require(_currencies.length == _txIdSha3.length);
        require(_currencies.length == _buyers.length);
        require(_currencies.length == _amountsWei.length);
        require(_currencies.length == _tokensE18.length);

        for (uint i = 0; i < _txIdSha3.length; i++) {
            _externalSaleSha3(
                Currency(_currencies[i]),
                _txIdSha3[i],
                _buyers[i],
                _amountsWei[i],
                _tokensE18[i]
            );
        }
    }

    function _externalSaleSha3(
        Currency _currency,
        bytes32 _txIdSha3, // To get bytes32 use keccak256(txId) OR sha3(txId)
        address _buyer,
        uint256 _amountWei,
        uint256 _tokensE18
    ) internal {

        require(_buyer > 0 && _amountWei > 0 && _tokensE18 > 0);

        var txsByCur = externalTxs[uint8(_currency)];

        // If this foreign transaction has been already processed in this contract.
        require(txsByCur[_txIdSha3] == 0);

        totalInWei = safeAdd(totalInWei, _amountWei);
        require(totalInWei <= maxCapWei); // Max cap should not be reached yet.

        require(token.sell(_buyer, _tokensE18)); // Transfer tokens to buyer.
        totalTokensSold = safeAdd(totalTokensSold, _tokensE18);
        totalExternalSales++;

        txsByCur[_txIdSha3] = _tokensE18;
        ExternalSale(_currency, _txIdSha3, _buyer, _amountWei, _tokensE18);
    }

    // Get id of currency enum. --------------------------------------------

    function btcId() public constant returns (uint8) {
        return uint8(Currency.BTC);
    }

    function ltcId() public constant returns (uint8) {
        return uint8(Currency.LTC);
    }

    function zecId() public constant returns (uint8) {
        return uint8(Currency.ZEC);
    }

    function dashId() public constant returns (uint8) {
        return uint8(Currency.DASH);
    }

    function wavesId() public constant returns (uint8) {
        return uint8(Currency.WAVES);
    }

    function usdId() public constant returns (uint8) {
        return uint8(Currency.USD);
    }

    function eurId() public constant returns (uint8) {
        return uint8(Currency.EUR);
    }

    // Get token count by transaction id. ----------------------------------

    function _tokensByTx(Currency _currency, string _txId) internal constant returns (uint256) {
        return tokensByTx(uint8(_currency), _txId);
    }

    function tokensByTx(uint8 _currency, string _txId) public constant returns (uint256) {
        return externalTxs[_currency][keccak256(_txId)];
    }

    function tokensByBtcTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.BTC, _txId);
    }

    function tokensByLtcTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.LTC, _txId);
    }

    function tokensByZecTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.ZEC, _txId);
    }

    function tokensByDashTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.DASH, _txId);
    }

    function tokensByWavesTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.WAVES, _txId);
    }

    function tokensByUsdTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.USD, _txId);
    }

    function tokensByEurTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.EUR, _txId);
    }

    // End of external sales.
    //----------------------------------------------------------------------

    function totalSales() public constant returns (uint256) {
        return safeAdd(totalEthSales, totalExternalSales);
    }

    function isMaxCapReached() public constant returns (bool) {
        return totalInWei >= maxCapWei;
    }

    function isSaleOn() public constant returns (bool) {
        uint _now = getNow();
        return startTime <= _now && _now <= endTime;
    }

    function isSaleOver() public constant returns (bool) {
        return getNow() > endTime;
    }

    function isFinalized() public constant returns (bool) {
        return finalizedTime > 0;
    }

    /*
     * Finalize the crowdsale. Raised money can be sent to beneficiary only if crowdsale hit end time or max cap.
     */
    function finalize() public onlyOwner {

        // Cannot finalise before end day of crowdsale until max cap is reached.
        require(isMaxCapReached() || isSaleOver());

        beneficiary.transfer(this.balance);

        finalizedTime = getNow();
    }
}


contract XToken is CommonBsToken {

    function XToken() public CommonBsToken(
        0xE3E9F66E5Ebe9E961662da34FF9aEA95c6795fd0,     // TODO address _seller (main holder of all tokens)
        &#39;X full&#39;,
        &#39;X short&#39;,
        100 * 1e6, // Max token supply.
        40 * 1e6   // Sale limit - max tokens that can be sold through all tiers of tokensale.
    ) {}
}

contract XPresale is CommonBsPresale {

    function XPresale(address _owner, address _token) public CommonBsPresale(
        _owner,
        _token,
        0xE3E9F66E5Ebe9E961662da34FF9aEA95c6795fd0  // TODO address _beneficiary
    ) {}
}

contract Deployer {
    
    XToken public token;
    XPresale public presale;
    
    function Deployer() public {
        address owner = msg.sender;
        token = new XToken();
        presale = new XPresale(owner, token);
        token.addOwner(owner);
        token.addOwner(presale);
    }
}