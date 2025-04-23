CREATE DATABASE  IF NOT EXISTS `manman` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `manman`;
-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: manman
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `AID` int NOT NULL,
  `Aname` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`AID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'Alice Admin','9991112222'),(2,'Bob Boss','8882223333');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch`
--

DROP TABLE IF EXISTS `branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branch` (
  `BranchID` int NOT NULL,
  `Bname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`BranchID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch`
--

LOCK TABLES `branch` WRITE;
/*!40000 ALTER TABLE `branch` DISABLE KEYS */;
INSERT INTO `branch` VALUES (1,'Central'),(2,'North'),(3,'South');
/*!40000 ALTER TABLE `branch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_inventory`
--

DROP TABLE IF EXISTS `branch_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branch_inventory` (
  `BranchID` int NOT NULL,
  `InventoryID` int NOT NULL,
  `Quantity` int DEFAULT NULL,
  PRIMARY KEY (`BranchID`,`InventoryID`),
  KEY `InventoryID` (`InventoryID`),
  CONSTRAINT `branch_inventory_ibfk_1` FOREIGN KEY (`BranchID`) REFERENCES `branch` (`BranchID`),
  CONSTRAINT `branch_inventory_ibfk_2` FOREIGN KEY (`InventoryID`) REFERENCES `inventory` (`InventoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_inventory`
--

LOCK TABLES `branch_inventory` WRITE;
/*!40000 ALTER TABLE `branch_inventory` DISABLE KEYS */;
INSERT INTO `branch_inventory` VALUES (1,1,47),(1,2,95),(2,1,30),(2,3,57),(3,2,40),(3,3,64);
/*!40000 ALTER TABLE `branch_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery`
--

DROP TABLE IF EXISTS `delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery` (
  `DeliveryID` int NOT NULL AUTO_INCREMENT,
  `Address` varchar(200) DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL,
  `Street` varchar(100) DEFAULT NULL,
  `Country` varchar(100) DEFAULT NULL,
  `PinCode` varchar(20) DEFAULT NULL,
  `RecipientName` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`DeliveryID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery`
--

LOCK TABLES `delivery` WRITE;
/*!40000 ALTER TABLE `delivery` DISABLE KEYS */;
INSERT INTO `delivery` VALUES (1,'123 Main St','Metropolis','Main','CountryA','12345','John Doe'),(2,'456 Oak Ave','Gotham','Oak','CountryB','67890','Jane Smith'),(5,'123 Main St','gurgaon','sector 52','india','122001','John Doe'),(6,'UK','new york','canada','Japan','123456','David Miller'),(7,'UK','gurgaon','sector 52','China','122001','David Miller');
/*!40000 ALTER TABLE `delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `EID` int NOT NULL,
  `Ename` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`EID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (1,'Eve Employee','7773334444'),(2,'Charlie Clerk','6664445555');
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `InventoryID` int NOT NULL,
  `Itemname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`InventoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,'Electronics'),(2,'Groceries'),(3,'Clothing');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice`
--

DROP TABLE IF EXISTS `invoice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice` (
  `InvoiceID` int NOT NULL AUTO_INCREMENT,
  `OrderNo` int DEFAULT NULL,
  `InvoiceDate` date DEFAULT NULL,
  PRIMARY KEY (`InvoiceID`),
  UNIQUE KEY `OrderNo` (`OrderNo`),
  CONSTRAINT `invoice_ibfk_1` FOREIGN KEY (`OrderNo`) REFERENCES `orders` (`OrderNo`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice`
--

LOCK TABLES `invoice` WRITE;
/*!40000 ALTER TABLE `invoice` DISABLE KEYS */;
INSERT INTO `invoice` VALUES (1,1,'2025-04-20'),(2,2,'2025-04-21'),(3,4,'2025-04-23'),(4,5,'2025-04-23'),(5,6,'2025-04-23');
/*!40000 ALTER TABLE `invoice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_product`
--

DROP TABLE IF EXISTS `order_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_product` (
  `OrderNo` int NOT NULL,
  `PID` int NOT NULL,
  `Quantity` int DEFAULT NULL,
  PRIMARY KEY (`OrderNo`,`PID`),
  KEY `PID` (`PID`),
  CONSTRAINT `order_product_ibfk_1` FOREIGN KEY (`OrderNo`) REFERENCES `orders` (`OrderNo`),
  CONSTRAINT `order_product_ibfk_2` FOREIGN KEY (`PID`) REFERENCES `product` (`PID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_product`
--

LOCK TABLES `order_product` WRITE;
/*!40000 ALTER TABLE `order_product` DISABLE KEYS */;
INSERT INTO `order_product` VALUES (1,1,1),(1,2,1),(2,2,2),(2,3,1),(4,3,2),(5,2,8),(6,4,1);
/*!40000 ALTER TABLE `order_product` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `UpdateInventoryAfterOrder` AFTER INSERT ON `order_product` FOR EACH ROW BEGIN
    DECLARE inv_id INT;
    DECLARE remaining_qty INT;
    DECLARE branch_id INT;
    DECLARE branch_qty INT;
    DECLARE done INT DEFAULT 0;
    
    -- Cursor declaration must come before any other statements
    DECLARE branch_cursor CURSOR FOR
        SELECT BranchID, Quantity 
        FROM Branch_Inventory 
        WHERE InventoryID = (SELECT InventoryID FROM Product WHERE PID = NEW.PID) 
        AND Quantity > 0
        ORDER BY Quantity DESC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    -- Get inventory ID for the product
    SELECT InventoryID INTO inv_id FROM Product WHERE PID = NEW.PID;
    
    -- Set initial remaining quantity to update
    SET remaining_qty = NEW.Quantity;
    
    OPEN branch_cursor;
    
    update_loop: LOOP
        FETCH branch_cursor INTO branch_id, branch_qty;
        
        IF done OR remaining_qty <= 0 THEN
            LEAVE update_loop;
        END IF;
        
        IF branch_qty >= remaining_qty THEN
            -- This branch has enough inventory
            UPDATE Branch_Inventory
            SET Quantity = Quantity - remaining_qty
            WHERE BranchID = branch_id AND InventoryID = inv_id;
            
            SET remaining_qty = 0;
        ELSE
            -- Take what we can from this branch
            UPDATE Branch_Inventory
            SET Quantity = 0
            WHERE BranchID = branch_id AND InventoryID = inv_id;
            
            SET remaining_qty = remaining_qty - branch_qty;
        END IF;
    END LOOP;
    
    CLOSE branch_cursor;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `OrderNo` int NOT NULL AUTO_INCREMENT,
  `Date` date DEFAULT NULL,
  `Amount` decimal(10,2) DEFAULT NULL,
  `userID` int DEFAULT NULL,
  `EmployeeID` int DEFAULT NULL,
  `DeliveryID` int DEFAULT NULL,
  PRIMARY KEY (`OrderNo`),
  KEY `userID` (`userID`),
  KEY `EmployeeID` (`EmployeeID`),
  KEY `DeliveryID` (`DeliveryID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `users` (`userID`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`EmployeeID`) REFERENCES `employee` (`EID`),
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`DeliveryID`) REFERENCES `delivery` (`DeliveryID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'2025-04-20',820.00,1,1,1),(2,'2025-04-21',60.00,2,2,2),(4,'2025-04-23',80.00,1,1,5),(5,'2025-04-23',160.00,3,1,6),(6,'2025-04-23',1000.00,3,1,7);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `PID` int NOT NULL AUTO_INCREMENT,
  `Pname` varchar(100) DEFAULT NULL,
  `Category` varchar(50) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `SupID` int DEFAULT NULL,
  `StorageID` int DEFAULT NULL,
  `InventoryID` int DEFAULT NULL,
  PRIMARY KEY (`PID`),
  KEY `SupID` (`SupID`),
  KEY `StorageID` (`StorageID`),
  KEY `InventoryID` (`InventoryID`),
  CONSTRAINT `product_ibfk_1` FOREIGN KEY (`SupID`) REFERENCES `supplier` (`SupID`),
  CONSTRAINT `product_ibfk_2` FOREIGN KEY (`StorageID`) REFERENCES `storage` (`StorageID`),
  CONSTRAINT `product_ibfk_3` FOREIGN KEY (`InventoryID`) REFERENCES `inventory` (`InventoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'Laptop','Electronics',800.00,1,1,1),(2,'T-Shirt','Clothing',20.00,2,2,3),(3,'Rice Bag','Groceries',40.00,1,1,2),(4,'Iphone','Electronics',1000.00,2,2,1);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `storage`
--

DROP TABLE IF EXISTS `storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `storage` (
  `StorageID` int NOT NULL,
  `Sitem` varchar(100) DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  PRIMARY KEY (`StorageID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storage`
--

LOCK TABLES `storage` WRITE;
/*!40000 ALTER TABLE `storage` DISABLE KEYS */;
INSERT INTO `storage` VALUES (1,'Warehouse A',200),(2,'Warehouse B',150);
/*!40000 ALTER TABLE `storage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier` (
  `SupID` int NOT NULL,
  `Sname` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`SupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
INSERT INTO `supplier` VALUES (1,'Acme Supplies','5551234567'),(2,'Global Goods','5559876543');
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(100) DEFAULT NULL,
  `Password` varchar(100) NOT NULL,
  `Name` varchar(100) DEFAULT NULL,
  `Address` varchar(200) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `AdminID` int DEFAULT NULL,
  PRIMARY KEY (`userID`),
  KEY `AdminID` (`AdminID`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`AdminID`) REFERENCES `admin` (`AID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'john_doe','pass123','John Doe','123 Main St','1234567890','john@example.com',1),(2,'jane_smith','pass456','Jane Smith','456 Oak Ave','2345678901','jane@example.com',2),(3,'Miller','pass123','David Miller','UK','9876543456','miller@gmail.com',2);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'manman'
--

--
-- Dumping routines for database 'manman'
--
/*!50003 DROP FUNCTION IF EXISTS `GetSupplierName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetSupplierName`(prod_id INT) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE sup_name VARCHAR(100);
    SELECT Sname INTO sup_name
    FROM Supplier
    WHERE SupID = (SELECT SupID FROM Product WHERE PID = prod_id);
    RETURN sup_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `GetTotalProductsInInventory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GetTotalProductsInInventory`(inv_id INT) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT SUM(Quantity) INTO total
    FROM Branch_Inventory
    WHERE InventoryID = inv_id;
    RETURN IFNULL(total, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddProduct`(
    IN p_name VARCHAR(100), 
    IN p_category VARCHAR(50), 
    IN p_price DECIMAL(10,2),
    IN p_supid INT, 
    IN p_storageid INT, 
    IN p_inventoryid INT,
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        ROLLBACK;
    END;
    
    START TRANSACTION;
    INSERT INTO Product (Pname, Category, Price, SupID, StorageID, InventoryID)
    VALUES (p_name, p_category, p_price, p_supid, p_storageid, p_inventoryid);
    SET p_success = TRUE;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddProductToOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddProductToOrder`(
    IN p_orderid INT,
    IN p_productid INT,
    IN p_quantity INT,
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE available BOOLEAN DEFAULT FALSE;
    DECLARE product_price DECIMAL(10,2);
    DECLARE current_amount DECIMAL(10,2);
    
    -- Check if enough stock
    CALL CheckStock(p_productid, p_quantity, available);
    
    IF available THEN
        -- Get product price
        SELECT Price INTO product_price FROM Product WHERE PID = p_productid;
        
        -- Add product to order
        INSERT INTO Order_Product (OrderNo, PID, Quantity)
        VALUES (p_orderid, p_productid, p_quantity);
        
        -- Update order amount
        SELECT Amount INTO current_amount FROM Orders WHERE OrderNo = p_orderid;
        UPDATE Orders 
        SET Amount = current_amount + (product_price * p_quantity)
        WHERE OrderNo = p_orderid;
        
        SET p_success = TRUE;
    ELSE
        SET p_success = FALSE;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckStock` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckStock`(IN prod_id INT, IN qty INT, OUT available BOOLEAN)
BEGIN
    DECLARE total_qty INT DEFAULT 0;
    
    -- Get the total quantity across all branches
    SELECT SUM(bi.Quantity) INTO total_qty
    FROM Product p
    JOIN Branch_Inventory bi ON p.InventoryID = bi.InventoryID
    WHERE p.PID = prod_id;
    
    -- Set the output parameter
    IF total_qty >= qty THEN
        SET available = TRUE;
    ELSE
        SET available = FALSE;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GenerateAdminReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateAdminReport`(OUT report_text TEXT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE u_id INT;
    DECLARE u_name VARCHAR(100);
    DECLARE order_count INT;
    DECLARE result TEXT DEFAULT '';
    
    DECLARE cur CURSOR FOR 
        SELECT u.userID, u.Name, COUNT(o.OrderNo) as OrderCount
        FROM Users u
        LEFT JOIN Orders o ON u.userID = o.userID
        GROUP BY u.userID;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO u_id, u_name, order_count;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET result = CONCAT(result, 'User ID: ', u_id, ', Name: ', u_name, ', Orders: ', order_count, '\n');
    END LOOP;
    
    CLOSE cur;
    SET report_text = result;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PlaceOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PlaceOrder`(
    IN p_userid INT,
    IN p_amount DECIMAL(10,2),
    IN p_address VARCHAR(200),
    IN p_city VARCHAR(100),
    IN p_street VARCHAR(100),
    IN p_country VARCHAR(100),
    IN p_pincode VARCHAR(20),
    IN p_recipient VARCHAR(100),
    OUT p_orderid INT
)
BEGIN
    DECLARE delivery_id INT;
    DECLARE emp_id INT;
    
    -- Get a random employee to prepare the order
    SELECT EID INTO emp_id FROM Employee ORDER BY RAND() LIMIT 1;
    
    -- Create delivery record
    INSERT INTO Delivery (Address, City, Street, Country, PinCode, RecipientName)
    VALUES (p_address, p_city, p_street, p_country, p_pincode, p_recipient);
    SET delivery_id = LAST_INSERT_ID();
    
    -- Create order
    INSERT INTO Orders (Date, Amount, userID, EmployeeID, DeliveryID)
    VALUES (CURDATE(), p_amount, p_userid, emp_id, delivery_id);
    SET p_orderid = LAST_INSERT_ID();
    
    -- Create invoice
    INSERT INTO Invoice (OrderNo, InvoiceDate)
    VALUES (p_orderid, CURDATE());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-23 23:06:20
