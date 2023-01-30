/**

 *Submitted for verification at Etherscan.io on 2019-04-10

*/



pragma solidity ^0.5.3;



contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    function owner() public view returns (address) {

        return _owner;

    }



    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



contract RelayRegistry is Ownable {

    

    event AddedRelay(address relay);

    event RemovedRelay(address relay);

    

    mapping (address => bool) public relays;

    

    constructor(address initialRelay) public {

        relays[initialRelay] = true;

    }

    

    function triggerRelay(address relay, bool value) onlyOwner public returns (bool) {

        relays[relay] = value;

        if(value) {

            emit AddedRelay(relay);

        } else {

            emit RemovedRelay(relay);

        }

        return true;

    }

    

}



interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

}



// All functions of SmartWallet Implementations should be called using delegatecall

contract SmartWallet {



    event Upgrade(address indexed newImplementation);



    // Shared key value store. Data should be encoded and decoded using abi.encode()/abi.decode() by different implementations

    mapping (bytes32 => bytes) public store;

    

    modifier onlyRelay {

        RelayRegistry registry = RelayRegistry(0xd23e2F482005a90FC2b8dcDd58affc05D5776cb7); // relay registry address

        require(registry.relays(msg.sender));

        _;

    }

    

    modifier onlyOwner {

        require(msg.sender == abi.decode(store["owner"], (address)) || msg.sender == abi.decode(store["factory"], (address)));

        _;

    }

    

    function initiate(address owner) public returns (bool) {

        // this function can only be called by the factory

        if(msg.sender != abi.decode(store["factory"], (address))) return false;

        // store current owner in key store

        store["owner"] = abi.encode(owner);

        store["nonce"] = abi.encode(0);

        return true;

    }

    

    // Called by factory to initiate state if deployment was relayed

    function initiate(address owner, address relay, uint fee, address token) public returns (bool) {

        require(initiate(owner), "internal initiate failed");

        // Access ERC20 token

        IERC20 tokenContract = IERC20(token);

        // Send fee to relay

        require(tokenContract.transfer(relay, fee), "fee transfer failed");

        return true;

    }

    

    function pay(address to, uint value, uint fee, address tokenContract, uint8 v, bytes32 r, bytes32 s) onlyRelay public returns (bool) {

        uint currentNonce = abi.decode(store["nonce"], (uint));

        require(abi.decode(store["owner"], (address)) == recover(keccak256(abi.encodePacked(msg.sender, to, tokenContract, abi.decode(store["factory"], (address)), value, fee, tx.gasprice, currentNonce)), v, r, s));

        IERC20 token = IERC20(tokenContract);

        store["nonce"] = abi.encode(currentNonce+1);

        require(token.transfer(to, value));

        require(token.transfer(msg.sender, fee));

        return true;

    }

    

    function pay(address to, uint value, address tokenContract) onlyOwner public returns (bool) {

        IERC20 token = IERC20(tokenContract);

        require(token.transfer(to, value));

        return true;

    }

    

    function pay(address[] memory to, uint[] memory value, address[] memory tokenContract) onlyOwner public returns (bool) {

        for (uint i; i < to.length; i++) {

            IERC20 token = IERC20(tokenContract[i]);

            require(token.transfer(to[i], value[i]));

        }

        return true;

    }

    

    function upgrade(address implementation, uint fee, address feeContract, uint8 v, bytes32 r, bytes32 s) onlyRelay public returns (bool) {

        uint currentNonce = abi.decode(store["nonce"], (uint));

        address owner = abi.decode(store["owner"], (address));

        address factory = abi.decode(store["factory"], (address));

        require(owner == recover(keccak256(abi.encodePacked(msg.sender, implementation, feeContract, factory, fee, tx.gasprice, currentNonce)), v, r, s));

        store["nonce"] = abi.encode(currentNonce+1);

        store["fallback"] = abi.encode(implementation);

        IERC20 feeToken = IERC20(feeContract);

        require(feeToken.transfer(msg.sender, fee));

        emit Upgrade(implementation);

        return true;

        

    }

    

    function upgrade(address implementation) onlyOwner public returns (bool) {

        store["fallback"] = abi.encode(implementation);

        emit Upgrade(implementation);

        return true;

    }

    

    

    function recover(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        bytes32 prefixedMessageHash = keccak256(abi.encodePacked(prefix, messageHash));

        return ecrecover(prefixedMessageHash, v, r, s);

    }

    

}