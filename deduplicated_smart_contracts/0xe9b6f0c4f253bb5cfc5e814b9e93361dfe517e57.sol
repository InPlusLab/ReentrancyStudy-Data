// ��֧ܧ��ѧ� �ӧ֧��ڧ� - 9 ��֧���ӧѧ� �էݧ� ��ѧ٧ӧ֧���ӧѧߧڧ� �� Rinkeby
// �է�ҧѧӧݧ֧ߧ� �ܧ�ާާ֧ߧ�� �� require
// �ڧ���ѧӧݧ֧ߧ� ��-�ڧ� refund
// �ҧݧ�ܧڧ��ӧܧ� ��֧�֧ӧ�է�� ��է֧ݧѧߧ� �ߧ� �ӧ֧�� ��֧�ڧ�� ICO �� Crowdsale
// �է�ҧѧӧݧ֧� �ݧ�� �� refund
// �է�ҧѧӧݧ֧ߧ� ���ߧܧ�ڧ� �ҧݧ�ܧڧ��ӧܧ�\��ѧ٧ҧݧ�ܧڧ��ӧܧ� �ӧߧ֧�ߧڧ� ��֧�֧ӧ�է�� �� ��ѧҧ��֧� ��֧اڧާ� �ܧ�ߧ��ѧܧ��
// �էݧ� �ӧ�٧ާ�اߧ���� ��ѧ��֧�� �էڧӧڧէ֧ߧէ��
// CRYPT Token = > CRYPT
// CRTT => CRT
// �ڧ٧ާ֧ߧ֧ߧ� ��-��ڧ� ��ѧ٧էѧ�� ���ܧ֧ߧ��. �ҧ֧��ݧѧ�ߧ� ��ѧ٧էѧ�� ���ܧ֧ߧ� �ާ�اߧ� ���ݧ�ܧ� �� 4-�� �٧ѧ�֧٧֧�ӧڧ��ӧѧߧߧ�� �ѧէ�֧���
// �� fallback ���ߧܧ�ڧ� �է�ҧѧӧݧ֧� �ҧݧ�� ��ѧ��֧�� �էݧڧ�֧ݧ�ߧ���� ��֧�ڧ�է��, ��ѧ�� �ާ֧اէ� ��֧�ڧ�էѧާ� 
// �� �ѧӧ��ާѧ�ڧ�֧�ܧ�� ��ާ֧ߧ� ��֧�ڧ�է�� ��� ��ܧ�ߧ�ѧߧڧ� �ܧ�ߧ���ݧ�ߧ�ԧ� �ӧ�֧ާ֧ߧ� (��ѧ�٧�=30 ������)

//- ���ڧާڧ�� ��� ��ҧ�֧ާ� 0.4 ETH = 2 000 ���ܧ֧ߧ��
//- ���ڧާڧ�� ��� �ӧ�֧ާ֧ߧ� 1 ���������� 
//- ���ѧ�٧� �ާ֧اէ� ���ѧէڧ�ާ� - 1 ����ܧ� 
//* ���������������������� ������������ ���� PRESALE 0.1 ETH 
//* ������������������������ ������������ ���� PREICO 0.1 ETH
// ����֧ԧ� �ӧ����֧ߧ� = 50 000 ���ܧ֧ߧ��
// HardCap 40% = 20 000 ���ܧ֧ߧ�� = 4 ETH



pragma solidity ^0.4.23;


contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
        public view returns (uint256);

    function transferFrom(address from, address to, uint256 value)
        public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);
    event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
    );
}



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}



contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
  
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}


contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

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
        uint _addedValue
    )
    public
    returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        returns (bool)
    {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}


contract CRYPTToken is StandardToken {
    string public constant name = "CRYPT Test Token";
    string public constant symbol = "CRTT";
    uint32 public constant decimals = 18;
    uint256 public INITIAL_SUPPLY = 50000 * 1 ether;
    address public CrowdsaleAddress;
    bool public lockTransfers = false;

    constructor(address _CrowdsaleAddress) public {
    
        CrowdsaleAddress = _CrowdsaleAddress;
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;      
    }
  
    modifier onlyOwner() {
        // only Crowdsale contract
        require(msg.sender == CrowdsaleAddress);
        _;
    }

     // Override
    function transfer(address _to, uint256 _value) public returns(bool){
        if (msg.sender != CrowdsaleAddress){
            require(!lockTransfers, "Transfers are prohibited in ICO and Crowdsale period");
        }
        return super.transfer(_to,_value);
    }

     // Override
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
        if (msg.sender != CrowdsaleAddress){
            require(!lockTransfers, "Transfers are prohibited in ICO and Crowdsale period");
        }
        return super.transferFrom(_from,_to,_value);
    }
     
    function acceptTokens(address _from, uint256 _value) public onlyOwner returns (bool){
        require (balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[CrowdsaleAddress] = balances[CrowdsaleAddress].add(_value);
        emit Transfer(_from, CrowdsaleAddress, _value);
        return true;
    }

    function lockTransfer(bool _lock) public onlyOwner {
        lockTransfers = _lock;
    }



    function() external payable {
        // The token contract don`t receive ether
        revert();
    }  
}