-- 1. Get all tasks assigned to a user.
SELECT id, title, description, status_id, user_id
FROM tasks
WHERE user_id = :user_id;

-- 2. Get tasks with a particular status using a subquery.
SELECT id, title, description, status_id, user_id
FROM tasks
WHERE status_id = (SELECT id FROM status WHERE name = :status_name);

-- 3. Change a task's status.
UPDATE tasks
SET status_id = (SELECT id FROM status WHERE name = :status_name)
WHERE id = :task_id;

-- 4. Get users who have no tasks.
SELECT id, fullname, email
FROM users
WHERE id NOT IN (SELECT user_id FROM tasks);

-- 5. Add a task for a user.
INSERT INTO tasks (title, description, status_id, user_id)
VALUES (
    :title,
    :description,
    (SELECT id FROM status WHERE name = :status_name),
    :user_id
);

-- 6. Get tasks that are not completed.
SELECT t.id, t.title, t.description, s.name AS status, t.user_id
FROM tasks AS t
JOIN status AS s ON s.id = t.status_id
WHERE s.name <> 'completed';

-- 7. Delete a task.
DELETE FROM tasks WHERE id = :task_id;

-- 8. Find users by email pattern (for example, '%@example.com').
SELECT id, fullname, email
FROM users
WHERE email LIKE :email_pattern;

-- 9. Update a user's name.
UPDATE users
SET fullname = :fullname
WHERE id = :user_id;

-- 10. Count tasks grouped by status.
SELECT s.name, COUNT(t.id) AS task_count
FROM status AS s
LEFT JOIN tasks AS t ON t.status_id = s.id
GROUP BY s.id, s.name
ORDER BY s.id;

-- 11. Get tasks assigned to users with a particular email domain.
SELECT t.id, t.title, t.description, u.fullname, u.email
FROM tasks AS t
JOIN users AS u ON u.id = t.user_id
WHERE u.email LIKE :email_domain;

-- 12. Get tasks without a description.
SELECT id, title, user_id
FROM tasks
WHERE description IS NULL OR TRIM(description) = '';

-- 13. Get users and their tasks that are in progress.
SELECT u.id AS user_id, u.fullname, t.id AS task_id, t.title, s.name AS status
FROM users AS u
INNER JOIN tasks AS t ON t.user_id = u.id
INNER JOIN status AS s ON s.id = t.status_id
WHERE s.name = 'in progress';

-- 14. Get users and their task counts, including users without tasks.
SELECT u.id, u.fullname, COUNT(t.id) AS task_count
FROM users AS u
LEFT JOIN tasks AS t ON t.user_id = u.id
GROUP BY u.id, u.fullname
ORDER BY u.id;
