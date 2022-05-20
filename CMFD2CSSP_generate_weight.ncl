;======================================================================
;CMFD2CSSP_generate_weight.ncl
;   Concepts illustrated:
;   - Create interpolating weight from CMFD grid to CSSP grid using ESMF software
;   - for precipitation,   using coservation interpolation
;   - for other variables, using bilinear    interpolation
;======================================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;;; srcFileName is a CMFD forcing file which provides lon and lat information
srcFileName = "/work/jhzeng/data/ITPCAS_CMFD/Temp/temp_CMFD_V0106_B-01_03hr_010deg_201808.nc"
;;; dstFileName is a data file which include lon and lat information for the destination grid
dstFileName = "/work2/pji/China_6km/domain/finalsurfacedata__dynlai.nc"
outFilePref = "./"
;;;;READ LON&LAT

;;;;Grid info of CMFD
sfile = addfile(srcFileName,"r")
t2m=short2flt(sfile->temp)
lat2d = sfile->lat
lon2d = sfile->lon

;;;;Grid info of CSSP
dfile = addfile(dstFileName,"r")
latd=dfile->XLAT
lond=dfile->XLON

do iii=0,1
 if (iii.eq.0) then
  ;---Interpolation method to use
  interpMethod = "bilinear"
  ;---Output (and, eventually, input) files
  srcGridName = outFilePref+"CMFD_SCRIP.nc"
  dstGridName = outFilePref+"CSSP_SCRIP.nc"
  wgtFile     = outFilePref+"CMFD_2_CSSP_" + interpMethod + ".nc"
  ;---Set to True if you want to skip any of these steps
  SKIP_TRI_SCRIP_GEN  = False
  SKIP_MPAS_ESMF_GEN  = False
  SKIP_WGT_GEN        = False
 else 
;---Interpolation method to use
  delete(interpMethod)
  interpMethod = "conserve"
  wgtFile     = outFilePref+"CMFD_2_CSSP_" + interpMethod + ".nc"
  SKIP_TRI_SCRIP_GEN  = True
  SKIP_MPAS_ESMF_GEN  = True
  SKIP_WGT_GEN        = False
 end if
;----------------------------------------------------------------------
; Step 1 part 1
;   Convert source CLDAS rectilinear grid to a SCRIP File.
;----------------------------------------------------------------------
if(.not.SKIP_TRI_SCRIP_GEN) then
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@Title          = "A CMFD 0.1 degree lon/lat grid."
  Opt@GridMask      = where(ismissing(t2m(0,:,:)),0,1)
  rectilinear_to_SCRIP(srcGridName,lat2d,lon2d,Opt)
  ;---Clean up
  delete(Opt)
end if

; Step 1 part 2
;   Convert source curvilinear grid to a SCRIP File.
;----------------------------------------------------------------------
if(.not.SKIP_TRI_SCRIP_GEN) then
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@Title          = "A CSSP 6km lon/lat grid."

  curvilinear_to_SCRIP(dstGridName,latd,lond,Opt)

  ;---Clean up
  delete(Opt)
end if

;----------------------------------------------------------------------
; Step 2
;    Generate weights
;----------------------------------------------------------------------
if(.not.SKIP_WGT_GEN) then
  Opt                      = True
  Opt@InterpMethod         = interpMethod
  Opt@ForceOverwrite       = True
  Opt@SrcRegional    = True
  Opt@DstRegional    = True
  print("Generating interpolation weights from CMFD to CSSP grid ...")
  ESMF_regrid_gen_weights(srcGridName, dstGridName, wgtFile, Opt)
end if
end do
delete(lat2d)
delete(lon2d)
delete(latd)
delete(lond)

end
