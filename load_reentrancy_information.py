import os

reentrancy_information = dict()
reentrant_contracts = set()
tool_re = dict()
tool_list = ['oyente', 'mythril', 'securify1', 'securify2', 'smartian', 'sailfish']

with open("reentrancy_information.csv", "r") as f:
    lines = f.readlines()
    # 'address', 'true_positive', 'oyente', 'mythril', 'securify1', 'securify2', 'smartian', 'sailfish'
    key_list = lines[0].split("\n")[0].split(",")
    for key in key_list[1:]:
        tool_re[key] = set()
    for line in lines[1:]:
        line = line.split("\n")[0].split(",")
        reentrancy_information[line[0]] = dict()
        for index, key in enumerate(key_list[1:]):
            reentrancy_information[line[0]][key] = line[index+1]
            if line[index+1] == "1":
                tool_re[key].add(line[0])
        if reentrancy_information[line[0]]["true_positive"] == "1":
            reentrant_contracts.add(line[0])

print("total contracts", len(lines[1:]))

print("tool,", "reported num,", "true positive")
for tool in tool_list:
    print(tool, ",", len(tool_re[tool]), ",", len(tool_re[tool].intersection(reentrant_contracts)))