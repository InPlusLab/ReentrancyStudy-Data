/**

 *Submitted for verification at Etherscan.io on 2019-02-09

*/



pragma solidity ^0.4.24;



contract CarHistoryFactory{

    address owner;



    struct CarRepairShop{

        bool doesExist;

        string shopName;

        string descriptions;

    }



    mapping (address => CarRepairShop) carRepairShops;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner() {

        require(msg.sender == owner, "Not authorized.(owner)");

        _;

    }



    function addRepairShop(string _shopName, string _descriptions, address _shopAddress) onlyOwner public {

        if (carRepairShops[_shopAddress].doesExist != true){

            CarRepairShop memory tempShop;



            tempShop.shopName = _shopName;

            tempShop.descriptions = _descriptions;

            tempShop.doesExist = true;



            carRepairShops[_shopAddress] = tempShop;

        } else {

            updateRepairShop(_shopName, _descriptions, _shopAddress);

        }

    }



    function updateRepairShop(string _shopName, string _descriptions, address _shopAddress) onlyOwner public {

        require(carRepairShops[_shopAddress].doesExist == true);

        carRepairShops[_shopAddress].descriptions = _descriptions;

        carRepairShops[_shopAddress].shopName = _shopName;

    }



    address[] repairHistoryContract;

    mapping (string => address) repairHistoryVehicleContract;



    modifier onlyRepairShop() {

        require(existRepairShop(msg.sender), "Not authorized.(shop)");

        _;

    }



    function existRepairShop(address _address) public view returns(bool){

        return carRepairShops[_address].doesExist;

    }



    function createRepairHistoryContract(string _VIN, string _repairTarget, string _repairDetail) onlyRepairShop public {

        if(repairHistoryVehicleContract[_VIN] != 0){

            RepairHistory historyContract = RepairHistory(repairHistoryVehicleContract[_VIN]);

            historyContract.addRepairHistory(_repairTarget, _repairDetail, msg.sender);

        }else{

            address newRepairHistory = new RepairHistory(_VIN, _repairTarget, _repairDetail, msg.sender);

            repairHistoryContract.push(newRepairHistory);

            repairHistoryVehicleContract[_VIN] = newRepairHistory;

        }

    }



    function getVehicleHistoryCount(string _VIN) public view returns(uint){

        require(repairHistoryVehicleContract[_VIN] != 0);

        RepairHistory historyContract = RepairHistory(repairHistoryVehicleContract[_VIN]);

        return historyContract.getRepairHistoryCount();

    }



    function getVehicleHistory(string _VIN, uint _number) public view returns(string, string, string, string, uint){

        require(repairHistoryVehicleContract[_VIN] != 0);



        RepairHistory historyContract = RepairHistory(repairHistoryVehicleContract[_VIN]);

        address repairShopAddress;

        string memory repairTarget;

        string memory repairDetail;

        uint repairTime;

        (repairShopAddress, repairTarget, repairDetail, repairTime) = historyContract.getRepairHistory(_number);

        return (carRepairShops[repairShopAddress].shopName, carRepairShops[repairShopAddress].descriptions, repairTarget, repairDetail, repairTime);

    }



    function getVehicleAddresses() public view returns(address[]){

        return repairHistoryContract;

    }



    function getVehicle(address _historyContract) public view returns(string){

        RepairHistory historyContract = RepairHistory(_historyContract);

        return historyContract.getVIN();

    }

}



contract RepairHistory{

    address factoryAddress;

    address senderAddress;



    struct VehicleRepairHistory{

        address repairShop;

        uint repairTime;

        string repairTarget;

        string repairDetail;

    }



    string VIN;



    VehicleRepairHistory[] vehicleRepairHistory;



    modifier onlyRepairShop(){

        CarHistoryFactory factory = CarHistoryFactory(factoryAddress);

        require(factory.existRepairShop(senderAddress), "Not authorized.(shop)");

        _;

    }



    constructor(string _VIN, string _repairTarget, string _repairDetail, address _sender) public {

        factoryAddress = msg.sender;

        senderAddress = _sender;



        VIN = _VIN;



        addRepairHistory(_repairTarget, _repairDetail, _sender);

    }



    function addRepairHistory(string _repairTarget, string _repairDetail, address _sender) onlyRepairShop public {

        VehicleRepairHistory memory history;

        history.repairShop = _sender;

        history.repairTarget = _repairTarget;

        history.repairDetail = _repairDetail;

        history.repairTime = now;

        vehicleRepairHistory.push(history);

    }



    function getRepairHistoryCount() public view returns(uint){

        return vehicleRepairHistory.length;

    }



    function getRepairHistory(uint _number) public view returns(address, string, string, uint){

        return (vehicleRepairHistory[_number].repairShop, vehicleRepairHistory[_number].repairTarget, vehicleRepairHistory[_number].repairDetail, vehicleRepairHistory[_number].repairTime);

    }



    function getVIN() public view returns(string){

        return VIN;

    }

}