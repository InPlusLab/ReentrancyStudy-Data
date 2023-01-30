pragma solidity ^0.5.8;

import "./ERC20Pausable.sol";
import "./ERC20Detailed.sol";
import "./NTSToken.sol";

/**
 * @dev NTS ���ֺ�Լ
 * �ڴ������ߺ���Ҫ��25�ڷ���������Թɶ����ֽ��к�Լ���֡�
 * ���ֹ���
 *   ��ָ�����Ĵ���ת����ĳ�˻�������һ���º���� 50%������ 6 ���½�����
 */
contract NTSTokenTimeLock {
    address private owner;//��Լ������
    // �����Լ��ַ
    NTSToken public token;

    // ���д��������˻��ĳֲ���Ϣ
    mapping(address=>Partner) public balances;
    // ���ֻ��
    address[] public partners;

    // ������Ϣ
    struct Partner {
        uint  initTokens;//��ʼ Token ��
        uint balance;//���
        uint64 nextRelease ;//�´ν���ʱ��timestamp
    }


    constructor(NTSToken _token)public{
        owner = msg.sender;
        token = _token;
    }

    modifier checkTime(uint64 _unlockTimestamp){
        //��Ȼ�������������������ʱ����� block.timestamp �����ɿ󹤲��ݡ�
        //���������ǵ������п�û���㹻�Ķ������޸ģ����Դ˷��ա�
        require(_unlockTimestamp > block.timestamp, "_onceUnlockTime must less at block.timestamp");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"you are not contract owner");
        _;
    }

    /**
        @dev �����������������ʲ�������ָ���˻���������ǰ��Ҫ�� Token ��Լ�ϵ���approve������ Token ת�ơ�
        @param _unlockTimestamp ��һ�ν���ʱ�䣬�������ڵ�ǰ����ʱ�����ע��ʱ�����뼶�� UTC ʱ�����
        @param _partner �����˻�������Ϊ�յ�ַ
        @param _amount ���ֽ�����Ϊ 0���Ҳ��ܳ��� msg.sender �����
     */
    function lock(uint64 _unlockTimestamp,address _partner,uint _amount)
        public  onlyOwner() checkTime(_unlockTimestamp) returns (bool){
        addLock(_unlockTimestamp,_partner,_amount);
        return true;
    }

    /**
     * @dev ����������˺����֣�������ǰ��Ҫ�� Token ��Լ�ϵ���approve������ Token ת�ơ�
        @param _unlockTimestamp ��һ�ν���ʱ�䣬�������ڵ�ǰ����ʱ�����ע��ʱ�����뼶�� UTC ʱ�����
        @param _partners �����˻����ϣ�����Ϊ�յ�ַ
        @param _amounts  �����˻���Ӧ�����ֽ�����Ϊ 0
     */
    function lockBath(uint64 _unlockTimestamp,
    address[] memory _partners,
    uint[] memory _amounts) public onlyOwner() checkTime(_unlockTimestamp) returns(bool){
       require(_partners.length==_amounts.length,"items mismatch");
       for (uint i = 0; i < _partners.length; i++){
            addLock(_unlockTimestamp,_partners[i],_amounts[i]);
       }
       return true;
    }

    // �����˻�����
    function addLock(uint64 _unlockTimestamp,address _partner,uint _amount) internal{
        require(_amount > 0, "no tokens to lock");
        require(_partner!=address(0),"the zero address");
        require(balances[_partner].initTokens==0, "already set partner position");

        //�ӷ�������ת�� Token ������Լ
        bool ok = token.transferFrom(msg.sender,address(this),_amount);
        // ���ת��ʧ�ܣ���˵�����˺�û���㹻����ʹ�ã���˲���Ҫ�������Ƿ���
        require(ok,"transfer token failed");
        balances[_partner] = Partner({
            initTokens: _amount,
            balance: _amount,
            nextRelease: _unlockTimestamp
        });
        partners.push(_partner);
    }

    /**
        @dev �ͷ��ѽ��� Token
     */
    function release() public {
        address to = msg.sender;
        Partner storage p = balances[to];
        require(p.balance > 0,"no tokens can release");
        //���е��˽���ʱ�䣬����ȡ
        require(p.nextRelease <= block.timestamp, "no yet time");

        uint  amount = 0;
        //����ǵ�һ�ν�������������� 50%
        if (p.balance==p.initTokens){
           amount = p.initTokens/2;
        }else{
            //����ÿ��ֻ�ܽ��������� 6 ��֮һ
            // ��һ�ν���һ���ʣ��   p.initTokens/2
            // ��������6 ���½�����ϣ���ÿ�ν��� 6 ��֮һ ���� p.initTokens/2/6
            // �� p.initTokens/12
            amount = p.initTokens/12;
        }
        // ��ȫ������ͷ�
        if(amount>p.balance){
            amount = p.balance;
        }
        bool ok = token.transfer(to, amount);
        require(ok,"transfer token failed");
        // �������
        p.balance -= amount;
        // ������һ�ν���ʱ��
        // 1����=31��x86400��=2678400��
        p.nextRelease += 2678400;
        //��ʹ���Ϊ 0��Ҳ���������ݡ�
    }
}