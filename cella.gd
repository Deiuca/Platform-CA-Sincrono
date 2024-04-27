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
	
	#Se tutti vicini sono ARIA 25% diventi muro
	if num_vicini_aria == 8:
		probabilita_diventi_tipo(25.0, Init.tipi.MURO)
	#Se Gsx G Gdx sono muro 40% diventi muro
	if Init.tipi.MURO == self.vicini[7].tipo == self.vicini[6].tipo == self.vicini[5].tipo:
		probabilita_diventi_tipo(40.0, Init.tipi.MURO)
	#Se Dx è MURO e il resto ARIA
	if self.vicini[4].tipi == Init.tipi.MURO and num_vicini_aria == 7:
		probabilita_diventi_tipo(70.0, Init.tipi.MURO)

func determina_se_accade(probabilita : float):
	probabilita = fmod(probabilita, 100.0)
	var random = self.randomGenerator.randf_range(0,100)
	if probabilita <= random:
		return true
	return false
	
func probabilita_diventi_tipo(probabilita : float, stato_da_settare : Init.tipi):
	if determina_se_accade(probabilita):
			self.set_tipo(stato_da_settare)

func vicini_con_stato(tipo : Init.tipi) -> int:
	var contatore = 0
	for vicino in vicini:
		if vicino.tipo == tipo:
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
