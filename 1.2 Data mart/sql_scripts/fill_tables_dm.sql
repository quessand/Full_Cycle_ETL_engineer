TRUNCATE TABLE DM.DM_ACCOUNT_TURNOVER_F;
INSERT INTO DM.DM_ACCOUNT_TURNOVER_F (oper_date,acct_num,deb_turnover_rub,cre_turnover_rub)
SELECT
	fpf.oper_date::date, 
	mad.account_number,
	ROUND(SUM(fpf.credit_amount::numeric),2),
	ROUND(SUM(fpf.debet_amount::numeric), 2)
FROM ds.ft_posting_f AS fpf
LEFT JOIN ds.md_account_d mad
	ON fpf.credit_account_rk = mad.account_rk
WHERE mad.account_number IS NOT NULL
GROUP BY fpf.oper_date, mad.account_number
ORDER BY fpf.oper_date
;

TRUNCATE TABLE dm.dm_f101_round_f;
WITH turnover_rub AS (
	SELECT
		debet_account_rk AS deb_acct_id,
		credit_amount AS cre_amt,
		debet_amount AS deb_amt,
		currency_code AS curr_id,
		coalesce(merd.reduced_cource, 1) AS curr_value,
		CASE WHEN currency_code = '643' THEN credit_amount ELSE 0 END AS turn_cre_rub,
		CASE WHEN currency_code = '643' THEN debet_amount ELSE 0 END AS turn_deb_rub,
		CASE WHEN currency_code <> '643' THEN credit_amount * coalesce(merd.reduced_cource, 1) ELSE 0 END AS turn_cre_curr,
		CASE WHEN currency_code <> '643' THEN debet_amount * coalesce(merd.reduced_cource, 1) ELSE 0 END AS turn_deb_curr
	FROM ds.ft_posting_f pos
	INNER JOIN ds.md_account_d mad
		ON pos.debet_account_rk = mad.account_rk
	LEFT JOIN ds.md_exchange_rate_d merd
		ON 
			mad.currency_rk = merd.currency_rk
			AND pos.oper_date >= merd.data_actual_date
			AND pos.oper_date <= merd.data_actual_end_date
),

balance_rub AS (
	SELECT 
		fbf.account_rk AS acct_id,
		fbf.balance_out AS bal,
		mcd.currency_code AS curr_id,
		coalesce(merd.reduced_cource, 1) AS curr_value,
		CASE WHEN mcd.currency_code = '643' THEN fbf.balance_out ELSE 0 END AS in_bal_rub,
		CASE WHEN mcd.currency_code <> '643' THEN fbf.balance_out * coalesce(merd.reduced_cource, 1) ELSE 0 END AS in_bal_curr
	FROM ds.ft_balance_f fbf
	LEFT JOIN ds.md_currency_d mcd
		ON fbf.currency_rk = mcd.currency_rk
	LEFT JOIN ds.md_exchange_rate_d merd
		ON 
			fbf.currency_rk = merd.currency_rk
			AND fbf.on_date >= merd.data_actual_date
			AND fbf.on_date <= merd.data_actual_end_date
),
			
ledger AS (
	SELECT
		mad.account_rk AS acct_id,
		mad.account_number AS acct_num,
		mlas.chapter,
		mlas.ledger_account,
		CASE WHEN mlas.characteristic = 'А' THEN 1 WHEN mlas.characteristic = 'П' THEN 2 ELSE 0 END AS acc_type
	FROM ds.md_account_d mad
	LEFT JOIN ds.md_ledger_account_s mlas
		ON LEFT(mad.account_number, 5)::int = mlas.ledger_account
),

values AS (
	SELECT
		br.acct_id,
		br.in_bal_rub,
		br.in_bal_curr,
		br.in_bal_rub + br.in_bal_curr AS in_bal_total,
		coalesce(agg.turn_deb_rub,0) AS turn_deb_rub,
		coalesce(agg.turn_cre_curr,0) AS turn_deb_curr,
		coalesce(agg.turn_deb_rub,0) + coalesce(agg.turn_deb_curr,0) AS turn_deb_total,
		coalesce(agg.turn_cre_rub,0) AS turn_cre_rub,
		coalesce(agg.turn_cre_curr,0) AS turn_cre_curr,
		coalesce(agg.turn_cre_rub,0) + coalesce(agg.turn_cre_curr,0) AS turn_cre_total,
		br.in_bal_rub - coalesce(agg.turn_cre_rub,0) + coalesce(agg.turn_deb_rub,0) AS out_bal_rub,
		br.in_bal_curr - coalesce(agg.turn_cre_curr,0) + coalesce(agg.turn_deb_curr,0) AS out_bal_curr,
		(br.in_bal_rub - coalesce(agg.turn_cre_rub,0) + coalesce(agg.turn_deb_rub,0)) + (br.in_bal_curr - coalesce(agg.turn_cre_curr,0) + coalesce(agg.turn_deb_curr,0)) AS out_bal_total
	FROM (
		SELECT 
			deb_acct_id, 
			SUM(turn_cre_rub) AS turn_cre_rub,
			SUM(turn_deb_rub) AS turn_deb_rub,
			SUM(turn_cre_curr) AS turn_cre_curr,
			SUM(turn_deb_curr) AS turn_deb_curr
		FROM turnover_rub
		GROUP BY deb_acct_id
		ORDER BY deb_acct_id
		) AS agg
	FULL JOIN balance_rub AS br
		ON agg.deb_acct_id = br.acct_id
	)

INSERT INTO dm.dm_f101_round_f (regn,plan,num_sc,a_p,vr,vv,vitg,ora,ova,oitga,orp,ovp,oitgp,ir,iv,iitg,dt)
SELECT
	9999 AS bank_id,
	subq.chapter,
	subq.ledger_account,
	subq.acc_type,
	subq.in_bal_rub,
	subq.in_bal_curr,
	subq.in_bal_total,
	subq.turn_deb_rub,
	subq.turn_deb_curr,
	subq.turn_deb_total,
	subq.turn_cre_rub,
	subq.turn_cre_curr,
	subq.turn_cre_total,
	subq.out_bal_rub,
	subq.out_bal_curr,
	subq.out_bal_total,
	'2024-01-01'::date AS dt
FROM (
	SELECT 
		ledger.chapter,
		ledger_account,
		ledger.acc_type,
		SUM(ROUND(in_bal_rub/1000)) AS in_bal_rub,
		SUM(ROUND(in_bal_curr/1000)) AS in_bal_curr,
		SUM(ROUND(in_bal_total/1000)) AS in_bal_total,
		SUM(ROUND(turn_deb_rub/1000)) AS turn_deb_rub,
		SUM(ROUND(turn_deb_curr/1000)) AS turn_deb_curr,
		SUM(ROUND(turn_deb_total/1000)) AS turn_deb_total,
		SUM(ROUND(turn_cre_rub/1000)) AS turn_cre_rub,
		SUM(ROUND(turn_cre_curr/1000)) AS turn_cre_curr,
		SUM(ROUND(turn_cre_total/1000)) AS turn_cre_total,
		SUM(ROUND(out_bal_rub/1000)) AS out_bal_rub,
		SUM(ROUND(out_bal_curr/1000)) AS out_bal_curr,
		SUM(ROUND(out_bal_total/1000)) AS out_bal_total
	FROM values
	LEFT JOIN ledger
		ON values.acct_id = ledger.acct_id
	GROUP BY ledger.chapter,ledger_account,ledger.acc_type
	) AS subq
