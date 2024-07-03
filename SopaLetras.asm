.data
	archivo: .asciiz "palabras.txt"  # Nombre del archivo
	archivoDeSalida: .asciiz "SopaDeLetras.txt"  # Nombre que recibira el archivo a crear
	sopaLetras: .space 400           # Separar espacio para los elementos de la matriz
	palabras: .space 100       	 # Creamos un buffer para almacenar todas las palabras
	palabra: .space 10	 	 # Creamos un buffer de palabra para guardar una palabra 
	coma: .asciiz ","		 # Creamos una etiqueta para almacenar la coma
	punto: .asciiz "."		 # Creamos una etiqueta para almacenar el punto
	nuevaLinea: .asciiz "\n"         # Creamos una etiqueta para salto de linea
	posicion: .asciiz " Posicion: "	# Creamos buffer para almacenar string para imprimir la posicion y direccion de la palabra
	direccionArriba: .asciiz "  Hacia arriba"
	direccionAbajo: .asciiz "  Hacia abajo"
	direccionDerecha: .asciiz "  Hacia la derecha"
	direccionIzquierda: .asciiz "  Hacia la izquierda"
	sopaLetrasTxt: .space 800       # Creamos el buffer que se escribira en la sopa de letras txt

.text
	main:
		jal cargarArchivo       # Llamamos el metodo para cargar el archivo 
		jal leerArchivo		# Llamamos el metodo para leer el archivo
		jal cerrarArchivo	# Llamamos el metodo para cerrar el archivo
		jal leerPalabras	# Llamamos el metodo para leer las palabras	
		jal generarLetrasAleatorias  # Llamamos el metodo para llenar la matriz generando letras aleatorias
		jal sopaDeLetrasTxt	     # Llamamos este metodo para crear la sopa de letras con los espacios y los saltos de linea
		jal escribirSopaDeLetrasEnTxt# Llamamos este metodo para escribir la sopa de letras en el archivo txt
		jal terminarPrograma	# Llamamos el metodo para cerrar el programa
		
	cargarArchivo:
    		#Cargar Archivo
    		addi $v0,$zero,13       # Cargar el valor 13 en $v0 para abrir un archivo
    		la $a0, archivo         # Cargar la dirección de la cadena que contiene el nombre del archivo
    		addi $a1,$zero,0        # Cargar el valor 0 para indicar que se leerá el archivo
    		syscall         	# Llamar al sistema para abrir el archivo
    		addi $s0, $v0, 0	# Cargamos $v0 en $s0
    		jr $ra			# Retornamos la funcion
    		
	leerArchivo:
    		# Leer el archivo
    		addi $v0,$zero,14       # Cargar el valor 14 en $v0 para leer un archivo
    		addi $a0, $s0, 0    	# Mover el valor de $v0 a $a0, que contiene el descriptor de archivo
    		la $a1, palabras  	# Cargar la dirección del buffer donde se almacenará el texto leído
    		addi $a2,$zero,100	# Cargar el tamaño del buffer
    		syscall          	# Llamar al sistema para leer el archivo
    		jr $ra			#Retornamos la funcion
    
   	cerrarArchivo:
    		# Cerrar el archivo
    		addi $v0,$zero,16      	# Cargar el valor 16 en $v0 para cerrar un archivo
    		addi $a0, $v0, 0    	# Mover el valor de $v0 a $a0, que contiene el descriptor de archivo
    		syscall          	# Llamar al sistema para cerrar el archivo
    		jr $ra			#Retornamos la funcion
    		
    	leerPalabras:
    		# Metodo para comenzar a leer las palabras de palabras
    		addi $t0,$zero,0	# Iniciamos $t0 en 0
    		lb $t1,punto($t0)	# Leemos el elemento punto
    		lb $t2,coma($t0)	# Leemos el elemento coma
    		
    		mientrasNoLeaPunto:			# Creamos un ciclo para iterar el texto hasta encontrar un punto
    			addi $t3,$zero,0		#Iniciamos $t3 en 0
    			lb $t4,palabras($t0)		# Leemos el byte inicial de buffer texto
    			beq $t1, $t4, encontroPunto	# Condicion para saber si llego al final del buffer Texto, utilizando un punto
    			la $t5, palabra			# Cargamos en $t5 la direccion de palabra
    			bne $t2,$t4,mientrasNoLeaComa	# Condicion para verificar si el caracter leido es diferente de la coma
    			addi $t0,$t0,1			# Incrementar $t0 en 1
    			encontroComa:			# Etiqueta de salida de no coma para continuar con la ejecucion
    			j mientrasNoLeaPunto		# Salto al mientras no punto para iterar en el ciclo
    		
   		mientrasNoLeaComa:			# Creamos un ciclo para iterar hasta encontrar una coma y seleccionar la primera palabra
   			sb $t4($t5)			# Guardamos el caracter leido en el buffer palabra
			addi $v0,$zero, 11     	        # carga el código de la llamada al sistema 11 (print_char)
			add $a0, $zero,$t4   		# carga el valor ASCII del caracter 'a' en $a0
			syscall          		# llama a la función del sistema para imprimir el caracter
			addi $t5, $t5, 1		# Incrementamos $t5 en 1 para avanzar en la direccion del buffer palabra
			addi $t3, $t3, 1		# Incrementamos $t3 en 1 para contar los caracteres que tiene una palabra
			addi $t0, $t0, 1		# Incrementamos $t0 en 1 para avanzar en el buffer texto 
    			lb $t4,palabras($t0)		# leemos el dato de buffer texto mandando $t0 como la direccion y lo almacenamos en $t4
    			beq $t2,$t4,palabraLeida	# Comparamos el caracter leido con una coma para saber si ya leyo la palabra completa
    			beq $t1,$t4,palabraLeida	# Condicion para verificar si el caracter que leyo es el punto y finalizar el ciclo leer palabras
    			j mientrasNoLeaComa		# Hacer un salto al ciclo para iterar mas caracteres en caso de no encontrar una coma o un punto
    			
    		palabraLeida:				# Creamos una etiqueta para escribir la palabra en un vector 
    			addi $s0,$zero,0		# Inicializamos $s0 en 0, con este vamos a comparar $s0 para ver si hubo un cambuio y la palabra fue escrita 
    			mientrasPalabraNoHaSidoEscrita:	# Con este ciclo verificaremos si la posicion y direccion son aceptables para procesar a escribir la palabra 
    				addi $sp,$sp,-56	# A continuacion guardamos los datos en la pila para no perderlos y realizar una correcta ejecucion del codigo
    	 			sw $ra,0($sp)		# Guardamos la direccion de retorno en la pila
    	 			jal apilar 		# Llamamos el metodo para apilar 
    	 			addi $a0,$zero,3	# Enviamos como parametro el numero limite
    				jal generarNumeroAleatorio	# Llamamos al metodo para generar una direccion entre 0 y 3
    				addi $s1,$v1,0		# el valor retornado de la funcion almacenado en $v1 lo asignamos a $s1
    				addi $a0,$zero,399	# Enviamos como parametro el numero limite
    				jal generarNumeroAleatorio  	# Llamamos al metodo para generar una posicion entre 0 y 399
    				addi $s2,$v1,0		# el valor retornado de la funcion almacenado en $v1 lo asignamos a $s2
    				addi $a0,$s1,0		# A $a0 le enviamos lo que hay en $s1 para enviarlo como argumento 
    				addi $a1,$s2,0		# A $a1 le enviamos lo que hay en $s2 para enviarlo como argumento
    				addi $a2,$t3,0		# A $a2 le enviamos lo que hay en $t3 para enviarlo como argumento
    				addi $a3,$zero,1	# A $a3 le enviamos 1 como metodo, que nos servira para que nos haga una funcion especifica que sera validar el espacio
    				jal enSopaDeLetras	# Llamamos la funcion para validar si hay el espacio adecuado para escribir la palabra
    				addi $s5,$v0,0		# El valor retornado en $v0 lo guardamos em $s3 para verificar si existe el espacio adecuado 
    				addi $a3,$zero,0	# A $a3 le enviamos 0 como metodo, que nos servira para que nos haga una funcion especifica que sera verificar si hay letras
    				jal enSopaDeLetras	# Llamaos el metodo para verificar si existe una palabra o caracter ya escrita en la matriz
    				addi $s6,$v0,0		# El valor retornado en $v0 lo guardamos en $s4 para comprobar si existe la palabra en la posicion seleccionada
   				jal desapilar		# Llamamos la funcion desapilar
    				lw $ra,0($sp)		# Cargamos la direccion de retorno guardada en la pila
    				addi $sp,$sp,56		# Liberamos la memoria
    				beq $zero,$s5,espacioValidadoExitosamente	# Esta condicion nos permite continuar si el espacio es valido para escribir la palabra
    				palabraEscrita:					# Etiqueta para continuar con el proceso de escribir la palabra en la sopa de letras
    				bne $zero,$s0,encontroComa		# Si esta $s0 es diferente a 0 quiere decir que la palabra se escribio correctamente y continua con la siguiente palabra	
    				j mientrasPalabraNoHaSidoEscrita	# Salta al ciclo para seguir iterando en tal caso de que la posicion o direccion no seas las adecuadas
    				
    		espacioValidadoExitosamente:					# Etiqueta que continua el proceso cuando el espacio ha sido el adecuado 
    			beq $zero,$s6,NoHayLetraValidadoExitosamente		# Condicion para comprobar si existe o no una palabra o caracter en la posicion y espacios seleccionados para escribir la palabra
    			j palabraEscrita					# Si la condicion anterior no se cumple realizamos el siguiente salto para generar otros datos
    			
    		NoHayLetraValidadoExitosamente:					# Etiqueta para continuar con el proceso si no existe una palabra
    			addi $sp,$sp,-56			# A continuacion guardamos los datos en la pila para no perderlos y realizar una correcta ejecucion del codigo
    	 		sw $ra,0($sp)				# Guardamos la direccion de retorno 
    			jal apilar				# Metodo para apilar
    			addi $a3,$zero,2			# A $a3 le enviamos 2 como metodo, que nos servira para que nos haga una funcion especifica que seria escribir en la sopa de letras
    			jal enSopaDeLetras    		# Llamamos al metodo escribir palabra, despues de haber validado la posicion y el nulo en los espacios seleccionados
    			jal mensajeEnSalidaEstandar	# Llamamos el metodo mensaje salida estandar para que nos imprima la posicion y direccion de la palabra
    			jal desapilar			# Metodo para desapilar
    			lw $ra,0($sp)			# Liberamos la pila
    			addi $sp,$sp,56			# A continuacion guardamos los datos en la pila para no perderlos y realizar una correcta ejecucion del codigo
    			addi $s0,$zero,1		# Cargamos los datos guardados en la pila a sus correspondientes variables y liberamos la memoria de la pila
    			j palabraEscrita    			# Realizamos el salto a la etiqueta para continuar con el proceso y verificar si la palabra fue escrita
    		encontroPunto:					# Etiqueta de salida del mientras no lea punto 
    			jr $ra					# Etiqueta de retorno 
		
   	enSopaDeLetras:				# Metodo multifuncion para verificar el espacio, si existe una palabra y para escribir la palabra en la sopa de letra
    		addi $t0,$zero,0		# Usaremos $t0-$t3 igual a 0-3 para la direccion 
    		addi $t1,$zero,1		
    		addi $t2,$zero,2
    		addi $t3,$zero,3
    		addi $t4,$zero,20		# Usaremos $t4 Como un dato igual a 20 que corresponde al numero de filas o columnas
    		addi $s0,$a0,0			# $s0-$s3 igual a $a0-$a3 para almacenar los argumentos 
    		addi $s1,$a1,0			
    		addi $s2,$a2,0
    		beq $t1,$a3,verificarSiCabe	#Condiciones para acceder a una funcion especifica 
    		beq $t0,$a3,verificarSiHayLetra
    		beq $t2,$a3,EscribirPalabraEnSopaDeLetras	
    		verificacionCompleta:			# Etiqueta para controlar que el proceso fue completado y seguir 
		jr $ra					# Etiqueta de retorno
		
		verificarSiCabe:			# Etiqueta para verificar si la sopa de letra tiene el espacio adecuado para la palabra en su posicion y direccion generada
			div $s1,$t4			# Realizamos una division para hallar la fila o columna
    			mflo $t5			# Almacenamos la division entera en $t5
    			mfhi $t6			# Almacenamos en residuo en $t6
			addi $v0,$zero,1		# $v0 dato a retornar para poder verificar si el proceso ha sido correcto
			validarEspacio:			# Etiqueta para selecciona la direccion correspondiente y validar el espacio
				beq $t0,$s0,calcularEspacioArriba		# Condiciones para saber cual es la direccion generada y calcular el espacio total
    				beq $t1,$s0,calcularEspacioAbajo
    				beq $t2,$s0,calcularEspacioDerecha
    				beq $t3,$s0,calcularEspacioIzquierda
    		
    		verificarSiHayLetra:		# Este metodo sirve para validar si no hay alguna letra en las casillas de la posicion y direccion seleccionada
    			addi $v0,$zero,0	# Inicializamos variables que nos permiten manejar los buffers para recorrerlo y escribir en ellos
    			addi $t4,$zero,0
			addi $t5,$a1,0
			mientrasNoHayaLetra:	# Ciclo para recorrer la posicion y direccion en la sopa de letras y veificar si no hay leras ya existentes en este
				beq $t4,$s2,verificacionCompleta   	# Cierre del ciclo 
				addi $t4,$t4,1				# Incrementamos, cargamos dato y con las condiciones manejamos las direcciones y tambien si hay alguna letra en la casilla
				lb $t6,sopaLetras($t5)
				bne $t6,$zero,noAprobadoHayLetra
				beq $t0,$s0,avanzarArriba
    				beq $t1,$s0,avanzarAbajo
    				beq $t2,$s0,avanzarDerecha
    				beq $t3,$s0,avanzarIzquierda
    				posicionActualizadaVerificar:		# Etiqueta para continuar con el proceso
    				j mientrasNoHayaLetra		
    		
    		EscribirPalabraEnSopaDeLetras:		# Proceder a escribir la palabra en la sopa de letras
    		la $t7, sopaLetras			# Cargamos la direccion de la sopa de letras e iniciamos variables que nos permiten manejar esta misma
    		addi $t4,$zero,0			
    		addi $t5,$a1,0				# $t5 = $a1 +0 donde $a1 es la posicion generada aleatoriamente
    		add $t5,$t5,$t7				# $t5 le sumanos la direccion de la sopa de letras
    		escribirLetraEnSopaDeLetras:		# ciclo para escribir las letras en la sopa de letras
    			beq $t4,$s2,verificacionCompleta	# Cierre del ciclo	
    			lb $t6,palabra($t4)		# Cargamos dato, incrementamos y con las condicionales avanzamos a la respectiva direccion
			addi $t4,$t4,1	
			sb $t6($t5)
			beq $t0,$s0,avanzarArriba
    			beq $t1,$s0,avanzarAbajo
    			beq $t2,$s0,avanzarDerecha
    			beq $t3,$s0,avanzarIzquierda
    			posicionActualizadaEscribir:	# Etiqueta para continuar con el proceso despues de avanzar en la direccion
    			j escribirLetraEnSopaDeLetras	# Salto al ciclo
    			
		calcularEspacioArriba: 			# A continuacion las siguientes etiquetas nos calculan el espacio total disponible en todas las direcciones
			addi $s3,$t5,1			# $s3 = posicion/20+1
			j aprobarEspacioParaPalabra     # Esta etiqueta sirve para verificar el espacio total disponible con el tamaño de la palabra
			
		calcularEspacioAbajo:
			sub $s3,$t4,$t5			# $s3 = 20 - posicion/20
			j aprobarEspacioParaPalabra
			
		calcularEspacioDerecha:
			sub $s3,$t4,$t6			# $s3 = 20 - posicion%20
			j aprobarEspacioParaPalabra
			
		calcularEspacioIzquierda:
			addi $s3,$t6,1			# $s3 = posicion/20 + 1
			j aprobarEspacioParaPalabra
			
		aprobarEspacioParaPalabra:		# Esta etiqueta verifica el espacio disponible respecto al tamaño de la palabra
			slt $t7,$s3,$s2			# Arroja 1 si $s3 < $s2 de lo contrario arroja 0
			beq $t7,$t0,espacioAprobadoCorrectamente # Si obtenemos un 0 de la comparacion anterior quiere decir que la palabra si cabe en el espacio total disponible
			j verificacionCompleta		# Etiqueta para continuar al siguiente proceso
		
		espacioAprobadoCorrectamente:		# Esta etiqueta permite hacer el cambio en la variable de retorno de forma exitosa y hacer un salto al siguiente paso
			addi $v0,$t7,0			
			j verificacionCompleta
			
		avanzarArriba: 						# Los siguientes metodos nos permiten avanzar en la respectiva direccion
			addi $t5,$t5,-20				# Depende la funcion que se este trabajando, con las condicionales este realiza el salto a donde fue llamado previamente
			beq $t0,$a3,posicionActualizadaVerificar	# Se usa el 20 que es el numero de filas, para avanzar verticalmente y el 1 para avanzar horizaontal mente
			beq $t2,$a3,posicionActualizadaEscribir
			
		avanzarAbajo: 
			addi $t5,$t5,20
			beq $t0,$a3,posicionActualizadaVerificar
			beq $t2,$a3,posicionActualizadaEscribir
			
		avanzarDerecha: 
			addi $t5,$t5,1
			beq $t0,$a3,posicionActualizadaVerificar
			beq $t2,$a3,posicionActualizadaEscribir
			
		avanzarIzquierda: 
			addi $t5,$t5,-1
			beq $t0,$a3,posicionActualizadaVerificar
			beq $t2,$a3,posicionActualizadaEscribir
			
		noAprobadoHayLetra:		# si encuenta una letra en la casilla o posicion cambiar el valor de la variable de retorno y realiza el salto para continuar
			addi $v0,$zero,1
			j verificacionCompleta
			
	apilar:				# Metodo para apilar 
    		sw $t0,4($sp)
    		sw $t1,8($sp)
    		sw $t2,12($sp)
   		sw $t3,16($sp)
   		sw $t4,20($sp)
   		sw $t5,24($sp)
   		sw $t6,28($sp)
   		sw $s0,32($sp)
   		sw $s1,36($sp)
   		sw $s2,40($sp)
   		sw $s3,44($sp)
   		sw $s4,48($sp)
   		sw $t7,52($sp)
   		jr $ra
    		
	desapilar:		 # Metodo para desapilar
   		lw $t0,4($sp)
   		lw $t1,8($sp)
   		lw $t2,12($sp)
   		lw $t3,16($sp)
   		lw $t4,20($sp)
   		lw $t5,24($sp)
   		lw $t6,28($sp)
   		lw $s0,32($sp)
   		lw $s1,36($sp)
   		lw $s2,40($sp)
   		lw $s3,44($sp)
   		lw $s4,48($sp)
   		lw $t7,52($sp)
   		jr $ra
			   		   		   		
	generarNumeroAleatorio:
		# Generar el número aleatorio entre 0 y 399
		addi $s0,$a0,1
		addi $v0,$zero,42       # Cargar el valor 42 en $v0 para generar un número aleatorio
		addi $a0,$zero,0        # Donde se guardara el numero generado
		add $a1,$zero,$s0       # Cargar el valor a0 en $a1 como límite superior
		syscall          	# Llamar al sistema para generar el número aleatorio
		addi $v1, $a0, 0    	# Mover el valor generado a $v1
		jr $ra
					
	generarLetrasAleatorias:
		addi $t0,$zero,0        # Iniciamos t2 en 0 para recorrer el bufer 
		addi $t1,$zero,400      # Ponemos el tamaño del vector para ponerle limite al ciclo	
		mientrasNoLetra:	# Ciclo para verificar que no haya una letra en la respectiva posicion
			beq $t0,$t1,generarLetrasAleatoriasFinalizado	# Salida del ciclo
			lb $t2,sopaLetras($t0)		# Cargamos el byte si este es nulo generamos la letra de lo contrario continuamos con la siguiente posicion
			beq $t2,$zero,generarLetra	# Hasta que este finalice el recorrido 
			generarLetraFinalizado:
			addi $t0,$t0,1	
			j mientrasNoLetra
			generarLetrasAleatoriasFinalizado:
			jr $ra
			
	generarLetra:
		addi $sp,$sp,-4			# A continuacion guardamos los datos en la pila para no perderlos y realizar una correcta ejecucion del codigo
    	 	sw $ra,0($sp)			# Guardamos la dir de retorno 
    	 	addi $a0,$zero,25		# Generamos un numero aleatorio hasta 25 
    	 	jal generarNumeroAleatorio	# Llamamos al metodo para generar un numero aleatorio
    	 	lw $ra,0($sp) 			# Cargamos el valor de ra guardado en la pila
    	 	addi $sp,$sp,4			# Liberamos el espacio de la pila
    	 	addi $s1,$v1,'A'	        # sumanos el numero generado y la posicion de la A en ascii
    	 	la $t2,sopaLetras($t0)		# Cargamos la direccion y almacenamos el caracter generado 
    	 	sb $s1($t2)			
		j generarLetraFinalizado
	
	sopaDeLetrasTxt:			# Metodo para crear un buffer de la sopa de letra con los espacios y saltos de linea
		addi $t0,$zero,0		# Inicializamos variables para hacer el recorrido y establecemos el limite que es el tamaño del vector
		addi $t1,$zero,400
		addi $s2,$zero,2		# Esta variable nos permitira realizar una multiplicacion para poder modificar la posicion del nuevo buffer
		la $t5,sopaLetrasTxt		# Cargamos la direccion del nuevo buffer
		addi $s0,$zero,20		# Estos datos nos permitiras controlar el salto de linea, tambien acceder a caracteres como espacio y salto de linea
		addi $s1,$zero,19
		addi $s3,$zero,' '
		addi $s4,$zero,10 
		mientrasNoSea400:		# Este ciclo nos permite recorrer la sopa de letras y transcribir sus letras en la nueva sopa de letras adicionando espacios 
			beq $t0,$t1,llegoA400   # y salto de linea correspondientes
			mult $t0,$s2		# Multiplicamos la posicion de la sopa de letras por 2 y el resultado sera la posicion en la cual se va a escribir en el nuevo buffer 
			mflo $t3		# Accedemos al resultado y se lo añadimos a la direccion almacenada en $t5, cargamos el dato de la sopa de letra y lo guardamos en dicha direccion
			add $t7,$t5,$t3		
			lb $t2 sopaLetras($t0)
			sb $t2($t7)
			addi $t4,$t3,1		# Procedemos a incrementar la variable, realizamos una division obteniendo el residuo y asi verificar si es necesario agregar un salto de linea o un espacio
			div $t0,$s0	
			mfhi $t6
			add $t7,$t5,$t4
			beq $t6,$s1,agregarSaltoDeLinea
			bne $t6,$s1,agregarEspacio
			continuarSiguientePosicion:
			addi $t0,$t0,1		# Incrementamos las variables y seguimos con el ciclo
			j mientrasNoSea400
		llegoA400:			# Salida del ciclo
		jr $ra
						# Estas etiquetas permiten agregar espacio y salto de linea
		agregarSaltoDeLinea:
			sb $s4($t7)
			j continuarSiguientePosicion
		
		agregarEspacio:
			sb $s3($t7)
			j continuarSiguientePosicion
		
     	mensajeEnSalidaEstandar:		# Metodo para imprimir en la salida estandar la palabra posicion y direccion
     		addi $s0,$a0,0			# Inicializamos variables
     		addi $t0,$zero,0		# Usaremos $t0-$t3 igual a 0-3 para la direccion y tambien 20 correspondiente al numero de la fila
    		addi $t1,$zero,1
    		addi $t2,$zero,2
    		addi $t3,$zero,3
     		addi $t4, $zero, 20
     		div $a1,$t4			# Realizamos la division de la posicion/20 para obtener la div entera y el modulo, a esto le agregamos 1 para asi obtener la fila y columna 
     		mflo $t5
     		mfhi $t6			
     		addi $v0,$zero,4		# Imprimimos el buffer posicion haciendo el llamado de la funcion syscall enviando $v0 = 4
     		la $a0,posicion
     		syscall
     		addi $v0,$zero,1		# Procedemos a imprimir los datos de la fila el caracter x y la columna haciendo uso de syscall
     		addi $a0,$t5,1
		syscall
     		addi $v0,$zero,11
     		la $a0,'x'
		syscall
		addi $v0,$zero,1
     		addi $a0,$t6,1
		syscall
     		beq $s0,$t0,imprimirHaciaArriba	#Controlamos las direcciones con las condiciones para imprimir la direccion correspondiente a la palabra
     		beq $s0,$t1,imprimirHaciaAbajo
     		beq $s0,$t2,imprimirHaciaLaDerecha
     		beq $s0,$t3,imprimirHaciaLaIzquierda
     		finalizarImprimirDireccion:	# Despues de imprimir la direccion realizamos un salto de linea para la siguiente palabra 
     		addi $v0,$zero,4
     		la $a0,nuevaLinea
     		syscall
     		jr $ra 
     						# Las siguientes etiquetas imprimen la direccion correspondiente seleccionada en las condiciones
     	imprimirHaciaArriba:
     		addi $v0,$zero,4
     		la $a0,direccionArriba
     		syscall
     		j finalizarImprimirDireccion
     	
     	imprimirHaciaAbajo:
     		addi $v0,$zero,4
     		la $a0,direccionAbajo
     		syscall
     		j finalizarImprimirDireccion
     	
     	imprimirHaciaLaDerecha:
     		addi $v0,$zero,4
     		la $a0,direccionDerecha
     		syscall
     		j finalizarImprimirDireccion
     	
     	imprimirHaciaLaIzquierda:
     		addi $v0,$zero,4
     		la $a0,direccionIzquierda
     		syscall
     		j finalizarImprimirDireccion
     		
     	escribirSopaDeLetrasEnTxt:
     		# Abrir archivo en modo de escritura
		addi $v0,$zero, 13       # Cargar el código de la llamada al sistema para abrir un archivo
		la $a0,archivoDeSalida  # Cargar la dirección de la cadena que contiene el nombre del archivo
		addi $a1,$zero, 1        # Modo de escritura: 1
		addi $a2,$zero,0
		syscall          # Llamada al sistema para abrir el archivo
		addi $s0,$v0,0

		# Escribir en el archivo
		addi $v0,$zero, 15       # Cargar el código de la llamada al sistema para escribir en un archivo
		addi $a0,$s0, 0    # Mover el identificador del archivo al registro de argumento
		la $a1, sopaLetrasTxt  # Cargar la dirección de la cadena que contiene el mensaje
		addi $a2,$zero, 801       # Longitud del mensaje
		syscall          # Llamada al sistema para escribir en el archivo

		# Cerrar el archivo
		addi $a0, $s0,0    # Mover el identificador del archivo al registro de argumento
		addi $v0,$zero, 16       # Cargar el código de la llamada al sistema para cerrar un archivo
		syscall          # Llamada al sistema para cerrar el archivo
     		jr $ra
     	
     	terminarPrograma:
    		# Terminar el programa
    		addi $v0,$zero,10       # Cargar el valor 10 en $v0 para salir del programa
    		syscall          	# Llamar al sistema para salir del programa
    	
