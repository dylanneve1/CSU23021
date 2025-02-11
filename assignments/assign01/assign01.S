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
        bl      led_setup                                   @ Branch to led_setup subroutine
        bl      button_setup                                @ Branch to button_setup subroutine
@-----------------------------------------------------------
        bl      main_loop                                   @ Branch to main loop
@-----------------------------------------------------------

/**
 * @brief LED Setup
 *        Sets up LED on pin 25 as an output
 */
led_setup:
        push    {lr}
@------ DEBUG PRINT ----------------------------------------
        ldr     r0, =setup_led_msg
        bl      printf
@------ ENABLE LED -----------------------------------------
        ldr     r0, =GPIO_LED_PIN                           @ Load LED Pin number into r0
        bl      asm_gpio_init                               @ Initialize GPIO pin
        ldr     r0, =GPIO_LED_PIN
        ldr     r1, =GPIO_DIR_OUT
        bl      asm_gpio_set_dir                            @ Set LED as output
@-----------------------------------------------------------
        pop     {pc}

/**
 * @brief Alarm Setup
 *        Sets up alarm
 */
alarm_setup:
@------ ENABLE ALARM ---------------------------------------
@-----------------------------------------------------------


/**
 * @brief Button Setup
 *        Sets up buttons on pin 20, 21 and 22 as inputs
 */
button_setup:
        push    {lr}
@------ DEBUG PRINT ----------------------------------------
        ldr     r0, =setup_button_msg
        bl      printf
@------ ENABLE BUTTON --------------------------------------
        ldr     r0, =GPIO_BTN_EN                            @ Load Enable Pin number into r0
        bl      asm_gpio_init                               @ Initialize GPIO pin
        ldr     r0, =GPIO_BTN_EN                            @ Load Enable Pin number into r0
        ldr     r1, =GPIO_DIR_IN                            @ Load direction, input, into r1
        bl      asm_gpio_set_dir                            @ Set Enable as input
@------ UP BUTTON ------------------------------------------
        ldr     r0, =GPIO_BTN_UP                            @ Load Up Pin number into r0
        bl      asm_gpio_init                               @ Initialize GPIO pin
        ldr     r0, =GPIO_BTN_UP                            @ Load Up Pin number into r0
        ldr     r1, =GPIO_DIR_IN                            @ Load direction, input, into r1
        bl      asm_gpio_set_dir                            @ Set Up as input
@------ DOWN BUTTON ----------------------------------------
        ldr     r0, =GPIO_BTN_DN                            @ Load Down Pin number into r0
        bl      asm_gpio_init                               @ Initialize GPIO pin
        ldr     r0, =GPIO_BTN_DN                            @ Load Down Pin number into r0
        ldr     r1, =GPIO_DIR_IN                            @ Load direction, input, into r1
        bl      asm_gpio_set_dir                            @ Set Down as input
@-----------------------------------------------------------
        pop     {pc}                                        @ Return to caller

/**
 * @brief Main Loop
 *        The main loop of the asm part of the program
 */
main_loop:
        bl      main_loop

/**
 * @brief Toggle
 *        Subroutine to toggle the LED value
 */
sub_toggle:
        push    {lr}                                        @ Store the link register to the stack as we will call nested subroutines
@------ READ LED PIN ---------------------------------------
        movs    r0, #GPIO_LED_PIN                           @ Set the LED GPIO pin number to r0 for use by asm_gpio_get
        bl      asm_gpio_get                                @ Get current the value of the LED GPIO pin (returns to r0)
@------ CONDITIONAL LOGIC ----------------------------------
        cmp     r0, #LED_VAL_OFF                            @ Check if the LED GPIO pin value is "off"
        beq     led_set_on                                  @ If it is "off" then then jump code to to turn it on
        b       led_set_off
@-----------------------------------------------------------

/**
 * @brief LED set OFF
 *        Subroutine to set LED state to ON
 */
led_set_off:
@------ DEBUG PRINT ----------------------------------------
        ldr     r0, =led_off_msg                            @ Load the asciz led_off_msg into r0
        bl      printf                                      @ Print the statement loaded into r0
@------ SET DESIRED STATE ----------------------------------
        movs    r1, #LED_VAL_OFF                            @ The LED is currently "on" so we want to turn it "off"
@------ JUMP TO SET STATE ----------------------------------
        b       led_set_state                               @ Jump to portion of code where we set the state of the LED
@-----------------------------------------------------------

/**
 * @brief LED set ON
 *        Subroutine to set LED state to OFF
 */
led_set_on:
@------ DEBUG PRINT ----------------------------------------
        ldr     r0, =led_on_msg                             @ Load the asciz led_on_msg into r0
        bl      printf                                      @ Print the statement loaded into r0
@------ SET DESIRED STATE ----------------------------------
        movs    r1, #LED_VAL_ON                             @ The LED is currently "off" so we want to turn it "on"
@-----------------------------------------------------------

/**
 * @brief LED set STATE
 *        Subroutine set LED state based on r1
 */
led_set_state:
@------ SET LED STATE --------------------------------------------------------
        movs    r0, #GPIO_LED_PIN                           @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
        bl      asm_gpio_put                                @ Update the the value of the LED GPIO pin (based on value in r1)
@-----------------------------------------------------------
        pop     {pc}                                        @ Pop the link register from the stack to the program counter


.align 4
setup_button_msg:  .asciz "main_asm:   setting up button on pin 21\n"
setup_led_msg:     .asciz "main_asm:   setting up LED on pin 25\n"
button_press_msg:  .asciz "main_loop:  button press detected\n"
led_on_msg:        .asciz "sub_toggle: toggling LED on\n"
led_off_msg:       .asciz "sub_toggle: toggling LED off\n"

.data
lstate:    .word   DFLT_STATE_STRT
ltimer:    .word   DFLT_ALARM_TIME
sleeptime: .word   1000                                     @ The amount of time between blinks
