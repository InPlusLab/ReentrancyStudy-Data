/**

 *Submitted for verification at Etherscan.io on 2019-03-07

*/



pragma solidity ^0.5.5;

pragma experimental ABIEncoderV2;



//Where r you Vitalik, we don't have FLOAT :( and money to develop plz~ :D











///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Start contract of base component

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract AI_on_BlockChain__BaseComponent {

    



    struct NeuralNetWork_Struct_Object

    {

        uint Im_Number_Of_Layer ;

        uint[] Im_Nodes_In_EachLayer;

        int[][] Im_Bias_Of_Nodes_In_EachLayer;

        int[][][] Im_Weights_Of_Nodes_In_EachLayer;

    }    

    

    function Im_StanderRandomNumber(uint Im_Cute_Input_Number) 

    public view  

    returns (int Im_Cute_Random_Number)

    {

        //Worship Lu

        require(msg.sender != block.coinbase);

        require(msg.sender == tx.origin);

        

        int Im_Random_Number = int(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, block.difficulty,  Im_Cute_Input_Number))) % 2;

        

        return Im_Random_Number;

    }

        

    

    function Im_Function_Initialize_NeuralNetwork(uint TotalNumber_Of_Layer, uint[] memory WeR_Nodes_In_EachLayer) 

    public view 

    returns (NeuralNetWork_Struct_Object memory Im_NeuralNetWork_Object)

    {

        

        int[][] memory WeR_Bias_Of_Nodes_In_EachLayer;

        int[][][] memory WeR_Weights_Of_Nodes_In_EachLayer;

        

        for (uint Im_Number_Of_Layer = 1 ; Im_Number_Of_Layer <= TotalNumber_Of_Layer ; Im_Number_Of_Layer++) 

        {

            for(uint Im_Number_Of_Node = 0 ; Im_Number_Of_Node <= WeR_Nodes_In_EachLayer[Im_Number_Of_Layer]; Im_Number_Of_Node++) 

            {

                WeR_Bias_Of_Nodes_In_EachLayer[Im_Number_Of_Layer][Im_Number_Of_Node] = Im_StanderRandomNumber(now)-1;

                

                for(uint Im_Weights_For_Node ;  Im_Weights_For_Node <= WeR_Nodes_In_EachLayer[Im_Number_Of_Layer-1] ; Im_Weights_For_Node++){

                    

                    WeR_Weights_Of_Nodes_In_EachLayer[Im_Number_Of_Layer][Im_Number_Of_Node][Im_Weights_For_Node]= Im_StanderRandomNumber(now);

                }

            }

        }

        

        NeuralNetWork_Struct_Object memory Im_NeuralNetWork_Struct_Object = NeuralNetWork_Struct_Object

        (

            {Im_Number_Of_Layer : TotalNumber_Of_Layer,

            Im_Nodes_In_EachLayer : WeR_Nodes_In_EachLayer,

            Im_Bias_Of_Nodes_In_EachLayer : WeR_Bias_Of_Nodes_In_EachLayer,

            Im_Weights_Of_Nodes_In_EachLayer : WeR_Weights_Of_Nodes_In_EachLayer}

        );

        

        return Im_NeuralNetWork_Struct_Object;

    }

    

    

    

    

    function Im_Sum_For_NodeInput(int[] memory Im_InputData, int[] memory Im_EachWeights, int Im_Bias) 

    public pure 

    returns (int TransferValue_For_ActivationFunction) 

    {

        int Sum_Value;

        for(uint Im_Calculous_Pair = 0; Im_Calculous_Pair < Im_InputData.length; Im_Calculous_Pair++)

        {

            Sum_Value = Sum_Value + Im_InputData[Im_Calculous_Pair] * Im_EachWeights[Im_Calculous_Pair];

        }

        

        Sum_Value = Sum_Value + Im_Bias;

        

        return Sum_Value;

    }

    

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//End contract of base component

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////











///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Start contract of computational function

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract AI_on_BlockChain__ComputationalFunction is AI_on_BlockChain__BaseComponent{

    

    function Im_Activation_Function__Sigmoid(int Im_InputValue) 

    public pure 

    returns (int Im_OutputValue) 

    {

        //int Im_interger = 12345e-2;

        int Im_Exponencial_Number;

        int Im_Sigmoid_Output;

        

//searching operand Im_Exponencial_Number = int(2.71828) ** ( - Im_InputValue);

        

        Im_Sigmoid_Output = 1 / ( 1 + Im_Exponencial_Number );

         

        return  Im_Sigmoid_Output;

        

    }

    

    

    

    function Im_Activation_Function__Relu(int Im_Input) 

    public pure 

    returns (int Im_Output) 

    {

        

        int Im_Relu_Output;

        

        if(Im_Input <= 0)

        {

            Im_Relu_Output = 0;  

        } 

        

        

        else if(Im_Input > 0)

        {

            Im_Relu_Output = Im_Input;

        }

        

        return Im_Relu_Output;

        

    }





    function Im_sigmoid_function_Derivative (int Im_InputValue)

    public pure

    returns(int Im_OutputValue) 

    {

        int Im_OutputValue_Computation;

        

        Im_OutputValue_Computation = Im_InputValue * (1 - Im_InputValue);

        

        return Im_OutputValue_Computation;

    }





//    function Im_relu_function_Derivative () returns() {    }

    

    

    function Im_Loss_function__L2 (int[] memory Im_Predict_ResultSets, int[] memory Im_Actual_ResultSets) 

    public pure

    returns (int Im_Result_Error) 

    {

        int Im_L2_Error;

        

        for (uint Im_Number_Of_ComputationalPair ; Im_Number_Of_ComputationalPair < Im_Predict_ResultSets.length; Im_Number_Of_ComputationalPair++)

        {

            int Im_Residual;

            Im_Residual = Im_Actual_ResultSets[Im_Number_Of_ComputationalPair] - Im_Predict_ResultSets[Im_Number_Of_ComputationalPair];

            Im_L2_Error = Im_L2_Error + (Im_Residual * Im_Residual);

        }

        

        return Im_L2_Error;

    }



    function Im_Loss_function__MSE (int[] memory Im_Predict_ResultSets, int[] memory Im_Actual_ResultSets) 

    public pure 

    returns (int Im_Result_Error) 

    {

        int Im_MSE_Error;

        

        for (uint Im_Number_Of_ComputationalPair ; Im_Number_Of_ComputationalPair < Im_Predict_ResultSets.length; Im_Number_Of_ComputationalPair++)

        {

            int Im_Residual;

            Im_Residual = Im_Actual_ResultSets[Im_Number_Of_ComputationalPair] - Im_Predict_ResultSets[Im_Number_Of_ComputationalPair];

            Im_MSE_Error = Im_MSE_Error + (Im_Residual * Im_Residual);

        }        

        Im_MSE_Error = Im_MSE_Error / int(Im_Predict_ResultSets.length);

        

        return Im_MSE_Error;

    }

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Start contract of computational function

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////











///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Start contract of operational function

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract AI_on_BlockChain__OperationalFunction is AI_on_BlockChain__ComputationalFunction {





    function Im_Forward_Propagation__Prediction(int[] memory Im_Input_Feature , NeuralNetWork_Struct_Object memory Im_NeuralNetWork_Object)

    public pure

    returns(int Im_OutPut_PredictionResult)

    {



        int[] memory Im_Current_FlowingTensor;

        int[] memory Im_New_FlowingTensor;

        int Im_OutPutResult;

        Im_Current_FlowingTensor = Im_Input_Feature;

        

        for(uint Im_Propagation_Layer = 1; Im_Propagation_Layer <= Im_NeuralNetWork_Object.Im_Number_Of_Layer; Im_Propagation_Layer++)

        {

            for(uint Im_Current_Neural = 0; Im_Current_Neural <= Im_NeuralNetWork_Object.Im_Nodes_In_EachLayer[Im_Propagation_Layer]; Im_Current_Neural++)

            {

                int Im_Activation_Function_Input_Sum;

                Im_Activation_Function_Input_Sum = Im_Sum_For_NodeInput

                (

                    {Im_InputData : Im_Current_FlowingTensor, 

                    Im_EachWeights : Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer[Im_Propagation_Layer][Im_Current_Neural], 

                    Im_Bias : Im_NeuralNetWork_Object.Im_Bias_Of_Nodes_In_EachLayer[Im_Propagation_Layer][Im_Current_Neural]}

                );

                

                Im_New_FlowingTensor[Im_Current_Neural] = Im_Activation_Function__Sigmoid(Im_Activation_Function_Input_Sum);

            }

            

            Im_Current_FlowingTensor = Im_New_FlowingTensor;



        }

        

        Im_OutPutResult = Im_Current_FlowingTensor[0];

        

        return Im_OutPutResult;

    }    

    



// throw out the input summation of each node and partial derivative of input summation respect to each weight



    function Im_Backward_Propagation__ForwardPass(int[] memory Im_Current_InputData, NeuralNetWork_Struct_Object memory Im_NeuralNetWork_Object)

    public pure

    returns (int[][] memory InputSum_Of_Nodes, int[][][] memory Im_PartialDerivative__Of_InputSum_RespectTo_Weights)

    {

        int[][] memory Im_InputSum_Of_Nodes;

        int[][][] memory Im_PartialDerivative_Of_InputSum_RespectTo_Weights;

        

        int[] memory Im_Current_FlowingTensor;

        int[] memory Im_New_FlowingTensor;        

        Im_Current_FlowingTensor = Im_Current_InputData;

        

        for(uint Im_Propagation_Layer = 1; Im_Propagation_Layer <= Im_NeuralNetWork_Object.Im_Number_Of_Layer; Im_Propagation_Layer++)

        {

            for(uint Im_Current_Neural = 0; Im_Current_Neural <= Im_NeuralNetWork_Object.Im_Nodes_In_EachLayer[Im_Propagation_Layer]; Im_Current_Neural++)

            {

                int Im_Activation_Function_Input_Sum;

                Im_Activation_Function_Input_Sum = Im_Sum_For_NodeInput

                (

                    Im_Current_FlowingTensor, 

                    Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer[Im_Propagation_Layer][Im_Current_Neural], 

                    Im_NeuralNetWork_Object.Im_Bias_Of_Nodes_In_EachLayer[Im_Propagation_Layer][Im_Current_Neural]

                );

                

                Im_New_FlowingTensor[Im_Current_Neural] = Im_Activation_Function__Sigmoid(Im_Activation_Function_Input_Sum);

                

//                

                Im_InputSum_Of_Nodes[Im_Propagation_Layer][Im_Current_Neural] = Im_Activation_Function_Input_Sum;

                Im_PartialDerivative_Of_InputSum_RespectTo_Weights[Im_Propagation_Layer][Im_Current_Neural] = Im_Current_FlowingTensor;

//                

            }

            

            Im_Current_FlowingTensor = Im_New_FlowingTensor;



        }

        

        return (Im_InputSum_Of_Nodes, Im_PartialDerivative_Of_InputSum_RespectTo_Weights); 

        

    }

    



    function Im_Backward_Propagation__BackwardPass(int[] memory Im_PartialDerivative__Current_Error, int[][] memory Im_InputSum_Of_Nodes, NeuralNetWork_Struct_Object memory Im_NeuralNetWork_Object)

    public pure

    returns (int[][] memory PartialDerivative__of_Error_RespectTo_InputSum_Of_Nodes)

    {

        

        int[][] memory Im_PartialDerivative__of_Error_RespectTo_InputSum_Of_Nodes;

        int[] memory Im_PartialDerivative__TensorSet___In_Previous_Layer;

        

        Im_PartialDerivative__TensorSet___In_Previous_Layer = Im_PartialDerivative__Current_Error;

        

        

        for(uint Im_Propagation_Layer = 1; Im_Propagation_Layer <= Im_NeuralNetWork_Object.Im_Number_Of_Layer; Im_Propagation_Layer++)

        {



            int[] memory Im_PartialDerivative__InputSum_Of_Nodes___In_Current_Layer;            

            

            for(uint Im_Current_Neural = 0; Im_Current_Neural <= Im_NeuralNetWork_Object.Im_Nodes_In_EachLayer[Im_Propagation_Layer]; Im_Current_Neural++)

            {

                int Im_Sum_Of__Weight_Time_PartialDerivativePreviousLayerInputSum;

                int Im_PartialDerivative__Of_Loss_Respect_to_InputSum__in_Current_Neural;

                

                for(uint Im_Number_Of_CurrentWeight; Im_Number_Of_CurrentWeight < Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer[Im_Propagation_Layer][Im_Current_Neural].length; Im_Number_Of_CurrentWeight++)

                {

                    int Im_CurrentWeight;

                    int Im_PartialDerivative_PreviousLayerInputSum;

                    

                    Im_CurrentWeight = Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer[Im_Propagation_Layer][Im_Current_Neural][Im_Number_Of_CurrentWeight];

                    Im_PartialDerivative_PreviousLayerInputSum = Im_PartialDerivative__TensorSet___In_Previous_Layer[Im_Number_Of_CurrentWeight];

                    

                    Im_Sum_Of__Weight_Time_PartialDerivativePreviousLayerInputSum = Im_Sum_Of__Weight_Time_PartialDerivativePreviousLayerInputSum + (Im_CurrentWeight * Im_PartialDerivative_PreviousLayerInputSum);

                }

                

                Im_PartialDerivative__Of_Loss_Respect_to_InputSum__in_Current_Neural = Im_sigmoid_function_Derivative(Im_InputSum_Of_Nodes[Im_Propagation_Layer][Im_Current_Neural]) * Im_Sum_Of__Weight_Time_PartialDerivativePreviousLayerInputSum;

                Im_PartialDerivative__InputSum_Of_Nodes___In_Current_Layer[Im_Current_Neural] = Im_PartialDerivative__Of_Loss_Respect_to_InputSum__in_Current_Neural;

            }

            

            Im_PartialDerivative__of_Error_RespectTo_InputSum_Of_Nodes[Im_NeuralNetWork_Object.Im_Number_Of_Layer - Im_Propagation_Layer] = Im_PartialDerivative__InputSum_Of_Nodes___In_Current_Layer;

            Im_PartialDerivative__TensorSet___In_Previous_Layer = Im_PartialDerivative__InputSum_Of_Nodes___In_Current_Layer;

            

        }

        

        return Im_PartialDerivative__of_Error_RespectTo_InputSum_Of_Nodes;

        

    }

    





    function Im_ComputationFunction_PartialDerivative__Of_LossFunction_RespectTo_Weights

    (

        int[][] memory Im_Input_Feature, 

        int[] memory Im_Input_Label, 

        NeuralNetWork_Struct_Object memory Im_NeuralNetWork_Object        

    )

    public pure

    returns

    (int[][][] memory PartialDerivative__Of_LossFunction_RespectTo_Weights_TotalAccumulation)

    {

    //    compute partial derivative of loss respect to weight

        int[][][] memory Im_PartialDerivative__Of_LossFunction_RespectTo_Weights_TotalAccumulation;          

        

    //    compute the total loss and the total partial derivative of loss respect to each weight of the current weight from all the prediction value and actual value(label      

        for(uint Im_Number_Of_Data; Im_Number_Of_Data < Im_Input_Label.length ; Im_Number_Of_Data)

        {

            

            int[][][] memory Im_PartialDerivative__Of_LossFunction_RespectTo_Weights;

            //    store result of forward pass in backward propogation

            int[][] memory Im_InputSum_Of_EachNodes;

            int[][][] memory Im_PartialDerivative__Of_InputSum_RespectTo_Weights;            

            //    store result of backward pass in backward propogation

            int[][] memory Im_PartialDerivative__of_Error_RespectTo_InputSum_Of_Nodes;    



            

            int[] memory Im_OutPut_PredictionResult_Of_This_Data;

            int[] memory Im_OutPut_ActualLabelResult_Of_This_Data;

            int[] memory Im_Error_Of_This_Data;

            

        //    forward propogation compute all the prediction value for total input feature

            Im_OutPut_PredictionResult_Of_This_Data[0] = Im_Forward_Propagation__Prediction

            (

                {Im_Input_Feature : Im_Input_Feature[Im_Number_Of_Data], 

                Im_NeuralNetWork_Object : Im_NeuralNetWork_Object}

            );

            

            Im_OutPut_ActualLabelResult_Of_This_Data[0] = Im_Input_Label[Im_Number_Of_Data];

            Im_Error_Of_This_Data[0] = Im_Loss_function__L2({Im_Predict_ResultSets : Im_OutPut_PredictionResult_Of_This_Data, Im_Actual_ResultSets : Im_OutPut_ActualLabelResult_Of_This_Data});                

            

        //  compute all the partial derivative of input sum respect to each weight

        

            (Im_InputSum_Of_EachNodes, Im_PartialDerivative__Of_InputSum_RespectTo_Weights) = Im_Backward_Propagation__ForwardPass

            (

                {Im_Current_InputData : Im_Input_Feature[Im_Number_Of_Data], 

                Im_NeuralNetWork_Object : Im_NeuralNetWork_Object}

            );

            

            

        //  compute all the partial derivative of loss respect to each input sum

            Im_PartialDerivative__of_Error_RespectTo_InputSum_Of_Nodes = Im_Backward_Propagation__BackwardPass

            (

                {Im_PartialDerivative__Current_Error : Im_Error_Of_This_Data, 

                Im_InputSum_Of_Nodes : Im_InputSum_Of_EachNodes, 

                Im_NeuralNetWork_Object : Im_NeuralNetWork_Object}   

            );                

            

            

            for(uint Im_Number_Of_layer = 1; Im_Number_Of_layer < Im_NeuralNetWork_Object.Im_Number_Of_Layer; Im_Number_Of_layer++ )

            {                

                for(uint Im_Number_Of_Neural; Im_Number_Of_Neural < Im_NeuralNetWork_Object.Im_Nodes_In_EachLayer[Im_Number_Of_layer]; Im_Number_Of_Neural++ )

                {                

                    for(uint Im_Number_Of_Weight; Im_Number_Of_Weight < Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer[Im_Number_Of_layer][Im_Number_Of_Neural].length; Im_Number_Of_Weight++ )

                    {

                        Im_PartialDerivative__Of_LossFunction_RespectTo_Weights[Im_Number_Of_layer][Im_Number_Of_Neural][Im_Number_Of_Weight] = Im_PartialDerivative__Of_InputSum_RespectTo_Weights[Im_Number_Of_layer][Im_Number_Of_Neural][Im_Number_Of_Weight] * Im_PartialDerivative__of_Error_RespectTo_InputSum_Of_Nodes[Im_Number_Of_layer][Im_Number_Of_Neural];

                        Im_PartialDerivative__Of_LossFunction_RespectTo_Weights_TotalAccumulation[Im_Number_Of_layer][Im_Number_Of_Neural][Im_Number_Of_Weight] = Im_PartialDerivative__Of_LossFunction_RespectTo_Weights_TotalAccumulation[Im_Number_Of_layer][Im_Number_Of_Neural][Im_Number_Of_Weight] + Im_PartialDerivative__Of_LossFunction_RespectTo_Weights[Im_Number_Of_layer][Im_Number_Of_Neural][Im_Number_Of_Weight] ;

                    }                

                } 

            }

        }

        

        return Im_PartialDerivative__Of_LossFunction_RespectTo_Weights_TotalAccumulation;

    }



}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//End contract of operational function

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////











///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Start contract of excution

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract AI_on_BlockChain__Execution is AI_on_BlockChain__OperationalFunction {

    

    function Im_Predict_Function(int[] memory Im_Input_Feature , NeuralNetWork_Struct_Object memory Im_NeuralNetWork_Object)

    public pure

    returns(int Im_Prediction_Result)

    {

        int Im_Prediction_ResultValue;

        Im_Prediction_ResultValue = Im_Forward_Propagation__Prediction

        (

            {Im_Input_Feature : Im_Input_Feature, 

            Im_NeuralNetWork_Object : Im_NeuralNetWork_Object}

        );



        return Im_Prediction_ResultValue;

    }    

    



    function Im_Training_Function__BackwardPropagation

    (

        int[][] memory Im_Input_Feature, 

        int[] memory Im_Input_Label, 

        int Learing_Rate, 

        uint TrainingTimes, 

        NeuralNetWork_Struct_Object memory Im_NeuralNetWork_Object

    )

    public pure

    returns 

    (

        int Avrage_Error, 

        int[] memory PredictionResultSet_AfterTraining, 

        int[][][] memory Current_WeightSet_Of_Nodes_In_EachLayer

    )

    {

    // initialize original weight equal to Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer

        int[][][] memory Im_Current_WeightSet_Of_Nodes_In_EachLayer = Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer;

        

    // loop training times

        for(uint Im_NumberOfTraining = 0; Im_NumberOfTraining < TrainingTimes; Im_NumberOfTraining++ )

        {



    //    compute partial derivative of loss respect to weight

            

        

            int[][][] memory Im_PartialDerivative__Of_LossFunction_RespectTo_Weights_TotalAccumulation;          

            

            Im_PartialDerivative__Of_LossFunction_RespectTo_Weights_TotalAccumulation = Im_ComputationFunction_PartialDerivative__Of_LossFunction_RespectTo_Weights

            (

                {Im_Input_Feature : Im_Input_Feature, 

                Im_Input_Label : Im_Input_Label, 

                Im_NeuralNetWork_Object : Im_NeuralNetWork_Object}

            );    

                

            for(uint Im_Number_Of_layer = 1; Im_Number_Of_layer < Im_NeuralNetWork_Object.Im_Number_Of_Layer; Im_Number_Of_layer++ )

            {                

                for(uint Im_Number_Of_Neural; Im_Number_Of_Neural < Im_NeuralNetWork_Object.Im_Nodes_In_EachLayer[Im_Number_Of_layer]; Im_Number_Of_Neural++ )

                {                

                    for(uint Im_Number_Of_Weight; Im_Number_Of_Weight < Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer[Im_Number_Of_layer][Im_Number_Of_Neural].length; Im_Number_Of_Weight++ )

                    {

                        Im_Current_WeightSet_Of_Nodes_In_EachLayer[Im_Number_Of_layer][Im_Number_Of_Neural][Im_Number_Of_Weight] = Im_Current_WeightSet_Of_Nodes_In_EachLayer[Im_Number_Of_layer][Im_Number_Of_Neural][Im_Number_Of_Weight]  - ( Learing_Rate * Im_PartialDerivative__Of_LossFunction_RespectTo_Weights_TotalAccumulation[Im_Number_Of_layer][Im_Number_Of_Neural][Im_Number_Of_Weight] );

                        Im_NeuralNetWork_Object.Im_Weights_Of_Nodes_In_EachLayer = Im_Current_WeightSet_Of_Nodes_In_EachLayer;

                    }                

                } 

            }

            

            //    update partial derivative of loss respect to weight by updateing : (weight = Learing_Rate * partial derivative of loss respect to weight)

            

        }

        

        int Im_PredictionResult_AfterTraining;

        int[] memory Im_PredictionResultSet_AfterTraining;

        int Im_Avrage_Error;

        

        for(uint Im_Number_Of_Data; Im_Number_Of_Data <= Im_Input_Feature.length ; Im_Number_Of_Data++)

        {

            Im_PredictionResult_AfterTraining = Im_Forward_Propagation__Prediction({Im_Input_Feature : Im_Input_Feature[Im_Number_Of_Data], Im_NeuralNetWork_Object : Im_NeuralNetWork_Object});

            Im_PredictionResultSet_AfterTraining[Im_Number_Of_Data] = Im_PredictionResult_AfterTraining;

        }

        

        Im_Avrage_Error = Im_Loss_function__L2({Im_Predict_ResultSets : Im_PredictionResultSet_AfterTraining, Im_Actual_ResultSets : Im_Input_Label});

        

        return (Im_Avrage_Error, Im_PredictionResultSet_AfterTraining, Im_Current_WeightSet_Of_Nodes_In_EachLayer);

    }

    

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//End contract of execution

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////







//Create by [email protected]

//Worship LuGoddess forever