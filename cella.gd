extends Sprite2D

class_name Cella

#ARIA è il default stato di una cella
@export var default_tipo : Init.tipi = Init.tipi.ARIA

var tipo : Init.tipi = self.default_tipo
var tipi_livello = {}
var randomGenerator : RandomNumberGenerator
var grid_size : Vector2

#Pattern: SuSx, Su, SuDx, Sx, Dx, GiuSx, Giu, GiuDx
var vicini = [null,null,null,null,null,null,null,null]

var vicinato_allargato = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null]

func inizializza(tipi_livello : Dictionary, randomGenerator : RandomNumberGenerator, grid_size :Vector2):
	self.texture = tipi_livello[self.default_tipo]
	self.tipi_livello = tipi_livello
	self.randomGenerator = randomGenerator
	self.grid_size = grid_size

#Debug
var label : Label = Label.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#Debug
	self.label.scale = Vector2(fmod(self.scale.x, 1)-0.2,fmod(self.scale.y, 1)-0.2)
	#add_child(self.label)

func determina_tipo():
	
	var num_vicini_muro = vicini_con_stato(Init.tipi.MURO)
	var num_vicini_aria = vicini_con_stato(Init.tipi.ARIA)
	var num_vicini_allargati_muro = vicini_allargati_con_stato(Init.tipi.MURO)
	var num_vicini_allargati_aria = vicini_allargati_con_stato(Init.tipi.ARIA)
	var num_vicini_allargati_piattaforma = vicini_allargati_con_stato(Init.tipi.PLATFORM)
	
	#Se tutti vicini sono ARIA 1.5% diventi muro
	if (num_vicini_aria + num_vicini_allargati_aria) == 24 :
		if( self.tipo == Init.tipi.ARIA ):
			probabilita_diventi_tipo(1.5, Init.tipi.PLATFORM)
			return
	
	#Se Gsx G Gdx sono muro 10% diventi muro
	if(are_cells_stato([self.vicini[7], self.vicini[6], self.vicini[5]], Init.tipi.MURO) and are_cells_stato([self.vicini[2], self.vicini[0], self.vicini[1]], Init.tipi.ARIA)):
		if  not are_cells_stato([self.vicini[3]], [Init.tipi.MURO_RAMPA_DOWN, Init.tipi.MURO_RAMPA_UP]) and not are_cells_stato([self.vicini[4]], [Init.tipi.MURO_RAMPA_DOWN, Init.tipi.MURO_RAMPA_UP]):
			if probabilita_diventi_tipo(10.0, Init.tipi.MURO):
				return
		
	#Se è troppo vicina ad un MURO diventa aria
	if not are_cells_stato([self], [Init.tipi.MURO, Init.tipi.MURO_RAMPA_DOWN, Init.tipi.MURO_RAMPA_UP]) and (num_vicini_allargati_muro > 0 or num_vicini_muro > 0):
		set_tipo(Init.tipi.ARIA)
		return
	
	#Se a VDx,Dx,Sx,VSx è piattaforma, favorisci che diventi ARIA  
	if are_cells_stato([self.vicini[3], self.vicini[4], self.vicinato_allargato[7], self.vicinato_allargato[8]], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE]):
		if probabilita_diventi_tipo(30.0, Init.tipi.ARIA):
			return
			
	#Se Dx è PIATTAFORMA e sotto e sopra è aria, diventa piattaforma
	if are_cells_stato([self.vicini[4]], Init.tipi.PLATFORM, true) and are_cells_stato([self.vicini[6], self.vicini[1]], Init.tipi.ARIA, true ):
		if(num_vicini_allargati_piattaforma < 2):
			if probabilita_diventi_tipo(20.0, Init.tipi.PLATFORM):
				return
	
	#Se Sx è PIATTAFORMA e sotto e sopra è aria, diventa PLATFORM
	if are_cells_stato([self.vicini[3]], Init.tipi.PLATFORM, true) and num_vicini_aria == 7:
		if(num_vicini_allargati_piattaforma < 2):
			if probabilita_diventi_tipo(15.0, Init.tipi.PLATFORM):
				return
	
	#Piazza una rampa giu quando tra piattaforma e aria e sotto aria e se è già un platform
	if are_cells_stato([self.vicini[3]], [Init.tipi.PLATFORM, Init.tipi.PLATFORM_OBSTACLE], true) and are_cells_stato([self.vicini[4]], Init.tipi.ARIA):
		if are_cells_stato([self.vicini[4]], Init.tipi.ARIA) and self.tipo == Init.tipi.PLATFORM:
			if probabilita_diventi_tipo(10.0, Init.tipi.RAMPA_DOWN):
				return
	
	#Se VSx, Sx è platform & Dx aria, diventa EDGE 
	if(are_cells_stato([self.vicini[3], self.vicinato_allargato[7]], Init.tipi.PLATFORM, true)) and not are_cells_stato([self.vicini[3]], Init.tipi.EDGE_DOWN):
		if are_cells_stato([self.vicini[4]], Init.tipi.ARIA):
			if probabilita_diventi_tipo(10.0, Init.tipi.EDGE_DOWN):
				return
	
	#Se Sx Dx è platform, può diventare ostacolo
	if(are_cells_stato([self.vicini[3],self.vicini[4]], Init.tipi.PLATFORM, true)):
		if determina_se_accade(25.0):
			if not probabilita_diventi_tipo(50.0, Init.tipi.PLATFORM_OBSTACLE):
				set_tipo(Init.tipi.PLATFORM_OBSTACLE_DOWN)
			return
			
	#Regola MURO RAMPA
	if are_cells_stato([self.vicini[3]], Init.tipi.MURO) and are_cells_stato([self.vicini[4]], Init.tipi.ARIA) and are_cells_stato([self.vicini[6]], Init.tipi.MURO, true):
		set_tipo(Init.tipi.MURO_RAMPA_DOWN)
	
	if are_cells_stato([self.vicini[4]], Init.tipi.MURO) and are_cells_stato([self.vicini[3]], Init.tipi.ARIA) and are_cells_stato([self.vicini[6]], Init.tipi.MURO, true):
		set_tipo(Init.tipi.MURO_RAMPA_UP)
		
	if are_cells_stato([self.vicini[4]], Init.tipi.MURO) and are_cells_stato([self.vicini[3]], Init.tipi.MURO):
		set_tipo(Init.tipi.MURO)
	
	#Se VSx o Sx o VDx o Dx -> % NEMICO
	var cond1 = are_cells_stato([self.vicini[7]], Init.tipi.PLATFORM_OBSTACLE, true)
	var cond2 = are_cells_stato([self.vicinato_allargato[9]], Init.tipi.PLATFORM_OBSTACLE, true)
	var cond3 = are_cells_stato([self.vicinato_allargato[10]], Init.tipi.PLATFORM_OBSTACLE, true)
	if are_cells_stato([self.vicini[5]], Init.tipi.PLATFORM_OBSTACLE, true) or cond1 or cond2 or cond3:
		if probabilita_diventi_tipo(15.0, Init.tipi.NEMICO):
			pass
		
	#REGOLE CORREZIONE
		
	#Se Sx è PIATTAFORMA && VSx ARIA -> Piattaforma
	if are_cells_stato([self.vicini[3]], Init.tipi.PLATFORM, true) and are_cells_stato([self.vicinato_allargato[7]], Init.tipi.ARIA, true):
		set_tipo(Init.tipi.PLATFORM)
		
	if self.tipo == Init.tipi.ARIA and are_cells_stato([self.vicini[1]], Init.tipi.NEMICO, true):
		self.vicini[1].set_tipo(Init.tipi.ARIA)
		
	#Se NEMICO e sotto NO platform -> Delete
	if self.tipo == Init.tipi.NEMICO and not are_cells_stato([self.vicini[6]], Init.tipi.PLATFORM):
		set_tipo(Init.tipi.ARIA)
		
	#Se NEMICO e vicino ha NEMICO -> ARIA
	if self.tipo == Init.tipi.NEMICO and (are_cells_stato([self.vicini[3]], Init.tipi.NEMICO) or are_cells_stato([self.vicini[4]], Init.tipi.NEMICO)):
		set_tipo((Init.tipi.ARIA))
	
	if self.tipo == Init.tipi.PLATFORM and num_vicini_aria == 8 and num_vicini_allargati_piattaforma > 0:
		set_tipo(Init.tipi.ARIA)
		return
		

func are_cells_stato(array_celle : Array[Sprite2D], tipo , devono_esistere = false) -> bool:
	if typeof(tipo) == TYPE_ARRAY:
		return check_cells_stati(array_celle, tipo, devono_esistere)
	else:
		return check_cells_stato(array_celle, tipo, devono_esistere)

func check_cells_stato(array_celle : Array[Sprite2D], tipo : Init.tipi, devono_esistere = false):
	for cella in array_celle:
		if (((cella.tipo != tipo) if cella != null else (devono_esistere))):
			return false
	return true

func check_cells_stati(array_celle : Array[Sprite2D], tipi : Array, devono_esistere = false):
	for cella in array_celle:
		if ((( not cella.tipo in tipi) if cella != null else (devono_esistere))):
			return false
	return true

func determina_se_accade(probabilita : float) -> bool:
	probabilita = fmod(probabilita, 100.0)
	var random = self.randomGenerator.randf_range(0,100)
	if random <= probabilita:
		return true
	return false
	
func probabilita_diventi_tipo(probabilita : float, tipo_da_settare : Init.tipi)-> bool:
	if determina_se_accade(probabilita):
			if self.tipo != tipo_da_settare:
				self.set_tipo(tipo_da_settare)
				return true
	return false

func vicini_con_stato(tipo : Init.tipi) -> int:
	var contatore = 0
	for vicino in vicini:
		if vicino != null and vicino.tipo == tipo:
			contatore += 1
	return contatore

func vicini_allargati_con_stato(tipo : Init.tipi) -> int:
	var contatore = 0
	for vicino in vicinato_allargato:
		if vicino != null and vicino.tipo == tipo:
			contatore += 1
	return contatore

func set_tipo(tipo : Init.tipi):
	if tipo in self.tipi_livello:
		self.tipo = tipo
		self.texture = tipi_livello[tipo]
		return
	print("Tipo non consentito!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
