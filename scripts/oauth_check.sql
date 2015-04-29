USE DATABASE signonotron2_development
SELECT name, description, uid, secret FROM oauth_applications;
SELECT a.name, a.description, t.token FROM
    oauth_applications AS a JOIN
    oauth_access_tokens AS t ON a.id = t.application_id;



SELECT application_id, user_id, permissions FROM permissions\

SELECT id, email, api_user FROM users WHERE api_user;

SELECT u.email, t.token FROM users AS u JOIN oauth_access_tokens AS t ON u.id = t.user_id;

SELECT u.email, p.application_id FROM permissions as p JOIN users as u ON u.id = p.user_id WHERE api_user=1;



SELECT p.user_id, t.token FROM permissions as p JOIN oauth_access_tokens AS t on p.id = t.resource_owner_id;


