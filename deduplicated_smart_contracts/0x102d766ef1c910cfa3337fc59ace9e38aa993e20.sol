/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity ^0.6.8;


library Math {

    // return a + b
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "add overflow");
        return c;
    }

    // return a - b
    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        require(b <= a, "sub underflow");
        return a - b;
    }

    // return a * b
    function mul(uint256 a, uint256 b) public pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "mul overflow");
        return c;
    }

    // return a / b
    function div(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "div zero");
        return a / b;
    }

    // return the greatest uint256 less than or equal to the square root of a
    function sqrt(uint256 a) public pure returns (uint256) {
        uint256 result = 0;
        uint256 bit = 1 << 254; // the second to top bit
        while (bit > a) {
            bit >>= 2;
        }
        while (bit != 0) {
            uint256 sum = result + bit;
            result >>= 1;
            if (a >= sum) {
                a -= sum;
                result += bit;
            }
            bit >>= 2;
        }
        return result;
    }
}


interface Erc20 {
    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}


contract Exchange {
    using Math for uint256;

    address public token;
    uint256 private maxAmount = 5*10**24;

    event Buy(address _buyer, uint256 _wei);

    event Sell(address _seller, uint256 _wei);

    constructor(address _token) public {
        token = _token;
    }

    // any unknown function will be interpreted as purchase
    fallback() external payable {
        buy();
    }

    // incoming eth will be used for purchase
    receive() external payable {
        buy();
    }

    /// @notice purchases tokens using all incoming eth; reverts if there is not enough tokens,
    /// or balance of the exchange is greater than 5*10^24 tokens
    function buy() public payable {
        uint256 tokensBefore = Erc20(token).balanceOf(address(this));
        require(tokensBefore <= maxAmount, "big balance");
        uint256 tokensAfter = v(tokensBefore, true, msg.value);
        Erc20(token).transfer(msg.sender, tokensBefore.sub(tokensAfter));
        emit Buy(msg.sender, msg.value);
    }

    /// @dev call token.approve(this, _tokens) before this
    /// @notice sells tokens for eth; if there is not enough eth in the exchange,
    /// or amount of tokens is too big, only appropriate amount of tokens will be used for sale;
    /// reverts if balance of the exchange is greater than 5*10^24 tokens
    function sell(uint256 _tokens) public {
        uint256 tokensBefore = Erc20(token).balanceOf(address(this));
        require(tokensBefore <= maxAmount, "big balance");
        uint256 tokensAfter = tokensBefore.add(_tokens);
        if (tokensAfter > maxAmount) {
            tokensAfter = maxAmount;
            _tokens = tokensAfter.sub(tokensBefore);
        }

        uint256 sum = s(tokensBefore, tokensAfter);
        if (sum > address(this).balance) {
            sum = address(this).balance;
            tokensAfter = v(tokensBefore, false, sum);
            _tokens = tokensAfter.sub(tokensBefore);
        }

        Erc20(token).transferFrom(msg.sender, address(this), _tokens);
        msg.sender.transfer(sum);
        emit Sell(msg.sender, sum);
    }

    /// @notice feel free to clean from all spam tokens,
    /// grab free tokens if there is too much of them
    function clean(address _contract, uint256 _value) public {
        if (_contract == token) {
            uint256 tokens = Erc20(token).balanceOf(address(this));
            require(tokens > maxAmount, "no free tokens");
            require(_value <= tokens.sub(maxAmount), "big _value");
        }
        Erc20(_contract).transfer(msg.sender, _value);
    }

    /// @dev reverts if balance of the exchange is greater than 5*10^24 tokens
    /// @return current price in wei/token*10^18
    function price() public view returns (uint256) {
        uint256 tokens = Erc20(token).balanceOf(address(this));
        return Math.sub(10**18, tokens.div(5000000));
    }

    /// @dev reverts if there is not enough tokens,
    /// or balance of the exchange is greater than 5*10^24 tokens
    /// @return eth/10^18 required to buy provided number of tokens/10^18
    function tokensToEthForPurchase(uint256 _tokens) public view returns (uint256) {
        uint256 tokensBefore = Erc20(token).balanceOf(address(this));
        require(tokensBefore <= maxAmount, "big balance");
        uint256 tokensAfter = tokensBefore.sub(_tokens);
        return s(tokensAfter, tokensBefore);
    }

    /// @dev reverts if there is not enough tokens,
    /// or balance of the exchange is greater than 5*10^24 tokens
    /// @return amount of tokens/10^18 to receive from purchase using provided amount of eth/10^18
    function ethToTokensForPurchase(uint256 _eth) public view returns (uint256) {
        uint256 tokensBefore = Erc20(token).balanceOf(address(this));
        require(tokensBefore <= maxAmount, "big balance");
        uint256 tokensAfter = v(tokensBefore, true, _eth);
        return tokensBefore.sub(tokensAfter);
    }

    /// @dev reverts if balance of the exchange is greater than 5*10^24 tokens
    /// @return eth/10^18 to receive from sale of provided number of tokens/10^18
    function tokensToEthForSale(uint256 _tokens) public view returns (uint256) {
        uint256 tokensBefore = Erc20(token).balanceOf(address(this));
        require(tokensBefore <= maxAmount, "big balance");
        uint256 tokensAfter = tokensBefore.add(_tokens);
        if (tokensAfter > maxAmount) {
            tokensAfter = maxAmount;
        }

        uint256 sum = s(tokensBefore, tokensAfter);
        if (sum > address(this).balance) {
            return address(this).balance;
        }
        return sum;
    }

    /// @dev reverts if there is not enough eth in the exchange,
    /// or amount of tokens is too big,
    /// or balance of the exchange is greater than 5*10^24 tokens
    /// @return amount of tokens/10^18 required to get desired amount of eth/10^18
    function ethToTokensForSale(uint256 _eth) public view returns (uint256) {
        uint256 tokensBefore = Erc20(token).balanceOf(address(this));
        require(tokensBefore <= maxAmount, "big balance");
        require(_eth <= address(this).balance, "big _eth");
        uint256 tokensAfter = v(tokensBefore, false, _eth);
        return tokensAfter.sub(tokensBefore);
    }

    // v - volume in tokens
    // require vL <= vR <= 5*10^24, check this before!
    // returns sum in wei between vL and vR, rounded to zero
    function s(uint256 vL, uint256 vR) private pure returns (uint256) {
        return vR.sub(vL).mul(Math.sub(10**25, vR).sub(vL)).div(10**25);
    }

    // v0 - current volume in tokens
    // require v0 <= 5*10^24, check this before!
    // isV0Right - bool, if true, returns v <= v0, else returns v >= v0
    // s - sum in wei
    // returns volume v in tokens, reverts if s is too big
    // 0 <= v <= 5*10^24
    function v(uint256 v0, bool isV0Right, uint256 s) private pure returns (uint256) {
        uint256 d = 10**50;
        if (isV0Right) {
            d = d.add(s.mul(4*10**25)).sub(Math.sub(10**25, v0).mul(v0).mul(4));
        } else {
            d = d.sub(s.mul(4*10**25)).sub(Math.sub(10**25, v0).mul(v0).mul(4));
        }
        return Math.sub(5*10**24, d.sqrt().div(2));
    }
}