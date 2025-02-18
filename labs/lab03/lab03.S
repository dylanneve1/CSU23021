.syntax unified                                    @ Specify unified assembly syntax
.cpu    cortex-m0plus                              @ Specify CPU type is Cortex M0+
.thumb                                             @ Specify thumb assembly for RP2040
.global main_asm                                   @ Provide program starting address to the linker
.align  4                                          @ Specify code alignment

.equ    SLEEP_TIME,            500                 @ Specify the amount of ms that we want to sleep for in the loop
.equ    LED_GPIO_PIN,           25                 @ Specifiy the physical GPIO pin that the LED is connected to
.equ    LED_GPIO_OUT,            1                 @ Specify the direction that we want to set the GPIO pin to
.equ    LED_VALUE_ON,            1                 @ Specify the value that turns the LED "on"
.equ    LED_VALUE_OFF,           0                 @ Specify the value that turns the LED "off"

.equ    BUTTON_GPIO_PIN,        21                 @ Specify the physical GPIO pin that the button is connected to
.equ    BUTTON_GPIO_DIR,         0                 @ Specify the direction that we want to set the GPIO pin to
.equ    BUTTON_GPIO_PRESSED,     0                 @ Specify buttons active state, visible on MAKER PI PICO board

@ Entry point to the ASM portion of the program
main_asm:
    ldr     r0, =setup_led_msg                     @ Load the asciz setup_led_msg into r0
    bl      printf                                 @ Print the statement loaded into r0
    movs    r0, #LED_GPIO_PIN                      @ This value is the GPIO LED pin on the PI PICO board
    bl      asm_gpio_init                          @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #LED_GPIO_PIN                      @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #LED_GPIO_OUT                      @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir                       @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    ldr     r0, =setup_button_msg                  @ Load the asciz setup_button_msg into r0
    bl      printf                                 @ Print the statement loaded into r0
    movs    r0, #BUTTON_GPIO_PIN                   @ This value is the GPIO button pin on the PI PICO board
    bl      asm_gpio_init                          @ Call the subroutine to initialise the GPIO pin specified by r0
    movs    r0, #BUTTON_GPIO_PIN                   @ This value is the GPIO LED pin on the PI PICO board
    movs    r1, #BUTTON_GPIO_DIR                   @ We want this GPIO pin to be setup as an output pin
    bl      asm_gpio_set_dir                       @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    movs    r2, #1                                 @ Stores previous button state, not pressed to begin with
loop:
    bl      sub_read_button                        @ Read button state (result in r0)
    cmp     r0, #BUTTON_GPIO_PRESSED               @ Check if button is pressed (active low)
    bne     skip_toggle                            @ If not pressed, skip toggling
    cmp     r2, #1                                 @ Check if previous state was not pressed
    bne     skip_toggle                            @ If it was already pressed, skip toggle
    ldr     r0, =button_press_msg                  @ Load the asciz button_press_msg into r0
    bl      printf                                 @ Print the statement loaded into r0
    bl      sub_toggle                             @ Toggle LED state
skip_toggle:
    movs    r2, r0                                 @ Store current button state for next iteration
    b       loop                                   @ Repeat loop

@ Subroutine to read button state
sub_read_button:
    push    {lr}                                   @ Store the link register to the stack as we will call nested subroutines                       
    movs    r0, #BUTTON_GPIO_PIN                   @ Load the button's GPIO pin number into r0
    bl      asm_gpio_get                           @ Call asm_gpio_get to read the current state of the button pin
    pop     {pc}                                   @ Pop the link register from the stack to the program counter  

@ Subroutine to toggle the LED GPIO pin value
sub_toggle:
    push    {lr}                                   @ Store the link register to the stack as we will call nested subroutines
    movs    r0, #LED_GPIO_PIN                      @ Set the LED GPIO pin number to r0 for use by asm_gpio_get
    bl      asm_gpio_get                           @ Get current the value of the LED GPIO pin (returns to r0)
    cmp     r0, #LED_VALUE_OFF                     @ Check if the LED GPIO pin value is "off"
    beq     led_set_on                             @ If it is "off" then then jump code to to turn it on
led_set_off:
    ldr     r0, =led_off_msg                       @ Load the asciz led_off_msg into r0
    bl      printf                                 @ Print the statement loaded into r0
    movs    r1, #LED_VALUE_OFF                     @ The LED is currently "on" so we want to turn it "off"
    b       led_set_state                          @ Jump to portion of code where we set the state of the LED
led_set_on:
    ldr     r0, =led_on_msg                        @ Load the asciz led_on_msg into r0
    bl      printf                                 @ Print the statement loaded into r0
    movs    r1, #LED_VALUE_ON                      @ The LED is currently "off" so we want to turn it "on"
led_set_state:
    movs    r0, #LED_GPIO_PIN                      @ Set the LED GPIO pin number to r0 for use by asm_gpio_put
    bl      asm_gpio_put                           @ Update the the value of the LED GPIO pin (based on value in r1)
    pop     {pc}                                   @ Pop the link register from the stack to the program counter

.align 4                                           @ Specify code alignment
setup_button_msg:  .asciz "main_asm:   setting up button on pin 21\n"
setup_led_msg:     .asciz "main_asm:   setting up LED on pin 25\n"
button_press_msg:  .asciz "loop:       button press detected\n"
led_on_msg:        .asciz "sub_toggle: toggling LED on\n"
led_off_msg:       .asciz "sub_toggle: toggling LED off\n"
@ Set data alignment
.data
    .align 4
