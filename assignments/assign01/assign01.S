#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified
.cpu    cortex-m0plus
.thumb
.global main_asm
.align  4

.equ    DFLT_STATE_STRT,           1                        @ Specify the value to start flashing
.equ    DFLT_STATE_STOP,           0                        @ Specify the value to stop flashing
.equ    DFLT_ALARM_TIME,     1000000                        @ Specify the default alarm timeout

.equ    GPIO_BTN_DN_MSK,  0x00040000                        @ Bit-18 for falling-edge event on GP20
.equ    GPIO_BTN_EN_MSK,  0x00400000                        @ Bit-22 for falling-edge event on GP21
.equ    GPIO_BTN_UP_MSK,  0x04000000                        @ Bit-26 for falling-edge event on GP22

.equ    GPIO_BTN_DN,              20                        @ Specify pin for the "down" button
.equ    GPIO_BTN_EN,              21                        @ Specify pin for the "enter" button
.equ    GPIO_BTN_UP,              22                        @ Specify pin for the "up" button
.equ    GPIO_LED_PIN,             25                        @ Specify pin for the built-in LED
.equ    GPIO_DIR_IN,               0                        @ Specify input direction for a GPIO pin
.equ    GPIO_DIR_OUT,              1                        @ Specify output direction for a GPIO pin

.equ    LED_VAL_ON,                1                        @ Specify value that turns the LED "on"
.equ    LED_VAL_OFF,               0                        @ Specify value that turns the LED "off"

.equ    BUTTON_GPIO_PRESSED,       0

.equ    GPIO_ISR_OFFSET,        0x74                        @ GPIO is int #13 (vector table entry 29)
.equ    ALRM_ISR_OFFSET,        0x40                        @ ALARM0 is int #0 (vector table entry 16)

/**
 * @brief Main entry point
 *        Core code for assembly section of the program
 */
main_asm:
@------ INITIAL SETUP--------------------------------------
    bl      led_setup                                       @ Branch to led_setup
    bl      button_setup                                    @ Branch to button_setup
    bl      alarm_setup                                     @ Branch to alarm_setup
    bl      set_alarm                                       @ Branch to set_alarm
    bl      gpio_setup                                      @ Branch to gpio_setup
@-----------------------------------------------------------
    bl      main_loop                                       @ Branch to main_loop
@-----------------------------------------------------------

/**
 * @brief LED Setup
 *        Sets up LED on pin 25 as an output
 */
led_setup:
    push    {lr}
@------ DEBUG PRINT ----------------------------------------
    ldr     r0, =setup_led_msg                              @ Load LED setup message into r0
    bl      printf                                          @ Branch to printf
@------ ENABLE LED -----------------------------------------
    ldr     r0, =GPIO_LED_PIN                               @ Load LED Pin number into r0
    bl      asm_gpio_init                                   @ Initialize GPIO pin
    ldr     r0, =GPIO_LED_PIN                               @ Load LED Pin number into r0
    ldr     r1, =GPIO_DIR_OUT                               @ Load LED Pin direction into r1
    bl      asm_gpio_set_dir                                @ Branch to asm_gpio_set_dir
@-----------------------------------------------------------
    pop     {pc}

/**
 * @brief Alarm Setup
 *        Sets up alarm
 */
alarm_setup:
@------ ENABLE ALARM ---------------------------------------
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)            @ Load the address of the Vector Table Offset Register into r2  
    ldr     r1, [r2]                                        @ Load this value into r2 
    movs    r2, #ALRM_ISR_OFFSET                            @ Move the ALARM0 offset into r2 
    add     r2, r1                                          @ Add the Alarm0 offset to the base address of Vector Table 
    ldr     r0, =alarm_isr                                  @ Load the address of subtoggle_led into r0 
    str     r0, [r2]                                        @ Store the value into r2 (base address for RP2040 + Alarm0 offset), i.e. the alarm isr address
    movs    r0, #1                                     
    lsls    r1, #0
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)       @ Load the address for the NVIC Interrupt Clear Pending register
    str     r0, [r2]                                        @ Clear any pending interrupts by writing 1 at bit position 0 to the ICPR register
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)       @ Load the address for the NVIC Interrupt Set Enable register
    str     r0, [r2]                                        @ Enable the alarm 0 interrupt by writing 1 at bit position 0 to the ISER register
@-----------------------------------------------------------
    bx      lr 

set_alarm:
@------ SET ALARM ------------------------------------------
    ldr     r0, =ltimer                                     @ Load the address of sleeptime into r1
    ldr     r0, [r0]                                        @ where r0 is the length of the alarm
    ldr     r2, =TIMER_BASE                                 @ Load the address of the base address for the RP2040 timer component
    movs    r1, #1                                          @ Move logical HIGH into r1
    str     r1, [r2, #TIMER_INTE_OFFSET]                    @ Writing 1 at bit position 0 to TIMER interrupt enable register.
    ldr     r1, [r2, #TIMER_TIMELR_OFFSET]                  @ Load the current time from the timer 
    add     r1, r0                                          @ Add the current time to sleeptime
    str     r1, [r2, #TIMER_ALARM0_OFFSET]                  @ Write this new time to the ALARM0 control register
@-----------------------------------------------------------
    bx      lr

gpio_setup:
@------ GPIO SETUP -----------------------------------------
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)            @ Load the address of the Vector Table Offset Register into r2  
    ldr     r1, [r2]                                        @ Load the base address into r1 
    movs    r2, #GPIO_ISR_OFFSET                            @ Move the GPIO offset into r2 
    add     r2, r1                                          @ Add the GPIO offset to the base address of the Vector Table 
    ldr     r1, =gpio_isr                                   @ Load the address of gpio_isr into r1 
    str     r1, [r2]                                        @ Store this value into r2 (base address for RP2040 + GPIO offset), i.e. the gpio isr address
    movs    r1, #1                                          @ Move the value 1 into r1 where bit 13 is logical HIGH
    lsls    r1, #13
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)       @ Load the address for the NVIC Interrupt Clear Pending register
    str     r1, [r2]                                        @ Store the value in r1 into the ICPR - bit 13 as the GPIO is at int #13
    ldr     r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)       @ Load the address for the NVIC  Interrupt Set Enable register
@-----------------------------------------------------------
    str     r1, [r2]                                        @ Store the value in r1 into the ISER - this enables the GPIO interrupt
    bx      lr 

/**
 * @brief Button Setup
 *        Sets up buttons on pin 20, 21 and 22 as inputs
 */
button_setup:
    push    {lr}
@------ DEBUG PRINT ----------------------------------------
    ldr     r0, =setup_ebutton_msg
    bl      printf
@------ ENABLE BUTTON --------------------------------------
    ldr     r0, =GPIO_BTN_EN                                @ Load Enable Pin number into r0
    bl      asm_gpio_init                                   @ Initialize GPIO pin
    ldr     r0, =GPIO_BTN_EN                                @ Load Enable Pin number into r0
    ldr     r1, =GPIO_DIR_IN                                @ Load direction, input, into r1
    bl      asm_gpio_set_dir                                @ Set Enable as input
@------ DEBUG PRINT ----------------------------------------
    ldr     r0, =setup_ubutton_msg
    bl      printf
@------ UP BUTTON ------------------------------------------
    ldr     r0, =GPIO_BTN_UP                                @ Load Up Pin number into r0
    bl      asm_gpio_init                                   @ Initialize GPIO pin
    ldr     r0, =GPIO_BTN_UP                                @ Load Up Pin number into r0
    ldr     r1, =GPIO_DIR_IN                                @ Load direction, input, into r1
    bl      asm_gpio_set_dir                                @ Set Up as input
@------ DEBUG PRINT ----------------------------------------
    ldr     r0, =setup_dbutton_msg
    bl      printf
@------ DOWN BUTTON ----------------------------------------
    ldr     r0, =GPIO_BTN_DN                                @ Load Down Pin number into r0
    bl      asm_gpio_init                                   @ Initialize GPIO pin
    ldr     r0, =GPIO_BTN_DN                                @ Load Down Pin number into r0
    ldr     r1, =GPIO_DIR_IN                                @ Load direction, input, into r1
    bl      asm_gpio_set_dir                                @ Set Down as input
@-----------------------------------------------------------
    pop     {pc}                                            @ Return to caller

/**
 * @brief Main Loop
 *        The main loop of the asm part of the program
 */
main_loop:
    b       main_loop

.thumb_func
gpio_isr:
    push    {lr}                                            @ Store the link register to the stack 
    pop     {pc}                                            @ Pop the link register from the stack to the program counter

.thumb_func
alarm_isr:
    push    {lr}                                            @ Store the link register to the stack
@------ DEBUG PRINT ----------------------------------------
    ldr     r0, =alarm_isr_msg
    bl      printf
@------ CLEAR ALARM INTERRUPT FLAG -------------------------
    ldr     r2, =TIMER_BASE                                 @ Load timer base address into r2
    movs    r1, #1                                          @ Set alarm interrupt flag
    str     r1, [r2, #TIMER_INTR_OFFSET]                    @ Clear interrupt by writing to TIMER register
@------ READ LED PIN ---------------------------------------
    movs    r0, #GPIO_LED_PIN                               @ Set the LED GPIO pin number to r0 for use by asm_gpio_get
    bl      asm_gpio_get                                    @ Get current the value of the LED GPIO pin (returns to r0)
@------ CONDITIONAL LOGIC ----------------------------------
    cmp     r0, #LED_VAL_OFF                                @ Check if the LED GPIO pin value is "off"
    beq     led_set_on                                      @ If it is "off" then then jump code to to turn it on
    b       led_set_off
@-----------------------------------------------------------

/**
 * @brief LED set OFF
 *        Subroutine to set LED state to ON
 */
led_set_off:
@------ DEBUG PRINT ----------------------------------------
    ldr     r0, =led_off_msg                                @ Load the asciz led_off_msg into r0
    bl      printf                                          @ Print the statement loaded into r0
@------ SET DESIRED STATE ----------------------------------
    movs    r1, #LED_VAL_OFF                                @ The LED is currently "on" so we want to turn it "off"
@------ JUMP TO SET STATE ----------------------------------
    b       led_set_state                                   @ Jump to portion of code where we set the state of the LED
@-----------------------------------------------------------

/**
 * @brief LED set ON
 *        Subroutine to set LED state to OFF
 */
led_set_on:
@------ DEBUG PRINT ----------------------------------------
    ldr     r0, =led_on_msg                                 @ Load the asciz led_on_msg into r0
    bl      printf                                          @ Print the statement loaded into r0
@------ SET DESIRED STATE ----------------------------------
    movs    r1, #LED_VAL_ON                                 @ The LED is currently "off" so we want to turn it "on"
@-----------------------------------------------------------

/**
 * @brief LED set STATE
 *        Subroutine set LED state based on r1
 */
led_set_state:
@------ SET LED STATE --------------------------------------
    movs    r0, #GPIO_LED_PIN                               @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put                                    @ Update the the value of the LED GPIO pin (based on value in r1)
@-----------------------------------------------------------
    bl      set_alarm                                       @ Call the set_alarm subroutine to reset the flash rate
    pop     {pc}                                            @ Pop the link register from the stack to the program counter


.align 4
setup_ebutton_msg: .asciz "button_setup: setting up EN button on pin 21\n"
setup_ubutton_msg: .asciz "button_setup: setting up UP button on pin 21\n"
setup_dbutton_msg: .asciz "button_setup: setting up DOWN button on pin 21\n"
setup_led_msg:     .asciz "led_setup:    setting up LED on pin 25\n"
led_on_msg:        .asciz "led_set_on:   toggling LED on\n"
led_off_msg:       .asciz "led_set_off:  toggling LED off\n"
alarm_isr_msg      .asciz "alarm_isr:    timer triggered!\n"

.data
lstate:    .word   DFLT_STATE_STRT
ltimer:    .word   DFLT_ALARM_TIME
