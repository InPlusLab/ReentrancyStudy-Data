/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

pragma solidity >=0.4.24 <0.6.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract SetterRole {
    using Roles for Roles.Role;

    event SetterAdded(address indexed account);
    event SetterRemoved(address indexed account);

    Roles.Role private _setters;

    constructor () internal {
        _addSetter(msg.sender);
    }

    modifier onlySetter() {
        require(isSetter(msg.sender));
        _;
    }

    function isSetter(address account) public view returns (bool) {
        return _setters.has(account);
    }

    function addSetter(address account) public onlySetter {
        _addSetter(account);
    }

    function _addSetter(address account) internal {
        _setters.add(account);
        emit SetterAdded(account);
    }

    function removeSetter(address account) public onlySetter {
        _removeSetter(account);
    }

    function _removeSetter(address account) internal {
        _setters.remove(account);
        emit SetterRemoved(account);
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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract Erc20StdI {
    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract DBMintI {
    function mint(address _beneficiary, uint _txAmount, address _pairAddress) public;
}

contract BDErc20Pay is SetterRole {
    using SafeMath for uint;

    // ERC20 token for purchase
    Erc20StdI public erc20;
    // uniswap-v2 router contract
    IUniswapV2Router01 public swapRouter;
    // dividend contract address
    address payable public mintDivsAddr;

    //Order status
    enum STATUS{
        init, //init£º0£¬cannot cancel this value
        paid, //Order has been paid
        received, //Order has been received
        aborted, //Order has been aborted
        returning, //Order application return
        canceledReturn, //Order canceled for return refund
        refuseReturn, //Order rejected for return refund
        refunded//Order has been returned
    }//0,1,2...

    uint16 public constant  FEE_RATIO = 200;//2byte
    uint16 constant         THIS_DIVISOR = 10000;//2byte
    uint40 public constant  RETURN_PERIOD = 7 days;//5byte
    uint40 public constant  MAX_EXTENSION_PERIOD = 4 days;//5byte
    uint   public           lockedInOrders;

    //Order info
    struct Order {
        address seller;//uint160 20byte
        address buyer; //uint160 20byte
        uint8 status;//1byte
        uint40 endTime;//5byte
        uint sellerAmount;//32byte
        uint returnAmount;//32byte
    }//20+28(20+2+1+5)+32+32

    //All orders data
    mapping(uint => Order) public orders;

    event Purchase(uint indexed orderID, uint amount);
    event ConfirmReceived(uint indexed orderID);
    event Abort(uint indexed orderID, uint amount);
    event ApplyReturn(uint indexed orderID, uint amount);
    event CancelReturn(uint indexed orderID, uint amount);
    event RefuseReturn(uint indexed orderID);
    event ConfirmReturned(uint indexed orderID);
    event Withdraw(uint indexed orderID, address indexed beneficiary, uint amount);

    modifier validOrder(uint _orderID){
        require(orders[_orderID].buyer != address(0), "Order invalid.");
        _;
    }

    modifier validToken(){
        require(address(erc20) != address(0), "Invalid payment erc20 token.");
        _;
    }

    constructor(address _swapRouter, address _tokenAddr, address payable _mintDivsAddr) public{
        // Check address
        require(_swapRouter != address(0) && _tokenAddr != address(0) && _mintDivsAddr != address(0), "InitAddress is invalid address.");
        swapRouter = IUniswapV2Router01(_swapRouter);
        mintDivsAddr = _mintDivsAddr;
        erc20 = Erc20StdI(_tokenAddr);
    }

    function() external payable {

    }

    /**
     * @dev Volume Purchase
     **/
    function purchaseMulti(uint[] memory _orderIDs, address[] memory _sellers, uint[] memory _amounts) public validToken payable {
        require(_orderIDs.length > 0 && _sellers.length == _orderIDs.length && _amounts.length == _orderIDs.length, "Invalid purchase info.");
        uint _sumAmount;
        for (uint i = 0; i < _orderIDs.length; i++) {
            _sumAmount += _amounts[i];
            _purchase(_orderIDs[i], _sellers[i], msg.sender, _amounts[i], false);
        }
        //token purchase
        if (msg.value == 0) {
            require(erc20.transferFrom(msg.sender, address(this), _sumAmount), "TRC20 should approve at first.");
        }
        //ether purchase
        else {
            _ethToToken(msg.value, _sumAmount, msg.sender);
        }
    }

    function purchase(uint _orderID, address _seller, uint _amount) public validToken payable {
        if (msg.value == 0) {
            _purchase(_orderID, _seller, msg.sender, _amount, true);
        } else {
            _purchase(_orderID, _seller, msg.sender, _amount, false);
            _ethToToken(msg.value, _amount, msg.sender);
        }
    }

    function _purchase(uint _orderID, address _seller, address _buyer, uint _amount, bool needTransfer) internal {
        //Check Order
        Order storage order = orders[_orderID];

        require(_orderID > 0, "Invalid orderID.");
        require(order.buyer == address(0), "Order should be in 'clean' state.");
        require(_buyer != _seller, "Seller and buyer cannot be the same address.");
        require(_buyer != address(0), "Buyer is invalid address.");
        require(_seller != address(0), "Seller is invalid address.");

        //transfer from sender
        if (needTransfer) {
            require(erc20.transferFrom(_buyer, address(this), _amount), "TRC20 should approve at first.");
        }

        order.seller = _seller;
        order.buyer = _buyer;
        order.status = uint8(STATUS.paid);
        order.sellerAmount = _amount;
        lockedInOrders += _amount;

        emit Purchase(_orderID, _amount);
    }

    function _ethToToken(uint _ethPay, uint _tokenOut, address payable _buyer) internal {
        address WETH = swapRouter.WETH();
        uint _ethIn = getEthBoughtPrice(_tokenOut);
        require(_ethPay >= _ethIn, "Insufficient ether payment.");
        address[] memory _path = new address[](2);
        _path[0] = WETH;
        _path[1] = address(erc20);
        swapRouter.swapETHForExactTokens.value(_ethIn)(_tokenOut, _path, address(this), block.timestamp + (10 minutes));
        if (_ethPay - _ethIn > 0) {
            _buyer.transfer(_ethPay - _ethIn);
        }
    }

    function getEthBoughtPrice(uint _amountOut) public view returns (uint amount){
        address[] memory _path = new address[](2);
        _path[0] = swapRouter.WETH();
        _path[1] = address(erc20);

        amount = swapRouter.getAmountsIn(_amountOut, _path)[0];
    }

    function getTokenBoughtPrice(uint _amountOut) public view returns (uint amount){
        address[] memory _path = new address[](2);
        _path[0] = address(erc20);
        _path[1] = swapRouter.WETH();

        amount = swapRouter.getAmountsIn(_amountOut, _path)[0];
    }

    /**
     * @dev confirm received
     **/
    function confirmReceived(uint _orderID) public {
        Order storage order = orders[_orderID];
        // Permission check
        require(msg.sender == order.buyer || isSetter(msg.sender), "Permission limit.");
        // Status check
        require(order.status == uint8(STATUS.paid), "Status is not allowed.");

        // Modify data
        order.status = uint8(STATUS.received);
        order.endTime = uint40(block.timestamp + RETURN_PERIOD);

        emit ConfirmReceived(_orderID);
    }

    /**
     * @dev abort the order
     **/
    function abort(uint _orderID, bool _isToken) public {
        Order storage order = orders[_orderID];
        uint _sellerAmount = order.sellerAmount;
        // Permission check
        require(msg.sender == order.seller || isSetter(msg.sender), "Permission limit.");
        // Status check
        require(order.status == uint8(STATUS.paid), "Status error.");

        // Modify status
        order.returnAmount = _sellerAmount;
        order.sellerAmount = 0;
        order.status = uint8(STATUS.aborted);

        emit Abort(_orderID, _sellerAmount);

        // transfer to buyer
        if (_sellerAmount > 0) _withdraw(_orderID, _isToken, address(uint160(order.buyer)));
    }

    /**
     * @dev Apply order return
     **/
    function applyReturn(uint _orderID, uint _returnAmount) public {
        Order storage order = orders[_orderID];
        uint _sellerAmount = order.sellerAmount;
        // Permission check
        require(msg.sender == order.buyer, "Permission limit.");
        // Status check
        require(order.status == uint8(STATUS.received) || order.status == uint8(STATUS.canceledReturn), "Status is not allowed.");
        // Time check
        require(block.timestamp < order.endTime, "Has timed out.");
        // Amount check
        require(_returnAmount <= _sellerAmount, "Invalid refund amount.");

        //Add extension period
        if (order.status == uint8(STATUS.received) && order.endTime - block.timestamp < MAX_EXTENSION_PERIOD) {
            order.endTime = uint40(block.timestamp + MAX_EXTENSION_PERIOD);
        }

        // Modify data
        order.status = uint8(STATUS.returning);
        order.returnAmount = _returnAmount;
        order.sellerAmount = _sellerAmount - _returnAmount;

        emit ApplyReturn(_orderID, _returnAmount);
    }

    /**
     * @dev cancel order return
     **/
    function cancelReturn(uint _orderID) public {
        Order storage order = orders[_orderID];
        uint _returnAmount = order.returnAmount;
        // Permission check
        require(msg.sender == order.buyer, "Permission limit.");
        // Status check
        require(order.status == uint8(STATUS.returning), "Status is not allowed.");

        // Modify data
        order.status = uint8(STATUS.canceledReturn);
        order.sellerAmount += _returnAmount;
        order.returnAmount = 0;

        emit CancelReturn(_orderID, _returnAmount);
    }

    /**
     * @dev refuse return
     **/
    function refuseReturn(uint _orderID) public {
        Order storage order = orders[_orderID];
        // Permission check
        require(isSetter(msg.sender), "Permission limit.");
        // Status check
        require(order.status == uint8(STATUS.returning), "Operation is not allowed.");

        // Modify status
        order.status = uint8(STATUS.refuseReturn);
        order.sellerAmount += order.returnAmount;
        order.returnAmount = 0;

        emit RefuseReturn(_orderID);
    }

    /**
     * @dev confirm returned
     **/
    function confirmReturned(uint _orderID, bool _isToken, uint _returnAmount) public {
        Order storage order = orders[_orderID];
        // Permission check
        require(order.seller == msg.sender || isSetter(msg.sender), "Permission limit.");
        // Status check
        require(order.status == uint8(STATUS.returning), "Operation is not allowed.");
        // Amount check
        require(order.returnAmount == _returnAmount, "Return amount is error.");

        // Modify status
        order.status = uint8(STATUS.refunded);

        emit ConfirmReturned(_orderID);

        // transfer to buyer
        if (order.returnAmount > 0) _withdraw(_orderID, _isToken, address(uint160(order.buyer)));
    }

    /**
     * @dev seller volume withdraw
     **/
    function withdrawMulti(uint[] memory _orderIDs, bool[] memory _isTokens) public {
        require(_orderIDs.length > 0 && _isTokens.length == _orderIDs.length, "Invalid orders info.");
        for (uint i = 0; i < _orderIDs.length; i++) {
            _withdraw(_orderIDs[i], _isTokens[i], msg.sender);
        }
    }

    /**
     * @dev seller withdraw token/ether
     **/
    function withdraw(uint _orderID, bool _isToken) public {
        _withdraw(_orderID, _isToken, msg.sender);
    }

    /**
     * @dev buyer,seller withdraw token/ether
     **/
    function _withdraw(uint _orderID, bool _isToken, address payable sender) internal {
        Order storage order = orders[_orderID];
        uint _returnAmount = order.returnAmount;
        uint _sellerAmount = order.sellerAmount;
        uint8 _status = order.status;

        address WETH = swapRouter.WETH();
        address[] memory _path = new address[](2);
        _path[0] = address(erc20);
        _path[1] = WETH;

        // for seller
        if (order.seller == sender && _sellerAmount > 0 && (
        //normal received
        ((_status == uint8(STATUS.received) || _status == uint8(STATUS.canceledReturn)) && uint40(block.timestamp) > order.endTime)
        //rejected return
        || (_status == uint8(STATUS.refuseReturn))
        //part of return
        || (_status == uint8(STATUS.refunded))
        )) {
            uint _revenue = _sellerAmount * FEE_RATIO / THIS_DIVISOR;
            uint _txAmount = _sellerAmount.sub(_revenue);
            // Modify status
            order.sellerAmount = 0;
            lockedInOrders -= _sellerAmount;

            if (_isToken) {
                // transfer token
                require(erc20.transfer(sender, _txAmount), "Transfer erc20 failed.");
                // swap token to ether and transfer revenue to divsAddr
                if (_revenue > 0) {
                    //approve transfer
                    erc20.approve(address(swapRouter), _revenue);
                    swapRouter.swapExactTokensForETH(_revenue, 1, _path, mintDivsAddr, block.timestamp + (10 minutes));
                }
            } else {
                uint _ethBought;
                //swap token to ether
                if (_sellerAmount > 0) {
                    //approve transfer
                    erc20.approve(address(swapRouter), _sellerAmount);
                    _ethBought = swapRouter.swapExactTokensForETH(_sellerAmount, 1, _path, address(this), block.timestamp + (10 minutes))[1];
                }
                _revenue = _ethBought * FEE_RATIO / THIS_DIVISOR;
                //transfer ether
                sender.transfer(_ethBought.sub(_revenue));
                //transfer revenue to divsAddr
                mintDivsAddr.transfer(_revenue);
            }
            // mining
            DBMintI(mintDivsAddr).mint(order.buyer, _sellerAmount, IUniswapV2Factory(swapRouter.factory()).getPair(address(erc20), swapRouter.WETH()));

            emit Withdraw(_orderID, sender, _txAmount);
            return;
        }
        // for buyer
        if (order.buyer == sender && _returnAmount > 0 && (
        // refunded
        (_status == uint8(STATUS.refunded)
        // aborted
        || (_status == uint8(STATUS.aborted))
        // part of aborted and received
        || (_status == uint8(STATUS.received))))) {
            // Modify status
            order.returnAmount = 0;
            lockedInOrders -= _returnAmount;
            if (_isToken) {
                // transfer token
                require(erc20.transfer(sender, _returnAmount), "Transfer erc20 failed.");
            } else {
                //approve transfer
                erc20.approve(address(swapRouter), _returnAmount);
                //transfer ether
                swapRouter.swapExactTokensForETH(_returnAmount, 1, _path, sender, block.timestamp + (10 minutes));
            }
            emit Withdraw(_orderID, sender, _returnAmount);
            return;
        }
        revert("Something bad happened");
    }

    /**
     * @dev reset token contract address.
     */
    function resetTokenAddr(address _tokenAddr) public onlySetter returns (bool isSuccess){
        require(_tokenAddr != address(0), "_tokenAddr is invalid.");
        erc20 = Erc20StdI(_tokenAddr);
        return true;
    }

    /**
     * @dev reset uniswap-v2 router contract address.
     */
    function resetSwapRouter(address _swapRouter) public onlySetter returns (bool isSuccess){
        require(_swapRouter != address(0), "_swapRouter is invalid.");
        swapRouter = IUniswapV2Router01(_swapRouter);
        return true;
    }

    /**
     * @dev kill this contract while upgraded.
     */
    function kill() public onlySetter {
        require(lockedInOrders == 0, "All order balances need to be withdrawn.");
        uint balance = erc20.balanceOf(address(this));
        if (balance > 0) {
            require(erc20.transfer(msg.sender, balance), "Transfer erc20 failed.");
        }
        selfdestruct(msg.sender);
    }
}