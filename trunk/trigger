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



CREATE OR REPLACE TRIGGER check_unique_installation_address
BEFORE INSERT OR UPDATE OF installation address ON subscriptions
DECLARE
	installation_address_not_unique;
