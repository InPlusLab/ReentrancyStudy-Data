/**

 *Submitted for verification at Etherscan.io on 2019-06-08

*/



pragma solidity ^0.4.25;



library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}



    // CONFIDENCIALITY CONTRACT -- 

    // TERMO DE CONFIDENCIALIDADE



//Pelo presente o(s) participante(s) da reunião abaixo nominado que firma o presente termo, compromete-se a não utilizar as informações confidenciais, ou não, que tiver acesso, para gerar benefício próprio exclusivo e/ou unilateral, presente ou futuro, ou para o uso de terceiros; não realizar nenhuma gravação ou cópia de documentos, rascunhos ou manuscritos a que tiver acesso;

// Todo o conhecimento que for explanado sobre a plataforma de negócios da GOLDOFIR FINANCIAL SOLUTIONS e a BLOCKUM, são confidenciais, responsabilizando-me por todas as pessoas que vierem a ter acesso às informações, por meu intermédio, e obrigando-me, assim, a ressarcir a ocorrência de qualquer dano e / ou prejuízo oriundo de uma eventual quebra de sigilo das informações fornecidas, cabendo contra o infrator a multa de R$ 100.000.000,00.

//As Informações são de caráter confidencial e toda informação revelada através da apresentação da tecnologia, a respeito de, ou, associada com a avaliação, sob a forma escrita, verbal ou por quaisquer outros meios, é extremamente vedado.

// Mais, a informação confidencial não se limita, à informação relativa às operações, processos, planos ou intenções, informações sobre produção, instalações, equipamentos, segredos de negócio, segredo de fábrica, dados, habilidades especializadas, projetos, métodos e metodologia, fluxogramas, especializações, componentes, fórmulas, produtos, amostras, diagramas, desenhos de esquema industrial, patentes, oportunidades de mercado e questões relativas a negócios revelados da tecnologia supra mencionada, mas também a todo o conteúdo da reunião.

// Avaliação significará todas e quaisquer discussões, conversações ou negociações entre, ou com as partes, de alguma forma relacionada ou associada com a apresentação do modelo de negócio da GOLDOFIR e BLOCKUM, deve ser mantida sob a confidencialidade que o instrumento prevê.

//Pelo não cumprimento do presente Termo de Confidencialidade e Sigilo, fica o abaixo assinado ciente de todas as sanções judiciais que poderão advir.

// Tem um contrato inteligente com o Ethereum Blockchain.

//Considerando cada uma das partes envolvidas no mesmo: smart contract address blockchain ethereum e participant address ethereum.

// local ____________________– __, ___ de __________ de 20___.



    contract TermoConfidencialidade{

        

        string public constant name = "TERMO DE CONFIDENCIALIDADE GOLDOFIR FINANCIAL SOLUTIONS ";

        string public constant symbol = "TERMG";

        uint8 public constant decimals = 8;

        uint public _totalSupply = 500;

        // Zeros after the point

        uint256 constant public DECIMAL_ZEROS = 100000000;

        uint256 public RATE = 500;

        bool public isMinting = true;

        string public constant generatedBy  = " TERMO DE CONFIDENCIALIDADE GOLDOFIR FINANCIAL SOLUTIONS ";

        

        using SafeMath for uint256;

        address public owner;

        

         // Functions with this modifier can only be executed by the owner

         modifier onlyOwner() {

            if (msg.sender != owner) {

                throw;

            }

             _;

         }

     

        // Balances for each account

        mapping(address => uint256) balances;

        // Owner of account approves the transfer of an amount to another account

        mapping(address => mapping(address=>uint256)) allowed;



        // Its a payable function works as a token factory.

        function () payable{

            createTokens();

        }



        // Constructor

        constructor() public {

            owner = 0xE7c1CbC85874e305EF1b9348228a20F0856cEB56; 

            balances[owner] = _totalSupply;

        }



        //allows owner to burn tokens that are not sold in a crowdsale

        function burnTokens(uint256 _value) onlyOwner {



             require(balances[msg.sender] >= _value && _value > 0 );

             _totalSupply = _totalSupply.sub(_value);

             balances[msg.sender] = balances[msg.sender].sub(_value);

             

        }







        // This function creates Tokens  

         function createTokens() payable {

            if(isMinting == true){

                require(msg.value > 0);

                uint256  tokens = msg.value.mul(RATE);

                balances[msg.sender] = balances[msg.sender].add(tokens);

                _totalSupply = _totalSupply.add(tokens);

                owner.transfer(msg.value);

            }

            else{

                throw;

            }

        }





        function endCrowdsale() onlyOwner {

            isMinting = false;

        }



        function changeCrowdsaleRate(uint256 _value) onlyOwner {

            RATE = _value;

        }





        

        function totalSupply() constant returns(uint256){

            return _totalSupply;

        }

        // What is the balance of a particular account?

        function balanceOf(address _owner) constant returns(uint256){

            return balances[_owner];

        }



         // Transfer the balance from owner's account to another account   

        function transfer(address _to, uint256 _value)  returns(bool) {

            require(balances[msg.sender] >= _value && _value > 0 );

            balances[msg.sender] = balances[msg.sender].sub(_value);

            balances[_to] = balances[_to].add(_value);

            Transfer(msg.sender, _to, _value);

            return true;

        }

        

    // Send _value amount of tokens from address _from to address _to

    // The transferFrom method is used for a withdraw workflow, allowing contracts to send

    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge

    // fees in sub-currencies; the command should fail unless the _from account has

    // deliberately authorized the sender of the message via some mechanism; we propose

    // these standardized APIs for approval:

    function transferFrom(address _from, address _to, uint256 _value)  returns(bool) {

        require(allowed[_from][msg.sender] >= _value && balances[_from] >= _value && _value > 0);

        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);

        return true;

    }

    

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.

    // If this function is called again it overwrites the current allowance with _value.

    function approve(address _spender, uint256 _value) returns(bool){

        allowed[msg.sender][_spender] = _value; 

        Approval(msg.sender, _spender, _value);

        return true;

    }

    

    // Returns the amount which _spender is still allowed to withdraw from _owner

    function allowance(address _owner, address _spender) constant returns(uint256){

        return allowed[_owner][_spender];

    }

    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}