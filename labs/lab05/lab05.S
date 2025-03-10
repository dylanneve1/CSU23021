#include "hardware/regs/addressmap.h"
#include "hardware/regs/m0plus.h"
 
.syntax unified                 @ Specify unified assembly syntax
.cpu    cortex-m0plus           @ Specify CPU type is Cortex M0+
.thumb                          @ Specify thumb assembly for RP2040
.global main_asm                @ Provide program starting address to the linker
.align 4                        @ Specify code alignment
 
.equ    SLEEP_TIME, 500         @ Specify the sleep time (in ms)
.equ    LED_GPIO_PIN, 25        @ Specify the pin that the LED is connected to
.equ    LED_GPIO_OUT, 1         @ Specify the direction of the GPIO pin
.equ    LED_VALUE_ON, 1         @ Specify the value that turns the LED "on"
.equ    LED_VALUE_OFF, 0        @ Specify the value that turns the LED "off"
.equ    SVC_ISR_OFFSET, 0x2C    @ The SVC is entry 11 in the vector table
.equ    SVC_MAX_INSTRS, 0x01    @ Maximum allowed SVC subroutines

.equ    SETUP_LED_MSG, 1        @ Setup event button message
.equ    DO_SLEEP_MSG, 2         @ Do sleep event message
.equ    LED_ON_MSG, 3           @ LED on message
.equ    LED_OFF_MSG, 4          @ LED off message
.equ    SETUP_SVC_MSG, 5        @ Setup SVC message
 
@ Entry point to the ASM portion of the program
main_asm:
    bl      init_gpio_led       @ Initialise the GPIO LED pin
    bl      install_svc_isr     @ Install the SVC interrupt service routine
loop:
    svc     #0                  @ Call the SVC ISR with value 0 (turns on LED)
    nop                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep            @ Short pause before proceeding
    svc     #1                  @ Call the SVC ISR with value 1 (turns off LED)
    nop                         @ Add a no-op instruction for alignment after SVC
    bl      do_sleep            @ Add a short pause before proceeding
    b       loop                @ Always jump back to the start of the loop
 
@ Subroutine used to introduce a short delay in the application
do_sleep:
    push    {lr}                        @ Store the link register to the stack
    ldr     r0, =DO_SLEEP_MSG           @ Load the mapping for do_sleep_msg into r0
    bl      log_message                 @ Call log_message from C section of code
    ldr     r0, =SLEEP_TIME             @ Set the value of SLEEP_TIME we want to wait for
    bl      sleep_ms                    @ Sleep until SLEEP_TIME has elapsed then toggle the LED GPIO pin
    pop     {pc}                        @ Return to caller
 
@ Subroutine used to initialise the PI Pico built-in LED
init_gpio_led:
    push    {lr}                        @ Store the link register to the stack
    ldr     r0, =SETUP_LED_MSG          @ Load the mapping for setup_led_msg into r0
    bl      log_message                 @ Call log_message from C section of code
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board
    bl      asm_gpio_init               @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #LED_GPIO_PIN           @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #LED_GPIO_OUT           @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir            @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    pop     {pc}                        @ Return to caller
 
@ Subroutine used to install the SVC interrupt service handler
install_svc_isr:
    push    {lr}                                    @ Store the link register to the stack
    ldr     r0, =SETUP_SVC_MSG                      @ Load the mapping for setup_svc_msg into r0
    bl      log_message                             @ Call log_message from C section of code
    ldr     r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)    @ Load the address of the Vector Table Offset Register
    ldr     r1, [r2]                                @ Read the current vector table base address
    movs    r2, #SVC_ISR_OFFSET                     @ Load the offset for the SVC ISR in the vector table
    add     r2, r1                                  @ Compute the address of the SVC vector entry
    ldr     r0, =svc_isr                            @ Load the address of our custom SVC handler
    str     r0, [r2]                                @ Store the address of svc_isr into the SVC vector entry
    pop     {pc}                                    @ Return from the function
 
@ SVC interrupt service handler routine
.thumb_func                     @ Required for all interrupt service routines
svc_isr:
    push    {lr}                @ Save the Link Register (return address) onto the stack
    ldr     r0, [sp, #0x1C]     @ Load the stacked Program Counter (PC) value (address of SVC instruction)
    subs    r0, #0x2            @ Adjust PC to point to the actual SVC instruction
    ldr     r0, [r0]            @ Read the instruction at that address
    ldr     r1, =#0xFF          @ Load mask to extract the SVC number
    ands    r0, r1              @ Extract the immediate value
    cmp     r0, #SVC_MAX_INSTRS @ Compare with the max number of allowed SVC handlers
    bgt     svc_done            @ If SVC number is greater, exit ISR (invalid SVC call)
    adr     r1, svc_jmptbl      @ Load the address of the jump table for SVC handlers
    lsls    r0, #2              @ Multiply SVC number by 4 (word offset for jump table)
    ldr     r1, [r1, r0]        @ Load the address of the corresponding SVC handler
    mov     pc, r1              @ Branch to the appropriate SVC handler
svc_done:
    pop     {pc}                @ Restore the return address
 
@ First function of SVC subroutine - turn on the LED
svc_num0:
    ldr     r0, =LED_ON_MSG     @ Load the mapping for led_off_msg into r0
    bl      log_message         @ Call log_message from C section of code
    movs    r1, #LED_VALUE_ON   @ The LED is currently "off" so we want to turn it "on"
    movs    r0, #LED_GPIO_PIN   @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put        @ Update the the value of the LED GPIO pin (based on value in r1)
    b       svc_done            @ Branch back to the main ISR when done
 
@ Second function of SVC subroutine - turn off the LED
svc_num1:
    ldr     r0, =LED_OFF_MSG    @ Load the mapping for led_off_msg into r0
    bl      log_message         @ Call log_message from C section of code
    movs    r1, #LED_VALUE_OFF  @ The LED is currently "on" so we want to turn it "off"
    movs    r0, #LED_GPIO_PIN   @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put        @ Update the the value of the LED GPIO pin (based on value in r1)
    b       svc_done            @ Branch back to the main ISR when done
 
@ SVC function entry jump table.
.align 2
svc_jmptbl:
    .word svc_num0              @ Entry zero goes to SVC function #0.
    .word svc_num1              @ Entry one goes to SVC function #1.
    .word 0                     @ Null termination of the jump table.
 
@ Set data alignment
.data
    .align 4
