#include "pico/stdlib.h"
#include <stdio.h>
#include "hardware/gpio.h"

// Define log message mappings
#define setup_led_msg        "init_gpio_led:    setting up LED on pin 25\n"
#define do_sleep_msg         "do_sleep:         sleeping for 500ms\n"
#define led_on_msg           "svc_num0:         toggling LED state to on\n"
#define led_off_msg          "svc_num1:         toggling LED state to off\n"
#define setup_svc_msg        "install_svc_isr:  toggling LED state to off\n"

// Must declare the main assembly entry point before use.
void main_asm();

// Logger function - called from assembly
void log_message(int code) {
    switch (code) {
        case 1:
            printf("%s", setup_led_msg);
            break;
        case 2:
            printf("%s", do_sleep_msg);
            break;
        case 3:
            printf("%s", led_on_msg);
            break;
        case 4:
            printf("%s", led_off_msg);
            break;
        case 5:
            printf("%s", setup_svc_msg);
            break;
        default:
            printf("Unknown log event: %d\n", code);
            break;
    }
}


/**
 * @brief Wrapper to allow the assembly code to call the gpio_init()
 *        SDK function.
 * 
 * @param pin       The GPIO pin number to initialise.
 */
void asm_gpio_init(int pin) {
    gpio_init(pin);
}


/**
 * @brief Wrapper to allow the assembly code to call the gpio_set_dir()
 *        SDK function.
 * 
 * @param pin       The GPIO pin number of which to set the direction.
 * @param dir       Specify the direction that the pin should be set to (0=input/1=output).
 */
void asm_gpio_set_dir(int pin, int dir) {
    gpio_set_dir(pin, dir);
}


/**
 * @brief Wrapper to allow the assembly code to call the gpio_get()
 *        SDK function.
 * 
 * @param pin       The GPIO pin number to read from.
 * @return int      Returns the current value of the GPIO pin.
 */
int asm_gpio_get(int pin) {
    return gpio_get(pin);
}


/**
 * @brief Wrapper to allow the assembly code to call the gpio_put()
 *        SDK function.
 * 
 * @param pin       The GPIO pin number to write to.
 * @param value     Specify the value that the pin should be set to (0/1).
 */
void asm_gpio_put(int pin, int value) {
    gpio_put(pin, value);
}


/**
 * @brief EXAMPLE - BLINK_ASM
 *        Simple example that uses assembly code to initialise
 *        the built-in LED on Raspberry Pi Pico and then flash
 *        it forever using a sleep routine to set the period of
 *        the flash.
 * 
 * @return int      Returns exit-status zero on completion.
 */
int main() {
    // Initialise all basic IO
    stdio_init_all();

    // Jump into the main assembly code subroutine.
    main_asm();

    // Returning zero indicates everything went okay.
    return 0;
}
