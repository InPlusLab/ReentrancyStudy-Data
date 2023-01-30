pragma solidity ^0.5.11;

import "./GridOwnership.sol";
import "./safemath.sol";
//import "./console.sol";

contract GridMain is GridOwnership {

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    //uint16 public version = 101;

    function buyGird(uint16 _i, uint16 _j, uint16 _k, uint16 _l, address payable _inviter) external payable whenNotPaused {
        require(_i >= 1 && _i <= 100, "value invalid");
        require(_j >= 1 && _j <= 100, "value invalid");
        require(_k >= _i && _k <= 100, "value invalid");
        require(_l >= _j && _l <= 100, "value invalid");
        //require(_k >= _i && _l >= _j, "value invalid");
        require((_k-_i+1)*(_l-_j+1) <= limitGridsEachtime, "too many grids you selected, that may cause problems.");
        uint16 _x;
        uint16 _y;
        //string memory position;
        uint16 position;
        uint256 currentPrice = 0;
        uint256 gridId = 0;
        uint256 tempLevelUpFee = 0;
        address payable inviter;

        if(_inviter == address(0)){
            inviter = owner;
        }else{
            inviter = _inviter;
        }

        //log("mappingPositionToGirdId[position]: ", mappingPositionToGirdId[position]);
        //log("arr_struct_grid[1].level: ", arr_struct_grid[1].level);
        //log("msg.value: ", msg.value);
        //uint fee = msg.value;
        //address acc = msg.sender;

        for(_x = _i; _x<=_k; _x++){
            for(_y = _j; _y<=_l; _y++){
                //position = strConcat(uint2str(_x),uint2str(_y));
                //log("position: ", position);
                position = (_x-1)*100+_y;
                gridId = mappingPositionToGirdId[position];
                if(gridId > 0){
                    structGird storage _grid = arr_struct_grid[gridId-1];
                    //if(_grid.level > 0){
                        //uint16 id = arr_struct_grid.push(structGird(_x, _y, 1)) - 1;
                        //mappingPositionToOwner[position] = msg.sender;
                        currentPrice += _grid.level * levelUpFee + levelUpFee;
                        _grid.owner.transfer(_grid.level * levelUpFee + levelUpFee / 5);
                    _grid.inviter.transfer(levelUpFee / 10);
                    authorAddress.transfer(levelUpFee / 10);
                    foundationAddress.transfer(levelUpFee / 10);
                    owner.transfer(levelUpFee/50);
                    mappingOwnerGridCount[_grid.owner] = mappingOwnerGridCount[_grid.owner].sub(1);
                    mappingOwnerGridCount[msg.sender] = mappingOwnerGridCount[msg.sender].add(1);
                    _grid.level = _grid.level.add(1);
                    _grid.owner = msg.sender;
                    if(_grid.inviter != inviter){
                        _grid.inviter = inviter;
                    }
                    //}
                }else{
                    //uint16 id = arr_struct_grid.push(structGird(_x, _y, 1)) - 1;
                    //mappingGirdPositionToOwner[position] = msg.sender;
                    //tempLevelUpFee = levelUpFee;
                    if(discountGridsCount < 1000){
                        //currentPrice += levelUpFee;
                    }else if(discountGridsCount < 3000){
                        tempLevelUpFee = levelUpFee*1/10;
                    }else if(discountGridsCount < 6000){
                        tempLevelUpFee = levelUpFee*3/10;
                    }else if(discountGridsCount < 10000){
                        tempLevelUpFee = levelUpFee*6/10;
                    }else{
                        tempLevelUpFee = levelUpFee;
                    }
                    discountGridsCount = discountGridsCount.add(1);
                    currentPrice += tempLevelUpFee;
                    uint id = arr_struct_grid.push(structGird(_x, _y, 1, msg.sender, inviter));
                    mappingPositionToGirdId[position] = id;
                    mappingOwnerGridCount[msg.sender] = mappingOwnerGridCount[msg.sender].add(1);
                    owner.transfer(tempLevelUpFee);
                }
            }
        }
        require(msg.value >= currentPrice, "out of your balance");
        //require(address(this).balance >= currentPrice, "out of contract balance, please buy level0 grids");
        /*for(_x = _i; _x<=_k; _x++){
            for(_y = _j; _y<=_l; _y++){
                //position = strConcat(uint2str(_x),uint2str(_y));
                position = (_x-1)*100+_y;
                gridId = mappingPositionToGirdId[position];
                if(gridId > 0){
                    structGird memory _grid = arr_struct_grid[gridId-1];
                 //&& _grid.level > 0){
                    //uint16 id = arr_struct_grid.push(structGird(_x, _y, 1)) - 1;
                    //mappingPositionToOwner[position] = msg.sender;
                    //mappingPositionToGird[position].level = mappingPositionToGird[position].level.add(1);
                    //mappingPositionToGird[position].owner = msg.sender;
                    _grid.owner.transfer(_grid.level * levelUpFee + levelUpFee / 5);
                    _grid.inviter.transfer(levelUpFee / 10);
                    authorAddress.transfer(levelUpFee / 10);
                    foundationAddress.transfer(levelUpFee / 10);
                    owner.transfer(levelUpFee/50);

                    mappingOwnerGridCount[_grid.owner] = mappingOwnerGridCount[_grid.owner].sub(1);
                    mappingOwnerGridCount[msg.sender] = mappingOwnerGridCount[msg.sender].add(1);
                    _grid.level = _grid.level.add(1);
                    _grid.owner = msg.sender;
                    _grid.inviter = inviter;
                }else{
                    uint id = arr_struct_grid.push(structGird(_x, _y, 1, msg.sender, inviter));
                    mappingPositionToGirdId[position] = id;
                    mappingOwnerGridCount[msg.sender] = mappingOwnerGridCount[msg.sender].add(1);
                    owner.transfer(levelUpFee);
                    //mappingGirdPositionToOwner[position] = msg.sender;
                    //mappingPositionToGird[position] = structGird(_x, _y, 1, msg.sender);
                }
            }
        }*/
        msg.sender.transfer(msg.value.sub(currentPrice));
    }

    function getGridPrice(uint16 _i, uint16 _j, uint16 _k, uint16 _l) external view whenNotPaused returns(uint256){
        require(_i >= 1 && _i <= 100, "value invalid");
        require(_j >= 1 && _j <= 100, "value invalid");
        require(_k >= _i && _k <= 100, "value invalid");
        require(_l >= _j && _l <= 100, "value invalid");
        //require(_k >= _i && _l >= _j, "value invalid");
        require((_k-_i+1)*(_l-_j+1) <= limitGridsEachtime, "too many grids you selected, that may cause problems.");
        uint16 _x;
        uint16 _y;
        //string memory position;
        uint16 position;

        //log("mappingPositionToGirdId[position]: ", mappingPositionToGirdId[position]);
        //log("arr_struct_grid[1].level: ", arr_struct_grid[1].level);
        //log("msg.value: ", msg.value);
        //uint fee = msg.value;
        //address acc = msg.sender;

        uint256 currentPrice = 0;
        uint256 gridId = 0;
        uint256 tempLevelUpFee = 0;
        for(_x = _i; _x<=_k; _x++){
            for(_y = _j; _y<=_l; _y++){
                //position = strConcat(uint2str(_x),uint2str(_y));
                //log("position: ", position);
                position = (_x-1)*100+_y;
                gridId = mappingPositionToGirdId[position];
                if(gridId > 0){
                    structGird memory _grid = arr_struct_grid[gridId-1];
                    //if(_grid.level > 0){
                        //uint16 id = arr_struct_grid.push(structGird(_x, _y, 1)) - 1;
                        //mappingPositionToOwner[position] = msg.sender;
                        currentPrice += _grid.level * levelUpFee + levelUpFee;
                    //}
                }else{
                    //uint16 id = arr_struct_grid.push(structGird(_x, _y, 1)) - 1;
                    //mappingGirdPositionToOwner[position] = msg.sender;
                    if(discountGridsCount < 1000){
                        //currentPrice += levelUpFee;
                    }else if(discountGridsCount < 3000){
                        tempLevelUpFee = levelUpFee*1/10;
                    }else if(discountGridsCount < 6000){
                        tempLevelUpFee = levelUpFee*3/10;
                    }else if(discountGridsCount < 10000){
                        tempLevelUpFee = levelUpFee*6/10;
                    }else{
                        tempLevelUpFee = levelUpFee;
                    }
                    //discountGridsCount = discountGridsCount.add(1);
                    currentPrice += tempLevelUpFee;
                    //currentPrice += levelUpFee;
                }
            }
        }

        return currentPrice;
    }
}
