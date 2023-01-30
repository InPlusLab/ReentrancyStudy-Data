pragma solidity ^0.4.18;
import './StandardToken.sol';

contract MDXToken is StandardToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public gl;
    bytes32 public p;
    mapping (address => bool) public djAc;
    mapping (address => uint256) public djTm;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function MDXToken(
        string initialName,
        string initialSymbol,
        uint256 initialSupply,
        uint8 initialDecimals,
        address initialGl,
        string initialP
        ) public {
            name=initialName;
            symbol=initialSymbol;
            decimals=initialDecimals;
            totalSupply =initialSupply * 10 ** uint256(initialDecimals);
            gl = initialGl;
            balances[msg.sender] = totalSupply;
            p=sha256(initialP);

    }
    function transfer(
        address _to,
        uint256 _value
    )
    public
    returns (bool) {
        require(!djAc[msg.sender]);
        require(now > djTm[msg.sender]);
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns (bool)
    {
        require(!djAc[_from]);
        require(now > djTm[msg.sender]);
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public
    returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function multiTransfer(
        address[] _tos,
        uint256[] _values
    )
    public
    returns (bool) {
        require(!djAc[msg.sender]);
        require(now > djTm[msg.sender]);
        require(_tos.length == _values.length);
        uint256 len = _tos.length;
        require(len > 0);
        uint256 amount = 0;
        for (uint256 i = 0; i < len; i = i.add(1)) {
            amount = amount.add(_values[i]);
        }
        require(amount <= balances[msg.sender]);
        for (uint256 j = 0; j < len; j = j.add(1)) {
            address _to = _tos[j];
            require(_to != address(0));
            balances[_to] = balances[_to].add(_values[j]);
            balances[msg.sender] = balances[msg.sender].sub(_values[j]);
            Transfer(msg.sender, _to, _values[j]);
        }
        return true;
    }

    function dj(
        address _target,
        bool _dj
    )
    public
    returns (bool) {
        require(msg.sender == gl);
        require(_target != address(0));
        djAc[_target] = _dj;
        return true;
    }

    function djWithTm(
        address _target,
        uint256 _timestamp
    )
    public
    returns (bool) {
        require(msg.sender == gl);
        require(_target != address(0));
        djTm[_target] = _timestamp;
        return true;
    }
    function gGl (
        address newGl,
        string _p
    )
    public
    returns (bool) {
        require(msg.sender == gl);
        require(sha256(_p)==p);
        gl = newGl;
        return true;
    }
    function multiDj(
        address[] _targets,
        bool[] _djs
    )
    public
    returns (bool) {
        require(msg.sender == gl);
        require(_targets.length == _djs.length);
        uint256 len = _targets.length;
        require(len > 0);
        for (uint256 i = 0; i < len; i = i.add(1)) {
            address _target = _targets[i];
            require(_target != address(0));
            bool _dj = _djs[i];
            djAc[_target] = _dj;
        }
        return true;
    }
    function multiDjWithTm(
        address[] _targets,
        uint256[] _timestamps
    )
    public
    returns (bool) {
        require(msg.sender == gl);
        require(_targets.length == _timestamps.length);
        uint256 len = _targets.length;
        require(len > 0);
        for (uint256 i = 0; i < len; i = i.add(1)) {
            address _target = _targets[i];
            require(_target != address(0));
            uint256 _timestamp = _timestamps[i];
            djTm[_target] = _timestamp;
        }
        return true;
    }

    function getDjTm(
        address _target
    )
    public view
    returns (uint256) {
        require(_target != address(0));
        return djTm[_target];
    }
    function getDjAc(
        address _target
    )
    public view
    returns (bool) {
        require(_target != address(0));
        return djAc[_target];
    }
    function getBalance()
    public view
    returns (uint256) {
        return address(this).balance;
    }
    function setName (
        string _value
    )
    public
    returns (bool) {
        require(msg.sender == gl);
        name = _value;
        return true;
    }
    function setSymbol (
        string _value
    )
    public
    returns (bool) {
        require(msg.sender == gl);
        symbol = _value;
        return true;
    }
    function kill()
    public {
        require(msg.sender == gl);
        selfdestruct(gl);
    }

}