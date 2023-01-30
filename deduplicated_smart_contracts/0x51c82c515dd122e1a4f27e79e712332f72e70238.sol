pragma solidity 0.5.9;

import "./SafeERC20.sol";
import "./KyberNetworkProxyInterface.sol";
import "./PermissionGroups.sol";
import "./Withdrawable.sol";
import "./KyberSwapLimitOrder.sol";
import "./Utils.sol";

contract MonitorHelper is Utils2, PermissionGroups, Withdrawable {
    KyberSwapLimitOrder public ksContract;
    KyberNetworkProxyInterface public kyberProxy;
    uint public slippageRate = 300; // 3%

    constructor(KyberSwapLimitOrder _ksContract, KyberNetworkProxyInterface _kyberProxy) public Withdrawable(msg.sender) {
        ksContract = _ksContract;
        kyberProxy = _kyberProxy;
    }

    function setKSContract(KyberSwapLimitOrder _ksContract) public onlyAdmin {
        ksContract = _ksContract;
    }

    function setKyberProxy(KyberNetworkProxyInterface _kyberProxy) public onlyAdmin {
        kyberProxy = _kyberProxy;
    }

    function setSlippageRate(uint _slippageRate) public onlyAdmin {
        slippageRate = _slippageRate;
    }

    function getNonces(address []memory users, uint256[] memory concatenatedTokenAddresses)
    public view
    returns (uint256[] memory nonces) {
        require(users.length == concatenatedTokenAddresses.length);
        nonces = new uint256[](users.length);
        for(uint i=0; i< users.length; i ++) {
            nonces[i]= ksContract.nonces(users[i],concatenatedTokenAddresses[i]);
        }
        return (nonces);
    }

    function getNonceFromKS(address user, uint256 concatenatedTokenAddress)
    public view
    returns (uint256 nonces) {
        nonces = ksContract.nonces(user, concatenatedTokenAddress);
        return nonces;
    }

    function getBalancesAndAllowances(address[] memory wallets, ERC20[] memory tokens)
    public view
    returns (uint[] memory balances, uint[] memory allowances) {
        require(wallets.length == tokens.length);
        balances = new uint[](wallets.length);
        allowances = new uint[](wallets.length);
        for(uint i = 0; i < wallets.length; i++) {
            balances[i] = tokens[i].balanceOf(wallets[i]);
            allowances[i] = tokens[i].allowance(wallets[i], address(ksContract));
        }
        return (balances, allowances);
    }

    function getBalances(address[] memory wallets, ERC20[] memory tokens)
    public view
    returns (uint[] memory balances) {
        require(wallets.length == tokens.length);
        balances = new uint[](wallets.length);
        for(uint i = 0; i < wallets.length; i++) {
            balances[i] = tokens[i].balanceOf(wallets[i]);
        }
        return balances;
    }

    function getBalancesSingleWallet(address wallet, ERC20[] memory tokens)
    public view
    returns (uint[] memory balances) {
        balances = new uint[](tokens.length);
        for(uint i = 0; i < tokens.length; i++) {
            balances[i] = tokens[i].balanceOf(wallet);
        }
        return balances;
    }

    function getAllowances(address[] memory wallets, ERC20[] memory tokens)
    public view
    returns (uint[] memory allowances) {
        require(wallets.length == tokens.length);
        allowances = new uint[](wallets.length);
        for(uint i = 0; i < wallets.length; i++) {
            allowances[i] = tokens[i].allowance(wallets[i], address(ksContract));
        }
        return allowances;
    }

    function getAllowancesSingleWallet(address wallet, ERC20[] memory tokens)
    public view
    returns (uint[] memory allowances) {
        allowances = new uint[](tokens.length);
        for(uint i = 0; i < tokens.length; i++) {
            allowances[i] = tokens[i].allowance(wallet, address(ksContract));
        }
        return allowances;
    }

    function checkOrdersExecutable(
        address[] memory senders, ERC20[] memory srcs,
        uint[] memory srcAmounts, ERC20[] memory dests,
        uint[] memory rates, uint[] memory nonces
    )
    public view
    returns (bool[] memory executables) {
        require(senders.length == srcs.length);
        require(senders.length == dests.length);
        require(senders.length == srcAmounts.length);
        require(senders.length == rates.length);
        require(senders.length == nonces.length);
        executables = new bool[](senders.length);
        bool isOK = true;
        uint curRate = 0;
        uint allowance = 0;
        uint balance = 0;
        for(uint i = 0; i < senders.length; i++) {
            isOK = true;
            balance = srcs[i].balanceOf(senders[i]);
            if (balance < srcAmounts[i]) { isOK = false; }
            if (isOK) {
                allowance = srcs[i].allowance(senders[i], address(ksContract));
                if (allowance < srcAmounts[i]) { isOK = false; }
            }
            if (isOK && address(ksContract) != address(0)) {
                isOK = ksContract.validAddressInNonce(nonces[i]);
                if (isOK) {
                    uint concatTokenAddresses = ksContract.concatTokenAddresses(address(srcs[i]), address(dests[i]));
                    isOK = ksContract.isValidNonce(senders[i], concatTokenAddresses, nonces[i]);
                }
            }
            if (isOK) {
                (curRate, ) = kyberProxy.getExpectedRate(srcs[i], dests[i], srcAmounts[i]);
                if (curRate * 10000 < rates[i] * (10000 + slippageRate)) { isOK = false; }
            }
            executables[i] = isOK;
        }
        return executables;
    }
}
