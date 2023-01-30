/**

 *Submitted for verification at Etherscan.io on 2018-12-28

*/



pragma solidity ^0.4.17;



contract ERC20Interface {

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    

}

contract blocks{

     ERC20Interface public acceptedToken;

     uint256 starttime;

     uint256 a=3;

     //操作账户

    address account0=0x4d891FB46ae966cdEe6920F9cD908BcaD5044799;

    //接收地址，1-9为归还的地址   O(∩_∩)O悬镜O(∩_∩)O

      address account1=0xc9f7A171a5642E680bD6171bF0Da626C6c2e9FcE;//100000 BACC 任总    

      address account2=0x694Cb887FECE2575F92Ef30D67Ad9f5e5b01E8E9;//600000 BACC 于秀丽

      address account3=0x29BFb6ff54417a9Dc0419eD820D87351826A9732;//500000 BACC 肖二长

      address account4=0x3b3D11875a0e846455FB96196597FC72b42dD6d1;//177542 BACC 于秀丽

      address account5=0x54b63CBCe8374BB060f446BAab1eCde0e2Bf3E45;//150771 BACC 怡君    

      address account6=0x93D20388CfF710f565be4927150BB9C455ECe9e1;//195427 BACC 刘小东

      address account7=0x2638C5b660E6d6662A3aEa4522050Dac63D7e4e5;//198714 BACC 雨荷   

      address account8=0xE90382BaEA59bBC93F5F7583c6E32c9f5F6D5139;//104442 BACC 小雨   

      address account9=0xda7B3A22b2BE61cCF235726ee1d6b3477284319e;//500000 BACC 张清辉

  function blocks(address _acceptedToken) public {

    acceptedToken = ERC20Interface(_acceptedToken);

    starttime=now;

  }





  function unblock() public{

      require(msg.sender==account0);

        if(now>(starttime)&&now<(starttime + 2 years)){

          require(a==3);

          acceptedToken.transferFrom(account0,account1,33333);

          acceptedToken.transferFrom(account0,account2,200000);

          acceptedToken.transferFrom(account0,account3,166666);

          acceptedToken.transferFrom(account0,account4,59180);

          acceptedToken.transferFrom(account0,account5,50257);

          acceptedToken.transferFrom(account0,account6,65142);

          acceptedToken.transferFrom(account0,account7,66238);

          acceptedToken.transferFrom(account0,account8,34814);

          acceptedToken.transferFrom(account0,account9,166666);

          a=a-1;

      }

        if(now>(starttime+2 years)&&now<(starttime+3 years)){

            require(a==2);

             acceptedToken.transferFrom(account0,account1,33333);

          acceptedToken.transferFrom(account0,account2,200000);

          acceptedToken.transferFrom(account0,account3,166666);

          acceptedToken.transferFrom(account0,account4,59180);

          acceptedToken.transferFrom(account0,account5,50257);

          acceptedToken.transferFrom(account0,account6,65142);

          acceptedToken.transferFrom(account0,account7,66238);

          acceptedToken.transferFrom(account0,account8,34814);

          acceptedToken.transferFrom(account0,account9,166666);

            a=a-1;

      }

        if(now>(starttime+3 years)){

              require(a==1);

          acceptedToken.transferFrom(account0,account1,33333);

          acceptedToken.transferFrom(account0,account2,200000);

          acceptedToken.transferFrom(account0,account3,166666);

          acceptedToken.transferFrom(account0,account4,59180);

          acceptedToken.transferFrom(account0,account5,50257);

          acceptedToken.transferFrom(account0,account6,65142);

          acceptedToken.transferFrom(account0,account7,66238);

          acceptedToken.transferFrom(account0,account8,34814);

          acceptedToken.transferFrom(account0,account9,166666);

             a=a-1;

      }

  }

}