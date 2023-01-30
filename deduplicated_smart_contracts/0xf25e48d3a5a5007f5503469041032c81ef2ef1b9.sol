/**

 *Submitted for verification at Etherscan.io on 2019-02-23

*/



/**

 * Copyright (c) 2018-present, Leap DAO (leapdao.org)

 *

 * This source code is licensed under the Mozilla Public License, version 2,

 * found in the LICENSE file in the root directory of this source tree.

 */



pragma solidity 0.5.2;





contract Bridge {

  

  function admin() external view returns (address) {

  }



  struct Period {

    uint32 height;  // the height of last block in period

    uint32 timestamp;

  }



  bytes32 public tipHash; // hash of first period that has extended chain to some height

  uint256 public genesisBlockNumber;

  uint256 parentBlockInterval; // how often epochs can be submitted max

  uint256 public lastParentBlock; // last ethereum block when epoch was submitted

  address public operator; // the operator contract



  mapping(bytes32 => Period) public periods;



}



contract Vault {



  Bridge public bridge;



  uint16 public erc20TokenCount;

  uint16 public nftTokenCount;



  mapping(address => bool) public tokenColors;



  function getTokenAddr(uint16 _color) public view returns (address) {



  }





}



/**

 * @title Initializable

 *

 * @dev Helper contract to support initializer functions. To use it, replace

 * the constructor with a function that has the `initializer` modifier.

 * WARNING: Unlike constructors, initializer functions must be manually

 * invoked. This applies both to deploying an Initializable contract, as well

 * as extending an Initializable contract via inheritance.

 * WARNING: When used with inheritance, manual care must be taken to not invoke

 * a parent initializer twice, or ensure that all initializers are idempotent,

 * because this is not dealt with automatically as with constructors.

 */

contract Initializable {



  /**

   * @dev Indicates that the contract has been initialized.

   */

  bool private initialized;



  /**

   * @dev Indicates that the contract is in the process of being initialized.

   */

  bool private initializing;



  /**

   * @dev Modifier to use in the initializer function of a contract.

   */

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");



    bool wasInitializing = initializing;

    initializing = true;

    initialized = true;



    _;



    initializing = wasInitializing;

  }



  /// @dev Returns true if and only if the function is running in the constructor

  function isConstructor() private view returns (bool) {

    // extcodesize checks the size of the code stored in an address, and

    // address returns the current address. Since the code is still not

    // deployed when running a constructor, any checks on its code size will

    // yield zero, making it an effective way to detect if a contract is

    // under construction or not.

    uint256 cs;

    assembly { cs := extcodesize(address) }

    return cs == 0;

  }



  // Reserved storage space to allow for layout changes in the future.

  uint256[50] private ______gap;

}





/**

 * @title Adminable

 *

 * @dev Helper contract to support initializer functions. To use it, replace

 * the constructor with a function that has the `initializer` modifier.

 * WARNING: Unlike constructors, initializer functions must be manually

 * invoked. This applies both to deploying an Initializable contract, as well

 * as extending an Initializable contract via inheritance.

 * WARNING: When used with inheritance, manual care must be taken to not invoke

 * a parent initializer twice, or ensure that all initializers are idempotent,

 * because this is not dealt with automatically as with constructors.

 */

contract Adminable is Initializable {



  /**

   * @dev Storage slot with the admin of the contract.

   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is

   * validated in the constructor.

   */

  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;



  /**

   * @dev Modifier to check whether the `msg.sender` is the admin.

   * If it is, it will run the function. Otherwise, fails.

   */

  modifier ifAdmin() {

    require(msg.sender == _admin());

    _;

  }



  function admin() external view returns (address) {

    return _admin();

  }



    /**

   * @return The admin slot.

   */

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;

    assembly {

      adm := sload(slot)

    }

  }

}





contract SwapExchange {



  bytes32 public name;

  bytes32 public symbol;

  uint256 public decimals;



  function setup(address _nativeToken, address _tokenAddr) public {}



  // to be implemented



}



/**

 * @title ERC20Mintable

 * @dev ERC20 minting logic

 */

contract ERC20Mintable  {

    /**

     * @dev Function to mint tokens

     * @param to The address that will receive the minted tokens.

     * @param value The amount of tokens to mint.

     * @return A boolean that indicates if the operation was successful.

     */

    function mint(address to, uint256 value) public returns (bool) {

    }

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

}



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

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

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



contract SwapRegistry is Adminable {

  using SafeMath for uint256;



  // Claim Related

  Bridge bridge;

  Vault vault;

  uint256 constant maxTax = 1000; // 100%

  uint256 taxRate; // as perMil (1000 == 100%, 1 == 0.1%)

  uint256 constant inflationFactor = 10 ** 15;

  uint256 constant maxInflation = 2637549827; // the x from (1 + x*10^-18)^(30 * 24 * 363) = 2  

  uint256 inflationRate; // between 0 and maxInflation/inflationFactor

  uint256 constant poaSupplyTarget = 7000000 * 10 ** 18;

  uint256 poaReward;

  mapping(uint256 => uint256) public slotToHeight;



  function initialize(

    address _bridge,

    address _vault,

    uint256 _poaReward

  ) public initializer {

    require(_bridge != address(0), "invalid bridge address");

    bridge = Bridge(_bridge);

    require(_bridge != address(0), "invalid vault address");

    vault = Vault(_vault);

    // todo: check that this contract is admin of token;

    taxRate = maxTax;

    inflationRate = maxInflation;

    poaReward = _poaReward;

  }



  function claim(

    uint256 _slotId,

    bytes32[] memory _consensusRoots,

    bytes32[] memory _cas,

    bytes32[] memory _validatorData,

    bytes32[] memory _rest

  ) public {

    uint256 maxHeight = slotToHeight[_slotId];

    uint32 claimCount = 0;

    for (uint256 i = 0; i < _consensusRoots.length; i += 1) {

      require(_slotId == uint256(_validatorData[i] >> 160), "unexpected slotId");

      require(msg.sender == address(uint160(uint256(_validatorData[i]))), "unexpected claimant");

      uint256 height;

      bytes32 left = _validatorData[i];

      bytes32 right = _rest[i];

      assembly {

        mstore(0, left)

        mstore(0x20, right)

        right := keccak256(0, 0x40)

      }

      left = _cas[i];

      assembly {

        mstore(0, left)

        mstore(0x20, right)

        right := keccak256(0, 0x40)

      }

      left = _consensusRoots[i];

      assembly {

        mstore(0, left)

        mstore(0x20, right)

        right := keccak256(0, 0x40)

      }

      (height ,) = bridge.periods(right);

      require(height > maxHeight, "unorderly claim");

      maxHeight = height;

      claimCount += 1;

    }

    slotToHeight[_slotId] = maxHeight;

    ERC20Mintable token = ERC20Mintable(vault.getTokenAddr(0));

    uint256 total = token.totalSupply();

    uint256 staked = token.balanceOf(bridge.operator());

    

    // calculate reward according to:

    // https://ethresear.ch/t/riss-reflexive-inflation-through-staked-supply/3633

    uint256 reward = total.mul(inflationRate).div(inflationFactor);

    if (staked > total.div(2)) {

      reward = reward.mul(total.sub(staked).mul(staked).mul(4)).div(total);

    }

    if (total < poaSupplyTarget) {

      reward = poaReward;

    }

    reward = reward.mul(claimCount);

    uint256 tax = reward.mul(taxRate).div(maxTax);  // taxRate perMil (1000 == 100%, 1 == 0.1%)

    // mint tokens

    token.mint(msg.sender, reward.sub(tax));

    token.mint(bridge.admin(), tax);

  }



  // Governance Params



  function getTaxRate() public view returns(uint256) {

    return taxRate;

  }



  function setTaxRate(uint256 _taxRate) public ifAdmin {

    require(_taxRate <= maxTax, "tax rate can not be more than 100%");

    taxRate = _taxRate;

  }



  function getInflationRate() public view returns(uint256) {

    return inflationRate;

  }



  function setInflationRate(uint256 _inflationRate) public ifAdmin {

    require(_inflationRate < maxInflation, "inflation too high");

    inflationRate = _inflationRate;

  }



  // Swap Exchanges



  event NewExchange(address indexed token, address indexed exchange);

  mapping(address => address) tokenToExchange;

  mapping(address => address) exchangeToToken;

  address exchangeCodeAddr;



  function createExchange(address _token) public returns (address) {

    require(_token != address(0), "invalid token address");

    address nativeToken = vault.getTokenAddr(0);

    require(_token != nativeToken, "token can not be nativeToken");

    require(tokenToExchange[_token] == address(0), "exchange already created");

    address exchange = createClone(exchangeCodeAddr);

    SwapExchange(exchange).setup(nativeToken, _token);

    tokenToExchange[_token] = exchange;

    exchangeToToken[exchange] = _token;

    emit NewExchange(_token, exchange);

    return exchange;

  }



  function getExchangeCodeAddr() public view returns(address) {

    return exchangeCodeAddr;

  }



  function setExchangeCodeAddr(address _exchangeCodeAddr) public ifAdmin {

    exchangeCodeAddr = _exchangeCodeAddr;

  }



  function getExchange(address _token) public view returns(address) {

    return tokenToExchange[_token];

  }



  function getToken(address _exchange) public view returns(address) {

    return exchangeToToken[_exchange];

  }



  function createClone(address target) internal returns (address result) {

    bytes20 targetBytes = bytes20(target);

    assembly {

      let clone := mload(0x40)

      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

      mstore(add(clone, 0x14), targetBytes)

      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      result := create(0, clone, 0x37)

    }

  }



}