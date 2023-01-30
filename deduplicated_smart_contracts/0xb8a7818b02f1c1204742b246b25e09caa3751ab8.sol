/**

 *Submitted for verification at Etherscan.io on 2019-01-30

*/



pragma solidity ^0.4.25;



contract AxieCore{

  function getAxie(

    uint256 _axieId

  )

    external

    view

    returns (uint256 /* _genes */, uint256 /* _bornAt */);

}

contract GetStats{

  struct Type{

    uint hp;

    uint speed;

    uint skill;

    uint morale;

    uint attack;

    uint defense;

    uint accuracy;

  }

  mapping(uint => Type) internal typeMap;

  mapping(uint => Type) internal bonusMap;

  uint[] internal masks;

  AxieCore internal axie=AxieCore(0xF5b0A3eFB8e8E4c201e2A935F110eAaF3FFEcb8d); //0xC2093A90a4046B7F347c84f512651e6977BD11a0);

  constructor() public{

    //Beast

    typeMap[0]=Type({hp: 2, speed: 3, skill: 2, morale: 5, attack: 3, defense: 2, accuracy: 5});

    bonusMap[0]=Type({hp: 0, speed: 1, skill: 0, morale: 3, attack: 0, defense: 0, accuracy: 0});

    //Bug

    typeMap[1]=Type({hp: 3, speed: 2, skill: 3, morale: 4, attack: 2, defense: 3, accuracy: 5});

    bonusMap[1]=Type({hp: 1, speed: 0, skill: 0, morale: 3, attack: 0, defense: 0, accuracy: 0});

    //Bird

    typeMap[2]=Type({hp: 1, speed: 5, skill: 3, morale: 3, attack: 5, defense: 1, accuracy: 4});

    bonusMap[2]=Type({hp: 0, speed: 3, skill: 0, morale: 1, attack: 0, defense: 0, accuracy: 0});

    //Plant

    typeMap[3]=Type({hp: 5, speed: 2, skill: 2, morale: 3, attack: 2, defense: 5, accuracy: 3});

    bonusMap[3]=Type({hp: 3, speed: 0, skill: 0, morale: 1, attack: 0, defense: 0, accuracy: 0});

    //Aquatic

    typeMap[4]=Type({hp: 4, speed: 4, skill: 3, morale: 1, attack: 5, defense: 3, accuracy: 2});

    bonusMap[4]=Type({hp: 1, speed: 3, skill: 0, morale: 0, attack: 0, defense: 0, accuracy: 0});

    //Reptile

    typeMap[5]=Type({hp: 4, speed: 3, skill: 2, morale: 3, attack: 3, defense: 4, accuracy: 3});

    bonusMap[5]=Type({hp: 3, speed: 1, skill: 0, morale: 0, attack: 0, defense: 0, accuracy: 0});



    masks=new uint[](6);

    masks[0]=uint(0X3C0000000000000000000000000000000000000000000000);//eyes

    masks[1]=uint(0X3C00000000000000000000000000000000000000);//mouth

    masks[2]=uint(0X3C000000000000000000000000000000);//ears

    masks[3]=uint(0X3C0000000000000000000000);//horn

    masks[4]=uint(0x3C00000000000000);//back

    masks[5]=uint(0x3C000000);//tail

  }

  function getStats(uint id) public view returns (uint,uint,uint,uint){

    var (_genes,_bornAt) = axie.getAxie(id);

    return computeStatsFromGene(_genes);

  }

  function computeStatsFromGene(uint gene) public view returns(uint,uint,uint,uint){

    uint base=uint(gene & 0xF000000000000000000000000000000000000000000000000000000000000000) >> 252;

    uint hp=23+4*typeMap[base].hp;

    uint speed=23+4*typeMap[base].speed;

    uint skill=23+4*typeMap[base].skill;

    uint morale=23+4*typeMap[base].morale;

    uint partType;

    for(uint8 i=0;i<6;i++){

      partType=uint(gene & masks[i]) >> (186-32*i);

      hp+=bonusMap[partType].hp;

      speed+=bonusMap[partType].speed;

      skill+=bonusMap[partType].skill;

      morale+=bonusMap[partType].morale;

    }

    return(hp,speed,skill,morale);

  }



}