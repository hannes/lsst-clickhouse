-- Q01 -- check
SELECT COUNT(*) FROM Object;

-- Q02
SELECT COUNT(*) FROM Source;

-- Q03 -- check
SELECT COUNT(*) FROM ForcedSource;

-- Q04 -- check, no result
SELECT ra, decl FROM Object WHERE deepSourceId = 3306154155315676;

-- Q05 -- check
SELECT ra, decl FROM Object WHERE decl BETWEEN 19.171 AND 19.175 AND ra BETWEEN 0.95 AND 1.0;

-- Q06, -- check, no result
SELECT COUNT(*) FROM Object WHERE y_instFlux > 5;

-- Q07, -- check
SELECT MIN(ra), MAX(ra), MIN(decl), MAX(decl) FROM Object;

-- Q08, --check
SELECT COUNT(*) FROM Source WHERE flux_sinc BETWEEN 1 AND 2;

-- Q09, -- check
SELECT COUNT(*) FROM Source WHERE flux_sinc BETWEEN 2 AND 3;

-- Q10, -- check
SELECT COUNT(*) FROM ForcedSource WHERE psfFlux BETWEEN 0.1 AND 0.2;

-- Q11, -- check
SELECT COUNT(*) FROM Object all inner join (select objectId as deepSourceId from Source where flux_sinc BETWEEN 0.13 AND 0.14)  USING deepSourceId ;

-- Q12, --check
SELECT COUNT(*)  FROM Object all inner join (select deepSourceId from ForcedSource where psfFlux BETWEEN 0.13 AND 0.14)  USING deepSourceId ;

-- Q13, --check
select count(*) from (
  select *, 1 as jk from Object WHERE ra BETWEEN 90.299197 AND 98.762526 AND decl BETWEEN -66.468216 AND -56.412851
  ) as o1  ALL INNER JOIN (
  SELECT 1 as jk, deepSourceId, decl - 0.015 AS decl_min
              ,decl + 0.015 AS decl_max,
              if(abs(decl) + 0.015 > 89.9, 180, (180/pi())*((abs(atan(sin((0.015*pi())/180) / sqrt(abs(cos(((decl - 0.015)*pi())/180) * cos(((decl + 0.015)*pi())/180)))))))) AS alpha,
              ra - alpha as ra_min,
              ra + alpha as ra_max
         FROM Object WHERE ra BETWEEN 90.299197 AND 98.762526 AND decl BETWEEN -66.468216 AND -56.412851) as o2 
  USING jk where o1.decl BETWEEN decl_min AND decl_max
   AND o1.ra BETWEEN ra_min AND ra_max;

