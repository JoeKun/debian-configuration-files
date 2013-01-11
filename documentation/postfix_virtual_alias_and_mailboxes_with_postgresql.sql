-- postfix_virtual_alias_and_mailboxes_with_postgresql.sql
-- Created by Joel Lopes Da Silva on 1/10/2013.

-- This is a very rough list of commands without much in the way of 
-- explanations. Hopefully I can turn this into a nice tutorial someday.


-- su - postgres
-- createuser --no-createdb --no-createrole --no-superuser --encrypted --pwprompt mail
-- createuser --no-createdb --no-createrole --no-superuser --encrypted --pwprompt postfix
-- createdb --owner=mail mail "Mail aliases and accounts information"
-- psql
-- GRANT ALL PRIVILEGES ON DATABASE mail TO mail;
-- \q
-- psql --host=localhost --username=mail --dbname=mail


DROP TABLE IF EXISTS domains;
DROP TABLE IF EXISTS aliases;
DROP TABLE IF EXISTS mailboxes;


CREATE TABLE domains (
    domain      varchar(255) NOT NULL, 
    aliases     boolean      NOT NULL   DEFAULT true, 
    mailboxes   boolean      NOT NULL   DEFAULT false, 
    maxquota    bigint       NOT NULL   DEFAULT 0, 
    active      boolean      NOT NULL   DEFAULT true, 
    created     timestamptz  NOT NULL   DEFAULT current_timestamp, 
    modified    timestamptz  NOT NULL   DEFAULT current_timestamp, 
    PRIMARY KEY (domain)
);

CREATE TABLE aliases (
    source      varchar(255) NOT NULL, 
    destination text         NOT NULL, 
    active      boolean      NOT NULL   DEFAULT true, 
    created     timestamptz  NOT NULL   DEFAULT current_timestamp, 
    modified    timestamptz  NOT NULL   DEFAULT current_timestamp, 
    PRIMARY KEY (source)
);

CREATE TABLE mailboxes (
    address     varchar(255) NOT NULL, 
    password    varchar(255) NOT NULL, 
    quota       bigint       NOT NULL   DEFAULT 0, 
    active      boolean      NOT NULL   DEFAULT true, 
    created     timestamptz  NOT NULL   DEFAULT current_timestamp, 
    modified    timestamptz  NOT NULL   DEFAULT current_timestamp, 
    PRIMARY KEY (address)
);


-- GRANT CONNECT ON DATABASE mail TO postfix;
-- GRANT SELECT ON TABLE domains TO postfix;
-- GRANT SELECT ON TABLE aliases TO postfix;
-- GRANT SELECT ON TABLE mailboxes TO postfix;


INSERT INTO domains (domain, aliases, mailboxes, maxquota) VALUES ('foo.com',          true, false, 0);
INSERT INTO domains (domain, aliases, mailboxes, maxquota) VALUES ('active.foo.com',   true, true,  55);
INSERT INTO domains (domain, aliases, mailboxes, maxquota) VALUES ('disabled.foo.com', true, true,  0);
UPDATE domains SET active = false WHERE domain = 'disabled.foo.com';

INSERT INTO aliases (source, destination) VALUES ('first@foo.com',           'destination-1@bar.org');
INSERT INTO aliases (source, destination) VALUES ('second@foo.com',          'destination-2@bar.org');
INSERT INTO aliases (source, destination) VALUES ('third@foo.com',           'destination-3@bar.org');
INSERT INTO aliases (source, destination) VALUES ('first@active.foo.com',    'destination-1@active.bar.org');
INSERT INTO aliases (source, destination) VALUES ('second@active.foo.com',   'destination-2@active.bar.org');
INSERT INTO aliases (source, destination) VALUES ('third@active.foo.com',    'destination-3@active.bar.org');
INSERT INTO aliases (source, destination) VALUES ('first@disabled.foo.com',  'destination-1@disabled.bar.org');
INSERT INTO aliases (source, destination) VALUES ('second@disabled.foo.com', 'destination-2@disabled.bar.org');
INSERT INTO aliases (source, destination) VALUES ('third@disabled.foo.com',  'destination-3@disabled.bar.org');
UPDATE aliases SET active = false WHERE source = 'second@foo.com';
UPDATE aliases SET active = false WHERE source = 'second@active.foo.com';
UPDATE aliases SET active = false WHERE source = 'second@disabled.foo.com';

INSERT INTO mailboxes (address, password, quota) VALUES ('addr-1@foo.com',          'pass1', 0);
INSERT INTO mailboxes (address, password, quota) VALUES ('addr-2@foo.com',          'pass2', 10);
INSERT INTO mailboxes (address, password, quota) VALUES ('addr-3@foo.com',          'pass3', 60);
INSERT INTO mailboxes (address, password, quota) VALUES ('addr-1@active.foo.com',   'pass1', 0);
INSERT INTO mailboxes (address, password, quota) VALUES ('addr-2@active.foo.com',   'pass2', 10);
INSERT INTO mailboxes (address, password, quota) VALUES ('addr-3@active.foo.com',   'pass3', 60);
INSERT INTO mailboxes (address, password, quota) VALUES ('addr-1@disabled.foo.com', 'pass1', 0);
INSERT INTO mailboxes (address, password, quota) VALUES ('addr-2@disabled.foo.com', 'pass2', 10);
INSERT INTO mailboxes (address, password, quota) VALUES ('addr-3@disabled.foo.com', 'pass3', 60);
UPDATE mailboxes SET active = false WHERE address = 'addr-2@foo.com';
UPDATE mailboxes SET active = false WHERE address = 'addr-2@active.foo.com';
UPDATE mailboxes SET active = false WHERE address = 'addr-2@disabled.foo.com';


-- select active virtual alias domain (tested: OK) /etc/postfix/sql/virtual_alias/domains.cf
-- SELECT domain FROM domains WHERE domain = '%s' AND mailboxes = false AND aliases = true AND active = true;

-- select active alias (tested: OK) /etc/postfix/sql/virtual_alias/maps.cf
-- SELECT destination FROM aliases INNER JOIN domains ON domain = '%d' WHERE source = '%s' AND aliases.active = true AND domains.active = true;

-- select active mailboxes domain (tested: OK) /etc/postfix/sql/virtual_mailbox/domains.cf
-- SELECT domain FROM domains WHERE domain = '%s' AND mailboxes = true AND active = true;

-- select mailbox quota (tested: OK) /etc/postfix/sql/virtual_mailbox/limit_maps.cf
-- SELECT CASE WHEN (SELECT quota FROM mailboxes WHERE address = '%s') = 0 THEN (SELECT maxquota FROM domains WHERE domain = '%d') WHEN (SELECT maxquota FROM domains WHERE domain = '%d') = 0 THEN (SELECT quota FROM mailboxes WHERE address = '%s') ELSE LEAST((SELECT quota FROM mailboxes WHERE address = '%s'), (SELECT maxquota FROM domains WHERE domain = '%d')) END;

-- select mailbox location (tested: OK) /etc/postfix/sql/virtual_mailbox/maps.cf
-- SELECT concat_ws('/', '%d', '%u', 'mail', '') AS mail_directory FROM mailboxes INNER JOIN domains ON domains.domain = '%d' AND domains.active = true AND domains.mailboxes = true WHERE address = '%s' AND mailboxes.active = true;

-- groupadd --gid 114 virtual_mail
-- adduser --system --home /var/mail/virtual --shell /bin/false --no-create-home --uid 114 --ingroup virtual_mail --disabled-password --disabled-login virtual_mail
-- chfn virtual_mail

