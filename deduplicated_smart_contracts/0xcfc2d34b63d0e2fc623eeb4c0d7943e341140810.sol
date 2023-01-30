pragma solidity ^0.5.17;

import "./MorpheusGameController.sol";
import "./SafeMath.sol";


contract randomOracle {

    address public gameAddress;
    MorpheusGameController public game;
    uint256 nonce = 17;
    uint8 mod = 2;
    address public deployer;
    
    using SafeMath for uint256;
    
   constructor() public{
    deployer = msg.sender;
    }
    
    modifier onlyGame() {
        require(msg.sender == gameAddress);
        _;
    }
    
    function setGame(MorpheusGameController _game, address _gameAddress) public{
        require(msg.sender==deployer,"Not your Oracle");
        game = _game;
        gameAddress = _gameAddress;
    }
    
    function getRandom(bytes32 _id) external onlyGame() returns(uint){
        return _getRandom(_id);
    }
    
    
    function _getRandom(bytes32 _id) private returns(uint256){
        uint256 _random = (uint256(keccak256(abi.encodePacked(now,_id, block.difficulty,nonce,block.number)))) % mod; 
        nonce = nonce.add(1);
        returnResult(_id,_random);
    }
    
    
    function returnResult(bytes32 _id, uint _result) private{
        game.callback(_id,_result);
    }
    
    
}
