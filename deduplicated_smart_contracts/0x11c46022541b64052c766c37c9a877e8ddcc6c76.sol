// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.23;

// import 'ds-auth/auth.sol';
contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

// import 'ds-math/math.sol';
contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

// import './IkuraStorage.sol';
/**
 *
 * ロジックの更新に影響されない永続化データを保持するクラス
 *
 */
contract IkuraStorage is DSMath, DSAuth {
  // オーナー（中央銀行）のアドレス
  address[] ownerAddresses;

  // 各アドレスのdJPYの口座残高
  mapping(address => uint) coinBalances;

  // 各アドレスのSHINJI tokenの口座残高
  mapping(address => uint) tokenBalances;

  // 各アドレスが指定したアドレスに対して許可する最大送金額
  mapping(address => mapping (address => uint)) coinAllowances;

  // dJPYの発行高
  uint _totalSupply = 0;

  // 手数料率
  // 0.01pips = 1
  // 例). 手数料を 0.05% とする場合は 500
  uint _transferFeeRate = 500;

  // 最低手数料額
  // 1 = 1dJPY
  // amount * 手数料率で算出した金額がここで設定した最低手数料を下回る場合は、最低手数料額を手数料とする
  uint8 _transferMinimumFee = 5;

  address tokenAddress;
  address multiSigAddress;
  address authorityAddress;

  // @NOTE リリース時にcontractのdeploy -> watch contract -> setOwnerの流れを
  //省略したい場合は、ここで直接controllerのアドレスを指定するとショートカットできます
  // 勿論テストは通らなくなるので、テストが通ったら試してね
  constructor() public DSAuth() {
    /*address controllerAddress = 0x34c5605A4Ef1C98575DB6542179E55eE1f77A188;
    owner = controllerAddress;
    LogSetOwner(controllerAddress);*/
  }

  function changeToken(address tokenAddress_) public auth {
    tokenAddress = tokenAddress_;
  }

  function changeAssociation(address multiSigAddress_) public auth {
    multiSigAddress = multiSigAddress_;
  }

  function changeAuthority(address authorityAddress_) public auth {
    authorityAddress = authorityAddress_;
  }

  // --------------------------------------------------
  // functions for _totalSupply
  // --------------------------------------------------

  /**
   * 総発行額を返す
   *
   * @return 総発行額
   */
  function totalSupply() public view auth returns (uint) {
    return _totalSupply;
  }

  /**
   * 総発行数を増やす（mintと並行して呼ばれることを想定）
   *
   * @param amount 鋳造数
   */
  function addTotalSupply(uint amount) public auth {
    _totalSupply = add(_totalSupply, amount);
  }

  /**
   * 総発行数を減らす（burnと並行して呼ばれることを想定）
   *
   * @param amount 鋳造数
   */
  function subTotalSupply(uint amount) public auth {
    _totalSupply = sub(_totalSupply, amount);
  }

  // --------------------------------------------------
  // functions for _transferFeeRate
  // --------------------------------------------------

  /**
   * 手数料率を返す
   *
   * @return 現在の手数料率
   */
  function transferFeeRate() public view auth returns (uint) {
    return _transferFeeRate;
  }

  /**
   * 手数料率を変更する
   *
   * @param newTransferFeeRate 新しい手数料率
   *
   * @return 更新に成功したらtrue、失敗したらfalse（今のところ失敗するケースはない）
   */
  function setTransferFeeRate(uint newTransferFeeRate) public auth returns (bool) {
    _transferFeeRate = newTransferFeeRate;

    return true;
  }

  // --------------------------------------------------
  // functions for _transferMinimumFee
  // --------------------------------------------------

  /**
   * 最低手数料返す
   *
   * @return 現在の最低手数料
   */
  function transferMinimumFee() public view auth returns (uint8) {
    return _transferMinimumFee;
  }

  /**
   * 最低手数料を変更する
   *
   * @param newTransferMinimumFee 新しい最低手数料
   *
   * @return 更新に成功したらtrue、失敗したらfalse（今のところ失敗するケースはない）
   */
  function setTransferMinimumFee(uint8 newTransferMinimumFee) public auth {
    _transferMinimumFee = newTransferMinimumFee;
  }

  // --------------------------------------------------
  // functions for ownerAddresses
  // --------------------------------------------------

  /**
   * 指定したユーザーアドレスをオーナーの一覧に追加する
   *
   * トークンの移動時に内部的にオーナーのアドレスを管理するための関数。
   * トークンの所有者 = オーナーという扱いになったので、この配列に含まれるアドレスの一覧は
   * 手数料からの収益の分配をする時に利用するだけで、オーナーかどうかの判定には利用しない
   *
   * @param addr ユーザーのアドレス
   *
   * @return 処理に成功したらtrue、失敗したらfalse
   */
  function addOwnerAddress(address addr) internal returns (bool) {
    ownerAddresses.push(addr);

    return true;
  }

  /**
   * 指定したユーザーアドレスをオーナーの一覧から削除する
   *
   * トークンの移動時に内部的にオーナーのアドレスを管理するための関数。
   *
   * @param addr オーナーに属するユーザーのアドレス
   *
   * @return 処理に成功したらtrue、失敗したらfalse
   */
  function removeOwnerAddress(address addr) internal returns (bool) {
    uint i = 0;

    while (ownerAddresses[i] != addr) { i++; }

    while (i < ownerAddresses.length - 1) {
      ownerAddresses[i] = ownerAddresses[i + 1];
      i++;
    }

    ownerAddresses.length--;

    return true;
  }

  /**
   * 最初のオーナー（contractをdeployしたユーザー）のアドレスを返す
   *
   * @return 最初のオーナーのアドレス
   */
  function primaryOwner() public view auth returns (address) {
    return ownerAddresses[0];
  }

  /**
   * 指定したアドレスがオーナーアドレスに登録されているか返す
   *
   * @param addr ユーザーのアドレス
   *
   * @return オーナーに含まれている場合はtrue、含まれていない場合はfalse
   */
  function isOwnerAddress(address addr) public view auth returns (bool) {
    for (uint i = 0; i < ownerAddresses.length; i++) {
      if (ownerAddresses[i] == addr) return true;
    }

    return false;
  }

  /**
   * オーナー数を返す
   *
   * @return オーナー数
   */
  function numOwnerAddress() public view auth returns (uint) {
    return ownerAddresses.length;
  }

  // --------------------------------------------------
  // functions for coinBalances
  // --------------------------------------------------

  /**
   * 指定したユーザーのdJPY残高を返す
   *
   * @param addr ユーザーのアドレス
   *
   * @return dJPY残高
   */
  function coinBalance(address addr) public view auth returns (uint) {
    return coinBalances[addr];
  }

  /**
   * 指定したユーザーのdJPYの残高を増やす
   *
   * @param addr ユーザーのアドレス
   * @param amount 差分
   *
   * @return 処理に成功したらtrue、失敗したらfalse
   */
  function addCoinBalance(address addr, uint amount) public auth returns (bool) {
    coinBalances[addr] = add(coinBalances[addr], amount);

    return true;
  }

  /**
   * 指定したユーザーのdJPYの残高を減らす
   *
   * @param addr ユーザーのアドレス
   * @param amount 差分
   *
   * @return 処理に成功したらtrue、失敗したらfalse
   */
  function subCoinBalance(address addr, uint amount) public auth returns (bool) {
    coinBalances[addr] = sub(coinBalances[addr], amount);

    return true;
  }

  // --------------------------------------------------
  // functions for tokenBalances
  // --------------------------------------------------

  /**
   * 指定したユーザーのSHINJIトークンの残高を返す
   *
   * @param addr ユーザーのアドレス
   *
   * @return SHINJIトークン残高
   */
  function tokenBalance(address addr) public view auth returns (uint) {
    return tokenBalances[addr];
  }

  /**
   * 指定したユーザーのSHINJIトークンの残高を増やす
   *
   * @param addr ユーザーのアドレス
   * @param amount 差分
   *
   * @return 処理に成功したらtrue、失敗したらfalse
   */
  function addTokenBalance(address addr, uint amount) public auth returns (bool) {
    tokenBalances[addr] = add(tokenBalances[addr], amount);

    if (tokenBalances[addr] > 0 && !isOwnerAddress(addr)) {
      addOwnerAddress(addr);
    }

    return true;
  }

  /**
   * 指定したユーザーのSHINJIトークンの残高を減らす
   *
   * @param addr ユーザーのアドレス
   * @param amount 差分
   *
   * @return 処理に成功したらtrue、失敗したらfalse
   */
  function subTokenBalance(address addr, uint amount) public auth returns (bool) {
    tokenBalances[addr] = sub(tokenBalances[addr], amount);

    if (tokenBalances[addr] <= 0) {
      removeOwnerAddress(addr);
    }

    return true;
  }

  // --------------------------------------------------
  // functions for coinAllowances
  // --------------------------------------------------

  /**
   * 送金許可金額を返す
   *
   * @param owner_ 送金者
   * @param spender 送金代行者
   *
   * @return 送金許可金額
   */
  function coinAllowance(address owner_, address spender) public view auth returns (uint) {
    return coinAllowances[owner_][spender];
  }

  /**
   * 送金許可金額を指定した金額だけ増やす
   *
   * @param owner_ 送金者
   * @param spender 送金代行者
   * @param amount 金額
   *
   * @return 更新に成功したらtrue、失敗したらfalse
   */
  function addCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
    coinAllowances[owner_][spender] = add(coinAllowances[owner_][spender], amount);

    return true;
  }

  /**
   * 送金許可金額を指定した金額だけ減らす
   *
   * @param owner_ 送金者
   * @param spender 送金代行者
   * @param amount 金額
   *
   * @return 更新に成功したらtrue、失敗したらfalse
   */
  function subCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
    coinAllowances[owner_][spender] = sub(coinAllowances[owner_][spender], amount);

    return true;
  }

  /**
   * 送金許可金額を指定した値に更新する
   *
   * @param owner_ 送金者
   * @param spender 送金代行者
   * @param amount 送金許可金額
   *
   * @return 指定に成功したらtrue、失敗したらfalse
   */
  function setCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
    coinAllowances[owner_][spender] = amount;

    return true;
  }

  /**
   * 権限チェック用関数のoverride
   *
   * @param src 実行者アドレス
   * @param sig 実行関数の識別子
   *
   * @return 実行が許可されていればtrue、そうでなければfalse
   */
  function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
    sig; // #HACK

    return  src == address(this) ||
            src == owner ||
            src == tokenAddress ||
            src == authorityAddress ||
            src == multiSigAddress;
  }
}


// import './IkuraTokenEvent.sol';
/**
 * Tokenでの処理に関するイベント定義
 *
 * - ERC20に準拠したイベント（Transfer / Approval）
 * - IkuraTokenの独自イベント（TransferToken / TransferFee）
 */
contract IkuraTokenEvent {
  /** オーナーがdJPYを鋳造した際に発火するイベント */
  event IkuraMint(address indexed owner, uint);

  /** オーナーがdJPYを消却した際に発火するイベント */
  event IkuraBurn(address indexed owner, uint);

  /** トークンの移動時に発火するイベント */
  event IkuraTransferToken(address indexed from, address indexed to, uint value);

  /** 手数料が発生したときに発火するイベント */
  event IkuraTransferFee(address indexed from, address indexed to, address indexed owner, uint value);

  /**
   * テスト時にこのイベントも流れてくるはずなので追加で定義
   * controllerでもイベントを発火させているが、ゆくゆくはここでIkuraTokenのバージョンとか追加の情報を投げる可能性もあるので残留。
   */
  event IkuraTransfer(address indexed from, address indexed to, uint value);

  /** 送金許可イベント */
  event IkuraApproval(address indexed owner, address indexed spender, uint value);
}


// import './IkuraToken.sol';
/**
 *
 * トークンロジック
 *
 */
contract IkuraToken is IkuraTokenEvent, DSMath, DSAuth {
  //
  // constants
  //

  // 手数料率
  // 0.01pips = 1
  // 例). 手数料を 0.05% とする場合は 500
  uint _transferFeeRate = 0;

  // 最低手数料額
  // 1 = 1dJPY
  // amount * 手数料率で算出した金額がここで設定した最低手数料を下回る場合は、最低手数料額を手数料とする
  uint8 _transferMinimumFee = 0;

  // ロジックバージョン
  uint _logicVersion = 2;

  //
  // libraries
  //

  /*using ProposalLibrary for ProposalLibrary.Entity;
  ProposalLibrary.Entity proposalEntity;*/

  //
  // private
  //

  // データの永続化ストレージ
  IkuraStorage _storage;
  IkuraAssociation _association;

  constructor() DSAuth() public {
    // @NOTE リリース時にcontractのdeploy -> watch contract -> setOwnerの流れを
    //省略したい場合は、ここで直接controllerのアドレスを指定するとショートカットできます
    // 勿論テストは通らなくなるので、テストが通ったら試してね
    /*address controllerAddress = 0x34c5605A4Ef1C98575DB6542179E55eE1f77A188;
    owner = controllerAddress;
    LogSetOwner(controllerAddress);*/
  }

  // ----------------------------------------------------------------------------------------------------
  // 以降はERC20に準拠した関数
  // ----------------------------------------------------------------------------------------------------

  /**
   * ERC20 Token Standardに準拠した関数
   *
   * dJPYの発行高を返す
   *
   * @return 発行高
   */
  function totalSupply(address sender) public view returns (uint) {
    sender; // #HACK

    return _storage.totalSupply();
  }

  /**
   * ERC20 Token Standardに準拠した関数
   *
   * 特定のアドレスのdJPY残高を返す
   *
   * @param sender 実行アドレス
   * @param addr アドレス
   *
   * @return 指定したアドレスのdJPY残高
   */
  function balanceOf(address sender, address addr) public view returns (uint) {
    sender; // #HACK

    return _storage.coinBalance(addr);
  }

  /**
   * ERC20 Token Standardに準拠した関数
   *
   * 指定したアドレスに対してdJPYを送金する
   * 以下の条件を満たす必要がある
   *
   * - メッセージの送信者の残高 >= 送金額
   * - 送金額 > 0
   * - 送金先のアドレスの残高 + 送金額 > 送金元のアドレスの残高（overflowのチェックらしい）
   *
   * @param sender 送金元アドレス
   * @param to 送金対象アドレス
   * @param amount 送金額
   *
   * @return 条件を満たして処理に成功した場合はtrue、失敗した場合はfalse
   */
  function transfer(address sender, address to, uint amount) public auth returns (bool success) {
    uint fee = transferFee(sender, sender, to, amount);
    uint totalAmount = add(amount, fee);

    require(_storage.coinBalance(sender) >= totalAmount);
    require(amount > 0);

    // 実行者の口座からamount + feeの金額が控除される
    _storage.subCoinBalance(sender, totalAmount);

    // toの口座にamountが振り込まれる
    _storage.addCoinBalance(to, amount);

    if (fee > 0) {
      // 手数料を受け取るオーナーのアドレスを選定
      address owner = selectOwnerAddressForTransactionFee(sender);

      // オーナーの口座にfeeが振り込まれる
      _storage.addCoinBalance(owner, fee);
    }

    return true;
  }

  /**
   * ERC20 Token Standardに準拠した関数
   *
   * from（送信元のアドレス）からto（送信先のアドレス）へamount分だけ送金する。
   * 主に口座からの引き出しに利用され、契約によってサブ通貨の送金手数料を徴収することができるようになる。
   * この操作はfrom（送信元のアドレス）が何らかの方法で意図的に送信者を許可する場合を除いて失敗すべき。
   * この許可する処理はapproveコマンドで実装しましょう。
   *
   * 以下の条件を満たす場合だけ送金を認める
   *
   * - 送信元の残高 >= 金額
   * - 送金する金額 > 0
   * - 送信者に対して送信元が許可している金額 >= 送金する金額
   * - 送信先の残高 + 金額 > 送信元の残高（overflowのチェックらしい）
   # - 送金処理を行うユーザーの口座残高 >= 送金処理の手数料
   *
   * @param sender 実行アドレス
   * @param from 送金元アドレス
   * @param to 送金先アドレス
   * @param amount 送金額
   *
   * @return 条件を満たして処理に成功した場合はtrue、失敗した場合はfalse
   */
  function transferFrom(address sender, address from, address to, uint amount) public auth returns (bool success) {
    uint fee = transferFee(sender, from, to, amount);

    require(_storage.coinBalance(from) >= amount);
    require(_storage.coinAllowance(from, sender) >= amount);
    require(amount > 0);
    require(add(_storage.coinBalance(to), amount) > _storage.coinBalance(to));

    if (fee > 0) {
      require(_storage.coinBalance(sender) >= fee);

      // 手数料を受け取るオーナーのアドレスを選定
      address owner = selectOwnerAddressForTransactionFee(sender);

      // 手数料はこの関数を実行したユーザー（主に取引所とか）から徴収する
      _storage.subCoinBalance(sender, fee);

      _storage.addCoinBalance(owner, fee);
    }

    // 送金元から送金額を引く
    _storage.subCoinBalance(from, amount);

    // 送金許可している金額を減らす
    _storage.subCoinAllowance(from, sender, amount);

    // 送金口座に送金額を足す
    _storage.addCoinBalance(to, amount);

    return true;
  }

  /**
   * ERC20 Token Standardに準拠した関数
   *
   * spender（支払い元のアドレス）にsender（送信者）がamount分だけ支払うのを許可する
   * この関数が呼ばれる度に送金可能な金額を更新する。
   *
   * @param sender 実行アドレス
   * @param spender 送金元アドレス
   * @param amount 送金額
   *
   * @return 基本的にtrueを返す
   */
  function approve(address sender, address spender, uint amount) public auth returns (bool success) {
    _storage.setCoinAllowance(sender, spender, amount);

    return true;
  }

  /**
   * ERC20 Token Standardに準拠した関数
   *
   * 受取側に対して支払い側がどれだけ送金可能かを返す
   *
   * @param sender 実行アドレス
   * @param owner 受け取り側のアドレス
   * @param spender 支払い元のアドレス
   *
   * @return 許可されている送金料
   */
  function allowance(address sender, address owner, address spender) public view returns (uint remaining) {
    sender; // #HACK

    return _storage.coinAllowance(owner, spender);
  }

  // ----------------------------------------------------------------------------------------------------
  // 以降はERC20以外の独自実装
  // ----------------------------------------------------------------------------------------------------

  /**
   * 特定のアドレスのSHINJI残高を返す
   *
   * @param sender 実行アドレス
   * @param owner アドレス
   *
   * @return 指定したアドレスのSHINJIトークン量
   */
  function tokenBalanceOf(address sender, address owner) public view returns (uint balance) {
    sender; // #HACK

    return _storage.tokenBalance(owner);
  }

  /**
   * 指定したアドレスに対してSHINJIトークンを送金する
   *
   * - 送信元の残トークン量 >= トークン量
   * - 送信するトークン量 > 0
   * - 送信先の残高 + 金額 > 送信元の残高（overflowのチェック）
   *
   * @param sender 実行アドレス
   * @param to 送金対象アドレス
   * @param amount 送金額
   *
   * @return 条件を満たして処理に成功した場合はtrue、失敗した場合はfalse
   */
  function transferToken(address sender, address to, uint amount) public auth returns (bool success) {
    require(_storage.tokenBalance(sender) >= amount);
    require(amount > 0);
    require(add(_storage.tokenBalance(to), amount) > _storage.tokenBalance(to));

    _storage.subTokenBalance(sender, amount);
    _storage.addTokenBalance(to, amount);

    emit IkuraTransferToken(sender, to, amount);

    return true;
  }

  /**
   * 送金元、送金先、送金金額によって対象のトランザクションの手数料を決定する
   * 送金金額に対して手数料率をかけたものを計算し、最低手数料金額とのmax値を取る。
   *
   * @param sender 実行アドレス
   * @param from 送金元
   * @param to 送金先
   * @param amount 送金金額
   *
   * @return 手数料金額
   */
  function transferFee(address sender, address from, address to, uint amount) public view returns (uint) {
    sender; from; to; // #avoid warning
    if (_transferFeeRate > 0) {
      uint denominator = 1000000; // 0.01 pips だから 100 * 100 * 100 で 100万
      uint numerator = mul(amount, _transferFeeRate);

      uint fee = numerator / denominator;
      uint remainder = sub(numerator, mul(denominator, fee));

      // 余りがある場合はfeeに1を足す
      if (remainder > 0) {
        fee++;
      }

      if (fee < _transferMinimumFee) {
        fee = _transferMinimumFee;
      }

      return fee;
    } else {
      return 0;
    }
  }

  /**
   * 手数料率を返す
   *
   * @param sender 実行アドレス
   *
   * @return 手数料率
   */
  function transferFeeRate(address sender) public view returns (uint) {
    sender; // #HACK

    return _transferFeeRate;
  }

  /**
   * 最低手数料額を返す
   *
   * @param sender 実行アドレス
   *
   * @return 最低手数料額
   */
  function transferMinimumFee(address sender) public view returns (uint8) {
    sender; // #HACK

    return _transferMinimumFee;
  }

  /**
   * 手数料を振り込む口座を選択する
   * #TODO とりあえず一個目のオーナーに固定。後で選定ロジックを変える
   *
   * @param sender 実行アドレス
   * @return 特定のオーナー口座
   */
  function selectOwnerAddressForTransactionFee(address sender) public view returns (address) {
    sender; // #HACK

    return _storage.primaryOwner();
  }

  /**
   * dJPYを鋳造する
   *
   * - コマンドを実行したユーザがオーナーである
   * - 鋳造する量が0より大きい
   *
   * 場合は成功する
   *
   * @param sender 実行アドレス
   * @param amount 鋳造する金額
   */
  function mint(address sender, uint amount) public auth returns (bool) {
    require(amount > 0);

    _association.newProposal(keccak256('mint'), sender, amount, '');

    return true;
    /*return proposalEntity.mint(sender, amount);*/
  }

  /**
   * dJPYを消却する
   *
   * - コマンドを実行したユーザがオーナーである
   * - 鋳造する量が0より大きい
   * - dJPYの残高がamountよりも大きい
   * - SHINJIをamountよりも大きい
   *
   * 場合は成功する
   *
   * @param sender 実行アドレス
   * @param amount 消却する金額
   */
  function burn(address sender, uint amount) public auth returns (bool) {
    require(amount > 0);
    require(_storage.coinBalance(sender) >= amount);
    require(_storage.tokenBalance(sender) >= amount);

    _association.newProposal(keccak256('burn'), sender, amount, '');

    return true;
    /*return proposalEntity.burn(sender, amount);*/
  }

  /**
   * 提案を承認する。
   * #TODO proposalIdは分からないので、別のものからproposalを特定しないといかんよ
   */
  function confirmProposal(address sender, bytes32 type_, uint proposalId) public auth {
    _association.confirmProposal(type_, sender, proposalId);
    /*proposalEntity.confirmProposal(sender, type_, proposalId);*/
  }

  /**
   * 指定した種類の提案数を取得する
   *
   * @param type_ 提案の種類（'mint' | 'burn' | 'transferMinimumFee' | 'transferFeeRate'）
   *
   * @return 提案数（承認されていないものも含む）
   */
  function numberOfProposals(bytes32 type_) public view returns (uint) {
    return _association.numberOfProposals(type_);
    /*return proposalEntity.numberOfProposals(type_);*/
  }

  /**
   * 関連づける承認プロセスを変更する
   *
   * @param association_ 新しい承認プロセス
   */
  function changeAssociation(address association_) public auth returns (bool) {
    _association = IkuraAssociation(association_);
    return true;
  }

  /**
   * 永続化ストレージを設定する
   *
   * @param storage_ 永続化ストレージのインスタンス（アドレス）
   */
  function changeStorage(address storage_) public auth returns (bool) {
    _storage = IkuraStorage(storage_);
    return true;
  }

  /**
   * ロジックのバージョンを返す
   *
   * @param sender 実行ユーザーのアドレス
   *
   * @return バージョン情報
   */
  function logicVersion(address sender) public view returns (uint) {
    sender; // #HACK

    return _logicVersion;
  }
}

/**
 * 経過時間とSHINJI Tokenの所有比率によって特定のアクションの承認を行うクラス
 */
contract IkuraAssociation is DSMath, DSAuth {
  //
  // public
  //

  // 提案が承認されるために必要な賛成票の割合
  uint public confirmTotalTokenThreshold = 50;

  //
  // private
  //

  // データの永続化ストレージ
  IkuraStorage _storage;
  IkuraToken _token;

  // 提案一覧
  Proposal[] mintProposals;
  Proposal[] burnProposals;

  mapping (bytes32 => Proposal[]) proposals;

  struct Proposal {
    address proposer;                     // 提案者
    bytes32 digest;                       // チェックサム
    bool executed;                        // 実行の有無
    uint createdAt;                       // 提案作成日時
    uint expireAt;                        // 提案の締め切り
    address[] confirmers;                 // 承認者
    uint amount;                          // 鋳造量
  }

  //
  // Events
  //

  event MintProposalAdded(uint proposalId, address proposer, uint amount);
  event MintConfirmed(uint proposalId, address confirmer, uint amount);
  event MintExecuted(uint proposalId, address proposer, uint amount);

  event BurnProposalAdded(uint proposalId, address proposer, uint amount);
  event BurnConfirmed(uint proposalId, address confirmer, uint amount);
  event BurnExecuted(uint proposalId, address proposer, uint amount);

  constructor() public {
    proposals[keccak256('mint')] = mintProposals;
    proposals[keccak256('burn')] = burnProposals;

    // @NOTE リリース時にcontractのdeploy -> watch contract -> setOwnerの流れを
    //省略したい場合は、ここで直接controllerのアドレスを指定するとショートカットできます
    // 勿論テストは通らなくなるので、テストが通ったら試してね
    /*address controllerAddress = 0x34c5605A4Ef1C98575DB6542179E55eE1f77A188;
    owner = controllerAddress;
    LogSetOwner(controllerAddress);*/
  }

  /**
   * 永続化ストレージを設定する
   *
   * @param newStorage 永続化ストレージのインスタンス（アドレス）
   */
  function changeStorage(IkuraStorage newStorage) public auth returns (bool) {
    _storage = newStorage;
    return true;
  }

  function changeToken(IkuraToken token_) public auth returns (bool) {
    _token = token_;
    return true;
  }

  /**
   * 提案を作成する
   *
   * @param proposer 提案者のアドレス
   * @param amount 鋳造量
   */
  function newProposal(bytes32 type_, address proposer, uint amount, bytes transationBytecode) public returns (uint) {
    uint proposalId = proposals[type_].length++;
    Proposal storage proposal = proposals[type_][proposalId];
    proposal.proposer = proposer;
    proposal.amount = amount;
    proposal.digest = keccak256(proposer, amount, transationBytecode);
    proposal.executed = false;
    proposal.createdAt = now;
    proposal.expireAt = proposal.createdAt + 86400;

    // 提案の種類毎に実行すべき内容を実行する
    // @NOTE literal_stringとbytesは単純に比較できないのでkeccak256のハッシュ値で比較している
    if (type_ == keccak256('mint')) emit MintProposalAdded(proposalId, proposer, amount);
    if (type_ == keccak256('burn')) emit BurnProposalAdded(proposalId, proposer, amount);

    // 本人は当然承認
    confirmProposal(type_, proposer, proposalId);

    return proposalId;
  }

  /**
   * トークン所有者が提案に対して賛成する
   *
   * @param type_ 提案の種類
   * @param confirmer 承認者のアドレス
   * @param proposalId 提案ID
   */
  function confirmProposal(bytes32 type_, address confirmer, uint proposalId) public {
    Proposal storage proposal = proposals[type_][proposalId];

    // 既に承認済みの場合はエラーを返す
    require(!hasConfirmed(type_, confirmer, proposalId));

    // 承認行為を行ったフラグを立てる
    proposal.confirmers.push(confirmer);

    // 提案の種類毎に実行すべき内容を実行する
    // @NOTE literal_stringとbytesは単純に比較できないのでkeccak256のハッシュ値で比較している
    if (type_ == keccak256('mint')) emit MintConfirmed(proposalId, confirmer, proposal.amount);
    if (type_ == keccak256('burn')) emit BurnConfirmed(proposalId, confirmer, proposal.amount);

    if (isProposalExecutable(type_, proposalId, proposal.proposer, '')) {
      proposal.executed = true;

      // 提案の種類毎に実行すべき内容を実行する
      // @NOTE literal_stringとbytesは単純に比較できないのでkeccak256のハッシュ値で比較している
      if (type_ == keccak256('mint')) executeMintProposal(proposalId);
      if (type_ == keccak256('burn')) executeBurnProposal(proposalId);
    }
  }

  /**
   * 既に承認済みの提案かどうかを返す
   *
   * @param type_ 提案の種類
   * @param addr 承認者のアドレス
   * @param proposalId 提案ID
   *
   * @return 承認済みであればtrue、そうでなければfalse
   */
  function hasConfirmed(bytes32 type_, address addr, uint proposalId) internal view returns (bool) {
    Proposal storage proposal = proposals[type_][proposalId];
    uint length = proposal.confirmers.length;

    for (uint i = 0; i < length; i++) {
      if (proposal.confirmers[i] == addr) return true;
    }

    return false;
  }

  /**
   * 指定した提案を承認したトークンの総量を返す
   *
   * @param type_ 提案の種類
   * @param proposalId 提案ID
   *
   * @return 承認に投票されたトークン数
   */
  function confirmedTotalToken(bytes32 type_, uint proposalId) internal view returns (uint) {
    Proposal storage proposal = proposals[type_][proposalId];
    uint length = proposal.confirmers.length;
    uint total = 0;

    for (uint i = 0; i < length; i++) {
      total = add(total, _storage.tokenBalance(proposal.confirmers[i]));
    }

    return total;
  }

  /**
   * 指定した提案の締め切りを返す
   *
   * @param type_ 提案の種類
   * @param proposalId 提案ID
   *
   * @return 提案の締め切り
   */
  function proposalExpireAt(bytes32 type_, uint proposalId) public view returns (uint) {
    Proposal storage proposal = proposals[type_][proposalId];
    return proposal.expireAt;
  }

  /**
   * 提案が実行条件を満たしているかを返す
   *
   * 【承認条件】
   * - まだ実行していない
   * - 提案の有効期限内である
   * - 指定した割合以上の賛成トークンを得ている
   *
   * @param proposalId 提案ID
   *
   * @return 実行条件を満たしている場合はtrue、そうでない場合はfalse
   */
  function isProposalExecutable(bytes32 type_, uint proposalId, address proposer, bytes transactionBytecode) internal view returns (bool) {
    Proposal storage proposal = proposals[type_][proposalId];

    // オーナーがcontrollerを登録したユーザーしか存在しない場合は
    if (_storage.numOwnerAddress() < 2) {
      return true;
    }

    return  proposal.digest == keccak256(proposer, proposal.amount, transactionBytecode) &&
            isProposalNotExpired(type_, proposalId) &&
            mul(100, confirmedTotalToken(type_, proposalId)) / _storage.totalSupply() > confirmTotalTokenThreshold;
  }

  /**
   * 指定した種類の提案数を取得する
   *
   * @param type_ 提案の種類（'mint' | 'burn' | 'transferMinimumFee' | 'transferFeeRate'）
   *
   * @return 提案数（承認されていないものも含む）
   */
  function numberOfProposals(bytes32 type_) public constant returns (uint) {
    return proposals[type_].length;
  }

  /**
   * 未承認で有効期限の切れていない提案の数を返す
   *
   * @param type_ 提案の種類（'mint' | 'burn' | 'transferMinimumFee' | 'transferFeeRate'）
   *
   * @return 提案数
   */
  function numberOfActiveProposals(bytes32 type_) public view returns (uint) {
    uint numActiveProposal = 0;

    for(uint i = 0; i < proposals[type_].length; i++) {
      if (isProposalNotExpired(type_, i)) {
        numActiveProposal++;
      }
    }

    return numActiveProposal;
  }

  /**
   * 提案の有効期限が切れていないかチェックする
   *
   * - 実行されていない
   * - 有効期限が切れていない
   *
   * 場合のみtrueを返す
   */
  function isProposalNotExpired(bytes32 type_, uint proposalId) internal view returns (bool) {
    Proposal storage proposal = proposals[type_][proposalId];

    return  !proposal.executed &&
            now < proposal.expireAt;
  }

  /**
   * dJPYを鋳造する
   *
   * - 鋳造する量が0より大きい
   *
   * 場合は成功する
   *
   * @param proposalId 提案ID
   */
  function executeMintProposal(uint proposalId) internal returns (bool) {
    Proposal storage proposal = proposals[keccak256('mint')][proposalId];

    // ここでも念のためチェックを入れる
    require(proposal.amount > 0);

    emit MintExecuted(proposalId, proposal.proposer, proposal.amount);

    // 総供給量 / 実行者のdJPY / 実行者のSHINJI tokenを増やす
    _storage.addTotalSupply(proposal.amount);
    _storage.addCoinBalance(proposal.proposer, proposal.amount);
    _storage.addTokenBalance(proposal.proposer, proposal.amount);

    return true;
  }

  /**
   * dJPYを消却する
   *
   * - 消却する量が0より大きい
   * - 提案者の所有するdJPYの残高がamount以上
   * - 提案者の所有するSHINJIがamountよりも大きい
   *
   * 場合は成功する
   *
   * @param proposalId 提案ID
   */
  function executeBurnProposal(uint proposalId) internal returns (bool) {
    Proposal storage proposal = proposals[keccak256('burn')][proposalId];

    // ここでも念のためチェックを入れる
    require(proposal.amount > 0);
    require(_storage.coinBalance(proposal.proposer) >= proposal.amount);
    require(_storage.tokenBalance(proposal.proposer) >= proposal.amount);

    emit BurnExecuted(proposalId, proposal.proposer, proposal.amount);

    // 総供給量 / 実行者のdJPY / 実行者のSHINJI tokenを減らす
    _storage.subTotalSupply(proposal.amount);
    _storage.subCoinBalance(proposal.proposer, proposal.amount);
    _storage.subTokenBalance(proposal.proposer, proposal.amount);

    return true;
  }

  function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
    sig; // #HACK

    return  src == address(this) ||
            src == owner ||
            src == address(_token);
  }
}