pragma solidity ^0.4.24;

/**
 * �������ܺϼs
 *
 * Symbol       : WGGT
 * Name         : Wind Green Gain Token
 * Total supply : 2,160,000,000.000000000000000000
 * Decimals     : 18
 */


/**
 * Safe maths
 */
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }


    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }


    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }


    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


/**
 * ERC ���Ř˜� #20 Interface: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/**
 * һ����ʽ����ȡ�ú�׼�K���к�ʽ (Borrowed from MiniMeToken)
 */
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


/**
 * ���Й�
 */
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);


    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }


    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


/**
 * ERC20 ���ݴ��ţ����x(����)��ȫ������̖(�s��)�����ʶ�(С���c���λ��)���̶�(δ�������~)�İl������
 */
contract WindGreenGainToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    /**
     * Constructor
     */
    constructor() public {
        symbol = "WGGT";
        name = "Wind Green Gain Token";
        decimals = 18;
        _totalSupply = 2160000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


    /**
     * �l�еĹ�������
     */
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    /**
     * �� `tokeOwner` �X����ַȡ�ô����N�~��
     */
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    /**
     * �Ĵ��ų����ߵ��X���D `tokens` �� `to` �X����ַ��
     *  - ���ų����ߵ��X���e���Ҫ�������N�~
     *  - �����~�� 0 �ǿɱ����S��
     */
    function transfer(address to, uint tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens);       // �N�~�򲻉�
        require(balances[to] + tokens >= balances[to]);// ��ֹ��ζ

        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;
    }


    /**
     * ���ų������Á��׼ `spender` �Ĵ��ų����ߵ��X����ַ�� transferFrom(...) ��ʽʹ�� `tokens`��
     *
     * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md �н��h�˲��Ùz��
     * ��׼�p���M����������@��ԓ�� UI �Ќ�����
     */
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    /**
     * �� `from` �X����ַ�D `tokens` �� `to` �X����ַ��
     *
     * ���д˺�ʽ�߱�������Ĵ��ŏ� `from` �X����ַʹ�ô��š�
     */
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    /**
     * ���ش��ų����ߺ�׼ `spender` �X����ַ �ɽ��׵Ĵ��Ŕ�����
     */
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    /**
     * ���ų����߿ɺ�׼ `spender` �Ĵ��ų����ߵ��X����ַ�� transferFrom(...) ��ʽ���� `token`��Ȼ
     * ����� `spender` �� `receiveApproval(...)` �ϼs��ʽ��
     */
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    /**
     * ��ֹ©��(������ ETH)��
     */
    function () public payable {
        //revert();
    }


    /**
     * �����߿��D���κ�����l�͵� ERC20 ���š�
     */
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }


    function deposit() public payable {
        require(balances[msg.sender] >= msg.value);             // �N�~�򲻉�
        require(balances[owner] + msg.value >= balances[owner]);// ��ֹ��ζ

        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }


    function withdraw(uint withdrawAmount) public {
        if(balances[msg.sender] >= withdrawAmount) {
            balances[msg.sender] -= withdrawAmount;
            msg.sender.transfer(withdrawAmount);
        }
    }
}