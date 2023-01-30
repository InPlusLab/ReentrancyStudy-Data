/**

 *Submitted for verification at Etherscan.io on 2018-08-24

*/



pragma solidity ^0.4.20;



/*

* LastHero�Ŷ�.

* -> ����ʲô?

* �Ľ��������������ʽ�ģ��:

* [x] �ú�Լ��Ŀǰ���ȶ������ܺ�Լ�����ܹ����еĹ�������!

* [x] ��ARC�ȶ�����ȫר����˲��ԡ�

* [X] �¹��ܣ��ɲ��������������ؽ���������ʲ�ȫ������!

* [x] �¹��ܣ�������Ǯ��֮�䴫����ҡ����������ܺ�Լ�н��н���!

* [x] �����ԣ������״�POS�ڵ���̫��ְ�ܺ�Լ����V������¹��ܡ�

* [x] ���ڵ㣺����100�����Ҽ���ӵ���Լ������ڵ㣬���ڵ���Ψһ�����ܺ�Լ���!

* [x] ���ڵ㣺����ͨ��������ڵ�����Լ����ң�����Ի��10%�ķֺ�!

*

* -> ������Ŀ?

* ���ǵ��Ŷӳ�Աӵ�г�ǿ�Ĵ�����ȫ���ܺ�Լ��������

* �µĿ����Ŷ��ɾ���ḻ��רҵ������Ա��ɣ����������Լ��ȫר����ˡ�

* ���⣬���ǹ������й����ٴε�ģ�⹥�����ú�Լ����û�б����ƹ���

* 

* -> �����Ŀ�ĳ�Ա����Щ?

* - PonziBot (math/memes/main site/master)��ѧ

* - Mantso (lead solidity dev/lead web3 dev)����

* - swagg (concept design/feedback/management)�������/����/����

* - Anonymous#1 (main site/web3/test cases)��վ/web3/����

* - Anonymous#2 (math formulae/whitepaper)��ѧ�Ƶ�/��Ƥ��

*

* -> ����Ŀ�İ�ȫ�����Ա:

* - Arc

* - tocisck

* - sumpunk

*/



contract Hourglass {

    /*=================================

    =            MODIFIERS  ȫ��       =

    =================================*/

    // ֻ�޳ֱ��û�

    modifier onlyBagholders() {

        require(myTokens() > 0);

        _;

    }

    

    // ֻ�������û�

    modifier onlyStronghands() {

        require(myDividends(true) > 0);

        _;

    }

    

    // ����ԱȨ��:

    // -> ���ĺ�Լ����

    // -> ���Ĵ�������

    // -> �ı�POS���Ѷȣ�ȷ��ά��һ�����ڵ���Ҫ���ٴ��ң��Ա����ķ���

    // ����Աû��Ȩ������������:

    // -> �����ʽ�

    // -> ��ֹ�û�ȡ��

    // -> �Իٺ�Լ

    // -> �ı���Ҽ۸�

    modifier onlyAdministrator(){ // ����ȷ���ǹ���Ա

        address _customerAddress = msg.sender;

        require(administrators[keccak256(_customerAddress)]); // �ڹ���Ա�б��д���

        _; // ��ʾ��modifier�ĺ���ִ����󣬿�ʼִ����������

    }

    

    

    // ȷ����Լ�е�һ�����Ҿ��ȵķ���

    // ����ζ�ţ�����ƽ�����Ƴɱ��ǲ����ܴ��ڵ�

    // �⽫Ϊ����Ľ����ɳ����¼�ʵ�Ļ�����

    modifier antiEarlyWhale(uint256 _amountOfEthereum){ // �ж�״̬

        address _customerAddress = msg.sender;

        

        // ���ǻ��Ǵ��ڲ�����Ͷ�ʵ�λ��?

        // ��Ȼ��ˣ����ǽ���ֹ���ڵĴ��Ͷ�� 

        if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){

            require(

                // ����û��ڴ���������

                ambassadors_[_customerAddress] == true &&

                

                // �û��������Ƿ񳬹�����������

                (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_

                

            );

            

            // �����ۼ����  

            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);

        

            // ִ��

            _;

        } else {

            // �����������̫�������½�������ֵ������׶�Ҳ��������������

            onlyAmbassadors = false;

            _;    

        }

        

    }

    

    

    /*==============================

    =            EVENTS  �¼�      =

    ==============================*/

    event onTokenPurchase( // �������

        address indexed customerAddress,

        uint256 incomingEthereum,

        uint256 tokensMinted,

        address indexed referredBy

    );

    

    event onTokenSell( // ���۴���

        address indexed customerAddress,

        uint256 tokensBurned,

        uint256 ethereumEarned

    );

    

    event onReinvestment( // ��Ͷ��

        address indexed customerAddress,

        uint256 ethereumReinvested,

        uint256 tokensMinted

    );

    

    event onWithdraw( // ��ȡ�ʽ�

        address indexed customerAddress,

        uint256 ethereumWithdrawn

    );

    

    // ERC20��׼

    event Transfer( // һ�ν���

        address indexed from,

        address indexed to,

        uint256 tokens

    );

    

    

    /*=====================================

    =            CONFIGURABLES  ����       =

    =====================================*/

    string public name = "LastHero3D"; // ����

    string public symbol = "Keys"; // ����

    uint8 constant public decimals = 18; // С��λ

    uint8 constant internal dividendFee_ = 10; // ���׷ֺ����

    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether; // ���ҳ�ʼ�۸�

    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether; // ���ҵ����۸�

    uint256 constant internal magnitude = 2**64;

    

    // �ɷ�֤����Ĭ��ֵΪ100���ң�

    uint256 public stakingRequirement = 100e18;

    

    // ����ƻ�

    mapping(address => bool) internal ambassadors_; // ������

    uint256 constant internal ambassadorMaxPurchase_ = 1 ether; // �����

    uint256 constant internal ambassadorQuota_ = 20 ether; // �����޶�

    

    

    

   /*================================

    =            DATASETS   ����     =

    ================================*/

    // ÿ����ַ�Ĺɷ���������������ţ�

    mapping(address => uint256) internal tokenBalanceLedger_; // �����ַ�Ĵ�������

    mapping(address => uint256) internal referralBalance_; // �����ַ���Ƽ��ֺ�

    mapping(address => int256) internal payoutsTo_;

    mapping(address => uint256) internal ambassadorAccumulatedQuota_;

    uint256 internal tokenSupply_ = 0;

    uint256 internal profitPerShare_;

    

    // ����Ա�б�����ԱȨ�޼�������

    mapping(bytes32 => bool) public administrators; // �����ߵ�ַ�б�

    

    // �������ƶȳ�����ֻ�д�����Թ�����ң���ȷ���������Ľ������ֲ����Է��ֱұ���������

    bool public onlyAmbassadors = true; // ����ֻ�д����ܹ��������

    





    /*=======================================

    =            PUBLIC FUNCTIONS ��������   =

    =======================================*/

    /*

    * -- Ӧ����� --  

    */

    function Hourglass()

        public

    {

        // ��������ӹ���Ա

        administrators[0x4d947d5487ba694cc3c03fbaae7a63f0aec61e26bf7284baa1e36f8cbdbfe7e1] = true;

        administrators[0xdacb12a29ec52e618a1dbe39a3317833066e94371856cc2013565dab2ae6fa62] = true;

        

        // ��������Ӵ���

        // mantso - lead solidity dev & lead web dev. 

        ambassadors_[0xdD9eaEbc859051A801e2044636204271B5D6821A] = true;

        

        // ponzibot - mathematics & website, and undisputed meme god.

        ambassadors_[0xd47671aA1c42cF274697C8Fdf77470509B296d09] = true;



        ambassadors_[0x8948e4b00deb0a5adb909f4dc5789d20d0851d71] = true;

        



    }

    

     

    /**

     * ��������̫�����紫��ת��Ϊ���ҵ��ã������´��ݣ�������²����ˣ�

     */

    function buy(address _referredBy)

        public

        payable

        returns(uint256)

    {

        purchaseTokens(msg.value, _referredBy);

    }

    

    /**

     * �ص�����������ֱ�ӷ��͵���Լ����̫��������

     * ���ǲ���ͨ�����ַ�ʽ��ָ��һ����ַ��

     */

    function()

        payable

        public

    {

        purchaseTokens(msg.value, 0x0);

    }

    

    /**

     * �����еķֺ�����ת��Ϊ���ҡ�

     */

    function reinvest()

        onlyStronghands()

        public

    {

        // ��ȡ��Ϣ

        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code

        

        // ʵ��֧���Ĺ�Ϣ

        address _customerAddress = msg.sender;

        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

        

        // �����ο�����

        _dividends += referralBalance_[_customerAddress];

        referralBalance_[_customerAddress] = 0;

        

        // ����һ�����򶩵�ͨ�����⻯�ġ����ع�Ϣ��

        uint256 _tokens = purchaseTokens(_dividends, 0x0);

        

        // �ش��¼�

        onReinvestment(_customerAddress, _dividends, _tokens);

    }

    

    /**

     * �˳����̣�����������ȡ�ʽ�

     */

    function exit()

        public

    {

        // ͨ�����û�ȡ��������������ȫ������

        address _customerAddress = msg.sender;

        uint256 _tokens = tokenBalanceLedger_[_customerAddress];

        if(_tokens > 0) sell(_tokens);

        

        // ȡ�����

        withdraw();

    }



    /**

     * ȡ�������ߵ��������档

     */

    function withdraw()

        onlyStronghands()

        public

    {

        // ��������

        address _customerAddress = msg.sender;

        uint256 _dividends = myDividends(false); // �Ӵ����л�òο�����

        

        // ���¹�Ϣϵͳ

        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

        

        // ��Ӳο�����

        _dividends += referralBalance_[_customerAddress];

        referralBalance_[_customerAddress] = 0;

        

        // ��ȡ����

        _customerAddress.transfer(_dividends);

        

        // �ش��¼�

        onWithdraw(_customerAddress, _dividends);

    }

    

    /**

     * ��̫�����ҡ�

     */

    function sell(uint256 _amountOfTokens)

        onlyBagholders()

        public

    {

        // ��������

        address _customerAddress = msg.sender;

        // ���Զ���˹��BTFO

        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        uint256 _tokens = _amountOfTokens;

        uint256 _ethereum = tokensToEthereum_(_tokens);

        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);

        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        

        // �����ѳ��۵Ĵ���

        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

        

        // ���¹�Ϣϵͳ

        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));

        payoutsTo_[_customerAddress] -= _updatedPayouts;       

        

        // ��ֹ����0

        if (tokenSupply_ > 0) {

            // ���´��ҵĹ�Ϣ���

            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

        }

        

        // �ش��¼�

        onTokenSell(_customerAddress, _tokens, _taxedEthereum);

    }

    

    

    /**

     * ���������˻�ת�ƴ����³������˻���

     * ��ס�����ﻹ��10%�ķ��á�

     */

    function transfer(address _toAddress, uint256 _amountOfTokens)

        onlyBagholders()

        public

        returns(bool)

    {

        // ����

        address _customerAddress = msg.sender;

        

        // ȡ��ӵ���㹻�Ĵ���

        // ���ҽ�ֹת�ƣ�ֱ������׶ν�����

        // �����ǲ��벶����

        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        

        // ȡ������δ���Ĺ�Ϣ

        if(myDividends(true) > 0) withdraw();

        

        // ��ת�ƴ��ҵ�ʮ��֮һ

        // ��Щ����ƽ�ָ����ɶ�

        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);

        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);

        uint256 _dividends = tokensToEthereum_(_tokenFee);

  

        // ���ٷ��ô���

        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);



        // ���ҽ���

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

        

        // ���¹�Ϣϵͳ

        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);

        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);

        

        // �ַ���Ϣ��������

        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

        

        // �ش��¼�

        Transfer(_customerAddress, _toAddress, _taxedTokens);

        

        // ERC20��׼

        return true;

       

    }

    

    /*----------  ����Ա����  ----------*/

    /**

     * ���û������������Ա������ǰ��������׶Ρ�

     */

    function disableInitialStage()

        onlyAdministrator()

        public

    {

        onlyAmbassadors = false;

    }

    

    /**

     * ��������������Ը�������Ա�˻���

     */

    function setAdministrator(bytes32 _identifier, bool _status)

        onlyAdministrator()

        public

    {

        administrators[_identifier] = _status;

    }

    

    /**

     * ��ΪԤ����ʩ������Ա���Ե������ڵ�ķ��ʡ�

     */

    function setStakingRequirement(uint256 _amountOfTokens)

        onlyAdministrator()

        public

    {

        stakingRequirement = _amountOfTokens;

    }

    

    /**

     * ����Ա�������¶���Ʒ�ƣ��������ƣ���

     */

    function setName(string _name)

        onlyAdministrator()

        public

    {

        name = _name;

    }

    

    /**

     * ����Ա�������¶���Ʒ�ƣ����ҷ��ţ���

     */

    function setSymbol(string _symbol)

        onlyAdministrator()

        public

    {

        symbol = _symbol;

    }



    

    /*----------  �����ߺͼ�����  ----------*/

    /**

     * �ں�Լ�в鿴��ǰ��̫��״̬�ķ���

     * ���� totalEthereumBalance()

     */

    function totalEthereumBalance() // �鿴���

        public

        view

        returns(uint)

    {

        return this.balance;

    }

    

    /**

     * �������ҹ�Ӧ������

     */

    function totalSupply()

        public

        view

        returns(uint256)

    {

        return tokenSupply_;

    }

    

    /**

     * ���������ߵĴ�����

     */

    function myTokens()

        public

        view

        returns(uint256)

    {

        address _customerAddress = msg.sender; // ��÷����ߵĵ�ַ

        return balanceOf(_customerAddress);

    }

    

    /**

     * ȡ��������ӵ�еĹ�Ϣ��

     * ���`_includeReferralBonus` ��ֵΪ1����ô�Ƽ����𽫱��������ڡ�

     * ��ԭ���ǣ�����ҳ��ǰ�ˣ�����ϣ���õ�ȫ�ֻ��ܡ�

     * �����ڲ������У�����ϣ���ֿ����㡣

     */ 

    function myDividends(bool _includeReferralBonus) // ���طֺ���������Ĳ�������ָʾ�Ƿ����Ƽ��ֺ�

        public 

        view 

        returns(uint256)

    {

        address _customerAddress = msg.sender;

        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;

    }

    

    /**

     * ���������ַ�Ĵ�����

     */

    function balanceOf(address _customerAddress)

        view

        public

        returns(uint256)

    {

        return tokenBalanceLedger_[_customerAddress];

    }

    

    /**

     * ���������ַ�Ĺ�Ϣ��

     */

    function dividendsOf(address _customerAddress)

        view

        public

        returns(uint256)

    {

        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;

    }

    

    /**

     * ���ش�������ļ۸�

     */

    function sellPrice() 

        public 

        view 

        returns(uint256)

    {

        // ���ǵļ��������ڴ��ҹ�Ӧ������������Ҫ֪����Ӧ����

        if(tokenSupply_ == 0){

            return tokenPriceInitial_ - tokenPriceIncremental_;

        } else {

            uint256 _ethereum = tokensToEthereum_(1e18);

            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );

            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

            return _taxedEthereum;

        }

    }

    

    /**

     * ���ش��������ļ۸�

     */

    function buyPrice() 

        public 

        view 

        returns(uint256)

    {

        // ���ǵļ��������ڴ��ҹ�Ӧ������������Ҫ֪����Ӧ����

        if(tokenSupply_ == 0){

            return tokenPriceInitial_ + tokenPriceIncremental_;

        } else {

            uint256 _ethereum = tokensToEthereum_(1e18);

            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );

            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);

            return _taxedEthereum;

        }

    }

    

    /**

     * ǰ�˹��ܣ���̬��ȡ���붩���۸�

     */

    function calculateTokensReceived(uint256 _ethereumToSpend) 

        public 

        view 

        returns(uint256)

    {

        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);

        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

        

        return _amountOfTokens;

    }

    

    /**

     * ǰ�˹��ܣ���̬��ȡ���������۸�

     */

    function calculateEthereumReceived(uint256 _tokensToSell) 

        public 

        view 

        returns(uint256)

    {

        require(_tokensToSell <= tokenSupply_);

        uint256 _ethereum = tokensToEthereum_(_tokensToSell);

        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);

        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        return _taxedEthereum;

    }

    

    

    /*==========================================

    =            INTERNAL FUNCTIONS  �ڲ�����   =

    ==========================================*/

    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)

        antiEarlyWhale(_incomingEthereum)

        internal

        returns(uint256)

    {

        // ��������

        address _customerAddress = msg.sender;

        uint256 _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);

        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);

        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);

        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

        uint256 _fee = _dividends * magnitude;

 

        // ��ֹ����ִ��

        // ��ֹ���

        // (��ֹ�ڿ�����)

        // ����SAFEMATH��֤���ݰ�ȫ��

        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

        

        // �û��Ƿ����ڵ����ã�

        if(

            // �Ƿ����Ƽ��ߣ�

            _referredBy != 0x0000000000000000000000000000000000000000 &&



            // ��ֹ����!

            _referredBy != _customerAddress && // �����Լ��Ƽ��Լ�

            

            // �Ƽ����Ƿ����㹻�Ĵ��ң�

            // ȷ���Ƽ����ǳ�ʵ�����ڵ�

            tokenBalanceLedger_[_referredBy] >= stakingRequirement

        ){

            // �Ƹ��ٷ���

            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);

        } else {

            // ���蹺��

            // ����Ƽ�������ȫ�ַֺ�

            _dividends = SafeMath.add(_dividends, _referralBonus); // ���Ƽ����������ֺ�

            _fee = _dividends * magnitude;

        }

        

        // ���ǲ��ܸ����޾�����̫��

        if(tokenSupply_ > 0){

            

            // ��Ӵ��ҵ����ҳ�

            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

 

            // ��ȡ��ʽ�������õĹ�Ϣ������ƽ����������йɶ�

            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

            

            // �����û�ͨ�������õĴ��������� 

            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));

        

        } else {

            // ��Ӵ��ҵ����ҳ�

            tokenSupply_ = _amountOfTokens;

        }

        

        // ���´��ҹ�Ӧ�������û���ַ

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        

        // ��������˫����ӵ�д���ǰ�����÷ֺ죻

        // ��֪������Ϊ�����ˣ�������û������

        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);

        payoutsTo_[_customerAddress] += _updatedPayouts;

        

        // �ش��¼�

        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);

        

        return _amountOfTokens;

    }



    /**

     * ͨ����̫����������������Ҽ۸�

     * ����һ���㷨���ڰ�Ƥ�������ҵ����Ŀ�ѧ�㷨��

     * ����һЩ�޸ģ��Է�ֹʮ���ƴ���ʹ�������������

     */

    function ethereumToTokens_(uint256 _ethereum) // ����ETH�һ����ҵĻ���

        internal

        view

        returns(uint256)

    {

        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;

        uint256 _tokensReceived = 

         (

            (

                // �����������

                SafeMath.sub(

                    (sqrt

                        (

                            (_tokenPriceInitial**2)

                            +

                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))

                            +

                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))

                            +

                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)

                        )

                    ), _tokenPriceInitial

                )

            )/(tokenPriceIncremental_)

        )-(tokenSupply_)

        ;

  

        return _tokensReceived;

    }

    

    /**

     * ������ҳ��۵ļ۸�

     * ����һ���㷨���ڰ�Ƥ�������ҵ����Ŀ�ѧ�㷨��

     * ����һЩ�޸ģ��Է�ֹʮ���ƴ���ʹ�������������

     */

     function tokensToEthereum_(uint256 _tokens)

        internal

        view

        returns(uint256)

    {



        uint256 tokens_ = (_tokens + 1e18);

        uint256 _tokenSupply = (tokenSupply_ + 1e18);

        uint256 _etherReceived =

        (

            // underflow attempts BTFO

            SafeMath.sub(

                (

                    (

                        (

                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))

                        )-tokenPriceIncremental_

                    )*(tokens_ - 1e18)

                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2

            )

        /1e18);

        return _etherReceived;

    }

    

    

    //���������Gas

    //���Ż������1gwei

    function sqrt(uint x) internal pure returns (uint y) {

        uint z = (x + 1) / 2;

        y = x;

        while (z < y) {

            y = z;

            z = (x / z + z) / 2;

        }

    }

}



/**

 * @title SafeMath����

 * @dev ��ȫ����ѧ����

 */

library SafeMath {



    /**

    * @dev �������ֳ˷����׳������

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev �������ֵ�����������

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // ֵΪ0ʱ�Զ��׳�

        uint256 c = a / b;

        // assert(a == b * c + a % b); // ���򲻳���

        return c;

    }



    /**

    * @dev �������ֵļ���������������ڱ�������������׳���

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev �������ֵļӷ�����������׳�

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}