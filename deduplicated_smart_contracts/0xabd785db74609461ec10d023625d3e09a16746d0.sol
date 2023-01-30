/**

 *Submitted for verification at Etherscan.io on 2019-02-15

*/



pragma solidity 0.5.1;

pragma experimental ABIEncoderV2;



/**

 * @dev Standard interface for a dex proxy contract.

 */

interface Proxy {



  /**

   * @dev Executes an action.

   * @param _target Target of execution.

   * @param _a Address usually represention from.

   * @param _b Address usually representing to.

   * @param _c Integer usually repersenting amount/value/id.

   */

  function execute(

    address _target,

    address _a,

    address _b,

    uint256 _c

  )

    external;

    

}



/**

 * @dev Xcert interface.

 */

interface Xcert // is ERC721 metadata enumerable

{



  /**

   * @dev Creates a new Xcert.

   * @param _to The address that will own the created Xcert.

   * @param _id The Xcert to be created by the msg.sender.

   * @param _imprint Cryptographic asset imprint.

   */

  function create(

    address _to,

    uint256 _id,

    bytes32 _imprint

  )

    external;



  /**

   * @dev Change URI base.

   * @param _uriBase New uriBase.

   */

  function setUriBase(

    string calldata _uriBase

  )

    external;



  /**

   * @dev Returns a bytes4 of keccak256 of json schema representing 0xcert Protocol convention.

   * @return Schema id.

   */

  function schemaId()

    external

    view

    returns (bytes32 _schemaId);



  /**

   * @dev Returns imprint for Xcert.

   * @param _tokenId Id of the Xcert.

   * @return Token imprint.

   */

  function tokenImprint(

    uint256 _tokenId

  )

    external

    view

    returns(bytes32 imprint);



}





/**

 * @dev Math operations with safety checks that throw on error. This contract is based on the 

 * source code at: 

 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol.

 */

library SafeMath

{



  /**

   * @dev Error constants.

   */

  string constant OVERFLOW = "008001";

  string constant SUBTRAHEND_GREATER_THEN_MINUEND = "008002";

  string constant DIVISION_BY_ZERO = "008003";



  /**

   * @dev Multiplies two numbers, reverts on overflow.

   * @param _factor1 Factor number.

   * @param _factor2 Factor number.

   * @return The product of the two factors.

   */

  function mul(

    uint256 _factor1,

    uint256 _factor2

  )

    internal

    pure

    returns (uint256 product)

  {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_factor1 == 0)

    {

      return 0;

    }



    product = _factor1 * _factor2;

    require(product / _factor1 == _factor2, OVERFLOW);

  }



  /**

   * @dev Integer division of two numbers, truncating the quotient, reverts on division by zero.

   * @param _dividend Dividend number.

   * @param _divisor Divisor number.

   * @return The quotient.

   */

  function div(

    uint256 _dividend,

    uint256 _divisor

  )

    internal

    pure

    returns (uint256 quotient)

  {

    // Solidity automatically asserts when dividing by 0, using all gas.

    require(_divisor > 0, DIVISION_BY_ZERO);

    quotient = _dividend / _divisor;

    // assert(_dividend == _divisor * quotient + _dividend % _divisor); // There is no case in which this doesn't hold.

  }



  /**

   * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

   * @param _minuend Minuend number.

   * @param _subtrahend Subtrahend number.

   * @return Difference.

   */

  function sub(

    uint256 _minuend,

    uint256 _subtrahend

  )

    internal

    pure

    returns (uint256 difference)

  {

    require(_subtrahend <= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);

    difference = _minuend - _subtrahend;

  }



  /**

   * @dev Adds two numbers, reverts on overflow.

   * @param _addend1 Number.

   * @param _addend2 Number.

   * @return Sum.

   */

  function add(

    uint256 _addend1,

    uint256 _addend2

  )

    internal

    pure

    returns (uint256 sum)

  {

    sum = _addend1 + _addend2;

    require(sum >= _addend1, OVERFLOW);

  }



  /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo), reverts when

    * dividing by zero.

    * @param _dividend Number.

    * @param _divisor Number.

    * @return Remainder.

    */

  function mod(

    uint256 _dividend,

    uint256 _divisor

  )

    internal

    pure

    returns (uint256 remainder) 

  {

    require(_divisor != 0, DIVISION_BY_ZERO);

    remainder = _dividend % _divisor;

  }



}



/**

 * @title Contract for setting abilities.

 * @dev For optimization purposes the abilities are represented as a bitfield. Maximum number of

 * abilities is therefore 256. This is an example(for simplicity is made for max 8 abilities) of how

 * this works. 

 * 00000001 Ability A - number representation 1

 * 00000010 Ability B - number representation 2

 * 00000100 Ability C - number representation 4

 * 00001000 Ability D - number representation 8

 * 00010000 Ability E - number representation 16

 * etc ... 

 * To grant abilities B and C, we would need a bitfield of 00000110 which is represented by number

 * 6, in other words, the sum of abilities B and C. The same concept works for revoking abilities

 * and checking if someone has multiple abilities.

 */

contract Abilitable

{

  using SafeMath for uint;



  /**

   * @dev Error constants.

   */

  string constant NOT_AUTHORIZED = "017001";

  string constant ONE_ZERO_ABILITY_HAS_TO_EXIST = "017002";

  string constant INVALID_INPUT = "017003";



  /**

   * @dev Ability 1 is a reserved ability. It is an ability to grant or revoke abilities. 

   * There can be minimum of 1 address with ability 1.

   * Other abilities are determined by implementing contract.

   */

  uint8 constant ABILITY_TO_MANAGE_ABILITIES = 1;



  /**

   * @dev Maps address to ability ids.

   */

  mapping(address => uint256) public addressToAbility;



  /**

   * @dev Count of zero ability addresses.

   */

  uint256 private zeroAbilityCount;



  /**

   * @dev Emits when an address is granted an ability.

   * @param _target Address to which we are granting abilities.

   * @param _abilities Number representing bitfield of abilities we are granting.

   */

  event GrantAbilities(

    address indexed _target,

    uint256 indexed _abilities

  );



  /**

   * @dev Emits when an address gets an ability revoked.

   * @param _target Address of which we are revoking an ability.

   * @param _abilities Number representing bitfield of abilities we are revoking.

   */

  event RevokeAbilities(

    address indexed _target,

    uint256 indexed _abilities

  );



  /**

   * @dev Guarantees that msg.sender has certain abilities.

   */

  modifier hasAbilities(

    uint256 _abilities

  ) 

  {

    require(_abilities > 0, INVALID_INPUT);

    require(

      (addressToAbility[msg.sender] & _abilities) == _abilities,

      NOT_AUTHORIZED

    );

    _;

  }



  /**

   * @dev Contract constructor.

   * Sets ABILITY_TO_MANAGE_ABILITIES ability to the sender account.

   */

  constructor()

    public

  {

    addressToAbility[msg.sender] = ABILITY_TO_MANAGE_ABILITIES;

    zeroAbilityCount = 1;

    emit GrantAbilities(msg.sender, ABILITY_TO_MANAGE_ABILITIES);

  }



  /**

   * @dev Grants specific abilities to specified address.

   * @param _target Address to grant abilities to.

   * @param _abilities Number representing bitfield of abilities we are granting.

   */

  function grantAbilities(

    address _target,

    uint256 _abilities

  )

    external

    hasAbilities(ABILITY_TO_MANAGE_ABILITIES)

  {

    addressToAbility[_target] |= _abilities;



    if((_abilities & ABILITY_TO_MANAGE_ABILITIES) == ABILITY_TO_MANAGE_ABILITIES)

    {

      zeroAbilityCount = zeroAbilityCount.add(1);

    }

    emit GrantAbilities(_target, _abilities);

  }



  /**

   * @dev Unassigns specific abilities from specified address.

   * @param _target Address of which we revoke abilites.

   * @param _abilities Number representing bitfield of abilities we are revoking.

   */

  function revokeAbilities(

    address _target,

    uint256 _abilities

  )

    external

    hasAbilities(ABILITY_TO_MANAGE_ABILITIES)

  {

    addressToAbility[_target] &= ~_abilities;

    if((_abilities & 1) == 1)

    {

      require(zeroAbilityCount > 1, ONE_ZERO_ABILITY_HAS_TO_EXIST);

      zeroAbilityCount--;

    }

    emit RevokeAbilities(_target, _abilities);

  }



  /**

   * @dev Check if an address has a specific ability. Throws if checking for 0.

   * @param _target Address for which we want to check if it has a specific abilities.

   * @param _abilities Number representing bitfield of abilities we are checking.

   */

  function isAble(

    address _target,

    uint256 _abilities

  )

    external

    view

    returns (bool)

  {

    require(_abilities > 0, INVALID_INPUT);

    return (addressToAbility[_target] & _abilities) == _abilities;

  }

  

}



/**

 * @title XcertCreateProxy - creates a token on behalf of contracts that have been approved via

 * decentralized governance.

 */

contract XcertCreateProxy is 

  Abilitable 

{



  /**

   * @dev List of abilities:

   * 2 - Ability to execute create. 

   */

  uint8 constant ABILITY_TO_EXECUTE = 2;



  /**

   * @dev Creates a new NFT.

   * @param _xcert Address of the Xcert contract on which the creation will be perfomed.

   * @param _to The address that will own the created NFT.

   * @param _id The NFT to be created by the msg.sender.

   * @param _imprint Cryptographic asset imprint.

   */

  function create(

    address _xcert,

    address _to,

    uint256 _id,

    bytes32 _imprint

  )

    external

    hasAbilities(ABILITY_TO_EXECUTE)

  {

    Xcert(_xcert).create(_to, _id, _imprint);

  }

  

}



/**

 * @dev Decentralize exchange, creating, updating and other actions for fundgible and non-fundgible 

 * tokens powered by atomic swaps. 

 */

contract OrderGateway is

  Abilitable

{



  /**

   * @dev List of abilities:

   * 1 - Ability to set proxies.

   */

  uint8 constant ABILITY_TO_SET_PROXIES = 2;



  /**

   * @dev Xcert abilities.

   */

  uint8 constant ABILITY_ALLOW_CREATE_ASSET = 32;



  /**

   * @dev Error constants.

   */

  string constant INVALID_SIGNATURE_KIND = "015001";

  string constant INVALID_PROXY = "015002";

  string constant TAKER_NOT_EQUAL_TO_SENDER = "015003";

  string constant SENDER_NOT_TAKER_OR_MAKER = "015004";

  string constant CLAIM_EXPIRED = "015005";

  string constant INVALID_SIGNATURE = "015006";

  string constant ORDER_CANCELED = "015007";

  string constant ORDER_ALREADY_PERFORMED = "015008";

  string constant MAKER_NOT_EQUAL_TO_SENDER = "015009";

  string constant SIGNER_NOT_AUTHORIZED = "015010";



  /**

   * @dev Enum of available signature kinds.

   * @param eth_sign Signature using eth sign.

   * @param trezor Signature from Trezor hardware wallet.

   * It differs from web3.eth_sign in the encoding of message length

   * (Bitcoin varint encoding vs ascii-decimal, the latter is not

   * self-terminating which leads to ambiguities).

   * See also:

   * https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer

   * https://github.com/trezor/trezor-mcu/blob/master/firmware/ethereum.c#L602

   * https://github.com/trezor/trezor-mcu/blob/master/firmware/crypto.c#L36 

   * @param eip721 Signature using eip721.

   */

  enum SignatureKind

  {

    eth_sign,

    trezor,

    eip712

  }



  /**

   * Enum of available action kinds.

   */

  enum ActionKind

  {

    create,

    transfer

  }



  /**

   * @dev Structure representing what to send and where.

   * @param token Address of the token we are sending.

   * @param proxy Id representing approved proxy address.

   * @param param1 Address of the sender or imprint.

   * @param to Address of the receiver.

   * @param value Amount of ERC20 or ID of ERC721.

   */

  struct ActionData 

  {

    ActionKind kind;

    uint32 proxy;

    address token;

    bytes32 param1;

    address to;

    uint256 value;

  }



  /**

   * @dev Structure representing the signature parts.

   * @param r ECDSA signature parameter r.

   * @param s ECDSA signature parameter s.

   * @param v ECDSA signature parameter v.

   * @param kind Type of signature. 

   */

  struct SignatureData

  {

    bytes32 r;

    bytes32 s;

    uint8 v;

    SignatureKind kind;

  }



  /**

   * @dev Structure representing the data needed to do the order.

   * @param maker Address of the one that made the claim.

   * @param taker Address of the one that is executing the claim.

   * @param actions Data of all the actions that should accure it this order.

   * @param signature Data from the signed claim.

   * @param seed Arbitrary number to facilitate uniqueness of the order's hash. Usually timestamp.

   * @param expiration Timestamp of when the claim expires. 0 if indefinet. 

   */

  struct OrderData 

  {

    address maker;

    address taker;

    ActionData[] actions;

    uint256 seed;

    uint256 expiration;

  }



  /** 

   * @dev Valid proxy contract addresses.

   */

  mapping(uint32 => address) public idToProxy;



  /**

   * @dev Mapping of all cancelled orders.

   */

  mapping(bytes32 => bool) public orderCancelled;



  /**

   * @dev Mapping of all performed orders.

   */

  mapping(bytes32 => bool) public orderPerformed;



  /**

   * @dev This event emmits when tokens change ownership.

   */

  event Perform(

    address indexed _maker,

    address indexed _taker,

    bytes32 _claim

  );



  /**

   * @dev This event emmits when transfer order is cancelled.

   */

  event Cancel(

    address indexed _maker,

    address indexed _taker,

    bytes32 _claim

  );



  /**

   * @dev This event emmits when proxy address is changed..

   */

  event ProxyChange(

    uint32 indexed _id,

    address _proxy

  );



  /**

   * @dev Sets a verified proxy address. 

   * @notice Can be done through a multisig wallet in the future.

   * @param _id Id of the proxy.

   * @param _proxy Proxy address.

   */

  function setProxy(

    uint32 _id,

    address _proxy

  )

    external

    hasAbilities(ABILITY_TO_SET_PROXIES)

  {

    idToProxy[_id] = _proxy;

    emit ProxyChange(_id, _proxy);

  }



  /**

   * @dev Performs the ERC721/ERC20 atomic swap.

   * @param _data Data required to make the order.

   * @param _signature Data from the signature. 

   */

  function perform(

    OrderData memory _data,

    SignatureData memory _signature

  )

    public 

  {

    require(_data.taker == msg.sender, TAKER_NOT_EQUAL_TO_SENDER);

    require(_data.expiration >= now, CLAIM_EXPIRED);



    bytes32 claim = getOrderDataClaim(_data);

    require(

      isValidSignature(

        _data.maker,

        claim,

        _signature

      ), 

      INVALID_SIGNATURE

    );



    require(!orderCancelled[claim], ORDER_CANCELED);

    require(!orderPerformed[claim], ORDER_ALREADY_PERFORMED);



    orderPerformed[claim] = true;



    _doActions(_data);



    emit Perform(

      _data.maker,

      _data.taker,

      claim

    );

  }



  /** 

   * @dev Cancels order

   * @param _data Data of order to cancel.

   */

  function cancel(

    OrderData memory _data

  )

    public

  {

    require(_data.maker == msg.sender, MAKER_NOT_EQUAL_TO_SENDER);



    bytes32 claim = getOrderDataClaim(_data);

    require(!orderPerformed[claim], ORDER_ALREADY_PERFORMED);



    orderCancelled[claim] = true;

    emit Cancel(

      _data.maker,

      _data.taker,

      claim

    );

  }



  /**

   * @dev Calculates keccak-256 hash of OrderData from parameters.

   * @param _orderData Data needed for atomic swap.

   * @return keccak-hash of order data.

   */

  function getOrderDataClaim(

    OrderData memory _orderData

  )

    public

    view

    returns (bytes32)

  {

    bytes32 temp = 0x0;



    for(uint256 i = 0; i < _orderData.actions.length; i++)

    {

      temp = keccak256(

        abi.encodePacked(

          temp,

          _orderData.actions[i].kind,

          _orderData.actions[i].proxy,

          _orderData.actions[i].token,

          _orderData.actions[i].param1,

          _orderData.actions[i].to,

          _orderData.actions[i].value

        )

      );

    }



    return keccak256(

      abi.encodePacked(

        address(this),

        _orderData.maker,

        _orderData.taker,

        temp,

        _orderData.seed,

        _orderData.expiration

      )

    );

  }

  

  /**

   * @dev Verifies if claim signature is valid.

   * @param _signer address of signer.

   * @param _claim Signed Keccak-256 hash.

   * @param _signature Signature data.

   */

  function isValidSignature(

    address _signer,

    bytes32 _claim,

    SignatureData memory _signature

  )

    public

    pure

    returns (bool)

  {

    if(_signature.kind == SignatureKind.eth_sign)

    {

      return _signer == ecrecover(

        keccak256(

          abi.encodePacked(

            "\x19Ethereum Signed Message:\n32",

            _claim

          )

        ),

        _signature.v,

        _signature.r,

        _signature.s

      );

    } else if (_signature.kind == SignatureKind.trezor)

    {

      return _signer == ecrecover(

        keccak256(

          abi.encodePacked(

            "\x19Ethereum Signed Message:\n\x20",

            _claim

          )

        ),

        _signature.v,

        _signature.r,

        _signature.s

      );

    } else if (_signature.kind == SignatureKind.eip712)

    {

      return _signer == ecrecover(

        _claim,

        _signature.v,

        _signature.r,

        _signature.s

      );

    }



    revert(INVALID_SIGNATURE_KIND);

  }



  /**

   * @dev Helper function that makes transfes.

   * @param _order Data needed for order.

   */

  function _doActions(

    OrderData memory _order

  )

    private

  {

    for(uint256 i = 0; i < _order.actions.length; i++)

    {

      require(

        idToProxy[_order.actions[i].proxy] != address(0),

        INVALID_PROXY

      );



      if(_order.actions[i].kind == ActionKind.create)

      {

        require(

          Abilitable(_order.actions[i].token).isAble(_order.maker, ABILITY_ALLOW_CREATE_ASSET),

          SIGNER_NOT_AUTHORIZED

        );

        

        XcertCreateProxy(idToProxy[_order.actions[i].proxy]).create(

          _order.actions[i].token,

          _order.actions[i].to,

          _order.actions[i].value,

          _order.actions[i].param1

        );

      } 

      else if (_order.actions[i].kind == ActionKind.transfer)

      {

        address from = address(uint160(bytes20(_order.actions[i].param1)));

        require(

          from == _order.maker

          || from == _order.taker,

          SENDER_NOT_TAKER_OR_MAKER

        );

        

        Proxy(idToProxy[_order.actions[i].proxy]).execute(

          _order.actions[i].token,

          from,

          _order.actions[i].to,

          _order.actions[i].value

        );

      }

    }

  }

  

}