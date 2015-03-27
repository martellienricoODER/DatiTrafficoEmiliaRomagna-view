/*crea la tabella per l'aggiornamento di un campo*/
/*INPUT  tabella _val(key,val)*/
/*OUTPUT tabella _val_upd(key,val)*/

/*TABELLE RICHIESTE:
-   lstchr(lstchr)          contiene la lista dei caratteri validi
-   trachr(oldchr,newchr)   tabella di traduzione dei caratteri non validi
*/

/*todo: ?un controllo che la tabella trachr non contenga valori in lstchr?*/

/*100   carico delle tabelle aggiornate*/
/*  110 lista dei caratteri validi*/
drop table if exists cfg_lstchr;
.separator ,
.import .\\cfg\\lstchr.txt cfg_lstchr

/*  120 carico la tabella di traduzione aggiornata*/
drop table if exists cfg_trachr;
.separator ,
.import .\\cfg\\trachr.txt cfg_trachr

/*200 creazione tabella d'uscita*/
drop table if exists _val_upd;
create table if not exists _val_upd as 
with recursive wrk(itr,key,val) as (
select (select count(*) from cfg_trachr) itr,key,val                                                   
  from _val a,cfg_lstchr b
 where lower(a.val)<>strfilter(lower(a.val),b.lstchr)
union all
select a.itr-1 itr,a.key,replace(a.val,c.oldchr,c.newchr) tratto                                                   
  from wrk a,cfg_lstchr b,cfg_trachr c
 where c.rowid=a.itr)
select distinct key,val from wrk where itr=0
;


