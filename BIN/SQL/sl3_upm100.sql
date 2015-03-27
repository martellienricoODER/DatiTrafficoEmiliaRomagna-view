/*caricamento modulo per funzioni aggiuntive*/
.load .\\BIN\\EXE\\libsqlitefunctions.so

drop table if exists upmimp;
CREATE TABLE upmimp (
 PRG TEXT /*NUMERO_PROGRESSIVO*/ 
,POS TEXT /*POSTAZIONE*/
,LAT TEXT /*LATITUDINE_X*/ 
,LON TEXT /*LONGITUDINE_Y*/
,TRT TEXT /*TRATTO*/
,NNC TEXT /*NN_CORSIE */
,COR TEXT /*CORSIA*/
,DIR TEXT /*DIREZIONE_MARCIA_LOCALITA'*/
,PKM TEXT /*PROGRESSIVA_KM*/
)
;

drop table if exists upmimperr;
CREATE TABLE upmimperr as
select '' ERR,'' FLD, a.* from upmimp a;
;
                                                      

/*import dal file CSV*/
/*copia di Anagrafica.csv*/
.separator ,
.import .\\tmp\\upm.csv upmimp

/*verifico che vi sia univocita' tra progressivo, postazione e tratta*/
with dat as (select prg,pos from upmimp)
insert into upmimperr
select distinct 'non univocita'' tra progressivo e postazione' err,'PRG,POS' fld,c.*
  from dat a join dat b on b.prg=a.prg
             join upmimp c on c.prg=a.prg and c.pos=a.pos
 where b.pos<>a.pos
; 

with dat as (select pos,trt from upmimp)
insert into upmimperr
select distinct 'non univocita'' tra postazione e tratta' err,'POS,TRT' fld,c.*
  from dat a join dat b on b.pos=a.pos
             join upmimp c on c.pos=a.pos and c.trt=a.trt
 where b.trt<>a.trt
; 


/*modifica dei caratteri non standard - tratta*/
drop table if exists _val;
create table if not exists _val as 
select distinct PRG key,TRT val from upmimp
;          

.read .\\BIN\\SQL\\sl3_trachr.sql

update upmimp 
   set TRT=(select x.val 
              from _val_upd x 
             where x.key=upmimp.PRG )   
 where exists (select 'x' 
                 from _val_upd x 
                where x.key=upmimp.PRG )
;                                                

/*log delle anomalie residue*/
insert into upmimperr
select 'caratteri non validi' err,'TRT' fld,a.*                                                  
  from upmimp a,cfg_lstchr b
 where lower(a.TRT)<>strfilter(lower(a.TRT),b.lstchr)
;

/*modifica dei caratteri non standard - direzione*/
drop table if exists _val;
create table if not exists _val as 
select distinct PRG key,DIR val from upmimp
;          
.read .\\BIN\\SQL\\sl3_trachr.sql

update upmimp 
   set DIR=(select x.val 
                 from _val_upd x 
                where x.key=upmimp.PRG )
 where exists (select 'x' 
                 from _val_upd x 
                where x.key=upmimp.PRG )
;                                                

/*log delle anomalie residue*/
insert into upmimperr
select 'caratteri non validi' err,'DIR' fld,a.*                                                  
  from upmimp a,cfg_lstchr b
 where lower(a.dir)<>strfilter(lower(a.dir),b.lstchr)
;



/*uniformo la notazione del campo PKM*/
update upmimp
   set PKM=printf('%7.3f',replace(PKM,',','.'))
 where 1=1
;


/*uniformo la notazione dei secondi nei campi LAT LON*/
.read .\\cfg\\crdchr.sql 

update upmimp 
   set LAT=replace(LAT,'''''',(select chr from cfg_crdchr where des='secondi'))
     , LON=replace(LON,'''''',(select chr from cfg_crdchr where des='secondi'))
 where 1=1
;
update upmimp 
   set LAT=substr(LAT,1,8)||(select chr from cfg_crdchr where des='decimali')||'00'||(select chr from cfg_crdchr where des='secondi')
 where substr(LAT,9,1)=(select chr from cfg_crdchr where des='secondi')
;
update upmimp 
   set LON=substr(LON,1,8)||(select chr from cfg_crdchr where des='decimali')||'00'||(select chr from cfg_crdchr where des='secondi')
 where substr(LON,9,1)=(select chr from cfg_crdchr where des='secondi')
;

drop table if exists wrkcrd;
create table wrkcrd as 
select distinct PRG,POS
     , LAT,instr(hex(LAT),b.chr) LATGRA,instr(LAT,c.chr) LATPRI,instr(LAT,d.chr) LATSEC,instr(LAT,e.chr) LATDEC, 0 X
     , LON,instr(hex(LON),b.chr) LONGRA,instr(LON,c.chr) LONPRI,instr(LON,d.chr) LONSEC,instr(LON,e.chr) LONDEC, 0 Y
     , TRT,NNC,COR,DIR,PKM
  from upmimp a,(select HEX(chr) chr from cfg_crdchr where des='gradi') b
               ,(select chr from cfg_crdchr where des='primi') c 
               ,(select chr from cfg_crdchr where des='secondi') d
               ,(select chr from cfg_crdchr where des='decimali') e 
 where a.rowid>1
;

update wrkcrd 
   set LAT=substr(LAT,1,9)||'0'||substr(LAT,10,2)
     , LATGRA=5, LATPRI=5, LATSEC=11, LATDEC=8 
 where (LATGRA=5 and LATPRI=5 and LATSEC=10 and LATDEC=8)   
;

update wrkcrd 
   set LON=substr(LON,1,9)||'0'||substr(LON,10,2)
     , LONGRA=5, LONPRI=5, LONSEC=11, LONDEC=8 
 where (LONGRA=5 and LONPRI=5 and LONSEC=10 and LONDEC=8)   
;



insert into upmimperr
select 'formato coordinate anomalo' ERR, 'LAT' FLD
     , PRG,POS,LAT,LON,TRT,NNC,COR,DIR,PKM
  from wrkcrd
 where NOT (LATGRA=5 and LATPRI=5 and LATSEC=11 and LATDEC=8)   
;    
    
insert into upmimperr
select 'formato coordinate anomalo' ERR, 'LON' FLD
     , PRG,POS,LAT,LON,TRT,NNC,COR,DIR,PKM
  from wrkcrd
 where NOT (LONGRA=5 and LONPRI=5 and LONSEC=11 and LONDEC=8)   
;

drop table if exists wrkfin;
create table wrkfin as
select distinct PRG,POS
     , LAT,substr(LAT,1,2) LATGRA,substr(LAT,4,2) LATPRI,substr(LAT,7,2) LATSEC,substr(LAT,10,2) LATDEC
          ,printf('%11.8f',round(substr(LAT,1,2)+substr(LAT,4,2)/60.0+substr(LAT,7,2)/3600.0+substr(LAT,10,2)/36000.0, 8)) X
     , LON,substr(LON,1,2) LONGRA,substr(LON,4,2) LONPRI,substr(LON,7,2) LONSEC,substr(LON,10,2) LONDEC
          ,printf('%11.8f',round(substr(LON,1,2)+substr(LON,4,2)/60.0+substr(LON,7,2)/3600.0+substr(LON,10,2)/36000.0, 8)) Y
     , TRT,NNC,COR,DIR,PKM
  from wrkcrd a
 where (LATGRA=5 and LATPRI=5 and LATSEC=11 and LATDEC=8)   
   and (LONGRA=5 and LONPRI=5 and LONSEC=11 and LONDEC=8)
;

/*log dei record gia' presenti*/
select 'record gia'' presente' ERR, '***' FLD
     , PRG,POS,LAT,LON,TRT,NNC,COR,DIR,PKM
 from wrkfin a
 where exists (select 'x' from upm x
                where x.PRG=a.PRG and x.POS=a.POS and x.X=a.X and x.Y=a.Y 
                  and x.TRT=a.TRT and x.NNC=a.NNC and x.COR=a.COR and x.DIR=a.DIR and x.PKM=a.PKM)
;

/*log dei record errati*/
select * from upmimperr;

/*inserimento dei record nella tabella master*/
insert into upm 
select PRG,POS,LATGRA,LATPRI,LATSEC,LATDEC,X,LONGRA,LONPRI,LONSEC,LONDEC,Y,TRT,NNC,COR,DIR,PKM from wrkfin a
 where not exists (select 'x' from upm x
                    where x.PRG=a.PRG and x.POS=a.POS and x.X=a.X and x.Y=a.Y 
                      and x.TRT=a.TRT and x.NNC=a.NNC and x.COR=a.COR and x.DIR=a.DIR and x.PKM=a.PKM)
   and not exists (select 'x' from upmimperr x)
;
  