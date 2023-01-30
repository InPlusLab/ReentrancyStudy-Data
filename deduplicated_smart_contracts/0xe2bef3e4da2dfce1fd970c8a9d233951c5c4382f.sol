pragma solidity ^0.4.22;

/// @title ERC-721�˜ʒ��������s�Υ��󥿥ե��`��
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

contract RocsCoreRe {

    function getRoc(uint _tokenId) public returns (
        uint rocId,
        string dna,
        uint marketsFlg);

    function getRocIdToTokenId(uint _rocId) public view returns (uint);
    function getRocIndexToOwner(uint _rocId) public view returns (address);
}

contract ItemsBase is Pausable {
    // �ϥ�ȴ�
    uint public huntingPrice = 5 finney;
    function setHuntingPrice(uint256 price) public onlyOwner {
        huntingPrice = price;
    }

    // ERC721
    event Transfer(address from, address to, uint tokenId);
    event ItemTransfer(address from, address to, uint tokenId);

    // Item������
    event ItemCreated(address owner, uint tokenId, uint ticketId);

    event HuntingCreated(uint huntingId, uint rocId);

    /// @dev Item�Θ�����
    struct Item {
        uint itemId;
        uint8 marketsFlg;
        uint rocId;
        uint8 equipmentFlg;
    }
    Item[] public items;

    // itemId��tokenId�Υޥåԥ�
    mapping(uint => uint) public itemIndex;
    // itemId����tokenId��ȡ��
    function getItemIdToTokenId(uint _itemId) public view returns (uint) {
        return itemIndex[_itemId];
    }

    /// @dev item�����Ф��륢�ɥ쥹�ؤΥޥåԥ�
    mapping (uint => address) public itemIndexToOwner;
    // @dev item�������ߥ��ɥ쥹�������Ф���ȩ`�������ؤΥޥåԥ�
    mapping (address => uint) public itemOwnershipTokenCount;
    /// @dev item�κ��ӳ��������J���줿���ɥ쥹�ؤΥޥåԥ�
    mapping (uint => address) public itemIndexToApproved;

    /// @dev �ض���item���Иؤ򥢥ɥ쥹�˸�굱�Ƥޤ���
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        itemOwnershipTokenCount[_to]++;
        itemOwnershipTokenCount[_from]--;
        itemIndexToOwner[_tokenId] = _to;
        // ���٥���_ʼ
        emit ItemTransfer(_from, _to, _tokenId);
    }

    address public rocCoreAddress;
    RocsCoreRe rocCore;

    function setRocCoreAddress(address _rocCoreAddress) public onlyOwner {
        rocCoreAddress = _rocCoreAddress;
        rocCore = RocsCoreRe(rocCoreAddress);
    }
    function getRocCoreAddress() 
        external
        view
        onlyOwner
        returns (
        address
    ) {
        return rocCore;
    }

    /// @dev Hunting�Θ�����
    struct Hunting {
        uint huntingId;
    }
    // Hunting��mapping rocHuntingIndex[rocId][tokenId] = Hunting
    mapping(uint => mapping (uint => Hunting)) public rocHuntingIndex;

    /// @notice Hunting�����ɤ��Ʊ��椹���ڲ��᥽�åɡ� 
    /// @param _rocId 
    /// @param _huntingId 
    function _createRocHunting(
        uint _rocId,
        uint _huntingId
    )
        internal
        returns (bool)
    {
        Hunting memory _hunting = Hunting({
            huntingId: _huntingId
        });

        rocHuntingIndex[_rocId][_huntingId] = _hunting;
        // HuntingCreated���٥��
        emit HuntingCreated(_huntingId, _rocId);

        return true;
    }
}

/// @title Item���Иؤ�����륳��ȥ饯��
/// @dev OpenZeppelin��ERC721�ɥ�եȌgװ�˜ʒ�
contract ItemsOwnership is ItemsBase, ERC721 {

    /// @notice ERC721�Ƕ��x����Ƥ��롢�ä��Q�������ܤʥȩ`�������ǰ��ӛ�š�
    string public constant name = "CryptoFeatherItems";
    string public constant symbol = "CCHI";

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

    /// @dev �ض��Υ��ɥ쥹��ָ�����줿item�άF�ڤ������ߤǤ��뤫�ɤ���������å����ޤ���
    /// @param _claimant 
    /// @param _tokenId 
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return itemIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev �ض��Υ��ɥ쥹��ָ�����줿item�����ڤ��뤫�ɤ���������å����ޤ���
    /// @param _claimant the address we are confirming kitten is approved for.
    /// @param _tokenId kitten id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return itemIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev ��ǰ�γ��J���ϕ������ơ�transferFrom�����ˌ����Ƴ��J���줿���ɥ쥹��ީ`�����ޤ���
    function _approve(uint256 _tokenId, address _approved) internal {
        itemIndexToApproved[_tokenId] = _approved;
    }

    // ָ�����줿���ɥ쥹��item����ȡ�ä��ޤ���
    function balanceOf(address _owner) public view returns (uint256 count) {
        return itemOwnershipTokenCount[_owner];
    }

    /// @notice item�������ߤ������ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ
    function transfer(address _to, uint256 _tokenId) public whenNotPaused {
        // ��ȫ�����å�
        require(_to != address(0));
        // �Է֤�item�����ͤ뤳�ȤϤǤ��ޤ���
        require(_owns(msg.sender, _tokenId));
        // ���Иؤ��ٸ�굱�ơ������Фγ��J�Υ��ꥢ��ܞ�ͥ��٥�Ȥ�����
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice transferFrom������餷�Ƅe�Υ��ɥ쥹���ض���item��ܞ�ͤ���������뤨�ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ
    function approve(address _to, uint256 _tokenId) external whenNotPaused {
        // �����ߤΤߤ��j�ɳ��J���J��뤳�Ȥ��Ǥ��ޤ���
        require(_owns(msg.sender, _tokenId));
        // ���J����h���ޤ�����ǰ�γ��J���ä��Q���ޤ�����
        _approve(_tokenId, _to);
        // ���J���٥�Ȥ�k�Ф��롣
        emit Approval(msg.sender, _to, _tokenId);
    }

    /// @notice item�����ߤΉ�����Ф��ޤ�����ܞ�ͤ��ޤ������Υ��ɥ쥹�ˤϡ���ǰ�������ߤ���ܞ�ͳ��J���뤨���Ƥ��ޤ���
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

    /// @notice �F�ڴ��ڤ���item�ξt���򷵤��ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ�Ǥ���
    function totalSupply() public view returns (uint) {
        return items.length - 1;
    }

    /// @notice ָ�����줿item�άF�����Иؤ���굱�Ƥ��Ƥ��륢�ɥ쥹�򷵤��ޤ���
    /// @dev ERC-721�ؤΜʒ��˱�Ҫ�Ǥ���
    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = itemIndexToOwner[_tokenId];
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

/// @title Item���v���������Ф�����ȥ饯��
contract ItemsBreeding is ItemsOwnership {

    /// @notice Item�����ɤ��Ʊ��档 
    /// @param _itemId 
    /// @param _marketsFlg 
    /// @param _rocId 
    /// @param _equipmentFlg 
    /// @param _owner 
    function _createItem(
        uint _itemId,
        uint _marketsFlg,
        uint _rocId,
        uint _equipmentFlg,
        address _owner
    )
        internal
        returns (uint)
    {
        Item memory _item = Item({
            itemId: _itemId,
            marketsFlg: uint8(_marketsFlg),
            rocId: _rocId,
            equipmentFlg: uint8(_equipmentFlg)
        });

        uint newItemId = items.push(_item) - 1;
        // ͬһ�Υȩ`����ID���k���������Ϥόg�Ф�ֹͣ���ޤ�
        require(newItemId == uint(newItemId));
        // RocCreated���٥��
        emit ItemCreated(_owner, newItemId, _itemId);

        // ����ˤ�����Иؤ���굱�Ƥ�졢ERC721�ɥ�եȤ��Ȥ�ܞ�ͥ��٥�Ȥ��k�Ф���ޤ�
        itemIndex[_itemId] = newItemId;
        _transfer(0, _owner, newItemId);

        return newItemId;
    }

    /// @notice �����ƥ��װ��״�B����¤��ޤ��� 
    /// @param _reItems 
    /// @param _inItems 
    /// @param _rocId 
    function equipmentItem(
        uint[] _reItems,
        uint[] _inItems,
        uint _rocId
    )
        external
        whenNotPaused
        returns(bool)
    {
        uint checkTokenId = rocCore.getRocIdToTokenId(_rocId);
        uint i;
        uint itemTokenId;
        Item memory item;
        // ���
        for (i = 0; i < _reItems.length; i++) {
            itemTokenId = getItemIdToTokenId(_reItems[i]);
            // item�Υѥ��`�������å�
            item = items[itemTokenId];
            // �ީ`���åȤؤγ�Ʒ�Ф��_�J���Ƥ���������
            require(uint(item.marketsFlg) == 0);
            // �����ƥ�װ���Ф��_�J���Ƥ���������
            require(uint(item.equipmentFlg) == 1);
            // װ�ť��å���ͬһ���_�J���Ƥ���������
            require(uint(item.rocId) == _rocId);
            // װ����
            items[itemTokenId].rocId = 0;
            items[itemTokenId].equipmentFlg = 0;
            // �����ƥ�Υ��`�ʩ`���`���Х��å��Υ��`�ʩ`�򥻥åȤ��ʤ����ޤ���
            address itemOwner = itemIndexToOwner[itemTokenId];
            address checkOwner = rocCore.getRocIndexToOwner(checkTokenId);
            if (itemOwner != checkOwner) {
                itemIndexToOwner[itemTokenId] = checkOwner;
            }
        }
        // װ��
        for (i = 0; i < _inItems.length; i++) {
            itemTokenId = getItemIdToTokenId(_inItems[i]);
            // item�Υѥ��`�������å�
            item = items[itemTokenId];
            // item�Υ��`�ʩ`�Ǥ�����
            require(_owns(msg.sender, itemTokenId));
            // �ީ`���åȤؤγ�Ʒ�Ф��_�J���Ƥ���������
            require(uint(item.marketsFlg) == 0);
            // �����ƥ�δװ�䤫�_�J���Ƥ���������
            require(uint(item.equipmentFlg) == 0);
            // װ��I��
            items[itemTokenId].rocId = _rocId;
            items[itemTokenId].equipmentFlg = 1;
        }
        return true;
    }

    /// @notice ���M�����¤������΄I����Ф��ޤ���
    /// @param _itemId 
    function usedItem(
        uint _itemId
    )
        external
        whenNotPaused
        returns(bool)
    {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        Item memory item = items[itemTokenId];
        // item�Υ��`�ʩ`�Ǥ�����
        require(_owns(msg.sender, itemTokenId));
        // �ީ`���åȤؤγ�Ʒ�Ф��_�J���Ƥ���������
        require(uint(item.marketsFlg) == 0);
        // �����ƥ�δװ�䤫�_�J���Ƥ���������
        require(uint(item.equipmentFlg) == 0);
        delete itemIndex[_itemId];
        delete items[itemTokenId];
        delete itemIndexToOwner[itemTokenId];
        return true;
    }

    /// @notice Hunting�΄I����Ф��ޤ���
    /// @param _rocId 
    /// @param _huntingId 
    /// @param _items 
    function processHunting(
        uint _rocId,
        uint _huntingId,
        uint[] _items
    )
        external
        payable
        whenNotPaused
        returns(bool)
    {
        require(msg.value >= huntingPrice);

        uint checkTokenId = rocCore.getRocIdToTokenId(_rocId);
        uint marketsFlg;
        ( , , marketsFlg) = rocCore.getRoc(checkTokenId);

        // markets�Ф��_�J���Ƥ���������
        require(marketsFlg == 0);
        bool createHunting = false;
        // Hunting�I��
        require(_huntingId > 0);
        createHunting = _createRocHunting(
            _rocId,
            _huntingId
        );

        uint i;
        for (i = 0; i < _items.length; i++) {
            _createItem(
                _items[i],
                0,
                0,
                0,
                msg.sender
            );
        }

        // ���^�֤��I���֤˷���
        uint256 bidExcess = msg.value - huntingPrice;
        msg.sender.transfer(bidExcess);

        return createHunting;
    }

    /// @notice Item�����ɤ��ޤ������٥����
    /// @param _items 
    /// @param _owners 
    function createItems(
        uint[] _items,
        address[] _owners
    )
        external onlyOwner
        returns (uint)
    {
        uint i;
        uint createItemId;
        for (i = 0; i < _items.length; i++) {
            createItemId = _createItem(
                _items[i],
                0,
                0,
                0,
                _owners[i]
            );
        }
        return createItemId;
    }

}

/// @title Item��Market���v����I��
contract ItemsMarkets is ItemsBreeding {

    event ItemMarketsCreated(uint256 tokenId, uint128 marketsPrice);
    event ItemMarketsSuccessful(uint256 tokenId, uint128 marketsPriceice, address buyer);
    event ItemMarketsCancelled(uint256 tokenId);

    // ERC721
    event Transfer(address from, address to, uint tokenId);

    // NFT�Ϥ�Market
    struct ItemMarkets {
        // ���h�r��NFT����
        address seller;
        // Market�΁���
        uint128 marketsPrice;
    }

    // �ȩ`����ID���錝�ꤹ��ީ`���åȤؤγ�Ʒ�˥ޥåפ��ޤ���
    mapping (uint256 => ItemMarkets) tokenIdToItemMarkets;

    // �ީ`���åȤؤγ�Ʒ�������Ϥ��O��
    uint256 public ownerCut = 0;
    function setOwnerCut(uint256 _cut) public onlyOwner {
        require(_cut <= 10000);
        ownerCut = _cut;
    }

    /// @notice Item�ީ`���åȤؤγ�Ʒ�����ɤ����_ʼ���ޤ���
    /// @param _itemId 
    /// @param _marketsPrice 
    function createItemSaleMarkets(
        uint256 _itemId,
        uint256 _marketsPrice
    )
        external
        whenNotPaused
    {
        require(_marketsPrice == uint256(uint128(_marketsPrice)));

        // �����å��ä�tokenId�򥻥å�
        uint itemTokenId = getItemIdToTokenId(_itemId);
        // item�Υ��`�ʩ`�Ǥ�����
        require(_owns(msg.sender, itemTokenId));
        // item�Υѥ��`�������å�
        Item memory item = items[itemTokenId];
        // �ީ`���åȤؤγ�Ʒ�Ф��_�J���Ƥ���������
        require(uint(item.marketsFlg) == 0);
        // װ���Ф��_�J���Ƥ���������
        require(uint(item.rocId) == 0);
        require(uint(item.equipmentFlg) == 0);
        // ���J
        _approve(itemTokenId, msg.sender);
        // �ީ`���åȤؤγ�Ʒ���å�
        _escrow(msg.sender, itemTokenId);
        ItemMarkets memory itemMarkets = ItemMarkets(
            msg.sender,
            uint128(_marketsPrice)
        );

        // �ީ`���åȤؤγ�ƷFLG�򥻥å�
        items[itemTokenId].marketsFlg = 1;

        _itemAddMarkets(itemTokenId, itemMarkets);
    }

    /// @dev �ީ`���åȤؤγ�Ʒ���_�ީ`���åȤؤγ�Ʒ�Υꥹ�Ȥ�׷�Ӥ��ޤ��� 
    ///  �ޤ���ItemMarketsCreated���٥�Ȥ�k�������ޤ���
    /// @param _tokenId The ID of the token to be put on markets.
    /// @param _markets Markets to add.
    function _itemAddMarkets(uint256 _tokenId, ItemMarkets _markets) internal {
        tokenIdToItemMarkets[_tokenId] = _markets;
        emit ItemMarketsCreated(
            uint256(_tokenId),
            uint128(_markets.marketsPrice)
        );
    }

    /// @dev �ީ`���åȤؤγ�Ʒ���_�ީ`���åȤؤγ�Ʒ�Υꥹ�Ȥ����������ޤ���
    /// @param _tokenId 
    function _itemRemoveMarkets(uint256 _tokenId) internal {
        delete tokenIdToItemMarkets[_tokenId];
    }

    /// @dev �o�����˥ީ`���åȤؤγ�Ʒ��ȡ�������ޤ���
    /// @param _tokenId 
    function _itemCancelMarkets(uint256 _tokenId) internal {
        _itemRemoveMarkets(_tokenId);
        emit ItemMarketsCancelled(_tokenId);
    }

    /// @dev �ޤ��@�ä���Ƥ��ʤ��ީ`���åȤؤγ�Ʒ�򥭥�󥻥뤷�ޤ���
    ///  Ԫ�������ߤ�NFT�򷵤��ޤ���
    /// @notice ����ϡ����s��һ�rֹͣ���Ƥ����g�˺��ӳ������Ȥ��Ǥ���״�B����v���Ǥ���
    /// @param _itemId 
    function itemCancelMarkets(uint _itemId) external {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        ItemMarkets storage markets = tokenIdToItemMarkets[itemTokenId];
        address seller = markets.seller;
        require(msg.sender == seller);
        _itemCancelMarkets(itemTokenId);
        itemIndexToOwner[itemTokenId] = seller;
        items[itemTokenId].marketsFlg = 0;
    }

    /// @dev ���s��һ�rֹͣ���줿�Ȥ��˥ީ`���åȤؤγ�Ʒ�򥭥�󥻥뤷�ޤ���
    ///  �����ߤ�����������Ф����Ȥ��Ǥ���NFT�ωӤ��֤˷�����ޤ��� 
    ///  �o���r�ˤΤ�ʹ�ä��Ƥ���������
    /// @param _itemId 
    function itemCancelMarketsWhenPaused(uint _itemId) whenPaused onlyOwner external {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        ItemMarkets storage markets = tokenIdToItemMarkets[itemTokenId];
        address seller = markets.seller;
        _itemCancelMarkets(itemTokenId);
        itemIndexToOwner[itemTokenId] = seller;
        items[itemTokenId].marketsFlg = 0;
    }

    /// @dev �ީ`���åȤؤγ�Ʒ����
    ///  ʮ�֤�����Ether�����o������NFT�����Иؤ���ܞ���롣
    /// @param _itemId 
    function itemBid(uint _itemId) external payable whenNotPaused {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        // �ީ`���åȤؤγ�Ʒ������ؤβ��դ�ȡ�ä���
        ItemMarkets storage markets = tokenIdToItemMarkets[itemTokenId];

        uint128 sellingPrice = uint128(markets.marketsPrice);
        // �����~���������ϤǤ����¤�_�J���롣
        // msg.value��wei����
        require(msg.value >= sellingPrice);
        // �ީ`���åȤؤγ�Ʒ�����夬���������ǰ�ˡ�؜���ߤؤβ��դ�ȡ�ä��ޤ���
        address seller = markets.seller;

        // �ީ`���åȤؤγ�Ʒ���������ޤ���
        _itemRemoveMarkets(itemTokenId);

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
        emit ItemMarketsSuccessful(itemTokenId, sellingPrice, msg.sender);

        _transfer(seller, msg.sender, itemTokenId);
        // �ީ`���åȤؤγ�ƷFLG�򥻥å�
        items[itemTokenId].marketsFlg = 0;
    }

    /// @dev ������Ӌ��
    /// @param _price 
    function _computeCut(uint128 _price) internal view returns (uint) {
        return _price * ownerCut / 10000;
    }

}

/// @title CryptoFeather
contract ItemsCore is ItemsMarkets {

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

    /// @notice tokenId����Item���v���뤹�٤Ƥ��v�B���򷵤��ޤ���
    /// @param _tokenId 
    function getItem(uint _tokenId)
        external
        view
        returns (
        uint itemId,
        uint marketsFlg,
        uint rocId,
        uint equipmentFlg
    ) {
        Item memory item = items[_tokenId];
        itemId = uint(item.itemId);
        marketsFlg = uint(item.marketsFlg);
        rocId = uint(item.rocId);
        equipmentFlg = uint(item.equipmentFlg);
    }

    /// @notice itemId����Item���v���뤹�٤Ƥ��v�B���򷵤��ޤ���
    /// @param _itemId 
    function getItemItemId(uint _itemId)
        external
        view
        returns (
        uint itemId,
        uint marketsFlg,
        uint rocId,
        uint equipmentFlg
    ) {
        Item memory item = items[getItemIdToTokenId(_itemId)];
        itemId = uint(item.itemId);
        marketsFlg = uint(item.marketsFlg);
        rocId = uint(item.rocId);
        equipmentFlg = uint(item.equipmentFlg);
    }

    /// @notice itemId����Markets���򷵤��ޤ���
    /// @param _itemId 
    function getMarketsItemId(uint _itemId)
        external
        view
        returns (
        address seller,
        uint marketsPrice
    ) {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        ItemMarkets storage markets = tokenIdToItemMarkets[itemTokenId];
        seller = markets.seller;
        marketsPrice = uint(markets.marketsPrice);
    }

    /// @notice itemId���饪�`�ʩ`���򷵤��ޤ���
    /// @param _itemId 
    function getItemIndexToOwner(uint _itemId)
        external
        view
        returns (
        address owner
    ) {
        uint itemTokenId = getItemIdToTokenId(_itemId);
        owner = itemIndexToOwner[itemTokenId];
    }

    /// @notice rocId��huntingId����hunting�δ��ڥ����å�
    /// @param _rocId 
    /// @param _huntingId 
    function getHunting(uint _rocId, uint _huntingId)
        public
        view
        returns (
        uint huntingId
    ) {
        Hunting memory hunting = rocHuntingIndex[_rocId][_huntingId];
        huntingId = uint(hunting.huntingId);
    }

    /// @notice _rocId���饪�`�ʩ`���򷵤��ޤ���
    /// @param _rocId 
    function getRocOwnerItem(uint _rocId)
        external
        view
        returns (
        address owner
    ) {
        uint checkTokenId = rocCore.getRocIdToTokenId(_rocId);
        owner = rocCore.getRocIndexToOwner(checkTokenId);
    }

}