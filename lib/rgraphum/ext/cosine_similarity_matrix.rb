class CosineSimilarityMatrix

    inline do |builder|
      builder.include "<math.h>"
      builder.add_compile_flags "-fopenmp"
      builder.c <<-EOF

      VALUE c_similarity( VALUE ary ){
        int i,j,k;

        int m = RARRAY_LEN(ary);
        int n = RARRAY_LEN(rb_ary_entry(ary,0));

        float **val;
        float *s;

        float dot_ab   = 0.0;
        float sq_sum_a = 0.0;
        float sq_sum_b = 0.0;
        VALUE sim_ary = rb_ary_new();
        VALUE sim     = rb_ary_new();

        // float val[m][n];
        val = malloc(sizeof(float *) * m);
        for (i=0;i<m;i++){
          val[i] = malloc(sizeof(float) * n);
        }

        // float s[m][n];
        s = malloc( sizeof(float) * m * m);

        // init
        for( i=0; i<m; i++){
          for( j=0; j<n; j++){
            val[i][j] = NUM2DBL( rb_ary_entry(rb_ary_entry(ary,i),j) );
          }
        }


        for( i=0; i<m; i++){
          for( j=0; j<m; j++){
            if( i == j ){
              s[i*m + j] = 1.0;
            } else if( i > j ){
              s[i*m + j] = s[j*m + i];
            } else {
              dot_ab   = 0.0;
              sq_sum_a = 0.0;
              sq_sum_b = 0.0;

              for( k=0; k<n; k++){
                dot_ab   += ( val[i][k] * val[j][k] );
                sq_sum_a += ( val[i][k] * val[i][k] );
                sq_sum_b += ( val[j][k] * val[j][k] );
              }
              s[i*m + j] = dot_ab / ( sqrt( sq_sum_a * sq_sum_b) );

            }
          }   
        }

        for( i=0; i<m; i++){
          sim = rb_ary_new();
          for( j=0; j<m; j++){
            rb_ary_push( sim, DBL2NUM(s[i*m + j] ));
          }   
          rb_ary_push( sim_ary, sim );
        }

        free(val);
        free(s);

        return sim_ary;
      }
 
      EOF
    end
end

