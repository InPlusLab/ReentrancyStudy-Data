/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity ^0.5.1;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic token.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    event Mint(address indexed to, uint256 value);
    event Burn(address indexed to, uint256 value);

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Mint(account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Burn(account, value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

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
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BITFEX is ERC20, Ownable {
    string public constant name = "BITFEX";
    string public constant symbol = "BFX";
    uint32 public constant decimals = 18;

    event Release(address indexed to, uint256 value);
    event TokensVestedTeam(address indexed to, uint256 value);
    event TokensVestedFoundation(address indexed to, uint256 value);
    event TokensVestedEmployeePool(address indexed to, uint256 value);
    event TokensVestedAdvisors(address indexed to, uint256 value);
    event TokensVestedBounty(address indexed to, uint256 value);
    event TokensVestedPrivateSale(address indexed to, uint256 value);
    event RevenueTransferred(address indexed from, uint256 value);

    uint256 public teamAmount = uint256(2e8).mul(1 ether); // 200 000 000 vested for 4 years, 12.5% every 6 months
    uint256 public foundationAmount = uint256(1e8).mul(1 ether); // 100 000 000 vested for 2 years, 50% every year
    uint256 public employeePoolAmount = uint256(5e7).mul(1 ether); // 50 000 000 locked for 1 year
    uint256 public liquidityAmount = uint256(5e7).mul(1 ether); // 50 000 000
    uint256 public advisorsAmount = uint256(25e6).mul(1 ether); // 25 000 000 vested for 6 months, 50% every 3 months
    uint256 public bountyAmount = uint256(25e6).mul(1 ether); // 25 000 000 locked for 3 months 
    uint256 public publicSaleAmount = uint256(4e8).mul(1 ether); // 400 000 000
    uint256 public privateSaleAmount = uint256(15e7).mul(1 ether); // 150 000 000 vested for 6 months, 50% every 3 months
    address public revenuesAddress; // address for revenues transferring, all tokens sent to this address will be burnt
    address[] private _vestedAddresses;
    mapping (address => bool) private _vestedAddressesAdded;

    mapping (address => uint256) private _balances_3_months; //locked
    mapping (address => uint256) private _released_3_months; //released 3 months
    mapping (address => uint256) private _balances_6_months; //vested 50% every 3 months
    mapping (address => uint256) private _released_6_months; //released 6 months
    mapping (address => uint256) private _balances_1_year; //locked
    mapping (address => uint256) private _released_1_year; //released 1 year
    mapping (address => uint256) private _balances_2_years; //vested 50% every year
    mapping (address => uint256) private _released_2_years; //released 2 years
    mapping (address => uint256) private _balances_4_years; //vested 12.5% every 6 months
    mapping (address => uint256) private _released_4_years; //released 4 years

    uint256 public vestingStartTime; // vesting program start time

    /**
    * @param newOwner Address of the contract owner
    */
    constructor(address newOwner) public {
        require(newOwner != address(0));
        _transferOwnership(newOwner);
        vestingStartTime = now;
    }

    /**
     * @dev Set revenuesAddress (all tokens sent to this address will be burnt)
     * @param newAddress Special address for revenues.
     */
    function setRevenuesAddress (address newAddress) public onlyOwner returns (bool) {
        require(newAddress != address(0));
        revenuesAddress = newAddress;
        return true;
    }

    /**
     * @dev Vest token for team
     * @param recipient The team address.
     * @param amount Token amount.
     * @return true if succeed.
     */
    function teamVest (address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(recipient != address(0));
        require(teamAmount >= amount, 'Tokens limit exceeded');
        if (!_vestedAddressesAdded[recipient]) {
            _vestedAddresses.push(recipient);
            _vestedAddressesAdded[recipient] = true;
        }
        teamAmount = teamAmount
            .sub(amount);
        _balances_4_years[recipient] = _balances_4_years[recipient]
            .add(amount);
        emit TokensVestedTeam(recipient, amount);
        return true;
    }

    /**
     * @dev Vest token for foundation
     * @param recipient The foundation address.
     * @param amount Token amount.
     * @return true if succeed.
     */
    function foundationVest (address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(recipient != address(0));
        require(foundationAmount >= amount, 'Tokens limit exceeded');
        if (!_vestedAddressesAdded[recipient]) {
            _vestedAddresses.push(recipient);
            _vestedAddressesAdded[recipient] = true;
        }
        foundationAmount = foundationAmount
            .sub(amount);
        _balances_2_years[recipient] = _balances_2_years[recipient]
            .add(amount);
        emit TokensVestedFoundation(recipient, amount);
        return true;
    }

    /**
     * @dev Vest token for employee pool
     * @param recipient The employee pool address.
     * @param amount Token amount.
     * @return true if succeed.
     */
    function employeePoolVest (address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(recipient != address(0));
        require(employeePoolAmount >= amount, 'Tokens limit exceeded');
        if (!_vestedAddressesAdded[recipient]) {
            _vestedAddresses.push(recipient);
            _vestedAddressesAdded[recipient] = true;
        }
        employeePoolAmount = employeePoolAmount
            .sub(amount);
        _balances_1_year[recipient] = _balances_1_year[recipient]
            .add(amount);
        emit TokensVestedEmployeePool(recipient, amount);
        return true;
    }

    /**
     * @dev Vest token for advisors
     * @param recipient The advisors address.
     * @param amount Token amount.
     * @return true if succeed.
     */
    function advisorsVest (address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(recipient != address(0));
        require(advisorsAmount >= amount, 'Tokens limit exceeded');
        if (!_vestedAddressesAdded[recipient]) {
            _vestedAddresses.push(recipient);
            _vestedAddressesAdded[recipient] = true;
        }
        advisorsAmount = advisorsAmount
            .sub(amount);
        _balances_6_months[recipient] = _balances_6_months[recipient]
            .add(amount);
        emit TokensVestedAdvisors(recipient, amount);
        return true;
    }

    /**
     * @dev Vest token for bounty
     * @param recipient The bounty address.
     * @param amount Token amount.
     * @return true if succeed.
     */
    function bountyVest (address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(recipient != address(0));
        require(bountyAmount >= amount, 'Tokens limit exceeded');
        if (!_vestedAddressesAdded[recipient]) {
            _vestedAddresses.push(recipient);
            _vestedAddressesAdded[recipient] = true;
        }
        bountyAmount = bountyAmount
            .sub(amount);
        _balances_3_months[recipient] = _balances_3_months[recipient]
            .add(amount);
        emit TokensVestedBounty(recipient, amount);
        return true;
    }

    /**
     * @dev Vest token for private sale
     * @param recipient The private sale address.
     * @param amount Token amount.
     * @return true if succeed.
     */
    function privateSaleVest (address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(recipient != address(0));
        require(privateSaleAmount >= amount, 'Tokens limit exceeded');
        if (!_vestedAddressesAdded[recipient]) {
            _vestedAddresses.push(recipient);
            _vestedAddressesAdded[recipient] = true;
        }
        privateSaleAmount = privateSaleAmount
            .sub(amount);
        _balances_6_months[recipient] = _balances_6_months[recipient]
            .add(amount);
        emit TokensVestedPrivateSale(recipient, amount);
        return true;
    }

    /**
     * @dev Send token for sale
     * @param recipient The recipient's address.
     * @param amount Token amount.
     * @return true if succeed.
     */
    function sendSaleTokens (address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(amount > 0);
        require(recipient != address(0));
        require(publicSaleAmount >= amount, 'Tokens limit exceeded');
        publicSaleAmount = publicSaleAmount
            .sub(amount);
        _mint(recipient, amount);
        return true;
    }

    /**
     * @dev Send token for liquidity
     * @param recipient The recipient's address.
     * @param amount Token amount.
     * @return true if succeed.
     */
    function sendLiquidityTokens (address recipient, uint256 amount) public onlyOwner returns (bool) {
        require(amount > 0);
        require(recipient != address(0));
        require(liquidityAmount >= amount, 'Tokens limit exceeded');
        liquidityAmount = liquidityAmount
            .sub(amount);
        _mint(recipient, amount);
        return true;
    }

    /**
     * @dev Returns balance of the vested tokens
     * @param who Address for which balance will be returned.
     */
    function vestedBalanceOf(address who) public view returns (uint256) {
        return _balances_3_months[who]
            .add(_balances_6_months[who])
            .add(_balances_1_year[who])
            .add(_balances_2_years[who])
            .add(_balances_4_years[who]);
    }

    /**
     * @dev Internal function, returns balance of the vested for 3 months tokens available for release
     * @param who Address for which balance will be returned.
     */
    function _available3months(address who) private view returns (uint256) {
        if (now.sub(vestingStartTime) > 91 days)
            return _balances_3_months[who]
                .sub(_released_3_months[who]);
        return 0;
    }

    /**
     * @dev Internal function, returns balance of the vested for 6 months tokens available for release
     * @param who Address for which balance will be returned.
     */
    function _available6months(address who) private view returns (uint256) {
        uint256 timeFromVestingStart = now
            .sub(vestingStartTime);
        if (timeFromVestingStart < 91 days)
            return 0;
        else if (timeFromVestingStart < 182 days)
            return _balances_6_months[who]
                .div(2)
                .sub(_released_6_months[who]);
        else
            return _balances_6_months[who]
                .sub(_released_6_months[who]);
    }

    /**
     * @dev Internal function, returns balance of the vested for 1 year tokens available for release
     * @param who Address for which balance will be returned.
     */
    function _available1year(address who) private view returns (uint256) {
        if (now.sub(vestingStartTime) > 365 days)
            return _balances_1_year[who]
                .sub(_released_1_year[who]);
        return 0;
    }

    /**
     * @dev Internal function, returns balance of the vested for 2 years tokens available for release
     * @param who Address for which balance will be returned.
     */
    function _available2years(address who) private view returns (uint256) {
        uint256 timeFromVestingStart = now
            .sub(vestingStartTime);
        if (timeFromVestingStart < 365 days)
            return 0;
        else if (timeFromVestingStart < 730 days)
            return _balances_2_years[who]
                .div(2)
                .sub(_released_2_years[who]);
        else
            return _balances_2_years[who]
                .sub(_released_2_years[who]);
    }

    /**
     * @dev Internal function, returns balance of the vested for 4 years tokens available for release
     * @param who Address for which balance will be returned.
     */
    function _available4years(address who) private view returns (uint256) {
        uint256 timeFromVestingStart = now
            .sub(vestingStartTime);
        uint256 vestingPeriod = timeFromVestingStart
            .div(182 days);
        if (vestingPeriod > 8) vestingPeriod = 8;
        return _balances_4_years[who]
            .mul(vestingPeriod)
            .mul(125)
            .div(1000)
            .sub(_released_4_years[who]);
    }

    /**
     * @dev Returns balance of the vested tokens available for release
     * @param who Address for which balance will be returned.
     */
    function availableBalanceOf(address who) public view returns (uint256) {
        return _available3months(who)
            .add(_available6months(who))
            .add(_available1year(who))
            .add(_available2years(who))
            .add(_available4years(who));
    }

    /**
     * @dev Internal function Release vested tokens according to the current date
     * @param who Address for which tokens will be released.
     */
    function _release(address who) internal returns (bool) {
        uint256 toRelease;
        uint256 available = _available3months(who);
        if (available > 0) {
            _released_3_months[who] = _released_3_months[who]
                .add(available);
            toRelease =  toRelease
                .add(available);
        }
        available = _available6months(who);
        if (available > 0) {
            _released_6_months[who] = _released_6_months[who]
                .add(available);
            toRelease =  toRelease
                .add(available);
        }
        available = _available1year(who);
        if (available > 0) {
            _released_1_year[who] = _released_1_year[who]
                .add(available);
            toRelease =  toRelease
                .add(available);
        }
        available = _available2years(who);
        if (available > 0) {
            _released_2_years[who] = _released_2_years[who]
                .add(available);
            toRelease =  toRelease
                .add(available);
        }
        available = _available4years(who);
        if (available > 0) {
            _released_4_years[who] = _released_4_years[who]
                .add(available);
            toRelease =  toRelease
                .add(available);
        }
        if (toRelease > 0) {
            _mint(who, toRelease);
            emit Release(who, toRelease);
        }
        return true;
    }

    /**
     * @dev Release vested tokens according to the current date
     */
    function release() public returns (bool) {
        return _release(msg.sender);
    }

    /**
     * @dev Release all vested tokens according to the current date
     */
    function releaseAll() public onlyOwner returns (bool) {
        for (uint256 i = 0; i < _vestedAddresses.length; i ++) {
            _release(_vestedAddresses[i]);
        }
        return true;
    }

    /**
     * @dev Burning tokens sent to the revenuesAddress address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0));
        if (to != revenuesAddress)
            return super.transfer(to, value);
        super.transfer(to, value);
        _burn(to, value);
        emit RevenueTransferred(msg.sender, value);
        return true;
    }

    /**
     * @dev Burning tokens sent to the revenuesAddress address
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0));
        if (to != revenuesAddress)
            return super.transferFrom(from, to, value);
        super.transferFrom(from, to, value);
        _burn(to, value);
        emit RevenueTransferred(from, value);
        return true;
    }
}