CREATE TABLE customers (
	hkid VARCHAR2(8) PRIMARY KEY,
	name VARCHAR2(50)  NOT NULL, 
	phone_number VARCHAR2(20) NOT NULL,
	billing_address VARCHAR2(100) NOT NULL,
	payment_method VARCHAR2(8) NOT NULL
		CONSTRAINT invalid_method CHECK
			(payment_method = 'cash' OR
			 payment_method = 'auto-pay'),
	card_number VARCHAR2(20),
	card_owner VARCHAR2(50),
	card_expiry_date DATE	
	);

CREATE TABLE service_plans (
        plan_code VARCHAR2(4) PRIMARY KEY,
        name VARCHAR2(50) NOT NULL,
        service_type VARCHAR2(2) NOT NULL
		CONSTRAINT invalid_type CHECK
			(service_type = 'BB' OR
			 service_type = 'HT'),
        description VARCHAR2(100) NOT NULL,
        contract_period VARCHAR2(20) NOT NULL,
        monthly_fee VARCHAR2(10) NOT NULL
        );

CREATE TABLE subscriptions (
	subscription_id VARCHAR2(20) PRIMARY KEY,
	activation_data DATE NOT NULL,
	installation_address VARCHAR2(100) NOT NULL,
	hkid VARCHAR2(8) NOT NULL
		REFERENCES customers(hkid)
		ON DELETE CASCADE,
	plan_code VARCHAR2(4) NOT NULL
		REFERENCES service_plans(plan_code)
		ON DELETE CASCADE
		);
		
CREATE TABLE BB_plan_subscriptions (
	subscription_id VARCHAR2(20) PRIMARY KEY
		REFERENCES subscriptions(subscription_id)
		ON DELETE CASCADE,
	email VARCHAR2(30) NOT NULL
		CONSTRAINT email_unique UNIQUE,
	password VARCHAR2(20) NOT NULL
	);
	
CREATE TABLE HT_plan_subscriptions (
	subscription_id VARCHAR2(20) PRIMARY KEY
		REFERENCES subscriptions(subscription_id)
		ON DELETE CASCADE,
	phone_number VARCHAR2(20) NOT NULL
		CONSTRAINT phone_unique UNIQUE
	);	
