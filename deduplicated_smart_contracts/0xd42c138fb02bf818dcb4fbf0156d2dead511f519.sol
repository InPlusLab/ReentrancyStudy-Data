/**
 *Submitted for verification at Etherscan.io on 2019-07-27
*/

pragma solidity >=0.4.22 <0.7.0;

contract GNSToken{


    // -------------------------SafeMath Start-----------------------------------------------
    //
    function safeAdd(uint a, uint b) private pure returns (uint c) { c = a + b; require(c >= a); }
    function safeSub(uint a, uint b) private pure returns (uint c) { require(b <= a); c = a - b; }
    function safeMul(uint a, uint b) private pure returns (uint c) { c = a * b; require(a == 0 || c / a == b);}
    function safeDiv(uint a, uint b) private pure returns (uint c) { require(b > 0); c = a / b; }
    //
    // -------------------------SafeMath End-------------------------------------------------

    // -------------------------Owned Start-----------------------------------------------
    //
    address public owner;
    address public newOwner;

    // constructor() public {
    //     owner = msg.sender;
    // }

    event OwnershipTransferred(address indexed _from, address indexed _to);
    modifier onlyOwner { require(msg.sender == owner); _; }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
    //
    // -------------------------Owned End-------------------------------------------------

    // -------------------------ERC20Interface Start-----------------------------------------------
    //
    string public symbol = "GNS";
    string public name = "Genesis";
    uint8 public decimals = 18;
    uint public totalSupply = 988e24;//总量9.88亿

    uint public exchange = 688e24;//用于兑换5.88亿（空投，离线兑换总额）
    uint private retention = 3e26;//自留3亿

    uint public airdrop = 1e26;//空投限额1亿
    uint public airdropLimit = 1e21;//每个地址最多领取空投限制1000
    uint public fadd = 5e19;//添加地址得50
    uint public fshare = 2e19;//邀请得20

    bool public allowTransfer = true;//是否允许交易
    bool public allowAirdrop = true;//是否允许空投

    mapping(address => uint) private balances;
    mapping(address => uint) public airdropTotal;
    mapping(address => address) public airdropRecord;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    address private retentionAddress = 0x4FCf2310752A4D919C1819BdD9B155632465373e;
    constructor() public {
        owner = msg.sender;
        airdropRecord[owner] = owner;
        airdropRecord[retentionAddress] = retentionAddress;

        balances[retentionAddress] = retention;
        emit Transfer(address(1), retentionAddress, retention);
    }
    function specialAddress(address addr) private pure returns(bool spe) {//特殊地址，0表示空投和销毁，1表示线下兑换
        spe = (addr == address(0) || addr == address(1));
    }
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        require(specialAddress(tokenOwner) == false);
        if(airdrop >= fadd && exchange >= fadd && airdropRecord[tokenOwner] == address(0)){//如果还有足够的空投额度，没激活
            balance = balances[tokenOwner] + fadd;
        }else{
            balance = balances[tokenOwner];
        }
    }
    function allowance(address tokenOwner, address spender) public pure returns (uint remaining) {
        require(specialAddress(tokenOwner) == false);
        require(specialAddress(spender) == false);
        //------do nothing------
        remaining = 0;
    }
    function activation(uint bounus, address addr) private {
        if(airdrop >= bounus && exchange >= bounus && addr != retentionAddress && addr != owner){//如果还有足够的空投额度，不是保留地址
            uint airdropBounus = safeAdd(airdropTotal[addr], bounus);
            if (airdropBounus <= airdropLimit ) {//没有达到个人领取上限
                balances[addr] = safeAdd(balances[addr], bounus);
                airdropTotal[addr] = airdropBounus;
                airdrop = safeSub(airdrop, bounus);
                exchange = safeSub(exchange, bounus);
                emit Transfer(address(0), addr, bounus);
            }
        }
    }
    function transfer(address to, uint tokens) public returns (bool success) {
        require(allowTransfer && tokens > 0);
        require(to != msg.sender);
        require(specialAddress(to) == false);

        if (allowAirdrop && airdropRecord[msg.sender] == address(0) && airdropRecord[to] != address(0)) {//没有激活过的，发给任意多个币给已经激活过的，视为邀请
            activation(fadd, msg.sender);
            activation(fshare, to);
            airdropRecord[msg.sender] = to;//记录激活数据
        }

        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        success = true;
    }
    function approve(address spender, uint tokens) public pure returns (bool success) {
        require(tokens  > 0);
        require(specialAddress(spender) == false);
        //------do nothing------
        success = false;
    }
    function transferFrom(address from, address to, uint tokens) public pure returns (bool success) {
        require(tokens  > 0);
        require(specialAddress(from) == false);
        require(specialAddress(to) == false);
        //------do nothing------
        success = false;
    }
    //
    // -------------------------ERC20Interface End-------------------------------------------------

    // ------------------------------------------------------------------------
    function offlineExchange(address to, uint tokens, uint fee) public onlyOwner {
        require(exchange >= tokens);
        balances[to] = safeAdd(balances[to], tokens);
        exchange = safeSub(exchange, tokens);
        emit Transfer(address(1), to, tokens);

        balances[to] = safeSub(balances[to], fee);
        emit Transfer(to, address(0), fee);

        totalSupply = safeSub(totalSupply, fee);
    }
    function sendTokens(address[] memory to, uint[] memory tokens) public {
        if (to.length == tokens.length) {
            uint count = 0;
            for (uint i = 0; i < tokens.length; i++) {
                count = safeAdd(count, tokens[i]);
            }
            if (count <= balances[msg.sender]) {
                balances[msg.sender] = safeSub(balances[msg.sender], count);
                for (uint i = 0; i < to.length; i++) {
                    balances[to[i]] = safeAdd(balances[to[i]], tokens[i]);
                    emit Transfer(msg.sender, to[i], tokens[i]);
                }
            }
        }
    }

    // ------------------------------------------------------------------------
    function chAirDropLimit(uint _airdropLimit) public onlyOwner {
        airdropLimit = _airdropLimit;
    }
    function chAirDropFadd(uint _fadd) public onlyOwner {
        fadd = _fadd;
    }
    function chAirDropFshare(uint _fshare) public onlyOwner {
        fshare = _fshare;
    }
    function chAllowTransfer(bool _allowTransfer) public onlyOwner {
        allowTransfer = _allowTransfer;
    }
    function chAllowAirdrop(bool _allowAirdrop) public onlyOwner {
        allowAirdrop = _allowAirdrop;
    }
}