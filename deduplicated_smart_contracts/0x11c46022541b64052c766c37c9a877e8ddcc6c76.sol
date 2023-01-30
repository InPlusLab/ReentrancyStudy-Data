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
 * ���å��θ��¤�Ӱ푤���ʤ����A���ǩ`���򱣳֤��륯�饹
 *
 */
contract IkuraStorage is DSMath, DSAuth {
  // ���`�ʩ`�������y�У��Υ��ɥ쥹
  address[] ownerAddresses;

  // �����ɥ쥹��dJPY�ο����и�
  mapping(address => uint) coinBalances;

  // �����ɥ쥹��SHINJI token�ο����и�
  mapping(address => uint) tokenBalances;

  // �����ɥ쥹��ָ���������ɥ쥹�ˌ������S�ɤ�������ͽ��~
  mapping(address => mapping (address => uint)) coinAllowances;

  // dJPY�ΰk�и�
  uint _totalSupply = 0;

  // ��������
  // 0.01pips = 1
  // ��). �����Ϥ� 0.05% �Ȥ�����Ϥ� 500
  uint _transferFeeRate = 500;

  // ����������~
  // 1 = 1dJPY
  // amount * �������ʤ�����������~���������O��������������Ϥ��»ؤ���Ϥϡ�����������~�������ϤȤ���
  uint8 _transferMinimumFee = 5;

  address tokenAddress;
  address multiSigAddress;
  address authorityAddress;

  // @NOTE ���`���r��contract��deploy -> watch contract -> setOwner�������
  //ʡ�Ԥ��������Ϥϡ�������ֱ��controller�Υ��ɥ쥹��ָ������ȥ���`�ȥ��åȤǤ��ޤ�
  // ��Փ�ƥ��Ȥ�ͨ��ʤ��ʤ�Τǡ��ƥ��Ȥ�ͨ�ä���ԇ���Ƥ�
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
   * �t�k���~�򷵤�
   *
   * @return �t�k���~
   */
  function totalSupply() public view auth returns (uint) {
    return _totalSupply;
  }

  /**
   * �t�k�����򉈤䤹��mint�ȁK�Ф��ƺ��Ф�뤳�Ȥ��붨��
   *
   * @param amount �����
   */
  function addTotalSupply(uint amount) public auth {
    _totalSupply = add(_totalSupply, amount);
  }

  /**
   * �t�k������p�餹��burn�ȁK�Ф��ƺ��Ф�뤳�Ȥ��붨��
   *
   * @param amount �����
   */
  function subTotalSupply(uint amount) public auth {
    _totalSupply = sub(_totalSupply, amount);
  }

  // --------------------------------------------------
  // functions for _transferFeeRate
  // --------------------------------------------------

  /**
   * �������ʤ򷵤�
   *
   * @return �F�ڤ���������
   */
  function transferFeeRate() public view auth returns (uint) {
    return _transferFeeRate;
  }

  /**
   * �������ʤ�������
   *
   * @param newTransferFeeRate �¤�����������
   *
   * @return ���¤˳ɹ�������true��ʧ��������false����ΤȤ���ʧ�����륱�`���Ϥʤ���
   */
  function setTransferFeeRate(uint newTransferFeeRate) public auth returns (bool) {
    _transferFeeRate = newTransferFeeRate;

    return true;
  }

  // --------------------------------------------------
  // functions for _transferMinimumFee
  // --------------------------------------------------

  /**
   * ��������Ϸ���
   *
   * @return �F�ڤ����������
   */
  function transferMinimumFee() public view auth returns (uint8) {
    return _transferMinimumFee;
  }

  /**
   * ��������Ϥ�������
   *
   * @param newTransferMinimumFee �¤������������
   *
   * @return ���¤˳ɹ�������true��ʧ��������false����ΤȤ���ʧ�����륱�`���Ϥʤ���
   */
  function setTransferMinimumFee(uint8 newTransferMinimumFee) public auth {
    _transferMinimumFee = newTransferMinimumFee;
  }

  // --------------------------------------------------
  // functions for ownerAddresses
  // --------------------------------------------------

  /**
   * ָ��������`���`���ɥ쥹�򥪩`�ʩ`��һ�E��׷�Ӥ���
   *
   * �ȩ`������Ƅӕr���ڲ��Ĥ˥��`�ʩ`�Υ��ɥ쥹������뤿����v����
   * �ȩ`����������� = ���`�ʩ`�Ȥ����Q���ˤʤä��Τǡ��������Ф˺��ޤ�륢�ɥ쥹��һ�E��
   * �����Ϥ���΅���η���򤹤�r�����ä�������ǡ����`�ʩ`���ɤ������ж��ˤ����ä��ʤ�
   *
   * @param addr ��`���`�Υ��ɥ쥹
   *
   * @return �I��˳ɹ�������true��ʧ��������false
   */
  function addOwnerAddress(address addr) internal returns (bool) {
    ownerAddresses.push(addr);

    return true;
  }

  /**
   * ָ��������`���`���ɥ쥹�򥪩`�ʩ`��һ�E������������
   *
   * �ȩ`������Ƅӕr���ڲ��Ĥ˥��`�ʩ`�Υ��ɥ쥹������뤿����v����
   *
   * @param addr ���`�ʩ`���������`���`�Υ��ɥ쥹
   *
   * @return �I��˳ɹ�������true��ʧ��������false
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
   * ����Υ��`�ʩ`��contract��deploy������`���`���Υ��ɥ쥹�򷵤�
   *
   * @return ����Υ��`�ʩ`�Υ��ɥ쥹
   */
  function primaryOwner() public view auth returns (address) {
    return ownerAddresses[0];
  }

  /**
   * ָ���������ɥ쥹�����`�ʩ`���ɥ쥹�˵��h����Ƥ��뤫����
   *
   * @param addr ��`���`�Υ��ɥ쥹
   *
   * @return ���`�ʩ`�˺��ޤ�Ƥ�����Ϥ�true�����ޤ�Ƥ��ʤ����Ϥ�false
   */
  function isOwnerAddress(address addr) public view auth returns (bool) {
    for (uint i = 0; i < ownerAddresses.length; i++) {
      if (ownerAddresses[i] == addr) return true;
    }

    return false;
  }

  /**
   * ���`�ʩ`���򷵤�
   *
   * @return ���`�ʩ`��
   */
  function numOwnerAddress() public view auth returns (uint) {
    return ownerAddresses.length;
  }

  // --------------------------------------------------
  // functions for coinBalances
  // --------------------------------------------------

  /**
   * ָ��������`���`��dJPY�иߤ򷵤�
   *
   * @param addr ��`���`�Υ��ɥ쥹
   *
   * @return dJPY�и�
   */
  function coinBalance(address addr) public view auth returns (uint) {
    return coinBalances[addr];
  }

  /**
   * ָ��������`���`��dJPY�βиߤ򉈤䤹
   *
   * @param addr ��`���`�Υ��ɥ쥹
   * @param amount ���
   *
   * @return �I��˳ɹ�������true��ʧ��������false
   */
  function addCoinBalance(address addr, uint amount) public auth returns (bool) {
    coinBalances[addr] = add(coinBalances[addr], amount);

    return true;
  }

  /**
   * ָ��������`���`��dJPY�βиߤ�p�餹
   *
   * @param addr ��`���`�Υ��ɥ쥹
   * @param amount ���
   *
   * @return �I��˳ɹ�������true��ʧ��������false
   */
  function subCoinBalance(address addr, uint amount) public auth returns (bool) {
    coinBalances[addr] = sub(coinBalances[addr], amount);

    return true;
  }

  // --------------------------------------------------
  // functions for tokenBalances
  // --------------------------------------------------

  /**
   * ָ��������`���`��SHINJI�ȩ`����βиߤ򷵤�
   *
   * @param addr ��`���`�Υ��ɥ쥹
   *
   * @return SHINJI�ȩ`����и�
   */
  function tokenBalance(address addr) public view auth returns (uint) {
    return tokenBalances[addr];
  }

  /**
   * ָ��������`���`��SHINJI�ȩ`����βиߤ򉈤䤹
   *
   * @param addr ��`���`�Υ��ɥ쥹
   * @param amount ���
   *
   * @return �I��˳ɹ�������true��ʧ��������false
   */
  function addTokenBalance(address addr, uint amount) public auth returns (bool) {
    tokenBalances[addr] = add(tokenBalances[addr], amount);

    if (tokenBalances[addr] > 0 && !isOwnerAddress(addr)) {
      addOwnerAddress(addr);
    }

    return true;
  }

  /**
   * ָ��������`���`��SHINJI�ȩ`����βиߤ�p�餹
   *
   * @param addr ��`���`�Υ��ɥ쥹
   * @param amount ���
   *
   * @return �I��˳ɹ�������true��ʧ��������false
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
   * �ͽ��S�ɽ��~�򷵤�
   *
   * @param owner_ �ͽ���
   * @param spender �ͽ������
   *
   * @return �ͽ��S�ɽ��~
   */
  function coinAllowance(address owner_, address spender) public view auth returns (uint) {
    return coinAllowances[owner_][spender];
  }

  /**
   * �ͽ��S�ɽ��~��ָ���������~�������䤹
   *
   * @param owner_ �ͽ���
   * @param spender �ͽ������
   * @param amount ���~
   *
   * @return ���¤˳ɹ�������true��ʧ��������false
   */
  function addCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
    coinAllowances[owner_][spender] = add(coinAllowances[owner_][spender], amount);

    return true;
  }

  /**
   * �ͽ��S�ɽ��~��ָ���������~�����p�餹
   *
   * @param owner_ �ͽ���
   * @param spender �ͽ������
   * @param amount ���~
   *
   * @return ���¤˳ɹ�������true��ʧ��������false
   */
  function subCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
    coinAllowances[owner_][spender] = sub(coinAllowances[owner_][spender], amount);

    return true;
  }

  /**
   * �ͽ��S�ɽ��~��ָ���������˸��¤���
   *
   * @param owner_ �ͽ���
   * @param spender �ͽ������
   * @param amount �ͽ��S�ɽ��~
   *
   * @return ָ���˳ɹ�������true��ʧ��������false
   */
  function setCoinAllowance(address owner_, address spender, uint amount) public auth returns (bool) {
    coinAllowances[owner_][spender] = amount;

    return true;
  }

  /**
   * ���ޥ����å����v����override
   *
   * @param src �g���ߥ��ɥ쥹
   * @param sig �g���v�����R�e��
   *
   * @return �g�Ф��S�ɤ���Ƥ����true�������Ǥʤ����false
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
 * Token�Ǥ΄I����v���륤�٥�ȶ��x
 *
 * - ERC20�˜ʒ��������٥�ȣ�Transfer / Approval��
 * - IkuraToken�ζ��ԥ��٥�ȣ�TransferToken / TransferFee��
 */
contract IkuraTokenEvent {
  /** ���`�ʩ`��dJPY����줷���H�˰k�𤹤륤�٥�� */
  event IkuraMint(address indexed owner, uint);

  /** ���`�ʩ`��dJPY����ȴ�����H�˰k�𤹤륤�٥�� */
  event IkuraBurn(address indexed owner, uint);

  /** �ȩ`������Ƅӕr�˰k�𤹤륤�٥�� */
  event IkuraTransferToken(address indexed from, address indexed to, uint value);

  /** �����Ϥ��k�������Ȥ��˰k�𤹤륤�٥�� */
  event IkuraTransferFee(address indexed from, address indexed to, address indexed owner, uint value);

  /**
   * �ƥ��ȕr�ˤ��Υ��٥�Ȥ�����Ƥ���Ϥ��ʤΤ�׷�ӤǶ��x
   * controller�Ǥ⥤�٥�Ȥ�k�𤵤��Ƥ��뤬���椯�椯�Ϥ�����IkuraToken�ΥЩ`�����Ȥ�׷�Ӥ�����Ͷ��������Ԥ⤢��Τǲ�����
   */
  event IkuraTransfer(address indexed from, address indexed to, uint value);

  /** �ͽ��S�ɥ��٥�� */
  event IkuraApproval(address indexed owner, address indexed spender, uint value);
}


// import './IkuraToken.sol';
/**
 *
 * �ȩ`������å�
 *
 */
contract IkuraToken is IkuraTokenEvent, DSMath, DSAuth {
  //
  // constants
  //

  // ��������
  // 0.01pips = 1
  // ��). �����Ϥ� 0.05% �Ȥ�����Ϥ� 500
  uint _transferFeeRate = 0;

  // ����������~
  // 1 = 1dJPY
  // amount * �������ʤ�����������~���������O��������������Ϥ��»ؤ���Ϥϡ�����������~�������ϤȤ���
  uint8 _transferMinimumFee = 0;

  // ���å��Щ`�����
  uint _logicVersion = 2;

  //
  // libraries
  //

  /*using ProposalLibrary for ProposalLibrary.Entity;
  ProposalLibrary.Entity proposalEntity;*/

  //
  // private
  //

  // �ǩ`�������A�����ȥ�`��
  IkuraStorage _storage;
  IkuraAssociation _association;

  constructor() DSAuth() public {
    // @NOTE ���`���r��contract��deploy -> watch contract -> setOwner�������
    //ʡ�Ԥ��������Ϥϡ�������ֱ��controller�Υ��ɥ쥹��ָ������ȥ���`�ȥ��åȤǤ��ޤ�
    // ��Փ�ƥ��Ȥ�ͨ��ʤ��ʤ�Τǡ��ƥ��Ȥ�ͨ�ä���ԇ���Ƥ�
    /*address controllerAddress = 0x34c5605A4Ef1C98575DB6542179E55eE1f77A188;
    owner = controllerAddress;
    LogSetOwner(controllerAddress);*/
  }

  // ----------------------------------------------------------------------------------------------------
  // �Խ���ERC20�˜ʒ������v��
  // ----------------------------------------------------------------------------------------------------

  /**
   * ERC20 Token Standard�˜ʒ������v��
   *
   * dJPY�ΰk�иߤ򷵤�
   *
   * @return �k�и�
   */
  function totalSupply(address sender) public view returns (uint) {
    sender; // #HACK

    return _storage.totalSupply();
  }

  /**
   * ERC20 Token Standard�˜ʒ������v��
   *
   * �ض��Υ��ɥ쥹��dJPY�иߤ򷵤�
   *
   * @param sender �g�Х��ɥ쥹
   * @param addr ���ɥ쥹
   *
   * @return ָ���������ɥ쥹��dJPY�и�
   */
  function balanceOf(address sender, address addr) public view returns (uint) {
    sender; // #HACK

    return _storage.coinBalance(addr);
  }

  /**
   * ERC20 Token Standard�˜ʒ������v��
   *
   * ָ���������ɥ쥹�ˌ�����dJPY���ͽ𤹤�
   * ���¤������򜺤�����Ҫ������
   *
   * - ��å��`���������ߤβи� >= �ͽ��~
   * - �ͽ��~ > 0
   * - �ͽ��ȤΥ��ɥ쥹�βи� + �ͽ��~ > �ͽ�Ԫ�Υ��ɥ쥹�βиߣ�overflow�Υ����å��餷����
   *
   * @param sender �ͽ�Ԫ���ɥ쥹
   * @param to �ͽ����󥢥ɥ쥹
   * @param amount �ͽ��~
   *
   * @return �����򜺤����ƄI��˳ɹ��������Ϥ�true��ʧ���������Ϥ�false
   */
  function transfer(address sender, address to, uint amount) public auth returns (bool success) {
    uint fee = transferFee(sender, sender, to, amount);
    uint totalAmount = add(amount, fee);

    require(_storage.coinBalance(sender) >= totalAmount);
    require(amount > 0);

    // �g���ߤο�������amount + fee�ν��~���س������
    _storage.subCoinBalance(sender, totalAmount);

    // to�ο�����amount������z�ޤ��
    _storage.addCoinBalance(to, amount);

    if (fee > 0) {
      // �����Ϥ��ܤ�ȡ�륪�`�ʩ`�Υ��ɥ쥹���x��
      address owner = selectOwnerAddressForTransactionFee(sender);

      // ���`�ʩ`�ο�����fee������z�ޤ��
      _storage.addCoinBalance(owner, fee);
    }

    return true;
  }

  /**
   * ERC20 Token Standard�˜ʒ������v��
   *
   * from������Ԫ�Υ��ɥ쥹������to�������ȤΥ��ɥ쥹����amount�֤����ͽ𤹤롣
   * ���˿���������������������ä��졢���s�ˤ�äƥ���ͨ؛���ͽ������Ϥ�Յ����뤳�Ȥ��Ǥ���褦�ˤʤ롣
   * ���β�����from������Ԫ�Υ��ɥ쥹�����Τ餫�η��������Ĥ������ߤ��S�ɤ�����Ϥ������ʧ�����٤���
   * �����S�ɤ���I���approve���ޥ�ɤǌgװ���ޤ��礦��
   *
   * ���¤������򜺤������Ϥ����ͽ���J���
   *
   * - ����Ԫ�βи� >= ���~
   * - �ͽ𤹤���~ > 0
   * - �����ߤˌ���������Ԫ���S�ɤ��Ƥ�����~ >= �ͽ𤹤���~
   * - �����Ȥβи� + ���~ > ����Ԫ�βиߣ�overflow�Υ����å��餷����
   # - �ͽ��I����Ф���`���`�ο����и� >= �ͽ��I���������
   *
   * @param sender �g�Х��ɥ쥹
   * @param from �ͽ�Ԫ���ɥ쥹
   * @param to �ͽ��ȥ��ɥ쥹
   * @param amount �ͽ��~
   *
   * @return �����򜺤����ƄI��˳ɹ��������Ϥ�true��ʧ���������Ϥ�false
   */
  function transferFrom(address sender, address from, address to, uint amount) public auth returns (bool success) {
    uint fee = transferFee(sender, from, to, amount);

    require(_storage.coinBalance(from) >= amount);
    require(_storage.coinAllowance(from, sender) >= amount);
    require(amount > 0);
    require(add(_storage.coinBalance(to), amount) > _storage.coinBalance(to));

    if (fee > 0) {
      require(_storage.coinBalance(sender) >= fee);

      // �����Ϥ��ܤ�ȡ�륪�`�ʩ`�Υ��ɥ쥹���x��
      address owner = selectOwnerAddressForTransactionFee(sender);

      // �����ϤϤ����v����g�Ф�����`���`������ȡ�����Ȥ�������Յ�����
      _storage.subCoinBalance(sender, fee);

      _storage.addCoinBalance(owner, fee);
    }

    // �ͽ�Ԫ�����ͽ��~������
    _storage.subCoinBalance(from, amount);

    // �ͽ��S�ɤ��Ƥ�����~��p�餹
    _storage.subCoinAllowance(from, sender, amount);

    // �ͽ�������ͽ��~���㤹
    _storage.addCoinBalance(to, amount);

    return true;
  }

  /**
   * ERC20 Token Standard�˜ʒ������v��
   *
   * spender��֧�B��Ԫ�Υ��ɥ쥹����sender�������ߣ���amount�֤���֧�B���Τ��S�ɤ���
   * �����v�������Ф��Ȥ��ͽ���ܤʽ��~����¤��롣
   *
   * @param sender �g�Х��ɥ쥹
   * @param spender �ͽ�Ԫ���ɥ쥹
   * @param amount �ͽ��~
   *
   * @return �����Ĥ�true�򷵤�
   */
  function approve(address sender, address spender, uint amount) public auth returns (bool success) {
    _storage.setCoinAllowance(sender, spender, amount);

    return true;
  }

  /**
   * ERC20 Token Standard�˜ʒ������v��
   *
   * ��ȡ�Ȥˌ�����֧�B���Ȥ��ɤ�����ͽ���ܤ��򷵤�
   *
   * @param sender �g�Х��ɥ쥹
   * @param owner �ܤ�ȡ��ȤΥ��ɥ쥹
   * @param spender ֧�B��Ԫ�Υ��ɥ쥹
   *
   * @return �S�ɤ���Ƥ����ͽ���
   */
  function allowance(address sender, address owner, address spender) public view returns (uint remaining) {
    sender; // #HACK

    return _storage.coinAllowance(owner, spender);
  }

  // ----------------------------------------------------------------------------------------------------
  // �Խ���ERC20����ζ��Ԍgװ
  // ----------------------------------------------------------------------------------------------------

  /**
   * �ض��Υ��ɥ쥹��SHINJI�иߤ򷵤�
   *
   * @param sender �g�Х��ɥ쥹
   * @param owner ���ɥ쥹
   *
   * @return ָ���������ɥ쥹��SHINJI�ȩ`������
   */
  function tokenBalanceOf(address sender, address owner) public view returns (uint balance) {
    sender; // #HACK

    return _storage.tokenBalance(owner);
  }

  /**
   * ָ���������ɥ쥹�ˌ�����SHINJI�ȩ`������ͽ𤹤�
   *
   * - ����Ԫ�βХȩ`������ >= �ȩ`������
   * - ���Ť���ȩ`������ > 0
   * - �����Ȥβи� + ���~ > ����Ԫ�βиߣ�overflow�Υ����å���
   *
   * @param sender �g�Х��ɥ쥹
   * @param to �ͽ����󥢥ɥ쥹
   * @param amount �ͽ��~
   *
   * @return �����򜺤����ƄI��˳ɹ��������Ϥ�true��ʧ���������Ϥ�false
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
   * �ͽ�Ԫ���ͽ��ȡ��ͽ���~�ˤ�äƌ���Υȥ�󥶥������������Ϥ�Q������
   * �ͽ���~�ˌ������������ʤ򤫤�����Τ�Ӌ�㤷����������Ͻ��~�Ȥ�max����ȡ�롣
   *
   * @param sender �g�Х��ɥ쥹
   * @param from �ͽ�Ԫ
   * @param to �ͽ���
   * @param amount �ͽ���~
   *
   * @return �����Ͻ��~
   */
  function transferFee(address sender, address from, address to, uint amount) public view returns (uint) {
    sender; from; to; // #avoid warning
    if (_transferFeeRate > 0) {
      uint denominator = 1000000; // 0.01 pips ������ 100 * 100 * 100 �� 100��
      uint numerator = mul(amount, _transferFeeRate);

      uint fee = numerator / denominator;
      uint remainder = sub(numerator, mul(denominator, fee));

      // ��꤬������Ϥ�fee��1���㤹
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
   * �������ʤ򷵤�
   *
   * @param sender �g�Х��ɥ쥹
   *
   * @return ��������
   */
  function transferFeeRate(address sender) public view returns (uint) {
    sender; // #HACK

    return _transferFeeRate;
  }

  /**
   * ����������~�򷵤�
   *
   * @param sender �g�Х��ɥ쥹
   *
   * @return ����������~
   */
  function transferMinimumFee(address sender) public view returns (uint8) {
    sender; // #HACK

    return _transferMinimumFee;
  }

  /**
   * �����Ϥ�����z��������x�k����
   * #TODO �Ȥꤢ����һ��Ŀ�Υ��`�ʩ`�˹̶�������x�����å���䤨��
   *
   * @param sender �g�Х��ɥ쥹
   * @return �ض��Υ��`�ʩ`����
   */
  function selectOwnerAddressForTransactionFee(address sender) public view returns (address) {
    sender; // #HACK

    return _storage.primaryOwner();
  }

  /**
   * dJPY����줹��
   *
   * - ���ޥ�ɤ�g�Ф�����`�������`�ʩ`�Ǥ���
   * - ��줹������0���󤭤�
   *
   * ���Ϥϳɹ�����
   *
   * @param sender �g�Х��ɥ쥹
   * @param amount ��줹����~
   */
  function mint(address sender, uint amount) public auth returns (bool) {
    require(amount > 0);

    _association.newProposal(keccak256('mint'), sender, amount, '');

    return true;
    /*return proposalEntity.mint(sender, amount);*/
  }

  /**
   * dJPY����ȴ����
   *
   * - ���ޥ�ɤ�g�Ф�����`�������`�ʩ`�Ǥ���
   * - ��줹������0���󤭤�
   * - dJPY�βиߤ�amount����󤭤�
   * - SHINJI��amount����󤭤�
   *
   * ���Ϥϳɹ�����
   *
   * @param sender �g�Х��ɥ쥹
   * @param amount ��ȴ������~
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
   * �᰸����J���롣
   * #TODO proposalId�Ϸ֤���ʤ��Τǡ��e�Τ�Τ���proposal���ض����ʤ��Ȥ������
   */
  function confirmProposal(address sender, bytes32 type_, uint proposalId) public auth {
    _association.confirmProposal(type_, sender, proposalId);
    /*proposalEntity.confirmProposal(sender, type_, proposalId);*/
  }

  /**
   * ָ�������N��᰸����ȡ�ä���
   *
   * @param type_ �᰸�ηN�'mint' | 'burn' | 'transferMinimumFee' | 'transferFeeRate'��
   *
   * @return �᰸�������J����Ƥ��ʤ���Τ⺬�ࣩ
   */
  function numberOfProposals(bytes32 type_) public view returns (uint) {
    return _association.numberOfProposals(type_);
    /*return proposalEntity.numberOfProposals(type_);*/
  }

  /**
   * �v�B�Ť�����J�ץ�����������
   *
   * @param association_ �¤������J�ץ���
   */
  function changeAssociation(address association_) public auth returns (bool) {
    _association = IkuraAssociation(association_);
    return true;
  }

  /**
   * ���A�����ȥ�`�����O������
   *
   * @param storage_ ���A�����ȥ�`���Υ��󥹥��󥹣����ɥ쥹��
   */
  function changeStorage(address storage_) public auth returns (bool) {
    _storage = IkuraStorage(storage_);
    return true;
  }

  /**
   * ���å��ΥЩ`�����򷵤�
   *
   * @param sender �g�Х�`���`�Υ��ɥ쥹
   *
   * @return �Щ`��������
   */
  function logicVersion(address sender) public view returns (uint) {
    sender; // #HACK

    return _logicVersion;
  }
}

/**
 * �U�^�r�g��SHINJI Token�����б��ʤˤ�ä��ض��Υ��������γ��J���Ф����饹
 */
contract IkuraAssociation is DSMath, DSAuth {
  //
  // public
  //

  // �᰸�����J����뤿��˱�Ҫ���m��Ʊ�θ��
  uint public confirmTotalTokenThreshold = 50;

  //
  // private
  //

  // �ǩ`�������A�����ȥ�`��
  IkuraStorage _storage;
  IkuraToken _token;

  // �᰸һ�E
  Proposal[] mintProposals;
  Proposal[] burnProposals;

  mapping (bytes32 => Proposal[]) proposals;

  struct Proposal {
    address proposer;                     // �᰸��
    bytes32 digest;                       // �����å�����
    bool executed;                        // �g�Ф��Пo
    uint createdAt;                       // �᰸�����Օr
    uint expireAt;                        // �᰸�ξ����Ф�
    address[] confirmers;                 // ���J��
    uint amount;                          // �����
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

    // @NOTE ���`���r��contract��deploy -> watch contract -> setOwner�������
    //ʡ�Ԥ��������Ϥϡ�������ֱ��controller�Υ��ɥ쥹��ָ������ȥ���`�ȥ��åȤǤ��ޤ�
    // ��Փ�ƥ��Ȥ�ͨ��ʤ��ʤ�Τǡ��ƥ��Ȥ�ͨ�ä���ԇ���Ƥ�
    /*address controllerAddress = 0x34c5605A4Ef1C98575DB6542179E55eE1f77A188;
    owner = controllerAddress;
    LogSetOwner(controllerAddress);*/
  }

  /**
   * ���A�����ȥ�`�����O������
   *
   * @param newStorage ���A�����ȥ�`���Υ��󥹥��󥹣����ɥ쥹��
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
   * �᰸�����ɤ���
   *
   * @param proposer �᰸�ߤΥ��ɥ쥹
   * @param amount �����
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

    // �᰸�ηN��ˌg�Ф��٤����ݤ�g�Ф���
    // @NOTE literal_string��bytes�υg���˱��^�Ǥ��ʤ��Τ�keccak256�Υϥå��傎�Ǳ��^���Ƥ���
    if (type_ == keccak256('mint')) emit MintProposalAdded(proposalId, proposer, amount);
    if (type_ == keccak256('burn')) emit BurnProposalAdded(proposalId, proposer, amount);

    // ���ˤϵ�Ȼ���J
    confirmProposal(type_, proposer, proposalId);

    return proposalId;
  }

  /**
   * �ȩ`���������ߤ��᰸�ˌ������m�ɤ���
   *
   * @param type_ �᰸�ηN�
   * @param confirmer ���J�ߤΥ��ɥ쥹
   * @param proposalId �᰸ID
   */
  function confirmProposal(bytes32 type_, address confirmer, uint proposalId) public {
    Proposal storage proposal = proposals[type_][proposalId];

    // �Ȥ˳��J�g�ߤΈ��Ϥϥ���`�򷵤�
    require(!hasConfirmed(type_, confirmer, proposalId));

    // ���J�О���Фä��ե饰�����Ƥ�
    proposal.confirmers.push(confirmer);

    // �᰸�ηN��ˌg�Ф��٤����ݤ�g�Ф���
    // @NOTE literal_string��bytes�υg���˱��^�Ǥ��ʤ��Τ�keccak256�Υϥå��傎�Ǳ��^���Ƥ���
    if (type_ == keccak256('mint')) emit MintConfirmed(proposalId, confirmer, proposal.amount);
    if (type_ == keccak256('burn')) emit BurnConfirmed(proposalId, confirmer, proposal.amount);

    if (isProposalExecutable(type_, proposalId, proposal.proposer, '')) {
      proposal.executed = true;

      // �᰸�ηN��ˌg�Ф��٤����ݤ�g�Ф���
      // @NOTE literal_string��bytes�υg���˱��^�Ǥ��ʤ��Τ�keccak256�Υϥå��傎�Ǳ��^���Ƥ���
      if (type_ == keccak256('mint')) executeMintProposal(proposalId);
      if (type_ == keccak256('burn')) executeBurnProposal(proposalId);
    }
  }

  /**
   * �Ȥ˳��J�g�ߤ��᰸���ɤ����򷵤�
   *
   * @param type_ �᰸�ηN�
   * @param addr ���J�ߤΥ��ɥ쥹
   * @param proposalId �᰸ID
   *
   * @return ���J�g�ߤǤ����true�������Ǥʤ����false
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
   * ָ�������᰸����J�����ȩ`����ξt���򷵤�
   *
   * @param type_ �᰸�ηN�
   * @param proposalId �᰸ID
   *
   * @return ���J��ͶƱ���줿�ȩ`������
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
   * ָ�������᰸�ξ����Ф�򷵤�
   *
   * @param type_ �᰸�ηN�
   * @param proposalId �᰸ID
   *
   * @return �᰸�ξ����Ф�
   */
  function proposalExpireAt(bytes32 type_, uint proposalId) public view returns (uint) {
    Proposal storage proposal = proposals[type_][proposalId];
    return proposal.expireAt;
  }

  /**
   * �᰸���g�������򜺤����Ƥ��뤫�򷵤�
   *
   * �����J������
   * - �ޤ��g�Ф��Ƥ��ʤ�
   * - �᰸���Є������ڤǤ���
   * - ָ������������Ϥ��m�ɥȩ`�����äƤ���
   *
   * @param proposalId �᰸ID
   *
   * @return �g�������򜺤����Ƥ�����Ϥ�true�������Ǥʤ����Ϥ�false
   */
  function isProposalExecutable(bytes32 type_, uint proposalId, address proposer, bytes transactionBytecode) internal view returns (bool) {
    Proposal storage proposal = proposals[type_][proposalId];

    // ���`�ʩ`��controller����h������`���`�������ڤ��ʤ����Ϥ�
    if (_storage.numOwnerAddress() < 2) {
      return true;
    }

    return  proposal.digest == keccak256(proposer, proposal.amount, transactionBytecode) &&
            isProposalNotExpired(type_, proposalId) &&
            mul(100, confirmedTotalToken(type_, proposalId)) / _storage.totalSupply() > confirmTotalTokenThreshold;
  }

  /**
   * ָ�������N��᰸����ȡ�ä���
   *
   * @param type_ �᰸�ηN�'mint' | 'burn' | 'transferMinimumFee' | 'transferFeeRate'��
   *
   * @return �᰸�������J����Ƥ��ʤ���Τ⺬�ࣩ
   */
  function numberOfProposals(bytes32 type_) public constant returns (uint) {
    return proposals[type_].length;
  }

  /**
   * δ���J���Є����ޤ��Ф�Ƥ��ʤ��᰸�����򷵤�
   *
   * @param type_ �᰸�ηN�'mint' | 'burn' | 'transferMinimumFee' | 'transferFeeRate'��
   *
   * @return �᰸��
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
   * �᰸���Є����ޤ��Ф�Ƥ��ʤ��������å�����
   *
   * - �g�Ф���Ƥ��ʤ�
   * - �Є����ޤ��Ф�Ƥ��ʤ�
   *
   * ���ϤΤ�true�򷵤�
   */
  function isProposalNotExpired(bytes32 type_, uint proposalId) internal view returns (bool) {
    Proposal storage proposal = proposals[type_][proposalId];

    return  !proposal.executed &&
            now < proposal.expireAt;
  }

  /**
   * dJPY����줹��
   *
   * - ��줹������0���󤭤�
   *
   * ���Ϥϳɹ�����
   *
   * @param proposalId �᰸ID
   */
  function executeMintProposal(uint proposalId) internal returns (bool) {
    Proposal storage proposal = proposals[keccak256('mint')][proposalId];

    // �����Ǥ���Τ�������å�������
    require(proposal.amount > 0);

    emit MintExecuted(proposalId, proposal.proposer, proposal.amount);

    // �t���o�� / �g���ߤ�dJPY / �g���ߤ�SHINJI token�򉈤䤹
    _storage.addTotalSupply(proposal.amount);
    _storage.addCoinBalance(proposal.proposer, proposal.amount);
    _storage.addTokenBalance(proposal.proposer, proposal.amount);

    return true;
  }

  /**
   * dJPY����ȴ����
   *
   * - ��ȴ��������0���󤭤�
   * - �᰸�ߤ����Ф���dJPY�βиߤ�amount����
   * - �᰸�ߤ����Ф���SHINJI��amount����󤭤�
   *
   * ���Ϥϳɹ�����
   *
   * @param proposalId �᰸ID
   */
  function executeBurnProposal(uint proposalId) internal returns (bool) {
    Proposal storage proposal = proposals[keccak256('burn')][proposalId];

    // �����Ǥ���Τ�������å�������
    require(proposal.amount > 0);
    require(_storage.coinBalance(proposal.proposer) >= proposal.amount);
    require(_storage.tokenBalance(proposal.proposer) >= proposal.amount);

    emit BurnExecuted(proposalId, proposal.proposer, proposal.amount);

    // �t���o�� / �g���ߤ�dJPY / �g���ߤ�SHINJI token��p�餹
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