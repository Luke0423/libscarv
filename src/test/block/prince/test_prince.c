
#include <stdio.h>
#include <stdint.h>

#include "util.h"
#include "scarv/block/prince/prince.h"

const int num_prince_vectors = 5;

//! Known I/O vectors for prince.
uint64_t prince_test_vectors[5][4] = {
// plaintext       ,  k0              ,  k1              ,  cipher
{0x0000000000000000,0x0000000000000000,0x0000000000000000,0x818665aa0d02dfda},
{0xffffffffffffffff,0x0000000000000000,0x0000000000000000,0x604ae6ca03c20ada},
{0x0000000000000000,0xffffffffffffffff,0x0000000000000000,0x9fb51935fc3df524},
{0x0000000000000000,0x0000000000000000,0xffffffffffffffff,0x78a54cbe737bb7ef},
{0x0123456789abcdef,0x0000000000000000,0xfedcba9876543210,0xae25ad3ca8fa9ccf},
};


void put64h(uint64_t x) {
    uint8_t * p = (uint8_t*)&x;

    printf("0x");
    for(int i = 0; i < 8; i ++) {
        uint8_t c = p[7-i];
        printf("%.2X", c);
    }
}

int main(int argc, char ** argv) {

    printf("import sys\n");

    for(int i = 0; i < num_prince_vectors; i++) {

        uint64_t plaintext = prince_test_vectors[i][0];
        uint64_t k0        = prince_test_vectors[i][1];
        uint64_t k1        = prince_test_vectors[i][2];
        uint64_t ciphertext= prince_test_vectors[i][3];

        uint64_t enc_result= 0;
        uint64_t dec_result= 0;

        printf("# ----- Prince %d / %d --------\n", i,num_prince_vectors);

        printf("plaintext = "); put64h(plaintext ); printf("\n");
        printf("k0        = "); put64h(k0        ); printf("\n");
        printf("k1        = "); put64h(k1        ); printf("\n");
        printf("ciphertext= "); put64h(ciphertext); printf("\n");

        MEASURE (
            enc_result = prince_enc(plaintext, k0, k1);
        );

        printf("enc_result= "); put64h(enc_result); printf("\n");

        if(enc_result != ciphertext) {
            printf("print('Encryption fail. Expected ");
            put64h(ciphertext);
            printf(", got ");
            put64h(enc_result);
            printf("')\n");
            printf("sys.exit(1)\n");
        }

        MEASURE(
            dec_result = prince_dec(ciphertext, k0, k1);
        );

        printf("dec_result= "); put64h(dec_result); printf("\n");

        if(dec_result != plaintext) {
            printf("print('Decryption fail. Expected ");
            put64h(plaintext);
            printf(", got ");
            put64h(dec_result);
            printf("')\n");
            printf("sys.exit(1)\n");
        }
    }
}
