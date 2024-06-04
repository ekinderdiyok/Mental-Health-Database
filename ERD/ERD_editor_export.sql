
CREATE TABLE anxiety_treatment_gap
(
  entity         VARCHAR(255),
  year           INT         ,
  code           VARCHAR(10) ,
  adequate_treat DOUBLE      ,
  other_treat    DOUBLE      ,
  untreated      DOUBLE      ,
  PRIMARY KEY (entity, year)
);

COMMENT ON TABLE anxiety_treatment_gap IS 'Breakdown of anxiety patients treatment gap';

COMMENT ON COLUMN anxiety_treatment_gap.entity IS 'Name of a country or region';

COMMENT ON COLUMN anxiety_treatment_gap.year IS '4 digit year';

COMMENT ON COLUMN anxiety_treatment_gap.code IS 'ISO country code';

COMMENT ON COLUMN anxiety_treatment_gap.adequate_treat IS 'Percentage of anxiety patients';

COMMENT ON COLUMN anxiety_treatment_gap.other_treat IS 'Percentage of anxiety patients';

COMMENT ON COLUMN anxiety_treatment_gap.untreated IS 'Percentage of anxiety patients';

CREATE TABLE burden
(
  entity VARCHAR(255),
  year   INTEGER     ,
  code   VARCHAR(10) ,
  depr   DOUBLE      ,
  schi   DOUBLE      ,
  bipo   DOUBLE      ,
  eati   DOUBLE      ,
  anxi   DOUBLE       NOT NULL,
  PRIMARY KEY (entity, year)
);

COMMENT ON TABLE burden IS 'Disability-Adjusted Life Years (DALYS) from each mental illness';

COMMENT ON COLUMN burden.entity IS 'Name of a country or region';

COMMENT ON COLUMN burden.year IS '4 digit year';

COMMENT ON COLUMN burden.code IS 'ISO country code';

COMMENT ON COLUMN burden.depr IS 'Total DALYs from depression';

COMMENT ON COLUMN burden.schi IS 'Total DALYs from schizophrenia';

COMMENT ON COLUMN burden.bipo IS 'Total DALYs from bipolar disorder';

COMMENT ON COLUMN burden.eati IS 'Total DALYs from eating disorders';

COMMENT ON COLUMN burden.anxi IS 'Total DALYs from anxiety disorders';

CREATE TABLE entity_year_index
(
  entity VARCHAR(255),
  year   INT         ,
  PRIMARY KEY (entity, year)
);

COMMENT ON TABLE entity_year_index IS 'Master table for unique entities and years';

COMMENT ON COLUMN entity_year_index.entity IS 'Name of a country or region';

COMMENT ON COLUMN entity_year_index.year IS '4 digit year';

CREATE TABLE prevalence
(
  entity VARCHAR(255),
  year   INT         ,
  code   VARCHAR(10) ,
  schi   DOUBLE      ,
  depr   DOUBLE      ,
  anxi   DOUBLE      ,
  bipo   DOUBLE      ,
  eati   DOUBLE      ,
  PRIMARY KEY (entity, year)
);

COMMENT ON TABLE prevalence IS 'Prevalence of mental illnesses in percentage';

COMMENT ON COLUMN prevalence.entity IS 'Name of a country or region';

COMMENT ON COLUMN prevalence.year IS '4 digit year';

COMMENT ON COLUMN prevalence.schi IS 'Schizophrenia prevalence in percentage';

COMMENT ON COLUMN prevalence.depr IS 'Depression prevalence in percentage';

COMMENT ON COLUMN prevalence.anxi IS 'Anxiety prevalence in percentage';

COMMENT ON COLUMN prevalence.bipo IS 'Bipolar disorder prevalence in percentage';

COMMENT ON COLUMN prevalence.eati IS 'Eating disorder prevalence in percentage';

ALTER TABLE anxiety_treatment_gap
  ADD CONSTRAINT FK_entity_year_index_TO_anxiety_treatment_gap
    FOREIGN KEY (entity, year)
    REFERENCES entity_year_index (entity, year);

ALTER TABLE prevalence
  ADD CONSTRAINT FK_entity_year_index_TO_prevalence
    FOREIGN KEY (entity, year)
    REFERENCES entity_year_index (entity, year);

ALTER TABLE burden
  ADD CONSTRAINT FK_entity_year_index_TO_burden
    FOREIGN KEY (entity, year)
    REFERENCES entity_year_index (entity, year);
