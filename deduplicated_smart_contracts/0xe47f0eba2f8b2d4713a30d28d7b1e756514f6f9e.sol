pragma solidity ^ 0.4.11;


contract Dragon {
    function burnDragons( uint256 _amount );
}


contract Burner {
    

    address dragon;
    uint256 DragonsBurned;
    
    
    modifier onlyDragon() {
        if (msg.sender != dragon) {
            throw;
        }
        _;
    }
    
    function Burner () {
        
        dragon = 0x1d1CF6cD3fE91fe4d1533BA3E0b7758DFb59aa1f;
        
    }



    function dragonHandler( uint256 _amount ) onlyDragon {
        
        Dragon drag = Dragon ( dragon );
        drag.burnDragons ( _amount );
        DragonsBurned += _amount;
    
        
    }   
 
 
    
    
}