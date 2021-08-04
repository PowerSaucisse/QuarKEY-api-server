-- Author : Estéban Ristich <esteban.ristich@protonmail.com>

SELECT 'CREATE DATABASE quarkey ENCODING ''UTF8'''
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'quarkey')\gexec

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


CREATE TABLE IF NOT EXISTS tester_keys (
    id              VARCHAR(20) PRIMARY KEY NOT NULL UNIQUE,
    type            VARCHAR(6) NOT NULL,
    expiration_on   TIMESTAMP DEFAULT NULL,
    created_on      TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc')
);


CREATE TABLE IF NOT EXISTS accounts (
    id                  VARCHAR(24) PRIMARY KEY NOT NULL UNIQUE,
    f_tester_key        VARCHAR(20) NOT NULL UNIQUE,
    firstname           VARCHAR(20) NOT NULL,
    lastname            VARCHAR(20) NOT NULL,
    email               VARCHAR(150) NOT NULL UNIQUE,
    password            VARCHAR(256) NOT NULL,
    public_key          BYTEA NOT NULL,
    private_key         BYTEA NOT NULL,
    roles               TEXT NOT NULL,
    subscription_exp    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    is_banned           BOOLEAN NOT NULL DEFAULT FALSE,
    updated_on          TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    created_on          TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    CONSTRAINT fk_tester_key
        FOREIGN KEY(f_tester_key)
            REFERENCES tester_keys(id)
);


-- Add refferal account
/* CREATE TABLE IF NOT EXISTS account_refferals (
    id          GENERATED BY DEFAULT AS IDENTITY UNIQUE,
    f_owner     TEXT NOT NULL,
    f_refferal  TEXT NOT NULL
); */


CREATE TABLE IF NOT EXISTS passwords (
    id          UUID PRIMARY KEY NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
    f_owner     VARCHAR(24) NOT NULL,
    type        VARCHAR(10) NOT NULL DEFAULT 'basic',
    name        VARCHAR(24) NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    login       VARCHAR(128) DEFAULT NULL,
    password_1  TEXT NOT NULL,
    password_2  TEXT DEFAULT NULL,
    url         VARCHAR(255) DEFAULT NULL,
--    data        JSON NOT NULL, -- '{"name": "N26", "description": "Bank account", "login": "random01", "password": ["root"], "url": "https://app.n26.com/login"}'
    updated_on  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    created_on  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    CONSTRAINT fk_account
        FOREIGN KEY(f_owner)
            REFERENCES accounts(id)
);


CREATE TABLE IF NOT EXISTS tags (
    id          UUID PRIMARY KEY NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
    f_owner     VARCHAR(24) NOT NULL,
    name        VARCHAR(20) NOT NULL,
    color       VARCHAR(8) DEFAULT NULL,
    icon        VARCHAR(40) DEFAULT NULL,
    -- See to add icon in relational table maybe
    CONSTRAINT fk_account
        FOREIGN KEY(f_owner)
            REFERENCES accounts(id)
);


CREATE TABLE IF NOT EXISTS password_tag_linkers (
    id          BIGINT GENERATED BY DEFAULT AS IDENTITY UNIQUE,
    f_password  UUID NOT NULL,
    f_tag       UUID NOT NULL,
    CONSTRAINT fk_password
        FOREIGN KEY(f_password)
            REFERENCES passwords(id),
    CONSTRAINT fk_tag
        FOREIGN KEY(f_tag)
            REFERENCES tags(id),
    CONSTRAINT unq_password_tag
        UNIQUE(f_password, f_tag)
);


CREATE TABLE IF NOT EXISTS auth_token_rsa (
    id          INT GENERATED BY DEFAULT AS IDENTITY UNIQUE,
    type        TEXT NOT NULL UNIQUE,
    public_key  BYTEA NOT NULL,
    private_key BYTEA NOT NULL,
    updated_on  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    created_on  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc')
);