/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.5.0;

library SafeMath {

    //�ӷ�
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    //����
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    //�˷�
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    //����
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

}

/**
 * ��Լ����Ա
 * �ǼǺ�Լ����Ա��ַ������ʵ�ֹ���Աת��
 */
contract Ownable {
    /* ����ԱǮ����ַ */
    address public owner;

    /* ת�ù���Ա��־ */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev ���ú�Լ������Ϊ��Լ����Ա
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev ���޺�Լ����Ա����
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
    * @dev ����Լ����ԱȨ��ת�ø��¹���Ա
    * @param newOwner �¹���ԱǮ����ַ
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/* ��Լ���׿��أ�ֻ�к�Լ����Ա���ܲ��� */
contract Pausable is Ownable {
    /* �����¼������û�в���������¼�¼��� */
    event Pause();
    event Unpause();

    /* ��Լ���׿��ر��� */
    bool public paused = false;

    /**
    * @dev ����δֹͣ��Լ��������²���
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev ����ֹͣ��Լ��������²���
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev ��Լ����Աֹͣ��Լ����
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev ��Լ����Ա������Լ����
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

/* ERC20��׼ */
contract ERC20Basic {
    /* token�ܷ����� */
    uint256 public totalSupply;
    /* ��ȡָ��Ǯ����ַ��token��� */
    function balanceOf(address who) public view returns (uint256);
    /* ת��value��token��ָ��Ǯ����ַto */
    function transfer(address to, uint256 value) public returns (bool);
    /* ת����־ */
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/* ERC20��׼ */
contract ERC20 is ERC20Basic {
    /* ��ȡ����spender������ȡtoken�Ķ�� */
    function allowance(address owner, address spender) public view returns (uint256);
    /* ��׼spender�˻����Լ����˻�ת��value��token���ɷֶ��ת�� */
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    /* ��approve����ʹ�ã�approve��׼֮�󣬵���transferFrom��ת��token */
    function approve(address spender, uint256 value) public returns (bool);
    /* ������approve�ɹ�ʱ��һ��Ҫ����Approval�¼� */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/* ������Լ��ʵ��ERC20��׼ */
contract BasicToken is ERC20Basic {
    /* ���밲ȫ����� */
    using SafeMath for uint256;

    /* �洢ָ��Ǯ����token��� */
    mapping(address => uint256) balances;

    /**
     * @dev ת��_value��token��ָ��Ǯ����ַ_to
     * @param _to ָ��Ǯ����ַ
     * @param _value token����
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        /* ������㣬SafeMath.sub���׳��쳣 */
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev ��ȡָ��Ǯ����ַ��token���
     * @param _owner ָ��Ǯ����ַ
     * @return uint256
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/* ��׼��Լ��ʵ��ERC20��׼ */
contract StandardToken is ERC20, BasicToken {

    /* ָ���˺ŵ�token��� */
    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev ��һ��Ǯ����ַת��token����һ��Ǯ����ַ�����±������token���
     * ��approve����ʹ�ã�approve��׼֮�󣬵���transferFrom��ת��token
     * @param _from ���ĸ�Ǯ����ַ����token
     * @param _to ת�Ƶ��ĸ�Ǯ����ַ
     * @param _value ת�ƶ��ٸ�token����������Ϊ�Ǹ���
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }


    /**
     * @dev ��׼spender���Լ����˻�ת��value��token���ɷֶ��ת��
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender ��Ҫ����token�ĵ�ַ
     * @param _value token��������������token���
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev ��ȡ����spender��ȡtoken�Ķ��
     * @param _owner ��һ��Ǯ����ַ�����Լ����ԱǮ����ַ
     * @param _spender ��Ҫ����token�ĵ�ַ
     * @return uint256
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev ����spender�Ŀ���token���
     * @param _spender ��Ҫ����token�ĵ�ַ
     * @param _addedValue ��Ҫ����token�ĸ����������ɿ�ʹ�õ�token���
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev ����spender�Ŀ���token���
     * @param _spender ��Ҫ����token�ĵ�ַ
     * @param _subtractedValue ��Ҫ����token�ĸ����������ɿ�ʹ�õ�token���
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}
/**
 * ����/����
 **/
contract TokenVesting is Ownable {
    using SafeMath for uint256;

    event Released(uint256 amount);
    event Revoked();
    //��Լ�����ַ
    address public beneficiary;
    
    uint256 public cliff;
    uint256 public start;
    uint256 public duration;
    
    //Token
    MyETPToken _token;
    
    //�Ƿ�ɻ���
    bool public revocable;
    
    //���ͷ�
    uint256 public released;
    bool public revoked;

    /**
    * �������ֺ�Լ
    * @param _ERC20Token ETP��Լ��ַ
    * @param _beneficiary ����Ǯ����ַ
    * @param _start ��ʼʱ���
    * @param _cliff ����ʱ��
    * @param _duration ���ֳ���ʱ��(��λ:s)
    * @param _revocable �Ƿ�ɻ���δ�ͷŲ���
    */
    constructor(address _ERC20Token, address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
        require(_beneficiary != address(0));
        require(_cliff <= _duration);
        _token = MyETPToken(_ERC20Token);
        beneficiary = _beneficiary;
        revocable = _revocable;
        duration = _duration;
        cliff = _start.add(_cliff);
        start = _start;
    }

    /**
    * �ͷ�
    */
    function release() public {
        uint256 unreleased = releasableAmount();
        require(unreleased > 0);
        released = released.add(unreleased);
        _token.transfer(beneficiary, unreleased);
        emit Released(unreleased);
    }

    /**
    * ����δ�ͷ�
    */
    function revoke() public onlyOwner {
        require(revocable);
        require(!revoked);
        uint256 balance = _token.balanceOf(address(this));
        uint256 unreleased = releasableAmount();
        uint256 refund = balance.sub(unreleased);
        revoked = true;
        _token.transfer(owner, refund);
        emit Revoked();
    }

    /**
    * ��ȡ���ͷ�
    **/
    function releasableAmount() public view returns (uint256) {
        return vestedAmount().sub(released);
    }

    /**
    * ��ȡ���ͷ�
    */
    function vestedAmount() public view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration) || revoked) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}

contract MyETPToken is PausableToken {
    /* Token���� */
    string public name;
    /* Token���� */
    string public symbol;
    /* Token��ȷλ�� */
    uint256 public decimals = 18;

    //����
    constructor(uint256 _initialSupply, string memory _tokenName, string memory _tokenSymbol) public {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        name = _tokenName;
        symbol = _tokenSymbol;
    }
    
    //���ĺ�Լ����
    function changeContractName(string memory _newName, string memory _newSymbol) public onlyOwner {
        name = _newName;
        symbol = _newSymbol;
    }
}