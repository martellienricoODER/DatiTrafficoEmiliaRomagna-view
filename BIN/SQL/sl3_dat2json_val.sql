WITH 
  dat as (select a.rid,a.jsn  
            from wrk a
         )
, hdr as (
select case tip when 'JS' then 'var '||var||'_json = ' else '' end||'[' txt
     , 100 sez,500 ord
  from cfg    
)
, ftr as (
select ']'||case tip when 'JS' then ';' else '' end txt
     , 900 sez,500 ord
  from cfg    
)
, fea as (
select distinct jsn||case rid when lst.lst then '' else ',' end txt
     , 500 sez,rid ord
  from dat,(select max(rid) lst from dat) lst
)
select txt from (
select txt,sez,ord from hdr
union all
select txt,sez,ord from fea
union all
select txt,sez,ord from ftr
order by sez,ord,txt)
;

/*
WITH 
  dat as (select a.rowid RID,a.jsn jsn,a.X X,a.Y Y 
            from wrk a
         )
, hdr as (
select case tip when 'JS' then 'var '||var||'_geojson = ' else '' end||'{"type": "FeatureCollection","crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },"features": [' txt
     , 100 sez,500 ord
  from cfg    
)
, ftr as (
select ']}'||case tip when 'JS' then ';' else '' end txt
     , 900 sez,500 ord
  from cfg    
)
, fea as (
select distinct'{ "type": "Feature", "properties": { '||jsn||' }, "geometry": { "type": "Point", "coordinates": [ '||Y||', '||X||' ] } }'||case rid when lst.lst then '' else ',' end txt
     , 500 sez,rid ord
  from dat,(select max(rid) lst from dat) lst
)
select txt from (
select txt,sez,ord from hdr
union all
select txt,sez,ord from fea
union all
select txt,sez,ord from ftr
order by sez,ord,txt)
;
*/