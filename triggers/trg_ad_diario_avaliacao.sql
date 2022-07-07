CREATE OR REPLACE EDITIONABLE TRIGGER  "trg_ad_diario_avaliacao" 
  before insert on ad_diario_avaliacao 
  referencing old as old new as new 
  for each row 
begin 
  select nvl(max(id_diario_avaliacao), 0) + 1 
    into :new.id_diario_avaliacao 
    from ad_diario_avaliacao; 
  -- 
  :new.dt_registro := sysdate; 
  -- 
  if :new.id_colaborador_avaliador is null and :new.id_perfil_registro = 1 then 
     :new.id_colaborador_avaliador := PCK_AD.FNC_BUSCA_ID_GERENTE_COLABORADOR(:new.id_colaborador); 
  end if; 
end; 

/
ALTER TRIGGER  "TRG_AD_DIARIO_AVALIACAO" ENABLE
/