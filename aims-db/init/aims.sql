ALTER DATABASE aims SET timezone TO 'UTC';
ALTER DATABASE aims SET glob_variables.terminal_limit_time = '1 hour';
ALTER DATABASE aims SET glob_variables.command_limit_minutes = 1;
ALTER DATABASE aims SET glob_variables.test_steps_limit_minutes = 1;
ALTER DATABASE aims SET glob_variables.count_test_steps = 6;
ALTER DATABASE aims SET glob_variables.notifications_minutes_as_new = 1;
ALTER DATABASE aims SET glob_variables.id_work_mode_no_assignation = 2;
ALTER DATABASE aims SET glob_variables.id_work_mode_installation = 3;
ALTER DATABASE aims SET glob_variables.id_work_mode_replacement = 4;
ALTER DATABASE aims SET glob_variables.id_work_mode_productive = 5;
ALTER DATABASE aims SET glob_variables.id_work_mode_discharged = 6;
ALTER DATABASE aims SET glob_variables.valid_active_minutes_of_session = 10;
SET SESSION glob_variables.encrypted_user_password = 'qOwFncF79ArlAaWpAKearQ==';
SET SESSION glob_variables.encrypted_super_user_password = 'qOwFncF79ArlAaWpAKearQ==';
SET SESSION TIMEZONE TO 'UTC';-- DB setup
DROP ROLE IF EXISTS system_admin;
DROP ROLE IF EXISTS mesa_control;
DROP ROLE IF EXISTS monitoreo;
DROP ROLE IF EXISTS asignador;
DROP ROLE IF EXISTS test;
DROP ROLE IF EXISTS no_access_role;
DROP ROLE IF EXISTS backend_agent;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TYPE historical_actions AS ENUM ('CREACIÓN', 'MODIFICACIÓN', 'ELIMINACIÓN', 'HABILITACIÓN', 'DESHABILITACIÓN','ASIGNACIÓN');
CREATE ROLE system_admin;
CREATE ROLE mesa_control;
CREATE ROLE monitoreo;
CREATE ROLE asignador;
CREATE ROLE test;
CREATE ROLE no_access_role;
CREATE ROLE backend_agent;

-- DB creation
CREATE TABLE IF NOT EXISTS system_user
(
    id_system_user serial,
    name character varying(30) NOT NULL,
    last_name character varying(30) NULL,
    mothers_last_name character varying(30) NULL,
    nickname character varying(30) NOT NULL,
    password character varying(100) NOT NULL DEFAULT '',
    address_street VARCHAR(64) NOT NULL,
    address_street_number VARCHAR(16) NOT NULL,
    address_suite_number VARCHAR(16) NULL DEFAULT NULL,
    address_suburb VARCHAR(32) NOT NULL, -- colonia
    address_county VARCHAR(32) NOT NULL, -- alcaldía o municipio
    address_city VARCHAR(32) NOT NULL,
    address_state VARCHAR(32) NOT NULL,
    address_zip_code VARCHAR(5) NOT NULL,
    email character varying(50),
    phone character varying(50),
    date_session timestamp(6) with time zone,
    date_validity timestamp(6) with time zone,
    id_role integer NOT NULL,
    enabled boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    is_super_user boolean DEFAULT false,
    deleted_reason TEXT NULL DEFAULT NULL,

    -- historical attributes
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL,
    date_deleted TIMESTAMP NULL DEFAULT NULL,
    historical_action HISTORICAL_ACTIONS DEFAULT 'CREACIÓN',
    historical_action_user_id VARCHAR(36) NULL DEFAULT NULL,
    historical_id VARCHAR(36) NOT NULL DEFAULT uuid_generate_v4(),

    PRIMARY KEY (id_system_user)
);


CREATE TABLE IF NOT EXISTS notifications_level
(
    id_notification_level serial,
    name TEXT NOT NULL,

    PRIMARY KEY (id_notification_level)
);

CREATE TABLE IF NOT EXISTS system_user_notification_levels
(
    id_system_user_notification_level serial,
    system_user_historical_id VARCHAR(36) NOT NULL,
    id_notification_level INT NOT NULL,

    PRIMARY KEY (system_user_historical_id,id_notification_level)
);

CREATE TABLE IF NOT EXISTS auth_tokens
(
    id_auth_token serial,
    valid_token VARCHAR(36) NOT NULL DEFAULT uuid_generate_v4(),
    system_user_historical_id VARCHAR(36) NOT NULL,
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_auth_token)
);

CREATE TABLE IF NOT EXISTS historic_sessions
(
    id_historic_sessions serial,
    system_user_historical_id VARCHAR(36) NOT NULL,
    type TEXT NOT NULL,
    reason TEXT NULL DEFAULT NULL,
    date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_historic_sessions)
);

CREATE TABLE IF NOT EXISTS service_user
(
    id_service_user serial,
    name character varying(30) NOT NULL,
    last_name character varying(30) NULL,
    mothers_last_name character varying(30) NULL,
    nickname character varying(30) NULL,
    nip character varying(50) NOT NULL DEFAULT '',
    address_street VARCHAR(64) NULL,
    address_street_number VARCHAR(16) NULL,
    address_suite_number VARCHAR(16) NULL DEFAULT NULL,
    address_suburb VARCHAR(32) NULL, -- colonia
    address_county VARCHAR(32) NULL, -- alcaldía o municipio
    address_city VARCHAR(32) NULL,
    address_state VARCHAR(32) NULL,
    address_zip_code VARCHAR(5) NULL,
    email character varying(50) NOT NULL,
    phone character varying(50) NULL,
    date_session timestamp(6) with time zone,
    date_validity timestamp(6) with time zone,
    enabled boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    deleted_reason TEXT NULL DEFAULT NULL,
    creation_mode TEXT NULL DEFAULT NULL,

    -- historical attributes
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL,
    date_deleted TIMESTAMP NULL DEFAULT NULL,
    historical_action HISTORICAL_ACTIONS DEFAULT 'CREACIÓN',
    historical_action_user_id VARCHAR(36) NULL DEFAULT NULL,
    historical_id VARCHAR(36) NOT NULL DEFAULT uuid_generate_v4(),

    PRIMARY KEY (id_service_user)
);

CREATE TABLE IF NOT EXISTS roles
(
    id_role serial NOT NULL,
    name character varying(20) NOT NULL,
    large_name character varying(30) NOT NULL,
    PRIMARY KEY (id_role)
);

CREATE TABLE IF NOT EXISTS questions
(
    id_question serial NOT NULL,
    question character varying(80) NOT NULL,
    PRIMARY KEY (id_question)
);

CREATE TABLE IF NOT EXISTS service_user_responses
(
    id_question integer NOT NULL,
    id_service_user integer NOT NULL,
    response character varying(100) NOT NULL,
    id_response serial NOT NULL,
    PRIMARY KEY (id_response)
);

CREATE TABLE IF NOT EXISTS groups
(
    id_group serial NOT NULL,
    name character varying(30) NOT NULL,
    description character varying(100) NOT NULL,
    enabled boolean DEFAULT true,
    is_deleted boolean DEFAULT false,

    -- historical attributes
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL,
    date_deleted TIMESTAMP NULL DEFAULT NULL,
    historical_action HISTORICAL_ACTIONS DEFAULT 'CREACIÓN',
    historical_action_user_id VARCHAR(36) NULL DEFAULT NULL,
    historical_id VARCHAR(36) NOT NULL DEFAULT uuid_generate_v4(),

    PRIMARY KEY (id_group)
);

CREATE TABLE IF NOT EXISTS groups_service_user
(
    id_group integer NOT NULL,
    id_service_user integer NOT NULL,
    id_user_group serial NOT NULL,
    enabled boolean DEFAULT true,
    is_deleted boolean DEFAULT false,

    -- historical attributes
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL,
    date_deleted TIMESTAMP NULL DEFAULT NULL,
    historical_action HISTORICAL_ACTIONS DEFAULT 'CREACIÓN',
    historical_action_user_id VARCHAR(36) NULL DEFAULT NULL,
    historical_id VARCHAR(36) NOT NULL DEFAULT uuid_generate_v4(),

    PRIMARY KEY (id_user_group)
);

CREATE TABLE IF NOT EXISTS branch
(
    id_branch SERIAL NOT NULL,
    name VARCHAR(32) NOT NULL,
    address_street VARCHAR(64) NOT NULL,
    address_street_number VARCHAR(16) NOT NULL,
    address_suite_number VARCHAR(16) NULL DEFAULT NULL,
    address_suburb VARCHAR(32) NOT NULL, -- colonia
    address_county VARCHAR(32) NOT NULL, -- alcaldía o municipio
    address_city VARCHAR(32) NOT NULL,
    address_state VARCHAR(32) NOT NULL,
    address_zip_code VARCHAR(5) NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    enabled boolean DEFAULT true,
    is_deleted boolean DEFAULT false,

    -- historical attributes
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL,
    date_deleted TIMESTAMP NULL DEFAULT NULL,
    historical_action HISTORICAL_ACTIONS DEFAULT 'CREACIÓN',
    historical_action_user_id VARCHAR(36) NULL DEFAULT NULL,
    historical_id VARCHAR(36) NOT NULL DEFAULT uuid_generate_v4(),

    PRIMARY KEY (id_branch)
);

CREATE TABLE IF NOT EXISTS electronic_lock
(
    id_electronic_lock serial NOT NULL,
    id_lock integer NOT NULL UNIQUE,
    work_mode_date TIMESTAMP DEFAULT NULL,
    work_mode integer DEFAULT NULL,
    work_type_online integer DEFAULT 0,
    communication_date TIMESTAMP NULL DEFAULT NULL,
    validated BOOLEAN NULL DEFAULT NULL,
    status INT DEFAULT 0,
    
    PRIMARY KEY (id_electronic_lock)
);

CREATE TABLE IF NOT EXISTS terminal
(
    id_terminal serial NOT NULL,
    status character varying(20),
    status_description character varying(50),
    id_key integer,
    name character varying(30) NOT NULL,
    id_branch integer NULL,
    id_assignment integer NULL,
    enabled boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    serie character varying(40) NULL,
    model character varying(40) NULL,
    version character varying(30) NULL,
    randomic_lock_type character varying(50) NULL,
    creation_mode TEXT NULL DEFAULT NULL,

    -- historical attributes
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL,
    date_deleted TIMESTAMP NULL DEFAULT NULL,
    historical_action HISTORICAL_ACTIONS DEFAULT 'CREACIÓN',
    historical_action_user_id VARCHAR(36) NULL DEFAULT NULL,
    historical_id VARCHAR(36) NOT NULL DEFAULT uuid_generate_v4(),

    PRIMARY KEY (id_terminal)
);

CREATE TABLE IF NOT EXISTS assignment
(
    id_assignment serial NOT NULL,
    id_terminal INTEGER NULL DEFAULT NULL,
    id_lock INTEGER NULL DEFAULT NULL,
    PRIMARY KEY (id_assignment)
);

CREATE TABLE IF NOT EXISTS group_terminal
(
    id_group_terminal serial NOT NULL,
    id_group integer NOT NULL,
    id_terminal integer NOT NULL,
    enabled boolean DEFAULT true,
    is_deleted boolean DEFAULT false,

    -- historical attributes
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP NULL DEFAULT NULL,
    date_deleted TIMESTAMP NULL DEFAULT NULL,
    historical_action HISTORICAL_ACTIONS DEFAULT 'CREACIÓN',
    historical_action_user_id VARCHAR(36) NULL DEFAULT NULL,
    historical_id VARCHAR(36) NOT NULL DEFAULT uuid_generate_v4(),

    PRIMARY KEY (id_group_terminal)
);

CREATE TABLE IF NOT EXISTS randomic_operation
(
    id_randomic_operation SERIAL NOT NULL,
    system_user_historical_id VARCHAR(36) NULL DEFAULT NULL,
    service_user_historical_id VARCHAR(36) NULL DEFAULT NULL,
    operation_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP::TIMESTAMPTZ,
    is_approved BOOLEAN DEFAULT FALSE,

    PRIMARY KEY (id_randomic_operation)
);

CREATE TABLE IF NOT EXISTS randomic_operation_questions
(
    randomic_operation_questions_id SERIAL NOT NULL,
    id_randomic_operation INTEGER NOT NULL,
    id_question INTEGER NOT NULL,
    response VARCHAR(64) NULL DEFAULT NULL,

    PRIMARY KEY (randomic_operation_questions_id)
);

CREATE TABLE IF NOT EXISTS randomic_operation_locks 
(
    id_randomic_operation_lock SERIAL NOT NULL,
    service_user_historical_id VARCHAR(36) NULL DEFAULT NULL,
    lock_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP::TIMESTAMPTZ,
    is_locked BOOLEAN NOT NULL DEFAULT true,
    lock_description TEXT NULL DEFAULT NULL,

    PRIMARY KEY (id_randomic_operation_lock)
);

CREATE TABLE IF NOT EXISTS randomic_challenge_opening
(
    id_randomic_challenge_opening serial NOT NULL,
    success BOOLEAN NULL DEFAULT NULL,
    lock_select INT NULL DEFAULT NULL,
    try_count INT DEFAULT 0,
    id_lock INT NOT NULL,
    id_randomic_operation INT NOT NULL,
    failure_description TEXT NULL,
    date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_randomic_challenge_opening)
);

CREATE TABLE IF NOT EXISTS event_notifications (
  id_event_notification SERIAL,
  id_event INTEGER NULL DEFAULT NULL,
  system_user_historical_id VARCHAR(36) NOT NULL,
  seen BOOLEAN DEFAULT FALSE,
  is_new BOOLEAN DEFAULT TRUE,

  PRIMARY KEY (id_event_notification)
);

CREATE TABLE IF NOT EXISTS alarm_notifications (
  id_alarm_notification SERIAL,
  id_alarm INTEGER NULL DEFAULT NULL,
  system_user_historical_id VARCHAR(36) NOT NULL,
  seen BOOLEAN DEFAULT FALSE,
  is_new BOOLEAN DEFAULT TRUE,

  PRIMARY KEY (id_alarm_notification)
);

CREATE TABLE IF NOT EXISTS historical_lock_notifications (
  id_historical_lock_notification SERIAL,
  id_historical_lock INTEGER NULL DEFAULT NULL,
  system_user_historical_id VARCHAR(36) NOT NULL,
  seen BOOLEAN DEFAULT FALSE,
  is_new BOOLEAN DEFAULT TRUE,

  PRIMARY KEY (id_historical_lock_notification)
);

CREATE TABLE IF NOT EXISTS historical_lock
(
    id_historical_lock serial,
    id_lock integer NOT NULL,
    work_mode_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_work_mode integer DEFAULT 0,
    PRIMARY KEY (id_historical_lock)
);


CREATE TABLE IF NOT EXISTS work_mode
(
    id_work_mode serial,
    name character varying(30) not null,
    is_notification BOOLEAN DEFAULT false,
    is_email_notification BOOLEAN DEFAULT false,
    notification_message TEXT DEFAULT NULL,
    id_notification_level INT DEFAULT NULL,
    link_to TEXT NOT NULL,
    PRIMARY KEY (id_work_mode)
);


CREATE TABLE IF NOT EXISTS alarm_type
(
    id_alarm_type serial,
    name character varying(40) not null,
    description character varying(50),
    is_notification BOOLEAN DEFAULT false,
    is_email_notification BOOLEAN DEFAULT false,
    notification_message TEXT DEFAULT NULL,
    id_notification_level INT DEFAULT NULL,

    PRIMARY KEY (id_alarm_type)
);

CREATE TABLE IF NOT EXISTS alarms
(
    id_alarm serial,
    id_lock integer NOT NULL,
    id_alarm_type integer NOT NULL,
    date_start TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_close TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (id_alarm)
);

CREATE TABLE IF NOT EXISTS lock_key
(
    id_lock_key serial,
    id_lock integer NOT NULL,
    key character varying(32) NOT NULL,

    PRIMARY KEY (id_lock_key)
);

CREATE TABLE IF NOT EXISTS commands (
    id_command serial,
    id_lock integer NOT NULL,
    cmd integer NOT NULL,
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_apply TIMESTAMP NULL DEFAULT NULL,
    date_canceled TIMESTAMP NULL DEFAULT NULL,
    code_date_opened TIMESTAMP NULL DEFAULT NULL,
    canceled_description character varying(80),
    command_data character varying(60),
    expiration integer NULL,
    duration integer NULL,
    temp_code character varying(12) DEFAULT NULL,
    lock_select INTEGER NULL DEFAULT NULL,
    id_randomic_operation INTEGER NULL DEFAULT NULL,

    PRIMARY KEY (id_command)
);

CREATE TABLE IF NOT EXISTS command_type (
    id_command_type serial,
    description character varying(30) NOT NULL,
    input_type character varying(30) NOT NULL,
    with_lock_select BOOLEAN NOT NULL DEFAULT FALSE,

    PRIMARY KEY (id_command_type)
);

CREATE TABLE IF NOT EXISTS cp_sepomex (
    id integer NOT NULL,
    d_codigo character varying(6),
    d_asenta character varying(255),
    d_tipo_asenta character varying(255),
    d_mnpio character varying(255),
    d_estado character varying(255),
    d_ciudad character varying(255),
    d_cp character varying(6),
    c_estado character varying(3),
    c_oficina character varying(10),
    c_cp character varying(255),
    c_tipo_asenta character varying(255),
    c_mnpio character varying(5),
    id_asenta_cpcons character varying(4),
    d_zona character varying(255),
    c_cve_ciudad character varying(5)
);

CREATE TABLE IF NOT EXISTS event_type (
    id_event_type serial,
    description character varying(40) NOT NULL,
    is_notification BOOLEAN DEFAULT false,
    is_email_notification BOOLEAN DEFAULT false,
    notification_message TEXT DEFAULT NULL,
    id_notification_level INT DEFAULT NULL,

    PRIMARY KEY (id_event_type)
);

CREATE TABLE IF NOT EXISTS events (
    id_event serial,
    id_lock integer NOT NULL,
    id_event_type integer NOT NULL,
    event_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_event)
);

CREATE TABLE IF NOT EXISTS keys (
    id_key integer NOT NULL,
    alias character varying(30) NOT NULL,
    creation_date character varying(20) NOT NULL,
    key character varying(20) NOT NULL
);


CREATE TABLE IF NOT EXISTS electronic_lock_tests (
    id_electronic_lock_test serial ,
    id_lock INT NOT NULL,
    test_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    system_user_historical_id VARCHAR(36) NOT NULL,
    failure_details TEXT NULL DEFAULT NULL,
    success BOOLEAN NULL DEFAULT NULL,

    PRIMARY KEY (id_electronic_lock_test)
);

CREATE TABLE IF NOT EXISTS electronic_lock_tests_steps (
    id_electronic_lock_test_step serial,
    id_electronic_lock_test INT NOT NULL,
    step INT NOT NULL,
    test_step_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    failed BOOLEAN DEFAULT false,

    PRIMARY KEY (id_electronic_lock_test_step)
);

ALTER TABLE IF EXISTS system_user
    ADD FOREIGN KEY (id_role)
    REFERENCES roles (id_role) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS service_user_responses
    ADD FOREIGN KEY (id_question)
    REFERENCES questions (id_question) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS service_user_responses
    ADD FOREIGN KEY (id_service_user)
    REFERENCES service_user (id_service_user) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS groups_service_user
    ADD FOREIGN KEY (id_group)
    REFERENCES groups (id_group) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS groups_service_user
    ADD FOREIGN KEY (id_service_user)
    REFERENCES service_user (id_service_user) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS terminal
    ADD FOREIGN KEY (id_branch)
    REFERENCES branch (id_branch) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS group_terminal
    ADD FOREIGN KEY (id_group)
    REFERENCES groups (id_group) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS group_terminal
    ADD FOREIGN KEY (id_terminal)
    REFERENCES terminal (id_terminal) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS historical_lock
    ADD FOREIGN KEY (id_lock)
    REFERENCES electronic_lock (id_lock) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS alarms
    ADD FOREIGN KEY (id_lock)
    REFERENCES electronic_lock (id_lock) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS alarms
    ADD FOREIGN KEY (id_alarm_type)
    REFERENCES alarm_type (id_alarm_type) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS commands
    ADD FOREIGN KEY (cmd)
    REFERENCES command_type (id_command_type) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS commands
    ADD FOREIGN KEY (id_lock)
    REFERENCES electronic_lock (id_lock) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS commands
    ADD FOREIGN KEY (id_randomic_operation)
    REFERENCES randomic_operation (id_randomic_operation) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS randomic_challenge_opening
    ADD FOREIGN KEY (id_randomic_operation)
    REFERENCES randomic_operation (id_randomic_operation) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS randomic_challenge_opening
    ADD FOREIGN KEY (id_lock)
    REFERENCES electronic_lock (id_lock) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS events
    ADD FOREIGN KEY (id_lock)
    REFERENCES electronic_lock (id_lock) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS events
    ADD FOREIGN KEY (id_event_type)
    REFERENCES event_type (id_event_type) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS randomic_operation_questions
    ADD FOREIGN KEY (id_question)
    REFERENCES questions (id_question) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
ALTER TABLE IF EXISTS randomic_operation_questions
    ADD FOREIGN KEY (id_randomic_operation)
    REFERENCES randomic_operation (id_randomic_operation) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS event_notifications
    ADD FOREIGN KEY (id_event)
    REFERENCES events (id_event) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS alarm_notifications
    ADD FOREIGN KEY (id_alarm)
    REFERENCES alarms (id_alarm) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS historical_lock_notifications
    ADD FOREIGN KEY (id_historical_lock)
    REFERENCES historical_lock (id_historical_lock) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS historical_lock
    ADD FOREIGN KEY (id_work_mode)
    REFERENCES work_mode (id_work_mode) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS terminal
    ADD FOREIGN KEY (id_assignment)
    REFERENCES assignment (id_assignment) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS assignment
  ADD FOREIGN KEY (id_lock)
  REFERENCES electronic_lock (id_lock) MATCH SIMPLE
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
  NOT VALID;

ALTER TABLE IF EXISTS event_type
  ADD FOREIGN KEY (id_notification_level)
  REFERENCES notifications_level (id_notification_level) MATCH SIMPLE
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
  NOT VALID;

ALTER TABLE IF EXISTS alarm_type
  ADD FOREIGN KEY (id_notification_level)
  REFERENCES notifications_level (id_notification_level) MATCH SIMPLE
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
  NOT VALID;

ALTER TABLE IF EXISTS work_mode
  ADD FOREIGN KEY (id_notification_level)
  REFERENCES notifications_level (id_notification_level) MATCH SIMPLE
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
  NOT VALID;
    
ALTER TABLE IF EXISTS system_user_notification_levels
  ADD FOREIGN KEY (id_notification_level)
  REFERENCES notifications_level (id_notification_level) MATCH SIMPLE
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
  NOT VALID;

ALTER TABLE IF EXISTS electronic_lock_tests_steps
  ADD FOREIGN KEY (id_electronic_lock_test)
  REFERENCES electronic_lock_tests (id_electronic_lock_test) MATCH SIMPLE
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
  NOT VALID;

-- Alter sequences
ALTER SEQUENCE IF EXISTS questions_id_question_seq START WITH 15 RESTART;
ALTER SEQUENCE IF EXISTS electronic_lock_id_electronic_lock_seq START WITH 11 RESTART;
ALTER SEQUENCE IF EXISTS alarm_type_id_alarm_type_seq START WITH 3 RESTART;
ALTER SEQUENCE IF EXISTS roles_id_role_seq START WITH 3 RESTART;
ALTER SEQUENCE IF EXISTS lock_key_id_lock_key_seq START WITH 7 RESTART;

ALTER SEQUENCE IF EXISTS system_user_id_system_user_seq START WITH 9 RESTART;
ALTER SEQUENCE IF EXISTS service_user_id_service_user_seq START WITH 6 RESTART;
ALTER SEQUENCE IF EXISTS groups_id_group_seq START WITH 4 RESTART;

ALTER SEQUENCE IF EXISTS branch_id_branch_seq START WITH 4 RESTART;
ALTER SEQUENCE IF EXISTS terminal_id_terminal_seq START WITH 10 RESTART;
ALTER SEQUENCE IF EXISTS assignment_id_assignment_seq START WITH 9 RESTART;

ALTER SEQUENCE IF EXISTS commands_id_command_seq START WITH 11 RESTART;

ALTER SEQUENCE IF EXISTS electronic_lock_tests_id_electronic_lock_test_seq START WITH 5 RESTART;

-- Data inject

-- notifications levels
INSERT INTO notifications_level
  (id_notification_level,name)
VALUES
  (1,'Aviso'),
  (2,'Alerta'),
  (3,'Urgente');


INSERT INTO questions (id_question,question)
VALUES
  (1,'Organización'),
  (2,'Fecha de nacimiento'),
  (3,'Estado donde vives'),
  (4,'Dónde naciste (estado)'),
  (5,'Nombre de la madre'),
  (6,'Nombre de escuela primaria'),
  (7,'Color favorito'),
  (8,'Nombre de mascota'),
  (9,'Estado civil'),
  (10,'Equipo de futbol'),
  (11,'Usas lentes'),
  (12,'RFC (sin homoclave)'),
  (13,'Número IMSS'),
  (14,'Cuántos hijos')
ON CONFLICT DO NOTHING;

INSERT INTO electronic_lock (id_electronic_lock,id_lock,work_mode_date,work_mode,communication_date)
VALUES
  (1,1000,CURRENT_TIMESTAMP,6,CURRENT_TIMESTAMP),
  (2,1001,CURRENT_TIMESTAMP,3,CURRENT_TIMESTAMP),
  (3,1002,CURRENT_TIMESTAMP,3,CURRENT_TIMESTAMP),
  (4,1003,CURRENT_TIMESTAMP,3,CURRENT_TIMESTAMP),
  (6,1005,'2022-05-10 10:32:15.981188',5,CURRENT_TIMESTAMP),
  (7,1006,'2022-05-11 10:32:15.981188',6,CURRENT_TIMESTAMP),
  (5,1004,'2022-05-06 10:32:15.981188',5,'2022-05-02 10:32:15.981188'),
  (8,1007,'2022-05-06 10:32:15.981188',5,'2022-05-03 10:32:15.981188'),
  (9,1008,'2022-05-06 10:32:15.981188',2,'2022-05-04 10:32:15.981188'),
  (10,1009,'2022-05-06 10:32:15.981188',2,'2022-05-04 10:32:15.981188'),
  (11,1010,'2022-05-06 10:32:15.981188',1,'2022-05-04 10:32:15.981188'),
  (12,1011,'2022-05-06 10:32:15.981188',1,'2022-05-04 10:32:15.981188')
ON CONFLICT DO NOTHING;


-- Alarms with system notification
INSERT INTO work_mode (id_work_mode,name,is_notification,notification_message,id_notification_level,link_to)
VALUES
  (1,'Pruebas',false,'La chapa %s ha cambiado al modo de trabajo de pruebas.',1,
    'lock'),
  (2,'No asignado',true,'La chapa %s ha cambiado al modo de trabajo no asignada.',1,
    'lock'),
  (3,'Asignado para instalación',true,'El cajero %s ha cambiado al modo de trabajo asignada para instalación.',1,
    'cashier'),
  (4,'Asignado para reemplazo',true,'El cajero %s ha cambiado al modo de trabajo asignada para reemplazo.',1,
    'cashier'),
  (5,'Productivo',true,'El cajero %s ha cambiado al modo de trabajo productivo.',1,
    'cashier'),
  (6,'Baja',true,'El cajero %s ha cambiado al modo de trabajo de baja.',1,
    'cashier')
ON CONFLICT DO NOTHING;

-- Alarms without system notification
INSERT INTO alarm_type (id_alarm_type,name)
VALUES
  (2,'Inhíbido'),
  (3,'Abierto Fascia'),
  (4,'Intrusión'),
  (9,'Abierto Copete'),
  (10,'Chapa Copete Averiada')
ON CONFLICT DO NOTHING;

-- Alarms with system notification
INSERT INTO alarm_type (id_alarm_type,name,is_notification,notification_message,id_notification_level)
VALUES
  (1,'Alerta',true,'El cajero %s ha tenido un error desconocido.',2),
  (5,'Chapa Fascia Averiada',true,'Se ha averiado la Fascia del cajero %s.',2),
  (6,'Sensor de Luz Averiada',true,'Se ha averiado el sensor de luz del cajero %s.',2),
  (7,'Dispensador Deshabilitado',true,'El dispensador del cajero %s está deshabilitado.',2),
  (8,'Armado',true,'Se ha armado el cajero %s cuando tenía su dispensador deshabilitado.',2)
ON CONFLICT DO NOTHING;

--Events without notification
INSERT INTO event_type (id_event_type,description)
VALUES
  (1,'Reto solicitado'),
  (2,'Reto solicitado durante intrusion'),
  (5,'Cerrado sin ingreso a zona no segura'),
  (7,'Cerrado con ingreso a zona no segura'),
  (8,'Respuesta equivocada'),
  (9,'Respuesta equivocada durante intrusion'),
  (10,'Reto caduco'),
  (11,'Reto caduco durante intrusion'),
  (14,'Llave nueva ha sido guardada'),
  (18,'Ingreso a menu de Dongle'),
  (19,'Cargar llave seleccionado'),
  (20,'Exportar Log seleccionado'),
  (21,'Llave dinamica solicitada'),
  (22,'Timeout de conexion de Dongle'),
  (23,'Log exportado con éxito'),
  (24,'Error al exportar Log'),
  (27,'Chapa conectada'),
  (28,'Sensor de luz conectado'),
  (30,'Chapa cerrada'),
  (32,'Ausencia de luz'),
  (33,'Reto actualizado'),
  (34,'Sistema OK!'),
  (35,'Estableciendo conexión'),
  (38,'Boton liberado'),
  (40,'Bootloader activado por comando'),
  (41,'Cambio de llave por comando'),
  (42,'X'),
  (46,'Apertura (Copete) por comando'),
  (47,'Apertura (Copete) por reto'),
  (48,'Chapa abierta (Copete)'),
  (49,'Chapa cerrada (Copete)')
ON CONFLICT DO NOTHING;

-- Events with system notification
INSERT INTO event_type (id_event_type,description,is_notification,notification_message,id_notification_level)
VALUES
  (3,'Apertura mediante reto',true,'El proceso de apertura randómica del cajero %s fue exitoso.',1),
  (4,'Apertura mediante reto durante intrusion',true,'El proceso de apertura randómica del cajero %s fue exitoso durante intrusión.',1),
  (6,'Tiempo abierto agotado, sistema alarmado',true,'El tiempo abierto del cajero %s se agotó.',2),
  (12,'Limite de intentos, fuera de servicio',true,'Límite de intentos de apertura alcanzado. El cajero %s queda fuera de servicio.',2),
  (15,'Intrusion',true,'El cajero %s se encuentra en estado de intrusión.',2),
  (16,'Chapa desconectada',true,'El cajero %s se encuentra desconectada.',2),
  (17,'Sensor de luz desconectado',true,'Se desconectó el sensor de luz del cajero %s.',2),
  (25,'Sistema restablecido',true,'El sistema del cajero %s ha sido reestablecido.',1),
  (26,'Sistema re-energizado',true,'El sistema del cajero %s ha sido re-energizado.',1),
  (29,'Chapa abierta (Fascia)',true,'Se ha abierto el cajero %s desde la Fascia.',1),
  (31,'Presencia de luz',true,'Se ha encontrado la presencia de luz en el cajero %s.',2),
  (36,'Fallo la conexión',true,'La conexión del cajero %s ha sufrido un fallo.',2),
  (37,'Boton presionado',true,'Se ha presionado un botón en el cajero %s.',2),
  (39,'Apertura (Fascia) por comando',true,'Se ha abierto correctamente la fascia del cajero %s por medio de comando remoto.',1),
  (43,'Corte de Energia por comando',true,'Se ha cortado la energía del cajero %s por medio de comando remoto.',1),
  (44,'Reenergizado por comando',true,'Se ha reenergizado el cajero %s por medio de comando remoto.',1),
  (45,'Reenergizado mediante reto',true,'Se ha reenergizado el cajero %s por medio de reto.',1)
ON CONFLICT DO NOTHING;

-- Events with system notification and email notification
INSERT INTO event_type (id_event_type,description,is_notification,is_email_notification,notification_message,id_notification_level)
VALUES
  (13,'Amago',true,true,'El cajero %s se encuentra en modo de amago.',3)
ON CONFLICT DO NOTHING;

INSERT INTO roles (id_role,name,large_name)
VALUES
  (1,'system_admin','Administrador'),
  (2,'mesa_control','Mesa de apertura'),
  (3,'monitoreo','Monitoreo'),
  (4,'asignador','Asignador'),
  (5,'test','Test')
ON CONFLICT DO NOTHING;

INSERT INTO lock_key (
  id_lock_key,
  id_lock,
  key
) VALUES 
  (1,1000,'1911050754030000041600001F26F088'),
  (2,1001,'1911201112050000041E0000011B1754'),
  (3,1002,'1911210945400000041F0000062B8BE3'),
  (4,1003,'19112111201400000003000004CDE1F0'),
  (5,1004,'210806150029000004B200001A9D380B'),
  (6,1005,'210819210519000004B300000EBC4352')
ON CONFLICT DO NOTHING;

INSERT INTO command_type (id_command_type,description,input_type,with_lock_select)
  VALUES 
    (1,'Apertura','datetime',true),
    (2,'Cargar Firmware','datetime',false),
    (3,'Actualizar Llaves','datetime',false),
    (4,'Reset','datetime',false),
    (5,'Corte de Energia','datetime',false),
    (7,'Código Programado','minutes',true),
    (8,'Prueba de teclado','minutes',false)
ON CONFLICT DO NOTHING;


--- Usuarios de sistema
INSERT INTO system_user (
  id_system_user,
  name,
  last_name,
  mothers_last_name,
  nickname,
  address_street,
  address_street_number,
  address_suburb,
  address_county,
  address_city,
  address_state,
  address_zip_code,
  email,
  id_role,
  enabled,
  is_super_user
)
VALUES
  (
    0,
    'superuser',
    'superuser',
    'superuser',
    'superuser',
    'superuser',
    'superuser',
    'superuser',
    'superuser',
    'superuser',
    'superuser',
    '11111',
    'super@user.com',
    1,
    true,
    true
  ), --PASSWORD "1234"
  (
    1,
    'ADMIN',
    'ADMIN',
    'ADMIN',
    'ADMIN',
    'XDirección',
    '1234',
    'XDirección',
    'XDirección',
    'XDirección',
    'XDirección',
    '11111',
    'admin@admin.com',
    1,
    true,
    false
  ), --PASSWORD "1234"
  (
    2,
    'MESA_CONTROL',
    'MESA_CONTROL',
    'MESA_CONTROL',
    'MESA_CONTROL',
    'XDirección',
    '1234',
    'XDirección',
    'XDirección',
    'XDirección',
    'XDirección',
    '11111',
    'mesa@control.com',
    2,
    true,
    false
  ), --PASSWORD "1234"
  (
    3,
    'Fabian',
    'Ley',
    'va',
    'Fabian',
    'XDirección',
    '1234',
    'XDirección',
    'XDirección',
    'XDirección',
    'XDirección',
    '11111',
    'fabian.boss.felt@gmail.com',
    2,
    true,
    false
  ), --PASSWORD "1234"
  (
    4,
    'Luisana',
    'Martin',
    'Rod',
    'Luisana',
    'Cañaberal',
    '320',
    'Centro',
    'Xochi',
    'Ciudad de México',
    'Ciudad de México',
    '98754',
    'lmartin@sisu.mx',
    1,
    true,
    false
  ), --PASSWORD "1234"
  (
    5,
    'Erik',
    'Mejia',
    'Rod',
    'Erik',
    'Saturno',
    '320',
    'Centro',
    'Fresnillo',
    'Zacatecas',
    'Zacatecas',
    '93000',
    'emejia9514@gmail.com',
    1,
    true,
    false
  ),
  (
    6,
    'Monitoreo',
    'Monitoreo',
    'Monitoreo',
    'Monitoreo',
    'Saturno',
    '320',
    'Centro',
    'Fresnillo',
    'Zacatecas',
    'Zacatecas',
    '93000',
    'monitoreo@monitoreo.com',
    3,
    true,
    false
  ), --PASSWORD "1234"
  (
    7,
    'Asignador',
    'Asignador',
    'Asignador',
    'Asignador',
    'Saturno',
    '320',
    'Centro',
    'Fresnillo',
    'Zacatecas',
    'Zacatecas',
    '93000',
    'asignador@asignador.com',
    4,
    true,
    false
  ), --PASSWORD "1234"
  (
    8,
    'Test',
    'Test',
    'Test',
    'Test',
    'Saturno',
    '320',
    'Centro',
    'Fresnillo',
    'Zacatecas',
    'Zacatecas',
    '93000',
    'test@test.com',
    5,
    true,
    false
  )
  ON CONFLICT DO NOTHING;

SELECT current_setting('glob_variables.encrypted_user_password');

UPDATE system_user SET
	password = current_setting('glob_variables.encrypted_user_password')::TEXT
  WHERE is_super_user = false;

UPDATE system_user SET
	password = current_setting('glob_variables.encrypted_super_user_password')::TEXT
  WHERE is_super_user = true;

INSERT INTO system_user_notification_levels
  (system_user_historical_id,id_notification_level)
VALUES
  ((SELECT historical_id FROM system_user WHERE id_system_user = 1),1),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 1),2),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 1),3),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 2),1),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 2),2),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 5),1),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 5),2),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 5),3),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 6),1),
  ((SELECT historical_id FROM system_user WHERE id_system_user = 6),2)
ON CONFLICT DO NOTHING;

--- Usuarios de servicio
INSERT INTO service_user (
  id_service_user,
  name,
  last_name,
  mothers_last_name,
  nickname,
  address_street,
  address_street_number,
  address_suburb,
  address_county,
  address_city,
  address_state,
  address_zip_code,
  email,
  enabled
)
VALUES
  (
    1,
    'Pedro',
    'Sanchéz',
    'Morales',
    'Pedro Sanchéz',
    'Australia',
    '945',
    'Gekaloka',
    'Tlalpan',
    'Chihuahua',
    'Chihuahua',
    '94386',
    'psanchez@sisu.mx',
    true
  ), --NIP "1234"
  (
    2,
    'Roberta',
    'Rodriguez',
    'Rodriguez',
    'Roberta Rodriguez',
    'Australia',
    '945',
    'Gekaloka',
    'Tlalpan',
    'Chihuahua',
    'Chihuahua',
    '91000',
    'rrodriguez@sisu.mx',
    true
  ), --NIP "1234"
  (
    3,
    'Carmela',
    'Viramontes',
    'Viramontes',
    'Carmela Viramontes',
    'Australia',
    '945',
    'Gekaloka',
    'Tlalpan',
    'Chihuahua',
    'Chihuahua',
    '67382',
    'cviramontes@sisu.mx',
    true
  ), --NIP "1234"
  (
    4,
    'Pablo',
    'Viramontes',
    'Viramontes',
    'Pablo Viramontes',
    'Australia',
    '945',
    'Gekaloka',
    'Tlalpan',
    'Chihuahua',
    'Chihuahua',
    '63728',
    'pviramontes@sisu.mx',
    true
  ), --NIP "1234"
  (
    5,
    'Jonathan',
    'Casas',
    'Casas',
    'Jonathan Casas',
    'Australia',
    '945',
    'Gekaloka',
    'Tlalpan',
    'Chihuahua',
    'Chihuahua',
    '57438',
    'jcasas@sisu.mx',
    true
  ) --NIP "1234"
  ON CONFLICT DO NOTHING;

UPDATE service_user SET
	nip = current_setting('glob_variables.encrypted_user_password')::TEXT;

--- Respuestas usuario de servicio
INSERT INTO service_user_responses (
  id_question,
  id_service_user,
  response
) VALUES 
  (1,1,'WALMART'),(2,1,'1/12/1990'),(3,1,'Zacatecas'),(4,1,'Sinaloa'),(5,1,'Carmen'),(6,1,'Pedro Velez'),
    (7,1,'Amarillo'),( 8,1,'Conchita'),(9,1,'Soltero'),(11,1,'Sí'),
  (1,2,'Soriana'),(2,2,'13/5/1980'),(3,2,'Queretaro'),(4,2,'Quintana Roo'),(5,2,'María'),( 6,2,'Víctor Rosales'),
    (7,2,'Rojo'),(8,2,'Firulais'),(9,2,'Casado'),(14,2,'3'),
  (1,3,'SISU'),(2,3,'30/9/2000'),(3,3,'Sonora'),(4,3,'Baja california'),(5,3,'Carolina'),(6,3,'González Ortega'),
    (7,3,'Verde'),(8,3,'Nube'),(9,3,'Soltero'),(11,3,'No'),
  (1,4,'Sams'),(2,4,'3/4/1970'),(3,4,'Oaxaca'),(4,4,'Michoacán'),(5,4,'Regina'),(6,4,'Olimpiada'),
    (7,4,'Negro'),(8,4,'Peluches'),(9,4,'Divorciado'),(14,4,'1'),
  (1,5,'Wings army'),(2,5,'13/8/1998'),(3,5,'Yucatán'),(4,5,'Veracruz'),(5,5,'Pamela'),(6,5,'Modelo'),
    (7,5,'Blanco'),(8,5,'Pelos'),(9,5,'Casado'),(11,5,'Sí')
ON CONFLICT DO NOTHING;

--- Grupos
INSERT INTO groups (
  id_group,
  name,
  description
) VALUES
  (1,'G0001','Grupo 1'),
  (2,'G0002','Grupo 2'),
  (3,'G0003','Grupo 3')
ON CONFLICT DO NOTHING;


--- Relación entre usuarios de servicio y grupos
INSERT INTO groups_service_user (
  id_service_user,
  id_group
) VALUES 
  (1,1),
  (2,3),
  (3,3)
ON CONFLICT DO NOTHING;

--- Sucursales
INSERT INTO branch (
  id_branch,
  name,
  address_street,
  address_street_number,
  address_suburb,
  address_county,
  address_city,
  address_state,
  address_zip_code,
  phone_number
) VALUES 
  (
    1,
    'S-0001 Plaza central',
    '5 de mayo',
    '457',
    'Cruz verde',
    'Xochi',
    'Xalapa',
    'Coahuila',
    '48547',
    '1234567890'
  ),
  (
    2,
    'S-0002 Zócalo',
    'Saturno',
    '398',
    'Cima alta',
    'Chimpalzingo',
    'Colotlán',
    'Zacatecas',
    '63267',
    '1234567890'
  ),
  (
    3,
    'S-0003 Plaza de armería',
    'Cáribe',
    '167',
    'Concha del oro',
    'Pozotlán',
    'Zapopán',
    'Chiapas',
    '84367',
    '1234567890'
  )
ON CONFLICT DO NOTHING;

--- Asignaciones
INSERT INTO assignment (
  id_assignment,
  id_terminal,
  id_lock
) VALUES 
  (1,1,1000),
  (2,2,1001),
  (3,3,1002),
  (4,4,1003),
  (5,5,1004),
  (6,6,1005),
  (7,7,1006),
  (8,8,1007)
ON CONFLICT DO NOTHING;


--- Cajeros
INSERT INTO terminal (
  id_terminal,
  id_assignment,
  id_branch,
  name,
  serie,
  model,
  version,
  randomic_lock_type
) VALUES 
  (1,1,1,'C01 Cajero 1','131','','',''),
  (2,2,3,'C02 Cajero 2','232','123','123','123'),
  (3,3,3,'C03 Cajero 3','333','','',''),
  (4,4,1,'C04 Cajero 4','434','','',''),
  (5,5,3,'C05 Cajero 5','535','','',''),
  (6,6,3,'C06 Cajero 6','636','','',''),
  (7,7,3,'C06 Cajero 7','737','','',''),
  (8,8,1,'C06 Cajero 8','838','','','')
ON CONFLICT DO NOTHING;

INSERT INTO terminal (
  id_terminal,
  id_branch,
  name,
  serie
) VALUES 
  (9,1,'C09 Cajero 9','939')
ON CONFLICT DO NOTHING;

--- Relación entre chapas y grupos
INSERT INTO group_terminal (
  id_terminal,
  id_group
) VALUES 
  (1,3),
  (4,3),
  (2,1),
  (3,1),
  (5,1),
  (6,1)
ON CONFLICT DO NOTHING;

-- alarmas
INSERT INTO alarms (
  id_lock,
  id_alarm_type
) VALUES 
  (1003,2),
  (1004,7)
ON CONFLICT DO NOTHING;

INSERT INTO alarms (
  id_lock,
  id_alarm_type,
  date_close
) VALUES 
  (1004,3,'2022-05-04 14:39:59.546539'),
  (1004,5,'2022-05-12 14:39:59.546539'),
  (1004,7,'2022-05-22 14:39:59.546539')
ON CONFLICT DO NOTHING;

-- Comando realizados en chapas
INSERT INTO randomic_operation
  (system_user_historical_id,service_user_historical_id,is_approved)
VALUES
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 1),
    (SELECT historical_id FROM service_user WHERE id_service_user = 1),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 2),
    (SELECT historical_id FROM service_user WHERE id_service_user = 2),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 3),
    (SELECT historical_id FROM service_user WHERE id_service_user = 3),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 1),
    (SELECT historical_id FROM service_user WHERE id_service_user = 4),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 4),
    (SELECT historical_id FROM service_user WHERE id_service_user = 1),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 1),
    (SELECT historical_id FROM service_user WHERE id_service_user = 1),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 2),
    (SELECT historical_id FROM service_user WHERE id_service_user = 2),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 1),
    (SELECT historical_id FROM service_user WHERE id_service_user = 4),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 4),
    (SELECT historical_id FROM service_user WHERE id_service_user = 1),
    true
  ),
  (
    (SELECT historical_id FROM system_user WHERE id_system_user = 2),
    (SELECT historical_id FROM service_user WHERE id_service_user = 2),
    true
  )
;

INSERT INTO commands (
  id_command,
  id_lock,
  cmd,
  expiration,
  date_created,
  id_randomic_operation
) VALUES 
  (1,1000,1,300,'2022-05-09 16:39:58.809401',1),
  (4,1001,1,300,'2022-05-09 16:39:58.809401',2),
  (5,1001,1,300,'2022-05-09 16:39:58.809401',3),
  (6,1003,1,300,'2022-05-09 16:39:58.809401',4),
  (7,1003,1,300,'2022-05-09 16:39:58.809401',5),
  (8,1003,1,300,'2022-05-09 16:39:58.809401',6)
ON CONFLICT DO NOTHING;

INSERT INTO commands (
  id_command,
  id_lock,
  cmd,
  expiration,
  date_apply,
  id_randomic_operation
) VALUES 
  (2,1000,1,4,CURRENT_TIMESTAMP,7),
  (9,1002,1,4,CURRENT_TIMESTAMP,8)
ON CONFLICT DO NOTHING;

INSERT INTO commands (
  id_command,
  id_lock,
  cmd,
  expiration,
  date_canceled,
  id_randomic_operation,
  canceled_description
) VALUES 
  (3,1000,1,3,CURRENT_TIMESTAMP,9,'Cancelado manual'),
  (10,1002,1,4,CURRENT_TIMESTAMP,10,'Cancelado manual')
ON CONFLICT DO NOTHING;

-- Events
INSERT INTO events (
  id_event_type,
  id_lock,
  event_date
)VALUES
  (1,1000,'2022-05-01 14:39:59.546539'),
  (2,1000,'2022-05-02 14:39:59.546539'),
  (3,1000,CURRENT_TIMESTAMP),

  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  (4,1003,'2022-05-04 14:39:59.546539'),
  (5,1003,'2022-05-01 14:39:59.546539'),
  (6,1003,'2022-04-01 14:39:59.546539'),
  (7,1003,CURRENT_TIMESTAMP),
  
  (8,1004,'2022-04-20 14:39:59.546539'),
  (20,1004,'2022-04-03 14:39:59.546539'),
  (21,1004,CURRENT_TIMESTAMP),
  (44,1005,CURRENT_TIMESTAMP),
  (23,1002,'2022-05-03 14:39:59.546539'),
  (37,1002,CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- blocked users
INSERT INTO randomic_operation_locks 
  (service_user_historical_id)
VALUES
  ((SELECT historical_id FROM service_user WHERE id_service_user = 3));

-- electronic_lock tests
INSERT INTO electronic_lock_tests
  (id_electronic_lock_test,id_lock,system_user_historical_id,success)
VALUES
  (1,1001,(SELECT historical_id FROM system_user WHERE id_system_user = 1),false),
  (2,1001,(SELECT historical_id FROM system_user WHERE id_system_user = 1),true),
  (3,1010,(SELECT historical_id FROM system_user WHERE id_system_user = 1),false),
  (4,1002,(SELECT historical_id FROM system_user WHERE id_system_user = 1),true)
ON CONFLICT DO NOTHING;

INSERT INTO electronic_lock_tests_steps
  (id_electronic_lock_test,step)
VALUES
  (1,1),
  (1,2),
  (1,3),
  (3,1),
  (3,2),
  (3,3),
  (3,4),
  (4,1),
  (4,2),
  (4,3),
  (4,4),
  (4,5),
  (4,6),
  (2,1),
  (2,2),
  (2,3),
  (2,4),
  (2,5),
  (2,6)
ON CONFLICT DO NOTHING;

INSERT INTO electronic_lock_tests_steps
  (id_electronic_lock_test,step,failed)
VALUES
  (1,4,true),
  (3,5,true)
ON CONFLICT DO NOTHING;-- AFTER INSERT electronic_lock PUSH historical_lock
CREATE OR REPLACE FUNCTION push_historical_lock_insert()
  	RETURNS trigger 
	VOLATILE  
AS
$$
BEGIN
	IF(NEW.work_mode IS NOT NULL) THEN
		INSERT INTO historical_lock (
			id_lock,
			id_work_mode
		)VALUES(
			NEW.id_lock,
			NEW.work_mode
		);
	END IF;
	RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER after_insert_electronic_lock_push_historical_lock
  AFTER INSERT
  ON electronic_lock
  FOR EACH ROW
  EXECUTE PROCEDURE push_historical_lock_insert();

-- BEFORE UPDATE electronic_lock PUSH historical_lock
CREATE OR REPLACE FUNCTION put_work_mode_date_update_electronic_lock()
  	RETURNS trigger 
	VOLATILE  
AS
$$
BEGIN
	IF(NEW.work_mode != OLD.work_mode) THEN
    NEW.work_mode_date = CURRENT_TIMESTAMP;
	END IF;
	RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER before_update_electronic_lock_work_mode_date
  BEFORE UPDATE
  ON electronic_lock
  FOR EACH ROW
  EXECUTE PROCEDURE put_work_mode_date_update_electronic_lock();

-- AFTER UPDATE electronic_lock PUSH historical_lock
CREATE OR REPLACE FUNCTION push_historical_lock_update()
  	RETURNS trigger 
	VOLATILE  
AS
$$
BEGIN
	IF(NEW.work_mode != OLD.work_mode) THEN
		INSERT INTO historical_lock (
			id_lock,
			id_work_mode
		)VALUES(
			NEW.id_lock,
			NEW.work_mode
		);
	END IF;
	RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER after_update_electronic_lock_push_historical_lock
  AFTER UPDATE
  ON electronic_lock
  FOR EACH ROW
  EXECUTE PROCEDURE push_historical_lock_update();DROP TYPE IF EXISTS jwt_token CASCADE;
CREATE TYPE jwt_token AS
(
	nickname text,
	name text,
	exp integer,
	email text,
	role text,
  historical_id text,
  valid_token text
);

CREATE EXTENSION IF NOT EXISTS pgcrypto;
--- get new notifications to push
CREATE OR REPLACE FUNCTION get_new_notifications_to_push()
  RETURNS TABLE(
    id INT,
    date TIMESTAMP WITH TIME ZONE,
    type TEXT,
    is_email_notification BOOLEAN,
    id_lock INT,
    id_notification_level INT,
    subject TEXT,
    message TEXT
  )
  STABLE
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    last_event_date TIMESTAMP;
    last_alarm_date TIMESTAMP;
    last_work_mode_date TIMESTAMP;
    id_event INT;
  BEGIN
    SELECT MAX(e.event_date) INTO last_event_date
    FROM event_notifications n 
      INNER JOIN events e ON e.id_event = n.id_event;

    SELECT MAX(a.date_start) INTO last_alarm_date 
    FROM alarm_notifications n
      INNER JOIN alarms a ON a.id_alarm = n.id_alarm;

    SELECT MAX(hl.work_mode_date) INTO last_work_mode_date 
    FROM historical_lock_notifications n
      INNER JOIN historical_lock hl ON hl.id_historical_lock = n.id_historical_lock;
    
    RETURN QUERY (
      (SELECT 
        e.id_event AS id, 
        e.event_date::TIMESTAMP WITH TIME ZONE AS date, 
        'event' AS type,
        et.is_email_notification,
        e.id_lock,
        nl.id_notification_level,
        CONCAT(nl.name, ': Cajero ',t.name),
        FORMAT(et.notification_message,t.name) as message
      FROM events e
        INNER JOIN event_type et ON et.id_event_type = e.id_event_type
        INNER JOIN notifications_level nl ON nl.id_notification_level = et.id_notification_level
        INNER JOIN electronic_lock el ON el.id_lock = e.id_lock
        INNER JOIN assignment assign ON assign.id_lock = el.id_lock
        INNER JOIN terminal t ON t.id_assignment = assign.id_assignment
          AND t.is_deleted = false
      WHERE CASE WHEN last_event_date IS NOT NULL THEN e.event_date > last_event_date ELSE true END
        AND et.is_notification = true
      )
    UNION
      (SELECT 
        a.id_alarm AS id, 
        a.date_start::TIMESTAMP WITH TIME ZONE AS date, 
        'alarm' AS type, 
        at.is_email_notification, 
        a.id_lock,
        nl.id_notification_level,
        CONCAT(nl.name, ': Cajero ',t.name),
        FORMAT(at.notification_message,t.name) as message
      FROM alarms a
        INNER JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
        INNER JOIN notifications_level nl ON nl.id_notification_level = at.id_notification_level
        INNER JOIN electronic_lock el ON el.id_lock = a.id_lock
        INNER JOIN assignment assign ON assign.id_lock = el.id_lock
        INNER JOIN terminal t ON t.id_assignment = assign.id_assignment
          AND t.is_deleted = false
      WHERE CASE WHEN last_alarm_date IS NOT NULL THEN a.date_start > last_alarm_date ELSE true END
        AND at.is_notification = true
      )
    UNION
      (SELECT 
        hl.id_historical_lock AS id, 
        hl.work_mode_date::TIMESTAMP WITH TIME ZONE AS date, 
        'historical_lock' AS type, 
        wm.is_email_notification, 
        hl.id_lock,
        nl.id_notification_level,
        CASE 
          WHEN wm.link_to = 'lock' THEN CONCAT(nl.name,': Chapa ',el.id_lock) 
          WHEN wm.link_to = 'cashier' THEN CONCAT(nl.name,': Cajero' ,t.name) 
        END,
        CASE 
          WHEN wm.link_to = 'lock' THEN FORMAT(wm.notification_message,el.id_lock) 
          WHEN wm.link_to = 'cashier' THEN FORMAT(wm.notification_message,t.name) 
        END
      FROM historical_lock hl
        INNER JOIN work_mode wm ON wm.id_work_mode = hl.id_work_mode
        INNER JOIN notifications_level nl ON nl.id_notification_level = wm.id_notification_level
        INNER JOIN electronic_lock el ON el.id_lock = hl.id_lock
        LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
        LEFT JOIN terminal t ON t.id_terminal = assign.id_terminal
          AND t.is_deleted = false
      WHERE CASE WHEN last_work_mode_date IS NOT NULL THEN hl.work_mode_date > last_work_mode_date ELSE true END
        AND wm.is_notification = true
      )
    ORDER BY date
    );
  END;
$FUNCTION$;

--- insert new event notification for all users
CREATE OR REPLACE FUNCTION insert_new_event_notification(
  id_event INT
)
 RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
AS 
$FUNCTION$
  DECLARE 
    system_user_historical_id TEXT;
  BEGIN
    FOR system_user_historical_id IN 
      SELECT su.historical_id FROM events e
        INNER JOIN event_type et ON et.id_event_type = e.id_event_type
        INNER JOIN notifications_level nl ON nl.id_notification_level = et.id_notification_level
        INNER JOIN system_user_notification_levels sunl ON sunl.id_notification_level = nl.id_notification_level
        INNER JOIN system_user su ON su.historical_id = sunl.system_user_historical_id 
          AND su.is_deleted = false AND su.enabled = true
        WHERE e.id_event = insert_new_event_notification.id_event
    LOOP
      INSERT INTO event_notifications
        (id_event,system_user_historical_id)
      VALUES
        (insert_new_event_notification.id_event,system_user_historical_id);
    END LOOP;
  END;
$FUNCTION$;

--- insert new alarm notification for all users
CREATE OR REPLACE FUNCTION insert_new_alarm_notification(
  id_alarm INT
)
 RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
AS 
$FUNCTION$
  DECLARE 
    system_user_historical_id TEXT;
  BEGIN
    FOR system_user_historical_id IN 
      SELECT su.historical_id FROM alarms a
        INNER JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
        INNER JOIN notifications_level nl ON nl.id_notification_level = at.id_notification_level
        INNER JOIN system_user_notification_levels sunl ON sunl.id_notification_level = nl.id_notification_level
        INNER JOIN system_user su ON su.historical_id = sunl.system_user_historical_id 
          AND su.is_deleted = false AND su.enabled = true
        WHERE a.id_alarm = insert_new_alarm_notification.id_alarm
    LOOP
      INSERT INTO alarm_notifications
        (id_alarm,system_user_historical_id)
      VALUES
        (insert_new_alarm_notification.id_alarm,system_user_historical_id);
    END LOOP;
  END;
$FUNCTION$;

--- insert new historical_lock notification for all users
CREATE OR REPLACE FUNCTION insert_new_historical_lock_notification(
  id_historical_lock INT
)
 RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
AS 
$FUNCTION$
  DECLARE 
    system_user_historical_id TEXT;
  BEGIN
    FOR system_user_historical_id IN 
      SELECT su.historical_id FROM historical_lock hl
        INNER JOIN work_mode wm ON wm.id_work_mode = hl.id_work_mode
        INNER JOIN notifications_level nl ON nl.id_notification_level = wm.id_notification_level
        INNER JOIN system_user_notification_levels sunl ON sunl.id_notification_level = nl.id_notification_level
        INNER JOIN system_user su ON su.historical_id = sunl.system_user_historical_id 
          AND su.is_deleted = false AND su.enabled = true
        WHERE hl.id_historical_lock = insert_new_historical_lock_notification.id_historical_lock
    LOOP
      INSERT INTO historical_lock_notifications
        (id_historical_lock,system_user_historical_id)
      VALUES
        (insert_new_historical_lock_notification.id_historical_lock,system_user_historical_id);
    END LOOP;
  END;
$FUNCTION$;

-- Get last x notifications
CREATE OR REPLACE FUNCTION get_last_notifications(quantity INT,system_user_historical_id TEXT,
  OUT notifications JSONB [],
  OUT un_read_quantity INT
)
 LANGUAGE plpgsql
 VOLATILE
AS 
$FUNCTION$
  DECLARE
    notification_json JSONB;
  BEGIN
    PERFORM check_token_validity();
    un_read_quantity := (SELECT 
        COUNT(n.id_event_notification)
      FROM event_notifications n
      WHERE n.system_user_historical_id = get_last_notifications.system_user_historical_id AND n.seen = false)::INT;

    un_read_quantity := un_read_quantity + (SELECT 
        COUNT(n.id_alarm_notification)
      FROM alarm_notifications n
      WHERE n.system_user_historical_id = get_last_notifications.system_user_historical_id AND n.seen = false)::INT;

    un_read_quantity := un_read_quantity + (SELECT 
        COUNT(n.id_historical_lock_notification)
      FROM historical_lock_notifications n
      WHERE n.system_user_historical_id = get_last_notifications.system_user_historical_id AND n.seen = false)::INT;

    get_last_notifications.notifications := ARRAY(
      SELECT 
        jsonb_build_object(
          'id_notification',notifications.id_notification,
          'type',notifications.type, 
          'title',notifications.title,
          'message',notifications.message,
          'date',notifications.date::TIMESTAMP WITH TIME ZONE, 
          'seen',notifications.seen,
          'is_new',notifications.is_new,
          'terminal_historical_id',notifications.historical_id,
          'id_electronic_lock',notifications.id_electronic_lock
        )
        FROM
      ( 
        SELECT
          n.id_event_notification as id_notification,
          'event' as type,
          nl.name as title,
          FORMAT(et.notification_message,t.name) as message,
          e.event_date as date, 
          n.seen,
          e.event_date + current_setting('glob_variables.notifications_minutes_as_new')::INT * INTERVAL'1 minute' > CURRENT_TIMESTAMP AND n.is_new as is_new,
          t.historical_id::TEXT,
          el.id_electronic_lock
        FROM event_notifications n
          INNER JOIN events e ON e.id_event = n.id_event
          INNER JOIN event_type et ON et.id_event_type = e.id_event_type
          INNER JOIN notifications_level nl ON nl.id_notification_level = et.id_notification_level
          INNER JOIN electronic_lock el ON el.id_lock = e.id_lock
          LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
          LEFT JOIN terminal t ON t.id_assignment = assign.id_assignment
            AND t.is_deleted = false
        WHERE n.system_user_historical_id = get_last_notifications.system_user_historical_id
      UNION
        SELECT
          n.id_alarm_notification,
          'alarm' as type,
          nl.name,
          FORMAT(at.notification_message,t.name) ,
          a.date_start, 
          n.seen,
          a.date_start + current_setting('glob_variables.notifications_minutes_as_new')::INT * INTERVAL'1 minute' > CURRENT_TIMESTAMP AND n.is_new,
          t.historical_id::TEXT,
          el.id_electronic_lock
        FROM alarm_notifications n
          INNER JOIN alarms a ON a.id_alarm = n.id_alarm
          INNER JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
          INNER JOIN notifications_level nl ON nl.id_notification_level = at.id_notification_level
          INNER JOIN electronic_lock el ON el.id_lock = a.id_lock
          LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
          LEFT JOIN terminal t ON t.id_assignment = assign.id_assignment
            AND t.is_deleted = false
        WHERE n.system_user_historical_id = get_last_notifications.system_user_historical_id
      UNION
        SELECT
          n.id_historical_lock_notification,
          wm.link_to,
          nl.name,
          CASE 
            WHEN wm.link_to = 'lock' THEN FORMAT(wm.notification_message,el.id_lock) 
            WHEN wm.link_to = 'cashier' THEN FORMAT(wm.notification_message,t.name) 
          END,
          hl.work_mode_date, 
          n.seen,
          hl.work_mode_date + current_setting('glob_variables.notifications_minutes_as_new')::INT * INTERVAL'1 minute' > CURRENT_TIMESTAMP AND n.is_new,
          t.historical_id::TEXT,
          el.id_electronic_lock
        FROM historical_lock_notifications n
          INNER JOIN historical_lock hl ON hl.id_historical_lock = n.id_historical_lock
          INNER JOIN work_mode wm ON hl.id_work_mode = wm.id_work_mode
          INNER JOIN notifications_level nl ON nl.id_notification_level = wm.id_notification_level
          INNER JOIN electronic_lock el ON el.id_lock = hl.id_lock
          LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
          LEFT JOIN terminal t ON t.id_terminal = assign.id_terminal
            AND t.is_deleted = false
        WHERE n.system_user_historical_id = get_last_notifications.system_user_historical_id
      ) as notifications
      ORDER BY notifications.date DESC, notifications.id_notification
        LIMIT quantity
    );
    FOREACH notification_json IN ARRAY get_last_notifications.notifications LOOP
      IF(notification_json->>'is_new') THEN
        IF(notification_json->>'type' = 'event') THEN
          UPDATE event_notifications n SET
            is_new = false
          WHERE n.id_event_notification = (notification_json->>'id_notification')::INT;
        ELSIF(notification_json->>'type' = 'alarm') THEN
          UPDATE alarm_notifications n SET
            is_new = false
          WHERE n.id_alarm_notification = (notification_json->>'id_notification')::INT;
        ELSE
          UPDATE historical_lock_notifications n SET
            is_new = false
          WHERE n.id_historical_lock_notification = (notification_json->>'id_notification')::INT;
        END IF;
      END IF;
    END LOOP;
    RETURN;
  END;
$FUNCTION$;

--- mark event notifications with seen = true status
CREATE OR REPLACE FUNCTION read_event_notification(id_event_notification INT)
 RETURNS void
 LANGUAGE plpgsql
 VOLATILE
AS 
$FUNCTION$
  BEGIN    
    PERFORM check_token_validity();
    UPDATE event_notifications n SET
      seen = true
    WHERE n.id_event_notification = read_event_notification.id_event_notification;
  END;
$FUNCTION$;

--- mark alarm notifications with seen = true status
CREATE OR REPLACE FUNCTION read_alarm_notification(id_alarm_notification INT)
 RETURNS void
 LANGUAGE plpgsql
 VOLATILE
AS 
$FUNCTION$
  BEGIN    
    PERFORM check_token_validity();
    UPDATE alarm_notifications n SET
      seen = true
    WHERE n.id_alarm_notification = read_alarm_notification.id_alarm_notification;
  END;
$FUNCTION$;

--- mark historical_lock notifications with seen = true status
CREATE OR REPLACE FUNCTION read_historical_lock_notification(id_historical_lock_notification INT)
 RETURNS void
 LANGUAGE plpgsql
 VOLATILE
AS 
$FUNCTION$
  BEGIN    
    PERFORM check_token_validity();
    UPDATE historical_lock_notifications n SET
      seen = true
    WHERE n.id_historical_lock_notification = read_historical_lock_notification.id_historical_lock_notification;
  END;
$FUNCTION$;

-- get notifications
CREATE OR REPLACE FUNCTION get_notifications(
    system_user_historical_id TEXT,
    filters TEXT
  )
  RETURNS TABLE(
    id_notification INT,
    id_cashier TEXT,
    type TEXT,
    title TEXT,
    message TEXT,
    date TIMESTAMP WITH TIME ZONE,
    seen BOOLEAN,
    terminal_historical_id TEXT,
    id_electronic_lock INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    json_filters JSON;
    type_filter TEXT;
    id_cashier_filter TEXT;
    message_filter TEXT;
    seen_filter BOOLEAN;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_cashier_filter := json_filters->'idCashier'->>'value';
    type_filter := json_filters->'title'->>'value';
    message_filter := json_filters->'message'->>'value';
    seen_filter := json_filters->'seen'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    RETURN QUERY
      SELECT 
        n.id_notification,
        t.name::TEXT,
        n.type,
        n.title,
        CASE 
          WHEN n.type = 'lock' THEN FORMAT(n.message,el.id_lock) 
          ELSE FORMAT(n.message,t.name) 
        END as message,
        n.date::TIMESTAMP WITH TIME ZONE,
        n.seen,
        t.historical_id::TEXT,
        el.id_electronic_lock
      FROM
        (
          SELECT 
            n.id_event_notification as id_notification,
            'event' as type, 
            nl.name as title,
            et.notification_message as message,
            e.event_date as date, 
            n.seen,
            e.id_lock,
            n.system_user_historical_id
          FROM event_notifications n
            INNER JOIN events e ON e.id_event = n.id_event
            INNER JOIN event_type et ON et.id_event_type = e.id_event_type
            INNER JOIN notifications_level nl ON nl.id_notification_level = et.id_notification_level
        UNION
          SELECT 
            n.id_alarm_notification,
            'alarm', 
            nl.name,
            at.notification_message,
            a.date_start, 
            n.seen,
            a.id_lock,
            n.system_user_historical_id
          FROM alarm_notifications n
            INNER JOIN alarms a ON a.id_alarm = n.id_alarm
            INNER JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
            INNER JOIN notifications_level nl ON nl.id_notification_level = at.id_notification_level
        UNION
          SELECT 
            n.id_historical_lock_notification,
            wm.link_to, 
            nl.name,
            wm.notification_message,
            hl.work_mode_date, 
            n.seen,
            hl.id_lock,
            n.system_user_historical_id
          FROM historical_lock_notifications n
            INNER JOIN historical_lock hl ON hl.id_historical_lock = n.id_historical_lock
            INNER JOIN work_mode wm ON wm.id_work_mode = hl.id_work_mode
            INNER JOIN notifications_level nl ON nl.id_notification_level = wm.id_notification_level
        ) as n 
        INNER JOIN electronic_lock el ON el.id_lock = n.id_lock
        LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
        LEFT JOIN terminal t ON t.id_terminal = assign.id_terminal
          AND t.is_deleted = false
      WHERE 
        n.system_user_historical_id = get_notifications.system_user_historical_id
        AND 
          CASE
            WHEN id_cashier_filter IS NOT NULL AND id_cashier_filter != '' 
              THEN LOWER(t.name) LIKE CONCAT('%',LOWER(id_cashier_filter),'%')
            ELSE true
          END
        AND 
          CASE
            WHEN type_filter IS NOT NULL AND type_filter != '' 
              THEN n.title = type_filter
            ELSE true
          END
        AND
          CASE
            WHEN message_filter IS NOT NULL AND message_filter != ''
              THEN 
                CASE 
                  WHEN n.type = 'lock' THEN LOWER(FORMAT(n.message,el.id_lock))
                  ELSE LOWER(FORMAT(n.message,t.name))
                END LIKE CONCAT('%',LOWER(message_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN seen_filter IS NOT NULL
              THEN n.seen = seen_filter
            ELSE true
          END
        AND
          CASE
            WHEN date_finish IS NOT NULL THEN 
              n.date >= date_init AND n.date <= date_finish
            ELSE true
          END
      ORDER BY n.date DESC, n.id_notification;
  END;
$function$;

-- get new notifications
CREATE OR REPLACE FUNCTION get_new_notifications(
    system_user_historical_id TEXT,
    last_date TEXT,
    filters TEXT
  )
  RETURNS TABLE(
    id_notification INT,
    id_cashier TEXT,
    type TEXT,
    title TEXT,
    message TEXT,
    date TIMESTAMP WITH TIME ZONE,
    seen BOOLEAN,
    terminal_historical_id TEXT,
    id_electronic_lock INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    ids_notifications INT[];
    json_filters JSON;
    id_cashier_filter TEXT;
    type_filter TEXT;
    message_filter TEXT;
    seen_filter BOOLEAN;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_cashier_filter := json_filters->'idCashier'->>'value';
    type_filter := json_filters->'title'->>'value';
    message_filter := json_filters->'message'->>'value';
    seen_filter := json_filters->'seen'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    last_date := last_date;
    
    RETURN QUERY
      SELECT 
        n.id_notification,
        t.name::TEXT,
        n.type,
        n.title,
        CASE 
          WHEN n.type = 'lock' THEN FORMAT(n.message,el.id_lock) 
          ELSE FORMAT(n.message,t.name) 
        END as message,
        n.date::TIMESTAMP WITH TIME ZONE,
        n.seen,
        t.historical_id::TEXT,
        el.id_electronic_lock
      FROM
        (
          SELECT 
            n.id_event_notification as id_notification,
            'event' as type, 
            nl.name as title,
            et.notification_message as message,
            e.event_date as date, 
            n.seen,
            e.id_lock,
            n.system_user_historical_id
          FROM event_notifications n
            INNER JOIN events e ON e.id_event = n.id_event
            INNER JOIN event_type et ON et.id_event_type = e.id_event_type
            INNER JOIN notifications_level nl ON nl.id_notification_level = et.id_notification_level
        UNION
          SELECT 
            n.id_alarm_notification,
            'alarm', 
            nl.name,
            at.notification_message,
            a.date_start, 
            n.seen,
            a.id_lock,
            n.system_user_historical_id
          FROM alarm_notifications n
            INNER JOIN alarms a ON a.id_alarm = n.id_alarm
            INNER JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
            INNER JOIN notifications_level nl ON nl.id_notification_level = at.id_notification_level
        UNION
          SELECT 
            n.id_historical_lock_notification,
            wm.link_to, 
            nl.name,
            wm.notification_message,
            hl.work_mode_date, 
            n.seen,
            hl.id_lock,
            n.system_user_historical_id
          FROM historical_lock_notifications n
            INNER JOIN historical_lock hl ON hl.id_historical_lock = n.id_historical_lock
            INNER JOIN work_mode wm ON wm.id_work_mode = hl.id_work_mode
            INNER JOIN notifications_level nl ON nl.id_notification_level = wm.id_notification_level
        ) as n 
        INNER JOIN electronic_lock el ON el.id_lock = n.id_lock
        LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
        LEFT JOIN terminal t ON t.id_terminal = assign.id_terminal
          AND t.is_deleted = false
      WHERE 
        n.system_user_historical_id = get_new_notifications.system_user_historical_id
        AND 
          CASE
            WHEN last_date IS NOT NULL AND last_date != '' 
              THEN n.date::TIMESTAMP(0) > last_date::TIMESTAMP(0)
            ELSE true
          END
        AND 
          CASE
            WHEN id_cashier_filter IS NOT NULL AND id_cashier_filter != '' 
              THEN LOWER(t.name) LIKE CONCAT('%',LOWER(id_cashier_filter),'%')
            ELSE true
          END
        AND 
          CASE
            WHEN type_filter IS NOT NULL AND type_filter != '' 
              THEN n.title = type_filter
            ELSE true
          END
        AND
          CASE
            WHEN message_filter IS NOT NULL AND message_filter != ''
              THEN 
                CASE 
                  WHEN n.type = 'lock' THEN LOWER(FORMAT(n.message,el.id_lock))
                  ELSE LOWER(FORMAT(n.message,t.name))
                END LIKE CONCAT('%',LOWER(message_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN seen_filter IS NOT NULL
              THEN n.seen = seen_filter
            ELSE true
          END
        AND
          CASE
            WHEN date_finish IS NOT NULL THEN 
              n.date >= date_init AND n.date <= date_finish
            ELSE true
          END
      ORDER BY n.date DESC, n.id_notification;
  END;
$function$;

CREATE OR REPLACE FUNCTION get_notifications_levels()
  RETURNS TABLE (
    id_notification_level INT,
    name TEXT
  )
  LANGUAGE plpgsql
  STABLE
AS
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT
        nl.id_notification_level,
        nl.name
      FROM notifications_level nl;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION get_notifications_types()
 RETURNS TABLE (
   type TEXT,
   id_notification INT, 
   message TEXT,
   is_email_notification BOOLEAN,
   id_notification_level INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT * FROM
        (
          SELECT 
            'event' as type,
            et.id_event_type as id,
            FORMAT(et.notification_message,'[id cajero]') as message,
            et.is_email_notification,
            et.id_notification_level
          from event_type et 
          where et.is_notification = true
          
        UNION
          SELECT 
            'alarm' as type,
            at.id_alarm_type as id,
            FORMAT(at.notification_message,'[id cajero]') as message,
            at.is_email_notification,
            at.id_notification_level
          from alarm_type at 
          where at.is_notification = true
        UNION
          SELECT 
            'work_mode' as type,
            wm.id_work_mode as id,
            CASE WHEN wm.link_to = 'lock' 
              THEN FORMAT(wm.notification_message,'[id chapa]')
              ELSE FORMAT(wm.notification_message,'[id cajero]')
            END as message,
            wm.is_email_notification,
            wm.id_notification_level
          from work_mode wm 
          where wm.is_notification = true
        ) as notifications
        ORDER BY notifications.type,notifications.id;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION set_notifications_types(
  IN notifications_types TEXT
)
  RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
AS 
$function$
  DECLARE
    json_notifications_types JSON;
    type TEXT;
    id INT;
  BEGIN
    PERFORM check_token_validity();
    json_notifications_types := notifications_types::JSON;
    FOR i IN 0..json_array_length(json_notifications_types)-1 LOOP
      type := json_notifications_types->i->>'type';
      id := json_notifications_types->i->>'idNotification';
      IF(type = 'alarm') THEN 
		UPDATE alarm_type at SET
		  id_notification_level = (json_notifications_types->i->>'idNotificationLevel')::INT,
		  is_email_notification = (json_notifications_types->i->>'isEmailNotification')::BOOLEAN
		WHERE at.id_alarm_type = id;
	  ELSIF(type = 'event') THEN
		UPDATE event_type et SET
		  id_notification_level = (json_notifications_types->i->>'idNotificationLevel')::INT,
		  is_email_notification = (json_notifications_types->i->>'isEmailNotification')::BOOLEAN
		WHERE et.id_event_type = id;
      ELSIF(type = 'work_mode') THEN
		UPDATE work_mode wm SET
		  id_notification_level = (json_notifications_types->i->>'idNotificationLevel')::INT,
		  is_email_notification = (json_notifications_types->i->>'isEmailNotification')::BOOLEAN
		WHERE wm.id_work_mode = id;
      END IF;
    END LOOP;
  END;
$function$;-- new branch
CREATE OR REPLACE FUNCTION insert_new_branch (
  name TEXT,
  address_street TEXT,
  address_street_number TEXT,
  address_suite_number TEXT,
  address_suburb TEXT,
  address_county TEXT,
  address_city TEXT,
  address_state TEXT,
  address_zip_code TEXT,
  phone_number TEXT
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$function$
  DECLARE
    jwt_historical_id TEXT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    INSERT INTO branch (
      name,
      address_street,
      address_street_number,
      address_suite_number,
      address_suburb,
      address_county,
      address_city,
      address_state,
      address_zip_code,
      phone_number,
      historical_action_user_id
    )
    VALUES(
      insert_new_branch.name,
      insert_new_branch.address_street,
      insert_new_branch.address_street_number,
      insert_new_branch.address_suite_number,
      insert_new_branch.address_suburb,
      insert_new_branch.address_county,
      insert_new_branch.address_city,
      insert_new_branch.address_state,
      insert_new_branch.address_zip_code,
      insert_new_branch.phone_number,
      jwt_historical_id
    );
  END;
$function$;

-- get branches
CREATE OR REPLACE FUNCTION get_all_branches()
 RETURNS TABLE (
   id_branch INT, 
   branch_historical_id TEXT, 
   name TEXT, 
   address_city TEXT, 
   address_state TEXT, 
   phone_number TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
    SELECT branch.id_branch::INT,
      branch.historical_id::TEXT,
      branch.name::TEXT,
      branch.address_city::TEXT,
      branch.address_state::TEXT,
      branch.phone_number::TEXT
    FROM branch
    WHERE branch.is_deleted = false
    ORDER BY branch.name;
  END;
$function$;

-- get branches by status
CREATE OR REPLACE FUNCTION get_all_branches_by_status(enabled boolean)
 RETURNS TABLE (
   id_branch INT, 
   branch_historical_id TEXT,
   name TEXT, 
   address_city TEXT, 
   address_state TEXT, 
   phone_number TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT branch.id_branch::INT,
      branch.historical_id::TEXT,
        branch.name::TEXT,
        branch.address_city::TEXT,
        branch.address_state::TEXT,
        branch.phone_number::TEXT
      FROM branch
      WHERE branch.is_deleted = false AND branch.enabled = get_all_branches_by_status.enabled
      ORDER BY branch.name;
  END;
$function$;


--get branch by id
CREATE OR REPLACE FUNCTION get_branch_by_historical_id(
  IN branch_historical_id TEXT,
  OUT id_branch INT,
  OUT name TEXT,
  OUT phone_number TEXT,
  OUT address_street TEXT,
  OUT address_street_number TEXT,
  OUT address_suite_number TEXT,
  OUT address_zip_code TEXT,
  OUT address_suburb TEXT,
  OUT address_county TEXT,
  OUT address_city TEXT,
  OUT address_state TEXT,
  OUT enabled BOOLEAN
)
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    SELECT 
      branch.id_branch::INT,
      branch.name::TEXT,
      branch.phone_number::TEXT,
      branch.address_street::TEXT,
      branch.address_street_number::TEXT,
      branch.address_suite_number::TEXT,
      branch.address_zip_code::TEXT,
      branch.address_suburb::TEXT,
      branch.address_county::TEXT,
      branch.address_city::TEXT,
      branch.address_state::TEXT,
      branch.enabled
    INTO
      id_branch,
      name,
      phone_number,
      address_street,
      address_street_number,
      address_suite_number,
      address_zip_code,
      address_suburb,
      address_county,
      address_city,
      address_state,
      enabled
    FROM branch WHERE branch.historical_id = branch_historical_id AND branch.is_deleted = false LIMIT 1;
    RETURN;
  END;
$function$;


-- update branch
CREATE OR REPLACE FUNCTION update_branch (
  name TEXT,
  address_street TEXT,
  address_street_number TEXT,
  address_suite_number TEXT,
  address_suburb TEXT,
  address_county TEXT,
  address_city TEXT,
  address_state TEXT,
  address_zip_code TEXT,
  phone_number TEXT,
  branch_historical_id TEXT
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$function$
  DECLARE
    jwt_historical_id TEXT;
    new_id_terminal INT;
    historical_id_terminal TEXT;
    historical_ids_terminals TEXT [];
    new_id_branch INT;
    last_ids_terminals INT[];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    INSERT INTO branch (
      name,
      address_street,
      address_street_number,
      address_suite_number,
      address_suburb,
      address_county,
      address_city,
      address_state,
      address_zip_code,
      phone_number,
      enabled,
      date_updated, 
      historical_action, 
      historical_action_user_id, 
      historical_id
    )
    SELECT 
      update_branch.name,
      update_branch.address_street,
      update_branch.address_street_number,
      update_branch.address_suite_number,
      update_branch.address_suburb,
      update_branch.address_county,
      update_branch.address_city,
      update_branch.address_state,
      update_branch.address_zip_code,
      update_branch.phone_number,
      b.enabled,
      CURRENT_TIMESTAMP, 
      'MODIFICACIÓN', 
      jwt_historical_id, 
      b.historical_id
        from branch as b WHERE b.historical_id= branch_historical_id AND b.is_deleted = false;
    
    SELECT currval('branch_id_branch_seq') into new_id_branch;

    historical_ids_terminals := ARRAY(SELECT t.historical_id
      FROM terminal AS t 
        INNER JOIN branch b ON b.id_branch = t.id_branch
      WHERE t.is_deleted = false AND b.historical_id = branch_historical_id AND b.is_deleted = false);

    IF(historical_ids_terminals is not null) THEN
      FOREACH historical_id_terminal IN ARRAY (historical_ids_terminals)
      LOOP
        INSERT INTO terminal(
          status,
          status_description,
          id_key,
          name,
          id_assignment,
          enabled,
          id_branch,
          version,
          serie,
          randomic_lock_type,
          model,
          historical_id,
          date_updated,
          historical_action
        )SELECT
          t.status,
          t.status_description,
          t.id_key,
          t.name,
          t.id_assignment,
          t.enabled,
          new_id_branch,
          t.version,
          t.serie,
          t.randomic_lock_type,
          t.model,
          t.historical_id,
          CURRENT_TIMESTAMP, 
          'MODIFICACIÓN'
        FROM terminal t WHERE t.historical_id = historical_id_terminal AND t.is_deleted = false;

        SELECT currval('terminal_id_terminal_seq') into new_id_terminal;

        UPDATE assignment assign SET
          id_terminal = new_id_terminal
        FROM terminal t
        WHERE t.id_terminal = assign.id_terminal AND t.historical_id = historical_id_terminal;

        INSERT INTO group_terminal(
          id_group,
          id_terminal,
          historical_id,
          historical_action_user_id,
          date_updated,
          historical_action
        )SELECT
          gt.id_group,
          new_id_terminal,
          gt.historical_id,
          jwt_historical_id,
          CURRENT_TIMESTAMP, 
          'MODIFICACIÓN'
        FROM group_terminal gt 
          INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
        WHERE t.historical_id = historical_id_terminal AND t.is_deleted = false AND gt.is_deleted = false;
      END LOOP;

      last_ids_terminals := ARRAY(SELECT MAX(t.id_terminal) FROM terminal t
        WHERE t.historical_id = ANY(historical_ids_terminals) GROUP BY t.historical_id);

      UPDATE group_terminal gt SET
        is_deleted = true
        FROM terminal t
        WHERE gt.id_terminal = t.id_terminal AND gt.is_deleted = false AND
          t.historical_id = ANY(historical_ids_terminals) AND t.is_deleted = false AND
            NOT(t.id_terminal = ANY(last_ids_terminals));

      UPDATE terminal t SET
        is_deleted = true
        WHERE t.historical_id = ANY(historical_ids_terminals) AND t.is_deleted = false AND
            NOT(t.id_terminal = ANY(last_ids_terminals));
    END IF;

    UPDATE branch b SET
      is_deleted = true
      WHERE
        b.historical_id = branch_historical_id AND b.is_deleted = false
          AND b.id_branch != new_id_branch;
  END;
$function$;

--- disable branches
CREATE OR REPLACE FUNCTION disable_branch(historical_ids TEXT[])
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE
    jwt_historical_id TEXT;
    new_id_branch INT;
    new_id_terminal INT;
    terminal_historical_id TEXT;
    next_historical_id TEXT;
    terminal_historical_ids TEXT[];
    last_ids_terminals INT [];
    last_ids_branch INT [];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    FOREACH next_historical_id IN ARRAY(historical_ids)
    LOOP 
      INSERT INTO branch (
        name,
        address_street,
        address_street_number,
        address_suite_number,
        address_suburb,
        address_county,
        address_city,
        address_state,
        address_zip_code,
        phone_number,
        enabled,
        historical_action, 
        historical_action_user_id, 
        historical_id,
        date_updated
      )
      SELECT 
        b.name,
        b.address_street,
        b.address_street_number,
        b.address_suite_number,
        b.address_suburb,
        b.address_county,
        b.address_city,
        b.address_state,
        b.address_zip_code,
        b.phone_number,
        false,
        'DESHABILITACIÓN', 
        jwt_historical_id, 
        b.historical_id,
        CURRENT_TIMESTAMP
          from branch as b WHERE b.historical_id = next_historical_id AND b.is_deleted = false;
    
      SELECT currval('branch_id_branch_seq') into new_id_branch;

      terminal_historical_ids := ARRAY(SELECT t.historical_id
        FROM terminal AS t 
          INNER JOIN branch b ON t.id_branch = b.id_branch
        WHERE t.is_deleted = false AND b.historical_id = next_historical_id AND b.is_deleted = false);

      if(terminal_historical_ids is not null) THEN
        FOREACH terminal_historical_id IN ARRAY(terminal_historical_ids)
        LOOP
          INSERT INTO terminal(
            status,
            status_description,
            id_key,
            name,
            id_assignment,
            enabled,
            id_branch,
            version,
            serie,
            randomic_lock_type,
            model,
            historical_action_user_id,
            historical_id,
            historical_action,
            date_updated
          )SELECT
            t.status,
            t.status_description,
            t.id_key,
            t.name,
            t.id_assignment,
            t.enabled,
            new_id_branch,
            t.version,
            t.serie,
            t.randomic_lock_type,
            t.model,
            jwt_historical_id,
            t.historical_id,
            'DESHABILITACIÓN',
            CURRENT_TIMESTAMP
          FROM terminal t WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false;

          SELECT currval('terminal_id_terminal_seq') into new_id_terminal;

          UPDATE assignment assign SET
            id_terminal = new_id_terminal
          FROM terminal t
          WHERE t.id_terminal = assign.id_terminal AND t.historical_id = terminal_historical_id;

          INSERT INTO group_terminal(
            id_group,
            id_terminal,
            historical_id,
            historical_action_user_id,
            historical_action,
            date_updated
          )SELECT
            gt.id_group,
            new_id_terminal,
            gt.historical_id,
            jwt_historical_id,
            'DESHABILITACIÓN',
            CURRENT_TIMESTAMP
          FROM group_terminal gt 
            INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
          WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false AND gt.is_deleted = false;
        END LOOP;

        last_ids_terminals := ARRAY(SELECT MAX(t.id_terminal) FROM terminal t 
          WHERE t.historical_id = ANY(terminal_historical_ids) GROUP by t.historical_id);

        UPDATE group_terminal gt SET
          is_deleted = true
        FROM terminal t
        WHERE
          gt.id_terminal = t.id_terminal AND gt.is_deleted = false AND
          t.historical_id = ANY(terminal_historical_ids) AND t.is_deleted = false 
            AND NOT(t.id_terminal = ANY(last_ids_terminals));

        UPDATE terminal t SET
          is_deleted = true
        WHERE
          t.historical_id = ANY(terminal_historical_ids) AND t.is_deleted = false 
            AND NOT(t.id_terminal = ANY(last_ids_terminals));
      END IF;
    END LOOP;

    last_ids_branch := ARRAY(SELECT MAX(b.id_branch) FROM branch b
          WHERE b.historical_id = ANY(historical_ids) GROUP by b.historical_id);

    UPDATE branch b SET
      is_deleted = true
    WHERE
      b.historical_id = ANY(historical_ids) AND b.is_deleted = false
        AND NOT(b.id_branch = ANY(last_ids_branch));
  END;
$FUNCTION$;

--- enable branches
CREATE OR REPLACE FUNCTION enable_branch(historical_ids TEXT[])
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE
    jwt_historical_id TEXT;
    new_id_branch INT;
    new_id_terminal INT;
    terminal_historical_id TEXT;
    next_historical_id TEXT;
    terminal_historical_ids TEXT [];
    last_ids_terminals INT [];
    last_ids_branch INT [];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    FOREACH next_historical_id IN ARRAY (historical_ids)
    LOOP 
      INSERT INTO branch (
        name,
        address_street,
        address_street_number,
        address_suite_number,
        address_suburb,
        address_county,
        address_city,
        address_state,
        address_zip_code,
        phone_number,
        enabled,
        historical_action, 
        historical_action_user_id, 
        historical_id,
        date_updated
      )
      SELECT 
        b.name,
        b.address_street,
        b.address_street_number,
        b.address_suite_number,
        b.address_suburb,
        b.address_county,
        b.address_city,
        b.address_state,
        b.address_zip_code,
        b.phone_number,
        true,
        'HABILITACIÓN', 
        jwt_historical_id, 
        b.historical_id,
        CURRENT_TIMESTAMP
          from branch as b WHERE b.historical_id = next_historical_id AND b.is_deleted = false;
    
      SELECT currval('branch_id_branch_seq') into new_id_branch;

      terminal_historical_ids := ARRAY(SELECT t.historical_id
        FROM terminal AS t 
          INNER JOIN branch b ON t.id_branch = b.id_branch
        WHERE t.is_deleted = false AND b.historical_id = next_historical_id AND b.is_deleted = false);

      if(terminal_historical_ids is not null) THEN
        FOREACH terminal_historical_id IN ARRAY (terminal_historical_ids)
        LOOP
          INSERT INTO terminal(
            status,
            status_description,
            id_key,
            name,
            id_assignment,
            enabled,
            id_branch,
            version,
            serie,
            randomic_lock_type,
            model,
            historical_action_user_id,
            historical_id,
            historical_action,
            date_updated
          )SELECT
            t.status,
            t.status_description,
            t.id_key,
            t.name,
            t.id_assignment,
            t.enabled,
            new_id_branch,
            t.version,
            t.serie,
            t.randomic_lock_type,
            t.model,
            jwt_historical_id,
            t.historical_id,
            'HABILITACIÓN',
            CURRENT_TIMESTAMP
          FROM terminal t WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false;

          SELECT currval('terminal_id_terminal_seq') into new_id_terminal;

          UPDATE assignment assign SET
            id_terminal = new_id_terminal
          FROM terminal t
          WHERE t.id_terminal = assign.id_terminal AND t.historical_id = terminal_historical_id;

          INSERT INTO group_terminal(
            id_group,
            id_terminal,
            historical_id,
            historical_action_user_id,
            historical_action,
            date_updated
          )SELECT
            gt.id_group,
            new_id_terminal,
            gt.historical_id,
            jwt_historical_id,
            'HABILITACIÓN',
            CURRENT_TIMESTAMP
          FROM group_terminal gt 
            INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
          WHERE t.historical_id = terminal_historical_id AND gt.is_deleted = false AND t.is_deleted = false;
        END LOOP;

        last_ids_terminals := ARRAY(SELECT MAX(t.id_terminal) FROM terminal t 
          WHERE t.historical_id = ANY(terminal_historical_ids) GROUP by t.historical_id);

        UPDATE group_terminal gt SET
          is_deleted = true
        FROM terminal t
        WHERE
          gt.id_terminal = t.id_terminal AND gt.is_deleted = false AND
          t.historical_id = ANY(terminal_historical_ids) AND t.is_deleted = false 
            AND NOT(t.id_terminal = ANY(last_ids_terminals));

        UPDATE terminal t SET
          is_deleted = true
        WHERE
          t.historical_id = ANY(terminal_historical_ids) AND t.is_deleted = false 
            AND NOT(t.id_terminal = ANY(last_ids_terminals));
      END IF;
    END LOOP;

    last_ids_branch := ARRAY(SELECT MAX(b.id_branch) FROM branch b
          WHERE b.historical_id = ANY(historical_ids) GROUP by b.historical_id);

    UPDATE branch b SET
      is_deleted = true
    WHERE
      b.historical_id = ANY(historical_ids) AND b.is_deleted = false
        AND NOT(b.id_branch = ANY(last_ids_branch));
  END;
$FUNCTION$;

-- get terminal count by branch
CREATE OR REPLACE FUNCTION get_cashier_counts(
    IN branch_historical_id TEXT,
    OUT assign_count INT, 
    OUT online_count INT, 
    OUT alarm_count INT, 
    OUT offline_count INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    limit_time INTERVAL;
    rec RECORD;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('glob_variables.terminal_limit_time', true)::INTERVAL INTO limit_time;
    
    online_count := 0;
    offline_count := 0;

    SELECT COUNT(t.*) INTO assign_count
      FROM branch b
        INNER JOIN terminal t ON t.id_branch = b.id_branch
        INNER JOIN assignment assign ON t.id_assignment = assign.id_assignment
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
      WHERE b.is_deleted = false AND
        CASE
          WHEN branch_historical_id IS NOT NULL OR branch_historical_id != '' 
            THEN b.historical_id = branch_historical_id
          ELSE true
        END 
        AND t.is_deleted = false;

    FOR rec IN (SELECT el.id_electronic_lock,el.work_mode_date,el.communication_date,t.id_terminal
      FROM branch b
        INNER JOIN terminal t ON t.id_branch = b.id_branch
        INNER JOIN assignment assign ON t.id_assignment = assign.id_assignment
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
      WHERE b.is_deleted = false AND
        CASE
          WHEN branch_historical_id IS NOT NULL OR branch_historical_id != '' 
            THEN b.historical_id = branch_historical_id
          ELSE true
        END 
        AND t.is_deleted = false)
    LOOP
      IF (rec.communication_date + limit_time < CURRENT_TIMESTAMP) THEN
        offline_count := offline_count + 1;
      ELSE
        online_count := online_count + 1;
      END IF;
    END LOOP;

    alarm_count := array_length(
      ARRAY(
        SELECT el.id_electronic_lock
          FROM branch b
            INNER JOIN terminal t ON t.id_branch = b.id_branch
            INNER JOIN assignment assign ON t.id_assignment = assign.id_assignment
            INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
            INNER JOIN alarms a ON a.id_lock = el.id_lock
          WHERE b.is_deleted = false AND
            CASE
              WHEN branch_historical_id IS NOT NULL OR branch_historical_id != '' 
                THEN b.historical_id = branch_historical_id
              ELSE true
            END 
            AND t.is_deleted = false
            AND a.date_close IS NULL GROUP BY el.id_electronic_lock
      )
    ,1);

    alarm_count := COALESCE(alarm_count,0);
    RETURN;
  END;
$function$;

-- get terminal data by branch
CREATE OR REPLACE FUNCTION get_cashiers_status(
    branch_historical_id TEXT,
    cashier_status TEXT,
    filters TEXT,
    sort_field TEXT,
    sort_order TEXT
  )
  RETURNS TABLE (
    id_cashier TEXT,
    branch_name TEXT,
    id_electronic_lock INT,
    id_lock INT, 
    status BOOLEAN, 
    alarm_type TEXT, 
    last_communication TIMESTAMP WITH TIME ZONE
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    json_filters JSON;
    id_cashier_filter TEXT;
    branch_name_filter TEXT;
    id_lock_filter TEXT;
    status_filter BOOLEAN;
    alert_type_filter TEXT;
    last_communication_init TIMESTAMP;
    last_communication_finish TIMESTAMP;
    limit_time INTERVAL;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_lock_filter := json_filters->'idLock'->>'value';
    status_filter := json_filters->'status'->>'value';
    alert_type_filter := json_filters->'alarmType'->>'value';
    branch_name_filter := json_filters->'branchName'->>'value';
    id_cashier_filter := json_filters->'idCashier'->>'value';

    last_communication_init := json_filters->'lastCommunication'->'value'->>0;
    last_communication_init := last_communication_init::TIMESTAMP;
    last_communication_finish := json_filters->'lastCommunication'->'value'->>1;
    last_communication_finish := last_communication_finish::TIMESTAMP + INTERVAL '1 day';

    SELECT current_setting('glob_variables.terminal_limit_time', true)::INTERVAL INTO limit_time;

    RETURN QUERY
      SELECT 
        t.name::TEXT,
        b.name::TEXT,
        el.id_electronic_lock::INT,
        el.id_lock::INT,
        CASE
          WHEN el.communication_date + limit_time < CURRENT_TIMESTAMP OR el.communication_date IS NULL THEN false
          ELSE true
        END AS status,
		    at.name::TEXT,
        el.communication_date::TIMESTAMP WITH TIME ZONE
      FROM branch b
        INNER JOIN terminal t ON t.id_branch = b.id_branch
        INNER JOIN assignment assign ON t.id_assignment = assign.id_assignment
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
        LEFT JOIN alarms a ON a.id_lock = el.id_lock AND a.date_close IS NULL
        LEFT JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
      WHERE t.is_deleted = false
        AND 
          CASE
            WHEN branch_historical_id IS NOT NULL AND branch_historical_id != ''
              THEN b.historical_id = branch_historical_id AND b.is_deleted = false
            ELSE true
          END
        AND
          CASE
            WHEN get_cashiers_status.cashier_status IS NOT NULL AND get_cashiers_status.cashier_status = 'offline'
              THEN el.communication_date + limit_time < CURRENT_TIMESTAMP OR el.communication_date IS NULL
            WHEN get_cashiers_status.cashier_status IS NOT NULL AND get_cashiers_status.cashier_status = 'online'
              THEN el.communication_date + limit_time > CURRENT_TIMESTAMP 
            ELSE true
          END
        AND
          CASE
            WHEN (branch_name_filter IS NOT NULL AND branch_name_filter != '') 
              THEN LOWER(b.name::TEXT) LIKE CONCAT('%',LOWER(branch_name_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN (id_cashier_filter IS NOT NULL AND id_cashier_filter != '') 
              THEN LOWER(t.name::TEXT) LIKE CONCAT('%',LOWER(id_cashier_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN (id_lock_filter IS NOT NULL AND id_lock_filter != '') 
              THEN el.id_lock::TEXT LIKE CONCAT('%',id_lock_filter,'%')
            ELSE true
          END
        AND
          CASE
            WHEN status_filter IS NOT NULL AND status_filter::BOOLEAN = false
				      THEN el.communication_date + limit_time < CURRENT_TIMESTAMP OR el.communication_date IS NULL
            WHEN status_filter IS NOT NULL AND status_filter::BOOLEAN = true
              THEN el.communication_date + limit_time > CURRENT_TIMESTAMP 
            ELSE true
          END
        AND
          CASE
            WHEN (alert_type_filter IS NOT NULL AND alert_type_filter != '') 
              THEN LOWER(at.name) LIKE CONCAT('%',LOWER(alert_type_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN last_communication_finish IS NOT NULL 
              THEN el.communication_date IS NOT NULL
                AND el.communication_date >= last_communication_init 
                AND el.communication_date <= last_communication_finish
            ELSE true
          END
      ORDER BY
        CASE WHEN sort_field = 'branchName' AND sort_order = 'ASC'
          THEN b.name END,
        CASE WHEN sort_field = 'branchName' AND sort_order = 'DESC'
          THEN b.name END DESC,
        CASE WHEN sort_field = 'idCashier' AND sort_order = 'ASC'
          THEN t.name END,
        CASE WHEN sort_field = 'idCashier' AND sort_order = 'DESC'
          THEN t.name END DESC,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN el.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN el.id_lock END DESC,
        CASE WHEN sort_field = 'status' AND sort_order = 'ASC'
          THEN el.communication_date + limit_time < CURRENT_TIMESTAMP END,
        CASE WHEN sort_field = 'status' AND sort_order = 'DESC'
          THEN el.communication_date + limit_time < CURRENT_TIMESTAMP END DESC,
        CASE WHEN sort_field = 'alarmType' AND sort_order = 'ASC'
          THEN at.name END,
        CASE WHEN (sort_field = 'alarmType' AND sort_order = 'DESC')  OR sort_field = ''
          THEN at.name END DESC,
        CASE WHEN sort_field = 'lastCommunication' AND sort_order = 'ASC'
          THEN el.communication_date END,
        CASE WHEN (sort_field = 'lastCommunication' AND sort_order = 'DESC') OR sort_field = ''
          THEN el.communication_date END DESC;
  END;
$function$;


---- Terminals

-- get cashiers
CREATE OR REPLACE FUNCTION get_all_cashiers()
  RETURNS TABLE(
    id_terminal INT,
    id_lock INT,
    branch_name TEXT,
    group_name TEXT,
    id_group INT,
    id_branch INT,
    id_cashier TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT 
        t.id_terminal::INT,
        el.id_lock::INT,
        b.name::TEXT as branch_name,
        g.name::TEXT as group_name,
        b.id_branch,
        g.id_group,
        t.name::TEXT
      FROM terminal AS t 
        LEFT JOIN branch b ON b.id_branch = t.id_branch
        LEFT JOIN assignment assign ON assign.id_assignment = t.id_assignment
        LEFT JOIN electronic_lock el ON el.id_lock = assign.id_lock
        LEFT JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
          AND gt.is_deleted = false
        LEFT JOIN groups g ON g.id_group = gt.id_group
      WHERE t.is_deleted = false
      ORDER BY t.name;
  END;
$FUNCTION$;

-- get terminals by status
CREATE OR REPLACE FUNCTION get_all_cashiers_by_status(
    enabled boolean,
    filters TEXT,
    sort_field TEXT,
    sort_order TEXT
  )
  RETURNS TABLE(
    id_terminal INT,
    terminal_historical_id TEXT,
    id_lock INT,
    branch_name TEXT,
    group_name TEXT,
    id_group INT,
    id_branch INT,
    id_cashier TEXT,
    cashier_status TEXT,
    incomplete BOOLEAN
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    json_filters JSON;
    id_cashier_filter TEXT;
    id_branch_filter TEXT;
    id_group_filter TEXT;
    id_lock_filter TEXT;
    status_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_cashier_filter := json_filters->'idCashier'->>'value';
    id_branch_filter := (json_filters->'idBranch'->>'value');
    id_group_filter := (json_filters->'idGroup'->>'value');
    id_lock_filter := (json_filters->'idLock'->>'value');
    status_filter := json_filters->'cashierStatus'->>'value';

  	RETURN QUERY SELECT 
      t.id_terminal::INT,
      t.historical_id::TEXT,
      el.id_lock::INT,
      b.name::TEXT as branch_name,
      g.name::TEXT as group_name,
      g.id_group,
      b.id_branch,
      t.name::TEXT as id_cashier,
      CASE
        WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
		    WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
        WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
        WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
        WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
      END as cashier_status,
      NOT(COALESCE(
        NULLIF(t.name IS NOT NULL,true),
        NULLIF(g.id_group IS NOT NULL,true),
        NULLIF(b.id_branch IS NOT NULL,true),
        NULLIF(el.id_lock IS NOT NULL,true),
        NULLIF(t.serie IS NOT NULL,true),
        NULLIF(t.model IS NOT NULL,true),
        NULLIF(t.version IS NOT NULL,true),
        NULLIF(t.randomic_lock_type IS NOT NULL,true)
      ) IS NULL) as incomplete
      FROM terminal AS t 
        LEFT JOIN branch b ON b.id_branch = t.id_branch
        LEFT JOIN assignment assign ON assign.id_assignment = t.id_assignment
        LEFT JOIN electronic_lock el ON el.id_lock = assign.id_lock
        LEFT JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
          AND gt.is_deleted = false
        LEFT JOIN groups g ON g.id_group = gt.id_group
        LEFT JOIN (
          SELECT COUNT(assign2.id_lock) replace_count, t2.historical_id FROM terminal t2
            INNER JOIN assignment assign2 ON assign2.id_terminal = t2.id_terminal
            INNER JOIN electronic_lock el2 ON el2.id_lock = assign2.id_lock
          WHERE el2.work_mode = current_setting('glob_variables.id_work_mode_replacement')::INT
				  GROUP BY t2.historical_id
        ) replace_lock ON replace_lock.historical_id = t.historical_id
      WHERE t.is_deleted = false AND t.enabled = get_all_cashiers_by_status.enabled
        AND 
          CASE
            WHEN id_cashier_filter IS NOT NULL AND id_cashier_filter != '' 
              THEN LOWER(t.name) LIKE CONCAT('%',LOWER(id_cashier_filter),'%')
            ELSE true
          END
        AND 
          CASE
            WHEN id_branch_filter IS NOT NULL AND id_branch_filter != '' 
              THEN b.id_branch = id_branch_filter::INT
            ELSE true
          END
        AND 
          CASE
            WHEN id_group_filter IS NOT NULL AND id_group_filter != '' 
              THEN g.id_group = id_group_filter::INT
            ELSE true
          END
        AND 
          CASE
            WHEN id_lock_filter IS NOT NULL AND id_lock_filter != '' 
              THEN LOWER(el.id_lock::TEXT) LIKE CONCAT('%',LOWER(id_lock_filter),'%')
            ELSE true
          END
        AND 
          CASE
            WHEN status_filter IS NOT NULL AND status_filter != '' 
              THEN status_filter = 
                CASE
                  WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
                  WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
                  WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
                  WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
                  WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
                END 
            ELSE true
          END
      ORDER BY 
        CASE WHEN (sort_field = 'idCashier' AND sort_order = 'ASC') or sort_field = ''
          THEN t.name END,
        CASE WHEN sort_field = 'idCashier' AND sort_order = 'DESC'
          THEN t.name END DESC,
        CASE WHEN sort_field = 'branchName' AND sort_order = 'ASC'
          THEN b.name END,
        CASE WHEN sort_field = 'branchName' AND sort_order = 'DESC'
          THEN b.name END DESC,
        CASE WHEN sort_field = 'groupName' AND sort_order = 'ASC'
          THEN g.name END,
        CASE WHEN sort_field = 'groupName' AND sort_order = 'DESC'
          THEN g.name END DESC,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN el.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN el.id_lock END DESC,
        CASE WHEN sort_field = 'cashierStatus' AND sort_order = 'ASC'
          THEN 
            CASE
              WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
              WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
            END
          END,
        CASE WHEN sort_field = 'cashierStatus' AND sort_order = 'DESC'
          THEN 
            CASE
              WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
              WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
            END
          END DESC;
  END;
$FUNCTION$;

-- Get incomplete cashiers
CREATE OR REPLACE FUNCTION get_incomplete_cashiers(
    enabled boolean,
    filters TEXT,
    sort_field TEXT,
    sort_order TEXT
  )
  RETURNS TABLE(
    id_terminal INT,
    terminal_historical_id TEXT,
    id_lock INT,
    branch_name TEXT,
    group_name TEXT,
    id_group INT,
    id_branch INT,
    id_cashier TEXT,
    cashier_status TEXT,
    incomplete BOOLEAN
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    json_filters JSON;
    id_cashier_filter TEXT;
    id_branch_filter TEXT;
    id_group_filter TEXT;
    id_lock_filter TEXT;
    status_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_cashier_filter := json_filters->'idCashier'->>'value';
    id_branch_filter := (json_filters->'idBranch'->>'value');
    id_group_filter := (json_filters->'idGroup'->>'value');
    id_lock_filter := (json_filters->'idLock'->>'value');
    status_filter := json_filters->'cashierStatus'->>'value';
    RETURN QUERY
      SELECT 
      t.id_terminal::INT,
      t.historical_id::TEXT,
      el.id_lock::INT,
      b.name::TEXT as branch_name,
      g.name::TEXT as group_name,
      g.id_group,
      b.id_branch,
      t.name::TEXT as id_cashier,
      CASE
        WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
		    WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
        WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
        WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
        WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
      END as cashier_status,
      true
      FROM terminal AS t 
        LEFT JOIN branch b ON b.id_branch = t.id_branch
        LEFT JOIN assignment assign ON assign.id_assignment = t.id_assignment
        LEFT JOIN electronic_lock el ON el.id_lock = assign.id_lock
        LEFT JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
          AND gt.is_deleted = false
        LEFT JOIN groups g ON g.id_group = gt.id_group
        LEFT JOIN (
          SELECT COUNT(assign2.id_lock) replace_count, t2.historical_id FROM terminal t2
            INNER JOIN assignment assign2 ON assign2.id_terminal = t2.id_terminal
            INNER JOIN electronic_lock el2 ON el2.id_lock = assign2.id_lock
          WHERE el2.work_mode = current_setting('glob_variables.id_work_mode_replacement')::INT
				  GROUP BY t2.historical_id
        ) replace_lock ON replace_lock.historical_id = t.historical_id
      WHERE t.is_deleted = false AND t.enabled = get_incomplete_cashiers.enabled
        AND NOT(COALESCE(
          NULLIF(t.name IS NOT NULL,true),
          NULLIF(g.id_group IS NOT NULL,true),
          NULLIF(b.id_branch IS NOT NULL,true),
          NULLIF(el.id_lock IS NOT NULL,true),
          NULLIF(t.serie IS NOT NULL,true),
          NULLIF(t.model IS NOT NULL,true),
          NULLIF(t.version IS NOT NULL,true),
          NULLIF(t.randomic_lock_type IS NOT NULL,true)
        ) IS NULL)
        AND 
          CASE
            WHEN id_cashier_filter IS NOT NULL AND id_cashier_filter != '' 
              THEN LOWER(t.name) LIKE CONCAT('%',LOWER(id_cashier_filter),'%')
            ELSE true
          END
        AND 
          CASE
            WHEN id_branch_filter IS NOT NULL AND id_branch_filter != '' 
              THEN b.id_branch = id_branch_filter::INT
            ELSE true
          END
        AND 
          CASE
            WHEN id_group_filter IS NOT NULL AND id_group_filter != '' 
              THEN g.id_group = id_group_filter::INT
            ELSE true
          END
        AND 
          CASE
            WHEN id_lock_filter IS NOT NULL AND id_lock_filter != '' 
              THEN LOWER(el.id_lock::TEXT) LIKE CONCAT('%',LOWER(id_lock_filter),'%')
            ELSE true
          END
        AND 
          CASE
            WHEN status_filter IS NOT NULL AND status_filter != '' 
              THEN status_filter = 
                CASE
                  WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
                  WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
                  WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
                  WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
                  WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
                END 
            ELSE true
          END
      ORDER BY 
        CASE WHEN (sort_field = 'idCashier' AND sort_order = 'ASC') or sort_field = ''
          THEN t.name END,
        CASE WHEN sort_field = 'idCashier' AND sort_order = 'DESC'
          THEN t.name END DESC,
        CASE WHEN sort_field = 'branchName' AND sort_order = 'ASC'
          THEN b.name END,
        CASE WHEN sort_field = 'branchName' AND sort_order = 'DESC'
          THEN b.name END DESC,
        CASE WHEN sort_field = 'groupName' AND sort_order = 'ASC'
          THEN g.name END,
        CASE WHEN sort_field = 'groupName' AND sort_order = 'DESC'
          THEN g.name END DESC,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN el.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN el.id_lock END DESC,
        CASE WHEN sort_field = 'cashierStatus' AND sort_order = 'ASC'
          THEN 
            CASE
              WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
              WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
            END
          END,
        CASE WHEN sort_field = 'cashierStatus' AND sort_order = 'DESC'
          THEN 
            CASE
              WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
              WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
              WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
            END
          END DESC;
  END;
$FUNCTION$;

-- get terminals by id group
CREATE OR REPLACE FUNCTION get_all_cashiers_by_group(
    enabled boolean,
    group_historical_id TEXT,
    filters TEXT,
    sort_field TEXT,
    sort_order TEXT
  )
  RETURNS TABLE(
    id_terminal INT,
    terminal_historical_id TEXT,
    id_lock INT,
    branch_name TEXT,
    group_name TEXT,
    id_group INT,
    id_branch INT,
    id_cashier TEXT,
    cashier_status TEXT,
    incomplete BOOLEAN
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    json_filters JSON;
    id_cashier_filter TEXT;
    id_branch_filter TEXT;
    id_group_filter TEXT;
    id_lock_filter TEXT;
    status_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_cashier_filter := json_filters->'idCashier'->>'value';
    id_branch_filter := (json_filters->'idBranch'->>'value');
    id_group_filter := (json_filters->'idGroup'->>'value');
    id_lock_filter := (json_filters->'idLock'->>'value');
    status_filter := json_filters->'cashierStatus'->>'value';

    RETURN QUERY
      SELECT 
        t.id_terminal::INT,
        t.historical_id::TEXT,
        el.id_lock::INT,
        b.name::TEXT as branch_name,
        g.name::TEXT as group_name,
        g.id_group,
        b.id_branch,
        t.name::TEXT as id_cashier,
        CASE
          WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
		    WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
          WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
          WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
          WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
        END as cashier_status,
        NOT(COALESCE(
          NULLIF(t.name IS NOT NULL,true),
          NULLIF(g.id_group IS NOT NULL,true),
          NULLIF(b.id_branch IS NOT NULL,true),
          NULLIF(el.id_lock IS NOT NULL,true),
          NULLIF(t.serie IS NOT NULL,true),
          NULLIF(t.model IS NOT NULL,true),
          NULLIF(t.version IS NOT NULL,true),
          NULLIF(t.randomic_lock_type IS NOT NULL,true)
        ) IS NULL) as incomplete
      FROM terminal AS t 
          LEFT JOIN branch b ON b.id_branch = t.id_branch
          LEFT JOIN assignment assign ON assign.id_assignment = t.id_assignment
          LEFT JOIN electronic_lock el ON el.id_lock = assign.id_lock
          LEFT JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
            AND gt.is_deleted = false
          LEFT JOIN groups g ON g.id_group = gt.id_group
          LEFT JOIN (
            SELECT COUNT(assign2.id_lock) replace_count, t2.historical_id FROM terminal t2
              INNER JOIN assignment assign2 ON assign2.id_terminal = t2.id_terminal
              INNER JOIN electronic_lock el2 ON el2.id_lock = assign2.id_lock
            WHERE el2.work_mode = current_setting('glob_variables.id_work_mode_replacement')::INT
            GROUP BY t2.historical_id
          ) replace_lock ON replace_lock.historical_id = t.historical_id
        WHERE t.is_deleted = false AND t.enabled = get_all_cashiers_by_group.enabled
          AND g.historical_id = group_historical_id
          AND 
            CASE
              WHEN id_cashier_filter IS NOT NULL AND id_cashier_filter != '' 
                THEN LOWER(t.name) LIKE CONCAT('%',LOWER(id_cashier_filter),'%')
              ELSE true
            END
          AND 
            CASE
              WHEN id_branch_filter IS NOT NULL AND id_branch_filter != '' 
                THEN b.id_branch = id_branch_filter::INT
              ELSE true
            END
          AND 
            CASE
              WHEN id_group_filter IS NOT NULL AND id_group_filter != '' 
                THEN g.id_group = id_group_filter::INT
              ELSE true
            END
          AND 
            CASE
              WHEN id_lock_filter IS NOT NULL AND id_lock_filter != '' 
                THEN LOWER(el.id_lock::TEXT) LIKE CONCAT('%',LOWER(id_lock_filter),'%')
              ELSE true
            END
          AND 
            CASE
              WHEN status_filter IS NOT NULL AND status_filter != '' 
                THEN status_filter = 
                  CASE
                    WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
                    WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
                    WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
                    WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
                    WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
                  END 
              ELSE true
            END
        ORDER BY 
          CASE WHEN (sort_field = 'idCashier' AND sort_order = 'ASC') or sort_field = ''
            THEN t.name END,
          CASE WHEN sort_field = 'idCashier' AND sort_order = 'DESC'
            THEN t.name END DESC,
          CASE WHEN sort_field = 'branchName' AND sort_order = 'ASC'
            THEN b.name END,
          CASE WHEN sort_field = 'branchName' AND sort_order = 'DESC'
            THEN b.name END DESC,
          CASE WHEN sort_field = 'groupName' AND sort_order = 'ASC'
            THEN g.name END,
          CASE WHEN sort_field = 'groupName' AND sort_order = 'DESC'
            THEN g.name END DESC,
          CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
            THEN el.id_lock END,
          CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
            THEN el.id_lock END DESC,
          CASE WHEN sort_field = 'cashierStatus' AND sort_order = 'ASC'
            THEN 
              CASE
                WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
                WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
                WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
                WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
                WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
              END
            END,
          CASE WHEN sort_field = 'cashierStatus' AND sort_order = 'DESC'
            THEN 
              CASE
                WHEN t.id_assignment IS NULL THEN 'Cajero por configurar'
                WHEN replace_lock.replace_count = 1 THEN 'Chapa por reemplazar'
                WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_installation')::INT THEN 'Chapa asignada'
                WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT THEN 'Chapa instalada'
                WHEN t.id_assignment IS NOT NULL AND el.work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT THEN 'Chapa dada de baja'
              END
            END DESC;
  END;
$FUNCTION$;


-- insert new terminal
CREATE OR REPLACE FUNCTION insert_new_cashier (
  version TEXT,
  serie_atm TEXT,
  randomic_lock_type TEXT,
  model TEXT,
  id_lock INT,
  id_group TEXT,
  id_branch INT,
  name TEXT,
  creation_mode TEXT
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$function$
DECLARE
  jwt_historical_id TEXT;
  next_id_terminal INT;
  next_id_assignment INT;
BEGIN
  PERFORM check_token_validity();
  SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

  INSERT INTO terminal (
    version,
    serie,
    randomic_lock_type,
    model,
    id_branch,
    historical_action_user_id,
    name,
    creation_mode
  )
  VALUES(
    insert_new_cashier.version,
    insert_new_cashier.serie_atm,
    insert_new_cashier.randomic_lock_type,
    insert_new_cashier.model,
    insert_new_cashier.id_branch,
    jwt_historical_id,
    insert_new_cashier.name,
    insert_new_cashier.creation_mode
  ) RETURNING terminal.id_terminal INTO next_id_terminal;


  IF(insert_new_cashier.id_lock IS NOT NULL) THEN
    INSERT INTO assignment (
      id_lock,
      id_terminal
    )
    VALUES(
      insert_new_cashier.id_lock,
      next_id_terminal
    ) RETURNING assignment.id_assignment INTO next_id_assignment;
    UPDATE terminal SET
      id_assignment = next_id_assignment
    WHERE id_terminal = next_id_terminal;
  END IF;


  UPDATE electronic_lock el SET
    work_mode_date = CURRENT_TIMESTAMP,
    work_mode = current_setting('glob_variables.id_work_mode_installation')::INT
  WHERE el.id_lock = insert_new_cashier.id_lock;

  IF insert_new_cashier.id_group != '' THEN
    INSERT INTO group_terminal (
      id_group,
      id_terminal,
      historical_action_user_id
    )
    VALUES(
      insert_new_cashier.id_group::INT,
      next_id_terminal,
      jwt_historical_id
    );
  END IF;
END;
$function$;

-- upload cashiers massive with json
CREATE OR REPLACE FUNCTION upload_cashiers_massive (
    cashiers TEXT
  ) 
RETURNS VOID
LANGUAGE plpgsql
VOLATILE
AS
$function$
  DECLARE
    json_cashiers JSON;
    rec RECORD;
  BEGIN
    PERFORM check_token_validity();
    json_cashiers := cashiers::JSON;
    FOR rec IN (SELECT * FROM json_to_recordset(json_cashiers)
      as x(
        "Chapa" TEXT,
        "Version" TEXT,
        "SerieATM" TEXT,
        "ChapaRandomica" TEXT,
        "Modelo" TEXT,
        "IDCajero" TEXT, 
        "Sucursal" TEXT, 
        "Grupo" TEXT
      )
    ) LOOP
      rec."Version" := CASE WHEN rec."Version" = '' THEN null ELSE rec."Version" END;
      rec."SerieATM" := CASE WHEN rec."SerieATM" = '' THEN null ELSE rec."SerieATM" END;
      rec."ChapaRandomica" := CASE WHEN rec."ChapaRandomica" = '' THEN null ELSE rec."ChapaRandomica" END;
      rec."Modelo" := CASE WHEN rec."Modelo" = '' THEN null ELSE rec."Modelo" END;
	    PERFORM insert_new_cashier(
        rec."Version"::TEXT,
        rec."SerieATM"::TEXT,
        rec."ChapaRandomica"::TEXT,
        rec."Modelo"::TEXT,
        CASE WHEN rec."Chapa" = '' THEN NULL ELSE rec."Chapa"::INT END,
        rec."Grupo"::TEXT,
        CASE WHEN rec."Sucursal" = '' THEN NULL ELSE rec."Sucursal"::INT END,
        rec."IDCajero",
        'Archivo'
      );
    END LOOP;
  END;

$function$;

-- get cashier by id
CREATE OR REPLACE FUNCTION get_cashier_by_id(
    IN terminal_historical_id TEXT,
    OUT id_terminal INT,
    OUT serie TEXT,
    OUT model TEXT,
    OUT version TEXT,
    OUT randomic_lock_type TEXT,
    OUT id_lock INT,
    OUT id_branch INT,
    OUT id_group INT,
    OUT name TEXT,
    OUT enabled BOOLEAN
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    rec record;
  BEGIN
    PERFORM check_token_validity();
    FOR rec IN
      (SELECT 
        t.id_terminal::INT,
        t.serie::TEXT,
        t.model::TEXT,
        t.version::TEXT,
        t.randomic_lock_type::TEXT,
        el.id_lock::INT,
        b.id_branch::INT,
        g.id_group::INT,
        t.name::TEXT,
        t.enabled
          FROM terminal AS t 
            LEFT JOIN branch b ON b.id_branch = t.id_branch
            LEFT JOIN assignment assign ON t.id_assignment = assign.id_assignment
            LEFT JOIN electronic_lock el ON assign.id_lock = el.id_lock
            LEFT JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
              AND gt.is_deleted = false
            LEFT JOIN groups g ON g.id_group = gt.id_group
          WHERE t.historical_id = get_cashier_by_id.terminal_historical_id AND t.is_deleted = false LIMIT 1)
    LOOP
      get_cashier_by_id.id_terminal := rec.id_terminal;
      get_cashier_by_id.serie := rec.serie;
      get_cashier_by_id.model := rec.model;
      get_cashier_by_id.version := rec.version;
      get_cashier_by_id.randomic_lock_type := rec.randomic_lock_type;
      get_cashier_by_id.id_lock := rec.id_lock;
      get_cashier_by_id.id_branch := rec.id_branch;
      get_cashier_by_id.id_group := rec.id_group;
      get_cashier_by_id.name := rec.name;
      get_cashier_by_id.enabled := rec.enabled;
      RETURN;
    END LOOP;
  END;
$function$;

-- get cashier data, branch, and group by id
CREATE OR REPLACE FUNCTION get_cashier_related_data_by_id(
    IN terminal_historical_id TEXT,
    OUT id_cashier TEXT,
    OUT id_lock INT,
    OUT branch_name TEXT,
    OUT group_name TEXT,
    OUT alarm_type TEXT,
    OUT status BOOLEAN,
    OUT can_replace BOOLEAN,
    OUT replace_id_lock INT,
    OUT enabled BOOLEAN
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    rec RECORD;
    limit_time INTERVAL;
  BEGIN    
    PERFORM check_token_validity();
    SELECT current_setting('glob_variables.terminal_limit_time', true)::INTERVAL INTO limit_time;

    SELECT el.id_lock INTO replace_id_lock FROM electronic_lock el
      INNER JOIN assignment assign ON assign.id_lock = el.id_lock
      INNER JOIN terminal t ON t.id_terminal = assign.id_terminal
    WHERE t.historical_id = get_cashier_related_data_by_id.terminal_historical_id 
      AND t.is_deleted = false AND el.work_mode = current_setting('glob_variables.id_work_mode_replacement')::INT;

    SELECT 
      t.name::TEXT,
      el.id_lock::INT,
      b.name::TEXT,
      g.name::TEXT,
      at.name,
      el.communication_date + limit_time > CURRENT_TIMESTAMP,
      el.work_mode > 4,
      t.enabled
    INTO
      id_cashier,
      id_lock,
      branch_name,
      group_name,
      alarm_type,
      status,
      can_replace,
      enabled
    FROM terminal AS t 
      LEFT JOIN branch b ON b.id_branch = t.id_branch
      LEFT JOIN assignment assign ON t.id_assignment = assign.id_assignment
      LEFT JOIN electronic_lock el ON assign.id_lock = el.id_lock
      LEFT JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
        AND gt.is_deleted = false
      LEFT JOIN groups g ON g.id_group = gt.id_group
      LEFT JOIN alarms a ON a.id_lock = el.id_lock AND a.date_close IS NULL
      LEFT JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
    WHERE t.historical_id = get_cashier_related_data_by_id.terminal_historical_id AND t.is_deleted = false LIMIT 1;
  END;
$function$;

-- update cashier
CREATE OR REPLACE FUNCTION update_cashier (
  version TEXT,
  serie_atm TEXT,
  randomic_lock_type TEXT,
  model TEXT,
  id_lock INT,
  id_group TEXT,
  id_branch INT,
  terminal_historical_id TEXT,
  name TEXT
)
  RETURNS VOID
 LANGUAGE plpgsql
AS 
$function$
  DECLARE
    jwt_historical_id TEXT;
    count_group_relation INT;
    next_id_terminal INT;
    next_id_assignment INT;
    existing_assignment assignment;
    has_id_assignment INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    INSERT INTO terminal (
      id_assignment,
      id_branch,
      status,
      status_description,
      id_key,
      name,
      enabled,
      version,
      serie,
      randomic_lock_type,
      model,
      date_updated, 
      historical_action, 
      historical_action_user_id, 
      historical_id
    )
    SELECT 
      t.id_assignment,
      update_cashier.id_branch,
      t.status,
      t.status_description,
      t.id_key,
      update_cashier.name,
      t.enabled,
      update_cashier.version,
      update_cashier.serie_atm,
      update_cashier.randomic_lock_type,
      update_cashier.model,
      CURRENT_TIMESTAMP, 
      'MODIFICACIÓN', 
      jwt_historical_id, 
      t.historical_id
        from terminal as t WHERE t.historical_id = update_cashier.terminal_historical_id AND t.is_deleted = false
    RETURNING terminal.id_terminal,terminal.id_assignment INTO next_id_terminal,has_id_assignment;

    IF(has_id_assignment IS NULL AND update_cashier.id_lock IS NOT NULL) THEN
      INSERT INTO assignment (
        id_terminal,
        id_lock
      ) VALUES (
        next_id_terminal,
        update_cashier.id_lock
      ) RETURNING assignment.id_assignment INTO next_id_assignment;

      UPDATE terminal t SET
        id_assignment = next_id_assignment
      WHERE t.id_terminal = next_id_terminal;

      UPDATE electronic_lock el SET
        work_mode = current_setting('glob_variables.id_work_mode_installation')::INT,
        work_mode_date = CURRENT_TIMESTAMP
      WHERE el.id_lock = update_cashier.id_lock;
    END IF;

    UPDATE assignment assign SET
      id_terminal = next_id_terminal
    FROM terminal t
    WHERE t.id_terminal = assign.id_terminal AND t.historical_id = update_cashier.terminal_historical_id;

    SELECT count(gt.*) INTO count_group_relation 
      FROM group_terminal gt 
        INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
      WHERE t.historical_id = update_cashier.terminal_historical_id AND t.is_deleted = false;

    IF(update_cashier.id_group != '' AND count_group_relation >= 1) THEN
      INSERT INTO group_terminal(
        id_group,
        id_terminal,
        historical_id,
        historical_action_user_id,
        date_updated,
        historical_action
      )SELECT
        update_cashier.id_group::int,
        next_id_terminal,
        gt.historical_id,
        jwt_historical_id,
        CURRENT_TIMESTAMP, 
        'MODIFICACIÓN'
      FROM group_terminal gt 
        INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
      WHERE t.historical_id = update_cashier.terminal_historical_id AND t.is_deleted = false
        AND gt.is_deleted = false;
    ELSIF(update_cashier.id_group != '') THEN
      INSERT INTO group_terminal (
        id_group,
        id_terminal,
        historical_action_user_id
      )
      VALUES(
        update_cashier.id_group::INT,
        next_id_terminal,
        jwt_historical_id
      );
    END IF;

    UPDATE group_terminal gt SET
      is_deleted = true
    FROM terminal t
    WHERE t.historical_id = update_cashier.terminal_historical_id AND t.is_deleted = false AND
      gt.id_terminal = t.id_terminal AND gt.is_deleted = false AND t.id_terminal != next_id_terminal;

    UPDATE terminal t SET
      is_deleted = true
    WHERE
      t.historical_id = update_cashier.terminal_historical_id AND t.is_deleted = false
        AND t.id_terminal != next_id_terminal;
  END;
$function$;

-- Add replace lock to cashier
CREATE OR REPLACE FUNCTION add_replace_lock_to_cashier (
  id_lock INT,
  terminal_historical_id TEXT
)
  RETURNS VOID
 LANGUAGE plpgsql
AS 
$function$
  DECLARE
    jwt_historical_id TEXT;
    id_terminal INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    SELECT t.id_terminal INTO id_terminal FROM terminal t 
      WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false;
    INSERT INTO assignment (
      id_terminal,
      id_lock
    ) VALUES (
      id_terminal,
      id_lock
    );
    UPDATE electronic_lock el SET
      work_mode = current_setting('glob_variables.id_work_mode_replacement')::INT
    WHERE el.id_lock = add_replace_lock_to_cashier.id_lock;
  END;
$function$;

--- disable cashiers
CREATE OR REPLACE FUNCTION disable_cashier(
  IN historical_ids TEXT [],
  IN encrypted_password TEXT, 
  IN user_email TEXT,
  OUT user_status TEXT
)
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id TEXT;
    terminal_historical_id TEXT;
    new_id_terminal INT;
    last_ids INT[];
    account system_user;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    SELECT a.* INTO account
      FROM system_user AS a
      WHERE a.email = disable_cashier.user_email AND is_deleted = false ORDER BY id_system_user DESC LIMIT 1;

    IF account.password = disable_cashier.encrypted_password AND account.enabled = true THEN
      FOREACH terminal_historical_id IN ARRAY (historical_ids)
      LOOP
        INSERT INTO terminal(
          status,
          status_description,
          id_key,
          name,
          id_assignment,
          enabled,
          id_branch,
          version,
          serie,
          randomic_lock_type,
          model,
          historical_action_user_id,
          historical_id,
          historical_action,
          date_updated
        )SELECT
          t.status,
          t.status_description,
          t.id_key,
          t.name,
          t.id_assignment,
          false,
          t.id_branch,
          t.version,
          t.serie,
          t.randomic_lock_type,
          t.model,
          jwt_historical_id,
          t.historical_id,
          'DESHABILITACIÓN',
          CURRENT_TIMESTAMP
        FROM terminal t WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false;

        SELECT currval('terminal_id_terminal_seq') into new_id_terminal;

        UPDATE assignment assign SET
          id_terminal = new_id_terminal
        FROM terminal t
        WHERE t.id_terminal = assign.id_terminal AND t.historical_id = terminal_historical_id;

        UPDATE electronic_lock el SET
          work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT
        FROM assignment assign
        WHERE el.id_lock = assign.id_lock AND assign.id_terminal = new_id_terminal;

        INSERT INTO group_terminal(
          id_group,
          id_terminal,
          historical_id,
          historical_action_user_id,
          historical_action,
          date_updated
        )SELECT
          gt.id_group,
          new_id_terminal,
          gt.historical_id,
          jwt_historical_id,
          'DESHABILITACIÓN',
          CURRENT_TIMESTAMP
        FROM group_terminal gt 
          INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
          WHERE t.historical_id = terminal_historical_id AND gt.is_deleted = false AND t.is_deleted = false;
      END LOOP;
      last_ids := ARRAY(SELECT MAX(t.id_terminal) FROM terminal t 
        WHERE t.historical_id = ANY(historical_ids) GROUP BY t.historical_id);

      UPDATE group_terminal gt SET
        is_deleted = true
        FROM terminal t
        WHERE
          gt.id_terminal = t.id_terminal AND gt.is_deleted = false AND
          t.historical_id = ANY(historical_ids) AND t.is_deleted = false AND NOT(t.id_terminal = ANY(last_ids));

      UPDATE terminal t SET
        is_deleted = true
        WHERE
          t.historical_id = ANY(historical_ids) AND t.is_deleted = false AND NOT(t.id_terminal = ANY(last_ids));
    ELSE
      user_status = 'credencialesErroneas';
    END IF;
  END;
$FUNCTION$;

--- enable cashiers
CREATE OR REPLACE FUNCTION enable_cashier(
  IN historical_ids TEXT [],
  IN encrypted_password TEXT, 
  IN user_email TEXT,
  OUT user_status TEXT
)
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id TEXT;
    terminal_historical_id TEXT;
    new_id_terminal INT;
    last_ids INT[];
    account system_user;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    SELECT a.* INTO account
      FROM system_user AS a
      WHERE a.email = enable_cashier.user_email AND is_deleted = false ORDER BY id_system_user DESC LIMIT 1;

    IF account.password = enable_cashier.encrypted_password AND account.enabled = true THEN
      FOREACH terminal_historical_id IN ARRAY (historical_ids)
      LOOP
        INSERT INTO terminal(
          status,
          status_description,
          id_key,
          name,
          id_assignment,
          enabled,
          id_branch,
          version,
          serie,
          randomic_lock_type,
          model,
          historical_action_user_id,
          historical_id,
          historical_action,
          date_updated
        )SELECT
          t.status,
          t.status_description,
          t.id_key,
          t.name,
          t.id_assignment,
          true,
          t.id_branch,
          t.version,
          t.serie,
          t.randomic_lock_type,
          t.model,
          jwt_historical_id,
          t.historical_id,
          'HABILITACIÓN',
          CURRENT_TIMESTAMP
        FROM terminal t WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false;

        SELECT currval('terminal_id_terminal_seq') into new_id_terminal;

        UPDATE assignment assign SET
          id_terminal = new_id_terminal
        FROM terminal t
        WHERE t.id_terminal = assign.id_terminal AND t.historical_id = terminal_historical_id;

        INSERT INTO group_terminal(
          id_group,
          id_terminal,
          historical_id,
          historical_action_user_id,
          historical_action,
          date_updated
        )SELECT
          gt.id_group,
          new_id_terminal,
          gt.historical_id,
          jwt_historical_id,
          'HABILITACIÓN',
          CURRENT_TIMESTAMP
        FROM group_terminal gt 
          INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
        WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false AND gt.is_deleted = false;
      END LOOP;

      last_ids := ARRAY(SELECT MAX(t.id_terminal) FROM terminal t 
        WHERE t.historical_id = ANY(historical_ids) GROUP BY t.historical_id);

      UPDATE group_terminal gt SET
        is_deleted = true
        FROM terminal t
        WHERE
          gt.id_terminal = t.id_terminal AND gt.is_deleted = false AND
          t.historical_id = ANY(historical_ids) AND t.is_deleted = false AND NOT(t.id_terminal = ANY(last_ids));

      UPDATE terminal t SET
        is_deleted = true
        WHERE
          t.historical_id = ANY(historical_ids) AND t.is_deleted = false AND NOT(t.id_terminal = ANY(last_ids));
    ELSE
      user_status = 'credencialesErroneas';
    END IF;
  END;
$FUNCTION$;

-- assign group to terminals
CREATE OR REPLACE FUNCTION assign_group_terminal(group_historical_id TEXT,historical_ids TEXT[])
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id TEXT;
    terminal_historical_id TEXT;
    new_id_terminal INT;
    count_group_relation INT;
    selected_id_group INT;
    last_ids INT[];
    terminal_able_to_change terminal;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    FOREACH terminal_historical_id IN ARRAY (historical_ids)
    LOOP
      SELECT * INTO terminal_able_to_change
      FROM terminal AS t 
        LEFT JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
        LEFT JOIN groups g on g.id_group = gt.id_group
      WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false
        AND ((g.id_group IS NOT NULL AND g.historical_id != group_historical_id)OR g.id_group IS NULL);
      if(terminal_able_to_change.id_terminal IS NOT NULL) THEN
        INSERT INTO terminal(
          status,
          status_description,
          id_key,
          name,
          id_assignment,
          enabled,
          id_branch,
          version,
          serie,
          randomic_lock_type,
          model,
          historical_action_user_id,
          historical_id,
          historical_action,
          date_updated
        )SELECT
          t.status,
          t.status_description,
          t.id_key,
          t.name,
          t.id_assignment,
          t.enabled,
          t.id_branch,
          t.version,
          t.serie,
          t.randomic_lock_type,
          t.model,
          jwt_historical_id,
          t.historical_id,
          'ASIGNACIÓN',
          CURRENT_TIMESTAMP
        FROM terminal t WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false;

        SELECT count(gt.*) INTO count_group_relation 
          FROM group_terminal gt 
            INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
          WHERE t.historical_id = terminal_historical_id AND t.is_deleted = false;

        SELECT currval('terminal_id_terminal_seq') into new_id_terminal;


        SELECT g.id_group INTO selected_id_group FROM groups g 
          WHERE g.historical_id = group_historical_id AND g.is_deleted = false;

        IF(group_historical_id != '' AND count_group_relation >= 1) THEN

          INSERT INTO group_terminal(
            id_group,
            id_terminal,
            historical_id,
            historical_action_user_id,
            historical_action,
            date_updated
          )SELECT
            selected_id_group,
            new_id_terminal,
            gt.historical_id,
            jwt_historical_id,
            'ASIGNACIÓN',
            CURRENT_TIMESTAMP
          FROM group_terminal gt 
            INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
          WHERE t.historical_id = terminal_historical_id AND gt.is_deleted = false AND t.is_deleted = false;
        ELSIF(group_historical_id != '') THEN
          INSERT INTO group_terminal (
            id_group,
            id_terminal,
            historical_action_user_id
          )
          VALUES( 
            selected_id_group, 
            new_id_terminal,
            jwt_historical_id
          );
        END IF;

        UPDATE assignment assign SET
            id_terminal = new_id_terminal
          FROM terminal t
          WHERE t.id_terminal = assign.id_terminal AND t.historical_id = terminal_historical_id;
      END IF;
    END LOOP;

    last_ids := ARRAY(SELECT MAX(t.id_terminal) FROM terminal t 
      WHERE t.historical_id = ANY(historical_ids) GROUP BY t.historical_id);


    UPDATE group_terminal gt SET
      is_deleted = true
      FROM terminal t
      WHERE
        gt.id_terminal = t.id_terminal AND gt.is_deleted = false AND
        t.historical_id = ANY(historical_ids) AND t.is_deleted = false AND NOT(t.id_terminal = ANY(last_ids));

    UPDATE terminal t SET
      is_deleted = true
      WHERE
        t.historical_id = ANY(historical_ids) AND t.is_deleted = false AND NOT(t.id_terminal = ANY(last_ids));
  END;
$FUNCTION$;


-- Electronic locks
-- get open electronic locks
CREATE OR REPLACE FUNCTION get_open_electronic_locks()
 RETURNS TABLE (id_electronic_lock INT, id_lock INT)
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    ids_already_select INT[];
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT
        el.id_electronic_lock::INT,
        el.id_lock::INT
      FROM electronic_lock el
        INNER JOIN work_mode wm ON wm.id_work_mode = el.work_mode
        LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
      WHERE wm.id_work_mode = current_setting('glob_variables.id_work_mode_no_assignation')::INT 
        AND assign.id_assignment IS NULL
      ORDER BY el.id_lock;
  END;
$function$;

--- get all electronic locks
CREATE OR REPLACE FUNCTION get_all_electronic_locks()
 RETURNS TABLE (id_electronic_lock INT, id_lock INT,terminal_name TEXT,work_mode INT)
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT
        el.id_electronic_lock::INT,
        el.id_lock::INT,
        t.name::TEXT,
        el.work_mode
      FROM electronic_lock el
        INNER JOIN assignment assign ON assign.id_lock = el.id_lock
        INNER JOIN terminal t ON t.id_terminal = assign.id_terminal
      WHERE t.is_deleted = false
      ORDER BY el.id_lock; 
  END;
$function$;

-- get electronic locks for randomic operations
CREATE OR REPLACE FUNCTION get_electronic_locks_randomic_operations()
 RETURNS TABLE (
   id_electronic_lock INT, 
   id_lock INT,
   terminal_name TEXT,
   work_mode INT,
   cashier_serie TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    role TEXT;
    id_role INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.role') INTO role;
    SELECT roles.id_role INTO id_role FROM roles WHERE roles.name = role;
    RETURN QUERY
      SELECT
        el.id_electronic_lock::INT,
        el.id_lock::INT,
        t.name::TEXT,
        el.work_mode,
        t.serie::TEXT
      FROM electronic_lock el
        INNER JOIN assignment assign ON assign.id_lock = el.id_lock
        INNER JOIN terminal t ON t.id_terminal = assign.id_terminal
        INNER JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
        INNER JOIN groups g ON g.id_group = gt.id_group
        INNER JOIN branch b ON b.id_branch = t.id_branch
      WHERE t.is_deleted = false AND t.enabled = true
        AND b.is_deleted = false AND b.enabled = true
        AND g.is_deleted = false AND g.enabled = true
        AND
          CASE WHEN NOT (id_role = ANY(ARRAY[1,2])) THEN el.work_mode = current_setting('glob_variables.id_work_mode_productive')::INT
            ELSE
              el.work_mode = ANY(ARRAY[
                current_setting('glob_variables.id_work_mode_installation')::INT,
                current_setting('glob_variables.id_work_mode_replacement')::INT,
                current_setting('glob_variables.id_work_mode_productive')::INT
              ])
          END
        AND COALESCE(
          NULLIF(t.name IS NOT NULL,true),
          NULLIF(g.id_group IS NOT NULL,true),
          NULLIF(b.id_branch IS NOT NULL,true),
          NULLIF(el.id_lock IS NOT NULL,true),
          NULLIF(t.serie IS NOT NULL,true),
          NULLIF(t.model IS NOT NULL,true),
          NULLIF(t.version IS NOT NULL,true),
          NULLIF(t.randomic_lock_type IS NOT NULL,true)
        ) IS NULL
      ORDER BY el.id_lock; 
  END;
$function$;

--- get all electronic locks by user
CREATE OR REPLACE FUNCTION get_all_electronic_locks_by_user(id_service_user INT)
 RETURNS TABLE (
   id_electronic_lock INT, 
   id_lock INT,
   terminal_name TEXT,
   work_mode INT,
   cashier_serie TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT
        el.id_electronic_lock::INT,
        el.id_lock::INT,
        t.name::TEXT,
        el.work_mode,
        t.serie::TEXT
      FROM electronic_lock el
        INNER JOIN assignment assign ON assign.id_lock = el.id_lock
        INNER JOIN terminal t ON t.id_terminal = assign.id_terminal
        INNER JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
        INNER JOIN groups g ON g.id_group = gt.id_group 
        INNER JOIN groups_service_user gu ON gu.id_group = g.id_group
        INNER JOIN service_user s ON s.id_service_user = gu.id_service_user
        INNER JOIN branch b ON b.id_branch = t.id_branch
      WHERE t.is_deleted = false AND t.enabled = true
        AND b.is_deleted = false AND b.enabled = true
        AND g.is_deleted = false AND g.enabled = true
        AND gt.is_deleted = false AND g.is_deleted = false AND gu.is_deleted = false
        AND s.is_deleted = false AND s.id_service_user = get_all_electronic_locks_by_user.id_service_user
        AND
          el.work_mode = ANY(ARRAY[
            current_setting('glob_variables.id_work_mode_installation')::INT,
            current_setting('glob_variables.id_work_mode_replacement')::INT,
            current_setting('glob_variables.id_work_mode_productive')::INT
          ])
        AND COALESCE(
          NULLIF(t.name IS NOT NULL,true),
          NULLIF(g.id_group IS NOT NULL,true),
          NULLIF(b.id_branch IS NOT NULL,true),
          NULLIF(el.id_lock IS NOT NULL,true),
          NULLIF(t.serie IS NOT NULL,true),
          NULLIF(t.model IS NOT NULL,true),
          NULLIF(t.version IS NOT NULL,true),
          NULLIF(t.randomic_lock_type IS NOT NULL,true)
        ) IS NULL
      ORDER BY el.id_lock; 
  END;
$function$;


--- get questions of service user
CREATE OR REPLACE FUNCTION get_questions_service_user(
  IN id_service_user INT, 
  IN id_lock INT, 
  IN nip TEXT,
  IN timezone TEXT,
  OUT responses service_user_responses[],
  OUT number_of_tries INT
)
 LANGUAGE plpgsql
 VOLATILE
AS 
$function$
  DECLARE
    user_serv service_user;
    res TEXT;
    todays_already_use_questions INT[];
    quantity_of_retries INT;
    lock_record randomic_operation_locks;
  BEGIN
    PERFORM check_token_validity();

    SELECT su.* INTO user_serv
      FROM service_user AS su
      WHERE su.id_service_user = get_questions_service_user.id_service_user AND su.is_deleted = false;

    SELECT uol.* INTO lock_record
      FROM randomic_operation_locks AS uol
        INNER JOIN service_user su ON su.historical_id = uol.service_user_historical_id
    WHERE su.id_service_user = get_questions_service_user.id_service_user 
      AND (uol.lock_date at time zone get_questions_service_user.timezone)::DATE = (CURRENT_TIMESTAMP at time zone get_questions_service_user.timezone)::DATE;

    IF user_serv.nip = get_questions_service_user.nip AND user_serv.enabled = true THEN
      SELECT 
        CASE 
          WHEN lock_record IS NOT NULL AND lock_record.is_locked = false
            THEN 0
          ELSE
            COUNT(ro.id_randomic_operation)
        END
        INTO number_of_tries
      FROM randomic_operation ro 
        INNER JOIN service_user su ON su.historical_id = ro.service_user_historical_id
      WHERE su.id_service_user = get_questions_service_user.id_service_user 
        AND (ro.operation_date at time zone get_questions_service_user.timezone)::DATE = (CURRENT_TIMESTAMP at time zone get_questions_service_user.timezone)::DATE
        AND ro.is_approved = false;

      todays_already_use_questions := ARRAY(SELECT roq.id_question FROM randomic_operation ro 
        INNER JOIN randomic_operation_questions roq ON roq.id_randomic_operation = ro.id_randomic_operation
        INNER JOIN service_user su ON su.historical_id = ro.service_user_historical_id
      WHERE su.id_service_user = get_questions_service_user.id_service_user 
        AND (ro.operation_date at time zone get_questions_service_user.timezone)::DATE = (CURRENT_TIMESTAMP at time zone get_questions_service_user.timezone)::DATE
        AND ro.is_approved = false
      GROUP BY roq.id_question);
      get_questions_service_user.responses := ARRAY(SELECT q FROM service_user_responses q 
        WHERE q.id_service_user = get_questions_service_user.id_service_user AND 
         (NOT (q.id_question = ANY(todays_already_use_questions)) OR 
          (lock_record IS NOT NULL AND lock_record.is_locked = false))
        );
      RETURN;
    ELSE 
      RAISE EXCEPTION SQLSTATE '90002' USING 
        MESSAGE = FORMAT('credencialesErroneas');
    END IF;
  END;
$function$;

--- verify service user
CREATE OR REPLACE FUNCTION verify_service_user(
  IN id_service_user INT, 
  IN id_lock INT, 
  IN nip TEXT,
  IN timezone TEXT,
  OUT number_of_tries INT,
  OUT is_locked BOOLEAN,
  OUT user_status TEXT
)
 LANGUAGE plpgsql
 VOLATILE
AS 
$function$
  DECLARE
    lock_record randomic_operation_locks;
    user_serv service_user;
    res TEXT;
  BEGIN
    PERFORM check_token_validity();

    SELECT uol.* INTO lock_record
      FROM randomic_operation_locks AS uol
      INNER JOIN service_user su ON su.historical_id = uol.service_user_historical_id
    WHERE su.id_service_user = verify_service_user.id_service_user 
      AND (uol.lock_date at time zone verify_service_user.timezone)::DATE = (CURRENT_TIMESTAMP at time zone verify_service_user.timezone)::DATE;

    SELECT su.* INTO user_serv
      FROM service_user AS su
      WHERE su.id_service_user = verify_service_user.id_service_user AND su.is_deleted = false;
    SELECT 
      CASE 
        WHEN lock_record IS NOT NULL AND lock_record.is_locked = false
          THEN 0
        ELSE COUNT(ro.id_randomic_operation) 
      END
      INTO number_of_tries
    FROM randomic_operation ro 
      INNER JOIN service_user su ON su.historical_id = ro.service_user_historical_id
    WHERE su.id_service_user = verify_service_user.id_service_user 
      AND (ro.operation_date at time zone verify_service_user.timezone)::DATE = (CURRENT_TIMESTAMP at time zone verify_service_user.timezone)::DATE
      AND ro.is_approved = false;
    verify_service_user.is_locked = lock_record.is_locked;
    IF user_serv.nip = verify_service_user.nip AND user_serv.enabled = true THEN
      RETURN;
    ELSE 
      user_status := 'credencialesErroneas';
      RETURN;
    END IF;
  END;
$function$;

-- lock service user from randomic operations
CREATE OR REPLACE FUNCTION lock_service_user(
  IN id_service_user INT,
  IN timezone TEXT,
  IN lock_description TEXT
)
  RETURNS VOID
  LANGUAGE plpgsql
  VOLATILE
AS 
$function$
  DECLARE
    serv_user_historical_id TEXT;
    already_exist_lock randomic_operation_locks;
  BEGIN
    PERFORM check_token_validity();
    SELECT su.historical_id INTO serv_user_historical_id
    FROM service_user su 
      WHERE su.id_service_user = lock_service_user.id_service_user;

    SELECT rol.* INTO already_exist_lock
    FROM randomic_operation_locks rol 
      WHERE rol.service_user_historical_id = serv_user_historical_id 
        AND (rol.lock_date at time zone lock_service_user.timezone)::DATE = (CURRENT_TIMESTAMP at time zone lock_service_user.timezone)::DATE;
    IF (already_exist_lock IS NULL) THEN
      INSERT INTO randomic_operation_locks
        (service_user_historical_id,lock_description)
      VALUES
        (serv_user_historical_id,lock_description);
    END IF;
  END;
$function$;

-- Get lock key by id_lock
CREATE OR REPLACE FUNCTION get_lock_key_by_id(
    IN id_lock INT,
    OUT key TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    SELECT lock_key.key::TEXT INTO get_lock_key_by_id.key 
      FROM lock_key where lock_key.id_lock = get_lock_key_by_id.id_lock;
    RETURN;
  END;
$function$;


CREATE OR REPLACE FUNCTION get_commands_for_cashiers(
    terminal_historical_id TEXT,
    filters TEXT,
    sort_field TEXT,
    sort_order TEXT
  )
  RETURNS TABLE(
    id_cashier TEXT,
    id_command INT,
    id_command_type INT,
    id_lock INT,
    command_name TEXT,
    created_date TIMESTAMP WITH TIME ZONE ,
    apply_or_cancel_date TIMESTAMP WITH TIME ZONE,
    system_user_name TEXT,
    service_user_name TEXT,
    canceled_description TEXT,
    status TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    rec RECORD;
    res TEXT;
    json_filters JSON;
    id_lock_filter TEXT;
    id_command_filter INT;
    created_date_init TIMESTAMP;
    created_date_finish TIMESTAMP;
    apply_cancel_date_init TIMESTAMP;
    apply_cancel_date_finish TIMESTAMP;
    system_user_name_filter TEXT;
    service_user_name_filter TEXT;
    canceled_description_filter TEXT;
    status_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_lock_filter := json_filters->'idLock'->>'value';
    id_command_filter := json_filters->'idCommandType'->>'value';

    created_date_init := json_filters->'createdDate'->'value'->>0;
    created_date_init := created_date_init::TIMESTAMP;
    created_date_finish := json_filters->'createdDate'->'value'->>1;
    created_date_finish := created_date_finish::TIMESTAMP + INTERVAL '1 day';

    apply_cancel_date_init := json_filters->'applyOrCancelDate'->'value'->>0;
    apply_cancel_date_init := apply_cancel_date_init::TIMESTAMP;
    apply_cancel_date_finish := json_filters->'applyOrCancelDate'->'value'->>1;
    apply_cancel_date_finish := apply_cancel_date_finish::TIMESTAMP + INTERVAL '1 day';

    system_user_name_filter := json_filters->'systemUserName'->>'value';
    service_user_name_filter := json_filters->'serviceUserName'->>'value';
    canceled_description_filter := json_filters->'canceledDescription'->>'value';
    status_filter := json_filters->'status'->>'value';

    RETURN QUERY
      SELECT 
        t.name::TEXT as id_cashier,
        c.id_command,
        ct.id_command_type,
        el.id_lock,
        ct.description::TEXT,
        c.date_created::TIMESTAMPTZ,
        COALESCE(c.date_canceled,c.date_apply,NULL)::TIMESTAMPTZ as apply_or_cancel_date,
        CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT) as system_user_name,
        CONCAT(serv_us.name::TEXT,' ',serv_us.last_name::TEXT,' ',serv_us.mothers_last_name::TEXT) as service_user_name,
        c.canceled_description::TEXT,
        CASE
          WHEN c.date_canceled is not null THEN 'Cancelado'
          WHEN c.date_apply is not null THEN 'Ejecutado'
          ELSE 'Pendiente'
        END as command_status
      FROM terminal t
        INNER JOIN assignment assign ON assign.id_terminal = t.id_terminal
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
        INNER JOIN commands c ON c.id_lock = el.id_lock
        INNER JOIN command_type ct ON ct.id_command_type = c.cmd
        INNER JOIN randomic_operation ro ON ro.id_randomic_operation = c.id_randomic_operation
        INNER JOIN system_user sys_us ON sys_us.historical_id = ro.system_user_historical_id AND sys_us.is_deleted = false
        INNER JOIN service_user serv_us ON serv_us.historical_id = ro.service_user_historical_id AND serv_us.is_deleted = false
      WHERE t.is_deleted = false
        AND 
          CASE
            WHEN get_commands_for_cashiers.terminal_historical_id IS NOT NULL 
              OR get_commands_for_cashiers.terminal_historical_id != '' 
                THEN t.historical_id = get_commands_for_cashiers.terminal_historical_id
            ELSE true
          END
        AND
          CASE
            WHEN id_command_filter IS NOT NULL THEN ct.id_command_type = id_command_filter
            ELSE true
          END
        AND
          CASE
            WHEN (id_lock_filter IS NOT NULL AND id_lock_filter != '') 
              THEN el.id_lock::TEXT LIKE CONCAT('%',id_lock_filter,'%')
            ELSE true
          END
        AND
          CASE
            WHEN created_date_finish IS NOT NULL THEN c.date_created >= created_date_init 
              AND c.date_created <= created_date_finish
            ELSE true
          END
        AND
          CASE
            WHEN apply_cancel_date_finish IS NOT NULL THEN 
              COALESCE(c.date_canceled,c.date_apply,NULL) >= apply_cancel_date_init 
                AND COALESCE(c.date_canceled,c.date_apply,NULL) <= apply_cancel_date_finish
            ELSE true
          END
        AND
          CASE
            WHEN (system_user_name_filter IS NOT NULL AND system_user_name_filter != '')  
              THEN LOWER(CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT)) 
                LIKE CONCAT('%',LOWER(system_user_name_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN (service_user_name_filter IS NOT NULL AND service_user_name_filter != '')  
              THEN LOWER(CONCAT(serv_us.name::TEXT,' ',serv_us.last_name::TEXT,' ',serv_us.mothers_last_name::TEXT)) 
                LIKE CONCAT('%',LOWER(service_user_name_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN (canceled_description_filter IS NOT NULL AND canceled_description_filter != '')  
              THEN LOWER(c.canceled_description) LIKE CONCAT('%',LOWER(canceled_description_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN status_filter IS NOT NULL THEN 
              CASE
                WHEN c.date_canceled is not null THEN 'Cancelado'
                WHEN c.date_apply is not null THEN 'Ejecutado'
                ELSE 'Pendiente'
              END = status_filter
            ELSE true
          END
      ORDER BY 
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN el.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN el.id_lock END DESC,
        CASE WHEN sort_field = 'commandName' AND sort_order = 'ASC'
          THEN ct.description END,
        CASE WHEN sort_field = 'commandName' AND sort_order = 'DESC'
          THEN ct.description END DESC,
        CASE WHEN sort_field = 'createdDate' AND sort_order = 'ASC'
          THEN c.date_created END,
        CASE WHEN (sort_field = 'createdDate' AND sort_order = 'DESC')  OR sort_field = ''
          THEN c.date_created END DESC,
        CASE WHEN sort_field = 'applyOrCancelDate' AND sort_order = 'ASC'
          THEN COALESCE(c.date_canceled,c.date_apply,NULL) END,
        CASE WHEN sort_field = 'applyOrCancelDate' AND sort_order = 'DESC'
          THEN COALESCE(c.date_canceled,c.date_apply,NULL) END DESC,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'ASC'
          THEN CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'DESC'
          THEN CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'serviceUserName' AND sort_order = 'ASC'
          THEN CONCAT(serv_us.name::TEXT,' ',serv_us.last_name::TEXT,' ',serv_us.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'serviceUserName' AND sort_order = 'DESC'
          THEN CONCAT(serv_us.name::TEXT,' ',serv_us.last_name::TEXT,' ',serv_us.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'canceledDescription' AND sort_order = 'ASC'
          THEN c.canceled_description END,
        CASE WHEN sort_field = 'canceledDescription' AND sort_order = 'DESC'
          THEN c.canceled_description END DESC,
        CASE WHEN sort_field = 'status' AND sort_order = 'ASC'
          THEN 
            CASE
              WHEN c.date_canceled is not null THEN 'Cancelado'
              WHEN c.date_apply is not null THEN 'Ejecutado'
              ELSE 'Pendiente'
            END 
          END,
        CASE WHEN (sort_field = 'status' AND sort_order = 'DESC')
          THEN 
            CASE
              WHEN c.date_canceled is not null THEN 'Cancelado'
              WHEN c.date_apply is not null THEN 'Ejecutado'
              ELSE 'Pendiente'
            END 
          END DESC;
  END;
$function$;

-- get assignations of a cashier
CREATE OR REPLACE FUNCTION get_assignations_from_cashiers(
    terminal_historical_id TEXT,
    filters TEXT,
    sort_field TEXT,
    sort_order TEXT
  )
  RETURNS TABLE(
    id_lock INT,
    work_mode_name TEXT,
    id_cashier TEXT,
    branch_name TEXT,
    work_mode_date TIMESTAMP WITH TIME ZONE
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    rec RECORD;
    json_filters JSON;
    id_lock_filter TEXT;
    work_mode_name_filter TEXT;
    branch_name_filter TEXT;
    id_cashier_filter TEXT;
    work_mode_date_init TIMESTAMP;
    work_mode_date_finish TIMESTAMP;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_lock_filter := json_filters->'idLock'->>'value';
    work_mode_name_filter := json_filters->'workModeName'->>'value';
    branch_name_filter := json_filters->'branchName'->>'value';
    id_cashier_filter := json_filters->'idCashier'->>'value';

    work_mode_date_init := json_filters->'workModeDate'->'value'->>0;
    work_mode_date_init := work_mode_date_init::TIMESTAMP;
    work_mode_date_finish := json_filters->'workModeDate'->'value'->>1;
    work_mode_date_finish := work_mode_date_finish::TIMESTAMP + INTERVAL '1 day';

    RETURN QUERY
      SELECT
        el.id_lock,
        wm.name::TEXT AS work_mode_name,
        t.name::TEXT AS id_cashier,
        b.name::TEXT AS branch_name,
        el.work_mode_date::TIMESTAMP WITH TIME ZONE
      FROM terminal t
        LEFT JOIN branch b ON b.id_branch = t.id_branch
        INNER JOIN assignment assign ON assign.id_terminal = t.id_terminal
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
        INNER JOIN work_mode wm ON wm.id_work_mode = el.work_mode
      WHERE t.historical_id = get_assignations_from_cashiers.terminal_historical_id AND t.is_deleted = false
        AND 
          CASE
            WHEN id_lock_filter IS NOT NULL OR id_lock_filter != '' 
              THEN el.id_lock::TEXT LIKE CONCAT('%',id_lock_filter,'%')
            ELSE true
          END
        AND 
          CASE
            WHEN work_mode_name_filter IS NOT NULL OR work_mode_name_filter != '' 
              THEN wm.name = work_mode_name_filter
            ELSE true
          END
        AND 
          CASE
            WHEN branch_name_filter IS NOT NULL OR branch_name_filter != '' 
              THEN LOWER(b.name) LIKE CONCAT('%',LOWER(branch_name_filter),'%')
            ELSE true
          END
        AND 
          CASE
            WHEN id_cashier_filter IS NOT NULL OR id_cashier_filter != '' 
              THEN LOWER(t.name) LIKE CONCAT('%',LOWER(id_cashier_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN work_mode_date_finish IS NOT NULL THEN el.work_mode_date >= work_mode_date_init 
              AND el.work_mode_date <= work_mode_date_finish
            ELSE true
          END
      ORDER BY 
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN el.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN el.id_lock END DESC,
        CASE WHEN sort_field = 'workModeName' AND sort_order = 'ASC'
          THEN wm.name END,
        CASE WHEN sort_field = 'workModeName' AND sort_order = 'DESC'
          THEN wm.name END DESC,
        CASE WHEN sort_field = 'branchName' AND sort_order = 'ASC'
          THEN b.name END,
        CASE WHEN sort_field = 'branchName' AND sort_order = 'ASC'
          THEN b.name END DESC,
        CASE WHEN sort_field = 'idCashier' AND sort_order = 'ASC'
          THEN t.name END,
        CASE WHEN sort_field = 'idCashier' AND sort_order = 'ASC'
          THEN t.name END DESC,
        CASE WHEN sort_field = 'workModeDate' AND sort_order = 'ASC'
          THEN el.work_mode_date END,
        CASE WHEN (sort_field = 'workModeDate' AND sort_order = 'ASC') OR sort_field = ''
          THEN el.work_mode_date END DESC,
        CASE WHEN sort_field = ''
          THEN wm.id_work_mode END ;
  END;
$function$;

-- get alarms by id terminal
CREATE OR REPLACE FUNCTION get_cashier_alarms(
    terminal_historical_id TEXT,
    filters TEXT,
    sort_field TEXT,
    sort_order TEXT
  )
  RETURNS TABLE(
    id_lock INT,
    id_alarm INT,
    id_alarm_type INT,
    alarm_type TEXT,
    date_start TIMESTAMP WITH TIME ZONE,
    date_close TIMESTAMP WITH TIME ZONE,
    status BOOLEAN
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$  
  DECLARE
    json_filters JSON;
    id_lock_filter TEXT;
    id_alarm_type_filter INT;
    date_start_init TIMESTAMP;
    date_start_finish TIMESTAMP;
    date_close_init TIMESTAMP;
    date_close_finish TIMESTAMP;
    status_filter BOOLEAN;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_lock_filter := json_filters->'idLock'->>'value';
    id_alarm_type_filter := json_filters->'idAlarmType'->>'value';
    status_filter := json_filters->'status'->>'value';

    date_start_init := json_filters->'dateStart'->'value'->>0;
    date_start_init := date_start_init::TIMESTAMP;
    date_start_finish := json_filters->'dateStart'->'value'->>1;
    date_start_finish := date_start_finish::TIMESTAMP + INTERVAL '1 day';

    date_close_init := json_filters->'dateClose'->'value'->>0;
    date_close_init := date_close_init::TIMESTAMP;
    date_close_finish := json_filters->'dateClose'->'value'->>1;
    date_close_finish := date_close_finish::TIMESTAMP + INTERVAL '1 day';

    RETURN QUERY
      SELECT 
        el.id_lock::INT,
        a.id_alarm::INT,
        at.id_alarm_type::INT,
        at.name::TEXT,
        a.date_start::TIMESTAMP WITH TIME ZONE,
        a.date_close::TIMESTAMP WITH TIME ZONE,
        CASE
          WHEN a.date_close IS NOT NULL THEN true
          ELSE false
        END AS status
      FROM terminal t
        INNER JOIN assignment assign ON assign.id_terminal = t.id_terminal
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
        INNER JOIN alarms a ON a.id_lock = el.id_lock
        INNER JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
      WHERE t.is_deleted = false
        AND 
          CASE
            WHEN get_cashier_alarms.terminal_historical_id IS NOT NULL OR get_cashier_alarms.terminal_historical_id != '' 
              THEN t.historical_id = get_cashier_alarms.terminal_historical_id
            ELSE true
          END
        AND
          CASE
            WHEN (id_lock_filter IS NOT NULL AND id_lock_filter != '') 
              THEN el.id_lock::TEXT LIKE CONCAT('%',id_lock_filter,'%')
            ELSE true
          END
        AND
          CASE
            WHEN id_alarm_type_filter IS NOT NULL THEN at.id_alarm_type = id_alarm_type_filter
            ELSE true
          END
        AND
          CASE
            WHEN status_filter IS NOT NULL THEN a.date_close IS NOT NULL = status_filter
            ELSE true
          END
        AND
          CASE
            WHEN date_start_finish IS NOT NULL THEN a.date_start >= date_start_init 
              AND a.date_start <= date_start_finish
            ELSE true
          END
        AND
          CASE
            WHEN date_close_finish IS NOT NULL THEN a.date_close >= date_close_init 
              AND a.date_close <= date_close_finish
            ELSE true
          END
      ORDER BY 
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN el.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN el.id_lock END DESC,
        CASE WHEN sort_field = 'alarmType' AND sort_order = 'ASC'
          THEN at.name END,
        CASE WHEN sort_field = 'alarmType' AND sort_order = 'DESC'
          THEN at.name END DESC,
        CASE WHEN sort_field = 'dateStart' AND sort_order = 'ASC'
          THEN a.date_start END,
        CASE WHEN sort_field = 'dateStart' AND sort_order = 'DESC' OR sort_field = ''
          THEN a.date_start END DESC,
        CASE WHEN sort_field = 'dateClose' AND sort_order = 'ASC'
          THEN a.date_close END,
        CASE WHEN sort_field = 'dateClose' AND sort_order = 'DESC'
          THEN a.date_close END DESC,
        CASE WHEN sort_field = 'status' AND sort_order = 'ASC' OR sort_field = ''
          THEN 
            CASE
              WHEN a.date_close IS NOT NULL THEN true
              ELSE false
            END 
          END,
        CASE WHEN (sort_field = 'status' AND sort_order = 'DESC')
          THEN 
            CASE
              WHEN a.date_close IS NOT NULL THEN true
              ELSE false
            END 
          END DESC;
  END;
$function$;

-- get events by cashier
CREATE OR REPLACE FUNCTION get_events_from_cashiers(
  terminal_historical_id TEXT,
  sort_field TEXT,
  sort_order TEXT,
  filters TEXT
)
  RETURNS TABLE(
    id_lock INT,
    id_event INT,
    id_event_type INT,
    event_date TIMESTAMP WITH TIME ZONE,
    description TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    json_filters JSON;
    id_lock_filter TEXT;
    description_filter TEXT;
    init_date TIMESTAMP;
    finish_date TIMESTAMP;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;
    id_lock_filter := json_filters->'idLock'->>'value';
    description_filter := json_filters->'description'->>'value';
    init_date := json_filters->'eventDate'->'value'->>0;
    init_date := init_date::TIMESTAMP;
    finish_date := json_filters->'eventDate'->'value'->>1;
    finish_date := finish_date::TIMESTAMP + INTERVAL '1 day';
    RETURN QUERY
      SELECT 
        el.id_lock::INT,
        e.id_event::INT,
        et.id_event_type::INT,
        e.event_date::TIMESTAMP WITH TIME ZONE,
        et.description::TEXT
      FROM terminal t
        INNER JOIN assignment assign ON assign.id_terminal = t.id_terminal
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
        INNER JOIN events e ON e.id_lock = el.id_lock
        INNER JOIN event_type et ON et.id_event_type = e.id_event_type
      WHERE t.is_deleted = false AND
        CASE
          WHEN get_events_from_cashiers.terminal_historical_id IS NOT NULL 
            AND get_events_from_cashiers.terminal_historical_id != ''
              THEN t.historical_id = get_events_from_cashiers.terminal_historical_id
          ELSE true
        END
      AND
        CASE
          WHEN (id_lock_filter IS NOT NULL AND id_lock_filter != '') 
            THEN el.id_lock::TEXT LIKE CONCAT('%',id_lock_filter,'%')
          ELSE true
        END
      AND
        CASE
          WHEN (description_filter IS NOT NULL AND description_filter != '')
            THEN LOWER(et.description) LIKE CONCAT('%',LOWER(description_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN finish_date IS NOT NULL THEN e.event_date >= init_date AND e.event_date <= finish_date
          ELSE true
        END
      ORDER BY 
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN el.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN el.id_lock END DESC,
        CASE WHEN sort_field = 'description' AND sort_order = 'ASC'
          THEN et.description END,
        CASE WHEN sort_field = 'description' AND sort_order = 'DESC'
          THEN et.description END DESC,
        CASE WHEN sort_field = 'eventDate' AND sort_order = 'ASC'
          THEN e.event_date END,
        CASE WHEN (sort_field = 'eventDate' AND sort_order = 'DESC') 
          OR sort_field = ''
            THEN e.event_date END DESC;
  END;
$function$;


-- Commands
-- get all command_types
CREATE OR REPLACE FUNCTION get_all_command_types()
  RETURNS TABLE(
    id_command_type INT,
    description TEXT,
    input_type TEXT,
    with_lock_select BOOLEAN
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT 
        ct.id_command_type::INT, 
        ct.description::TEXT,
        ct.input_type::TEXT,
        ct.with_lock_select::BOOLEAN
      FROM command_type ct;
  END;
$function$;

-- Insert new command for electronic lock
CREATE OR REPLACE FUNCTION insert_new_command(
  IN id_lock INT, 
  IN id_command_type INT,
  IN start_date TIMESTAMP WITHOUT TIME ZONE,
  IN lock_select INT,
  IN id_randomic_operation INT,
  OUT id_command INT,
  OUT date_apply TIMESTAMP WITH TIME ZONE,
  OUT date_canceled TIMESTAMP WITH TIME ZONE,
  OUT command_minutes_running_time INT,
  OUT lock_selected INT
)
 LANGUAGE plpgsql
 VOLATILE
 AS 
$function$
  DECLARE
    exist_command commands;
    command_limit_minutes INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT c.* INTO exist_command FROM commands c WHERE c.id_lock = insert_new_command.id_lock 
      AND c.date_canceled IS NULL AND c.date_apply IS NULL LIMIT 1;
    IF(exist_command IS NULL) THEN
      SELECT current_setting('glob_variables.command_limit_minutes', true)::INT INTO command_limit_minutes;

      INSERT INTO commands (
        id_lock,
        cmd,
        date_created,
        expiration,
        lock_select,
        id_randomic_operation
      ) VALUES (
        insert_new_command.id_lock,
        id_command_type,
        start_date,
        command_limit_minutes * 60,
        lock_select,
        id_randomic_operation
      ) RETURNING commands.id_command,commands.date_apply,commands.date_canceled,commands.lock_select
        INTO insert_new_command.id_command,insert_new_command.date_apply,insert_new_command.date_canceled,insert_new_command.lock_selected;

      insert_new_command.command_minutes_running_time := 60 * command_limit_minutes;
      RETURN;
    ELSE
      RAISE EXCEPTION SQLSTATE '90003' USING 
        MESSAGE = FORMAT('comandoCorriendo');
    END IF;
  END;
$function$;

-- Insert new temporal code command
CREATE OR REPLACE FUNCTION insert_new_temp_code_command(
  IN id_lock INT, 
  IN id_command_type INT,
  IN start_date TIMESTAMP WITHOUT TIME ZONE,
  IN minutes_duration INT,
  IN lock_select INT,
  IN id_randomic_operation INT,
  OUT id_command INT,
  OUT date_created TIMESTAMP WITH TIME ZONE,
  OUT command_minutes_running_time INT,
  OUT duration_time INT,
  OUT generated_code TEXT,
  OUT lock_selected INT
)
 LANGUAGE plpgsql
 VOLATILE
 AS 
$function$
  DECLARE
    exist_command commands;
    command_limit_minutes INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT c.* INTO exist_command FROM commands c WHERE c.id_lock = insert_new_temp_code_command.id_lock 
      AND c.date_canceled IS NULL AND c.date_apply IS NULL LIMIT 1;
    IF(exist_command IS NULL) THEN
      SELECT current_setting('glob_variables.command_limit_minutes', true)::INT INTO command_limit_minutes;

      INSERT INTO commands (
        id_lock,
        cmd,
        expiration,
        duration,
        date_created,
        temp_code,
        lock_select,
        id_randomic_operation
      ) VALUES (
        insert_new_temp_code_command.id_lock,
        id_command_type,
        command_limit_minutes * 60,
        minutes_duration * 60,
        start_date,
        UPPER(encode(gen_random_bytes(4), 'hex')),
        lock_select,
        id_randomic_operation
      ) RETURNING 
          commands.id_command,
          commands.temp_code,
          commands.date_created,
          commands.lock_select
        INTO 
          insert_new_temp_code_command.id_command,
          insert_new_temp_code_command.generated_code,
          insert_new_temp_code_command.date_created,
          insert_new_temp_code_command.lock_selected;

      insert_new_temp_code_command.command_minutes_running_time := command_limit_minutes * 60;
      insert_new_temp_code_command.duration_time := minutes_duration * 60;
      RETURN;
    ELSE
      RAISE EXCEPTION SQLSTATE '90003' USING 
        MESSAGE = FORMAT('comandoCorriendo');
    END IF;
  END;
$function$;

CREATE OR REPLACE FUNCTION check_command_situation(
  IN id_command INT,
  OUT situation TEXT,
  OUT date_apply TIMESTAMPTZ
)
 LANGUAGE plpgsql
 VOLATILE
 AS 
$function$
  DECLARE
    id_system_user INT;
    exist_command commands;
    command_limit_time INTERVAL;
  BEGIN
    PERFORM check_token_validity();
    SELECT c.* INTO exist_command FROM commands c WHERE c.id_command = check_command_situation.id_command;
    command_limit_time := (SELECT current_setting('glob_variables.command_limit_minutes', true)::INT * INTERVAL'1 minute');

    IF(exist_command.code_date_opened IS NOT NULL) THEN
      check_command_situation.situation := 'Abierto';
    ELSIF(exist_command.date_apply IS NOT NULL) THEN
      check_command_situation.situation := 'Aplicado';
      check_command_situation.date_apply := exist_command.date_apply::TIMESTAMPTZ;
    ELSIF (exist_command.date_canceled IS NOT NULL) THEN
      check_command_situation.situation := 'Cancelado';
    ELSIF( exist_command.date_created + (exist_command.expiration/60) * INTERVAL'1 minute' < CURRENT_TIMESTAMP) THEN
      UPDATE commands c SET
        date_canceled = CURRENT_TIMESTAMP,
        canceled_description = 'Se agotó el tiempo límite'
      WHERE c.id_command = check_command_situation.id_command;
      check_command_situation.situation := 'Cancelado';
    ELSE
      check_command_situation.situation := '';
    END IF;
    RETURN;
  END;
$function$;

-- get programmed command
CREATE OR REPLACE FUNCTION get_programmed_command(
  IN id_lock INT,
  OUT id_command INT,
  OUT id_command_type INT,
  OUT date_apply TIMESTAMP WITH TIME ZONE,
  OUT code_date_opened TIMESTAMP WITH TIME ZONE,
  OUT date_canceled TIMESTAMP WITH TIME ZONE,
  OUT date_created TIMESTAMP WITH TIME ZONE,
  OUT command_minutes_running_time INT,
  OUT duration_time INT,
  OUT temp_code TEXT,
  OUT lock_selected INT
)
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    command_limit_minutes INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT 
      c.id_command::INT,
      c.cmd::INT,
      c.date_apply,
      c.code_date_opened,
      c.date_canceled,
      c.date_created,
      c.expiration,
      c.duration,
      c.temp_code,
      c.lock_select
    INTO 
      get_programmed_command.id_command,
      get_programmed_command.id_command_type,
      get_programmed_command.date_apply,
      get_programmed_command.code_date_opened,
      get_programmed_command.date_canceled,
      get_programmed_command.date_created,
      get_programmed_command.command_minutes_running_time,
      get_programmed_command.duration_time,
      get_programmed_command.temp_code,
      get_programmed_command.lock_selected
    FROM commands c 
    WHERE c.id_lock = get_programmed_command.id_lock AND 
      c.date_canceled IS NULL AND c.code_date_opened IS NULL
        AND (c.date_apply IS NULL OR (c.cmd = 7 AND c.date_apply + c.duration * INTERVAL '1 second' > CURRENT_TIMESTAMP)) 
    LIMIT 1;
    RETURN;
  END;
$function$;

-- Alarms
CREATE OR REPLACE FUNCTION get_all_alarm_types()
  RETURNS TABLE(
    id_alarm_type INT,
    name TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT at.id_alarm_type::INT, at.name::TEXT
        FROM alarm_type at;
  END;
$function$;


-- Randomic operations

-- insert randomic operation
CREATE OR REPLACE FUNCTION insert_new_randomic_operation(
  IN system_user_historical_id TEXT,
  IN service_user_historical_id TEXT,
  IN responses TEXT,
  IN id_randomic_operation INT,
  IN timezone TEXT,
  OUT new_id_randomic_operation INT
)
 LANGUAGE plpgsql
 VOLATILE
AS 
$function$
  DECLARE
    lock_record randomic_operation_locks;
    json_responses JSON;
    number_of_tries INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT uol.* INTO lock_record
      FROM randomic_operation_locks AS uol
      INNER JOIN service_user su ON su.historical_id = uol.service_user_historical_id
    WHERE su.historical_id = insert_new_randomic_operation.service_user_historical_id AND su.is_deleted = false 
      AND (uol.lock_date at time zone insert_new_randomic_operation.timezone)::DATE = (CURRENT_TIMESTAMP at time zone insert_new_randomic_operation.timezone)::DATE;

    SELECT 
      CASE 
        WHEN lock_record IS NOT NULL AND lock_record.is_locked = false
          THEN 0
        ELSE COUNT(ro.id_randomic_operation) 
      END
      INTO number_of_tries
    FROM randomic_operation ro 
      INNER JOIN service_user su ON su.historical_id = ro.service_user_historical_id
    WHERE su.historical_id = insert_new_randomic_operation.service_user_historical_id AND su.is_deleted = false
      AND (ro.operation_date at time zone insert_new_randomic_operation.timezone)::DATE = (CURRENT_TIMESTAMP at time zone insert_new_randomic_operation.timezone)::DATE
      AND ro.is_approved = false;

    IF(insert_new_randomic_operation.id_randomic_operation IS NULL AND number_of_tries < 3) THEN
      INSERT INTO randomic_operation (
        system_user_historical_id,
        service_user_historical_id,
        operation_date
      ) VALUES (
        system_user_historical_id,
        service_user_historical_id,
        CURRENT_TIMESTAMP
      ) RETURNING randomic_operation.id_randomic_operation INTO new_id_randomic_operation;
    ELSE
      new_id_randomic_operation := insert_new_randomic_operation.id_randomic_operation;
    END IF;

    IF(responses IS NOT NULL AND new_id_randomic_operation IS NOT NULL) THEN
      json_responses := responses::JSON;
      FOR i IN 0..json_array_length(json_responses)-1 LOOP
        INSERT INTO randomic_operation_questions (
          id_randomic_operation,
          id_question,
          response
        ) VALUES (
          new_id_randomic_operation,
          (json_responses->i->>'idQuestion')::INT,
          json_responses->i->>'userResponse'
        );
      END LOOP;
    END IF;

    RETURN;
  END;
$function$;

CREATE OR REPLACE FUNCTION approve_randomic_operation(
  id_randomic_operation INT
)
 RETURNS void
 LANGUAGE plpgsql
 VOLATILE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    UPDATE randomic_operation ro SET
      is_approved = true
    WHERE
      ro.id_randomic_operation = approve_randomic_operation.id_randomic_operation;
  END;
$function$;

CREATE OR REPLACE FUNCTION get_all_work_modes()
 RETURNS TABLE (id_work_mode int, work_mode_name TEXT)
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT 
        wm.id_work_mode,
        wm.name::TEXT
      FROM work_mode AS wm;
  END;
$FUNCTION$;

--- get electronic lock list
CREATE OR REPLACE FUNCTION get_electronic_lock_list()
 RETURNS TABLE (
    id_electronic_lock INT, 
    id_lock INT,
    id_cashier TEXT,
    work_mode_name TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT
        el.id_electronic_lock::INT,
        el.id_lock::INT,
        t.name::TEXT,
        wm.name::TEXT
      FROM electronic_lock el
        LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
        LEFT JOIN terminal t ON t.id_terminal = assign.id_terminal
        INNER JOIN work_mode wm ON wm.id_work_mode = el.work_mode
      ORDER BY el.id_lock; 
  END;
$function$;

--- get electronic lock list
CREATE OR REPLACE FUNCTION get_historic_work_modes_by_id(id_electronic_lock TEXT)
 RETURNS TABLE (
    id_lock INT, 
    id_historical_lock INT, 
    work_mode_name TEXT,
    id_cashier TEXT,
    branch_name TEXT,
    historic_lock_date TIMESTAMP WITH TIME ZONE
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT 
        el.id_lock,
        hl.id_historical_lock,
        wm.name::TEXT,
        t.name::TEXT,
        b.name::TEXT,
        hl.work_mode_date::TIMESTAMP WITH TIME ZONE
      FROM electronic_lock el 
        INNER JOIN historical_lock hl ON hl.id_lock = el.id_lock
        INNER JOIN work_mode wm ON wm.id_work_mode = hl.id_work_mode
        LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
        LEFT JOIN terminal t ON t.id_terminal = assign.id_terminal
        LEFT JOIN branch b ON b.id_branch = t.id_branch
      WHERE 
        CASE WHEN get_historic_work_modes_by_id.id_electronic_lock IS NOT NULL 
          AND get_historic_work_modes_by_id.id_electronic_lock != ''
            THEN el.id_electronic_lock = get_historic_work_modes_by_id.id_electronic_lock::INT
          ELSE true
        END
      ORDER BY hl.work_mode_date DESC;
  END;
$function$;

-- get electronic lock by id
CREATE OR REPLACE FUNCTION get_electronic_lock_related_data_by_id(
    IN id_electronic_lock INT,
    OUT id_cashier TEXT,
    OUT id_lock INT,
    OUT branch_name TEXT,
    OUT group_name TEXT,
    OUT alarm_type TEXT,
    OUT work_mode INT,
    OUT status BOOLEAN
  )
 LANGUAGE plpgsql
 STABLE
AS 
$function$
  DECLARE
    rec RECORD;
    limit_time INTERVAL;
  BEGIN    
    PERFORM check_token_validity();
    SELECT current_setting('glob_variables.terminal_limit_time', true)::INTERVAL INTO limit_time;

    SELECT 
      t.name::TEXT,
      el.id_lock::INT,
      b.name::TEXT,
      g.name::TEXT,
      at.name,
      el.communication_date + limit_time > CURRENT_TIMESTAMP,
      el.work_mode
      INTO
        id_cashier,
        id_lock,
        branch_name,
        group_name,
        alarm_type,
        status,
        work_mode
      FROM electronic_lock AS el 
        LEFT JOIN assignment assign ON el.id_lock = assign.id_lock
        LEFT JOIN terminal t ON assign.id_terminal = t.id_terminal
        LEFT JOIN branch b ON b.id_branch = t.id_branch
        LEFT JOIN group_terminal gt ON gt.id_terminal = t.id_terminal
          AND gt.is_deleted = false
        LEFT JOIN groups g ON g.id_group = gt.id_group
        LEFT JOIN alarms a ON a.id_lock = el.id_lock AND a.date_close IS NULL
        LEFT JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
      WHERE el.id_electronic_lock = get_electronic_lock_related_data_by_id.id_electronic_lock LIMIT 1;
  END;
$function$;

-- make lock installation
CREATE OR REPLACE FUNCTION make_lock_installation(id_lock INT)
RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
AS 
$function$
  DECLARE
    rec RECORD;
    current_id_terminal INT;
    current_id_assignment INT;
  BEGIN    
    PERFORM check_token_validity();

    SELECT t.id_terminal,assign.id_assignment INTO current_id_terminal,current_id_assignment
    FROM terminal t
      INNER JOIN assignment assign ON assign.id_terminal = t.id_terminal
      INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
    WHERE el.id_lock = make_lock_installation.id_lock AND t.is_deleted = false;

    UPDATE electronic_lock el SET
      work_mode = current_setting('glob_variables.id_work_mode_discharged')::INT
    FROM assignment assign
      INNER JOIN terminal t ON t.id_assignment = assign.id_assignment
    WHERE assign.id_lock = el.id_lock AND t.id_terminal = current_id_terminal AND t.is_deleted = false
      AND el.id_lock != make_lock_installation.id_lock;

    UPDATE terminal t SET
      id_assignment = current_id_assignment
    FROM assignment assign
      INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
    WHERE assign.id_terminal = t.id_terminal AND el.id_lock = make_lock_installation.id_lock AND t.is_deleted = false;

    UPDATE electronic_lock el SET
      work_mode = current_setting('glob_variables.id_work_mode_productive')::INT
    WHERE el.id_lock = make_lock_installation.id_lock;
  END;
$function$;

-- randomic_challenge_opening
CREATE OR REPLACE FUNCTION insert_randomic_challenge_opening(
  IN id_lock INT,
  IN id_randomic_operation INT,
  OUT id_randomic_challenge_opening INT
)
 LANGUAGE plpgsql
 VOLATILE
 AS 
$function$
  BEGIN
    PERFORM check_token_validity();

    INSERT INTO randomic_challenge_opening (
      id_lock,
      id_randomic_operation
    ) VALUES (
      id_lock,
      id_randomic_operation
    ) RETURNING randomic_challenge_opening.id_randomic_challenge_opening
      INTO insert_randomic_challenge_opening.id_randomic_challenge_opening;
    RETURN;
  END;
$function$;

CREATE OR REPLACE FUNCTION set_lock_select_randomic_challenge(
  IN id_randomic_challenge_opening INT,
  IN lock_select INT,
  OUT try_count INT
)
 LANGUAGE plpgsql
 VOLATILE
 AS 
$function$
  BEGIN
    PERFORM check_token_validity();

    UPDATE randomic_challenge_opening rco SET
      lock_select = set_lock_select_randomic_challenge.lock_select,
      try_count = rco.try_count + 1
    WHERE rco.id_randomic_challenge_opening = set_lock_select_randomic_challenge.id_randomic_challenge_opening
    RETURNING rco.try_count INTO set_lock_select_randomic_challenge.try_count;
    RETURN;
  END;
$function$;

CREATE OR REPLACE FUNCTION set_success_randomic_challenge_opening(
  IN id_randomic_challenge_opening INT
)
RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
 AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    UPDATE randomic_challenge_opening rco SET
      success = true
    WHERE rco.id_randomic_challenge_opening = set_success_randomic_challenge_opening.id_randomic_challenge_opening;
  END;
$function$;

CREATE OR REPLACE FUNCTION set_failure_randomic_challenge_opening(
  IN id_randomic_challenge_opening INT,
  IN failure_description TEXT
)
RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
 AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    UPDATE randomic_challenge_opening rco SET
      success = false,
      failure_description = set_failure_randomic_challenge_opening.failure_description
    WHERE rco.id_randomic_challenge_opening = set_failure_randomic_challenge_opening.id_randomic_challenge_opening;
  END;
$function$;-- Commands
CREATE OR REPLACE FUNCTION insert_new_randomic_open_command(
  IN id_lock INT, 
  IN user_email TEXT, 
  OUT randomic_open_limit_time INT
)
 LANGUAGE plpgsql
 VOLATILE
 AS 
$function$
  DECLARE
    id_system_user INT;
    exist_command commands;
  BEGIN
    PERFORM check_token_validity();
    SELECT c.* INTO exist_command FROM commands c WHERE c.id_lock = insert_new_randomic_open_command.id_lock 
      AND c.date_canceled IS NULL AND c.date_apply IS NULL LIMIT 1;
    IF(exist_command IS NULL) THEN
      SELECT s.id_system_user INTO id_system_user FROM system_user s WHERE s.email = user_email;
      INSERT INTO commands (
        id_lock,
        id_system_user,
        cmd
      ) VALUES (
        insert_new_randomic_open_command.id_lock,
        id_system_user,
        1
      );
      SELECT current_setting('glob_variables.command_limit_minutes', true)::INT INTO randomic_open_limit_time;
      randomic_open_limit_time := 1000 * 60 * randomic_open_limit_time;
      RETURN;
    ELSE
      RAISE EXCEPTION SQLSTATE '90003' USING 
        MESSAGE = FORMAT('comandoCorriendo');
    END IF;
  END;
$function$;

CREATE OR REPLACE FUNCTION cancel_randomic_open_command(id_lock INT)
  RETURNS void
 LANGUAGE plpgsql
 AS 
$function$
  DECLARE
    exist_command commands;
    command_limit_time INTERVAL;
  BEGIN
    PERFORM check_token_validity();
    SELECT c.* INTO exist_command FROM commands c 
      WHERE c.id_lock = cancel_randomic_open_command.id_lock AND c.date_canceled IS NULL AND c.date_apply IS NULL LIMIT 1;
    IF(exist_command.date_created + (exist_command.expiration/60) * INTERVAL'1 minute' < CURRENT_TIMESTAMP) THEN
      UPDATE commands c SET
        date_canceled = CURRENT_TIMESTAMP,
        canceled_description = 'Se agotó el tiempo límite'
      WHERE 
        c.id_command = exist_command.id_command;
    END IF;
    RETURN;
  END;
$function$;

CREATE OR REPLACE FUNCTION cancel_commands_from_terminal(terminal_historical_id TEXT)
  RETURNS void
 LANGUAGE plpgsql
 AS 
$function$
  DECLARE
    rec RECORD;
    command_limit_time INTERVAL;
  BEGIN
    FOR rec IN (SELECT c.date_created,c.id_command,c.expiration FROM commands c 
      INNER JOIN electronic_lock el ON el.id_lock = c.id_lock
      INNER JOIN assignment assign ON assign.id_lock = el.id_lock
      INNER JOIN terminal t ON t.id_assignment = assign.id_assignment
      WHERE 
        CASE
          WHEN cancel_commands_from_terminal.terminal_historical_id IS NOT NULL OR cancel_commands_from_terminal.terminal_historical_id != '' 
            THEN t.historical_id = cancel_commands_from_terminal.terminal_historical_id
          ELSE true
        END
        AND c.date_canceled IS NULL AND c.date_apply IS NULL
    	  AND t.is_deleted = false)
    LOOP
      IF(rec.date_created + (rec.expiration/60) * INTERVAL'1 minute' < CURRENT_TIMESTAMP) THEN
        UPDATE commands c SET
          date_canceled = CURRENT_TIMESTAMP,
          canceled_description = 'Se agotó el tiempo límite'
        WHERE 
          c.id_command = rec.id_command;
      END IF;
    END LOOP;
    RETURN;
  END;
$function$;


CREATE OR REPLACE FUNCTION direct_cancel_randomic_open_command(
    IN id_command INT,
    OUT affected_id INT
  )
 LANGUAGE plpgsql
 AS 
$function$
  DECLARE
  BEGIN
    PERFORM check_token_validity();
    UPDATE commands c SET
      date_canceled = CURRENT_TIMESTAMP,
      canceled_description = 'Cancelado manual'
    WHERE 
      c.id_command = direct_cancel_randomic_open_command.id_command AND c.date_canceled IS NULL
      RETURNING c.id_command INTO affected_id;
    RETURN;
  END;
$function$;

CREATE OR REPLACE FUNCTION get_service_users_with_responses()
  RETURNS TABLE(
    id_service_user INT,
    complete_name TEXT,
    nip TEXT,
    responses JSONB
  )
 LANGUAGE plpgsql
 STABLE
 AS 
$function$
  DECLARE
    rec RECORD;
  BEGIN
    PERFORM check_token_validity();
    FOR rec IN (SELECT 
      s.id_service_user,
      CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT) as complete_name,
      s.nip 
    FROM service_user s WHERE s.is_deleted = false ORDER BY s.name)
    LOOP
      get_service_users_with_responses.responses := (SELECT jsonb_object_agg(r.id_question,r.response) FROM service_user_responses r
        WHERE r.id_service_user = rec.id_service_user);
      get_service_users_with_responses.id_service_user = rec.id_service_user;
      get_service_users_with_responses.complete_name = rec.complete_name;
      get_service_users_with_responses.nip = rec.nip;
      RETURN NEXT;
    END LOOP;
  END;
$function$;

CREATE OR REPLACE FUNCTION get_cashiers_report()
  RETURNS TABLE(
    id_terminal INT,
    id_cashier TEXT,
    branch_name TEXT,
    modelo TEXT,
    marca TEXT,
    address TEXT,
    address_suburb TEXT,
    address_city TEXT,
    address_county TEXT,
    address_state TEXT,
    address_zip_code TEXT,
    id_lock INT
  )
 LANGUAGE plpgsql
 STABLE
 AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY 
      SELECT 
        t.id_terminal,
        t.name::TEXT,
        b.name::TEXT,
        t.model::TEXT as modelo, 
        '' as marca,
        CONCAT(b.address_street,' ',b.address_street_number)::TEXT as address,
        b.address_suburb::TEXT,
        b.address_city::TEXT,
        b.address_county::TEXT,
        b.address_state::TEXT,
        b.address_zip_code::TEXT,
        el.id_lock
      FROM terminal t
        LEFT JOIN assignment assign ON assign.id_assignment = t.id_assignment
        LEFT JOIN electronic_lock el ON el.id_lock = assign.id_lock
        LEFT JOIN branch b ON b.id_branch = t.id_branch
      WHERE t.is_deleted = false
      ORDER BY t.name;
  END;
$function$;

CREATE OR REPLACE FUNCTION get_operations_report(
    filters TEXT
  )
  RETURNS TABLE(
    id INT,
    id_cashier TEXT,
    description TEXT,
    date TIMESTAMP WITH TIME ZONE,
    invoice TEXT,
    activity TEXT,
    branch_name TEXT,
    address_state TEXT,
    service_user_name TEXT,
    organization TEXT,
    system_user_name TEXT
  )
 LANGUAGE plpgsql
 STABLE
 AS 
$function$
  DECLARE
    json_filters JSON;
    id_cashier_filter TEXT;
    description_filter TEXT;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
    invoice_filter TEXT;
    activity_filter TEXT;
    branch_name_filter TEXT;
    address_state_filter TEXT;
    service_user_name_filter TEXT;
    organization_filter TEXT;
    system_user_name_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;
    id_cashier_filter := json_filters->'idCashier'->>'value';
    description_filter := json_filters->'description'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    invoice_filter := json_filters->'invoice'->>'value';
    activity_filter := json_filters->'activity'->>'value';
    branch_name_filter := json_filters->'branchName'->>'value';
    address_state_filter := json_filters->'addressState'->>'value';
    service_user_name_filter := json_filters->'serviceUserName'->>'value';
    organization_filter := json_filters->'organization'->>'value';
    system_user_name_filter := json_filters->'systemUserName'->>'value';

    RETURN QUERY 
        SELECT * FROM
      (SELECT
        e.id_event as id,
        t.name::TEXT as id_cashier,
        et.description::TEXT,
        e.event_date::TIMESTAMP WITH TIME ZONE as date,
        '' as invoice,
        '' as activity,
        b.name::TEXT as branch_name,
        b.address_state::TEXT as branch_address_state,
        '' as service_user,
        '' as organization,
        '' as system_user
      FROM terminal t
        INNER JOIN branch b ON b.id_branch = t.id_branch
        INNER JOIN assignment assign ON assign.id_assignment = t.id_assignment
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
        INNER JOIN events e ON e.id_lock = el.id_lock
        INNER JOIN event_type et ON et.id_event_type = e.id_event_type
      WHERE t.is_deleted = false
      UNION
      SELECT
        a.id_alarm as id,
        t.name::TEXT,
        at.name::TEXT as description,
        a.date_start as date,
        '' as folio,
        '' as activity,
        b.name::TEXT,
        b.address_state::TEXT,
        '' as service_user,
        '' as organization,
        '' as system_user
      FROM terminal t
        INNER JOIN branch b ON b.id_branch = t.id_branch
        INNER JOIN assignment assign ON assign.id_assignment = t.id_assignment
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
        INNER JOIN alarms a ON a.id_lock = el.id_lock
        INNER JOIN alarm_type at ON at.id_alarm_type = a.id_alarm_type
      WHERE t.is_deleted = false
      UNION
      SELECT
        hl.id_historical_lock as id,
        COALESCE(t.name::TEXT,CONCAT('Id chapa ',el.id_lock::TEXT)) as id_cashier,
        CONCAT('Cambio al modo ',LOWER(wm.name)),
        hl.work_mode_date::TIMESTAMP WITH TIME ZONE as date,
        '' as invoice,
        '' as activity,
        b.name::TEXT as branch_name,
        b.address_state::TEXT as branch_address_state,
        '' as service_user,
        '' as organization,
        '' as system_user
      FROM historical_lock hl
        INNER JOIN work_mode wm ON wm.id_work_mode = hl.id_work_mode
        INNER JOIN electronic_lock el ON el.id_lock = hl.id_lock
        LEFT JOIN assignment assign ON assign.id_lock = el.id_lock
        LEFT JOIN terminal t ON assign.id_terminal = t.id_terminal and t.is_deleted = false
        LEFT JOIN branch b ON b.id_branch = t.id_branch
      ) as ops
      WHERE 
        CASE
          WHEN id_cashier_filter IS NOT NULL AND id_cashier_filter != '' 
            THEN LOWER(ops.id_cashier) LIKE CONCAT('%',LOWER(id_cashier_filter),'%')
          ELSE true
        END
      AND 
        CASE
          WHEN description_filter IS NOT NULL AND description_filter != '' 
            THEN LOWER(ops.description) LIKE CONCAT('%',LOWER(description_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN date_finish IS NOT NULL THEN 
            ops.date >= date_init AND ops.date <= date_finish
          ELSE true
        END
      AND 
        CASE
          WHEN invoice_filter IS NOT NULL AND invoice_filter != '' 
            THEN false -- folio filter
          ELSE true
        END
      AND 
        CASE
          WHEN activity_filter IS NOT NULL AND activity_filter != '' 
            THEN false -- activity filter
          ELSE true
        END
      AND 
        CASE
          WHEN branch_name_filter IS NOT NULL AND branch_name_filter != '' 
            THEN LOWER(ops.branch_name) LIKE CONCAT('%',LOWER(branch_name_filter),'%')
          ELSE true
        END
      AND 
        CASE
          WHEN address_state_filter IS NOT NULL AND address_state_filter != '' 
            THEN LOWER(ops.branch_address_state) LIKE CONCAT('%',LOWER(address_state_filter),'%')
          ELSE true
        END
      AND 
        CASE
          WHEN service_user_name_filter IS NOT NULL AND service_user_name_filter != '' 
            THEN false -- service user name filter
          ELSE true
        END
      AND 
        CASE
          WHEN organization_filter IS NOT NULL AND organization_filter != '' 
            THEN false -- organization filter
          ELSE true
        END
      AND 
        CASE
          WHEN system_user_name_filter IS NOT NULL AND system_user_name_filter != '' 
            THEN false -- system user name filter
          ELSE true
        END
      ORDER BY date DESC;
  END;
$function$;

CREATE OR REPLACE FUNCTION system_user_actions_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
 RETURNS TABLE(
   affected_user TEXT,
   responsable TEXT,
   action TEXT,
   date TIMESTAMPTZ,
   additional_information TEXT
 )
 LANGUAGE plpgsql
 STABLE
AS $FUNCTION$
  DECLARE
    json_filters JSON;
    affected_user_filter TEXT;
    responsable_filter TEXT;
    action_filter TEXT;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
    additional_information_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    affected_user_filter := json_filters->'affectedUser'->>'value';
    responsable_filter := json_filters->'responsable'->>'value';
    action_filter := json_filters->'action'->>'value';
    additional_information_filter := json_filters->'additionalInformation'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    RETURN QUERY
      SELECT 
        CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT) as affected_user,
        CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) as responsable,
        s.historical_action::TEXT as action,
        COALESCE(s.date_updated,s.date_deleted,s.date_created)::timestamptz as date,
        CASE WHEN s.deleted_reason IS NOT NULL THEN CONCAT('Motivo: ',s.deleted_reason::TEXT) END
      FROM system_user s
        INNER JOIN system_user responsable ON s.historical_action_user_id = responsable.historical_id
          AND responsable.is_deleted = false
      WHERE 
          CASE
            WHEN affected_user_filter IS NOT NULL AND affected_user_filter != '' 
              THEN LOWER(CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT)) 
                LIKE CONCAT('%',LOWER(affected_user_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN responsable_filter IS NOT NULL AND responsable_filter != '' 
              THEN LOWER(CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT)) 
                LIKE CONCAT('%',LOWER(responsable_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN action_filter IS NOT NULL AND action_filter != '' 
              THEN s.historical_action::TEXT = action_filter
            ELSE true
          END
        AND
          CASE
            WHEN date_finish IS NOT NULL THEN 
              COALESCE(s.date_updated,s.date_deleted,s.date_created) >= date_init 
                AND COALESCE(s.date_updated,s.date_deleted,s.date_created) <= date_finish
            ELSE true
          END
        AND
          CASE
            WHEN additional_information_filter IS NOT NULL AND additional_information_filter != '' 
              THEN LOWER(s.deleted_reason) LIKE CONCAT('%',LOWER(additional_information_filter),'%')
            ELSE true
          END
      ORDER BY 
        CASE WHEN sort_field = 'affectedUser' AND sort_order = 'ASC'
          THEN CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'affectedUser' AND sort_order = 'DESC'
          THEN CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'ASC'
          THEN CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'DESC'
          THEN CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'action' AND sort_order = 'ASC'
          THEN s.historical_action::TEXT END,
        CASE WHEN sort_field = 'action' AND sort_order = 'DESC'
          THEN s.historical_action::TEXT END DESC,
        CASE WHEN sort_field = 'date' AND sort_order = 'ASC'
          THEN COALESCE(s.date_updated,s.date_deleted,s.date_created) END,
        CASE WHEN (sort_field = 'date' AND sort_order = 'DESC') or sort_field = ''
          THEN COALESCE(s.date_updated,s.date_deleted,s.date_created) END DESC,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'ASC'
          THEN s.deleted_reason END,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'DESC'
          THEN s.deleted_reason END DESC;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION service_user_actions_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
 RETURNS TABLE(
   affected_user TEXT,
   responsable TEXT,
   action TEXT,
   date TIMESTAMPTZ,
   additional_information TEXT
 )
 LANGUAGE plpgsql
 STABLE
AS $FUNCTION$
  DECLARE
    json_filters JSON;
    affected_user_filter TEXT;
    responsable_filter TEXT;
    action_filter TEXT;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
    additional_information_filter TEXT;
    deleted_reason_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    affected_user_filter := json_filters->'affectedUser'->>'value';
    responsable_filter := json_filters->'responsable'->>'value';
    action_filter := json_filters->'action'->>'value';
    additional_information_filter := json_filters->'additionalInformation'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';
    RETURN QUERY
      SELECT 
        CONCAT(s.name,' ',s.last_name,' ',s.mothers_last_name)::TEXT as affected_user, 
        CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) as responsable,
        s.historical_action::TEXT as action,
        COALESCE(s.date_updated,s.date_created)::timestamptz as date,
        CASE 
          WHEN s.deleted_reason IS NOT NULL THEN CONCAT('Motivo: ',s.deleted_reason::TEXT) 
          WHEN s.creation_mode IS NOT NULL THEN CONCAT('Modo de creación: ',s.creation_mode::TEXT)
        END
      FROM service_user s
        INNER JOIN system_user responsable ON s.historical_action_user_id = responsable.historical_id
          AND responsable.is_deleted = false
		  WHERE s.historical_action != 'ASIGNACIÓN' AND
        CASE
          WHEN affected_user_filter IS NOT NULL AND affected_user_filter != '' 
            THEN LOWER(CONCAT(s.name,' ',s.last_name,' ',s.mothers_last_name)) LIKE CONCAT('%',LOWER(affected_user_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN responsable_filter IS NOT NULL AND responsable_filter != '' 
            THEN LOWER(CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT)) 
              LIKE CONCAT('%',LOWER(responsable_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN action_filter IS NOT NULL AND action_filter != '' 
            THEN s.historical_action::TEXT = action_filter
          ELSE true
        END
      AND
        CASE
          WHEN date_finish IS NOT NULL THEN 
            COALESCE(s.date_updated,s.date_created) >= date_init 
              AND COALESCE(s.date_updated,s.date_created) <= date_finish
          ELSE true
        END
      AND
        CASE
          WHEN additional_information_filter IS NOT NULL AND additional_information_filter != '' 
            THEN COALESCE(LOWER(s.creation_mode),LOWER(s.deleted_reason)) LIKE CONCAT('%',LOWER(additional_information_filter),'%')
          ELSE true
        END
      ORDER BY
        CASE WHEN sort_field = 'affectedUser' AND sort_order = 'ASC'
          THEN CONCAT(s.name,' ',s.last_name,' ',s.mothers_last_name) END,
        CASE WHEN sort_field = 'affectedUser' AND sort_order = 'DESC'
          THEN CONCAT(s.name,' ',s.last_name,' ',s.mothers_last_name) END DESC,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'ASC'
          THEN CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'DESC'
          THEN CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'action' AND sort_order = 'ASC'
          THEN s.historical_action::TEXT END,
        CASE WHEN sort_field = 'action' AND sort_order = 'DESC'
          THEN s.historical_action::TEXT END DESC,
        CASE WHEN sort_field = 'date' AND sort_order = 'ASC'
          THEN COALESCE(s.date_updated,s.date_created) END,
        CASE WHEN (sort_field = 'date' AND sort_order = 'DESC') or sort_field = ''
          THEN COALESCE(s.date_updated,s.date_created) END DESC,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'ASC'
          THEN COALESCE(s.creation_mode::TEXT,s.deleted_reason::TEXT) END,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'DESC'
          THEN COALESCE(s.creation_mode::TEXT,s.deleted_reason::TEXT) END DESC;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION groups_actions_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
 RETURNS TABLE(
   affected_entity TEXT,
   responsable TEXT,
   action TEXT,
   date TIMESTAMPTZ,
   additional_information TEXT
 )
 LANGUAGE plpgsql
 STABLE
AS $FUNCTION$
  DECLARE
    json_filters JSON;
    affected_entity_filter TEXT;
    responsable_filter TEXT;
    action_filter TEXT;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
    additional_information_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    affected_entity_filter := json_filters->'affectedEntity'->>'value';
    responsable_filter := json_filters->'responsable'->>'value';
    action_filter := json_filters->'action'->>'value';
    additional_information_filter := json_filters->'additionalInformation'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    RETURN QUERY
      SELECT * FROM
      (
        SELECT 
          CONCAT('Grupo: ',g.name)::TEXT as affected_entity, 
          CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) as responsable,
          g.historical_action::TEXT as action,
          COALESCE(g.date_updated,g.date_created)::timestamptz as date,
          '' AS additional_information
        FROM groups g
          INNER JOIN system_user responsable ON g.historical_action_user_id = responsable.historical_id
            AND responsable.is_deleted = false
      UNION
        SELECT 
			      CONCAT('Cajero: ',cashier_assignations.terminal_name)::TEXT as entity,
          	CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT),
          	cashier_assignations.event::TEXT as action,
          	cashier_assignations.date_created::timestamptz,
            COALESCE(cashier_assignations.group_name,'Sin grupo')::TEXT
        FROM 
        (
          (
            SELECT 
              t.historical_action as terminal_historical_action
			        ,t.historical_action_user_id
              ,g.id_group
              ,t.name AS terminal_name
              ,t.date_created
              ,g.historical_id as type_historical_id
              ,lead(g.historical_id) OVER w as next_type_historical_id
              ,g.name AS group_name
              ,t.date_updated AS terminal_date_updated
              ,'ASIGNACIÓN' AS event
            FROM terminal t
              LEFT JOIN group_terminal gt ON t.id_terminal = gt.id_terminal 
              LEFT JOIN groups g ON g.id_group = gt.id_group 
            WHERE ((g.id_group IS NOT NULL AND t.historical_action = 'CREACIÓN') OR t.historical_action != 'CREACIÓN')
            WINDOW w AS (PARTITION BY t.historical_id ORDER BY t.date_created DESC)
          )
          UNION
          (
            SELECT 
              t.historical_action as terminal_historical_action
			        ,t.historical_action_user_id
              ,lead(g.id_group) OVER w
              ,t.name AS terminal_name
              ,t.date_created
              ,g.historical_id as type_historical_id
              ,lead(g.historical_id) OVER w as next_type_historical_id
              ,lead(g.name) OVER w as next_type_name
              ,lead(t.date_updated) OVER w as next_terminal_date_updated
              ,'DESASIGNACIÓN' AS event
            FROM terminal t
              LEFT JOIN group_terminal gt ON t.id_terminal = gt.id_terminal 
              LEFT JOIN groups g ON g.id_group = gt.id_group 
            WHERE (t.historical_action != 'CREACIÓN' OR (t.historical_action = 'CREACIÓN' AND g.historical_id IS NOT NULL))
            WINDOW w AS (PARTITION BY t.historical_id ORDER BY t.date_created DESC)
          )
        ) cashier_assignations
        INNER JOIN system_user responsable ON cashier_assignations.historical_action_user_id = responsable.historical_id
          AND responsable.is_deleted = false
          WHERE (cashier_assignations.terminal_historical_action = 'CREACIÓN' AND cashier_assignations.id_group IS NOT NULL)
            OR (
              cashier_assignations.terminal_historical_action != 'CREACIÓN' 
              AND 
              (
                cashier_assignations.type_historical_id != cashier_assignations.next_type_historical_id
                  OR 
                cashier_assignations.type_historical_id IS NOT NULL AND cashier_assignations.next_type_historical_id IS NULL
                  OR 
                cashier_assignations.type_historical_id IS NULL AND cashier_assignations.next_type_historical_id IS NOT NULL
              )
            )
        UNION 
          SELECT 
            CONCAT('Usuario de servicio: ',service_user_assignations.complete_name)::TEXT as entity,
            CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT),
            service_user_assignations.event::TEXT as action,
            service_user_assignations.date_created::timestamptz,
            COALESCE(service_user_assignations.group_name,'Sin grupo')::TEXT
          FROM 
            (
              (
              SELECT 
                s.historical_action as service_user_historical_action
                ,s.historical_action_user_id
                ,g.id_group
                ,CONCAT(s.name,' ',s.last_name,' ',s.mothers_last_name) AS complete_name
                ,s.date_created
                ,g.historical_id as type_historical_id
                ,lead(g.historical_id) OVER w as next_type_historical_id
                ,g.name AS group_name
                ,s.date_updated AS terminal_date_updated
                ,'ASIGNACIÓN' AS event
              FROM service_user s
                LEFT JOIN groups_service_user gs ON s.id_service_user = gs.id_service_user 
                LEFT JOIN groups g ON g.id_group = gs.id_group 
              WHERE ((g.id_group IS NOT NULL AND s.historical_action = 'CREACIÓN') OR s.historical_action != 'CREACIÓN')
                WINDOW w AS (PARTITION BY s.historical_id ORDER BY s.date_created DESC)
              )
            UNION
              (
                SELECT 
                  s.historical_action
                  ,s.historical_action_user_id
                  ,lead(g.id_group) OVER w
                  ,CONCAT(s.name,' ',s.last_name,' ',s.mothers_last_name) AS complete_name
                  ,s.date_created
                  ,g.historical_id as type_historical_id
                  ,lead(g.historical_id) OVER w as next_type_historical_id
                  ,lead(g.name) OVER w as next_type_name
                  ,lead(s.date_updated) OVER w as next_terminal_date_updated
                  ,'DESASIGNACIÓN' AS event
                FROM service_user s
                  LEFT JOIN groups_service_user gs ON s.id_service_user = gs.id_service_user 
                  LEFT JOIN groups g ON g.id_group = gs.id_group 
                WHERE (s.historical_action != 'CREACIÓN' OR (s.historical_action = 'CREACIÓN' AND g.historical_id IS NOT NULL))
                  WINDOW w AS (PARTITION BY s.historical_id ORDER BY s.date_created DESC)
              )
            ) service_user_assignations
            INNER JOIN system_user responsable ON service_user_assignations.historical_action_user_id = responsable.historical_id
              AND responsable.is_deleted = false
            WHERE (service_user_assignations.service_user_historical_action = 'CREACIÓN' AND service_user_assignations.id_group IS NOT NULL)
              OR (
                service_user_assignations.service_user_historical_action != 'CREACIÓN' AND 
                (
                    service_user_assignations.type_historical_id != service_user_assignations.next_type_historical_id
                  OR 
                    service_user_assignations.type_historical_id IS NOT NULL AND service_user_assignations.next_type_historical_id IS NULL
                  OR 
                    service_user_assignations.type_historical_id IS NULL AND service_user_assignations.next_type_historical_id IS NOT NULL
                )
              )
      ) group_events
        WHERE
          CASE
            WHEN affected_entity_filter IS NOT NULL AND affected_entity_filter != '' 
              THEN LOWER(group_events.affected_entity) LIKE CONCAT('%',LOWER(affected_entity_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN responsable_filter IS NOT NULL AND responsable_filter != '' 
              THEN LOWER(group_events.responsable) LIKE CONCAT('%',LOWER(responsable_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN action_filter IS NOT NULL AND action_filter != '' 
              THEN LOWER(group_events.action) LIKE CONCAT(LOWER(action_filter),'%')
            ELSE true
          END 
        AND
          CASE
            WHEN date_finish IS NOT NULL THEN 
              group_events.date >= date_init AND group_events.date <= date_finish
            ELSE true
          END
        AND
          CASE
            WHEN additional_information_filter IS NOT NULL AND additional_information_filter != '' THEN 
              LOWER(group_events.additional_information) LIKE CONCAT('%',LOWER(additional_information_filter),'%')
            ELSE true
          END
      ORDER BY
        CASE WHEN sort_field = 'affectedEntity' AND sort_order = 'ASC'
          THEN group_events.affected_entity END,
        CASE WHEN sort_field = 'affectedEntity' AND sort_order = 'DESC'
          THEN group_events.affected_entity END DESC,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'ASC'
          THEN group_events.responsable END,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'DESC'
          THEN group_events.responsable END DESC,
        CASE WHEN sort_field = 'date' AND sort_order = 'ASC'
          THEN group_events.date END,
        CASE WHEN (sort_field = 'date' AND sort_order = 'DESC') or sort_field = ''
          THEN group_events.date END DESC,
        CASE WHEN (sort_field = 'action' AND sort_order = 'ASC') or sort_field = ''
          THEN group_events.action END,
        CASE WHEN sort_field = 'action' AND sort_order = 'DESC'
          THEN group_events.action END DESC,
        CASE WHEN (sort_field = 'additionalInformation' AND sort_order = 'ASC') or sort_field = ''
          THEN group_events.additional_information END,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'DESC'
          THEN group_events.additional_information END DESC;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION branches_actions_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
 RETURNS TABLE(
   affected_branch TEXT,
   responsable TEXT,
   action TEXT,
   date TIMESTAMPTZ
 )
 LANGUAGE plpgsql
 STABLE
AS $FUNCTION$
  DECLARE
    json_filters JSON;
    affected_branch_filter TEXT;
    responsable_filter TEXT;
    action_filter TEXT;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    affected_branch_filter := json_filters->'affectedBranch'->>'value';
    responsable_filter := json_filters->'responsable'->>'value';
    action_filter := json_filters->'action'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    RETURN QUERY
      SELECT 
        b.name::TEXT as affected_branch, 
        CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) as responsable,
        b.historical_action::TEXT as action,
        COALESCE(b.date_updated,b.date_created)::timestamptz as date
      FROM branch b
        INNER JOIN system_user responsable ON b.historical_action_user_id = responsable.historical_id
          AND responsable.is_deleted = false
      WHERE
          CASE
            WHEN affected_branch_filter IS NOT NULL AND affected_branch_filter != '' 
              THEN LOWER(b.name) LIKE CONCAT('%',LOWER(affected_branch_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN responsable_filter IS NOT NULL AND responsable_filter != '' 
              THEN LOWER(CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT)) 
                LIKE CONCAT('%',LOWER(responsable_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN action_filter IS NOT NULL AND action_filter != '' 
              THEN b.historical_action::TEXT = action_filter
            ELSE true
          END
        AND
          CASE
            WHEN date_finish IS NOT NULL THEN 
              COALESCE(b.date_updated,b.date_created) >= date_init 
                AND COALESCE(b.date_updated,b.date_created) <= date_finish
            ELSE true
          END
      ORDER BY
        CASE WHEN sort_field = 'affectedBranch' AND sort_order = 'ASC'
          THEN b.name END,
        CASE WHEN sort_field = 'affectedBranch' AND sort_order = 'DESC'
          THEN b.name END DESC,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'ASC'
          THEN CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'DESC'
          THEN CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'action' AND sort_order = 'ASC'
          THEN b.historical_action::TEXT END,
        CASE WHEN sort_field = 'action' AND sort_order = 'DESC'
          THEN b.historical_action::TEXT END DESC,
        CASE WHEN sort_field = 'date' AND sort_order = 'ASC'
          THEN COALESCE(b.date_updated,b.date_created) END,
        CASE WHEN (sort_field = 'date' AND sort_order = 'DESC') or sort_field = ''
          THEN COALESCE(b.date_updated,b.date_created) END DESC;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION cashier_actions_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
 RETURNS TABLE(
   affected_cashier TEXT,
   responsable TEXT,
   action TEXT,
   date TIMESTAMPTZ,
   additional_information TEXT
 )
 LANGUAGE plpgsql
 STABLE
AS $FUNCTION$
  DECLARE
    json_filters JSON;
    affected_cashier_filter TEXT;
    responsable_filter TEXT;
    action_filter TEXT;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
    additional_information_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    affected_cashier_filter := json_filters->'affectedCashier'->>'value';
    responsable_filter := json_filters->'responsable'->>'value';
    action_filter := json_filters->'action'->>'value';
    additional_information_filter := json_filters->'additionalInformation'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    RETURN QUERY
      SELECT 
        t.name::TEXT as affected_cashier, 
        CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) as responsable,
        t.historical_action::TEXT as action,
        COALESCE(t.date_updated,t.date_created)::timestamptz as date,
        CASE WHEN t.creation_mode IS NOT NULL THEN CONCAT('Modo de creación: ',t.creation_mode::TEXT) END
      FROM terminal t
        INNER JOIN system_user responsable ON t.historical_action_user_id = responsable.historical_id
          AND responsable.is_deleted = false
		WHERE t.historical_action != 'ASIGNACIÓN' AND
        CASE
          WHEN affected_cashier_filter IS NOT NULL AND affected_cashier_filter != '' 
            THEN LOWER(t.name) LIKE CONCAT('%',LOWER(affected_cashier_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN responsable_filter IS NOT NULL AND responsable_filter != '' 
            THEN LOWER(CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT)) 
              LIKE CONCAT('%',LOWER(responsable_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN action_filter IS NOT NULL AND action_filter != '' 
            THEN t.historical_action::TEXT = action_filter
          ELSE true
        END
      AND
        CASE
          WHEN date_finish IS NOT NULL THEN 
            COALESCE(t.date_updated,t.date_created) >= date_init 
              AND COALESCE(t.date_updated,t.date_created) <= date_finish
          ELSE true
        END
      AND
        CASE
          WHEN additional_information_filter IS NOT NULL AND additional_information_filter != '' 
            THEN LOWER(t.creation_mode) LIKE CONCAT('%',LOWER(additional_information_filter),'%')
          ELSE true
        END
      ORDER BY
        CASE WHEN sort_field = 'affectedCashier' AND sort_order = 'ASC'
          THEN t.name END,
        CASE WHEN sort_field = 'affectedCashier' AND sort_order = 'DESC'
          THEN t.name END DESC,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'ASC'
          THEN CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'responsable' AND sort_order = 'DESC'
          THEN CONCAT(responsable.name::TEXT,' ',responsable.last_name::TEXT,' ',responsable.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'action' AND sort_order = 'ASC'
          THEN t.historical_action::TEXT END,
        CASE WHEN sort_field = 'action' AND sort_order = 'DESC'
          THEN t.historical_action::TEXT END DESC,
        CASE WHEN sort_field = 'date' AND sort_order = 'ASC'
          THEN COALESCE(t.date_updated,t.date_created) END,
        CASE WHEN (sort_field = 'date' AND sort_order = 'DESC') or sort_field = ''
          THEN COALESCE(t.date_updated,t.date_created) END DESC,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'ASC'
          THEN t.creation_mode END,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'DESC'
          THEN t.creation_mode END DESC;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION randomic_challenge_opening_actions_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
  RETURNS TABLE(
    id_lock INT,
    success BOOLEAN,
    system_user_name TEXT,
    service_user_name TEXT,
    lock_select INT,
    date TIMESTAMPTZ,
    additional_information TEXT
 )
 LANGUAGE plpgsql
 STABLE
AS $FUNCTION$
  DECLARE
    json_filters JSON;
    id_lock_filter TEXT;
    success_filter TEXT;
    system_user_name_filter TEXT;
    service_user_name_filter TEXT;
    lock_select_filter TEXT;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
    additional_information_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    id_lock_filter := json_filters->'idLock'->>'value';
    success_filter := json_filters->'success'->>'value';
    system_user_name_filter := json_filters->'systemUserName'->>'value';
    service_user_name_filter := json_filters->'serviceUserName'->>'value';
    lock_select_filter := json_filters->'lockSelect'->>'value';
    additional_information_filter := json_filters->'additionalInformation'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';
    RETURN QUERY
      SELECT 
        rco.id_lock,
        rco.success,
        CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT) as system_user_name,
        CONCAT(serv_us.name,' ',serv_us.last_name,' ',serv_us.mothers_last_name) as service_user_name,
        rco.lock_select,
        rco.date::TIMESTAMPTZ,
        rco.failure_description::TEXT
      FROM randomic_challenge_opening rco
        INNER JOIN randomic_operation ro ON ro.id_randomic_operation = rco.id_randomic_operation
        INNER JOIN system_user sys_us ON ro.system_user_historical_id = sys_us.historical_id
          AND sys_us.is_deleted = false
        INNER JOIN service_user serv_us ON ro.service_user_historical_id = serv_us.historical_id
          AND serv_us.is_deleted = false
      WHERE 
        CASE
          WHEN id_lock_filter IS NOT NULL AND id_lock_filter != '' 
            THEN rco.id_lock::TEXT LIKE CONCAT('%',LOWER(id_lock_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN success_filter IS NOT NULL AND success_filter = 'success' THEN rco.success = true
          WHEN success_filter IS NOT NULL AND success_filter = 'failure' THEN rco.success = false
          WHEN success_filter IS NOT NULL AND success_filter = 'null' THEN rco.success IS NULL
          ELSE true
        END
      AND
        CASE
          WHEN system_user_name_filter IS NOT NULL AND system_user_name_filter != '' 
            THEN LOWER(CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT)) 
              LIKE CONCAT('%',LOWER(system_user_name_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN service_user_name_filter IS NOT NULL AND service_user_name_filter != '' 
            THEN LOWER(CONCAT(serv_us.name,' ',serv_us.last_name,' ',serv_us.mothers_last_name)) 
              LIKE CONCAT('%',LOWER(service_user_name_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN lock_select_filter IS NOT NULL AND lock_select_filter != '' 
            THEN rco.lock_select = lock_select_filter::INT
          ELSE true
        END
      AND
        CASE
          WHEN date_finish IS NOT NULL THEN 
            rco.date >= date_init AND rco.date <= date_finish
          ELSE true
        END
      AND
        CASE
          WHEN additional_information_filter IS NOT NULL AND additional_information_filter != '' 
            THEN LOWER(rco.failure_description) LIKE CONCAT('%',LOWER(additional_information_filter),'%')
          ELSE true
        END
      ORDER BY
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN rco.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN rco.id_lock END DESC,
        CASE WHEN sort_field = 'success' AND sort_order = 'ASC'
          THEN rco.success END,
        CASE WHEN sort_field = 'success' AND sort_order = 'DESC'
          THEN rco.success END DESC,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'ASC'
          THEN CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'DESC'
          THEN CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'serviceUserName' AND sort_order = 'ASC'
          THEN CONCAT(serv_us.name,' ',serv_us.last_name,' ',serv_us.mothers_last_name) END,
        CASE WHEN sort_field = 'serviceUserName' AND sort_order = 'DESC'
          THEN CONCAT(serv_us.name,' ',serv_us.last_name,' ',serv_us.mothers_last_name) END DESC,
        CASE WHEN sort_field = 'lockSelect' AND sort_order = 'ASC'
          THEN rco.lock_select END,
        CASE WHEN sort_field = 'lockSelect' AND sort_order = 'DESC'
          THEN rco.lock_select END DESC,
        CASE WHEN sort_field = 'date' AND sort_order = 'ASC'
          THEN rco.date END,
        CASE WHEN (sort_field = 'date' AND sort_order = 'DESC') or sort_field = ''
          THEN rco.date END DESC,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'ASC'
          THEN rco.failure_description END,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'DESC'
          THEN rco.failure_description END DESC;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION sessions_actions_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
  RETURNS TABLE(
    system_user_name TEXT,
    type TEXT,
    date TIMESTAMPTZ,
    additional_information TEXT
 )
 LANGUAGE plpgsql
 STABLE
AS $FUNCTION$
  DECLARE
    json_filters JSON;
    system_user_name_filter TEXT;
    type_filter TEXT;
    date_init TIMESTAMP;
    date_finish TIMESTAMP;
    additional_information_filter TEXT;
  BEGIN
    PERFORM check_token_validity();
    json_filters := filters::JSON;

    system_user_name_filter := json_filters->'systemUserName'->>'value';
    type_filter := json_filters->'type'->>'value';
    additional_information_filter := json_filters->'additionalInformation'->>'value';

    date_init := (json_filters->'date'->'value'->>0)::TIMESTAMP;
    date_finish := (json_filters->'date'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    RETURN QUERY
      SELECT 
        CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT),
        hs.type::TEXT,
        hs.date::TIMESTAMPTZ,
        hs.reason::TEXT
      FROM historic_sessions hs
        INNER JOIN system_user sys_us ON hs.system_user_historical_id = sys_us.historical_id
          AND sys_us.is_deleted = false
      WHERE 
        CASE
          WHEN system_user_name_filter IS NOT NULL AND system_user_name_filter != '' 
            THEN LOWER(CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT)) 
              LIKE CONCAT('%',LOWER(system_user_name_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN type_filter IS NOT NULL AND type_filter != '' 
            THEN LOWER(hs.type) LIKE CONCAT('%',LOWER(type_filter),'%')
          ELSE true
        END
      AND
        CASE
          WHEN date_finish IS NOT NULL THEN 
            hs.date >= date_init AND hs.date <= date_finish
          ELSE true
        END
      AND
        CASE
          WHEN additional_information_filter IS NOT NULL AND additional_information_filter != '' 
            THEN LOWER(hs.reason) LIKE CONCAT('%',LOWER(additional_information_filter),'%')
          ELSE true
        END
      ORDER BY
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'ASC'
          THEN CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT) END,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'DESC'
          THEN CONCAT(sys_us.name::TEXT,' ',sys_us.last_name::TEXT,' ',sys_us.mothers_last_name::TEXT) END DESC,
        CASE WHEN sort_field = 'type' AND sort_order = 'ASC'
          THEN hs.type END,
        CASE WHEN sort_field = 'type' AND sort_order = 'DESC'
          THEN hs.type END DESC,
        CASE WHEN sort_field = 'date' AND sort_order = 'ASC'
          THEN hs.date END,
        CASE WHEN (sort_field = 'date' AND sort_order = 'DESC') or sort_field = ''
          THEN hs.date END DESC,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'ASC'
          THEN hs.reason END,
        CASE WHEN sort_field = 'additionalInformation' AND sort_order = 'DESC'
          THEN hs.reason END DESC;
  END;
$FUNCTION$;CREATE OR REPLACE FUNCTION get_electronic_locks_in_test()
 RETURNS TABLE (
   id_lock int, 
   status TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    failure_locks INT[];
  BEGIN
    PERFORM check_token_validity();

    failure_locks := ARRAY(
      SELECT 
				elt.id_lock
      FROM electronic_lock_tests elt 
      WHERE elt.success = false
      GROUP BY elt.id_lock
    );

    RETURN QUERY
      SELECT 
        el.id_lock,
        CASE 
          WHEN el.id_lock = ANY(failure_locks)
          THEN 'Fallido'
          ELSE 'Por iniciar'
        END as status
      FROM electronic_lock el
        LEFT JOIN electronic_lock_tests elt ON elt.id_lock = el.id_lock
      WHERE el.work_mode = 1 GROUP BY el.id_lock;
  END;
$FUNCTION$;


CREATE OR REPLACE FUNCTION get_failure_historic_lock_tests_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
 RETURNS TABLE (
    id_lock int, 
    system_user_name TEXT,
    test_date TIMESTAMP WITH TIME ZONE,
    failure_step_number INT,
    failure_details TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    failure_locks INT[];
    json_filters JSON;
    id_lock_filter TEXT;
    system_user_name_filter TEXT;
    test_date_init TIMESTAMP;
    test_date_finish TIMESTAMP;
    failure_step_number_filter TEXT;
    failure_details_filter TEXT;
  BEGIN
    PERFORM check_token_validity();

    json_filters := filters::JSON;

    id_lock_filter := json_filters->'idLock'->>'value';
    system_user_name_filter := json_filters->'systemUserName'->>'value';
    failure_step_number_filter := json_filters->'failureStepNumber'->>'value';
    failure_details_filter := json_filters->'failureDetails'->>'value';

    test_date_init := (json_filters->'testDate'->'value'->>0)::TIMESTAMP;
    test_date_finish := (json_filters->'testDate'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    failure_locks := ARRAY(
      SELECT 
				elt.id_lock
      FROM electronic_lock_tests elt 
      WHERE elt.success = false
      GROUP BY elt.id_lock
    );

    RETURN QUERY
      SELECT 
        elt.id_lock,
        CONCAT(su.name,' ',su.last_name,' ',su.mothers_last_name),
        elt.test_date::TIMESTAMPTZ,
        elts.step,
        elt.failure_details
      FROM electronic_lock_tests elt 
        INNER JOIN electronic_lock_tests_steps elts ON elts.id_electronic_lock_test = elt.id_electronic_lock_test
          AND elts.failed = true
        INNER JOIN system_user su ON su.historical_id = elt.system_user_historical_id AND is_deleted = false
      WHERE elt.id_lock = ANY(failure_locks)
        AND
          CASE
            WHEN id_lock_filter IS NOT NULL AND id_lock_filter != '' 
              THEN elt.id_lock::TEXT LIKE CONCAT('%',id_lock_filter,'%')
            ELSE true
          END
        AND
          CASE
            WHEN system_user_name_filter IS NOT NULL AND system_user_name_filter != '' 
              THEN LOWER(CONCAT(su.name,' ',su.last_name,' ',su.mothers_last_name)) LIKE CONCAT('%',LOWER(system_user_name_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN test_date_finish IS NOT NULL THEN 
              elt.test_date >= test_date_init AND elt.test_date <= test_date_finish
            ELSE true
          END
        AND
          CASE
            WHEN failure_step_number_filter IS NOT NULL AND failure_step_number_filter != '' 
              THEN elts.step = failure_step_number_filter::INT
            ELSE true
          END
        AND
          CASE
            WHEN failure_details_filter IS NOT NULL AND failure_details_filter != '' 
              THEN elt.failure_details LIKE CONCAT('%',LOWER(failure_details_filter),'%')
            ELSE true
          END
      ORDER BY
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN elt.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN elt.id_lock END DESC,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'ASC'
          THEN CONCAT(su.name,' ',su.last_name,' ',su.mothers_last_name) END,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'DESC'
          THEN CONCAT(su.name,' ',su.last_name,' ',su.mothers_last_name) END DESC,
        CASE WHEN sort_field = 'testDate' AND sort_order = 'ASC'
          THEN elt.test_date::TIMESTAMPTZ END,
        CASE WHEN (sort_field = 'testDate' AND sort_order = 'DESC') or sort_field = ''
          THEN elt.test_date::TIMESTAMPTZ END DESC,
        CASE WHEN sort_field = 'failureStepNumber' AND sort_order = 'ASC'
          THEN elts.step END,
        CASE WHEN sort_field = 'failureStepNumber' AND sort_order = 'DESC'
          THEN elts.step END DESC,
        CASE WHEN sort_field = 'failureDetails' AND sort_order = 'ASC'
          THEN elt.failure_details END,
        CASE WHEN sort_field = 'failureDetails' AND sort_order = 'DESC'
          THEN elt.failure_details END DESC;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION get_success_historic_lock_tests_report(
  filters TEXT,
  sort_field TEXT,
  sort_order TEXT
)
 RETURNS TABLE (
    id_lock int, 
    system_user_name TEXT,
    test_date TIMESTAMP WITH TIME ZONE,
    failure_count INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    success_locks_test_ids INT[];
    json_filters JSON;
    id_lock_filter TEXT;
    system_user_name_filter TEXT;
    test_date_init TIMESTAMP;
    test_date_finish TIMESTAMP;
    failure_count_filter TEXT;
    count_test_steps INT;
  BEGIN
    PERFORM check_token_validity();

    json_filters := filters::JSON;

    id_lock_filter := json_filters->'idLock'->>'value';
    system_user_name_filter := json_filters->'systemUserName'->>'value';
    failure_count_filter := json_filters->'failureCount'->>'value';

    test_date_init := (json_filters->'testDate'->'value'->>0)::TIMESTAMP;
    test_date_finish := (json_filters->'testDate'->'value'->>1)::TIMESTAMP+ INTERVAL '1 day';

    SELECT current_setting('glob_variables.count_test_steps', true)::INT INTO count_test_steps;

    success_locks_test_ids := ARRAY(SELECT 
        elt.id_electronic_lock_test
      FROM electronic_lock_tests elt 
      WHERE elt.success = true
      GROUP BY elt.id_electronic_lock_test
    );

    RETURN QUERY
      SELECT 
        elt.id_lock,
        CONCAT(su.name,' ',su.last_name,' ',su.mothers_last_name),
        elt.test_date::TIMESTAMPTZ,
        lock_count.failure_count::INT
      FROM electronic_lock_tests elt 	
        INNER JOIN system_user su ON su.historical_id = elt.system_user_historical_id AND is_deleted = false
        INNER JOIN (SELECT elt2.id_lock,COUNT(elt2.id_lock)-1 as failure_count FROM electronic_lock_tests elt2 GROUP BY elt2.id_lock) lock_count ON lock_count.id_lock = elt.id_lock
      WHERE elt.id_electronic_lock_test = ANY(success_locks_test_ids)
        AND
          CASE
            WHEN id_lock_filter IS NOT NULL AND id_lock_filter != '' 
              THEN elt.id_lock::TEXT LIKE CONCAT('%',id_lock_filter,'%')
            ELSE true
          END
        AND
          CASE
            WHEN system_user_name_filter IS NOT NULL AND system_user_name_filter != '' 
              THEN LOWER(CONCAT(su.name,' ',su.last_name,' ',su.mothers_last_name)) LIKE CONCAT('%',LOWER(system_user_name_filter),'%')
            ELSE true
          END
        AND
          CASE
            WHEN test_date_finish IS NOT NULL THEN 
              elt.test_date >= test_date_init AND elt.test_date <= test_date_finish
            ELSE true
          END
        AND
          CASE
            WHEN failure_count_filter IS NOT NULL AND failure_count_filter != '' 
              THEN lock_count.failure_count = failure_count_filter::INT
            ELSE true
          END
      ORDER BY
        CASE WHEN sort_field = 'idLock' AND sort_order = 'ASC'
          THEN elt.id_lock END,
        CASE WHEN sort_field = 'idLock' AND sort_order = 'DESC'
          THEN elt.id_lock END DESC,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'ASC'
          THEN CONCAT(su.name,' ',su.last_name,' ',su.mothers_last_name) END,
        CASE WHEN sort_field = 'systemUserName' AND sort_order = 'DESC'
          THEN CONCAT(su.name,' ',su.last_name,' ',su.mothers_last_name) END DESC,
        CASE WHEN sort_field = 'testDate' AND sort_order = 'ASC'
          THEN elt.test_date::TIMESTAMPTZ END,
        CASE WHEN (sort_field = 'testDate' AND sort_order = 'DESC') or sort_field = ''
          THEN elt.test_date::TIMESTAMPTZ END DESC,
        CASE WHEN sort_field = 'failureCount' AND sort_order = 'ASC'
          THEN lock_count.failure_count END,
        CASE WHEN sort_field = 'failureCount' AND sort_order = 'DESC'
          THEN lock_count.failure_count END DESC;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION insert_new_keyboard_test_command(
  IN id_lock INT,
  IN random_string TEXT,
  OUT id_command INT,
  OUT date_created TIMESTAMPTZ,
  OUT command_minutes_running_time INT
)
LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    command_limit_minutes INT;
    minutes_duration INT;
    jwt_historical_id text;
    duration_time INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    SELECT current_setting('glob_variables.command_limit_minutes', true)::INT INTO command_limit_minutes;
    SELECT current_setting('glob_variables.test_steps_limit_minutes', true)::INT * 60 INTO duration_time;

    insert_new_keyboard_test_command.command_minutes_running_time := command_limit_minutes * 60;
    
    INSERT INTO commands (
      id_lock,
      cmd,
      expiration,
      duration,
      temp_code
    ) VALUES (
      insert_new_keyboard_test_command.id_lock,
      8,
      insert_new_keyboard_test_command.command_minutes_running_time,
      duration_time,
      random_string
    ) RETURNING 
        commands.id_command,
        commands.date_created
      INTO 
        insert_new_keyboard_test_command.id_command,
        insert_new_keyboard_test_command.date_created;

    UPDATE electronic_lock el SET
      status = 0
    WHERE el.id_lock = insert_new_keyboard_test_command.id_lock;
    RETURN;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION insert_new_test(
  IN id_lock INT,
  OUT new_id_lock_test INT
)
LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    command_limit_minutes INT;
    minutes_duration INT;
    jwt_historical_id text;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
      
    INSERT INTO electronic_lock_tests
      (id_lock,system_user_historical_id)
    VALUES 
      (insert_new_test.id_lock,jwt_historical_id)
    RETURNING 
      electronic_lock_tests.id_electronic_lock_test
    INTO 
      new_id_lock_test;
    RETURN;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION insert_new_test_step(
  IN id_electronic_lock_test INT,
  IN step INT,
  OUT new_id_electronic_lock_test_step INT,
  OUT test_step_date TIMESTAMPTZ,
  OUT step_limit_time INT
)
LANGUAGE plpgsql
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('glob_variables.test_steps_limit_minutes', true)::INT * 60 
      INTO insert_new_test_step.step_limit_time;
    
    INSERT INTO electronic_lock_tests_steps
      (id_electronic_lock_test,step)
    VALUES
      (id_electronic_lock_test,step)
    RETURNING 
      electronic_lock_tests_steps.id_electronic_lock_test_step,
      electronic_lock_tests_steps.test_step_date 
    INTO 
      new_id_electronic_lock_test_step,
      insert_new_test_step.test_step_date;
    RETURN;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION check_test_situation(
  IN id_lock INT,
  IN step_looking_for INT,
  OUT can_proceed BOOLEAN
)
LANGUAGE plpgsql
STABLE
AS 
$FUNCTION$
  DECLARE
    lock INT;
  BEGIN
    PERFORM check_token_validity();
	can_proceed := false;
    SELECT el.id_lock INTO lock FROM electronic_lock el
      where el.id_lock = check_test_situation.id_lock AND el.status = check_test_situation.step_looking_for;

    IF(lock IS NOT NULL) THEN
      check_test_situation.can_proceed = true;
    END IF;
    RETURN;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION cancel_keyboard_test_commands()
  RETURNS void
 LANGUAGE plpgsql
 AS 
$function$
  DECLARE
    rec RECORD;
    command_limit_time INTERVAL;
  BEGIN
    FOR rec IN (SELECT c.date_created,c.id_command,c.expiration FROM commands c 
      INNER JOIN electronic_lock el ON el.id_lock = c.id_lock
      WHERE c.date_canceled IS NULL AND c.date_apply IS NULL AND c.cmd = 8)
    LOOP
      IF(rec.date_created + (rec.expiration/60) * INTERVAL'1 minute' < CURRENT_TIMESTAMP) THEN
        UPDATE commands c SET
          date_canceled = CURRENT_TIMESTAMP,
          canceled_description = 'Se agotó el tiempo límite'
        WHERE 
          c.id_command = rec.id_command;
      END IF;
    END LOOP;
    RETURN;
  END;
$function$;

CREATE OR REPLACE FUNCTION cancel_open_test_steps()
  RETURNS void
 LANGUAGE plpgsql
 AS 
$function$
  DECLARE
    rec RECORD;
    command_limit_time INTERVAL;
    last_lock_test_step_ids INT[];
    test_steps_limit_minutes INT;
  BEGIN
    SELECT current_setting('glob_variables.test_steps_limit_minutes', true)::INT INTO test_steps_limit_minutes;
    last_lock_test_step_ids := ARRAY(SELECT MAX(elts.id_electronic_lock_test_step)
      FROM electronic_lock_tests_steps elts
        INNER JOIN electronic_lock_tests elt ON elt.id_electronic_lock_test = elts.id_electronic_lock_test
        INNER JOIN electronic_lock el ON el.id_lock = elt.id_lock
      WHERE elt.success IS NULL AND
        NOT (elts.id_electronic_lock_test = ANY(SELECT 
            elt.id_electronic_lock_test
          FROM electronic_lock_tests elt 
            INNER JOIN electronic_lock_tests_steps elts ON 
              elts.id_electronic_lock_test = elt.id_electronic_lock_test AND elts.failed = true
          GROUP BY elt.id_electronic_lock_test))
      GROUP BY elts.id_electronic_lock_test);

    FOR rec IN (SELECT elts.id_electronic_lock_test_step,elts.test_step_date,elt.id_electronic_lock_test
      FROM electronic_lock_tests_steps elts
        INNER JOIN electronic_lock_tests elt ON elt.id_electronic_lock_test = elts.id_electronic_lock_test
        INNER JOIN electronic_lock el ON el.id_lock = elt.id_lock
        WHERE elts.id_electronic_lock_test_step = ANY(last_lock_test_step_ids)
        ORDER BY elts.test_step_date)
    LOOP
      IF(rec.test_step_date + (test_steps_limit_minutes) * INTERVAL'1 minute' < CURRENT_TIMESTAMP) THEN
        UPDATE electronic_lock_tests_steps elts SET
          failed = true
        WHERE 
          elts.id_electronic_lock_test_step = rec.id_electronic_lock_test_step;

        UPDATE electronic_lock_tests elt SET
          success = false
        WHERE 
          elt.id_electronic_lock_test = rec.id_electronic_lock_test;
      END IF;
    END LOOP;
    RETURN;
  END;
$function$;

CREATE OR REPLACE FUNCTION get_current_test(
  IN id_lock INT,
  OUT id_electronic_lock_test INT,
  OUT step INT,
  OUT test_step_date INT
)
LANGUAGE plpgsql
STABLE
AS 
$FUNCTION$
  DECLARE
    lock INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT elt.id_electronic_lock_test INTO get_current_test.id_electronic_lock_test
      FROM electronic_lock_tests_steps elts
        INNER JOIN electronic_lock_tests elt ON elt.id_electronic_lock_test = elts.id_electronic_lock_test
        INNER JOIN electronic_lock el ON el.id_lock = elt.id_lock
      WHERE el.work_mode = 1 AND el.id_lock = get_current_test.id_lock AND
        NOT (elts.id_electronic_lock_test = ANY(SELECT 
            elt.id_electronic_lock_test
          FROM electronic_lock_tests elt 
            INNER JOIN electronic_lock_tests_steps elts ON 
              elts.id_electronic_lock_test = elt.id_electronic_lock_test AND elts.failed = true
          GROUP BY elt.id_electronic_lock_test))
      GROUP BY elt.id_electronic_lock_test;
    
    IF(get_current_test.id_electronic_lock_test IS NOT NULL) THEN
      SELECT 
        elts.step, 
        elts.test_step_date
        INTO
        get_current_test.step,
        get_current_test.test_step_date
      FROM electronic_lock_tests_steps elts 
        WHERE elts.id_electronic_lock_test = get_current_test.id_electronic_lock_test 
      ORDER BY id_electronic_lock_test_step DESC
      LIMIT 1;
    END IF;
    RETURN;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION advance_electronic_lock_status(
  IN id_lock INT
)
RETURNS VOID
LANGUAGE plpgsql
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    UPDATE electronic_lock el SET
      status = status + 1
    WHERE el.id_lock = advance_electronic_lock_status.id_lock;
    RETURN;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION set_lock_test_failure_details(
  IN id_electronic_lock_test INT,
  IN failure_details TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    UPDATE electronic_lock_tests elt SET
      failure_details = set_lock_test_failure_details.failure_details
    WHERE elt.id_electronic_lock_test = set_lock_test_failure_details.id_electronic_lock_test;
    RETURN;
  END;
$FUNCTION$;--- authenticate AND get jwt
CREATE OR REPLACE FUNCTION get_jwt_token(email text, encrypted_password text)
 RETURNS jwt_token
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
AS $FUNCTION$
  DECLARE
    key bytea;
    cypher text;
    pwd text;
    account system_user;
    user_role roles;
    existing_token auth_tokens;
    affected_rows auth_tokens;
    valid_token TEXT;
    valid_active_minutes_of_session INTERVAL;
  BEGIN
    SELECT current_setting('glob_variables.valid_active_minutes_of_session', true)::INT * INTERVAL'1 minute' 
      INTO valid_active_minutes_of_session;

    SELECT a.* INTO account
      FROM system_user AS a
      WHERE a.email = get_jwt_token.email AND is_deleted = false ORDER BY id_system_user DESC LIMIT 1;
      
    SELECT rol.* INTO user_role
      FROM roles AS rol
      WHERE rol.id_role = account.id_role;

    SELECT auth_tok.* INTO existing_token
      FROM auth_tokens AS auth_tok
      WHERE auth_tok.system_user_historical_id = account.historical_id 
        AND auth_tok.date_created + valid_active_minutes_of_session > CURRENT_TIMESTAMP LIMIT 1;

    if existing_token IS NOT NULL THEN
      RAISE EXCEPTION SQLSTATE '90002' USING 
        MESSAGE = FORMAT('sesionExistente');
    ELSE
      DELETE FROM auth_tokens WHERE auth_tokens.system_user_historical_id = account.historical_id;
      SELECT auth_tok.* INTO affected_rows
      FROM auth_tokens AS auth_tok
        WHERE auth_tok.system_user_historical_id = account.historical_id LIMIT 1;
      IF(affected_rows IS NOT NULL) THEN
        INSERT INTO historic_sessions (
          system_user_historical_id,
          type,
          reason
        ) VALUES (
          account.historical_id,
          'Cierre de sesión',
          'Inactividad'
        );
      END IF;
    END IF;

    IF account.password = get_jwt_token.encrypted_password AND account.enabled = true THEN
      INSERT INTO auth_tokens (
        system_user_historical_id
      ) VALUES (
        account.historical_id
      ) RETURNING auth_tokens.valid_token::TEXT INTO valid_token;

      INSERT INTO historic_sessions (
        system_user_historical_id,
        type
      ) VALUES (
        account.historical_id,
        'Inicio de sesión'
      );

      RETURN (
        account.nickname,
        CONCAT(account.name,' ',account.last_name,' ',account.mothers_last_name),
        extract(epoch FROM now() + interval '1 days'),
        account.email,
        user_role.name,
        account.historical_id,
        valid_token
      )::jwt_token;
    ELSE 
      RETURN null;
    END IF;
  END;
$FUNCTION$;

--- logout
CREATE OR REPLACE FUNCTION logout(historical_id TEXT,valid_token TEXT,reason TEXT)
 RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
AS $FUNCTION$
  DECLARE 
    affected_rows auth_tokens;
  BEGIN

    DELETE FROM auth_tokens WHERE 
      auth_tokens.system_user_historical_id = logout.historical_id AND
      auth_tokens.valid_token = logout.valid_token 
    RETURNING * INTO affected_rows;

    if(COUNT(affected_rows) > 0) THEN
      INSERT INTO historic_sessions (
        system_user_historical_id,
        type,
        reason
      ) VALUES (
        historical_id,
        'Cierre de sesión',
        reason
      );
    END IF;
  END;
$FUNCTION$;

-- check token validity
CREATE OR REPLACE FUNCTION check_token_validity()
 RETURNS VOID
 LANGUAGE plpgsql
 STABLE
AS $FUNCTION$
  DECLARE 
    jwt_historical_id TEXT;
    jwt_valid_token TEXT;
    existing_token auth_tokens;
    valid_active_minutes_of_session INTERVAL;
  BEGIN
    SELECT current_setting('glob_variables.valid_active_minutes_of_session', true)::INT * INTERVAL'1 minute' 
      INTO valid_active_minutes_of_session;
    SELECT 
      current_setting('jwt.claims.historical_id'),
      current_setting('jwt.claims.valid_token') 
    INTO 
      jwt_historical_id,
      jwt_valid_token;

    SELECT auth_tok.* INTO existing_token
      FROM auth_tokens AS auth_tok
      WHERE auth_tok.system_user_historical_id = jwt_historical_id 
        AND auth_tok.valid_token = jwt_valid_token
        AND auth_tok.date_created + valid_active_minutes_of_session > CURRENT_TIMESTAMP LIMIT 1;
    IF existing_token IS NULL THEN
      RAISE EXCEPTION SQLSTATE '90003' USING 
        MESSAGE = FORMAT('tokenNoExistente');
    END IF;
  END;
$FUNCTION$;

-- check token validity
CREATE OR REPLACE FUNCTION update_auth_token()
 RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
AS $FUNCTION$
  DECLARE 
    jwt_historical_id TEXT;
    jwt_valid_token TEXT;
    existing_token auth_tokens;
  BEGIN
    PERFORM check_token_validity();
    SELECT 
      current_setting('jwt.claims.historical_id'),
      current_setting('jwt.claims.valid_token') 
    INTO 
      jwt_historical_id,
      jwt_valid_token;
    UPDATE auth_tokens auth_tok SET
      date_created = CURRENT_TIMESTAMP
    WHERE auth_tok.system_user_historical_id = jwt_historical_id 
      AND auth_tok.valid_token = jwt_valid_token;
  END;
$FUNCTION$;


--- assign service user to groups
CREATE OR REPLACE FUNCTION assign_group_service_user(group_historical_id text,historical_ids TEXT[])
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    new_id_service_user INT;
    next_historical_id TEXT;
    service_user_able_to_change service_user;
    count_group_relation INT;
    selected_id_group INT;
    last_ids INT[];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    
    FOR i IN 1 .. array_upper(assign_group_service_user.historical_ids,1)
    LOOP
      next_historical_id := assign_group_service_user.historical_ids[i];
      SELECT * INTO service_user_able_to_change
      FROM service_user AS su 
        LEFT JOIN groups_service_user gsu ON gsu.id_service_user = su.id_service_user
        LEFT JOIN groups g on g.id_group = gsu.id_group
      WHERE su.historical_id = next_historical_id AND su.is_deleted = false
        AND ((g.id_group IS NOT NULL AND g.historical_id != group_historical_id)OR g.id_group IS NULL);
      if(service_user_able_to_change.id_service_user IS NOT NULL) THEN
        INSERT INTO service_user(
          address_street,
          address_street_number,
          address_suite_number,
          address_suburb,
          address_county,
          address_city,
          address_state,
          address_zip_code,
          email, 
          name, 
          last_name, 
          mothers_last_name, 
          nickname, 
          phone, 
          historical_action, 
          historical_action_user_id, 
          historical_id,
          nip,
          enabled,
          date_updated
        )SELECT 
          su.address_street,
          su.address_street_number,
          su.address_suite_number,
          su.address_suburb,
          su.address_county,
          su.address_city,
          su.address_state, 
          su.address_zip_code,
          su.email, 
          su.name, 
          su.last_name, 
          su.mothers_last_name, 
          su.nickname, 
          su.phone, 
          'ASIGNACIÓN', 
          jwt_historical_id, 
          su.historical_id, 
          su.nip, 
          su.enabled,
          CURRENT_TIMESTAMP
        FROM service_user AS su WHERE su.historical_id = next_historical_id AND su.is_deleted = false;

        SELECT currval('service_user_id_service_user_seq') INTO new_id_service_user;

        SELECT count(gu.*) INTO count_group_relation 
          FROM groups_service_user gu 
            INNER JOIN service_user su ON su.id_service_user = gu.id_service_user
          WHERE su.historical_id = next_historical_id AND su.is_deleted = false AND gu.is_deleted = false;

        SELECT g.id_group INTO selected_id_group 
          FROM groups g WHERE g.historical_id = group_historical_id AND g.is_deleted = false;

        IF(assign_group_service_user.group_historical_id != '' AND count_group_relation >= 1) THEN
          INSERT INTO groups_service_user(
            id_group,
            id_service_user,
            historical_id,
            historical_action_user_id,
            historical_action,
            date_updated
          )SELECT
            selected_id_group,
            new_id_service_user,
            gu.historical_id,
            jwt_historical_id,
            'ASIGNACIÓN',
            CURRENT_TIMESTAMP
          FROM groups_service_user gu 
            INNER JOIN service_user su ON su.id_service_user = gu.id_service_user
          WHERE su.historical_id = next_historical_id AND su.is_deleted = false AND gu.is_deleted = false;
        ELSIF(assign_group_service_user.group_historical_id != '') THEN
          INSERT INTO groups_service_user (
            id_group,
            id_service_user,
            historical_action_user_id
          )
          VALUES( 
            selected_id_group, 
            new_id_service_user,
            jwt_historical_id
          );
        END IF;

        INSERT INTO service_user_responses(
          id_question,
          id_service_user,
          response
        )SELECT
          r.id_question,
          new_id_service_user,
          r.response
        FROM service_user_responses r 
          INNER JOIN service_user su ON su.id_service_user = r.id_service_user
        WHERE su.historical_id = next_historical_id AND su.is_deleted = false;
      END IF;
    END LOOP;

    last_ids := ARRAY(SELECT MAX(su.id_service_user) FROM service_user su GROUP BY su.historical_id);

    UPDATE groups_service_user g
      SET
        is_deleted = true
      FROM service_user su
      WHERE
        g.id_service_user = su.id_service_user AND g.is_deleted = false
        AND su.historical_id = ANY(assign_group_service_user.historical_ids) AND su.is_deleted = false
          AND NOT(su.id_service_user = ANY(last_ids));

    UPDATE service_user
      SET
        is_deleted = true
      WHERE
        historical_id = ANY(assign_group_service_user.historical_ids) AND is_deleted = false
          AND NOT(id_service_user = ANY(last_ids));
  END;
$FUNCTION$;


--- disable service users
CREATE OR REPLACE FUNCTION disable_service_user(historical_ids TEXT[], disabled_reason TEXT)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    new_id_service_user INT;
    next_historical_id TEXT;
    last_ids INT[];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    
    FOR i IN 1 .. array_upper(disable_service_user.historical_ids,1)
    LOOP
      next_historical_id := disable_service_user.historical_ids[i];
      INSERT INTO service_user(
        address_street,
        address_street_number,
        address_suite_number,
        address_suburb,
        address_county,
        address_city,
        address_state,
        address_zip_code,
        email, 
        name, 
        last_name, 
        mothers_last_name, 
        nickname, 
        phone, 
        historical_action, 
        historical_action_user_id, 
        historical_id,
        nip,
        enabled,
        deleted_reason
      )SELECT 
        su.address_street,
        su.address_street_number,
        su.address_suite_number,
        su.address_suburb,
        su.address_county,
        su.address_city,
        su.address_state, 
        su.address_zip_code,
        su.email, 
        su.name, 
        su.last_name, 
        su.mothers_last_name, 
        su.nickname, 
        su.phone, 
        'DESHABILITACIÓN', 
        jwt_historical_id, 
        su.historical_id, 
        su.nip, 
        false,
        disable_service_user.disabled_reason
      FROM service_user AS su WHERE su.historical_id = next_historical_id AND su.is_deleted = false;

      SELECT currval('service_user_id_service_user_seq') INTO new_id_service_user;

      INSERT INTO groups_service_user(
        id_group,
        id_service_user,
        historical_id,
        historical_action,
        historical_action_user_id,
        date_updated
      )SELECT
        gu.id_group,
        new_id_service_user,
        gu.historical_id,
        'DESHABILITACIÓN',
        jwt_historical_id,
        CURRENT_TIMESTAMP
      FROM groups_service_user gu 
        INNER JOIN service_user su ON su.id_service_user = gu.id_service_user
      WHERE su.historical_id = next_historical_id AND su.is_deleted = false AND gu.is_deleted = false;

      INSERT INTO service_user_responses(
        id_question,
        id_service_user,
        response
      )SELECT
        r.id_question,
        new_id_service_user,
        r.response
      FROM service_user_responses r 
        INNER JOIN service_user su ON su.id_service_user = r.id_service_user
      WHERE su.historical_id = next_historical_id AND su.is_deleted = false;
    END LOOP;

    last_ids := ARRAY(SELECT MAX(su.id_service_user) FROM service_user su GROUP BY su.historical_id);

    UPDATE groups_service_user g
      SET
        is_deleted = true
      FROM service_user su
      WHERE
        g.id_service_user = su.id_service_user AND g.is_deleted = false
        AND su.historical_id = ANY(disable_service_user.historical_ids) AND su.is_deleted = false
          AND NOT(su.id_service_user = ANY(last_ids));

    UPDATE service_user
      SET
        is_deleted = true
      WHERE
        historical_id = ANY(disable_service_user.historical_ids) AND is_deleted = false
          AND NOT(id_service_user = ANY(last_ids));
  END;
$FUNCTION$;


--- disable system users
CREATE OR REPLACE FUNCTION disable_system_user(historical_ids TEXT[], disabled_reason TEXT)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    last_ids INT[];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    INSERT INTO system_user(
      address_street,
      address_street_number,
      address_suite_number,
      address_suburb,
      address_county,
      address_city,
      address_state,
      address_zip_code,
      email, 
      name, 
      last_name,
      mothers_last_name,
      nickname, 
      phone, 
      historical_action, 
      historical_action_user_id, 
      historical_id,
      password,
      enabled,
      id_role,
      date_deleted,
      deleted_reason
    )SELECT 
      su.address_street,
      su.address_street_number,
      su.address_suite_number,
      su.address_suburb,
      su.address_county,
      su.address_city,
      su.address_state, 
      su.address_zip_code,
      su.email, 
      su.name, 
      su.last_name, 
      su.mothers_last_name, 
      su.nickname, 
      su.phone, 
      'DESHABILITACIÓN', 
      jwt_historical_id, 
      su.historical_id, 
      su.password, 
      false, 
      su.id_role,
      CURRENT_TIMESTAMP,
      disable_system_user.disabled_reason
    FROM system_user AS su WHERE su.historical_id = ANY(disable_system_user.historical_ids)
      AND su.is_deleted = false;

    last_ids := ARRAY(SELECT MAX(su.id_system_user) FROM system_user su GROUP BY su.historical_id);

    UPDATE system_user
      SET
          is_deleted = true
      WHERE
          historical_id = ANY(disable_system_user.historical_ids) AND is_deleted = false
            AND NOT (id_system_user = ANY(last_ids));
  END;
$FUNCTION$;


--- disable groups
CREATE OR REPLACE FUNCTION disable_group(
  IN historical_ids TEXT[],
  OUT errors_count INT
)
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id TEXT;
    next_historical_id TEXT;
    new_id_group INT;
    last_ids INT[];
    count_users INT;
    count_terminals INT;
    removed_ids TEXT[];
    result_ids TEXT[];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    errors_count := 0;

    FOR i IN 1 .. array_upper(disable_group.historical_ids,1)
    LOOP
      next_historical_id := disable_group.historical_ids[i];
      SELECT count(su.id_service_user)::int into count_users 
        FROM groups AS g
        INNER JOIN groups_service_user AS gu ON g.id_group = gu.id_group AND gu.is_deleted = false
        INNER JOIN service_user AS su ON su.id_service_user = gu.id_service_user
          AND su.is_deleted = false
        WHERE g.historical_id = next_historical_id AND g.is_deleted = false;

      SELECT count(t.id_terminal)::int into count_terminals 
        FROM groups AS g
        INNER JOIN group_terminal AS gt ON g.id_group = gt.id_group AND gt.is_deleted = false
        INNER JOIN terminal AS t ON t.id_terminal = gt.id_terminal
          AND t.is_deleted = false
        WHERE g.historical_id = next_historical_id AND g.is_deleted = false;

      if ( count_users = 0 AND count_terminals = 0) THEN
        INSERT INTO groups (
          name,
          description,
          enabled,
          historical_id,
          historical_action,
          historical_action_user_id
        )SELECT
          g.name,
          g.description,
          false,
          g.historical_id,
          'DESHABILITACIÓN',
          jwt_historical_id
        FROM groups g WHERE g.historical_id = next_historical_id AND g.is_deleted = false
          RETURNING groups.id_group INTO new_id_group;

        INSERT INTO groups_service_user(
          id_group,
          id_service_user,
          historical_id,
          historical_action,
          historical_action_user_id,
          date_updated
        )SELECT
          new_id_group,
          gu.id_service_user,
          gu.historical_id,
          'DESHABILITACIÓN',
          jwt_historical_id,
          CURRENT_TIMESTAMP
        FROM groups_service_user gu 
          INNER JOIN groups g ON g.id_group = gu.id_group
        WHERE g.historical_id = next_historical_id AND g.is_deleted = false AND gu.is_deleted = false;

        INSERT INTO group_terminal(
          id_group,
          id_terminal,
          historical_id,
          historical_action,
          historical_action_user_id,
          date_updated
        )SELECT
          new_id_group,
          gt.id_terminal,
          gt.historical_id,
          'DESHABILITACIÓN',
          jwt_historical_id,
          CURRENT_TIMESTAMP
        FROM group_terminal gt 
          INNER JOIN groups g ON g.id_group = gt.id_group
        WHERE g.historical_id = next_historical_id AND g.is_deleted = false AND gt.is_deleted = false;
      ELSE
        errors_count := errors_count + 1;
        removed_ids := array_append(removed_ids,next_historical_id);
      END IF;
    END LOOP;


    IF(array_length(historical_ids,1) > errors_count) THEN
      result_ids = ARRAY(SELECT array(SELECT unnest(historical_ids) EXCEPT SELECT unnest(removed_ids)));
      last_ids := ARRAY(SELECT MAX(id_group) FROM groups g 
        WHERE g.historical_id::TEXT = ANY(result_ids)
        GROUP BY g.historical_id);

      UPDATE groups_service_user gu SET
        is_deleted = true
        FROM groups g
        WHERE
          g.id_group = gu.id_group
          AND g.historical_id = ANY (result_ids) AND NOT(g.id_group = ANY(last_ids)) 
          AND g.is_deleted = false AND gu.is_deleted = false;
        
      UPDATE group_terminal gt SET
        is_deleted = true
        FROM groups g
        WHERE
          g.id_group = gt.id_group
          AND g.historical_id = ANY (result_ids) AND NOT(g.id_group = ANY(last_ids)) 
          AND g.is_deleted = false AND gt.is_deleted = false;

      UPDATE groups g SET
        is_deleted = true
        WHERE
          g.historical_id = ANY (result_ids) AND NOT(g.id_group = ANY(last_ids)) AND g.is_deleted = false;
    END IF;
    RETURN;
  END;
$FUNCTION$;


--- enable service users
CREATE OR REPLACE FUNCTION enable_service_user(historical_ids TEXT[])
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    next_historical_id TEXT;
    new_id_service_user INT;
    last_ids INT[];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    
    FOR i IN 1 .. array_upper(enable_service_user.historical_ids,1)
    LOOP
      next_historical_id := enable_service_user.historical_ids[i];
      INSERT INTO service_user(
        address_street,
        address_street_number,
        address_suite_number,
        address_suburb,
        address_county,
        address_city,
        address_state,
        address_zip_code,
        email, 
        name, 
        last_name, 
        mothers_last_name, 
        nickname, 
        phone, 
        historical_action, 
        historical_action_user_id, 
        historical_id,
        nip,
        enabled
      )SELECT 
        su.address_street,
        su.address_street_number,
        su.address_suite_number,
        su.address_suburb,
        su.address_county,
        su.address_city,
        su.address_state, 
        su.address_zip_code,
        su.email, 
        su.name, 
        su.last_name, 
        su.mothers_last_name, 
        su.nickname, 
        su.phone, 
        'HABILITACIÓN', 
        jwt_historical_id, 
        su.historical_id, 
        su.nip, 
        true
      FROM service_user AS su WHERE su.historical_id = next_historical_id AND su.is_deleted = false;

      SELECT currval('service_user_id_service_user_seq') INTO new_id_service_user;

      INSERT INTO groups_service_user(
        id_group,
        id_service_user,
        historical_id,
        historical_action,
        historical_action_user_id,
        date_updated
      )SELECT
        gu.id_group,
        new_id_service_user,
        gu.historical_id,
        'HABILITACIÓN',
        jwt_historical_id,
        CURRENT_TIMESTAMP
      FROM groups_service_user gu 
        INNER JOIN service_user su ON su.id_service_user = gu.id_service_user
      WHERE su.historical_id = next_historical_id AND su.is_deleted = false AND gu.is_deleted = false;

      INSERT INTO service_user_responses(
        id_question,
        id_service_user,
        response
      )SELECT
        r.id_question,
        new_id_service_user,
        r.response
      FROM service_user_responses r 
        INNER JOIN service_user su ON su.id_service_user = r.id_service_user
      WHERE su.historical_id = next_historical_id AND su.is_deleted = false;
    END LOOP;

    last_ids := ARRAY(SELECT MAX(su.id_service_user) FROM service_user su GROUP BY su.historical_id);

    UPDATE groups_service_user g
      SET
        is_deleted = true
      FROM service_user su
      WHERE
        g.id_service_user = su.id_service_user AND g.is_deleted = false
        AND su.historical_id = ANY(enable_service_user.historical_ids) AND su.is_deleted = false
          AND NOT(su.id_service_user = ANY(last_ids)) ;

    UPDATE service_user
      SET
        is_deleted = true
      WHERE
        historical_id = ANY(enable_service_user.historical_ids) AND is_deleted = false
          AND NOT(id_service_user = ANY(last_ids));
  END;
$FUNCTION$;


--- enable system users
CREATE OR REPLACE FUNCTION enable_system_user(historical_ids TEXT[])
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    last_ids INT[];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    INSERT INTO system_user(
      address_street,
      address_street_number,
      address_suite_number,
      address_suburb,
      address_county,
      address_city,
      address_state,
      address_zip_code,
      email, 
      name, 
      last_name, 
      mothers_last_name, 
      nickname, 
      phone, 
      historical_action, 
      historical_action_user_id, 
      historical_id,
      password,
      enabled,
      id_role
    )SELECT 
      su.address_street,
      su.address_street_number,
      su.address_suite_number,
      su.address_suburb,
      su.address_county,
      su.address_city,
      su.address_state, 
      su.address_zip_code,
      su.email, 
      su.name, 
      su.last_name, 
      su.mothers_last_name, 
      su.nickname, 
      su.phone, 
      'HABILITACIÓN', 
      jwt_historical_id, 
      su.historical_id, 
      su.password, 
      true, 
      su.id_role
    FROM system_user AS su WHERE su.historical_id = ANY(enable_system_user.historical_ids)
      AND su.is_deleted = false;

    last_ids := ARRAY(SELECT MAX(su.id_system_user) FROM system_user su GROUP BY su.historical_id);

    UPDATE system_user
      SET
        is_deleted = true
      WHERE
        historical_id = ANY(enable_system_user.historical_ids) AND is_deleted = false
          AND NOT(id_system_user = ANY(last_ids));
  END;
$FUNCTION$;


--- enable groups
CREATE OR REPLACE FUNCTION enable_group(historical_ids TEXT[])
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id TEXT;
    next_historical_id TEXT;
    new_id_group INT;
    last_ids INT[];
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    FOR i IN 1 .. array_upper(enable_group.historical_ids,1)
    LOOP
      next_historical_id := enable_group.historical_ids[i];
      INSERT INTO groups (
        name,
        description,
        enabled,
        historical_id,
        historical_action,
        historical_action_user_id
      )SELECT
        g.name,
        g.description,
        true,
        g.historical_id,
        'HABILITACIÓN',
        jwt_historical_id
      FROM groups g WHERE g.historical_id = next_historical_id AND g.is_deleted = false;

      SELECT currval('groups_id_group_seq') INTO new_id_group;

      INSERT INTO groups_service_user(
        id_group,
        id_service_user,
        historical_id,
        historical_action,
        historical_action_user_id,
        date_updated
      )SELECT
        new_id_group,
        gu.id_service_user,
        gu.historical_id,
        'HABILITACIÓN',
        jwt_historical_id,
        CURRENT_TIMESTAMP
      FROM groups_service_user gu 
        INNER JOIN groups g ON g.id_group = gu.id_group
      WHERE g.historical_id = next_historical_id AND gu.is_deleted = false AND g.is_deleted = false;

      INSERT INTO group_terminal(
        id_group,
        id_terminal,
        historical_id,
        historical_action,
        historical_action_user_id,
        date_updated
      )SELECT
        new_id_group,
        gt.id_terminal,
        gt.historical_id,
        'HABILITACIÓN',
        jwt_historical_id,
        CURRENT_TIMESTAMP
      FROM group_terminal gt 
        INNER JOIN groups g ON g.id_group = gt.id_group
      WHERE g.historical_id = next_historical_id AND gt.is_deleted = false AND g.is_deleted = false;
    END LOOP;

    last_ids := ARRAY(SELECT MAX(g.id_group) FROM groups g 
      WHERE g.historical_id = ANY(historical_ids) GROUP BY g.historical_id);

    UPDATE groups_service_user gu SET
      is_deleted = true
      FROM groups g
      WHERE
        g.id_group = gu.id_group
        AND g.historical_id = ANY (historical_ids) AND NOT(g.id_group = ANY(last_ids)) 
        AND g.is_deleted = false AND gu.is_deleted = false;
      
    UPDATE group_terminal gt SET
      is_deleted = true
      FROM groups g
      WHERE
        g.id_group = gt.id_group
        AND g.historical_id = ANY (historical_ids) AND NOT(g.id_group = ANY(last_ids)) 
        AND g.is_deleted = false AND gt.is_deleted = false;

    UPDATE groups g SET
      is_deleted = true
      WHERE
        g.historical_id = ANY (historical_ids) AND NOT(g.id_group = ANY(last_ids)) AND g.is_deleted = false;

  END;
$FUNCTION$;


--- get all groups
CREATE OR REPLACE FUNCTION get_all_groups()
 RETURNS TABLE (id_group int, group_historical_id TEXT,name text,description text,enabled boolean)
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT 
        g.id_group::int,
        g.historical_id::TEXT,
        g.name::text,
        g.description::text,
        g.enabled 
      FROM groups AS g
      WHERE g.is_deleted = false
      GROUP BY g.id_group ORDER BY g.name;
  END;
$FUNCTION$;


--- get all groups with certain status
CREATE OR REPLACE FUNCTION get_all_groups_with_status(enabled_groups boolean)
 RETURNS TABLE (
   id_group int,
   group_historical_id TEXT,
   name text,
   description text,
   count_users int,
   count_terminals INT,
   enabled boolean
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    rec record;
  BEGIN
    PERFORM check_token_validity();
    FOR rec IN (SELECT 
        g.id_group::int,
        g.historical_id::TEXT,
        g.name::text,
        g.description::text,
        g.enabled 
      FROM groups AS g
      WHERE g.is_deleted = false AND g.enabled = get_all_groups_with_status.enabled_groups
      GROUP BY g.id_group ORDER BY g.name)
    LOOP
      SELECT count(su.id_service_user)::int into count_users 
        FROM groups AS g
        INNER JOIN groups_service_user AS gu ON g.id_group = gu.id_group AND gu.is_deleted = false
        INNER JOIN service_user AS su ON su.id_service_user = gu.id_service_user
          AND su.is_deleted = false
        WHERE g.id_group = rec.id_group;

      SELECT count(t.id_terminal)::int into count_terminals 
        FROM groups AS g
        INNER JOIN group_terminal AS gt ON g.id_group = gt.id_group AND gt.is_deleted = false
        INNER JOIN terminal AS t ON t.id_terminal = gt.id_terminal
          AND t.is_deleted = false
        WHERE g.id_group = rec.id_group;
      
      id_group := rec.id_group;
      group_historical_id := rec.historical_id;
      name := rec.name;
      description := rec.description;
      enabled := rec.enabled;
      RETURN NEXT;
    END LOOP;
  END;
$FUNCTION$;


--- get group by id
CREATE OR REPLACE FUNCTION get_group_by_historical_id(
  IN group_historical_id TEXT,
  OUT name TEXT,
  OUT description TEXT,
  OUT enabled BOOLEAN
)
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    SELECT g.name::TEXT, g.description::TEXT,g.enabled INTO name,description,enabled
      FROM groups g WHERE g.historical_id = group_historical_id AND g.is_deleted = false;
  END;
$FUNCTION$;


--- get all roles
CREATE OR REPLACE FUNCTION get_all_roles()
 RETURNS SETOF roles
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY 
      SELECT * FROM roles ORDER BY large_name;
  END;
$FUNCTION$;


--- get all service users
CREATE OR REPLACE FUNCTION get_all_service_users(enabled boolean)
 RETURNS TABLE (
   id_service_user INT, 
   service_user_historical_id TEXT, 
   complete_name TEXT, 
   nickname TEXT, 
   email TEXT, 
   phone TEXT, 
   group_name TEXT,
   id_group INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT s.id_service_user::INT,
        s.historical_id::TEXT,
        CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT),
        s.nickname::TEXT,
        s.email::TEXT,
        s.phone::TEXT,
        g.name::TEXT,
        g.id_group::INT
      FROM service_user s 
        LEFT OUTER JOIN groups_service_user gu ON gu.id_service_user = s.id_service_user 
          AND gu.is_deleted = false
        LEFT OUTER JOIN groups g ON g.id_group = gu.id_group AND g.is_deleted = false
      WHERE s.enabled = get_all_service_users.enabled AND s.is_deleted = false
        ORDER BY s.name;
      
  END;
$FUNCTION$;

--- get all service users
CREATE OR REPLACE FUNCTION get_blocked_service_users(timezone TEXT)
 RETURNS TABLE (
   id_service_user INT, 
   service_user_historical_id TEXT, 
   complete_name TEXT, 
   nickname TEXT, 
   email TEXT, 
   phone TEXT, 
   group_name TEXT,
   id_group INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT s.id_service_user::INT,
        s.historical_id::TEXT,
        CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT),
        s.nickname::TEXT,
        s.email::TEXT,
        s.phone::TEXT,
        g.name::TEXT,
        g.id_group::INT
      FROM service_user s 
        INNER JOIN randomic_operation_locks rol ON rol.service_user_historical_id = s.historical_id
        LEFT OUTER JOIN groups_service_user gu ON gu.id_service_user = s.id_service_user 
          AND gu.is_deleted = false
        LEFT OUTER JOIN groups g ON g.id_group = gu.id_group AND g.is_deleted = false
      WHERE s.is_deleted = false AND rol.is_locked = true 
        AND (rol.lock_date at time zone get_blocked_service_users.timezone)::DATE = (CURRENT_TIMESTAMP at time zone get_blocked_service_users.timezone)::DATE
        ORDER BY s.name;
      
  END;
$FUNCTION$;

-- get incomplete service users
CREATE OR REPLACE FUNCTION get_incomplete_service_users(enabled boolean)
 RETURNS TABLE (
   id_service_user INT, 
   service_user_historical_id TEXT, 
   complete_name TEXT, 
   nickname TEXT, 
   email TEXT, 
   phone TEXT, 
   group_name TEXT,
   id_group INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT s.id_service_user::INT,
        s.historical_id::TEXT,
        CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT),
        s.nickname::TEXT,
        s.email::TEXT,
        s.phone::TEXT,
        g.name::TEXT,
        g.id_group::INT
      FROM service_user s 
        LEFT OUTER JOIN service_user_responses sur ON sur.id_service_user = s.id_service_user
        LEFT OUTER JOIN groups_service_user gu ON gu.id_service_user = s.id_service_user 
          AND gu.is_deleted = false
        LEFT OUTER JOIN groups g ON g.id_group = gu.id_group AND g.is_deleted = false
      WHERE s.enabled = get_incomplete_service_users.enabled AND s.is_deleted = false
      GROUP BY s.id_service_user,g.id_group
      HAVING NOT(COALESCE(
        NULLIF(s.name IS NOT NULL,true),
        NULLIF(s.last_name IS NOT NULL,true),
        NULLIF(s.mothers_last_name IS NOT NULL,true),
        NULLIF(g.id_group IS NOT NULL,true),
        NULLIF(s.address_street IS NOT NULL,true),
        NULLIF(s.address_street_number IS NOT NULL,true),
        NULLIF(s.address_suburb IS NOT NULL,true),
        NULLIF(s.address_county IS NOT NULL,true),
        NULLIF(s.address_city IS NOT NULL,true),
        NULLIF(s.address_state IS NOT NULL,true),
        NULLIF(s.address_zip_code IS NOT NULL,true),
        NULLIF(COUNT(sur.id_response)>=10,true)
      ) IS NULL)	
      ORDER BY s.name;
      
  END;
$FUNCTION$;

--- get service users for randomic operations
CREATE OR REPLACE FUNCTION get_service_users_randomic_operations()
 RETURNS TABLE (
   id_service_user INT, 
   service_user_historical_id TEXT, 
   complete_name TEXT, 
   nickname TEXT, 
   email TEXT, 
   phone TEXT, 
   group_name TEXT,
   id_group INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT s.id_service_user::INT,
        s.historical_id::TEXT,
        CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT),
        s.nickname::TEXT,
        s.email::TEXT,
        s.phone::TEXT,
        g.name::TEXT,
        g.id_group::INT
      FROM service_user s 
        INNER JOIN service_user_responses sur ON sur.id_service_user = s.id_service_user
        INNER JOIN groups_service_user gu ON gu.id_service_user = s.id_service_user 
          AND gu.is_deleted = false
        INNER JOIN groups g ON g.id_group = gu.id_group AND g.is_deleted = false
      WHERE s.enabled = true AND s.is_deleted = false
        AND g.is_deleted = false AND g.enabled = true
      GROUP BY s.id_service_user,g.id_group
      HAVING COALESCE(
        NULLIF(s.name IS NOT NULL,true),
        NULLIF(s.last_name IS NOT NULL,true),
        NULLIF(s.mothers_last_name IS NOT NULL,true),
        NULLIF(g.id_group IS NOT NULL,true),
        NULLIF(s.address_street IS NOT NULL,true),
        NULLIF(s.address_street_number IS NOT NULL,true),
        NULLIF(s.address_suburb IS NOT NULL,true),
        NULLIF(s.address_county IS NOT NULL,true),
        NULLIF(s.address_city IS NOT NULL,true),
        NULLIF(s.address_state IS NOT NULL,true),
        NULLIF(s.address_zip_code IS NOT NULL,true),
        NULLIF(COUNT(sur.id_response)>=10,true)
      ) IS NULL
      ORDER BY s.name;
      
  END;
$FUNCTION$;


--- get all service users by terminal
CREATE OR REPLACE FUNCTION get_all_service_users_by_terminal(enabled boolean, id_electronic_lock INT)
 RETURNS TABLE (
   id_service_user INT, 
   complete_name TEXT,
   service_user_historical_id TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT 
        s.id_service_user::INT,
        CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT),
        s.historical_id::TEXT
      FROM service_user s 
        INNER JOIN service_user_responses sur ON sur.id_service_user = s.id_service_user
        INNER JOIN groups_service_user gu ON gu.id_service_user = s.id_service_user 
        INNER JOIN groups g ON g.id_group = gu.id_group 
        INNER JOIN group_terminal gt ON gt.id_group = g.id_group
        INNER JOIN terminal t ON t.id_terminal = gt.id_terminal
        INNER JOIN assignment assign ON t.id_terminal = assign.id_terminal
        INNER JOIN electronic_lock el ON el.id_lock = assign.id_lock
      WHERE s.enabled = get_all_service_users_by_terminal.enabled  AND s.is_deleted = false 
        AND gu.is_deleted = false 
        AND g.is_deleted = false AND g.enabled = true
        AND gt.is_deleted = false 
        AND t.is_deleted = false AND t.enabled = true
        AND el.id_electronic_lock = get_all_service_users_by_terminal.id_electronic_lock
      GROUP BY s.id_service_user,g.id_group
      HAVING COALESCE(
        NULLIF(s.name IS NOT NULL,true),
        NULLIF(s.last_name IS NOT NULL,true),
        NULLIF(s.mothers_last_name IS NOT NULL,true),
        NULLIF(g.id_group IS NOT NULL,true),
        NULLIF(s.address_street IS NOT NULL,true),
        NULLIF(s.address_street_number IS NOT NULL,true),
        NULLIF(s.address_suburb IS NOT NULL,true),
        NULLIF(s.address_county IS NOT NULL,true),
        NULLIF(s.address_city IS NOT NULL,true),
        NULLIF(s.address_state IS NOT NULL,true),
        NULLIF(s.address_zip_code IS NOT NULL,true),
        NULLIF(COUNT(sur.id_response)>=10,true)
      ) IS NULL
        ORDER BY s.name;
  END;
$FUNCTION$;


--- get all service users from certain group
CREATE OR REPLACE FUNCTION get_all_service_users_from_group(group_historical_id TEXT,enabled boolean)
 RETURNS TABLE (
   id_service_user INT, 
   service_user_historical_id TEXT,
   complete_name TEXT, 
   nickname TEXT, 
   email TEXT, 
   phone TEXT, 
   group_name TEXT,
   id_group INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT s.id_service_user::INT,
        s.historical_id::TEXT,
        CONCAT(s.name::TEXT,' ',s.last_name::TEXT,' ',s.mothers_last_name::TEXT),
        s.nickname::TEXT,
        s.email::TEXT,
        s.phone::TEXT,
        g.name::TEXT,
        g.id_group::INT
      FROM service_user s 
        LEFT OUTER JOIN groups_service_user gu ON gu.id_service_user = s.id_service_user 
        LEFT OUTER JOIN groups g ON g.id_group = gu.id_group
        WHERE s.is_deleted = false AND g.historical_id = group_historical_id AND g.is_deleted = false
          AND s.enabled = get_all_service_users_FROM_group.enabled AND gu.is_deleted = false
          ORDER BY s.name;
  END;
$FUNCTION$;


--- get all system users
CREATE OR REPLACE FUNCTION get_all_system_users(enabled boolean)
 RETURNS TABLE (
   id_system_user INT, 
   system_user_historical_id TEXT,
   complete_name TEXT, 
   nickname TEXT, 
   email TEXT, 
   phone TEXT, 
   role_name TEXT,
   id_role INT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    system_users_ids int[];
    arow RECORD;
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY
      SELECT s.id_system_user::INT,
        s.historical_id::TEXT,
        CONCAT(s.name,' ',s.last_name,' ',s.mothers_last_name)::TEXT,
        s.nickname::TEXT,
        s.email::TEXT,
        s.phone::TEXT,
        r.large_name::TEXT,
        s.id_role::INT
      FROM system_user s 
        INNER JOIN roles r ON r.id_role = s.id_role
        WHERE s.enabled = get_all_system_users.enabled AND s.is_deleted = false AND is_super_user = false
        ORDER BY s.name;
  END;
$FUNCTION$;


--- get catalog of questions
CREATE OR REPLACE FUNCTION get_all_questions()
 RETURNS SETOF questions
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    RETURN QUERY SELECT * FROM questions ORDER BY id_question;
  END;
$FUNCTION$;


--- get service user by id
CREATE OR REPLACE FUNCTION get_service_user_by_historical_id(
    IN service_user_historical_id TEXT,
    IN timezone TEXT,
    OUT id_service_user INT,
    OUT name TEXT,
    OUT last_name TEXT,
    OUT mothers_last_name TEXT,
    OUT nickname TEXT,
    OUT email TEXT, 
    OUT phone TEXT,
    OUT address_street TEXT,
    OUT address_street_number TEXT,
    OUT address_suite_number TEXT,
    OUT address_suburb TEXT,
    OUT address_county TEXT,
    OUT address_city TEXT,
    OUT address_state TEXT,
    OUT address_zip_code TEXT,
    OUT enabled BOOLEAN,
    OUT id_group INT,
    OUT is_locked BOOLEAN,
    OUT disabled_reason TEXT,
    OUT responses service_user_responses[]
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE 
    rec record;
    groups_ids int[];
    already_exist_lock randomic_operation_locks;
  BEGIN
    PERFORM check_token_validity();
    groups_ids := ARRAY(
      SELECT ids.id_group FROM (
        SELECT DISTINCT ON (g.historical_id)historical_id, g.id_group 
          FROM groups g ORDER BY historical_id,g.id_group DESC
      ) AS ids
    );
    SELECT rol.* INTO already_exist_lock
      FROM randomic_operation_locks rol 
    WHERE rol.service_user_historical_id = get_service_user_by_historical_id.service_user_historical_id
      AND (rol.lock_date at time zone get_service_user_by_historical_id.timezone)::DATE = 
        (CURRENT_TIMESTAMP at time zone get_service_user_by_historical_id.timezone)::DATE;

    FOR rec IN (SELECT 
      s.id_service_user::INT,
      s.name::TEXT,
      s.last_name::TEXT,
      s.mothers_last_name::TEXT,
      s.nickname::TEXT,
      s.email::TEXT,
      s.phone::TEXT,
      s.address_street::TEXT,
      s.address_street_number::TEXT,
      s.address_suite_number::TEXT,
      s.address_suburb::TEXT,
      s.address_county::TEXT,
      s.address_city::TEXT,
      s.address_state::TEXT,
      s.address_zip_code::TEXT,
      s.enabled::BOOLEAN,
      s.deleted_reason::TEXT,
      gu.id_group::INT
        FROM service_user AS s 
          LEFT OUTER JOIN groups_service_user gu ON gu.id_service_user = s.id_service_user AND gu.id_group = ANY(groups_ids)
        WHERE s.historical_id = get_service_user_by_historical_id.service_user_historical_id
          AND s.is_deleted = false
         LIMIT 1)
    LOOP
        id_service_user := rec.id_service_user;
        name := rec.name;
        last_name := rec.last_name;
        mothers_last_name := rec.mothers_last_name;
        nickname := rec.nickname;
        email := rec.email; 
        phone := rec.phone;
        address_street := rec.address_street;
        address_street_number := rec.address_street_number;
        address_suite_number := rec.address_suite_number;
        address_suburb := rec.address_suburb;
        address_county := rec.address_county;
        address_city := rec.address_city;
        address_state := rec.address_state;
        address_zip_code := rec.address_zip_code;
        enabled := rec.enabled;
        id_group := rec.id_group;
        is_locked := already_exist_lock.is_locked;
        disabled_reason := rec.deleted_reason;
        responses := ARRAY(SELECT q FROM service_user_responses q 
          INNER JOIN service_user su ON su.id_service_user = q.id_service_user
          WHERE su.historical_id = get_service_user_by_historical_id.service_user_historical_id
            AND su.is_deleted = false);

      RETURN;
    END LOOP;

  END;
$FUNCTION$;


--- get system user by id
CREATE OR REPLACE FUNCTION get_system_user_by_historical_id(
    IN system_user_historical_id TEXT,
    OUT id_system_user INT,
    OUT name TEXT,
    OUT last_name TEXT,
    OUT mothers_last_name TEXT,
    OUT nickname TEXT,
    OUT email TEXT, 
    OUT phone TEXT,
    OUT id_role INT,
    OUT address_street TEXT,
    OUT address_street_number TEXT,
    OUT address_suite_number TEXT,
    OUT address_suburb TEXT,
    OUT address_county TEXT,
    OUT address_city TEXT,
    OUT address_state TEXT,
    OUT address_zip_code TEXT,
    OUT enabled BOOLEAN,
    OUT role_name TEXT,
    OUT disabled_reason TEXT,
    OUT notification_levels INT[]
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  BEGIN
    PERFORM check_token_validity();
    SELECT 
      s.id_system_user::INT,
      s.name::TEXT,
      s.last_name::TEXT,
      s.mothers_last_name::TEXT,
      s.nickname::TEXT,
      s.email::TEXT,
      s.phone::TEXT,
      s.id_role::INT,
      s.address_street::TEXT,
      s.address_street_number::TEXT,
      s.address_suite_number::TEXT,
      s.address_suburb::TEXT,
      s.address_county::TEXT,
      s.address_city::TEXT,
      s.address_state::TEXT,
      s.address_zip_code::TEXT,
      s.enabled::BOOLEAN,
      r.large_name::TEXT,
      s.deleted_reason::TEXT
    INTO 
      id_system_user,
      name,
      last_name,
      mothers_last_name,
      nickname,
      email, 
      phone,
      id_role,
      address_street,
      address_street_number,
      address_suite_number,
      address_suburb,
      address_county,
      address_city,
      address_state,
      address_zip_code,
      enabled,
      role_name,
      disabled_reason
    FROM system_user AS s 
      INNER JOIN roles r ON r.id_role = s.id_role
    WHERE s.historical_id = get_system_user_by_historical_id.system_user_historical_id
      AND s.is_deleted = false
    LIMIT 1;
    notification_levels := ARRAY(
      SELECT sunl.id_notification_level FROM system_user_notification_levels sunl
        WHERE sunl.system_user_historical_id = get_system_user_by_historical_id.system_user_historical_id
    )
    RETURN;
  END;
$FUNCTION$;


--- insert group
CREATE OR REPLACE FUNCTION insert_group(name text, description text)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    existing_group groups;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    SELECT * INTO existing_group FROM groups g WHERE g.name = insert_group.name;
    IF(existing_group is null) THEN
      INSERT INTO groups
          (name,description,historical_action_user_id,enabled)
        VALUES
          (name,description,jwt_historical_id,true);
    ELSE
      RAISE EXCEPTION SQLSTATE '90001' USING 
        MESSAGE = FORMAT('grupoExistente');
    END IF;
  END;
$FUNCTION$;


--- update group
CREATE OR REPLACE FUNCTION update_group(name text, description text,group_historical_id TEXT)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    new_id_group INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    INSERT INTO groups (
      name,
      description,
      enabled,
      historical_id,
      date_updated, 
      historical_action, 
      historical_action_user_id
    )
    SELECT 
      g.name,
      update_group.description,
      g.enabled,
      g.historical_id,
      CURRENT_TIMESTAMP,
      'MODIFICACIÓN',
      jwt_historical_id
    FROM groups AS g WHERE g.historical_id = group_historical_id AND g.is_deleted = false;
    SELECT currval('groups_id_group_seq') INTO new_id_group;

    INSERT INTO groups_service_user (
      id_service_user,
      id_group,
      historical_id
    )
    SELECT 
      gu.id_service_user,
      new_id_group,
      gu.historical_id
    FROM groups_service_user AS gu 
      INNER JOIN groups g ON g.id_group = gu.id_group
    WHERE g.historical_id = group_historical_id AND g.is_deleted = false AND gu.is_deleted = false;

    INSERT INTO group_terminal (
      id_terminal,
      id_group,
      historical_id
    )
    SELECT 
      gt.id_terminal,
      new_id_group,
      gt.historical_id
    FROM group_terminal AS gt 
      INNER JOIN groups g ON g.id_group = gt.id_group
    WHERE g.historical_id = group_historical_id AND g.is_deleted = false AND gt.is_deleted = false;

    UPDATE groups_service_user gu SET
      is_deleted = true
      FROM groups g
      WHERE
        gu.id_group = g.id_group AND gu.is_deleted = false AND
        g.historical_id = group_historical_id AND g.is_deleted = false AND g.id_group != new_id_group;
      
    UPDATE group_terminal gt SET
      is_deleted = true
      FROM groups g
      WHERE
        gt.id_group = g.id_group AND gt.is_deleted = false AND
        g.historical_id = group_historical_id AND g.is_deleted = false AND g.id_group != new_id_group;

    UPDATE groups g SET
      is_deleted = true
      WHERE
        g.historical_id = group_historical_id AND g.is_deleted = false AND g.id_group != new_id_group;
  END;
$FUNCTION$;


--- insert service user
CREATE OR REPLACE FUNCTION insert_service_user(
  address_street text, 
  address_street_number text, 
  address_suite_number text, 
  address_suburb text, 
  address_county text,
  address_city text,
  address_state text, 
  address_zip_code text, 
  email text, 
  last_name text, 
  mothers_last_name text, 
  name text, 
  nickname text, 
  nip text, 
  phone text, 
  enabled boolean, 
  id_group text, 
  array_respuestas text[],
  array_questions int[]
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    id_service_user int;
    jwt_historical_id text;
    existing_service_user service_user;
    existing_system_user system_user;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    SELECT * INTO existing_service_user FROM service_user s WHERE s.email = insert_service_user.email AND s.is_deleted = false;
    SELECT * INTO existing_system_user FROM system_user s WHERE s.email = insert_service_user.email AND s.is_deleted = false;
    IF(existing_service_user IS NULL AND existing_system_user IS NULL) THEN
      INSERT INTO service_user (
        address_street,
        address_street_number,
        address_suite_number,
        address_suburb,
        address_county,
        address_city,
        address_state,
        address_zip_code,
        email,
        name,
        last_name, 
        mothers_last_name, 
        nickname,
        nip,
        phone,
        enabled,
        creation_mode,
        historical_action_user_id
      )
      VALUES (
        insert_service_user.address_street,
        insert_service_user.address_street_number,
        insert_service_user.address_suite_number,
        insert_service_user.address_suburb,
        insert_service_user.address_county,
        insert_service_user.address_city,
        insert_service_user.address_state,
        insert_service_user.address_zip_code,
        insert_service_user.email,
        insert_service_user.name,
        insert_service_user.last_name, 
        insert_service_user.mothers_last_name, 
        insert_service_user.nickname,
        insert_service_user.nip,
        insert_service_user.phone,
        insert_service_user.enabled,
        'Formulario',
        jwt_historical_id
      );
      SELECT currval('service_user_id_service_user_seq') INTO id_service_user;

      IF(id_group != '') THEN
        INSERT INTO groups_service_user (
          id_group,
          id_service_user,
          historical_action_user_id
        )
        VALUES( 
          insert_service_user.id_group::int, 
          id_service_user,
          jwt_historical_id
        );
      END IF;

      FOR i IN 1 .. array_upper(array_questions,1)
        LOOP
          INSERT INTO service_user_responses (
            id_question,
            id_service_user,
            response
          ) 
          VALUES (
            array_questions[i],
            id_service_user,
            array_respuestas[i]
          );
        END LOOP;
    ELSE
      RAISE EXCEPTION SQLSTATE '90001' USING 
        MESSAGE = FORMAT('emailExistente');
    END IF;
  END;
$FUNCTION$;

--- insert service user
CREATE OR REPLACE FUNCTION insert_service_user_from_upload(
  name text, 
  last_name text, 
  mothers_last_name text, 
  email text, 
  nip text, 
  array_respuestas text[]
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    id_service_user int;
    jwt_historical_id text;
    existing_service_user service_user;
    existing_system_user system_user;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    SELECT * INTO existing_service_user FROM service_user s WHERE s.email = insert_service_user_from_upload.email AND s.is_deleted = false;
    SELECT * INTO existing_system_user FROM system_user s WHERE s.email = insert_service_user_from_upload.email AND s.is_deleted = false;
    IF(existing_service_user IS NULL AND existing_system_user IS NULL) THEN
      INSERT INTO service_user (
        name,
        last_name, 
        mothers_last_name, 
        email,
        nip,
        enabled,
        creation_mode,
        historical_action_user_id
      )
      VALUES (
        insert_service_user_from_upload.name,
        insert_service_user_from_upload.last_name, 
        insert_service_user_from_upload.mothers_last_name, 
        insert_service_user_from_upload.email,
        insert_service_user_from_upload.nip,
        true,
        'Archivo',
        jwt_historical_id
      );
      SELECT currval('service_user_id_service_user_seq') INTO id_service_user;

      FOR i IN 1 .. array_upper(array_respuestas,1)
        LOOP
          IF(array_respuestas[i] != '') THEN
            INSERT INTO service_user_responses (
              id_question,
              id_service_user,
              response
            ) 
            VALUES (
              i,
              id_service_user,
              array_respuestas[i]
            );
          END IF;
        END LOOP;
    ELSE
      RAISE EXCEPTION SQLSTATE '90001' USING 
        MESSAGE = FORMAT('emailExistente');
    END IF;
  END;
$FUNCTION$;


--- insert system user
CREATE OR REPLACE FUNCTION insert_system_user(
  address_street text, 
  address_street_number text, 
  address_suite_number text, 
  address_suburb text, 
  address_county text,
  address_city text,
  address_state text, 
  address_zip_code text, 
  email text, 
  id_role integer, 
  name text, 
  last_name text, 
  mothers_last_name text, 
  nickname text, 
  password text, 
  phone text, 
  enabled boolean, 
  notification_levels INT[]
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE
    jwt_historical_id text;
    existing_service_user service_user;
    existing_system_user system_user;
    new_historical_id TEXT;
	  id_notification_lvl INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    SELECT * INTO existing_service_user FROM service_user s WHERE s.email = insert_system_user.email AND s.is_deleted = false;
    SELECT * INTO existing_system_user FROM system_user s WHERE s.email = insert_system_user.email AND s.is_deleted = false;
    IF(existing_service_user IS NULL AND existing_system_user IS NULL) THEN
      INSERT INTO system_user (
        address_street,
        address_street_number,
        address_suite_number,
        address_suburb,
        address_county,
        address_city,
        address_state,
        address_zip_code,
        email,
        id_role,
        name,
        last_name,
        mothers_last_name,
        nickname,
        password,
        phone,
        enabled,
        historical_action_user_id
      )
      VALUES (
        insert_system_user.address_street,
        insert_system_user.address_street_number,
        insert_system_user.address_suite_number,
        insert_system_user.address_suburb,
        insert_system_user.address_county,
        insert_system_user.address_city,
        insert_system_user.address_state,
        insert_system_user.address_zip_code,
        insert_system_user.email,
        insert_system_user.id_role,
        insert_system_user.name,
        insert_system_user.last_name,
        insert_system_user.mothers_last_name,
        insert_system_user.nickname,
        insert_system_user.password,
        insert_system_user.phone,
        insert_system_user.enabled,
        jwt_historical_id
      ) RETURNING system_user.historical_id INTO new_historical_id;

      FOREACH id_notification_lvl IN ARRAY notification_levels LOOP
        INSERT INTO system_user_notification_levels
          (system_user_historical_id,id_notification_level)
        VALUES
          (new_historical_id,id_notification_lvl);
      END LOOP;

    ELSE
      RAISE EXCEPTION SQLSTATE '90001' USING 
        MESSAGE = FORMAT('emailExistente');
    END IF;
  END;
$FUNCTION$;

-- unlock service user to use randomic operations
CREATE OR REPLACE FUNCTION unlock_service_user(
  IN service_user_historical_id TEXT,
  IN timezone TEXT
)
  RETURNS VOID
  LANGUAGE plpgsql
  VOLATILE
AS 
$function$
  BEGIN
    PERFORM check_token_validity();
    UPDATE randomic_operation_locks rol SET
      is_locked = false
    WHERE rol.service_user_historical_id = unlock_service_user.service_user_historical_id
      AND (rol.lock_date at time zone unlock_service_user.timezone)::DATE = 
        (CURRENT_TIMESTAMP at time zone unlock_service_user.timezone)::DATE;
  END;
$function$;


--- update service user
CREATE OR REPLACE FUNCTION update_service_user(
  address_street text, 
  address_street_number text, 
  address_suite_number text, 
  address_suburb text, 
  address_county text,
  address_city text,
  address_state text, 
  address_zip_code text, 
  name text, 
  last_name text, 
  mothers_last_name text, 
  nickname text, 
  phone text, 
  id_group text,
  service_user_historical_id TEXT, 
  array_respuestas text[],
  array_questions int[]
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    new_id_service_user int;
    count_group_relation INT;
    enabled_to_update BOOLEAN;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    SELECT su.enabled INTO enabled_to_update FROM service_user su 
      WHERE su.historical_id = update_service_user.service_user_historical_id
        AND su.is_deleted = false;

    IF(enabled_to_update) THEN

      INSERT INTO service_user (
        address_street,
        address_street_number,
        address_suite_number,
        address_suburb,
        address_county,
        address_city,
        address_state,
        address_zip_code,
        name, 
        last_name, 
        mothers_last_name, 
        nickname, 
        phone, 
        historical_id,
        email, 
        nip,
        enabled,
        historical_action_user_id, 
        historical_action, 
        date_updated
      )
      SELECT 
        update_service_user.address_street,
        update_service_user.address_street_number,
        update_service_user.address_suite_number,
        update_service_user.address_suburb,
        update_service_user.address_county, 
        update_service_user.address_city, 
        update_service_user.address_state, 
        update_service_user.address_zip_code, 
        update_service_user.name,
        update_service_user.last_name,
        update_service_user.mothers_last_name,
        update_service_user.nickname,
        update_service_user.phone, 
        su.historical_id, 
        su.email, 
        su.nip, 
        su.enabled, 
        jwt_historical_id, 
        'MODIFICACIÓN', 
        CURRENT_TIMESTAMP
      FROM service_user AS su WHERE su.historical_id = update_service_user.service_user_historical_id
        AND su.is_deleted = false;

      SELECT currval('service_user_id_service_user_seq') INTO new_id_service_user;
      SELECT count(gu.*) INTO count_group_relation 
        FROM groups_service_user gu 
          INNER JOIN service_user su ON su.id_service_user = gu.id_service_user
        WHERE su.historical_id = update_service_user.service_user_historical_id
          AND su.is_deleted = false;
      IF(id_group != '' AND count_group_relation >= 1) THEN
        INSERT INTO groups_service_user(
          id_group,
          id_service_user,
          historical_id,
          historical_action_user_id,
          historical_action,
          date_updated
        )SELECT
          update_service_user.id_group::int,
          new_id_service_user,
          gu.historical_id,
          jwt_historical_id,
          'MODIFICACIÓN',
          CURRENT_TIMESTAMP
        FROM groups_service_user gu 
          INNER JOIN service_user su ON su.id_service_user = gu.id_service_user
        WHERE su.historical_id = update_service_user.service_user_historical_id
          AND su.is_deleted = false AND gu.is_deleted = false;

      ELSIF(id_group != '') THEN
        INSERT INTO groups_service_user (
          id_group,
          id_service_user,
          historical_action_user_id
        )
        VALUES( 
          update_service_user.id_group::int, 
          new_id_service_user,
          jwt_historical_id
        );
      END IF;

      FOR i IN 1 .. array_upper(update_service_user.array_questions,1)
      LOOP
        INSERT INTO service_user_responses (
          id_question,
          id_service_user,
          response
        ) 
        VALUES (
          update_service_user.array_questions[i],
          new_id_service_user,
          update_service_user.array_respuestas[i]
        ) ON CONFLICT DO NOTHING;
      END LOOP;

      UPDATE groups_service_user g
        SET
          is_deleted = true
        FROM service_user su
        WHERE
          g.id_service_user = su.id_service_user AND g.is_deleted = false AND
          su.historical_id = update_service_user.service_user_historical_id AND su.is_deleted = false
            AND su.id_service_user != new_id_service_user;

      UPDATE service_user s
        SET
          is_deleted = true
        WHERE
          s.historical_id = update_service_user.service_user_historical_id AND s.is_deleted = false
            AND s.id_service_user != new_id_service_user;

    ELSE
      RAISE EXCEPTION SQLSTATE '90001' USING 
        MESSAGE = FORMAT('noSePuedeEditar');
    END IF;
  END;
$FUNCTION$;


--- update system user
CREATE OR REPLACE FUNCTION update_system_user(
  address_street text, 
  address_street_number text, 
  address_suite_number text, 
  address_suburb text, 
  address_county text,
  address_city text, 
  address_state text, 
  address_zip_code text, 
  id_role integer, 
  name text, 
  last_name text, 
  mothers_last_name text, 
  nickname text, 
  phone text, 
  system_user_historical_id TEXT, 
  notification_levels INT[]
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    next_system_user_id INT;
	  id_notification_lvl INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    INSERT INTO system_user (
      address_street,
      address_street_number,
      address_suite_number,
      address_suburb,
      address_county,
      address_city,
      address_state,
      address_zip_code,
      name, 
      last_name,
      mothers_last_name,
      nickname, 
      phone, 
      id_role,
      historical_id,
      email, 
      password,
      enabled,
      historical_action_user_id, 
      historical_action, 
      date_updated
    )
    SELECT 
      update_system_user.address_street,
      update_system_user.address_street_number,
      update_system_user.address_suite_number,
      update_system_user.address_suburb,
      update_system_user.address_county, 
      update_system_user.address_city, 
      update_system_user.address_state, 
      update_system_user.address_zip_code, 
      update_system_user.name,
      update_system_user.last_name,
      update_system_user.mothers_last_name,
      update_system_user.nickname,
      update_system_user.phone, 
      update_system_user.id_role,
      su.historical_id, 
      su.email, 
      su.password, 
      su.enabled, 
      jwt_historical_id, 
      'MODIFICACIÓN', 
      CURRENT_TIMESTAMP
    FROM system_user AS su WHERE su.historical_id = update_system_user.system_user_historical_id
      AND su.is_deleted = false;

    SELECT currval('system_user_id_system_user_seq') INTO next_system_user_id;
    UPDATE system_user s
      SET
          is_deleted = true
      WHERE
          s.historical_id = update_system_user.system_user_historical_id AND is_deleted = false
            AND s.id_system_user != next_system_user_id;

    DELETE FROM system_user_notification_levels sunl
      WHERE sunl.system_user_historical_id = update_system_user.system_user_historical_id;

    FOREACH id_notification_lvl IN ARRAY notification_levels LOOP
      INSERT INTO system_user_notification_levels
        (system_user_historical_id,id_notification_level)
      VALUES
        (system_user_historical_id,id_notification_lvl);
    END LOOP;
  END;
$FUNCTION$;


--- get all system users emails
CREATE OR REPLACE FUNCTION get_all_system_users_emails(enabled boolean)
 RETURNS TABLE (
   email TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    system_users_ids int[];
    arow RECORD;
  BEGIN
    RETURN QUERY
      SELECT 
        s.email::TEXT
      FROM system_user s 
      WHERE s.enabled = get_all_system_users_emails.enabled AND s.is_deleted = false
        ORDER BY s.name;
  END;
$FUNCTION$;


CREATE OR REPLACE FUNCTION get_system_users_emails_notification_level(enabled boolean, id_notification_level INT)
 RETURNS TABLE (
   email TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    system_users_ids int[];
    arow RECORD;
  BEGIN
    RETURN QUERY
      SELECT 
        s.email::TEXT
      FROM system_user s 
        INNER JOIN system_user_notification_levels sunl ON sunl.system_user_historical_id = s.historical_id
      WHERE s.enabled = get_system_users_emails_notification_level.enabled AND s.is_deleted = false 
        AND sunl.id_notification_level = get_system_users_emails_notification_level.id_notification_level
      ORDER BY s.name;
  END;
$FUNCTION$;

CREATE OR REPLACE FUNCTION get_all_emails()
 RETURNS TABLE (
   email TEXT
  )
 LANGUAGE plpgsql
 STABLE
AS 
$FUNCTION$
  DECLARE
    system_users_ids int[];
    arow RECORD;
  BEGIN
    RETURN QUERY
      (SELECT 
        s.email::TEXT
      FROM system_user s 
      WHERE s.is_deleted = false 
    UNION
      SELECT 
        s.email::TEXT
      FROM service_user s 
      WHERE s.is_deleted = false )ORDER BY email;
  END;
$FUNCTION$;

--- reset system user password
CREATE OR REPLACE FUNCTION reset_system_user_password(system_user_historical_id TEXT, password TEXT)
 RETURNS VOID
 LANGUAGE plpgsql
 VOLATILE
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    next_system_user_id INT;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;

    INSERT INTO system_user (
      address_street,
      address_street_number,
      address_suite_number,
      address_suburb,
      address_county,
      address_city,
      address_state,
      address_zip_code,
      name, 
      last_name, 
      mothers_last_name, 
      nickname, 
      phone, 
      id_role,
      historical_id,
      email, 
      password,
      enabled,
      historical_action_user_id, 
      historical_action, 
      date_updated
    )
    SELECT 
      su.address_street,
      su.address_street_number,
      su.address_suite_number,
      su.address_suburb,
      su.address_county, 
      su.address_city, 
      su.address_state, 
      su.address_zip_code, 
      su.name,
      su.last_name,
      su.mothers_last_name,
      su.nickname,
      su.phone, 
      su.id_role,
      su.historical_id, 
      su.email, 
      reset_system_user_password.password, 
      su.enabled, 
      jwt_historical_id, 
      'MODIFICACIÓN', 
      CURRENT_TIMESTAMP
    FROM system_user AS su WHERE su.historical_id = system_user_historical_id
      AND su.is_deleted = false;

    SELECT currval('system_user_id_system_user_seq') INTO next_system_user_id;
    UPDATE system_user s
      SET
          is_deleted = true
      WHERE
          s.historical_id = system_user_historical_id AND is_deleted = false
            AND s.id_system_user != next_system_user_id;
  END;
$FUNCTION$;

-- reset service user nip
CREATE OR REPLACE FUNCTION reset_service_user_nip(
  service_user_historical_id TEXT,
  nip TEXT
)
 RETURNS void
 LANGUAGE plpgsql
AS 
$FUNCTION$
  DECLARE 
    jwt_historical_id text;
    new_id_service_user int;
    count_group_relation INT;
    enabled_to_update BOOLEAN;
  BEGIN
    PERFORM check_token_validity();
    SELECT current_setting('jwt.claims.historical_id') INTO jwt_historical_id;
    SELECT su.enabled INTO enabled_to_update FROM service_user su 
      WHERE su.historical_id = reset_service_user_nip.service_user_historical_id
        AND su.is_deleted = false;

    IF(enabled_to_update) THEN
      INSERT INTO service_user (
        address_street,
        address_street_number,
        address_suite_number,
        address_suburb,
        address_county,
        address_city,
        address_state,
        address_zip_code,
        name, 
        last_name, 
        mothers_last_name, 
        nickname, 
        phone, 
        historical_id,
        email, 
        nip,
        enabled,
        historical_action_user_id, 
        historical_action, 
        date_updated
      )
      SELECT 
        su.address_street,
        su.address_street_number,
        su.address_suite_number,
        su.address_suburb,
        su.address_county, 
        su.address_city, 
        su.address_state, 
        su.address_zip_code, 
        su.name,
        su.last_name, 
        su.mothers_last_name, 
        su.nickname,
        su.phone, 
        su.historical_id, 
        su.email, 
        reset_service_user_nip.nip, 
        su.enabled, 
        jwt_historical_id, 
        'MODIFICACIÓN', 
        CURRENT_TIMESTAMP
      FROM service_user AS su WHERE su.historical_id = reset_service_user_nip.service_user_historical_id
        AND su.is_deleted = false;

      SELECT currval('service_user_id_service_user_seq') INTO new_id_service_user;
      SELECT count(gu.*) INTO count_group_relation 
        FROM groups_service_user gu 
          INNER JOIN service_user su ON su.id_service_user = gu.id_service_user
        WHERE su.historical_id = reset_service_user_nip.service_user_historical_id
          AND su.is_deleted = false;
      IF(count_group_relation >= 1) THEN
        INSERT INTO groups_service_user(
          id_group,
          id_service_user,
          historical_id,
          historical_action_user_id,
          historical_action,
          date_updated
        )SELECT
          gu.id_group::int,
          new_id_service_user,
          gu.historical_id,
          jwt_historical_id,
          'MODIFICACIÓN',
          CURRENT_TIMESTAMP
        FROM groups_service_user gu 
          INNER JOIN service_user su ON su.id_service_user = gu.id_service_user
        WHERE su.historical_id = reset_service_user_nip.service_user_historical_id
          AND su.is_deleted = false AND gu.is_deleted = false;
      END IF;
      
      INSERT INTO service_user_responses (
        id_question,
        id_service_user,
        response
      ) 
      SELECT 
        sur.id_question,
        new_id_service_user,
        sur.response
      FROM service_user AS su 
        INNER JOIN service_user_responses sur ON sur.id_service_user = su.id_service_user
      WHERE su.historical_id = reset_service_user_nip.service_user_historical_id
        AND su.is_deleted = false ON CONFLICT DO NOTHING;

      UPDATE groups_service_user g
        SET
          is_deleted = true
        FROM service_user su
        WHERE
          g.id_service_user = su.id_service_user AND g.is_deleted = false AND
          su.historical_id = reset_service_user_nip.service_user_historical_id AND su.is_deleted = false
            AND su.id_service_user != new_id_service_user;

      UPDATE service_user s
        SET
          is_deleted = true
        WHERE
          s.historical_id = reset_service_user_nip.service_user_historical_id AND s.is_deleted = false
            AND s.id_service_user != new_id_service_user;

    ELSE
      RAISE EXCEPTION SQLSTATE '90001' USING 
        MESSAGE = FORMAT('noSePuedeEditar');
    END IF;
  END;
$FUNCTION$;-- Schema permissions
GRANT USAGE ON SCHEMA public TO system_admin;
GRANT USAGE ON SCHEMA public TO mesa_control;

-- Functions permissions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO system_admin;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_jwt_token TO public;
GRANT EXECUTE ON FUNCTION uuid_generate_v4 TO mesa_control,asignador;

-- Sequences permissions
GRANT USAGE ON ALL SEQUENCES in SCHEMA public To system_admin;-- table permissions
GRANT SELECT,UPDATE ON event_notifications,alarm_notifications,historical_lock,work_mode,historical_lock_notifications TO system_admin;
GRANT SELECT,UPDATE ON event_notifications,alarm_notifications,historical_lock,work_mode,historical_lock_notifications to mesa_control;
GRANT SELECT,UPDATE ON event_notifications,alarm_notifications,historical_lock,work_mode,historical_lock_notifications to monitoreo;

GRANT SELECT ON notifications_level TO system_admin,mesa_control,monitoreo;

GRANT SELECT, INSERT ON event_notifications,alarm_notifications,historical_lock_notifications to backend_agent;
GRANT SELECT ON events,event_type,alarms,alarm_type,system_user,historical_lock,work_mode,notifications_level,system_user_notification_levels to backend_agent;

-- function permissions
GRANT EXECUTE ON FUNCTION 
  get_last_notifications,
  get_notifications,
  get_new_notifications,
  read_event_notification,
  read_alarm_notification,
  read_historical_lock_notification
TO mesa_control;

GRANT EXECUTE ON FUNCTION 
  get_last_notifications,
  get_notifications,
  get_new_notifications,
  read_event_notification,
  read_alarm_notification,
  read_historical_lock_notification
TO monitoreo;

GRANT EXECUTE ON FUNCTION 
  get_new_notifications_to_push,
  insert_new_event_notification,
  insert_new_alarm_notification,
  insert_new_historical_lock_notification
TO backend_agent;

-- sequence permissions
GRANT USAGE ON 
  event_notifications_id_event_notification_seq,
  alarm_notifications_id_alarm_notification_seq,
  historical_lock_notifications_id_historical_lock_notificati_seq
TO backend_agent;-- Tables permissions
GRANT SELECT, INSERT ON historical_lock to public;

GRANT SELECT, INSERT, UPDATE ON branch to system_admin;
GRANT SELECT, INSERT, UPDATE ON terminal to system_admin;
GRANT SELECT, INSERT, UPDATE ON group_terminal to system_admin;
GRANT SELECT, INSERT, UPDATE ON electronic_lock to system_admin;
GRANT SELECT, INSERT, UPDATE ON assignment to system_admin;
GRANT SELECT, INSERT, UPDATE ON alarms to system_admin;
GRANT SELECT,UPDATE ON alarm_type to system_admin;
GRANT SELECT ON lock_key to system_admin;
GRANT SELECT, INSERT, UPDATE ON randomic_operation to system_admin;
GRANT SELECT, INSERT, UPDATE ON randomic_operation_questions to system_admin;
GRANT SELECT, INSERT, UPDATE ON randomic_operation_locks to system_admin;
GRANT SELECT, INSERT, UPDATE ON randomic_challenge_opening to system_admin;

GRANT SELECT, INSERT, UPDATE ON branch to mesa_control;
GRANT SELECT, INSERT, UPDATE ON terminal to mesa_control;
GRANT SELECT, INSERT, UPDATE ON assignment to mesa_control;
GRANT SELECT ON terminal to mesa_control;
GRANT SELECT,INSERT,UPDATE ON group_terminal to mesa_control;
GRANT SELECT, UPDATE ON electronic_lock to mesa_control;
GRANT SELECT ON electronic_lock to mesa_control;
GRANT SELECT ON assignment to mesa_control;
GRANT SELECT ON lock_key to mesa_control;
GRANT SELECT ON command_type to mesa_control;
GRANT SELECT ON alarms,alarm_type to mesa_control;
GRANT SELECT ON events,event_type to mesa_control;
GRANT SELECT, INSERT, UPDATE ON commands to mesa_control;
GRANT SELECT, INSERT ON randomic_operation_locks to mesa_control;
GRANT SELECT, INSERT, UPDATE ON randomic_operation to mesa_control;
GRANT SELECT, INSERT ON randomic_operation_questions to mesa_control;
GRANT SELECT, INSERT, UPDATE ON randomic_challenge_opening to mesa_control;

GRANT SELECT ON branch to monitoreo;
GRANT SELECT ON terminal, group_terminal to monitoreo;
GRANT SELECT ON randomic_operation_locks to monitoreo;
GRANT SELECT ON assignment to monitoreo;
GRANT SELECT ON electronic_lock to monitoreo;
GRANT SELECT ON commands,command_type to monitoreo;
GRANT SELECT ON historical_lock,work_mode to monitoreo;
GRANT SELECT ON alarms,alarm_type to monitoreo;
GRANT SELECT ON events,event_type to monitoreo;
GRANT SELECT ON randomic_operation to monitoreo;

GRANT SELECT ON branch to asignador;
GRANT SELECT, INSERT, UPDATE ON terminal, group_terminal to asignador;
GRANT SELECT, INSERT ON assignment to asignador;
GRANT SELECT, UPDATE ON electronic_lock to asignador;
GRANT SELECT ON historical_lock,work_mode to asignador;
GRANT SELECT ON alarms,alarm_type to asignador;

GRANT SELECT ON commands,electronic_lock,assignment,terminal TO backend_agent;
GRANT UPDATE ON commands TO backend_agent;

-- Functions Permissions
GRANT EXECUTE ON FUNCTION 
  -- BRANCHES
  insert_new_branch,
  get_all_branches,
  get_all_branches_by_status,
  get_branch_by_historical_id,
  update_branch,
  disable_branch,
  enable_branch,
  get_cashier_counts,
  get_cashiers_status,

  -- Cashiers
  get_all_cashiers,
  get_all_cashiers_by_status,
  get_incomplete_cashiers,
  get_all_cashiers_by_group,
  insert_new_cashier,
  upload_cashiers_massive,
  get_cashier_by_id,
  get_cashier_related_data_by_id,
  update_cashier,
  disable_cashier,
  enable_cashier,
  assign_group_terminal,
  get_commands_for_cashiers,
  get_assignations_from_cashiers,
  get_cashier_alarms,
  get_events_from_cashiers,
  get_all_work_modes,
  get_all_alarm_types,
  get_historic_work_modes_by_id,
  add_replace_lock_to_cashier,
  make_lock_installation,

  -- Electronic Locks
  get_all_electronic_locks,
  get_all_electronic_locks_by_user,
  get_lock_key_by_id,
  get_open_electronic_locks,
  get_electronic_lock_list,
  get_electronic_lock_related_data_by_id,

  -- randomic operations
  insert_new_randomic_operation,
  insert_new_temp_code_command,
  gen_random_bytes,
  approve_randomic_operation,
  verify_service_user,
  get_questions_service_user,
  lock_service_user,
  get_service_users_randomic_operations,
  get_electronic_locks_randomic_operations,
  
  -- commands
  get_all_command_types,
  insert_new_command,
  check_command_situation,
  get_programmed_command,
  cancel_randomic_open_command,
  direct_cancel_randomic_open_command,
  cancel_commands_from_terminal,
  insert_randomic_challenge_opening,
  set_success_randomic_challenge_opening,
  set_failure_randomic_challenge_opening
TO mesa_control;

GRANT EXECUTE ON FUNCTION 
   -- BRANCHES
  get_all_branches,
  get_all_branches_by_status,
  get_cashiers_status,

  -- Cashiers
  get_all_cashiers,
  get_all_cashiers_by_status,
  get_cashier_related_data_by_id,
  get_incomplete_cashiers,
  get_commands_for_cashiers,
  get_assignations_from_cashiers,
  get_cashier_alarms,
  get_events_from_cashiers,
  get_all_work_modes,
  get_all_alarm_types,
  get_electronic_lock_list,
  get_historic_work_modes_by_id,
  get_electronic_lock_related_data_by_id,
  get_cashier_counts,

  --commands
  get_all_command_types
TO monitoreo;

GRANT EXECUTE ON FUNCTION 
   -- BRANCHES
  get_all_branches,
  get_all_branches_by_status,

  -- Cashiers
  get_all_cashiers,
  get_all_cashiers_by_status,
  get_incomplete_cashiers,
  insert_new_cashier,
  upload_cashiers_massive,
  get_cashier_related_data_by_id,
  add_replace_lock_to_cashier,

  -- Electronic Locks
  get_open_electronic_locks
TO asignador;

GRANT EXECUTE ON FUNCTION 
  cancel_commands_from_terminal
TO backend_agent;

-- Sequences permissions
GRANT USAGE ON 
  branch_id_branch_seq,
  terminal_id_terminal_seq,
  assignment_id_assignment_seq,
  group_terminal_id_group_terminal_seq,
  randomic_operation_id_randomic_operation_seq,
  randomic_operation_questions_randomic_operation_questions_i_seq,
  randomic_operation_locks_id_randomic_operation_lock_seq,
  commands_id_command_seq,
  historical_lock_id_historical_lock_seq,
  randomic_challenge_opening_id_randomic_challenge_opening_seq
To mesa_control;

GRANT USAGE ON 
  terminal_id_terminal_seq,
  assignment_id_assignment_seq,
  group_terminal_id_group_terminal_seq,
  historical_lock_id_historical_lock_seq
To asignador;-- Tables permissions
GRANT SELECT,INSERT,UPDATE ON commands to system_admin;
GRANT SELECT ON command_type to system_admin;
GRANT SELECT ON events to system_admin;
GRANT SELECT,UPDATE ON event_type to system_admin;

GRANT EXECUTE ON FUNCTION 
  --reports
  get_service_users_with_responses,
  get_cashiers_report,
  get_operations_report

TO mesa_control;

GRANT EXECUTE ON FUNCTION 
  --reports
  get_operations_report

TO monitoreo;GRANT SELECT, INSERT, UPDATE ON electronic_lock_tests TO system_admin;
GRANT SELECT, INSERT, UPDATE ON electronic_lock_tests_steps TO system_admin;

GRANT SELECT, INSERT, UPDATE ON electronic_lock_tests TO test;
GRANT SELECT, INSERT, UPDATE ON electronic_lock_tests_steps TO test;
GRANT SELECT, UPDATE ON electronic_lock to test;
GRANT SELECT, INSERT, UPDATE ON commands to test;

GRANT SELECT, UPDATE ON electronic_lock_tests TO backend_agent;
GRANT SELECT, UPDATE ON electronic_lock_tests_steps TO backend_agent;

GRANT EXECUTE ON FUNCTION 
  get_electronic_locks_in_test,
  get_failure_historic_lock_tests_report,
  get_success_historic_lock_tests_report,
  insert_new_keyboard_test_command,
  insert_new_test,
  insert_new_test_step,
  check_command_situation,
  check_test_situation,
  get_programmed_command,
  get_current_test,
  advance_electronic_lock_status,
  set_lock_test_failure_details
To test;

GRANT EXECUTE ON FUNCTION 
  cancel_keyboard_test_commands,
  cancel_open_test_steps
TO backend_agent;

GRANT USAGE ON 
  commands_id_command_seq,
  electronic_lock_tests_id_electronic_lock_test_seq,
  electronic_lock_tests_steps_id_electronic_lock_test_step_seq
To test;-- Table Permissions
GRANT SELECT,UPDATE,INSERT ON system_user TO system_admin;
GRANT SELECT,DELETE,INSERT ON system_user_notification_levels TO system_admin;
GRANT SELECT ON system_user to mesa_control;
GRANT SELECT,UPDATE,INSERT ON service_user to system_admin;
GRANT SELECT,UPDATE,INSERT ON service_user to mesa_control;
GRANT SELECT ON system_user,service_user,groups_service_user,groups,service_user_responses to monitoreo;
GRANT SELECT ON system_user,service_user,groups_service_user,groups,service_user_responses,questions,roles to test;
GRANT SELECT ON groups,groups_service_user,group_terminal,service_user,terminal to asignador;

GRANT SELECT,UPDATE,INSERT ON groups TO system_admin;
GRANT SELECT,UPDATE,INSERT ON groups TO mesa_control;

GRANT SELECT,UPDATE,INSERT ON questions to system_admin;
GRANT SELECT,UPDATE,INSERT ON questions to mesa_control;
GRANT SELECT,UPDATE,INSERT ON service_user_responses to system_admin;
GRANT SELECT,UPDATE,INSERT ON service_user_responses to mesa_control;
GRANT SELECT,UPDATE,INSERT ON groups_service_user to system_admin;
GRANT SELECT,UPDATE,INSERT ON groups_service_user to mesa_control;

GRANT SELECT,UPDATE,INSERT ON roles TO system_admin;
GRANT SELECT ON roles TO mesa_control;
GRANT SELECT,UPDATE,DELETE ON auth_tokens TO mesa_control,system_admin,monitoreo,asignador,test;
GRANT SELECT,INSERT ON historic_sessions TO mesa_control,system_admin,monitoreo,asignador,test;

GRANT EXECUTE ON FUNCTION 
  --auth
  check_token_validity,
  update_auth_token,
  logout,

  -- service users
  get_all_service_users,
  get_blocked_service_users,
  get_all_service_users_from_group,
  get_all_service_users_by_terminal,
  get_service_user_by_historical_id,
  insert_service_user,
  update_service_user,
  disable_service_user,
  enable_service_user,
  get_all_questions,
  assign_group_service_user,
  get_incomplete_service_users,
  get_all_emails,
  insert_service_user_from_upload,

  -- groups
  get_all_groups_with_status, 
  get_all_groups,
  get_group_by_historical_id,
  insert_group,
  update_group,
  enable_group,
  disable_group
TO mesa_control;

GRANT EXECUTE ON FUNCTION 
  --auth
  check_token_validity,
  update_auth_token,
  logout,

  -- service users
  get_all_service_users,
  get_blocked_service_users,
  get_incomplete_service_users,

  -- groups
  get_all_groups_with_status, 
  get_all_groups
TO monitoreo;

GRANT EXECUTE ON FUNCTION 
  --auth
  check_token_validity,
  update_auth_token,
  logout,

    -- groups
  get_all_groups_with_status, 
  get_all_groups
TO asignador;

GRANT EXECUTE ON FUNCTION 
  --auth
  check_token_validity,
  update_auth_token,
  logout,

  -- service users
  get_all_service_users_by_terminal,
  get_all_questions
TO test;

GRANT EXECUTE ON FUNCTION 
  -- system users
  get_system_users_emails_notification_level
TO backend_agent;

-- Sequences permissions
GRANT USAGE ON 
  system_user_id_system_user_seq,
  service_user_id_service_user_seq,
  service_user_responses_id_response_seq,
  groups_service_user_id_user_group_seq,
  groups_id_group_seq
To mesa_control;

GRANT USAGE ON 
  historic_sessions_id_historic_sessions_seq
To mesa_control,monitoreo,asignador,test;

