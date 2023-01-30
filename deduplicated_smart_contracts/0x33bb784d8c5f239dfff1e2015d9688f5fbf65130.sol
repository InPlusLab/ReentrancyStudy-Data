/**
 *Submitted for verification at Etherscan.io on 2019-10-22
*/

/**
 *Submitted for verification at Etherscan.io on 2018-02-08
*/
 

contract TycoonToken {
    // Track how many tokens are owned by each address.
    mapping (address => uint256) public balanceOf;

    string public name = "BlockRewardEther";
    string public symbol = "BRETH";
    uint8 public decimals = 18;
    address owner = msg.sender;
    uint public Distributed;

    uint256 public totalSupply = 1000000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);
    mapping(address => bool)isWorksContract;

    function TycoonToken() public {
        // Initially assign all tokens to the contract's creator.
        balanceOf[this] = totalSupply;
     //   Transfer(address(0), msg.sender, totalSupply);
       //  Transfer(this, msg.sender, totalSupply);
    }
    function AddContract(address _add) external{
        require(msg.sender == owner);
       isWorksContract[_add] = true;
    }
    
    
    
     function claimReward(uint Amount, address add,address isGamecontract) public returns (bool success) {
        if(balanceOf[this] >= Amount){
        require(balanceOf[this] >= Amount);
        require(isWorksContract[isGamecontract] == true);
        uint Amount1 =  Amount * (uint256(10) ** decimals);
        balanceOf[this] -= Amount1;  // deduct from sender's balance
        balanceOf[add] += Amount1;          // add to recipient's balance
        Transfer(this, add, Amount1);
        Distributed += Amount1;
        return true;
         }
         else{
             
         }
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;  // deduct from sender's balance
        balanceOf[to] += value;          // add to recipient's balance
        Transfer(msg.sender, to, value);
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 value)
        public
        returns (bool success)
    {
        allowance[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
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
        Transfer(from, to, value);
        return true;
    }
}