pragma solidity ^ 0.4.11;


contract Dragon {
    function burnDragons( uint256 _amount );
}


contract Burner {
    

    address public dragon;
    uint256 public DragonsBurned;
    
    
    modifier onlyDragon() {
        if (msg.sender != dragon) {
            throw;
        }
        _;
    }
    
    function Burner () {
        
        dragon = 0x814F67fA286f7572B041D041b1D99b432c9155Ee; // Hardcode Dragon address
        
    }



    function dragonHandler( uint256 _amount ) onlyDragon {
        
        Dragon drag = Dragon ( dragon );
        drag.burnDragons ( _amount );
        DragonsBurned += _amount;
    
        
    }   
 
 
    
    
}