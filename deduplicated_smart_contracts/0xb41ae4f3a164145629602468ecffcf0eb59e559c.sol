pragma solidity ^0.4.15;

/**
 * title Eliptic curve signature operations
 *
 * 
 */

library ECRecovery {

  /**
   * Recover signer address from a message by using his signature
   * param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes sig) constant returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      /* prefix might be needed for geth only
      * https://github.com/ethereum/go-ethereum/issues/3731
      */
      bytes memory prefix = "\x19Ethereum Signed Message:\n32";
      hash = sha3(prefix, hash);
      return ecrecover(hash, v, r, s);
    }
  }

}

/**
 * title SafeMath
 * Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * title Ownable
 * The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * Allows the current owner to transfer control of the contract to a newOwner.
   * param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * §¬§à§ß§ä§â§Ñ§Ü§ä §è§Ö§ß§ä§â§Ñ§Ý§î§ß§à§Û §Ý§à§Ô§Ú§Ü§Ú
 */

contract MemeCore is Ownable {
    using SafeMath for uint;
    using ECRecovery for bytes32;

    /* §®§Ñ§á§Ñ §Ñ§Õ§â§Ö§ã §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ñ - nonce, §ß§å§Ø§ß§à §Õ§Ý§ñ §ä§à§Ô§à, §é§ä§à§Ò§í §ß§Ö§Ý§î§Ù§ñ §Ò§í§Ý§à §á§à§Ó§ä§à§â§ß§à §Ù§Ñ§á§â§à§ã§Ú§ä§î withdraw */
    mapping (address => uint) withdrawalsNonce;

    event Withdraw(address receiver, uint weiAmount);
    event WithdrawCanceled(address receiver);

    function() payable {
        require(msg.value != 0);
    }

    /* §©§Ñ§á§â§à§ã §ß§Ñ §Ó§í§á§Ý§Ñ§ä§å §à§ä §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§ñ, §Ú§ã§á§à§Ý§î§Ù§å§Ö§ä§ã§ñ §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §Ü§Ý§Ú§Ö§ß§ä §Õ§Ö§Ý§Ñ§Ö§ä withdraw */
    function _withdraw(address toAddress, uint weiAmount) private {
        // §¥§Ö§Ý§Ñ§Ö§Þ §á§Ö§â§Ö§Ó§à§Õ §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ð
        toAddress.transfer(weiAmount);

        Withdraw(toAddress, weiAmount);
    }


    /* §©§Ñ§á§â§à§ã §ß§Ñ §Ó§í§á§Ý§Ñ§ä§å §à§ä §á§à§Ý§î§Ù§à§Ó§Ñ§ä§Ö§Ý§ñ, §Ú§ã§á§à§Ý§î§Ù§å§Ö§ä§ã§ñ §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §Ü§Ý§Ú§Ö§ß§ä §Õ§Ö§Ý§Ñ§Ö§ä withdraw */
    function withdraw(uint weiAmount, bytes signedData) external {
        uint256 nonce = withdrawalsNonce[msg.sender] + 1;

        bytes32 validatingHash = keccak256(msg.sender, weiAmount, nonce);

        // §±§à§Õ§á§Ú§ã§í§Ó§Ñ§ä§î §Ó§ã§Ö §ä§â§Ñ§ß§Ù§Ñ§Ü§è§Ú§Ú §Õ§à§Ý§Ø§Ö§ß owner
        address addressRecovered = validatingHash.recover(signedData);

        require(addressRecovered == owner);

        // §¥§Ö§Ý§Ñ§Ö§Þ §á§Ö§â§Ö§Ó§à§Õ §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ð
        _withdraw(msg.sender, weiAmount);

        withdrawalsNonce[msg.sender] = nonce;
    }

    /* §°§ä§Þ§Ö§ß§Ñ withdraw */
    function cancelWithdraw(){
        withdrawalsNonce[msg.sender]++;

        WithdrawCanceled(msg.sender);
    }

    /* §¥§à§ã§ä§å§á§ß§Ñ §ä§à§Ý§î§Ü§à owner'§å, §Ú§ã§á§à§Ý§î§Ù§å§Ö§ä§ã§ñ §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú §Ò§ï§Ü§Ö§ß§Õ §Õ§Ö§Ý§Ñ§Ö§ä withdraw */
    function backendWithdraw(address toAddress, uint weiAmount) external onlyOwner {
        require(toAddress != 0);

        // §¥§Ö§Ý§Ñ§Ö§Þ §á§Ö§â§Ö§Ó§à§Õ §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ð
        _withdraw(toAddress, weiAmount);
    }

}