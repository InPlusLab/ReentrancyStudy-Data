/**
 *Submitted for verification at Etherscan.io on 2019-06-10
*/

pragma solidity ^0.4.25;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    } 
}

library SafeMath8{
     function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        require(c >= a);
        return c;
    }  

    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b <= a);
        uint8 c = a - b;
        return c;
    }

     function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) {
            return 0;
        }
        uint8 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b > 0);
        uint8 c = a / b;
        return c;
    }
 }



interface ERC20 {
  function decimals() external view returns(uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns(bool);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) ;
}

interface master{
    function inquire_location(address _address) external view returns(uint16, uint16);
    function inquire_slave_address(uint16 _slave) external view returns(address);
    function inquire_tot_building(uint16 _slave, uint16 _domain) external view returns(uint8[]);
    function owner_slave_amount()external view returns(uint);
    function owner_slave(uint _index) external view returns(address);
} 
 
interface boxManager{
    function showBoxAmount(uint8 _boxIndex) external view returns (uint);
    function newContracts(uint _boxIndex) external view returns (address);
    
}



  
contract owned{

    address public manager;

    constructor() public{
        manager = msg.sender;
    }

    modifier onlymanager{
        require(msg.sender == manager);
        _;
    } 

    function transferownership(address _new_manager) public onlymanager {
        manager = _new_manager;
    }
}   

contract trade is owned{  

    address arina_address = 0xe6987cd613dfda0995a95b3e6acbabececd41376;
    address master_address = 0x0ac10bf0342fa2724e93d250751186ba5b659303;
    
    address boxManager_address = 0x8842511f9eaaa75904017ff8ca26ba03ee2ddfa0;

    mapping(uint8 => mapping(uint16 => uint)) lv1BuyPrice; 

    mapping(uint16 => uint) pool; 
    mapping(uint16 => mapping(uint8 => uint)) box_amount_city; 
    
    using SafeMath8 for uint8;
    using SafeMath for uint;
    event buyBox(address indexed target, uint8 boxIndex, uint boxAmount, uint buyPrice); 
    event sellBox(address indexed target, uint8 boxIndex, uint boxAmount, uint sellPrice); 
    
    
    function() external payable{}

    constructor() public{
        
        
        lv1BuyPrice[0][1] = 300;
        lv1BuyPrice[0][2] = 320;
        lv1BuyPrice[0][3] = 280;
        lv1BuyPrice[0][4] = 290;
        lv1BuyPrice[0][5] = 250;
        lv1BuyPrice[0][6] = 260; 
        lv1BuyPrice[0][7] = 240;
        lv1BuyPrice[0][8] = 230;
        lv1BuyPrice[0][9] = 160; 
        lv1BuyPrice[0][10] = 156;
        lv1BuyPrice[0][11] = 144;
        lv1BuyPrice[0][12] = 140;
        lv1BuyPrice[0][13] = 420;
        lv1BuyPrice[0][14] = 415;
        lv1BuyPrice[0][15] = 390;
        lv1BuyPrice[0][16] = 460;

        lv1BuyPrice[1][1] = 150;
        lv1BuyPrice[1][2] = 160;
        lv1BuyPrice[1][3] = 156;
        lv1BuyPrice[1][4] = 164;
        lv1BuyPrice[1][5] = 100;
        lv1BuyPrice[1][6] = 110;
        lv1BuyPrice[1][7] = 105;
        lv1BuyPrice[1][8] = 98;
        lv1BuyPrice[1][9] = 250;
        lv1BuyPrice[1][10] = 240;
        lv1BuyPrice[1][11] = 230;
        lv1BuyPrice[1][12] = 260;
        lv1BuyPrice[1][13] = 200;
        lv1BuyPrice[1][14] = 220;
        lv1BuyPrice[1][15] = 210;
        lv1BuyPrice[1][16] = 190;

        lv1BuyPrice[2][1] = 300;
        lv1BuyPrice[2][2] = 310;
        lv1BuyPrice[2][3] = 320;
        lv1BuyPrice[2][4] = 290;
        lv1BuyPrice[2][5] = 250;
        lv1BuyPrice[2][6] = 240;
        lv1BuyPrice[2][7] = 260;
        lv1BuyPrice[2][8] = 235;
        lv1BuyPrice[2][9] = 200;
        lv1BuyPrice[2][10] = 210;
        lv1BuyPrice[2][11] = 220;
        lv1BuyPrice[2][12] = 180;
        lv1BuyPrice[2][13] = 400;
        lv1BuyPrice[2][14] = 420;
        lv1BuyPrice[2][15] = 380;
        lv1BuyPrice[2][16] = 390;

        lv1BuyPrice[3][1] = 200;
        lv1BuyPrice[3][2] = 220;
        lv1BuyPrice[3][3] = 210;
        lv1BuyPrice[3][4] = 190;
        lv1BuyPrice[3][5] = 250;
        lv1BuyPrice[3][6] = 240;
        lv1BuyPrice[3][7] = 230;
        lv1BuyPrice[3][8] = 260;
        lv1BuyPrice[3][9] = 300;
        lv1BuyPrice[3][10] = 310;
        lv1BuyPrice[3][11] = 320;
        lv1BuyPrice[3][12] = 280;
        lv1BuyPrice[3][13] = 150;
        lv1BuyPrice[3][14] = 140;
        lv1BuyPrice[3][15] = 160;
        lv1BuyPrice[3][16] = 170;

        lv1BuyPrice[4][1] = 250;
        lv1BuyPrice[4][2] = 240;
        lv1BuyPrice[4][3] = 235;
        lv1BuyPrice[4][4] = 230;
        lv1BuyPrice[4][5] = 300;
        lv1BuyPrice[4][6] = 310;
        lv1BuyPrice[4][7] = 320;
        lv1BuyPrice[4][8] = 280;
        lv1BuyPrice[4][9] = 200;
        lv1BuyPrice[4][10] = 220;
        lv1BuyPrice[4][11] = 210;
        lv1BuyPrice[4][12] = 190;
        lv1BuyPrice[4][13] = 420;
        lv1BuyPrice[4][14] = 410;
        lv1BuyPrice[4][15] = 380;
        lv1BuyPrice[4][16] = 390;

        lv1BuyPrice[5][1] = 250;
        lv1BuyPrice[5][2] = 240;
        lv1BuyPrice[5][3] = 235;
        lv1BuyPrice[5][4] = 230;
        lv1BuyPrice[5][5] = 300;
        lv1BuyPrice[5][6] = 320;
        lv1BuyPrice[5][7] = 280;
        lv1BuyPrice[5][8] = 270;
        lv1BuyPrice[5][9] = 200;
        lv1BuyPrice[5][10] = 220;
        lv1BuyPrice[5][11] = 210;
        lv1BuyPrice[5][12] = 240;
        lv1BuyPrice[5][13] = 400;
        lv1BuyPrice[5][14] = 410;
        lv1BuyPrice[5][15] = 440; 
        lv1BuyPrice[5][16] = 360; 
     
         
        
    }

    function receiveApproval(address _sender, uint256 _value,
    address _tokenContract, bytes memory _extraData) public{
        bytes1 action;

        uint8 index;
        uint8 box_amount;
        uint8 rate;
        
        uint16 city;
        uint16 domain;
        uint totalPrice; 
    
        address box_address; 
        
        action = _extraData[0]; 
        

        if (action == 0x1){ 
            require(_extraData.length == 3);
            rate = 100;
            (city,domain) = master(master_address).inquire_location(_sender);
            
            
            for(uint8 i =0 ;i<master(master_address).inquire_tot_building(city,domain).length ;i++ ){
                if( master(master_address).inquire_tot_building(city,domain)[i] == 4){
                   rate = rate.sub(5);
                }else if(master(master_address).inquire_tot_building(city,domain)[i] == 19){
                   rate = rate.sub(10);
                }
            }

            index = uint8(_extraData[1]); 
            box_amount = uint8(_extraData[2]);
            require(box_amount_city[city][index] >= box_amount);
            box_address = boxManager(boxManager_address).newContracts(index);
           
            totalPrice = 0;
            for( i =1 ;i<= box_amount ;i++ ){
                totalPrice = totalPrice.add(realPrice(city, index) /100 * rate); 
                pool[city] = pool[city].add(realPrice(city, index) /100 * rate);
            }

            require(_tokenContract == arina_address);
            
            require(_value == totalPrice);
            
            require(box_amount_city[city][index] >= box_amount);
            
            require(ERC20(arina_address).transferFrom(_sender, address(this), _value),"交易失敗");
            
            ERC20(box_address).transfer(_sender, box_amount);
            box_amount_city[city][index]= box_amount_city[city][index].sub(box_amount);
            emit buyBox(_sender,index,box_amount,totalPrice);
        }
 
        else if(action == 0x2){ 
            require(_extraData.length == 2);
            rate = 100;         
            
            index = uint8(_extraData[1]); 
            box_amount = uint8(_value);
            
            
            
            (city,domain) = master(master_address).inquire_location(_sender);
            
            
            for(i =0 ;i<master(master_address).inquire_tot_building(city,domain).length ;i++ ){
                if( master(master_address).inquire_tot_building(city,domain)[i] == 4){
                   rate = rate.add(5);
                }else if(master(master_address).inquire_tot_building(city,domain)[i] == 16){
                   rate = rate.add(10);
                }
            } 
            
            box_address = boxManager(boxManager_address).newContracts(index);

            
            totalPrice = 0; 
            for(i =1 ;i<= box_amount ;i++ ){
                totalPrice = totalPrice.add((realPrice(city, index)/4) /100 *rate);
                pool[city] = pool[city].sub((realPrice(city, index)/4) /100 *rate);
            }
             

            require(_tokenContract == box_address);
            
            require(ERC20(box_address).transferFrom(_sender, address(this), _value),"交易失敗");
            
            box_amount_city[city][index] =  box_amount_city[city][index].add(box_amount); 
            
            
            require(pool[city] >= totalPrice);
            
            ERC20(arina_address).transfer(_sender, totalPrice);
             
            emit sellBox(_sender,index,box_amount,totalPrice);
        }  
        else if(action == 0x3){ 
            require(_sender == manager);
            require(_extraData.length == 2);
            city = uint8(_extraData[1]);

            require(_tokenContract == arina_address);
            
            require(ERC20(arina_address).transferFrom(_sender, address(this), _value),"交易失敗");
            pool[city] = pool[city].add(_value);
        }

        else{revert();}
 
    }
    
    function checkSlave() public view returns(bool){ 
        uint length = master(master_address).owner_slave_amount();
        for(uint i=1;i<=length;i++){
             address slave = master(master_address).owner_slave(i);
             if(msg.sender == slave){
                 return true;
             }
        }
        return false;
    }

    
 
    function inquire_pool(uint16 _city) public view returns(uint){   
        return pool[_city];
    }

    function origBuyPrice(uint16 _city,uint8 _index) public view returns(uint){
        

        uint8 lv = _index%5 + 1 ;
        uint8 typ = _index/5 ; 
        if (lv == 1){  
            return lv1BuyPrice[typ][_city] * (10**7);
        }
        else{
            return lv1BuyPrice[typ][_city] * (10**7) * 3**(uint(lv)-1); 
        }
    }

    function cpi(uint16 _city) public view returns(int){        

        uint balance = pool[_city]/100000000;
        return (int(balance)*10000)/(500000)-10000;
        
        
    } 

    function realPrice(uint16 _city, uint8 _index) public view returns(uint){
        return origBuyPrice(_city,_index)*(10000+uint(cpi(_city)))/10000;
    }

    function inquire_box_address(uint8 _index) public view returns(address){
        return boxManager(boxManager_address).newContracts(_index);
    } 
 
    function inquire_box_amount(uint16 _city,uint8 _index) public view returns(uint){
        return box_amount_city[_city][_index];
    }
    
    function set_city_pool(uint _arina, uint16 _city ) external{   
        require(msg.sender == master_address);
        pool[_city] = pool[_city].add(_arina);
    }
    
    function set_city_box_amount(uint16 _city, uint8 _index, uint _amount ) external{   
        require(checkSlave());
        box_amount_city[_city][_index] = box_amount_city[_city][_index].add(_amount);
    }
    
    function exchange_arina(uint _arina, uint16 _city, address _target) external {
        require(msg.sender == master_address);
        require(pool[_city] >= _arina);
        ERC20(arina_address).transfer(_target, _arina); 
        pool[_city] = pool[_city].sub(_arina);
    }
 


    

    function withdraw_all_ETH() public onlymanager{
        manager.transfer(address(this).balance);
    }

    function withdraw_all_arina() public onlymanager{
        uint asset = ERC20(arina_address).balanceOf(address(this));
        uint length = master(master_address).owner_slave_amount();
        ERC20(arina_address).transfer(manager, asset);
         
        for(uint8 i = 1;i <= length;i++){
            pool[i] = 0;
        }
        
    }

    function withdraw_ETH(uint _eth_wei) public onlymanager{
        manager.transfer(_eth_wei);
    }

    function withdraw_arina(uint _arina, uint16 _city) public onlymanager{
        require(pool[_city] >= _arina);
        ERC20(arina_address).transfer(manager, _arina); 
        pool[_city] = pool[_city].sub(_arina);
    }


    function set_arina_address(address _arina_address) public onlymanager{
        arina_address = _arina_address;
    }

    function set_boxManager_address(address _boxManager_address) public onlymanager{
        boxManager_address = _boxManager_address;
    }

    function set_master_address(address _master_address) public onlymanager{
        master_address = _master_address;
    }

}