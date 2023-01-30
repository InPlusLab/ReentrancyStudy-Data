pragma solidity ^0.4.19;      // ָ��Compiler�汾

contract ERC20_token {   // ʹ�� is �^�� ERC20_interface
    uint256 public totalSupply;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value, string _text); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    uint256 constant private MAX_UINT256 = 2**256 - 1; // ���ⳬ�^uint256�����ܵ�ֵ���a��overflow
    mapping (address => uint256) public balances;   // ֮���ʹ�� balances[��ַ] ��ԃ�ض���ַ���N�~
    mapping (address => mapping (address => uint256)) public allowed;  // ���� allowed[��ַ][��ַ]����ԃ�ض���ַ���Խo��һ����ַ���D�����~

    string public name;             // �ͺϼsȡ���Q
    uint8  public decimals = 18;    // С���c���ٷ����h��18
    string public symbol;           // e.g. ^_^
    address owner;
    uint256 public buyPrice;   // һ��λEther���ԓQ����token
    uint private weiToEther = 10 ** 18; // �ц�λ��wei�D��Ether

    // �����ӣ�һ�_ʼ�������У���Ҫ�ṩ�������r�����Q�����I
    constructor (
        uint256 _initialSupply,
        uint256 _buyPrice,
        string _tokenName,
        string _tokenSymbol
    ) public {
        totalSupply = _initialSupply * 10 ** uint256(decimals); // token����
        balances[msg.sender] = totalSupply;                    // ������Token��ȫ������o�ϼs������      

        name = _tokenName;                                   // token���Q
        symbol = _tokenSymbol;                               // token ���I
        owner = msg.sender;                                  // �ϼs������
        buyPrice = _buyPrice;                                // ÿ��λ ether ֮�r��
    }
    
    // �޶�ֻ�кϼs�����˲��܈����ض�function
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // ��ԃ�N�~
    function balanceOf(address _owner) public view returns (uint256 balance) {
      return balances[_owner];
    }

    // �ĺϼs�����˵�ַ�D��
    function transfer(address _to, uint256 _value, string _text) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value, _text);
        return true;
    }

    // ��ĳһ�˵�ַ�D�o��һ�˵�ַ����Ҫ���D�����~�б�ͬ�⣬�������С��(msg.sender)�ðְֵĸ���(_from)�D���o�e��(_to)
    function transferFrom(address _from, address _to, uint256 _value, string _text) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value, _text);
        return true;
    }

    // �o���ض���̖�D�����~  ���С���İְ�(msg.sender)�oС��(_spender)һ�����ÿ��������~�Ȟ�value
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // ��ԃ�ض���̖�D�o��һ��̖֮�D�����~
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }   

    // �O��tokenُ�I�r��ֻ�кϼs�����߿����O��
    function setPrice(uint _price) public onlyOwner {
        buyPrice = _price;
    }

    // ُ�Itoken
    function buy() public payable {
        uint amount;
        amount = msg.value * buyPrice * 10 ** uint256(decimals) / weiToEther;    // ُ�I����token
        require(balances[owner] >= amount);              // �z��߀�Л]�����token�����u
        balances[msg.sender] += amount;                  // ����ُ�I��token   
        balances[owner] -= amount;                        // �p�ٓ�����token
        emit Transfer(msg.sender, owner, amount, 'Buy token');               // �a��token�D��log
    }

    // �ĺϼs�D��Ether�������ߎ���
    function withdraw(uint amount) public onlyOwner {
        owner.transfer(amount * weiToEther);
    }
}