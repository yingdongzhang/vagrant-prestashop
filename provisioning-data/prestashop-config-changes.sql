UPDATE ps_configuration
SET value = 0
WHERE name = 'PS_SMARTY_CACHE';

UPDATE ps_configuration
SET value = 2
WHERE name = 'PS_SMARTY_FORCE_COMPILE';