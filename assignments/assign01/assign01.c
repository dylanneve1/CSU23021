#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"

// Define log message mappings
#define setup_ebutton_msg    "button_setup:          setting up EN button on pin 21\n"
#define setup_ubutton_msg    "button_setup:          setting up UP button on pin 22\n"
#define setup_dbutton_msg    "button_setup:          setting up DOWN button on pin 20\n"
#define event_msg            "gpio_isr:              an event has occurred!\n"
#define event_eb_msg         "enable_button_event:   enable button has been pressed\n"
#define event_ub_msg         "up_button_event:       up button has been pressed\n"
#define event_db_msg         "down_button_event:     down button has been pressed\n"
#define setup_led_msg        "led_setup:             setting up LED on pin 25\n"
#define led_on_msg           "led_set_on:            toggling LED state to on\n"
#define led_off_msg          "led_set_off:           toggling LED state to off\n"
#define reset_timer_msg      "reset_timer_event:     timer reset to DFLT_ALARM_TIME\n"

// Declare the main assembly code entry point.
void main_asm();

// Logger function - called from assembly
void log_message(int code) {
    switch (code) {
        case 1:
            printf("%s", setup_ebutton_msg);
            break;
        case 2:
            printf("%s", setup_ubutton_msg);
            break;
        case 3:
            printf("%s", setup_dbutton_msg);
            break;
        case 4:
            printf("%s", event_msg);
            break;
        case 5:
            printf("%s", event_eb_msg);
            break;
        case 6:
            printf("%s", event_ub_msg);
            break;
        case 7:
            printf("%s", event_db_msg);
            break;
        case 8:
            printf("%s", setup_led_msg);
            break;
        case 9:
            printf("%s", led_on_msg);
            break;
        case 10:
            printf("%s", led_off_msg);
            break;
        case 11:
            printf("%s", reset_timer_msg);
            break;
        default:
            printf("Unknown log event: %d\n", code);
            break;
    }
}

// Initialise a GPIO pin – see SDK for detail on gpio_init()
void asm_gpio_init(uint pin) {
    gpio_init(pin);
}

// Set direction of a GPIO pin – see SDK for detail on gpio_set_dir()
void asm_gpio_set_dir(uint pin, bool out) {
    gpio_set_dir(pin, out);
}

// Get the value of a GPIO pin – see SDK for detail on gpio_get()
bool asm_gpio_get(uint pin) {
    return gpio_get(pin);
}

// Set the value of a GPIO pin – see SDK for detail on gpio_put()
void asm_gpio_put(uint pin, bool value) {
    gpio_put(pin, value);
}

// Enable falling-edge interrupt – see SDK for detail on gpio_set_irq_enabled()
void asm_gpio_set_irq(uint pin) {
    gpio_set_irq_enabled(pin, GPIO_IRQ_EDGE_FALL, true);
}

// Main entry point of the application
int main() {
    stdio_init_all();              // Initialise all basic IO
    printf("Assignment #1...\n");  // Basic print to console
    main_asm();                    // Jump into the ASM code
    return 0;                      // Application return code
}
