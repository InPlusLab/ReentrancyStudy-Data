/**
 *Submitted for verification at Etherscan.io on 2019-12-21
*/

pragma solidity >=0.5.0 <0.6.0;
/**
 * @title KyberNetworkProxy
 * @dev Mock of the KyberNetworkProxy. Only used in development
 */
contract KyberNetworkProxy {

    constructor() public {
    }

    /**
     * @dev Get a mocked up rate for the trade
     */
    function getExpectedRate(
        address /* src */,
        address /* dest */,
        uint /* srcQty */
        )
        public pure
        returns(uint expectedRate, uint slippageRate)
    {
        return (32749000000000000000, 31766530000000000000);
    }

    /// @notice use token address ETH_TOKEN_ADDRESS for ether
    /// @dev makes a trade between src and dest token and send dest token to destAddress
    /// @param maxDestAmount A limit on the amount of dest tokens
    /// @return amount of actual dest tokens
    function trade(
        address /* src */,
        uint /* srcAmount */,
        address /* dest */,
        address /* destAddress */,
        uint  maxDestAmount,
        uint /* minConversionRate */,
        address /* walletId */
    )
        public
        payable
        returns(uint)
    {
      return maxDestAmount;
    }

    /// @dev makes a trade between src and dest token and send dest tokens to msg sender
    /// @return amount of actual dest tokens
    function swapTokenToToken(
        address /* src */,
        uint /* srcAmount */,
        address /* dest */,
        uint /* minConversionRate */
    )
        public pure
        returns(uint)
    {
        return 100;
    }

    /// @dev makes a trade from Ether to token. Sends token to msg sender
    /// @return amount of actual dest tokens
    function swapEtherToToken(
        address /* token */,
        uint /* minConversionRate */
    ) public payable returns(uint) {
        return 200;
    }
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
}/* solium-disable security/no-block-members */




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
 * @title KyberFeeBurner
 * @dev Contract that holds assets for the purpose of trading them to SNT and burning them
 * @dev Assets come from the Escrow contract fees
 */
contract KyberFeeBurner is Ownable, SafeTransfer {

    address public SNT;
    address public burnAddress;
    address public walletId;
    KyberNetworkProxy public kyberNetworkProxy;
    uint public maxSlippageRate;

    // In Kyber's contracts, this is the address for ETH
    address constant internal ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @param _snt Address of the SNT contract
     * @param _burnAddress Address where to burn the assets
     * @param _kyberNetworkProxy License contract instance address for arbitrators
     * @param _walletId Wallet address to send part of the fees to (used for the fee sharing program)
     * @param _maxSlippageRate Max slippage rate to accept a trade
     */
    constructor(address _snt, address _burnAddress, address _kyberNetworkProxy, address _walletId, uint _maxSlippageRate) public {
        SNT = _snt;
        burnAddress = _burnAddress;
        kyberNetworkProxy = KyberNetworkProxy(_kyberNetworkProxy);
        walletId = _walletId;

        setMaxSlippageRate(_maxSlippageRate);
    }

    event SNTAddressChanged(address sender, address prevSNTAddress, address newSNTAddress);

    /**
     * @dev Changes the SNT contract address
     * @param _snt New SNT contract address
     */
    function setSNT(address _snt) external onlyOwner {
        emit SNTAddressChanged(msg.sender, SNT, _snt);
        SNT = _snt;
    }

    event BurnAddressChanged(address sender, address prevBurnAddress, address newBurnAddress);

    /**
     * @dev Changes the burn address
     * @param _burnAddress New burn address
     */
    function setBurnAddress(address _burnAddress) external onlyOwner {
        emit BurnAddressChanged(msg.sender, burnAddress, _burnAddress);
        burnAddress = _burnAddress;
    }

    event KyberNetworkProxyAddressChanged(address sender, address prevKyberAddress, address newKyberAddress);

    /**
     * @dev Changes the KyberNetworkProxy contract address
     * @param _kyberNetworkProxy New KyberNetworkProxy address
     */
    function setKyberNetworkProxyAddress(address _kyberNetworkProxy) external onlyOwner {
        emit KyberNetworkProxyAddressChanged(msg.sender, address(kyberNetworkProxy), _kyberNetworkProxy);
        kyberNetworkProxy = KyberNetworkProxy(_kyberNetworkProxy);
    }

    event WalletIdChanged(address sender, address prevWalletId, address newWalletId);

    /**
     * @dev Changes the walletId address (for the fee sharing program)
     * @param _walletId New walletId address
     */
    function setWalletId(address _walletId) external onlyOwner {
        emit WalletIdChanged(msg.sender, walletId, _walletId);
        walletId = _walletId;
    }

    /**
     * @dev Changes the current max slippage rate
     * @param _newSlippageRate New slippage rate
     */
    function setMaxSlippageRate(uint _newSlippageRate) public onlyOwner {
        require(_newSlippageRate <= 10000, "Invalid slippage rate");
        emit SlippageRateChanged(msg.sender, maxSlippageRate, _newSlippageRate);
        maxSlippageRate = _newSlippageRate;
    }

    event SlippageRateChanged(address sender, uint oldRate, uint newRate);

    event Swap(address sender, address srcToken, address destToken, uint srcAmount, uint destAmount);


    /**
     * @dev Swaps the total balance of the selected asset to SNT and transfers it to the burn address
     * @param _token Address of the asset to trade
     */
    function swap(address _token) public {
        if (_token == address(0)) {
            swap(_token, address(this).balance);
        } else {
            ERC20Token t = ERC20Token(_token);
            swap(_token, t.balanceOf(address(this)));
        }
    }

    /**
     * @dev Swaps the selected asset to SNT and transfers it to the burn address
     * @param _token Address of the asset to trade
     * @param _amount Amount to swap
     */
    function swap(address _token, uint _amount) public {
        uint tokensToTradeRate;
        uint ratePer1Token;
        uint minAcceptedRate;

        uint destAmount;

        if (_token == address(0)) {
            require(_amount <= address(this).balance, "Invalid amount");

            (ratePer1Token,) = kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, SNT, 1 ether);
            (tokensToTradeRate,) = kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, SNT, _amount);
            minAcceptedRate = (ratePer1Token * (10000 - maxSlippageRate)) / 10000;
            require(tokensToTradeRate >= minAcceptedRate, "Rate is not acceptable");

            destAmount = kyberNetworkProxy.trade.value(_amount)(ETH_TOKEN_ADDRESS, _amount, SNT, burnAddress, 0 - uint256(1), tokensToTradeRate, walletId);
            emit Swap(msg.sender, ETH_TOKEN_ADDRESS, SNT, _amount, destAmount);
        } else {
            ERC20Token t = ERC20Token(_token);
            require(_amount <= t.balanceOf(address(this)), "Invalid amount");

            if (_token == SNT) {
                require(_safeTransfer(t, burnAddress, _amount), "SNT transfer failure");
                emit Swap(msg.sender, SNT, SNT, _amount, _amount);
                return;
            } else {
                // Mitigate ERC20 Approve front-running attack, by initially setting allowance to 0
                require(ERC20Token(_token).approve(address(kyberNetworkProxy), 0), "Failed to reset approval");

                // Set the spender's token allowance to tokenQty
                require(ERC20Token(_token).approve(address(kyberNetworkProxy), _amount), "Failed to approve trade amount");

                (ratePer1Token,) = kyberNetworkProxy.getExpectedRate(_token, SNT, 1 ether);
                (tokensToTradeRate,) = kyberNetworkProxy.getExpectedRate(_token, SNT, _amount);
                minAcceptedRate = (ratePer1Token * (10000 - maxSlippageRate)) / 10000;
                require(tokensToTradeRate >= minAcceptedRate, "Rate is not acceptable");

                destAmount = kyberNetworkProxy.trade(_token, _amount, SNT, burnAddress, 0 - uint256(1), tokensToTradeRate, walletId);

                emit Swap(msg.sender, _token, SNT, _amount, destAmount);
            }
        }
    }

    event EscapeTriggered(address sender, address token, uint amount);

    /**
     * @dev Exits the selected asset to the owner
     * @param _token Address of the asset to exit
     */
    function escape(address _token) external onlyOwner {
        if (_token == address(0)) {
            uint ethBalance = address(this).balance;
            address ownerAddr = address(uint160(owner()));
            (bool success, ) = ownerAddr.call.value(ethBalance)("");
            require(success, "Transfer failed.");
            emit EscapeTriggered(msg.sender, _token, ethBalance);
        } else {
            ERC20Token t = ERC20Token(_token);
            uint tokenBalance = t.balanceOf(address(this));
            require(_safeTransfer(t, owner(), tokenBalance), "Token transfer error");
            emit EscapeTriggered(msg.sender, _token, tokenBalance);
        }
    }

    function() payable external {
    }

}