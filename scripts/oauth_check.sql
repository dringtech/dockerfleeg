USE signonotron2_development

SELECT name, description, uid, secret FROM oauth_applications;

SELECT
    u.name, t.token
FROM
    users u,
    permissions p,
    oauth_access_tokens t
WHERE
    p.id = t.resource_owner_id
AND
    u.id = p.user_id;


