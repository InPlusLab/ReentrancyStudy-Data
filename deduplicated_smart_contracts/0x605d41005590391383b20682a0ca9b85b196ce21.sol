/**
 *Submitted for verification at Etherscan.io on 2019-10-11
*/

pragma solidity 0.5.11;

interface ERC20 {
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
}

interface Kyber {
    function swapEtherToToken(ERC20 token, uint minConversionRate) external payable returns(uint256);
    function swapTokenToEther(ERC20 token, uint256 srcAmount, uint256 minConversionRate) external returns(uint256);
}

interface Synthetix {
    function exchange(bytes32 sourceCurrencyKey, uint256 sourceAmount, bytes32 destinationCurrencyKey, address destinationAddress) external returns(bool);
    function synths(bytes32 currencyKey) external returns(address);
}

interface UniswapFactory {
    function getExchange(address token) external view returns(address);
}

interface Uniswap {
    function ethToTokenSwapInput(uint256 minTokens, uint256 deadline) external payable returns(uint256);
    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline) external payable returns(uint256);
    function tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint256 deadline) external returns(uint256);
    function tokenToEthSwapOutput(uint256 ethBought, uint256 maxTokens, uint256 deadline) external returns(uint256);
}

contract KyberSynthetix {
    Kyber kyber = Kyber(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    Synthetix synthetix = Synthetix(0xC011A72400E58ecD99Ee497CF89E3775d4bd732F);
    UniswapFactory uniswapFactory = UniswapFactory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    
    function ethToSynth(bytes32 synthKey) external payable {
        ERC20 synth = ERC20(synthetix.synths(synthKey));
        _ethToSeth();
        _sethToSynth(synthKey);
        synth.transfer(msg.sender, synth.balanceOf(address(this)));
    }
    
    function synthToEth(bytes32 synthKey, uint256 inputAmount) external {
        ERC20 synth = ERC20(synthetix.synths(synthKey));
        synth.transferFrom(msg.sender, address(this), inputAmount);
        _synthToSeth(synthKey);
        _sethToEth();
        msg.sender.transfer(address(this).balance);
    }
    
    function tokenToSynth(ERC20 token, bytes32 synthKey, uint256 inputAmount) external {
        ERC20 synth = ERC20(synthetix.synths(synthKey));
        token.transferFrom(msg.sender, address(this), inputAmount);
        _tokenToEth(token);
        _ethToSeth();
        _sethToSynth(synthKey);
        synth.transfer(msg.sender, synth.balanceOf(address(this)));
    }
    
    function synthToToken(bytes32 synthKey, ERC20 token, uint256 inputAmount) external {
        ERC20 synth = ERC20(synthetix.synths(synthKey));
        synth.transferFrom(msg.sender, address(this), inputAmount);
        _synthToSeth(synthKey);
        _sethToEth();
        _ethToToken(token);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    
    function _tokenToEth(ERC20 token) internal {
        _unlockToken(token, address(kyber));
        uint256 amount = token.balanceOf(address(this));
        kyber.swapTokenToEther(token, amount, 0);
    }
    
    function _ethToToken(ERC20 token) internal {
        uint256 amount = token.balanceOf(address(this));
        kyber.swapEtherToToken.value(amount)(token, 0);
    }
    
    function _sethToSynth(bytes32 synthKey) internal {
        if (synthKey == 'sETH') {
            return;
        }
        ERC20 synth = ERC20(synthetix.synths(synthKey));
        uint256 amount = synth.balanceOf(address(this));
        _unlockToken(synth, address(synthetix));
        synthetix.exchange('sETH', amount, synthKey, address(this));
    }
    
    function _synthToSeth(bytes32 synthKey) internal {
        if (synthKey == 'sETH') {
            return;
        }
        ERC20 synth = ERC20(synthetix.synths(synthKey));
        uint256 amount = synth.balanceOf(address(this));
        _unlockToken(synth, address(synthetix));
        synthetix.exchange(synthKey, amount, 'sETH', address(this));
    }
    
    function _ethToSeth() internal {
        address synthAddress = synthetix.synths('sETH');
        Uniswap uniswap = Uniswap(uniswapFactory.getExchange(synthAddress));
        uint256 amount;
        if (msg.value > 0) {
            amount = msg.value;
        } else {
            amount = address(this).balance;
        }
        uniswap.ethToTokenSwapInput.value(amount)(0, block.timestamp);
    }
    
    function _sethToEth() internal {
        ERC20 synth = ERC20(synthetix.synths('sETH'));
        Uniswap uniswap = Uniswap(uniswapFactory.getExchange(address(synth)));
        _unlockToken(synth, address(uniswap));
        uniswap.tokenToEthSwapInput(synth.balanceOf(address(this)), 0, block.timestamp);
    }
    
    function _unlockToken(ERC20 token, address to) internal {
        if (token.allowance(address(this), to) == 0) {
            token.approve(to, uint256(-1));
        }
    }
}