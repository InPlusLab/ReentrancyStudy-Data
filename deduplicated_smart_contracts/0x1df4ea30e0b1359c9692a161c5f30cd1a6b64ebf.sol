/**
 *Submitted for verification at Etherscan.io on 2021-03-29
*/

//  simple claims store
//  https://azimuth.network

pragma solidity 0.4.24;

////////////////////////////////////////////////////////////////////////////////
//  Imports
////////////////////////////////////////////////////////////////////////////////

// OpenZeppelin's Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// Azimuth's Azimuth.sol

//  Azimuth: point state data contract
//
//    This contract is used for storing all data related to Azimuth points
//    and their ownership. Consider this contract the Azimuth ledger.
//
//    It also contains permissions data, which ties in to ERC721
//    functionality. Operators of an address are allowed to transfer
//    ownership of all points owned by their associated address
//    (ERC721's approveAll()). A transfer proxy is allowed to transfer
//    ownership of a single point (ERC721's approve()).
//    Separate from ERC721 are managers, assigned per point. They are
//    allowed to perform "low-impact" operations on the owner's points,
//    like configuring public keys and making escape requests.
//
//    Since data stores are difficult to upgrade, this contract contains
//    as little actual business logic as possible. Instead, the data stored
//    herein can only be modified by this contract's owner, which can be
//    changed and is thus upgradable/replaceable.
//
//    This contract will be owned by the Ecliptic contract.
//
contract Azimuth is Ownable
{
//
//  Events
//

  //  OwnerChanged: :point is now owned by :owner
  //
  event OwnerChanged(uint32 indexed point, address indexed owner);

  //  Activated: :point is now active
  //
  event Activated(uint32 indexed point);

  //  Spawned: :prefix has spawned :child
  //
  event Spawned(uint32 indexed prefix, uint32 indexed child);

  //  EscapeRequested: :point has requested a new :sponsor
  //
  event EscapeRequested(uint32 indexed point, uint32 indexed sponsor);

  //  EscapeCanceled: :point's :sponsor request was canceled or rejected
  //
  event EscapeCanceled(uint32 indexed point, uint32 indexed sponsor);

  //  EscapeAccepted: :point confirmed with a new :sponsor
  //
  event EscapeAccepted(uint32 indexed point, uint32 indexed sponsor);

  //  LostSponsor: :point's :sponsor is now refusing it service
  //
  event LostSponsor(uint32 indexed point, uint32 indexed sponsor);

  //  ChangedKeys: :point has new network public keys
  //
  event ChangedKeys( uint32 indexed point,
                     bytes32 encryptionKey,
                     bytes32 authenticationKey,
                     uint32 cryptoSuiteVersion,
                     uint32 keyRevisionNumber );

  //  BrokeContinuity: :point has a new continuity number, :number
  //
  event BrokeContinuity(uint32 indexed point, uint32 number);

  //  ChangedSpawnProxy: :spawnProxy can now spawn using :point
  //
  event ChangedSpawnProxy(uint32 indexed point, address indexed spawnProxy);

  //  ChangedTransferProxy: :transferProxy can now transfer ownership of :point
  //
  event ChangedTransferProxy( uint32 indexed point,
                              address indexed transferProxy );

  //  ChangedManagementProxy: :managementProxy can now manage :point
  //
  event ChangedManagementProxy( uint32 indexed point,
                                address indexed managementProxy );

  //  ChangedVotingProxy: :votingProxy can now vote using :point
  //
  event ChangedVotingProxy(uint32 indexed point, address indexed votingProxy);

  //  ChangedDns: dnsDomains have been updated
  //
  event ChangedDns(string primary, string secondary, string tertiary);

//
//  Structures
//

  //  Size: kinds of points registered on-chain
  //
  //    NOTE: the order matters, because of Solidity enum numbering
  //
  enum Size
  {
    Galaxy, // = 0
    Star,   // = 1
    Planet  // = 2
  }

  //  Point: state of a point
  //
  //    While the ordering of the struct members is semantically chaotic,
  //    they are ordered to tightly pack them into Ethereum's 32-byte storage
  //    slots, which reduces gas costs for some function calls.
  //    The comment ticks indicate assumed slot boundaries.
  //
  struct Point
  {
    //  encryptionKey: (curve25519) encryption public key, or 0 for none
    //
    bytes32 encryptionKey;
  //
    //  authenticationKey: (ed25519) authentication public key, or 0 for none
    //
    bytes32 authenticationKey;
  //
    //  spawned: for stars and galaxies, all :active children
    //
    uint32[] spawned;
  //
    //  hasSponsor: true if the sponsor still supports the point
    //
    bool hasSponsor;

    //  active: whether point can be linked
    //
    //    false: point belongs to prefix, cannot be configured or linked
    //    true: point no longer belongs to prefix, can be configured and linked
    //
    bool active;

    //  escapeRequested: true if the point has requested to change sponsors
    //
    bool escapeRequested;

    //  sponsor: the point that supports this one on the network, or,
    //           if :hasSponsor is false, the last point that supported it.
    //           (by default, the point's half-width prefix)
    //
    uint32 sponsor;

    //  escapeRequestedTo: if :escapeRequested is true, new sponsor requested
    //
    uint32 escapeRequestedTo;

    //  cryptoSuiteVersion: version of the crypto suite used for the pubkeys
    //
    uint32 cryptoSuiteVersion;

    //  keyRevisionNumber: incremented every time the public keys change
    //
    uint32 keyRevisionNumber;

    //  continuityNumber: incremented to indicate network-side state loss
    //
    uint32 continuityNumber;
  }

  //  Deed: permissions for a point
  //
  struct Deed
  {
    //  owner: address that owns this point
    //
    address owner;

    //  managementProxy: 0, or another address with the right to perform
    //                   low-impact, managerial operations on this point
    //
    address managementProxy;

    //  spawnProxy: 0, or another address with the right to spawn children
    //              of this point
    //
    address spawnProxy;

    //  votingProxy: 0, or another address with the right to vote as this point
    //
    address votingProxy;

    //  transferProxy: 0, or another address with the right to transfer
    //                 ownership of this point
    //
    address transferProxy;
  }

//
//  General state
//

  //  points: per point, general network-relevant point state
  //
  mapping(uint32 => Point) public points;

  //  rights: per point, on-chain ownership and permissions
  //
  mapping(uint32 => Deed) public rights;

  //  operators: per owner, per address, has the right to transfer ownership
  //             of all the owner's points (ERC721)
  //
  mapping(address => mapping(address => bool)) public operators;

  //  dnsDomains: base domains for contacting galaxies
  //
  //    dnsDomains[0] is primary, the others are used as fallbacks
  //
  string[3] public dnsDomains;

//
//  Lookups
//

  //  sponsoring: per point, the points they are sponsoring
  //
  mapping(uint32 => uint32[]) public sponsoring;

  //  sponsoringIndexes: per point, per point, (index + 1) in
  //                     the sponsoring array
  //
  mapping(uint32 => mapping(uint32 => uint256)) public sponsoringIndexes;

  //  escapeRequests: per point, the points they have open escape requests from
  //
  mapping(uint32 => uint32[]) public escapeRequests;

  //  escapeRequestsIndexes: per point, per point, (index + 1) in
  //                         the escapeRequests array
  //
  mapping(uint32 => mapping(uint32 => uint256)) public escapeRequestsIndexes;

  //  pointsOwnedBy: per address, the points they own
  //
  mapping(address => uint32[]) public pointsOwnedBy;

  //  pointOwnerIndexes: per owner, per point, (index + 1) in
  //                     the pointsOwnedBy array
  //
  //    We delete owners by moving the last entry in the array to the
  //    newly emptied slot, which is (n - 1) where n is the value of
  //    pointOwnerIndexes[owner][point].
  //
  mapping(address => mapping(uint32 => uint256)) public pointOwnerIndexes;

  //  managerFor: per address, the points they are the management proxy for
  //
  mapping(address => uint32[]) public managerFor;

  //  managerForIndexes: per address, per point, (index + 1) in
  //                     the managerFor array
  //
  mapping(address => mapping(uint32 => uint256)) public managerForIndexes;

  //  spawningFor: per address, the points they can spawn with
  //
  mapping(address => uint32[]) public spawningFor;

  //  spawningForIndexes: per address, per point, (index + 1) in
  //                      the spawningFor array
  //
  mapping(address => mapping(uint32 => uint256)) public spawningForIndexes;

  //  votingFor: per address, the points they can vote with
  //
  mapping(address => uint32[]) public votingFor;

  //  votingForIndexes: per address, per point, (index + 1) in
  //                    the votingFor array
  //
  mapping(address => mapping(uint32 => uint256)) public votingForIndexes;

  //  transferringFor: per address, the points they can transfer
  //
  mapping(address => uint32[]) public transferringFor;

  //  transferringForIndexes: per address, per point, (index + 1) in
  //                          the transferringFor array
  //
  mapping(address => mapping(uint32 => uint256)) public transferringForIndexes;

//
//  Logic
//

  //  constructor(): configure default dns domains
  //
  constructor()
    public
  {
    setDnsDomains("example.com", "example.com", "example.com");
  }

  //  setDnsDomains(): set the base domains used for contacting galaxies
  //
  //    Note: since a string is really just a byte[], and Solidity can't
  //    work with two-dimensional arrays yet, we pass in the three
  //    domains as individual strings.
  //
  function setDnsDomains(string _primary, string _secondary, string _tertiary)
    onlyOwner
    public
  {
    dnsDomains[0] = _primary;
    dnsDomains[1] = _secondary;
    dnsDomains[2] = _tertiary;
    emit ChangedDns(_primary, _secondary, _tertiary);
  }

  //
  //  Point reading
  //

    //  isActive(): return true if _point is active
    //
    function isActive(uint32 _point)
      view
      external
      returns (bool equals)
    {
      return points[_point].active;
    }

    //  getKeys(): returns the public keys and their details, as currently
    //             registered for _point
    //
    function getKeys(uint32 _point)
      view
      external
      returns (bytes32 crypt, bytes32 auth, uint32 suite, uint32 revision)
    {
      Point storage point = points[_point];
      return (point.encryptionKey,
              point.authenticationKey,
              point.cryptoSuiteVersion,
              point.keyRevisionNumber);
    }

    //  getKeyRevisionNumber(): gets the revision number of _point's current
    //                          public keys
    //
    function getKeyRevisionNumber(uint32 _point)
      view
      external
      returns (uint32 revision)
    {
      return points[_point].keyRevisionNumber;
    }

    //  hasBeenLinked(): returns true if the point has ever been assigned keys
    //
    function hasBeenLinked(uint32 _point)
      view
      external
      returns (bool result)
    {
      return ( points[_point].keyRevisionNumber > 0 );
    }

    //  isLive(): returns true if _point currently has keys properly configured
    //
    function isLive(uint32 _point)
      view
      external
      returns (bool result)
    {
      Point storage point = points[_point];
      return ( point.encryptionKey != 0 &&
               point.authenticationKey != 0 &&
               point.cryptoSuiteVersion != 0 );
    }

    //  getContinuityNumber(): returns _point's current continuity number
    //
    function getContinuityNumber(uint32 _point)
      view
      external
      returns (uint32 continuityNumber)
    {
      return points[_point].continuityNumber;
    }

    //  getSpawnCount(): return the number of children spawned by _point
    //
    function getSpawnCount(uint32 _point)
      view
      external
      returns (uint32 spawnCount)
    {
      uint256 len = points[_point].spawned.length;
      assert(len < 2**32);
      return uint32(len);
    }

    //  getSpawned(): return array of points created under _point
    //
    //    Note: only useful for clients, as Solidity does not currently
    //    support returning dynamic arrays.
    //
    function getSpawned(uint32 _point)
      view
      external
      returns (uint32[] spawned)
    {
      return points[_point].spawned;
    }

    //  hasSponsor(): returns true if _point's sponsor is providing it service
    //
    function hasSponsor(uint32 _point)
      view
      external
      returns (bool has)
    {
      return points[_point].hasSponsor;
    }

    //  getSponsor(): returns _point's current (or most recent) sponsor
    //
    function getSponsor(uint32 _point)
      view
      external
      returns (uint32 sponsor)
    {
      return points[_point].sponsor;
    }

    //  isSponsor(): returns true if _sponsor is currently providing service
    //               to _point
    //
    function isSponsor(uint32 _point, uint32 _sponsor)
      view
      external
      returns (bool result)
    {
      Point storage point = points[_point];
      return ( point.hasSponsor &&
               (point.sponsor == _sponsor) );
    }

    //  getSponsoringCount(): returns the number of points _sponsor is
    //                        providing service to
    //
    function getSponsoringCount(uint32 _sponsor)
      view
      external
      returns (uint256 count)
    {
      return sponsoring[_sponsor].length;
    }

    //  getSponsoring(): returns a list of points _sponsor is providing
    //                   service to
    //
    //    Note: only useful for clients, as Solidity does not currently
    //    support returning dynamic arrays.
    //
    function getSponsoring(uint32 _sponsor)
      view
      external
      returns (uint32[] sponsees)
    {
      return sponsoring[_sponsor];
    }

    //  escaping

    //  isEscaping(): returns true if _point has an outstanding escape request
    //
    function isEscaping(uint32 _point)
      view
      external
      returns (bool escaping)
    {
      return points[_point].escapeRequested;
    }

    //  getEscapeRequest(): returns _point's current escape request
    //
    //    the returned escape request is only valid as long as isEscaping()
    //    returns true
    //
    function getEscapeRequest(uint32 _point)
      view
      external
      returns (uint32 escape)
    {
      return points[_point].escapeRequestedTo;
    }

    //  isRequestingEscapeTo(): returns true if _point has an outstanding
    //                          escape request targetting _sponsor
    //
    function isRequestingEscapeTo(uint32 _point, uint32 _sponsor)
      view
      public
      returns (bool equals)
    {
      Point storage point = points[_point];
      return (point.escapeRequested && (point.escapeRequestedTo == _sponsor));
    }

    //  getEscapeRequestsCount(): returns the number of points _sponsor
    //                            is providing service to
    //
    function getEscapeRequestsCount(uint32 _sponsor)
      view
      external
      returns (uint256 count)
    {
      return escapeRequests[_sponsor].length;
    }

    //  getEscapeRequests(): get the points _sponsor has received escape
    //                       requests from
    //
    //    Note: only useful for clients, as Solidity does not currently
    //    support returning dynamic arrays.
    //
    function getEscapeRequests(uint32 _sponsor)
      view
      external
      returns (uint32[] requests)
    {
      return escapeRequests[_sponsor];
    }

  //
  //  Point writing
  //

    //  activatePoint(): activate a point, register it as spawned by its prefix
    //
    function activatePoint(uint32 _point)
      onlyOwner
      external
    {
      //  make a point active, setting its sponsor to its prefix
      //
      Point storage point = points[_point];
      require(!point.active);
      point.active = true;
      registerSponsor(_point, true, getPrefix(_point));
      emit Activated(_point);
    }

    //  setKeys(): set network public keys of _point to _encryptionKey and
    //            _authenticationKey, with the specified _cryptoSuiteVersion
    //
    function setKeys(uint32 _point,
                     bytes32 _encryptionKey,
                     bytes32 _authenticationKey,
                     uint32 _cryptoSuiteVersion)
      onlyOwner
      external
    {
      Point storage point = points[_point];
      if ( point.encryptionKey == _encryptionKey &&
           point.authenticationKey == _authenticationKey &&
           point.cryptoSuiteVersion == _cryptoSuiteVersion )
      {
        return;
      }

      point.encryptionKey = _encryptionKey;
      point.authenticationKey = _authenticationKey;
      point.cryptoSuiteVersion = _cryptoSuiteVersion;
      point.keyRevisionNumber++;

      emit ChangedKeys(_point,
                       _encryptionKey,
                       _authenticationKey,
                       _cryptoSuiteVersion,
                       point.keyRevisionNumber);
    }

    //  incrementContinuityNumber(): break continuity for _point
    //
    function incrementContinuityNumber(uint32 _point)
      onlyOwner
      external
    {
      Point storage point = points[_point];
      point.continuityNumber++;
      emit BrokeContinuity(_point, point.continuityNumber);
    }

    //  registerSpawn(): add a point to its prefix's list of spawned points
    //
    function registerSpawned(uint32 _point)
      onlyOwner
      external
    {
      //  if a point is its own prefix (a galaxy) then don't register it
      //
      uint32 prefix = getPrefix(_point);
      if (prefix == _point)
      {
        return;
      }

      //  register a new spawned point for the prefix
      //
      points[prefix].spawned.push(_point);
      emit Spawned(prefix, _point);
    }

    //  loseSponsor(): indicates that _point's sponsor is no longer providing
    //                 it service
    //
    function loseSponsor(uint32 _point)
      onlyOwner
      external
    {
      Point storage point = points[_point];
      if (!point.hasSponsor)
      {
        return;
      }
      registerSponsor(_point, false, point.sponsor);
      emit LostSponsor(_point, point.sponsor);
    }

    //  setEscapeRequest(): for _point, start an escape request to _sponsor
    //
    function setEscapeRequest(uint32 _point, uint32 _sponsor)
      onlyOwner
      external
    {
      if (isRequestingEscapeTo(_point, _sponsor))
      {
        return;
      }
      registerEscapeRequest(_point, true, _sponsor);
      emit EscapeRequested(_point, _sponsor);
    }

    //  cancelEscape(): for _point, stop the current escape request, if any
    //
    function cancelEscape(uint32 _point)
      onlyOwner
      external
    {
      Point storage point = points[_point];
      if (!point.escapeRequested)
      {
        return;
      }
      uint32 request = point.escapeRequestedTo;
      registerEscapeRequest(_point, false, 0);
      emit EscapeCanceled(_point, request);
    }

    //  doEscape(): perform the requested escape
    //
    function doEscape(uint32 _point)
      onlyOwner
      external
    {
      Point storage point = points[_point];
      require(point.escapeRequested);
      registerSponsor(_point, true, point.escapeRequestedTo);
      registerEscapeRequest(_point, false, 0);
      emit EscapeAccepted(_point, point.sponsor);
    }

  //
  //  Point utils
  //

    //  getPrefix(): compute prefix ("parent") of _point
    //
    function getPrefix(uint32 _point)
      pure
      public
      returns (uint16 prefix)
    {
      if (_point < 0x10000)
      {
        return uint16(_point % 0x100);
      }
      return uint16(_point % 0x10000);
    }

    //  getPointSize(): return the size of _point
    //
    function getPointSize(uint32 _point)
      external
      pure
      returns (Size _size)
    {
      if (_point < 0x100) return Size.Galaxy;
      if (_point < 0x10000) return Size.Star;
      return Size.Planet;
    }

    //  internal use

    //  registerSponsor(): set the sponsorship state of _point and update the
    //                     reverse lookup for sponsors
    //
    function registerSponsor(uint32 _point, bool _hasSponsor, uint32 _sponsor)
      internal
    {
      Point storage point = points[_point];
      bool had = point.hasSponsor;
      uint32 prev = point.sponsor;

      //  if we didn't have a sponsor, and won't get one,
      //  or if we get the sponsor we already have,
      //  nothing will change, so jump out early.
      //
      if ( (!had && !_hasSponsor) ||
           (had && _hasSponsor && prev == _sponsor) )
      {
        return;
      }

      //  if the point used to have a different sponsor, do some gymnastics
      //  to keep the reverse lookup gapless.  delete the point from the old
      //  sponsor's list, then fill that gap with the list tail.
      //
      if (had)
      {
        //  i: current index in previous sponsor's list of sponsored points
        //
        uint256 i = sponsoringIndexes[prev][_point];

        //  we store index + 1, because 0 is the solidity default value
        //
        assert(i > 0);
        i--;

        //  copy the last item in the list into the now-unused slot,
        //  making sure to update its :sponsoringIndexes reference
        //
        uint32[] storage prevSponsoring = sponsoring[prev];
        uint256 last = prevSponsoring.length - 1;
        uint32 moved = prevSponsoring[last];
        prevSponsoring[i] = moved;
        sponsoringIndexes[prev][moved] = i + 1;

        //  delete the last item
        //
        delete(prevSponsoring[last]);
        prevSponsoring.length = last;
        sponsoringIndexes[prev][_point] = 0;
      }

      if (_hasSponsor)
      {
        uint32[] storage newSponsoring = sponsoring[_sponsor];
        newSponsoring.push(_point);
        sponsoringIndexes[_sponsor][_point] = newSponsoring.length;
      }

      point.sponsor = _sponsor;
      point.hasSponsor = _hasSponsor;
    }

    //  registerEscapeRequest(): set the escape state of _point and update the
    //                           reverse lookup for sponsors
    //
    function registerEscapeRequest( uint32 _point,
                                    bool _isEscaping, uint32 _sponsor )
      internal
    {
      Point storage point = points[_point];
      bool was = point.escapeRequested;
      uint32 prev = point.escapeRequestedTo;

      //  if we weren't escaping, and won't be,
      //  or if we were escaping, and the new target is the same,
      //  nothing will change, so jump out early.
      //
      if ( (!was && !_isEscaping) ||
           (was && _isEscaping && prev == _sponsor) )
      {
        return;
      }

      //  if the point used to have a different request, do some gymnastics
      //  to keep the reverse lookup gapless.  delete the point from the old
      //  sponsor's list, then fill that gap with the list tail.
      //
      if (was)
      {
        //  i: current index in previous sponsor's list of sponsored points
        //
        uint256 i = escapeRequestsIndexes[prev][_point];

        //  we store index + 1, because 0 is the solidity default value
        //
        assert(i > 0);
        i--;

        //  copy the last item in the list into the now-unused slot,
        //  making sure to update its :escapeRequestsIndexes reference
        //
        uint32[] storage prevRequests = escapeRequests[prev];
        uint256 last = prevRequests.length - 1;
        uint32 moved = prevRequests[last];
        prevRequests[i] = moved;
        escapeRequestsIndexes[prev][moved] = i + 1;

        //  delete the last item
        //
        delete(prevRequests[last]);
        prevRequests.length = last;
        escapeRequestsIndexes[prev][_point] = 0;
      }

      if (_isEscaping)
      {
        uint32[] storage newRequests = escapeRequests[_sponsor];
        newRequests.push(_point);
        escapeRequestsIndexes[_sponsor][_point] = newRequests.length;
      }

      point.escapeRequestedTo = _sponsor;
      point.escapeRequested = _isEscaping;
    }

  //
  //  Deed reading
  //

    //  owner

    //  getOwner(): return owner of _point
    //
    function getOwner(uint32 _point)
      view
      external
      returns (address owner)
    {
      return rights[_point].owner;
    }

    //  isOwner(): true if _point is owned by _address
    //
    function isOwner(uint32 _point, address _address)
      view
      external
      returns (bool result)
    {
      return (rights[_point].owner == _address);
    }

    //  getOwnedPointCount(): return length of array of points that _whose owns
    //
    function getOwnedPointCount(address _whose)
      view
      external
      returns (uint256 count)
    {
      return pointsOwnedBy[_whose].length;
    }

    //  getOwnedPoints(): return array of points that _whose owns
    //
    //    Note: only useful for clients, as Solidity does not currently
    //    support returning dynamic arrays.
    //
    function getOwnedPoints(address _whose)
      view
      external
      returns (uint32[] ownedPoints)
    {
      return pointsOwnedBy[_whose];
    }

    //  getOwnedPointAtIndex(): get point at _index from array of points that
    //                         _whose owns
    //
    function getOwnedPointAtIndex(address _whose, uint256 _index)
      view
      external
      returns (uint32 point)
    {
      uint32[] storage owned = pointsOwnedBy[_whose];
      require(_index < owned.length);
      return owned[_index];
    }

    //  management proxy

    //  getManagementProxy(): returns _point's current management proxy
    //
    function getManagementProxy(uint32 _point)
      view
      external
      returns (address manager)
    {
      return rights[_point].managementProxy;
    }

    //  isManagementProxy(): returns true if _proxy is _point's management proxy
    //
    function isManagementProxy(uint32 _point, address _proxy)
      view
      external
      returns (bool result)
    {
      return (rights[_point].managementProxy == _proxy);
    }

    //  canManage(): true if _who is the owner or manager of _point
    //
    function canManage(uint32 _point, address _who)
      view
      external
      returns (bool result)
    {
      Deed storage deed = rights[_point];
      return ( (0x0 != _who) &&
               ( (_who == deed.owner) ||
                 (_who == deed.managementProxy) ) );
    }

    //  getManagerForCount(): returns the amount of points _proxy can manage
    //
    function getManagerForCount(address _proxy)
      view
      external
      returns (uint256 count)
    {
      return managerFor[_proxy].length;
    }

    //  getManagerFor(): returns the points _proxy can manage
    //
    //    Note: only useful for clients, as Solidity does not currently
    //    support returning dynamic arrays.
    //
    function getManagerFor(address _proxy)
      view
      external
      returns (uint32[] mfor)
    {
      return managerFor[_proxy];
    }

    //  spawn proxy

    //  getSpawnProxy(): returns _point's current spawn proxy
    //
    function getSpawnProxy(uint32 _point)
      view
      external
      returns (address spawnProxy)
    {
      return rights[_point].spawnProxy;
    }

    //  isSpawnProxy(): returns true if _proxy is _point's spawn proxy
    //
    function isSpawnProxy(uint32 _point, address _proxy)
      view
      external
      returns (bool result)
    {
      return (rights[_point].spawnProxy == _proxy);
    }

    //  canSpawnAs(): true if _who is the owner or spawn proxy of _point
    //
    function canSpawnAs(uint32 _point, address _who)
      view
      external
      returns (bool result)
    {
      Deed storage deed = rights[_point];
      return ( (0x0 != _who) &&
               ( (_who == deed.owner) ||
                 (_who == deed.spawnProxy) ) );
    }

    //  getSpawningForCount(): returns the amount of points _proxy
    //                         can spawn with
    //
    function getSpawningForCount(address _proxy)
      view
      external
      returns (uint256 count)
    {
      return spawningFor[_proxy].length;
    }

    //  getSpawningFor(): get the points _proxy can spawn with
    //
    //    Note: only useful for clients, as Solidity does not currently
    //    support returning dynamic arrays.
    //
    function getSpawningFor(address _proxy)
      view
      external
      returns (uint32[] sfor)
    {
      return spawningFor[_proxy];
    }

    //  voting proxy

    //  getVotingProxy(): returns _point's current voting proxy
    //
    function getVotingProxy(uint32 _point)
      view
      external
      returns (address voter)
    {
      return rights[_point].votingProxy;
    }

    //  isVotingProxy(): returns true if _proxy is _point's voting proxy
    //
    function isVotingProxy(uint32 _point, address _proxy)
      view
      external
      returns (bool result)
    {
      return (rights[_point].votingProxy == _proxy);
    }

    //  canVoteAs(): true if _who is the owner of _point,
    //               or the voting proxy of _point's owner
    //
    function canVoteAs(uint32 _point, address _who)
      view
      external
      returns (bool result)
    {
      Deed storage deed = rights[_point];
      return ( (0x0 != _who) &&
               ( (_who == deed.owner) ||
                 (_who == deed.votingProxy) ) );
    }

    //  getVotingForCount(): returns the amount of points _proxy can vote as
    //
    function getVotingForCount(address _proxy)
      view
      external
      returns (uint256 count)
    {
      return votingFor[_proxy].length;
    }

    //  getVotingFor(): returns the points _proxy can vote as
    //
    //    Note: only useful for clients, as Solidity does not currently
    //    support returning dynamic arrays.
    //
    function getVotingFor(address _proxy)
      view
      external
      returns (uint32[] vfor)
    {
      return votingFor[_proxy];
    }

    //  transfer proxy

    //  getTransferProxy(): returns _point's current transfer proxy
    //
    function getTransferProxy(uint32 _point)
      view
      external
      returns (address transferProxy)
    {
      return rights[_point].transferProxy;
    }

    //  isTransferProxy(): returns true if _proxy is _point's transfer proxy
    //
    function isTransferProxy(uint32 _point, address _proxy)
      view
      external
      returns (bool result)
    {
      return (rights[_point].transferProxy == _proxy);
    }

    //  canTransfer(): true if _who is the owner or transfer proxy of _point,
    //                 or is an operator for _point's current owner
    //
    function canTransfer(uint32 _point, address _who)
      view
      external
      returns (bool result)
    {
      Deed storage deed = rights[_point];
      return ( (0x0 != _who) &&
               ( (_who == deed.owner) ||
                 (_who == deed.transferProxy) ||
                 operators[deed.owner][_who] ) );
    }

    //  getTransferringForCount(): returns the amount of points _proxy
    //                             can transfer
    //
    function getTransferringForCount(address _proxy)
      view
      external
      returns (uint256 count)
    {
      return transferringFor[_proxy].length;
    }

    //  getTransferringFor(): get the points _proxy can transfer
    //
    //    Note: only useful for clients, as Solidity does not currently
    //    support returning dynamic arrays.
    //
    function getTransferringFor(address _proxy)
      view
      external
      returns (uint32[] tfor)
    {
      return transferringFor[_proxy];
    }

    //  isOperator(): returns true if _operator is allowed to transfer
    //                ownership of _owner's points
    //
    function isOperator(address _owner, address _operator)
      view
      external
      returns (bool result)
    {
      return operators[_owner][_operator];
    }

  //
  //  Deed writing
  //

    //  setOwner(): set owner of _point to _owner
    //
    //    Note: setOwner() only implements the minimal data storage
    //    logic for a transfer; the full transfer is implemented in
    //    Ecliptic.
    //
    //    Note: _owner must not be the zero address.
    //
    function setOwner(uint32 _point, address _owner)
      onlyOwner
      external
    {
      //  prevent burning of points by making zero the owner
      //
      require(0x0 != _owner);

      //  prev: previous owner, if any
      //
      address prev = rights[_point].owner;

      if (prev == _owner)
      {
        return;
      }

      //  if the point used to have a different owner, do some gymnastics to
      //  keep the list of owned points gapless.  delete this point from the
      //  list, then fill that gap with the list tail.
      //
      if (0x0 != prev)
      {
        //  i: current index in previous owner's list of owned points
        //
        uint256 i = pointOwnerIndexes[prev][_point];

        //  we store index + 1, because 0 is the solidity default value
        //
        assert(i > 0);
        i--;

        //  copy the last item in the list into the now-unused slot,
        //  making sure to update its :pointOwnerIndexes reference
        //
        uint32[] storage owner = pointsOwnedBy[prev];
        uint256 last = owner.length - 1;
        uint32 moved = owner[last];
        owner[i] = moved;
        pointOwnerIndexes[prev][moved] = i + 1;

        //  delete the last item
        //
        delete(owner[last]);
        owner.length = last;
        pointOwnerIndexes[prev][_point] = 0;
      }

      //  update the owner list and the owner's index list
      //
      rights[_point].owner = _owner;
      pointsOwnedBy[_owner].push(_point);
      pointOwnerIndexes[_owner][_point] = pointsOwnedBy[_owner].length;
      emit OwnerChanged(_point, _owner);
    }

    //  setManagementProxy(): makes _proxy _point's management proxy
    //
    function setManagementProxy(uint32 _point, address _proxy)
      onlyOwner
      external
    {
      Deed storage deed = rights[_point];
      address prev = deed.managementProxy;
      if (prev == _proxy)
      {
        return;
      }

      //  if the point used to have a different manager, do some gymnastics
      //  to keep the reverse lookup gapless.  delete the point from the
      //  old manager's list, then fill that gap with the list tail.
      //
      if (0x0 != prev)
      {
        //  i: current index in previous manager's list of managed points
        //
        uint256 i = managerForIndexes[prev][_point];

        //  we store index + 1, because 0 is the solidity default value
        //
        assert(i > 0);
        i--;

        //  copy the last item in the list into the now-unused slot,
        //  making sure to update its :managerForIndexes reference
        //
        uint32[] storage prevMfor = managerFor[prev];
        uint256 last = prevMfor.length - 1;
        uint32 moved = prevMfor[last];
        prevMfor[i] = moved;
        managerForIndexes[prev][moved] = i + 1;

        //  delete the last item
        //
        delete(prevMfor[last]);
        prevMfor.length = last;
        managerForIndexes[prev][_point] = 0;
      }

      if (0x0 != _proxy)
      {
        uint32[] storage mfor = managerFor[_proxy];
        mfor.push(_point);
        managerForIndexes[_proxy][_point] = mfor.length;
      }

      deed.managementProxy = _proxy;
      emit ChangedManagementProxy(_point, _proxy);
    }

    //  setSpawnProxy(): makes _proxy _point's spawn proxy
    //
    function setSpawnProxy(uint32 _point, address _proxy)
      onlyOwner
      external
    {
      Deed storage deed = rights[_point];
      address prev = deed.spawnProxy;
      if (prev == _proxy)
      {
        return;
      }

      //  if the point used to have a different spawn proxy, do some
      //  gymnastics to keep the reverse lookup gapless.  delete the point
      //  from the old proxy's list, then fill that gap with the list tail.
      //
      if (0x0 != prev)
      {
        //  i: current index in previous proxy's list of spawning points
        //
        uint256 i = spawningForIndexes[prev][_point];

        //  we store index + 1, because 0 is the solidity default value
        //
        assert(i > 0);
        i--;

        //  copy the last item in the list into the now-unused slot,
        //  making sure to update its :spawningForIndexes reference
        //
        uint32[] storage prevSfor = spawningFor[prev];
        uint256 last = prevSfor.length - 1;
        uint32 moved = prevSfor[last];
        prevSfor[i] = moved;
        spawningForIndexes[prev][moved] = i + 1;

        //  delete the last item
        //
        delete(prevSfor[last]);
        prevSfor.length = last;
        spawningForIndexes[prev][_point] = 0;
      }

      if (0x0 != _proxy)
      {
        uint32[] storage sfor = spawningFor[_proxy];
        sfor.push(_point);
        spawningForIndexes[_proxy][_point] = sfor.length;
      }

      deed.spawnProxy = _proxy;
      emit ChangedSpawnProxy(_point, _proxy);
    }

    //  setVotingProxy(): makes _proxy _point's voting proxy
    //
    function setVotingProxy(uint32 _point, address _proxy)
      onlyOwner
      external
    {
      Deed storage deed = rights[_point];
      address prev = deed.votingProxy;
      if (prev == _proxy)
      {
        return;
      }

      //  if the point used to have a different voter, do some gymnastics
      //  to keep the reverse lookup gapless.  delete the point from the
      //  old voter's list, then fill that gap with the list tail.
      //
      if (0x0 != prev)
      {
        //  i: current index in previous voter's list of points it was
        //     voting for
        //
        uint256 i = votingForIndexes[prev][_point];

        //  we store index + 1, because 0 is the solidity default value
        //
        assert(i > 0);
        i--;

        //  copy the last item in the list into the now-unused slot,
        //  making sure to update its :votingForIndexes reference
        //
        uint32[] storage prevVfor = votingFor[prev];
        uint256 last = prevVfor.length - 1;
        uint32 moved = prevVfor[last];
        prevVfor[i] = moved;
        votingForIndexes[prev][moved] = i + 1;

        //  delete the last item
        //
        delete(prevVfor[last]);
        prevVfor.length = last;
        votingForIndexes[prev][_point] = 0;
      }

      if (0x0 != _proxy)
      {
        uint32[] storage vfor = votingFor[_proxy];
        vfor.push(_point);
        votingForIndexes[_proxy][_point] = vfor.length;
      }

      deed.votingProxy = _proxy;
      emit ChangedVotingProxy(_point, _proxy);
    }

    //  setManagementProxy(): makes _proxy _point's transfer proxy
    //
    function setTransferProxy(uint32 _point, address _proxy)
      onlyOwner
      external
    {
      Deed storage deed = rights[_point];
      address prev = deed.transferProxy;
      if (prev == _proxy)
      {
        return;
      }

      //  if the point used to have a different transfer proxy, do some
      //  gymnastics to keep the reverse lookup gapless.  delete the point
      //  from the old proxy's list, then fill that gap with the list tail.
      //
      if (0x0 != prev)
      {
        //  i: current index in previous proxy's list of transferable points
        //
        uint256 i = transferringForIndexes[prev][_point];

        //  we store index + 1, because 0 is the solidity default value
        //
        assert(i > 0);
        i--;

        //  copy the last item in the list into the now-unused slot,
        //  making sure to update its :transferringForIndexes reference
        //
        uint32[] storage prevTfor = transferringFor[prev];
        uint256 last = prevTfor.length - 1;
        uint32 moved = prevTfor[last];
        prevTfor[i] = moved;
        transferringForIndexes[prev][moved] = i + 1;

        //  delete the last item
        //
        delete(prevTfor[last]);
        prevTfor.length = last;
        transferringForIndexes[prev][_point] = 0;
      }

      if (0x0 != _proxy)
      {
        uint32[] storage tfor = transferringFor[_proxy];
        tfor.push(_point);
        transferringForIndexes[_proxy][_point] = tfor.length;
      }

      deed.transferProxy = _proxy;
      emit ChangedTransferProxy(_point, _proxy);
    }

    //  setOperator(): dis/allow _operator to transfer ownership of all points
    //                 owned by _owner
    //
    //    operators are part of the ERC721 standard
    //
    function setOperator(address _owner, address _operator, bool _approved)
      onlyOwner
      external
    {
      operators[_owner][_operator] = _approved;
    }
}

// Azimuth's ReadsAzimuth.sol

//  ReadsAzimuth: referring to and testing against the Azimuth
//                data contract
//
//    To avoid needless repetition, this contract provides common
//    checks and operations using the Azimuth contract.
//
contract ReadsAzimuth
{
  //  azimuth: points data storage contract.
  //
  Azimuth public azimuth;

  //  constructor(): set the Azimuth data contract's address
  //
  constructor(Azimuth _azimuth)
    public
  {
    azimuth = _azimuth;
  }

  //  activePointOwner(): require that :msg.sender is the owner of _point,
  //                      and that _point is active
  //
  modifier activePointOwner(uint32 _point)
  {
    require( azimuth.isOwner(_point, msg.sender) &&
             azimuth.isActive(_point) );
    _;
  }

  //  activePointManager(): require that :msg.sender can manage _point,
  //                        and that _point is active
  //
  modifier activePointManager(uint32 _point)
  {
    require( azimuth.canManage(_point, msg.sender) &&
             azimuth.isActive(_point) );
    _;
  }
}

////////////////////////////////////////////////////////////////////////////////
//  Claims
////////////////////////////////////////////////////////////////////////////////

//  Claims: simple identity management
//
//    This contract allows points to document claims about their owner.
//    Most commonly, these are about identity, with a claim's protocol
//    defining the context or platform of the claim, and its dossier
//    containing proof of its validity.
//    Points are limited to a maximum of 16 claims.
//
//    For existing claims, the dossier can be updated, or the claim can
//    be removed entirely. It is recommended to remove any claims associated
//    with a point when it is about to be transferred to a new owner.
//    For convenience, the owner of the Azimuth contract (the Ecliptic)
//    is allowed to clear claims for any point, allowing it to do this for
//    you on-transfer.
//
contract Claims is ReadsAzimuth
{
  //  ClaimAdded: a claim was added by :by
  //
  event ClaimAdded( uint32 indexed by,
                    string _protocol,
                    string _claim,
                    bytes _dossier );

  //  ClaimRemoved: a claim was removed by :by
  //
  event ClaimRemoved(uint32 indexed by, string _protocol, string _claim);

  //  maxClaims: the amount of claims that can be registered per point
  //
  uint8 constant maxClaims = 16;

  //  Claim: claim details
  //
  struct Claim
  {
    //  protocol: context of the claim
    //
    string protocol;

    //  claim: the claim itself
    //
    string claim;

    //  dossier: data relating to the claim, as proof
    //
    bytes dossier;
  }

  //  per point, list of claims
  //
  mapping(uint32 => Claim[maxClaims]) public claims;

  //  constructor(): register the azimuth contract.
  //
  constructor(Azimuth _azimuth)
    ReadsAzimuth(_azimuth)
    public
  {
    //
  }

  //  addClaim(): register a claim as _point
  //
  function addClaim(uint32 _point,
                    string _protocol,
                    string _claim,
                    bytes _dossier)
    external
    activePointManager(_point)
  {
    //  require non-empty protocol and claim fields
    //
    require( ( 0 < bytes(_protocol).length ) &&
             ( 0 < bytes(_claim).length ) );

    //  cur: index + 1 of the claim if it already exists, 0 otherwise
    //
    uint8 cur = findClaim(_point, _protocol, _claim);

    //  if the claim doesn't yet exist, store it in state
    //
    if (cur == 0)
    {
      //  if there are no empty slots left, this throws
      //
      uint8 empty = findEmptySlot(_point);
      claims[_point][empty] = Claim(_protocol, _claim, _dossier);
    }
    //
    //  if the claim has been made before, update the version in state
    //
    else
    {
      claims[_point][cur-1] = Claim(_protocol, _claim, _dossier);
    }
    emit ClaimAdded(_point, _protocol, _claim, _dossier);
  }

  //  removeClaim(): unregister a claim as _point
  //
  function removeClaim(uint32 _point, string _protocol, string _claim)
    external
    activePointManager(_point)
  {
    //  i: current index + 1 in _point's list of claims
    //
    uint256 i = findClaim(_point, _protocol, _claim);

    //  we store index + 1, because 0 is the eth default value
    //  can only delete an existing claim
    //
    require(i > 0);
    i--;

    //  clear out the claim
    //
    delete claims[_point][i];

    emit ClaimRemoved(_point, _protocol, _claim);
  }

  //  clearClaims(): unregister all of _point's claims
  //
  //    can also be called by the ecliptic during point transfer
  //
  function clearClaims(uint32 _point)
    external
  {
    //  both point owner and ecliptic may do this
    //
    //    We do not necessarily need to check for _point's active flag here,
    //    since inactive points cannot have claims set. Doing the check
    //    anyway would make this function slightly harder to think about due
    //    to its relation to Ecliptic's transferPoint().
    //
    require( azimuth.canManage(_point, msg.sender) ||
             ( msg.sender == azimuth.owner() ) );

    Claim[maxClaims] storage currClaims = claims[_point];

    //  clear out all claims
    //
    for (uint8 i = 0; i < maxClaims; i++)
    {
      //  only emit the removed event if there was a claim here
      //
      if ( 0 < bytes(currClaims[i].claim).length )
      {
        emit ClaimRemoved(_point, currClaims[i].protocol, currClaims[i].claim);
      }

      delete currClaims[i];
    }
  }

  //  findClaim(): find the index of the specified claim
  //
  //    returns 0 if not found, index + 1 otherwise
  //
  function findClaim(uint32 _whose, string _protocol, string _claim)
    public
    view
    returns (uint8 index)
  {
    //  we use hashes of the string because solidity can't do string
    //  comparison yet
    //
    bytes32 protocolHash = keccak256(bytes(_protocol));
    bytes32 claimHash = keccak256(bytes(_claim));
    Claim[maxClaims] storage theirClaims = claims[_whose];
    for (uint8 i = 0; i < maxClaims; i++)
    {
      Claim storage thisClaim = theirClaims[i];
      if ( ( protocolHash == keccak256(bytes(thisClaim.protocol)) ) &&
           ( claimHash == keccak256(bytes(thisClaim.claim)) ) )
      {
        return i+1;
      }
    }
    return 0;
  }

  //  findEmptySlot(): find the index of the first empty claim slot
  //
  //    returns the index of the slot, throws if there are no empty slots
  //
  function findEmptySlot(uint32 _whose)
    internal
    view
    returns (uint8 index)
  {
    Claim[maxClaims] storage theirClaims = claims[_whose];
    for (uint8 i = 0; i < maxClaims; i++)
    {
      Claim storage thisClaim = theirClaims[i];
      if ( (0 == bytes(thisClaim.claim).length) )
      {
        return i;
      }
    }
    revert();
  }
}