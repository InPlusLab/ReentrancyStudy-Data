pragma solidity ^0.4.21;


contract Platform
{
    address public platform = 0x709a0A8deB88A2d19DAB2492F669ef26Fd176f6C;

    modifier onlyPlatform() {
        require(msg.sender == platform);
        _;
    }

    function isPlatform() public view returns (bool) {
        return platform == msg.sender;
    }
}


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract BeneficiaryInterface
{
    function getAvailableWithdrawInvestmentsForBeneficiary() public view returns (uint);
    function withdrawInvestmentsBeneficiary(address withdraw_address) public returns (bool);
}


//���ߧ�֧��֧ۧ� �էݧ� ICO �ܧ�ߧ��ѧܧ���, ����ҧ� ��� �ާ�ԧݧ� �ԧ�ӧ��ڧ�� CNRToken-��
//�� ���� ���� �֧ާ� ��֧�֧ӧ֧ݧ� �ҧѧҧܧ�
contract CNRAddBalanceInterface
{
    function addTokenBalance(address, uint) public;
}


//���ߧ�֧��֧ۧ� �էݧ� ��ѧҧ�ڧܧ�, ����ҧ� ��ߧ� �ާ�ԧݧ� �է�ҧѧӧݧ��� ���ܧ֧ߧ�
contract CNRAddTokenInterface
{
    function addTokenAddress(address) public;
}

//TODO: �ާ�ا֧� ��է֧ݧѧ�� �ܧݧѧ�� TokensCollection, �ܧ�է� �ӧ�ߧ֧��� �ӧ�� ���ߧܧ�ڧ�ߧѧݧ�ߧ���� �ڧ�  tokens_map, tokens_arr �ڧ��
contract CNRToken is ERC20, CNRAddBalanceInterface, CNRAddTokenInterface, Platform
{
    using SafeMath for uint256;


    //����ܧ֧�  ERC20
    string public constant name = "ICO Constructor token";
    string public constant symbol = "CNR";
    uint256 public constant decimals = 18;


    //-------------------------ERC20 interface----------------------------------
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => uint256) balances;
    ////////////////////////////ERC20 interface/////////////////////////////////

    //���է�֧� �ԧ�ѧߧ� ��ѧҧ�ڧܧ�
    address public grand_factory = address(0);

    //���ѧ�� �� �ާѧ��ڧ� �է�ҧѧӧݧ֧ߧߧ� ���ܧ֧ߧ��. ����ݧ֧ӧ�� ��ݧ֧ާ֧ߧ�  �٧ѧ�֧٧֧�ӧڧ��ӧѧ� �էݧ�
    //���ڧ��. �����ѧݧ�ߧ�� �էݧ� ���ܧ֧ߧ��
    mapping(address => uint256) public  tokens_map;
    TokenInfo[] public                  tokens_arr;

    //���ѧ�� �� �٧ѧҧ�ѧߧߧ�ާ� ����ߧ����ާ� (���ڧ���, ���ܧ֧ߧѧާ�). (�ѧէ�֧� �ܧ��֧ݧ�ܧ� �ܧݧڧ֧ߧ�� => (�ڧߧէ֧ܧ� ���ܧ֧ߧ� => ��ܧ�ݧ�ܧ� ��ا� �٧ѧҧ�ѧ�))
    //���� �ڧߧէ֧ܧ�� 0 - �ӧ�֧ԧէ� ���ڧ�.
    mapping(address => mapping(uint => uint)) withdrawns;

    function CNRToken() public
    {
        totalSupply = 10*1000*1000*(10**decimals); // 10 mln
        balances[msg.sender] = totalSupply;

        //���� �ߧ�ݧ֧ӧ�� �ڧߧէ֧ܧ�� �ߧѧ��էڧ��� ���ڧ�
        tokens_arr.push(
            TokenInfo(
                address(0),
                0));
    }


    //����ߧܧ�ڧ� ���ݧ��֧ߧڧ� �ѧէ�֧��� �ӧ�֧� �է�ҧѧӧݧ֧ߧߧ�� ���ܧ֧ߧ��
    function getRegisteredTokens()
    public view
    returns (address[])
    {
        // ��ڧ��ѧ�ڧ�, �ܧ�ԧէ� �ߧ� �է�ҧѧӧݧ֧ߧ� ���ܧ֧ߧ�. <= ����ҧ� ��ҧ�ѧ�� ���֧� mythril,
        // �ܧ������ �ߧ� ���ߧڧާѧ֧� ���� �� �ܧ�ߧ����ܧ���� �٧ѧҧڧ� ��֧�ӧ�� ��ݧ֧ާ֧ߧ�
        if (tokens_arr.length <= 1)
            return;

        address[] memory token_addresses = new address[](tokens_arr.length-1);
        for (uint i = 1; i < tokens_arr.length; i++)
        {
            token_addresses[i-1] = tokens_arr[i].contract_address;
        }

        return token_addresses;
    }

    //����ߧܧڧ�� ���ݧ��֧ߧڧ� �էѧߧߧ�� �� �ӧ�֧� �է�����ߧ�� �է���էѧ� �� ether ��� �ӧ�֧�
    //�٧ѧ�֧ԧڧ���ڧ��ӧѧߧߧ�� �ܧ�ߧ��ѧܧ��� ���ܧ֧ߧ��. �����ҧ� �ӧ����ݧ�٧�ӧѧ���� ���ڧާ�
    //�է���էѧާ� �ߧ�اߧ� �էݧ� �ܧѧاا�ԧ� ���ܧ֧ߧ� �ӧ�٧ӧѧ�� takeICOInvestmentsEtherCommission
    function getAvailableEtherCommissions()
    public view
    returns(
        address[],
        uint[]
    )
    {
        // ��ڧ��ѧ�ڧ�, �ܧ�ԧէ� �ߧ� �է�ҧѧӧݧ֧ߧ� ���ܧ֧ߧ�. <= ����ҧ� ��ҧ�ѧ�� ���֧� mythril,
        // �ܧ������ �ߧ� ���ߧڧާѧ֧� ���� �� �ܧ�ߧ����ܧ���� �٧ѧҧڧ� ��֧�ӧ�� ��ݧ֧ާ֧ߧ�
        if (tokens_arr.length <= 1)
            return;

        address[] memory token_addresses = new address[](tokens_arr.length-1);
        uint[] memory available_withdraws = new uint[](tokens_arr.length-1);
        //���է֧�� �է�ݧاߧ� �ҧ��� ��� 1-�ԧ�, �����ާ� ���� �ߧ� 0-��� - ���ڧ�
        for (uint i = 1; i < tokens_arr.length; i++)
        {
            token_addresses[i-1] = tokens_arr[i].contract_address;
            available_withdraws[i-1] =
                BeneficiaryInterface(tokens_arr[i].contract_address).getAvailableWithdrawInvestmentsForBeneficiary();
        }

        return (token_addresses, available_withdraws);
    }


    //����ߧܧ�ڧ�, �ܧ������ �ާ�ا֧� �է֧�ԧߧ��� �ܧ�� ��ԧ�էߧ�, ����ҧ� �ߧ� �էѧߧߧ��  �ܧ�ߧ��ѧܧ� �ҧ�ݧ� ��֧�֧ӧ֧է֧�
    //�ܧ�ާڧ��ڧ� �� �ڧߧӧ֧��ڧ�ڧ� �� ���ڧ��
    function takeICOInvestmentsEtherCommission(address ico_token_address)
    public
    {
        //�����ӧ֧��֧� ���� ��ѧߧ֧� �ҧ��! �է�ҧѧӧݧ֧� ��ѧܧ�� ���ܧ֧�
        require(tokens_map[ico_token_address] != 0);

        //���٧ߧѧ֧� ��ܧ�ݧ�ܧ� �ާ� �ާ�ا֧� �ӧ�ӧ֧��� �ҧѧҧݧ�
        uint available_investments_commission =
            BeneficiaryInterface(ico_token_address).getAvailableWithdrawInvestmentsForBeneficiary();

        //���ѧ��ާڧߧѧ֧� ���� �ҧѧҧܧ� �٧ѧҧ�ѧݧ�
        //�٧ѧ��ާڧߧѧ֧� �է� ��֧�֧ӧ�է�, ��ѧ� �ܧѧ� ������ �է֧�ԧѧ֧� external contract method
        tokens_arr[0].ever_added = tokens_arr[0].ever_added.add(available_investments_commission);

        //���֧�֧ӧ�էڧ� �ҧѧҧݧ� �ߧ� �ѧէ�֧� ����ԧ� �ܧ�ߧ��ѧܧ��
        BeneficiaryInterface(ico_token_address).withdrawInvestmentsBeneficiary(
            address(this));
    }


    //����֧�ڧѧݧ�ߧ� ��ѧ٧�֧�ѧ֧� ���ݧ��֧ߧڧ� �ҧѧҧݧ�
    function()
    public payable
    {

    }


    //���֧��� ����ѧߧ�ӧܧ� �ѧէ�֧�� grandFactory, �ܧ������ �ҧ�է֧� �ڧ���ݧ�٧�ӧѧ�
    function setGrandFactory(address _grand_factory)
    public
        onlyPlatform
    {
        //�����ӧ֧��֧� ����ҧ� �ѧէ�֧� �ҧ�� ��֧�֧էѧ� �ߧ��ާѧݧ�ߧ��
        require(_grand_factory != address(0));

        grand_factory = _grand_factory;
    }

    // �ҧѧݧѧߧ� ��ѧ���ڧ��ӧѧ֧��� ��� ����ާ�ݧ�:
    // ��ҧ�֧� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ�� �ܧ�ߧ��ѧܧ�� _token_address, �ܧ������ �ӧݧѧէ֧֧� �ܧ�ߧ��ѧܧ� CNR
    // ��ާߧ�اѧ֧� �ߧ� �ܧ�ݧڧ�֧��ӧ� ���ܧ֧ߧ�� CNR �� _owner, �է֧ݧڧ� �ߧ� totalSupply (���ݧ��ѧ֧� �է�ݧ�)
    // �� ���ߧڧާѧ֧� ��ا� �ӧ�ӧ֧է֧ߧߧ�� _owner'��� ���ާާ� ���ܧ֧ߧ��
    //��������ߧ�� �� �ӧ�ӧ�է� �ҧѧݧѧߧ� �� ���ܧ֧ߧѧ� �ߧ֧ܧ�����ԧ� ICO
    function balanceOfToken(address _owner, address _token_address)
    public view
    returns (uint256 balance)
    {
        //�����ӧ֧�ܧ� �ߧѧݧڧ�ڧ� ��ѧܧ�ԧ� ���ܧ֧ߧ�
        require(tokens_map[_token_address] != 0);

        uint idx = tokens_map[_token_address];
        balance =
            tokens_arr[idx].ever_added
            .mul(balances[_owner])
            .div(totalSupply)
            .sub(withdrawns[_owner][idx]);
        }

    // �ӧ�� �ܧѧ� �� �� balanceOfToken, ���ݧ�ܧ� �ڧ���ݧ�٧�֧� 0 ��ݧ֧ާ֧ߧ� �� tokens_arr �� withdrawns[_owner]
    //��������ߧ�� �� �ӧ�ӧ�է� �ҧѧݧѧߧ� �� ���ڧ�ѧ�
    function balanceOfETH(address _owner)
    public view
    returns (uint256 balance)
    {
        balance =
            tokens_arr[0].ever_added
            .mul(balances[_owner])
            .div(totalSupply)
            .sub(withdrawns[_owner][0]);
    }

    //����ߧܧ�ڧ� ��֧�֧ӧ�է� �է�����ߧ�� ���ܧ֧ߧ�� �ߧ֧ܧ�����ԧ� ICO �ߧ� ��ܧѧ٧ѧߧߧ�� �ܧ��֧ݧ֧�
    function withdrawTokens(address _token_address, address _destination_address)
    public
    {
        //�����ӧ֧�ܧ� �ߧѧݧڧ�ڧ� ��ѧܧ�ԧ� ���ܧ֧ߧ�
        require(tokens_map[_token_address] != 0);

        uint token_balance = balanceOfToken(msg.sender, _token_address);
        uint token_idx = tokens_map[_token_address];
        withdrawns[msg.sender][token_idx] = withdrawns[msg.sender][token_idx].add(token_balance);
        ERC20Basic(_token_address).transfer(_destination_address, token_balance);
    }

    //����ߧܧڧ�� �٧ѧҧڧ�ѧߧڧ� �է�����ߧ�ԧ� ���ڧ�� �ߧ� ��ܧѧ٧ѧߧߧ�� �ܧ��֧ݧ֧�
    function withdrawETH(address _destination_address)
    public
    {
        uint value_in_wei = balanceOfETH(msg.sender);
        withdrawns[msg.sender][0] = withdrawns[msg.sender][0].add(value_in_wei);
        _destination_address.transfer(value_in_wei);
    }


    //���ѧߧߧѧ� ���ߧܧ�ڧ� �էݧ�اߧ� �ӧ�٧�ӧѧ���� �ڧ� �ܧ�ߧ��ѧܧ���-���ܧ֧ߧ��, �� ���� �ާ�ާ֧ߧ� �ܧ�ԧէ� �ҧ֧ߧ֧�ڧ�ڧѧ��
    //(�ߧ� �ܧ�ߧ��ѧܧ� �ҧ֧ߧ֧�ڧ�ڧѧ��) ��֧�֧ӧ�է���� ���ܧ֧ߧ�
    function addTokenBalance(address _token_contract, uint amount)
    public
    {
        //�����ӧ֧��֧� ���� ���ߧܧ�ڧ� �ӧ�٧�ӧѧ֧��� �ڧ� ��ѧߧ֧� �է�ҧѧӧݧ֧ߧߧ�ߧ�! �ܧ�ߧ��ѧܧ�� ���ܧ֧ߧ�
        require(tokens_map[msg.sender] != 0);

        //�����ҧѧӧݧ֧ߧڧ� �էѧߧߧ�� ��ҧ� �ӧ�֧� ���ܧ֧ߧѧ�, ��֧�֧ӧ֧է֧ߧߧ�� �ҧ֧ߧ֧�ڧ�ڧѧ��
        tokens_arr[tokens_map[_token_contract]].ever_added = tokens_arr[tokens_map[_token_contract]].ever_added.add(amount);
    }

    //����ߧܧڧ�� �է�ҧѧӧݧ֧ߧڧ� �ߧ�ӧ�ԧ� ���ܧ֧ߧ�. ���ѧߧߧѧ� ���ߧܧ�ڧ� �է�ݧاߧ� �ӧ�٧�ӧѧ����
    //���ݧ�ܧ� GrandFactory ���� ���٧էѧߧڧ� �ߧ�ӧ�ԧ� ICO ���ܧ֧ߧ�
    function addTokenAddress(address ico_token_address)
    public
    {
        //�����ӧ֧��֧� ����ҧ� ���� �ҧ�� �ӧ�٧�� �ڧ� grand_factory
        require(grand_factory == msg.sender);

        //�����ӧ֧��֧� ���� ��ѧߧ֧� �ߧ� �ҧ�� �է�ѧӧݧ֧� ��ѧܧ�� ���ܧ֧�
        require(tokens_map[ico_token_address] == 0);

        tokens_arr.push(
            TokenInfo(
                ico_token_address,
                0));
        tokens_map[ico_token_address] = tokens_arr.length - 1;
    }



    //------------------------------ERC20---------------------------------------

    //���ѧݧѧߧ� �� ���ܧ֧ߧѧ�
    function balanceOf(address _owner)
    public view
    returns (uint256 balance)
    {
        return balances[_owner];
    }


    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        //        uint withdraw_to_transfer = withdrawn[msg.sender] *  _value / balances[msg.sender];

        for (uint i = 0; i < tokens_arr.length; i++)
        {
            //���ܧ�ݧ�ܧ� �٧ѧҧ�ѧߧߧ�� ����ߧ���֧� ��֧�֧ާ֧��ڧ�� �ߧ� �է��ԧ�� �ѧܧܧѧ�ߧ�
            uint withdraw_to_transfer = withdrawns[msg.sender][i].mul(_value).div(balances[msg.sender]);

            //���֧�ӧ�էڧ� �٧ѧҧ�ѧߧߧ�� �է����
            withdrawns[msg.sender][i] = withdrawns[msg.sender][i].sub(withdraw_to_transfer);
            withdrawns[_to][i] = withdrawns[_to][i].add(withdraw_to_transfer);
        }


        //���֧�֧ӧ�էڧ� ���ܧ֧ߧ�
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);


        //���֧ߧ֧�ڧ� ���ҧ��ڧ�
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        for (uint i = 0; i < tokens_arr.length; i++)
        {
            //���ܧ�ݧ�ܧ� �٧ѧҧ�ѧߧߧ�� ����ߧ���֧� ��֧�֧ާ֧��ڧ�� �ߧ� �է��ԧ�� �ѧܧܧѧ�ߧ�
            uint withdraw_to_transfer = withdrawns[_from][i].mul(_value).div(balances[_from]);

            //���֧�ӧ�էڧ� �٧ѧҧ�ѧߧߧ�� �է����
            withdrawns[_from][i] = withdrawns[_from][i].sub(withdraw_to_transfer);
            withdrawns[_to][i] = withdrawns[_to][i].add(withdraw_to_transfer);
        }


        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);


        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    ///////////////////////////////////ERC20////////////////////////////////////

    struct TokenInfo
    {
        //���է�֧� �ܧ�ߧ��ѧܧ�� ���ܧ֧ߧ� (�ާ�ا֧� �ӧ��ݧڧ�� ������?)
        address contract_address;

        //���֧�� �է����, ��֧�֧ӧ֧է֧ߧߧ�� �ߧ� �ѧէ�֧� �էѧߧߧ�ԧ� �ܧ�ߧ��ѧܧ�� �ӧ�٧�ӧ��
        //���ߧܧ�ڧ� addTokenBalance
        uint256 ever_added;
    }
}