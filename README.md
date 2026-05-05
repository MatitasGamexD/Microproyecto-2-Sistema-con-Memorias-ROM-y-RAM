# Microproyecto 2: Sistema Automático con Memorias ROM y RAM en VHDL

## Descripción

Este repositorio contiene el desarrollo corregido y actualizado del **Microproyecto 2**, correspondiente al diseño e implementación de un sistema digital en **VHDL** que integra una memoria **ROM síncrona** y una memoria **RAM síncrona de lectura/escritura**, controladas por una **máquina de estados finitos FSM**.

En esta versión, el sistema fue modificado para funcionar de forma **totalmente automática**, sin depender de switches para seleccionar direcciones, leer o escribir manualmente. Después del reset, el sistema recorre automáticamente las direcciones de la ROM, copia los datos hacia la RAM y posteriormente realiza la lectura automática de la RAM para mostrar los resultados en LEDs y displays de siete segmentos.

El diseño fue desarrollado para la tarjeta **DE0 con FPGA Cyclone III EP3C16F484C6**, utilizando **Quartus II** para la síntesis e implementación, y **ModelSim-Altera** para la simulación.

---

## Objetivo del proyecto

Diseñar e implementar un sistema digital automático en VHDL capaz de:

- Leer datos predefinidos desde una memoria ROM síncrona.
- Escribir automáticamente esos datos en una memoria RAM síncrona.
- Leer automáticamente los datos almacenados en la RAM.
- Visualizar la dirección actual, el dato leído y el estado del sistema.
- Validar el comportamiento mediante un testbench en ModelSim-Altera.
- Implementar el diseño en la tarjeta DE0.

---

## Funcionamiento general

El sistema realiza una transferencia automática de datos desde la ROM hacia la RAM.

El proceso general es el siguiente:

1. Se presiona `KEY[0]` para resetear el sistema.
2. Al soltar el reset, la FSM inicia automáticamente.
3. La FSM coloca la primera dirección de la ROM.
4. Se espera un ciclo de reloj debido a que la ROM es síncrona.
5. El dato leído desde la ROM se escribe en la RAM en la misma dirección.
6. El sistema incrementa la dirección y repite el proceso.
7. Al finalizar la copia de todas las direcciones, se activa `copy_done`.
8. Después, el sistema entra en modo de lectura automática de RAM.
9. La FSM recorre las direcciones de la RAM y muestra los datos en LEDs y displays.

---

## Máquina de estados

La unidad de control se implementó mediante una FSM con los siguientes estados:

| Estado | Función |
|---|---|
| `S_ROM_ADDR` | Coloca la dirección actual para lectura de ROM. |
| `S_ROM_WAIT` | Espera un ciclo porque la ROM es síncrona. |
| `S_RAM_WRITE` | Escribe en RAM el dato leído desde ROM. |
| `S_NEXT_COPY` | Incrementa la dirección de copia o finaliza la transferencia. |
| `S_RAM_READ` | Lee automáticamente una dirección de la RAM. |
| `S_LATCH_READ` | Guarda el dato leído para mostrarlo estable. |
| `S_WAIT_TICK` | Espera un pulso de temporización antes de pasar a la siguiente dirección. |

---

## Archivos principales

| Archivo | Descripción |
|---|---|
| `mem_pkg.vhd` | Paquete VHDL con constantes, tipos de datos y función para displays de siete segmentos. |
| `rom_sync.vhd` | Memoria ROM síncrona inicializada con datos predefinidos. |
| `ram_sincrona.vhd` | Memoria RAM síncrona de lectura/escritura usando `rd_en`, `wr_en`, `addr`, `data_in` y `data_out`. |
| `sistema_memorias_auto_top.vhd` | Módulo automático principal que controla la transferencia ROM-RAM mediante FSM. |
| `DE0_TOP.vhd` | Entidad superior para la implementación física en la tarjeta DE0. |
| `tb_sistema_memorias_auto.vhd` | Testbench para validar la simulación automática del sistema. |

---

## Datos almacenados en la ROM

La ROM usada en esta versión contiene los siguientes datos iniciales:

| Dirección | Dato |
|---|---|
| `0` | `AA` |
| `1` | `55` |
| `2` | `F0` |
| `3` | `0F` |
| `4` | `FF` |
| `5` | `00` |
| `6` | `00` |
| `7` | `00` |
| `8` | `00` |
| `9` | `00` |
| `A` | `00` |
| `B` | `00` |
| `C` | `00` |
| `D` | `00` |
| `E` | `00` |
| `F` | `00` |

---

## Señales principales

| Señal | Descripción |
|---|---|
| `clk` | Reloj principal del sistema. |
| `rst` | Reinicia la FSM y el proceso automático. |
| `current_addr` | Dirección actual mostrada por el sistema. |
| `data_out` | Dato leído desde la RAM. |
| `copy_done` | Indica que la copia de ROM hacia RAM terminó. |
| `state_led` | Representa el estado actual de la FSM. |
| `rom_addr_s` | Dirección enviada a la ROM. |
| `rom_data_s` | Dato leído desde la ROM. |
| `ram_addr_s` | Dirección usada para escritura o lectura en RAM. |
| `ram_data_s` | Dato leído desde la RAM. |
| `ram_wr_s` | Señal de escritura en RAM. |
| `ram_rd_s` | Señal de lectura en RAM. |
| `tick_s` | Pulso de temporización para avanzar la lectura automática. |

---

## Asignación en la tarjeta DE0

| Elemento físico | Función |
|---|---|
| `CLOCK_50` | Reloj principal de 50 MHz. |
| `KEY[0]` | Reset del sistema. |
| `KEY[1]` | No se usa en la versión automática. |
| `KEY[2]` | No se usa en la versión automática. |
| `SW[9:0]` | No controlan el proceso; se dejaron declarados en el top. |
| `LEDR[7:0]` | Muestran el dato leído desde RAM. |
| `LEDR[8]` | Indica que finalizó la copia ROM-RAM. |
| `LEDR[9]` | Indica que el sistema está copiando datos. |
| `HEX0` | Parte baja del dato leído. |
| `HEX1` | Parte alta del dato leído. |
| `HEX2` | Dirección actual. |
| `HEX3` | Estado actual de la FSM. |

---

## Pineo principal

El diseño utiliza el dispositivo:

```text
Cyclone III EP3C16F484C6
