/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity ^0.5.10;

contract SafeMath {
  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract Token {
  function balanceOf(address _owner) public view returns (uint256 balance) {}
  function transfer(address _to, uint256 _value) public returns (bool success) {}
  //function transfer(address _to, uint _value) public;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}
  //function transferFrom(address from, address to, uint value) public;
}


contract DaiSwap is SafeMath {
    mapping (address => uint) public daiposit;
    uint public totaldai = 0;
    uint public baseMultiplier = 40;
    uint fee = 997; // 0.3%
    uint constant decOffset = 1e12;
    Token  daiContract = Token(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    //Token  usdContract = Token(0xdAC17F958D2ee523a2206206994597C13D831ec7);  // USDT
    Token  usdContract = Token(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC
    //Token   daiContract = Token(0xE888757Fbf1f29B520a80f977DBE52F9AD20d6C9); //Kovan Testnet
    //Token  usdContract = Token(0x3502B803f2a516cD6e9d6E8938b700d78ABF1373); //Kovan Testnet

    function sharesFromDai(uint dai) public view returns (uint) {
        if (totaldai == 0) return dai; // Initialisation 
        uint amt_dai  =  daiContract.balanceOf(address(this));
        return safeMul(dai, totaldai) / amt_dai;
    }

    function usdAmountFromShares(uint shares) public view returns (uint) {
        if (totaldai == 0) return shares / decOffset; // Initialisation - 1 Dai = 1 Shares
        uint amt_usd = safeMul(usdContract.balanceOf(address(this)), decOffset);
        return (safeMul(shares, amt_usd) / totaldai) / decOffset;
    }
    
    function usdAmountFromDai(uint dai) public view returns (uint) {
        return usdAmountFromShares(sharesFromDai(dai));
    }
    
    function deposit(uint dai) public {
        uint shares = sharesFromDai(dai);
        uint usd = usdAmountFromShares(shares);
        daiposit[msg.sender] = safeAdd(daiposit[msg.sender], shares);
        totaldai             = safeAdd(totaldai, shares);
        daiContract.transferFrom(msg.sender, address(this), dai);
        usdContract.transferFrom(msg.sender, address(this), usd);
    }
    
    function withdraw() public {
        uint dai = safeMul(daiposit[msg.sender],  daiContract.balanceOf(address(this))) / totaldai;
        uint usd = safeMul(daiposit[msg.sender], usdContract.balanceOf(address(this))) / totaldai;
        totaldai = safeSub(totaldai, daiposit[msg.sender]);
        daiposit[msg.sender] = 0;
        daiContract.transfer(msg.sender, dai);
        usdContract.transfer(msg.sender, usd);
    }
    
    function calcSwapForUSD(uint dai) public view returns (uint) {
        uint base    = safeMul(baseMultiplier, totaldai);
        uint amt_dai =         daiContract.balanceOf(address(this));
        uint amt_usd = safeMul(usdContract.balanceOf(address(this)), decOffset);
        uint usd     = safeSub(safeAdd(amt_usd, base), ( safeMul(safeAdd(base, amt_usd), safeAdd(base, amt_dai)) / safeAdd(safeAdd(base, amt_dai), dai)));
        usd = usd / decOffset;
        return safeMul(usd, fee) / 1000;
    }
    
    function swapForUSD(uint dai) public {
        uint usd = calcSwapForUSD(dai);
        daiContract.transferFrom(msg.sender, address(this), dai);
        usdContract.transfer(msg.sender, usd);
    }
    
    function calcSwapForDai(uint usd) public view returns (uint) {
        uint base     = safeMul(baseMultiplier, totaldai);
        uint amt_dai  =         daiContract.balanceOf(address(this));
        uint amt_usd  = safeMul(usdContract.balanceOf(address(this)), decOffset);
        uint dai      = safeSub(safeAdd(amt_dai, base), ( safeMul(safeAdd(base, amt_usd), safeAdd(base, amt_dai)) / safeAdd(safeAdd(base, amt_usd), safeMul(usd, decOffset))));
        return safeMul(dai, fee) / 1000;
    }
    
    function swapForDai(uint usd) public {
        uint dai = calcSwapForDai(usd);
        usdContract.transferFrom(msg.sender, address(this), usd);
        daiContract.transfer(msg.sender, dai);
    }
}