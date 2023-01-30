/**
 *Submitted for verification at Etherscan.io on 2020-06-11
*/

pragma solidity ^0.6.4;


contract CarrefourFactory {
    struct Lotto {
        bytes codice_tracciabilita;
        bytes id_allevatore;
        bytes10 data_nascita_pulcino;
        bytes10 data_trasferimento_allevamento;
        bytes id_owner_informazione;
    }

    struct Articolo {
        bytes lotto; // Here a synonym of "codice_tracciabilita"
        bytes codice_articolo;
        bytes10 data_produzione;
        bytes10 data_scadenza;
        bytes id_stabilimento;
    }

    address private owner;

    mapping(bytes => Lotto) private lotti;
    mapping(bytes => bool) private lotto_exist;
    mapping(bytes => Articolo) private articoli;
    mapping(bytes => bool) private articolo_exist;

    event lottoAdded(bytes codice_tracciabilita);
    event articoloAdded(
        bytes lotto,
        bytes codice_articolo,
        bytes10 data_scadenza
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlymanager() {
        require(msg.sender == owner, "Member not allowed");
        _;
    }

    function createLotto(
        bytes memory codice_tracciabilita,
        bytes memory id_allevatore,
        bytes10 data_nascita_pulcino,
        bytes10 data_trasferimento_allevamento,
        bytes memory id_owner_informazione
    ) public onlymanager {
        require(
            lotto_exist[codice_tracciabilita] == false,
            "Il lotto ¨¨ gi¨¤ presente"
        );
        require(
            codice_tracciabilita.length > 0,
            "Codice tracciabilit¨¤ non valido"
        );
        require(id_allevatore.length > 0, "Codice allevatore non valido");
        require(data_nascita_pulcino.length > 0, "Data di nascita non valida");
        require(
            data_trasferimento_allevamento.length > 0,
            "Data trasferimento allevamento non valida"
        );

        Lotto memory lotto_tmp;
        lotto_tmp.codice_tracciabilita = codice_tracciabilita;
        lotto_tmp.id_allevatore = id_allevatore;
        lotto_tmp.data_nascita_pulcino = data_nascita_pulcino;
        lotto_tmp
            .data_trasferimento_allevamento = data_trasferimento_allevamento;
        lotto_tmp.id_owner_informazione = id_owner_informazione;

        lotti[codice_tracciabilita] = lotto_tmp;
        lotto_exist[codice_tracciabilita] = true;

        emit lottoAdded(codice_tracciabilita);
    }

    function get_dati_lotto(bytes memory codice_tracciabilita)
        public
        view
        returns (
            bytes memory,
            bytes10,
            bytes10,
            bytes memory
        )
    {
        require(
            codice_tracciabilita.length > 0,
            "Il codice tracciabilt¨¤ ¨¨ obbligatorio"
        );
        require(
            lotto_exist[codice_tracciabilita] == true,
            "Il lotto non ¨¨ stato trovato"
        );

        return (
            lotti[codice_tracciabilita].id_allevatore,
            lotti[codice_tracciabilita].data_nascita_pulcino,
            lotti[codice_tracciabilita].data_trasferimento_allevamento,
            lotti[codice_tracciabilita].id_owner_informazione
        );
    }

    function createArticolo(
        bytes memory _lotto, // Here a synonym of "codice_tracciabilita"
        bytes memory _codice_articolo,
        bytes10 _data_produzione,
        bytes10 _data_scadenza,
        bytes memory _id_stabilimento
    ) public onlymanager {
        require(_lotto.length > 0, "Codice tracciabilit¨¤ vuoto");
        require(_codice_articolo.length > 0, "Codice Art. vuoto");
        require(
            articolo_exist[_codice_articolo] == false,
            "L'articolo ¨¨ gi¨¤ presente"
        );
        require(_data_produzione.length > 0, "Data produzione vuota");
        require(_data_scadenza.length > 0, "Data scadenza vuota");
        require(_id_stabilimento.length > 0, "ID stabilimento vuoto");

        Articolo memory articolo_tmp;
        articolo_tmp.lotto = _lotto;
        articolo_tmp.codice_articolo = _codice_articolo;
        articolo_tmp.data_produzione = _data_produzione;
        articolo_tmp.data_scadenza = _data_scadenza;
        articolo_tmp.id_stabilimento = _id_stabilimento;

        articoli[_codice_articolo] = articolo_tmp;
        articolo_exist[_codice_articolo] = true;

        emit articoloAdded(_lotto, _codice_articolo, _data_scadenza);
    }

    function get_dati_articolo(
        bytes memory codice_tracciabilita,
        bytes memory codice_articolo,
        bytes10 data_scadenza
    )
        public
        view
        returns (
            bytes10,
            bytes memory,
            bytes memory,
            bytes10,
            bytes10
        )
    {
        require(codice_tracciabilita.length > 0, "Lotto non trovato");
        require(codice_articolo.length > 0, "Codice articolo non trovato");
        require(data_scadenza.length > 0, "Data Scadenza non trovata");
        require(
            articolo_exist[codice_articolo] == true,
            "Articolo non trovato"
        );
        bytes memory cod_lotto = articoli[codice_articolo].lotto;
        Lotto memory lotto_tmp = lotti[cod_lotto];

        return (
            articoli[codice_articolo].data_produzione, // Here a synonym of "codice_tracciabilita"
            articoli[codice_articolo].id_stabilimento,
            lotto_tmp.id_allevatore,
            lotto_tmp.data_nascita_pulcino,
            lotto_tmp.data_trasferimento_allevamento
        );
    }
}