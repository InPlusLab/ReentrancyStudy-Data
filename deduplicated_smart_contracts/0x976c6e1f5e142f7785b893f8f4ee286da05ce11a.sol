// SPDX-License-Identifier: MIT

    /**
     * LYNC Network
     * https://lync.network
     *
     * Additional details for contract and wallet information:
     * https://lync.network/tracking/
     *
     * The cryptocurrency network designed for passive token rewards for its community.
     */

pragma solidity ^0.7.0;

import "./safemath.sol";

contract LYNCToken {

    //Enable SafeMath
    using SafeMath for uint256;

    //Token details
    string constant public name = "LYNC Network";
    string constant public symbol = "LYNC";
    uint8 constant public decimals = 18;

    //Reward pool and owner address
    address public owner;
    address public rewardPoolAddress;

    //Supply and tranasction fee
    uint256 public maxTokenSupply = 1e24;   // 1,000,000 tokens
    uint256 public feePercent = 1;          // initial transaction fee percentage
    uint256 public feePercentMax = 10;      // maximum transaction fee percentage

    //Events
    event Transfer(address indexed _from, address indexed _to, uint256 _tokens);
    event Approval(address indexed _owner,address indexed _spender, uint256 _tokens);
    event TranserFee(uint256 _tokens);
    event UpdateFee(uint256 _fee);
    event RewardPoolUpdated(address indexed _rewardPoolAddress, address indexed _newRewardPoolAddress);
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
    event OwnershipRenounced(address indexed _previousOwner, address indexed _newOwner);

    //Mappings
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) private allowances;

    //On deployment
    constructor () {
        owner = msg.sender;
        rewardPoolAddress = address(this);
        balanceOf[msg.sender] = maxTokenSupply;
        emit Transfer(address(0), msg.sender, maxTokenSupply);
    }

    //ERC20 totalSupply
    function totalSupply() public view returns (uint256) {
        return maxTokenSupply;
    }

    //ERC20 transfer
    function transfer(address _to, uint256 _tokens) public returns (bool) {
        transferWithFee(msg.sender, _to, _tokens);
        return true;
    }

    //ERC20 transferFrom
    function transferFrom(address _from, address _to, uint256 _tokens) public returns (bool) {
        require(_tokens <= balanceOf[_from], "Not enough tokens in the approved address balance");
        require(_tokens <= allowances[_from][msg.sender], "token amount is larger than the current allowance");
        transferWithFee(_from, _to, _tokens);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_tokens);
        return true;
    }

    //ERC20 approve
    function approve(address _spender, uint256 _tokens) public returns (bool) {
        allowances[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    //ERC20 allowance
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

    //Transfer with transaction fee applied
    function transferWithFee(address _from, address _to, uint256 _tokens) internal returns (bool) {
        require(balanceOf[_from] >= _tokens, "Not enough tokens in the senders balance");
        uint256 _feeAmount = (_tokens.mul(feePercent)).div(100);
        balanceOf[_from] = balanceOf[_from].sub(_tokens);
        balanceOf[_to] = balanceOf[_to].add(_tokens.sub(_feeAmount));
        balanceOf[rewardPoolAddress] = balanceOf[rewardPoolAddress].add(_feeAmount);
        emit Transfer(_from, _to, _tokens.sub(_feeAmount));
        emit Transfer(_from, rewardPoolAddress, _feeAmount);
        emit TranserFee(_tokens);
        return true;
    }

    //Update transaction fee percentage
    function updateFee(uint256 _updateFee) public onlyOwner {
        require(_updateFee <= feePercentMax, "Transaction fee cannot be greater than 10%");
        feePercent = _updateFee;
        emit UpdateFee(_updateFee);
    }

    //Update the reward pool address
    function updateRewardPool(address _newRewardPoolAddress) public onlyOwner {
        require(_newRewardPoolAddress != address(0), "New reward pool address cannot be a zero address");
        rewardPoolAddress = _newRewardPoolAddress;
        emit RewardPoolUpdated(rewardPoolAddress, _newRewardPoolAddress);
    }

    //Transfer current token balance to the reward pool address
    function rewardPoolBalanceTransfer() public onlyOwner returns (bool) {
        uint256 _currentBalance = balanceOf[address(this)];
        transferWithFee(address(this), rewardPoolAddress, _currentBalance);
        return true;
    }

    //Transfer ownership to new owner
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner cannot be a zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    //Remove owner from the contract
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner, address(0));
        owner = address(0);
    }

    //Modifiers
    modifier onlyOwner() {
        require(owner == msg.sender, "Only current owner can call this function");
        _;
    }
}

// SPDX-License-Identifier: MIT

/**
 * LYNC Network
 * https://lync.network
 *
 * Additional details for contract and wallet information:
 * https://lync.network/tracking/
 *
 * The cryptocurrency network designed for passive token rewards for its community.
 */

pragma solidity ^0.7.0;

import "./lynctoken.sol";

contract LYNCTokenSale {

   //Enable SafeMath
    using SafeMath for uint256;

    address payable owner;
    address public contractAddress;
    uint256 public tokensSold;
    uint256 public priceETH;
    uint256 public SCALAR = 1e18;           // multiplier
    uint256 public maxBuyETH = 10;          // in ETH
    uint256 public tokenOverFlow = 5e20;    // 500 tokens
    uint256 public tokenPrice = 70;         // in cents
    uint256 public batchSize = 1;           // batch size of distribution

    bool public saleEnabled = false;

    LYNCToken public tokenContract;

    //Events
    event Sell(address _buyer, uint256 _amount);


    //Mappings
    mapping(address => uint256) public purchaseData;

    //Buyers list
    address[] userIndex;

    //On deployment
    constructor(LYNCToken _tokenContract, uint256 _priceETH) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        contractAddress = address(this);
        priceETH = _priceETH;
    }

    //Buy tokens with ETH
    function buyTokens(uint256 _ethSent) public payable {

        require(saleEnabled == true, "The LYNC Initial Token Offering will commence on the 28th of September @ 5PM UTC");
        require(_ethSent <= maxBuyETH.mul(SCALAR), "Exceeded maximum purchase per transaction");
        require(_ethSent >= 1e17, "Minimum purchase per transaction is 0.1 ETH");

        uint256 _priceETH = priceETH.mul(SCALAR);

        //Check if there are enough tokens available in this round
        if (tokensSold < (100000 * SCALAR)) {

            //Scale up token price
            uint256 _tokenPrice = tokenPrice.mul(SCALAR);

            //Calculate tokens based on current eth price in contract
            uint256 _tokensPerETH = _priceETH.div(_tokenPrice);
            uint256 _numberOfTokens = _ethSent.mul(_tokensPerETH);

            //Calculate how many tokens left in this round
            uint256 _tokensRemaining = (100000 * SCALAR).sub(tokensSold);

            //Check that the purchase amount does not exceed tokens remaining in this round, including overflow
            require(_numberOfTokens < _tokensRemaining.add(tokenOverFlow), "Not enough tokens remain in Round 1");

            //Record purchased tokens
            if(purchaseData[msg.sender] == 0) {
                userIndex.push(msg.sender);
            }

            purchaseData[msg.sender] = purchaseData[msg.sender].add(_numberOfTokens);
            tokensSold = tokensSold.add(_numberOfTokens);
            emit Sell(msg.sender, _numberOfTokens);

            //Update token price if round max is met after this tranasaction
            if(tokensSold > 100000 * SCALAR) {
              //Set the token price for Round 2
              tokenPrice = 80; //in cents
            }

        } else if (tokensSold > (100000 * SCALAR) && tokensSold < (250000 * SCALAR)) {

            //Scale up token price
            uint256 _tokenPrice = tokenPrice.mul(SCALAR);

            //Calculate tokens based on current eth price in contract
            uint256 _tokensPerETH = _priceETH.div(_tokenPrice);
            uint256 _numberOfTokens = _ethSent.mul(_tokensPerETH);

            //Calculate how many tokens left in this round
            uint256 _tokensRemaining = (250000 * SCALAR).sub(tokensSold);

            //Check that the purchase amount does not exceed tokens remaining in this round, including overflow
            require(_numberOfTokens < _tokensRemaining.add(tokenOverFlow), "Not enough tokens remain in Round 2");

            //Record purchased tokens
            if(purchaseData[msg.sender] == 0) {
                userIndex.push(msg.sender);
            }
            purchaseData[msg.sender] = purchaseData[msg.sender].add(_numberOfTokens);
            tokensSold = tokensSold.add(_numberOfTokens);
            emit Sell(msg.sender, _numberOfTokens);

            //Update token price if round max is met after this tranasaction
            if(tokensSold > 250000 * SCALAR) {
              //Set the token price for Round 3
              tokenPrice = 90; //in cents
            }

        } else {

            //Scale up token price
            uint256 _tokenPrice = tokenPrice.mul(SCALAR);

            //Calculate tokens based on current eth price in contract
            uint256 _tokensPerETH = _priceETH.div(_tokenPrice);
            uint256 _numberOfTokens = _ethSent.mul(_tokensPerETH);

            //Check that the purchase amount does not exceed remaining tokens
            require(_numberOfTokens <= tokenContract.balanceOf(address(this)), "Not enough tokens remain in Round 3");

            //Record purchased tokens
            if(purchaseData[msg.sender] == 0) {
                userIndex.push(msg.sender);
            }
            purchaseData[msg.sender] = purchaseData[msg.sender].add(_numberOfTokens);
            tokensSold = tokensSold.add(_numberOfTokens);
            emit Sell(msg.sender, _numberOfTokens);
        }
    }

    //Return total number of buyers
    function totalBuyers() view public returns (uint256) {
        return userIndex.length;
    }

    //Enable the token sale
    function enableSale(bool _saleStatus) public onlyOwner {
        saleEnabled = _saleStatus;
    }

    //Update the current ETH price in cents
    function updatePriceETH(uint256 _updateETH) public onlyOwner {
        priceETH = _updateETH;
    }

    //Update the maximum buy in ETH
    function updateMaxBuyETH(uint256 _maxBuyETH) public onlyOwner {
        maxBuyETH = _maxBuyETH;
    }

    //Update the distribution batch size
    function updateBatchSize(uint256 _batchSize) public onlyOwner {
        batchSize = _batchSize;
    }

    //Distribute purchased tokens in batches
    function distributeTokens() public onlyOwner {

        for (uint256 i = 0; i < batchSize; i++) {
            address _userAddress = userIndex[i];
            uint256 _tokensOwed = purchaseData[_userAddress];
            if(_tokensOwed > 0) {
                require(tokenContract.transfer(_userAddress, _tokensOwed));
                purchaseData[_userAddress] = 0;
            }
        }
    }

    //Withdraw current ETH balance
    function withdraw() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    //End the token sale and transfer remaining ETH and tokens to the owner
    function endSale() public onlyOwner {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        msg.sender.transfer(address(this).balance);
        saleEnabled = false;
    }

    //Modifiers
    modifier onlyOwner() {
        require(owner == msg.sender, "Only current owner can call this function");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

