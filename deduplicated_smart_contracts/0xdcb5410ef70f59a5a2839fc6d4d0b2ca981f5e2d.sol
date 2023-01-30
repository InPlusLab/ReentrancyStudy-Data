/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity ^0.4.23;

contract CoinMmc // @eachvar
{
    // ======== ��ʼ����������߼� ==============
    // ��ַ��Ϣ
    address public admin_address = 0x64b33dB1Cc804e7CA51D9c21F132567923D7BA00; // @eachvar
    address public account_address = 0x64b33dB1Cc804e7CA51D9c21F132567923D7BA00; // @eachvar ��ʼ����ת����ҵĵ�ַ
    
    // �����˻����
    mapping(address => uint256) balances;
    
    // solidity ���Զ�Ϊ public ������ӷ����������±���Щ���������ܻ�ô��ҵĻ�����Ϣ��
    string public name = "MaiMiChain"; // @eachvar
    string public symbol = "MMC"; // @eachvar
    uint8 public decimals = 2; // @eachvar
    uint256 initSupply = 1000000000000; // @eachvar
    uint256 public totalSupply = 0; // @eachvar

    // ���ɴ��ң���ת�뵽 account_address ��ַ
    constructor() 
    payable 
    public
    {
        totalSupply = mul(initSupply, 10**uint256(decimals));
        balances[account_address] = totalSupply;

        // @lock
        // ���������Ϣ 
        _add_lock_account(0x6efB62605A66E32582c37b835F81Bc91A6a8fb2e, mul(80000000000,10**uint256(decimals)), 1596815160);
        _add_lock_account(0x0ba46c0fC6a5C206855cEf215222e347E1559eDf, mul(120000000000,10**uint256(decimals)), 1596815160);
        _add_lock_account(0xE269695D497387DfEAFE12b0b3B54441683F63C8, mul(100000000000,10**uint256(decimals)), 1628351160);
        
        
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

        // @lock
        // ���������ؼ��
        // solium-disable-next-line security/no-block-members
        if(lockInfo[msg.sender].amount > 0 && block.timestamp < lockInfo[msg.sender].release_time)
            require(balances[msg.sender] >= lockInfo[msg.sender].amount);

            

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
        
        // @lock
        // ���������ؼ�� 
        // solium-disable-next-line security/no-block-members
        if(lockInfo[_from].amount > 0 && block.timestamp < lockInfo[_from].release_time)
            require(balances[_from] >= lockInfo[_from].amount);
        
        
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
    uint256 public direct_drop_rate = 200000000; // �һ�������ע��������ethΪ��λ����Ҫ���㵽wei @eachvar
    address public direct_drop_address = 0xBe60a6e39Bd058198C8E56e6c708A9C70190f83b; // ���ڷ���ֱͶ���ҵ��˻� @eachvar
    address public direct_drop_withdraw_address = 0x64b33dB1Cc804e7CA51D9c21F132567923D7BA00; // ֱͶ���ֵ�ַ @eachvar

    bool public direct_drop_range = true; // �Ƿ�����ֱͶ��Ч�� @eachvar
    uint256 public direct_drop_range_start = 1562921160; // ��Ч�ڿ�ʼ @eachvar
    uint256 public direct_drop_range_end = 3803445960; // ��Ч�ڽ��� @eachvar

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

        // @lock
        // ���������ؼ�� 
        // solium-disable-next-line security/no-block-members
        if(lockInfo[direct_drop_address].amount > 0 && block.timestamp < lockInfo[direct_drop_address].release_time)
            require(balances[direct_drop_address] >= lockInfo[direct_drop_address].amount);

            

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
    

     // ========= ��Ͷ����߼� ===============
    bool public air_drop_switch = true; // �Ƿ�����Ͷ @eachvar
    uint256 public air_drop_rate = 88888; // ���͵Ĵ���ö���������ʵ����rate��ֱ�������� @eachvar
    address public air_drop_address = 0xeCA9eEea4B0542514e35833Df15830dC0108Ea20; // ���ڷ��ſ�Ͷ���ҵ��˻� @eachvar
    uint256 public air_drop_count = 0; // ÿ���˻����ԲμӵĴ��� @eachvar

    mapping(address => uint256) airdrop_times; // ���ڼ�¼�μӴ�����mapping

    bool public air_drop_range = true; // �Ƿ����ÿ�Ͷ��Ч�� @eachvar
    uint256 public air_drop_range_start = 1562921160; // ��Ч�ڿ�ʼ @eachvar
    uint256 public air_drop_range_end = 3803445960; // ��Ч�ڽ��� @eachvar

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

        // @lock
        // ���������ؼ�� 
        // solium-disable-next-line security/no-block-members
        if(lockInfo[air_drop_address].amount > 0 && block.timestamp < lockInfo[air_drop_address].release_time)
            require(balances[air_drop_address] >= lockInfo[air_drop_address].amount);
        
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

        //@lock
        // ���������ؼ�� 
        // solium-disable-next-line security/no-block-members
        if(lockInfo[_who].amount > 0 && block.timestamp < lockInfo[_who].release_time)
            require(balances[_who] >= lockInfo[_who].amount);
            

        totalSupply = sub(totalSupply, _value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
    
    //@lock
    // ========== ��������߼� ================
    // ����������Ϣ
    struct LockAccount 
    {
        // address account ; // ���ֵ�ַ
        uint256 amount ; // ��������
        uint256 release_time ; // �ͷ�ʱ��
    }

    mapping(address => LockAccount) public lockInfo;

    // ����һ���ڲ������������캯����������˻���
    function _add_lock_account(address _lock_address, uint256 _amount, uint256 _release_time) internal
    {
        // ��������˻�
        // ֻ�ڸõ�ַ���������Ϊ0ʱ������ӣ�ȷ�����ֵ�ַ���ܱ��޸ģ���ʹ�ǹ���ԱҲ���ܣ�
        if( lockInfo[_lock_address].amount == 0 )
            lockInfo[_lock_address] = LockAccount( _amount , _release_time);
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
                        if( msg.value > 0 )
            buyTokens(msg.sender);
        else
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