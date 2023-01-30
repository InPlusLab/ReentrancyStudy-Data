/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

pragma solidity ^0.5.16;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract LockIdGen {

    uint256 public requestCount;

    constructor() public {
        requestCount = 0;
    }

    function generateLockId() internal returns (bytes32 lockId) {
        return keccak256(abi.encodePacked(blockhash(block.number-1), address(this), ++requestCount));
    }
}
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(StandardToken token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(StandardToken token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(StandardToken token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(StandardToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(StandardToken token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ManagerUpgradeable is LockIdGen {

    struct ChangeRequest {
        address proposedNew;
        address proposedClear;
    }

    // address public custodian;
    mapping (address => address) public managers;

    mapping (bytes32 => ChangeRequest) public changeReqs;

    uint256     public    mancount  ;

    // CONSTRUCTOR
    constructor(
         address  [] memory _mans
    )
      LockIdGen()
      public
    {
        uint256 numMans = _mans.length;
        for (uint256 i = 0; i < numMans; i++) {
          address pto = _mans[i];
          require(pto != address(0));
          managers[pto] = pto;
        }
        mancount = numMans;
    }



    modifier onlyManager {
        require(msg.sender == managers[msg.sender],"onlyManger must use");
        _;
    }

    //replace managers
    function replaceManager(address _new,address _clear) public onlyManager {
        require( _clear != address(0) || _new != address(0) );

        require( _clear == address(0) || managers[_clear] == _clear);
        
        if(_new != address(0))
        {
            managers[_new] = _new;
            mancount = mancount + 1;
        }

        if(_clear != address(0) && managers[_clear] == _clear)
        {
            delete managers[_clear];
            mancount = mancount - 1;
        }

    }
    
    // for manager change
    function requestChange(address _new,address _clear) public onlyManager returns (bytes32 lockId) {
        require( _clear != address(0) || _new != address(0) );

        require( _clear == address(0) || managers[_clear] == _clear);

        lockId = generateLockId();

        changeReqs[lockId] = ChangeRequest({
            proposedNew: _new,
            proposedClear: _clear
        });

        emit ChangeRequested(lockId, msg.sender, _new,_clear);
    }

    event ChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _new,
        address _clear
    );

   function confirmChange(bytes32 _lockId) public onlyManager {
        ChangeRequest storage changeRequest = changeReqs[_lockId];
        require( changeRequest.proposedNew != address(0) || changeRequest.proposedClear != address(0));

        if(changeRequest.proposedNew != address(0))
        {
            managers[changeRequest.proposedNew] = changeRequest.proposedNew;
            mancount = mancount + 1;
        }

        if(changeRequest.proposedClear != address(0))
        {
            delete managers[changeRequest.proposedClear];
            mancount = mancount - 1;
        }

        delete changeReqs[_lockId];

        emit ChangeConfirmed(_lockId, changeRequest.proposedNew,changeRequest.proposedClear);
    }
    event ChangeConfirmed(bytes32 _lockId, address _newCustodian, address _clearCustodian);

    function sweepChange(bytes32 _lockId) public onlyManager {
        ChangeRequest storage changeRequest=changeReqs[_lockId];
        require((changeRequest.proposedNew != address(0) || changeRequest.proposedClear != address(0) ));
        delete changeReqs[_lockId];
        emit ChangeSweep(_lockId, msg.sender);
    }
    event ChangeSweep(bytes32 _lockId, address _sender);
    
    function sweeptoken(address tokenaddr,uint256 amount) public onlyManager{
        TransferHelper.safeTransfer(tokenaddr,msg.sender,amount);
    }
    function sweepeth(uint256 amount) public onlyManager{
        msg.sender.transfer(amount);
    }
}

contract ERC20Basic {
    // events
    event Transfer(address indexed from, address indexed to, uint256 value);

    // public functions
    function totalSupply() public view returns (uint256);
    function balanceOf(address addr) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
}

contract ERC20 is ERC20Basic {
    // events
    event Approval(address indexed owner, address indexed agent, uint256 value);

    // public functions
    function allowance(address owner, address agent) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address agent, uint256 value) public returns (bool);

}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  // public variables
  string public name;
  string public symbol;
  uint8 public decimals = 18;

  // internal variables
  uint256 _totalSupply;
  mapping(address => uint256) _balances;

  // events

  // public functions
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address addr) public view returns (uint256 balance) {
    return _balances[addr];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(to != address(0));
    require(value <= _balances[msg.sender]);

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  // internal functions

}



contract StandardToken is ERC20, BasicToken {
  // public variables

  // internal variables
  mapping (address => mapping (address => uint256)) _allowances;

  // events

  // public functions
  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(to != address(0));
    require(value <= _balances[from],"value lt from");
    require(value <= _allowances[from][msg.sender],"value lt _allowances from ");

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

  function approve(address agent, uint256 value) public returns (bool) {
    _allowances[msg.sender][agent] = value;
    emit Approval(msg.sender, agent, value);
    return true;
  }

  function allowance(address owner, address agent) public view returns (uint256) {
    return _allowances[owner][agent];
  }

  function increaseApproval(address agent, uint value) public returns (bool) {
    _allowances[msg.sender][agent] = _allowances[msg.sender][agent].add(value);
    emit Approval(msg.sender, agent, _allowances[msg.sender][agent]);
    return true;
  }

  function decreaseApproval(address agent, uint value) public returns (bool) {
    uint allowanceValue = _allowances[msg.sender][agent];
    if (value > allowanceValue) {
      _allowances[msg.sender][agent] = 0;
    } else {
      _allowances[msg.sender][agent] = allowanceValue.sub(value);
    }
    emit Approval(msg.sender, agent, _allowances[msg.sender][agent]);
    return true;
  }
  // internal functions
}



contract MinableToken is StandardToken,ManagerUpgradeable{
    
    
    uint256 maxMined =0;
    constructor(uint256 _maxMined,address [] memory _mans) public ManagerUpgradeable(_mans){
        maxMined = _maxMined;
    }
    
    function _mint(address to, uint256 value) public onlyManager  {
        require(maxMined==0||_totalSupply.add(value)<=maxMined,"_mint value invalid");
        _totalSupply = _totalSupply.add(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) public {
        _balances[from] = _balances[from].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }


}

contract DC is MinableToken {
  // public variables
  string public name = "Decentralized CNY Stablecoin";
  string public symbol = "DC";
  uint8 public decimals = 18;
  string  public constant version  = "1";


  // internal variables
 
  // events

  // public functions
  constructor(address [] memory _mans,uint256 _maxMined) public MinableToken(_maxMined,_mans) {

  }

  // internal functions
}



contract USDT is MinableToken {
  // public variables
  string public name = "Defiking.finance Version 2.0";
  string public symbol = "USDT";
  uint8 public decimals = 6;

  // internal variables
 
  // events

  // public functions
  constructor(address [] memory _mans,uint256 _maxMined) public MinableToken(_maxMined,_mans) {
    //init _totalSupply
    // _totalSupply = 1000*10000 * (10 ** uint256(decimals));
    
    // _balances[msg.sender] = _totalSupply;
    // emit Transfer(address(0x0), msg.sender, _totalSupply);
  }

  // internal functions
}


contract DBank is ManagerUpgradeable{
    using SafeMath for uint256;
    using SafeMath for uint8;
    using SafeERC20 for ERC20;
    
    int8 public status;//1:正常，0:暂停,3:其他

    uint256  public FIX_MUL = 100;
    uint256  public  buy_price = 650; //买入（抵押价格）
    uint256  public  sell_price = 655; //卖出价格（赎回）
    
    uint256  public  total_deposit_eu = 0; //总抵押eu数量

    uint256  public  total_withdraw_dc = 0; //总出售dc数量


    address   public dcToken;
    address   public euToken;

    uint256 public EU_decimals = 10 ** 6;
    uint256 public DC_decimals = 10 ** 18;

    mapping(address => uint256) public withdrawWhiteLists;//address->0：m没有限额，其他则有限额
    
    
    constructor(address _dcToken,address _euToken,uint256 _buy_price,uint256 _sell_price,address  [] memory _mans) public ManagerUpgradeable(_mans){
        require(_sell_price>_buy_price);
        status = 1;
        dcToken = _dcToken;
        euToken = _euToken; 
        buy_price = _buy_price;
        sell_price = _sell_price;
    }

    function setDCToken(address _dcToken) public onlyManager {
        dcToken = _dcToken;
    }
    
     function setStatus(int8 _status) public onlyManager {
        status = _status;
    }
    
    function setDCPrice(uint256 _buy_price,uint256 _sell_price) public onlyManager {
        require(_sell_price>_buy_price);
        buy_price = _buy_price;
        sell_price = _sell_price;
    }
    

    modifier onRunning {
        require(status == 1,"status not corrent");
        _;
    }

    function deposit(uint256 _amount) public onRunning payable returns (bool){
        require(_amount>0,"_amount must gt zero");

        // user must call prove first.
        
        //euToken.transferFrom(msg.sender,address(this),_amount);

        TransferHelper.safeTransferFrom(euToken,msg.sender,address(this),_amount);

        //
        uint256  dcAmount = _amount.mul(DC_decimals).mul(buy_price).div(FIX_MUL).div(EU_decimals);

        DC(dcToken)._mint(msg.sender,dcAmount);

        total_deposit_eu = total_deposit_eu.add(_amount);         
        
    }

    function withdraw(uint256 dcAmount) public onRunning payable returns (bool){
        require(dcAmount>0,"dcAmount must gt zero");

        require(DC(dcToken).balanceOf(msg.sender)>=dcAmount);
        
        uint256 euAmount = dcAmount.mul(EU_decimals).mul(FIX_MUL).div(sell_price).div(DC_decimals);
        
        require(ERC20(euToken).balanceOf(msg.sender)>=euAmount);
        
        TransferHelper.safeTransfer(euToken,msg.sender,euAmount); 
        
        DC(dcToken)._burn(msg.sender,dcAmount);

        total_withdraw_dc = total_withdraw_dc.add(dcAmount);        
    }



}


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    // function safeTransferETH(address to, uint value) internal {
    //     (bool success,bt) = to.call{value:value}(new bytes(0));
    //     require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    // }
}