--need to include fine dates as a filter. Fine date is not yet in snapshot.

--WITH parameters AS (
--	SELECT
--		/* Choose a start and end date for the fines period */
--       '2000-01-01' :: DATE AS start_date,
--       '2021-01-01' :: DATE AS end_date,

SELECT  
-- DATE RANGE
--	fine_account_id,
--    fee_fine_id,
    owner_id, 
    fee_fine_owner,
--    material_type,
--    payment_status,
    patron_group_id,
    patron_group_name,
    fee_fine_type,
  --fine_date,
	sum(transaction_amount) AS fine_amount_paid,
	sum(fine_account_amount) AS original_fine_amount,
	sum(account_balance) AS fine_account_balance
FROM local.vandanashah_feesfines_accounts_actions 
--WHERE fine_date >= (SELECT start_date FROM parameters)
--  AND fine_date <  (SELECT end_date FROM parameters)  
GROUP BY
-- 	fine_account_id,
-- 	fee_fine_id,
 	owner_id,
 	fee_fine_owner,
-- 	material_type,
-- 	payment_status,
 	patron_group_id,
 	patron_group_name,
 	fee_fine_type
    ;


