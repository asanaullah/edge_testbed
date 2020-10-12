void customlogic_axi(
  volatile int *a,
  volatile int *b,
  volatile int *c) {
#pragma HLS INTERFACE s_axilite port = a bundle = hls
#pragma HLS INTERFACE s_axilite port = b  bundle = hls
#pragma HLS INTERFACE s_axilite port = c  bundle = hls
#pragma HLS INTERFACE s_axilite port = return bundle = hls

	  c[0] = a[0] + b[0];

}
