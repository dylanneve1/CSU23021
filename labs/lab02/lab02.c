#include <stdio.h>
#include <stdlib.h>
#include "pico/stdlib.h"
#include "pico/float.h"
#include "pico/double.h"

/**
 * @brief Calculates a single precision approximation of PI using a product series.
 *
 * This function approximates PI using the Wallis product.
 * 
 * When the formula is expanded, it results in an infinite series, which
 * can be used to calculate an approximate value for PI. The more iterations
 * are calculated, the more accurate the approximate becomes.
 *
 * @param iterations The number of iterations to perform the calculation.
 */
void calculatePI_singlePrecision(int iterations) {
    printf("Calculating single precision PI approximation...");
    float sum = 1, term, pi = 0;
    for (float i = 1; i <= iterations; i++) {
        term = pow((2 * i), 2) / ((2 * i - 1) * (2 * i + 1));
        sum *= term;
    }
    pi = 2 * sum;
    printf("Single Precision PI Approximation = %.10lf\n", pi);
}

/**
 * @brief Calculates a double precision approximation of PI using a product series.
 *
 * This function approximates PI using the Wallis product.
 * 
 * When the formula is expanded, it results in an infinite series, which
 * can be used to calculate an approximate value for PI. The more iterations
 * are calculated, the more accurate the approximate becomes.
 *
 * @param iterations The number of iterations to perform the calculation.
 */
void calculatePI_doublePrecision(int iterations) {
    printf("Calculating double precision PI approximation...");
    double sum = 1, term, pi = 0;
    for (double i = 1; i <= iterations; i++) {
        term = pow((2 * i), 2) / ((2 * i - 1) * (2 * i + 1));
        sum *= term;
    }
    pi = 2 * sum;
    printf("Double Precision PI Approximation = %.10lf\n", pi);
}

/**
 * @brief Entry point of the application.
 *
 * Initializes the standard I/O and starts the PI approximation calculation.
 *
 * @return int Application return code (zero for success).
 */
int main() {
    stdio_init_all();

    // Inform the user what's going on by starting the PI calculation.
    calculatePI_singlePrecision(100000);
    calculatePI_doublePrecision(100000);

    // Returning zero indicates that everything went okay.
    return 0;
}