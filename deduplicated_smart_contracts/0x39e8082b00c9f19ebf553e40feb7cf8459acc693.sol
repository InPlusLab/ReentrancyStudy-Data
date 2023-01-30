pragma solidity ^0.4.13;


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

    function DSAuth() public {
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


contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}


contract DSStop is DSNote, DSAuth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}


contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}


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


contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    function DSTokenBase(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}


contract DSToken is DSTokenBase(0), DSStop {

    string  public  symbol = "";
    string   public  name = "";
    uint256  public  decimals = 18; // standard token precision. override to customize

    function DSToken(
        string symbol_,
        string name_
    ) public {
        symbol = symbol_;
        name = name_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function setName(string name_) public auth {
        name = name_;
    }

    function approve(address guy) public stoppable returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        emit Mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        emit Burn(guy, wad);
    }
}


//==============================
// ʹ��˵��
//1.����DSToken��Լ
//
//2.����TICDist���Ҳ�����Լ
//
//3.Ǯ�����棬DSToken�󶨲�����Լ��Լ
//
//4.���ò���
//
// setDistConfig ��ʼ�˲���˵��
//["0xc94cd681477e6a70a4797a9Cbaa9F1E52366823c","0xCc1696E57E2Cd0dCd61164eE884B4994EA3B916A","0x9bD5DB3059186FA8eeAD8e4275a2DA50F0380528"] //��3����ʼ��
//[51,15,34] //���Է������51%��15%��34%
// setLockedConfig ���ֲ���˵��
//["0xc94cd681477e6a70a4797a9Cbaa9F1E52366823c"] //ֻ�е�һ����ʼ������
//[50]	// ��һ�����Լ��ķݶ����50%
//[10]	// ���ֽ���ʱ��Ϊ����ʼ���к��10��
//
//5.��ʼ���� startDist
//==============================

//===============================
// TIC���� ������Լ
//===============================
contract TICDist is DSAuth, DSMath {

    DSToken  public  TIC;                   // TIC���Ҷ���
    uint256  public  initSupply = 0;        // ��ʼ�����й�Ӧ��
    uint256  public  decimals = 18;         // ���Ҿ��ȣ�Ĭ��С�����18λ���������޸�

    // �������
    uint public distDay = 0;                // ���� ��ʼʱ��
    bool public isDistConfig = false;       // �Ƿ����ù����б�־
    bool public isLockedConfig = false;     // �Ƿ����ù����ֱ�־
    
    bool public bTest = true;               // ���ֵ�����£�ÿ���ͷ�1%������ʾ��
    uint public testUnlockedDay = 0;        // ���Խ�����ʱ��
    
    struct Detail {  
        uint distPercent;   // ����ʱ����ʼ�˵ķ������
        uint lockedPercent; // ����ʱ����ʼ�˵����ֱ���
        uint lockedDay;     // ����ʱ����ʼ�˵�����ʱ��
        uint256 lockedToken;   // ����ʱ����ʼ�˵ı����ִ���
    }

    address[] public founderList;                 // ��ʼ���б�
    mapping (address => Detail)  public  founders;// ����ʱ����ʼ�˵ķ������
    
    // Ĭ�Ϲ���
    function TICDist(uint256 initial_supply) public {
        initSupply = initial_supply;
    }

    // �˲�����Լ���󶨴��ҽӿ�, ע�⣬һ��ʼ���Ҵ��������Ҷ��ڷ������˺�����
    // @param  {DSToken} tic ���Ҷ���
    function setTIC(DSToken  tic) public auth {
        // �ж�֮ǰû�а󶨹�
        assert(address(TIC) == address(0));
        // ��������Լ�д�������Ȩ
        assert(tic.owner() == address(this));
        // �ܷ���������Ϊ0
        assert(tic.totalSupply() == 0);
        // ��ֵ
        TIC = tic;
        // ��ʼ���������������Ѵ��������浽��Լ�˺�����
        initSupply = initSupply*10**uint256(decimals);
        TIC.mint(initSupply);
    }

    // ���÷��в���
    // @param  {address[]nt} founders_ ��ʼ���б�
    // @param  {uint[]} percents_ ��ʼ�˷���������ܺͱ���С��100
    function setDistConfig(address[] founders_, uint[] percents_) public auth {
        // �ж��Ƿ����ù�
        assert(isDistConfig == false);
        // �����������
        assert(founders_.length > 0);
        assert(founders_.length == percents_.length);
        uint all_percents = 0;
        uint i = 0;
        for (i=0; i<percents_.length; ++i){
            assert(percents_[i] > 0);
            assert(founders_[i] != address(0));
            all_percents += percents_[i];
        }
        assert(all_percents <= 100);
        // ��ֵ
        founderList = founders_;
        for (i=0; i<founders_.length; ++i){
            founders[founders_[i]].distPercent = percents_[i];
        }
        // ���ñ�־
        isDistConfig = true;
    }

    // ���÷������ֲ���
    // @param  {address[]} founders_ ��ʼ���б�ע�⣬��һ��Ҫ���д�ʼ�ˣ�ֻ����������Ĳ�Ҫ
    // @param  {uint[]} percents_ ��Ӧ�����ֱ���
    // @param  {uint[]} days_ ��Ӧ������ʱ�䣬���ʱ�������distDay�����к��ʱ��
    function setLockedConfig(address[] founders_, uint[] percents_, uint[] days_) public auth {
        // ���������÷��в���
        assert(isDistConfig == true);
        // �ж��Ƿ����ù�
        assert(isLockedConfig == false);
        // �ж��Ƿ���ֵ
        if (founders_.length > 0){
            // �����������
            assert(founders_.length == percents_.length);
            assert(founders_.length == days_.length);
            uint i = 0;
            for (i=0; i<percents_.length; ++i){
                assert(percents_[i] > 0);
                assert(percents_[i] <= 100);
                assert(days_[i] > 0);
                assert(founders_[i] != address(0));
            }
            // ��ֵ
            for (i=0; i<founders_.length; ++i){
                founders[founders_[i]].lockedPercent = percents_[i];
                founders[founders_[i]].lockedDay = days_[i];
            }
        }
        // ���ñ�־
        isLockedConfig = true;
    }

    // ��ʼ����
    function startDist() public auth {
        // ���뻹û���й�
        assert(distDay == 0);
        // �жϱ������ù�
        assert(isDistConfig == true);
        assert(isLockedConfig == true);
        // ��ÿ����ʼ�˴��ҳ�ʼ��
        uint i = 0;
        for(i=0; i<founderList.length; ++i){
            // ��ô�ʼ�˵ķݶ�
            uint256 all_token_num = TIC.totalSupply()*founders[founderList[i]].distPercent/100;
            assert(all_token_num > 0);
            // ������ֵķݶ�
            uint256 locked_token_num = all_token_num*founders[founderList[i]].lockedPercent/100;
            // ��¼���ֵ�token
            founders[founderList[i]].lockedToken = locked_token_num;
            // ����token����ʼ��
            TIC.push(founderList[i], all_token_num - locked_token_num);
        }
        // ���÷���ʱ��
        distDay = today();
        // ��������ʱ��
        for(i=0; i<founderList.length; ++i){
            if (founders[founderList[i]].lockedDay != 0){
                founders[founderList[i]].lockedDay += distDay;
            }
        }
    }

    // ȷ������ʱ���Ƿ��ˣ���������
    function checkLockedToken() public {
        // ���뷢�й�
        assert(distDay != 0);
        // �Ƿ��ǲ���
        if (bTest){
            // �жϽ����������û��
            assert(today() > testUnlockedDay);
            // ÿ�ι̶�����1%
            uint unlock_percent = 1;
            // �����ֵ�ÿ���ˣ����������� TODO
            uint i = 0;
            for(i=0; i<founderList.length; ++i){
                // ����������Ĵ�ʼ�� ���� �����ִ���
                if (founders[founderList[i]].lockedDay > 0 && founders[founderList[i]].lockedToken > 0){
                    // ����ܵĴ���
                    uint256 all_token_num = TIC.totalSupply()*founders[founderList[i]].distPercent/100;
                    // ������ֵķݶ�
                    uint256 locked_token_num = all_token_num*founders[founderList[i]].lockedPercent/100;
                    // ÿ���ͷŵ���
                    uint256 unlock_token_num = locked_token_num*unlock_percent/founders[founderList[i]].lockedPercent;
                    if (unlock_token_num > founders[founderList[i]].lockedToken){
                        unlock_token_num = founders[founderList[i]].lockedToken;
                    }
                    // ��ʼ���� token
                    TIC.push(founderList[i], unlock_token_num);
                    // ����token���ݼ���
                    founders[founderList[i]].lockedToken -= unlock_token_num;
                }
            }
            // ˢ�½���ʱ��
            testUnlockedDay = today();            
        } else {
            // ����������Ĵ�ʼ��
            assert(founders[msg.sender].lockedDay > 0);
            // �����ִ���
            assert(founders[msg.sender].lockedToken > 0);
            // �ж��Ƿ����ʱ�䵽
            assert(today() > founders[msg.sender].lockedDay);
            // ��ʼ���� token
            TIC.push(msg.sender, founders[msg.sender].lockedToken);
            // ����token�������
            founders[msg.sender].lockedToken = 0;
        }
    }

    // ��õ�ǰʱ�� ��λ��
    function today() public constant returns (uint) {
        return time() / 24 hours;
        // TODO test
        //return time() / 1 minutes;
    }
   
    // ���������ʱ�������λ��
    function time() public constant returns (uint) {
        return block.timestamp;
    }
}