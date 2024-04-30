extends Sprite2D

#ARIA è il default stato di una cella
@export var default_tipo : Init.tipi = Init.tipi.ARIA

var tipo : Init.tipi = self.default_tipo
var tipi_livello = {}
var randomGenerator : RandomNumberGenerator
var grid_size : Vector2

#Pattern: SuSx, Su, SuDx, Sx, Dx, GiuSx, Giu, GiuDx
var vicini = [null,null,null,null,null,null,null,null]
var vicinato_allargato = []

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
	self.label.scale = Vector2(fmod(self.scale.x, 1)+0.2,fmod(self.scale.y, 1)+0.2)
	#add_child(self.label)

func determina_tipo():
	
	var num_vicini_muro = vicini_con_stato(Init.tipi.MURO)
	var num_vicini_aria = vicini_con_stato(Init.tipi.ARIA)
	#Regole
	
	#Se tutti vicini sono ARIA 1% diventi muro
	if num_vicini_aria == 8 and self.position.y > (self.texture.get_size().y * 4 * self.scale.y) and self.position.y < ((self.grid_size.y - 4) * self.texture.get_size().y *self.scale.y):
		probabilita_diventi_tipo(1.5, Init.tipi.MURO)
		return
	
	#Se Gsx G Gdx sono muro 10% diventi muro
	if(are_cells_stato([self.vicini[7], self.vicini[6], self.vicini[5]], Init.tipi.MURO)):
		probabilita_diventi_tipo(10.0, Init.tipi.MURO)
		return
		
	#Se Dx è MURO e il resto ARIA
	if are_cells_stato([self.vicini[3]], Init.tipi.MURO) and num_vicini_aria == 7:
		probabilita_diventi_tipo(60.0, Init.tipi.MURO)
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
