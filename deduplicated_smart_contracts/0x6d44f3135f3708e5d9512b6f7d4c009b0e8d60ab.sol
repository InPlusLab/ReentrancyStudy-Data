pragma solidity ^0.4.9; 
//v.1609rev17 Ezlab 2016 all-rights reseved <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ee9d9b9e9e819c9aae8b94828f8cc0879a">[email&#160;protected]</a>
//special purpose contract for CantinaVolpone further info https://agrichain.it/d/0x160564d346f6e9fb3d93c034f207ecf9791b7739

//common base contract
contract BaseAgriChainContract {
    address creator; 
    bool public isSealed;
    function BaseAgriChainContract() public    {  creator = msg.sender; EventCreated(this,creator); }
    modifier onlyIfNotSealed() //semantic when sealed is not possible to change sensible data
    {
        if (isSealed)
            throw;
        _;
    }

    modifier onlyBy(address _account) //semantic only _account can operate
    {
        if (msg.sender != _account)
            throw;
        _;
    }
    
    function kill() onlyBy(creator)   { suicide(creator); }     
    function setCreator(address _creator)  onlyBy(creator)  { creator = _creator;     }
    function setSealed()  onlyBy(creator)  { isSealed = true;  EventSealed(this);   } //seal down contract not reversible

    event EventCreated(address self,address creator);
    event EventSealed(address self); //invoked when contract is sealed
    event EventChanged(address self,string property); // generic property change
    event EventChangedInt32(address self,string property,int32 value); //Int32 property change
    event EventChangedString(address self,string property,string value); //string property Change
    event EventChangedAddress(address self,string property,address value); //address property Changed
    
  
}







// production 
contract AgriChainContract   is BaseAgriChainContract    
{  
    string  public  Organization;      //Production Organization
    string  public  Product ;          //Product
    string  public  Description ;      //Description
    address public  AgriChainData;     //ProductionData
    string  public  AgriChainSeal;     //SecuritySeal
    string  public  Notes ;
    
    function   AgriChainProductionContract() public
    { 
       AgriChainData=address(this);
    }
    
    function setOrganization(string _Organization)  onlyBy(creator)  onlyIfNotSealed()
    {
          Organization = _Organization;
          EventChangedString(this,&#39;Organization&#39;,_Organization);

    }
    
    function setProduct(string _Product)  onlyBy(creator) onlyIfNotSealed()
    {
          Product = _Product;
          EventChangedString(this,&#39;Product&#39;,_Product);
        
    }
    
    function setDescription(string _Description)  onlyBy(creator) onlyIfNotSealed()
    {
          Description = _Description;
          EventChangedString(this,&#39;Description&#39;,_Description);
    }
    function setAgriChainData(address _AgriChainData)  onlyBy(creator) onlyIfNotSealed()
    {
         AgriChainData = _AgriChainData;
         EventChangedAddress(this,&#39;AgriChainData&#39;,_AgriChainData);
    }
    
    
    function setAgriChainSeal(string _AgriChainSeal)  onlyBy(creator) onlyIfNotSealed()
    {
         AgriChainSeal = _AgriChainSeal;
         EventChangedString(this,&#39;AgriChainSeal&#39;,_AgriChainSeal);
    }
    
    
     
    function setNotes(string _Notes)  onlyBy(creator)
    {
         Notes =  _Notes;
         EventChanged(this,&#39;Notes&#39;);
    }
}


//InnerData
contract AgriChainDataContract   is BaseAgriChainContract    
{  
    function   AgriChainDataContract() public
    {
        AgriChainNextData=address(this);
        AgriChainPrevData=address(this);
        AgriChainRootData=address(this);
    }
    
      address public  AgriChainNextData;
      address public  AgriChainPrevData;
      address public  AgriChainRootData;
      
      string public AgriChainType;
      string public AgriChainLabel;
      string public AgriChainLabelInt;
      string public AgriChainDescription;
      string public AgriChainDescriptionInt;
      
    function setChain(address _Next,address _Prev, address _Root)  onlyBy(creator)  
    {
         AgriChainNextData=_Next;
         AgriChainPrevData=_Prev;
         AgriChainRootData=_Root;
         EventChanged(this,&#39;Chain&#39;);
    }
    
    //main language data  
    function setData(string _Type,string _Label,string _Description)  onlyBy(creator) onlyIfNotSealed()
    {
          AgriChainType=_Type;
          AgriChainLabel=_Label;
          AgriChainDescription=_Description;
          EventChanged(this,&#39;Data&#39;);
    }
   
    //International language data
    function setDataInt(string _LabelInt,string _DescriptionInt)  onlyBy(creator) onlyIfNotSealed()
    {
          
          AgriChainLabelInt=_LabelInt;
          AgriChainDescriptionInt=_DescriptionInt;
          EventChanged(this,&#39;DataInt&#39;);
    }
   
      
}

//DocumentData
contract AgriChainDocumentContract   is AgriChainDataContract    
{  
     
    string  public  Emitter;      //Organization
    string  public  Name;         //Name
    string  public  Description ; //Description
    string  public  NameInt;         //Name International
    string  public  DescriptionInt ; //Description International

    string  public  FileName;     //FileName
    string  public  FileHash;     //FileHash
    string  public  FileData;     //FileData
   
    string  public  FileNameInt;  //FileName International
    string  public  FileHashInt;  //FileHash International
    string  public  FileDataInt;  //FileData International

    string  public  Notes ;
    address public  Revision; 
    
    function   AgriChainDocumentContract() public
    {
        Revision=address(this);
    }
    
    function setData(string _Emitter,string _Name,string _Description, string _FileName,string _FileHash,string _FileData)  onlyBy(creator) onlyIfNotSealed()
    {
          Emitter=_Emitter;
          Name=_Name;
          Description=_Description;
          FileName=_FileName;
          FileHash=_FileHash;
          FileData=_FileData;          
          EventChanged(this,&#39;Data&#39;);
       
    } 
    
     
    
    function setRevision(address _Revision)  onlyBy(creator) onlyIfNotSealed()
    {
          Revision = _Revision;
        
    } 
     
     
    function setNotes(string _Notes)  onlyBy(creator)
    {
         Notes =  _Notes;
         
    }
}


//
contract AgriChainProductionLotContract   is AgriChainDataContract    
{  
    
     int32  public QuantityInitial;
     int32  public QuantityAvailable;
     string public QuantityUnit;
    
    function InitQuantity(int32 _Initial,string _Unit)  onlyBy(creator)  onlyIfNotSealed()
    {
          QuantityInitial = _Initial;
          QuantityAvailable = _Initial;
          QuantityUnit = _Unit;
          EventChangedInt32(this,&#39;QuantityInitial&#39;,_Initial);

    }
  
    function UseQuantity(int32 _Use)  onlyBy(creator)  
    {
          QuantityAvailable = QuantityAvailable-_Use;
          EventChangedInt32(this,&#39;QuantityAvailable&#39;,QuantityAvailable);

    }
  
}