/**
 *Submitted for verification at Etherscan.io on 2019-06-19
*/

pragma solidity >=0.4.0 <0.6.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable {
     address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title Token
 * @dev API interface for interacting with the WILD Token contract 
 */
interface Token {

  function allowance(address _owner, address _spender) external returns (uint256 remaining);

  function transfer(address _to, uint256 _value) external;

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

  function balanceOf(address _owner) external returns (uint256 balance);
}


/**
* @title Iot Chain Node Contract
* �ڵ�ͶƱ��Լ����Ҫ���ܰ������볬���ڵ㣬�ڵ�ͶƱ��Token����
*/
contract NodeBallot is Ownable{
    
    using SafeMath for uint256;

    struct Node {
        // original
        uint256 originalAmount;
        // total
        uint256 totalBallotAmount;
        // date ��Ϊ�����ڵ�ʱ��
        uint date;
        //  judge node is valid
        bool valid;
    }
    
    struct BallotInfo {
        //�ڵ��ַ
        address nodeAddress;
        //ͶƱ���� 
        uint256 amount;
        //ͶƱ����
        uint date;
    }

    //������90��
    uint256 public constant lockLimitTime = 3 * 30 ; 
    
    //��token
    Token public token;
    
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public decimals = 10**18;
    
    //�ڵ���Ϣ 
    mapping (address => Node) public nodes;
    //�û�ͶƱ��Ϣ 
    mapping (address => BallotInfo) public userBallotInfoMap;
    //��Ƿ���
    bool public activityEnable = true;
    //�Ƿ񿪷�����
    bool public withdrawEnable = false;
    //�ܲ������������
    uint256 public totalLockToken = 0; 
    //�����ֵ�Token����
    uint256 public totalWithdrawToken = 0; 
    //���ʼ����
    uint public startDate = 0;
    
    constructor(address tokenAddr) public{
        
        token = Token(tokenAddr);
        
        startDate = now;
    }
    
    
    /**
    * @dev ͶƱ�¼���¼ 
    * _ballotAddress ͶƱ��ַ
    * _nodeAddress �ڵ��ַ
    * _ballotAmount ͶƱ���� 
    * _date ͶƱʱ���
    */
    event Ballot(address indexed _ballotAddress,address indexed _nodeAddress, uint256 _ballotAmount, uint _date);
    
     /**
    * @dev �����ڵ��¼ 
    * _nodeAddress �����ڵ��ַ
    * _oringinalAmount �����ڵ�ֲ����� 
    * _date ��Ϊ�����ڵ��ʱ���
    */
    event GeneralNode(address indexed _nodeAddress,uint256 _oringinalAmount, uint _date);
    
    /**
    * @dev ���ּ�¼ 
    * _ballotAddress ���ֵ�ַ
    * amount ��������
    */
    event Withdraw(address indexed _ballotAddress,uint256 _amount);

    /**
    * @dev �޸Ļ����״̬ 
    * enable ��Ƿ����
    */
    function motifyActivityEnable(bool enable) public onlyOwner{
        activityEnable = enable;
    }
    
    /**
    * @dev ���Ŀ�������״̬���ɹ���Ա����״̬�޸�
    * enable ����/�ر�
    */
    function openWithdraw(bool enable) public onlyOwner {
        
        if(enable){
            require(activityEnable == false,"please make sure the activity is closed.");
        }
        else{
            require(activityEnable == true,"please make sure the activity is on.");
        }
        withdrawEnable = enable;
    }
   
   
   
    /**
    * @dev ��Ϊ�����ڵ���Ϣ��
    * nodeAddress �ڵ��ַ
    * originalAmount �ڵ��ʲ�
    */
    function generalSuperNode(uint256 originalAmount) public {

        //�жϻ�Ƿ����
        require(activityEnable == true ,'The activity have been closed. Code<202>');
        
        //��鳬���ڵ���Ѻ����
        require(originalAmount >= 100000 * decimals,'The amount of node token is too low. Code<201>');
        
        //����û��Ƿ���Ȩ���㹻�������  
        uint256 allowance = token.allowance(msg.sender,address(this));
        require(allowance>=originalAmount,'Insufficient authorization balance available in the contract. Code<204>');

        //���ó����ڵ��Ƿ����
        Node memory addOne = nodes[msg.sender];
        require(addOne.valid == false,'Node did exist. Code<208>');
        
        //���ݴ洢
        nodes[msg.sender] = Node(originalAmount,0,now,true);
        
        totalLockToken = SafeMath.add(totalLockToken,originalAmount);
        
        //��ͶƱ�˵�tokenת�Ƶ���Լ��
        token.transferFrom(msg.sender,address(this),originalAmount);
        
        emit GeneralNode(msg.sender,originalAmount,now);
    }
    
    /**
    * @dev ͶƱ�����û����ø÷�������ͶƱ
    * nodeAddressArr �ڵ��ַ
    * ballotAmount   ͶƱ����
    */
    function ballot(address nodeAddress , uint256 ballotAmount) public returns (bool result){
        
        //�жϻ�Ƿ����
        require(activityEnable == true ,'The activity have been closed. Code<202>');
        
        //�ж��û��Ƿ���ͶƱ
        BallotInfo memory ballotInfo = userBallotInfoMap[msg.sender];
        require(ballotInfo.amount == 0,'The address has been voted. Code<200>');
        
        //���ڵ��Ƿ����
        Node memory node = nodes[nodeAddress];
        require(node.valid == true,'Node does not exist. Code<203>');
            
        //����û��Ƿ���Ȩ���㹻�������  
        uint256 allowance = token.allowance(msg.sender,address(this));
        require(allowance>=ballotAmount,'Insufficient authorization balance available in the contract. Code<204>');

        //ͳ�ƽڵ�ͶƱ��Ϣ 
        nodes[nodeAddress].totalBallotAmount = SafeMath.add(node.totalBallotAmount,ballotAmount);
        
         //�洢�û�ͶƱ��Ϣ 
        BallotInfo memory info = BallotInfo(nodeAddress,ballotAmount,now);
        userBallotInfoMap[msg.sender]=info;
        
        //ͳ���������� 
        totalLockToken = SafeMath.add(totalLockToken,ballotAmount);
        
        //��ͶƱ�˵�itcת�Ƶ���Լ��ת�Ƶ���Լ��
        token.transferFrom(msg.sender,address(this),ballotAmount);
        
        emit Ballot(msg.sender,nodeAddress,ballotAmount,now);
        
        result = true;
    }
    
    /**
    * @dev ���֣����û����ø÷����������� 
    */
    function withdrawToken() public returns(bool res){
        
        return _withdrawToken(msg.sender);
    }
 
    /**
    * @dev ���֣��ɹ���Ա���ø÷�����ָ����ַ�������� 
    * ballotAddress �û���ַ 
    */
    function withdrawTokenToAddress(address ballotAddress) public onlyOwner returns(bool res){
        
        return _withdrawToken(ballotAddress);
    }
    
    /**
    * @dev ���֣��ڲ�����
    * destinationAddress ���ֵ�ַ
    */
    function _withdrawToken(address destinationAddress) internal returns(bool){
        
        require(destinationAddress != address(0),'Invalid withdraw address. Code<205>');
        require(withdrawEnable,'Token withdrawal is not open. Code<207>');
        
        BallotInfo memory info = userBallotInfoMap[destinationAddress];
        Node memory node = nodes[destinationAddress];
        
        require(info.amount != 0 || node.originalAmount != 0,'This address is invalid. Code<209>');

        uint256 amount = 0;

        if(info.amount != 0){
            require(now >= info.date + lockLimitTime * 1 days,'The token is still in the lock period. Code<212>');
            amount = info.amount;

            userBallotInfoMap[destinationAddress]=BallotInfo(info.nodeAddress,0,info.date);
        }
        
        if(node.originalAmount != 0){
            
            require(now >= node.date + lockLimitTime * 1 days,'The token is still in the lock period. Code<212>');
            amount = SafeMath.add(amount,node.originalAmount);
            
            nodes[destinationAddress] = Node(node.originalAmount,node.totalBallotAmount,node.date,false);
        }
        
        totalWithdrawToken = SafeMath.add(totalWithdrawToken,amount);
        
        //���Ŵ���
        token.transfer(destinationAddress,amount);
        
        emit Withdraw(destinationAddress,amount);
        
        return true;
    }
    
    
    /**
    * @dev ת��Token������Ա����
    */
    function transferToken() public onlyOwner {
        
        require(now >= startDate + 365 * 1 days,"transfer time limit.");
        token.transfer(_owner, token.balanceOf(address(this)));
    }

    
    /**
    * @dev ���ٺ�Լ
    */
    function destruct() payable public onlyOwner {
        
        //����Ƿ����  
        require(activityEnable == false,'Activities are not up to the deadline. Code<212>');
        //����Ƿ������
        require(token.balanceOf(address(this)) == 0 , 'please execute transferToken first. Code<213>');
        
        selfdestruct(msg.sender); // ���ٺ�Լ
    }
}