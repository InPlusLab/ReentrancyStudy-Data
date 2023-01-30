/**
 *Submitted for verification at Etherscan.io on 2019-10-07
*/

pragma solidity ^0.4.26;


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DSMath {
    
    

    function add(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        assert((z = x * y) >= x);
    }
    
    function div(uint256 x, uint256 y) pure internal returns (uint256 z) {
        require(y > 0);
        z = x / y;
    }
    
    function min(uint256 x, uint256 y) pure internal returns (uint256 z) {
        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) pure internal returns (uint256 z) {
        return x >= y ? x : y;
    }

    


    function hadd(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) pure internal returns (uint128 z) {
        assert(y > 0);
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) pure internal returns (uint128 z) {
        return x <= y ? x : y;
    }
    function hmax(uint128 x, uint128 y) pure internal returns (uint128 z) {
        return x >= y ? x : y;
    }


    

    function imin(int256 x, int256 y) pure internal returns (int256 z) {
        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) pure internal returns (int256 z) {
        return x >= y ? x : y;
    }

    

    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) pure internal returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) pure internal returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmin(x, y);
    }
    function wmax(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmax(x, y);
    }

    

    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) pure internal returns (uint128) {
        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) pure internal returns (uint128) {
        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) view internal returns (uint128 z) {
        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) view internal returns (uint128 z) {
        
        
        
        
        
        
        
        
        
        
        
        
        
        

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmin(x, y);
    }
    function rmax(uint128 x, uint128 y) pure internal returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) pure internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }

}

contract MedianizerInterface {
    function peek() public view returns (bytes32, bool);
    function read() public returns (bytes32);
    function poke() public;
    function poke(bytes32) public;
    function fund (uint256 amount, ERC20 token) public;
}

contract Oracle is DSMath {
    uint32  constant public DELAY = 900; 
    uint128 constant public prem = 1100000000000000000; 
    uint128 constant public turn = 1010000000000000000; 

    MedianizerInterface med;

    uint32 public expiry;
    uint32 public timeout;
    uint128 assetPrice;                     
    uint128 public paymentTokenPrice;
    uint256 rewardAmount;

    mapping(bytes32 => AsyncRequest) asyncRequests;

    struct AsyncRequest {
        address rewardee;
        uint128 payment;
        uint128 disbursement;
        ERC20 token;
        bool assetPriceSet;
        bool paymentTokenPriceSet;
    }

    function peek() public view
        returns (bytes32,bool)
    {
        return (bytes32(uint(assetPrice)), now < expiry);
    }

    function read() public view
        returns (bytes32)
    {
        assert(now < expiry);
        return bytes32(uint(assetPrice));
    }
    
    function setAssetPrice(bytes32 queryId, uint128 assetPrice_, uint32 expiry_) internal
    {
        asyncRequests[queryId].disbursement = 0;
        if (assetPrice_ >= wmul(assetPrice, turn) || assetPrice_ <= wdiv(assetPrice, turn)) { asyncRequests[queryId].disbursement = asyncRequests[queryId].payment; }
        assetPrice = assetPrice_;
        expiry = expiry_;
        med.poke();
        asyncRequests[queryId].assetPriceSet = true;
        if (asyncRequests[queryId].paymentTokenPriceSet) { reward(queryId); }
    }

    function setPaymentTokenPrice(bytes32 queryId, uint128 paymentTokenPrice_) internal {
        paymentTokenPrice = paymentTokenPrice_;
        asyncRequests[queryId].paymentTokenPriceSet = true;
        if (asyncRequests[queryId].assetPriceSet) { reward(queryId); }
    }

    function reward(bytes32 queryId) internal { 
        rewardAmount = wmul(wmul(paymentTokenPrice, asyncRequests[queryId].disbursement), prem);
        if (asyncRequests[queryId].token.balanceOf(address(this)) >= rewardAmount && asyncRequests[queryId].disbursement > 0) {
            require(asyncRequests[queryId].token.transfer(asyncRequests[queryId].rewardee, rewardAmount));
        }
        delete(asyncRequests[queryId]);
    }

    function setMaxReward(uint256 maxReward_) public;
}

contract Medianizer is DSMath {
    bool    hasPrice;
    bytes32 assetPrice;
    uint256 public minOraclesRequired = 5;
    bool on;
    address deployer;

    Oracle[] public oracles;

    constructor() {
    	deployer = msg.sender;
    }

    function setOracles(address[10] addrs) {
    	require(!on);
        require(msg.sender == deployer);
        oracles.push(Oracle(addrs[0]));
        oracles.push(Oracle(addrs[1]));
        oracles.push(Oracle(addrs[2]));
        oracles.push(Oracle(addrs[3]));
        oracles.push(Oracle(addrs[4]));
        oracles.push(Oracle(addrs[5]));
        oracles.push(Oracle(addrs[6]));
        oracles.push(Oracle(addrs[7]));
        oracles.push(Oracle(addrs[8]));
        oracles.push(Oracle(addrs[9]));
    	on = true;
    }

    function setMaxReward(uint256 maxReward_) {
    	require(on);
    	require(msg.sender == deployer);
        oracles[0].setMaxReward(maxReward_);
        oracles[1].setMaxReward(maxReward_);
        oracles[2].setMaxReward(maxReward_);
        oracles[3].setMaxReward(maxReward_);
        oracles[4].setMaxReward(maxReward_);
        oracles[5].setMaxReward(maxReward_);
        oracles[6].setMaxReward(maxReward_);
        oracles[7].setMaxReward(maxReward_);
        oracles[8].setMaxReward(maxReward_);
        oracles[9].setMaxReward(maxReward_);
    }

    function peek() public view returns (bytes32, bool) {
        return (assetPrice,hasPrice);
    }

    function read() public returns (bytes32) {
        var (assetPrice, hasPrice) = peek();
        assert(hasPrice);
        return assetPrice;
    }

    function fund (uint256 amount, ERC20 token) public {
      for (uint256 i = 0; i < oracles.length; i++) {
        require(token.transferFrom(msg.sender, address(oracles[i]), uint(div(uint128(amount), uint128(oracles.length)))));
      }
    }

    function poke() public {
        poke(0);
    }

    function poke(bytes32) public {
        (assetPrice, hasPrice) = compute();
    }

    function compute() public returns (bytes32, bool) {
        bytes32[] memory wuts = new bytes32[](oracles.length);
        uint256 ctr = 0;
        for (uint256 i = 0; i < oracles.length; i++) {
            if (address(oracles[i]) != 0) {
                var (wut, wuz) = oracles[i].peek();
                if (wuz) {
                    if (ctr == 0 || wut >= wuts[ctr - 1]) {
                        wuts[ctr] = wut;
                    } else {
                        uint256 j = 0;
                        while (wut >= wuts[j]) {
                            j++;
                        }
                        for (uint256 k = ctr; k > j; k--) {
                            wuts[k] = wuts[k - 1];
                        }
                        wuts[j] = wut;
                    }
                    ctr++;
                }
            }
        }

        if (ctr < minOraclesRequired) return (assetPrice, false);

        bytes32 value;
        if (ctr % 2 == 0) {
            uint128 val1 = uint128(wuts[(ctr / 2) - 1]);
            uint128 val2 = uint128(wuts[ctr / 2]);
            value = bytes32((val1 + val2) / 2);
        } else {
            value = wuts[(ctr - 1) / 2];
        }

        return (value, true);
    }
}