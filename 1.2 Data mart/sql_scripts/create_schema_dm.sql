DROP SCHEMA IF EXISTS dm CASCADE;
CREATE SCHEMA dm;

-- таблица оборотов
CREATE TABLE DM.DM_ACCOUNT_TURNOVER_F (
	oper_date date,
	acct_num VARCHAR(20),
	deb_turnover_rub float,
	cre_turnover_rub float,
	PRIMARY KEY (oper_date, acct_num)
	);

-- Таблица 101-й отчётной формы 
CREATE TABLE DM.DM_F101_ROUND_F (
	REGN numeric(4) NOT NULL, -- Регистрационный номер кредитной организации
	PLAN varchar(1) NOT NULL CHECK (PLAN IN ('А','Б','В','Г')), -- Глава Плана счетов бухгалтерского учета в кредитных организациях: (А – балансовые счета;Б – счета доверительного управления; В – внебалансовые счета;Г – срочные операции)
	NUM_SC varchar(5) NOT NULL, -- Номер счета второго порядка по Плану счетов бухгалтерского учета
	A_P numeric(1) NOT NULL CHECK (A_P=1 OR A_P=2), -- Признак счета:1 – счет активный; 2 – счет пассивный
	VR numeric(16) NOT NULL, -- Входящие остатки «в рублях», тыс. руб
	VV numeric(16) NOT NULL, -- Входящие остатки «ин. вал., драг.металлы», тыс. руб.
	VITG numeric(33) NOT NULL, -- Входящие остатки «итого», тыс. руб
	ORA numeric(16) NOT NULL, -- Обороты за отчетный период по дебету (активу) «в рублях», тыс. руб.
	OVA numeric(16) NOT NULL, -- Обороты за отчетный период по дебету (активу) «ин. вал., драг. металлы», тыс. руб.
	OITGA numeric(33) NOT NULL, -- Обороты за отчетный период по дебету (активу) «итого», тыс. руб.
	ORP numeric(16) NOT NULL, -- Обороты за отчетный период по кредиту (пассиву) «в рублях», тыс. руб.
	OVP numeric(16) NOT NULL, -- Обороты за отчетный период по кредиту (пассиву) «ин. вал., драг. металлы», тыс. руб.
	OITGP numeric(33) NOT NULL, -- Обороты за отчетный период по кредиту (пассиву) «итого», тыс. руб.
	IR numeric(16) NOT NULL, -- Исходящие остатки «в рублях», тыс. руб.
	IV numeric(16) NOT NULL, -- Исходящие остатки «ин. вал., драг. металлы», тыс. руб.
	IITG numeric(33) NOT NULL, -- Исходящие остатки «итого», тыс. руб.
	DT date NOT NULL, -- Отчетная дата, на которую составлена оборотная ведомость кредитной организации
	PRIZ numeric(1) NOT NULL DEFAULT(1) -- Признак категории раскрытия информации
	);