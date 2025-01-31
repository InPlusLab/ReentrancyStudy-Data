# ReentrancyStudy-Data

ReentrancyStudy-Data is a large-scale dataset of reentrancy vulnerability in smart contracts, which is built from 230,548 open-source smart contracts from Etherscan. 

For more details, please refer to our paper "Turn the Rudder: A Beacon of Reentrancy Detection for Smart Contracts on Ethereum" [ICSE'23 paper](https://github.com/InPlusLab/ReentrancyStudy-Data/tree/main/paper/Turn_the_Rudder_A_Beacon_of_Reentrancy_Detection_for_Smart_Contracts_on_Ethereum.pdf).

## Data Annotation

### deduplicated_smart_contracts
The deduplicated smart contracts.

### reentrant_contracts
The reentrant contracts (code) with labels.

### tools_output
The reported reentrancy by analysis tools (oyente, mythril, securify1, securify2, smartian, sailfish).

### reentrancy_information.csv
The reentrant labels of deduplicated smart contracts.

In 'true positive' column:
```
1 means the contract is manually verified to true reentrant contract.
0 means the contract is manually verified to false reentrant contract.
N/A means the contract does not be successfully analyzed by any tool.
```

In the column of tools (oyente, mythril, securify1, securify2, smartian):
```
1 means the contract is reported to reentrant contract by the tool.
0 means the contract is not reported to reentrant contract by the tool.
N/A means the contract does not be successfully analyzed by the tool.
```

### contract_information_etherscan.csv
The information of contracts from etherscan.

### hash_to_address.json
The mapping from the hash value (for deduplication) to the address.

### load_reentrancy_information.py
The python script to load reentrancy_information.csv.

## Citing

Zibin Zheng, Neng Zhang, Jianzhong Su, Zhijie Zhong, Mingxi Ye, and Jiachi Chen, “Turn the rudder: A beacon of reentrancy detection for smart contracts on ethereum,” in Proceedings of the 45th IEEE/ACM International Conference on Software Engineering, ser. ICSE ’23, 2023

## Contact 
If you have any questions about our dataset, please contact sujzh3@mail2.sysu.edu.cn.

<!-- ```
@inproceedings{zheng2023turn,
author = {Zheng, Zibin and Zhang, Neng and Su, Jianzhong and Zhong, Zhijie and Ye, Mingxi and Chen, Jiachi},
title = {Turn the Rudder: A Beacon of Reentrancy Detection for Smart Contracts on Ethereum},
year = {2023},
booktitle = {Proceedings of the 45th IEEE/ACM International Conference on Software Engineering},
series = {ICSE '23}
}
``` -->