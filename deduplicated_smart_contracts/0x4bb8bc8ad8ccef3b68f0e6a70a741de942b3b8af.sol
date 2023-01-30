/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

contract Tombstone{
    string public name;
    string public born_on;
    string public died_on;
    string public epitaph;
    string public place;
    
    event Mourn(address indexed who);
    
    bool built = false;
    
    function build(
        string memory _name, 
        string memory _born_on, 
        string memory _died_on, 
        string memory _epitaph, 
        string memory _place
    ) public {
        require(!built);
        name = _name;
        born_on = _born_on;
        died_on = _died_on;
        epitaph = _epitaph;
        place = _place;
        built = true;
    }
    
    
    function info() public view 
        returns(
            string memory, 
            string memory, 
            string memory, 
            string memory,
            string memory
        )
    {
        return (name, born_on, died_on, epitaph, place);
    }
    
    function mourn() public {
        emit Mourn(msg.sender);
    }
}