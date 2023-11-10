-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;
DROP VIEW IF EXISTS slg;
DROP VIEW IF EXISTS lslg;
DROP VIEW IF EXISTS salary_statistics;
DROP VIEW IF EXISTS maxid;


-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
 FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast,birthYear FROM people WHERE weight > 300-- replace this line
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast,birthYear  FROM people where nameFirst LIKE '% %' order by nameFirst,nameLast  
  -- replace this line
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT  birthYear,avg(height) ,count(*)  
  from people 
  group by birthYear 
  ORDER BY birthyear ASC  -- replace this line
    ;


-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT  birthYear,avg(height) ,count(*)  from people  group by birthYear HAVING 
    AVG(height) > 70  ORDER BY 
    birthyear ASC;


-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT nameFirst, namelast, p.playerid,  yearid  from people as p left outer join HallofFame  as h on
  p.playerid=h.playerid where  h.inducted = 'Y' order by yearid desc ,p.playerid asc -- replace this line
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
   SELECT nameFirst,nameLast,p.playerid,c.schoolID,h.yearid 
   from people as p 
   left outer join HallofFame as h on  p.playerid=h.playerid 
   left outer join CollegePlaying as c on p.playerid=c.playerid
   left outer join schools as s on c.schoolID=s.schoolID
   where  h.inducted ='Y'  and  s.schoolState = 'CA'
    order by h.yearid desc ,c.schoolID ,p.playerid asc  
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT 
      p.playerid,namefirst, namelast, c.schoolid
  from 
     people as p
  left outer join 
      HallofFame as h on p.playerid=h.playerid
  left outer join 
   CollegePlaying as c on p.playerid=c.playerid   
  where
    h.inducted='Y'
  order by
    p.playerid desc,schoolID
   -- replace this line
;

CREATE VIEW slg(playerid,yearid,AB,slgval)
AS 
  Select playerID,yearID,AB,((H-H2B-H3B-HR)+2*H2B+3*H3B+4*HR)/cast(AB as float)
  from batting  
  where AB>50
;


-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  -- SELECT 1, 1, 1, 1, 1 -- replace this line
  select p.playerid,p.nameFirst,p.nameLast,s.yearid,s.slgval
  from 
   people p 
  left outer join slg s
  on p.playerid=s.playerid
  order by s.slgval desc,s.yearid,p.playerid
  limit 10
;


create view lslg(playerid,lslgval)
as 
select playerid,((sum(H)-sum(H2B)-sum(H3B)-sum(HR))+2*sum(H2B)+3*sum(H3B)+4*sum(HR)+0.0)/(sum(AB)+0.0)
from 
  batting  
group by playerid  
HAVING sum(AB)>50 ;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerID,p.nameFirst,p.nameLast,lslgval
 from people p
inner join 
 lslg l
 on p.playerid=l.playerid
 order by 
 lslgval desc,p.playerid 
 limit 10
;





-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT nameFirst, nameLast,lslgval  -- replace this line
 from people p
inner join 
 lslg l
 on p.playerid=l.playerid
where l.lslgval>(select lslgval from lslg where playerid='mayswi01')
--  order by 
--  lslgval desc,p.playerid 
--  limit 10
  


  

  
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID, min(salary), max(salary), avg(salary) -- replace this line

  from 
      salaries
  group by 
  yearID
  order by 
  yearid asc
;



-- Question 4ii  
-- 感觉取巧了，要求是左开右闭，我这个可能有问题吧
CREATE VIEW q4ii(binid, low, high, count)
AS
SELECT
    b.binid,
    (507500.0 + b.binid * (
        SELECT CAST(((MAX(salary) - MIN(salary)) / 10) AS INT)
        FROM Salaries
        WHERE yearID = 2016
    )) AS low,
    ((b.binid + 1) * (
        SELECT CAST(((MAX(salary) - MIN(salary)) / 10) AS INT)
        FROM Salaries
        WHERE yearID = 2016
    ) + 507500.0) AS high,
    COUNT(s.Salary) AS salary_count
FROM
    binids b
left JOIN
    Salaries s ON s.yearID = 2016 AND s.salary >= (507500.0 + b.binid * (
        SELECT CAST(((MAX(salary) - MIN(salary)) / 10) AS INT)
        FROM Salaries
        WHERE yearID = 2016
    )) 
    AND s.salary <=((b.binid + 1) * (
        SELECT CAST(((MAX(salary) - MIN(salary)) / 10) AS INT)
        FROM Salaries
        WHERE yearID = 2016
    ) + 507500.0)
GROUP BY
    b.binid;


 create view salary_statistics(yearid,minsa,maxsa,avgsa)
 as 
    select yearid,min(salary),max(salary),avg(salary)
    from salaries
    group by yearid; 

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  select s1.yearid,s1.minsa-s2.minsa,s1.maxsa-s2.maxsa,s1.avgsa-s2.avgsa
  from salary_statistics s1
  inner join salary_statistics s2
  on s1.yearid-1=s2.yearid
  order by s1.yearid;
;

-- Question 4iv

create view maxid(playerid,salary,yearid)
as 
  select playerid,salary,yearid
  from salaries
  where (
      yearid=2000 and salary=(
        select max(salary) from salaries s1
        where s1.yearid=2000
      )
  )
      or 
          (
          yearid = 2001 AND salary =
          (SELECT MAX(salary)
          FROM salaries s2
          WHERE s2.yearid = 2001)

  );



CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid,p.namefirst,p.namelast,m.salary,m.yearid
  from people p 
  inner join maxid m
  on p.playerid=m.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamid, MAX(s.salary) - MIN(s.salary)
  FROM allstarfull a INNER JOIN salaries s 
  ON a.playerid = s.playerid AND a.yearid = s.yearid
  WHERE s.yearid = 2016
  GROUP BY a.teamid
;

