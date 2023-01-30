/**
 *Submitted for verification at Etherscan.io on 2020-03-11
*/

pragma solidity 0.6.0;
contract Offsetting {
string constant offsetting = 
"Offsetting Date (碳汇抵消时间): 07 Mar 2020 \n"
"Total Amount of Carbon Offsets (碳汇抵消总量):100 tonnes of VCU \n"
"Standard of Carbon Credit (使用碳汇标准): VCS \n"
"Project of Carbon Credit (使用的碳汇项目): Inner Mongolia Keyihe IFM (conversion of logged to protected forest) Project \n"
"VCUSerial Numbers (VCU 编号): 7331-385170050-385170149-VCU-013-MER-CN-14-1718-01012016-31122016-0 \n"
"Beneficial Owner (抵消受益人): MyCarbon App of ECO2 Consensus \n"
"Reason for Offsetting (抵消原因): \n"
"7,083 members of MyCarbon offset their daily carbon emissions between 14 November 2019 and 31 December 2019. ECO2 Consensus guarantees that it will retire offsets in IHS Markit based on member&#39;s individual carbon neutrality contributions. \n"
"2019 年 11 月 14 日至 2019 年 12 月 31 日，碳库 APP 中 7083 名成员抵消了他们的每日碳排放。ECO2 区块链气候共识保证，将在 IHS Markit 中帮助每一位会员完成碳抵消。推动个人参与碳中和！ \n"

"Period of Participationin MyCarbon App (参与日期): 2019-11-14 to 2019-12-31 \n"

"Number of Participants in MyCarbon App (参与人数):7,083 人 \n"

"List of Participants (members whose carbon offset exceeds 1 tonne CO2) in MyCarbon App \n"
"参与名单(中和数量超过 1 吨的会员名单): \n"
"| 排名 Rank | 会员编号 Member No. | 用户名 Username | 中和量(吨) Offset（tonne） | \n"
"| :---------: | :-------------------: | :---------------: | :--------------------------: | \n"
"| 1         | E727112             | 王明辉          | 6.0                        | \n"
"| 2         | E104605             | 彭俊强          | 5.5                        | \n"
"| 3         | E280317             | 左常鑫          | 5.1                        | \n"
"| 4         | E259636             | zzssxifen       | 4.2                        | \n"
"| 5         | E214281             | 候相波          | 4.0                        | \n"
"| 6         | E280897             | 郭双民          | 4.0                        | \n"
"| 7         | E331425             | 吴建钊          | 3.8                        | \n"
"| 8         | E800782             | 何世利          | 3.1                        | \n"
"| 9         | E185337             | 朱艳花          | 3.0                        | \n"
"| 10        | E143595             | 祝剑城          | 2.8                        | \n"
"| 11        | E768247             | 苏克明          | 2.0                        | \n"
"| 12        | E776223             | 杨继库          | 2.0                        | \n"
"| 13        | E344789             | 黄斌华          | 1.5                        | \n"
"| 14        | E887833             | 张晓凤          | 1.4                        | \n"
"| 15        | E862511             | 李成            | 1.4                        | \n"
"| 16        | E603572             | 陈一山          | 1.4                        | \n"
"| 17        | E347455             | 李小利          | 1.3                        | \n"
"| 18        | E660246             | 谷瑞蕊          | 1.2                        | \n"
"| 19        | E373605             | 刘雪丽          | 1.1                        | \n"
"| 20        | E412421             | 熊文宇          | 1.1                        | \n"
"| 21        | E914766             | 马学良          | 1.0                        | \n"
;

function getValue() public pure returns (string memory) {
    return offsetting;
}

}