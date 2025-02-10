#include <stdio.h>
#include <stdlib.h>
#include "pico/stdlib.h"
#include "pico/float.h"
#include "pico/double.h"

#define DEFINED_PI 3.14159265359

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
    printf("------------------------------------------------\n");
    printf("Calculating single precision PI approximation...\n");
    float sum = 1, term, pi = 0;
    for (float i = 1; i <= iterations; i++) {
        term = pow((2 * i), 2) / ((2 * i - 1) * (2 * i + 1));
        sum *= term;
    }
    pi = 2 * sum;
    float error = fabsf(pi - DEFINED_PI);
    printf("Single Precision PI Approximation = %.11f\n", pi);
    printf("Absolute Error = %.11f\n", error);
    printf("------------------------------------------------\n");
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
    printf("------------------------------------------------\n");
    printf("Calculating double precision PI approximation...\n");
    double sum = 1, term, pi = 0;
    for (double i = 1; i <= iterations; i++) {
        term = pow((2 * i), 2) / ((2 * i - 1) * (2 * i + 1));
        sum *= term;
    }
    pi = 2 * sum;
    double error = fabs(pi - DEFINED_PI);
    printf("Double Precision PI Approximation = %.11f\n", pi);
    printf("Absolute Error = %.11f\n", error);
    printf("------------------------------------------------\n");
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

    printf("Approximating PI: Lab02\n");
    printf("username:         neved\n");
    printf("S/N:          213643332\n");

    calculatePI_singlePrecision(100000);
    calculatePI_doublePrecision(100000);

    // Returning zero indicates that everything went okay.
    return 0;
}