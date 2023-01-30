/**

 *Submitted for verification at Etherscan.io on 2018-09-28

*/



contract BlockmaticsGraduationCertificate_092818 {

    address public owner = msg.sender;

    string public certificate;

    bool public certIssued = false;



    function publishGraduatingClass (string cert) public {

        assert (msg.sender == owner && !certIssued);



        certIssued = true;

        certificate = cert;

    }

}