/**

 *Submitted for verification at Etherscan.io on 2018-10-24

*/



//д�����Լ��Ŀ�ģ�����Ϊ�˷����ҿ��ٵĽ���ETH��IFS֮��Ķһ�

//��Լ�Ļ���ԭ���ע�ͣ�����Լ����д�ķǳ���ϸ���Է����ҽ��мල������

//������Լ���߼��ǳ��򵥣�

//1.�û�������Լ��ETH����С��λΪ0.01ETH��ÿ0.01ETH����Լ����û���ҹ����ĵ�ַ����200��IFS Token��ȥ

//2.С��0.01ETH�Ĳ��֣���Լ����һء�IFS������������һ���˻���Ȩ����ǰ��Լ�ģ������Ȩ�������㣬���Լ��ʧ�ܣ��û��������ETHҲ��ֱ�ӱ����أ�����ʧ��



//IFSʹ�ó�����

//������https://www.fanstime.org/

//APP  Fanstime

//Fanstime��һ���������ǽ��׵Ľ����������Թ���������ǵ�ʱ�䣬�ȴ��۸����ǻ����ǽ�����Ȩ

//IFS��Fanstime�е�ͨ�û��ң����������10:1(��ÿ��IFS�۸�Ϊ1ëǮ)�Ĺ̶��һ��ʡ��ٷ����Ӵ���ʽ�ر�֤���ʵ��ȶ�





//                   _ooOoo_

//                  o8888888o

//                  88" . "88

//                  (| -_- |)

//                  O\  =  /O

//               ____/`---'\____

//             .'  \\|     |//  `.

//            /  \\|||  :  |||//  \

//           /  _||||| -:- |||||-  \

//           |   | \\\  -  /// |   |

//           | \_|  ''\---/''  |   |

//           \  .-\__  `-`  ___/-. /

//         ___`. .'  /--.--\  `. . __

//      ."" '<  `.___\_<|>_/___.'  >'"".

//     | | :  ` - `.;`\ _ /`;.`/ - ` : | |

//     \  \ `-.   \_ __\ /__ _/   .-` /  /

//======`-.____`-.___\_____/___.-`____.-'======

//                   `=---='

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

//        [���汣��]�һ�IFS�볡�Ķ�׬��Ǯ







//���յ�ǰETH�۸�1400���Ҽ��㣬����ԼIFS�۸�Ϊ�����Ż�Ŷ~





//********************************************************************************

//*

//*

//*

//*             ����㲻���ű���Լ����ȫ��������0.01ETH����ʮ����Ǯ��

//*

//*                             �һ�һ��

//*

//*                     ȥApp����ʹ��һ�£����������

//*

//*

//*

//********************************************************************************











//ע�����

//1.��Ҫ�ӽ�����ֱ�ӶԱ���Լ��ң�������Ҫ�ӽ�����ֱ�ӶԱ���Լ��ң�������Ҫ�ӽ�����ֱ�ӶԱ���Լ��ң�����

pragma solidity ^0.4.25;

contract Token {

    function totalSupply() constant returns (uint256 supply) {}

    function balanceOf(address _owner) constant returns (uint256 balance) {}

    function transfer(address _to, uint256 _value) returns (bool success) {}

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    function approve(address _spender, uint256 _value) returns (bool success) {}

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract TokenExchange{



    uint256 public minETHExchange = 10000000000000000;//��С�һ���λ��0.01ETH��

    uint256 public TokenCountPer = 200000000000000000000;//ÿ0.01ETH�ɶһ�200IFS

    address public tokenAddress = address(0x5d47D55b33e067F8BfA9f1955c776B5AddD8fF17);//IFS��Token��ַ

    address public fromAddress = address(0xfA25eC30ba33742D8d5E9657F7d04AeF8AF91F40);//����IFS�ĵ�ַ�����ڳ��ҵ��û�����

    address public owner = address(0x8cddc253CA7f0bf51BeF998851b3F8E41053B784);//�����ջ�ETH�ĵ�ַ

    Token _token = Token(tokenAddress);//ʵ����IFS�ĺ�Լ



    function() public payable {

        require(msg.value >= minETHExchange);//���֧����ETH��������С��0.01ETH

        uint256 count = 0;

        count = msg.value / minETHExchange;//������Թ�����ٷ�



        uint256 remianETH = msg.value - (count * minETHExchange);//��������

        uint256 tokenCount = count * TokenCountPer;//����ɶһ�IFS����



        if(remianETH > 0){//���������������0�Ļ������������

            tx.origin.transfer(remianETH);

        }

        require(_token.transferFrom(fromAddress,tx.origin,tokenCount));//ʹ��IFS�ĺ�Լ�����׷����߷���IFS

        owner.transfer(address(this).balance);

    }

}