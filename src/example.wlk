import wollok.game.*

const bomba = new NoFrutas(tiempo=80,imagen="bomba.png",cantidadPuntos=20,velocidad=400)
const manzanaDorada = new Especiales(tiempo=120, imagen="manzanaDorada.png",cantidadPuntos =20,velocidad=400)
const manzana = new Frutas(tiempo=20, imagen = "manzanaRoja.png",cantidadPuntos=5,velocidad=600)
const manzanaVerde = new Frutas(tiempo=60, imagen = "manzanaVerde.png",cantidadPuntos=3,velocidad=400)
//const start = new Text (position=game.at(8,8), text = "PRESIONE LA TECLA [SPACE] PARA EMPEZAR",color ="BF8000FF" )
const gameOver = new Text (position=game.at(8,8), text = "GAME OVER",color="BF8000FF")
const continue = new Text(position = game.center(),text= "presiona [ENTER] para continuar", color = "BF8000FF")
object juego {
	var objetosVoladores = [manzana,manzanaVerde,bomba,manzanaDorada]
	var property position = null
	method configurar(){
		game.width(17)
		game.height(12)
		game.title("FrutasVoladoras")
		game.addVisual(fondo)
		game.addVisual(temporizador)
		game.addVisual(puntos)
		game.addVisual(personaje)
		game.addVisual(vidauno)
		game.addVisual(vidados)
		game.addVisual(vidatres)
		game.onCollideDo(personaje,{ obstaculo => obstaculo.agarrar()})
		personaje.iniciar()
		temporizador.iniciar()
		manzana.iniciar()
		manzanaDorada.iniciar()
		manzanaVerde.iniciar()
		bomba.iniciar()
	} 
	method iniciar(){
		 self.configurar()		  
	}
	method correr(){
		objetosVoladores.forEach({nombre=>nombre.iniciar()})
		temporizador.iniciar()
		personaje.mover()
	}	
	method terminar(){	
		objetosVoladores.forEach({nombre=>nombre.detener()})
		game.addVisual(gameOver)
		game.addVisual(continue)
		temporizador.detener()
		puntos.reiniciar()
		game.removeVisual(personaje)	
		keyboard.enter().onPressDo{game.clear() self.iniciar()}	
	}
}
object fondo{
	method position()=game.origin()
	method image()="fondo.jpeg"
}
class Text{
	var position
	var text
	var color
	method position()= position
	method text() = text
	method textColor() = color
	}
// objeto el cual recolecta frutas//
object personaje{
	const posicionInicial = game.at(game.width()*1/2,1)
	var property position = posicionInicial
	
	method image() = "personaje.png"
	
	method iniciar(){
		position = posicionInicial
		self.mover()
	}
	method mover(){
		keyboard.a().onPressDo{ position=position.left(1)}
		keyboard.d().onPressDo{ position=position.right(1)}
		keyboard.w().onPressDo{ self.saltar()}
		}
		method saltar(){
		if(position.y() == 1) {
			position=position.up(1)
			game.schedule(250*3,{position=position.down(1)})
	}
}
	method position()=position	
}
object temporizador{
	var property tiempo = 0
	
	method text() = "Tiempo:" + tiempo.toString()
	method position() = game.at(15, 9)
	method textColor()= "73738D"
	
	method tiempo()= tiempo
		
	method iniciar(){
		tiempo = 0
		game.onTick(120,"tiempo",{self.pasarTiempo()})
	}
	method pasarTiempo(){
		tiempo = tiempo +1
	}
	
	method detener(){
		game.removeTickEvent("tiempo")
		tiempo = 0
	}
}
object puntos{
	var puntos = 0
	method text() = "Puntos:" + puntos.toString() 
	method position()= game.at( 15, 10)
	method textColor()= "73738D"
	
	method aumentar(param){
	puntos =puntos+param
	}
	method disminuir(param){
		puntos=puntos-param
		if (puntos== -10){
		juego.terminar()}
	}
	method reiniciar(){
		puntos = 0
	}
}
const vidauno = new Vida(position=game.at(7,11))
const vidados = new Vida(position=game.at(8,11))
const vidatres = new Vida(position=game.at(9,11))

class Vida{
	var property position
	
	
	method image()="vida.png"
	method position()=position

		
	}
object contador{
	var property contador=0
	var vidas = [vidauno,vidados,vidatres]
	
	method disminuirVida(){
		game.removeVisual(vidas.get(contador))
		contador +=1
		if (contador==3){
		juego.terminar()}
		
	}
	method aumentarVida(){
		if (contador>0){
		contador-=1
		game.addVisual(vidas.get(contador))}
		
	}
}
// el jugador debe agarrarlas o pierde vida//
class Frutas{
	var imagen = ""
	var	tiempo = 0
	var cantidadPuntos = 0
	var velocidad =400
	var property position = game.at(0.randomUpTo(game.width()).truncate(0), game.height()+1)
	var timingdecaida=false
	
	method image() = imagen
	
	method position()=position
	
	method iniciar(){
			position = game.at(0.randomUpTo(game.width()).truncate(0), game.height()+1)
			game.onTick(5,"timing",{self.timing()})
			game.onTick(velocidad,"caerFrutas",{if (timingdecaida) self.caer()})	
	}		
	method timing(){
		if (tiempo==temporizador.tiempo()){
			timingdecaida=true
			game.removeTickEvent("timing")
			game.addVisual(self)
		}
	}
	method caer(){	
		position = position.down(1)
		if (position.y()==-1){
			contador.disminuirVida()
			position=game.at(0.randomUpTo(game.width()).truncate(0), game.height())
			}
	}
	method agarrar(){
		puntos.aumentar(cantidadPuntos)
		position=game.at(0.randomUpTo(game.width()).truncate(0), game.height())
	}		
	method detener(){
		game.removeTickEvent("caerFrutas")
		timingdecaida=false
	}
}
// si son agarrados disminuye la vida//
class NoFrutas inherits Frutas{
	override method caer(){
		position = position.down(1)
		if (position.y()==-1){
			position=game.at(0.randomUpTo(game.width()).truncate(0), game.height())
	}
	}
	override method agarrar(){
		contador.disminuirVida()
		puntos.disminuir(cantidadPuntos)
		position=game.at(0.randomUpTo(game.width()).truncate(0), game.height())	
	}
}
class Especiales inherits Frutas{
	
	override method agarrar(){
		contador.aumentarVida()
		puntos.aumentar(cantidadPuntos)
		game.schedule(400,{game.say(personaje, "Fantastico!")})
		position=game.at(0.randomUpTo(game.width()).truncate(0), game.height())
	}
}
