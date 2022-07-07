CREATE TABLE  "AD_AVALIACAO" 
   ("ID" NUMBER(5,0) NOT NULL ENABLE, 
	"ID_COLABORADOR" NUMBER(4,0) NOT NULL ENABLE, 
	"ID_COLABORADOR_AVALIADOR" NUMBER(4,0) NOT NULL ENABLE, 
	"TP_AVALIACAO" NUMBER(1,0) NOT NULL ENABLE, 
	"DT_FIM_AVALIACAO" DATE, 
	"DT_FEEDBACK" DATE, 
	"OBSERVACAO" VARCHAR2(4000), 
	"DT_GERACAO_AVALIACAO" DATE, 
	 CONSTRAINT "AD_AVALIACAO_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "AD_CK_TP_AVAL" CHECK (tp_avaliacao in(1,2,3,4,5)) ENABLE
   )
/
ALTER TABLE  "AD_AVALIACAO" ADD CONSTRAINT "AD_AVALIACAO_FK_USU" FOREIGN KEY ("ID_COLABORADOR")
	  REFERENCES  "AD_USUARIO" ("ID") ON DELETE CASCADE ENABLE
/
ALTER TABLE  "AD_AVALIACAO" ADD CONSTRAINT "AD_AVALIACAO_FK_USU_AVAL" FOREIGN KEY ("ID_COLABORADOR_AVALIADOR")
	  REFERENCES  "AD_USUARIO" ("ID") ON DELETE CASCADE ENABLE
/


CREATE OR REPLACE EDITIONABLE TRIGGER  "TRG_AD_AVALIACAO" 
  before insert or update on ad_avaliacao 
  referencing old as old new as new 
  for each row 
declare 
   
begin 
  if inserting then 
    select seq_ad_avaliacao.nextval 
      into :new.id 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_AVALIACAO" ENABLE
/


