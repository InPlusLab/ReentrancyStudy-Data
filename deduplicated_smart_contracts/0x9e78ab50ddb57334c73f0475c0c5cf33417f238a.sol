pragma solidity ^0.5.0;
import "./LinkedList.sol";

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value, bytes memory _data) public;
}


contract tfys{
    mapping (string => int[]) public resultados;
    
    function getResultado(string memory auction) public view returns(int[] memory resultado){
        resultado=resultados[auction];
    }
    
    function salvarResultados(string memory auction, int[] memory numeros) public{
        require(isOwner[msg.sender]);
        resultados[auction]=numeros;
    }
    
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    mapping(uint=>mapping (uint=> LinkedList)) public listasDeEscolhas;
    
    mapping (uint=>votacao) public listaDeVotacoes;
    uint public votacaoAtual=0;
    struct votacao{
        mapping(address=>bool) votou;
        mapping(address=>uint) votouOnde;
        mapping(uint=>uint) votosNaOpcao;
        uint blocoInicial;
        uint blocoFinal;
        string titulo;
        escolha[] escolhas;
        uint quantidadeEscolhas;
    }
    struct escolha{
        string titulo;
        LinkedList votos;
    }
    
    function abrirVotacao(uint blocoInicial, uint blocoFinal, string memory titulo) public{
        require(isOwner[msg.sender]);
        require(blocoInicial >= block.number);
        require(blocoFinal > blocoInicial);
        uint inteiroNulo;
        uint votacaoAtualBlocoFinal = listaDeVotacoes[votacaoAtual].blocoFinal;
        if (votacaoAtualBlocoFinal != inteiroNulo){
            require(votacaoAtualBlocoFinal<block.number);
        }
        
        listaDeVotacoes[votacaoAtual].blocoInicial=blocoInicial;
        listaDeVotacoes[votacaoAtual].blocoFinal=blocoFinal;
        listaDeVotacoes[votacaoAtual].titulo=titulo;
        listaDeVotacoes[votacaoAtual].quantidadeEscolhas=0;
        
        votacaoAtual++;
    }
    function editarVotacao(uint blocoInicial, uint blocoFinal, string memory titulo) public{
        require(isOwner[msg.sender]);
        require(blocoFinal > blocoInicial);
        listaDeVotacoes[votacaoAtual-1].blocoInicial=blocoInicial;
        listaDeVotacoes[votacaoAtual-1].blocoFinal=blocoFinal;
        listaDeVotacoes[votacaoAtual-1].titulo=titulo;
    }
    
    function adicionarUmaEscolha(string memory titulo) public{
        require(isOwner[msg.sender]);
        // require(listaDeVotacoes[votacaoAtual-1].blocoInicial>=block.number);
        uint inteiroNulo;
        if (listaDeVotacoes[votacaoAtual-1].quantidadeEscolhas==inteiroNulo){
            listaDeVotacoes[votacaoAtual-1].quantidadeEscolhas=0;
        }
        listaDeVotacoes[votacaoAtual-1].quantidadeEscolhas++;

        LinkedList votos;
        listaDeVotacoes[votacaoAtual-1].escolhas.push(escolha({titulo: titulo, votos:votos}));
    }
    
    function getResultadoDaEscolha(uint _escolha, uint _votacao) public view returns(string memory escolhaTitulo, uint votos){
        escolhaTitulo = listaDeVotacoes[_votacao].escolhas[_escolha].titulo;
        votos = listaDeVotacoes[_votacao].votosNaOpcao[_escolha];
    }
    
    function votar(uint _escolha) public {
        require(listaDeVotacoes[votacaoAtual-1].blocoInicial<=block.number);
        require(listaDeVotacoes[votacaoAtual-1].blocoFinal>=block.number);
        listaDeVotacoes[votacaoAtual-1].votosNaOpcao[_escolha]+=users[msg.sender].balance;
        listaDeVotacoes[votacaoAtual-1].votouOnde[msg.sender]=_escolha;
        listaDeVotacoes[votacaoAtual-1].votou[msg.sender]=true;
        LinkedList votos;
        if (listaDeVotacoes[votacaoAtual-1].escolhas[_escolha].votos==votos){
            listaDeVotacoes[votacaoAtual-1].escolhas[_escolha].votos = new LinkedList(msg.sender);
        }else{
            listaDeVotacoes[votacaoAtual-1].escolhas[_escolha].votos.add(msg.sender);
        }
        
    }
    
    function name() public pure returns (string memory _name){
        _name = "TradeForYou-S";
    }
    
    function symbol() public pure returns (bytes32 _symbol){
        _symbol = "TFYS";
    }
    
    function decimals() public pure returns (uint8 _decimals){
        _decimals = 0;
    }
    
    uint public janelaAtual=0;
    mapping(uint=>janela) public listaDeJanelas;
    struct janela{
        uint blocoInicial;
        uint blocoFinal;
        uint ethEmWei;
        uint totalTokensTravados;
        mapping (address=>uint) saldoTravado;
    }

    function abrirJanela(uint blocoInicial, uint blocoFinal, uint ethEmWei) public payable{
        
        require(msg.value==ethEmWei);
        require(isOwner[msg.sender]);
        require(blocoInicial >= block.number);
        require(blocoFinal > blocoInicial);
        uint inteiroNulo;
        uint janelaAtualBlocoFinal = listaDeJanelas[janelaAtual].blocoFinal;
        if (janelaAtualBlocoFinal != inteiroNulo){
            require(janelaAtualBlocoFinal<block.number);
        }
        janelaAtual++;
        listaDeJanelas[janelaAtual].blocoInicial=blocoInicial;
        listaDeJanelas[janelaAtual].blocoFinal=blocoFinal;
        listaDeJanelas[janelaAtual].ethEmWei=ethEmWei;
        
    }
    function editarJanela(uint blocoInicial, uint blocoFinal, uint ethEmWei) public payable{
        require(msg.value==ethEmWei);
        require(isOwner[msg.sender]);
        require(blocoFinal > blocoInicial);
        listaDeJanelas[janelaAtual].blocoInicial=blocoInicial;
        listaDeJanelas[janelaAtual].blocoFinal=blocoFinal;
        uint saldoASacar = listaDeJanelas[janelaAtual].ethEmWei;
        listaDeJanelas[janelaAtual].ethEmWei=ethEmWei;
        msg.sender.transfer(saldoASacar);
    }
    
    mapping (address => bool) public isOwner;
    uint private _quantidadeOwners = 0;
    LinkedList private _owners;
    
    mapping(address=>account) users;
    
    struct account{
        uint balance;
        uint headDividendos;
        uint[] dividendos;
    }
    
    function participarDaJanela() public{
        require(listaDeJanelas[janelaAtual].blocoInicial<=block.number);
        require(listaDeJanelas[janelaAtual].blocoFinal>=block.number);
        uint inteiroNulo;
        if(listaDeJanelas[janelaAtual].saldoTravado[msg.sender]==inteiroNulo){
            listaDeJanelas[janelaAtual].saldoTravado[msg.sender]=0;
        }
        require(users[msg.sender].balance>listaDeJanelas[janelaAtual].saldoTravado[msg.sender]);
        listaDeJanelas[janelaAtual].saldoTravado[msg.sender]=users[msg.sender].balance;
        listaDeJanelas[janelaAtual].totalTokensTravados+=users[msg.sender].balance;
        users[msg.sender].dividendos.push(janelaAtual);
    }
    function reclamarDividendos() public payable{
        require(users[msg.sender].dividendos.length>0);
        uint head = users[msg.sender].headDividendos;
        uint dividendos=0;
        for(uint i=head; i<users[msg.sender].dividendos.length; i++){
            janela storage janelaContagem = listaDeJanelas[users[msg.sender].dividendos[i]];
            if(janelaContagem.blocoFinal<block.number){
                users[msg.sender].headDividendos++;
                uint totalTrancado = janelaContagem.totalTokensTravados;
                uint meuTrancado = janelaContagem.saldoTravado[msg.sender];
                uint totalWei = janelaContagem.ethEmWei;
                dividendos += (totalWei/totalTrancado)*meuTrancado;
            }
        }
        msg.sender.transfer(dividendos);
    }

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    constructor() public{
        _totalSupply=10000000;
        users[msg.sender].balance=_totalSupply;
        isOwner[msg.sender]=true;
        _quantidadeOwners++;
        _owners = new LinkedList(msg.sender);
        
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address owner) public view returns (uint256) {
        return users[owner].balance;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function transfer(address to, uint256 value) public returns (bool) {
        bytes memory empty;
        transfer(to, value, empty);
        return true;
    }
    function transfer(address to, uint256 value, bytes memory data) public returns (bool) {
        _transfer(msg.sender, to, value, data);
        return true;
    }
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        bytes memory empty;
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(value));
        _transfer(from, to, value, empty);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    function _transfer(address from, address to, uint256 value, bytes memory data) internal {
        if(listaDeJanelas[janelaAtual].blocoFinal>=block.number){
            uint inteiroNulo;
            if(listaDeJanelas[janelaAtual].saldoTravado[from]==inteiroNulo){
                listaDeJanelas[janelaAtual].saldoTravado[from]=0;
            }
            uint saldoLivre = users[from].balance.sub(listaDeJanelas[janelaAtual].saldoTravado[from]);
            require(saldoLivre>=value);
        }
        if (listaDeVotacoes[votacaoAtual-1].votou[msg.sender]){
            uint valorDoVoto=listaDeVotacoes[votacaoAtual-1].votosNaOpcao[listaDeVotacoes[votacaoAtual-1].votouOnde[msg.sender]];
            listaDeVotacoes[votacaoAtual-1].votosNaOpcao[listaDeVotacoes[votacaoAtual-1].votouOnde[msg.sender]]= valorDoVoto.sub(value);
        } if (listaDeVotacoes[votacaoAtual-1].votou[to]){
            uint valorDoVoto = listaDeVotacoes[votacaoAtual-1].votosNaOpcao[listaDeVotacoes[votacaoAtual-1].votouOnde[to]];
            listaDeVotacoes[votacaoAtual-1].votosNaOpcao[listaDeVotacoes[votacaoAtual-1].votouOnde[to]] = valorDoVoto.add(value);
        }
        uint codeLength;
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(to)
        }
        require(to != address(0), "ERC20: transfer to the zero address");
        users[from].balance = users[from].balance.sub(value);
        users[to].balance = users[to].balance.add(value);
        emit Transfer(from, to, value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, data);
        }
        
    }
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    
    function getOwnersList() public view returns(address[] memory){
         return _owners.getList();
    }
    
    function addOwner(address _newOwner) public returns(bool){
        require(isOwner[msg.sender]);
        isOwner[_newOwner]=true;
        _quantidadeOwners++;
        _owners.add(_newOwner);
        return true;
    }
    function removeOwner(address _oldOwner) public returns(bool){
        require(isOwner[msg.sender]);
        require(_quantidadeOwners>1);
        isOwner[_oldOwner]=false;
        _quantidadeOwners--;
        _owners.remove(_oldOwner);
        return true;
    }
    
    
}