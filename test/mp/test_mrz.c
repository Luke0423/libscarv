#include "test_mrz.h"

FILE* urandom = NULL; mrz_ctx_t ctx;

// ============================================================================

int test_mrz_rand_modulus( mrz_t r, int l_min, int l_max ) {
  uint8_t t;

  fread( &t, sizeof( uint8_t ), 1, urandom );

  int l_r = ( t % ( l_max + 1 - l_min) ) + l_min;

  do {
    fread( r, sizeof( limb_t ), l_r, urandom );
  } while( !( r[ 0 ] & 1 ) );

  return l_r;
}

int test_mrz_rand_operand( mrz_t r, mrz_t x, int l_x ) {
  int l_r = l_x;

  do {
    fread( r, sizeof( limb_t ), l_r, urandom );
  }
  while( mpn_cmp( r, l_r, x, l_x ) >= 0 );

  return l_r;
}

void test_mrz_dump( char* id, mrz_t x, int l_x ) {
  printf( "%s = int( '", id );

  for( int i = l_x - 1; i >= 0; i-- ) {
    printf( "%08lX", x[ i ] );
  }

  printf( "', 16 )\n" );
}

// ============================================================================

void test_mrz_exp( int n, int l_min, int l_max ) {
  for( int i = 0; i < n; i++ ) {
    printf("# test_mrz:mrz_exp[%d/%d]\n", i, n );

    mrz_t N; int l_N;
    mrz_t x; int l_x;
    mrz_t y; int l_y;
    mrz_t r; int l_r;

    l_N = l_r = test_mrz_rand_modulus( N, l_min, l_max );

          l_x = test_mrz_rand_operand( x, N, l_N );
          l_y = test_mrz_rand_operand( y, N, l_N );

    test_mrz_dump( "N", N, l_N );
    test_mrz_dump( "x", x, l_x );
    test_mrz_dump( "y", y, l_y );

    mrz_precomp( &ctx, N, l_N );

    mrz_mul( &ctx, r, x, ctx.rho_2 );
    MEASURE( mrz_exp( &ctx, r, r, y, l_y ) );
    mrz_mul( &ctx, r, r, ctx.rho_0 );

    test_mrz_dump( "r", r, l_r );

    printf( "t = pow( x, y, N )                       " "\n"       );

    printf( "if ( r != t ) :                          " "\n"       );
    printf( "  print( 'fail test_mrz:mrz_exp[%d/%d]' )" "\n", i, n );
    printf( "  print( 'N == %%s' %% ( hex( N ) )     )" "\n"       );
    printf( "  print( 'x == %%s' %% ( hex( x ) )     )" "\n"       );
    printf( "  print( 'y == %%s' %% ( hex( y ) )     )" "\n"       );
    printf( "  print( 'r == %%s' %% ( hex( r ) )     )" "\n"       );
    printf( "  print( '  != %%s' %% ( hex( t ) )     )" "\n"       );

    printf( "  sys.exit( 1 )                          " "\n\n"     );
  }
}

// ============================================================================

int main( int argc, char* argv[] ) {
  opt_parse( argc, argv );

  if( NULL == ( urandom = fopen( "/dev/urandom", "rb" ) ) ) {
    abort();
  }

  printf( "import sys\n" );

  int l_min = MIN( opt_mp_mpz_min_limb, CONF_MP_MRZ_MAX_LIMBS );
  int l_max = MIN( opt_mp_mpz_max_limb, CONF_MP_MRZ_MAX_LIMBS );

  test_mrz_exp( opt_trials, l_min, l_max );

  fclose( urandom );

  return 0;
}

// ============================================================================
