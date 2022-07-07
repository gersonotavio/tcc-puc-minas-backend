create or replace PACKAGE  "PCK_AD" is
  procedure carga_usuarios;
  procedure atualiza_competencia;
  procedure gera_avaliacoes_ano_corrente;
  procedure busca_descricao_resultado(p_tp_avaliacao IN NUMBER, p_pontos IN NUMBER, p_titulo OUT VARCHAR2, p_descricao OUT VARCHAR2);
  procedure gera_alinhamentos_ano_corrente;
  function fnc_busca_id_gerente_colab(p_id in number) RETURN NUMBER;
  function fnc_busca_id_diretor_gerente(p_id  in number) RETURN NUMBER;  
  function fnc_conceito_result(p_id  in number, p_vl_escolha in number) RETURN VARCHAR2;  
  function fnc_conceito_result_cor(p_id  in number, p_vl_escolha in number) RETURN VARCHAR2;  
  function fnc_conceito_result_cor_fonte(p_id  in number, p_vl_escolha in number) RETURN VARCHAR2;  
  PROCEDURE envia_email_autoavaliacao;
  PROCEDURE envia_email_avaliacao;
  PROCEDURE envia_email_alinhamento;
End;
/
create or replace PACKAGE BODY  "PCK_AD" is

  procedure carga_usuarios is
    begin 
    insert into ad_usuario 
  (id, nm_usuario, id_perfil, id_administrador)
    select 
        COLABORADOR_ID, 
        NM_USUARIO, 
        CASE 
        WHEN ID_GERENTE = 1 THEN  2
        WHEN NM_LOTACAO ='DEX' THEN 4
        ELSE
        1 END AS PERFIL, 0    
        from v_ad_dados_usuarios;
        
        Update ad_usuario set id_administrador = 1 where id in (5,63,216,96,104); -->> Andre,Daiane,Gerson,Juliana,Monique
        
  end;
  
  procedure atualiza_competencia is
  
    cursor c1 is
    -- Fórmula para 20/3
    select 
    Round( ((20/100)/3) *10,2) c1,
    Round( ((20/100)/3) *20,2) c2,
    Round( ((20/100)/3) *30,2) c3,
    Round( ((20/100)/3) *40,2) c4
    from dual;
    r1 c1%rowtype;
    
    
    cursor c2 is
    -- Fórmula para 40 /8
    select 
    Round( ((40/100)/8) *10,2) c1,
    Round( ((40/100)/8) *20,2) c2,
    Round( ((40/100)/8) *30,2) c3,
    Round( ((40/100)/8) *40,2) c4
    from dual;
    r2 c2%rowtype;
    
    cursor c3 is
    -- Fórmula para 40 /4
    select 
    Round( ((40/100)/4) *10,2) c1,
    Round( ((40/100)/4) *20,2) c2,
    Round( ((40/100)/4) *30,2) c3,
    Round( ((40/100)/4) *40,2) c4
    from dual;
    r3 c3%rowtype;
    begin
    -->>
    Update ad_competencia set vl_perc_peso = 20 where id = 1;
    Update ad_competencia set vl_perc_peso = 40 where id = 2;
    Update ad_competencia set vl_perc_peso = 40 where id = 3;
    -->>
     open c1;
     fetch c1 into r1;
     while c1%found loop
       update ad_competencia 
       set 
       vl_conceito_1=r1.c1, 
       vl_conceito_2=r1.c2, 
       vl_conceito_3=r1.c3, 
       vl_conceito_4=r1.c4 
       where id = 1;
       
       fetch c1 into r1;
     end loop;
     close c1;
    
    
     open c2;
     fetch c2 into r2;
     while c2%found loop
    
       update ad_competencia 
       set 
       vl_conceito_1=r2.c1, 
       vl_conceito_2=r2.c2, 
       vl_conceito_3=r2.c3, 
       vl_conceito_4=r2.c4 
       where id = 2;
    
       fetch c2 into r2;
     end loop;
     close c2;
    
     open c3;
     fetch c3 into r3;
     while c3%found loop
       update ad_competencia 
       set 
       vl_conceito_1=r3.c1, 
       vl_conceito_2=r3.c2, 
       vl_conceito_3=r3.c3, 
       vl_conceito_4=r3.c4 
       where id = 3;
    
       fetch c3 into r3;
     end loop;
     close c3;
    
    
  End;

  procedure gera_avaliacoes_ano_corrente IS
    --
    -- verifica se tem registros do ano atual --
    CURSOR c1(p_ano NUMBER) IS
      SELECT 1
        FROM ad_avaliacao a
       WHERE extract(YEAR FROM(a.dt_geracao_avaliacao)) = p_ano;
    r1 c1%ROWTYPE;
    --
    --
    -- Popula Avaliação Individual Colaboradores --
    CURSOR c2 IS
      SELECT u.id id_colaborador,
             pck_ad.fnc_busca_id_gerente_colab(u.id) id_colaborador_avaliador,
             1 tp_avaliacao -- Avaliação Individual Colaboradores --
        FROM ad_usuario u,
             hp_colaboradores e
       WHERE u.id_perfil in(1,5)
        and e.colaborador_id = u.id
        and e.id_ativo = 1;
    r2 c2%ROWTYPE;
    --
    --
    -- Popula Avaliação Individual Gerentes --
    CURSOR c3 IS
      SELECT u.id id_colaborador,
             pck_ad.fnc_busca_id_diretor_gerente(u.id)  id_colaborador_avaliador, 
             2    tp_avaliacao -- Avaliação Individual Gerentes --
        FROM ad_usuario u,
             hp_colaboradores e
       WHERE u.id_perfil in( 2,6)
        and e.colaborador_id = u.id
        and e.id_ativo = 1;
    r3 c3%ROWTYPE;
    --
    --
    -- Popula  Autoavaliação --
    CURSOR c4 IS
      SELECT u.id id_colaborador,
             pck_ad.fnc_busca_id_gerente_colab(u.id) id_colaborador_avaliador,
             3 tp_avaliacao --  Autoavaliação --
        FROM ad_usuario u,
             hp_colaboradores e
       WHERE u.id_perfil in(1,5)
        and e.colaborador_id = u.id
        and e.id_ativo = 1;
    r4 c4%ROWTYPE;
    --
    --
    -- Popula  Autoavaliação gerente--
    CURSOR c5 IS
      SELECT u.id id_colaborador,
             pck_ad.fnc_busca_id_diretor_gerente(u.id)  id_colaborador_avaliador, 
             4    tp_avaliacao --  Autoavaliação do Gerente
        FROM ad_usuario u,
             hp_colaboradores e
       WHERE u.id_perfil in (2,6)
        and e.colaborador_id = u.id
        and e.id_ativo = 1;
    r5 c5%ROWTYPE;
    --
    --
    -- Popula Avaliação Desempenho dos Gestores --
    CURSOR c6 IS
      SELECT pck_ad.fnc_busca_id_gerente_colab(u.id) id_colaborador,
             u.id    id_colaborador_avaliador, 
             5    tp_avaliacao -- Avaliação Desempenho dos Gestores --
        FROM ad_usuario u,
             hp_colaboradores e
       WHERE u.id_perfil in(1,5)
        and e.colaborador_id = u.id
        and e.id_ativo = 1;
    r6 c6%ROWTYPE;
    --
    CURSOR c7(p_ano NUMBER) IS
      SELECT a.id, -1 nr_escolha, 0 vl_escolha
        FROM ad_avaliacao a
       WHERE extract(YEAR FROM(a.dt_geracao_avaliacao)) = p_ano
       ORDER BY a.id_colaborador;
    r7 c7%ROWTYPE;
    --
    v_ano_corrente         NUMBER := NULL;
    v_contador             NUMBER := 0;
    v_dt_geracao_avaliacao DATE   := null;
    --
  BEGIN
    -- busca o ano atual --
    SELECT extract(YEAR FROM(SYSDATE)) ano_corrente INTO v_ano_corrente FROM dual;
    SELECT SYSDATE INTO v_dt_geracao_avaliacao FROM dual;
    -- teste gerson - retirar depois --
     --v_ano_corrente := 2020;
     --v_dt_geracao_avaliacao := '01/12/2020';
  
    -- verifica se tem registros do ano atual --
    OPEN c1(v_ano_corrente);
    FETCH c1 INTO r1;
    --
    -- caso não tenha registros do ano corrente, insere para todos os colaboradores e gerentes --
    IF c1%NOTFOUND THEN
      OPEN c2;
      FETCH c2 INTO r2;
      --
      WHILE c2%FOUND LOOP
        --  tipo de Avaliação Individual Colaboradores  --
        INSERT INTO ad_avaliacao
          (id_colaborador, id_colaborador_avaliador, tp_avaliacao, dt_geracao_avaliacao)
        VALUES
          (r2.id_colaborador, r2.id_colaborador_avaliador, r2.tp_avaliacao, v_dt_geracao_avaliacao);
        FETCH c2 INTO r2;
      END LOOP;
      CLOSE c2;
    
      OPEN c3;
      FETCH c3 INTO r3;
      --
      WHILE c3%FOUND LOOP
        --  tipo de Avaliação Individual Gerentes --
        INSERT INTO ad_avaliacao
          (id_colaborador, id_colaborador_avaliador, tp_avaliacao, dt_geracao_avaliacao)
        VALUES
          (r3.id_colaborador, r3.id_colaborador_avaliador, r3.tp_avaliacao, v_dt_geracao_avaliacao);
        FETCH c3 INTO r3;
      END LOOP;
      CLOSE c3;
    
      OPEN c4;
      FETCH c4 INTO r4;
      --
      WHILE c4%FOUND LOOP
        --  tipo de  Autoavaliação (Colaborador) --
        INSERT INTO ad_avaliacao
          (id_colaborador, id_colaborador_avaliador, tp_avaliacao, dt_geracao_avaliacao)
        VALUES
          (r4.id_colaborador, r4.id_colaborador_avaliador, r4.tp_avaliacao, v_dt_geracao_avaliacao);
        FETCH c4 INTO r4;
      END LOOP;
      CLOSE c4;
    
      OPEN c5;
      FETCH c5 INTO r5;
      --
      WHILE c5%FOUND LOOP
        --  tipo de  Autoavaliação do Gerente (Gerente) --
        INSERT INTO ad_avaliacao
          (id_colaborador, id_colaborador_avaliador, tp_avaliacao, dt_geracao_avaliacao)
        VALUES
          (r5.id_colaborador, r5.id_colaborador_avaliador, r5.tp_avaliacao, v_dt_geracao_avaliacao);
        FETCH c5 INTO r5;
      END LOOP;
      CLOSE c5;
    
      OPEN c6;
      FETCH c6 INTO r6;
      --
      WHILE c6%FOUND LOOP
        --  tipo de Avaliação Desempenho dos Gestores --
        INSERT INTO ad_avaliacao
          (id_colaborador, id_colaborador_avaliador, tp_avaliacao, dt_geracao_avaliacao)
        VALUES
          (r6.id_colaborador, r6.id_colaborador_avaliador, r6.tp_avaliacao, v_dt_geracao_avaliacao);
        FETCH c6 INTO r6;
      END LOOP;
      CLOSE c6;
      --
      -- popula os itens da avaliação para os gerente e colaboradores --
      --
      OPEN c7(v_ano_corrente);
      FETCH c7 INTO r7;
      --
      WHILE c7%FOUND LOOP
        --  insere os 15 itens para cada avaliação --
        v_contador := 1;
        WHILE v_contador < 16 LOOP
          --
          INSERT INTO ad_avaliacao_item
            (id, id_indicador, nr_escolha, vl_escolha)
          VALUES
            (r7.id, v_contador, r7.nr_escolha, r7.vl_escolha);
          --
          v_contador := v_contador + 1;
        END LOOP;
        --
        FETCH c7 INTO r7;
      END LOOP;
      CLOSE c7;
      --
    END IF;
    --
    CLOSE c1;
    --
    COMMIT;
    --
  END;
  
  PROCEDURE busca_descricao_resultado(p_tp_avaliacao IN NUMBER, p_pontos IN NUMBER, p_titulo OUT VARCHAR2, p_descricao OUT VARCHAR2) IS
    CURSOR c1 IS
  
      SELECT r.ds_titulo, r.ds_resultado
        FROM ad_indicador_resultado r
       WHERE round(p_pontos) BETWEEN r.id_faixa_inicial AND r.id_faixa_final
         AND r.TP_AVALIACAO = p_tp_avaliacao;
    r1 c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1
      INTO r1;
    IF c1%FOUND THEN
      p_titulo    := r1.ds_titulo;
      p_descricao := r1.ds_resultado;
    else
      p_titulo    := 'Atenção!';
      p_descricao := 'Dados não encontrados para esta pontuação.';
    END IF;
    CLOSE c1;
  
  END;
  
  PROCEDURE gera_alinhamentos_ano_corrente IS
    --
    CURSOR c1(p_ano NUMBER) IS
    -- verifica se tem registros do ano atual --
      SELECT 1
        FROM ad_alinhamento a
       WHERE extract(YEAR FROM(a.dt_referencia)) = p_ano;
    r1 c1%ROWTYPE;
    --
    --
    CURSOR c2 IS
      SELECT u.id id_colaborador,
             pck_ad.fnc_busca_id_gerente_colab(u.id) id_colaborador_avaliador
        FROM ad_usuario u,
             hp_colaboradores e
       WHERE u.id_perfil in(1, 5)
        and e.colaborador_id = u.id
        and e.id_ativo = 1;
    r2 c2%ROWTYPE;
    --
    --
    v_ano_corrente  NUMBER := NULL;
    v_dt_referencia DATE   := null;
    --
  BEGIN
    -- busca o ano atual --
    SELECT extract(YEAR FROM(SYSDATE)) ano_corrente INTO v_ano_corrente FROM dual;
  
    -- verifica se tem registros do ano atual --
    OPEN c1(v_ano_corrente);
    FETCH c1 INTO r1;
    --
    -- caso não tenha registros do ano corrente, insere para todos os colaboradores --
    IF c1%NOTFOUND THEN
      OPEN c2;
      FETCH c2 INTO r2;
      --
      WHILE c2%FOUND LOOP
        --
        -- inclui alinhamentos de Abril --
        --
        v_dt_referencia := to_date('01/04/'||to_char(sysdate,'rrrr') ,'dd/mm/rrrr'); 
        --
        insert into ad_alinhamento
          (id_colaborador, id_colaborador_avaliador, dt_referencia)
        values
          (r2.id_colaborador, r2.id_colaborador_avaliador, v_dt_referencia);
        --
        -- inclui alinhamentos de Agosto --
        --
        v_dt_referencia := to_date('01/08/'||to_char(sysdate,'rrrr') ,'dd/mm/rrrr'); 
        --
        insert into ad_alinhamento
          (id_colaborador, id_colaborador_avaliador, dt_referencia)
        values
          (r2.id_colaborador, r2.id_colaborador_avaliador, v_dt_referencia);
        --  
        FETCH c2 INTO r2;
      END LOOP;
      CLOSE c2;
      --
    END IF;
    --
    CLOSE c1;
    --
    COMMIT;
    --
  END;
  
  FUNCTION fnc_busca_id_gerente_colab(p_id  in number)
  RETURN NUMBER AS

    cursor c1 is
      SELECT e.colaborador_id,
             e.emp_cod,
             e.par_matr,
             e.nome,
             e.lotacao_id,
             o.nm_lotacao,
             g.colaborador_id colaborador_id_gerente,
             g.emp_cod emp_cod_gerente,
             g.par_matr par_matr_gerente,
             g.nome nome_gerente
        FROM hp_colaboradores e,
             hp_lotacao o,
             hp_colaboradores g
       WHERE e.colaborador_id = p_id
         AND o.lotacao_id = e.lotacao_id
         AND e.id_gerente != 1
         AND e.id_ativo = 1
         AND g.lotacao_id = e.lotacao_id
         AND g.id_ativo = 1
         AND g.id_gerente = 1
         AND g.dt_rescisao IS NULL;
  
    r1 c1%rowtype;
    v_id number := null;

  BEGIN
  
    open c1;
    fetch c1
      into r1;
    if c1%found then
      v_id := r1.colaborador_id_gerente;
    else
         -- busca id dos diretores do Auditor e Ouvidor --
         select  fnc_busca_id_diretor_gerente(p_id)
           into v_id
           from dual;
    end if;
    close c1;
  
    return v_id;
  END fnc_busca_id_gerente_colab;

  
  FUNCTION fnc_busca_id_diretor_gerente(p_id  in number)
  RETURN NUMBER AS

    cursor c1 is
      SELECT e.colaborador_id colaborador_id_gerente,
             e.emp_cod emp_cod_gerente,
             e.par_matr par_matr_gerente,
             e.nome nome_gerente,
             e.lotacao_id,
             o.nm_lotacao,
             d.colaborador_id colaborador_id_diretor,
             d.emp_cod emp_cod_diretor,
             d.par_matr par_matr_diretor,
             d.nome nome_diretor,
             d.id_cargo,
             ca.ds_cargo
        FROM hp_colaboradores e,
             hp_lotacao o,
             hp_colaboradores d,
             ad_diretoria_lotacao dl,
             ad_diretoria di,
             pcr_cargo ca
       WHERE e.colaborador_id = p_id
         AND o.lotacao_id = e.lotacao_id
         AND (e.id_gerente = 1 or (e.lotacao_id in(10,14)))
         AND e.id_ativo = 1
         AND d.lotacao_id = 11
         AND dl.id_diretoria = di.id_diretoria
         AND dl.id_lotacao = e.lotacao_id
         and di.id_cargo = d.id_cargo
         AND d.id_ativo = 1
         AND d.dt_rescisao IS NULL
         AND ca.id_cargo = d.id_cargo;
  
    r1 c1%rowtype;
    v_id number := null;

  BEGIN
  
    open c1;
    fetch c1
      into r1;
    if c1%found then
      v_id := r1.colaborador_id_diretor;
    end if;
    close c1;
  
    return v_id;
  END fnc_busca_id_diretor_gerente;

  function fnc_conceito_result(p_id  in number, p_vl_escolha in number)   
  RETURN VARCHAR2 AS

    cursor c1 is
        select r.ds_conc_result 
          from ad_conceito_resultado r
        where p_vl_escolha between r.vl_indice_ini and r.VL_INDICE_FIM
         and r.id_conceito = p_id;
    r1 c1%rowtype;
    v_ds_conceito varchar2(30) := null;

  BEGIN
  
    open c1;
    fetch c1
      into r1;
    if c1%found then
      v_ds_conceito := r1.ds_conc_result;
    end if;
    close c1;
  
    return v_ds_conceito;
  END fnc_conceito_result;
  
  function fnc_conceito_result_cor(p_id  in number, p_vl_escolha in number)  
  RETURN VARCHAR2 AS

    cursor c1 is
        select r.cor 
          from ad_conceito_resultado r
        where p_vl_escolha between r.vl_indice_ini and r.VL_INDICE_FIM
         and r.id_conceito = p_id;
    r1 c1%rowtype;
    v_ds_conceito varchar2(30) := null;

  BEGIN
  
    open c1;
    fetch c1
      into r1;
    if c1%found then
      v_ds_conceito := r1.cor;
    end if;
    close c1;
  
    return v_ds_conceito; 
  END fnc_conceito_result_cor;
  
  function fnc_conceito_result_cor_fonte(p_id  in number, p_vl_escolha in number)   
  RETURN VARCHAR2 AS

    cursor c1 is
        select r.cor_fonte 
          from ad_conceito_resultado r
        where p_vl_escolha between r.vl_indice_ini and r.VL_INDICE_FIM
         and r.id_conceito = p_id;
    r1 c1%rowtype;
    v_ds_conceito varchar2(30) := null;

  BEGIN
  
    open c1;
    fetch c1
      into r1;
    if c1%found then
      v_ds_conceito := r1.cor_fonte;
    end if;
    close c1;
  
    return v_ds_conceito;  
  END fnc_conceito_result_cor_fonte;

  --------------------------------------------------------
  -- A U T O A V A L I A Ç Ã O                       -----
  --------------------------------------------------------
  PROCEDURE envia_email_autoavaliacao IS
    --
    -- lista todos colaboradores e gerentes para envio do email inicial 01/12 --
    CURSOR c1 IS
      SELECT u.nome,
             'gerson@celos.com.br' ds_email, -- utilizar email do gerson para testes --
             --u.ds_email, 
             to_char(last_day('01/12/' || to_char(SYSDATE, 'rrrr')),'dd/mm/rrrr') ultima_dia_ano,
             a.id_colaborador,
             a.tp_avaliacao,
             a.dt_geracao_avaliacao,
             u.par_matr
        FROM ad_avaliacao a, v_ad_dados_usuarios u
       WHERE a.tp_avaliacao IN (3, 4)
         AND a.id_colaborador = u.colaborador_id
         AND to_char(a.dt_geracao_avaliacao, 'rrrr') = to_char(SYSDATE, 'rrrr');
    r1 c1%rowtype;
    --
    --
    -- lista todos colaboradores e gerentes que ainda não finalizaram a  Autoavaliação --
    CURSOR c2 IS
      SELECT u.nome,
             'gerson@celos.com.br' ds_email, -- utilizar email do gerson para testes --
             --u.ds_email, 
             decode(to_char(a.dt_geracao_avaliacao,'yyyy'),2021,'12/01/2022',to_char(last_day('01/12/' || to_char(SYSDATE, 'rrrr')),'dd/mm/rrrr')) ultima_dia_ano,
             a.id_colaborador,
             a.tp_avaliacao,
             a.dt_geracao_avaliacao,
             u.par_matr
        FROM ad_avaliacao a, v_ad_dados_usuarios u
       WHERE a.tp_avaliacao IN (3, 4)
         AND a.id_colaborador = u.colaborador_id
         --AND to_char(a.dt_geracao_avaliacao, 'rrrr') = to_char(SYSDATE, 'rrrr')
         AND a.dt_fim_avaliacao IS NULL;
    r2 c2%ROWTYPE;
    --
    v_cont      NUMBER(3) := 0;
    v_remetente VARCHAR2(30);
    v_copia1    VARCHAR2(30);
    v_copia2    VARCHAR2(30) := NULL;
    v_assunto   VARCHAR2(200);
    v_texto     CLOB;
    p_mensagem  varchar2(2000);
    --
  BEGIN
    --
    -- Verifica se já foi enviado o 1o. email de aviso --
    --
    SELECT COUNT(1)
      INTO v_cont
      FROM ad_log_envio_email a
     WHERE a.tp_avaliacao IN (3, 4)
       AND to_char(a.dt_geracao_avaliacao, 'rrrr') = to_char(SYSDATE, 'rrrr');
    --
    -- ********************************************************************************
    -- *** A U T O A V A L I A Ç Ã O                                                ***
    -- ********************************************************************************
    --
    -- Envia o primeiro email de aviso da data final da  Autoavaliação no dia 01/12 --
    --
    p_mensagem := NULL;
    --
    IF v_cont > 0 THEN
      --
      p_mensagem := 'Email inicial da  Autoavaliação já enviado para os colaboradores e gerentes.';
      --
    ELSIF v_cont = 0 AND  '01/12' = to_char(SYSDATE, 'dd/mm') THEN
      --
      --
      v_remetente := 'naoresponder@celos.com.br';
      v_copia1    := null;
      --v_copia1    := ' gerson@celos.com.br';
      --v_copia2  := 'andre@celos.com.br';
      --
      wwv_flow_api.set_security_group_id;
      --
      -- caso não tenha sido enviado, envia para todos colaboradores e gerentes --
      OPEN c1;
      FETCH c1
        INTO r1;
      --
      WHILE c1%FOUND LOOP
        --
        --
        v_assunto := 'Avaliação de Desempenho - Disponibilização para fazer a  Autoavaliação.' || ' Matr. ' || r1.par_matr;
        
        --v_texto := NULL;
        --
        v_texto := '<p>Olá ' || r1.nome ||
                   ',<br />
      <br />A sua  Autoavaliação já pode ser preenchida!<br />
      <br />Basta acessar o seu cadastro no sistema de Gestão de Desempenho e clicar em  Autoavaliação! O prazo para preenchimento, conforme previsto na Metodologia de Avaliação de Desempenho, é até ' ||
                   r1.ultima_dia_ano ||
                   '.</p>
    <p>Em caso de dúvidas entre em contato com a área de Gestão de Pessoas.<br />
      <br />E-mail enviado automaticamente.<br />
      <br />Favor não responder esse e-mail.</p>';
        --
        dbms_output.put_line(length(v_texto));
        dbms_output.put_line((v_texto));
        --
        wwv_flow_api.set_security_group_id;
        --
        apex_mail.send(p_to => r1.ds_email, 
                       p_from => v_remetente, 
                       p_cc => v_copia1, 
                       p_bcc => v_copia2, 
                       p_subj => v_assunto, 
                       p_body => v_texto, 
                       p_body_html => v_texto);
        
        apex_mail.push_queue;
        --
        --
        INSERT INTO ad_log_envio_email
          (colaborador_id,
           ds_email,
           tp_avaliacao,
           dt_geracao_avaliacao,
           dt_envio_email,
           ds_tp_email)
        VALUES
          (r1.id_colaborador,
           r1.ds_email,
           r1.tp_avaliacao,
           r1.dt_geracao_avaliacao,
           SYSDATE,
           'Email de Alerta da  liberação para preenchimento da  Autoavaliação a partir de 01/12/' ||
           to_char(SYSDATE, 'rrrr'));
        --
        dbms_output.put_line('Email enviado para:' || r1.ds_email || ' a/c ' ||
                             r1.nome);
        FETCH c1
          INTO r1;
      END LOOP;
      CLOSE c1;
      --
      p_mensagem := 'Email inicial da  Autoavaliação enviado para os colaboradores e gerentes com sucesso.';
      --
      commit;
      --
    END IF;
    --
    -- Verifica se as autoavaliações ainda estão pendentes e envia email de lembrete --
    --
    SELECT COUNT(1)
      INTO v_cont
      FROM ad_avaliacao a
     WHERE a.tp_avaliacao IN (3, 4)
       --AND to_char(a.dt_geracao_avaliacao, 'rrrr') = to_char(SYSDATE, 'rrrr')
       AND a.dt_fim_avaliacao IS NULL;
    --
    -- se existir algum registro com a  Autoavaliação em aberto, verifica  a data do lembrete e envia o email --
    IF v_cont > 0 AND to_char(SYSDATE, 'dd/mm') IN ('10/01', '12/01', '05/12', '10/12', '15/12', '20/12', '25/12', '30/12') THEN
      --
      v_remetente := 'naoresponder@celos.com.br';
      v_copia1    := null;
      --v_copia1    := ' gerson@celos.com.br';
      --v_copia2  := 'gerson@celos.com.br';
      --
      wwv_flow_api.set_security_group_id;
      --
      -- Caso existam colaboradores e gerentes que ainda não finalizaram a  Autoavaliação e esteja na data do lembrete --
      OPEN c2;
      FETCH c2
        INTO r2;
      --
      WHILE c2%FOUND LOOP
        --
        --
        v_assunto := 'Avaliação de Desempenho - Lembrete para finalizar a  Autoavaliação.' ||
                     ' Matr. ' || r2.par_matr;
        
        --v_texto := NULL;
        --
        v_texto := '<p>Olá ' || r2.nome ||
                   ',<br />
        <br />Lembramos que a  Autoavaliação referente ao período de ' ||
                   to_char(r2.dt_geracao_avaliacao, 'rrrr') || ' encerra em ' ||
                   r2.ultima_dia_ano ||
                   '.<br />
        <br />Acesse o menu de sistemas, item Gestão de Desempenho, clique em  Autoavaliação e preencha o formulário.</p>
      <p>Em caso de dúvidas entre em contato com a área de Gestão de Pessoas.<br />
        <br />E-mail enviado automaticamente.<br />
        <br />Favor não responder esse e-mail.</p>';
        --
        dbms_output.put_line(length(v_texto));
        dbms_output.put_line((v_texto));
        --
        wwv_flow_api.set_security_group_id;
        --
        apex_mail.send(p_to => r2.ds_email, 
                       p_from => v_remetente, 
                       p_cc => v_copia1, 
                       p_bcc => v_copia2, 
                       p_subj => v_assunto, 
                       p_body => v_texto, 
                       p_body_html => v_texto);
        
        apex_mail.push_queue;
        --
        --
        INSERT INTO ad_log_envio_email
          (colaborador_id,
           ds_email,
           tp_avaliacao,
           dt_geracao_avaliacao,
           dt_envio_email,
           ds_tp_email)
        VALUES
          (r2.id_colaborador,
           r2.ds_email,
           r2.tp_avaliacao,
           r2.dt_geracao_avaliacao,
           SYSDATE,
           'Email lembrete para finalizar o preenchimento da  Autoavaliação. Enviado em: ' ||
           to_char(SYSDATE, 'dd/mm/rrrr hh24:mi:ss'));
        --
        FETCH c2
          INTO r2;
      END LOOP;
      CLOSE c2;
      --
      p_mensagem := 'Email lembrete para finalizar a  Autoavaliação enviado para os colaboradores e gerentes com sucesso.';
    END IF;
    --
  END;
  --------------------------------------------------------
  -- A V A L I A Ç Ã O   D E    D E S E M P E N H O  -----
  --------------------------------------------------------
  PROCEDURE envia_email_avaliacao IS
    --
    -- lista todos colaboradores para envio do email inicial 01/12 --
    CURSOR c1 IS
      SELECT u.nome,
             'gerson@celos.com.br' ds_email, -- utilizar email do gerson para testes -- 
             --u.ds_email, 
             to_char(last_day('01/12/' || to_char(SYSDATE, 'rrrr')),'dd/mm/rrrr') ultima_dia_ano,
             to_char(last_day('01/01/' || to_char(SYSDATE, 'rrrr')),'dd/mm/rrrr') ultima_dia_avaliacao,
             a.id_colaborador,
             a.tp_avaliacao,
             a.dt_geracao_avaliacao,
             u.par_matr
        FROM ad_avaliacao a, v_ad_dados_usuarios u
       WHERE a.tp_avaliacao = 1
         AND a.id_colaborador = u.colaborador_id
         AND u.id_ativo = 1
         AND u.id_gerente = 0;
         -- AND to_char(a.dt_geracao_avaliacao, 'rrrr') = to_char(SYSDATE, 'rrrr');
    r1 c1%ROWTYPE;
    --
    -- lista todos gerentes para envio do email inicial 01/12 --
    CURSOR c2 IS
      SELECT u.colaborador_id,
             u.nome,
             'gerson@celos.com.br' ds_email, -- utilizar email do gerson para testes --
             --u.ds_email, 
             u.par_matr
        FROM v_ad_dados_usuarios u
       WHERE u.id_gerente = 1
         AND u.id_ativo = 1;
    r2 c2%ROWTYPE;
    --
    -- lista todos colaboradores que ainda não finalizaram as avaliações dos gerentes --
    CURSOR c3 IS
      SELECT u.nome,
             'gerson@celos.com.br' ds_email, -- utilizar email do gerson para testes --
             --u.ds_email, 
             decode(to_char(a.dt_geracao_avaliacao,'yyyy'),2021,'12/01/2022',to_char(last_day('01/12/' || to_char(SYSDATE, 'rrrr')),'dd/mm/rrrr')) ultima_dia_ano,
             a.id_colaborador,
             a.tp_avaliacao,
             a.dt_geracao_avaliacao,
             u.par_matr
        FROM ad_avaliacao a, 
             v_ad_dados_usuarios u
       WHERE a.tp_avaliacao = 5
         AND a.id_colaborador = u.colaborador_id
         AND u.id_gerente = 0
         AND u.id_ativo = 1
         --AND to_char(a.dt_geracao_avaliacao, 'rrrr') = to_char(SYSDATE, 'rrrr')
         and a.dt_fim_avaliacao is null;  
    r3 c3%ROWTYPE;
    --
    v_dt_geracao_avaliacao DATE := NULL;
    v_cont                 NUMBER(3) := 0;
    v_remetente            VARCHAR2(30);
    v_copia1               VARCHAR2(30);
    v_copia2               VARCHAR2(30) := NULL;
    v_assunto              VARCHAR2(100);
    v_texto                CLOB;
    v_data_fim             VARCHAR2(10) := NULL;
    v_ano_fim              NUMBER := NULL;
    v_dt_mais_recente      DATE := NULL;
    v_dt_fim_avaliacoes    DATE := NULL;
    p_mensagem             varchar2(2000);
    --
  BEGIN
    --
    -- Verifica se já foi enviado o 1o. email de aviso aos colaboradores --
    --
    SELECT COUNT(1)
      INTO v_cont
      FROM ad_log_envio_email a, v_ad_dados_usuarios u
     WHERE a.tp_avaliacao = 1
       AND a.colaborador_id = u.colaborador_id
       AND u.id_ativo = 1
       AND u.id_gerente = 0
       AND to_char(a.dt_geracao_avaliacao, 'rrrr') = to_char(SYSDATE, 'rrrr');
    --
    -- Envia o primeiro email de aviso da data final da  Autoavaliação no dia 31/01 do próximo ano --
    --
    p_mensagem := NULL;
    --
    IF v_cont > 0 THEN
      --
      p_mensagem := 'Email inicial da Avaliação já enviado para os colaboradores.';
      --
    ELSIF v_cont = 0 AND  '01/12' = to_char(SYSDATE, 'dd/mm') THEN
      --
      --
      v_remetente := 'naoresponder@celos.com.br';
      v_copia1    := null;
      --v_copia1    := ' gerson@celos.com.br';
      --v_copia2  := 'gerson@celos.com.br';
      --
      wwv_flow_api.set_security_group_id;
      --
      -- caso não tenha sido enviado, envia para todos colaboradores --
      OPEN c1;
      FETCH c1
        INTO r1;
      --
      WHILE c1%FOUND LOOP
        --
        --
        v_assunto := 'Avaliação de Desempenho - Disponibilização para fazer a Avaliação Desempenho.' ||
                     ' Matr. ' || r1.par_matr;
        
        --v_texto := NULL;
        --
        v_texto := '<p>Olá ' || r1.nome || ',<br />
      <br />Até o dia ' || r1.ultima_dia_avaliacao ||
                   ', os Gerentes realizarão as Avaliações de Desempenho referente ao ano ' ||
                   to_char(r1.dt_geracao_avaliacao , 'rrrr') ||
                   ', conforme previsto na Metodologia de Avaliação de Desempenho, disponível na Intranet > Recursos Humanos.</p>
    <p>Em caso de dúvidas entre em contato com a área de Gestão de Pessoas.<br />
      <br />E-mail enviado automaticamente.<br />
      <br />Favor não responder esse e-mail.</p>';
        --
        --dbms_output.put_line(length(v_texto));
        --dbms_output.put_line((v_texto));
        --
        wwv_flow_api.set_security_group_id;
        --
        apex_mail.send(p_to => r1.ds_email, 
                       p_from => v_remetente, 
                       p_cc => v_copia1, 
                       p_bcc => v_copia2, 
                       p_subj => v_assunto, 
                       p_body => v_texto, 
                       p_body_html => v_texto);
        
        apex_mail.push_queue;
        --
        --
        INSERT INTO ad_log_envio_email
          (colaborador_id,
           ds_email,
           tp_avaliacao,
           dt_geracao_avaliacao,
           dt_envio_email,
           ds_tp_email)
        VALUES
          (r1.id_colaborador,
           r1.ds_email,
           r1.tp_avaliacao,
           r1.dt_geracao_avaliacao,
           SYSDATE,
           'Email de Alerta da  liberação para preenchimento da Avaliação de Desempenho a partir de 01/12/' ||
           to_char(SYSDATE, 'rrrr'));
        --
        --dbms_output.put_line('Email enviado para:' || r1.ds_email || ' a/c ' || r1.nome);
        FETCH c1
          INTO r1;
      END LOOP;
      CLOSE c1;
      --
      p_mensagem := 'Email inicial da Avaliação enviado para os colaboradores com sucesso.';
      --
    END IF;
    --
    -- Email para os colaboradores responderem a avaliação dos gerentes --
    --
    IF  to_char(SYSDATE, 'dd/mm') in ('01/12', '10/12', '20/12', '30/12', '12/01')THEN
      --
      --
      v_remetente := 'naoresponder@celos.com.br';
      v_copia1    := null;
      --v_copia1    := ' gerson@celos.com.br';
      --v_copia2  := 'gerson@celos.com.br';
      --
      wwv_flow_api.set_security_group_id;
      --
      -- caso não tenha sido enviado, envia para todos colaboradores --
      OPEN c3;
      FETCH c3
        INTO r3;
      --
      WHILE c3%FOUND LOOP
        --
        --
        v_assunto := 'Avaliação de Desempenho - Disponibilização para fazer a Av.Desempenho dos gestores.' ||
                     ' Matr. ' || r3.par_matr;
        
        --v_texto := NULL;
        --
        v_texto := '<p>Olá ' || r3.nome || ',<br />
      <br />Até o dia '||r3.ultima_dia_ano ||
                   ', deverão ser preenchidas a Avaliação de Desempenho do seu Gestor referente ao ano de ' ||
                   to_char(r3.dt_geracao_avaliacao, 'rrrr') ||
                   ', conforme previsto na Metodologia de Avaliação de Desempenho, disponível na Intranet > Recursos Humanos.</p>
    <p>Lembramos que a Avaliação não registra o nome do Avaliador.<br />
    <p>É muito importante a sua participação!<br />
    <p>Em caso de dúvidas entre em contato com a área de Gestão de Pessoas.<br />
      <br />E-mail enviado automaticamente.<br />
      <br />Favor não responder esse e-mail.</p>';
        --
        --dbms_output.put_line(length(v_texto));
        --dbms_output.put_line((v_texto));
        --
        wwv_flow_api.set_security_group_id;
        --
        apex_mail.send(p_to => r3.ds_email, 
                       p_from => v_remetente, 
                       p_cc => v_copia1, 
                       p_bcc => v_copia2, 
                       p_subj => v_assunto, 
                       p_body => v_texto, 
                       p_body_html => v_texto);
        
        apex_mail.push_queue;
        --
        --
        INSERT INTO ad_log_envio_email
          (colaborador_id,
           ds_email,
           tp_avaliacao,
           dt_geracao_avaliacao,
           dt_envio_email,
           ds_tp_email)
        VALUES
          (r3.id_colaborador,
           r3.ds_email,
           5,
           r3.dt_geracao_avaliacao,
           SYSDATE,
           'Email de Alerta da  liberação para preenchimento da Avaliação de Desempenho dos gestores a partir de 01/12/' ||
           to_char(SYSDATE, 'rrrr'));
        --
        --dbms_output.put_line('Email enviado para:' || r1.ds_email || ' a/c ' || r1.nome);
        FETCH c3 INTO r3;
      END LOOP;
      CLOSE c3;
      --
      p_mensagem := p_mensagem || 'Email inicial da Avaliação dos gerentes enviado para os colaboradores com sucesso.';
      --
    END IF;
    
    --
    -- Email para os gerentes --------------------
    --
    --
    -- Verifica se já foi enviado o 1o. email de aviso aos gerentes --
    --
    SELECT COUNT(1)
      INTO v_cont
      FROM v_ad_dados_usuarios u, ad_log_envio_email a
     WHERE u.id_gerente = 1
       AND u.colaborador_id = a.colaborador_id
       AND a.tp_avaliacao = 1
       AND to_char(a.dt_geracao_avaliacao, 'rrrr') = to_char(SYSDATE, 'rrrr');
    -- 
    if to_date(to_char(sysdate,'dd/mm/rrrr')) < to_date('01/10/'||to_char(sysdate,'rrrr')) then
      SELECT to_char(SYSDATE, 'rrrr') 
        INTO v_ano_fim
        FROM dual;
    else
      SELECT to_char(SYSDATE, 'rrrr') + 1
        INTO v_ano_fim
        FROM dual;
    end if;
    --
    SELECT '31/01/' || v_ano_fim
      INTO v_data_fim
      FROM dual;
    --
    SELECT max(a.dt_geracao_avaliacao)
      INTO v_dt_geracao_avaliacao
      FROM ad_log_envio_email a
     WHERE a.tp_avaliacao = 1;
    --
    -- Envia o primeiro email de aviso da data final da  Autoavaliação no dia 31/01 do próximo ano --
    --
    --
    IF v_cont > 0 THEN
      --
      p_mensagem := p_mensagem || ' *** Email inicial da Avaliação já enviado para os gerentes.';
      --
    ELSIF v_cont = 0 AND '01/12' = to_char(SYSDATE, 'dd/mm') THEN
      --
      --
      v_remetente := 'naoresponder@celos.com.br';
      v_copia1    := null;
      --v_copia1    := ' gerson@celos.com.br';
      --v_copia2  := 'gerson@celos.com.br';
      --
      wwv_flow_api.set_security_group_id;
      --
      -- caso não tenha sido enviado, envia para todos colaboradores --
      OPEN c2;
      FETCH c2
        INTO r2;
      --
      WHILE c2%FOUND LOOP
        --
        --
        v_assunto := 'Nova Avaliação de Desempenho - Disponibilização Avaliação Desempenho dos colaboradores da área.';
        
        --v_texto := NULL;
        --
        v_texto := '<p>Olá ' || r2.nome ||
                   ',<br />
      <br/>Informamos que até ' || v_data_fim ||
                   ' deverá ser realizada a Avaliação de Desempenho de cada Colaborador, conforme prevê na Metodologia de Avaliação de <br/>
      Desempenho. Programe com a sua equipe as reuniões individuais e se organize conforme prazo estipulado.</p>
    <p>Em caso de dúvidas entre em contato com a área de Gestão de Pessoas.<br />
      <br />E-mail enviado automaticamente.<br />
      <br />Favor não responder esse e-mail.</p>';
        --
        --dbms_output.put_line(length(v_texto));
        --dbms_output.put_line((v_texto));
        --
        wwv_flow_api.set_security_group_id;
        --
        apex_mail.send(p_to => r2.ds_email, 
                       p_from => v_remetente, 
                       p_cc => v_copia1, 
                       p_bcc => v_copia2, 
                       p_subj => v_assunto, 
                       p_body => v_texto, 
                       p_body_html => v_texto);
        
        apex_mail.push_queue;
        --
        --
        INSERT INTO ad_log_envio_email
          (colaborador_id,
           ds_email,
           tp_avaliacao,
           dt_geracao_avaliacao,
           dt_envio_email,
           ds_tp_email)
        VALUES
          (r2.colaborador_id,
           r2.ds_email,
           1,
           v_dt_geracao_avaliacao,
           SYSDATE,
           'Email de Alerta aos gerentes para preenchimento da Avaliação de Desempenho a partir de 01/12/' ||
           to_char(SYSDATE, 'rrrr'));
        --
        --dbms_output.put_line('Email enviado para:' || r1.ds_email || ' a/c ' || r1.nome);
        FETCH c2
          INTO r2;
      END LOOP;
      CLOSE c2;
      --
      p_mensagem := p_mensagem || ' *** Email inicial da Avaliação enviado para os gerentes com sucesso.';
      --
    END IF;
    --
    -- Email de lembrete para os gerentes sobre a finalização da Avaliação de Desempenho dos colaboradores da sua área
    --
    --
    SELECT to_date('01/01/' || (to_char(MAX(a.dt_geracao_avaliacao), 'rrrr') + 1), 'dd/mm/rrrr'),
           last_day(to_date('01/01/' || (to_char(MAX(a.dt_geracao_avaliacao), 'rrrr') + 1), 'dd/mm/rrrr')),
           MAX(a.dt_geracao_avaliacao)
      into v_dt_mais_recente, 
           v_dt_fim_avaliacoes,
           v_dt_geracao_avaliacao
      FROM ad_avaliacao a;
    --
    IF to_char(SYSDATE, 'dd/mm') IN ('10/12', '20/12', '30/12') OR 
      (to_char(v_dt_mais_recente,'rrrr') = to_char(sysdate,'rrrr') and to_char(SYSDATE, 'dd/mm') IN ('10/01','20/01','30/01')) THEN
      --
      v_remetente := 'naoresponder@celos.com.br';
      v_copia1    := null;
      --v_copia1    := ' gerson@celos.com.br';
      --v_copia2  := 'gerson@celos.com.br';
      --
      wwv_flow_api.set_security_group_id;
      --
      -- Caso existam colaboradores e gerentes que ainda não finalizaram a  Autoavaliação e esteja na data do lembrete --
      OPEN c2;
      FETCH c2
        INTO r2;
      --
      WHILE c2%FOUND LOOP
        --
        --
        v_assunto := 'Avaliação de Desempenho - Lembrete para finalizar a Av. Desempenho dos colaboradores.' ||
                     ' Matr. ' || r2.par_matr;
        
        --v_texto := NULL;
        --
        v_texto := '<p>Olá ' || r2.nome ||
                   ',<br />
        <br />Lembramos que as Avaliações de Desempenho deverão ser realizadas até ' || to_char(v_dt_fim_avaliacoes,'dd/mm/rrrr') ||
                   '.<br />
        <br />Caso já tenham sido realizadas, por gentileza, desconsiderar essa mensagem.</p>
      <p>Em caso de dúvidas entre em contato com a área de Gestão de Pessoas.<br />
        <br />E-mail enviado automaticamente.<br />
        <br />Favor não responder esse e-mail.</p>';
        --
        dbms_output.put_line(length(v_texto));
        dbms_output.put_line((v_texto));
        --
        wwv_flow_api.set_security_group_id;
        --
        apex_mail.send(p_to => r2.ds_email, 
                       p_from => v_remetente, 
                       p_cc => v_copia1, 
                       p_bcc => v_copia2, 
                       p_subj => v_assunto, 
                       p_body => v_texto, 
                       p_body_html => v_texto);
          
        apex_mail.push_queue;
        --
        --
        INSERT INTO ad_log_envio_email
          (colaborador_id,
           ds_email,
           tp_avaliacao,
           dt_geracao_avaliacao,
           dt_envio_email,
           ds_tp_email)
        VALUES
          (r2.colaborador_id,
           r2.ds_email,
           1,
           v_dt_geracao_avaliacao,
           SYSDATE,
           'Email lembrete para finalizar o preenchimento da Avaliação Desempenho Colaboradores. Enviado em: ' ||
           to_char(SYSDATE, 'dd/mm/rrrr hh24:mi:ss'));
        --
        FETCH c2
          INTO r2;
      END LOOP;
      CLOSE c2;
      --
      p_mensagem := p_mensagem || ' *** Email lembrete para finalizar a Avaliação Desempenho dos colaboradores com sucesso.';
    END IF;
    --
  END;
  --------------------------------------------------------
  -- A L I N H A M E N T O                           -----
  --------------------------------------------------------
  PROCEDURE envia_email_alinhamento IS
    --
    -- lista todos gerentes para envio do email lembrando de fazer o alinhamento em abril e agosto --
    CURSOR c1 IS
      SELECT u.colaborador_id,
             u.nome,
             'gerson@celos.com.br' ds_email,  -- utilizar email do gerson para testes --
             --u.ds_email, 
             u.par_matr
        FROM v_ad_dados_usuarios u
       WHERE u.id_gerente = 1
         AND u.id_ativo = 1;
    r1 c1%ROWTYPE;
    --
    v_dt_referencia        DATE := NULL;
    v_remetente            VARCHAR2(30);
    v_copia1               VARCHAR2(30);
    v_copia2               VARCHAR2(30) := NULL;
    v_assunto              VARCHAR2(100);
    v_texto                CLOB;
    v_data_fim             VARCHAR2(10) := NULL;
    p_mensagem             varchar2(2000);
    --
  BEGIN
    --
    --
    p_mensagem := NULL;
    --
    -- Email para os gerentes --------------------
    --
    --
    SELECT last_day(sysdate),
          to_char(SYSDATE, 'dd/mm/rrrr')
      INTO v_data_fim,
           v_dt_referencia
      FROM dual;
    --
    IF to_char(SYSDATE, 'dd/mm') in ('01/04','01/08') THEN
      --
      --
      --
      v_remetente := 'naoresponder@celos.com.br';
      v_copia1    := null;
      --v_copia1    := ' gerson@celos.com.br';
      --v_copia2  := 'gerson@celos.com.br';
      --
      wwv_flow_api.set_security_group_id;
      --
      OPEN c1;
      FETCH c1 INTO r1;
      --
      WHILE c1%FOUND LOOP
        --
        --
        v_assunto := 'Alinhamento da área - Disponibilização para fazer o Alinhamento com os colaboradores.';
        
        --v_texto := NULL;
        --
        v_texto := '<p>Olá ' || r1.nome ||
                   ',<br />
      <br/>Informamos que os alinhamentos referente a '||to_char(sysdate,'mm/rrrr')  ||' foi aberto e deverá ser realizado até o dia '|| to_char(v_data_fim,'dd/mm/rrrr') ||'.'||
   '<p>Em caso de dúvidas entre em contato com a área de Gestão de Pessoas.<br />
      <br />E-mail enviado automaticamente.<br />
      <br />Favor não responder esse e-mail.</p>';
        --
        --dbms_output.put_line(length(v_texto));
        --dbms_output.put_line((v_texto));
        --
        wwv_flow_api.set_security_group_id;
        --
        apex_mail.send(p_to => r1.ds_email, 
                       p_from => v_remetente, 
                       p_cc => v_copia1, 
                       p_bcc => v_copia2, 
                       p_subj => v_assunto, 
                       p_body => v_texto, 
                       p_body_html => v_texto);
        
        apex_mail.push_queue;
        --
        --
        INSERT INTO ad_log_envio_email
          (colaborador_id,
           ds_email,
           tp_avaliacao,
           dt_geracao_avaliacao,
           dt_envio_email,
           ds_tp_email)
        VALUES
          (r1.colaborador_id,
           r1.ds_email,
           null, -- não é avaliação e sim alinhamento de área
           v_dt_referencia,
           SYSDATE,
           'Email de Alerta aos gerentes para preenchimento do Alinhamento da área  partir de '||to_char(SYSDATE, 'dd/mm'));
        --
        --dbms_output.put_line('Email enviado para:' || r1.ds_email || ' a/c ' || r1.nome);
        FETCH c1 INTO r1;
      END LOOP;
      CLOSE c1;
      --
      p_mensagem := p_mensagem ||  ' *** Email inicial do Alinhamento da área  enviado para os gerentes com sucesso.';
      --
    END IF;
    --
    -- Email de lembrete para os gerentes sobre a finalização do Alinhamento com os colaboradores da sua área
    --
    --
    --
    IF to_char(SYSDATE, 'dd/mm') IN ('10/04','15/04','20/04','25/04','29/04','10/08','15/08','20/08','25/08','29/08') then
      --
      v_remetente := 'naoresponder@celos.com.br';
      v_copia1    := null;
      --v_copia1    := ' gerson@celos.com.br';
      --v_copia2  := 'gerson@celos.com.br';
      --
      wwv_flow_api.set_security_group_id;
      --
      -- Caso existam colaboradores e gerentes que ainda não finalizaram a  Autoavaliação e esteja na data do lembrete --
      OPEN c1;
      FETCH c1 INTO r1;
      --
      WHILE c1%FOUND LOOP
        --
        --
        v_assunto := 'Alinhamento da área - Lembrete para finalizar o Alinhamento com os colaboradores.';
        
        --v_texto := NULL;
        --
        v_texto := '<p>Olá ' || r1.nome ||
                   ',<br />
        <br />Lembramos que os Alinhamentos deve ser realizado até dia ' || to_char(v_data_fim,'dd/mm/rrrr') ||
                   '.<br />
        <br />Caso já tenham sido realizado, por gentileza, desconsiderar essa mensagem.</p>
      <p>Em caso de dúvidas entre em contato com a área de Gestão de Pessoas.<br />
        <br />E-mail enviado automaticamente.<br />
        <br />Favor não responder esse e-mail.</p>';
        --
        dbms_output.put_line(length(v_texto));
        dbms_output.put_line((v_texto));
        --
        wwv_flow_api.set_security_group_id;
        --
        apex_mail.send(p_to => r1.ds_email, 
                       p_from => v_remetente, 
                       p_cc => v_copia1, 
                       p_bcc => v_copia2, 
                       p_subj => v_assunto, 
                       p_body => v_texto, 
                       p_body_html => v_texto);
          
        apex_mail.push_queue;
        --
        --
        INSERT INTO ad_log_envio_email
          (colaborador_id,
           ds_email,
           tp_avaliacao,
           dt_geracao_avaliacao,
           dt_envio_email,
           ds_tp_email)
        VALUES
          (r1.colaborador_id,
           r1.ds_email,
           null, -- não é avaliação, e sim alinhamento
           v_dt_referencia,
           SYSDATE,
           'Email lembrete para finalizar o preenchimento do Alinhamento com os Colaboradores. Enviado em: ' ||
           to_char(SYSDATE, 'dd/mm/rrrr hh24:mi:ss'));
        --
        FETCH c1 INTO r1;
      END LOOP;
      CLOSE c1;
      --
      p_mensagem := p_mensagem || ' *** Email lembrete para finalizar a Alinhamento dos colaboradores com sucesso.';
    END IF;
    --
  END;
END;
