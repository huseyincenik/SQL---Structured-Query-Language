/*Charlie's Chocolate Factory company produces chocolates. The following product information is stored: product name, product ID, and quantity on hand. These chocolates are made up of many components. Each component can be supplied by one or more suppliers. The following component information is kept: component ID, name, description, quantity on hand, suppliers who supply them, when and how much they supplied, and products in which they are used. On the other hand following supplier information is stored: supplier ID, name, and activation status.

Assumptions

A supplier can exist without providing components.
A component does not have to be associated with a supplier. It may already have been in the inventory.
A component does not have to be associated with a product. Not all components are used in products.
A product cannot exist without components. 

Do the following exercises, using the data model.

     a) Create a database named "Manufacturer"

     b) Create the tables in the database.

     c) Define table constraints.*/

---Solution
--a) Create a database named "Manufacturer"
CREATE DATABASE Manufacturer;
USE Manufacturer
--Create Schemas

CREATE SCHEMA Product
GO
CREATE SCHEMA Component
GO

--b) Create the tables in the database.
CREATE TABLE Product.Product(
	prod_id INT,--prod_id INT IDENTITY(1, 1) PRIMARY KEY
	prod_name VARCHAR(50),--NOT NULL
	quantity INT --NOT NULL
);
CREATE TABLE Product.Prod_Comp(
	prod_id INT ,
	comp_id INT,
	quantity_comp INT --NOT NULL
	--PRIMARY KEY(prod_id, comp_id),
	--FOREIGN KEY(prod_id) REFERENCES product(prod_id) ON DELETE CASCADE ON UPDATE CASCADE,
	--FOREIGN KEY(comp_id) REFERENCES component(comp_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Component.Component(
	comp_id INT ,--NOT NULL,--comp_id INT IDENTITY(1, 1) PRIMARY KEY
	comp_name VARCHAR(50)  , --NOT NULL ,--A supplier can exist without providing components
	description VARCHAR(50),
	quantity_comp INT --NOT NULL
);
CREATE TABLE Component.Comp_Supp(
	supp_id INT,--supp_id INT PRIMARY KEY --NOT NULL
	comp_id INT,--comp_id INT PRIMARY KEY --NOT NULL
	order_date DATE,
	quantity INT--NOT NULL
);
CREATE TABLE Component.Supplier(
	supp_id INT ,--NOT NULL,--supp_id INT PRIMARY KEY
	supp_name VARCHAR(50) ,--NOT NULL
	supp_location VARCHAR(50),
	supp_country VARCHAR(50),
	is_active BIT --NOT NULL

)

--- c) Define table constraints:

--for Product.Product table
ALTER TABLE Product.Product
ALTER COLUMN prod_id INT NOT NULL

ALTER TABLE Product.Product
ALTER COLUMN prod_name VARCHAR(50) NOT NULL

ALTER TABLE Product.Product
ALTER COLUMN quantity INT NOT NULL

ALTER TABLE Product.Product
ADD CONSTRAINT pk_product PRIMARY KEY(prod_id)

--for Component.Component table
ALTER TABLE Component.Component
ALTER COLUMN comp_id INT NOT NULL

ALTER TABLE Component.Component
ALTER COLUMN comp_name VARCHAR(50) NOT NULL

ALTER TABLE Component.Component
ALTER COLUMN quantity_comp INT NOT NULL

ALTER TABLE Component.Component
ADD CONSTRAINT pk_component PRIMARY KEY(comp_id)

--for Product.Prod_Comp table
ALTER TABLE Product.Prod_Comp
ALTER COLUMN quantity_comp INT NOT NULL

ALTER TABLE Product.Prod_Comp
ADD CONSTRAINT fk_prod_id FOREIGN KEY(prod_id) REFERENCES Product.Product(prod_id) ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE Product.Prod_Comp
ADD CONSTRAINT fk_comp_id FOREIGN KEY(comp_id) REFERENCES Component.Component(comp_id) ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE Product.Prod_Comp
ALTER COLUMN prod_id INT NOT NULL; 

ALTER TABLE Product.Prod_Comp
ALTER COLUMN comp_id INT NOT NULL; 

ALTER TABLE Product.Prod_Comp
ADD CONSTRAINT pk_comp_prod PRIMARY KEY (comp_id, prod_id);


--for Component.Supplier table
ALTER TABLE Component.Supplier
ALTER COLUMN supp_id INT NOT NULL

ALTER TABLE Component.Supplier
ALTER COLUMN supp_name VARCHAR(50) NOT NULL

ALTER TABLE Component.Supplier
ALTER COLUMN is_active BIT NOT NULL

ALTER TABLE Component.Supplier
ADD CONSTRAINT pk_supplier PRIMARY KEY(supp_id)

--for Component.Comp_Supp table
ALTER TABLE Component.Comp_Supp
ALTER COLUMN quantity INT NOT NULL

ALTER TABLE Component.Comp_Supp
ADD CONSTRAINT fk_supp_id FOREIGN KEY(supp_id) REFERENCES Component.Supplier(supp_id) ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE Component.Comp_Supp
ADD CONSTRAINT fk_comp_id FOREIGN KEY(comp_id) REFERENCES Component.Component(comp_id) ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE Component.Comp_Supp
ALTER COLUMN supp_id INT NOT NULL

ALTER TABLE Component.Comp_Supp
ALTER COLUMN comp_id INT NOT NULL

ALTER TABLE Component.Comp_Supp
ADD CONSTRAINT pk_supp_comp PRIMARY KEY (supp_id, comp_id)



