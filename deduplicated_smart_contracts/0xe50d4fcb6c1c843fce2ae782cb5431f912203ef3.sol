/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

pragma solidity ^0.5.16;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) 
            return 0;
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

}

contract ERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        if(_allowed[msg.sender][to] < uint256(-1))
            _allowed[msg.sender][to] = _allowed[msg.sender][to].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

}

contract ERC20Mintable is ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    function _mint(address to, uint256 amount) internal {
        _balances[to] = _balances[to].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        _balances[from] = _balances[from].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(from, address(0), amount);
    }
}

contract AGT {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;
    mapping(address => uint256) public mask;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 internal constant _totalSupply = 10000e18;
    uint256 public dividend;

    string public constant name = "Angel token";
    string public constant symbol = "AGT";
    uint8 public constant decimals = 18;

    ERC20 constant token = ERC20(0xE50D4FCb6C1c843fcE2aE782cb5431F912203EF3);

    constructor() public {
        _balances[msg.sender] = _totalSupply;
    }

    function distribute(uint256 amount) external {
        require (msg.sender == address(token));
        dividend = dividend.add( amount.mul(1e18).div(_totalSupply) );
    }

    function update(address holder) public {
        uint256 diff = dividend.sub(mask[holder]);
        mask[holder] = dividend;
        if(diff > 0)
            token.transfer(holder, diff.mul(_balances[holder].div(1e18)));
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        if(_allowed[msg.sender][to] < uint256(-1))
            _allowed[msg.sender][to] = _allowed[msg.sender][to].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        update(from);
        update(to);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

}

contract EGT is ERC20Mintable {

    AGT constant GTDAO = AGT(0x340942963663FcB0a206c2010544ad91bDdbED25);
    address public constant defaultRef = 0xFd11b6884B6B3D3eAecc794F531d503d9b3b1781;
    // --- EIP712 niceties ---
    bytes32 public DOMAIN_SEPARATOR;
    // bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)");
    bytes32 public constant PERMIT_TYPEHASH = 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;

    mapping(address => address) public ref;
    mapping(address => bool) public isMember;

    event Register(address indexed client, address indexed referrer);

    constructor(uint256 chainId_) public {
        symbol = "EGT";
        name = "Eth Gearing Token";
        decimals = 18;
        isMember[defaultRef] = true;
        ref[defaultRef] = defaultRef;

        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId_,
            address(this)
        ));
    }

    function register(address _referrer) public {
        require(!isMember[msg.sender]);
        if(!isMember[_referrer]) _referrer = defaultRef;

        ref[msg.sender] = _referrer;
        isMember[msg.sender] = true;

        emit Register(msg.sender, _referrer);
    }

    function buy() public payable {
        require(isMember[msg.sender]);

        uint256 amount = msg.value;
        _mint(msg.sender, amount.mul(1000));

        _mint(address(GTDAO), amount.mul(100));
        GTDAO.distribute(amount.mul(100));

        address referrer = ref[msg.sender];
        _mint(referrer, amount.mul(50));

        referrer = ref[referrer];
        _mint(referrer, amount.mul(30));

        referrer = ref[referrer];
        _mint(referrer, amount.mul(20));
    }

    function sell(uint256 amount) public {
        _burn(msg.sender, amount);
        uint256 eth = amount / 1200;
        (bool success, ) = msg.sender.call.value(eth)("");
        require(success);
    }

    function() external payable {
        buy();
    }

    mapping (address => uint256) public nonces;
    string  public constant version  = "1";

    // --- Approve by signature ---
    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) external
    {
        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH,
                                     holder,
                                     spender,
                                     nonce,
                                     expiry,
                                     allowed))
        ));

        require(holder != address(0), "invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "invalid-permit");
        require(expiry == 0 || now <= expiry, "permit-expired");
        require(nonce == nonces[holder]++, "invalid-nonce");
        uint256 amount = allowed ? uint256(-1) : 0;
        _allowed[holder][spender] = amount;
        emit Approval(holder, spender, amount);
    }

}