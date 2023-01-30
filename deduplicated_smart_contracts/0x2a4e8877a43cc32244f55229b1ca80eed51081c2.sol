/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

// Sources flattened with buidler v1.2.0 https://buidler.dev

// File @pie-dao/proxy/contracts/PProxyStorage.sol@v0.0.6

pragma solidity ^0.6.2;

contract PProxyStorage {

    function readString(bytes32 _key) public view returns(string memory) {
        return bytes32ToString(storageRead(_key));
    }

    function setString(bytes32 _key, string memory _value) internal {
        storageSet(_key, stringToBytes32(_value));
    }

    function readBool(bytes32 _key) public view returns(bool) {
        return storageRead(_key) == bytes32(uint256(1));
    }

    function setBool(bytes32 _key, bool _value) internal {
        if(_value) {
            storageSet(_key, bytes32(uint256(1)));
        } else {
            storageSet(_key, bytes32(uint256(0)));
        }
    }

    function readAddress(bytes32 _key) public view returns(address) {
        return bytes32ToAddress(storageRead(_key));
    }

    function setAddress(bytes32 _key, address _value) internal {
        storageSet(_key, addressToBytes32(_value));
    }

    function storageRead(bytes32 _key) public view returns(bytes32) {
        bytes32 value;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            value := sload(_key)
        }
        return value;
    }

    function storageSet(bytes32 _key, bytes32 _value) internal {
        // targetAddress = _address;  // No!
        bytes32 implAddressStorageKey = _key;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(implAddressStorageKey, _value)
        }
    }

    function bytes32ToAddress(bytes32 _value) public pure returns(address) {
        return address(uint160(uint256(_value)));
    }

    function addressToBytes32(address _value) public pure returns(bytes32) {
        return bytes32(uint256(_value));
    }

    function stringToBytes32(string memory _value) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(_value);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(_value, 32))
        }
    }

    function bytes32ToString(bytes32 _value) public pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint256 j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_value) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}


// File @pie-dao/proxy/contracts/PProxy.sol@v0.0.6

pragma solidity ^0.6.2;


contract PProxy is PProxyStorage {

    bytes32 constant IMPLEMENTATION_SLOT = keccak256(abi.encodePacked("IMPLEMENTATION_SLOT"));
    bytes32 constant OWNER_SLOT = keccak256(abi.encodePacked("OWNER_SLOT"));

    modifier onlyProxyOwner() {
        require(msg.sender == readAddress(OWNER_SLOT), "PProxy.onlyProxyOwner: msg sender not owner");
        _;
    }

    constructor () public {
        setAddress(OWNER_SLOT, msg.sender);
    }

    function getProxyOwner() public view returns (address) {
       return readAddress(OWNER_SLOT);
    }

    function setProxyOwner(address _newOwner) onlyProxyOwner public {
        setAddress(OWNER_SLOT, _newOwner);
    }

    function getImplementation() public view returns (address) {
        return readAddress(IMPLEMENTATION_SLOT);
    }

    function setImplementation(address _newImplementation) onlyProxyOwner public {
        setAddress(IMPLEMENTATION_SLOT, _newImplementation);
    }


    fallback () external payable {
       return internalFallback();
    }

    function internalFallback() internal virtual {
        address contractAddr = readAddress(IMPLEMENTATION_SLOT);
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), contractAddr, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

}


// File @pie-dao/proxy/contracts/PProxyPausable.sol@v0.0.6

pragma solidity ^0.6.2;


contract PProxyPausable is PProxy {

    bytes32 constant PAUSED_SLOT = keccak256(abi.encodePacked("PAUSED_SLOT"));
    bytes32 constant PAUZER_SLOT = keccak256(abi.encodePacked("PAUZER_SLOT"));

    constructor() PProxy() public {
        setAddress(PAUZER_SLOT, msg.sender);
    }

    modifier onlyPauzer() {
        require(msg.sender == readAddress(PAUZER_SLOT), "PProxyPausable.onlyPauzer: msg sender not pauzer");
        _;
    }

    modifier notPaused() {
        require(!readBool(PAUSED_SLOT), "PProxyPausable.notPaused: contract is paused");
        _;
    }

    function getPauzer() public view returns (address) {
        return readAddress(PAUZER_SLOT);
    }

    function setPauzer(address _newPauzer) public onlyProxyOwner{
        setAddress(PAUZER_SLOT, _newPauzer);
    }

    function renouncePauzer() public onlyPauzer {
        setAddress(PAUZER_SLOT, address(0));
    }

    function getPaused() public view returns (bool) {
        return readBool(PAUSED_SLOT);
    }

    function setPaused(bool _value) public onlyPauzer {
        setBool(PAUSED_SLOT, _value);
    }

    function internalFallback() internal virtual override notPaused {
        super.internalFallback();
    }

}


// File contracts/interfaces/IBFactory.sol

pragma solidity ^0.6.4;


interface IBFactory {
  function newBPool() external returns (address);
}


// File contracts/interfaces/IBPool.sol

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is disstributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.6.4;


interface IBPool {
  function isBound(address token) external view returns (bool);

  function getBalance(address token) external view returns (uint256);

  function rebind(
    address token,
    uint256 balance,
    uint256 denorm
  ) external;

  function setSwapFee(uint256 swapFee) external;

  function setPublicSwap(bool _public) external;

  function bind(
    address token,
    uint256 balance,
    uint256 denorm
  ) external;

  function unbind(address token) external;

  function getDenormalizedWeight(address token) external view returns (uint256);

  function getTotalDenormalizedWeight() external view returns (uint256);

  function getCurrentTokens() external view returns (address[] memory);

  function setController(address manager) external;

  function isPublicSwap() external view returns (bool);

  function getSwapFee() external view returns (uint256);

  function gulp(address token) external;

  function calcPoolOutGivenSingleIn(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 tokenAmountIn,
    uint256 swapFee
  ) external pure returns (uint256 poolAmountOut);

  function calcSingleInGivenPoolOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 poolAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountIn);

  function calcSingleOutGivenPoolIn(
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 poolAmountIn,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountOut);

  function calcPoolInGivenSingleOut(
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 tokenAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 poolAmountIn);
}


// File contracts/interfaces/IERC20.sol

pragma solidity ^0.6.4;


interface IERC20 {
  event Approval(address indexed _src, address indexed _dst, uint256 _amount);
  event Transfer(address indexed _src, address indexed _dst, uint256 _amount);

  function totalSupply() external view returns (uint256);

  function balanceOf(address _whom) external view returns (uint256);

  function allowance(address _src, address _dst) external view returns (uint256);

  function approve(address _dst, uint256 _amount) external returns (bool);

  function transfer(address _dst, uint256 _amount) external returns (bool);

  function transferFrom(
    address _src,
    address _dst,
    uint256 _amount
  ) external returns (bool);
}


// File contracts/Ownable.sol

pragma solidity 0.6.4;


// TODO move this generic contract to a seperate repo with all generic smart contracts

contract Ownable {
  bytes32 public constant oSlot = keccak256("Ownable.storage.location");

  event OwnerChanged(address indexed previousOwner, address indexed newOwner);

  // Ownable struct
  struct os {
    address owner;
  }

  modifier onlyOwner() {
    require(msg.sender == los().owner, "Ownable.onlyOwner: msg.sender not owner");
    _;
  }

  /**
        @notice Transfer ownership to a new address
        @param _newOwner Address of the new owner
    */
  function transferOwnership(address _newOwner) external onlyOwner {
    _setOwner(_newOwner);
  }

  /**
        @notice Internal method to set the owner
        @param _newOwner Address of the new owner
    */
  function _setOwner(address _newOwner) internal {
    emit OwnerChanged(los().owner, _newOwner);
    los().owner = _newOwner;
  }

  /**
        @notice Load ownable storage
        @return s Storage pointer to the Ownable storage struct
    */
  function los() internal pure returns (os storage s) {
    bytes32 loc = oSlot;
    assembly {
      s_slot := loc
    }
  }
}


// File contracts/interfaces/IPSmartPool.sol

pragma solidity ^0.6.4;



interface IPSmartPool is IERC20 {
  // function joinPool(uint256 _amount) external;

  // function exitPool(uint256 _amount) external;

  function getController() external view returns (address);

  function getTokens() external view returns (address[] memory);

  function calcTokensForAmount(uint256 _amount)
    external
    view
    returns (address[] memory tokens, uint256[] memory amounts);
}


// File contracts/PCTokenStorage.sol

pragma solidity 0.6.4;


contract PCTokenStorage {
  bytes32 public constant ptSlot = keccak256("PCToken.storage.location");
  struct pts {
    string name;
    string symbol;
    uint256 totalSupply;
    mapping(address => uint256) balance;
    mapping(address => mapping(address => uint256)) allowance;
  }

  /**
        @notice Load pool token storage
        @return s Storage pointer to the pool token struct
    */
  function lpts() internal pure returns (pts storage s) {
    bytes32 loc = ptSlot;
    assembly {
      s_slot := loc
    }
  }
}


// File contracts/Math.sol

library Math {
  uint256 internal constant BONE = 10**18;

  // Add two numbers together checking for overflows
  function badd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "ERR_ADD_OVERFLOW");
    return c;
  }

  // subtract two numbers and return diffecerence when it underflows
  function bsubSign(uint256 a, uint256 b) internal pure returns (uint256, bool) {
    if (a >= b) {
      return (a - b, false);
    } else {
      return (b - a, true);
    }
  }

  // Subtract two numbers checking for underflows
  function bsub(uint256 a, uint256 b) internal pure returns (uint256) {
    (uint256 c, bool flag) = bsubSign(a, b);
    require(!flag, "ERR_SUB_UNDERFLOW");
    return c;
  }

  // Multiply two 18 decimals numbers
  function bmul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c0 = a * b;
    require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
    uint256 c1 = c0 + (BONE / 2);
    require(c1 >= c0, "ERR_MUL_OVERFLOW");
    uint256 c2 = c1 / BONE;
    return c2;
  }

  // Divide two 18 decimals numbers
  function bdiv(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "ERR_DIV_ZERO");
    uint256 c0 = a * BONE;
    require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL"); // bmul overflow
    uint256 c1 = c0 + (b / 2);
    require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require
    uint256 c2 = c1 / b;
    return c2;
  }
}


// File contracts/PCToken.sol

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.6.4;





// Highly opinionated token implementation
// Based on the balancer Implementation

contract PCToken is IERC20, PCTokenStorage {
  using Math for uint256;

  event Approval(address indexed _src, address indexed _dst, uint256 _amount);
  event Transfer(address indexed _src, address indexed _dst, uint256 _amount);

  uint8 public constant decimals = 18;

  function _mint(uint256 _amount) internal {
    pts storage s = lpts();
    s.balance[address(this)] = s.balance[address(this)].badd(_amount);
    s.totalSupply = s.totalSupply.badd(_amount);
    emit Transfer(address(0), address(this), _amount);
  }

  function _burn(uint256 _amount) internal {
    pts storage s = lpts();
    require(s.balance[address(this)] >= _amount, "ERR_INSUFFICIENT_BAL");
    s.balance[address(this)] = s.balance[address(this)].bsub(_amount);
    s.totalSupply = s.totalSupply.bsub(_amount);
    emit Transfer(address(this), address(0), _amount);
  }

  function _move(
    address _src,
    address _dst,
    uint256 _amount
  ) internal {
    pts storage s = lpts();
    require(s.balance[_src] >= _amount, "ERR_INSUFFICIENT_BAL");
    s.balance[_src] = s.balance[_src].bsub(_amount);
    s.balance[_dst] = s.balance[_dst].badd(_amount);
    emit Transfer(_src, _dst, _amount);
  }

  function _push(address _to, uint256 _amount) internal {
    _move(address(this), _to, _amount);
  }

  function _pull(address _from, uint256 _amount) internal {
    _move(_from, address(this), _amount);
  }

  function allowance(address _src, address _dst) external override view returns (uint256) {
    return lpts().allowance[_src][_dst];
  }

  function balanceOf(address _whom) external override view returns (uint256) {
    return lpts().balance[_whom];
  }

  function totalSupply() public override view returns (uint256) {
    return lpts().totalSupply;
  }

  function name() external view returns (string memory) {
    return lpts().name;
  }

  function symbol() external view returns (string memory) {
    return lpts().symbol;
  }

  function approve(address _dst, uint256 _amount) external override returns (bool) {
    lpts().allowance[msg.sender][_dst] = _amount;
    emit Approval(msg.sender, _dst, _amount);
    return true;
  }

  function increaseApproval(address _dst, uint256 _amount) external returns (bool) {
    pts storage s = lpts();
    s.allowance[msg.sender][_dst] = s.allowance[msg.sender][_dst].badd(_amount);
    emit Approval(msg.sender, _dst, s.allowance[msg.sender][_dst]);
    return true;
  }

  function decreaseApproval(address _dst, uint256 _amount) external returns (bool) {
    pts storage s = lpts();
    uint256 oldValue = s.allowance[msg.sender][_dst];
    if (_amount > oldValue) {
      s.allowance[msg.sender][_dst] = 0;
    } else {
      s.allowance[msg.sender][_dst] = oldValue.bsub(_amount);
    }
    emit Approval(msg.sender, _dst, s.allowance[msg.sender][_dst]);
    return true;
  }

  function transfer(address _dst, uint256 _amount) external override returns (bool) {
    _move(msg.sender, _dst, _amount);
    return true;
  }

  function transferFrom(
    address _src,
    address _dst,
    uint256 _amount
  ) external override returns (bool) {
    pts storage s = lpts();
    require(
      msg.sender == _src || _amount <= s.allowance[_src][msg.sender],
      "ERR_PCTOKEN_BAD_CALLER"
    );
    _move(_src, _dst, _amount);
    if (msg.sender != _src && s.allowance[_src][msg.sender] != uint256(-1)) {
      s.allowance[_src][msg.sender] = s.allowance[_src][msg.sender].bsub(_amount);
      emit Approval(msg.sender, _dst, s.allowance[_src][msg.sender]);
    }
    return true;
  }
}


// File contracts/ReentryProtection.sol

pragma solidity 0.6.4;


// TODO move this generic contract to a seperate repo with all generic smart contracts

contract ReentryProtection {
  bytes32 public constant rpSlot = keccak256("ReentryProtection.storage.location");

  // reentry protection storage
  struct rps {
    uint256 lockCounter;
  }

  modifier noReentry {
    // Use counter to only write to storage once
    lrps().lockCounter++;
    uint256 lockValue = lrps().lockCounter;
    _;
    require(lockValue == lrps().lockCounter, "ReentryProtection.noReentry: reentry detected");
  }

  /**
        @notice Load reentry protection storage
        @return s Pointer to the reentry protection storage struct
    */
  function lrps() internal pure returns (rps storage s) {
    bytes32 loc = rpSlot;
    assembly {
      s_slot := loc
    }
  }
}


// File contracts/smart-pools/PBasicSmartPool.sol

pragma solidity 0.6.4;






contract PBasicSmartPool is IPSmartPool, PCToken, ReentryProtection {
  // P Basic Smart Struct
  bytes32 public constant pbsSlot = keccak256("PBasicSmartPool.storage.location");
  struct pbs {
    IBPool bPool;
    address controller;
    address publicSwapSetter;
    address tokenBinder;
  }

  modifier ready() {
    require(address(lpbs().bPool) != address(0), "PBasicSmartPool.ready: not ready");
    _;
  }

  event LOG_JOIN(address indexed caller, address indexed tokenIn, uint256 tokenAmountIn);

  event LOG_EXIT(address indexed caller, address indexed tokenOut, uint256 tokenAmountOut);

  event TokensApproved();
  event ControllerChanged(address indexed previousController, address indexed newController);
  event PublicSwapSetterChanged(address indexed previousSetter, address indexed newSetter);
  event TokenBinderChanged(address indexed previousTokenBinder, address indexed newTokenBinder);
  event PublicSwapSet(address indexed setter, bool indexed value);
  event SwapFeeSet(address indexed setter, uint256 newFee);
  event PoolJoined(address indexed from, uint256 amount);
  event PoolExited(address indexed from, uint256 amount);
  event PoolExitedWithLoss(address indexed from, uint256 amount, address[] lossTokens);

  modifier onlyController() {
    require(msg.sender == lpbs().controller, "PBasicSmartPool.onlyController: not controller");
    _;
  }

  modifier onlyPublicSwapSetter() {
    require(
      msg.sender == lpbs().publicSwapSetter,
      "PBasicSmartPool.onlyPublicSwapSetter: not public swap setter"
    );
    _;
  }

  modifier onlyTokenBinder() {
    require(msg.sender == lpbs().tokenBinder, "PBasicSmartPool.onlyTokenBinder: not token binder");
    _;
  }

  /**
        @notice Initialises the contract
        @param _bPool Address of the underlying balancer pool
        @param _name Name for the smart pool token
        @param _symbol Symbol for the smart pool token
        @param _initialSupply Initial token supply to mint
    */
  function init(
    address _bPool,
    string calldata _name,
    string calldata _symbol,
    uint256 _initialSupply
  ) external {
    pbs storage s = lpbs();
    require(address(s.bPool) == address(0), "PBasicSmartPool.init: already initialised");
    require(_bPool != address(0), "PBasicSmartPool.init: _bPool cannot be 0x00....000");
    require(_initialSupply != 0, "PBasicSmartPool.init: _initialSupply can not zero");
    s.bPool = IBPool(_bPool);
    s.controller = msg.sender;
    s.publicSwapSetter = msg.sender;
    s.tokenBinder = msg.sender;
    lpts().name = _name;
    lpts().symbol = _symbol;
    _mintPoolShare(_initialSupply);
    _pushPoolShare(msg.sender, _initialSupply);
  }

  /**
        @notice Sets approval to all tokens to the underlying balancer pool
        @dev It uses this function to save on gas in joinPool
    */
  function approveTokens() public noReentry {
    IBPool bPool = lpbs().bPool;
    address[] memory tokens = bPool.getCurrentTokens();
    for (uint256 i = 0; i < tokens.length; i++) {
      IERC20(tokens[i]).approve(address(bPool), uint256(-1));
    }
    emit TokensApproved();
  }

  /**
        @notice Sets the controller address. Can only be set by the current controller
        @param _controller Address of the new controller
    */
  function setController(address _controller) external onlyController noReentry {
    emit ControllerChanged(lpbs().controller, _controller);
    lpbs().controller = _controller;
  }

  /**
        @notice Sets public swap setter address. Can only be set by the controller
        @param _newPublicSwapSetter Address of the new public swap setter
    */
  function setPublicSwapSetter(address _newPublicSwapSetter) external onlyController noReentry {
    emit PublicSwapSetterChanged(lpbs().publicSwapSetter, _newPublicSwapSetter);
    lpbs().publicSwapSetter = _newPublicSwapSetter;
  }

  /**
        @notice Sets the token binder address. Can only be set by the controller
        @param _newTokenBinder Address of the new token binder
    */
  function setTokenBinder(address _newTokenBinder) external onlyController noReentry {
    emit TokenBinderChanged(lpbs().tokenBinder, _newTokenBinder);
    lpbs().tokenBinder = _newTokenBinder;
  }

  /**
        @notice Enables or disables public swapping on the underlying balancer pool.
                Can only be set by the controller.
        @param _public Public or not
    */
  function setPublicSwap(bool _public) external onlyPublicSwapSetter noReentry {
    emit PublicSwapSet(msg.sender, _public);
    lpbs().bPool.setPublicSwap(_public);
  }

  /**
        @notice Set the swap fee on the underlying balancer pool.
                Can only be called by the controller.
        @param _swapFee The new swap fee
    */
  function setSwapFee(uint256 _swapFee) external onlyController noReentry {
    emit SwapFeeSet(msg.sender, _swapFee);
    lpbs().bPool.setSwapFee(_swapFee);
  }
 
  function bind(
    address _token,
    uint256 _balance,
    uint256 _denorm
  ) external onlyTokenBinder noReentry {
    IBPool bPool = lpbs().bPool;
    IERC20 token = IERC20(_token);
    require(
      token.transferFrom(msg.sender, address(this), _balance),
      "PBasicSmartPool.bind: transferFrom failed"
    );
    token.approve(address(bPool), uint256(-1));
    bPool.bind(_token, _balance, _denorm);
  }

  /**
        @notice Rebind a token to the pool
        @param _token Token to bind
        @param _balance Amount to bind
        @param _denorm Denormalised weight
    */
  function rebind(
    address _token,
    uint256 _balance,
    uint256 _denorm
  ) external onlyTokenBinder noReentry {
    IBPool bPool = lpbs().bPool;
    IERC20 token = IERC20(_token);

    // gulp old non acounted for token balance in the contract
    bPool.gulp(_token);

    uint256 oldBalance = token.balanceOf(address(bPool));
    // If tokens need to be pulled from msg.sender
    if (_balance > oldBalance) {
      require(
        token.transferFrom(msg.sender, address(this), _balance.bsub(oldBalance)),
        "PBasicSmartPool.rebind: transferFrom failed"
      );
      token.approve(address(bPool), uint256(-1));
    }

    bPool.rebind(_token, _balance, _denorm);

    // If any tokens are in this contract send them to msg.sender
    uint256 tokenBalance = token.balanceOf(address(this));
    if (tokenBalance > 0) {
      require(token.transfer(msg.sender, tokenBalance), "PBasicSmartPool.rebind: transfer failed");
    }
  }

  /**
        @notice Unbind a token
        @param _token Token to unbind
    */
  function unbind(address _token) external onlyTokenBinder noReentry {
    IBPool bPool = lpbs().bPool;
    IERC20 token = IERC20(_token);
    // unbind the token in the bPool
    bPool.unbind(_token);

    // If any tokens are in this contract send them to msg.sender
    uint256 tokenBalance = token.balanceOf(address(this));
    if (tokenBalance > 0) {
      require(token.transfer(msg.sender, tokenBalance), "PBasicSmartPool.unbind: transfer failed");
    }
  }

  function getTokens() external override view returns (address[] memory) {
    return lpbs().bPool.getCurrentTokens();
  }

  /**
        @notice Gets the underlying assets and amounts to mint specific pool shares.
        @param _amount Amount of pool shares to calculate the values for
        @return tokens The addresses of the tokens
        @return amounts The amounts of tokens needed to mint that amount of pool shares
    */
  function calcTokensForAmount(uint256 _amount)
    external
    override
    view
    returns (address[] memory tokens, uint256[] memory amounts)
  {
    tokens = lpbs().bPool.getCurrentTokens();
    amounts = new uint256[](tokens.length);
    uint256 ratio = _amount.bdiv(totalSupply());

    for (uint256 i = 0; i < tokens.length; i++) {
      address t = tokens[i];
      uint256 bal = lpbs().bPool.getBalance(t);
      uint256 amount = ratio.bmul(bal);
      amounts[i] = amount;
    }
  }

  /** 
        @notice Get the address of the controller
        @return The address of the pool
    */
  function getController() external override view returns (address) {
    return lpbs().controller;
  }

  /** 
        @notice Get the address of the public swap setter
        @return The public swap setter address
    */
  function getPublicSwapSetter() external view returns (address) {
    return lpbs().publicSwapSetter;
  }

  /**
        @notice Get the address of the token binder
        @return The token binder address
    */
  function getTokenBinder() external view returns (address) {
    return lpbs().tokenBinder;
  }

  /**
        @notice Get if public swapping is enabled
        @return If public swapping is enabled
    */
  function isPublicSwap() external view returns (bool) {
    return lpbs().bPool.isPublicSwap();
  }

  /**
        @notice Get the current swap fee
        @return The current swap fee
    */
  function getSwapFee() external view returns (uint256) {
    return lpbs().bPool.getSwapFee();
  }

  /**
        @notice Get the address of the underlying Balancer pool
        @return The address of the underlying balancer pool
    */
  function getBPool() external view returns (address) {
    return address(lpbs().bPool);
  }

  /**
        @notice Pull the underlying token from an address and rebind it to the balancer pool
        @param _token Address of the token to pull
        @param _from Address to pull the token from
        @param _amount Amount of token to pull
        @param _tokenBalance Balance of the token already in the balancer pool
    */
  function _pullUnderlying(
    address _token,
    address _from,
    uint256 _amount,
    uint256 _tokenBalance
  ) internal {
    IBPool bPool = lpbs().bPool;
    // Gets current Balance of token i, Bi, and weight of token i, Wi, from BPool.
    uint256 tokenWeight = bPool.getDenormalizedWeight(_token);

    require(
      IERC20(_token).transferFrom(_from, address(this), _amount),
      "PBasicSmartPool._pullUnderlying: transferFrom failed"
    );
    bPool.rebind(_token, _tokenBalance.badd(_amount), tokenWeight);
  }

  /** 
        @notice Push a underlying token and rebind the token to the balancer pool
        @param _token Address of the token to push
        @param _to Address to pull the token to
        @param _amount Amount of token to push
        @param _tokenBalance Balance of the token already in the balancer pool
    */
  function _pushUnderlying(
    address _token,
    address _to,
    uint256 _amount,
    uint256 _tokenBalance
  ) internal {
    IBPool bPool = lpbs().bPool;
    // Gets current Balance of token i, Bi, and weight of token i, Wi, from BPool.
    uint256 tokenWeight = bPool.getDenormalizedWeight(_token);
    bPool.rebind(_token, _tokenBalance.bsub(_amount), tokenWeight);

    require(
      IERC20(_token).transfer(_to, _amount),
      "PBasicSmartPool._pushUnderlying: transfer failed"
    );
  }

  /**
        @notice Pull pool shares
        @param _from Address to pull pool shares from
        @param _amount Amount of pool shares to pull
    */
  function _pullPoolShare(address _from, uint256 _amount) internal {
    _pull(_from, _amount);
  }

  /**
        @notice Burn pool shares
        @param _amount Amount of pool shares to burn
    */
  function _burnPoolShare(uint256 _amount) internal {
    _burn(_amount);
  }

  /** 
        @notice Mint pool shares 
        @param _amount Amount of pool shares to mint
    */
  function _mintPoolShare(uint256 _amount) internal {
    _mint(_amount);
  }

  /**
        @notice Push pool shares to account
        @param _to Address to push the pool shares to
        @param _amount Amount of pool shares to push
    */
  function _pushPoolShare(address _to, uint256 _amount) internal {
    _push(_to, _amount);
  }

  /**
        @notice Searches for an address in an array of addresses and returns if found
        @param _needle Address to look for
        @param _haystack Array to search
        @return If value is found
    */
  function _contains(address _needle, address[] memory _haystack) internal pure returns (bool) {
    for (uint256 i = 0; i < _haystack.length; i++) {
      if (_haystack[i] == _needle) {
        return true;
      }
    }
    return false;
  }

  /**
        @notice Load PBasicPool storage
        @return s Pointer to the storage struct
    */
  function lpbs() internal pure returns (pbs storage s) {
    bytes32 loc = pbsSlot;
    assembly {
      s_slot := loc
    }
  }
}


// File contracts/smart-pools/PCappedSmartPool.sol

pragma solidity 0.6.4;



contract PCappedSmartPool is PBasicSmartPool {
  bytes32 public constant pcsSlot = keccak256("PCappedSmartPool.storage.location");

  event CapChanged(address indexed setter, uint256 oldCap, uint256 newCap);

  struct pcs {
    uint256 cap;
  }

  modifier withinCap() {
    _;
    require(totalSupply() < lpcs().cap, "PCappedSmartPool.withinCap: Cap limit reached");
  }

  /**
        @notice Set the maximum cap of the contract
        @param _cap New cap in wei
    */
  function setCap(uint256 _cap) external onlyController noReentry {
    emit CapChanged(msg.sender, lpcs().cap, _cap);
    lpcs().cap = _cap;
  }

  /**
        @notice Get the current cap
        @return The current cap in wei
    */
  function getCap() external view returns (uint256) {
    return lpcs().cap;
  }

  /**
        @notice Load the PCappedSmartPool storage
        @return s Pointer to the storage struct
    */
  function lpcs() internal pure returns (pcs storage s) {
    bytes32 loc = pcsSlot;
    assembly {
      s_slot := loc
    }
  }
}


// File contracts/factory/PProxiedFactory.sol

pragma solidity ^0.6.4;








contract PProxiedFactory is Ownable {
  IBFactory public balancerFactory;
  address public smartPoolImplementation;
  mapping(address => bool) public isPool;
  address[] public pools;

  event SmartPoolCreated(address indexed poolAddress, string name, string symbol);

  function init(address _balancerFactory) public {
    require(smartPoolImplementation == address(0), "Already initialised");
    _setOwner(msg.sender);
    balancerFactory = IBFactory(_balancerFactory);

    PCappedSmartPool implementation = new PCappedSmartPool();
    implementation.init(address(1), "IMPL", "IMPL", 1 ether);
    smartPoolImplementation = address(implementation);
  }

  function newProxiedSmartPool(
    string memory _name,
    string memory _symbol,
    uint256 _initialSupply,
    address[] memory _tokens,
    uint256[] memory _amounts,
    uint256[] memory _weights,
    uint256 _cap
  ) public onlyOwner returns (address) {
    // Deploy proxy contract
    PProxyPausable proxy = new PProxyPausable();

    // Setup proxy
    proxy.setImplementation(smartPoolImplementation);
    proxy.setPauzer(msg.sender);
    proxy.setProxyOwner(msg.sender);

    // Setup balancer pool
    address balancerPoolAddress = balancerFactory.newBPool();
    IBPool bPool = IBPool(balancerPoolAddress);

    for (uint256 i = 0; i < _tokens.length; i++) {
      IERC20 token = IERC20(_tokens[i]);
      // Transfer tokens to this contract
      token.transferFrom(msg.sender, address(this), _amounts[i]);
      // Approve the balancer pool
      token.approve(balancerPoolAddress, uint256(-1));
      // Bind tokens
      bPool.bind(_tokens[i], _amounts[i], _weights[i]);
    }
    bPool.setController(address(proxy));

    // Setup smart pool
    PCappedSmartPool smartPool = PCappedSmartPool(address(proxy));

    smartPool.init(balancerPoolAddress, _name, _symbol, _initialSupply);
    smartPool.setCap(_cap);
    smartPool.setPublicSwapSetter(msg.sender);
    smartPool.setTokenBinder(msg.sender);
    smartPool.setController(msg.sender);
    smartPool.approveTokens();

    isPool[address(smartPool)] = true;
    pools.push(address(smartPool));

    emit SmartPoolCreated(address(smartPool), _name, _symbol);

    smartPool.transfer(msg.sender, _initialSupply);

    return address(smartPool);
  }
}


// File contracts/test/TestPCToken.sol

pragma solidity 0.6.4;



contract TestPCToken is PCToken {
  constructor(string memory _name, string memory _symbol) public {
    lpts().name = _name;
    lpts().symbol = _symbol;
  }

  function mint(address _to, uint256 _amount) external {
    _mint(_amount);
    _push(_to, _amount);
  }

  function burn(address _from, uint256 _amount) external {
    _pull(_from, _amount);
    _burn(_amount);
  }
}


// File contracts/test/TestReentryProtection.sol

pragma solidity 0.6.4;



contract TestReentryProtection is ReentryProtection {
  // This should fail
  function test() external noReentry {
    reenter();
  }

  function reenter() public noReentry {
    // Do nothing
  }
}


// File contracts/interfaces/IKyberNetwork.sol

pragma solidity ^0.6.4;


interface IKyberNetwork {
  function trade(
    address src,
    uint256 srcAmount,
    address dest,
    address payable destAddress,
    uint256 maxDestAmount,
    uint256 minConversionRate,
    address walletId
  ) external payable returns (uint256);
}


// File contracts/interfaces/IUniswapExchange.sol

pragma solidity ^0.6.4;


interface IUniswapExchange {
  // Address of ERC20 token sold on this exchange
  function tokenAddress() external view returns (address token);

  // Address of Uniswap Factory
  function factoryAddress() external view returns (address factory);

  // Provide Liquidity
  function addLiquidity(
    uint256 min_liquidity,
    uint256 max_tokens,
    uint256 deadline
  ) external payable returns (uint256);

  function removeLiquidity(
    uint256 amount,
    uint256 min_eth,
    uint256 min_tokens,
    uint256 deadline
  ) external returns (uint256, uint256);

  // Get Prices
  function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

  function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

  function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

  function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

  // Trade ETH to ERC20
  function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
    external
    payable
    returns (uint256 tokens_bought);

  function ethToTokenTransferInput(
    uint256 min_tokens,
    uint256 deadline,
    address recipient
  ) external payable returns (uint256 tokens_bought);

  function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline)
    external
    payable
    returns (uint256 eth_sold);

  function ethToTokenTransferOutput(
    uint256 tokens_bought,
    uint256 deadline,
    address recipient
  ) external payable returns (uint256 eth_sold);

  // Trade ERC20 to ETH
  function tokenToEthSwapInput(
    uint256 tokens_sold,
    uint256 min_eth,
    uint256 deadline
  ) external returns (uint256 eth_bought);

  function tokenToEthTransferInput(
    uint256 tokens_sold,
    uint256 min_eth,
    uint256 deadline,
    address recipient
  ) external returns (uint256 eth_bought);

  function tokenToEthSwapOutput(
    uint256 eth_bought,
    uint256 max_tokens,
    uint256 deadline
  ) external returns (uint256 tokens_sold);

  function tokenToEthTransferOutput(
    uint256 eth_bought,
    uint256 max_tokens,
    uint256 deadline,
    address recipient
  ) external returns (uint256 tokens_sold);

  // Trade ERC20 to ERC20
  function tokenToTokenSwapInput(
    uint256 tokens_sold,
    uint256 min_tokens_bought,
    uint256 min_eth_bought,
    uint256 deadline,
    address token_addr
  ) external returns (uint256 tokens_bought);

  function tokenToTokenTransferInput(
    uint256 tokens_sold,
    uint256 min_tokens_bought,
    uint256 min_eth_bought,
    uint256 deadline,
    address recipient,
    address token_addr
  ) external returns (uint256 tokens_bought);

  function tokenToTokenSwapOutput(
    uint256 tokens_bought,
    uint256 max_tokens_sold,
    uint256 max_eth_sold,
    uint256 deadline,
    address token_addr
  ) external returns (uint256 tokens_sold);

  function tokenToTokenTransferOutput(
    uint256 tokens_bought,
    uint256 max_tokens_sold,
    uint256 max_eth_sold,
    uint256 deadline,
    address recipient,
    address token_addr
  ) external returns (uint256 tokens_sold);

  // Trade ERC20 to Custom Pool
  function tokenToExchangeSwapInput(
    uint256 tokens_sold,
    uint256 min_tokens_bought,
    uint256 min_eth_bought,
    uint256 deadline,
    address exchange_addr
  ) external returns (uint256 tokens_bought);

  function tokenToExchangeTransferInput(
    uint256 tokens_sold,
    uint256 min_tokens_bought,
    uint256 min_eth_bought,
    uint256 deadline,
    address recipient,
    address exchange_addr
  ) external returns (uint256 tokens_bought);

  function tokenToExchangeSwapOutput(
    uint256 tokens_bought,
    uint256 max_tokens_sold,
    uint256 max_eth_sold,
    uint256 deadline,
    address exchange_addr
  ) external returns (uint256 tokens_sold);

  function tokenToExchangeTransferOutput(
    uint256 tokens_bought,
    uint256 max_tokens_sold,
    uint256 max_eth_sold,
    uint256 deadline,
    address recipient,
    address exchange_addr
  ) external returns (uint256 tokens_sold);

  // ERC20 comaptibility for liquidity tokens
  // bytes32 public name;
  // bytes32 public symbol;
  // uint256 public decimals;
  function transfer(address _to, uint256 _value) external returns (bool);

  function transferFrom(
    address _from,
    address _to,
    uint256 value
  ) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  function allowance(address _owner, address _spender) external view returns (uint256);

  function balanceOf(address _owner) external view returns (uint256);

  function totalSupply() external view returns (uint256);

  // Never use
  function setup(address token_addr) external;
}


// File contracts/interfaces/IUniswapFactory.sol

pragma solidity ^0.6.4;


interface IUniswapFactory {
  // Create Exchange
  function createExchange(address token) external returns (address exchange);

  // Get Exchange and Token Info
  function getExchange(address token) external view returns (address exchange);

  function getToken(address exchange) external view returns (address token);

  function getTokenWithId(uint256 tokenId) external view returns (address token);

  // Never use
  function initializeFactory(address template) external;
}