DROP SCHEMA IF EXISTS ds CASCADE;
CREATE SCHEMA ds;

-- курсы валют
CREATE TABLE DS.MD_EXCHANGE_RATE_D (
	data_actual_date date NOT NULL,
	data_actual_end_date date,
	currency_rk int NOT NULL,
	reduced_cource float,
	code_iso_num VARCHAR(3),
	PRIMARY KEY (data_actual_date, currency_rk)
	);

-- остатки средств на счетах
CREATE TABLE DS.FT_BALANCE_F (
	on_date date NOT NULL,
	account_rk int NOT NULL,
	currency_rk int,
	balance_out float,
	PRIMARY KEY (on_date, account_rk)
	);

-- проводки (движения средств) по счетам
CREATE TABLE DS.FT_POSTING_F (
	oper_date date NOT NULL,
	credit_account_rk int NOT NULL,
	debet_account_rk int NOT NULL,
	credit_amount float,
	debet_amount float,
	PRIMARY KEY (oper_date, credit_account_rk, debet_account_rk)
	);

-- информация о счетах клиентов
CREATE TABLE DS.MD_ACCOUNT_D (
	data_actual_date date NOT NULL,
	data_actual_end_date date NOT NULL,
	account_rk int NOT NULL,
	account_number VARCHAR(20) NOT NULL,
	char_type VARCHAR(1) NOT NULL,
	currency_rk int NOT NULL,
	currency_code VARCHAR(3) NOT NULL,
	PRIMARY KEY (data_actual_date, account_rk)
	);

-- справочник валют
CREATE TABLE DS.md_currency_d (
	currency_rk int NOT NULL,
	data_actual_date date NOT NULL,
	data_actual_end_date date,
	currency_code VARCHAR(3),
	code_iso_char VARCHAR(3)
	);

-- справочник балансовых счётов
CREATE TABLE DS.MD_LEDGER_ACCOUNT_S (
	chapter VARCHAR(1),
	chapter_name VARCHAR(16),
	section_number int,
	section_name VARCHAR(22),
	subsection_name VARCHAR(21),
	ledger1_account int,
	ledger1_account_name VARCHAR(47),
	ledger_account int NOT NULL,
	ledger_account_name VARCHAR(153),
	characteristic VARCHAR(1),
	is_resident int,
	is_reserve int,
	is_reserved int,
	is_loan int,
	is_reserved_assets int,
	is_overdue int,
	is_interest int,
	pair_account VARCHAR(5),
	start_date date NOT NULL,
	end_date date,
	is_rub_only int,
	min_term VARCHAR(1),
	min_term_measure VARCHAR(1),
	max_term VARCHAR(1),
	max_term_measure VARCHAR(1),
	ledger_acc_full_name_translit VARCHAR(1),
	is_revaluation VARCHAR(1),
	is_correct VARCHAR(1),
	PRIMARY KEY (ledger_account, start_date)
	);

--------------------------------------------
DROP SCHEMA IF EXISTS logs CASCADE;
CREATE SCHEMA logs;

CREATE TABLE logs.data_upload_log (
	table_name varchar NOT NULL,
	datetime timestamp NOT NULL,
	process_status varchar NOT NULL,
	rows_count int,
	upload_status varchar
	)