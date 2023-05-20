pragma solidity ^0.4.17;
pragma experimental ABIEncoderV2;

contract MilkContract {
    struct Supplier {
        address id;
        string name;
        string phone;
        string email;
        uint256 pricePerLiter;
        string location;
        uint256 balance;
        uint256 rating;
        uint256 numRatings;}
    struct Consumer {
        address id;
        string name;
        string phone;
        string email;
        string location;
        uint256 balance;
        address supplier;}
    struct Transaction {
        uint256 id;
        address consumer;
        address supplier;
        uint256 amount;
        uint256 rating;
        bool confirmed;}
    
    
    mapping(address => Supplier) public suppliers;
    mapping(address => Consumer) public consumers;
    Transaction[] public transactions;
    address[] public suppliersAddress;
    uint256 supplierCount = 0;
    uint256 consumerCount = 0;

    function addSupplier(string name, string phone, string email, uint256 pricePerLiter, string location) public {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(phone).length > 0, "Phone cannot be empty");
        require(bytes(email).length > 0, "Email cannot be empty");
        require(pricePerLiter > 0, "PricePerLiter must be greater than zero");
        require(bytes(location).length > 0, "Location cannot be empty");
        supplierCount++;
        suppliersAddress.push(msg.sender);
        suppliers[msg.sender] = Supplier(msg.sender, name, phone, email, pricePerLiter, location, 0, 0, 0);}
    function addConsumer(string name, string phone, string email, string location) public payable {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(phone).length > 0, "Phone cannot be empty");
        require(bytes(email).length > 0, "Email cannot be empty");
        require(bytes(location).length > 0, "Location cannot be empty");
        consumerCount++;
        consumers[msg.sender] = Consumer(msg.sender, name, phone, email, location, msg.value, address(0));}
    function chooseSupplier(address supplier) public {
        require(msg.sender != supplier);
        require(bytes(suppliers[supplier].name).length > 0);

        consumers[msg.sender].supplier = supplier;}
    function initiateTransaction(address consumerAddress, uint256 amount) public {
        require(amount > 0);
        require(bytes(suppliers[msg.sender].name).length > 0);
        require(bytes(consumers[consumerAddress].name).length > 0);

        uint256 calculatedAmount = amount * suppliers[msg.sender].pricePerLiter;

        transactions.push(Transaction(transactions.length + 1, consumerAddress, msg.sender, calculatedAmount, 0, false));}
    function confirmTransaction(uint256 transactionIndex, uint256 rating) public {
        Transaction storage transaction = transactions[transactionIndex];
        require(transaction.consumer == msg.sender);
        require(!transaction.confirmed, "Transaction has already been confirmed");

        // Deduct the amount from the consumer's balance
        Consumer storage consumer = consumers[transaction.consumer];
        require(consumer.balance >= transaction.amount, "Insufficient balance");
        consumer.balance -= transaction.amount;

        // Transfer the amount to the supplier's balance
        Supplier storage supplier = suppliers[transaction.supplier];
        supplier.balance += transaction.amount;

        // Update the supplier's rating
        uint256 totalRating = supplier.rating * supplier.numRatings;
        supplier.numRatings++;
        supplier.rating = (totalRating + rating) / supplier.numRatings;

        // Mark the transaction as confirmed
        transaction.confirmed = true;}
    function getSupplier(address supplier) public view returns (string, string, string, uint256, string, uint256, uint256) {
        Supplier storage s = suppliers[supplier];
        return (s.name, s.phone, s.email, s.pricePerLiter, s.location, s.rating, s.numRatings);}
    function getConsumer(address consumer) public view returns (string, string, string, string, uint256, address) {
        Consumer storage c = consumers[consumer];
        return (c.name, c.phone, c.email, c.location, c.balance, c.supplier);}
    function withdrawBalance(uint256 amount) public {
        require(amount > 0, "WithdrawBalance should be more that zero");
        require(suppliers[msg.sender].balance >= amount, "Insufficient balance");

        suppliers[msg.sender].balance -= amount;
        msg.sender.transfer(amount);}
    function getSupplierTransactions() public view returns (Transaction[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].supplier == msg.sender) {
                count++;
            }
        }
        Transaction[] memory result = new Transaction[](count);
        uint256 index = 0;
        for ( i = 0; i < transactions.length; i++) {
            if (transactions[i].supplier == msg.sender) {
                result[index] = transactions[i];
                index++;
            }
        }
        return (result);}
    function getConsumerTransactions() public view returns (Transaction[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].consumer == msg.sender) {
                count++;
            }
        }
        Transaction[] memory result = new Transaction[](count);
        uint256 index = 0;
        for ( i = 0; i < transactions.length; i++) {
            if (transactions[i].consumer == msg.sender) {
                result[index] = transactions[i];
                index++;
            }
        }
        return (result);}
    function addBalance() public payable {
        Consumer storage consumer = consumers[msg.sender];
        consumer.balance += msg.value;}
    function getAllSuppliers() public view returns (Supplier[] memory) {
        Supplier[] memory allSuppliers = new Supplier[](supplierCount);
        uint256 i = 0;
        for (i=0; i<supplierCount; i++) {
            allSuppliers[i] = suppliers[suppliersAddress[i]];
        }
        return allSuppliers;}
}
