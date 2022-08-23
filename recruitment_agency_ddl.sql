-- CREATE DATABASE "recruitment_agency"
-- WITH OWNER postgres;
-- COMMENT ON DATABASE "recruitment_agency" IS 'Database for DDL Homework. Recruitment Agency';

-- CREATE SCHEMA "recruitment_agency";
-- COMMENT ON SCHEMA "recruitment_agency" IS 'Separate schema for Agency data';
-- ALTER SCHEMA "recruitment_agency" OWNER TO postgres;

-- SET SEARCH_PATH TO AVOID SCHEMA NAMES BEFORE OBJECTS:
SET SEARCH_PATH TO "recruitment_agency";

-- !! NOTE !! : Nearly all tables contain "last_updated_at" column.
--              This column is used to track the datetime of a change in any record.
--              For example: When a candidate updates his document to new url, "last_updated_at" columns is updated too.
--              While using UPDATE command, developers must explicitly set "last_updated_at" to current_date() or now().
--              We might also later create a trigger for such purposes.


-- CANDIDATE -----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "employment_status"
(
    "employment_status_id" smallint generated always as identity (start with 1 increment by 1),
    "employment_status"    varchar(100) not null unique,
    --PK CONSTRAINT:
    CONSTRAINT "PK_employment_status" PRIMARY KEY ("employment_status_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "employment_status" IS 'Table to store employment statuses each candidate of the agency might have';


CREATE TABLE IF NOT EXISTS "candidate_status"
(
    "candidate_status_id" smallint generated always as identity (start with 1 increment by 1),
    "candidate_status"    varchar(100) not null unique,
    --PK CONSTRAINT:
    CONSTRAINT "PK_candidate_status" PRIMARY KEY ("candidate_status_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "candidate_status" IS 'Table to store condition statuses each candidate of the agency might have';


CREATE TABLE IF NOT EXISTS "candidate"
(
    "candidate_id"         int generated always as identity (start with 1 increment by 1),
    "first_name"           varchar(100) not null,
    "last_name"            varchar(100) not null,
    "email"                varchar(100) not null unique,
    "phone"                varchar(100) not null unique,
    "details"              text         not null default 'no details provided',
    "employment_status_id" smallint     not null,
    "candidate_status_id"  smallint     not null,
    "last_updated_at"      timestamp    not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_candidate" PRIMARY KEY ("candidate_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_candidate.employment_status" FOREIGN KEY ("employment_status_id") REFERENCES "employment_status" ("employment_status_id"),
    CONSTRAINT "FK_candidate.candidate_status" FOREIGN KEY ("candidate_status_id") REFERENCES "candidate_status" ("candidate_status_id"),
    -- VALIDATE EMAIL:
    CONSTRAINT "CHECK_candidate_email" CHECK ("email" ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    -- VALIDATE PHONE NUMBER TO CONTAIN DIGITS ONLY:
    CONSTRAINT "CHECK_candidate_phone_number" CHECK ("phone" ~ '^\d*$')

);
-- TABLE COMMENTS:
COMMENT ON TABLE "candidate" IS 'Table to store data of all candidates of the agency';
-- INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_candidate_employment_status_id" ON "candidate" ("employment_status_id");
CREATE INDEX IF NOT EXISTS "idx_candidate_candidate_status_id" ON "candidate" ("candidate_status_id");


CREATE TABLE IF NOT EXISTS "document_type"
(
    "document_type_id" smallint generated always as identity (start with 1 increment by 1),
    "document_type"    varchar(100) not null unique,
    --PK CONSTRAINT:
    CONSTRAINT "PK_document_type" PRIMARY KEY ("document_type_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "document_type" IS 'Table to store document types';


CREATE TABLE IF NOT EXISTS "candidate_document"
(
    "candidate_document_id" int generated always as identity (start with 1 increment by 1),
    "candidate_id"          int          not null,
    "document_name"         varchar(100) not null,
    "document_type_id"      smallint     not null,
    "document_url"          text         not null,
    "last_updated_at"       timestamp    not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_candidate_document" PRIMARY KEY ("candidate_document_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_candidate_document.candidate_id" FOREIGN KEY ("candidate_id") REFERENCES "candidate" ("candidate_id"),
    CONSTRAINT "FK_candidate_document.document_type_id" FOREIGN KEY ("document_type_id") REFERENCES "document_type" ("document_type_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "candidate_document" IS 'Table to store documents each candidate of the agency might have';
-- CREATE INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_candidate_document_candidate_id" ON "candidate_document" ("candidate_id");
CREATE INDEX IF NOT EXISTS "idx_candidate_document_document_type_id" ON "candidate_document" ("document_type_id");


CREATE TABLE IF NOT EXISTS "skill"
(
    "skill_id" int generated always as identity (start with 1 increment by 1),
    "skill"    varchar(100) not null unique,
    --PK CONSTRAINT:
    CONSTRAINT "PK_skill" PRIMARY KEY ("skill_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "skill" IS 'Table to store all possible skills';


CREATE TABLE IF NOT EXISTS "candidate_skill"
(
    "candidate_id" int not null,
    "skill_id"     int not null,
    --PK CONSTRAINT:
    CONSTRAINT "PK_candidate_skill" PRIMARY KEY ("candidate_id", "skill_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_candidate_skill.candidate_id" FOREIGN KEY ("candidate_id") REFERENCES "candidate" ("candidate_id"),
    CONSTRAINT "FK_candidate_skill.skill_id" FOREIGN KEY ("skill_id") REFERENCES "skill" ("skill_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "candidate_skill" IS 'Table used to link the skills to candidates';
-- CREATE INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_candidate_skill_candidate_id" ON "candidate_skill" ("candidate_id");
CREATE INDEX IF NOT EXISTS "idx_candidate_skill_skill_id" ON "candidate_skill" ("skill_id");


CREATE TABLE IF NOT EXISTS "education_type"
(
    "education_type_id" smallint generated always as identity (start with 1 increment by 1),
    "education_type"    varchar(100) not null unique,
    --PK CONSTRAINT:
    CONSTRAINT "PK_education_type" PRIMARY KEY ("education_type_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "education_type" IS 'Table to store all possible education types';


CREATE TABLE IF NOT EXISTS "institution"
(
    "institution_id"  int generated always as identity (start with 1 increment by 1),
    "name"            varchar(100) not null unique,
    "description"     text,
    "phone_number"    varchar(100) not null unique,
    "email"           varchar(100) not null unique,
    "homepage_url"    text         not null,
    "address"         varchar(255) not null,
    "last_updated_at" timestamp    not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_institution" PRIMARY KEY ("institution_id"),
    -- VALIDATE PHONE NUMBER TO CONTAIN DIGITS ONLY:
    CONSTRAINT "CHECK_institution_phone_number" CHECK ("phone_number" ~ '^\d*$'),
    -- VALIDATE EMAIL:
    CONSTRAINT "CHECK_institution_email" CHECK ("email" ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);
-- TABLE COMMENTS:
COMMENT ON TABLE "institution" IS 'Table to store all education institutions that each candidate of the agency might have studied at';


CREATE TABLE IF NOT EXISTS "education"
(
    "education_id"      int generated always as identity (start with 1 increment by 1),
    "candidate_id"      int       not null,
    "institution_id"    int       not null,
    "education_type_id" smallint  not null,
    "start_date"        date      not null,
    "graduation_date"   date,
    "details"           text      not null default 'no details were provided',
    "last_updated_at"   timestamp not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_education" PRIMARY KEY ("education_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_education.candidate_id" FOREIGN KEY ("candidate_id") REFERENCES "candidate" ("candidate_id"),
    CONSTRAINT "FK_education.institution_id" FOREIGN KEY ("institution_id") REFERENCES "institution" ("institution_id"),
    CONSTRAINT "FK_education.education_type_id" FOREIGN KEY ("education_type_id") REFERENCES "education_type" ("education_type_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "education" IS 'Table used to store education of each candidate';
-- CREATE INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_education_candidate_id" ON "education" ("candidate_id");
CREATE INDEX IF NOT EXISTS "idx_education_institution_id" ON "education" ("institution_id");
CREATE INDEX IF NOT EXISTS "idx_education_education_type_id" ON "education" ("education_type_id");


-- DML DATA INSERTS (Candidate): ---------------------------------------------------------------------------------------

-- "employment_status" does not depend on candidate and will be filled beforehand:
INSERT INTO "employment_status"(employment_status)
VALUES ('UNEMPLOYED'), ('EMPLOYED'), ('EMPLOYED PART-TIME'), ('HIRED BY CLIENT ORGANIZATION');

-- "candidate_status" does not depend on candidate and will be filled beforehand:
INSERT INTO "candidate_status"(candidate_status)
VALUES ('NOT UNDER CONSIDERATION'), ('UNDER CONSIDERATION'), ('HIRED'), ('NOT HIRED');

-- "document_type" does not depend on candidate and will be filled beforehand:
INSERT INTO "document_type"(document_type)
VALUES ('PASSPORT'), ('CV'), ('COVER LETTER'), ('CERTIFICATE');

-- "skill" does not depend on candidate and will be filled beforehand:
INSERT INTO "skill"(skill)
VALUES ('Python'), ('IOS'), ('SQL'), ('Electial Engineering'), ('STATISTICS'), ('LEADERSHIP'), ('TRELLO');

-- "education_type" does not depend on candidate and will be filled beforehand:
INSERT INTO "education_type"(education_type)
VALUES ('HIGH SCHOOL'),('BACHELORS'),('MASTERS'),('PHD'),('ASSOCIATE'),('PURSUING DEGREE');

-- "institution" does not depend on candidate and will be filled beforehand:
-- While creating a profile, candidate will chose the options from the provided list of institutions:
INSERT INTO "institution"(name, description, phone_number, email, homepage_url, address)
VALUES ('INHA University in Tashkent',
        'Inha University in Tashkent or IUT is a branch of Korean Inha University in Tashkent, Uzbekistan',
        '998712899999',
        'info@inha.uz',
        'https://inha.uz/',
        '9, Ziyolilar str., M.Ulugbek district, 100170 Tashkent, Uzbekistan'
        ),
       ('Academic lyceum "International House Tashkent"',
        'In 1987, in cooperation with the leadership and teachers of the Tashkent Institute of ' ||
        'Irrigation and Agricultural Mechanization Engineers, an academic lyceum was founded ' ||
        'on the basis of the 142nd secondary school',
        '998712373170',
        'contact@iht.uz',
        'http://iht.uz/en/home/',
        'Kari Niyazov, 39 Tashkent'
        );


-- NEW CANDIDATE CREATING SCENARIO (Kamoliddin):

-- First we create a record for the candidate in "candidate" table and store the candidate_id in cte:
-- We set "candidate_status" to "NOT UNDER CONSIDERATION" for the time of creation of the records.
WITH cte_candidate AS (
    INSERT INTO "candidate" (first_name, last_name, email, phone, details, employment_status_id, candidate_status_id)
        SELECT 'Kamoliddin',
               'Nabijonov',
               'nabijonovkamol@gmail.com',
               '998935539555',
               'Senior student at Inha University and a DBA in banking industry',
               (select employment_status_id from employment_status where employment_status = 'EMPLOYED PART-TIME'),
               (select candidate_status_id from candidate_status where candidate_status = 'NOT UNDER CONSIDERATION')
        WHERE NOT EXISTS(select 1
                         from candidate
                         where first_name = 'Kamoliddin'
                           and last_name = 'Nabijonov'
                           and email = 'nabijonovkamol@gmail.com'
                           and phone = '998935539555')
        RETURNING candidate_id
),
-- We then create a record for candidate's documents and store them in "candidate_document" table:
cte_document AS (
    INSERT INTO "candidate_document" (candidate_id, document_name, document_type_id, document_url)
        SELECT cc.candidate_id,
               'Nabijonov_CV',
               (select document_type_id from document_type where document_type = 'CV'),
               'https://www.cakeresume.com/kamol-nabijonov'
        FROM cte_candidate cc
        WHERE NOT EXISTS(select 1
                         from candidate_document
                         where candidate_id = cc.candidate_id
                           and document_name = 'Nabijonov_CV'
                           and document_url = 'https://www.cakeresume.com/kamol-nabijonov')
    RETURNING candidate_document_id, candidate_id
),
-- We then create records for all skills that the candidate has and store them in "candidate_skill" table:
-- Note that I have used CROSS JOIN to insert multiple selected skills for the candidate.
cte_candidate_skill AS (
    INSERT INTO "candidate_skill"(candidate_id, skill_id)
    SELECT cc.candidate_id, skl.skill_id
    FROM cte_candidate cc
    CROSS JOIN (select skill_id from "skill" where lower(skill) in ('python', 'sql')) skl
    WHERE NOT EXISTS(select 1 from candidate_skill where candidate_id = cc.candidate_id and skill_id = skl.skill_id)
    RETURNING candidate_id, skill_id
),
-- We then create records for candidate's education and store them in "education" table:
-- Note that I have used CROSS JOIN to insert multiple records of education for the candidate.
cte_education AS (
    INSERT INTO "education" (candidate_id, institution_id, education_type_id, start_date, graduation_date, details)
        SELECT cc.candidate_id,
               inst.institution_id,
               (select education_type_id from education_type where education_type = 'PURSUING DEGREE'),
               to_date('2018-09-01', 'yyyy-mm-dd'),
               null,
               'In deans least for 3 years straight'
        FROM cte_candidate cc
                 CROSS JOIN (select institution_id
                             from institution
                             where lower(name) = 'inha university in tashkent') inst
        WHERE NOT EXISTS(select 1
                         from education
                         where candidate_id = cc.candidate_id
                           and institution_id = inst.institution_id
                           and education_type_id =
                               (select education_type_id from education_type where education_type = 'PURSUING DEGREE'))
        RETURNING education_id, candidate_id
)
-- SHOW ALL INSERTED RECORDS
SELECT *
FROM cte_candidate cc
INNER JOIN cte_document USING (candidate_id)
INNER JOIN cte_candidate_skill USING (candidate_id)
INNER JOIN cte_education USING (candidate_id);


-- NEW CANDIDATE CREATING SCENARIO (Zafar):

-- First we create a record for the candidate in "candidate" table and store the candidate_id in cte:
-- We set "candidate_status" to "NOT UNDER CONSIDERATION" for the time of creation of the records.
WITH cte_candidate AS (
    INSERT INTO "candidate" (first_name, last_name, email, phone, details, employment_status_id, candidate_status_id)
        SELECT 'Zafar',
               'Ivaev',
               'zivaev@mail.ru',
               '998946265215',
               '3 years as an ios developer in international projects',
               (select employment_status_id from employment_status where employment_status = 'EMPLOYED'),
               (select candidate_status_id from candidate_status where candidate_status = 'NOT UNDER CONSIDERATION')
        WHERE NOT EXISTS(select 1
                         from candidate
                         where first_name = 'Zafar'
                           and last_name = 'Ivaev'
                           and email = 'zivaev@mail.ru'
                           and phone = '998946265215')
        RETURNING candidate_id
),
-- We then create a record for candidate's documents and store them in "candidate_document" table:
cte_document AS (
    INSERT INTO "candidate_document" (candidate_id, document_name, document_type_id, document_url)
        SELECT cc.candidate_id,
               'Ivaev_Passport',
               (select document_type_id from document_type where document_type = 'PASSPORT'),
               'https://storage.kun.uz/source/6/H97krVyp9qph5qfsn1ea8r9Qrv1R48Xk.jpg'
        FROM cte_candidate cc
        WHERE NOT EXISTS(select 1
                         from candidate_document
                         where candidate_id = cc.candidate_id
                           and document_name = 'Ivaev_Passport'
                           and document_url = 'https://storage.kun.uz/source/6/H97krVyp9qph5qfsn1ea8r9Qrv1R48Xk.jpg')
    RETURNING candidate_document_id, candidate_id
),
-- We then create records for all skills that the candidate has and store them in "candidate_skill" table:
-- Note that I have used CROSS JOIN to insert multiple selected skills for the candidate.
cte_candidate_skill AS (
    INSERT INTO "candidate_skill"(candidate_id, skill_id)
    SELECT cc.candidate_id, skl.skill_id
    FROM cte_candidate cc
    CROSS JOIN (select skill_id from "skill" where lower(skill) in ('ios', 'statistics')) skl
    WHERE NOT EXISTS(select 1 from candidate_skill where candidate_id = cc.candidate_id and skill_id = skl.skill_id)
    RETURNING candidate_id, skill_id
),
-- We then create records for candidate's education and store them in "education" table:
-- Note that I have used CROSS JOIN to insert multiple records of education for the candidate.
cte_education AS (
    INSERT INTO "education" (candidate_id, institution_id, education_type_id, start_date, graduation_date)
        SELECT cc.candidate_id,
               inst.institution_id,
               (select education_type_id from education_type where education_type = 'BACHELORS'),
               to_date('2017-09-01', 'yyyy-mm-dd'),
               to_date('2021-09-01', 'yyyy-mm-dd')
        FROM cte_candidate cc
                 CROSS JOIN (select institution_id
                             from institution
                             where lower(name) = 'inha university in tashkent') inst
        WHERE NOT EXISTS(select 1
                         from education
                         where candidate_id = cc.candidate_id
                           and institution_id = inst.institution_id
                           and education_type_id =
                               (select education_type_id from education_type where education_type = 'BACHELORS'))
        RETURNING education_id, candidate_id
)
-- SHOW ALL INSERTED RECORDS
SELECT *
FROM cte_candidate cc
INNER JOIN cte_document USING (candidate_id)
INNER JOIN cte_candidate_skill USING (candidate_id)
INNER JOIN cte_education USING (candidate_id);
------------------------------------------------------------------------------------------------------------------------

-- "record_ts" COLUMNS -------------------------------------------------------------------------------------------------
ALTER TABLE "candidate_status" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "employment_status" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "candidate" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "document_type" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "candidate_document" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "skill" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "candidate_skill" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "education_type" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "institution" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "education" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
------------------------------------------------------------------------------------------------------------------------



-- RECRUITER -----------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "department"
(
    "department_id" smallint generated always as identity (start with 1 increment by 1),
    "department"    varchar(100) not null unique,
    --PK CONSTRAINT:
    CONSTRAINT "PK_department" PRIMARY KEY ("department_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "department" IS 'Table to store departments within agency';


CREATE TABLE IF NOT EXISTS "recruiter"
(
    "recruiter_id"    int generated always as identity (start with 1 increment by 1),
    "first_name"      varchar(100) not null,
    "last_name"       varchar(100) not null,
    "birth_date"      date         not null,
    "passport"        varchar(50)  not null unique,
    "profile_url"     text         not null,
    "address"         text,
    "department_id"   smallint     not null,
    "condition"       smallint     not null default 1,
    "date_begin"      date         not null,
    "date_end"        date,
    "last_updated_at" timestamp    not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_recruiter" PRIMARY KEY ("recruiter_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_recruiter.department_id" FOREIGN KEY ("department_id") REFERENCES "department" ("department_id"),
    --CHECK CONSTRAINTS:
    CONSTRAINT "CHECK_recruiter_condition" CHECK ("condition" in (0, 1))
);
-- TABLE COMMENTS:
COMMENT ON TABLE "recruiter" IS 'Table to store data of all recruiters working for the agency';
COMMENT ON COLUMN "recruiter"."condition" IS '0 - NONACTIVE, 1 - ACTIVE';
-- INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_recruiter_department_id" ON "recruiter" ("department_id");


CREATE TABLE IF NOT EXISTS "recruiter_phone"
(
    "recruiter_phone_id" int generated always as identity (start with 1 increment by 1),
    "recruiter_id"       int          not null,
    "phone"              varchar(100) not null unique,
    "type"               smallint     not null,
    --PK CONSTRAINT:
    CONSTRAINT "PK_recruiter_phone" PRIMARY KEY ("recruiter_phone_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_recruiter_phone.recruiter_id" FOREIGN KEY ("recruiter_id") REFERENCES "recruiter" ("recruiter_id"),
    -- VALIDATE PHONE NUMBER TO CONTAIN DIGITS ONLY:
    CONSTRAINT "CHECK_recruiter_phone" CHECK ("phone" ~ '^\d*$'),
    --CHECK CONSTRAINTS:
    CONSTRAINT "CHECK_recruiter_phone_type" CHECK ("type" in (1, 2))
);
-- TABLE COMMENTS:
COMMENT ON TABLE "recruiter_phone" IS 'Table to store all phone numbers of recruiters';
COMMENT ON COLUMN "recruiter_phone"."type" IS '1 - PERSONAL, 2 - WORK';
-- INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_recruiter_phone_recruiter_id" ON "recruiter_phone" ("recruiter_id");


CREATE TABLE IF NOT EXISTS "recruiter_email"
(
    "recruiter_email_id" int generated always as identity (start with 1 increment by 1),
    "recruiter_id"       int          not null,
    "email"              varchar(100) not null unique,
    "type"               smallint     not null,
    --PK CONSTRAINT:
    CONSTRAINT "PK_recruiter_email" PRIMARY KEY ("recruiter_email_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_recruiter_email.recruiter_id" FOREIGN KEY ("recruiter_id") REFERENCES "recruiter" ("recruiter_id"),
    --VALIDATE EMAIL:
    CONSTRAINT "CHECK_recruiter_email" CHECK ("email" ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    --CHECK CONSTRAINTS:
    CONSTRAINT "CHECK_recruiter_email_type" CHECK ("type" in (1, 2))
);
-- TABLE COMMENTS:
COMMENT ON TABLE "recruiter_email" IS 'Table to store all emails of recruiters';
COMMENT ON COLUMN "recruiter_email"."type" IS '1 - PERSONAL, 2 - WORK';
-- INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_recruiter_email_recruiter_id" ON "recruiter_email" ("recruiter_id");


-- DML DATA INSERTS (Recruiter): ---------------------------------------------------------------------------------------
INSERT INTO "department"(department)
VALUES ('IT'),
       ('HR'),
       ('ENGINEERING'),
       ('MARKETING'),
       ('FINANCE');


INSERT INTO recruiter (first_name, last_name, birth_date, passport, profile_url, address, department_id, condition,
                       date_begin, date_end)
SELECT 'Dildora',                                                                     -- first_name
       'Razakova',                                                                    -- last_name
       to_date('1997-01-10', 'yyyy-mm-dd'),                                           -- birth_date
       'AA12345678',                                                                  -- passport
       'https://www.linkedin.com/in/dildora-razakova-732029187?originalSubdomain=uz', -- profile_url
       '156 Usman Nasyr Str, Tashkent',                                               -- address
       (select department_id from department where department = 'FINANCE'),           -- department_id,
       0,                                                                             -- condition
       to_date('2020-05-01', 'yyyy-mm-dd'),                                           -- date_begin
       to_date('2021-11-01', 'yyyy-mm-dd')                                            -- date_end
WHERE NOT EXISTS(select 1
                 from recruiter
                 where first_name = 'Dildora'
                   and last_name = 'Razakova'
                   and passport = 'AA12345678'
                   and date_begin = to_date('2020-05-01', 'yyyy-mm-dd')
                   and department_id = (select department_id from department where department = 'FINANCE'));


INSERT INTO recruiter (first_name, last_name, birth_date, passport, profile_url, address, department_id, condition,
                       date_begin, date_end)
SELECT 'Vitaliy',                                                      -- first_name
       'Davidov',                                                      -- last_name
       to_date('1995-02-15', 'yyyy-mm-dd'),                            -- birth_date
       'AA22233444',                                                   -- passport
       'https://www.linkedin.com/in/vitaliy-davidov-0b1525178/',       -- profile_url
       'Uzbekistan, Tashkent, Yashnabad district, st. Makhtumkuli, 2', -- address
       (select department_id from department where department = 'IT'), -- department_id,
       1,                                                              -- condition
       to_date('2020-10-01', 'yyyy-mm-dd'),                            -- date_begin
       null                                                            -- date_end
WHERE NOT EXISTS(select 1
                 from recruiter
                 where first_name = 'Vitaliy'
                   and last_name = 'Davidov'
                   and passport = 'AA22233444'
                   and date_begin = to_date('2020-10-01', 'yyyy-mm-dd')
                   and department_id = (select department_id from department where department = 'IT'));


INSERT INTO recruiter_phone(RECRUITER_ID, PHONE, TYPE)
SELECT r.recruiter_id, '998934445566', 1
FROM recruiter r
WHERE r.first_name = 'Dildora' and r.last_name = 'Razakova' and r.passport = 'AA12345678'
AND NOT EXISTS(select 1 from recruiter_phone where recruiter_id = r.recruiter_id and phone = '998934445566');

INSERT INTO recruiter_phone(RECRUITER_ID, PHONE, TYPE)
SELECT r.recruiter_id, '998971111111', 2
FROM recruiter r
WHERE r.first_name = 'Dildora' and r.last_name = 'Razakova' and r.passport = 'AA12345678'
AND NOT EXISTS(select 1 from recruiter_phone where recruiter_id = r.recruiter_id and phone = '998971111111');

INSERT INTO recruiter_phone(RECRUITER_ID, PHONE, TYPE)
SELECT r.recruiter_id, '998937778899', 1
FROM recruiter r
WHERE r.first_name = 'Vitaliy' and r.last_name = 'Davidov' and r.passport = 'AA22233444'
AND NOT EXISTS(select 1 from recruiter_phone where recruiter_id = r.recruiter_id and phone = '998937778899');

INSERT INTO recruiter_phone(RECRUITER_ID, PHONE, TYPE)
SELECT r.recruiter_id, '998972222222', 2
FROM recruiter r
WHERE r.first_name = 'Vitaliy' and r.last_name = 'Davidov' and r.passport = 'AA22233444'
AND NOT EXISTS(select 1 from recruiter_phone where recruiter_id = r.recruiter_id and phone = '998972222222');


INSERT INTO recruiter_email(RECRUITER_ID, EMAIL, TYPE)
SELECT r.recruiter_id, 'dildorarazakova@gmail.com', 1
FROM recruiter r
WHERE r.first_name = 'Dildora' and r.last_name = 'Razakova' and r.passport = 'AA12345678'
AND NOT EXISTS(select 1 from recruiter_email where recruiter_id = r.recruiter_id and email = 'dildorarazakova@gmail.com');

INSERT INTO recruiter_email(RECRUITER_ID, EMAIL, TYPE)
SELECT r.recruiter_id, 'dildorarazakova@epam.com', 2
FROM recruiter r
WHERE r.first_name = 'Dildora' and r.last_name = 'Razakova' and r.passport = 'AA12345678'
AND NOT EXISTS(select 1 from recruiter_email where recruiter_id = r.recruiter_id and email = 'dildorarazakova@epam.com');

INSERT INTO recruiter_email(RECRUITER_ID, EMAIL, TYPE)
SELECT r.recruiter_id, 'vitaliydavidov@gmail.com', 1
FROM recruiter r
WHERE r.first_name = 'Vitaliy' and r.last_name = 'Davidov' and r.passport = 'AA22233444'
AND NOT EXISTS(select 1 from recruiter_email where recruiter_id = r.recruiter_id and email = 'vitaliydavidov@gmail.com');

INSERT INTO recruiter_email(RECRUITER_ID, EMAIL, TYPE)
SELECT r.recruiter_id, 'vitaliydavidov@epam.com', 2
FROM recruiter r
WHERE r.first_name = 'Vitaliy' and r.last_name = 'Davidov' and r.passport = 'AA22233444'
AND NOT EXISTS(select 1 from recruiter_email where recruiter_id = r.recruiter_id and email = 'vitaliydavidov@epam.com');
------------------------------------------------------------------------------------------------------------------------

-- "record_ts" COLUMNS -------------------------------------------------------------------------------------------------
ALTER TABLE "department" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "recruiter" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "recruiter_phone" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "recruiter_email" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
------------------------------------------------------------------------------------------------------------------------


set search_path to recruitment_agency;

-- ORGANIZATION & JOB --------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "organization"
(
    "organization_id"        int generated always as identity (start with 1 increment by 1),
    "name"                   varchar(100) not null unique,
    "description"            text,
    "inn"                    varchar(9)   not null unique,
    "email"                  varchar(100) not null unique,
    "address"                varchar(255) not null,
    "organization_condition" smallint     not null default 1,
    "last_updated_at"        timestamp    not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_organization" PRIMARY KEY ("organization_id"),
    -- VALIDATE INN TO CONTAIN DIGITS ONLY:
    CONSTRAINT "CHECK_organization_inn" CHECK ("inn" ~ '^\d*$'),
    -- VALIDATE EMAIL:
    CONSTRAINT "CHECK_organization_email" CHECK ("email" ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    --CHECK CONSTRAINTS:
    CONSTRAINT "CHECK_organization_condition" CHECK ("organization_condition" in (0, 1))
);
-- TABLE COMMENTS:
COMMENT ON TABLE "organization" IS 'Table to store data of all client organizations of the agency';
COMMENT ON COLUMN "organization"."organization_condition" IS '0 - NONACTIVE, 1 - ACTIVE';

-- Organization, provides managers to work with.
-- All such contacts are stored in this table
CREATE TABLE IF NOT EXISTS "organization_manager"
(
    "organization_manager_id" int generated always as identity (start with 1 increment by 1),
    "organization_id"         int          not null,
    "person_name"             varchar(255) not null,
    "person_email"            varchar(100) not null unique,
    "person_phone"            varchar(100) not null unique,
    "last_updated_at"         timestamp    not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_organization_manager" PRIMARY KEY ("organization_manager_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_organization_manager_id.organization_id" FOREIGN KEY ("organization_id") REFERENCES "organization" ("organization_id"),
    --VALIDATE EMAIL:
    CONSTRAINT "CHECK_person_email" CHECK ("person_email" ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    -- VALIDATE PHONE NUMBER TO CONTAIN DIGITS ONLY:
    CONSTRAINT "CHECK_person_phone" CHECK ("person_phone" ~ '^\d*$')
);
-- TABLE COMMENTS:
COMMENT ON TABLE "organization_manager" IS 'Table to store all managers provided by organization';
-- INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_organization_manager_organization_id" ON "organization_manager" ("organization_id");


CREATE TABLE IF NOT EXISTS "job_status"
(
    "job_status_id" smallint generated always as identity (start with 1 increment by 1),
    "job_status"    varchar(100) not null unique,
    --PK CONSTRAINT:
    CONSTRAINT "PK_job_status" PRIMARY KEY ("job_status_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "job_status" IS 'Table to store job statuses';


CREATE TABLE IF NOT EXISTS "job"
(
    "job_id"          int generated always as identity (start with 1 increment by 1),
    "organization_id" int          not null,
    "title"           varchar(100) not null,
    "description"     text         not null default 'no description was provided',
    "platform_url"    text         not null,
    "department_id"   smallint     not null,
    "job_status_id"   smallint     not null,
    "last_updated_at" timestamp    not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_job" PRIMARY KEY ("job_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_job.organization_id" FOREIGN KEY ("organization_id") REFERENCES "organization" ("organization_id"),
    CONSTRAINT "FK_job.department_id" FOREIGN KEY ("department_id") REFERENCES "department" ("department_id"),
    CONSTRAINT "FK_job.job_status_id" FOREIGN KEY ("job_status_id") REFERENCES "job_status" ("job_status_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "job" IS 'Table to store data of all available jobs';
-- CREATE INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_job_organization_id" ON "job" ("organization_id");
CREATE INDEX IF NOT EXISTS "idx_job_department_id" ON "job" ("department_id");
CREATE INDEX IF NOT EXISTS "idx_job_status_id" ON "job" ("job_status_id");


CREATE TABLE IF NOT EXISTS "test_task"
(
    "test_task_id"    int generated always as identity (start with 1 increment by 1),
    "manager_id"      integer      not null,
    "title"           varchar(100) not null,
    "description"     text         not null default 'no description was provided',
    "url"             text         not null,
    "last_updated_at" timestamp    not null default current_date,
    --PK CONSTRAINT:
    CONSTRAINT "PK_test_task" PRIMARY KEY ("test_task_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_test_task.manager_id" FOREIGN KEY ("manager_id") REFERENCES "organization_manager" ("organization_manager_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "test_task" IS 'Table to store data of all tasks provided by interviewer for the hiring process';
-- CREATE INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_test_task_manager_id" ON "test_task" ("manager_id");


-- DML DATA INSERTS (Organization): ------------------------------------------------------------------------------------
INSERT INTO "job_status"(job_status)
VALUES ('NONACTIVE'),('ACTIVE'),('PENDING'),('CLOSED');

-- CREATE DATA FOR ORGANIZATION (Artel):
INSERT INTO "organization"(name, description, inn, email, address, organization_condition)
SELECT 'Artel',
        'Artel Electronics LLC (“Artel”), Central Asia’s leading home appliance and electronics manufacturer and
         one of Uzbekistan’s largest companies, has received a first-time Fitch rating of B with a stable outlook',
        '302913673',
        'info@artelelectronics.com', -- email
        'Uzbekistan, Tashkent, Yashnabad district, st. Makhtumkuli, 2', -- address
        1 -- organization_condition
WHERE NOT EXISTS(select 1 from organization where name = 'Artel' and inn = '302913673' and email = 'info@artelelectronics.com');

-- CREATE DATA FOR ORGANIZATION (EPAM):
INSERT INTO "organization"(name, description, inn, email, address, organization_condition)
SELECT 'EPAM Systems',
        'EPAM Systems, Inc. is an American-Belarusian company that specializes in product development,
        digital platform engineering, and digital product design.
        One of the world''s largest manufacturers of custom software and consulting providers',
        '102345678',
        'info@epam.com', -- email
        '41 University Drive • Suite 202, Newtown, PA 18940 • USA', -- address
        1 -- organization_condition
WHERE NOT EXISTS(select 1 from organization where name = 'EPAM Systems' and inn = '102345678' and email = 'info@epam.com');

INSERT INTO "organization_manager"(organization_id, person_name, person_email, person_phone)
SELECT o.organization_id, 'Ulugbek Abirov', 'ulugbekabir@gmail.com', '998999889393'
FROM organization o
WHERE lower(o.name) = 'artel'
  AND NOT EXISTS(select 1
                 from organization_manager
                 where o.organization_id = o.organization_id
                   and person_name = 'Ulugbek Abirov'
                   and person_email = 'ulugbekabir@gmail.com');

INSERT INTO "organization_manager"(organization_id, person_name, person_email, person_phone)
SELECT o.organization_id, 'Aziz Muratov', 'azizbekmuratov@epam.com', '998991123343'
FROM organization o
WHERE lower(o.name) = 'epam systems'
  AND NOT EXISTS(select 1
                 from organization_manager
                 where o.organization_id = o.organization_id
                   and person_name = 'Aziz Muratov'
                   and person_email = 'azizbekmuratov@epam.com');

-- CREATE DATA FOR JOBS:
-- NOTE !: Organization might have multiple records for same job opening indicating number of vacant positions:

-- INSERT DATA FOR JOBS PROVIDED BY "Artel" ORGANIZATION:
INSERT INTO "job"(organization_id, title, description, platform_url, department_id, job_status_id)
SELECT o.organization_id,
       'SMM specialist',                                                       -- job title
       -- job description:
       'Responsibilities: Maintenance of social networks of the university;
        Development of an SMM strategy, drawing up a content plan Content creation work; Copywriting;
        Drawing up a technical specification for a designer;
        Requirements:
        Work experience at least 1 year;
        Organization; Literacy; Creativity; Compulsory knowledge of English and Uzbek;
        Conditions:
        Official employment;
        Career. We value a person''s potential;
        Full-time office work 5/1, 09:00 - 18:00;
        Salary based on the results of the interview',
       'https://g.co/kgs/c8s2qy',
       (select department_id from department where department = 'MARKETING'),
       (select job_status_id from job_status where job_status = 'ACTIVE')
FROM organization o
WHERE lower(o.name) = 'artel';

-- INSERT DATA FOR JOBS PROVIDED BY "EPAM" ORGANIZATION:
INSERT INTO "job"(organization_id, title, description, platform_url, department_id, job_status_id)
SELECT o.organization_id,
       'Data Engineer',                                                       -- job title
       -- job description:
        'Design and implement innovative analytical solution using Hadoop, NoSQL, and other Big Data related technologies, evaluating new features and architecture in Cloud/ on premise/ Hybrid solutions
        Work with product and engineering teams to understand requirements, evaluate new features and architecture to help drive decisions
        Build collaborative partnerships with architects, technical leads, and key individuals within other functional groups
        Perform detailed analysis of business problems and technical environments and use this in designing quality technical solution
        Actively participate in code review and test solutions to ensure it meets best practice specifications
        Build and foster a high-performance engineering culture, mentor team members, and provide team with the tools and motivation
        Write project documentation',
       'https://g.co/kgs/gGnXBE',
       (select department_id from department where department = 'IT'),
       (select job_status_id from job_status where job_status = 'ACTIVE')
FROM organization o
WHERE lower(o.name) = 'epam systems';


INSERT INTO "test_task"(manager_id, title, description, url)
SELECT om.organization_manager_id,
       'Create an advertisement text',
       'The task to test candidate''s creativity and grammatical resource and accuracy',
       'https://www.testgorilla.com/test-library/role-specific-skills-tests/social-media-management-test/'
FROM organization_manager om
WHERE om.person_name = 'Ulugbek Abirov'
  AND NOT EXISTS(select 1
                 from test_task
                 where manager_id = om.organization_manager_id
                   and title = 'Create an advertisement text'
                   and url =
                       'https://www.testgorilla.com/test-library/role-specific-skills-tests/social-media-management-test/');


INSERT INTO "test_task"(manager_id, title, description, url)
SELECT om.organization_manager_id,
       'LeetCode SQL task',
       'The task to test candidate''s problem solving skills and SQL knowledge',
       'https://leetcode.com/problems/nth-highest-salary/'
FROM organization_manager om
WHERE om.person_name = 'Aziz Muratov'
  AND NOT EXISTS(select 1
                 from test_task
                 where manager_id = om.organization_manager_id
                   and title = 'LeetCode SQL task'
                   and url = 'https://leetcode.com/problems/nth-highest-salary/');
------------------------------------------------------------------------------------------------------------------------

-- "record_ts" COLUMNS -------------------------------------------------------------------------------------------------
ALTER TABLE "organization" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "organization_manager" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "job_status" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "job" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "test_task" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
------------------------------------------------------------------------------------------------------------------------

-- APPLICATION && PROCESS ----------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "application"
(
    "application_id"     int generated always as identity (start with 1 increment by 1),
    "job_id"             int       not null,
    "candidate_id"       int       not null,
    "recruiter_id"       int       not null,
    "note"               text      not null default 'no notes provided',
    "application_status" smallint  not null default 1,
    "last_updated_at"    timestamp not null default current_timestamp,
    --PK CONSTRAINT:
    CONSTRAINT "PK_application" PRIMARY KEY ("application_id"),
    --FK CONSTRAINTS:
    CONSTRAINT "FK_application.recruiter_id" FOREIGN KEY ("recruiter_id") REFERENCES "recruiter" ("recruiter_id"),
    CONSTRAINT "FK_application.job_id" FOREIGN KEY ("job_id") REFERENCES "job" ("job_id"),
    CONSTRAINT "FK_application.candidate_id" FOREIGN KEY ("candidate_id") REFERENCES "candidate" ("candidate_id"),
    -- CHECK CONSTRAINTS:
    CONSTRAINT "CHECK_application_condition" CHECK ("application_status" in (1, 2, 3))
);
-- TABLE COMMENTS:
COMMENT ON TABLE "application"
    IS 'Main table in database that stores all applications by linking jobs to candidates. Managed by recruiters in all stages';
COMMENT ON COLUMN "application"."application_status"
    IS '1 - ACTIVE, 2 - CANCELED, 3 - CLOSED';
-- INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_application_recruiter_id" ON "application" ("recruiter_id");
CREATE INDEX IF NOT EXISTS "idx_application_job_id" ON "application" ("job_id");
CREATE INDEX IF NOT EXISTS "idx_application_candidate_id" ON "application" ("candidate_id");


CREATE TABLE IF NOT EXISTS "process_type"
(
    "process_type_id" smallint generated always as identity (start with 1 increment by 1),
    "process_type"    varchar(100) not null unique,
    --PK CONSTRAINT:
    CONSTRAINT "PK_process_type" PRIMARY KEY ("process_type_id")
);
-- TABLE COMMENTS:
COMMENT ON TABLE "process_type" IS 'Table to store process types';


CREATE TABLE IF NOT EXISTS "process" (
  "process_id" int generated always as identity (start with 1 increment by 1),
  "application_id" int not null,
  "recruiter_id" int not null,
  "manager_id" int, -- NOTE THAT THIS COLUMN IS NULLABLE BECAUSE A PROCESS MIGHT NOT HAVE A INTERVIEW MANAGER
  "test_task_id" int, -- NOTE THAT THIS COLUMN IS NULLABLE BECAUSE A PROCESS MIGHT NOT HAVE A TASK
  "process_status" smallint not null,
  "interviewer_feedback" text not null default 'no feedback',
  "recruiter_feedback" text not null default 'no feedback',
  "process_type_id" smallint not null,
  "last_updated_at" timestamp not null default current_timestamp,
  --PK CONSTRAINT:
  CONSTRAINT "PK_process" PRIMARY KEY ("process_id"),
  --FK CONSTRAINTS:
  CONSTRAINT "FK_process.manager_id" FOREIGN KEY ("manager_id") REFERENCES "organization_manager"("organization_manager_id"),
  CONSTRAINT "FK_process.recruiter_id" FOREIGN KEY ("recruiter_id") REFERENCES "recruiter"("recruiter_id"),
  CONSTRAINT "FK_process.test_task_id" FOREIGN KEY ("test_task_id") REFERENCES "test_task"("test_task_id"),
  CONSTRAINT "FK_process.application_id" FOREIGN KEY ("application_id") REFERENCES "application"("application_id"),
  CONSTRAINT "FK_process.process_type_id" FOREIGN KEY ("process_type_id") REFERENCES "process_type"("process_type_id"),
  -- CHECK CONSTRAINTS:
  CONSTRAINT "CHECK_process_status" CHECK ("process_status" in (1,2,3))
);
-- TABLE COMMENTS:
COMMENT ON TABLE "process" IS 'Table to store and manage all processes created by each application';
COMMENT ON COLUMN "process"."process_status" IS '1 - ACTIVE, 2 - CANCELED, 3 - COMPLETED';
-- CREATE INDEX ON FOREIGN KEYS:
CREATE INDEX IF NOT EXISTS "idx_process_manager_id" ON "process"("manager_id");
CREATE INDEX IF NOT EXISTS "idx_process_recruiter_id" ON "process"("recruiter_id");
CREATE INDEX IF NOT EXISTS "idx_process_test_task_id" ON "process"("test_task_id");
CREATE INDEX IF NOT EXISTS "idx_process_application_id" ON "process"("application_id");
CREATE INDEX IF NOT EXISTS "idx_process_process_type_id" ON "process"("process_type_id");

-- DML DATA INSERTS (APPLICATION && PROCESS): --------------------------------------------------------------------------
INSERT INTO "process_type"(process_type)
VALUES ('SCREENING'),('INTERVIEW'),('TEST'),('OFFER/REFUSE');

-- CANDIDATE (Kamoliddin) CREATES APPLICATION
WITH cte_job AS (
    -- SET CHOSEN JOB TO PENDING STATUS
    UPDATE "job"
        SET job_status_id = (select job_status_id from job_status where job_status = 'PENDING'),
            "last_updated_at" = current_timestamp
        WHERE job_id = (select job_id
                        from job
                        where title = 'SMM specialist'
                          and job_status_id = (select job_status_id from job_status where job_status = 'ACTIVE')
                          and organization_id = (select organization_id from organization where name = 'Artel')
                        order by last_updated_at desc
                        limit 1)
    RETURNING job_id, department_id
),
     cte_application AS (
         INSERT INTO "application" (job_id, candidate_id, recruiter_id, application_status)
             SELECT cte_job.job_id,
                    c.candidate_id,
                    -- TAKE FIRST AVAILABLE RECRUITER FROM THE DEPARTMENT TO WHICH THE JOB BELONGS TO (4 - MARKETING) AND ASSIGN TO THE CANDIDATE
                    (select distinct recruiter_id
                     from recruiter r
                              inner join recruiter_email re using (recruiter_id)
                     where r.first_name = 'Vitaliy'
                       and r.last_name = 'Davidov'
                       and re.email = 'vitaliydavidov@epam.com'
                       and r.condition = 1),
                    1 -- set application status to active
             FROM candidate c,
                  cte_job
             WHERE lower(c.first_name) = 'kamoliddin'
               and lower(c.last_name) = 'nabijonov'
               and c.email = 'nabijonovkamol@gmail.com'
               AND NOT EXISTS(select 1
                              from application
                              where job_id = cte_job.job_id
                                and candidate_id = c.candidate_id
                                and application_status = 1)
             RETURNING application_id, job_id, recruiter_id, candidate_id
)
-- EACH JOB APPLICATION INITIATES A PROCESS. IN OUR CASE APPLICATION CREATES SCREENING INTERVIEW PROCESS
INSERT
INTO "process"(application_id, recruiter_id, process_status, process_type_id)
SELECT ca.application_id,
       ca.recruiter_id,
       1,
       (select process_type_id from process_type where process_type = 'SCREENING')
FROM cte_application ca
WHERE NOT EXISTS(select 1
                 from process
                 where application_id = ca.application_id
                   and recruiter_id = ca.recruiter_id
                   and process_status = 1
                   and process_type_id = (select process_type_id from process_type where process_type = 'SCREENING'));


-- CANDIDATE (Zafar) CREATES APPLICATION
WITH cte_job AS (
    -- SET CHOSEN JOB TO PENDING STATUS
    UPDATE "job"
        SET job_status_id = (select job_status_id from job_status where job_status = 'PENDING'),
            "last_updated_at" = current_timestamp
        WHERE job_id = (select job_id
                        from job
                        where title = 'Data Engineer'
                          and job_status_id = (select job_status_id from job_status where job_status = 'ACTIVE')
                          and organization_id = (select organization_id from organization where name = 'EPAM Systems')
                        order by last_updated_at desc
                        limit 1)
    RETURNING job_id, department_id, organization_id

),
     cte_application AS (
         INSERT INTO "application" (job_id, candidate_id, recruiter_id, application_status)
             SELECT cte_job.job_id,
                    c.candidate_id,
                    -- TAKE FIRST AVAILABLE RECRUITER FROM THE DEPARTMENT TO WHICH THE JOB BELONGS TO (4 - MARKETING) AND ASSIGN TO THE CANDIDATE
                    (select distinct recruiter_id
                     from recruiter r
                              inner join recruiter_email re using (recruiter_id)
                     where r.first_name = 'Vitaliy'
                       and r.last_name = 'Davidov'
                       and re.email = 'vitaliydavidov@epam.com'
                       and r.condition = 1),
                    1 -- set application status to active
             FROM candidate c,
                  cte_job
             WHERE lower(c.first_name) = 'zafar'
               and lower(c.last_name) = 'ivaev'
               and c.email = 'zivaev@mail.ru'
               AND NOT EXISTS(select 1
                              from application
                              where job_id = cte_job.job_id
                                and candidate_id = c.candidate_id
                                and application_status = 1)
             RETURNING application_id, job_id, recruiter_id, candidate_id
),
-- EACH JOB APPLICATION INITIATES A PROCESS. IN OUR CASE APPLICATION CREATES TEST TASK PROCESS,
cte_manager AS (
    select organization_manager_id
    from organization_manager
    where organization_id = (select organization_id from cte_job)
      and person_name = 'Aziz Muratov'
      and person_email = 'azizbekmuratov@epam.com'
)
INSERT
INTO "process"(application_id, recruiter_id, manager_id, test_task_id, process_status, process_type_id)
SELECT ca.application_id,
       ca.recruiter_id,
       (select organization_manager_id from cte_manager),
       (select test_task_id from test_task where manager_id = (select organization_manager_id from cte_manager) and title = 'LeetCode SQL task'),
       1,
       (select process_type_id from process_type where process_type = 'TEST')
FROM cte_application ca
WHERE NOT EXISTS(select 1
                 from process
                 where application_id = ca.application_id
                   and recruiter_id = ca.recruiter_id
                   and process_status = 1
                   and process_type_id = (select process_type_id from process_type where process_type = 'TEST'));
------------------------------------------------------------------------------------------------------------------------

-- "record_ts" COLUMNS -------------------------------------------------------------------------------------------------
ALTER TABLE "application" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "process_type" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
ALTER TABLE "process" ADD COLUMN IF NOT EXISTS "record_ts" DATE NOT NULL DEFAULT current_date;
------------------------------------------------------------------------------------------------------------------------