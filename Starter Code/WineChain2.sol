pragma solidity ^0.7.6;
contract WineChain2{
    
    
    address payable public owner;
     uint totalamount =0;
    
    // Payable constructor can receive Ether
    constructor() payable {
        owner = payable(msg.sender);
    }
    
    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable {
        totalamount += msg.value;
    }
    
    
    // Function to withdraw all Ether from this contract.
    function withdraw() public {
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success,) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

   // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint _amount) public {
        // Note that "to" is declared as payable
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
    
    function getbalance() public view returns(
        uint _quantity
        ){
            _quantity = totalamount;
        }
    
    struct qualityReport{
        address winequalityinspector;
        int256 quantity;
        int256 defective;
        string remarks;
    }
    struct customsReport{
        string remarks;
        string receivedShipment;
        qualityReport qualityreport;
    }
    struct retailerReport{
        string productName;
        string rawMaterial;
        string remarks;
        string manufacturedDate;
        int256 quantityProduced;
        customsReport processedReport;
    }
   
    // Maps address of respective Stakeholders to true
    mapping(address=>bool) isWineProducer;
    mapping(address=>bool) isCustomsOfficer;
    mapping(address=>bool) isRetailer;
    mapping(address=>bool) isInspector;
   
    // Map Stakeholders address to Key
    mapping(address=>string) wineproducerMapping;
    mapping(address=>string) customsMapping;
    mapping(address=>string) retailerMapping;
    mapping(address=>string) winequalityinspectorMapping;
   
    //Events
    event wineproducerAddition(address wineproducerAddress,string wineproducerKey);
    event customsAddition(address customsAddress,string customsKey);
    event retailerAddition(address retailerAddress,string retailerKey);
    event winequalityinspectorAddition(address inspectoAddress,string inspectoKey);
    //Modifiers
    modifier onlyWineProducer(address wineproducer){
        require(isWineProducer[wineproducer]);
        _;
    }
    modifier onlyInspector(address winequalityinspector){
        require(isWineProducer[winequalityinspector]);
        _;
    }
    modifier onlyRetailer(address retailer){
        require(isRetailer[retailer]);
        _;
    }
    modifier onlyCustomsOfficer(address customs){
        require(isCustomsOfficer[customs]);
        _;
    }
    
    mapping(address=>mapping(string=>qualityReport)) qualityReports; // mapping of wineproducers address to lotNumber and report
    mapping(address=>mapping(address => mapping(string=>customsReport))) customsReports;
    mapping(string => string) lotToBatch;
    mapping(address=>mapping(string=>retailerReport)) retailerReports;
   
    function addWineProducer(address _wineproducer,string memory _wineproducerKey) public {
        isWineProducer[_wineproducer] = true;
        wineproducerMapping[_wineproducer] = _wineproducerKey;
        emit wineproducerAddition(_wineproducer,_wineproducerKey);
    }
    function addCustomsOfficer(address _customs,string memory _customsKey) public {
        isCustomsOfficer[_customs] = true;
        customsMapping[_customs] = _customsKey;
        emit customsAddition(_customs,_customsKey);
    }
    function addInspector(address _winequalityinspector,string memory _winequalityinspectorKey) public {
        isInspector[_winequalityinspector] = true;
        winequalityinspectorMapping[_winequalityinspector] = _winequalityinspectorKey;
        emit winequalityinspectorAddition(_winequalityinspector,_winequalityinspectorKey);
    }
    function addRetailer(address _retailer,string memory _retailerKey) public {
        isRetailer[_retailer] = true;
        retailerMapping[_retailer] = _retailerKey;
        emit retailerAddition(_retailer,_retailerKey);
    }
    function addQualityReport(address _wineproducer,address _winequalityinspector,string memory _lotNumber,string memory _remarks,int256 _quantity, int256 _defective) public {
        qualityReports[_wineproducer][_lotNumber].winequalityinspector = _winequalityinspector;
        qualityReports[_wineproducer][_lotNumber].remarks = _remarks;
        qualityReports[_wineproducer][_lotNumber].defective = _defective;
        qualityReports[_wineproducer][_lotNumber].quantity = _quantity;
    }
    function getQualityReport(address _wineproducer,string memory _lotNumber) public view returns(
        string memory _remarks,
        address _winequalityinspector,
        int256 _defective,
        int256 _quantity
        ){
        _remarks = qualityReports[_wineproducer][_lotNumber].remarks;
        _winequalityinspector = qualityReports[_wineproducer][_lotNumber].winequalityinspector;
        _defective = qualityReports[_wineproducer][_lotNumber].defective;
        _quantity = qualityReports[_wineproducer][_lotNumber].quantity;
    }
    function addCustomsOfficerReport(address _customs,address _wineproducer,
                                string memory _lotNumber,string memory _remarks,
                                string memory _receivedShipment) public{
        customsReports[_customs][_wineproducer][_lotNumber].remarks = _remarks;
        customsReports[_customs][_wineproducer][_lotNumber].receivedShipment = _receivedShipment;
        customsReports[_customs][_wineproducer][_lotNumber].qualityreport = qualityReports[_wineproducer][_lotNumber];
    }
    function getCustomsOfficerReport(address _customs,address _wineproducer,string memory _lotNumber) public view returns(
        string memory _remarks,
        string memory _receivedShipment
        ){
        _remarks = customsReports[_customs][_wineproducer][_lotNumber].remarks;
        _receivedShipment = customsReports[_customs][_wineproducer][_lotNumber].receivedShipment;
    }
    function BatchtoLot(string memory _batchNumber,string memory _lotNumber) public{
        lotToBatch[_batchNumber] = _lotNumber;
    }
    function addRetailerReport(address _retailer, address _customs, address _wineproducer,
        string memory _remarks,
        string memory _rawMaterial,
        string memory _productName,
        string memory _manufacturedDate,
        int256 _quantity,
        string memory _batchNumber
    ) public {
        retailerReports[_retailer][_batchNumber].productName = _productName;
        retailerReports[_retailer][_batchNumber].remarks = _remarks;
        retailerReports[_retailer][_batchNumber].rawMaterial = _rawMaterial;
        retailerReports[_retailer][_batchNumber].manufacturedDate = _manufacturedDate;
        retailerReports[_retailer][_batchNumber].quantityProduced = _quantity;
        retailerReports[_retailer][_batchNumber].processedReport = customsReports[_customs][_wineproducer][lotToBatch[_batchNumber]];
    }
    function getRetailerReport(address _retailer,string memory _batchNumber) public view returns(
        string memory _productName,
        string memory _remarks,
        string memory _rawMaterial,
        string memory _manufacturedDate,
        int256 _quantity
        ){
            _productName = retailerReports[_retailer][_batchNumber].productName;
            _remarks = retailerReports[_retailer][_batchNumber].remarks;
            _rawMaterial = retailerReports[_retailer][_batchNumber].rawMaterial;
            _manufacturedDate = retailerReports[_retailer][_batchNumber].manufacturedDate;
            _quantity = retailerReports[_retailer][_batchNumber].quantityProduced;
        }
   
}
