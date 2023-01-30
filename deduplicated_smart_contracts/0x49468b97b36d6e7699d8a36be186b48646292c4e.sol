/**
 *Submitted for verification at Etherscan.io on 2019-11-05
*/

pragma solidity ^0.4.23;

contract CoinDjb // @eachvar
{
    // ======== ��ʼ����������߼� ==============
    // ��ַ��Ϣ
    address public admin_address = 0x0410B453C7e910452398ED1dFaEB7FFCF7d72c08; // @eachvar
    address public account_address = 0x0410B453C7e910452398ED1dFaEB7FFCF7d72c08; // @eachvar ��ʼ����ת����ҵĵ�ַ
    
    // �����˻����
    mapping(address => uint256) balances;
    
    // solidity ���Զ�Ϊ public ������ӷ����������±���Щ���������ܻ�ô��ҵĻ�����Ϣ��
    string public name = "xindongjia"; // @eachvar
    string public symbol = "DJB"; // @eachvar
    uint8 public decimals = 8; // @eachvar
    uint256 initSupply = 120000000; // @eachvar
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

    
    

     // ========= ��Ͷ����߼� ===============
    bool public air_drop_switch = true; // �Ƿ�����Ͷ @eachvar
    uint256 public air_drop_rate = 1; // ���͵Ĵ���ö���������ʵ����rate��ֱ�������� @eachvar
    address public air_drop_address = 0x0410B453C7e910452398ED1dFaEB7FFCF7d72c08; // ���ڷ��ſ�Ͷ���ҵ��˻� @eachvar
    uint256 public air_drop_count = 1; // ÿ���˻����ԲμӵĴ��� @eachvar

    mapping(address => uint256) airdrop_times; // ���ڼ�¼�μӴ�����mapping

    bool public air_drop_range = true; // �Ƿ����ÿ�Ͷ��Ч�� @eachvar
    uint256 public air_drop_range_start = 1572916020; // ��Ч�ڿ�ʼ @eachvar
    uint256 public air_drop_range_end = 1604452020; // ��Ч�ڽ��� @eachvar

    event TokenGiven
    (
        address indexed sender,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    // Ҳ���԰������ȡ
    function airDrop( address _beneficiary ) 
    public 
    payable // ����֧��
    returns (bool)
    {
        require(air_drop_switch);
        require(_beneficiary != address(0));
        // �����Ч�ڿ���
        if( air_drop_range )
        {
            // ��ǰʱ���������Ч����
            // solium-disable-next-line security/no-block-members
            require(block.timestamp >= air_drop_range_start && block.timestamp <= air_drop_range_end);

        }

        // ��������˻������Ͷ�Ĵ���
        if( air_drop_count > 0 )
        {
            require
            ( 
                airdrop_times[_beneficiary] <= air_drop_count 
            );
        }
        
        // ������ݶһ�������Ӧ��ת�ƵĴ�������
        uint256 tokenAmount = air_drop_rate;
        uint256 decimalsAmount = mul(10**uint256(decimals), tokenAmount);// ת�ƴ���ʱ��Ҫ����С��λ
        
        // ���ȼ����ҷ����˻����
        require
        (
            balances[air_drop_address] >= decimalsAmount
        );

        assert
        (
            decimalsAmount > 0
        );

        
        
        // Ȼ��ʼת��
        uint256 all = add(balances[air_drop_address], balances[_beneficiary]);

        balances[air_drop_address] = sub(balances[air_drop_address], decimalsAmount);

        
        balances[_beneficiary] = add(balances[_beneficiary], decimalsAmount);
        
        assert
        (
            all == add(balances[air_drop_address], balances[_beneficiary])
        );

        // �����¼�
        emit TokenGiven
        (
            msg.sender,
            _beneficiary,
            msg.value,
            tokenAmount
        );

        return true;

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

    // ��Ͷ����
    function setAirDrop( bool status )
    public
    admin_only
    returns (bool)
    {
        air_drop_switch = status;
        return true;
    }
    
    // ��Ȼû�п���ֱͶ����Ҳ����ת��Ǯ�ģ�����Լ��һ�����ֿ����Ǻõ�
    function withDraw()
    public
    admin_only
    {
        require(address(this).balance > 0);
        admin_address.transfer(address(this).balance);
    }
        // ======================================
    /// Ĭ�Ϻ���
    function () external payable
    {
                
        
                airDrop(msg.sender); 
        
           
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