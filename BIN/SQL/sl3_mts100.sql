/*caricamento modulo per funzioni aggiuntive*/
.load .\\BIN\\EXE\\libsqlitefunctions.so

drop table if exists mtsimp;
CREATE TABLE mtsimp (
 POS TEXT /*Apparato                 */
,DT1 TEXT /*Data1                    */
,DT2 TEXT /*Data2                    */
,DT3 TEXT /*Data3                    */
,DTG TEXT /*Giorno                   */
,DTM TEXT /*Mese                     */
,DTA TEXT /*Anno                     */
,COR TEXT /*Corsia                   */
,SCT TEXT /*Solo_Conteggio           */
,AUM TEXT /*Auto_Monovolume          */
,AUR TEXT /*Auto_Monovolume_Rimorchio*/
,CMP TEXT /*Furgoncini_Camioncini    */
,CMM TEXT /*Camion_Medi              */
,CMG TEXT /*Camion_Grandi            */
,AUT TEXT /*Autotreni                */
,AUA TEXT /*Autoarticolati           */
,BUS TEXT /*Autobus                  */
,ALT TEXT /*Altri                    */
)
;

drop table if exists mtsimperr;
CREATE TABLE mtsimperr as
select '' ERR,'' FLD, a.* from mtsimp a;
;


/*import dal file CSV*/
/*copia di MTS_2014.csv*/
.separator ,
.import .\\tmp\\mts.csv mtsimp


drop table if exists mtswrk;
create table mtswrk as 
select POS
     , DT1,SUBSTR(DT1,1,2) DT1GIO,SUBSTR(DT1,4,2) DT1MES,SUBSTR(DT1,7,4) DT1ANN
     , DT2,SUBSTR(DT2,1,2) DT2GIO,SUBSTR(DT2,4,2) DT2MES,SUBSTR(DT2,7,4) DT2ANN
     , DT3,SUBSTR(DT3,9,2) DT3GIO,SUBSTR(DT3,6,2) DT3MES,SUBSTR(DT3,1,4) DT3ANN
     , substr('00'||DTG||' ',-1,-2) DTG, substr('00'||DTM||' ',-1,-2) DTM,DTA
     , COR,SCT
     , AUM,AUR,CMP,CMM,CMG,AUT,AUA,BUS,ALT
  FROM MTSIMP
 WHERE ROWID>1 
;

insert into mtsimperr
select 'date non congruenti','DT1'  
     , POS,DT1,DT2,DT3,DTG,DTM,DTA
     , COR,SCT
     , AUM,AUR,CMP,CMM,CMG,AUT,AUA,BUS,ALT  
  from mtswrk
 where not (dt1gio=dtg and dt1mes=dtm and dt1ann=dta)
;    

insert into mtsimperr
select 'date non congruenti','DT2'  
     , POS,DT1,DT2,DT3,DTG,DTM,DTA
     , COR,SCT
     , AUM,AUR,CMP,CMM,CMG,AUT,AUA,BUS,ALT  
  from mtswrk
 where not (dt2gio=dtg and dt2mes=dtm and dt2ann=dta)
;    

insert into mtsimperr
select 'date non congruenti','DT3'  
     , POS,DT1,DT2,DT3,DTG,DTM,DTA
     , COR,SCT
     , AUM,AUR,CMP,CMM,CMG,AUT,AUA,BUS,ALT  
  from mtswrk
 where not (dt3gio=dtg and dt3mes=dtm and dt3ann=dta)
;    

insert into mtsimperr
select 'data non valida','DT*'  
     , POS,DT1,DT2,DT3,DTG,DTM,DTA
     , COR,SCT
     , AUM,AUR,CMP,CMM,CMG,AUT,AUA,BUS,ALT  
  from mtswrk
 where (date(dta||'-'||dtm||'-'||dtg,'+1 days','-1 days')<>date(dta||'-'||dtm||'-'||dtg))
;    

insert into mtsimperr
select 'data futura','DT*'  
     , POS,DT1,DT2,DT3,DTG,DTM,DTA
     , COR,SCT
     , AUM,AUR,CMP,CMM,CMG,AUT,AUA,BUS,ALT  
  from mtswrk
 where date(dta||'-'||dtm||'-'||dtg)>date('now')
;    


insert into mtsimperr
select 'postazione non censita','POS'  
     , a.POS,a.DT1,a.DT2,a.DT3,a.DTG,a.DTM,a.DTA
     , a.COR,a.SCT
     , a.AUM,a.AUR,a.CMP,a.CMM,a.CMG,a.AUT,a.AUA,a.BUS,a.ALT  
  from mtswrk a left join upm b on b.pos=a.pos
 where b.pos is null
;  

drop table if exists wrkfin;
create table wrkfin as
select pos,cor,dta,dtm,dtg
     , sct
     , AUM,AUR,CMP,CMM,CMG,AUT,AUA,BUS,ALT
  from mtswrk
;


/*log dei record gia' presenti*/
select 'record gia'' presente' ERR, '***' FLD
     , a.* 
  from wrkfin a
 where exists (select 'x' from mts x 
                where x.pos=a.pos and x.cor=a.cor and x.dta=a.dta and x.dtm=a.dtm and x.dtg=a.dtg)   
;

/*log dei record errati*/
select * from mtsimperr;

/*inserimento dei record nella tabella master*/
insert into mts
select * from wrkfin a
 where not exists (select 'x' from mts x 
                    where x.pos=a.pos and x.cor=a.cor and x.dta=a.dta and x.dtm=a.dtm and x.dtg=a.dtg)  
   and not exists (select 'x' from mtsimperr x)
;  

   