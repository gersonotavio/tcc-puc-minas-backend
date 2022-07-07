CREATE TABLE  "AD_DIRETORIA" 
   ("ID_DIRETORIA" NUMBER(4,0) NOT NULL ENABLE, 
	"NM_DIRETORIA" VARCHAR2(50) NOT NULL ENABLE, 
	"ID_CARGO" NUMBER(4,0), 
	 CONSTRAINT "AD_DIRETORIA_PK" PRIMARY KEY ("ID_DIRETORIA")
  USING INDEX  ENABLE
   )
/


CREATE UNIQUE INDEX  "AD_DIRETORIA_UK" ON  "AD_DIRETORIA" ("NM_DIRETORIA")
/


CREATE OR REPLACE EDITIONABLE TRIGGER  "TRG_AD_DIRETORIA" 
  before insert or update on AD_DIRETORIA 
  referencing old as old new as new 
  for each row 
declare 
 
begin 
  if inserting then 
    select SEQ_AD_DIRETORIA.nextval 
      into :new.id_diretoria 
      from dual; 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_DIRETORIA" ENABLE
/


