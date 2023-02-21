create table ANTRENOR
(antrenor_id number(5),
nume_antrenor varchar2(25) constraint antrenor_nume_nn not null,
prenume_antrenor varchar2(25) constraint antrenor_prenume_nn not null,
gen char(1) constraint antrenor_gen_nn not null,
constraint antrenor_genul check(gen = 'M' or gen = 'F'),
constraint antrenor_id_pk primary key(antrenor_id));

create table SPONSOR
(sponsor_id number(5),
nume_sponsor varchar2(50) constraint sponsor_nume_nn not null,
constraint sponsor_id_pk primary key(sponsor_id));

create table NATIONALITATE
(nationalitate_id number(3),
nume_n varchar2(20) constraint nationalitate_nume_nn not null,
constraint nationalitate_id_pk primary key(nationalitate_id));

create table JUCATOR
(jucator_id number(5),
nume varchar2(25) constraint jucator_nume_nn not null,
prenume varchar2(25) constraint jucator_prenume_nn not null,
data_nasterii date constraint jucator_data_nasterii_nn not null,
nationalitate_id number(5),
partener_la_dublu number(5),
constraint jucator_id_pk primary key(jucator_id),
constraint jucator_nationalitate_id_fk foreign key(nationalitate_id)
references NATIONALITATE(nationalitate_id));

create table ANTRENAMENT
(jucator_id number(5),
antrenor_id number(5),
data_inceput date,
data_sfarsit date,
salariul number(10),
constraint antrenament_pk primary key(jucator_id, antrenor_id, data_inceput),
constraint antrenament_jucator_id_fk foreign key(jucator_id)
references JUCATOR(jucator_id),
constraint antrenament_antrenor_id_fk foreign key(antrenor_id)
references ANTRENOR(antrenor_id));

create table SPONSORIZARE
(jucator_id number(5),
sponsor_id number(5),
data_inceput date,
data_sfarsit date,
suma number(10) constraint sponsorizare_suma_nn not null,
constraint sponsorizare_pk primary key(jucator_id, sponsor_id, data_inceput),
constraint sponsorizare_jucator_id_fk foreign key(jucator_id)
references JUCATOR(jucator_id),
constraint sponsorizare_sponsor_id_fk foreign key(sponsor_id)
references SPONSOR(sponsor_id));

create table CARACTERISTICI_JUCATOR
(jucator_id number(5),
inaltime number(3) constraint inaltime_nn not null,
greutate number(3) constraint greutate_nn not null,
mana_dominanta varchar2(10) constraint mana_dominanta_nn not null,
tip_backhand varchar2(20) constraint tip_backhand_nn not null,
constraint cj_jucator_id_pk primary key(jucator_id),
constraint cj_jucator_id_fk foreign key(jucator_id)
references JUCATOR(jucator_id));

create table CLASAMENT
(jucator_id number(5),
punctaj_simplu number(5),
punctaj_dublu number(5),
constraint c_jucator_id_pk primary key(jucator_id),
constraint c_jucator_id_fk foreign key(jucator_id)
references JUCATOR(jucator_id));

create table ADRESA
(adresa_id number(5),
oras varchar2(25) constraint adresa_oras_nn not null,
tara varchar2(25) constraint tara_oras_nn not null,
constraint adresa_id_pk primary key(adresa_id));

create table TIP_TURNEU
(tip_id number(2),
nume_tip varchar2(25) constraint tt_nume_nn not null,
punctaj_max number(4) constraint tt_punctaj_max_nn not null,
constraint tip_turneu_pk primary key(tip_id));

create table TURNEU
(turneu_id number(5),
tip_id number(2),
nume_turneu varchar2(25) constraint turneu_nume_nn not null,
suprafata_de_joc varchar2(6) constraint turneu_sj_nn not null,
nr_de_jucatori number(3) constraint turneu_nj_nn not null,
adresa_id number(5),
constraint turneu_id_pk primary key(turneu_id),
constraint turneu_tip_id_fk foreign key(tip_id)
references TIP_TURNEU(tip_id),
constraint turneu_adresa_id_fk foreign key(adresa_id)
references ADRESA(adresa_id));

create table EDITIE
(editie_id number(4),
turneu_id number(4),
incheiata number(1) constraint incheiata_nn not null,
constraint editie_pk primary key(editie_id, turneu_id),
constraint editie_turneu_id_fk foreign key(turneu_id)
references TURNEU(turneu_id));

create table PROBA
(proba_id number(1),
nume_proba varchar2(6) constraint proba_nume_nn not null,
constraint proba_pk primary key(proba_id),
constraint probe check(nume_proba = 'simplu' or nume_proba = 'dublu'));

create table REZULTAT
(rezultat_id number(1),
nume_rezultat varchar2(20) constraint rezultat_nume_nn not null,
constraint rezultat_pk primary key(rezultat_id));

create table PUNCTAJ
(punctaj_id number(2),
tip_id number(2),
rezultat_id number(1),
valoare number(4) constraint punctaj_valoare_nn not null,
constraint punctaj_pk primary key(punctaj_id),
constraint punctaj_tip_id_fk foreign key(tip_id)
references TIP_TURNEU(tip_id),
constraint punctaj_rezultat_id_fk foreign key(rezultat_id)
references REZULTAT(rezultat_id));

create table PARTICIPARE
(jucator_id number(5),
turneu_id number(5),
proba_id number(1),
punctaj_id number(2),
editie_id number(4),
constraint participare_pk primary key(jucator_id, turneu_id, proba_id, punctaj_id, editie_id),
constraint participare_jucator_id_fk foreign key(jucator_id)
references JUCATOR(jucator_id),
constraint participare_editie_fk foreign key(editie_id, turneu_id)
references EDITIE(editie_id, turneu_id),
constraint participare_proba_id_fk foreign key(proba_id)
references PROBA(proba_id),
constraint participare_punctaj_id_fk foreign key(punctaj_id)
references PUNCTAJ(punctaj_id));

create sequence seq_jucator 
increment by 1 
start with 1 
maxvalue 99999 
nocycle 
nocache;

insert into ANTRENOR
values(1, 'Ferrero', 'Juan Carlos', 'M');
insert into ANTRENOR
values(2, 'Becker', 'Boris', 'M');
insert into ANTRENOR
values(3, 'Ivanisevic', 'Goran', 'M');
insert into ANTRENOR
values(4, 'Ljubicic', 'Ivan', 'M');
insert into ANTRENOR
values(5, 'Nadal', 'Antonio', 'M');

insert into SPONSOR
values(1, 'Nike');
insert into SPONSOR
values(2, 'Adidas');
insert into SPONSOR
values(3, 'Puma');
insert into SPONSOR
values(4, 'Lacoste');
insert into SPONSOR
values(5, 'Polo');

insert into NATIONALITATE
values(1, 'Român');
insert into NATIONALITATE
values(2, 'Spaniol');
insert into NATIONALITATE
values(3, 'Elve?ian');
insert into NATIONALITATE
values(4, 'Brazilian');
insert into NATIONALITATE
values(5, 'Sârb');

insert into JUCATOR
values(seq_jucator.nextval, 'Federer', 'Roger', to_date('08-08-1981', 'dd-mm-yyyy'), 3, null);
insert into JUCATOR
values(seq_jucator.nextval, 'Nadal', 'Rafael', to_date('03-06-1986', 'dd-mm-yyyy'), 2, 5);
insert into JUCATOR
values(seq_jucator.nextval, 'Djokovic', 'Novak', to_date('22-05-1987', 'dd-mm-yyyy'), 5, null);
insert into JUCATOR
values(seq_jucator.nextval, 'Wawrinka', 'Stan', to_date('28-03-1985', 'dd-mm-yyyy'), 3, null);
insert into JUCATOR
values(seq_jucator.nextval, 'Alcaraz', 'Carlos', to_date('05-05-2003', 'dd-mm-yyyy'), 2, 2);

insert into CARACTERISTICI_JUCATOR
values(1, 185, 85, 'dreapta', 'cu o mana');
insert into CARACTERISTICI_JUCATOR
values(2, 185, 85, 'stanga', 'cu doua maini');
insert into CARACTERISTICI_JUCATOR
values(3, 188, 77, 'dreapta', 'cu doua maini');
insert into CARACTERISTICI_JUCATOR
values(4, 183, 81, 'dreapta', 'cu o mana');
insert into CARACTERISTICI_JUCATOR
values(5, 185, 72, 'dreapta', 'cu doua maini');

insert into CLASAMENT
values(1, 4000, null);
insert into CLASAMENT
values(2, 5000, 2500);
insert into CLASAMENT
values(3, 10000, null);
insert into CLASAMENT
values(4, 2000, null);
insert into CLASAMENT
values(5, 3500, 3500);

insert into PROBA
values(1, 'simplu');
insert into PROBA
values(2, 'dublu');

insert into TIP_TURNEU
values(1, 'Grand Slam', 2000);
insert into TIP_TURNEU
values(2, 'ATP Masters', 1000);
insert into TIP_TURNEU
values(3, 'ATP 500 Series', 500);
insert into TIP_TURNEU
values(4, 'ATP 250 Series', 250);
insert into TIP_TURNEU
values(5, 'ATP Finals', 1500);

insert into ADRESA
values(1, 'Paris', 'Franta');
insert into ADRESA
values(2, 'Londra', 'Anglia');
insert into ADRESA
values(3, 'Roma', 'Italia');
insert into ADRESA
values(4, 'Madrid', 'Spania');
insert into ADRESA
values(5, 'Dubai', 'Emiratele Arabe Unite');

insert into TURNEU
values(1, 1, 'Roland Garros', 'zgura', 128, 1);
insert into TURNEU
values(2, 1, 'Wimbledon', 'iarba', 128, 2);
insert into TURNEU
values(3, 2, 'Italian Open', 'zgura', 56, 3);
insert into TURNEU
values(4, 2, 'Madrid Open', 'zgura', 56, 4);
insert into TURNEU
values(5, 3, 'Dubai Open', 'ciment', 32, 5);

insert into REZULTAT
values(1, 'castigator');
insert into REZULTAT
values(2, 'finalist');
insert into REZULTAT
values(3, 'semifinalist');
insert into REZULTAT
values(4, 'sfertfinalist');
insert into REZULTAT
values(5, 'runda 1');

insert into PUNCTAJ
values(1, 1, 1, 2000);
insert into PUNCTAJ
values(2, 1, 2, 1200);
insert into PUNCTAJ
values(3, 2, 1, 1000);
insert into PUNCTAJ
values(4, 2, 2, 600);
insert into PUNCTAJ
values(5, 3, 1, 500);
insert into PUNCTAJ
values(6, 3, 2, 300);

insert into ANTRENAMENT
values(1, 4, to_date('01-01-2015', 'dd-mm-yyyy'), null, 100000);
insert into ANTRENAMENT
values(1, 1, to_date('01-01-2014', 'dd-mm-yyyy'), to_date('31-12-2014', 'dd-mm-yyyy'), 80000);
insert into ANTRENAMENT
values(1, 3, to_date('01-01-2013', 'dd-mm-yyyy'), to_date('31-12-2013', 'dd-mm-yyyy'), 70000);
insert into ANTRENAMENT
values(2, 5, to_date('01-01-2008', 'dd-mm-yyyy'), null, null);
insert into ANTRENAMENT
values(2, 2, to_date('01-01-2010', 'dd-mm-yyyy'), to_date('31-12-2012', 'dd-mm-yyyy'), 55000);
insert into ANTRENAMENT
values(3, 2, to_date('01-01-2013', 'dd-mm-yyyy'), null, 120000);
insert into ANTRENAMENT
values(3, 3, to_date('01-01-2014', 'dd-mm-yyyy'), null, 120000);
insert into ANTRENAMENT
values(4, 4, to_date('01-01-2010', 'dd-mm-yyyy'), to_date('31-12-2014', 'dd-mm-yyyy'), 50000);
insert into ANTRENAMENT
values(5, 1, to_date('01-01-2015', 'dd-mm-yyyy'), null, 100000);
insert into ANTRENAMENT
values(5, 1, to_date('01-01-2013', 'dd-mm-yyyy'), to_date('31-12-2013', 'dd-mm-yyyy'), 20000);

insert into SPONSORIZARE
values(1, 1, to_date('01-01-2010', 'dd-mm-yyyy'), to_date('31-12-2020', 'dd-mm-yyyy'), 50000);
insert into SPONSORIZARE
values(1, 2, to_date('01-01-2021', 'dd-mm-yyyy'), null, 60000);
insert into SPONSORIZARE
values(2, 4, to_date('01-01-2010', 'dd-mm-yyyy'), null, 75000);
insert into SPONSORIZARE
values(2, 5, to_date('01-01-2015', 'dd-mm-yyyy'), null, 65000);
insert into SPONSORIZARE
values(3, 1, to_date('01-01-2010', 'dd-mm-yyyy'), to_date('31-12-2014', 'dd-mm-yyyy'), 40000);
insert into SPONSORIZARE
values(3, 3, to_date('01-01-2015', 'dd-mm-yyyy'), null, 80000);
insert into SPONSORIZARE
values(4, 1, to_date('01-01-2010', 'dd-mm-yyyy'), to_date('31-12-2014', 'dd-mm-yyyy'), 50000);
insert into SPONSORIZARE
values(4, 3, to_date('01-01-2015', 'dd-mm-yyyy'), null, 80000);
insert into SPONSORIZARE
values(5, 2, to_date('01-01-2020', 'dd-mm-yyyy'), null, 20000);
insert into SPONSORIZARE
values(5, 5, to_date('01-01-2020', 'dd-mm-yyyy'), null, 35000);

insert into EDITIE
values(2020, 2, 1);
insert into EDITIE
values(2021, 2, 1);
insert into EDITIE
values(2021, 1, 1);
insert into EDITIE
values(2021, 3, 1);
insert into EDITIE
values(2021, 4, 1);
insert into EDITIE
values(2022, 4, 1);


insert into PARTICIPARE
values(1, 2, 1, 2, 2020);
insert into PARTICIPARE
values(1, 2, 1, 1, 2021);
insert into PARTICIPARE
values(3, 2, 1, 1, 2020);
insert into PARTICIPARE
values(3, 1, 1, 2, 2021);
insert into PARTICIPARE
values(2, 1, 1, 1, 2021);
insert into PARTICIPARE
values(2, 1, 2, 1, 2021);
insert into PARTICIPARE
values(4, 3, 1, 4, 2021);
insert into PARTICIPARE
values(4, 4, 1, 3, 2021);
insert into PARTICIPARE
values(5, 4, 1, 3, 2022);
insert into PARTICIPARE
values(5, 1, 2, 1, 2021);

commit;














