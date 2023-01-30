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
    *               契約が一時停止されている場合にのみアクションを許可する
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    *               契約が一時停止されていない場合にのみアクションを許可する
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    *             一時停止するために所有者によって呼び出され、停止状態をトリガする
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    *             ポーズをとるためにオーナーが呼び出し、通常の状態に戻ります
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract RocsBase is Pausable {

    // 生誕代
    uint128 public eggPrice = 50 finney;
    function setEggPrice(uint128 _price) public onlyOwner {
        eggPrice = _price;
    }
    // 進化代
    uint128 public evolvePrice = 5 finney;
    function setEvolvePrice(uint128 _price) public onlyOwner {
        evolvePrice = _price;
    }

    // 生誕
    event RocCreated(address owner, uint tokenId, uint rocId);
    // ERC721
    event Transfer(address from, address to, uint tokenId);
    event ItemTransfer(address from, address to, uint tokenId);

    /// @dev Rocの構造体
    struct Roc {
        // ID
        uint rocId;
        // DNA
        string dna;
        // 出品中フラグ 1は出品中
        uint8 marketsFlg;
    }

    /// @dev Rocsの配列
    Roc[] public rocs;

    // rocIdとtokenIdのマッピング
    mapping(uint => uint) public rocIndex;
    // rocIdからtokenIdを取得
    function getRocIdToTokenId(uint _rocId) public view returns (uint) {
        return rocIndex[_rocId];
    }

    /// @dev 所有するアドレスへのマッピング
    mapping (uint => address) public rocIndexToOwner;
    // @dev 所有者アドレスから所有するトークン数へのマッピング
    mapping (address => uint) public ownershipTokenCount;
    /// @dev 呼び出しが承認されたアドレスへのマッピング
    mapping (uint => address) public rocIndexToApproved;

    /// @dev 特定のRocの所有権をアドレスに割り当てます。
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        ownershipTokenCount[_from]--;
        rocIndexToOwner[_tokenId] = _to;
        // イベント開始
        emit Transfer(_from, _to, _tokenId);
    }

}

/// @title ERC-721に準拠した契約のインタフェース：置き換え不可能なトークン
contract ERC721 {
    // イベント
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    // 必要なメソッド
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) external view returns (address _owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function totalSupply() public view returns (uint);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

/// @title Roc所有権を管理するコントラクト
/// @dev OpenZeppelinのERC721ドラフト実装に準拠
contract RocsOwnership is RocsBase, ERC721 {

    /// @notice ERC721で定義されている、置き換え不可能なトークンの名前と記号。
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
    ///  この契約によって実装された標準化されたインタフェースでtrueを返します。
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        // DEBUG ONLY
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    /// @dev 特定のアドレスに指定されたrocの現在の所有者であるかどうかをチェックします。
    /// @param _claimant 
    /// @param _tokenId 
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return rocIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev 特定のアドレスに指定されたrocが存在するかどうかをチェックします。
    /// @param _claimant the address we are confirming kitten is approved for.
    /// @param _tokenId kitten id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return rocIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev 以前の承認を上書きして、transferFrom（）に対して承認されたアドレスをマークします。
    function _approve(uint256 _tokenId, address _approved) internal {
        rocIndexToApproved[_tokenId] = _approved;
    }

    // 指定されたアドレスのroc数を取得します。
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice rocの所有者を変更します。
    /// @dev ERC-721への準拠に必要
    function transfer(address _to, uint256 _tokenId) public whenNotPaused {
        // 安全チェック
        require(_to != address(0));
        // 自分のrocしか送ることはできません。
        require(_owns(msg.sender, _tokenId));
        // 所有権の再割り当て、保留中の承認のクリア、転送イベントの送信
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice transferFrom（）を介して別のアドレスに特定のrocを転送する権利を与えます。
    /// @dev ERC-721への準拠に必要
    function approve(address _to, uint256 _tokenId) external whenNotPaused {
        // 所有者のみが譲渡承認を認めることができます。
        require(_owns(msg.sender, _tokenId));
        // 承認を登録します（以前の承認を置き換えます）。
        _approve(_tokenId, _to);
        // 承認イベントを発行する。
        emit Approval(msg.sender, _to, _tokenId);
    }

    /// @notice roc所有者の変更を行います。を転送します。そのアドレスには、以前の所有者から転送承認が与えられています。
    /// @dev ERC-721への準拠に必要
    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
        // 安全チェック。
        require(_to != address(0));
        // 承認と有効な所有権の確認
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        // 所有権を再割り当てします（保留中の承認をクリアし、転送イベントを発行します）。
        _transfer(_from, _to, _tokenId);
    }

    /// @notice 現在存在するrocの総数を返します。
    /// @dev ERC-721への準拠に必要です。
    function totalSupply() public view returns (uint) {
        return rocs.length - 1;
    }

    /// @notice 指定されたrocの現在所有権が割り当てられているアドレスを返します。
    /// @dev ERC-721への準拠に必要です。
    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = rocIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    /// @dev この契約に所有権を割り当て、NFTを強制終了します。
    /// @param _owner 
    /// @param _tokenId 
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        transferFrom(_owner, this, _tokenId);
    }

}

/// @title Rocの飼育に関する管理を行うコントラクト
contract RocsBreeding is RocsOwnership {

    /// @notice 新しいRocを作成して保存。 
    /// @param _rocId 
    /// @param _dna 
    /// @param _marketsFlg 
    /// @param _owner 
    /// @dev RocCreatedイベントとTransferイベントの両方を生成します。 
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
        // 同一のトークンIDが発生した場合は実行を停止します
        require(newRocId == uint(newRocId));
        // RocCreatedイベント
        emit RocCreated(_owner, newRocId, _rocId);

        // これにより所有権が割り当てられ、ERC721ドラフトごとに転送イベントが発行されます
        rocIndex[_rocId] = newRocId;
        _transfer(0, _owner, newRocId);

        return newRocId;
    }

    /// @notice 新たに生み出します 
    /// @param _rocId 
    /// @param _dna 
    function giveProduce(uint _rocId, string _dna)
        external
        payable
        whenNotPaused
        returns(uint)
    {
        // 支払いを確認します。
        require(msg.value >= eggPrice);
        uint createRocId = _createRoc(
            _rocId,
            _dna, 
            0, 
            msg.sender
        );
        // 超過分を買い手に返す
        uint256 bidExcess = msg.value - eggPrice;
        msg.sender.transfer(bidExcess);

        return createRocId;
    }

    /// @notice 初めてのRoc 
    /// @param _rocId 
    /// @param _dna 
    function freeGiveProduce(uint _rocId, string _dna)
        external
        payable
        whenNotPaused
        returns(uint)
    {
        // 初めてのRocか確認します。
        require(balanceOf(msg.sender) == 0);
        uint createRocId = _createRoc(
            _rocId,
            _dna, 
            0, 
            msg.sender
        );
        // 超過分を買い手に返す
        uint256 bidExcess = msg.value;
        msg.sender.transfer(bidExcess);

        return createRocId;
    }

}

/// @title Rocの売買のためのMarkets処理
contract RocsMarkets is RocsBreeding {

    event MarketsCreated(uint256 tokenId, uint128 marketsPrice);
    event MarketsSuccessful(uint256 tokenId, uint128 marketsPriceice, address buyer);
    event MarketsCancelled(uint256 tokenId);

    // NFT上のマーケットへの出品
    struct Markets {
        // 登録時のNFT売手
        address seller;
        // 価格
        uint128 marketsPrice;
    }

    // トークンIDから対応するマーケットへの出品にマップします。
    mapping (uint256 => Markets) tokenIdToMarkets;

    // マーケットへの出品の手数料を設定
    uint256 public ownerCut = 0;
    function setOwnerCut(uint256 _cut) public onlyOwner {
        require(_cut <= 10000);
        ownerCut = _cut;
    }

    /// @notice Rocマーケットへの出品を作成し、開始します。
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

        // チェック用のtokenIdをセット
        uint checkTokenId = getRocIdToTokenId(_rocId);

        // checkのオーナーである事
        require(_owns(msg.sender, checkTokenId));
        // checkのパラメータチェック
        Roc memory roc = rocs[checkTokenId];
        // マーケットへの出品中か確認してください。
        require(uint8(roc.marketsFlg) == 0);
        // 承認
        _approve(checkTokenId, msg.sender);
        // マーケットへの出品セット
        _escrow(msg.sender, checkTokenId);
        Markets memory markets = Markets(
            msg.sender,
            uint128(_marketsPrice)
        );

        // マーケットへの出品FLGをセット
        rocs[checkTokenId].marketsFlg = 1;
        _addMarkets(checkTokenId, markets);
    }

    /// @dev マーケットへの出品を公開マーケットへの出品のリストに追加します。 
    ///  また、MarketsCreatedイベントを発生させます。
    /// @param _tokenId The ID of the token to be put on markets.
    /// @param _markets Markets to add.
    function _addMarkets(uint256 _tokenId, Markets _markets) internal {
        tokenIdToMarkets[_tokenId] = _markets;
        emit MarketsCreated(
            uint256(_tokenId),
            uint128(_markets.marketsPrice)
        );
    }

    /// @dev マーケットへの出品を公開マーケットへの出品のリストから削除します。
    /// @param _tokenId 
    function _removeMarkets(uint256 _tokenId) internal {
        delete tokenIdToMarkets[_tokenId];
    }

    /// @dev 無条件にマーケットへの出品を取り消します。
    /// @param _tokenId 
    function _cancelMarkets(uint256 _tokenId) internal {
        _removeMarkets(_tokenId);
        emit MarketsCancelled(_tokenId);
    }

    /// @dev まだ獲得されていないMarketsをキャンセルします。
    ///  元の所有者にNFTを返します。
    /// @notice これは、契約が一時停止している間に呼び出すことができる状態変更関数です。
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

    /// @dev 契約が一時停止されたときにMarketsをキャンセルします。
    ///  所有者だけがこれを行うことができ、NFTは売り手に返されます。 
    ///  緊急時にのみ使用してください。
    /// @param _rocId 
    function cancelMarketsWhenPaused(uint _rocId) whenPaused onlyOwner external {
        uint checkTokenId = getRocIdToTokenId(_rocId);
        Markets storage markets = tokenIdToMarkets[checkTokenId];
        address seller = markets.seller;
        _cancelMarkets(checkTokenId);
        rocIndexToOwner[checkTokenId] = seller;
        rocs[checkTokenId].marketsFlg = 0;
    }

    /// @dev Markets入札
    ///  十分な量のEtherが供給されればNFTの所有権を移転する。
    /// @param _rocId 
    function bid(uint _rocId) external payable whenNotPaused {
        uint checkTokenId = getRocIdToTokenId(_rocId);
        // マーケットへの出品構造体への参照を取得する
        Markets storage markets = tokenIdToMarkets[checkTokenId];

        uint128 sellingPrice = uint128(markets.marketsPrice);
        // 入札額が価格以上である事を確認する。
        // msg.valueはweiの数
        require(msg.value >= sellingPrice);
        // マーケットへの出品構造体が削除される前に、販売者への参照を取得します。
        address seller = markets.seller;

        // マーケットへの出品を削除します。
        _removeMarkets(checkTokenId);

        if (sellingPrice > 0) {
            // 競売人のカットを計算します。
            uint128 marketseerCut = uint128(_computeCut(sellingPrice));
            uint128 sellerProceeds = sellingPrice - marketseerCut;

            // 売り手に送金する
            seller.transfer(sellerProceeds);
        }

        // 超過分を買い手に返す
        msg.sender.transfer(msg.value - sellingPrice);
        // イベント
        emit MarketsSuccessful(checkTokenId, sellingPrice, msg.sender);

        _transfer(seller, msg.sender, checkTokenId);
        // マーケットへの出品FLGをセット
        rocs[checkTokenId].marketsFlg = 0;
    }

    /// @dev 手数料計算
    /// @param _price 
    function _computeCut(uint128 _price) internal view returns (uint) {
        return _price * ownerCut / 10000;
    }

}

/// @title CryptoRocs
contract RocsCore is RocsMarkets {

    // コア契約が壊れてアップグレードが必要な場合に設定します
    address public newContractAddress;

    /// @dev 一時停止を無効にすると、契約を一時停止する前にすべての外部契約アドレスを設定する必要があります。
    function unpause() public onlyOwner whenPaused {
        require(newContractAddress == address(0));
        // 実際に契約を一時停止しないでください。
        super.unpause();
    }

    // @dev 利用可能な残高を取得できるようにします。
    function withdrawBalance(uint _subtractFees) external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > _subtractFees) {
            owner.transfer(balance - _subtractFees);
        }
    }

    /// @notice tokenIdからRocに関するすべての関連情報を返します。
    /// @param _tokenId トークンID
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

    /// @notice rocIdからRocに関するすべての関連情報を返します。
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

    /// @notice rocIdからMarkets情報を返します。
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

    /// @notice rocIdからオーナー情報を返します。
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