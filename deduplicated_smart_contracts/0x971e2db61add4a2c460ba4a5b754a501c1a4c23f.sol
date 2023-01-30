/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma solidity ^0.6.4;


/// @dev basic erc20 transfer
interface Token {
    function transfer(address _to, uint256 _value) external;
}


library Math {
    /// @return uint256 = a + b
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /// @return uint256 = a - b
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "too big value");
        return a - b;
    }

    /// @return uint256 = a * b
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /// @return uint256 = a / b
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /// @return int256 = a + b
    function signedAdd(int256 a, uint256 b) internal pure returns (int256) {
        int256 c = a + int256(b);
        assert(c >= a);
        return c;
    }

    /// @return int256 = a - b
    function signedSub(int256 a, uint256 b) internal pure returns (int256) {
        int256 c = a - int256(b);
        assert(c <= a);
        return c;
    }
}


/// @title fixed-price erc20 token linked with nft, both tokens with dividends
/// @author aqoleg
contract Ft {
    using Math for uint256;
    using Math for int256;

    uint256 public totalSupply; // erc20
    mapping(address => uint256) public balanceOf; // erc20
    mapping(address => mapping (address => uint256)) public allowance; // erc20, [owner][spender]
    uint8 public constant decimals = 18; // erc20
    string public constant name = "Funge Token"; // erc20
    string public constant symbol = "F"; // erc20

    // wei*price = totalSupply + totalShares*profitPerShare/multiplicator - totalPayouts
    // dividends = sharesOf*profitPerShare/multiplicator - payoutsOf
    uint256 public constant price = 10; // wei = ft / price
    uint256 public totalShares; // ft = sum(sharesOf)
    mapping(address => uint256) public sharesOf; // ft = balanceOf() + sum(nftPrices)
    uint256 public profitPerShare; // ft = shares * profitPerShare / multiplicator
    uint256 public constant multiplicator = 2**64;
    mapping(address => int256) public payoutsOf; // ft

    address public nft = address(0);
    bool public hasFee = true;
    address private biz = msg.sender;
    address private dev = msg.sender;

    /// @dev erc20
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @dev erc20
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Update();

    modifier onlyNft() {
        require(msg.sender == nft, "not nft");
        _;
    }

    /// @notice converts 90% of incoming eth into ft, spreads rest among shareholders; set gasLimit > 200000!
    receive() external payable {
        buy();
    }

    /// @notice keep clean from other tokens
    function clean(address _contract, uint256 _value) external {
        Token(_contract).transfer(msg.sender, _value);
    }

    function setNft(address _nft) external {
        require(nft == address(0), "already set");
        nft = _nft;
    }

    function setBiz(address _biz) external {
        require(msg.sender == biz, "not a biz");
        biz = _biz;
    }

    function setDev(address _dev) external {
        require(msg.sender == dev, "not a dev");
        dev = _dev;
    }

    function disableFee() external {
        require(msg.sender == biz || msg.sender == dev, "not a biz or dev");
        require(hasFee, "already disabled");
        hasFee = false;
    }

    /// @dev converts ft into nft, all price distributed as dividends
    function onMint(address _minter, uint256 _price) external onlyNft returns (bool) {
        // wei*price = Sp + Sh*pSh/M - P
        // wei*price = Sp-p + Sh*(pSh + p*M/Sh))/M - P

        balanceOf[_minter] = balanceOf[_minter].sub(_price);
        totalSupply = totalSupply.sub(_price);
        emit Transfer(_minter, address(0), _price);

        profitPerShare = profitPerShare.add(_price.mul(multiplicator).div(totalShares));
        return true;
    }

    /// @dev buys nft with ft, transfers 90% of price delta to seller, spread rests among shareholders
    function onBuy(
        address _seller,
        address _buyer,
        uint256 _previousPrice,
        uint256 _price
    ) external onlyNft returns (bool) {
        // wei*price = Sp + Sh*pSh/M - P
        // wei*price = Sp-f + (Sh+d)*(pSh + f*M/Sh)/M - (P + d*(pSh + f*M/Sh)/M)

        uint256 delta = _price.sub(_previousPrice);
        uint256 fee = delta.div(10);
        uint256 transferred = _price.sub(fee);
        delta = delta.sub(fee);

        profitPerShare = profitPerShare.add(fee.mul(multiplicator).div(totalShares)); // ft > 0

        balanceOf[_seller] = balanceOf[_seller].add(transferred);
        balanceOf[_buyer] = balanceOf[_buyer].sub(_price);
        totalSupply = totalSupply.sub(fee); // + (_price - fee) - _price
        emit Transfer(_buyer, _seller, transferred);
        emit Transfer(_buyer, address(0), fee);

        sharesOf[_seller] = sharesOf[_seller].add(delta); // + transferred - _previousPrice
        // sharesOf[_buyer] = sharesOf[_buyer] - _price + _price
        totalShares = totalShares.add(delta);

        uint256 payout = delta.mul(profitPerShare).div(multiplicator);
        payoutsOf[_seller] = payoutsOf[_seller].signedAdd(payout);
        return true;
    }

    /// @dev transfers nft, no fee
    function onTransfer(
        address _from,
        address _to,
        uint256 _price
    ) external onlyNft returns (bool) {
        // wei*price = Sp + Sh*pSh/M - P
        // wei*price = Sp + Sh*pSh/M - (P + p*pSh/M - p*pSh/M)

        sharesOf[_from] = sharesOf[_from].sub(_price);
        sharesOf[_to] = sharesOf[_to].add(_price);

        uint256 payout = _price.mul(profitPerShare).div(multiplicator);
        payoutsOf[_from] = payoutsOf[_from].signedSub(payout);
        payoutsOf[_to] = payoutsOf[_to].signedAdd(payout);

        emit Update();
        return true;
    }

    /// @notice converts 90% into dividends, spreads rest among shareholders
    function sell(uint256 _tokens) external {
        // wei*price = Sp + Sh*pSh/M - P
        // wei*price = Sp-t + (Sh-t)*(pSh + f*M/(Sh-t))/M - (P - ((t-f) + t*pSh/M))

        uint256 fee = _tokens.div(10);
        uint256 withdraw = _tokens.sub(fee);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_tokens);
        totalSupply = totalSupply.sub(_tokens);
        emit Transfer(msg.sender, address(0), _tokens);

        sharesOf[msg.sender] = sharesOf[msg.sender].sub(_tokens);
        totalShares = totalShares.sub(_tokens);

        uint256 payout = withdraw.add(_tokens.mul(profitPerShare).div(multiplicator));
        payoutsOf[msg.sender] = payoutsOf[msg.sender].signedSub(payout);

        profitPerShare = profitPerShare.add(fee.mul(multiplicator).div(totalShares)); // nft > 0
    }

    /// @notice withdraws all of dividends
    function withdraw() external {
        // wei*price = Sp + Sh*pSh/M - P
        // (wei - d/price)*price = Sp + Sh*pSh/M - (P + d)

        uint256 dividends = dividendsOf(msg.sender);
        require(dividends != 0, "zero dividends");

        payoutsOf[msg.sender] = payoutsOf[msg.sender].signedAdd(dividends);

        emit Update();
        msg.sender.transfer(dividends.div(price));
    }

    /// @notice converts all of dividends into ft
    function reinvest() external {
        // wei*price = Sp + Sh*pSh/M - P
        // wei*price = (Sp+d) + (Sh+d)*pSh/M - (P + (d + d*pSh/M))

        uint256 dividends = dividendsOf(msg.sender);
        require(dividends != 0, "zero dividends");

        balanceOf[msg.sender] = balanceOf[msg.sender].add(dividends);
        totalSupply = totalSupply.add(dividends);
        emit Transfer(address(0), msg.sender, dividends);

        sharesOf[msg.sender] = sharesOf[msg.sender].add(dividends);
        totalShares = totalShares.add(dividends);

        uint256 payout = dividends.add(dividends.mul(profitPerShare).div(multiplicator));
        payoutsOf[msg.sender] = payoutsOf[msg.sender].signedAdd(payout);
    }

    /// @notice converts 90% of incoming eth into ft, spreads rest among shareholders
    function buy() public payable {
        // wei*price = Sp + Sh*pSh/M - P
        // in * price = t + f + bFee + dFee
        // (wei + in)*price = Sp+t + (Sh+t)*(pSh + f*M/Sh)/M - (P - bFee - dFee + t*(pSh + f*M/Sh)/M)
        // first:
        // (wei + in)*price = Sp+t+f + (Sh+t+f)*pSh/M - (P - bFee - dFee + (t+f)*pSh/M)

        uint256 tokens = msg.value.mul(price);
        uint256 fee = tokens.div(10);
        tokens = tokens.sub(fee);
        uint256 devFee = fee.div(10);
        if (hasFee) {
            fee = fee.sub(devFee).sub(devFee);
        }

        if (totalShares != 0) {
            profitPerShare = profitPerShare.add(fee.mul(multiplicator).div(totalShares));
        } else {
            tokens = tokens.add(fee);
        }

        balanceOf[msg.sender] = balanceOf[msg.sender].add(tokens);
        totalSupply = totalSupply.add(tokens);
        emit Transfer(address(0), msg.sender, tokens);

        sharesOf[msg.sender] = sharesOf[msg.sender].add(tokens);
        totalShares = totalShares.add(tokens);

        if (hasFee) {
            payoutsOf[biz] = payoutsOf[biz].signedSub(devFee);
            payoutsOf[dev] = payoutsOf[dev].signedSub(devFee);
        }
        uint256 payout = tokens.mul(profitPerShare).div(multiplicator);
        payoutsOf[msg.sender] = payoutsOf[msg.sender].signedAdd(payout);
    }

    /// @notice transfers ft, spreads plus 5% among shareholders
    /// @dev erc20
    function transfer(address _to, uint256 _value) public returns (bool) {
        transferFt(msg.sender, _to, _value);

        return true;
    }

    /// @notice transfers ft, spreads plus 5% among shareholders
    /// @dev erc20
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        transferFt(_from, _to, _value);

        return true;
    }

    /// @notice approves other address to spend your ft
    /// @dev erc20
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "zero _spender");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function dividendsOf(address _owner) public view returns (uint256) {
        // dividends = sharesOf*profitPerShare/multiplicator - payoutsOf

        uint256 a = sharesOf[_owner].mul(profitPerShare).div(multiplicator);
        int256 b = payoutsOf[_owner];
        // a - b
        if (b < 0) {
            return a.add(uint256(-b));
        } else {
            uint256 c = uint256(b);
            if (c > a) {
                return 0;
            }
            return a - c;
        }
    }

    function transferFt(address _from, address _to, uint256 _value) private {
        // wei*price = Sp + Sh*pSh/M - P
        // newPSh = pSh + f*M/(Sh-v-f)
        // wei*price = Sp-f + (Sh-f)*newPSh/M - (P - (f+v)*pSh/M + v*newPSh/M)

        require(_to != address(0), "zero _to");
        uint256 fee = _value.div(20);
        uint256 cost = _value.add(fee);

        uint256 payout = cost.mul(profitPerShare).div(multiplicator);
        profitPerShare = profitPerShare.add(fee.mul(multiplicator).div(totalShares.sub(cost))); // nft > 0

        balanceOf[_from] = balanceOf[_from].sub(cost);
        balanceOf[_to] = balanceOf[_to].add(_value);
        totalSupply = totalSupply.sub(fee);
        emit Transfer(_from, _to, _value);
        emit Transfer(_from, address(0), fee);

        sharesOf[_from] = sharesOf[_from].sub(cost);
        sharesOf[_to] = sharesOf[_to].add(_value);
        totalShares = totalShares.sub(fee);

        payoutsOf[_from] = payoutsOf[_from].signedSub(payout);
        payout = _value.mul(profitPerShare).div(multiplicator);
        payoutsOf[_to] = payoutsOf[_to].signedAdd(payout);
    }
}