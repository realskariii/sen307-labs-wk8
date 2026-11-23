-- ============================================
-- VUA-SEN307 Database Systems: Lab 6 (Week 8)
-- Aggregate Functions, Grouping and Subqueries
-- Name: Joseph Ijanu Skari
-- Matric No: VUG/SEN/24/11477
-- Database: sen307_11477
-- ============================================

USE sen307_11477;

-- --------------------------------------------
-- Task 1: Count the students enrolled in each course.
-- LEFT JOIN keeps every course, even one with no enrolments.
-- COUNT(e.student_id) ignores NULLs, so an empty course gives 0.
-- (COUNT(*) would count the NULL-filled row and wrongly give 1.)
-- --------------------------------------------
SELECT c.course_title, COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
ORDER BY total_students DESC;

-- --------------------------------------------
-- Task 2: Courses with more than N students.
-- HAVING filters groups after counting (WHERE filters rows before).
-- --------------------------------------------

-- Task 2a: threshold 3
SELECT c.course_title, COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(e.student_id) > 3
ORDER BY total_students DESC;

-- Task 2b: threshold 5
SELECT c.course_title, COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(e.student_id) > 5
ORDER BY total_students DESC;

-- Task 2c: threshold 7
SELECT c.course_title, COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(e.student_id) > 7
ORDER BY total_students DESC;

-- --------------------------------------------
-- Task 3: Average number of courses per student,
-- including students with zero courses.
-- The inner query counts courses per student (LEFT JOIN keeps
-- students with no enrolments, who get 0). The outer query
-- averages those counts.
-- --------------------------------------------
SELECT ROUND(AVG(course_count), 2) AS avg_courses_per_student
FROM (
    SELECT s.student_id, COUNT(e.course_id) AS course_count
    FROM Student s
    LEFT JOIN Enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id
) AS per_student;

-- --------------------------------------------
-- Task 4 (non-correlated subquery): Students not enrolled
-- in any course. The inner query runs once and returns every
-- enrolled student_id; NOT IN keeps the students not in that list.
-- Same result as a LEFT JOIN ... WHERE e.student_id IS NULL (Week 7).
-- --------------------------------------------
SELECT student_id, matric_no, full_name
FROM Student
WHERE student_id NOT IN (SELECT student_id FROM Enrolment);

-- --------------------------------------------
-- Task 5 (correlated subquery): For each department, the student
-- (or students, if tied) with the highest number of enrolments.
-- Both subqueries refer to the outer row s, so they run once per
-- student. The last subquery finds the highest count among students
-- in the SAME department as s, using s.dept_id from the outer query.
-- --------------------------------------------
SELECT d.dept_name, s.full_name,
       (SELECT COUNT(*) FROM Enrolment e
        WHERE e.student_id = s.student_id) AS courses
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE (SELECT COUNT(*) FROM Enrolment e
       WHERE e.student_id = s.student_id)
    = (SELECT MAX(x.course_count)
       FROM (SELECT s2.student_id, s2.dept_id,
                    COUNT(e2.student_id) AS course_count
             FROM Student s2
             LEFT JOIN Enrolment e2 ON s2.student_id = e2.student_id
             GROUP BY s2.student_id, s2.dept_id) AS x
       WHERE x.dept_id = s.dept_id)
ORDER BY d.dept_name;
