/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity >= 0.4.21 <= 0.5.12;

/*
    Author : Biplav Raj Osti
    LinkedIn : https://www.linkedin.com/in/biplav-osti/
    
    Note: Smart contract has not been audited. Use at your own risk.
    Licensed under New BSD License (3-clause License)
*/

library ECDSA {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param __hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param __signature bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 __hash, bytes memory __signature)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (__signature.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables with inline assembly.
    assembly {
      r := mload(add(__signature, 0x20))
      s := mload(add(__signature, 0x40))
      v := byte(0, mload(add(__signature, 0x60)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(__hash, v, r, s);
    }
  }  
}

/*
    A registry of digital signatures.
    primary usage could be signing through state channels where owner of signature signs a piece of message and sends it to the
    receiver (consumer). The consumer can now use this signature as proof that he is authorized by the owner.
    the consumer will register (consume) that signature in the DigitalSignatureRegistry. the signature is of only one time use in the chain.
    The owner can choose whom to allow or deny to consume the signature.
    Since each signature is of one time use only, this can act as nonce in non replayable meta transaction.
*/
contract DigitalSignatureRegistry {
    using ECDSA for bytes32;
    
    // when new Digital Signature is added/registered
    event DSA(bytes signature, bytes32 message, address consumer);
    
    // owner allows third party to add/register a signed message by owner
    event Allowance(address owner, address consumer);
    
    //owner revokes the ability of third party to submit a signed message
    event Denial(address owner, address consumer);
    
    
    // maps owner => consumer => bool ( owner can have multiple consumer)
    mapping(address => mapping(address => bool)) _allowedTo;
    
    // mapping signature => consumer (used by) address
    mapping(bytes => address) private _consumer;
    
    // mapping signature => message signed
    mapping(bytes => bytes32) private _message;
    
    /*
        Owner allows a consumer to submit a signature
    */
    function allow(address __consumer) public {
        require(__consumer != address(0));
        require(msg.sender != address(0));
        
        _allowedTo[msg.sender][__consumer] = true;
        
        emit Allowance(msg.sender, __consumer);
    }
    
    /*
        Owner revoke the allowance given to a consumer to submit signature
    */
    function deny(address __consumer) public {
        require(__consumer != address(0));
        require(msg.sender != address(0));
        
        _allowedTo[msg.sender][__consumer] = false;
        
        emit Denial(msg.sender, __consumer);
    }
    
    /*
       Owner or the allowed party can register a signaure signed only by owner. 
    */
    function add(bytes memory __signature, bytes32 __message) public returns (bool) {
        
        // signature should not have been consumed already
        require(_consumer[__signature] == address(0));
        
        // check sender to be not zero
        require(msg.sender != address(0));
        
        //recover signer address from signature
        address signer = __message.recover(__signature);
        
        // check consumer (msg.sender) is allowed by signer
        require(msg.sender == signer || _allowedTo[signer][msg.sender]); 
        
        // register consumer and message
        _consumer[__signature] = msg.sender;
        _message[__signature] = __message;
        
        //trigger DS Added event
        emit DSA(__signature, __message, msg.sender);
        
        return true;
    }
    
    // get consumer of a signature
    function consumer(bytes memory __signature) public view returns (address) {
        return _consumer[__signature];
    }
    
    // get message hash of a signature
    function message(bytes memory __signature) public view returns (bytes32) {
        return _message[__signature];
    }
}