USE [BDNCE]
GO
/****** Object:  StoredProcedure [dbo].[spBDNDiccionario]    Script Date: 13/09/2021 16:27:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spBDNDiccionario] @atributos INT OUTPUT
AS
BEGIN
DECLARE @query nvarchar(100),
 @parametros nvarchar(100),
 @tabla AS nvarchar(50),
 @campo AS nvarchar(50),
 @sql AS nvarchar(4000),
 @returnAsSelect int = 0,
 @registros AS INT;
IF OBJECT_ID(N'tempdb..BDNDiccionario',N'U') IS NOT NULL
BEGIN
   DROP TABLE tempdb..BDNDiccionario;
   CREATE TABLE tempdb..BDNDiccionario (id int IDENTITY (1,1) NOT NULL,nombretabla varchar(50),nombrecampo varchar(50),espk int,
   CONSTRAINT PK_BDNHDiccionario_id PRIMARY KEY CLUSTERED (id));
END;
ELSE
BEGIN
CREATE TABLE tempdb..BDNDiccionario (id int IDENTITY (1,1) NOT NULL,nombretabla varchar(50),nombrecampo varchar(50),espk varchar(2),
   CONSTRAINT PK_BDNHDiccionario_id PRIMARY KEY CLUSTERED (id));
END
DECLARE Tabla CURSOR FOR SELECT TABLE_NAME  
                         FROM INFORMATION_SCHEMA.TABLES
                         WHERE TABLE_TYPE='BASE TABLE' AND
                         TABLE_NAME NOT IN ('aplicacion','ASILOC90','autotemp','BM40100','DTC_MESES','DTT_Version',
                                            'eConnect_Out_Setup','frl_acct_code','IGP_REPLICA','IGP_SET000',
                                            'igpsop10100historica','palbrdty','respaldo_RM00401',
                                            'respaldo_RM20201','RM00401_RESPALDO','RM20201_RESPALDO',
                                            'ReportSetup','tmp_IGP_REPLICA','usuario','rol','rol_usuario','logxierp',
											'CM20100','IV00111','IV00102','DTTRMTRX100','DTTSYIMP100','UPR40200')
                         ORDER BY TABLE_NAME;
OPEN Tabla;
FETCH NEXT FROM Tabla INTO @tabla;
WHILE @@fetch_status = 0
BEGIN
   SET @query = N'SET @cuantos_registros = (SELECT COUNT(*) FROM ' + @tabla + ')';
   SET @parametros = N'@cuantos_registros INT OUTPUT';
   EXECUTE sp_executesql @query, @parametros, @cuantos_registros=@registros OUTPUT;
   IF (@registros > 0)
       INSERT INTO tempdb..BDNDiccionario(nombretabla, nombrecampo, espk)
       SELECT  @tabla, COLUMN_NAME, 0 FROM Information_Schema.Columns WHERE TABLE_NAME = @tabla 
               AND DATA_TYPE = 'numeric' 
			   AND COLUMN_NAME NOT IN ('QUANTITY','NOTEINDX','EmailMaxFileSize','HRSPRSHFT','DOLRAMNT','DTSEQNUM','FactorUT',
			                           'TXDTLPCT','TDTABMIN','valor_nominal','porc_comision','porc_ret_islr','td_monto_porcentaje',
									   'td_porcentaje','cantidad_articulo','lista_precio_dcto_prcnt','islr','descuento_a_factura',
									   'monto_recargo','monto_descuento') 
			   AND COLUMN_NAME NOT LIKE '%QTY%' 
			   AND COLUMN_NAME NOT LIKE '%ATY%'
			   AND COLUMN_NAME NOT LIKE '%DLR%'
			   AND COLUMN_NAME NOT LIKE '%Record%'
			   AND COLUMN_NAME NOT LIKE '%porcentaje%'
			   AND COLUMN_NAME NOT LIKE '%porc_%'
			   AND COLUMN_NAME NOT LIKE '%prcnt_%'
			   AND COLUMN_NAME NOT LIKE '%RECNUM';
   FETCH NEXT FROM Tabla INTO @tabla;
END;
CLOSE Tabla;
DEALLOCATE Tabla;
SELECT * INTO tempdb.dbo.BDNdiccdatos  FROM tempdb..BDNDiccionario;
DECLARE @cuantos INT = (SELECT COUNT(*) FROM tempdb.dbo.BDNdiccdatos);
WHILE @cuantos > 0
BEGIN
    DECLARE @id INT = (SELECT TOP(1) id FROM tempdb..BDNdiccdatos ORDER BY id);
	DECLARE @nombretabla VARCHAR(50) = (SELECT TOP(1) nombretabla FROM tempdb..BDNdiccdatos ORDER BY id);
	DECLARE @nombrecampo  VARCHAR(50) = (SELECT TOP(1) nombrecampo FROM tempdb..BDNdiccdatos ORDER BY id);
	UPDATE tempdb..BDNDiccionario SET  tempdb..BDNDiccionario.espk = 
       (SELECT  COUNT(*) 
	          FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE 
	          WHERE  COLUMN_NAME = @nombrecampo AND CONSTRAINT_NAME = 'PK' + @nombretabla)
    WHERE  tempdb..BDNDiccionario.nombretabla = @nombretabla AND tempdb..BDNDiccionario.nombrecampo = @nombrecampo;
	DELETE tempdb.dbo.BDNdiccdatos WHERE id = @id;
	SET @cuantos = (SELECT COUNT(*) FROM tempdb..BDNdiccdatos);
END;
DROP TABLE tempdb..BDNdiccdatos;
SET @atributos = (SELECT COUNT(*) FROM tempdb..BDNDiccionario);
END;

DECLARE @t int = 0;
EXECUTE spBDNDiccionario @t output;
SELECT @t;


select * from tempdb..BDNDiccionario where nombrecampo='monto_recargo'

select monto_recargo from caj_transaccion_articulo


