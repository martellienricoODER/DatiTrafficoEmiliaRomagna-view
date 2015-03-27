
/*i record in mts sono suddivisi per corsie
non avendo intenzione di fare grafi orientati 
occorre sommare i valori delle corsia per ogni postazione
*/

drop table if exists dat001;
create table dat001 as
select pos,datetime(dta||'-'||dtm||'-'||dtg) dta
     , sum(AUM) AUM,sum(AUR) AUR             , sum(AUM+AUR) TOTAUT
     , sum(CMP) CMP,sum(CMM) CMM,sum(CMG) CMG, sum(CMP+CMM+CMG) TOTCAM
     , sum(AUT) AUT,sum(AUA) AUA             , sum(AUT+AUA) TOTATR
     , sum(BUS) BUS,sum(ALT) ALT             , sum(BUS+ALT) TOTBEA
     , sum(AUM+AUR+CMP+CMM+CMG+AUT+AUA+BUS+ALT) TOT
  from mts
 group by pos,dta,dtm,dtg
;
                
/*calcolo i valori statistici per ogni postazione*/
drop table if exists day;
create table day as
with recursive n(n) as (select 0 union all select n+1 from n where n+1<=6) 
select cast(n as text) day from n;
;

drop view if exists dat002;
create view dat002 as
select 
  pos,count(*) CNT   
, sum(AUM   ) sumAUM   , max(AUM   ) maxAUM   , cast(avg(AUM   ) as INTEGER) avgAUM   
, sum(AUR   ) sumAUR   , max(AUR   ) maxAUR   , cast(avg(AUR   ) as INTEGER) avgAUR   
, sum(TOTAUT) sumTOTAUT, max(TOTAUT) maxTOTAUT, cast(avg(TOTAUT) as INTEGER) avgTOTAUT
, sum(CMP   ) sumCMP   , max(CMP   ) maxCMP   , cast(avg(CMP   ) as INTEGER) avgCMP   
, sum(CMM   ) sumCMM   , max(CMM   ) maxCMM   , cast(avg(CMM   ) as INTEGER) avgCMM   
, sum(CMG   ) sumCMG   , max(CMG   ) maxCMG   , cast(avg(CMG   ) as INTEGER) avgCMG   
, sum(TOTCAM) sumTOTCAM, max(TOTCAM) maxTOTCAM, cast(avg(TOTCAM) as INTEGER) avgTOTCAM
, sum(AUT   ) sumAUT   , max(AUT   ) maxAUT   , cast(avg(AUT   ) as INTEGER) avgAUT   
, sum(AUA   ) sumAUA   , max(AUA   ) maxAUA   , cast(avg(AUA   ) as INTEGER) avgAUA   
, sum(TOTATR) sumTOTATR, max(TOTATR) maxTOTATR, cast(avg(TOTATR) as INTEGER) avgTOTATR
, sum(BUS   ) sumBUS   , max(BUS   ) maxBUS   , cast(avg(BUS   ) as INTEGER) avgBUS   
, sum(ALT   ) sumALT   , max(ALT   ) maxALT   , cast(avg(ALT   ) as INTEGER) avgALT   
, sum(TOTBEA) sumTOTBEA, max(TOTBEA) maxTOTBEA, cast(avg(TOTBEA) as INTEGER) avgTOTBEA
, sum(TOT   ) sumTOT   , max(TOT   ) maxTOT   , cast(avg(TOT   ) as INTEGER) avgTOT   
  from dat001,day 
 where strftime('%w',dta)= day
   and tot<>0  
 group by pos 
union
select 
  '_0_' pos,count(*) CNT   
, sum(AUM   ) sumAUM   , max(AUM   ) maxAUM   , cast(avg(AUM   ) as INTEGER) avgAUM   
, sum(AUR   ) sumAUR   , max(AUR   ) maxAUR   , cast(avg(AUR   ) as INTEGER) avgAUR   
, sum(TOTAUT) sumTOTAUT, max(TOTAUT) maxTOTAUT, cast(avg(TOTAUT) as INTEGER) avgTOTAUT
, sum(CMP   ) sumCMP   , max(CMP   ) maxCMP   , cast(avg(CMP   ) as INTEGER) avgCMP   
, sum(CMM   ) sumCMM   , max(CMM   ) maxCMM   , cast(avg(CMM   ) as INTEGER) avgCMM   
, sum(CMG   ) sumCMG   , max(CMG   ) maxCMG   , cast(avg(CMG   ) as INTEGER) avgCMG   
, sum(TOTCAM) sumTOTCAM, max(TOTCAM) maxTOTCAM, cast(avg(TOTCAM) as INTEGER) avgTOTCAM
, sum(AUT   ) sumAUT   , max(AUT   ) maxAUT   , cast(avg(AUT   ) as INTEGER) avgAUT   
, sum(AUA   ) sumAUA   , max(AUA   ) maxAUA   , cast(avg(AUA   ) as INTEGER) avgAUA   
, sum(TOTATR) sumTOTATR, max(TOTATR) maxTOTATR, cast(avg(TOTATR) as INTEGER) avgTOTATR
, sum(BUS   ) sumBUS   , max(BUS   ) maxBUS   , cast(avg(BUS   ) as INTEGER) avgBUS   
, sum(ALT   ) sumALT   , max(ALT   ) maxALT   , cast(avg(ALT   ) as INTEGER) avgALT   
, sum(TOTBEA) sumTOTBEA, max(TOTBEA) maxTOTBEA, cast(avg(TOTBEA) as INTEGER) avgTOTBEA
, sum(TOT   ) sumTOT   , max(TOT   ) maxTOT   , cast(avg(TOT   ) as INTEGER) avgTOT   
  from dat001,day 
 where strftime('%w',dta)= day
   and tot<>0   
;  

delete from day;
insert into day
with recursive n(n) as (select 0 union all select n+1 from n where n+1<=6) 
select cast(n as text) day from n where n between 1 and 5;
;

drop table if exists dat002FER;
create table dat002FER as
select * from dat002
;

delete from day;
insert into day
with recursive n(n) as (select 0 union all select n+1 from n where n+1<=6) 
select cast(n as text) day from n where n not between 1 and 5;
;

drop table if exists dat002FES;
create table dat002FES as
select * from dat002
;

delete from day;
insert into day
with recursive n(n) as (select 0 union all select n+1 from n where n+1<=6) 
select cast(n as text) day from n;
;


/*collasso la descrizione del punto di misura in un unica riga*/
drop table if exists dat003;
create table dat003 as
select POS,TRT,NNC,PKM,X,Y,max(upm.rowid) RID 
  from upm group by POS,TRT,NNC,PKM,X,Y
; 



drop table if exists cfg;
create table cfg as
select 'JS' tip,'DAT' var;

/*imposto il file di output*/
.output .\\tmp\\sl3_dat2json_tmpwrk.sql
.header off
.mode list
select '.output .\\dat\\'|| var || case tip when 'JS' then '.js' else '.json' end from cfg; 
.output stdout
.read .\\tmp\\sl3_dat2json_tmpwrk.sql

/*
drop table if exists wrk;
create table wrk as 
select RID,a.POS POS,TRT,NNC,PKM,X,Y
, CNT   
, sumAUM   , maxAUM   , avgAUM
, sumAUR   , maxAUR   , avgAUR                   
, sumTOTAUT, maxTOTAUT, avgTOTAUT
, sumCMP   , maxCMP   , avgCMP
, sumCMM   , maxCMM   , avgCMM
, sumCMG   , maxCMG   , avgCMG
, sumTOTCAM, maxTOTCAM, avgTOTCAM
, sumAUT   , maxAUT   , avgAUT
, sumAUA   , maxAUA   , avgAUA                   
, sumTOTATR, maxTOTATR, avgTOTATR
, sumBUS   , maxBUS   , avgBUS
, sumALT   , maxALT   , avgALT                   
, sumTOTBEA, maxTOTBEA, avgTOTBEA
, sumTOT   , maxTOT   , avgTOT
, ' POS      : "'||a.POS    ||'", TRT      : "'||TRT      ||'", NNC      : "'||NNC      ||'", PKM      : "'||PKM      ||  '", CNT      : "'||CNT      ||
'", sumAUM   : "'||sumAUM   ||'", maxAUM   : "'||maxAUM   ||'", avgAUM   : "'||avgAUM   ||
'", sumAUR   : "'||sumAUR   ||'", maxAUR   : "'||maxAUR   ||'", avgAUR   : "'||avgAUR   ||
'", sumTOTAUT: "'||sumTOTAUT||'", maxTOTAUT: "'||maxTOTAUT||'", avgTOTAUT: "'||avgTOTAUT||
'", sumCMP   : "'||sumCMP   ||'", maxCMP   : "'||maxCMP   ||'", avgCMP   : "'||avgCMP   ||
'", sumCMM   : "'||sumCMM   ||'", maxCMM   : "'||maxCMM   ||'", avgCMM   : "'||avgCMM   ||
'", sumCMG   : "'||sumCMG   ||'", maxCMG   : "'||maxCMG   ||'", avgCMG   : "'||avgCMG   ||
'", sumTOTCAM: "'||sumTOTCAM||'", maxTOTCAM: "'||maxTOTCAM||'", avgTOTCAM: "'||avgTOTCAM||
'", sumAUT   : "'||sumAUT   ||'", maxAUT   : "'||maxAUT   ||'", avgAUT   : "'||avgAUT   ||
'", sumAUA   : "'||sumAUA   ||'", maxAUA   : "'||maxAUA   ||'", avgAUA   : "'||avgAUA   ||
'", sumTOTATR: "'||sumTOTATR||'", maxTOTATR: "'||maxTOTATR||'", avgTOTATR: "'||avgTOTATR||
'", sumBUS   : "'||sumBUS   ||'", maxBUS   : "'||maxBUS   ||'", avgBUS   : "'||avgBUS   ||
'", sumALT   : "'||sumALT   ||'", maxALT   : "'||maxALT   ||'", avgALT   : "'||avgALT   ||
'", sumTOTBEA: "'||sumTOTBEA||'", maxTOTBEA: "'||maxTOTBEA||'", avgTOTBEA: "'||avgTOTBEA||
'", sumTOT   : "'||sumTOT   ||'", maxTOT   : "'||maxTOT   ||'", avgTOT   : "'||avgTOT   ||'"' jsn
  from dat003 a join dat002 b on b.pos=a.pos
;            
*/

drop table if exists wrk;
create table wrk as 
with dat as (
select RID,a.POS POS,TRT,NNC,PKM,X,Y
/*tutti i giorni*/
  /*conteggi*/
  , b.sumTOT         a_s_TOT   
      , b.sumTOTAUT  a_s_TOTAUT
          , b.sumAUM a_s_AUM   
          , b.sumAUR a_s_AUR   
      , b.sumTOTCAM  a_s_TOTCAM
          , b.sumCMP a_s_CMP    
          , b.sumCMM a_s_CMM    
          , b.sumCMG a_s_CMG    
      , b.sumTOTATR  a_s_TOTATR
          , b.sumAUT a_s_AUT    
          , b.sumAUA a_s_AUA    
      , b.sumTOTBEA  a_s_TOTBEA
          , b.sumBUS a_s_BUS    
          , b.sumALT a_s_ALT    
  /*medie*/  
  , b.avgTOT         a_a_TOT   
      , b.avgTOTAUT  a_a_TOTAUT
          , b.avgAUM a_a_AUM   
          , b.avgAUR a_a_AUR   
      , b.avgTOTCAM  a_a_TOTCAM
          , b.avgCMP a_a_CMP   
          , b.avgCMM a_a_CMM   
          , b.avgCMG a_a_CMG   
      , b.avgTOTATR  a_a_TOTATR
          , b.avgAUT a_a_AUT   
          , b.avgAUA a_a_AUA   
      , b.avgTOTBEA  a_a_TOTBEA
          , b.avgBUS a_a_BUS   
          , b.avgALT a_a_ALT   
/*tutti i giorni feriali*/
  , c.sumTOT         r_s_TOT   
      , c.sumTOTAUT  r_s_TOTAUT
          , c.sumAUM r_s_AUM   
          , c.sumAUR r_s_AUR   
      , c.sumTOTCAM  r_s_TOTCAM
          , c.sumCMP r_s_CMP    
          , c.sumCMM r_s_CMM    
          , c.sumCMG r_s_CMG    
      , c.sumTOTATR  r_s_TOTATR
          , c.sumAUT r_s_AUT    
          , c.sumAUA r_s_AUA    
      , c.sumTOTBEA  r_s_TOTBEA
          , c.sumBUS r_s_BUS    
          , c.sumALT r_s_ALT    
  , c.avgTOT         r_a_TOT   
      , c.avgTOTAUT  r_a_TOTAUT
          , c.avgAUM r_a_AUM   
          , c.avgAUR r_a_AUR   
      , c.avgTOTCAM  r_a_TOTCAM
          , c.avgCMP r_a_CMP   
          , c.avgCMM r_a_CMM   
          , c.avgCMG r_a_CMG   
      , c.avgTOTATR  r_a_TOTATR
          , c.avgAUT r_a_AUT   
          , c.avgAUA r_a_AUA   
      , c.avgTOTBEA  r_a_TOTBEA
          , c.avgBUS r_a_BUS   
          , c.avgALT r_a_ALT   
/*tutti i giorni festivi*/
  , d.sumTOT         s_s_TOT   
      , d.sumTOTAUT  s_s_TOTAUT
          , d.sumAUM s_s_AUM   
          , d.sumAUR s_s_AUR   
      , d.sumTOTCAM  s_s_TOTCAM
          , d.sumCMP s_s_CMP    
          , d.sumCMM s_s_CMM    
          , d.sumCMG s_s_CMG    
      , d.sumTOTATR  s_s_TOTATR
          , d.sumAUT s_s_AUT    
          , d.sumAUA s_s_AUA    
      , d.sumTOTBEA  s_s_TOTBEA
          , d.sumBUS s_s_BUS    
          , d.sumALT s_s_ALT    
  , d.avgTOT         s_a_TOT   
      , d.avgTOTAUT  s_a_TOTAUT
          , d.avgAUM s_a_AUM   
          , d.avgAUR s_a_AUR   
      , d.avgTOTCAM  s_a_TOTCAM
          , d.avgCMP s_a_CMP   
          , d.avgCMM s_a_CMM   
          , d.avgCMG s_a_CMG   
      , d.avgTOTATR  s_a_TOTATR
          , d.avgAUT s_a_AUT   
          , d.avgAUA s_a_AUA   
      , d.avgTOTBEA  s_a_TOTBEA
          , d.avgBUS s_a_BUS   
          , d.avgALT s_a_ALT   
  from dat003 a join dat002 b on b.pos=a.pos
                join dat002FER c on c.pos=a.pos
                join dat002FES d on d.pos=a.pos

)
select a.*
     , '{UPM:["'||RID||'","'||POS||'","'||TRT||'","'||NNC||'","'||PKM||'","'||X||'","'||Y||
     '"],MTS_ALL:{CNT:{V:'||a_s_TOT||
                     ',D:{AUT:{V:'||a_s_TOTAUT||
                             ',D:['||a_s_AUM||','||a_s_AUR||  
                      ']},CAM:{V:'||a_s_TOTCAM||
                             ',D:['||a_s_CMP||','||a_s_CMM||','||a_s_CMG||
                      ']},ATR:{V:'||a_s_TOTATR||
                             ',D:['||a_s_AUT||','||a_s_AUA||
                      ']},BEA:{V:'||a_s_TOTBEA||
                             ',D:['||a_s_BUS||','||a_s_ALT||
            ']}}},AVG:{V:'||a_a_TOT||
                     ',D:{AUT:{V:'||a_a_TOTAUT||
                             ',D:['||a_a_AUM||','||a_a_AUR||  
                      ']},CAM:{V:'||a_a_TOTCAM||
                             ',D:['||a_a_CMP||','||a_a_CMM||','||a_a_CMG||
                      ']},ATR:{V:'||a_a_TOTATR||
                             ',D:['||a_a_AUT||','||a_a_AUA||
                      ']},BEA:{V:'||a_a_TOTBEA||
                             ',D:['||a_a_BUS||','||a_a_ALT||
  ']}}}},MTS_FER:{CNT:{V:'||r_s_TOT||
                     ',D:{AUT:{V:'||r_s_TOTAUT||
                             ',D:['||r_s_AUM||','||r_s_AUR||  
                      ']},CAM:{V:'||r_s_TOTCAM||
                             ',D:['||r_s_CMP||','||r_s_CMM||','||r_s_CMG||
                      ']},ATR:{V:'||r_s_TOTATR||
                             ',D:['||r_s_AUT||','||r_s_AUA||
                      ']},BEA:{V:'||r_s_TOTBEA||
                             ',D:['||r_s_BUS||','||r_s_ALT||
            ']}}},AVG:{V:'||r_a_TOT||
                     ',D:{AUT:{V:'||r_a_TOTAUT||
                             ',D:['||r_a_AUM||','||r_a_AUR||  
                      ']},CAM:{V:'||r_a_TOTCAM||
                             ',D:['||r_a_CMP||','||r_a_CMM||','||r_a_CMG||
                      ']},ATR:{V:'||r_a_TOTATR||
                             ',D:['||r_a_AUT||','||r_a_AUA||
                      ']},BEA:{V:'||r_a_TOTBEA||
                             ',D:['||r_a_BUS||','||r_a_ALT||
  ']}}}},MTS_FES:{CNT:{V:'||s_s_TOT||
                     ',D:{AUT:{V:'||s_s_TOTAUT||
                             ',D:['||s_s_AUM||','||s_s_AUR||  
                      ']},CAM:{V:'||s_s_TOTCAM||
                             ',D:['||s_s_CMP||','||s_s_CMM||','||s_s_CMG||
                      ']},ATR:{V:'||s_s_TOTATR||
                             ',D:['||s_s_AUT||','||s_s_AUA||
                      ']},BEA:{V:'||s_s_TOTBEA||
                             ',D:['||s_s_BUS||','||s_s_ALT||
            ']}}},AVG:{V:'||s_a_TOT||
                     ',D:{AUT:{V:'||s_a_TOTAUT||
                             ',D:['||s_a_AUM||','||s_a_AUR||  
                      ']},CAM:{V:'||s_a_TOTCAM||
                             ',D:['||s_a_CMP||','||s_a_CMM||','||s_a_CMG||
                      ']},ATR:{V:'||s_a_TOTATR||
                             ',D:['||s_a_AUT||','||s_a_AUA||
                      ']},BEA:{V:'||s_a_TOTBEA||
                             ',D:['||s_a_BUS||','||s_a_ALT||
                         ']}}}}}' jsn 
  from dat a;
;            

             
.read .\\bin\\sql\\sl3_dat2json_val.sql

with pos as (select distinct pos from dat001)
   , dta as (select distinct dta from dat001)
select a.pos pos,b.dta dta,d.x x,d.y y
, ifnull(c.TOTAUT, 0) TOTAUT
, ifnull(c.TOTCAM, 0) TOTCAM
, ifnull(c.TOTATR, 0) TOTATR  
, ifnull(c.TOTBEA, 0) TOTBEA  
, ifnull(c.TOT   , 0) TOT                 
  from pos a join dta b on 1=1 
             left join dat001 c on c.pos=a.pos and c.dta=b.dta
             join dat003 d on d.pos=a.pos
order by b.dta,a.pos+0
;

.output stdout
