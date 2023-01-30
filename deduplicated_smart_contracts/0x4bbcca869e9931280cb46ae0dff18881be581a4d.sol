/**
 *Submitted for verification at Etherscan.io on 2019-12-21
*/

pragma solidity >=0.5.0 <0.6.0;

contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"
    event Upgraded(address indexed implementation);

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
        emit Upgraded(newAddress);
    }
    function proxiableUUID() public pure returns (bytes32) {
        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

interface ERC20Token {

    /**
     * @notice send `_value` token to `_to` from `msg.sender`
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint256 _value) external returns (bool success);

    /**
     * @notice `msg.sender` approves `_spender` to spend `_value` tokens
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint256 _value) external returns (bool success);

    /**
     * @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /**
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) external view returns (uint256 balance);

    /**
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    /**
     * @notice return total supply of tokens
     */
    function totalSupply() external view returns (uint256 supply);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Get the contract's owner
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Only the contract's owner can invoke this function");
        _;
    }

     /**
      * @dev Sets an owner address
      * @param _newOwner new owner address
      */
    function _setOwner(address _newOwner) internal {
        _owner = _newOwner;
    }

    /**
     * @dev is sender the owner of the contract?
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     *      Renouncing to ownership will leave the contract without an owner.
     *      It will not be possible to call the functions with the `onlyOwner`
     *      modifier anymore.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "New owner cannot be address(0)");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes memory _data) public;
}





contract SafeTransfer {
    function _safeTransfer(ERC20Token _token, address _to, uint256 _value) internal returns (bool result) {
        _token.transfer(_to, _value);
        assembly {
        switch returndatasize()
            case 0 {
            result := not(0)
            }
            case 32 {
            returndatacopy(0, 0, 32)
            result := mload(0)
            }
            default {
            revert(0, 0)
            }
        }
        require(result, "Unsuccessful token transfer");
    }

    function _safeTransferFrom(
        ERC20Token _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool result)
    {
        _token.transferFrom(_from, _to, _value);
        assembly {
        switch returndatasize()
            case 0 {
            result := not(0)
            }
            case 32 {
            returndatacopy(0, 0, 32)
            result := mload(0)
            }
            default {
            revert(0, 0)
            }
        }
        require(result, "Unsuccessful token transfer");
    }
}

contract IEscrow {

  enum EscrowStatus {CREATED, FUNDED, PAID, RELEASED, CANCELED}

  struct EscrowTransaction {
      uint256 offerId;
      address token;
      uint256 tokenAmount;
      uint256 expirationTime;
      uint256 sellerRating;
      uint256 buyerRating;
      uint256 fiatAmount;
      address payable buyer;
      address payable seller;
      address payable arbitrator;
      EscrowStatus status;
  }

  function createEscrow_relayed(
        address payable _sender,
        uint _offerId,
        uint _tokenAmount,
        uint _fiatAmount,
        string calldata _contactData,
        string calldata _location,
        string calldata _username
    ) external returns(uint escrowId);

  function pay(uint _escrowId) external;

  function pay_relayed(address _sender, uint _escrowId) external;

  function cancel(uint _escrowId) external;

  function cancel_relayed(address _sender, uint _escrowId) external;

  function openCase(uint  _escrowId, uint8 _motive) external;

  function openCase_relayed(address _sender, uint256 _escrowId, uint8 _motive) external;

  function rateTransaction(uint _escrowId, uint _rate) external;

  function rateTransaction_relayed(address _sender, uint _escrowId, uint _rate) external;

  function getBasicTradeData(uint _escrowId) external view returns(address payable buyer, address payable seller, address token, uint tokenAmount);

}
/* solium-disable security/no-block-members */
/* solium-disable security/no-inline-assembly */
/* solium-disable no-empty-blocks */






/* solium-disable security/no-block-members */
/* solium-disable security/no-inline-assembly */








/**
* @title License
* @dev Contract for buying a license
*/
contract License is Ownable, ApproveAndCallFallBack, SafeTransfer, Proxiable {
    uint256 public price;

    ERC20Token token;
    address burnAddress;

    struct LicenseDetails {
        uint price;
        uint creationTime;
    }

    address[] public licenseOwners;
    mapping(address => uint) public idxLicenseOwners;
    mapping(address => LicenseDetails) public licenseDetails;

    event Bought(address buyer, uint256 price);
    event PriceChanged(uint256 _price);

    bool internal _initialized;

    /**
     * @param _tokenAddress Address of token used to pay for licenses (SNT)
     * @param _price Price of the licenses
     * @param _burnAddress Address where the license fee is going to be sent
     */
    constructor(address _tokenAddress, uint256 _price, address _burnAddress) public {
        init(_tokenAddress, _price, _burnAddress);
    }

    /**
     * @dev Initialize contract (used with proxy). Can only be called once
     * @param _tokenAddress Address of token used to pay for licenses (SNT)
     * @param _price Price of the licenses
     * @param _burnAddress Address where the license fee is going to be sent
     */
    function init(
        address _tokenAddress,
        uint256 _price,
        address _burnAddress
    ) public {
        assert(_initialized == false);

        _initialized = true;

        price = _price;
        token = ERC20Token(_tokenAddress);
        burnAddress = _burnAddress;

        _setOwner(msg.sender);
    }

    function updateCode(address newCode) public onlyOwner {
        updateCodeAddress(newCode);
    }

    /**
     * @notice Check if the address already owns a license
     * @param _address The address to check
     * @return bool
     */
    function isLicenseOwner(address _address) public view returns (bool) {
        return licenseDetails[_address].price != 0 && licenseDetails[_address].creationTime != 0;
    }

    /**
     * @notice Buy a license
     * @dev Requires value to be equal to the price of the license.
     *      The msg.sender must not already own a license.
     */
    function buy() external returns(uint) {
        uint id = _buyFrom(msg.sender);
        return id;
    }

    /**
     * @notice Buy a license
     * @dev Requires value to be equal to the price of the license.
     *      The _owner must not already own a license.
     */
    function _buyFrom(address _licenseOwner) internal returns(uint) {
        require(licenseDetails[_licenseOwner].creationTime == 0, "License already bought");

        licenseDetails[_licenseOwner] = LicenseDetails({
            price: price,
            creationTime: block.timestamp
        });

        uint idx = licenseOwners.push(_licenseOwner);
        idxLicenseOwners[_licenseOwner] = idx;

        emit Bought(_licenseOwner, price);

        require(_safeTransferFrom(token, _licenseOwner, burnAddress, price), "Unsuccessful token transfer");

        return idx;
    }

    /**
     * @notice Set the license price
     * @param _price The new price of the license
     * @dev Only the owner of the contract can perform this action
    */
    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
        emit PriceChanged(_price);
    }

    /**
     * @dev Get number of license owners
     * @return uint
     */
    function getNumLicenseOwners() external view returns (uint256) {
        return licenseOwners.length;
    }

    /**
     * @notice Support for "approveAndCall". Callable only by `token()`.
     * @param _from Who approved.
     * @param _amount Amount being approved, need to be equal `price()`.
     * @param _token Token being approved, need to be equal `token()`.
     * @param _data Abi encoded data with selector of `buy(and)`.
     */
    function receiveApproval(address _from, uint256 _amount, address _token, bytes memory _data) public {
        require(_amount == price, "Wrong value");
        require(_token == address(token), "Wrong token");
        require(_token == address(msg.sender), "Wrong call");
        require(_data.length == 4, "Wrong data length");

        require(_abiDecodeBuy(_data) == bytes4(0xa6f2ae3a), "Wrong method selector"); //bytes4(keccak256("buy()"))

        _buyFrom(_from);
    }

    /**
     * @dev Decodes abi encoded data with selector for "buy()".
     * @param _data Abi encoded data.
     * @return Decoded registry call.
     */
    function _abiDecodeBuy(bytes memory _data) internal pure returns(bytes4 sig) {
        assembly {
            sig := mload(add(_data, add(0x20, 0)))
        }
    }
}

/* solium-disable security/no-block-members */




/**
* @title ArbitratorLicense
* @dev Contract for management of an arbitrator license
*/
contract ArbitrationLicense is License {

    enum RequestStatus {NONE,AWAIT,ACCEPTED,REJECTED,CLOSED}

    struct Request{
        address seller;
        address arbitrator;
        RequestStatus status;
        uint date;
    }

	struct ArbitratorLicenseDetails {
        uint id;
        bool acceptAny;// accept any seller
    }

    mapping(address => ArbitratorLicenseDetails) public arbitratorlicenseDetails;
    mapping(address => mapping(address => bool)) public permissions;
    mapping(address => mapping(address => bool)) public blacklist;
    mapping(bytes32 => Request) public requests;

    event ArbitratorRequested(bytes32 id, address indexed seller, address indexed arbitrator);

    event RequestAccepted(bytes32 id, address indexed arbitrator, address indexed seller);
    event RequestRejected(bytes32 id, address indexed arbitrator, address indexed seller);
    event RequestCanceled(bytes32 id, address indexed arbitrator, address indexed seller);
    event BlacklistSeller(address indexed arbitrator, address indexed seller);
    event UnBlacklistSeller(address indexed arbitrator, address indexed seller);

    /**
     * @param _tokenAddress Address of token used to pay for licenses (SNT)
     * @param _price Amount of token needed to buy a license
     * @param _burnAddress Burn address where the price of the license is sent
     */
    constructor(address _tokenAddress, uint256 _price, address _burnAddress)
      License(_tokenAddress, _price, _burnAddress)
      public {}

    /**
     * @notice Buy an arbitrator license
     */
    function buy() external returns(uint) {
        return _buy(msg.sender, false);
    }

    /**
     * @notice Buy an arbitrator license and set if the arbitrator accepts any seller
     * @param _acceptAny When set to true, all sellers are accepted by the arbitrator
     */
    function buy(bool _acceptAny) external returns(uint) {
        return _buy(msg.sender, _acceptAny);
    }

    /**
     * @notice Buy an arbitrator license and set if the arbitrator accepts any seller. Sets the arbitrator as the address in params instead of the sender
     * @param _sender Address of the arbitrator
     * @param _acceptAny When set to true, all sellers are accepted by the arbitrator
     */
    function _buy(address _sender, bool _acceptAny) internal returns (uint id) {
        id = _buyFrom(_sender);
        arbitratorlicenseDetails[_sender].id = id;
        arbitratorlicenseDetails[_sender].acceptAny = _acceptAny;
    }

    /**
     * @notice Change acceptAny parameter for arbitrator
     * @param _acceptAny indicates does arbitrator allow to accept any seller/choose sellers
     */
    function changeAcceptAny(bool _acceptAny) public {
        require(isLicenseOwner(msg.sender), "Message sender should have a valid arbitrator license");
        require(arbitratorlicenseDetails[msg.sender].acceptAny != _acceptAny,
                "Message sender should pass parameter different from the current one");

        arbitratorlicenseDetails[msg.sender].acceptAny = _acceptAny;
    }

    /**
     * @notice Allows arbitrator to accept a seller
     * @param _arbitrator address of a licensed arbitrator
     */
    function requestArbitrator(address _arbitrator) public {
       require(isLicenseOwner(_arbitrator), "Arbitrator should have a valid license");
       require(!arbitratorlicenseDetails[_arbitrator].acceptAny, "Arbitrator already accepts all cases");

       bytes32 _id = keccak256(abi.encodePacked(_arbitrator, msg.sender));
       RequestStatus _status = requests[_id].status;
       require(_status != RequestStatus.AWAIT && _status != RequestStatus.ACCEPTED, "Invalid request status");

       if(_status == RequestStatus.REJECTED || _status == RequestStatus.CLOSED){
           require(requests[_id].date + 3 days < block.timestamp,
            "Must wait 3 days before requesting the arbitrator again");
       }

       requests[_id] = Request({
            seller: msg.sender,
            arbitrator: _arbitrator,
            status: RequestStatus.AWAIT,
            date: block.timestamp
       });

       emit ArbitratorRequested(_id, msg.sender, _arbitrator);
    }

    /**
     * @dev Get Request Id
     * @param _arbitrator Arbitrator address
     * @param _account Seller account
     * @return Request Id
     */
    function getId(address _arbitrator, address _account) external pure returns(bytes32){
        return keccak256(abi.encodePacked(_arbitrator,_account));
    }

    /**
     * @notice Allows arbitrator to accept a seller's request
     * @param _id request id
     */
    function acceptRequest(bytes32 _id) public {
        require(isLicenseOwner(msg.sender), "Arbitrator should have a valid license");
        require(requests[_id].status == RequestStatus.AWAIT, "This request is not pending");
        require(!arbitratorlicenseDetails[msg.sender].acceptAny, "Arbitrator already accepts all cases");
        require(requests[_id].arbitrator == msg.sender, "Invalid arbitrator");

        requests[_id].status = RequestStatus.ACCEPTED;

        address _seller = requests[_id].seller;
        permissions[msg.sender][_seller] = true;

        emit RequestAccepted(_id, msg.sender, requests[_id].seller);
    }

    /**
     * @notice Allows arbitrator to reject a request
     * @param _id request id
     */
    function rejectRequest(bytes32 _id) public {
        require(isLicenseOwner(msg.sender), "Arbitrator should have a valid license");
        require(requests[_id].status == RequestStatus.AWAIT || requests[_id].status == RequestStatus.ACCEPTED,
            "Invalid request status");
        require(!arbitratorlicenseDetails[msg.sender].acceptAny, "Arbitrator accepts all cases");
        require(requests[_id].arbitrator == msg.sender, "Invalid arbitrator");

        requests[_id].status = RequestStatus.REJECTED;
        requests[_id].date = block.timestamp;

        address _seller = requests[_id].seller;
        permissions[msg.sender][_seller] = false;

        emit RequestRejected(_id, msg.sender, requests[_id].seller);
    }

    /**
     * @notice Allows seller to cancel a request
     * @param _id request id
     */
    function cancelRequest(bytes32 _id) public {
        require(requests[_id].seller == msg.sender,  "This request id does not belong to the message sender");
        require(requests[_id].status == RequestStatus.AWAIT || requests[_id].status == RequestStatus.ACCEPTED, "Invalid request status");

        address arbitrator = requests[_id].arbitrator;

        requests[_id].status = RequestStatus.CLOSED;
        requests[_id].date = block.timestamp;

        address _arbitrator = requests[_id].arbitrator;
        permissions[_arbitrator][msg.sender] = false;

        emit RequestCanceled(_id, arbitrator, requests[_id].seller);
    }

    /**
     * @notice Allows arbitrator to blacklist a seller
     * @param _seller Seller address
     */
    function blacklistSeller(address _seller) public {
        require(isLicenseOwner(msg.sender), "Arbitrator should have a valid license");

        blacklist[msg.sender][_seller] = true;

        emit BlacklistSeller(msg.sender, _seller);
    }

    /**
     * @notice Allows arbitrator to remove a seller from the blacklist
     * @param _seller Seller address
     */
    function unBlacklistSeller(address _seller) public {
        require(isLicenseOwner(msg.sender), "Arbitrator should have a valid license");

        blacklist[msg.sender][_seller] = false;

        emit UnBlacklistSeller(msg.sender, _seller);
    }

    /**
     * @notice Checks if Arbitrator permits to use his/her services
     * @param _seller sellers's address
     * @param _arbitrator arbitrator's address
     */
    function isAllowed(address _seller, address _arbitrator) public view returns(bool) {
        return (arbitratorlicenseDetails[_arbitrator].acceptAny && !blacklist[_arbitrator][_seller]) || permissions[_arbitrator][_seller];
    }

    /**
     * @notice Support for "approveAndCall". Callable only by `token()`.
     * @param _from Who approved.
     * @param _amount Amount being approved, need to be equal `price()`.
     * @param _token Token being approved, need to be equal `token()`.
     * @param _data Abi encoded data with selector of `buy(and)`.
     */
    function receiveApproval(address _from, uint256 _amount, address _token, bytes memory _data) public {
        require(_amount == price, "Wrong value");
        require(_token == address(token), "Wrong token");
        require(_token == address(msg.sender), "Wrong call");
        require(_data.length == 4, "Wrong data length");

        require(_abiDecodeBuy(_data) == bytes4(0xa6f2ae3a), "Wrong method selector"); //bytes4(keccak256("buy()"))

        _buy(_from, false);
    }
}

/* solium-disable no-empty-blocks */
/* solium-disable security/no-inline-assembly */



/**
 * @dev Uses ethereum signed messages
 */
contract MessageSigned {

    constructor() internal {}

    /**
     * @dev recovers address who signed the message
     * @param _signHash operation ethereum signed message hash
     * @param _messageSignature message `_signHash` signature
     */
    function _recoverAddress(bytes32 _signHash, bytes memory _messageSignature)
        internal
        pure
        returns(address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v,r,s) = signatureSplit(_messageSignature);
        return ecrecover(_signHash, v, r, s);
    }

    /**
     * @dev Hash a hash with `"\x19Ethereum Signed Message:\n32"`
     * @param _hash Sign to hash.
     * @return Hash to be signed.
     */
    function _getSignHash(bytes32 _hash) internal pure returns (bytes32 signHash) {
        signHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

    /**
     * @dev divides bytes signature into `uint8 v, bytes32 r, bytes32 s`
     * @param _signature Signature string
     */
    function signatureSplit(bytes memory _signature)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(_signature.length == 65, "Bad signature length");
        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            // Here we are loading the last 32 bytes, including 31 bytes
            // of 's'. There is no 'mload8' to do this.
            //
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            v := and(mload(add(_signature, 65)), 0xff)
        }
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "Bad signature version");
    }
}




contract SecuredFunctions is Ownable {

    mapping(address => bool) public allowedContracts;

    /// @notice Only allowed addresses and the same contract can invoke this function
    modifier onlyAllowedContracts {
        require(allowedContracts[msg.sender] || msg.sender == address(this), "Only allowed contracts can invoke this function");
        _;
    }

    /**
     * @dev Set contract addresses with special privileges to execute special functions
     * @param _contract Contract address
     * @param _allowed Is contract allowed?
     */
    function setAllowedContract (
        address _contract,
        bool _allowed
    ) public onlyOwner {
        allowedContracts[_contract] = _allowed;
    }
}








contract Stakable is Ownable, SafeTransfer {

    uint public basePrice = 0.01 ether;

    address payable public burnAddress;

    struct Stake {
        uint amount;
        address payable owner;
        address token;
    }

    mapping(uint => Stake) public stakes;
    mapping(address => uint) public stakeCounter;

    event BurnAddressChanged(address sender, address prevBurnAddress, address newBurnAddress);
    event BasePriceChanged(address sender, uint prevPrice, uint newPrice);

    event Staked(uint indexed itemId, address indexed owner, uint amount);
    event Unstaked(uint indexed itemId, address indexed owner, uint amount);
    event Slashed(uint indexed itemId, address indexed owner, address indexed slasher, uint amount);

    constructor(address payable _burnAddress) public {
        burnAddress = _burnAddress;
    }

    /**
     * @dev Changes the burn address
     * @param _burnAddress New burn address
     */
    function setBurnAddress(address payable _burnAddress) external onlyOwner {
        emit BurnAddressChanged(msg.sender, burnAddress, _burnAddress);
        burnAddress = _burnAddress;
    }

    /**
     * @dev Changes the base price
     * @param _basePrice New burn address
     */
    function setBasePrice(uint _basePrice) external onlyOwner {
        emit BasePriceChanged(msg.sender, basePrice, _basePrice);
        basePrice = _basePrice;
    }

    function _stake(uint _itemId, address payable _owner, address _tokenAddress) internal {
        require(stakes[_itemId].owner == address(0), "Already has/had a stake");

        stakeCounter[_owner]++;

        uint stakeAmount = basePrice * stakeCounter[_owner] * stakeCounter[_owner]; // y = basePrice * x^2

        // Using only ETH as stake for phase 0
        _tokenAddress = address(0);
        require(msg.value == stakeAmount, "ETH amount is required");

        // Uncomment to support tokens
        /*
        if (_tokenAddress != address(0)) {
            require(msg.value == 0, "Cannot send ETH with token address different from 0");
            ERC20Token tokenToPay = ERC20Token(_tokenAddress);
            require(_safeTransferFrom(tokenToPay, _owner, address(this), stakeAmount), "Unsuccessful token transfer");
        } else {
            require(msg.value == stakeAmount, "ETH amount is required");
        }
        */

        stakes[_itemId].amount = stakeAmount;
        stakes[_itemId].owner = _owner;
        stakes[_itemId].token = _tokenAddress;

        emit Staked(_itemId,  _owner, stakeAmount);
    }

    function getAmountToStake(address _owner) public view returns(uint){
        uint stakeCnt = stakeCounter[_owner] + 1;
        return basePrice * stakeCnt * stakeCnt; // y = basePrice * x^2
    }

    function _unstake(uint _itemId) internal {
        Stake storage s = stakes[_itemId];

        if (s.amount == 0) return; // No stake for item

        uint amount = s.amount;
        s.amount = 0;

        assert(stakeCounter[s.owner] > 0);
        stakeCounter[s.owner]--;

        if (s.token == address(0)) {
            (bool success, ) = s.owner.call.value(amount)("");
            require(success, "Transfer failed.");
        } else {
            require(_safeTransfer(ERC20Token(s.token), s.owner, amount), "Couldn't transfer funds");
        }

        emit Unstaked(_itemId, s.owner, amount);
    }

    function _slash(uint _itemId) internal {
        Stake storage s = stakes[_itemId];

        // TODO: what happens if offer was previosly validated and the user removed the stake?
        if (s.amount == 0) return;

        uint amount = s.amount;
        s.amount = 0;

        if (s.token == address(0)) {
            (bool success, ) = burnAddress.call.value(amount)("");
            require(success, "Transfer failed.");
        } else {
            require(_safeTransfer(ERC20Token(s.token), burnAddress, amount), "Couldn't transfer funds");
        }

        emit Slashed(_itemId, s.owner, msg.sender, amount);
    }

    function _refundStake(uint _itemId) internal {
        Stake storage s = stakes[_itemId];

        if (s.amount == 0) return;

        uint amount = s.amount;
        s.amount = 0;

        stakeCounter[s.owner]--;

        if (amount != 0) {
            if (s.token == address(0)) {
                (bool success, ) = s.owner.call.value(amount)("");
                require(success, "Transfer failed.");
            } else {
                require(_safeTransfer(ERC20Token(s.token), s.owner, amount), "Couldn't transfer funds");
            }
        }
    }

}



/**
* @title MetadataStore
* @dev User and offers registry
*/
contract MetadataStore is Stakable, MessageSigned, SecuredFunctions, Proxiable {

    struct User {
        string contactData;
        string location;
        string username;
    }

    struct Offer {
        int16 margin;
        uint[] paymentMethods;
        uint limitL;
        uint limitU;
        address asset;
        string currency;
        address payable owner;
        address payable arbitrator;
        bool deleted;
    }

    License public sellingLicenses;
    ArbitrationLicense public arbitrationLicenses;

    mapping(address => User) public users;
    mapping(address => uint) public user_nonce;

    Offer[] public offers;
    mapping(address => uint256[]) public addressToOffers;
    mapping(address => mapping (uint256 => bool)) public offerWhitelist;

    bool internal _initialized;

    event OfferAdded(
        address owner,
        uint256 offerId,
        address asset,
        string location,
        string currency,
        string username,
        uint[] paymentMethods,
        uint limitL,
        uint limitU,
        int16 margin
    );

    event OfferRemoved(address owner, uint256 offerId);

    /**
     * @param _sellingLicenses Sellers licenses contract address
     * @param _arbitrationLicenses Arbitrators licenses contract address
     * @param _burnAddress Address to send slashed offer funds
     */
    constructor(address _sellingLicenses, address _arbitrationLicenses, address payable _burnAddress) public
        Stakable(_burnAddress)
    {
        init(_sellingLicenses, _arbitrationLicenses);
    }

    /**
     * @dev Initialize contract (used with proxy). Can only be called once
     * @param _sellingLicenses Sellers licenses contract address
     * @param _arbitrationLicenses Arbitrators licenses contract address
     */
    function init(
        address _sellingLicenses,
        address _arbitrationLicenses
    ) public {
        assert(_initialized == false);

        _initialized = true;

        sellingLicenses = License(_sellingLicenses);
        arbitrationLicenses = ArbitrationLicense(_arbitrationLicenses);

        basePrice = 0.01 ether;


        _setOwner(msg.sender);
    }

    function updateCode(address newCode) public onlyOwner {
        updateCodeAddress(newCode);
    }

    event LicensesChanged(address sender, address oldSellingLicenses, address newSellingLicenses, address oldArbitrationLicenses, address newArbitrationLicenses);

    /**
     * @dev Initialize contract (used with proxy). Can only be called once
     * @param _sellingLicenses Sellers licenses contract address
     * @param _arbitrationLicenses Arbitrators licenses contract address
     */
    function setLicenses(
        address _sellingLicenses,
        address _arbitrationLicenses
    ) public onlyOwner {
        emit LicensesChanged(msg.sender, address(sellingLicenses), address(_sellingLicenses), address(arbitrationLicenses), (_arbitrationLicenses));

        sellingLicenses = License(_sellingLicenses);
        arbitrationLicenses = ArbitrationLicense(_arbitrationLicenses);
    }

    /**
     * @dev Get datahash to be signed
     * @param _username Username
     * @param _contactData Contact Data   ContactType:UserId
     * @param _nonce Nonce value (obtained from user_nonce)
     * @return bytes32 to sign
     */
    function _dataHash(string memory _username, string memory _contactData, uint _nonce) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _username, _contactData, _nonce));
    }

    /**
     * @notice Get datahash to be signed
     * @param _username Username
     * @param _contactData Contact Data   ContactType:UserId
     * @return bytes32 to sign
     */
    function getDataHash(string calldata _username, string calldata _contactData) external view returns (bytes32) {
        return _dataHash(_username, _contactData, user_nonce[msg.sender]);
    }

    /**
     * @dev Get signer address from signature. This uses the signature parameters to validate the signature
     * @param _username Status username
     * @param _contactData Contact Data   ContactType:UserId
     * @param _nonce User nonce
     * @param _signature Signature obtained from the previous parameters
     * @return Signing user address
     */
    function _getSigner(
        string memory _username,
        string memory _contactData,
        uint _nonce,
        bytes memory _signature
    ) internal view returns(address) {
        bytes32 signHash = _getSignHash(_dataHash(_username, _contactData, _nonce));
        return _recoverAddress(signHash, _signature);
    }

    /**
     * @notice Get signer address from signature
     * @param _username Status username
     * @param _contactData Contact Data   ContactType:UserId
     * @param _nonce User nonce
     * @param _signature Signature obtained from the previous parameters
     * @return Signing user address
     */
    function getMessageSigner(
        string calldata _username,
        string calldata _contactData,
        uint _nonce,
        bytes calldata _signature
    ) external view returns(address) {
        return _getSigner(_username, _contactData, _nonce, _signature);
    }

    /**
     * @dev Adds or updates user information
     * @param _user User address to update
     * @param _contactData Contact Data   ContactType:UserId
     * @param _location New location
     * @param _username New status username
     */
    function _addOrUpdateUser(
        address _user,
        string memory _contactData,
        string memory _location,
        string memory _username
    ) internal {
        User storage u = users[_user];
        u.contactData = _contactData;
        u.location = _location;
        u.username = _username;
    }

    /**
     * @notice Adds or updates user information via signature
     * @param _signature Signature
     * @param _contactData Contact Data   ContactType:UserId
     * @param _location New location
     * @param _username New status username
     * @return Signing user address
     */
    function addOrUpdateUser(
        bytes calldata _signature,
        string calldata _contactData,
        string calldata _location,
        string calldata _username,
        uint _nonce
    ) external returns(address payable _user) {
        _user = address(uint160(_getSigner(_username, _contactData, _nonce, _signature)));

        require(_nonce == user_nonce[_user], "Invalid nonce");

        user_nonce[_user]++;
        _addOrUpdateUser(_user, _contactData, _location, _username);

        return _user;
    }

    /**
     * @notice Adds or updates user information
     * @param _contactData Contact Data   ContactType:UserId
     * @param _location New location
     * @param _username New status username
     * @return Signing user address
     */
    function addOrUpdateUser(
        string calldata _contactData,
        string calldata _location,
        string calldata _username
    ) external {
        _addOrUpdateUser(msg.sender, _contactData, _location, _username);
    }

    /**
     * @notice Adds or updates user information
     * @dev can only be called by the escrow contract
     * @param _sender Address that sets the user info
     * @param _contactData Contact Data   ContactType:UserId
     * @param _location New location
     * @param _username New status username
     * @return Signing user address
     */
    function addOrUpdateUser(
        address _sender,
        string calldata _contactData,
        string calldata _location,
        string calldata _username
    ) external onlyAllowedContracts {
        _addOrUpdateUser(_sender, _contactData, _location, _username);
    }

    /**
    * @dev Add a new offer with a new user if needed to the list
    * @param _asset The address of the erc20 to exchange, pass 0x0 for Eth
    * @param _contactData Contact Data   ContactType:UserId
    * @param _location The location on earth
    * @param _currency The currency the user want to receive (USD, EUR...)
    * @param _username The username of the user
    * @param _paymentMethods The list of the payment methods the user accept
    * @param _limitL Lower limit accepted
    * @param _limitU Upper limit accepted
    * @param _margin The margin for the user
    * @param _arbitrator The arbitrator used by the offer
    */
    function addOffer(
        address _asset,
        string memory _contactData,
        string memory _location,
        string memory _currency,
        string memory _username,
        uint[] memory _paymentMethods,
        uint _limitL,
        uint _limitU,
        int16 _margin,
        address payable _arbitrator
    ) public payable {
        //require(sellingLicenses.isLicenseOwner(msg.sender), "Not a license owner");
        // @TODO: limit number of offers if the sender is unlicensed?

        require(arbitrationLicenses.isAllowed(msg.sender, _arbitrator), "Arbitrator does not allow this transaction");

        require(_limitL <= _limitU, "Invalid limits");
        require(msg.sender != _arbitrator, "Cannot arbitrate own offers");

        _addOrUpdateUser(
            msg.sender,
            _contactData,
            _location,
            _username
        );

        Offer memory newOffer = Offer(
            _margin,
            _paymentMethods,
            _limitL,
            _limitU,
            _asset,
            _currency,
            msg.sender,
            _arbitrator,
            false
        );

        uint256 offerId = offers.push(newOffer) - 1;
        offerWhitelist[msg.sender][offerId] = true;
        addressToOffers[msg.sender].push(offerId);

        emit OfferAdded(
            msg.sender,
            offerId,
            _asset,
            _location,
            _currency,
            _username,
            _paymentMethods,
            _limitL,
            _limitU,
            _margin);

        _stake(offerId, msg.sender, _asset);
    }

    /**
     * @notice Remove user offer
     * @dev Removed offers are marked as deleted instead of being deleted
     * @param _offerId Id of the offer to remove
     */
    function removeOffer(uint256 _offerId) external {
        require(offerWhitelist[msg.sender][_offerId], "Offer does not exist");

        offers[_offerId].deleted = true;
        offerWhitelist[msg.sender][_offerId] = false;
        emit OfferRemoved(msg.sender, _offerId);

        _unstake(_offerId);
    }

    /**
     * @notice Get the offer by Id
     * @dev normally we'd access the offers array, but it would not return the payment methods
     * @param _id Offer id
     * @return Offer data (see Offer struct)
     */
    function offer(uint256 _id) external view returns (
        address asset,
        string memory currency,
        int16 margin,
        uint[] memory paymentMethods,
        uint limitL,
        uint limitH,
        address payable owner,
        address payable arbitrator,
        bool deleted
    ) {
        Offer memory theOffer = offers[_id];

        // In case arbitrator rejects the seller
        address payable offerArbitrator = theOffer.arbitrator;
        if(!arbitrationLicenses.isAllowed(theOffer.owner, offerArbitrator)){
            offerArbitrator = address(0);
        }

        return (
            theOffer.asset,
            theOffer.currency,
            theOffer.margin,
            theOffer.paymentMethods,
            theOffer.limitL,
            theOffer.limitU,
            theOffer.owner,
            offerArbitrator,
            theOffer.deleted
        );
    }

    /**
     * @notice Get the offer's owner by Id
     * @dev Helper function
     * @param _id Offer id
     * @return Seller address
     */
    function getOfferOwner(uint256 _id) external view returns (address payable) {
        return (offers[_id].owner);
    }

    /**
     * @notice Get the offer's asset by Id
     * @dev Helper function
     * @param _id Offer id
     * @return Token address used in the offer
     */
    function getAsset(uint256 _id) external view returns (address) {
        return (offers[_id].asset);
    }

    /**
     * @notice Get the offer's arbitrator by Id
     * @dev Helper function
     * @param _id Offer id
     * @return Arbitrator address
     */
    function getArbitrator(uint256 _id) external view returns (address payable) {
        return (offers[_id].arbitrator);
    }

    /**
     * @notice Get the size of the offers
     * @return Number of offers stored in the contract
     */
    function offersSize() external view returns (uint256) {
        return offers.length;
    }

    /**
     * @notice Get all the offer ids of the address in params
     * @param _address Address of the offers
     * @return Array of offer ids for a specific address
     */
    function getOfferIds(address _address) external view returns (uint256[] memory) {
        return addressToOffers[_address];
    }

    /**
     * @dev Slash offer stake. If the sender is not the escrow contract, nothing will happen
     * @param _offerId Offer Id to slash
     */
    function slashStake(uint _offerId) external onlyAllowedContracts {
        _slash(_offerId);
    }

    /**
     * @dev Refunds a stake. Can be called automatically after an escrow is released
     * @param _offerId Offer Id to slash
     */
    function refundStake(uint _offerId) external onlyAllowedContracts {
        _refundStake(_offerId);
    }
}




// Contract that implements the relay recipient protocol.  Inherited by Gatekeeper, or any other relay recipient.
//
// The recipient contract is responsible to:
// * pass a trusted IRelayHub singleton to the constructor.
// * Implement acceptRelayedCall, which acts as a whitelist/blacklist of senders.  It is advised that the recipient's owner will be able to update that list to remove abusers.
// * In every function that cares about the sender, use "address sender = getSender()" instead of msg.sender.  It'll return msg.sender for non-relayed transactions, or the real sender in case of relayed transactions.



contract IRelayRecipient {

    /**
     * return the relayHub of this contract.
     */
    function getHubAddr() public view returns (address);

    /**
     * return the contract's balance on the RelayHub.
     * can be used to determine if the contract can pay for incoming calls,
     * before making any.
     */
    function getRecipientBalance() public view returns (uint);

    /*
     * Called by Relay (and RelayHub), to validate if this recipient accepts this call.
     * Note: Accepting this call means paying for the tx whether the relayed call reverted or not.
     *
     *  @return "0" if the the contract is willing to accept the charges from this sender, for this function call.
     *      any other value is a failure. actual value is for diagnostics only.
     *      ** Note: values below 10 are reserved by canRelay

     *  @param relay the relay that attempts to relay this function call.
     *          the contract may restrict some encoded functions to specific known relays.
     *  @param from the sender (signer) of this function call.
     *  @param encodedFunction the encoded function call (without any ethereum signature).
     *          the contract may check the method-id for valid methods
     *  @param gasPrice - the gas price for this transaction
     *  @param transactionFee - the relay compensation (in %) for this transaction
     *  @param signature - sender's signature over all parameters except approvalData
     *  @param approvalData - extra dapp-specific data (e.g. signature from trusted party)
     */
     function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
    external
    view
    returns (uint256, bytes memory);

    /*
     * modifier to be used by recipients as access control protection for preRelayedCall & postRelayedCall
     */
    modifier relayHubOnly() {
        require(msg.sender == getHubAddr(),"Function can only be called by RelayHub");
        _;
    }

    /** this method is called before the actual relayed function call.
     * It may be used to charge the caller before (in conjuction with refunding him later in postRelayedCall for example).
     * the method is given all parameters of acceptRelayedCall and actual used gas.
     *
     *
     *** NOTICE: if this method modifies the contract's state, it must be protected with access control i.e. require msg.sender == getHubAddr()
     *
     *
     * Revert in this functions causes a revert of the client's relayed call but not in the entire transaction
     * (that is, the relay will still get compensated)
     */
    function preRelayedCall(bytes calldata context) external returns (bytes32);

    /** this method is called after the actual relayed function call.
     * It may be used to record the transaction (e.g. charge the caller by some contract logic) for this call.
     * the method is given all parameters of acceptRelayedCall, and also the success/failure status and actual used gas.
     *
     *
     *** NOTICE: if this method modifies the contract's state, it must be protected with access control i.e. require msg.sender == getHubAddr()
     *
     *
     * @param success - true if the relayed call succeeded, false if it reverted
     * @param actualCharge - estimation of how much the recipient will be charged. This information may be used to perform local booking and
     *   charge the sender for this call (e.g. in tokens).
     * @param preRetVal - preRelayedCall() return value passed back to the recipient
     *
     * Revert in this functions causes a revert of the client's relayed call but not in the entire transaction
     * (that is, the relay will still get compensated)
     */
    function postRelayedCall(bytes calldata context, bool success, uint actualCharge, bytes32 preRetVal) external;

}



contract IRelayHub {
    // Relay management

    // Add stake to a relay and sets its unstakeDelay.
    // If the relay does not exist, it is created, and the caller
    // of this function becomes its owner. If the relay already exists, only the owner can call this function. A relay
    // cannot be its own owner.
    // All Ether in this function call will be added to the relay's stake.
    // Its unstake delay will be assigned to unstakeDelay, but the new value must be greater or equal to the current one.
    // Emits a Staked event.
    function stake(address relayaddr, uint256 unstakeDelay) external payable;

    // Emited when a relay's stake or unstakeDelay are increased
    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    // Registers the caller as a relay.
    // The relay must be staked for, and not be a contract (i.e. this function must be called directly from an EOA).
    // Emits a RelayAdded event.
    // This function can be called multiple times, emitting new RelayAdded events. Note that the received transactionFee
    // is not enforced by relayCall.
    function registerRelay(uint256 transactionFee, string memory url) public;

    // Emitted when a relay is registered or re-registerd. Looking at these events (and filtering out RelayRemoved
    // events) lets a client discover the list of available relays.
    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    // Removes (deregisters) a relay. Unregistered (but staked for) relays can also be removed. Can only be called by
    // the owner of the relay. After the relay's unstakeDelay has elapsed, unstake will be callable.
    // Emits a RelayRemoved event.
    function removeRelayByOwner(address relay) public;

    // Emitted when a relay is removed (deregistered). unstakeTime is the time when unstake will be callable.
    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    // Deletes the relay from the system, and gives back its stake to the owner. Can only be called by the relay owner,
    // after unstakeDelay has elapsed since removeRelayByOwner was called.
    // Emits an Unstaked event.
    function unstake(address relay) public;

    // Emitted when a relay is unstaked for, including the returned stake.
    event Unstaked(address indexed relay, uint256 stake);

    // States a relay can be in
    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    // Returns a relay's status. Note that relays can be deleted when unstaked or penalized.
    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);

    // Balance management

    // Deposits ether for a contract, so that it can receive (and pay for) relayed transactions. Unused balance can only
    // be withdrawn by the contract itself, by callingn withdraw.
    // Emits a Deposited event.
    function depositFor(address target) public payable;

    // Emitted when depositFor is called, including the amount and account that was funded.
    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    // Returns an account's deposits. These can be either a contnract's funds, or a relay owner's revenue.
    function balanceOf(address target) external view returns (uint256);

    // Withdraws from an account's balance, sending it back to it. Relay owners call this to retrieve their revenue, and
    // contracts can also use it to reduce their funding.
    // Emits a Withdrawn event.
    function withdraw(uint256 amount, address payable dest) public;

    // Emitted when an account withdraws funds from RelayHub.
    event Withdrawn(address indexed account, address indexed dest, uint256 amount);

    // Relaying

    // Check if the RelayHub will accept a relayed operation. Multiple things must be true for this to happen:
    //  - all arguments must be signed for by the sender (from)
    //  - the sender's nonce must be the current one
    //  - the recipient must accept this transaction (via acceptRelayedCall)
    // Returns a PreconditionCheck value (OK when the transaction can be relayed), or a recipient-specific error code if
    // it returns one in acceptRelayedCall.
    function canRelay(
        address relay,
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public view returns (uint256 status, bytes memory recipientContext);

    // Preconditions for relaying, checked by canRelay and returned as the corresponding numeric values.
    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    // Relays a transaction. For this to suceed, multiple conditions must be met:
    //  - canRelay must return PreconditionCheck.OK
    //  - the sender must be a registered relay
    //  - the transaction's gas price must be larger or equal to the one that was requested by the sender
    //  - the transaction must have enough gas to not run out of gas if all internal transactions (calls to the
    // recipient) use all gas available to them
    //  - the recipient must have enough balance to pay the relay for the worst-case scenario (i.e. when all gas is
    // spent)
    //
    // If all conditions are met, the call will be relayed and the recipient charged. preRelayedCall, the encoded
    // function and postRelayedCall will be called in order.
    //
    // Arguments:
    //  - from: the client originating the request
    //  - recipient: the target IRelayRecipient contract
    //  - encodedFunction: the function call to relay, including data
    //  - transactionFee: fee (%) the relay takes over actual gas cost
    //  - gasPrice: gas price the client is willing to pay
    //  - gasLimit: gas to forward when calling the encoded function
    //  - nonce: client's nonce
    //  - signature: client's signature over all previous params, plus the relay and RelayHub addresses
    //  - approvalData: dapp-specific data forwared to acceptRelayedCall. This value is *not* verified by the Hub, but
    //    it still can be used for e.g. a signature.
    //
    // Emits a TransactionRelayed event.
    function relayCall(
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public;

    // Emitted when an attempt to relay a call failed. This can happen due to incorrect relayCall arguments, or the
    // recipient not accepting the relayed call. The actual relayed call was not executed, and the recipient not charged.
    // The reason field contains an error code: values 1-10 correspond to PreconditionCheck entries, and values over 10
    // are custom recipient error codes returned from acceptRelayedCall.
    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    // Emitted when a transaction is relayed. Note that the actual encoded function might be reverted: this will be
    // indicated in the status field.
    // Useful when monitoring a relay's operation and relayed calls to a contract.
    // Charge is the ether value deducted from the recipient's balance, paid to the relay's owner.
    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    // Reason error codes for the TransactionRelayed event
    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    // Returns how much gas should be forwarded to a call to relayCall, in order to relay a transaction that will spend
    // up to relayedCallStipend gas.
    function requiredGas(uint256 relayedCallStipend) public view returns (uint256);

    // Returns the maximum recipient charge, given the amount of gas forwarded, gas price and relay fee.
    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) public view returns (uint256);

    // Relay penalization. Any account can penalize relays, removing them from the system immediately, and rewarding the
    // reporter with half of the relay's stake. The other half is burned so that, even if the relay penalizes itself, it
    // still loses half of its stake.

    // Penalize a relay that signed two transactions using the same nonce (making only the first one valid) and
    // different data (gas price, gas limit, etc. may be different). The (unsigned) transaction data and signature for
    // both transactions must be provided.
    function penalizeRepeatedNonce(bytes memory unsignedTx1, bytes memory signature1, bytes memory unsignedTx2, bytes memory signature2) public;

    // Penalize a relay that sent a transaction that didn't target RelayHub's registerRelay or relayCall.
    function penalizeIllegalTransaction(bytes memory unsignedTx, bytes memory signature) public;

    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) view external returns (uint256);
}


/*

  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/




library LibBytes {

    using LibBytes for bytes;

    /// @dev Gets the memory address for a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of byte array. This
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }
    
    /// @dev Gets the memory address for the contents of a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    /// @dev Copies `length` bytes from memory location `source` to `dest`.
    /// @param dest memory address to copy bytes to.
    /// @param source memory address to copy bytes from.
    /// @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }
                    
                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }
                    
                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    /// @dev Returns a slices from a byte array.
    /// @param b The byte array to take a slice from.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }
    
    /// @dev Returns a slice from a byte array without preserving the input.
    /// @param b The byte array to take a slice from. Will be destroyed in the process.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    /// @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    /// @dev Pops the last byte off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The byte that was popped off.
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        require(
            b.length > 0,
            "GREATER_THAN_ZERO_LENGTH_REQUIRED"
        );

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Pops the last 20 bytes off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The 20 byte address that was popped off.
    function popLast20Bytes(bytes memory b)
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= 20,
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Store last 20 bytes.
        result = readAddress(b, b.length - 20);

        assembly {
            // Subtract 20 from byte array length.
            let newLen := sub(mload(b), 20)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Tests equality of two byte arrays.
    /// @param lhs First byte array to compare.
    /// @param rhs Second byte array to compare.
    /// @return True if arrays are the same. False otherwise.
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    /// @dev Reads an address from a position in a byte array.
    /// @param b Byte array containing an address.
    /// @param index Index in byte array of address.
    /// @return address from byte array.
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    /// @dev Writes an address into a specific position in a byte array.
    /// @param b Byte array to insert address into.
    /// @param index Index in byte array of address.
    /// @param input Address to put into byte array.
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )
            
            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return bytes32 value from byte array.
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Writes a bytes32 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes32 to put into byte array.
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    /// @dev Reads a uint256 value from a position in a byte array.
    /// @param b Byte array containing a uint256 value.
    /// @param index Index in byte array of uint256 value.
    /// @return uint256 value from byte array.
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    /// @dev Writes a uint256 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input uint256 to put into byte array.
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return bytes4 value from byte array.
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    /// @dev Reads nested bytes from a specific position.
    /// @dev NOTE: the returned value overlaps with the input value.
    ///            Both should be treated as immutable.
    /// @param b Byte array containing nested bytes.
    /// @param index Index of nested bytes.
    /// @return result Nested bytes.
    function readBytesWithLength(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Read length of nested bytes
        uint256 nestedBytesLength = readUint256(b, index);
        index += 32;

        // Assert length of <b> is valid, given
        // length of nested bytes
        require(
            b.length >= index + nestedBytesLength,
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );
        
        // Return a pointer to the byte array as it exists inside `b`
        assembly {
            result := add(b, index)
        }
        return result;
    }

    /// @dev Inserts bytes at a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes to insert.
    function writeBytesWithLength(
        bytes memory b,
        uint256 index,
        bytes memory input
    )
        internal
        pure
    {
        // Assert length of <b> is valid, given
        // length of input
        require(
            b.length >= index + 32 + input.length,  // 32 bytes to store length
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );

        // Copy <input> into <b>
        memCopy(
            b.contentAddress() + index,
            input.rawAddress(), // includes length of <input>
            input.length + 32   // +32 bytes to store <input> length
        );
    }

    /// @dev Performs a deep copy of a byte array onto another byte array of greater than or equal length.
    /// @param dest Byte array that will be overwritten with source bytes.
    /// @param source Byte array to copy onto dest bytes.
    function deepCopyBytes(
        bytes memory dest,
        bytes memory source
    )
        internal
        pure
    {
        uint256 sourceLen = source.length;
        // Dest length must be >= source length, or some bytes would not be copied.
        require(
            dest.length >= sourceLen,
            "GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED"
        );
        memCopy(
            dest.contentAddress(),
            source.contentAddress(),
            sourceLen
        );
    }
}


contract RelayRecipient is IRelayRecipient {

    IRelayHub private relayHub; // The IRelayHub singleton which is allowed to call us

    function getHubAddr() public view returns (address) {
        return address(relayHub);
    }

    /**
     * Initialize the RelayHub of this contract.
     * Must be called at least once (e.g. from the constructor), so that the contract can accept relayed calls.
     * For ownable contracts, there should be a method to update the RelayHub, in case a new hub is deployed (since
     * the RelayHub itself is not upgradeable)
     * Otherwise, the contract might be locked on a dead hub, with no relays.
     */
    function setRelayHub(IRelayHub _rhub) internal {
        relayHub = _rhub;

        //attempt a read method, just to validate the relay is a valid RelayHub contract.
        getRecipientBalance();
    }

    function getRelayHub() internal view returns (IRelayHub) {
        return relayHub;
    }

    /**
     * return the balance of this contract.
     * Note that this method will revert on configuration error (invalid relay address)
     */
    function getRecipientBalance() public view returns (uint) {
        return getRelayHub().balanceOf(address(this));
    }

    function getSenderFromData(address origSender, bytes memory msgData) public view returns (address) {
        address sender = origSender;
        if (origSender == getHubAddr()) {
            // At this point we know that the sender is a trusted IRelayHub, so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            sender = LibBytes.readAddress(msgData, msgData.length - 20);
        }
        return sender;
    }

    /**
     * return the sender of this call.
     * if the call came through the valid RelayHub, return the original sender.
     * otherwise, return `msg.sender`
     * should be used in the contract anywhere instead of msg.sender
     */
    function getSender() public view returns (address) {
        return getSenderFromData(msg.sender, msg.data);
    }

    function getMessageData() public view returns (bytes memory) {
        bytes memory origMsgData = msg.data;
        if (msg.sender == getHubAddr()) {
            // At this point we know that the sender is a trusted IRelayHub, so we trust that the last bytes of msg.data are the verified sender address.
            // extract original message data from the start of msg.data
            origMsgData = new bytes(msg.data.length - 20);
            for (uint256 i = 0; i < origMsgData.length; i++)
            {
                origMsgData[i] = msg.data[i];
            }
        }
        return origMsgData;
    }
}



/**
 * @title Escrow Relay (Gas Station Network)
 */
contract EscrowRelay is RelayRecipient, Ownable {

  MetadataStore public metadataStore;
  IEscrow public escrow;
  address public snt;

  mapping(address => uint) public lastActivity;

  bytes4 constant CREATE_SIGNATURE = bytes4(keccak256("createEscrow(uint256,uint256,uint256,string,string,string)"));
  bytes4 constant PAY_SIGNATURE = bytes4(keccak256("pay(uint256)"));
  bytes4 constant CANCEL_SIGNATURE = bytes4(keccak256("cancel(uint256)"));
  bytes4 constant OPEN_CASE_SIGNATURE = bytes4(keccak256("openCase(uint256,uint8)"));
  bytes4 constant RATE_SIGNATURE  = bytes4(keccak256("rateTransaction(uint256,uint256)"));

  uint256 constant OK = 0;
  uint256 constant ERROR_ENOUGH_BALANCE = 11;
  uint256 constant ERROR_INVALID_ASSET = 12;
  uint256 constant ERROR_TRX_TOO_SOON = 13;
  uint256 constant ERROR_INVALID_BUYER = 14;
  uint256 constant ERROR_GAS_PRICE = 15;
  uint256 constant ERROR = 99;

  /**
   * @param _metadataStore Metadata Store Address
   * @param _escrow IEscrow Instance Address
   * @param _snt SNT address
   */
  constructor(address _metadataStore, address _escrow, address _snt) public {
    metadataStore = MetadataStore(_metadataStore);
    escrow = IEscrow(_escrow);
    snt = _snt;
  }

  /**
   * @notice Set metadata store address
   * @dev Only contract owner can execute this function
   * @param _metadataStore New metadata store address
   */
  function setMetadataStore(address _metadataStore) external onlyOwner {
    metadataStore = MetadataStore(_metadataStore);
  }

  /**
   * @notice Set escrow address
   * @dev Only contract owner can execute this function
   * @param _escrow New escrow address
   */
  function setEscrow(address _escrow) external onlyOwner {
    escrow = IEscrow(_escrow);
  }

  /**
   * @notice Set gas station network hub address
   * @dev Only contract owner can execute this function
   * @param _relayHub New relay hub address
   */
  function setRelayHubAddress(address _relayHub) external onlyOwner {
    setRelayHub(IRelayHub(_relayHub));
  }

  /**
   * @notice Determine if the timeout for relaying a create/cancel transaction has passed
   * @param _account Account to verify
   * @return bool
   */
  function canCreateOrCancel(address _account) external view returns(bool) {
    return (lastActivity[_account] + 15 minutes) < block.timestamp;
  }

  /**
   * @notice Create a new escrow
   * @param _offerId Offer
   * @param _tokenAmount Amount buyer is willing to trade
   * @param _fiatAmount Indicates how much FIAT will the user pay for the tokenAmount
   * @param _contactData Contact Data   ContactType:UserId
   * @param _location The location on earth
   * @param _username The username of the user
   */
  function createEscrow(
    uint _offerId,
    uint _tokenAmount,
    uint _fiatAmount,
    string memory _contactData,
    string memory _location,
    string memory _username
  ) public returns (uint escrowId) {
    address sender = getSender();
    lastActivity[sender] = block.timestamp;
    escrowId = escrow.createEscrow_relayed(
         address(uint160(sender)),
         _offerId,
         _tokenAmount,
         _fiatAmount,
         _contactData,
         _location,
         _username
    );
  }

  /**
   * @notice Mark transaction as paid
   * @param _escrowId Escrow to mark as paid
   */
  function pay(uint _escrowId) external {
    address sender = getSender();
    escrow.pay_relayed(sender, _escrowId);
  }

  /**
   * @notice Rate a transaction
   * @param _escrowId Id of the escrow
   * @param _rate rating of the transaction from 1 to 5
   */
  function rateTransaction(uint _escrowId, uint _rate) external {
    address sender = getSender();
    escrow.rateTransaction_relayed(sender, _escrowId, _rate);
  }

  /**
   * @notice Cancel an escrow
   * @param _escrowId Escrow to cancel
   */
  function cancel(uint _escrowId) external {
    address sender = getSender();
    lastActivity[sender] = block.timestamp;
    escrow.cancel_relayed(sender, _escrowId);
  }

  /**
   * @notice Open a dispute
   * @param _escrowId Escrow to open a dispute
   * @param _motive Motive a dispute is being opened
   */
  function openCase(uint _escrowId, uint8 _motive) public {
    address sender = getSender();
    escrow.openCase_relayed(sender, _escrowId, _motive);
  }

  // =======================1=================================================
  // Gas station network

  /**
   * @notice Function returning if we accept or not the relayed call (do we pay or not for the gas)
   * @param from Address of the buyer getting a free transaction
   * @param encodedFunction Function that will be called on the Escrow contract
   * @param gasPrice Gas price
   * @dev relay and transaction_fee are useless in our relay workflow
   */
  function acceptRelayedCall(
    address /* relay */,
    address from,
    bytes calldata encodedFunction,
    uint256 /* transactionFee */,
    uint256 gasPrice,
    uint256 /* gasLimit */,
    uint256 /* nonce */,
    bytes calldata /* approvalData */,
    uint256 /* maxPossibleCharge */
  ) external view returns (uint256, bytes memory)
  {
    bytes memory abiEncodedFunc = encodedFunction; // Call data elements cannot be accessed directly
    bytes4 fSign;
    uint dataValue;

    assembly {
      fSign := mload(add(abiEncodedFunc, add(0x20, 0)))
      dataValue := mload(add(abiEncodedFunc, 36))
    }

    return (_evaluateConditionsToRelay(from, gasPrice, fSign, dataValue), "");
  }

  /**
   * @dev Evaluates if the sender conditions are valid for relaying a escrow transaction
   * @param from Sender
   * @param gasPrice Gas Price
   * @param functionSignature Function Signature
   * @param dataValue Represents the escrowId or offerId depending on the function being called
   */
  function _evaluateConditionsToRelay(address from, uint gasPrice, bytes4 functionSignature, uint dataValue) internal view returns (uint256) {
    address token;

    if(functionSignature == RATE_SIGNATURE && gasPrice < 20000000000){
      return OK;
    }

    if(from.balance > 600000 * gasPrice) return ERROR_ENOUGH_BALANCE;

    if(gasPrice > 20000000000) return ERROR_GAS_PRICE; // 20Gwei

    if(functionSignature == PAY_SIGNATURE || functionSignature == CANCEL_SIGNATURE || functionSignature == OPEN_CASE_SIGNATURE){
      address payable buyer;
      
      (buyer, , token, ) = escrow.getBasicTradeData(dataValue);

      if(buyer != from) return ERROR_INVALID_BUYER;
      if(token != snt && token != address(0)) return ERROR_INVALID_ASSET;

      if(functionSignature == CANCEL_SIGNATURE){ // Allow activity after 15min have passed
        if((lastActivity[from] + 15 minutes) > block.timestamp) return ERROR_TRX_TOO_SOON;
      }

      return OK;
    } else if(functionSignature == CREATE_SIGNATURE) {
      token = metadataStore.getAsset(dataValue);

      if(token != snt && token != address(0)) return ERROR_INVALID_ASSET;

      // Allow activity after 15 min have passed
      if((lastActivity[from] + 15 minutes) > block.timestamp) return ERROR_TRX_TOO_SOON;

      return OK;
    }

    return ERROR;
  }

  /**
   * @notice Function executed before the relay. Unused by us
   */
  function preRelayedCall(bytes calldata) external returns (bytes32){
    // nothing to be done pre-call.
    // still, we must implement this method.
  }

  /**
   * @notice Function executed after the relay. Unused by us
   */
    function postRelayedCall(
      bytes calldata /*context*/, 
      bool /*success*/, 
      uint /*actualCharge*/, 
      bytes32 /*preRetVal*/) external {
    // nothing to be done post-call.
    // still, we must implement this method.
  }
}