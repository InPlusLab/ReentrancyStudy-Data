/**

 *Submitted for verification at Etherscan.io on 2018-12-09

*/



pragma solidity 0.4.25;



/*

* Stin Go ��һ�����ܺϼs�ṩ���������롣 

* ���ܺϼs�ɴ_�������Y������I�`�ͺڿ͹���

* ��ҪͶ�볬�^�����ݔ��

*/



contract StinGo {



    struct UserRecord {

        address referrer;

        uint tokens;

        uint gained_funds;

        uint ref_funds;

        // �@���I�������ؓ���

        int funds_correction;

    }



    using SafeMath for uint;

    using SafeMathInt for int;

    using Fee for Fee.fee;

    using ToAddress for bytes;



    // ERC20

    string constant public name = "Stin Go";

    string constant public symbol = "STIN";

    uint8 constant public decimals = 18;



    // Fees

    Fee.fee private fee_purchase = Fee.fee(1, 10); // 10%

    Fee.fee private fee_selling  = Fee.fee(1, 20); // 5%

    Fee.fee private fee_transfer = Fee.fee(1, 100); // 1%

    Fee.fee private fee_referral = Fee.fee(33, 100); // 33%



    // �����������ƌ��ɞ����]Ӌ���ą��c��

    uint constant private minimal_stake = 10e18;



    // �D�Qeth < - >���Ƶ����أ����������Ӌ�㾫��

    uint constant private precision_factor = 1e18;



    // ���r����

    //  - ����Ñ�ُ�I1�����ƣ��r�����ӡ�price_offset��ֵ

    //  - ����Ñ��u��1�����ƣ��r�񌢽��͡�price_offset��ֵ

    // ���PԔ����Ϣ��Ո��醷�����fundsToTokens���͡�tokensToFunds��

    uint private price = 1e29; // 100 Gwei * precision_factor

    uint constant private price_offset = 1e28; // 10 Gwei * precision_factor



    // ���ƿ���

    uint private total_supply = 0;



    // ���Ƴ�����֮�g����Ŀ���������춴˅��������K���ܜʴ_��ӳ�Y���~

    // �����޸����ڿ��������l��׃���r�����挍�Ñ��Ĺ�Ϣ

    // ���PԔ����Ϣ��Ո��醷�����dividendsOf���K�ڴ��a��ʹ�á�funds_correction��

    uint private shared_profit = 0;



    // �Ñ�������ӳ��

    mapping(address => UserRecord) private user_data;



    // ==== �޸� ==== //



    modifier onlyValidTokenAmount(uint tokens) {

        require(tokens > 0, "���Ɣ�����횴����");

        require(tokens <= user_data[msg.sender].tokens, "��]����������");

        _;

    }



    // ==== ���� API ==== //



    // ---- �������� ---- //



    function () public payable {

        buy(msg.data.toAddr());

    }



    /*

    *  ���յ����Y��ُ�I����

    */

    function buy(address referrer) public payable {



        // �����M

        (uint fee_funds, uint taxed_funds) = fee_purchase.split(msg.value);

        require(fee_funds != 0, "�����Y��̫С");



        // �����Ñ������]��

        //  - �㲻�ܳɞ��Լ������]��

        //  - �Ñ����������]�ˌ���һ������

        UserRecord storage user = user_data[msg.sender];

        if (referrer != 0x0 && referrer != msg.sender && user.referrer == 0x0) {

            user.referrer = referrer;

        }



        // ��Ո���]����

        if (user.referrer != 0x0) {

            fee_funds = rewardReferrer(msg.sender, user.referrer, fee_funds, msg.value);

            require(fee_funds != 0, "�����Y��̫С");

        }



        // Ӌ����Ž��~��׃���r��

        (uint tokens, uint _price) = fundsToTokens(taxed_funds);

        require(tokens != 0, "�����Y��̫С");

        price = _price;



        // ���ɴ��ţ����ӹ�������

        mintTokens(msg.sender, tokens);

        shared_profit = shared_profit.add(fee_funds);



        emit Purchase(msg.sender, msg.value, tokens, price / precision_factor, now);

    }



    /*

    *  ���۽o�������Ĵ��ŁK�@���Y��

    */

    function sell(uint tokens) public onlyValidTokenAmount(tokens) {



        // Ӌ���Y���~��׃���r��

        (uint funds, uint _price) = tokensToFunds(tokens);

        require(funds != 0, "�]���������Ɓ����@����");

        price = _price;



        // ��Ո�M

        (uint fee_funds, uint taxed_funds) = fee_selling.split(funds);

        require(fee_funds != 0, "�]���������Ɓ����@����");



        // ������ƁK���Ñ��Ĺ�Ϣ�����Y��

        burnTokens(msg.sender, tokens);

        UserRecord storage user = user_data[msg.sender];

        user.gained_funds = user.gained_funds.add(taxed_funds);



        // ���ӹ�������

        shared_profit = shared_profit.add(fee_funds);



        emit Selling(msg.sender, tokens, funds, price / precision_factor, now);

    }



    /*

    *  ���o�����������Əİl�����D�Ƶ���һ���Ñ�

    * ERC20

    */

    function transfer(address to_addr, uint tokens) public onlyValidTokenAmount(tokens) returns (bool success) {



        require(to_addr != msg.sender, "�㲻�ܰѴ����D׌�o�Լ�");



        // ��Ո�M

        (uint fee_tokens, uint taxed_tokens) = fee_transfer.split(tokens);

        require(fee_tokens != 0, "�]���������Ɓ������@һ�c");



        // Ӌ���Y���~��׃���r��

        (uint funds, uint _price) = tokensToFunds(fee_tokens);

        require(funds != 0, "�]���������Ɓ������@һ�c");

        price = _price;



        // ȼ���ͱ��ɴ��ţ������M��

        burnTokens(msg.sender, tokens);

        mintTokens(to_addr, taxed_tokens);



        // ���ӹ�������

        shared_profit = shared_profit.add(funds);



        emit Transfer(msg.sender, to_addr, tokens);

        return true;

    }



    /*

    *  ��Ͷ�Y���й�Ϣ

    */

    function reinvest() public {



        // �@�����й�Ϣ

        uint funds = dividendsOf(msg.sender);

        require(funds > 0, "��]�й�Ϣ");



        // ����������֮����¼�����0

        UserRecord storage user = user_data[msg.sender];

        user.funds_correction = user.funds_correction.add(int(funds));



        // ��Ո�M

        (uint fee_funds, uint taxed_funds) = fee_purchase.split(funds);

        require(fee_funds != 0, "�t�������������@һ�c");



        // ��Ո���]����

        if (user.referrer != 0x0) {

            fee_funds = rewardReferrer(msg.sender, user.referrer, fee_funds, funds);

            require(fee_funds != 0, "�t�������������@һ�c");

        }



        // Ӌ����Ž��~��׃���r��

        (uint tokens, uint _price) = fundsToTokens(taxed_funds);

        require(tokens != 0, "�t�������������@һ�c");

        price = _price;



        // ���ɴ��ţ����ӹ�������

        mintTokens(msg.sender, tokens);

        shared_profit = shared_profit.add(fee_funds);



        emit Reinvestment(msg.sender, funds, tokens, price / precision_factor, now);

    }



    /*

    *  �������й�Ϣ

    */

    function withdraw() public {



        // �@�����й�Ϣ

        uint funds = dividendsOf(msg.sender);

        require(funds > 0, "��]�й�Ϣ");



        // ����������֮����¼�����0

        UserRecord storage user = user_data[msg.sender];

        user.funds_correction = user.funds_correction.add(int(funds));



        // �l���Y��

        msg.sender.transfer(funds);



        emit Withdrawal(msg.sender, funds, now);

    }



    /*

    *  �������д��źͷּt

    */

    function exit() public {



        // �u�����д���

        uint tokens = user_data[msg.sender].tokens;

        if (tokens > 0) {

            sell(tokens);

        }



        withdraw();

    }



    /*

    * ���棡�˷��������Ƴ�����֮�g�������Ђ����Y�𣬁K�Ҳ��ṩ�κ΃���

    * ������δ�����҂������Bϵ�y�е�������ͬ/��ַʹ��

    * �����������gӭ��

    */

    function donate() public payable {

        shared_profit = shared_profit.add(msg.value);

        emit Donation(msg.sender, msg.value, now);

    }



    

    function totalSupply() public view returns (uint) {

        return total_supply;

    }



   

    function balanceOf(address addr) public view returns (uint) {

        return user_data[addr].tokens;

    }



   

    function dividendsOf(address addr) public view returns (uint) {



        UserRecord memory user = user_data[addr];



       

        int d = int(user.gained_funds.add(user.ref_funds));

        require(d >= 0);



        if (total_supply > 0) {

            d = d.add(int(shared_profit.mul(user.tokens) / total_supply));

        }



        if (user.funds_correction > 0) {

            d = d.sub(user.funds_correction);

        }

        else if (user.funds_correction < 0) {

            d = d.add(-user.funds_correction);

        }



        require(d >= 0);



        return uint(d);

    }



   

    function expectedTokens(uint funds, bool apply_fee) public view returns (uint) {

        if (funds == 0) {

            return 0;

        }

        if (apply_fee) {

            (,uint _funds) = fee_purchase.split(funds);

            funds = _funds;

        }

        (uint tokens,) = fundsToTokens(funds);

        return tokens;

    }



    function expectedFunds(uint tokens, bool apply_fee) public view returns (uint) {

        // �����п����ƻ�]���N�۴���

        if (tokens == 0 || total_supply == 0) {

            return 0;

        }

        // �ȿ����_���������ƣ�ֻ�Ǐ�Ӌ�����ų�����Ҫ������

        else if (tokens > total_supply) {

            tokens = total_supply;

        }

        (uint funds,) = tokensToFunds(tokens);

        if (apply_fee) {

            (,uint _funds) = fee_selling.split(funds);

            funds = _funds;

        }

        return funds;

    }



    /*

    *  ��һ�����Ƶ�ُ�I�r��

    */

    function buyPrice() public view returns (uint) {

        return price / precision_factor;

    }



    /*

    *  �ۃr��һ������

    */

    function sellPrice() public view returns (uint) {

        return price.sub(price_offset) / precision_factor;

    }



    // ==== ˽�˵� API ==== //



    function mintTokens(address addr, uint tokens) internal {



        UserRecord storage user = user_data[addr];



        bool not_first_minting = total_supply > 0;



        if (not_first_minting) {

            shared_profit = shared_profit.mul(total_supply.add(tokens)) / total_supply;

        }



        total_supply = total_supply.add(tokens);

        user.tokens = user.tokens.add(tokens);



        if (not_first_minting) {

            user.funds_correction = user.funds_correction.add(int(tokens.mul(shared_profit) / total_supply));

        }

    }



    function burnTokens(address addr, uint tokens) internal {



        UserRecord storage user = user_data[addr];



        uint dividends_from_tokens = 0;

        if (total_supply == tokens) {

            dividends_from_tokens = shared_profit.mul(user.tokens) / total_supply;

        }



        shared_profit = shared_profit.mul(total_supply.sub(tokens)) / total_supply;



        total_supply = total_supply.sub(tokens);

        user.tokens = user.tokens.sub(tokens);



        if (total_supply > 0) {

            user.funds_correction = user.funds_correction.sub(int(tokens.mul(shared_profit) / total_supply));

        }

        else if (dividends_from_tokens != 0) {

            user.funds_correction = user.funds_correction.sub(int(dividends_from_tokens));

        }

    }



    function rewardReferrer(address addr, address referrer_addr, uint funds, uint full_funds) internal returns (uint funds_after_reward) {

        UserRecord storage referrer = user_data[referrer_addr];

        if (referrer.tokens >= minimal_stake) {

            (uint reward_funds, uint taxed_funds) = fee_referral.split(funds);

            referrer.ref_funds = referrer.ref_funds.add(reward_funds);

            emit ReferralReward(addr, referrer_addr, full_funds, reward_funds, now);

            return taxed_funds;

        }

        else {

            return funds;

        }

    }



    function fundsToTokens(uint funds) internal view returns (uint tokens, uint _price) {

        uint b = price.mul(2).sub(price_offset);

        uint D = b.mul(b).add(price_offset.mul(8).mul(funds).mul(precision_factor));

        uint n = D.sqrt().sub(b).mul(precision_factor) / price_offset.mul(2);

        uint anp1 = price.add(price_offset.mul(n) / precision_factor);

        return (n, anp1);

    }



    function tokensToFunds(uint tokens) internal view returns (uint funds, uint _price) {

        uint sell_price = price.sub(price_offset);

        uint an = sell_price.add(price_offset).sub(price_offset.mul(tokens) / precision_factor);

        uint sn = sell_price.add(an).mul(tokens) / precision_factor.mul(2);

        return (sn / precision_factor, an);

    }



    // ==== ��� ==== //



    event Purchase(address indexed addr, uint funds, uint tokens, uint price, uint time);

    event Selling(address indexed addr, uint tokens, uint funds, uint price, uint time);

    event Reinvestment(address indexed addr, uint funds, uint tokens, uint price, uint time);

    event Withdrawal(address indexed addr, uint funds, uint time);

    event Donation(address indexed addr, uint funds, uint time);

    event ReferralReward(address indexed referral_addr, address indexed referrer_addr, uint funds, uint reward_funds, uint time);



    //ERC20

    event Transfer(address indexed from_addr, address indexed to_addr, uint tokens);



}



library SafeMath {



    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) {

            return 0;

        }

        uint c = a * b;

        require(c / a == b, "mul failed");

        return c;

    }



    function sub(uint a, uint b) internal pure returns (uint) {

        require(b <= a, "sub failed");

        return a - b;

    }



    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;

        require(c >= a, "add failed");

        return c;

    }



    function sqrt(uint x) internal pure returns (uint y) {

        uint z = add(x, 1) / 2;

        y = x;

        while (z < y) {

            y = z;

            z = add(x / z, z) / 2;

        }

    }

}



library SafeMathInt {



    function sub(int a, int b) internal pure returns (int) {

        int c = a - b;

        require(c <= a, "sub failed");

        return c;

    }



    function add(int a, int b) internal pure returns (int) {

        int c = a + b;

        require(c >= a, "add failed");

        return c;

    }

}



library Fee {



    using SafeMath for uint;



    struct fee {

        uint num;

        uint den;

    }



    function split(fee memory f, uint value) internal pure returns (uint tax, uint taxed_value) {

        if (value == 0) {

            return (0, 0);

        }

        tax = value.mul(f.num) / f.den;

        taxed_value = value.sub(tax);

    }



    function get_tax(fee memory f, uint value) internal pure returns (uint tax) {

        if (value == 0) {

            return 0;

        }

        tax = value.mul(f.num) / f.den;

    }

}



library ToAddress {



    function toAddr(bytes source) internal pure returns (address addr) {

        assembly {

            addr := mload(add(source, 0x14))

        }

        return addr;

    }

}