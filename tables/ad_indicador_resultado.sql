CREATE TABLE  "AD_INDICADOR_RESULTADO" 
   ("ID_INDICADOR_RESULTADO" NUMBER(4,0) NOT NULL ENABLE, 
	"DS_TITULO" VARCHAR2(50) NOT NULL ENABLE, 
	"DS_RESULTADO" VARCHAR2(4000) NOT NULL ENABLE, 
	"ID_FAIXA_INICIAL" NUMBER(2,0) NOT NULL ENABLE, 
	"ID_FAIXA_FINAL" NUMBER(2,0) NOT NULL ENABLE, 
	"TP_AVALIACAO" NUMBER(1,0), 
	 CONSTRAINT "AD_IND_RESULT_CHK" CHECK (tp_avaliacao in(1,2,3,4)) ENABLE, 
	 CONSTRAINT "AD_IND_RESULT_PK" PRIMARY KEY ("ID_INDICADOR_RESULTADO")
  USING INDEX  ENABLE
   )
/


CREATE OR REPLACE EDITIONABLE TRIGGER  "TRG_AD_INDICADOR_RESULTADO" 
  before insert or update on ad_indicador_resultado 
  referencing old as old new as new 
  for each row 
declare 
 
begin 
  if inserting then 
    select seq_ad_indicador_resultado.nextval 
      into :new.id_indicador_resultado 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_INDICADOR_RESULTADO" ENABLE
/


