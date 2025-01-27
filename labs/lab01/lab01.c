#include "pico/stdlib.h"

// FUNCTION TO CONTROL LED LIGH
void ledControl(int ledPin, int ledDelay);

/**
 * @brief EXAMPLE - BLINK_C
 *        Simple example to initialise the built-in LED on
 *        the Raspberry Pi Pico and then flash it forever. 
 * 
 * @return int  Application return code (zero for success).
 */
int main() {

    // Specify the PIN number and sleep delay
    const uint LED_PIN   =  25;
    const uint LED_DELAY = 500;

    // Setup the LED pin as an output.
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    // Do forever...
    while (true) {
      ledControl(LED_PIN, LED_DELAY);
    }

    // Should never get here due to infinite while-loop.
    return 0;

}

/**
* @brief Controls the LED state and delay
*
* @param ledPin   The GPIO pin connected to the LED.
* @param ledDelay Delay in milliseconds between state toggles.
*/
void ledControl(int ledPin, int ledDelay) {
  // Toggle the LED on and then sleep for delay period
  gpio_put(ledPin, 1);
  sleep_ms(ledDelay);

  // Toggle the LED off and then sleep for delay period
  gpio_put(ledPin, 0);
  sleep_ms(ledDelay);
}

