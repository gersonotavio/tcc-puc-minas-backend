create or replace PACKAGE pck_hp_colaboradores AS
	-- inicio cargo ---------------------------------------------------------------
	PROCEDURE prc_hp_cargo(p_id_colaborador  IN NUMBER,
												 p_cd_cargo        OUT NUMBER,
												 p_cargo           OUT VARCHAR2,
												 p_lotacao_cargo   OUT VARCHAR2,
												 p_periodo_cargo   OUT VARCHAR2,
												 p_atividade_cargo OUT VARCHAR2,
												 p_qtd_cargo       OUT NUMBER);
	-------------------------------------------------------------------------------

	FUNCTION fnc_hp_ret_cargo(p_id_colaborador NUMBER) RETURN VARCHAR2;
	-------------------------------------------------------------------------------

	FUNCTION fnc_hp_ret_lotacao_cargo(p_id_colaborador NUMBER) RETURN VARCHAR2;
	-------------------------------------------------------------------------------

	FUNCTION fnc_hp_ret_periodo_cargo(p_id_colaborador NUMBER) RETURN VARCHAR2;
	-------------------------------------------------------------------------------

	FUNCTION fnc_hp_ret_qtd_cargo(p_id_colaborador NUMBER) RETURN NUMBER;
	-- fim cargo ------------------------------------------------------------------

END pck_hp_colaboradores;
/
create or replace PACKAGE BODY pck_hp_colaboradores AS
	-- inicio cargo ---------------------------------------------------------------
	PROCEDURE prc_hp_cargo(p_id_colaborador  IN NUMBER,
												 p_cd_cargo        OUT NUMBER,
												 p_cargo           OUT VARCHAR2,
												 p_lotacao_cargo   OUT VARCHAR2,
												 p_periodo_cargo   OUT VARCHAR2,
												 p_atividade_cargo OUT VARCHAR2,
												 p_qtd_cargo       OUT NUMBER) is
		cursor c1 is
			select c.colaborador_id,
						 c.cargo_id,
						 l.nm_lotacao,
						 c.ds_cargo,
						 c.ds_periodo,
						 c.ds_atividades
				from hp_cargos c, hp_lotacao l
			 where l.lotacao_id(+) = c.lotacao_id
				 and rownum = 1
				 and c.colaborador_id = p_id_colaborador
				 and (upper(c.ds_periodo) like '%ATUAL%' or
							upper(c.ds_periodo) like '%ATUAIS%' or
							upper(c.ds_periodo) like '%HOJE%' or
							upper(c.ds_periodo) like '%ANDAMENTO%' or
							upper(c.ds_periodo) like '%MOMENTO%' or
							upper(c.ds_periodo) like '%PRESENTE%');
	
		r1 c1%rowtype;
		--
		cursor c2 is
			select c.colaborador_id, count(c.cargo_id) qtd
				from hp_cargos c
			 where c.colaborador_id = p_id_colaborador
			 group by c.colaborador_id;
	
		r2 c2%rowtype;
	begin
		open c1;
		fetch c1
			into r1;
		if c1%found then
			p_cd_cargo        := r1.cargo_id;
			p_cargo           := r1.ds_cargo;
			p_lotacao_cargo   := r1.nm_lotacao;
			p_periodo_cargo   := r1.ds_periodo;
			p_atividade_cargo := r1.ds_atividades;
		end if;
		close c1;
		--
		open c2;
		fetch c2
			into r2;
		if c2%found then
			p_qtd_cargo := r2.qtd;
		end if;
		close c2;
	end;
	-------------------------------------------------------------------------------

	FUNCTION fnc_hp_ret_cargo(p_id_colaborador NUMBER) RETURN VARCHAR2 IS
		cursor c1 is
    /*
			select c.colaborador_id,
						 c.cargo_id,
						 l.nm_lotacao,
						 c.ds_cargo,
						 c.ds_periodo,
						 c.ds_atividades
				from hp_cargos c, hp_lotacao l
			 where l.lotacao_id(+) = c.lotacao_id
				 and rownum = 1
				 and c.colaborador_id = p_id_colaborador
				 and (upper(c.ds_periodo) like '%ATUAL%' or
							upper(c.ds_periodo) like '%ATUAIS%' or
							upper(c.ds_periodo) like '%HOJE%' or
							upper(c.ds_periodo) like '%ANDAMENTO%' or
							upper(c.ds_periodo) like '%MOMENTO%' or
							upper(c.ds_periodo) like '%PRESENTE%');
              */
-- alterado em 21.07.2021 pegar a últia data, última posição
       select c.colaborador_id,
             c.cargo_id,
             l.nm_lotacao,
             c.ds_cargo,
             c.ds_periodo,
             c.ds_atividades,
             c.dt_inicio, c.dt_fim
--             'de '||to_char(c.dt_inicio,'dd/mm/yyyy')||' à '||to_char(c.dt_fim,'dd/mm/yyyy') novo_periodo
        from hp_cargos c, hp_lotacao l
       where l.lotacao_id(+) = c.lotacao_id
--         and rownum = 1
         and c.colaborador_id = p_id_colaborador
         and ( c.dt_fim is null or c.dt_fim = ( select max(x.dt_fim) from hp_cargos x where x.colaborador_id = c.colaborador_id ))
         order by c.dt_inicio desc   ;           
	
		r1 c1%rowtype;
	
		v_cargo VARCHAR(500);
	begin
		open c1;
		fetch c1
			into r1;
		if c1%found then
			v_cargo := r1.ds_cargo;-- || ' - ' || r1.ds_periodo;
		end if;
		close c1;
		return v_cargo;
	end;
	-------------------------------------------------------------------------------

	FUNCTION fnc_hp_ret_lotacao_cargo(p_id_colaborador NUMBER) RETURN VARCHAR2 IS
		cursor c1 is
			select c.colaborador_id, l.nm_lotacao
				from hp_cargos c, hp_lotacao l
			 where l.lotacao_id(+) = c.lotacao_id
				 and rownum = 1
				 and c.colaborador_id = p_id_colaborador
				 and (upper(c.ds_periodo) like '%ATUAL%' or
							upper(c.ds_periodo) like '%ATUAIS%' or
							upper(c.ds_periodo) like '%HOJE%' or
							upper(c.ds_periodo) like '%ANDAMENTO%' or
							upper(c.ds_periodo) like '%MOMENTO%' or
							upper(c.ds_periodo) like '%PRESENTE%');
	
		r1 c1%rowtype;
	
		v_lotacao_cargo VARCHAR(500);
	begin
		open c1;
		fetch c1
			into r1;
		if c1%found then
			v_lotacao_cargo := r1.nm_lotacao;
		end if;
		close c1;
		return v_lotacao_cargo;
	end;
	-------------------------------------------------------------------------------

	FUNCTION fnc_hp_ret_periodo_cargo(p_id_colaborador NUMBER) RETURN VARCHAR2 IS
		cursor c1 is
			select c.colaborador_id, c.ds_periodo
				from hp_cargos c
			 where rownum = 1
				 and c.colaborador_id = p_id_colaborador
				 and (upper(c.ds_periodo) like '%ATUAL%' or
							upper(c.ds_periodo) like '%ATUAIS%' or
							upper(c.ds_periodo) like '%HOJE%' or
							upper(c.ds_periodo) like '%ANDAMENTO%' or
							upper(c.ds_periodo) like '%MOMENTO%' or
							upper(c.ds_periodo) like '%PRESENTE%');
	
		r1 c1%rowtype;
	
		v_periodo_cargo VARCHAR(100);
	begin
		open c1;
		fetch c1
			into r1;
		if c1%found then
			v_periodo_cargo := r1.ds_periodo;
		end if;
		close c1;
		return v_periodo_cargo;
	end;
	-------------------------------------------------------------------------------

	FUNCTION fnc_hp_ret_qtd_cargo(p_id_colaborador NUMBER) RETURN NUMBER IS
		cursor c1 is
			select c.colaborador_id, count(c.cargo_id) qtd
				from hp_cargos c
			 where c.colaborador_id = p_id_colaborador
			 group by c.colaborador_id;
	
		r1 c1%rowtype;
	
		v_qtd_cargo NUMBER;
	begin
		open c1;
		fetch c1
			into r1;
		if c1%found then
			v_qtd_cargo := r1.qtd;
		end if;
		close c1;
		return v_qtd_cargo;
	end;
	-- fim cargo ------------------------------------------------------------------

END pck_hp_colaboradores;
