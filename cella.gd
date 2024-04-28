extends Sprite2D

#ARIA è il default stato di una cella
@export var default_tipo : Init.tipi = Init.tipi.ARIA

var tipo : Init.tipi = self.default_tipo
var tipi_livello = {}
var randomGenerator : RandomNumberGenerator

#Pattern: SuSx, Su, SuDx, Sx, Dx, GiuSx, Giu, GiuDx
var vicini = [null,null,null,null,null,null,null,null]

func inizializza(tipi_livello : Dictionary, randomGenerator : RandomNumberGenerator):
	self.texture = tipi_livello[self.default_tipo]
	self.tipi_livello = tipi_livello
	self.randomGenerator = randomGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func determina_tipo():
	
	var num_vicini_muro = vicini_con_stato(Init.tipi.MURO)
	var num_vicini_aria = vicini_con_stato(Init.tipi.ARIA)
	#Regole
	
	#Se tutti vicini sono ARIA 1.5% diventi muro
	if num_vicini_aria == 8 and self.position.y > (self.texture.get_size().y * 2) :
		probabilita_diventi_tipo(1.5, Init.tipi.MURO)
		return
	
	#Se Gsx G Gdx sono muro 10% diventi muro
	if(are_cells_stato([self.vicini[7], self.vicini[6], self.vicini[5]], Init.tipi.MURO)):
		probabilita_diventi_tipo(10.0, Init.tipi.MURO)
		return
		
	#Se Dx è MURO e il resto ARIA
	if are_cells_stato([self.vicini[4]], Init.tipi.MURO) and num_vicini_aria == 7:
		probabilita_diventi_tipo(30.0, Init.tipi.MURO)
		return

func are_cells_stato(array_celle : Array[Sprite2D], tipo : Init.tipi, devono_esistere = false) -> bool:
	for cella in array_celle:
		if (((cella.tipo != tipo) if cella != null else (devono_esistere))):
			return false
	return true

func determina_se_accade(probabilita : float) -> bool:
	probabilita = fmod(probabilita, 100.0)
	var random = self.randomGenerator.randf_range(0,100)
	if random <= probabilita:
		return true
	return false
	
func probabilita_diventi_tipo(probabilita : float, tipo_da_settare : Init.tipi):
	if determina_se_accade(probabilita):
			self.set_tipo(tipo_da_settare)

func vicini_con_stato(tipo : Init.tipi) -> int:
	var contatore = 0
	for vicino in vicini:
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
