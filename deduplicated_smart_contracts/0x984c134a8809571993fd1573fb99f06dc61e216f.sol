pragma solidity ^0.4.21;
/**
 * Overflow aware uint math functions.
 *
 * Inspired by https://github.com/MakerDAO/maker-otc/blob/master/contracts/simple_market.sol
 */
contract SafeMath {
  //internals

  function safeMul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event Burn(address indexed _from, uint256 _value);
}




/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is SafeMath {

    /**
     * Reviewed:
     * - Interger overflow = OK, checked
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(_to != 0X0);

        // ��� from ��ַ�� û����ô��� token�� ֹͣ����
        // ��� ���ת�� ���� �� ������ ֹͣ����
        if (balances[msg.sender] >= _value && balances[msg.sender] - _value < balances[msg.sender]) {

            // sender�Ļ�ͷ ��ȥ ��Ӧtoken�������� ʹ�� safemath ����
            balances[msg.sender] = super.safeSub(balances[msg.sender], _value);
            // receiver�Ļ�ͷ ���� ��Ӧtoken�������� ʹ�� safemath ����
            balances[_to] = super.safeAdd(balances[_to], _value);

            emit Transfer(msg.sender, _to, _value);//����event
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_to != 0X0);

        // ��� from ��ַ�� û����ô��� token�� ֹͣ����
        // ��� from ��ַ��owner�� �����msg.sender��Ȩ��û����ô���token��ֹͣ����
        // ��� ���ת�� ���� �� ������ ֹͣ����
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_from] - _value < balances[_from]) {

            // �� ����sender �� from�˻��Ŀ���Ȩ�� ���� ���Ӧ�� ������ ʹ�� safemath ����
            allowed[_from][msg.sender] = super.safeSub(allowed[_from][msg.sender], _value);
            // from�Ļ�ͷ ��ȥ ��Ӧtoken�������� ʹ�� safemath ����
            balances[_from] = super.safeSub(balances[_from], _value);
            // to�Ļ�ͷ ���� ��Ӧtoken�������� ʹ�� safemath ����
            balances[_to] = super.safeAdd(balances[_to], _value);

            emit Transfer(_from, _to, _value);//����event
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // �ý��׵� msg.sender �������� ���spender��ַȨ��
        // ����spender��ַ����ʹ�� msg.sender ��ַ�µ�һ��������token
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      // �鿴 spender �ܿ��� ���ٸ� owner �˻��µ�token
      return allowed[_owner][_spender];
    }

    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;
}










/*******************************************************************************
 *
 * Artchain Token  ���ܺ�Լ.
 *
 * version 15, 2018-05-28
 *
 ******************************************************************************/
contract ArtChainToken is StandardToken {

    // ����token�����֣� �����Ժ󲻿ɸ���
    string public constant name = "Artchain Global Token";

    // ����token�Ĵ��ţ� �����Ժ󲻿ɸ���
    string public constant symbol = "ACG";

    // ���ǵ� contract �����ʱ�� ֮ǰ�Ѿ��ж��������� block
    uint public startBlock;

    //֧�� С�����8λ�Ľ��ס� e.g. ��С������ 0.00000001 �� token
    uint public constant decimals = 8;

    // ���ǵ� token ���ܹ������� (�������� *10**uint(decimals))
    uint256 public totalSupply = 3500000000*10**uint(decimals); // 35��


    // founder�˻� - ��ַ���Ը���
    address public founder = 0x3b7ca9550a641B2bf2c60A0AeFbf1eA48891e58b;
    // ����ú�Լʱ��founder_token = founder
    // ���Ӧ�� token ������(�����ݹ�������)������˻���
    // ���� founder ��ַ�� token �������� founder_token ��ַ���У����ᱻת��
    // �� founder_token �ĵ�ַ�ں�Լ����󽫲��ܱ����ģ��õ�ַ�µ�tokenֻ�ܰ��ռȶ��Ĺ����ͷ�
    address public constant founder_token = 0x3b7ca9550a641B2bf2c60A0AeFbf1eA48891e58b;// founder_token=founder;


    // �����Ŷ�poi�˻� - ��ַ���Ը���
    address public poi = 0x98d95A8178ff41834773D3D270907942F5BE581e;
    // ����ú�Լʱ��poi_token = poi
    // ���Ӧ�� token ������(�����ݹ�������)������˻���
    // ���� poi ��ַ�� token �������� poi_token ��ַ���У����ᱻת��
    // �� poi_token �ĵ�ַ�ں�Լ����󽫲��ܱ����ģ� �õ�ַ�µ�tokenֻ�ܰ��ռȶ��Ĺ����ͷ�
    address public constant poi_token = 0x98d95A8178ff41834773D3D270907942F5BE581e; // poi_token=poi


    // ����˽ļ���˻�, ��Լ����󲻿ɸ��ģ����� token ��������ת�� û������
    address public constant privateSale = 0x31F2F3361e929192aB2558b95485329494955aC4;


    // �����䶳�˻�ת��/����
    // ���ÿ14�����һ��block�� ����block�������� ȷ���䶳��ʱ�䣬
    // ���� 185143 �� block ��Լ��Ҫһ����ʱ��
    uint public constant one_month = 185143;// ----   ʱ���׼
    uint public poiLockup = super.safeMul(uint(one_month), 7);  // poi �˻� �����ʱ�� 7����

    // ���� ��ͣ���ף� ֻ�� founder �˻� �ſ��Ը������״̬
    bool public halted = false;



    /*******************************************************************
     *
     *  �����Լ�� ����
     *
     *******************************************************************/
    function ArtChainToken() public {
    //constructor() public {

        // ����ú�Լ��ʱ��  startBlock�������µ� block������
        startBlock = block.number;

        // ��founder 20% �� token�� 35�ڵ� 20% ��7��  (�������� *10**uint(decimals))
        balances[founder] = 700000000*10**uint(decimals); // 7��

        // ��poi�˻� 40% �� token�� 35�ڵ� 40% ��14��
        balances[poi] = 1400000000*10**uint(decimals);   // 14��

        // ��˽ļ�˻� 40% �� token�� 35�ڵ� 40% ��14��
        balances[privateSale] = 1400000000*10**uint(decimals); // 14��
    }


    /*******************************************************************
     *
     *  ����ֹͣ���н��ף� ֻ�� founder �˻���������
     *
     *******************************************************************/
    function halt() public returns (bool success) {
        if (msg.sender!=founder) return false;
        halted = true;
        return true;
    }
    function unhalt() public returns (bool success) {
        if (msg.sender!=founder) return false;
        halted = false;
        return true;
    }


    /*******************************************************************
     *
     * �޸�founder/poi�ĵ�ַ�� ֻ�� ����founder�� �����޸�
     *
     * ���� token ���Ǵ��� founder_token �� poi_token��
     *
     *******************************************************************/
    function changeFounder(address newFounder) public returns (bool success){
        // ֻ�� "��founder" ���Ը��� Founder�ĵ�ַ
        if (msg.sender!=founder) return false;
        founder = newFounder;
        return true;
    }
    function changePOI(address newPOI) public returns (bool success){
        // ֻ�� "��founder" ���Ը��� poi�ĵ�ַ
        if (msg.sender!=founder) return false;
        poi = newPOI;
        return true;
    }




    /********************************************************
     *
     *  ת�� �Լ��˻��е� token ����Ҫ���� �������� ǰ���£�
     *
     ********************************************************/
    function transfer(address _to, uint256 _value) public returns (bool success) {

      // ��� ������ ����ͣ���ס� ״̬�Ļ��� �ܾ�����
      if (halted==true) return false;

      // poi_token �е� token�� �ж��Ƿ��ڶ���ʱ���� ����ʱ��Ϊһ�꣬ Ҳ���� poiLockup ��block��ʱ��
      if (msg.sender==poi_token && block.number <= startBlock + poiLockup)  return false;

      // founder_token �е� token�� ���ݹ����Ϊ48�����ͷţ���ʼ״̬��7�ڣ�
      if (msg.sender==founder_token){
        // ǰ6���� ���ܶ� founder_token �˻��� ��� Ҫά�� 100% (7�ڵ�100% = 7��)
        if (block.number <= startBlock + super.safeMul(uint(one_month), 6)  && super.safeSub(balanceOf(msg.sender), _value)<700000000*10**uint(decimals)) return false;
        // 6���µ�12����  founder_token �˻��� ��� ����Ҫ 85% (7�ڵ�85% = 5��9ǧ5����)
        if (block.number <= startBlock + super.safeMul(uint(one_month), 12) && super.safeSub(balanceOf(msg.sender), _value)<595000000*10**uint(decimals)) return false;
        // 12���µ�18���� founder_token �˻��� ��� ����Ҫ 70% (7�ڵ�70% = 4��9ǧ��)
        if (block.number <= startBlock + super.safeMul(uint(one_month), 18) && super.safeSub(balanceOf(msg.sender), _value)<490000000*10**uint(decimals)) return false;
        // 18���µ�24���� founder_token �˻��� ��� ����Ҫ 57.5% (7�ڵ�57.5% = 4��0ǧ2��5ʮ��)
        if (block.number <= startBlock + super.safeMul(uint(one_month), 24) && super.safeSub(balanceOf(msg.sender), _value)<402500000*10**uint(decimals)) return false;
        // 24���µ�30���� founder_token �˻��� ��� ����Ҫ 45% (7�ڵ�45% = 3��1ǧ5����)
        if (block.number <= startBlock + super.safeMul(uint(one_month), 30) && super.safeSub(balanceOf(msg.sender), _value)<315000000*10**uint(decimals)) return false;
        // 30���µ�36���� founder_token �˻��� ��� ����Ҫ 32.5% (7�ڵ�32.5% = 2��2ǧ7��5ʮ��)
        if (block.number <= startBlock + super.safeMul(uint(one_month), 36) && super.safeSub(balanceOf(msg.sender), _value)<227500000*10**uint(decimals)) return false;
        // 36���µ�42���� founder_token �˻��� ��� ����Ҫ 20% (7�ڵ�20% = 1��4ǧ��)
        if (block.number <= startBlock + super.safeMul(uint(one_month), 42) && super.safeSub(balanceOf(msg.sender), _value)<140000000*10**uint(decimals)) return false;
        // 42���µ�48���� founder_token �˻��� ��� ����Ҫ 10% (7�ڵ�10% = 7ǧ��)
        if (block.number <= startBlock + super.safeMul(uint(one_month), 48) && super.safeSub(balanceOf(msg.sender), _value)< 70000000*10**uint(decimals)) return false;
        // 48�����Ժ� û������
      }

      //��������£� �������н���
      return super.transfer(_to, _value);
    }

    /********************************************************
     *
     *  ת�� �����˻��е� token ����Ҫ���� �������� ǰ���£�
     *
     ********************************************************/
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // ��� ������ ����ͣ���ס� ״̬�Ļ��� �ܾ�����
        if (halted==true) return false;

        // poi_token �е� token�� �ж��Ƿ��ڶ���ʱ���� ����ʱ��Ϊһ�꣬ Ҳ���� poiLockup ��block��ʱ��
        if (_from==poi_token && block.number <= startBlock + poiLockup) return false;

        // founder_token �е� token�� ���ݹ����Ϊ48�����ͷţ���ʼ״̬��7�ڣ�
        if (_from==founder_token){
          // ǰ6���� ���ܶ� founder_token �˻��� ��� Ҫά�� 100% (7�ڵ�100% = 7��)
          if (block.number <= startBlock + super.safeMul(uint(one_month), 6)  && super.safeSub(balanceOf(_from), _value)<700000000*10**uint(decimals)) return false;
          // 6���µ�12����  founder_token �˻��� ��� ����Ҫ 85% (7�ڵ�85% = 5��9ǧ5����)
          if (block.number <= startBlock + super.safeMul(uint(one_month), 12) && super.safeSub(balanceOf(_from), _value)<595000000*10**uint(decimals)) return false;
          // 12���µ�18���� founder_token �˻��� ��� ����Ҫ 70% (7�ڵ�70% = 4��9ǧ��)
          if (block.number <= startBlock + super.safeMul(uint(one_month), 18) && super.safeSub(balanceOf(_from), _value)<490000000*10**uint(decimals)) return false;
          // 18���µ�24���� founder_token �˻��� ��� ����Ҫ 57.5% (7�ڵ�57.5% = 4��0ǧ2��5ʮ��)
          if (block.number <= startBlock + super.safeMul(uint(one_month), 24) && super.safeSub(balanceOf(_from), _value)<402500000*10**uint(decimals)) return false;
          // 24���µ�30���� founder_token �˻��� ��� ����Ҫ 45% (7�ڵ�45% = 3��1ǧ5����)
          if (block.number <= startBlock + super.safeMul(uint(one_month), 30) && super.safeSub(balanceOf(_from), _value)<315000000*10**uint(decimals)) return false;
          // 30���µ�36���� founder_token �˻��� ��� ����Ҫ 32.5% (7�ڵ�32.5% = 2��2ǧ7��5ʮ��)
          if (block.number <= startBlock + super.safeMul(uint(one_month), 36) && super.safeSub(balanceOf(_from), _value)<227500000*10**uint(decimals)) return false;
          // 36���µ�42���� founder_token �˻��� ��� ����Ҫ 20% (7�ڵ�20% = 1��4ǧ��)
          if (block.number <= startBlock + super.safeMul(uint(one_month), 42) && super.safeSub(balanceOf(_from), _value)<140000000*10**uint(decimals)) return false;
          // 42���µ�48���� founder_token �˻��� ��� ����Ҫ 10% (7�ڵ�10% = 7ǧ��)
          if (block.number <= startBlock + super.safeMul(uint(one_month), 48) && super.safeSub(balanceOf(_from), _value)< 70000000*10**uint(decimals)) return false;
          // 48�����Ժ� û������
        }

        //��������£� �������н���
        return super.transferFrom(_from, _to, _value);
    }









    /***********************************************************����
     *
     * ���� �Լ��˻��ڵ� tokens
     *
     ***********************************************************/
    function burn(uint256 _value) public returns (bool success) {

      // ��� ������ ����ͣ���ס� ״̬�Ļ��� �ܾ�����
      if (halted==true) return false;

      // poi_token �е� token�� �ж��Ƿ��ڶ���ʱ���� ����ʱ��Ϊ poiLockup ��block��ʱ��
      if (msg.sender==poi_token && block.number <= startBlock + poiLockup) return false;

      // founder_token �е� token�� �����Ա�����
      if (msg.sender==founder_token) return false;


      //��� ���˻� ���� ����� token ������ ��ֹ����
      if (balances[msg.sender] < _value) return false;
      //��� Ҫ���ٵ� _value �Ǹ����� ��ֹ����
      if (balances[msg.sender] - _value > balances[msg.sender]) return false;


      // �������ϵ� ����� ������� ���ٹ���

      // �˻�token������С�� ʹ�� safemath
      balances[msg.sender] = super.safeSub(balances[msg.sender], _value);
      // �����˻�token���� �����٣� ���� token��������Ҳ����٣� ʹ�� safemath
      totalSupply = super.safeSub(totalSupply, _value);

      emit Burn(msg.sender, _value); //����event

      return true;

    }




    /***********************************************************����
     *
     * ���� �����˻��ڵ� tokens
     *
     ***********************************************************/
    function burnFrom(address _from, uint256 _value) public returns (bool success) {

      // ��� ������ ����ͣ���ס� ״̬�Ļ��� �ܾ�����
      if (halted==true) return false;

      // ��� Ҫ���� poi_token �е� token��
      // ��Ҫ�ж��Ƿ��ڶ���ʱ���� ������ʱ��Ϊ poiLockup ��block��ʱ�䣩
      if (_from==poi_token && block.number <= startBlock + poiLockup) return false;

      // ���Ҫ���� founder_token �µ� token�� ֹͣ����
      // founder_token �е� token�� �����Ա�����
      if (_from==founder_token) return false;


      //��� ���˻� ���� ����� token ������ ��ֹ����
      if (balances[_from] < _value) return false;
      //��� ���˻� ����� msg.sender ��Ȩ�޲��� ����� token ������ ��ֹ����
      if (allowed[_from][msg.sender] < _value) return false;
      //��� Ҫ���ٵ� _value �Ǹ����� ��ֹ����
      if (balances[_from] - _value > balances[_from]) return false;


      // �������ϵ� ����� ������� ���ٹ���

      // from�˻��� msg.sender����֧��� token���� Ҳ���٣� ʹ�� safemath
      allowed[_from][msg.sender] = super.safeSub(allowed[_from][msg.sender], _value);
      // �˻�token������С�� ʹ�� safemath
      balances[_from] = super.safeSub(balances[_from], _value);
      // �����˻�token���� �����٣� ���� token��������Ҳ����٣� ʹ�� safemath
      totalSupply = super.safeSub(totalSupply, _value);

      emit Burn(_from, _value); //���� event

      return true;
  }
}