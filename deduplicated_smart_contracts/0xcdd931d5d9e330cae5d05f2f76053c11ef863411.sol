/**
 *Submitted for verification at Etherscan.io on 2020-07-06
*/

pragma solidity ^0.4.20;

// ����ERC-20��׼�ӿ�
contract AXMInterface {
    // ��������
    string public name;
    // ���ҷ��Ż���˵��д
    string public symbol;
    // ����С����λ�������ҵ���С��λ
    uint8 public decimals;
    // ���ҵķ�������
    uint public totalSupply;

    // ʵ�ִ��ҽ��ף����ڸ�ĳ����ַת�ƴ���
    function transfer(address to, uint tokens) public returns (bool success);
    // ʵ�ִ����û�֮��Ľ��ף���һ����ַת�ƴ��ҵ���һ����ַ
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    // ����spender��δ�����˻�ȡ���������ȡtokens������Ҫ����ĳЩ��������Ȩί�������û�������˻��ϻ��Ѵ���
    function approve(address spender, uint tokens) public returns (bool success);
    // ��ѯspender�����tokenOwner�ϻ��ѵĴ�������
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    // ���ҽ���ʱ�������¼���������transfer����ʱ����
    event Transfer(address indexed from, address indexed to, uint tokens);
    // ���������û�������˻��ϻ��Ѵ���ʱ�������¼���������approve����ʱ����
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ʵ��ERC-20��׼�ӿ�
contract AXMImpl is AXMInterface {
    // �洢ÿ����ַ������Ϊ��public�����Ի��Զ�����balanceOf������
    mapping (address => uint256) public balanceOf;
    // �洢ÿ����ַ�ɲ����ĵ�ַ����ɲ����Ľ��
    mapping (address => mapping (address => uint256)) internal allowed;

    // ��ʼ������
    constructor() public {
        name = "AXM���Ĵ��ƹ���";
        symbol = "AXM"; 
        decimals =3;
        totalSupply = 100000000 * 10 ** uint256(decimals);
        // ��ʼ���ô��ҵ��˻���ӵ�����еĴ���
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        // ��������ߵ�ַ�Ƿ�Ϸ�
        require(to != address(0));
        // ���鷢�����˻�����Ƿ��㹻
        require(balanceOf[msg.sender] >= tokens);
        // �����Ƿ�ᷢ�����
        require(balanceOf[to] + tokens >= balanceOf[to]);

        // �۳��������˻����
        balanceOf[msg.sender] -= tokens;
        // ���ӽ������˻����
        balanceOf[to] += tokens;

        // ������Ӧ���¼�
        emit Transfer(msg.sender, to, tokens);
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        // �����ַ�Ƿ�Ϸ�
        require(to != address(0) && from != address(0));
        // ���鷢�����˻�����Ƿ��㹻
        require(balanceOf[from] >= tokens);
        // ��������Ľ���Ƿ��Ǳ������
        require(allowed[from][msg.sender] <= tokens);
        // �����Ƿ�ᷢ�����
        require(balanceOf[to] + tokens >= balanceOf[to]);

        // �۳��������˻����
        balanceOf[from] -= tokens;
        // ���ӽ������˻����
        balanceOf[to] += tokens;

        // ������Ӧ���¼�
        emit Transfer(from, to, tokens);   

        success = true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        // ������Ӧ���¼�
        emit Approval(msg.sender, spender, tokens);

        success = true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
}