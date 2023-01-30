/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

pragma solidity 0.4.25;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.4.25;

    contract GODToken {

        string public name;

        string public symbol;

        uint8 public decimals;

        uint public totalSupply;

        uint public supplied;

        uint public surplusSupply;

        uint beforeFrequency = 0;

        uint centerFrequency = 300;

        uint afterFrequency = 400;

        address owner;

        uint public usdtPrice = 10000;


        address lotteryAddr;

        address gameAddr;

        address themisAddr;

        mapping(address => uint) public balanceOf;

        mapping(address => mapping(address => uint)) public allowance;

        constructor(
            string _name,
            string _symbol,
            uint8 _decimals,
            uint _totalSupply,
            address _owner
        )  public {
            name = _name;
            symbol = _symbol;
            decimals = _decimals;
            totalSupply = _totalSupply * (10 ** uint256(decimals));
            owner = _owner;
            surplusSupply = totalSupply;
        }

        event Transfer(address indexed from, address indexed to,uint value);

        event Approval(address indexed owner, address indexed spender, uint256 value);

        modifier validDestination(address _to) {
            require(_to != address(0x0), "address cannot be 0x0");
            require(_to != address(this), "address cannot be contract address");
            _;
        }

        function setAuthorityAddr(address gAddr, address lAddr, address tAddr) external {
            require(owner == msg.sender, "Insufficient permissions");
            gameAddr = gAddr;
            lotteryAddr = lAddr;
            themisAddr = tAddr;
        }

        function calculationNeedGOD(uint usdtVal) external view returns(uint) {
            uint godCount = SafeMath.div(SafeMath.div(usdtVal * 10 ** 8, 10), usdtPrice);
            return godCount;
        }

        function gainGODToken(uint value, bool isCovert) external {
            require(msg.sender == lotteryAddr || msg.sender == themisAddr, "Insufficient permissions");
            require(value <= surplusSupply, "GOD tokens are larger than the remaining supply");
            if(isCovert) {
                surplusSupply = SafeMath.sub(surplusSupply, value);
                supplied = SafeMath.add(supplied, value);
                uint number = SafeMath.div(supplied, (10 ** uint256(decimals)) * 10 ** 4);
                if(number <= 18900) {
                    uint count = 0;
                    if(number <= 6000) {
                        count = SafeMath.div(number, 10);
                        if(count > beforeFrequency) {
                            for(uint i = beforeFrequency; i < count; i++) {
                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));
                            }
                            beforeFrequency = count;
                        }
                    }else if(number <= 12000) {
                        if(beforeFrequency < 600) {
                            count = 600;
                            for(uint i2 = beforeFrequency; i2 < count; i2++) {
                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));
                            }
                            beforeFrequency = count;
                        }
                        count = SafeMath.div(number, 20);
                        if(count > centerFrequency) {
                            for(uint j = centerFrequency; j < count; j++) {
                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));
                            }
                            centerFrequency = count;
                        }
                    }else {
                        if(centerFrequency < 600) {
                            count = 600;
                            for(uint j2 = centerFrequency; j2 < count; j2++) {
                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));
                            }
                            centerFrequency = count;
                        }
                        count = SafeMath.div(number, 30);
                        if(count > afterFrequency) {
                            for(uint k = 0; k < count; k++) {
                                usdtPrice = SafeMath.add(usdtPrice, SafeMath.div(usdtPrice, 100));
                            }
                            afterFrequency = count;
                        }
                    }
                }
            }
            balanceOf[msg.sender] = SafeMath.add(balanceOf[msg.sender], value);
        }

        function transfer(address to, uint value) public validDestination(to) {
            require(value >= 0, "Incorrect transfer amount");
            require(balanceOf[msg.sender] >= value, "Insufficient balance");
            require(balanceOf[to] + value >= balanceOf[to], "Transfer failed");

            balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], value);
            balanceOf[to] = SafeMath.add(balanceOf[to], value);

            emit Transfer(msg.sender, to, value);
        }

        function approve(address spender, uint value) public {
              require((value == 0) || (allowance[msg.sender][spender] == 0));
              allowance[msg.sender][spender] = value;
              emit Approval(msg.sender, spender, value);
        }

        function transferFrom(
            address from,
            address to,
            uint value
            )
            public validDestination(to) {
            require(value >= 0, "Incorrect transfer amount");
            require(balanceOf[from] >= value, "Insufficient balance");
            require(balanceOf[to] + value >= balanceOf[to], "Transfer failed");
            require(value <= allowance[from][msg.sender], "The transfer amount is higher than the available amount");

            balanceOf[from] = SafeMath.sub(balanceOf[from], value);
            balanceOf[to] = SafeMath.add(balanceOf[to], value);
            allowance[from][msg.sender] = SafeMath.sub(allowance[from][msg.sender], value);

            emit Transfer(from, to, value);
        }

        function burn(address addr, uint value) public {
            require(msg.sender == gameAddr, "Insufficient permissions");
            require(balanceOf[addr] >= value, "Insufficient GOD required");
            balanceOf[addr] = SafeMath.sub(balanceOf[addr], value);
            balanceOf[address(0x0)] = SafeMath.add(balanceOf[address(0x0)], value);

            emit Transfer(addr, address(0x0), value);
        }
    }