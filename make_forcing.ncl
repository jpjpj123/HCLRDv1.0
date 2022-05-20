;======================================================================
;make_forcing.ncl
;   Concepts illustrated:
;   - Interpolate forcing from CMFD grid to CSSP grid using ESMF software
;   - for precipitation,   using coservation interpolation
;   - for other variables, using bilinear    interpolation
;======================================================================
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
;---Input weighted files
wgtFile_conserve      = "CMFD_2_CSSP_conserve.nc"
wgtFile_bilinear      = "CMFD_2_CSSP_bilinear.nc"
;---Input files
;---srcFileName is a CMFD forcing data which provides lon,lat information
srcFileName = "/work/jhzeng/data/ITPCAS_CMFD/Prec/prec_ITPCAS-CMFD_V0106_B-01_03hr_010deg_201511.nc"
;---dstFileName is a CSSP geophysical data which provides lon,lat information
dstFileName="/work2/pji/China_6km/domain/finalsurfacedata__dynlai.nc"
;---CMFD TOPO FILE
srcDEM="/back/pji/data/CMFD/CMFD_TOPO_WRF.nc"
;---CSSP TOPO FILE
dstDEM="/work2/pji/China_6km/domain/finalsurfacedata__dynlai.nc"

f=addfile(srcFileName,"r")
pre_ori="/work/jhzeng/data/ITPCAS_CMFD"
pre_cdir="./Forcing/" ;;where to put forcing 

;;;;;;;;;;;chose a subdomain which already covers the area we need to do;;;
f = addfile(srcFileName,"r")
lat2d = f->lat
lon2d = f->lon
iib=0
iie=400-1
jjb=0
jje=700-1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
g=9.8;
rd=287.1;Dry air gas constant ratio
laps=0.0065;Dry adiabatic lapse rate
ff=addfile(srcDEM,"r")
ORI_DEM=ff->HGT_M(0,:,:)

ff=addfile(dstDEM,"r")
DES_DEM=ff->HGT

;;;;prepare one dimensional olon olat for interpolation
dim=dimsizes(DES_DEM)
Opt=True
interp_DEM  = ESMF_regrid_with_weights(ORI_DEM,wgtFile_bilinear,Opt)

do iy=2016,2016
leap=0
sumday=31
if(mod(iy,400).eq.0)then
leap=1
else
 if(mod(iy,4).eq.0.and.mod(iy,100).ne.0)then
 leap=1
 end if
end if
kis=1
do ki=1,12

 if(ki.lt.10)then
  dir1="0"+ki
 else
  dir1=ki
 end if
 if(ki.lt.9)then
  dir11="0"+(ki+1)
 else
  dir11=ki+1
 end if
 rain_dir1=pre_ori+"/Prec/"+"prec_CMFD_V0106_B-01_03hr_010deg_"+iy+dir11+".nc"
 rain_dir2=pre_ori+"/Prec/"+"prec_CMFD_V0106_B-01_03hr_010deg_"+iy+dir1+".nc"
 t2m_dir1=pre_ori+"/Temp/" +"temp_CMFD_V0106_B-01_03hr_010deg_"+iy+dir11+".nc"
 t2m_dir2=pre_ori+"/Temp/" +"temp_CMFD_V0106_B-01_03hr_010deg_"+iy+dir1+".nc"
 pres_dir1=pre_ori+"/Pres/"+"pres_CMFD_V0106_B-01_03hr_010deg_"+iy+dir11+".nc"
 pres_dir2=pre_ori+"/Pres/"+"pres_CMFD_V0106_B-01_03hr_010deg_"+iy+dir1+".nc"
 shum_dir1=pre_ori+"/SHum/"+"shum_CMFD_V0106_B-01_03hr_010deg_"+iy+dir11+".nc"
 shum_dir2=pre_ori+"/SHum/"+"shum_CMFD_V0106_B-01_03hr_010deg_"+iy+dir1+".nc"
 wind_dir1=pre_ori+"/Wind/"+"wind_CMFD_V0106_B-01_03hr_010deg_"+iy+dir11+".nc"
 wind_dir2=pre_ori+"/Wind/"+"wind_CMFD_V0106_B-01_03hr_010deg_"+iy+dir1+".nc"
 srad_dir1=pre_ori+"/SRad/"+"srad_CMFD_V0106_B-01_03hr_010deg_"+iy+dir11+".nc"
 srad_dir2=pre_ori+"/SRad/"+"srad_CMFD_V0106_B-01_03hr_010deg_"+iy+dir1+".nc"
 lrad_dir1=pre_ori+"/LRad/"+"lrad_CMFD_V0106_B-01_03hr_010deg_"+iy+dir11+".nc"
 lrad_dir2=pre_ori+"/LRad/"+"lrad_CMFD_V0106_B-01_03hr_010deg_"+iy+dir1+".nc"
 print(rain_dir1)
 print(rain_dir2)
 if(ki.eq.12)then
 rain_dir1=pre_ori+"/Prec/"+"prec_CMFD_V0106_B-01_03hr_010deg_"+(iy+1)+"01.nc"
 t2m_dir1=pre_ori+"/Temp/"+"temp_CMFD_V0106_B-01_03hr_010deg_"+(iy+1)+"01.nc"
 pres_dir1=pre_ori+"/Pres/"+"pres_CMFD_V0106_B-01_03hr_010deg_"+(iy+1)+"01.nc"
 shum_dir1=pre_ori+"/SHum/"+"shum_CMFD_V0106_B-01_03hr_010deg_"+(iy+1)+"01.nc"
 wind_dir1=pre_ori+"/Wind/"+"wind_CMFD_V0106_B-01_03hr_010deg_"+(iy+1)+"01.nc"
 srad_dir1=pre_ori+"/SRad/"+"srad_CMFD_V0106_B-01_03hr_010deg_"+(iy+1)+"01.nc"
 lrad_dir1=pre_ori+"/LRad/"+"lrad_CMFD_V0106_B-01_03hr_010deg_"+(iy+1)+"01.nc"
 end if

f_rain1=addfile(rain_dir1,"r")
f_rain2=addfile(rain_dir2,"r")
f_t2m1=addfile(t2m_dir1,"r")
f_t2m2=addfile(t2m_dir2,"r")
f_pres1=addfile(pres_dir1,"r")
f_pres2=addfile(pres_dir2,"r")
f_shum1=addfile(shum_dir1,"r")
f_shum2=addfile(shum_dir2,"r")
f_wind1=addfile(wind_dir1,"r")
f_wind2=addfile(wind_dir2,"r")
f_srad1=addfile(srad_dir1,"r")
f_srad2=addfile(srad_dir2,"r")
f_lrad1=addfile(lrad_dir1,"r")
f_lrad2=addfile(lrad_dir2,"r")
rain2=f_rain2->prec(:,iib:iie,jjb:jje)*f_rain2->prec@scale_factor+f_rain2->prec@add_offset
rain1=f_rain1->prec(0,iib:iie,jjb:jje)*f_rain1->prec@scale_factor+f_rain1->prec@add_offset
t2m2=f_t2m2->temp(:,iib:iie,jjb:jje)*f_t2m2->temp@scale_factor+f_t2m2->temp@add_offset
t2m1=f_t2m1->temp(0,iib:iie,jjb:jje)*f_t2m1->temp@scale_factor+f_t2m1->temp@add_offset
pres2=f_pres2->pres(:,iib:iie,jjb:jje)*f_pres2->pres@scale_factor+f_pres2->pres@add_offset
pres1=f_pres1->pres(0,iib:iie,jjb:jje)*f_pres1->pres@scale_factor+f_pres1->pres@add_offset
shum2=f_shum2->shum(:,iib:iie,jjb:jje)*f_shum2->shum@scale_factor+f_shum2->shum@add_offset
shum1=f_shum1->shum(0,iib:iie,jjb:jje)*f_shum1->shum@scale_factor+f_shum1->shum@add_offset
wind2=f_wind2->wind(:,iib:iie,jjb:jje)*f_wind2->wind@scale_factor+f_wind2->wind@add_offset
wind1=f_wind1->wind(0,iib:iie,jjb:jje)*f_wind1->wind@scale_factor+f_wind1->wind@add_offset
srad2=f_srad2->srad(:,iib:iie,jjb:jje)*f_srad2->srad@scale_factor+f_srad2->srad@add_offset
srad1=f_srad1->srad(0,iib:iie,jjb:jje)*f_srad1->srad@scale_factor+f_srad1->srad@add_offset
lrad2=f_lrad2->lrad(:,iib:iie,jjb:jje)*f_lrad2->lrad@scale_factor+f_lrad2->lrad@add_offset
lrad1=f_lrad1->lrad(0,iib:iie,jjb:jje)*f_lrad1->lrad@scale_factor+f_lrad1->lrad@add_offset

;;;;;;;;;;;;;;;;;;;;calculate dew temperature
e2   =pres2/(0.622/shum2+0.378)/100 ;hpa
d2   = log(e2/6.1078)
aa=where(t2m2.gt.273.16,17.27,21.87)
bb=where(t2m2.gt.273.16,35.86,7.66 )
dt2m2 = (bb*d2-aa*273.16)/(d2-aa)


e1   =pres1/(0.622/shum1+0.378)/100 ;hpa
d1   = log(e1/6.1078)
aa1=where(t2m1.gt.273.16,17.27,21.87)
bb1=where(t2m1.gt.273.16,35.86,7.66 )
dt2m1 = (bb1*d1-aa1*273.16)/(d1-aa1)

;;;;;;;;;;;;;;;;;;;;calculate surface temperature;;;;;;;;;;;;;;;;;
dim2=dimsizes(t2m2)
t2m2_s=t2m2
dt2m2_s=dt2m2
pres2_s=pres2
do i=0,dim2(0)-1
   t2m2_s(i,:,:) =t2m2(i,:,:)+laps*ORI_DEM;
   dt2m2_s(i,:,:)=dt2m2(i,:,:)+laps*ORI_DEM;
end do
t2m1_s=t2m1+laps*ORI_DEM;
dt2m1_s=dt2m1+laps*ORI_DEM;

;;;;;;;;;;;;;;;;;;;calculate air pressure;;;;;;;;;;;;;;;;;;;;;
do i=0,dim2(0)-1
pres2_s(i,:,:)=pres2(i,:,:)*exp(-9.8*(0-ORI_DEM)/(287*(t2m2_s(i,:,:)+t2m2(i,:,:))/2))
end do
pres1_s=pres1*exp(-9.8*(0-ORI_DEM)/(287*(t2m1_s+t2m1)/2))
    

t2m2=t2m2_s
t2m1=t2m1_s
pres2=pres2_s
pres1=pres1_s
shum2=dt2m2_s
shum1=dt2m1_s

delete(t2m2_s)
delete(t2m1_s)
delete(pres2_s)
delete(pres1_s)
delete(dt2m2)
delete(dt2m1)

print("down to sea level ok")

Opt                = True
print("start interpolation")
temp_rain =ESMF_regrid_with_weights(rain2,wgtFile_conserve,Opt)*1.0
next_rain =ESMF_regrid_with_weights(rain1,wgtFile_conserve,Opt)*1.0
temp_t2m  =ESMF_regrid_with_weights(t2m2,wgtFile_bilinear,Opt)*1.0
next_t2m  =ESMF_regrid_with_weights(t2m1,wgtFile_bilinear,Opt)*1.0
temp_pres =ESMF_regrid_with_weights(pres2,wgtFile_bilinear,Opt)*1.0
next_pres =ESMF_regrid_with_weights(pres1,wgtFile_bilinear,Opt)*1.0
temp_shum =ESMF_regrid_with_weights(shum2,wgtFile_bilinear,Opt)*1.0
next_shum =ESMF_regrid_with_weights(shum1,wgtFile_bilinear,Opt)*1.0

temp_wind =ESMF_regrid_with_weights(wind2,wgtFile_bilinear,Opt)*1.0
next_wind =ESMF_regrid_with_weights(wind1,wgtFile_bilinear,Opt)*1.0
temp_srad =ESMF_regrid_with_weights(srad2,wgtFile_bilinear,Opt)*1.0
next_srad =ESMF_regrid_with_weights(srad1,wgtFile_bilinear,Opt)*1.0
temp_lrad =ESMF_regrid_with_weights(lrad2,wgtFile_bilinear,Opt)*1.0
next_lrad =ESMF_regrid_with_weights(lrad1,wgtFile_bilinear,Opt)*1.0


;;;;;;;;from sea level to surface
t2m2_h=temp_t2m
dt2m2_h=temp_t2m
pres2_h=temp_pres
do i=0,dim2(0)-1
   t2m2_h(i,:,:)=temp_t2m(i,:,:)-DES_DEM*laps
   dt2m2_h(i,:,:)=temp_shum(i,:,:)-DES_DEM*laps
   pres2_h(i,:,:)=temp_pres(i,:,:)*exp(-9.8*(DES_DEM-0)/(287*(t2m2_h(i,:,:)+temp_t2m(i,:,:))/2))
end do

delete(aa)
delete(bb)
aa=where(t2m2_h.gt.273.16,17.27,21.87)
bb=where(t2m2_h.gt.273.16,35.86,7.66 )
tmp_e=6.1078*exp(aa*(dt2m2_h-273.16)/(dt2m2_h-bb))
shum2_h=0.622*tmp_e/(pres2_h/100.-0.378*tmp_e)
delete(tmp_e)


t2m1_h=next_t2m-DES_DEM*laps
dt2m1_h=next_shum-DES_DEM*laps
pres1_h=next_pres*exp(-9.8*(DES_DEM-0)/(287*(t2m1_h+next_t2m)/2))

delete(aa)
delete(bb)
aa=where(t2m1_h.gt.273.16,17.27,21.87)
bb=where(t2m1_h.gt.273.16,35.86,7.66 )
tmp_e=6.1078*exp(aa*(dt2m1_h-273.16)/(dt2m1_h-bb))
shum1_h=0.622*tmp_e/(pres1_h/100.-0.378*tmp_e)
delete(tmp_e)


temp_t2m=t2m2_h
next_t2m=t2m1_h
temp_pres=pres2_h
next_pres=pres1_h
temp_shum=shum2_h
next_shum=shum1_h

print("up to surface ok")
print("end")
  ii=28
if (ki.eq.1 .or. ki .eq.3 .or.ki .eq. 5.or.ki.eq.7.or.ki.eq.8.or.ki.eq.10.or.ki.eq.12)then
  ii=31
end if
if(ki .eq. 2.and.leap.eq.1)then
  ii=29
end if
if (ki.eq.4 .or. ki .eq.6 .or.ki .eq.9.or.ki.eq.11)then
 ii=30
end if
mst=1
ccc=0
ccc1=0
ccc2=0
do jj=1,ii
if(jj.lt.10)then
dir2="0"+jj
else
dir2=jj
end if
dirout="ITPCAS_Forcing_"+iy+dir1+dir2+".nc"
print(dirout)
outrain=new((/24,dim(0),dim(1)/),float)
outt2m=new((/24,dim(0),dim(1)/),float)
outrh=new((/24,dim(0),dim(1)/),float)
outdswrf=new((/24,dim(0),dim(1)/),float)
outdlwrf=new((/24,dim(0),dim(1)/),float)
outhpbl=new((/24,dim(0),dim(1)/),float)
outpsfc=new((/24,dim(0),dim(1)/),float)
outu=new((/24,dim(0),dim(1)/),float)
outv=new((/24,dim(0),dim(1)/),float)
outtair=new((/24,dim(0),dim(1)/),float)
outp2=new((/24,dim(0),dim(1)/),float)
outhpbl=new((/24,dim(0),dim(1)/),float)
outh=new((/24,dim(0),dim(1)/),float)

 do ih=0,23
  if (mod(ih,3).eq.0)then
    ccc2=ccc2+1
  end if
  if(ccc2.lt.(8*ii))then
    if(mod(ih,3).eq.0)then
    ccc1=ccc1+1
    outt2m(ih,:,:)=temp_t2m(ccc1-1,:,:)*1.0
    outt2m(ih+1,:,:)=temp_t2m(ccc1-1,:,:)*2./3+temp_t2m(ccc1,:,:)/3.
    outt2m(ih+2,:,:)=temp_t2m(ccc1-1,:,:)/3.+temp_t2m(ccc1,:,:)*2/3.
    outpsfc(ih,:,:)=temp_pres(ccc1-1,:,:)*1.
    outpsfc(ih+1,:,:)=temp_pres(ccc1-1,:,:)*2/3.+temp_pres(ccc1,:,:)/3.
    outpsfc(ih+2,:,:)=temp_pres(ccc1-1,:,:)/3.+temp_pres(ccc1,:,:)*2/3.
    outrh(ih,:,:)=temp_shum(ccc1-1,:,:)*1.
    outrh(ih+1,:,:)=temp_shum(ccc1-1,:,:)*2/3.+temp_shum(ccc1,:,:)/3.
    outrh(ih+2,:,:)=temp_shum(ccc1-1,:,:)/3.+temp_shum(ccc1,:,:)*2/3.
    outu(ih,:,:)=temp_wind(ccc1-1,:,:)*1.
    outu(ih+1,:,:)=temp_wind(ccc1-1,:,:)*2/3.+temp_wind(ccc1,:,:)/3.
    outu(ih+2,:,:)=temp_wind(ccc1-1,:,:)/3.+temp_wind(ccc1,:,:)*2/3.
    outdswrf(ih,:,:)=temp_srad(ccc1-1,:,:)*1.
    outdswrf(ih+1,:,:)=temp_srad(ccc1-1,:,:)/2.+temp_srad(ccc1,:,:)/2.
    outdswrf(ih+2,:,:)=temp_srad(ccc1,:,:)*1.
    outdlwrf(ih,:,:)=temp_lrad(ccc1-1,:,:)*1.0
    outdlwrf(ih+1,:,:)=temp_lrad(ccc1-1,:,:)/2.+temp_lrad(ccc1,:,:)/2.
    outdlwrf(ih+2,:,:)=temp_lrad(ccc1,:,:)*1.
    end if
  end if
   if(ccc2.lt.(8*ii))then
     outrain(ih,:,:)=temp_rain(ccc2-1,:,:)*3/3
   else
     outrain(ih,:,:)=next_rain*3/3
   end if
  if(ccc2.eq.(8*ii).and.mod(ih,3).eq.0)then
    ccc1=ccc1+1
    outt2m(ih,:,:)=temp_t2m(ccc1-1,:,:)*1.
    outt2m(ih+1,:,:)=temp_t2m(ccc1-1,:,:)*2/3+next_t2m(:,:)/3
    outt2m(ih+2,:,:)=temp_t2m(ccc1-1,:,:)/3+next_t2m(:,:)*2/3
    outu(ih,:,:)=temp_wind(ccc1-1,:,:)*1.
    outu(ih+1,:,:)=temp_wind(ccc1-1,:,:)*2/3+next_wind(:,:)/3
    outu(ih+2,:,:)=temp_wind(ccc1-1,:,:)/3+next_wind(:,:)*2/3
    outrh(ih,:,:)=temp_shum(ccc1-1,:,:)*1.
    outrh(ih+1,:,:)=temp_shum(ccc1-1,:,:)*2/3+next_shum(:,:)/3
    outrh(ih+2,:,:)=temp_shum(ccc1-1,:,:)/3+next_shum(:,:)*2/3
    outpsfc(ih,:,:)=temp_pres(ccc1-1,:,:)*1.
    outpsfc(ih+1,:,:)=temp_pres(ccc1-1,:,:)*2/3+next_pres(:,:)/3
    outpsfc(ih+2,:,:)=temp_pres(ccc1-1,:,:)/3+next_pres(:,:)*2/3
    outdswrf(ih,:,:)=temp_srad(ccc1-1,:,:)*1.
    outdswrf(ih+1,:,:)=temp_srad(ccc1-1,:,:)/2+next_srad(:,:)/2
    outdswrf(ih+2,:,:)=next_srad(:,:)*1.
    outdlwrf(ih,:,:)=temp_lrad(ccc1-1,:,:)*1.
    outdlwrf(ih+1,:,:)=temp_lrad(ccc1-1,:,:)/2+next_lrad(:,:)/2
    outdlwrf(ih+2,:,:)=next_lrad(:,:)*1.
  end if
 end do
;;;then prepare for output
  guess     = 1                ; use zonal means
  is_cyclic = False             ; cyclic [global]
  nscan     = 200             ; usually much less than this
  eps       = 1.e-2            ; variable dependent
  relc      = 0.6              ; relaxation coefficient
  opt       = 0                ; not used
cdir=pre_cdir+iy+"/"+dirout
print(cdir)
;;;;;fill missing
;outv=0.
;outh=30.
;outhpbl=1000.
outt2m=outt2m-6.5*10/1000
;outp2=outpsfc*(((outt2m-laps*30)/outt2m)^(g/(rd*laps)))


outrain=where(outrain.gt.10000,-32767.,outrain)
outrain@_FillValue=-32767.
outrain@missing_value=-32767.
outrain!0="hour"
outrain!1="lat"
outrain!2="lon"
outrain@_long_name = "Precipitation rate" 
outrain@_unit ="mm/hr"

copy_VarCoords(outrain,outdswrf)
copy_VarCoords(outrain,outdlwrf)
copy_VarCoords(outrain,outrh)
copy_VarCoords(outrain,outu)
copy_VarCoords(outrain,outpsfc)
copy_VarCoords(outrain,outt2m)

outdswrf@_long_name = "Short wave radiation"
outdswrf@_unit ="W/m2/hr"
outdlwrf@_long_name = "Long wave radiation"
outdlwrf@_unit ="W/m2/hr"
outrh@_long_name = "Humidity"
outrh@_unit ="kg/kg"
outt2m@_long_name = "air temperature"
outt2m@_unit ="K"
outu@_long_name = "wind speed "
outu@_unit ="m/s"
outpsfc@_long_name = "surface pressure"
outpsfc@_unit ="Pa"



system("rm -f " + cdir)
ncdf = addfile(cdir,"c")
ncdf->APCP=outrain
ncdf->DSWRF=outdswrf
ncdf->DLWRF=outdlwrf
ncdf->Q10m=outrh
ncdf->U10m=outu
ncdf->PSFC=outpsfc
ncdf->T10m=outt2m
end do
delete(t2m2)
delete(rain2)
delete(wind2)
delete(pres2)
delete(shum2)
delete(srad2)
delete(lrad2)
delete(temp_rain)
delete(temp_t2m)
delete(temp_wind)
delete(temp_pres)
delete(temp_shum)
delete(temp_srad)
delete(temp_lrad)

end do
end do

end

