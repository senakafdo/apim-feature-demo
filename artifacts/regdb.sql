CREATE Database `regdb`;

USE `regdb`;

SET SQL_MODE = 'ALLOW_INVALID_DATES';

CREATE TABLE IF NOT EXISTS REG_CLUSTER_LOCK (
             REG_LOCK_NAME VARCHAR (20),
             REG_LOCK_STATUS VARCHAR (20),
             REG_LOCKED_TIME TIMESTAMP,
             REG_TENANT_ID INTEGER DEFAULT 0,
             PRIMARY KEY (REG_LOCK_NAME)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS REG_LOG (
             REG_LOG_ID INTEGER AUTO_INCREMENT,
             REG_PATH VARCHAR (750),
             REG_USER_ID VARCHAR (31) NOT NULL,
             REG_LOGGED_TIME TIMESTAMP NOT NULL,
             REG_ACTION INTEGER NOT NULL,
             REG_ACTION_DATA VARCHAR (500),
             REG_TENANT_ID INTEGER DEFAULT 0,
             PRIMARY KEY (REG_LOG_ID, REG_TENANT_ID)
)ENGINE INNODB;

-- The REG_PATH_VALUE should be less than 767 bytes, and hence was fixed at 750.
-- See CARBON-5917.

CREATE TABLE IF NOT EXISTS REG_PATH(
             REG_PATH_ID INTEGER NOT NULL AUTO_INCREMENT,
             REG_PATH_VALUE VARCHAR(750) NOT NULL,
             REG_PATH_PARENT_ID INTEGER,
             REG_TENANT_ID INTEGER DEFAULT 0,
             CONSTRAINT PK_REG_PATH PRIMARY KEY(REG_PATH_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE INDEX REG_PATH_IND_BY_PATH_VALUE USING HASH ON REG_PATH(REG_PATH_VALUE, REG_TENANT_ID);
CREATE INDEX REG_PATH_IND_BY_PATH_PARENT_ID USING HASH ON REG_PATH(REG_PATH_PARENT_ID, REG_TENANT_ID);

CREATE TABLE IF NOT EXISTS REG_CONTENT (
             REG_CONTENT_ID INTEGER NOT NULL AUTO_INCREMENT,
             REG_CONTENT_DATA LONGBLOB,
             REG_TENANT_ID INTEGER DEFAULT 0,
             CONSTRAINT PK_REG_CONTENT PRIMARY KEY(REG_CONTENT_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS REG_CONTENT_HISTORY (
             REG_CONTENT_ID INTEGER NOT NULL,
             REG_CONTENT_DATA LONGBLOB,
             REG_DELETED   SMALLINT,
             REG_TENANT_ID INTEGER DEFAULT 0,
             CONSTRAINT PK_REG_CONTENT_HISTORY PRIMARY KEY(REG_CONTENT_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS REG_RESOURCE (
            REG_PATH_ID         INTEGER NOT NULL,
            REG_NAME            VARCHAR(256),
            REG_VERSION         INTEGER NOT NULL AUTO_INCREMENT,
            REG_MEDIA_TYPE      VARCHAR(500),
            REG_CREATOR         VARCHAR(31) NOT NULL,
            REG_CREATED_TIME    TIMESTAMP NOT NULL DEFAULT 0,
            REG_LAST_UPDATOR    VARCHAR(31),
            REG_LAST_UPDATED_TIME    TIMESTAMP NOT NULL DEFAULT 0,
            REG_DESCRIPTION     VARCHAR(1000),
            REG_CONTENT_ID      INTEGER,
            REG_TENANT_ID INTEGER DEFAULT 0,
            REG_UUID VARCHAR(100) NOT NULL,
            CONSTRAINT PK_REG_RESOURCE PRIMARY KEY(REG_VERSION, REG_TENANT_ID)
)ENGINE INNODB;

ALTER TABLE REG_RESOURCE ADD CONSTRAINT REG_RESOURCE_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
ALTER TABLE REG_RESOURCE ADD CONSTRAINT REG_RESOURCE_FK_BY_CONTENT_ID FOREIGN KEY (REG_CONTENT_ID, REG_TENANT_ID) REFERENCES REG_CONTENT (REG_CONTENT_ID, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_IND_BY_NAME USING HASH ON REG_RESOURCE(REG_NAME, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_IND_BY_PATH_ID_NAME USING HASH ON REG_RESOURCE(REG_PATH_ID, REG_NAME, REG_TENANT_ID);

CREATE TABLE IF NOT EXISTS REG_RESOURCE_HISTORY (
            REG_PATH_ID         INTEGER NOT NULL,
            REG_NAME            VARCHAR(256),
            REG_VERSION         INTEGER NOT NULL,
            REG_MEDIA_TYPE      VARCHAR(500),
            REG_CREATOR         VARCHAR(31) NOT NULL,
            REG_CREATED_TIME    TIMESTAMP NOT NULL,
            REG_LAST_UPDATOR    VARCHAR(31),
            REG_LAST_UPDATED_TIME    TIMESTAMP NOT NULL,
            REG_DESCRIPTION     VARCHAR(1000),
            REG_CONTENT_ID      INTEGER,
            REG_DELETED         SMALLINT,
            REG_TENANT_ID INTEGER DEFAULT 0,
            REG_UUID VARCHAR(100) NOT NULL,
            CONSTRAINT PK_REG_RESOURCE_HISTORY PRIMARY KEY(REG_VERSION, REG_TENANT_ID)
)ENGINE INNODB;

ALTER TABLE REG_RESOURCE_HISTORY ADD CONSTRAINT REG_RESOURCE_HIST_FK_BY_PATHID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
ALTER TABLE REG_RESOURCE_HISTORY ADD CONSTRAINT REG_RESOURCE_HIST_FK_BY_CONTENT_ID FOREIGN KEY (REG_CONTENT_ID, REG_TENANT_ID) REFERENCES REG_CONTENT_HISTORY (REG_CONTENT_ID, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_HISTORY_IND_BY_NAME USING HASH ON REG_RESOURCE_HISTORY(REG_NAME, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_HISTORY_IND_BY_PATH_ID_NAME USING HASH ON REG_RESOURCE(REG_PATH_ID, REG_NAME, REG_TENANT_ID);

CREATE TABLE IF NOT EXISTS REG_COMMENT (
            REG_ID        INTEGER NOT NULL AUTO_INCREMENT,
            REG_COMMENT_TEXT      VARCHAR(500) NOT NULL,
            REG_USER_ID           VARCHAR(31) NOT NULL,
            REG_COMMENTED_TIME    TIMESTAMP NOT NULL,
            REG_TENANT_ID INTEGER DEFAULT 0,
            CONSTRAINT PK_REG_COMMENT PRIMARY KEY(REG_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS REG_RESOURCE_COMMENT (
            REG_COMMENT_ID          INTEGER NOT NULL,
            REG_VERSION             INTEGER,
            REG_PATH_ID             INTEGER,
            REG_RESOURCE_NAME       VARCHAR(256),
            REG_TENANT_ID INTEGER DEFAULT 0
)ENGINE INNODB;

ALTER TABLE REG_RESOURCE_COMMENT ADD CONSTRAINT REG_RESOURCE_COMMENT_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
ALTER TABLE REG_RESOURCE_COMMENT ADD CONSTRAINT REG_RESOURCE_COMMENT_FK_BY_COMMENT_ID FOREIGN KEY (REG_COMMENT_ID, REG_TENANT_ID) REFERENCES REG_COMMENT (REG_ID, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_COMMENT_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_COMMENT(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_COMMENT_IND_BY_VERSION USING HASH ON REG_RESOURCE_COMMENT(REG_VERSION, REG_TENANT_ID);

CREATE TABLE IF NOT EXISTS REG_RATING (
            REG_ID     INTEGER NOT NULL AUTO_INCREMENT,
            REG_RATING        INTEGER NOT NULL,
            REG_USER_ID       VARCHAR(31) NOT NULL,
            REG_RATED_TIME    TIMESTAMP NOT NULL,
            REG_TENANT_ID INTEGER DEFAULT 0,
            CONSTRAINT PK_REG_RATING PRIMARY KEY(REG_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS REG_RESOURCE_RATING (
            REG_RATING_ID           INTEGER NOT NULL,
            REG_VERSION             INTEGER,
            REG_PATH_ID             INTEGER,
            REG_RESOURCE_NAME       VARCHAR(256),
            REG_TENANT_ID INTEGER DEFAULT 0
)ENGINE INNODB;

ALTER TABLE REG_RESOURCE_RATING ADD CONSTRAINT REG_RESOURCE_RATING_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
ALTER TABLE REG_RESOURCE_RATING ADD CONSTRAINT REG_RESOURCE_RATING_FK_BY_RATING_ID FOREIGN KEY (REG_RATING_ID, REG_TENANT_ID) REFERENCES REG_RATING (REG_ID, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_RATING_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_RATING(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_RATING_IND_BY_VERSION USING HASH ON REG_RESOURCE_RATING(REG_VERSION, REG_TENANT_ID);


CREATE TABLE IF NOT EXISTS REG_TAG (
            REG_ID         INTEGER NOT NULL AUTO_INCREMENT,
            REG_TAG_NAME       VARCHAR(500) NOT NULL,
            REG_USER_ID        VARCHAR(31) NOT NULL,
            REG_TAGGED_TIME    TIMESTAMP NOT NULL,
            REG_TENANT_ID INTEGER DEFAULT 0,
            CONSTRAINT PK_REG_TAG PRIMARY KEY(REG_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS REG_RESOURCE_TAG (
            REG_TAG_ID              INTEGER NOT NULL,
            REG_VERSION             INTEGER,
            REG_PATH_ID             INTEGER,
            REG_RESOURCE_NAME       VARCHAR(256),
            REG_TENANT_ID INTEGER DEFAULT 0
)ENGINE INNODB;

ALTER TABLE REG_RESOURCE_TAG ADD CONSTRAINT REG_RESOURCE_TAG_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
ALTER TABLE REG_RESOURCE_TAG ADD CONSTRAINT REG_RESOURCE_TAG_FK_BY_TAG_ID FOREIGN KEY (REG_TAG_ID, REG_TENANT_ID) REFERENCES REG_TAG (REG_ID, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_TAG_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_TAG(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_TAG_IND_BY_VERSION USING HASH ON REG_RESOURCE_TAG(REG_VERSION, REG_TENANT_ID);

CREATE TABLE IF NOT EXISTS REG_PROPERTY (
            REG_ID         INTEGER NOT NULL AUTO_INCREMENT,
            REG_NAME       VARCHAR(100) NOT NULL,
            REG_VALUE        VARCHAR(1000),
            REG_TENANT_ID INTEGER DEFAULT 0,
            CONSTRAINT PK_REG_PROPERTY PRIMARY KEY(REG_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS REG_RESOURCE_PROPERTY (
            REG_PROPERTY_ID         INTEGER NOT NULL,
            REG_VERSION             INTEGER,
            REG_PATH_ID             INTEGER,
            REG_RESOURCE_NAME       VARCHAR(256),
            REG_TENANT_ID INTEGER DEFAULT 0
)ENGINE INNODB;

ALTER TABLE REG_RESOURCE_PROPERTY ADD CONSTRAINT REG_RESOURCE_PROPERTY_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);
ALTER TABLE REG_RESOURCE_PROPERTY ADD CONSTRAINT REG_RESOURCE_PROPERTY_FK_BY_TAG_ID FOREIGN KEY (REG_PROPERTY_ID, REG_TENANT_ID) REFERENCES REG_PROPERTY (REG_ID, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_PROPERTY_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_RESOURCE_PROPERTY(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);
CREATE INDEX REG_RESOURCE_PROPERTY_IND_BY_VERSION USING HASH ON REG_RESOURCE_PROPERTY(REG_VERSION, REG_TENANT_ID);

-- CREATE TABLE IF NOT EXISTS REG_ASSOCIATIONS (
-- SRC_PATH_ID     INTEGER,
-- SRC_RESOURCE_NAME    VARCHAR(256),
-- SRC_VERSION     INTEGER,
-- TGT_PATH_ID     INTEGER,
-- TGT_RESOURCE_NAME    VARCHAR(256),
-- TGT_VERSION     INTEGER
-- )ENGINE INNODB;
-- 
-- ALTER TABLE REG_ASSOCIATIONS ADD CONSTRAINT REG_ASSOCIATIONS_FK_BY_SRC_PATH_ID FOREIGN KEY (SRC_PATH_ID) REFERENCES REG_PATH (PATH_ID);
-- ALTER TABLE REG_ASSOCIATIONS ADD CONSTRAINT REG_ASSOCIATIONS_FK_BY_TGT_PATH_ID FOREIGN KEY (TGT_PATH_ID) REFERENCES REG_PATH (PATH_ID);
-- CREATE INDEX REG_ASSOCIATIONS_IND_BY_SRC_VERSION ON REG_ASSOCIATIONS(SRC_VERSION);
-- CREATE INDEX REG_ASSOCIATIONS_IND_BY_TGT_VERSION ON REG_ASSOCIATIONS(TGT_VERSION);
-- CREATE INDEX REG_ASSOCIATIONS_IND_BY_SRC_RESOURCE_NAME ON REG_ASSOCIATIONS(SRC_RESOURCE_NAME);
-- CREATE INDEX REG_ASSOCIATIONS_IND_BY_TGT_RESOURCE_NAME ON REG_ASSOCIATIONS(TGT_RESOURCE_NAME);



CREATE TABLE IF NOT EXISTS REG_ASSOCIATION (
            REG_ASSOCIATION_ID INTEGER AUTO_INCREMENT,
            REG_SOURCEPATH VARCHAR (750) NOT NULL,
            REG_TARGETPATH VARCHAR (750) NOT NULL,
            REG_ASSOCIATION_TYPE VARCHAR (2000) NOT NULL,
            REG_TENANT_ID INTEGER DEFAULT 0,
            PRIMARY KEY (REG_ASSOCIATION_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE IF NOT EXISTS REG_SNAPSHOT (
            REG_SNAPSHOT_ID     INTEGER NOT NULL AUTO_INCREMENT,
            REG_PATH_ID            INTEGER NOT NULL,
            REG_RESOURCE_NAME      VARCHAR(255),
            REG_RESOURCE_VIDS     LONGBLOB NOT NULL,
            REG_TENANT_ID INTEGER DEFAULT 0,
            CONSTRAINT PK_REG_SNAPSHOT PRIMARY KEY(REG_SNAPSHOT_ID, REG_TENANT_ID)
)ENGINE INNODB;

CREATE INDEX REG_SNAPSHOT_IND_BY_PATH_ID_AND_RESOURCE_NAME USING HASH ON REG_SNAPSHOT(REG_PATH_ID, REG_RESOURCE_NAME, REG_TENANT_ID);

ALTER TABLE REG_SNAPSHOT ADD CONSTRAINT REG_SNAPSHOT_FK_BY_PATH_ID FOREIGN KEY (REG_PATH_ID, REG_TENANT_ID) REFERENCES REG_PATH (REG_PATH_ID, REG_TENANT_ID);


-- ################################
-- USER MANAGER TABLES
-- ################################

CREATE TABLE UM_TENANT (
			UM_ID INTEGER NOT NULL AUTO_INCREMENT,
	        UM_DOMAIN_NAME VARCHAR(255) NOT NULL,
            UM_EMAIL VARCHAR(255),
            UM_ACTIVE BOOLEAN DEFAULT FALSE,
	        UM_CREATED_DATE TIMESTAMP NOT NULL,
	        UM_USER_CONFIG LONGBLOB,
			PRIMARY KEY (UM_ID),
			UNIQUE(UM_DOMAIN_NAME)
)ENGINE INNODB;

CREATE TABLE UM_DOMAIN(
            UM_DOMAIN_ID INTEGER NOT NULL AUTO_INCREMENT,
            UM_DOMAIN_NAME VARCHAR(255),
            UM_TENANT_ID INTEGER DEFAULT 0,
            PRIMARY KEY (UM_DOMAIN_ID, UM_TENANT_ID)
)ENGINE INNODB;

CREATE UNIQUE INDEX INDEX_UM_TENANT_UM_DOMAIN_NAME
                    ON UM_TENANT (UM_DOMAIN_NAME); 

CREATE TABLE UM_USER ( 
             UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
             UM_USER_NAME VARCHAR(255) NOT NULL, 
             UM_USER_PASSWORD VARCHAR(255) NOT NULL,
             UM_SALT_VALUE VARCHAR(31),
             UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
             UM_CHANGED_TIME TIMESTAMP NOT NULL,
             UM_TENANT_ID INTEGER DEFAULT 0, 
             PRIMARY KEY (UM_ID, UM_TENANT_ID), 
             UNIQUE(UM_USER_NAME, UM_TENANT_ID)
)ENGINE INNODB; 

CREATE TABLE UM_SYSTEM_USER ( 
             UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
             UM_USER_NAME VARCHAR(255) NOT NULL, 
             UM_USER_PASSWORD VARCHAR(255) NOT NULL,
             UM_SALT_VALUE VARCHAR(31),
             UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
             UM_CHANGED_TIME TIMESTAMP NOT NULL,
             UM_TENANT_ID INTEGER DEFAULT 0, 
             PRIMARY KEY (UM_ID, UM_TENANT_ID), 
             UNIQUE(UM_USER_NAME, UM_TENANT_ID)
)ENGINE INNODB; 

CREATE TABLE UM_ROLE ( 
             UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
             UM_ROLE_NAME VARCHAR(255) NOT NULL,
             UM_TENANT_ID INTEGER DEFAULT 0,
		UM_SHARED_ROLE BOOLEAN DEFAULT FALSE,  
             PRIMARY KEY (UM_ID, UM_TENANT_ID),
             UNIQUE(UM_ROLE_NAME, UM_TENANT_ID) 
)ENGINE INNODB;


CREATE TABLE UM_MODULE(
	UM_ID INTEGER  NOT NULL AUTO_INCREMENT,
	UM_MODULE_NAME VARCHAR(100),
	UNIQUE(UM_MODULE_NAME),
	PRIMARY KEY(UM_ID)
)ENGINE INNODB;

CREATE TABLE UM_MODULE_ACTIONS(
	UM_ACTION VARCHAR(255) NOT NULL,
	UM_MODULE_ID INTEGER NOT NULL,
	PRIMARY KEY(UM_ACTION, UM_MODULE_ID),
	FOREIGN KEY (UM_MODULE_ID) REFERENCES UM_MODULE(UM_ID) ON DELETE CASCADE
)ENGINE INNODB;

CREATE TABLE UM_PERMISSION ( 
             UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
             UM_RESOURCE_ID VARCHAR(255) NOT NULL, 
             UM_ACTION VARCHAR(255) NOT NULL, 
             UM_TENANT_ID INTEGER DEFAULT 0, 
		UM_MODULE_ID INTEGER DEFAULT 0,
             PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB; 

CREATE INDEX INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION ON UM_PERMISSION (UM_RESOURCE_ID, UM_ACTION, UM_TENANT_ID);

CREATE TABLE UM_ROLE_PERMISSION ( 
             UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
             UM_PERMISSION_ID INTEGER NOT NULL, 
             UM_ROLE_NAME VARCHAR(255) NOT NULL,
             UM_IS_ALLOWED SMALLINT NOT NULL, 
             UM_TENANT_ID INTEGER DEFAULT 0,
	     UM_DOMAIN_ID INTEGER, 
             UNIQUE (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID),
	     FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
	     FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE, 
             PRIMARY KEY (UM_ID, UM_TENANT_ID) 
)ENGINE INNODB; 

-- REMOVED UNIQUE (UM_PERMISSION_ID, UM_ROLE_ID) 
CREATE TABLE UM_USER_PERMISSION ( 
             UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
             UM_PERMISSION_ID INTEGER NOT NULL, 
             UM_USER_NAME VARCHAR(255) NOT NULL,
             UM_IS_ALLOWED SMALLINT NOT NULL,          
             UM_TENANT_ID INTEGER DEFAULT 0, 
             FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
             PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB;

-- REMOVED UNIQUE (UM_PERMISSION_ID, UM_USER_ID) 
CREATE TABLE UM_USER_ROLE ( 
             UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
             UM_ROLE_ID INTEGER NOT NULL, 
             UM_USER_ID INTEGER NOT NULL,
             UM_TENANT_ID INTEGER DEFAULT 0,  
             UNIQUE (UM_USER_ID, UM_ROLE_ID, UM_TENANT_ID), 
             FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_ROLE(UM_ID, UM_TENANT_ID), 
             FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID), 
             PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB; 

CREATE TABLE UM_SHARED_USER_ROLE(
    UM_ROLE_ID INTEGER NOT NULL,
    UM_USER_ID INTEGER NOT NULL,
    UM_USER_TENANT_ID INTEGER NOT NULL,
    UM_ROLE_TENANT_ID INTEGER NOT NULL,
    UNIQUE(UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID),
    FOREIGN KEY(UM_ROLE_ID,UM_ROLE_TENANT_ID) REFERENCES UM_ROLE(UM_ID,UM_TENANT_ID) ON DELETE CASCADE,
    FOREIGN KEY(UM_USER_ID,UM_USER_TENANT_ID) REFERENCES UM_USER(UM_ID,UM_TENANT_ID) ON DELETE CASCADE
)ENGINE INNODB;

CREATE TABLE UM_ACCOUNT_MAPPING(
	UM_ID INTEGER NOT NULL AUTO_INCREMENT,
	UM_USER_NAME VARCHAR(255) NOT NULL,
	UM_TENANT_ID INTEGER NOT NULL,
	UM_USER_STORE_DOMAIN VARCHAR(100),
	UM_ACC_LINK_ID INTEGER NOT NULL,
	UNIQUE(UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),
	FOREIGN KEY (UM_TENANT_ID) REFERENCES UM_TENANT(UM_ID) ON DELETE CASCADE,
	PRIMARY KEY (UM_ID)
)ENGINE INNODB;


CREATE TABLE UM_USER_ATTRIBUTE ( 
            UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
            UM_ATTR_NAME VARCHAR(255) NOT NULL, 
            UM_ATTR_VALUE VARCHAR(1024), 
            UM_PROFILE_ID VARCHAR(255), 
            UM_USER_ID INTEGER, 
            UM_TENANT_ID INTEGER DEFAULT 0, 
            FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID), 
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB; 



CREATE TABLE UM_DIALECT( 
            UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
            UM_DIALECT_URI VARCHAR(255) NOT NULL, 
            UM_TENANT_ID INTEGER DEFAULT 0, 
            UNIQUE(UM_DIALECT_URI, UM_TENANT_ID), 
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB; 

CREATE TABLE UM_CLAIM( 
            UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
            UM_DIALECT_ID INTEGER NOT NULL, 
            UM_CLAIM_URI VARCHAR(255) NOT NULL, 
            UM_DISPLAY_TAG VARCHAR(255), 
            UM_DESCRIPTION VARCHAR(255), 
            UM_MAPPED_ATTRIBUTE_DOMAIN VARCHAR(255),
            UM_MAPPED_ATTRIBUTE VARCHAR(255), 
            UM_REG_EX VARCHAR(255), 
            UM_SUPPORTED SMALLINT, 
            UM_REQUIRED SMALLINT, 
            UM_DISPLAY_ORDER INTEGER,
	    UM_CHECKED_ATTRIBUTE SMALLINT,
            UM_READ_ONLY SMALLINT,
            UM_TENANT_ID INTEGER DEFAULT 0, 
            UNIQUE(UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN), 
            FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID), 
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB; 


CREATE TABLE UM_PROFILE_CONFIG( 
            UM_ID INTEGER NOT NULL AUTO_INCREMENT, 
            UM_DIALECT_ID INTEGER NOT NULL, 
            UM_PROFILE_NAME VARCHAR(255), 
            UM_TENANT_ID INTEGER DEFAULT 0, 
            FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID), 
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB; 
    

CREATE TABLE UM_HYBRID_ROLE(
            UM_ID INTEGER NOT NULL AUTO_INCREMENT,
            UM_ROLE_NAME VARCHAR(255),
            UM_TENANT_ID INTEGER DEFAULT 0,
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE UM_HYBRID_USER_ROLE(
            UM_ID INTEGER NOT NULL AUTO_INCREMENT,
            UM_USER_NAME VARCHAR(255),
            UM_ROLE_ID INTEGER NOT NULL,
            UM_TENANT_ID INTEGER DEFAULT 0,
	    UM_DOMAIN_ID INTEGER,
            UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID),
            FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_HYBRID_ROLE(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
	    FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE UM_SYSTEM_ROLE(
            UM_ID INTEGER NOT NULL AUTO_INCREMENT,
            UM_ROLE_NAME VARCHAR(255),
            UM_TENANT_ID INTEGER DEFAULT 0,
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB;

CREATE TABLE UM_SYSTEM_USER_ROLE(
            UM_ID INTEGER NOT NULL AUTO_INCREMENT,
            UM_USER_NAME VARCHAR(255),
            UM_ROLE_ID INTEGER NOT NULL,
            UM_TENANT_ID INTEGER DEFAULT 0,
            UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),
            FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),
            PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB;


CREATE TABLE UM_HYBRID_REMEMBER_ME(
            UM_ID INTEGER NOT NULL AUTO_INCREMENT,
			UM_USER_NAME VARCHAR(255) NOT NULL,
			UM_COOKIE_VALUE VARCHAR(1024),
			UM_CREATED_TIME TIMESTAMP,
            UM_TENANT_ID INTEGER DEFAULT 0,
			PRIMARY KEY (UM_ID, UM_TENANT_ID)
)ENGINE INNODB;