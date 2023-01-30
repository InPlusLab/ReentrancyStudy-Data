/**
 *Submitted for verification at Etherscan.io on 2020-02-21
*/

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/TokenExpress.sol

pragma solidity ^0.4.25;



contract TokenExpress is Ownable {
    event Deposit(bytes32 indexed escrowId, address indexed sender, uint256 amount);
    event Send(bytes32 indexed escrowId, address indexed recipient, uint256 amount);
    event Recovery(bytes32 indexed escrowId, address indexed sender, uint256 amount);

    using SafeMath for uint256;

    // ユーザに負担してもらう手数料（wei）
    uint256 fee = 1000000;

    // ユーザが回収できるようになるまでの時間（時間）
    uint256 lockTime = 14 * 24;

    // オーナー以外に管理権限があるユーザ
    address administrator = 0x0;

    // 送金情報を保存する構造体
    struct TransferInfo {
        address from;
        address to;
        uint256 amount;
        uint256 date;
        bool    sent;
    }

    // デポジット情報
    mapping (bytes32 => TransferInfo) private _transferInfo;

    /**
     * コンストラクタ
     */
    constructor () public {
        owner = msg.sender;
    }

    /**
     * デポジットを行う
     * 引数１：システムで発行されたID
     * 引数２：送金額（wei で指定）
     * 引数３：送金先アドレス
     * ※ 送金額＋手数料分のETHを送ってもらう必要がある
     *
     * df121a97
     */
    function etherDeposit(bytes32 id, uint256 amount) payable public {
        // 既にIDが登録されていたら変更は不可
        require(_transferInfo[id].from == 0x0, "ID is already exists.");

        // 実際に送られた ether が送金額＋手数料よりも低ければエラー
        require(amount + fee <= msg.value, "Value is too low.");

        // 送金情報を登録する
        _transferInfo[id].from   = msg.sender;
        _transferInfo[id].to     = 0x0;
        _transferInfo[id].amount = amount;
        _transferInfo[id].date   = block.timestamp;
        emit Deposit(id, msg.sender, amount);
    }

    /**
     * 送金を行う
     * 引数１：システムで発行されたID
     *
     * 3af19adb
     */
    function etherSend(bytes32 id, address to) public {
        // IDが登録されていなければエラー
        require(_transferInfo[id].from != 0x0, "ID error.");

        // 既に送金・回収されていればエラー
        require(_transferInfo[id].sent == false, "Already sent.");

        // 送金先が不正なアドレスならエラー
        require(to != 0x0, "Address error.");

        // 送金指示をしたアドレスが、オーナーか管理者かデポジット者以外だったらエラー
        require(msg.sender == owner || msg.sender == administrator || msg.sender == _transferInfo[id].from, "Invalid address.");

        to.transfer(_transferInfo[id].amount);
        _transferInfo[id].to = to;
        _transferInfo[id].sent = true;
        emit Send(id, to, _transferInfo[id].amount);
    }

    /**
     * 回収を行う
     * 引数１：システムで発行されたID
     *
     * 6b87124e
     */
    function etherRecovery(bytes32 id) public {
        // IDが登録されていなければエラー
        require(_transferInfo[id].from != 0x0, "ID error.");

        // 既に送金・回収されていればエラー
        require(_transferInfo[id].sent == false, "Already recoveried.");

        // ロックタイムを過ぎて今ければエラー
        require(_transferInfo[id].date + lockTime * 60 * 60 <= block.timestamp, "Locked.");

        address to = _transferInfo[id].from;
        to.transfer(_transferInfo[id].amount);
        _transferInfo[id].sent = true;
        emit Recovery(id, _transferInfo[id].from, _transferInfo[id].amount);
    }

    /**
     * 指定したIDの情報を返す
     * onlyOwner にした方が良いかも
     */
    function etherInfo(bytes32 id) public view returns (address, address, uint256, bool) {
        return (_transferInfo[id].from, _transferInfo[id].to, _transferInfo[id].amount, _transferInfo[id].sent);
    }

    /**
     * オーナー以外の管理者を設定する
     * 引数１：管理者のアドレス
     *
     *
     */
    function setAdmin(address _admin) onlyOwner public {
        administrator = _admin;
    }

    /**
     * オーナー以外の管理者を取得する
     */
    function getAdmin() public view returns (address) {
        return administrator;
    }

    /**
     * 手数料の値を変更する
     * 引数１：手数料の値（wei）
     *
     * 69fe0e2d
     */
    function setFee(uint256 _fee) onlyOwner public {
        fee = _fee;
    }

    /**
     * 手数料の値を返す
     */
    function getFee() public view returns (uint256) {
        return fee;
    }

    /**
     * ロック期間を変更する
     * 引数１：ロック期間（時間）
     *
     * ae04d45d
     */
    function setLockTime(uint256 _lockTime) onlyOwner public {
        lockTime = _lockTime;
    }

    /**
     * ロック期間の値を返す
     */
    function getLockTime() public view returns (uint256) {
        return lockTime;
    }

    /**
     * コントラクトの残高確認
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * オーナーによる Ether の回収
     * 引数１：送り先アドレス
     * 引数２；送金額
     *
     * 3ef5e35f
     */
    function sendEtherToOwner(address to, uint256 amount) onlyOwner public {
        to.transfer(amount);
    }

}