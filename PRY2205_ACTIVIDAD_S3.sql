/*
Asignatura: Consulta de Bases de Datos
Sumativa 1 - Semana 3
Empresa: ASOCIADOS
*/

-- CASO 1: ANALISIS DE PROPIEDADES
SELECT id_tipo_propiedad AS tipo,
       COUNT(*) AS total_propiedades,
       TO_CHAR(MAX(valor_arriendo),
               'FM$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.''') AS max_arriendo,
       TO_CHAR(ROUND(AVG(valor_arriendo)),
               'FM$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.''') AS promedio_arriendo,
       TO_CHAR(MIN(valor_arriendo),
               'FM$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.''') AS min_arriendo,
       CASE
           WHEN MAX(valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
           ELSE 'PREMIUM'
       END AS clasificacion,
       TO_CHAR(SUM(NVL(valor_gasto_comun, 0)),
               'FM$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.''') AS total_gastos_comunes
FROM propiedad
GROUP BY id_tipo_propiedad
HAVING SUM(NVL(valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(valor_gasto_comun, 0)) DESC;

-- CASO 2: ANALISIS DE ANTIGÜEDAD DE EMPLEADOS
SELECT UPPER(nombre_emp || ' ' || appaterno_emp) AS "Nombre Empleado",
       TO_CHAR(sueldo_emp,
               'FM$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo con Formato",
       CASE
           WHEN sueldo_emp > 2000000 THEN 'ALTO'
           ELSE 'MEDIO'
       END AS "Clasificación Sueldo",
       TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12)
           AS "Años Antigüedad",
       'Corresponde bono ' ||
       CASE
           WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) <= 10
               THEN '5%'
           WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) <= 20
               THEN '10%'
           ELSE '15%'
       END || ': ' ||
       TO_CHAR(
           ROUND(sueldo_emp *
               CASE
                   WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) <= 10
                       THEN 0.05
                   WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) <= 20
                       THEN 0.10
                   ELSE 0.15
               END),
           'FM$999G999G999',
           'NLS_NUMERIC_CHARACTERS='',.''') AS bono
FROM empleado
WHERE id_categoria_emp = 3
  AND MONTHS_BETWEEN(SYSDATE, fecing_emp) > 60
  AND id_sucursal <> &CODIGO_SUCURSAL
ORDER BY sueldo_emp DESC;

-- CASO 3: CLASIFICACION DE CLIENTES POR RENTA

SELECT CASE
           WHEN renta_cli >= 1000000 THEN 'PREMIUM'
           WHEN renta_cli >= 600000 THEN 'ALTA'
           WHEN renta_cli >= 300000 THEN 'MEDIA'
           ELSE 'BAJA'
       END AS clasificacion_renta,
       COUNT(*) AS cantidad_clientes,
       TO_CHAR(ROUND(AVG(renta_cli)),
               'FM$999G999G999',
               'NLS_NUMERIC_CHARACTERS='',.''') AS renta_promedio,
       CASE
           WHEN COUNT(NVL(celular_cli, fonofijo_cli)) = 0
               THEN 'Clientes sin Teléfono'
           ELSE 'Clientes con Teléfono'
       END AS estado_telefono
FROM cliente
GROUP BY CASE
             WHEN renta_cli >= 1000000 THEN 'PREMIUM'
             WHEN renta_cli >= 600000 THEN 'ALTA'
             WHEN renta_cli >= 300000 THEN 'MEDIA'
             ELSE 'BAJA'
         END
HAVING AVG(renta_cli) > 200000;