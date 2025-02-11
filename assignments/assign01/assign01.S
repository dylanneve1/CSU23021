#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified
.cpu    cortex-m0plus
.thumb
.global main_asm
.align  4

.equ    DFLT_STATE_STRT, 1            @ Specify the value to start flashing
.equ    DFLT_STATE_STOP, 0            @ Specify the value to stop flashing
.equ    DFLT_ALARM_TIME, 1000000      @ Specify the default alarm timeout

.equ    GPIO_BTN_DN_MSK, 0x00040000   @ Bit-18 for falling-edge event on GP20
.equ    GPIO_BTN_EN_MSK, 0x00400000   @ Bit-22 for falling-edge event on GP21
.equ    GPIO_BTN_UP_MSK, 0x04000000   @ Bit-26 for falling-edge event on GP22

.equ    GPIO_BTN_DN,  20              @ Specify pin for the "down" button
.equ    GPIO_BTN_EN,  21              @ Specify pin for the "enter" button
.equ    GPIO_BTN_UP,  22              @ Specify pin for the "up" button
.equ    GPIO_LED_PIN, 25              @ Specify pin for the built-in LED
.equ    GPIO_DIR_IN,   0              @ Specify input direction for a GPIO pin
.equ    GPIO_DIR_OUT,  1              @ Specify output direction for a GPIO pin

.equ    LED_VAL_ON,    1              @ Specify value that turns the LED "on"
.equ    LED_VAL_OFF,   0              @ Specify value that turns the LED "off"

.equ    GPIO_ISR_OFFSET, 0x74         @ GPIO is int #13 (vector table entry 29)
.equ    ALRM_ISR_OFFSET, 0x40         @ ALARM0 is int #0 (vector table entry 16)

.data
sleeptime: .word 1000                 @ The amount of time between blinks

@ Entry point to the ASM portion of the program
main_asm:
@-------LED SETUP --------------------
        ldr     r0, =GPIO_LED_PIN     @ Load LED Pin number into r0
        bl      asm_gpio_init         @ Initialize GPIO pin
        ldr     r0, =GPIO_LED_PIN
        ldr     r1, =GPIO_DIR_OUT
        bl      asm_gpio_set_dir      @ Set LED as output
@------ BUTTON SETUP -----------------
        @ Enable
        ldr     r0, =GPIO_BTN_EN      @ Load Enable Pin number into r0
        bl      asm_gpio_init         @ Initialize GPIO pin
        ldr     r0, =GPIO_BTN_EN      @ Load Enable Pin number into r0
        ldr     r1, =GPIO_DIR_IN      @ Load direction, input, into r1
        bl      asm_gpio_set_dir      @ Set Enable as input
        @ Up
        ldr     r0, =GPIO_BTN_UP      @ Load Up Pin number into r0
        bl      asm_gpio_init         @ Initialize GPIO pin
        ldr     r0, =GPIO_BTN_UP      @ Load Up Pin number into r0
        ldr     r1, =GPIO_DIR_IN      @ Load direction, input, into r1
        bl      asm_gpio_set_dir      @ Set Up as input
        @ Down
        ldr     r0, =GPIO_BTN_DN      @ Load Down Pin number into r0
        bl      asm_gpio_init         @ Initialize GPIO pin
        ldr     r0, =GPIO_BTN_DN      @ Load Down Pin number into r0
        ldr     r1, =GPIO_DIR_IN      @ Load direction, input, into r1
        bl      asm_gpio_set_dir      @ Set Down as input

main_loop:
        ldr     r0, =msg
        bl      printf

        @ Turn LED ON
        ldr     r0, =GPIO_LED_PIN
        ldr     r1, =LED_VAL_ON
        bl      asm_gpio_put

        @ Wait for sleeptime
        ldr     r0, =sleeptime
        bl      sleep_ms

        @ Turn LED OFF
        ldr     r0, =GPIO_LED_PIN
        ldr     r1, =LED_VAL_OFF
        bl      asm_gpio_put

        @ Wait for sleeptime
        ldr     r0, =sleeptime
        bl      sleep_ms

        b       main_loop              @ Repeat loop

.align 4
msg:    .asciz "Running loop!\n"

.data
lstate: .word   DFLT_STATE_STRT
ltimer: .word   DFLT_ALARM_TIME
