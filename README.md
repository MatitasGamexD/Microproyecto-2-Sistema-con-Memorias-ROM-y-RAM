# Microproyecto 2: Sistema con Memorias ROM y RAM en VHDL

## Descripción

Este repositorio contiene el desarrollo del **Microproyecto 2**, correspondiente al diseño e implementación de un sistema digital en **VHDL** que integra una memoria **ROM inicializada** y una memoria **RAM de lectura/escritura**, controladas mediante una lógica secuencial.

El sistema fue desarrollado para ser implementado en la tarjeta **DE0 con FPGA Cyclone III EP3C16F484C6**, utilizando el entorno **Quartus II** y simulación mediante **ModelSim-Altera**.

El diseño permite leer datos almacenados previamente en una ROM, copiarlos hacia una RAM y posteriormente recuperarlos para su visualización mediante LEDs y displays de siete segmentos.


## Objetivo del proyecto

Diseñar e implementar un sistema digital modular en VHDL que permita:

- Leer datos desde una memoria ROM inicializada.
- Escribir los datos leídos en una memoria RAM.
- Leer los datos almacenados en RAM.
- Realizar escritura manual en la RAM.
- Visualizar datos y estados del sistema en la FPGA.
- Validar el funcionamiento mediante un testbench en ModelSim.



## Componentes implementados

El proyecto está organizado de forma modular y contiene los siguientes archivos principales:

| Archivo | Descripción |

| `mem_pkg.vhd` | Paquete VHDL con constantes, tipos de datos y función para displays de siete segmentos. |
| `rom_sync.vhd` | Memoria ROM síncrona inicializada con datos predefinidos. |
| `ram_sync.vhd` | Memoria RAM síncrona con capacidad de lectura y escritura. |
| `sistema_memorias_top.vhd` | Módulo principal de control del sistema mediante una máquina de estados. |
| `DE0_TOP.vhd` | Entidad superior para la implementación en la tarjeta DE0. |
| `tb_sistema_memorias.vhd` | Testbench para validar el funcionamiento del sistema en simulación. |


## Funcionamiento general

El sistema utiliza una máquina de estados finitos que controla el proceso de transferencia de datos entre la ROM y la RAM.

El funcionamiento general es el siguiente:

1. Se realiza un reset inicial del sistema.
2. Al activar la señal de inicio, el sistema lee una dirección de la ROM.
3. El dato leído desde la ROM se escribe en la misma dirección de la RAM.
4. El proceso se repite hasta copiar todas las posiciones de memoria.
5. Una vez finalizada la copia, se activa la señal 
6. El usuario puede leer los datos almacenados en RAM usando los switches.
7. También se puede escribir manualmente un dato en la RAM.


## Señales principales

| Señal | Función |
|---|---|
| `clk` | Señal de reloj del sistema. |
| `rst` | Reinicia el sistema y limpia la RAM. |
| `start` | Inicia la copia de datos desde ROM hacia RAM. |
| `addr` | Dirección de memoria seleccionada. |
| `data_in` | Dato de entrada para escritura manual en RAM. |
| `data_out` | Dato leído desde la RAM. |
| `we` | Habilita escritura en RAM. |
| `re` | Habilita lectura desde RAM. |
| `copy_done` | Indica que la copia de ROM a RAM terminó. |
| `state_led` | Indica el estado actual de la máquina de estados. |


## Asignación en la tarjeta DE0

| Elemento físico | Función |

| `BUTTON[0]` | Reset del sistema. |
| `BUTTON[1]` | Inicio de copia ROM a RAM. |
| `SW[3:0]` | Dirección de memoria. |
| `SW[7:4]` | Dato manual para escribir en RAM. |
| `SW[8]` | Señal de escritura `we`. |
| `SW[9]` | Señal de lectura `re`. |
| `LEDG[7:0]` | Visualización del dato leído. |
| `LEDG[8]` | Indicador de copia terminada. |
| `LEDG[9]` | Indicador de sistema ocupado. |
| `HEX0` y `HEX1` | Visualización hexadecimal del dato leído. |
| `HEX2` | Visualización de la dirección seleccionada. |
| `HEX3` | Visualización del estado de la FSM. |


## Simulación

La simulación se realizó en **ModelSim-Altera** usando el archivo:
tb_sistema_memorias.vhd
