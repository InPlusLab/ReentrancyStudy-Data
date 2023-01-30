/**
 *Submitted for verification at Etherscan.io on 2019-10-27
*/

pragma solidity > 0.5.2 < 0.6.0;

contract MultiSig {
    // Addresses of the MultiSig representatives
    address private addr1;
    address private addr2;
    address private addr3;

    // Address of the contract that manages the tokens
    address private tokenContract;
    
    // This is necessary to detect malleable signatures.
    uint256 constant HALF_CURVE_ORDER = uint256(0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0);
    
    /**
     * Signatures must not be used twice. Therefore, they need to contain a unique
     * value. These nonces need to be stored such that an additional usage is detectable.
     */
    mapping (bytes32 => bool) public nonces;
    
    /**
     * @param _addr1 first authorized representative
     * @param _addr2 second authorized representative
     * @param _addr3 third authorized representative
     * @param _tokenContract address of the contract that manages the tokens
     */
    constructor(address _addr1, address _addr2, address _addr3, address _tokenContract) public {
        require(_addr1 != _addr2 && _addr2 != _addr3 && _addr1 != _addr3, 'MultiSig representatives must not be the same.');

        addr1 = _addr1;
        addr2 = _addr2;
        addr3 = _addr3;

        tokenContract = _tokenContract;
    }

    /**
     * Checks whether the signature of the transaction and the co-signature come from the expected addresses. If that
     * is the case, deploy a smart contract at a precomputable address that transfers `amount` tokens from itselfs balance
     * to `to`.
     *
     * @param amount how much token should be transferred
     * @param sender address of the token sender
     * @param to address of the token receiver
     * @param r first part of the co-signature
     * @param s second part of the co-signature
     * @param v recovery value of the co-signature
     */
    function claim(uint256 amount, address sender, address to, bytes32 r, bytes32 s, uint8 v, bytes32 salt) public {
        checkSignature(amount, sender, to, r, s, v);
        
        deploy(salt, sender, to, amount);
    }
    
    /**
     * Checks whether the signature of the transaction comes from one of the expected addresses. It also checks
     * whether the given co-signature comes from one of the expected addresses, excluding the address of the 
     * transaction sender.
     *
     * @param amount the amount of assets that are transferred
     * @param sender address of the token sender
     * @param to address of the token receiver
     * @param r first part of the co-signature
     * @param s second part of the co-signature
     * @param v recovery value of the co-signature
     */
    function checkSignature(uint256 amount, address sender, address to, bytes32 r, bytes32 s, uint8 v) internal {
        require(msg.sender == addr1 || msg.sender == addr2 || msg.sender == addr3, "Invalid signer.");

        require(uint256(s) <= HALF_CURVE_ORDER, "Found malleable signature. Please insert a low-s signature.");
        
        bytes32 msgString = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n96",
            tokenContract,
            bytes4(keccak256("transfer(address,uint256)")),
            sender,
            to,
            amount
        ));
        
        address signer = ecrecover(msgString, v, r, s);

        require(signer != msg.sender, "Cosigner and signer must not be the same.");

        require(signer == addr1 || signer == addr2 || signer == addr3, "Invalid co-signer.");

        require(!nonces[msgString], "Nonce was already used.");
        nonces[msgString] = true;
    }
    
    /**
     * This deploys a smart contract which checks that `msg.sender == address()` where `address()` is the
     * address of this contract. The newly deployed smart contract then transfers `amount` tokens that are
     * stored in `tokenContract` to `to`.
     * Afterwards, the newly created contract triggers a self-destroy to save gas.
     *
     * @param salt used as user identifier to make contracts unique
     * @param to address of the receiver
     * @param amount amount of tokens that are transferred
     */
    function deploy(bytes32 salt, address sender, address to, uint256 amount) internal {
        bytes memory result = new bytes(273);
        address addr;

        assembly {
            let bytecode := add(result, 0x20)
            
            mstore(add(bytecode, 0),  0x608060405234801561001057600080fd5b5060f28061001f6000396000f3fe60) // 32 bytes
            mstore(add(bytecode, 32),  0x80604052348015600f57600080fd5b506004361060285760003560e01c8063a9) // 32 bytes
            mstore(add(bytecode, 64),  0x059cbb14602d575b600080fd5b605660048036036040811015604157600080fd) // 32 bytes
            mstore(add(bytecode, 96),  0x5b506001600160a01b0381351690602001356058565b005b7300000000000000) // 25 bytes

            mstore(add(bytecode, 121), shl(96, address())) // 20 bytes

            mstore(add(bytecode, 141), 0x803314607857600080fd5b730000000000000000000000000000000000000000) // 12 bytes

            mstore(add(bytecode, 153), shl(96, sload(tokenContract_slot))) // 20 bytes

            mstore(add(bytecode, 173), 0x60405163a9059cbb60e01b815284600482015283602482015260008060448360) // 32 bytes
            mstore(add(bytecode, 205), 0x00865af18060ba57600080fd5b83fffea265627a7a72305820a57bc3e7ae7d2e) // 32 bytes
            mstore(add(bytecode, 237), 0xb2dbb60e9abedab864f8ff1848db33ef2cec7a159a1793027864736f6c634300) // 32 bytes
            mstore(add(bytecode, 269), 0x0509003200000000000000000000000000000000000000000000000000000000) // 32 bytes
            
            // creates a new contract at a counterfactual address.
            // see http://eips.ethereum.org/EIPS/eip-1014 for more information
            // and https://github.com/miguelmota/solidity-create2-example for a PoC
            addr := create2(0, bytecode, 273, salt)
            
            if iszero(eq(addr, sender)) {
                revert(0,0)
            }

            mstore(bytecode, shl(224, 0xa9059cbb))
            mstore(add(bytecode, 4), to)
            mstore(add(bytecode, 36), amount)
            
            // Revert if not successful
            if iszero(call(gas(), addr, 0, bytecode, 68, 0, 0)) {
                revert(0,0)
            }
        }
    }
}