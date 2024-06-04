-- Create a table for anxiety treatment gap TEST
CREATE TABLE IF NOT EXISTS anxiety_treatment_gap (
    entity VARCHAR(255),
    code VARCHAR(10),
    year INT,
    adequate_treat DOUBLE PRECISION,
    other_treat DOUBLE PRECISION,
    untreated DOUBLE PRECISION,
    PRIMARY KEY (entity, year),  -- Ensures uniqueness and improves query performance
    FOREIGN KEY (entity, year) REFERENCES entity_year_index(entity, year)  -- Ensures referential integrity
);

CREATE TABLE IF NOT EXISTS entity_year_index (
    entity VARCHAR(255),
    year INT,
    PRIMARY KEY (entity, year)
);

CREATE TABLE IF NOT EXISTS prevalence (
    "entity" VARCHAR(255),
    "code" VARCHAR(10),
    "year" INT,
    "schi" DOUBLE PRECISION,
    "depr" DOUBLE PRECISION,
    "anxi" DOUBLE PRECISION,
    "bipo" DOUBLE PRECISION,
    "eati" DOUBLE PRECISION,
    PRIMARY KEY ("entity", "year") -- Composite primary key
    FOREIGN KEY ("entity", "year") REFERENCES entity_year_index("entity", "year") -- Ensures referential integrity
);


CREATE TABLE IF NOT EXISTS burden (
    entity VARCHAR(255),
    code VARCHAR(10),
    year INTEGER,
    depr DOUBLE PRECISION,
    schi DOUBLE PRECISION,
    bipo DOUBLE PRECISION,
    eati DOUBLE PRECISION,
    anxi DOUBLE PRECISION,
    PRIMARY KEY (entity, year), -- Composite primary key for entity and year 
    FOREIGN KEY ("entity", "year") REFERENCES entity_year_index("entity", "year") -- Ensures referential integrity
);