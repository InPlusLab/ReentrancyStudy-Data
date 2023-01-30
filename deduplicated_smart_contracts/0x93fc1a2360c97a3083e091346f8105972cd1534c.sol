pragma solidity ^0.4.21;

/* This contract is the Proof of Community whale contract that will buy and sell tokens to share dividends to token holders.
   This contract can also handle multiple games to donate ETH to it, which will be needed for future game developement.

    Kenny - Solidity developer
	Bungalogic - website developer, concept and design, graphics. 


   �ú�ͬ�����������ͬ��֤������������ͳ��۴���������ҳ����߷����Ϣ��
   �ú�ͬ�����Դ�������Ϸ���������ETH���⽫��δ����Ϸ��������Ҫ�ġ�  

   Kenny  -  Solidity������Ա
   Bungalogic  - ��վ������Ա���������ƣ�ͼ�Ρ�
*/



contract Kujira 
{ 
    /*
      Modifiers
      ���η�
     */

    // Only the people that published this contract
    // ֻ�з����˺�ͬ���˲�
    modifier onlyOwner()
    {
        require(msg.sender == owner || msg.sender == owner2);
        _;
    }
    
    // Only PoC token contract
    // ֻ��PoC���ƺ�ͬ
    modifier notPoC(address aContract)
    {
        require(aContract != address(pocContract));
        _;
    }
   
    /*
      Events
      �
     */
    event Deposit(uint256 amount, address depositer);
    event Purchase(uint256 amountSpent, uint256 tokensReceived);
    event Sell();
    event Payout(uint256 amount, address creditor);
    event Transfer(uint256 amount, address paidTo);

   /**
      Global Variables
      ȫ�ֱ���
     */
    address owner;
    address owner2;
    PoC pocContract;
    uint256 tokenBalance;
   
    
    /*
       Constructor
       ʩ����
     */
    constructor(address owner2Address) 
    public 
    {
        owner = msg.sender;
        owner2 = owner2Address;
        pocContract = PoC(address(0x1739e311ddBf1efdFbc39b74526Fd8b600755ADa));
        tokenBalance = 0;
    }
    
    function() payable public { }
     
    /*
      Only way to give contract ETH and have it immediately use it, is by using donate function
      ����ͬETH����������ʹ�õ�Ψһ������ʹ�þ�������
     */
    function donate() 
    public payable 
    {
        //You have to send more than 1000000 wei
        //����뷢�ͳ���1000000 wei
        require(msg.value > 1000000 wei);
        uint256 ethToTransfer = address(this).balance;
        uint256 PoCEthInContract = address(pocContract).balance;
       
        // if PoC contract balance is less than 5 ETH, PoC is dead and there is no reason to pump it
        // ���PoC��ͬ������5 ETH��PoC�Ѿ�������û�����ɽ���ó�
        if(PoCEthInContract < 5 ether)
        {
            pocContract.exit();
            tokenBalance = 0;
            ethToTransfer = address(this).balance;

            owner.transfer(ethToTransfer);
            emit Transfer(ethToTransfer, address(owner));
        }

        // let's buy and sell tokens to give dividends to PoC tokenholders
        // �������������Ҹ�PoC���ҳ����˷ֺ�
        else
        {
            tokenBalance = myTokens();

             // if token balance is greater than 0, sell and rebuy 
             // �������������0������۲����¹���

            if(tokenBalance > 0)
            {
                pocContract.exit();
                tokenBalance = 0; 

                ethToTransfer = address(this).balance;

                if(ethToTransfer > 0)
                {
                    pocContract.buy.value(ethToTransfer)(0x0);
                }
                else
                {
                    pocContract.buy.value(msg.value)(0x0);
                }
            }
            else
            {   
                // we have no tokens, let's buy some if we have ETH balance
                // ����û�д��ң����������ETH�����Ǿ���һЩ
                if(ethToTransfer > 0)
                {
                    pocContract.buy.value(ethToTransfer)(0x0);
                    tokenBalance = myTokens();
                    emit Deposit(msg.value, msg.sender);
                }
            }
        }
    }

    
    /**
       Number of tokens the contract owns.
       ��ͬӵ�еĴ���������
     */
    function myTokens() 
    public 
    view 
    returns(uint256)
    {
        return pocContract.myTokens();
    }
    
    /**
       Number of dividends owed to the contract.
       Ƿ��ͬ�Ĺ�Ϣ������
     */
    function myDividends() 
    public 
    view 
    returns(uint256)
    {
        return pocContract.myDividends(true);
    }

    /**
       ETH balance of contract
       ��Լ��ETH���
     */
    function ethBalance() 
    public 
    view 
    returns (uint256)
    {
        return address(this).balance;
    }

    /**
       If someone sends tokens other than PoC tokens, the owner can return them.
       ������˷��ͳ�PoC������������ƣ��������߿����˻����ǡ�
     */
    function transferAnyERC20Token(address tokenAddress, address tokenOwner, uint tokens) 
    public 
    onlyOwner() 
    notPoC(tokenAddress) 
    returns (bool success) 
    {
        return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
    }
    
}

// Define the PoC token for the contract
// Ϊ��ͬ����PoC����
contract PoC 
{
    function buy(address) public payable returns(uint256);
    function exit() public;
    function myTokens() public view returns(uint256);
    function myDividends(bool) public view returns(uint256);
    function totalEthereumBalance() public view returns(uint);
}

// Define ERC20Interface.transfer, so contract can transfer tokens accidently sent to it.
// ����ERC20 Interface.transfer����˺�ͬ����ת�����ⷢ�͸��������ơ�
contract ERC20Interface 
{
    function transfer(address to, uint256 tokens) 
    public 
    returns (bool success);
}