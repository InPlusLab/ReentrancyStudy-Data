/**

 *Submitted for verification at Etherscan.io on 2018-08-09

*/



pragma solidity ^0.4.11;





contract SafeMath {

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

    function min(uint256 x, uint256 y) constant internal returns (uint256 z) {

        return x <= y ? x : y;

    }

}



// contract ERC20 {

//     function totalSupply() constant returns (uint supply);

//     function balanceOf( address who ) constant returns (uint value);

//     function allowance( address owner, address spender ) constant returns (uint _allowance);



//     function transfer( address to, uint value) returns (bool ok);

//     function transferFrom( address from, address to, uint value) returns (bool ok);

//     function approve( address spender, uint value ) returns (bool ok);



//     event Transfer( address indexed from, address indexed to, uint value);

//     event Approval( address indexed owner, address indexed spender, uint value);

// }



//https://github.com/ethereum/ethereum-org/blob/master/solidity/token-erc20.sol

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {

    // Public variables of the token

    string public name;

    string public symbol;

    uint8 public decimals = 18;

    // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public totalSupply;



    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    // This generates a public event on the blockchain that will notify clients

    event Transfer(address indexed from, address indexed to, uint256 value);

    

    // This generates a public event on the blockchain that will notify clients

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);



    /**

     * Constructor function

     *

     * Initializes contract with initial supply tokens to the creator of the contract

     */

    function TokenERC20(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol

    ) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount

        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens

        name = tokenName;                                   // Set the name for display purposes

        symbol = tokenSymbol;                               // Set the symbol for display purposes

    }



    /**

     * Internal transfer, only can be called by this contract

     */

    function _transfer(address _from, address _to, uint _value) internal {

        // Prevent transfer to 0x0 address. Use burn() instead

        require(_to != 0x0);

        // Check if the sender has enough

        require(balanceOf[_from] >= _value);

        // Check for overflows

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        // Save this for an assertion in the future

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        // Subtract from the sender

        balanceOf[_from] -= _value;

        // Add the same to the recipient

        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    /**

     * Transfer tokens

     *

     * Send `_value` tokens to `_to` from your account

     *

     * @param _to The address of the recipient

     * @param _value the amount to send

     */

    function transfer(address _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);

        return true;

    }



    /**

     * Transfer tokens from other address

     *

     * Send `_value` tokens to `_to` on behalf of `_from`

     *

     * @param _from The address of the sender

     * @param _to The address of the recipient

     * @param _value the amount to send

     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    /**

     * Set allowance for other address

     *

     * Allows `_spender` to spend no more than `_value` tokens on your behalf

     *

     * @param _spender The address authorized to spend

     * @param _value the max amount they can spend

     */

    function approve(address _spender, uint256 _value) public

        returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * Set allowance for other address and notify

     *

     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it

     *

     * @param _spender The address authorized to spend

     * @param _value the max amount they can spend

     * @param _extraData some extra information to send to the approved contract

     */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)

        public

        returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    /**

     * Destroy tokens

     *

     * Remove `_value` tokens from the system irreversibly

     *

     * @param _value the amount of money to burn

     */

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough

        balanceOf[msg.sender] -= _value;            // Subtract from the sender

        totalSupply -= _value;                      // Updates totalSupply

        emit Burn(msg.sender, _value);

        return true;

    }



    /**

     * Destroy tokens from other account

     *

     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.

     *

     * @param _from the address of the sender

     * @param _value the amount of money to burn

     */

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough

        require(_value <= allowance[_from][msg.sender]);    // Check allowance

        balanceOf[_from] -= _value;                         // Subtract from the targeted balance

        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance

        totalSupply -= _value;                              // Update totalSupply

        emit Burn(_from, _value);

        return true;

    }

}



contract Erc20Dist is SafeMath {

    TokenERC20  public  _erc20token; //��������erc20����



    address public _ownerDist;// �����Լ���Ȩ���ˣ���ʼ�Ǵ����ߣ������ƽ�������

    uint256 public _distDay;//����ʱ��

    uint256 public _mode = 0;//ģ����1��ʾʹ��ģʽ1��2��ʾʹ��ģʽ2

    uint256 public _lockAllAmount;//���ֵ�����



    struct Detail{//�����������ṹ������

        address founder;//��ʼ�˵�ַ

        uint256 lockDay;//����ʱ��

        uint256 lockPercent;//���ְٷֱ�����0��100֮�䣩

        uint256 distAmount;//�ܷ�������

        uint256 lockAmount;//��ס�Ĵ�������

        uint256 initAmount;//��ʼ��Ĵ�����

        uint256 distRate;//���ֽ�����ÿ�������Ұٷֱ���������ס���ܶ��㣬0��100֮�䣩

        uint256 oneDayTransferAmount;//���ֽ�����ÿ��Ӧ���ŵĴ�������

        uint256 transferedAmount;//��ת�˴�������

        uint256 lastTransferDay;//���һ�ʴ��ҷ����ʱ��

        bool isFinish;// �Ƿ��˶��������

        bool isCancelDist;//�Ƿ�ͬ�⳷������

    }

    Detail private detail = Detail(address(0),0,0,0,0,0,0,0,0,0, false, false);//�м������ʼ���������ں�������ʱ�нӼ��������Ա㴫�͸�_details

    Detail[] public _details;//������������б�,����ʼ��Ϊ��ֵ

	uint256 public _detailsLength = 0;//�������鳤��



    bool public _fDist = false;// �Ƿ��Ѿ��������ı�ʶ����

    bool public _fConfig = false;// �Ƿ��Ѿ����ù��ı�ʶ����

    bool public _fFinish = false;// �Ƿ������˶��������

    bool public _fCancelDist = false;// �Ƿ�������

    

    function Erc20Dist() public {

        _ownerDist = msg.sender; // Ĭ�ϴ�����ΪȨ�������

    }



    function () public{}//callback���������ں�Լû��eth��ֵ���룬����û��ʲô��ȫ����



    // ���ú�Լ������

    function setOwner(address owner_) public {

        require (msg.sender == _ownerDist, "you must _ownerDist");// ����ԭ����������Ȩ

        require(_fDist == false, "not dist"); // ���뻹û��ʼ����

        require(_fConfig == false, "not config");// ���뻹û���ù�

        _ownerDist = owner_;

    }

    //���ò������Һ���

    function setErc20(TokenERC20  erc20Token) public {

        require (msg.sender == _ownerDist, "you must _ownerDist");

        require(address(_erc20token) == address(0),"you have set erc20Token");//����֮ǰû�����ù�

        require(erc20Token.balanceOf(address(this)) > 0, "this contract must own tokens");

        _erc20token = erc20Token;//��ȫ������erc20����

        _lockAllAmount = erc20Token.balanceOf(address(this));

    }



    // �������У��������в�����ͬ�⣬���ܳ�������

    function cancelDist() public {

        require(_fDist == true, "must dist"); // ���뷢��

        require(_fCancelDist == false, "must not cancel dist");



        // ѭ���ж��Ƿ�

        for(uint256 i=0;i<_details.length;i++){

            // �ж��Ƿ�����

            if ( _details[i].founder == msg.sender ) {

                // ���ñ�־

                _details[i].isCancelDist = true;

                break;

            }

        }

        // ����״̬

        updateCancelDistFlag();

        if (_fCancelDist == true) {

            require(_erc20token.balanceOf(address(this)) > 0, "must have balance");

            // �������д��Ҹ����Ȩ����

            _erc20token.transfer(

                _ownerDist, 

                _erc20token.balanceOf(address(this))

            );

        }

    }



    // �����Ƿ������б�־

    function updateCancelDistFlag() private {

        bool allCancelDist = true;

        for(uint256 i=0; i<_details.length; i++){

            // �ж���û����û����

            if (_details[i].isCancelDist == false) {

                allCancelDist = false;

                break;

            }

        }

        // ���º�Լ��ɱ�־

        _fCancelDist = allCancelDist;

    }



    // ��û���÷�������£��������д��ң������Ȩ���˺ţ������������

    function clearConfig() public {

        require (msg.sender == _ownerDist, "you must _ownerDist");

        require(_fDist == false, "not dist"); // ���뻹û��ʼ����

        require(address(_erc20token) != address(0),"you must set erc20Token");//����֮ǰ���ù�

        require(_erc20token.balanceOf(address(this)) > 0, "must have balance");

        // �������д��Ҹ����Ȩ����

        _erc20token.transfer(

            msg.sender, 

            _erc20token.balanceOf(address(this))

        );

        // ��ձ���

        _lockAllAmount = 0;

        TokenERC20  nullErc20token;

        _erc20token = nullErc20token;

        Detail[] nullDetails;

        _details = nullDetails;

        _detailsLength = 0;

        _mode = 0;

        _fConfig = false;

    }



    // �ͻ�֮ǰ��ת����Լ�ıң�����ͨ������ӿڣ���ȡ�����Ȩ�����˺ţ��������ں�Լִ�����֮��

    function withDraw() public {

        require (msg.sender == _ownerDist, "you must _ownerDist");

        require(_fFinish == true, "dist must be finished"); // ��Լ����ִ�����

        require(address(_erc20token) != address(0),"you must set erc20Token");//����֮ǰ���ù�

        require(_erc20token.balanceOf(address(this)) > 0, "must have balance");

        // �������д��Ҹ����Ȩ����

        _erc20token.transfer(

            _ownerDist, 

            _erc20token.balanceOf(address(this))

        );

    }



    //������ش�ʼ�˼����ҷ��š�������Ϣ���������ĺ�����auth��֤�������Ǻ�Լ�����˲��ܽ��иò���

    function configContract(uint256 mode,address[] founders,uint256[] distWad18Amounts,uint256[] lockPercents,uint256[] lockDays,uint256[] distRates) public {

    //��������˵����founders����ʼ�˵�ַ�б���

    //distWad18Amounts���ܷ��������б�������18λС��λ������

    //lockPercents�����ְٷֱ��б�ֵ��0��100֮�䣩����

    //lockDays�����������б�,distRates��ÿ�췢����ռ������������ֱ����б�ֵ��0��10000֮�䣩��

        require (msg.sender == _ownerDist, "you must _ownerDist");

        require(mode==1||mode==2,"there is only mode 1 or 2");//ֻ��ģʽ1��2����������ʽ

        _mode = mode;//�����췽ʽע�ᵽȫ��

        require(_fConfig == false,"you have configured it already");//���뻹δ���ù�

        require(address(_erc20token) != address(0), "you must setErc20 first");//�����Ѿ����úñ�����erc20����

        require(founders.length!=0,"array length can not be zero");//��ʼ���б���Ϊ��

        require(founders.length==distWad18Amounts.length,"founders length dismatch distWad18Amounts length");//��ʼ���б��ȱ�����ڷ��������б���

        require(distWad18Amounts.length==lockPercents.length,"distWad18Amounts length dismatch lockPercents length");//���������б��ȱ���������ְٷֱ��б���

        require(lockPercents.length==lockDays.length,"lockPercents length dismatch lockDays length");//���ְٷֱ��б��ȱ���������������б���

        require(lockDays.length==distRates.length,"lockDays length dismatch distRates length");//���ְٷֱ��б��ȱ������ÿ�շ��ű����б���



        //����

        for(uint256 i=0;i<founders.length;i++){

            require(distWad18Amounts[i]!=0,"dist token amount can not be zero");//ȷ������������Ϊ0

            for(uint256 j=0;j<i;j++){

                require(founders[i]!=founders[j],"you could not give the same address of founders");//����ȷ����ʼ����û�е�ַ��ͬ��

            }

        }

        



        //����Ϊѭ���з���ȫ�ֱ������м���ʱ����

        uint256 totalAmount = 0;//���Ŵ�������

        uint256 distAmount = 0;//����ǰ��ʼ�˷��Ŵ���������18λ���ȣ�

        uint256 oneDayTransferAmount = 0;//������ÿ��Ӧ���ŵ����������ں������м��㣩

        uint256 lockAmount = 0;//��ǰ��ʼ����ס�Ĵ�����

        uint256 initAmount = 0;//��ǰ��ʼ�˳�ʼ�������



        //����

        for(uint256 k=0;k<lockPercents.length;k++){

            require(lockPercents[k]<=100,"lockPercents unit must <= 100");//���ְٷֱ�������С�ڵ���100

            require(distRates[k]<=10000,"distRates unit must <= 10000");//������ֱ�������С�ڵ���10000

            distAmount = mul(distWad18Amounts[k],10**18);//����ǰ��ʼ�˷��Ŵ���������18λ���ȣ�

            totalAmount = add(totalAmount,distAmount);//���������ۼ�

            lockAmount = div(mul(lockPercents[k],distAmount),100);//��ס�Ĵ�������

            initAmount = sub(distAmount, lockAmount);//��ʼ��Ĵ�������

            oneDayTransferAmount = div(mul(distRates[k],lockAmount),10000);//������ÿ��Ӧ���ŵ�����



            //����Ϊ�м����detail��9����Ա��ֵ

            detail.founder = founders[k];

            detail.lockDay = lockDays[k];

            detail.lockPercent = lockPercents[k];

            detail.distRate = distRates[k];

            detail.distAmount = distAmount;

            detail.lockAmount = lockAmount;

            detail.initAmount = initAmount;

            detail.oneDayTransferAmount = oneDayTransferAmount;

            detail.transferedAmount = 0;//��ʼ��δ��ʼ���ţ������ѷ�������Ϊ0

            detail.lastTransferDay = 0;//��ʼ��δ��ʼ���ţ����ķ�������Ϊ0

            detail.isFinish = false;

            detail.isCancelDist = false;

            //�����õ��м���Ϣѹ��ȫ����Ϣ�б�_details

            _details.push(detail);

        }

        require(totalAmount <= _lockAllAmount, "distributed total amount should be equal lock amount");// ��������Ӧ�õ�����������

        require(totalAmount <= _erc20token.totalSupply(),"distributed total amount should be less than token totalSupply");//���ŵĴ�����������С���ܴ�����

		_detailsLength = _details.length;

        _fConfig = true;//������ϣ���������ɱ�ʶ����Ϊ��

        _fFinish = false;// Ĭ��û�������

        _fCancelDist = false;// �����������

    }



    //��ʼ���ź�������δ����ͷ��Ÿ�����ʼ�ˣ��������������Ϊ0�ģ�������Ľ������ͷ�����Ҳһͬ���š�auth��֤�������Ǻ�Լ�����˲��ܽ��иò���

    function startDistribute() public {

        require (msg.sender == _ownerDist, "you must _ownerDist");

        require(_fDist == false,"you have distributed erc20token already");//���뻹δ��ʼ���Ź�

        require(_details.length != 0,"you have not configured");//���뻹δ���ù�

        _distDay = today();//����ǰ������ϵͳʱ���¼Ϊ����ʱ��

        uint256 initDistAmount=0;//����ѭ����ʹ�õĵ�ǰ��ʼ�ˡ���ʼ���Ŵ���������ʱ����



        for(uint256 i=0;i<_details.length;i++){

            initDistAmount = _details[i].initAmount;//�׷���



            if(_details[i].lockDay==0){//�����ǰ��ʼ����������Ϊ0

                initDistAmount = add(initDistAmount, _details[i].oneDayTransferAmount);//��ʼ���Ŵ�����Ϊ�׷���+һ��ķ�����

            }

            _erc20token.transfer(

                _details[i].founder,

               initDistAmount

            );

            _details[i].transferedAmount = initDistAmount;//�ѷ���������ȫ��ϸ���н��еǼ�

            _details[i].lastTransferDay =_distDay;//����һ�η���������ȫ��ϸ���н��еǼ�

        }



        _fDist = true;//�ѳ�ʼ���ű�ʶ����Ϊ��

        updateFinishFlag();// ��������ɱ�־

    }



    // �����Ƿ�����ɱ�־

    function updateFinishFlag() private {

        //

        bool allFinish = true;

        for(uint256 i=0; i<_details.length; i++){

            // ����Ҫ���ֵģ�ֱ���������

            if (_details[i].lockPercent == 0) {

                _details[i].isFinish = true;

                continue;

            }

            // �����ֵģ������������ڽ���������Ҳ�������

            if (_details[i].distAmount == _details[i].transferedAmount) {

                _details[i].isFinish = true;

                continue;

            }

            allFinish = false;

        }

        // ���º�Լ��ɱ�־

        _fFinish = allFinish;

    }



    //ģʽ1�������˿ɵ��øú������쵱��Ӧ���Ŷ�

    function applyForTokenOneDay() public{

        require(_mode == 1,"this function can be called only when _mode==1");//ģʽ1�¿ɵ���

        require(_distDay != 0,"you haven't distributed");//�����Ѿ�������ʼ����

        require(_fFinish == false, "not finish");//�����Լ��ûִ����

        require(_fCancelDist == false, "must not cancel dist");

        uint256 daysAfterDist;//�����ʼ�𷢷�ʱ��

        uint256 tday = today();//���øú���ʱϵͳ��ǰʱ��

      

        for(uint256 i=0;i<_details.length;i++){

            // �����Ѿ���ɵĿ���pass

            if (_details[i].isFinish == true) {

                continue;

            }



            require(tday!=_details[i].lastTransferDay,"you have applied for todays token");//������컹δ����

            daysAfterDist = sub(tday,_distDay);//��������ʼ�𷢷�ʱ������

            if(daysAfterDist >= _details[i].lockDay){//���뷢��������Ҫ���ڵ�����������

                if(add(_details[i].transferedAmount, _details[i].oneDayTransferAmount) <= _details[i].distAmount){

                //�����ǰ��ʼ��ʣ��ķ����������ڵ���ÿ��Ӧ�����������򽫵���Ӧ��������������

                    _erc20token.transfer(

                        _details[i].founder,

                        _details[i].oneDayTransferAmount

                    );

                    //�ѷ���������ȫ��ϸ���н��еǼǸ���

                    _details[i].transferedAmount = add(_details[i].transferedAmount, _details[i].oneDayTransferAmount);

                }

                else if(_details[i].transferedAmount < _details[i].distAmount){

                //��������ѷ�������δ�ﵽ����Ӧ���������򽫵�ǰ��ʼ��ʣ���Ӧ���Ŵ��Ҷ����Ÿ���

                    _erc20token.transfer(

                        _details[i].founder,

                        sub( _details[i].distAmount, _details[i].transferedAmount)

                    );

                    //�ѷ���������ȫ��ϸ���н��еǼǸ���

                    _details[i].transferedAmount = _details[i].distAmount;

                }

                //����һ�η���������ȫ��ϸ���н��еǼǸ���

                _details[i].lastTransferDay = tday;

            }

        }   

        // ��������ɱ�־

        updateFinishFlag();

    }



    ///ģʽ2�������˿ɵ��øú������쵽��ǰʱ��Ӧ��ӵ�е�δ���Ĵ���

    function applyForToken() public {

        require(_mode == 2,"this function can be called only when _mode==2");//ģʽ2�¿ɵ���

        require(_distDay != 0,"you haven't distributed");//�����Ѿ�������ʼ����

        require(_fFinish == false, "not finish");//�����Լ��ûִ����

        require(_fCancelDist == false, "must not cancel dist");

        uint256 daysAfterDist;//�����ʼ�𷢷�ʱ��

        uint256 expectAmount;//����ѭ���е�ǰ��ʼ�˵�����ΪֹӦ�ñ����ŵ�����

        uint256 tday = today();//���øú���ʱϵͳ��ǰʱ��

        uint256 expectReleaseTimesNoLimit = 0;//�����󵽽���ΪֹӦ�÷ŵ�β�����(�������ѷ��������)



        for(uint256 i=0;i<_details.length;i++){

            // �����Ѿ���ɵĿ���pass

            if (_details[i].isFinish == true) {

                continue;

            }

            //������컹δ����

            require(tday!=_details[i].lastTransferDay,"you have applied for todays token");

            daysAfterDist = sub(tday,_distDay);//��������ʼ�𷢷�ʱ������

            if(daysAfterDist >= _details[i].lockDay){//���뷢��������Ҫ���ڵ�����������

                expectReleaseTimesNoLimit = add(sub(daysAfterDist,_details[i].lockDay),1);//�����󵽽���ΪֹӦ�÷ŵ�β�����

                //��ĿǰΪֹӦ�÷��ŵ�����=����Ӧ���ͷſ�Ĵ���xÿ��Ӧ���ͷŵı�����+��ʼ���������� ��ǰ��ʼ��Ӧ���ܷ������� �еĽ�Сֵ

                //��Ϊ�ͷſ�������ܴܺ��ˣ���������ʱ����

                expectAmount = min(add(mul(expectReleaseTimesNoLimit,_details[i].oneDayTransferAmount),_details[i].initAmount),_details[i].distAmount);



                //��Ƿ�µĴ���ͳͳ���Ÿ���ǰ��ʼ��

                _erc20token.transfer(

                    _details[i].founder,

                    sub(expectAmount, _details[i].transferedAmount)

                );

                //�ѷ���������ȫ��ϸ���н��еǼǸ���

                _details[i].transferedAmount = expectAmount;

                //����һ�η���������ȫ��ϸ���н��еǼǸ���

                _details[i].lastTransferDay = tday;

            }

        }

        // ��������ɱ�־

        updateFinishFlag();

    }



    //һ����м���

    function today() public constant returns (uint256) {

        return div(time(), 24 hours);//24 hours 

    }

    

    //��ȡ��ǰϵͳʱ��

    function time() public constant returns (uint256) {

        return block.timestamp;

    }

 

}