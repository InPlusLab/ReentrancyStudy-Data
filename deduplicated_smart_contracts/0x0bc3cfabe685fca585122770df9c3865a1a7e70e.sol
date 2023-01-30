/**

 *Submitted for verification at Etherscan.io on 2018-11-14

*/



// File: contracts/generic/Restricted.sol



/*

    Generic contract to authorise calls to certain functions only from a given address.

    The address authorised must be a contract (multisig or not, depending on the permission), except for local test



    deployment works as:

           1. contract deployer account deploys contracts

           2. constructor grants "PermissionGranter" permission to deployer account

           3. deployer account executes initial setup (no multiSig)

           4. deployer account grants PermissionGranter permission for the MultiSig contract

                (e.g. StabilityBoardProxy or PreTokenProxy)

           5. deployer account revokes its own PermissionGranter permission

*/



pragma solidity 0.4.24;





contract Restricted {



    // NB: using bytes32 rather than the string type because it's cheaper gas-wise:

    mapping (address => mapping (bytes32 => bool)) public permissions;



    event PermissionGranted(address indexed agent, bytes32 grantedPermission);

    event PermissionRevoked(address indexed agent, bytes32 revokedPermission);



    modifier restrict(bytes32 requiredPermission) {

        require(permissions[msg.sender][requiredPermission], "msg.sender must have permission");

        _;

    }



    constructor(address permissionGranterContract) public {

        require(permissionGranterContract != address(0), "permissionGranterContract must be set");

        permissions[permissionGranterContract]["PermissionGranter"] = true;

        emit PermissionGranted(permissionGranterContract, "PermissionGranter");

    }



    function grantPermission(address agent, bytes32 requiredPermission) public {

        require(permissions[msg.sender]["PermissionGranter"],

            "msg.sender must have PermissionGranter permission");

        permissions[agent][requiredPermission] = true;

        emit PermissionGranted(agent, requiredPermission);

    }



    function grantMultiplePermissions(address agent, bytes32[] requiredPermissions) public {

        require(permissions[msg.sender]["PermissionGranter"],

            "msg.sender must have PermissionGranter permission");

        uint256 length = requiredPermissions.length;

        for (uint256 i = 0; i < length; i++) {

            grantPermission(agent, requiredPermissions[i]);

        }

    }



    function revokePermission(address agent, bytes32 requiredPermission) public {

        require(permissions[msg.sender]["PermissionGranter"],

            "msg.sender must have PermissionGranter permission");

        permissions[agent][requiredPermission] = false;

        emit PermissionRevoked(agent, requiredPermission);

    }



    function revokeMultiplePermissions(address agent, bytes32[] requiredPermissions) public {

        uint256 length = requiredPermissions.length;

        for (uint256 i = 0; i < length; i++) {

            revokePermission(agent, requiredPermissions[i]);

        }

    }



}



// File: contracts/generic/SafeMath.sol



/**

* @title SafeMath

* @dev Math operations with safety checks that throw on error



    TODO: check against ds-math: https://blog.dapphub.com/ds-math/

    TODO: move roundedDiv to a sep lib? (eg. Math.sol)

    TODO: more unit tests!

*/

pragma solidity 0.4.24;





library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;

        require(a == 0 || c / a == b, "mul overflow");

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason

        uint256 c = a / b;

        // require(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "sub underflow");

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "add overflow");

        return c;

    }



    // Division, round to nearest integer, round half up

    function roundedDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason

        uint256 halfB = (b % 2 == 0) ? (b / 2) : (b / 2 + 1);

        return (a % b >= halfB) ? (a / b + 1) : (a / b);

    }



    // Division, always rounds up

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason

        return (a % b != 0) ? (a / b + 1) : (a / b);

    }



    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? b : a;

    }    

}



// File: contracts/PreToken.sol



/* Augmint pretoken contract to record agreements and tokens allocated based on the agreement.



    Important: this is NOT an ERC20 token!



    PreTokens are non-fungible: agreements can have different conditions (valuationCap and discount)

        and pretokens are not tradable.



    Ownership can be transferred if owner wants to change wallet but the whole agreement and

        the total pretoken amount is moved to a new account



    PreTokenSigner can (via MultiSig):

      - add agreements and issue pretokens to an agreement

      - change owner of any agreement to handle if an owner lost a private keys

      - burn pretokens from any agreement to fix potential erroneous issuance

    These are known compromises on trustlessness hence all these tokens distributed based on signed agreements and

        preTokens are issued only to a closed group of contributors / team members.

    If despite these something goes wrong then as a last resort a new pretoken contract can be recreated from agreements.



    Some ERC20 functions are implemented so agreement owners can see their balances and use transfer in standard wallets.

    Restrictions:

      - only total balance can be transfered - effectively ERC20 transfer used to transfer agreement ownership

      - only agreement holders can transfer

        (i.e. can't transfer 0 amount if have no agreement to avoid polluting logs with Transfer events)

      - transfer is only allowed to accounts without an agreement yet

      - no approval and transferFrom ERC20 functions

 */



pragma solidity 0.4.24;









contract PreToken is Restricted {

    using SafeMath for uint256;



    string constant public name = "Augmint pretokens"; // solhint-disable-line const-name-snakecase

    string constant public symbol = "APRE"; // solhint-disable-line const-name-snakecase

    uint8 constant public decimals = 0; // solhint-disable-line const-name-snakecase



    uint public totalSupply;



    struct Agreement {

        address owner;

        uint balance;

        uint32 discount; //  discountRate in parts per million , ie. 10,000 = 1%

        uint32 valuationCap; // in USD (no decimals)

    }



    /* Agreement hash is the SHA-2 (SHA-256) hash of signed agreement document.

         To generate:

            OSX: shasum -a 256 agreement.pdf

            Windows: certUtil -hashfile agreement.pdf SHA256 */

    mapping(address => bytes32) public agreementOwners; // to lookup agrement by owner

    mapping(bytes32 => Agreement) public agreements;



    bytes32[] public allAgreements; // all agreements to able to iterate over



    event Transfer(address indexed from, address indexed to, uint amount);



    event NewAgreement(address owner, bytes32 agreementHash, uint32 discount, uint32 valuationCap);



    constructor(address permissionGranterContract)

    public Restricted(permissionGranterContract) {} // solhint-disable-line no-empty-blocks



    function addAgreement(address owner, bytes32 agreementHash, uint32 discount, uint32 valuationCap)

    external restrict("PreTokenSigner") {

        require(owner != address(0), "owner must not be 0x0");

        require(agreementOwners[owner] == 0x0, "owner must not have an aggrement yet");

        require(agreementHash != 0x0, "agreementHash must not be 0x0");

        require(discount > 0, "discount must be > 0");

        require(agreements[agreementHash].discount == 0, "agreement must not exist yet");



        agreements[agreementHash] = Agreement(owner, 0, discount, valuationCap);

        agreementOwners[owner] = agreementHash;

        allAgreements.push(agreementHash);



        emit NewAgreement(owner, agreementHash, discount, valuationCap);

    }



    function issueTo(bytes32 agreementHash, uint amount) external restrict("PreTokenSigner") {

        Agreement storage agreement = agreements[agreementHash];

        require(agreement.discount > 0, "agreement must exist");



        agreement.balance = agreement.balance.add(amount);

        totalSupply = totalSupply.add(amount);



        emit Transfer(0x0, agreement.owner, amount);

    }



    /* Restricted function to allow pretoken signers to fix incorrect issuance */

    function burnFrom(bytes32 agreementHash, uint amount)

    public restrict("PreTokenSigner") returns (bool) {

        Agreement storage agreement = agreements[agreementHash];

        // this is redundant b/c of next requires but be explicit

        require(agreement.discount > 0, "agreement must exist");

        require(amount > 0, "burn amount must be > 0");

        // .sub would revert anyways but emit reason

        require(agreement.balance >= amount, "must not burn more than balance");



        agreement.balance = agreement.balance.sub(amount);

        totalSupply = totalSupply.sub(amount);



        emit Transfer(agreement.owner, 0x0, amount);

        return true;

    }



    function balanceOf(address owner) public view returns (uint) {

        return agreements[agreementOwners[owner]].balance;

    }



    /* function to transfer agreement ownership to other wallet by owner

        it's in ERC20 form so owners can use standard ERC20 wallet just need to pass full balance as value */

    function transfer(address to, uint amount) public returns (bool) { // solhint-disable-line no-simple-event-func-name

        require(amount == agreements[agreementOwners[msg.sender]].balance, "must transfer full balance");

        _transfer(msg.sender, to);

        return true;

    }



    /* Restricted function to allow pretoken signers to fix if pretoken owner lost keys */

    function transferAgreement(bytes32 agreementHash, address to)

    public restrict("PreTokenSigner") returns (bool) {

        _transfer(agreements[agreementHash].owner, to);

        return true;

    }



    /* private function used by transferAgreement & transfer */

    function _transfer(address from, address to) private {

        Agreement storage agreement = agreements[agreementOwners[from]];

        require(agreementOwners[from] != 0x0, "from agreement must exists");

        require(agreementOwners[to] == 0, "to must not have an agreement");

        require(to != 0x0, "must not transfer to 0x0");



        agreement.owner = to;



        agreementOwners[to] = agreementOwners[from];

        agreementOwners[from] = 0x0;



        emit Transfer(from, to, agreement.balance);

    }



    function getAgreementsCount() external view returns (uint agreementsCount) {

        return allAgreements.length;

    }



    // UI helper fx - Returns <chunkSize> agreements from <offset> as

    // [index in allAgreements, account address as uint, balance, agreementHash as uint,

    //          discount as uint, valuationCap as uint ]

    function getAgreements(uint offset, uint16 chunkSize)

    external view returns(uint[6][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), allAgreements.length);

        uint[6][] memory response = new uint[6][](limit.sub(offset));



        for (uint i = offset; i < limit; i++) {

            bytes32 agreementHash = allAgreements[i];

            Agreement storage agreement = agreements[agreementHash];



            response[i - offset] = [i, uint(agreement.owner), agreement.balance,

                uint(agreementHash), uint(agreement.discount), uint(agreement.valuationCap)];

        }

        return response;

    }

}



// File: contracts/generic/MultiSig.sol



/* Abstract multisig contract to allow multi approval execution of atomic contracts scripts

        e.g. migrations or settings.

    * Script added by signing a script address by a signer  (NEW state)

    * Script goes to ALLOWED state once a quorom of signers sign it (quorom fx is defined in each derived contracts)

    * Script can be signed even in APPROVED state

    * APPROVED scripts can be executed only once.

        - if script succeeds then state set to DONE

        - If script runs out of gas or reverts then script state set to FAILEd and not allowed to run again

          (To avoid leaving "behind" scripts which fail in a given state but eventually execute in the future)

    * Scripts can be cancelled by an other multisig script approved and calling cancelScript()

    * Adding/removing signers is only via multisig approved scripts using addSigners / removeSigners fxs

*/

pragma solidity 0.4.24;







contract MultiSig {

    using SafeMath for uint256;



    mapping(address => bool) public isSigner;

    address[] public allSigners; // all signers, even the disabled ones

                                // NB: it can contain duplicates when a signer is added, removed then readded again

                                //   the purpose of this array is to being able to iterate on signers in isSigner

    uint public activeSignersCount;



    enum ScriptState {New, Approved, Done, Cancelled, Failed}



    struct Script {

        ScriptState state;

        uint signCount;

        mapping(address => bool) signedBy;

        address[] allSigners;

    }



    mapping(address => Script) public scripts;

    address[] public scriptAddresses;



    event SignerAdded(address signer);

    event SignerRemoved(address signer);



    event ScriptSigned(address scriptAddress, address signer);

    event ScriptApproved(address scriptAddress);

    event ScriptCancelled(address scriptAddress);



    event ScriptExecuted(address scriptAddress, bool result);



    constructor() public {

        // deployer address is the first signer. Deployer can configure new contracts by itself being the only "signer"

        // The first script which sets the new contracts live should add signers and revoke deployer's signature right

        isSigner[msg.sender] = true;

        allSigners.push(msg.sender);

        activeSignersCount = 1;

        emit SignerAdded(msg.sender);

    }



    function sign(address scriptAddress) public {

        require(isSigner[msg.sender], "sender must be signer");

        Script storage script = scripts[scriptAddress];

        require(script.state == ScriptState.Approved || script.state == ScriptState.New,

                "script state must be New or Approved");

        require(!script.signedBy[msg.sender], "script must not be signed by signer yet");



        if (script.allSigners.length == 0) {

            // first sign of a new script

            scriptAddresses.push(scriptAddress);

        }



        script.allSigners.push(msg.sender);

        script.signedBy[msg.sender] = true;

        script.signCount = script.signCount.add(1);



        emit ScriptSigned(scriptAddress, msg.sender);



        if (checkQuorum(script.signCount)) {

            script.state = ScriptState.Approved;

            emit ScriptApproved(scriptAddress);

        }

    }



    function execute(address scriptAddress) public returns (bool result) {

        // only allow execute to signers to avoid someone set an approved script failed by calling it with low gaslimit

        require(isSigner[msg.sender], "sender must be signer");

        Script storage script = scripts[scriptAddress];

        require(script.state == ScriptState.Approved, "script state must be Approved");



        // passing scriptAddress to allow called script access its own public fx-s if needed

        if (scriptAddress.delegatecall.gas(gasleft() - 23000)

            (abi.encodeWithSignature("execute(address)", scriptAddress))) {

            script.state = ScriptState.Done;

            result = true;

        } else {

            script.state = ScriptState.Failed;

            result = false;

        }

        emit ScriptExecuted(scriptAddress, result);

    }



    function cancelScript(address scriptAddress) public {

        require(msg.sender == address(this), "only callable via MultiSig");

        Script storage script = scripts[scriptAddress];

        require(script.state == ScriptState.Approved || script.state == ScriptState.New,

                "script state must be New or Approved");



        script.state = ScriptState.Cancelled;



        emit ScriptCancelled(scriptAddress);

    }



    /* requires quorum so it's callable only via a script executed by this contract */

    function addSigners(address[] signers) public {

        require(msg.sender == address(this), "only callable via MultiSig");

        for (uint i= 0; i < signers.length; i++) {

            if (!isSigner[signers[i]]) {

                require(signers[i] != address(0), "new signer must not be 0x0");

                activeSignersCount++;

                allSigners.push(signers[i]);

                isSigner[signers[i]] = true;

                emit SignerAdded(signers[i]);

            }

        }

    }



    /* requires quorum so it's callable only via a script executed by this contract */

    function removeSigners(address[] signers) public {

        require(msg.sender == address(this), "only callable via MultiSig");

        for (uint i= 0; i < signers.length; i++) {

            if (isSigner[signers[i]]) {

                require(activeSignersCount > 1, "must not remove last signer");

                activeSignersCount--;

                isSigner[signers[i]] = false;

                emit SignerRemoved(signers[i]);

            }

        }

    }



    /* implement it in derived contract */

    function checkQuorum(uint signersCount) internal view returns(bool isQuorum);



    function getAllSignersCount() view external returns (uint allSignersCount) {

        return allSigners.length;

    }



    // UI helper fx - Returns signers from offset as [signer id (index in allSigners), address as uint, isActive 0 or 1]

    function getSigners(uint offset, uint16 chunkSize)

    external view returns(uint[3][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), allSigners.length);

        uint[3][] memory response = new uint[3][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {

            address signerAddress = allSigners[i];

            response[i - offset] = [i, uint(signerAddress), isSigner[signerAddress] ? 1 : 0];

        }

        return response;

    }



    function getScriptsCount() view external returns (uint scriptsCount) {

        return scriptAddresses.length;

    }



    // UI helper fx - Returns scripts from offset as

    //  [scriptId (index in scriptAddresses[]), address as uint, state, signCount]

    function getScripts(uint offset, uint16 chunkSize)

    external view returns(uint[4][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), scriptAddresses.length);

        uint[4][] memory response = new uint[4][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {

            address scriptAddress = scriptAddresses[i];

            response[i - offset] = [i, uint(scriptAddress),

                uint(scripts[scriptAddress].state), scripts[scriptAddress].signCount];

        }

        return response;

    }

}



// File: contracts/PreTokenProxy.sol



/* allows tx to execute if 50% +1 vote of active signers signed */

pragma solidity 0.4.24;







contract PreTokenProxy is MultiSig {



    function checkQuorum(uint signersCount) internal view returns(bool isQuorum) {

        isQuorum = signersCount > activeSignersCount / 2 ;

    }

}



// File: contracts/SB_scripts/mainnet/Main0018_preTokenSigners.sol



/* Add pretoken signers */



pragma solidity 0.4.24;







contract Main0018_preTokenSigners {



    PreToken public constant PRE_TOKEN = PreToken(0x97ea02179801FA94227DB5fC1d13Ac4277d40920);

    PreTokenProxy public constant PRE_TOKEN_PROXY = PreTokenProxy(0x8a69cf9d1D85bC150F69FeB80cC34c552F5fbea9);



    function execute(Main0018_preTokenSigners /* self, not used */) external {

        // called via StabilityBoardProxy

        require(address(this) == address(PRE_TOKEN_PROXY), "only execute via PreTokenProxy");



        //  PreToken signers

        address[] memory preTokenSigners = new address[](2);

        preTokenSigners[0] = 0xd8203A652452906586F2E6cB6e31f6f7fed094D4;  // Sz.K.

        preTokenSigners[1] = 0xf9ea0E2857405C859bb8647ECB11f931D1259753;  // P.P.

        PRE_TOKEN_PROXY.addSigners(preTokenSigners);

    }

}