CREATE OR REPLACE TRIGGER check_service_number
BEFORE INSERT OR UPDATE OF hkid ON subscriptions
DECLARE
	i NUMBER(1):= 0;
	service_number_exceeded EXCEPTION
BEGIN
	FOR R IN (
		SELECT * FROM subscriptions
		)LOOP
			IF: NEW.hkid = R.hkid then
				i:= i + 1;
			END IF;
			IF: i >= 3
				RAISE 
		END LOOP;
EXCEPTION
	WHEN service_number_exceeded THEN
	
END;	
	
	
CREATE OR REPLACE TRIGGER check_unique_installation_address
BEFORE INSERT OR UPDATE OF installation address ON subscriptions
DECLARE
	installation_address_not_unique;
