/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.4.25;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}

contract BaseToken is Ownable {
    using SafeMath for uint256;

    string constant public name = 'Ñô³Îó¦Ð·';
    string constant public symbol = 'YCPX';
    uint8 constant public decimals = 2;
    uint256 public totalSupply = 5000000;
    uint256 constant public _totalLimit = 10000000000000000;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0));
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));
        totalSupply = totalSupply.add(value);
        require(_totalLimit >= totalSupply);
        balanceOf[account] = balanceOf[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }
}

contract BurnToken is BaseToken {
    event Burn(address indexed from, uint256 value);

    function burn(uint256 value) public returns (bool) {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(msg.sender, value);
        return true;
    }

    function burnFrom(address from, uint256 value) public returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(from, value);
        return true;
    }
}

contract BatchToken is BaseToken {
    
    function batchTransfer(address[] addressList, uint256[] amountList) public returns (bool) {
        uint256 length = addressList.length;
        require(addressList.length == amountList.length);
        require(length > 0 && length <= 20);

        for (uint256 i = 0; i < length; i++) {
            transfer(addressList[i], amountList[i]);
        }

        return true;
    }
}

contract MintToken is BaseToken {
    uint256 constant public mintMax = 0;
    uint256 public mintTotal = 0;
    uint256 constant public mintBegintime = 1591936926;
    uint256 constant public mintPerday = 0;

    event Mint(address indexed to, uint256 value);

    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        require(block.timestamp >= mintBegintime);
        require(value > 0);

        if (mintPerday > 0) {
            uint256 currentMax = (block.timestamp - mintBegintime).mul(mintPerday) / (3600 * 24);
            uint256 leave = currentMax.sub(mintTotal);
            require(leave >= value);
        }

        mintTotal = mintTotal.add(value);
        if (mintMax > 0 && mintTotal > mintMax) {
            revert();
        }

        _mint(to, value);
        emit Mint(to, value);
        return true;
    }

    function mintToMax(address to) public onlyOwner returns (bool) {
        require(block.timestamp >= mintBegintime);
        require(mintMax > 0);

        uint256 value;
        if (mintPerday > 0) {
            uint256 currentMax = (block.timestamp - mintBegintime).mul(mintPerday) / (3600 * 24);
            value = currentMax.sub(mintTotal);
            uint256 leave = mintMax.sub(mintTotal);
            if (value > leave) {
                value = leave;
            }
        } else {
            value = mintMax.sub(mintTotal);
        }

        require(value > 0);
        mintTotal = mintTotal.add(value);
        _mint(to, value);
        emit Mint(to, value);
        return true;
    }
}

contract AirdropToken is BaseToken {
    uint256 constant public airMax = 0;
    uint256 public airTotal = 0;
    uint256 public airBegintime = 1591936926;
    uint256 public airEndtime = 1591936926;
    uint256 public airOnce = 0;
    uint256 public airLimitCount = 1;

    mapping (address => uint256) public airCountOf;

    event Airdrop(address indexed from, uint256 indexed count, uint256 tokenValue);
    event AirdropSetting(uint256 airBegintime, uint256 airEndtime, uint256 airOnce, uint256 airLimitCount);

    function airdrop() public payable {
        require(block.timestamp >= airBegintime && block.timestamp <= airEndtime);
        require(msg.value == 0);
        require(airOnce > 0);
        airTotal = airTotal.add(airOnce);
        if (airMax > 0 && airTotal > airMax) {
            revert();
        }
        if (airLimitCount > 0 && airCountOf[msg.sender] >= airLimitCount) {
            revert();
        }
        _mint(msg.sender, airOnce);
        airCountOf[msg.sender] = airCountOf[msg.sender].add(1);
        emit Airdrop(msg.sender, airCountOf[msg.sender], airOnce);
    }

    function changeAirdropSetting(uint256 newAirBegintime, uint256 newAirEndtime, uint256 newAirOnce, uint256 newAirLimitCount) public onlyOwner {
        airBegintime = newAirBegintime;
        airEndtime = newAirEndtime;
        airOnce = newAirOnce;
        airLimitCount = newAirLimitCount;
        emit AirdropSetting(newAirBegintime, newAirEndtime, newAirOnce, newAirLimitCount);
    }

}

contract CustomToken is BaseToken, BurnToken, BatchToken, MintToken, AirdropToken {
    constructor() public {
        balanceOf[0x766E72da5c64Bd9416467bFfD577ACa555450352] = totalSupply;
        emit Transfer(address(0), 0x766E72da5c64Bd9416467bFfD577ACa555450352, totalSupply);

        owner = 0x766E72da5c64Bd9416467bFfD577ACa555450352;
    }

    function() public payable {
        airdrop();
    }
}