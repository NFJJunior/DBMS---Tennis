set serveroutput on;
set echo off;

-- Pachetul proiect contine toate obiectele definite;
-- cerinta 13
CREATE OR REPLACE PACKAGE proiect IS
    -- cerinta 6
    procedure afisare_antrenori_sponsori(cod_turneu editie.turneu_id%TYPE, an editie.editie_id%TYPE);
    
    -- cerinta 7
    procedure modifica_sponsorizare;
    
    -- cerinta 8
    function turnee_castigate(an editie.editie_id%TYPE, nat nationalitate.nume_n%TYPE)
    return number;
    
    -- cerinta 9
    function ultimul_an(tip tip_turneu.nume_tip%TYPE)
    return number;
END proiect;
/

-- Corpul pachetul proiect
CREATE OR REPLACE PACKAGE BODY proiect IS
    -- cerinta 6
    procedure afisare_antrenori_sponsori(cod_turneu editie.turneu_id%TYPE, an editie.editie_id%TYPE)
    is
        type vector_antrenor is varray(10) of antrenor%rowtype;
        v_ant vector_antrenor := vector_antrenor();
        type tablou_imbricat_sponsor is table of sponsor%rowtype;
        ti_spo tablou_imbricat_sponsor := tablou_imbricat_sponsor();
        
        cod_jucator jucator.jucator_id%TYPE;
    begin
        select jucator_id into cod_jucator
        from participare natural join punctaj natural join rezultat
        where turneu_id = cod_turneu and editie_id = an and proba_id = 1 and nume_rezultat = 'castigator';
        
        select distinct antrenor_id, nume_antrenor, prenume_antrenor, gen
        bulk collect into v_ant
        from antrenament natural join antrenor
        where jucator_id = cod_jucator
        group by antrenor_id, nume_antrenor, prenume_antrenor, gen;
        
        dbms_output.put_line('Nr de antrenori: ' || v_ant.count);
        if v_ant.count != 0 then
            for i in 1..v_ant.count loop
            dbms_output.put_line(v_ant(i).prenume_antrenor || ' ' || v_ant(i).nume_antrenor);
            end loop;
        end if;
        
        dbms_output.new_line;
        
        select sponsor_id, nume_sponsor
        bulk collect into ti_spo
        from sponsorizare natural join sponsor
        where jucator_id = cod_jucator
        group by sponsor_id, nume_sponsor;
        
        dbms_output.put_line('Nr de sponsori: ' || ti_spo.count);
        if ti_spo.count != 0 then
            for i in ti_spo.first..ti_spo.last loop
            dbms_output.put_line(ti_spo(i).nume_sponsor);
            end loop;
        end if;
    exception
        when no_data_found then
            dbms_output.put_line('Inca nu s-a jucat editia aceasta!');
        when others then
            dbms_output.put_line('Alta eroare!');
    end afisare_antrenori_sponsori;
    
    --cerinta 7
    procedure modifica_sponsorizare
    is
        type informatii_jucator is record(
        cod_jucator jucator.jucator_id%TYPE,
        inaltime caracteristici_jucator.inaltime%TYPE);
        
        cursor c1
        return informatii_jucator is
        select jucator_id, inaltime
        from jucator natural join caracteristici_jucator;
        
        cursor c2(cod_jucator jucator.jucator_id%TYPE)
        is
        select *
        from sponsorizare
        where data_sfarsit is null and jucator_id = cod_jucator
        for update of suma nowait;
    begin
        for i in c1 loop
            for j in c2(i.cod_jucator) loop
                if i.inaltime > 185 then
                    update sponsorizare
                    set suma = suma * 1.1
                    where current of c2;
                else
                    update sponsorizare
                    set suma = suma * 1.05
                    where current of c2;
                end if;
            end loop;
        end loop;
    end modifica_sponsorizare;
    
    -- cerinta 8
    function turnee_castigate(an editie.editie_id%TYPE, nat nationalitate.nume_n%TYPE)
    return number is
        cursor jucatori(cod_nat nationalitate.nationalitate_id%TYPE)
        return jucator%rowtype is
        select *
        from jucator
        where nationalitate_id = cod_nat;
        
        exceptie1 exception;
        exceptie2 exception;
        test1 number;
        test2 number;
        
        cod_nat nationalitate.nationalitate_id%TYPE;
        raspuns number := 0;
        cnt number := 0;
    begin
        select count(*) into test1
        from participare
        where editie_id = an;
        if test1 = 0 then
            raise exceptie1;
        end if;
        
        select count(*) into test2
        from nationalitate
        where nume_n = nat;
        if test2 = 0 then
            raise exceptie2;
        end if;
        
        select nationalitate_id into cod_nat
        from nationalitate
        where nume_n = nat;
        
        for i in jucatori(cod_nat) loop
            select count(*) into cnt
            from participare natural join punctaj natural join rezultat
            where jucator_id = i.jucator_id and editie_id = an and nume_rezultat = 'castigator';
            raspuns := raspuns + cnt;
        end loop;
        
    return raspuns;
    exception
        when exceptie1 then
            dbms_output.put_line('Nu s-au jucat turnee in acest an!');
            return -1;
        when exceptie2 then
            dbms_output.put_line('Nationalitatea este gresita!');
            return -2;
        when others then
            return -3;
    end turnee_castigate;
    
    -- cerinta 9
    function ultimul_an(tip tip_turneu.nume_tip%TYPE)
    return number is
        type vector_ani is varray(10) of editie.editie_id%TYPE;
        ani vector_ani := vector_ani();
        type vector_turnee is varray(10) of turneu.turneu_id%TYPE;
        turnee vector_turnee := vector_turnee();
        type vector_stangaci is varray(10) of jucator.jucator_id%TYPE;
        stangaci vector_stangaci := vector_stangaci();
        
        exceptie1 exception;
        exceptie2 exception;
        
        cod_tip tip_turneu.tip_id%TYPE;
        cnt number;
    begin
        select tip_id into cod_tip
        from tip_turneu
        where nume_tip = tip;
        
        select distinct(editie_id)
        bulk collect into ani
        from participare
        order by editie_id desc;
        
        if ani.count = 0 then
            raise exceptie1;
        end if;
        
        select jucator_id
        bulk collect into stangaci
        from caracteristici_jucator
        where mana_dominanta = 'stanga';
        
        if stangaci.count = 0 then
            raise exceptie2;
        end if;
        
        for i in 1..ani.count loop
            select distinct(turneu_id)
            bulk collect into turnee
            from participare natural join turneu
            where tip_id = cod_tip and editie_id = ani(i);
            
            if turnee.count != 0 then
                for j in 1..turnee.count loop
                    for k in 1..stangaci.count loop
                        select count(*)
                        into cnt
                        from participare natural join punctaj natural join rezultat
                        where jucator_id = stangaci(k) and turneu_id = turnee(j) and editie_id = ani(i) and nume_rezultat = 'castigator';
                        
                        if cnt > 0 then
                            return ani(i);
                        end if;
                    end loop;
                end loop;
            end if;
        end loop;
        
        dbms_output.put_line('Niciun stangaci nu a castigat tipul asta de turneu!');
        return -1;
    exception
        when no_data_found then
            dbms_output.put_line('Tipul turneului este gresit!');
            return -2;
        when too_many_rows then
            dbms_output.put_line('Nu cred ca poate sa apara in procedura aceasta!');
            return -3;
        when exceptie1 then
            dbms_output.put_line('Aparent nu s-o jucat tenis niciodata!');
            return -4;
        when exceptie2 then
            dbms_output.put_line('Nu exista jucatori stangaci!');
            return -5;
        when others then
            dbms_output.put_line('N-am prevazut aceasta eroare!');
    end;
END proiect;
/

begin
    dbms_output.put_line(proiect.ultimul_an('Grand Slam'));
    dbms_output.put_line(proiect.ultimul_an('ATP Finals'));
    dbms_output.put_line(proiect.ultimul_an('Vocea Romaniei'));
end;
/

begin
    proiect.afisare_antrenori_sponsori(1, 2021);
end;
/

-- cerinta 10
CREATE OR REPLACE TRIGGER max_tip
    BEFORE INSERT ON tip_turneu
DECLARE
    cnt number;
BEGIN
    select count(*)
    into cnt
    from tip_turneu;
    
    if cnt >= 5 then
        raise_application_error(-20001, 'Exista doar 5 tipuri de turnee oficiale!');
    end if;
END;
/

insert into tip_turneu
values(6, 'Turneu neoficial', 100);

-- cerinta 11
CREATE OR REPLACE TRIGGER actualizare_clasament
    AFTER INSERT OR UPDATE ON editie
    FOR EACH ROW
DECLARE
    type info is record(
    cod_jucator jucator.jucator_id%TYPE,
    valoare punctaj.valoare%TYPE);
    type vector is varray(10) of info;
    vechi vector := vector();
    nou vector := vector();
BEGIN
    IF :new.incheiata = 1 THEN
        select jucator_id, valoare
        bulk collect into vechi
        from participare natural join punctaj
        where editie_id = :new.editie_id - 1 and turneu_id = :new.turneu_id and proba_id = 1;
        if vechi.count != 0 then
            for i in 1..vechi.count loop
                update clasament
                set clasament.punctaj_simplu = clasament.punctaj_simplu - vechi(i).valoare
                where jucator_id = vechi(i).cod_jucator;
            end loop;
        end if;
        
        select jucator_id, valoare
        bulk collect into nou
        from participare natural join punctaj
        where editie_id = :new.editie_id and turneu_id = :new.turneu_id and proba_id = 1;
        if nou.count != 0 then
            for i in 1..nou.count loop
                update clasament
                set clasament.punctaj_simplu = nvl(clasament.punctaj_simplu, 0) + nou(i).valoare
                where jucator_id = nou(i).cod_jucator;
            end loop;
        end if;
    END IF;
END;
/

select prenume, nume, punctaj_simplu
from jucator natural join clasament
order by punctaj_simplu desc;

insert into editie
values(2022, 1, 0);

insert into participare
values(3, 1, 1, 1, 2022);

update editie
set incheiata = 1
where editie_id = 2022 and turneu_id = 1;

rollback;

-- cerinta 12
CREATE TABLE istoric_modificari
    (utilizator varchar2(30),
    nume_bd varchar2(50),
    eveniment varchar2(20),
    nume_obiect varchar2(30),
data date);

CREATE OR REPLACE TRIGGER adauga_istoric
    AFTER CREATE OR DROP OR ALTER ON SCHEMA
BEGIN
    if user != 'NFJJUNIOR' then
        raise_application_error(-20002, 'Nu esti NFJJUNIOR!');
    end if;
    
    insert into istoric_modificari
    values(sys.login_user, sys.database_name, sys.sysevent, sys.dictionary_obj_name, sysdate);
END;
/

create table jucator2 as (select * from jucator);
drop table jucator2;

select *
from istoric_modificari;

execute proiect.modifica_sponsorizare;
/

--  cerinta 14
CREATE OR REPLACE PACKAGE bonus IS
    type juc is record(
    prenume jucator.prenume%TYPE,
    nume jucator.nume%TYPE);
    
    type finala is record(
    nume turneu.nume_turneu%TYPE,
    an editie.editie_id%TYPE,
    prenume_finalist1 jucator.prenume%TYPE,
    nume_finalist1 jucator.nume%TYPE,
    prenume_finalist2 jucator.prenume%TYPE,
    nume_finalist2 jucator.nume%TYPE);
    
    cursor c_jucatori return jucator%rowtype;
    
    -- cine e primul in clasament
    procedure primul;
    -- cine a jucat finala la proba de simplu a unei editii de turneu
    procedure finala_turneu(nume turneu.nume_turneu%TYPE, an editie.editie_id%TYPE);
    -- cate turnee a castigat un jucator
    function campion(cod_jucator jucator.jucator_id%TYPE)
    return number;
    -- cati bani primeste din sponsorizari un jucator
    function bani_sponsorizare(cod_jucator jucator.jucator_id%TYPE)
    return number;
    
END bonus;
/

CREATE OR REPLACE PACKAGE BODY bonus IS
    cursor c_jucatori
    return jucator%rowtype is
    select *
    from jucator;
    
    procedure primul
    is
        n juc;
    begin
        select * into n from
        (select prenume, nume
        from jucator natural join clasament
        order by punctaj_simplu desc)
        where rownum = 1;
        
        dbms_output.put_line(n.prenume || ' ' || n.nume);
    end primul;
    
    procedure finala_turneu(nume turneu.nume_turneu%TYPE, an editie.editie_id%TYPE)
    is
        f finala;
        cod_turneu turneu.turneu_id%TYPE;
    begin
        f.nume := nume;
        f.an := an;
        
        select turneu_id
        into cod_turneu
        from turneu
        where nume_turneu = nume;
        
        select prenume, nume
        into f.prenume_finalist1, f.nume_finalist1
        from participare natural join punctaj natural join rezultat natural join jucator
        where turneu_id = cod_turneu and editie_id = an and proba_id = 1 and nume_rezultat = 'castigator';
        
        select prenume, nume
        into f.prenume_finalist2, f.nume_finalist2
        from participare natural join punctaj natural join rezultat natural join jucator
        where turneu_id = cod_turneu and editie_id = an and proba_id = 1 and nume_rezultat = 'finalist';
        
        dbms_output.put_line(f.nume || ' ' || f.an);
        dbms_output.put_line(f.prenume_finalist1 || ' ' || f.nume_finalist1);
        dbms_output.put_line(f.prenume_finalist2 || ' ' || f.nume_finalist2);
    exception
        when no_data_found then
            dbms_output.put_line('Ori anul e gresit ori numele turneului e gresit ori nu s-au gasit cei doi finalisti!');
        when others then
            dbms_output.put_line('N-am prevazut aceasta eroare!');
    end finala_turneu;
    
    function campion(cod_jucator jucator.jucator_id%TYPE)
    return number is
        raspuns number;
    begin
        select count(*) 
        into raspuns
        from participare natural join punctaj natural join rezultat
        where jucator_id = cod_jucator and nume_rezultat = 'castigator';
        
        return raspuns;
    end campion;
    
    function bani_sponsorizare(cod_jucator jucator.jucator_id%TYPE)
    return number is
        raspuns number := 0;
    begin
        select sum(suma)
        into raspuns
        from sponsorizare natural join jucator
        where jucator_id = cod_jucator and data_sfarsit is null;
        
        return raspuns;
    end bani_sponsorizare;
END bonus;
/

begin
    bonus.primul;
    dbms_output.new_line;
    
    bonus.finala_turneu('Roland Garros', 2021);
    dbms_output.new_line;
    
    dbms_output.put_line('Jucatorul a castigat ' || bonus.campion(2) || ' turnee!');
    dbms_output.new_line;
    
    dbms_output.put_line(bonus.bani_sponsorizare(5));
    dbms_output.new_line;
end;
/