pragma solidity ^0.4.22;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    *               ���s��һ�rֹͣ����Ƥ�����ϤˤΤߥ����������S�ɤ���
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    *               ���s��һ�rֹͣ����Ƥ��ʤ����ϤˤΤߥ����������S�ɤ���
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    *             һ�rֹͣ���뤿��������ߤˤ�äƺ��ӳ����졢ֹͣ״�B��ȥꥬ����
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    *             �ݩ`����Ȥ뤿��˥��`�ʩ`�����ӳ�����ͨ����״�B�ˑ���ޤ�
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract RocsBase is Pausable {

    // ���Q��
    uint128 public eggPrice = 50 finney;
    function setEggPrice(uint128 _price) public onlyOwner {
        eggPrice = _price;
    }
    // �M����
    uint128 public evolvePrice = 5 finney;
    function setEvolvePrice(uint128 _price) public onlyOwner {
        evolvePrice = _price;
    }

    // ���Q
    event RocCreated(address owner, uint tokenId, uint rocId);
    // ERC721
    event Transfer(address from, address to, uint tokenId);
    event ItemTransfer(address from, address to, uint tokenId);

    /// @dev Roc�Θ�����
    struct Roc {
        // ID
        uint rocId;
        // DNA
        string dna;
        // ��Ʒ�Хե饰 1�ϳ�Ʒ��
        uint8 marketsFlg;
    }

    /// @dev Rocs������
    Roc[] public rocs;

    // rocId��tokenId�Υޥåԥ�
    mapping(uint => uint) public rocIndex;
    // rocId����tokenId��ȡ��
    function getRocIdToTokenId(uint _rocId) public view returns (uint) {
        return rocIndex[_rocId];
    }

    /// @dev ���Ф��륢�ɥ쥹�ؤΥޥåԥ�
    mapping (uint => address) public rocIndexToOwner;
    // @dev �����ߥ��ɥ쥹�������Ф���ȩ`�������ؤΥޥåԥ�
    mapping (address => uint) public ownershipTokenCount;
    /// @dev ���ӳ��������J���줿���ɥ쥹�ؤΥޥåԥ�
    mapping (uint => address) public rocIndexToApproved;

    /// @dev �ض���Roc�����Иؤ򥢥ɥ쥹�˸�굱�Ƥޤ���
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        ownershipTokenCount[_from]--;
        rocIndexToOwner[_tokenId] = _to;
        // ���٥���_ʼ
        emit Transfer(_from, _to, _tokenId);
    }

}

/// @title ERC-721�˜ʒ��������s�Υ��󥿥ե��`�����ä��Q�������ܤʥȩ`����
contract ERC721 {
    // ���٥��
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    // ��Ҫ�ʥ᥽�å�
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) external view returns (address _owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function totalSupply() public view returns (uint);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

/// @title Roc���Иؤ�����륳��ȥ饯��
/// @dev OpenZeppelin��ERC721�ɥ�եȌgװ�˜ʒ�
contract RocsOwnership is RocsBase, ERC721 {

    /// @notice ERC721�Ƕ��x����Ƥ��롢�ä��Q�������ܤʥȩ`�������ǰ��ӛ�š�
    string public constant name = "CryptoFeather";
    string public constant symbol = "CFE";

    bytes4 constant InterfaceSignature_ERC165 = 
    bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('totalSupply()'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  �������s�ˤ�äƌgװ���줿�˜ʻ����줿���󥿥ե��`����true�򷵤��ޤ���
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    /// @dev �ض��Υ��ɥ쥹��ָ�����줿roc�άF�ڤ������ߤǤ��뤫�ɤ���������å����ޤ���
    /// @param _claimant 
    /// @param _tokenId 
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return rocIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev �ض��Υ��ɥ쥹��ָ�����줿roc�����ڤ��뤫�ɤ���������å����ޤ���
    /// @param _claimant the address we are confirming kitten is approved for.
    /// @param _tokenId kitten id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return rocIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev ��ǰ�γ��J���ϕ������ơ�transferFrom�����ˌ����Ƴ��J���줿���ɥ쥹��ީ`�����ޤ���
    function _approve(uint256 _tokenId, address _approved) internal {
        rocIndexToApproved[_tokenId] = _approved;
    }

    // ָ�����줿���ɥ쥹��roc����ȡ�ä��ޤ���
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice roc�������ߤ������ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ
    function transfer(address _to, uint256 _tokenId) public whenNotPaused {
        // ��ȫ�����å�
        require(_to != address(0));
        // �Է֤�roc�����ͤ뤳�ȤϤǤ��ޤ���
        require(_owns(msg.sender, _tokenId));
        // ���Иؤ��ٸ�굱�ơ������Фγ��J�Υ��ꥢ��ܞ�ͥ��٥�Ȥ�����
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice transferFrom������餷�Ƅe�Υ��ɥ쥹���ض���roc��ܞ�ͤ���������뤨�ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ
    function approve(address _to, uint256 _tokenId) external whenNotPaused {
        // �����ߤΤߤ��j�ɳ��J���J��뤳�Ȥ��Ǥ��ޤ���
        require(_owns(msg.sender, _tokenId));
        // ���J����h���ޤ�����ǰ�γ��J���ä��Q���ޤ�����
        _approve(_tokenId, _to);
        // ���J���٥�Ȥ�k�Ф��롣
        emit Approval(msg.sender, _to, _tokenId);
    }

    /// @notice roc�����ߤΉ�����Ф��ޤ�����ܞ�ͤ��ޤ������Υ��ɥ쥹�ˤϡ���ǰ�������ߤ���ܞ�ͳ��J���뤨���Ƥ��ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ
    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
        // ��ȫ�����å���
        require(_to != address(0));
        // ���J���Є������Иؤδ_�J
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        // ���Иؤ��ٸ�굱�Ƥ��ޤ��������Фγ��J�򥯥ꥢ����ܞ�ͥ��٥�Ȥ�k�Ф��ޤ�����
        _transfer(_from, _to, _tokenId);
    }

    /// @notice �F�ڴ��ڤ���roc�ξt���򷵤��ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ�Ǥ���
    function totalSupply() public view returns (uint) {
        return rocs.length - 1;
    }

    /// @notice ָ�����줿roc�άF�����Иؤ���굱�Ƥ��Ƥ��륢�ɥ쥹�򷵤��ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ�Ǥ���
    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = rocIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    /// @dev �������s�����Иؤ��굱�ơ�NFT���ƽK�ˤ��ޤ���
    /// @param _owner 
    /// @param _tokenId 
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        transferFrom(_owner, this, _tokenId);
    }

}

/// @title Roc��������v���������Ф�����ȥ饯��
contract RocsBreeding is RocsOwnership {

    /// @notice �¤���Roc�����ɤ��Ʊ��档 
    /// @param _rocId 
    /// @param _dna 
    /// @param _marketsFlg 
    /// @param _owner 
    /// @dev RocCreated���٥�Ȥ�Transfer���٥�Ȥ΁I�������ɤ��ޤ��� 
    function _createRoc(
        uint _rocId,
        string _dna,
        uint _marketsFlg,
        address _owner
    )
        internal
        returns (uint)
    {
        Roc memory _roc = Roc({
            rocId: _rocId,
            dna: _dna,
            marketsFlg: uint8(_marketsFlg)
        });

        uint newRocId = rocs.push(_roc) - 1;
        // ͬһ�Υȩ`����ID���k���������Ϥόg�Ф�ֹͣ���ޤ�
        require(newRocId == uint(newRocId));
        // RocCreated���٥��
        emit RocCreated(_owner, newRocId, _rocId);

        // ����ˤ�����Иؤ���굱�Ƥ�졢ERC721�ɥ�եȤ��Ȥ�ܞ�ͥ��٥�Ȥ��k�Ф���ޤ�
        rocIndex[_rocId] = newRocId;
        _transfer(0, _owner, newRocId);

        return newRocId;
    }

    /// @notice �¤������߳����ޤ� 
    /// @param _rocId 
    /// @param _dna 
    function giveProduce(uint _rocId, string _dna)
        external
        payable
        whenNotPaused
        returns(uint)
    {
        // ֧�B����_�J���ޤ���
        require(msg.value >= eggPrice);
        uint createRocId = _createRoc(
            _rocId,
            _dna, 
            0, 
            msg.sender
        );
        // ���^�֤��I���֤˷���
        uint256 bidExcess = msg.value - eggPrice;
        msg.sender.transfer(bidExcess);

        return createRocId;
    }

    /// @notice ����Ƥ�Roc 
    /// @param _rocId 
    /// @param _dna 
    function freeGiveProduce(uint _rocId, string _dna)
        external
        payable
        whenNotPaused
        returns(uint)
    {
        // ����Ƥ�Roc���_�J���ޤ���
        require(balanceOf(msg.sender) == 0);
        uint createRocId = _createRoc(
            _rocId,
            _dna, 
            0, 
            msg.sender
        );
        // ���^�֤��I���֤˷���
        uint256 bidExcess = msg.value;
        msg.sender.transfer(bidExcess);

        return createRocId;
    }

}

/// @title Roc�Ή��I�Τ����Markets�I��
contract RocsMarkets is RocsBreeding {

    event MarketsCreated(uint256 tokenId, uint128 marketsPrice);
    event MarketsSuccessful(uint256 tokenId, uint128 marketsPriceice, address buyer);
    event MarketsCancelled(uint256 tokenId);

    // NFT�ϤΥީ`���åȤؤγ�Ʒ
    struct Markets {
        // ���h�r��NFT����
        address seller;
        // ����
        uint128 marketsPrice;
    }

    // �ȩ`����ID���錝�ꤹ��ީ`���åȤؤγ�Ʒ�˥ޥåפ��ޤ���
    mapping (uint256 => Markets) tokenIdToMarkets;

    // �ީ`���åȤؤγ�Ʒ�������Ϥ��O��
    uint256 public ownerCut = 0;
    function setOwnerCut(uint256 _cut) public onlyOwner {
        require(_cut <= 10000);
        ownerCut = _cut;
    }

    /// @notice Roc�ީ`���åȤؤγ�Ʒ�����ɤ����_ʼ���ޤ���
    /// @param _rocId 
    /// @param _marketsPrice 
    function createRocSaleMarkets(
        uint256 _rocId,
        uint256 _marketsPrice
    )
        external
        whenNotPaused
    {
        require(_marketsPrice == uint256(uint128(_marketsPrice)));

        // �����å��ä�tokenId�򥻥å�
        uint checkTokenId = getRocIdToTokenId(_rocId);

        // check�Υ��`�ʩ`�Ǥ�����
        require(_owns(msg.sender, checkTokenId));
        // check�Υѥ��`�������å�
        Roc memory roc = rocs[checkTokenId];
        // �ީ`���åȤؤγ�Ʒ�Ф��_�J���Ƥ���������
        require(uint8(roc.marketsFlg) == 0);
        // ���J
        _approve(checkTokenId, msg.sender);
        // �ީ`���åȤؤγ�Ʒ���å�
        _escrow(msg.sender, checkTokenId);
        Markets memory markets = Markets(
            msg.sender,
            uint128(_marketsPrice)
        );

        // �ީ`���åȤؤγ�ƷFLG�򥻥å�
        rocs[checkTokenId].marketsFlg = 1;
        _addMarkets(checkTokenId, markets);
    }

    /// @dev �ީ`���åȤؤγ�Ʒ���_�ީ`���åȤؤγ�Ʒ�Υꥹ�Ȥ�׷�Ӥ��ޤ��� 
    ///  �ޤ���MarketsCreated���٥�Ȥ�k�������ޤ���
    /// @param _tokenId The ID of the token to be put on markets.
    /// @param _markets Markets to add.
    function _addMarkets(uint256 _tokenId, Markets _markets) internal {
        tokenIdToMarkets[_tokenId] = _markets;
        emit MarketsCreated(
            uint256(_tokenId),
            uint128(_markets.marketsPrice)
        );
    }

    /// @dev �ީ`���åȤؤγ�Ʒ���_�ީ`���åȤؤγ�Ʒ�Υꥹ�Ȥ����������ޤ���
    /// @param _tokenId 
    function _removeMarkets(uint256 _tokenId) internal {
        delete tokenIdToMarkets[_tokenId];
    }

    /// @dev �o�����˥ީ`���åȤؤγ�Ʒ��ȡ�������ޤ���
    /// @param _tokenId 
    function _cancelMarkets(uint256 _tokenId) internal {
        _removeMarkets(_tokenId);
        emit MarketsCancelled(_tokenId);
    }

    /// @dev �ޤ��@�ä���Ƥ��ʤ�Markets�򥭥�󥻥뤷�ޤ���
    ///  Ԫ�������ߤ�NFT�򷵤��ޤ���
    /// @notice ����ϡ����s��һ�rֹͣ���Ƥ����g�˺��ӳ������Ȥ��Ǥ���״�B����v���Ǥ���
    /// @param _rocId 
    function cancelMarkets(uint _rocId) external {
        uint checkTokenId = getRocIdToTokenId(_rocId);
        Markets storage markets = tokenIdToMarkets[checkTokenId];
        address seller = markets.seller;
        require(msg.sender == seller);
        _cancelMarkets(checkTokenId);
        rocIndexToOwner[checkTokenId] = seller;
        rocs[checkTokenId].marketsFlg = 0;
    }

    /// @dev ���s��һ�rֹͣ���줿�Ȥ���Markets�򥭥�󥻥뤷�ޤ���
    ///  �����ߤ�����������Ф����Ȥ��Ǥ���NFT�ωӤ��֤˷�����ޤ��� 
    ///  �o���r�ˤΤ�ʹ�ä��Ƥ���������
    /// @param _rocId 
    function cancelMarketsWhenPaused(uint _rocId) whenPaused onlyOwner external {
        uint checkTokenId = getRocIdToTokenId(_rocId);
        Markets storage markets = tokenIdToMarkets[checkTokenId];
        address seller = markets.seller;
        _cancelMarkets(checkTokenId);
        rocIndexToOwner[checkTokenId] = seller;
        rocs[checkTokenId].marketsFlg = 0;
    }

    /// @dev Markets����
    ///  ʮ�֤�����Ether�����o������NFT�����Иؤ���ܞ���롣
    /// @param _rocId 
    function bid(uint _rocId) external payable whenNotPaused {
        uint checkTokenId = getRocIdToTokenId(_rocId);
        // �ީ`���åȤؤγ�Ʒ������ؤβ��դ�ȡ�ä���
        Markets storage markets = tokenIdToMarkets[checkTokenId];

        uint128 sellingPrice = uint128(markets.marketsPrice);
        // �����~���������ϤǤ����¤�_�J���롣
        // msg.value��wei����
        require(msg.value >= sellingPrice);
        // �ީ`���åȤؤγ�Ʒ�����夬���������ǰ�ˡ�؜���ߤؤβ��դ�ȡ�ä��ޤ���
        address seller = markets.seller;

        // �ީ`���åȤؤγ�Ʒ���������ޤ���
        _removeMarkets(checkTokenId);

        if (sellingPrice > 0) {
            // �����ˤΥ��åȤ�Ӌ�㤷�ޤ���
            uint128 marketseerCut = uint128(_computeCut(sellingPrice));
            uint128 sellerProceeds = sellingPrice - marketseerCut;

            // �Ӥ��֤��ͽ𤹤�
            seller.transfer(sellerProceeds);
        }

        // ���^�֤��I���֤˷���
        msg.sender.transfer(msg.value - sellingPrice);
        // ���٥��
        emit MarketsSuccessful(checkTokenId, sellingPrice, msg.sender);

        _transfer(seller, msg.sender, checkTokenId);
        // �ީ`���åȤؤγ�ƷFLG�򥻥å�
        rocs[checkTokenId].marketsFlg = 0;
    }

    /// @dev ������Ӌ��
    /// @param _price 
    function _computeCut(uint128 _price) internal view returns (uint) {
        return _price * ownerCut / 10000;
    }

}

/// @title CryptoRocs
contract RocsCore is RocsMarkets {

    // �������s������ƥ��åץ���`�ɤ���Ҫ�ʈ��Ϥ��O�����ޤ�
    address public newContractAddress;

    /// @dev һ�rֹͣ��o���ˤ���ȡ����s��һ�rֹͣ����ǰ�ˤ��٤Ƥ��ⲿ���s���ɥ쥹���O�������Ҫ������ޤ���
    function unpause() public onlyOwner whenPaused {
        require(newContractAddress == address(0));
        // �g�H�����s��һ�rֹͣ���ʤ��Ǥ���������
        super.unpause();
    }

    // @dev ���ÿ��ܤʲиߤ�ȡ�äǤ���褦�ˤ��ޤ���
    function withdrawBalance(uint _subtractFees) external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > _subtractFees) {
            owner.transfer(balance - _subtractFees);
        }
    }

    /// @notice tokenId����Roc���v���뤹�٤Ƥ��v�B���򷵤��ޤ���
    /// @param _tokenId �ȩ`����ID
    function getRoc(uint _tokenId)
        external
        view
        returns (
        uint rocId,
        string dna,
        uint marketsFlg
    ) {
        Roc memory roc = rocs[_tokenId];
        rocId = uint(roc.rocId);
        dna = string(roc.dna);
        marketsFlg = uint(roc.marketsFlg);
    }

    /// @notice rocId����Roc���v���뤹�٤Ƥ��v�B���򷵤��ޤ���
    /// @param _rocId rocId
    function getRocrocId(uint _rocId)
        external
        view
        returns (
        uint rocId,
        string dna,
        uint marketsFlg
    ) {
        Roc memory roc = rocs[getRocIdToTokenId(_rocId)];
        rocId = uint(roc.rocId);
        dna = string(roc.dna);
        marketsFlg = uint(roc.marketsFlg);
    }

    /// @notice rocId����Markets���򷵤��ޤ���
    /// @param _rocId rocId
    function getMarketsRocId(uint _rocId)
        external
        view
        returns (
        address seller,
        uint marketsPrice
    ) {
        uint checkTokenId = getRocIdToTokenId(_rocId);
        Markets memory markets = tokenIdToMarkets[checkTokenId];
        seller = markets.seller;
        marketsPrice = uint(markets.marketsPrice);
    }

    /// @notice rocId���饪�`�ʩ`���򷵤��ޤ���
    /// @param _rocId rocId
    function getRocIndexToOwner(uint _rocId)
        external
        view
        returns (
        address owner
    ) {
        uint checkTokenId = getRocIdToTokenId(_rocId);
        owner = rocIndexToOwner[checkTokenId];
    }

}