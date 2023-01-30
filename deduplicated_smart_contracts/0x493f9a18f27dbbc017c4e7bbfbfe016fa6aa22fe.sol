/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

pragma solidity >=0.4.23 < 0.6.0;


library SafeMath {

  /**
   * @dev Multiplies two numbers, throws on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
   * @dev Integer division of two numbers, truncating the quotient.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
   * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
   * @dev Adds two numbers, throws on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 */
contract Ownable {
    address internal _owner;
    mapping (address => bool) internal _admins;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AdminAdded(address indexed newAdmin);
    event AdminDelet(address indexed dropAdmin);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract
     * to the sender account.
     */
    constructor () internal {
        _owner = msg.sender;
        _admins[_owner] = true;
        emit OwnershipTransferred(address(0), _owner);
        emit AdminAdded(_owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    function isAdmin(address addr) public view returns (bool) {
        return _admins[addr];
    }

    function addAdmin(address admin) public onlyOwner returns (bool) {
        _admins[admin] = true;
        emit AdminAdded(admin);
        return true;
    }

    function delAdmin(address admin) public onlyOwner returns (bool) {
        _admins[admin] = false;
        emit AdminDelet(admin);
        return true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(address tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(receiver != address(0));
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount);
        assert(_token.transfer(receiver, amount));
    }

    /**
     * @dev Withdraw Ether
     */
    function withdrawEther(address to, uint256 amount) external payable onlyOwner {
        require(to != address(0));

        uint256 balance = address(this).balance;

        require(balance >= amount);
        to.transfer(amount);
    }
}

library ERC20AsmFn {

    function isContract(address addr) internal view {
        assembly {
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }

    function handleReturnData() internal pure returns (bool result) {
        assembly {
            switch returndatasize()
            case 0 { // not a std erc20
                result := 1
            }
            case 32 { // std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function asmTransfer(address _erc20Addr, address _to, uint256 _value) internal returns (bool result) {

        // Must be a contract addr first!
        isContract(_erc20Addr);

        // call return false when something wrong
        require(_erc20Addr.call(bytes4(keccak256("transfer(address,uint256)")), _to, _value));

        // handle returndata
        return handleReturnData();
    }

    function asmTransferFrom(address _erc20Addr, address _from, address _to, uint256 _value) internal returns (bool result) {

        // Must be a contract addr first!
        isContract(_erc20Addr);

        // call return false when something wrong
        require(_erc20Addr.call(bytes4(keccak256("transferFrom(address,address,uint256)")), _from, _to, _value));

        // handle returndata
        return handleReturnData();
    }

    function asmApprove(address _erc20Addr, address _spender, uint256 _value) internal returns (bool result) {

        // Must be a contract addr first!
        isContract(_erc20Addr);

        // call return false when something wrong
        require(_erc20Addr.call(bytes4(keccak256("approve(address,uint256)")), _spender, _value));

        // handle returndata
        return handleReturnData();
    }
}

contract Pausable is Ownable{
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract smartANT is Ownable, Pausable {
    using ERC20AsmFn for IERC20;
    using SafeMath for uint256;

    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        uint pendingReward;
        uint pendingAntDex;

        
        mapping (uint8 => Matrix) activeMatrix;
        // mapping(uint8 => bool) activePartners;
    }
    
    struct Matrix {
        bool blocked;
        uint purchased;
        address[] referrals;
    }
    
    uint public lastUserId = 2;
    
    address public rootAddress;
    
    address internal _defaultToken;
    address internal _defaultAntToken;
    
    mapping(uint8 => uint) public matrixPrice;
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    // mapping(uint => address) public userIds;

    
    uint antRate = 10;
    uint antPercentage = 50;
    
    /// @dev event
    event Donate(address indexed donator, uint indexed value);
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event UsdtReward(address indexed from, address indexed receiver, uint8 matrix, uint reward);
    event AntReward(address indexed from, address indexed receiver, uint8 matrix, uint reward);
    
    constructor(address _rootAddress, uint[] memory _matrixPrice, uint _decimals) public {
        uint _len = _matrixPrice.length;
        for (uint8 _i=0; _i<_len; _i++) {
            matrixPrice[_i+1] = _matrixPrice[_i] * 10**_decimals;
        }
        
        rootAddress = _rootAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0),
            pendingReward: uint(0),
            pendingAntDex: uint(0)
        });
        
        users[_rootAddress] = user;
        idToAddress[1] = _rootAddress;
 
    }
    
    function() external payable {
        // donate
        emit Donate(msg.sender, msg.value);
    }
    
    function SetUsdtAddress(address token) public onlyAdmin returns (bool) {
        _defaultToken = token;
        return true;
    }
    
    function usdtToken() public view returns(address) {
        return _defaultToken;
    }
    
    function SetAntAddress(address token) public onlyAdmin returns (bool) {
        _defaultAntToken = token;
        return true;
    }
    
    function antToken() public view returns(address) {
        return _defaultAntToken;
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function registrationExt(address referrerAddress, uint8 matrix) external {
        require(matrix>0 && matrix<4, "matrix error");
        registration(msg.sender, referrerAddress, matrix);
    }
    
    function registration(address userAddress, address referrerAddress, uint8 matrix) private {
        require(!isUserExists(userAddress), "user exist");
        require(isUserExists(referrerAddress), "referrer not exists");
        IERC20 _token = IERC20(_defaultToken);
        require(_token.asmTransferFrom(userAddress, address(this), matrixPrice[matrix]),  "registration cost insufficient usdt");
        
        // ensure  !contractAddress 
        uint _size;
        assembly {
            _size := extcodesize(userAddress)
        }
        require (_size == 0, "User address can not be contract address.");
        
        // init user
        User memory user = User ({
            id:lastUserId,
            referrer: referrerAddress,
            partnersCount: 0,
            pendingReward: uint(0),
            pendingAntDex: uint(0)
        });
        users[userAddress] = user;
        users[userAddress].activeMatrix[matrix].purchased = users[userAddress].activeMatrix[matrix].purchased.add(matrixPrice[matrix]);
        idToAddress[lastUserId] = userAddress;
        users[referrerAddress].activeMatrix[matrix].referrals.push(userAddress);
        users[referrerAddress].partnersCount += 1;

        doProfit(userAddress, matrix);
        
        lastUserId += 1;
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
        

    }
    
    function buyNewMatrix(uint8 matrix) external {
        require(isUserExists(msg.sender), "user not exist");
        require(matrix>0 && matrix<4, "matrix error");
        IERC20 _token = IERC20(_defaultToken);
        require(_token.asmTransferFrom(msg.sender, address(this), matrixPrice[matrix]),  "registration cost insufficient usdt");

        // ¹ºÂòmatrix
        users[msg.sender].activeMatrix[matrix].purchased = users[msg.sender].activeMatrix[matrix].purchased.add(matrixPrice[matrix]);
        doProfit(msg.sender, matrix);
    }

    function doProfit(address user, uint8 matrix) private {
        address _receiver = findReceiver(user);
        sendDividends(user, _receiver, matrix);
        sendDividends(user, user, matrix);
    }

    function pendingRewards(address user) public view returns (uint, uint) {
        return (users[user].pendingReward,
                users[user].pendingAntDex);
    }

    function usersMatrix(address user, uint8 matrix) public view returns(bool, uint, address[] memory) {
        return (users[user].activeMatrix[matrix].blocked,
                users[user].activeMatrix[matrix].purchased,
                users[user].activeMatrix[matrix].referrals);
    }

    function findReceiver(address user) private view returns(address) {
        return users[user].referrer;
    }
    
    function sendDividends(address user, address receiver, uint8 matrix) private returns (bool) {
        uint _usdtReward = 0;
        uint _antReward  = 0;
        IERC20 _token = IERC20(_defaultToken);
        IERC20 _antToken = IERC20(_defaultAntToken);
        
        require(user != address(0), "address invalid.");
        require(receiver != address(0), "address invalid.");

        if (user  == receiver) {
            _antReward = matrixPrice[matrix].mul(antRate);
            if (matrix != 1) _antReward = _antReward.mul(40).div(100);
            if (paused) {
                users[receiver].pendingAntDex = users[receiver].pendingAntDex.add(_antReward);
            } else {
                require(_antToken.asmTransfer(receiver, _antReward),  "insufficient usdt");
            }

            emit AntReward(user, receiver, matrix, _antReward);
            return true;
        } else {
            uint _count = users[receiver].partnersCount;
            uint _reward = 0;
            if (_count>0 && _count<5) _reward = matrixPrice[matrix].mul(40).div(100);
            if (_count>4 && _count<10) _reward = matrixPrice[matrix].mul(45).div(100);
            if (_count>9) _reward = matrixPrice[matrix].mul(50).div(100);

            _usdtReward = _reward.mul(uint(100).sub(antPercentage)).div(100);
            _antReward = _reward.mul(antPercentage).div(100).mul(antRate);

            if (paused) {
                users[receiver].pendingReward = users[receiver].pendingReward.add(_usdtReward);
                users[receiver].pendingAntDex = users[receiver].pendingAntDex.add(_antReward);
            } else {
                // UsdtReward
                require(_token.asmTransfer(receiver, _usdtReward),  "insufficient usdt");
                // AntReward
                require(_antToken.asmTransfer(receiver, _antReward),  "insufficient ant");
            }

            emit UsdtReward(user, receiver, matrix, _usdtReward);
            emit AntReward(user, receiver, matrix, _antReward);
        }
    }

    function withdrawUsdt(uint value) public returns (bool) {
        require(users[msg.sender].pendingReward >= value, "insufficient usdt");
        IERC20 _token = IERC20(_defaultToken);
        require(_token.asmTransfer(msg.sender, value),  "registration cost insufficient usdt");
        users[msg.sender].pendingReward = users[msg.sender].pendingReward.sub(value);
        return true;
    }

    function withdrawAnt(uint value) public returns (bool) {
        require(users[msg.sender].pendingAntDex >= value, "insufficient ant");
        IERC20 _token = IERC20(_defaultAntToken);
        require(_token.asmTransfer(msg.sender, value),  "registration cost insufficient ant");
        users[msg.sender].pendingAntDex = users[msg.sender].pendingAntDex.sub(value);
        return true;
    }

    function setAntRate(uint8 newRate) public onlyAdmin returns (bool) {
        require(newRate > 0, "Rate illegal");
        antRate = newRate;
        return true;
    }

    function setAntPercentage(uint8 newPercentage) public onlyAdmin returns (bool) {
        require(newPercentage > 0, "Percentage illegal");
        antPercentage = newPercentage;
        return true;
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}