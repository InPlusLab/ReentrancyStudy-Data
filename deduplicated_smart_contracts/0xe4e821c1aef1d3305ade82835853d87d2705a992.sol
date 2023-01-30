pragma solidity ^0.4.11;

/*
    Utilities & Common Modifiers
*/
contract Utils {
    /**
        constructor
    */
    function Utils() {
    }

    // verifies that an amount is greater than zero
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    // validates an address - currently only checks that it isn&#39;t null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    // verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

    // Overflow protected math functions

    /**
        @dev returns the sum of _x and _y, asserts if the calculation overflows

        @param _x   value 1
        @param _y   value 2

        @return sum
    */
    function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

    /**
        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number

        @param _x   minuend
        @param _y   subtrahend

        @return difference
    */
    function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

    /**
        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows

        @param _x   factor 1
        @param _y   factor 2

        @return product
    */
    function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}

/*
    Owned contract interface
*/
contract IOwned {
    // this function isn&#39;t abstract since the compiler emits automatically generated getter functions as external
    function owner() public constant returns (address owner) { owner; }

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

/*
    Provides support and utilities for contract ownership
*/
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address _prevOwner, address _newOwner);

    /**
        @dev constructor
    */
    function Owned() {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

    /**
        @dev allows transferring the contract ownership
        the new owner still needs to accept the transfer
        can only be called by the contract owner

        @param _newOwner    new contract owner
    */
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
        @dev used by a new owner to accept an ownership transfer
    */
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

/*
    Provides support and utilities for contract management
*/
contract Managed {
    address public manager;
    address public newManager;

    event ManagerUpdate(address _prevManager, address _newManager);

    /**
        @dev constructor
    */
    function Managed() {
        manager = msg.sender;
    }

    // allows execution by the manager only
    modifier managerOnly {
        assert(msg.sender == manager);
        _;
    }

    /**
        @dev allows transferring the contract management
        the new manager still needs to accept the transfer
        can only be called by the contract manager

        @param _newManager    new contract manager
    */
    function transferManagement(address _newManager) public managerOnly {
        require(_newManager != manager);
        newManager = _newManager;
    }

    /**
        @dev used by a new manager to accept a management transfer
    */
    function acceptManagement() public {
        require(msg.sender == newManager);
        ManagerUpdate(manager, newManager);
        manager = newManager;
        newManager = 0x0;
    }
}

/*
    Token Holder interface
*/
contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}

/*
    We consider every contract to be a &#39;token holder&#39; since it&#39;s currently not possible
    for a contract to deny receiving tokens.

    The TokenHolder&#39;s contract sole purpose is to provide a safety mechanism that allows
    the owner to send tokens that were sent to the contract by mistake back to their sender.
*/
contract TokenHolder is ITokenHolder, Owned, Utils {
    /**
        @dev constructor
    */
    function TokenHolder() {
    }

    /**
        @dev withdraws tokens held by the contract and sends them to an account
        can only be called by the owner

        @param _token   ERC20 token contract address
        @param _to      account to receive the new amount
        @param _amount  amount to withdraw
    */
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        assert(_token.transfer(_to, _amount));
    }
}

/*
    The smart token controller is an upgradable part of the smart token that allows
    more functionality as well as fixes for bugs/exploits.
    Once it accepts ownership of the token, it becomes the token&#39;s sole controller
    that can execute any of its functions.

    To upgrade the controller, ownership must be transferred to a new controller, along with
    any relevant data.

    The smart token must be set on construction and cannot be changed afterwards.
    Wrappers are provided (as opposed to a single &#39;execute&#39; function) for each of the token&#39;s functions, for easier access.

    Note that the controller can transfer token ownership to a new controller that
    doesn&#39;t allow executing any function on the token, for a trustless solution.
    Doing that will also remove the owner&#39;s ability to upgrade the controller.
*/
contract SmartTokenController is TokenHolder {
    ISmartToken public token;   // smart token

    /**
        @dev constructor
    */
    function SmartTokenController(ISmartToken _token)
        validAddress(_token)
    {
        token = _token;
    }

    // ensures that the controller is the token&#39;s owner
    modifier active() {
        assert(token.owner() == address(this));
        _;
    }

    // ensures that the controller is not the token&#39;s owner
    modifier inactive() {
        assert(token.owner() != address(this));
        _;
    }

    /**
        @dev allows transferring the token ownership
        the new owner still need to accept the transfer
        can only be called by the contract owner

        @param _newOwner    new token owner
    */
    function transferTokenOwnership(address _newOwner) public ownerOnly {
        token.transferOwnership(_newOwner);
    }

    /**
        @dev used by a new owner to accept a token ownership transfer
        can only be called by the contract owner
    */
    function acceptTokenOwnership() public ownerOnly {
        token.acceptOwnership();
    }

    /**
        @dev disables/enables token transfers
        can only be called by the contract owner

        @param _disable    true to disable transfers, false to enable them
    */
    function disableTokenTransfers(bool _disable) public ownerOnly {
        token.disableTransfers(_disable);
    }

    /**
        @dev withdraws tokens held by the token and sends them to an account
        can only be called by the owner

        @param _token   ERC20 token contract address
        @param _to      account to receive the new amount
        @param _amount  amount to withdraw
    */
    function withdrawFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        token.withdrawTokens(_token, _to, _amount);
    }
}

/*
    ERC20 Standard Token interface
*/
contract IERC20Token {
    // these functions aren&#39;t abstract since the compiler emits automatically generated getter functions as external
    function name() public constant returns (string name) { name; }
    function symbol() public constant returns (string symbol) { symbol; }
    function decimals() public constant returns (uint8 decimals) { decimals; }
    function totalSupply() public constant returns (uint256 totalSupply) { totalSupply; }
    function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

/*
    Ether Token interface
*/
contract IEtherToken is ITokenHolder, IERC20Token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
    function withdrawTo(address _to, uint256 _amount);
}

/*
    Smart Token interface
*/
contract ISmartToken is ITokenHolder, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}

/*
    Bancor Formula interface
*/
contract IBancorFormula {
    function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount) public constant returns (uint256);
    function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount) public constant returns (uint256);
}

/*
    EIP228 Token Changer interface
*/
contract ITokenChanger {
    function changeableTokenCount() public constant returns (uint16 count);
    function changeableToken(uint16 _tokenIndex) public constant returns (address tokenAddress);
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public constant returns (uint256 amount);
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 amount);
}

/*
    Open issues:
    - Add miner front-running attack protection. The issue is somewhat mitigated by the use of _minReturn when changing
    - Possibly add getters for reserve fields so that the client won&#39;t need to rely on the order in the struct
*/

/*
    Bancor Changer v0.2

    The Bancor version of the token changer, allows changing between a smart token and other ERC20 tokens and between different ERC20 tokens and themselves.

    ERC20 reserve token balance can be virtual, meaning that the calculations are based on the virtual balance instead of relying on
    the actual reserve balance. This is a security mechanism that prevents the need to keep a very large (and valuable) balance in a single contract.

    The changer is upgradable (just like any SmartTokenController).

    A note on change paths -
    Change path is a data structure that&#39;s used when changing a token to another token in the bancor network
    when the change cannot necessarily be done by single changer and might require multiple &#39;hops&#39;.
    The path defines which changers should be used and what kind of change should be done in each step.

    The path format doesn&#39;t include complex structure and instead, it is represented by a single array
    in which each &#39;hop&#39; is represented by a 2-tuple - smart token & to token.
    In addition, the first element is always the source token.
    The smart token is only used as a pointer to a changer (since changer addresses are more likely to change).

    Format:
    [source token, smart token, to token, smart token, to token...]


    WARNING: It is NOT RECOMMENDED to use the changer with Smart Tokens that have less than 8 decimal digits
             or with very small numbers because of precision loss
*/
contract BancorChanger is ITokenChanger, SmartTokenController, Managed {
    uint32 private constant MAX_CRR = 1000000;
    uint32 private constant MAX_CHANGE_FEE = 1000000;

    struct Reserve {
        uint256 virtualBalance;         // virtual balance
        uint32 ratio;                   // constant reserve ratio (CRR), represented in ppm, 1-1000000
        bool isVirtualBalanceEnabled;   // true if virtual balance is enabled, false if not
        bool isPurchaseEnabled;         // is purchase of the smart token enabled with the reserve, can be set by the owner
        bool isSet;                     // used to tell if the mapping element is defined
    }

    string public version = &#39;0.2&#39;;
    string public changerType = &#39;bancor&#39;;

    IBancorFormula public formula;                  // bancor calculation formula contract
    IERC20Token[] public reserveTokens;             // ERC20 standard token addresses
    IERC20Token[] public quickBuyPath;              // change path that&#39;s used in order to buy the token with ETH
    mapping (address => Reserve) public reserves;   // reserve token addresses -> reserve data
    uint32 private totalReserveRatio = 0;           // used to efficiently prevent increasing the total reserve ratio above 100%
    uint32 public maxChangeFee = 0;                 // maximum change fee for the lifetime of the contract, represented in ppm, 0...1000000 (0 = no fee, 100 = 0.01%, 1000000 = 100%)
    uint32 public changeFee = 0;                    // current change fee, represented in ppm, 0...maxChangeFee
    bool public changingEnabled = true;             // true if token changing is enabled, false if not

    // triggered when a change between two tokens occurs (TokenChanger event)
    event Change(address indexed _fromToken, address indexed _toToken, address indexed _trader, uint256 _amount, uint256 _return,
                 uint256 _currentPriceN, uint256 _currentPriceD);

    /**
        @dev constructor

        @param  _token          smart token governed by the changer
        @param  _formula        address of a bancor formula contract
        @param  _maxChangeFee   maximum change fee, represented in ppm
        @param  _reserveToken   optional, initial reserve, allows defining the first reserve at deployment time
        @param  _reserveRatio   optional, ratio for the initial reserve
    */
    function BancorChanger(ISmartToken _token, IBancorFormula _formula, uint32 _maxChangeFee, IERC20Token _reserveToken, uint32 _reserveRatio)
        SmartTokenController(_token)
        validAddress(_formula)
        validMaxChangeFee(_maxChangeFee)
    {
        formula = _formula;
        maxChangeFee = _maxChangeFee;

        if (address(_reserveToken) != 0x0)
            addReserve(_reserveToken, _reserveRatio, false);
    }

    // validates a reserve token address - verifies that the address belongs to one of the reserve tokens
    modifier validReserve(IERC20Token _address) {
        require(reserves[_address].isSet);
        _;
    }

    // validates a token address - verifies that the address belongs to one of the changeable tokens
    modifier validToken(IERC20Token _address) {
        require(_address == token || reserves[_address].isSet);
        _;
    }

    // validates maximum change fee
    modifier validMaxChangeFee(uint32 _changeFee) {
        require(_changeFee >= 0 && _changeFee <= MAX_CHANGE_FEE);
        _;
    }

    // validates change fee
    modifier validChangeFee(uint32 _changeFee) {
        require(_changeFee >= 0 && _changeFee <= maxChangeFee);
        _;
    }

    // validates reserve ratio range
    modifier validReserveRatio(uint32 _ratio) {
        require(_ratio > 0 && _ratio <= MAX_CRR);
        _;
    }

    // validates a change path - verifies that the number of elements is odd and that maximum number of &#39;hops&#39; is 10
    modifier validChangePath(IERC20Token[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

    // allows execution only when changing isn&#39;t disabled
    modifier changingAllowed {
        assert(changingEnabled);
        _;
    }

    /**
        @dev returns the number of reserve tokens defined

        @return number of reserve tokens
    */
    function reserveTokenCount() public constant returns (uint16 count) {
        return uint16(reserveTokens.length);
    }

    /**
        @dev returns the number of changeable tokens supported by the contract
        note that the number of changeable tokens is the number of reserve token, plus 1 (that represents the smart token)

        @return number of changeable tokens
    */
    function changeableTokenCount() public constant returns (uint16 count) {
        return reserveTokenCount() + 1;
    }

    /**
        @dev given a changeable token index, returns the changeable token contract address

        @param _tokenIndex  changeable token index

        @return number of changeable tokens
    */
    function changeableToken(uint16 _tokenIndex) public constant returns (address tokenAddress) {
        if (_tokenIndex == 0)
            return token;
        return reserveTokens[_tokenIndex - 1];
    }

    /*
        @dev allows the owner to update the formula contract address

        @param _formula    address of a bancor formula contract
    */
    function setFormula(IBancorFormula _formula)
        public
        ownerOnly
        validAddress(_formula)
        notThis(_formula)
    {
        formula = _formula;
    }

    /*
        @dev allows the manager to update the quick buy path

        @param _path    new quick buy path, see change path format above
    */
    function setQuickBuyPath(IERC20Token[] _path)
        public
        ownerOnly
        validChangePath(_path)
    {
        quickBuyPath = _path;
    }

    /*
        @dev allows the manager to clear the quick buy path
    */
    function clearQuickBuyPath() public ownerOnly {
        quickBuyPath.length = 0;
    }

    /**
        @dev returns the length of the quick buy path array

        @return quick buy path length
    */
    function getQuickBuyPathLength() public constant returns (uint256 length) {
        return quickBuyPath.length;
    }

    /**
        @dev returns true if ether token exists in the quick buy path, false if not
        note that there should always be one in the quick buy path, if one is set

        @return true if ether token exists, false if not
    */
    function hasQuickBuyEtherToken() public constant returns (bool) {
        return quickBuyPath.length > 0;
    }

    /**
        @dev returns the address of the ether token used by the quick buy functionality
        note that it should always be the first element in the quick buy path, if one is set

        @return ether token address
    */
    function getQuickBuyEtherToken() public constant returns (IEtherToken etherToken) {
        assert(quickBuyPath.length > 0);
        return IEtherToken(quickBuyPath[0]);
    }

    /**
        @dev disables the entire change functionality
        this is a safety mechanism in case of a emergency
        can only be called by the manager

        @param _disable true to disable changing, false to re-enable it
    */
    function disableChanging(bool _disable) public managerOnly {
        changingEnabled = !_disable;
    }

    /**
        @dev updates the current change fee
        can only be called by the manager

        @param _changeFee new change fee, represented in ppm
    */
    function setChangeFee(uint32 _changeFee)
        public
        managerOnly
        validChangeFee(_changeFee)
    {
        changeFee = _changeFee;
    }

    /*
        @dev returns the change fee amount for a given return amount

        @return change fee amount
    */
    function getChangeFeeAmount(uint256 _amount) public constant returns (uint256 feeAmount) {
        return safeMul(_amount, changeFee) / MAX_CHANGE_FEE;
    }

    /**
        @dev defines a new reserve for the token
        can only be called by the owner while the changer is inactive

        @param _token                  address of the reserve token
        @param _ratio                  constant reserve ratio, represented in ppm, 1-1000000
        @param _enableVirtualBalance   true to enable virtual balance for the reserve, false to disable it
    */
    function addReserve(IERC20Token _token, uint32 _ratio, bool _enableVirtualBalance)
        public
        ownerOnly
        inactive
        validAddress(_token)
        notThis(_token)
        validReserveRatio(_ratio)
    {
        require(_token != token && !reserves[_token].isSet && totalReserveRatio + _ratio <= MAX_CRR); // validate input

        reserves[_token].virtualBalance = 0;
        reserves[_token].ratio = _ratio;
        reserves[_token].isVirtualBalanceEnabled = _enableVirtualBalance;
        reserves[_token].isPurchaseEnabled = true;
        reserves[_token].isSet = true;
        reserveTokens.push(_token);
        totalReserveRatio += _ratio;
    }

    /**
        @dev updates one of the token reserves
        can only be called by the owner

        @param _reserveToken           address of the reserve token
        @param _ratio                  constant reserve ratio, represented in ppm, 1-1000000
        @param _enableVirtualBalance   true to enable virtual balance for the reserve, false to disable it
        @param _virtualBalance         new reserve&#39;s virtual balance
    */
    function updateReserve(IERC20Token _reserveToken, uint32 _ratio, bool _enableVirtualBalance, uint256 _virtualBalance)
        public
        ownerOnly
        validReserve(_reserveToken)
        validReserveRatio(_ratio)
    {
        Reserve storage reserve = reserves[_reserveToken];
        require(totalReserveRatio - reserve.ratio + _ratio <= MAX_CRR); // validate input

        totalReserveRatio = totalReserveRatio - reserve.ratio + _ratio;
        reserve.ratio = _ratio;
        reserve.isVirtualBalanceEnabled = _enableVirtualBalance;
        reserve.virtualBalance = _virtualBalance;
    }

    /**
        @dev disables purchasing with the given reserve token in case the reserve token got compromised
        can only be called by the owner
        note that selling is still enabled regardless of this flag and it cannot be disabled by the owner

        @param _reserveToken    reserve token contract address
        @param _disable         true to disable the token, false to re-enable it
    */
    function disableReservePurchases(IERC20Token _reserveToken, bool _disable)
        public
        ownerOnly
        validReserve(_reserveToken)
    {
        reserves[_reserveToken].isPurchaseEnabled = !_disable;
    }

    /**
        @dev returns the reserve&#39;s virtual balance if one is defined, otherwise returns the actual balance

        @param _reserveToken    reserve token contract address

        @return reserve balance
    */
    function getReserveBalance(IERC20Token _reserveToken)
        public
        constant
        validReserve(_reserveToken)
        returns (uint256 balance)
    {
        Reserve storage reserve = reserves[_reserveToken];
        return reserve.isVirtualBalanceEnabled ? reserve.virtualBalance : _reserveToken.balanceOf(this);
    }

    /**
        @dev returns the expected return for changing a specific amount of _fromToken to _toToken

        @param _fromToken  ERC20 token to change from
        @param _toToken    ERC20 token to change to
        @param _amount     amount to change, in fromToken

        @return expected change return amount
    */
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public constant returns (uint256 amount) {
        require(_fromToken != _toToken); // validate input

        // change between the token and one of its reserves
        if (_toToken == token)
            return getPurchaseReturn(_fromToken, _amount);
        else if (_fromToken == token)
            return getSaleReturn(_toToken, _amount);

        // change between 2 reserves
        uint256 purchaseReturnAmount = getPurchaseReturn(_fromToken, _amount);
        return getSaleReturn(_toToken, purchaseReturnAmount, safeAdd(token.totalSupply(), purchaseReturnAmount));
    }

    /**
        @dev returns the expected return for buying the token for a reserve token

        @param _reserveToken   reserve token contract address
        @param _depositAmount  amount to deposit (in the reserve token)

        @return expected purchase return amount
    */
    function getPurchaseReturn(IERC20Token _reserveToken, uint256 _depositAmount)
        public
        constant
        active
        validReserve(_reserveToken)
        returns (uint256 amount)
    {
        Reserve storage reserve = reserves[_reserveToken];
        require(reserve.isPurchaseEnabled); // validate input

        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = getReserveBalance(_reserveToken);
        amount = formula.calculatePurchaseReturn(tokenSupply, reserveBalance, reserve.ratio, _depositAmount);

        // deduct the fee from the return amount
        uint256 feeAmount = getChangeFeeAmount(amount);
        return safeSub(amount, feeAmount);
    }

    /**
        @dev returns the expected return for selling the token for one of its reserve tokens

        @param _reserveToken   reserve token contract address
        @param _sellAmount     amount to sell (in the smart token)

        @return expected sale return amount
    */
    function getSaleReturn(IERC20Token _reserveToken, uint256 _sellAmount) public constant returns (uint256 amount) {
        return getSaleReturn(_reserveToken, _sellAmount, token.totalSupply());
    }

    /**
        @dev changes a specific amount of _fromToken to _toToken

        @param _fromToken  ERC20 token to change from
        @param _toToken    ERC20 token to change to
        @param _amount     amount to change, in fromToken
        @param _minReturn  if the change results in an amount smaller than the minimum return - it is cancelled, must be nonzero

        @return change return amount
    */
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256 amount) {
        require(_fromToken != _toToken); // validate input

        // change between the token and one of its reserves
        if (_toToken == token)
            return buy(_fromToken, _amount, _minReturn);
        else if (_fromToken == token)
            return sell(_toToken, _amount, _minReturn);

        // change between 2 reserves
        uint256 purchaseAmount = buy(_fromToken, _amount, 1);
        return sell(_toToken, purchaseAmount, _minReturn);
    }

    /**
        @dev buys the token by depositing one of its reserve tokens

        @param _reserveToken   reserve token contract address
        @param _depositAmount  amount to deposit (in the reserve token)
        @param _minReturn      if the change results in an amount smaller than the minimum return - it is cancelled, must be nonzero

        @return buy return amount
    */
    function buy(IERC20Token _reserveToken, uint256 _depositAmount, uint256 _minReturn)
        public
        changingAllowed
        greaterThanZero(_minReturn)
        returns (uint256 amount)
    {
        amount = getPurchaseReturn(_reserveToken, _depositAmount);
        assert(amount != 0 && amount >= _minReturn); // ensure the trade gives something in return and meets the minimum requested amount

        // update virtual balance if relevant
        Reserve storage reserve = reserves[_reserveToken];
        if (reserve.isVirtualBalanceEnabled)
            reserve.virtualBalance = safeAdd(reserve.virtualBalance, _depositAmount);

        assert(_reserveToken.transferFrom(msg.sender, this, _depositAmount)); // transfer _depositAmount funds from the caller in the reserve token
        token.issue(msg.sender, amount); // issue new funds to the caller in the smart token

        // calculate the new price using the simple price formula
        // price = reserve balance / (supply * CRR)
        // CRR is represented in ppm, so multiplying by 1000000
        uint256 reserveAmount = safeMul(getReserveBalance(_reserveToken), MAX_CRR);
        uint256 tokenAmount = safeMul(token.totalSupply(), reserve.ratio);
        Change(_reserveToken, token, msg.sender, _depositAmount, amount, reserveAmount, tokenAmount);
        return amount;
    }

    /**
        @dev sells the token by withdrawing from one of its reserve tokens

        @param _reserveToken   reserve token contract address
        @param _sellAmount     amount to sell (in the smart token)
        @param _minReturn      if the change results in an amount smaller the minimum return - it is cancelled, must be nonzero

        @return sell return amount
    */
    function sell(IERC20Token _reserveToken, uint256 _sellAmount, uint256 _minReturn)
        public
        changingAllowed
        greaterThanZero(_minReturn)
        returns (uint256 amount)
    {
        require(_sellAmount <= token.balanceOf(msg.sender)); // validate input

        amount = getSaleReturn(_reserveToken, _sellAmount);
        assert(amount != 0 && amount >= _minReturn); // ensure the trade gives something in return and meets the minimum requested amount

        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = getReserveBalance(_reserveToken);
        // ensure that the trade will only deplete the reserve if the total supply is depleted as well
        assert(amount < reserveBalance || (amount == reserveBalance && _sellAmount == tokenSupply));

        // update virtual balance if relevant
        Reserve storage reserve = reserves[_reserveToken];
        if (reserve.isVirtualBalanceEnabled)
            reserve.virtualBalance = safeSub(reserve.virtualBalance, amount);

        token.destroy(msg.sender, _sellAmount); // destroy _sellAmount from the caller&#39;s balance in the smart token
        assert(_reserveToken.transfer(msg.sender, amount)); // transfer funds to the caller in the reserve token
                                                            // note that it might fail if the actual reserve balance is smaller than the virtual balance
        // calculate the new price using the simple price formula
        // price = reserve balance / (supply * CRR)
        // CRR is represented in ppm, so multiplying by 1000000
        uint256 reserveAmount = safeMul(getReserveBalance(_reserveToken), MAX_CRR);
        uint256 tokenAmount = safeMul(token.totalSupply(), reserve.ratio);
        Change(token, _reserveToken, msg.sender, _sellAmount, amount, tokenAmount, reserveAmount);
        return amount;
    }

    /**
        @dev changes the token to any other token in the bancor network by following a predefined change path
        note that when changing from an ERC20 token (as opposed to a smart token), allowance must be set beforehand

        @param _path        change path, see change path format above
        @param _amount      amount to change from (in the initial source token)
        @param _minReturn   if the change results in an amount smaller than the minimum return - it is cancelled, must be nonzero

        @return tokens issued in return
    */
    function quickChange(IERC20Token[] _path, uint256 _amount, uint256 _minReturn)
        public
        validChangePath(_path)
        returns (uint256 amount)
    {
        // we need to transfer the tokens from the caller to the local contract before we
        // follow the change path, to allow it to execute the change on behalf of the caller
        IERC20Token fromToken = _path[0];
        claimTokens(fromToken, msg.sender, _amount);

        ISmartToken smartToken;
        IERC20Token toToken;
        BancorChanger changer;
        uint256 pathLength = _path.length;

        // iterate over the change path
        for (uint256 i = 1; i < pathLength; i += 2) {
            smartToken = ISmartToken(_path[i]);
            toToken = _path[i + 1];
            changer = BancorChanger(smartToken.owner());

            // if the smart token isn&#39;t the source (from token), the changer doesn&#39;t have control over it and thus we need to approve the request
            if (smartToken != fromToken)
                ensureAllowance(fromToken, changer, _amount);

            // make the change - if it&#39;s the last one, also provide the minimum return value
            _amount = changer.change(fromToken, toToken, _amount, i == pathLength - 2 ? _minReturn : 1);
            fromToken = toToken;
        }

        // finished the change, transfer the funds back to the caller
        // if the last change resulted in ether tokens, withdraw them and send them as ETH to the caller
        if (changer.hasQuickBuyEtherToken() && changer.getQuickBuyEtherToken() == toToken) {
            IEtherToken etherToken = IEtherToken(toToken);
            etherToken.withdrawTo(msg.sender, _amount);
        }
        else {
            // not ETH, transfer the tokens to the caller
            assert(toToken.transfer(msg.sender, _amount));
        }

        return _amount;
    }

    /**
        @dev buys the smart token with ETH if the return amount meets the minimum requested
        note that this function can eventually be moved into a separate contract

        @param _minReturn  if the change results in an amount smaller than the minimum return - it is cancelled, must be nonzero

        @return tokens issued in return
    */
    function quickBuy(uint256 _minReturn) public payable returns (uint256 amount) {
        // ensure that the quick buy path was set
        assert(quickBuyPath.length > 0);
        // we assume that the initial source in the quick buy path is always an ether token
        IEtherToken etherToken = IEtherToken(quickBuyPath[0]);
        // deposit ETH in the ether token
        etherToken.deposit.value(msg.value)();
        // get the initial changer in the path
        ISmartToken smartToken = ISmartToken(quickBuyPath[1]);
        BancorChanger changer = BancorChanger(smartToken.owner());
        // approve allowance for the changer in the ether token
        ensureAllowance(etherToken, changer, msg.value);
        // execute the change
        uint256 returnAmount = changer.quickChange(quickBuyPath, msg.value, _minReturn);
        // transfer the tokens to the caller
        assert(token.transfer(msg.sender, returnAmount));
        return returnAmount;
    }

    /**
        @dev utility, returns the expected return for selling the token for one of its reserve tokens, given a total supply override

        @param _reserveToken   reserve token contract address
        @param _sellAmount     amount to sell (in the smart token)
        @param _totalSupply    total token supply, overrides the actual token total supply when calculating the return

        @return sale return amount
    */
    function getSaleReturn(IERC20Token _reserveToken, uint256 _sellAmount, uint256 _totalSupply)
        private
        constant
        active
        validReserve(_reserveToken)
        greaterThanZero(_totalSupply)
        returns (uint256 amount)
    {
        Reserve storage reserve = reserves[_reserveToken];
        uint256 reserveBalance = getReserveBalance(_reserveToken);
        amount = formula.calculateSaleReturn(_totalSupply, reserveBalance, reserve.ratio, _sellAmount);

        // deduct the fee from the return amount
        uint256 feeAmount = getChangeFeeAmount(amount);
        return safeSub(amount, feeAmount);
    }

    /**
        @dev utility, checks whether allowance for the given spender exists and approves one if it doesn&#39;t

        @param _token   token to check the allowance in
        @param _spender approved address
        @param _value   allowance amount
    */
    function ensureAllowance(IERC20Token _token, address _spender, uint256 _value) private {
        // check if allowance for the given amount already exists
        if (_token.allowance(this, _spender) >= _value)
            return;

        // if the allowance is nonzero, must reset it to 0 first
        if (_token.allowance(this, _spender) != 0)
            assert(_token.approve(_spender, 0));

        // approve the new allowance
        assert(_token.approve(_spender, _value));
    }

    /**
        @dev utility, transfers tokens from an account to the local contract

        @param _token   token to claim
        @param _from    account to claim the tokens from
        @param _amount  amount to claim
    */
    function claimTokens(IERC20Token _token, address _from, uint256 _amount) private {
        // if the token is the smart token, no allowance is required - destroy the tokens from the caller and issue them to the local contract
        if (_token == token) {
            token.destroy(_from, _amount); // destroy _amount tokens from the caller&#39;s balance in the smart token
            token.issue(this, _amount); // issue _amount new tokens to the local contract
            return;
        }

        // otherwise, we assume we already have allowance
        assert(_token.transferFrom(_from, this, _amount));
    }

    /**
        @dev fallback, buys the smart token with ETH
        note that the purchase will use the price at the time of the purchase
    */
    function() payable {
        quickBuy(1);
    }
}





// This contract allows people to lend and borrow any ERC-20 tokens that follow
// the Bancor Protocol (i.e. are tradable on-chain).
// The lender provides the
// That way, even if the lended token increases in value suddenly, there is a
// safety margin for the lender to recover their loan in full.

contract BancorLender {
  // A struct that represents an agreement between two parties to borrow BNT.
  // Offers to borrow are represented in the same struct, as unfinished
  // agreements.
  // TODO: incorporate premiums for the lenders.
  struct BorrowAgreement {
    address lender;
    address borrower;
    uint256 tokenAmount;
    uint256 collateralAmount;
    uint32 collateralRatio;  // Extra collateral, in integer percent.
    uint expiration;
  }

  IERC20Token constant public bancorToken =
      IERC20Token(0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C);
  BancorChanger constant public bancorChanger =
      BancorChanger(0xb626A5FacC4de1c813F5293Ec3bE31979f1D1c78);
  IEtherToken etherToken = bancorChanger.getQuickBuyEtherToken();

  BorrowAgreement[] public agreements;

  function isCollateralWithinMargin(
      uint256 tokenAmount, uint256 collateralAmount,
      uint32 collateralRatio) public constant
  returns(bool) {
    uint256 collateralInTokens =
        bancorChanger.getPurchaseReturn(etherToken, collateralAmount);
    uint256 minCollateral = tokenAmount * (100 + collateralRatio) / 100;
    return (collateralInTokens > minCollateral);
  }

  function offerPosition(
      uint256 _token_amount, uint32 _collataral_ratio,
      uint _expiration) public {
    assert(bancorToken.transferFrom(msg.sender, this, _token_amount));
    agreements.push(BorrowAgreement(
        msg.sender, 0, _token_amount, 0, _collataral_ratio, _expiration));
  }

  function takePosition(uint _index) public payable {
    // Check that the offer is valid.
    assert(agreements[_index].tokenAmount > 0);
    // Check that the offer has not been taken yet.
    assert(agreements[_index].borrower == 0);
    // Check that the taker provided enough collateral.
    uint256 tokenAmount = agreements[_index].tokenAmount;
    uint256 collateralAmount =
        bancorChanger.getSaleReturn(etherToken, tokenAmount) + msg.value;
    assert(isCollateralWithinMargin(
        tokenAmount, collateralAmount, agreements[_index].collateralRatio));
    // Sell the tokens and add that balance to the collateral.
    uint256 saleAmount = bancorChanger.sell(etherToken, tokenAmount, 1);
    assert(saleAmount + msg.value == collateralAmount);
    etherToken.withdraw(saleAmount);
    agreements[_index].borrower = msg.sender;
    agreements[_index].collateralAmount = collateralAmount;
  }

  function addCollateral(uint _index) public payable {
    // Check that the offer is valid.
    assert(agreements[_index].tokenAmount > 0);
    // To avoid people losing money by accident, only the original borrower
    // can add collateral to their position.
    assert(msg.sender == agreements[_index].borrower);
    agreements[_index].collateralAmount += msg.value;
  }

  function closePosition(uint _index) public {
    // Check that the offer is valid.
    assert(agreements[_index].tokenAmount > 0);
    uint256 tokenAmount = agreements[_index].tokenAmount;
    // Canceling an offer that has not been taken.
    if (agreements[_index].borrower == 0) {
      assert(msg.sender == agreements[_index].lender);
      bancorToken.transfer(agreements[_index].lender, tokenAmount);
      agreements[_index].tokenAmount = 0;
      return;
    }
    // Margin-calling (can be done by anyone as a public service) or closing a
    // position that reached maturity.
    uint256 collateralAmount = agreements[_index].collateralAmount;
    bool canMarginCall = !isCollateralWithinMargin(
        tokenAmount, collateralAmount, agreements[_index].collateralRatio);
    if (canMarginCall || now > agreements[_index].expiration) {
      uint256 tokenRecoveredAmount =
          bancorChanger.quickBuy.value(collateralAmount)(1);
      if (tokenRecoveredAmount >= tokenAmount) {
        // Good: the debt is returned in full.
        // Should be the majority of cases since we provide a safety margin
        // and the BNT price is continuous.
        assert(bancorToken.transfer(agreements[_index].lender, tokenAmount));
        uint256 remainingCollateral = bancorChanger.sell(
            etherToken, tokenRecoveredAmount - tokenAmount, 1);
        etherToken.withdrawTo(agreements[_index].borrower, remainingCollateral);
      } else {
        // Bad: part of the debt is not returned.
        assert(bancorToken.transfer(
            agreements[_index].lender, tokenRecoveredAmount));
      }
      agreements[_index].tokenAmount = 0;
    }
  }
}