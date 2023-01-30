/**
 *Submitted for verification at Etherscan.io on 2019-10-16
*/

/**

[                                                       ]
[ READ OUR LATEST COMMUNIQUE AT www.reigningemperor.com ]
[                                                       ]

REIGNING EMPEROR (当今皇上)

Reading this means that you are in danger.

This smart contract is an act of political protest and before you interact with our movement through it, you need to be sure that you really want to continue down this path of activism.

Think it over and scroll down if you're ready to go deeper.

.
.
.
.
.
.
.


Good, you're still here — so let's get into it.

We are a revolutionary movement in China known for the protest meme REIGNING EMPEROR (当今皇上).

Those words, a critical reference to our powerful party leader, is our rallying cry for the restoration of a revolutionary people's republic where the many have more power than the few.

Lately, as our movement has grown in prominence, and our people have started doing "surround and watch" (围观) protests across the mainland and sometimes in diaspora, the powerful ones have taken notice of us.

They want to eradicate our movement.

REIGNING EMPEROR (当今皇上) is now banned: instantly deleted by an algorithm the moment anyone uses the phrase publicly online or privately in messaging apps.

Those who used the phrase 当今皇上 in the past have had their social score lowered. Some  have been detained.  Our movement's founder (楼主), in fact, has not been seen for some time.


Banning us was an overstep. 当今皇上 has not been defeated but we have been forced to move to different fields of operation.

That is where you come in.

This smart contract is the embodiment of our movement and the reason why we'll eventually win.

By interacting with us via this code you: spread the protest, thwart the authorities and fund our movement.

THE RULES OF THIS PROTEST

To instantiate our movement on the Ethereum blockchain, we have created a protest game.

You may chose to be either: an activist or the police.

The objective of activists is to transfer our unique REIGNING EMPEROR (当今皇上) protest tokens to every active wallet on the blockchain.

The objective of the police is to delete our protest token from the blockchain by "arresting" activists. Police can remove tokens from any wallet, and stop that wallet from sending or receiving tokens, if they have 10 times as many tokens as the wallet they wish to "arrest."

Activists verified by HumanityDAO have the special ability to liberate other players from "jail."

The game ends when it has been played for at least 28 days and there are no tokens on the blockchain. If these two condition are met then this contract can be forced to self-destruct, permanently removing all protest tokens from the blockchain.

HOW TO SPREAD PROTEST

1. Acquire protest tokens by sending any amount of ether to this contract. Be sure to include a high gas limit. Once the ether has been received, you'll instantly receive 8640 当今皇上 per 1 eth.

	• Play for free: send 0 eth to this contract and receive 1 token.

	• This token funds actual activists. All ether sent to this contract is converted into Sparkle, a redistributive currency, and given entirely to a real activist organization in China.

2. Sending 当今皇上 tokens does not deplete your wallet's balance.

• If you have 100 tokens and transfer 100 tokens then you still have 100 tokens.

3. Tokens can only be transferred to wallets that have 0 tokens.

• Your balance equals the number of tokens you've received in the first transfer made to your wallet. The only way to increase the size of your wallet later on is by buying tokens from this contract.

4. For each token that you transfer, you must wait one second before making another transfer.

• If you send 100 tokens, then you must wait 100 seconds.

5. Tokens can only be sent to wallets that have more than 0 eth.

• The goal is to send the protest tokens to real humans.

Examine the source code of this contract and you'll discover special moves, such as detainPlayer, freePlayer, goUnderground and gameOver.

*/

pragma solidity ^0.5.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Sparkle is ERC20Detailed {


    function totalSupply() public view returns (uint256) {}

    function tobinsCollected() public view returns (uint256) {}

    function balanceOf(address owner) public view returns (uint256) {}

    function allowance(address owner, address spender) public view returns (uint256) {}

    function transfer(address to, uint256 value) public returns (bool) {}

    function transferFrom(address from, address to, uint256 value) public returns (bool) {  }

    function approve(address spender, uint256 value) public returns (bool) { }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {    }

    function () external payable {
        mintSparkle();
    }

    function mintSparkle() public payable returns (bool) {

    }

    function sellSparkle(uint256 amount) public returns (bool) {

    }


}

contract HumanityCheck {

  function isHuman(address who) public view returns (bool) {}
}


contract ReigningEmperor is ERC20Detailed {
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => uint256) private _detentionCamp; // record of arrested addresses
  mapping (address => uint256) private _underground; // record of players in safehouse
  mapping (address => uint256) private _points; // record of points
  mapping (address => uint256) private _arrests; // record of arrests
  mapping (address => uint256) private _releaseTime; // timelock on sending tokens

  uint256 private _totalSupply;
  uint256 private _totalCollected;
  uint256 private _startTime;

  uint256 public constant COST_PER_TOKEN = 1157407407407000; // 1 eth = 8640 Reigning Emperor tokens
  uint256 public constant MAX_COLLECTED = 9999000000000000000000; // 9999 eth maximum
  address payable deployed_sparkle = 0x286ae10228C274a9396a05A56B9E3B8f42D1cE14;
  address payable beneficiary = 0x15C8Ac6f003617452C860f3A600D00D46adbde8a; // Activists in China

  event playerDetained(address arrester, address arrestee);
  event playerFreed(address freedBy, address playerFreed);

  constructor() public ERC20Detailed("当今皇上", "REIGNING EMPEROR", 0) { // "Reigning Emperor"

    _startTime = now;
    _mint(msg.sender, 8640000);

    }


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // to construct a leaderboard of protesters
    function pointsOfProtester(address owner) public view returns (uint256) {
        return _points[owner];
    }

    // to construct a leaderboard of police
    function pointsOfPolice(address owner) public view returns (uint256) {
        return _arrests[owner];
    }


    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer must be greater than 0");
        require(_balances[recipient] == 0, "Recipient is already a protester.");
        require(recipient.balance != 0, "Recipient must have more than 0 eth in account.");
        require(_balances[sender] >= amount, "You do not have enough followers to organize that protest.");
        require(_detentionCamp[sender] == 0, "You are in detention camp.");
        require(_detentionCamp[recipient] == 0, "Oh no! Your comrade is in a detention camp.");
        require(block.timestamp >= _releaseTime[sender], "Your revolutionary energy is exhausted... you need to wait before organizing another protest.");

        // sender balance does not change on transfers, however it takes time to restore balance
        _releaseTime[sender] = now.add(amount); // 1 seconds per 1 token sent
        _balances[recipient] = amount; // recipient's balance is determined by sender

        _points[sender] = _points[sender].add(1); // sender receives 1 game point per transfer

        _totalSupply = _totalSupply.add(amount);

        // bonus for sending token to verified humans
        HumanityCheck deployed_humanitydao = HumanityCheck(0x4EE46dc4962C2c2F6bcd4C098a0E2b28f66A5E90);
         if (deployed_humanitydao.isHuman(recipient)) {
           uint256 bonus = amount.mul(2).div(10);
           _balances[sender] = _balances[sender].add(amount).add(bonus);
           _totalSupply = _totalSupply.add(bonus).add(amount);
         }

        emit Transfer(sender, recipient, amount);
    }




    function sparkleBalanceOfBeneficiary() public view returns (uint256) {

        uint256 sparkleBalance = Sparkle(deployed_sparkle).balanceOf(address(this));
        return sparkleBalance;
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(value, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    // confirm that this should be public vs external
    function detainPlayer(address player) public returns (bool) {

        // once a player has been arrested they can no longer send tokens from that address

        require(_totalCollected <= MAX_COLLECTED, "The protesters won. Game over.");
        require(_balances[msg.sender] >= _balances[player].mul(10), "You must have 10x the resources of the protester you wish to arrest.");

        if(_underground[player] == 1){
          require(_balances[msg.sender] >= _balances[player].mul(30), "This activist is in safehouse. You must have 30x the resources of the protester you wish to arrest.");
          _balances[msg.sender] = _balances[msg.sender].mul(70).div(100); // 30% of balance is depleted in detention operation
          _detentionCamp[player] = _balances[player];
          _burn(player, _balances[player]);
          _underground[player] = 0;
          _arrests[msg.sender] = _arrests[msg.sender].add(10); // 2 points for arresting protester in safehouse

          emit playerDetained(msg.sender, player);
          return true;
        } else {
          uint256 supplyDecrease = _balances[msg.sender].mul(10).div(100); // 10% of balance is depleted in detention operation
        _balances[msg.sender] = _balances[msg.sender].sub(supplyDecrease);
        _detentionCamp[player] = _balances[player]; // keep a record of how many tokens player had at time of arrest
        _burn(player, _balances[player]);
        _totalSupply = _totalSupply.sub(supplyDecrease);
        _arrests[msg.sender] = _arrests[msg.sender].add(1); // 1 point for normal arrest
        emit playerDetained(msg.sender, player);
        return true;
        }

    }

    // external or public?
    function freePlayer(address account) public returns (bool) {
      require(_totalCollected <= MAX_COLLECTED, "The protesters won. Game over.");
      require(msg.sender != account, "You cannot free yourself.");
      require(account != address(0), "You cannot free the 0 account");
      require(_balances[msg.sender] != 0, "You are not a protester.");

      // only humans can free players.
      HumanityCheck deployed_humanitydao = HumanityCheck(0x4EE46dc4962C2c2F6bcd4C098a0E2b28f66A5E90);
      require (deployed_humanitydao.isHuman(msg.sender), "You must be a human to free a player. Register with HumanityDao.org");
        uint256 supplyDecrease = _balances[msg.sender].mul(10).div(100); // 10% of balance is depleted in freeing operation
        _balances[msg.sender] = _balances[msg.sender].sub(supplyDecrease);
        _mint(account, _detentionCamp[account]); // player receives their old balance
        _totalSupply = _totalSupply.sub(supplyDecrease);
        _detentionCamp[account] = 0;

        emit playerFreed(msg.sender, account);
        return true;
    }

    function goUnderground() public returns (bool) {
      require(_totalCollected <= MAX_COLLECTED, "The protesters won. Game over.");
      require(_points[msg.sender] >= 100, "You must activate at least 100 protesters before you may go underground.");
      require(_underground[msg.sender] != 1, "You are already in a safehouse.");

        _underground[msg.sender] = 1;

        return true;
    }


  function () external payable {
      protest();
  }

  function protest() public payable returns (bool) {
    require(_totalCollected <= MAX_COLLECTED, "The protesters won. Game over.");
    require(_detentionCamp[msg.sender] != 1, "You are in detention camp.");
    if(msg.value == 0) {
      _mint(msg.sender, 1);
      return true;
    } else {
      // TODO = ADD a fallback in case buying Sparkle fails.
      deployed_sparkle.call.value(msg.value).gas(120000)("");
      uint256 amount = msg.value.div(COST_PER_TOKEN);
      _mint(msg.sender, amount);
      _totalCollected = _totalCollected.add(msg.value);
      return true;
    }

  }

    function sellSparkle(uint256 amount) public returns (bool) {
              require(msg.sender == beneficiary, "Access denied.");
              Sparkle(deployed_sparkle).sellSparkle(amount);
              beneficiary.transfer(address(this).balance);
              return true;
          }

          // just in case ether gets stuck in contract, this will clear it
    function emptyPot() public returns (bool) {
              require(msg.sender == beneficiary, "Access denied.");
              uint256 pot = address(this).balance;
              msg.sender.transfer(pot);
              return true;
                }


          function withdrawSparkle(uint256 amount) public returns (bool) {
                require(msg.sender == beneficiary, "Access denied.");
                Sparkle(deployed_sparkle).transfer(beneficiary, amount);
                return true;
                      }

          // this function is for protesters that retire from the movement
          // this function can also used by police, once they've arrested all
          // protesters to bring their token balance to 0 in order to end the game
          function stopProtesting() public returns (bool){
            _burn(msg.sender, _balances[msg.sender]);
            return true;
          }

          // Game is won if:
          // 1. The maximum of 9999 eth has been donated.
          //
          // All tokens are stored permanently on the blockchain and tokens can be
          // freely transfered forever.

          // Game is lost if:
          // 1. it has been played for at least 28 days
          // 2. there are zero tokens on the blockchain, not including balance of
          // player attempting to end the game. IE, all protesters have been arrested.
          //
          //
          // All tokens are removed from the blockchain and contract is deleted.


          function gameOver() public returns (bool)  {
          require(_totalCollected <= MAX_COLLECTED, "The protesters won. Game over.");
           require(block.timestamp >= _startTime + 28 days, "Game must be played for 28 days before it can end.");
           // balance of caller is not counted
           uint256 _tokensRemaining = _totalSupply.sub(_balances[msg.sender]);
            require(_tokensRemaining == 0, "There are still protesters active in the movement.");

            uint256 finalAmount = sparkleBalanceOfBeneficiary().mul(975).div(100); // allow for 2.25% transaction tax + margin of error
            Sparkle(deployed_sparkle).transfer(beneficiary, finalAmount);
            selfdestruct(beneficiary);
            return true;
          }

}