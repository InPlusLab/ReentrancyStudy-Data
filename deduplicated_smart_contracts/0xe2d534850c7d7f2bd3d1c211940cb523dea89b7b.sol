/**
 *Submitted for verification at Etherscan.io on 2019-11-03
*/

pragma solidity >=0.5.0 <0.6.0; 

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


contract AladdinToken {

    //=====================================================================================================================
    //==SECTION-1, Standard ERC20-TOKEN. Only transfer() been modified.
    //=====================================================================================================================

    using SafeMath for uint256;

    string constant private _name = "ADS";
    string constant private _symbol = "ADS";
    uint8 constant private _decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _special;
    
    uint256 constant private _totalSupply = (10**9)*(10**18);
    uint256 private _bancorPool;
    address public LOCK = 0x597f40FE34D1eCb851bD54Cb6AF4F5c940312C89;
    address public TEAM = 0x89C275BcaF12296CcCE3b396b0110385089aDe8D;
    uint256 public startTime;
     
    constructor() public {
        startTime = block.timestamp;
        _balances[LOCK] = 7*(10**8)*(10**18);
        _balances[TEAM] = (10**8)*(10**18);
        _bancorPool = 2*(10**8)*(10**18);
    }

    function viewBancorPool() public view returns (uint256) {
        return _bancorPool;
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        if(msg.sender == LOCK || _special[msg.sender]) {
            require(block.timestamp.sub(startTime) > 3*12*30 days); //Lock 3 years;
        } 
        else if(msg.sender == TEAM && amount > 0) {
            require(_balances[recipient] == 0 || _special[recipient]);
            _special[recipient] = true;
        }
        _transfer(msg.sender, recipient, amount); 
        return true;
    }
    
    function batchTransfer(address[] memory recipients , uint256[] memory amounts) public returns (bool) {
        require(recipients.length == amounts.length);
        for(uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
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

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    //=====================================================================================================================
    //==SECTION-2, BANCOR-TOKEN
    //=====================================================================================================================
    
    uint256 constant private BASE_UNIT = 10**18;  // 000000000000000000
    uint256 constant private _baseSupply = 3333*2*1500*BASE_UNIT; // 3333 * 2 = 6666
    uint256 constant private _baseBalance = 3333*BASE_UNIT; // 3333 * 3 = 9999£¬ 9999 + 1 = 10000
    uint256 private _virtualSupply = _baseSupply;
    uint256 private _virtualBalance = _baseBalance;
    uint256 constant private ROE_UNIT = BASE_UNIT; //Same decimal as ETH.
    uint256 constant public RCW = 2;  // Reciprocal CW, CW == 50% == 1/2;
    
    function realSupply() public view returns (uint256) {
        return _virtualSupply.sub(_baseSupply);
    }
    
    function realBanlance() public view returns (uint256) {
        return _virtualBalance.sub(_baseBalance);
    }
    
    // TODO overflow test.
    function sqrt(uint256 a) public pure returns (uint256 b) {
        uint256 c = (a+1)/2;
        b = a;
        while (c<b) {
            b = c;
            c = (a/c+c)/2;
        }
    }
    
    function oneEthToAds() public view returns (uint256) {
        return ROE_UNIT.mul(_virtualSupply).div(_virtualBalance.mul(2));
    }
    
    function oneAdsToEth() public view returns (uint256) {
        return ROE_UNIT.mul(_virtualBalance).div(_virtualSupply.div(2));
    }
    
    /*****************************************************************
    tknWei = supply*((1+ethWei/ethBlance)^(1/2)-1)
           = supply*(sqrt((ethBlance+ethWei)/ethBlance)-1);
           = supply*sqrt((ethBlance+ethWei)/ethBlance)-supply;
           = sqrt(supply*supply*(ethBlance+ethWei)/ethBlance)-supply;
           = sqrt(supply*supply*sum/ethBlance)-supply;
    *****************************************************************/  
    // When ethWei is ZERO, tknWei might be NON-ZERO.
    // This is because sell function retun eth value is less than precise value.
    // So it will Accumulate small amount of differences.
    function _bancorBuy(uint256 ethWei) internal returns (uint256 tknWei) {
        uint256 savedSupply = _virtualSupply;
        _virtualBalance = _virtualBalance.add(ethWei); //sum is new ethBlance.
        _virtualSupply = sqrt(_baseSupply.mul(_baseSupply).mul(_virtualBalance).div(_baseBalance));
        tknWei = _virtualSupply.sub(savedSupply);
        if(ethWei == 0) { // to reduce Accumulated differences.
            tknWei = 0;
        }
    }
    
    function evaluateEthToAds(uint256 ethWei) public view returns (uint256 tknWei) {
        if(ethWei > 0) {
            tknWei = sqrt(_baseSupply.mul(_baseSupply).mul(_virtualBalance.add(ethWei)).div(_baseBalance)).sub(_virtualSupply);
        }
    }
    
    function oneEthToAdsAfterBuy(uint256 ethWei) public view returns (uint256) {
        uint256 vb = _virtualBalance.add(ethWei);
        uint256 vs = sqrt(_baseSupply.mul(_baseSupply).mul(vb).div(_baseBalance));
        return ROE_UNIT.mul(vs).div(vb.mul(2));
    }
 
    //=====================================================================================================================
    //==SECTION-3, main program
    //=====================================================================================================================
    
    function _buyMint(uint256 ethWei, address buyer) internal returns (uint256 tknWei) {
        tknWei = _bancorBuy(ethWei);
        _balances[buyer] = _balances[buyer].add(tknWei);
        _bancorPool = _bancorPool.sub(tknWei);
        
        emit Transfer(address(0), buyer, tknWei);
    }
    
    // TODO, JUST FOR TEST ENV, NEED TO DELETE THIS FUNCTION WHEN DEPLOYED IN PRODUCTION ENV!!!
    //function buyMint(uint256 ethWei) public returns (uint256 tknWei) {
        //tknWei = _buyMint(ethWei, msg.sender);
    //}
    
    address public ethA = 0x1F49ac62066FBACa763045Ac2799ac43C7fDe6B8;
    address public ethB = 0x1D01C11162c4808a679Cf29380F7594d3163AF8d;
    address public ethC = 0x233bEEd512CE10ed72Ad6Bd43a5424af82d9D5Ef;
    mapping (address => uint256) private _ethOwner;
    
    function() external payable {
        if(msg.value > 0) {
            allocate(msg.value);
            _buyMint(msg.value, msg.sender);
        } else if (msg.sender == ethA || msg.sender == ethB || msg.sender == ethC) {
            msg.sender.transfer(_ethOwner[msg.sender]);
            _ethOwner[msg.sender] = 0;
        }
    }
    
    function allocate(uint256 ethWei) internal {
        uint256 foo = ethWei.mul(70).div(100);
        _ethOwner[ethA] = _ethOwner[ethA].add(foo);
        ethWei = ethWei.sub(foo);
        foo = ethWei.mul(67).div(100);
        _ethOwner[ethB] = _ethOwner[ethB].add(foo);
        _ethOwner[ethC] = _ethOwner[ethC].add(ethWei.sub(foo));
    }
    
    function viewAllocate(address addr) public view returns (uint256) {
        return _ethOwner[addr];
    }
    
}