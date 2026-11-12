CREATE INDEX IF NOT EXISTS pluto_geom_idx ON pluto USING GIST (geometry);
CREATE INDEX IF NOT EXISTS pluto_bbl_idx ON pluto (bbl);

DROP TABLE IF EXISTS features;
CREATE TABLE features AS
SELECT l.*,
       p.numfloors, p.unitsres, p.bldgclass, p.lotarea, p.bldgarea,
       p.geometry,
       nb.n_lots_500m,
       nb.median_year_500m,
       nb.avg_floors_500m
FROM ll84 l
JOIN pluto p ON p.bbl = l.bbl
CROSS JOIN LATERAL (
    SELECT COUNT(*)                                             AS n_lots_500m,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY q.yearbuilt) AS median_year_500m,
           AVG(q.numfloors)                                     AS avg_floors_500m
    FROM pluto q
    WHERE ST_DWithin(q.geometry, ST_Centroid(p.geometry), 1640)
      AND q.yearbuilt > 0
) nb;
