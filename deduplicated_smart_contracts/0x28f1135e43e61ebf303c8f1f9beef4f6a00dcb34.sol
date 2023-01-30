pragma solidity ^0.4.19;

/**
 * XC Contract Interface.
 */
interface XCInterface {

    /**
     * Set contract service status.
     * @param status contract service status (0:closed;1:only-closed-lock;2:only-closed-unlock;3:opened;).
     */
    function setStatus(uint8 status) external;

    /**
     * Get contract service status.
     * @return contract service status.
     */
    function getStatus() external view returns (uint8);

    /**
     * Get the current contract platform name.
     * @return contract platform name.
     */
    function getPlatformName() external view returns (bytes32);

    /**
     * Set the current contract administrator.
     * @param account account of contract administrator.
     */
    function setAdmin(address account) external;

    /**
     * Get the current contract administrator.
     * @return contract administrator.
     */
    function getAdmin() external view returns (address);

    /**
     * Set the Token contract address.
     * @param account contract address.
     */
    function setToken(address account) external;

    /**
     * Get the Token contract address.
     * @return contract address.
     */
    function getToken() external view returns (address);

    /**
     * Set the XCPlugin contract address.
     * @param account contract address.
     */
    function setXCPlugin(address account) external;

    /**
     * Get the XCPlugin contract address.
     * @return contract address.
     */
    function getXCPlugin() external view returns (address);

    /**
     * Transfer out of cross chain.
     * @param toAccount account of to platform.
     * @param value transfer amount.
     */
    function lock(address toAccount, uint value) external;

    /**
     * Transfer in of cross chain.
     * @param txid transaction id.
     * @param fromAccount ame of to platform.
     * @param toAccount account of to platform.
     * @param value transfer amount.
     */
    function unlock(string txid, address fromAccount, address toAccount, uint value) external;

    /**
     * Transfer the misoperation to the amount of the contract account to the specified account.
     * @param account the specified account.
     * @param value transfer amount.
     */
    function withdraw(address account, uint value) external;
}

/**
 * XC Plugin Contract Interface.
 */
interface XCPluginInterface {

    /**
     * Open the contract service status.
     */
    function start() external;

    /**
     * Close the contract service status.
     */
    function stop() external;

    /**
     * Get contract service status.
     * @return contract service status.
     */
    function getStatus() external view returns (bool);

    /**
     * Get the current contract platform name.
     * @return contract platform name.
     */
    function getPlatformName() external view returns (bytes32);

    /**
     * Set the current contract administrator.
     * @param account account of contract administrator.
     */
    function setAdmin(address account) external;

    /**
     * Get the current contract administrator.
     * @return contract administrator.
     */
    function getAdmin() external view returns (address);

    /**
     * Get the current token symbol.
     * @return token symbol.
     */
    function getTokenSymbol() external view returns (bytes32);

    /**
     * Add a contract trust caller.
     * @param caller account of caller.
     */
    function addCaller(address caller) external;

    /**
     * Delete a contract trust caller.
     * @param caller account of caller.
     */
    function deleteCaller(address caller) external;

    /**
     * Whether the trust caller exists.
     * @param caller account of caller.
     * @return whether exists.
     */
    function existCaller(address caller) external view returns (bool);

    /**
     * Get all contract trusted callers.
     * @return al lcallers.
     */
    function getCallers() external view returns (address[]);

    /**
     * Get the trusted platform name.
     * @return name a platform name.
     */
    function getTrustPlatform() external view returns (bytes32 name);

    /**
     * Add the trusted platform public key information.
     * @param publicKey a public key.
     */
    function addPublicKey(address publicKey) external;

    /**
     * Delete the trusted platform public key information.
     * @param publicKey a public key.
     */
    function deletePublicKey(address publicKey) external;

    /**
     * Whether the trusted platform public key information exists.
     * @param publicKey a public key.
     */
    function existPublicKey(address publicKey) external view returns (bool);

    /**
     * Get the count of public key for the trusted platform.
     * @return count of public key.
     */
    function countOfPublicKey() external view returns (uint);

    /**
     * Get the list of public key for the trusted platform.
     * @return list of public key.
     */
    function publicKeys() external view returns (address[]);

    /**
     * Set the weight of a trusted platform.
     * @param weight weight of platform.
     */
    function setWeight(uint weight) external;

    /**
     * Get the weight of a trusted platform.
     * @return weight of platform.
     */
    function getWeight() external view returns (uint);

    /**
     * Initiate and vote on the transaction proposal.
     * @param fromAccount name of to platform.
     * @param toAccount account of to platform.
     * @param value transfer amount.
     * @param txid transaction id.
     * @param sig transaction signature.
     */
    function voteProposal(address fromAccount, address toAccount, uint value, string txid, bytes sig) external;

    /**
     * Verify that the transaction proposal is valid.
     * @param fromAccount name of to platform.
     * @param toAccount account of to platform.
     * @param value transfer amount.
     * @param txid transaction id.
     */
    function verifyProposal(address fromAccount, address toAccount, uint value, string txid) external view returns (bool, bool);

    /**
     * Commit the transaction proposal.
     * @param txid transaction id.
     */
    function commitProposal(string txid) external returns (bool);

    /**
     * Get the transaction proposal information.
     * @param txid transaction id.
     * @return status completion status of proposal.
     * @return fromAccount account of to platform.
     * @return toAccount account of to platform.
     * @return value transfer amount.
     * @return voters notarial voters.
     * @return weight The weight value of the completed time.
     */
    function getProposal(string txid) external view returns (bool status, address fromAccount, address toAccount, uint value, address[] voters, uint weight);

    /**
     * Delete the transaction proposal information.
     * @param txid transaction id.
     */
    function deleteProposal(string txid) external;
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Token {

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);
}

contract XCPlugin is XCPluginInterface {

    /**
     * Contract Administrator
     * @field status Contract external service status.
     * @field platformName Current contract platform name.
     * @field tokenSymbol token Symbol.
     * @field account Current contract administrator.
     */
    struct Admin {
        bool status;
        bytes32 platformName;
        bytes32 tokenSymbol;
        address account;
        string version;
    }

    /**
     * Transaction Proposal
     * @field status Transaction proposal status(false:pending,true:complete).
     * @field fromAccount Account of form platform.
     * @field toAccount Account of to platform.
     * @field value Transfer amount.
     * @field tokenSymbol token Symbol.
     * @field voters Proposers.
     * @field weight The weight value of the completed time.
     */
    struct Proposal {
        bool status;
        address fromAccount;
        address toAccount;
        uint value;
        address[] voters;
        uint weight;
    }

    /**
     * Trusted Platform
     * @field status Trusted platform state(false:no trusted,true:trusted).
     * @field weight weight of platform.
     * @field publicKeys list of public key.
     * @field proposals list of proposal.
     */
    struct Platform {
        bool status;
        bytes32 name;
        uint weight;
        address[] publicKeys;
        mapping(string => Proposal) proposals;
    }

    Admin private admin;

    address[] private callers;

    Platform private platform;


    constructor() public {
        init();
    }

    /**
     * TODO Parameters that must be set before compilation
     * $Init admin.status
     * $Init admin.platformName
     * $Init admin.tokenSymbol
     * $Init admin.account
     * $Init admin.version
     * $Init platform.status
     * $Init platform.name
     * $Init platform.weight
     * $Init platform.publicKeys
     */
    function init() internal {
        // Admin { status | platformName | tokenSymbol | account}
        admin.status = true;
        admin.platformName = "ETH";
        admin.tokenSymbol = "INK";
        admin.account = msg.sender;
        admin.version = "1.0";
        platform.status = true;
        platform.name = "INK";
        platform.weight = 3;
        platform.publicKeys.push(0x80aa17b21c16620a4d7dd06ec1dcc44190b02ca0);
        platform.publicKeys.push(0xd2e40bb4967b355da8d70be40c277ebcf108063c);
        platform.publicKeys.push(0x1501e0f09498aa95cb0c2f1e3ee51223e5074720);
    }

    function start() onlyAdmin external {
        if (!admin.status) {
            admin.status = true;
        }
    }

    function stop() onlyAdmin external {
        if (admin.status) {
            admin.status = false;
        }
    }

    function getStatus() external view returns (bool) {
        return admin.status;
    }

    function getPlatformName() external view returns (bytes32) {
        return admin.platformName;
    }

    function setAdmin(address account) onlyAdmin nonzeroAddress(account) external {
        if (admin.account != account) {
            admin.account = account;
        }
    }

    function getAdmin() external view returns (address) {
        return admin.account;
    }

    function getTokenSymbol() external view returns (bytes32) {
        return admin.tokenSymbol;
    }

    function addCaller(address caller) onlyAdmin nonzeroAddress(caller) external {
        if (!_existCaller(caller)) {
            callers.push(caller);
        }
    }

    function deleteCaller(address caller) onlyAdmin nonzeroAddress(caller) external {
        for (uint i = 0; i < callers.length; i++) {
            if (callers[i] == caller) {
                if (i != callers.length - 1 ) {
                    callers[i] = callers[callers.length - 1];
                }
                callers.length--;
                return;
            }
        }
    }

    function existCaller(address caller) external view returns (bool) {
        return _existCaller(caller);
    }

    function getCallers() external view returns (address[]) {
        return callers;
    }

    function getTrustPlatform() external view returns (bytes32 name){
        return platform.name;
    }

    function setWeight(uint weight) onlyAdmin external {
        require(weight > 0);
        if (platform.weight != weight) {
            platform.weight = weight;
        }
    }

    function getWeight() external view returns (uint) {
        return platform.weight;
    }

    function addPublicKey(address publicKey) onlyAdmin nonzeroAddress(publicKey) external {
        address[] storage publicKeys = platform.publicKeys;
        for (uint i; i < publicKeys.length; i++) {
            if (publicKey == publicKeys[i]) {
                return;
            }
        }
        publicKeys.push(publicKey);
    }

    function deletePublicKey(address publicKey) onlyAdmin nonzeroAddress(publicKey) external {
        address[] storage publicKeys = platform.publicKeys;
        for (uint i = 0; i < publicKeys.length; i++) {
            if (publicKeys[i] == publicKey) {
                if (i != publicKeys.length - 1 ) {
                    publicKeys[i] = publicKeys[publicKeys.length - 1];
                }
                publicKeys.length--;
                return;
            }
        }
    }

    function existPublicKey(address publicKey) external view returns (bool) {
        return _existPublicKey(publicKey);
    }

    function countOfPublicKey() external view returns (uint){
        return platform.publicKeys.length;
    }

    function publicKeys() external view returns (address[]){
        return platform.publicKeys;
    }

    function voteProposal(address fromAccount, address toAccount, uint value, string txid, bytes sig) opened external {
        bytes32 msgHash = hashMsg(platform.name, fromAccount, admin.platformName, toAccount, value, admin.tokenSymbol, txid,admin.version);
        address publicKey = recover(msgHash, sig);
        require(_existPublicKey(publicKey));
        Proposal storage proposal = platform.proposals[txid];
        if (proposal.value == 0) {
            proposal.fromAccount = fromAccount;
            proposal.toAccount = toAccount;
            proposal.value = value;
        } else {
            require(proposal.fromAccount == fromAccount && proposal.toAccount == toAccount && proposal.value == value);
        }
        changeVoters(publicKey, txid);
    }

    function verifyProposal(address fromAccount, address toAccount, uint value, string txid) external view returns (bool, bool) {
        Proposal storage proposal = platform.proposals[txid];
        if (proposal.status) {
            return (true, (proposal.voters.length >= proposal.weight));
        }
        if (proposal.value == 0) {
            return (false, false);
        }
        require(proposal.fromAccount == fromAccount && proposal.toAccount == toAccount && proposal.value == value);
        return (false, (proposal.voters.length >= platform.weight));
    }

    function commitProposal(string txid) external returns (bool) {
        require((admin.status &&_existCaller(msg.sender)) || msg.sender == admin.account);
        require(!platform.proposals[txid].status);
        platform.proposals[txid].status = true;
        platform.proposals[txid].weight = platform.proposals[txid].voters.length;
        return true;
    }

    function getProposal(string txid) external view returns (bool status, address fromAccount, address toAccount, uint value, address[] voters, uint weight){
        fromAccount = platform.proposals[txid].fromAccount;
        toAccount = platform.proposals[txid].toAccount;
        value = platform.proposals[txid].value;
        voters = platform.proposals[txid].voters;
        status = platform.proposals[txid].status;
        weight = platform.proposals[txid].weight;
        return;
    }

    function deleteProposal(string txid) onlyAdmin external {
        delete platform.proposals[txid];
    }

    /**
     *   ######################
     *  #  private function  #
     * ######################
     */

    function hashMsg(bytes32 fromPlatform, address fromAccount, bytes32 toPlatform, address toAccount, uint value, bytes32 tokenSymbol, string txid,string version) internal pure returns (bytes32) {
        return sha256(bytes32ToStr(fromPlatform), ":0x", uintToStr(uint160(fromAccount), 16), ":", bytes32ToStr(toPlatform), ":0x", uintToStr(uint160(toAccount), 16), ":", uintToStr(value, 10), ":", bytes32ToStr(tokenSymbol), ":", txid, ":", version);
    }

    function changeVoters(address publicKey, string txid) internal {
        address[] storage voters = platform.proposals[txid].voters;
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == publicKey) {
                return;
            }
        }
        voters.push(publicKey);
    }

    function bytes32ToStr(bytes32 b) internal pure returns (string) {
        uint length = b.length;
        for (uint i = 0; i < b.length; i++) {
            if (b[b.length - 1 - i] != "") {
                length -= i;
                break;
            }
        }
        bytes memory bs = new bytes(length);
        for (uint j = 0; j < length; j++) {
            bs[j] = b[j];
        }
        return string(bs);
    }

    function uintToStr(uint value, uint base) internal pure returns (string) {
        uint _value = value;
        uint length = 0;
        bytes16 tenStr = "0123456789abcdef";
        while (true) {
            if (_value > 0) {
                length ++;
                _value = _value / base;
            } else {
                break;
            }
        }
        if (base == 16) {
            length = 40;
        }
        bytes memory bs = new bytes(length);
        for (uint i = 0; i < length; i++) {
            bs[length - 1 - i] = tenStr[value % base];
            value = value / base;
        }
        return string(bs);
    }

    function _existCaller(address caller) internal view returns (bool) {
        for (uint i = 0; i < callers.length; i++) {
            if (callers[i] == caller) {
                return true;
            }
        }
        return false;
    }

    function _existPublicKey(address publicKey) internal view returns (bool) {
        address[] memory publicKeys = platform.publicKeys;
        for (uint i = 0; i < publicKeys.length; i++) {
            if (publicKeys[i] == publicKey) {
                return true;
            }
        }
        return false;
    }

    function recover(bytes32 hash, bytes sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        return ecrecover(hash, v, r, s);
    }

    modifier onlyAdmin {
        require(admin.account == msg.sender);
        _;
    }

    modifier nonzeroAddress(address account) {
        require(account != address(0));
        _;
    }

    modifier opened() {
        require(admin.status);
        _;
    }
}

contract XC is XCInterface {

    /**
     * Contract Administrator
     * @field status Contract external service status.
     * @field platformName Current contract platform name.
     * @field account Current contract administrator.
     */
    struct Admin {
        uint8 status;
        bytes32 platformName;
        address account;
    }

    Admin private admin;

    uint public lockBalance;

    Token private token;

    XCPlugin private xcPlugin;

    event Lock(bytes32 toPlatform, address toAccount, bytes32 value, bytes32 tokenSymbol);

    event Unlock(string txid, bytes32 fromPlatform, address fromAccount, bytes32 value, bytes32 tokenSymbol);

    constructor() public {
        init();
    }

    /**
     * TODO Parameters that must be set before compilation
     * $Init admin.status
     * $Init admin.platformName
     * $Init admin.account
     * $Init lockBalance
     * $Init token
     * $Init xcPlugin
     */
    function init() internal {
        // Admin {status | platformName | account}
        admin.status = 3;
        admin.platformName = "ETH";
        admin.account = msg.sender;
        lockBalance = 344737963881081236;
        token = Token(0xf4c90e18727c5c76499ea6369c856a6d61d3e92e);
        xcPlugin = XCPlugin(0x15782cc68d841416f73e8f352f27cc1bc5e76e11);
    }

    function setStatus(uint8 status) onlyAdmin external {
        require(status <= 3);
        if (admin.status != status) {
            admin.status = status;
        }
    }

    function getStatus() external view returns (uint8) {
        return admin.status;
    }

    function getPlatformName() external view returns (bytes32) {
        return admin.platformName;
    }

    function setAdmin(address account) onlyAdmin nonzeroAddress(account) external {
        if (admin.account != account) {
            admin.account = account;
        }
    }

    function getAdmin() external view returns (address) {
        return admin.account;
    }

    function setToken(address account) onlyAdmin nonzeroAddress(account) external {
        if (token != account) {
            token = Token(account);
        }
    }

    function getToken() external view returns (address) {
        return token;
    }

    function setXCPlugin(address account) onlyAdmin nonzeroAddress(account) external {
        if (xcPlugin != account) {
            xcPlugin = XCPlugin(account);
        }
    }

    function getXCPlugin() external view returns (address) {
        return xcPlugin;
    }

    function lock(address toAccount, uint value) nonzeroAddress(toAccount) external {
        require(admin.status == 2 || admin.status == 3);
        require(xcPlugin.getStatus());
        require(value > 0);
        uint allowance = token.allowance(msg.sender, this);
        require(allowance >= value);
        bool success = token.transferFrom(msg.sender, this, value);
        require(success);
        lockBalance = SafeMath.add(lockBalance, value);
        emit Lock(xcPlugin.getTrustPlatform(), toAccount, bytes32(value), xcPlugin.getTokenSymbol());
    }

    function unlock(string txid, address fromAccount, address toAccount, uint value) nonzeroAddress(toAccount) external {
        require(admin.status == 1 || admin.status == 3);
        require(xcPlugin.getStatus());
        require(value > 0);
        bool complete;
        bool verify;
        (complete, verify) = xcPlugin.verifyProposal(fromAccount, toAccount, value, txid);
        require(verify && !complete);
        uint balance = token.balanceOf(this);
        require(balance >= value);
        require(token.transfer(toAccount, value));
        require(xcPlugin.commitProposal(txid));
        lockBalance = SafeMath.sub(lockBalance, value);
        emit Unlock(txid, xcPlugin.getTrustPlatform(), fromAccount, bytes32(value), xcPlugin.getTokenSymbol());
    }

    function withdraw(address account, uint value) onlyAdmin nonzeroAddress(account) external {
        require(value > 0);
        uint balance = token.balanceOf(this);
        require(SafeMath.sub(balance, lockBalance) >= value);
        bool success = token.transfer(account, value);
        require(success);
    }

    modifier onlyAdmin {
        require(admin.account == msg.sender);
        _;
    }

    modifier nonzeroAddress(address account) {
        require(account != address(0));
        _;
    }
}