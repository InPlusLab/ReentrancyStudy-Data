/**

 *Submitted for verification at Etherscan.io on 2018-09-04

*/



pragma solidity ^0.4.23;



contract XToken {

    /**

    ���ң���Ʒ����

    ��ʼ��ʱ������Ʒ��������Ʒ�۸�͵�λ

    ��Ʒ�̼�:���տ

    ��ң������ʷ�

    */

    struct Goods {

        string _desc;   //��ע

        string _name;   //��Ʒ����

        string _unit;   //��Ʒ������λ

        uint _price;    //��Ʒ�۸�

        address _shopowner; //�곤

    }



    /**

    ��ҹ����嵥

    */

    struct ShoppingItem {

        uint _id;

        uint _count;

    }

    struct ShoppingList {

        address _buyer;

        ShoppingItem[] _items;

    }



    address private _owner; //ƽ̨ӵ����

    address private _finance; //����ƾ���ƽ̨�տ���Ա

    uint private _percentage; //�Ӱٷֱ����



    //��Ʒ�б�

    Goods[] private _goods;

    //����嵥

    ShoppingList[] private _buyers;





	mapping (address => uint) private balances;



	event Transfer(address indexed _from, address indexed _to, uint256 _value);





	function send_coin(address from, address to, uint amount) private returns(bool sufficient) {

		require(balances[from] > amount, "�����׵��˺�û�и�����");



		balances[from] -= amount;

		balances[to] += amount;



		emit Transfer(from, to, amount);

		return true;

	}



    /**

    ֻ�й���Ա�ſ��Ը������˺ų�ֵ

     */

    function recharge(address to, uint amount) public returns(bool) {

        balances[to] += amount;

        balances[_owner] -= amount;//���˺�����Ҫ���٣���֤����һ��

        emit Transfer(_owner, to, amount);

        return true;

    } 



    constructor(uint percent) public {

		//balances[msg.sender] = 100000000000;



        //_owner = msg.sender;

        _percentage = percent; 



        //ָ�����������

        _owner = address(0x420534893844e08af857df1b4ee8e25b09eed227); //�����˺�

        _finance = address(0x1Af666fB7D3fF7096eA3b47AB2A710fF10E5Cd41);



        //_owner = address(0x18523c846681b51cdfa69a5daa251fb1977a151e); //˽�����˺�

        //_finance = address(0xbf62672b2705e59df2216499a94a2e53c928d53f); 

        //��������

        balances[_owner] = 100000000000;

    }



    function set_percentage(uint percentage) public {

        require(msg.sender == _owner, "��ƽ̨����Ա�������޸����");



        _percentage = percentage;

    }



    /**

     */

    function add_goods(string name, string unit, uint price, address shopowner, string desc) public returns(uint) {

        require(price > 0, "��Ʒ�۸���Ҫ����0");

        require(shopowner != address(0), "�̼ҵ�ַ����Ϊ��");

        /**

        ������Ʒ��ÿ����Ʒ�Ļ������ԣ��۸񣬵�λ�����ƣ�ӵ����

        */

        Goods memory newGoods = Goods({

            _name: name,

            _unit: unit,

            _price: price,

            _shopowner: shopowner,

            _desc: desc

        });

        

        _goods.push(newGoods);



        //������Ʒ�ɣ�

        return _goods.length;

    }



    function sell_goods(uint goodsID, uint count, address buyer) public returns(uint) {

        /**

        ������Ʒ�������Ҫ��곤������Ʒ����������֧������

        */

        

        require(count > 0, "�������ݲ���Ϊ0");

        require(buyer != address(0), "��Ҳ���Ϊ��");



        /**

        �����Ƿ���ָ������Ʒ��������о�֧����û�з���

         */



        uint price;

        uint p_shop;

        uint p_owner;

        /**���������Ҫ�޸�Ϊid�����ң���������Ʒ������Ϊ��Ʒ�����ظ� */

        for (uint i = 0; i < _goods.length; i++) {

            if( i ==  goodsID) {



                price = _goods[i]._price * count;



                p_shop = price * (100 - _percentage) / 100;

                p_owner = price * _percentage;



                if(false == send_coin(buyer, _goods[i]._shopowner, p_shop)) {

                    return 0;

                }

                if(false == send_coin(buyer, _finance, p_owner)) {

                    return 0;

                }



                //ֻ��������嵥��

                return price;

            }

        }



        return 0;

    }







    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {

        bytes storage a = bytes(_a);

        bytes memory b = bytes(_b);

        if (a.length != b.length)

            return false;

        // @todo unroll this loop

        for (uint i = 0; i < a.length; i ++)

            if (a[i] != b[i])

            {

                return false;

            }    

        return true;

    }

    



	function get_balance(address addr) public returns(uint) {

		return balances[addr];

	}

}