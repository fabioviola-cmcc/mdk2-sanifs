; Definition of parameters to visualize MEDSLIK-II output
; Values can be logical (False/True), integer (without dot), float (with dot)
; Questo script e' composto da una prima parte (primary parameters) in cui l'utente puo' se necessario cambiare
; i settaggi dei parametri e una seconda parte che l'utente non dovrebbe editare chiamata "Secondary Parameters".

;================= Primary parameters ==================

;I seguenti 4 parametri definiscono i contorni della figura, se commentati con ";" verranno
; calcolati automaticamente, nel caso in cui si preferisca settarli manualmente devono essere
; attivati togliendo il commento ";"

;MIN_LON = 10.0
;MAX_LON = 20.0
;MIN_LAT = 30.0
;MAX_LAT = 40.0

MIN_LON = 17.10
MAX_LON = 17.30
MIN_LAT = 40.4
MAX_LAT = 40.5

MIN_LON = 17.10
MAX_LON = 17.33
MIN_LAT = 40.4
MAX_LAT = 40.51

;MIN_LON = 17.00 +  8/60.0
;MAX_LON = 17.00 +15.5/60.0
;MIN_LAT = 40.00 + 25/60.0
;MAX_LAT = 40.00 + 29/60.0

; Il parametro HOUR_BEGIN definisce l'ora per cui verra' creata la prima mappa
; Il parametro HOUR_STEP definisce l'intervallo in ore fra una mappa e la successiva. Si consiglia di passare alla
; frequenza oraria soltanto quando la regione della mappa sara' definita in maniera definitiva.
; La durata della produzione delle mappe aumenta all'aumentare della frequenza temporale.
; HOUR_END definisce l'ora dell'ultima mappa, se posto uguale a -1 l'ultima mappa verra' prodotta per l'ultimo output disponibile.
HOUR_BEGIN = 0 ; must be equal to or greater than zero
HOUR_STEP  = 1 ; must be greater than zero, if "1" - all MEDSLIK output hours
HOUR_END   =-1 ; if zero or negative - to the end of MEDSLIK output


; Definisce il numero di DPI delle figure.
; greater value -> larger plot size
PLOT_DPI = 120




;================= Secondary parameters ==================
; L'utente non dovrebbe variare i parametri sottostanti.

;================= vectors on maps ==================

; plot main maps (oil+currents+wind)
MAIN_MAPS = True

; layers to plot on main maps
MAIN_MAPS_WIND     = True
MAIN_MAPS_CURRENTS = True

;;				MAIN_MAPS_WIND     = False
;;				MAIN_MAPS_CURRENTS = False

; plot currents/wind arrows only in the center of the oil slick
CURRENTS_CENTER_ONLY = False
WIND_CENTER_ONLY     = True

; vector annotation length
VECTOR_ANNOTATION_LENGTH = 0.05

;================= vector fields subsampling ==================

; uncoment values below to aply fixed value
; otherwise it will be assigned automatically
VECTOR_LAT_STRIDE = 2
VECTOR_LON_STRIDE = 2
;VECTOR_LON_STRIDE = 2
;VECTOR_LAT_STRIDE = 2



;================= animation ==================

; produce animated GIF
ANIMATION = True

; animation time step in milliseconds
; really it is slower
ANIMATION_DELAY = 50

;================= vector scales ==================

; currents scale factors, greater - longer arrows
CURRENTS_SCALE_GRID   = 0.5
CURRENTS_SCALE_CENTER = 2.

;CURRENTS_SCALE_GRID   = 2.0
CURRENTS_SCALE_GRID   = 0.2



; wind scale factors, greater - longer arrows
WIND_SCALE_GRID   = 0.5
WIND_SCALE_CENTER = 2.

;================= automatic map boundaries ==================

; map auto boundariy parameters in geographical minutes
LAT_MARGIN = 4.0
LON_MARGIN = 5.0
LAT_MARGIN = 8.0
LON_MARGIN = 10.0
LAT_CELL = 3.0
LON_CELL = 4.0



;================= colors ==================

; color is RGB triplet, possible values are from 0 to 1
; (/1., 1., 1./) - white
; (/1., 0., 0./) - red
; (/0., 0., 0./) - black
COLOR_GRID     = (/0.5,0.5,0.5/)
COLOR_LAND     = (/0.85,0.85,0.85/)
COLOR_WIND     = (/0.0,0.5,0.5/)
COLOR_CURRENTS = (/0.2,0.2,0.2/)

;================= fonts ==================

; font sizes
FONT_TITLE    = 0.014
FONT_AXIS     = 0.010
FONT_COLORBAR = 0.013
FONT_SLICKS   = 0.011
FONT_VECTOR_TEXT       = 0.012
FONT_VECTOR_ANNOTATION = 0.014

;================= grid lines  ==================

; sometimes gridlines cannot be drawn if map area is two small
; spacing in geographical minutes
GRID = False
GRID_THICKNESS   =  0.1
GRID_LAT_SPACING = 15.
GRID_LON_SPACING = 15.

;================= vector arrows shape  ==================

; arrow widths
;ARROW_CURRENTS_WIDTH = 1.0
ARROW_CURRENTS_WIDTH = 0.7
ARROW_WIND_WIDTH     = 1.0
ARROW_CENTER_CURRENTS_WIDTH = 2.0
ARROW_CENTER_WIND_WIDTH     = 2.5

; arrow heads
ARROW_CURRENTS_HEAD = 0.005
ARROW_WIND_HEAD     = 0.005
ARROW_CENTER_CURRENTS_HEAD = 0.010
ARROW_CENTER_WIND_HEAD     = 0.010

;================= technical parameters  ==================

; more messages about processing
VERBOSE = False

; maximum number of points in *.srf files
; to allocate memory before reading files
MAX_OIL_N = 40000

;================= obsolete parameters are not used now but must be available

; plot currents maps, only currents with color background
CURRENTS_MAPS = False

; plot slick map, color slick contours, surface oil density > 0.05 m3/km2
SLICK_MAP = False

CURRENTS_SCALE_MAP    = 1.5

; vector minimum distance
CURRENTS_MINIMUM_DISTANCE = 0.07
WIND_MINIMUM_DISTANCE = 0.07
CURRENTS_MINIMUM_DISTANCE = 0.0
WIND_MINIMUM_DISTANCE = 0.00

CURLY_CURRENTS = False



