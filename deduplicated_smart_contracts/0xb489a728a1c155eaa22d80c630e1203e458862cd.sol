/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



pragma solidity ^0.4.24;



library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

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



contract ERC20Interface {

    

    using SafeMath for uint256;

    

    string public name;

    string public symbol;

    uint8 public decimals;

    uint public totalSupply;



    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function approve(address spender, uint tokens) public returns (bool success);



    function transfer(address to, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);





    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



//���ô��ҿ��ƺ�Լ�Ĺ���Ա

contract Owned {

 

    // modifier(����)����ʾ������Ȩ�������߲���do something������administrator����˼

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;//do something 

    }

 

	//Ȩ��������

    address public owner;

 

	//��Լ������ʱ��ִ�У�ִ�к�Լ�����ǵ�һ��owner

    constructor() public {

        owner = msg.sender;

    }

	//�µ�owner,��ʼΪ�յ�ַ������null

    address newOwner=0x0;

 

	//����owner�ɹ����¼�

    event OwnerUpdate(address _prevOwner, address _newOwner);

 

    //����owner������Ȩ�����µ�owner(��Ҫ�µ�owner����acceptOwnership�����Ż���Ч)

    function changeOwner(address _newOwner) public onlyOwner {

        require(_newOwner != owner);

        newOwner = _newOwner;

    }

 

    //�µ�owner��������Ȩ,Ȩ��������ʽ��Ч

    function acceptOwnership() public{

        require(msg.sender == newOwner);

        emit OwnerUpdate(owner, newOwner);

        owner = newOwner;

        newOwner = 0x0;

    }

}



//���ҵĿ��ƺ�Լ

contract Controlled is Owned{

 

	//����vip

    constructor() public {

       setExclude(msg.sender,true);

    }

 

    // ���ƴ����Ƿ���Խ��ף�true�������(exclude����˻����ܴ����ƣ�����ʵ���������transferAllowed��)

    bool public transferEnabled = true;

 

    // �Ƿ������˻��������ܣ�true��������

    bool lockFlag=true;

	// �������˻����ϣ�address�˻���bool�Ƿ�����true:����������lockFlag=trueʱ����ϲ����ת�������ˣ�����

    mapping(address => bool) locked;

	// ӵ����Ȩ�û�������transferEnabled��lockFlag�����ƣ�vip����boolΪtrue����vip��Ч

    mapping(address => bool) exclude;

 

	//����transferEnabledֵ

    function enableTransfer(bool _enable) public onlyOwner returns (bool success){

        transferEnabled=_enable;

		return true;

    }

 

	//����lockFlagֵ

    function disableLock(bool _enable) public onlyOwner returns (bool success){

        lockFlag=_enable;

        return true;

    }

 

	// ��_addr�ӵ������˻����������������

    function addLock(address _addr) public onlyOwner returns (bool success){

        require(_addr!=msg.sender);

        locked[_addr]=true;

        return true;

    }

 

	//����vip�û�

    function setExclude(address _addr,bool _enable) public onlyOwner returns (bool success){

        exclude[_addr]=_enable;

        return true;

    }

 

	//����_addr�û�

    function removeLock(address _addr) public onlyOwner returns (bool success){

        locked[_addr]=false;

        return true;

    }

	//���ƺ�Լ ����ʵ��

    modifier transferAllowed(address _addr) {

        if (!exclude[_addr]) {

            require(transferEnabled,"transfer is not enabeled now!");

            if(lockFlag){

                require(!locked[_addr],"you are locked!");

            }

        }

        _;

    }

 

}



contract EpilogueToken is ERC20Interface,Controlled {

    

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) allowed;

    

    constructor() public {

        name = 'Epilogue';  //��������

        symbol = 'EP'; //���ҷ���

        decimals = 18; //С���� 

        totalSupply = 100000000 * 10 ** uint256(decimals); //���ҷ������� 

        balanceOf[msg.sender] = totalSupply; //ָ��������

    }

    

    function transfer(address to, uint256 tokens) public returns (bool success) {

        

        require(to != address(0));

        require(balanceOf[msg.sender] >= tokens);

        require(balanceOf[to] + tokens >= balanceOf[to]);

        

        balanceOf[msg.sender] -= tokens;

        balanceOf[to] += tokens;

        

        emit Transfer(msg.sender, to, tokens);

        

        return true;

    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        

        require(to != address(0));

        require(allowed[from][msg.sender] >= tokens);

        require(balanceOf[from] >= tokens);

        require(balanceOf[to] + tokens >= balanceOf[to]);

        

        balanceOf[from] -= tokens;

        balanceOf[to] += tokens;

        

        allowed[from][msg.sender] -= tokens;

        

        emit Transfer(from, to, tokens);

        

        return true;

    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }

    

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        

        emit Approval(msg.sender, spender, tokens);

        

        return true;

    }

    

}