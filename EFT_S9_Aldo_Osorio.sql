
-- informe 1
CREATE VIEW INFORME1_VIEW AS

SELECT 
rg.nombre_region,
COUNT(case when ((extract(YEAR FROM SYSDATE) - extract(YEAR FROM cl.fecha_inscripcion)) >= 20) then 1 end) as clientes_vip,
COUNT(cl.numrun) as clientes_total
FROM CLIENTE cl 
INNER JOIN REGION rg ON cl.cod_region = rg.cod_region 
GROUP BY rg.nombre_region
ORDER BY clientes_vip;

-- CREACION DE INDICES

CREATE  INDEX IDX_REGION  ON CLIENTE (cod_region);
CREATE  INDEX IDX_CLI_REGION ON CLIENTE (FECHA_INSCRIPCION);


select * from INFORME1_VIEW WHERE nombre_region like '%Metroplitana%';



--------------------------------------- -----------------------------------------
--INFORME 2

-- OPCION SET

SELECT 
TO_CHAR(SYSDATE,'dd-mm-yyyy') as fecha,
ROUND(AVG(ttc.monto_transaccion),0 ) as monto_promedio_transaccion,
ttc.cod_tptran_tarjeta,
'Super Avance en Efectivo' as tipo_transaccion
FROM cuota_transac_tarjeta_cliente ctc
inner join transaccion_tarjeta_cliente ttc on ctc.nro_transaccion = ttc.nro_transaccion
INNER JOIN tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta
where (extract(MONTH FROM ctc.fecha_venc_cuota) between 6 and 12 ) AND
extract(YEAR FROM ctc.fecha_venc_cuota) > =  (select to_number(max(distinct(extract(YEAR FROM fecha_venc_cuota))))-1 FROM cuota_transac_tarjeta_cliente) and
ttc.cod_tptran_tarjeta = 103
group by  ttc.cod_tptran_tarjeta
UNION
SELECT 
TO_CHAR(SYSDATE,'dd-mm-yyyy') as fecha,
ROUND(AVG(ttc.monto_transaccion),0 ) as monto_promedio_transaccion,
ttc.cod_tptran_tarjeta,
case when ttc.cod_tptran_tarjeta = 102 then 'Avance en Efectivo' else case when ttc.cod_tptran_tarjeta = 101 then 'Compras Tiendas Retail o Asociadas'  end end as tipo_transaccion
FROM cuota_transac_tarjeta_cliente ctc
inner join transaccion_tarjeta_cliente ttc on ctc.nro_transaccion = ttc.nro_transaccion
INNER JOIN tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta
where (extract(MONTH FROM ctc.fecha_venc_cuota) between 6 and 12 ) AND
extract(YEAR FROM ctc.fecha_venc_cuota) > =  (select to_number(max(distinct(extract(YEAR FROM fecha_venc_cuota))))-1 FROM cuota_transac_tarjeta_cliente) and
ttc.cod_tptran_tarjeta in (101,102)
group by  ttc.cod_tptran_tarjeta;



-- OPCION SELECT ANIDADO
-- Creacion tabla SELECCIÓN_TIPO_TRANSACCIÓN
create table SELECCIÓN_TIPO_TRANSACCIÓN as
SELECT 
TO_CHAR(SYSDATE,'dd-mm-yyyy') as fecha,
ROUND(AVG(ttc.monto_transaccion),0 ) as monto_promedio_transaccion,
ttc.cod_tptran_tarjeta as cod_tipo_transaccion,
case when ttc.cod_tptran_tarjeta = 103 then 'Super Avance en Efectivo' else case when ttc.cod_tptran_tarjeta = 102 then 'Avance en Efectivo' else case when ttc.cod_tptran_tarjeta = 101 then 'Compras Tiendas Retail o Asociadas'  end end end as tipo_transaccion
FROM cuota_transac_tarjeta_cliente ctc  
INNER JOIN transaccion_tarjeta_cliente ttc on ctc.nro_transaccion = ttc.nro_transaccion
INNER JOIN tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta
where (extract(MONTH FROM ctc.fecha_venc_cuota) between 6 and 12 ) AND
extract(YEAR FROM ctc.fecha_venc_cuota) > =  (select to_number(max(distinct(extract(YEAR FROM fecha_venc_cuota))))-1 FROM cuota_transac_tarjeta_cliente)
group by  ttc.cod_tptran_tarjeta
order by monto_promedio_transaccion;


-- reajuste de intereses - 0.01 que correponde al 1% de rebaja

  
update tipo_transaccion_tarjeta ttt set ttt.TASAINT_TPTRAN_TARJETA = ttt.TASAINT_TPTRAN_TARJETA - 0.01
where ttt.COD_TPTRAN_TARJETA in (select cod_tipo_transaccion from SELECCIÓN_TIPO_TRANSACCIÓN);
commit;



