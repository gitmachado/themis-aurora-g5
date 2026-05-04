UPDATE users
SET cpf = NULL
WHERE cpf IS NOT NULL
  AND btrim(cpf) = '';
