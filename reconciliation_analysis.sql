-- 1. DROP EXISTING TABLES
DROP TABLE IF EXISTS responses;
DROP TABLE IF EXISTS invites;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS accounts;

-- 2. CREATE SCHEMA
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    account_name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE contacts (
    contact_id INT PRIMARY KEY,
    account_id INT,
    email VARCHAR(100),
    name VARCHAR(100)
);

CREATE TABLE invites (
    invite_id INT PRIMARY KEY,
    contact_id INT,
    sent_date DATE,
    status VARCHAR(20)
);

CREATE TABLE responses (
    response_id INT PRIMARY KEY,
    invite_id INT,
    score INT,
    submitted_date DATE
);

-- 3. SEED SYNTHETIC CRM & SURVEY DATA
INSERT INTO accounts VALUES 
(101, 'Alpha Broadband', 'APAC'),
(102, 'Beta Fiber Networks', 'APAC'),
(103, 'Gamma Telecom', 'EMEA'),
(104, 'Delta Communications', 'NA');

INSERT INTO contacts VALUES 
(1, 101, 'john.doe@alpha.com', 'John Doe'),
(2, 101, 'john.doe@alpha.com', 'John Doe (Duplicate)'),
(3, 102, 'sara.s@betafiber.com', 'Sara Smith'),
(4, NULL, 'orphan.user@unknown.com', 'Orphan User'),
(5, 103, 'alex.k@gammatel.com', 'Alex Kumar');

INSERT INTO invites VALUES 
(1001, 1, '2026-03-01', 'delivered'),
(1002, 2, '2026-03-02', 'bounced'),
(1003, 3, '2026-03-05', 'delivered'),
(1004, 5, '2026-03-10', 'sent');

INSERT INTO responses VALUES 
(5001, 1001, 10, '2026-03-02'),
(5002, 1003, 4,  '2026-03-06');

-- 4. ANALYTICS & RECONCILIATION QUERIES

-- Query A: Detect Duplicate Contacts by Email
SELECT email, COUNT(contact_id) AS record_count
FROM contacts
GROUP BY email
HAVING COUNT(contact_id) > 1;

-- Query B: Find Orphan Contacts (Missing Account Mapping)
SELECT c.contact_id, c.email, c.name
FROM contacts c
LEFT JOIN accounts a ON a.account_id = c.account_id
WHERE a.account_id IS NULL;

-- Query C: Account NPS Calculation
SELECT 
    a.account_name,
    ROUND(
        (100.0 * SUM(CASE WHEN r.score >= 9 THEN 1 ELSE 0 END) / COUNT(*)) -
        (100.0 * SUM(CASE WHEN r.score <= 6 THEN 1 ELSE 0 END) / COUNT(*)), 
    1) AS nps_score
FROM responses r
JOIN invites i ON i.invite_id = r.invite_id
JOIN contacts c ON c.contact_id = i.contact_id
JOIN accounts a ON a.account_id = c.account_id
GROUP BY a.account_name;
-- Query D: Survey Funnel (invites -> delivered -> responses)
SELECT
  COUNT(*) AS invites_sent,
  SUM(CASE WHEN i.status = 'delivered' THEN 1 ELSE 0 END) AS delivered,
  COUNT(r.response_id) AS responses,
  ROUND(100.0 * COUNT(r.response_id) /
        NULLIF(SUM(CASE WHEN i.status = 'delivered' THEN 1 ELSE 0 END), 0), 1) AS response_rate_pct
FROM invites i
LEFT JOIN responses r ON r.invite_id = i.invite_id;
