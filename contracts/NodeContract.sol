pragma solidity >=0.4.21 <0.7.0;

contract NodeContract {

    address owner;
    uint currentPayableAmount;

	modifier onlyOwner(){
         require(msg.sender == owner);
         _;
    }

     struct weightStruct{
        uint weightOfScreenresolution;         //0
        uint weightOfRam;       //1
        uint weightOfInternalmemory;        //2
        uint weightOfFrontcamera;     //3
        uint weightOfRearcamera;        //4
        uint weight;          //6
    }

    struct Product {
        address producerAddress;    //0
        address retailerAddress;    //1
        address consumerAddress;    //2
        string name;                //3
        string typeOfProduct;       //4
        bool returnedToRetailer;    //5
        bool returnedToProducer;    //6
        uint reusePercentage;       //7
        uint price;                 //8
        uint percentConsumer;       //9
        bool markedByAdmin;         //10
    }

    Product[] public ProductList;
    weightStruct[] public weights;

	constructor() public {
        owner=msg.sender;
	}

	function () external payable{
	    revert();
	}

	function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

	function addProduct(string memory _name,string memory _type, uint _weightOfScreenresolution, uint _weightOfRam, uint _weightOfInternalmemory, uint _weightOfFrontcamera, uint _weightOfRearcamera, uint _weight,uint _price, uint _quantity) public{
        for(uint i=0; i<_quantity;i++){
            ProductList.push(Product(msg.sender, address(0), address(0), _name,_type, false, false, 0, _price, 0,false));
            weights.push(weightStruct(_weightOfScreenresolution,_weightOfRam,_weightOfInternalmemory,_weightOfFrontcamera, _weightOfRearcamera,_weight));
        }
	}

	function getProductCount() public view returns(uint){
	    return ProductList.length;
	}


    function getCostForRetailer(address _producer,string memory _name,string memory _type,uint _quantity) public view returns (uint){
        uint _sum=0;
        for(uint i=0;i<ProductList.length;i++){
            if(ProductList[i].producerAddress==_producer && compareStrings(ProductList[i].typeOfProduct,_type) && compareStrings(ProductList[i].name,_name) && _quantity>0 && ProductList[i].retailerAddress==address(0)){
                _quantity--;
                _sum=_sum+ProductList[i].price;
            }
        }
        return _sum;
    }

	function soldToRetailer(address payable _producer,string memory _name,string memory _type,uint _quantity) public payable{
        for(uint i=0;i<ProductList.length;i++){
            if(ProductList[i].producerAddress==_producer && compareStrings(ProductList[i].typeOfProduct,_type) && compareStrings(ProductList[i].name,_name) && _quantity>0 && ProductList[i].retailerAddress==address(0)){
                ProductList[i].retailerAddress=msg.sender;
                _quantity--;
            }
        }
        _producer.transfer(msg.value);
	}

    function getCostForConsumer(address _retailer,string memory _name,string memory _type,uint _quantity) public view returns (uint){
        uint _sum=0;
        for(uint i=0;i<ProductList.length;i++){
            if(ProductList[i].retailerAddress==_retailer && compareStrings(ProductList[i].typeOfProduct,_type) && compareStrings(ProductList[i].name,_name) && _quantity>0 && ProductList[i].consumerAddress==address(0)){
                _quantity--;
                _sum=_sum+ProductList[i].price;
            }
        }
        return _sum;
    }

	function soldToConsumer(address payable _retailer,string memory _name,string memory _type,uint _quantity) public payable{
        for(uint i=0;i<ProductList.length;i++){
            if(ProductList[i].retailerAddress==_retailer && compareStrings(ProductList[i].typeOfProduct,_type) && compareStrings(ProductList[i].name,_name) && _quantity>0 && ProductList[i].consumerAddress==address(0)){
                ProductList[i].consumerAddress=msg.sender;
                _quantity--;
            }
        }
        _retailer.transfer(msg.value);
	}

     function getValue(uint _id,uint _percentage) public view returns(uint){
        uint _percentConsumer = ProductList[_id].percentConsumer;
        uint _price = ProductList[_id].price;
        uint _amount = _percentConsumer*_price*10**16 + _percentage*_price*10**15;
        return _amount;
    }

    function addPercentage(uint _id,uint _percentage) public payable{
        ProductList[_id].reusePercentage=_percentage;
        address payable _retailer = address(uint160(ProductList[_id].retailerAddress));
        _retailer.transfer(msg.value);
    }

    function sendIncentives (uint[] memory _products,address payable _producer) public payable {
        //marking products marked by admin
        for(uint i=0;i<_products.length;i++){
            ProductList[_products[i]].markedByAdmin=true;
        }
        _producer.transfer(msg.value);
    }

    

    //Consumer Methods
    function fetchProductReferenceConsumer(address _address) public view returns(uint){

    }

}
