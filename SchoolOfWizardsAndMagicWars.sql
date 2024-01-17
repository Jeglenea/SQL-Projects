--phase one
best_student = "SELECT s.name
FROM Students s
INNER JOIN Student_Subject ss ON s.student_id = ss.student_id
WHERE s.grade = 3
GROUP BY s.student_id
HAVING AVG(ss.result) = 5
ORDER BY s.name;"
--phase two
achievement_point = "SELECT s.name, sum(a.bonus) AS [bonus point]
FROM Students s
INNER JOIN Student_Achievement sa ON s.student_id = sa.student_id
INNER JOIN Achievement a ON sa.achievement_id = a.achievement_id
GROUP BY s.name
ORDER BY sum(a.bonus) DESC
LIMIT 4;"
--phase three
average_student = "SELECT s.name, CASE WHEN AVG(ss.result) > 3.5 THEN 'above average' ELSE 'below average' END AS best
FROM Students s
JOIN Student_Subject ss ON s.student_id = ss.student_id
GROUP BY s.name
ORDER BY s.name ASC;"
--phase four
best_of_department = "SELECT
    s.name,
    d.department_name
FROM Students AS s
JOIN Student_Subject AS ss ON s.student_id = ss.student_id
JOIN Department AS d ON s.department_id = d.department_id
GROUP BY s.name, d.department_name
HAVING AVG(ss.result) > 4.5
ORDER BY s.name ASC;"
