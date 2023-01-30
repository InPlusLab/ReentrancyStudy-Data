/**
 *Submitted for verification at Etherscan.io on 2019-12-26
*/

pragma solidity ^0.5.0;

/*
표준 코드 라이브러리인 Open-Zepplin 코드기반으로 일부 기능이 추가 되었습니다.
*/

// 오버플로우 공격등에 취약점에 대해 저항성을 가지는 계산용 라이브러리 입니다. 
// SRC: zeppelin-solidity/contracts/math/SafeMath.sol
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) { return 0; }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

// 스마트 계약 선언
// SRC: zeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol
contract Token {
    using SafeMath for uint256;
    
    string public name;
    string public symbol;
    uint8  public decimals;
    address public owner; 
    
    uint256 constant INITIAL_SUPPLY = 5000000000;
    uint256 totalSupply_;
    bool public mintingFinished = false;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) internal allowed;

    // 아래와 같은 행위 발생시, 이벤트가 발생되어 네트워크에 공지가 됩니다. 
    event Transfer(address indexed from,  address indexed to,      uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    // 스마트 계약 생성자(초기화)
    constructor() public {
        name     = "ITTonion";
        symbol   = "ITT";
        decimals = 18;
        
        owner = msg.sender;
        totalSupply_ = INITIAL_SUPPLY * 10 ** uint(decimals);
        balances[msg.sender] = totalSupply_;
    }
    
    // 토큰이 추가 발행 될수 있는지 여부를 반환합니다.
    // SRC: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol
    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    // 관리자만 토큰을 발행할 수 있도록 제한합니다.
    // SRC: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol
    modifier hasMintPermission() {
        require(msg.sender == owner);
        _;
    }
  
    // 해당 주소로 토큰을 발행하여 전송합니다. 
    // SRC: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol
    function mint(address _to, uint256 _amount) hasMintPermission canMint public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    // 완전히 토큰 발행을 끝냅니다. (한번 수행되면 다시는 추가 발행이 안됩니다.)
    // SRC: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol
    function finishMinting() hasMintPermission canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
    
    // 현재까지 발행된 총량을 반환합니다. 
    // SRC: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    // 해당 계좌의 토큰 수를 조회합니다. 
    // SRC: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    // 해당 계좌로 토큰을 전송합니다.
    // SRC: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 인출권한을 가진 제3자가, 해당 계좌에서 다른 계좌로 토큰을 전송합니다. 
    // SRC: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    // 입력한 금액만큼 제 3자(spender)가 본 계좌로 부터 value 금액만큼 인출할수 있도록 허용합니다. 
    // SRC: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    // 제 3자(spender)에게 배정된 owner 계좌로부터 허용된 인출 금액을 확인합니다. 
    // SRC: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    // 입력한 금액만큼 제 3자(spender)에게 배정된 위임 인출 양을 늘립니다. 
    // SRC: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
        
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    // 입력한 금액만큼 제 3자(spender)에게 배정된 위임 인출 양을 줄입니다. 
    // SRC: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    
    // 토큰을 소각하고, 총 발행양을 줄입니다.
    // SRC: zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }
    
    // 토큰을 소각하고, 총 발행양을 줄입니다.
    // SRC: zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol
    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        
        balances[_who] = balances[_who].sub(_value);
        totalSupply_   = totalSupply_.sub(_value);
        
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
    
}