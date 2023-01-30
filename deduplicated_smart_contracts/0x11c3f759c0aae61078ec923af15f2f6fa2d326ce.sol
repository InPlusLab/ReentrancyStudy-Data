/**
 *Submitted for verification at Etherscan.io on 2019-12-26
*/

pragma solidity ^0.4.10;

contract Fyer {
    string  public name = "Fyer";
    string  public symbol = "FYER";
    string  public standard = "DApp Token v1.0";
    uint256 public totalSupply;
    uint256 public decimals=18;
    
    uint256 public stage = 0;
    mapping(uint256 => uint256) public stages;
    uint256 public difference =0;
    uint256 public origin_block = 0;
    uint256 public loop = 0;
    
    uint256 public dexamillions;
    uint256 public millions;
    uint256 public hundredks;
    uint256 public tenks;
    uint256 public ks;
    uint256 public hundreds;
    uint256 public tens;
    uint256 public units;
    
    uint256 public lastBlockNumber;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public temp_balances;
    mapping(address => uint256) public lastBurnBlockNumber;
    
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => mapping(address => uint256)) public temp_allowance;
    mapping(address => mapping(address => uint256)) public lastAllowanceBurnBlockNumber; 
    
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
  
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    constructor (uint256 _initialSupply) public {
        totalSupply = mul(_initialSupply, 10**(decimals));
        balanceOf[msg.sender] = totalSupply;
        temp_balances[msg.sender] = totalSupply;
        origin_block = block.number;
        lastBurnBlockNumber[msg.sender] = origin_block;

    }
    
    function burn_allowance (address _add, address _add2) public returns (bool success){
        
        lastBlockNumber = block.number;
        
        if (lastAllowanceBurnBlockNumber[_add][_add2]!=0 && lastAllowanceBurnBlockNumber[_add][_add2]<add(27000000, origin_block)){
                
            stage = 0;
            loop = 0;
            
            if (lastBlockNumber>add(origin_block, 27000000)){
                lastBlockNumber = add(origin_block, 27000000);
            }
            
            
            uint256 balance = temp_allowance[_add][_add2];
             
            difference = sub(lastBlockNumber, lastAllowanceBurnBlockNumber[_add][_add2]);
            
            if (difference>10000000){
                
                loop = add(loop, 1);
                
                dexamillions = div(difference, 10000000);
                
                for (uint256 i=0; i<dexamillions; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 3593813), 100000000000);
                }
                
                difference = sub(difference, mul(dexamillions, 10000000));
            }
            
            if (difference>1000000){
                
                loop = add(loop, 1);
                
                millions = div(difference, 1000000);
                
                for (i=0; i<millions; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 35938136636), 100000000000);
                }
                
                difference = sub(difference, mul(millions, 1000000));
            }
            
            if (difference>100000){
                
                loop = add(loop, 1);
                
                hundredks = div(difference,100000);
                
                for (i=0; i<hundredks; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 90272517794), 100000000000);
                    
                }
                
                difference = sub(difference, mul(hundredks, 100000));

                
            }
            
            if (difference>10000){
                
                loop = add(loop, 1);
                
                tenks=div(difference, 10000);
                
                for (i=0; i<tenks; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 98981847473), 100000000000);
                    
                }
                
                difference = sub(difference, mul(tenks, 10000));

            }
            
            if (difference>1000){
                
                loop = add(loop, 1);
                
                ks=div(difference, 1000);
                
                for (i=0; i<ks; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 99897715231), 100000000000);
                    
                }
                
                difference = sub(difference, mul(ks, 1000));

                
            }
            
            if (difference>100){
                
                loop = add(loop, 1);
                
                hundreds = div(difference, 100);

                for (i=0; i<hundreds; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 99989766812), 100000000000);
                    
                }
                
                difference = sub(difference, mul(hundreds, 100));
                
            }
            
            if (difference>10){
                
                loop = add(loop, 1);
                
                tens = div(difference, 10);

                for (i=0; i<tens; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 99998976634), 100000000000);
                    
                }
                
                difference = sub(difference, mul(tens, 10));
                
            }
            
            if (difference>1){
                
                loop = add(loop, 1);
                
                units = div(difference, 1);

                for (i=0; i<units; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 99999897662), 100000000000);
                    
                }
                
                difference = sub(difference, mul(units, 1));
                
            }
            
            temp_allowance[_add][_add2] = balance;

        }
        
        lastAllowanceBurnBlockNumber[_add][_add2]=lastBlockNumber;
        
        return true;
    }
    
    function burn (address _add) public returns(bool success){
        
        lastBlockNumber = block.number;
        
        if (lastBurnBlockNumber[_add]!=0 && lastBurnBlockNumber[_add]<add(27000000, origin_block)){
                
            stage = 0;
            loop = 0;
            
            if (lastBlockNumber>add(origin_block, 27000000)){
                lastBlockNumber = add(origin_block, 27000000);
            }
            
            
            
            uint256 balance = temp_balances[_add];
             
            difference = sub(lastBlockNumber, lastBurnBlockNumber[_add]);
            
            if (difference>10000000){
                
                loop = add(loop, 1);
                
                dexamillions = div(difference, 10000000);
                
                for (uint256 i=0; i<dexamillions; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 3593813), 100000000000);
                }
                
                difference = sub(difference, mul(dexamillions, 10000000));
            }
            
            if (difference>1000000){
                
                loop = add(loop, 1);
                
                millions = div(difference, 1000000);
                
                for (i=0; i<millions; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 35938136636), 100000000000);
                }
                
                difference = sub(difference, mul(millions, 1000000));
            }
            
            if (difference>100000){
                
                loop = add(loop, 1);
                
                hundredks = div(difference,100000);
                
                for (i=0; i<hundredks; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 90272517794), 100000000000);
                    
                }
                
                difference = sub(difference, mul(hundredks, 100000));

                
            }
            
            if (difference>10000){
                
                loop = add(loop, 1);
                
                tenks=div(difference, 10000);
                
                for (i=0; i<tenks; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 98981847473), 100000000000);
                    
                }
                
                difference = sub(difference, mul(tenks, 10000));

            }
            
            if (difference>1000){
                
                loop = add(loop, 1);
                
                ks=div(difference, 1000);
                
                for (i=0; i<ks; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 99897715231), 100000000000);
                    
                }
                
                difference = sub(difference, mul(ks, 1000));

                
            }
            
            if (difference>100){
                
                loop = add(loop, 1);
                
                hundreds = div(difference, 100);

                for (i=0; i<hundreds; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 99989766812), 100000000000);
                    
                }
                
                difference = sub(difference, mul(hundreds, 100));
                
            }
            
            if (difference>10){
                
                loop = add(loop, 1);
                
                tens = div(difference, 10);

                for (i=0; i<tens; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 99998976634), 100000000000);
                    
                }
                
                difference = sub(difference, mul(tens, 10));
                
            }
            
            if (difference>1){
                
                loop = add(loop, 1);
                
                units = div(difference, 1);

                for (i=0; i<units; i++){
                    
                    stages[stage]=balance;
                
                    stage = add(stage, 1);
                    
                    balance = div(mul(balance, 99999897662), 100000000000);
                    
                }
                
                difference = sub(difference, mul(units, 1));
                
            }

            totalSupply = add(sub(totalSupply, temp_balances[_add]), balance); 
            
            temp_balances[_add] = balance;

        }
        
        lastBurnBlockNumber[_add]=lastBlockNumber;
        
        if (msg.sender==_add){
            balanceOf[msg.sender] = temp_balances[msg.sender];
        }
        
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        
        lastBlockNumber = block.number;
        
        burn(msg.sender);
        
        require(balanceOf[msg.sender] >= _value);
        
        temp_balances[msg.sender] = sub(temp_balances[msg.sender], _value);
        balanceOf[msg.sender] = sub(balanceOf[msg.sender], _value);
        
        burn(_to);
        balanceOf[_to] = add(balanceOf[_to], _value);
        temp_balances[_to] = add(temp_balances[_to], _value);
        
        emit Transfer(msg.sender, _to, _value);

        return true;
    }
    
    function transfer_percentage(address _to, uint256 _value) public returns (bool success) {
        
        lastBlockNumber = block.number;
        
        uint256 original_balance = balanceOf[msg.sender];
        
        burn(msg.sender);
        balanceOf[msg.sender] = temp_balances[msg.sender];
        
        _value = div(mul(_value, balanceOf[msg.sender]), original_balance);
        
        require(balanceOf[msg.sender] >= _value);
        
        temp_balances[msg.sender] = sub(temp_balances[msg.sender], _value);

        balanceOf[msg.sender] = sub(balanceOf[msg.sender], _value);
        balanceOf[_to] = add(balanceOf[_to], _value);
        
        burn(_to);
        temp_balances[_to] = add(temp_balances[_to], _value);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        lastBlockNumber = block.number;
        
        allowance[msg.sender][_spender] = _value;
        temp_allowance[msg.sender][_spender] = _value;
        lastAllowanceBurnBlockNumber[msg.sender][_spender]=lastBlockNumber;
        
        emit Approval(msg.sender, _spender, _value);

        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
                
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        
        lastBlockNumber = block.number;
        
        burn(_from);
        
        burn_allowance(_from, msg.sender);
        
        require(_value <= temp_allowance[_from][msg.sender]);
        require(_value <= temp_balances[_from]);
        
        
        balanceOf[_from] = sub(balanceOf[_from], _value);
        temp_balances[_from] = sub(temp_balances[_from], _value);
        
        burn(_to);
        
        balanceOf[_to] = add(balanceOf[_to], _value);
        temp_balances[_to] = add(temp_balances[_to], _value);
        
        allowance[_from][msg.sender] = sub(allowance[_from][msg.sender], _value);
        temp_allowance[_from][msg.sender] = sub(temp_allowance[_from][msg.sender], _value);
        
        emit Transfer(_from, _to, _value);

        return true;
    }
    

}