CREATE TABLE  "AD_COMPETENCIA" 
   (	"ID" NUMBER(3,0) NOT NULL ENABLE, 
	"NM_COMPETENCIA_AREA" VARCHAR2(40) NOT NULL ENABLE, 
	"DS_COMPETENCIA" VARCHAR2(200) NOT NULL ENABLE, 
	"VL_PERC_PESO" NUMBER(3,0) NOT NULL ENABLE, 
	"VL_CONCEITO_1" NUMBER(5,2), 
	"VL_CONCEITO_2" NUMBER(5,2), 
	"VL_CONCEITO_3" NUMBER(5,2), 
	"VL_CONCEITO_4" NUMBER(5,2), 
	 CONSTRAINT "AD_COMPETENIA_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   )
/