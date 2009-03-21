CREATE OR REPLACE TRIGGER check_service_MaxNum
BEFORE INSERT OR UPDATE OF hkid ON subscriptions
FOR EACH ROW
DECLARE
	i NUMBER(1):= 0;
BEGIN
	FOR R IN (
		SELECT * FROM subscriptions
		)LOOP
			IF :NEW.hkid = R.hkid THEN
				i:= i + 1;
			END IF;
			IF i >= 3 THEN
				raise_application_error(-20000, 'Each customer can only subscribe at most three service plans!');
			END IF;
		END LOOP;
END;
/

CREATE OR REPLACE TRIGGER check_unique_BB_address
BEFORE INSERT OR UPDATE OF installation_address ON subscriptions
FOR EACH ROW
DECLARE
	newRecordID VARCHAR2(20):= :NEW.subscription_id;
	CURSOR BBcursor IS
		SELECT * FROM BB_plan_subscriptions
		WHERE subscription_id = newRecordID;
BEGIN
	IF :NEW.installation_address <> :OLD.installation_address THEN 
		OPEN BBcursor;
		LOOP
			EXIT WHEN BBcursor%NOTFOUND;
			raise_application_error(-20001, 'BB subscription installation address already exists');
		END LOOP;
		CLOSE BBcursor;
	END IF;
END;
/

CREATE OR REPLACE TRIGGER check_credit_card_info
BEFORE INSERT OR UPDATE OF payment_method, card_number, card_owner, card_expiry_date ON customers
FOR EACH ROW
BEGIN
	IF :NEW.payment_method = 'auto-pay' THEN
		IF (
		:NEW.card_number = NULL OR
		:NEW.card_owner = NULL OR
		:NEW.card_expiry_date = NULL
		) THEN 
			raise_application_error(-20002, 'Missing credit card information');
		END IF;
	END IF;
	IF :NEW.payment_method = 'cash' THEN
		IF (
		:NEW.card_number <> NULL OR
		:NEW.card_owner <> NULL OR
		:NEW.card_expiry_date <> NULL
		) THEN
			raise_application_error(-20003, 'Extra card_number, card_owner and card_expiry_date information for cash payment');
		END IF;
	END IF;
END;
/

CREATE OR REPLACE TRIGGER check_BB_type
BEFORE INSERT OR UPDATE OF subscription_id ON  BB_plan_subscriptions
FOR EACH ROW
DECLARE
	newBBID VARCHAR2(20):= :NEW.subscription_id;
	HTID SUBSCRIPTIONS.SUBSCRIPTION_ID%TYPE;
	CURSOR HTcursor IS
		SELECT subscription_id FROM service_plans NATURAL JOIN subscriptions
		WHERE service_plans.service_type = 'HT';
BEGIN
	OPEN HTcursor;
	LOOP
		EXIT WHEN HTcursor%NOTFOUND;
		FETCH HTcursor INTO HTID;
		IF HTID = newBBID THEN
			raise_application_error(-20004, 'Subscription type is mismached with service type in service plan');
		END IF;
	END LOOP;
	CLOSE HTcursor;
END;
/

CREATE OR REPLACE TRIGGER check_HT_type
BEFORE INSERT OR UPDATE OF subscription_id ON  HT_plan_subscriptions
FOR EACH ROW
DECLARE
	newHTID VARCHAR2(20):= :NEW.subscription_id;
	BBID SUBSCRIPTIONS.SUBSCRIPTION_ID%TYPE;
	CURSOR BBcursor IS
		SELECT subscription_id FROM service_plans NATURAL JOIN subscriptions
		WHERE service_plans.service_type = 'BB';
BEGIN
	OPEN BBcursor;
	LOOP
		EXIT WHEN BBcursor%NOTFOUND;
		FETCH BBcursor INTO BBID;
		IF BBID = newHTID THEN
			raise_application_error(-20004, 'Subscription type is mismached with service type in service plan');
		END IF;
	END LOOP;
	CLOSE BBcursor;
END;
/

CREATE OR REPLACE TRIGGER hkid_update_cascade
AFTER UPDATE OF hkid ON customers
FOR EACH ROW
BEGIN
	UPDATE subscriptions 
	SET hkid = :NEW.hkid
	WHERE hkid = :OLD.hkid;
END;
/

CREATE OR REPLACE TRIGGER subscription_id_update_cascade
AFTER UPDATE OF subscription_id ON subscriptions
FOR EACH ROW
BEGIN
	UPDATE BB_plan_subscriptions 
	SET subscription_id = :NEW.subscription_id
	WHERE subscription_id = :OLD.subscription_id;
	UPDATE HT_plan_subscriptions
	SET subscription_id = :NEW.subscription_id
	WHERE subscription_id = :OLD.subscription_id;
END;
/

CREATE OR REPLACE TRIGGER plan_code_update_cascade
AFTER UPDATE OF plan_code ON service_plans
FOR EACH ROW
BEGIN
	UPDATE subscriptions
	SET plan_code = :NEW.plan_code
	WHERE plan_code = :OLD.plan_code;
END;
/

