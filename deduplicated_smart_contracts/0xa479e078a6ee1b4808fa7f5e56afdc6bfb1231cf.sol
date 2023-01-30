/**

 *Submitted for verification at Etherscan.io on 2018-11-16

*/



// §Õ§Ú§ß§Ñ§ç§å§Û §à§ä§ã§ð§Õ§Ñ



pragma solidity 0.4.25;





library SafeMath {



    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {

            return 0;

        }



        uint256 c = _a * _b;

        require(c / _a == _b);



        return c;

    }



    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0);

        uint256 c = _a / _b;



        return c;

    }



    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a);

        uint256 c = _a - _b;



        return c;

    }



    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;

        require(c >= _a);



        return c;

    }



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



contract ERC20 is IERC20 {

  using SafeMath for uint256;



  mapping (address => uint256) private _balances;



  mapping (address => mapping (address => uint256)) private _allowed;



  uint256 private _totalSupply;



  function totalSupply() public view returns (uint256) {

    return _totalSupply;

  }



  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];

  }



  function allowance(

    address owner,

    address spender

   )

    public

    view

    returns (uint256)

  {

    return _allowed[owner][spender];

  }



  function transfer(address to, uint256 value) public returns (bool) {

    _transfer(msg.sender, to, value);

    return true;

  }



  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));



    _allowed[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);

    return true;

  }



  function transferFrom(

    address from,

    address to,

    uint256 value

  )

    public

    returns (bool)

  {

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    _transfer(from, to, value);

    return true;

  }



  function increaseAllowance(

    address spender,

    uint256 addedValue

  )

    public

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].add(addedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  function decreaseAllowance(

    address spender,

    uint256 subtractedValue

  )

    public

    returns (bool)

  {

    require(spender != address(0));



    _allowed[msg.sender][spender] = (

      _allowed[msg.sender][spender].sub(subtractedValue));

    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

    return true;

  }



  function _transfer(address from, address to, uint256 value) internal {

    require(to != address(0));



    _balances[from] = _balances[from].sub(value);

    _balances[to] = _balances[to].add(value);

    emit Transfer(from, to, value);

  }



  function _mint(address account, uint256 value) internal {

    require(account != address(0));



    _totalSupply = _totalSupply.add(value);

    _balances[account] = _balances[account].add(value);

    emit Transfer(address(0), account, value);

  }

}



contract RUSEK is ERC20 {



    string private _name = "Ruslan Yuzmukhametov";

    string private _symbol = "YRR";

    uint8 private _decimals = 1;

    mapping (uint => string) _avto;

    uint index;



    mapping (uint => string) friend;



    string _previousOwner;

    string _owner;



    constructor() public {

        _mint(address(this), 138);

        newAvto("AVEO, svoya sobstvennaya");

        friend[1] = "TEMOR";

        friend[2] = "ALBERTO";

        friend[3] = "VANO";

        friend[4] = "ALBERTLAR";

        friend[5] = "GAFUR";

        _previousOwner = "Sanya";

        _owner = "Nastya";

    }



    function newAvto(string _shit) public {

        index++;

        _avto[index] = _shit;

    }



    function newOwner(string _newOwner) external {

        _previousOwner = _owner;

        _owner = _newOwner;

    }



    function name() public view returns(string) {

      return _name;

    }



    function symbol() public view returns(string) {

      return _symbol;

    }



    function decimals() public view returns(uint8) {

      return _decimals;

    }



    function name(uint _) public view returns(string) {

      return _name;

    }



    function owner(uint _) external view returns(string) {

        return _owner;

    }



    function predidushiyOwner(uint _) external view returns(string) {

        return _previousOwner;

    }



    function withdraw(uint _) external {

        transfer(msg.sender, balanceOf(address(this)));

    }



    function vozrast(uint _) external view returns(uint256) {

        return (now - 879724800) / 365 days;

    }



    function razmerPipiski(uint _) external view returns(uint256) {

        require(msg.sender == address(0), "izvinite, v solidity net drobnih chisel");

    }



    function nation(uint _) external pure returns(string) {

        return "TATAR";

    }



    function education(uint _) external pure returns(string) {

        return "HuiEgoSnaet";

    }



    function orientation(uint _) external pure returns(string) {

        return "goluboy";

    }



    function avto(uint _number) external view returns(string) {

        return _avto[_number];

    }



    function friends(uint _) external view returns(string, string, string, string, string) {

        return(friend[1], friend[2], friend[3], friend[4], friend[5]);

    }



    function russinaRuletka(uint _) external view returns(string) {

        uint random = block.timestamp % 5;

        if (random == 1) {

            return "RUSEK";

        }

        if (random == 2) {

            return "JOSIK";

        }

        if (random == 3) {

            return "RUSLANCHIK";

        }

        if (random == 4) {

            return "YUZMUKHAMETOV";

        }

        if (random == 0) {

            return "RAUFOVICH";

        }

    }



    function poluchaetLesha(uint _) external pure returns(bool) {

        return true;

    }



    function dataSmerti(uint _) external pure returns(uint) {

        return 1542398400;

    }



    function zakhlopniEbalnick(uint _) external pure returns(bool) {

        return true;

    }



    function segodnyaTiIgraeshVFootbol(uint _) external pure returns(string) {

        return "a zavtra tebe d zhepu zabivayut gol";

    }



    function ebetSmartContracti(uint _) external pure returns(bool) {

        return true;

    }

}