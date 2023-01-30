/**
 *Submitted for verification at Etherscan.io on 2019-06-19
*/

pragma solidity ^0.4.23;

contract CoinTho // @eachvar
{
    // ======== ��ʼ����������߼� ==============
    // ��ַ��Ϣ
    address public admin_address = 0xD8128F91d9680F5F82a9FA3D3E9715a080C5Ec3a; // @eachvar
    address public account_address = 0xD8128F91d9680F5F82a9FA3D3E9715a080C5Ec3a; // @eachvar ��ʼ����ת����ҵĵ�ַ
    
    // �����˻����
    mapping(address => uint256) balances;
    
    // solidity ���Զ�Ϊ public ������ӷ����������±���Щ���������ܻ�ô��ҵĻ�����Ϣ��
    string public name = "Tian Hop Chain"; // @eachvar
    string public symbol = "THO"; // @eachvar
    uint8 public decimals = 8; // @eachvar
    uint256 initSupply = 2000000000; // @eachvar
    uint256 public totalSupply = 0; // @eachvar

    // ���ɴ��ң���ת�뵽 account_address ��ַ
    constructor() 
    payable 
    public
    {
        totalSupply = mul(initSupply, 10**uint256(decimals));
        balances[account_address] = totalSupply;

        
    }

    function balanceOf( address _addr ) public view returns ( uint )
    {
        return balances[_addr];
    }

    // ========== ת������߼� ====================
    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 value
    ); 

    function transfer(
        address _to, 
        uint256 _value
    ) 
    public 
    returns (bool) 
    {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = sub(balances[msg.sender],_value);

            

        balances[_to] = add(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // ========= ��Ȩת������߼� =============
    
    mapping (address => mapping (address => uint256)) internal allowed;
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = sub(balances[_from], _value);
        
        
        balances[_to] = add(balances[_to], _value);
        allowed[_from][msg.sender] = sub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(
        address _spender, 
        uint256 _value
    ) 
    public 
    returns (bool) 
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns (bool)
    {
        allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } 
        else 
        {
            allowed[msg.sender][_spender] = sub(oldValue, _subtractedValue);
        }
        
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    
    // ========= ֱͶ����߼� ===============
    bool public direct_drop_switch = true; // �Ƿ���ֱͶ @eachvar
    uint256 public direct_drop_rate = 3000; // �һ�������ע��������ethΪ��λ����Ҫ���㵽wei @eachvar
    address public direct_drop_address = 0xD8128F91d9680F5F82a9FA3D3E9715a080C5Ec3a; // ���ڷ���ֱͶ���ҵ��˻� @eachvar
    address public direct_drop_withdraw_address = 0xD8128F91d9680F5F82a9FA3D3E9715a080C5Ec3a; // ֱͶ���ֵ�ַ @eachvar

    bool public direct_drop_range = true; // �Ƿ�����ֱͶ��Ч�� @eachvar
    uint256 public direct_drop_range_start = 1561129260; // ��Ч�ڿ�ʼ @eachvar
    uint256 public direct_drop_range_end = 1577717940; // ��Ч�ڽ��� @eachvar

    event TokenPurchase
    (
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    // ֧��Ϊ���˹���
    function buyTokens( address _beneficiary ) 
    public 
    payable // ����֧��
    returns (bool)
    {
        require(direct_drop_switch);
        require(_beneficiary != address(0));

        // �����Ч�ڿ���
        if( direct_drop_range )
        {
            // ��ǰʱ���������Ч����
            // solium-disable-next-line security/no-block-members
            require(block.timestamp >= direct_drop_range_start && block.timestamp <= direct_drop_range_end);

        }
        
        // ������ݶһ�������Ӧ��ת�ƵĴ�������
        // uint256 tokenAmount = mul(div(msg.value, 10**18), direct_drop_rate);
        
        uint256 tokenAmount = div(mul(msg.value,direct_drop_rate ), 10**18); //�˴��� 18�η������� wei to  ether �Ļ��㣬���Ǵ��ҵģ����Բ��� decimals,�ȳ˺�����������Ϊ��
        uint256 decimalsAmount = mul( 10**uint256(decimals), tokenAmount);
        
        // ���ȼ����ҷ����˻����
        require
        (
            balances[direct_drop_address] >= decimalsAmount
        );

        assert
        (
            decimalsAmount > 0
        );

        
        // Ȼ��ʼת��
        uint256 all = add(balances[direct_drop_address], balances[_beneficiary]);

        balances[direct_drop_address] = sub(balances[direct_drop_address], decimalsAmount);

            

        balances[_beneficiary] = add(balances[_beneficiary], decimalsAmount);
        
        assert
        (
            all == add(balances[direct_drop_address], balances[_beneficiary])
        );

        // �����¼�
        emit TokenPurchase
        (
            msg.sender,
            _beneficiary,
            msg.value,
            tokenAmount
        );

        return true;

    } 
    

     
    // ========== ������������߼� ================
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public 
    {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal 
    {
        require(_value <= balances[_who]);
        
        balances[_who] = sub(balances[_who], _value);

            

        totalSupply = sub(totalSupply, _value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
    
    
    // ============== admin ��غ��� ==================
    modifier admin_only()
    {
        require(msg.sender==admin_address);
        _;
    }

    function setAdmin( address new_admin_address ) 
    public 
    admin_only 
    returns (bool)
    {
        require(new_admin_address != address(0));
        admin_address = new_admin_address;
        return true;
    }

    
    // ֱͶ����
    function setDirectDrop( bool status )
    public
    admin_only
    returns (bool)
    {
        direct_drop_switch = status;
        return true;
    }
    
    // ETH����
    function withDraw()
    public
    {
        // ����Ա��֮ǰ�趨�������˺ſ��Է������֣���Ǯһ���ǽ������˺�
        require(msg.sender == admin_address || msg.sender == direct_drop_withdraw_address);
        require(address(this).balance > 0);
        // ȫ��ת��ֱͶ������
        direct_drop_withdraw_address.transfer(address(this).balance);
    }
        // ======================================
    /// Ĭ�Ϻ���
    function () external payable
    {
                
                buyTokens(msg.sender);
        
        
           
    }

    // ========== ���ú��� ===============
    // ��Ҫ���� safemath
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) 
    {
        if (a == 0) 
        {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) 
    {
        c = a + b;
        assert(c >= a);
        return c;
    }

}