/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity ^0.4.10;

    contract Attractor {
        string  public name = "Attractor";
        string  public symbol = "ETHA1";
        string  public standard = "ERC20 Attract Token v0.0 (1 percent)";

        uint256 public totalSupply;

        mapping(uint256 => uint256) public totalSupplyDeep;
        mapping(uint256 => uint256) public reserveDeep;

        address owner;

        event Transfer(
            address indexed _from,
            address indexed _to,
            uint256 _value
        );

        event Approval(
            address indexed _owner,
            address indexed _spender,
            uint256 _value
        );

        event TransferDeep(
            address indexed _from,
            address indexed _to,
            uint256 _value,
      uint256 _deep
        );

        event ApprovalDeep(
            address indexed _owner,
            address indexed _spender,
            uint256 _value,
            uint256 _deep
        );

        mapping(address => uint256) public balanceOf;
        mapping(address => mapping(address => uint256)) public allowance;

        mapping(address => mapping(uint256 => uint256)) public balanceOfDeep;
        mapping(address => mapping(address => mapping(uint256 => uint256))) public allowanceDeep;

        mapping(address => uint256) supportOf;

        constructor (uint256 _initialSupply) public {
            balanceOf[msg.sender] = _initialSupply;
            totalSupply = _initialSupply;

            owner = msg.sender;
        }

        function transfer(address _to, uint256 _value) public returns (bool success) {
            require(balanceOf[msg.sender] >= _value);

            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;

            balanceOfDeep[msg.sender][0] = balanceOf[msg.sender];
            balanceOfDeep[_to][0] = balanceOf[_to];

            emit Transfer(msg.sender, _to, _value);

            return true;
        }

        function transferDeep(address _to, uint256 _value, uint256 _deep) public returns (bool success) {
            require(balanceOfDeep[msg.sender][_deep] >= _value);

            balanceOfDeep[msg.sender][_deep] -= _value;
            balanceOfDeep[_to][_deep] += _value;

            if(_deep == 0)
            {
                balanceOf[msg.sender] = balanceOfDeep[msg.sender][0];
                balanceOf[_to] = balanceOfDeep[_to][0];

                emit Transfer(msg.sender, _to, _value);
            }

            emit TransferDeep(msg.sender, _to, _value, _deep);

            return true;
        }

        function approve(address _spender, uint256 _value) public returns (bool success) {
            allowance[msg.sender][_spender] = _value;
            allowanceDeep[msg.sender][_spender][0] = _value;

            emit Approval(msg.sender, _spender, _value);

            return true;
        }

        function approveDeep(address _spender, uint256 _value, uint256 _deep) public returns (bool success) {
            allowanceDeep[msg.sender][_spender][_deep] = _value;
            if(_deep == 0)
            {
                allowance[msg.sender][_spender] = _value;
                emit Approval(msg.sender, _spender, _value);
            }

            emit ApprovalDeep(msg.sender, _spender, _value, _deep);
            return true;
        }

        function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
            require(_value <= balanceOf[_from]);
            require(_value <= allowance[_from][msg.sender]);

            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;

            allowance[_from][msg.sender] -= _value;

            balanceOfDeep[_from][0] = balanceOf[_from];
            balanceOfDeep[_to][0] = balanceOf[_to];

            allowanceDeep[_from][msg.sender][0] = allowance[_from][msg.sender];

            emit Transfer(_from, _to, _value);

            return true;
        }

        function transferFromDeep(address _from, address _to, uint256 _value, uint256 _deep) public returns (bool success) {
            require(_value <= balanceOfDeep[_from][_deep]);
            require(_value <= allowanceDeep[_from][msg.sender][_deep]);

            balanceOfDeep[_from][_deep] -= _value;
            balanceOfDeep[_to][_deep] += _value;

            allowanceDeep[_from][msg.sender][_deep] -= _value;

            if(_deep == 0)
            {
                balanceOf[_from] = balanceOfDeep[_from][0];
                balanceOf[_to] = balanceOfDeep[_to][0];

                allowance[_from][msg.sender] = allowanceDeep[_from][msg.sender][0];

                emit Transfer(_from, _to, _value);
            }

            emit TransferDeep(_from, _to, _value, _deep);

            return true;
        }

        function buyActs() public payable {
        require((msg.value * (totalSupply + 1)) >= (address(this).balance - msg.value + 1));
            uint256 adds = (msg.value * (totalSupply + 1))/(address(this).balance - msg.value + 1);

            balanceOf[msg.sender] += adds;
            totalSupply += adds;

            balanceOfDeep[msg.sender][0] = balanceOf[msg.sender];
            totalSupplyDeep[0] = totalSupply;
        }

        function buyActsDeep(uint256 _value, uint256 _deep) public {
            require((_value * (totalSupplyDeep[_deep + 1] + 1)) >= (reserveDeep[_deep] + 1));
            require(_value <= balanceOfDeep[msg.sender][_deep]);

            uint256 adds = (_value * (totalSupplyDeep[_deep + 1] + 1))/(reserveDeep[_deep] + 1);

            balanceOfDeep[msg.sender][_deep + 1] += adds;
            totalSupplyDeep[_deep + 1] += adds;

            reserveDeep[_deep] += _value;
            balanceOfDeep[msg.sender][_deep] -= _value;

            if(_deep == 0)
            {
                balanceOf[msg.sender] = balanceOfDeep[msg.sender][0];
            }
        }

            function sellActs(uint256 _value) public returns (bool success) {
            require(balanceOf[msg.sender] >= _value);
            require((_value * address(this).balance) >= (totalSupply + 1));

            uint256 sell = (_value * address(this).balance)/(totalSupply + 1);
            uint256 fee = (sell/100) + 1;
            sell -= fee;

            balanceOf[msg.sender] -= _value;
            totalSupply -= _value;

            balanceOfDeep[msg.sender][0] = balanceOf[msg.sender];

            if(supportOf[msg.sender] == 0)
            {
                if(!(owner.call.value(fee/10)()))
                    revert();
            }
            else if(supportOf[msg.sender] > 1)
            {
                if(!(owner.call.value(((supportOf[msg.sender] - 1) * fee)/100)()))
                    revert();
            }

            if(!(msg.sender.call.value(sell)()))
                revert();

            return true;
        }

        function sellActsDeep(uint256 _value, uint256 _deep) public returns (bool success) {
            require(balanceOfDeep[msg.sender][_deep + 1] >= _value);
            require((_value * reserveDeep[_deep]) >= (totalSupplyDeep[_deep + 1] + 1));

            uint256 sell = (_value * reserveDeep[_deep])/(totalSupplyDeep[_deep + 1] + 1);
            sell -= (sell/100) + 1;

            reserveDeep[_deep] -= sell;
            balanceOfDeep[msg.sender][_deep] += sell;

            balanceOfDeep[msg.sender][_deep + 1] -= _value;
            totalSupplyDeep[_deep + 1] -= _value;

            if(_deep == 0)
            {
                balanceOf[msg.sender] = balanceOfDeep[msg.sender][_deep];
            }

            return true;
        }

        function support(uint256 _value) public {
            require(_value < 100);
            supportOf[msg.sender] = _value + 1;
        }
    }

    // set deep to X

    contract AttractorDeepShell{

        mapping (address => uint256) public balanceOf;

        string  public name = "Attractor Deep Shell";
        string  public symbol = "ETHA1D1";
        string  public standard = "ERC20 Attract Deep Shell Token v0.0 (1 percent/1 deep)";

        uint256 public totalSupply = 0;
        uint8 public decimals = 18;

        uint256 public deep = 1;

        address public attractorAddress = 0xB9f04289514D233AEa451eA90c2613EfdeF40116;

        event Transfer(address indexed from, address indexed to, uint256 value);

        constructor () public {
        }

        function transfer(address to, uint256 value) public returns (bool success) {
            require(balanceOf[msg.sender] >= value);

            balanceOf[msg.sender] -= value;
            balanceOf[to] += value;

            emit Transfer(msg.sender, to, value);
            return true;
        }

        event Approval(address indexed owner, address indexed spender, uint256 value);

        mapping(address => mapping(address => uint256)) public allowance;

        function approve(address spender, uint256 value)
            public
            returns (bool success)
        {
            allowance[msg.sender][spender] = value;
            emit Approval(msg.sender, spender, value);
            return true;
        }

        function transferFrom(address from, address to, uint256 value)
            public
            returns (bool success)
        {
            require(value <= balanceOf[from]);
            require(value <= allowance[from][msg.sender]);

            balanceOf[from] -= value;
            balanceOf[to] += value;
            allowance[from][msg.sender] -= value;
            emit Transfer(from, to, value);
            return true;
        }

            function hold(uint256 value)
            public
            returns (bool success)
        {
            Attractor a = Attractor(attractorAddress);
            require(a.transferFromDeep(msg.sender,address(this),value,deep));

            balanceOf[msg.sender] += value;
            totalSupply += value;

            return true;
        }

        function free(uint256 value)
            public
            returns (bool success)
        {
            Attractor a = Attractor(attractorAddress);

            require(balanceOf[msg.sender] >= value);
            require(a.approveDeep(msg.sender,value,deep));

            balanceOf[msg.sender ] -= value;
            totalSupply -= value;

            return true;
        }
    }