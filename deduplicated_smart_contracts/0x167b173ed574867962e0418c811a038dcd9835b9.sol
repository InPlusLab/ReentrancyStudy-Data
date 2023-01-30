/**

 *Submitted for verification at Etherscan.io on 2019-02-10

*/



pragma solidity ^0.5.0;



contract SharingContract {

    address serviceProviderAddress = msg.sender;   

        

    uint    public  contractBalance;    

    uint    public  feeBalance;

    uint    idGenerator;                // default is 0



    struct SharingProd {    

       address payable ownerAddress;  

       address borrowerAddress;  

       string prodName;

       uint    price;

       uint    like;

    }



    mapping (uint => SharingProd) sharingProdList;



    function createSharingProd(string memory _prodName, uint _price) public payable returns(uint) {

       require(msg.value == 1 wei);

       

       SharingProd memory newSharingProd;

       newSharingProd.ownerAddress = msg.sender;

       newSharingProd.prodName = _prodName;

       newSharingProd.price = _price;

       sharingProdList[idGenerator] = newSharingProd;

       

       idGenerator++;

       feeBalance += msg.value;

       return idGenerator-1;

    }

    

    function getSharingProdInfo(uint _sharingProdId) public view returns(address, address, string memory, uint, uint){

      require(sharingProdList[_sharingProdId].ownerAddress != address(0));

       

       return (

           sharingProdList[_sharingProdId].ownerAddress, 

           sharingProdList[_sharingProdId].borrowerAddress,

           sharingProdList[_sharingProdId].prodName, 

           sharingProdList[_sharingProdId].price,

           sharingProdList[_sharingProdId].like

       );

   }



   function borrowSharingProd(uint _sharingProdId) public payable {

        require(sharingProdList[_sharingProdId].price == msg.value);

        require(sharingProdList[_sharingProdId].borrowerAddress == address(0));

        

        sharingProdList[_sharingProdId].borrowerAddress = msg.sender;

        contractBalance += msg.value;

    }

    

    function finishSharingProd(uint _sharingProdId, bool isLike) public {

        require(sharingProdList[_sharingProdId].borrowerAddress == msg.sender);



        sharingProdList[_sharingProdId].borrowerAddress = address(0); // initialize borrowerAddress

        if(isLike) {

            sharingProdList[_sharingProdId].like += 1;

        }

            

        contractBalance -= (sharingProdList[_sharingProdId].price);

        sharingProdList[_sharingProdId].ownerAddress.transfer(sharingProdList[_sharingProdId].price);

    }

}