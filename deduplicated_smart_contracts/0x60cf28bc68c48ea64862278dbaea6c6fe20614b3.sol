pragma solidity 0.4.24;

import "SafeMath.sol";

/**
 * TheNux Coin token contract. It implements the next capabilities:
 * 1. Standard ERC20 functionality. [OK]
 * 2. Additional utility function approveAndCall. [OK]
 * 3. Function to rescue "lost forever" tokens, which were accidentally sent to the contract address. [OK]
 * 4. Additional transfer and approve functions which allow to distinct the transaction signer and executor,
 *    which enables accounts with no Ether on their balances to make token transfers and use TheNux Coin services. [OK]
 * 5. Token sale distribution rules. [OK]
 */
contract TheNuxCoin {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals; // Makes JavaScript able to handle precise calculations (until totalSupply < 9 milliards)
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => mapping(uint => bool)) public usedSigIds; // Used in *ViaSignature(..)
    address public tokenDistributor; // Account authorized to distribute tokens only during the token distribution event

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier tokenDistributionPeriodOnly {require(tokenDistributor == msg.sender); _;}

    enum sigStandard { typed, personal, stringHex }

    bytes constant public ethSignedMessagePrefix = "\x19Ethereum Signed Message:\n";
    bytes32 constant public sigDestinationTransfer = keccak256(
        "address Token Contract Address",
        "address Sender's Address",
        "address Recipient's Address",
        "uint256 Amount to Transfer (last six digits are decimals)",
        "uint256 Fee in Tokens Paid to Executor (last six digits are decimals)",
        "address Account which will Receive Fee",
        "uint256 Signature Expiration Timestamp (unix timestamp)",
        "uint256 Signature ID"
    ); // `transferViaSignature`: keccak256(address(this), from, to, value, fee, deadline, sigId)

    /**
     * @param tokenName - full token name
     * @param tokenSymbol - token symbol
     */
    constructor (string tokenName, string tokenSymbol, uint8 tokenDecimals, uint256 tokenTotalSupply) public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        totalSupply = tokenTotalSupply;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(tokenTotalSupply);
        tokenDistributor = msg.sender;
    }

    /**
     * Utility internal function used to safely transfer `value` tokens `from` -> `to`. Throws if transfer is impossible.
     * @param from - account to make the transfer from
     * @param to - account to transfer `value` tokens to
     * @param value - tokens to transfer to account `to`
     */
    function internalTransfer (address from, address to, uint value) internal {
        require(to != 0x0); // Prevent people from accidentally burning their tokens
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * Utility internal function used to safely transfer `value1` tokens `from` -> `to1`, and `value2` tokens
     * `from` -> `to2`, minimizing gas usage (calling `internalTransfer` twice is more expensive). Throws if
     * transfers are impossible.
     * @param from - account to make the transfer from
     * @param to1 - account to transfer `value1` tokens to
     * @param value1 - tokens to transfer to account `to1`
     * @param to2 - account to transfer `value2` tokens to
     * @param value2 - tokens to transfer to account `to2`
     */
    function internalDoubleTransfer (address from, address to1, uint value1, address to2, uint value2) internal {
        require(to1 != 0x0 && to2 != 0x0); // Prevent people from accidentally burning their tokens
        balanceOf[from] = balanceOf[from].sub(value1.add(value2));
        balanceOf[to1] = balanceOf[to1].add(value1);
        emit Transfer(from, to1, value1);
        if (value2 > 0) {
            balanceOf[to2] = balanceOf[to2].add(value2);
            emit Transfer(from, to2, value2);
        }
    }

    /**
     * Internal method that makes sure that the given signature corresponds to a given data and is made by `signer`.
     * It utilizes three (four) standards of message signing in Ethereum, as at the moment of this smart contract
     * development there is no single signing standard defined. For example, Metamask and Geth both support
     * personal_sign standard, SignTypedData is only supported by Matamask, Trezor does not support "widely adopted"
     * Ethereum personal_sign but rather personal_sign with fixed prefix and so on.
     * Note that it is always possible to forge any of these signatures using the private key, the problem is that
     * third-party wallets must adopt a single standard for signing messages.
     * @param data - original data which had to be signed by `signer`
     * @param signer - account which made a signature
     * @param deadline - until when the signature is valid
     * @param sigId - signature unique ID. Signatures made with the same signature ID cannot be submitted twice
     * @param sig - signature made by `from`, which is the proof of `from`'s agreement with the above parameters
     * @param sigStd - chosen standard for signature validation. The signer must explicitly tell which standard they use
     */
    function requireSignature (
        bytes32 data,
        address signer,
        uint256 deadline,
        uint256 sigId,
        bytes sig,
        sigStandard sigStd
    ) internal {
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly { // solium-disable-line security/no-inline-assembly
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27)
            v += 27;
        require(block.timestamp <= deadline && !usedSigIds[signer][sigId]); // solium-disable-line security/no-block-members
        if (sigStd == sigStandard.typed) { // Typed signature. This is the most likely scenario to be used and accepted
            require(
                signer == ecrecover(
                    keccak256(
                        sigDestinationTransfer,
                        data
                    ),
                    v, r, s
                )
            );
        } else if (sigStd == sigStandard.personal) { // Ethereum signed message signature (Geth and Trezor)
            require(
                signer == ecrecover(keccak256(ethSignedMessagePrefix, "32", data), v, r, s) // Geth-adopted
                ||
                signer == ecrecover(keccak256(ethSignedMessagePrefix, "\x20", data), v, r, s) // Trezor-adopted
            );
        } else { // == 2; Signed string hash signature (the most expensive but universal)
            require(
                signer == ecrecover(keccak256(ethSignedMessagePrefix, "64", hexToString(data)), v, r, s) // Geth
                ||
                signer == ecrecover(keccak256(ethSignedMessagePrefix, "\x40", hexToString(data)), v, r, s) // Trezor
            );
        }
        usedSigIds[signer][sigId] = true;
    }

    /**
     * Utility costly function to encode bytes HEX representation as string.
     * @param sig - signature as bytes32 to represent as string
     */
    function hexToString (bytes32 sig) internal pure returns (bytes) { // /to-try/ convert to two uint256 and test gas
        bytes memory str = new bytes(64);
        for (uint8 i = 0; i < 32; ++i) {
            str[2 * i] = byte((uint8(sig[i]) / 16 < 10 ? 48 : 87) + uint8(sig[i]) / 16);
            str[2 * i + 1] = byte((uint8(sig[i]) % 16 < 10 ? 48 : 87) + (uint8(sig[i]) % 16));
        }
        return str;
    }

    /**
     * Transfer `value` tokens to `to` address from the account of sender.
     * @param to - the address of the recipient
     * @param value - the amount to send
     */
    function transfer (address to, uint256 value) public returns (bool) {
        internalTransfer(msg.sender, to, value);
        return true;
    }

    /**
     * This function distincts transaction signer from transaction executor. It allows anyone to transfer tokens
     * from the `from` account by providing a valid signature, which can only be obtained from the `from` account
     * owner.
     * Note that passed parameter sigId is unique and cannot be passed twice (prevents replay attacks). When there's
     * a need to make signature once again (because the first on is lost or whatever), user should sign the message
     * with the same sigId, thus ensuring that the previous signature won't be used if the new one passes.
     * Use case: the user wants to send some tokens to other user or smart contract, but don't have ether to do so.
     * @param from - the account giving its signature to transfer `value` tokens to `to` address
     * @param to - the account receiving `value` tokens
     * @param value - the value in tokens to transfer
     * @param fee - a fee to pay to `feeRecipient`
     * @param feeRecipient - account which will receive fee
     * @param deadline - until when the signature is valid
     * @param sigId - signature unique ID. Signatures made with the same signature ID cannot be submitted twice
     * @param sig - signature made by `from`, which is the proof of `from`'s agreement with the above parameters
     * @param sigStd - chosen standard for signature validation. The signer must explicitly tell which standard they use
     */
    function transferViaSignature (  
        address     from,
        address     to,
        uint256     value,
        uint256     fee,
        address     feeRecipient,
        uint256     deadline,
        uint256     sigId,
        bytes       sig,
        sigStandard sigStd
    ) external returns (bool) {
        requireSignature(
            keccak256(address(this), from, to, value, fee, feeRecipient, deadline, sigId),
            from, deadline, sigId, sig, sigStd
        );
        internalDoubleTransfer(from, to, value, feeRecipient, fee);
        return true;
    }

    /**
     * Allow `spender` to take `value` tokens from the transaction sender's account.
     * Beware that changing an allowance with this method brings the risk that `spender` may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender - the address authorized to spend
     * @param value - the maximum amount they can spend
     */
    function approve (address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * Transfer `value` tokens to `to` address from the `from` account, using the previously set allowance.
     * @param from - the address to transfer tokens from
     * @param to - the address of the recipient
     * @param value - the amount to send
     */
    function transferFrom (address from, address to, uint256 value) public returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        internalTransfer(from, to, value);
        return true;
    }

    /**
     * `tokenDistributor` is authorized to distribute tokens to the parties who participated in the token sale by the
     * time the `lastMint` function is triggered, which closes the ability to mint any new tokens forever.
     * Once the token distribution even ends (lastMint is triggered), tokenDistributor will become 0x0 and multiMint
     * function will never work again.
     * @param recipients - addresses of token recipients
     * @param amounts - corresponding amount of each token recipient in `recipients`
     */
    function multiMint (address[] recipients, uint256[] amounts) external tokenDistributionPeriodOnly {
        require(recipients.length == amounts.length);

        uint total = 0;

        for (uint i = 0; i < recipients.length; ++i) {
            balanceOf[recipients[i]] = balanceOf[recipients[i]].add(amounts[i]);
            total = total.add(amounts[i]);
            emit Transfer(0x0, recipients[i], amounts[i]);
        }

        totalSupply = totalSupply.add(total);
    }

}