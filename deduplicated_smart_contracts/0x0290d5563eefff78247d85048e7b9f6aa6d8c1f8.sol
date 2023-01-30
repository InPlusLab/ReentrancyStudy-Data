pragma solidity ^0.4.18;

contract DogCoreInterface {
    address public ceoAddress;
    address public cfoAddress;
    function getDog(uint256 _id)
        external
        view
        returns (
        //��ȴ��������
        uint256 cooldownIndex,
        //������ȴ�ڽ�����������
        uint256 nextActionAt,
        //���ֵĹ���ID
        uint256 siringWithId,
        //����ʱ��
        uint256 birthTime,
        //ĸ��ID
        uint256 matronId,
        //����ID
        uint256 sireId,
        //����
        uint256 generation,
        //����
        uint256 genes,
        //���죬0��ʾδ���죬1-7��ʾ����
        uint8  variation,
        //0�����ȵ�ID
        uint256 gen0
    );
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function sendMoney(address _to, uint256 _money) external;
    function totalSupply() external view returns (uint);
}


/*
    LotteryBase ��Ҫ�����˿�����Ϣ�������ת�뺯���Լ��ж��Ƿ񿪱���
*/
contract LotteryBase {
    
    // ��ǰ��������λ��
    uint8 public currentGene;
    // ��ǰ������������
    uint256 public lastBlockNumber;
    // ���������
    uint256 randomSeed = 1;
    // ����ص�ַ
    address public bonusPool;
    // �н���Ϣ
    struct CLottery {
        // �����н�����
        uint8[7]        luckyGenes;
        // ���ڽ�����ܶ�
        uint256         totalAmount;
        // ���ڵ�7�����򿪽���������
        uint256         openBlock;
        // �Ƿ񷢽����
        bool            isReward;
        // δ��һ�Ƚ����
        bool         noFirstReward;
    }
    // ��ʷ������Ϣ
    CLottery[] public CLotteries;
    // ������Լ��ַ
    address public finalLottery;
    // ��ؽ��
    uint256 public SpoolAmount = 0;
    // ������Ϣ�ӿ�
    DogCoreInterface public dogCore;
    // ��������¼�
    event OpenLottery(uint8 currentGene, uint8 luckyGenes, uint256 currentTerm, uint256 blockNumber, uint256 totalAmount);
    //���п����¼�
    event OpenCarousel(uint256 luckyGenes, uint256 currentTerm, uint256 blockNumber, uint256 totalAmount);
    
    
    //
    modifier onlyCEO() {
        require(msg.sender == dogCore.ceoAddress());
        _;  
    }
    //
    modifier onlyCFO() {
        require(msg.sender == dogCore.cfoAddress());
        _;  
    }
    /*
        ���ת�뽱��غ���
    */
    function toLotteryPool(uint amount) public onlyCFO {
        require(SpoolAmount >= amount);
        SpoolAmount -= amount;
    }
    /*
    �жϵ����Ƿ񿪱���
    */
    function _isCarousal(uint256 currentTerm) external view returns(bool) {
       return (currentTerm > 1 && CLotteries[currentTerm - 2].noFirstReward && CLotteries[currentTerm - 1].noFirstReward); 
    }
    
    /*
      ���ص�ǰ����
    */ 
    function getCurrentTerm() external view returns (uint256) {

        return (CLotteries.length - 1);
    }
}


/*
    LotteryGenes��Ҫʵ�ֽ�����ԭʼ����ת��Ϊ�ҽ�����
*/
contract LotteryGenes is LotteryBase {
    /*
     ���������ָ�ʽת��Ϊ�齱�����ʽ
    */
    function convertGeneArray(uint256 gene) public pure returns(uint8[7]) {
        uint8[28] memory geneArray; 
        uint8[7] memory lotteryArray;
        uint index = 0;
        for (index = 0; index < 28; index++) {
            uint256 geneItem = gene % (2 ** (5 * (index + 1)));
            geneItem /= (2 ** (5 * index));
            geneArray[index] = uint8(geneItem);
        }
        for (index = 0; index < 7; index++) {
            uint size = 4 * index;
            lotteryArray[index] = geneArray[size];
            
        }
        return lotteryArray;
    }

    /**
       �����Ի���ƴ�ճ�ԭʼ��������
    */ 
    function convertGene(uint8[7] luckyGenes) public pure returns(uint256) {
        uint8[28] memory geneArray;
        for (uint8 i = 0; i < 28; i++) {
            if (i%4 == 0) {
                geneArray[i] = luckyGenes[i/4];
            } else {
                geneArray[i] = 6;
            }
        }
        uint256 gene = uint256(geneArray[0]);
        
        for (uint8 index = 1; index < 28; index++) {
            uint256 geneItem = uint256(geneArray[index]);
            gene += geneItem << (index * 5);
        }
        return gene;
    }
}


/*
    SetLottery��Ҫʵ������������ͱ��п���
*/
contract SetLottery is LotteryGenes {

    function random(uint8 seed) internal returns(uint8) {
        randomSeed = block.timestamp;
        return uint8(uint256(keccak256(randomSeed, block.difficulty))%seed)+1;
    }

    /*
     �������������ÿһ�ڿ�7�Ρ�
     currentGene��ʾ���ڿ����ĵ�N������
     ����ǰcurrentGeneָ��Ϊ0�����ʾ�ڿ�����δ���κ����֣����߿������Ѿ���������������
     ��ǰ���������һ��������󣬼�¼��ǰ��������ź͵�ǰ����ؽ��
     ����ֵ�ֱ�Ϊ��ǰ��������(0��������)����ѯ��������(0��������)��
     ����״̬(0��ʾ�����ɹ���1��ʾ���ڿ����������ڵȴ�������2��ʾ��ǰ���򿪽��������ϸ����򿪽�������ͬ,3��ʾ����ؽ���)
     */
    function openLottery(uint8 _viewId) public returns(uint8,uint8) {
        uint8 viewId = _viewId;
        require(viewId < 7);
        // ��ȡ��ǰ�н���Ϣ
        uint256 currentTerm = CLotteries.length - 1;
        CLottery storage clottery = CLotteries[currentTerm];

        // ���7��������ɿ������ҵ���û�з�������˵���������л����Ѿ���������ڵȴ��������˳�
        if (currentGene == 0 && clottery.openBlock > 0 && clottery.isReward == false) {
            // �����¼������ز�ѯ�Ļ���
            OpenLottery(viewId, clottery.luckyGenes[viewId], currentTerm, 0, 0);
            //�ֱ𷵻ز�ѯ����״̬1 (��ʾ�������л��򿪽�����ڵȴ�����)
            return (clottery.luckyGenes[viewId],1);
        }
        // ����ϸ����򿪽��ͱ��ο�����ͬһ�����飬�˳�
        if (lastBlockNumber == block.number) {
            // �����¼������ز�ѯ�Ļ���
            OpenLottery(viewId, clottery.luckyGenes[viewId], currentTerm, 0, 0);
            //�ֱ𷵻ز�ѯ����״̬2 (��ǰ���򿪽��������ϸ����򿪽�������ͬ)
            return (clottery.luckyGenes[viewId],2);
        }
        // �����ǰ��������λΪ0�ҵ����Ѿ��������������һ�ڿ���
        if (currentGene == 0 && clottery.isReward == true) {
            // ��ʼ����ǰlottery��Ϣ
            CLottery memory _clottery;
            _clottery.luckyGenes = [0,0,0,0,0,0,0];
            _clottery.totalAmount = uint256(0);
            _clottery.isReward = false;
            _clottery.openBlock = uint256(0);
            currentTerm = CLotteries.push(_clottery) - 1;
        }

        // ���ǰ���ڶ�û��һ�Ƚ�����������ڲ������н����˳������������
        if (this._isCarousal(currentTerm)) {
            revert();
        }

        //�������
        uint8 luckyNum = 0;
        
        if (currentGene == 6) {
            // �������ؽ��Ϊ�㣬���˳�
            if (bonusPool.balance <= SpoolAmount) {
                // �����¼������ز�ѯ�Ļ���
                OpenLottery(viewId, clottery.luckyGenes[viewId], currentTerm, 0, 0);
                //�ֱ𷵻ز�ѯ����״̬3 (����ؽ���)
                return (clottery.luckyGenes[viewId],3);
            }
            //���������ֵ����ǰ����
            luckyNum = random(8);
            CLotteries[currentTerm].luckyGenes[currentGene] = luckyNum;
            //���������¼�
            OpenLottery(currentGene, luckyNum, currentTerm, block.number, bonusPool.balance);
            //�����ǰΪ���һ��������������һ����������λΪ0��ͬʱ��¼�µ�ǰ����Ų�д�뿪����Ϣ��ͬʱ������ؽ��д�뿪����Ϣ, ͬʱ��������Լ
            currentGene = 0;
            CLotteries[currentTerm].openBlock = block.number;
            CLotteries[currentTerm].totalAmount = bonusPool.balance;
            //��¼��ǰ������������
            lastBlockNumber = block.number;
        } else { 
            //���������ֵ����ǰ����
        
            luckyNum = random(12);
            CLotteries[currentTerm].luckyGenes[currentGene] = luckyNum;

            //���������¼�
            OpenLottery(currentGene, luckyNum, currentTerm, 0, 0);
            //��������£���һ����������λ��1
            currentGene ++;
            //��¼��ǰ������������
            lastBlockNumber = block.number;
        }
        //�ֱ𷵻ؿ������򣬲�ѯ����Ϳ����ɹ�״̬
        return (luckyNum,0);
    } 

    function random2() internal view returns (uint256) {
        return uint256(uint256(keccak256(block.timestamp, block.difficulty))%uint256(dogCore.totalSupply()) + 1);
    }

    /*
     ���п�������,ÿ�ڿ�һ��
    */
    function openCarousel() public {
        //��ȡ��ǰ������Ϣ
        uint256 currentTerm = CLotteries.length - 1;
        CLottery storage clottery = CLotteries[currentTerm];

        // �����ǰ��������ָ��Ϊ0�ҿ���������ڣ���δ��������˵����ǰ���򿪽���ϣ��ڵȴ�����
        if (currentGene == 0 && clottery.openBlock > 0 && clottery.isReward == false) {

            //���������¼�,���ص������п�������
            OpenCarousel(convertGene(clottery.luckyGenes), currentTerm, clottery.openBlock, clottery.totalAmount);
        }

        // �����������ָ��Ϊ0�ҿ���������ڣ����ҷ�����ϣ��������һ��������
        if (currentGene == 0 && clottery.openBlock > 0 && clottery.isReward == true) {
            CLottery memory _clottery;
            _clottery.luckyGenes = [0,0,0,0,0,0,0];
            _clottery.totalAmount = uint256(0);
            _clottery.isReward = false;
            _clottery.openBlock = uint256(0);
            currentTerm = CLotteries.push(_clottery) - 1;
        }

        //��������3 ��ǰ����δ�����صȽ�
        require (this._isCarousal(currentTerm));
        // �����ȡ���л���
        uint256 genes = _getValidRandomGenes();
        require (genes > 0);
        uint8[7] memory luckyGenes = convertGeneArray(genes);
        //���������¼�
        OpenCarousel(genes, currentTerm, block.number, bonusPool.balance);

        //д���¼
        CLotteries[currentTerm].luckyGenes = luckyGenes;
        CLotteries[currentTerm].openBlock = block.number;
        CLotteries[currentTerm].totalAmount = bonusPool.balance;
        
    }
    
    /*
      �����ȡ�Ϸ��ı��л���
    */
    function _getValidRandomGenes() internal view returns (uint256) {
        uint256 luckyDog = random2();
        uint256 genes = _validGenes(luckyDog);
        uint256 totalSupply = dogCore.totalSupply();
        if (genes > 0) {
            return genes;
        }  
        // ���dog���ܶҽ����򽥽����ж�����dog�Ƿ���������
        uint256 min = (luckyDog < totalSupply-luckyDog) ? (luckyDog - 1) : totalSupply-luckyDog;
        for (uint256 i = 1; i < min + 1; i++) {
            genes = _validGenes(luckyDog - i);
            if (genes > 0) {
                break;
            }
            genes = _validGenes(luckyDog + i);
            if (genes > 0) {
                    break;
                }
            }
            // min������Ȼδ�ҵ��ɶҽ�����
        if (genes == 0) {
            //luckyDog�Ҳ����
            if (min == luckyDog - 1) {
                for (i = min + luckyDog; i < totalSupply + 1; i++) {
                        genes = _validGenes(i);
                        if (genes > 0) {
                            break;
                        }
                    }   
                }
            //luckyDog������
            if (min == totalSupply - luckyDog) {
                for (i = min; i < luckyDog; i++) {
                        genes = _validGenes(luckyDog - i - 1);
                        if (genes > 0) {
                            break;
                        }
                    }   
                }
            }
        return genes;
    }


    /*
      �жϹ��Ƿ��ܶҽ�������ֱ�ӷ��ع��Ļ��򣬲����򷵻�0
    */
    function _validGenes(uint256 dogId) internal view returns (uint256) {

        var(, , , , , ,generation, genes, variation,) = dogCore.getDog(dogId);
        if (generation == 0 || dogCore.ownerOf(dogId) == finalLottery || variation > 0) {
            return 0;
        } else {
            return genes;
        }
    }

    
}

/*
  LotteryCore�ǿ�����������ں�Լ
  �����������п������������
  ͬʱLotteryCore�ṩ�����ѯ�ӿ�
*/

contract LotteryCore is SetLottery {
    
    // ���캯�������뽱��ص�ַ,��ʼ���н���Ϣ
    function LotteryCore(address _ktAddress) public {

        bonusPool = _ktAddress;
        dogCore = DogCoreInterface(_ktAddress);

        //��ʼ���н���Ϣ
        CLottery memory _clottery;
        _clottery.luckyGenes = [0,0,0,0,0,0,0];
        _clottery.totalAmount = uint256(0);
        _clottery.isReward = false;
        _clottery.openBlock = uint256(0);
        CLotteries.push(_clottery);
    }
    /*
    ����FinalLottery��ַ
    */
    function setFinalLotteryAddress(address _flAddress) public onlyCEO {
        finalLottery = _flAddress;
    }
    /*
    ��ȡ��ǰ�н���¼
    */
    function getCLottery() 
        public 
        view 
        returns (
            uint8[7]        luckyGenes,
            uint256         totalAmount,
            uint256         openBlock,
            bool            isReward,
            uint256         term
        ) {
            term = CLotteries.length - uint256(1);
            luckyGenes = CLotteries[term].luckyGenes;
            totalAmount = CLotteries[term].totalAmount;
            openBlock = CLotteries[term].openBlock;
            isReward = CLotteries[term].isReward;
    }

    /*
    ���ķ���״̬
    */
    function rewardLottery(bool isMore) external {
        // require contract address is final lottery
        require(msg.sender == finalLottery);

        uint256 term = CLotteries.length - 1;
        CLotteries[term].isReward = true;
        CLotteries[term].noFirstReward = isMore;
    }

    /*
    ת�����
    */
    function toSPool(uint amount) external {
        // require contract address is final lottery
        require(msg.sender == finalLottery);

        SpoolAmount += amount;
    }
}


/*
    FinalLottery �����ҽ������ͷ�������
    �н���Ϣflotteries���뿪��������[���Ƚ����ߣ����Ƚ��н����]��ӳ��
*/
contract FinalLottery {
    bool public isLottery = true;
    LotteryCore lotteryCore;
    DogCoreInterface dogCore;
    uint8[7] public luckyGenes;
    uint256         totalAmount;
    uint256         openBlock;
    bool            isReward;
    uint256         currentTerm;
    uint256  public duration;
    uint8   public  lotteryRatio;
    uint8[7] public lotteryParam;
    uint8   public  carousalRatio;
    uint8[7] public carousalParam; 
    // �н���Ϣ
    struct FLottery {
        //  ���ڸ��Ƚ�����
        //  һ�Ƚ�
        address[]        owners0;
        uint256[]        dogs0;
        //  ���Ƚ�
        address[]        owners1;
        uint256[]        dogs1;
        //  ���Ƚ�
        address[]        owners2;
        uint256[]        dogs2;
        //  �ĵȽ�
        address[]        owners3;
        uint256[]        dogs3;
        //  ��Ƚ�
        address[]        owners4;
        uint256[]        dogs4;
        //  ���Ƚ�
        address[]        owners5;
        uint256[]        dogs5;
        //  �ߵȽ�
        address[]        owners6;
        uint256[]        dogs6;
        // �н����
        uint256[]       reward;
    }
    // �ҽ�������Ϣ
    mapping(uint256 => FLottery) flotteries;
    // ���캯��
    function FinalLottery(address _lcAddress) public {
        lotteryCore = LotteryCore(_lcAddress);
        dogCore = DogCoreInterface(lotteryCore.bonusPool());
        duration = 11520;
        lotteryRatio = 23;
        lotteryParam = [46,16,10,9,8,6,5];
        carousalRatio = 12;
        carousalParam = [35,18,14,12,8,7,6];
        
    }
    
    // �����¼�
    event DistributeLottery(uint256[] rewardArray, uint256 currentTerm);
    // �ҽ��¼�
    event RegisterLottery(uint256 dogId, address owner, uint8 lotteryClass, string result);
    // ���öҽ�����
    function setLotteryDuration(uint256 durationBlocks) public {
        require(msg.sender == dogCore.ceoAddress());
        require(durationBlocks > 140);
        require(durationBlocks < block.number);
        duration = durationBlocks;
    }
    /*
     �ǼǶҽ�����,�����ڵ��ڿ�������֮��7���ڣ���40��320�������ڣ�
    */
    function registerLottery(uint256 dogId) public returns (uint8) {
        uint256 _dogId = dogId;
        (luckyGenes, totalAmount, openBlock, isReward, currentTerm) = lotteryCore.getCLottery();
        // ��ȡ��ǰ������Ϣ
        address owner = dogCore.ownerOf(_dogId);
        // ���յĲ��ܶҽ�
        require (owner != address(this));
        // �����߱���������Լ
        require(address(dogCore) == msg.sender);
        // ���л���λ������ϣ�ָ��Ϊ0ͬʱ����ش���0����δ������δ�ҽ�����
        require(totalAmount > 0 && isReward == false && openBlock > (block.number-duration));
        // ��ȡ�ó���Ļ��򣬴���������ʱ��
        var(, , , birthTime, , ,generation,genes, variation,) = dogCore.getDog(_dogId);
        // ��������С�ڿ���ʱ��
        require(birthTime < openBlock);
        // 0�������ܶҽ�
        require(generation > 0);
        // ����Ĳ��ܶҽ�
        require(variation == 0);
        // �жϸ��û��񼸵Ƚ���100��ʾδ�н�
        uint8 _lotteryClass = getLotteryClass(luckyGenes, genes);
        // ��δ�����˳�
        require(_lotteryClass < 7);
        // �����ظ��ҽ�
        address[] memory owners;
        uint256[] memory dogs;
         (dogs, owners) = _getLuckyList(currentTerm, _lotteryClass);
            
        for (uint i = 0; i < dogs.length; i++) {
            if (_dogId == dogs[i]) {
            //    revert();
                RegisterLottery(_dogId, owner, _lotteryClass,"dog already registered");
                 return 5;
            }
        }
        // ���Ǽ��н��ߵ��˻����뽱����Ϣ��
        _pushLuckyInfo(currentTerm, _lotteryClass, owner, _dogId);
        // �����ҽ��ɹ��¼�
        RegisterLottery(_dogId, owner, _lotteryClass,"successful");
        return 0;
    }
    /*
    ���������������ڵ��ڿ�������֮��
    */
    
    function distributeLottery() public returns (uint8) {
        (luckyGenes, totalAmount, openBlock, isReward, currentTerm) = lotteryCore.getCLottery();
        
        // �����ڵ��ڿ�������һ��֮�󷢽�
        require(openBlock > 0 && openBlock < (block.number-duration));

        //����ؿ��ý�������ڻ����0
        require(totalAmount >= lotteryCore.SpoolAmount());

        // ����Ѿ�����
        if (isReward == true) {
            DistributeLottery(flotteries[currentTerm].reward, currentTerm);
            return 1;
        }
        uint256 legalAmount = totalAmount - lotteryCore.SpoolAmount();
        uint256 totalDistribute = 0;
        uint8[7] memory lR;
        uint8 ratio;

        // ���к�������ֲ�ͬ�Ľ���������
        if (lotteryCore._isCarousal(currentTerm) ) {
            lR = carousalParam;
            ratio = carousalRatio;
        } else {
            lR = lotteryParam;
            ratio = lotteryRatio;
        }
        // �����������ַ����н���
        for (uint8 i = 0; i < 7; i++) {
            address[] memory owners;
            uint256[] memory dogs;
            (dogs, owners) = _getLuckyList(currentTerm, i);
            if (owners.length > 0) {
                    uint256 reward = (legalAmount * ratio * lR[i])/(10000 * owners.length);
                    totalDistribute += reward * owners.length;
                    // ת��CFO�������ѣ�10%��
                    dogCore.sendMoney(dogCore.cfoAddress(),reward * owners.length/10);
                    
                    for (uint j = 0; j < owners.length; j++) {
                        address gen0Add;
                        if (i == 0) {
                            // ת��
                            dogCore.sendMoney(owners[j],reward*95*9/1000);
                            // gen0 ����
                            gen0Add = _getGen0Address(dogs[j]);
                            assert(gen0Add != address(0));
                            dogCore.sendMoney(gen0Add,reward*5/100);
                        } else if (i == 1) {
                            // ת��
                            dogCore.sendMoney(owners[j],reward*97*9/1000);
                            // gen0 ����
                            gen0Add = _getGen0Address(dogs[j]);
                            assert(gen0Add != address(0));
                            dogCore.sendMoney(gen0Add,reward*3/100);
                        } else if (i == 2) {
                            // ת��
                            dogCore.sendMoney(owners[j],reward*98*9/1000);
                            // gen0 ����
                            gen0Add = _getGen0Address(dogs[j]);
                            assert(gen0Add != address(0));
                            dogCore.sendMoney(gen0Add,reward*2/100);
                        } else {
                            // ת��
                            dogCore.sendMoney(owners[j],reward*9/10);
                        }
                    }
                  // ��¼���Ƚ��������
                    flotteries[currentTerm].reward.push(reward);  
                } else {
                    flotteries[currentTerm].reward.push(0); 
                } 
        }
        //û���˵Ǽ�һ�Ƚ��н����������5%ת�����,���Ҹ�����һ�Ƚ�����
        if (flotteries[currentTerm].owners0.length == 0) {
            lotteryCore.toSPool((lotteryCore.bonusPool().balance - lotteryCore.SpoolAmount())/20);
            lotteryCore.rewardLottery(true);
        } else {
            //�������֮�󣬸��µ�ǰ����״̬������ǰ���������ʷ��¼
            lotteryCore.rewardLottery(false);
        }
        
        DistributeLottery(flotteries[currentTerm].reward, currentTerm);
        return 0;
    }

     /*
    ��ȡ����gen0���ȵ������˻�
    */
    function _getGen0Address(uint256 dogId) internal view returns(address) {
        var(, , , , , , , , , gen0) = dogCore.getDog(dogId);
        return dogCore.ownerOf(gen0);
    }

    /*
      ͨ������ȼ���ȡ�н����б���н����б�
    */
    function _getLuckyList(uint256 currentTerm1, uint8 lotclass) public view returns (uint256[] kts, address[] ons) {
        if (lotclass==0) {
            ons = flotteries[currentTerm1].owners0;
            kts = flotteries[currentTerm1].dogs0;
        } else if (lotclass==1) {
            ons = flotteries[currentTerm1].owners1;
            kts = flotteries[currentTerm1].dogs1;
        } else if (lotclass==2) {
            ons = flotteries[currentTerm1].owners2;
            kts = flotteries[currentTerm1].dogs2;
        } else if (lotclass==3) {
            ons = flotteries[currentTerm1].owners3;
            kts = flotteries[currentTerm1].dogs3;
        } else if (lotclass==4) {
            ons = flotteries[currentTerm1].owners4;
            kts = flotteries[currentTerm1].dogs4;
        } else if (lotclass==5) {
            ons = flotteries[currentTerm1].owners5;
            kts = flotteries[currentTerm1].dogs5;
        } else if (lotclass==6) {
            ons = flotteries[currentTerm1].owners6;
            kts = flotteries[currentTerm1].dogs6;
        }
    }

    /*
      ��owner��dogId�����н���Ϣ�洢
    */
    function _pushLuckyInfo(uint256 currentTerm1, uint8 _lotteryClass, address owner, uint256 _dogId) internal {
        if (_lotteryClass == 0) {
            flotteries[currentTerm1].owners0.push(owner);
            flotteries[currentTerm1].dogs0.push(_dogId);
        } else if (_lotteryClass == 1) {
            flotteries[currentTerm1].owners1.push(owner);
            flotteries[currentTerm1].dogs1.push(_dogId);
        } else if (_lotteryClass == 2) {
            flotteries[currentTerm1].owners2.push(owner);
            flotteries[currentTerm1].dogs2.push(_dogId);
        } else if (_lotteryClass == 3) {
            flotteries[currentTerm1].owners3.push(owner);
            flotteries[currentTerm1].dogs3.push(_dogId);
        } else if (_lotteryClass == 4) {
            flotteries[currentTerm1].owners4.push(owner);
            flotteries[currentTerm1].dogs4.push(_dogId);
        } else if (_lotteryClass == 5) {
            flotteries[currentTerm1].owners5.push(owner);
            flotteries[currentTerm1].dogs5.push(_dogId);
        } else if (_lotteryClass == 6) {
            flotteries[currentTerm1].owners6.push(owner);
            flotteries[currentTerm1].dogs6.push(_dogId);
        }
    }

    /*
      ���û���񽱵ȼ�
    */
    function getLotteryClass(uint8[7] luckyGenesArray, uint256 genes) internal view returns(uint8) {
        // �����ڿ�����Ϣ,��ֱ�ӷ���δ�н�
        if (currentTerm < 0) {
            return 100;
        }
        
        uint8[7] memory dogArray = lotteryCore.convertGeneArray(genes);
        uint8 cnt = 0;
        uint8 lnt = 0;
        for (uint i = 0; i < 6; i++) {

            if (luckyGenesArray[i] > 0 && luckyGenesArray[i] == dogArray[i]) {
                cnt++;
            }
        }
        if (luckyGenesArray[6] > 0 && luckyGenesArray[6] == dogArray[6]) {
            lnt = 1;
        }
        uint8 lotclass = 100;
        if (cnt==6 && lnt==1) {
            lotclass = 0;
        } else if (cnt==6 && lnt==0) {
            lotclass = 1;
        } else if (cnt==5 && lnt==1) {
            lotclass = 2;
        } else if (cnt==5 && lnt==0) {
            lotclass = 3;
        } else if (cnt==4 && lnt==1) {
            lotclass = 4;
        } else if (cnt==3 && lnt==1) {
            lotclass = 5;
        } else if (cnt==3 && lnt==0) {
            lotclass = 6;
        } else {
            lotclass = 100;
        }
        return lotclass;
    }
    /*
       ���û���񽱵ȼ��ӿ�
    */
    function checkLottery(uint256 genes) public view returns(uint8) {
        var(luckyGenesArray, , , isReward1, ) = lotteryCore.getCLottery();
        if (isReward1) {
            return 100;
        }
        return getLotteryClass(luckyGenesArray, genes);
    }
    /*
       ��ȡ��ǰLottery��Ϣ
    */
    function getCLottery() 
        public 
        view 
        returns (
            uint8[7]        luckyGenes1,
            uint256         totalAmount1,
            uint256         openBlock1,
            bool            isReward1,
            uint256         term1,
            uint8           currentGenes1,
            uint256         tSupply,
            uint256         sPoolAmount1,
            uint256[]       reward1
        ) {
            (luckyGenes1, totalAmount1, openBlock1, isReward1, term1) = lotteryCore.getCLottery();
            currentGenes1 = lotteryCore.currentGene();
            tSupply = dogCore.totalSupply();
            sPoolAmount1 = lotteryCore.SpoolAmount();
            reward1 = flotteries[term1].reward;
    }
    
}