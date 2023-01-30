/**
 *Submitted for verification at Etherscan.io on 2019-10-16
*/

pragma solidity 0.5.0;
contract LuckUtils{
    struct User{
        address raddr;
        uint8 valid;
        uint recode;
    }
    struct Wallet{
        uint last_invest;
        uint profit_d;
        uint index;
        uint8 status;
        uint profit_s;
        uint profit;
        uint amount;
        uint rn;
    }
    struct Invset{
        uint amount;
        uint8 lv;
        uint8 day;
        uint8 share;
        address addr;
        uint8 notDone;
        uint time;
    }
    struct Journal{
        uint amount;
        uint8 tag;
        uint time;
    }
    address private owner = 0x008C35450C696a9312Aef0f45d0813056Cc57759;
    uint private uinwei = 1 ether;
    uint private minAmount = 1;
    uint private maxAmount1 = 5;
    uint private maxAmount2 = 10;
    uint private maxAmount3 = 50;
    constructor()public {
        owner = msg.sender;
    }

    modifier IsOwner{
        require(msg.sender==owner,"not owner");
        _;
    }

    function pstatic(uint256 amount,uint8 lv) public pure returns(uint256){
        if(lv==1){
            return amount*5/1000;
        }else if(lv==2){
            return amount/100;
        }else if(lv==3){
            return amount*12/1000;
        }
        return 0;
    }

    function pdynamic(uint256 uinam,uint8 uLv,uint256 rei,uint8 riL2,uint remRn,uint256 layer) public pure returns(uint256){
        uint256 samount = 0;
        if(uinam<=0){
            return 0;
        }else if(rei<=0){
            return 0;
        }else if(riL2==3||rei>uinam){
            samount = pstatic(uinam,uLv);
        }else{
            samount = pstatic(rei,uLv);
        }

        if(riL2 == 1){
            if(layer==1){
                return samount/2;
            }else if(layer==2){
                return samount/5;
            }else if(layer==3){
                return samount/10;
            }else{
                return 0;
            }
        }else if(riL2 == 2||riL2 == 3){
            if(layer==1){
                return samount;
            }else if(layer==2){
                return samount*70/100;
            }else if(layer==3){
                return samount/2;
            }else if(layer>=4&&layer<=10){
                return samount/10;
            }else if(layer>=11&&layer<=20){
                return samount*5/100;
            }else if(layer>=21&&remRn>=2){
                return samount/100;
            }else{
                return 0;
            }
        }else{
            return 0;
        }
    }

    function check(uint amount,uint open3)public view returns (bool,uint8){

        if(amount%uinwei != 0){
            return (false,0);
        }

        uint amountEth = amount/uinwei;

        if(amountEth>=minAmount&&amountEth<=maxAmount1){
            return (true,1);
        }else if(amountEth>maxAmount1&&amountEth<=maxAmount2){
            return (true,2);
        }else if(open3==1&&amountEth>maxAmount2&&amountEth<=maxAmount3){
            return (true,3);
        }else{
            return (false,0);
        }
    }

    function isSufficient(uint amount,uint betPool,uint riskPool,uint thisBln) public pure returns(bool,uint256){
        if(amount>0&&betPool>amount){
            if(thisBln>riskPool){
                uint256 balance = thisBln-riskPool;
                if(balance>=amount){
                    return (true,amount);
                }
                return (false,balance);
            }
        }
        return (false,0);
    }

    function currTimeInSeconds() public view returns (uint256){
        return block.timestamp;
    }
}