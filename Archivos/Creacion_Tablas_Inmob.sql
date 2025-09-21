-- =========================
-- Setup
-- =========================
SET NAMES utf8mb4;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS negocio_inmob;
CREATE SCHEMA negocio_inmob DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE negocio_inmob;

-- =========================
-- Catálogos / Tablas de referencia
-- =========================
CREATE TABLE provincia (
  cod_provincia VARCHAR(10) NOT NULL PRIMARY KEY,
  provincia     VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE status (
  cod_status   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  status_desc  VARCHAR(50)  NOT NULL
) ENGINE=InnoDB;

CREATE TABLE tipo_persona (
  cod_tipo_persona TINYINT UNSIGNED NOT NULL PRIMARY KEY,
  persona_desc     VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE tipo_doc (
  cod_tipo_doc  TINYINT UNSIGNED NOT NULL PRIMARY KEY,
  doc_desc      VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE concepto (
  cod_concepto  INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  concepto_desc VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE tipo_amenities (
  amenities_id   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  amenities_desc VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

-- Cuenta de facturación (centralizada)
CREATE TABLE cuenta_factura (
  cod_factura_cuenta INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  alias_cuenta       VARCHAR(60) NULL,
  cuit               VARCHAR(15) NULL,
  cbu                VARCHAR(34) NULL,
  alias_mp           VARCHAR(40) NULL
) ENGINE=InnoDB;

-- =========================
-- Dirección
-- =========================
CREATE TABLE direccion (
  direccion_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  calle        VARCHAR(120) NOT NULL,
  numero       VARCHAR(10)  NOT NULL,
  piso         VARCHAR(5)   NULL,
  depto        VARCHAR(10)  NULL,
  barrio       VARCHAR(80)  NULL,
  localidad    VARCHAR(80)  NOT NULL,
  cod_provincia VARCHAR(10) NOT NULL,
  cod_postal   VARCHAR(10)  NULL,
  lat          DECIMAL(9,6) NULL,
  lng          DECIMAL(9,6) NULL,
  CONSTRAINT fk_direccion_provincia
    FOREIGN KEY (cod_provincia) REFERENCES provincia(cod_provincia)
) ENGINE=InnoDB;

-- =========================
-- Personas
-- =========================
CREATE TABLE propietario (
  propietario_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cod_tipo_persona  TINYINT UNSIGNED NOT NULL,
  nombre            VARCHAR(100) NOT NULL,
  apellido          VARCHAR(100) NOT NULL,
  email             VARCHAR(255) NOT NULL,
  telefono          VARCHAR(25)  NOT NULL,
  cod_tipo_doc      TINYINT UNSIGNED NOT NULL,
  nro_doc           VARCHAR(20)  NOT NULL,
  direccion_id      INT UNSIGNED NOT NULL,
  fecha_alta        DATE NOT NULL DEFAULT (CURRENT_DATE),
  activo            BOOLEAN NOT NULL DEFAULT TRUE,
  cod_factura_cuenta INT UNSIGNED NULL,
  PRIMARY KEY (propietario_id),
  UNIQUE KEY uq_propietario_doc (cod_tipo_doc, nro_doc),
  UNIQUE KEY uq_propietario_email (email),
  KEY idx_propietario_direccion (direccion_id),
  KEY idx_propietario_cuenta (cod_factura_cuenta),
  CONSTRAINT fk_propietario_tipo_persona
    FOREIGN KEY (cod_tipo_persona) REFERENCES tipo_persona(cod_tipo_persona),
  CONSTRAINT fk_propietario_tipo_doc
    FOREIGN KEY (cod_tipo_doc) REFERENCES tipo_doc(cod_tipo_doc),
  CONSTRAINT fk_propietario_direccion
    FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id),
  CONSTRAINT fk_propietario_cuenta
    FOREIGN KEY (cod_factura_cuenta) REFERENCES cuenta_factura(cod_factura_cuenta)
) ENGINE=InnoDB;

CREATE TABLE cliente (
  cliente_id        INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  cod_tipo_persona  TINYINT UNSIGNED NOT NULL,
  nombre            VARCHAR(100) NOT NULL,
  apellido          VARCHAR(100) NOT NULL,
  email             VARCHAR(255) NOT NULL,
  telefono          VARCHAR(25)  NOT NULL,
  cod_tipo_doc      TINYINT UNSIGNED NOT NULL,
  nro_doc           VARCHAR(20)  NOT NULL,
  direccion_id      INT UNSIGNED NOT NULL,
  fecha_alta        DATE NOT NULL DEFAULT (CURRENT_DATE),
  activo            BOOLEAN NOT NULL DEFAULT TRUE,
  cod_factura_cuenta INT UNSIGNED NULL,
  UNIQUE KEY uq_cliente_doc (cod_tipo_doc, nro_doc),
  UNIQUE KEY uq_cliente_email (email),
  KEY idx_cliente_direccion (direccion_id),
  KEY idx_cliente_cuenta (cod_factura_cuenta),
  CONSTRAINT fk_cliente_tipo_persona
    FOREIGN KEY (cod_tipo_persona) REFERENCES tipo_persona(cod_tipo_persona),
  CONSTRAINT fk_cliente_tipo_doc
    FOREIGN KEY (cod_tipo_doc) REFERENCES tipo_doc(cod_tipo_doc),
  CONSTRAINT fk_cliente_direccion
    FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id),
  CONSTRAINT fk_cliente_cuenta
    FOREIGN KEY (cod_factura_cuenta) REFERENCES cuenta_factura(cod_factura_cuenta)
) ENGINE=InnoDB;

CREATE TABLE agente (
  agente_id         INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  cod_tipo_persona  TINYINT UNSIGNED NOT NULL,
  nombre            VARCHAR(100) NOT NULL,
  apellido          VARCHAR(100) NOT NULL,
  email             VARCHAR(255) NOT NULL,
  telefono          VARCHAR(25)  NOT NULL,
  cod_tipo_doc      TINYINT UNSIGNED NOT NULL,
  nro_doc           VARCHAR(20)  NOT NULL,
  direccion_id      INT UNSIGNED NOT NULL,
  fecha_alta        DATE NOT NULL DEFAULT (CURRENT_DATE),
  activo            BOOLEAN NOT NULL DEFAULT TRUE,
  cod_factura_cuenta INT UNSIGNED NULL,
  UNIQUE KEY uq_agente_doc (cod_tipo_doc, nro_doc),
  UNIQUE KEY uq_agente_email (email),
  KEY idx_agente_direccion (direccion_id),
  KEY idx_agente_cuenta (cod_factura_cuenta),
  CONSTRAINT fk_agente_tipo_persona
    FOREIGN KEY (cod_tipo_persona) REFERENCES tipo_persona(cod_tipo_persona),
  CONSTRAINT fk_agente_tipo_doc
    FOREIGN KEY (cod_tipo_doc) REFERENCES tipo_doc(cod_tipo_doc),
  CONSTRAINT fk_agente_direccion
    FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id),
  CONSTRAINT fk_agente_cuenta
    FOREIGN KEY (cod_factura_cuenta) REFERENCES cuenta_factura(cod_factura_cuenta)
) ENGINE=InnoDB;

-- =========================
-- Propiedad
-- =========================
CREATE TABLE propiedad (
  propiedad_id   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  cod_tipo_prop  TINYINT UNSIGNED NOT NULL,         -- catálogo opcional
  direccion_id   INT UNSIGNED NOT NULL,
  anio_constr    SMALLINT UNSIGNED NULL,
  sup_total_m2   DECIMAL(10,2) NULL,
  propietario_id INT UNSIGNED NOT NULL,
  cod_unidad     VARCHAR(20) NULL,                  -- si aplicara (ej. "2B")
  uso            ENUM('residencial','comercial') NOT NULL,
  ambientes      TINYINT UNSIGNED NULL,
  banios         TINYINT UNSIGNED NULL,
  sup_cub_m2     DECIMAL(10,2) NULL,
  sup_des_m2     DECIMAL(10,2) NULL,
  expensas       DECIMAL(12,2) NULL,
  amoblado       BOOLEAN NOT NULL DEFAULT FALSE,
  disponible     BOOLEAN NOT NULL DEFAULT TRUE,
  cod_status     INT UNSIGNED NOT NULL,
  CONSTRAINT fk_propiedad_direccion
    FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id),
  CONSTRAINT fk_propiedad_propietario
    FOREIGN KEY (propietario_id) REFERENCES propietario(propietario_id),
  CONSTRAINT fk_propiedad_status
    FOREIGN KEY (cod_status) REFERENCES status(cod_status),
  KEY idx_propiedad_busqueda (uso, disponible, ambientes, sup_cub_m2, expensas)
) ENGINE=InnoDB;

-- N:N propiedad-amenities
CREATE TABLE propiedad_amenity (
  propiedad_id INT UNSIGNED NOT NULL,
  amenities_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (propiedad_id, amenities_id),
  CONSTRAINT fk_prop_amen_prop
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
  CONSTRAINT fk_prop_amen_amen
    FOREIGN KEY (amenities_id) REFERENCES tipo_amenities(amenities_id)
) ENGINE=InnoDB;

-- =========================
-- Operación comercial
-- =========================
CREATE TABLE consulta (
  consulta_id     INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  propiedad_id    INT UNSIGNED NOT NULL,
  cliente_id      INT UNSIGNED NOT NULL,
  origen          VARCHAR(50) NOT NULL, -- web, telefono, portalX, etc.
  mensaje         TEXT NOT NULL,
  fecha_consulta  DATETIME NOT NULL,
  estado          VARCHAR(30) NOT NULL,
  KEY idx_consulta_propiedad (propiedad_id),
  KEY idx_consulta_cliente (cliente_id),
  CONSTRAINT fk_consulta_propiedad
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
  CONSTRAINT fk_consulta_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
) ENGINE=InnoDB;

CREATE TABLE visita (
  visita_id    INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  fecha_hora   DATETIME NOT NULL,
  propiedad_id INT UNSIGNED NOT NULL,
  cliente_id   INT UNSIGNED NOT NULL,
  agente_id    INT UNSIGNED NOT NULL,
  resultado    VARCHAR(30) NOT NULL,
  notas        TEXT NULL,
  KEY idx_visita_propiedad (propiedad_id),
  KEY idx_visita_cliente (cliente_id),
  KEY idx_visita_agente (agente_id),
  CONSTRAINT fk_visita_propiedad
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
  CONSTRAINT fk_visita_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),
  CONSTRAINT fk_visita_agente
    FOREIGN KEY (agente_id) REFERENCES agente(agente_id)
) ENGINE=InnoDB;

CREATE TABLE oferta_solicitud (
  oferta_id     INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  propiedad_id  INT UNSIGNED NOT NULL,
  cliente_id    INT UNSIGNED NOT NULL,
  monto         DECIMAL(12,2) NOT NULL,
  moneda        CHAR(3) NOT NULL, -- ARS/USD
  condiciones   TEXT NULL,
  estado        VARCHAR(30) NOT NULL, -- enviada, aceptada, rechazada, etc.
  fecha         DATE NOT NULL,
  agente_id     INT UNSIGNED NOT NULL,
  KEY idx_oferta_propiedad_cliente (propiedad_id, cliente_id),
  CONSTRAINT fk_oferta_propiedad
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
  CONSTRAINT fk_oferta_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),
  CONSTRAINT fk_oferta_agente
    FOREIGN KEY (agente_id) REFERENCES agente(agente_id)
) ENGINE=InnoDB;

CREATE TABLE contrato (
  contrato_id   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  tipo_contrato ENUM('alquiler','compraventa','temporal') NOT NULL,
  propiedad_id  INT UNSIGNED NOT NULL,
  propietario_id INT UNSIGNED NOT NULL,
  cliente_id    INT UNSIGNED NOT NULL,
  fecha_inicio  DATE NOT NULL,
  fecha_fin     DATE NULL,
  precio        DECIMAL(12,2) NOT NULL,
  moneda        CHAR(3) NOT NULL,
  estado        VARCHAR(30) NOT NULL, -- vigente, finalizado, rescindido
  archivo_url   VARCHAR(1024) NULL,
  KEY idx_contrato_propietario (propietario_id),
  KEY idx_contrato_cliente (cliente_id),
  CONSTRAINT fk_contrato_propiedad
    FOREIGN KEY (propiedad_id) REFERENCES propiedad(propiedad_id),
  CONSTRAINT fk_contrato_propietario
    FOREIGN KEY (propietario_id) REFERENCES propietario(propietario_id),
  CONSTRAINT fk_contrato_cliente
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
) ENGINE=InnoDB;

-- =========================
-- Facturación / Pagos
-- =========================
CREATE TABLE facturacion (
  facturacion_id     INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  contrato_id        INT UNSIGNED NOT NULL,
  periodo            CHAR(7) NOT NULL,            -- 'YYYY-MM'
  cod_concepto       INT UNSIGNED NOT NULL,
  importe            DECIMAL(12,2) NOT NULL,
  moneda             CHAR(3) NOT NULL,
  estado             VARCHAR(20) NOT NULL,        -- emitida, pagada, vencida, etc.
  fecha              DATE NOT NULL,
  medio              VARCHAR(30) NOT NULL,        -- transferencia, MP, etc.
  cod_factura_cuenta INT UNSIGNED NOT NULL,
  KEY idx_facturacion_contrato (contrato_id),
  KEY idx_facturacion_periodo (periodo),
  KEY idx_facturacion_cuenta (cod_factura_cuenta),
  CONSTRAINT fk_facturacion_contrato
    FOREIGN KEY (contrato_id) REFERENCES contrato(contrato_id),
  CONSTRAINT fk_facturacion_concepto
    FOREIGN KEY (cod_concepto) REFERENCES concepto(cod_concepto),
  CONSTRAINT fk_facturacion_cuenta
    FOREIGN KEY (cod_factura_cuenta) REFERENCES cuenta_factura(cod_factura_cuenta)
) ENGINE=InnoDB;

-- =========================
-- Restore modes
-- =========================
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
