/**

 *Submitted for verification at Etherscan.io on 2018-09-26

*/



pragma solidity ^0.4.25;



// donate: 0x95CC9E2FE2E2de48A02CF6C09439889d72D5ea78



contract GorgonaKiller {

    // �ѧէ�֧� �ԧ��ԧ�ߧ�

    address public GorgonaAddr; 

    

    // �ާڧߧڧާѧݧ�ߧ�� �է֧��٧ڧ�

    uint constant public MIN_DEP = 0.01 ether; 

    

    // �ާѧܧ�ڧާѧݧ�ߧ�� ��ڧ�ݧ� ���ѧߧ٧ѧܧ�ڧ� ���� �ӧ��ݧѧ�� �էڧӧڧէ֧ߧէ��

    uint constant public TRANSACTION_LIMIT = 100;

    

    // �ҧѧݧѧߧ� �էڧӧڧէ֧ߧէ��

    uint public dividends;

    

    // id ����ݧ֧էߧ֧ԧ� �ڧߧӧ֧�����, �ܧ�����ާ� �����ݧ� ���ݧѧ��

    uint public last_payed_id;

    

    // ��ҧ�ѧ� ���ާާ� �է֧��٧ڧ��� ��� �ڧߧӧ֧������

    uint public deposits; 

    

    // �ѧէ�֧�� �ڧߧӧ֧������

    address[] addresses;



    // �ާѧ�ڧߧ� �ѧէ�֧� �ڧߧӧ֧����� - �����ܧ���� �ڧߧӧ֧�����

    mapping(address => Investor) public members;

    

    // id �ѧէ�֧�� �� investors, deposit - ���ާާ� �է֧��٧ڧ���

    struct Investor {

        uint id;

        uint deposit;

    }

    

    constructor() public {

        GorgonaAddr = 0x020e13faF0955eFeF0aC9cD4d2C64C513ffCBdec; 

    }



    // ��ҧ�ѧҧ��ܧ� �������ݧ֧ߧڧ�

    function () external payable {



        // �֧�ݧ� ���ڧ�ݧ� �� �ԧ��ԧ�ߧ� �ӧ���էڧ�

        if (msg.sender == GorgonaAddr) {

            return;

        }

        

        // �֧�ݧ� �ҧѧݧѧߧ� �ҧ֧� ��֧ܧ��֧ԧ� �������ݧ֧ߧڧ� > 0 ��ڧ�֧� �� �էڧӧڧէ֧ߧէ�

        if ( address(this).balance - msg.value > 0 ) {

            dividends = address(this).balance - msg.value;

        }

        

        // �ӧ��ݧѧ�ڧӧѧ֧� �էڧӧڧէ֧ߧէ�

        if ( dividends > 0 ) {

            payDividends();

        }

        

        // �ڧߧӧ֧��ڧ��֧� ��֧ܧ��֧� �������ݧ֧ߧڧ�

        if (msg.value >= MIN_DEP) {

            Investor storage investor = members[msg.sender];



            // �է�ҧѧӧݧ�֧� �ڧߧӧ֧�����, �֧�ݧ� �֧�� �ߧ֧�

            if (investor.id == 0) {

                investor.id = addresses.push(msg.sender);

            }



            // �����ݧߧ�֧� �է֧��٧ڧ� �ڧߧӧ֧����� �� ��ҧ�ڧ� �է֧��٧ڧ�

            investor.deposit += msg.value;

            deposits += msg.value;

    

            // �����ѧӧݧ�֧� �� �ԧ��ԧ�ߧ�

            payToGorgona();



        }

        

    }



    // �����ѧӧݧ�֧� ��֧ܧ��֧� �������ݧ֧ߧڧ� �� �ԧ��ԧ�ߧ�

    function payToGorgona() private {

        if ( GorgonaAddr.call.value( msg.value )() ) return; 

    }



    // �ӧ��ݧѧ�� �էڧӧڧէ֧ߧէ��

    function payDividends() private {

        address[] memory _addresses = addresses;

        

        uint _dividends = dividends;



        if ( _dividends > 0) {

            uint num_payed = 0;

            

            for (uint i = last_payed_id; i < _addresses.length; i++) {

                

                // ���ڧ�ѧ֧� �էݧ� �ܧѧاէ�ԧ� �ڧߧӧ֧����� �է�ݧ� �էڧӧڧէ֧ߧէ��

                uint amount = _dividends * members[ _addresses[i] ].deposit / deposits;

                

                // �����ѧӧݧ�֧� �էڧӧڧէ֧ߧէ�

                if ( _addresses[i].send( amount ) ) {

                    last_payed_id = i+1;

                    num_payed += 1;

                }

                

                // �֧�ݧ� �է���ڧԧݧ� �ݧڧާڧ�� �ӧ��ݧѧ� �ӧ���էڧ� �ڧ� ��ڧܧݧ�

                if ( num_payed == TRANSACTION_LIMIT ) break;

                

            }

            

            // ��ҧߧ�ݧ�֧� id ����ݧ֧էߧ֧� �ӧ��ݧѧ��, �֧�ݧ� �ӧ��ݧѧ�ڧݧ� �ӧ�֧�

            if ( last_payed_id >= _addresses.length) {

                last_payed_id = 0;

            }

            

            dividends = 0;

            

        }

        

    }

    

    // ��ާ���ڧ� �ҧѧݧѧߧ� �ߧ� �ܧ�ߧ��ѧܧ��

    function getBalance() public view returns(uint) {

        return address(this).balance / 10 ** 18;

    }



    // ��ާ���ڧ� ��ڧ�ݧ� �ڧߧӧ֧������

    function getInvestorsCount() public view returns(uint) {

        return addresses.length;

    }



}