//Shopfront Example Practice

pragma solidity ^0.4.6;


contract Shopfront {
    address public admin; //Site admin

    //Struct of all products on the website
    struct OurProducts {
        address merchant; 
        uint    price; //Price per unit in Ether. 
        uint    stock; 
    }
    
    /*Map the ID of each object to the struct of their
    Merchant, Price, & Stock */
    mapping (address => OurProducts) public ourProducts; 
    
    //Mapping balance values to addresses of merchants.
    mapping (address => uint) public balances;
    //For handling 3rd party coin
    mapping (address => mapping(address => uint)) public despaBalances; 
    
    //Mapping of a mapping to coPurchase
    mapping (address => mapping(address => uint256)) combinedMoney; 
    mapping (address => mapping(address => address)) itemToPurchase;
    
    //Event logs
    event   LogProductAddition(address aMerchant, address anItemId, uint aPrice, uint aStock);
    event   LogProductPurchased(bytes32 aBuyer, address boughtId, uint boughtStock);
    event   LogProductCoPurchased(bytes32 theBuyers, address boughtId, uint boughtStock);
    
//Constructor
function Shopfront() {
    admin = msg.sender; 
}    

//Function to add products to the website
function addNewProduct(address theId, uint thePrice, uint theStock)
    public
    returns (bool success)
{
    //Cases to throw
    if  (theStock == 0) throw; 
    if  (thePrice == 0) throw; 
    /* What is if a merchant tries to add more stock to an existing product
    but tries to put a different price. Added new function for add stock. */
    if (ourProducts[theId].merchant == msg.sender) throw; /* If they have already
    the product, they should just be adding stock. To Do - 1. If they need to change the price, 
    they can go through the admin. Assume that if another vendor tries to add the same item, thats
    ok, they can price compete like amazon. Maybe add a change price function for merchants to 
    change price directly...*/

    //Build the struct & push
    uint oneWei = 1000000000000000000;
    
    ourProducts[theId].merchant = msg.sender; 
    ourProducts[theId].price = thePrice*oneWei;
    ourProducts[theId].stock += theStock;

    //Add an event to product addition 
    LogProductAddition(msg.sender, theId, thePrice, theStock);
    return true; 
}

function addStock(address theId, uint theStock)
    public
    returns (bool success)
    {
        if (theStock == 0) throw;
        if (ourProducts[theId].merchant != msg.sender) throw; 
        ourProducts[theId].stock += theStock; 
        return true; 
    }

/*Function to buy a product - but the instructions said as a 'regular user', does
that mean I need to keep a register of users?*/ 
function singleBuyProduct(address buyId, uint howMany)
    public
    payable
    returns (bool success)
{
    //Cases to throw
    /* Must have enough in stock.*/
    if (howMany <= 0) throw; 
    /* Requiring the purchaser to pay exact. Do not want to deal with returning 
    leftover money */
    if (msg.value <= 0) throw; 
    /* Vendor cannot buy their own product, false advertising data.*/
    if (msg.sender == ourProducts[buyId].merchant) throw;
    
    ourProducts[buyId].stock -= howMany;
    
    /* Hashing the sender so they can remain 'anonymous' on the website */
    bytes32 theBuyer = keccak256(msg.sender);
    LogProductPurchased(theBuyer, buyId, howMany);
    
    /* Any remainder balances go to contract/admin */
    balances[admin] += msg.value*5/100;
    balances[ourProducts[buyId].merchant] += msg.value*95/100; 
    
    return true; 

}

//Function with ability to remove product.
function removeProduct(address removeId)
    public
    returns (bool success)

{
    /*Product should exist in the site.*/
    if (ourProducts[removeId].merchant == 0) throw; 
    /* Only merchants or the admin should be able to remove product. */
    if (msg.sender != ourProducts[removeId].merchant || msg.sender != admin) throw;
    /* I've seen a couple of different ways to remove, suggesting it is okay to 
    remove if numbers of events is bounded. Here you can only remove one product at a time, 
    so it should be bounded -as far as my definition goes. */
    delete ourProducts[removeId];
    /*Or I could create a variable within the struct/array that switches from 1 to 0
    based on whether or not the product should show? Maybe it's something seasonal. */
    return true; 
    /*This just leaves zeros in the mapping, is that okay?*/

}

//Function to be able to make a payment. 
function makePayment() 
    public
    payable
    returns (bool success)
{
    /*Leave this as is? I thought about maping balances, but why? If a random money launderer
    sends money to the contract, they would be able to get it out, right?*/
}

//Function to be able to withdrawl
function withdrawl() 
    public
    returns (bool success)
{
   /* Only those with balanaces mapped to their addresses can withdrawl. 
   So, people that paid for "co-purchases" can withdrawl if they decide not to purchase in the end */
    if(!msg.sender.send(balances[msg.sender])) throw;
    balances[msg.sender] -= balances[msg.sender];
    return true; 
}

/* Co Purchasing: 
What if's & Assumptions
1. Assumptions: Only 2 people can copurchase at one time. (i.e. you can't have 3 people copurchase one thing)
2. What if one person is copurchasing the same thing with two different people
3. How do you make sure that a random person doesn't step in and 'steal' the copurchase 
4. At this point, for simplification, only one item at time can be co-purchased. 

Steps:
1. Use mapping of a mapping of mapping for a coPurcase
*/

/*Function to start a copurchase. Either party can create. Allows each buyer to 
pay a different amount but they have to figure it out between themselves how much
each will pay. */
function copurchasePart1(address coBuyer1, address itemId)
    public
    payable
    returns (bool success)
    {
        if (msg.value <= 0) throw; 
        if (ourProducts[itemId].stock <= 0) throw; 
        if (coBuyer1 == 0x0) throw;
        /* If they pay the whole thing, that's not a copurchase. Should use other
        functionality for buying the item on their own. */
        if (msg.value >= ourProducts[itemId].price) throw; 
        combinedMoney[msg.sender][coBuyer1] += msg.value;
        itemToPurchase[msg.sender][coBuyer1] = itemId; 
        return true;
    }

function copurchasePart2(address coBuyer2, address itemId2)
    public
    payable
    returns (bool success)
    {
        if (msg.value <=0) throw; 
        if (ourProducts[itemId2].stock <= 0) throw; 
        if (coBuyer2 == 0x0) throw; 
        if (itemToPurchase[coBuyer2][msg.sender] != itemId2) throw;
        /* Not dealing with fancy return supply chains, just pay the right amount! :) */
        if (combinedMoney[coBuyer2][msg.sender] + msg.value > ourProducts[itemId2].price) throw; 
        combinedMoney[coBuyer2][msg.sender] += msg.value;
        return true; 
    }

/* Simpifying assumption that the initiator will be the one picking up the product */
function coPickUp(address coBuyer1, address itemId3)
    public
    returns (bool success)
    {
        if (combinedMoney[msg.sender][coBuyer1] != ourProducts[itemId3].price) throw; 
        /* To Do - Think of a way to 'reserve stock'. At this point, the item could 
        sell out before the copurchase is complete. */
        if (ourProducts[itemId3].stock == 0) throw;
        ourProducts[itemId3].stock -= 1; 
        var anonBuyers = keccak256(msg.sender, coBuyer1);
        LogProductCoPurchased(anonBuyers, itemId3, 1);
        return true;
    }

/*Purchase with 3rd party coins. 
My line of thinking 
0. Create 'DespaCento' - imported. Create own coin for testing purposes.
1. (Function) Buyer needs to send DespaCento to map to contract address. 
--> How do I check the DespaCento in their account??
2. (Function) Buyer can specify what he/she want to buy & how many. If there is enough
despaCento in their account they can buy. 

To Do - Unless I add another pricing column, I need a conversion to/from Ether.

function sendDespaCento(uint sentAmount)
    public
    // Not payable because not paying in Either
    {
        despaBalances[msg.sender][this] += sentAmount; 
        //How to check if buyer has enough despaCento to send? Showing errors for compilation,
        //how to be able to check? Child contract? Seems like that's not the answer.
        if (balancesOf[msg.sender]>= sentAmount) throw;
        //How to deduct despaCento from the buyer? 
        // Should I rather be allowing for the contract to make transactions on the 
        //buyer's behalf? But would be the "to" in that case? The contract address as allowed to send 
        //from the buyers account and can send despacento to itself?...that doesn't feel right.
        
    }
    
function buyWithDespaCento(address itemId, uint howMany)
    public
    {
        var totalCost = ourProducts[itemId].price * howMany; 
        if (despaBalances[msg.sender][this] < totalCost) throw; 
        if (ourProducts[itemId].stock < howMany) throw; 
        despaBalances[msg.sender][this] -= totalCost; 
        ourProducts[itemId].stock -= howMany; 
    }
 
*/
        
    }

