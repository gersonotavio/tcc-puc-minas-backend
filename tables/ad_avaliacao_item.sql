CREATE TABLE  "AD_AVALIACAO_ITEM" 
   (	"ID_AVALIACAO" NUMBER(5,0) NOT NULL ENABLE, 
	"ID" NUMBER(5,0) NOT NULL ENABLE, 
	"ID_INDICADOR" NUMBER(3,0) NOT NULL ENABLE, 
	"NR_ESCOLHA" NUMBER(1,0) NOT NULL ENABLE, 
	"VL_ESCOLHA" NUMBER(5,2) NOT NULL ENABLE
   )
/
ALTER TABLE  "AD_AVALIACAO_ITEM" ADD CONSTRAINT "AD_AVALIACAO_ITEM_CON" FOREIGN KEY ("ID_INDICADOR")
	  REFERENCES  "AD_INDICADOR" ("ID") ENABLE
/
ALTER TABLE  "AD_AVALIACAO_ITEM" ADD CONSTRAINT "FK_AD_AVALIACAO" FOREIGN KEY ("ID")
	  REFERENCES  "AD_AVALIACAO" ("ID") ENABLE
/


CREATE OR REPLACE EDITIONABLE TRIGGER  "TRG_AD_AVALIACAO_ITEM" 
  before insert or update on ad_avaliacao_item 
  referencing old as old new as new 
  for each row 
declare 
 
begin 
  if inserting then 
    select seq_ad_avaliacao_item.nextval 
      into :new.id_avaliacao 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_AVALIACAO_ITEM" ENABLE
/


