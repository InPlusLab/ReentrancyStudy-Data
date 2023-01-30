/**

 *Submitted for verification at Etherscan.io on 2018-12-11

*/



pragma solidity ^0.4.25;



contract Single_contract_works {

    address public insurer;

    string public customer_email;

    string public practitioner_name;

    string public practitioner_id;

    string public company_name;

    string public owner_name;

    string public site_address;

    int public declared_contract_price_in_cents;

    string public estimated_start_date;

    string public Estimated_end_date;

    string public policy_number;

    string public description_of_contract;

    string public conditions;

    bool public on_risk;

  

    

    constructor(string initial_customer_email,

                string initial_practitioner_name,

                string initial_practitioner_id,

                string initial_company_name,

                string initial_owner_name,

                string initial_site_address,

                int initial_declared_contract_price_in_cents,

                string initial_estimated_start_date,

                string initial_Estimated_end_date,

                string initial_policy_number,

                string initial_description_of_contract,

                string initial_conditions,

                bool initial_on_risk

    ) public{

        insurer =  msg.sender;

        customer_email =  initial_customer_email;

        practitioner_name =  initial_practitioner_name;

        practitioner_id =  initial_practitioner_id;

        company_name = initial_company_name;

        owner_name = initial_owner_name;

        site_address =  initial_site_address;

        declared_contract_price_in_cents =  initial_declared_contract_price_in_cents;

        estimated_start_date = initial_estimated_start_date;

        Estimated_end_date = initial_Estimated_end_date;

        policy_number = initial_policy_number;

        description_of_contract =  initial_description_of_contract;

        conditions = initial_conditions;

        on_risk = initial_on_risk;

    }

    

    function off_risk(bool off_risk_flag) public restricted returns(bool success) {

        on_risk = off_risk_flag;

    return true;

    }

    

    modifier restricted() {

        require(msg.sender == insurer);

        _;

        

    }

    

}