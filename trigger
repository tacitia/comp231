CREATE OR REPLACE TRIGGER check_service_MaxNum
BEFORE INSERT OR UPDATE OF hkid ON subscriptions
DECLARE
	i NUMBER(1):= 0;
	service_number_exceeded EXCEPTION;
BEGIN
	FOR R IN (
		SELECT * FROM subscriptions
		)LOOP
			IF :NEW.hkid = R.hkid THEN
				i:= i + 1;
			END IF;
			IF i >= 3
				RAISE  service_number_exceeded;
			END IF;
		END LOOP;
EXCEPTION
	WHEN service_number_exceeded THEN
	DBMS_OUTPUT.PUT_LINE('Each customer can only subscribe at most three service plans!');
END;
/


CREATE OR REPLACE TRIGGER check_service_MinNum
BEFORE INSERT OR UPDATE hkid ON customers
DECLARE
	i NUMBER(1):= 0;
	hasSubscription BOOLEAN:= FALSE;
	no_service EXCEPTION;
BEGIN
	FOR R IN (
		SELECT * FROM subscriptions
		)LOOP
			IF :NEW.hkid = R.hkid then
				hasSubscription = TRUE;
			END IF;
		END LOOP;
	IF hasSubscription = FALSE THEN
		RAISE no_service;
	END IF;
EXCEPTION
	WHEN no_service THEN
	DBMS_OUTPUT.PUT_LINE('Each customer need to subscribe at least one service plan!');
END;
/


//What if the installation address of an update is the same as the old one?
CREATE OR REPLACE TRIGGER check_unique_installation_address
BEFORE INSERT OR UPDATE OF installation address ON subscriptions
DECLARE
	installation_address_not_unique;
BEGIN
	FOR R IN (
		SELECT * FROM subscriptions
		)LOOP
			IF :NEW.installation_address = R.installation_address THEN
				IF EXISTS (
					SELECT * FROM BB_plan_subscriptions
					WHERE subscription_id = R.subscription_id
					) THEN
					RAISE installation_address_not_unique;
				END IF;
			END IF;
		END LOOP;
EXCEPTION
	WHEN installation_address_not_unique THEN
	DBMS_OUTPUT.PUT_LINE('BB subscription installation address already exists');
END;
/


//What will happen during update?
CREATE OR REPLACE TRIGGER check_credit_card_info
AFTER INSERT OR UPDATE OF payment_meghod ON customers
DECLARE
	missing_credit_card_info;
BEGIN
	IF :NEW.payment_method = 'auto-pay' THEN
		IF (
			:NEW.card_number = NULL OR
			:NEW.card_owner = NULL OR
			:NEW.card_expiry_date = NULL
			) THEN 
			RAISE missing_credit_card_info;
		END IF;
	END IF;
EXCEPTION
	WHEN missing_credit_card_info;
	DBMS_OUTPUT.PUT_LINE('Missing credit card information');
END;
/


CREATE OR REPLACE TRIGGER BB_subscription_delete_cascade
BEFORE DELETE ON BB_plan_subscriptions
FOR EACH ROW
BEGIN
	DELETE FROM subscriptions
	WHERE subscription_id = :OLD.subscription_id;
END;
/


CREATE OR REPLACE TRIGGER HT_subscription_delete_cascade
BEFORE DELETE ON HT_plan_subscriptions
FOR EACH ROW
BEGIN
	DELETE FROM subscriptions
	WHERE subscription_id = :OLD.subscription_id;
END;
/